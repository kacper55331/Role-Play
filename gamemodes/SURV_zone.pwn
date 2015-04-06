FuncPub::LoadGangZone()
{
	new string[ 126 ],
	    zone = 1;
	mysql_query("SELECT z.*, g.color FROM `surv_zone` z LEFT JOIN `surv_groups` g ON (z.group_uid = g.uid)");
	mysql_store_result();
	while(mysql_fetch_row(string))
	{
	    if(zone == MAX_ZONES) break;
	    
	    sscanf(string, "p<|>ds[27]da<f>[4]dx",
			Zone(zone, zone_uid),
			Zone(zone, zone_name),
			Zone(zone, zone_group),
			Zone(zone, zone_pos),
			Zone(zone, zone_flag),
			Zone(zone, zone_color)
		);
		
		if(!Zone(zone, zone_color))
			Zone(zone, zone_color) = 0xFFFFFF00;
		
		Zone(zone, zone_id) = GangZoneCreate(Zone(zone, zone_pos)[ 0 ], Zone(zone, zone_pos)[ 1 ], Zone(zone, zone_pos)[ 2 ], Zone(zone, zone_pos)[ 3 ]);
	    zone++;
	}
	mysql_free_result();
	printf("# Strefy zostały wczytane! | %d", zone-1);
	return 1;
}

FuncPub::GetPlayerZone(playerid)
{
	for(new z; z != MAX_ZONES; z++)
	{
	    if(!Zone(z, zone_uid)) continue;

	    if(IsPlayerInArea(playerid, Zone(z, zone_pos)[ 0 ], Zone(z, zone_pos)[ 1 ], Zone(z, zone_pos)[ 2 ], Zone(z, zone_pos)[ 3 ]))
	        return z;
	}
	return 0;
}

FuncPub::ShowPlayerZone(playerid)
{
	if(IsPlayerInTypeGroup(playerid, group_type_gang) || Player(playerid, player_adminlvl))
	{
		for(new z; z != MAX_ZONES; z++)
		{
		    if(!Zone(z, zone_uid)) continue;

			GangZoneHideForPlayer(playerid, Zone(z, zone_id));
			GangZoneShowForPlayer(playerid, Zone(z, zone_id), Zone(z, zone_color));
		}
	}
	return 1;
}

stock IsPlayerInArea(playerid, Float:minx, Float:miny, Float:maxx, Float:maxy)
{
    new Float:x,
		Float:y,
		Float:z;
    GetPlayerPos(playerid, x, y, z);
    if (x > minx && x < maxx && y > miny && y < maxy) return 1;
    return 0;
}

stock IsVehicleInArea(carid, Float:minx, Float:miny, Float:maxx, Float:maxy)
{
    new Float:x,
		Float:y,
		Float:z;
    GetVehiclePosPos(carid, x, y, z);
    if (x > minx && x < maxx && y > miny && y < maxy) return 1;
    return 0;
}

stock GetClosestStreet(playerid)
{
	new street,
		Float:distance;

	GetPlayerPos(playerid, posx, posy, posz);
	for(new strid; strid != MAX_STREET; strid++)
	{
		if(IsPlayerInArea(playerid, Street(strid, street_pos)[ 0 ], Street(strid, street_pos)[ 1 ], Street(strid, street_pos)[ 2 ], Street(strid, street_pos)[ 3 ]))
			return strid;

		new Float:Dist = GetDistanceToPosition(playerid, Street(strid, street_pos)[ 0 ], Street(strid, street_pos)[ 1 ], Street(strid, street_pos)[ 2 ], Street(strid, street_pos)[ 3 ]);
		if((Dist < distance))
		{
			distance = Dist;
			street = strid;
		}
	}
	return street;
}

stock GetDistanceToPosition(playerid, Float:minx, Float:miny, Float:maxx, Float:maxy)
{
	new Float:distance,
		Float:posx,
		Float:posy,
		Float:posz;
	GetPlayerPos(playerid, posx, posy, posz);

	distance = floatsqroot(floatpower(floatabs(floatsub(posx,maxx-minx)),2)+floatpower(floatabs(floatsub(posy,maxy-miny)),2));
	return distance;
}

FuncPub::LoadStreets()
{
	new strid = 1,
	    string[ 64 ];
	mysql_query("SELECT * FROM `surv_street`");
	mysql_store_result();
	while(mysql_fetch_row(string))
	{
	    if(strid == MAX_STREET) break;
	    sscanf(string, "p<|>ds[32]da<f>[4]d",
	        Street(strid, street_uid),
	        Street(strid, street_name),
	        Street(strid, street_limit),
	        Street(strid, street_pos),
	        Street(strid, street_flag)
		);
		strid++;
	}
	mysql_free_result();
	printf("# Ulice zostały wczytane! | %d", strid-1);
	return 1;
}

FuncPub::GetPlayerStreet(playerid)
{
	for(new strid; strid != MAX_STREET; strid++)
	{
	    if(!Street(strid, street_uid)) continue;
	    
		if(IsPlayerInArea(playerid, Street(strid, street_pos)[ 0 ], Street(strid, street_pos)[ 1 ], Street(strid, street_pos)[ 2 ], Street(strid, street_pos)[ 3 ]))
			return strid;
	}
	return 0;
}

stock GetStreetID(streetuid)
{
    for(new strid; strid != MAX_STREET; strid++)
        if(Street(strid, street_uid) == streetuid)
            return strid;
    return 0;
}

FuncPub::CheckStreet(playerid)
{
	if(Player(playerid, player_door_timer)) return 1;
	
	new street = GetPlayerStreet(playerid);
	if(!street)
	{
		PlayerTextDrawHide(playerid, Player(playerid, player_street));
		HideStreetTD(playerid);
		return 1;
	}
	PlayerTextDrawSetString(playerid, Player(playerid, player_street), Street(street, street_name));
	PlayerTextDrawShow(playerid, Player(playerid, player_street));
	Player(playerid, player_streetid) = street;
	
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return HideStreetTD(playerid);
	if(!Street(street, street_limit)) return HideStreetTD(playerid);

	TextDrawShowForPlayer(playerid, Setting(setting_radar)[ 0 ]);
	TextDrawShowForPlayer(playerid, Setting(setting_radar)[ 1 ]);
	TextDrawShowForPlayer(playerid, Setting(setting_radar)[ 2 ]);
	
	new string[ 5 ];
	format(string, sizeof string, "%d", Street(street, street_limit));
	
	if(Street(street, street_limit) >= 100)
	{
		PlayerTextDrawHide(playerid, Player(playerid, player_radar)[ 0 ]);
		PlayerTextDrawSetString(playerid, Player(playerid, player_radar)[ 1 ], string);
		PlayerTextDrawShow(playerid, Player(playerid, player_radar)[ 1 ]);
	}
	else
	{
	    PlayerTextDrawHide(playerid, Player(playerid, player_radar)[ 1 ]);
		PlayerTextDrawSetString(playerid, Player(playerid, player_radar)[ 0 ], string);
		PlayerTextDrawShow(playerid, Player(playerid, player_radar)[ 0 ]);
	}
	return 1;
}

FuncPub::HideStreetTD(playerid)
{
	TextDrawHideForPlayer(playerid, Setting(setting_radar)[ 0 ]);
	TextDrawHideForPlayer(playerid, Setting(setting_radar)[ 1 ]);
	TextDrawHideForPlayer(playerid, Setting(setting_radar)[ 2 ]);
	
	PlayerTextDrawHide(playerid, Player(playerid, player_radar)[ 0 ]);
	PlayerTextDrawHide(playerid, Player(playerid, player_radar)[ 1 ]);
	
	Player(playerid, player_streetid) = 0;
	return 1;
}

FuncPub::LoadGrunt()
{
	new grid = 1,
	    string[ 126 ];
	mysql_query("SELECT * FROM `surv_grunt`");
	mysql_store_result();
	while(mysql_fetch_row(string))
	{
	    if(grid == MAX_GRUNT) break;
	    sscanf(string, "p<|>da<d>[2]a<f>[5]d",
		    Grunt(grid, grunt_uid),
		    Grunt(grid, grunt_owner),
		    Grunt(grid, grunt_pos),
			Grunt(grid, grunt_flag)
		);
/*		new obj[ 4 ];
		new idx = 0;
		new Float:xmin = Grunt(grid, grunt_pos)[ 0 ];
		new Float:ymin = Grunt(grid, grunt_pos)[ 1 ];
		new Float:xmax = Grunt(grid, grunt_pos)[ 2 ];
		new Float:ymax = Grunt(grid, grunt_pos)[ 3 ];
	    new asd = floatround(floatsub(xmax, xmin));
	    new asd3 = floatround(floatsub(ymax, ymin));

		for(new i=0; i<asd/4; i++)
		{
		    obj[ 0 ] = CreateObject(1318, xmin+(i*4), ymin, Grunt(grid, grunt_pos)[ 4 ], 90, 90, 0, 100);
		    obj[ 2 ] = CreateObject(1318, xmax-(i*4), ymax, Grunt(grid, grunt_pos)[ 4 ], -90, -90, 0, 100);
			idx++;
		}
		for(new i=0; i<asd3/4; i++)
		{
		    obj[ 1 ] = CreateObject(1318, xmin, ymin-(i*4), Grunt(grid, grunt_pos)[ 4 ], 90, 0, 0, 100);
		    obj[ 3 ] = CreateObject(1318, xmax, ymax+(i*4), Grunt(grid, grunt_pos)[ 4 ], -90, 0, 0, 100);
		    idx++;
		}
		printf("%d", idx);*/


/*		new Float:xmin = Grunt(grid, grunt_pos)[ 0 ];
		new Float:ymin = Grunt(grid, grunt_pos)[ 1 ];
		new Float:xmax = Grunt(grid, grunt_pos)[ 2 ];
		new Float:ymax = Grunt(grid, grunt_pos)[ 3 ];
		//printf("%f %f %f %f", xmin, ymin, xmax, ymax);
		new objid[ 4 ], idx;

		for(; xmin < xmax; xmin++)
		{
		    if(!(idx%4))
		    {
		    	objid[ 0 ] = CreateObject(1459, xmin, Grunt(grid, grunt_pos)[ 1 ], Grunt(grid, grunt_pos)[ 4 ], 0, 0, 0, 100);
		    	objid[ 1 ] = CreateObject(1459, xmin, Grunt(grid, grunt_pos)[ 3 ], Grunt(grid, grunt_pos)[ 4 ], 0, 0, 0, 100);
			}
			idx++;
	 	}
	 	idx = 0;
		for(; ymin < ymax; ymin++)
		{
		    if(!(idx%4))
		    {
		    	objid[ 2 ] = CreateObject(1459, Grunt(grid, grunt_pos)[ 0 ], ymin, Grunt(grid, grunt_pos)[ 4 ], 0, 0, 90, 100);
		    	objid[ 3 ] = CreateObject(1459, Grunt(grid, grunt_pos)[ 2 ], ymin, Grunt(grid, grunt_pos)[ 4 ], 0, 0, 90, 100);
			}
			idx++;
		}*/
		grid++;
	}
	mysql_free_result();
	printf("# Grunty zostały wczytane! | %d", grid-1);
	return 1;
}

FuncPub::GetPlayerGrunt(playerid)
{
	for(new grid; grid != MAX_GRUNT; grid++)
	{
	    if(!Grunt(grid, grunt_uid)) continue;
	    
		if(IsPlayerInArea(playerid, Grunt(grid, grunt_pos)[ 0 ], Grunt(grid, grunt_pos)[ 1 ], Grunt(grid, grunt_pos)[ 2 ], Grunt(grid, grunt_pos)[ 3 ]))
			return grid;
	}
	return 0;
}

stock GetGruntID(gruntuid)
{
    for(new grid; grid != MAX_GRUNT; grid++)
        if(Grunt(grid, grunt_uid) == gruntuid)
            return grid;
    return 0;
}

stock GetClosestGrunt(playerid)
{
	new grunt,
		Float:distance;

	GetPlayerPos(playerid, posx, posy, posz);
	for(new grid; grid != MAX_GRUNT; grid++)
	{
		if(IsPlayerInArea(playerid, Grunt(grid, grunt_pos)[ 0 ], Grunt(grid, grunt_pos)[ 1 ], Grunt(grid, grunt_pos)[ 2 ], Grunt(grid, grunt_pos)[ 3 ]))
			return grid;

		new Float:Dist = GetDistanceToPosition(playerid, Grunt(grid, grunt_pos)[ 0 ], Grunt(grid, grunt_pos)[ 1 ], Grunt(grid, grunt_pos)[ 2 ], Grunt(grid, grunt_pos)[ 3 ]);
		if((Dist < distance))
		{
			distance = Dist;
			street = strid;
		}
	}
	return grunt;
}
