FuncPub::LoadBus()
{
	new busid = 1,
	    string[ 64 ];
	mysql_query("SELECT surv_bus.uid, surv_bus.name, surv_bus.street, surv_objects.X, surv_objects.Y, surv_objects.Z FROM `surv_bus` JOIN `surv_objects` ON surv_bus.objectuid = surv_objects.uid");
	mysql_store_result();
	while(mysql_fetch_row_format(string))
	{
	    if(busid == MAX_BUS) break;
	    
	    sscanf(string, "p<|>ds[32]da<f>[3]",
		    Bus(busid, bus_uid),
		    Bus(busid, bus_name),
		    Bus(busid, bus_street),
		    Bus(busid, bus_pos)
	    );

    	busid++;
    }
    mysql_free_result();
	printf("# Autobusy zostały wczytane! | %d", busid-1);
	return 1;
}

FuncPub::Bus_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case 13:
		{
		    if(!response) return 1;
		    new busuid = strval(inputtext);
			new act_bus = Player(playerid, player_busid);
		    
		    new busid;
		    for(; busid != MAX_BUS; busid++)
		        if(Bus(busid, bus_uid) == busuid)
		            break;
		            
		    new Float:pricex,
		        Float:price,
				czas;
			pricex = Distance3D(Bus(busid, bus_pos)[ 0 ], Bus(busid, bus_pos)[ 1 ], Bus(busid, bus_pos)[ 2 ], Bus(act_bus, bus_pos)[ 0 ], Bus(act_bus, bus_pos)[ 1 ], Bus(act_bus, bus_pos)[ 2 ]);
			czas = floatval(floatdiv(pricex, 10));
			price = floatdiv(pricex, 40);
			
			SetPVarInt(playerid, "bus-id", 		busid);
			SetPVarInt(playerid, "bus-time", 	czas);
			SetPVarFloat(playerid, "bus-price", 	price);
			
			if(price > Player(playerid, player_cash))
				return ShowInfo(playerid, red"Nie masz wystarczajacej ilości gotówki, by zapłacić za przejazd.");

		    new czasStr[ 45 ];
			ReturnTimeMega(czas, czasStr);

			new string[ 150 ];
	    	format(string, sizeof string,
				"Nazwa:\t"green"%s\nCena:\t"green"$%.2f\nCzas:\t"green"%s\nCzy na pewno chcesz się tam udać?",
				Bus(busid, bus_name),
				GetPVarFloat(playerid, "bus-price"),
				czasStr
			);
     		Dialog::Output(playerid, 14, DIALOG_STYLE_LIST, IN_HEAD, string, "Tak", "Nie");
		}
		case 14:
		{
		    if(!response)
		    {
				DeletePVar(playerid, "bus-price");
    			DeletePVar(playerid, "bus-time");
    			DeletePVar(playerid, "bus-id");
		        return 1;
		    }
		    ShowInfo(playerid, green"Autobus zjawi się za kilka chwil!\n\n"white"Jeżeli chcesz anulować podróż oddal się od przystanku.");
		    KillTimer(Player(playerid, player_bus_timer));
			Player(playerid, player_bus_timer) = SetTimerEx("Bus_Timer", 5000, 0, "d", playerid);
		}
	}
	return 1;
}

FuncPub::Bus_Timer(playerid)
{
	new act_bus = Player(playerid, player_busid);
 	if(!IsPlayerInRangeOfPoint(playerid, 10.0, Bus(act_bus, bus_pos)[ 0 ], Bus(act_bus, bus_pos)[ 1 ], Bus(act_bus, bus_pos)[ 2 ]))
		return Chat::Output(playerid, SZARY, (Player(playerid, player_sex) == sex_woman) ? ("Oddaliłaś się od przystanku i nie wsiadłaś do autobusu.") : ("Oddaliłeś się od przystanku i nie wsiadłeś do autobusu."));

	new Float:bus_price = GetPVarFloat(playerid, "bus-price");
	DeletePVar(playerid, "bus-price");
	if(bus_price > Player(playerid, player_cash))
		return ShowInfo(playerid, red"Nie masz wystarczajacej ilości gotówki, by zapłacić za przejazd.");
	GivePlayerMoneyEx(playerid, 0 - bus_price, true);

	new bus_time = GetPVarInt(playerid, "bus-time");
	new busid = GetPVarInt(playerid, "bus-id");
    DeletePVar(playerid, "bus-time");
    KillTimer(Player(playerid, player_bus_timer));
	Player(playerid, player_bus_timer) = SetTimerEx("Bus_Timer_Ex", bus_time*1000, 0, "d", playerid);

	new string[ 126 ];
	format(string, sizeof string, "* %s wsiadł%s do lini 102 i odjechał%s w stronę przystanku \"%s\".", NickName(playerid), (Player(playerid, player_sex) == sex_woman) ? ("a") : (""), (Player(playerid, player_sex) == sex_woman) ? ("a") : (""), Bus(busid, bus_name));
	serwerme(playerid, string);

	SetPlayerPosEx(playerid, Bus(busid, bus_pos)[ 0 ], Bus(busid, bus_pos)[ 1 ], Bus(busid, bus_pos)[ 2 ]-15.0);
	TogglePlayerControllable(playerid, false);

	InterpolateCameraPos(playerid, Bus(act_bus, bus_pos)[ 0 ], Bus(act_bus, bus_pos)[ 1 ], Bus(act_bus, bus_pos)[ 2 ]+20.0, Bus(busid, bus_pos)[ 0 ], Bus(busid, bus_pos)[ 1 ], Bus(busid, bus_pos)[ 2 ], ((bus_time*1000)+2000), CAMERA_MOVE);
	InterpolateCameraLookAt(playerid, Bus(busid, bus_pos)[ 0 ], Bus(busid, bus_pos)[ 1 ], Bus(busid, bus_pos)[ 2 ], Bus(busid, bus_pos)[ 0 ], Bus(busid, bus_pos)[ 1 ], Bus(busid, bus_pos)[ 2 ], 1000, CAMERA_MOVE);
	return 1;
}

FuncPub::Bus_Timer_Ex(playerid)
{
	new busid = GetPVarInt(playerid, "bus-id");
	SetPlayerPosEx(playerid, Bus(busid, bus_pos)[ 0 ], Bus(busid, bus_pos)[ 1 ], Bus(busid, bus_pos)[ 2 ]);
	UnFreezePlayer(playerid);
    #if STREAMER == 0
		LoadPlayerObjects(playerid, Player(playerid, player_vw));
	#endif
	LoadPlayerText(playerid, Player(playerid, player_vw));

	SetCameraBehindPlayer(playerid);
	
	new str[ 30 + MAX_PLAYER_NAME ];
	format(str, sizeof str, "* %s %s", NickName(playerid), (Player(playerid, player_sex) == sex_woman) ? ("wysiadła z autobusu.") : ("wysiadł z autobusu."));
	serwerme(playerid, str);

    Player(playerid, player_busid) 		= 0;
    KillTimer(Player(playerid, player_bus_timer));
    Player(playerid, player_bus_timer) 	= 0;
    DeletePVar(playerid, "bus-id");
	return 1;
}

Cmd::Input->bus(playerid, params[])
{
	new buffer[ 1024 ];
	Player(playerid, player_busid) = 0;
	
	for(new busid; busid != MAX_BUS; busid++)
	{
	    if(!Bus(busid, bus_uid)) continue;
	    if(IsPlayerInRangeOfPoint(playerid, 5.0, Bus(busid, bus_pos)[ 0 ], Bus(busid, bus_pos)[ 1 ], Bus(busid, bus_pos)[ 2 ]))
			Player(playerid, player_busid) = busid;

	    static strid;
	    strid = GetStreetID(Bus(busid, bus_street));

        if(Player(playerid, player_busid) == busid)
			format(buffer, sizeof buffer, "%s%d\t%s\t%s "red"<-- Jesteś tutaj\n", buffer, Bus(busid, bus_uid), Bus(busid, bus_name), Street(strid, street_name));
		else
 			format(buffer, sizeof buffer, "%s%d\t%s\t%s\n", buffer, Bus(busid, bus_uid), Bus(busid, bus_name), Street(strid, street_name));
	}
	if(isnull(buffer) || !Player(playerid, player_busid)) return ShowInfo(playerid, red"Nie jesteś na żadnym przystanku!");
	if(Bus(Player(playerid, player_busid), bus_uid) != 25 && Bus(Player(playerid, player_busid), bus_uid) != 26)
	{
		new count;
	    foreach(Player, i)
	    {
	        new group = IsPlayerInTypeGroup(i, group_type_taxi);
	        if(!group) continue;
	        if(Player(i, player_duty) != group) continue;

	        count++;
	    }
	    if(count >= 3) return ShowInfo(playerid, red"Nie możesz użyć autobusu, na służbie jest więcej, niż 3 taksówkarzy!");
	}
	Dialog::Output(playerid, 13, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
	return 1;
}
