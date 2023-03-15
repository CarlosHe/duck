unit Duck.Migration;

interface

uses
  Duck.Contract.Migration;

type

  TDuckMigration = class(TInterfacedObject, IDuckMigration)
  strict private
    { strict private declarations }
    constructor Create(const AVersion: Int64; const AName: string; const AUp: string; const ADown: string);
  private
    { private declarations }
    FVersion: Int64;
    FName: string;
    FUp: string;
    FDown: string;
  protected
    { protected declarations }
  public
    { public declarations }
    function GetVersion: Int64;
    function GetName: string;
    function GetUp: string;
    function GetDown: string;
    class function New(const AVersion: Int64; const AName: string; const AUp: string; const ADown: string): IDuckMigration;
  end;

implementation

{ TDuckMigration }

constructor TDuckMigration.Create(const AVersion: Int64; const AName: string; const AUp: string; const ADown: string);
begin
  FVersion := AVersion;
  FName := AName;
  FUp := AUp;
  FDown := ADown;
end;

function TDuckMigration.GetDown: string;
begin
  Result := FDown;
end;

function TDuckMigration.GetName: string;
begin
  Result := FName;
end;

function TDuckMigration.GetUp: string;
begin
  Result := FUp;
end;

function TDuckMigration.GetVersion: Int64;
begin
  Result := FVersion;
end;

class function TDuckMigration.New(const AVersion: Int64; const AName: string; const AUp: string; const ADown: string): IDuckMigration;
begin
  Result := Self.Create(AVersion, AName, AUp, ADown);
end;

end.
