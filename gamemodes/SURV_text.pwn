FuncPub::LoadPlayerText(playerid, virtualworld)
{
	for(new t; t != MAX_3DTEXT_PLAYER; t++)
	{
	    if(Text(playerid, t, text_textID) == PlayerText3D:INVALID_3DTEXT_ID) continue;

		DeletePlayer3DTextLabel(playerid, Text(playerid, t, text_textID));
		for(new eText:d; d < eText; d++)
		    Text(playerid, t, d) = 0;
		Text(playerid, t, text_textID) = PlayerText3D:INVALID_3DTEXT_ID;
	}

	new string[ 400 ];
	if(virtualworld == 0)
	{
	    // Bus
	    format(string, sizeof string,
			"SELECT surv_bus.uid, surv_bus.name, surv_objects.X, surv_objects.Y, surv_objects.Z, surv_street.name FROM `surv_bus` JOIN `surv_objects` ON surv_bus.objectuid = surv_objects.uid LEFT JOIN `surv_street` ON surv_bus.street = surv_street.uid WHERE surv_objects.door = '%d'",
			virtualworld
		);
		mysql_query(string);
	 	mysql_store_result();
	  	while(mysql_fetch_row_format(string))
		{
		    new textid = 1;
			for(; textid != MAX_3DTEXT_PLAYER; textid++)
			    if(Text(playerid, textid, text_textID) == PlayerText3D:INVALID_3DTEXT_ID)
			        break;
		    if(textid == MAX_3DTEXT_PLAYER) break;
		    
		    static name[ 32 ],
				busStr[ 126 ],
				streetname[ 32 ];
				
	    	sscanf(string, "p<|>ds[32]a<f>[3]s[32]",
	    	    Text(playerid, textid, text_owner)[ 1 ],
	    	    name,
	    	    Text(playerid, textid, text_pos),
	    	    streetname
			);
			Text(playerid, textid, text_owner)[ 0 ] = text_owner_bus;
			
			if(!(DIN(streetname, "NULL")))
				format(busStr, sizeof busStr,
					"Nazwa: "green"%s\n"white"Ulica: "green"%s\n"grey"(( /bus ))",
					name,
					streetname
				);
			else
				format(busStr, sizeof busStr,
					"Nazwa: "green"%s\n"grey"(( /bus ))",
					name
				);

	 		Text(playerid, textid, text_textID) = CreatePlayer3DTextLabel(playerid, busStr, BIALY, Text(playerid, textid, text_pos)[ 0 ], Text(playerid, textid, text_pos)[ 1 ], Text(playerid, textid, text_pos)[ 2 ], 15, .testLOS=1);
		}
		mysql_free_result();
	}
	
	// Plants
    format(string, sizeof string,
		"SELECT surv_plants.uid, surv_plants.progress, surv_objects.X, surv_objects.Y, surv_objects.Z, SQRT(((surv_objects.X - %f)  * (surv_objects.X - %f)) + ((surv_objects.Y - %f) * (surv_objects.Y - %f))) AS dist FROM `surv_plants` JOIN `surv_objects` ON surv_plants.objectuid = surv_objects.uid WHERE surv_objects.door = '%d' ORDER BY dist",
		Player(playerid, player_position)[ 0 ],
		Player(playerid, player_position)[ 0 ],
		Player(playerid, player_position)[ 1 ],
		Player(playerid, player_position)[ 1 ],
		virtualworld
	);
	mysql_query(string);
 	mysql_store_result();
  	while(mysql_fetch_row_format(string))
	{
	    new textid = 1;
		for(; textid != MAX_3DTEXT_PLAYER; textid++)
		    if(Text(playerid, textid, text_textID) == PlayerText3D:INVALID_3DTEXT_ID)
		        break;
	    if(textid == MAX_3DTEXT_PLAYER) break;
	    
	    static plantStr[ 40 ],
	    	Float:progress;
	    
    	sscanf(string, "p<|>dfa<f>[3]",
    	    Text(playerid, textid, text_owner)[ 1 ],
    	    progress,
    	    Text(playerid, textid, text_pos)
		);
		Text(playerid, textid, text_owner)[ 0 ] = text_owner_plant;
		
		if(progress < 100)
			format(plantStr, sizeof plantStr, C_BLUE2"Ukończono: "white"%.1f%%", progress);
		else
		    plantStr = grey"(( /zbierz ))";
		    
	 	Text(playerid, textid, text_textID) = CreatePlayer3DTextLabel(playerid, plantStr, BIALY, Text(playerid, textid, text_pos)[ 0 ], Text(playerid, textid, text_pos)[ 1 ], Text(playerid, textid, text_pos)[ 2 ]+1, 15, .testLOS=1);
	}
	mysql_free_result();
	
	// Reszta
	if(!virtualworld)
	    format(string, sizeof string,
			"SELECT SQRT(((t.X - %f)  * (t.X - %f)) + ((t.Y - %f) * (t.Y - %f))) AS dist, t.* FROM `surv_text` t WHERE t.door = '%d' ORDER BY dist",
			Player(playerid, player_position)[ 0 ],
			Player(playerid, player_position)[ 0 ],
			Player(playerid, player_position)[ 1 ],
			Player(playerid, player_position)[ 1 ],
			virtualworld
		);
	else
	    format(string, sizeof string,
			"SELECT SQRT(((t.X - %f)  * (t.X - %f)) + ((t.Y - %f) * (t.Y - %f))) AS dist, t.* FROM `surv_text` t JOIN `surv_doors` d ON t.door = d.uid WHERE d.in_pos_vw = '%d' ORDER BY dist",
			Player(playerid, player_position)[ 0 ],
			Player(playerid, player_position)[ 0 ],
			Player(playerid, player_position)[ 1 ],
			Player(playerid, player_position)[ 1 ],
			virtualworld
		);
	mysql_query(string);
 	mysql_store_result();
  	while(mysql_fetch_row(string))
	{
	    new textid = 1;
		for(; textid != MAX_3DTEXT_PLAYER; textid++)
		    if(Text(playerid, textid, text_textID) == PlayerText3D:INVALID_3DTEXT_ID)
		        break;
	    if(textid == MAX_3DTEXT_PLAYER) break;
	    
	    static text[ 256 ], Float:dist;
	    
		sscanf(string, "p<|>fda<d>[2]a<f>[3]{d}s[256]",
		    dist,
			Text(playerid, textid, text_uid),
			Text(playerid, textid, text_owner),
			Text(playerid, textid, text_pos),
			text
		);
		decodepl(text);
		char_replace(text, "|", "\n");

 		Text(playerid, textid, text_textID) = CreatePlayer3DTextLabel(playerid, text, BIALY, Text(playerid, textid, text_pos)[ 0 ], Text(playerid, textid, text_pos)[ 1 ], Text(playerid, textid, text_pos)[ 2 ], 15, .testLOS=1);
	}
	mysql_free_result();

	return 1;
}

FuncPub::LoadIcons(playerid)
{
	new index = 1,
		string[ 126 ];
	mysql_query("SELECT * FROM `surv_icons`");
 	mysql_store_result();
	while(mysql_fetch_row(string))
	{
	    if(index == MAX_ICONS) break;

	    static Float:pos[ 3 ],
			style,
			model;
			
	    sscanf(string, "p<|>{d}dda<f>[3]",
	    	model,
	    	style,
			pos
		);
		SetPlayerMapIcon(playerid, index, pos[ 0 ], pos[ 1 ], pos[ 2 ], model, 0, style);

		Player(playerid, player_veh_icon)[ index ] = 1;
		index++;
	}
	mysql_free_result();
	return 1;
}
