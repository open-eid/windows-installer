#powershell -ExecutionPolicy ByPass -File build.ps1 -version 3.12.0.0
param(
   [string]$heat = "$env:WIX\bin\heat.exe",
   [string]$candle = "$env:WIX\bin\candle.exe",
   [string]$light = "$env:WIX\bin\light.exe",
   [string]$torch = "$env:WIX\bin\torch.exe",
   [string]$msbuild = "C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe",
   [string]$version = "3.12.0.0",
   [string]$sign = $null
)

$env:MSI_VERSION = $version
$env:CLIENT_PATH = "libs\DigiDoc3 Client"
$env:UTIL_PATH = "libs\ID-card utility"
$env:CHROME_TOKEN_PATH = "libs\Chrome Token Signing"
$env:ARCHIVE = "."
if( !(Test-Path Env:\VCINSTALLDIR) ) {
    $env:VCINSTALLDIR = "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\"
}
$filename = "Eesti_ID_kaart-$version$env:VER_SUFFIX"
$cwd = Split-Path $MyInvocation.MyCommand.Path
$shell = new-object -com shell.application
$installer = new-object -comobject WindowsInstaller.Installer

Function Sign ($filename) {
    signtool.exe sign /a /v /s MY /n "$sign" /fd SHA256 /du http://installer.id.ee `
        /t http://timestamp.verisign.com/scripts/timstamp.dll "$filename"
}

Function CreateProductsXML ($msi, $out) {
    $db = $installer.GetType().InvokeMember("OpenPackage","InvokeMethod",$Null,$installer,@("$cwd\$msi",1))
    if(!$db) {
        return
    }

    $xml = New-Object System.XMl.XmlTextWriter("$cwd\$out",$Null)
    $xml.Formatting = "Indented"
    $xml.Indentation = "4"
    $xml.WriteStartDocument()
    $xml.WriteStartElement("products")
    $xml.WriteStartElement("product")
    $xml.WriteAttributeString("filename", $msi)
    foreach($property in @("ProductName", "ProductVersion", "Manufacturer", "ProductCode", "UpgradeCode")) {
        $xml.WriteAttributeString($property, $db.GetType().InvokeMember("Property","GetProperty",$Null,$db,$property))
    }
    $xml.WriteEndElement()
    $xml.WriteEndElement()
    $xml.WriteEndDocument()
    $xml.Close()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($db)
}

& $msbuild "/p:Configuration=Release;Platform=Win32" EstEIDFindCertificateAction\EstEIDFindCertificateAction.vcxproj

mkdir -Force -Path "libs"
mkdir -Force -Path "unsigned"
msiexec /qn /a Digidoc3_Client.msi TARGETDIR="$cwd\libs" | Out-Null
msiexec /qn /a ID-card_utility.msi TARGETDIR="$cwd\libs" | Out-Null
msiexec /qn /a chrome-token-signing.msi TARGETDIR="$cwd\libs" | Out-Null
msiexec /qn /a esteid-plugin-ie_x64.msi TARGETDIR="$cwd\X64" | Out-Null
msiexec /qn /a esteid-plugin-ie_x86.msi TARGETDIR="$cwd\X86" | Out-Null
msiexec /qn /a firefox-token-signing_x86.msi TARGETDIR="$cwd\X86" | Out-Null
msiexec /qn /a firefox-token-signing_x64.msi TARGETDIR="$cwd\X64" | Out-Null

Remove-Item "$env:CLIENT_PATH\certs\TEST*.crt"
& $heat dir "$env:CLIENT_PATH\certs" -nologo -gg -scom -sreg -sfrag -srd -cg SKCertificates `
  -dr CertificatesFolder -var var.certsLocation -out CertsFragment.wxs

$wix_modules = @("WixUI_IDCard", "WixUI_ChangeLog", "RemoveOldSoftDlg", "MyInstallDirDlg",
    "minidriver", "opensc", "commonlibs", "CertsFragment", "qdigidoc", "qesteidutil", "updater",
    "esteid-browser-plugin", "ie-plugin", "chrome-token-signing", "Eesti_ID_kaart")
$cultures = @("en-US", "et-EE")

foreach($platform in @("x86", "x64")) {
    foreach($version in @("7", "8", "8.1")) {
        mkdir -Force -Path "minidriver\$version$platform"
        foreach($item in $shell.NameSpace("$cwd\esteidcm_win$version$platform.zip").items()) {
            $shell.Namespace("$cwd\minidriver\$version$platform").CopyHere($item,0x14)
        }
    }
    foreach($mod in $wix_modules) {
        & $candle -nologo "$mod.wxs" -v -ext WixUtilExtension -ext WixDifxAppExtension `
          "-dPlatform=$platform" "-dcertsLocation=$env:CLIENT_PATH\certs"
    }
    foreach($culture in $cultures) {
        $wix_modules_obj = ($wix_modules -join ".wixobj ") + ".wixobj"
        & $light -nologo -out "$($filename)_$culture.$platform.msi" -sice:ICE57 -sice:ICE03 `
          -ext WixUtilExtension -ext WixUIExtension -ext WixDifxAppExtension `
          -loc IDCard_$culture.wxl -cultures:$culture `
          "-dcertsLocation=$env:CLIENT_PATH\certs" `
          "$env:WIX\bin\difxapp_$platform.wixlib" `
          $wix_modules_obj.Split(" ")
        if($sign) {
            cp "$($filename)_$culture.$platform.msi" "unsigned"
            Sign("$($filename)_$culture.$platform.msi")
        }
    }
    & $torch -nologo -p -t language -out `
      "$($filename)_$($cultures[1]).$platform.mst" `
      "$($filename)_$($cultures[0]).$platform.msi" `
      "$($filename)_$($cultures[1]).$platform.msi"
    CreateProductsXML "$($filename)_$($cultures[1]).$platform.msi" "products_$platform.xml"
}
