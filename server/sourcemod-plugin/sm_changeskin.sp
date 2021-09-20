#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>
#include <clientprefs>

#include "sm_skin.sp"
#include "sm_gloves.sp"
#include "sm_player_model.sp"
#include "sm_teleport.sp"

#undef REQUIRE_PLUGIN
#define MAX_PAINTS 800

public Plugin myinfo = {
  name = "SM CS:GO Change Skin",
  author = "Andreas Mausch",
  description = "",
  version = "1.0",
  url = "https://andreas-mausch.de/"
};

public OnPluginStart() {
  RegConsoleCmd("sm_changeskin", ChangeSkin);
  RegConsoleCmd("sm_gloves", ChangeGloves);
  RegConsoleCmd("sm_player_model", ChangePlayerModel);
  RegConsoleCmd("sm_teleport", Teleport);
}
