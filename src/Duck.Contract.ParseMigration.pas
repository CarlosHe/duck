unit Duck.Contract.ParseMigration;

interface

type

  IDuckParseMigration = interface
    ['{AC0AD6EF-1F64-42A7-853D-786A46F0BA5F}']
    procedure LoadFromFolder(const AFolderName: string);
    procedure SaveToFolder(const AFolderName: string);
  end;

implementation

end.
