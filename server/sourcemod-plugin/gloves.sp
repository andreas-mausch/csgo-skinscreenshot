public Action:ChangeGloves(client, args) {
  if (GetCmdArgs() != 4) {
    ReplyToCommand(client, "Need 4 arguments (index, paint, wear, seed)");
    return Plugin_Handled;
  }

  char indexString[64], paintString[64], wearString[64], seedString[32];
  GetCmdArg(1, indexString, sizeof(indexString));
  GetCmdArg(2, paintString, sizeof(paintString));
  GetCmdArg(3, wearString, sizeof(wearString));
  GetCmdArg(4, seedString, sizeof(seedString));

  int index = StringToInt(indexString);
  int paint = StringToInt(paintString);
  float wear = StringToFloat(wearString);
  int seed = StringToInt(seedString);

  PrintToServer("ChangeGloves index=%d, paint=%d, wear=%f, seed=%d", index, paint, wear, seed);

  int activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
  if(activeWeapon != -1) {
    SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", -1);
  }

  int gloves = GetEntPropEnt(client, Prop_Send, "m_hMyWearables");

  if(gloves != -1) {
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
  SetEntProp(gloves, Prop_Send, "m_nFallbackSeed", seed);

  DispatchSpawn(gloves);
  SetEntPropEnt(client, Prop_Send, "m_hMyWearables", gloves);

  if(activeWeapon != -1) {
    new Handle:pack;
    CreateDataTimer(0.2, ResetGloves, pack);
    WritePackCell(pack, client);
    WritePackCell(pack, activeWeapon);
  }

  return Plugin_Handled;
}

public Action:ResetGloves(Handle:timer, Handle:pack) {
  ResetPack(pack);
  int client = ReadPackCell(pack);
  int activeWeapon = ReadPackCell(pack);

  if(IsClientInGame(client) && IsValidEntity(activeWeapon)) {
    SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", activeWeapon);
  }
}
