unit Duck.Connector.SQLdb;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  SQLDB,
  Duck.Contract.Connector,
  DB;

type

  TDuckSQLdbConnector = class(TInterfacedObject, IDuckConnector)
  strict private
    { strict private declarations }
    constructor Create(const AConnection: TSQLConnector);
  private
    { private declarations }
    FConnection: TSQLConnector;
  protected
    { protected declarations }
  public
    { public declarations }
    procedure ExecuteSQL(const ASQL: string);
    function Query(const ASQL: string; const AParams: TArray<Variant> = []): TDataSet;
    class function New(const AConnection: TSQLConnector): IDuckConnector;
  end;

implementation

{ TDuckSQLdbConnector }

constructor TDuckSQLdbConnector.Create(const AConnection: TSQLConnector);
begin
  FConnection := AConnection;
end;

procedure TDuckSQLdbConnector.ExecuteSQL(const ASQL: string);
begin
  FConnection.ExecuteDirect(ASQL);
end;

class function TDuckSQLdbConnector.New(const AConnection: TSQLConnector): IDuckConnector;
begin
  Result := Self.Create(AConnection);
end;

function TDuckSQLdbConnector.Query(const ASQL: string; const AParams: TArray<Variant> = []): TDataSet;
var
  LSQLQuery: TSQLQuery;
  I: Integer;
begin
  LSQLQuery := TSQLQuery.Create(nil);
  try
    LSQLQuery.DataBase := FConnection;
    LSQLQuery.SQL.Text := ASQL;
    for I:= 0 to High(AParams) do
      LSQLQuery.Params.Items[I].Value := AParams[I];
    LSQLQuery.Open;
  finally
    Result := LSQLQuery;
  end;
end;

end.

