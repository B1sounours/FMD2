unit DownloadsDB;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLiteData, uBaseUnit, sqlite3dyn;

type

  { TDownloadsDB }

  TDownloadsDB = class(TSQLiteDataWA)
  public
    constructor Create(const AFilename: String);
    function Add(
      const Aenabled:Boolean; const Aorder,Ataskstatus,Achapterptr,Anumberofpages,Acurrentpage:Integer;
      const Amoduleid,Alink,Atitle,Astatus,Aprogress,Asaveto:String;
      const Adateadded,Adatelastdownloaded:TDateTime;
      const Achapterslinks,Achaptersnames,Apagelinks,Apagecontainerlinks,Afilenames,Acustomfilenames,Achaptersstatus:String
      ): String; inline;
    procedure Update(
      const Aid:String;
      const Ataskstatus,Achapterptr,Anumberofpages,Acurrentpage:Integer;
      const Astatus,Aprogress:String;
      const Adatelastdownloaded:TDateTime;
      const Apagelinks,Apagecontainerlinks,Afilenames,Achaptersstatus:String
      ); inline;
    procedure UpdateEnabled(const Aid:String;const Aenabled:Boolean); inline;
    procedure UpdateStatus(const Aid:String;const Ataskstatus:Integer;const Astatus:String); inline;
    procedure Delete(const Aid:String); inline;
  end;

const
  f_id                 = 0;
  f_enabled            = 1;
  f_order              = 2;
  f_taskstatus         = 3;
  f_chapterptr         = 4;
  f_numberofpages      = 5;
  f_currentpage        = 6;
  f_moduleid           = 7;
  f_link               = 8;
  f_title              = 9;
  f_status             = 10;
  f_progress           = 11;
  f_saveto             = 12;
  f_dateadded          = 13;
  f_datelastdownloaded = 14;
  f_chapterslinks      = 15;
  f_chaptersnames      = 16;
  f_pagelinks          = 17;
  f_pagecontainerlinks = 18;
  f_filenames          = 19;
  f_customfilenames    = 20;
  f_chaptersstatus     = 21;

implementation

{ TDownloadsDB }

constructor TDownloadsDB.Create(const AFilename: String);
begin
  inherited Create;
  Filename := AFilename;
  TableName := 'downloads';
  CreateParams :=
    '"id" INTEGER PRIMARY KEY,' +
    '"enabled" BOOLEAN,' +
    '"order" INTEGER,' +
    '"taskstatus" INTEGER,' +
    '"chapterptr" INTEGER,' +
    '"numberofpages" INTEGER,' +
    '"currentpage" INTEGER,' +
    '"moduleid" TEXT,' +
    '"link" TEXT,' +
    '"title" TEXT,' +
    '"status" TEXT,' +
    '"progress" TEXT,' +
    '"saveto" TEXT,' +
    '"dateadded" DATETIME,' +
    '"datelastdownloaded" DATETIME,' +
    '"chapterslinks" TEXT,' +
    '"chaptersnames" TEXT,' +
    '"pagelinks" TEXT,' +
    '"pagecontainerlinks" TEXT,' +
    '"filenames" TEXT,' +
    '"customfilenames" TEXT,' +
    '"chaptersstatus" TEXT';
  FieldsParams := '"id","enabled","order","taskstatus","chapterptr","numberofpages","currentpage","moduleid","link","title","status","progress","saveto","dateadded","datelastdownloaded","chapterslinks","chaptersnames","pagelinks","pagecontainerlinks","filenames","customfilenames","chaptersstatus"';
  SelectParams := 'SELECT ' + FieldsParams + ' FROM '+QuotedStrD(TableName)+' ORDER BY "order"';
end;

function TDownloadsDB.Add(
  const Aenabled:Boolean; const Aorder,Ataskstatus,Achapterptr,Anumberofpages,Acurrentpage:Integer;
  const Amoduleid,Alink,Atitle,Astatus,Aprogress,Asaveto:String;
  const Adateadded,Adatelastdownloaded:TDateTime;
  const Achapterslinks,Achaptersnames,Apagelinks,Apagecontainerlinks,Afilenames,Acustomfilenames,Achaptersstatus:String
  ): String;
begin
  Connection.ExecuteSQL(
    'INSERT INTO "downloads" ("enabled","order","taskstatus","chapterptr","numberofpages","currentpage","moduleid","link","title","status","progress","saveto","dateadded","datelastdownloaded","chapterslinks","chaptersnames","pagelinks","pagecontainerlinks","filenames","customfilenames","chaptersstatus") VALUES (''' +
    BoolToStr(Aenabled,'1','0') + ''',''' +
    IntToStr(Aorder) + ''',''' +
    IntToStr(Ataskstatus) + ''',''' +
    IntToStr(Achapterptr) + ''',''' +
    IntToStr(Anumberofpages) + ''',''' +
    IntToStr(Acurrentpage) + ''',''' +
    Amoduleid + ''',' +
    QuotedStr(Alink) + ',' +
    QuotedStr(Atitle) + ',' +
    QuotedStr(Astatus) + ',' +
    QuotedStr(Aprogress) + ',' +
    QuotedStr(Asaveto) + ',' +
    QuotedStr(Adateadded) + ',' +
    QuotedStr(Adatelastdownloaded) + ',' +
    QuotedStr(Achapterslinks) + ',' +
    QuotedStr(Achaptersnames) + ',' +
    QuotedStr(Apagelinks) + ',' +
    QuotedStr(Apagecontainerlinks) + ',' +
    QuotedStr(Afilenames) + ',' +
    QuotedStr(Acustomfilenames) + ',' +
    QuotedStr(Achaptersstatus) + ');');
  Result:=IntToStr(sqlite3_last_insert_rowid(Connection.Handle));
end;

procedure TDownloadsDB.Update(
  const Aid:String;
  const Ataskstatus,Achapterptr,Anumberofpages,Acurrentpage:Integer;
  const Astatus,Aprogress:String;
  const Adatelastdownloaded:TDateTime;
  const Apagelinks,Apagecontainerlinks,Afilenames,Achaptersstatus:String
  );
begin
  AppendSQLSafe('UPDATE "downloads" SET "taskstatus"=''' +IntToStr(Ataskstatus) +
    ''',"chapterptr"=''' +     IntToStr(Achapterptr) +
    ''',"numberofpages"=''' +  IntToStr(Anumberofpages) +
    ''',"currentpage"=''' +    IntToStr(Acurrentpage) +
    ''',"status"=' +           QuotedStr(Astatus) +
    ',"progress"=' +           QuotedStr(Aprogress) +
    ',"datelastdownloaded"=' + QuotedStr(Adatelastdownloaded) +
    ',"pagelinks"=' +          QuotedStr(Apagelinks) +
    ',"pagecontainerlinks"=' + QuotedStr(Apagecontainerlinks) +
    ',"filenames"=' +          QuotedStr(Afilenames) +
    ',"chaptersstatus"=' +     QuotedStr(Achaptersstatus) +
    ' WHERE "id"='''+Aid+''';');
end;

procedure TDownloadsDB.UpdateEnabled(const Aid:String;const Aenabled:Boolean);
begin
  AppendSQL('UPDATE "downloads" SET "enabled"='''+BoolToStr(Aenabled,'1','0')+''' WHERE "id"='''+Aid+''';');
end;

procedure TDownloadsDB.UpdateStatus(const Aid:String;const Ataskstatus:Integer;const Astatus:String);
begin
  AppendSQL('UPDATE "downloads" SET "taskstatus"='''+IntToStr(Ataskstatus)+''',"status"='+QuotedStr(Astatus)+' WHERE "id"='''+Aid+''';');
end;

procedure TDownloadsDB.Delete(const Aid:String);
begin
  AppendSQL('DELETE FROM "downloads" WHERE "id"='''+Aid+''';');
end;

end.

