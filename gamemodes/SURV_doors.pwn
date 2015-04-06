FuncPub::LoadDoors()
{
	new string[ 256 ],
		doorid = 1;
	mysql_query("SELECT surv_doors.*, surv_cd.url FROM `surv_doors` LEFT JOIN `surv_cd` ON surv_doors.sound = surv_cd.uid");
	mysql_store_result();
	while(mysql_fetch_row_format(string))
	{
		if(doorid == MAX_DOORS) break;

		sscanf(string, "p<|>ds["#MAX_ITEM_NAME"]s[5]dda<d>[2]fa<f>[4]dda<f>[4]ddddd{d}s[64]",
			Door(doorid, door_uid), Door(doorid, door_name),
			Door(doorid, door_number), Door(doorid, door_street),
			Door(doorid, door_close), Door(doorid, door_owner), Door(doorid, door_pay),
			Door(doorid, door_in_pos), Door(doorid, door_in_vw), Door(doorid, door_in_int),
			Door(doorid, door_out_pos), Door(doorid, door_out_vw), Door(doorid, door_out_int),
			Door(doorid, door_pickup), Door(doorid, door_option),
			Door(doorid, door_to), Door(doorid, door_sound_url)
		);
		
		if(Door(doorid, door_pickup))
		{
			new pickupid;
			pickupid = CreatePickup(Door(doorid, door_pickup), 2, Door(doorid, door_out_pos)[ 0 ], Door(doorid, door_out_pos)[ 1 ], Door(doorid, door_out_pos)[ 2 ], Door(doorid, door_out_vw));
	        Pickup(pickupid, pickup_model) 		= Door(doorid, door_pickup);
	        Pickup(pickupid, pickup_type) 		= 0;
			Pickup(pickupid, pickup_pos)[ 0 ] 	= Door(doorid, door_out_pos)[ 0 ];
			Pickup(pickupid, pickup_pos)[ 1 ] 	= Door(doorid, door_out_pos)[ 1 ];
			Pickup(pickupid, pickup_pos)[ 2 ] 	= Door(doorid, door_out_pos)[ 2 ];
	        Pickup(pickupid, pickup_vw) 		= Door(doorid, door_out_vw);
	        Pickup(pickupid, pickup_owner)[ 0 ]	= pickup_type_door;
	        Pickup(pickupid, pickup_owner)[ 1 ] = doorid;
	        Pickup(pickupid, pickup_sampID)     = pickupid;
			Door(doorid, door_pickupID) 		= Pickup(pickupid, pickup_sampID);
		}
        if(DIN(Door(doorid, door_sound_url), "NULL"))
            Door(doorid, door_sound_url)[ 0 ] = EOS;

		Itter_Add(Server_Doors, doorid);
		doorid++;
	}
	mysql_free_result();
	printf("# Drzwi zostały wczytane! | %d", doorid-1);
	return 1;
}

FuncPub::SaveDoor(doorid)
{
	new buffer[ 100 ];
	format(buffer, sizeof buffer,
		"UPDATE `surv_doors` SET `option` = '%d', `close` = '%d', `pay` = '%.2f' WHERE `uid` = '%d'",
        Door(doorid, door_option),
        Door(doorid, door_close),
        Door(doorid, door_pay),
        Door(doorid, door_uid)
	);
	mysql_query(buffer);
	return 1;
}

FuncPub::DeleteDoor(doorid)
{
	new string[ 80 ];
	format(string, sizeof string,
		"DELETE FROM `surv_doors` WHERE `uid` = '%d'",
		Door(doorid, door_uid)
	);
	mysql_query(string);
	
	format(string, sizeof string,
	    "DELETE FROM `surv_objects` WHERE `door` = '%d'",
	    Door(doorid, door_uid)
	);
	mysql_query(string);
	
	#if STREAMER
		for(new objectid; objectid < Streamer_GetUpperBound(STREAMER_TYPE_OBJECT); objectid++)
		{
			if(!IsValidDynamicObject(objectid))
				continue;
		    if(!Streamer_IsInArrayData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_WORLD_ID, Door(doorid, door_in_vw)))
				continue;

			new c;
			for(; c < MAX_OBJECTS; c++)
			    if(Object(c, obj_objID) == objectid)
			        break;
	        if(c != MAX_OBJECTS)
	        {
	            for(new eObjects:i; i < eObjects; i++)
					Object(c, i) = 0;
				Object(c, obj_objID) = INVALID_OBJECT_ID;
			}
		}
	#endif

	if(Door(doorid, door_pickupID))
		DestroyPickup(Door(doorid, door_pickupID));
  	Itter_Remove(Server_Doors, doorid);

	for(new ePickup:i; i < ePickup; i++)
    	Pickup(Door(doorid, door_pickupID), i) = 0;

	for(new eDoors:i; i < eDoors; i++)
    	Door(doorid, i) = 0;
    	
	return 1;
}

FuncPub::CreateDoor(name[], ownerType, owner, Float:out_pos_x, Float:out_pos_y, Float:out_pos_z, Float:out_pos_a, out_pos_int, out_pos_vw, interior_uid, pickup)
{
	new doorid = 1;
	for(; doorid != MAX_DOORS; doorid++)
	    if(!Door(doorid, door_uid))
	        break;

	if(doorid == MAX_DOORS) return 0;
    new Float:in_pos[ 4 ],
		in_int;

	new string[ 256 ];
	format(string, sizeof string,
	    "SELECT `x`, `y`, `z`, `a`, `int` FROM `surv_int` WHERE `uid` = '%d'",
		interior_uid
	);
	mysql_query(string);
	mysql_store_result();
	mysql_fetch_row(string);
	sscanf(string, "p<|>a<f>[4]d", in_pos, in_int);
	mysql_free_result();
	
	format(string, sizeof string,
	    "INSERT INTO `surv_doors` VALUES (NULL, '%s', '0', '0', '0', '%d', '%d', '0', '%f', '%f', '%f', '%f', '0', '%d', '%f', '%f', '%f', '%f', '%d', '%d', '%d', 0, 0, 0)",
	    name,
	    ownerType,
	    owner,
	    in_pos[ 0 ],
	    in_pos[ 1 ],
	    in_pos[ 2 ],
	    in_pos[ 3 ],
	    in_int,
		out_pos_x,
		out_pos_y,
		out_pos_z,
		out_pos_a,
		out_pos_vw,
		out_pos_int,
		pickup
	);
	mysql_query(string);

	Door(doorid, door_uid) = Door(doorid, door_in_vw) = mysql_insert_id();
	format(Door(doorid, door_name), MAX_ITEM_NAME, name);
	Door(doorid, door_owner)[ 0 ] = ownerType;
	Door(doorid, door_owner)[ 1 ] = owner;
	Door(doorid, door_in_pos)[ 0 ] = in_pos[ 0 ];
	Door(doorid, door_in_pos)[ 1 ] = in_pos[ 1 ];
	Door(doorid, door_in_pos)[ 2 ] = in_pos[ 2 ];
	Door(doorid, door_in_pos)[ 3 ] = in_pos[ 3 ];
	Door(doorid, door_in_int) = in_int;
	Door(doorid, door_out_pos)[ 0 ] = out_pos_x;
	Door(doorid, door_out_pos)[ 1 ] = out_pos_y;
	Door(doorid, door_out_pos)[ 2 ] = out_pos_z;
	Door(doorid, door_out_pos)[ 3 ] = out_pos_a;
	Door(doorid, door_out_vw) = out_pos_vw;
	Door(doorid, door_out_int) = out_pos_int;
	Door(doorid, door_pickup) = pickup;
	
	format(string, sizeof string,
		"UPDATE `surv_doors` SET `in_pos_vw` = '%d' WHERE `uid` = '%d'",
	    Door(doorid, door_in_vw),
	    Door(doorid, door_uid)
	);
	mysql_query(string);
	
	Itter_Add(Server_Doors, doorid);

	if(Door(doorid, door_pickup))
	{
		new pickupid;
		pickupid = CreatePickup(Door(doorid, door_pickup), 2, Door(doorid, door_out_pos)[ 0 ], Door(doorid, door_out_pos)[ 1 ], Door(doorid, door_out_pos)[ 2 ], Door(doorid, door_out_vw));
        Pickup(pickupid, pickup_model) 		= Door(doorid, door_pickup);
        Pickup(pickupid, pickup_type) 		= 0;
		Pickup(pickupid, pickup_pos)[ 0 ] 	= Door(doorid, door_out_pos)[ 0 ];
		Pickup(pickupid, pickup_pos)[ 1 ] 	= Door(doorid, door_out_pos)[ 1 ];
		Pickup(pickupid, pickup_pos)[ 2 ] 	= Door(doorid, door_out_pos)[ 2 ];
        Pickup(pickupid, pickup_vw) 		= Door(doorid, door_out_vw);
        Pickup(pickupid, pickup_owner)[ 0 ]	= pickup_type_door;
        Pickup(pickupid, pickup_owner)[ 1 ] = doorid;
        Pickup(pickupid, pickup_sampID)     = Door(doorid, door_pickupID) = pickupid;
	}
	return doorid;
}

stock CanPlayerOpenDoor(playerid, doorid)
{
	if(Player(playerid, player_adminlvl) && Player(playerid, player_aduty))
	    return true;

	new num,
		string[ 160 ];
	format(string, sizeof string,
		"SELECT 1 FROM `surv_items` WHERE `type` = "#item_key" AND `v1` = "#key_type_doors" AND `v2` = '%d' AND `ownerType`="#item_place_player" AND `owner`='%d'",
		Door(doorid, door_uid),
		Player(playerid, player_uid)
	);
	mysql_query(string);
	mysql_store_result();
	num = mysql_num_rows();
	mysql_free_result();

	if(num)
	    return true;
	if(Door(doorid, door_owner)[ 0 ] == door_type_group)
	{
	    new groupid = IsPlayerInUidGroup(playerid, Door(doorid, door_owner)[ 1 ]);
	    if(groupid && Group(playerid, groupid, group_can) & member_can_door)
			return true;
	}
	else if(Door(doorid, door_owner)[ 0 ] == door_type_house)
	{
	    if(Door(doorid, door_owner)[ 1 ] == Player(playerid, player_uid))
	        return true;
	    format(string, sizeof string,
			"SELECT 1 FROM `surv_members` WHERE `player` = '%d' AND `type` = "#member_type_doors" AND `id` = '%d'",
			Player(playerid, player_uid),
			Door(doorid, door_uid)
		);
		mysql_query(string);
		mysql_store_result();
		num = mysql_num_rows();
		mysql_free_result();
		if(num)
		    return true;
	}
	return false;
}

stock CanPlayerProductBuy(playerid, doorid)
{
	if(Door(doorid, door_owner)[ 0 ] == door_type_group)
	{
	    new groupid = IsPlayerInUidGroup(playerid, Door(doorid, door_owner)[ 1 ]);
	    if(!groupid)
			return -1;
	    if(Group(playerid, groupid, group_can) & member_can_product)
			return groupid;
	}
	else if(Door(doorid, door_owner)[ 0 ] == door_type_house)
	{
	    if(Door(doorid, door_owner)[ 1 ] == Player(playerid, player_uid))
	        return 0;
	}
	return -1;
}

stock CanPlayerProductSell(playerid, doorid)
{
	if(Door(doorid, door_owner)[ 0 ] == door_type_group)
	{
	    new groupid = IsPlayerInUidGroup(playerid, Door(doorid, door_owner)[ 1 ]);
	    if(!groupid)
			return -1;
	    if(Group(playerid, groupid, group_can) & member_can_sell)
			return groupid;
	}
	else if(Door(doorid, door_owner)[ 0 ] == door_type_house)
	{
	    if(Door(doorid, door_owner)[ 1 ] == Player(playerid, player_uid))
	        return 0;
	}
	return -1;
}

stock IsPlayerDoorOwner(playerid, doorid)
{
	if(Player(playerid, player_adminlvl) && Player(playerid, player_aduty))
	    return true;

	if(Door(doorid, door_owner)[ 0 ] == door_type_group)
	{
	    new groupid = IsPlayerInUidGroup(playerid, Door(doorid, door_owner)[ 1 ]);
	    if(!groupid)
	        return -1;
	    if(Group(playerid, groupid, group_can) & member_can_door_opt)
			return groupid;
	}
	else if(Door(doorid, door_owner)[ 0 ] == door_type_house)
	{
	    if(Door(doorid, door_owner)[ 1 ] == Player(playerid, player_uid))
	        return 0;
	}
	return -1;
}

stock GetPlayerDoor(playerid, bool:out = true)
{
/*	new doorid = Player(playerid, player_door);
	if(!doorid)
	{*/
	new pl_vw = Player(playerid, player_vw);
	if(out)
	{
		foreach(Server_Doors, i)
		    if((IsPlayerInRangeOfPoint(playerid, 1.5, Door(i, door_out_pos)[ 0 ], Door(i, door_out_pos)[ 1 ], Door(i, door_out_pos)[ 2 ]) && pl_vw == Door(i, door_out_vw))
			|| (IsPlayerInRangeOfPoint(playerid, 1.5, Door(i, door_in_pos)[ 0 ], Door(i, door_in_pos)[ 1 ], Door(i, door_in_pos)[ 2 ]) && pl_vw == Door(i, door_in_vw)))
				return i;
	}
	else
	{
		foreach(Server_Doors, i)
		    if((IsPlayerInRangeOfPoint(playerid, 1.5, Door(i, door_in_pos)[ 0 ], Door(i, door_in_pos)[ 1 ], Door(i, door_in_pos)[ 2 ]) && pl_vw == Door(i, door_in_vw)))
				return i;
	}
	if(Player(playerid, player_door))
	    return Player(playerid, player_door);
//	}
	return false;
}

FuncPub::Door_OnPlayerPickUpPickup(playerid, pickupid)
{
	if(Pickup(pickupid, pickup_owner)[ 0 ] == pickup_type_door)
	{
	    new doorid = Pickup(pickupid, pickup_owner)[ 1 ],
			string[ 126 ];
			
	   	if(Door(doorid, door_close)) PlayerTextDrawBoxColor(playerid, Player(playerid, player_door_td)[ 2 ], 0xFF0000AA);
		else PlayerTextDrawBoxColor(playerid, Player(playerid, player_door_td)[ 2 ], 13107290);
		
		if(Player(playerid, player_adminlvl) && Player(playerid, player_aduty)) format(string, sizeof string, " ~w~(UID: %d)", Door(doorid, door_uid));
		
        if(Door(doorid, door_pay))
		   	format(string, sizeof string, "%s%s~n~~y~Wstep: ~w~$%.2f~n~~n~Nacisnij [~k~~SNEAK_ABOUT~] oraz [~k~~PED_SPRINT~]", Door(doorid, door_name), string, Door(doorid, door_pay));
       	else
			format(string, sizeof string, "%s%s~n~~n~~n~~w~Nacisnij [~k~~SNEAK_ABOUT~] oraz [~k~~PED_SPRINT~]", Door(doorid, door_name), string);

        EscapePL(string);
       	PlayerTextDrawSetString(playerid, Player(playerid, player_door_td)[ 0 ], string);
   		PlayerTextDrawShow(playerid, Player(playerid, player_door_td)[ 0 ]);
   		PlayerTextDrawShow(playerid, Player(playerid, player_door_td)[ 1 ]);
   		PlayerTextDrawShow(playerid, Player(playerid, player_door_td)[ 2 ]);

	   	new strid;
	    for(; strid != MAX_STREET; strid++)
	        if(Door(doorid, door_street) == Street(strid, street_uid))
	            break;
   		if(strid)
   		{
			format(string, sizeof string,
				"%s %s",
				Street(strid, street_name),
				Door(doorid, door_number)
			);
			
			PlayerTextDrawSetString(playerid, Player(playerid, player_street), string);
			PlayerTextDrawShow(playerid, Player(playerid, player_street));
   		}
   		KillTimer(Player(playerid, player_door_timer));
   		Player(playerid, player_door_timer) = 0;
   		Player(playerid, player_door_timer) = SetTimerEx("OnPlayerHideDoorTD", 5000, false, "d", playerid);
	}
	return 1;
}

FuncPub::OnPlayerHideDoorTD(playerid)
{
    PlayerTextDrawHide(playerid, Player(playerid, player_door_td)[ 0 ]);
    PlayerTextDrawHide(playerid, Player(playerid, player_door_td)[ 1 ]);
    PlayerTextDrawHide(playerid, Player(playerid, player_door_td)[ 2 ]);
    KillTimer(Player(playerid, player_door_timer)); Player(playerid, player_door_timer) = 0;
    
    if(!GetPlayerStreet(playerid))
        PlayerTextDrawHide(playerid, Player(playerid, player_street));
	return 1;
}

FuncPub::Doors_OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(Create(playerid, create_type) == create_edit_inside && !Player(playerid, player_adminlvl))
	    return ShowCMD(playerid, "Nie możesz wyjść z interioru edytując pozycje wewnętrzną.");

	if(PRESSED(KEY_SPRINT + KEY_WALK))
	{
	    new pl_vw = Player(playerid, player_vw);
		foreach(Server_Doors, i)
		{
  			if(pl_vw == Door(i, door_out_vw) && IsPlayerInRangeOfPoint(playerid, 1.5, Door(i, door_out_pos)[ 0 ], Door(i, door_out_pos)[ 1 ], Door(i, door_out_pos)[ 2 ]))
			{
				if(Door(i, door_close))
				{
				    new sound[ ] = {doors_sound_lock};
				    Audio_Play(playerid, sound[ random(sizeof sound) ]);
				    GameTextForPlayer(playerid, "~r~Zamkniete", 3000, 3);
				    break;
				}
				if(Player(playerid, player_rolki))
				    return ShowInfo(playerid, red"Nie możesz wejść do środka w rolkach!");
                if(Door(i, door_pay))
                {
                    new res = CanPlayerOpenDoor(playerid, i);
                    if(!res)
                    {
					   	if(Door(i, door_pay) > Player(playerid, player_cash))
		   				    return GameTextForPlayer(playerid,"~r~Nie masz tyle gotowki", 3000, 3);
		   				new string[ 126 ];
		   				format(string, sizeof string,
		   				    "UPDATE `surv_groups` SET `cash` = `cash` + '%.2f' WHERE `uid` = '%d'",
		   				    Door(i, door_pay),
		   				    Door(i, door_owner)[ 1 ]
						);
						mysql_query(string);
						
						format(string, sizeof string,
							"INSERT INTO `surv_groups_log` VALUES (NULL, '%d', '0', '%d', UNIX_TIMESTAMP(), '%.2f', 'Wejscie')",
							Door(i, door_owner)[ 1 ],
							Player(playerid, player_uid),
							Door(i, door_pay)
						);
						mysql_query(string);

		   				GivePlayerMoneyEx(playerid, 0 - Door(i, door_pay), true);
					}
   				}
   				Player(playerid, player_door) = i;
   				Audio_Play(playerid, doors_sound_open);
				FadeColorForPlayer(playerid, 0, 0, 0, 0, 0, 0, 0, 255, 15, 0); // Ściemnienie
   				Player(playerid, player_dark) = dark_door_in;
   				return 1;
			}
  			else if(pl_vw == Door(i, door_in_vw) && IsPlayerInRangeOfPoint(playerid, 1.5, Door(i, door_in_pos)[ 0 ], Door(i, door_in_pos)[ 1 ], Door(i, door_in_pos)[ 2 ]))
			{
				if(Door(i, door_close))
				{
				    new sound[ ] = {doors_sound_lock};
				    Audio_Play(playerid, sound[ random(sizeof sound) ]);
				    GameTextForPlayer(playerid, "~r~Zamkniete", 3000, 3);
				    break;
				}
   				Player(playerid, player_door) = i;
   				Audio_Play(playerid, doors_sound_open);
				FadeColorForPlayer(playerid, 0, 0, 0, 0, 0, 0, 0, 255, 15, 0); // Ściemnienie
   				Player(playerid, player_dark) = dark_door_out;
				return 1;
			}
		}
		if(Player(playerid, player_hotel))
		{
		    if(Player(playerid, player_hotel_close)) return GameTextForPlayer(playerid, "~r~Pokoj zamkniety", 3000, 3);
			Audio_Play(playerid, doors_sound_open);
			FadeColorForPlayer(playerid, 0, 0, 0, 0, 0, 0, 0, 255, 15, 0); // Ściemnienie
			Player(playerid, player_dark) = dark_hotel;
		}
	}
	return 1;
}

FuncPub::OnPlayerEnterInterior(playerid, doorid)
{
   	Player(playerid, player_door) = doorid;
   	SetPlayerWeather(playerid, 2);

    #if !STREAMER
		LoadPlayerObjects(playerid, Door(doorid, door_in_vw));
	#endif
	LoadPlayerText(playerid, Door(doorid, door_in_vw));
	OnPlayerHideDoorTD(playerid);
	if(Door(doorid, door_option) & door_option_sound && !Player(playerid, player_door_sound))
	{
		if(Audio_IsClientConnected(playerid))
			Player(playerid, player_door_sound) = Audio_PlayStreamed(playerid, Door(doorid, door_sound_url));
		else
		    PlayAudioStreamForPlayer(playerid, Door(doorid, door_sound_url));
	}
	if(Player(playerid, player_option) & option_freeze)
	{
	    TogglePlayerControllable(playerid, false);
	    SetTimerEx("UnFreezePlayer", 3000, 0, "d", playerid);
	}
	if(Door(doorid, door_to))
	{
	    foreach(Server_Doors, d)
	    {
	        if(Door(d, door_uid) != Door(doorid, door_to)) continue;
	    	Player(playerid, player_door) = d;
	    	break;
		}
	}
	
	switch(Door(doorid, door_owner)[ 0 ])
	{
	    case door_type_bingo: ShowCMD(playerid, "Znajdujesz się w sklepie z ubraniami. Jeżeli chcesz zakupić ubranie, wystarczy, że wpiszesz /ubranie");
	    case door_type_hotel: ShowCMD(playerid, "Znajdujesz się w hotelu. Jeżeli chcesz wynająć pokój wpisz /pokoj zamelduj");
	}
	
	new string[ 126 ];
	format(string, sizeof string,
		"INSERT INTO `surv_odciski` VALUES (NULL, '%d', UNIX_TIMESTAMP(), '"#odcisk_type_door"', '%d', '%d')",
		Player(playerid, player_uid),
		Door(doorid, door_uid),
		_:Player(playerid, player_rekawiczki)
	);
	mysql_query(string);
	return 1;
}

FuncPub::OnPlayerExitInterior(playerid, doorid)
{
   	SetPlayerWeather(playerid, Setting(setting_weather));
    Player(playerid, player_door) = Door(doorid, door_out_vw) ? (doorid) : (0);

    #if !STREAMER
		LoadPlayerObjects(playerid, Door(doorid, door_out_vw));
	#endif
	LoadPlayerText(playerid, Door(doorid, door_out_vw));
	if(Audio_IsClientConnected(playerid) && Player(playerid, player_door_sound))
	{
		Audio_Stop(playerid, Player(playerid, player_door_sound));
		Player(playerid, player_door_sound) = 0;
	}
	else
		StopAudioStreamForPlayer(playerid);
	
	if(Player(playerid, player_option) & option_freeze)
	{
	    TogglePlayerControllable(playerid, false);
	    SetTimerEx("UnFreezePlayer", 3000, 0, "d", playerid);
	}
	new groupid = Player(playerid, player_duty);
	if(groupid)
	{
	    if(Group(playerid, groupid, group_option) & group_option_duty)
	    {
			if(!Door(doorid, door_out_vw))
			{
				new string[ 10 ];
				format(string, sizeof string, "%d duty", groupid);
				cmd_g(playerid, string);
			}
			else if(Door(doorid, door_owner)[ 0 ] == door_type_group)
			{
			    if(Group(playerid, groupid, group_uid) != Door(doorid, door_owner)[ 1 ])
				{
					new string[ 10 ];
					format(string, sizeof string, "%d duty", groupid);
					cmd_g(playerid, string);
				}
			}
	    }
	}
	if(Tren(playerid, train_item))
	{
	    new string[ 70 ];
		format(string, sizeof string,
			"UPDATE `surv_items` SET `v2` = '%d' WHERE `uid` = '%d'",
			Tren(playerid, train_time),
			Tren(playerid, train_item)
		);
		mysql_query(string);

		for(new eTrain:i; i < eTrain; i++)
	    	Tren(playerid, i) = 0;

	    ShowInfo(playerid, green"Trening siłowy przerwany");
	}
	return 1;
}

FuncPub::Door_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case 40:
	    {
			if(!response) return 1;
			if(strfind(inputtext, "Ustaw nazwę drzwi", true) != -1)
		        Dialog::Output(playerid, 41, DIALOG_STYLE_INPUT, IN_HEAD" "white"» "grey"Zmiana nazwy", white"Wprowadz nazwe która ma się wyświetlać\n\n"red"Od 3 do "#MAX_ITEM_NAME" znaków!", "Zmień nazwę", "Anuluj");
			else if(strfind(inputtext, "Ustaw opłate", true) != -1)
	            Dialog::Output(playerid, 42, DIALOG_STYLE_INPUT, IN_HEAD" "white"» "grey"Koszt wstępu", white"Wpisz kwotę, która będzie pobierana za wejscie do środka.\n\n"red"MAX 200.00$", "Ustaw Opłatę", "Anuluj");
            else if(strfind(inputtext, "Dodatki", true) != -1)
            {
 		        new doorid = Player(playerid, player_door_id),
 		            buffer[ 126 ];
 		            
				if(Door(doorid, door_option) & door_option_audio)
				    strcat(buffer, "Ustawienia Hifi\n");
				else
				    strcat(buffer, "Kup system Hifi - "green"$"white""#audio_price"\n");

				strcat(buffer, "Zakup sejf - "green"$"white""#sejf_price"\n");
				    
				Dialog::Output(playerid, 45, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Ustawienia Hifi", buffer, "Wybierz", "Zamknij");
            }
            else if(strfind(inputtext, "Sejf", true) != -1)
            {
                ShowPlayerSejf(playerid);
            }
            else if(strfind(inputtext, "Zmień wejście", true) != -1)
            {
                ShowCMD(playerid, "Wciśnij enter, gdy będziesz gotowy zapisać nową pozycje wewnętrzną! Y by anulować.");
                Create(playerid, create_value)[ 0 ] = Player(playerid, player_door_id);
                Create(playerid, create_type) = create_edit_inside;
            }
            else if(strfind(inputtext, "Magazyn", true) != -1)
            {
 		        new doorid = Player(playerid, player_door_id),
                	string[ 126 ],
					buffer[ 512 ];
					
				format(string, sizeof string,
					"SELECT `uid`, `name`, `price`, `amount` FROM `surv_products` WHERE `amount` != 0 AND `owner` = '%d'",
					Door(doorid, door_uid)
				);
				mysql_query(string);
				mysql_store_result();
				while(mysql_fetch_row(string))
				{
	                static uid,
	                    Float:price,
	                    amount,
						name[ 32 ];
						
					sscanf(string, "p<|>ds["#MAX_ITEM_NAME"]fd",
					    uid,
					    name,
						price,
						amount
					);
					
					format(buffer, sizeof buffer, "%s%d\t%dx\t$%.2f\t%s\n", buffer, uid, amount, price, name);
				}
				mysql_free_result();
				if(isnull(buffer)) ShowInfo(playerid, red"Magazyn jest pusty!");
				else ShowList(playerid, buffer);
            }
            else if(strfind(inputtext, "/przejazd", true) != -1)
            {
				if(!Player(playerid, player_adminlvl)) return 1;
 		        new doorid = Player(playerid, player_door_id);
				if(Door(doorid, door_option) & door_option_przejazd)
				{
				    Door(doorid, door_option) -= door_option_przejazd;
				    GameTextForPlayer(playerid, "~b~~h~Opcja: /przejazd wylaczona", 3000, 1);
				}
				else
				{
				    Door(doorid, door_option) += door_option_przejazd;
				    GameTextForPlayer(playerid, "~b~~h~Opcja: /przejazd wlaczona", 3000, 1);
				}
				SaveDoor(doorid);
				cmd_drzwi(playerid, "");
            }
            else if(strfind(inputtext, "Muzyka na zewnątrz", true) != -1)
            {
				if(!Player(playerid, player_adminlvl)) return 1;
 		        new doorid = Player(playerid, player_door_id);
				if(Door(doorid, door_option) & door_option_audio_out)
				{
				    Door(doorid, door_option) -= door_option_audio_out;
				    GameTextForPlayer(playerid, "~b~~h~Opcja: Muzyka na zewnatrz wylaczona", 3000, 1);
				}
				else
				{
				    Door(doorid, door_option) += door_option_audio_out;
				    GameTextForPlayer(playerid, "~b~~h~Opcja: Muzyka na zewnatrz wlaczona", 3000, 1);
				}
				SaveDoor(doorid);
				cmd_drzwi(playerid, "");
            }
            else if(strfind(inputtext, "/kup", true) != -1)
            {
				if(!Player(playerid, player_adminlvl)) return 1;
 		        new doorid = Player(playerid, player_door_id);
				if(Door(doorid, door_option) & door_option_buy)
				{
				    Door(doorid, door_option) -= door_option_buy;
				    GameTextForPlayer(playerid, "~b~~h~Opcja: /kup wylaczona", 3000, 1);
				}
				else
				{
				    Door(doorid, door_option) += door_option_buy;
				    GameTextForPlayer(playerid, "~b~~h~Opcja: /kup wlaczona", 3000, 1);
				}
				SaveDoor(doorid);
				cmd_drzwi(playerid, "");
            }
			else if(strfind(inputtext, "Płatność kartą", true) != -1)
			{
				if(!Player(playerid, player_adminlvl)) return 1;
 		        new doorid = Player(playerid, player_door_id);
				if(Door(doorid, door_option) & door_option_card)
				{
				    Door(doorid, door_option) -= door_option_card;
				    GameTextForPlayer(playerid, "~b~~h~Opcja: Platnosc karta wylaczona", 3000, 1);
				}
				else
				{
				    Door(doorid, door_option) += door_option_card;
				    GameTextForPlayer(playerid, "~b~~h~Opcja: Platnosc karta wlaczona", 3000, 1);
				}
				SaveDoor(doorid);
				cmd_drzwi(playerid, "");			
			}
			else if(strfind(inputtext, "Płatność paypass", true) != -1)
			{
				if(!Player(playerid, player_adminlvl)) return 1;
 		        new doorid = Player(playerid, player_door_id);
				if(Door(doorid, door_option) & door_option_paypass)
				{
				    Door(doorid, door_option) -= door_option_paypass;
				    GameTextForPlayer(playerid, "~b~~h~Opcja: Platnosc paypass wylaczona", 3000, 1);
				}
				else
				{
				    Door(doorid, door_option) += door_option_paypass;
				    GameTextForPlayer(playerid, "~b~~h~Opcja: Platnosc paypass wlaczona", 3000, 1);
				}
				SaveDoor(doorid);
				cmd_drzwi(playerid, "");			
			}
			else if(strfind(inputtext, "Skasuj ostatni obiekt", true) != -1)
			{
			    new object_uid;
			    new doorid = Player(playerid, player_door_id);
			    new string[ 126 ];
			    format(string, sizeof string,
			        "SELECT `uid` FROM `surv_objects` WHERE `door` = '%d' ORDER BY `uid` DESC",
			        Door(doorid, door_uid)
				);
				mysql_query(string);
				mysql_store_result();
				if(!mysql_num_rows())
				{
					ShowInfo(playerid, red"W budynku nie ma już obiektów!");
				    mysql_free_result();
					return 1;
				}
				object_uid = mysql_fetch_int();
				mysql_free_result();
				format(string, sizeof string,
					"UPDATE `surv_objects` SET `accept` = '0' WHERE `uid` = '%d' AND `door` = '%d'",
					object_uid,
			        Door(doorid, door_uid)
				);
				mysql_query(string);

				#if STREAMER
				    new c, objectid = GetObjectID(object_uid);
					for(; c < MAX_OBJECTS; c++)
					    if(Object(c, obj_objID) == objectid)
					        break;
					printf("c: %d, objid: %d", c, objectid);
		            if(c != MAX_OBJECTS)
		            {
		                for(new eObjects:i; i < eObjects; i++)
							Object(c, i) = 0;
						Object(c, obj_objID) = INVALID_OBJECT_ID;
					}
					DestroyDynamicObject(objectid);
				#else
					foreach(Player, i)
					{
					    if(Door(doorid, door_in_vw) != Player(i, player_vw)) continue;
					    new objectid = 1;
						for(; objectid != MAX_OBJECTS; objectid++)
						{
						    if(Object(i, objectid, obj_objID) == INVALID_OBJECT_ID)
								continue;
						    if(!Object(i, objectid, obj_uid))
								continue;
							if(Object(i, objectid, obj_uid) == object_uid)
							    break;
						}
					    DestroyPlayerObject(i, Object(i, objectid, obj_objID));

						for(new eObjects:d; d < eObjects; d++)
							Object(i, objectid, d)		= 0;

					    Object(i, objectid, obj_objID) = INVALID_OBJECT_ID;
					}
				#endif
				GameTextForPlayer(playerid, "~b~~h~Ostatni obiekt skasowany!", 3000, 1);
			}
			else if(strfind(inputtext, "Skasuj wszystkie obiekty", true) != -1)
			{
			    new string[ 126 ];
			    new doorid = Player(playerid, player_door_id);
				
				#if STREAMER
				    format(string, sizeof string,
				        "SELECT `uid` FROM `surv_objects` WHERE `accept` = '1' AND `door` = '%d'",
				        Door(doorid, door_uid)
					);
					mysql_query(string);
					mysql_store_result();
					while(mysql_fetch_row(string))
					{
					    new c, objectid = GetObjectID(strval(string));
						for(; c < MAX_OBJECTS; c++)
						    if(Object(c, obj_objID) == objectid)
						        break;
			            if(c != MAX_OBJECTS)
			            {
			                for(new eObjects:i; i < eObjects; i++)
								Object(c, i) = 0;
							Object(c, obj_objID) = INVALID_OBJECT_ID;
						}
						DestroyDynamicObject(objectid);
					}
					mysql_free_result();
				    format(string, sizeof string,
						"UPDATE `surv_objects` SET `accept` = '0' WHERE `door` = '%d'",
				        Door(doorid, door_uid)
					);
					mysql_query(string);
				#else
				    format(string, sizeof string,
						"UPDATE `surv_objects` SET `accept` = '0' WHERE `door` = '%d'",
				        Door(doorid, door_uid)
					);
					mysql_query(string);
					foreach(Player, i)
					{
					    if(Door(doorid, door_in_vw) != Player(i, player_vw)) continue;

					    LoadPlayerObjects(i, Player(i, player_vw));
					}
				#endif
				GameTextForPlayer(playerid, "~b~~h~Obiekty skasowane!", 3000, 1);
			}
		}
	    case 41:
	    {
		    if(!response) return 1;
	        if(3 <= strlen(inputtext) <= MAX_ITEM_NAME || Player(playerid, player_adminlvl))
	        {
		        new doorid = Player(playerid, player_door_id),
					string[ 126 ];
		        
		        mysql_real_escape_string(inputtext, inputtext);
				format(Door(doorid, door_name), MAX_ITEM_NAME, inputtext);
				format(string, sizeof string,
					"UPDATE `surv_doors` SET `name` = '%s' WHERE `uid` = '%d'",
					Door(doorid, door_name),
					Door(doorid, door_uid)
				);
				mysql_query(string);
				
			    GameTextForPlayer(playerid, "~b~~h~Nazwa zmieniona pomyslnie.", 3000, 1);
	        }
	        else
	        {
		        Dialog::Output(playerid, 41, DIALOG_STYLE_INPUT, IN_HEAD" "white"» "grey"Zmiana nazwy", white"Wprowadz nazwe która ma się wyświetlać\n\n"red"Od 3 do "#MAX_ITEM_NAME" znaków!", "Zmień nazwę", "Anuluj");
				GameTextForPlayer(playerid, "~r~Od 3 do "#MAX_ITEM_NAME" znakow!", 3000, 1);
			}
	    }
	    case 42:
	    {
		    if(!response) return 1;
	        new Float:cash = floatstr(inputtext);
            if(cash > 200.0)
            {
				Dialog::Output(playerid, 42, DIALOG_STYLE_INPUT, IN_HEAD" "white"» "grey"Koszt wstępu", white"Wpisz kwotę, która będzie pobierana za wejscie do środka.\n\n"red"MAX 200.00$", "Ustaw Opłatę", "Anuluj");
                GameTextForPlayer(playerid, "~r~MAX $200.00", 3000, 1);
				return 1;
			}
			
			new doorid = Player(playerid, player_door_id);
			Door(doorid, door_pay) = cash;
			
	        GameTextForPlayer(playerid, "~b~~h~Cena zostala ustawiona.", 3000, 1);
	    }
	    case 45:
	    {
	        if(!response) return 1;
 		    new doorid = Player(playerid, player_door_id);
	        if(strfind(inputtext, "Kup system Hifi", true) != -1)
	        {
		    	if(audio_price > Player(playerid, player_cash))
					return ShowInfo(playerid, red"Nie masz tyle gotówki!");
				GivePlayerMoneyEx(playerid, 0 - audio_price, true);
				
				Door(doorid, door_option) += door_option_audio;
				SaveDoor(doorid);

  				GameTextForPlayer(playerid, "~b~~h~System audio zakupiony!", 3000, 1);
	        }
	        else if(DIN(inputtext, "Ustawienia Hifi"))
	        {
 		        new buffer[ 126 ];
				if(Door(doorid, door_option) & door_option_audio)
				{
				    format(buffer, sizeof buffer, "%s muzykę\n", Door(doorid, door_option) & door_option_sound ? ("Wyłącz") : ("Włącz"));
					if(Door(doorid, door_option) & door_option_sound)
					{
					    strcat(buffer, "Zmień utwór\n");
						if(Door(doorid, door_option) & door_option_audio_out)
						{
							new hour;
							gettime(hour);
							if(hour <= 22 || hour >= 6)
								format(buffer, sizeof buffer, "%s"red"%s muzyke na zewnątrz (Między 22:00, a 6:00)\n", buffer, Door(doorid, door_sound_out) ? ("Wyłącz") : ("Włącz"));
							else
								format(buffer, sizeof buffer, "%s%s muzyke na zewnątrz\n", buffer, Door(doorid, door_sound_out) ? ("Wyłącz") : ("Włącz"));
						}
					}
				}
				Dialog::Output(playerid, 46, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Ustawienia Hifi", buffer, "Wybierz", "Wróć");
			}
			else if(strfind(inputtext, "Zakup sejf", true) != -1)
			{
		    	if(sejf_price > Player(playerid, player_cash))
					return ShowInfo(playerid, red"Nie masz tyle gotówki!");
				GivePlayerMoneyEx(playerid, 0 - sejf_price, true);

				new buffer[ 126 ];
				format(buffer, sizeof buffer,
					"INSERT INTO `surv_sejf` VALUES (NULL, '%d', 'Szafka', '0.00', '1234')",
					Door(doorid, door_uid)
				);
				mysql_query(buffer);
				GameTextForPlayer(playerid, "~b~~h~System audio zakupiony!", 3000, 1);
				ShowCMD(playerid, "Szafka została zakupiona pomyślnie. Domyślne hasło: 1234");
			}
	    }
	    case 46:
	    {
	        if(!response) return OnDialogResponseEx(playerid, 40, 1, 0, "Dodatki");
 		    new doorid = Player(playerid, player_door_id);
 		    if(strfind(inputtext, "muzyke na zewnątrz", true) != -1)
 		    {
				if(Door(doorid, door_sound_out))
				{
				    GameTextForPlayer(playerid, "~b~~h~Muzyka na zewnatrz wylaczona!", 3000, 1);
			        foreach(Player, i)
			        {
			            if(!Audio_IsClientConnected(i)) continue;
			            Audio_Stop(i, Player(i, player_door_out_sound)[ doorid ]);
				    	Player(i, player_door_out_sound)[ doorid ] = 0;
					}
				}
				else
				{
				    new hour;
					gettime(hour);
					if((hour <= 22 || hour >= 6) && !Player(playerid, player_adminlvl))
						return OnDialogResponseEx(playerid, 40, 1, 0, "Dodatki");
						
				    GameTextForPlayer(playerid, "~b~~h~Muzyka na zewnatrz wlaczona!", 3000, 1);
				    foreach(Player, i)
				    {
						if(!Audio_IsClientConnected(i)) continue;
						
						Player(i, player_door_out_sound)[ doorid ] = Audio_PlayStreamed(i, Door(doorid, door_sound_url));
					 	Audio_Set3DPosition(i, Player(i, player_door_out_sound)[ doorid ], Door(doorid, door_out_pos)[ 0 ], Door(doorid, door_out_pos)[ 1 ], Door(doorid, door_out_pos)[ 2 ], 30.0);
					}
					GameTextForPlayer(playerid, "~b~~h~Muzyka na zewnatrz wlaczona!", 3000, 1);
				}
  		        Door(doorid, door_sound_out) = !Door(doorid, door_sound_out);
		    }
			else if(strfind(inputtext, "muzykę", true) != -1)
			{
			    if(Door(doorid, door_option) & door_option_sound)
			    {
			        GameTextForPlayer(playerid, "~b~~h~Muzyka wylaczona!", 3000, 1);
			        Door(doorid, door_option) -= door_option_sound;
			        foreach(Player, i)
			        {
			            if(doorid != Player(i, player_door)) continue;
			            if(Audio_IsClientConnected(i))
			            {
				            Audio_Stop(i, Player(i, player_door_sound));
				            Player(i, player_door_sound) = 0;
			            }
			            else StopAudioStreamForPlayer(i);
			        }
			    }
			    else
			    {
			        if(isnull(Door(doorid, door_sound_url)))
			        {
					    ShowPlayerCD(playerid, 48);
						SetPVarInt(playerid, "door-change", 0);
			        }
			        else
			        {
				        foreach(Player, i)
				        {
				            if(doorid != Player(i, player_door)) continue;
				            if(Audio_IsClientConnected(i))
				            {
				            	Player(i, player_door_sound) = Audio_PlayStreamed(i, Door(doorid, door_sound_url));
							}
							else
        						PlayAudioStreamForPlayer(i, Door(doorid, door_sound_url));
				        }
				        Door(doorid, door_option) += door_option_sound;
			        	GameTextForPlayer(playerid, "~b~~h~Muzyka wlaczona!", 3000, 1);
			        }
			    }
			    SaveDoor(doorid);
			}
			else if(DIN(inputtext, "Zmień utwór"))
			{
			    ShowPlayerCD(playerid, 48);
				SetPVarInt(playerid, "door-change", 1);
			}
	    }
	    case 48:
	    {
	        if(!response)
				return OnDialogResponseEx(playerid, 45, 1, 0, "Ustawienia Hifi");
	        
	        new doorid = Player(playerid, player_door_id),
				itemuid = strval(inputtext),
				string[ 136 ];
				
			format(string, sizeof string,
				"SELECT surv_cd.url, surv_items.v1 FROM `surv_cd` JOIN `surv_items` ON surv_items.v1 = surv_cd.uid WHERE surv_items.uid = '%d'",
				itemuid
			);
			mysql_query(string);
			mysql_store_result();
			mysql_fetch_row(string);
			mysql_free_result();
			new url[ 64 ], v1;
			sscanf(string, "p<|>s[64]d",
				url,
				v1
			);
			
			if(isnull(url))
			    return ShowInfo(playerid, red"Płyta jest pusta!");
			    
			format(string, sizeof string,
				"UPDATE `surv_doors` SET `sound` = '%d' WHERE `uid` = '%d'",
				v1,
				Door(doorid, door_uid)
			);
			mysql_query(string);
				
			format(Door(doorid, door_sound_url), sizeof url, url);
	        foreach(Player, i)
	        {
	            if(!Audio_IsClientConnected(i)) continue;
	            Audio_Stop(i, Player(i, player_door_out_sound)[ doorid ]);
	            if(Door(doorid, door_option) & door_option_audio_out && Door(doorid, door_sound_out))
	            {
					Player(i, player_door_out_sound)[ doorid ] = Audio_PlayStreamed(i, Door(doorid, door_sound_url));
				 	Audio_Set3DPosition(i, Player(i, player_door_out_sound)[ doorid ], Door(doorid, door_out_pos)[ 0 ], Door(doorid, door_out_pos)[ 1 ], Door(doorid, door_out_pos)[ 2 ], 30.0);
				}
	            if(doorid != Player(i, player_door)) continue;
	            Audio_Stop(i, Player(i, player_door_sound));
	            Player(i, player_door_sound) = Audio_PlayStreamed(i, Door(doorid, door_sound_url));
	        }

        	if(GetPVarInt(playerid, "door-change"))
        		GameTextForPlayer(playerid, "~b~~h~Utwor zmieniony!", 3000, 1);
			else
        		GameTextForPlayer(playerid, "~b~~h~Muzyka wlaczona!", 3000, 1);

			DeletePVar(playerid, "door-change");
	    }
	}
	return 1;
}

FuncPub::ShowPlayerCD(playerid, guiID)
{
    new buffer[ 256 ],
		string[ 64 ];

	format(buffer, sizeof buffer,
		"SELECT `uid`, `name` FROM `surv_items` WHERE `ownerType` = "#item_place_player" AND `owner` = '%d' AND `type`="#item_cd" ORDER BY `uid` DESC",
		Player(playerid, player_uid)
	);
	mysql_query(buffer);
	mysql_store_result();
	buffer[ 0 ] = EOS;
	while(mysql_fetch_row(string))
	{
	    static uid,
			name[ MAX_ITEM_NAME ];
		sscanf(string, "p<|>ds["#MAX_ITEM_NAME"]",
			uid,
			name
		);

		format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, uid, name);
	}
	mysql_free_result();
	if(isnull(buffer))
		return ShowInfo(playerid, red"Nie masz żadnej płyty przy sobie!");
	else
		Dialog::Output(playerid, guiID, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Wybór płyty", buffer, "Użyj", "Wróć");
	return 1;
}

Cmd::Input->zamknij(playerid, params[])
{
	new doorid = GetPlayerDoor(playerid);
	if(!doorid)
		return ShowInfo(playerid, red"Nie stoisz przy żadnych drzwiach!");
		
	new can_open = CanPlayerOpenDoor(playerid, doorid);
	if(!can_open)
	    return ShowInfo(playerid, red"Nie masz uprawnień!");
	    
	if(Player(playerid, player_option) & option_me)
	{
		new string[ 30 + MAX_PLAYER_NAME ];
		format(string, sizeof string, "* %s %s", NickName(playerid), (Door(doorid, door_close)) ? ("otwiera drzwi kluczem.") : ("zamyka drzwi na klucz."));
		serwerme(playerid, string);
	}
	else GameTextForPlayer(playerid, (Door(doorid, door_close)) ? ("~g~Drzwi otwarte") : ("~r~Drzwi zamkniete"), 3000, 3);

    ApplyAnimation(playerid, "BD_FIRE", "wash_up", 4.0, 0, 0, 0, 0, 0, 0);
	Door(doorid, door_close) = !Door(doorid, door_close);
	return 1;
}

Cmd::Input->drzwi(playerid, params[])
{
	if(!isnull(params))
	{
		if(!strcmp(params, "zamknij", true)) return cmd_zamknij(playerid, params);
		return 1;
	}
	new doorid = GetPlayerDoor(playerid);
	if(!doorid)
		return ShowInfo(playerid, red"Nie stoisz przy żadnych drzwiach!");
		
	new can_use = IsPlayerDoorOwner(playerid, doorid);
    new can_buy = CanPlayerProductBuy(playerid, doorid);

	Player(playerid, player_door_id) = doorid;
	
	new buffer[ 350 ];
	if(can_use != -1)
	{
		strcat(buffer, "# Ustaw nazwę drzwi\n");
		strcat(buffer, "# Ustaw opłate\n");
		strcat(buffer, "# Dodatki\n");
		strcat(buffer, "# Sejf\n");
		strcat(buffer, "# Zmień wejście\n");
		strcat(buffer, "# Skasuj ostatni obiekt\n");
		strcat(buffer, "# Skasuj wszystkie obiekty\n");
	}
    if(can_buy != -1) strcat(buffer, "# Magazyn\n");
    if(Player(playerid, player_adminlvl))
	{
		strcat(buffer, grey"------------------------\n");
	    format(buffer, sizeof buffer, "%s/przejazd:\t\t\t%s\n", buffer, YesOrNo(bool:(Door(doorid, door_option) & door_option_przejazd)));
	    format(buffer, sizeof buffer, "%sMuzyka na zewnątrz:\t\t%s\n", buffer, YesOrNo(bool:(Door(doorid, door_option) & door_option_audio_out)));
	    format(buffer, sizeof buffer, "%s/kup:\t\t\t\t%s\n", buffer, YesOrNo(bool:(Door(doorid, door_option) & door_option_buy)));
	    format(buffer, sizeof buffer, "%sPłatność kartą:\t\t\t%s\n", buffer, YesOrNo(bool:(Door(doorid, door_option) & door_option_card)));
	    format(buffer, sizeof buffer, "%sPłatność paypass:\t\t%s\n", buffer, YesOrNo(bool:(Door(doorid, door_option) & door_option_paypass)));
	}
    if(isnull(buffer))
		return ShowInfo(playerid, red"Nie masz uprawnień!");
	else
		Dialog::Output(playerid, 40, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Drzwi", buffer, "Wybierz", "Zamknij");
	return 1;
}

Cmd::Input->przejazd(playerid, params[])
{
    new pl_vw = Player(playerid, player_vw),
		vehid = Player(playerid, player_veh),
		bool:enter;
		
	if(vehid == INVALID_VEHICLE_ID)
	    return ShowInfo(playerid, red"Nie jesteś w pojeździe.");
	    
	new seat[ MAX_PLAYERS ] = {-1, ...};
	
	foreach(Server_Doors, i)
	{
		if(pl_vw == Door(i, door_out_vw) && IsPlayerInRangeOfPoint(playerid, 1.5, Door(i, door_out_pos)[ 0 ], Door(i, door_out_pos)[ 1 ], Door(i, door_out_pos)[ 2 ]))
		{
			if((Door(i, door_option) & door_option_przejazd) && vehid)
			{
				if(Door(i, door_close))
				{
				    new sound[] = {doors_sound_lock};
				    Audio_Play(playerid, sound[random(sizeof sound)]);
				    GameTextForPlayer(playerid, "~r~Zamkniete", 3000, 3);
					enter = true;
				    break;
				}
				foreach(Player, victimid)
				{
				    if(Player(victimid, player_veh) != vehid) continue;
				    new aseat = GetPlayerVehicleSeat(victimid);
					if(aseat == -1) continue;
					if(aseat == 128) continue;
					seat[victimid] = aseat;
				}
				
			    SetVehiclePos(vehid, Door(i, door_in_pos)[ 0 ], Door(i, door_in_pos)[ 1 ], Door(i, door_in_pos)[ 2 ]);
			    SetVehicleZAngle(vehid, Door(i, door_in_pos)[ 3 ]);
			    LinkVehicleToInterior(vehid, Vehicle(vehid, vehicle_int) = Door(i, door_in_int));
				SetVehicleVirtualWorld(vehid, Vehicle(vehid, vehicle_vw) = Door(i, door_in_vw));
				
				foreach(Player, victimid)
				{
				    if(Player(victimid, player_veh) == vehid)
				    {
						SetPlayerPosEx(victimid, Door(i, door_in_pos)[ 0 ], Door(i, door_in_pos)[ 1 ], Door(i, door_in_pos)[ 2 ], Door(i, door_in_pos)[ 3 ]);
						SetPlayerVirtualWorld(victimid, Player(victimid, player_vw) = Door(i, door_in_vw));
		               	SetPlayerInterior(victimid, Player(victimid, player_int) = Door(i, door_in_int));
		               	SetPlayerWeather(victimid, 2);
						Player(victimid, player_disabled) = true;
						SetTimerEx("AntyCheat_Enable", 5000, false, "d", victimid);
						if(seat[victimid] != -1)
						{
						    Player(victimid, player_veh) = vehid;
							PutPlayerInVehicle(victimid, vehid, seat[victimid]);
						}
						OnPlayerEnterInterior(victimid, i);
					}
				}
				enter = true;
				break;
			}
		}
		else if(pl_vw == Door(i, door_in_vw) && IsPlayerInRangeOfPoint(playerid, 1.5, Door(i, door_in_pos)[ 0 ], Door(i, door_in_pos)[ 1 ], Door(i, door_in_pos)[ 2 ]))
		{
			if(vehid)
			{
				if(Door(i, door_close))
				{
				    new sound[] = {doors_sound_lock};
				    Audio_Play(playerid, sound[random(sizeof sound)]);
				    GameTextForPlayer(playerid, "~r~Zamkniete", 3000, 3);
					enter = true;
				    break;
				}
				foreach(Player, victimid)
				{
				    if(Player(victimid, player_veh) != vehid) continue;
				    new aseat = GetPlayerVehicleSeat(victimid);
					if(aseat == -1) continue;
					if(aseat == 128) continue;
					seat[victimid] = aseat;
				}

			    SetVehiclePos(vehid, Door(i, door_out_pos)[ 0 ], Door(i, door_out_pos)[ 1 ], Door(i, door_out_pos)[ 2 ]);
			    SetVehicleZAngle(vehid, Door(i, door_out_pos)[ 3 ]);
			    LinkVehicleToInterior(vehid, Vehicle(vehid, vehicle_int) = Door(i, door_out_int));
				SetVehicleVirtualWorld(vehid, Vehicle(vehid, vehicle_vw) = Door(i, door_out_vw));
				
				foreach(Player, victimid)
				{
				    if(Player(victimid, player_veh) == vehid)
				    {
						SetPlayerPosEx(victimid, Door(i, door_out_pos)[ 0 ], Door(i, door_out_pos)[ 1 ], Door(i, door_out_pos)[ 2 ], Door(i, door_out_pos)[ 3 ]);
						SetPlayerVirtualWorld(victimid, Player(victimid, player_vw) = Door(i, door_out_vw));
		               	SetPlayerInterior(victimid, Player(victimid, player_int) = Door(i, door_out_int));
		               	SetPlayerWeather(victimid, Setting(setting_weather));
						Player(victimid, player_disabled) = true;
						SetTimerEx("AntyCheat_Enable", 5000, false, "d", victimid);
						if(seat[victimid] != -1)
						{
							PutPlayerInVehicle(victimid, vehid, seat[victimid]);
						    Player(victimid, player_veh) = vehid;
						}
						OnPlayerExitInterior(victimid, i);
					}
				}
				enter = true;
				break;
			}
		}
	}
	if(!enter)
	    ShowInfo(playerid, red"Nie jest przy drzwiach z możliwością wjazdu pojazdem!");
	return 1;
}
Cmd::Input->ubranie(playerid, params[]) return cmd_kup(playerid, params);

Cmd::Input->kup(playerid, params[])
{
	new doorid = GetPlayerDoor(playerid, false);
	if(!doorid)
		return ShowInfo(playerid, red"Nie stoisz przy żadnych drzwiach!");

	if(Door(doorid, door_owner)[ 0 ] == door_type_bingo)
	{
	    if(!GetPVarInt(playerid, "Ubranie"))
	    {
	        TogglePlayerControllable(playerid, false);
	 		GetPlayerPos(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]);
	 		SetPlayerFacingAngle(playerid, 90);
	    	SetPlayerCameraPos(playerid, Player(playerid, player_position)[ 0 ]-3, Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]);
	  		SetPlayerCameraLookAt(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]);
            SetPVarInt(playerid, "Ubranie", GetPlayerSkin(playerid));
            
            ShowCMD(playerid, "Aby wybrać ubranie "white"używaj strzałek"grey", aby zakupić wciśnij "white"ENTER lub F"grey".");
            ShowCMD(playerid, "Aby anulować zakup wpisz ponownie "white"(/kup)"grey".");
	    }
	    else
	    {
		    ShowCMD(playerid, "Zakup ubrania anulowany.");
			SetCameraBehindPlayer(playerid);
	     	SetPlayerSkin(playerid, GetPVarInt(playerid, "Ubranie"));
	 		DeletePVar(playerid, "Ubranie");
	   		TogglePlayerControllable(playerid, true);
	    }
	}
	else
	{
		if(!(Door(doorid, door_option) & door_option_buy))
		    return ShowInfo(playerid, red"W tym budynku ta opcja jest niedostępna!");

		Player(playerid, player_door_id) = doorid;

		new buffer[ 2058 ],
			string[ 64 ];
		format(buffer, sizeof buffer, "SELECT `uid`, `name`, `price` FROM `surv_products` WHERE `amount` != 0 AND `owner` = '%d'", Door(doorid, door_uid));
		mysql_query(buffer);
		mysql_store_result();
		buffer[ 0 ] = EOS;
		while(mysql_fetch_row(string))
		{
		    static uid,
				name[ MAX_ITEM_NAME ],
				Float:price;

			sscanf(string, "p<|>ds["#MAX_ITEM_NAME"]f",
				uid,
				name,
				price
			);

			format(buffer, sizeof buffer, "%s%d\t$%.2f\t\t%s\n", buffer, uid, price, name);
		}
		mysql_free_result();
		if(isnull(buffer))
			ShowInfo(playerid, red"Magazyn jest pusty!");
		else
			Dialog::Output(playerid, 54, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Kup", buffer, "Wybierz", "Zamknij");
	}
	return 1;
}

Cmd::Input->podaj(playerid, params[])
{
	new doorid = GetPlayerDoor(playerid, false);
	if(!doorid)
		return ShowInfo(playerid, red"Nie stoisz przy żadnych drzwiach!");
	new can_buy = CanPlayerProductBuy(playerid, doorid);
	if(can_buy == -1)
	    return ShowInfo(playerid, red"Nie masz dostępu!");
	    
	new victimid;
	if(sscanf(params, "u", victimid))
	    return ShowCMD(playerid, "Tip: /podaj [ID/Nick]");
	if(!IsPlayerConnected(victimid))
	    return NoPlayer(playerid);
	if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
		return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");

	Player(playerid, player_door_id) = doorid;

	new buffer[ 2058 ],
		string[ 64 ];
	format(buffer, sizeof buffer,
		"SELECT `uid`, `name`, `price` FROM `surv_products` WHERE `amount` != 0 AND `owner` = '%d'",
		Door(doorid, door_uid)
	);
	mysql_query(buffer);
	mysql_store_result();
	buffer[ 0 ] = EOS;
	while(mysql_fetch_row(string))
	{
	    static uid,
			name[ MAX_ITEM_NAME ],
			Float:price;

		sscanf(string, "p<|>ds["#MAX_ITEM_NAME"]f",
			uid,
			name,
			price
		);

		format(buffer, sizeof buffer, "%s%d\t$%.2f\t\t%s\n", buffer, uid, price, name);
	}
	mysql_free_result();
	if(isnull(buffer))
		return ShowInfo(playerid, red"Magazyn jest pusty!");
	else
		Dialog::Output(playerid, 55, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Oferowanie produktu", buffer, "Wybierz", "Zamknij");
		
	Offer(playerid, offer_player) 	= victimid;
	Offer(playerid, offer_type)     = offer_type_product;
	return 1;
}

Cmd::Input->pokoj(playerid, params[])
{
	new doorid = GetPlayerDoor(playerid, false);
	if(!doorid)
		return ShowInfo(playerid, red"Nie stoisz przy żadnych drzwiach!");
	if(Door(doorid, door_owner)[ 0 ] != door_type_hotel)
	    return ShowInfo(playerid, red"Nie jesteś w hotelu!");

	new type[ 32 ], varchar[ 32 ];
	if(sscanf(params, "s[32]S()[32]", type, varchar))
		return ShowCMD(playerid, "/pokoj [zamelduj/wymelduj/wejdz/zamknij]");
	if(!strcmp(type, "zamelduj", true))
	{
		new string[ 126 ];
		format(string, sizeof string,
			"SELECT 1 FROM `surv_members` WHERE `type` = '"#member_type_hotel"' AND `id` = '%d' AND `player` = '%d'",
		    Door(doorid, door_uid),
		    Player(playerid, player_uid)
		);
		mysql_query(string);
		mysql_store_result();
		new num = mysql_num_rows();
		mysql_free_result();
		if(num)
		    return ShowInfo(playerid, red"Jesteś już zameldowany w tym hotelu!");

		format(string, sizeof string,
			"INSERT INTO `surv_members` (`player`, `type`, `id`) VALUES ('%d', '"#member_type_hotel"', '%d')",
		    Player(playerid, player_uid),
		    Door(doorid, door_uid)
		);
		mysql_query(string);
	   	ShowCMD(playerid, "Recepcjonistka podaje Ci klucz od pokoju.");

	    format(string, sizeof string, "Na kluczu jest numer pokoju: %d", Player(playerid, player_uid));
		serwerdo(playerid, string);
	}
	else if(!strcmp(type, "wymelduj", true))
	{
		new string[ 126 ];
		format(string, sizeof string,
			"SELECT 1 FROM `surv_members` WHERE `type` = '"#member_type_hotel"' AND `id` = '%d' AND `player` = '%d'",
		    Door(doorid, door_uid),
		    Player(playerid, player_uid)
		);
		mysql_query(string);
		mysql_store_result();
		new num = mysql_num_rows();
		mysql_free_result();
		if(!num)
		    return ShowInfo(playerid, red"Nie jesteś zameldowany w tym hotelu!");

		format(string, sizeof string,
		    "DELETE FROM `surv_members` WHERE `type` = '"#member_type_hotel"' AND `id` = '%d' AND `player` = '%d'",
		    Door(doorid, door_uid),
		    Player(playerid, player_uid)
		);
		mysql_query(string);

	    format(string, sizeof string, "* %s oddaje klucz recepcjonistce.", NickName(playerid));
		serwerme(playerid, string);

		ShowCMD(playerid, "Oddałeś klucz recepcjonistce.");
	}
	else if(!strcmp(type, "wejdz", true) || !strcmp(type, "wejdź", true))
	{
	    if(isnull(varchar))
	        return ShowCMD(playerid, "/pokoj wejdź [numer pokoju]");
	    new room = strval(varchar),
			roomid,
			string[ 126 ];
		if(Player(playerid, player_uid) != room)
		{
		    foreach(Player, i)
		    {
		        if(Player(i, player_uid) != room) continue;
		        if(Player(i, player_hotel_close)) continue;
		        roomid = Player(i, player_hotel);
		        break;
		    }
		    if(!roomid)
		        return GameTextForPlayer(playerid, "~r~Pokoj zamkniety", 3000, 3);
		    format(string, sizeof string,
				"SELECT `uid`, `in_x`, `in_y`, `in_z`, `in_int` FROM `surv_hotels` WHERE `uid` = '%d'",
				roomid
			);
	    }
	    else
	    {
		    format(string, sizeof string,
				"SELECT `uid`, `in_x`, `in_y`, `in_z`, `in_int` FROM `surv_hotels` WHERE `door_uid` = '%d'",
				Door(doorid, door_uid)
			);
		}
		mysql_query(string);
	    mysql_store_result();
	    if(!mysql_num_rows())
		{
		    mysql_free_result();
			ShowInfo(playerid, red"Error 404!\n\nBrak interioru!");
			return 1;
		}
	    mysql_fetch_row_format(string);
	    mysql_free_result();
	    sscanf(string, "p<|>da<f>[3]d",
	        Player(playerid, player_hotel),
	        Player(playerid, player_position),
	        Player(playerid, player_int)
	    );
	    Player(playerid, player_vw) = room;
		FadeColorForPlayer(playerid, 0, 0, 0, 0, 0, 0, 0, 255, 15, 0); // Ściemnienie
		Player(playerid, player_dark) = dark_spawn;
	}
	else if(!strcmp(type, "zamknij", true))
	{
		new string[ 126 ];
		format(string, sizeof string,
			"SELECT 1 FROM `surv_members` WHERE `type` = '"#member_type_hotel"' AND `id` = '%d' AND `player` = '%d'",
		    Door(doorid, door_uid),
		    Player(playerid, player_uid)
		);
		mysql_query(string);
		mysql_store_result();
		new num = mysql_num_rows();
		mysql_free_result();
		if(!num)
		    return ShowInfo(playerid, red"Nie jesteś zameldowany w tym hotelu!");

		if(Player(playerid, player_option) & option_me)
		{
			format(string, sizeof string, "* %s %s", NickName(playerid), (Player(playerid, player_hotel_close)) ? ("otwiera drzwi kluczem.") : ("zamyka drzwi na klucz."));
			serwerme(playerid, string);
		}
		Player(playerid, player_hotel_close) = !Player(playerid, player_hotel_close);
	}
	// Player(playerid, player_hotel)
	return 1;
}
