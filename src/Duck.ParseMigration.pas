unit Duck.ParseMigration;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  {$IF DEFINED(FPC)}
  Classes,
  {$ELSE}
  System.Classes,
  {$ENDIF}
  Duck.Contract.ParseMigration,
  Duck.Contract.Migration,
  Duck.Contract.Manager;

type

  TDuckParseMigration = class(TInterfacedObject, IDuckParseMigration)
  strict private
    { strict private declarations }
    constructor Create(const ADuckManager: IDuckManager);
  private
    { private declarations }
    FDuckManager: IDuckManager;
  protected
    { protected declarations }
    function ParseUpAndDown(const AStringList: TStringList; const AStartLine: Integer; const AEndLine: Integer): string;
    function Parse(const AFileName: string): IDuckMigration;
  public
    { public declarations }
    procedure LoadFromFolder(const AFolderName: string);
    procedure SaveToFolder(const AFolderName: string);
    class function New(const ADuckManager: IDuckManager): IDuckParseMigration;
  end;

implementation

uses
  {$IF DEFINED(FPC)}
  SysUtils,
  FileUtil,
  //IOUtils,
  {$ELSE}
  System.SysUtils,
  System.IOUtils,
  {$ENDIF}
  Duck.Migration;

const
  TAG_DUCK_UP = '+duck Up';
  TAG_DUCK_DOWN = '+duck Down';

  { TDuckParseMigration }

constructor TDuckParseMigration.Create(const ADuckManager: IDuckManager);
begin
  FDuckManager := ADuckManager;
end;

procedure TDuckParseMigration.LoadFromFolder(const AFolderName: string);
var
  {$IF DEFINED(FPC)}
  LFiles: TStringList;
  {$ELSE}
  LFiles: TArray<string>;
  {$ENDIF}
  I: Integer;
begin
  {$IF DEFINED(FPC)}
  LFiles := TStringList.Create;
  try
    FindAllFiles(LFiles, ExpandFileName(AFolderName), '*.sql', True);
    for I := 0 to Pred(LFiles.Count) do
    FDuckManager.AddMigration(Parse(LFiles.Strings[I]));
  finally
    LFiles.Free;
  end;
  {$ELSE}
  LFiles := TDirectory.GetFiles(AFolderName, '*.sql');
  for I := Low(LFiles) to High(LFiles) do
    FDuckManager.AddMigration(Parse(LFiles[I]));
  {$ENDIF}
end;

class function TDuckParseMigration.New(const ADuckManager: IDuckManager): IDuckParseMigration;
begin
  Result := Self.Create(ADuckManager);
end;

function TDuckParseMigration.Parse(const AFileName: string): IDuckMigration;
var
  LStringList: TStringList;
  LExtractedFileName: string;
  LVersion: string;
  LName: string;
  LUp: string;
  LDown: string;
  I: Integer;
  LPosStartDuckUp: Integer;
  LPosEndDuckUp: Integer;
  LPosStartDuckDown: Integer;
  LPosEndDuckDown: Integer;
begin
  LExtractedFileName := ExtractFileName(AFileName);
  LVersion := Copy(LExtractedFileName, 0, Pos('_', LExtractedFileName) - 1);
  LName := Copy(LExtractedFileName, Length(LVersion) + 2, Length(LExtractedFileName) - 1 - Length(LVersion) - Length(ExtractFileExt(LExtractedFileName)));

  LStringList := TStringList.Create;
  try
    LStringList.LoadFromFile(AFileName);
    LPosEndDuckUp := LStringList.Count;
    LPosEndDuckDown := LStringList.Count;
    I := 0;

    while I <= Pred(LStringList.Count) do
    begin
      if Pos(TAG_DUCK_UP, LStringList.Strings[I]) > 0 then
        LPosStartDuckUp := I;
      if Pos(TAG_DUCK_DOWN, LStringList.Strings[I]) > 0 then
        LPosStartDuckDown := I;
      Inc(I);
    end;

    if LPosStartDuckDown > LPosStartDuckUp then
      LPosEndDuckUp := LPosStartDuckDown
    else
      LPosEndDuckDown := LPosEndDuckUp;

    LUp := ParseUpAndDown(LStringList, LPosStartDuckUp + 1, LPosEndDuckUp - 1);
    LDown := ParseUpAndDown(LStringList, LPosStartDuckDown + 1, LPosEndDuckDown - 1);
    Result := TDuckMigration.New(StrToInt64Def(LVersion, 0), LName, LUp, LDown);
  finally
    LStringList.Free;
  end;
end;

function TDuckParseMigration.ParseUpAndDown(const AStringList: TStringList; const AStartLine, AEndLine: Integer): string;
var
  I: Integer;
begin
  for I := AStartLine to AEndLine do
  begin
    Result := Result + AStringList.Strings[I];
    if I < AEndLine then
      Result := Result + sLineBreak;
  end;
end;

procedure TDuckParseMigration.SaveToFolder(const AFolderName: string);
var
  LMigrationCollection: TArray<IDuckMigration>;
  LStringList: TStringList;
  I: Integer;
begin
  LMigrationCollection := FDuckManager.GetMigrationCollection;
  for I := Low(LMigrationCollection) to High(LMigrationCollection) do
  begin
    LStringList := TStringList.Create;
    try
      if not LMigrationCollection[I].GetUp.IsEmpty then
      begin
        LStringList.Add('-- ' + TAG_DUCK_UP);
        LStringList.Add(LMigrationCollection[I].GetUp);
      end;
      if not LMigrationCollection[I].GetDown.IsEmpty then
      begin
        LStringList.Add('-- ' + TAG_DUCK_DOWN);
        LStringList.Add(LMigrationCollection[I].GetDown);
      end;
      {$IF DEFINED(FPC)}
      LStringList.SaveToFile( ConcatPaths([ExpandFileName(AFolderName), string.Join('_', [LMigrationCollection[I].GetVersion, LMigrationCollection[I].GetName]) + '.sql']) );
      {$ELSE}
      LStringList.SaveToFile(TPath.Combine(AFolderName, string.Join('_', [LMigrationCollection[I].GetVersion, LMigrationCollection[I].GetName]) + '.sql'));
      {$ENDIF}
    finally
      LStringList.Free;
    end;
  end;
end;

end.
