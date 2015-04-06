stock wordwrap(string[], len = sizeof string)
{
	if(!string[ 0 ]) return 0;
	
	new pos = strfind(string, " "),
		space;
	while(pos != -1)
	{
		space++;
		
		if(space == 6)
		{
			strins(string, "\n", pos + 1, len);
			space = 0;
		}
		pos = strfind(string, " ", true, pos + 1);
	}
	return 1;
}

FuncPub::LoadPlayerOpis(playerid)
{
	if(!Player(playerid, player_opis))
	{
		Player(playerid, player_opis_id) = Text3D:INVALID_3DTEXT_ID;
	    return 1;
	}
	    
	new buffer[ 128 ],
		string[ 128 ];
	format(buffer, sizeof buffer,
		"SELECT `opis` FROM `surv_opis` WHERE `uid` = '%d'",
	    Player(playerid, player_opis)
	);
	mysql_query(buffer);
	mysql_store_result();
	mysql_fetch_row(string);
	mysql_free_result();
	if(Player(playerid, player_opis_id) == Text3D:INVALID_3DTEXT_ID && !isnull(string))
	{
		wordwrap(string);
		Player(playerid, player_opis_id) = Create3DTextLabel(string, opis_color, 0.0, 0.0, 0.0, 5.0, 0, 1);
		Attach3DTextLabelToPlayer(Player(playerid, player_opis_id), playerid, 0.0, 0.0, -0.6);
	}
	return 1;
}

FuncPub::Opis_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case 74:
	    {
	        if(!response) return 1;
	        
	        if(DIN(inputtext, "Nowy"))
	            return Dialog::Output(playerid, 76, DIALOG_STYLE_INPUT, IN_HEAD, white"Wpisz treść opisu:", "Stwórz", "Zamknij");
            if(DIN(inputtext, "- Wyłącz"))
            {
            	if(Player(playerid, player_opis_id) != Text3D:INVALID_3DTEXT_ID)
				{
				    Delete3DTextLabel(Player(playerid, player_opis_id));
				    Player(playerid, player_opis_id) = Text3D:INVALID_3DTEXT_ID;
				    Player(playerid, player_opis) = 0;
			    }

			    ShowInfo(playerid, "Opis wyłączony!");
				return 1;
			}
			new opisuid;
			if(sscanf(inputtext, "d", opisuid)) return 1;
	        SetPVarInt(playerid, "opis-uid", opisuid);
	        if(Player(playerid, player_opis) == opisuid)
	        	Dialog::Output(playerid, 77, DIALOG_STYLE_LIST, IN_HEAD, "Wyłącz\nSkasuj", "Wybierz", "Wróć");
	        else
	        	Dialog::Output(playerid, 77, DIALOG_STYLE_LIST, IN_HEAD, "Użyj\nSkasuj", "Wybierz", "Wróć");
	    }
	    case 76:
	    {
	        if(!response) return 1;
	        
	        new string[ 256 ];
	        if(strlen(inputtext) > 128)
				strdel(inputtext, 128, strlen(inputtext));
	        
	        EscapePL(inputtext);
	        mysql_real_escape_string(inputtext, inputtext);
	        format(string, sizeof string,
	            "INSERT INTO `surv_opis` VALUES (NULL, '"#text_owner_player"', '%d', '%s')",
				Player(playerid, player_uid),
				inputtext
			);
			mysql_query(string);
			
			format(string, sizeof string, inputtext);
			
			wordwrap(string);
			Player(playerid, player_opis) = mysql_insert_id();
			if(Player(playerid, player_opis_id) == Text3D:INVALID_3DTEXT_ID)
			{
				Player(playerid, player_opis_id) = Create3DTextLabel(string, opis_color, 0.0, 0.0, 0.0, 5.0, 0, 1);
				Attach3DTextLabelToPlayer(Player(playerid, player_opis_id), playerid, 0.0, 0.0, -0.6);
			}
			else Update3DTextLabelText(Player(playerid, player_opis_id), opis_color, string);
			ShowInfo(playerid, string);
	    }
	    case 77:
	    {
	        if(!response) return cmd_opis(playerid, "");
			new opisuid = GetPVarInt(playerid, "opis-uid");
			if(DIN(inputtext, "Użyj"))
			{
				new buffer[ 126 ], string[ 160 ];
				format(buffer, sizeof buffer,
					"SELECT `opis` FROM `surv_opis` WHERE `uid` = '%d' AND `type` = '"#text_owner_player"' AND `id` = '%d'",
				    opisuid,
				    Player(playerid, player_uid)
				);
				mysql_query(buffer);
				mysql_store_result();
				mysql_fetch_row(string);
				mysql_free_result();
				EscapePL(string);
				wordwrap(string);
				Player(playerid, player_opis) = opisuid;
				if(Player(playerid, player_opis_id) == Text3D:INVALID_3DTEXT_ID)
				{
					Player(playerid, player_opis_id) = Create3DTextLabel(string, opis_color, 0.0, 0.0, 0.0, 5.0, 0, 1);
					Attach3DTextLabelToPlayer(Player(playerid, player_opis_id), playerid, 0.0, 0.0, -0.6);
				}
				else Update3DTextLabelText(Player(playerid, player_opis_id), opis_color, string);

				ShowInfo(playerid, string);
			}
			else if(DIN(inputtext, "Skasuj"))
			{
				new buffer[ 64 ];
				format(buffer, sizeof buffer,
					"DELETE FROM `surv_opis` WHERE `uid` = '%d'",
				    opisuid
				);
				mysql_query(buffer);
				
				if(opisuid == Player(playerid, player_opis))
				{
				    Delete3DTextLabel(Player(playerid, player_opis_id));
			    	Player(playerid, player_opis_id) = Text3D:INVALID_3DTEXT_ID;
			    	Player(playerid, player_opis) = 0;
				}
				
				ShowInfo(playerid, "Opis skasowany!");
			}
			else if(DIN(inputtext, "Wyłącz"))
			{
			    if(Player(playerid, player_opis_id) != Text3D:INVALID_3DTEXT_ID)
				{
				    Delete3DTextLabel(Player(playerid, player_opis_id));
				    Player(playerid, player_opis_id) = Text3D:INVALID_3DTEXT_ID;
				    Player(playerid, player_opis) = 0;
			    }
			    
			    ShowInfo(playerid, "Opis wyłączony!");
			}
	    }
	}
	return 1;
}

Cmd::Input->opis(playerid, params[])
{
	new buffer[ 2058 ],
		string[ 160 ],
		count;
	if(isnull(params))
	{
		format(string, sizeof string,
			"SELECT `uid`, `opis` FROM `surv_opis` WHERE `type` = '"#text_owner_player"' AND `id` = '%d'",
		    Player(playerid, player_uid)
		);
		mysql_query(string);
		mysql_store_result();
		while(mysql_fetch_row(string))
		{
		    static uid,
				name[ 130 ],
				len;

			sscanf(string, "p<|>ds[126]",
				uid,
				name
			);
			len = strlen(name);
			count++;

			if(len >= max_c)
			{
			    strdel(name, max_c, len);
			    strcat(name, "...");
			}
			if(Player(playerid, player_opis) == uid)
				format(buffer, sizeof buffer, "- Aktualnie używany: "gui_active"%s\n- Wyłącz\n \nOstatnio używane:\n%s", name, buffer);

			if(Player(playerid, player_opis) == uid)
				format(buffer, sizeof buffer, "%s%d\t"gui_active"%s\n", buffer, uid, name);
			else
				format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, uid, name);
		}
		mysql_free_result();
		strcat(buffer, "Nowy\n");
		if(!count)
			Dialog::Output(playerid, 76, DIALOG_STYLE_INPUT, IN_HEAD, white"Wpisz treść opisu:", "Stwórz", "Zamknij");
		else
			Dialog::Output(playerid, 74, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
	}
	else
	{
	    if(!strcmp(params, "usun", true) || !strcmp(params, "usuń", true))
	    {
		    if(Player(playerid, player_opis_id) != Text3D:INVALID_3DTEXT_ID)
			{
			    Delete3DTextLabel(Player(playerid, player_opis_id));
			    Player(playerid, player_opis_id) = Text3D:INVALID_3DTEXT_ID;
			    Player(playerid, player_opis) = 0;
				ShowCMD(playerid, "Opis skasowany!");
		    }
			else ShowCMD(playerid, "Nie masz żadnego opisu!");
	    }
	    else
	    {
			format(string, sizeof string, params);
			wordwrap(string);
			Player(playerid, player_opis) = 0;
			if(Player(playerid, player_opis_id) == Text3D:INVALID_3DTEXT_ID)
			{
				Player(playerid, player_opis_id) = Create3DTextLabel(string, opis_color, 0.0, 0.0, 0.0, 5.0, 0, 1);
				Attach3DTextLabelToPlayer(Player(playerid, player_opis_id), playerid, 0.0, 0.0, -0.6);
			}
			else Update3DTextLabelText(Player(playerid, player_opis_id), opis_color, string);
			format(string, sizeof string, white"Opis do czasu wyjścia z serwera:\n\n%s", string);
			ShowInfo(playerid, string);
		}
	}
	return 1;
}
