unit Migration.V20230527111000_CreateTableUser;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Duck.Contract.Migration;

type

  { TCreateUserTableMigration }

  TCreateUserTableMigration = class(TInterfacedObject, IDuckMigration)
  strict private
    constructor Create;
  private
  public
    function GetVersion: Int64;
    function GetName: string;
    function GetUp: string;
    function GetDown: string;
    class function New: IDuckMigration;
  end;

implementation

{ TCreateUserTableMigration }

constructor TCreateUserTableMigration.Create;
begin

end;

function TCreateUserTableMigration.GetVersion: Int64;
begin
  Result := 20230527111000;
end;

function TCreateUserTableMigration.GetName: string;
begin
  Result := 'create_table_user';
end;

function TCreateUserTableMigration.GetUp: string;
begin
  Result := 'CREATE TABLE users (name varchar(10) NOT NULL);';
end;

function TCreateUserTableMigration.GetDown: string;
begin
  Result := 'DROP TABLE users;';
end;

class function TCreateUserTableMigration.New: IDuckMigration;
begin
  Result := Self.Create;
end;

end.

