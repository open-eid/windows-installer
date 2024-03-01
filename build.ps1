#powershell -ExecutionPolicy ByPass -File build.ps1
param(
   [string]$wix = "wix.exe",
   [string]$msiversion = (Get-Date -Format "%y.%M.%d.0"),
   [string]$filename = "Open-EID-$msiversion$env:VER_SUFFIX",
   [string]$updater = "ID-Updater",
   [string]$qdigidoc4 = "Digidoc4",
   [string]$shellext = "Digidoc_ShellExt",
   [string]$idemia = "AWP",
   [string]$webeid = "web-eid",
   [string]$sign = $null
)

Function GetFileName($find) {
    $list = Get-ChildItem "$find*"
    if($list -is [system.array]) {
        $find = $list[0].BaseName
    } else {
        $find = $list.BaseName
    }
    return $find
}

Function GetBaseName($find, $substring) {
    $find = GetFileName $find
    if($substring) {
        $find = $find.Substring(0, $find.Length - $substring)
    }
    return $find
}

Function GetVersion($find) {
    $find = GetFileName $find
    return $find.Substring($find.IndexOf('.') + 1)
}

$path = split-path -parent $MyInvocation.MyCommand.Definition
$qdigidoc4 = GetBaseName $qdigidoc4 4
$shellext = GetBaseName $shellext 4
$updater = GetBaseName $updater 4
$webeid = GetBaseName $webeid 4
$idemia = GetBaseName $idemia 10

Function Sign($filename) {
    signtool.exe sign /a /v /s MY /n "$sign" /fd SHA256 /du http://installer.id.ee `
        /tr http://sha256timestamp.ws.symantec.com/sha256/timestamp /td SHA256 "$filename"
}
& $wix build -nologo -ext WixToolset.Util.wixext "$path\browserrestart.wxs" -d "MSI_VERSION=$msiversion" `
    -loc "$path\browserrestart.en-US.wxl" -culture en-US -out browserrestart.en-US.msi
& $wix build -nologo -ext WixToolset.Util.wixext "$path\browserrestart.wxs" -d "MSI_VERSION=$msiversion" `
    -loc "$path\browserrestart.et-EE.wxl" -culture et-EE -out browserrestart.et-EE.msi
& $wix build -nologo "$path\metainfo.wxs" -d "MSI_VERSION=$msiversion" -out metainfo.msi
if($sign) {
    Sign("browserrestart.en-US.msi")
    Sign("browserrestart.et-EE.msi")
    Sign("metainfo.msi")
}
& $wix build "$path\bootstrapper.wxs" -nologo -ext WixToolset.Bal.wixext -ext WixToolset.Util.wixext `
    -d "MSI_VERSION=$msiversion" -d "path=$path" -d "idemia=$idemia" -d "updater=$updater" `
    -d "webeid=$webeid" -d "qdigidoc4=$qdigidoc4" -d "shellext=$shellext" -out "$filename.exe"
if($sign) {
    cp "$filename.exe" "unsigned"
    & $wix burn detach -nologo "$filename.exe" -engine "$filename.engine.exe"
    Sign("$filename.engine.exe")
    & $wix burn reattach -nologo "$filename.exe" -engine "$filename.engine.exe" -o "$filename.exe"
    Sign("$filename.exe")
    Remove-Item "$filename.engine.exe"
}
