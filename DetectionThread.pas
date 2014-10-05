{
    XVM Updater - World of Tanks's XVM one click installer/updater
    Copyright (C) 2013 - 2014  Edgar 'LaCourgette' Fournival

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
}

unit DetectionThread;

interface

uses
  Classes;

type
  TDetectionThread = class(TThread)
    constructor Create; overload;
  public
    InstallationFound: Boolean;
    procedure RecordInstallation(Path: String);
  private
    Installations: TStringList;
  protected
    procedure Execute; override;
  end;

implementation

uses
  SysUtils, Main, WoT_Utils, Masks, Windows, ActiveX;


constructor TDetectionThread.Create;
begin
  FreeOnTerminate := True;
  InstallationFound := False;
  Installations := TStringList.Create;

  inherited Create(false);
end;


procedure TDetectionThread.RecordInstallation(Path: String);
begin
  if not(InstallationFound) then
    begin
      InstallationFound := true;
      Synchronize(procedure
        begin
          fWindow.cbInstallations.Items.Insert(0, Path); // Top of the list
          fWindow.SetVersion(Path);
        end);
      Installations.Add(Path);
    end
  else
    begin
      if Installations.IndexOf(Path) = -1 then
        begin
          Installations.Add(Path);
          Synchronize(procedure
            begin
              fWindow.cbInstallations.Items.Insert(
                fWindow.cbInstallations.Items.Count-1, Path); // Before last one
            end);
        end;
    end;
end;


procedure TDetectionThread.Execute;
const
  WoT_Dir: array[1..12] of String = (
      'World_of_Tanks',
      'World of Tanks',
      'World_of_Tanks_closed_Beta',
      'Games\World_of_Tanks',
      'Games\World of Tanks',
      'Games\World_of_Tanks_closed_Beta',
      'Program Files (x86)\World_of_Tanks',
      'Program Files (x86)\World of Tanks',
      'Program Files (x86)\World_of_Tanks_closed_Beta',
      'Program Files\World_of_Tanks',
      'Program Files\World of Tanks',
      'Program Files\World_of_Tanks_closed_Beta'
    );
var
  vDrivesSize: Cardinal;
  vDrives: array[0..128] of Char;
  vDrive: PChar;
  I: Integer;
  searchResult: TSearchRec;
  StartMenu: String;
  currentSC: String;
  Directory: String;
begin
  CoInitialize(nil);

  try
    // Checking global Start menu shortcut (fast)
    try
      StartMenu := GetStartMenuPrograms;
      if FileExists(StartMenu + '\World of Tanks\World of tanks.lnk') then
        begin
          Directory := ExtractFileDir(
            GetShortcutTarget(StartMenu + '\World of Tanks\World of tanks.lnk'));
          if FileExists(Directory + '\worldoftanks.exe') then RecordInstallation(Directory);
        end;
    except
      // Fail silently.
    end;

    // Checking desktop shortcut linking to "worldoftanks.exe" or "xvm-stat.exe" (slow)
    try
      if FindFirst(GetDesktop + '\' + '*.lnk', faAnyFile, searchResult) = 0 then
        begin
          repeat
            CurrentSC := GetShortcutTarget(GetDesktop + '\' + searchResult.Name);
            if MatchesMask(CurrentSC, '*WorldOfTanks.exe') or
               MatchesMask(CurrentSC, '*xvm-stat.exe') or
               MatchesMask(CurrentSC, '*WOTLauncher.exe') then
              begin
                Directory := ExtractFileDir(CurrentSC);
                if FileExists(Directory + '\worldoftanks.exe') then RecordInstallation(Directory);
              end;
          until FindNext(searchResult) <> 0;
          SysUtils.FindClose(searchResult);
        end;
    except
      // Fail silently.
    end;

    // Checking known directories on each disk (slower)
    try
      vDrivesSize := GetLogicalDriveStrings(SizeOf(vDrives), vDrives);
      if vDrivesSize = 0 then Exit;

      vDrive := vDrives;
      while vDrive^ <> #0 do
        begin
          if IsDriveReady(vDrive) then
            begin
              for I := 1 to Length(WoT_Dir) do
                begin
                  if DirectoryExists(StrPas(vDrive) + WoT_Dir[I] + '\') then
                    begin
                      Directory := StrPas(vDrive) + WoT_Dir[I];
                      if FileExists(Directory + '\worldoftanks.exe') then RecordInstallation(Directory);
                    end;
                end;
            end;
          Inc(vDrive, SizeOf(vDrive));
        end;
    except
      // Fail silently.
    end;
  finally
    CoUninitialize;
  end;

  Terminate;
end;

end.
