; Inno Setup script for the Keychron Battery Widget Windows installer.
; Build from the repo root with:
;   iscc /DAppVersion=1.0.0 build-scripts\windows_installer.iss
; The workflow passes AppVersion from the git tag.

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif

#define AppName       "Keychron Battery Widget"
#define AppPublisher  "Keychron Battery Widget Contributors"
#define AppExeName    "KeychronBatteryWidget.exe"
#define AppId         "{{8F2E5B9F-4D1A-4B1A-9F2D-7E8C3C5B4A11}"

[Setup]
AppId={#AppId}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={autopf}\KeychronBatteryWidget
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
UninstallDisplayName={#AppName}
UninstallDisplayIcon={app}\{#AppExeName}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64
OutputDir=.
OutputBaseFilename=KeychronBatteryWidget-Setup-{#AppVersion}
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
CloseApplications=force
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "autostart"; Description: "Start {#AppName} automatically when Windows starts"; GroupDescription: "Additional options:"
Name: "startapp";  Description: "Launch {#AppName} after installation";              GroupDescription: "Additional options:"

[Files]
; PyInstaller produces a single-file exe that the workflow drops into dist/.
Source: "..\dist\{#AppExeName}"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#AppName}";                 Filename: "{app}\{#AppExeName}"
Name: "{group}\Uninstall {#AppName}";       Filename: "{uninstallexe}"
; Placing the shortcut under {userstartup} makes Windows launch the widget
; for the current user on every sign-in, without needing admin rights.
Name: "{userstartup}\{#AppName}";           Filename: "{app}\{#AppExeName}"; Tasks: autostart

[Run]
Filename: "{app}\{#AppExeName}"; Description: "Launch {#AppName}"; Flags: nowait postinstall skipifsilent; Tasks: startapp

[UninstallRun]
; Best-effort: kill a running instance before removing files so uninstall
; doesn't leave the exe locked.
Filename: "{sys}\taskkill.exe"; Parameters: "/F /IM {#AppExeName}"; Flags: runhidden; RunOnceId: "KillWidget"
