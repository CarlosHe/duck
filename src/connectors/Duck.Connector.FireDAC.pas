unit Duck.Connector.FireDAC;

interface

uses
  FireDAC.Comp.Client,
  FireDAC.DApt,
  Duck.Contract.Connector,
  Data.DB;

type

  TDuckFireDACConnector = class(TInterfacedObject, IDuckConnector)
  strict private
    { strict private declarations }
    constructor Create(const AConnection: TFDConnection);
  private
    { private declarations }
    FConnection: TFDConnection;
  protected
    { protected declarations }
  public
    { public declarations }
    procedure ExecuteSQL(const ASQL: string);
    function Query(const ASQL: string; const AParams: TArray<Variant> = []): TDataSet;
    class function New(const AConnection: TFDConnection): IDuckConnector;
  end;

implementation

{ TDuckFireDACConnector }

constructor TDuckFireDACConnector.Create(const AConnection: TFDConnection);
begin
  FConnection := AConnection;
end;

procedure TDuckFireDACConnector.ExecuteSQL(const ASQL: string);
begin
  FConnection.ExecSQL(ASQL);
end;

class function TDuckFireDACConnector.New(const AConnection: TFDConnection): IDuckConnector;
begin
  Result := Self.Create(AConnection);
end;

function TDuckFireDACConnector.Query(const ASQL: string; const AParams: TArray<Variant> = []): TDataSet;
var
  LFDQuery: TFDQuery;
begin
  LFDQuery := TFDQuery.Create(nil);
  try
    LFDQuery.Connection := FConnection;
    LFDQuery.Open(ASQL, AParams);
  finally
    Result := LFDQuery;
  end;
end;

end.
