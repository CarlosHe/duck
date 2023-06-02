unit Duck.Contract.Manager;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  {$IF DEFINED(FPC)}
  Generics.Collections,
  {$ELSE}
  System.Generics.Collections,
  {$ENDIF}
  Duck.Contract.Migration;

type

  IDuckManager = interface
    ['{3AD9F145-68AF-4183-9B54-0AF8FC6B7895}']
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
  end;

implementation

end.
