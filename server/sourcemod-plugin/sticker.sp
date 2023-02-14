#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>
#include <clientprefs>
#include <PTaH>

#undef REQUIRE_PLUGIN
#define MAX_PAINTS 800

Handle g_SDKGetAttributeDefinitionByName = null;
Handle g_SDKGenerateAttribute = null;
Handle g_SDKAddAttribute = null;
int g_econItemOffset = -1;
int g_networkedDynamicAttributesOffset = 156;
int g_attributeListCountOffset = 16;
int g_attributeListReadOffset = 4;

Address g_pItemSystem = Address_Null;
Address g_pItemSchema = Address_Null;

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
  g_econItemOffset = FindSendPropOffset("CBaseCombatWeapon", "m_Item");

  SetupItemSystem();
  SetupGetAttributeDefinitionByName();
  SetupGenerateAttribute();
  SetupAddAttribute();

  RegConsoleCmd("sm_sticker", SetSticker);
}

public Action:SetupItemSystem()
{
  StartPrepSDKCall(SDKCall_Static);
  // ItemSystem
  char signature[] = "\x55\x89\xE5\x57\x56\x53\x83\xEC\x0C\x8B\x1D\x2A\x2A\x2A\x2A\x85\xDB\x74\x2A";
  PrepSDKCall_SetSignature(SDKLibrary_Server, signature, sizeof(signature) - 1);
  PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);

  Handle SDKItemSystem = EndPrepSDKCall();
  if (!SDKItemSystem)
  {
    SetFailState("Method \"ItemSystem\" was not loaded right.");
    return;
  }

  g_pItemSystem = SDKCall(SDKItemSystem);
  if (g_pItemSystem == Address_Null)
  {
    SetFailState("Failed to get \"ItemSystem\" pointer address.");
    return;
  }

  delete SDKItemSystem;
  g_pItemSchema = g_pItemSystem + view_as<Address>(4);
}

public Action:SetupGetAttributeDefinitionByName()
{
  StartPrepSDKCall(SDKCall_Raw);
  // CEconItemSchema::GetAttributeDefinitionByName
  char signature[] = "\x55\x89\xE5\x57\x56\x53\x83\xEC\x1C\xA1\x2A\x2A\x2A\x2A\x8B\x75\x08\x89\x45\xE4\x85\xC0\x75\x2A";
  PrepSDKCall_SetSignature(SDKLibrary_Server, signature, sizeof(signature) - 1);
  PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
  PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);

  if (!(g_SDKGetAttributeDefinitionByName = EndPrepSDKCall()))
  {
    SetFailState("Method \"CEconItemSchema::GetAttributeDefinitionByName\" was not loaded right.");
    return;
  }
}

public Action:SetupGenerateAttribute()
{
  StartPrepSDKCall(SDKCall_Raw);
  // CEconItemSystem::GenerateAttribute
  char signature[] = "\x55\x89\xE5\x56\x53\x8B\x5D\x0C\x83\xEC\x0C\x6A\x18";
  PrepSDKCall_SetSignature(SDKLibrary_Server, signature, sizeof(signature) - 1);
  PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
  PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
  PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);

  if (!(g_SDKGenerateAttribute = EndPrepSDKCall()))
  {
    SetFailState("Method \"CEconItemSystem::GenerateAttribute\" was not loaded right.");
    return;
  }
}

public Action:SetupAddAttribute()
{
  StartPrepSDKCall(SDKCall_Raw);
  // CAttributeList::AddAttribute
  char signature[] = "\x55\x89\xE5\x57\x56\x53\x83\xEC\x1C\x8B\x5D\x0C\x8B\x75\x08\x0F\xB7\x7B\x04";
  PrepSDKCall_SetSignature(SDKLibrary_Server, signature, sizeof(signature) - 1);
  PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);

  if (!(g_SDKAddAttribute = EndPrepSDKCall()))
  {
    SetFailState("Method \"CAttributeList::AddAttribute\" was not loaded right.");
    return;
  }
}

public Action:SetSticker(client, args)
{
  if (GetCmdArgs() < 2)
  {
    ReplyToCommand(client, "Need at least 2 arguments (slot, index, wear, scale, rotation)");
    return Plugin_Handled;
  }

  new String:slotString[64], String:indexString[64], String:wearString[64], String:scaleString[64], String:rotationString[64];
  new slot, index, Float:wear, Float:scale, Float:rotation;
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

  slot = StringToInt(slotString);
  index = StringToInt(indexString);
  wear = StringToFloat(wearString);
  scale = StringToFloat(scaleString);
  rotation = StringToFloat(rotationString);

  PrintToServer("SetSticker slot=%d, index=%d, wear=%f, scale=%f, rotation=%f", slot, index, wear, scale, rotation);

  new weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

  if (GetEntProp(weapon, Prop_Send, "m_iItemIDHigh") < 16384)
  {
    static int IDHigh = 16384;
    SetEntProp(weapon, Prop_Send, "m_iItemIDLow", -1);
    SetEntProp(weapon, Prop_Send, "m_iItemIDHigh", IDHigh++);
    SetEntProp(weapon, Prop_Send, "m_iAccountID", GetSteamAccountID(client, true));
    SetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity", client);
    SetEntPropEnt(weapon, Prop_Send, "m_hPrevOwner", -1);
  }

  Address pWeapon = GetEntityAddress(weapon);
  if (pWeapon == Address_Null)
  {
    ReplyToCommand(client, "weapon address not found");
    return Plugin_Handled;
  }

  Address pEconItemView = pWeapon + view_as<Address>(g_econItemOffset);
  SetAttributeValue(client, pEconItemView, index, "sticker slot %i id", slot);
  SetAttributeValue(client, pEconItemView, view_as<int>(wear), "sticker slot %i wear", slot);
  SetAttributeValue(client, pEconItemView, view_as<int>(scale), "sticker slot %i scale", slot);
  SetAttributeValue(client, pEconItemView, view_as<int>(rotation), "sticker slot %i rotation", slot);

  PTaH_ForceFullUpdate(client);

  return Plugin_Handled;
}

stock bool SetAttributeValue(int client, Address pEconItemView, int attrValue, const char[] format, any ...)
{
  char attr[254];
  VFormat(attr, sizeof(attr), format, 5);

  Address pAttributeDef = SDKCall(g_SDKGetAttributeDefinitionByName, g_pItemSchema, attr);
  if (pAttributeDef == Address_Null)
  {
    PrintToChat(client, "[SM] Invalid item attribute definition, contact an administrator.");
    return false;
  }

  // Get item attribute list.
  Address pAttributeList = pEconItemView + view_as<Address>(g_networkedDynamicAttributesOffset);

  // Get attribute data.
  int attrDefIndex = LoadFromAddress(pAttributeDef + view_as<Address>(0x8), NumberType_Int16);
  int attrCount = LoadFromAddress(pAttributeList + view_as<Address>(g_attributeListCountOffset), NumberType_Int32);
  Address pAttrData = DereferencePointer(pAttributeList + view_as<Address>(g_attributeListReadOffset));

  // Checks if the item already has the attribute, then update value.
  int k = 0;
  for (int i = 0; i < attrCount; i++)
  {
    Address pAttribute = pAttrData + view_as<Address>(k);

    int defIndex = LoadFromAddress(pAttribute + view_as<Address>(0x4), NumberType_Int16);
    if (defIndex == attrDefIndex)
    {
      // Checks if the value is different.
      int value = LoadFromAddress(pAttribute + view_as<Address>(0x8), NumberType_Int32);
      if (value != attrValue)
      {
        StoreToAddress(pAttribute + view_as<Address>(0x8), attrValue, NumberType_Int32);
        return true;
      }
      return false;
    }

    // Increment index.
    k += 24;
  }

  // Didn't find it. Add a new one.
  Address pAttribute = SDKCall(g_SDKGenerateAttribute, g_pItemSystem, attrDefIndex, view_as<float>(attrValue));
  if (IsValidAddress(pAttribute))
  {
    // Attach attribute in weapon.
    SDKCall(g_SDKAddAttribute, pAttributeList, pAttribute);
    return true;
  }
  return false;
}

stock int FindSendPropOffset(char[] cls, char[] prop)
{
  int offset;
  if ((offset = FindSendPropInfo(cls, prop)) < 1)
  {
    SetFailState("Failed to find prop: \"%s\" on \"%s\" class.", prop, cls);
  }
  return offset;
}

stock bool IsValidAddress(Address pAddress)
{
  static Address Address_MinimumValid = view_as<Address>(0x10000);
  if (pAddress == Address_Null)
  {
    return false;
  }
  return unsigned_compare(view_as<int>(pAddress), view_as<int>(Address_MinimumValid)) >= 0;
}

stock int unsigned_compare(int a, int b)
{
  if (a == b)
  {
    return 0;
  }

  if ((a >>> 31) == (b >>> 31))
  {
    return ((a & 0x7FFFFFFF) > (b & 0x7FFFFFFF)) ? 1 : -1;
  }
  return ((a >>> 31) > (b >>> 31)) ? 1 : -1;
}

stock Address DereferencePointer(Address addr)
{
  return view_as<Address>(LoadFromAddress(addr, NumberType_Int32));
}
