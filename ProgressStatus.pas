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

unit ProgressStatus;

interface

uses
  Contnrs, ComCtrls, StdCtrls, Forms;

type
  TProgressStatus = class
  public
    constructor Create; overload;
    procedure SetupControls(Form: TForm);
    procedure RemoveControls(Form: TForm);
    procedure SetProgress(Progress: Integer);
    procedure SetNormal(PMax: Int64 = 100);
    procedure SetWaiting;
    procedure SetError;
    procedure SetCurrentOperation(Operation: String);
  private
    Controls: TComponentList;
  end;

implementation

uses
  Languages, Main;


constructor TProgressStatus.Create;
begin
  inherited;

  Controls := nil;
end;


procedure TProgressStatus.SetupControls(Form: TForm);
var
  ProgressBar: TProgressBar;
  StatusLabel: TLabel;
begin
  // Initialize the controls list if needed
  if not(Assigned(Controls)) then Controls := TComponentList.Create;

  // If there is no controls in the list (it might have been cleared before)
  if Controls.Count = 0 then
    begin
      with TfWindow(Form) do
        begin
          Height := Height + 32;
          bProcess.Top := bProcess.Top - 32;
          bgLanguage.Top := bgLanguage.Top - 32;
        end;

      ProgressBar := TProgressBar.Create(Form);
      with ProgressBar do
        begin
          Parent := Form;
          Width := Form.ClientWidth - 16;
          Height := 24;
          Left := 8;
          Top := Form.ClientHeight - 32;
          State := pbsNormal;
          Style := pbstNormal;
          Max := 100;
        end;
      Controls.Add(ProgressBar);

      StatusLabel := TLabel.Create(Form);
      with StatusLabel do
        begin
          Parent := ProgressBar;
          Caption := '';
          AutoSize := true;
          Left := 8;
          Top := 4;
        end;
      Controls.Add(StatusLabel);
    end;
end;


procedure TProgressStatus.RemoveControls(Form: TForm);
begin
  Controls.Clear;

  with TfWindow(Form) do
    begin
      Height := Height - 32;
      bProcess.Top := bProcess.Top + 32;
      bgLanguage.Top := bgLanguage.Top + 32;
    end;
end;


procedure TProgressStatus.SetNormal(PMax: Int64);
begin
  with TProgressBar(Controls.First) do
    begin
      State := pbsNormal;
      Style := pbstNormal;
      Max := PMax;
      Position := 0;
    end;
end;


procedure TProgressStatus.SetProgress(Progress: Integer);
begin
  TProgressBar(Controls.First).Position := Progress;
end;


procedure TProgressStatus.SetWaiting;
begin
  TProgressBar(Controls.First).Style := pbstMarquee;
end;


procedure TProgressStatus.SetError;
begin
  with TProgressBar(Controls.First) do
    begin
      State := pbsError;
      Position := 100;
    end;
end;


procedure TProgressStatus.SetCurrentOperation(Operation: String);
begin
  TLabel(Controls.Last).Caption := Operation;
end;


end.
