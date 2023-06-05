unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs;

type
  TFrmPrincipal = class(TForm)
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.fmx}

uses Horse,
     Horse.GBSwagger,
     Horse.Jhonson,
     Horse.BasicAuthentication,
     Horse.CORS,
     Controllers.Global;


procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
    THorse.Use(HorseSwagger);
    THorse.Use(Jhonson);
    THorse.Use(CORS);

//    THorse.Use(
//      HorseBasicAuthentication(
//      function(const AUsername, APassword: string): Boolean
//      begin
//          Result := AUsername.Equals('user') and APassword.Equals('123');
//      end)
//    );

    // Registro rotas..
    Controllers.Global.RegistrarRotas;

    THorse.Listen(9000);

    {
    THorse.Listen(3000, procedure(Horse: THorse)
    begin

    end);
    }
end;

end.
