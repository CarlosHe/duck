unit Duck.Contract.Entity.Version;

interface

type

  IDuckVersionEntity = interface
    ['{1158374E-C2F8-4D7E-AD4A-53824634C7BA}']
    function GetId: Integer;
    function GetVersinId: Int64;
    function GetIsApplied: Boolean;
    function GetUpdatedAt: Int64;
    procedure SetId(const AId: Integer);
    procedure SetVersinId(const AVersionId: Int64);
    procedure SetIsApplied(const AIsApplied: Boolean);
    procedure SetUpdatedAt(const AUpdatedAt: Int64);
  end;

implementation

end.
