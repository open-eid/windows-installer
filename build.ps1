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
   [string]$idemia = "AWP",
   [string]$sign = $null
)

Function GetBaseName($find, $substring) {
    $list = Get-ChildItem "$find*"
    if($list -is [system.array]) {
        $find = $list[0].BaseName
    } else {
        $find = $list.BaseName
    }
    return $find.Substring(0, $find.Length - $substring)
}

$idemia = GetBaseName $idemia 6

Function Sign($filename) {
    signtool.exe sign /a /v /s MY /n "$sign" /fd SHA256 /du http://installer.id.ee `
        /tr http://sha256timestamp.ws.symantec.com/sha256/timestamp /td SHA256 "$filename"
}
& wix build -nologo -ext WixToolset.Util.wixext "$path\browserrestart.wxs" -d "MSI_VERSION=$msiversion" `
    -loc "$path\browserrestart.en-US.wxl" -culture en-US -out browserrestart.en-US.msi
& wix build -nologo -ext WixToolset.Util.wixext "$path\browserrestart.wxs" -d "MSI_VERSION=$msiversion" `
    -loc "$path\browserrestart.et-EE.wxl" -culture et-EE -out browserrestart.et-EE.msi
& wix build -nologo "$path\metainfo.wxs" -d "MSI_VERSION=$msiversion" -out metainfo.msi
if($sign) {
    Sign("browserrestart.en-US.msi")
    Sign("browserrestart.et-EE.msi")
    Sign("metainfo.msi")
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
