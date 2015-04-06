FuncPub::SelectPlayer(playerid)
{
	#if Debug
		printf("SelectPlayer(%d)", playerid);
	#endif
	TextDrawHideForPlayer(playerid, Setting(setting_td_box)[ 0 ]);
	TextDrawHideForPlayer(playerid, Setting(setting_td_box)[ 1 ]);
    KillTimer(Player(playerid, player_cam_timer));
    Player(playerid, player_cam_timer) = 0;

	SetSpawnInfo(playerid, NO_TEAM, 0, Setting(setting_r_pos)[ 0 ], Setting(setting_r_pos)[ 1 ], Setting(setting_r_pos)[ 2 ], Setting(setting_r_pos)[ 3 ], 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);
	SetPlayerVirtualWorld(playerid, playerid);
	FreezePlayer(playerid);

	SetTimerEx("SelectPlayerCamera", 100, false, "d", playerid);
	return 1;
}

FuncPub::SelectPlayerCamera(playerid)
{
    #if Debug
		printf("SelectPlayerCamera(%d)", playerid);
	#endif
	for(new pid; pid != MAX_SELECT; pid++)
	{
	    if(!Select(playerid, pid, select_uid)) continue;
	    PlayerTextDrawDestroy(playerid, Select(playerid, pid, select_td));

 	    for(new eSelect:d; d < eSelect; d++)
	    	Select(playerid, pid, d) = 0;
	}
	new buffer[ 256 ],
		string[ 126 ],
		pid;
	format(buffer, sizeof buffer,
		"SELECT `uid`, `name`, `cash`, `skin`, `sex`, `block` FROM `surv_players` WHERE `guid` = '%d' ORDER BY `lastlogged` DESC LIMIT %d, %d",
		Player(playerid, player_guid),
		Player(playerid, player_select_page),
		MAX_SELECT
	);
	mysql_query(buffer);
	mysql_store_result();
	while(mysql_fetch_row(buffer))
	{
	    if(pid == MAX_SELECT) break;
	    
	    sscanf(buffer, "p<|>ds["#MAX_PLAYER_NAME"]fddd",
	        Select(playerid, pid, select_uid),
	        Select(playerid, pid, select_name),
	        Select(playerid, pid, select_cash),
	        Select(playerid, pid, select_skin),
	        Select(playerid, pid, select_sex),
	        Select(playerid, pid, select_block)
		);
		if(Select(playerid, pid, select_uid))
		{
			format(string, sizeof string,
				"%s~n~Plec: %s~n~Portfel: ~g~$~w~%.2f",
				Select(playerid, pid, select_name),
				(Select(playerid, pid, select_sex) == sex_men) ? ("Mezczyzna") : ("Kobieta"),
				Select(playerid, pid, select_cash)
			);
			Select(playerid, pid, select_td) = CreatePlayerTextDraw(playerid, 4.000000, 76.000000+(pid*30.0), string);
			PlayerTextDrawBackgroundColor(playerid, Select(playerid, pid, select_td), 34);
			PlayerTextDrawFont(playerid, Select(playerid, pid, select_td), 1);
			PlayerTextDrawLetterSize(playerid, Select(playerid, pid, select_td), 0.200000, 0.800000);
			PlayerTextDrawColor(playerid, Select(playerid, pid, select_td), -1);
			PlayerTextDrawSetOutline(playerid, Select(playerid, pid, select_td), 1);
			PlayerTextDrawSetProportional(playerid, Select(playerid, pid, select_td), 1);
			PlayerTextDrawUseBox(playerid, Select(playerid, pid, select_td), 1);

			if(Player(playerid, player_select_uid) == pid)
				PlayerTextDrawBoxColor(playerid, Select(playerid, pid, select_td), 2122480264);
			else if(Select(playerid, pid, select_block) & block_ban || Select(playerid, pid, select_block) & block_ck || Select(playerid, pid, select_block) & block_block)
				PlayerTextDrawBoxColor(playerid, Select(playerid, pid, select_td), 1882206344);
			else
			{
				PlayerTextDrawSetSelectable(playerid, Select(playerid, pid, select_td), true);
				PlayerTextDrawBoxColor(playerid, Select(playerid, pid, select_td), 791952264);
			}
			PlayerTextDrawTextSize(playerid, Select(playerid, pid, select_td), 172.000000, 20.000000);
			PlayerTextDrawShow(playerid, Select(playerid, pid, select_td));
		}
		else break;
	    pid++;
	}
	if(!pid) Kick(playerid);
	mysql_free_result();
	
	TextDrawShowForPlayer(playerid, Setting(setting_selected)[ 0 ]);
	TextDrawShowForPlayer(playerid, Setting(setting_selected)[ 1 ]);
	TextDrawShowForPlayer(playerid, Setting(setting_selected)[ 2 ]);
	TextDrawShowForPlayer(playerid, Setting(setting_selected)[ 3 ]);
	TextDrawShowForPlayer(playerid, Setting(setting_selected_bg));

	SetPlayerSkin(playerid, Select(playerid, Player(playerid, player_select_uid), select_skin));
	SetPlayerAttachedObjects(playerid, Select(playerid, Player(playerid, player_select_uid), select_uid));
	SetDance(playerid);
	SelectTextDraw(playerid, GREEN); // TODO

	SetPlayerCameraPos(playerid, Setting(setting_r_cam)[ 0 ], Setting(setting_r_cam)[ 1 ], Setting(setting_r_cam)[ 2 ]);
	SetPlayerCameraLookAt(playerid, Setting(setting_r_cam)[ 3 ], Setting(setting_r_cam)[ 4 ], Setting(setting_r_cam)[ 5 ]);
	if(!Player(playerid, player_cam_timer))
		Player(playerid, player_cam_timer) = SetTimerEx("UpdateCamera", 5000, 1, "d", playerid);
	return 1;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if(playertextid != PlayerText:INVALID_TEXT_DRAW)
    {
    	for(new pid; pid != MAX_SELECT; pid++)
    	{
    	    if(!Select(playerid, pid, select_uid)) continue;
    	    if(playertextid == Select(playerid, pid, select_td))
    	    {
				PlayerTextDrawSetSelectable(playerid, Select(playerid, Player(playerid, player_select_uid), select_td), true);
				PlayerTextDrawBoxColor(playerid, Select(playerid, Player(playerid, player_select_uid), select_td), 791952264);
				PlayerTextDrawShow(playerid, Select(playerid, Player(playerid, player_select_uid), select_td));

    	        Player(playerid, player_select_uid) = pid;
    	        SetPlayerSkin(playerid, Select(playerid, pid, select_skin));
    	        SetPlayerAttachedObjects(playerid, Select(playerid, pid, select_uid));
    	        SetDance(playerid);

				PlayerTextDrawSetSelectable(playerid, Select(playerid, pid, select_td), false);
				PlayerTextDrawBoxColor(playerid, Select(playerid, pid, select_td), 2122480264);
				PlayerTextDrawShow(playerid, Select(playerid, pid, select_td));
				break;
    	    }
		}
    }
    return 1;
}

FuncPub::Login_OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == Setting(setting_selected)[ 3 ])
	{
	    // Informacje
		TextDrawHideForPlayer(playerid, Setting(setting_selected)[ 0 ]);
		TextDrawHideForPlayer(playerid, Setting(setting_selected)[ 1 ]);
		TextDrawHideForPlayer(playerid, Setting(setting_selected)[ 2 ]);
		TextDrawHideForPlayer(playerid, Setting(setting_selected)[ 3 ]);
        TextDrawHideForPlayer(playerid, Setting(setting_selected_bg));
    	for(new pid; pid != MAX_SELECT; pid++)
    	{
    	    if(!Select(playerid, pid, select_uid)) continue;

    	    PlayerTextDrawDestroy(playerid, Select(playerid, pid, select_td));

	 	    for(new eSelect:d; d < eSelect; d++)
		    	Select(playerid, pid, d) = 0;
    	}
	    SetTimerEx (!#kickPlayer, 249, false, !"i", playerid);
	}
	else if(clickedid == Setting(setting_selected)[ 0 ])
	{
	    // Graj
		TextDrawHideForPlayer(playerid, Setting(setting_selected)[ 0 ]);
		TextDrawHideForPlayer(playerid, Setting(setting_selected)[ 1 ]);
		TextDrawHideForPlayer(playerid, Setting(setting_selected)[ 2 ]);
		TextDrawHideForPlayer(playerid, Setting(setting_selected)[ 3 ]);
        TextDrawHideForPlayer(playerid, Setting(setting_selected_bg));

		Player(playerid, player_uid) = Select(playerid, Player(playerid, player_select_uid), select_uid);

    	for(new pid; pid != MAX_SELECT; pid++)
    	{
    	    if(!Select(playerid, pid, select_uid)) continue;

    	    PlayerTextDrawHide(playerid, Select(playerid, pid, select_td));
    	    PlayerTextDrawDestroy(playerid, Select(playerid, pid, select_td));

	 	    for(new eSelect:d; d < eSelect; d++)
		    	Select(playerid, pid, d) = 0;
    	}
		OnPlayerLoginIn(playerid);
	}
	else if(clickedid == Setting(setting_selected)[ 1 ])
	{
	    // Informacje
	    new p_uid = Select(playerid, Player(playerid, player_select_uid), select_uid),
			buffer[ 512 ], timeStr[ 45 ];
			
		new name[ MAX_PLAYER_NAME ],
		    timehere,
		    age,
		    visits,
		    Float:hp,
		    Float:cash,
		    sex,
		    skin,
		    aj, bw, jail;
		    
		format(buffer, sizeof buffer,
			"SELECT `name`, `timehere`, `age`, `visits`, `hp`, `cash`, `sex`, `skin`, `aj`, `bw`, `jail` FROM `surv_players` WHERE `uid` = '%d'",
			p_uid
		);
		mysql_query(buffer);
		mysql_store_result();
		mysql_fetch_row(buffer);
		mysql_free_result();
		sscanf(buffer, "p<|>s["#MAX_PLAYER_NAME"]dddffddddd",
		    name, timehere, age, visits, hp, cash, sex, skin, aj, bw, jail
		);
		FullTimeExtra(timehere, timeStr);
		UnderscoreToSpace(name);

	    format(buffer, sizeof buffer, "Nick:\t\t\t%s (%d)\n", name, p_uid);
	    format(buffer, sizeof buffer, "%sCzas gry:\t\t%s\n", buffer, timeStr);
		format(buffer, sizeof buffer, "%sOdwiedzin:\t\t%d\n", buffer, visits);
		strcat(buffer, "------------------------\n");
	    format(buffer, sizeof buffer, "%sŻycie:\t\t\t%.2f%%\n", buffer, hp);
	    format(buffer, sizeof buffer, "%sGotówka:\t\t$%.2f\n", buffer, cash);
	    format(buffer, sizeof buffer, "%sPłeć:\t\t\t%s\n", buffer, (sex == sex_men) ? ("Mężczyzna") : ("Kobieta"));
	    format(buffer, sizeof buffer, "%sWiek:\t\t\t%d\n", buffer, age);
	    format(buffer, sizeof buffer, "%sSkin:\t\t\t%d\n", buffer, skin);
	   	if(aj)
	   	{
			ReturnTime(aj, timeStr);
		   	format(buffer, sizeof buffer, "%sAdmin Jail:\t"red"%s\t\n", buffer, timeStr);
		}
		if(bw)
	   	{
			ReturnTime(bw, timeStr);
			format(buffer, sizeof buffer, "%sBW:\t\t\t"red"%s\n", buffer, timeStr);
		}
	    if(jail)
	   	{
		//	ReturnTime(gettime()-Player(playerid, player_jail), timeStr);
			format(buffer, sizeof buffer, "%sAreszt:\t\t\t"red"%d\n", buffer, jail);
		}
		ShowList(playerid, buffer);
	}
	return 1;
}

FuncPub::SetDance(playerid)
{
	switch(random(7))
	{
		case 0: ApplyAnimation(playerid, "DANCING", "DAN_Down_A", 4.00, 1, 1, 1, 1, 1); // Taichi
		case 1: ApplyAnimation(playerid, "DANCING", "DAN_Left_A", 4.00, 1, 1, 1, 1, 1); // Dilujesz
		case 2: ApplyAnimation(playerid, "DANCING", "DAN_Right_A", 4.0, 1, 1, 1, 1, 1); // Ręce
		case 3: ApplyAnimation(playerid, "DANCING", "DAN_Up_A", 4.0000, 1, 1, 1, 1, 1); // f**k
		case 4: ApplyAnimation(playerid, "DANCING", "dnce_M_a", 4.0000, 1, 1, 1, 1, 1); // Lookout
		case 5: ApplyAnimation(playerid, "RAPPING", "RAP_B_Loop", 4.00, 1, 0, 0, 0, 0); // Rapujesz
		case 6: ApplyAnimation(playerid, "DANCING", "DAN_Right_A", 4.0, 1, 1, 1, 1, 1); // Taniec
	}
	return 1;
}

FuncPub::UpdateCamera(playerid)
{
	SetPlayerCameraPos(playerid, Setting(setting_r_cam)[ 0 ] + random(3 -1), Setting(setting_r_cam)[ 1 ] + random(2 -1), Setting(setting_r_cam)[ 2 ] + random(2 -1));
	SetPlayerCameraLookAt(playerid, Setting(setting_r_cam)[ 3 ], Setting(setting_r_cam)[ 4 ], Setting(setting_r_cam)[ 5 ], CAMERA_MOVE);
    SetDance(playerid);
	return 1;
}
