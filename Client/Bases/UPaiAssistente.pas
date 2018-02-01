unit UPaiAssistente;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UPai, ComCtrls, ActnList;

type
  TFPaiAssistente = class(TFPai)
    StatusBar1: TStatusBar;
    PageControl1: TPageControl;
    ActionList1: TActionList;
    actVoltar: TAction;
    actAvancar: TAction;
    actCancelar: TAction;
    actConfirmar: TAction;
    procedure actVoltarExecute(Sender: TObject);
    procedure actVoltarUpdate(Sender: TObject);
    procedure actAvancarExecute(Sender: TObject);
    procedure actAvancarUpdate(Sender: TObject);
    procedure actCancelarExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure actConfirmarUpdate(Sender: TObject);
    procedure actCancelarUpdate(Sender: TObject);
  private
    fPodeAvancar: Boolean;
    fPodeCancelar: Boolean;
    fPodeConfirmar: Boolean;
    fPodeVoltar: Boolean;
  protected
    property PodeAvancar: Boolean read fPodeAvancar write fPodeAvancar;
    property PodeVoltar: Boolean read fPodeVoltar write fPodeVoltar;
    property PodeCancelar: Boolean read fPodeCancelar write fPodeCancelar;
    property PodeConfirmar: Boolean read fPodeConfirmar write fPodeConfirmar;
  public
    { Public declarations }
  end;

var
  FPaiAssistente: TFPaiAssistente;

implementation

{$R *.dfm}

procedure TFPaiAssistente.actAvancarExecute(Sender: TObject);
begin
  inherited;
  if PageControl1.ActivePageIndex < PageControl1.PageCount - 1 then
    PageControl1.ActivePageIndex := PageControl1.ActivePageIndex + 1;
end;

procedure TFPaiAssistente.actAvancarUpdate(Sender: TObject);
begin
  inherited;
  actAvancar.Enabled := (PageControl1.ActivePageIndex < PageControl1.PageCount - 1) and fPodeAvancar;
end;

procedure TFPaiAssistente.actCancelarExecute(Sender: TObject);
begin
  inherited;
  Close;
end;

procedure TFPaiAssistente.actCancelarUpdate(Sender: TObject);
begin
  inherited;
  actCancelar.Enabled := fPodeCancelar;
end;

procedure TFPaiAssistente.actConfirmarUpdate(Sender: TObject);
begin
  inherited;
  actConfirmar.Enabled := (PageControl1.ActivePageIndex = (PageControl1.PageCount - 1)) and fPodeConfirmar;
end;

procedure TFPaiAssistente.actVoltarExecute(Sender: TObject);
begin
  inherited;
  if PageControl1.ActivePageIndex > 0 then
    PageControl1.ActivePageIndex := PageControl1.ActivePageIndex - 1;
end;

procedure TFPaiAssistente.actVoltarUpdate(Sender: TObject);
begin
  inherited;
  actVoltar.Enabled := (PageControl1.ActivePageIndex > 0) and fPodeVoltar;
end;

procedure TFPaiAssistente.FormCreate(Sender: TObject);
var
  i: integer;
begin
  PodeAvancar := true;
  PodeVoltar := true;
  PodeCancelar := true;
  PodeConfirmar := true;

  PageControl1.ActivePageIndex := 0;
  for i := 0 to PageControl1.PageCount - 1 do
    PageControl1.Pages[i].TabVisible := False;
  PageControl1.ActivePageIndex := 0;

  inherited;
end;

procedure TFPaiAssistente.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Shift = [] then
  begin
    case Key of
      VK_F2:
        begin
          actVoltar.Execute;
          Key := VK_CLEAR;
        end;
      VK_F3:
        begin
          actAvancar.Execute;
          Key := VK_CLEAR;
        end;
      VK_F6, VK_ESCAPE:
        begin
          actCancelar.Execute;
          Key := VK_CLEAR;
        end;
      VK_F5:
        begin
          actConfirmar.Execute;
          Key := VK_CLEAR;
        end;
    end;
  end;
  inherited;
end;

end.

