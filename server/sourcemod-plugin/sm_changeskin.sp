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

public Plugin:myinfo =
{
  name = "SM CS:GO Change Skin",
  author = "Andreas Mausch",
  description = "",
  version = "1.0",
  url = "https://andreas-mausch.de/"
};

public OnPluginStart()
{
  RegConsoleCmd("sm_changeskin", ChangeSkin);
  RegConsoleCmd("sm_gloves", ChangeGloves);
  RegConsoleCmd("sm_player_model", ChangePlayerModel);
  RegConsoleCmd("sm_teleport", Teleport);

  for (new client = 1; client <= MaxClients; client++)
  {
    if (!IsClientInGame(client))
      continue;

    OnClientPutInServer(client);
  }
}

public OnClientPutInServer(client)
{
  if(!IsFakeClient(client)) SDKHook(client, SDKHook_WeaponEquipPost, OnPostWeaponEquip);
}

public Action:OnPostWeaponEquip(client, weapon)
{
  new Handle:pack;
  CreateDataTimer(0.0, Pasado, pack);
  WritePackCell(pack, EntIndexToEntRef(weapon));
  WritePackCell(pack, client);
}

public Action:Pasado(Handle:timer, Handle:pack)
{
  new weapon;
  new client

  ResetPack(pack);
  weapon = EntRefToEntIndex(ReadPackCell(pack));
  client = ReadPackCell(pack);

  if(weapon == INVALID_ENT_REFERENCE || !IsClientInGame(client) || !IsPlayerAlive(client)) return;

  if(weapon < 1 || !IsValidEdict(weapon) || !IsValidEntity(weapon)) return;

  if (GetEntProp(weapon, Prop_Send, "m_hPrevOwner") > 0 || (GetEntProp(weapon, Prop_Send, "m_iItemIDHigh") == 0 && GetEntProp(weapon, Prop_Send, "m_iItemIDLow") == 2048))
    return;

  decl String:Classname[64];
  GetEdictClassname(weapon, Classname, 64);
  if(StrEqual(Classname, "weapon_taser"))
  {
    return;
  }
  new weaponindex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
  if(weaponindex == 42 || weaponindex == 59)
  {
    return;
  }
  if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == weapon || GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) == weapon || GetPlayerWeaponSlot(client, CS_SLOT_KNIFE) == weapon || GetPlayerWeaponSlot(client, CS_SLOT_C4) == weapon)
  {
    switch (weaponindex)
    {
      case 60: strcopy(Classname, 64, "weapon_m4a1_silencer");
      case 61: strcopy(Classname, 64, "weapon_usp_silencer");
      case 63: strcopy(Classname, 64, "weapon_cz75a");
      case 500: strcopy(Classname, 64, "weapon_bayonet");
      case 506: strcopy(Classname, 64, "weapon_knife_gut");
      case 505: strcopy(Classname, 64, "weapon_knife_flip");
      case 508: strcopy(Classname, 64, "weapon_knife_m9_bayonet");
      case 507: strcopy(Classname, 64, "weapon_knife_karambit");
      case 509: strcopy(Classname, 64, "weapon_knife_tactical");
      case 515: strcopy(Classname, 64, "weapon_knife_butterfly");
    }
    new valor = 0;
    if(valor == 0) return;
    //PrintToChat(client, "prueba");
  }
}
