Packaging version [19.07](https://github.com/open-eid/osx-installer/releases/tag/v19.07) release notes
--------------------------------------------
- Option to disable Chrome extension activation policy

[Full Changelog](https://github.com/open-eid/osx-installer/compare/v18.12...v19.07)

Packaging version [18.12](https://github.com/open-eid/osx-installer/releases/tag/v18.12) release notes
--------------------------------------------
- Include IDEMIA drivers

[Full Changelog](https://github.com/open-eid/osx-installer/compare/v18.10...v18.12)

Packaging version [18.06](https://github.com/open-eid/windows-installer/releases/tag/v18.06) release notes
--------------------------------------------
- Include DigiDoc4 client in the Open-EID installer

Packaging version [18.03](https://github.com/open-eid/windows-installer/releases/tag/v18.03) release notes
--------------------------------------------
- Remove uninstall/upgrade msi-s (#25)
- Add versioned vcredist (#26)
- Set REINSTALLMODE to "amus" (#28)
- Dont install driver on X86 for workaround wix bootstrapper bug (#29)

[Full Changelog](https://github.com/open-eid/windows-installer/compare/v17.12...v17.03)

Packaging version [17.12](https://github.com/open-eid/windows-installer/releases/tag/v17.12) release notes
--------------------------------------------
- Include new Fireofx PKCS11 loader for Firefox 58

[Full Changelog](https://github.com/open-eid/windows-installer/compare/v17.11...v17.12)

Packaging version [17.11](https://github.com/open-eid/windows-installer/releases/tag/v17.11) release notes
--------------------------------------------
- Include VC redistributable packages to install Windows Universal Runtimes

[Full Changelog](https://github.com/open-eid/windows-installer/compare/v17.10...v17.11)

Packaging version [17.10](https://github.com/open-eid/windows-installer/releases/tag/v17.10) release notes
--------------------------------------------
- Remove NPAPI plugin

[Full Changelog](https://github.com/open-eid/windows-installer/compare/v17.08...v17.10)

Packaging version [17.08](https://github.com/open-eid/windows-installer/releases/tag/v17.08) release notes
--------------------------------------------
- Don't run ID-Card utility at end

[Full Changelog](https://github.com/open-eid/windows-installer/compare/v17.06...v17.08)

Packaging version [17.06](https://github.com/open-eid/windows-installer/releases/tag/v17.06) release notes
--------------------------------------------
- Include TeRa time-stamping application
- Separate plugins installer

[Full Changelog](https://github.com/open-eid/windows-installer/compare/v17.01...v17.06)

Packaging version [17.01](https://github.com/open-eid/windows-installer/releases/tag/v17.01) release notes
--------------------------------------------
- Fix chrome-token-signing install with Firefox components

[Full Changelog](https://github.com/open-eid/windows-installer/compare/v3.12.5...v17.01)


Packaging version 3.12.2 release notes
--------------------------------------
Changes compared to ver 3.12.1

- Split Windows Explorer Shell Extension to separate msi-s


Packaging version 3.12.1 release notes
--------------------------------------
Changes compared to ver 3.12.0

- Option to install 32 bit Desktop applications on 64 bit host


Packaging version 3.12.0 release notes
--------------------------------------
Changes compared to ver 3.11.1

- Improved installation package of eID software, it is now possible during installation process to customize the set of software components that will be installed. 
- 64-bit versions of DigiDoc3 Client and ID-card utility are now supported in case of 64-bit Windows operating systems.
- Improved OpenSC driver that is included in installation, added Dell 3G modem ATR values in order to avoid Firefox crashing if the Dell 3G card is used.
- Changed branding.


Packaging version 3.11.1 release notes
--------------------------------------
Changes compared to ver 3.11.0

- Upgraded bundled Openssl to 1.0.2d version

List of known issues: https://github.com/open-eid/windows-installer/wiki/Known-issues


Packaging version 3.11.0 release notes
--------------------------------------
Changes compared to ver 3.10.3

- Register Firefox PKCS11 Module on X64 bit Firefox Browser
- Added option to customize the selection of components that are being installed
- Started using SHA-256 algorithm when signing the installation package
- Updated the base libraries versions


Packaging version 3.10.3 release notes
--------------------------------------
Changes compared to ver 3.10.2

- Running windows installer with ENABLENPAPI=OFF key disables enabling NPAPI support in Chrome. Windows installer doesn't check if chrome is running and updater is not executed. This makes it possible to run windows installer quietly.

Known issues:
- The ENABLENPAPI=OFF key does not work when upgrading from 3.10.2 to 3.10.3 in which case the Windows installer cannot be run quietly (if Chrome is running). This does not affect a clean install or upgrading from an earlier version.


Packaging version 3.10.2 release notes
--------------------------------------
Changes compared to ver 3.10

- Added functionality for enabling NPAPI support in Chrome. Windows installer checks if Chrome is running and executes Updater. The -chrome-npapi flag is set by Updater.
- C++ Runtime files moved to Application folder to support SCCM and GPO silent install

Known issues:
- The Windows installer cannot be run quietly (if Chrome is running).


Packaging version 3.10 release notes
--------------------------------------
Changes compared to ver 3.9.1

- Changed Windows installation package, SK's certificates are no longer installed to the certificate store, previously installed SK certificates are removed. The SK CA certificates are distributed through the operating system's native update mechanism. The CA certificates used by DigiDoc3 Client are now taken from TSL (Trust Service Status List).
- 2010 C++ Runtime is now installed only when msvcp100.dll file is not found in System32 folder to resolve problem with ID-software installation in Windows Server 2012.
- Fixed problem with Windows Minidriver installation in Windows 8.
- Updated OpenSC PKCS#11 module, version 0.14.0 is now used in Windows installations. 


Packaging version 3.9.1 release notes
--------------------------------------
Changes compared to ver 3.9

- Fixed Windows installation package parameter that can be used by administrators to avoid installing the default certificates that are included in the package. Otherwise, the default certificates are re-installed and existing certificates are overwritten.
- Fixed KLASS3-SK 2010 certificate's installation problem in Windows.


Packaging version 3.9 release notes
--------------------------------------
Changes compared to ver 3.8.2

- Improved ID-software installer in Windows, now the Windows explorer extension component is not re-built if it hasn't had any changes.
- Removed packaging support for Windows XP and Vista operating systems.
- Added new Finnish certificates "VRK CA for Qualified Certificates - G2" or "VRK Gov. CA for Citizen Qualified Certificates - G2" to Finnish certificates' installation packages. 
- Added Finnish, Latvian, Lithuanian test certificates to test certificates' installation packages. 
- Added missing KLASS3-SK 2010 certificate (issued by EE Certification Centre Root CA) to ID-software installation package for Windows environment.


Packaging version 3.8.2 release notes
--------------------------------------
Changes compared to ver 3.8.1

- Added Microsoft Visual C++ 2008 SP1 run-time library for Windows XP SP3 users to fix authentication with smart card in Internet Explorer browser.
- Fixed the removal of smart card ATR entries during Minidriver installation, existing ATR entries which have been created during installing Minidriver from MS Update are not removed when installing ID-card software package which supports the same Minidriver version. 
- Changed ID-card software installation in Windows environment to improve EstEID plugin usage in Internet Explorer browsers. During ID-card software installation, the user's group policy settings are altered so that EstEID plugin usage is automatically allowed in Internet Explorer, additional confirmation is no longer asked from the user in the browser. As a result, the EstEID plugin can not be manually disabled in Internet Explorer settings, the user has to uninstall ID-card software package to remove the plugin.


Packaging version 3.8.1 release notes
--------------------------------------
Changes compared to ver 3.8.0

- Added Qt 4.8 packaging support for Windows XP users who use a certain type of graphic card outdated drivers.
- Added restoring of parameter EnableScPnP to Windows default value for the installation of Minidriver to succeed in some DELL computers. 
- Removed smart card ATR records that collide with the Estonian ID card ATR values from ActivIdentity ProtectTools for the installation of Minidriver to succeed in some HP computers.


Packaging version 3.8.0 release notes
--------------------------------------

- Updated the compilation of Windows packages to Visual Studio 2010.
- Improved Windows installer: added translation to Estonian language and implemented new design.
