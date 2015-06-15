#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>
#include <clientprefs>
#include <multicolors>

#undef REQUIRE_PLUGIN
#include <lastrequest>

#define MAX_PAINTS 800

public Plugin:myinfo =
{
	name = "SM CS:GO Change Skin",
	author = "Andreas Mausch",
	description = "",
	version = "1.0",
	url = "http://andreas-mausch.github.io/"
};

public OnPluginStart()
{
	RegConsoleCmd("sm_changeskin", MyChangeSkin);

	for (new client = 1; client <= MaxClients; client++)
	{
		if (!IsClientInGame(client))
			continue;
			
		OnClientPutInServer(client);
	}
}

public Action:MyChangeSkin(client, args)
{
	if (GetCmdArgs() != 6)
	{
		ReplyToCommand(client, "Need 6 arguments (weapon, paint, wear, stattrak, quality, seed)");
		return Plugin_Handled;
	}

	new String:arg1[64], String:arg2[32], String:arg3[32], String:arg4[32], String:arg5[32], String:arg6[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	GetCmdArg(3, arg3, sizeof(arg3));
	GetCmdArg(4, arg4, sizeof(arg4));
	GetCmdArg(5, arg5, sizeof(arg5));
	GetCmdArg(6, arg6, sizeof(arg6));

	new new_paint, new_stattrak, new_quality, new_seed;
	new Float:new_wear;
	new String:new_weapon[64];

	new_weapon = arg1;
	new_paint = StringToInt(arg2);
	new_wear = StringToFloat(arg3);
	new_stattrak = StringToInt(arg4);
	new_quality = StringToInt(arg5);
	new_seed = StringToInt(arg6);

	RemoveWeapons(client);
	new knife = GivePlayerItem(client, new_weapon);
	EquipPlayerWeapon(client, knife);

	PrintToServer("MyChangeSkin weapon=%s, paint=%d, wear=%f, stattrak=%d, quality=%d, seed=%d", new_weapon, new_paint, new_wear, new_stattrak, new_quality, new_seed);

	ChangeSkinTo(client, new_paint, new_wear, new_stattrak, new_quality, new_seed);

	return Plugin_Handled;
}

RemoveWeapons(client)
{
	new weapon = -1;
	for (new i = 0; i <= 5; i++)
	{
		if ((weapon = GetPlayerWeaponSlot(client, i)) != INVALID_ENT_REFERENCE)
		{
			RemovePlayerItem(client, weapon);
		}
	}
}

ChangeSkinTo(client, new_paint, Float:new_wear, new_stattrak, new_quality, new_seed)
{
	if(!IsPlayerAlive(client))
	{
		ReplyToCommand(client, "You cant use this when you are dead");
		return;
	}

	new windex = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(windex < 1)
	{
		ReplyToCommand(client, "You cant use a paint on this weapon");
		return;
	}

	decl String:Classname[64];
	GetEdictClassname(windex, Classname, 64);

	if(StrEqual(Classname, "weapon_taser"))
	{
		ReplyToCommand(client, "You cant use a paint on this weapon");
		return;
	}

	new weaponindex = GetEntProp(windex, Prop_Send, "m_iItemDefinitionIndex");
	if(weaponindex == 42 || weaponindex == 59)
	{
		ReplyToCommand(client, "You cant use a paint on this weapon");
		return;
	}

	if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == windex || GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) == windex || GetPlayerWeaponSlot(client, CS_SLOT_KNIFE) == windex || GetPlayerWeaponSlot(client, CS_SLOT_C4) == windex)
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
		ChangePaint2(client, windex, Classname, weaponindex, new_paint, new_wear, new_stattrak, new_quality, new_seed);
		FakeClientCommand(client, "use %s", Classname);
	}
	else ReplyToCommand(client, "You cant use a paint in this weapon");
}

ChangePaint2(client, windex, String:Classname[64], weaponindex, new_paint, Float:new_wear, new_stattrak, new_quality, new_seed)
{
	new bool:knife = false;
	if(StrContains(Classname, "weapon_knife", false) == 0 || StrContains(Classname, "weapon_bayonet", false) == 0)
	{
		knife = true;
	}

	//PrintToChat(client, "weapon %s", Classname);
	new ammo, clip;
	if(!knife)
	{
		ammo = GetReserveAmmo(client, windex);
		clip = GetEntProp(windex, Prop_Send, "m_iClip1");
	}
	RemovePlayerItem(client, windex);
	AcceptEntityInput(windex, "Kill");

	new Handle:pack;
	new entity = GivePlayerItem(client, Classname);

	if(knife)
	{
		if (weaponindex != 42 && weaponindex != 59)
			EquipPlayerWeapon(client, entity);
	}
	else
	{
		SetReserveAmmo(client, windex, ammo);
		SetEntProp(entity, Prop_Send, "m_iClip1", clip);
	}

	new m_iItemIDHigh = GetEntProp(entity, Prop_Send, "m_iItemIDHigh");
	new m_iItemIDLow = GetEntProp(entity, Prop_Send, "m_iItemIDLow");

	SetEntProp(entity,Prop_Send,"m_iItemIDLow",2048);
	SetEntProp(entity,Prop_Send,"m_iItemIDHigh",0);

	SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", new_paint);
	SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", new_wear);
	SetEntProp(entity, Prop_Send, "m_nFallbackStatTrak", new_stattrak);
	SetEntProp(entity, Prop_Send, "m_iEntityQuality", new_quality);
	SetEntProp(entity, Prop_Send, "m_nFallbackSeed", new_seed);

	CreateDataTimer(0.2, RestoreItemID, pack);
	WritePackCell(pack,EntIndexToEntRef(entity));
	WritePackCell(pack,m_iItemIDHigh);
	WritePackCell(pack,m_iItemIDLow);
}

public OnClientPutInServer(client)
{
	if(!IsFakeClient(client)) SDKHook(client, SDKHook_WeaponEquipPost, OnPostWeaponEquip);
}

public Action:OnPostWeaponEquip(client, weapon)
{
	new Handle:pack;
	CreateDataTimer(0.0, Pasado, pack);
	WritePackCell(pack,EntIndexToEntRef(weapon));
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

stock GetReserveAmmo(client, weapon)
{
	new ammotype = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
	if(ammotype == -1) return -1;

	return GetEntProp(client, Prop_Send, "m_iAmmo", _, ammotype);
}

stock SetReserveAmmo(client, weapon, ammo)
{
	new ammotype = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
	if(ammotype == -1) return;

	SetEntProp(client, Prop_Send, "m_iAmmo", ammo, _, ammotype);
}

public Action:RestoreItemID(Handle:timer, Handle:pack)
{
	new entity;
	new m_iItemIDHigh;
	new m_iItemIDLow;

	ResetPack(pack);
	entity = EntRefToEntIndex(ReadPackCell(pack));
	m_iItemIDHigh = ReadPackCell(pack);
	m_iItemIDLow = ReadPackCell(pack);

	if(entity != INVALID_ENT_REFERENCE)
	{
		SetEntProp(entity,Prop_Send,"m_iItemIDHigh",m_iItemIDHigh);
		SetEntProp(entity,Prop_Send,"m_iItemIDLow",m_iItemIDLow);
	}
}
