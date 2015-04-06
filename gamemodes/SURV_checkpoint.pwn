FuncPub::LoadPlayerRace(playerid, cat)
{
	new string[ 64 ];
	format(string, sizeof string,
		"SELECT * FROM `surv_race` WHERE `cat` = '%d'",
		cat
	);
	mysql_query(string);
	mysql_store_result();
	while(mysql_fetch_row(string))
	{
	    if(Player(playerid, player_race_max) == MAX_CHECK) break;
	    
	    sscanf(string, "p<|>d{d}a<f>[3]",
			Race(playerid, Player(playerid, player_race_max), race_uid),
			Race(playerid, Player(playerid, player_race_max), race_pos)
		);
	    Player(playerid, player_race_max)++;
	}
	mysql_free_result();
	return 1;
}

FuncPub::RandomRace(type, id)
{
	new result,
		string[ 126 ];
	format(string, sizeof string,
		"SELECT `uid` FROM `surv_race_cat` WHERE `ownerType` = '%d' AND `owner` = '%d' ORDER BY RAND() LIMIT 1",
		type,
		id
	);
	mysql_query(string);
	mysql_store_result();
	result = mysql_fetch_int();
	mysql_free_result();
	return result;
}

stock ClearRace(playerid)
{
	for(new x; x != MAX_CHECK; x++)
    	for(new eRace:i; i < eRace; i++)
    		Race(playerid, x, i) = 0;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	new vehid = Player(playerid, player_veh);
	if(vehid == INVALID_VEHICLE_ID) return 1;
	
    Player(playerid, player_race)++;
	PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
    if(Vehicle(vehid, vehicle_owner)[ 0 ] == vehicle_owner_job && Player(playerid, player_job) == Vehicle(vehid, vehicle_owner)[ 1 ])
    {
        if(Player(playerid, player_race) != 1 && Player(playerid, player_race_max) != Player(playerid, player_race))
        {
            new Float:dist, Float:money, race = Player(playerid, player_race);
			dist = Distance3D(Race(playerid, race, race_pos)[ 0 ], Race(playerid, race, race_pos)[ 1 ], Race(playerid, race, race_pos)[ 2 ], Race(playerid, race-1, race_pos)[ 0 ], Race(playerid, race-1, race_pos)[ 1 ], Race(playerid, race-1, race_pos)[ 2 ]);
			money = floatdiv(dist, 100);
			GivePlayerMoneyEx(playerid, money, true);
		}
    }
	if(Player(playerid, player_race_max) == Player(playerid, player_race))
	{
	    ShowCMD(playerid, "Koniec");
	    Player(playerid, player_race) = 0;
	    Player(playerid, player_race_max) = 0;
	    ClearRace(playerid);
	    DisablePlayerRaceCheckpoint(playerid);
	    if(Vehicle(vehid, vehicle_owner)[ 0 ] == vehicle_owner_job)
	    {
	        SetVehicleToRespawn(Vehicle(vehid, vehicle_vehID));
	    }
	}
	else if(Player(playerid, player_race_max) == Player(playerid, player_race)+1)
	{
	    SetPlayerRaceCheckpoint(playerid, 1,
			Race(playerid, Player(playerid, player_race), race_pos)[ 0 ],
			Race(playerid, Player(playerid, player_race), race_pos)[ 1 ],
			Race(playerid, Player(playerid, player_race), race_pos)[ 2 ],
			Race(playerid, Player(playerid, player_race)+1, race_pos)[ 0 ],
			Race(playerid, Player(playerid, player_race)+1, race_pos)[ 1 ],
			Race(playerid, Player(playerid, player_race)+1, race_pos)[ 2 ],
		10);
	}
	else
	{
	    SetPlayerRaceCheckpoint(playerid, 0,
			Race(playerid, Player(playerid, player_race), race_pos)[ 0 ],
			Race(playerid, Player(playerid, player_race), race_pos)[ 1 ],
			Race(playerid, Player(playerid, player_race), race_pos)[ 2 ],
			Race(playerid, Player(playerid, player_race)+1, race_pos)[ 0 ],
			Race(playerid, Player(playerid, player_race)+1, race_pos)[ 1 ],
			Race(playerid, Player(playerid, player_race)+1, race_pos)[ 2 ],
		10);
	}
	return 1;
}

