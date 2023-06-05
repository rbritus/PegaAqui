unit DataModule.Global;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Phys.FB, FireDAC.Phys.FBDef,
  FireDAC.Phys.IBBase,

  DateUtils,
  DataSet.Serialize.Config,
  DataSet.Serialize,
  System.JSON,
  FireDAC.DApt;

type
  TDmGlobal = class(TDataModule)
    Conn: TFDConnection;
    FDPhysFBDriverLink: TFDPhysFBDriverLink;
    procedure DataModuleCreate(Sender: TObject);
    procedure ConnBeforeConnect(Sender: TObject);
  private
    procedure CarregarConfigDB(Connection: TFDConnection);

  public
    function DashboardResumos(id_usuario: integer): TJsonObject;
    function DashboardAnual(id_usuario: integer): TJsonArray;
    function ListarNegocios(id_usuario: integer; etapa: string): TJsonArray;
    function ListarNegociosResumo(id_usuario: integer): TJsonArray;
    function EditarNegocio(id_negocio: integer; etapa, descricao, empresa,
                          contato, fone, email: string; valor: double): TJsonObject;
    function ExcluirNegocio(id_negocio: integer): TJsonObject;
    function InserirNegocio(id_usuario: integer; etapa, descricao, empresa,
                          contato, fone, email: string; valor: double): TJsonObject;
    function ListarEtapas: TJsonArray;

    function ExcluirTarefa(id_tarefa: integer): TJsonObject;
    function InserirTarefa(id_negocio: integer; tarefa, descricao, dt_tarefa,
                           hora: string): TJsonObject;
    function ListarTarefas(id_usuario: integer;
                           ind_concluido: string): TJsonArray;
    function StatusTarefa(id_tarefa: integer;
                          ind_concluido: string): TJsonObject;
    function ListarNegocioId(id_negocio: integer): TJsonObject;
  end;

var
  DmGlobal: TDmGlobal;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDmGlobal.CarregarConfigDB(Connection: TFDConnection);
begin
    Connection.DriverName := 'FB';

    with Connection.Params do
    begin
        Clear;
        Add('DriverID=FB');
        Add('Database=c:\sua-pasta-aqui\BANCO.FDB');
        Add('User_Name=SYSDBA');
        Add('Password=masterkey');
        Add('Port=3050');
        Add('Protocol=TCPIP');
        Add('Server=127.0.0.1');
    end;

    FDPhysFBDriverLink.VendorLib := 'C:\Program Files (x86)\Firebird\Firebird_3_0\fbclient.dll';
end;

procedure TDmGlobal.ConnBeforeConnect(Sender: TObject);
begin
    CarregarConfigDB(Conn);
end;

procedure TDmGlobal.DataModuleCreate(Sender: TObject);
begin
    TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLower;
    TDataSetSerializeConfig.GetInstance.Import.DecimalSeparator := '.';

    Conn.Connected := true;
end;

function TDmGlobal.DashboardResumos(id_usuario: integer): TJsonObject;
var
    qry: TFDQuery;
    obj: TJSONObject;
begin
    if id_usuario <= 0 then
        raise Exception.Create('Informe o usuário');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        // Valores do mes...
        qry.Active := false;
        qry.SQL.Clear;
        qry.SQL.Add('select sum(valor) as valor_mes, count(*) as qtd_mes');
        qry.SQL.Add('from    tab_negocio');
        qry.SQL.Add('where   dt_cadastro >= :dt_de');
        qry.SQL.Add('and     dt_cadastro < :dt_ate');
        qry.SQL.Add('and     id_usuario = :id_usuario');

        qry.ParamByName('id_usuario').Value := id_usuario;
        qry.ParamByName('dt_de').Value := FormatDateTime('yyyy-mm-dd', StartOfTheMonth(date));
        qry.ParamByName('dt_ate').Value := FormatDateTime('yyyy-mm-dd', StartOfTheMonth(date).IncMonth(1));

        qry.Active := true;

        obj := qry.ToJSONObject; { "valor_mes": 7300, "qtd_mes": 2 }


        // Valores o dia...
        qry.Active := false;
        qry.SQL.Clear;
        qry.SQL.Add('select  sum(valor) as valor_dia, count(*) as qtd_dia');
        qry.SQL.Add('from    tab_negocio');
        qry.SQL.Add('where   dt_cadastro >= :dt_de');
        qry.SQL.Add('and     dt_cadastro < :dt_ate');
        qry.SQL.Add('and     id_usuario = :id_usuario');

        qry.ParamByName('id_usuario').Value := id_usuario;
        qry.ParamByName('dt_de').Value := FormatDateTime('yyyy-mm-dd', date);
        qry.ParamByName('dt_ate').Value := FormatDateTime('yyyy-mm-dd', date.IncDay(1));

        qry.Active := true;

        obj.AddPair('valor_dia', qry.FieldByName('valor_dia').AsFloat);
        obj.AddPair('qtd_dia', qry.FieldByName('qtd_dia').AsInteger);

        Result := obj;
    finally
        FreeAndNil(qry);
    end;
end;

function TDmGlobal.DashboardAnual(id_usuario: integer): TJsonArray;
var
    qry: TFDQuery;
begin
     if (id_usuario <= 0) then
        raise Exception.Create('Informe o usuário');

     try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;


        qry.Active := false;
        qry.SQL.Clear;
        qry.SQL.Add('select  extract(month from dt_cadastro) as field, sum(valor) as valor');
        qry.SQL.Add('from    tab_negocio');
        qry.SQL.Add('where   dt_cadastro >= :dt_de');
        qry.SQL.Add('and     id_usuario = :id_usuario');
        qry.SQL.Add('group by extract(month from dt_cadastro)');
        qry.SQL.Add('order by 1');

        qry.ParamByName('id_usuario').Value := id_usuario;
        qry.ParamByName('dt_de').Value := FormatDateTime('yyyy-mm-dd', StartOfTheMonth(date).IncMonth(-11));

        qry.Active := true;

        Result := qry.ToJSONArray;

     finally
        FreeAndNil(qry);
     end;
end;

function TDmGlobal.ListarNegocios(id_usuario: integer; etapa: string): TJsonArray;
var
    qry: TFDQuery;
begin
     if (id_usuario <= 0) then
        raise Exception.Create('Informe o usuário');

     try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        qry.Active := false;
        qry.SQL.Clear;
        qry.SQL.Add('select  *');
        qry.SQL.Add('from    tab_negocio');
        qry.SQL.Add('where   id_usuario = :id_usuario');

        if etapa <> '' then
        begin
            qry.SQL.Add('and etapa = :etapa');
            qry.ParamByName('etapa').Value := etapa;
        end;

        qry.ParamByName('id_usuario').Value := id_usuario;
        qry.Active := true;

        Result := qry.ToJSONArray;

     finally
        FreeAndNil(qry);
     end;
end;

function TDmGlobal.ListarNegocioId(id_negocio: integer): TJsonObject;
var
    qry: TFDQuery;
begin
     if (id_negocio <= 0) then
        raise Exception.Create('Informe o id. negócio');

     try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        qry.Active := false;
        qry.SQL.Clear;
        qry.SQL.Add('select  *');
        qry.SQL.Add('from    tab_negocio');
        qry.SQL.Add('where   id_negocio = :id_negocio');


        qry.ParamByName('id_negocio').Value := id_negocio;
        qry.Active := true;

        Result := qry.ToJsonObject;

     finally
        FreeAndNil(qry);
     end;
end;

function TDmGlobal.ListarNegociosResumo(id_usuario: integer): TJsonArray;
var
    qry: TFDQuery;
begin
     if (id_usuario <= 0) then
        raise Exception.Create('Informe o usuário');

     try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        qry.Active := false;
        qry.SQL.Clear;
        qry.SQL.Add('select  e.etapa, count(n.id_negocio) as qtd, coalesce(sum(n.valor), 0) as valor, e.ordem');
        qry.SQL.Add('from    tab_etapa e');
        qry.SQL.Add('left join tab_negocio n on (e.etapa = n.etapa and n.id_usuario = :id_usuario)');
        qry.SQL.Add('group by e.etapa, e.ordem');
        qry.SQL.Add('order by e.ordem');

        qry.ParamByName('id_usuario').Value := id_usuario;
        qry.Active := true;

        Result := qry.ToJSONArray;

     finally
        FreeAndNil(qry);
     end;
end;

function TDmGlobal.InserirNegocio(id_usuario: integer;
                                 etapa, descricao, empresa, contato, fone, email: string;
                                 valor: double): TJsonObject;
var
    qry: TFDQuery;
begin
     if (id_usuario <= 0) or (etapa = '') then
        raise Exception.Create('Informe o usuário e a etapa');

     try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        with qry do
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('insert into tab_negocio(id_usuario, etapa, descricao, empresa, contato, fone, email, valor, dt_cadastro)');
            SQL.Add('values(:id_usuario, :etapa, :descricao, :empresa, :contato, :fone, :email, :valor, current_timestamp)');
            SQL.Add('returning id_negocio');

            ParamByName('id_usuario').Value := id_usuario;
            ParamByName('etapa').Value := etapa;
            ParamByName('descricao').Value := descricao;
            ParamByName('empresa').Value := empresa;
            ParamByName('contato').Value := contato;
            ParamByName('fone').Value := fone;
            ParamByName('email').Value := email;
            ParamByName('valor').Value := valor;

            Active := true;
        end;

        Result := qry.ToJSONObject;

     finally
        FreeAndNil(qry);
     end;
end;

function TDmGlobal.EditarNegocio(id_negocio: integer;
                                 etapa, descricao, empresa, contato, fone, email: string;
                                 valor: double): TJsonObject;
var
    qry: TFDQuery;
begin
     if (id_negocio <= 0) or (etapa = '') then
        raise Exception.Create('Informe o id. negócio e a etapa');

     try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        with qry do
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('update tab_negocio set etapa=:etapa, descricao=:descricao, empresa=:empresa, ');
            SQL.Add('        contato=:contato, fone=:fone, email=:email, valor=:valor');
            SQL.Add('where id_negocio=:id_negocio');
            SQL.Add('returning id_negocio');

            ParamByName('id_negocio').Value := id_negocio;
            ParamByName('etapa').Value := etapa;
            ParamByName('descricao').Value := descricao;
            ParamByName('empresa').Value := empresa;
            ParamByName('contato').Value := contato;
            ParamByName('fone').Value := fone;
            ParamByName('email').Value := email;
            ParamByName('valor').Value := valor;

            Active := true;
        end;

        Result := qry.ToJSONObject;

     finally
        FreeAndNil(qry);
     end;
end;

function TDmGlobal.ExcluirNegocio(id_negocio: integer): TJsonObject;
var
    qry: TFDQuery;
begin
     if (id_negocio <= 0)then
        raise Exception.Create('Informe o id. negócio');

     try
        try
            qry := TFDQuery.Create(nil);
            qry.Connection := Conn;

            Conn.StartTransaction;

            with qry do
            begin
                Active := false;
                SQL.Clear;
                SQL.Add('delete from tab_negocio_tarefa where id_negocio=:id_negocio');
                ParamByName('id_negocio').Value := id_negocio;
                ExecSQL;

                Active := false;
                SQL.Clear;
                SQL.Add('delete from tab_negocio where id_negocio=:id_negocio');
                SQL.Add('returning id_negocio');
                ParamByName('id_negocio').Value := id_negocio;
                Active := true;
            end;

            Result := qry.ToJSONObject;

            Conn.Commit;

        except on ex:exception do
            begin
                Conn.Rollback;
                raise Exception.Create(ex.Message);
            end;
        end;

     finally
        FreeAndNil(qry);
     end;
end;

function TDmGlobal.ListarEtapas(): TJsonArray;
var
    qry: TFDQuery;
begin
     try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        qry.Active := false;
        qry.SQL.Clear;
        qry.SQL.Add('select  *');
        qry.SQL.Add('from    tab_etapa ');
        qry.SQL.Add('order by ordem');
        qry.Active := true;

        Result := qry.ToJSONArray;

     finally
        FreeAndNil(qry);
     end;
end;

function TDmGlobal.ListarTarefas(id_usuario: integer; ind_concluido: string): TJsonArray;
var
    qry: TFDQuery;
begin
     if (id_usuario <= 0) then
        raise Exception.Create('Informe o usuário');

     try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        qry.Active := false;
        qry.SQL.Clear;
        qry.SQL.Add('select  t.*');
        qry.SQL.Add('from    tab_negocio_tarefa t');
        qry.SQL.Add('join    tab_negocio n on (n.id_negocio = t.id_negocio)');
        qry.SQL.Add('where   n.id_usuario = :id_usuario');

        qry.ParamByName('id_usuario').Value := id_usuario;

        if ind_concluido <> '' then
        begin
            qry.SQL.Add('and t.ind_concluido = :ind_concluido');
            qry.ParamByName('ind_concluido').Value := ind_concluido;
        end;

        qry.SQL.Add('order by t.dt_tarefa, t.hora');
        qry.Active := true;

        Result := qry.ToJSONArray;

     finally
        FreeAndNil(qry);
     end;
end;

function TDmGlobal.InserirTarefa(id_negocio: integer;
                                 tarefa, descricao, dt_tarefa, hora: string): TJsonObject;
var
    qry: TFDQuery;
begin
     if (id_negocio <= 0) or (tarefa = '') then
        raise Exception.Create('Informe o id. negocio e a tarefa');

     try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        with qry do
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('insert into tab_negocio_tarefa(id_negocio, tarefa, descricao, dt_tarefa, hora, ind_concluido)');
            SQL.Add('values(:id_negocio, :tarefa, :descricao, :dt_tarefa, :hora, :ind_concluido)');
            SQL.Add('returning id_tarefa');

            ParamByName('id_negocio').Value := id_negocio;
            ParamByName('tarefa').Value := tarefa;
            ParamByName('descricao').Value := descricao;
            ParamByName('dt_tarefa').Value := dt_tarefa;
            ParamByName('hora').Value := hora;
            ParamByName('ind_concluido').Value := 'N';

            Active := true;
        end;

        Result := qry.ToJSONObject;

     finally
        FreeAndNil(qry);
     end;
end;

function TDmGlobal.ExcluirTarefa(id_tarefa: integer): TJsonObject;
var
    qry: TFDQuery;
begin
     if (id_tarefa <= 0)then
        raise Exception.Create('Informe o id. tarefa');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        with qry do
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('delete from tab_negocio_tarefa where id_tarefa=:id_tarefa');
            SQL.Add('returning id_tarefa');
            ParamByName('id_tarefa').Value := id_tarefa;
            Active := true;
        end;

        Result := qry.ToJSONObject;

     finally
        FreeAndNil(qry);
     end;
end;

function TDmGlobal.StatusTarefa(id_tarefa: integer; ind_concluido: string): TJsonObject;
var
    qry: TFDQuery;
begin
     if (id_tarefa <= 0) or (ind_concluido = '') then
        raise Exception.Create('Informe o id. tarefa e o status');

     try
        qry := TFDQuery.Create(nil);
        qry.Connection := Conn;

        with qry do
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('update tab_negocio_tarefa set ind_concluido=:ind_concluido');
            SQL.Add('where id_tarefa=:id_tarefa');
            SQL.Add('returning id_tarefa');

            ParamByName('id_tarefa').Value := id_tarefa;
            ParamByName('ind_concluido').Value := ind_concluido;

            Active := true;
        end;

        Result := qry.ToJSONObject;

     finally
        FreeAndNil(qry);
     end;
end;

end.
