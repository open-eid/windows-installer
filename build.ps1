#powershell -ExecutionPolicy ByPass -File build.ps1
param(
   [string]$candle = "$env:WIX\bin\candle.exe",
   [string]$light = "$env:WIX\bin\light.exe",
   [string]$insignia = "$env:WIX\bin\insignia.exe",
   [string]$msiversion = (Get-Date -Format "%y.%M.%d.0"),
   [string]$url = "https://installer.id.ee/media/windows/{2}",
   [string]$filename = "Open-EID-$msiversion$env:VER_SUFFIX",
   [string]$updater = "ID-Updater",
   [string]$qdigidoc4 = "Digidoc4_Client",
   [string]$shellext = "Digidoc_ShellExt",
   [string]$idemia = "AWP",
   [string]$webeid = "web-eid",
   [string]$embed = "no",
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
$qdigidoc4 = GetBaseName $qdigidoc4 10
$shellext = GetBaseName $shellext 4
$updater = GetBaseName $updater 4
$webeid = GetBaseName $webeid 4
$idemia = GetBaseName $idemia 10

Function Sign($filename) {
    signtool.exe sign /a /v /s MY /n "$sign" /fd SHA256 /du http://installer.id.ee `
        /tr http://sha256timestamp.ws.symantec.com/sha256/timestamp /td SHA256 "$filename"
}
& $candle -nologo -ext WixUtilExtension "$path\browserrestart.wxs" "-dMSI_VERSION=$msiversion"
& $light -nologo -ext WixUtilExtension -loc "$path\browserrestart.en-US.wxl" -cultures:en-US -out browserrestart.en-US.msi browserrestart.wixobj
& $light -nologo -ext WixUtilExtension -loc "$path\browserrestart.et-EE.wxl" -cultures:et-EE -out browserrestart.et-EE.msi browserrestart.wixobj
& $candle -nologo "$path\metainfo.wxs" "-dMSI_VERSION=$msiversion"
& $light -nologo -out metainfo.msi metainfo.wixobj
if($sign) {
    Sign("browserrestart.en-US.msi")
    Sign("browserrestart.et-EE.msi")
    Sign("metainfo.msi")
}
& $candle "$path\bootstrapper.wxs" -nologo -ext WixBalExtension -ext WixUtilExtension `
    "-dMSI_VERSION=$msiversion" "-dpath=$path" "-dURL=$url" "-dembed=$embed" `
    "-dupdater=$updater" "-dqdigidoc4=$qdigidoc4" "-dshellext=$shellext" `
    "-didemia=$idemia" "-dwebeid=$webeid"
& $light bootstrapper.wixobj -nologo -ext WixBalExtension -out "$filename.exe"
if($sign) {
    cp "$filename.exe" "unsigned"
    & $insignia -nologo -ib "$filename.exe" -o "$filename.engine.exe"
    Sign("$filename.engine.exe")
    & $insignia -nologo -ab "$filename.engine.exe" "$filename.exe" -o "$filename.exe"
    Sign("$filename.exe")
    Remove-Item "$filename.engine.exe"
}
