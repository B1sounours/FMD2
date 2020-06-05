unit LuaFMD;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, {$ifdef luajit}lua{$else}{$ifdef lua54}lua54{$else}lua53{$endif}{$endif};

implementation

uses
  LuaUtils, LuaPackage, FMDOptions, SimpleTranslator;

function luaopen_fmd(L: Plua_State): Integer; cdecl;
var
  t: Integer;
begin
  t := luaNewTable(L);
  luaAddStringToTable(L, t, 'Directory', FMD_DIRECTORY);
  luaAddStringToTable(L, t, 'ExeName', FMD_EXENAME);
  luaAddStringToTable(L, t, 'Version', FMD_VERSION_STRING);
  luaAddStringToTable(L, t, 'Revision', REVISION_NUMBER);
  luaAddStringToTable(L, t, 'LuaDirectory', LUA_REPO_FOLDER);
  luaAddStringToTable(L, t, 'SelectedLanguage', SimpleTranslator.LastSelected);
  Result := 1;
end;

initialization
  LuaPackage.AddLib('fmd', @luaopen_fmd);

end.
