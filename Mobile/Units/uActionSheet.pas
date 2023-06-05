unit uActionSheet;

interface

uses FMX.Layouts, FMX.Objects, FMX.Types, FMX.Forms, FMX.Graphics, FMX.Ani,
     FMX.StdCtrls, SysUtils;

type
  TExecutaClick = procedure(Sender: TObject) of Object;

  TActionSheet = class
  private
    rectFundo, rectMenu, rectCancelar: TRectangle;
    lyt: TLayout;
    ani : TFloatAnimation;
    lblTitulo, lblCanc, lblItem : TLabel;
    FTitleMenuText, FCancelMenuText, FTagString : string;
    lineBorder: TLine;
    alturaItems, FTitleFontSize, FCancelFontSize, FTag: integer;
    FCancelFontColor, FMenuColor, FTitleFontColor : Cardinal;
    FBackgroundOpacity : Double;
  public
    constructor Create(Frm: TForm);
    procedure ShowMenu();
    procedure ClickBackground(Sender: TObject);
    procedure HideMenu();
    procedure FinishFade(Sender: TObject);
    procedure AddItem(codItem: string; itemText: string;
                      ACallBack: TExecutaClick = nil;
                      fontTextColor: cardinal = $FF087AF7;
                      fontSize: integer = 17);
    property TitleMenuText: string read FTitleMenuText write FTitleMenuText;
    property TitleFontSize: integer read FTitleFontSize write FTitleFontSize;
    property TitleFontColor: Cardinal read FTitleFontColor write FTitleFontColor;
    property CancelMenuText: string read FCancelMenuText write FCancelMenuText;
    property CancelFontSize: integer read FCancelFontSize write FCancelFontSize;
    property CancelFontColor: Cardinal read FCancelFontColor write FCancelFontColor;
    property BackgroundOpacity: Double read FBackgroundOpacity write FBackgroundOpacity;
    property MenuColor: Cardinal read FMenuColor write FMenuColor;
    property Tag: Integer read FTag write FTag;
    property TagString: String read FTagString write FTagString;

end;


implementation

constructor TActionSheet.Create(Frm: TForm);
begin
    alturaItems := 0;
    FTitleMenuText := 'Escolha uma opção';
    FTitleFontSize := 15;
    FTitleFontColor := $FF8B8B8B;
    FCancelMenuText := 'Cancelar';
    FCancelFontSize := 17;
    FCancelFontColor := $FF087AF7;
    FBackgroundOpacity := 0.5;
    FMenuColor := $FFFFFFFF;

    // Cria rect de fundo transparente...
    rectFundo := TRectangle.Create(Frm);
    with rectFundo do
    begin
        Align := TAlignLayout.Contents;
        Fill.Kind := TBrushKind.Solid;
        Fill.Color := $FF000000;
        Opacity := 0;
        BringToFront;
        Visible := false;
        HitTest := true;
        OnClick := ClickBackground;
        Tag := 0; // Invisivel
    end;
    Frm.AddObject(rectFundo);


    // Cria animacao de fade do fundo...
    ani := TFloatAnimation.Create(rectFundo);
    ani.PropertyName := 'Opacity';
    ani.StartValue := 0;
    ani.StopValue := 0.5;
    ani.Inverse := false;
    ani.Duration := 0.2;
    rectFundo.AddObject(ani);


    // Layout que vai conter o menu...
    lyt := TLayout.Create(Frm);
    lyt.Align := TAlignLayout.Contents;
    lyt.BringToFront;
    Frm.AddObject(lyt);



    // Fundo do menu...
    rectMenu := TRectangle.Create(lyt);
    with rectMenu do
    begin
        Align := TAlignLayout.Bottom;
        Fill.Kind := TBrushKind.Solid;
        Fill.Color := FMenuColor;
        Opacity := 1;
        BringToFront;
        Visible := true;
        HitTest := true;
        XRadius := 10;
        YRadius := 10;
        Margins.Left := 10;
        Margins.Right := 10;
        Margins.Bottom := -900;
        Height := 200;
        Parent := lyt;
        Stroke.Kind := TBrushKind.None;
    end;
    lyt.AddObject(rectMenu);


    // Label com pergunta
    lblTitulo := TLabel.Create(rectMenu);
    with lblTitulo do
    begin
        Text := FTitleMenuText;
        Align := TAlignLayout.Top;
        Height := 0;
        VertTextAlign := TTextAlign.Center;
        TextAlign := TTextAlign.Center;
        StyledSettings := StyledSettings - [TStyledSetting.Size, TStyledSetting.FontColor];
        Font.Size := FTitleFontSize;
        FontColor := FTitleFontColor;
        Margins.Left := 15;
        Margins.Right := 15;
    end;
    rectMenu.AddObject(lblTitulo);


    // Fundo do cancelar...
    rectCancelar := TRectangle.Create(rectMenu);
    with rectCancelar do
    begin
        Align := TAlignLayout.Bottom;
        Fill.Kind := TBrushKind.Solid;
        Fill.Color := FMenuColor;
        Opacity := 1;
        BringToFront;
        Visible := true;
        HitTest := true;
        XRadius := 10;
        YRadius := 10;
        Margins.Bottom := -60;
        Height := 50;
        Parent := rectMenu;
        Stroke.Kind := TBrushKind.None;
    end;
    rectMenu.AddObject(rectCancelar);


    // Label cancelar
    lblCanc := TLabel.Create(rectCancelar);
    with lblCanc do
    begin
        Text := FCancelMenuText;
        Align := TAlignLayout.Client;
        VertTextAlign := TTextAlign.Center;
        TextAlign := TTextAlign.Center;
        StyledSettings := StyledSettings - [TStyledSetting.Size, TStyledSetting.FontColor];
        Font.Size := FCancelFontSize;
        FontColor := FCancelFontColor;
        HitTest := true;
        OnClick := ClickBackground;
    end;
    rectCancelar.AddObject(lblCanc);

end;

procedure TActionSheet.ClickBackground(Sender: TObject);
begin
    HideMenu;
end;

procedure TActionSheet.ShowMenu();
begin
    // Acerta o fundo opaco...
    rectFundo.Opacity := 0;
    rectFundo.Visible := true;
    rectFundo.Tag := 1;
    ani.Delay := 0;
    ani.StartValue := 0;
    ani.StopValue := FBackgroundOpacity;
    ani.Start;


    // Acerta item cancelar...
    lblCanc.Font.Size := FCancelFontSize;
    lblCanc.Text := FCancelMenuText;
    lblCanc.FontColor := FCancelFontColor;
    rectCancelar.Fill.Color := FMenuColor;


    // Acerta titulo do menu...
    if Trim(FTitleMenuText) = '' then
        lblTitulo.Height := 0
    else
        lblTitulo.Height := 40;

    lblTitulo.Font.Size := FTitleFontSize;
    lblTitulo.Text := FTitleMenuText;


    // Acerta menu...
    rectMenu.Fill.Color := FMenuColor;
    rectMenu.Height := lblTitulo.Height + alturaItems;
    rectMenu.Margins.Bottom := (rectMenu.Height + 100) * -1;
    rectMenu.Visible := true;
    TAnimator.AnimateFloat(rectMenu,
                          'Margins.Bottom', rectCancelar.Height + 20, 0.3,
                          TAnimationType.InOut,
                          TInterpolationType.Circular);
end;

procedure TActionSheet.AddItem(codItem: string; itemText: string;
                               ACallBack: TExecutaClick = nil;
                               fontTextColor: cardinal = $FF087AF7;
                               fontSize: integer = 17);
begin
    lineBorder := TLine.Create(rectMenu);
    with lineBorder do
    begin
        Stroke.Kind := TBrushKind.Solid;
        Stroke.Color := $FFCCCCCC;
        Opacity := 0.4;
        Height := 1;
        Align := TAlignLayout.Top;
    end;
    rectMenu.AddObject(lineBorder);


    lblItem := TLabel.Create(rectMenu);
    with lblItem do
    begin
        Text := itemText;
        Align := TAlignLayout.Top;
        Height := 55;
        VertTextAlign := TTextAlign.Center;
        TextAlign := TTextAlign.Center;
        StyledSettings := StyledSettings - [TStyledSetting.Size, TStyledSetting.FontColor];
        Font.Size := fontSize;
        FontColor := fontTextColor;
        HitTest := true;
        Margins.Left := 10;
        Margins.Right := 10;
        TagString := codItem;
        OnClick := ACallBack;
    end;
    rectMenu.AddObject(lblItem);

    alturaItems := alturaItems + Trunc(lblItem.Height + 1);
end;


procedure TActionSheet.FinishFade(Sender: TObject);
begin
    if rectFundo.Tag = 0 then
        rectFundo.Visible := false;
end;

procedure TActionSheet.HideMenu();
begin
  TAnimator.AnimateFloat(rectMenu,
                          'Margins.Bottom',
                          (rectMenu.Height + 100) * -1,
                          0.3,
                          TAnimationType.InOut,
                          TInterpolationType.Circular);

    rectFundo.Tag := 0;
    ani.Delay := 0.3;
    ani.Duration := 0.2;
    ani.StartValue := 0.5;
    ani.StopValue := 0;
    //ani.OnFinish := FinishFade;
    //ani.Start;
    rectFundo.Visible := false;
end;



end.
