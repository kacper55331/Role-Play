FuncPub::LoadStation()
{
	new stationid = 1,
		string[ 64 ];
	mysql_query("SELECT * FROM `surv_station`");
	mysql_store_result();
	while(mysql_fetch_row(string))
	{
		if(stationid == MAX_STATION) break;
		
		sscanf(string, "p<|>da<d>[2]a<f>[3]ff",
		    Station(stationid, station_uid),
		    Station(stationid, station_owner),
		    Station(stationid, station_pos),
		    Station(stationid, station_range),
		    Station(stationid, station_fuel)
		);
		stationid++;
	}
	mysql_free_result();
	printf("# Stacje zostały wczytane! | %d", stationid-1);
	return 1;
}

FuncPub::SaveStation(statid)
{
	new string[ 126 ];
	format(string, sizeof string,
		"UPDATE `surv_station` SET `fuel` = '%.2f' WHERE `uid` = '%d'",
		Station(statid, station_fuel),
		Station(statid, station_uid)
	);
	mysql_query(string);
	return 1;
}

stock IsPlayerInStation(playerid)
{
	for(new statid; statid != MAX_STATION; statid++)
	    if(IsPlayerInRangeOfPoint(playerid, Station(statid, station_range), Station(statid, station_pos)[ 0 ], Station(statid, station_pos)[ 1 ], Station(statid, station_pos)[ 2 ]))
	    	return statid;
	return 0;
}

Cmd::Input->tankuj(playerid, params[])
{
	if(IsPlayerInAnyVehicle(playerid))
		return ShowCMD(playerid, "Wyjdź z wozu i stań przy baku.");
	if(GetPVarFloat(playerid, "fuel"))
	    return ShowCMD(playerid, "Tankujesz już jakiś pojazd!");
	new stationid = IsPlayerInStation(playerid);
	if(!stationid)
	    return ShowCMD(playerid, "Nie jesteś na stacji benzynowej.");
	if(!Station(stationid, station_fuel))
	    return ShowCMD(playerid, "Dystrybutory są puste!");
	new vehid = GetClosestCar(playerid);
	if(!vehid)
	    return ShowCMD(playerid, "Nie stoisz przy żadnym pojeździe.");
	if(Vehicle(vehid, vehicle_engine))
	    return ShowCMD(playerid, "Silnik w pojeździe jest odpalony.");

	new string[ 126 ];
	if(Station(stationid, station_owner)[ 0 ] == station_owner_group)
	{
	    format(string, sizeof string,
			"SELECT `v1` FROM `surv_groups` WHERE `uid` = '%d'",
	        Station(stationid, station_owner)[ 1 ]
		);
		mysql_query(string);
		mysql_store_result();
		mysql_fetch_float(Station(stationid, station_value));
		mysql_free_result();
	}
	else Station(stationid, station_value) = 2.0;
	
	new Float:cash = floatstr(params);
	if(!cash)
	{
	    format(string, sizeof string, "Tip: /tankuj [Kwota] "white"Cena za litr wynosi: "green"$"white"%.3f", Station(stationid, station_value));
	    return ShowCMD(playerid, string);
	}
	if(Player(playerid, player_cash) < cash)
	    return ShowCMD(playerid, "Nie masz tyle gotówki!");
	if(cash <= 0)
	    return ShowCMD(playerid, "Kwota nie może być niższa od "green2"$"white"0");
	    
	if(Player(playerid, player_option) & option_me)
	{
 		format(string, sizeof string, "* %s wkłada wąż do baku i tankuje pojazd %s.", NickName(playerid), Vehicle(vehid, vehicle_name));
		serwerme(playerid, string);
	}
	format(string, sizeof string, "Trwa tankowanie pojazdu: ~r~%s", Vehicle(vehid, vehicle_name));
	PlayerTextDrawSetString(playerid, Player(playerid, player_fuel_td)[ 0 ], string);

	PlayerTextDrawSetString(playerid, Player(playerid, player_fuel_td)[ 1 ], "0.00");
	PlayerTextDrawSetString(playerid, Player(playerid, player_fuel_td)[ 2 ], "0");
	
	format(string, sizeof string, "%.2f", Station(stationid, station_value));
	PlayerTextDrawSetString(playerid, Player(playerid, player_fuel_td)[ 3 ], string);
	
	TextDrawShowForPlayer(playerid, Setting(setting_fuel_td)[ 0 ]);
	TextDrawShowForPlayer(playerid, Setting(setting_fuel_td)[ 1 ]);
	TextDrawShowForPlayer(playerid, Setting(setting_fuel_td)[ 2 ]);
	TextDrawShowForPlayer(playerid, Setting(setting_fuel_td)[ 3 ]);
	TextDrawShowForPlayer(playerid, Setting(setting_fuel_td)[ 4 ]);
	TextDrawShowForPlayer(playerid, Setting(setting_fuel_td)[ 5 ]);
	TextDrawShowForPlayer(playerid, Setting(setting_fuel_td)[ 6 ]);
	TextDrawShowForPlayer(playerid, Setting(setting_fuel_td)[ 7 ]);
	PlayerTextDrawShow(playerid, Player(playerid, player_fuel_td)[ 0 ]); // Info
	PlayerTextDrawShow(playerid, Player(playerid, player_fuel_td)[ 1 ]); // Ilość
	PlayerTextDrawShow(playerid, Player(playerid, player_fuel_td)[ 2 ]); // Cena
	PlayerTextDrawShow(playerid, Player(playerid, player_fuel_td)[ 3 ]); // Cena za litr

	ApplyAnimation(playerid, "BD_FIRE", "wash_up", 4.1, 0, 0, 0, 1, 0);
	FreezePlayer(playerid);

    SetPVarFloat(playerid, "fuel-step", floatdiv(cash, Station(stationid, station_value)));
    Player(playerid, player_fuel_timer) = SetTimerEx("Fuel_Timer", timer_time, false, "dddd", playerid, vehid, stationid, playerid);
	return 1;
}

FuncPub::Fuel_Timer(playerid, vehid, statid, victimid)
{
	if(!IsPlayerConnected(playerid))
	    return 1;
	new Float:minus_value = 0.76;
    if(!GetPVarFloat(playerid, "fuel-step"))
    {
		UnFreezePlayer(playerid);
		ApplyAnimation(playerid, "BD_FIRE", "wash_up", 4.1, 0, 0, 0, 0, 100);
		serwerdo(playerid, "* Pojazd zatankowany. *");
		
		GivePlayerMoneyEx(victimid, 0 - (Station(statid, station_value) * GetPVarFloat(playerid, "fuel")), true);
		if(playerid != victimid)
		{
			new Float:pd = Station(statid, station_value);
		    pd /= 10;
		    GivePlayerMoneyEx(playerid, (pd * GetPVarFloat(playerid, "fuel")), true);
		}
		Vehicle(vehid, vehicle_fuel) += GetPVarFloat(playerid, "fuel");
		SaveStation(statid);

		new string[ 80 ];
		if(Station(statid, station_owner)[ 0 ] == station_owner_group)
		{
		    format(string, sizeof string,
				"UPDATE `surv_groups` SET `cash` = `cash` + '%.2f' WHERE `uid` = '%d'",
				Station(statid, station_value) * GetPVarFloat(playerid, "fuel"),
				Station(statid, station_owner)[ 1 ]
			);
		    mysql_query(string);
		}
		
        Player(playerid, player_fuel_timer) = SetTimerEx("Fuel_End", 4000, 0, "d", playerid);
    }
    else if(GetPVarFloat(playerid, "fuel-step") <= minus_value)
    {
	    if(Station(statid, station_fuel) >= GetPVarFloat(playerid, "fuel-step"))
		{
	        new interval = floatval(GetPVarFloat(playerid, "fuel-step")*1000);
	    	Player(playerid, player_fuel_timer) = SetTimerEx("Fuel_Timer", interval, false, "dddd", playerid, vehid, statid, playerid);
	    	SetPVarFloat(playerid, "fuel", GetPVarFloat(playerid, "fuel") + GetPVarFloat(playerid, "fuel-step"));
		    DeletePVar(playerid, "fuel-step");
	    }
		else
		{
	        new interval = floatval(Station(statid, station_fuel)*1000);
	    	Player(playerid, player_fuel_timer) = SetTimerEx("Fuel_Timer", interval, false, "dddd", playerid, vehid, statid, playerid);
	        SetPVarFloat(playerid, "fuel", GetPVarFloat(playerid, "fuel") + Station(statid, station_fuel));
	        DeletePVar(playerid, "fuel-step");
		    ShowInfo(playerid, red"Tankowanie przerwane: brak paliwa w dystrybutorach!");
			Station(statid, station_fuel) = 0;
		}
    }
	else if(GetPVarFloat(playerid, "fuel-step") >= minus_value)
	{
	    if(Station(statid, station_fuel) >= minus_value)
	    {
			Station(statid, station_fuel) -= minus_value;
		    SetPVarFloat(playerid, "fuel-step", floatsub(GetPVarFloat(playerid, "fuel-step"), minus_value)); // floatsub = odejmowanie
	    	SetPVarFloat(playerid, "fuel", GetPVarFloat(playerid, "fuel") + minus_value);
	    	Player(playerid, player_fuel_timer) = SetTimerEx("Fuel_Timer", timer_time, false, "dddd", playerid, vehid, statid, playerid);

	        if(GetPVarFloat(playerid, "fuel") > (GetVehicleMaxFuel(Vehicle(vehid, vehicle_model)) - Vehicle(vehid, vehicle_fuel)))
	        {
	            SetPVarFloat(playerid, "fuel", GetVehicleMaxFuel(Vehicle(vehid, vehicle_model)) - Vehicle(vehid, vehicle_fuel));
	        	DeletePVar(playerid, "fuel-step");
	        }
		}
		else
		{
			Station(statid, station_fuel) = 0;
	    	Player(playerid, player_fuel_timer) = SetTimerEx("Fuel_Timer", timer_time, false, "dddd", playerid, vehid, statid, playerid);
	        SetPVarFloat(playerid, "fuel", GetPVarFloat(playerid, "fuel") + Station(statid, station_fuel));
	        DeletePVar(playerid, "fuel-step");
		    ShowInfo(playerid, red"Tankowanie przerwane: brak paliwa w dystrybutorach!");
		}
    }

    new string[ 126 ];
    format(string, sizeof string, "%.2f", GetPVarFloat(playerid, "fuel"));
    PlayerTextDrawSetString(playerid, Player(playerid, player_fuel_td)[ 1 ], string);

    format(string, sizeof string, "%.2f", Station(statid, station_value) * GetPVarFloat(playerid, "fuel"));
    PlayerTextDrawSetString(playerid, Player(playerid, player_fuel_td)[ 2 ], string);
	return 1;
}

FuncPub::Fuel_End(playerid)
{
	PlayerTextDrawHide(playerid, Player(playerid, player_fuel_td)[ 0 ]);
	PlayerTextDrawHide(playerid, Player(playerid, player_fuel_td)[ 1 ]);
	PlayerTextDrawHide(playerid, Player(playerid, player_fuel_td)[ 2 ]);
	PlayerTextDrawHide(playerid, Player(playerid, player_fuel_td)[ 3 ]);
	TextDrawHideForPlayer(playerid, Setting(setting_fuel_td)[ 0 ]);
	TextDrawHideForPlayer(playerid, Setting(setting_fuel_td)[ 1 ]);
	TextDrawHideForPlayer(playerid, Setting(setting_fuel_td)[ 2 ]);
	TextDrawHideForPlayer(playerid, Setting(setting_fuel_td)[ 3 ]);
	TextDrawHideForPlayer(playerid, Setting(setting_fuel_td)[ 4 ]);
	TextDrawHideForPlayer(playerid, Setting(setting_fuel_td)[ 5 ]);
	TextDrawHideForPlayer(playerid, Setting(setting_fuel_td)[ 6 ]);
	TextDrawHideForPlayer(playerid, Setting(setting_fuel_td)[ 7 ]);
	
	KillTimer(Player(playerid, player_fuel_timer));
	DeletePVar(playerid, "fuel");
	DeletePVar(playerid, "fuel-step");
	return 1;
}
