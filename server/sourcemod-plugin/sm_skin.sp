public Action:ChangeSkin(client, args) {
  if (GetCmdArgs() != 6) {
    ReplyToCommand(client, "Need 6 arguments (weapon, paint, wear, stattrak, quality, seed)");
    return Plugin_Handled;
  }

  char weapon[64], paintString[32], wearString[32], stattrakString[32], qualityString[32], seedString[32];
  GetCmdArg(1, weapon, sizeof(weapon));
  GetCmdArg(2, paintString, sizeof(paintString));
  GetCmdArg(3, wearString, sizeof(wearString));
  GetCmdArg(4, stattrakString, sizeof(stattrakString));
  GetCmdArg(5, qualityString, sizeof(qualityString));
  GetCmdArg(6, seedString, sizeof(seedString));

  int paint = StringToInt(paintString);
  float wear = StringToFloat(wearString);
  int stattrak = StringToInt(stattrakString);
  int quality = StringToInt(qualityString);
  int seed = StringToInt(seedString);

  PrintToServer("ChangeSkin weapon=%s, paint=%d, wear=%f, stattrak=%d, quality=%d, seed=%d", weapon, paint, wear, stattrak, quality, seed);

  RemoveWeapons(client);
  int entity = GivePlayerItem(client, weapon);

  if (entity == -1) {
    ReplyToCommand(client, "Couldn't give item to player: %s", weapon);
    return Plugin_Handled;
  }

  EquipPlayerWeapon(client, entity);

  ChangeSkinTo(client, entity, paint, wear, stattrak, quality, seed);

  return Plugin_Handled;
}

RemoveWeapons(int client) {
  for (int i = 0; i <= 5; i++) {
    int weapon = GetPlayerWeaponSlot(client, i);
    if (weapon != INVALID_ENT_REFERENCE) {
      RemovePlayerItem(client, weapon);
    }
  }
}

ChangeSkinTo(int client, int entity, int paint, float wear, int stattrak, int quality, int seed)
{
  if(!IsPlayerAlive(client)) {
    ReplyToCommand(client, "You cant use this when you are dead");
    return;
  }

  int activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
  if(activeWeapon < 1) {
    ReplyToCommand(client, "You cant use a paint on this weapon");
    return;
  }

  char classname[64];
  GetEdictClassname(activeWeapon, classname, 64);

  if (StrEqual(classname, "weapon_taser")) {
    ReplyToCommand(client, "You cant use a paint on this weapon");
    return;
  }

  int weaponIndex = GetEntProp(activeWeapon, Prop_Send, "m_iItemDefinitionIndex");
  // 42 = WEAPON_KNIFE (Default CT Knife)
  // 59 = WEAPON_KNIFE_T (Default T Knife)
  if (weaponIndex == 42 || weaponIndex == 59) {
    ReplyToCommand(client, "You cant use a paint on this weapon");
    return;
  }

  if (GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == activeWeapon ||
      GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) == activeWeapon ||
      GetPlayerWeaponSlot(client, CS_SLOT_KNIFE) == activeWeapon ||
      GetPlayerWeaponSlot(client, CS_SLOT_C4) == activeWeapon)
  {
    switch (weaponIndex)
    {
      case 60: strcopy(classname, 64, "weapon_m4a1_silencer");
      case 61: strcopy(classname, 64, "weapon_usp_silencer");
      case 63: strcopy(classname, 64, "weapon_cz75a");
      case 500: strcopy(classname, 64, "weapon_bayonet");
      case 506: strcopy(classname, 64, "weapon_knife_gut");
      case 505: strcopy(classname, 64, "weapon_knife_flip");
      case 508: strcopy(classname, 64, "weapon_knife_m9_bayonet");
      case 507: strcopy(classname, 64, "weapon_knife_karambit");
      case 509: strcopy(classname, 64, "weapon_knife_tactical");
      case 515: strcopy(classname, 64, "weapon_knife_butterfly");
    }
    ChangePaint2(client, entity, paint, wear, stattrak, quality, seed);
    FakeClientCommand(client, "use %s", classname);
  }
  else {
    ReplyToCommand(client, "You cant use a paint in this weapon");
  }
}

ChangePaint2(int client, int entity, int paint, float wear, int stattrak, int quality, int seed) {
  int m_iItemIDHigh = GetEntProp(entity, Prop_Send, "m_iItemIDHigh");
  int m_iItemIDLow = GetEntProp(entity, Prop_Send, "m_iItemIDLow");

  SetEntProp(entity, Prop_Send, "m_iItemIDLow", 2048);
  SetEntProp(entity, Prop_Send, "m_iItemIDHigh", 0);
  SetEntProp(entity, Prop_Send, "m_iAccountID", GetSteamAccountID(client, true));
  SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
  SetEntPropEnt(entity, Prop_Send, "m_hPrevOwner", -1);

  SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", paint);
  SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", wear);
  SetEntProp(entity, Prop_Send, "m_nFallbackStatTrak", stattrak);
  SetEntProp(entity, Prop_Send, "m_iEntityQuality", quality);
  SetEntProp(entity, Prop_Send, "m_nFallbackSeed", seed);

  Handle pack;
  CreateDataTimer(0.2, RestoreItemID, pack);
  WritePackCell(pack, EntIndexToEntRef(entity));
  WritePackCell(pack, m_iItemIDHigh);
  WritePackCell(pack, m_iItemIDLow);
}

Action RestoreItemID(Handle timer, Handle pack) {
  ResetPack(pack);
  int entity = EntRefToEntIndex(ReadPackCell(pack));
  int m_iItemIDHigh = ReadPackCell(pack);
  int m_iItemIDLow = ReadPackCell(pack);

  if (entity != INVALID_ENT_REFERENCE) {
    SetEntProp(entity, Prop_Send, "m_iItemIDHigh", m_iItemIDHigh);
    SetEntProp(entity, Prop_Send, "m_iItemIDLow", m_iItemIDLow);
  }

  return Plugin_Handled;
}
