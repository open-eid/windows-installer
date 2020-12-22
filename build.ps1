#powershell -ExecutionPolicy ByPass -File build.ps1 -msiversion 3.12.0.0
param(
   [string]$candle = "$env:WIX\bin\candle.exe",
   [string]$light = "$env:WIX\bin\light.exe",
   [string]$insignia = "$env:WIX\bin\insignia.exe",
   [string]$msiversion = "3.12.0.0",
   [string]$url = "https://installer.id.ee/media/windows/{2}",
   [string]$filename = "Open-EID-$msiversion$env:VER_SUFFIX",
   [string]$vcredist = "vcredist",
   [string]$updater = "ID-Updater",
   [string]$qdigidoc4 = "Digidoc4_Client",
   [string]$shellext = "Digidoc_ShellExt",
   [string]$minidriver = "minidriver",
   [string]$idemia = "AWP",
   [string]$ieplugin = "ie-token-signing",
   [string]$chrome = "chrome-token-signing",
   [string]$loader = "firefox-pkcs11-loader",
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
$vcredist = GetBaseName $vcredist 4
$qdigidoc4 = GetBaseName $qdigidoc4 10
$shellext = GetBaseName $shellext 4
$updater = GetBaseName $updater 4
$ieplugin = GetBaseName $ieplugin 4
$chrome = GetBaseName $chrome 4
$loader = GetBaseName $loader 4
$minidriver = GetBaseName $minidriver 4
$idemia = GetBaseName $idemia 10

Function Sign($filename) {
    signtool.exe sign /a /v /s MY /n "$sign" /fd SHA256 /du http://installer.id.ee `
        /tr http://sha256timestamp.ws.symantec.com/sha256/timestamp /td SHA256 "$filename"
}
Function Create($wxs, $filename, $defaultX64) {
    & $candle "$path\$wxs.wxs" -nologo -ext WixBalExtension -ext WixUtilExtension `
        "-dMSI_VERSION=$msiversion" "-dpath=$path" "-ddefaultX64=$defaultX64" "-dURL=$url" "-dembed=$embed" "-dvcredist=$vcredist" `
        "-dupdater=$updater" "-dqdigidoc4=$qdigidoc4" "-dqesteidutil=$qesteid" "-dqdigidoc=$qdigidoc" `
        "-dminidriver=$minidriver" "-didemia=$idemia" "-dieplugin=$ieplugin" "-dchrome=$chrome" "-dloader=$loader" "-dshellext=$shellext" 
    & $light "$wxs.wixobj" -nologo -ext WixBalExtension -out "$filename"
    if($sign) {
        cp "$filename" "unsigned"
        & $insignia -nologo -ib "$filename" -o "$filename.engine.exe"
        Sign("$filename.engine.exe")
        & $insignia -nologo -ab "$filename.engine.exe" "$filename" -o "$filename"
        Sign("$filename")
        Remove-Item "$filename.engine.exe"
    }
}
& $candle -nologo "$path\qtconf.wxs" "-dMSI_VERSION=$msiversion" -arch x86
& $light -nologo -out "qtconf.x86.msi" qtconf.wixobj
& $candle -nologo "$path\qtconf.wxs" "-dMSI_VERSION=$msiversion" -arch x64
& $light -nologo -out "qtconf.x64.msi" qtconf.wixobj
& $candle -nologo "$path\metainfo.wxs" "-dMSI_VERSION=$msiversion"
& $light -nologo -out "metainfo.msi" metainfo.wixobj
if($sign) {
    Sign("qtconf.x86.msi")
    Sign("qtconf.x64.msi")
    Sign("metainfo.msi")
}
Create "bootstrapper" $filename".exe" 1
Create "bootstrapper" $filename"_x86.exe" 0
Create "plugins" $filename"-plugins.exe" 0
