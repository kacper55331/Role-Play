FuncPub::LoadRadar()
{
	new radid = 1,
	    string[ 64 ];
	mysql_query("SELECT r.uid, r.street, s.limit, r.range, o.X, o.Y, o.Z FROM `surv_radar` r JOIN `surv_objects` o ON r.objectuid = o.uid JOIN `surv_street` s ON r.street = s.uid");
	mysql_store_result();
	while(mysql_fetch_row(string))
	{
	    if(radid == MAX_RADAR) break;
	    
	    sscanf(string, "p<|>ddffa<f>[3]",
	        Radar(radid, radar_uid),
	        Radar(radid, radar_street),
	        Radar(radid, radar_speed),
	        Radar(radid, radar_range),
	        Radar(radid, radar_pos)
		);
	    
	    radid++;
	}
	mysql_free_result();
	printf("# Radary zostały wczytane! | %d", radid-1);
	return 1;
}

FuncPub::CheckRadar(playerid)
{
	for(new radid = 1; radid != MAX_RADAR; radid++)
	{
	    if(Player(playerid, player_mandat) == radid) continue;
		if(GetVehSpeed(Player(playerid, player_veh)) > Radar(radid, radar_speed))
		{
			if(IsPlayerInRangeOfPoint(playerid, Radar(radid, radar_range), Radar(radid, radar_pos)[ 0 ], Radar(radid, radar_pos)[ 1 ], Radar(radid, radar_pos)[ 2 ]))
			{
			    Player(playerid, player_mandat) = radid;
			    SetTimerEx("MandatOff", 5000, false, "d", playerid);
			    //Chat::Output(playerid, -1, "Dostałeś mandat!");
			    FadeColorForPlayer(playerid, 255, 255, 255, 255, 0, 0, 0, 0, 10, 0); // Rozjaśnienie
				Player(playerid, player_dark) = dark_none;
			    break;
			}
		}
	}
	return 1;
}

FuncPub::MandatOff(playerid)
{
    Player(playerid, player_mandat) = 0;
    return 1;
}
