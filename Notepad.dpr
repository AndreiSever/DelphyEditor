program Notepad;

uses
  Forms,
  Editor in 'Editor.pas';

  {$R *.res}

begin
  Application.Initialize;
  Application.Title := '�������� ���������';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
