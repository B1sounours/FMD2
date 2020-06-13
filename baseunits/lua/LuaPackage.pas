unit LuaPackage;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, {$ifdef luajit}lua{$else}{$ifdef lua54}lua54{$else}lua53{$endif}{$endif}, LuaBase;

procedure RegisterLoader(const L: Plua_State);
procedure AddLib(const AName: String; const ARegLib: lua_CFunction);

procedure ClearCache;

var
  LuaLibDir: String = 'lua' + DirectorySeparator;

implementation

uses FileCache, FileUtil, LazFileUtils, MultiLog, LuaUtils;

const
  LIBPREFIX = 'fmd.';

type

  TLuaLib = class
    RegLib: lua_CFunction;
  end;

  { TCachedPackage }

  TCachedPackage = class
  public
    FileName: String;
    Stream: TMemoryStream;
    constructor Create(const AFileName: String; const AStream: TMemoryStream);
    destructor Destroy; override;
  end;

var
  HostPackage,
  Package: TFileCache;

{ TCacheItem }

constructor TCachedPackage.Create(const AFileName: String;
  const AStream: TMemoryStream);
begin
  FileName := AFileName;
  Stream := AStream;
end;

destructor TCachedPackage.Destroy;
begin
  Stream.Free;
  inherited Destroy;
end;

{ LuaPackage }

function _findpackage(L: Plua_State): Integer; cdecl;
var
  i: Integer;
  o: TLuaLib;
  c: TCachedPackage;
  p: String;
begin
  p := luaToString(L, 1);

  if p.StartsWith(LIBPREFIX) then
  begin
    o := TLuaLib(HostPackage.Find(p));
    if o <> nil then
    begin
      lua_pushcfunction(L, o.RegLib);
      Exit(1);
    end
  end;

  c := TCachedPackage(Package.Find(p));
  if c <> nil then
  begin
    i := LuaLoadFromStreamOrFile(L, c.Stream, c.FileName);
    if i = 0 then
      Exit(1)
    else
      Logger.SendError('require '+QuotedStr(p)+' '+LuaGetReturnString(i)+': '+lua_tostring(L,-1));
  end;
  Result := 0;
end;

procedure RegisterLoader(const L: Plua_State);
var
  top, loaders, i: Integer;
begin
  top:=lua_gettop(L);
  lua_getglobal(L, 'package');
  if LUA_VERSION_NUM = 501 then
    lua_getfield(L, -1, 'loaders')
  else
    lua_getfield(L, -1, 'searchers');
  loaders:=lua_gettop(L);
  i:=0;
  repeat
    Inc(i);
    lua_rawgeti(L, loaders, i);
  until lua_type(L, -1) <= LUA_TNIL;
  lua_pop(L, 1);
  for i:=i downto 2 do // shift items down to make a room
    lua_rawseti(L, loaders, i);
  lua_pushcfunction(L, @_findpackage);
  lua_rawseti(L, loaders,1);
  lua_settop(L,top);
end;

function LoadLuaFile(const AFileName: String): TObject;
var
  f: String;
  m: TMemoryStream;
begin
  f := LuaLibDir + AFileName.Replace('.', DirectorySeparator) + '.lua';
  if FileExists(f) then
  begin
    m := LuaDumpFileToStream(f);
    if m <> nil then
      Result := TCachedPackage.Create(f, m);
  end
  else
    Result := nil;
end;

procedure AddLib(const AName: String; const ARegLib: lua_CFunction);
var
  lib: TLuaLib;
begin
  lib := TLuaLib.Create;
  lib.RegLib := ARegLib;
  HostPackage.Add(LIBPREFIX + AName, TObject(lib));
end;

procedure ClearCache;
begin
  Package.Clear;
end;

initialization
  Package:=TFileCache.Create(@LoadLuaFile);
  HostPackage:=TFileCache.Create;

finalization
  Package.Free;
  HostPackage.Free;

end.
