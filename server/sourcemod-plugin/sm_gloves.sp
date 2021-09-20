public Action:ChangeGloves(client, args)
{
  if (GetCmdArgs() != 3)
  {
    ReplyToCommand(client, "Need 3 arguments (index, paint, wear)");
    return Plugin_Handled;
  }

  new String:indexString[64], String:paintString[64], String:wearString[64], index, paint, Float:wear;
  GetCmdArg(1, indexString, sizeof(indexString));
  GetCmdArg(2, paintString, sizeof(paintString));
  GetCmdArg(3, wearString, sizeof(wearString));
  index = StringToInt(indexString);
  paint = StringToInt(paintString);
  wear = StringToFloat(wearString);

  PrintToServer("ChangeGloves index=%d, paint=%d, wear=%f", index, paint, wear);

  int activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
  if(activeWeapon != -1)
  {
    SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", -1);
  }

  int gloves = GetEntPropEnt(client, Prop_Send, "m_hMyWearables");

  if(gloves != -1)
  {
    AcceptEntityInput(gloves, "KillHierarchy");
  }

  gloves = CreateEntityByName("wearable_item");
  SetEntProp(gloves, Prop_Send, "m_iItemIDLow", -1);
  SetEntProp(gloves, Prop_Send, "m_iItemDefinitionIndex", index);
  SetEntProp(gloves, Prop_Send,  "m_nFallbackPaintKit", paint);
  SetEntPropFloat(gloves, Prop_Send, "m_flFallbackWear", wear);
  SetEntPropEnt(gloves, Prop_Data, "m_hOwnerEntity", client);
  SetEntPropEnt(gloves, Prop_Data, "m_hParent", client);
  SetEntProp(gloves, Prop_Send, "m_bInitialized", 1);

  DispatchSpawn(gloves);
  SetEntPropEnt(client, Prop_Send, "m_hMyWearables", gloves);

  if(activeWeapon != -1)
  {
    new Handle:pack;
    CreateDataTimer(0.2, ResetGloves, pack);
    WritePackCell(pack, client);
    WritePackCell(pack, activeWeapon);
  }

  return Plugin_Handled;
}

public Action:ResetGloves(Handle:timer, Handle:pack)
{
  new client;
  new activeWeapon;

  ResetPack(pack);
  client = ReadPackCell(pack);
  activeWeapon = ReadPackCell(pack);

  if(IsClientInGame(client) && IsValidEntity(activeWeapon))
  {
    SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", activeWeapon);
  }
}
