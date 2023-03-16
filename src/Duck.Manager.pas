unit Duck.Manager;

interface

uses
  System.Generics.Collections,
  System.Generics.Defaults,
  Duck.Contract.Manager,
  Duck.Contract.Repository,
  Duck.Contract.Migration,
  Duck.Contract.Entity.Version;

type

  TDuckManager = class(TInterfacedObject, IDuckManager)
  strict private
    { strict private declarations }
    constructor Create(const ADuckRepository: IDuckRepository);
  private
    { private declarations }
    FVersion: Int64;
    FDuckRepository: IDuckRepository;
    FMigrationCollection: TList<IDuckMigration>;
    FPendingMigrationCollection: TList<IDuckMigration>;
    FVersionEntityCollection: TArray<IDuckVersionEntity>;
  protected
    { protected declarations }
    function ListMigrationComparison(const Left, Right: IDuckMigration): Integer;
    function GetIsPendingMigration(const ADuckMigration: IDuckMigration; const AVersionEntityCollection: TArray<IDuckVersionEntity>): Boolean;
    function GetPendingMigrationCollection(const ADuckMigration: TList<IDuckMigration>; const AVersionEntityCollection: TArray<IDuckVersionEntity>): TList<IDuckMigration>;
    function GetVersionEntityExists(const AVersionId: Int64; const ADuckVersionEntityCollection: TArray<IDuckVersionEntity>): Boolean;
    procedure UpdateIsAppliedVersionEntityItemByVersionId(const AVersionId: Int64; const ADuckVersionEntityCollection: TArray<IDuckVersionEntity>; const AIsApplied: Boolean);
  public
    { public declarations }
    destructor Destroy; override;
    procedure AddMigration(const ADuckMigration: IDuckMigration);
    function GetMigrationCollection: TArray<IDuckMigration>;
    procedure Up;
    procedure UpByOne;
    procedure UpToVersion(const AVersion: Int64);
    procedure Down;
    procedure DownToVersion(const AVersion: Int64);
    procedure Redo;
    procedure Reset;
    function Version: Int64;
    class function New(const ADuckRepository: IDuckRepository): IDuckManager;
  end;

implementation

{ TDuckManager }

constructor TDuckManager.Create(const ADuckRepository: IDuckRepository);
begin
  FMigrationCollection := TList<IDuckMigration>.Create(TComparer<IDuckMigration>.Construct(ListMigrationComparison));
  FDuckRepository := ADuckRepository;
  FDuckRepository.CreateDuckTable;
  FVersionEntityCollection := FDuckRepository.GetVersionEntityCollection;
  FPendingMigrationCollection := GetPendingMigrationCollection(FMigrationCollection, FVersionEntityCollection);
  FVersion := FDuckRepository.GetVersion;
end;

destructor TDuckManager.Destroy;
begin
  FMigrationCollection.Free;
  FPendingMigrationCollection.Free;
  inherited;
end;

procedure TDuckManager.Down;
var
  I: Integer;
begin
  FMigrationCollection.Sort;
  for I := Pred(FMigrationCollection.Count) downto 0 do
  begin
    if FMigrationCollection.Items[I].GetVersion > FVersion then
      Continue;
    FDuckRepository.ExecuteScriptMigration(FMigrationCollection.Items[I].GetDown);
    FDuckRepository.UpdateIsApplied(FMigrationCollection.Items[I].GetVersion, False);
    UpdateIsAppliedVersionEntityItemByVersionId(FMigrationCollection.Items[I].GetVersion, FVersionEntityCollection, False);
    if I > 0 then
      FVersion := FMigrationCollection.Items[I - 1].GetVersion
    else
      FVersion := 0;
    FPendingMigrationCollection.Add(FMigrationCollection[I]);
    Break;
  end;
end;

procedure TDuckManager.DownToVersion(const AVersion: Int64);
begin
  if not FMigrationCollection.Count > 0 then
    Exit;
  while AVersion < FVersion do
    Down;
end;

function TDuckManager.GetIsPendingMigration(const ADuckMigration: IDuckMigration; const AVersionEntityCollection: TArray<IDuckVersionEntity>): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := Low(AVersionEntityCollection) to High(AVersionEntityCollection) do
  begin
    if (AVersionEntityCollection[I].GetVersinId = ADuckMigration.GetVersion) and (AVersionEntityCollection[I].GetIsApplied) then
    begin
      Result := False;
      Break;
    end;
  end;
end;

function TDuckManager.GetMigrationCollection: TArray<IDuckMigration>;
begin
  Result := FMigrationCollection.ToArray;
end;

function TDuckManager.GetPendingMigrationCollection(const ADuckMigration: TList<IDuckMigration>; const AVersionEntityCollection: TArray<IDuckVersionEntity>): TList<IDuckMigration>;
var
  I: Integer;
begin
  Result := TList<IDuckMigration>.Create(TComparer<IDuckMigration>.Construct(ListMigrationComparison));
  for I := 0 to Pred(ADuckMigration.Count) do
  begin
    if GetIsPendingMigration(ADuckMigration.Items[I], AVersionEntityCollection) then
      Result.Add(ADuckMigration.Items[I]);
  end;
end;

function TDuckManager.GetVersionEntityExists(const AVersionId: Int64; const ADuckVersionEntityCollection: TArray<IDuckVersionEntity>): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(ADuckVersionEntityCollection) to High(ADuckVersionEntityCollection) do
  begin
    if ADuckVersionEntityCollection[I].GetVersinId = AVersionId then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TDuckManager.ListMigrationComparison(const Left, Right: IDuckMigration): Integer;
begin
  Result := Left.GetVersion - Right.GetVersion;
end;

class function TDuckManager.New(const ADuckRepository: IDuckRepository): IDuckManager;
begin
  Result := Self.Create(ADuckRepository);
end;

procedure TDuckManager.Redo;
var
  I: Integer;
begin
  for I := Pred(FMigrationCollection.Count) downto 0 do
  begin
    if FMigrationCollection.Items[I].GetVersion > FVersion then
      Continue;
    FDuckRepository.ExecuteScriptMigration(FMigrationCollection.Items[I].GetDown);
    FDuckRepository.ExecuteScriptMigration(FMigrationCollection.Items[I].GetUp);
    FDuckRepository.UpdateIsApplied(FMigrationCollection.Items[I].GetVersion, True);
    UpdateIsAppliedVersionEntityItemByVersionId(FMigrationCollection.Items[I].GetVersion, FVersionEntityCollection, True);
    FVersion := FMigrationCollection.Items[I].GetVersion;
    if FPendingMigrationCollection.Contains(FMigrationCollection[I]) then
      FPendingMigrationCollection.Remove(FMigrationCollection[I]);
    Break;
  end;
end;

procedure TDuckManager.Reset;
begin
  DownToVersion(0);
end;

procedure TDuckManager.AddMigration(const ADuckMigration: IDuckMigration);
var
  LDuckVersionEntity: IDuckVersionEntity;
begin
  FMigrationCollection.Add(ADuckMigration);
  if not GetVersionEntityExists(ADuckMigration.GetVersion, FVersionEntityCollection) then
  begin
    LDuckVersionEntity := FDuckRepository.StoreVersion(ADuckMigration.GetVersion, False);
    FVersionEntityCollection := FVersionEntityCollection + [LDuckVersionEntity];
  end;
  if GetIsPendingMigration(ADuckMigration, FVersionEntityCollection) then
    FPendingMigrationCollection.Add(ADuckMigration);
end;

procedure TDuckManager.Up;
begin
  while FPendingMigrationCollection.Count > 0 do
    UpByOne;
end;

procedure TDuckManager.UpByOne;
begin
  FPendingMigrationCollection.Sort;
  if FPendingMigrationCollection.Count > 0 then
  begin
    FDuckRepository.ExecuteScriptMigration(FPendingMigrationCollection.Items[0].GetUp);
    FDuckRepository.UpdateIsApplied(FPendingMigrationCollection.Items[0].GetVersion, True);
    UpdateIsAppliedVersionEntityItemByVersionId(FPendingMigrationCollection.Items[0].GetVersion, FVersionEntityCollection, True);
    FVersion := FPendingMigrationCollection.Items[0].GetVersion;
    FPendingMigrationCollection.Remove(FPendingMigrationCollection[0]);
  end;
end;

procedure TDuckManager.UpdateIsAppliedVersionEntityItemByVersionId(const AVersionId: Int64; const ADuckVersionEntityCollection: TArray<IDuckVersionEntity>; const AIsApplied: Boolean);
var
  I: Integer;
begin
  for I := Low(ADuckVersionEntityCollection) to High(ADuckVersionEntityCollection) do
  begin
    if ADuckVersionEntityCollection[I].GetVersinId = AVersionId then
    begin
      ADuckVersionEntityCollection[I].SetIsApplied(AIsApplied);
      Break;
    end;
  end;
end;

procedure TDuckManager.UpToVersion(const AVersion: Int64);
begin
  while FPendingMigrationCollection.Count > 0 do
  begin
    if FPendingMigrationCollection[0].GetVersion > AVersion then
      Break;
    UpByOne;
  end;
end;

function TDuckManager.Version: Int64;
begin
  Result := FVersion;
end;

end.
