unit UnitTarefaCad;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.TabControl, FMX.ListBox,
  FMX.Layouts, FMX.Edit, FMX.DateTimeCtrls, uLoading;

type
  TFrmTarefaCad = class(TForm)
    rectToolbar2: TRectangle;
    Label6: TLabel;
    Image5: TImage;
    btnSalvar: TSpeedButton;
    Image1: TImage;
    btnVoltar: TSpeedButton;
    TabControl: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    lbTarefa: TListBox;
    ListBoxItem1: TListBoxItem;
    Image2: TImage;
    Label9: TLabel;
    ListBoxItem2: TListBoxItem;
    Image3: TImage;
    Label1: TLabel;
    ListBoxItem3: TListBoxItem;
    Image4: TImage;
    Label2: TLabel;
    ListBoxItem4: TListBoxItem;
    Image6: TImage;
    Label3: TLabel;
    ListBoxItem5: TListBoxItem;
    Image7: TImage;
    Label4: TLabel;
    Line1: TLine;
    Line2: TLine;
    Line3: TLine;
    Line4: TLine;
    Line5: TLine;
    cmbTarefa: TComboBox;
    edtDescricao: TEdit;
    edtData: TDateEdit;
    EdtHora: TTimeEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSalvarClick(Sender: TObject);
    procedure lbTarefaItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure btnVoltarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    Fid_negocio: integer;
    procedure TarefaTerminate(Sender: TObject);
    { Private declarations }
  public
    property id_negocio: integer read Fid_negocio write Fid_negocio;
  end;

var
  FrmTarefaCad: TFrmTarefaCad;

implementation

{$R *.fmx}

uses DataModule.Global;

procedure TFrmTarefaCad.TarefaTerminate(Sender: TObject);
begin
    TLoading.Hide;

    // Verifica se deu erro na thread...
    if Sender is TThread then
        if Assigned(TThread(Sender).FatalException) then
        begin
            showmessage(Exception(TThread(sender).FatalException).Message);
            exit;
        end;

    close;
end;

procedure TFrmTarefaCad.btnSalvarClick(Sender: TObject);
var
    t: TThread;
begin
    TLoading.Show(FrmTarefaCad, '');

    t := TThread.CreateAnonymousThread(procedure
    begin
        //sleep(1500);

        // Enviar os dados do negocios p/ server...
        DmGlobal.CadastrarTarefa(id_negocio,
                                 cmbTarefa.Selected.Text,
                                 edtDescricao.Text,
                                 FormatDateTime('yyyy-mm-dd', edtData.Date),
                                 EdtHora.Text);
    end);

    t.OnTerminate := TarefaTerminate;
    t.Start;
end;

procedure TFrmTarefaCad.btnVoltarClick(Sender: TObject);
begin
    if TabControl.TabIndex > 0 then
        TabControl.GotoVisibleTab(0)
    else
        close;
end;

procedure TFrmTarefaCad.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := TCloseAction.caFree;
    FrmTarefaCad := nil;
end;

procedure TFrmTarefaCad.FormCreate(Sender: TObject);
begin
    TabControl.ActiveTab := TabItem1;
end;

procedure TFrmTarefaCad.lbTarefaItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
    cmbTarefa.ItemIndex := Item.Index;
    TabControl.GotoVisibleTab(1);
end;

end.
