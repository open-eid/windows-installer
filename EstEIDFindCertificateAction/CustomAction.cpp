/*
* EstEIDFindCertificateAction - custom actions for Estonian EID card WiX installer
*
* Copyright (C) 2011 Codeborne (info@codeborne.com)
*
* This library is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This library is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this library; if not, write to the Free Software
* Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

#include "stdafx.h"
#include "skHashes.h"

#pragma comment(lib, "crypt32.lib")
#include <Wincrypt.h>

#define BUF_SIZE 256

HRESULT GetProperty(MSIHANDLE hInstaller, LPCWSTR property, LPWSTR value, DWORD cch_value);
bool IsCertificateInstalled(unsigned char* hash, wchar_t* certStoreName);
PCCERT_CONTEXT FindCertificateByHash(HCERTSTORE hSystemStore, unsigned char *hash);
UINT __stdcall SetCertificatesStatuses(MSIHANDLE hInstall);

UINT __stdcall SetCertificatesStatuses(MSIHANDLE hInstall)
{
    HRESULT hr = S_OK;
    UINT er = ERROR_SUCCESS;
    char buf[BUF_SIZE];
    bool isCertInstalled;

    hr = WcaInitialize(hInstall, "SetCertificatesStatuses");
    ExitOnFailure(hr, "Failed to initialize");
    WcaLog(LOGMSG_STANDARD, "Initialized.");
    
    sprintf_s(buf, BUF_SIZE, "Number of certs in DLL = %i", SK_HASH_COUNT);
    WcaLog(LOGMSG_STANDARD, buf);

    for(int i = 0; i < SK_HASH_COUNT; i++) {
        isCertInstalled = IsCertificateInstalled(skHashes[i].skHash, skHashes[i].certStoreName);
        hr = WcaSetIntProperty(skHashes[i].propertyName, isCertInstalled);	
        sprintf_s(buf, BUF_SIZE, "Certificate #%i property value is %i", i, /*skHashes[i].propertyName,*/ isCertInstalled);
        WcaLog(LOGMSG_STANDARD, buf);
        sprintf_s(buf, BUF_SIZE, "Failed to set cert #%i property value", i);
        ExitOnFailure(hr, buf);
    }

LExit:
    er = SUCCEEDED(hr) ? ERROR_SUCCESS : ERROR_INSTALL_FAILURE;
    return WcaFinalize(er);
}

UINT __stdcall UninstallCertificates(MSIHANDLE hInstall)
{
    HRESULT hr = WcaInitialize(hInstall, "UninstallCertificates");
    ExitOnFailure(hr, "Failed to initialize");
    WcaLog(LOGMSG_STANDARD, "Initialized.");

    HANDLE rootStore = CertOpenStore(CERT_STORE_PROV_SYSTEM,
        0, NULL, CERT_SYSTEM_STORE_LOCAL_MACHINE, L"root");
    HANDLE caStore = CertOpenStore(CERT_STORE_PROV_SYSTEM,
        0, NULL, CERT_SYSTEM_STORE_LOCAL_MACHINE, L"ca");
    if(!rootStore || !caStore)
    {
        WcaLog(LOGMSG_STANDARD, "Failed to open CertificateStore");
        return WcaFinalize(ERROR_SUCCESS);
    }

    for(int i = 0; i < SK_HASH_COUNT; i++) {
        CRYPT_HASH_BLOB toFindData = { SK_HASH_LEN, skHashes[i].skHash };
        PCCERT_CONTEXT pCertContext = CertFindCertificateInStore(
            wcscmp(skHashes[i].certStoreName, L"root") == 0 ? rootStore : caStore,
            X509_ASN_ENCODING|PKCS_7_ASN_ENCODING, 0, CERT_FIND_HASH, &toFindData, NULL);

        if(!pCertContext)
        {
            WcaLog(LOGMSG_STANDARD, "Not found Certificate #%i", i);
            continue;
        }

        WCHAR name[128];
        CertGetNameString(pCertContext,
            CERT_NAME_FRIENDLY_DISPLAY_TYPE, 0, NULL, name, 128);

        if(!wcsstr(name, L"wixCert_1"))
        {
            WcaLog(LOGMSG_STANDARD, "Certificate #%i %S does not contain wixCert", i, name);
            continue;
        }

        CertDeleteCertificateFromStore(pCertContext);
        WcaLog(LOGMSG_STANDARD, "Removing Certificate #%i %S", i, name);
    }

LExit:
    CertCloseStore(caStore, 0);
    CertCloseStore(rootStore, 0);
    return WcaFinalize(ERROR_SUCCESS);
}

PCCERT_CONTEXT FindCertificateByHash(HCERTSTORE hSystemStore, unsigned char *hash)
{
    PCCERT_CONTEXT pCertContext = NULL;
    CRYPT_HASH_BLOB toFindData;

    toFindData.cbData = SK_HASH_LEN;
    toFindData.pbData = hash;

    pCertContext = CertFindCertificateInStore(hSystemStore,
        X509_ASN_ENCODING |
        PKCS_7_ASN_ENCODING, 0,
        CERT_FIND_HASH, &toFindData,
        NULL);
    return pCertContext;
}

bool IsCertificateInstalled(unsigned char* hash, wchar_t* certStoreName)
{
    HANDLE hSystemStore;
    PCCERT_CONTEXT pCertContext;
    bool ret;

    hSystemStore = CertOpenSystemStore(NULL, certStoreName);
    if (!hSystemStore) {
        ret = false;
    }

    wprintf(L"Accessing certificate store: %s\n", certStoreName);

    pCertContext = FindCertificateByHash(hSystemStore, hash);
    if (pCertContext) {
        ret = true;
    } else {
        ret = false;
    }

    CertCloseStore(hSystemStore, 0);
    return ret;
}

HRESULT GetProperty(MSIHANDLE hInstaller, LPCWSTR property, LPWSTR value, DWORD cch_value) {
    UINT err = MsiGetProperty(hInstaller, property, value, &cch_value);
    return (err == ERROR_SUCCESS ? S_OK : E_FAIL);
}

// DllMain - Initialize and cleanup WiX custom action utils.
extern "C" BOOL WINAPI DllMain(
                               __in HINSTANCE hInst,
                               __in ULONG ulReason,
                               __in LPVOID
                               )
{
    switch(ulReason)
    {
    case DLL_PROCESS_ATTACH:
        WcaGlobalInitialize(hInst);
        break;

    case DLL_PROCESS_DETACH:
        WcaGlobalFinalize();
        break;
    }

    return TRUE;
}
