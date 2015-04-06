FuncPub::Order_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
 		case 53:
 		{
 		    if(!response) return 1;
 		    
 		    #define masa 5000*(Player(playerid, player_stamina)/3000)+1
 		    
 		    new string[ 126 ],
 		        orderuid = strval(inputtext),
		 		dooruid, weight, drive, amount, groupid;
		 		
			format(string, sizeof string,
				"SELECT `door_uid`, `weight`, `drive`, `amount` FROM `surv_orders` WHERE `uid` = '%d'",
				orderuid
			);
			mysql_query(string);
			mysql_store_result();
			mysql_fetch_row(string);
			mysql_free_result();
			
			sscanf(string, "p<|>dddd",
				dooruid,
				weight,
				drive,
				amount
			);
			
			groupid = IsPlayerInTypeGroup(playerid, group_type_kurier);
			
			if(drive != Player(playerid, player_uid))
			{
			    if(Player(playerid, player_job) != job_kurier && !groupid)
			        return ShowInfo(playerid, red"Nie jesteś kurierem!");
			}

			new doorid;
			foreachex(Server_Doors, doorid)
			    if(Door(doorid, door_uid) == dooruid)
			        break;

			new kurid = 1;
			if(groupid)
			{
			    for(; kurid != MAX_KURIER; kurid++)
			        if(!Kurier(playerid, kurid, pack_id) && !Kurier(playerid, kurid, pack_doorid))
			            break;
				if(kurid == MAX_KURIER || !kurid)
				    return ShowInfo(playerid, red"Nie masz więcej miejsca.");
			}
			else
			{
				kurid = 1;
				if(Kurier(playerid, kurid, pack_id) || Kurier(playerid, kurid, pack_doorid))
				    return ShowInfo(playerid, red"Nosisz już coś.");
			}
			if(weight*amount > masa && IsPlayerInAnyVehicle(playerid))
			{
				if(IsARower(Player(playerid, player_veh)))
					return ShowInfo(playerid, red"Tym pojazdem nie możesz przewozić paczek.");
			}
			else
			{
				if(!IsPlayerInAnyVehicle(playerid))
				{
					if(weight*amount < masa)
					{
					    // Noszenie paczki
					    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
//					    Chat::Output(playerid, CLR_GREEN, "Nosisz paczuszkę na rękach");
					}
					else
					    return ShowInfo(playerid, red"Nie masz wystarczającej siły");
				}
			}
			if(doorid == -1)
			{
				format(string, sizeof string,
					"UPDATE `surv_orders` SET `status` = "#pack_status_end" WHERE `uid` = '%d'",
					orderuid
				);
				mysql_query(string);

				ShowInfo(playerid, "Wystąpił błąd!");
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
			    return 1;
			}
			format(string, sizeof string,
				"UPDATE `surv_orders` SET `status` = "#pack_status_road" WHERE `uid` = '%d'",
				orderuid
			);
			mysql_query(string);

		    Kurier(playerid, kurid, pack_id) = orderuid;
		    Kurier(playerid, kurid, pack_doorid) = doorid;

		    new strid;
		    for(; strid != MAX_STREET; strid++)
		        if(Door(doorid, door_street) == Street(strid, street_uid))
		            break;
		            
			if(!strid)
			{
				DisablePlayerCheckpoint(playerid);
				SetPlayerCheckpoint(playerid, Door(doorid, door_out_pos)[ 0 ], Door(doorid, door_out_pos)[ 1 ], Door(doorid, door_out_pos)[ 2 ], 2.0);

				ShowInfo(playerid, green"Zawieź paczkę na miejsce odbioru!\n\n"white"Punkt został zaznaczony na mapie!");
			}
			else
			{
			    format(string, sizeof string,
			        "Adres do doręczenia: %s %s",
					Street(strid, street_name),
					Door(doorid, door_number)
				);
				Chat::Output(playerid, CLR_GREEN, string);
			}
 		}
 		case 54:
 		{
 		    if(!response) return 1;
 		    new string[ 256 ],
			 	productuid = strval(inputtext);
			format(string, sizeof string,
				"SELECT * FROM `surv_products` WHERE `uid` = '%d'",
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
				itm_weight,
				itm_owner;

			sscanf(string, "p<|>{d}dda<d>[2]fs["#MAX_ITEM_NAME"]df",
			    itm_owner,
				itm_type,
				itm_value,
				itm_value3,
				itm_name,
				itm_weight,
				itm_price
			);
			
			if(Player(playerid, player_cash) < itm_price)
				return ShowInfo(playerid, red"Nie masz tyle gotówki!");
				
			if(itm_type == item_food) itm_value[ 0 ] += gettime();
			else if(itm_type == item_phone)
			{
				mysql_query("INSERT INTO `surv_phone` (`uid`) VALUES (NULL)");
				itm_value[ 1 ] = mysql_insert_id();
			}
			else if(itm_type == item_sim)
			{
			    itm_value[ 0 ] = randomEx(10000000, 99999999);
			}
			Createitem(playerid, itm_type, itm_value[ 0 ], itm_value[ 1 ], itm_value3, itm_name, itm_weight);

			GivePlayerMoneyEx(playerid, 0 - itm_price, true);

	        format(string, sizeof string,
				"UPDATE `surv_products` SET `amount` = `amount` - 1 WHERE `uid` = '%d'",
				productuid
			);
	        mysql_query(string);
			
			format(string, sizeof string,
				"UPDATE `surv_groups` SET `cash` = `cash` + '%.2f' WHERE `uid` = '%d'",
				itm_price,
				itm_owner
			);
			mysql_query(string);
			
			format(string, sizeof string,
				"INSERT INTO `surv_groups_log` VALUES (NULL, '%d', '0', '%d', UNIX_TIMESTAMP(), '%.2f', 'Zakup %s')",
				itm_owner,
				Player(playerid, player_uid),
				itm_price,
				itm_name
			);
			mysql_query(string);
			
			format(string, sizeof string,
			    "Produkt \"%s\" zakupiony!",
			    itm_name
			);
			Chat::Output(playerid, CLR_GREEN, string);
 		}
 		case 55:
 		{
 		    if(!response) return 1;
 		    new productuid = strval(inputtext);
 		    Offer(playerid, offer_value)[ 0 ] = productuid;

 		    Dialog::Output(playerid, 56, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj cene za którą chcesz sprzedać jeden produkt.", "Dalej", "Zamknij");
 		}
 		case 56:
 		{
 		    if(!response) return 1;
			new Float:price = floatstr(inputtext),
			    Float:cena,
			    string[ 64 ];
			format(string, sizeof string, "SELECT `price` FROM `surv_products` WHERE `uid` = %d", Offer(playerid, offer_value)[ 0 ]);
			mysql_query(string);
			mysql_store_result();
			mysql_fetch_float(cena);
			mysql_free_result();
			if(cena <= 0)
				return Dialog::Output(playerid, 56, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj cene za którą chcesz sprzedać jeden produkt.", "Dalej", "Zamknij");

			if(price < cena)
			{
				Dialog::Output(playerid, 56, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj cene za którą chcesz sprzedać jeden produkt.", "Dalej", "Zamknij");
				format(string, sizeof string, "~n~~n~~n~~r~~h~Cena musi byc wieksza od: ~w~$%.2f", cena);
                GameTextForPlayer(playerid, string, 5000, 5);
			}
			else
			{
				Offer(playerid, offer_value3) = price;
				Dialog::Output(playerid, 57, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj ilość produktów, którą chcesz sprzedać.", "Dalej", "Zamknij");
			}
 		}
 		case 57:
 		{
 		    if(!response) return 1;
 			new amount = strval(inputtext);
 			if(!amount) amount = 1;
 			
 		    new string[ 126 ], ilosc;
			format(string, sizeof string, "SELECT `amount` FROM `surv_products` WHERE `uid` = %d", Offer(playerid, offer_value)[ 0 ]);
			mysql_query(string);
			mysql_store_result();
			ilosc = mysql_fetch_int();
			mysql_free_result();
			if(amount <= 0)
				return Dialog::Output(playerid, 57, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj ilość produktów, którą chcesz sprzedać.", "Dalej", "Zamknij");
			if(amount > ilosc)
			{
				format(string, sizeof string, "~n~~n~~n~~r~~h~W magazynie %s tylko ~w~%d ~r~~h~%s.", dli(ilosc, "jest", "sa", "jest"), ilosc, dli(ilosc, "produkt", "produkty", "produktow"));
                GameTextForPlayer(playerid, string, 5000, 5);
				Dialog::Output(playerid, 57, DIALOG_STYLE_INPUT, IN_HEAD, white"Podaj ilość produktów, którą chcesz sprzedać.", "Dalej", "Zamknij");
			}
			else
			{
			    new victimid = Offer(playerid, offer_player);
			    
				Offer(playerid, offer_value)[ 1 ] = amount;
				Offer(playerid, offer_cash) 	= Offer(playerid, offer_value)[ 1 ]*Offer(playerid, offer_value3);
				Offer(playerid, offer_active)   = true;

				Offer(victimid, offer_player) 	= playerid;
				Offer(victimid, offer_value)[ 0 ] 	= Offer(playerid, offer_value)[ 0 ];
				Offer(victimid, offer_value)[ 1 ] 	= Offer(playerid, offer_value)[ 1 ];
				Offer(victimid, offer_value3) 	= Offer(playerid, offer_value3);
				Offer(victimid, offer_cash) 	= Offer(playerid, offer_cash);
				Offer(victimid, offer_active)   = Offer(playerid, offer_active);
				Offer(victimid, offer_type)     = Offer(playerid, offer_type);
				
				ShowPlayerOffer(playerid, victimid);
			}
 		}
 		case 86:
 		{
 		    if(!response) return 1;
 		    new string[ 256 ],
			 	productuid = strval(inputtext);
			format(string, sizeof string,
				"SELECT * FROM `surv_products` WHERE `uid` = '%d'",
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
				itm_weight,
				itm_owner;

			sscanf(string, "p<|>{d}dda<d>[2]fs["#MAX_ITEM_NAME"]df",
			    itm_owner,
				itm_type,
				itm_value,
				itm_value3,
				itm_name,
				itm_weight,
				itm_price
			);

			if(Player(playerid, player_cash) < itm_price)
				return ShowInfo(playerid, red"Nie masz tyle gotówki!");
				
            Createitem(playerid, itm_type, itm_value[ 0 ], itm_value[ 1 ], itm_value3, itm_name, itm_weight);

			GivePlayerMoneyEx(playerid, 0 - itm_price, true);

	        format(string, sizeof string,
				"UPDATE `surv_products` SET `amount` = `amount` - 1 WHERE `uid` = '%d'",
				productuid
			);
	        mysql_query(string);

	        format(string, sizeof string,
				"UPDATE `surv_groups` SET `cash` = `cash` + '%.2f' WHERE `uid` = '%d'",
				itm_price,
				itm_owner
			);
			mysql_query(string);

			format(string, sizeof string,
				"INSERT INTO `surv_groups_log` VALUES (NULL, '%d', '%d', '0', UNIX_TIMESTAMP(), '%.2f', 'Zakup %s z automatu')",
				itm_owner,
				Player(playerid, player_uid),
				itm_price,
				itm_name
			);
			mysql_query(string);
 		}
 		case 88:
 		{
 		    if(!response) return EndCall(playerid);
 		    Tel_OnPlayerText(playerid, inputtext);
 		    new uid = strval(inputtext),
			 	string[ 126 ],
			 	buffer[ 126 ],
			 	pack_name[ 32 ],
			 	pack_idx,
		 		status;
			format(buffer, sizeof buffer, "Numer przesyłki:\t%d\n", uid);

			format(string, sizeof string,
			    "SELECT o.status, o.pack, p.name FROM `surv_orders` o JOIN `surv_pack_pos` p ON o.pack = p.uid WHERE o.uid = '%d'",
			    uid
			);
			mysql_query(string);
			mysql_store_result();
			if(mysql_num_rows())
			{
				mysql_fetch_row(string);
				sscanf(string, "p<|>dds[32]", status, pack_idx, pack_name);
				if(pack_idx)
					format(buffer, sizeof buffer, "%sMagazyn:\t\t%s\n", string, pack_name);
			}
			mysql_free_result();

			
			if(status == pack_status_road)
			{
			    new victimid;
			    foreach(Player, i)
			    {
			        for(new kurid; kurid != MAX_KURIER; kurid++)
			        {
				        if(Kurier(playerid, kurid, pack_id) == uid)
				            victimid = i;
					}
				}
				format(string, sizeof string, "%sStatus:\t\tW drodze\nDostarcza:\t%s", string, NickName(victimid));
			}
			else if(status == pack_status_none) strcat(string, "Status:\t\t\tNie pobrano");
			else strcat(string, "Status:\t\t\tDostarczono");
			
			Dialog::Output(playerid, 89, DIALOG_STYLE_MSGBOX, IN_HEAD, string, "Zamknij", "");
 		}
	}
	return 1;
}

FuncPub::End_Order(playerid)
{
	DeletePVar(playerid, "product-uid");
	DeletePVar(playerid, "product-amount");
	DeletePVar(playerid, "product-group");
	DeletePVar(playerid, "product-sell");
	EndCall(playerid);
	return 1;
}

Cmd::Input->paczki(playerid, params[])
{
	new buffer[ 256 ];
	for(new kurid = 1; kurid != MAX_KURIER; kurid++)
	{
		if(!Kurier(playerid, kurid, pack_id)) continue;
		format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, Kurier(playerid, kurid, pack_id), Door(Kurier(playerid, kurid, pack_doorid), door_name));
	}
	if(isnull(buffer)) ShowInfo(playerid, red"Nie nosisz żadnej paczki!");
	else ShowList(playerid, buffer);
	return 1;
}

Cmd::Input->paczka(playerid, params[])
{
	if(DIN(params, "anuluj"))
	{
		new kurid = 1;
		for(; kurid != MAX_KURIER; kurid++)
			if(Kurier(playerid, kurid, pack_id))
			    break;

		if(kurid == MAX_KURIER || !kurid)
		    return ShowInfo(playerid, red"Nie przewozisz żadnej paczki!");

		DisablePlayerCheckpoint(playerid);
	        
	    new string[ 126 ];
	    format(string, sizeof string,
	        "UPDATE `surv_orders` SET `status` = "#pack_status_none" WHERE `uid`= '%d'",
	        Kurier(playerid, kurid, pack_id)
		);
		mysql_query(string);
		
		for(new eKurier:d; d < eKurier; d++)
		    Kurier(playerid, kurid, d) = 0;

	    if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CARRY)
	    {
	        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	    }
	}
	else
	{
	    new query[ 160 ],
			bool:is = false,
			pack_uid,
			Float:closest_pos[ 3 ];
			
	    GetPlayerPos(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]);
		format(query, sizeof query,
			"SELECT *, SQRT(((X - %f)  * (X - %f)) + ((Y - %f) * (Y - %f))) AS dist FROM `surv_pack_pos` ORDER BY dist",
			Player(playerid, player_position)[ 0 ],
			Player(playerid, player_position)[ 0 ],
			Player(playerid, player_position)[ 1 ],
			Player(playerid, player_position)[ 1 ]
		);
	    mysql_query(query);
	    mysql_store_result();
	    while(mysql_fetch_row(query))
	    {
	        static Float:pos[ 3 ];
	        sscanf(query, "p<|>da<f>[3]",
				pack_uid,
				pos
			);
			if(closest_pos[ 0 ] == 0.0 && closest_pos[ 1 ] == 0.0 && closest_pos[ 1 ] == 0.0)
			{
			    closest_pos[ 0 ] = pos[ 0 ];
			    closest_pos[ 1 ] = pos[ 1 ];
			    closest_pos[ 2 ] = pos[ 2 ];
			}
	        if(IsPlayerInRangeOfPoint(playerid, 15.0, pos[ 0 ], pos[ 1 ], pos[ 2 ]))
			{
				is = true;
				break;
			}
	    }
		mysql_free_result();
		if(is)
		{
			new buffer[ 512 ],
				string[ 40 ];
			format(buffer, sizeof buffer,
				"SELECT surv_orders.uid, surv_orders.drive, surv_doors.name, surv_orders.status FROM `surv_orders` JOIN `surv_doors` ON surv_orders.door_uid = surv_doors.uid WHERE surv_orders.status != "#pack_status_end"",
				pack_uid
			);
			mysql_query(buffer);
			buffer[ 0 ] = EOS;
			mysql_store_result();
			while(mysql_fetch_row(string))
			{
			    static uid,
			        drive,
					name[ MAX_ITEM_NAME ],
					status;
					
				sscanf(string, "p<|>dds["#MAX_ITEM_NAME"]d",
				    uid,
				    drive,
				    name,
				    status
				);
				if(drive == Player(playerid, player_uid))
					format(buffer, sizeof buffer, "%s%d\t%s%s\n", buffer, uid, (status == pack_status_road) ? (C_ORANGE) : (C_GREEN), name);
				else
					format(buffer, sizeof buffer, "%s%d\t%s%s\n", buffer, uid, (status == pack_status_road) ? (C_ORANGE) : (""), name);
			}
			mysql_free_result();
			if(isnull(buffer)) return ShowInfo(playerid, red"Brak paczek, spróbuj ponownie później lub w innym magazynie!");
			else Dialog::Output(playerid, 53, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
		}
		else
		{
			new string[ 256 ],
				add;
			new doorid,
				orderuid;
			for(new kurid = 1; kurid != MAX_KURIER; kurid++)
			{
			    if(!Kurier(playerid, kurid, pack_id))
					continue;

			    orderuid = Kurier(playerid, kurid, pack_id);
				doorid = Kurier(playerid, kurid, pack_doorid);
	    		if(!IsPlayerInRangeOfPoint(playerid, 5.0, Door(doorid, door_out_pos)[ 0 ], Door(doorid, door_out_pos)[ 1 ], Door(doorid, door_out_pos)[ 2 ]))
					continue;

				format(string, sizeof string,
					"SELECT * FROM `surv_orders` WHERE `uid` = '%d'",
					orderuid
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
					itm_weight,
					itm_amount,
					o_door,
					dowoz;

				sscanf(string, "p<|>{ddd}dda<d>[2]fs["#MAX_ITEM_NAME"]ddfd",
				    o_door,
					itm_type,
					itm_value,
					itm_value3,
					itm_name,
					itm_weight,
					itm_amount,
					itm_price,
					dowoz
				);

				format(string, sizeof string,
					"INSERT INTO `surv_products` VALUES (NULL, '%d', '%d', '%d', '%d', '%f', '%s', '%d', '%f', '%d')",
					Door(doorid, door_uid),
					itm_type,
					itm_value[ 0 ],
					itm_value[ 1 ],
					itm_value3,
					itm_name,
					itm_weight,
					itm_price,
					itm_amount
				);
				mysql_query(string);

				format(string, sizeof string,
					"UPDATE `surv_orders` SET `status` = "#pack_status_end", `drive` = '0' WHERE `uid` = '%d'",
					orderuid
				);
				mysql_query(string);

				add++;
	            
	            for(new eKurier:d; d < eKurier; d++)
		    		Kurier(playerid, kurid, d) = 0;
		    		
		    	new gid = IsPlayerInTypeGroup(playerid, group_type_kurier);
                format(string, sizeof string,
					"UPDATE `surv_groups` SET `cash` = `cash` + '%.2f' WHERE `uid` = '%d'",
                    price_kurier/2,
                    Group(playerid, gid, group_uid)
				);
				mysql_query(string);
				
				format(string, sizeof string,
					"INSERT INTO `surv_groups_log` VALUES (NULL, '%d', '%d', '0', UNIX_TIMESTAMP(), '%.2f', 'Zakup %s z automatu')",
					Group(playerid, gid, group_uid),
					Player(playerid, player_uid),
					price_kurier/2
				);
				mysql_query(string);

                GivePlayerMoneyEx(playerid, price_kurier/2, true);

/*	            if(dowoz != Player(playerid, player_uid))
	            {
				}*/
			    if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CARRY)
			    {
			        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
			    }
			}
			if(!add)
			{
			    SetPlayerCheckpoint(playerid, closest_pos[ 0 ], closest_pos[ 1 ], closest_pos[ 2 ], 2.0);
			    ShowInfo(playerid, red"Nie jesteś w punkcie odbioru/dostarczenia paczek!\n\nNajbliższy punkt został zaznaczony na mapie.");
			    return 1;
			}
			else if(add == 1)
		        format(string, sizeof string,
				    "Dostarczyłeś paczke.",
					add
				);
		    else
				format(string, sizeof string,
				    "Dostarczyłeś %d %s na raz.",
					add,
					dli(add, "", "paczki", "paczek")
				);
            
        	for(new s; s != MAX_KURIER; s++)
		    {
			    if(!Kurier(playerid, s, pack_id))
					continue;
				doorid = Kurier(playerid, s, pack_doorid);

				SetPlayerCheckpoint(playerid, Door(doorid, door_out_pos)[ 0 ], Door(doorid, door_out_pos)[ 1 ], Door(doorid, door_out_pos)[ 2 ], 2.0);
			    break;
		    }
		    if(!doorid)
		    {
		        DisablePlayerCheckpoint(playerid);
		  		strcat(string, "\n\nWszystkie paczki dostarczone!");
			}
			ShowInfo(playerid, string);
		}
	}
	return 1;
}
