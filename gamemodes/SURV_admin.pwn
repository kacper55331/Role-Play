public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    if(!Player(playerid, player_adminlvl)) return 1;
    #if mapandreas
    	MapAndreas_FindZ_For2DCoord(fX, fY, fZ);
    #endif
    SetPlayerPos(playerid, fX, fY, fZ);
    SetPlayerInterior(playerid, 0);
    return 1;
}

FuncPub::Admin_OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(Create(playerid, create_type) == create_edit_outside || Create(playerid, create_type) == create_edit_inside)
	{
	    if(newkeys & KEY_SECONDARY_ATTACK)
	    {
            new did = Create(playerid, create_value)[ 0 ];
			GetPlayerPos(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]);
			GetPlayerFacingAngle(playerid, Player(playerid, player_position)[ 3 ]);
			Player(playerid, player_vw) = GetPlayerVirtualWorld(playerid);
			Player(playerid, player_int) = GetPlayerInterior(playerid);

			if(Create(playerid, create_type) == create_edit_outside)
			{
	            Door(did, door_out_pos)[ 0 ] = Player(playerid, player_position)[ 0 ];
	            Door(did, door_out_pos)[ 1 ] = Player(playerid, player_position)[ 1 ];
	            Door(did, door_out_pos)[ 2 ] = Player(playerid, player_position)[ 2 ];
	            Door(did, door_out_pos)[ 3 ] = Player(playerid, player_position)[ 3 ];
				//Door(did, door_out_vw) = Player(playerid, player_vw);
				Door(did, door_out_int) = Player(playerid, player_int);
	            if(Door(did, door_pickup))
	            {
					DestroyPickup(Door(did, door_pickupID));
					new pickupid;
					pickupid = CreatePickup(Door(did, door_pickup), 2, Door(did, door_out_pos)[ 0 ], Door(did, door_out_pos)[ 1 ], Door(did, door_out_pos)[ 2 ], Door(did, door_out_vw));
			        Pickup(pickupid, pickup_model) 		= Door(did, door_pickup);
			        Pickup(pickupid, pickup_type) 		= 0;
					Pickup(pickupid, pickup_pos)[ 0 ] 	= Door(did, door_out_pos)[ 0 ];
					Pickup(pickupid, pickup_pos)[ 1 ] 	= Door(did, door_out_pos)[ 1 ];
					Pickup(pickupid, pickup_pos)[ 2 ] 	= Door(did, door_out_pos)[ 2 ];
			        Pickup(pickupid, pickup_vw) 		= Door(did, door_out_vw);
			        Pickup(pickupid, pickup_owner)[ 0 ]	= pickup_type_door;
			        Pickup(pickupid, pickup_owner)[ 1 ] = did;
			        Pickup(pickupid, pickup_sampID)     = pickupid;
			        Door(did, door_pickupID) 			= pickupid;
	            }

				new string[ 256 ];
				format(string, sizeof string,
				    "UPDATE `surv_doors` SET `out_pos_x` = '%f', `out_pos_y` = '%f', `out_pos_z` = '%f', `out_pos_a` = '%f', `out_pos_int` = '%d' WHERE `uid` = '%d'",
		            Door(did, door_out_pos)[ 0 ],
		            Door(did, door_out_pos)[ 1 ],
		            Door(did, door_out_pos)[ 2 ],
		            Door(did, door_out_pos)[ 3 ],
					Door(did, door_out_int),
					Door(did, door_uid)
				);
				mysql_query(string);

				ShowCMD(playerid, "Pozycja zewnętrza drzwi zapisana!");
			}
			else if(Create(playerid, create_type) == create_edit_inside)
			{
			    //if(Player(playerid, player_vw) == 0)
			        //return ShowInfo(playerid, red"Nie możesz zrobić wyjścia w vw 0");
			        
				Door(did, door_in_pos)[ 0 ] = Player(playerid, player_position)[ 0 ];
	            Door(did, door_in_pos)[ 1 ] = Player(playerid, player_position)[ 1 ];
	            Door(did, door_in_pos)[ 2 ] = Player(playerid, player_position)[ 2 ];
	            Door(did, door_in_pos)[ 3 ] = Player(playerid, player_position)[ 3 ];
				//Door(did, door_in_vw) = Player(playerid, player_vw);
				Door(did, door_in_int) = Player(playerid, player_int);

				new string[ 256 ];
				format(string, sizeof string,
				    "UPDATE `surv_doors` SET `in_pos_x` = '%f', `in_pos_y` = '%f', `in_pos_z` = '%f', `in_pos_a` = '%f', `in_pos_int` = '%d' WHERE `uid` = '%d'",
		            Door(did, door_in_pos)[ 0 ],
		            Door(did, door_in_pos)[ 1 ],
		            Door(did, door_in_pos)[ 2 ],
		            Door(did, door_in_pos)[ 3 ],
					Door(did, door_in_int),
					Door(did, door_uid)
				);
				mysql_query(string);

				ShowCMD(playerid, "Pozycja wewnętrza drzwi zapisana!");
			}
			End_Create(playerid);
	    }
	    else if(newkeys & KEY_YES)
	    {
	        ShowCMD(playerid, "Zmiana pozycji anulowana!");
	        End_Create(playerid);
	    }
	}
	return 1;
}

FuncPub::Admin_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case 35:
	    {
	        if(!response) return 1;
	        new muid = strval(inputtext),
				string[ 230 ];
	        SetPVarInt(playerid, "message-uid", muid);
	        format(string, sizeof string,
				"UPDATE `surv_messages` SET `read` = '1' WHERE `uid` = '%d'",
				muid
			);
	        mysql_query(string);

			mysql_query("SELECT 1 FROM `surv_messages` WHERE `type` = "#message_type_raport" AND `read` = '0'");
			mysql_store_result();
			Setting(setting_raports) = mysql_num_rows();
			mysql_free_result();
			UpdateInfos();

			format(string, sizeof string,
				"SELECT surv_players.name, surv_players.uid, surv_messages.time, surv_messages.text FROM `surv_messages` JOIN `surv_players` ON surv_messages.victim = surv_players.uid WHERE surv_messages.uid = '%d'",
				muid
			);
	        mysql_query(string);
	        mysql_store_result();
			mysql_fetch_row(string);
			mysql_free_result();

	        new text[ 128 ],
	            date[ 32 ],
				createtime;

			new victim[ MAX_PLAYER_NAME ],
				victimuid;

			sscanf(string, "p<|>s["#MAX_PLAYER_NAME"]dds[128]",
				victim,
				victimuid,
			    createtime,
			    text
			);

			new check[ MAX_PLAYER_NAME ],
				checkuid;

			format(string, sizeof string,
				"SELECT surv_players.name, surv_players.uid FROM `surv_messages` JOIN `surv_players` ON surv_messages.player = surv_players.uid WHERE surv_messages.uid = '%d'",
				muid
			);
	        mysql_query(string);
	        mysql_store_result();
			mysql_fetch_row(string);
			mysql_free_result();

			sscanf(string, "p<|>s["#MAX_PLAYER_NAME"]d",
			    check,
			    checkuid
			);
            ReturnTimeAgo(createtime, date);
            
			format(string, sizeof string,
				"Zgłoszony: %s(%d)\nZgłosił: %s(%d)\nData: %s\n\nTreść:\n%s",
				victim,
				victimuid,
				check,
				checkuid,
				date,
				text
			);
            Dialog::Output(playerid, 52, DIALOG_STYLE_MSGBOX, IN_HEAD, string, "Zamknij", "Skasuj");
	    }
	    case 52:
	    {
	        if(response) return DeletePVar(playerid, "message-uid");
	        new muid = GetPVarInt(playerid, "message-uid"),
				string[ 70 ];

	        format(string, sizeof string,
				"UPDATE `surv_messages` SET `read` = '2' WHERE `uid` = '%d'",
				muid
			);
	        mysql_query(string);

	        ShowInfo(playerid, green"Raport skasowany pomyślnie!");

	        DeletePVar(playerid, "message-uid");
	    }
	    case 64:
	    {
	        if(!response) return End_Create(playerid);
	        if(DIN(inputtext, "Pojazd"))
	        {
	            Create(playerid, create_cat) = create_cat_veh;
	        	Dialog::Output(playerid, 65, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj nazwe auta lub ID modelu.", "Dalej", "Zamknij");
	        }
	        else if(DIN(inputtext, "Przedmiot"))
	        {
	            Create(playerid, create_cat) = create_cat_item;
	            
	            new buffer[ 512 ];
				for(new id; id != sizeof ItemName; id++)
				    format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, id, ItemName[ id ]);
				Dialog::Output(playerid, 91, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Dalej", "Zamknij");
	        }
	        else if(DIN(inputtext, "Grupe"))
	        {
	            Create(playerid, create_cat) = create_cat_group;
	            
	            new buffer[ 512 ];
                for(new id; id != sizeof GroupName; id++)
					format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, id, GroupName[ id ]);

				Dialog::Output(playerid, 104, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Dalej", "Zamknij");
	        }
	        else if(DIN(inputtext, "Drzwi"))
	        {
	            Create(playerid, create_cat) = create_cat_door;
	            
	            new buffer[ 512 ];
                for(new id; id != sizeof PickModel; id++)
					format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, PickModel[ id ][ model_id ], PickModel[ id ][ model_name ]);

				Dialog::Output(playerid, 121, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Dalej", "Zamknij");
	        }
	        else if(DIN(inputtext, "Obiekt"))
	        {
	            Create(playerid, create_cat) = create_cat_obj;
	            Dialog::Output(playerid, 137, DIALOG_STYLE_INPUT, IN_HEAD, "Podaj id modelu", "Dalej", "Zamknij");
	        }
	        else if(DIN(inputtext, "Pickup"))
	        {
	            Create(playerid, create_cat) = create_cat_pick;
	            new buffer[ 512 ];
                for(new id = 1; id != sizeof PickModel; id++)
					format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, PickModel[ id ][ model_id ], PickModel[ id ][ model_name ]);

	            Dialog::Output(playerid, 147, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Dalej", "Zamknij");
	        }
	        else if(DIN(inputtext, "Strefe"))
	        {
	            Create(playerid, create_cat) = create_cat_strefa;
	            
	        }
	    }
	    case 65:
	    {
	        if(!response) return End_Create(playerid);
			new num,
				last,
				buffer[ 512 ];
			if ('0' <= inputtext[ 0 ] <= '9')
			{
				new i = strval(inputtext);
				if(400 <= i <= 611)
				{
					num++;
					last = i;
				}
			}
			else
			{
				for(new i = 400, poj[ 64 ], znak; i <= 611; i++)
				{
				    poj = NazwyPojazdow[ i-400 ];
				    znak = strfind(poj, inputtext, true);
					if(znak != -1)
					{
					    strins(poj, green, znak);
					    strins(poj, white, znak+strlen(inputtext)+strlen(green));
					    format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, i, poj);
					    num++;
					    last = i;
					}
					if(num > 8) break;
				}
			}
			strcat(buffer, "------------------------\n");
			if(num > 8) strcat(buffer, "Lista ucięta, zbyt wiele wyników!\n");
			strcat(buffer, "Wyszukaj inny pojazd");

			if(num == 1)
			{
			    Create(playerid, create_type) = last;
   				Dialog::Output(playerid, 67, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj pierwszy kolor pojazdu.", "Dalej", "Zamknij");
			}
			else if(!num) Dialog::Output(playerid, 65, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj nazwe auta lub ID modelu.\n\n"red"Nie poprawna nazwa lub ID pojazdu!", "Dalej", "Zamknij");
			else Dialog::Output(playerid, 66, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Dalej", "Zamknij");
	    }
	    case 66:
	    {
	        if(!response) return End_Create(playerid);

			if(DIN(inputtext, "Wyszukaj inny pojazd"))
		        return Dialog::Output(playerid, 65, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj nazwe auta lub ID modelu.", "Dalej", "Zamknij");

			Create(playerid, create_type) = strval(inputtext);
			if(Create(playerid, create_cat) == create_cat_veh)
   				Dialog::Output(playerid, 67, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj pierwszy kolor pojazdu.", "Dalej", "Zamknij");
			else if(Create(playerid, create_cat) == create_cat_eveh)
   				Dialog::Output(playerid, 67, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj pierwszy kolor pojazdu.", "Dalej", "Zamknij");

	    }
	    case 67:
	    {
	        if(!response) return End_Create(playerid);

			Create(playerid, create_value)[ 0 ] = strval(inputtext);
        	
        	Dialog::Output(playerid, 68, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj drugi kolor pojazdu.", "Dalej", "Zamknij");
	    }
	    case 68:
	    {
	        if(!response) return End_Create(playerid);

			Create(playerid, create_value)[ 1 ] = strval(inputtext);
		    if(Iter_Count(Server_Vehicles) == MAX_VEHICLES)
		        return ShowInfo(playerid, red"Brak limitu pojazdów!"), End_Create(playerid);
			new carid = CreateVeh(playerid, Create(playerid, create_type), vehicle_owner_player, Player(playerid, player_uid), Create(playerid, create_value)[ 0 ], Create(playerid, create_value)[ 1 ]);
				
			new string[ 126 ];
	        format(string, sizeof(string),
				green"Dodano pojazd!\n"white"UID:\t\t\t%d\nModel:\t\t\t%d\nKolor1:\t\t\t%d\nKolor2:\t\t\t%d",
				Vehicle(carid, vehicle_uid),
				Vehicle(carid, vehicle_model),
				Vehicle(carid, vehicle_color)[ 0 ],
				Vehicle(carid, vehicle_color)[ 1 ]
			);
	        ShowInfo(playerid, string);
	        
	        End_Create(playerid);
	    }
	    case 91:
	    {
	        if(!response) return End_Create(playerid);
			Create(playerid, create_type) = strval(inputtext);
	        
	        switch(Create(playerid, create_type))
	        {
	            case item_weapon, item_ammo:
	            {
	            	new weaponame[ 32 ],
						string[ 512 ];
				    for(new int = 1; int != 46; int++)
				    {
				        if(IsValidWeapon(int)) continue;
				        
				        GetWeaponName(int, weaponame, sizeof weaponame);
						format(string, sizeof string, "%s%d\t%s\n", string, int, weaponame);
					}
	        		Dialog::Output(playerid, 92, DIALOG_STYLE_LIST, IN_HEAD, string, "Dalej", "Zamknij");
	            }
	            case item_drugs:
	            {
	                new string[ 512 ];
	                for(new d; d != sizeof NarkName; d++)
	                    format(string, sizeof string, "%s%d\t%s\n", string, d, NarkName[ d ]);
	        		Dialog::Output(playerid, 92, DIALOG_STYLE_LIST, IN_HEAD, string, "Dalej", "Zamknij");
	            }
	            case item_none, item_watch, item_kajdanki, item_megafon, item_checkbox, item_rolki, item_cd, item_cdplayer, item_pack, item_notes:
	            {
					Dialog::Output(playerid, 95, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj wagę przedmiotu.", "Dalej", "Zamknij");
	            }
	            default: Dialog::Output(playerid, 92, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj pierwszą wartość przedmiotu.", "Dalej", "Zamknij");
			}
	    }
	    case 92:
	    {
	        if(!response) return End_Create(playerid);
	        Create(playerid, create_value)[ 0 ] = strval(inputtext);
	        
	        new string[ 50 ];
	        switch(Create(playerid, create_type))
	        {
	            case item_weapon, item_ammo:
	                string = white"Podaj ilość amunicji.";
	            case item_drugs: return Dialog::Output(playerid, 95, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj wagę przedmiotu.", "Dalej", "Zamknij");
	            default: string = white"Podaj drugą wartość przedmiotu.";
	        }
	        Dialog::Output(playerid, 93, DIALOG_STYLE_INPUT, IN_HEAD, string, "Dalej", "Zamknij");
	    }
	    case 93:
	    {
	        if(!response) return End_Create(playerid);
	        
	        Create(playerid, create_value)[ 1 ] = strval(inputtext);
	        
	        switch(Create(playerid, create_type))
	        {
				case item_food, item_drink: Dialog::Output(playerid, 95, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj wartość HP.", "Dalej", "Zamknij");
				case item_check: Dialog::Output(playerid, 95, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj kwotę.", "Dalej", "Zamknij");
				case item_karta: Dialog::Output(playerid, 95, DIALOG_STYLE_LIST, IN_HEAD, "0\tfalse\n1\ttrue", "Dalej", "Zamknij");
				case item_attach:
				{
				    new string[ 456 ];
				    strcat(string, "1 - Brzuch\n");
					strcat(string, "2 - Głowa\n");
					strcat(string, "3 - Lewe ramie\n");
					strcat(string, "4 - Prawe ramie\n");
					strcat(string, "5 - Lewa ręka\n");
					strcat(string, "6 - Prawa ręka\n");
					strcat(string, "7 - Lewe udo\n");
					strcat(string, "8 - Prawe udo\n");
					strcat(string, "9 - Lewa stopa\n");
					strcat(string, "10 - Prawa stopa\n");
					strcat(string, "11 - Prawe kolano\n");
					strcat(string, "12 - Lewe kolano\n");
					strcat(string, "13 - Lewy łokieć\n");
					strcat(string, "14 - Prawy łokieć\n");
					strcat(string, "15 - Lewy obojczyk\n");
					strcat(string, "16 - Prawy obojczyk\n");
					strcat(string, "17 - Szyja\n");
					strcat(string, "18 - Szczęka\n");
					Dialog::Output(playerid, 94, DIALOG_STYLE_LIST, IN_HEAD, string, "Dalej", "Zamknij");
				}
				default: Dialog::Output(playerid, 95, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj wagę przedmiotu.", "Dalej", "Zamknij");
	        }
	    }
	    case 94:
	    {
	        if(!response) return End_Create(playerid);
	        
	        Create(playerid, create_value2) = floatstr(inputtext);
	        
	        Dialog::Output(playerid, 95, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj wagę przedmiotu", "Dalej", "Zamknij");
	    }
	    case 95:
	    {
	        if(!response) return End_Create(playerid);
	        
	        Create(playerid, create_value)[ 2 ] = strval(inputtext);
	        
			Dialog::Output(playerid, 96, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj nazwę przedmiotu", "Dalej", "Zamknij");
	    }
	    case 96:
	    {
	        if(!response) return End_Create(playerid);
	        if(isnull(inputtext)) return Dialog::Output(playerid, 96, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj nazwę przedmiotu", "Dalej", "Zamknij");
		    if(strlen(inputtext) > MAX_PLAYER_NAME) return Dialog::Output(playerid, 96, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj nazwę przedmiotu", "Dalej", "Zamknij");

	        mysql_real_escape_string(inputtext, inputtext);
	        format(Create(playerid, create_name), MAX_ITEM_NAME, inputtext);
	        
	        new uid = Createitem(playerid, Create(playerid, create_type), Create(playerid, create_value)[ 0 ], Create(playerid, create_value)[ 1 ], Create(playerid, create_value2), Create(playerid, create_name), Create(playerid, create_value)[ 2 ]);

			new string[ 126 ];
			format(string, sizeof string,
				green"Dodano przedmiot\n"white"UID:\t%d\nNazwa:\t%s\nTyp:\t%d (%s)\nWaga:\t%dg",
				uid,
				Create(playerid, create_name),
				Create(playerid, create_type),
				ItemName[ Create(playerid, create_type) ],
			 	Create(playerid, create_value)[ 2 ]
			);
			ShowInfo(playerid, string);
			
			End_Create(playerid);
	    }
	    case 97:
	    {
	        if(!response) return End_Create(playerid);
	        if(DIN(inputtext, "Pojazd"))
	        {
	            Create(playerid, create_cat) = create_cat_eveh;
	        	Dialog::Output(playerid, 98, DIALOG_STYLE_LIST, IN_HEAD, "Podaj UID pojazdu\nPokaż najbliższy(e)", "Dalej", "Wróć");
	        }
	        else if(DIN(inputtext, "Obiekt"))
	        {
	            Create(playerid, create_cat) = create_cat_eobj;
	            cmd_msel(playerid, "");
	        }
	        else if(DIN(inputtext, "Grupe") || DIN(inputtext, "Grupa"))
	        {
				new temp[ 2058 ], string[ MAX_GROUP_NAME + 10 ];
				mysql_query("SELECT `uid`, `name` FROM `surv_groups`");
				mysql_store_result();
				while(mysql_fetch_row(string))
				{
				    new uid,
						name[ MAX_GROUP_NAME ];
				    sscanf(string, "p<|>ds["#MAX_GROUP_NAME"]",
						uid,
						name
					);
					format(temp, sizeof temp, "%s%d\t%s\n", temp, uid, name);
				}
				mysql_free_result();
		        Dialog::Output(playerid, 142, DIALOG_STYLE_LIST, IN_HEAD, temp, "Zmień", "Wróć");
	            Create(playerid, create_cat) = create_cat_egroup;
	        }
	        else if(DIN(inputtext, "Przedmiot"))
	        {
	            Create(playerid, create_cat) = create_cat_eitem;
	            Dialog::Output(playerid, 138, DIALOG_STYLE_LIST, IN_HEAD, "Podaj UID przedmiotu.\nWybierz z ekwipunku.", "Dalej", "Wróć");
	        }
	        else if(DIN(inputtext, "Drzwi"))
	        {
	            new dooridx = GetPlayerDoor(playerid);
				if(!dooridx)
					return ShowInfo(playerid, red"Nie stoisz przy żadnych drzwiach!"), End_Create(playerid);

	            Create(playerid, create_cat) = create_cat_edoor;
	            Create(playerid, create_value)[ 0 ] = dooridx;
	            new Temp[ 512 ];
	            new owner_namex[ 32 ];
	            switch(Door(dooridx, door_owner)[ 0 ])
	            {
	                case door_type_group, door_type_house:
	                {
					    new owner_list[][] = {"", "surv_groups", "surv_players"};
		            	format(Temp, sizeof Temp,
		                	"SELECT `name` FROM `%s` WHERE `uid` = '%d'",
		                    owner_list[ Door(dooridx, door_owner)[ 0 ] ],
		                    Door(dooridx, door_owner)[ 1 ]
						);
						mysql_query(Temp);
						mysql_store_result();
						if(!mysql_num_rows()) owner_namex = "n/a";
						else mysql_fetch_row(owner_namex);
						mysql_free_result();
			            if(Door(dooridx, door_owner)[ 0 ] == door_type_house)
			                UnderscoreToSpace(owner_namex);
					}
					case door_type_hotel: owner_namex = "Hotel";
					case door_type_bingo: owner_namex = "Binco";
					default: owner_namex = "n/a";
	            }
	            new to_name[ 32 ];
	            if(Door(dooridx, door_to))
	            {
	                foreach(Server_Doors, d)
	                {
	                    if(Door(dooridx, door_to) != Door(d, door_uid)) continue;
	                    format(to_name, sizeof to_name, Door(d, door_name));
	                    break;
	                }
	            }
				format(Temp, sizeof Temp, "UID:\t\t%d\n", Door(dooridx, door_uid));
				format(Temp, sizeof Temp, "%sNazwa:\t\t%s\n", Temp, Door(dooridx, door_name));
				format(Temp, sizeof Temp, "%sPickup:\t\t%d\n", Temp, Door(dooridx, door_pickup));
				format(Temp, sizeof Temp, "%sTo door:\t%s\n", Temp, to_name);
				format(Temp, sizeof Temp, "%sVW wew/zew:\t%d/%d\n", Temp, Door(dooridx, door_in_vw), Door(dooridx, door_out_vw));
				format(Temp, sizeof Temp, "%sWłaściciel:\t%d:%d (%s)\n", Temp, Door(dooridx, door_owner)[ 0 ], Door(dooridx, door_owner)[ 1 ], owner_namex);
				strcat(Temp, "------------------------\n");
				strcat(Temp, "Zmień właściciela\n");
				strcat(Temp, "Zmień pozycje wewnętrzną\n");
				strcat(Temp, "Zmień pozycje zewnętrzną\n");
				strcat(Temp, "Zmień interior\n");
                strcat(Temp, "Zmień wew vw\n");
				strcat(Temp, "Zmień zew vw\n");
				strcat(Temp, "Zmień pickup\n");
				strcat(Temp, "Zmień to UID\n");
				strcat(Temp, red"USUŃ\n");
				Dialog::Output(playerid, 145, DIALOG_STYLE_LIST, IN_HEAD, Temp, "Dalej", "Zamknij");
	        }
	        else if(DIN(inputtext, "Strefe"))
	        {
	            new zone = GetPlayerZone(playerid);
	            if(!Zone(zone, zone_uid))
	                return ShowInfo(playerid, red"Nie jesteś w żadnej strefie!"), End_Create(playerid);
	            Create(playerid, create_cat) = create_cat_estref;
	            Create(playerid, create_value)[ 0 ] = zone;
	            new buffer[ 256 ];
				format(buffer, sizeof buffer, "UID:\t\t%d\n", Zone(zone, zone_uid));
				format(buffer, sizeof buffer, "%sNazwa:\t\t%s\n", buffer, Zone(zone, zone_name));
				format(buffer, sizeof buffer, "%sKoordy:\t\t%f, %f, %f, %f\n", buffer, Zone(zone, zone_pos)[ 0 ], Zone(zone, zone_pos)[ 1 ], Zone(zone, zone_pos)[ 2 ], Zone(zone, zone_pos)[ 3 ]);
				if(Zone(zone, zone_group))
				{
				    new groupname[ 32 ],
						string[ 64 ];
				    format(string, sizeof string,
						"SELECT `name` FROM `surv_groups` WHERE `uid` = '%d'",
						Zone(zone, zone_group)
					);
					mysql_query(string);
					mysql_store_result();
					if(mysql_num_rows())
						mysql_fetch_row(groupname);
					else
						groupname = "n/a";
					mysql_free_result();
					format(buffer, sizeof buffer, "%sWłaściciel:\t%d (%s)\n", buffer, Zone(zone, zone_group), groupname);
				}
				strcat(buffer, "------------------------\n");
				strcat(buffer, "Zmień właściciela\n");
				Dialog::Output(playerid, 102, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Dalej", "Zamknij");
	        }
	    }
	    case 98:
	    {
			if(!response) return End_Create(playerid);
			switch(listitem)
			{
			    case 0: Dialog::Output(playerid, 99, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj UID pojazdu.", "Dalej", "Zamknij");
			    case 1:
			    {
			        new num,
						lastcar,
						buffer[ 512 ];
					foreach(Server_Vehicles, carid)
					{
						if(!IsPlayerInRangeOfPoint(playerid, 20.0, Vehicle(carid, vehicle_act_position)[ 0 ], Vehicle(carid, vehicle_act_position)[ 1 ], Vehicle(carid, vehicle_act_position)[ 2 ]))
							continue;

						format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, Vehicle(carid, vehicle_uid), NazwyPojazdow[Vehicle(carid, vehicle_model) - 400]);
						num++;
						lastcar = Vehicle(carid, vehicle_uid);
						if(num == 9)
						{
							strcat(buffer, "------------------------\n");
							strcat(buffer, "Lista ucięta, zbyt wiele wyników!\n");
							break;
						}
					}
					if(num == 1)
					{
					    Create(playerid, create_value)[ 0 ] = lastcar;
					    Admin_OnDialogResponse(playerid, 99, 2, 0, "");
					}
					else if(!num) ShowInfo(playerid, red"Nie znaleziono pojazdów w pobliżu!");
					else Dialog::Output(playerid, 99, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Dalej", "Wróć");
			    }
			}
	    }
	    case 99:
	    {
	        if(!response) return End_Create(playerid);
	        if(!Create(playerid, create_value)[ 0 ])
	        	Create(playerid, create_value)[ 0 ] = strval(inputtext);
	        	
	        new vehicleid = INVALID_VEHICLE_ID;
			foreachex(Server_Vehicles, vehicleid)
				if(Vehicle(vehicleid, vehicle_uid) == Create(playerid, create_value)[ 0 ])
					break;

			new buffer[ 1024 ],
				model,
				Float:hp,
				Float:fuel,
				color[ 2 ],
				plate[ 32 ],
				owner[ 2 ],
				Float:distance,
				Float:sp_pos[ 3 ],
				veh_name[ 64 ];
				
			if(vehicleid == -1)
			{
				format(buffer, sizeof buffer,
					"SELECT `name`, `model`, `hp`, `fuel`, `c1`, `c2`, `distance`, `plate`, `ownerType`, `owner`, `x`, `y`, `z` FROM `surv_vehicles` WHERE `uid` = '%d'",
					Create(playerid, create_value)[ 0 ]
				);
				mysql_query(buffer);
				mysql_store_result();
		        if(!mysql_num_rows())
		        {
		            ShowInfo(playerid, red"Ten pojazd nie istnieje!");
		            mysql_free_result();
		            return 1;
		        }
				else mysql_fetch_row(buffer);
				mysql_free_result();

				sscanf(buffer, "p<|>s[64]dffa<d>[2]fs[32]a<d>[2]a<f>[3]",
				    veh_name,
				    model,
				    hp,
				    fuel,
				    color,
				    distance,
				    plate,
				    owner,
				    sp_pos
				);
				Create(playerid, create_value)[ 1 ] = INVALID_VEHICLE_ID;
			}
			else
			{
			    Create(playerid, create_value)[ 1 ] = vehicleid;
			    model 		= Vehicle(vehicleid, vehicle_model);
			    hp 			= Vehicle(vehicleid, vehicle_hp);
			    fuel 		= Vehicle(vehicleid, vehicle_fuel);
			    color[ 0 ] 	= Vehicle(vehicleid, vehicle_color)[ 0 ];
			    color[ 1 ] 	= Vehicle(vehicleid, vehicle_color)[ 1 ];
			    owner[ 0 ]	= Vehicle(vehicleid, vehicle_owner)[ 0 ];
			    owner[ 1 ]	= Vehicle(vehicleid, vehicle_owner)[ 1 ];
			    distance 	= Vehicle(vehicleid, vehicle_distance);
			    sp_pos[ 0 ] = Vehicle(vehicleid, vehicle_position)[ 0 ];
			    sp_pos[ 1 ] = Vehicle(vehicleid, vehicle_position)[ 1 ];
			    sp_pos[ 2 ] = Vehicle(vehicleid, vehicle_position)[ 2 ];
			    format(veh_name, sizeof veh_name, Vehicle(vehicleid, vehicle_name));
		    	if(isnull(Vehicle(vehicleid, vehicle_plate)))
			        plate = "Brak";
			    else
			    	format(plate, sizeof plate, Vehicle(vehicleid, vehicle_plate));
			}
			new ownerName[ MAX_GROUP_NAME ];
			if(owner[ 0 ] == vehicle_owner_job)
				format(ownerName, sizeof ownerName, JobName[ owner[ 1 ] ]);
			else
			{
				new table[ 3 ][ ] = {"", "`surv_groups`", "`surv_players`"};
				format(buffer, sizeof buffer,
					"SELECT `name` FROM %s WHERE `uid` = '%d'",
					table[owner[ 0 ]],
					owner[ 1 ]
				);
				mysql_query(buffer);
				mysql_store_result();
				if(!mysql_num_rows()) ownerName = "n\a";
				else mysql_fetch_row(ownerName);
				mysql_free_result();

				if(owner[ 0 ] == vehicle_owner_player)
				    UnderscoreToSpace(ownerName);
			}
			format(buffer, sizeof buffer, "UID:\t\t%d\n", Create(playerid, create_value)[ 0 ]);
			format(buffer, sizeof buffer, "%sModel:\t\t%s (%s - %d)\n", buffer, veh_name, model == 0 ? ("n/a") : NazwyPojazdow[ model - 400 ], model);
			format(buffer, sizeof buffer, "%sKolory:\t\t%d:%d\n", buffer, color[ 0 ], color[ 1 ]);
			format(buffer, sizeof buffer, "%sHP wozu:\t%.1f\t%s\n", buffer, hp, (hp <= 300) ? ("Zniszczony") : (""));
			format(buffer, sizeof buffer, "%sPaliwo:\t\t%.1f/%d L\n", buffer, fuel, model == 0 ? (0) : GetVehicleMaxFuel(model));
			format(buffer, sizeof buffer, "%sPrzebieg:\t%.1fkm\n", buffer, distance);
			format(buffer, sizeof buffer, "%sRejestracja:\t%s\n", buffer, plate);
			format(buffer, sizeof buffer, "%sWłaściciel:\t%d:%d (%s)\n", buffer, owner[ 0 ], owner[ 1 ], ownerName);
			format(buffer, sizeof buffer, "%sSpawn:\t\t%f, %f, %f\n", buffer, sp_pos[ 0 ], sp_pos[ 1 ], sp_pos[ 2 ]);
			if(Create(playerid, create_value)[ 1 ] != INVALID_VEHICLE_ID)
			{
				format(buffer, sizeof buffer, "%sPozycja:\t%f, %f, %f\n", buffer, Vehicle(vehicleid, vehicle_act_position)[ 0 ], Vehicle(vehicleid, vehicle_act_position)[ 1 ], Vehicle(vehicleid, vehicle_act_position)[ 2 ]);
				strcat(buffer, "------------------------\n");
				strcat(buffer, "Teleportuj się do pojazdu\n");
				strcat(buffer, "Teleportuj pojazd do siebie\n");
				strcat(buffer, "Odspawnuj\n");
				new bool:count;
				foreach(Player, i)
				{
				    if(GetPlayerVehicleID(i) != Create(playerid, create_value)[ 1 ]) continue;
				    if(!count)
				    {
				        strcat(buffer, "W Pojeździe:\n");
				        count = true;
				    }
				    format(buffer, sizeof buffer, "%s\t- %s (%d)\n", buffer, NickName(i), i);
				}
			}
			else
			{
				strcat(buffer, "------------------------\n");
				strcat(buffer, "Spawnuj\n");
			}
			strcat(buffer, "------------------------\n");
			strcat(buffer, "Zmień nazwe\n");
			strcat(buffer, "Ustaw flagi\n");
			strcat(buffer, "Zmień rejestracje\n");
			strcat(buffer, "Zmień kolory\n");
			strcat(buffer, "Zmień przebieg\n");
			strcat(buffer, "Zmień właściciela\n");
			strcat(buffer, "Zmień ilość paliwa\n");
			strcat(buffer, "Zmień HP\n");
			strcat(buffer, "Zmień model\n");
			strcat(buffer, "Napraw\n");
			strcat(buffer, red"USUŃ\n");
			Dialog::Output(playerid, 100, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
	    }
	    case 100:
	    {
	        if(!response) return End_Create(playerid);
	        
	        new vehicle_id = Create(playerid, create_value)[ 1 ];
	        if(DIN(inputtext, "Teleportuj się do pojazdu"))
	        {
				SetPlayerPosEx(playerid, Vehicle(vehicle_id, vehicle_act_position)[ 0 ], Vehicle(vehicle_id, vehicle_act_position)[ 1 ], Vehicle(vehicle_id, vehicle_act_position)[ 2 ]);
			    SetPlayerVirtualWorld(playerid, Player(playerid, player_vw) = Vehicle(vehicle_id, vehicle_vw) = GetVehicleVirtualWorld(vehicle_id));
			    SetPlayerInterior(playerid, Player(playerid, player_int) = Vehicle(vehicle_id, vehicle_int));

			    #if !STREAMER
					LoadPlayerObjects(playerid, Player(playerid, player_vw));
				#endif
				LoadPlayerText(playerid, Player(playerid, player_vw));

				End_Create(playerid);
	        }
	        else if(DIN(inputtext, "Teleportuj pojazd do siebie"))
	        {
			    GetPlayerPos(playerid, Vehicle(vehicle_id, vehicle_act_position)[ 0 ], Vehicle(vehicle_id, vehicle_act_position)[ 1 ], Vehicle(vehicle_id, vehicle_act_position)[ 2 ]);
			    GetXYInFrontOfPlayer(playerid, Vehicle(vehicle_id, vehicle_act_position)[ 0 ], Vehicle(vehicle_id, vehicle_act_position)[ 1 ], 3);
			    
				SetVehiclePos(vehicle_id, Vehicle(vehicle_id, vehicle_act_position)[ 0 ], Vehicle(vehicle_id, vehicle_act_position)[ 1 ], Vehicle(vehicle_id, vehicle_act_position)[ 2 ]);
			    SetVehicleVirtualWorld(vehicle_id, Vehicle(vehicle_id, vehicle_vw) = Player(playerid, player_vw));
                LinkVehicleToInterior(vehicle_id, Vehicle(vehicle_id, vehicle_int) = Player(playerid, player_int));
			    End_Create(playerid);
	        }
	        else if(DIN(inputtext, "Zmień kolory"))
	        {
				Dialog::Output(playerid, 101, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj kolory oddzielając je spacją.", "Zmień", "Wróć");
	            Create(playerid, create_type) = create_edit_color;
	        }
	        else if(DIN(inputtext, "Zmień przebieg"))
	        {
				Dialog::Output(playerid, 101, DIALOG_STYLE_INPUT, IN_HEAD, ""white"Podaj nową ilość przebiegu.", "Zmień", "Wróć");
	            Create(playerid, create_type) = create_edit_distance;
	        }
	        else if(DIN(inputtext, "Zmień właściciela"))
	        {
				Dialog::Output(playerid, 101, DIALOG_STYLE_LIST, IN_HEAD, "0\tBrak\n1\tGrupa\n2\tGracz\n3\tPraca dorywcza", "Zmień", "Wróć");
                Create(playerid, create_type) = create_edit_owner;
	        }
	        else if(DIN(inputtext, "Zmień ilość paliwa"))
	        {
				Dialog::Output(playerid, 101, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj nową ilość paliwa.", "Zmień", "Wróć");
	            Create(playerid, create_type) = create_edit_fuel;
	        }
	        else if(DIN(inputtext, "Zmień HP"))
	        {
                Dialog::Output(playerid, 101, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj nową ilość HP.", "Zmień", "Wróć");
				Create(playerid, create_type) = create_edit_hp;
	        }
	        else if(DIN(inputtext, "Zmień model"))
	        {
				Dialog::Output(playerid, 101, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj nazwe auta lub ID modelu.", "Dalej", "Wróć");
                Create(playerid, create_type) = create_edit_model;
	        }
	        else if(DIN(inputtext, "Zmień rejestracje"))
	        {
	            Dialog::Output(playerid, 101, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj nową rejestracje.", "Dalej", "Wróć");
	            Create(playerid, create_type) = create_edit_plate;
	        }
	        else if(DIN(inputtext, "Zmień nazwe"))
	        {
				Dialog::Output(playerid, 101, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj nową nazwę auta.", "Dalej", "Wróć");
                Create(playerid, create_type) = create_edit_name;
	        }
	        else if(DIN(inputtext, "Napraw"))
	        {
	            if(vehicle_id != INVALID_VEHICLE_ID)
	            {
					Vehicle(vehicle_id, vehicle_ac) = true;
					Vehicle(vehicle_id, vehicle_hp) = 1000.0;
					SetVehicleHealth(Vehicle(vehicle_id, vehicle_vehID), Vehicle(vehicle_id, vehicle_hp));
			   	    RepairVehicle(Vehicle(vehicle_id, vehicle_vehID));
					Vehicle(vehicle_id, vehicle_damage)[ 0 ] = Vehicle(vehicle_id, vehicle_damage)[ 1 ] = Vehicle(vehicle_id, vehicle_damage)[ 2 ] = Vehicle(vehicle_id, vehicle_damage)[ 3 ] = 0;
					SetTimerEx("EnableAnty", 2000, false, "d", vehicle_id);
				}
				else
				{
				    new tsmp[ 126 ];
				    format(tsmp, sizeof tsmp,
				        "UPDATE `surv_vehicles` SET `dmg` = '0,0,0,0', `hp` = '1000.0' WHERE `uid` = '%d'",
				        Create(playerid, create_value)[ 0 ]
					);
					mysql_query(tsmp);
				}
				SendClientMessage(playerid, SZARY, "Pojazd został naprawiony.");
	            Admin_OnDialogResponse(playerid, 99, 2, 0, "");
	        }
	        else if(DIN(inputtext, "Ustaw flagi"))
	        {
	            new v_option;
	            if(vehicle_id != INVALID_VEHICLE_ID)
	                v_option = Vehicle(vehicle_id, vehicle_option);
	            else
	            {
	                new string[ 70 ];
					format(string, sizeof string,
						"SELECT `option` FROM `surv_vehicles` WHERE `uid` = '%d'",
						Create(playerid, create_value)[ 0 ]
					);
					mysql_query(string);
					mysql_store_result();
					v_option = mysql_fetch_int();
					mysql_free_result();
	            }
	            
	            new tmp[ 1024 ];
				format(tmp, sizeof tmp, "Immobiliser:\t\t%s\n", YesOrNo(bool:(v_option & option_immo)));
				format(tmp, sizeof tmp, "%sAlarm:\t\t\t%s\n", tmp, YesOrNo(bool:(v_option & option_alarm)));
				format(tmp, sizeof tmp, "%sAudio:\t\t\t%s\n", tmp, YesOrNo(bool:(v_option & option_audio)));
				format(tmp, sizeof tmp, "%sKomputer:\t\t%s\n", tmp, YesOrNo(bool:(v_option & option_pc)));
				format(tmp, sizeof tmp, "%sBomba:\t\t\t%s\n", tmp, YesOrNo(bool:(v_option & option_bomb)));
//				format(tmp, sizeof tmp, "%sNeon:\t\t\t%s\n", tmp, YesOrNo(bool:(v_option & option_neon)));
				format(tmp, sizeof tmp, "%sSyrena:\t\t\t%s\n", tmp, YesOrNo(bool:(v_option & option_siren)));
				if(Player(playerid, player_adminlvl) == sizeof AdminLvl-1)
					format(tmp, sizeof tmp, "%sTurbo:\t\t\t%s\n", tmp, YesOrNo(bool:(v_option & option_turbo)));
				format(tmp, sizeof tmp, "%sPrzyciemnione:\t\t%s\n", tmp, YesOrNo(bool:(v_option & option_dark)));
				Dialog::Output(playerid, 101, DIALOG_STYLE_LIST, IN_HEAD, tmp, "Zmień", "Wróć");
	            Create(playerid, create_type) = create_edit_flags;
	        }
	        else if(DIN(inputtext, "USUŃ"))
	        {
			    new veh_model,
					string[ 126 ];
				if(vehicle_id != INVALID_VEHICLE_ID)
					veh_model = Vehicle(vehicle_id, vehicle_model);
				else
				{
					format(string, sizeof string,
						"SELECT `model` FROM `surv_vehicles` WHERE `uid` = '%d'",
						Create(playerid, create_value)[ 0 ]
					);
					mysql_query(string);
					mysql_store_result();
					veh_model = mysql_fetch_int();
					mysql_free_result();
				}
				
			    format(string, sizeof string, red"Czy na pewno chcesz skasować pojazd %s. UID: %d", veh_model == 0 ? ("n/a") : NazwyPojazdow[veh_model-400], Create(playerid, create_value)[ 0 ]);
				Dialog::Output(playerid, 101, DIALOG_STYLE_MSGBOX, IN_HEAD, string, "Tak", "Zamknij");

                Create(playerid, create_type) = create_edit_delete;
	        }
	        else if(DIN(inputtext, "Spawnuj"))
	        {
	            LoadVehicleEx(Create(playerid, create_value)[ 0 ]);
	            SendClientMessage(playerid, SZARY, "Pojazd zespawnowany.");
	            Admin_OnDialogResponse(playerid, 99, 2, 0, "");
	        }
	        else if(DIN(inputtext, "Odspawnuj"))
	        {
                UnSpawnVeh(vehicle_id);
	            SendClientMessage(playerid, SZARY, "Pojazd odspawnowany.");
	            Admin_OnDialogResponse(playerid, 99, 2, 0, "");
	        }
	    }
	    case 101:
	    {
	        if(!response) return Admin_OnDialogResponse(playerid, 99, 2, 0, "");
	        
	        new vehicle_id = Create(playerid, create_value)[ 1 ],
				string[ 256 ];
	        
	        switch(Create(playerid, create_type))
	        {
	            case create_edit_flags:
	            {
		            new v_option;
		            if(vehicle_id != INVALID_VEHICLE_ID)
		                v_option = Vehicle(vehicle_id, vehicle_option);
		            else
		            {
						format(string, sizeof string,
							"SELECT `option` FROM `surv_vehicles` WHERE `uid` = '%d'",
							Create(playerid, create_value)[ 0 ]
						);
						mysql_query(string);
						mysql_store_result();
						v_option = mysql_fetch_int();
						mysql_free_result();
		            }
		            if(strfind(inputtext, "Immobiliser", true) != -1)
		            {
		            	if(v_option & option_immo)
		            	    v_option -= option_immo;
						else
						    v_option += option_immo;
					}
					else if(strfind(inputtext, "Alarm", true) != -1)
		            {
		            	if(v_option & option_alarm)
		            	    v_option -= option_alarm;
						else
						    v_option += option_alarm;
					}
					else if(strfind(inputtext, "Audio", true) != -1)
		            {
		            	if(v_option & option_audio)
		            	    v_option -= option_audio;
						else
						    v_option += option_audio;
					}
					else if(strfind(inputtext, "Komputer", true) != -1)
		            {
		            	if(v_option & option_pc)
		            	    v_option -= option_pc;
						else
						    v_option += option_pc;
					}
					else if(strfind(inputtext, "Bomba", true) != -1)
		            {
		            	if(v_option & option_bomb)
		            	    v_option -= option_bomb;
						else
						    v_option += option_bomb;
					}
					else if(strfind(inputtext, "Syrena", true) != -1)
		            {
		            	if(v_option & option_siren)
		            	    v_option -= option_siren;
						else
						    v_option += option_siren;
					}
					else if(strfind(inputtext, "Turbo", true) != -1)
		            {
		            	if(v_option & option_turbo)
		            	    v_option -= option_turbo;
						else
						    v_option += option_turbo;
					}
					else if(strfind(inputtext, "Przyciemnione", true) != -1)
					{
		            	if(v_option & option_dark)
		            	    v_option -= option_dark;
						else
						    v_option += option_dark;
					}
					if(vehicle_id != INVALID_VEHICLE_ID)
					{
					    Vehicle(vehicle_id, vehicle_option) = v_option;
						InstallSiren(vehicle_id);
					}
				 	format(string, sizeof string,
						"UPDATE `surv_vehicles` SET `option` = '%d' WHERE `uid` = %d",
						v_option,
						Create(playerid, create_value)[ 0 ]
					);
					mysql_query(string);
					
					Admin_OnDialogResponse(playerid, 100, 2, 0, "Ustaw flagi");
					return 1;
	            }
	            case create_edit_name:
	            {
	            	mysql_real_escape_string(inputtext, inputtext);
					if(vehicle_id != INVALID_VEHICLE_ID)
						format(Vehicle(vehicle_id, vehicle_name), 32, inputtext);

				 	format(string, sizeof string,
						"UPDATE `surv_vehicles` SET `name` = '%s' WHERE `uid` = %d",
						inputtext,
						Create(playerid, create_value)[ 0 ]
					);
					mysql_query(string);
					
                    SendClientMessage(playerid, SZARY, "Nazwa pojazdu zmieniona pomyślnie!");
	            }
	            case create_edit_color:
	            {
		            new veh_color[ 2 ];
		            if(sscanf(inputtext, "a<d>[2]", veh_color))
		                return Dialog::Output(playerid, 101, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj kolory oddzielając je spacją.\n\n"red"Nie podano któregoś z kolorów.", "Zmień", "Zamknij");

					if(vehicle_id != INVALID_VEHICLE_ID)
						ChangeVehicleColor(Vehicle(vehicle_id, vehicle_vehID), Vehicle(vehicleid, vehicle_color)[ 0 ] = veh_color[ 0 ], Vehicle(vehicleid, vehicle_color)[ 1 ] = veh_color[ 1 ]);

				 	format(string, sizeof string,
						"UPDATE `surv_vehicles` SET `c1` = '%d', `c2` = '%d' WHERE `uid` = %d",
						veh_color[ 0 ], veh_color[ 1 ],
						Create(playerid, create_value)[ 0 ]
					);
					mysql_query(string);

					SendClientMessage(playerid, SZARY, "Kolory zostały zmienione pomyślnie.");
	            }
	            case create_edit_distance:
	            {
		            new Float:veh_distance = floatstr(inputtext);
					if(vehicle_id != INVALID_VEHICLE_ID)
						Vehicle(vehicle_id, vehicle_distance) = veh_distance;
						
					format(string, sizeof string,
						"UPDATE `surv_vehicles` SET `distance` = '%.1f' WHERE `uid` = %d",
						veh_distance,
						Create(playerid, create_value)[ 0 ]
					);
					mysql_query(string);

					SendClientMessage(playerid, SZARY, "Przebieg został zmieniony pomyślnie.");
	            }
	            case create_edit_owner:
	            {
					Create(playerid, create_value)[ 2 ] = strval(inputtext);
					Create(playerid, create_type) = create_edit_owner2;
					switch(Create(playerid, create_value)[ 2 ])
					{
					    case vehicle_owner_group:
					    {
							new temp[ 2058 ];
							mysql_query("SELECT `uid`, `name` FROM `surv_groups`");
							mysql_store_result();
							while(mysql_fetch_row(string))
							{
							    new uid,
									name[ MAX_GROUP_NAME ];
							    sscanf(string, "p<|>ds["#MAX_GROUP_NAME"]",
									uid,
									name
								);
								format(temp, sizeof temp, "%s%d\t%s\n", temp, uid, name);
							}
							mysql_free_result();
					        Dialog::Output(playerid, 101, DIALOG_STYLE_LIST, IN_HEAD, temp, "Zmień", "Wróć");
					    }
					    case vehicle_owner_player:
					    {
					        Dialog::Output(playerid, 101, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj ID gracza, który ma zostać właścicielem pojazdu.", "Zmień", "Wróć");
					    }
					    case vehicle_owner_job:
					    {
					        new temp[ 126 ];
					        for(new c; c != sizeof JobName; c++)
					            format(temp, sizeof temp, "%s%d\t%s\n", temp, c, JobName[ c ]);
					        Dialog::Output(playerid, 101, DIALOG_STYLE_LIST, IN_HEAD, temp, "Zmień", "Wróć");
					    }
					    default: Admin_OnDialogResponse(playerid, 101, 2, 0, "");
					}
					return 1;
	            }
	            case create_edit_owner2:
	            {
	                new veh_owner[ 2 ],
						uid = strval(inputtext);
	                veh_owner[ 0 ] = Create(playerid, create_value)[ 2 ];
					if(veh_owner[ 0 ] == vehicle_owner_player)
					    veh_owner[ 1 ] = Player(uid, player_uid);
					else if(veh_owner[ 0 ] == vehicle_owner_group || veh_owner[ 0 ] == vehicle_owner_job)
						veh_owner[ 1 ] = uid;
					else
					    veh_owner[ 1 ] = 0;
					if(vehicle_id != INVALID_VEHICLE_ID)
					{
						Vehicle(vehicle_id, vehicle_owner)[ 0 ] = veh_owner[ 0 ];
			    		Vehicle(vehicle_id, vehicle_owner)[ 1 ] = veh_owner[ 1 ];
					}
					format(string, sizeof string,
						"UPDATE `surv_vehicles` SET `ownerType` = '%d', `owner` = '%d' WHERE `uid` = %d",
						veh_owner[ 0 ], veh_owner[ 1 ],
						Create(playerid, create_value)[ 0 ]
					);
					mysql_query(string);
					SendClientMessage(playerid, SZARY, "Właściciel został zmieniony pomyślnie.");
	            }
	            case create_edit_fuel:
	            {
		        	new Float:veh_fuel = floatstr(inputtext);
					if(vehicle_id != INVALID_VEHICLE_ID)
						Vehicle(vehicle_id, vehicle_fuel) = veh_fuel;

					format(string, sizeof string,
						"UPDATE `surv_vehicles` SET `fuel` = '%.1f' WHERE `uid` = %d",
						veh_fuel,
						Create(playerid, create_value)[ 0 ]
					);
					mysql_query(string);

					SendClientMessage(playerid, SZARY, "Ilość paliwa została zmieniona pomyślnie.");
	            }
	            case create_edit_hp:
	            {
	                new Float:veh_hp = floatstr(inputtext);
					if(vehicle_id != INVALID_VEHICLE_ID)
					{
					    Vehicle(vehicle_id, vehicle_ac) = true;
					    SetVehicleHealth(Vehicle(vehicle_id, vehicle_vehID), Vehicle(vehicle_id, vehicle_hp) = veh_hp);
					    SetTimerEx("EnableAnty", 2000, false, "d", vehicle_id);
					}
					format(string, sizeof string,
						"UPDATE `surv_vehicles` SET `hp` = '%.1f' WHERE `uid` = %d",
						veh_hp,
						Create(playerid, create_value)[ 0 ]
					);
					mysql_query(string);
					
                    SendClientMessage(playerid, SZARY, "Ilość HP została zmieniona pomyślnie.");
	            }
	            case create_edit_model:
	            {
					if(vehicle_id != INVALID_VEHICLE_ID)
					{
					    new veh_model;
						if ('0' <= inputtext[ 0 ] <= '9')
						{
							new i = strval(inputtext);
							if(400 <= i <= 611)
							{
								veh_model = i;
							}
						}
						else
						{
							for(new i = 400, poj[ 64 ], znak; i <= 611; i++)
							{
							    poj = NazwyPojazdow[ i-400 ];
							    znak = strfind(poj, inputtext, true);
								if(znak != -1)
								{
								    veh_model = i;
								}
							}
						}
						if(!veh_model) return Dialog::Output(playerid, 101, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj nazwe auta lub ID modelu.", "Dalej", "Wróć");
						new Float:vpos[ 3 ];
						GetVehiclePos(vehicle_id, vpos[ 0 ], vpos[ 1 ], vpos[ 2 ]);
						Vehicle(vehicle_id, vehicle_model) = veh_model;

			            UnSpawnVeh(vehicle_id);
			            
			            format(string, sizeof string,
							"UPDATE `surv_vehicles` SET `model` = '%d' WHERE `uid` = %d",
							veh_model,
							Create(playerid, create_value)[ 0 ]
						);
						mysql_query(string);
						
						Create(playerid, create_value)[ 1 ] = LoadVehicleEx(Create(playerid, create_value)[ 0 ]);
						SetVehiclePos(Vehicle(Create(playerid, create_value)[ 1 ], vehicle_vehID), vpos[ 0 ], vpos[ 1 ], vpos[ 2 ]);
					}
					else
					{
					    format(string, sizeof string,
							"UPDATE `surv_vehicles` SET `model` = '%d' WHERE `uid` = %d",
							strval(inputtext),
							Create(playerid, create_value)[ 0 ]
						);
						mysql_query(string);
					}
					SendClientMessage(playerid, SZARY, "Model został zmieniony pomyślnie.");
	            }
	            case create_edit_plate:
	            {
	                mysql_real_escape_string(inputtext, inputtext);
	                
		            format(string, sizeof string,
						"UPDATE `surv_vehicles` SET `plate` = '%s' WHERE `uid` = %d",
						inputtext,
						Create(playerid, create_value)[ 0 ]
					);
					mysql_query(string);
					
	                if(vehicle_id != INVALID_VEHICLE_ID)
	                {
						new Float:vpos[ 3 ];
						GetVehiclePos(vehicle_id, vpos[ 0 ], vpos[ 1 ], vpos[ 2 ]);
						format(Vehicle(vehicle_id, vehicle_plate), 32, inputtext);

			            UnSpawnVeh(vehicle_id);

						Create(playerid, create_value)[ 1 ] = LoadVehicleEx(Create(playerid, create_value)[ 0 ]);
						SetVehiclePos(Vehicle(Create(playerid, create_value)[ 1 ], vehicle_vehID), vpos[ 0 ], vpos[ 1 ], vpos[ 2 ]);
					}
					SendClientMessage(playerid, SZARY, "Rejestracja zmieniona pomyślnie.");
	            }
	            case create_edit_delete:
	            {
	            	if(vehicle_id == INVALID_VEHICLE_ID)
					{
		                format(string, sizeof string,
							"DELETE FROM `surv_vehicles` WHERE `uid` = '%d'",
							Create(playerid, create_value)[ 0 ]
						);
						mysql_query(string);
					}
					else DeleteVeh(vehicle_id);
					
					ShowInfo(playerid, green"Pojazd skasowany pomyślnie!");
					End_Create(playerid);
					return 1;
	            }
	        }
	        Admin_OnDialogResponse(playerid, 99, 2, 0, "");
	    }
		case 102:
		{
		    if(!response) return End_Create(playerid);
		    if(DIN(inputtext, "Zmień właściciela"))
		    {
				new temp[ 2058 ] = "0\tBrak\n",
					string[ 64 ];
				mysql_query("SELECT `uid`, `name` FROM `surv_groups`");
				mysql_store_result();
				while(mysql_fetch_row(string))
				{
				    new uid,
						name[ MAX_GROUP_NAME ];
				    sscanf(string, "p<|>ds["#MAX_GROUP_NAME"]",
						uid,
						name
					);
					format(temp, sizeof temp, "%s%d\t%s\n", temp, uid, name);
				}
				mysql_free_result();
		        Dialog::Output(playerid, 103, DIALOG_STYLE_LIST, IN_HEAD, temp, "Zmień", "Wróć");
		    }
		}
		case 103:
		{
		    if(!response) return End_Create(playerid);
			new uid = strval(inputtext),
				zone = Create(playerid, create_value)[ 0 ],
				string[ 126 ];

			Zone(zone, zone_group) = uid;
			format(string, sizeof string,
				"UPDATE `surv_zone` SET `group_uid` = '%d' WHERE `uid` = '%d'",
				Zone(zone, zone_group),
				Zone(zone, zone_uid)
			);
			mysql_query(string);
			if(uid)
			{
				format(string, sizeof string,
					"SELECT `color` FROM `surv_groups` WHERE `uid` = '%d'",
					Zone(zone, zone_group)
				);
				mysql_query(string);
				mysql_store_result();
				mysql_fetch_row(string);
		    	sscanf(string, "x", Zone(zone, zone_color));
	            mysql_free_result();
            }
            else Zone(zone, zone_color) = 0xFFFFFF00;

			foreach(Player, i) ShowPlayerZone(i);

			SendClientMessage(playerid, SZARY, "Właściciel został zmieniony pomyślnie.");
            End_Create(playerid);
		}
		case 104:
		{
		    if(!response) return End_Create(playerid);
		    Create(playerid, create_type) = strval(inputtext);
		    Dialog::Output(playerid, 105, DIALOG_STYLE_INPUT, IN_HEAD, "Podaj nazwę grupy", "Dalej", "Zamknij");
		}
		case 105:
		{
		    if(!response) return End_Create(playerid);
		    if(strlen(inputtext) > MAX_GROUP_NAME) return Dialog::Output(playerid, 105, DIALOG_STYLE_INPUT, IN_HEAD, "Podaj nazwę grupy", "Dalej", "Zamknij");
		    format(Create(playerid, create_name), MAX_GROUP_NAME, inputtext);
		    Dialog::Output(playerid, 106, DIALOG_STYLE_INPUT, IN_HEAD, "Podaj ID gracza", "Dalej", "Zamknij");
		}
		case 106:
		{
		    if(!response) return End_Create(playerid);
		    new player = strval(inputtext);
		    if(!IsPlayerConnected(player))
		        return Dialog::Output(playerid, 106, DIALOG_STYLE_INPUT, IN_HEAD, "Podaj nazwę grupy", "Dalej", "Zamknij");
	        if(Group(player, MAX_GROUPS-1, group_uid))
				return ShowInfo(playerid, red"Gracz nie ma wolnych slotów!");

			new uid = CreateGroup(player, Create(playerid, create_type), Create(playerid, create_name));
			new string[ 126 ];
			format(string, sizeof string,
				green"Dodano grupe\n"white"UID:\t%d\nNazwa:\t%s\nTyp:\t%d(%s)\nLider:\t%s",
				uid,
				Create(playerid, create_name),
				Create(playerid, create_type),
				GroupName[ Create(playerid, create_type) ],
			 	NickName(player)
			);
			ShowInfo(playerid, string);

			End_Create(playerid);
		}
		case 121:
		{
		    if(!response) return End_Create(playerid);
		    Create(playerid, create_type) = strval(inputtext);
		    Dialog::Output(playerid, 122, DIALOG_STYLE_LIST, IN_HEAD, "0\tBrak\n1\tGrupa\n2\tDom\n3\tBingo\n4\tHotel", "Dalej", "Zamknij");
		}
		case 122:
		{
		    if(!response) return End_Create(playerid);
			Create(playerid, create_value)[ 0 ] = strval(inputtext);
			switch(Create(playerid, create_value)[ 0 ])
			{
			    case door_type_group:
			    {
					new temp[ 2058 ], string[ 64 ];
					mysql_query("SELECT `uid`, `name` FROM `surv_groups`");
					mysql_store_result();
					while(mysql_fetch_row(string))
					{
					    new uid,
							name[ MAX_GROUP_NAME ];
					    sscanf(string, "p<|>ds["#MAX_GROUP_NAME"]",
							uid,
							name
						);
						format(temp, sizeof temp, "%s%d\t%s\n", temp, uid, name);
					}
					mysql_free_result();
			        Dialog::Output(playerid, 123, DIALOG_STYLE_LIST, IN_HEAD, temp, "Zmień", "Wróć");
			    }
			    case door_type_house:
			    {
			        Dialog::Output(playerid, 123, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj ID gracza, który ma zostać właścicielem drzwi.", "Dalej", "Zamknij");
			    }
			    default: Admin_OnDialogResponse(playerid, 123, 2, 0, "0");
			}
		}
		case 123:
		{
		    if(!response) return End_Create(playerid);
		    if(Create(playerid, create_value)[ 0 ] == door_type_house)
		    {
			    new victimid;
	            sscanf(inputtext, "u", victimid);
	            if(!IsPlayerConnected(victimid))
	            {
	                NoPlayer(playerid);
	                End_Create(playerid);
	                return 1;
	            }
	            Create(playerid, create_value)[ 1 ] = victimid;
            }
            else Create(playerid, create_value)[ 1 ] = strval(inputtext);
			    
			Dialog::Output(playerid, 124, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj nazwe drzwi.", "Dalej", "Zamknij");
		}
		case 124:
		{
		    if(!response) return End_Create(playerid);
		    mysql_real_escape_string(inputtext, inputtext);
		    format(Create(playerid, create_name), MAX_ITEM_NAME, inputtext);
		    
		    new temp[ 256 ], string[ 64 ];
		    mysql_query("SELECT * FROM `surv_int_cat`");
		    mysql_store_result();
		    while(mysql_fetch_row(string))
		    {
		        new uid, name[ 32 ];
		        sscanf(string, "p<|>ds[32]", uid, name);
		        format(temp, sizeof temp, "%s%d\t%s\n", temp, uid, name);
		    }
		    mysql_free_result();
		    Dialog::Output(playerid, 125, DIALOG_STYLE_LIST, IN_HEAD, temp, "Dalej", "Zamknij");
		}
		case 125:
		{
		    if(!response) return End_Create(playerid);
			new cat = strval(inputtext);
			
			new temp[ 512 ], string[ 70 ];
			format(string, sizeof string,
			    "SELECT `uid`, `name` FROM `surv_int` WHERE `cat` = '%d'",
			    cat
			);
			mysql_query(string);
		    mysql_store_result();
		    while(mysql_fetch_row(string))
		    {
		        new uid, name[ 32 ];
		        sscanf(string, "p<|>ds[32]", uid, name);
		        format(temp, sizeof temp, "%s%d\t%s\n", temp, uid, name);
		    }
		    mysql_free_result();
		    Dialog::Output(playerid, 126, DIALOG_STYLE_LIST, IN_HEAD, temp, "Dalej", "Wróć");
		}
		case 126:
		{
		    if(!response) return Admin_OnDialogResponse(playerid, 124, 2, 0, Create(playerid, create_name));
		    new doorid,
				Float:pos[ 4 ],
				pos_int,
				pos_vw,
				value = Create(playerid, create_value)[ 1 ];
		    
			GetPlayerPos(playerid, pos[ 0 ], pos[ 1 ], pos[ 2 ]);
			GetPlayerFacingAngle(playerid, pos[ 3 ]);
			pos_int = GetPlayerInterior(playerid);
			pos_vw = GetPlayerVirtualWorld(playerid);
			
			if(Create(playerid, create_value)[ 0 ] == door_type_house)
			    value = Player(value, player_uid);
			    
			doorid = CreateDoor(
				Create(playerid, create_name),
				Create(playerid, create_value)[ 0 ],
				value,
				pos[ 0 ],
				pos[ 1 ],
				pos[ 2 ],
				pos[ 3 ],
				pos_int,
				pos_vw,
				strval(inputtext),
				Create(playerid, create_type)
			);
			if(!doorid) return Chat::Output(playerid, SZARY, "Wystąpił błąd!"), End_Create(playerid);
			
			new string[ 256 ];
			format(string, sizeof string, "Stworzono Drzwi (UID: %d, Nazwa: %s)!", Door(doorid, door_uid), Door(doorid, door_name));
			Chat::Output(playerid, SZARY, string);
			
			if(Create(playerid, create_value)[ 0 ] == door_type_house)
			{
				format(string, sizeof string,
					"INSERT INTO `surv_members` (`player`, `type`, `id`, `rankid`) VALUES ('%d', '"#member_type_doors"', '%d', '1')",
					value,
					Door(doorid, door_uid)
				);
				mysql_query(string);
			}

            End_Create(playerid);
		}
		case 137:
		{
		    if(!response) return End_Create(playerid);
		    
		    new doorid = GetPlayerDoor(playerid, false);

	 	    GetPlayerPos(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]);
			GetXYInFrontOfPlayer(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], 0.5);
		    Player(playerid, player_position)[ 2 ] -= player_down;

			new string[ 200 ],
				objectuid,
				objx_model = strval(inputtext);

			if(!(0 <= objx_model <= 100000))
			    return ShowCMD(playerid, "Error: Zbyt wysoki lub zbyt niski model obiektu!"), End_Create(playerid);

			if(CrashedObject(objx_model))
			    return ShowCMD(playerid, "Error: Objekt crasujący rozgrywkę!"), End_Create(playerid);

			format(string, sizeof string,
				"INSERT INTO `surv_objects` (`model`, `X`, `Y`, `Z`, `door`, `accept`) VALUES ('%d', '%f', '%f', '%f', '%d', 1)",
				objx_model,
				Player(playerid, player_position)[ 0 ],
				Player(playerid, player_position)[ 1 ],
				Player(playerid, player_position)[ 2 ],
				Door(doorid, door_uid)
			);
			mysql_query(string);
			objectuid = mysql_insert_id();

			#if STREAMER
			    new objectid;
				objectid = CreateDynamicObject(objx_model, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ], 0, 0, 0, Door(doorid, door_in_vw), -1, -1, 1000.0);
			    Streamer_SetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_EXTRA_ID, objectuid);
				Streamer_Update(playerid);
				Player(playerid, player_selected_object) = objectid;
				EditDynamicObject(playerid, objectid);
			#else
				foreach(Player, i)
				{
					if(GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(i)) continue;

					new objectid = 1;
					for(; objectid != MAX_OBJECTS; objectid++)
					    if(!IsValidPlayerObject(playerid, Object(playerid, objectid, obj_objID)) && !IsValidObject(objectid))
					        break;

					if(objectid >= MAX_OBJECTS)
			        {
			            DestroyPlayerObject(i, objectid);
						ShowInfo(playerid, red"W tym pomieszczeniu skończył się limit obiektów!");
						return 1;
					}
					Object(i, objectid, obj_objID) = CreatePlayerObject(i, objx_model, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ], 0, 0, 0, 200.0);
					Object(i, objectid, obj_uid) = objectuid;
					if(i == playerid)
					{
					    Player(playerid, player_selected_object) = objectid;
						EditPlayerObject(playerid, Object(playerid, objectid, obj_objID));
					}
				}
			#endif
			Create(playerid, create_value)[ 0 ] = objectuid;
		}
		case 138:
		{
		    if(!response) return End_Create(playerid);
			switch(listitem)
			{
			    case 0: Dialog::Output(playerid, 139, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj UID przedmiotu.", "Dalej", "Zamknij");
			    case 1:
			    {
			        new temp[ 1024 ], string[ 128 ];
			        
			        new uid, count;
			        format(string, sizeof string,
			            "SELECT `uid`, `name` FROM `surv_items` WHERE `ownerType` = '"#item_place_player"' AND `owner` = '%d'",
			            Player(playerid, player_uid)
					);
			        mysql_query(string);
			        mysql_store_result();
			        while(mysql_fetch_row(string))
			        {
			            new name[ MAX_ITEM_NAME ];
			        
			            sscanf(string, "p<|>ds["#MAX_ITEM_NAME"]", uid, name);
			            
			            format(temp, sizeof temp, "%s%d\t%s\n", temp, uid, name);
			            count++;
			        }
			        mysql_free_result();
			        
			        if(count == 1)
			        {
			            OnDialogResponseEx(playerid, 139, 2, 0, temp);
			        }
			        else if(!count) ShowInfo(playerid, red"Nie posiadasz żadnych przedmiotów!");
			        else Dialog::Output(playerid, 139, DIALOG_STYLE_LIST, IN_HEAD, temp, "Wybierz", "Zamknij");
			    }
			}
		}
		case 139:
		{
		    if(!response) return End_Create(playerid);
		    if(!Create(playerid, create_value)[ 0 ])
		    	Create(playerid, create_value)[ 0 ] = strval(inputtext);
		    	
		    new string[ 128 ];
	        format(string, sizeof string,
	            "SELECT * FROM `surv_items` WHERE `uid` = '%d'",
	            Create(playerid, create_value)[ 0 ]
			);
	        mysql_query(string);
	        mysql_store_result();
	        mysql_fetch_row(string);
	        if(!mysql_num_rows())
	        {
	            ShowInfo(playerid, red"Ten przedmiot nie istnieje!");
	            mysql_free_result();
				End_Create(playerid);
	            return 1;
	        }
	        mysql_free_result();
	        
	        new itm_uid,
				itm_name[ MAX_ITEM_NAME ],
				itm_owner[ 2 ],
	            itm_typ,
	            itm_value[ 2 ],
	            Float:itm_value3,
	            Float:itm_pos[ 3 ],
	            itm_vw,
	            itm_weight,
	            itm_lastused,
	            itm_created[ 32 ];
				
				// 1078|Camera|1|1|1|43|48|0|0|0|0|0|0|0|0|1390313934|2014-01-21 15:17:59
			sscanf(string, "p<|>ds["#MAX_ITEM_NAME"]a<d>[2]da<d>[2]fa<f>[3]d{d}d{d}ds[32]",
			    itm_uid,
			    itm_name,
			    itm_owner,
			    itm_typ,
			    itm_value,
			    itm_value3,
			    itm_pos,
			    itm_vw,
			    itm_weight,
			    itm_lastused,
			    itm_created
			);
			new owner_name[ 32 ];
			if(itm_owner[ 0 ] != item_place_none)
			{
			    if(itm_owner[ 0 ] == item_place_vehicle || itm_owner[ 0 ] == item_place_tuning)
			        format(string, sizeof string,
			            "SELECT `name` FROM `surv_vehicles` WHERE `uid` = '%d'",
			            itm_owner[ 1 ]
					);
				else if(itm_owner[ 0 ] == item_place_player)
			        format(string, sizeof string,
			            "SELECT `name` FROM `surv_players` WHERE `uid` = '%d'",
			            itm_owner[ 1 ]
					);
				else if(itm_owner[ 0 ] == item_place_item)
			        format(string, sizeof string,
			            "SELECT `name` FROM `surv_items` WHERE `uid` = '%d'",
			            itm_owner[ 1 ]
					);
		        mysql_query(string);
		        mysql_store_result();
		        if(!mysql_num_rows()) owner_name = "n/a";
				else mysql_fetch_row(owner_name);
		        mysql_free_result();
			}
			new lastuseStr[ 32 ];
			ReturnTimeAgo(itm_lastused, lastuseStr);
			
			new temp[ 512 ];
			format(temp, sizeof temp, "UID:\t\t%d\n", itm_uid);
			format(temp, sizeof temp, "%sNazwa:\t\t%s\n", temp, itm_name);
			format(temp, sizeof temp, "%sTyp:\t\t%d (%s)\n", temp, itm_typ, ItemName[ itm_typ ]);
			format(temp, sizeof temp, "%sWaga:\t\t%dg\n", temp, itm_weight);
			format(temp, sizeof temp, "%sWartość 1:\t%d\n", temp, itm_value[ 0 ]);
			format(temp, sizeof temp, "%sWartość 2:\t%d\n", temp, itm_value[ 1 ]);
			format(temp, sizeof temp, "%sWartość 3:\t%.2f\n", temp, itm_value3);
			format(temp, sizeof temp, "%sOst. użyty:\t%s\n", temp, lastuseStr);
			format(temp, sizeof temp, "%sStworzony:\t%s\n", temp, itm_created);
			strcat(temp, "------------------------\n");
			if(itm_owner[ 0 ] == item_place_vehicle)
			{
				format(temp, sizeof temp, "%sOwnerType:\tPojazd\n", temp);
				format(temp, sizeof temp, "%sOwner:\t\t%d (%s)\n", temp, itm_owner[ 1 ], owner_name);
			}
			else if(itm_owner[ 0 ] == item_place_player)
			{
			    UnderscoreToSpace(owner_name);
				format(temp, sizeof temp, "%sOwnerType:\tGracz\n", temp);
				format(temp, sizeof temp, "%sOwner:\t\t%d (%s)\n", temp, itm_owner[ 1 ], owner_name);
			}
			else if(itm_owner[ 0 ] == item_place_item)
			{
				format(temp, sizeof temp, "%sOwnerType:\tPrzedmiot\n", temp);
				format(temp, sizeof temp, "%sOwner:\t\t%d (%s)\n", temp, itm_owner[ 1 ], owner_name);
			}
			else if(itm_owner[ 0 ] == item_place_tuning)
			{
				format(temp, sizeof temp, "%sOwnerType:\tTuning\n", temp);
				format(temp, sizeof temp, "%sOwner:\t\t%d (%s)\n", temp, itm_owner[ 1 ], owner_name);
			}
			else
			{
				format(temp, sizeof temp, "%sOwnerType:\tBrak\n", temp);
				format(temp, sizeof temp, "%sPozycja:\t%f %f %f\n", temp, itm_pos[ 0 ], itm_pos[ 1 ], itm_pos[ 2 ]);
				format(temp, sizeof temp, "%sVW:\t\t%d\n", temp, itm_vw);
			}
			strcat(temp, "------------------------\n");
			strcat(temp, "Zmień nazwę\n");
			strcat(temp, "Zmień typ\n");
			strcat(temp, "Zmień wartość 1\n");
			strcat(temp, "Zmień wartość 2\n");
			strcat(temp, "Zmień wartość 3\n");
			if(itm_owner[ 0 ] == item_place_player && itm_owner[ 1 ] != Player(playerid, player_uid))
				strcat(temp, "Przypisz sobie\n");
			strcat(temp, red"Skasuj\n");
			Dialog::Output(playerid, 140, DIALOG_STYLE_LIST, IN_HEAD, temp, "Wybierz", "Zamknij");
		}
		case 140:
		{
		    if(!response) return End_Create(playerid);
		    
		    //new itm_uid = Create(playerid, create_value)[ 0 ];
		    if(DIN(inputtext, "Zmień nazwę"))
		    {
				Dialog::Output(playerid, 141, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj nową nazwę przedmiotu", "Wybierz", "Zamknij");
		        Create(playerid, create_type) = create_edit_name;
		    }
		    else if(DIN(inputtext, "Zmień typ"))
		    {
	            new temp[ 512 ];
				for(new id; id != sizeof ItemName; id++)
				    format(temp, sizeof temp, "%s%d\t%s\n", temp, id, ItemName[ id ]);

				Dialog::Output(playerid, 141, DIALOG_STYLE_LIST, IN_HEAD, temp, "Wybierz", "Zamknij");
		        Create(playerid, create_type) = create_edit_type;
		    }
		    else if(DIN(inputtext, "Zmień wartość 1"))
		    {
				Dialog::Output(playerid, 141, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj nową wartość 1 przedmiotu", "Wybierz", "Zamknij");
                Create(playerid, create_type) = create_edit_value1;
		    }
		    else if(DIN(inputtext, "Zmień wartość 2"))
		    {
				Dialog::Output(playerid, 141, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj nową wartość 2 przedmiotu", "Wybierz", "Zamknij");
                Create(playerid, create_type) = create_edit_value2;
		    }
		    else if(DIN(inputtext, "Zmień wartość 3"))
		    {
				Dialog::Output(playerid, 141, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj nową wartość 3 przedmiotu", "Wybierz", "Zamknij");
                Create(playerid, create_type) = create_edit_value3;
		    }
		    else if(DIN(inputtext, "Przypisz sobie"))
		    {

		    }
		    else if(DIN(inputtext, "Skasuj"))
		    {
                Dialog::Output(playerid, 141, DIALOG_STYLE_MSGBOX, IN_HEAD, white"Na pewno chcesz skasować ten przedmiot?", "Tak", "Zamknij");
                Create(playerid, create_type) = create_edit_delete;
		    }
		}
		case 141:
		{
		    if(!response) return End_Create(playerid);
		    new itm_uid = Create(playerid, create_value)[ 0 ],
				temp[ 256 ];
		    switch(Create(playerid, create_type))
		    {
		        case create_edit_name:
		        {
		        	mysql_real_escape_string(inputtext, inputtext);
		        	format(temp, sizeof temp,
						"UPDATE `surv_items` SET `name` = '%s' WHERE `uid` = '%d'",
		        	    inputtext,
		        	    itm_uid
					);
					mysql_query(temp);
					ShowCMD(playerid, "Nazwa przedmiotu zmieniona pomyślnie!");
		        }
		        case create_edit_type:
		        {
		            new itm_type = strval(inputtext);
		        	format(temp, sizeof temp,
						"UPDATE `surv_items` SET `type` = '%d' WHERE `uid` = '%d'",
		        	    itm_type,
		        	    itm_uid
					);
					mysql_query(temp);
                    ShowCMD(playerid, "Typ przedmiotu zmieniony pomyślnie!");
		        }
		        case create_edit_value1:
		        {
		            new itm_v = strval(inputtext);
		        	format(temp, sizeof temp,
						"UPDATE `surv_items` SET `v1` = '%d' WHERE `uid` = '%d'",
		        	    itm_v,
		        	    itm_uid
					);
					mysql_query(temp);
                    ShowCMD(playerid, "Wartość 1 przedmiotu zmieniona pomyślnie!");
		        }
		        case create_edit_value2:
		        {
		            new itm_v = strval(inputtext);
		        	format(temp, sizeof temp,
						"UPDATE `surv_items` SET `v2` = '%d' WHERE `uid` = '%d'",
		        	    itm_v,
		        	    itm_uid
					);
					mysql_query(temp);
                    ShowCMD(playerid, "Wartość 2 przedmiotu zmieniona pomyślnie!");
		        }
		        case create_edit_value3:
				{
				    new Float:itm_v = floatstr(inputtext);
		        	format(temp, sizeof temp,
						"UPDATE `surv_items` SET `v3` = '%f' WHERE `uid` = '%d'",
		        	    itm_v,
		        	    itm_uid
					);
					mysql_query(temp);
                    ShowCMD(playerid, "Wartość 3 przedmiotu zmieniona pomyślnie!");
				}
				case create_edit_delete:
				{
		        	format(temp, sizeof temp,
						"DELETE FROM `surv_items` WHERE `uid` = '%d'",
		        	    itm_uid
					);
					mysql_query(temp);
					ShowCMD(playerid, "Przedmiot skasowany pomyślnie!");
				}
		    }
		    End_Create(playerid);
		}
		case 142:
		{
		    if(!response) return End_Create(playerid);
		    if(!Create(playerid, create_value)[ 0 ])
		    	Create(playerid, create_value)[ 0 ] = strval(inputtext);

		    new string[ 128 ];
	        format(string, sizeof string,
	            "SELECT * FROM `surv_groups` WHERE `uid` = '%d'",
	            Create(playerid, create_value)[ 0 ]
			);
	        mysql_query(string);
	        mysql_store_result();
	        mysql_fetch_row(string);
	        if(!mysql_num_rows())
	        {
	            ShowInfo(playerid, red"Taka grupa nie istnieje!");
	            mysql_free_result();
	            End_Create(playerid);
	            return 1;
	        }
	        mysql_free_result();
	        
	        new g_uid,
				g_name[ MAX_GROUP_NAME ],
				g_tag[ 5 ],
				g_type,
				g_color,
				g_option,
				g_v1[ 32 ],
				g_v2[ 32 ],
				Float:g_cash,
				g_points,
				g_tpoints;
				
			sscanf(string, "p<|>ds["#MAX_GROUP_NAME"]s[5]dxds[32]s[32]fdd",
			    g_uid,
			    g_name,
			    g_tag,
				g_type,
				g_color,
				g_option,
				g_v1,
				g_v2,
				g_cash,
				g_points,
				g_tpoints
			);
	        
	        new temp[ 1024 ];
			format(temp, sizeof temp, "UID:\t\t%d\n", g_uid);
			format(temp, sizeof temp, "%sNazwa:\t\t%s\n", temp, g_name);
			format(temp, sizeof temp, "%sTyp:\t\t%d (%s)\n", temp, g_type, GroupName[ g_type ]);
            format(temp, sizeof temp, "%sKolor:\t\t{%06x}#%x\n", temp, g_color >>> 8, g_color);
            format(temp, sizeof temp, "%sValue:\t\t%s:%s\n", temp, g_v1, g_v2);
            format(temp, sizeof temp, "%sCash:\t\t$%.2f\n", temp, g_cash);
            format(temp, sizeof temp, "%sPoints:\t\t%d:%d\n", temp, g_points, g_tpoints);
            strcat(temp, "------------------------\n");
            strcat(temp, "Zmień nazwę\n");
            strcat(temp, "Zmień typ\n");
            strcat(temp, "Nadaj lidera\n");
            strcat(temp, "Przyjmij\n");
            strcat(temp, "Wyrzuć\n");
            strcat(temp, "Ustaw flagi\n");
            strcat(temp, "Skasuj\n");
            Dialog::Output(playerid, 143, DIALOG_STYLE_LIST, IN_HEAD, temp, "Wybierz", "Zamknij");
		}
		case 143:
		{
			if(!response) return End_Create(playerid);
			if(DIN(inputtext, "Zmień nazwę"))
			{
			    Create(playerid, create_type) = create_edit_name;

            	Dialog::Output(playerid, 144, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj nową nazwę grupy", "Wybierz", "Zamknij");
			}
			else if(DIN(inputtext, "Zmień typ"))
			{
                Create(playerid, create_type) = create_edit_type;
                
			    new temp[ 512 ];
                for(new id; id != sizeof GroupName; id++)
					format(temp, sizeof temp, "%s%d\t%s\n", temp, id, GroupName[ id ]);

            	Dialog::Output(playerid, 144, DIALOG_STYLE_LIST, IN_HEAD, temp, "Wybierz", "Zamknij");
			}
			else if(DIN(inputtext, "Nadaj lidera"))
			{
                Create(playerid, create_type) = create_edit_owner;
                
            	Dialog::Output(playerid, 144, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj ID lidera.", "Wybierz", "Zamknij");
			}
			else if(DIN(inputtext, "Wyrzuć"))
			{
			    Create(playerid, create_type) = create_edit_person;
			    
				new temp[ 512 ];
				foreach(Player, i)
				{
				    new g = IsPlayerInUidGroup(i, Create(playerid, create_value)[ 0 ]);
				    if(!g) continue;
				    
				    format(temp, sizeof temp, "%s%d\t%s\n", temp, i, NickName(i));
				}
				if(isnull(temp)) ShowInfo(playerid, red"Do tej grupy nikt nie należy!");
            	else Dialog::Output(playerid, 144, DIALOG_STYLE_LIST, IN_HEAD, temp, "Wybierz", "Zamknij");
			}
			else if(DIN(inputtext, "Ustaw flagi"))
			{

			}
			else if(DIN(inputtext, "Skasuj"))
			{
                Create(playerid, create_type) = create_edit_delete;

                Dialog::Output(playerid, 144, DIALOG_STYLE_MSGBOX, IN_HEAD, white"Czy napewno chcesz skasować tą grupę?", "Tak", "Nie");
			}
			else if(DIN(inputtext, "Przyjmij"))
			{
                Create(playerid, create_type) = create_edit_add;

                Dialog::Output(playerid, 144, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj ID gracza, który ma zostać przyjęty do tej grupy.", "Wybierz", "Zamknij");
			}
		}
		case 144:
		{
		    if(!response) return End_Create(playerid);
		    new g_uid = Create(playerid, create_value)[ 0 ],
				string[ 150 ];
		    switch(Create(playerid, create_type))
		    {
		        case create_edit_name:
		        {
		        	mysql_real_escape_string(inputtext, inputtext);
		        	
		        	format(string, sizeof string, "UPDATE `surv_groups` SET `name` = '%s' WHERE `uid` = '%d'",
		        		inputtext,
		        		g_uid
					);
					mysql_query(string);
					
					foreach(Player, i)
					{
					    new g = IsPlayerInUidGroup(i, g_uid);
					    if(!g) continue;
					    format(Group(i, g, group_name), MAX_GROUP_NAME, inputtext);
					}
					ShowCMD(playerid, "Nazwa grupy zmieniona pomyślnie!");
		        }
		        case create_edit_type:
		        {
					new g_type = strval(inputtext);
					
		        	format(string, sizeof string, "UPDATE `surv_groups` SET `type` = '%d' WHERE `uid` = '%d'",
		        		g_type,
		        		g_uid
					);
					mysql_query(string);

					foreach(Player, i)
					{
					    new g = IsPlayerInUidGroup(i, g_uid);
					    if(!g) continue;
					    Group(i, g, group_type) = g_type;
					}
					ShowCMD(playerid, "Typ grupy zmieniony pomyślnie!");
		        }
		        case create_edit_delete:
		        {
		            DeleteGroup(g_uid);
		            ShowCMD(playerid, "Grupa skasowana pomyślnie!");
		        }
		        case create_edit_person:
		        {
		            new victimid = strval(inputtext);
		            RemovePlayerFromGroup(victimid, g_uid);
		            ShowCMD(playerid, "Gracz wyrzucony z grupy pomyślnie!");
		        }
		        case create_edit_add:
		        {
		            new victimid = strval(inputtext);
					new g = IsPlayerInUidGroup(victimid, g_uid);
		            if(!g) g = AddPlayerToGroup(victimid, g_uid);
		            if(g) ShowCMD(playerid, "Gracz został przyjęty pomyślnie!");
		        }
		        case create_edit_owner:
		        {
		            new victimid = strval(inputtext);
					new g = IsPlayerInUidGroup(victimid, g_uid);
		            if(!g) g = AddPlayerToGroup(victimid, g_uid);
		            if(!g) return End_Create(playerid);
		            
	                new rankid;
	                format(string, sizeof string,
						"SELECT `uid` FROM `surv_ranks` WHERE `group_uid` = '%d' AND `can` & '"#member_can_nodel"'",
						g_uid
					);
					mysql_query(string);
					mysql_store_result();
					if(mysql_num_rows())
						rankid = mysql_fetch_int();
					mysql_free_result();
					
					Group(victimid, g, group_can) = 1+2+4+8+16+32+64+128+member_can_panel+member_can_nodel;

					if(!rankid)
					{
					    format(string, sizeof string,
					        "INSERT INTO `surv_ranks` VALUES (NULL, '%d', 'Lider', '%d', '0');",
					        g_uid,
					        Group(victimid, g, group_can)
						);
						mysql_query(string);
						rankid = mysql_insert_id();
					}

					format(string, sizeof string,
						"UPDATE `surv_members` SET `rankid` = '%d' WHERE `player` = '%d' AND `type` = '"#member_type_group"' AND `id` = '%d'",
					    rankid,
					    Player(victimid, player_uid),
					    g_uid
					);
					mysql_query(string);
					
					ShowCMD(playerid, "Gracz został mianowany liderem grupy!");
		        }
		    }
		    End_Create(playerid);
		}
		case 145:
		{
		    if(!response) return End_Create(playerid);

	        if(DIN(inputtext, "Zmień właściciela"))
	        {
				Dialog::Output(playerid, 146, DIALOG_STYLE_LIST, IN_HEAD, "0\tBrak\n1\tGrupa\n2\tGracz\n3\tBingo\n4\tHotel", "Zmień", "Wróć");
                Create(playerid, create_type) = create_edit_owner;
	        }
	        else if(DIN(inputtext, "Zmień zew vw"))
	        {
	            Dialog::Output(playerid, 146, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj vw drzwi", "Zmień", "Wróć");
                Create(playerid, create_type) = create_edit_out_vw;
	        }
	        else if(DIN(inputtext, "Zmień wew vw"))
	        {
	            Dialog::Output(playerid, 146, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj vw drzwi", "Zmień", "Wróć");
                Create(playerid, create_type) = create_edit_in_vw;
	        }
	        else if(DIN(inputtext, "Zmień pickup"))
	        {
	            new tmp[ 512 ];
                for(new id; id != sizeof PickModel; id++)
					format(tmp, sizeof tmp, "%s%d\t%s\n", tmp, PickModel[ id ][ model_id ], PickModel[ id ][ model_name ]);
				Dialog::Output(playerid, 146, DIALOG_STYLE_LIST, IN_HEAD, tmp, "Zmień", "Wróć");

	            Create(playerid, create_type) = create_edit_pickup;
	        }
	        else if(DIN(inputtext, "Zmień interior"))
	        {
			    new tmp[ 256 ], string[ 64 ];
			    mysql_query("SELECT * FROM `surv_int_cat`");
			    mysql_store_result();
			    while(mysql_fetch_row(string))
			    {
			        new uid, name[ 32 ];
			        sscanf(string, "p<|>ds[32]", uid, name);
			        format(tmp, sizeof tmp, "%s%d\t%s\n", tmp, uid, name);
			    }
			    mysql_free_result();
			    Dialog::Output(playerid, 146, DIALOG_STYLE_LIST, IN_HEAD, tmp, "Wybierz", "Wróć");
			    
                Create(playerid, create_type) = create_edit_interior;
	        }
	        else if(DIN(inputtext, "Zmień pozycje wewnętrzną"))
	        {
	            ShowCMD(playerid, "Wciśnij enter, gdy będziesz gotowy zapisać nową pozycje wewnętrzną! Y by anulować.");
                Create(playerid, create_type) = create_edit_inside;
	        }
	        else if(DIN(inputtext, "Zmień pozycje zewnętrzną"))
	        {
	            ShowCMD(playerid, "Wciśnij enter, gdy będziesz gotowy zapisać nową pozycje zewnętrzną! Y by anulować.");
                Create(playerid, create_type) = create_edit_outside;
	        }
	        else if(DIN(inputtext, "Zmień to UID"))
	        {
	            Dialog::Output(playerid, 146, DIALOG_STYLE_INPUT, IN_HEAD, "Podaj UID drzwi, na które ma się zmieniać po wejściu", "Zmień", "Wróć");
	            Create(playerid, create_type) = create_edit_to;
	        }
	        else if(DIN(inputtext, "USUŃ"))
	        {
	            Dialog::Output(playerid, 146, DIALOG_STYLE_MSGBOX, IN_HEAD, white"Czy na pewno chcesz skasować te drzwi?", "Tak", "Nie");
	            Create(playerid, create_type) = create_edit_delete;
	        }
		}
		case 146:
		{
		    if(!response) return End_Create(playerid);
		    new door_id = Create(playerid, create_value)[ 0 ], gz[ 256 ];
		    switch(Create(playerid, create_type))
		    {
		        case create_edit_to:
		        {
		            Door(door_id, door_to) = strval(inputtext);
		            format(gz, sizeof gz,
		                "UPDATE `surv_doors` SET `to` = '%d' WHERE `uid` = '%d'",
		                Door(door_id, door_to),
		                Door(door_id, door_uid)
					);
					mysql_query(gz);
                    ShowCMD(playerid, "Zmiana UID drzwi po przejściu ustawiona pomyślnie!");
		        }
		        case create_edit_out_vw:
		        {
		            Door(door_id, door_out_vw) = strval(inputtext);
		            foreach(Player, i)
		            {
		                if(Player(i, player_door) != door_id) continue;
		                SetPlayerVirtualWorld(i, Player(i, player_vw) = Door(door_id, door_in_vw));
		            }
		            format(gz, sizeof gz,
		                "UPDATE `surv_doors` SET `out_pos_vw` = '%d' WHERE `uid` = '%d'",
		                Door(door_id, door_out_vw),
		                Door(door_id, door_uid)
					);
					mysql_query(gz);
					ShowCMD(playerid, "Zewnętrzny vw ustawiony pomyślnie!");
				}
		        case create_edit_in_vw:
		        {
		            Door(door_id, door_in_vw) = strval(inputtext);
		            foreach(Player, i)
		            {
		                if(Player(i, player_door) != door_id) continue;
		                SetPlayerVirtualWorld(i, Player(i, player_vw) = Door(door_id, door_in_vw));
		            }
		            format(gz, sizeof gz,
		                "UPDATE `surv_doors` SET `in_pos_vw` = '%d' WHERE `uid` = '%d'",
		                Door(door_id, door_in_vw),
		                Door(door_id, door_uid)
					);
					mysql_query(gz);
					ShowCMD(playerid, "Wewnętrzny vw ustawiony pomyślnie!");
		        }
		        case create_edit_pickup:
		        {
		            if(Door(door_id, door_pickupID)) DestroyPickup(Door(door_id, door_pickupID));
		            Door(door_id, door_pickup) = strval(inputtext);
		            if(Door(door_id, door_pickup))
		            {
						new pickupid;
						pickupid = CreatePickup(Door(door_id, door_pickup), 2, Door(door_id, door_out_pos)[ 0 ], Door(door_id, door_out_pos)[ 1 ], Door(door_id, door_out_pos)[ 2 ], Door(door_id, door_out_vw));
				        Pickup(pickupid, pickup_model) 		= Door(door_id, door_pickup);
				        Pickup(pickupid, pickup_type) 		= 0;
						Pickup(pickupid, pickup_pos)[ 0 ] 	= Door(door_id, door_out_pos)[ 0 ];
						Pickup(pickupid, pickup_pos)[ 1 ] 	= Door(door_id, door_out_pos)[ 1 ];
						Pickup(pickupid, pickup_pos)[ 2 ] 	= Door(door_id, door_out_pos)[ 2 ];
				        Pickup(pickupid, pickup_vw) 		= Door(door_id, door_out_vw);
				        Pickup(pickupid, pickup_owner)[ 0 ]	= pickup_type_door;
				        Pickup(pickupid, pickup_owner)[ 1 ] = door_id;
				        Pickup(pickupid, pickup_sampID)     = pickupid;
				        Door(door_id, door_pickupID) 		= pickupid;
		            }
		            format(gz, sizeof gz,
		                "UPDATE `surv_doors` SET `pickup` = '%d' WHERE `uid` = '%d'",
		                Door(door_id, door_pickup),
		                Door(door_id, door_uid)
					);
					mysql_query(gz);
					ShowCMD(playerid, "Pickup ustawiony pomyślnie!");
		        }
		        case create_edit_owner:
		        {
		            Create(playerid, create_value)[ 1 ] = strval(inputtext);
		            Create(playerid, create_type) = create_edit_owner2;
		      		switch(Create(playerid, create_value)[ 1 ])
					{
					    case door_type_group:
					    {
							new temp[ 2058 ], string[ 64 ];
							mysql_query("SELECT `uid`, `name` FROM `surv_groups`");
							mysql_store_result();
							while(mysql_fetch_row(string))
							{
							    new uid,
									name[ MAX_GROUP_NAME ];
							    sscanf(string, "p<|>ds["#MAX_GROUP_NAME"]",
									uid,
									name
								);
								format(temp, sizeof temp, "%s%d\t%s\n", temp, uid, name);
							}
							mysql_free_result();
					        Dialog::Output(playerid, 146, DIALOG_STYLE_LIST, IN_HEAD, temp, "Zmień", "Wróć");
					    }
					    case door_type_house:
					    {
					        Dialog::Output(playerid, 146, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj ID gracza, który ma zostać właścicielem drzwi.", "Dalej", "Zamknij");
					    }
					    default: Admin_OnDialogResponse(playerid, 146, 2, 0, "0");
					}
					return 1;
		        }
		        case create_edit_owner2:
		        {
		            Door(door_id, door_owner)[ 0 ] = Create(playerid, create_value)[ 1 ];
		            if(Door(door_id, door_owner)[ 0 ] == door_type_house)
		            {
		                new victimid;
		                sscanf(inputtext, "u", victimid);
		                if(!IsPlayerConnected(victimid))
		                {
		                    NoPlayer(playerid);
		                    End_Create(playerid);
		                    return 1;
		                }
		                Door(door_id, door_owner)[ 1 ] = Player(victimid, player_uid);
					}
					else Door(door_id, door_owner)[ 1 ] = strval(inputtext);
					
					format(gz, sizeof gz,
		                "UPDATE `surv_doors` SET `ownerType` = '%d', `owner` = '%d' WHERE `uid` = '%d'",
		                Door(door_id, door_owner)[ 0 ],
		                Door(door_id, door_owner)[ 1 ],
		                Door(door_id, door_uid)
					);
					mysql_query(gz);
					ShowCMD(playerid, "Właściciel ustawiony pomyślnie!");
				}
				case create_edit_interior:
				{
                    Create(playerid, create_type) = create_edit_interior2;
                    
                    new tmp[ 1024 ], string[ 70 ];
					format(string, sizeof string,
					    "SELECT `uid`, `name` FROM `surv_int` WHERE `cat` = '%d'",
					    strval(inputtext)
					);
					mysql_query(string);
				    mysql_store_result();
				    while(mysql_fetch_row(string))
				    {
				        new uid, name[ 32 ];
				        sscanf(string, "p<|>ds[32]", uid, name);
				        format(tmp, sizeof tmp, "%s%d\t%s\n", tmp, uid, name);
				    }
				    mysql_free_result();
                    
                    Dialog::Output(playerid, 146, DIALOG_STYLE_LIST, IN_HEAD, tmp, "Dalej", "Zamknij");
                    return 1;
				}
				case create_edit_interior2:
				{
				    new interior_id = strval(inputtext),
						string[ 256 ],
						Float:in_pos[ 4 ],
						in_int;
					format(string, sizeof string,
					    "SELECT `x`, `y`, `z`, `a`, `int` FROM `surv_int` WHERE `uid` = '%d'",
						interior_id
					);
					mysql_query(string);
					mysql_store_result();
					mysql_fetch_row(string);
					sscanf(string, "p<|>a<f>[4]d", in_pos, in_int);
					mysql_free_result();
					
					Door(door_id, door_in_pos)[ 0 ] = in_pos[ 0 ];
		            Door(door_id, door_in_pos)[ 1 ] = in_pos[ 1 ];
		            Door(door_id, door_in_pos)[ 2 ] = in_pos[ 2 ];
		            Door(door_id, door_in_pos)[ 3 ] = in_pos[ 3 ];
					Door(door_id, door_in_int) = in_int;

					format(string, sizeof string,
					    "UPDATE `surv_doors` SET `in_pos_x` = '%f', `in_pos_y` = '%f', `in_pos_z` = '%f', `in_pos_a` = '%f', `in_pos_int` = '%d' WHERE `uid` = '%d'",
			            Door(door_id, door_in_pos)[ 0 ],
			            Door(door_id, door_in_pos)[ 1 ],
			            Door(door_id, door_in_pos)[ 2 ],
			            Door(door_id, door_in_pos)[ 3 ],
						Door(door_id, door_in_int),
						Door(door_id, door_uid)
					);
					mysql_query(string);
					ShowCMD(playerid, "Interior ustawiony pomyślnie!");
				}
				case create_edit_delete:
				{
				    DeleteDoor(door_id);
				    ShowCMD(playerid, "Drzwi skasowane pomyślnie!");
				}
		    }
		    End_Create(playerid);
		}
		case 147:
		{
		    if(!response) return End_Create(playerid);
		    Create(playerid, create_value)[ 0 ] = strval(inputtext);
		    
		    new tmp[ 256 ];
            for(new id; id != sizeof JobName; id++)
                format(tmp, sizeof tmp, "%s%d\t%s\n", tmp, id, JobName[ id ]);

		    Dialog::Output(playerid, 148, DIALOG_STYLE_LIST, IN_HEAD, tmp, "Dalej", "Zamknij");
		}
		case 148:
		{
		    if(!response) return End_Create(playerid);
			new pick_model = Create(playerid, create_value)[ 0 ],
			    pick_type = strval(inputtext),
				string[ 64 ];

			GetPlayerPos(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]);
			Player(playerid, player_vw) = GetPlayerVirtualWorld(playerid);

			new pickid = MakePickup(pick_model, pick_type, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ], Player(playerid, player_vw));
			format(string, sizeof string,
				"Pickup stworzony!\nUID:\t%d\nTyp:\t%d (%s)\nModel:\t%d",
				Pickup(pickid, pickup_uid),
				pick_type, JobName[ pick_type ],
				pick_model
			);
			ShowList(playerid, string);
		}
		case 152:
		{
		    if(!response) return End_Create(playerid);
	        if(DIN(inputtext, "Zmień właściciela"))
	        {
				Dialog::Output(playerid, 153, DIALOG_STYLE_LIST, IN_HEAD, "0\tBrak\n1\tGrupa\n2\tGracz\n3\tDrzwi", "Zmień", "Wróć");
                Create(playerid, create_type) = create_edit_owner;
	        }
	        else if(DIN(inputtext, "Zmień range bramy"))
	        {
	            Dialog::Output(playerid, 153, DIALOG_STYLE_INPUT, IN_HEAD, "Podaj range bramy:", "Zmień", "Wróć");
                Create(playerid, create_type) = create_edit_range;
	        }
		}
		case 153:
		{
		    if(!response) return End_Create(playerid);
		    new object = Player(playerid, player_selected_object);
		    switch(Create(playerid, create_type))
		    {
		        case create_edit_range:
		        {
		            new Float:range = floatstr(inputtext);
		            new tmp[ 256 ];
		            
		            #if STREAMER
			            format(tmp, sizeof tmp, "UPDATE `surv_objects` SET `gateRange` = '%f' WHERE `uid` = '%d'",
						    range,
						    Streamer_GetIntData(STREAMER_TYPE_OBJECT, object, E_STREAMER_EXTRA_ID)
						);
						mysql_query(tmp);
						
						new c;
						for(; c < MAX_OBJECTS; c++)
						    if(Object(c, obj_objID) == object)
						        break;
						if(c != MAX_OBJECTS)
						    Object(c, obj_gaterange) = range;
		            #else
			            format(tmp, sizeof tmp, "UPDATE `surv_objects` SET `gateRange` = '%f' WHERE `uid` = '%d'",
						    range,
						    Object(playerid, object, obj_uid)
						);
						mysql_query(tmp);
			            foreach(Player, i)
						{
							if(!Player(i, player_spawned) || !Player(i, player_logged)) continue;
						    if(Player(playerid, player_vw) != Player(i, player_vw)) continue;
						    new objectid = 1;
							for(; objectid != MAX_OBJECTS; objectid++)
							{
							    if(Object(i, objectid, obj_objID) == INVALID_OBJECT_ID)
							        continue;
							    if(!IsValidPlayerObject(i, Object(i, objectid, obj_objID)))
							        continue;
							    if(!Object(i, objectid, obj_uid))
									continue;
								if(Object(i, objectid, obj_uid) == Object(playerid, object, obj_uid))
								    break;
							}
							if(objectid == MAX_OBJECTS) continue;
						    Object(i, objectid, obj_gaterange) = range;
						}
					#endif
					ShowCMD(playerid, "Range bramy zmieniony!");
		        }
		        case create_edit_owner:
		        {
		            Create(playerid, create_value)[ 2 ] = strval(inputtext);
		            Create(playerid, create_type) = create_edit_owner2;
		            switch(Create(playerid, create_value)[ 2 ])
		            {
		                case object_owner_group:
		                {
							new temp[ 2058 ], string[ 35 ];
							mysql_query("SELECT `uid`, `name` FROM `surv_groups`");
							mysql_store_result();
							while(mysql_fetch_row(string))
							{
							    new uid,
									name[ MAX_GROUP_NAME ];
							    sscanf(string, "p<|>ds["#MAX_GROUP_NAME"]",
									uid,
									name
								);
								format(temp, sizeof temp, "%s%d\t%s\n", temp, uid, name);
							}
							mysql_free_result();
					        Dialog::Output(playerid, 153, DIALOG_STYLE_LIST, IN_HEAD, temp, "Zmień", "Wróć");
						}
						case object_owner_player:
						{
						    Dialog::Output(playerid, 153, DIALOG_STYLE_INPUT, IN_HEAD, "Podaj ID gracza", "Zmień", "Wróć");
						}
						default: Admin_OnDialogResponse(playerid, 153, 2, 0, "0");
		            }
		            return 1;
		        }
		        case create_edit_owner2:
		        {
		            new type = Create(playerid, create_value)[ 2 ],
		                id = strval(inputtext),
						doorid = GetPlayerDoor(playerid),
						tmp[ 256 ];
		                
					if(type == object_owner_player)
					    id = Player(id, player_uid);
					else if(type == object_owner_doors)
					{
					    if(!doorid)
					    {
					        End_Create(playerid);
					        ShowInfo(playerid, red"Nie stoisz przy żadnych drzwiach");
					        return 1;
					    }
						id = Door(doorid, door_uid);
					}
					#if STREAMER
						format(tmp, sizeof tmp, "UPDATE `surv_objects` SET `ownerType` = '%d', `owner` = '%d' WHERE `uid` = '%d'",
						    type,
						    id,
							Streamer_GetIntData(STREAMER_TYPE_OBJECT, object, E_STREAMER_EXTRA_ID)
						);
						mysql_query(tmp);

						new c;
						for(; c < MAX_OBJECTS; c++)
						    if(Object(c, obj_objID) == object)
						        break;
						if(c == MAX_OBJECTS)
						{
						    for(c = 0; c < MAX_OBJECTS; c++)
						    	if(Object(c, obj_objID) == INVALID_OBJECT_ID)
						    	    break;
                            if(c == MAX_OBJECTS) return 1;
                            
							new Float:pos[ 3 ],
								Float:rpos[ 3 ];
							StopDynamicObject(object);
						    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_X, pos[ 0 ]);
						    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_Y, pos[ 1 ]);
						    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_Z, pos[ 2 ]);
						    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_X, rpos[ 0 ]);
						    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_Y, rpos[ 1 ]);
						    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_Z, rpos[ 2 ]);
						    
							Object(c, obj_objID) = object;
							Object(c, obj_position)[ 0 ] = pos[ 0 ];
							Object(c, obj_position)[ 1 ] = pos[ 1 ];
							Object(c, obj_position)[ 2 ] = pos[ 2 ];
							Object(c, obj_positionrot)[ 0 ] = rpos[ 0 ];
							Object(c, obj_positionrot)[ 1 ] = rpos[ 1 ];
							Object(c, obj_positionrot)[ 2 ] = rpos[ 2 ];
							Object(c, obj_owner)[ 0 ] = type;
							Object(c, obj_owner)[ 1 ] = id;
						}
		                else if(c != MAX_OBJECTS)
		                {
							Object(c, obj_owner)[ 0 ] = type;
							Object(c, obj_owner)[ 1 ] = id;
						}
					#else
						format(tmp, sizeof tmp, "UPDATE `surv_objects` SET `ownerType` = '%d', `owner` = '%d' WHERE `uid` = '%d'",
						    type,
						    id,
						    Object(playerid, object, obj_uid)
						);
						mysql_query(tmp);
						foreach(Player, i)
						{
							if(!Player(i, player_spawned) || !Player(i, player_logged)) continue;
						    if(Player(playerid, player_vw) != Player(i, player_vw)) continue;
						    new objectid = 1;
							for(; objectid != MAX_OBJECTS; objectid++)
							{
							    if(Object(i, objectid, obj_objID) == INVALID_OBJECT_ID)
							        continue;
							    if(!IsValidPlayerObject(i, Object(i, objectid, obj_objID)))
							        continue;
							    if(!Object(i, objectid, obj_uid))
									continue;
								if(Object(i, objectid, obj_uid) == Object(playerid, object, obj_uid))
								    break;
							}
							if(objectid == MAX_OBJECTS) continue;
						    Object(i, objectid, obj_owner)[ 0 ] = type;
						    Object(i, objectid, obj_owner)[ 1 ] = id;
						}
					#endif
					ShowCMD(playerid, "Właściciel obiektu zmieniony!");
		        }
		    }
		    End_Create(playerid);
		}
	}
	return 1;
}

FuncPub::End_Create(playerid)
{
    for(new eCreate:i; i < eCreate; i++)
    	Create(playerid, i) = 0;
	return 1;
}

FuncPub::UpdateInfos()
{
	new buffer[ 256 ];
	new AFK, admins, adminsduty;
	foreach(Player, i)
	{
	    if(Player(i, player_afktime)[ 0 ] > 5) AFK++;
	    if(Player(i, player_adminlvl))
	    {
			if(Player(i, player_aduty)) adminsduty++;
	        admins++;
	    }

	}

	format(buffer, sizeof buffer,
		"Zespawnowanych pojazdow: %d           Graczy AFK: %d           Graczy online: %d/%d           Adminow online: %d/%d",
		Iter_Count(Server_Vehicles),
		AFK,
		Iter_Count(Player),
		GetMaxPlayers(),
		adminsduty,
		admins
	);
	TextDrawSetString(Setting(setting_admin_head), buffer);

	format(buffer, sizeof buffer,
		"Nowe raporty: ~g~%d",
		Setting(setting_raports)
	);
	TextDrawSetString(Setting(setting_admin_report), buffer);
	return 1;
}

FuncPub::ShowAdminPanel(playerid)
{
	TextDrawShowForPlayer(playerid, Setting(setting_admin_head));
	TextDrawShowForPlayer(playerid, Setting(setting_admin_box)[ 0 ]);
	TextDrawShowForPlayer(playerid, Setting(setting_admin_box)[ 1 ]);
	TextDrawShowForPlayer(playerid, Setting(setting_admin_exit));
	TextDrawShowForPlayer(playerid, Setting(setting_admin_report));
	if(!Player(playerid, player_aduty))
	    TextDrawShowForPlayer(playerid, Setting(setting_admin_duty)[ 0 ]);
	else
	    TextDrawShowForPlayer(playerid, Setting(setting_admin_duty)[ 1 ]);

	SelectTextDraw(playerid, 0xFF4040AA);
	SetPVarInt(playerid, "admin-show", 1);
	return 1;
}

FuncPub::HideAdminPanel(playerid)
{
	TextDrawHideForPlayer(playerid, Setting(setting_admin_head));
	TextDrawHideForPlayer(playerid, Setting(setting_admin_box)[ 0 ]);
	TextDrawHideForPlayer(playerid, Setting(setting_admin_box)[ 1 ]);
	TextDrawHideForPlayer(playerid, Setting(setting_admin_exit));
	TextDrawHideForPlayer(playerid, Setting(setting_admin_report));
    TextDrawHideForPlayer(playerid, Setting(setting_admin_duty)[ 0 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_admin_duty)[ 1 ]);

	CancelSelectTextDraw(playerid);
	DeletePVar(playerid, "admin-show");
	return 1;
}

stock IsPlayerGameAdmin(playerid, adminlvl, perm)
{
	if(Player(playerid, player_adminlvl) >= adminlvl)
	{
	    if(Player(playerid, player_adminperm) & perm)
	        return true;
		else
		{
		    Chat::Output(playerid, CLR_RED, "# Permission denied!");
		    return false;
		}
	}
	return false;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == Setting(setting_admin_exit))
	    HideAdminPanel(playerid);
	else if(clickedid == Setting(setting_admin_report))
	    cmd_raporty(playerid, "");
	else if(clickedid == Setting(setting_admin_duty)[ 1 ]) // wyjdz
	{
    	TextDrawHideForPlayer(playerid, Setting(setting_admin_duty)[ 1 ]);
    	TextDrawShowForPlayer(playerid, Setting(setting_admin_duty)[ 0 ]);
    	
	    EnterAdminDuty(playerid);
	}
	else if(clickedid == Setting(setting_admin_duty)[ 0 ]) // wejdz
	{
    	TextDrawHideForPlayer(playerid, Setting(setting_admin_duty)[ 0 ]);
    	TextDrawShowForPlayer(playerid, Setting(setting_admin_duty)[ 1 ]);
    	
    	EnterAdminDuty(playerid);
	}
	Login_OnPlayerClickTextDraw(playerid, clickedid);
	Group_OnPlayerClickTextDraw(playerid, clickedid);
	return 1;
}

FuncPub::EnterAdminDuty(playerid)
{
	new string[ 256 ];
	if(!Player(playerid, player_aduty))
	{
	    Player(playerid, player_aduty) = true;
	    Chat::Output(playerid, GREEN, "Wszedłeś na służbę!");
    	SetPlayerHealth(playerid, Player(playerid, player_hp) = 99999.0);
    	
    	format(string, sizeof string,
    	    "INSERT INTO `all_admin` VALUES (NULL, '%d', UNIX_TIMESTAMP(), '0', '"#type_rp"')",
    	    Player(playerid, player_guid)
		);
		mysql_query(string);
		Player(playerid, player_admin_id) = mysql_insert_id();
    }
    else
    {
        Player(playerid, player_aduty) = false;
    	Chat::Output(playerid, 0, red"Zszedłeś ze służby!");
    	SetPlayerHealth(playerid, Player(playerid, player_hp) = 100.0);
    	
    	format(string, sizeof string,
    	    "UPDATE `all_admin` SET `end` = UNIX_TIMESTAMP() WHERE `uid` = '%d'",
    	    Player(playerid, player_admin_id)
		);
		mysql_query(string);
		Player(playerid, player_admin_id) = 0;
    }
    UpdateInfos();
    UpdatePlayerNick(playerid);
    return 1;
}

FuncPub::AntyCheat(playerid)
{
	if(Player(playerid, player_disabled)) return 1;
	if(IsPlayerNPC(playerid)) return 1;
	
	new string[ 256 ],
		reason[ 126 ],
		Float:HP,
		Float:Armour,
		Float:vehHP,
		Float:pos[ 3 ];
		
	GetPlayerPos(playerid, pos[ 0 ], pos[ 1 ], pos[ 2 ]);
	GetPlayerHealth(playerid, HP);
	GetPlayerArmour(playerid, Armour);

	// --- Anty Money Hack --- //
	if(GetPlayerMoney(playerid) != floatval(Player(playerid, player_cash)))
		SetPlayerMoney(playerid, Player(playerid, player_cash));

	// --- Anty Health Hack --- //
	if(HP > Player(playerid, player_hp))
		SetPlayerHealth(playerid, Player(playerid, player_hp));
		
	// --- Anty Armour Hack --- //
	if(Armour > Player(playerid, player_armour))
	    SetPlayerArmour(playerid, Player(playerid, player_armour));
	    
	// --- Anty Jail Break --- //
	if(Player(playerid, player_aj) > 10)
	{
	    new Float:distance = Distance3D(pos[ 0 ], pos[ 1 ], pos[ 2 ], Setting(setting_aj)[ 0 ], Setting(setting_aj)[ 1 ], Setting(setting_aj)[ 2 ]);
	    if(GetPlayerVirtualWorld(playerid) != playerid || distance > 50.0)
	    {
			Player(playerid, player_position)[ 0 ] = Setting(setting_aj)[ 0 ];
			Player(playerid, player_position)[ 1 ] = Setting(setting_aj)[ 1 ];
			Player(playerid, player_position)[ 2 ] = Setting(setting_aj)[ 2 ];

			SetPlayerPosEx(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]);
			SetPlayerVirtualWorld(playerid, Player(playerid, player_vw) = playerid);
			SetPlayerInterior(playerid, Player(playerid, player_int) = 0);
		}
	}
    // --- Anty UnFreeze --- //
/*	new Float:distance = Distance3D(Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ], pos[ 0 ], pos[ 1 ], pos[ 2 ]);
    if(Player(playerid, player_freezed) && distance > 20.0 && GetPlayerSurfingVehicleID(playerid) == INVALID_VEHICLE_ID)
    {
        format(reason, sizeof reason,
			"UnFreeze, przesuniecie o %.2fj podczas freeze",
			distance
		);
		format(string, sizeof string,
			"~>~ Kick ~<~ ~r~%s ~w~zostal wyrzucony przez ~r~System~w~. ~w~Powod: ~r~%s",
			NickName(playerid),
			reason
		);
		ShowKara(playerid, string);
		Logs(-1, playerid, reason, kara_kick, -1);
		SetTimerEx (!#kickPlayer, 249, false, !"i", playerid);
    }*/
    
	new carid = GetPlayerVehicleID(playerid);
    if(carid > 0)
    {
        // --- Anty Speed Hack --- //
        new Float:vehSpeed = GetVehSpeed(Vehicle(carid, vehicle_vehID));
        if(vehSpeed > 270.0)
        {
	        format(reason, sizeof reason,
				"Speed Hack, predkosc: %.2fkm/h",
				vehSpeed
			);
			format(string, sizeof string,
				"~>~ Kick ~<~ ~r~%s ~w~zostal wyrzucony przez ~r~System~w~. ~w~Powod: ~r~%s",
				NickName(playerid),
				reason
			);
			ShowKara(playerid, string);
			Logs(-1, playerid, reason, kara_kick, -1);
			SetTimerEx (!#kickPlayer, 249, false, !"i", playerid);
        }
        
        // --- Anty Vehicle God --- //
        GetVehicleHealth(carid, vehHP);
        new Float:amount = (Vehicle(carid, vehicle_hp) - vehHP);
        if(amount < -10)
        {
            if(Vehicle(carid, vehicle_ac))
            {
				SetVehicleHealth(carid, Vehicle(carid, vehicle_hp) = 1000.0);
                Vehicle(carid, vehicle_ac) = false;
            }
            else
            {
		        format(reason, sizeof reason,
					"VehGod, naprawa pojazdu o %.2fj HP.",
					amount * -1
				);
				format(string, sizeof string,
					"~>~ Kick ~<~ ~r~%s ~w~zostal wyrzucony przez ~r~System~w~. ~w~Powod: ~r~%s",
					NickName(playerid),
					reason
				);
				ShowKara(playerid, string);
				Logs(-1, playerid, reason, kara_kick, -1);
				SetTimerEx (!#kickPlayer, 249, false, !"i", playerid);
				printf("[AC] Vehicle God, vhp: %f / ghp: %f", Vehicle(carid, vehicle_hp), vehHP);
				Vehicle(carid, vehicle_hp) = vehHP;
				SetVehicleHealth(carid, Vehicle(carid, vehicle_hp));
			}
        }
/*
        new weapons[ 13 ][ 2 ];
		for (new i = 0; i < 13; i++)
		{
		    GetPlayerWeaponData(playerid, i, weapons[ i ][ 0 ], weapons[ i ][ 1 ]);
		    if(!weapons[ i ][ 0 ] || !weapons[ i ][ 1 ]) continue;
		    if(Weapon(playerid, 0, weapon_uid) && Weapon(playerid, 0, weapon_model) == weapons[ i ][ 0 ]) continue;
		    if(Weapon(playerid, 1, weapon_uid) && Weapon(playerid, 1, weapon_model) == weapons[ i ][ 0 ]) continue;
			new weaponname[ 32 ];
			GetWeaponName(weapons[ i ][ 0 ], weaponname, sizeof weaponname);
		    format(reason, sizeof reason,
				"Weapon Hack, wyciagnal bron w pojezdzie %s (%d) z %d ammo.",
				weaponname,
				weapons[ i ][ 0 ],
				weapons[ i ][ 1 ]
			);
			format(string, sizeof string,
				"~>~ Kick ~<~ ~r~%s ~w~zostal wyrzucony przez ~r~System~w~. ~w~Powod: ~r~%s",
				NickName(playerid),
				reason
			);
			ShowKara(playerid, string);
			Logs(-1, playerid, reason, kara_kick, -1);
			SetTimerEx (!#kickPlayer, 249, false, !"i", playerid);
			printf("[AC] %d -> %d:%d", weapons[i][0], Weapon(playerid, 0, weapon_model), Weapon(playerid, 1, weapon_model));
		}*/
    }
    else
    {
		// --- No run --- //
		if(GetPlayerSpeed(playerid) >= 5 && Player(playerid, player_block) & block_norun)
		{
			TogglePlayerControllable(playerid, false);
			SetTimerEx("UnFreezePlayer", 500, 0, "d", playerid);
		}
    }
    // --- Anty JetPack Hack --- //
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK && !Player(playerid, player_adminlvl))
	{
        format(reason, sizeof reason,
			"Jetpack"
		);
		format(string, sizeof string,
			"~>~ Kick ~<~ ~r~%s ~w~zostal wyrzucony przez ~r~System~w~. ~w~Powod: ~r~%s",
			NickName(playerid),
			reason
		);
		ShowKara(playerid, string);
		Logs(-1, playerid, reason, kara_kick, -1);
		SetTimerEx (!#kickPlayer, 249, false, !"i", playerid);
 	}

 	// --- Anty Weapon Hack --- //
	new weapon = GetPlayerWeapon(playerid);
 	if(Weapon(playerid, Player(playerid, player_used_weapon), weapon_model) != weapon && weapon && !Weapon(playerid, Player(playerid, player_used_weapon), weapon_uid))
 	{
 	    new ammo = GetWeaponAmmo(playerid, weapon);
 	    if(ammo)
 	    {
			new weaponname[ 32 ];
			GetWeaponName(weapon, weaponname, sizeof weaponname);
	        format(reason, sizeof reason,
				"Weapon Hack, wyciagnal bron %s (%d) z %d ammo.",
				weaponname,
				weapon,
				ammo
			);
			format(string, sizeof string,
				"~>~ Kick ~<~ ~r~%s ~w~zostal wyrzucony przez ~r~System~w~. ~w~Powod: ~r~%s",
				NickName(playerid),
				reason
			);
			ShowKara(playerid, string);
			Logs(-1, playerid, reason, kara_kick, -1);
			SetTimerEx (!#kickPlayer, 249, false, !"i", playerid);
		}
 	}
 	
/*    new ammo = GetPlayerAmmo(playerid);
    if(Player(playerid, player_ammo) > ammo && HavePlayerWeapon(playerid) && weapon)
    {
        //Chat::Output(playerid, SZARY, "Unlimited Ammo! (Kick)");
    }*/
	return 1;
}

FuncPub::AntyCheatVehicle()
{
    foreach(Server_Vehicles, carid)
    {
    	if(Vehicle(carid, vehicle_ac)) continue;
        new Float:vehHP;
        GetVehicleHealth(carid, vehHP);
        new Float:amount = (Vehicle(carid, vehicle_hp) - vehHP);
        if(amount > 0)
        {
            foreach(Player, i)
            {
                if(GetPlayerVehicleID(i) != carid) continue;
            	OnVehicleLoseHP(i, amount);
			}
			Vehicle(carid, vehicle_hp) = vehHP;
			GetVehicleDamageStatus(Vehicle(carid, vehicle_vehID), Vehicle(carid, vehicle_damage)[ 0 ], Vehicle(carid, vehicle_damage)[ 1 ], Vehicle(carid, vehicle_damage)[ 2 ], Vehicle(carid, vehicle_damage)[ 3 ]);
        }
	}
	return 1;
}

FuncPub::EnableAnty(vehid)
{
    Vehicle(vehid, vehicle_ac) = false;
	return 1;
}

FuncPub::CheckSpamCmd(playerid)
{
    if(Player(playerid, player_cmds) > 10)
    {
        new string[ 256 ],
			reason[ 40 ];
			
        format(reason, sizeof reason,
			"Spam komend, %d w ciagu 3 sekund",
            Player(playerid, player_cmds)
		);
		format(string, sizeof string,
			"~>~ Kick ~<~ ~r~%s ~w~zostal wyrzucony przez ~r~System~w~. ~w~Powod: ~r~%s",
			NickName(playerid),
			reason
		);
		ShowKara(playerid, string);
		Logs(-1, playerid, reason, kara_kick, -1);
		SetTimerEx (!#kickPlayer, 249, false, !"i", playerid);
    }
    Player(playerid, player_cmds) = 0;
    Player(playerid, player_cmd_timer) = 0;
	return 1;
}

FuncPub::CheckSpamChat(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
    if(Player(playerid, player_texts) > 15)
    {
        new string[ 256 ],
			reason[ 40 ];

        format(reason, sizeof reason,
			"Anty flood, %d w ciagu 5 sekund",
            Player(playerid, player_texts)
		);
		format(string, sizeof string,
			"~>~ Kick ~<~ ~r~%s ~w~zostal wyrzucony przez ~r~System~w~. ~w~Powod: ~r~%s",
			NickName(playerid),
			reason
		);
		ShowKara(playerid, string);
		Logs(-1, playerid, reason, kara_kick, -1);
		SetTimerEx (!#kickPlayer, 249, false, !"i", playerid);
    }
	Player(playerid, player_texts) = 0;
	Player(playerid, player_text_timer) = 0;
	return 1;
}

FuncPub::ShowKara(playerid, reason[])
{
	EscapePL(reason);
	reason[ 0 ] = toupper(reason[ 0 ]);
	foreach(Player, i)
	{
	    if(!Player(i, player_adminlvl))
	    {
			if(Player(playerid, player_vw) != Player(i, player_vw))
				continue;
			if(!IsPlayerInRangeOfPoint(i, 30.0, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]))
				continue;
		}
		
		PlayerTextDrawShow(i, Player(i, player_kara)[ 0 ]);
		PlayerTextDrawSetString(i, Player(i, player_kara)[ 1 ], reason);
		PlayerTextDrawShow(i, Player(i, player_kara)[ 1 ]);
		
		KillTimer(Player(i, player_kara_timer));
		Player(i, player_kara_timer) = SetTimerEx("HideKara", 15000, 0, "d", i);
	}
	return 1;
}

FuncPub::HideKara(playerid)
{
	PlayerTextDrawHide(playerid, Player(playerid, player_kara)[ 0 ]);
	PlayerTextDrawHide(playerid, Player(playerid, player_kara)[ 1 ]);
	KillTimer(Player(playerid, player_kara_timer));
	Player(playerid, player_kara_timer) = 0;
	return 1;
}

FuncPub::Logs(playerid, victimid, reason[ ], type, time) // player - nadający | victimid - nadany | time - sekundy
{
	new active;
	switch(type)
	{
	    case kara_kick, kara_jail, kara_warn: active = 2;
	    default: active = 1;
	}
	new string[ 256 ];
	mysql_real_escape_string(reason, reason);
	reason[ 0 ] = toupper(reason[ 0 ]);
    EscapePL(reason);
    
	format(string, sizeof string,
		"INSERT INTO `all_logs` VALUES (NULL, '%d', '%d', '%d', '%s', UNIX_TIMESTAMP(), '%d', '%d', '"#type_rp"')",
		playerid == -1 ? (-1) : (Player(playerid, player_uid)),
		Player(victimid, player_uid),
		type,
		reason,
		time == -1 ? (-1) : (gettime() + time),
		active
	);
	mysql_query(string);
	return 1;
}

Cmd::Input->admin(playerid, params[])
{
    if(!Player(playerid, player_adminlvl)) return 1;
	if(!GetPVarInt(playerid, "admin-show"))
    	ShowAdminPanel(playerid);
	else
		HideAdminPanel(playerid);
	return 1;
}

Cmd::Input->report(playerid, params[])
{
	new victimid,
	    message[ 128 ];
	if(sscanf(params, "us[128]", victimid, message))
	    return ShowCMD(playerid, "Tip: /report [ID/Nick] [Treść]");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);
	new buffer[ 256 ];
	mysql_real_escape_string(message, message);
	format(buffer, sizeof buffer, "INSERT INTO `surv_messages` VALUES (NULL, '"#message_type_raport"', '%d', '%d', UNIX_TIMESTAMP(), '%s', '0')", Player(playerid, player_uid), Player(victimid, player_uid), message);
	mysql_query(buffer);
	
    format(buffer, sizeof buffer, green"Report wysyłany pomyślnie.\nTreść: "white"%s", message);
	ShowInfo(playerid, buffer);
	
	mysql_query("SELECT 1 FROM `surv_messages` WHERE `type` = "#message_type_raport" AND `read` = '0'");
	mysql_store_result();
	Setting(setting_raports) = mysql_num_rows();
	mysql_free_result();
	UpdateInfos();
	
	format(buffer, sizeof buffer, "Raport od %s (%d) na %s (%d). Treść: %s", NickName(playerid), playerid, NickName(victimid), victimid, message);
	foreach(Player, i)
		if(Player(i, player_adminlvl) && Player(i, player_aduty))
			Chat::Output(i, CLR_ZOLTY, buffer);
	return 1;
}
Cmd::Input->raport(playerid, params[]) return cmd_report(playerid, params);

Cmd::Input->a(playerid, params[])
{
	new string[ 512 ];
	foreach(Player, i)
	{
	    if(!Player(i, player_aduty)) continue;
	    if(!Player(i, player_adminlvl)) continue;
	    
	    if(isnull(AdminLvl[ Player(i, player_adminlvl) ][ admin_tag ]))
			format(string, sizeof string, "%s%d\t{%06x}%s%s\t"white"%s\n",
				string,
				i,
				AdminLvl[ Player(i, player_adminlvl) ][ admin_color ] >>> 8,
				AdminLvl[ Player(i, player_adminlvl) ][ admin_name ],
				Player(i, player_adminlvl) == 5 ? ("") : ("\t"),
				NickName(i)
			);
	    else
			format(string, sizeof string, "%s%d\t{%06x}%s\t\t"white"%s (%s)\n",
				string,
				i,
				AdminLvl[ Player(i, player_adminlvl) ][ admin_color ] >>> 8,
				AdminLvl[ Player(i, player_adminlvl) ][ admin_name ],
				NickName(i),
				AdminLvl[ Player(i, player_adminlvl) ][ admin_tag ]
			);
	}
	if(isnull(string)) ShowInfo(playerid, red"Nie ma żadnego administratora online.");
	else
	{
	    format(string, sizeof string, grey"ID:\tRanga:\t\t\tNick:\n%s", string);
		ShowList(playerid, string);
	}
	return 1;
}

Cmd::Input->aduty(playerid, params[])
{
	if(!Player(playerid, player_adminlvl)) return 1;
    EnterAdminDuty(playerid);
    return 1;
}

Cmd::Input->raporty(playerid, params[])
{
	if(!Player(playerid, player_adminlvl)) return 1;

	new buffer[ 256 ],
		string[ 16 ];
	mysql_query("SELECT DISTINCT surv_messages.uid, surv_messages.read, surv_messages.time, all_online.ID FROM `surv_messages` JOIN `all_online` ON surv_messages.victim = all_online.player WHERE surv_messages.type = "#message_type_raport" AND surv_messages.read != 2 ORDER BY surv_messages.time DESC");
	mysql_store_result();
	while(mysql_fetch_row_format(string))
	{
	    static uid,
			victimid,
	   		read,
			date,
			dateStr[ 32 ];

		sscanf(string, "p<|>dddd",
			uid,
			read,
			date,
			victimid
		);
		if(!IsPlayerConnected(victimid)) continue;
		
		ReturnTimeAgo(date, dateStr);
		
		if(!read)
			format(buffer, sizeof buffer, "%s"gui_active"%d\t%s\t%s\n", buffer, uid, dateStr, NickSamp(victimid));
		else if(read == 1)
			format(buffer, sizeof buffer, "%s%d\t%s\t%s\n", buffer, uid, dateStr, NickSamp(victimid));
	}
	mysql_free_result();
	if(!isnull(buffer))
		Dialog::Output(playerid, 35, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
	else
	    ShowInfo(playerid, red"Brak raportów! :)");
	return 1;
}

Cmd::Input->set(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_set)) return 1;
	new victimid, string[ 64 ];
	if(sscanf(params, "us[64]", victimid, string))
	    return ShowCMD(playerid, "Tip: /set [ID/Nick] [Parametr]");
	if(!IsPlayerConnected(victimid))
	    return NoPlayer(playerid);
	new buffer[ 126 ];
	format(buffer, sizeof buffer, "%d set %s", victimid, string);
	cmd_player(playerid, buffer);
	return 1;
}

Cmd::Input->setvw(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_set)) return 1;
	new victimid, value;
	if(sscanf(params, "ud", victimid, value))
	    return ShowCMD(playerid, "Tip: /setvw [ID/Nick] [ID]");
	if(!IsPlayerConnected(victimid))
	    return NoPlayer(playerid);
	new buffer[ 126 ];
	format(buffer, sizeof buffer, "%d set vw %d", victimid, value);
	cmd_player(playerid, buffer);
	return 1;
}

Cmd::Input->setskin(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_set)) return 1;
	new victimid, value;
	if(sscanf(params, "ud", victimid, value))
	    return ShowCMD(playerid, "Tip: /setskin [ID/Nick] [ID]");
	if(!IsPlayerConnected(victimid))
	    return NoPlayer(playerid);
	new buffer[ 126 ];
	format(buffer, sizeof buffer, "%d set skin %d", victimid, value);
	cmd_player(playerid, buffer);
	return 1;
}

Cmd::Input->player(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_set) && !IsPlayerAdmin(playerid)) return 1;
	new sub[ 30 ],
   		rest[ 80 ],
	   	victimid;
   	if(sscanf(params, "us[30]S()[80]", victimid, sub, rest))
	   	return ShowCMD(playerid, "Tip: /player [ID/Nick] [set/give]");
	if(!IsPlayerConnected(victimid))
	    return NoPlayer(playerid);
    if(!strcmp(sub, "set", true))
	{
		new sub2[ 20 ],
   			rest2[ 32 ],
  			string[ 126 ];
   		if(sscanf(rest, "s[20]S()[32]", sub2, rest2))
		   	return ShowCMD(playerid, "Tip: /player [ID/Nick] set [skin/cash/admin/hp/vw/int/nick/permnick/perm]");
    	if(!strcmp(sub2, "skin", true))
    	{
    	    if(isnull(rest2))
    	        return ShowCMD(playerid, "Tip: /player [ID/Nick] set skin [ID skina]");

    	    new skinid = strval(rest2);
    	    if(IsValidSkin(skinid))
    	        return ShowCMD(playerid, "Niewłaściwe ID skina.");
    	        
    	    SetPlayerSkin(victimid, Player(victimid, player_skin) = skinid);

    	    format(string, sizeof string,
				"UPDATE `surv_players` SET `skin` = '%d' WHERE `uid` = '%d'",
				Player(victimid, player_skin),
				Player(victimid, player_uid)
			);
			mysql_query(string);
			format(string, sizeof string,
				"Ustawiłeś graczowi %s skin: %d.",
				NickName(victimid),
				Player(victimid, player_skin)
			);
 			Chat::Output(playerid, CLR_GREEN, string);
    	}
    	else if(!strcmp(sub2, "cash", true) || !strcmp(sub2, "money", true) || !strcmp(sub2, "kasa", true))
    	{
			if(!IsPlayerGameAdmin(playerid, 4, admin_perm_server) && !IsPlayerAdmin(playerid)) return 1;
    	    if(isnull(rest2))
    	        return ShowCMD(playerid, "Tip: /player [ID/Nick] set cash [Kwota]");

    	    new Float:cash = floatstr(rest2);
    	    SetPlayerMoney(victimid, Player(victimid, player_cash) = cash);
			format(string, sizeof string,
				"Ustawiłeś graczowi %s gotówke: $%.2f.",
				NickName(victimid),
				Player(victimid, player_cash)
			);
 			Chat::Output(playerid, CLR_GREEN, string);
    	}
    	else if(!strcmp(sub2, "perm", true) || !strcmp(sub2, "perm", true))
    	{
			if(!IsPlayerGameAdmin(playerid, 4, admin_perm_server) && !IsPlayerAdmin(playerid)) return 1;
    	    if(isnull(rest2))
    	        return ShowCMD(playerid, "Tip: /player [ID/Nick] set adminlvl [Level]");

    	    new adminperm = strval(rest2);
    	    
    	    Player(victimid, player_adminperm) = adminperm;
    	    Chat::Output(playerid, CLR_GREEN, "Permy zmienione!");
		}
    	else if(!strcmp(sub2, "admin", true) || !strcmp(sub2, "adminlvl", true))
    	{
			if(!IsPlayerGameAdmin(playerid, 4, admin_perm_server) && !IsPlayerAdmin(playerid)) return 1;
    	    if(isnull(rest2))
    	        return ShowCMD(playerid, "Tip: /player [ID/Nick] set adminlvl [Level]");

    	    new adminlvl = strval(rest2);
    	    if(adminlvl > sizeof AdminLvl-1)
    	        adminlvl = sizeof AdminLvl-1;
    	        
    	    Player(victimid, player_adminlvl) = adminlvl;

    	    format(string, sizeof string,
				"UPDATE `"IN_PREF"members` SET `RP` = '%d' WHERE `member_id` = '%d'",
				Player(victimid, player_adminlvl),
				Player(victimid, player_guid)
			);
			mysql_query(string);
			if(!Player(victimid, player_adminlvl))
			{
				format(string, sizeof string,
					"Zabrałeś graczowi %s rangę admina",
					NickName(victimid)
				);
				Player(playerid, player_aduty) = false;
			}
			else
			{
			    if(isnull(AdminLvl[ Player(victimid, player_adminlvl) ][ admin_tag ]))
					format(string, sizeof string,
						"Ustawiłeś graczowi %s adminlvl: {%06x}%s.",
						NickName(victimid),
						AdminLvl[ Player(victimid, player_adminlvl) ][ admin_color ] >>> 8,
						AdminLvl[ Player(victimid, player_adminlvl) ][ admin_name ]
					);
			    else
					format(string, sizeof string,
						"Ustawiłeś graczowi %s adminlvl: {%06x}%s (%s).",
						NickName(victimid),
						AdminLvl[ Player(victimid, player_adminlvl) ][ admin_color ] >>> 8,
						AdminLvl[ Player(victimid, player_adminlvl) ][ admin_name ],
						AdminLvl[ Player(victimid, player_adminlvl) ][ admin_tag ]
					);
			}
 			Chat::Output(playerid, CLR_GREEN, string);
 			
 			UpdatePlayerNick(victimid);
    	}
    	else if(!strcmp(sub2, "hp", true) || !strcmp(sub2, "health", true))
    	{
    	    if(isnull(rest2))
    	        return ShowCMD(playerid, "Tip: /player [ID/Nick] set hp [Ilość życia]");

    	    new Float:health = floatstr(rest2);
    	    
    	    if(health > 100) health = 100.0;
    	    else if(health < 0) health = 0.0;

    	    SetPlayerHealth(victimid, Player(victimid, player_hp) = health);

			format(string, sizeof string,
				"Ustawiłeś graczowi %s health: %.2f.",
				NickName(victimid),
				Player(victimid, player_hp)
			);
 			Chat::Output(playerid, CLR_GREEN, string);
    	}
    	else if(!strcmp(sub2, "nick", true) || !strcmp(sub2, "name", true))
    	{
    	    if(isnull(rest2))
    	        return ShowCMD(playerid, "Tip: /player [ID/Nick] set nick [Nowa nazwa]");
//    		mysql_real_escape_string(rest2, rest2);
    	    
/*    	    format(string, sizeof string,
				"UPDATE `surv_players` SET `name` = '%s' WHERE `uid` = '%d'",
				rest2,
				Player(victimid, player_uid)
			);
			mysql_query(string);*/
			
			format(string, sizeof string,
				"Ustawiłeś graczowi %s tymczasową nazwę: %s.",
				NickName(victimid),
				rest2
			);
 			Chat::Output(playerid, CLR_GREEN, string);
     	    format(Player(victimid, player_name), MAX_PLAYER_NAME, rest2);
    	    UpdatePlayerNick(victimid);
   		}
    	else if(!strcmp(sub2, "permnick", true) || !strcmp(sub2, "permname", true))
    	{
    	    if(isnull(rest2))
    	        return ShowCMD(playerid, "Tip: /player [ID/Nick] set permnick [Nowa nazwa]");
    		mysql_real_escape_string(rest2, rest2);
    	    UpdatePlayerNick(victimid);

   	    	format(string, sizeof string,
				"UPDATE `surv_players` SET `name` = '%s' WHERE `uid` = '%d'",
				rest2,
				Player(victimid, player_uid)
			);
			mysql_query(string);

			format(string, sizeof string,
				"Ustawiłeś graczowi %s nazwę: %s.",
				NickName(victimid),
				rest2
			);
 			Chat::Output(playerid, CLR_GREEN, string);
    		format(Player(victimid, player_name), MAX_PLAYER_NAME, rest2);
    	    SetPlayerName(victimid, Player(playerid, player_name));
    	}
    	else if(!strcmp(sub2, "vw", true) || !strcmp(sub2, "virtualworld", true))
    	{
    	    new vw = strval(rest2);
    	    
    	    SetPlayerVirtualWorld(victimid, Player(victimid, player_vw) = vw);
    		#if !STREAMER
				LoadPlayerObjects(victimid, Player(victimid, player_vw));
			#endif
			LoadPlayerText(victimid, Player(victimid, player_vw));

			format(string, sizeof string,
				"Ustawiłeś graczowi %s VW: %d.",
				NickName(victimid),
				Player(victimid, player_vw)
			);
 			Chat::Output(playerid, CLR_GREEN, string);
    	}
    	else if(!strcmp(sub2, "int", true) || !strcmp(sub2, "interior", true))
    	{
    	    new interior = strval(rest2);

    	    SetPlayerInterior(victimid, Player(victimid, player_int) = interior);
    	    
			format(string, sizeof string,
				"Ustawiłeś graczowi %s interior: %d.",
				NickName(victimid),
				Player(victimid, player_int)
			);
 			Chat::Output(playerid, CLR_GREEN, string);
    	}
    	else return ShowCMD(playerid, "Tip: /player [ID/Nick] set [skin/cash/admin/hp/vw/int]");
	}
	else if(!strcmp(sub, "give", true))
	{
		new sub2[ 20 ],
   			rest2[ 32 ],
  			string[ 126 ];
   		if(sscanf(rest, "s[20]S()[32]", sub2, rest2))
		   	return ShowCMD(playerid, "Tip: /player [ID/Nick] give [cash]");
    	if(!strcmp(sub2, "cash", true))
    	{
			if(!IsPlayerGameAdmin(playerid, 4, admin_perm_server) && !IsPlayerAdmin(playerid)) return 1;
    	    if(isnull(rest2))
    	        return ShowCMD(playerid, "Tip: /player [ID/Nick] give cash [Kwota]");

    	    new Float:cash = floatstr(rest2);
    	    SetPlayerMoney(victimid, Player(victimid, player_cash) += cash);
    	    
			format(string, sizeof string,
				"Dałeś graczowi %s $%.2f.",
				NickName(victimid),
				cash
			);
 			Chat::Output(playerid, CLR_GREEN, string);
    	}
    	else return ShowCMD(playerid, "Tip: /player [ID/Nick] give [cash]");
	}
	return 1;
}

Cmd::Input->slap(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_slap)) return 1;
	new victimid;
	if(sscanf(params, "u", victimid))
		return ShowCMD(playerid, "Tip: /slap [ID/Nick]");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);

	new Float:pos[ 3 ];
		
/*	format(string, sizeof string, "~>~ Slap ~<~ ~r~%s ~w~dostal slapa od ~r~%s~w~. ~w~%s%s", NickName(victimid), NickName(playerid), reason[ 0 ] ? ("Powod: ~r~") : (""), reason);
	ShowKara(victimid, string);*/
	
	if(IsPlayerInAnyVehicle(victimid))
	    RemovePlayerFromVehicle(victimid);
	GetPlayerVelocity(victimid, pos[ 0 ], pos[ 1 ], pos[ 2 ]);
	SetPlayerVelocity(victimid, pos[ 0 ], pos[ 1 ], pos[ 2 ] + 0.3);

    GameTextForPlayer(victimid, "~n~~n~~r~SLAP", 5000, 5);
//	Logs(playerid, victimid, reason, kara_slap, -1);
	return 1;
}

Cmd::Input->warn(playerid, params[])
{
	if(!Player(playerid, player_adminlvl)) return 1;
	new reason[ 64 ],
	    victimid;
	if(sscanf(params, "uS()[64]", victimid, reason))
		return ShowCMD(playerid, "Tip: /warn [ID/Nick] [Powód(opcjonalny)]");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);

	new string[ 256 ];
	format(string, sizeof string, "~>~ Warn ~<~ ~r~%s ~w~dostal ostrzezenie od ~r~%s~w~. ~w~%s%s", NickName(victimid), NickName(playerid), reason[ 0 ] ? ("Powod: ~r~") : (""), reason);
	ShowKara(victimid, string);

	Logs(playerid, victimid, reason, kara_warn, -1);
	return 1;
}

Cmd::Input->bw(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_bw)) return 1;
	new victimid;
	if(sscanf(params, "u", victimid))
		return ShowCMD(playerid, "Tip: /bw [ID/Nick]");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);
	new string[ 64 ];
	if(Player(victimid, player_bw))
	{
	    UnBW(victimid);
	    SetPlayerHealth(victimid, Player(victimid, player_hp) = 20.0);
	    SetPlayerDrunkLevel(victimid, Player(victimid, player_drunklvl) = 0);
	    
	   	format(string, sizeof string, "%s ściągnął Ci BW.", NickName(playerid));
		Chat::Output(victimid, CLR_WHITE, string);

	   	format(string, sizeof string, "Ściągnąłeś BW %s.", NickName(victimid));
		Chat::Output(playerid, SZARY, string);
	}
	else
	{
	    OnPlayerStateChange(victimid, PLAYER_STATE_WASTED, GetPlayerState(victimid));
	    BW(victimid, 10);
		Player(victimid, player_spawned) = true;
		FreezePlayer(victimid);

	   	format(string, sizeof string, "%s nadał Ci BW.", NickName(playerid));
		Chat::Output(victimid, CLR_WHITE, string);

	   	format(string, sizeof string, "Nadałeś BW %s.", NickName(victimid));
		Chat::Output(playerid, SZARY, string);
	}
	UpdatePlayerNick(victimid);
	return 1;
}

Cmd::Input->freeze(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_bw)) return 1;
	new victimid;
	if(sscanf(params, "u", victimid))
		return ShowCMD(playerid, "Tip: /freeze [ID/Nick]");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);
	new string[ 64 ];
	if(Player(victimid, player_freezed))
	{
	    UnFreezePlayer(victimid);

	   	format(string, sizeof string, "%s odmroził Cię.", NickName(playerid));
		Chat::Output(victimid, CLR_WHITE, string);

	   	format(string, sizeof string, "Odmroziłeś %s.", NickName(victimid));
		Chat::Output(playerid, SZARY, string);
	}
	else
	{
	    FreezePlayer(victimid);

	   	format(string, sizeof string, "%s zamroził Cię.", NickName(playerid));
		Chat::Output(victimid, CLR_WHITE, string);

	   	format(string, sizeof string, "Zamroziłeś %s.", NickName(victimid));
		Chat::Output(playerid, SZARY, string);
	}
	return 1;
}

Cmd::Input->todoor(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_tp)) return 1;

	new dooruid;
	if(sscanf(params, "d", dooruid))
		return ShowCMD(playerid, "Tip: /todoor [UID drzwi]");
		
	new doorid;
	foreach(Server_Doors, door)
	{
	    if(Player(playerid, player_door) == dooruid)
	    {
			doorid = door;
			break;
		}
	}
	SetPlayerPosEx(playerid, Door(doorid, door_out_pos)[ 0 ], Door(doorid, door_out_pos)[ 1 ], Door(doorid, door_out_pos)[ 2 ], Door(doorid, door_out_pos)[ 3 ]);
	SetPlayerVirtualWorld(playerid, Player(playerid, player_vw) = Door(doorid, door_out_vw));
   	SetPlayerInterior(playerid, Player(playerid, player_int) = Door(doorid, door_out_int));
    #if !STREAMER
		LoadPlayerObjects(playerid, Player(playerid, player_vw));
	#endif
	LoadPlayerText(playerid, Player(playerid, player_vw));
	return 1;
}

Cmd::Input->goto(playerid, params[]) return cmd_to(playerid, params);
Cmd::Input->to(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_tp)) return 1;
	new victimid;
	if(sscanf(params, "u", victimid))
		return ShowCMD(playerid, "Tip: /to [ID/Nick]");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);
		
	new Float:pos[ 3 ];
	GetPlayerPos(victimid, pos[ 0 ], pos[ 1 ], pos[ 2 ]);
	Player(playerid, player_int) = Player(victimid, player_int) = GetPlayerInterior(victimid);
	Player(playerid, player_vw) = Player(victimid, player_vw) = GetPlayerVirtualWorld(victimid);
	Player(playerid, player_door) = Player(victimid, player_door);
	if(IsPlayerInAnyVehicle(playerid))
	{
	    new carid = GetPlayerVehicleID(playerid);
		SetPlayerVirtualWorld(playerid, Player(victimid, player_vw));
		SetVehicleVirtualWorld(carid, 	Vehicle(carid, vehicle_vw) = Player(victimid, player_vw));
		SetPlayerInterior(playerid, 	Player(victimid, player_int));
		LinkVehicleToInterior(carid, 	Vehicle(carid, vehicle_int) = Player(victimid, player_int));
	    SetPlayerPosEx(playerid, pos[ 0 ]+1, pos[ 1 ]+1, pos[ 2 ]+1.3);
		SetVehiclePos(carid, pos[ 0 ]+1, pos[ 1 ]+1, pos[ 2 ]+1.3);
		PutPlayerInVehicleEx(playerid, carid, GetPlayerVehicleSeat(playerid));
	}
	else
	{
		SetPlayerVirtualWorld(playerid, Player(victimid, player_vw));
		SetPlayerInterior(playerid, Player(victimid, player_int));
		SetPlayerPosEx(playerid, pos[ 0 ]+1, pos[ 1 ]+1, pos[ 2 ]+1.3);
	}
    #if !STREAMER
		LoadPlayerObjects(playerid, Player(victimid, player_vw));
	#endif
	LoadPlayerText(playerid, Player(victimid, player_vw));
	return 1;
}

Cmd::Input->gethere(playerid, params[]) return cmd_tm(playerid, params);
Cmd::Input->tm(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_tp)) return 1;
	new victimid;
	if(sscanf(params, "u", victimid))
		return ShowCMD(playerid, "Tip: /tm [ID/Nick]");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);
	if(Player(victimid, player_afktime)[ 0 ] > 5)
		return ShowCMD(playerid, "Ten gracz jest prawdopodobnie AFK.");

	new Float:pos[ 3 ];
	GetPlayerPos(playerid, pos[ 0 ], pos[ 1 ], pos[ 2 ]);
	Player(victimid, player_int) = Player(playerid, player_int) = GetPlayerInterior(playerid);
	Player(victimid, player_vw) = Player(playerid, player_vw) = GetPlayerVirtualWorld(playerid);
	Player(victimid, player_door) = Player(playerid, player_door);
	if(IsPlayerInAnyVehicle(victimid))
	{
	    new carid = GetPlayerVehicleID(victimid);
		SetPlayerVirtualWorld(victimid, Player(playerid, player_vw));
		SetVehicleVirtualWorld(carid, 	Vehicle(carid, vehicle_vw) =Player(playerid, player_vw));
		SetPlayerInterior(victimid, 	Player(playerid, player_int));
		LinkVehicleToInterior(carid, 	Vehicle(carid, vehicle_int) =Player(playerid, player_int));
	    SetPlayerPosEx(victimid, pos[ 0 ]+1, pos[ 1 ]+1, pos[ 2 ]+1.3);
		SetVehiclePos(carid, pos[ 0 ]+1, pos[ 1 ]+1, pos[ 2 ]+1.3);
		PutPlayerInVehicleEx(victimid, carid, GetPlayerVehicleSeat(victimid));
	}
	else
	{
		SetPlayerVirtualWorld(victimid, Player(playerid, player_vw));
		SetPlayerInterior(victimid, Player(playerid, player_int));
		SetPlayerPosEx(victimid, pos[ 0 ]+1, pos[ 1 ]+1, pos[ 2 ]+1.3);
	}
    #if !STREAMER
		LoadPlayerObjects(victimid, Player(victimid, player_vw));
	#endif
	LoadPlayerText(victimid, Player(victimid, player_vw));
	if(Player(victimid, player_selected_object) != INVALID_OBJECT_ID)
	{
	    Player(victimid, player_selected_object) = INVALID_OBJECT_ID;
	    Create(victimid, create_value)[ 1 ] = 0;
		CancelEdit(victimid);
	}
//    Chat::Output(victimid, CLR_GREEN, "Zostałeś teleportowany!");
	return 1;
}

Cmd::Input->ptp(playerid, params[]) return cmd_tp(playerid, params);
Cmd::Input->tp(pid, params[])
{
	if(!IsPlayerGameAdmin(pid, 1, admin_perm_tp)) return 1;
	new playerid,
		victimid;
	if(sscanf(params, "uu", victimid, playerid))
		return ShowCMD(playerid, "Tip: /tp [ID/Nick] [ID/Nick]");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(pid);
	if(!IsPlayerConnected(playerid))
		return NoPlayer(pid);

	new Float:pos[ 3 ];
	GetPlayerPos(playerid, pos[ 0 ], pos[ 1 ], pos[ 2 ]);
	Player(victimid, player_int) = Player(playerid, player_int) = GetPlayerInterior(playerid);
	Player(victimid, player_vw) = Player(playerid, player_vw) = GetPlayerVirtualWorld(playerid);
	Player(victimid, player_door) = Player(playerid, player_door);
	if(IsPlayerInAnyVehicle(victimid))
	{
	    new carid = GetPlayerVehicleID(victimid);
		SetPlayerVirtualWorld(victimid, Player(playerid, player_vw));
		SetVehicleVirtualWorld(carid, 	Vehicle(carid, vehicle_vw) =Player(playerid, player_vw));
		SetPlayerInterior(victimid, 	Player(playerid, player_int));
		LinkVehicleToInterior(carid, 	Vehicle(carid, vehicle_int) =Player(playerid, player_int));
	    SetPlayerPosEx(victimid, pos[ 0 ]+1, pos[ 1 ]+1, pos[ 2 ]+1.3);
		SetVehiclePos(carid, pos[ 0 ]+1, pos[ 1 ]+1, pos[ 2 ]+1.3);
		PutPlayerInVehicleEx(victimid, carid, GetPlayerVehicleSeat(victimid));
	}
	else
	{
		SetPlayerVirtualWorld(victimid, Player(playerid, player_vw));
		SetPlayerInterior(victimid, Player(playerid, player_int));
		SetPlayerPosEx(victimid, pos[ 0 ]+1, pos[ 1 ]+1, pos[ 2 ]+1.3);
	}
    #if !STREAMER
		LoadPlayerObjects(victimid, Player(playerid, player_vw));
	#endif
	LoadPlayerText(victimid, Player(playerid, player_vw));

    Chat::Output(victimid, CLR_GREEN, "Zostałeś teleportowany!");
    Chat::Output(pid, CLR_GREEN, "Gracz został teleportowany!");
	return 1;
}

Cmd::Input->stworz(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_create)) return 1;
	Dialog::Output(playerid, 64, DIALOG_STYLE_LIST, IN_HEAD, "Pojazd\nPrzedmiot\nDrzwi\nObiekt\nGrupe\nPickup\nStrefe", "Wybierz", "Zamknij");
	return 1;
}

Cmd::Input->edytuj(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_edit)) return 1;
	Dialog::Output(playerid, 97, DIALOG_STYLE_LIST, IN_HEAD, "Pojazd\nPrzedmiot\nDrzwi\nObiekt\nGrupe\nStrefe", "Wybierz", "Zamknij");
	return 1;
}

Cmd::Input->nieznajomi(playerid, params[])
{
    if(!Player(playerid, player_adminlvl)) return 1;
	new buffer[ 512 ];
	foreach(Player, i)
	{
		if(!Player(i, player_mask)) continue;
		format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, i, NickName(i));
	}
	if(isnull(buffer)) ShowInfo(playerid, red"Nikt nie ma ukrytej twarzy!");
	else ShowList(playerid, buffer);
	return 1;
}

Cmd::Input->ban(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_ban)) return 1;
	new victimid,
	    reason[ 64 ],
		endtime,
		type;
	if(sscanf(params, "udcS()[64]", victimid, endtime, type, reason))
		if(sscanf(params, "uS()[64]", victimid, reason))
		    return ShowCMD(playerid, "Tip: /ban [ID/Nick] [Powód] | /ban [ID/Nick] [Czas] [Typ(d,h,m)] [Powód(opcjonalny)]");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);
	if(IsPlayerNPC(victimid))
	    return ShowCMD(playerid, "Ten gracz to bot, bocie.");

	new stringTime[ 16 ],
		string[ 256 ];
	switch(tolower(type))
	{
		case 'd':
		{
			format(stringTime, sizeof stringTime, "%d %s", endtime, dli(endtime, "dzień", "dni", "dni"));
			endtime *= 86400;
		}
		case 'g', 'h':
		{
			format(stringTime, sizeof stringTime, "%d %s", endtime, dli(endtime, "godzina", "godziny", "godzin"));
			endtime *= 3600;
		}
		case 'm':
		{
			format(stringTime, sizeof stringTime, "%d %s", endtime, dli(endtime, "minuta", "minuty", "minut"));
			endtime *= 60;
		}
		case 0: // Permanentny
		{
		    endtime = -1;
		}
		default:
			return ShowInfo(playerid, kom"Typy blokad:\nd - dni\nh - godziny\nm - minuty");
	}
	if(endtime == -1)
		format(string, sizeof string, "~>~ Ban ~<~ ~r~%s ~w~dostal bana od ~r~%s~w~. ~w~%s%s", Player(victimid, player_gname), NickName(playerid), reason[ 0 ] ? ("Powod: ~r~") : (""), reason);
	else
		format(string, sizeof string, "~>~ Ban ~<~ ~r~%s ~w~dostal bana od ~r~%s~w~ na ~r~%s~w~. ~w~%s%s", Player(victimid, player_gname), NickName(playerid), stringTime, reason[ 0 ] ? ("Powod: ~r~") : (""), reason);
	ShowKara(victimid, string);
	
	format(string, sizeof string,
	    "UPDATE `"IN_PREF"members` SET `member_group_id` = '5' WHERE `uid` = '%d'",
	    Player(victimid, player_guid)
	);
	mysql_query(string);
	
	Logs(playerid, victimid, reason, kara_ban, endtime);
	Player(victimid, player_block) += block_ban;
	SetTimerEx (!#kickPlayer, 249, false, !"i", victimid);
	return 1;
}

Cmd::Input->block(playerid, params[])
{
	if(!Player(playerid, player_adminlvl)) return 1;
	new victimid,
		string[ 32 ],
		string2[ 64 ];
	if(sscanf(params, "us[32]S()[64]", victimid, string, string2))
	    return ShowCMD(playerid, "Tip: /block [ID/Nick] [weap, char, veh, ooc, run]");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);
		
	new buffer[ 126 ];
	format(buffer, sizeof buffer, "%d %s", victimid, string2);
    if(!strcmp(string, "char", true) || !strcmp(string, "character", true))
        cmd_blockchar(playerid, buffer);
    else if(!strcmp(string, "weap", true) || !strcmp(string, "weapon", true))
        cmd_nogun(playerid, buffer);
    else if(!strcmp(string, "veh", true) || !strcmp(string, "vehicle", true))
        cmd_noveh(playerid, buffer);
    else if(!strcmp(string, "ooc", true))
        cmd_noooc(playerid, buffer);
    else if(!strcmp(string, "run", true))
        cmd_norun(playerid, buffer);
	else cmd_block(playerid, "");
	return 1;
}

Cmd::Input->blockchar(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_block)) return 1;
	new victimid,
	    reason[ 64 ],
		endtime,
		type;
	if(sscanf(params, "udcS()[64]", victimid, endtime, type, reason))
		if(sscanf(params, "uS()[64]", victimid, reason))
		    return ShowCMD(playerid, "Tip: /block [ID/Nick] [Powód] | /block [ID/Nick] [Czas] [Typ(d,h,m)] [Powód(opcjonalny)]");

	new stringTime[ 16 ],
		string[ 256 ];
	switch(tolower(type))
	{
		case 'd':
		{
			format(stringTime, sizeof stringTime, "%d %s", endtime, dli(endtime, "dzień", "dni", "dni"));
			endtime *= 86400;
		}
		case 'g', 'h':
		{
			format(stringTime, sizeof stringTime, "%d %s", endtime, dli(endtime, "godzina", "godziny", "godzin"));
			endtime *= 3600;
		}
		case 'm':
		{
			format(stringTime, sizeof stringTime, "%d %s", endtime, dli(endtime, "minuta", "minuty", "minut"));
			endtime *= 60;
		}
		case 0: // Permanentny
		{
		    endtime = -1;
		}
		default:
			return ShowInfo(playerid, kom"Typy blokad:\nd - dni\nh - godziny\nm - minuty");
	}
	if(endtime == -1)
		format(string, sizeof string, "~>~ Block ~<~ ~r~%s ~w~dostal bana od ~r~%s~w~. ~w~%s%s", NickName(victimid), NickName(playerid), reason[ 0 ] ? ("Powod: ~r~") : (""), reason);
	else
		format(string, sizeof string, "~>~ Block ~<~ ~r~%s ~w~dostal bana od ~r~%s~w~ na ~r~%s~w~. ~w~%s%s", NickName(victimid), NickName(playerid), stringTime, reason[ 0 ] ? ("Powod: ~r~") : (""), reason);
	ShowKara(victimid, string);

	Logs(playerid, victimid, reason, kara_block, endtime);
	Player(victimid, player_block) += block_block;
	SetTimerEx (!#kickPlayer, 249, false, !"i", victimid);
	return 1;
}

Cmd::Input->nogun(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_blockad)) return 1;
	new victimid,
	    reason[ 64 ],
		endtime,
		type;
	if(sscanf(params, "udcS()[64]", victimid, endtime, type, reason))
		if(sscanf(params, "uS()[64]", victimid, reason))
		    return ShowCMD(playerid, "Tip: /nogun [ID/Nick] [Powód] | /nogun [ID/Nick] [Czas] [Typ(d,h,m)] [Powód(opcjonalny)]");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);

	if(Player(victimid, player_block) & block_nogun)
	{
	    ShowCMD(playerid, "Blokada broni zdjęta.");
	    Player(victimid, player_block) -= block_nogun;
	}
	else
	{
		new stringTime[ 16 ],
			string[ 256 ];
		switch(tolower(type))
		{
			case 'd':
			{
				format(stringTime, sizeof stringTime, "%d %s", endtime, dli(endtime, "dzień", "dni", "dni"));
				endtime *= 86400;
			}
			case 'g', 'h':
			{
				format(stringTime, sizeof stringTime, "%d %s", endtime, dli(endtime, "godzina", "godziny", "godzin"));
				endtime *= 3600;
			}
			case 'm':
			{
				format(stringTime, sizeof stringTime, "%d %s", endtime, dli(endtime, "minuta", "minuty", "minut"));
				endtime *= 60;
			}
			case 0: // Permanentny
			{
			    endtime = -1;
			}
			default:
				return ShowInfo(playerid, kom"Typy blokad:\nd - dni\nh - godziny\nm - minuty");
		}
		if(endtime == -1)
			format(string, sizeof string, "~>~ Blokada broni ~<~ ~r~%s ~w~zablokowal mozliwosc uzywania broni ~r~%s~w~. ~w~%s%s", NickName(playerid), NickName(victimid), reason[ 0 ] ? ("Powod: ~r~") : (""), reason);
		else
			format(string, sizeof string, "~>~ Blokada broni ~<~ ~r~%s ~w~zablokowal mozliwosc uzywania broni ~r~%s~w~ na ~r~%s~w~. ~w~%s%s", NickName(playerid), NickName(victimid), stringTime, reason[ 0 ] ? ("Powod: ~r~") : (""), reason);
		ShowKara(victimid, string);

		Logs(playerid, victimid, reason, kara_nogun, endtime);
		Player(victimid, player_block) += block_nogun;
	}
	return 1;
}

Cmd::Input->norun(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_blockad)) return 1;
	new victimid,
	    reason[ 64 ],
		endtime,
		type;
	if(sscanf(params, "udcS()[64]", victimid, endtime, type, reason))
		if(sscanf(params, "uS()[64]", victimid, reason))
		    return ShowCMD(playerid, "Tip: /norun [ID/Nick] [Powód] | /norun [ID/Nick] [Czas] [Typ(d,h,m)] [Powód(opcjonalny)]");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);

	if(Player(victimid, player_block) & block_norun)
	{
	    ShowCMD(playerid, "Blokada biegania zdjęta.");
	    Player(victimid, player_block) -= block_norun;
	}
	else
	{
		new stringTime[ 16 ],
			string[ 256 ];
		switch(tolower(type))
		{
			case 'd':
			{
				format(stringTime, sizeof stringTime, "%d %s", endtime, dli(endtime, "dzień", "dni", "dni"));
				endtime *= 86400;
			}
			case 'g', 'h':
			{
				format(stringTime, sizeof stringTime, "%d %s", endtime, dli(endtime, "godzina", "godziny", "godzin"));
				endtime *= 3600;
			}
			case 'm':
			{
				format(stringTime, sizeof stringTime, "%d %s", endtime, dli(endtime, "minuta", "minuty", "minut"));
				endtime *= 60;
			}
			case 0: // Permanentny
			{
			    endtime = -1;
			}
			default:
				return ShowInfo(playerid, kom"Typy blokad:\nd - dni\nh - godziny\nm - minuty");
		}
		if(endtime == -1)
			format(string, sizeof string, "~>~ Blokada biegania ~<~ ~r~%s ~w~zablokowal mozliwosc biegania ~r~%s~w~. ~w~%s%s", NickName(playerid), NickName(victimid), reason[ 0 ] ? ("Powod: ~r~") : (""), reason);
		else
			format(string, sizeof string, "~>~ Blokada biegania ~<~ ~r~%s ~w~zablokowal mozliwosc biegania ~r~%s~w~ na ~r~%s~w~. ~w~%s%s", NickName(playerid), NickName(victimid), stringTime, reason[ 0 ] ? ("Powod: ~r~") : (""), reason);
		ShowKara(victimid, string);

		Logs(playerid, victimid, reason, kara_norun, endtime);
		Player(victimid, player_block) += block_norun;
	}
	return 1;
}

Cmd::Input->noveh(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_blockad)) return 1;
	new victimid,
	    reason[ 64 ],
		endtime,
		type;
	if(sscanf(params, "udcS()[64]", victimid, endtime, type, reason))
		if(sscanf(params, "uS()[64]", victimid, reason))
		    return ShowCMD(playerid, "Tip: /noveh [ID/Nick] [Powód] | /noveh [ID/Nick] [Czas] [Typ(d,h,m)] [Powód(opcjonalny)]");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);

	if(Player(victimid, player_block) & block_noveh)
	{
	    ShowCMD(playerid, "Blokada prowadzenia pojazdów zdjęta.");
	    Player(victimid, player_block) -= block_noveh;
	}
	else
	{
		new stringTime[ 16 ],
			string[ 256 ];
		switch(tolower(type))
		{
			case 'd':
			{
				format(stringTime, sizeof stringTime, "%d %s", endtime, dli(endtime, "dzień", "dni", "dni"));
				endtime *= 86400;
			}
			case 'g', 'h':
			{
				format(stringTime, sizeof stringTime, "%d %s", endtime, dli(endtime, "godzina", "godziny", "godzin"));
				endtime *= 3600;
			}
			case 'm':
			{
				format(stringTime, sizeof stringTime, "%d %s", endtime, dli(endtime, "minuta", "minuty", "minut"));
				endtime *= 60;
			}
			case 0: // Permanentny
			{
			    endtime = -1;
			}
			default:
				return ShowInfo(playerid, kom"Typy blokad:\nd - dni\nh - godziny\nm - minuty");
		}
		if(endtime == -1)
			format(string, sizeof string, "~>~ Blokada pojazdow ~<~ ~r~%s ~w~zablokowal mozliwosc prowadzenia pojazdow ~r~%s~w~. ~w~%s%s", NickName(playerid), NickName(victimid), reason[ 0 ] ? ("Powod: ~r~") : (""), reason);
		else
			format(string, sizeof string, "~>~ Blokada pojazdow ~<~ ~r~%s ~w~zablokowal mozliwosc prowadzenia pojazdow ~r~%s~w~ na ~r~%s~w~. ~w~%s%s", NickName(playerid), NickName(victimid), stringTime, reason[ 0 ] ? ("Powod: ~r~") : (""), reason);
		ShowKara(victimid, string);

		Logs(playerid, victimid, reason, kara_noveh, endtime);
		Player(victimid, player_block) += block_noveh;
	}
	return 1;
}

Cmd::Input->noooc(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_blockad)) return 1;
	new victimid,
	    reason[ 64 ],
		endtime,
		type;
	if(sscanf(params, "udcS()[64]", victimid, endtime, type, reason))
		if(sscanf(params, "uS()[64]", victimid, reason))
		    return ShowCMD(playerid, "Tip: /noooc [ID/Nick] [Powód] | /noooc [ID/Nick] [Czas] [Typ(d,h,m)] [Powód(opcjonalny)]");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);

	if(Player(victimid, player_block) & block_noooc)
	{
	    ShowCMD(playerid, "Blokada czatu OOC zdjęta.");
	    Player(victimid, player_block) -= block_noooc;
	}
	else
	{
		new stringTime[ 16 ],
			string[ 256 ];
		switch(tolower(type))
		{
			case 'd':
			{
				format(stringTime, sizeof stringTime, "%d %s", endtime, dli(endtime, "dzień", "dni", "dni"));
				endtime *= 86400;
			}
			case 'g', 'h':
			{
				format(stringTime, sizeof stringTime, "%d %s", endtime, dli(endtime, "godzina", "godziny", "godzin"));
				endtime *= 3600;
			}
			case 'm':
			{
				format(stringTime, sizeof stringTime, "%d %s", endtime, dli(endtime, "minuta", "minuty", "minut"));
				endtime *= 60;
			}
			case 0: // Permanentny
			{
			    endtime = -1;
			}
			default:
				return ShowInfo(playerid, kom"Typy banów:\nd - dni\nh - godziny\nm - minuty");
		}
		if(endtime == -1)
			format(string, sizeof string, "~>~ Blakada czatu OOC ~<~ ~r~%s ~w~zablokowal mozliwosc pisania na czacie OOC ~r~%s~w~. ~w~%s%s", NickName(playerid), NickName(victimid), reason[ 0 ] ? ("Powod: ~r~") : (""), reason);
		else
			format(string, sizeof string, "~>~ Blokada czatu OOC ~<~ ~r~%s ~w~zablokowal mozliwosc pisania na czacie OOC ~r~%s~w~ na ~r~%s~w~. ~w~%s%s", NickName(playerid), NickName(victimid), stringTime, reason[ 0 ] ? ("Powod: ~r~") : (""), reason);
		ShowKara(victimid, string);

		Logs(playerid, victimid, reason, kara_noooc, endtime);
		Player(victimid, player_block) += block_noooc;
	}
	return 1;
}

Cmd::Input->glob(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_glob)) return 1;

	if(isnull(params))
		return ShowCMD(playerid, "Tip: /glob [Treść]");

	new len = strlen(params),
		str[ 128 ];
    params[ 0 ] = toupper(params[ 0 ]);
 	if(len >= MAX_LINE)
	{
       	new text1[ MAX_LINE+1 ],
        	text2[ MAX_LINE+1 ];

		new odstep = strfind(params, " ", .pos = (MAX_LINE-10));
		if(odstep == -1) odstep = MAX_LINE;

       	strmid(text1, params, 0, odstep);
       	strmid(text2, params, odstep, len);
       	if(odstep != -1) strdel(text2, 0, 1);

       	format(str, sizeof str, "[[ %s: %s...", NickName(playerid), text1);
		SendClientMessageToAll(CLR_WHITE, str);

       	format(str, sizeof str, "...%s ]]", text2);
		SendClientMessageToAll(CLR_WHITE, str);
  	}
  	else
  	{
		format(str, sizeof str, "[[ %s: %s ]]", NickName(playerid), params);
		SendClientMessageToAll(CLR_WHITE, str);
	}
	return 1;
}

Cmd::Input->as(playerid, params[])
{
	if(!Player(playerid, player_adminlvl)) return 1;

	if(isnull(params))
		return ShowCMD(playerid, "Tip: /as [Treść]");
	if(!Player(playerid, player_aduty))
	    return ShowCMD(playerid, "Nie jesteś na /aduty!");
	    
	params[ 0 ] = toupper(params[ 0 ]);
	
	new str[ 200 ];
	if(isnull(AdminLvl[ Player(playerid, player_adminlvl) ][ admin_tag ]))
		format(str, sizeof str,
			"(( {%06x}%s (%d)"yellow": %s ))",
			AdminLvl[ Player(playerid, player_adminlvl) ][ admin_color ] >>> 8,
			NickName(playerid),
			playerid,
			params
		);
	else
		format(str, sizeof str,
			"(( {%06x}[%s] %s (%d)"yellow": %s ))",
			AdminLvl[ Player(playerid, player_adminlvl) ][ admin_color ] >>> 8,
			AdminLvl[ Player(playerid, player_adminlvl) ][ admin_tag ],
			NickName(playerid),
			playerid,
			params
		);
	
	foreach(Player, i)
		if(Player(i, player_adminlvl) && Player(i, player_aduty))
			Chat::Output(i, CLR_ZOLTY, str);
	return 1;
}

Cmd::Input->relog(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_kick)) return 1;
	new victimid;
	if(sscanf(params, "u", victimid))
		return ShowCMD(playerid, "Tip: /relog [ID/Nick]");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);
	if(IsPlayerNPC(victimid))
	    return ShowCMD(playerid, "Ten gracz to bot, bocie.");

	cmd_login(victimid, "");
	return 1;
}

Cmd::Input->kick(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_kick)) return 1;
	new reason[ 64 ],
	    victimid;
	if(sscanf(params, "uS()[64]", victimid, reason))
		return ShowCMD(playerid, "Tip: /kick [ID/Nick] [Powód(opcjonalny)]");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);
	if(IsPlayerNPC(victimid))
	    return ShowCMD(playerid, "Ten gracz to bot, bocie.");

	new string[ 256 ];
	format(string, sizeof string, "~>~ Kick ~<~ ~r~%s ~w~zostal wyrzucony przez ~r~%s~w~. ~w~%s%s", NickName(victimid), NickName(playerid), reason[ 0 ] ? ("Powod: ~r~") : (""), reason);
	ShowKara(victimid, string);

	Logs(playerid, victimid, reason, kara_kick, -1);
	SetTimerEx(!#kickPlayer, 249, false, !"i", victimid);
	return 1;
}

Cmd::Input->kickex(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_kick)) return 1;
	new reason[ 64 ],
	    victimid;
	if(sscanf(params, "uS()[64]", victimid, reason))
		return ShowCMD(playerid, "Tip: /kickex [ID/Nick] [Powód(opcjonalny)]");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);

	Kick(victimid);
	return 1;
}

Cmd::Input->asay(playerid, params[])
{
	if(!Player(playerid, player_adminlvl)) return 1;
	new reason[ 64 ],
	    victimid;
	if(sscanf(params, "us[64]", victimid, reason))
		return ShowCMD(playerid, "Tip: /asay [ID/Nick] [Treść]");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);
		
	OnPlayerText(victimid, reason);
	return 1;
}

Cmd::Input->globdo(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_globdo)) return 1;
	if(isnull(params))
		return ShowCMD(playerid, "Tip: /globdo [Treść]");

	new len = strlen(params),
		str[ 128 ];
	params[ 0 ] = toupper(params[ 0 ]);
	if(len >= MAX_LINE)
	{
       	new text1[ MAX_LINE+1 ],
        	text2[ MAX_LINE+1 ];
		new odstep = strfind(params, " ", .pos = (MAX_LINE-10));
		if(odstep == -1) odstep = MAX_LINE;

       	strmid(text1, params, 0, odstep);
       	strmid(text2, params, odstep, len);
       	if(odstep != -1) strdel(text2, 0, 1);

       	format(str, sizeof str, "* %s...", text1);
		SendClientMessageToAll(COLOR_DO, str);

       	format(str, sizeof str, "...%s *", text2);
		SendClientMessageToAll(COLOR_DO, str);
  	}
  	else
  	{
		format(str, sizeof str, "* %s *", params);
		SendClientMessageToAll(COLOR_DO, str);
	}
 	return 1;
}

Cmd::Input->aj(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_aj)) return 1;
	
	new victimid;
	if(sscanf(params, "u", victimid))
		return ShowCMD(playerid, "Tip: /aj [ID/Nick]");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);
	if(Player(victimid, player_aj))
	{
	    Player(victimid, player_aj) = 3;
	}
	else
	{
		new reason[ 64 ], timed;
		if(sscanf(params, "udS()[64]", victimid, timed, reason))
		    return ShowCMD(playerid, "Tip: /aj [ID/Nick] [Czas] [Powód(opcjonalny)]");

		new string[ 256 ];
		format(string, sizeof string, "~>~ Jail ~<~ ~r~%s ~w~zostal uwieziony w Admin Jailu przez ~r~%s~w~. ~w~%s%s", NickName(victimid), NickName(playerid), reason[ 0 ] ? ("Powod: ~r~") : (""), reason);
		ShowKara(victimid, string);
		
		OnPlayerLoginOut(victimid);
		Player(victimid, player_position)[ 0 ] = Setting(setting_aj)[ 0 ];
		Player(victimid, player_position)[ 1 ] = Setting(setting_aj)[ 1 ];
		Player(victimid, player_position)[ 2 ] = Setting(setting_aj)[ 2 ];
		
		SetPlayerPosEx(victimid, Player(victimid, player_position)[ 0 ], Player(victimid, player_position)[ 1 ], Player(victimid, player_position)[ 2 ]);
		SetPlayerVirtualWorld(victimid, Player(victimid, player_vw) = victimid);
		SetPlayerInterior(victimid, Player(victimid, player_int) = 0);

		Logs(playerid, victimid, reason, kara_jail, -1);
		Player(victimid, player_aj) = timed*60;
	}
	return 1;
}
Cmd::Input->rc(playerid, params[]) return cmd_spec(playerid, params);
Cmd::Input->spec(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_spec)) return 1;

	if(isnull(params))
	{
		new victimid = Player(playerid, player_spec);
		if(victimid != INVALID_PLAYER_ID)
		{
	    	TogglePlayerSpectating(playerid, false);
			SetCameraBehindPlayer(playerid);
		    Player(victimid, player_spectated)--;
		    Player(playerid, player_spec) = INVALID_PLAYER_ID;
	    }
	}
	else
	{
		new victimid;
		if(sscanf(params, "u", victimid))
			return ShowCMD(playerid, "Tip: /rc [ID/Nick]");
		if(!IsPlayerConnected(victimid))
			return NoPlayer(playerid);
		if(Player(victimid, player_spec) != INVALID_PLAYER_ID)
		    return ShowCMD(playerid, "Ten gracz kogoś specuje");
		    
		OnPlayerLoginOut(playerid);
		TogglePlayerSpectating(playerid, true);
		Player(playerid, player_spec) = victimid;
		Player(victimid, player_spectated)++;
		SetPlayerVirtualWorld(playerid, Player(victimid, player_vw));
		SetPlayerInterior(playerid, Player(victimid, player_int));
    	#if !STREAMER
			LoadPlayerObjects(playerid, Player(victimid, player_vw));
		#endif
		LoadPlayerText(playerid, Player(victimid, player_vw));
		
        if(GetPlayerState(victimid) == PLAYER_STATE_DRIVER)
		{
		    PlayerSpectateVehicle(playerid, GetPlayerVehicleID(victimid));
		}
		else
		{
		    PlayerSpectatePlayer(playerid, victimid);
		}
		//ShowCMD(playerid, "Podglądasz gracza, by przestać użyj ponownie (/rc)");
	}
	return 1;
}

Cmd::Input->serwer(playerid, params[])
{
	if(!IsPlayerGameAdmin(playerid, 1, admin_perm_server)) return 1;

//	if(!(Player(playerid, player_adminlvl) && Player(playerid, player_adminperm) & admin_perm_server)) return 1;
	
	new sub[ 80 ],
   		rest[ 80 ];
   	if(sscanf(params, "s[80]S()[80]", sub, rest))
	   	return ShowCMD(playerid, "Tip: /serwer [mysql/pogoda/godzina/reload]");
   	if(!strcmp(sub, "mysql", true))
	{
	    new string[ 128 ];
		mysql_stat(string);
		SendClientMessage(playerid, SZARY, string);
	}
	else if(!strcmp(sub, "netstats", true))
	{
		new stats[ 401 ];
        GetNetworkStats(stats, sizeof stats); 
        ShowInfo(playerid, stats);
	}
	else if(!strcmp(sub, "pogoda", true))
	{
		if(isnull(rest)) return ShowCMD(playerid, "Tip: /serwer pogoda [ID]");
        Setting(setting_weather) = strval(rest);
		SetWeather(Setting(setting_weather));
		foreach(Player, i)
		{
		    if(!Player(i, player_logged)) continue;
			if(!Player(i, player_door)) continue;
			SetPlayerWeather(playerid, 2);
		}
	}
	else if(!strcmp(sub, "godzina", true))
	{
		if(isnull(rest)) return ShowCMD(playerid, "Tip: /serwer godzina [godzina]");
		SetWorldTime(strval(rest));
	}
	else if(!strcmp(sub, "restart", true) || !strcmp(sub, "gmx", true))
	{
		SendClientMessageToAll(SZARY, "Restart serwera!");
		foreach(Player, i) SetTimerEx (!#kickPlayer, 249, false, !"i", i);

		SetTimer("RestartMode", 4000, false);
	}
	else if(!strcmp(sub, "reload", true))
	{
	    new sub2[ 20 ], rest2[ 32 ];
	    if(sscanf(rest, "s[20]S()[32]", sub2, rest2))
	        return ShowCMD(playerid, "Tip: /serwer reload [objects/text/builds/vehicles]");

	    if(!strcmp(sub2, "objects", true))
	    {
    		#if STREAMER
    		    LoadObjects();
			#else
		        foreach(Player, i)
		        {
		            if(!Player(i, player_spawned) || !Player(i, player_logged))
						continue;
		            if(Player(i, player_selected_object) != INVALID_OBJECT_ID)
						continue;
					if(Player(i, player_vw) != Player(playerid, player_vw))
					    continue;
		            LoadPlayerObjects(i, Player(i, player_vw));
		        }
			#endif
	        ShowCMD(playerid, "Obiekty przeładowane!");
	    }
	    else
		if(!strcmp(sub2, "text", true))
	    {
	        foreach(Player, i)
	        {
	            if(!Player(i, player_spawned) || !Player(i, player_logged))
					continue;

	            LoadPlayerText(i, Player(i, player_vw));
	        }
	        ShowCMD(playerid, "3D texty przeładowane!");
	    }
	    else if(!strcmp(sub2, "builds", true))
	    {
	    	foreach(Player, i)
	        {
	            if(!Player(i, player_spawned) || !Player(i, player_logged))
					continue;
					
				RemovePlayerBuilds(i);
			}
			ShowCMD(playerid, "Usunięte obiekty przeładowane!");
	    }
	    else if(!strcmp(sub2, "vehicles", true))
	    {
	        new Float:dist,
				redx;
	        if(sscanf(rest2, "F(50)D(1)", dist, redx))
	            return ShowCMD(playerid, "Tip: /serwer reload vehicles [dystans] [0 - nie tworzą się, 1 - tworzą się]");
	            
	        new UsedVeh[ MAX_VEHICLES ] = {false, ...},
    			iTrailer[ MAX_VEHICLES ] = {false, ...},
				count = 0,
				string[ 60 ];
    		foreach(Player, i)
    		{
	            if(!Player(i, player_spawned) || !Player(i, player_logged))
					continue;
    		    if(!GetPlayerVehicleID(i))
					continue;
					
    		    UsedVeh[GetPlayerVehicleID(i)] = true;
    		    if(IsTrailerAttachedToVehicle(GetPlayerVehicleID(i)) == 1)
    		        iTrailer[GetPlayerVehicleID(i)] = true;
	        }
	        for(new i = 1; i != MAX_VEHICLES; i++)
		 	{
			    if(!Vehicle(i, vehicle_uid))
					continue;
			    if(Vehicle(i, vehicle_vehID) == INVALID_VEHICLE_ID)
					continue;
				if(GetDistanceToCar(playerid, i) > dist)
				    continue;
			    if(!UsedVeh[ i ] && !iTrailer[ i ])
		        {
		            new uid = Vehicle(i, vehicle_uid);
				    UnSpawnVeh(i);
				    if(redx)
						LoadVehicleEx(uid);
				    count++;
				}
			}
			format(string, sizeof string, "Przeładowałeś %d nieużywanych pojazdów", count);
			ShowCMD(playerid, string);
	    }
	}
	return 1;
}

Cmd::Input->heal(victimid, params[])
{
	if(!Player(victimid, player_adminlvl)) return 1;

	new playerid;
	if(!isnull(params)) sscanf(params, "u", playerid);
	else playerid = victimid;

	if(!IsPlayerConnected(playerid))
		return NoPlayer(victimid);

	SetPlayerHealth(playerid, Player(playerid, player_hp) = 100.0);
	SetPlayerDrunkLevel(playerid, Player(playerid, player_drunklvl) = 0);
	SetPlayerWeather(playerid, Setting(setting_weather));
	UpdatePlayerNick(playerid);
	return 1;
}

Cmd::Input->setweaponskill(playerid, params[])
{
	if(!Player(playerid, player_adminlvl)) return 1;
	
	new victimid,
		weaponid,
		skill;
	if(sscanf(params, "udD(1)", victimid, weaponid, skill))
		return ShowCMD(playerid, "Tip: /setweaponskill [ID/Nick] [weapon] [skill 1/0]");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);
	if(!(0 <= weaponid <= 10))
	    return ShowCMD(playerid, "Błąd: Weaponid od 0 do 10");
	    
	if(skill) skill = 999;
	else skill = 0;
	    
    SetPlayerSkillLevel(victimid, weaponid, skill);
    ShowCMD(playerid, "WeaponSkill zmieniony!");
	return 1;
}

