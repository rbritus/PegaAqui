unit DataModule.Global;

interface

uses
  System.SysUtils, System.Classes, DataSet.Serialize, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, System.JSON, RESTRequest4D;

type
  TDmGlobal = class(TDataModule)
    TabNegociosResumo: TFDMemTable;
    TabNegocios: TFDMemTable;
    TabDashboard: TFDMemTable;
    TabTarefas: TFDMemTable;
    TabNegocio: TFDMemTable;
    TabEtapas: TFDMemTable;
    TabProdutos: TFDMemTable;
  private

  public
    procedure ListarNegociosResumo(id_usuario: integer);
    procedure ListarNegocios(etapa: string; id_usuario: integer);
    procedure DashboardResumos(id_usuario: integer);
    function DashboardAnual(id_usuario: integer): TJsonArray;
    procedure ListarTarefas(ind_concluido: string; id_usuario: integer);
    procedure ListarNegocioId(id_negocio: integer);
    procedure CadastrarNegocio(id_negocio, id_usuario: integer; etapa,
                          descricao, empresa, contato, fone, email: string; valor: double);
    procedure CadastrarTarefa(id_negocio: integer;
                              tarefa, descricao, dt_tarefa, hora: string);
    procedure ExcluirNegocio(id_negocio: integer);
    procedure ExcluirTarefa(id_tarefa: integer);
    procedure StatusTarefa(id_tarefa: integer; ind_concluido: string);
    procedure ListarEtapas;
    procedure ListarProdutos(id_usuario: integer);
  end;

var
  DmGlobal: TDmGlobal;

CONST
    BASE_URL = 'http://localhost:3000';
    API_USER = '99coders';
    API_PASS = '112233';


implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDmGlobal.ListarNegociosResumo(id_usuario: integer);
var
    resp: IResponse;
begin
    TabNegociosResumo.FieldDefs.Clear;

    resp := TRequest.New.BaseURL(BASE_URL)
                    .Resource('/negocios/resumo')
                    .AddParam('id_usuario', id_usuario.ToString)
                    .BasicAuthentication(API_USER, API_PASS)
                    .Accept('application/json')
                    .DataSetAdapter(TabNegociosResumo)
                    .Get;

    if resp.StatusCode <> 200 then
        raise Exception.Create(resp.Content);
end;

procedure TDmGlobal.ListarNegocios(etapa: string; id_usuario: integer);
var
    resp: IResponse;
begin
    TabNegocios.FieldDefs.Clear;

    resp := TRequest.New.BaseURL(BASE_URL)
                    .Resource('/negocios')
                    .AddParam('id_usuario', id_usuario.ToString)
                    .AddParam('etapa', etapa)
                    .BasicAuthentication(API_USER, API_PASS)
                    .Accept('application/json')
                    .DataSetAdapter(TabNegocios)
                    .Get;

    if resp.StatusCode <> 200 then
        raise Exception.Create(resp.Content);
end;

procedure TDmGlobal.DashboardResumos(id_usuario: integer);
var
//    resp: IResponse;
    json_str: string;
begin
    TabDashboard.FieldDefs.Clear;

    json_str := '{"valormes": 15, "qtdmes": 6}';

    TabDashboard.LoadFromJSON(json_str);

//    resp := TRequest.New.BaseURL(BASE_URL)
//                    .Resource('/dashboard/resumos')
//                    .AddParam('id_usuario', id_usuario.ToString)
//                    .BasicAuthentication(API_USER, API_PASS)
//                    .Accept('application/json')
//                    .DataSetAdapter(TabDashboard)
//                    .Get;
//
//    if resp.StatusCode <> 200 then
//        raise Exception.Create(resp.Content);

end;

function TDmGlobal.DashboardAnual(id_usuario: integer): TJsonArray;
var
//    resp: IResponse;
    json_str: string;
begin
    json_str := '[{"field": 1, "valor": 56}, {"field": 2, "valor": 80}, ';
    json_str := json_str + '{"field": 3, "valor": 32.3}, {"field": 4, "valor": 0}, {"field": 5, "valor": 15}]';

    Result := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(json_str), 0) as TJSONArray;

//    resp := TRequest.New.BaseURL(BASE_URL)
//                    .Resource('/dashboard/anual')
//                    .AddParam('id_usuario', id_usuario.ToString)
//                    .BasicAuthentication(API_USER, API_PASS)
//                    .Accept('application/json')
//                    .Get;
//
//    if resp.StatusCode <> 200 then
//        raise Exception.Create(resp.Content);


//    Result := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(resp.Content), 0) as TJSONArray;
end;

procedure TDmGlobal.ListarTarefas(ind_concluido: string; id_usuario: integer);
var
    resp: IResponse;
begin
    TabTarefas.FieldDefs.Clear;

    resp := TRequest.New.BaseURL(BASE_URL)
                    .Resource('/tarefas')
                    .AddParam('id_usuario', id_usuario.ToString)
                    .AddParam('ind_concluido', ind_concluido)
                    .BasicAuthentication(API_USER, API_PASS)
                    .Accept('application/json')
                    .DataSetAdapter(TabTarefas)
                    .Get;

    if resp.StatusCode <> 200 then
        raise Exception.Create(resp.Content);
end;

procedure TDmGlobal.ListarProdutos(id_usuario: integer);
var
//    resp: IResponse;
    json_str: string;
begin
    tabProdutos.FieldDefs.Clear;

    json_str := '[{"id_produto": 1, "descricao": "Coca-cola", "preco": 3.5, "classificacao": "Lata 350ml"},';
    json_str := json_str + '{"id_produto": 2, "descricao": "Coca-cola", "preco": 2.6, "classificacao": "Pet 260ml"},';
    json_str := json_str + '{"id_produto": 3, "descricao": "Fandangos", "preco": 2.5, "classificacao": "60gm"},';
    json_str := json_str + '{"id_produto": 4, "descricao": "Cheetos", "preco": 2.5, "classificacao": "60gm"},';
    json_str := json_str + '{"id_produto": 5, "descricao": "Água", "preco": 1.5, "classificacao": "Pet 200ml"},';
    json_str := json_str + '{"id_produto": 6, "descricao": "Heinneken", "preco": 4.5, "classificacao": "Lata 350ml"}]';

    tabProdutos.LoadFromJSON(json_str);

//    resp := TRequest.New.BaseURL(BASE_URL)
//                    .Resource('/tarefas')
//                    .AddParam('id_usuario', id_usuario.ToString)
//                    .BasicAuthentication(API_USER, API_PASS)
//                    .Accept('application/json')
//                    .DataSetAdapter(tabProdutos)
//                    .Get;
//
//    if resp.StatusCode <> 200 then
//        raise Exception.Create(resp.Content);
end;

procedure TDmGlobal.ListarNegocioId(id_negocio: integer);
var
    resp: IResponse;
begin
    TabNegocio.FieldDefs.Clear;

    // GET -> http://localhost:3000/negocios/3

    resp := TRequest.New.BaseURL(BASE_URL)
                    .Resource('/negocios')
                    .ResourceSuffix(id_negocio.ToString)
                    .BasicAuthentication(API_USER, API_PASS)
                    .Accept('application/json')
                    .DataSetAdapter(TabNegocio)
                    .Get;

    if resp.StatusCode <> 200 then
        raise Exception.Create(resp.Content);
end;

procedure TDmGlobal.ListarEtapas;
var
    resp: IResponse;
begin
    TabEtapas.FieldDefs.Clear;

    resp := TRequest.New.BaseURL(BASE_URL)
                    .Resource('/etapas')
                    .BasicAuthentication(API_USER, API_PASS)
                    .Accept('application/json')
                    .DataSetAdapter(TabEtapas)
                    .Get;

    if resp.StatusCode <> 200 then
        raise Exception.Create(resp.Content);
end;

procedure TDmGlobal.CadastrarNegocio(id_negocio, id_usuario: integer;
                                     etapa, descricao, empresa, contato, fone, email: string;
                                     valor: double);
var
    resp: IResponse;
    json: TJSONObject;
begin
    json := TJSONObject.Create;
    try
        json.AddPair('id_usuario', id_usuario.ToString);
        json.AddPair('etapa', etapa);
        json.AddPair('descricao', descricao);
        json.AddPair('empresa', empresa);
        json.AddPair('contato', contato);
        json.AddPair('fone', fone);
        json.AddPair('email', email);
        json.AddPair('valor', TJsonNumber.Create(valor));

        if id_negocio = 0 then
        begin
            resp := TRequest.New.BaseURL(BASE_URL)
                    .Resource('/negocios')
                    .BasicAuthentication(API_USER, API_PASS)
                    .Accept('application/json')
                    .AddBody(json.ToJSON)
                    .Post;

            if resp.StatusCode <> 201 then
                raise Exception.Create(resp.Content);
        end
        else
        begin
            resp := TRequest.New.BaseURL(BASE_URL)
                    .Resource('/negocios')
                    .ResourceSuffix(id_negocio.ToString)
                    .BasicAuthentication(API_USER, API_PASS)
                    .Accept('application/json')
                    .AddBody(json.ToJSON)
                    .Put;

            if resp.StatusCode <> 200 then
                raise Exception.Create(resp.Content);
        end;

    finally
        json.DisposeOf;
    end;

end;

procedure TDmGlobal.CadastrarTarefa(id_negocio: integer;
                                    tarefa, descricao, dt_tarefa, hora: string);
var
    resp: IResponse;
    json: TJSONObject;
begin
    json := TJSONObject.Create;
    try
        json.AddPair('id_negocio', id_negocio.ToString);
        json.AddPair('tarefa', tarefa);
        json.AddPair('descricao', descricao);
        json.AddPair('dt_tarefa', dt_tarefa); // yyyy-mm-dd
        json.AddPair('hora', hora);

        resp := TRequest.New.BaseURL(BASE_URL)
                .Resource('/tarefas')
                .BasicAuthentication(API_USER, API_PASS)
                .Accept('application/json')
                .AddBody(json.ToJSON)
                .Post;

        if resp.StatusCode <> 201 then
            raise Exception.Create(resp.Content);

    finally
        json.DisposeOf;
    end;

end;


procedure TDmGlobal.ExcluirNegocio(id_negocio: integer);
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(BASE_URL)
                .Resource('/negocios')
                .ResourceSuffix(id_negocio.ToString)
                .BasicAuthentication(API_USER, API_PASS)
                .Accept('application/json')
                .Delete;

    if resp.StatusCode <> 200 then
        raise Exception.Create(resp.Content);
end;

procedure TDmGlobal.StatusTarefa(id_tarefa: integer; ind_concluido: string);
var
    resp: IResponse;
    json: TJSONObject;
begin
    json := TJSONObject.Create;
    try
        json.AddPair('ind_concluido', ind_concluido);

        resp := TRequest.New.BaseURL(BASE_URL)
                .Resource('/tarefas')
                .ResourceSuffix(id_tarefa.ToString + '/status')
                .BasicAuthentication(API_USER, API_PASS)
                .Accept('application/json')
                .AddBody(json.ToJSON)
                .Put;

        if resp.StatusCode <> 200 then
            raise Exception.Create(resp.Content);

    finally
        json.DisposeOf;
    end;

end;

procedure TDmGlobal.ExcluirTarefa(id_tarefa: integer);
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(BASE_URL)
                .Resource('/tarefas')
                .ResourceSuffix(id_tarefa.ToString)
                .BasicAuthentication(API_USER, API_PASS)
                .Accept('application/json')
                .Delete;

    if resp.StatusCode <> 200 then
        raise Exception.Create(resp.Content);
end;


end.
