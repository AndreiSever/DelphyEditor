program Notepad;

uses
  Forms,
  Editor in 'Editor.pas';

  {$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Редактор Подкопаев';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
