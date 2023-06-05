unit Frame.Produto;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.Effects, FMX.Layouts;

type
  TFrameProduto = class(TFrame)
    lblPreco: TLabel;
    lblNome: TLabel;
    lblClassificacao: TLabel;
    Rectangle1: TRectangle;
    Image1: TImage;
    btnAdd: TCircle;
    Image2: TImage;
    Rectangle2: TRectangle;
    ShadowEffect1: TShadowEffect;
    procedure Image2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

procedure TFrameProduto.Image2Click(Sender: TObject);
begin
  ShowMessage('produto adicionado')
end;

end.
