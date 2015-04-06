/* TODO:
 - login.pwn -> Ustawienia
 - main -> premium (0 - none, 1 - premium, 2 - gold); premiumtime
 - main -> trusted (0 - false, 1 - true)
 - veh.pwn -> GPS (ikony ważnych miejsc)
 - door.pwn -> grunt = wielkość * cena strefy
 - door.pwn -> wycena domu = interior + gruntu
*/

#define Debug        		1
#define Forum               2
#define Locked              0
#define mapandreas          0
#define OFFICIAL            1
#define STREAMER            1
#define IN_VERSION    		"1.0.3"
#define today   			"08062014"

//forward OnClientCheckResponse(playerid, actionid, memaddr, retndata);
//native SendClientCheck(playerid, actionid, memaddr, memOffset, bytesCount);

#include "SURV_h.pwn"
/*
enum(<<= 1)
{
	NULL = 0,
  	SOBEIT = 0x5E8606,
};


public OnClientCheckResponse(playerid, actionid, memaddr, retndata)
{
	switch(retndata)
	{
   		case 0xA0: printf("*** GTA Gracza %s jest czyste! ***", NickName(playerid));
     	default:
 		{
          	SendClientMessage(playerid, -1, "{FF0000}Serwer wykrył u Ciebie niedozwolone pliki..");
          	SendClientMessage(playerid, -1, "{FF0000}Aby rozpocząć grę na serwerze usuń je z folderu GTA.");
            printf("*** SOBEIT - %s ***", NickName(playerid));
			Kick(playerid);
  		}
	}
} */

main()
{
	print("								");
	print("#############################");
 	print("								");
	print("   "IN_NAME"					");
	print("   Kacper Michewicz			");
	print("   2014						");
	print("   © All right reserved		");
	print("								");
	print("#############################");
	print("								");
}

public OnGameModeInit()
{
   	new count = GetTickCount();
   	MySQL_Connect();
	#if OFFICIAL
	    SetGameModeText("v"IN_VERSION", build: "today);
	#else
		SetGameModeText("DBG: v"IN_VERSION", build: "today);
	#endif
	AllowInteriorWeapons(true); 		// Bronie w interiorach
	EnableStuntBonusForAll(false); 		// Kasa za stunty
	ShowNameTags(false);				// Nametagi
	DisableInteriorEnterExits(); 		// Strzałki do domyślnych interiorów GTA
	ManualVehicleEngineAndLights(); 	// Światła i silnik wyłączony domyślnie
	//UsePlayerPedAnims();            	// Bieganie jak Carl Johnson!
	FadeInit();                         // Ładowanie zaciemnienia ekranu
	#if mapandreas
		MapAndreas_Init(MAP_ANDREAS_MODE_FULL);// Ładowanie pluginu MapAndreas
	#endif

	print("## Rozpoczynam wczytywanie danych!");
	if(mysql_ping() == -1)
	{
	    SendRconCommand("mapname ~MySQL Error~");
        print("[MySQL Error]: Brak połączenia z bazą danych!");
		return 1;
	}
	else print("# Połączono z bazą danych!");
	LoadSetting();
	Setting(setting_globtimer)	= SetTimer("GlobalTimer", 1000, 1);
	Setting(setting_opttimer)	= SetTimer("OptTimer", 100, 1);
	//LoadNPC();
	LoadVehicles();
	LoadTextDraws();
	LoadPickups();
	LoadDoors();
	LoadBus();
	LoadStation();
	LoadAnims();
	LoadStreets();
	LoadRadar();
	LoadGangZone();
	LoadGrunt();
	LoadSocket();
	LoadSkins();
	#if STREAMER
		LoadObjects();
	#endif
	new Float:czas = floatdiv(GetTickCount() - count, 1000);
	printf("## Dane wczytane pomyślnie! | Czas wykonywania: %.2f %s",
		czas,
		dli(floatval(czas), "sekunde", "sekundy", "sekund")
	);
	mysql_debug(1);
	
	//ACset_MoneyCheck(false);
	return 1;
}
/*
public AC_OnCheatDetected(playerid, cheat_type, ac_extra)
{
	printf("[AC] Coś wykryłem %d!", cheat_type);
	return 1;
}*/

public OnGameModeExit()
{
	#if Debug
	    print("OnGameModeExit()");
	#endif
    Audio_DestroyTCPServer();
    DOF2_Exit();
    FadeExit();
    #if mapandreas
		MapAndreas_Unload();
	#endif
	KillTimer(Setting(setting_globtimer));
	KillTimer(Setting(setting_opttimer));
    #if OFFICIAL
		for(new carid; carid != MAX_VEHICLES; carid++)
		{
		    if(!Vehicle(carid, vehicle_uid)) continue;
		    if(Vehicle(carid, vehicle_vehID) == INVALID_VEHICLE_ID) continue;
		    UnSpawnVeh(carid);
		}
		foreach(Server_Doors, doorid)
		{
		    SaveDoor(doorid);
		}
  	#endif
	foreach(Player, playerid)
	{
	    Player(playerid, player_spawned) = false;
		OnPlayerLoginOut(playerid);
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	if(playerid > MAX_PLAYERS) return Kick(playerid);
	
/*	new actionid = 0x5, memaddr = SOBEIT, retndata = 0x4;
	SendClientCheck(playerid, actionid, memaddr, NULL, retndata);
	switch(retndata)
	{
		case 10:
		{
        	printf("Użytkownik %s prawdopodobnie posiada s0beita, bądź plik d3d9.dll w katalogu z GTA San Andreas", NickName(playerid));
		}
	}*/
    for(new ePlayers:i; i < ePlayers; i++)
    	Player(playerid, i) = 0;

	ClearData(playerid);
	
	SetPlayerColor(playerid, 0x00000000);
	SetPlayerScore(playerid, 0);

	if(IsPlayerNPC(playerid)) return NPC_OnPlayerConnect(playerid);

	#if Debug
	    printf("OnPlayerConnect(%d)", playerid);
	#endif

	SetTimerEx("Clear", 125, false, "d", playerid);
	if(!Player(playerid, player_cam_timer))
		Player(playerid, player_cam_timer) = SetTimerEx("TimerCameraChange", 10000, 1, "d", playerid);
	GetPlayerIp(playerid, Player(playerid, player_ip), 18);

	FadePlayerConnect(playerid);
	TextDrawShowForPlayer(playerid, Setting(setting_td_box)[ 0 ]);
	TextDrawShowForPlayer(playerid, Setting(setting_td_box)[ 1 ]);
	
	Dialog::Output(playerid, 10, DIALOG_STYLE_PASSWORD, IN_HEAD" "white"» "grey"Zaloguj się", TEXT_LOGIN, "Zaloguj", "Wyjdź");
	FadeColorForPlayer(playerid, 0, 0, 0, 255, 0, 0, 0, 255, 15, 0); // Rozjaśnienie
	Player(playerid, player_dark) = dark_login;
	return 1;
}

FuncPub::Clear(playerid)
{
    SetPlayerColor(playerid, 0x00000000);
	for(new i; i <= 100; i++)
		Chat::Output(playerid, 1, " ");
	return 1;
}

FuncPub::loginTimer(playerid)
{
	if(Player(playerid, player_login_timer))
	{
		KillTimer(Player(playerid, player_login_timer));
		Player(playerid, player_login_timer) = 0;
		if(Player(playerid, player_cam_timer))
		{
			KillTimer(Player(playerid, player_cam_timer));
			Player(playerid, player_cam_timer) = 0;
		}
		Chat::Output(playerid, CLR_RED, "Czas na zalogowanie minął!");
		SetTimerEx("kickEx", 500, false, "d", playerid);
	}
	return 1;
}

FuncPub::ClearData(playerid)
{
	Player(playerid, player_skuty)  = INVALID_PLAYER_ID;
	Player(playerid, player_re)  	= INVALID_PLAYER_ID;
	Player(playerid, player_spec) 	= INVALID_PLAYER_ID;
	Player(playerid, player_npc) 	= INVALID_PLAYER_ID;
	Player(playerid, player_color)  = player_nick_def;
	Player(playerid, player_opis_id) = Text3D:INVALID_3DTEXT_ID;
	Player(playerid, player_tag) 	= Text3D:INVALID_3DTEXT_ID;
	Player(playerid, player_veh)    = INVALID_VEHICLE_ID;
	Player(playerid, player_spray) 	= Text3D:INVALID_3DTEXT_ID;
	Player(playerid, player_selected_object) = INVALID_OBJECT_ID;

	Taxi(playerid, taxi_player) 	= INVALID_PLAYER_ID;
	
	Phone(playerid, phone_to) 		= INVALID_PLAYER_ID;
	Phone(playerid, phone_incoming) = INVALID_PLAYER_ID;
	
	Tren(playerid, train_obj) 		= INVALID_OBJECT_ID;
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	#if Debug
	    printf("OnPlayerDisconnect(%d, %d)", playerid, reason);
	#endif
	if(Player(playerid, player_tag) != Text3D:INVALID_3DTEXT_ID)
		Delete3DTextLabel(Player(playerid, player_tag));

	if(Player(playerid, player_opis_id) != Text3D:INVALID_3DTEXT_ID)
		Delete3DTextLabel(Player(playerid, player_opis_id));

    if(Player(playerid, player_cam_timer)) 		KillTimer(Player(playerid, player_cam_timer));
    if(Player(playerid, player_fuel_timer)) 	KillTimer(Player(playerid, player_fuel_timer));
    if(Player(playerid, player_jail_timer)) 	KillTimer(Player(playerid, player_jail_timer));
	if(Player(playerid, player_drug_timer)) 	KillTimer(Player(playerid, player_drug_timer));
	if(Player(playerid, player_login_timer)) 	KillTimer(Player(playerid, player_login_timer));
	if(Player(playerid, player_fish_timer)) 	KillTimer(Player(playerid, player_fish_timer));
	if(Player(playerid, player_achiv_timer)) 	KillTimer(Player(playerid, player_achiv_timer));
	if(Player(playerid, player_bus_timer)) 		KillTimer(Player(playerid, player_bus_timer));
	if(Player(playerid, player_veh_timer)) 		KillTimer(Player(playerid, player_veh_timer));
	if(Player(playerid, player_door_timer)) 	KillTimer(Player(playerid, player_door_timer));
	if(Player(playerid, player_mobile_timer)) 	KillTimer(Player(playerid, player_mobile_timer));
	if(Player(playerid, player_kara_timer)) 	KillTimer(Player(playerid, player_kara_timer));
	if(Player(playerid, player_cmd_timer)) 		KillTimer(Player(playerid, player_cmd_timer));
	if(Player(playerid, player_text_timer)) 	KillTimer(Player(playerid, player_text_timer));
	if(Player(playerid, player_aduty))			EnterAdminDuty(playerid);

    UpdateInfos();
    
	new string[ 200 ];
    if(!IsPlayerNPC(playerid))
    {
		format(string, sizeof string,
			"INSERT INTO `surv_connect` VALUES (NULL, '%d', UNIX_TIMESTAMP(), '%d', '%s', '%d', '%d')",
			Player(playerid, player_uid),
			_:Player(playerid, player_logged),
			Player(playerid, player_ip),
			Player(playerid, player_timehere)[ 1 ],
			Player(playerid, player_afktime)[ 2 ]
		);
    	mysql_query(string);
    	
     	if(!Player(playerid, player_logged)) return 1;

		format(string, sizeof string,
			"DELETE FROM `all_online` WHERE `player` = '%d' AND `ID` = '%d' AND `type` = '"#type_rp"'",
			Player(playerid, player_uid),
			playerid
		);
		mysql_query(string);

	   	OnPlayerLoginOut(playerid);
   	}
	
	new Text3D:End,
		TimePlay[ 45 ];
    ReturnTime(Player(playerid, player_timehere)[ 1 ], TimePlay);
	format(string, sizeof string, "%s\n(( %s ))\nGrał: %s", NickName(playerid), DiscReason[ reason ], TimePlay);
	End = Create3DTextLabel(string, SZARY, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ] + 0.5, 50, Player(playerid, player_vw), 1);
	SetTimerEx("End_TD", 10000, false, "i", _:End);
	
	for(new i; i < MAX_GROUPS; i++)
	    for(new eGroups:d; d < eGroups; d++)
	    	Group(playerid, i, d) = 0;

    for(new ePlayers:i; i < ePlayers; i++)
    	Player(playerid, i) = 0;
    ClearData(playerid);
	return 1;
}

FuncPub::End_TD(textid)
{
	Delete3DTextLabel(Text3D:textid);
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(!text[ 0 ]) return false;
	#if Debug
	    if(!IsPlayerNPC(playerid)) printf("OnPlayerText(%d, %s)", playerid, text);
	#endif
	
	if(!Player(playerid, player_logged))
	{
	    Dialog::Output(playerid, 10, DIALOG_STYLE_PASSWORD, IN_HEAD" "white"» "grey"Zaloguj się", TEXT_LOGIN, "Zaloguj", "Wyjdź");
	    return false;
	}
	if(!Player(playerid, player_spawned))
	    return false;
	if(Player(playerid, player_aj))
	{
	    ShowInfo(playerid, TEXT_AJ);
	    return false;
	}
	if(Player(playerid, player_bw))
	{
	    ShowInfo(playerid, red"Nie możesz rozmawiać podczas BW!");
	    return false;
	}
	if(text[ 0 ] == '-' || text[ 0 ] == '.')
	{
 	    SetAnimationByName(playerid, text[ 1 ]);
 	    return false;
	}
	if(Player(playerid, player_knebel))
	{
	    ShowInfo(playerid, red"Jesteś zakneblowany!");
	    return false;
	}

	Player(playerid, player_texts)++;
	if(!Player(playerid, player_text_timer))
		Player(playerid, player_text_timer) = SetTimerEx("CheckSpamChat", 5000, false, "d", playerid);

	if(IsPlayerVisibleItems(playerid) && Player(playerid, player_option) & option_textdraw)
	{
		Items_OnPlayerText(playerid, text);
		return false;
	}
	if(Phone(playerid, phone_to) != INVALID_PLAYER_ID && Phone(Phone(playerid, phone_to), phone_to) == playerid)
	{
	    Tel_OnPlayerText(playerid, text);
	    return false;
	}
	if(!strcmp(text, ":D", true))
	{
		cmd_me(playerid, "śmieje się.");
		ApplyAnimation(playerid, "RAPPING", "Laugh_01", 4.1, 0, 0, 0, 0, 0);
	}
	else if(!strcmp(":P", text, true))
	{
		cmd_me(playerid, "wystawia język.");
	}
	else if(!strcmp(":/", text, true))
	{
		cmd_me(playerid, "krzywi się.");
	}
	else if(!strcmp(":(", text, true) || !strcmp(";(", text, true))
	{
		cmd_me(playerid, "robi smutną minę.");
	}
	else if(!strcmp(":)", text, true))
	{
		cmd_me(playerid, "uśmiecha się.");
	}
	else if(!strcmp(";)", text, true))
	{
		cmd_me(playerid, "mruga jednym okiem.");
	}
	else if(!strcmp(":o", text, true) || !strcmp(";o", text, true))
	{
		cmd_me(playerid, "dziwi się.");
	}
	else if(!strcmp("XD", text, true))
	{
		cmd_me(playerid, "wybucha śmiechem.");
		ApplyAnimation(playerid, "RAPPING", "Laugh_01", 4.1, 0, 0, 0, 0, 0);
	}
	else if(!strcmp(":*", text, true))
	{
		cmd_me(playerid, "robi dzióbek.");
	}
	else if(text[ 0 ] == '!' || text[ 0 ] == '@')
	{
	    Group_OnPlayerText(playerid, text);
	    return false;
	}
	else
	{
	    if(strfind(text, "Witam", false) != -1 && !IsPlayerNPC(playerid))
	    {
	        for(new n; n != sizeof NpcData; n++)
	        {
	            if(NPC(n, npc_door) != Player(playerid, player_door)) continue;
	            if(NPC(n, npc_pos)[ 0 ] == 0.0 && NPC(n, npc_pos)[ 1 ] == 0.0 && NPC(n, npc_pos)[ 2 ] == 0.0) continue;
	            if(!IsPlayerInRangeOfPoint(playerid, 3.0, NPC(n, npc_pos)[ 0 ], NPC(n, npc_pos)[ 1 ], NPC(n, npc_pos)[ 2 ])) continue;
	            if(NPC(n, npc_function) == npc_func_gov)
	            {
	                new buffer[ 350 ];
	                for(new d; d != sizeof LicName; d++)
				    {
				        if(LicName[ d ][ lic_group ] != group_type_gov) continue;
				        if(d != 6) continue;
				    	format(buffer, sizeof buffer, "%s%d\t"green2"$"white"%.2f\t\t%s\n", buffer, d, LicName[ d ][ lic_price ] + LicName[ d ][ lic_price_before ], LicName[ d ][ lic_name ]);
					}
		            Dialog::Output(playerid, 157, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Wyrób dokument", buffer, "Wybierz", "Zamknij");

					OnPlayerText(NPC(n, npc_playerid), "Witam, w czym mogę pomóc?");

		            Player(playerid, player_npc) = n;
		            break;
	            }
	        }
	    }
	    if(strfind(text, "Znalazłem Cię!", true) != -1 && !IsPlayerNPC(playerid))
	    {
	        for(new n; n != sizeof NpcData; n++)
	        {
	            if(NPC(n, npc_pos)[ 0 ] == 0.0 && NPC(n, npc_pos)[ 1 ] == 0.0 && NPC(n, npc_pos)[ 2 ] == 0.0) continue;
	            if(!IsPlayerInRangeOfPoint(playerid, 3.0, NPC(n, npc_pos)[ 0 ], NPC(n, npc_pos)[ 1 ], NPC(n, npc_pos)[ 2 ])) continue;
	            if(NPC(n, npc_function) == npc_func_achiv)
	            {
	                //OnPlayerText(NPC(n, npc_playerid), "Kurwa, złapałeś mnie. Masz mój hajs..");
	                NPC_SetRandomPos(n, NPC(n, npc_playerid));
	                GivePlayerMoneyEx(playerid, randomEx(1, 10), true);
	            }
			}
		}
		new len = strlen(text),
			back,
			string[ 128 ];

  		text[ 0 ] = toupper(text[ 0 ]);
		if(text[ len-1 ] != '.' && text[ len-1 ] != '?' && text[ len-1 ] != '!' && text[ len-1 ] != '*')
			back = '.';

		/*
		if(len >= 5 && Player(playerid, player_drunklvl) > 5000)
		{
		    for(new g = 3; g <= len; g += random(5)+2)
		    {
		        if(g >= len) break;
				if(text[ g ] != '.' && text[ g ] != '?' && text[ g ] != '!') continue;
		        if(text[ g ] == ' ') continue;
		        if(isupper(text[g])) text[g] = znaki[randomEx(24, sizeof znaki - 10)];
		        else if(islower(text[g])) text[g] = znaki[random(24)];
				else continue;
		    }
		}*/
		
		format(string, sizeof string, "%s mówi: %s%c", NickName(playerid), text, back);
		if(Player(playerid, player_veh) != INVALID_VEHICLE_ID && Vehicle(Player(playerid, player_veh), vehicle_option) & option_window)
			SendWrappedMessageToPlayerRange(playerid, COLOR_FADE1, COLOR_FADE2, COLOR_FADE3, COLOR_FADE4, COLOR_FADE5, string, 2, MAX_LINE);
		else
			SendWrappedMessageToPlayerRange(playerid, COLOR_FADE1, COLOR_FADE2, COLOR_FADE3, COLOR_FADE4, COLOR_FADE5, string, 14, MAX_LINE);

		if(!Player(playerid, player_anim) && !IsPlayerInAnyVehicle(playerid) && Player(playerid, player_option) & option_anim_m)
		{
		    SetAnimationByGame(playerid, Player(playerid, player_anim_chat), len);
		}

	}
 	return 0;
}

public OnPlayerRequestClass(playerid, classid)
{
	if(IsPlayerNPC(playerid)) return NPC_OnPlayerRequestClass(playerid, classid);
	#if Debug
	    printf("OnPlayerRequestClass(%d)", playerid);
	#endif
	if(!Player(playerid, player_logged)) return 1;
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
    if(IsPlayerNPC(playerid)) return 1;
	#if Debug
	    printf("OnPlayerRequestSpawn(%d)", playerid);
	#endif
	
	if(!Player(playerid, player_logged)) return 0;
    return 1;
}

public OnPlayerSpawn(playerid)
{
 	if(IsPlayerNPC(playerid)) return NPC_OnPlayerSpawn(playerid);
	#if Debug
	    printf("OnPlayerSpawn(%d)", playerid);
	#endif
 	if(!Player(playerid, player_logged)) return 1;
 	
 	if(isnull(Player(playerid, player_ip)))
 	    GetPlayerIp(playerid, Player(playerid, player_ip), 18);
	if(Itter_Count(Player) > DOF2_GetInt(IN_BAZA, "players"))
	    DOF2_SetInt(IN_BAZA, "players", Itter_Count(Player));

	KillTimer(Player(playerid, player_cam_timer));
	Player(playerid, player_cam_timer) = 0;
	Audio_Stop(playerid, Player(playerid, player_connect_sound));
	
	Player(playerid, player_spawned) = true;

	SetPlayerHealth(playerid, Player(playerid, player_hp));
	
	SetPlayerPosEx(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ], Player(playerid, player_position)[ 3 ]);
	SetPlayerInterior(playerid, Player(playerid, player_int));
	SetPlayerVirtualWorld(playerid, Player(playerid, player_vw));
	SetPlayerDrunkLevel(playerid, Player(playerid, player_drunklvl));

	SetPlayerSkin(playerid, Player(playerid, player_skin));

    if(Player(playerid, player_option) & option_fight)
 		SetPlayerFightingStyle(playerid, FightData[ Player(playerid, player_fight) ][ fight_id ]);
    else
        SetPlayerFightingStyle(playerid, FIGHT_STYLE_NORMAL);

	SetPlayerMoney(playerid, Player(playerid, player_cash));

	PlayerTextDrawShow(playerid, Player(playerid, player_cash_td));
//	PlayerTextDrawShow(playerid, Player(playerid, player_infos));

	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 			1);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL_SILENCED, 	1);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_DESERT_EAGLE, 	999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SHOTGUN, 			999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN, 	1);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SPAS12_SHOTGUN, 	1);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI, 		1);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MP5, 				999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_AK47, 			999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_M4, 				999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SNIPERRIFLE, 		999);
	
	if(!Player(playerid, player_reload_anims))
	{
		PreloadAnimLibraries(playerid);
	    Player(playerid, player_reload_anims) = true;
	}

	if(Player(playerid, player_bw))
	{
	    FreezePlayerEx(playerid);
	    SetPlayerHealth(playerid, Player(playerid, player_hp) = 999999.0);
	    SetTimerEx("AntyCheat_Enable", 3000, false, "d", playerid);
	}
	else UnFreezePlayer(playerid);

    #if !STREAMER
		LoadPlayerObjects(playerid, Player(playerid, player_vw));
	#endif
	LoadPlayerText(playerid, Player(playerid, player_vw));
	LoadSounds(playerid);
    CancelSelectTextDraw(playerid);
	SetPlayerAttachedObjects(playerid, Player(playerid, player_uid));

	if(!(Player(playerid, player_option) & option_panor))
	{
		TextDrawHideForPlayer(playerid, Setting(setting_td_box)[ 0 ]);
		TextDrawHideForPlayer(playerid, Setting(setting_td_box)[ 1 ]);
	}
	
	if(Player(playerid, player_option) & option_news)
	{
	    TextDrawShowForPlayer(playerid, Setting(setting_sn)[ 0 ]);
	    TextDrawShowForPlayer(playerid, Setting(setting_sn)[ 1 ]);
	}
	else
	{
	    TextDrawHideForPlayer(playerid, Setting(setting_sn)[ 0 ]);
	    TextDrawHideForPlayer(playerid, Setting(setting_sn)[ 1 ]);
	}
	if(!Player(playerid, player_height))
	{
	    new buffer[ 512 ];
	    for(new x = 160; x != 210; x++)
	    	format(buffer, sizeof buffer, "%s%dcm\n", buffer, x);
	    	
	    Dialog::Output(playerid, 170, DIALOG_STYLE_LIST, "Wybierz wzrost postaci", buffer, "Wybierz", "Później");
	}
	else if(!(Player(playerid, player_option) & option_vehicle) && Player(playerid, player_timehere)[ 0 ] > 7200)
	{
	    new buffer[ 512 ];
	    for(new x; x != sizeof StartingVehicle; x++)
	        format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, x, NazwyPojazdow[StartingVehicle[ x ] - 400]);
		Dialog::Output(playerid, 11, DIALOG_STYLE_LIST, "Wybierz pojazd startowy", buffer, "Wybierz", "Później");
	}
	
	SetCameraBehindPlayer(playerid);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	#if Debug
	    printf("OnPlayerDeath(%d, %d, %d)", playerid, killerid, reason);
	#endif
    Player(playerid, player_spawned) = false;
    if(killerid != INVALID_PLAYER_ID)
    {
		// Fake Kill
		if(!OdlegloscMiedzyGraczami(25.0, playerid, killerid) || Player(killerid, player_timehere)[ 0 ] < 7200)
		{
			//BW(playerid, 1);
		}
        if((gettime() - Player(playerid, player_killed_time)) < 1)
        {
            Player(playerid, player_killed)++;
            if(Player(playerid, player_killed) == 3)
            {
                //new msg[126];
                //format(msg,sizeof(msg),"Gracz o ID: %d wykonuje FakeKille!",playerid);
                //SendClientMessageToAll(-1,msg);
                //SendClientMessage(playerid,-1,"Zostałeś Zbanowany! Powód: FakeKilling");
                //BanEx(playerid,"FakeKill");
				printf("Gracz o ID: %d wykonuje FakeKille!", playerid);
				Kick(playerid);
            }
        }
        else Player(playerid, player_killed) = 0;
        Player(playerid, player_killed_time) = gettime();
	}
	SetSpawnInfo(playerid, NO_TEAM, Player(playerid, player_skin), Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ], Player(playerid, player_position)[ 3 ], 0, 0, 0, 0, 0, 0);
	//printf("State: %f %f %f %d %d", Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ], Player(playerid, player_vw), Player(playerid, player_int));
	BW(playerid, (!reason) ? 5 : 10);
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(!Player(playerid, player_uid) && Player(playerid, player_cam_timer))
        SelectTextDraw(playerid, GREEN); // TODO
	if(!Player(playerid, player_spawned) || !Player(playerid, player_logged) || IsPlayerNPC(playerid))
        return 1;

	if(Player(playerid, player_afktime)[ 0 ] > 4)
	{
		Player(playerid, player_afktime)[ 0 ] = 0;
		UpdatePlayerNick(playerid);
	}
	if(!GetPlayerVehicleID(playerid))
	{
	    if(Player(playerid, player_fish))
	        if(PRESSED(KEY_SPRINT))
	            Player(playerid, player_fish)--;
	            
		if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED)
	    	if(PRESSED(KEY_JUMP) || PRESSED(KEY_SPRINT))
				ApplyAnimation(playerid, "GYMNASIUM", "gym_jog_falloff",4.1,0,1,1,0,0);

		if(PRESSED(KEY_HANDBRAKE) && GetPlayerWeapon(playerid) >= 22)
		{
			Player(playerid, player_aim) = true;

			if(Player(playerid, player_option) & option_shooting)
			{
				Player(playerid, player_aim_object) = CreateObject(playerid, 19300, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
				AttachObjectToPlayer(Player(playerid, player_aim_object), playerid, (Player(playerid, player_option) & option_hand) ? (-0.5) : (0.5), -0.92, Player(playerid, player_crouch) ? (0.3) : (0.6), 0.0, 0.0, 0.0);
				AttachCameraToObject(playerid, Player(playerid, player_aim_object));
			}
		    //if(Player(playerid, player_stamina) <= 3050 && Repair(playerid, repair_type) != repair_spray && !Player(playerid, player_anim) && !IsPlayerInTypeGroup(playerid, group_type_pd))
		    	//SetPlayerDrunkLevel(playerid, 4990);
		}
	 	else if(RELEASED(KEY_HANDBRAKE) && Player(playerid, player_aim))
	 	{
		 	Player(playerid, player_aim) = false;
	 		DestroyObject(Player(playerid, player_aim_object));
	 		SetCameraBehindPlayer(playerid);
		    //if(Player(playerid, player_stamina) <= 3050)
		 		//SetPlayerDrunkLevel(playerid, Player(playerid, player_drunklvl));
		}
		if(newkeys == (KEY_HANDBRAKE + KEY_YES) && Player(playerid, player_aim))
		{
	        if(Player(playerid, player_option) & option_hand)
	            Player(playerid, player_option) -= option_hand;
	        else
	            Player(playerid, player_option) += option_hand;

			AttachObjectToPlayer(Player(playerid, player_aim_object), playerid, (Player(playerid, player_option) & option_hand) ? (-0.5) : (0.5), -0.92, Player(playerid, player_crouch) ? (0.3) : (0.6), 0.0, 0.0, 0.0);
			AttachCameraToObject(playerid, Player(playerid, player_aim_object));
		}
		if(Repair(playerid, repair_type) == repair_spray)
		{
			if(PRESSED(KEY_FIRE))
	   		{
		    	KillTimer(GetPVarInt(playerid, "Paint"));
		    	DeletePVar(playerid, "Paint");
	     		SetPVarInt(playerid, "Paint", SetTimerEx("Paint_Timer", 750, 1, "d", playerid));
			}
			else if(RELEASED(KEY_FIRE))
			{
			    KillTimer(GetPVarInt(playerid, "Paint"));
		    	DeletePVar(playerid, "Paint");
			}
		}
		
		Doors_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
		Anims_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
		Train_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
	}
	else Vehicle_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
	
	Admin_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
	Items_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
	return 1;
}

FuncPub::Paint_Timer(playerid)
{
    if(GetPlayerWeapon(playerid) != 41)
		return GameTextForPlayer(playerid,"~r~Wyciagnij spray can!", 3000, 3);
	if(GetPlayerWeaponState(playerid) == WEAPONSTATE_RELOADING)
	    return 1;
	    
    new vehicleid = Repair(playerid, repair_value)[ 2 ];
	if(!IsPlayerFacingVehicle(playerid, vehicleid))
		return GameTextForPlayer(playerid,"~w~odwroc sie w strone ~n~auta, inaczej malowanie zostanie ~r~przerwane~w~!", 3000, 3);

    new victimid = Repair(playerid, repair_player);
	if(GetDistanceToCar(playerid, vehicleid) > 15.0 && !Vehicle(vehicleid, vehicle_uid))
    {
		GameTextForPlayer(playerid, "~n~~r~Malowanie przerwane!", 3000, 4);
		GameTextForPlayer(victimid, "~n~~r~Malowanie przerwane!", 3000, 4);
	    GivePlayerMoneyEx(victimid, Repair(playerid, repair_cash), true);

		KillTimer(GetPVarInt(playerid, "Paint"));
	    DeletePVar(playerid, "Paint");
  		End_Repair(playerid);
  		return 1;
	}
	new string[ 126 ],
		Float:procent,
		bar[ 32 ],
		end;
	Repair(playerid, repair_time)++;
	
	if(Repair(playerid, repair_value)[ 1 ] == -1)
	{
	    end = 300;
	    procent = floatmul(floatdiv(Repair(playerid, repair_time), end), 100);
	}
	else
	{
	    end = 50;
	    procent = floatmul(floatdiv(Repair(playerid, repair_time), end), 100);
	}
	if(procent >= 100)      bar = green"----------";
	else if(procent >= 90)	bar = green"---------"white"-";
	else if(procent >= 80)	bar = green"--------"white"--";
	else if(procent >= 70)	bar = green"-------"white"---";
	else if(procent >= 60)	bar = green"------"white"----";
	else if(procent >= 50)	bar = green"-----"white"-----";
	else if(procent >= 40)	bar = green"----"white"------";
	else if(procent >= 30)	bar = green"---"white"-------";
	else if(procent >= 20)	bar = green"--"white"--------";
	else if(procent >= 10)	bar = green"-"white"---------";
	else					bar = white"----------";

	format(string, sizeof string,
		"Lakierowanie pojazdu %s\nUkończono w %.1f%%\n%s\n%d/%d",
		NazwyPojazdow[ Vehicle(vehicleid, vehicle_model) - 400 ],
		procent,
		bar
	);
	if(Player(playerid, player_spray) != Text3D:INVALID_3DTEXT_ID)
		Update3DTextLabelText(Player(playerid, player_spray), COLOR_PURPLE, string);

	if(Repair(playerid, repair_time) == end)
	{
	    new color[ 2 ];
		color[ 0 ] = Repair(playerid, repair_value)[ 0 ];
		color[ 1 ] = Repair(playerid, repair_value)[ 1 ];
			
		SetPlayerMoney(playerid, Player(playerid, player_cash) += Repair(playerid, repair_cash));

		if(color[ 1 ] != -1)
		{
			Vehicle(vehicleid, vehicle_color)[ 0 ] = color[ 0 ];
			Vehicle(vehicleid, vehicle_color)[ 1 ] = color[ 1 ];
		    ChangeVehicleColor(vehicleid, Vehicle(vehicleid, vehicle_color)[ 0 ], Vehicle(vehicleid, vehicle_color)[ 1 ]);
			format(string, sizeof string,
				"UPDATE `surv_vehicles` SET `c1` = '%d', `c2` = '%d' WHERE `uid` = '%d'",
				Vehicle(vehicleid, vehicle_color)[ 0 ],
				Vehicle(vehicleid, vehicle_color)[ 1 ],
				Vehicle(vehicleid, vehicle_uid)
			);
			mysql_query(string);
		}
		else
		{
		    Vehicle(vehicleid, vehicle_pj) = color[ 0 ];
		    ChangeVehiclePaintjob(vehicleid, Vehicle(vehicleid, vehicle_pj));
			format(string, sizeof string,
				"UPDATE `surv_vehicles` SET `pj` = '%d' WHERE `uid` = '%d'",
				Vehicle(vehicleid, vehicle_color)[ 0 ],
				Vehicle(vehicleid, vehicle_uid)
			);
			mysql_query(string);
		}
	    
	    GameTextForPlayer(playerid,"~n~~g~Przemalowano", 3000,4);
		PlayerPlaySound(playerid, 1134, 0.0, 0.0, 10.0);

 		KillTimer(GetPVarInt(playerid, "Paint"));
	    DeletePVar(playerid, "Paint");

       	End_Repair(playerid);
	}
	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
/*
	if(!Player(playerid, player_spawned) || !Player(playerid, player_logged) || IsPlayerNPC(playerid))
        return 0;*/
        
	if(GetPlayerWeapon(playerid) == 38 || GetPlayerWeapon(playerid) == 35 || GetPlayerWeapon(playerid) == 36)
	    return Kick(playerid);

	if(Player(playerid, player_afktime)[ 0 ] > 4)
	{
		Player(playerid, player_afktime)[ 0 ] = 0;
	    UpdatePlayerNick(playerid);
	}
	
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_DUCK && !Player(playerid, player_crouch))
	{
		Player(playerid, player_crouch) = true;
	    
		if(Player(playerid, player_aim))
		{
			AttachObjectToPlayer(Player(playerid, player_aim_object), playerid, (Player(playerid, player_option) & option_hand) ? (-0.5) : (0.5), -0.92, 0.3, 0.0, 0.0, 0.0);
			AttachCameraToObject(playerid, Player(playerid, player_aim_object));
		}
	}
	else if(GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK && Player(playerid, player_crouch))
	{
		Player(playerid, player_crouch) = false;
	    
		if(Player(playerid, player_aim))
		{
			AttachObjectToPlayer(Player(playerid, player_aim_object), playerid, (Player(playerid, player_option) & option_hand) ? (-0.5) : (0.5), -0.92, 0.6, 0.0, 0.0, 0.0);
			AttachCameraToObject(playerid, Player(playerid, player_aim_object));
		}
	}
    Items_OnPlayerUpdate(playerid);
    Skin_OnPlayerUpdate(playerid);
	return 1;
}

/*
 * OnPlayerGiveDamage(playerid, damagedid, Float: amount, weaponid)
 * playerid = strzelający
 * damagedid = postrzelony
 * amount = ilość HP
 * weaponid = ID użytej broni
 */
public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
{
	#if Debug
	    printf("OnPlayerGiveDamage(%d, %d, %f, %d, %d)", playerid, damagedid, amount, weaponid, bodypart);
	#endif

	return 1;
}

/*
 * OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid)
 * playerid = postrzelony
 * issuerid = strzelający
 * amount = ilość HP
 * weaponid = ID użytej broni
 */
public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	#if Debug
	    printf("OnPlayerTakeDamage(%d, %d, %f, %d, %d)", playerid, issuerid, amount, weaponid, bodypart);
	#endif
	if(issuerid != INVALID_PLAYER_ID)
	{
		if(IsPlayerNPC(issuerid)) return 1;
		if(!IsPlayerInAnyVehicle(issuerid) && Weapon(issuerid, Player(issuerid, player_used_weapon), weapon_model) != weaponid && !Weapon(issuerid, Player(issuerid, player_used_weapon), weapon_uid) && weaponid)
		{
		    print("[AC]Damage bez broni");
		    Kick(issuerid);
		    return 1;
		}
		if(Weapon(issuerid, Player(issuerid, player_used_weapon), weapon_uid) && Weapon(issuerid, Player(issuerid, player_used_weapon), weapon_model))
		{
			if(Weapon(issuerid, Player(issuerid, player_used_weapon), weapon_flag) & weapon_flag_paral)
			{
		 		FreezePlayer(playerid);
		   		SetTimerEx("UnFreezePlayer", 5000, false, "d", playerid);
			    SetPlayerHealth(playerid, Player(playerid, player_hp));
		  		ApplyAnimation(playerid, "CRACK", "crckidle1", 4.1, 1, 0, 0, 0, 0);
		  		Player(playerid, player_anim) = true;
		  		return 1;
			}
			if(Player(playerid, player_hp) < 20.0 && GetPlayerWeapon(issuerid) >= 22)
			{
		 		FreezePlayer(playerid);
		   		SetTimerEx("UnFreezePlayer", 5000, false, "d", playerid);
		  		ApplyAnimation(playerid, "CRACK", "crckidle1", 4.1, 1, 0, 0, 0, 0);
		  		Player(playerid, player_anim) = true;
			}
		}
		if(Player(issuerid, player_timehere)[ 0 ] < 7200 || Player(issuerid, player_block) & block_norun)
		{
			SetPlayerHealth(playerid, Player(playerid, player_hp));
			return 1;
		}
	}
	new amo = floatval(amount);

	Player(playerid, player_hp) 		-= amount;

	if(HavePlayerWeapon(issuerid))
	{
	    if(!(bodypart == 0 || bodypart == 1 || bodypart == 2))
	    {
	        new string[ 64 ];
			Player(playerid, player_shot_body)[ bodypart ]++;

			format(string, sizeof string, "Trafiłeś w %s.", BodyParts[ bodypart ]);
			Chat::Output(issuerid, CLR_RED, string);

			format(string, sizeof string, "Dostałeś w %s.", BodyParts[ bodypart ]);
			Chat::Output(playerid, CLR_RED, string);
		}
	}
	
	if((Player(playerid, player_screen) + (amo/10)+1) < 15)
		Player(playerid, player_screen) += (amo/10)+1;
	else
	    Player(playerid, player_screen) = 15;

	if(Player(playerid, player_screen))
	    Player(playerid, player_color) 	= player_nick_red;

	if(amo) TextDrawShowForPlayer(playerid, Setting(setting_red));

/*	if((Player(playerid, player_pulse) 	+ (amo*2)+1) < 200)
    	Player(playerid, player_pulse) 	+= (amo*2)+1;
	else
	    Player(playerid, player_pulse) 	= 200;*/

	Energy(playerid);
	UpdatePlayerNick(playerid);
	return 1;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(IsPlayerNPC(playerid)) return 1;
	
	if(HavePlayerWeapon(playerid) && Weapon(playerid, Player(playerid, player_used_weapon), weapon_ammo) && Weapon(playerid, Player(playerid, player_used_weapon), weapon_uid))
    	Weapon(playerid, Player(playerid, player_used_weapon), weapon_ammo)--;

	if(Weapon(playerid, Player(playerid, player_used_weapon), weapon_flag) & weapon_flag_nodmg)
	    return 0;

	if(Repair(playerid, repair_type) == repair_spray && weaponid == 41)
	    return 0;

	if(Player(playerid, player_timehere)[ 0 ] < 7200)
	    return 0;

	if(!IsPlayerInAnyVehicle(playerid) && weaponid && weaponid != Weapon(playerid, Player(playerid, player_used_weapon), weapon_model) && !Weapon(playerid, Player(playerid, player_used_weapon), weapon_uid))
	{
		Kick(playerid);
	    return 0;
	}
	if(!(IsPlayerInTypeGroup(playerid, group_type_gang) || IsPlayerInTypeGroup(playerid, group_type_mafia) || IsPlayerInTypeGroup(playerid, group_type_pd) || IsPlayerInTypeGroup(playerid, group_type_mafia)))
	{
		if(hittype == BULLET_HIT_TYPE_VEHICLE && HavePlayerWeapon(playerid))
		    return 0;
		if(hittype == BULLET_HIT_TYPE_PLAYER && IsPlayerInAnyVehicle(playerid))
		    return 0;
	}
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
    PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
	Pickup_OnPlayerPickUpPickup(playerid, pickupid);
	Door_OnPlayerPickUpPickup(playerid, pickupid);
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    #define dialogid	Player(playerid, player_dialog)

	if(Audio_IsClientConnected(playerid))
	{
		if(response) Audio_Play(playerid, gui_button1_sound);
		else Audio_Play(playerid, gui_button2_sound);
	}
	else
	{
		if(response) PlayerPlaySound(playerid, 1083, 0.0, 0.0, 0.0);
		else PlayerPlaySound(playerid, 1084, 0.0, 0.0, 0.0);
	}

	#if Debug
	    if(dialogid != 999 && dialogid != cellmin && dialogid != 10)
			printf("OnDialogResponse(%d, %d, %d, %d, %s)", playerid, dialogid, response, listitem, inputtext);
	#endif
    if(dialogid != cellmin && dialogid != dialogid)
        response = false;
        
    A_CHAR(inputtext);
    
	Pc_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
	Bus_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
	Tel_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
	//NPC_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
	Door_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
	Bank_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
	Sejf_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
	Opis_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
 	Anims_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
   	Items_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
	Offer_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
	Admin_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
	Order_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
	Pickup_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
	Friends_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
	Vehicle_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);

	switch(dialogid)
	{
		case 1: // SelectSpawn(playerid)
		{
		    new uid = strval(inputtext),
				query[ 100 ];
				
		    format(query, sizeof query, "SELECT * FROM `surv_spawns` WHERE `uid` = '%d'", uid);
		    mysql_query(query);
		    mysql_store_result();
		    mysql_fetch_row_format(query);
		    sscanf(query, "p<|>{d}a<f>[4]dd",
		        Player(playerid, player_position),
		        Player(playerid, player_vw),
		        Player(playerid, player_int)
		    );
		    mysql_free_result();

			SetSpawnInfo(playerid, NO_TEAM, Player(playerid, player_skin), Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ], Player(playerid, player_position)[ 3 ], 0, 0, 0, 0, 0, 0);
			
			FadeColorForPlayer(playerid, 0, 0, 0, 0, 0, 0, 0, 255, 15, 0); // Ściemnienie
			Player(playerid, player_dark) = dark_spawn;
		}
		case 10:
		{
	    	if(!response) return SetTimerEx (!#kickPlayer, 249, false, !"i", playerid);
		    if(isnull(inputtext) || strlen(inputtext) > 21)
				return Dialog::Output(playerid, 10, DIALOG_STYLE_PASSWORD, IN_HEAD" "white"» "grey"Zaloguj się", TEXT_LOGIN"\n\nNie podałeś hasła!", "Zaloguj", "Wyjdź");

			new salt[ 10 ],
				bool:log,
				buffer[ 256 ],
				score;

	        //mysql_real_escape_string(inputtext, inputtext);
	        #if Forum == 1 // MyBB
				format(buffer, sizeof buffer, "SELECT mybb_users.uid, mybb_users.username FROM `surv_players` JOIN mybb_users ON mybb_users.uid = surv_players.guid WHERE surv_players.name = '%s'", NickSamp(playerid));
			#elseif Forum == 2 // IPB
				format(buffer, sizeof buffer, "SELECT f.member_id, f.score, f.RP, f.RP_perm, f.members_display_name FROM `surv_players` JOIN "IN_PREF"members f ON f.member_id = surv_players.guid WHERE surv_players.name = '%s'", NickSamp(playerid));
			#endif
			mysql_query(buffer);
		    mysql_store_result();
		    if(mysql_num_rows())
		    {
				mysql_fetch_row_format(buffer);
		        sscanf(buffer, "p<|>dddds[120]",
			        Player(playerid, player_guid),
			        score,
			        Player(playerid, player_adminlvl),
			        Player(playerid, player_adminperm),
			        Player(playerid, player_gname)
		        );
		        mysql_free_result();
				log = true;
		    }
		    else
		    {
				mysql_free_result();
	        	#if Forum == 1 // MyBB
					format(buffer, sizeof buffer, "SELECT mybb_users.uid, mybb_users.username FROM `surv_players` JOIN mybb_users ON mybb_users.uid = surv_players.guid WHERE mybb_users.username = '%s'", NickSamp(playerid));
				#elseif Forum == 2 // IPB
					format(buffer, sizeof buffer, "SELECT f.member_id, f.score, f.RP, f.RP_perm, f.members_display_name FROM `surv_players` JOIN "IN_PREF"members f ON f.member_id = surv_players.guid WHERE f.name = '%s'", NickSamp(playerid));
				#endif
				mysql_query(buffer);
			    mysql_store_result();
			    if(mysql_num_rows())
			    {
					mysql_fetch_row_format(buffer);
			        sscanf(buffer, "p<|>dddds[120]",
				        Player(playerid, player_guid),
				        score,
				        Player(playerid, player_adminlvl),
				        Player(playerid, player_adminperm),
				        Player(playerid, player_gname)
			        );
			        mysql_free_result();
					log = false;
			    }
			    else
			    {
					mysql_free_result();
					ShowInfo(playerid, red"Nie znaleziono konta globalnego o takiej nazwie.\n\nJeżeli podajesz dane prawidłowo, spróbuj zresetować hasło poprzez forum.");
					SetTimerEx (!#kickPlayer, 249, false, !"i", playerid);
			     	return 1;
		     	}
		    }
		    
		    format(buffer, sizeof buffer,
				"SELECT `members_pass_salt` FROM `"IN_PREF"members` WHERE `member_id` = '%d'",
				Player(playerid, player_guid)
			);
			mysql_query(buffer);
			mysql_store_result();
			mysql_fetch_row(salt);
			mysql_free_result();
		    
		    new password[ 120 ];
	 		format(password, sizeof password, "%s%s", MD5_Hash(salt), MD5_Hash(inputtext));
	 		mysql_real_escape_string(password, password);
			if(log == false) // Nazwa OOC
			{
				new query[ 256 ];
	        	#if Forum == 1 // MyBB
			 		format(query, sizeof query, "SELECT `uid` FROM `surv_players` JOIN mybb_users ON mybb_users.password = md5('%s') WHERE surv_players.guid = '%d' AND mybb_users.uid = '%d'", password, Player(playerid, player_guid), Player(playerid, player_guid));
				#elseif Forum == 2 // IPB
			 		format(query, sizeof query, "SELECT `uid` FROM `surv_players` JOIN "IN_PREF"members f ON f.members_pass_hash = md5('%s') WHERE surv_players.guid = '%d' AND f.member_id = '%d'", password, Player(playerid, player_guid), Player(playerid, player_guid));
				#endif
				mysql_query(query);
			   	mysql_store_result();
			   	new num = mysql_num_rows(),
				   	uid = mysql_fetch_int();
				   	
	   			mysql_free_result();
			   	if(num)
			   	{
					SetPlayerScore(playerid, score);
					if(Player(playerid, player_cam_timer))
					{
						KillTimer(Player(playerid, player_cam_timer));
						Player(playerid, player_cam_timer) = 0;
					}
					if(Player(playerid, player_login_timer))
					{
						KillTimer(Player(playerid, player_login_timer));
						Player(playerid, player_login_timer) = 0;
					}
			   	}
			   	if(num == 1)
			   	{
				   	Player(playerid, player_uid) = uid;
					OnPlayerLoginIn(playerid);
			   	}
			    else if(num > 1)
			    {
					PreloadAnimLibraries(playerid);
					SelectPlayer(playerid);
					SetPlayerDrunkLevel(playerid, 0);
			    }
			    else Dialog::Output(playerid, 10, DIALOG_STYLE_PASSWORD, IN_HEAD" "white"» "grey"Zaloguj się", TEXT_LOGIN"\n\nPodałeś nieprawidłowe hasło do konta lub nie masz postaci, spróbuj ponownie.", "Zaloguj", "Wyjdź");
			}
			else
			{
			    new query[ 256 ];
	        	#if Forum == 1 // MyBB
		 			format(query, sizeof query, "SELECT p.uid, p.block FROM `surv_players` p JOIN mybb_users f ON f.password = md5('%s') WHERE p.guid = '%d' AND p.name = '%s'", password, Player(playerid, player_guid), NickSamp(playerid));
				#elseif Forum == 2 // IPB
		 			format(query, sizeof query, "SELECT p.uid, p.block FROM `surv_players` p JOIN "IN_PREF"members f ON f.members_pass_hash = md5('%s') WHERE p.guid = '%d' AND p.name = '%s'", password, Player(playerid, player_guid), NickSamp(playerid));
				#endif
				mysql_query(query);
			   	mysql_store_result();
			    if(mysql_num_rows())
			    {
			        mysql_fetch_row_format(query);
			        sscanf(query, "p<|>dd",
						Player(playerid, player_uid),
						Player(playerid, player_block)
					);
					SetPlayerScore(playerid, score);
					if(Player(playerid, player_block) & block_ban)
					{
						Chat::Output(playerid, RED, "Ta postać jest zbanowana!");
						SetTimerEx (!#kickPlayer, 249, false, !"i", playerid);
					}
					else if(Player(playerid, player_block) & block_ck)
					{
						Chat::Output(playerid, RED, "Ta postać nie żyje!");
						SetTimerEx (!#kickPlayer, 249, false, !"i", playerid);
					}
					else if(Player(playerid, player_block) & block_block)
					{
						Chat::Output(playerid, RED, "Ta postać została zablokowana!");
						SetTimerEx (!#kickPlayer, 249, false, !"i", playerid);
					}
					else OnPlayerLoginIn(playerid);
			    }
			    else Dialog::Output(playerid, 10, DIALOG_STYLE_PASSWORD, IN_HEAD" "white"» "grey"Zaloguj się", TEXT_LOGIN"\n\nPodałeś nieprawidłowe hasło do konta, spróbuj ponownie.", "Zaloguj", "Wyjdź");
				mysql_free_result();
			}
		}
		case 11:
		{
		    if(!response) return 1;
		    if(Player(playerid, player_option) & option_vehicle) return 1;
		    new id = strval(inputtext),
				string[ 256 ],
				vehid = CreateVeh(playerid, StartingVehicle[ id ], vehicle_owner_player, Player(playerid, player_uid), random(120), random(120));
			format(string, sizeof string,
				"UPDATE `surv_vehicles` SET `x` = '%f', `y` = '%f', `z` = '%f', `a` = '%f', `int` = '0', `vw` = '0' WHERE `uid` = '%d'",
				Setting(setting_veh_pos)[ 0 ],
				Setting(setting_veh_pos)[ 1 ],
				Setting(setting_veh_pos)[ 2 ],
				Setting(setting_veh_pos)[ 3 ],
				Vehicle(vehid, vehicle_uid)
			);
			mysql_query(string);
			Vehicle(vehid, vehicle_option) = option_nosell;
			Vehicle(vehid, vehicle_distance) = randomEx(0, 15000);
			UnSpawnVeh(vehid);

			Player(playerid, player_option) += option_vehicle;

			format(string, sizeof string,
			    "UPDATE `surv_players` SET `option` = `option` + '"#option_vehicle"' WHERE `uid` = '%d' AND !(`option` & '"#option_vehicle"')",
			    Player(playerid, player_uid)
			);
			mysql_query(string);
			
            ShowInfo(playerid, white"W garażu znalazłeś stary pojazd, który nadaje się jedynie na złomowisko.\nPo kilku godzinach spędzonych przy naprawie pojazdu, wymianie niektórych części udało Ci się odpalić silnik w pojeździe.\n\nZobaczymy.. jak długo pojazd będzie sprawny.");
		}
		case 170:
		{
		    if(!response) return 1;
		    if(Player(playerid, player_height)) return 1;
		    
		    new h = strval(inputtext), string[ 80 ];
			format(string, sizeof string,
			    "UPDATE `surv_players` SET `height` = '%d' WHERE `uid` = '%d'",
			    h,
			    Player(playerid, player_uid)
			);
			mysql_query(string);
			
			Player(playerid, player_height) = h;
			
			if(!(Player(playerid, player_option) & option_vehicle) && Player(playerid, player_timehere)[ 0 ] > 7200)
			{
			    new buffer[ 512 ];
			    for(new x; x != sizeof StartingVehicle; x++)
			        format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, x, NazwyPojazdow[StartingVehicle[ x ] - 400]);
				Dialog::Output(playerid, 11, DIALOG_STYLE_LIST, "Wybierz pojazd startowy", buffer, "Wybierz", "Później");
			}
			else ShowInfo(playerid, green"Dane postaci zaaktualizowane.");
		}
		case 39:
		{
		    if(DIN(inputtext, "Pozycje początkowe"))
		        return SelectSpawn(playerid);
		    else if(DIN(inputtext, "Ostatnia pozycja"))
		    {
			    SetSpawnInfo(playerid, NO_TEAM, Player(playerid, player_skin), Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ], Player(playerid, player_position)[ 3 ], 0, 0, 0, 0, 0, 0);
				FadeColorForPlayer(playerid, 0, 0, 0, 0, 0, 0, 0, 255, 15, 0); // Ściemnienie
				Player(playerid, player_dark) = dark_spawn;
		    }
		    else
		    {
				new dooruid = strval(inputtext),
					string[ 128 ];
		        if(strfind(inputtext, "[HOTEL]", true) != -1)
		        {
					format(string, sizeof string,
						"SELECT `uid`, `in_x`, `in_y`, `in_z`, `in_int` FROM `surv_hotels` WHERE `door_uid` = '%d'",
						dooruid
					);
					mysql_query(string);
				    mysql_store_result();
				    mysql_fetch_row_format(string);
				    mysql_free_result();
				    sscanf(string, "p<|>da<f>[3]d",
				        Player(playerid, player_hotel),
				        Player(playerid, player_position),
				        Player(playerid, player_int)
				    );
				    Player(playerid, player_vw) = Player(playerid, player_uid);
		        }
		        else if(strfind(inputtext, "[DOM]", true) != -1)
		        {
					format(string, sizeof string,
						"SELECT `in_pos_x`, `in_pos_y`, `in_pos_z`, `in_pos_a`, `in_pos_vw`, `in_pos_int` FROM `surv_doors` WHERE `uid` = '%d'",
						dooruid
					);
					mysql_query(string);
				    mysql_store_result();
				    mysql_fetch_row_format(string);
				    mysql_free_result();
				    sscanf(string, "p<|>a<f>[4]dd",
				        Player(playerid, player_position),
				        Player(playerid, player_vw),
				        Player(playerid, player_int)
				    );
			    }
				foreach(Server_Doors, door)
				{
				    if(dooruid == Door(door, door_uid))
				    {
						Player(playerid, player_door) = door;
						break;
					}
				}
				SetSpawnInfo(playerid, NO_TEAM, Player(playerid, player_skin), Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ], Player(playerid, player_position)[ 3 ], 0, 0, 0, 0, 0, 0);
				FadeColorForPlayer(playerid, 0, 0, 0, 0, 0, 0, 0, 255, 15, 0); // Ściemnienie
				Player(playerid, player_dark) = dark_spawn;
			}
		}
		case 60:
		{
		    if(!response) return 1;
		    if(DIN(inputtext, "Ustawienia konta"))
		    {
		        new buffer[ 360 ];
		        format(buffer, sizeof buffer, "Automatyczne /me:\t\t%s\n", YesOrNo(bool:(Player(playerid, player_option) & option_me)));
		        format(buffer, sizeof buffer, "%sZamrożenie przy drzwiach:\t%s\n", buffer, YesOrNo(bool:(Player(playerid, player_option) & option_freeze)));
		        format(buffer, sizeof buffer, "%sPanoramika:\t\t\t%s\n", buffer, YesOrNo(bool:(Player(playerid, player_option) & option_panor)));
		        format(buffer, sizeof buffer, "%sBlokada wiadomości:\t\t%s\n", buffer, YesOrNo(bool:(Player(playerid, player_option) & option_pm)));
		        format(buffer, sizeof buffer, "%sPasek SanNews:\t\t%s\n", buffer, YesOrNo(bool:(Player(playerid, player_option) & option_news)));
				format(buffer, sizeof buffer, "%sWygląd przedmiotów:\t\t%s\n", buffer, (Player(playerid, player_option) & option_textdraw) ? ("TextDraw") : ("GUI"));
				format(buffer, sizeof buffer, "%sNowe strzelanie:\t\t%s\n", buffer, YesOrNo(bool:(Player(playerid, player_option) & option_shooting)));
				if(Player(playerid, player_option) & option_shooting)
					format(buffer, sizeof buffer, "%s\t- Strona:\t\t%s\n", buffer, (Player(playerid, player_option) & option_hand) ? ("Lewa") : ("Prawa"));
				format(buffer, sizeof buffer, "%sAnimacja mowy:\t\t\t%s\n", buffer, YesOrNo(bool:(Player(playerid, player_option) & option_anim_m)));
				format(buffer, sizeof buffer, "%sAnimacja krzyku:\t\t%s\n", buffer, YesOrNo(bool:(Player(playerid, player_option) & option_anim_k)));
				if(Player(playerid, player_fight))
				    format(buffer, sizeof buffer, "%sSztuka walki:\t\t\t%s\n", buffer, YesOrNo(bool:(Player(playerid, player_option) & option_fight)));
				Dialog::Output(playerid, 75, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Ustawienia", buffer, "Wybierz", "Wróć");
		    }
		    else if(DIN(inputtext, "Uprawnienia administratora"))
		    {
		        new buffer[ 1024 ];
		        format(buffer, sizeof buffer, "/kick\t\t\t\t%s\n", YesOrNo(bool:(Player(playerid, player_adminperm) & admin_perm_kick)));
				format(buffer, sizeof buffer, "%s/ban\t\t\t\t%s\n", buffer, YesOrNo(bool:(Player(playerid, player_adminperm) & admin_perm_ban)));
				format(buffer, sizeof buffer, "%s/block\t\t\t\t%s\n", buffer, YesOrNo(bool:(Player(playerid, player_adminperm) & admin_perm_block)));
				format(buffer, sizeof buffer, "%s/set /player\t\t\t%s\n", buffer, YesOrNo(bool:(Player(playerid, player_adminperm) & admin_perm_set)));
				format(buffer, sizeof buffer, "%s/stworz\t\t\t\t%s\n", buffer, YesOrNo(bool:(Player(playerid, player_adminperm) & admin_perm_create)));
				format(buffer, sizeof buffer, "%s/edytuj\t\t\t\t%s\n", buffer, YesOrNo(bool:(Player(playerid, player_adminperm) & admin_perm_edit)));
				format(buffer, sizeof buffer, "%s/slap\t\t\t\t%s\n", buffer, YesOrNo(bool:(Player(playerid, player_adminperm) & admin_perm_slap)));
				format(buffer, sizeof buffer, "%s/bw /freeze\t\t\t%s\n", buffer, YesOrNo(bool:(Player(playerid, player_adminperm) & admin_perm_bw)));
				format(buffer, sizeof buffer, "%s/tp /to /tm\t\t\t%s\n", buffer, YesOrNo(bool:(Player(playerid, player_adminperm) & admin_perm_tp)));
				format(buffer, sizeof buffer, "%s/nogun /noveh /noooc\t\t%s\n", buffer, YesOrNo(bool:(Player(playerid, player_adminperm) & admin_perm_blockad)));
				format(buffer, sizeof buffer, "%s/glob\t\t\t\t%s\n", buffer, YesOrNo(bool:(Player(playerid, player_adminperm) & admin_perm_glob)));
				format(buffer, sizeof buffer, "%s/globdo\t\t\t\t%s\n", buffer, YesOrNo(bool:(Player(playerid, player_adminperm) & admin_perm_globdo)));
				format(buffer, sizeof buffer, "%s/aj\t\t\t\t%s\n", buffer, YesOrNo(bool:(Player(playerid, player_adminperm) & admin_perm_aj)));
				format(buffer, sizeof buffer, "%s/spec\t\t\t\t%s\n", buffer, YesOrNo(bool:(Player(playerid, player_adminperm) & admin_perm_spec)));
				format(buffer, sizeof buffer, "%s/serwer\t\t\t\t%s\n", buffer, YesOrNo(bool:(Player(playerid, player_adminperm) & admin_perm_server)));
		        ShowList(playerid, buffer);
		    }
		}
		case 75:
		{
		    if(!response) return cmd_stats(playerid, "");
		    if(strfind(inputtext, "Automatyczne /me", true) != -1)
		    {
		        if(Player(playerid, player_option) & option_me)
		            Player(playerid, player_option) -= option_me;
				else
				    Player(playerid, player_option) += option_me;
		    }
		    else if(strfind(inputtext, "Zamrożenie przy drzwiach", true) != -1)
		    {
		        if(Player(playerid, player_option) & option_freeze)
		            Player(playerid, player_option) -= option_freeze;
				else
				    Player(playerid, player_option) += option_freeze;
		    }
		    else if(strfind(inputtext, "Panoramika", true) != -1)
		    {
		        if(Player(playerid, player_option) & option_panor)
		        {
		            Player(playerid, player_option) -= option_panor;
		            
					TextDrawHideForPlayer(playerid, Setting(setting_td_box)[ 0 ]);
					TextDrawHideForPlayer(playerid, Setting(setting_td_box)[ 1 ]);
				}
				else
				{
				    Player(playerid, player_option) += option_panor;
				    
					TextDrawShowForPlayer(playerid, Setting(setting_td_box)[ 0 ]);
					TextDrawShowForPlayer(playerid, Setting(setting_td_box)[ 1 ]);
				}
		    }
		    else if(strfind(inputtext, "Blokada wiadomości", true) != -1)
		    {
		        if(Player(playerid, player_option) & option_pm)
		            Player(playerid, player_option) -= option_pm;
				else
				    Player(playerid, player_option) += option_pm;
		    }
		    else if(strfind(inputtext, "Pasek SanNews", true) != -1)
		    {
		        if(Player(playerid, player_option) & option_news)
		        {
		            Player(playerid, player_option) -= option_news;
		            
					TextDrawHideForPlayer(playerid, Setting(setting_sn)[ 0 ]);
					TextDrawHideForPlayer(playerid, Setting(setting_sn)[ 1 ]);
				}
				else
				{
				    Player(playerid, player_option) += option_news;
				    
					TextDrawShowForPlayer(playerid, Setting(setting_sn)[ 0 ]);
					TextDrawShowForPlayer(playerid, Setting(setting_sn)[ 1 ]);
				}
		    }
		    else if(strfind(inputtext, "Nowe strzelanie", true) != -1)
		    {
		        if(Player(playerid, player_option) & option_shooting)
		            Player(playerid, player_option) -= option_shooting;
		        else
		            Player(playerid, player_option) += option_shooting;
		    }
		    else if(strfind(inputtext, "Strona", true) != -1)
		    {
		        if(Player(playerid, player_option) & option_hand)
		            Player(playerid, player_option) -= option_hand;
		        else
		            Player(playerid, player_option) += option_hand;
		    }
		    else if(strfind(inputtext, "Wygląd przedmiotów", true) != -1)
		    {
		        if(Player(playerid, player_option) & option_textdraw)
		        {
		            if(IsPlayerVisibleItems(playerid)) HideItemsTextDraw(playerid);
		            Player(playerid, player_option) -= option_textdraw;
				}
				else
		            Player(playerid, player_option) += option_textdraw;
		    }
			else if(strfind(inputtext, "Animacja mowy", true) != -1)
			{
		        if(Player(playerid, player_option) & option_anim_m)
		            Player(playerid, player_option) -= option_anim_m;
		        else
		            Player(playerid, player_option) += option_anim_m;
			}
			else if(strfind(inputtext, "Animacja krzyku", true) != -1)
			{
		        if(Player(playerid, player_option) & option_anim_k)
		            Player(playerid, player_option) -= option_anim_k;
		        else
		            Player(playerid, player_option) += option_anim_k;
			}
			else if(strfind(inputtext, "Sztuka walki", true) != -1)
			{
		        if(Player(playerid, player_option) & option_fight)
		        {
		            Player(playerid, player_option) -= option_fight;
		            SetPlayerFightingStyle(playerid, FIGHT_STYLE_NORMAL);
				}
		        else
		        {
		            Player(playerid, player_option) += option_fight;
		            SetPlayerFightingStyle(playerid, FightData[ Player(playerid, player_fight) ][ fight_id ]);
				}
			}
		    OnDialogResponseEx(playerid, 60, 1, 0, "Ustawienia konta");
		}
		case 135:
		{
		    if(!response) return 1;
		    new buffer[ 1024 ];
		    switch(listitem)
		    {
		        case 0:
		        {
					strcat(buffer, "Jak zacząć?\n\n");
					strcat(buffer, "Wygląda na to, że potrzebujesz informacji odnośnie rozgrywki.\n\n");
					strcat(buffer, "Niedaleko znajduje się przystanek. Możesz go użyć, by dojechać np. do centrum lub urzędu.\n");
					strcat(buffer, "Długość podróży zależna jest od długości do pokonania. Jeżeli wolisz używać taksówek, kup telefon w sklepie 24/7.");
		        }
		        case 1:
		        {
			        strcat(buffer, "OOC i IC\n\n");
			        strcat(buffer, "Pamiętaj, że RolePlay polega na odgrywaniu realnego życia postaci, którą stworzyłeś(aś).\n");
					strcat(buffer, "1. Wyobraź sobie, że jesteś aktorem, który gra tę postać w serialu. Na tym polega RolePlay.\n");
					strcat(buffer, "2. Aktor nie wie wszystkiego o postaci i jej wirtualnym świecie. Zna też innych aktorów (graczy), którzy grają inne postacie.\n");
					strcat(buffer, "3. Postać NIE wie wszystkiego tego, co aktor, i nie zna wszystkich pozostałych postaci. Ona poprostu żyje w mieście.\n");
					strcat(buffer, "4. Wy - gracze/aktorzy - i wszystko, co wiecie lub piszecie między sobą, to informacje OOC. Realny świat to jest OOC.\n");
					strcat(buffer, "5. Gdy wypowiadasz się jako postać (do innej wirtualnej postaci), bądź wykonujesz nią jakąś czynność, robisz to IC.\n");
					strcat(buffer, "6. Jeżeli chcesz krzyknąć, musisz użyc podwójnego \"!!\"");
		        }
		        case 2:
		        {
		            strcat(buffer, "Podstawowe komendy\n\n");
					strcat(buffer, "/me (opis czynności), /do (opis otoczenia), /c (cicho), /w (wiadomość), /re (odpowiedź)\n");
					strcat(buffer, "/stats, /p(przedmioty), /g (grupy), /v (pojazdy), /o (oferty), /drzwi\n");
					strcat(buffer, "/anim (lista animacji), /pay, /bank\n");
					strcat(buffer, "/raport, /a, /login\n");
		        }
		        case 3:
		        {
		            cmd_anims(playerid, "");
		        }
		        case 4:
		        {
			        strcat(buffer, "Pojazdy\n\n");
					strcat(buffer, "Na naszym serwerze możesz posiadać dowolną ilość pojazdów. Wpisz /v, aby zespawnować lub odspawnować dowolny z pojazdów.\n");
					strcat(buffer, "Użyj /v namierz, gdy nie widzisz swojego pojazdu. Pozwoli Ci to zlokalizować go, ustawiając\n");
					strcat(buffer, "czerwony marker na mapie.");
		        }
		        case 5:
		        {
		            strcat(buffer, "Przedmioty\n\n");
					strcat(buffer, "Przedmioty można zakupić od innych graczy, w ich firmach lub sklepach 24/7.\n");
					strcat(buffer, "Aby wylistować posiadane przedmioty użyj komendy /p.\n");
					strcat(buffer, "Z jej pomocą możesz podnosić przedmioty znajdujące się na ziemi.");
				}
				case 6:
				{
					strcat(buffer, "Oferty\n\n");
					strcat(buffer, "Oferty umożliwiają składanie graczom ofert usług.\n");
					strcat(buffer, "Dzięki nim masz pewność, że gracz zapłaci za daną usługę.\n");
					strcat(buffer, "Wpisz /o, aby sprawdzić jakie możesz składać oferty lub /o [usługa] [gracz] [dodatkowe parametry], by złożyć ofertę.");
				}
				case 7:
				{
					strcat(buffer, "Praca dorywcza\n\n");
					strcat(buffer, "/o naprawa [Gracz] /o tankowanie [Gracz] /o lakierowanie [Gracz] /o paintjob [Gracz] /paczka.\n");
					strcat(buffer, "Możesz także używać przedmiotów mechaników.");
		        }
		        case 8:
		        {
		        	strcat(buffer, "Listy Twoich grup (i sloty): /g\n\n");
					strcat(buffer, "Wypowiedzi poprzedza się jednym znakiem (a nie komendą).\n");
					strcat(buffer, "Znak @ odpowiada za czat OOC, a znak ! - za czat IC. (@Witam, !Witam).\n");
					strcat(buffer, "@1 Cześć! - Napisze wiadomość OOC do całej grupy w slocie 1.\n");
					strcat(buffer, "!2 Cześć! - Napisze wiadomość IC do całej grupy w slocie 2.\n");
		        }
		    }
		    if(listitem != 3) ShowInfo(playerid, buffer);
		}
	}
	return 0;
}

FuncPub::GlobalTimer()
{
	Setting(setting_uptime)++;
	
	static godzina,
		minuta,
		second;
		
	gettime(godzina, minuta, second);
	if(!(minuta % 10) && !second) // Co 10min. :)
	{
		mysql_query("UPDATE `surv_plants` SET `progress` = `progress` + 0.1 WHERE `progress` < 100");
        mysql_reload();
	}
	if(!(second % 3))
	{
	    foreach(Server_Vehicles, carid)
	    {
	        if(!Vehicle(carid, vehicle_engine)) continue;
	        if(GetVehicleMaxFuel(Vehicle(carid, vehicle_model)) == 0) continue;
	        if(Vehicle(carid, vehicle_fuel) < 0.1)
	        {
	            Vehicle(carid, vehicle_fuel) = 0;
				GetVehiclePos(Vehicle(carid, vehicle_vehID), Vehicle(carid, vehicle_position)[ 0 ], Vehicle(carid, vehicle_position)[ 1 ], Vehicle(carid, vehicle_position)[ 2 ]);
				GetVehicleZAngle(Vehicle(carid, vehicle_vehID), Vehicle(carid, vehicle_position)[ 3 ]);
				GetVehicleHealth(Vehicle(carid, vehicle_vehID), Vehicle(carid, vehicle_hp));
				GetVehicleDamageStatus(Vehicle(carid, vehicle_vehID), Vehicle(carid, vehicle_damage)[ 0 ], Vehicle(carid, vehicle_damage)[ 1 ], Vehicle(carid, vehicle_damage)[ 2 ], Vehicle(carid, vehicle_damage)[ 3 ]);

			    new s[ 7 ];
		     	GetVehicleParamsEx(Vehicle(carid, vehicle_vehID), s[ 0 ], s[ 1 ], s[ 2 ], s[ 3 ], s[ 4 ], s[ 5 ], s[ 6 ]);
		      	SetVehicleParamsEx(Vehicle(carid, vehicle_vehID), _:Vehicle(carid, vehicle_engine) = 0, s[ 1 ], s[ 2 ], _:Vehicle(carid, vehicle_lock), s[ 4 ], s[ 5 ], s[ 6 ]);
	        }
	        else Vehicle(carid, vehicle_fuel) -= 0.01;
	    }
	}
	if(!(godzina % 4) && !minuta && !second)
	{
	    LoadWeather();
	}
	if(!minuta && !second)
	{
	    SetWorldTime(godzina);

/*		static string[ 64 ];
		format(string, sizeof string, "** Dzwony w ratuszu biją %d %s. **",
			godzina,
			dli(godzina, "raz", "razy", "razy")
		);
		SendClientMessageToAll(COLOR_PURPLE, string);*/
	}
	if(godzina == 4 && !minuta && !second)
	{
		SendClientMessageToAll(SZARY, "Nocny restart skryptu!");
		foreach(Player, i) SetTimerEx (!#kickPlayer, 249, false, !"i", i);
		
		SetTimer("PayDay", 2000, false);
	}
	foreach(Player, i)
	{
	    if(IsPlayerNPC(i))
			continue;
		if(!Player(i, player_spawned) || !Player(i, player_logged))
			continue;
			
		if(Player(i, player_aj) > 1) Player(i, player_aj)--;
		if(Player(i, player_bw)) Player(i, player_bw)--;
		if(Player(i, player_fish)) Player(i, player_fish)--;
		if(Tren(i, train_time)) Tren(i, train_time)--;
		
		if(Player(i, player_screen))
		{
		    Player(i, player_screen)--;
		    if(!Player(i, player_screen))
		    {
		        if(Player(i, player_duty) && Group(i, Player(i, player_duty), group_option) & group_option_color && Group(i, Player(i, player_duty), group_can) & member_can_duty)
		            Player(i, player_color) = Group(i, Player(i, player_duty), group_color);
				else if(Player(i, player_premium))
				    Player(i, player_color) = player_nick_prem;
				else
					Player(i, player_color) = player_nick_def;
		        UpdatePlayerNick(i);
		        TextDrawHideForPlayer(i, Setting(setting_red));
		    }
		}

		Player(i, player_afktime)[ 0 ]++;
        if(Player(i, player_afktime)[ 0 ] > 5)
        {
			Player(i, player_afktime)[ 1 ]++;
			Player(i, player_afktime)[ 2 ]++;
			UpdatePlayerNick(i);
		}
		if(Player(i, player_afktime)[ 0 ] <= 10)
		{
		    /*if(!(second % 3))
		    {
			    if(GetPlayerVehicleID(i) > 0) Player(i, player_veh) = GetPlayerVehicleID(i);
			    else Player(i, player_veh) = INVALID_VEHICLE_ID;
		    }*/
            Player(i, player_timehere)[ 0 ]++;
            if(!(Player(i, player_timehere)[ 0 ] % 3600))
            {
                new string[ 126 ];
                new d = Player(i, player_premium) ? (15) : (10);
                format(string, sizeof string, "UPDATE `"IN_PREF"members` SET `score` = `score` + '%d' WHERE `member_id` = '%d'", d, Player(i, player_guid));
                SetPlayerScore(i, GetPlayerScore(i) + d);
				mysql_query(string);
            }
		    Player(i, player_timehere)[ 1 ]++;
			static duty;
			duty = Player(i, player_duty);
		    if(duty)
				Group(i, duty, group_duty)++;
		}
		if(Player(i, player_timehere)[ 0 ] >= 36000)
			GivePlayerAchiv(i, achiv_time);

		//if(Phone(i, phone_to) != INVALID_PLAYER_ID && Phone(Phone(i, phone_to), phone_to) == i)
		    //Phone(i, phone_time)++;
		
	    #if !STREAMER
			if(!Player(i, player_bw) && !Player(i, player_aj) && Player(i, player_selected_object) == INVALID_OBJECT_ID && !Player(i, player_vw) && Player(i, player_obj_dist))
			{
				GetPlayerPos(i, Player(i, player_position)[ 0 ], Player(i, player_position)[ 1 ], Player(i, player_position)[ 2 ]);
				if(Player(i, player_obj_dist) < Distance3D(Player(i, player_obj_pos)[ 0 ], Player(i, player_obj_pos)[ 1 ], Player(i, player_obj_pos)[ 2 ], Player(i, player_position)[ 0 ], Player(i, player_position)[ 1 ], Player(i, player_position)[ 2 ]))
				{
				    #if Debug
						new count = GetTickCount();
					#endif
				    LoadPlayerObjects(i, Player(i, player_vw));
				    #if Debug
				        new Float:timedd = floatdiv(GetTickCount() - count, 1000), str[ 32 ];
				        format(str, sizeof str, "Odświeżenie obiektów! %.2f s", timedd);
				    	Chat::Output(i, CLR_GREEN, str);
				    #endif
				}
			}
		#endif

		BW_Timer(i);
		AJ_Timer(i);
		Blood_Timer(i);
		Fish_Timer(i);
		Train_Timer(i);
	    CuffedTimer(i);
		Energy(i);
		Vehicle_Repair(i);
		AntyDos(i);
		AntyCheat(i);
	}
	return 1;
}

FuncPub::PayDay()
{
	#if OFFICIAL
    	mysql_query("UPDATE surv_players p SET p.cash = p.cash + IFNULL((SELECT SUM(r.pay) FROM surv_members m, surv_ranks r WHERE m.player = p.uid AND r.uid = m.rankid AND m.duty > 600), 0.0)");
    	mysql_query("UPDATE surv_members SET `duty` = '0' WHERE duty > 600");
	#endif// WHERE p.lastlogged >= UNIX_TIMESTAMP()-86400
	SetTimer("RestartMode", 30000, false);
    return 1;
}

FuncPub::RestartMode()
{
    SendRconCommand("gmx");
    return 1;
}

FuncPub::AntyDos(playerid)
{
    new stats[ 400 ],
		KBits[ 5 ];
    GetPlayerNetworkStats(playerid, stats, sizeof stats);
    new temp = strfind(stats, "Inst. KBits per second:");
    strmid(KBits, stats, temp+23, sizeof stats);
    new k = strval(KBits);
    if(k > Setting(setting_packet))
	{
		print("Dos Attack");
		Kick(playerid);
	}
	return 1;
}

FuncPub::OptTimer()
{
	foreach(Player, i)
	{
	    if(IsPlayerNPC(i))
			continue;
		if(!Player(i, player_spawned) || !Player(i, player_logged))
			continue;
		if(GetPlayerVehicleID(i) > 0)
		{
			Vehicle_Timer(i);
			CheckRadar(i);
		}
		CheckStreet(i);
	}
	AntyCheatVehicle();
	return 1;
}

FuncPub::Blood_Timer(playerid)
{
/*	if(!Player(playerid, player_blood))
	{
	    // Śmierć
	    //BW(playerid, 30);
	    //Player(playerid, player_blooding) 	= 0;
	    //Player(playerid, player_blood) 		= 0;
	}
	else if(Player(playerid, player_blood) < 2000)
	{
	    ///SetPlayerWeather(playerid, -68);
		//SetPlayerDrunkLevel(playerid, 15000);
	    // Kolory przed oczyma
	}
	else if(Player(playerid, player_blood) < 3000)
	{
	    // 1% szansy na BW
	    new rand = random(100)+1;
	    if(rand == 6)
	    {
	        //BW(playerid, 30);
	    	//Player(playerid, player_blooding) 	= 0;
	    	//Player(playerid, player_blood) 		= 0;
	        // BW
	    }
	}*/
	return 1;
}

FuncPub::Train_Timer(playerid)
{
	if(!Tren(playerid, train_time) && Tren(playerid, train_item))
	{
	    new buffer[ 126 ];
	    ShowInfo(playerid, white"Trening zakończony!");
	    
	    Player(playerid, player_stamina) += 5;
	    
	    format(buffer, sizeof buffer,
            "UPDATE `surv_players` SET `stamina` = '%d' WHERE `uid` = '%d'",
            Player(playerid, player_stamina),
            Player(playerid, player_uid)
		);
		mysql_query(buffer);
		
		format(buffer, sizeof buffer,
		    "DELETE FROM `surv_items` WHERE `uid` = '%d'",
		    Tren(playerid, train_item)
		);
		mysql_query(buffer);
	    
        ClearTrening(playerid);
	}
	else if(Tren(playerid, train_time))
	{
	    new str[ 10 ];
	    format(str, sizeof str, "~w~%d:%d", Tren(playerid, train_time), Tren(playerid, train_count));
	    GameTextForPlayer(playerid, str, 500, 1);
	}
	return 1;
}

FuncPub::Fish_Timer(playerid)
{
	if(!Player(playerid, player_fish) && Player(playerid, player_fish_timer))
	{
	    ShowInfo(playerid, white"Połów zakończony!");
	    KillTimer(Player(playerid, player_fish_timer));
	    Player(playerid, player_fish_timer) = 0;
	    UnFreezePlayer(playerid);
	    RemovePlayerAttachedObject(playerid, 3);
	}
	else if(Player(playerid, player_fish))
	{
	    new str[ 10 ];
	    format(str, sizeof str, "~w~%d", Player(playerid, player_fish));
	    GameTextForPlayer(playerid, str, 500, 1);
	}
	return 1;
}

FuncPub::Fish_Anim(playerid)
{
	ApplyAnimation(playerid,"SWORD","sword_block",50.0,0,1,0,1,1);
	return 1;
}

FuncPub::BW_Timer(playerid)
{
	if(Player(playerid, player_bw) == 1)
	{
		ShowInfo(playerid, white"Ocknąłeś się po utracie przytomności i nic nie pamiętasz.\nNiezwłocznie udaj się do szpitala "white"aby obejrzał Cię lekarz.");
		UnBW(playerid); // TODO
		return 1;
	}
	else if(Player(playerid, player_bw))
	{
	    new string[ 45 ];
		ReturnTime(Player(playerid, player_bw), string);
	    format(string, sizeof string, "~r~BW: ~w~%s", string);
		GameTextForPlayer(playerid, string, 1000, 1);
	    SetPlayerHealth(playerid, Player(playerid, player_hp) = 9999.0);
	    if(!(Player(playerid, player_bw) % 5))
	    	ApplyAnimation(playerid, "PED", "FLOOR_hit", 4.1, 0, 1, 1, 1, 1);
//	    FreezePlayer(playerid);
	}
	return 1;
}

FuncPub::UnBW(playerid)
{
	UnFreezePlayer(playerid);
	ClearAnimations(playerid);
	ClearAnimations(playerid);

	SetPlayerHealth(playerid, Player(playerid, player_hp) = 20.0);
    SetPlayerDrunkLevel(playerid, Player(playerid, player_drunklvl) = 4999);

	Player(playerid, player_bw) = 0;
	return 1;
}

FuncPub::BW(playerid, time)
{
	new string[ 126 ],
	    timeStr[ 45 ];
	Player(playerid, player_bw) = time * 60;
	
	ReturnTime(Player(playerid, player_bw), timeStr);
	
	format(string, sizeof string,
		"Twoja postać straciła przytomność. Odczekaj %s, aby wznowić swoją grę albo czekaj na nadejście pomocy.",
		timeStr
	);
	ShowInfo(playerid, string);
	GivePlayerAchiv(playerid, achiv_bw);
//	OnPlayerLoginOut(playerid);
	return 1;
}

FuncPub::AJ_Timer(playerid)
{
	if(Player(playerid, player_aj) == 2)
	{
		SetPlayerHealth(playerid, Player(playerid, player_hp) = 100.0);
		Player(playerid, player_aj) = 1;
		PlayerSpawn(playerid);
		
		Chat::Output(playerid, 0, white"Czas Twojej kary dobiegł końca, "red"oby czegoś Cię to nauczyło.");
		return 1;
	}
	else if(Player(playerid, player_aj))
	{
	    new string[ 45 ];
	    
		ReturnTime(Player(playerid, player_aj), string);
	    format(string, sizeof string, "~r~AJ: ~w~%s", string);
		GameTextForPlayer(playerid, string, 1000, 1);
	    SetPlayerHealth(playerid, Player(playerid, player_hp) = 100.0);
	}
	return 1;
}

FuncPub::LoadSounds(playerid)
{
	if(!Audio_IsClientConnected(playerid) || IsPlayerNPC(playerid))
	    return 1;
	if(!Player(playerid, player_spawned) || !Player(playerid, player_logged))
		return 1;

	#if Debug
	    printf("LoadSounds(%d)", playerid);
	#endif
	
	Audio_Stop(playerid, Player(playerid, player_heart_sound));
	Player(playerid, player_heart_sound) = 0;

	Audio_Stop(playerid, Player(playerid, player_heart_sound_fast));
	Player(playerid, player_heart_sound_fast) = 0;

	foreach(Server_Doors, doorid)
	{
	    if(Door(doorid, door_option) & door_option_audio_out && Door(doorid, door_sound_out))
		{
			Audio_Stop(playerid, Player(playerid, player_door_out_sound)[ doorid ]);
			Player(playerid, player_door_out_sound)[ doorid ] = Audio_PlayStreamed(playerid, Door(doorid, door_sound_url));
		  	Audio_Set3DPosition(playerid, Player(playerid, player_door_out_sound)[ doorid ], Door(doorid, door_out_pos)[ 0 ], Door(doorid, door_out_pos)[ 1 ], Door(doorid, door_out_pos)[ 2 ], 30.0);
		}
	}
	Energy(playerid);
	
	new string[ 220 ],
		url[ 64 ],
		itemuid;
		
	format(string, sizeof string,
		"SELECT surv_items.uid, surv_cd.url FROM `surv_cd` JOIN `surv_items` ON surv_items.v1 = surv_cd.uid WHERE surv_items.ownerType="#item_place_player" AND surv_items.type = "#item_cdplayer" AND surv_items.owner='%d' AND surv_items.used = '1'",
		Player(playerid, player_uid)
	);
	mysql_query(string);
	mysql_store_result();
	mysql_fetch_row(string);
	mysql_free_result();
	
	sscanf(string, "p<|>ds[64]",
		itemuid,
		url
	);
	
	if(isnull(url) || !itemuid)
		return 1;
	
	Audio_Stop(playerid, Player(playerid, player_cdplayer_sound));
	Player(playerid, player_cdplayer_sound) = Audio_PlayStreamed(playerid, url);
    Player(playerid, player_cdplayer) = itemuid;
    
	new doorid = Player(playerid, player_door);
	if(doorid && Door(doorid, door_option) & door_option_sound && !Player(playerid, player_door_sound))
	{
		if(Audio_IsClientConnected(playerid))
			Player(playerid, player_door_sound) = Audio_PlayStreamed(playerid, Door(doorid, door_sound_url));
		else
		    PlayAudioStreamForPlayer(playerid, Door(doorid, door_sound_url));
	}
	return 1;
}

FuncPub::Energy(playerid)
{
	new victimid = GetPlayerTargetPlayer(playerid);
	if(victimid != INVALID_PLAYER_ID && GetPlayerWeapon(playerid) >= 22)
	    Player(victimid, player_pulse) += 3;

	new minus = -2;
	if(!IsPlayerInAnyVehicle(playerid) && GetPlayerSurfingVehicleID(playerid) != INVALID_VEHICLE_ID)
	{
	    new Float:speed = GetPlayerSpeed(playerid);
	    if(speed >= 17)			minus = 3;
	    else if(speed >= 13)	minus = 2;
	    else if(speed >= 8)		minus = 1;
	    else if(speed >= 1)		minus = -1; // TODO

		if(Player(playerid, player_pulse) >= 200)
		{
	    	//ShowInfo(playerid, red"Nie masz już siły by biec dalej.\n"white"Odczekaj chwilę.");
		    Player(playerid, player_pulse) = 200;
		}
	}
	if((80 <= Player(playerid, player_pulse)))
    	Player(playerid, player_pulse) += minus;
    else if(Player(playerid, player_pulse) > 200)
        Player(playerid, player_pulse) = 200;
	else if(Player(playerid, player_pulse) < 80)
        Player(playerid, player_pulse) = 80;
        
/*	if((75 <= Player(playerid, player_hungry) <= 100)) hungry = "~g~Najedzony";
	else if((50 <= Player(playerid, player_hungry) <= 75)) hungry = "~y~Nasycony";
	else if((25 <= Player(playerid, player_hungry) <= 50)) hungry = "~r~~h~Glodny";
	else hungry = "~r~Bardzo glodny";
	
	if(Player(playerid, player_pulse) >= 140) pulscolor = "~r~";
	else if((100 <= Player(playerid, player_pulse) < 140)) pulscolor = "~y~";
	else pulscolor = "~w~";

	if(Player(playerid, player_blood) < 12000)
	    Player(playerid, player_blood) += 1;
    else if(Player(playerid, player_blood) > 12000)
        Player(playerid, player_blood) = 12000;
        
	if(Player(playerid, player_blooding))
		format(string, sizeof string, "~r~(-%d/s)", Player(playerid, player_blooding));
		
	format(string, sizeof string,
		"Puls: %s%d/min~n~~w~Glod: %d %s~w~~n~Krew: %d%s",
		pulscolor,
		Player(playerid, player_pulse),
		Player(playerid, player_hungry),
		hungry,
		Player(playerid, player_blood),
		string
	);
	PlayerTextDrawSetString(playerid, Player(playerid, player_infos), string);
	*/
	if(!Audio_IsClientConnected(playerid)) return 1;
	
	if(Player(playerid, player_pulse) >= 140 && !Player(playerid, player_heart_sound_fast))
	{
		if(Player(playerid, player_heart_sound))
		{
			Audio_Stop(playerid, Player(playerid, player_heart_sound));
			Player(playerid, player_heart_sound) = 0;
		}
		Player(playerid, player_heart_sound_fast) = Audio_Play(playerid, heart_sound_fast, .loop = true);
		Audio_SetVolume(playerid, Player(playerid, player_heart_sound_fast), 80);
	}
	else if((100 <= Player(playerid, player_pulse) < 140) && !Player(playerid, player_heart_sound))
	{
	    if(Player(playerid, player_heart_sound_fast))
	    {
			Audio_Stop(playerid, Player(playerid, player_heart_sound_fast));
			Player(playerid, player_heart_sound_fast) = 0;
		}
		Player(playerid, player_heart_sound) = Audio_Play(playerid, heart_sound, .loop = true);
		Audio_SetVolume(playerid, Player(playerid, player_heart_sound), 40);
	}
	else if(Player(playerid, player_pulse) < 100 && Player(playerid, player_heart_sound))
	{
		Audio_Stop(playerid, Player(playerid, player_heart_sound));
		Player(playerid, player_heart_sound) = 0;
		
		Audio_Stop(playerid, Player(playerid, player_heart_sound_fast));
		Player(playerid, player_heart_sound_fast) = 0;
	}
	return 1;
}

FuncPub::UpdatePlayerNick(playerid)
{
	new opis[ 2 ][ 126 ],
		playernick[ 126 + MAX_PLAYER_NAME ],
		opis_name[ 13 ][ 16 ],
		under_name[ 4 ][ 16 ];

	if(Player(playerid, player_bw))
		opis_name[ 0 ] = (Player(playerid, player_sex) == sex_woman) ? ("nieprzytomna") : ("nieprzytomny");
    if(Player(playerid, player_pasy))
        opis_name[ 1 ] = "zapięte pasy";
    if(Player(playerid, player_premium))
        opis_name[ 2 ] = "konto premium";
	//if(3000 < Player(playerid, player_stamina) < 3025)
		//format(opis_name[ 3 ], sizeof opis_name[ ], "%dj siły", Player(playerid, player_stamina));
	//else if(3025 <= Player(playerid, player_stamina))
		//opis_name[ 3 ] = (Player(playerid, player_sex) == sex_woman) ? ("wysportowana") : ("muskularny");
	if(Player(playerid, player_mask))
        opis_name[ 4 ] = "ukryta twarz";
   	if(Player(playerid, player_timehere)[ 0 ] < 7200)
        opis_name[ 5 ] = "nowy gracz";
	if(Player(playerid, player_skuty) != INVALID_PLAYER_ID)
	    opis_name[ 6 ] = (Player(playerid, player_sex) == sex_woman) ? ("skuta") : ("skuty");
	if(Player(playerid, player_hp) < 20.0)
	    opis_name[ 7 ] = (Player(playerid, player_sex) == sex_woman) ? ("ranna") : ("ranny");
    if(Group(playerid, Player(playerid, player_duty), group_option) & group_option_color && Player(playerid, player_duty) && Group(playerid, Player(playerid, player_duty), group_can) & member_can_duty)
        format(opis_name[ 8 ], sizeof opis_name[ ], Group(playerid, Player(playerid, player_duty), group_tag));
    if(Player(playerid, player_veh) != INVALID_VEHICLE_ID && Vehicle(Player(playerid, player_veh), vehicle_option) & option_window)
        opis_name[ 9 ] = "szyba zamknięta";
    if(Player(playerid, player_drunklvl) > 5000)
        opis_name[ 10 ] = (Player(playerid, player_sex) == sex_woman) ? ("upita") : ("upity");
/*	if(Player(playerid, player_blooding))
        opis_name[ 9 ] = "krwawi";
	if(Player(playerid, player_hungry) < 25)
	    opis_name[ 10 ] = (Player(playerid, player_sex) == sex_woman) ? ("głodna") : ("głodny");*/
	if(Player(playerid, player_knebel))
	    opis_name[ 11 ] = (Player(playerid, player_sex) == sex_woman) ? ("zakneblowana") : ("zakneblowany");
	if(Player(playerid, player_worek))
	    opis_name[ 12 ] = "worek na głowie";
	    
	if(3000 < Player(playerid, player_stamina))
	    format(under_name[ 0 ], sizeof under_name[ ], "%dj", Player(playerid, player_stamina));
	if(Player(playerid, player_height))
        format(under_name[ 1 ], sizeof under_name[ ], "%dcm", Player(playerid, player_height));
    if(Player(playerid, player_drunklvl) > 5000)
        under_name[ 2 ] = "%";
	if(IsPlayerNPC(playerid))
	    under_name[ 3 ] = "BOT";

	for(new i; i < sizeof under_name; i++)
	{
	    if(isnull(under_name[ i ])) continue;
	    format(opis[ 1 ], sizeof opis[ ], "%s%s, ", opis[ 1 ], under_name[ i ]);
	}
	if(!isnull(opis[ 1 ]))
	{
		opis[ 1 ][ strlen(opis[ 1 ]) - 2 ] = ')';
		format(opis[ 1 ], sizeof opis[  ], "\n(%s", opis[ 1 ]);
	}

	// -----
	if(Player(playerid, player_afktime)[ 0 ] > 5)
	{
	    ReturnTimeMega(Player(playerid, player_afktime)[ 0 ], opis[ 0 ], sizeof opis[ ]);
	    format(opis[ 0 ], sizeof opis[ ], "AFK: %s, ", opis[ 0 ]);
	}
	else
	{
		for(new i; i < sizeof opis_name; i++)
		{
		    if(isnull(opis_name[ i ])) continue;
		    format(opis[ 0 ], sizeof opis[  ], "%s%s, ", opis[ 0 ], opis_name[ i ]);
			//if(!(i % 4) && i != sizeof opis_name-1) strcat(opis[ 0 ], "\n");
		}
	}
	if(!isnull(opis[ 0 ]))
	{
		opis[ 0 ][ strlen(opis[ 0 ]) - 2 ] = ')';
		format(opis[ 0 ], sizeof opis[ ], "\n(%s", opis[ 0 ]);
	}
	if(GetPlayerVehicleID(playerid) > 0 && Player(playerid, player_veh) != INVALID_VEHICLE_ID && Vehicle(Player(playerid, player_veh), vehicle_option) & option_dark)
	{
		if(isnull(AdminLvl[ Player(playerid, player_adminlvl) ][ admin_tag ]) && Player(playerid, player_aduty))
			format(playernick, sizeof playernick, "{%06x}%s\n{%06x}%s (%d)%s%s", Player(playerid, player_screen) ? Player(playerid, player_color) >>> 8 : AdminLvl[ Player(playerid, player_adminlvl) ][ admin_color ] >>> 8, AdminLvl[ Player(playerid, player_adminlvl) ][ admin_name ], Player(playerid, player_color) >>> 8, NickName(playerid), playerid, opis[ 1 ], opis[ 0 ]);
		else if(Player(playerid, player_adminlvl) && Player(playerid, player_aduty))
			format(playernick, sizeof playernick, "{%06x}%s (%s)\n{%06x}%s (%d)%s%s", Player(playerid, player_screen) ? Player(playerid, player_color) >>> 8 : AdminLvl[ Player(playerid, player_adminlvl) ][ admin_color ] >>> 8, AdminLvl[ Player(playerid, player_adminlvl) ][ admin_name ], AdminLvl[ Player(playerid, player_adminlvl) ][ admin_tag ], Player(playerid, player_color) >>> 8, NickName(playerid), playerid, opis[ 1 ], opis[ 0 ]);
		else
			format(playernick, sizeof playernick, "%s%s", opis[ 1 ], opis[ 0 ]);
	}
	else
	{
		if(isnull(AdminLvl[ Player(playerid, player_adminlvl) ][ admin_tag ]) && Player(playerid, player_aduty))
			format(playernick, sizeof playernick, "{%06x}%s\n{%06x}%s (%d)%s%s", Player(playerid, player_screen) ? Player(playerid, player_color) >>> 8 : AdminLvl[ Player(playerid, player_adminlvl) ][ admin_color ] >>> 8, AdminLvl[ Player(playerid, player_adminlvl) ][ admin_name ], Player(playerid, player_color) >>> 8, NickName(playerid), playerid, opis[ 1 ], opis[ 0 ]);
		else if(Player(playerid, player_adminlvl) && Player(playerid, player_aduty))
			format(playernick, sizeof playernick, "{%06x}%s (%s)\n{%06x}%s (%d)%s%s", Player(playerid, player_screen) ? Player(playerid, player_color) >>> 8 : AdminLvl[ Player(playerid, player_adminlvl) ][ admin_color ] >>> 8, AdminLvl[ Player(playerid, player_adminlvl) ][ admin_name ], AdminLvl[ Player(playerid, player_adminlvl) ][ admin_tag ], Player(playerid, player_color) >>> 8, NickName(playerid), playerid, opis[ 1 ], opis[ 0 ]);
		else if(Player(playerid, player_duty) && Player(playerid, player_mask) && Group(playerid, Player(playerid, player_duty), group_option) & group_option_color && Group(playerid, Player(playerid, player_duty), group_can) & member_can_duty)
			format(playernick, sizeof playernick, "{%06x}%s (%dh)%s%s", Player(playerid, player_screen) ? Player(playerid, player_color) >>> 8 : Group(playerid, Player(playerid, player_duty), group_color) >>> 8, NickName(playerid), floatval(Player(playerid, player_timehere)[ 0 ]/3600), opis[ 1 ], opis[ 0 ]);
		else if(Player(playerid, player_mask))
			format(playernick, sizeof playernick, "%s (%dh)%s%s", NickName(playerid), floatval(Player(playerid, player_timehere)[ 0 ]/3600), opis[ 1 ], opis[ 0 ]);
		else if(Player(playerid, player_duty) && Group(playerid, Player(playerid, player_duty), group_option) & group_option_color && Group(playerid, Player(playerid, player_duty), group_can) & member_can_duty)
			format(playernick, sizeof playernick, "{%06x}%s (%d, %dh)%s%s", Player(playerid, player_screen) ? Player(playerid, player_color) >>> 8 : Group(playerid, Player(playerid, player_duty), group_color) >>> 8, NickName(playerid), playerid, floatval(Player(playerid, player_timehere)[ 0 ]/3600), opis[ 1 ], opis[ 0 ]);
		else
			format(playernick, sizeof playernick, "%s (%d, %dh)%s%s", NickName(playerid), playerid, floatval(Player(playerid, player_timehere)[ 0 ]/3600), opis[ 1 ], opis[ 0 ]);
	}
	if(Player(playerid, player_tag) != Text3D:INVALID_3DTEXT_ID)
		Update3DTextLabelText(Player(playerid, player_tag), Player(playerid, player_color), playernick);
//	print(playernick);
	return 1;
}

FuncPub::PlayerSpawn(playerid)
{
    new buffer[ 512 ],
		string[ 200 ],
		count = 1;
		
	if(!Player(playerid, player_aj) && !Player(playerid, player_jail))
	    strcat(buffer, "Ostatnia pozycja\n");
   	strcat(buffer, "Pozycje początkowe\n");
    
    format(string, sizeof string,
		"SELECT d.uid, d.name, m.type FROM `surv_doors` d JOIN `surv_members` m ON m.id = d.uid WHERE m.player = '%d' AND m.type != "#member_type_group"",
		Player(playerid, player_uid)
	);
	mysql_query(string);
	mysql_store_result();
	while(mysql_fetch_row(string))
	{
	    static uid,
			name[ MAX_ITEM_NAME ],
			type;
			
	    sscanf(string, "p<|>ds["#MAX_ITEM_NAME"]d",
	        uid,
	        name,
	        type
		);
		if(type == member_type_doors)
			format(buffer, sizeof buffer, "%s%d\t[DOM]\t\t%s\n", buffer, uid, name);
		else if(type == member_type_hotel)
			format(buffer, sizeof buffer, "%s%d\t[HOTEL]\t%s\n", buffer, uid, name);
		else continue;
		count++;
	}
	mysql_free_result();
	if(count)
	{
	    if(Player(playerid, player_aj))
		    Player(playerid, player_aj) = 0;
		if(Player(playerid, player_jail))
            Player(playerid, player_jail) = 0;
            
		Dialog::Output(playerid, 39, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Miejsce spawnu", buffer, "Wybierz", "");
	}
	else
	{
		SetSpawnInfo(playerid, NO_TEAM, Player(playerid, player_skin), Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ], Player(playerid, player_position)[ 3 ], 0, 0, 0, 0, 0, 0);

		FadeColorForPlayer(playerid, 0, 0, 0, 0, 0, 0, 0, 255, 15, 0); // Ściemnienie
		Player(playerid, player_dark) = dark_spawn;
	}
	return 1;
}

FuncPub::SelectSpawn(playerid)
{
	#if Debug
	    printf("SelectSpawn(%d)", playerid);
	#endif
	new buffer[ 256 ],
		str[ 64 ];
		
	mysql_query("SELECT `uid`, `name` FROM `surv_spawns`");
 	mysql_store_result();
  	while(mysql_fetch_row_format(str))
	{
		static uid,
			name[ 40 ];
			
		sscanf(str, "p<|>ds[32]",
			uid,
			name
		);
		format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, uid, name);
	}
	mysql_free_result();
	Dialog::Output(playerid, 1, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Miejsce spawnu", buffer, "Wybierz", "");
	return 1;
}

FuncPub::LoadPlayerJailPos(playerid)
{
	new string[ 64 ],
		jailuid;
		
	mysql_query("SELECT j.uid, j.in_x, j.in_y, j.in_z, d.in_pos_vw, d.in_pos_int FROM `surv_jail` j JOIN `surv_doors` d ON d.uid = j.door_uid ORDER BY RAND()");
	mysql_store_result();
	mysql_fetch_row(string);
	mysql_free_result();
	
	sscanf(string, "p<|>da<f>[3]dd",
	    jailuid,
		Player(playerid, player_position),
		Player(playerid, player_vw),
		Player(playerid, player_int)
	);
	
    if((Player(playerid, player_jail) - gettime()) < (24 * 60 * 60))
        Player(playerid, player_jail_timer) = SetTimerEx("Un_Jail", (Player(playerid, player_jail) - gettime()) * 1000, false, "dd", playerid, jailuid);

	SetSpawnInfo(playerid, NO_TEAM, Player(playerid, player_skin), Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ], Player(playerid, player_position)[ 3 ], 0, 0, 0, 0, 0, 0);

	FadeColorForPlayer(playerid, 0, 0, 0, 0, 0, 0, 0, 255, 15, 0); // Ściemnienie
	Player(playerid, player_dark) = dark_spawn;
	return 1;
}

FuncPub::Un_Jail(playerid, jailuid)
{
	new string[ 126 ];
	
	format(string, sizeof string,
		"SELECT `out_x`, `out_y`, `out_z` FROM `surv_jail` WHERE `uid` = '%d'",
		jailuid
	);
	mysql_query(string);
	mysql_store_result();
	mysql_fetch_row(string);
	mysql_free_result();
	
	sscanf(string, "p<|>a<f>[3]",
		Player(playerid, player_position)
	);
	
    ShowInfo(playerid, white"Wyszedłeś z więzienia.");// TODO

	SetPlayerPosEx(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ], Player(playerid, player_position)[ 3 ]);

	KillTimer(Player(playerid, player_jail_timer));
	Player(playerid, player_jail_timer) = 0;
	Player(playerid, player_jail) = 0;
    format(string, sizeof string,
        "UPDATE `surv_players` SET `jail` = '%d' WHERE `uid` = '%d'",
		Player(playerid, player_uid)
	);
	mysql_query(string);
	return 1;
}

public OnFadeComplete(playerid, beforehold)
{
	switch(Player(playerid, player_dark))
	{
		case dark_camera:
		{
		    FadeColorForPlayer(playerid, 0, 0, 0, 255, 0, 0, 0, 0, 15, 0); // Rozjaśnienie
			Player(playerid, player_dark) = dark_none;
			OnPlayerCameraChange(playerid);
		}
		case dark_spawn:
		{
		    TogglePlayerSpectating(playerid, 0);
		    FadeColorForPlayer(playerid, 0, 0, 0, 255, 0, 0, 0, 0, 15, 0); // Rozjaśnienie
			Player(playerid, player_dark) = dark_none;
			KillTimer(Player(playerid, player_cam_timer));
			Player(playerid, player_cam_timer) = 0;
		    SpawnPlayer(playerid);
		}
		case dark_login:
		{
		    if(!Player(playerid, player_login_timer))
		    	Player(playerid, player_login_timer) = SetTimerEx("loginTimer", 30000, false, "d", playerid);
		    FadeColorForPlayer(playerid, 0, 0, 0, 255, 0, 0, 0, 0, 15, 0); // Rozjaśnienie
			Player(playerid, player_dark) = dark_none;
			OnPlayerCameraChange(playerid);
		}
		case dark_door_in:
		{
		    new i = Player(playerid, player_door);
		    
	    	SetPlayerPosEx(playerid, Door(i, door_in_pos)[ 0 ], Door(i, door_in_pos)[ 1 ], Door(i, door_in_pos)[ 2 ], Door(i, door_in_pos)[ 3 ]);
			SetPlayerVirtualWorld(playerid, Player(playerid, player_vw) = Door(i, door_in_vw));
	       	SetPlayerInterior(playerid, Player(playerid, player_int) = Door(i, door_in_int));
	       	OnPlayerEnterInterior(playerid, i);
	       	TogglePlayerControllable(playerid, false);
	       	
		    FadeColorForPlayer(playerid, 0, 0, 0, 255, 0, 0, 0, 0, 15, 0); // Rozjaśnienie
			Player(playerid, player_dark) = dark_door_in2;
		}
		case dark_door_in2:
		{
		    TogglePlayerControllable(playerid, true);
			if(Player(playerid, player_option) & option_freeze)
			{
			    TogglePlayerControllable(playerid, false);
			    SetTimerEx("UnFreezePlayer", 3000, 0, "d", playerid);
			}
		}
		case dark_door_out:
		{
		    new i = Player(playerid, player_door);

			SetPlayerPosEx(playerid, Door(i, door_out_pos)[ 0 ], Door(i, door_out_pos)[ 1 ], Door(i, door_out_pos)[ 2 ], Door(i, door_out_pos)[ 3 ]);
			SetPlayerVirtualWorld(playerid, Player(playerid, player_vw) = Door(i, door_out_vw));
           	SetPlayerInterior(playerid, Player(playerid, player_int) = Door(i, door_out_int));
           	OnPlayerExitInterior(playerid, i);
           	TogglePlayerControllable(playerid, false);

		    FadeColorForPlayer(playerid, 0, 0, 0, 255, 0, 0, 0, 0, 15, 0); // Rozjaśnienie
			Player(playerid, player_dark) = dark_door_out2;
		}
		case dark_door_out2:
		{
		    TogglePlayerControllable(playerid, true);
			if(Player(playerid, player_option) & option_freeze)
			{
			    TogglePlayerControllable(playerid, false);
			    SetTimerEx("UnFreezePlayer", 3000, 0, "d", playerid);
			}
		}
		case dark_hotel:
		{
			new string[ 200 ],
				dooruid;
				
			format(string, sizeof string,
				"SELECT surv_hotels.*, surv_doors.in_pos_vw, surv_doors.in_pos_int FROM `surv_hotels` JOIN `surv_doors` ON surv_doors.uid = surv_hotels.door_uid WHERE surv_hotels.uid = '%d'",
				Player(playerid, player_hotel)
			);
			mysql_query(string);
			mysql_store_result();
			mysql_fetch_row(string);
			mysql_free_result();

			sscanf(string, "p<|>{da<f>[3]d}a<f>[3]ddd",
				Player(playerid, player_position),
				dooruid,
				Player(playerid, player_vw),
				Player(playerid, player_int)
			);

			SetPlayerPosEx(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ], Player(playerid, player_position)[ 3 ]);
			SetPlayerVirtualWorld(playerid, Player(playerid, player_vw));
           	SetPlayerInterior(playerid, Player(playerid, player_int));
		    FadeColorForPlayer(playerid, 0, 0, 0, 255, 0, 0, 0, 0, 15, 0); // Rozjaśnienie
			Player(playerid, player_dark) = dark_none;

			foreach(Server_Doors, doorid)
			{
			    if(Door(doorid, door_uid) == dooruid)
			    {
					Player(playerid, player_door) = doorid;
					break;
				}
			}

		    Player(playerid, player_hotel) = 0;
		}
		case dark_character:
		{
		    PreloadAnimLibraries(playerid);
			SelectPlayer(playerid);
			SetPlayerDrunkLevel(playerid, 0);
		    FadeColorForPlayer(playerid, 0, 0, 0, 255, 0, 0, 0, 0, 15, 0); // Rozjaśnienie
			Player(playerid, player_dark) = dark_none;
		}
		case dark_kick:
		{
		    Kick(playerid);
		}
	}
	return 1;
}

FuncPub::TimerCameraChange(playerid)
{
	#if Debug
	    printf("TimerCameraChange(%d)", playerid);
	#endif
	FadeColorForPlayer(playerid, 0, 0, 0, 0, 0, 0, 0, 255, 15, 0); // Ściemnienie
	Player(playerid, player_dark) = dark_camera;
	return 1;
}

FuncPub::OnPlayerCameraChange(playerid)
{
	#if Debug
	    printf("OnPlayerCameraChange(%d)", playerid);
	#endif
	new string[ 100 ],
  		Float:pos[ 3 ],
  		Float:rpos[ 3 ];
  
    format(string, sizeof string,
		"SELECT * FROM `surv_cams` WHERE `uid` != '%d' ORDER BY RAND() LIMIT 1",
		Player(playerid, player_cam)
	);
    mysql_query(string);
	mysql_store_result();
 	mysql_fetch_row_format(string);
 	sscanf(string, "p<|>da<f>[3]a<f>[3]",
 	    Player(playerid, player_cam),
	 	pos,
	 	rpos
	);
	mysql_free_result();

 	SetPlayerCameraPos(playerid, pos[ 0 ], pos[ 1 ], pos[ 2 ]);
	SetPlayerCameraLookAt(playerid, rpos[ 0 ], rpos[ 1 ], rpos[ 2 ]);
	SetPlayerPos(playerid, pos[ 0 ], pos[ 1 ], pos[ 2 ] + 20.0);
	return 1;
}

FuncPub::OnPlayerLoginOut(playerid)
{
	#if Debug
	    printf("OnPlayerLoginOut(%d)", playerid);
	#endif
	if(Player(playerid, player_spawned))
	{
		GetPlayerPos(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]);
		GetPlayerFacingAngle(playerid, Player(playerid, player_position)[ 3 ]);
		Player(playerid, player_vw) = GetPlayerVirtualWorld(playerid);
		Player(playerid, player_int) = GetPlayerInterior(playerid);
		Player(playerid, player_drunklvl) = GetPlayerDrunkLevel(playerid);
	}
	if(Player(playerid, player_hp) > 100.0) Player(playerid, player_hp) = 100.0;
	if(Player(playerid, player_hp) < 0.0) Player(playerid, player_hp) = 0.0;
	new string[ 512 ];
	format(string, sizeof string,
		"UPDATE `surv_players` SET `timehere` = '%d', `visits` = '%d', `cash` = '%.2f', `block` = '%d', `x` = '%f', `y` = '%f', `z` = '%f', `a` = '%f', `int` = '%d', `vw` = '%d', `door` = '%d', `hp` = '%f', `aj` = '%d', `bw` = '%d', `jail` = '%d', `job` = '%d', `drunklvl` = '%d', `option` = '%d', `achiv` = '%d', `afktime` = '%d', `dist` = '%f', `veh_dist` = '%f', `lastlogged` = UNIX_TIMESTAMP() WHERE `uid` = '%d'",
		Player(playerid, player_timehere)[ 0 ],
		Player(playerid, player_visits),
		Player(playerid, player_cash),
		Player(playerid, player_block),
		Player(playerid, player_position)[ 0 ],
		Player(playerid, player_position)[ 1 ],
		Player(playerid, player_position)[ 2 ],
		Player(playerid, player_position)[ 3 ],
		Player(playerid, player_int),
		Player(playerid, player_vw),
		Door(Player(playerid, player_door), door_uid),
		Player(playerid, player_hp),
		Player(playerid, player_aj),
		Player(playerid, player_bw),
		Player(playerid, player_jail),
		Player(playerid, player_job),
		Player(playerid, player_drunklvl),
		Player(playerid, player_option),
		Player(playerid, player_achiv),
		Player(playerid, player_afktime)[ 1 ],
		Player(playerid, player_dist),
		Player(playerid, player_veh_dist),
		Player(playerid, player_uid)
	);
	mysql_query(string);
	
	if(Player(playerid, player_duty))
	{
	    format(string, sizeof string,
			"UPDATE `surv_members` SET `duty` = `duty` + '%d' WHERE `player` = '%d' AND (type = "#member_type_group" AND id = '%d')",
			Group(playerid, Player(playerid, player_duty), group_duty),
			Player(playerid, player_uid),
			Group(playerid, Player(playerid, player_duty), group_uid)
		);
	    mysql_query(string);
	    Player(playerid, player_duty) = 0;
	    Group(playerid, Player(playerid, player_duty), group_duty) = 0;
	}
	if(Weapon(playerid, 1, weapon_uid) || Weapon(playerid, 0, weapon_uid))
	{
		if(Weapon(playerid, 0, weapon_model) == Weapon(playerid, 1, weapon_model) && Weapon(playerid, 0, weapon_model))
		{
		    new ammo = GetWeaponAmmo(playerid, Weapon(playerid, 0, weapon_model));

			new tammo = ammo;
			ammo = ammo/2 + ammo % 2;

	        format(string, sizeof string,
				"UPDATE `surv_items` SET `used` = 0, `v2` = '%d' WHERE `uid` = '%d'",
				tammo-ammo,
				Weapon(playerid, 1, weapon_uid)
			);
			mysql_query(string);
			ClearWeapon(playerid, 1);

	        format(string, sizeof string,
				"UPDATE `surv_items` SET `used` = 0, `v2` = '%d' WHERE `uid` = '%d'",
				tammo-ammo,
				Weapon(playerid, 0, weapon_uid)
			);
			mysql_query(string);
			ClearWeapon(playerid, 0);
		}
		else
		{
		    for(new x; x != MAX_WEAPON; x++)
		    {
		        if(!Weapon(playerid, x, weapon_uid)) continue;
		        if(!Weapon(playerid, x, weapon_model)) continue;
		        new ammo = GetWeaponAmmo(playerid, Weapon(playerid, x, weapon_model));

		        format(string, sizeof string,
					"UPDATE `surv_items` SET `used` = 0, `v2` = '%d' WHERE `uid` = '%d'",
					ammo,
					Weapon(playerid, x, weapon_uid)
				);
				mysql_query(string);
				ClearWeapon(playerid, x);
		    }
		}
	}
	ResetPlayerWeapons(playerid);

	if(Player(playerid, player_rolki))
	{
	    format(string, sizeof string,
			"UPDATE `surv_items` SET `used` = 0 WHERE `ownerType`="#item_place_player" AND `owner`='%d' AND `type` ="#item_rolki"",
			Player(playerid, player_uid)
		);
		mysql_query(string);
		Player(playerid, player_rolki) = false;
	}
	if(Player(playerid, player_veh) != INVALID_VEHICLE_ID)
	{
	    SaveVeh(Player(playerid, player_veh));
	    Player(playerid, player_veh) = INVALID_VEHICLE_ID;
	}
	format(string, sizeof string,
		"UPDATE `surv_orders` SET `status` = '"#pack_status_none"' WHERE `drive` = '%d' AND `status` = "#pack_status_road"",
		Player(playerid, player_uid)
	);
	mysql_query(string);
	
	format(string, sizeof string,
		"UPDATE `surv_items` SET `v2` = '%d' WHERE `uid` = '%d'",
		Tren(playerid, train_time),
		Tren(playerid, train_item)
	);
	mysql_query(string);
	
	for(new kurid; kurid != MAX_KURIER; kurid++)
		for(new eKurier:d; d < eKurier; d++)
		    Kurier(playerid, kurid, d) = 0;
		    
	for(new b; b != MAX_BLOKADA; b++)
	{
		if(!IsValidDynamicObject(Player(playerid, player_blockade)[ b ])) continue;
		DestroyDynamicObject(Player(playerid, player_blockade)[ b ]);
	}
	if(Repair(playerid, repair_type) && Repair(playerid, repair_time))
	{
		if(Repair(playerid, repair_type) == repair_comp || Repair(playerid, repair_type) == repair_inveh || Repair(playerid, repair_type) == repair_repair || Repair(playerid, repair_type) == repair_spray)
		{
	    	new victimid = Repair(playerid, repair_player);
	    	
	        if(Repair(playerid, repair_type) == repair_repair)
	        	GivePlayerMoneyEx(victimid, Repair(victimid, repair_value2) + Repair(playerid, repair_cash), true);
			else
	        	GivePlayerMoneyEx(victimid, Repair(playerid, repair_cash), true);

			if(Repair(playerid, repair_type) == repair_comp || Repair(playerid, repair_type) == repair_inveh)
				GameTextForPlayer(victimid, Repair(playerid, repair_type) == repair_comp ? ("~w~Tuning ~r~anulowany") : ("~w~Naprawa ~r~anulowana"), 1000, 3);
			else if(Repair(playerid, repair_type) == repair_spray)
			    GameTextForPlayer(victimid, "~n~~r~Malowanie przerwane!", 3000, 4);
		}
	}
	End_Repair(playerid);
	End_Create(playerid);
	Bank_Clear(playerid);
	ClearNark(playerid);
	ClearOffer(playerid);
	ClearRace(playerid);
	EndCall(playerid);
	ClearTrening(playerid);
//	ClearPhone(playerid);
	
	if(Player(playerid, player_spectated))
	{
	    foreach(Player, i)
	    {
	        if(Player(i, player_spec) != playerid) continue;
	        
	    	TogglePlayerSpectating(i, 0);
			SetCameraBehindPlayer(i);
			Player(i, player_spec) = INVALID_PLAYER_ID;
	    }
	}
	return 1;
}

FuncPub::OnPlayerLoginIn(playerid)
{
	if(!Player(playerid, player_uid)) return SetTimerEx (!#kickPlayer, 249, false, !"i", playerid);
	#if Debug
	    printf("OnPlayerLoginIn(%d)", playerid);
	#endif
	new string[ 256 ],
		pl_lastlogged;
	format(string, sizeof string,
		"SELECT * FROM `surv_players` WHERE `uid` = '%d' AND `guid` = '%d' LIMIT 1",
		Player(playerid, player_uid),
		Player(playerid, player_guid)
	);
	mysql_query(string);
    mysql_store_result();
    if(!mysql_num_rows())
    {
        SetTimerEx (!#kickPlayer, 249, false, !"i", playerid);
    	mysql_free_result();
    	return 1;
    }
    mysql_fetch_row_format(string);
    sscanf(string, "p<|>dds["#MAX_PLAYER_NAME"]da<f>[4]dddddddddfdddfdddddddddddddddddffd",
        Player(playerid, player_guid),
        Player(playerid, player_uid),
        Player(playerid, player_name),
        Player(playerid, player_height),
        Player(playerid, player_position),
        Player(playerid, player_int),
        Player(playerid, player_vw),
        Player(playerid, player_door),
        Player(playerid, player_visits),
        Player(playerid, player_timehere)[ 0 ],
        Player(playerid, player_block),
        Player(playerid, player_bw),
        Player(playerid, player_aj),
        Player(playerid, player_jail),
        Player(playerid, player_cash),
        Player(playerid, player_skin),
        Player(playerid, player_sex),
        Player(playerid, player_age),
        Player(playerid, player_hp),
		Player(playerid, player_achiv),
        Player(playerid, player_lang),
        Player(playerid, player_option),
        Player(playerid, player_pulse),
        Player(playerid, player_blood),
        Player(playerid, player_blooding),
        Player(playerid, player_hungry),
        Player(playerid, player_fight),
        Player(playerid, player_stamina),
        Player(playerid, player_druglvl),
        Player(playerid, player_drunklvl),
       	Player(playerid, player_anim_chat),
        Player(playerid, player_mask),
        Player(playerid, player_job),
        Player(playerid, player_opis),
        Player(playerid, player_pkt),
        Player(playerid, player_afktime)[ 1 ],
        Player(playerid, player_dist),
        Player(playerid, player_veh_dist),
        pl_lastlogged
	);
	mysql_free_result();

	if(Player(playerid, player_block) & block_ban)
	{
		Chat::Output(playerid, RED, "Ta postać jest zbanowana!");
		cmd_login(playerid, "");
		return 1;
	}
	else if(Player(playerid, player_block) & block_ck)
	{
		Chat::Output(playerid, RED, "Ta postać nie żyje!");
		cmd_login(playerid, "");
		return 1;
	}
	else if(Player(playerid, player_block) & block_block)
	{
		Chat::Output(playerid, RED, "Ta postać jest zablokowana!");
		cmd_login(playerid, "");
		return 1;
	}
#if Locked
    else if(!(Player(playerid, player_option) & option_connect))
        return SetTimerEx (!#kickPlayer, 249, false, !"i", playerid);
#endif

	if(Player(playerid, player_door))
	{
		foreach(Server_Doors, door)
		{
		    if(Player(playerid, player_door) == Door(door, door_uid))
		    {
				Player(playerid, player_door) = door;
				SetPlayerWeather(playerid, 2);
				break;
			}
		}
	}
	SetPlayerName(playerid, Player(playerid, player_name));
	SetPlayerMoney(playerid, Player(playerid, player_cash));
    SetPlayerColor(playerid, 0xFFFFFF00);
	if(Player(playerid, player_cam_timer))
	{
		KillTimer(Player(playerid, player_cam_timer));
		Player(playerid, player_cam_timer) = 0;
	}
	if(Player(playerid, player_login_timer))
	{
		KillTimer(Player(playerid, player_login_timer));
    	Player(playerid, player_login_timer) = 0;
	}
    
	Player(playerid, player_logged)	= true;
	Player(playerid, player_visits)++;
	UpdateInfos();
	
	if(Player(playerid, player_premium))
	    Player(playerid, player_color) = player_nick_prem;
	else
		Player(playerid, player_color) = player_nick_def;
		
	
	if(Player(playerid, player_tag) == Text3D:INVALID_3DTEXT_ID)
	{
		new nametag[ MAX_PLAYER_NAME + 7 ];
		format(nametag, sizeof nametag, "%s (%d)", NickName(playerid), playerid);
		Player(playerid, player_tag) = Create3DTextLabel(nametag, Player(playerid, player_color), 0.0, 0.0, 0.0, 14.0, 1, true);
		Attach3DTextLabelToPlayer(Player(playerid, player_tag), playerid, 0.0, 0.0, 0.17);
	}
	
	format(string, sizeof string,
		"INSERT INTO `all_online` VALUES ('"#type_rp"', '%d', '%d', UNIX_TIMESTAMP())",
		Player(playerid, player_uid),
		playerid
	);
	mysql_query(string);

	format(string, sizeof string,
		"Witaj, "C_BLUE2"%s "white"na postaci: "C_BLUE2"%s "grey"(UID: %d, GUID: %d, ID: %d)"white". Miłej gry!",
		Player(playerid, player_gname),
		NickSamp(playerid, true),
		Player(playerid, player_uid),
		Player(playerid, player_guid),
		playerid
	);
	Chat::Output(playerid, CLR_WHITE, string);

	#if !STREAMER
    	for(new t = 1; t != MAX_OBJECTS; t++) Object(playerid, t, obj_objID) = INVALID_OBJECT_ID;
	#endif
    for(new t = 1; t != MAX_3DTEXT_PLAYER; t++) Text(playerid, t, text_textID) = PlayerText3D:INVALID_3DTEXT_ID;

    LoadPlayerTextDraws(playerid);
    LoadPlayerGroups(playerid);
	LoadPlayerOpis(playerid);
	LoadIcons(playerid);
	ShowPlayerZone(playerid);
	ShowCountOfMessages(playerid);
	UpdatePlayerNick(playerid);
	LoadPlayerFriends(playerid);
	RemovePlayerBuilds(playerid);

	GameTextForPlayer(playerid, "~w~Zostales ~y~Zalogowany!", 3000, 1);
    GivePlayerAchiv(playerid, achiv_login);

	if(!Player(playerid, player_timehere)[ 0 ])
	{
	    format(string, sizeof string, "Ubranie(%d)", Player(playerid, player_skin));
	    Createitem(playerid, item_cloth, Player(playerid, player_skin), 0, 0.0, string, 200);

		SelectSpawn(playerid);
	}
	else if(Player(playerid, player_aj))
	{
	    Player(playerid, player_position)[ 0 ] = Setting(setting_aj)[ 0 ];
		Player(playerid, player_position)[ 1 ] = Setting(setting_aj)[ 1 ];
		Player(playerid, player_position)[ 2 ] = Setting(setting_aj)[ 2 ];
		SetSpawnInfo(playerid, NO_TEAM, Player(playerid, player_skin), Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ], Player(playerid, player_position)[ 3 ], 0, 0, 0, 0, 0, 0);

		FadeColorForPlayer(playerid, 0, 0, 0, 0, 0, 0, 0, 255, 15, 0); // Ściemnienie
		Player(playerid, player_dark) = dark_spawn;
	}
	else if(gettime() < Player(playerid, player_jail))
	{
		LoadPlayerJailPos(playerid);
	}
	else if(Player(playerid, player_bw) || (gettime() - pl_lastlogged) < 15*60)
	{
		SetSpawnInfo(playerid, NO_TEAM, Player(playerid, player_skin), Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ], Player(playerid, player_position)[ 3 ], 0, 0, 0, 0, 0, 0);

		FadeColorForPlayer(playerid, 0, 0, 0, 0, 0, 0, 0, 255, 15, 0); // Ściemnienie
		Player(playerid, player_dark) = dark_spawn;
	}
	else PlayerSpawn(playerid);
	return 1;
}
