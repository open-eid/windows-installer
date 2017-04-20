#powershell -ExecutionPolicy ByPass -File build.ps1 -msiversion 3.12.0.0
param(
   [string]$candle = "$env:WIX\bin\candle.exe",
   [string]$light = "$env:WIX\bin\light.exe",
   [string]$insignia = "$env:WIX\bin\insignia.exe",
   [string]$msiversion = "3.12.0.0",
   [string]$url = "https://installer.id.ee/media/windows/{2}",
   [string]$filename = "Open-EID-$msiversion$env:VER_SUFFIX",
   [string]$updater = "ID-Updater",
   [string]$qdigidoc = "Digidoc3_Client",
   [string]$shellext = "Digidoc3_ShellExt",
   [string]$qesteid = "ID-card_utility",
   [string]$minidriver = "minidriver",
   [string]$ieplugin = "ie-token-signing",
   [string]$chrome = "chrome-token-signing",
   [string]$firefox = "firefox-token-signing",
   [string]$loader = "firefox-pkcs11-loader",
   [string]$tera = "TeRa",
   [string]$teraVersion = $null,
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
$qdigidoc = GetBaseName $qdigidoc 10
$shellext = GetBaseName $shellext 4
$qesteid = GetBaseName $qesteid 10
$updater = GetBaseName $updater 4
$ieplugin = GetBaseName $ieplugin 4
$chrome = GetBaseName $chrome 4
$firefox = GetBaseName $firefox 4
$loader = GetBaseName $loader 4
$minidriver = GetBaseName $minidriver 4
$teraVersion = GetVersion $tera

Function Sign($filename) {
    signtool.exe sign /a /v /s MY /n "$sign" /fd SHA256 /du http://installer.id.ee `
        /t http://timestamp.verisign.com/scripts/timstamp.dll "$filename"
}
Function Create($wxs, $filename, $defaultX64) {
    & $candle "$path\$wxs.wxs" -nologo -ext WixBalExtension -ext WixUtilExtension `
        "-dMSI_VERSION=$msiversion" "-dpath=$path" "-ddefaultX64=$defaultX64" "-dURL=$url" "-dembed=$embed" `
        "-dupdater=$updater" "-dqesteidutil=$qesteid" "-dqdigidoc=$qdigidoc" "-dteraVersion=$teraVersion" "-dminidriver=$minidriver" `
        "-dieplugin=$ieplugin" "-dchrome=$chrome" "-dfirefox=$firefox" "-dloader=$loader" "-dshellext=$shellext" 
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

& $candle -nologo "$path\metainfo.wxs" "-dMSI_VERSION=$msiversion"
& $light -nologo -out "metainfo.msi" metainfo.wixobj
& $candle -nologo "$path\uninstaller.wxs" "-dMSI_VERSION=$msiversion"
& $light -nologo -out "uninstaller.msi" uninstaller.wixobj
if($sign) {
    Sign("metainfo.msi")
    Sign("uninstaller.msi")
}
Create "bootstrapper" $filename".exe" 1
Create "bootstrapper" $filename"_x86.exe" 0
Create "plugins" $filename"-plugins.exe" 0