unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.TabControl,
  FMX.ListBox, FMX.ListView.Types, FMX.ListView.Appearances, System.StrUtils,
  FMX.ListView.Adapters.Base, FMX.ListView, uLoading, uSession, uSuperChartLight,
  System.JSON, uActionSheet, DateUtils, FMX.DialogService, FMX.Effects;

type
  TFrmPrincipal = class(TForm)
    rectAbas: TRectangle;
    lytAba1: TLayout;
    Label1: TLabel;
    Image1: TImage;
    lytAba3: TLayout;
    Label3: TLabel;
    Image3: TImage;
    lytAba4: TLayout;
    Label4: TLabel;
    Image4: TImage;
    TabControl: TTabControl;
    TabItem1: TTabItem;
    TabItem3: TTabItem;
    TabItem4: TTabItem;
    rectToolbar1: TRectangle;
    Label5: TLabel;
    imgRefreshDashboard: TImage;
    btnRefreshDashboard: TSpeedButton;
    rectToolbar3: TRectangle;
    Label7: TLabel;
    Rectangle1: TRectangle;
    Label8: TLabel;
    rectFundoAba1: TRectangle;
    Rectangle2: TRectangle;
    Layout1: TLayout;
    Layout2: TLayout;
    Image6: TImage;
    Label9: TLabel;
    lblDash1Valor: TLabel;
    lblDash1Qtd: TLabel;
    Rectangle4: TRectangle;
    lytGrafico: TLayout;
    Label15: TLabel;
    imgContato: TImage;
    rectAbaStatus: TRectangle;
    lblProdutos: TLabel;
    lblCarrinho: TLabel;
    rectBotaoSelecionado: TRectangle;
    imgFinalizado: TImage;
    imgData: TImage;
    lbxConfiguracoes: TListBox;
    ListBoxItem1: TListBoxItem;
    Image8: TImage;
    Label10: TLabel;
    Line1: TLine;
    ListBoxItem2: TListBoxItem;
    Image9: TImage;
    Label11: TLabel;
    Line2: TLine;
    ListBoxItem3: TListBoxItem;
    Image10: TImage;
    Label13: TLabel;
    Line3: TLine;
    lbProdutos: TListBox;
    TabControlMercadinho: TTabControl;
    TabProdutos: TTabItem;
    TabCarrinho: TTabItem;
    LayContador: TLayout;
    Circle2: TCircle;
    ShadowEffect2: TShadowEffect;
    Label2: TLabel;
    procedure lytAba1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnRefreshDashboardClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lblCarrinhoClick(Sender: TObject);
    procedure lvTarefasItemClick(const Sender: TObject; const AItem: TListViewItem);
    procedure lblProdutosClick(Sender: TObject);
  private
    menu_tarefa: TActionSheet;

    procedure MudarAba(lyt: TLayout);
    procedure MontarDashboard;
    procedure DashboardTerminate(Sender: TObject);
    procedure MontarGrafico(json_array: TJsonArray);
    procedure SelecionarBotaoMercadinho(lbl: TLabel; Aba: TTabItem);
    procedure AddProduto(Codigo: integer; Desricao, Classificacao: string; Preco: double);
    procedure ListarProdutos;
    procedure ProdutosTerminate(Sender: TObject);
    procedure InicializarAbaProdutos;
    procedure btnAddClick(Sender: TObject);
  public
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.fmx}

uses
  DataModule.Global, Frame.Produto, UnitNegocioCad, UnitTarefaCad;

// Formato: 2021-10-09T14:11:28.877Z  -->  Date
function StringUTCToDate(str: string): TDate;
var
  ano, mes, dia, hora, minuto, seg: integer;
begin
  try
    ano := Copy(str, 1, 4).ToInteger;
    mes := Copy(str, 6, 2).ToInteger;
    dia := Copy(str, 9, 2).ToInteger;
    hora := Copy(str, 12, 2).ToInteger;
    minuto := Copy(str, 15, 2).ToInteger;
    seg := Copy(str, 18, 2).ToInteger;

    Result := EncodeDateTime(ano, mes, dia, hora, minuto, seg, 0);
  except
    Result := 0;
  end;
end;

procedure TFrmPrincipal.DashboardTerminate(Sender: TObject);
begin
  TLoading.Hide;

  // Verifica se deu erro na thread...
  if Sender is TThread then
    if Assigned(TThread(Sender).FatalException) then
    begin
      showmessage(Exception(TThread(Sender).FatalException).Message);
      exit;
    end;
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  // Obtido na tela de login...
  TSession.ID_USUARIO := 1;
  // ---------------------------

  // Menu tarefas...
  menu_tarefa := TActionSheet.Create(FrmPrincipal);
  // menu_tarefa.TitleFontSize := 12;
  // menu_tarefa.TitleMenuText := 'Mercadinho';
  // menu_tarefa.TitleFontColor := $FFA3A3A3;
  //
  // menu_tarefa.CancelMenuText := 'Cancelar';
  // menu_tarefa.CancelFontSize := 15;
  // menu_tarefa.CancelFontColor := $FF4162FF;
  //
  // menu_tarefa.BackgroundOpacity := 0.5;
  // menu_tarefa.MenuColor := $FFFFFFFF;

  // menu_tarefa.AddItem('', 'Excluir', ClickTarefaExcluir, $FFDA4F3F, 15);
  // menu_tarefa.AddItem('', 'Tarefa Não Finalizada', ClickTarefaNaoFinalizada, $FF4162FF, 15);
  // menu_tarefa.AddItem('', 'Tarefa Finalizada', ClickTarefaFinalizada, $FF4162FF, 15);
  MudarAba(lytAba1);
end;

procedure TFrmPrincipal.FormDestroy(Sender: TObject);
begin
  menu_tarefa.DisposeOf;
end;

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
  MontarDashboard;
end;

procedure TFrmPrincipal.SelecionarBotaoMercadinho(lbl: TLabel; Aba: TTabItem);
begin
  rectBotaoSelecionado.width := lbl.width;
  rectBotaoSelecionado.position.x := lbl.position.x;
  TabControlMercadinho.ActiveTab := Aba;
end;

procedure TFrmPrincipal.lblCarrinhoClick(Sender: TObject);
begin
  SelecionarBotaoMercadinho(TLabel(Sender), TabCarrinho);
end;

procedure TFrmPrincipal.lblProdutosClick(Sender: TObject);
begin
  SelecionarBotaoMercadinho(lblProdutos, TabProdutos);
end;

procedure TFrmPrincipal.InicializarAbaProdutos;
begin
  SelecionarBotaoMercadinho(lblProdutos, TabProdutos);
  ListarProdutos;
end;

procedure TFrmPrincipal.ProdutosTerminate(Sender: TObject);
begin
  lbProdutos.EndUpdate;
  TLoading.Hide;

  // Verifica se deu erro na thread...
  if Sender is TThread then
    if Assigned(TThread(Sender).FatalException) then
    begin
      showmessage(Exception(TThread(Sender).FatalException).Message);
      exit;
    end;
end;

procedure TFrmPrincipal.ListarProdutos;
var
  t: TThread;
begin
  TLoading.Show(FrmPrincipal, '');

  lbProdutos.BeginUpdate;
  lbProdutos.Items.Clear;

  t := TThread.CreateAnonymousThread(
    procedure
    begin
      DmGlobal.ListarProdutos(TSession.ID_USUARIO);

      TThread.Synchronize(TThread.CurrentThread,
        procedure
        begin
          while not DmGlobal.TabProdutos.eof do
          begin
            AddProduto(DmGlobal.TabProdutos.fieldbyname('id_produto').AsInteger, DmGlobal.TabProdutos.fieldbyname('descricao').asstring, DmGlobal.TabProdutos.fieldbyname('classificacao').asstring, DmGlobal.TabProdutos.fieldbyname('preco').AsFloat);

            DmGlobal.TabProdutos.Next;
          end;
        end);
    end);

  t.OnTerminate := ProdutosTerminate;
  t.Start;
end;

procedure TFrmPrincipal.btnAddClick(Sender: TObject);
begin

end;

procedure TFrmPrincipal.AddProduto(Codigo: integer; Desricao, Classificacao: string; Preco: double);
var
  f: TFrameProduto;
  Item: TListBoxItem;
begin
  Item := TListBoxItem.Create(lbProdutos);
  Item.Selectable := false;
  Item.Text := '';
  Item.Height := 160;
//  Item.Tag := Codigo;
  Item.HitTest := False;

  f := TFrameProduto.Create(Item);
  f.lblPreco.Text := FormatFloat('R$ #,##0.00', Preco);
  f.lblNome.Text := Desricao;
  f.lblClassificacao.Text := Classificacao;
  f.btnAdd.Tag := Codigo;
  f.btnAdd.OnClick := btnAddClick;

  Item.AddObject(f);

  lbProdutos.AddObject(Item);
end;

procedure TFrmPrincipal.MontarGrafico(json_array: TJsonArray);
var
  chart: TSuperChart;
  erro: string;
begin
  chart := TSuperChart.Create(lytGrafico, Lines);
  try    // Valores...
    chart.ShowValues := true;
    chart.FontSizeValues := 10;
    chart.FontColorValues := $FFFFFFFF;
    chart.FormatValues := '#,##0.00';

    // Linhas...
    chart.LineColor := $FF5467FB;
    chart.FontColorValues := $FF5467FB;

    // Argumentos...
    chart.FontSizeArgument := 8;
    chart.FontColorArgument := $FF656565;

    // Render grafico...
    chart.LoadFromJSON(json_array.ToJSON, erro);

    if not erro.IsEmpty then
      showmessage(erro);
  finally
    chart.DisposeOf;
  end;
end;

procedure TFrmPrincipal.MontarDashboard;
var
  t: TThread;
  json_array: TJsonArray;
begin
  lblDash1Valor.Text := '---';
  lblDash1Qtd.Text := '---';
  // lblDash2Valor.Text := '---';
  // lblDash2Qtd.Text := '---';

  TLoading.Show(FrmPrincipal, '');

  t := TThread.CreateAnonymousThread(
    procedure
    begin
      DmGlobal.DashboardResumos(TSession.ID_USUARIO);
      json_array := DmGlobal.DashboardAnual(TSession.ID_USUARIO);

      TThread.Synchronize(TThread.CurrentThread,
        procedure
        begin
          lblDash1Valor.Text := FormatFloat('R$#,##0.00', DmGlobal.TabDashboard.fieldbyname('valormes').AsFloat);
          lblDash1Qtd.Text := FormatFloat('(#,## negócios)', DmGlobal.TabDashboard.fieldbyname('qtdmes').AsFloat);

          // Montar grafico...
          MontarGrafico(json_array);
        end);

    end);

  t.OnTerminate := DashboardTerminate;
  t.Start;
end;

procedure TFrmPrincipal.btnRefreshDashboardClick(Sender: TObject);
begin
  MontarDashboard;
end;

procedure TFrmPrincipal.MudarAba(lyt: TLayout);
begin
  lytAba1.Opacity := 0.5;
  lytAba3.Opacity := 0.5;
  lytAba4.Opacity := 0.5;

  lyt.Opacity := 1;

  TabControl.GotoVisibleTab(lyt.Tag);

  if lyt.Tag = 1 then // Aba Mercadinho
    InicializarAbaProdutos;
end;


procedure TFrmPrincipal.lvTarefasItemClick(const Sender: TObject; const AItem: TListViewItem);
begin
  menu_tarefa.Tag := AItem.Index;
  menu_tarefa.TagString := AItem.TagString; // id_tarefa
  menu_tarefa.ShowMenu;
end;

procedure TFrmPrincipal.lytAba1Click(Sender: TObject);
begin
  MudarAba(TLayout(Sender));
end;

end.

