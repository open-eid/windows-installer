#powershell -ExecutionPolicy ByPass -File build.ps1
param(
   [string]$path = $PSScriptRoot,
   [string]$build_number = $(if ($null -eq $env:BUILD_NUMBER) {"0"} else {$env:BUILD_NUMBER}),
   [string]$msiversion = (Get-Date -Format "%y.%M.%d.$build_number"),
   [string]$filename = "Open-EID-$msiversion$env:VER_SUFFIX",
   [string]$updater = (Get-ChildItem "ID-Updater*x64.msi"),
   [string]$qdigidoc4 = (Get-ChildItem "Digidoc4*x64.msi"),
   [string]$shellext = (Get-ChildItem "Digidoc_ShellExt*x64.msi"),
   [string]$webeid = (Get-ChildItem "web-eid*x64.msi"),
   [string]$idemia = (Get-ChildItem "idplug-classic-*-Estonia_64bit.msi"),
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
    -d "MSI_VERSION=$msiversion" -d "path=$path" -d "idemia=$idemia" -d "updater=$updater" `
    -d "webeid=$webeid" -d "qdigidoc4=$qdigidoc4" -d "shellext=$shellext" -out "$filename.exe"
if($sign) {
    & wix burn detach -nologo "$filename.exe" -engine "$filename.engine.exe"
    Sign("$filename.engine.exe")
    & wix burn reattach -nologo "$filename.exe" -engine "$filename.engine.exe" -o "$filename.exe"
    Sign("$filename.exe")
    Remove-Item "$filename.engine.exe"
}
