program Sample;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  Duck.Contract.Connector,
  Duck.Contract.Entity.Version,
  Duck.Contract.Manager,
  Duck.Contract.Migration,
  Duck.Contract.ParseMigration,
  Duck.Contract.Repository,
  Duck.Entity.Version,
  Duck.Manager,
  Duck.Migration,
  Duck.ParseMigration,
  views.main,
  Duck.Connector.SQLdb,
  Duck.Repository.MySQL,
  Duck.Repository.PostgreSQL,
  Migration.V20230527111000_CreateTableUser;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
