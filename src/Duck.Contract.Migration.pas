unit Duck.Contract.Migration;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

type

  IDuckMigration = interface
    ['{286BC6AA-980C-4180-9324-EABE7420F644}']
    function GetVersion: Int64;
    function GetName: string;
    function GetUp: string;
    function GetDown: string;
  end;

implementation

end.
