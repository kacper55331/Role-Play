public OnPlayerCommandReceived(playerid, cmdtext[])
{
	if(!Player(playerid, player_logged)) return 0;
	return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
	printf("[zcmd] [%s]: %s", NickSamp(playerid), cmdtext);
	Player(playerid, player_cmds)++;
	
	if(!Player(playerid, player_cmd_timer))
		Player(playerid, player_cmd_timer) = SetTimerEx("CheckSpamCmd", 3000, false, "d", playerid);
	
    if(!success) PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
	return 1;
}

//
Cmd::Input->qs(playerid, params[]) return Kick(playerid);

Cmd::Input->me(playerid, params[])
{
	if(isnull(params))
		return ShowCMD(playerid, "Tip: /me [Treść]");

	new len = strlen(params),
		str[ 150 ],
		back;
		
	if(params[ len-1 ] != '.' && params[ len-1 ] != '?' && params[ len-1 ] != '!' && params[ len-1 ] != '*')
		back = '.';
		
	format(str, sizeof str, "** %s %s%s", NickName(playerid), params, back);
	SendWrappedMessageToPlayerRange(playerid, COLOR_PURPLE, COLOR_PURPLE2, COLOR_PURPLE3, COLOR_PURPLE4, COLOR_PURPLE5, str, 14, MAX_LINE);
/*
	if(len <= MAX_LINE)
	{
		serwerme(playerid, str);
	}
 	else
	{
       	new text1[ MAX_LINE+1 ];
        	
		new odstep = strfind(params, " ", .pos = (MAX_LINE-10));
		if(odstep == -1) odstep = MAX_LINE;

       	//strmid(text1, params, 0, odstep);
       	strmid(text1, params, odstep, len);
       	strdel(params, odstep, len);
       	if(odstep != -1) strdel(params, 0, 1);

       	format(str, sizeof str, "** %s %s...", NickName(playerid), params);
		serwerme(playerid, str);

       	format(str, sizeof str, "** ...%s%s", text1, back);
		serwerme(playerid, str);
  	}*/
	return 1;
}
Cmd::Input->ja(playerid, params[]) return cmd_me(playerid, params);

Cmd::Input->mec(playerid, params[])
{
	if(isnull(params))
		return ShowCMD(playerid, "Tip: /mec [Treść]");

	new len = strlen(params),
		str[ 150 ],
		back;
		
	if(params[ len-1 ] != '.' && params[ len-1 ] != '?' && params[ len-1 ] != '!' && params[ len-1 ] != '*')
		back = '.';
		
	format(str, sizeof str, "** %s %s%s", NickName(playerid), params, back);
	SendWrappedMessageToPlayerRange(playerid, COLOR_PURPLE, COLOR_PURPLE2, COLOR_PURPLE3, COLOR_PURPLE4, COLOR_PURPLE5, str, 10, MAX_LINE);
	return 1;
}

Cmd::Input->b(playerid, params[])
{
	if(Player(playerid, player_block) & block_noooc)
	    return ShowInfo(playerid, TEXT_OOC);
	if(isnull(params))
		return ShowCMD(playerid, "Tip: /b [Treść]");

	new len = strlen(params),
		str[ 150 ],
		back;
	if(params[ len-1 ] != '.' && params[ len-1 ] != '?' && params[ len-1 ] != '!' && params[ len-1 ] != '*')
		back = '.';

	params[ 0 ] = toupper(params[ 0 ]);
	format(str, sizeof str, "[%d] %s: (( %s%s ))", playerid, NickName(playerid), params, back);
	SendWrappedMessageToPlayerRange(playerid, COLOR_FADE1, COLOR_FADE2, COLOR_FADE3, COLOR_FADE4, COLOR_FADE5, str, 14, MAX_LINE);
	return 1;
}

Cmd::Input->do(playerid, params[])
{
	if(isnull(params))
		return ShowCMD(playerid, "Tip: /do [Treść]");

	new len = strlen(params),
		str[ 150 ],
		back;
	if(params[ len-1 ] != '.' && params[ len-1 ] != '?' && params[ len-1 ] != '!' && params[ len-1 ] != '*')
		back = '.';

	params[ 0 ] = toupper(params[ 0 ]);
	format(str, sizeof str, "** %s%s (( %s ))", params, back, NickName(playerid));
	SendWrappedMessageToPlayerRange(playerid, COLOR_DO, COLOR_DO2, COLOR_DO3, COLOR_DO4, COLOR_DO5, str, 14, MAX_LINE);
 	return 1;
}

Cmd::Input->do2(playerid, params[])
{
	if(!Player(playerid, player_adminlvl)) return 1;
	
	if(isnull(params))
		return ShowCMD(playerid, "Tip: /do [Treść]");

	new len = strlen(params),
		string[ 150 ],
		back,
		Text3D:End;
	if(params[ len-1 ] != '.' && params[ len-1 ] != '?' && params[ len-1 ] != '!' && params[ len-1 ] != '*')
		back = '.';
		
	params[ 0 ] = toupper(params[ 0 ]);
	format(string, sizeof string, "%s%s (( %s ))", params, back, NickName(playerid));
	wordwrap(string);
	GetPlayerPos(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]);
	End = Create3DTextLabel(string, opis_color, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ] + 0.5, 50, Player(playerid, player_vw), 1);
	SetTimerEx("End_TD", 10000, false, "i", _:End);
 	return 1;
}

Cmd::Input->doc(playerid, params[])
{
	if(isnull(params))
		return ShowCMD(playerid, "Tip: /doc [Treść]");

	new len = strlen(params),
		str[ 150 ],
		back;
	if(params[ len-1 ] != '.' && params[ len-1 ] != '?' && params[ len-1 ] != '!' && params[ len-1 ] != '*')
		back = '.';

	params[ 0 ] = toupper(params[ 0 ]);
	format(str, sizeof str, "** %s%s (( %s ))", params, back, NickName(playerid));
	SendWrappedMessageToPlayerRange(playerid, COLOR_DO, COLOR_DO2, COLOR_DO3, COLOR_DO4, COLOR_DO5, str, 10, MAX_LINE);
 	return 1;
}

Cmd::Input->l(playerid, params[])
{
	if(Player(playerid, player_aj)) return ShowInfo(playerid, TEXT_AJ);
	if(Player(playerid, player_bw)) return ShowInfo(playerid, red"Nie możesz rozmawiać podczas BW!");
	if(Player(playerid, player_knebel)) return ShowInfo(playerid, red"Jesteś zakneblowany!");

	if(isnull(params))
		return ShowCMD(playerid, "Tip: /l(ocal) [Treść]");

    new len = strlen(params),
		back,
		string[ 150 ];

	params[ 0 ] = toupper(params[ 0 ]);
	if(params[ len-1 ] != '.' && params[ len-1 ] != '?' && params[ len-1 ] != '!' && params[ len-1 ] != '*')
		back = '.';

	format(string, sizeof string, "%s mówi: %s%c", NickName(playerid), params, back);
	if(Player(playerid, player_veh) != INVALID_VEHICLE_ID && Vehicle(Player(playerid, player_veh), vehicle_option) & option_window)
		SendWrappedMessageToPlayerRange(playerid, COLOR_FADE1, COLOR_FADE2, COLOR_FADE3, COLOR_FADE4, COLOR_FADE5, string, 2, MAX_LINE);
	else
		SendWrappedMessageToPlayerRange(playerid, COLOR_FADE1, COLOR_FADE2, COLOR_FADE3, COLOR_FADE4, COLOR_FADE5, string, 14, MAX_LINE);
	return 1;
}
Cmd::Input->local(playerid, params[]) return cmd_l(playerid, params);

Cmd::Input->krzycz(playerid, params[])
{
	if(Player(playerid, player_aj)) return ShowInfo(playerid, TEXT_AJ);
	if(Player(playerid, player_bw)) return ShowInfo(playerid, red"Nie możesz rozmawiać podczas BW!");
	if(Player(playerid, player_knebel)) return ShowInfo(playerid, red"Jesteś zakneblowany!");

	if(isnull(params))
		return ShowCMD(playerid, "Tip: /k(rzycz) [Treść]");
		
	new string[ 150 ];

	format(string, sizeof string, "%s krzyczy: %s!!", NickName(playerid), params);
	if(Player(playerid, player_veh) != INVALID_VEHICLE_ID && Vehicle(Player(playerid, player_veh), vehicle_option) & option_window)
		SendWrappedMessageToPlayerRange(playerid, BIALY, BIALY, BIALY, COLOR_FADE1, COLOR_FADE2, string, 15, MAX_LINE);
	else
		SendWrappedMessageToPlayerRange(playerid, BIALY, BIALY, BIALY, COLOR_FADE1, COLOR_FADE2, string, 30, MAX_LINE);

	if(Player(playerid, player_option) & option_anim_k)
		ApplyAnimation(playerid, "ON_LOOKERS", "shout_in", 4.0, 0, 0, 0, 0, 0);
	return 1;
}
Cmd::Input->k(playerid, params[]) return cmd_krzycz(playerid, params);
Cmd::Input->s(playerid, params[]) return cmd_krzycz(playerid, params);

Cmd::Input->szept(playerid, params[])
{
	if(Player(playerid, player_aj)) return ShowInfo(playerid, TEXT_AJ);
	if(Player(playerid, player_bw)) return ShowInfo(playerid, red"Nie możesz rozmawiać podczas BW!");
	if(Player(playerid, player_knebel)) return ShowInfo(playerid, red"Jesteś zakneblowany!");

	if(isnull(params))
		return ShowCMD(playerid, "Tip: /s(zept) [Treść]");

	new len = strlen(params),
		str[ 150 ],
		back;
	if(params[ len-1 ] != '.' && params[ len-1 ] != '?' && params[ len-1 ] != '!' && params[ len-1 ] != '*')
		back = '.';

	params[ 0 ] = toupper(params[ 0 ]);
	format(str, sizeof str, "%s szepcze: %s%s", NickName(playerid), params, back);
	SendWrappedMessageToPlayerRange(playerid, BIALY, BIALY, BIALY, COLOR_FADE1, COLOR_FADE2, str, 8, MAX_LINE);
 	return 1;
}
Cmd::Input->c(playerid, params[]) return cmd_szept(playerid, params);

Cmd::Input->w(playerid, params[])
{
	if(!Player(playerid, player_logged))
	    return 1;
	#define color1 0xffcb73FF
	#define color2 0xffae31FF
	new
		victimid,
	 	wiadomosc[ 150 ];

	if(sscanf(params, "us[128]", victimid, wiadomosc))
		return ShowCMD(playerid, "Tip: /w(iadomosc) [ID/Nick] [Treść]");
	if(playerid == victimid)
		return ShowCMD(playerid, "Nie możesz wysłać wiadomości do siebie!");
	if(!IsPlayerConnected(victimid) || !Player(victimid, player_logged))
		return NoPlayer(playerid);
	if(Player(victimid, player_option) & option_pm)
	    return ShowCMD(playerid, "Gracz ma zablokowane prywatne wiadomości!");
	
	new buffer[ 150 ];
	wiadomosc[ 0 ] = toupper(wiadomosc[ 0 ]);
	
	format(buffer, sizeof buffer, "(( > %s (%d): %s ))", NickName(victimid), victimid, wiadomosc);
	SendWrappedMessageToPlayer(playerid, color1, buffer);
	
	if(Player(playerid, player_mask))
		format(buffer, sizeof buffer, "(( %s: %s ))", NickName(playerid), wiadomosc);
	else
		format(buffer, sizeof buffer, "(( %s (%d): %s ))", NickName(playerid), playerid, wiadomosc);
 	SendWrappedMessageToPlayer(victimid, color2, buffer);
 	
 	Player(victimid, player_re) = playerid;

	if(Player(victimid, player_afktime)[ 0 ] > 5)
		ShowCMD(playerid, "Ten gracz jest prawdopodobnie AFK i nie może odpowiedzieć na tą wiadomość.");

  	if(Audio_IsClientConnected(victimid))
  		Audio_Play(victimid, sound_info);
  	else
  	    PlayerPlaySound(victimid, 1052, 0.0, 0.0, 0.0);
	return 1;
}
Cmd::Input->pm(playerid, params[]) return cmd_w(playerid, params);
Cmd::Input->wiadomosc(playerid, params[]) return cmd_w(playerid, params);

Cmd::Input->re(playerid, wiadomosc[])
{
	new victimid = Player(playerid, player_re);
	if(!IsPlayerConnected(victimid))
	    return NoPlayer(playerid);
	if(victimid == INVALID_PLAYER_ID)
	    return ShowCMD(playerid, "Gracz musi pierw do Ciebie napisać, abyś mógł do niego szybko odpisywać.");

	new buffer[ 150 ];
	wiadomosc[ 0 ] = toupper(wiadomosc[ 0 ]);

	if(Player(victimid, player_mask))
		format(buffer, sizeof buffer, "(( > %s: %s ))", NickName(victimid), wiadomosc);
	else
		format(buffer, sizeof buffer, "(( > %s (%d): %s ))", NickName(victimid), victimid, wiadomosc);

	SendWrappedMessageToPlayer(playerid, color1, buffer);

	format(buffer, sizeof buffer, "(( %s (%d): %s ))", NickName(playerid), playerid, wiadomosc);
 	SendWrappedMessageToPlayer(victimid, color2, buffer);

 	Player(victimid, player_re) = playerid;

	if(Player(victimid, player_afktime)[ 0 ] > 5)
		Chat::Output(playerid, SZARY, "Ten gracz jest prawdopodobnie AFK i nie może odpowiedzieć na tą wiadomość.");
	return 1;
}

Cmd::Input->megafon(playerid, params[])
{
	if(!HavePlayerItem(playerid, item_megafon))
		return ShowCMD(playerid, "Nie posiadasz megafonu.");

	if(isnull(params))
		return ShowCMD(playerid, "Tip: /m(egafon) [Treść]");

	new len = strlen(params),
		str[ 150 ],
		back;
	if(params[ len-1 ] != '.' && params[ len-1 ] != '?' && params[ len-1 ] != '!' && params[ len-1 ] != '*')
		back = '.';

	params[ 0 ] = toupper(params[ 0 ]);
	format(str, sizeof str, "** %s (megafon): %s%s", NickName(playerid), params, back);
	SendWrappedMessageToPlayerRange(playerid, 0xFFFF00FF, 0xFFFF00FF, 0xFFFF00FF, 0xFFFF00FF, 0xFFFF00FF, str, 50, MAX_LINE);
	return 1;
}
Cmd::Input->m(playerid, params[]) return cmd_megafon(playerid, params);

Cmd::Input->sprobuj(playerid, params[])
{
	if(isnull(params))
		return ShowCMD(playerid, "Tip: /sprobuj [Akcja] (np. 'Trafić do kosza')");

	new str[ 126 ];
	switch(random(2)+1)
	{
		case 1: format(str, sizeof str, "* %s spróbował %s i udało mu się.", NickName(playerid), params);
		case 2: format(str, sizeof str, "* %s spróbował %s i nie udało mu się.", NickName(playerid), params);
	}
	serwerme(playerid, str);
	return 1;
}

Cmd::Input->id(playerid, params[])
{
	new buffer[ 512 ];
	if(isnull(params))
	{
	    new victimid = INVALID_PLAYER_ID,
			Float:tmpdis,
			Float:dist = 30.0;
	    foreach(Player, i)
	    {
	        if(i == playerid) continue;
	        if(Player(i, player_vw) != Player(playerid, player_vw)) continue;
	        if(Player(i, player_mask)) continue;
	        
	        GetPlayerPos(i, Player(i, player_position)[ 0 ], Player(i, player_position)[ 1 ], Player(i, player_position)[ 2 ]);
        	tmpdis = GetPlayerDistanceFromPoint(playerid, Player(i, player_position)[ 0 ], Player(i, player_position)[ 1 ], Player(i, player_position)[ 2 ]);
        	if(tmpdis < dist)
        	{
            	dist = tmpdis;
            	victimid = i;
        	}
	    }
	    if(victimid == INVALID_PLAYER_ID) ShowCMD(playerid, "Brak graczy w pobliżu!");
	    else
	    {
			format(buffer, sizeof buffer, "Najbliższy gracz %s (ID: %d) i jest oddalony o %.2fj", NickName(victimid), victimid, dist);
			ShowCMD(playerid, buffer);
		}
		return 1;
	}
	if('0' <= params[ 0 ] <= '9')
	{
	    buffer[ 0 ] = EOS;
	    new num;
		for(new l = GetMaxPlayers()-1, i = strval(params); i <= l; i += 10)
		{
	    	if(!IsPlayerConnected(i)) continue;
	    	if(IsPlayerNPC(i)) continue;
			format(buffer, sizeof buffer, "%s"green"%d\t"white"%s\n", buffer, i, NickSamp(i));
			num++;
			if(num > 9)
			{
				strcat(buffer, grey"------------------------\n");
				strcat(buffer, "Lista ucięta, zbyt wiele wyników!");
				break;
			}
		}
	}
	else
	{
	    buffer[ 0 ] = EOS;
	    new num, znak = -1;
		foreach(Player, i)
		{
		    new nick[ MAX_PLAYER_NAME + 12 ];
		    format(nick, sizeof nick, NickSamp(i));
		    znak = strfind(nick, params, true);
			if(znak != -1)
			{
			    strins(nick, green, znak);
			    strins(nick, white, znak+strlen(params)+strlen(green));
			    format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, i, nick);
				num++;
			}
			if(num > 9)
			{
				strcat(buffer, grey"------------------------\n");
				strcat(buffer, "Lista ucięta, zbyt wiele wyników!");
				break;
			}
		}
	}
	if(isnull(buffer))
		NoPlayer(playerid);
	else
		ShowList(playerid, buffer);
	return 1;
}

Cmd::Input->plac(playerid, params[])
{
	new victimid,
		Float:amount;

	if(sscanf(params, "uf", victimid, amount))
		return ShowCMD(playerid, "Tip: /plac [ID/Nick] [ilość]");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);
	if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
		return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");
	if(amount > Player(playerid, player_cash))
		return ShowCMD(playerid, "Nie posiadasz tyle gotówki");
	if(amount <= 0)
	    return ShowCMD(playerid, "Kwota nie może być niższa od "green2"$"white"0");
	if(playerid == victimid)
	    return ShowCMD(playerid, "Nie możesz przekazać gotówki sobie!");
	if(Player(playerid, player_timehere)[ 0 ] < 7200)
	    return ShowCMD(playerid, "Nie masz przegranych 2 godzin, by użyć tej komendy!");

	if(IsPlayerNPC(victimid))
	    GivePlayerAchiv(playerid, achiv_npc);
	    
    GivePlayerMoneyEx(playerid, 0 - amount, true);
    GivePlayerMoneyEx(victimid, amount, true);

	new string[ 126 ];
	if(Player(playerid, player_option) & option_me)
	{
		format(string, sizeof string, "* %s podaje trochę gotówki %s.", NickName(playerid), NickName(victimid));
		serwerme(playerid, string);
	}
	format(string, sizeof string, "Otrzymał%sś $%.2f gotówki od %s.", Player(victimid, player_sex) == sex_woman ? ("a") : ("e"), amount, NickName(playerid));
	Chat::Output(victimid, COLOR_LIGHTBLUE, string);

	ApplyAnimation(playerid, "DEALER", "shop_pay", 4.1, 0, 1, 1, 1, 1);
	return 1;
}
Cmd::Input->pay(playerid, params[]) return cmd_plac(playerid, params);

Cmd::Input->stats(victimid, params[])
{
	new playerid;
	if(!isnull(params))
	{
		if(Player(victimid, player_adminlvl)) sscanf(params, "u", playerid);
		else playerid = victimid;
	}
	else playerid = victimid;

	if(!IsPlayerConnected(playerid) && !Player(playerid, player_logged))
		return NoPlayer(victimid);

	new buffer[ 1024 ],
		buffer2[ 64 ],
		timeStr[ 45 ],
		timeStr2[ 45 ],
		Float:cash,
		zone = GetPlayerZone(playerid),
		street = GetPlayerStreet(playerid),
		grunt = GetPlayerGrunt(playerid),
		door = Player(playerid, player_door);
		
	format(buffer, sizeof buffer,
	    "SELECT SUM(cash) FROM `surv_bank` WHERE `ownerType` = '"#bank_type_player"' AND `owner` = '%d'",
	    Player(playerid, player_uid)
	);
	mysql_query(buffer);
	mysql_store_result();
	if(mysql_num_rows()) mysql_fetch_float(cash);
	mysql_free_result();
	
	FullTimeExtra(Player(playerid, player_timehere)[ 0 ], timeStr);
	ReturnTimeMega(Player(playerid, player_timehere)[ 1 ], timeStr2);
 	if(isnull(Player(playerid, player_ip)))
 	    GetPlayerIp(playerid, Player(playerid, player_ip), 18);

  	format(buffer2, sizeof buffer2, C_BLUE2"%s "white"[%s] (ID: %d)", NickName(playerid), Player(playerid, player_ip), playerid);
    format(buffer, sizeof buffer, "Nick OOC:\t\t%s (%d)\n", Player(playerid, player_gname), Player(playerid, player_guid));
    format(buffer, sizeof buffer, "%sNick:\t\t\t%s (%d)\n", buffer, NickSamp(playerid, true), Player(playerid, player_uid));
    format(buffer, sizeof buffer, "%sCzas gry:\t\t%s\n", buffer, timeStr);
    format(buffer, sizeof buffer, "%sGrasz od:\t\t%s\n", buffer, timeStr2);
	format(buffer, sizeof buffer, "%sOdwiedzin:\t\t%d\n", buffer, Player(playerid, player_visits));
	strcat(buffer, grey"------------------------\n");
    format(buffer, sizeof buffer, "%sŻycie:\t\t\t%.2f%%\n", buffer, Player(playerid, player_hp));
    format(buffer, sizeof buffer, "%sGotówka:\t\t"green2"$"white"%.2f\n", buffer, Player(playerid, player_cash));
    format(buffer, sizeof buffer, "%sStan konta:\t\t"green2"$"white"%.2f\n", buffer, cash);
    format(buffer, sizeof buffer, "%sPłeć:\t\t\t%s\n", buffer, (Player(playerid, player_sex) == sex_men) ? ("Mężczyzna") : ("Kobieta"));
    format(buffer, sizeof buffer, "%sWiek:\t\t\t%d\n", buffer, Player(playerid, player_age));
    format(buffer, sizeof buffer, "%sSkin:\t\t\t%d\n", buffer, Player(playerid, player_skin));
    if(Audio_IsClientConnected(playerid))
        strcat(buffer, "Audio Plugin:\t\t"green2"Tak\n");
    if(Player(playerid, player_stamina) > 3000)
    	format(buffer, sizeof buffer, "%sSiła:\t\t\t%dj\n", buffer, Player(playerid, player_stamina));
	if(Player(playerid, player_fight))
        format(buffer, sizeof buffer, "%sSztuka walki:\t\t%s (%d)\n", buffer, FightData[ Player(playerid, player_fight) ][ fight_name ], FightData[ Player(playerid, player_fight) ][ fight_id ]);
   	if(Player(playerid, player_job))
    	format(buffer, sizeof buffer, "%sPraca dorywcza:\t%s\n", buffer, JobName[ Player(playerid, player_job) ]);
   	if(Player(playerid, player_aj))
   	{
		ReturnTime(Player(playerid, player_aj), timeStr);
	   	format(buffer, sizeof buffer, "%sAdmin Jail:\t"red"%s\t\n", buffer, timeStr);
	}
	if(Player(playerid, player_bw))
   	{
		ReturnTime(Player(playerid, player_bw), timeStr);
		format(buffer, sizeof buffer, "%sBW:\t\t\t"red"%s\n", buffer, timeStr);
	}
    if(Player(playerid, player_jail))
   	{
		ReturnTimeAgo(gettime()-Player(playerid, player_jail), timeStr);
		format(buffer, sizeof buffer, "%sAreszt:\t\t\t"red"%d\n", buffer, timeStr);
	}
    if(Player(playerid, player_adminlvl))
    {
        if(isnull(AdminLvl[ Player(playerid, player_adminlvl) ][ admin_tag ]))
			format(buffer, sizeof buffer, "%sAdmin:\t\t\t%d ({%06x}%s"white")\n", buffer, Player(playerid, player_adminlvl), AdminLvl[ Player(playerid, player_adminlvl) ][ admin_color ] >>> 8, AdminLvl[ Player(playerid, player_adminlvl) ][ admin_name ]);
		else
		    format(buffer, sizeof buffer, "%sAdmin:\t\t\t%d ({%06x}%s %s"white")\n", buffer, Player(playerid, player_adminlvl), AdminLvl[ Player(playerid, player_adminlvl) ][ admin_color ] >>> 8, AdminLvl[ Player(playerid, player_adminlvl) ][ admin_name ], AdminLvl[ Player(playerid, player_adminlvl) ][ admin_tag ]);
        if(Player(playerid, player_spec) != INVALID_PLAYER_ID)
	    	format(buffer, sizeof buffer, "%sSpec:\t\t\t%d (%s)\n", buffer, Player(playerid, player_spec), NickName(Player(playerid, player_spec)));

		new bool:spec;
		foreach(Player, i)
		{
			if(Player(i, player_spec) != playerid) continue;
			if(!spec)
			{
			    strcat(buffer, "Obserwowany:\n");
			    spec = true;
			}
    		format(buffer, sizeof buffer, "%s\t- %s (%d)\n", buffer, NickName(i), i);
		}
	}
	if(door)
		format(buffer, sizeof buffer, "%sDrzwi:\t\t\t%d (%s)\n", buffer, Door(door, door_uid), Door(door, door_name));
	if(zone)
		format(buffer, sizeof buffer, "%sStrefa:\t\t\t%d (%s)\n", buffer, Zone(zone, zone_uid), Zone(zone, zone_name));
	if(grunt)
		format(buffer, sizeof buffer, "%sGrunt:\t\t\t%d\n", buffer, Grunt(grunt, grunt_uid));
	if(street)
		format(buffer, sizeof buffer, "%sUlica:\t\t\t%d (%s)\n", buffer, Street(street, street_uid), Street(street, street_name));
    if(Player(playerid, player_vw))
		format(buffer, sizeof buffer, "%sVirtual World:\t\t%d\n", buffer, Player(playerid, player_vw));

	new bool:count;
	for(new groupid; groupid != MAX_GROUPS; groupid++)
	{
	    if(!Group(playerid, groupid, group_uid)) continue;
	    if(!count)
	    {
	        strcat(buffer, "Grupy:\n");
	        count = true;
	    }
	    if(Player(playerid, player_duty) == groupid)
	    {
	        new tstr[ 32 ];
	        ReturnTimeMega(Group(playerid, groupid, group_duty), tstr);
			format(buffer, sizeof buffer, "%s\t- {%06x}%s (%d) %s\n", buffer, Group(playerid, groupid, group_color) >>> 8, Group(playerid, groupid, group_name), Group(playerid, groupid, group_uid), tstr);
		}
		else
	    	format(buffer, sizeof buffer, "%s\t- %s (%d)\n", buffer, Group(playerid, groupid, group_name), Group(playerid, groupid, group_uid));
	}
	if(playerid == victimid)
	{
		strcat(buffer, grey"------------------------\n");
		strcat(buffer, "Ustawienia konta\n");
		if(Player(playerid, player_adminlvl))
			strcat(buffer, "Uprawnienia administratora\n");
		Dialog::Output(victimid, 60, DIALOG_STYLE_LIST, buffer2, buffer, "Wybierz", "Zamknij");
	}
	else Dialog::Output(victimid, 999, DIALOG_STYLE_LIST, buffer2, buffer, "Wybierz", "");
	return 1;
}

Cmd::Input->news(playerid, params[])
{
    if(!IsPlayerInTypeGroup(playerid, group_type_radio))
        return 1;
	if(isnull(params))
		return ShowCMD(playerid, "Tip: /news [Treść]");
    EscapePL(params);
    if(!CheckTextDrawString(params))
    {
        TextDrawSetString(Setting(setting_sn)[ 1 ], SAN_NEWS);
        Chat::Output(playerid, SZARY, "W tej wiadomości nie mogą się znajdować dwie ~ obok siebie.");
    }
    else
    {
		new string[ 256 ];
		format(string, sizeof string,
			"~>~ ~p~%s ~r~(news)~w~: ~w~%s",
			NickName(playerid),
			params
		);
		TextDrawSetString(Setting(setting_sn)[ 1 ], string);
	}
	return 1;
}

Cmd::Input->life(playerid, params[])
{
    if(!IsPlayerInTypeGroup(playerid, group_type_radio))
        return 1;
	if(isnull(params))
		return ShowCMD(playerid, "Tip: /life [Treść]");
    EscapePL(params);
    if(!CheckTextDrawString(params))
    {
        TextDrawSetString(Setting(setting_sn)[ 1 ], SAN_NEWS);
        Chat::Output(playerid, SZARY, "W tej wiadomości nie mogą się znajdować dwie ~ obok siebie.");
    }
    else
    {
		new string[ 256 ];
		format(string, sizeof string,
			"~>~ ~p~%s ~r~(na zywo)~w~: ~w~%s",
			NickName(playerid),
			params
		);
		TextDrawSetString(Setting(setting_sn)[ 1 ], string);
	}
	return 1;
}
Cmd::Input->live(playerid, cmdtext[]) return cmd_life(playerid, cmdtext);

Cmd::Input->reklama(playerid, params[])
{
    if(!IsPlayerInTypeGroup(playerid, group_type_radio))
        return 1;
	if(isnull(params))
		return ShowCMD(playerid, "Tip: /reklama [Treść]");
    EscapePL(params);
    if(!CheckTextDrawString(params))
    {
        TextDrawSetString(Setting(setting_sn)[ 1 ], SAN_NEWS);
        Chat::Output(playerid, SZARY, "W tej wiadomości nie mogą się znajdować dwie ~ obok siebie.");
    }
    else
    {
		new string[ 256 ];
		format(string, sizeof string,
			"~>~ ~p~%s ~r~(reklama)~w~: ~w~%s",
			NickName(playerid),
			params
		);
		TextDrawSetString(Setting(setting_sn)[ 1 ], string);
	}
	return 1;
}

Cmd::Input->login(playerid, cmdtext[]) return cmd_logout(playerid, cmdtext);
Cmd::Input->logout(playerid, params[])
{
	if(Player(playerid, player_tag) != Text3D:INVALID_3DTEXT_ID)
	{
		Delete3DTextLabel(Player(playerid, player_tag));
		Player(playerid, player_tag) = Text3D:INVALID_3DTEXT_ID;
	}
	if(Player(playerid, player_opis_id) != Text3D:INVALID_3DTEXT_ID)
	{
		Delete3DTextLabel(Player(playerid, player_opis_id));
		Player(playerid, player_opis_id) = Text3D:INVALID_3DTEXT_ID;
	}
	for(new t = 1; t != MAX_3DTEXT_PLAYER; t++)
	{
	    if(Text(playerid, t, text_textID) == PlayerText3D:INVALID_3DTEXT_ID) continue;

		DeletePlayer3DTextLabel(playerid, Text(playerid, t, text_textID));
		for(new eText:d; d < eText; d++)
		    Text(playerid, t, d) = 0;
		Text(playerid, t, text_textID) = PlayerText3D:INVALID_3DTEXT_ID;
	}
	#if !STREAMER
		for(new t = 1; t != MAX_OBJECTS; t++)
		{
		    if(IsValidPlayerObject(playerid, Object(playerid, t, obj_objID)))
		    	DestroyPlayerObject(playerid, Object(playerid, t, obj_objID));

			for(new eObjects:i; i < eObjects; i++)
				Object(playerid, t, i)		= 0;
			Object(playerid, t, obj_objID) = INVALID_OBJECT_ID;
		}
	#endif

    OnPlayerLoginOut(playerid);
    
    new string[ 200 ],
		Text3D:End,
		TimePlay[ 45 ],
		admin[ 2 ],
		guid,
		gname[ 120 ];
		
	guid = Player(playerid, player_guid);
	format(gname, sizeof gname, Player(playerid, player_gname));
	admin[ 0 ] = Player(playerid, player_adminlvl);
	admin[ 1 ] = Player(playerid, player_adminperm);

	TextDrawHideForPlayer(playerid, Setting(setting_td_box)[ 0 ]);
	TextDrawHideForPlayer(playerid, Setting(setting_td_box)[ 1 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_sn)[ 0 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_sn)[ 1 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_td_item)[ 0 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_td_item)[ 1 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_td_item)[ 2 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_td_item)[ 3 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_td_item)[ 4 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_td_item)[ 5 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_td_item)[ 6 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_silnik));
    TextDrawHideForPlayer(playerid, Setting(setting_admin_head));
    TextDrawHideForPlayer(playerid, Setting(setting_admin_box)[ 0 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_admin_box)[ 1 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_admin_exit));
    TextDrawHideForPlayer(playerid, Setting(setting_admin_report));
    TextDrawHideForPlayer(playerid, Setting(setting_admin_duty)[ 0 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_admin_duty)[ 1 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_fuel_td)[ 0 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_fuel_td)[ 1 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_fuel_td)[ 2 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_fuel_td)[ 3 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_fuel_td)[ 4 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_fuel_td)[ 5 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_fuel_td)[ 6 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_fuel_td)[ 7 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_selected_bg));
    TextDrawHideForPlayer(playerid, Setting(setting_selected)[ 0 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_selected)[ 1 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_selected)[ 2 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_selected)[ 3 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_radar)[ 0 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_radar)[ 1 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_radar)[ 2 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_group_out)[ 0 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_group_out)[ 1 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_achiv)[ 0 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_achiv)[ 1 ]);
    for(new c; c != MAX_GROUPS; c++)
    {
        TextDrawHideForPlayer(playerid, Setting(setting_group_background)[ c ]);
        TextDrawHideForPlayer(playerid, Setting(setting_group_veh)[ c ]);
        TextDrawHideForPlayer(playerid, Setting(setting_group_duty_on)[ c ]);
        TextDrawHideForPlayer(playerid, Setting(setting_group_duty)[ c ]);
        TextDrawHideForPlayer(playerid, Setting(setting_group_online)[ c ]);
        TextDrawHideForPlayer(playerid, Setting(setting_group_magazyn)[ c ]);
        TextDrawHideForPlayer(playerid, Setting(setting_group_info)[ c ]);
    }
    
	PlayerTextDrawDestroy(playerid, Player(playerid, player_cash_td));
	PlayerTextDrawDestroy(playerid, Player(playerid, player_infos));
	PlayerTextDrawDestroy(playerid, Player(playerid, player_veh_td));
	PlayerTextDrawDestroy(playerid, Player(playerid, player_street));
	PlayerTextDrawDestroy(playerid, Player(playerid, player_item_td)[ 0 ]);
	PlayerTextDrawDestroy(playerid, Player(playerid, player_item_td)[ 1 ]);
	PlayerTextDrawDestroy(playerid, Player(playerid, player_item_td)[ 2 ]);
	PlayerTextDrawDestroy(playerid, Player(playerid, player_friend));
	PlayerTextDrawDestroy(playerid, Player(playerid, player_fuel_td)[ 0 ]);
	PlayerTextDrawDestroy(playerid, Player(playerid, player_fuel_td)[ 1 ]);
	PlayerTextDrawDestroy(playerid, Player(playerid, player_fuel_td)[ 2 ]);
	PlayerTextDrawDestroy(playerid, Player(playerid, player_fuel_td)[ 3 ]);
	PlayerTextDrawDestroy(playerid, Player(playerid, player_cash_add));
	PlayerTextDrawDestroy(playerid, Player(playerid, player_kara)[ 0 ]);
	PlayerTextDrawDestroy(playerid, Player(playerid, player_kara)[ 1 ]);
	PlayerTextDrawDestroy(playerid, Player(playerid, player_radar)[ 0 ]);
	PlayerTextDrawDestroy(playerid, Player(playerid, player_radar)[ 1 ]);
	PlayerTextDrawDestroy(playerid, Player(playerid, player_door_td)[ 0 ]);
	PlayerTextDrawDestroy(playerid, Player(playerid, player_door_td)[ 1 ]);
	PlayerTextDrawDestroy(playerid, Player(playerid, player_door_td)[ 2 ]);
	PlayerTextDrawDestroy(playerid, Player(playerid, player_achiv_text));
	for(new c; c!= MAX_GROUPS; c++)
	    PlayerTextDrawDestroy(playerid, Group(playerid, c, group_text));
	    

	format(string, sizeof string,
		"DELETE FROM `all_online` WHERE `player` = '%d' AND `ID` = '%d' AND `type` = '"#type_rp"'",
		Player(playerid, player_uid),
		playerid
	);
	mysql_query(string);

    ReturnTime(Player(playerid, player_timehere)[ 1 ], TimePlay);
	format(string, sizeof string, "%s\n(( Logout ))\nGrał: %s", NickName(playerid), TimePlay);
	End = Create3DTextLabel(string, SZARY, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ] + 0.5, 50, Player(playerid, player_vw), 1);
	SetTimerEx("End_TD", 10000, false, "i", _:End);
	
	Clear(playerid);
	
	for(new i; i != MAX_GROUPS; i++)
	    for(new eGroups:d; d < eGroups; d++)
	    	Group(playerid, i, d) = 0;

	for(new ePlayers:i; i < ePlayers; i++)
    	Player(playerid, i) = 0;
    	
	ClearData(playerid);

    FadeColorForPlayer(playerid, 0, 0, 0, 0, 0, 0, 0, 255, 15, 0); // Ściemnienie
	Player(playerid, player_dark) = dark_character;
	
	Player(playerid, player_guid) = guid;
	Player(playerid, player_adminlvl) = admin[ 0 ];
	Player(playerid, player_adminperm) = admin[ 1 ];
	format(Player(playerid, player_gname), sizeof gname, gname);
	return 1;
}

Cmd::Input->pomoc(playerid, params[])
{
	Dialog::Output(playerid, 135, DIALOG_STYLE_LIST, IN_HEAD,
		"Jak zacząć?\n\
		OOC i IC\n\
		Podstawowe komendy\n\
		Animacje\n\
		Pojazdy\n\
		Przedmioty\n\
		Oferty\n\
		Praca\n\
		Czaty grupowe",
	"Wybierz", "Zamknij");
	return 1;
}

Cmd::Input->zbieraj(playerid, params[])
{
    if(Player(playerid, player_job) != job_smieciarz)
        return ShowInfo(playerid, red"Nie pracujesz jako śmieciarz!");
	if(IsPlayerInAnyVehicle(playerid))
	    return ShowInfo(playerid, red"Musisz wyjść z pojazdu!");
    if(Player(playerid, player_trash) == MAX_SMIECI)
        return ShowInfo(playerid, red"Nie możesz podnieść więcej śmieci.");
	GetPlayerPos(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]);
	Player(playerid, player_vw) = GetPlayerVirtualWorld(playerid);

    new string[ 300 ];
    format(string, sizeof string,
		"SELECT `uid`, SQRT(((x - %f) * (x - %f)) + ((y - %f) * (y - %f))) AS dist FROM `surv_items` WHERE `ownerType`="#item_place_none" AND `vw` = '%d' AND `type` = '"#item_trash"' ORDER BY dist",
		Player(playerid, player_position)[ 0 ],
		Player(playerid, player_position)[ 0 ],
		Player(playerid, player_position)[ 1 ],
		Player(playerid, player_position)[ 1 ],
		Player(playerid, player_vw)
	);
	mysql_query(string);
	mysql_store_result();
	
	new c[ MAX_SMIECI ], countx;
	if(mysql_num_rows())
	{
		while(mysql_fetch_row(string))
		{
		    if(Player(playerid, player_trash) == MAX_SMIECI)
		    {
		        ShowCMD(playerid, "Zebrałeś już odpowiednią ilość śmieci. Podejdź do pojazdu i wpisz /odloz");
				break;
		    }
		    static uid, Float:dist;
		    sscanf(string, "p<|>df", uid, dist);
		    
		    if(dist > 5.0) break;
		    countx++;
			c[ countx ] = uid;
		    Player(playerid, player_trash) ++;
		}
		if(!countx) return ShowCMD(playerid, "W pobliżu nie ma śmieci!");
		for(new x; x != sizeof c; x++)
		{
			for(new count; count < MAX_OBJECTS; count++)
			{
			    if(Object(count, obj_objID) == INVALID_OBJECT_ID) continue;
			    if(!Streamer_IsInArrayData(STREAMER_TYPE_OBJECT, Object(count, obj_objID), E_STREAMER_WORLD_ID, Player(playerid, player_vw))) continue;
				if(Object(count, obj_owner)[ 0 ] != object_owner_item) continue;
				if(Object(count, obj_owner)[ 1 ] != c[ x ]) continue;

		    	format(string, sizeof string,
		    	    "DELETE FROM `surv_objects` WHERE `uid` = '%d'",
		    	    Streamer_GetIntData(STREAMER_TYPE_OBJECT, Object(count, obj_objID), E_STREAMER_EXTRA_ID)
				);
				mysql_query(string);
				
				DestroyDynamicObject(Object(count, obj_objID));

	            for(new eObjects:i; i < eObjects; i++)
					Object(count, i) = 0;
				Object(count, obj_objID) = INVALID_OBJECT_ID;
				break;
			}
			format(string, sizeof string,
	    	    "DELETE FROM `surv_items` WHERE `uid` = '%d'",
	    	    c[ x ]
			);
			mysql_query(string);
		}
		format(string, sizeof string,
			"Zebrałeś %d %s. Łącznie: %d/"#MAX_SMIECI"",
			countx,
			dli(countx, "śmiecia", "śmiecie", "śmieci"),
			Player(playerid, player_trash)
		);
		ShowCMD(playerid, string);
	}
	else ShowInfo(playerid, red"W pobliżu nie ma żadnych śmieci!");
	mysql_free_result();
	return 1;
}

Cmd::Input->odloz(playerid, params[])
{
	new vehid = GetClosestCar(playerid, 10.0);
	if(Vehicle(vehid, vehicle_owner)[ 0 ] == vehicle_owner_job && Vehicle(vehid, vehicle_owner)[ 1 ] != Player(playerid, player_job))
	    return ShowInfo(playerid, red"Nie jesteś przy odpowiednim pojeździe.");
	    
	new string[ 64 ];
	format(string, sizeof string,
		"Odłożyłeś %d %s. O to Twoja zapłata.",
		Player(playerid, player_trash),
		dli(Player(playerid, player_trash), "śmiecia", "śmiecie", "śmieci")
	);
	ShowCMD(playerid, string);
	
	GivePlayerMoneyEx(playerid, Player(playerid, player_trash) * 0.5, true);
    Player(playerid, player_trash) = 0;
	return 1;
}
/*
#if Debug
Cmd::Input->kill(playerid, params[])
{
	SetPlayerHealth(playerid, 0.0);
	return 1;
}
#endif
*/
