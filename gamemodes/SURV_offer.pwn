FuncPub::ShowPlayerOffer(playerid, victimid) // playerid - oferuje | victimid - odbiera
{
	Chat::Output(playerid, CLR_GREEN, SEND_OFFER);
	
	new cashStr[ 30 ],
		buffer[ 256 ],
		bool:cart;

    if(!Offer(victimid, offer_cash)) cashStr = "Za darmo";
    else format(cashStr, sizeof cashStr, green2"$"white"%.2f", Offer(victimid, offer_cash));

	switch(Offer(victimid, offer_type))
    {
        case offer_type_item:
        {
            new string[ 126 ];
            
			format(buffer, sizeof buffer,
				"Oferta od:\t%s\nTyp:\t\tPrzedmiot\nInfo:\n",
				NickName(playerid)
			);

			format(string, sizeof string, "SELECT `uid`, `name`, `v1`, `v2` FROM `surv_items` WHERE `ownerType` = "#item_place_player" AND `owner` = '%d' AND `used` = '2'", Player(playerid, player_uid));
			mysql_query(string);
			mysql_store_result();
			while(mysql_fetch_row(string))
			{
           		static itm_uid,
				   	itm_name[ MAX_ITEM_NAME ],
                	itm_value[ 2 ];

				sscanf(string, "p<|>ds["#MAX_ITEM_NAME"]a<d>[2]",
					itm_uid,
					itm_name,
					itm_value
				);
				format(buffer, sizeof buffer,
					"%s\t\t- %s(%d)[%d, %d]\n",
					buffer,
					itm_name,
					itm_uid,
					itm_value[ 0 ], itm_value[ 1 ]
				);
			}
			mysql_free_result();
			
			format(buffer, sizeof buffer,
			    "%s\nCena:\t\t%s",
			    buffer,
			    cashStr
			);
        }
        case offer_type_vehicle:
        {
            new vehid = Offer(playerid, offer_value)[ 1 ];
 			format(buffer, sizeof buffer,
				"Oferta od:\t%s\nTyp:\t\tPojazd\n",
				NickName(playerid)
			);
  			format(buffer, sizeof buffer,
 			    "%sInformacje:\n\t\tUID:\t\t%d\n\t\tNazwa:\t\t%s (%d)\n\t\tPrzebieg:\t%fkm\n\t\tŻycie:\t\t%s%.1f%%", buffer,
 			    Vehicle(vehid, vehicle_uid),
 			    Vehicle(vehid, vehicle_name), Vehicle(vehid, vehicle_model),
 			    Vehicle(vehid, vehicle_distance),
		 		(Vehicle(vehid, vehicle_hp) <= 300) ? (red):(""), Vehicle(vehid, vehicle_hp)/10
			);
			format(buffer, sizeof buffer,
			    "%s\nCena:\t\t%s", buffer,
			    cashStr
			);
		}
        case offer_type_group:
        {
            new groupid = Offer(playerid, offer_value)[ 1 ];
 			format(buffer, sizeof buffer,
				"Oferta od:\t%s\nTyp:\t\tDołączenie do grupy\n",
				NickName(playerid)
			);
 			format(buffer, sizeof buffer,
 			    "%sInformacje:\n\t\tNazwa:\t\t%s(UID: %d)", buffer,
 			    Group(playerid, groupid, group_name),
 			    Group(playerid, groupid, group_uid)
			);
        }
        case offer_type_product:
        {
			new string[ 126 ];
			format(buffer, sizeof buffer,
				"Oferta od:\t%s\nTyp:\t\tProdukt\n",
				NickName(playerid)
			);
			format(string, sizeof string,
				"SELECT `name`, `v1`, `v2` FROM `surv_products` WHERE `uid` = '%d'",
				Offer(playerid, offer_value)[ 0 ]
			);
			mysql_query(string);
			mysql_store_result();
			mysql_fetch_row(string);
			mysql_free_result();
			new itm_name[ MAX_ITEM_NAME ],
				itm_value[ 2 ];
			sscanf(string, "p<|>s["#MAX_ITEM_NAME"]a<d>[2]",
				itm_name,
				itm_value
			);
			format(buffer, sizeof buffer,
				"%sInfo:\t\t%s[%d, %d]\nIlość:\t\t%d\nCena:\t\t%s ("green2"$"white"%.2f * %d)", buffer,
			    itm_name,
			    itm_value[ 0 ], itm_value[ 1 ],
			    Offer(playerid, offer_value)[ 1 ],
			    cashStr,
			    Offer(playerid, offer_value3),
			    Offer(playerid, offer_value)[ 1 ]
			);
			cart = true;
        }
        case offer_type_plate:
        {
        	format(buffer, sizeof buffer,
				"Oferta od:\t%s\nTyp:\t\tZarejestrowanie pojazdu\nInfo:\t\t"#IN_CITY" %s\nCena:\t\t%s",
				NickName(playerid),
				Offer(playerid, offer_value4),
			    cashStr
			);
			cart = true;
		}
		case offer_type_document:
		{
			format(buffer, sizeof buffer,
				"Oferta od:\t%s\nTyp:\t\tPokazanie dokumentu",
				NickName(playerid)
			);
		}
		case offer_type_ulotka:
		{
			format(buffer, sizeof buffer,
				"Oferta od:\t%s\nTyp:\t\tOdebranie ulotki",
				NickName(playerid)
			);
		}
		case offer_type_comp:
		{
			format(buffer, sizeof buffer,
				"Oferta od:\t%s\nTyp:\t\tMontaż komponentu\nNazwa:\t\t%s(%d)\nRobocizna:\t%s",
				NickName(playerid),
				TuneName[ Offer(playerid, offer_value)[ 1 ]-1000 ][ comp_name ],
				Offer(playerid, offer_value)[ 1 ],
				cashStr
			);
		}
		case offer_type_spray:
		{
		    if(Offer(playerid, offer_value)[ 1 ] == -1)
		    {
				format(buffer, sizeof buffer,
					"Oferta od:\t%s\nTyp:\t\tNakładanie Paintjob\nKolor:\t\t%d\nRobocizna:\t%s",
					NickName(playerid),
					Offer(playerid, offer_value)[ 0 ],
					cashStr
				);
		    }
		    else
		    {
				format(buffer, sizeof buffer,
					"Oferta od:\t%s\nTyp:\t\tMalowanie auta\nKolory:\t\t%d/%d\nRobocizna:\t%s",
					NickName(playerid),
					Offer(playerid, offer_value)[ 0 ],
					Offer(playerid, offer_value)[ 1 ],
					cashStr
				);
			}
		}
		case offer_type_konto:
		{
			format(buffer, sizeof buffer,
				"Oferta od:\t%s(%s)\nTyp:\t\tZałożenie konta\nNumer:\t\t%d\nCena:\t\t%s",
				NickName(playerid),
				Group(playerid, Offer(playerid, offer_value)[ 1 ], group_name),
				Offer(playerid, offer_value)[ 0 ],
				cashStr
			);
			cart = true;
		}
		case offer_type_inveh:
		{
			format(buffer, sizeof buffer,
				"Oferta od:\t%s\nTyp:\t\tMontaż elementu\nNazwa:\t\t%s (%d)\nRobocizna:\t%s",
				NickName(playerid),
				InVeh[ Offer(playerid, offer_value)[ 1 ] ][ in_name ],
				Offer(playerid, offer_value)[ 1 ],
				cashStr
			);
		}
		case offer_type_tatoo:
		{
			format(buffer, sizeof buffer,
				"Oferta od:\t%s\nTyp:\t\tTatuaż\nNazwa:\t\t%s\nCena:\t\t%s",
				NickName(playerid),
				Offer(playerid, offer_value4),
				cashStr
			);
		}
		case offer_type_doc:
		{
			format(buffer, sizeof buffer,
				"Oferta od:\t%s\nTyp:\t\tDokument\nNazwa:\t\t%s\nCena:\t\t%s",
				NickName(playerid),
				LicName[ Offer(playerid, offer_value)[ 0 ] ][ lic_name ],
				cashStr
			);
			cart = true;
		}
		case offer_type_anim:
		{
			format(buffer, sizeof buffer,
				"Oferta od:\t%s\nTyp:\t\tUżycie animacji",
				NickName(playerid)
			);
		}
		case offer_type_repair:
		{
		    if(Offer(playerid, offer_value)[ 1 ]) cart = true;
		    
			format(buffer, sizeof buffer,
				"Oferta od:\t%s\nTyp:\t\tNaprawa\nRobocizna:\t"green2"$"white"%.2f + "green2"$"white"%.2f\nŁącznie:\t"green2"$"white"%.2f",
				NickName(playerid),
				Offer(playerid, offer_cash),
				Offer(playerid, offer_value3),
				Offer(playerid, offer_value3) + Offer(playerid, offer_cash)
			);
		}
		case offer_type_leczenie:
		{
			format(buffer, sizeof buffer,
				"Oferta od:\t%s\nTyp:\t\tLeczenie\nCena:\t\t%s",
				NickName(playerid),
				cashStr
			);
		}
		case offer_type_rp:
		{
		    if(Offer(playerid, offer_value)[ 0 ])
		    {
				format(buffer, sizeof buffer,
					"Oferta od:\t%s\nTyp:\t\tAkcja RP\nCena:\t\t%s",
					Group(playerid, Offer(playerid, offer_value)[ 0 ], group_name),
					cashStr
				);
				cart = true;
			}
			else
				format(buffer, sizeof buffer,
					"Oferta od:\t%s\nTyp:\t\tAkcja RP\nCena:\t\t%s",
					NickName(playerid),
					cashStr
				);
		}
		case offer_type_taxi:
		{
			format(buffer, sizeof buffer,
				"Oferta od:\t%s\nTyp:\t\tPrzejazd taksówką\nCena:\t\t%s/km",
				NickName(playerid),
				cashStr
			);
			cart = true;
		}
		case offer_type_silownia:
		{
			format(buffer, sizeof buffer,
				"Oferta od:\t%s\nTyp:\t\tTrening siłowy\nCena:\t\t%s",
				NickName(playerid),
				cashStr
			);
			cart = true;
		}
		case offer_type_walka:
		{
			format(buffer, sizeof buffer,
				"Oferta od:\t%s\nTyp:\t\tNauka %s\nCena:\t\t%s",
				NickName(playerid),
				FightData[ Offer(playerid, offer_value)[ 1 ] ][ fight_name ],
				cashStr
			);
			cart = true;
		}
		case offer_type_mandat:
		{
			format(buffer, sizeof buffer,
				"Oferta od:\t%s\nTyp:\t\tMandat\nPunkty:\t%d\nPowód:\t%s\nCena:\t\t%s",
				NickName(playerid),
				Offer(playerid, offer_value)[ 0 ],
				Offer(playerid, offer_value4),
				cashStr
			);
			cart = true;
		}
		case offer_type_hol:
		{
			format(buffer, sizeof buffer,
				"Oferta od:\t%s\nTyp:\t\tHolowanie\nCena:\t\t%s",
				NickName(playerid),
				cashStr
			);
		}
		case offer_type_blokada:
		{
			format(buffer, sizeof buffer,
				"Oferta od:\t%s\nTyp:\t\tZdjęcie blokady na koło\nCena:\t\t%s",
				NickName(playerid),
				cashStr
			);
		}
		case offer_type_tank:
		{
			format(buffer, sizeof buffer,
				"Oferta od:\t%s\nTyp:\t\tTankowanie\nCena:\t\t%s",
				NickName(playerid),
				cashStr
			);
		}
		case offer_type_hotdog:
		{
			format(buffer, sizeof buffer,
				"Oferta od:\t%s\nTyp:\t\tZakup hotdoga\nCena:\t\t%s",
				NickName(playerid),
				cashStr
			);
		}
        default: return Chat::Output(playerid, CLR_RED, "Opcja niedostępna");
    }
    if(Offer(victimid, offer_cash))
    {
		strcat(buffer, grey"\n------------------------\n");
		if(cart)
		{
			new doorid = GetPlayerDoor(playerid, false),
				string[ 200 ],
				paypass,
				card;
			format(string, sizeof string,
				"SELECT `v3` FROM `surv_items` WHERE `ownerType` = "#item_place_player" AND `owner` = '%d' AND `type` = "#item_karta"",
				Player(playerid, player_uid)
			);
			mysql_query(string);
			mysql_store_result();
			while(mysql_fetch_row(string))
			{
				static id;
				id = strval(string);
				if(id) paypass++;
				card++;
			}
			mysql_free_result();
			if(Door(doorid, door_option) & door_option_card && card)
			{
				strcat(buffer, "Zapłać kartą\n");
			}
			if(Door(doorid, door_option) & door_option_paypass && paypass && Offer(victimid, offer_cash) > 50)
			{
				strcat(buffer, "Zapłać kartą zbliżeniową\n");
			}
		}
		strcat(buffer, "Zapłać gotówką\n");
	}
    Dialog::Output(victimid, 26, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Akceptuj", "Odrzuć");
	return 1;
}

FuncPub::Offer_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case 26:
	    {
	        if(!response) GameTextForPlayer(Offer(playerid, offer_player), "~r~Oferta odrzucona", 3000, 3);
	        else 
			{
				if(DIN(inputtext, "Zapłać kartą zbliżeniowo"))
				{
					new buffer[ 256 ], 
						string[ 64 ],
						count;
					format(buffer, sizeof buffer, "SELECT DISTINCT `v1`, `name`, `v2` FROM `surv_items` WHERE `ownerType` = "#item_place_player" AND `owner` = '%d' AND `type` = "#item_karta" AND `v3` = '1'", Player(playerid, player_uid));
					mysql_query(buffer);
					mysql_store_result();

					buffer = grey"Wybierz kartę:\n";

					while(mysql_fetch_row_format(string))
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
					if(count) return Dialog::Output(playerid, 70, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
					else ShowInfo(playerid, red"Nie posiadasz karty z funkcją paypass.");
				}
				else if(DIN(inputtext, "Zapłać kartą"))
				{
					new buffer[ 256 ], 
						string[ 64 ],
						count;
					format(buffer, sizeof buffer, "SELECT DISTINCT `v1`, `name`, `v2` FROM `surv_items` WHERE `ownerType` = "#item_place_player" AND `owner` = '%d' AND `type` = "#item_karta"", Player(playerid, player_uid));
					mysql_query(buffer);
					mysql_store_result();

					buffer = grey"Wybierz kartę:\n";

					while(mysql_fetch_row_format(string))
					{
						static uid,
							name[ MAX_ITEM_NAME ],
							block;
						sscanf(string, "p<|>ds["#MAX_ITEM_NAME"]d",
							uid,
							name,
							block
						);
						if(block) format(buffer, sizeof buffer, "%s%d\t"red"%s\n", buffer, uid, name);
						else format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, uid, name);
						count++;
					}
					mysql_free_result();
					if(count) return Dialog::Output(playerid, 71, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
					else ShowInfo(playerid, red"Nie posiadasz karty.");
				}
				else Oferta(playerid, Offer(playerid, offer_player), offer_pay_cash);
	        }
	        ClearOffer(playerid);
	    }
		case 70:
		{
			if(!response) GameTextForPlayer(Offer(playerid, offer_player), "~r~Oferta odrzucona", 3000, 3);
			else 
			{
				new card = strval(inputtext),
					string[ 126 ];
				
				format(string, sizeof string, "SELECT `v2` FROM `surv_items` WHERE `v1` = '%d'", card);
				mysql_query(string);
				mysql_store_result();
				new bool:reason;
				if(mysql_fetch_int())
					reason = true;
				mysql_free_result();
				
				Bankomat(playerid, bank_number) = card;
				
				if(reason) 
				{
					ShowInfo(playerid, red"Ta karta została zablokowana!");
					GameTextForPlayer(Offer(playerid, offer_player), "~r~Oferta odrzucona", 3000, 3);
				}
				else Oferta(playerid, Offer(playerid, offer_player), card);
			}
		  	ClearOffer(playerid);
		}
		case 71:
		{
			if(!response) GameTextForPlayer(Offer(playerid, offer_player), "~r~Oferta odrzucona", 3000, 3);
			else 
			{
				new card = strval(inputtext),
					string[ 126 ];
				
				format(string, sizeof string, "SELECT `v2` FROM `surv_items` WHERE `v1` = '%d'", card);
				mysql_query(string);
				mysql_store_result();
				new bool:reason;
				if(mysql_fetch_int())
					reason = true;
				mysql_free_result();
				
				Bankomat(playerid, bank_number) = card;
				
				if(reason) 
				{
					ShowInfo(playerid, red"Ta karta została zablokowana!");
					GameTextForPlayer(Offer(playerid, offer_player), "~r~Oferta odrzucona", 3000, 3);
				}
				else return Dialog::Output(playerid, 72, DIALOG_STYLE_PASSWORD, IN_HEAD, bank_pin, "Dalej", "Zamknij");
			}
		  	ClearOffer(playerid);
		}
		case 72:
		{
    	    if(!response) GameTextForPlayer(Offer(playerid, offer_player), "~r~Oferta odrzucona", 3000, 3);
    	    else
			{
				if(isnull(inputtext) || strlen(inputtext) > 32)
					return Dialog::Output(playerid, 72, DIALOG_STYLE_PASSWORD, IN_HEAD, bank_pin, "Dalej", "Zamknij");

				new string[ 128 ];
				mysql_real_escape_string(inputtext, inputtext);
				format(string, sizeof string, "SELECT 1 FROM `surv_bank` WHERE `pin` = md5('%s') AND `number` = '%d'", inputtext, Bankomat(playerid, bank_number));
				mysql_query(string);
				mysql_store_result();
				if(mysql_num_rows())
					Oferta(playerid, Offer(playerid, offer_player), Bankomat(playerid, bank_number));
				else
				{
					Dialog::Output(playerid, 72, DIALOG_STYLE_PASSWORD, IN_HEAD, bank_pin, "Dalej", "Zamknij");
					GameTextForPlayer(playerid, "~n~~n~~n~~r~~h~Podales bledne haslo!", 5000, 5);
				}
				mysql_free_result();
			}			
		  	ClearOffer(playerid);
	  	}
		case 80:
		{
		    if(!response)
		    {
				GameTextForPlayer(Offer(playerid, offer_player), "~r~Oferta odrzucona", 3000, 3);
		        ClearOffer(playerid);
				return 1;
		    }
		    new victimid = Offer(playerid, offer_player),
		        vehicle = strval(inputtext),
				string[ 256 ],
				randomchars[ 6 ];
				
			Offer(playerid, offer_value)[ 0 ] = vehicle;
			Offer(victimid, offer_value)[ 0 ] = vehicle;
				
			for(new d; d != 20; d++)
			{
			    for(new i; i != sizeof randomchars-1; i++)
			        randomchars[ i ] = znaki[randomEx(26, sizeof znaki)];

			    format(string, sizeof string,
					"%s"#IN_CITY" %s\n",
					string,
					randomchars
				);
			}
			Dialog::Output(playerid, 81, DIALOG_STYLE_LIST, IN_HEAD, string, "Wybierz", "Zamknij");
		}
		case 81:
		{
		    if(!response)
		    {
				GameTextForPlayer(Offer(playerid, offer_player), "~r~Oferta odrzucona", 3000, 3);
		        ClearOffer(playerid);
				return 1;
		    }
		    
		    //
		    new buffer[ 126 ];
		    format(buffer, sizeof buffer,
		        "SELECT 1 FROM `surv_vehicles` WHERE `plate` LIKE '%s'",
		        inputtext[ strlen(IN_CITY) + 1 ]
			);
			mysql_query(buffer);
			mysql_store_result();
			if(mysql_num_rows())
			{
			    new string[ 256 ],
					randomchars[ 6 ];
				for(new d; d != 20; d++)
				{
				    for(new i; i != sizeof randomchars-1; i++)
				        randomchars[ i ] = znaki[randomEx(26, sizeof znaki)];

				    format(string, sizeof string,
						"%s"#IN_CITY" %s\n",
						string,
						randomchars
					);
				}
				Dialog::Output(playerid, 81, DIALOG_STYLE_LIST, IN_HEAD, string, "Wybierz", "Zamknij");
                mysql_free_result();
				return 1;
			}
			mysql_free_result();
			
		    new victimid = Offer(playerid, offer_player);
		    
		    format(Offer(playerid, offer_value4), 64, inputtext[ strlen(IN_CITY) + 1 ]);
			Offer(playerid, offer_active)       = true;

		    format(Offer(victimid, offer_value4), 64, inputtext[ strlen(IN_CITY) + 1 ]);
			Offer(victimid, offer_active)       = true;
			
			ShowPlayerOffer(victimid, playerid);
		}
		case 134:
		{
		    if(!response)
		    {
				GameTextForPlayer(Offer(playerid, offer_player), "~r~Oferta odrzucona", 3000, 3);
	          	ClearOffer(playerid);
				return 1;
		    }
		    new licid = strval(inputtext);
		    new victimid = Offer(playerid, offer_player);

			Offer(playerid, offer_active)       = true;
			Offer(playerid, offer_value)[ 0 ] 	= licid;
			Offer(playerid, offer_cash)			= LicName[ licid ][ lic_price ];

			Offer(victimid, offer_value)[ 0 ] 	= licid;
			Offer(victimid, offer_active)       = true;
			Offer(victimid, offer_cash)			= LicName[ licid ][ lic_price ];

            ShowPlayerOffer(playerid, victimid);
		}
		case 157:
	    {
	        if(!response)
			{
			    Player(playerid, player_npc) = INVALID_PLAYER_ID;
				return 1;
			}
	        new doc = strval(inputtext),
				victimid = Player(playerid, player_npc),
				buffer[ 126 ];

			format(buffer, sizeof buffer, "Chciałbym wyrobić %s.", LicName[ doc ][ lic_name ]);
	        OnPlayerText(playerid, buffer);

	        switch(doc)
	        {
	            case doc_dowod:
	            {
	                format(buffer, sizeof buffer, "W takim razie poproszę zdjęcie oraz "green2"$"white"%.2f", LicName[ doc ][ lic_price ]);
	            	OnPlayerText(NPC(victimid, npc_playerid), buffer);

					Offer(playerid, offer_type) 		= offer_type_doc;
					Offer(playerid, offer_player) 		= NPC(victimid, npc_playerid);
					Offer(playerid, offer_value)[ 0 ] 	= doc;
					Offer(playerid, offer_value)[ 1 ] 	= Door(NPC(victimid, npc_door), door_owner)[ 1 ];
					Offer(playerid, offer_cash)			= LicName[ doc ][ lic_price ];
					Offer(playerid, offer_active)       = true;

					Offer(NPC(victimid, npc_playerid), offer_type) 			= offer_type_doc;
					Offer(NPC(victimid, npc_playerid), offer_player) 		= playerid;
					Offer(NPC(victimid, npc_playerid), offer_value)[ 0 ] 	= doc;
					Offer(NPC(victimid, npc_playerid), offer_value)[ 1 ] 	= Door(NPC(victimid, npc_door), door_owner)[ 1 ];
					Offer(NPC(victimid, npc_playerid), offer_cash)			= LicName[ doc ][ lic_price ];
					Offer(NPC(victimid, npc_playerid), offer_active)       	= true;

	                ShowPlayerOffer(NPC(victimid, npc_playerid), playerid);
                }
                default: ShowInfo(victimid, red"Opcja niedostępna.");
			}
	    }
	}
	return 1;
}

FuncPub::ClearOffer(playerid)
{
	new victimid = Offer(playerid, offer_player);
	if(victimid != INVALID_PLAYER_ID)
	{
  		for(new eOffer:i; i < eOffer; i++)
			Offer(victimid, i) = 0;
		Offer(victimid, offer_player) = INVALID_PLAYER_ID;
	}
	for(new eOffer:i; i < eOffer; i++)
		Offer(playerid, i) = 0;
	Offer(playerid, offer_player) = INVALID_PLAYER_ID;
	return 1;
}

FuncPub::Oferta(playerid, victimid, type) // playerid - odbiera | victimid - oferuje
{
	if(!Offer(playerid, offer_active) || !Offer(victimid, offer_active))
	    return 1;
	#if Debug
	    printf("[Offer]: Oferta od %s dla %s", NickName(victimid), NickName(playerid));
	    printf("[Offer]: v1: %d, v2: %d, v3: %f, v4: %s", Offer(victimid, offer_value)[ 0 ], Offer(victimid, offer_value)[ 1 ], Offer(victimid, offer_value3), Offer(victimid, offer_value4));
	#endif
	    
 	if(!IsPlayerConnected(playerid))
	 	return ShowInfo(victimid, red"Oferta została anulowana.\n\nGracz opuścił serwer.");

 	if(!IsPlayerConnected(victimid))
	 	return ShowInfo(playerid, red"Oferta została anulowana.\n\nGracz opuścił serwer.");

 	if(Offer(playerid, offer_cash) > Player(playerid, player_cash) && !type)
	{
		ShowInfo(playerid, red"Oferta została anulowana.\n\nNie posiadasz wystarczającej ilości gotówki.");
	    ShowInfo(victimid, red"Oferta została anulowana.\n\nTen gracz nie posiada wystarczającej ilości gotówki.");
		return 1;
	}

	new buffer[ 256 ];
	switch(Offer(victimid, offer_type))
	{
	    case offer_type_item:
	    {
	    	Chat::Output(playerid, CLR_GREEN, "Kupiłeś przedmioty.");
			Chat::Output(victimid, CLR_GREEN, "Przedmioty został sprzedany.");

	        GivePlayerMoneyEx(playerid, 0 - Offer(victimid, offer_cash), true);
	        GivePlayerMoneyEx(victimid, Offer(victimid, offer_cash), true);

	        format(buffer, sizeof buffer,
				"UPDATE `surv_items` SET `owner` = '%d', `used` = '0', `favorite` = '0' WHERE `ownerType` = "#item_place_player" AND `owner` = '%d' AND `used` = '2'",
				Player(playerid, player_uid),
				Player(victimid, player_uid)
			);
	        mysql_query(buffer);
	        Player(victimid, player_item_selected) = 0;
		    if(IsPlayerVisibleItems(victimid))
		    {
				for(new i = 1; i != MAX_ITEMS; i++)
				{
				    if(Item(victimid, i, item_uid) == Offer(victimid, offer_value)[ 0 ]) continue;
				    if(Item(victimid, i, item_uid))
					{
				    	ShowPlayerItems(victimid, Player(victimid, player_item_site));
						break;
					}
			        HideItemsTextDraw(victimid);
					return 1;
				}
			}
		    if(IsPlayerVisibleItems(playerid))
		    	ShowPlayerItems(playerid, Player(playerid, player_item_site));
	    }
	    case offer_type_vehicle:
	    {
	        new vehid = Offer(victimid, offer_value)[ 1 ];
	        Vehicle(vehid, vehicle_owner)[ 1 ] = Player(playerid, player_uid);
	        
	        GivePlayerMoneyEx(playerid, 0 - Offer(victimid, offer_cash), true);
	        GivePlayerMoneyEx(victimid, Offer(victimid, offer_cash), true);

            format(buffer, sizeof buffer,
				"UPDATE `surv_vehicles` SET `owner` = '%d' WHERE `uid` = '%d'",
				Vehicle(vehid, vehicle_owner)[ 1 ],
				Offer(victimid, offer_value)[ 0 ]
			);
			mysql_query(buffer);
			
			SendClientMessage(victimid, CLR_GREEN, "Twój pojazd został sprzedany!");
			SendClientMessage(playerid, CLR_GREEN, "Zakupiłeś pojazd.");
			
			RemovePlayerFromVehicle(victimid);
	    }
	    case offer_type_group:
	    {
			new groupid = AddPlayerToGroup(playerid, Offer(victimid, offer_value)[ 0 ]);
			if(groupid)
			{
				SendClientMessage(victimid, CLR_GREEN, "Przyjąłeś gracza do grupy.");
				SendClientMessage(playerid, CLR_GREEN, "Witaj w grupie.");
				GivePlayerAchiv(playerid, achiv_join);
			}
			else ShowInfo(victimid, red"Wystąpił nieznany błąd!");
	    }
	    case offer_type_product:
	    {
	        new productuid = Offer(victimid, offer_value)[ 0 ],
	            amount = Offer(victimid, offer_value)[ 1 ],
		 		doorid = Player(victimid, player_door_id);
			 	
			format(buffer, sizeof buffer,
				"SELECT * FROM `surv_products` WHERE `uid` = '%d'",
				productuid
			);
			mysql_query(buffer);
			mysql_store_result();
			mysql_fetch_row(buffer);
			mysql_free_result();

			new itm_type,
				itm_value[ 2 ],
				Float:itm_value3,
				itm_name[ MAX_ITEM_NAME ],
				itm_weight,
				Float:itm_price;

			sscanf(buffer, "p<|>{dd}da<d>[2]fs["#MAX_ITEM_NAME"]df",
				itm_type,
				itm_value,
				itm_value3,
				itm_name,
				itm_weight,
				itm_price
			);
			if(itm_type == item_food) itm_value[ 0 ] += gettime();

			for(new i; i != amount; i++)
            	Createitem(playerid, itm_type, itm_value[ 0 ], itm_value[ 1 ], itm_value3, itm_name, itm_weight);

	        format(buffer, sizeof buffer,
				"UPDATE `surv_products` SET `amount` = `amount` - '%d' WHERE `uid` = '%d'",
				amount,
				productuid
			);
	        mysql_query(buffer);
	        
	        new groupuid, 
				groupname[ 32 ];
			format(buffer, sizeof buffer,
				"SELECT surv_groups.uid, surv_groups.name FROM `surv_groups` JOIN `surv_doors` ON surv_groups.uid = surv_doors.owner WHERE surv_doors.uid = '%d'",
				Door(doorid, door_uid)
			);
			mysql_query(buffer);
			mysql_store_result();
			mysql_fetch_row(buffer);
			sscanf(buffer, "p<|>ds[32]",
				groupuid,
				groupname
			);
			mysql_free_result();

			format(buffer, sizeof buffer,
				"UPDATE `surv_groups` SET `cash` = `cash` + '%.2f' WHERE `uid` = '%d'",
				Offer(victimid, offer_cash),
				groupuid
			);
			mysql_query(buffer);

			format(buffer, sizeof buffer,
				"INSERT INTO `surv_groups_log` VALUES (NULL, '%d', '%d', '%d', UNIX_TIMESTAMP(), '%.2f', 'Sprzedaz %dx %s')",
				groupuid,
				Player(victimid, player_uid),
				Player(playerid, player_uid),
				Offer(victimid, offer_cash),
				amount,
				itm_name
			);
			mysql_query(buffer);

			if(!type)
				GivePlayerMoneyEx(playerid, 0 - Offer(victimid, offer_cash), true);
			else
			{
				format(buffer, sizeof buffer, 
					"UPDATE `surv_bank` SET `cash` = `cash` - '%.2f' WHERE `number` = '%d'", 
					Offer(victimid, offer_cash), 
					type
				);
				mysql_query(buffer);
				
				new Float:stan;
				format(buffer, sizeof buffer, 
					"SELECT `cash` FROM `surv_bank` WHERE `number` = '%d'", 
					type
				);
				mysql_query(buffer);
				mysql_store_result();
				mysql_fetch_float(stan);
				mysql_free_result();
				
				format(buffer, sizeof buffer, 
					"Zakup w %s(%s) za $%.2f. Stan: $%.2f",
					Door(doorid, door_name),
					groupname,
					Offer(victimid, offer_cash), 
					stan
				); 
				mysql_real_escape_string(buffer, buffer);
				
				format(buffer, sizeof buffer, 
					"INSERT INTO `surv_bank_log` VALUE (NULL, UNIX_TIMESTAMP(), '%d', '%s')", 
					type, 
					buffer
				);
				mysql_query(buffer);
				
				Bank_Clear(playerid);
			}
			
	    	Chat::Output(playerid, CLR_GREEN, "Zaakceptowałeś ofertę.");
			Chat::Output(victimid, CLR_GREEN, "Gracz zaakceptował ofertę.");
	    }
	    case offer_type_plate:
	    {
	        format(buffer, sizeof buffer,
	            "UPDATE `surv_vehicles` SET `plate` = '%s' WHERE `uid` = '%d'",
	            Offer(playerid, offer_value4),
	            Offer(playerid, offer_value)[ 0 ]
			);
	        mysql_query(buffer);
	        
			if(!type)
				GivePlayerMoneyEx(playerid, 0 - Offer(victimid, offer_cash), true);
			else
			{
				format(buffer, sizeof buffer,
					"UPDATE `surv_bank` SET `cash` = `cash` - '%.2f' WHERE `number` = '%d'",
					Offer(victimid, offer_cash),
					type
				);
				mysql_query(buffer);

				new Float:stan;
				format(buffer, sizeof buffer,
					"SELECT `cash` FROM `surv_bank` WHERE `number` = '%d'",
					type
				);
				mysql_query(buffer);
				mysql_store_result();
				mysql_fetch_float(stan);
				mysql_free_result();

				format(buffer, sizeof buffer,
					"Zakup rejestracji za $%.2f. Stan: $%.2f",
					Offer(victimid, offer_cash),
					stan
				);
				mysql_real_escape_string(buffer, buffer);

				format(buffer, sizeof buffer,
					"INSERT INTO `surv_bank_log` VALUE (NULL, UNIX_TIMESTAMP(), '%d', '%s')",
					type,
					buffer
				);
				mysql_query(buffer);

				Bank_Clear(playerid);
			}
			
	    	Chat::Output(playerid, CLR_GREEN, "Zaakceptowałeś ofertę. Pojazd został zarejestrowany pomyślnie.");
			Chat::Output(victimid, CLR_GREEN, "Gracz zaakceptował ofertę.");
	    }
	    case offer_type_document:
	    {
	        // value[ 0 ] = item_uid
			Chat::Output(victimid, CLR_GREEN, "Dokument pokazany.");

			new value[ 2 ];
			new playername[ MAX_PLAYERS ], age;
			new year;
			getdate(year);
			
			format(buffer, sizeof buffer,
			    "SELECT `v1`, `v2` FROM `surv_items` WHERE `uid` = '%d'",
			    Offer(playerid, offer_value)[ 0 ]
			);
			mysql_query(buffer);
			mysql_store_result();
			mysql_fetch_row(buffer);
			sscanf(buffer, "p<|>a<d>[2]", value);
			mysql_free_result();
			
			format(buffer, sizeof buffer,
				"SELECT `name`, `age` FROM `surv_players` WHERE `uid` = '%d'",
				value[ 0 ]
			);
			mysql_query(buffer);
			mysql_store_result();
			mysql_fetch_row(buffer);

			sscanf(buffer, "p<|>s["#MAX_PLAYER_NAME"]d",
			    playername,
			    age
			);
			mysql_free_result();
			
			UnderscoreToSpace(playername);

	        format(buffer, sizeof buffer,
				white"\tDane Licencji:\n\nImię i Nazwisko:\t\t%s\nRok urodzenia:\t\t%d\nLicencja:\t\t\t%s",
				playername,
				year - age,
				LicName[ value[ 1 ] ][ lic_name ]
			);
			ShowInfo(playerid, buffer);
	    }
	    case offer_type_ulotka:
	    {
	        new text[ 512 ],
				groupid;

	        mysql_query("SELECT `text`, `group` FROM `surv_ulotka` WHERE `end` > UNIX_TIMESTAMP() ORDER BY RAND() LIMIT 1");
			mysql_store_result();
			mysql_fetch_row_format(text);
			if(!mysql_num_rows())
			{
			    ShowInfo(playerid, red"Brak dostępnych ulotek!");
				ShowInfo(victimid, red"Brak dostępnych ulotek!");
				mysql_free_result();
			    return 1;
			}
			mysql_free_result();
			sscanf(text, "p<|>s[512]d",
				text,
				groupid
			);
			
			format(text, sizeof text,
				"INSERT INTO `surv_karteczki` VALUES (NULL, '%s', '"#kart_type_group"', '%d', UNIX_TIMESTAMP())",
				text,
				groupid
			);
			mysql_query(text);
			
			Createitem(playerid, item_kartka, mysql_insert_id(), 0, 0.0, "Ulotka", 0);
			
			GivePlayerMoneyEx(playerid, 0.5, true);

	    	Chat::Output(playerid, CLR_GREEN, "Zaakceptowałeś ofertę.");
			Chat::Output(victimid, CLR_GREEN, "Gracz zaakceptował ofertę. Otrzymałeś "green2"$"white"0.5");
	    }
	    case offer_type_comp:
	    {
	        Repair(victimid, repair_cash) = Offer(victimid, offer_cash);
	        Repair(victimid, repair_time) = time_repair;
	        Repair(victimid, repair_type) = repair_comp;
	        Repair(victimid, repair_player) = playerid;
	        Repair(victimid, repair_value)[ 0 ] = Offer(victimid, offer_value)[ 0 ];
	        Repair(victimid, repair_value)[ 1 ] = Offer(victimid, offer_value)[ 1 ];
	        Repair(victimid, repair_value)[ 2 ] = Player(playerid, player_veh);

	        GivePlayerMoneyEx(playerid, 0 - Offer(victimid, offer_cash), true);

	    	Chat::Output(playerid, CLR_GREEN, "Zaakceptowałeś oferte, teraz poczekaj, aż mechanik zamontuje komponent.");
			Chat::Output(victimid, CLR_GREEN, "Gracz zaakceptował montaż komponentu, montuj go do czasu zakończenia się odliczania.");
	    }
	    case offer_type_spray:
	    {
	        Repair(victimid, repair_cash) = Offer(victimid, offer_cash);
	        Repair(victimid, repair_player) = playerid;
	        Repair(victimid, repair_type) = repair_spray;
	        Repair(victimid, repair_value)[ 0 ] = Offer(playerid, offer_value)[ 0 ];
	        Repair(victimid, repair_value)[ 1 ] = Offer(playerid, offer_value)[ 1 ];
	        Repair(victimid, repair_value)[ 2 ] = Player(playerid, player_veh);

	        GivePlayerMoneyEx(playerid, 0 - Offer(victimid, offer_cash), true);

	    	Chat::Output(playerid, CLR_GREEN, "Zaakceptowałeś oferte, teraz poczekaj, aż mechanik przemaluje pojazd.");
			Chat::Output(victimid, CLR_GREEN, "Gracz zaakceptował malowanie auta, pryskaj w stronę auta sprayem.");

            if(Player(victimid, player_spray) == Text3D:INVALID_3DTEXT_ID)
            {
	    		Player(victimid, player_spray) = Create3DTextLabel("Rozpoczynanie malowania", COLOR_PURPLE, 0.0, 0.0, 0.0, 5.0, 0, 1);
				Attach3DTextLabelToVehicle(Player(victimid, player_spray), Repair(victimid, repair_value)[ 2 ], 0.0, 0.0, 1.0);
			}
	    }
	    case offer_type_konto:
	    {
	        new groupid = Offer(victimid, offer_value)[ 1 ],
	            numer = Offer(victimid, offer_value)[ 0 ];
	            
			format(buffer, sizeof buffer,
				"UPDATE `surv_groups` SET `cash` = `cash` + '%.2f' WHERE `uid` = '%d'",
				Offer(victimid, offer_cash),
				Group(victimid, groupid, group_uid)
			);
			mysql_query(buffer);
			
			format(buffer, sizeof buffer,
			    "INSERT INTO `surv_bank` VALUES (NULL, '"#bank_type_player"', '%d', '%d', '0', '1234', 'Konto główne', '%d')",
			    Player(playerid, player_uid),
			    numer,
			    Group(victimid, groupid, group_uid)
			);
			mysql_query(buffer);

			if(!type)
				GivePlayerMoneyEx(playerid, 0 - Offer(victimid, offer_cash), true);
			else
			{
				format(buffer, sizeof buffer,
					"UPDATE `surv_bank` SET `cash` = `cash` - '%.2f' WHERE `number` = '%d'",
					Offer(victimid, offer_cash),
					type
				);
				mysql_query(buffer);

				new Float:stan;
				format(buffer, sizeof buffer,
					"SELECT `cash` FROM `surv_bank` WHERE `number` = '%d'",
					type
				);
				mysql_query(buffer);
				mysql_store_result();
				mysql_fetch_float(stan);
				mysql_free_result();

				format(buffer, sizeof buffer,
					"Założenie konta w %s za $%.2f. Stan: $%.2f",
					Group(victimid, groupid, group_name),
					Offer(victimid, offer_cash),
					stan
				);
				mysql_real_escape_string(buffer, buffer);

				format(buffer, sizeof buffer,
					"INSERT INTO `surv_bank_log` VALUE (NULL, UNIX_TIMESTAMP(), '%d', '%s')",
					type,
					buffer
				);
				mysql_query(buffer);

				Bank_Clear(playerid);
			}
	    	Chat::Output(playerid, CLR_GREEN, "Zaakceptowałeś oferte. Konto zostało stworzone. PIN: 1234");
			Chat::Output(victimid, CLR_GREEN, "Gracz zaakceptował oferte.");
	    }
	    case offer_type_inveh:
	    {
	        Repair(victimid, repair_cash) = Offer(victimid, offer_cash);
	        Repair(victimid, repair_time) = time_repair;
	        Repair(victimid, repair_type) = repair_inveh;
	        Repair(victimid, repair_player) = playerid;
	        Repair(victimid, repair_value)[ 0 ] = Offer(victimid, offer_value)[ 0 ];
	        Repair(victimid, repair_value)[ 1 ] = Offer(victimid, offer_value)[ 1 ];
	        Repair(victimid, repair_value)[ 2 ] = Player(playerid, player_veh);
	        Repair(victimid, repair_value)[ 3 ] = floatval(Offer(victimid, offer_value3));

	        GivePlayerMoneyEx(playerid, 0 - Offer(victimid, offer_cash), true);
	    	Chat::Output(playerid, CLR_GREEN, "Zaakceptowałeś oferte, teraz poczekaj, aż mechanik zamontuje elementu.");
			Chat::Output(victimid, CLR_GREEN, "Gracz zaakceptował montaż elementu, montuj go do czasu zakończenia się odliczania.");
	    }
	    case offer_type_tatoo:
	    {
	    	Chat::Output(playerid, CLR_GREEN, "Zaakceptowałeś oferte!");
			Chat::Output(victimid, CLR_GREEN, "Gracz zaakceptował tatuaż.");
			
			GivePlayerMoneyEx(playerid, 0 - Offer(victimid, offer_cash), true);
			GivePlayerMoneyEx(victimid, Offer(victimid, offer_cash), true);
			
			mysql_real_escape_string(Offer(victimid, offer_value4), Offer(victimid, offer_value4));
			format(buffer, sizeof buffer,
			    "INSERT INTO `surv_tatoo` VALUES (NULL, '%d', '%s');",
			    Player(playerid, player_uid),
			    Offer(victimid, offer_value4)
			);
			mysql_query(buffer);
	    }
	    case offer_type_doc:
	    {
	    	Chat::Output(playerid, CLR_GREEN, "Zaakceptowałeś oferte!");
			Chat::Output(victimid, CLR_GREEN, "Gracz zaakceptował kupno dokumentu.");

			if(!type)
				GivePlayerMoneyEx(playerid, 0 - Offer(victimid, offer_cash), true);
			else
			{
				format(buffer, sizeof buffer,
					"UPDATE `surv_bank` SET `cash` = `cash` - '%.2f' WHERE `number` = '%d'",
					Offer(victimid, offer_cash),
					type
				);
				mysql_query(buffer);

				new Float:stan;
				format(buffer, sizeof buffer,
					"SELECT `cash` FROM `surv_bank` WHERE `number` = '%d'",
					type
				);
				mysql_query(buffer);
				mysql_store_result();
				mysql_fetch_float(stan);
				mysql_free_result();

				format(buffer, sizeof buffer,
					"Zakup %s w %s za $%.2f. Stan: $%.2f",
					LicName[ Offer(victimid, offer_value)[ 0 ] ][ lic_name ],
					Group(victimid, Offer(victimid, offer_value)[ 1 ], group_name),
					Offer(victimid, offer_cash),
					stan
				);
				mysql_real_escape_string(buffer, buffer);

				format(buffer, sizeof buffer,
					"INSERT INTO `surv_bank_log` VALUE (NULL, UNIX_TIMESTAMP(), '%d', '%s')",
					type,
					buffer
				);
				mysql_query(buffer);

				Bank_Clear(playerid);
			}
			format(buffer, sizeof buffer,
			    "UPDATE `surv_groups` SET `cash` = `cash` + '%.2f' WHERE `uid` = '%d'",
				Group(victimid, Offer(victimid, offer_value)[ 1 ], group_uid)
			);
			mysql_query(buffer);
			
			Createitem(playerid, item_document, Player(playerid, player_uid), Offer(victimid, offer_value)[ 0 ], 0.0, LicName[ Offer(victimid, offer_value)[ 0 ] ][ lic_name ], 0);
			new n = Player(playerid, player_npc);
			if(n != INVALID_PLAYER_ID)
			{
		    	cmd_do(NPC(n, npc_playerid), "Dokument jest w trakcie tworzenia.");
		    	format(buffer, sizeof buffer, "Proszę, oto %s. Miłego dnia!", LicName[ Offer(victimid, offer_value)[ 0 ] ][ lic_name ]);
		 		OnPlayerText(NPC(n, npc_playerid), buffer);
		 		OnPlayerText(NPC(n, npc_playerid), ":)");
		 		Player(playerid, player_npc) = INVALID_PLAYER_ID;
			}
	    }
	    case offer_type_anim:
	    {
			SetPlayerToFacePlayer(playerid, victimid);

		    switch(Offer(victimid, offer_value)[ 0 ])
			{
			    default:
			    {
					ApplyAnimation(playerid, "GANGS", "hndshkaa", 4.0, 0, 0, 0, 0, 0);
					ApplyAnimation(victimid, "GANGS", "hndshkaa", 4.0, 0, 0, 0, 0, 0);
				}
			}
	    }
	    case offer_type_repair:
	    {
		 	if(Offer(victimid, offer_cash) + Offer(victimid, offer_value3) > Player(playerid, player_cash))
			{
				ShowInfo(playerid, red"Oferta została anulowana.\n\nNie posiadasz wystarczającej ilości gotówki.");
			    ShowInfo(victimid, red"Oferta została anulowana.\n\nTen gracz nie posiada wystarczającej ilości gotówki.");
				return 1;
			}
	        Repair(victimid, repair_cash) = Offer(victimid, offer_cash);
	        Repair(victimid, repair_time) = time_repair;
	        Repair(victimid, repair_type) = repair_repair;
	        Repair(victimid, repair_player) = playerid;
	        Repair(victimid, repair_value)[ 1 ] = Offer(playerid, offer_value)[ 1 ];
	        Repair(victimid, repair_value)[ 2 ] = Offer(playerid, offer_value)[ 0 ];
	        Repair(victimid, repair_value2) = Offer(victimid, offer_value3);

			if(!type)
	        	GivePlayerMoneyEx(playerid, 0 - (Offer(victimid, offer_cash) + Offer(victimid, offer_value3)), true);
			else
			{
				format(buffer, sizeof buffer,
					"UPDATE `surv_bank` SET `cash` = `cash` - '%.2f' WHERE `number` = '%d'",
					(Offer(victimid, offer_cash) + Offer(victimid, offer_value3)),
					type
				);
				mysql_query(buffer);

				new Float:stan;
				format(buffer, sizeof buffer,
					"SELECT `cash` FROM `surv_bank` WHERE `number` = '%d'",
					type
				);
				mysql_query(buffer);
				mysql_store_result();
				mysql_fetch_float(stan);
				mysql_free_result();
				if(Offer(playerid, offer_value)[ 1 ])
					format(buffer, sizeof buffer,
						"Naprawa pojazdu w %s za $%.2f. Stan: $%.2f",
						Group(victimid, Offer(victimid, offer_value)[ 1 ], group_name),
						(Offer(victimid, offer_cash) + Offer(victimid, offer_value3)),
						stan
					);
				else
				format(buffer, sizeof buffer,
					"Naprawa pojazdu za $%.2f. Stan: $%.2f",
					(Offer(victimid, offer_cash) + Offer(victimid, offer_value3)),
					stan
				);

				mysql_real_escape_string(buffer, buffer);

				format(buffer, sizeof buffer,
					"INSERT INTO `surv_bank_log` VALUE (NULL, UNIX_TIMESTAMP(), '%d', '%s')",
					type,
					buffer
				);
				mysql_query(buffer);

				Bank_Clear(playerid);
			}
	    	Chat::Output(playerid, CLR_GREEN, "Zaakceptowałeś oferte, teraz poczekaj, aż mechanik naprawi pojazd.");
			Chat::Output(victimid, CLR_GREEN, "Gracz zaakceptował naprawe auta, naprawiaj go do czasu zakończenia się odliczania.");
	    }
	    case offer_type_leczenie:
	    {
	        new gid = Player(victimid, player_duty);
	        if(!gid) return 1;
			format(buffer, sizeof buffer,
			    "UPDATE `surv_groups` SET `cash` = `cash` + '%.2f' WHERE `uid` = '%d'",
			    Offer(victimid, offer_cash),
				Group(victimid, gid, group_uid)
			);
			mysql_query(buffer);
			
	        GivePlayerMoneyEx(playerid, 0 - Offer(victimid, offer_cash), true);
	        GivePlayerHealthEx(playerid, 99.0);
	    	Chat::Output(playerid, CLR_GREEN, "Zaakceptowałeś oferte.");
			Chat::Output(victimid, CLR_GREEN, "Gracz zaakceptował leczenie.");
	    }
	    case offer_type_rp:
	    {
	        if(Offer(playerid, offer_value)[ 0 ])
	        {
				format(buffer, sizeof buffer,
				    "UPDATE `surv_groups` SET `cash` = `cash` + '%.2f' WHERE `uid` = '%d'",
				    Offer(victimid, offer_cash),
					Group(victimid, Offer(playerid, offer_value)[ 0 ], group_uid)
				);
				mysql_query(buffer);
	        }
	        else
	        {
	            GivePlayerMoneyEx(victimid, Offer(victimid, offer_cash), true);
	        }
			if(!type)
				GivePlayerMoneyEx(playerid, 0 - Offer(victimid, offer_cash), true);
			else
			{
				format(buffer, sizeof buffer,
					"UPDATE `surv_bank` SET `cash` = `cash` - '%.2f' WHERE `number` = '%d'",
					Offer(victimid, offer_cash),
					type
				);
				mysql_query(buffer);

				new Float:stan;
				format(buffer, sizeof buffer,
					"SELECT `cash` FROM `surv_bank` WHERE `number` = '%d'",
					type
				);
				mysql_query(buffer);
				mysql_store_result();
				mysql_fetch_float(stan);
				mysql_free_result();

				format(buffer, sizeof buffer,
					"Akcja RP z %s za $%.2f. Stan: $%.2f",
					Group(victimid, Offer(playerid, offer_value)[ 0 ], group_name),
					Offer(victimid, offer_cash),
					stan
				);
				mysql_real_escape_string(buffer, buffer);

				format(buffer, sizeof buffer,
					"INSERT INTO `surv_bank_log` VALUE (NULL, UNIX_TIMESTAMP(), '%d', '%s')",
					type,
					buffer
				);
				mysql_query(buffer);

				Bank_Clear(playerid);
			}
			Chat::Output(playerid, CLR_GREEN, "Zaakceptowałeś oferte.");
			Chat::Output(victimid, CLR_GREEN, "Gracz zaakceptował akcje RP.");
	    }
	    case offer_type_taxi:
	    {
	        Taxi(playerid, taxi_player) = victimid;
	        Taxi(playerid, taxi_price) = Offer(victimid, offer_cash);
	        Taxi(playerid, taxi_group) = Group(victimid, Offer(playerid, offer_value)[ 0 ], group_uid);
	        
	    	Chat::Output(playerid, CLR_GREEN, "Zaakceptowałeś oferte.");
			Chat::Output(victimid, CLR_GREEN, "Gracz zaakceptował przejazd.");
	    }
	    case offer_type_silownia:
	    {
	        new groupid = Offer(playerid, offer_value)[ 0 ];
			format(buffer, sizeof buffer,
			    "UPDATE `surv_groups` SET `cash` = `cash` + '%.2f' WHERE `uid` = '%d'",
			    floatsub(Offer(victimid, offer_cash), Setting(setting_gym)[ 0 ]),
				Group(victimid, groupid, group_uid)
			);
			mysql_query(buffer);

			if(!type)
				GivePlayerMoneyEx(playerid, 0 - Offer(victimid, offer_cash), true);
			else
			{
				format(buffer, sizeof buffer,
					"UPDATE `surv_bank` SET `cash` = `cash` - '%.2f' WHERE `number` = '%d'",
					Offer(victimid, offer_cash),
					type
				);
				mysql_query(buffer);

				new Float:stan;
				format(buffer, sizeof buffer,
					"SELECT `cash` FROM `surv_bank` WHERE `number` = '%d'",
					type
				);
				mysql_query(buffer);
				mysql_store_result();
				mysql_fetch_float(stan);
				mysql_free_result();

				format(buffer, sizeof buffer,
					"Trening silowy w %s za $%.2f. Stan: $%.2f",
					Group(victimid, Offer(playerid, offer_value)[ 0 ], group_name),
					Offer(victimid, offer_cash),
					stan
				);
				mysql_real_escape_string(buffer, buffer);

				format(buffer, sizeof buffer,
					"INSERT INTO `surv_bank_log` VALUE (NULL, UNIX_TIMESTAMP(), '%d', '%s')",
					type,
					buffer
				);
				mysql_query(buffer);

				Bank_Clear(playerid);
			}
	    	Chat::Output(playerid, CLR_GREEN, "Zaakceptowałeś oferte, ćwicz teraz.");
			Chat::Output(victimid, CLR_GREEN, "Gracz zaakceptował oferte.");

			format(buffer, sizeof buffer, "Karnet(%s)", Group(victimid, groupid, group_name));
			Createitem(playerid, item_karnet, Group(victimid, groupid, group_uid), 1200, 0.0, buffer, 0);
		}
	    case offer_type_walka:
	    {
			format(buffer, sizeof buffer,
			    "UPDATE `surv_groups` SET `cash` = `cash` + '%.2f' WHERE `uid` = '%d'",
			    floatsub(Offer(victimid, offer_cash), Setting(setting_gym)[ 1 ]),
				Group(victimid, Offer(playerid, offer_value)[ 0 ], group_uid)
			);
			mysql_query(buffer);

			if(!type)
				GivePlayerMoneyEx(playerid, 0 - Offer(victimid, offer_cash), true);
			else
			{
				format(buffer, sizeof buffer,
					"UPDATE `surv_bank` SET `cash` = `cash` - '%.2f' WHERE `number` = '%d'",
					Offer(victimid, offer_cash),
					type
				);
				mysql_query(buffer);

				new Float:stan;
				format(buffer, sizeof buffer,
					"SELECT `cash` FROM `surv_bank` WHERE `number` = '%d'",
					type
				);
				mysql_query(buffer);
				mysql_store_result();
				mysql_fetch_float(stan);
				mysql_free_result();

				format(buffer, sizeof buffer,
					"Nauka walki w %s za $%.2f. Stan: $%.2f",
					Group(victimid, Offer(playerid, offer_value)[ 0 ], group_name),
					Offer(victimid, offer_cash),
					stan
				);
				mysql_real_escape_string(buffer, buffer);

				format(buffer, sizeof buffer,
					"INSERT INTO `surv_bank_log` VALUE (NULL, UNIX_TIMESTAMP(), '%d', '%s')",
					type,
					buffer
				);
				mysql_query(buffer);

				Bank_Clear(playerid);
			}
	    	Chat::Output(playerid, CLR_GREEN, "Zaakceptowałeś oferte.");
			Chat::Output(victimid, CLR_GREEN, "Gracz zaakceptował oferte.");

			if(!(Player(playerid, player_option) & option_fight))
			    Player(playerid, player_option) += option_fight;
	        Player(playerid, player_fight) = Offer(playerid, offer_value)[ 1 ];
	        SetPlayerFightingStyle(playerid, FightData[ Player(playerid, player_fight) ][ fight_id ]);
	        
	        format(buffer, sizeof buffer,
	            "UPDATE `surv_players` SET `fight` = '%d' WHERE `uid` = '%d'",
	            Player(playerid, player_fight),
	            Player(playerid, player_uid)
			);
			mysql_query(buffer);
	    }
	    case offer_type_mandat:
	    {
			format(buffer, sizeof buffer,
			    "UPDATE `surv_groups` SET `cash` = `cash` + '%.2f' WHERE `uid` = '%d'",
			    Offer(victimid, offer_cash),
				Group(victimid, Offer(playerid, offer_value)[ 1 ], group_uid)
			);
			mysql_query(buffer);

			if(!type)
				GivePlayerMoneyEx(playerid, 0 - Offer(victimid, offer_cash), true);
			else
			{
				format(buffer, sizeof buffer,
					"UPDATE `surv_bank` SET `cash` = `cash` - '%.2f' WHERE `number` = '%d'",
					Offer(victimid, offer_cash),
					type
				);
				mysql_query(buffer);

				new Float:stan;
				format(buffer, sizeof buffer,
					"SELECT `cash` FROM `surv_bank` WHERE `number` = '%d'",
					type
				);
				mysql_query(buffer);
				mysql_store_result();
				mysql_fetch_float(stan);
				mysql_free_result();

				format(buffer, sizeof buffer,
					"Mandat dla %s za $%.2f. Stan: $%.2f",
					Group(victimid, Offer(playerid, offer_value)[ 1 ], group_name),
					Offer(victimid, offer_cash),
					stan
				);
				mysql_real_escape_string(buffer, buffer);

				format(buffer, sizeof buffer,
					"INSERT INTO `surv_bank_log` VALUE (NULL, UNIX_TIMESTAMP(), '%d', '%s')",
					type,
					buffer
				);
				mysql_query(buffer);

				Bank_Clear(playerid);
			}
			AddToKartoteka(victimid, pc_user_pd, pd_mandat, select_char, Player(playerid, player_uid), NickSamp(playerid), Offer(playerid, offer_value4), Offer(playerid, offer_value)[ 0 ], Offer(playerid, offer_cash));
			
			Player(playerid, player_pkt) += Offer(playerid, offer_value)[ 0 ];
			
			format(buffer, sizeof buffer,
			    "UPDATE `surv_players` SET `pkt` = `pkt` + '%d' WHERE `uid` = '%d'",
			    Offer(playerid, offer_value)[ 0 ],
			    Player(playerid, player_uid)
			);
			mysql_query(buffer);
			    
	    	Chat::Output(playerid, CLR_GREEN, "Zaakceptowałeś mandat. Punkty zostały przypisane do Twojej postaci.");
			Chat::Output(victimid, CLR_GREEN, "Gracz zaakceptował mandat.");
	    }
	    case offer_type_hol:
	    {
	        GivePlayerMoneyEx(playerid, 0 - Offer(victimid, offer_cash), true);
	        GivePlayerMoneyEx(victimid, Offer(victimid, offer_cash), true);

            AttachTrailerToVehicle(Offer(playerid, offer_value)[ 1 ], Offer(playerid, offer_value)[ 0 ]);
            
	    	Chat::Output(playerid, CLR_GREEN, "Zaakceptowałeś holowanie.");
			Chat::Output(victimid, CLR_GREEN, "Gracz zaakceptował holowanie.");
	    }
	    case offer_type_blokada:
	    {
	        new vehid = Offer(playerid, offer_value)[ 0 ];
	        new groupuid = Offer(playerid, offer_value)[ 1 ];

			format(buffer, sizeof buffer,
			    "UPDATE `surv_groups` SET `cash` = `cash` + '%.2f' WHERE `uid` = '%d'",
			    Offer(victimid, offer_cash),
				groupuid
			);
			mysql_query(buffer);
			
			format(buffer, sizeof buffer,
			    "UPDATE `surv_vehicles` SET `block` = '0.0', `block_reason` = 'NULL' WHERE `uid` = '%d'",
			    Vehicle(vehid, vehicle_uid)
			);
			mysql_query(buffer);
			
			Vehicle(vehid, vehicle_block) = 0.0;
			format(Vehicle(vehid, vehicle_block_reason), 64, "NULL");
			
	        GivePlayerMoneyEx(playerid, 0 - Offer(victimid, offer_cash), true);

	    	Chat::Output(playerid, CLR_GREEN, "Zaakceptowałeś zdjęcie blokady.");
			Chat::Output(victimid, CLR_GREEN, "Gracz zaakceptował zdjęcie blokady.");
	    }
	    case offer_type_tank:
	    {
	        new stationid = Offer(victimid, offer_value)[ 1 ];
	        new vehid = Offer(victimid, offer_value)[ 0 ];
	        
			if(Player(victimid, player_option) & option_me)
			{
		 		format(buffer, sizeof buffer, "* %s wkłada wąż do baku i tankuje pojazd %s.", NickName(victimid), Vehicle(vehid, vehicle_name));
				serwerme(victimid, buffer);
			}

			format(buffer, sizeof buffer, "Trwa tankowanie pojazdu: ~r~%s", Vehicle(vehid, vehicle_name));
			PlayerTextDrawSetString(victimid, Player(victimid, player_fuel_td)[ 0 ], buffer);

			PlayerTextDrawSetString(victimid, Player(victimid, player_fuel_td)[ 1 ], "0.00");
			PlayerTextDrawSetString(victimid, Player(victimid, player_fuel_td)[ 2 ], "0");

			format(buffer, sizeof buffer, "%.2f", Station(stationid, station_value));
			PlayerTextDrawSetString(victimid, Player(victimid, player_fuel_td)[ 3 ], buffer);

			TextDrawShowForPlayer(victimid, Setting(setting_fuel_td)[ 0 ]);
			TextDrawShowForPlayer(victimid, Setting(setting_fuel_td)[ 1 ]);
			TextDrawShowForPlayer(victimid, Setting(setting_fuel_td)[ 2 ]);
			TextDrawShowForPlayer(victimid, Setting(setting_fuel_td)[ 3 ]);
			TextDrawShowForPlayer(victimid, Setting(setting_fuel_td)[ 4 ]);
			TextDrawShowForPlayer(victimid, Setting(setting_fuel_td)[ 5 ]);
			TextDrawShowForPlayer(victimid, Setting(setting_fuel_td)[ 6 ]);
			TextDrawShowForPlayer(victimid, Setting(setting_fuel_td)[ 7 ]);
			PlayerTextDrawShow(victimid, Player(victimid, player_fuel_td)[ 0 ]); // Info
			PlayerTextDrawShow(victimid, Player(victimid, player_fuel_td)[ 1 ]); // Ilość
			PlayerTextDrawShow(victimid, Player(victimid, player_fuel_td)[ 2 ]); // Cena
			PlayerTextDrawShow(victimid, Player(victimid, player_fuel_td)[ 3 ]); // Cena za litr

			ApplyAnimation(victimid, "BD_FIRE", "wash_up", 4.1, 0, 0, 0, 1, 0);
			FreezePlayer(victimid);

		    SetPVarFloat(victimid, "fuel-step", floatdiv(Offer(victimid, offer_cash), Station(stationid, station_value)));
		    Player(victimid, player_fuel_timer) = SetTimerEx("Fuel_Timer", timer_time, false, "dddd", victimid, vehid, stationid, playerid);

	    	Chat::Output(playerid, CLR_GREEN, "Zaakceptowałeś tankowanie pojazdu.");
			Chat::Output(victimid, CLR_GREEN, "Gracz zaakceptował tankowanie pojazdu.");
	    }
	    case offer_type_hotdog:
	    {
	        Createitem(playerid, item_food, gettime() + 7200, 1, 10.0, "Hot Dog", 0);
	        
	        GivePlayerMoneyEx(playerid, 0 - Offer(victimid, offer_cash), true);
	        GivePlayerMoneyEx(victimid, Offer(victimid, offer_cash)/2, true);
	        
	    	Chat::Output(playerid, CLR_GREEN, "Zaakceptowałeś oferte.");
			Chat::Output(victimid, CLR_GREEN, "Gracz zaakceptował kupno hotdoga.");
	    }
	}
	return 1;
}

Cmd::Input->oferuj(playerid, params[]) return cmd_o(playerid, params);

Cmd::Input->o(playerid, params[])
{
	new type[64],
		varchar[126];
	if(sscanf(params, "s[64]S()[126]", type, varchar))
	{
	    new buffer[ 1024 ];
	    strcat(buffer, "Tip: /o(feruj) "kom2"[Type] [ID/Nick] [Parametr]\n\n"white"");
	    
	    if(IsPlayerInTypeGroup(playerid, group_type_pd)) strcat(buffer, "Grupa: mandat, blokada\n"); //
	    if(IsPlayerInTypeGroup(playerid, group_type_mc)) strcat(buffer, "Grupa: leczenie\n");//
	    if(IsPlayerInTypeGroup(playerid, group_type_gov)) strcat(buffer, "Grupa: dokument, lekcja, rejestracja\n");
	    if(IsPlayerInTypeGroup(playerid, group_type_fd)) strcat(buffer, "Grupa: leczenie\n");//
	    if(IsPlayerInTypeGroup(playerid, group_type_radio)) strcat(buffer, "Grupa: reklama, wywiad\n");
	    if(IsPlayerInTypeGroup(playerid, group_type_bank)) strcat(buffer, "Grupa: konto\n");
	    if(IsPlayerInTypeGroup(playerid, group_type_gastro)) strcat(buffer, "Grupa: /podaj\n");//
	    if(IsPlayerInTypeGroup(playerid, group_type_workshop)) strcat(buffer, "Grupa: naprawa, lakierowanie, paintjob\n");//
	    if(IsPlayerInTypeGroup(playerid, group_type_binco)) strcat(buffer, "Grupa: ubranie\n");
	    if(IsPlayerInTypeGroup(playerid, group_type_shop)) strcat(buffer, "Grupa: /podaj\n");//
	    if(IsPlayerInTypeGroup(playerid, group_type_build)) strcat(buffer, "Grupa: dom, wnetrze\n");
	    if(IsPlayerInTypeGroup(playerid, group_type_gym)) strcat(buffer, "Grupa: trening, sztukawalki\n");//
	    if(IsPlayerInTypeGroup(playerid, group_type_station)) strcat(buffer, "Grupa: tankowanie, kanister\n");
	    if(IsPlayerInTypeGroup(playerid, group_type_post)) strcat(buffer, "Grupa: wysylka\n");
		if(IsPlayerInTypeGroup(playerid, group_type_gang)) strcat(buffer, "Grupa: tatuaż\n");//
		if(IsPlayerInTypeGroup(playerid, group_type_mafia)) strcat(buffer, "Grupa: tatuaż\n");//
		if(IsPlayerInTypeGroup(playerid, group_type_taxi)) strcat(buffer, "Grupa: przejazd\n");//

		if(Player(playerid, player_job) == job_newspaper) strcat(buffer, "Praca: ulotka\n");//
		strcat(buffer, "\n"kom"Dla wszystkich: auto / holowanie / akcjarp");
		ShowInfo(playerid, buffer);
		return 1;
	}
	if(!strcmp(type, "pojazd", true) || !strcmp(type, "auto", true))
	{
	    new victimid,
			Float:cena,
			vehid = Player(playerid, player_veh);
			
   	    if(vehid == INVALID_VEHICLE_ID)
		   	return ShowCMD(playerid, "Nie jesteś w pojeździe.");
		if(Vehicle(vehid, vehicle_owner)[ 0 ] != vehicle_owner_player)
			return ShowCMD(playerid, "Ten pojazd jest przypisany do jakiejś grupy!");
	    if(Player(playerid, player_uid) != Vehicle(vehid, vehicle_owner)[ 1 ])
			return ShowCMD(playerid, "Nie jesteś właścicielem tego pojazdu!");
		if(Vehicle(vehid, vehicle_option) & option_nosell)
		    return ShowInfo(playerid, red"Ten pojazd ma już kilkadziesiąt dobrych lat - na pewno nikt go nie kupi.\nNadaje się jedynie do oddania na złomowisko.");
			
	    if(sscanf(varchar, "uf", victimid, cena))
			return ShowCMD(playerid, "Tip: /o(feruj) auto [ID/Nick] [Cena]");
		if(victimid == playerid)
		    return ShowCMD(playerid, "Nie możesz zaoferować czegoś sobie!");
		if(!IsPlayerConnected(victimid))
			return NoPlayer(playerid);
		if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
			return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");
        if(Offer(victimid, offer_active))
            return ShowInfo(playerid, OFFER_FALSE);
		if(cena < 0)
			return ShowCMD(playerid, "Kwota nie może być niższa od 0.");

		Offer(playerid, offer_type) 		= offer_type_vehicle;
		Offer(playerid, offer_player) 		= victimid;
		Offer(playerid, offer_value)[ 0 ] 	= Vehicle(vehid, vehicle_uid);
		Offer(playerid, offer_value)[ 1 ] 	= vehid;
		Offer(playerid, offer_cash)			= cena;
		Offer(playerid, offer_active)       = true;

		Offer(victimid, offer_type) 		= offer_type_vehicle;
		Offer(victimid, offer_player) 		= playerid;
		Offer(victimid, offer_value)[ 0 ] 	= Vehicle(vehid, vehicle_uid);
		Offer(victimid, offer_value)[ 1 ] 	= vehid;
		Offer(victimid, offer_cash)			= cena;
		Offer(victimid, offer_active)       = true;
		ShowPlayerOffer(playerid, victimid);
	}
	else if(!strcmp(type, "rejestracja", true) || !strcmp(type, "rejestracje", true))
	{
		if(!IsPlayerInTypeGroup(playerid, group_type_gov))
		    return 1;
		    
		new doorid = GetPlayerDoor(playerid, false);
		if(!doorid)
			return ShowCMD(playerid, "Nie stoisz przy żadnych drzwiach!");

		if(CanPlayerProductSell(playerid, doorid) == -1)
		    return ShowCMD(playerid, "Te drzwi nie należą do Ciebie!");

		new victimid;
	    if(sscanf(varchar, "u", victimid))
			return ShowCMD(playerid, "Tip: /o(feruj) rejestracja [ID/Nick]");
		if(!IsPlayerConnected(victimid))
			return NoPlayer(playerid);
		if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
			return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");
		if(victimid == playerid)
		    return ShowCMD(playerid, "Nie możesz zaoferować czegoś sobie!");
        if(Offer(victimid, offer_active))
            return ShowInfo(playerid, OFFER_FALSE);

        Offer(playerid, offer_type) 		= offer_type_plate;
		Offer(playerid, offer_player) 		= victimid;
		Offer(playerid, offer_cash)        	= 300.0;

        Offer(victimid, offer_type) 		= offer_type_plate;
		Offer(victimid, offer_player) 		= playerid;
		Offer(victimid, offer_cash)        	= 300.0;

		new buffer[ 512 ],
			string[ 160 ];
			
		// Pojazdy gracza
		format(string, sizeof string,
			"SELECT `uid`, `model`, `name` FROM `surv_vehicles` WHERE `ownerType` = "#vehicle_owner_player" AND `owner` = '%d' AND `plate` LIKE 'Brak' AND `spawned` = '0'",
			Player(victimid, player_uid)
		);
	    mysql_query(string);
	    mysql_store_result();
		while(mysql_fetch_row(string))
		{
			static uid,
				model,
				name[ 64 ];
			sscanf(string, "p<|>dds[64]",
				uid,
				model,
				name
			);
			if(!(400 <= model <= 611)) continue;
			format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, uid, name);
		}
		mysql_free_result();
		
		// Pojazdy grupy
		for(new groupid = 1; groupid != MAX_GROUPS; groupid++)
		{
		    if(!Group(victimid, groupid, group_uid)) continue;
		    if(!(Group(victimid, groupid, group_can) & member_can_vehicle)) continue;

			format(string, sizeof string,
				"SELECT `uid`, `model`, `name` FROM `surv_vehicles` WHERE ownerType = "#vehicle_owner_group" AND owner = '%d' AND `plate` LIKE 'Brak' AND `spawned` = '0'",
				Group(victimid, groupid, group_uid)
			);
		    mysql_query(string);
		    mysql_store_result();
		    if(mysql_num_rows())
				format(buffer, sizeof buffer, "%s{%06x}------------[%s]------------\n", buffer, Group(victimid, groupid, group_color) >>> 8, Group(victimid, groupid, group_name));
			while(mysql_fetch_row(string))
			{
				static uid,
					model,
					name[ 64 ];
				sscanf(string, "p<|>dd",
					uid,
					model,
					name
				);
				if(!(400 <= model <= 611)) continue;
				format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, uid, name);
			}
			mysql_free_result();
		}
		
		if(isnull(buffer))
			ShowInfo(playerid, red"Gracz nie posiada niezarejestrowanego pojazdu!");
		else Dialog::Output(victimid, 80, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
	}
	else if(!strcmp(type, "ulotka", true))
	{
	    if(Player(playerid, player_job) != job_newspaper)
	        return 1;
	        
	    new victimid;
	    if(sscanf(varchar, "u", victimid))
			return ShowCMD(playerid, "Tip: /o(feruj) ulotka [ID/Nick]");
		if(!IsPlayerConnected(victimid))
			return NoPlayer(playerid);
		if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
			return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");
        if(Offer(victimid, offer_active))
            return ShowInfo(playerid, OFFER_FALSE);
		if(victimid == playerid)
		    return ShowCMD(playerid, "Nie możesz zaoferować czegoś sobie!");
	//	if(!Player(playerid, player_ulotki))
	//		return ShowInfo(playerid, red"Nie masz już ulotek! Uzupełnij zapasy w siedzibie radia.");
            
 		Offer(playerid, offer_type) 		= offer_type_ulotka;
		Offer(playerid, offer_player) 		= victimid;
		Offer(playerid, offer_active)       = true;

		Offer(victimid, offer_type) 		= offer_type_ulotka;
		Offer(victimid, offer_player) 		= playerid;
		Offer(victimid, offer_active)       = true;
		ShowPlayerOffer(playerid, victimid);
	}
	else if(!strcmp(type, "lakierowanie", true) || !strcmp(type, "malowanie", true))
	{
		new doorid = GetPlayerDoor(playerid, false),
			groupid;
		if(!doorid)
			return ShowInfo(playerid, red"Nie stoisz przy żadnych drzwiach!");
		if(Door(doorid, door_owner)[ 0 ] == door_type_group)
		{
	    	groupid = IsPlayerInUidGroup(playerid, Door(doorid, door_owner)[ 1 ]);
	    	if(!groupid)
	    	    return ShowInfo(playerid, red"Nie możesz użyć tej komendy tutaj.");
			if(Group(playerid, groupid, group_type) != group_type_workshop)
			    return 1;
		}
		else return ShowInfo(playerid, red"Nie jesteś w warsztacie.");
	    new victimid,
			color[ 2 ],
			Float:price;
			
	    if(sscanf(varchar, "ua<d>[2]f", victimid, color, price))
			return ShowCMD(playerid, "Tip: /o(feruj) "kom2"malowanie [ID/Nick] [Color1] [Color2] [Robocizna]");
		if(!IsPlayerConnected(victimid))
			return NoPlayer(playerid);
		if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
			return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");
        if(Offer(victimid, offer_active))
            return ShowInfo(playerid, OFFER_FALSE);
		if(!(0 <= color[ 0 ] <= 255) || !(0 <= color[ 1 ] <= 255))
			return ShowCMD(playerid, "Zakres kolorów pojazdu od 0 do 255");
		if(Weapon(playerid, Player(playerid, player_used_weapon), weapon_model) != 41)
			return ShowCMD(playerid, "Musisz wyciągnąć spray.");
		if(victimid == playerid)
		    return ShowCMD(playerid, "Nie możesz zaoferować czegoś sobie!");

		new vehid = Player(victimid, player_veh);
   	    if(vehid == INVALID_VEHICLE_ID)
		   	return ShowCMD(playerid, "Nie jesteś w pojeździe.");
		if(Vehicle(vehid, vehicle_owner)[ 0 ] != vehicle_owner_player)
			return ShowCMD(playerid, "Ten pojazd jest przypisany do jakiejś grupy!");
	    if(Player(victimid, player_uid) != Vehicle(vehid, vehicle_owner)[ 1 ])
			return ShowCMD(playerid, "Gracz nie jest właścicielem tego pojazdu!");
		if(price < 0)
			return ShowCMD(playerid, "Kwota nie może być niższa od 0.");

		Offer(playerid, offer_type) 		= offer_type_spray;
		Offer(playerid, offer_player) 		= victimid;
		Offer(playerid, offer_value)[ 0 ] 	= color[ 0 ];
		Offer(playerid, offer_value)[ 1 ] 	= color[ 1 ];
		Offer(playerid, offer_cash)			= price;
		Offer(playerid, offer_active)       = true;

		Offer(victimid, offer_type) 		= offer_type_spray;
		Offer(victimid, offer_player) 		= playerid;
		Offer(victimid, offer_value)[ 0 ] 	= color[ 0 ];
		Offer(victimid, offer_value)[ 1 ] 	= color[ 1 ];
		Offer(victimid, offer_cash)			= price;
		Offer(victimid, offer_active)       = true;
		ShowPlayerOffer(playerid, victimid);
	}
	else if(!strcmp(type, "pj", true) || !strcmp(type, "paintjob", true))
	{
		new doorid = GetPlayerDoor(playerid, false),
			groupid;
		if(!doorid)
			return ShowInfo(playerid, red"Nie stoisz przy żadnych drzwiach!");
		if(Door(doorid, door_owner)[ 0 ] == door_type_group)
		{
	    	groupid = IsPlayerInUidGroup(playerid, Door(doorid, door_owner)[ 1 ]);
	    	if(!groupid)
	    	    return ShowInfo(playerid, red"Nie możesz użyć tej komendy tutaj.");
			if(Group(playerid, groupid, group_type) != group_type_workshop)
			    return 1;
		}
		else return ShowInfo(playerid, red"Nie jesteś w warsztacie.");

	    new victimid,
			color,
			Float:price;

	    if(sscanf(varchar, "udf", victimid, color, price))
			return ShowCMD(playerid, "Tip: /o(feruj) paintjob [ID/Nick] [Color] [Robocizna] | Kolor 3 - usuwa paintjob.");
		if(!IsPlayerConnected(victimid))
			return NoPlayer(playerid);
		if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
			return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");
        if(Offer(victimid, offer_active))
            return ShowInfo(playerid, OFFER_FALSE);
		if(!(0 <= color <= 4))
			return ShowCMD(playerid, "Zakres kolorów pojazdu od 0 do 4");
		if(Weapon(playerid, Player(playerid, player_used_weapon), weapon_model) != 41)
			return ShowCMD(playerid, "Musisz wyciągnąć spray.");
		if(victimid == playerid)
		    return ShowCMD(playerid, "Nie możesz zaoferować czegoś sobie!");

		new vehid = Player(victimid, player_veh);
   	    if(vehid == INVALID_VEHICLE_ID)
		   	return ShowCMD(playerid, "Nie jesteś w pojeździe.");
		if(Vehicle(vehid, vehicle_owner)[ 0 ] != vehicle_owner_player)
			return ShowCMD(playerid, "Ten pojazd jest przypisany do jakiejś grupy!");
	    if(Player(victimid, player_uid) != Vehicle(vehid, vehicle_owner)[ 1 ])
			return ShowCMD(playerid, "Gracz nie jest właścicielem tego pojazdu!");
		if(price < 0)
			return ShowCMD(playerid, "Kwota nie może być niższa od 0.");

		Offer(playerid, offer_type) 		= offer_type_spray;
		Offer(playerid, offer_player) 		= victimid;
		Offer(playerid, offer_value)[ 0 ] 	= color;
		Offer(playerid, offer_value)[ 1 ] 	= -1;
		Offer(playerid, offer_cash)			= price;
		Offer(playerid, offer_active)       = true;

		Offer(victimid, offer_type) 		= offer_type_spray;
		Offer(victimid, offer_player) 		= playerid;
		Offer(victimid, offer_value)[ 0 ] 	= color;
		Offer(victimid, offer_value)[ 1 ] 	= -1;
		Offer(victimid, offer_cash)			= price;
		Offer(victimid, offer_active)       = true;
		ShowPlayerOffer(playerid, victimid);
	}
	else if(!strcmp(type, "konto", true))
	{
		new doorid = GetPlayerDoor(playerid, false),
			groupid;
		if(!doorid)
			return ShowInfo(playerid, red"Nie stoisz przy żadnych drzwiach!");
		if(Door(doorid, door_owner)[ 0 ] == door_type_group)
		{
	    	groupid = IsPlayerInUidGroup(playerid, Door(doorid, door_owner)[ 1 ]);
	    	if(!groupid)
	    	    return ShowInfo(playerid, red"Nie możesz użyć tej komendy tutaj.");
			if(Group(playerid, groupid, group_type) != group_type_bank)
			    return 1;
		}
		else return ShowInfo(playerid, red"Nie jesteś w banku.");
		
	    new victimid;

	    if(sscanf(varchar, "u", victimid))
			return ShowCMD(playerid, "Tip: /o(feruj) konto [ID/Nick]");
		if(!IsPlayerConnected(victimid))
			return NoPlayer(playerid);
		if(victimid == playerid)
		    return ShowCMD(playerid, "Nie możesz zaoferować czegoś sobie!");
		if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
			return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");
        if(Offer(victimid, offer_active))
            return ShowInfo(playerid, OFFER_FALSE);
            
		new buffer[ 126 ];
		format(buffer, sizeof buffer,
		    "SELECT `v2` FROM `surv_groups` WHERE `uid` = '%d'",
		    Group(playerid, groupid, group_uid)
		);
		mysql_query(buffer);
		mysql_store_result();
		mysql_fetch_row(buffer);
		mysql_free_result();
		
        new numer = randomEx(1000000, 9999999),
			Float:price = floatstr(buffer);

		Offer(playerid, offer_type) 		= offer_type_konto;
		Offer(playerid, offer_player) 		= victimid;
		Offer(playerid, offer_value)[ 0 ] 	= numer;
		Offer(playerid, offer_value)[ 1 ] 	= groupid;
		Offer(playerid, offer_cash)			= price;
		Offer(playerid, offer_active)       = true;

		Offer(victimid, offer_type) 		= offer_type_konto;
		Offer(victimid, offer_player) 		= playerid;
		Offer(victimid, offer_value)[ 0 ] 	= numer;
		Offer(victimid, offer_value)[ 1 ] 	= groupid;
		Offer(victimid, offer_cash)			= price;
		Offer(victimid, offer_active)       = true;
		ShowPlayerOffer(playerid, victimid);
	}
	else if(!strcmp(type, "tatoo", true) || !strcmp(type, "tatuaż", true))
	{
	    new gang = IsPlayerInTypeGroup(playerid, group_type_gang);
	    if(!gang)
		    gang = IsPlayerInTypeGroup(playerid, group_type_mafia);
		if(!gang)
		    return ShowInfo(playerid, red"Nie jesteś w gangu lub mafii, nie możesz użyć tej komendy!");
		
	    new victimid,
			Float:price,
			tresc[ 32 ];
	    if(sscanf(varchar, "ufs[32]", victimid, price, tresc))
			return ShowCMD(playerid, "Tip: /o(feruj) "kom2"tatuaż [ID/Nick] [Kwota] [Treść(do 32 znaków)]");
		if(!IsPlayerConnected(victimid))
			return NoPlayer(playerid);
		if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
			return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");
		if(victimid == playerid)
		    return ShowCMD(playerid, "Nie możesz zaoferować czegoś sobie!");
        if(Offer(victimid, offer_active))
            return ShowInfo(playerid, OFFER_FALSE);
        if(!IsPlayerInUidGroup(victimid, Group(playerid, gang, group_uid)))
            return ShowCMD(playerid, "Gracz nie jest w Twojej grupie!");
		if(price < 0)
			return ShowCMD(playerid, "Kwota nie może być niższa od 0.");

		Offer(playerid, offer_type) 		= offer_type_tatoo;
		Offer(playerid, offer_player) 		= victimid;
		format(Offer(playerid, offer_value4), 32, tresc);
		Offer(playerid, offer_cash)			= price;
		Offer(playerid, offer_active)       = true;

		Offer(victimid, offer_type) 		= offer_type_tatoo;
		Offer(victimid, offer_player) 		= playerid;
		format(Offer(victimid, offer_value4), 32, tresc);
		Offer(victimid, offer_cash)			= price;
		Offer(victimid, offer_active)       = true;
		ShowPlayerOffer(playerid, victimid);
	}
	else if(!strcmp(type, "dokument", true))
	{
	    new duty = Player(playerid, player_duty);
	    if(!duty)
	        return ShowInfo(playerid, red"Nie jesteś na duty w żadnej grupie!");

		new doorid = GetPlayerDoor(playerid, false);
		if(!doorid)
			return ShowInfo(playerid, red"Nie stoisz przy żadnych drzwiach!");

		new groupid = CanPlayerProductSell(playerid, doorid);
		if(groupid == -1)
		    return ShowInfo(playerid, red"Te drzwi nie należą do Ciebie!");

		if(groupid != duty)
		    return 1;

	    new victimid;
	    if(sscanf(varchar, "u", victimid))
			return ShowCMD(playerid, "Tip: /o(feruj) dokument [ID/Nick]");
		if(!IsPlayerConnected(victimid))
			return NoPlayer(playerid);
		if(victimid == playerid)
		    return ShowCMD(playerid, "Nie możesz zaoferować czegoś sobie!");
		if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
			return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");
        if(Offer(victimid, offer_active))
            return ShowInfo(playerid, OFFER_FALSE);

		Offer(playerid, offer_type) 		= offer_type_doc;
		Offer(playerid, offer_player) 		= victimid;
		Offer(playerid, offer_value)[ 1 ] 	= groupid;

		Offer(victimid, offer_type) 		= offer_type_doc;
		Offer(victimid, offer_player) 		= playerid;
		Offer(victimid, offer_value)[ 1 ] 	= groupid;

        new buffer[ 256 ];
        for(new d; d != sizeof LicName; d++)
        {
            if(LicName[ d ][ lic_group ] != Group(playerid, groupid, group_type)) continue;
	    	format(buffer, sizeof buffer, "%s%d\t"green2"$"white"%.2f\t%s\n", buffer, d, LicName[ d ][ lic_price ], LicName[ d ][ lic_name ]);
		}
		if(isnull(buffer)) ShowInfo(playerid, red"Twoja grupa nie oferuje żadnych dokumentów!");
		else Dialog::Output(playerid, 134, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
	}
	else if(!strcmp(type, "tankowanie", true))
	{
		if(IsPlayerInAnyVehicle(playerid))
			return ShowCMD(playerid, "Wyjdź z wozu i stań przy baku.");
		if(GetPVarFloat(playerid, "fuel"))
		    return ShowCMD(playerid, "Tankujesz już jakiś pojazd!");
	    if(Player(playerid, player_job) != job_mechanic)
	        return 1;

		new stationid = IsPlayerInStation(playerid);
	    if(!stationid)
			return ShowCMD(playerid, "Nie jesteś na stacji benzynowej!");

	    new victimid,
			Float:price;
	    if(sscanf(varchar, "uf", victimid, price))
			return ShowCMD(playerid, "Tip: /o(feruj) tankowanie [ID/Nick] [Cena]");
		if(!IsPlayerConnected(victimid))
			return NoPlayer(playerid);
		if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
			return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");
        if(Offer(victimid, offer_active))
            return ShowInfo(playerid, OFFER_FALSE);
		if(victimid == playerid)
		    return ShowCMD(playerid, "Nie możesz zaoferować czegoś sobie!");
		if(price < 0)
			return ShowCMD(playerid, "Kwota nie może być niższa od "green2"$"white"0");
			
		if(Player(victimid, player_cash) < price)
		    return ShowCMD(playerid, "Gracz nie ma tyle gotówki!");

		new vehid = Player(victimid, player_veh);
		if(vehid == INVALID_VEHICLE_ID)
			return ShowCMD(playerid, "Gracz nie jest w żadnym pojeździe.");
			
		if(!Station(stationid, station_fuel))
		    return ShowCMD(playerid, "Dystrybutory są puste!");
		    
		new string[ 126 ];
		if(Station(stationid, station_owner)[ 0 ] == station_owner_group)
		{
		    format(string, sizeof string,
				"SELECT `v1` FROM `surv_groups` WHERE `uid` = '%d'",
		        Station(stationid, station_owner)[ 1 ]
			);
			mysql_query(string);
			mysql_store_result();
			mysql_fetch_float(Station(stationid, station_value));
			mysql_free_result();
		}
		else Station(stationid, station_value) = 2.0;
		
		Offer(playerid, offer_type) 		= offer_type_tank;
		Offer(playerid, offer_player) 		= victimid;
		Offer(playerid, offer_value)[ 0 ] 	= vehid;
		Offer(playerid, offer_value)[ 1 ] 	= stationid;
		Offer(playerid, offer_cash)			= price;
		Offer(playerid, offer_active)       = true;

		Offer(victimid, offer_type) 		= offer_type_tank;
		Offer(victimid, offer_player) 		= playerid;
		Offer(victimid, offer_value)[ 0 ] 	= vehid;
		Offer(victimid, offer_value)[ 1 ] 	= stationid;
		Offer(victimid, offer_cash)			= price;
		Offer(victimid, offer_active)       = true;
		ShowPlayerOffer(playerid, victimid);
	}
	else if(!strcmp(type, "naprawa", true) || !strcmp(type, "naprawe", true))
	{
	    new duty;
		if(Player(playerid, player_job) == job_mechanic && !Player(playerid, player_duty))
		{
		    if(!IsPlayerInStation(playerid))
				return ShowCMD(playerid, "Nie jesteś na stacji benzynowej!");
		}
		else
	    {
			duty = Player(playerid, player_duty);
			if(!duty)
				return ShowInfo(playerid, red"Nie jesteś na duty w żadnej grupie lub nie jesteś mechanikiem!");
			if(Group(playerid, duty, group_type) != group_type_workshop)
				return ShowInfo(playerid, red"Grupa w której jesteś na służbie jest złego typu.\n\n"white"Aby naprawić pojazd na stacji jako mechanik, musisz zejśc ze służby!");

			new doorid = GetPlayerDoor(playerid, false);
			if(!doorid)
				return ShowInfo(playerid, red"Nie stoisz przy żadnych drzwiach!");

			new groupid = CanPlayerProductSell(playerid, doorid);
			if(groupid == -1)
			    return ShowInfo(playerid, red"Te drzwi nie należą do Ciebie!");
		}
		new victimid,
		    Float:price;
	    if(sscanf(varchar, "uf", victimid, price))
			return ShowCMD(playerid, "Tip: /o(feruj) naprawa [ID/Nick] [Robocizna]");
		if(!IsPlayerConnected(victimid))
			return NoPlayer(playerid);
		if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
			return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");
		if(victimid == playerid)
			return ShowCMD(playerid, "Nie możesz sam sobie tego oferować.");
		if(price < 0)
			return ShowCMD(playerid, "Kwota nie może być niższa od 0.");
        if(Offer(victimid, offer_active))
            return ShowInfo(playerid, OFFER_FALSE);

		new vehid = Player(victimid, player_veh);
		if(vehid == INVALID_VEHICLE_ID) return ShowCMD(playerid, "Gracz nie jest w żadnym pojeździe.");

		Offer(playerid, offer_type) 		= offer_type_repair;
		Offer(playerid, offer_player) 		= victimid;
		Offer(playerid, offer_value)[ 0 ] 	= vehid;
		Offer(playerid, offer_value)[ 1 ] 	= duty;
		Offer(playerid, offer_value3)       = (Vehicle(vehid, vehicle_hp) - 1000 * (-1) * 0.75);
		Offer(playerid, offer_cash)			= price;
		Offer(playerid, offer_active)       = true;

		Offer(victimid, offer_type) 		= offer_type_repair;
		Offer(victimid, offer_player) 		= playerid;
		Offer(victimid, offer_value)[ 0 ] 	= vehid;
		Offer(victimid, offer_value)[ 1 ] 	= duty;
		Offer(victimid, offer_cash)			= price;
		Offer(victimid, offer_active)       = true;
		Offer(victimid, offer_value3)       = Offer(playerid, offer_value3);
		ShowPlayerOffer(playerid, victimid);
		return 1;
	}
	else if(!strcmp(type, "leczenie", true))
	{
	    new gid = Player(playerid, player_duty);
	    if(!gid)
	    	return ShowInfo(playerid, red"Nie jesteś na duty żadnej grupy!");
		if(!(Group(playerid, gid, group_type) == group_type_fd || Group(playerid, gid, group_type) == group_type_mc))
			return ShowInfo(playerid, red"Grupa w której jesteś na służbie jest złego typu.");

		new victimid,
			Float:price;
		if(sscanf(varchar, "uf", victimid, price))
			return ShowCMD(playerid, "Tip: /o leczenie [ID/Nick] [Cena]");
		if(!IsPlayerConnected(victimid))
			return NoPlayer(playerid);
		if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
			return SendClientMessage(playerid, SZARY, "Gracz nie znajduje się w pobliżu.");
		if(price < 0)
			return ShowCMD(playerid, "Kwota nie może być niższa od 0.");
        if(Offer(victimid, offer_active))
            return ShowInfo(playerid, OFFER_FALSE);

		Offer(playerid, offer_type) 		= offer_type_leczenie;
		Offer(playerid, offer_player) 		= victimid;
		Offer(playerid, offer_cash)			= price;
		Offer(playerid, offer_active)       = true;

		Offer(victimid, offer_type) 		= offer_type_leczenie;
		Offer(victimid, offer_player) 		= playerid;
		Offer(victimid, offer_cash)			= price;
		Offer(victimid, offer_active)       = true;
		ShowPlayerOffer(playerid, victimid);
	}
	else if(!strcmp(type, "rp", true) || !strcmp(type, "akcjarp", true))
	{
	    new duty = Player(playerid, player_duty);
		new victimid,
			Float:price,
			name[ 64 ];
		if(sscanf(varchar, "ufs[64]", victimid, price, name))
			return ShowCMD(playerid, "Tip: /o akcjarp [ID/Nick] [Cena] [Nazwa]");
		if(!IsPlayerConnected(victimid))
			return NoPlayer(playerid);
		if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
			return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");
		if(price < 0)
			return ShowCMD(playerid, "Kwota nie może być niższa od "green2"$"white"0");
        if(Offer(victimid, offer_active))
            return ShowInfo(playerid, OFFER_FALSE);

		Offer(playerid, offer_type) 		= offer_type_rp;
		Offer(playerid, offer_player) 		= victimid;
		Offer(playerid, offer_cash)			= price;
		Offer(playerid, offer_value)[ 0 ] 	= duty;
		Offer(playerid, offer_active)       = true;
		format(Offer(playerid, offer_value4), sizeof name, name);

		Offer(victimid, offer_type) 		= offer_type_rp;
		Offer(victimid, offer_player) 		= playerid;
		Offer(victimid, offer_cash)			= price;
		Offer(victimid, offer_value)[ 0 ] 	= duty;
		Offer(victimid, offer_active)       = true;
		format(Offer(victimid, offer_value4), sizeof name, name);

		ShowPlayerOffer(playerid, victimid);
	}
	else if(!strcmp(type, "przejazd", true) || !strcmp(type, "transport", true))
	{
	    new gid = Player(playerid, player_duty);
	    if(!gid)
	    	return ShowInfo(playerid, red"Nie jesteś na duty żadnej grupy!");
		if(Group(playerid, gid, group_type) != group_type_taxi)
			return ShowInfo(playerid, red"Grupa w której jesteś na służbie jest złego typu.");

		new vehid = Player(playerid, player_veh);
   	    if(vehid == INVALID_VEHICLE_ID)
		   	return ShowCMD(playerid, "Nie jesteś w pojeździe.");
		if(Vehicle(vehid, vehicle_owner)[ 0 ] != vehicle_owner_group)
			return ShowCMD(playerid, "Ten pojazd nie należy do Twojej grupy!");
		if(Vehicle(vehid, vehicle_owner)[ 1 ] != Group(playerid, gid, group_uid))
			return ShowCMD(playerid, "Ten pojazd nie należy do Twojej grupy!");

		new victimid,
			Float:price;
		if(sscanf(varchar, "uf", victimid, price))
			return ShowCMD(playerid, "Tip: /o transport [ID/Nick] [Kwota za KM]");
		if(!IsPlayerConnected(victimid))
			return NoPlayer(playerid);
		if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
			return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");
		if(price < 0)
			return ShowCMD(playerid, "Kwota nie może być niższa od "green2"$"white"0");
		if(price > 20)
			return ShowCMD(playerid, "Kwota nie może być wyższa, niż "green2"$"white"20");
        if(Offer(victimid, offer_active))
            return ShowInfo(playerid, OFFER_FALSE);

		Offer(playerid, offer_type) 		= offer_type_taxi;
		Offer(playerid, offer_player) 		= victimid;
		Offer(playerid, offer_cash)			= price;
		Offer(playerid, offer_value)[ 0 ] 	= gid;
		Offer(playerid, offer_active)       = true;

		Offer(victimid, offer_type) 		= offer_type_taxi;
		Offer(victimid, offer_player) 		= playerid;
		Offer(victimid, offer_cash)			= price;
		Offer(victimid, offer_value)[ 0 ] 	= gid;
		Offer(victimid, offer_active)       = true;

		ShowPlayerOffer(playerid, victimid);
	}
	else if(!strcmp(type, "trening", true))
	{
	    new gid = Player(playerid, player_duty);
	    if(!gid)
	    	return ShowInfo(playerid, red"Nie jesteś na duty żadnej grupy!");
		if(Group(playerid, gid, group_type) != group_type_gym)
			return 1;

		new doorid = GetPlayerDoor(playerid, false);
		if(!doorid)
			return ShowInfo(playerid, red"Nie stoisz przy żadnych drzwiach!");

		if(CanPlayerProductSell(playerid, doorid) == -1)
		    return ShowInfo(playerid, red"Te drzwi nie należą do Ciebie!");
		    
		new Float:min_price,
			string[ 126 ];
	    format(string, sizeof string,
			"SELECT `v1` FROM `surv_groups` WHERE `uid` = '%d'",
	        Group(playerid, gid, group_uid)
		);
		mysql_query(string);
		mysql_store_result();
		mysql_fetch_float(min_price);
		mysql_free_result();

		new victimid,
			Float:price;
		if(sscanf(varchar, "uf", victimid, price))
			return ShowCMD(playerid, "Tip: /o trening [ID/Nick] [Cena]");
		if(!IsPlayerConnected(victimid))
			return NoPlayer(playerid);
		if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
			return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");
		if(price < 0)
			return ShowCMD(playerid, "Kwota nie może być niższa od "green2"$"white"0");
		if(price < min_price)
		{
		    format(string, sizeof string,
				"Minimalna kwota za trening to: "green2"$"white"%.2f",
				min_price
			);
			ShowCMD(playerid, string);
		    return 1;
		}
		if(price < Setting(setting_gym)[ 0 ])
		{
		    format(string, sizeof string,
				"Minimalna kwota za trening to "green2"$"white"%.2f",
		    	Setting(setting_gym)[ 0 ]
			);
			ShowCMD(playerid, string);
		    return 1;
		}
		if(Offer(victimid, offer_active))
            return ShowInfo(playerid, OFFER_FALSE);

		Offer(playerid, offer_type) 		= offer_type_silownia;
		Offer(playerid, offer_player) 		= victimid;
		Offer(playerid, offer_cash)			= price;
		Offer(playerid, offer_value)[ 0 ] 	= gid;
		Offer(playerid, offer_active)       = true;

		Offer(victimid, offer_type) 		= offer_type_silownia;
		Offer(victimid, offer_player) 		= playerid;
		Offer(victimid, offer_cash)			= price;
		Offer(victimid, offer_value)[ 0 ] 	= gid;
		Offer(victimid, offer_active)       = true;

		ShowPlayerOffer(playerid, victimid);
	}
	else if(!strcmp(type, "sztukawalki", true) || !strcmp(type, "sztukewalki", true))
	{
	    new gid = Player(playerid, player_duty);
	    if(!gid)
	    	return ShowInfo(playerid, red"Nie jesteś na duty żadnej grupy!");
		if(Group(playerid, gid, group_type) != group_type_gym)
			return 1;

		new doorid = GetPlayerDoor(playerid, false);
		if(!doorid)
			return ShowInfo(playerid, red"Nie stoisz przy żadnych drzwiach!");

		if(CanPlayerProductSell(playerid, doorid) == -1)
		    return ShowInfo(playerid, red"Te drzwi nie należą do Ciebie!");

		new Float:min_price,
			string[ 126 ];
	    format(string, sizeof string,
			"SELECT `v2` FROM `surv_groups` WHERE `uid` = '%d'",
	        Group(playerid, gid, group_uid)
		);
		mysql_query(string);
		mysql_store_result();
		mysql_fetch_float(min_price);
		mysql_free_result();

		new victimid,
			Float:price,
			style;
		if(sscanf(varchar, "ufd", victimid, price, style))
		{
		    string = grey"Tip: /o sztukawalki [ID/Nick] [Cena] [Typ]\n\n"white"Typy:\n";
			for(new c = 1; c != sizeof FightData; c++)
			    format(string, sizeof string, "%s%d\t%s\n", string, c, FightData[ c ][ fight_name ]);
			ShowInfo(playerid, string);
			return 1;
		}
		if(!IsPlayerConnected(victimid))
			return NoPlayer(playerid);
		if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
			return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");
		if(price < 0)
			return ShowCMD(playerid, "Kwota nie może być niższa od "green2"$"white"0");
		if(price < min_price)
		{
		    format(string, sizeof string,
				"Minimalna kwota za sztuke walki to: "green2"$"white"%.2f",
				min_price
			);
			ShowCMD(playerid, string);
		    return 1;
		}
		if(price < Setting(setting_gym)[ 1 ])
		{
		    format(string, sizeof string,
				"Minimalna kwota za sztuke walki to "green2"$"white"%.2f",
		    	Setting(setting_gym)[ 1 ]
			);
			ShowCMD(playerid, string);
		    return 1;
		}
		if(!(0 < style <= sizeof FightData-1))
			return ShowCMD(playerid, "Nieprawidłowy typ!");
		if(Player(victimid, player_stamina) < 3050)
		    return ShowCMD(playerid, "Gracz nie ma wystarczającej ilości siły! Wymagana ilość: 3050j");
        if(Offer(victimid, offer_active))
            return ShowInfo(playerid, OFFER_FALSE);

		Offer(playerid, offer_type) 		= offer_type_walka;
		Offer(playerid, offer_player) 		= victimid;
		Offer(playerid, offer_cash)			= price;
		Offer(playerid, offer_value)[ 0 ] 	= gid;
		Offer(playerid, offer_value)[ 1 ] 	= style;
		Offer(playerid, offer_active)       = true;

		Offer(victimid, offer_type) 		= offer_type_walka;
		Offer(victimid, offer_player) 		= playerid;
		Offer(victimid, offer_cash)			= price;
		Offer(victimid, offer_value)[ 0 ] 	= gid;
		Offer(victimid, offer_value)[ 1 ] 	= style;
		Offer(victimid, offer_active)       = true;

		ShowPlayerOffer(playerid, victimid);
	}
	else if(!strcmp(type, "mandat", true))
	{
	    new gid = Player(playerid, player_duty);
	    if(!gid)
	    	return ShowInfo(playerid, red"Nie jesteś na duty żadnej grupy!");
		if(Group(playerid, gid, group_type) != group_type_pd)
			return 1;
			
		new victimid,
		    pkt,
		    Float:price,
			reason[ 32 ];
		if(sscanf(varchar, "udfs[32]", victimid, pkt, price, reason))
			return ShowCMD(playerid, "Tip: /o mandat [ID/Nick] [Punkty] [Cena] [Powód]");
		if(!IsPlayerConnected(victimid))
			return NoPlayer(playerid);
		if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
			return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");
		if(price < 0)
			return ShowCMD(playerid, "Kwota nie może być niższa od "green2"$"white"0");
        if(Offer(victimid, offer_active))
            return ShowInfo(playerid, OFFER_FALSE);

		Offer(playerid, offer_type) 		= offer_type_mandat;
		Offer(playerid, offer_player) 		= victimid;
		Offer(playerid, offer_cash)			= price;
		Offer(playerid, offer_value)[ 0 ] 	= pkt;
		Offer(playerid, offer_value)[ 1 ] 	= gid;
		format(Offer(playerid, offer_value4), sizeof reason, reason);
		Offer(playerid, offer_active)       = true;

		Offer(victimid, offer_type) 		= offer_type_mandat;
		Offer(victimid, offer_player) 		= playerid;
		Offer(victimid, offer_cash)			= price;
		Offer(victimid, offer_value)[ 0 ] 	= pkt;
		Offer(victimid, offer_value)[ 1 ] 	= gid;
		format(Offer(victimid, offer_value4), sizeof reason, reason);
		Offer(victimid, offer_active)       = true;
		
		ShowPlayerOffer(playerid, victimid);
	}
	else if(!strcmp(type, "holowanie", true))
	{
	    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
	        return ShowCMD(playerid, "Musisz być kierowcą, aby użyć tej komendy!");

	    if(!HavePlayerItem(playerid, item_hol))
	        return ShowCMD(playerid, "Nie masz linki holowniczej!");

		new vehid = Player(playerid, player_veh);
   	    if(vehid == INVALID_VEHICLE_ID)
		   	return ShowCMD(playerid, "Nie jesteś w pojeździe.");

		new victimid,
		    Float:price;
		if(sscanf(varchar, "uf", victimid, price))
			return ShowCMD(playerid, "Tip: /o holowanie [ID/Nick] [Cena]");
		if(!IsPlayerConnected(victimid))
			return NoPlayer(playerid);
		if(!OdlegloscMiedzyGraczami(30.0, playerid, victimid))
			return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");
		if(price < 0)
			return ShowCMD(playerid, "Kwota nie może być niższa od "green2"$"white"0");
        if(Offer(victimid, offer_active))
            return ShowInfo(playerid, OFFER_FALSE);
	    if(GetPlayerState(victimid) == PLAYER_STATE_DRIVER)
	        return ShowCMD(playerid, "Gracz musi siedzieć jako pasażer.");

		new poj = Player(victimid, player_veh);
   	    if(poj == INVALID_VEHICLE_ID)
		   	return ShowCMD(playerid, "Gracz nie jest w pojeździe.");

        if(!IsVehicleStreamedIn(poj, playerid))
            return 1;

    	new Float:katH;
		new Float:katP;
		GetVehicleZAngle(vehid, katH); // holownik
		GetVehicleZAngle(poj, katP); // pojazd holowany
		if(AngleDifference(katH, katP) > 20.0) // jeśli nie stoją do siebie prostopadle, lub chociaż mniej więcej prostopadle, czyli ta różnica 20 stopni
			return ShowCMD(playerid, "Pojazdy nie stoją do siebie prostopadle!");
			
		new Float:hpos[2], Float:ppos[2];
		GetVehiclePos(vehid, hpos[0], hpos[1], katH); // holownik
		GetVehiclePos(poj, ppos[0], ppos[1], katH); // pojazd holowany
		katH = floatsqroot(floatpower(hpos[1] - ppos[1], 2) + floatpower(hpos[0] - ppos[0], 2)); // obliczanie odległości miedzy pojazdami z Pitagorasa
		if(katH > 10.0) // jeśli są zbyt daleko od siebie
			return ShowCMD(playerid, "Pojazdy są zbyt daleko siebie!");

		ppos[0] += (katH * floatsin(-katP, degrees));
		ppos[1] += (katH * floatcos(-katP, degrees));
		if(floatsqroot(floatpower(hpos[1] - ppos[1], 2) + floatpower(hpos[0] - ppos[0], 2)) > 3.0)
			return 1;

		Offer(playerid, offer_type) 		= offer_type_hol;
		Offer(playerid, offer_player) 		= victimid;
		Offer(playerid, offer_cash)			= price;
		Offer(playerid, offer_value)[ 0 ] 	= vehid;
		Offer(playerid, offer_value)[ 1 ] 	= poj;
		Offer(playerid, offer_active)       = true;

		Offer(victimid, offer_type) 		= offer_type_hol;
		Offer(victimid, offer_player) 		= playerid;
		Offer(victimid, offer_cash)			= price;
		Offer(victimid, offer_value)[ 0 ] 	= vehid;
		Offer(victimid, offer_value)[ 1 ] 	= poj;
		Offer(victimid, offer_active)       = true;

		ShowPlayerOffer(playerid, victimid);
	}
	else if(!strcmp(type, "blokada", true))
	{
	    new gid = Player(playerid, player_duty);
	    if(!gid)
	    	return ShowInfo(playerid, red"Nie jesteś na duty żadnej grupy!");
		if(Group(playerid, gid, group_type) != group_type_pd)
			return 1;

		new victimid;
		if(sscanf(varchar, "u", victimid))
			return ShowCMD(playerid, "Tip: /o blokada [ID/Nick]");
		if(!IsPlayerConnected(victimid))
			return NoPlayer(playerid);
		if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
			return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");
        if(Offer(victimid, offer_active))
            return ShowInfo(playerid, OFFER_FALSE);

		new vehid = Player(victimid, player_veh);
   	    if(vehid == INVALID_VEHICLE_ID)
		   	return ShowCMD(playerid, "Gracz nie jest w pojeździe.");
		   	
		if(!Vehicle(vehid, vehicle_block))
		    return ShowCMD(playerid, "Na pojazd nie jest nałożona blokada na koło.");

		Offer(playerid, offer_type) 		= offer_type_blokada;
		Offer(playerid, offer_player) 		= victimid;
		Offer(playerid, offer_cash)			= Vehicle(vehid, vehicle_block);
		Offer(playerid, offer_value)[ 0 ] 	= vehid;
		Offer(playerid, offer_value)[ 1 ] 	= Group(playerid, gid, group_uid);
		Offer(playerid, offer_active)       = true;

		Offer(victimid, offer_type) 		= offer_type_blokada;
		Offer(victimid, offer_player) 		= playerid;
		Offer(victimid, offer_cash)			= Vehicle(vehid, vehicle_block);
		Offer(victimid, offer_value)[ 0 ] 	= vehid;
		Offer(victimid, offer_value)[ 1 ] 	= Group(playerid, gid, group_uid);
		Offer(victimid, offer_active)       = true;

		ShowPlayerOffer(playerid, victimid);
	}
	else cmd_oferuj(playerid, "");
	return 1;
}

Cmd::Input->cennik(playerid, params[])
{
	new doorid = GetPlayerDoor(playerid, false);
	if(!doorid)
		return ShowInfo(playerid, red"Nie stoisz przy żadnych drzwiach!");

	new groupid = CanPlayerProductSell(playerid, doorid);
	if(!(groupid != -1))
	    return ShowInfo(playerid, red"Te drzwi nie należą do Ciebie!");

	new victimid;
    if(sscanf(params, "u", victimid)) return ShowCMD(playerid, "Tip: /cennik [ID/Nick]");
	if(!IsPlayerConnected(victimid)) return NoPlayer(playerid);
	if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid)) return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");
//	if(victimid == playerid) return ShowCMD(playerid, "Nie możesz sam sobie tego oferować.");

    new buffer[ 512 ];
    for(new d; d != sizeof LicName; d++)
    {
        if(LicName[ d ][ lic_group ] != Group(playerid, groupid, group_type)) continue;
    	format(buffer, sizeof buffer, "%s%d\t"green2"$"white"%.2f\t%s\n", buffer, d, LicName[ d ][ lic_price ] + LicName[ d ][ lic_price_before ], LicName[ d ][ lic_name ]);
	}
	if(isnull(buffer)) ShowInfo(playerid, red"Twoja grupa nie oferuje żadnych dokumentów!");
	else ShowList(victimid, buffer);
	return 1;
}

Cmd::Input->yo(playerid, params[])
{
	new victimid, id;
	if(sscanf(params, "uD(1)", victimid, id))
		return ShowCMD(playerid, "Tip: /yo [ID/Nick] [typ]");
	if(victimid == INVALID_PLAYER_ID)
		return NoPlayer(playerid);
	if(victimid == playerid)
	    return ShowCMD(playerid, "Nie możesz zaoferować czegoś sobie!");
	if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
		return ShowInfo(playerid, red"Gracz nie znajduje się w pobliżu.");
	if(!IsPlayerFacingPlayer(playerid, victimid, 20))
		return ShowInfo(playerid, red"Nie patrzysz się w stronę tego gracza.");
    if(Offer(victimid, offer_active))
        return ShowInfo(playerid, OFFER_FALSE);

	Offer(playerid, offer_type) 		= offer_type_anim;
	Offer(playerid, offer_player) 		= victimid;
	Offer(playerid, offer_value)[ 1 ] 	= id;
	Offer(playerid, offer_active)       = true;

	Offer(victimid, offer_type) 		= offer_type_anim;
	Offer(victimid, offer_player) 		= playerid;
	Offer(victimid, offer_value)[ 1 ] 	= id;
	Offer(victimid, offer_active)       = true;

	ShowPlayerOffer(playerid, victimid);
	return 1;
}
