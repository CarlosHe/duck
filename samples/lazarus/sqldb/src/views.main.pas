unit views.main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, mysql57conn, mysql56conn, mysql55conn, mysql51conn, mysql50conn, Forms, Controls, Graphics,
  Dialogs, StdCtrls, Duck.Contract.Manager;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonUp: TButton;
    ButtonDown: TButton;
    ButtonReset: TButton;
    ButtonParse: TButton;
    ButtonSave: TButton;
    SQLConnector: TSQLConnector;
    SQLTransaction1: TSQLTransaction;
    procedure ButtonDownClick(Sender: TObject);
    procedure ButtonParseClick(Sender: TObject);
    procedure ButtonResetClick(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure ButtonUpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    DuckManager: IDuckManager;

  public

  end;

var
  Form1: TForm1;


implementation

uses
  Duck.Manager,
  Duck.Connector.SQLdb,
  Duck.Repository.MySQL,
  Duck.Contract.ParseMigration,
  Duck.ParseMigration,
  Migration.V20230527111000_CreateTableUser;

{$R *.lfm}

{ TForm1 }

procedure TForm1.ButtonUpClick(Sender: TObject);
begin
  DuckManager.Up;
end;

procedure TForm1.ButtonDownClick(Sender: TObject);
begin
  DuckManager.Down;
end;

procedure TForm1.ButtonParseClick(Sender: TObject);
var
  LDuckParseMigration: IDuckParseMigration;
begin
  LDuckParseMigration := TDuckParseMigration.New(DuckManager);
  LDuckParseMigration.LoadFromFolder('.\migrations');
end;

procedure TForm1.ButtonResetClick(Sender: TObject);
begin
  DuckManager.Reset;
end;

procedure TForm1.ButtonSaveClick(Sender: TObject);
var
  LDuckParseMigration: IDuckParseMigration;
begin
  LDuckParseMigration := TDuckParseMigration.New(DuckManager);
  LDuckParseMigration.SaveToFolder('.\migrations');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  DuckManager := TDuckManager.New(
    TDuckMySQLRepository.New(
      TDuckSQLdbConnector.New(SQLConnector)
    )
  );

  DuckManager.AddMigration(TCreateUserTableMigration.New);
end;

end.

