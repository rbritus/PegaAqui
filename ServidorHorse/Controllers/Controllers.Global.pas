unit Controllers.Global;

interface

uses Horse,
     DataModule.Global,
     System.JSON,
     System.SysUtils;

procedure RegistrarRotas;
procedure DashboardResumos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure DashboardAnual(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ListarNegociosResumo(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ListarNegocios(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ListarNegocioId(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure InserirNegocio(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure EditarNegocio(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ExcluirNegocio(Req: THorseRequest; Res: THorseResponse; Next: TProc);

procedure ListarEtapas(Req: THorseRequest; Res: THorseResponse; Next: TProc);

procedure ListarTarefas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure InserirTarefa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ExcluirTarefa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure StatusTarefa(Req: THorseRequest; Res: THorseResponse; Next: TProc);


implementation

procedure RegistrarRotas;
begin
    THorse.Get('/dashboard/resumos', DashboardResumos);
    THorse.Get('/dashboard/anual', DashboardAnual);

    THorse.Get('/negocios/resumo', ListarNegociosResumo);
    THorse.Get('/negocios', ListarNegocios);
    THorse.Get('/negocios/:id_negocio', ListarNegocioId);
    THorse.Post('/negocios', InserirNegocio);
    THorse.Put('/negocios/:id_negocio', EditarNegocio);
    THorse.Delete('/negocios/:id_negocio', ExcluirNegocio);

    THorse.Get('/etapas', ListarEtapas);

    THorse.Get('/tarefas', ListarTarefas);
    THorse.Post('/tarefas', InserirTarefa);
    THorse.Delete('/tarefas/:id_tarefa', ExcluirTarefa);
    THorse.Put('/tarefas/:id_tarefa/status', StatusTarefa);
end;

procedure DashboardResumos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
    id_usuario: integer;
begin
    try
        try
            DmGlobal := TDmGlobal.Create(nil);

            // Query Param
            // GET --> http://localhost:3000/dashboard/resumos?id_usuario=1

            try
                id_usuario := Req.Query['id_usuario'].ToInteger;
            except
                id_usuario := 0;
            end;

            Res.Send<TJSONObject>(DmGlobal.DashboardResumos(id_usuario)).Status(200);

        except on ex:exception do
            Res.Send(ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure DashboardAnual(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
    id_usuario: integer;
begin
    try
        try
            DmGlobal := TDmGlobal.Create(nil);

            // Query Param
            // GET --> http://localhost:3000/dashboard/anual?id_usuario=1

            try
                id_usuario := Req.Query['id_usuario'].ToInteger;
            except
                id_usuario := 0;
            end;

            Res.Send<TJSONArray>(DmGlobal.DashboardAnual(id_usuario)).Status(200);

        except on ex:exception do
            Res.Send(ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure ListarNegociosResumo(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
    id_usuario: integer;
begin
    try
        try
            DmGlobal := TDmGlobal.Create(nil);

            // Query Param
            // GET --> http://localhost:3000/negocios/resumo?id_usuario=1

            try
                id_usuario := Req.Query['id_usuario'].ToInteger;
            except
                id_usuario := 0;
            end;

            Res.Send<TJSONArray>(DmGlobal.ListarNegociosResumo(id_usuario)).Status(200);

        except on ex:exception do
            Res.Send(ex.Message).Status(500);
        end;
    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure ListarNegocios(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
    id_usuario: integer;
    etapa: string;
begin
    try
        try
            DmGlobal := TDmGlobal.Create(nil);

            // GET --> http://localhost:3000/negocios?id_usuario=1&etapa=Proposta

            try
                id_usuario := Req.Query['id_usuario'].ToInteger;
            except
                id_usuario := 0;
            end;

            try
                etapa := Req.Query['etapa'];
            except
                etapa := '';
            end;

            Res.Send<TJSONArray>(DmGlobal.ListarNegocios(id_usuario, etapa)).Status(200);

        except on ex:exception do
            Res.Send(ex.Message).Status(500);
        end;

    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure ListarNegocioId(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
    id_negocio: integer;
    etapa: string;
begin
    try
        try
            DmGlobal := TDmGlobal.Create(nil);

            // URI Params...
            // GET --> http://localhost:3000/negocios/123

            try
                id_negocio := Req.Params.Items['id_negocio'].ToInteger
            except
                id_negocio := 0;
            end;


            Res.Send<TJSONObject>(DmGlobal.ListarNegocioId(id_negocio)).Status(200);

        except on ex:exception do
            Res.Send(ex.Message).Status(500);
        end;

    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure InserirNegocio(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
    body: TJSONObject;

    id_usuario: integer;
    etapa, descricao, empresa, contato, fone, email: string;
    valor: double;
begin
    try
        try
            DmGlobal := TDmGlobal.Create(nil);

            body := Req.Body<TJSONObject>;

            id_usuario := body.GetValue<integer>('id_usuario', 0);
            etapa := body.GetValue<string>('etapa', '');
            descricao := body.GetValue<string>('descricao', '');
            empresa := body.GetValue<string>('empresa', '');
            contato := body.GetValue<string>('contato', '');
            fone := body.GetValue<string>('fone', '');
            email := body.GetValue<string>('email', '');
            valor := body.GetValue<double>('valor', 0);


            Res.Send<TJSONObject>(DmGlobal.InserirNegocio(id_usuario, etapa, descricao, empresa,
                                                          contato, fone, email, valor)).Status(201);

        except on ex:exception do
            Res.Send(ex.Message).Status(500);
        end;

    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure EditarNegocio(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
    body: TJSONObject;

    id_negocio: integer;
    etapa, descricao, empresa, contato, fone, email: string;
    valor: double;
begin
    try
        try
            DmGlobal := TDmGlobal.Create(nil);

            // URI Params
            // PUT ->  http://localhost:3000/negocios/12

            try
                id_negocio := Req.Params.Items['id_negocio'].ToInteger;
            except
                id_negocio := 0;
            end;

            body := Req.Body<TJSONObject>;
            etapa := body.GetValue<string>('etapa', '');
            descricao := body.GetValue<string>('descricao', '');
            empresa := body.GetValue<string>('empresa', '');
            contato := body.GetValue<string>('contato', '');
            fone := body.GetValue<string>('fone', '');
            email := body.GetValue<string>('email', '');
            valor := body.GetValue<double>('valor', 0);


            Res.Send<TJSONObject>(DmGlobal.EditarNegocio(id_negocio, etapa, descricao, empresa,
                                                         contato, fone, email, valor)).Status(200);

        except on ex:exception do
            Res.Send(ex.Message).Status(500);
        end;

    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure ExcluirNegocio(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
    body: TJSONObject;
    id_negocio: integer;
begin
    try
        try
            DmGlobal := TDmGlobal.Create(nil);

            // URI Param
            // DELETE -> http://localhost:3000/negocios/8

            try
                id_negocio := Req.Params.Items['id_negocio'].ToInteger;
            except
                id_negocio := 0;
            end;


            Res.Send<TJSONObject>(DmGlobal.ExcluirNegocio(id_negocio)).Status(200);

        except on ex:exception do
            Res.Send(ex.Message).Status(500);
        end;

    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure ListarEtapas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
begin
    try
        try
            DmGlobal := TDmGlobal.Create(nil);

            // GET --> http://localhost:3000/etapas

            Res.Send<TJSONArray>(DmGlobal.ListarEtapas).Status(200);

        except on ex:exception do
            Res.Send(ex.Message).Status(500);
        end;

    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure ListarTarefas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
    id_usuario: integer;
    ind_concluido: string;
begin
    try
        try
            DmGlobal := TDmGlobal.Create(nil);

            // GET --> http://localhost:3000/tarefas?id_usuario=1&ind_concluido=S

            try
                id_usuario := Req.Query['id_usuario'].ToInteger;
            except
                id_usuario := 0;
            end;

            try
                ind_concluido := Req.Query['ind_concluido'];
            except
                ind_concluido := '';
            end;

            Res.Send<TJSONArray>(DmGlobal.ListarTarefas(id_usuario, ind_concluido)).Status(200);

        except on ex:exception do
            Res.Send(ex.Message).Status(500);
        end;

    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure InserirTarefa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
    body: TJSONObject;

    id_negocio: integer;
    tarefa, descricao, dt_tarefa, hora: string;
begin
    try
        try
            DmGlobal := TDmGlobal.Create(nil);

            body := Req.Body<TJSONObject>;
            id_negocio := body.GetValue<integer>('id_negocio', 0);
            tarefa := body.GetValue<string>('tarefa', '');
            descricao := body.GetValue<string>('descricao', '');
            dt_tarefa := body.GetValue<string>('dt_tarefa', '');
            hora := body.GetValue<string>('hora', '');


            Res.Send<TJSONObject>(DmGlobal.InserirTarefa(id_negocio, tarefa, descricao, dt_tarefa, hora)).Status(201);

        except on ex:exception do
            Res.Send(ex.Message).Status(500);
        end;

    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure ExcluirTarefa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
    body: TJSONObject;
    id_tarefa: integer;
begin
    try
        try
            DmGlobal := TDmGlobal.Create(nil);

            // DELETE -> http://localhost:3000/tarefas/5

            try
                id_tarefa := Req.Params.Items['id_tarefa'].ToInteger;
            except
                id_tarefa := 0;
            end;

            Res.Send<TJSONObject>(DmGlobal.ExcluirTarefa(id_tarefa)).Status(200);

        except on ex:exception do
            Res.Send(ex.Message).Status(500);
        end;

    finally
        FreeAndNil(DmGlobal);
    end;
end;

procedure StatusTarefa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    DmGlobal: TDmGlobal;
    body: TJSONObject;

    id_tarefa: integer;
    ind_concluido: string;
begin
    try
        try
            DmGlobal := TDmGlobal.Create(nil);

            // PUT -> http://localhost:3000/tarefas/3/status

            try
                id_tarefa := Req.Params.Items['id_tarefa'].ToInteger;
            except
                id_tarefa := 0;
            end;

            body := Req.Body<TJSONObject>;
            ind_concluido := body.GetValue<string>('ind_concluido', '');


            Res.Send<TJSONObject>(DmGlobal.StatusTarefa(id_tarefa, ind_concluido)).Status(200);

        except on ex:exception do
            Res.Send(ex.Message).Status(500);
        end;

    finally
        FreeAndNil(DmGlobal);
    end;
end;

end.
