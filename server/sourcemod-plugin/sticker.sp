#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>
#include <clientprefs>
#include <PTaH>

#undef REQUIRE_PLUGIN
#define MAX_PAINTS 800

public Plugin:myinfo =
{
  name = "SM CS:GO Set Sticker",
  author = "Andreas Mausch",
  description = "",
  version = "1.0",
  url = "https://andreas-mausch.de/"
};

public OnPluginStart()
{
  RegConsoleCmd("sm_sticker", SetSticker);
}

public Action:SetSticker(client, args)
{
  if (GetCmdArgs() < 2)
  {
    ReplyToCommand(client, "Need at least 2 arguments (slot, index, wear, scale, rotation)");
    return Plugin_Handled;
  }

  new String:slotString[64], String:indexString[64], String:wearString[64], String:scaleString[64], String:rotationString[64];
  new iSlot, iStickerIndex, Float:fStickerWear, Float:fStickerScale, Float:fStickerRotation;
  GetCmdArg(1, slotString, sizeof(slotString));
  GetCmdArg(2, indexString, sizeof(indexString));
  
  if (GetCmdArg(3, wearString, sizeof(wearString)) == 0)
  {
    wearString = "0.0";
  }
  if (GetCmdArg(4, scaleString, sizeof(scaleString)) == 0)
  {
    scaleString = "1.0";
  }
  GetCmdArg(5, rotationString, sizeof(rotationString));

  iSlot = StringToInt(slotString);
  iStickerIndex = StringToInt(indexString);
  fStickerWear = StringToFloat(wearString);
  fStickerScale = StringToFloat(scaleString);
  fStickerRotation = StringToFloat(rotationString);

  PrintToServer("SetSticker slot=%d, index=%d, wear=%f, scale=%f, rotation=%f", iSlot, iStickerIndex, fStickerWear, fStickerScale, fStickerRotation);

  int iWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

  if (GetEntProp(iWeapon, Prop_Send, "m_iItemIDHigh") < 16384)
  {
    static int IDHigh = 16384;
    SetEntProp(iWeapon, Prop_Send, "m_iItemIDLow", -1);
    SetEntProp(iWeapon, Prop_Send, "m_iItemIDHigh", IDHigh++);
    SetEntProp(iWeapon, Prop_Send, "m_iAccountID", GetSteamAccountID(client, true));
    SetEntPropEnt(iWeapon, Prop_Send, "m_hOwnerEntity", client);
    SetEntPropEnt(iWeapon, Prop_Send, "m_hPrevOwner", -1);
  }
  CAttributeList pAttributeList = PTaH_GetEconItemViewFromEconEntity(iWeapon).NetworkedDynamicAttributesForDemos;
  
  pAttributeList.SetOrAddAttributeValue(113 + iSlot * 4, iStickerIndex); // sticker slot %i id
	
  if(fStickerWear != 0.0)
	{
		pAttributeList.SetOrAddAttributeValue(114 + iSlot * 4, fStickerWear); // sticker slot %i wear
	}

  if(fStickerScale != 0.0)
	{
		pAttributeList.SetOrAddAttributeValue(115 + iSlot * 4, fStickerScale); //sticker slot %i scale
	}
	
  if(fStickerRotation != 0.0)
	{
		pAttributeList.SetOrAddAttributeValue(116 + iSlot * 4, fStickerRotation); //sticker slot %i rotation
	}

  PTaH_ForceFullUpdate(client);

  return Plugin_Handled;
}