FuncPub::Group_OnPlayerText(playerid, text[])
{
	#define t_ooc	1
	#define t_ic    2
	new groupid,
		input[ 128 ],
		type;
	if(text[ 0 ] == '!')
	{
		sscanf(text, "'!'ds[128]", groupid, input);
		if(!(0 < groupid <= MAX_GROUPS)) return 1;
		type = t_ic;
	}
	else if(text[ 0 ] == '@')
	{
		sscanf(text, "'@'ds[128]", groupid, input);
		if(!(0 < groupid <= MAX_GROUPS)) return 1;
		if(Group(playerid, groupid, group_option) & group_option_ooc)
		    return Chat::Output(playerid, SZARY, "Czat OOC grupy zablokowany!");
		type = t_ooc;
	}
	if(!Group(playerid, groupid, group_uid)) return 1;
	if(!(Group(playerid, groupid, group_can) & member_can_ooc))
	    return Chat::Output(playerid, SZARY, "Nie masz uprawnień do pisania na czacie OOC i IC grupy!");

	new string[ 128 ];
    foreach(Player, i)
    {
		new g = IsPlayerInUidGroup(i, Group(playerid, groupid, group_uid));
		if(!g) continue;
        if(type == t_ooc)
			format(string, sizeof string,
				"@%d %s (( %s: %s ))",
				g,
				Group(i, g, group_tag),
				NickName(playerid),
				input
			);
		else if(type == t_ic)
			format(string, sizeof string,
				"!%d %s ** %s: %s **",
				g,
				Group(i, g, group_tag),
				NickName(playerid),
				input
			);
		Chat::Output(i, Group(i, g, group_color), string);
	}
	if(type == t_ic)
	{
		format(string, sizeof string, "%s mówi(radio): %s", NickName(playerid), input);
		SendClientMessageEx(14.0, playerid, string, COLOR_FADE1, COLOR_FADE2, COLOR_FADE3, COLOR_FADE4, COLOR_FADE5, true);
	}
	return 1;
}

FuncPub::LoadPlayerGroups(playerid)
{
	new string[ 300 ],
		groupid = 1;
	format(string, sizeof string,
		"SELECT g.*, m.suit, r.name, r.can FROM `surv_groups` g JOIN `surv_members` m ON (m.type = "#member_type_group" AND m.id = g.uid) LEFT JOIN `surv_ranks` r ON (m.rankid = r.uid AND r.group_uid = g.uid) WHERE m.player = '%d'",
		Player(playerid, player_uid)
	);
	mysql_query(string);
	mysql_store_result();
	while(mysql_fetch_row_format(string))
	{
	    if(groupid == MAX_GROUPS) break;
	    
	    sscanf(string, "p<|>ds["#MAX_GROUP_NAME"]s[5]dxd{a<f>[3]ddd}ds[32]d",
			Group(playerid, groupid, group_uid),
			Group(playerid, groupid, group_name),
			Group(playerid, groupid, group_tag),
			Group(playerid, groupid, group_type),
			Group(playerid, groupid, group_color),
			Group(playerid, groupid, group_option),
			Group(playerid, groupid, group_skin),
			Group(playerid, groupid, group_rankname),
			Group(playerid, groupid, group_can)
		);
		if(!Group(playerid, groupid, group_color))
		    Group(playerid, groupid, group_color) = 0xFFFFFFAA;
		    
		new str[ 32 ];
		format(str, sizeof str, "%d_____%s", groupid, Group(playerid, groupid, group_name));
		Group(playerid, groupid, group_text) = CreatePlayerTextDraw(playerid, 96.000000, 133.000000 + (groupid*20.0), str);
		PlayerTextDrawBackgroundColor(playerid, Group(playerid, groupid, group_text), 255);
		PlayerTextDrawFont(playerid, Group(playerid, groupid, group_text), 1);
		PlayerTextDrawLetterSize(playerid, Group(playerid, groupid, group_text), 0.300000, 1.200000);
		PlayerTextDrawColor(playerid, Group(playerid, groupid, group_text), -1);
		PlayerTextDrawSetOutline(playerid, Group(playerid, groupid, group_text), 1);
		PlayerTextDrawSetProportional(playerid, Group(playerid, groupid, group_text), 1);

	    groupid++;
	}
	mysql_free_result();
	return 1;
}

FuncPub::CreateGroup(playerid, type, name[])
{
	new groupuid, rankuid,
		string[ 256 ];
	
	mysql_real_escape_string(name, name);
	format(string, sizeof string,
	    "INSERT INTO `surv_groups` (`name`, `type`) VALUES ('%s', '%d')",
	    name,
		type
	);
	mysql_query(string);
	groupuid = mysql_insert_id();
	
	new rank = 1+2+4+8+16+32+64+128+member_can_panel+member_can_nodel;
	format(string, sizeof string,
	    "INSERT INTO `surv_ranks` VALUES (NULL, '%d', 'Lider', '%d', '0')",
	    groupuid,
	    rank
	);
	mysql_query(string);
	rankuid = mysql_insert_id();
	
	new groupid = AddPlayerToGroup(playerid, groupuid);
	Group(playerid, groupid, group_type) = type;
	Group(playerid, groupid, group_color) = 0xFFFFFFAA;
	format(Group(playerid, groupid, group_name), MAX_GROUP_NAME, name);
	Group(playerid, groupid, group_can) = rank;
	format(Group(playerid, groupid, group_rankname), MAX_GROUP_NAME, "Lider");
	
	format(string, sizeof string,
	    "UPDATE `surv_members` SET `rankid` = '%d' WHERE `player` = '%d' AND `type` = '"#member_type_group"' AND `id` = '%d'",
		rankuid,
		Player(playerid, player_uid),
	    groupuid
	);
	mysql_query(string);
	return groupuid;
}

FuncPub::DeleteGroup(groupuid)
{
	new string[ 126 ];
	format(string, sizeof string,
		"DELETE FROM `surv_groups` WHERE `uid` = '%d'",
		groupuid
	);
	mysql_query(string);
	
	format(string, sizeof string,
	    "DELETE FROM `surv_ranks` WHERE `group_uid` = '%d'",
	    groupuid
	);
	mysql_query(string);
	
	foreach(Player, playerid)
	{
	    static groupid;
	    groupid = IsPlayerInUidGroup(playerid, groupuid);
	    if(groupid)
	    {
			RemovePlayerFromGroup(playerid, groupuid);

	    	// TODO
	    	Chat::Output(playerid, GREEN, "Twoja grupa została skasowana!");
	    }
	}
}

FuncPub::ShowPlayerGroupList(playerid)
{
	new count,
		str[ 64 ];
	for(new groupid; groupid != MAX_GROUPS; groupid++)
	{
	    if(!Group(playerid, groupid, group_uid)) continue;
	    format(str, sizeof str, "%d_____%s", groupid, Group(playerid, groupid, group_name));
	    PlayerTextDrawSetString(playerid, Group(playerid, groupid, group_text), str);
	    PlayerTextDrawShow(playerid, Group(playerid, groupid, group_text));

		TextDrawShowForPlayer(playerid, Setting(setting_group_background)[ groupid ]);
		TextDrawShowForPlayer(playerid, Setting(setting_group_info)[ groupid ]);
		TextDrawShowForPlayer(playerid, Setting(setting_group_veh)[ groupid ]);
		TextDrawShowForPlayer(playerid, Setting(setting_group_online)[ groupid ]);
		TextDrawShowForPlayer(playerid, Setting(setting_group_magazyn)[ groupid ]);

		if(Player(playerid, player_duty) == groupid)
		    TextDrawShowForPlayer(playerid, Setting(setting_group_duty_on)[ groupid ]);
		else
		    TextDrawShowForPlayer(playerid, Setting(setting_group_duty)[ groupid ]);

		count++;
	}
	if(count)
	{
		TextDrawShowForPlayer(playerid, Setting(setting_group_out)[ 0 ]);
		TextDrawShowForPlayer(playerid, Setting(setting_group_out)[ 1 ]);
		
		SelectTextDraw(playerid, 0xFF4040AA);
		SetPVarInt(playerid, "group-show", 1);
		GivePlayerAchiv(playerid, achiv_join);
	}
	else ShowCMD(playerid, "Nie należysz do żadnej grupy!");
	return 1;
}

FuncPub::HidePlayerGroupList(playerid)
{
	for(new groupid; groupid != MAX_GROUPS; groupid++)
	{
	    if(!Group(playerid, groupid, group_uid)) continue;
	    PlayerTextDrawHide(playerid, Group(playerid, groupid, group_text));
		TextDrawHideForPlayer(playerid, Setting(setting_group_out)[ 0 ]);
		TextDrawHideForPlayer(playerid, Setting(setting_group_out)[ 1 ]);
		TextDrawHideForPlayer(playerid, Setting(setting_group_background)[ groupid ]);
		TextDrawHideForPlayer(playerid, Setting(setting_group_info)[ groupid ]);
		TextDrawHideForPlayer(playerid, Setting(setting_group_veh)[ groupid ]);
		TextDrawHideForPlayer(playerid, Setting(setting_group_online)[ groupid ]);
		TextDrawHideForPlayer(playerid, Setting(setting_group_magazyn)[ groupid ]);
		TextDrawHideForPlayer(playerid, Setting(setting_group_duty_on)[ groupid ]);
		TextDrawHideForPlayer(playerid, Setting(setting_group_duty)[ groupid ]);
	}
    DeletePVar(playerid, "group-show");
    CancelSelectTextDraw(playerid);
}

FuncPub::Group_OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(GetPVarInt(playerid, "group-show"))
    {
		new str[ 32 ];
		for(new groupid; groupid != MAX_GROUPS; groupid++)
		{
		    if(!Group(playerid, groupid, group_uid)) continue;

		    format(str, sizeof str, "%d ", groupid);
		    if(Setting(setting_group_info)[ groupid ] == clickedid)
		    {
		        strcat(str, "info");
		        break;
			}
		    else if(Setting(setting_group_veh)[ groupid ] == clickedid)
		    {
		        strcat(str, "v");
		        break;
			}
		    else if(Setting(setting_group_online)[ groupid ] == clickedid)
		    {
		        strcat(str, "online");
		        break;
			}
		    else if(Setting(setting_group_duty_on)[ groupid ] == clickedid || Setting(setting_group_duty)[ groupid ] == clickedid)
			{
		        strcat(str, "duty");
		        break;
			}
			else if(Setting(setting_group_magazyn)[ groupid ] == clickedid)
			{
	            strcat(str, "przebierz");
		        break;
			}
		}
		cmd_g(playerid, str);
		HidePlayerGroupList(playerid);
	}
	return 1;
}

FuncPub::AddPlayerToGroup(playerid, groupuid)
{
	new groupid = 1;
	for(; groupid != MAX_GROUPS; groupid++)
		if(!Group(playerid, groupid, group_uid))
			break;
	if(groupid == MAX_GROUPS)
	{
		ShowInfo(playerid, red"Brak wolnych slotów na grupy.");
		return false;
	}
	
	new string[ 126 ];
	
	format(string, sizeof string,
	    "SELECT `name`, `tag`, `color`, `option` FROM `surv_groups` WHERE `uid` = '%d'",
	    groupuid
	);
	mysql_query(string);
	mysql_store_result();
	mysql_fetch_row(string);
	mysql_free_result();
	sscanf(string, "p<|>s["#MAX_GROUP_NAME"]s[5]dxd",
	    Group(playerid, groupid, group_name),
	    Group(playerid, groupid, group_tag),
	    Group(playerid, groupid, group_type),
	    Group(playerid, groupid, group_color),
	    Group(playerid, groupid, group_option)
	);
	Group(playerid, groupid, group_uid) = groupuid;
	
	format(string, sizeof string,
		"INSERT INTO `surv_members` (`player`, `type`, `id`) VALUES ('%d', '"#member_type_group"', '%d')",
		Player(playerid, player_uid),
		groupuid
	);
	mysql_query(string);
	format(string, sizeof string,
	    "INSERT INTO `surv_members_log` VALUES (NULL, '%d', '%d', UNIX_TIMESTAMP(), '0')",
	    Player(playerid, player_uid),
	    groupuid
	);
	mysql_query(string);

	format(string, sizeof string, "%d_____%s", groupid, Group(playerid, groupid, group_name));
	Group(playerid, groupid, group_text) = CreatePlayerTextDraw(playerid, 96.000000, 133.000000 + (groupid*20.0), string);
	PlayerTextDrawBackgroundColor(playerid, Group(playerid, groupid, group_text), 255);
	PlayerTextDrawFont(playerid, Group(playerid, groupid, group_text), 1);
	PlayerTextDrawLetterSize(playerid, Group(playerid, groupid, group_text), 0.300000, 1.200000);
	PlayerTextDrawColor(playerid, Group(playerid, groupid, group_text), -1);
	PlayerTextDrawSetOutline(playerid, Group(playerid, groupid, group_text), 1);
	PlayerTextDrawSetProportional(playerid, Group(playerid, groupid, group_text), 1);

	return groupid;
}

FuncPub::RemovePlayerFromGroup(playerid, groupuid)
{
	new groupid = IsPlayerInUidGroup(playerid, groupuid);
	if(!groupid) return false;
	
	new string[ 150 ];
	format(string, sizeof string,
		"DELETE FROM `surv_members` WHERE `player` = '%d' AND `type` = "#member_type_group" AND `id` = '%d'",
		Player(playerid, player_uid),
		groupuid
	);
	mysql_query(string);
	format(string, sizeof string,
	    "UPDATE `surv_members_log` SET `end` = 'UNIX_TIMESTAMP' WHERE `player` = '%d' AND `group` = '%d'",
		Player(playerid, player_uid),
		groupuid
	);
	mysql_query(string);
	
	PlayerTextDrawDestroy(playerid, Group(playerid, groupid, group_text));
	
	for(new eGroups:d; d < eGroups; d++)
	    Group(playerid, groupid, d) = 0;
	return true;
}

stock IsPlayerInTypeGroup(playerid, type)
{
	for(new groupid = 1; groupid != MAX_GROUPS; groupid++)
	{
	    if(!Group(playerid, groupid, group_uid)) continue;
	    if(Group(playerid, groupid, group_type) == type)
			return groupid;
	}
	return false;
}

stock IsPlayerInUidGroup(playerid, groupuid)
{
	for(new groupid = 1; groupid != MAX_GROUPS; groupid++)
	{
	    if(!Group(playerid, groupid, group_uid)) continue;
	    if(Group(playerid, groupid, group_uid) == groupuid)
			return groupid;
	}
	return false;
}

stock GiveGroupPoint(groupuid, point, reason[])
{
	new string[ 200 ];
	format(string, sizeof string,
		"UPDATE `surv_groups` SET `points` = `points` + '%d', `tpoints` = `tpoints` + '%d' WHERE `uid` = '%d'",
		point, point,
		groupuid
	);
	mysql_query(string);
	return true;
}

FuncPub::CuffedTimer(playerid)
{
	new victimid = Player(playerid, player_skuty); //
	if(victimid == INVALID_PLAYER_ID) return 1;
    if(!IsPlayerConnected(victimid))
	{
	    Player(playerid, player_skuty) = INVALID_PLAYER_ID;
	    ShowInfo(playerid, red"Gracz przez którego byłeś skuty opuścił serwer!");
		return 1;
	}
	if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
	{
	    GetPlayerPos(victimid, Player(victimid, player_position)[ 0 ], Player(victimid, player_position)[ 1 ], Player(victimid, player_position)[ 2 ]);
	    GetPlayerFacingAngle(victimid, Player(victimid, player_position)[ 3 ]);
	    Player(victimid, player_vw) = GetPlayerVirtualWorld(victimid);
	    Player(victimid, player_int) = GetPlayerInterior(victimid);
	    
	    SetPlayerPosEx(playerid, Player(victimid, player_position)[ 0 ] + 0.2, Player(victimid, player_position)[ 1 ], Player(victimid, player_position)[ 2 ], Player(victimid, player_position)[ 3 ]);
		SetPlayerVirtualWorld(playerid, Player(victimid, player_vw));
		SetPlayerInterior(playerid, Player(victimid, player_int));
	}
	return 1;
}

Cmd::Input->g(playerid, params[])
{
	new groupid,
		str1[ 64 ],
		str2[ 64 ];
	if(sscanf(params, "is[64]S()[64]", groupid, str1, str2))
	{
		if(!GetPVarInt(playerid, "group-show"))
		{
			ShowPlayerGroupList(playerid);
			ShowCMD(playerid, "Tip: /g(rupa) [slot] [info/duty/online/ooc/zapros/wypros/przebierz/wplac/opusc]");
		}
		else HidePlayerGroupList(playerid);
		return 1;
	}
	if(!(0 < groupid <= MAX_GROUPS)) return 1;
	if(!Group(playerid, groupid, group_uid)) return 1;

	if(!strcmp(str1, "info", true))
	{
		new Float:cash, Float:value[ 2 ], points[ 2 ], buffer[ 1024 ], string[ 80 ];
		format(buffer, sizeof buffer,
			"SELECT `cash`, `v1`, `v2`, `points`, `tpoints` FROM `surv_groups` WHERE `uid` = '%d'",
			Group(playerid, groupid, group_uid)
		);
		mysql_query(buffer);
		mysql_store_result();
		mysql_fetch_row(string);
		mysql_free_result();
		sscanf(string, "p<|>fa<f>[2]a<d>[2]", cash, value, points);
		
		format(buffer, sizeof buffer, "Nazwa i UID grupy:\t\t\t%s (%d)\n", Group(playerid, groupid, group_name), Group(playerid, groupid, group_uid));
		format(buffer, sizeof buffer, "%sFlaga:\t\t\t\t\t%d\n", buffer, Group(playerid, groupid, group_option));
		format(buffer, sizeof buffer, "%sKolor:\t\t\t\t\t{%06x}#%x\n", buffer, Group(playerid, groupid, group_color) >>> 8, Group(playerid, groupid, group_color));
		format(buffer, sizeof buffer, "%sWartości:\t\t\t\t%.2f:%.2f\n", buffer, value[ 0 ], value[ 1 ]);
		format(buffer, sizeof buffer, "%sKasa:\t\t\t\t\t"green2"$"white"%.2f\n", buffer, cash);
		format(buffer, sizeof buffer, "%sAktualne Punkty:\t\t\t%d\n", buffer, points[ 0 ]);
		format(buffer, sizeof buffer, "%sRazem Punktów:\t\t\t%d\n", buffer, points[ 1 ]);
		format(buffer, sizeof buffer, "%sTyp grupy:\t\t\t\t%s (%d)\n", buffer, GroupName[ Group(playerid, groupid, group_type) ], Group(playerid, groupid, group_type));
		format(buffer, sizeof buffer, "%sTag:\t\t\t\t\t%s\n", buffer, Group(playerid, groupid, group_tag));
		strcat(buffer, grey"------------------------\n");
		format(buffer, sizeof buffer, "%sCzat OOC:\t\t\t\t%s\n", buffer, YesOrNo(bool:(Group(playerid, groupid, group_option) & group_option_ooc)));
		format(buffer, sizeof buffer, "%sKolorowa nazwa nicku:\t\t\t%s\n", buffer, YesOrNo(bool:(Group(playerid, groupid, group_option) & group_option_color)));
		format(buffer, sizeof buffer, "%sCzat departamentowy:\t\t\t%s\n", buffer, YesOrNo(bool:(Group(playerid, groupid, group_option) & group_option_depar)));
		format(buffer, sizeof buffer, "%sPokazywanie identyfikatora:\t\t%s\n", buffer, YesOrNo(bool:(Group(playerid, groupid, group_option) & group_option_id)));
		format(buffer, sizeof buffer, "%sSłużba w drzwiach:\t\t\t%s\n", buffer, YesOrNo(bool:(Group(playerid, groupid, group_option) & group_option_duty)));
		format(buffer, sizeof buffer, "%sZabieranie przedmiotów:\t\t%s\n", buffer, YesOrNo(bool:(Group(playerid, groupid, group_option) & group_option_take)));
		format(buffer, sizeof buffer, "%sPrzetrzymanie:\t\t\t\t%s\n", buffer, YesOrNo(bool:(Group(playerid, groupid, group_option) & group_option_przet)));
		format(buffer, sizeof buffer, "%sWypłacanie gotówki:\t\t\t%s\n", buffer, YesOrNo(bool:(Group(playerid, groupid, group_option) & group_option_payout)));

		if(!isnull(Group(playerid, groupid, group_rankname)) && !(DIN(Group(playerid, groupid, group_rankname), "NULL")))
		{
			strcat(buffer, grey"------------------------\n");
			format(buffer, sizeof buffer, "%sStanowisko:\t\t\t\t%s\n", buffer, Group(playerid, groupid, group_rankname));
			format(buffer, sizeof buffer, "%sFlaga:\t\t\t\t\t%d\n", buffer, Group(playerid, groupid, group_can));
			format(buffer, sizeof buffer, "%sSkin:\t\t\t\t\t%d\n", buffer, Group(playerid, groupid, group_skin));

		    format(buffer, sizeof buffer, "%sDostęp do pojazdów:\t\t\t%s\n", buffer, YesOrNo(bool:(Group(playerid, groupid, group_can) & member_can_vehicle)));
		    format(buffer, sizeof buffer, "%sDostęp do drzwi:\t\t\t%s\n", buffer, YesOrNo(bool:(Group(playerid, groupid, group_can) & member_can_door)));
		    format(buffer, sizeof buffer, "%s/podaj:\t\t\t\t\t%s\n", buffer, YesOrNo(bool:(Group(playerid, groupid, group_can) & member_can_sell)));
		    format(buffer, sizeof buffer, "%sPrzyjmowanie pracowników:\t\t%s\n", buffer, YesOrNo(bool:(Group(playerid, groupid, group_can) & member_can_added)));
		    format(buffer, sizeof buffer, "%sZamawianie produktów:\t\t\t%s\n", buffer, YesOrNo(bool:(Group(playerid, groupid, group_can) & member_can_product)));
		    format(buffer, sizeof buffer, "%sBramy:\t\t\t\t\t%s\n", buffer, YesOrNo(bool:(Group(playerid, groupid, group_can) & member_can_gate)));
		    format(buffer, sizeof buffer, "%sUstawienia drzwi:\t\t\t%s\n", buffer, YesOrNo(bool:(Group(playerid, groupid, group_can) & member_can_door_opt)));
		    format(buffer, sizeof buffer, "%sPisanie na czacie IC i OOC:\t\t%s\n", buffer, YesOrNo(bool:(Group(playerid, groupid, group_can) & member_can_ooc)));

			if(Group(playerid, groupid, group_can) & member_can_nodel)
			    GivePlayerAchiv(playerid, achiv_lider);
		}
		
		ShowList(playerid, buffer);
	}
	else if(!strcmp(str1, "duty", true) || !strcmp(str1, "sluzba", true))
	{
	    if(Player(playerid, player_duty) && !(Player(playerid, player_duty) == groupid))
	        return ShowInfo(playerid, red"Nie jesteś na służbie w tym slocie!");
	        
		if(Player(playerid, player_duty))
		{
		    new string[ 120 ];
		    format(string, sizeof string,
				"UPDATE `surv_members` SET `duty` = `duty` + '%d' WHERE `player` = '%d' AND (type = "#member_type_group" AND id = '%d')",
				Group(playerid, groupid, group_duty),
				Player(playerid, player_uid),
				Group(playerid, groupid, group_uid)
			);
		    mysql_query(string);
		
		    Group(playerid, groupid, group_duty)	= 0;
		    Player(playerid, player_duty)			= 0;

			if(Player(playerid, player_premium))
			    Player(playerid, player_color) = player_nick_prem;
			else
				Player(playerid, player_color) = player_nick_def;
            UpdatePlayerNick(playerid);
            
		    // End of duty | TODO
		    format(string, sizeof string,
		        "SELECT `duty` FROM `surv_members` WHERE `player` = '%d' AND (type = "#member_type_group" AND id = '%d')",
				Player(playerid, player_uid),
				Group(playerid, groupid, group_uid)
			);
			mysql_query(string);
			mysql_store_result();
			new duty_time = mysql_fetch_int();
			mysql_free_result();
			
			new dateStr[ 32 ];
			ReturnTimeMega(duty_time, dateStr);
			
			format(string, sizeof string,
				"Zszedłeś ze służby! Przepracowałeś już łącznie %s.",
			    dateStr
			);
		    Chat::Output(playerid, Group(playerid, groupid, group_color), string);
		}
		else
		{
			if(Group(playerid, groupid, group_option) & group_option_duty)
			{
				new doorid = GetPlayerDoor(playerid, false);
			    if(!doorid)
			        return ShowInfo(playerid, red"Aby wejść na służbę tej grupy musisz być w drzwiach grupy!");
		    
				if(Door(doorid, door_owner)[ 0 ] == door_type_group)
				{
				    if(Group(playerid, groupid, group_uid) != Door(doorid, door_owner)[ 1 ])
						return ShowInfo(playerid, red"Aby wejść na służbę tej grupy musisz być w drzwiach grupy!");
				}
				else return ShowInfo(playerid, red"Aby wejść na służbę tej grupy musisz być w drzwiach grupy!");
		    }
		    Group(playerid, groupid, group_duty)	= 0;
		    Player(playerid, player_duty)			= groupid;
		    
		    if(Group(playerid, groupid, group_option) & group_option_color && Group(playerid, Player(playerid, player_duty), group_can) & member_can_duty)
		    {
		    	Player(playerid, player_color) = Group(playerid, groupid, group_color);
		    	UpdatePlayerNick(playerid);
		    }
		    // Start duty | TODO
		    Chat::Output(playerid, Group(playerid, groupid, group_color), "Wszedłeś na służbę!");
		}
	}
	else if(!strcmp(str1, "online", true))
	{
	    new buffer[ 1024 ];
	    format(buffer, sizeof buffer, "{%06x}%s (UID: %d)\n", Group(playerid, groupid, group_color) >>> 8, Group(playerid, groupid, group_name), Group(playerid, groupid, group_uid));
        foreach(Player, i)
        {
			new gid = IsPlayerInUidGroup(i, Group(playerid, groupid, group_uid));
            if(!gid) continue;
            
            if(Player(i, player_afktime)[ 0 ] > 5)
            {
                static string[ 45 ];
                ReturnTimeMega(Player(i, player_afktime)[ 0 ], string, sizeof string);
				format(buffer, sizeof buffer, "%s%d\t%s "red"(AFK: %s)\n", buffer, i, NickName(i), string);
			}
			else
			{
			    if(!isnull(Group(i, gid, group_rankname)) && !(DIN(Group(i, gid, group_rankname), "NULL")))
					format(buffer, sizeof buffer, "%s%d%s\t%s(%s)\n", buffer, i, (Player(i, player_duty) == gid) ? ("*") : (""), NickName(i), Group(i, gid, group_rankname));
				else
					format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, i, NickName(i));
			}
		}
		ShowList(playerid, buffer);
	}
	else if(!strcmp(str1, "zapros", true))
	{
        if(!(Group(playerid, groupid, group_can) & member_can_added))
            return ShowInfo(playerid, red"Brak uprawnień!");
            
		new
			victimid;
   		if(sscanf(str2, "u", victimid))
			return ShowCMD(playerid, "Tip: /g(rupa) zapros [ID/Nick]");
		if(!IsPlayerConnected(victimid))
			return NoPlayer(playerid);
		if(victimid == playerid)
		    return ShowCMD(playerid, "Nie możesz zaoferować czegoś sobie!");
        if(IsPlayerInUidGroup(victimid, Group(playerid, groupid, group_uid)))
			return ShowCMD(playerid, "Gracz jest już w Twojej grupie!");
        if(Group(victimid, MAX_GROUPS-1, group_uid))
			return ShowCMD(playerid, "Gracz nie ma wolnych slotów!");
		if(Offer(victimid, offer_active))
		    return ShowCMD(playerid, "Aktualnie ktoś inny oferuje graczowi przysługę.");

		Offer(playerid, offer_type) 		= offer_type_group;
		Offer(playerid, offer_player) 		= victimid;
		Offer(playerid, offer_value)[ 0 ] 	= Group(playerid, groupid, group_uid);
		Offer(playerid, offer_value)[ 1 ] 	= groupid;
		Offer(playerid, offer_active)       = true;
		
		Offer(victimid, offer_type) 		= offer_type_group;
		Offer(victimid, offer_player) 		= playerid;
		Offer(victimid, offer_value)[ 0 ] 	= Group(playerid, groupid, group_uid);
		Offer(victimid, offer_value)[ 1 ] 	= groupid;
		Offer(victimid, offer_active)       = true;
		ShowPlayerOffer(playerid, victimid);
	}
	else if(!strcmp(str1, "wypros", true))
	{
        if(!(Group(playerid, groupid, group_can) & member_can_added))
            return ShowInfo(playerid, red"Brak uprawnień!");
		new
			victimid;
   		if(sscanf(str2, "u", victimid))
			return ShowCMD(playerid, "Tip: /g(rupa) wypros [ID/Nick]");
		if(!IsPlayerConnected(victimid))
			return NoPlayer(playerid);
        if(!IsPlayerInUidGroup(victimid, Group(playerid, groupid, group_uid)))
			return ShowCMD(playerid, "Gracz nie jest w Twojej grupie!");
			
		new succes;
		succes = RemovePlayerFromGroup(victimid, Group(playerid, groupid, group_uid));
 		if(succes)
		{
			SendClientMessage(playerid, GREEN, "Wywaliłeś gracza z grupy.");
			SendClientMessage(victimid, GREEN, "Zostałeś wyrzucony z grupy.");
		}
		else ShowInfo(playerid, red"Wystąpił nieznany błąd!");
	}
	else if(!strcmp(str1, "ooc", true))
	{
        if(!(Group(playerid, groupid, group_can) & member_can_added))
            return ShowInfo(playerid, red"Brak uprawnień!");
            
        new string[ 126 ];
        if(Group(playerid, groupid, group_option) & group_option_ooc)
        {
	        foreach(Player, i)
	        {
				new groupidd = IsPlayerInUidGroup(i, Group(playerid, groupid, group_uid));
	            if(!groupidd) continue;
	            if(!(Group(i, groupidd, group_option) & group_option_ooc)) continue;

            	SendClientMessage(i, GREEN, "Czat OOC grupy włączony!");
            	Group(i, groupidd, group_option) -= group_option_ooc;
			}
			
			format(string, sizeof string,
				"UPDATE `surv_groups` SET `option` = `option` - '"#group_option_ooc"' WHERE `uid` = '%d' AND `option` & "#group_option_ooc"",
				Group(playerid, groupid, group_uid)
			);
			mysql_query(string);
		}
		else
		{
	        foreach(Player, i)
	        {
				new groupidd = IsPlayerInUidGroup(i, Group(playerid, groupid, group_uid));
	            if(!groupidd) continue;
	            if(Group(i, groupidd, group_option) & group_option_ooc) continue;
	            
            	SendClientMessage(i, GREEN, "Czat OOC grupy wyłączony!");
		    	Group(i, groupidd, group_option) += group_option_ooc;
			}
			
			format(string, sizeof string,
				"UPDATE `surv_groups` SET `option` = `option` + '"#group_option_ooc"' WHERE `uid` = '%d' AND !(`option` & "#group_option_ooc")",
				Group(playerid, groupid, group_uid)
			);
			mysql_query(string);
		}
	}
	else if(!strcmp(str1, "v", true) || !strcmp(str1, "pojazdy", true))
	{
        if(!(Group(playerid, groupid, group_can) & member_can_vehicle))
            return ShowInfo(playerid, red"Brak uprawnień!");
            
		new string[ 150 ],
			buffer[ 1024 ];
		format(string, sizeof string,
			"SELECT `uid`, `model`, `name`, `spawned` FROM `surv_vehicles` WHERE ownerType = "#vehicle_owner_group" AND owner = '%d'",
			Group(playerid, groupid, group_uid)
		);
	    mysql_query(string);
	    mysql_store_result();
		while(mysql_fetch_row(string))
		{
			static uid,
				model,
				name[ 64 ],
				spawn;
				
			sscanf(string, "p<|>dds[64]d",
				uid,
				model,
				name,
				spawn
			);
			if(!(400 <= model <= 611)) continue;
			if(spawn)
				format(buffer, sizeof buffer, "%s"gui_active"%d\t%s\n", buffer, uid, name);
			else
				format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, uid, name);
		}
		mysql_free_result();
		if(isnull(buffer)) ShowInfo(playerid, red"W grupie nie ma żadnych pojazdów!");
		else
		{
		    format(buffer, sizeof buffer, "UID:\tNazwa:\n%s", buffer);
			Dialog::Output(playerid, 37, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
		}
	}
	else if(!strcmp(str1, "respawn", true))
	{
        if(!(Group(playerid, groupid, group_can) & member_can_added))
            return ShowInfo(playerid, red"Brak uprawnień!");
        new UsedVeh[ MAX_VEHICLES ] = {false, ...},
			iTrailer[ MAX_VEHICLES ] = {false, ...},
			count = 0;
		foreach(Player, i)
		{
            if(!Player(i, player_spawned) || !Player(i, player_logged))
				continue;
		    if(Player(i, player_veh) == INVALID_VEHICLE_ID)
				continue;

		    UsedVeh[Player(i, player_veh)] = true;
		    if(IsTrailerAttachedToVehicle(Player(i, player_veh)) == 1)
		        iTrailer[Player(i, player_veh)] = true;
        }
        for(new i = 1; i != MAX_VEHICLES; i++)
	 	{
	 	    if(Vehicle(i, vehicle_owner)[ 0 ] != vehicle_owner_group)
			 	continue;
			if(Vehicle(i, vehicle_owner)[ 1 ] != Group(playerid, groupid, group_uid))
			    continue;
		    if(!Vehicle(i, vehicle_uid))
				continue;
		    if(Vehicle(i, vehicle_vehID) == INVALID_VEHICLE_ID)
				continue;
		    if(!UsedVeh[ i ] && !iTrailer[ i ])
	        {
	            SetVehicleToRespawn(Vehicle(i, vehicle_vehID));
/*	            new uid = Vehicle(i, vehicle_uid);
			    UnSpawnVeh(i);
			    LoadVehicleEx(uid);*/
			}
			count++;
		}
		if(!count) ShowCMD(playerid, "W tej grupie nie ma pojazdów!");
		else ShowCMD(playerid, "Pojazdy grupy zespawnowane!");
	}
	else if(!strcmp(str1, "wplac", true) || !strcmp(str1, "wpłać", true))
	{
		new Float:cash;
   		if(sscanf(str2, "f", cash))
			return ShowCMD(playerid, "Tip: /g(rupa) [slot] wplac [Kwota]");
		if(cash > Player(playerid, player_cash))
			return ShowCMD(playerid, "Nie posiadasz tyle gotówki");
		if(cash <= 0)
		    return ShowCMD(playerid, "Kwota nie może być niższa od 0.");

		new string[ 126 ];
		format(string, sizeof string,
			"UPDATE `surv_groups` SET `cash` = `cash` + '%.2f' WHERE `uid` = '%d'",
			cash,
			Group(playerid, groupid, group_uid)
		);
		mysql_query(string);
		
		format(string, sizeof string,
			"INSERT INTO `surv_groups_log` VALUES (NULL, '%d', '%d', '0', UNIX_TIMESTAMP(), '%.2f', 'Wplata')",
			Group(playerid, groupid, group_uid),
			Player(playerid, player_uid),
			cash
		);
		mysql_query(string);
		
		GivePlayerMoneyEx(playerid, 0 - cash, true);
		format(string, sizeof string, "Wpłaciłeś $%.2f na konto grupy", cash);
		ShowCMD(playerid, string);
	}
	else if(!strcmp(str1, "wyplac", true) || !strcmp(str1, "wypłać", true))
	{
        if(!(Group(playerid, groupid, group_can) & member_can_added))
            return ShowInfo(playerid, red"Brak uprawnień!");
            
		new Float:gcash,
			string[ 126 ];
		format(string, sizeof string,
			"SELECT `cash` FROM `surv_groups` WHERE `uid` = '%d'",
		    Group(playerid, groupid, group_uid)
		);
		mysql_query(string);
		mysql_store_result();
		mysql_fetch_float(gcash);
		mysql_free_result();
		
		new Float:cash;
   		if(sscanf(str2, "f", cash))
			return ShowCMD(playerid, "Tip: /g(rupa) [slot] wyplac [Kwota]");
		if(cash > gcash)
			return ShowCMD(playerid, "Grupa nie posiada tyle gotówki.");
		if(cash <= 0)
		    return ShowCMD(playerid, "Kwota nie może być niższa od $0.");

		format(string, sizeof string,
			"UPDATE `surv_groups` SET `cash` = `cash` - '%.2f' WHERE `uid` = '%d'",
			cash,
			Group(playerid, groupid, group_uid)
		);
		mysql_query(string);
		
		format(string, sizeof string,
			"INSERT INTO `surv_groups_log` VALUES (NULL, '%d', '%d', '0', UNIX_TIMESTAMP(), '-%.2f', 'Wyplata')",
			Group(playerid, groupid, group_uid),
			Player(playerid, player_uid),
			cash
		);
		mysql_query(string);

		GivePlayerMoneyEx(playerid, cash, true);
		format(string, sizeof string, "Wypłaciłeś $%.2f z konto grupy. Zostało: $%.2f", cash, gcash-cash);
		ShowCMD(playerid, string);
	}
	else if(!strcmp(str1, "przebierz", true))
	{
	    if(!Group(playerid, groupid, group_skin))
	        return ShowInfo(playerid, red"Lider grupy nie ustawił Ci skina!");

		SetPlayerSkin(playerid, Group(playerid, groupid, group_skin));
	}
	else if(!strcmp(str1, "opusc", true) || !strcmp(str1, "opuść", true))
	{
	    RemovePlayerFromGroup(playerid, Group(playerid, groupid, group_uid));
	    ShowCMD(playerid, "Opuściłeś grupę.");
	}
	else ShowCMD(playerid, "Tip: /g(rupa) [slot] [info/duty/online/ooc/zapros/wypros/przebierz/wplac/opusc]");
	return 1;
}

Cmd::Input->grupa(playerid, params[]) return cmd_g(playerid, params);

Cmd::Input->skuj(playerid, params[])
{
	if(!HavePlayerItem(playerid, item_kajdanki))
	    return ShowInfo(playerid, red"Nie posiadasz kajdanek!");

	new victimid;
	if(sscanf(params, "d", victimid))
		return ShowCMD(playerid, "Tip: /skuj [ID/Nick]");
	if(victimid == playerid)
		return ShowCMD(playerid, "Nie możesz sam siebie skuć!");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);
	if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
		return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");

	if(Player(victimid, player_skuty) == INVALID_PLAYER_ID)
	{
	    Player(victimid, player_skuty) = playerid;

	    if(Player(playerid, player_option) & option_me)
	    {
	        new string[ 15 + MAX_PLAYER_NAME + MAX_PLAYER_NAME ];
	    	format(string, sizeof string, "* %s skuł %s.", NickName(playerid), NickName(victimid));
			serwerme(playerid, string);
	    }
	    SetPlayerSpecialAction(victimid, SPECIAL_ACTION_CUFFED);
	    SetPlayerAttachedObject(victimid, 0, 19418, 6, -0.011000, 0.028000, -0.022000, -15.600012, -33.699977, -81.700035, 0.891999, 1.000000, 1.168000);
	}
	else
	{
	    if(Player(victimid, player_skuty) != playerid)
			return ShowInfo(playerid, red"Ten gracz jest skuty przez inną osobę.");

	    Player(victimid, player_skuty) = INVALID_PLAYER_ID;

	    if(Player(playerid, player_option) & option_me)
	    {
	        new string[ 15 + MAX_PLAYER_NAME + MAX_PLAYER_NAME ];
	    	format(string, sizeof string, "* %s rozkuł %s.", NickName(playerid), NickName(victimid));
			serwerme(playerid, string);
	    }
	    SetPlayerSpecialAction(victimid, SPECIAL_ACTION_NONE);
		RemovePlayerAttachedObject(victimid, 0);
	}
	UpdatePlayerNick(victimid);
	return 1;
}
Cmd::Input->lina(playerid, params[]) return cmd_skuj(playerid, params);
Cmd::Input->zwiaz(playerid, params[]) return cmd_skuj(playerid, params);
Cmd::Input->rozkuj(playerid, params[]) return cmd_skuj(playerid, params);

Cmd::Input->knebluj(playerid, params[])
{
	if(!HavePlayerItem(playerid, item_knebel))
	    return ShowInfo(playerid, red"Nie posiadasz knebla!");
	    
	new victimid;
	if(sscanf(params, "d", victimid))
		return ShowCMD(playerid, "Tip: /knebluj [ID/Nick]");
	if(victimid == playerid)
		return ShowCMD(playerid, "Nie możesz sam siebie zakneblować!");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);
	if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
		return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");

	Player(victimid, player_knebel) = !Player(victimid, player_knebel);
	if(Player(victimid, player_knebel))
	{
	    if(Player(playerid, player_option) & option_me)
	    {
	        new string[ 20 + MAX_PLAYER_NAME + MAX_PLAYER_NAME ];
	    	format(string, sizeof string, "* %s zakneblował %s.", NickName(playerid), NickName(victimid));
			serwerme(playerid, string);
	    }
	}
	else
	{
	    if(Player(playerid, player_option) & option_me)
	    {
	        new string[ 20 + MAX_PLAYER_NAME + MAX_PLAYER_NAME ];
	    	format(string, sizeof string, "* %s odkneblował %s.", NickName(playerid), NickName(victimid)); //TODO
			serwerme(playerid, string);
	    }
	}
	UpdatePlayerNick(victimid);
	return 1;
}

Cmd::Input->worek(playerid, params[])
{
	if(!HavePlayerItem(playerid, item_worek))
	    return ShowInfo(playerid, red"Nie posiadasz knebla!");

	new victimid;
	if(sscanf(params, "d", victimid))
		return ShowCMD(playerid, "Tip: /worek [ID/Nick]");
	if(victimid == playerid)
		return ShowCMD(playerid, "Nie możesz sam sobie założyć worka na głowę!");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);
	if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
		return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");

	Player(victimid, player_worek) = !Player(victimid, player_worek);
	if(Player(victimid, player_worek))
	{
	    if(Player(playerid, player_option) & option_me)
	    {
	        new string[ 64 + MAX_PLAYER_NAME ];
	    	format(string, sizeof string, "* %s założył worek na głowe %s.", NickName(playerid), NickName(victimid));
			serwerme(playerid, string);
	    }
	    TextDrawShowForPlayer(victimid, Setting(setting_black));
	    TogglePlayerSpectating(victimid, true);

	}
	else
	{
	    if(Player(playerid, player_option) & option_me)
	    {
	        new string[ 64 + MAX_PLAYER_NAME ];
	    	format(string, sizeof string, "* %s zdjął worek z głowy %s.", NickName(playerid), NickName(victimid));
			serwerme(playerid, string);
	    }
	    TextDrawHideForPlayer(victimid, Setting(setting_black));
	    SetCameraBehindPlayer(victimid);
	}
	UpdatePlayerNick(victimid);
	return 1;
}

Cmd::Input->tatuaz(playerid, params[])
{
	if(!(IsPlayerInTypeGroup(playerid, group_type_gang) || IsPlayerInTypeGroup(playerid, group_type_mafia) || IsPlayerInTypeGroup(playerid, group_type_pd)))
 		return ShowCMD(playerid, "Nie jesteś w odpowiedniej grupie!");
	new victimid;
	if(sscanf(params, "u", victimid))
		return ShowCMD(playerid, "Tip: /tatuaz [ID/Nick]");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);
	if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
		return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");
		
	new buffer[ 70 ], string[ 512 ];
	format(buffer, sizeof buffer,
	    "SELECT `uid`, `tresc` FROM `surv_tatoo` WHERE `player` = '%d'",
	    Player(victimid, player_uid)
	);
	mysql_query(buffer);
	mysql_store_result();
	while(mysql_fetch_row(buffer))
	{
	    static uid, tresc[ 32 ];
	    sscanf(buffer, "p<|>ds[32]",
		    uid,
		    tresc
		);
	    format(string, sizeof string, "%s%d\t%s\n", string, uid, tresc);
	}
	mysql_free_result();
	if(isnull(string)) ShowInfo(playerid, red"Gracz nie posiada tatuaży!");
	else ShowList(playerid, string);
	return 1;
}

Cmd::Input->ulecz(playerid, params[]) return cmd_reanimuj(playerid, params);
Cmd::Input->reanimuj(playerid, params[])
{
	if(!(IsPlayerInTypeGroup(playerid, group_type_fd) || IsPlayerInTypeGroup(playerid, group_type_mc)))
		return 1;
	new victimid;
	if(sscanf(params, "u", victimid)) return ShowCMD(playerid, "Tip: /reanimuj [ID/Nick]");
	if(victimid == INVALID_PLAYER_ID) return NoPlayer(playerid);
	if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid)) return SendClientMessage(playerid, SZARY, "Gracz nie znajduje się w pobliżu.");

	if(Player(victimid, player_bw))
	{
	    UnBW(victimid);
	    SetPlayerHealth(victimid, Player(victimid, player_hp) = 10.0);
	    SetPlayerDrunkLevel(victimid, Player(victimid, player_drunklvl) = 0);
	}
	else GivePlayerHealthEx(victimid, 30.0, true);
	return 1;
}

Cmd::Input->d(playerid, params[])
{
	new gid = Player(playerid, player_duty);
	if(!gid)
	    return ShowInfo(playerid, red"Nie jesteś na duty żadnej grupy!");
    if(!(Group(playerid, gid, group_option) & group_option_depar))
        return ShowInfo(playerid, red"Twoja grupa nie ma dostępnej tej opcji!");
    if(isnull(params))
        return ShowCMD(playerid, "Tip: /d [Treść]");
    
	new string[ 128 ];
    if(!isnull(Group(playerid, gid, group_rankname)) && !(DIN(Group(playerid, gid, group_rankname), "NULL")))
		format(string, sizeof string, "** [%s] %s %s: %s **", Group(playerid, gid, group_tag), Group(playerid, gid, group_rankname), NickName(playerid), params);
	else
		format(string, sizeof string, "** [%s] %s: %s **", Group(playerid, gid, group_tag), NickName(playerid), params);

	foreach(Player, i)
	{
	    if(!Player(i, player_duty)) continue;
	    if(!(Group(i, Player(i, player_duty), group_option) & group_option_depar)) continue;
	    
	    Chat::Output(i, 0xd9534fFF, string);
	}
	format(string, sizeof string, "%s mówi(radio): %s", NickName(playerid), params);
	SendClientMessageEx(14.0, playerid, string, COLOR_FADE1, COLOR_FADE2, COLOR_FADE3, COLOR_FADE4, COLOR_FADE5, true);

	return 1;
}

Cmd::Input->przeszukaj(playerid, params[])
{
	if(!(IsPlayerInTypeGroup(playerid, group_type_pd) || IsPlayerInTypeGroup(playerid, group_type_mafia) || IsPlayerInTypeGroup(playerid, group_type_gang)))
		return 1;
	new victimid;
	if(sscanf(params, "u", victimid)) return ShowCMD(playerid, "Tip: /przeszukaj [ID/Nick]");
	if(victimid == INVALID_PLAYER_ID) return NoPlayer(playerid);
	if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid)) return SendClientMessage(playerid, SZARY, "Gracz nie znajduje się w pobliżu.");

	new buffer[ 1024 ], string[ 126 ];
	format(buffer, sizeof buffer, "Gotówka:\t$%.2f\n", Player(victimid, player_cash));
	strcat(buffer, "---[Przedmioty]---\n");
	
	format(string, sizeof string,
		"SELECT `uid`, `name`, `used` FROM `surv_items` WHERE `ownerType` = '"#item_place_player"' AND `owner` = '%d'",
		Player(victimid, player_uid));
	mysql_query(string);
	mysql_store_result();
	while(mysql_fetch_row(string))
	{
	    static uid,
			name[ MAX_ITEM_NAME ],
	   		use,
	   		used[ 10 ];

		sscanf(string, "p<|>ds[24]d",
			uid,
			name,
			use
		);

		if(use == 1) used = C_GREEN;
		else used = "";

		format(buffer, sizeof buffer, "%s%s%d\t%s\n", buffer, used, uid, name);
	}
	mysql_free_result();
	ShowList(playerid, buffer);
	return 1;
}

Cmd::Input->aresztuj(playerid, params[])
{
	if(!IsPlayerInTypeGroup(playerid, group_type_pd))
		return 1;
	new doorid = GetPlayerDoor(playerid, false);
	if(!doorid)
		return ShowInfo(playerid, red"Nie stoisz przy żadnych drzwiach!");

	new victimid,
		reason[ 64 ],
		endtime,
		type;
	if(sscanf(params, "udcs[64]", victimid, endtime, type, reason))
		return ShowCMD(playerid, "Tip: /aresztuj [ID/Nick] [Czas] [Typ(d,h,m)] [Powód]");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);
	if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
		return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");

	new string[ 256 ],
		stringTime[ 32 ];

	GetPlayerPos(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]);
	GetPlayerFacingAngle(playerid, Player(playerid, player_position)[ 3 ]);
	Player(playerid, player_vw) = GetPlayerVirtualWorld(playerid);
	Player(playerid, player_int) = GetPlayerInterior(playerid);

	format(string, sizeof string,
	    "SELECT SQRT(((j.out_x - %f)  * (j.out_x - %f)) + ((j.out_y - %f) * (j.out_y - %f))) AS dist, j.uid, j.in_x, j.in_y, j.in_z FROM `surv_jail` j WHERE j.door_uid = '%d' ORDER BY dist",
        Player(playerid, player_position)[ 0 ],
        Player(playerid, player_position)[ 0 ],
        Player(playerid, player_position)[ 1 ],
        Player(playerid, player_position)[ 1 ],
	    Door(doorid, door_uid)
	);
	mysql_query(string);
	mysql_store_result();
	mysql_fetch_row(string);
	new Float:in_pos[ 3 ], jail_uid, Float:dist;
	sscanf(string, "p<|>fda<f>[3]", dist, jail_uid, in_pos);
	mysql_free_result();
	
	if(dist > 5.0)
	    return ShowInfo(playerid, red"Nie jesteś przy celi.");
	
	switch(tolower(type))
	{
		case 'd':
		{
			format(stringTime, sizeof stringTime, "%d %s", endtime, dli(endtime, "dzień", "dni", "dni"));
			endtime *= 86400;
		}
		case 'g', 'h':
		{
			format(stringTime, sizeof stringTime, "%d %s", endtime, dli(endtime, "godzine", "godziny", "godzin"));
			endtime *= 3600;
		}
		case 'm':
		{
			format(stringTime, sizeof stringTime, "%d %s", endtime, dli(endtime, "minute", "minuty", "minut"));
			endtime *= 60;
		}
		default:
			return ShowInfo(playerid, kom"Typy kar:\nd - dni\nh - godziny\nm - minuty");
	}
	format(string, sizeof string, "Zostałeś uwięziony na %s przez %s. Powód: %s", stringTime, NickName(playerid), reason);
	ShowCMD(victimid, string);
	
	format(string, sizeof string, "Gracz %s został uwięziony na %s. Powód: %s", NickName(victimid), stringTime, reason);
	ShowCMD(playerid, string);
	
	Player(victimid, player_jail) = gettime() + endtime;
	format(string, sizeof string,
	    "UPDATE `surv_players` SET `jail` = '%d' WHERE `uid` = '%d'",
	    Player(victimid, player_jail),
	    Player(victimid, player_uid)
	);
	mysql_query(string);
	
	AddToKartoteka(playerid, pc_user_none, pd_jail, select_char, Player(victimid, player_uid), NickSamp(victimid), reason, endtime, 0);
	
	SetPlayerPosEx(victimid, in_pos[ 0 ], in_pos[ 1 ], in_pos[ 2 ]);
	GivePlayerAchiv(victimid, achiv_jail);
	
	if(Player(victimid, player_jail_timer))
		KillTimer(Player(victimid, player_jail_timer));
	
	if((Player(victimid, player_jail) - gettime()) < (24 * 60 * 60))
        Player(victimid, player_jail_timer) = SetTimerEx("Un_Jail", (Player(victimid, player_jail) - gettime()) * 1000, false, "dd", victimid, jail_uid);
	return 1;
}
Cmd::Input->blokada(playerid, params[])
{
	if(!(IsPlayerInTypeGroup(playerid, group_type_pd) || IsPlayerInTypeGroup(playerid, group_type_mc) || IsPlayerInTypeGroup(playerid, group_type_fd)))
		return 1;

	new slot, type;
	if(sscanf(params, "dd", slot, type))
	    return ShowCMD(playerid, "Tip: /blokada [Slot 1-"#MAX_BLOKADA"] [Type]");
	if(slot <= 0 || slot >= MAX_BLOKADA)
	    return ShowCMD(playerid, "Nieprawidłowy slot.");
	if(IsPlayerInAnyVehicle(playerid))
		return ShowCMD(playerid, "Nie możesz użyć tej komendy w pojeździe!");
	if(type <= 0 || type >= sizeof Blockades)
	    return ShowCMD(playerid, "Nieprawidłowy typ.");

	if(IsValidDynamicObject(Player(playerid, player_blockade)[ slot ]))
	{
		DestroyDynamicObject(Player(playerid, player_blockade)[ slot ]);
		GameTextForPlayer(playerid, "~y~Blokada usunieta", 3000, 3);
		return 1;
	}
	new Float:PosX, Float:PosY, Float:PosZ, Float:PosA;

	GetPlayerPos(playerid, PosX, PosY, PosZ);
	GetPlayerFacingAngle(playerid, PosA);

	GetXYInFrontOfPlayer(playerid, PosX, PosY, 3.0);
	Player(playerid, player_blockade)[ slot ] = CreateDynamicObject(Blockades[ type ], PosX, PosY, PosZ - 0.5, 0.0, 0.0, PosA, Player(playerid, player_vw));

	Streamer_Update(playerid);

	GameTextForPlayer(playerid, "~y~Blokada postawiona", 3000, 3);
	return 1;
}

Cmd::Input->blokuj(playerid, params[])
{
	if(!IsPlayerInTypeGroup(playerid, group_type_pd))
		return 1;
	new vehid = GetClosestCar(playerid, 5.0);

	if(vehid == INVALID_VEHICLE_ID)
		return GameTextForPlayer(playerid, "~r~Nie znajdujesz sie w poblizu zadnego pojazdu", 3000, 3);

	new Float:price,
		reason[ 64 ];
	if(sscanf(params, "fs[64]", price, reason))
	    return ShowCMD(playerid, "Tip: /blokada [Kwota] [Powód]");
	if(price <= 0)
	    return ShowCMD(playerid, "Kwota nie może być niższa od "green2"$"white"0");

	new string[ 350 ];
	EscapePL(reason);
	mysql_real_escape_string(reason, reason);
	
	Vehicle(vehid, vehicle_block) = price;
	format(Vehicle(vehid, vehicle_block_reason), 64, reason);
	GetVehiclePos(Vehicle(vehid, vehicle_vehID), Vehicle(vehid, vehicle_position)[ 0 ], Vehicle(vehid, vehicle_position)[ 1 ], Vehicle(vehid, vehicle_position)[ 2 ]);
	GetVehicleZAngle(Vehicle(vehid, vehicle_vehID), Vehicle(vehid, vehicle_position)[ 3 ]);

	format(string, sizeof string,
	    "UPDATE `surv_vehicles` SET `x` = '%f', `y` = '%f', `z` = '%f', `a` = '%f', `int` = '%d', `vw` = '%d', `block` = '%.2f', `block_reason` = '%s' WHERE `uid` = '%d'",
		Vehicle(vehid, vehicle_position)[ 0 ],
		Vehicle(vehid, vehicle_position)[ 1 ],
		Vehicle(vehid, vehicle_position)[ 2 ],
		Vehicle(vehid, vehicle_position)[ 3 ],
		Vehicle(vehid, vehicle_int),
		Vehicle(vehid, vehicle_vw),
	    Vehicle(vehid, vehicle_block),
	    Vehicle(vehid, vehicle_block_reason),
	    Vehicle(vehid, vehicle_uid)
	);
	mysql_query(string);
	if(IsTrailerAttachedToVehicle(Vehicle(vehid, vehicle_vehID)))
	{
		vehid = GetVehicleTrailer(Vehicle(vehid, vehicle_vehID));
		GetVehiclePos(Vehicle(vehid, vehicle_vehID), Vehicle(vehid, vehicle_position)[ 0 ], Vehicle(vehid, vehicle_position)[ 1 ], Vehicle(vehid, vehicle_position)[ 2 ]);
		GetVehicleZAngle(Vehicle(vehid, vehicle_vehID), Vehicle(vehid, vehicle_position)[ 3 ]);
		format(string, sizeof string,
			"UPDATE `surv_vehicles` SET `x` = '%f', `y` = '%f', `z` = '%f', `a` = '%f', `int` = '%d', `vw` = '%d' WHERE `uid` = '%d'",
			Vehicle(vehid, vehicle_position)[ 0 ],
			Vehicle(vehid, vehicle_position)[ 1 ],
			Vehicle(vehid, vehicle_position)[ 2 ],
			Vehicle(vehid, vehicle_position)[ 3 ],
			Vehicle(vehid, vehicle_int),
			Vehicle(vehid, vehicle_vw),
			Vehicle(vehid, vehicle_uid)
		);
		mysql_query(string);
	}
	
	AddToKartoteka(playerid, pc_user_pd, pd_block, select_veh, Vehicle(vehid, vehicle_uid), Vehicle(vehid, vehicle_plate), reason, 0, price);
	
	format(string, sizeof string,
		"Blokada na koło nałożona. Kwota: $%.2f. Powód: %s",
	    Vehicle(vehid, vehicle_block),
	    Vehicle(vehid, vehicle_block_reason)
	);
	ShowCMD(playerid, string);
	return 1;
}

Cmd::Input->pokaz(playerid, params[])
{
	new victimid, sub[ 32 ];
	if(sscanf(params, "us[32]", victimid, sub)) return ShowCMD(playerid, "Tip: /pokaz [ID/Nick] [przedmioty/id]");
	if(victimid == INVALID_PLAYER_ID) return NoPlayer(playerid);
	if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid)) return SendClientMessage(playerid, SZARY, "Gracz nie znajduje się w pobliżu.");

	if(!strcmp(sub, "przedmioty", true) || !strcmp(sub, "przedmiot", true))
	{
		new buffer[ 1024 ], string[ 126 ];
		format(string, sizeof string,
			"SELECT `uid`, `name`, `used` FROM `surv_items` WHERE `ownerType` = '"#item_place_player"' AND `owner` = '%d'",
			Player(playerid, player_uid));
		mysql_query(string);
		mysql_store_result();
		while(mysql_fetch_row(string))
		{
		    static uid,
				name[ MAX_ITEM_NAME ],
		   		use,
		   		used[ 10 ];

			sscanf(string, "p<|>ds[24]d",
				uid,
				name,
				use
			);

			if(use == 1) used = C_GREEN;
			else used = "";

			format(buffer, sizeof buffer, "%s%s%d\t%s\n", buffer, used, uid, name);
		}
		mysql_free_result();
		ShowList(victimid, buffer);
	}
	else if(!strcmp(sub, "id", true) || !strcmp(sub, "identyfikator", true))
	{
	    new duty = Player(playerid, player_duty);
	    if(!duty)
	        return ShowInfo(playerid, red"Nie jesteś na służbie w żadnej grupie!");
		if(!(Group(playerid, duty, group_option) & group_option_id))
		    return ShowInfo(playerid, red"Twoja grupa nie oferuje tej funkcji!");
		    
		new string[ 256 ], year;
		getdate(year);
		format(string, sizeof string,
			white"\tDane Identyfikatora:\n\nImię i Nazwisko:\t%s\nRok urodzenia:\t\t%d\nGrupa:\t\t\t%s\nStanowisko:\t%s",
			NickName(playerid),
			year - Player(playerid, player_age),
			Group(playerid, duty, group_name),
			Group(playerid, duty, group_rankname)
		);
		ShowInfo(victimid, string);
	}
	return 1;
}
