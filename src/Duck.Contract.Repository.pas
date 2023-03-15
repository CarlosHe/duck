unit Duck.Contract.Repository;

interface

uses
  Duck.Contract.Entity.Version;

type

  IDuckRepository = interface
    ['{4220CCDF-269D-4FAF-A7F6-30278647B96E}']
    procedure CreateDuckTable;
    function GetVersion: Int64;
    function StoreVersion(const AVersionId: Int64; const AIsApplied: Boolean): IDuckVersionEntity;
    procedure UpdateIsApplied(const AVersionId: Int64; const AIsApplied: Boolean);
    function GetVersionEntityCollection: TArray<IDuckVersionEntity>;
    procedure ExecuteScriptMigration(const AScriptMigration: string);
  end;

implementation


end.
