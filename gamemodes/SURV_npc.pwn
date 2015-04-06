FuncPub::LoadNPC()
{
	for(new n; n != sizeof NpcData; n++)
	{
        NPC(n, npc_playerid) = INVALID_PLAYER_ID;

		if(isnull(NPC(n, npc_file)))
			NPC(n, npc_playerid) =ConnectRNPC(NPC(n, npc_name));
		else
	    	ConnectNPC(NPC(n, npc_name), NPC(n, npc_file));
	    	
	    if(NPC(n, npc_vehicle))
	    {
			static carid;
		    if(NPC(n, npc_vehicle) != 577)
		    	carid = AddStaticVehicle(NPC(n, npc_vehicle), 0.0, 0.0, 0.0, 200.0, -1, -1);
		    else
		    	carid = CreateVehicle(NPC(n, npc_vehicle), 0.0, 0.0, 0.0, 0.0, -1, -1, -1);
	        Vehicle(carid, vehicle_vehID) = carid;
	        NPC(n, npc_vehicle) = carid;
        }
	}
	for(new carid; carid != MAX_VEHICLES; carid++)
	{
	    if(!GetVehicleModel(carid)) continue;
	    
        Vehicle(carid, vehicle_hp) = 1000.0;
        Vehicle(carid, vehicle_owner)[ 0 ] = vehicle_owner_npc;
        Vehicle(carid, vehicle_fuel) = 9999999;
        OnVehicleSpawn(carid);
        SetVehicleParamsEx(Vehicle(carid, vehicle_vehID), _:Vehicle(carid, vehicle_engine) = true, 1, 0, _:Vehicle(carid, vehicle_lock) = false, 0, 0, 0);
        Itter_Add(Server_Vehicles, Vehicle(carid, vehicle_vehID));
	}

	printf("# Boty zosta³y wczytane! | %d", sizeof NpcData);
	return 1;
}

FuncPub::NPC_OnPlayerConnect(playerid)
{
    SetPlayerColor(playerid, 0xFFFFFF00);
    SetPlayerHealth(playerid, 99999.0);
    Player(playerid, player_hp) 		= 99999.0;
    Player(playerid, player_logged)  	= true;
    Player(playerid, player_option)  	= option_anim_m + option_me + option_pm;
    GetPlayerName(playerid, Player(playerid, player_name), MAX_PLAYER_NAME);
    
	if(Player(playerid, player_tag) == Text3D:INVALID_3DTEXT_ID)
	{
		new nametag[ MAX_PLAYER_NAME ];
		format(nametag, sizeof nametag, "%s", NickName(playerid));
		Player(playerid, player_tag) = Create3DTextLabel(nametag, Player(playerid, player_color), 0.0, 0.0, 0.0, 14.0, 1);
		Attach3DTextLabelToPlayer(Player(playerid, player_tag), playerid, 0.0, 0.0, 0.17);
        UpdatePlayerNick(playerid);
	}
	return 1;
}

FuncPub::NPC_OnPlayerRequestClass(playerid, classid)
{
	for(new n; n != sizeof NpcData; n++)
	{
	    if(!strcmp(NickSamp(playerid), NPC(n, npc_name), true))
	    {
	        NPC(n, npc_playerid) = playerid;
	        if(NPC(n, npc_function) == npc_func_drive)
	        	SetSpawnInfo(playerid, 69, NPC(n, npc_skin), 1462.0745, 2630.8787, 10.8203, 0.0, -1, -1, -1, -1, -1, -1);
	        else
	            SetSpawnInfo(playerid, 69, NPC(n, npc_skin), NPC(n, npc_pos)[ 0 ], NPC(n, npc_pos)[ 1 ], NPC(n, npc_pos)[ 2 ], NPC(n, npc_pos)[ 3 ], -1, -1, -1, -1, -1, -1);
	    }
	}
	return 1;
}

FuncPub::NPC_OnPlayerSpawn(playerid)
{
	for(new n; n != sizeof NpcData; n++)
	{
	    if(!strcmp(NickSamp(playerid), NPC(n, npc_name), true))
	    {
	        if(NPC(n, npc_function) == npc_func_drive)
	        {
		    	PutPlayerInVehicle(playerid, NPC(n, npc_vehicle), 0);
	    	}
	    	else if(NPC(n, npc_function) == npc_func_gov)
	    	{
	    	    /*SetPlayerPos(playerid, NPC(n, npc_pos)[ 0 ], NPC(n, npc_pos)[ 1 ], NPC(n, npc_pos)[ 2 ]);
	    	    SetPlayerFacingAngle(playerid, NPC(n, npc_pos)[ 3 ]);*/
	    		if(NPC(n, npc_door))
				{
					foreach(Server_Doors, door)
					{
					    if(NPC(n, npc_door) == Door(door, door_uid))
					    {
							SetPlayerVirtualWorld(playerid, Door(door, door_in_vw));
		               		SetPlayerInterior(playerid, Door(door, door_in_int));
							SetPlayerWeather(playerid, 2);
							NPC(n, npc_door) = door;
							break;
						}
					}
				}
	    	}
	    	else if(NPC(n, npc_function) == npc_func_achiv)
	    	{
	    	    NPC_SetRandomPos(n, playerid);
	    	}
	    	if(!isnull(NPC(n, npc_opis)) && Player(playerid, player_opis_id) == Text3D:INVALID_3DTEXT_ID)
	    	{
	    	    wordwrap(NPC(n, npc_opis));
				Player(playerid, player_opis_id) = Create3DTextLabel(NPC(n, npc_opis), opis_color, 0.0, 0.0, 0.0, 5.0, 0, 1);
				Attach3DTextLabelToPlayer(Player(playerid, player_opis_id), playerid, 0.0, 0.0, -0.6);
	    	}
			Player(playerid, player_spawned) = true;
		}
	}
	return 1;
}

FuncPub::NPC_SetRandomPos(n, playerid)
{
	new str[ 126 ];
    format(str, sizeof str,
    	"SELECT * FROM `surv_npc` WHERE `uid` != '%d' ORDER BY RAND()",
    	NPC(n, npc_door)
    );
    mysql_query(str);
    mysql_store_result();
    mysql_fetch_row(str);
    sscanf(str, "p<|>da<f>[4]", NPC(n, npc_door), NPC(n, npc_pos));
    mysql_free_result();
    SetPlayerPos(playerid, NPC(n, npc_pos)[ 0 ], NPC(n, npc_pos)[ 1 ], NPC(n, npc_pos)[ 2 ]);
    SetPlayerFacingAngle(playerid, NPC(n, npc_pos)[ 3 ]);
    
    if(!NPC(n, npc_timer))
    {
        NPC(n, npc_timer) = SetTimerEx("NPC_Message", randomEx(10000, 30000), true, "dd", n, playerid);
    }
	return 1;
}

FuncPub::NPC_Message(n, playerid)
{
	for(new d; d != sizeof NpcMessage; d++)
	{
	    if(NPC(n, npc_function) != NpcMessage[d][msg_function]) continue;
	    
	    OnPlayerText(playerid, NpcMessage[d][msg_text]);
	}
	return 1;
}
