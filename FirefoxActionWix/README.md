
    <Binary Id="FirefoxAction.CA.dll" SourceFile="$(var.src)\FirefoxAction.CA.dll" />
    <CustomAction Id="ExtensionSettingsInstall" Return="check" Execute="firstSequence"
      BinaryKey="FirefoxAction.CA.dll" DllEntry="ExtensionSettingsInstall" />
    <Property Id="EXTENSIONSETTINGS_URL" Value="$(var.URL)" />
    <Property Id="EXTENSIONSETTINGS_UUID" Value="{02274e0c-d135-45f0-8a9c-32b35110e10d}" />

    <InstallExecuteSequence>
      <Custom Action="ExtensionSettingsInstall" Before="WriteRegistryValues">NOT Installed</Custom>
    </InstallExecuteSequence>
