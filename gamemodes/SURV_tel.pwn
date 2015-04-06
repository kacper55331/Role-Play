FuncPub::EndCall(playerid)
{
	if(Phone(playerid, phone_to) == INVALID_PLAYER_ID && Phone(playerid, phone_incoming) == INVALID_PLAYER_ID) return 1;

	new victimid = Phone(playerid, phone_to),
		string[ 150 ];
		
	if(victimid == INVALID_PLAYER_ID)
		victimid = Phone(playerid, phone_incoming);
		
	Audio_Stop(playerid, Player(playerid, player_mobile_sound_call));
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);

	foreach(Player, id)
	{
	    if(!Audio_IsClientConnected(id)) continue;
	    if(!Player(playerid, player_mobile_sound_called)[ id ]) continue;
	    
		Audio_Stop(id, Player(playerid, player_mobile_sound_called)[ id ]);
		Player(playerid, player_mobile_sound_called)[ id ] = 0;
	}

	Chat::Output(playerid, COLOR_YELLOW, "Rozmowa zakoñczona.");
	format(string, sizeof string, "* %s zakoñczy³%s rozmowe. *", NickName(playerid), (Player(playerid, player_sex) == sex_woman) ? ("a") : (""));
	serwerme(playerid, string);
	
	format(string, sizeof string,
		"UPDATE `surv_phone_call` SET `trwa` = '%d', `read` = '%d' WHERE `uid` = '%d'",
		Phone(playerid, phone_time),
		(victimid == INVALID_PLAYER_ID) ? (1) : (0),
		Phone(playerid, phone_call_uid)
	);
	mysql_query(string);

	for(new ePhone:i; i < ePhone; i++)
		Phone(playerid, i) = 0;

	Phone(playerid, phone_to) = INVALID_PLAYER_ID;
	Phone(playerid, phone_incoming) = INVALID_PLAYER_ID;
	
	if(victimid != INVALID_PLAYER_ID)
	{
	    if(victimid == 911 || victimid == 4444 || victimid == 7777 || victimid == 5555 || victimid == 7778)
			return 1;

		Audio_Stop(victimid, Player(victimid, player_mobile_sound_call));
		SetPlayerSpecialAction(victimid, SPECIAL_ACTION_STOPUSECELLPHONE);

		Chat::Output(victimid, COLOR_YELLOW, "Rozmowa zakoñczona.");
		format(string, sizeof string, "* %s zakoñczy³%s rozmowe. *", NickName(victimid), (Player(victimid, player_sex) == sex_woman) ? ("a") : (""));
		serwerme(victimid, string);

		for(new ePhone:i; i < ePhone; i++)
			Phone(victimid, i) = 0;

		Phone(victimid, phone_to) = INVALID_PLAYER_ID;
		Phone(victimid, phone_incoming) = INVALID_PLAYER_ID;
	}
	return 1;
}

FuncPub::Tel_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case 16:
	    {
            new victimid = Phone(playerid, phone_incoming); // Dzwoni¹cy
            if(victimid == INVALID_PLAYER_ID)
                return 1;
	        if(response)
	        {
	            Phone(playerid, phone_to) = victimid;
	            
	            Chat::Output(victimid, COLOR_YELLOW, "Rozmówca odebra³ telefon.");
	            
	            new string[ 64 ];
	            format(string, sizeof string, "* %s odbiera telefon. *", NickName(playerid));
	            serwerme(playerid, string);
	            
				Audio_Stop(victimid, Player(victimid, player_mobile_sound_call));

				foreach(Player, id)
				{
				    if(!Audio_IsClientConnected(id)) continue;
				    if(!Player(playerid, player_mobile_sound_called)[ id ]) continue;
					Audio_Stop(id, Player(playerid, player_mobile_sound_called)[ id ]);
					Player(playerid, player_mobile_sound_called)[ id ] = 0;
				}
				
				KillTimer(Player(victimid, player_mobile_timer));
        		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
	        }
	        else
	        {
				KillTimer(Player(victimid, player_mobile_timer));
	            Audio_Play(playerid, call_sound_end);
				EndCall(playerid);
	        }
	        Phone(playerid, phone_incoming) = INVALID_PLAYER_ID;
	    }
 		case 28:
 		{
 		    if(!response) return End_Order(playerid);
 		    new catid = strval(inputtext);
 		    new buffer[ 1024 ], string[ 126 ];
 		    new doorid = Player(playerid, player_door_id);

		 	if(Door(doorid, door_owner)[ 0 ] == door_type_group)
		 	{
				format(buffer, sizeof buffer,
					"SELECT surv_product_id.uid, surv_product_id.name, surv_product_id.price, surv_groups.uid FROM `surv_product_id` JOIN `surv_groups` ON surv_product_id.group_type = surv_groups.type OR surv_product_id.group_id = surv_groups.uid JOIN `surv_doors` ON surv_doors.ownerType = "#door_type_group" AND surv_doors.owner = surv_groups.uid WHERE surv_product_id.cat = '%d' AND surv_doors.uid = '%d'",
					catid,
					Door(doorid, door_uid)
				);
			}
			else if(Door(doorid, door_owner)[ 0 ] == door_type_house)
			{
				format(buffer, sizeof buffer,
					"SELECT `uid`, `name`, `price` FROM `surv_product_id` WHERE `cat` = '%d' AND `group_type` = '-1'",
					catid
				);
				SetPVarInt(playerid, "product-group", -1);
			}
			mysql_query(buffer);
		 	mysql_store_result();
		 	buffer[ 0 ] = EOS;
			while(mysql_fetch_row(string))
			{
			    static uid,
					name[ MAX_ITEM_NAME ],
					Float:price,
					group;
				sscanf(string, "p<|>ds[" #MAX_ITEM_NAME "]fd",
					uid,
					name,
					price,
					group
				);
				format(buffer, sizeof buffer, "%s%d\t$%.2f\t%s\n", buffer, uid, price, name);
				if(GetPVarInt(playerid, "product-group") != -1)
					SetPVarInt(playerid, "product-group", group);
			}
			mysql_free_result();
			if(isnull(buffer))
			{
				ShowInfo(playerid, red"Brak przedmiotów w tej kategorii!");
				End_Order(playerid);
			}
			else Dialog::Output(playerid, 29, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
 		}
 		case 29:
 		{
 		    if(!response) return End_Order(playerid);
			new productuid = strval(inputtext);
			SetPVarInt(playerid, "product-uid", productuid);

			new string[ 64 ];
			format(string, sizeof string,
				"SELECT `name` FROM `surv_product_id` WHERE `uid` = %d",
				productuid
			);
			mysql_query(string);
		 	mysql_store_result();
			mysql_fetch_row(string);
			mysql_free_result();

  		    Tel_OnPlayerText(playerid, string);

		 	format(string, sizeof string,
				white"Podaj ile sztuk chcesz kupiæ \"%s\".",
				string
		 	);
			Dialog::Output(playerid, 87, DIALOG_STYLE_INPUT, IN_HEAD, string, "Dalej", "Zamknij");
 		}
 		case 87:
 		{
  		    if(!response) return End_Order(playerid);
			new amount = strval(inputtext);
			if(!amount) amount = 1;
			SetPVarInt(playerid, "product-amount", amount);
			Dialog::Output(playerid, 30, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj cene za któr¹ chcesz sprzedawaæ produkt.", "Dalej", "Zamknij");

  		    new string[ 20 ];
  		    format(string, sizeof string, "%d %s", amount, dli(amount, "sztuke", "sztuki", "sztuk"));
  		    Tel_OnPlayerText(playerid, string);
 		}
		case 30:
 		{
 		    if(!response) return End_Order(playerid);
 		    new Float:sell = floatstr(inputtext);
 		    if(!sell) sell = 1;
            SetPVarFloat(playerid, "product-sell", sell);
			Dialog::Output(playerid, 31, DIALOG_STYLE_LIST, IN_HEAD, "Wybierz typ dostawy:\n0. Kurier($"#price_kurier")", "Dalej", "Zamknij");// \n1. Odbiór osobisty
 		}
		case 31:
 		{
 		    if(!response) return End_Order(playerid);
			new productuid = GetPVarInt(playerid, "product-uid"),
				amount = GetPVarInt(playerid, "product-amount"),
				doorid = Player(playerid, player_door_id),
				groupuid = GetPVarInt(playerid, "product-group"),
				dowoz = strval(inputtext),
				Float:sell = GetPVarFloat(playerid, "product-sell"),
				string[ 256 ],
				Float:cash;

			if(groupuid != -1)
			{
				format(string, sizeof string,
					"SELECT `cash` FROM `surv_groups` WHERE `uid` = '%d'",
					groupuid
				);
				mysql_query(string);
				mysql_store_result();
				mysql_fetch_float(cash);
				mysql_free_result();
			}
			else
			    cash = Player(playerid, player_cash);

			format(string, sizeof string,
				"SELECT * FROM `surv_product_id` WHERE `uid` = '%d'",
				productuid
			);
			mysql_query(string);
			mysql_store_result();
			mysql_fetch_row(string);
			mysql_free_result();

			new itm_type,
				itm_value[ 2 ],
				Float:itm_value3,
				itm_name[ MAX_ITEM_NAME ],
				Float:itm_price,
				itm_pack,
				itm_weight;

			sscanf(string, "p<|>{dd}d{dd}da<d>[2]fs["#MAX_ITEM_NAME"]df",
				itm_pack,
				itm_type,
				itm_value,
				itm_value3,
				itm_name,
				itm_weight,
				itm_price
			);
			new Float:minus;
			if(dowoz)
			{
				minus = (itm_price*amount);
				dowoz = Player(playerid, player_uid);
			}
			else
			    minus = (itm_price*amount)+price_kurier;

			if(cash < minus)
			    return ShowInfo(playerid, (groupuid != -1) ? (red"Na koncie grupy nie ma tyle gotówki.") : (red"Nie posiadasz tyle gotówki.")), EndCall(playerid);

			if(groupuid != -1)
			{
			    format(string, sizeof string,
					"UPDATE `surv_groups` SET `cash` = `cash` - '%.2f' WHERE `uid` = '%d'",
					minus,
					groupuid
				);
			    mysql_query(string);

			    format(string, sizeof string,
					"INSERT INTO `surv_groups_log` VALUES (NULL, '%d', '%d', '0', UNIX_TIMESTAMP(), '-%.2f', 'Zamowienie %dx %s')",
					groupuid,
					Player(playerid, player_uid),
					minus,
					amount,
					itm_name
				);
				mysql_query(string);
			}
			else
			    SetPlayerMoney(playerid, Player(playerid, player_cash) -= minus);

			format(string, sizeof string,
				"INSERT INTO `surv_orders` (`door_uid`, `item_type`, `v1`, `v2`, `v3`, `name`, `weight`, `amount`, `price`, `drive`, `pack`) VALUE ('%d', '%d', '%d', '%d', '%f', '%s', '%d', '%d', '%.2f', '%d', '%d')",
				Door(doorid, door_uid),
				itm_type,
				itm_value[ 0 ],
				itm_value[ 1 ],
				itm_value3,
				itm_name,
				itm_weight,
				amount,
				sell,
				dowoz,
				itm_pack
			);
			mysql_query(string);
			new uid = mysql_insert_id(),
				itm_pack_name[ 32 ],
				Float:itm_pack_pos[ 3 ];
			format(string, sizeof string,
			    "SELECT `name`, `x`, `y`, `z` FROM `surv_pack_pos` WHERE `uid` = '%d'",
				itm_pack
			);
			mysql_query(string);
			mysql_store_result();
			mysql_fetch_row(string);
			sscanf(string, "p<|>s[32]a<f>[3]",
				itm_pack_name,
				itm_pack_pos
			);
			mysql_free_result();
			if(dowoz)
			{
			    // TODO
	 			SetPlayerCheckpoint(playerid, itm_pack_pos[ 0 ], itm_pack_pos[ 1 ], itm_pack_pos[ 2 ], 15.0);

				format(string, sizeof string,
					green"Produkt zamówiony!\n\n"white"Numer przesy³ki: %d\n"white"Magazyn: %s\n"white"Nazwa: %s\n"white"Iloœæ: %d\n"white"Cena za szt.: $%.2f\n"white"£¹cznie: $%.2f\n\n"white"Aby odebraæ paczke udaj siê do magazynu zaznaczonego na mapie!",
					uid,
					itm_pack_name,
					itm_name,
					amount,
					itm_price,
					minus
				);
			}
			else
			{
			 	format(string, sizeof string,
					green"Produkt zamówiony!\n\n"white"Numer przesy³ki: %d\n"white"Nazwa: %s\n"white"Iloœæ: %d\n"white"Cena za szt.: $%.2f\n"white"Kurier: $"#price_kurier"\n"white"£¹cznie: $%.2f\n\n"white"Poczekaj na kuriera, aby sprawdziæ status paczki zadzwoñ pod 778.",
					uid,
					itm_name,
					amount,
					itm_price,
					minus
				);
			}
 		    print("7");
			Dialog::Output(playerid, 89, DIALOG_STYLE_MSGBOX, IN_HEAD, string, "Zamknij", "");
 		}
		case 89:
	    {
	        EndCall(playerid);
	    }
	    case 154:
	    {
	        if(!response)
			{
			    EndCall(playerid);
				return 1;
			}
	        SetPVarInt(playerid, "call-type", listitem);
            Tel_OnPlayerText(playerid, inputtext);
			Dialog::Output(playerid, 155, DIALOG_STYLE_INPUT, IN_HEAD, "Opisz powoli ca³¹ sytuacje:", "OK", "Zamknij");
	    }
	    case 155:
	    {
	        if(!response)
			{
			    EndCall(playerid);
				DeletePVar(playerid, "call-type");
				return 1;
			}
	        if(isnull(inputtext)) return Dialog::Output(playerid, 155, DIALOG_STYLE_INPUT, IN_HEAD, "Opisz powoli ca³¹ sytuacje:", "OK", "Zamknij");
	        new type = GetPVarInt(playerid, "call-type"),
				string[ 126 ];
				
			if(type == 0) type = group_type_pd;
			else if(type == 1) type = group_type_fd;
			else return 1;
			
			Tel_OnPlayerText(playerid, inputtext);
	        
			format(string, sizeof string, "[%d] Zg³oszenie - Centrala: %s (( %s ))", Phone(playerid, phone_number), inputtext, NickName(playerid));
		   	foreach(Player, i)
		   	{
				new g = IsPlayerInTypeGroup(i, type);
				if(!g) continue;
				if(Player(i, player_duty) != g) continue;
				
			    SendClientMessage(i, COLOR_YELLOW, string);
			}
			ShowInfo(playerid, "Zg³oszenie wys³ane!\n\nDziêkujemy za telefon.");
	        EndCall(playerid);
	    }
	    case 158:
	    {
	        if(!response) return EndCall(playerid);
	        if(isnull(inputtext)) return Dialog::Output(playerid, 158, DIALOG_STYLE_INPUT, IN_HEAD, white"Opisz miejsce w którym siê znajdujesz", "Wyœlij", "Zamknij");
			new string[ 126 ];
            Tel_OnPlayerText(playerid, inputtext);
            
			format(string, sizeof string, "[%d] Zg³oszenie - Centrala: %s (( %s ))", Phone(playerid, phone_number), inputtext, NickName(playerid));
		   	foreach(Player, i)
		   	{
				new g = IsPlayerInTypeGroup(i, group_type_taxi);
				if(!g) continue;
				if(Player(i, player_duty) != g) continue;

			    SendClientMessage(i, COLOR_YELLOW, string);
			}
			ShowInfo(playerid, "Taksówka wezwana!\n\nDziêkujemy za telefon.");
	        EndCall(playerid);
	    }
	    case 160:
	    {
	        if(!response) return ClearPhone(playerid);
	        new buffer[ 2058 ];
	        if(strfind(inputtext, "WprowadŸ numer", true) != -1)
	        {
				Dialog::Output(playerid, 162, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj numer telefonu", "Wybierz", "Zamknij");
	        }
	        else if(strfind(inputtext, "Kontakty", true) != -1)
	        {
				new string[ 126 ];
				format(string, sizeof string,
				    "SELECT `victim`, `name` FROM `surv_phone_contact` WHERE `player` = '%d'",
				    Phone(playerid, phone_number)
				);
				mysql_query(string);
				mysql_store_result();
				while(mysql_fetch_row(string))
				{
				    new numer, name[ MAX_PLAYER_NAME ];
				    sscanf(string, "p<|>ds["#MAX_PLAYER_NAME"]", numer, name);
				    
					format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, numer, name);
				}
				mysql_free_result();
				strcat(buffer, "Dodaj nowy numer\n");
				strcat(buffer, grey"------------------------\n");
				strcat(buffer, "911\t\tNumer alarmowy\n");
				strcat(buffer, "4444\t\tTaxi\n");
				strcat(buffer, "7777\t\tZamówienia\n");
				Dialog::Output(playerid, 162, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
	        }
	        else if(strfind(inputtext, "Ostatnie po³¹czenia", true) != -1)
	        {
				new string[ 256 ], count;
				format(string, sizeof string,
				    "SELECT s.uid, s.time, s.read, s.trwa, IFNULL(v.name, s.from) FROM `surv_phone_call` s LEFT JOIN `surv_phone_contact` v ON (s.from = v.victim AND s.to = v.player) WHERE s.to = '%d' ORDER BY s.time DESC",
				    Phone(playerid, phone_number)
				);

				mysql_query(string);
				mysql_store_result();
				while(mysql_fetch_row(string))
				{
				    static uid, timex, name[ MAX_PLAYER_NAME ], read, trwa,
						dateStr[ 32 ], trwaStr[ 32 ];
				    sscanf(string, "p<|>dddds["#MAX_PLAYER_NAME"]", uid, timex, read, trwa, name);

					ReturnTimeAgo(timex, dateStr);
                    ReturnTimeMega(trwa, trwaStr);
                    
					format(buffer, sizeof buffer, "%s{000000}%d "white"Od: %s\tData: %s\n", buffer, uid, name, dateStr);
					format(buffer, sizeof buffer, "%s{000000}%d "white"Czas: %s\n", buffer, uid, trwaStr);
					count++;
					if(mysql_num_rows() != count) strcat(buffer, grey"------------------------\n");
				}
				mysql_free_result();
				if(!isnull(buffer)) Dialog::Output(playerid, 169, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
				else Dialog::Output(playerid, 169, DIALOG_STYLE_LIST, IN_HEAD, red"Brak SMS'ów!", "Okey", "");

				format(string, sizeof string,
				    "UPDATE `surv_phone_call` SET `read` = '1' WHERE `to` = '%d' AND `read` = '0'",
				    Phone(playerid, phone_number)
				);
				mysql_query(string);
				
				new res = mysql_affected_rows();
				
				format(string, sizeof string,
				    "UPDATE `surv_items` SET `v3` = `v3` - '%d' WHERE `v1` = '%d' AND `type` = '"#item_phone"'",
				    res,
				    Phone(playerid, phone_number)
				);
				mysql_query(string);
			}
	        else if(strfind(inputtext, "Skrzynka odbiorcza", true) != -1)
	        {
				new string[ 256 ], count;
				format(string, sizeof string,
				    "SELECT s.uid, s.time, s.read, IFNULL(v.name, s.from), s.text FROM `surv_phone_sms` s LEFT JOIN `surv_phone_contact` v ON (s.from = v.victim AND s.to = v.player) WHERE s.to = '%d' ORDER BY s.time DESC",
				    Phone(playerid, phone_number)
				);
				mysql_query(string);
				mysql_store_result();
				while(mysql_fetch_row(string))
				{
				    new uid, timex, name[ MAX_PLAYER_NAME ], read,
						text[ 126 ], dateStr[ 32 ], len;
						
				    sscanf(string, "p<|>ddds["#MAX_PLAYER_NAME"]s[126]", uid, timex, read, name, text);

                    ReturnTimeAgo(timex, dateStr);
                    
                    len = strlen(text);
					if(len >= max_c)
					{
					    strdel(text, max_c, len);
					    strcat(text, "...");
					}
					
					format(buffer, sizeof buffer, "%s{000000}%d %sOd: %s\tData: %s\n", buffer, uid, read ? (white) : (green), IsNumeric(name) ? NiceMoney(strval(name), "-") : (name), dateStr);
					format(buffer, sizeof buffer, "%s{000000}%d\t%sTreœæ: %s\n", buffer, uid, read ? (white) : (green), text);
					count++;
					if(mysql_num_rows() != count) strcat(buffer, grey"------------------------\n");
				}
				mysql_free_result();
				if(isnull(buffer)) Dialog::Output(playerid, 169, DIALOG_STYLE_LIST, IN_HEAD, red"Brak SMS'ów!", "Okey", "");
				else Dialog::Output(playerid, 169, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Okey", "");
	        }
	        else if(strfind(inputtext, "Ustawienia", true) != -1)
	        {
				Dialog::Output(playerid, 161, DIALOG_STYLE_LIST, IN_HEAD, "Dzwonek telefonu\nDzwonek SMS", "Wybierz", "Zamknij");
	        }
	        else if(strfind(inputtext, "Wycisz", true) != -1 || strfind(inputtext, "Odcisz", true) != -1)
	        {
				if(Phone(playerid, phone_option) & phone_mute)
				    Phone(playerid, phone_option) -= phone_mute;
				else
				    Phone(playerid, phone_option) += phone_mute;

				ShowCMD(playerid, Phone(playerid, phone_option) & phone_mute ? ("Telefon wyciszony.") : ("Telefon odciszony."));
				format(buffer, sizeof buffer,
				    "UPDATE `surv_phone` SET `option` = '%d' WHERE `uid` = '%d'",
				    Phone(playerid, phone_option),
				    Phone(playerid, phone_uid)
				);
				mysql_query(buffer);

                Phone_Default(playerid);
	        }
	        else if(strfind(inputtext, "Wy³¹cz", true) != -1 || strfind(inputtext, "W³¹cz", true) != -1)
	        {
				if(Phone(playerid, phone_option) & phone_off)
				    Phone(playerid, phone_option) -= phone_off;
				else
				    Phone(playerid, phone_option) += phone_off;

				ShowCMD(playerid, Phone(playerid, phone_option) & phone_off ? ("Telefon wy³¹czony.") : ("Telefon w³¹czony."));

				format(buffer, sizeof buffer,
				    "UPDATE `surv_phone` SET `option` = '%d' WHERE `uid` = '%d'",
				    Phone(playerid, phone_option),
				    Phone(playerid, phone_uid)
				);
				mysql_query(buffer);
				
				Phone_Default(playerid);
	        }
	        else if(strfind(inputtext, "Wyjmij karte", true) != -1)
	        {
				format(buffer, sizeof buffer,
				    "UPDATE `surv_items` SET `v1` = '0' WHERE `v1` = '%d' AND `v2` = '%d' AND `type` = '"#item_phone"'",
				    Phone(playerid, phone_number),
				    Phone(playerid, phone_uid)
				);
				mysql_query(buffer);

				format(buffer, sizeof buffer,
				    "UPDATE `surv_items` SET `ownerType` = '"#item_place_player"', `owner` = '%d' WHERE `v1` = '%d' AND `type` = '"#item_sim"'",
				    Player(playerid, player_uid),
				    Phone(playerid, phone_number)
				);
				mysql_query(buffer);
				
				ClearPhone(playerid);
	        }
	    }
	    case 161:
	    {
	        if(!response) return Phone_Default(playerid);
	        new ring, sms, string[ 100 ], buffer[ 512 ];
	        format(string, sizeof string,
	            "SELECT `ring`, `sms` FROM `surv_phone` WHERE `uid` = '%d'",
	            Phone(playerid, phone_uid)
			);
			mysql_query(string);
			mysql_store_result();
			mysql_fetch_row(string);
			sscanf(string, "p<|>dd", ring, sms);
			mysql_free_result();
			
	        if(strfind(inputtext, "Dzwonek telefonu", true) != -1)
	        {
	            Create(playerid, create_value)[ 0 ] = 0;
	            for(new c; c != sizeof RingTone; c++)
	            {
	                if(RingTone[ c ][ ring_type ] != Create(playerid, create_value)[ 0 ]) continue;
	                format(buffer, sizeof buffer, "%s%s%d\t%s\n", buffer, c == ring ? (green) : (""), c, RingTone[ c ][ ring_name ]);
	            }
                Dialog::Output(playerid, 166, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
	        }
	        else if(strfind(inputtext, "Dzwonek SMS", true) != -1)
	        {
	            Create(playerid, create_value)[ 0 ] = 1;
	            for(new c; c != sizeof RingTone; c++)
	            {
	                if(RingTone[ c ][ ring_type ] != Create(playerid, create_value)[ 0 ]) continue;
	                format(buffer, sizeof buffer, "%s%s%d\t%s\n", buffer, c == sms ? (green) : (""), c, RingTone[ c ][ ring_name ]);
	            }
                Dialog::Output(playerid, 166, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
	        }
	    }
	    case 162:
	    {
	        if(!response) return Phone_Default(playerid);
	        if(strfind(inputtext, "Dodaj nowy numer", true) != -1)
	        {
	            Dialog::Output(playerid, 163, DIALOG_STYLE_INPUT, IN_HEAD, white"WprowadŸ numer telefonu.", "Wybierz", "Zamknij");
	            return 1;
	        }
			new buffer[ 256 ],
				numer = strval(inputtext);
			if(numer >= 10000000)
			{
				new string[ 100 ],
					bool:res;

				format(string, sizeof string,
				    "SELECT 1 FROM `surv_phone_contact` WHERE `player` = '%d' AND `victim` = '%d'",
				    Phone(playerid, phone_number),
				    numer
				);
				mysql_query(string);
				mysql_store_result();
				res = !!mysql_num_rows();
				mysql_free_result();

				strcat(buffer, "Zadzwoñ\n");
				strcat(buffer, "Wyœlij SMS\n");
				if(res)
				{
					strcat(buffer, grey"------------------------\n");
					strcat(buffer, "Zmieñ nazwê\n");
					strcat(buffer, "Skasuj\n");
				}
				Create(playerid, create_value)[ 0 ] = numer;
			}
			if(isnull(buffer))
			{
			    Call(playerid, numer);
			}
			else
				Dialog::Output(playerid, 165, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
	    }
	    case 163:
	    {
	        if(!response) return Phone_Default(playerid);
	        if(isnull(inputtext)) return Dialog::Output(playerid, 163, DIALOG_STYLE_INPUT, IN_HEAD, white"WprowadŸ numer telefonu.", "Wybierz", "Zamknij");
	        if(!IsNumeric(inputtext)) return Dialog::Output(playerid, 163, DIALOG_STYLE_INPUT, IN_HEAD, white"WprowadŸ numer telefonu.\n\n"red"Numer nie jest liczb¹.", "Wybierz", "Zamknij");
			if(strlen(inputtext) != 8) return Dialog::Output(playerid, 163, DIALOG_STYLE_INPUT, IN_HEAD, white"WprowadŸ numer telefonu.\n\n"red"Numer musi mieæ 8 znaków.", "Wybierz", "Zamknij");

			Create(playerid, create_value)[ 0 ] = strval(inputtext);
            Dialog::Output(playerid, 164, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj nazwê kontaktu", "Wybierz", "Zamknij");
	    }
	    case 164:
	    {
	        if(!response) return Phone_Default(playerid);
	        if(isnull(inputtext)) return Dialog::Output(playerid, 164, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj nazwê kontaktu", "Wybierz", "Zamknij");
		    if(strlen(inputtext) >= MAX_PLAYER_NAME) return Dialog::Output(playerid, 164, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj nazwê kontaktu.\n\n"red"Za d³uga nazwa!", "Wybierz", "Zamknij");

			mysql_real_escape_string(inputtext, inputtext);
			EscapePL(inputtext);
			new buffer[ 126 ];
			format(buffer, sizeof buffer,
				"INSERT INTO `surv_phone_contact` VALUES (NULL, '%d', '%d', '%s')",
				Phone(playerid, phone_number),
				Create(playerid, create_value)[ 0 ],
				inputtext
			);
			mysql_query(buffer);
            Create(playerid, create_value)[ 0 ] = 0;
            ShowCMD(playerid, "Kontakt dodany.");
	        Phone_Default(playerid);
	    }
	    case 165:
	    {
	        if(!response) return Phone_Default(playerid);
	        if(strfind(inputtext, "Zadzwoñ", true) != -1)
	        {
	            Call(playerid, Create(playerid, create_value)[ 0 ]);
	            Create(playerid, create_value)[ 0 ] = 0;
	        }
	        else if(strfind(inputtext, "Wyœlij SMS", true) != -1)
	        {
	            Dialog::Output(playerid, 167, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj treœæ SMS'a", "Wybierz", "Zamknij");
	        }
	        else if(strfind(inputtext, "Zmieñ nazwê", true) != -1)
	        {
	            Dialog::Output(playerid, 168, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj nazwê.", "Wybierz", "Zamknij");
	        }
	        else if(strfind(inputtext, "Skasuj", true) != -1)
	        {
				new string[ 126 ];
				format(string, sizeof string,
				    "DELETE FROM `surv_phone_contact` WHERE `player` = '%d' AND `victim` = '%d'",
				    Phone(playerid, phone_number),
				    Create(playerid, create_value)[ 0 ]
				);
				mysql_query(string);
				
				ShowCMD(playerid, "Kontakt skasowany pomyœlnie!");
				
				Create(playerid, create_value)[ 0 ] = 0;
				Phone_Default(playerid);
	        }
	    }
	    case 166:
	    {
	        if(!response) return Phone_Default(playerid);
	        new string[ 126 ], n;
	        sscanf(inputtext, "d", n);
	        if(!Create(playerid, create_value)[ 0 ]) //ring
	        {
	            format(string, sizeof string,
	                "UPDATE `surv_phone` SET `ring` = '%d' WHERE `uid` = '%d'",
					n,
					Phone(playerid, phone_uid)
				);
				mysql_query(string);

				format(string, sizeof string,
				    "Dzwonek telefonu zosta³ zmieniony na \"%s\" pomyœlnie.",
				    RingTone[ n ][ ring_name ]
				);
				ShowCMD(playerid, string);
			}
			else // sms
			{
	            format(string, sizeof string,
	                "UPDATE `surv_phone` SET `sms` = '%d' WHERE `uid` = '%d'",
					n,
					Phone(playerid, phone_uid)
				);
				mysql_query(string);
				
				format(string, sizeof string,
				    "Dzwonek SMS zosta³ zmieniony na \"%s\" pomyœlnie.",
				    RingTone[ n ][ ring_name ]
				);
				ShowCMD(playerid, string);
			}
			Phone_Default(playerid);
	    }
	    case 167:
	    {
	        if(!response) return Phone_Default(playerid);
	        if(isnull(inputtext)) return Dialog::Output(playerid, 167, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj treœæ SMS'a", "Wybierz", "Zamknij");
	        
	        SMS(playerid, Create(playerid, create_value)[ 0 ], inputtext);
	        Create(playerid, create_value)[ 0 ] = 0;
	    }
	    case 168:
	    {
	        if(!response) return Phone_Default(playerid);
	        if(isnull(inputtext)) return Dialog::Output(playerid, 168, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj nazwê", "Wybierz", "Zamknij");
		    if(strlen(inputtext) >= MAX_PLAYER_NAME) return Dialog::Output(playerid, 168, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj nazwê.\n\n"red"Zbyt d³uga nazwa!", "Wybierz", "Zamknij");

			mysql_real_escape_string(inputtext, inputtext);
			EscapePL(inputtext);

			new string[ 126 ];
			
			format(string, sizeof string,
			    "UPDATE `surv_phone_contact` SET `name` = '%s' WHERE `player` = '%d' AND `victim` = '%d'",
			    inputtext,
			    Phone(playerid, phone_number),
			    Create(playerid, create_value)[ 0 ]
			);
			mysql_query(string);
			Create(playerid, create_value)[ 0 ] = 0;
			Phone_Default(playerid);
			
			ShowCMD(playerid, "Nazwa kontaktu zmieniona pomyœlnie!");
	    }
	    case 169:
	    {
	        Phone_Default(playerid);
	    }
	}
	return 1;
}
/*
Zadzwoñ -> numer -> treœæ
Wyœlij SMS -> numer -> treœæ
Kontakty -> Lista + dodaj numer | + numery alarmowe -> Zadzwoñ / Wyœlij SMS / Zmieñ nazwê / Skasuj
Ostatnie po³¹czenia [x] -> Lista -> Odzwoñ / Wyœlij SMS / Usuñ
Skrzynka odbiorcza [x] -> Lista -> Odpowiedz / Skasuj
Ustawienia -> Dzwonek telefonu, dzwonek SMS
Wycisz/Odcisz
Wy³¹cz

W³¹cz
Wyjmij kartê
*/
FuncPub::ClearPhone(playerid)
{
	new victimid = Phone(playerid, phone_to);
	for(new ePhone:i; i < ePhone; i++)
		Phone(playerid, i) = 0;
		
	Phone(playerid, phone_to) = INVALID_PLAYER_ID;
	
	if(victimid != INVALID_PLAYER_ID)
	{
		for(new ePhone:i; i < ePhone; i++)
			Phone(victimid, i) = 0;
			
		Phone(victimid, phone_to) = INVALID_PLAYER_ID;
	}
	return 1;
}

FuncPub::Tel_OnPlayerText(playerid, text[])
{
	new string[ 128 ];
	if(Phone(playerid, phone_to) <= MAX_PLAYERS)
	{
		new victimid = Phone(playerid, phone_to);
	    if(!IsPlayerConnected(victimid))
	    {
			EndCall(playerid);
			return 1;
	    }
	    if(IsNumeric(Phone(victimid, phone_to_name)))
			format(string, sizeof string, "%s (telefon, %s): %s", NiceMoney(Phone(playerid, phone_number), "-"), (Player(playerid, player_sex) == sex_men) ? ("mê¿czyzna") : ("kobieta"), text);
		else
			format(string, sizeof string, "%s (telefon, %s): %s", Phone(victimid, phone_to_name), (Player(playerid, player_sex) == sex_men) ? ("mê¿czyzna") : ("kobieta"), text);
	    if(Phone(victimid, phone_to) == playerid)
			Chat::Output(victimid, COLOR_YELLOW, string);
    }
    
	format(string, sizeof string, "%s mówi (telefon): %s", NickName(playerid), text);
	SendClientMessageEx(14.0, playerid, string, COLOR_FADE1, COLOR_FADE2, COLOR_FADE3, COLOR_FADE4, COLOR_FADE5);
	return 1;
}

FuncPub::SMS(playerid, numer, tresc[])
{
	if(!numer)
		return ShowInfo(playerid, red"Nie poda³eœ numeru.");
	if(numer == Phone(playerid, phone_number))
	    return ShowInfo(playerid, red"Nie mo¿esz napisaæ sam do siebie!");

	new string[ 256 ],
		smsuid;
	mysql_real_escape_string(tresc, tresc);
	format(string, sizeof string,
	    "INSERT INTO `surv_phone_sms` VALUES (NULL, '%d', '%d', '%s', UNIX_TIMESTAMP(), '1')",
	    Phone(playerid, phone_number),
	    numer,
	    tresc
	);
	mysql_query(string);
	smsuid = mysql_insert_id();
	
    new victimid = INVALID_PLAYER_ID,
		ring, option;
	format(string, sizeof string,
		"SELECT o.ID, p.sms, p.option FROM `all_online` o JOIN `surv_items` i ON (i.owner = o.player AND i.type = '"#item_phone"' AND i.ownerType = "#item_place_player") JOIN `surv_phone` p ON (i.v2 = p.uid) WHERE i.v1 = '%d'",
		numer
	);
	mysql_query(string);
	mysql_store_result();
	new bool:numeros = !!mysql_num_rows();
	if(numeros)
	{
		mysql_fetch_row(string);
		sscanf(string, "p<|>ddd",
		    victimid,
		    ring,
		    option
		);
	}
	mysql_free_result();

	if(!IsPlayerConnected(victimid) || (option & phone_off) || !numeros)
	{
	    format(string, sizeof string,
			"UPDATE `surv_items` SET `v3` = `v3` + '1' WHERE `v1` = '%d' AND `type` = '"#item_phone"'",
			numer
		);
		mysql_query(string);
		Chat::Output(playerid, COLOR_YELLOW, "Wiadomoœæ zosta³a wys³ana! "red"(( Gracz nie jest online ))");
		return 1;
	}
	new victim_name[ 2 ][ MAX_PLAYER_NAME ], // 0 to, 1 from
   		bool:num[ 2 ] = true;
	format(string, sizeof string,
		"SELECT `name` FROM `surv_phone_contact` WHERE `player` = '%d' AND `victim` = '%d' LIMIT 1",
		Phone(playerid, phone_number),
		numer
	);
	mysql_query(string);
 	mysql_store_result();
 	if(!mysql_num_rows())
 	{
 	    format(victim_name[ 0 ], MAX_PLAYER_NAME, "%d", numer);
 	    num[ 0 ] = false;
 	}
 	else
 	{
	 	mysql_fetch_row(victim_name[ 0 ]);
	 	num[ 0 ] = true;
	}
 	mysql_free_result();

	format(string, sizeof string,
		"SELECT `name` FROM `surv_phone_contact` WHERE `player` = '%d' AND `victim` = '%d' LIMIT 1",
		numer,
		Phone(playerid, phone_number)
	);
	mysql_query(string);
 	mysql_store_result();
 	if(!mysql_num_rows())
 	{
 	    format(victim_name[ 1 ], MAX_PLAYER_NAME, "%d", Phone(playerid, phone_number));
 	    num[ 1 ] = false;
 	}
 	else
 	{
	 	mysql_fetch_row(victim_name[ 1 ]);
	 	num[ 1 ] = true;
	}
 	mysql_free_result();
	if(option & phone_mute)
	{
		Chat::Output(victimid, COLOR_PURPLE, "* Czujesz wibrowanie w kieszeni. *");

		GetPlayerPos(victimid, Player(victimid, player_position)[ 0 ], Player(victimid, player_position)[ 1 ], Player(victimid, player_position)[ 2 ]);
		foreach(Player, id)
		{
			if(!Audio_IsClientConnected(id)) continue;
		    if(!OdlegloscMiedzyGraczami(3.0, victimid, id)) continue;
			
		   	Audio_Set3DPosition(id, Audio_Play(id, call_sound_mute, .loop = false), Player(victimid, player_position)[ 0 ], Player(victimid, player_position)[ 1 ], Player(victimid, player_position)[ 2 ], 1.0);
		}
	}
	else
	{
		GetPlayerPos(victimid, Player(victimid, player_position)[ 0 ], Player(victimid, player_position)[ 1 ], Player(victimid, player_position)[ 2 ]);
		foreach(Player, id)
		{
			if(!Audio_IsClientConnected(id)) continue;
		    if(!OdlegloscMiedzyGraczami(15.0, victimid, id)) continue;
			
		   	Audio_Set3DPosition(id, Audio_Play(id, RingTone[ ring ][ ring_id ]), Player(victimid, player_position)[ 0 ], Player(victimid, player_position)[ 1 ], Player(victimid, player_position)[ 2 ], 10.0);
		}
		format(string, sizeof string, "* %s otrzyma³ SMS'a. *", NickName(victimid));
		serwerme(victimid, string);
	}
	format(string, sizeof string, "[%s] %s", !num[ 1 ] ? NiceMoney(strval(victim_name[ 1 ]), "-") : victim_name[ 1 ], tresc);
	Chat::Output(victimid, COLOR_YELLOW, string);
	
	format(string, sizeof string,
	    "UPDATE `surv_phone_sms` SET `read` = '1' WHERE `uid` = '%d'",
		smsuid
	);
	mysql_query(string);
	
    Chat::Output(playerid, COLOR_YELLOW, "Wiadomoœæ zosta³a wys³ana!");
	return 1;
}

FuncPub::Call(playerid, numer)
{
	if(Phone(playerid, phone_to) != INVALID_PLAYER_ID)
	    return EndCall(playerid);
	if(!numer)
	    return ShowInfo(playerid, red"Nie poda³eœ numeru.");
	if(numer == Phone(playerid, phone_number))
	    return ShowInfo(playerid, red"Nie mo¿esz zadzwoniæ sam do siebie!");
	    
	new string[ 256 ];
	format(string, sizeof string,
		"INSERT INTO `surv_phone_call` VALUES (NULL, '%d', '%d', UNIX_TIMESTAMP(), '1', '0')",
		Phone(playerid, phone_number),
		numer
	);
	mysql_query(string);
    Phone(playerid, phone_call_uid) = mysql_insert_id();
	if(numer == 911)
	{
		ShowPlayerDialog(playerid, 154, DIALOG_STYLE_LIST, IN_HEAD, "Policja\nStra¿ po¿arna", "Wybierz", "Zamknij");
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
	    Phone(playerid, phone_to) = 911;
	}
	else if(numer == 7777 || numer == 777)
	{
	    // Zamawianie
//	    if(!Player(playerid, player_mobile_cash))
//	        return ShowInfo(playerid, red"Brak œrodków na koncie!");

        new doorid = GetPlayerDoor(playerid, true);
	    if(!doorid)
	    {
			ShowInfo(playerid, red"Nie jesteœ w ¿adnym budynku!");
			EndCall(playerid);
	        return 1;
		}
	    new can_buy = CanPlayerProductBuy(playerid, doorid);
	    if(can_buy == -1)
	    {
			ShowInfo(playerid, red"Nie masz uprawnieñ!");
			EndCall(playerid);
	        return 1;
		}
        Player(playerid, player_door_id) = doorid;
        
		new buffer[ 512 ];
		mysql_query("SELECT * FROM `surv_product_cat`");
		mysql_store_result();
		while(mysql_fetch_row(string))
		{
		    static uid,
				name[ 32 ];
		    sscanf(string, "p<|>ds[32]",
				uid,
				name
			);
			
			format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, uid, name);
		}
		mysql_free_result();
		Dialog::Output(playerid, 28, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
	    Phone(playerid, phone_to) = 7777;
	}
	else if(numer == 4444 || numer == 444)
	{
//	    if(!Player(playerid, player_mobile_cash))
//	        return ShowInfo(playerid, red"Brak œrodków na koncie!");
		new count;
	    foreach(Player, i)
	    {
	        new group = IsPlayerInTypeGroup(i, group_type_taxi);
	        if(!group) continue;
	        if(Player(i, player_duty) != group) continue;
	        
	        count++;
	    }
	    
	    if(!count)
		{
			ShowInfo(playerid, red"Nie ma ¿adnego taksówkarza na s³u¿bie!");
			EndCall(playerid);
			return 1;
		}
	    else Dialog::Output(playerid, 158, DIALOG_STYLE_INPUT, IN_HEAD, white"Opisz miejsce w którym siê znajdujesz", "Wyœlij", "Zamknij");
	    
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
	    Phone(playerid, phone_to) = 4444;
	    // Taxi
	}
	else if(numer == 5555 || numer == 555)
	{
//	    if(!Player(playerid, player_mobile_cash))
//	        return ShowInfo(playerid, red"Brak œrodków na koncie!");
	    // Radio
	    Phone(playerid, phone_to) = 5555;
	}
	else if(numer == 7778 || numer == 778)
	{
//	    if(!Player(playerid, player_mobile_cash))
//	        return ShowInfo(playerid, red"Brak œrodków na koncie!");

	    // Sprawdzanie statusu paczki
		Dialog::Output(playerid, 88, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj IDentyfikator paczki\n(zosta³ podany przy zamówieniu)", "SprawdŸ", "Zamknij");
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
	    Phone(playerid, phone_to) = 7778;
	}
	else
	{
//	    if(!Player(playerid, player_mobile_cash))
//	        return ShowInfo(playerid, red"Brak œrodków na koncie!");

	    new victimid = INVALID_PLAYER_ID,
			ring, option;
		format(string, sizeof string,
			"SELECT o.ID, p.ring, p.option FROM `all_online` o JOIN `surv_items` i ON (i.owner = o.player AND i.type = '"#item_phone"' AND i.ownerType = "#item_place_player") JOIN `surv_phone` p ON (i.v2 = p.uid) WHERE i.v1 = '%d'",
			numer
		);
		mysql_query(string);
		mysql_store_result();
		new bool:numeros = !!mysql_num_rows();
		if(numeros)
		{
			mysql_fetch_row(string);
			sscanf(string, "p<|>ddd",
			    victimid,
			    ring,
			    option
			);
		}
		mysql_free_result();

		if(victimid == playerid)
		    return ShowInfo(playerid, red"Nie mo¿esz zadzwoniæ sam do siebie!");
		
		if(!IsPlayerConnected(victimid) || (option & phone_off) || !numeros)
		{
		    format(string, sizeof string,
				"UPDATE `surv_items` SET `v3` = `v3` + '1' WHERE `v1` = '%d' AND `type` = '"#item_phone"'",
				numer
			);
			mysql_query(string);
			
		    Audio_Play(playerid, call_sound_end);
			Chat::Output(playerid, CLR_YELLOW, "Telefon u¿ytkownika jest wy³¹czony lub jest poza zasiêgiem.");
			EndCall(playerid);
			return 1;
		}
		
		new victim_name[ 2 ][ MAX_PLAYER_NAME ], // 0 to, 1 from
	   		bool:num[ 2 ] = true;
		format(string, sizeof string,
			"SELECT `name` FROM `surv_phone_contact` WHERE `player` = '%d' AND `victim` = '%d' LIMIT 1",
			Phone(playerid, phone_number),
			numer
		);
		mysql_query(string);
	 	mysql_store_result();
	 	if(!mysql_num_rows())
	 	{
	 	    format(victim_name[ 0 ], MAX_PLAYER_NAME, "%d", numer);
	 	    num[ 0 ] = false;
	 	}
	 	else
	 	{
		 	mysql_fetch_row(victim_name[ 0 ]);
		 	num[ 0 ] = true;
		}
	 	mysql_free_result();
	 	
		format(string, sizeof string,
			"SELECT `name` FROM `surv_phone_contact` WHERE `player` = '%d' AND `victim` = '%d' LIMIT 1",
			numer,
			Phone(playerid, phone_number)
		);
		mysql_query(string);
	 	mysql_store_result();
	 	if(!mysql_num_rows())
	 	{
	 	    format(victim_name[ 1 ], MAX_PLAYER_NAME, "%d", Phone(playerid, phone_number));
	 	    num[ 1 ] = false;
	 	}
	 	else
	 	{
		 	mysql_fetch_row(victim_name[ 1 ]);
		 	num[ 1 ] = true;
		}
	 	mysql_free_result();
	 	
		if(Phone(victimid, phone_to) != INVALID_PLAYER_ID)
		{
		    format(string, sizeof string,
				"UPDATE `surv_items` SET `v3` = `v3` + '1' WHERE `v1` = '%d' AND `type` = '"#item_phone"'",
				numer
			);
			mysql_query(string);
			
	        if(!num[ 1 ])
				format(string, sizeof string, "Numer %s próbowa³ siê do Ciebie dodzwoniæ.", NiceMoney(Phone(playerid, phone_number), "-"));
			else
				format(string, sizeof string, "%s próbowa³ siê do Ciebie dodzwoniæ.", victim_name[ 1 ]);
            Chat::Output(victimid, CLR_YELLOW, string);
			Chat::Output(playerid, CLR_YELLOW, "* Zajête. * (( Gracz z kimœ rozmawia ))");
			EndCall(playerid);
			return 1;
		}
		if(Phone(victimid, phone_incoming) != INVALID_PLAYER_ID)
		{
		    format(string, sizeof string,
				"UPDATE `surv_items` SET `v3` = `v3` + '1' WHERE `v1` = '%d' AND `type` = '"#item_phone"'",
				numer
			);
			mysql_query(string);

	        if(!num[ 1 ])
				format(string, sizeof string, "Numer %s próbowa³ siê do Ciebie dodzwoniæ.", NiceMoney(Phone(playerid, phone_number), "-"));
			else
				format(string, sizeof string, "%s próbowa³ siê do Ciebie dodzwoniæ.", victim_name[ 1 ]);
            Chat::Output(victimid, CLR_YELLOW, string);
			Chat::Output(playerid, CLR_YELLOW, "* Zajête. * (( Ktoœ ju¿ dzwoni do tego gracza ))");
			EndCall(playerid);
			return 1;
		}
 		if(option & phone_mute)
		{
			Chat::Output(victimid, COLOR_PURPLE, "* Czujesz wibrowanie w kieszeni. *");

			GetPlayerPos(victimid, Player(victimid, player_position)[ 0 ], Player(victimid, player_position)[ 1 ], Player(victimid, player_position)[ 2 ]);
			foreach(Player, id)
			{
				if(!Audio_IsClientConnected(id)) continue;
		    	if(!OdlegloscMiedzyGraczami(15.0, victimid, id)) continue;
				if(Player(victimid, player_mobile_sound_called)[ id ]) continue;
				Player(victimid, player_mobile_sound_called)[ id ] = Audio_Play(id, call_sound_mute, .loop = true);
			   	Audio_Set3DPosition(id, Player(victimid, player_mobile_sound_called)[ id ], Player(victimid, player_position)[ 0 ], Player(victimid, player_position)[ 1 ], Player(victimid, player_position)[ 2 ], 1.0);
			}
		}
		else
		{
			GetPlayerPos(victimid, Player(victimid, player_position)[ 0 ], Player(victimid, player_position)[ 1 ], Player(victimid, player_position)[ 2 ]);
			foreach(Player, id)
			{
				if(!Audio_IsClientConnected(id)) continue;
		    	if(!OdlegloscMiedzyGraczami(15.0, victimid, id)) continue;
				if(Player(victimid, player_mobile_sound_called)[ id ]) continue;
				Player(victimid, player_mobile_sound_called)[ id ] = Audio_Play(id, RingTone[ ring ][ ring_id ], .loop = true);
			   	Audio_Set3DPosition(id, Player(victimid, player_mobile_sound_called)[ id ], Player(victimid, player_position)[ 0 ], Player(victimid, player_position)[ 1 ], Player(victimid, player_position)[ 2 ], 10.0);
			}
			format(string, sizeof string, "* Dzwoni telefon %s. *", NickName(victimid));
			serwerme(victimid, string);
		}
		Chat::Output(playerid, COLOR_PURPLE, "* S³yszysz dŸwiêk wybierania. *");
        if(!num[ 1 ])
			format(string, sizeof string, "Numer %s próbuje siê do Ciebie dodzwoniæ.", NiceMoney(Phone(playerid, phone_number), "-"));
		else
			format(string, sizeof string, "%s próbuje siê do Ciebie dodzwoniæ.", victim_name[ 1 ]);
			
		Dialog::Output(victimid, 16, DIALOG_STYLE_MSGBOX, IN_HEAD, string, "Odbierz", "Odrzuæ");
		Player(playerid, player_mobile_timer) = SetTimerEx("Tel_Timer", 10000, false, "dd", playerid, numer);
		Player(playerid, player_mobile_sound_call) = Audio_Play(playerid, call_sound, .loop = true);
        Phone(playerid, phone_to) = victimid;

        Phone(victimid, phone_incoming) = playerid;
        format(Phone(victimid, phone_to_name), MAX_PLAYER_NAME, victim_name[ 1 ]);
        format(Phone(playerid, phone_to_name), MAX_PLAYER_NAME, victim_name[ 0 ]);

        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
	}
	return 1;
}

FuncPub::Tel_Timer(playerid, numer)
{
	new victimid = Phone(playerid, phone_to),
		string[ 100 ];
	
	KillTimer(Player(playerid, player_mobile_timer));

    if(!IsNumeric(Phone(victimid, phone_to_name)))
		format(string, sizeof string, "Numer %s próbowa³ siê z tob¹ po³¹czyæ.", NiceMoney(Phone(playerid, phone_number), "-"));
	else
		format(string, sizeof string, "%s próbowa³ siê z Tob¹ po³¹czyæ.", Phone(victimid, phone_to_name));
	Chat::Output(victimid, COLOR_YELLOW, string);

	Audio_Stop(playerid, Player(playerid, player_mobile_sound_call));
	Player(playerid, player_mobile_sound_call) = 0;
	Audio_Play(playerid, call_sound_end);
	DestroyDialog(victimid);
	
	format(string, sizeof string,
		"UPDATE `surv_items` SET `v3` = `v3` + 1 WHERE `v1` = '%d' AND `type` = '"#item_phone"'",
		numer
	);
	mysql_query(string);
	
	Phone(victimid, phone_incoming) = INVALID_PLAYER_ID;
	
	Chat::Output(playerid, COLOR_YELLOW, "* Brak odpowiedzi. *");
	EndCall(playerid);
	return 1;
}

FuncPub::Phone_Default(playerid)
{
	new string[ 256 ], call, sms;
    format(string, sizeof string,
		"SELECT `option` FROM `surv_phone` WHERE `uid` = '%d'",
		Phone(playerid, phone_uid)
	);
	mysql_query(string);
	mysql_store_result();
	Phone(playerid, phone_option) = mysql_fetch_int();
	mysql_free_result();
	
    format(string, sizeof string,
		"SELECT COUNT(*) FROM `surv_phone_sms` WHERE `to` = '%d' AND `read` = '0'",
		Phone(playerid, phone_number)
	);
	mysql_query(string);
	mysql_store_result();
	sms = mysql_fetch_int();
	mysql_free_result();
	
    format(string, sizeof string,
		"SELECT COUNT(*) FROM `surv_phone_call` WHERE `to` = '%d' AND `read` = '0'",
		Phone(playerid, phone_number)
	);
	mysql_query(string);
	mysql_store_result();
	call = mysql_fetch_int();
	mysql_free_result();

	if(!(Phone(playerid, phone_option) & phone_off))
	{
	    new buffer[ 512 ];
	    strcat(buffer, "WprowadŸ numer\n");
	    strcat(buffer, "Kontakty\n");
	    
	    if(call)
	        format(buffer, sizeof buffer, "%sOstatnie po³¹czenia "red"[%d %s]\n", buffer, call, dli(call, "nieodebrana", "nieodebrane", "nieodebranych"));
		else
		    strcat(buffer, "Ostatnie po³¹czenia\n");

	    if(sms)
	        format(buffer, sizeof buffer, "%sSkrzynka odbiorcza "red"[%d %s]\n", buffer, sms, dli(sms, "nowa", "nowe", "nowych"));
		else
		    strcat(buffer, "Skrzynka odbiorcza\n");
		    
		strcat(buffer, "Ustawienia\n");
		
		if(Phone(playerid, phone_option) & phone_mute)
			strcat(buffer, "Odcisz\n");
		else
		    strcat(buffer, "Wycisz\n");
		    
		strcat(buffer, "Wy³¹cz\n");
		
		Dialog::Output(playerid, 160, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
	}
	else
	    Dialog::Output(playerid, 160, DIALOG_STYLE_LIST, IN_HEAD, "W³¹cz\nWyjmij karte", "Wybierz", "Zamknij");
	return 1;
}
/*
Zadzwoñ -> numer -> treœæ
Wyœlij SMS -> numer -> treœæ
Kontakty -> Lista + dodaj numer | + numery alarmowe -> Zadzwoñ / Wyœlij SMS / Zmieñ nazwê / Skasuj
Ostatnie po³¹czenia [x] -> Lista -> Odzwoñ / Wyœlij SMS / Usuñ
Skrzynka odbiorcza [x] -> Lista -> Odpowiedz / Skasuj
Ustawienia -> Dzwonek telefonu, dzwonek SMS, -----, wyjmij karte
Wycisz/Odcisz
Wy³¹cz
*/
Cmd::Input->tel(playerid, params[])
{
    if(Phone(playerid, phone_to) != INVALID_PLAYER_ID) return EndCall(playerid);
    
	new itemuid = HavePlayerItem(playerid, item_phone);
	if(!itemuid)
	    return ShowInfo(playerid, red"Nie masz telefonu komórkowego!");
	    
	new string[ 100 ];
	format(string, sizeof string,
		"SELECT `v1`, `v2` FROM `surv_items` WHERE `uid` = '%d' AND `v1` != '0' LIMIT 1",
		itemuid
	);
	mysql_query(string);
	mysql_store_result();
	if(mysql_num_rows())
	{
	 	mysql_fetch_row(string);
	 	sscanf(string, "p<|>dd",
	 	    Phone(playerid, phone_number),
	 	    Phone(playerid, phone_uid)
		);

		if(isnull(params))
		    Phone_Default(playerid);
		else
			Call(playerid, strval(params));
	}
	else ShowInfo(playerid, red"Nie posiadasz telefonu z w³o¿on¹ kart¹ SIM!");
	mysql_free_result();
	return 1;
}
Cmd::Input->call(playerid, params[]) return cmd_tel(playerid, params);
Cmd::Input->z(playerid, params[]) return cmd_tel(playerid, "");
Cmd::Input->zakoncz(playerid, params[]) return cmd_tel(playerid, "");

Cmd::Input->sms(playerid, params[])
{
	new itemuid = HavePlayerItem(playerid, item_phone);
	if(!itemuid)
	    return ShowInfo(playerid, red"Nie masz telefonu komórkowego!");

	new string[ 100 ];
	format(string, sizeof string,
		"SELECT `v1`, `v2` FROM `surv_items` WHERE `uid` = '%d' AND `v1` != '0' LIMIT 1",
		itemuid
	);
	mysql_query(string);
	mysql_store_result();
	if(mysql_num_rows())
	{
	 	mysql_fetch_row(string);
	 	sscanf(string, "p<|>dd",
	 	    Phone(playerid, phone_number),
	 	    Phone(playerid, phone_uid)
		);
		
		new numer, tresc[ 126 ];
		if(sscanf(params, "ds[126]", numer, tresc))
		    return Phone_Default(playerid);
		    
		SMS(playerid, numer, tresc);
	}
	else ShowInfo(playerid, red"Nie posiadasz telefonu z w³o¿on¹ kart¹ SIM!");
	mysql_free_result();
	return 1;
}
