windows-installer
=================

A WIX bootstrapper EXE with DigiDoc, ID-card utility and package with various drivers.

1. Fetch the source

        git clone --recursive https://github.com/open-eid/windows-installer
        cd windows-installer

2. Download dependencies to packages folder
   * Digidoc4_Client*.msi
   * Digidoc3_Client*.msi
   * ID-card_utility*.msi
   * ID-Updater*.msi
   * TeRa*.msi
   * chrome-token-signing*.msi
   * esteid-plugin-ie*.msi
   * firefox_pkcs11_loader*.msi
   * firefox-token-signing*.msi
   * minidriver*.msi

3. Run build.ps1 script, optional parameter -msiversion

        powershell -ExecutionPolicy ByPass -File build.ps1 -msiversion 3.12.0.0

4. Execute

        Open-EID.exe

## Support
Official builds are provided through official distribution point [installer.id.ee](https://installer.id.ee). If you want support, you need to be using official builds. Contact for assistance by email [abi@id.ee](mailto:abi@id.ee) or [www.id.ee](http://www.id.ee).

Source code is provided on "as is" terms with no warranty (see license for more information). Do not file Github issues with generic support requests.