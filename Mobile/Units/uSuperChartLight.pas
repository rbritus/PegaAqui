unit uSuperChartLight;

interface

uses FMX.Objects, FMX.Layouts, System.JSON, System.NetEncoding, System.SysUtils,
     FMX.Types, System.UITypes, FMX.Graphics, System.Classes, FMX.StdCtrls,
     Data.DB, System.Generics.Collections, System.Types;

type
    TPoints = Record
      pt: TPointF;
      vl: double;
      field: string;
end;

type
  TChartType = (Lines);

type
  TSuperChart = class
  private
    Bar, BarBackground: TRectangle;
    Line: TLine;
    LineCircle: TCircle;
    LabelValue, LabelArg: TLabel;
    BarCount: Integer;
    MaxValue: double;
    CountComp: integer;
    Pontos: TList<TPoints>;
    spaceBetweenPoints: Integer;

    FLayout: TLayout;
    FChartType: TChartType;
    FShowValues: Boolean;
    FFontSizeValues: Integer;
    FFontColorValues: Cardinal;
    FBarColor: Cardinal;
    FBackgroundColor: Cardinal;
    FShowBackground: Boolean;
    FFormatValues: String;
    FFontSizeArgument: Integer;
    FFontColorArgument: Cardinal;
    FRoundedBotton: Boolean;
    FRoundedTop: Boolean;
    FLineColor: Cardinal;

    procedure AddLine(vlFrom, vlTo: Double);
    procedure AddLinePoint(vl: double; field: string);
    function getLayoutHeight: Double;
  public
    constructor Create(Layout: TLayout; ChartType: TChartType);
    procedure LoadFromJSON(jsonString: string; var error: string);
    procedure ClearChart;
    property ShowValues: Boolean read FShowValues write FShowValues;
    property FontSizeValues: Integer read FFontSizeValues write FFontSizeValues;
    property FontColorValues: Cardinal read FFontColorValues write FFontColorValues;
    property BarColor: Cardinal read FBarColor write FBarColor;
    property ShowBackground: Boolean read FShowBackground write FShowBackground;
    property BackgroundColor: Cardinal read FBackgroundColor write FBackgroundColor;
    property FormatValues: String read FFormatValues write FFormatValues;
    property FontSizeArgument: Integer read FFontSizeArgument write FFontSizeArgument;
    property FontColorArgument: Cardinal read FFontColorArgument write FFontColorArgument;
    property RoundedBotton: Boolean read FRoundedBotton write FRoundedBotton;
    property RoundedTop: Boolean read FRoundedTop write FRoundedTop;

    property LineColor: Cardinal read FLineColor write FLineColor;
end;


implementation

constructor TSuperChart.Create(Layout: TLayout; ChartType: TChartType);
begin
    CountComp := 0;
    FLayout := Layout;
    FChartType := ChartType;


    // Default values...
    FShowValues := true;
    FFontSizeValues := 12;
    FFontColorValues := $FF424242;
    FBarColor := $FF2A8FF7;
    FShowBackground := false;
    FBackgroundColor := $FFF3F3F3;
    FFormatValues := '';
    FFontSizeArgument := 12;
    FFontColorArgument := $FF424242;
    FRoundedBotton := false;
    FRoundedTop := false;

    FLineColor := $FF2A8FF7;


    ClearChart;
end;

procedure DrawLineBetweenPoints(L: TLine; p1, p2: TPointF);
begin
    L.LineType := TLineType.Diagonal;
    L.RotationCenter.X := 0.0;
    L.RotationCenter.Y := 0.0;

    if (p2.X >= p1.X) then
    begin
        // Line goes left to right, what about vertical?
        if (p2.Y > p1.Y) then begin
            // Case #1 - Line goes high to low, so NORMAL DIAGONAL
            L.RotationAngle := 0;
            L.Position.X := p1.X;
            L.Width := p2.X - p1.X;
            L.Position.Y := p1.Y;
            L.Height := p2.Y - p1.Y;
        end
        else
        begin
            // Case #2 - Line goes low to high, so REVERSE DIAGONAL
            // X and Y are now upper left corner and width and height reversed
            L.RotationAngle := -90;
            L.Position.X := p1.X;
            L.Width := p1.Y - p2.Y;
            L.Position.Y := p1.Y;
            L.Height := p2.X - p1.X;
        end;
    end
    else
    begin
        // Line goes right to left
        if (p1.Y > p2.Y) then
        begin
            // Case #3 - Line goes high to low (but reversed) so NORMAL DIAGONAL
            L.RotationAngle := 0;
            L.Position.X := p2.X;
            L.Width := p1.X - p2.X;
            L.Position.Y := p2.Y;
            L.Height := p1.Y - p2.Y;
        end
        else
        begin
            // Case #4 - Line goes low to high, REVERSE DIAGONAL
            // X and Y are now upper left corner and width and height reversed
            L.RotationAngle := -90;
            L.Position.X := p2.X;
            L.Width := p2.Y - p1.Y;
            L.Position.Y := p2.Y;
            L.Height := p1.X - p2.X;
        end;
    end;

    if (L.Height < 0.01) then
        L.Height := 0.1;
    if (L.Width < 0.01) then
        L.Width := 0.1;
end;

procedure TSuperChart.ClearChart;
var
    x : Integer;
begin
    // Destroy all componentes...
    for x := FLayout.ComponentCount - 1 downto 0 do
        FLayout.Components[x].DisposeOf;
end;

function TSuperChart.getLayoutHeight: Double;
const BASE_BOARD = 30;
begin
    Result := FLayout.Height - BASE_BOARD;
end;

procedure TSuperChart.AddLine(vlFrom, vlTo: Double);
var
    ptFrom, ptTo: TPointF;
begin
    // Calculate bar proportion...
    ptFrom.Y := (1 - (vlFrom / MaxValue)) * getLayoutHeight;
    ptFrom.X := CountComp * spaceBetweenPoints;

    ptTo.Y := (1 - (vlTo / MaxValue)) * getLayoutHeight;
    ptTo.X := (CountComp + 1) * spaceBetweenPoints;


    Line := TLine.Create(FLayout);
    Line.Parent := FLayout;
    Line.Stroke.Kind := TBrushKind.Solid;
    Line.Stroke.Color := FLineColor;
    Line.Stroke.Thickness := 2;
    Line.Opacity := 0;

    Line.AnimateFloatDelay('Opacity', 1, 0.3, (CountComp * 0.15) + 0.2,
                           TAnimationType.InOut,
                           TInterpolationType.Circular);


    DrawLineBetweenPoints(Line, ptFrom, ptTo);
    inc(CountComp);

end;

procedure TSuperChart.AddLinePoint(vl: double; field: string);
var
    porc : double;
begin
    // Calculate bar proportion...
    porc := (1 - (vl / MaxValue)) * getLayoutHeight;

    LineCircle := TCircle.Create(FLayout);
    LineCircle.Parent := FLayout;
    LineCircle.Stroke.Kind := TBrushKind.None;
    LineCircle.Fill.Kind := TBrushKind.Solid;
    LineCircle.Fill.Color := FLineColor;
    LineCircle.Width := 14;
    LineCircle.Height := 14;
    //LineCircle.Opacity := 0;

    LineCircle.Position.X := CountComp * spaceBetweenPoints - Trunc(LineCircle.Width / 2);
    //LineCircle.Position.Y := porc - Trunc(LineCircle.Width / 2);
    LineCircle.Position.Y := getLayoutHeight - 35;

    //LineCircle.AnimateFloatDelay('Opacity', 1, 0.3, (CountComp * 0.2) + 0.3);
    LineCircle.AnimateFloat('Position.Y', porc - Trunc(LineCircle.Width / 2), 0.5,
                            TAnimationType.InOut,
                            TInterpolationType.Circular);




    // Label values...
    LabelValue := TLabel.Create(LineCircle);
    LabelValue.Parent := LineCircle;

    if FFormatValues <> '' then
        LabelValue.Text := FormatFloat(FFormatValues, vl)
    else
        LabelValue.Text := vl.ToString;


    LabelValue.Align := TAlignLayout.Center;
    LabelValue.Margins.Bottom := 45;
    LabelValue.TextSettings.HorzAlign := TTextAlign.Center;


    LabelValue.StyledSettings := LabelValue.StyledSettings - [TStyledSetting.Size, TStyledSetting.FontColor];
    LabelValue.Font.Size := FFontSizeValues;
    LabelValue.FontColor := FFontColorValues;
    LabelValue.Visible := ShowValues;
    LabelValue.Name := 'lblSuperChatValues_' + CountComp.ToString;



    // Label Arguments...
    LabelArg := TLabel.Create(FLayout);
    LabelArg.Parent := FLayout;
    LabelArg.Text := field;

    LabelArg.Width := spaceBetweenPoints;
    LabelArg.Position.X := (CountComp * spaceBetweenPoints - Trunc(LineCircle.Width / 2)) - Trunc(spaceBetweenPoints / 2) + 7;
    LabelArg.Position.Y := FLayout.Height - 25;
    LabelArg.Margins.Bottom := -20;
    LabelArg.TextSettings.HorzAlign := TTextAlign.Center;

    LabelArg.StyledSettings := LabelArg.StyledSettings - [TStyledSetting.Size, TStyledSetting.FontColor];
    LabelArg.Font.Size := FFontSizeArgument;
    LabelArg.Height := 20;
    LabelArg.FontColor := FFontColorArgument;


    inc(CountComp);
end;

procedure TSuperChart.LoadFromJSON(jsonString: string; var error: string);
var
    jsonArray: TJsonArray;
    x : integer;
    p: TPoints;
begin
    error := '';
    ClearChart;

    try
        jsonArray := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(jsonString), 0) as TJSONArray;
    except
        error := 'Invalid JSON array';
        exit;
    end;


    if jsonArray = nil then
    begin
        error := 'Invalid JSON array';
        exit;
    end;


    BarCount := jsonArray.Size;
    MaxValue := 0;

    for x := jsonArray.Size - 1 downto 0 do
        if MaxValue < jsonArray.Get(x).GetValue<double>('valor') then
            MaxValue := jsonArray.Get(x).GetValue<double>('valor');

    MaxValue := MaxValue * 1.1;

    if (FChartType = Lines) then
    begin
        pontos := TList<TPoints>.Create;
        CountComp := 0;
        spaceBetweenPoints := Trunc(FLayout.Width / (BarCount - 1));

        for x := 0 to jsonArray.Size - 2 do
            AddLine(jsonArray.Get(x).GetValue<double>('valor'),
                    jsonArray.Get(x+1).GetValue<double>('valor'));


        CountComp := 0;
        for x := 0 to jsonArray.Size - 1 do
            AddLinePoint(jsonArray.Get(x).GetValue<double>('valor'),
                         jsonArray.Get(x).GetValue<string>('field'));

        pontos.DisposeOf;
    end;

    jsonArray.DisposeOf;
end;




end.
