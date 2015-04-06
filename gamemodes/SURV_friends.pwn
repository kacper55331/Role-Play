// TODO

FuncPub::LoadPlayerFriends(playerid)
{
	new string[ 320 ];
	format(string, sizeof string,
		"SELECT DISTINCT o.ID, g.members_display_name FROM `all_online` o JOIN `surv_players` p JOIN `"IN_PREF"profile_friends` f JOIN `"IN_PREF"members` g ON o.player = p.uid AND g.member_id = p.guid AND f.friends_member_id = p.guid WHERE f.friends_friend_id = '%d' AND o.type = '"#type_rp"' AND f.friends_approved = '1'",
		Player(playerid, player_guid)
	);
	mysql_query(string);
	mysql_store_result();
	while(mysql_fetch_row_format(string))
	{
	    static id,
	        name[ 32 ],
			str[ 80 ];
			
		sscanf(string, "p<|>ds[32]",
			id,
			name
		);
		
		//Chat::Output(id, GREEN, "Twój znajomy dołączył do gry!");
		
		format(str, sizeof str, "~y~~h~%s~n~~w~dolaczyl do gry!", Player(playerid, player_gname));
		PlayerTextDrawSetString(id, Player(id, player_friend), str);
		PlayerTextDrawShow(id, Player(id, player_friend));
		Audio_Play(id, sound_info);
		
		/*format(str, sizeof str, "Twój znajomy %s jest w grze, na postaci %s!", name, NickName(id));
		Chat::Output(playerid, GREEN, str);*/
		if(!Player(id, player_friends))
			Player(id, player_friends) = SetTimerEx("HideFriend", 5000, 0, "d", id);
	}
	mysql_free_result();
	return 1;
}

FuncPub::HideFriend(playerid)
{
	PlayerTextDrawHide(playerid, Player(playerid, player_friend));
	Player(playerid, player_friends) = 0;
	return 1;
}

FuncPub::ShowMessages(playerid)
{
	new buffer[ 256 ],
		string[ 360 ];
	format(string, sizeof string,
		"SELECT DISTINCT surv_messages.uid, surv_friends.name, surv_messages.read FROM `surv_messages` JOIN `surv_friends` ON surv_friends.victim = surv_messages.player WHERE surv_messages.victim = '%d' AND surv_messages.type = "#message_type_priv" AND surv_messages.read != '2' ORDER BY surv_messages.time DESC",
		Player(playerid, player_uid)
	);
	mysql_query(string);
	mysql_store_result();
	while(mysql_fetch_row_format(string))
	{
	    static uid,
			name[ 32 ],
	   		read;
	   
		sscanf(string, "p<|>ds[32]d",
			uid,
			name,
			read
		);
	   
		if(!read)
			format(buffer, sizeof buffer, "%s"green"%d\t%s\n", buffer, uid, name);
		else if(read == 1)
			format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, uid, name);
	}
	mysql_free_result();
	if(!isnull(buffer))
		Dialog::Output(playerid, 9, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
	else
	    ShowInfo(playerid, red"Nie masz żadnych wiadomości!");
	return 1;
}

FuncPub::ShowCountOfMessages(playerid)
{
	new count,
		string[ 115 ];
	format(string, sizeof string,
		"SELECT COUNT(*) FROM `surv_messages` WHERE `victim` = '%d' AND `read` = 0 AND `type` = "#message_type_priv"",
		Player(playerid, player_guid)
	);
	mysql_query(string);
	mysql_store_result();
	mysql_fetch_row_format(string);
	count = strval(string);
	mysql_free_result();
	if(count)
	{
		format(string, sizeof string,
			"Masz %d %s! (( /friends wiadomosc ))",
			count,
			dli(count, "nieprzeczytaną wiadomość", "nieprzeczytane wiadomości", "nieprzeczytanych wiadomości")
		);
		Chat::Output(playerid, SZARY, string);
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	if(!Player(playerid, player_logged))
	    return 1;
	if(clickedplayerid == playerid)
	    return 1;

	new result,
		string[ 220 ];
	format(string, sizeof string,
		"SELECT 1 FROM `"IN_PREF"profile_friends` WHERE `friends_member_id` = '%d' AND `friends_friend_id` = '%d'",
		Player(playerid, player_guid),
		Player(clickedplayerid, player_guid)
	);
	mysql_query(string);
	mysql_store_result();
	result = mysql_num_rows();
	mysql_free_result();

    SetPVarInt(playerid, "friend-id", clickedplayerid);

    if(result)
        Dialog::Output(playerid, 4, DIALOG_STYLE_LIST, IN_HEAD, "\
        Informacje\n\
        Wyślij wiadomość\n\
        Skasuj",
        "Wybierz", "Zamknij");
	else
		Dialog::Output(playerid, 4, DIALOG_STYLE_LIST, IN_HEAD, "\
	    Wyślij wiadomość\n\
	    Dodaj do znajomych",
	    "Wybierz", "Zamknij");
	return 1;
}

FuncPub::ShowPlayerFriends(playerid)
{
	new buffer[ 1024 ],
		string[ 360 ],
		count;
	format(string, sizeof string,
		"SELECT DISTINCT f.friends_id, g.members_display_name, f.friends_approved, o.id FROM `"IN_PREF"members` g JOIN `"IN_PREF"profile_friends` f JOIN `surv_players` p ON f.friends_friend_id = g.member_id LEFT JOIN `all_online` o ON p.uid = o.player AND p.guid = g.member_id WHERE f.friends_member_id = '%d'",
		Player(playerid, player_guid)
	);
	mysql_query(string);
	mysql_store_result();
	while(mysql_fetch_row_format(string))
	{
	    static name[ 32 ],
			uid,
			apr,
			idstr[10],
			id;
			
		sscanf(string, "p<|>ds[32]ds[10]",
			uid,
			name,
			apr,
			idstr
		);
		
		if(!isnull(idstr) && !(DIN(idstr, "NULL")))
			id = strval(idstr);
		else
		    id = INVALID_PLAYER_ID;
		    
		if(!apr)
			count++;
		else
		{
		    if(IsPlayerConnected(id))
				format(buffer, sizeof buffer, "%s%d\t"green"%s(ID: %d)\n", buffer, uid, name, id);
		    else
				format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, uid, name);
		}
	}
	mysql_free_result();
	if(count)
	{
		format(buffer, sizeof buffer, "%sDo akceptacji: %d", buffer, count);
	}
	if(isnull(buffer)) ShowInfo(playerid, red"Nie masz przyjaciół!");
	else
	{
	    format(buffer, sizeof buffer, "Lista znajomych:\n%s", buffer);
		Dialog::Output(playerid, 3, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
	}
	return 1;
}

FuncPub::Friends_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case 3:
	    {
	        if(!response) return 1;
	        new frienduid = strval(inputtext),
	       		friendid = -1,
	        	znak = strfind(inputtext, "(ID:");
	        	
	        if(znak != -1)
	        {
	        	strdel(inputtext, 0, znak+5);
	        	friendid = strval(inputtext);
	        }
	        
	        SetPVarInt(playerid, "friend-uid", frienduid);
	        
            if(IsPlayerConnected(friendid))
            {
				SetPVarInt(playerid, "friend-id", friendid);
		        Dialog::Output(playerid, 4, DIALOG_STYLE_LIST, IN_HEAD, "\
		        Informacje\n\
		        Wyślij wiadomość\n\
		        Skasuj",
		        "Wybierz", "Zamknij");
			}
			else
		        Dialog::Output(playerid, 4, DIALOG_STYLE_LIST, IN_HEAD, "\
		        Informacje\n\
		        Zostaw wiadomość\n\
		        Skasuj",
		        "Wybierz", "Zamknij");
	    }
	    case 4:
	    {
	        if(!response)
	        {
	            DeletePVar(playerid, "friend-id");
	            DeletePVar(playerid, "friend-uid");
	            return 1;
	        }
	        if(DIN(inputtext, "Wyślij wiadomość"))
	        {
	            Dialog::Output(playerid, 5, DIALOG_STYLE_INPUT, IN_HEAD, "Wpisz treść wiadomości, którą chcesz wysłać.", "Wyślij", "Anuluj");
	        }
	        else if(DIN(inputtext, "Zostaw wiadomość"))
	        {
	            Dialog::Output(playerid, 8, DIALOG_STYLE_INPUT, IN_HEAD, "Wpisz treść wiadomości, którą chcesz zostawić.", "Wyślij", "Anuluj");
	        }
/*	        else if(DIN(inputtext, "Zmień nazwę"))
	        {
	            Dialog::Output(playerid, 6, DIALOG_STYLE_INPUT, IN_HEAD, "Podaj nową nazwę przyjaciela.", "Zapisz", "Anuluj");
	        }
	        else if(DIN(inputtext, "Skasuj"))
	        {
	            Dialog::Output(playerid, 7, DIALOG_STYLE_MSGBOX, IN_HEAD, "Czy na pewno chcesz skasować tego przyjaciela?", "Tak", "Nie");
	        }*/
	        else if(DIN(inputtext, "Dodaj do znajomych"))
	        {
	            new friendid = GetPVarInt(playerid, "friend-id"),
		        	result,
					string[ 128 ];
				format(string, sizeof string, "SELECT 1 FROM `"IN_PREF"profile_friends` WHERE `friends_member_id` = '%d' AND `friends_friend_id` = '%d'", Player(playerid, player_guid), Player(friendid, player_guid));
		        mysql_query(string);
		        mysql_store_result();
				result = mysql_num_rows();
				mysql_free_result();
				if(result)
				    return ShowInfo(playerid, red"Ten gracz należy już do grupy Twoich przyjaciół!");

				format(string, sizeof string, "INSERT INTO `"IN_PREF"profile_friends` VALUES (NULL, '%d', '%d', '0', UNIX_TIMESTAMP())", Player(playerid, player_guid), Player(friendid, player_guid));
				mysql_query(string);
				
				format(string, sizeof string, green"%s został dodany do listy Twoich znajomych!", NickName(friendid));
				Chat::Output(playerid, 0, string);
				
				format(string, sizeof string, green"Gracz %s dodał Cię do znajomych, aby potwierdzić wpisz /friends!", NickName(playerid));
				Chat::Output(friendid, 0, string);
	        }
	        else if(DIN(inputtext, "Informacje"))
	        {
	            new friendid = GetPVarInt(playerid, "friend-id"),
	           		frienduid = GetPVarInt(playerid, "friend-uid"),
		            string[ 150 ],
		            buffer[ 256 ];
	            if(friendid)
	            {
			        new result;
					format(string, sizeof string,
						"SELECT 1 FROM `"IN_PREF"profile_friends` WHERE `friends_member_id` = '%d' AND `friends_friend_id` = '%d' AND `friends_approved` = '1'",
						Player(playerid, player_uid),
						Player(friendid, player_uid)
					);
			        mysql_query(string);
			        mysql_store_result();
					result = mysql_num_rows();
					mysql_free_result();
					
	                format(buffer, sizeof buffer, "Zalogowany:\t"green"Tak\n");
	                format(buffer, sizeof buffer, "%sNick OOC:\t%s (%d)\n", buffer, Player(friendid, player_gname), Player(playerid, player_guid));
	                format(buffer, sizeof buffer, "%sNick IC:\t\t%s (%d)\n", buffer, NickName(friendid), Player(playerid, player_uid));
	                if(result)
	                {
	                    new timeStr[ 45 ],
							timeStr2[ 45 ];
							
						ReturnTime(Player(playerid, player_timehere)[ 0 ], timeStr);
						ReturnTime(Player(playerid, player_timehere)[ 1 ], timeStr2);
						format(buffer, sizeof buffer, "%sCzas gry:\t%s\n", buffer, timeStr);
						format(buffer, sizeof buffer, "%sGra od:\t%s\n", buffer, timeStr2);
	                	format(buffer, sizeof buffer, "%sWizyt:\t\t%s\n", buffer, Player(friendid, player_visits));
	                }
	                ShowList(playerid, buffer);
	            }
	            else
	            {
					new gname[ 120 ],
						guid;
	        		#if Forum == 1 // MyBB
						format(buffer, sizeof buffer, "SELECT mybb_users.username, mybb_users.uid FROM `mybb_users` JOIN `surv_players` ON surv_players.guid = mybb_users.uid JOIN `surv_friends` ON surv_friends.victim = surv_players.uid WHERE surv_friends.uid = '%d'", frienduid);
					#elseif Forum == 2 // IPB
						format(buffer, sizeof buffer, "SELECT m.members_display_name, m.member_id FROM `"IN_PREF"members` m JOIN `"IN_PREF"profile_friends` f ON f.friends_friend_id = m.member_id WHERE f.friends_id = '%d'", frienduid);
					#endif
			        mysql_query(buffer);
			        mysql_store_result();
					mysql_fetch_row(string);
					sscanf(string, "p<|>s[120]d",
						gname,
						guid
					);
					mysql_free_result();

	                format(buffer, sizeof buffer, "Zalogowany:\t"red"Nie\n");
	                format(buffer, sizeof buffer, "%sNick OOC:\t%s (%d)\n", buffer, gname, guid);
	                ShowList(playerid, buffer);
	            }
	        }
	    }
	    case 5:
	    {
	        if(!response)
	        {
	            DeletePVar(playerid, "friend-id");
	            DeletePVar(playerid, "friend-uid");
	            return 1;
	        }
			new friendid = GetPVarInt(playerid, "friend-id"),
				string[ 128 ];
			format(string, sizeof string,
				"%d %s",
				friendid,
				inputtext
			);
			cmd_w(playerid, string);
			
            DeletePVar(playerid, "friend-id");
            DeletePVar(playerid, "friend-uid");
	    }
	    case 6:
	    {
	        if(!response)
	        {
	            DeletePVar(playerid, "friend-id");
	            DeletePVar(playerid, "friend-uid");
	            return 1;
	        }
	        new frienduid = GetPVarInt(playerid, "friend-uid"),
				string[ 120 ];
	        mysql_real_escape_string(inputtext, inputtext);
	        
	        format(string, sizeof string,
				"UPDATE `surv_friends` SET `name` = '%s' WHERE `uid` = '%d'",
				inputtext,
				frienduid
			);
	        mysql_query(string);
	        
            DeletePVar(playerid, "friend-id");
            DeletePVar(playerid, "friend-uid");
            
            ShowInfo(playerid, green"Nazwa została zmieniona pomyślnie!");
	    }
	    case 7:
	    {
	        if(!response)
	        {
	            DeletePVar(playerid, "friend-id");
	            DeletePVar(playerid, "friend-uid");
	            return 1;
	        }
	        new frienduid = GetPVarInt(playerid, "friend-uid"),
				string[ 120 ];

	        format(string, sizeof string,
				"DELETE FROM `surv_friends` WHERE `uid` = '%d'",
				frienduid
			);
	        mysql_query(string);

            DeletePVar(playerid, "friend-id");
            DeletePVar(playerid, "friend-uid");
            
            ShowInfo(playerid, green"Przyjaciel został skasowany!");
	    }
	    case 8:
	    {
	        if(!response)
	        {
	            DeletePVar(playerid, "friend-id");
	            DeletePVar(playerid, "friend-uid");
	            return 1;
	        }

	        new frienduid = GetPVarInt(playerid, "friend-uid"),
				pl_uid,
				string[ 256 ];
			format(string, sizeof string,
				"SELECT surv_players.uid FROM `surv_players` JOIN `surv_friends` ON surv_players.uid = surv_friends.victim WHERE surv_friends.uid = '%d'",
				frienduid
			);
	        mysql_query(string);
	        mysql_store_result();
			pl_uid = mysql_fetch_int();
			mysql_free_result();
			
	        new result;
			format(string, sizeof string, "SELECT 1 FROM `surv_friends` WHERE `player` = '%d' AND `victim` = '%d'", pl_uid, Player(playerid, player_uid));
	        mysql_query(string);
	        mysql_store_result();
			result = mysql_num_rows();
			mysql_free_result();
			if(!result)
			    return ShowInfo(playerid, red"Nie możesz zostawić temu graczowi wiadomości! Nie jesteś dodany przez niego do przyjaciół!");

	        mysql_real_escape_string(inputtext, inputtext);
			format(string, sizeof string, "INSERT INTO `surv_messages`(`player`, `victim`, `time`, `text`, `type`) VALUES ('%d', '%d', UNIX_TIMESTAMP(), '%s', "#message_type_priv")", Player(playerid, player_uid), pl_uid, inputtext);
			mysql_query(string);
			
            DeletePVar(playerid, "friend-id");
            DeletePVar(playerid, "friend-uid");

            ShowInfo(playerid, green"Wiadomość została wysłana!");
	    }
	    case 9:
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
	        
	        new name[ 32 ],
				text[ 128 ],
				date[ 32 ],
				createtime;
			format(string, sizeof string, "SELECT surv_friends.name, surv_messages.text, surv_messages.time FROM `surv_messages` JOIN `surv_friends` ON surv_friends.victim = surv_messages.player WHERE surv_messages.uid = '%d'", muid);
	        mysql_query(string);
	        mysql_store_result();
			mysql_fetch_row(string);
			sscanf(string, "p<|>s[32]s[128]d",
			    name,
			    text,
			    createtime
			);
			mysql_free_result();
			
			ReturnTimeAgo(createtime, date);
			
			format(string, sizeof string, "Od: %s\nData: %s\n\nTreść:\n%s", name, date, text);
            Dialog::Output(playerid, 12, DIALOG_STYLE_MSGBOX, IN_HEAD, string, "Zamknij", "Skasuj");
	    }
	    case 12:
	    {
	        if(response) return DeletePVar(playerid, "message-uid");
	        new muid = GetPVarInt(playerid, "message-uid"),
				string[ 70 ];
	        
	        format(string, sizeof string,
				"UPDATE `surv_messages` SET `read` = '2' WHERE `uid` = '%d'",
				muid
			);
	        mysql_query(string);
	        
	        ShowInfo(playerid, green"Wiadomość skasowana pomyślnie!");
	        
	        DeletePVar(playerid, "message-uid");
	    }
	}
	return 1;
}

Cmd::Input->friends(playerid, params[])
{
	if(DIN(params, "wiadomosc"))
	    ShowMessages(playerid);
	else
		ShowPlayerFriends(playerid);
	return 1;
}
