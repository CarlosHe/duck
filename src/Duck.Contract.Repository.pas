unit Duck.Contract.Repository;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Duck.Contract.Entity.Version;

type

  IDuckRepository = interface
    ['{AE784C3A-6570-455B-8105-D45D653B0BCD}']
    procedure CreateDuckTable;
    function GetVersion: Int64;
    function GetVersionEntityCollection: TArray<IDuckVersionEntity>;
    function StoreVersion(const AVersionId: Int64; const AIsApplied: Boolean): IDuckVersionEntity;
    procedure UpdateIsApplied(const AVersionId: Int64; const AIsApplied: Boolean);
    procedure ExecuteScriptMigration(const AScriptMigration: string);
  end;

implementation


end.
