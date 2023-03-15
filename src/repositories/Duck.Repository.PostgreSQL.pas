unit Duck.Repository.PostgreSQL;

interface

uses
  Duck.Contract.Entity.Version,
  Duck.Contract.Repository,
  Duck.Contract.Connector;

type

  TDuckPostgreSQLRepository = class(TInterfacedObject, IDuckRepository)
  strict private
    { strict private declarations }
    constructor Create(const AConnector: IDuckConnector);
  private
    { private declarations }
    FConnector: IDuckConnector;
  protected
    { protected declarations }
  public
    { public declarations }
    procedure CreateDuckTable;
    function GetVersion: Int64;
    function StoreVersion(const AVersionId: Int64; const AIsApplied: Boolean): IDuckVersionEntity;
    procedure UpdateIsApplied(const AVersionId: Int64; const AIsApplied: Boolean);
    function GetVersionEntityCollection: TArray<IDuckVersionEntity>;
    procedure ExecuteScriptMigration(const AScriptMigration: string);
    class function New(const AConnector: IDuckConnector): IDuckRepository;
  end;

implementation

uses
  System.SysUtils,
  System.DateUtils,
  Data.DB,
  Duck.Entity.Version;

{ TDuckPostgreSQLRepository }

constructor TDuckPostgreSQLRepository.Create(const AConnector: IDuckConnector);
begin
  FConnector := AConnector;
end;

procedure TDuckPostgreSQLRepository.CreateDuckTable;
begin
  FConnector.ExecuteSQL(
    'CREATE SEQUENCE IF NOT EXISTS public.duck_db_version_id_seq' + #13#10 +
    '    INCREMENT 1' + #13#10 +
    '    START 1' + #13#10 +
    '    MINVALUE 1' + #13#10 +
    '    MAXVALUE 2147483647' + #13#10 +
    '    CACHE 1;' + #13#10 +
    'CREATE TABLE IF NOT EXISTS duck_db_version' + #13#10 +
    '(' + #13#10 +
    '    id integer NOT NULL DEFAULT nextval(' + QuotedStr('duck_db_version_id_seq') + '::regclass),' + #13#10 +
    '    version_id bigint NOT NULL,' + #13#10 +
    '    is_applied boolean NOT NULL,' + #13#10 +
    '    updated_at timestamp without time zone DEFAULT ' + QuotedStr('NOW()') + ',' + #13#10 +
    '    CONSTRAINT duck_db_version_pkey PRIMARY KEY (id)' + #13#10 +
    ')'
    );
end;

procedure TDuckPostgreSQLRepository.ExecuteScriptMigration(const AScriptMigration: string);
begin
  FConnector.ExecuteSQL(AScriptMigration);
end;

function TDuckPostgreSQLRepository.GetVersion: Int64;
var
  LDataSet: TDataSet;
begin
  Result := 0;
  LDataSet := FConnector.Query('SELECT version_id FROM duck_db_version WHERE is_applied ORDER BY version_id DESC LIMIT 1;');
  try
    if LDataSet.RecordCount > 0 then
      Result := LDataSet.FieldByName('version_id').AsLargeInt;
  finally
    LDataSet.Free;
  end;
end;

function TDuckPostgreSQLRepository.GetVersionEntityCollection: TArray<IDuckVersionEntity>;
var
  LDataSet: TDataSet;
  LDuckVersionEntity: IDuckVersionEntity;
begin
  Result := [];
  LDataSet := FConnector.Query('SELECT * FROM duck_db_version ORDER BY version_id ASC;');
  try
    while not LDataSet.Eof do
    begin
      LDuckVersionEntity := TDuckVersionEntity.New;
      try
        LDuckVersionEntity.SetId(LDataSet.FieldByName('id').AsInteger);
        LDuckVersionEntity.SetVersinId(LDataSet.FieldByName('version_id').AsLargeInt);
        LDuckVersionEntity.SetIsApplied(LDataSet.FieldByName('is_applied').AsBoolean);
        LDuckVersionEntity.SetUpdatedAt(DateTimeToUnix(LDataSet.FieldByName('updated_at').AsDateTime));
      finally
        Result := Result + [LDuckVersionEntity];
      end;
      LDataSet.Next;
    end;

  finally
    LDataSet.Free;
  end;
end;

class function TDuckPostgreSQLRepository.New(const AConnector: IDuckConnector): IDuckRepository;
begin
  Result := Self.Create(AConnector)
end;

function TDuckPostgreSQLRepository.StoreVersion(const AVersionId: Int64; const AIsApplied: Boolean): IDuckVersionEntity;
var
  LDataSet: TDataSet;
  LDuckVersionEntity: IDuckVersionEntity;
begin
  Result := nil;
  LDataSet := FConnector.Query(
    'INSERT INTO' + #13#10 +
    ' duck_db_version (version_id, is_applied)' + #13#10 +
    ' VALUES (' + AVersionId.ToString + ', ' + BoolToStr(AIsApplied, True) + ')' + #13#10 +
    'RETURNING id, version_id, is_applied, updated_at;'
    );
  try
    if not LDataSet.IsEmpty then
    begin
      LDuckVersionEntity := TDuckVersionEntity.New;
      try
        LDuckVersionEntity.SetId(LDataSet.FieldByName('id').AsInteger);
        LDuckVersionEntity.SetVersinId(LDataSet.FieldByName('version_id').AsLargeInt);
        LDuckVersionEntity.SetIsApplied(LDataSet.FieldByName('is_applied').AsBoolean);
        LDuckVersionEntity.SetUpdatedAt(DateTimeToUnix(LDataSet.FieldByName('updated_at').AsDateTime));
      finally
        Result := LDuckVersionEntity;
      end;
    end;
  finally
    LDataSet.Free;
  end;
end;

procedure TDuckPostgreSQLRepository.UpdateIsApplied(const AVersionId: Int64; const AIsApplied: Boolean);
begin
  FConnector.ExecuteSQL('UPDATE duck_db_version SET is_applied = ' + BoolToStr(AIsApplied, True) + ', updated_at = NOW() WHERE version_id = ' + AVersionId.ToString + ';');
end;

end.
