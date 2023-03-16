<p align="center">
  <a href="https://github.com/CarlosHe/duck/blob/main/img/duck-logo.png">
    <img alt="Duck" height="150" src="https://github.com/CarlosHe/duck/blob/main/img/duck-logo.png">
  </a>  
</p><br>
<p align="center">
  <b>Duck</b> is a database migration framework. Manage your database by creating incremental SQL changes or Delphi functions.
</p><br>

## ⚙️ Installation
Installation is done using the [`boss install`](https://github.com/HashLoad/boss) command:
``` sh
boss install github.com/CarlosHe/duck
```

## ⚡️ Quickstart
ex: FireDAC connector and PostgreSQL repository.
```delphi
uses
  Duck.Contract.Manager,
  Duck.Manager,
  Duck.Connector.FireDAC,
  Duck.Repository.PostgreSQL;

var DuckManager: IDuckManager;

begin
  DuckManager := TDuckManager.New(
    TDuckPostgreSQLRepository.New(
      TDuckFireDACConnector.New(FDConnection)
    )
  );
end.
```

## ⚡️ Create class migration
```delphi
unit Migration.V20230315000000_CreateTableExample;

interface

uses
  Duck.Contract.Migration;

type

  TCreateExampleTableMigration = class(TInterfacedObject, IDuckMigration)
  strict private
    { strict private declarations }
    constructor Create;
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    function GetVersion: Int64;
    function GetName: string;
    function GetUp: string;
    function GetDown: string;
    class function New: IDuckMigration;
  end;

implementation

{ TCreateExampleTableMigration }

constructor TCreateExampleTableMigration.Create;
begin

end;

function TCreateExampleTableMigration.GetDown: string;
begin
  Result := 'DROP TABLE examples;';
end;

function TCreateExampleTableMigration.GetName: string;
begin
  Result := 'create_table_examples';
end;

function TCreateExampleTableMigration.GetVersion: Int64;
begin
  Result := 20230315000000;
end;

class function TCreateExampleTableMigration.New: IDuckMigration;
begin
  Result := Self.Create;
end;

function TCreateExampleTableMigration.GetUp: string;
begin
  Result := 'CREATE TABLE examples (name varchar NOT NULL);';
end;

end.
```

## ⚡️ Add class migration
```delphi
begin
  DuckManager.AddMigration(TCreateExampleTableMigration.New);
end.
```

## ⚡️ Create file migration
Create migration file (version_name.sql).
ex: 20230315000000_create_table_examples.sql
```sql
-- +duck Up
CREATE TABLE examples (name varchar NOT NULL);
-- +duck Down
DROP TABLE examples;
```

## ⚡️ Add folder migration files
```delphi
uses
  Duck.Contract.ParseMigration,
  Duck.ParseMigration;

var
  LDuckParseMigration: IDuckParseMigration;
begin
  LDuckParseMigration := TDuckParseMigration.New(DuckManager);
  LDuckParseMigration.LoadFromFolder('.\migrations');
end.
```

## ⚡️ Up
Apply all available migrations.
```delphi
begin
  DuckManager.Up;
end.
```

## ⚡️ UpToVersion
Migrate up to a specific version.
```delphi
begin
  DuckManager.UpToVersion(20230315000000);
end.
```

## ⚡️ UpByOne
Migrate up a single migration from the current version
```delphi
begin
  DuckManager.UpByOne;
end.
```

## ⚡️ Down
Roll back a single migration from the current version.
```delphi
begin
  DuckManager.Down;
end.
```

## ⚡️ DownToVersion
Roll back migrations to a specific version.
```delphi
begin
  DuckManager.DownToVersion(20230315000000);
end.
```

## ⚡️ Redo
Roll back the most recently applied migration, then run it again.
```delphi
begin
  DuckManager.Redo;
end.
```

## ⚡️ Reset
Roll back all migrations.
```delphi
begin
  DuckManager.Reset;
end.
```
