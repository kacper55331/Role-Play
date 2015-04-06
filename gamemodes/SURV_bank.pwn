/* TODO:
 - opłaty..
 
*/

FuncPub::Bank_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case 18:
		{
			if(!response || !listitem) return Bank_Clear(playerid);
			new string[ 126 ],
				number = strval(inputtext);
			if(Bankomat(playerid, bank_bankomate))
			{
				format(string, sizeof string, "SELECT `v2` FROM `surv_items` WHERE `v1` = '%d'", number);
				mysql_query(string);
				mysql_store_result();
				new bool:reason;
				if(mysql_fetch_int())
					reason = true;
				mysql_free_result();
				
				if(reason) return ShowInfo(playerid, red"Ta karta została zablokowana!");
			}
			Bankomat(playerid, bank_number) = number;
			
			format(string, sizeof string, "SELECT `name` FROM `surv_bank` WHERE `number` = '%d'", Bankomat(playerid, bank_number));
			mysql_query(string);
			mysql_store_result();
			if(mysql_num_rows())
    	    	Dialog::Output(playerid, 19, DIALOG_STYLE_PASSWORD, IN_HEAD, bank_pin, "Dalej", "Zamknij");
			else
			{
			    ShowInfo(playerid, bank_deactive);
				Bank_Clear(playerid);
			}
			mysql_free_result();
		}
		case 19:
		{
    	    if(!response) return Bank_Clear(playerid);
    	    
    	    if(isnull(inputtext) || strlen(inputtext) > 32)
				return Dialog::Output(playerid, 19, DIALOG_STYLE_PASSWORD, IN_HEAD, bank_pin, "Dalej", "Zamknij");

			new string[ 128 ];
            mysql_real_escape_string(inputtext, inputtext);
            format(string, sizeof string, "SELECT `cash`, `name` FROM `surv_bank` WHERE `pin` = '%s' AND `number` = '%d'", inputtext, Bankomat(playerid, bank_number));
            mysql_query(string);
            mysql_store_result();
		    if(mysql_num_rows())
		    {
				mysql_fetch_row(string);
				sscanf(string, "p<|>fs[32]", 
					Bankomat(playerid, bank_cash),
					Bankomat(playerid, bank_name)
				);
            	
				Bank_Default(playerid);
            }
		    else
		    {
    	    	Dialog::Output(playerid, 19, DIALOG_STYLE_PASSWORD, IN_HEAD, bank_pin, "Dalej", "Zamknij");
				GameTextForPlayer(playerid, "~n~~n~~n~~r~~h~Podales bledne haslo!", 5000, 5);
		    }
            mysql_free_result();
		}
		case 20:
		{
    	    if(!response) return Bank_Clear(playerid);
    	    
		    if(DIN(inputtext, "Wypłać"))
		    {
		        new string[ 120 ];
		        format(string, sizeof string,
					bank_wyplac,
					Bankomat(playerid, bank_cash)
				);
		        Dialog::Output(playerid, 24, DIALOG_STYLE_INPUT, IN_HEAD, string, "Wypłać", "Wróć");
		    }
		    else if(DIN(inputtext, "Wpłać"))
		    {
		        Dialog::Output(playerid, 25, DIALOG_STYLE_INPUT, IN_HEAD, bank_wplac, "Wpłać", "Wróć");
		    }
		    else if(DIN(inputtext, "Sprawdź stan konta"))
		    {
		        new string[ 60 ];
		        format(string, sizeof string, white"Stan konta: "green"$%.2f", Bankomat(playerid, bank_cash));
		        Dialog::Output(playerid, 21, DIALOG_STYLE_MSGBOX, IN_HEAD, string, "OK", "");
		    }
			else if(DIN(inputtext, "Informacje o koncie"))
			{
				new string[ 256 ];
				format(string, sizeof string, white"Nazwa konta:\t%s\n", Bankomat(playerid, bank_name));
				format(string, sizeof string, "%sStan konta:\t$%.2f\n", string, Bankomat(playerid, bank_cash));
				format(string, sizeof string, "%sWłaściciel:\n\t%s\n", string, GetBankOwner(Bankomat(playerid, bank_number)));
				if(Bankomat(playerid, bank_cash) >= 2000)
				    GivePlayerAchiv(playerid, achiv_bank);
				    
				Dialog::Output(playerid, 21, DIALOG_STYLE_MSGBOX, IN_HEAD, string, "OK", "");
			}
		    else if(DIN(inputtext, "Zmień PIN"))
		    {
		        Dialog::Output(playerid, 22, DIALOG_STYLE_PASSWORD, IN_HEAD, bank_newpin, "Dalej", "Wróć");
		    }
		    else if(DIN(inputtext, "Informacje o bankomacie"))
		    {
			    new string[ 160 ];
		        if(Bankomat(playerid, bank_owner))
		        {
					new groupname[ MAX_ITEM_NAME ];
			        format(string, sizeof string, "SELECT `name` FROM `surv_groups` WHERE `uid` = '%d'", Bankomat(playerid, bank_owner));
			        mysql_query(string);
			        mysql_store_result();
			        mysql_fetch_row(groupname);
			        mysql_free_result();
			        
			        format(string, sizeof string, white"Właściciel: "C_BLUE2"%s\n"white"Użycie bankomatu: "C_BLUE2"$%.2f"bank_info"", groupname, Bankomat(playerid, bank_value)[ 1 ]);
		        }
		        else
		            format(string, sizeof string, white"Właściciel: "C_BLUE2"publiczny\n"white"Użycie bankomatu: "C_BLUE2"$%.2f"bank_info"", Setting(setting_bank));

		        Dialog::Output(playerid, 21, DIALOG_STYLE_MSGBOX, IN_HEAD, string, "OK", "");
		    }
		    else if(DIN(inputtext, "Zablokuj konto"))
		    {
		        Dialog::Output(playerid, 23, DIALOG_STYLE_PASSWORD, IN_HEAD, bank_block, "Zablokuj", "Wróć");
		    }
		    else if(DIN(inputtext, "Zablokuj kartę"))
		    {
		        new buffer[ 256 ],
					string[ 32 ],
					id;
		        format(buffer, sizeof buffer, "SELECT `uid`, `name` FROM `surv_items` WHERE `v1` = '%d' AND `v2` = '0'", Bankomat(playerid, bank_number));
		        mysql_query(buffer);
		        mysql_store_result();
		        buffer = "Wybierz kartę, którą chcesz zablokować:\n";
		        while(mysql_fetch_row(string))
		        {
		            static uid,
						name[ MAX_ITEM_NAME ];
		            sscanf(string, "p<|>ds["#MAX_ITEM_NAME"]",
						uid,
						name
					);
					format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, uid, name);
					
					id++;
		        }
				mysql_free_result();
				if(!id) return Dialog::Output(playerid, 21, DIALOG_STYLE_MSGBOX, IN_HEAD, red"Brak dostępnych kart!", "OK", "");
				Dialog::Output(playerid, 27, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Wróć");
		    }
		    else if(DIN(inputtext, "Historia"))
		    {
		        new buffer[ 512 ],
					string[ 124 ];
		        format(string, sizeof string, "SELECT `time`, `name` FROM `surv_bank_log` WHERE `number` = '%d' ORDER BY `time` DESC LIMIT 10", Bankomat(playerid, bank_number));
		        mysql_query(string);
		        mysql_store_result();
		        buffer = "Ostatnie 10 użyć konta:\n";
		        while(mysql_fetch_row(string))
		        {
					static date,
						name[ 64 ],
						dateStr[ 32 ];
						
					sscanf(string, "p<|>ds[64]",
					    date,
					    name
					);
					ReturnTimeAgo(date, dateStr);

					format(buffer, sizeof buffer, "%s%s\t%s\n", buffer, dateStr, name);
				}
				mysql_free_result();
				Dialog::Output(playerid, 21, DIALOG_STYLE_LIST, IN_HEAD, buffer, "OK", "");
		    }
			else if(DIN(inputtext, "Zmień nazwę konta"))
			{
				Dialog::Output(playerid, 73, DIALOG_STYLE_INPUT, IN_HEAD, bank_chname, "Zmień", "Wróć");
			}
			else if(DIN(inputtext, "Wyrób kartę"))
			{
			    new string[ MAX_ITEM_NAME ];
				format(string, sizeof string, "Karta(%d)", Bankomat(playerid, bank_number));
				Createitem(playerid, item_karta, Bankomat(playerid, bank_number), 0, 1.0, string, 1);
				Dialog::Output(playerid, 21, DIALOG_STYLE_MSGBOX, IN_HEAD, "Karta do bankomatu wyrobiona.", "Wróć", "");
			}
		}
		case 21:
		{
            Bank_Default(playerid);
		}
		case 22:
		{
		    if(!response) return Bank_Default(playerid);
			if(!strval(inputtext)) return Dialog::Output(playerid, 115, DIALOG_STYLE_PASSWORD, IN_HEAD, bank_newpin, "Dalej", "Wróć");
		    new string[ 128 ];
			mysql_real_escape_string(inputtext, inputtext);
			
			format(string, sizeof string, "UPDATE `surv_bank` SET `pin`='%s' WHERE `number`=%d", inputtext, Bankomat(playerid, bank_number));
            mysql_query(string);

            format(string, sizeof string, white"Kod PIN został zmieniony pomyślnie.\n"red"Nowy pin:\t\t\t%s", inputtext);
			Dialog::Output(playerid, 21, DIALOG_STYLE_MSGBOX, IN_HEAD, string, "OK", "");
		}
		case 23:
		{
		    if(!response) return Bank_Default(playerid);
    	    if(isnull(inputtext) || strlen(inputtext) > 32)
				return Dialog::Output(playerid, 23, DIALOG_STYLE_PASSWORD, IN_HEAD, bank_block, "Zablokuj", "Wróć");

			new string[ 128 ],
				num;
            mysql_real_escape_string(inputtext, inputtext);
            format(string, sizeof string, "SELECT 1 FROM `surv_bank` WHERE `pin` = '%s' AND `number` = '%d'", inputtext, Bankomat(playerid, bank_number));
            mysql_query(string);
            mysql_store_result();
            num = mysql_num_rows();
			mysql_free_result();
		    if(num)
		    {
			    SetPlayerMoney(playerid, Player(playerid, player_cash) += Bankomat(playerid, bank_cash));

			   	format(string, sizeof string, "DELETE FROM `surv_bank` WHERE `number`='%d'", Bankomat(playerid, bank_number));
			   	mysql_query(string);

			   	format(string, sizeof string, "DELETE FROM `surv_bank_log` WHERE `number`='%d'", Bankomat(playerid, bank_number));
			   	mysql_query(string);
			   	
			   	ShowInfo(playerid, green"Konto zablokowane pomyślnie!");

			    Bank_Clear(playerid);
            }
		    else
		    {
    	    	Dialog::Output(playerid, 23, DIALOG_STYLE_PASSWORD, IN_HEAD, bank_block, "Zablokuj", "Wróć");
				GameTextForPlayer(playerid, "~n~~n~~n~~r~~h~Podales bledne haslo!", 5000, 5);
		    }
		}
		case 24:
		{
		    if(!response) return Bank_Default(playerid);
		    if(!Bankomat(playerid, bank_cash))
		    {
		        Bank_Default(playerid);
		    	GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~r~~h~Twoje konto w banku jest puste!", 5000, 5);
				return 1;
		    }
			new Float:cash = floatstr(inputtext);
			if(cash <= 0)
			    return Dialog::Output(playerid, 21, DIALOG_STYLE_MSGBOX, IN_HEAD, red"Kwota musi być większa od $0", "Wróć", "");
			if(cash > 10000)
			    return Dialog::Output(playerid, 21, DIALOG_STYLE_MSGBOX, IN_HEAD, red"Kwota musi być mniejsza niż $10000", "Wróć", "");
			if(Bankomat(playerid, bank_cash) < cash)
			{
			    new string[ 120 ];
		        format(string, sizeof string,
					bank_wyplac,
					Bankomat(playerid, bank_cash)
				);
		        Dialog::Output(playerid, 24, DIALOG_STYLE_INPUT, IN_HEAD, string, "Wypłać", "Wróć");
				GameTextForPlayer(playerid, "~n~~n~~n~~r~~h~Nie masz tyle gotowki na koncie.", 5000, 5);
				return 1;
			}
		    GivePlayerMoneyEx(playerid, cash, true);
			Bankomat(playerid, bank_cash) -= floatadd(cash, (Bankomat(playerid, bank_bankomate)) ? (Bankomat(playerid, bank_value)[ 1 ]) : (0.0));
		        
		    new string[ 256 ];
		    format(string, sizeof string, "UPDATE `surv_bank` SET `cash` = `cash` - '%.2f' WHERE `number` = '%d'", cash, Bankomat(playerid, bank_number));
		    mysql_query(string);
		    
		    if(Bankomat(playerid, bank_bankomate))
		    	format(string, sizeof string, "Wyplata bankomat $%.2f + $%.2f. Stan: $%.2f.", cash, Bankomat(playerid, bank_value)[ 1 ], Bankomat(playerid, bank_cash));
			else
		    	format(string, sizeof string, "Wyplata $%.2f. Stan: $%.2f", cash, Bankomat(playerid, bank_cash));

			mysql_real_escape_string(string, string);
			format(string, sizeof string, "INSERT INTO `surv_bank_log` VALUE (NULL, UNIX_TIMESTAMP(), '%d', '%s')", Bankomat(playerid, bank_number), string);
			mysql_query(string);

			format(string, sizeof string, bank_wyplata, (Player(playerid, player_sex) == sex_woman) ? ("a") : ("e"), cash, Bankomat(playerid, bank_cash));
			Dialog::Output(playerid, 21, DIALOG_STYLE_MSGBOX, IN_HEAD, string, "Wróć", "");
		}
		case 25:
		{
		    if(!response) return Bank_Default(playerid);
			
			new Float:cash = floatstr(inputtext);
			
			if(cash <= 0)
			    return Dialog::Output(playerid, 21, DIALOG_STYLE_MSGBOX, IN_HEAD, red"Kwota musi być większa od $0", "Wróć", "");
			if(cash > 10000)
			    return Dialog::Output(playerid, 21, DIALOG_STYLE_MSGBOX, IN_HEAD, red"Kwota musi być mniejsza niż $10000", "Wróć", "");

			if(Player(playerid, player_cash) < cash)
			{
		        Dialog::Output(playerid, 25, DIALOG_STYLE_INPUT, IN_HEAD, bank_wplac, "Wpłać", "Wróć");
				GameTextForPlayer(playerid, "~n~~n~~n~~r~~h~Nie masz tyle gotowki.", 5000, 5);
				return 1;
			}
			
		    GivePlayerMoneyEx(playerid, 0 - cash, true);
		    Bankomat(playerid, bank_cash) += cash;
		    
		    new string[ 150 ];
		    format(string, sizeof string, "UPDATE `surv_bank` SET `cash` = `cash` + '%.2f' WHERE `number` = '%d'", cash, Bankomat(playerid, bank_number));
		    mysql_query(string);

		    format(string, sizeof string, "Wplata $%.2f. Stan: $%.2f", cash, Bankomat(playerid, bank_cash)); mysql_real_escape_string(string, string);
		    format(string, sizeof string, "INSERT INTO `surv_bank_log` VALUE (NULL, UNIX_TIMESTAMP(), '%d', '%s')", Bankomat(playerid, bank_number), string);
			mysql_query(string);

			format(string, sizeof string, bank_wplata, (Player(playerid, player_sex) == sex_woman) ? ("a") : ("e"), cash, Bankomat(playerid, bank_cash));
			Dialog::Output(playerid, 21, DIALOG_STYLE_MSGBOX, IN_HEAD, string, "Wróć", "");
		}
		case 27:
		{
		    if(!response || !listitem) return Bank_Default(playerid);
			
			new itemuid = strval(inputtext),
				string[ 120 ];
				
		    format(string, sizeof string, "UPDATE `surv_items` SET `v2` = '1' WHERE `uid` = '%d'", itemuid);
		    mysql_query(string);
		    
			Dialog::Output(playerid, 21, DIALOG_STYLE_MSGBOX, IN_HEAD, bank_karte, "Wróć", "");
		}
		case 32:
		{
		    if(!response) return Bank_Clear(playerid);
			new number = strval(inputtext);
			Bankomat(playerid, bank_number) = number;

			Dialog::Output(playerid, 33, DIALOG_STYLE_PASSWORD, IN_HEAD, bank_pin, "Dalej", "Zamknij");
		}
		case 33:
		{
		    if(!response) return Bank_Clear(playerid);
			
    	    if(isnull(inputtext) || strlen(inputtext) > 32)
				return Dialog::Output(playerid, 19, DIALOG_STYLE_PASSWORD, IN_HEAD, bank_pin, "Dalej", "Zamknij");

			new string[ 128 ];
            mysql_real_escape_string(inputtext, inputtext);
            format(string, sizeof string, "SELECT `cash` FROM `surv_bank` WHERE `pin` = '%s' AND `number` = '%d'", inputtext, Bankomat(playerid, bank_number));
            mysql_query(string);
            mysql_store_result();
		    if(mysql_num_rows())
		    {
				Dialog::Output(playerid, 34, DIALOG_STYLE_INPUT, IN_HEAD, bank_checkbox, "Dalej", "Zamknij");
            }
		    else
		    {
    	    	Dialog::Output(playerid, 33, DIALOG_STYLE_PASSWORD, IN_HEAD, bank_pin, "Dalej", "Zamknij");
				GameTextForPlayer(playerid, "~n~~n~~n~~r~~h~Podales bledne haslo!", 5000, 5);
		    }
            mysql_free_result();
		}
		case 34:
		{
		    if(!response) return Bank_Clear(playerid);

			new Float:kasa = floatstr(inputtext);
			if(kasa <= 0)
			    return Dialog::Output(playerid, 34, DIALOG_STYLE_INPUT, IN_HEAD, bank_checkbox, "Dalej", "Zamknij");

			new itm_name[ MAX_ITEM_NAME ],
				buffer[ 126 ];
			format(itm_name, sizeof itm_name, "Czek na $%.2f", kasa);
            Createitem(playerid, item_check, Bankomat(playerid, bank_number), 1, kasa, itm_name, 1);

            format(buffer, sizeof buffer, bank_check, (Player(playerid, player_sex) == sex_woman) ? ("a") : ("e"), kasa);
            ShowInfo(playerid, buffer);

		    format(buffer, sizeof buffer, "Wypisano czek na $%.2f", kasa); mysql_real_escape_string(buffer, buffer);
		    format(buffer, sizeof buffer, "INSERT INTO `surv_bank_log` VALUE (NULL, UNIX_TIMESTAMP(), '%d', '%s')", Bankomat(playerid, bank_number), buffer);
			mysql_query(buffer);

            Bank_Clear(playerid);
		}
		case 73:
		{
		    if(!response) return Bank_Default(playerid);
			
			if(isnull(inputtext) || strlen(inputtext) > 32)
				return Dialog::Output(playerid, 73, DIALOG_STYLE_INPUT, IN_HEAD, bank_chname, "Zmień", "Wróć");

			new string[ 128 ];
			mysql_real_escape_string(inputtext, inputtext);
			EscapePL(inputtext);
			
			format(string, sizeof string, "UPDATE `surv_bank` SET `name`='%s' WHERE `number`=%d", inputtext, Bankomat(playerid, bank_number));
            mysql_query(string);
			
			format(Bankomat(playerid, bank_name), 32, inputtext);

            format(string, sizeof string, white"Nazwa konta została zmieniona pomyślnie!\nNowa nazwa:\t\t%s", inputtext);
			Dialog::Output(playerid, 21, DIALOG_STYLE_MSGBOX, IN_HEAD, string, "OK", "");
		}
	}
	return 1;
}

FuncPub::Bank_Clear(playerid)
{
	for(new eBank:d; d < eBank; d++)
	    Bankomat(playerid, d) = 0;
	return 1;
}

FuncPub::Bank_Default(playerid)
{
	new string[ 40 ];
	format(string, sizeof string,
		"Konto: %s",
		Bankomat(playerid, bank_name)
	);
	
    if(Bankomat(playerid, bank_bankomate))
        Dialog::Output(playerid, 20, DIALOG_STYLE_LIST, string, bank_bankomat, "Dalej", "Wyloguj");
    else
        Dialog::Output(playerid, 20, DIALOG_STYLE_LIST, string, bank_bank, "Dalej", "Zamknij");
	return 1;
}

stock GetBankOwner(number)
{
	new string[ 64 ],
		buffer[ 80 ];
	
	new owner[ 2 ];
	format(buffer, sizeof buffer,
		"SELECT `ownerType`, `owner` FROM `surv_bank` WHERE `number` = '%d'", 
		number
	);
	mysql_query(buffer);
	mysql_store_result();
	mysql_fetch_row(string);
	sscanf(string, "p<|>a<d>[2]",
		owner
	);
	mysql_free_result();
	
	if(owner[ 0 ] == bank_type_player)
	{
		format(buffer, sizeof buffer,
			"SELECT `name` FROM `surv_players` WHERE `uid` = '%d'", 
			owner[ 1 ]
		);
		mysql_query(buffer);
		mysql_store_result();
		mysql_fetch_row(string);
		UnderscoreToSpace(string);
		mysql_free_result();
		strins(string, "Osoba prywatna: ", 0);
	}
	else if(owner[ 0 ] == bank_type_group)
	{
		format(buffer, sizeof buffer,
			"SELECT `name` FROM `surv_groups` WHERE `uid` = '%d'", 
			owner[ 1 ]
		);	
		mysql_query(buffer);
		mysql_store_result();
		mysql_fetch_row(string);
		mysql_free_result();
		strins(string, "Grupa: ", 0);
	}
	else string = "Błąd";
	return string;
}

Cmd::Input->bank(playerid, params[])
{
	new string[ 50 ],
	    buffer[ 512 ],
		count;
	Bankomat(playerid, bank_bankomate) = false;

	#if STREAMER
		for(new objectid; objectid < Streamer_GetUpperBound(STREAMER_TYPE_OBJECT); objectid++)
	    {
			if(!IsValidDynamicObject(objectid))
				continue;
	        if(Streamer_GetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_MODEL_ID) != bankomat_model)
	            continue;
		    if(!Streamer_IsInArrayData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_WORLD_ID, Player(playerid, player_vw)))
				continue;
				
			new Float:pos[ 3 ];
		    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_X, pos[ 0 ]);
		    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_Y, pos[ 1 ]);
		    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_Z, pos[ 2 ]);
			if(!IsPlayerInRangeOfPoint(playerid, 2.0, pos[ 0 ], pos[ 1 ], pos[ 2 ]))
				continue;

	        Bankomat(playerid, bank_bankomate) = true;
	        break;
	    }
	#else
		for(new objectid = 1; objectid != MAX_OBJECTS; objectid++)
		{
		    if(Object(playerid, objectid, obj_objID) == INVALID_OBJECT_ID)
		        continue;
		    if(!IsValidPlayerObject(playerid, Object(playerid, objectid, obj_objID)))
		        continue;
		    if(!Object(playerid, objectid, obj_uid))
				continue;
			if(!IsPlayerInRangeOfPoint(playerid, 2.0, Object(playerid, objectid, obj_position)[ 0 ], Object(playerid, objectid, obj_position)[ 1 ], Object(playerid, objectid, obj_position)[ 2 ]))
				continue;
			if(Object(playerid, objectid, obj_model) != bankomat_model)
			    continue;
			Bankomat(playerid, bank_bankomate) = true;
			break;
		}
	#endif

	if(Bankomat(playerid, bank_bankomate))
	{
		format(buffer, sizeof buffer, "SELECT DISTINCT `v1`, `name`, `v2` FROM `surv_items` WHERE `ownerType` = "#item_place_player" AND `owner` = '%d' AND `type` = "#item_karta"", Player(playerid, player_uid));
		mysql_query(buffer);
		mysql_store_result();

		buffer = "Wybierz kartę:\n";
		count = 0;

		while(mysql_fetch_row(string))
		{
		    static uid,
				name[ MAX_ITEM_NAME ],
				block;
		    sscanf(string, "p<|>ds["#MAX_ITEM_NAME"]d",
				uid,
				name,
				block
			);
			if(block) format(buffer, sizeof(buffer), "%s%d\t"red"%s\n", buffer, uid, name);
			else format(buffer, sizeof(buffer), "%s%d\t%s\n", buffer, uid, name);
			count++;
		}
		mysql_free_result();
		if(count) return Dialog::Output(playerid, 18, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
		else ShowInfo(playerid, red"Nie posiadasz żadnej karty od bankomatu.\n\n"white"Możesz ją wyrobić u pracownika banku.");
	    return 1;
	}
	
    if(!Player(playerid, player_door))
        return ShowInfo(playerid, red"Nie jesteś w banku!");

	new groupuid; 
    format(buffer, sizeof buffer,
		"SELECT surv_groups.uid FROM `surv_doors` JOIN `surv_groups` ON surv_doors.ownerType = "#door_type_group" AND surv_doors.owner = surv_groups.uid WHERE surv_groups.type = "#group_type_bank" AND surv_doors.uid = '%d'",
		Door(Player(playerid, player_door), door_uid)
	);
	mysql_query(buffer);
	mysql_store_result();
	count = mysql_num_rows();
	groupuid = mysql_fetch_int();
	Bankomat(playerid, bank_bankomate) = false;
	mysql_free_result();
	
	if(!count)
		return ShowInfo(playerid, red"Nie jesteś w banku!");

	if(!strcmp(params, "załóż", true) || !strcmp(params, "zaloz", true))
	{
		if(50.0 > Player(playerid, player_cash))
			return ShowCMD(playerid, "Nie posiadasz tyle gotówki");
		format(buffer, sizeof buffer,
		    "INSERT INTO `surv_bank` VALUES (NULL, '"#bank_type_player"', '%d', '%d', '0', '1234', 'Konto glowne', '%d')",
		    Player(playerid, player_uid),
		    randomEx(1000000, 9999999),
		    groupuid
		);
		mysql_query(buffer);
		
		GivePlayerMoneyEx(playerid, 0 - 50.0, true);
		
	    Chat::Output(playerid, CLR_GREEN, "Konto zostało stworzone. PIN: 1234");
	}
	else
	{
		format(buffer, sizeof buffer, "SELECT `number`, `name` FROM `surv_bank` WHERE `ownerType` = "#bank_type_player" AND `owner` = '%d' AND `group` = '%d'", Player(playerid, player_uid), groupuid);
		mysql_query(buffer);
		mysql_store_result();

		buffer = "Wybierz kartę:\n";
		count = 0;

		while(mysql_fetch_row_format(string))
		{
		    static id,
				name[ 32 ];
		    sscanf(string, "p<|>ds[32]",
				id,
				name
			);
			format(buffer, sizeof(buffer), "%s%d\t%s\n", buffer, id, name);
			count++;
		}
		mysql_free_result();
		if(count) Dialog::Output(playerid, 18, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
		else ShowInfo(playerid, red"Nie posiadasz założonego konta w tym banku.\n\n"white"Możesz je założyć wpisując /bank załóż.");
	}
	return 1;
}
Cmd::Input->bankomat(playerid, cmdtext[]) return cmd_bank(playerid, cmdtext);
