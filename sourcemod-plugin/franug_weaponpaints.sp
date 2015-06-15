#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>
#include <clientprefs>
#include <multicolors>

#undef REQUIRE_PLUGIN
#include <lastrequest>

#define MAX_PAINTS 800

enum Listado
{
	String:Nombre[64],
	index,
	Float:wear,
	stattrak,
	quality
}

new Handle:c_Game = INVALID_HANDLE;
new Handle:c_Game2 = INVALID_HANDLE;

new Handle:menuw = INVALID_HANDLE;
new g_paints[MAX_PAINTS][Listado];
new g_paintCount = 0;
new String:path_paints[PLATFORM_MAX_PATH];

new bool:g_hosties = false;

new bool:g_c4;
new Handle:cvar_c4;

#define DATA "1.6.4"

new Handle:arbol[MAXPLAYERS+1];

new Handle:saytimer;
new Handle:cvar_saytimer;
new g_saytimer;

new Handle:rtimer;
new Handle:cvar_rtimer;
new g_rtimer;

new Handle:cvar_rmenu;
new g_rmenu;

public Plugin:myinfo =
{
	name = "SM CS:GO Weapon Paints",
	author = "Franc1sco franug",
	description = "",
	version = DATA,
	url = "http://www.claninspired.com/"
};

public OnPluginStart()
{
	LoadTranslations ("franug_weaponpaints.phrases");
	c_Game = RegClientCookie("Paints_v6_part1", "Paints_v6_part1", CookieAccess_Private);
	c_Game2 = RegClientCookie("Paints_v6_part2", "Paints_v6_part2", CookieAccess_Private);
	
	CreateConVar("sm_wpaints_version", DATA, "", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_CHEAT|FCVAR_DONTRECORD);
	
	HookEvent("round_start", roundStart);
	
	RegConsoleCmd("buyammo1", GetSkins);
	
	RegAdminCmd("sm_reloadwskins", ReloadSkins, ADMFLAG_ROOT);
	
	for (new client = 1; client <= MaxClients; client++)
	{
		if (!IsClientInGame(client))
			continue;
			
		OnClientPutInServer(client);
		
		if(!AreClientCookiesCached(client))
			continue;
			
		OnClientCookiesCached(client);
	}
	
	cvar_c4 = CreateConVar("sm_weaponpaints_c4", "1", "Enable or disable that people can apply paints to the C4. 1 = enabled, 0 = disabled");
	cvar_saytimer = CreateConVar("sm_weaponpaints_saytimer", "10", "Time in seconds for block that show the plugin commands in chat when someone type a command. -1.0 = never show the commands in chat");
	cvar_rtimer = CreateConVar("sm_weaponpaints_roundtimer", "20", "Time in seconds roundstart for can use the commands for change the paints. -1.0 = always can use the command");
	cvar_rmenu = CreateConVar("sm_weaponpaints_rmenu", "1", "Re-open the menu when you select a option. 1 = enabled, 0 = disabled.");
	
	g_c4 = GetConVarBool(cvar_c4);
	g_saytimer = GetConVarInt(cvar_saytimer);
	g_rtimer = GetConVarInt(cvar_rtimer);
	g_rmenu = GetConVarBool(cvar_rmenu);
	
	HookConVarChange(cvar_c4, OnConVarChanged);
	HookConVarChange(cvar_saytimer, OnConVarChanged);
	HookConVarChange(cvar_rtimer, OnConVarChanged);
	HookConVarChange(cvar_rmenu, OnConVarChanged);
	
	ReadPaints();
}

public OnConVarChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if (convar == cvar_c4)
	{
		g_c4 = bool:StringToInt(newValue);
	}
	else if (convar == cvar_saytimer)
	{
		g_saytimer = StringToInt(newValue);
	}
	else if (convar == cvar_rtimer)
	{
		g_rtimer = StringToInt(newValue);
	}
	else if (convar == cvar_rmenu)
	{
		g_rmenu = bool:StringToInt(newValue);
	}
}

public OnPluginEnd()
{
	for(new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			OnClientDisconnect(client);
		}
	}
}

public OnClientCookiesCached(client)
{
	decl String:cookie1[100], String:cookie2[100];
	GetClientCookie(client, c_Game, cookie1, sizeof(cookie1));
	GetClientCookie(client, c_Game2, cookie2, sizeof(cookie2));
	
	if(strlen(cookie1) < 3) Format(cookie1, sizeof(cookie1), "0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;");
	if(strlen(cookie2) < 3) Format(cookie2, sizeof(cookie2), "0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;");
	
	CrearArbol(client, cookie1, cookie2);
}

public OnClientDisconnect(client)
{	
	if(AreClientCookiesCached(client))
	{
		SaveCookies(client);
	}
	if(arbol[client] != INVALID_HANDLE)
	{
		ClearTrie(arbol[client]);
		CloseHandle(arbol[client]);
		arbol[client] = INVALID_HANDLE;
	}
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	MarkNativeAsOptional("IsClientInLastRequest");

	return APLRes_Success;
}

public OnLibraryAdded(const String:name[])
{
	if (StrEqual(name, "hosties"))
	{
		g_hosties = true;
	}
}

public OnLibraryRemoved(const String:name[])
{
	if (StrEqual(name, "hosties"))
	{
		g_hosties = false;
	}
}

public Action:ReloadSkins(client, args)
{	
	ReadPaints();
	ReplyToCommand(client, " \x04[WP]\x01 %T","Weapon paints reloaded", client);
	
	return Plugin_Handled;
}

ShowMenu(client, item)
{
	SetMenuTitle(menuw, "%T","Menu title", client);
	
	RemoveMenuItem(menuw, 1);
	RemoveMenuItem(menuw, 0);
	decl String:tdisplay[64];
	Format(tdisplay, sizeof(tdisplay), "%T", "Random paint", client);
	InsertMenuItem(menuw, 0, "-1", tdisplay);
	Format(tdisplay, sizeof(tdisplay), "%T", "Default paint", client);
	InsertMenuItem(menuw, 1, "0", tdisplay);
	
	DisplayMenuAtItem(menuw, client, item, 0);
}

public Action:GetSkins(client, args)
{	
	ShowMenu(client, 0);
	
	return Plugin_Handled;
}

public Action:OnClientSayCommand(client, const String:command[], const String:sArgs[])
{
    if(StrEqual(sArgs, "!wskins", false) || StrEqual(sArgs, "!ws", false) || StrEqual(sArgs, "!paints", false))
	{

		ShowMenu(client, 0);
		
		if(saytimer != INVALID_HANDLE || g_saytimer == -1) return Plugin_Handled;
		saytimer = CreateTimer(1.0*g_saytimer, Tsaytimer);
		return Plugin_Continue;
		
	}
	else if(StrEqual(sArgs, "!ss", false) || StrEqual(sArgs, "!showskin", false))
	{
		ShowSkin(client);
		
		if(saytimer != INVALID_HANDLE || g_saytimer == -1) return Plugin_Handled;
		saytimer = CreateTimer(1.0*g_saytimer, Tsaytimer);
		return Plugin_Continue;
	}
    
    return Plugin_Continue;
}

ShowSkin(client)
{
	new weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon < 1 || !IsValidEdict(weapon) || !IsValidEntity(weapon))
	{
		CPrintToChat(client, " {green}[WP]{default} %T", "Paint not found", client);
		return;
	}
	
	new buscar = GetEntProp(weapon,Prop_Send,"m_nFallbackPaintKit");
	for(new i=1; i<g_paintCount;i++)
	{
		if(buscar == g_paints[i][index])
		{
			CPrintToChat(client, " {green}[WP]{default} %T", "Paint found", client, g_paints[i][Nombre]);
			return;
		}
	}
	
	CPrintToChat(client, " {green}[WP]{default} %T", "Paint not found", client);
}

public Action:Tsaytimer(Handle:timer)
{
	saytimer = INVALID_HANDLE;
}

public Action:roundStart(Handle:event, const String:name[], bool:dontBroadcast) 
{
	if(g_rtimer == -1) return;
	
	if(rtimer != INVALID_HANDLE)
	{
		KillTimer(rtimer);
		rtimer = INVALID_HANDLE;
	}
	
	rtimer = CreateTimer(1.0*g_rtimer, Rtimer);
}

public Action:Rtimer(Handle:timer)
{
	rtimer = INVALID_HANDLE;
}

public DIDMenuHandler(Handle:menu, MenuAction:action, client, itemNum) 
{
	if ( action == MenuAction_Select ) 
	{
		if(rtimer == INVALID_HANDLE && g_rtimer != -1)
		{
			CPrintToChat(client, " {green}[WP]{default} %T", "You can use this command only the first seconds", client, g_rtimer);
			if(g_rmenu) ShowMenu(client, GetMenuSelectionPosition());
			return;
		}
		if(!IsPlayerAlive(client))
		{
			CPrintToChat(client, " {green}[WP]{default} %t", "You cant use this when you are dead");
			if(g_rmenu) ShowMenu(client, GetMenuSelectionPosition());
			return;
		}
		if(g_hosties && IsClientInLastRequest(client))
		{
			CPrintToChat(client, " {green}[WP]{default} %t", "You cant use this when you are in a lastrequest");
			if(g_rmenu) ShowMenu(client, GetMenuSelectionPosition());
			return;
		}
		
		decl String:info[4];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		new theindex = StringToInt(info);
		
		new windex = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(windex < 1)
		{
			CPrintToChat(client, " {green}[WP]{default} %t", "You cant use a paint in this weapon");
			if(g_rmenu) ShowMenu(client, GetMenuSelectionPosition());
			return;
		}
		
		decl String:Classname[64];
		GetEdictClassname(windex, Classname, 64);
		
		if(StrEqual(Classname, "weapon_taser"))
		{
			CPrintToChat(client, " {green}[WP]{default} %t", "You cant use a paint in this weapon");
			if(g_rmenu) ShowMenu(client, GetMenuSelectionPosition());
			return;
		}
		new weaponindex = GetEntProp(windex, Prop_Send, "m_iItemDefinitionIndex");
		if(weaponindex == 42 || weaponindex == 59)
		{
			CPrintToChat(client, " {green}[WP]{default} %t", "You cant use a paint in this weapon");
			if(g_rmenu) ShowMenu(client, GetMenuSelectionPosition());
			return;
		}
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == windex || GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) == windex || GetPlayerWeaponSlot(client, CS_SLOT_KNIFE) == windex || (g_c4 && GetPlayerWeaponSlot(client, CS_SLOT_C4) == windex))
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
			SetTrieValue(arbol[client], Classname, theindex);
			ChangePaint(client, windex, Classname, weaponindex);
			FakeClientCommand(client, "use %s", Classname);
			if(theindex == 0) CPrintToChat(client, " {green}[WP]{default} %t","You have choose your default paint for your", Classname);
			else if(theindex == -1) CPrintToChat(client, " {green}[WP]{default} %t","You have choose a random paint for your", Classname);
			else CPrintToChat(client, " {green}[WP]{default} %t", "You have choose a weapon", g_paints[theindex][Nombre], Classname);
		}
		else CPrintToChat(client, " {green}[WP]{default} %t", "You cant use a paint in this weapon");
		
		if(g_rmenu) ShowMenu(client, GetMenuSelectionPosition());
		
	}
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

ReadPaints()
{
	BuildPath(Path_SM, path_paints, sizeof(path_paints), "configs/csgo_wpaints.cfg");
	
	decl Handle:kv;
	g_paintCount = 1;

	kv = CreateKeyValues("Paints");
	FileToKeyValues(kv, path_paints);

	if (!KvGotoFirstSubKey(kv)) {

		SetFailState("CFG File not found: %s", path_paints);
		CloseHandle(kv);
	}
	do {

		KvGetSectionName(kv, g_paints[g_paintCount][Nombre], 64);
		g_paints[g_paintCount][index] = KvGetNum(kv, "paint", 0);
		g_paints[g_paintCount][wear] = KvGetFloat(kv, "wear", -1.0);
		g_paints[g_paintCount][stattrak] = KvGetNum(kv, "stattrak", -2);
		g_paints[g_paintCount][quality] = KvGetNum(kv, "quality", -2);

		g_paintCount++;
	} while (KvGotoNextKey(kv));
	CloseHandle(kv);
	
	if(menuw != INVALID_HANDLE) CloseHandle(menuw);
	menuw = INVALID_HANDLE;
	
	menuw = CreateMenu(DIDMenuHandler);
	
	// TROLLING
	SetMenuTitle(menuw, "( ͡° ͜ʖ ͡°)");
	decl String:item[4];
	AddMenuItem(menuw, "-1", "Random paint");
	AddMenuItem(menuw, "0", "Default paint"); 
	// FORGET THIS
	
	for (new i=1; i<g_paintCount; ++i) {
		Format(item, 4, "%i", i);
		AddMenuItem(menuw, item, g_paints[i][Nombre]);
	}
	SetMenuExitButton(menuw, true);
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

ChangePaint(client, windex, String:Classname[64], weaponindex)
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
	new theindex;
	GetTrieValue(arbol[client], Classname, theindex);
	if(theindex == 0) return;

	if(theindex == -1)
	{
		theindex = GetRandomInt(1, g_paintCount-1);
	}
	
	new m_iItemIDHigh = GetEntProp(entity, Prop_Send, "m_iItemIDHigh");
	new m_iItemIDLow = GetEntProp(entity, Prop_Send, "m_iItemIDLow");

	SetEntProp(entity,Prop_Send,"m_iItemIDLow",2048);
	SetEntProp(entity,Prop_Send,"m_iItemIDHigh",0);

	SetEntProp(entity,Prop_Send,"m_nFallbackPaintKit",g_paints[theindex][index]);
	if(g_paints[theindex][wear] >= 0.0) SetEntPropFloat(entity,Prop_Send,"m_flFallbackWear",g_paints[theindex][wear]);
	if(g_paints[theindex][stattrak] != -2) SetEntProp(entity,Prop_Send,"m_nFallbackStatTrak",g_paints[theindex][stattrak]);
	if(g_paints[theindex][quality] != -2) SetEntProp(entity,Prop_Send,"m_iEntityQuality",g_paints[theindex][quality]);
	

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
    
	if(weapon == INVALID_ENT_REFERENCE || !IsClientInGame(client) || !IsPlayerAlive(client) || (g_hosties && IsClientInLastRequest(client))) return;
	
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
	if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == weapon || GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) == weapon || GetPlayerWeaponSlot(client, CS_SLOT_KNIFE) == weapon || (g_c4 && GetPlayerWeaponSlot(client, CS_SLOT_C4) == weapon))
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
		GetTrieValue(arbol[client], Classname, valor);
		if(valor == 0) return;
		//PrintToChat(client, "prueba");
		ChangePaint(client, weapon, Classname, weaponindex);
	}
}

CrearArbol(client, String:cookie1[100], String:cookie2[100])
{
	arbol[client] = CreateTrie();

	decl String:parte1[23][4];
	ExplodeString(cookie1, ";", parte1, sizeof(parte1), sizeof(parte1[]));
	
	SetTrieValue(arbol[client], "weapon_negev", StringToInt(parte1[0]));
	SetTrieValue(arbol[client], "weapon_m249", StringToInt(parte1[1]));
	SetTrieValue(arbol[client], "weapon_bizon", StringToInt(parte1[2]));
	SetTrieValue(arbol[client], "weapon_p90", StringToInt(parte1[3]));
	SetTrieValue(arbol[client], "weapon_scar20", StringToInt(parte1[4]));
	SetTrieValue(arbol[client], "weapon_g3sg1", StringToInt(parte1[5]));
	SetTrieValue(arbol[client], "weapon_m4a1", StringToInt(parte1[6]));
	SetTrieValue(arbol[client], "weapon_m4a1_silencer", StringToInt(parte1[7]));
	SetTrieValue(arbol[client], "weapon_ak47", StringToInt(parte1[8]));
	SetTrieValue(arbol[client], "weapon_aug", StringToInt(parte1[9]));
	SetTrieValue(arbol[client], "weapon_galilar", StringToInt(parte1[10]));
	SetTrieValue(arbol[client], "weapon_awp", StringToInt(parte1[11]));
	SetTrieValue(arbol[client], "weapon_sg556", StringToInt(parte1[12]));
	SetTrieValue(arbol[client], "weapon_ump45", StringToInt(parte1[13]));
	SetTrieValue(arbol[client], "weapon_mp7", StringToInt(parte1[14]));
	SetTrieValue(arbol[client], "weapon_famas", StringToInt(parte1[15]));
	SetTrieValue(arbol[client], "weapon_mp9", StringToInt(parte1[16]));
	SetTrieValue(arbol[client], "weapon_mac10", StringToInt(parte1[17]));
	SetTrieValue(arbol[client], "weapon_ssg08", StringToInt(parte1[18]));
	SetTrieValue(arbol[client], "weapon_nova", StringToInt(parte1[19]));
	SetTrieValue(arbol[client], "weapon_xm1014", StringToInt(parte1[20]));
	SetTrieValue(arbol[client], "weapon_sawedoff", StringToInt(parte1[21]));
	SetTrieValue(arbol[client], "weapon_mag7", StringToInt(parte1[22]));
	
	
	decl String:parte2[17][4];
	ExplodeString(cookie2, ";", parte2, sizeof(parte2), sizeof(parte2[]));
	
	SetTrieValue(arbol[client], "weapon_elite", StringToInt(parte2[0]));
	SetTrieValue(arbol[client], "weapon_deagle", StringToInt(parte2[1]));
	SetTrieValue(arbol[client], "weapon_tec9", StringToInt(parte2[2]));
	SetTrieValue(arbol[client], "weapon_fiveseven", StringToInt(parte2[3]));
	SetTrieValue(arbol[client], "weapon_cz75a", StringToInt(parte2[4]));
	SetTrieValue(arbol[client], "weapon_glock", StringToInt(parte2[5]));
	SetTrieValue(arbol[client], "weapon_usp_silencer", StringToInt(parte2[6]));
	SetTrieValue(arbol[client], "weapon_p250", StringToInt(parte2[7]));
	SetTrieValue(arbol[client], "weapon_hkp2000", StringToInt(parte2[8]));
	SetTrieValue(arbol[client], "weapon_bayonet", StringToInt(parte2[9]));
	SetTrieValue(arbol[client], "weapon_knife_gut", StringToInt(parte2[10]));
	SetTrieValue(arbol[client], "weapon_knife_flip", StringToInt(parte2[11]));
	SetTrieValue(arbol[client], "weapon_knife_m9_bayonet", StringToInt(parte2[12]));
	SetTrieValue(arbol[client], "weapon_knife_karambit", StringToInt(parte2[13]));
	SetTrieValue(arbol[client], "weapon_knife_tactical", StringToInt(parte2[14]));
	SetTrieValue(arbol[client], "weapon_knife_butterfly", StringToInt(parte2[15]));
	SetTrieValue(arbol[client], "weapon_c4", StringToInt(parte2[16]));
	
	
}

SaveCookies(client)
{
	decl String:cookie1[100], String:cookie2[100];
	new valor;

	GetTrieValue(arbol[client], "weapon_negev", valor);
	Format(cookie1, sizeof(cookie1), "%i", valor);
		
	GetTrieValue(arbol[client], "weapon_m249", valor);
	Format(cookie1, sizeof(cookie1), "%s;%i", cookie1, valor);
		
	GetTrieValue(arbol[client], "weapon_bizon", valor);
	Format(cookie1, sizeof(cookie1), "%s;%i", cookie1, valor);
	
	GetTrieValue(arbol[client], "weapon_p90", valor);
	Format(cookie1, sizeof(cookie1), "%s;%i", cookie1, valor);
	
	GetTrieValue(arbol[client], "weapon_scar20", valor);
	Format(cookie1, sizeof(cookie1), "%s;%i", cookie1, valor);
	
	GetTrieValue(arbol[client], "weapon_g3sg1", valor);
	Format(cookie1, sizeof(cookie1), "%s;%i", cookie1, valor);
	
	GetTrieValue(arbol[client], "weapon_m4a1", valor);
	Format(cookie1, sizeof(cookie1), "%s;%i", cookie1, valor);
	
	GetTrieValue(arbol[client], "weapon_m4a1_silencer", valor);
	Format(cookie1, sizeof(cookie1), "%s;%i", cookie1, valor);
	
	GetTrieValue(arbol[client], "weapon_ak47", valor);
	Format(cookie1, sizeof(cookie1), "%s;%i", cookie1, valor);
	
	GetTrieValue(arbol[client], "weapon_aug", valor);
	Format(cookie1, sizeof(cookie1), "%s;%i", cookie1, valor);
	
	GetTrieValue(arbol[client], "weapon_galilar", valor);
	Format(cookie1, sizeof(cookie1), "%s;%i", cookie1, valor);
	
	GetTrieValue(arbol[client], "weapon_awp", valor);
	Format(cookie1, sizeof(cookie1), "%s;%i", cookie1, valor);
	
	GetTrieValue(arbol[client], "weapon_sg556", valor);
	Format(cookie1, sizeof(cookie1), "%s;%i", cookie1, valor);
	
	GetTrieValue(arbol[client], "weapon_ump45", valor);
	Format(cookie1, sizeof(cookie1), "%s;%i", cookie1, valor);
	
	GetTrieValue(arbol[client], "weapon_mp7", valor);
	Format(cookie1, sizeof(cookie1), "%s;%i", cookie1, valor);
	
	GetTrieValue(arbol[client], "weapon_famas", valor);
	Format(cookie1, sizeof(cookie1), "%s;%i", cookie1, valor);
	
	GetTrieValue(arbol[client], "weapon_mp9", valor);
	Format(cookie1, sizeof(cookie1), "%s;%i", cookie1, valor);
	
	GetTrieValue(arbol[client], "weapon_mac10", valor);
	Format(cookie1, sizeof(cookie1), "%s;%i", cookie1, valor);
	
	GetTrieValue(arbol[client], "weapon_ssg08", valor);
	Format(cookie1, sizeof(cookie1), "%s;%i", cookie1, valor);
	
	GetTrieValue(arbol[client], "weapon_nova", valor);
	Format(cookie1, sizeof(cookie1), "%s;%i", cookie1, valor);
	
	GetTrieValue(arbol[client], "weapon_xm1014", valor);
	Format(cookie1, sizeof(cookie1), "%s;%i", cookie1, valor);
	
	GetTrieValue(arbol[client], "weapon_sawedoff", valor);
	Format(cookie1, sizeof(cookie1), "%s;%i", cookie1, valor);
	
	GetTrieValue(arbol[client], "weapon_mag7", valor);
	Format(cookie1, sizeof(cookie1), "%s;%i", cookie1, valor);
	
	SetClientCookie(client, c_Game, cookie1);
	
	
	GetTrieValue(arbol[client], "weapon_elite", valor);
	Format(cookie2, sizeof(cookie2), "%i", valor);
		
	GetTrieValue(arbol[client], "weapon_deagle", valor);
	Format(cookie2, sizeof(cookie2), "%s;%i", cookie2, valor);
		
	GetTrieValue(arbol[client], "weapon_tec9", valor);
	Format(cookie2, sizeof(cookie2), "%s;%i", cookie2, valor);
	
	GetTrieValue(arbol[client], "weapon_fiveseven", valor);
	Format(cookie2, sizeof(cookie2), "%s;%i", cookie2, valor);
	
	GetTrieValue(arbol[client], "weapon_cz75a", valor);
	Format(cookie2, sizeof(cookie2), "%s;%i", cookie2, valor);
	
	GetTrieValue(arbol[client], "weapon_glock", valor);
	Format(cookie2, sizeof(cookie2), "%s;%i", cookie2, valor);
	
	GetTrieValue(arbol[client], "weapon_usp_silencer", valor);
	Format(cookie2, sizeof(cookie2), "%s;%i", cookie2, valor);
	
	GetTrieValue(arbol[client], "weapon_p250", valor);
	Format(cookie2, sizeof(cookie2), "%s;%i", cookie2, valor);
	
	GetTrieValue(arbol[client], "weapon_hkp2000", valor);
	Format(cookie2, sizeof(cookie2), "%s;%i", cookie2, valor);
	
	GetTrieValue(arbol[client], "weapon_bayonet", valor);
	Format(cookie2, sizeof(cookie2), "%s;%i", cookie2, valor);
	
	GetTrieValue(arbol[client], "weapon_knife_gut", valor);
	Format(cookie2, sizeof(cookie2), "%s;%i", cookie2, valor);
	
	GetTrieValue(arbol[client], "weapon_knife_flip", valor);
	Format(cookie2, sizeof(cookie2), "%s;%i", cookie2, valor);
	
	GetTrieValue(arbol[client], "weapon_knife_m9_bayonet", valor);
	Format(cookie2, sizeof(cookie2), "%s;%i", cookie2, valor);
	
	GetTrieValue(arbol[client], "weapon_knife_karambit", valor);
	Format(cookie2, sizeof(cookie2), "%s;%i", cookie2, valor);
	
	GetTrieValue(arbol[client], "weapon_knife_tactical", valor);
	Format(cookie2, sizeof(cookie2), "%s;%i", cookie2, valor);
	
	GetTrieValue(arbol[client], "weapon_knife_butterfly", valor);
	Format(cookie2, sizeof(cookie2), "%s;%i", cookie2, valor);
	
	GetTrieValue(arbol[client], "weapon_c4", valor);
	Format(cookie2, sizeof(cookie2), "%s;%i", cookie2, valor);
	
	SetClientCookie(client, c_Game2, cookie2);
}
