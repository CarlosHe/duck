unit Duck.Contract.Connector;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  {$IF DEFINED(FPC)}
  DB
  {$ELSE}
  Data.DB
  {$ENDIF}
  ;

type

  IDuckConnector = interface
    ['{4461370E-99C3-4A21-A34A-2555FB561E1D}']
    procedure ExecuteSQL(const ASQL: string);
    function Query(const ASQL: string; const AParams: TArray<Variant> = []): TDataSet;
  end;

implementation

end.
