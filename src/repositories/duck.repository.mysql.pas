unit Duck.Repository.MySQL;

{$IFDEF FPC}
  {$MODE Delphi} {$M+}
{$ENDIF}

interface

uses
  {$IF DEFINED(FPC)}
  SysUtils,
  {$ELSE}
  {$ENDIF}
  Duck.Contract.Repository,
  Duck.Contract.Entity.Version,
  Duck.Contract.Connector
  ;

type

  { TDuckMySQLRepository }

  TDuckMySQLRepository = class(TInterfacedObject, IDuckRepository)
  strict private
    { strict private declarations }
    constructor Create(const AConnector: IDuckConnector);
  private
    { private declarations }
    FConnector: IDuckConnector;
  public
    { public declarations }
    procedure CreateDuckTable;
    function GetVersion: Int64;
    function GetVersionEntityCollection: TArray<IDuckVersionEntity>;
    function StoreVersion(const AVersionId: Int64; const AIsApplied: Boolean): IDuckVersionEntity;
    procedure UpdateIsApplied(const AVersionId: Int64; const AIsApplied: Boolean);
    procedure ExecuteScriptMigration(const AScriptMigration: string);
    class function New(const AConnector: IDuckConnector): IDuckRepository;
  end;

implementation

uses
  {$IF DEFINED(FPC)}
  DateUtils,
  DB,
  {$ELSE}
  System.SysUtils,
  System.DateUtils,
  Data.DB,
  {$ENDIF}
  Duck.Entity.Version;

{ TDuckMySQLRepository }

constructor TDuckMySQLRepository.Create(const AConnector: IDuckConnector);
begin
  FConnector := AConnector;
end;

procedure TDuckMySQLRepository.CreateDuckTable;
begin
  FConnector.ExecuteSQL(
    'CREATE TABLE IF NOT EXISTS duck_db_version' + #13#10 +
    '(' + #13#10 +
    '    id integer NOT NULL AUTO_INCREMENT,' + #13#10 +
    '    version_id bigint NOT NULL,' + #13#10 +
    '    is_applied boolean NOT NULL,' + #13#10 +
    '    updated_at timestamp DEFAULT CURRENT_TIMESTAMP,' + #13#10 +
    '    PRIMARY KEY(id)' + #13#10 +
    ')'
    );
end;

procedure TDuckMySQLRepository.ExecuteScriptMigration(const AScriptMigration: string);
begin
  FConnector.ExecuteSQL(AScriptMigration);
end;

function TDuckMySQLRepository.GetVersion: Int64;
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

function TDuckMySQLRepository.GetVersionEntityCollection: TArray<IDuckVersionEntity>;
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

class function TDuckMySQLRepository.New(const AConnector: IDuckConnector): IDuckRepository;
begin
  Result := Self.Create(AConnector)
end;

function TDuckMySQLRepository.StoreVersion(const AVersionId: Int64; const AIsApplied: Boolean): IDuckVersionEntity;
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

procedure TDuckMySQLRepository.UpdateIsApplied(const AVersionId: Int64; const AIsApplied: Boolean);
begin
  FConnector.ExecuteSQL('UPDATE duck_db_version SET is_applied = ' + BoolToStr(AIsApplied, True) + ', updated_at = CURRENT_TIMESTAMP WHERE version_id = ' + AVersionId.ToString + ';');
end;

end.

