#powershell -ExecutionPolicy ByPass -File build.ps1
param(
   [string]$path = $PSScriptRoot,
   [string]$build_number = $(if ($null -eq $env:BUILD_NUMBER) {"0"} else {$env:BUILD_NUMBER}),
   [string]$msiversion = (Get-Date -Format "%y.%M.%d.$build_number"),
   [string]$filename = "Open-EID-$msiversion$env:VER_SUFFIX",
   [string]$updater_x64 = (Get-ChildItem "ID-Updater*x64.msi"),
   [string]$updater_arm64 = (Get-ChildItem "ID-Updater*arm64.msi"),
   [string]$qdigidoc4_x64 = (Get-ChildItem "Digidoc4*x64.msi"),
   [string]$qdigidoc4_arm64 = (Get-ChildItem "Digidoc4*arm64.msi"),
   [string]$shellext = (Get-ChildItem "Digidoc_ShellExt*x64.msi"),
   [string]$webeid_x64 = (Get-ChildItem "web-eid*x64.msi"),
   [string]$webeid_arm64 = (Get-ChildItem "web-eid*arm64.msi"),
   [string]$idemia = (Get-ChildItem "idplug-classic-*-Estonia_64bit.msi"),
   [string]$thales_x64 = (Get-ChildItem "SmartCard_Client_64*.msi"),
   [string]$thales_arm64 = (Get-ChildItem "SmartCard_Client_arm64*.msi"),
   [string]$certdel_x64 = (Get-ChildItem "CertDelApp_64*.msi"),
   [string]$certdel_arm64 = (Get-ChildItem "CertDelApp_arm64*.msi"),
   [string]$sign = $null
)

Function Sign($filename) {
    & signtool.exe sign /a /v /s MY /n "$sign" /fd SHA256 /du http://installer.id.ee `
        /tr http://timestamp.digicert.com /td SHA256 "$filename"
}
& wix build -nologo "$path\metainfo.wxs" -d "MSI_VERSION=$msiversion" -out metainfo.msi
if($sign) {
    Sign("metainfo.msi")
    Sign("$path\RemoveAWPBlock.mst")
}
& wix build -nologo -ext WixToolset.BootstrapperApplications.wixext -ext WixToolset.Util.wixext "$path\bootstrapper.wxs" `
    -out "$filename.exe" -d "MSI_VERSION=$msiversion" -d "path=$path" -d "idemia=$idemia" -d "shellext=$shellext" `
    -d "thales_x64=$thales_x64" -d "thales_arm64=$thales_arm64" -d "certdel_x64=$certdel_x64" -d "certdel_arm64=$certdel_arm64" `
    -d "webeid_x64=$webeid_x64" -d "qdigidoc4_x64=$qdigidoc4_x64"  -d "updater_x64=$updater_x64" `
    -d "webeid_arm64=$webeid_arm64" -d "qdigidoc4_arm64=$qdigidoc4_arm64" -d "updater_arm64=$updater_arm64"
if($sign) {
    & wix burn detach -nologo "$filename.exe" -engine "$filename.engine.exe"
    Sign("$filename.engine.exe")
    & wix burn reattach -nologo "$filename.exe" -engine "$filename.engine.exe" -o "$filename.exe"
    Sign("$filename.exe")
    Remove-Item "$filename.engine.exe"
}
