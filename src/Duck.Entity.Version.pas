unit Duck.Entity.Version;

interface

uses
  Duck.Contract.Entity.Version;

type

  TDuckVersionEntity = class(TInterfacedObject, IDuckVersionEntity)
  strict private
    { strict private declarations }
    constructor Create;
  private
    { private declarations }
    FId: Integer;
    FVersinId: Int64;
    FIsApplied: Boolean;
    FUpdatedAt: Int64;
  protected
    { protected declarations }
  public
    { public declarations }
    function GetId: Integer;
    function GetVersinId: Int64;
    function GetIsApplied: Boolean;
    function GetUpdatedAt: Int64;
    procedure SetId(const AId: Integer);
    procedure SetVersinId(const AVersionId: Int64);
    procedure SetIsApplied(const AIsApplied: Boolean);
    procedure SetUpdatedAt(const AUpdatedAt: Int64);
    class function New: IDuckVersionEntity;
  end;

implementation

{ TDuckVersionEntity }

constructor TDuckVersionEntity.Create;
begin

end;

function TDuckVersionEntity.GetUpdatedAt: Int64;
begin
  Result := FUpdatedAt;
end;

function TDuckVersionEntity.GetId: Integer;
begin
  Result := FId;
end;

function TDuckVersionEntity.GetIsApplied: Boolean;
begin
  Result := FIsApplied;
end;

function TDuckVersionEntity.GetVersinId: Int64;
begin
  Result := FVersinId;
end;

class function TDuckVersionEntity.New: IDuckVersionEntity;
begin
  Result := Self.Create;
end;

procedure TDuckVersionEntity.SetUpdatedAt(const AUpdatedAt: Int64);
begin
  FUpdatedAt := AUpdatedAt;
end;

procedure TDuckVersionEntity.SetId(const AId: Integer);
begin
  FId := AId;
end;

procedure TDuckVersionEntity.SetIsApplied(const AIsApplied: Boolean);
begin
  FIsApplied := AIsApplied;
end;

procedure TDuckVersionEntity.SetVersinId(const AVersionId: Int64);
begin
  FVersinId := AVersionId;
end;

end.
