unit Editor;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, Menus, ComCtrls, ClipBrd,
  ToolWin, ActnList, ImgList, StdActns, XPStyleActnCtrls, ActnMan,
  ActnCtrls, ExtActns, BandActn, IniFiles, AppEvnts;

type
  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    FileNewItem: TMenuItem;
    FileOpenItem: TMenuItem;
    FileSaveItem: TMenuItem;
    FileSaveAsItem: TMenuItem;
    FilePrintItem: TMenuItem;
    FileExitItem: TMenuItem;
    EditUndoItem: TMenuItem;
    EditCutItem: TMenuItem;
    EditCopyItem: TMenuItem;
    EditPasteItem: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    PrintDialog: TPrintDialog;
    FontDialog: TFontDialog;
    N5: TMenuItem;
    miEditFont: TMenuItem;
    Editor: TRichEdit;
    ToolbarImages: TImageList;
    ActionList1: TActionList;
    FileNewCmd: TAction;
    FileOpenCmd: TAction;
    FileSaveCmd: TAction;
    FilePrintCmd: TAction;
    FileExitCmd: TAction;
    EditCutCmd: TAction;
    EditCopyCmd: TAction;
    EditPasteCmd: TAction;
    EditUndoCmd: TAction;
    EditFontCmd: TAction;
    FileSaveAsCmd: TAction;
    SearchFind: TSearchFind;
    SearchFindNext: TSearchFindNext;
    SearchReplace: TSearchReplace;
    SearchFindFirst: TSearchFindFirst;
    Search: TMenuItem;
    Find1: TMenuItem;
    FindFirst1: TMenuItem;
    FindNext1: TMenuItem;
    Replace1: TMenuItem;
    ActionToolBar1: TActionToolBar;
    ActionManager1: TActionManager;
    RichEditBold1: TRichEditBold;
    RichEditItalic1: TRichEditItalic;
    RichEditUnderline1: TRichEditUnderline;
    RichEditStrikeOut1: TRichEditStrikeOut;
    RichEditBullets1: TRichEditBullets;
    RichEditAlignLeft1: TRichEditAlignLeft;
    RichEditAlignRight1: TRichEditAlignRight;
    RichEditAlignCenter1: TRichEditAlignCenter;
    Format1: TMenuItem;
    Bold1: TMenuItem;
    Bullets1: TMenuItem;
    Italic1: TMenuItem;
    Strikeout1: TMenuItem;
    Underline1: TMenuItem;
    N3: TMenuItem;
    Center1: TMenuItem;
    AlignLeft1: TMenuItem;
    AlignRight1: TMenuItem;
    CustomizeActionBars1: TCustomizeActionBars;
    ools1: TMenuItem;
    Customize1: TMenuItem;
    EditSelectAllCmd: TEditSelectAll;
    SelectAll1: TMenuItem;
    FullScreen: TAction;
    ApplicationEvents1: TApplicationEvents;
    EditCopy1: TEditCopy;
    procedure FormCreate(Sender: TObject);
    procedure FileNew(Sender: TObject);
    procedure FileOpen(Sender: TObject);
    procedure FileSave(Sender: TObject);
    procedure FileSaveAs(Sender: TObject);
    procedure FilePrint(Sender: TObject);
    procedure FileExit(Sender: TObject);
    procedure EditUndo(Sender: TObject);
    procedure EditCut(Sender: TObject);
    procedure EditCopy(Sender: TObject);
    procedure EditPaste(Sender: TObject);
    procedure SelectFont(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ActionList2Update(Action: TBasicAction;
      var Handled: Boolean);
    procedure SearchFindFindDialogFind(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FullScreenExecute(Sender: TObject);

     
    procedure ApplicationEvents1Minimize(Sender: TObject);
    procedure ApplicationEvents1Restore(Sender: TObject);
  private
    FFileName: string;
    FUpdating: Boolean;
    function CurrText: TTextAttributes;
    procedure SetFileName(const FileName: String);
    procedure CheckFileSave;
    procedure PerformFileOpen(const AFileName: string);
    procedure SetModified(Value: Boolean);
  end;

var
  MainForm: TMainForm;
  IniFile: TIniFile;
  MinFlag: Boolean;
  Flag:boolean;

implementation

uses RichEdit;

const
  sSaveChanges = 'Do you want to save changes to %s?';
  sOverWrite = 'Do you want to overwrite %s';
  sUntitled = 'Безымянный';
  sModified = 'Modified';

{$R *.dfm}

function TMainForm.CurrText: TTextAttributes;
begin
  if Editor.SelLength > 0 then Result := Editor.SelAttributes
  else Result := Editor.DefAttributes;
end;

procedure TMainForm.SetFileName(const FileName: String);
begin
  FFileName := FileName;
  Caption := Format('%s - %s', [ExtractFileName(FileName), Application.Title]);
  SaveDialog.FileName:= FileName;
end;

procedure TMainForm.CheckFileSave;
var
  SaveResp: Integer;
begin
  if not Editor.Modified then Exit;
  SaveResp := MessageDlg(Format(sSaveChanges, [FFileName]),
    mtConfirmation, mbYesNoCancel, 0);
  case SaveResp of
    idYes: FileSave(Self);
    idNo:;
    idCancel: Abort;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var Status: Integer;
begin
  OpenDialog.InitialDir := ExtractFilePath(ParamStr(0));
  SaveDialog.InitialDir := OpenDialog.InitialDir;
  SetFileName(sUntitled);

  IniFile := TIniFile.Create ( ChangeFileExt ( Application.ExeName, '.ini' ) );
  Status := IniFile.ReadInteger ('MainFrame', 'Status', 0);

  if Status <> 0 then
    begin
      Top := IniFile.ReadInteger ('MainFrame', 'Top', Top);
      Left := IniFile.ReadInteger ('MainFrame', 'Left', Left);
      Width := IniFile.ReadInteger ('MainFrame', 'Width', Width);
      Height := IniFile.ReadInteger ('MainFrame', 'Height', Height);
      case Status of
        2: WindowState := wsMinimized;
        3: WindowState := wsMaximized;
      end;
    end;
end;

procedure TMainForm.FileNew(Sender: TObject);
begin
  CheckFileSave;
  SetFileName(sUntitled);
  Editor.Lines.Clear;
  Editor.Modified := False;
  SetModified(False);
end;

procedure TMainForm.PerformFileOpen(const AFileName: string);
begin
  Editor.Lines.LoadFromFile(AFileName);
  SetFileName(AFileName);
  Editor.SetFocus;
  Editor.Modified := False;
  SetModified(False);
end;

procedure TMainForm.FileOpen(Sender: TObject);
begin
  CheckFileSave;
  if OpenDialog.Execute then
  begin
    PerformFileOpen(OpenDialog.FileName);
    Editor.ReadOnly := ofReadOnly in OpenDialog.Options;
  end;
end;

procedure TMainForm.FileSave(Sender: TObject);
begin
  if FFileName = sUntitled then
    FileSaveAs(Sender)
  else
  begin
    Editor.Lines.SaveToFile(FFileName);
    Editor.Modified := False;
    SetModified(False);
  end;
end;

procedure TMainForm.FileSaveAs(Sender: TObject);
begin
  if SaveDialog.Execute then
  begin
    if FileExists(SaveDialog.FileName) then
      if MessageDlg(Format(sOverWrite, [SaveDialog.FileName]),
        mtConfirmation, mbYesNoCancel, 0) <> idYes then Exit;
    Editor.Lines.SaveToFile(SaveDialog.FileName);
    SetFileName(SaveDialog.FileName);
    Editor.Modified := False;
    SetModified(False);
  end;
end;

procedure TMainForm.FilePrint(Sender: TObject);
begin
  if PrintDialog.Execute then
    Editor.Print(FFileName);
end;

procedure TMainForm.FileExit(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.EditUndo(Sender: TObject);
begin
  with Editor do
    if HandleAllocated then SendMessage(Handle, EM_UNDO, 0, 0);
end;

procedure TMainForm.EditCut(Sender: TObject);
begin
  Editor.CutToClipboard;
end;

procedure TMainForm.EditCopy(Sender: TObject);
begin
  Editor.CopyToClipboard;
end;

procedure TMainForm.EditPaste(Sender: TObject);
begin
  Editor.PasteFromClipboard;
end;

procedure TMainForm.SelectFont(Sender: TObject);
begin
  FontDialog.Font.Assign(Editor.SelAttributes);
  if FontDialog.Execute then
    CurrText.Assign(FontDialog.Font);
  Editor.SetFocus;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  try
    CheckFileSave;
  except
    CanClose := False;
  end;
end;

procedure TMainForm.SetModified(Value: Boolean);
begin

end;

procedure TMainForm.ActionList2Update(Action: TBasicAction;
  var Handled: Boolean);
begin
  EditCutCmd.Enabled := Editor.SelLength > 0;
  EditCopyCmd.Enabled := EditCutCmd.Enabled;
  if Editor.HandleAllocated then
  begin
    EditUndoCmd.Enabled := Editor.Perform(EM_CANUNDO, 0, 0) <> 0;
    EditPasteCmd.Enabled := Editor.Perform(EM_CANPASTE, 0, 0) <> 0;
  end;
end;

procedure TMainForm.SearchFindFindDialogFind(Sender: TObject);
var
  FoundAt: LongInt;
  StartPos, ToEnd: Integer;
begin
  with Editor do
  begin
    if SelLength <> 0 then
      StartPos := SelStart + SelLength
    else
      StartPos := 0;
    ToEnd := Length(Text) - StartPos;
    FoundAt := FindText(SearchFind.Dialog.FindText, StartPos, ToEnd, [stMatchCase]);
    if FoundAt <> -1 then
    begin
      SetFocus;
      SelStart := FoundAt;
      SelLength := Length(SearchFind.Dialog.FindText);
    end;
  end;
end;


procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var Status: Integer;
begin
    case WindowState of
      wsNormal:
        begin
          IniFile.WriteInteger ('MainFrame', 'Top', Top);
          IniFile.WriteInteger ('MainFrame', 'Left', Left);
          IniFile.WriteInteger ('MainFrame', 'Width', Width);
          IniFile.WriteInteger ('MainFrame', 'Height', Height);
          Status := 1;
        end;
      wsMinimized: Status := 2;
      wsMaximized: Status := 3;
    end;
    if Flag then Status := 2;
    IniFile.WriteInteger ('MainFrame', 'Status', Status );
end;

procedure TMainForm.FullScreenExecute(Sender: TObject);
var tempTop, tempLeft, tempWidth, tempHeight:integer;
begin
 if not FullScreen.Checked then
 begin
  tempTop := MainForm.Top;
  tempLeft := MainForm.Left;
  tempWidth:= MainForm.Width;
  tempHeight := MainForm.Height;

  MainForm.BorderIcons:=[];
  MainForm.BorderStyle:=bsNone;
  MainForm.ClientHeight:=Screen.Height;
  MainForm.ClientWidth:=Screen.Width;
  MainForm.Left:=0;
  MainForm.Top:=0;
  FullScreen.Checked:=true;
 end
 else
  begin
    MainForm.BorderIcons:=[biSystemMenu,biMinimize,biMaximize];
    MainForm.BorderStyle:=bsSizeable;
    Top := IniFile.ReadInteger ('MainFrame', 'Top', Top);
    Left := IniFile.ReadInteger ('MainFrame', 'Left', Left);
    ClientWidth := IniFile.ReadInteger ('MainFrame', 'Width', Width);
    ClientHeight := IniFile.ReadInteger ('MainFrame', 'Height', Height);
    FullScreen.Checked:=false;
   end;
end;



procedure TMainForm.ApplicationEvents1Minimize(Sender: TObject);
begin
flag:=true;
end;

procedure TMainForm.ApplicationEvents1Restore(Sender: TObject);
begin
flag:=false;
end;

end.
