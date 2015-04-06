/* TODO:
 - Crafting | na koniec

*/
FuncPub::Items_OnPlayerText(playerid, text[])
{
	new str1[ 64 ],
		str2[ 128 ];
	if(sscanf(text, "s[64]S()[128]", str1, str2))
	    return 1;
	if(!strcmp(str1, "odloz", true) || !strcmp(str1, "odłóż", true))
	{
	    // odloz [itemID]
		new itemid = strval(str2);
		if(!itemid)
			return Chat::Output(playerid, SZARY, "odloz [ID na liście]");
		if(!(0 < itemid <= MAX_ITEMS))
			return Chat::Output(playerid, SZARY, "Błędne ID przedmiotu");
		if(!Item(playerid, itemid, item_uid))
			return Chat::Output(playerid, SZARY, "odloz [ID na liście] | Slot jest pusty.");

	    OnPlayerRemoveItem(playerid, itemid);
	}
	else if(!strcmp(str1, "daj", true) || !strcmp(str1, "d", true))
	{
	    // daj [playerID]
	    new victimid;
		if(sscanf(str2, "d", victimid))
		    return Chat::Output(playerid, SZARY, "daj [ID/Nick]");
		if(!IsPlayerConnected(victimid))
		    return Chat::Output(playerid, SZARY, "daj [ID/Nick] | Nie znaleziono gracza.");
		if(!Player(playerid, player_item_selected))
		    return Chat::Output(playerid, SZARY, "daj [ID/Nick] | Nie zaznaczyłeś żadnego przedmiotu. Użyj \"wybierz [ID na liście]\".");
		if(Offer(victimid, offer_active))
		    return Chat::Output(playerid, SZARY, "daj [ID/Nick] | Ktoś temu graczu coś oferuje!");
		if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
		    return Chat::Output(playerid, SZARY, "daj [ID/Nick] | Gracz nie jest w pobliżu!");
		if(playerid == victimid)
		    return Chat::Output(playerid, SZARY, "daj [ID/Nick] | Nie możesz sprzedać czegoś sobie!");

		Offer(playerid, offer_type) 		= offer_type_item;
		Offer(playerid, offer_player) 		= victimid;
		Offer(playerid, offer_active)       = true;
		
		Offer(victimid, offer_type) 		= offer_type_item;
		Offer(victimid, offer_player) 		= playerid;
		Offer(victimid, offer_active)       = true;

        ShowPlayerOffer(playerid, victimid);
	}
	else if(!strcmp(str1, "oferuj", true) || !strcmp(str1, "o", true))
	{
	    // oferuj [playerID] [Cena]
	    new victimid,
			Float:price;
		if(sscanf(str2, "df", victimid, price))
		    return Chat::Output(playerid, SZARY, "oferuj [ID/Nick] [Cena]");
		if(!IsPlayerConnected(victimid))
		    return Chat::Output(playerid, SZARY, "oferuj [ID/Nick] [Cena] | Nie znaleziono gracza.");
		if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
		    return Chat::Output(playerid, SZARY, "oferuj [ID/Nick] [Cena] | Gracz nie jest w pobliżu!");
		if(!Player(playerid, player_item_selected))
		    return Chat::Output(playerid, SZARY, "oferuj [ID/Nick] [Cena] | Nie zaznaczyłeś żadnego przedmiotu. Użyj \"wybierz [ID na liście]\".");
		if(Offer(victimid, offer_active))
		    return Chat::Output(playerid, SZARY, "oferuj [ID/Nick] [Cena] | Ktoś temu graczu coś oferuje!");
		if(playerid == victimid)
		    return Chat::Output(playerid, SZARY, "oferuj [ID/Nick] [Cena] | Nie możesz sprzedać czegoś sobie!");
		if(price <= 0)
		    return ShowCMD(playerid, "Kwota nie może być niższa od $0.");

		Offer(playerid, offer_type) 		= offer_type_item;
		Offer(playerid, offer_player) 		= victimid;
		Offer(playerid, offer_cash) 		= price;
		Offer(playerid, offer_active)       = true;

		Offer(victimid, offer_type) 		= offer_type_item;
		Offer(victimid, offer_player) 		= playerid;
		Offer(victimid, offer_cash) 		= price;
		Offer(victimid, offer_active)       = true;

        ShowPlayerOffer(playerid, victimid);
	}
	else if(!strcmp(str1, "info", true) || !strcmp(str1, "informacje", true))
	{
	    // info [itemID]
		new itemid = strval(str2);
		if(!itemid)
			return Chat::Output(playerid, SZARY, "wloz [ID na liście]");
		if(!(0 < itemid <= MAX_ITEMS))
			return Chat::Output(playerid, SZARY, "Błędne ID przedmiotu");

		ShowItemInfo(playerid, itemid);
	}
	else if(!strcmp(str1, "wloz", true) || !strcmp(str1, "włóż", true) || !strcmp(str1, "w", true))
	{
	    // wloz [itemID]
		new itemid = strval(str2);
		if(!itemid)
			return Chat::Output(playerid, SZARY, "wloz [ID na liście]");
		if(!(0 < itemid <= MAX_ITEMS))
			return Chat::Output(playerid, SZARY, "Błędne ID przedmiotu");
		if(!Player(playerid, player_item_selected))
		    return Chat::Output(playerid, SZARY, "wloz [ID na liście] | Nie zaznaczyłeś żadnego przedmiotu. Użyj \"wybierz [ID na liście]\".");
		if(Item(playerid, itemid, item_type) != item_pack)
		    return Chat::Output(playerid, SZARY, "wloz [ID na liście] | Ten przedmiot nie magazynuje innych.");

		OnPlayerPutInItem(playerid, Item(playerid, itemid, item_uid));
	}
/*	else if(!strcmp(str1, "nazwa", true) || !strcmp(str1, "n", true))
	{
	    // nazwa [itemID1] [Nazwa]
	    new itemid,
			nazwa[ MAX_ITEM_NAME ];
		if(sscanf(str2, "ds["#MAX_ITEM_NAME"]", itemid, nazwa))
		    return Chat::Output(playerid, SZARY, "nazwa [ID na liście] [Nowa nazwa]");
		if(!(0 < itemid <= MAX_ITEMS))
			return Chat::Output(playerid, SZARY, "Błędne ID przedmiotu");
		if(!Item(playerid, itemid, item_uid))
			return Chat::Output(playerid, SZARY, "nazwa [ID na liście] [Nowa nazwa] | Slot jest pusty.");
        if(!(3 <= strlen(nazwa)))
			return Chat::Output(playerid, SZARY, "nazwa [ID na liście] [Nowa nazwa] | Za krótka nazwa przedmiotu.");
        if(!(strlen(nazwa) <= MAX_ITEM_NAME))
			return Chat::Output(playerid, SZARY, "nazwa [ID na liście] [Nowa nazwa] | Za długa nazwa przedmiotu.");
        
		OnItemNameChange(playerid, itemid, nazwa);
	}*/
	else if(!strcmp(str1, "ulub", true) || !strcmp(str1, "ulubiony", true) || !strcmp(str1, "u", true))
	{
	    // ulub [itemID]
		new itemid = strval(str2);
		if(!itemid)
			return Chat::Output(playerid, SZARY, "ulub [ID na liście]");
		if(!(0 < itemid <= MAX_ITEMS))
			return Chat::Output(playerid, SZARY, "Błędne ID przedmiotu");
		if(!Item(playerid, itemid, item_uid))
			return Chat::Output(playerid, SZARY, "ulub [ID na liście] | Slot jest pusty");

		OnPlayerAddItemToFavorite(playerid, itemid);
	}
	else if(!strcmp(str1, "wybierz", true) || !strcmp(str1, "select", true) || !strcmp(str1, "w", true) || !strcmp(str1, "wyb", true) || !strcmp(str1, "z", true) || !strcmp(str1, "zaznacz", true) || !strcmp(str1, "zaz", true))
	{
		// wybierz [itemID]
		new itemid = strval(str2);
		if(!itemid)
			return Chat::Output(playerid, SZARY, "wybierz [ID na liście]");
		if(!(0 < itemid <= MAX_ITEMS))
			return Chat::Output(playerid, SZARY, "Błędne ID przedmiotu");
		if(!Item(playerid, itemid, item_uid))
			return Chat::Output(playerid, SZARY, "wybierz [ID na liście] | Slot jest pusty");

		OnPlayerSelectItem(playerid, itemid);
	}
	else if(!strcmp(str1, "craft", true) || !strcmp(str1, "craftuj", true))
	{
	    OnPlayerCraft(playerid);
	}
	else if(!strcmp(str1, ">", true))
	{
	    ShowPlayerItems(playerid, Player(playerid, player_item_site)+(MAX_ITEMS-1));
	}
	else if(!strcmp(str1, "<", true))
	{
	    ShowPlayerItems(playerid, Player(playerid, player_item_site)-(MAX_ITEMS-1));
	}
	else if(!strcmp(str1, "zniszcz", true))
	{
		new itemid = strval(str2);
		if(!itemid)
			return Chat::Output(playerid, SZARY, "odloz [ID na liście]");
		if(!(0 < itemid <= MAX_ITEMS))
			return Chat::Output(playerid, SZARY, "Błędne ID przedmiotu");
		if(!Item(playerid, itemid, item_uid))
			return Chat::Output(playerid, SZARY, "wybierz [ID na liście] | Slot jest pusty");
	    OnItemDestroy(playerid, itemid);
	}
	else if(!strcmp(str1, "pomoc", true) || !strcmp(str1, "help", true))
	{
	    ShowInfo(playerid, white"Tu będzie pomoc!");
	}
   	else
	{
		new itemid = strval(str1);
		if(!itemid)
		    return ShowInfo(playerid, red"Błędne ID przedmiotu");
		if(!(0 < itemid <= MAX_ITEMS))
			return ShowInfo(playerid, red"Błędne ID przedmiotu");
		if(!Item(playerid, itemid, item_uid))
			return ShowInfo(playerid, red"Błędne ID przedmiotu");
		OnPlayerUseItem(playerid, itemid, str2);
	}
	return 1;
}

FuncPub::ShowItemInfo(playerid, itemid)
{
	new buffer[ 1024 ], string[ 128 ];
    format(string, sizeof string,
        "SELECT `weight`, `last_used`, `created` FROM `surv_items` WHERE `uid` = '%d'",
        Item(playerid, itemid, item_uid)
	);
    mysql_query(string);
    mysql_store_result();
    mysql_fetch_row(string);
    mysql_free_result();

    new itm_weight,
        itm_lastused,
        itm_created[ 32 ],
		lastuseStr[ 32 ];

		// 1078|Camera|1|1|1|43|48|0|0|0|0|0|0|0|0|1390313934|2014-01-21 15:17:59
	sscanf(string, "p<|>dds[32]",
	    itm_weight,
	    itm_lastused,
	    itm_created
	);
	ReturnTimeAgo(itm_lastused, lastuseStr);

 	format(buffer, sizeof buffer, "Nazwa i UID przedmiotu:\t%s (%d)\n", Item(playerid, itemid, item_name), Item(playerid, itemid, item_uid));
	format(buffer, sizeof buffer, "%sWaga:\t\t\t\t%dg\n", buffer, itm_weight);
 	format(buffer, sizeof buffer, "%sTyp:\t\t\t\t%d (%s)\n", buffer, Item(playerid, itemid, item_type), ItemName[ Item(playerid, itemid, item_type) ]);
	format(buffer, sizeof buffer, "%sOst. użyty:\t\t\t%s\n", buffer, lastuseStr);
	format(buffer, sizeof buffer, "%sStworzony:\t\t\t%s\n", buffer, itm_created);
	strcat(buffer, grey"------------------------\n");
	switch(Item(playerid, itemid, item_type))
	{
	    case item_weapon, item_ammo:
	    {
	        new weaponname[ 32 ];
	        GetWeaponName(Item(playerid, itemid, item_value)[ 0 ], weaponname, sizeof weaponname);
			format(buffer, sizeof buffer, "%sModel broni:\t\t\t%d (%s)\n", buffer, Item(playerid, itemid, item_value)[ 0 ], weaponname);
			format(buffer, sizeof buffer, "%sIlość amunicji:\t\t\t%d\n", buffer, Item(playerid, itemid, item_value)[ 1 ]);
			if(Item(playerid, itemid, item_value3))
			{
				strcat(buffer, "Flagi:\n");
				if(floatval(Item(playerid, itemid, item_value3)) & weapon_flag_paral) strcat(buffer, "\t- Paralizator\n");
				if(floatval(Item(playerid, itemid, item_value3)) & weapon_flag_nodmg) strcat(buffer, "\t- Brak obrażeń\n");
			}
	    }
	    case item_phone:
	    {
			format(buffer, sizeof buffer, "%sNumer:\t\t\t\t%d\n", buffer, Item(playerid, itemid, item_value)[ 0 ]);
			format(buffer, sizeof buffer, "%sPowiadomień:\t\t\t%.0f\n", buffer, Item(playerid, itemid, item_value3));
	    }
	    case item_food:
	    {
	        new timestr[ 32 ];
	        new tx = Item(playerid, itemid, item_value)[ 0 ] - gettime();
	        if(tx > 0)
	        	ReturnTime(tx, timestr);
			else
			    timestr = "Przeterminowane";
	        format(buffer, sizeof buffer, "%sIlość:\t\t\t\t%d\n", buffer, Item(playerid, itemid, item_value)[ 1 ]);
	        format(buffer, sizeof buffer, "%sWażność:\t\t\t%s\n", buffer, timestr);
	        format(buffer, sizeof buffer, "%sIlość HP:\t\t\t%.2f\n", buffer, Item(playerid, itemid, item_value3));
	    }
	    case item_karta:
	    {
	        format(buffer, sizeof buffer, "%sNumer konta:\t\t\t%d\n", buffer, Item(playerid, itemid, item_value)[ 0 ]);
	        format(buffer, sizeof buffer, "%sZablokowana:\t\t\t%s\n", buffer, YesOrNo(bool:Item(playerid, itemid, item_value)[ 1 ]));
	        format(buffer, sizeof buffer, "%sPayPass:\t\t\t%s\n", buffer, YesOrNo(bool:Item(playerid, itemid, item_value3)));

	    }
	    case item_cloth:
	    {
	        format(buffer, sizeof buffer, "%sSkin:\t\t\t\t%d\n", buffer, Item(playerid, itemid, item_value)[ 0 ]);
	    }
	    case item_drink:
	    {
	        format(buffer, sizeof buffer, "%sIlość:\t\t\t\t%d\n", buffer, Item(playerid, itemid, item_value)[ 0 ]);
	        format(buffer, sizeof buffer, "%sIlość HP:\t\t\t%.2f\n", buffer, Item(playerid, itemid, item_value3));
	    }
	    default:
	    {
			if(Item(playerid, itemid, item_value)[ 0 ]) format(buffer, sizeof buffer, "%sWartość 1:\t\t\t%d\n", buffer, Item(playerid, itemid, item_value)[ 0 ]);
			if(Item(playerid, itemid, item_value)[ 1 ]) format(buffer, sizeof buffer, "%sWartość 2:\t\t\t%d\n", buffer, Item(playerid, itemid, item_value)[ 1 ]);
			if(Item(playerid, itemid, item_value3)) format(buffer, sizeof buffer, "%sWartość 3:\t\t\t%.2f\n", buffer, Item(playerid, itemid, item_value3));
	    }
	}
	ShowList(playerid, buffer);
	return 1;
}

FuncPub::OnPlayerUseItem(playerid, itemid, textuse[])
{
    if(Player(playerid, player_aj) || Player(playerid, player_jail))
        return ShowInfo(playerid, TEXT_AJ);
    if(!HavePlayerItemUID(playerid, Item(playerid, itemid, item_uid)))
    {
		if(IsPlayerVisibleItems(playerid))
		    ShowPlayerItems(playerid, Player(playerid, player_item_site));
        ShowInfo(playerid, red"Ten przedmiot został skasowany lub nie należy do Ciebie.");
        return 1;
    }
	if(Item(playerid, itemid, item_used) == 2)
        return ShowInfo(playerid, red"Nie możesz używać zaznaczonego przedmiotu.");

	new stringex[ 126 ];
	format(stringex, sizeof stringex,
		"INSERT INTO `surv_odciski` VALUES (NULL, '%d', UNIX_TIMESTAMP(), '"#odcisk_type_item"', '%d', '%d')",
		Player(playerid, player_uid),
		Item(playerid, itemid, item_uid),
		_:Player(playerid, player_rekawiczki)
	);
	mysql_query(stringex);

	new bool:showed = true;
	switch(Item(playerid, itemid, item_type))
	{
		case item_weapon:
		{
		    if(Item(playerid, itemid, item_used) == 1)
		    {
//		        if(Player(playerid, player_weapon)[ 1 ] != Item(playerid, itemid, item_uid) || Player(playerid, player_weapon2)[ 1 ] != Item(playerid, itemid, item_uid))
//		            return 1;
		            
				new ammo;
			    if(Item(playerid, itemid, item_value)[ 0 ] == Weapon(playerid, 0, weapon_model) && Item(playerid, itemid, item_value)[ 0 ] == Weapon(playerid, 1, weapon_model))
			    {
					ammo = GetWeaponAmmo(playerid, Weapon(playerid, 0, weapon_model));
				    new tammo = ammo;
					ammo = ammo/2 + ammo % 2;

				    new skillid;
				    if(Item(playerid, itemid, item_value)[ 0 ] == WEAPON_COLT45)
						skillid = WEAPONSKILL_PISTOL;
				    if(Item(playerid, itemid, item_value)[ 0 ] == WEAPON_UZI)
						skillid = WEAPONSKILL_MICRO_UZI;
					SetPlayerSkillLevel(playerid, skillid, 0);

			        SetPlayerAmmo(playerid, Item(playerid, itemid, item_value)[ 0 ], tammo-ammo);
//                    RemovePlayerWeapon(playerid, Item(playerid, itemid, item_value)[ 0 ]);

			        ClearWeapon(playerid, 1);
			        Weapon(playerid, 0, weapon_ammo) -= ammo;
		        }
		        else
		        {
					new x;
		            for(; x != MAX_WEAPON; x++)
		            {
		                if(Item(playerid, itemid, item_value)[ 0 ] == Weapon(playerid, x, weapon_model))
		                    break;
		            }
		            if(x == MAX_WEAPON) return 1;
		            ammo = GetWeaponAmmo(playerid, Weapon(playerid, x, weapon_model));
//		            SetWeaponAmmo(playerid, Item(playerid, itemid, item_value)[ 0 ], 0);
                    RemovePlayerWeapon(playerid, Item(playerid, itemid, item_value)[ 0 ]);

					ClearWeapon(playerid, x);
		       	 	if(IsPlayerAttachedObjectSlotUsed(playerid, x))
		       	 		RemovePlayerAttachedObject(playerid, x);
		        }

				new string[ 126 ];
		        format(string, sizeof string, "UPDATE `surv_items` SET `used` = 0, `v2` = '%d' WHERE `uid` = '%d'", ammo, Item(playerid, itemid, item_uid));
				mysql_query(string);
				
				Player(playerid, player_disabled) = true;
				SetTimerEx("AntyCheat_Enable", 1000, false, "d", playerid);

	            if(Player(playerid, player_option) & option_me)
				{
				    string[ 0 ] = EOS;
				    if(textuse[ 0 ]) format(string, sizeof string, " %s", textuse);
					format(string, sizeof string, "* %s schował broń %s%s.", NickName(playerid), Item(playerid, itemid, item_name), string);
					serwerme(playerid, string);
				}
			}
		    else
		    {
		        if(Player(playerid, player_block) & block_nogun)
		            return ShowInfo(playerid, TEXT_BRON);
		            
		        if(Weapon(playerid, 1, weapon_model) && Weapon(playerid, 0, weapon_model))
		           	return ShowInfo(playerid, red"Używasz już jakiejś broni!");
				
				if(!Item(playerid, itemid, item_value)[ 1 ] && Weapon(playerid, 0, weapon_model) != Item(playerid, itemid, item_value)[ 0 ])
					return GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~w~Ten przedmiot nie posiada amunicji!", 2000, 3);

				
                //if(Player(playerid, player_weapon)[ 0 ] && Player(playerid, player_weapon)[ 1 ])
                if(Weapon(playerid, 0, weapon_model) && !Weapon(playerid, 1, weapon_model))
                {
                    if(Weapon(playerid, 0, weapon_model) == Item(playerid, itemid, item_value)[ 0 ])
                    {
	                    if(!(Item(playerid, itemid, item_value)[ 0 ] == WEAPON_COLT45 || Item(playerid, itemid, item_value)[ 0 ] == WEAPON_UZI))
	                        return ShowInfo(playerid, red"Tych broni nie możesz używać razem!");

						if(Weapon(playerid, 0, weapon_flag) & weapon_flag_paral)
						    return ShowInfo(playerid, red"Tej broni nie możesz łączyć z inną!");

	                    new ammo = GetWeaponAmmo(playerid, Weapon(playerid, 0, weapon_model));
					    new skillid;

					    if(Item(playerid, itemid, item_value)[ 0 ] == WEAPON_COLT45)
							skillid = WEAPONSKILL_PISTOL;
					    else if(Item(playerid, itemid, item_value)[ 0 ] == WEAPON_UZI)
							skillid = WEAPONSKILL_MICRO_UZI;

		        		ResetPlayerWeapons(playerid);
				        GivePlayerWeapon(playerid, Item(playerid, itemid, item_value)[ 0 ], ammo + Item(playerid, itemid, item_value)[ 1 ]);
						SetPlayerSkillLevel(playerid, skillid, 999);
						Weapon(playerid, 0, weapon_ammo) += Item(playerid, itemid, item_value)[ 1 ];
					}
					else
					{
					    if(GetWeaponSlot(Item(playerid, itemid, item_value)[ 0 ]) == GetWeaponSlot(Weapon(playerid, 0, weapon_model)))
					        return ShowInfo(playerid, red"Nie możesz mieć dwóch broni tego samego typu, nie pasujących do siebie!");
					        
			    		GivePlayerWeapon(playerid, Item(playerid, itemid, item_value)[ 0 ], Item(playerid, itemid, item_value)[ 1 ]);
						Weapon(playerid, 1, weapon_ammo) += Item(playerid, itemid, item_value)[ 1 ];
					}
					Weapon(playerid, 1, weapon_uid) = Item(playerid, itemid, item_uid);
					Weapon(playerid, 1, weapon_model) = Item(playerid, itemid, item_value)[ 0 ];
		    		format(Weapon(playerid, 1, weapon_name), MAX_ITEM_NAME, Item(playerid, itemid, item_name));
		    		Weapon(playerid, 1, weapon_flag) = floatval(Item(playerid, itemid, item_value3));
                }
                else
                {
                    new skillid;
				    if(Item(playerid, itemid, item_value)[ 0 ] == WEAPON_COLT45)
						skillid = WEAPONSKILL_PISTOL;
				    if(Item(playerid, itemid, item_value)[ 0 ] == WEAPON_UZI)
						skillid = WEAPONSKILL_MICRO_UZI;
						
                    SetPlayerSkillLevel(playerid, skillid, 0);
                    
		    		GivePlayerWeapon(playerid, Item(playerid, itemid, item_value)[ 0 ], Item(playerid, itemid, item_value)[ 1 ]);
		    		Weapon(playerid, 0, weapon_model) = Item(playerid, itemid, item_value)[ 0 ];
		    		Weapon(playerid, 0, weapon_uid) = Item(playerid, itemid, item_uid);
		    		format(Weapon(playerid, 0, weapon_name), MAX_ITEM_NAME, Item(playerid, itemid, item_name));
		    		Weapon(playerid, 0, weapon_flag) = floatval(Item(playerid, itemid, item_value3));
					Weapon(playerid, 0, weapon_ammo) = Item(playerid, itemid, item_value)[ 1 ];
				}

				new string[ 126 ];
	    		if(Player(playerid, player_option) & option_me)
				{
				    if(textuse[ 0 ]) format(string, sizeof string, " %s", textuse);
					format(string, sizeof string, "* %s wyciągnął broń %s%s.", NickName(playerid), Item(playerid, itemid, item_name), string);
					serwerme(playerid, string);
				}
				if(IsPlayerWeapon(Item(playerid, itemid, item_value)[ 0 ]))
					GivePlayerAchiv(playerid, achiv_gun);

				format(string, sizeof string, "UPDATE `surv_items` SET `used` = 1 WHERE `uid` = '%d'", Item(playerid, itemid, item_uid));
				mysql_query(string);
			}
		}
		case item_ammo:
		{
		    new buffer[ 256 ];
			formatex(string, 130, "SELECT `uid`, `name` FROM `surv_items` WHERE `ownerType`="#item_place_player" AND `owner`='%d' AND `v1` = '%d' AND `used` = 0 AND `type` = "#item_weapon"", Player(playerid, player_uid), Item(playerid, itemid, item_value)[ 0 ]);
			mysql_query(string);
			mysql_store_result();
			while(mysql_fetch_row(string))
			{
			    static uid,
			        name[ MAX_ITEM_NAME ];
			        
				sscanf(string, "p<|>ds["#MAX_ITEM_NAME"]",
					uid,
					name
				);
				
				format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, uid, name);
			}
			mysql_free_result();
			if(isnull(buffer)) return ShowInfo(playerid, red"Nie masz broni pasującej do tej amunicji.");
		    else Dialog::Output(playerid, 15, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Amunicja", buffer, "Wybierz", "Zamknij");
		    SetPVarInt(playerid, "item-uid", Item(playerid, itemid, item_uid));
			showed = false;
		}
		case item_cloth:
		{
		    Player(playerid, player_skin) = Item(playerid, itemid, item_value)[ 0 ];
		    SetPlayerSkin(playerid, Player(playerid, player_skin));
		    new string[ 126 ];
		    format(string, sizeof string,
				"UPDATE `surv_players` SET `skin` = '%d' WHERE `uid` = '%d'",
				Player(playerid, player_skin),
				Player(playerid, player_uid)
			);
			mysql_query(string);
			showed = false;
		}
		case item_food:
		{
			if(Item(playerid, itemid, item_value)[ 0 ] < gettime())
		        return ShowInfo(playerid, red"Ten produkt jest nieświeży. Nadaje się tylko do wyrzucenia.");

		    new string[ 126 ];
            GivePlayerHealthEx(playerid, Item(playerid, itemid, item_value3));
            //Player(playerid, player_hungry) += floatval(Item(playerid, itemid, item_value3));
			if(Player(playerid, player_option) & option_me)
			{
				format(string, sizeof string, "* %s zaczyna spożywać \"%s\".", NickName(playerid), Item(playerid, itemid, item_name));
				serwerme(playerid, string);
			}
			Item(playerid, itemid, item_value)[ 1 ]--;
			if(!Item(playerid, itemid, item_value)[ 1 ])
			{
				new itm_name[ MAX_ITEM_NAME ];
				format(itm_name, sizeof itm_name, "Opakowanie po \"%s\"", Item(playerid, itemid, item_name));
				Createitem(playerid, item_trash, trash_food, 0, 0.0, itm_name, 1);

				format(string, sizeof string, "DELETE FROM `surv_items` WHERE `uid` = '%d'", Item(playerid, itemid, item_uid));
				mysql_query(string);
				showed = false;
			}
			else
			{
		    	format(string, sizeof string, "UPDATE `surv_items` SET `v2`=`v2` - 1 WHERE `uid` = '%d'", Item(playerid, itemid, item_uid));
		    	mysql_query(string);

				showed = true;
			}
		}
		case item_drink:
		{
			new string[ 126 ];
            GivePlayerHealthEx(playerid, Item(playerid, itemid, item_value3));
            Player(playerid, player_hungry) += floatval(Item(playerid, itemid, item_value3));
			SetPlayerSpecialAction(playerid, Item(playerid, itemid, item_value)[ 1 ]);
			Item(playerid, itemid, item_value)[ 0 ]--;
			if(!Item(playerid, itemid, item_value)[ 0 ])
			{
				new itm_name[ MAX_ITEM_NAME ];
				format(itm_name, sizeof itm_name, "Butelka po \"%s\"", Item(playerid, itemid, item_name));
				Createitem(playerid, item_trash, trash_bottle, 0, 0.0, itm_name, 1);

				format(string, sizeof string, "DELETE FROM `surv_items` WHERE `uid` = '%d'", Item(playerid, itemid, item_uid));
				mysql_query(string);
				showed = false;
			}
			else
			{
		    	format(string, sizeof string, "UPDATE `surv_items` SET `v1`=`v1` - 1 WHERE `uid` = '%d'", Item(playerid, itemid, item_uid));
		    	mysql_query(string);
				showed = true;
			}
		}
		case item_watch:
		{
			cmd_time(playerid, "");
			showed = false;
		}
		case item_key:
		{
		    new buffer[ 126 ];
		    if(Item(playerid, itemid, item_value)[ 0 ] == key_type_vehicle)
		    {
		        new model;
		        format(buffer, sizeof buffer, "SELECT `model` FROM `surv_vehicles` WHERE `uid` = '%d'", Item(playerid, itemid, item_value)[ 1 ]);
		        mysql_query(buffer);
				mysql_store_result();
				model = mysql_fetch_int();
				mysql_free_result();
				
				format(buffer, sizeof buffer,
					white"Ten klucz pasuje tylko do %s (UID: %d).",
					NazwyPojazdow[model - 400],
					Item(playerid, itemid, item_value)[ 1 ]
				);
		        ShowInfo(playerid, buffer);
		    }
		    else if(Item(playerid, itemid, item_value)[ 0 ] == key_type_doors)
		    {
				format(buffer, sizeof buffer,
					white"Ten klucz nadaje się tylko do standardowych drzwi (UID: %d).",
					Item(playerid, itemid, item_value)[ 1 ]
				);
		        ShowInfo(playerid, buffer);
			}
		}
		case item_ciggy:
		{
		    new string[ 126 ];
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_SMOKE_CIGGY);
			
			Item(playerid, itemid, item_value)[ 0 ]--;
			if(!Item(playerid, itemid, item_value)[ 0 ])
			{
				format(string, sizeof string, "DELETE FROM `surv_items` WHERE `uid` = '%d'", Item(playerid, itemid, item_uid));
				mysql_query(string);
			}
			else
			{
		    	format(string, sizeof string, "UPDATE `surv_items` SET `v1`=`v1` - 1 WHERE `uid` = '%d'", Item(playerid, itemid, item_uid));
		    	mysql_query(string);
			}
			showed = false;
		}
		case item_radio: {}
		case item_phone:
		{
		    if(!Item(playerid, itemid, item_value)[ 1 ])
		    {
				mysql_query("INSERT INTO `surv_phone` (`uid`) VALUES (NULL)");
				new uid = mysql_insert_id(), string[ 126 ];
		    	format(string, sizeof string,
					"UPDATE `surv_items` SET `v1` = '0', `v2` = '%d' WHERE `uid` = '%d'",
					uid,
					Item(playerid, itemid, item_uid)
				);
		    	mysql_query(string);
		    	Item(playerid, itemid, item_value)[ 0 ] = 0;
		    	Item(playerid, itemid, item_value)[ 1 ] = uid;
		    }
			if(!Item(playerid, itemid, item_value)[ 0 ])
				return ShowInfo(playerid, red"W telefonie nie ma karty SIM!");

    		Phone(playerid, phone_uid) = Item(playerid, itemid, item_value)[ 1 ];
	        Phone(playerid, phone_number) = Item(playerid, itemid, item_value)[ 0 ];

		    if(isnull(textuse))
		        Phone_Default(playerid);
			else
		    	Call(playerid, strval(textuse));
		    showed = false;
		}
		case item_kajdanki:
		{
		    if(isnull(textuse))
		        return Chat::Output(playerid, SZARY, "[ID na liście] [ID/Nick]");
		    cmd_skuj(playerid, textuse);
		}
		case item_megafon:
		{
		    if(isnull(textuse))
		        return Chat::Output(playerid, SZARY, "[ID na liście] [Treść]");
		    cmd_megafon(playerid, textuse);
		}
		case item_karta:
		{
			ShowInfo(playerid, white"Karty możesz użyć przy dowolnym bankomacie. Daje ona dostęp do konta z banku.\nAby zmienić nazwę przedmiotu wpisz: \"nazwa [ID na liście] [Nowa nazwa]\"");
		}
		case item_trash: {}
		case item_seed:
		{
	        if(!Player(playerid, player_door) && !Player(playerid, player_adminlvl))
	            return ShowInfo(playerid, red"Nie możesz sadzić na zewnątrz budynku!");
	            
	 	    GetPlayerPos(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]);
			GetXYInFrontOfPlayer(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], 0.5);
		    Player(playerid, player_position)[ 2 ] -= player_down;
		    
			new string[ 200 ],
				objectuid,
				plantuid;
	 	    	
			format(string, sizeof string,
				"INSERT INTO `surv_objects` (`model`, `X`, `Y`, `Z`, `door`, `accept`) VALUES ('%d', '%f', '%f', '%f', '%d', 1)",
				Item(playerid, itemid, item_value)[ 0 ],
				Player(playerid, player_position)[ 0 ],
				Player(playerid, player_position)[ 1 ],
				Player(playerid, player_position)[ 2 ],
				Door(Player(playerid, player_door), door_uid)
			);
			mysql_query(string);
			objectuid = mysql_insert_id();
			
			format(string, sizeof string,
			    "INSERT INTO `surv_plants` (`uid`, `type`, `objectuid`, `owner`) VALUE (NULL, '%d', '%d', '%d')",
			    Item(playerid, itemid, item_value)[ 0 ],
			    objectuid,
			    Player(playerid, player_uid)
			);
			mysql_query(string);
			plantuid = mysql_insert_id();

			#if STREAMER
				new object = CreateDynamicObject(Item(playerid, itemid, item_value)[ 0 ], Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ], 0.0, 0.0, 0.0, Player(playerid, player_vw), -1, -1, 1000.0);
				Streamer_SetIntData(STREAMER_TYPE_OBJECT, object, E_STREAMER_EXTRA_ID, objectuid);
				EditDynamicObject(playerid, object);
			    // TODO
			#else
				foreach(Player, i)
				{
					if(Player(playerid, player_vw) != Player(i, player_vw)) continue;

					new objectid = 1;
					for(; objectid != MAX_OBJECTS; objectid++)
					    if(!IsValidPlayerObject(playerid, Object(playerid, objectid, obj_objID)) && !IsValidObject(objectid))
					        break;
					if(objectid == MAX_OBJECTS)
			        {
			            DestroyPlayerObject(i, objectid);

						ShowInfo(playerid, red"W tym pomieszczeniu skończył się limit obiektów!");

						format(string, sizeof string, "DELETE FROM `surv_plants` WHERE `uid` = '%d'", plantuid);
						mysql_query(string);

						format(string, sizeof string, "DELETE FROM `surv_objects` WHERE `uid` = '%d'", objectuid);
						mysql_query(string);
						return 1;
			        }
					Object(i, objectid, obj_objID) = CreatePlayerObject(i, Item(playerid, itemid, item_value)[ 0 ], Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ], 0, 0, 0, 200.0);
					Object(i, objectid, obj_uid) = objectuid;
					if(i == playerid) EditPlayerObject(playerid, Object(playerid, objectid, obj_objID));
				}
			#endif
			SetPVarInt(playerid, "seed-item-uid", Item(playerid, itemid, item_uid));
			SetPVarInt(playerid, "seed-object-uid", objectuid);
			SetPVarInt(playerid, "seed-plant-uid", plantuid);
			SetPVarInt(playerid, "seed-item-value", Item(playerid, itemid, item_value)[ 1 ]);
			showed = false;
		}
		case item_attach:
		{
		    if(Item(playerid, itemid, item_used) == 1)
		    {
				new index = Item(playerid, itemid, item_value)[ 1 ];
				
				Attach(playerid, index, attach_itemuid) = Item(playerid, itemid, item_uid);
				SetPVarInt(playerid, "attach-item-slot", index);

		        Dialog::Output(playerid, 17, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Ustawienia", "Edytuj\nSkasuj", "Wybierz", "Zamknij");
		    }
		    else
		    {
             	new index = Item(playerid, itemid, item_value)[ 1 ];
             	
   		        if(IsPlayerAttachedObjectSlotUsed(playerid, index))
					return ShowInfo(playerid, red"Slot jest zajęty!");
					
                Attach(playerid, index, attach_model) 	= Item(playerid, itemid, item_value)[ 0 ];
	            Attach(playerid, index, attach_bone) 	= floatval(Item(playerid, itemid, item_value3));
				Attach(playerid, index, attach_itemuid) = Item(playerid, itemid, item_uid);
				
		        SetPlayerAttachedObject(playerid, index, Attach(playerid, index, attach_model), Attach(playerid, index, attach_bone));
		        EditAttachedObject(playerid, index);
 		    }
			showed = false;
		}
		case item_drugs:
		{
		    if(Player(playerid, player_drug)) return ShowInfo(playerid, red"Zażywasz już coś!");
		    new druglvl,
				string[ 126 ];
			switch(Item(playerid, itemid, item_value)[ 0 ])
			{
			    case nark_type_marycha:
			    {
			        druglvl = 0;
			        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_SMOKE_CIGGY);
			    }
				case nark_type_crack:
				{
                    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_SMOKE_CIGGY);
				    druglvl = randomEx(20, 50);
				}
			    case nark_type_amfa:
				{
					druglvl = randomEx(20, 40);
				}
				case nark_type_ecstasy:
				{
					druglvl = randomEx(15, 20);
				}
				case nark_type_heroina:
				{
					druglvl = randomEx(30, 50);
				}
				case nark_type_kokaina:
				{
                    druglvl = randomEx(30, 50);
				}
				case nark_type_meta:
				{
					druglvl = randomEx(15, 20);
				}
				case nark_type_grzyby: {}
				case nark_type_lsd: {}
				case nark_type_opium: {}
			}
			Player(playerid, player_drug) = Item(playerid, itemid, item_value)[ 0 ];
			Nark(playerid, nark_druglvl) = druglvl;
			Item(playerid, itemid, item_value)[ 1 ]--;
			if(!Item(playerid, itemid, item_value)[ 1 ])
			{
				format(string, sizeof string, "DELETE FROM `surv_items` WHERE `uid` = '%d'", Item(playerid, itemid, item_uid));
				mysql_query(string);
			}
			else
			{
		    	format(string, sizeof string, "UPDATE `surv_items` SET `v2` = `weight` - 1, `weight` = `weight` - 1 WHERE `uid` = '%d'", Item(playerid, itemid, item_uid));
		    	mysql_query(string);
			}
		}
		case item_checkbox:
		{
		    new buffer[ 256 ],
		        count,
		        string[ 32 ];

			format(buffer, sizeof buffer, "SELECT DISTINCT `number` FROM `surv_bank` WHERE `ownerType` = "#bank_type_player" AND `owner` = '%d'", Player(playerid, player_uid));
			mysql_query(buffer);
			mysql_store_result();

			buffer = "Wybierz kartę:\n";
			count = 0;

			while(mysql_fetch_row(string))
			{
			    static id;
			    id = strval(string);
				format(buffer, sizeof(buffer), "%s%d\n", buffer, id);
				count++;
			}
			mysql_free_result();
			if(count) Dialog::Output(playerid, 32, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Czek", buffer, "Wybierz", "Zamknij");
			else ShowInfo(playerid, red"Nie posiadasz założonego konta w banku.\n\n"white"Możesz je założyć u pracownika banku.");
			showed = false;
		}
		case item_check:
		{
		    if(!Item(playerid, itemid, item_value)[ 1 ])
		        return ShowInfo(playerid, red"Czek został odwołany!");
		    new buffer[ 256 ],
		        count;
			format(buffer, sizeof buffer,
				"SELECT 1 FROM `surv_doors` JOIN `surv_groups` ON surv_doors.ownerType = "#door_type_group" AND surv_doors.owner = surv_groups.uid WHERE surv_groups.type = "#group_type_bank" AND surv_doors.uid = '%d'",
				Door(Player(playerid, player_door), door_uid)
			);
			mysql_query(buffer);
			mysql_store_result();
			count = mysql_num_rows();
			mysql_free_result();

			if(!count)
				return ShowInfo(playerid, red"Nie jesteś w banku!");

			new Float:bank_money;
			format(buffer, sizeof buffer,
				"SELECT `cash` FROM `surv_bank` WHERE `number` = '%d'",
				Item(playerid, itemid, item_value)[ 0 ]
			);
			mysql_query(buffer);
			mysql_store_result();
			mysql_fetch_float(bank_money);
			mysql_free_result();

			if(bank_money < Item(playerid, itemid, item_value3))
			    return ShowInfo(playerid, red"Czek jest bez pokrycia!");
			    
			if(Item(playerid, itemid, item_value3) <= 0)
			    return DeleteItem(Item(playerid, itemid, item_uid));
			    
		    format(buffer, sizeof buffer, "UPDATE `surv_bank` SET `cash` = `cash` - '%.2f' WHERE `number` = '%d'", Item(playerid, itemid, item_value3), Item(playerid, itemid, item_value)[ 0 ]);
		    mysql_query(buffer);
		    
		    SetPlayerMoney(playerid, Player(playerid, player_cash) += Item(playerid, itemid, item_value3));

			ShowInfo(playerid, green"Czek zrealizowano pomyślnie!");
			DeleteItem(Item(playerid, itemid, item_uid));
			
			showed = false;
		}
		case item_rolki:
		{
		    if(Player(playerid, player_door))
		        return ShowInfo(playerid, red"Nie możesz założyć rolek w budynku!");
		    new string[ 65 ];
		    Player(playerid, player_rolki) = !Player(playerid, player_rolki);
		    Item(playerid, itemid, item_used) = !Item(playerid, itemid, item_used);
	        format(string, sizeof string, "UPDATE `surv_items` SET `used` = '%d' WHERE `uid` = '%d'", Item(playerid, itemid, item_used), Item(playerid, itemid, item_uid));
			mysql_query(string);
			showed = false;
		}
		case item_craft:
		{
		    ShowInfo(playerid, white"Przedmiot nadaje się do craftingu!\nZaznacz go \"wybierz [ID na liście]\", a następnie wpisz \"craftuj\"");
		}
		case item_cd:
		{
		    if(Item(playerid, itemid, item_value)[ 0 ])
		        return ShowInfo(playerid, red"Ta płyta jest już nagrana!");
		    SetPVarInt(playerid, "cd-uid", Item(playerid, itemid, item_uid));
		    Dialog::Output(playerid, 47, DIALOG_STYLE_INPUT, IN_HEAD" "white"» "grey"Nagrywanie płyty", "Podaj adres URL radia.", "Zapisz", "Zamknij");
		}
		case item_bumbox: {}
		case item_cdplayer:
		{
		    if(Player(playerid, player_cdplayer) != Item(playerid, itemid, item_uid) && Player(playerid, player_cdplayer))
		        return ShowInfo(playerid, red"Aktualnie korzystasz z innego CD-Playera.");
		        
		    new buffer[ 126 ];
		    format(buffer, sizeof buffer, "%s muzykę\n", Player(playerid, player_cdplayer) ? ("Wyłącz") : ("Włącz"));
			if(Player(playerid, player_cdplayer))
			    strcat(buffer, "Zmień utwór\n");
			    
			Dialog::Output(playerid, 58, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"CD-Player", buffer, "Wybierz", "Zamknij");
			
			SetPVarInt(playerid, "sound-v1", Item(playerid, itemid, item_value)[ 0 ]);
			SetPVarInt(playerid, "sound-uid", Item(playerid, itemid, item_uid));
			showed = false;
		}
		case item_pack:
		{
			new string[ 126 ], buffer[ 512 ];
			format(string, sizeof string, "SELECT `uid`, `name` FROM `surv_items` WHERE `ownerType` = '"#item_place_item"' AND `owner` = '%d'", Item(playerid, itemid, item_uid));
			mysql_query(string);
			mysql_store_result();
			while(mysql_fetch_row(string))
			{
			    static uid, name[ MAX_ITEM_NAME ];
			    sscanf(string, "p<|>ds["#MAX_ITEM_NAME"]",
			        uid,
			        name
				);
				
				format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, uid, name);
			}
			mysql_free_result();
			Dialog::Output(playerid, 78, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Paczka", buffer, "Wyjmij", "Zamknij");
		}
		case item_siren:
		{
		    new carid = Player(playerid, player_veh),
				string[ 125 ];

		    if(carid == INVALID_VEHICLE_ID)
		        return ShowInfo(playerid, red"Nie jesteś w pojeździe");

			if(Vehicle(carid, vehicle_option) & option_siren && Vehicle(carid, vehicle_siren_obj) != INVALID_OBJECT_ID)
			    return ShowInfo(playerid, red"Na tym pojeździe jest już zamontowana syrena.");
				    
			Vehicle(carid, vehicle_siren) = Item(playerid, itemid, item_value)[ 0 ];
			Vehicle(carid, vehicle_option) += option_siren;
			InstallSiren(carid);
			
			format(string, sizeof string,
				"UPDATE `surv_items` SET `ownerType` = '" #item_place_tuning "', `owner` = '%d' WHERE `uid` = '%d'",
				Vehicle(carid, vehicle_uid),
				Item(playerid, itemid, item_uid)
			);
			mysql_query(string);
			
			format(string, sizeof string,
				"UPDATE `surv_vehicles` SET `siren` = '%d' WHERE `uid` = '%d'",
				Vehicle(carid, vehicle_siren),
				Vehicle(carid, vehicle_uid)
			);
			mysql_query(string);
			
			ShowInfo(playerid, green"Syrena zamontowana pomyślnie.");
		}
		case item_document:
		{
		    if(isnull(textuse))
		    {
		        new playername[ MAX_PLAYER_NAME ],
					age,
					string[ 126 ],
					year;
					
				format(string, sizeof string,
					"SELECT `name`, `age` FROM `surv_players` WHERE `uid` = '%d'",
					Item(playerid, itemid, item_value)[ 0 ]
				);
				mysql_query(string);
				mysql_store_result();
				mysql_fetch_row(string);
				
				sscanf(string, "p<|>s["#MAX_PLAYER_NAME"]d",
				    playername,
				    age
				);
				mysql_free_result();
				
				UnderscoreToSpace(playername);
		        getdate(year);
		        
		        format(string, sizeof string,
					white"\tDane Licencji:\n\nImię i Nazwisko:\t\t%s\nRok urodzenia:\t\t%d\nLicencja:\t\t\t%s",
					playername,
					year - age,
					LicName[ Item(playerid, itemid, item_value)[ 1 ] ][ lic_name ]
				);
				ShowInfo(playerid, string);
		    }
		    else
		    {
		        new victimid = strval(textuse);
		        
				if(!IsPlayerConnected(victimid))
				    return Chat::Output(playerid, SZARY, "[ID na liście] [ID/Nick] | Nie znaleziono gracza.");
				if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
				    return Chat::Output(playerid, SZARY, "[ID na liście] [ID/Nick] | Gracz nie jest w pobliżu!");
		        if(Offer(victimid, offer_active))
		            return ShowInfo(playerid, OFFER_FALSE);

		        Offer(playerid, offer_type) 		= offer_type_document;
				Offer(playerid, offer_player) 		= victimid;
				Offer(playerid, offer_value)[ 0 ] 	= Item(playerid, itemid, item_uid);
                Offer(playerid, offer_active)       = true;

		        Offer(victimid, offer_type) 		= offer_type_document;
				Offer(victimid, offer_player) 		= playerid;
				Offer(victimid, offer_value)[ 0 ] 	= Item(playerid, itemid, item_uid);
				Offer(victimid, offer_active)       = true;
                
                ShowPlayerOffer(playerid, victimid);
		    }
		}
		case item_leki:
		{
		    new victimid,
				string[ 126 ];
			if(isnull(textuse))
		        victimid = playerid;
			else
			{
			    victimid = strval(textuse);
				if(!IsPlayerConnected(victimid))
				    return Chat::Output(playerid, SZARY, "[ID na liście] [ID/Nick] | Nie znaleziono gracza.");
				if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
				    return Chat::Output(playerid, SZARY, "[ID na liście] [ID/Nick] | Gracz nie jest w pobliżu!");
			}
			switch(Item(playerid, itemid, item_value)[ 0 ])
		    {
		        case lek_bandaz:
		        {
         			if(!Player(victimid, player_blooding))
         			{
		            	if(playerid != victimid)
		                	return ShowInfo(playerid, red"Gracz nie krwawi!");
						else
						    return ShowInfo(playerid, red"Nie krwawisz!");
		            }
		        	Player(victimid, player_blooding) -= 50;
		        	if(Player(victimid, player_blooding) < 0)
		        	    Player(victimid, player_blooding) = 0;
		        }
		        case lek_morfina:
		        {

		        }
		    }
			Item(playerid, itemid, item_value)[ 1 ]--;
			if(!Item(playerid, itemid, item_value)[ 1 ])
			{
				format(string, sizeof string, "DELETE FROM `surv_items` WHERE `uid` = '%d'", Item(playerid, itemid, item_uid));
				mysql_query(string);
			}
			else
			{
		    	format(string, sizeof string, "UPDATE `surv_items` SET `v2`= `v2` - 1 WHERE `uid` = '%d'", Item(playerid, itemid, item_uid));
		    	mysql_query(string);
			}
		}
		case item_notes:
		{
		    new query[ 600 ],
				string[ 512 ],
				count;
				
			format(query, sizeof query,
			    "SELECT `uid`, `text` FROM `surv_karteczki` WHERE `authorType` = '"#kart_type_item"' AND `author` = '%d'",
			    Item(playerid, itemid, item_uid)
			);
			mysql_query(query);
			mysql_store_result();
		    while(mysql_fetch_row(query))
		    {
				static uid,
					text[ 512 ],
					len;
				
				sscanf(query, "p<|>ds[512]",
					uid,
					text
				);
				len = strlen(text);
				if(len >= max_c)
				{
				    strdel(text, max_c, len);
				    strcat(text, "...");
				}
				format(string, sizeof string, "%s%d\t%s\n", string, uid, text);
				count++;
		    }
			mysql_free_result();
			strcat(string, grey"------------------------\n");
			strcat(string, "Dodaj nowy wpis");
			SetPVarInt(playerid, "notes-uid", Item(playerid, itemid, item_uid));
			
		    if(!count) Dialog::Output(playerid, 83, DIALOG_STYLE_INPUT, IN_HEAD" "white"» "grey"Notes", white"Notes jest pusty.\nWpisz niżej tekst, aby stworzyć pierwszą notatkę!", "Zapisz", "Zamknij");
		    else Dialog::Output(playerid, 84, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Notes", string, "Wybierz", "Zamknij");
		}
		case item_kartka:
		{
		    new uid = Item(playerid, itemid, item_value)[ 0 ],
		        string[ 600 ],
		        query[ 160 ],
				owner[ 2 ],
				timeAgo[ 32 ],
				unix_time;
			format(query, sizeof query,
			    "SELECT * FROM `surv_karteczki` WHERE `uid` = '%d'",
			    uid
			);
			mysql_query(query);
			mysql_store_result();
			mysql_fetch_row(string);
			mysql_free_result();
			
			sscanf(string, "p<|>{d}s[512]a<d>[2]d",
			    string,
			    owner,
			    unix_time
			);
			ReturnTimeAgo(unix_time, timeAgo);
			
			new name[ MAX_PLAYER_NAME ];
			format(query, sizeof query,
			    "SELECT `name` FROM %s WHERE `uid` = '%d'",
			    (owner[ 0 ] == kart_type_player) ? ("`surv_players`") : ("`surv_groups`"),
			    owner[ 1 ]
			);
			mysql_query(query);
			mysql_store_result();
			mysql_fetch_row(name);
			mysql_free_result();
			
			UnderscoreToSpace(name);
			
			format(string, sizeof string,
			    "%s\n\nAutor: %s\t\t\tNapisano: %s",
				string,
				name,
				timeAgo
			);
			
			ShowInfo(playerid, string);

			if(Player(playerid, player_option) & option_me)
			{
			    format(string, sizeof string, "* %s czyta karteczkę.", NickName(playerid));
			    serwerme(playerid, string);
			}
		}
		case item_component:
		{
	        new victimid,
				Float:price;

	        if(sscanf(textuse, "uf", victimid, price))
			    return Chat::Output(playerid, SZARY, "[ID na liście] [ID/Nick] [Robocizna]");
			if(!IsPlayerConnected(victimid))
			    return Chat::Output(playerid, SZARY, "[ID na liście] [ID/Nick] [Robocizna] | Nie znaleziono gracza.");
			if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
			    return Chat::Output(playerid, SZARY, "[ID na liście] [ID/Nick] [Robocizna] | Gracz nie jest w pobliżu!");
	        if(Offer(victimid, offer_active))
	            return ShowInfo(playerid, OFFER_FALSE);
		    if(!Player(victimid, player_veh))
		        return ShowInfo(playerid, red"Gracz nie jest w pojeździe.");
			if(Repair(playerid, repair_type))
			    return ShowInfo(playerid, red"Aktualnie pracujesz przy innym pojeździe.");
			if(GetVehicleComponentInSlot(Player(victimid, player_veh), GetVehicleComponentType(Item(playerid, itemid, item_value)[ 0 ])) == Item(playerid, itemid, item_value)[ 0 ])
                return ShowInfo(playerid, red"Slot zajęty.");
                
            new bool:can;
            if(GetVehicleComponentType(Item(playerid, itemid, item_value)[ 0 ]) == CARMODTYPE_WHEELS && IsCar(Player(victimid, player_veh)))
            {
                can = true;
            }
            else
            {
	            for(new s; s != sizeof CarMods; s++)
	            {
	                if(CarMods[ s ][ 0 ] == Vehicle(Player(victimid, player_veh), vehicle_model))
	                {
		                for(new d; d != sizeof CarMods[ ]; d++)
		                {
		                	if(CarMods[ s ][ d ] == Item(playerid, itemid, item_value)[ 0 ])
		                	{
			                	can = true;
								break;
		                	}
						}
					}
	        	}
        	}
        	if(!can)
        	    return ShowInfo(playerid, red"Ten przedmiot nie pasuje do tego pojazdu.");
        	    
			Offer(playerid, offer_type) 		= offer_type_comp;
			Offer(playerid, offer_player) 		= victimid;
			Offer(playerid, offer_cash) 		= price;
			Offer(playerid, offer_value)[ 0 ] 	= Item(playerid, itemid, item_uid);
			Offer(playerid, offer_value)[ 1 ] 	= Item(playerid, itemid, item_value)[ 0 ];
            Offer(playerid, offer_active)       = true;

	        Offer(victimid, offer_type) 		= offer_type_comp;
			Offer(victimid, offer_player) 		= playerid;
			Offer(victimid, offer_cash) 		= price;
			Offer(victimid, offer_value)[ 0 ] 	= Item(playerid, itemid, item_uid);
			Offer(victimid, offer_value)[ 1 ] 	= Item(playerid, itemid, item_value)[ 0 ];
			Offer(victimid, offer_active)       = true;

            ShowPlayerOffer(playerid, victimid);
		}
		case item_element:
		{
	        new victimid,
				Float:price;

	        if(sscanf(textuse, "uf", victimid, price))
			    return Chat::Output(playerid, SZARY, "[ID na liście] [ID/Nick] [Robocizna]");
			if(!IsPlayerConnected(victimid))
			    return Chat::Output(playerid, SZARY, "[ID na liście] [ID/Nick] [Robocizna] | Nie znaleziono gracza.");
			if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
			    return Chat::Output(playerid, SZARY, "[ID na liście] [ID/Nick] [Robocizna] | Gracz nie jest w pobliżu!");
	        if(Offer(victimid, offer_active))
	            return ShowInfo(playerid, OFFER_FALSE);
		    if(!Player(victimid, player_veh))
		        return ShowInfo(playerid, red"Gracz nie jest w pojeździe.");
			if(Repair(playerid, repair_type))
			    return ShowInfo(playerid, red"Aktualnie pracujesz przy innym pojeździe.");
			//offer_type_element
		}
		case item_vehitem:
		{
	        new victimid,
				Float:price;

	        if(sscanf(textuse, "uf", victimid, price))
			    return Chat::Output(playerid, SZARY, "[ID na liście] [ID/Nick] [Robocizna]");
			if(!IsPlayerConnected(victimid))
			    return Chat::Output(playerid, SZARY, "[ID na liście] [ID/Nick] [Robocizna] | Nie znaleziono gracza.");
			if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
			    return Chat::Output(playerid, SZARY, "[ID na liście] [ID/Nick] [Robocizna] | Gracz nie jest w pobliżu!");
	        if(Offer(victimid, offer_active))
	            return ShowInfo(playerid, OFFER_FALSE);
		    if(!Player(victimid, player_veh))
		        return Chat::Output(playerid, SZARY, "[ID na liście] [ID/Nick] [Robocizna] | Gracz nie jest w pojeździe.");
			if(Repair(playerid, repair_type))
			    return ShowInfo(playerid, red"Aktualnie pracujesz przy innym pojeździe.");
			if(Vehicle(Player(victimid, player_veh), vehicle_option) & InVeh[ Item(playerid, itemid, item_value)[ 0 ] ][ in_bit ])
			    return ShowInfo(playerid, red"Dany element jest już zamontowany w tym pojeździe.");

			Offer(playerid, offer_type) 		= offer_type_inveh;
			Offer(playerid, offer_player) 		= victimid;
			Offer(playerid, offer_cash) 		= price;
			Offer(playerid, offer_value)[ 0 ] 	= Item(playerid, itemid, item_uid);
			Offer(playerid, offer_value)[ 1 ] 	= Item(playerid, itemid, item_value)[ 0 ];
			Offer(playerid, offer_value3) 		= Item(playerid, itemid, item_value)[ 1 ];
            Offer(playerid, offer_active)       = true;

	        Offer(victimid, offer_type) 		= offer_type_inveh;
			Offer(victimid, offer_player) 		= playerid;
			Offer(victimid, offer_cash) 		= price;
			Offer(victimid, offer_value)[ 0 ] 	= Item(playerid, itemid, item_uid);
			Offer(victimid, offer_value)[ 1 ] 	= Item(playerid, itemid, item_value)[ 0 ];
			Offer(victimid, offer_value3) 		= Item(playerid, itemid, item_value)[ 1 ];
			Offer(victimid, offer_active)       = true;

            ShowPlayerOffer(playerid, victimid);
		}
		case item_worek:
		{
	        if(isnull(textuse))
			    return Chat::Output(playerid, SZARY, "[ID na liście]");

			cmd_worek(playerid, textuse);
		}
		case item_knebel:
		{
	        if(isnull(textuse))
			    return Chat::Output(playerid, SZARY, "[ID na liście]");

			cmd_knebluj(playerid, textuse);
		}
		case item_mask:
		{
		    if(Player(playerid, player_mask) == 0)
		    {
		        if(!isnull(textuse) && Item(playerid, itemid, item_value)[ 0 ] == 1)
		        {
			        if(!(3 <= strlen(textuse)))
						return Chat::Output(playerid, SZARY, "[ID na liście] [Nazwa] | Za krótka nazwa.");
			        if(!(strlen(textuse) <= MAX_PLAYER_NAME))
						return Chat::Output(playerid, SZARY, "[ID na liście] [Nazwa] | Za długa nazwa.");
					new part[ 24 ], part2[ 24 ];
					if(sscanf(textuse, "p<_>s[24]s[24]", part, part2))
					    return Chat::Output(playerid, SZARY, "[ID na liście] [Nazwa] | Nazwa musi składać się z dwóch części oddzielonych '_'.");
					if(!isnull(part) && !isnull(part2))
					    return Chat::Output(playerid, SZARY, "[ID na liście] [Nazwa] | Nazwa musi składać się z dwóch części oddzielonych '_'.");
					SetPVarString(playerid, "mask-name", textuse);
                    Player(playerid, player_mask) = -1;
		    	    UpdatePlayerNick(playerid);
		        }
		        else
		        {
			        Player(playerid, player_mask) = Item(playerid, itemid, item_uid);

			        new string[ 126 ];
			        format(string, sizeof string,
						"UPDATE `surv_players` SET `mask` = '%d' WHERE `uid` = '%d'",
						Player(playerid, player_mask),
						Player(playerid, player_uid)
					);
			        mysql_query(string);

			    	format(string, sizeof string, "UPDATE `surv_items` SET `used` = '1' WHERE `uid` = '%d'", Item(playerid, itemid, item_uid));
			    	mysql_query(string);
		    	}
		        Chat::Output(playerid, SZARY, "Maska założona!");
		    	showed = false;
		    }
		    else
		    {
		        if(Player(playerid, player_mask) != -1)
		        {
			        if(Player(playerid, player_mask) != Item(playerid, itemid, item_uid))
			            return ShowInfo(playerid, red"Masz inną maskę założoną.");
				}
		        new string[ 126 ];
		        format(string, sizeof string,
					"UPDATE `surv_players` SET `mask` = '0' WHERE `uid` = '%d'",
					Player(playerid, player_uid)
				);
		        mysql_query(string);

		        Item(playerid, itemid, item_value)[ 0 ]--;
				if(!Item(playerid, itemid, item_value)[ 0 ])
				{
					format(string, sizeof string, "DELETE FROM `surv_items` WHERE `uid` = '%d'", Item(playerid, itemid, item_uid));
					mysql_query(string);
				}
				else
				{
			    	format(string, sizeof string, "UPDATE `surv_items` SET `v1`=`v1` - 1, `used` = '0' WHERE `uid` = '%d'", Item(playerid, itemid, item_uid));
			    	mysql_query(string);
				}
		        Chat::Output(playerid, SZARY, "Maska zdjęta!");
		        Player(playerid, player_mask) = 0;
		    }
		    UpdatePlayerNick(playerid);
		}
		case item_tlumik:
		{
		    if(!GetPlayerWeapon(playerid))
		        return ShowInfo(playerid, red"Wyciągnij broń!");
		    if(!Weapon(playerid, Player(playerid, player_used_weapon), weapon_model))
		        return ShowInfo(playerid, red"Wyciągnij broń!");
			if(Weapon(playerid, 0, weapon_model) == Weapon(playerid, 1, weapon_model))
				return ShowInfo(playerid, red"Nie możesz założyć tłumika na dwie bronie!");

			if(Weapon(playerid, Player(playerid, player_used_weapon), weapon_model) == WEAPON_COLT45)
			{
				new ammo = GetWeaponAmmo(playerid, Weapon(playerid, Player(playerid, player_used_weapon), weapon_model));
				ResetPlayerWeapons(playerid);
				Player(playerid, player_disabled) = true;
				Weapon(playerid, Player(playerid, player_used_weapon), weapon_model) = WEAPON_SILENCED;
				SetTimerEx("giveWeapon", 250, false, "dd", playerid, ammo);
				Chat::Output(playerid, SZARY, "Tłumik zamontowany.");
			}
			else if(Weapon(playerid, Player(playerid, player_used_weapon), weapon_model) == WEAPON_SILENCED)
			{
				new ammo = GetWeaponAmmo(playerid, Weapon(playerid, Player(playerid, player_used_weapon), weapon_model));
				ResetPlayerWeapons(playerid);
				Player(playerid, player_disabled) = true;
				Weapon(playerid, Player(playerid, player_used_weapon), weapon_model) = WEAPON_COLT45;
				SetTimerEx("giveWeapon", 250, false, "dd", playerid, ammo);
				Chat::Output(playerid, SZARY, "Tłumik zdjęty.");
			}
			else ShowInfo(playerid, red"Tłumik możesz zamontować tylko do Colta45!");
		}
		case item_kluczyki:
		{
		    new string[ 256 ];
		    new vehid = CreateVeh(playerid, Item(playerid, itemid, item_value)[ 0 ], vehicle_owner_player, Player(playerid, player_uid), random(120), random(120));
			format(string, sizeof string,
				"UPDATE `surv_vehicles` SET `x` = '%f', `y` = '%f', `z` = '%f', `a` = '%f', `int` = '0', `vw` = '0' WHERE `uid` = '%d'",
				Setting(setting_veh_pos)[ 0 ],
				Setting(setting_veh_pos)[ 1 ],
				Setting(setting_veh_pos)[ 2 ],
				Setting(setting_veh_pos)[ 3 ],
				Vehicle(vehid, vehicle_uid)
			);
			mysql_query(string);
			UnSpawnVeh(vehid);
			OnItemDestroy(playerid, itemid);
			SendClientMessage(playerid, SZARY, "Twój pojazd znajduje się w magazynie, aby go zespawnować wpisz /v.");
		}
		case item_wedka:
		{
		    cmd_wedkowanie(playerid, "");
		}
		case item_sim:
		{
		    new string[ 200 ], buffer[ 512 ];

		    format(string, sizeof string,
				"SELECT i.uid, i.name FROM `surv_items` i, `surv_phone` p WHERE i.ownerType = '"#item_place_player"' AND i.owner = '%d' AND i.type = '"#item_phone"' AND i.v1 = 0 AND p.option & '"#phone_off"' AND i.v2 = p.uid",
				Player(playerid, player_uid)
			);
			mysql_query(string);
			mysql_store_result();
			while(mysql_fetch_row(string))
			{
			    static uid,
					name[ MAX_ITEM_NAME ];
			    sscanf(string, "p<|>ds["#MAX_ITEM_NAME"]",
			        uid,
			        name
				);

				format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, uid, name);
			}
			mysql_free_result();
			if(isnull(buffer))
			    ShowInfo(playerid, red"Brak telefonu z wolnym slotem na karte SIM!");
			else
			{
			    SetPVarInt(playerid, "sim-numer", Item(playerid, itemid, item_value)[ 0 ]);
			    SetPVarInt(playerid, "sim-uid", Item(playerid, itemid, item_uid));
			    Dialog::Output(playerid, 159, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Karta SIM", buffer, "Wybierz", "Zamknij");
			}
		}
		case item_kostka:
		{
			cmd_kostka(playerid, "");
		}
		case item_karnet:
		{
		    if(Tren(playerid, train_item))
		    {
		        new string[ 70 ];
				format(string, sizeof string,
					"UPDATE `surv_items` SET `v2` = '%d' WHERE `uid` = '%d'",
					Tren(playerid, train_time),
					Tren(playerid, train_item)
				);
				mysql_query(string);

				for(new eTrain:i; i < eTrain; i++)
			    	Tren(playerid, i) = 0;
			    	
			    ShowInfo(playerid, green"Trening siłowy przerwany");
		    	return 1;
			}
		    	
			new doorid = GetPlayerDoor(playerid, false);
			if(!doorid)
				return ShowInfo(playerid, red"Nie stoisz przy żadnych drzwiach!");
				
			if(Door(doorid, door_owner)[ 0 ] != door_type_group && Door(doorid, door_owner)[ 1 ] != Item(playerid, itemid, item_value)[ 0 ])
			    return ShowInfo(playerid, red"Nie możesz wykorzystać tego karnetu tutaj!");
				
			Tren(playerid, train_item) = Item(playerid, itemid, item_uid);
			Tren(playerid, train_group) = Item(playerid, itemid, item_value)[ 0 ];
			Tren(playerid, train_time) = Item(playerid, itemid, item_value)[ 1 ];
			
			ShowInfo(playerid, green"Trening rozpoczęty!");
		}
	}
	new string[ 80 ];
	format(string, sizeof string,
		"UPDATE `surv_items` SET `last_used` = UNIX_TIMESTAMP() WHERE `uid` = '%d'",
		Item(playerid, itemid, item_uid)
	);
	mysql_query(string);
	
	if(IsPlayerVisibleItems(playerid) && showed)
	    ShowPlayerItems(playerid, Player(playerid, player_item_site));
	else
	    HideItemsTextDraw(playerid);
	return 1;
}

FuncPub::giveWeapon(playerid, ammo)
{
    GivePlayerWeapon(playerid, Weapon(playerid, 0, weapon_model), ammo);
    AntyCheat_Enable(playerid);
    return 1;
}

FuncPub::AntyCheat_Enable(playerid)
{
	GetPlayerPos(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]);
	GetPlayerFacingAngle(playerid, Player(playerid, player_position)[ 3 ]);
    Player(playerid, player_disabled) = false;
    return 1;
}

stock ClearWeapon(playerid, slot)
{
    for(new ePlayerWeapon:i; i < ePlayerWeapon; i++)
    	Weapon(playerid, slot, i) = 0;
    return 1;
}

FuncPub::OnPlayerCraft(playerid)
{
	new wynik,
		string[ 200 ],
		buffer[ 256 ];
	format(string, sizeof string, "SELECT `v1` FROM `surv_items` WHERE `used` = 2 AND `ownerType` = "#item_place_player" AND `owner` = '%d' AND `type` = "#item_craft"", Player(playerid, player_uid));
	mysql_query(string);
	mysql_store_result();
	while(mysql_fetch_row(string))
	{
		wynik += strval(string);
	}
	mysql_free_result();
	
	if(!wynik)
	    return ShowInfo(playerid, red"Żaden z zaznaczonych przedmiotów nie nadaje się do craftingu!");
	
	format(string, sizeof string, "SELECT `uid`, `name` FROM `surv_craft` WHERE `ID` = '%d'", wynik);
	mysql_query(string);
	mysql_store_result();
	while(mysql_fetch_row(string))
	{
	    static uid,
			name[ MAX_ITEM_NAME ];
		sscanf(string, "p<|>ds["#MAX_ITEM_NAME"]",
		    uid,
		    name
		);
		format(buffer, sizeof buffer, "%s%d\t%s", buffer, uid, name);
	}
	mysql_free_result();
	if(isnull(buffer)) ShowInfo(playerid, red"Brak możliwych kombinacji.");
	else Dialog::Output(playerid, 36, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Crafting", buffer, "Craftuj", "Zamknij");
	return 1;
}

FuncPub::OnPlayerPutInItem(playerid, itemuid)
{
	new string[ 200 ];
   	format(string, sizeof string,
		"UPDATE `surv_items` SET `ownerType` = '"#item_place_item"', `owner` = '%d', `used`='0', `favorite` = '0' WHERE `ownerType` = '"#item_place_player"' AND `owner` = '%d' AND `used` = '2'",
	   	itemuid,
	   	Player(playerid, player_uid)
 	);
	mysql_query(string);
	
	if(IsPlayerVisibleItems(playerid))
	    ShowPlayerItems(playerid, Player(playerid, player_item_site));
	return 1;
}

FuncPub::OnPlayerAddItemToFavorite(playerid, itemid)
{
	new string[ 126 ];
	Item(playerid, itemid, item_favorite) = !Item(playerid, itemid, item_favorite);
    format(string, sizeof string, "UPDATE `surv_items` SET `favorite` = '%d' WHERE `uid` = '%d'", Item(playerid, itemid, item_favorite), Item(playerid, itemid, item_uid));
	mysql_query(string);
	if(IsPlayerVisibleItems(playerid))
	    ShowPlayerItems(playerid, Player(playerid, player_item_site));
	return 1;
}

FuncPub::OnPlayerSelectItem(playerid, itemid)
{
	if(Item(playerid, itemid, item_used) == 1)
	    return ShowInfo(playerid, red"Nie możesz zaznaczyć używanego przedmiotu!");

    if(Item(playerid, itemid, item_used) == 2)
    {
        Player(playerid, player_item_selected)--;
        Item(playerid, itemid, item_used) = 0;
	}
	else
	{
        Player(playerid, player_item_selected)++;
	    Item(playerid, itemid, item_used) = 2;
	}
	new string[ 126 ];
    format(string, sizeof string, "UPDATE `surv_items` SET `used` = '%d' WHERE `uid` = '%d'", Item(playerid, itemid, item_used), Item(playerid, itemid, item_uid));
	mysql_query(string);
	if(IsPlayerVisibleItems(playerid))
	    ShowPlayerItems(playerid, Player(playerid, player_item_site));
	return 1;
}

FuncPub::OnItemNameChange(playerid, itemid, newname[])
{
	if(!strcmp(Item(playerid, itemid, item_name), newname, true))
		return ShowInfo(playerid, red"Ten przedmiot już się tak nazywa!");
		
	if(Item(playerid, itemid, item_type) != item_karta)
		return ShowInfo(playerid, red"Nie możesz zmienić nazwy tego typu przedmiotu!");
	EscapePL(newname);
	mysql_real_escape_string(newname, newname);
	new string[ 126 ];
    format(string, sizeof string, "UPDATE `surv_items` SET `name` = '%s' WHERE `uid` = '%d'", newname, Item(playerid, itemid, item_uid));
	mysql_query(string);

	if(IsPlayerVisibleItems(playerid))
	    ShowPlayerItems(playerid, Player(playerid, player_item_site));

	return 1;
}

FuncPub::OnPlayerRemoveItem(playerid, itemid)
{
	if(Item(playerid, itemid, item_used))
		return ShowInfo(playerid, red"Nie możesz wyrzucić przedmiotu, którego aktualnie używasz lub jest zaznaczony!");

	new string[ 256 ];
	if(!IsPlayerInAnyVehicle(playerid))
 	{
 	    GetPlayerPos(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]);
		GetXYInFrontOfPlayer(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], 0.5);
		#if mapandreas
	        if(Player(playerid, player_door))
			    Player(playerid, player_position)[ 2 ] -= player_down;
			else
				MapAndreas_FindZ_For2DCoord(Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]);
		#else
		    Player(playerid, player_position)[ 2 ] -= player_down;
		#endif
		
		#if STREAMER
		    new Float:r[ 3 ],
				model;
			model = ObjectItem(Item(playerid, itemid, item_type), Item(playerid, itemid, item_value)[ 0 ]);
			if(Item(playerid, itemid, item_type) == item_weapon)
			{
				r[ 0 ] = 85.0;
				r[ 1 ] = -809.0;
			}
			r[ 2 ] = random(360);
		    format(string, sizeof string,
				"INSERT INTO `surv_objects` (`model`, `x`, `y`, `z`, `rx`, `ry`, `rz`, `ownerType`, `owner`, `door`, `accept`) VALUES ('%d', '%f', '%f', '%f', '%f', '%f', '%f', '"#object_owner_item"', '%d', '%d', '1')",
				model,
				Player(playerid, player_position)[ 0 ],
				Player(playerid, player_position)[ 1 ],
				Player(playerid, player_position)[ 2 ],
				r[ 0 ], r[ 1 ], r[ 2 ],
				Item(playerid, itemid, item_uid),
				Door(Player(playerid, player_door), door_uid)
			);
			mysql_query(string);
			new objectuid = mysql_insert_id();
			new objectid = CreateDynamicObject(model, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ], r[ 0 ], r[ 1 ], r[ 2 ], Player(playerid, player_vw), -1, -1, 1000.0);
			Streamer_SetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_EXTRA_ID, objectuid);
			Streamer_Update(playerid);
			
			new c;
			for(; c < MAX_OBJECTS; c++)
			    if(Object(c, obj_objID) == objectid)
			        break;
			if(c == MAX_OBJECTS)
			{
			    for(c = 0; c < MAX_OBJECTS; c++)
			    	if(Object(c, obj_objID) == INVALID_OBJECT_ID)
			    	    break;
			    if(c != MAX_OBJECTS)
			    {
				    Object(c, obj_objID) = objectid;
					Object(c, obj_position)[ 0 ] = Player(playerid, player_position)[ 0 ];
					Object(c, obj_position)[ 1 ] = Player(playerid, player_position)[ 1 ];
					Object(c, obj_position)[ 2 ] = Player(playerid, player_position)[ 2 ];
					Object(c, obj_positionrot)[ 0 ] = r[ 0 ];
					Object(c, obj_positionrot)[ 1 ] = r[ 1 ];
					Object(c, obj_positionrot)[ 2 ] = r[ 2 ];
					Object(c, obj_owner)[ 0 ] = object_owner_item;
					Object(c, obj_owner)[ 1 ] = Item(playerid, itemid, item_uid);
				}
			}
            else if(c != MAX_OBJECTS)
            {
				Object(c, obj_owner)[ 0 ] = object_owner_item;
				Object(c, obj_owner)[ 1 ] = Item(playerid, itemid, item_uid);
			}
		#else
			foreach(Player, i)
			{
			    if(Player(i, player_vw) != Player(playerid, player_vw)) continue;

				new objectid = 1;
				for(; objectid != MAX_OBJECTS; objectid++)
				    if(!IsValidPlayerObject(playerid, Object(playerid, objectid, obj_objID)) && !IsValidObject(objectid))
				        break;
				if(objectid == MAX_OBJECTS) continue;

		        Object(i, objectid, obj_objID) = ObjectItem(i, Item(playerid, itemid, item_type), Item(playerid, itemid, item_value)[ 0 ], Item(playerid, itemid, item_value)[ 1 ], Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]);
			    Object(i, objectid, obj_owner)[ 0 ] 	= object_owner_item;
			    Object(i, objectid, obj_owner)[ 1 ] 	= Item(playerid, itemid, item_uid);
		        Object(i, objectid, obj_position)    	= Player(playerid, player_position);
			}
		#endif
   		ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.1, 0, 0, 0, 0, 0);

		format(string, sizeof string,
			"UPDATE `surv_items` SET `X`='%f', `Y`='%f', `Z`='%f', `vw`='%d', `ownerType`='"#item_place_none"', `owner`='0' WHERE `uid`='%d'",
			Player(playerid, player_position)[ 0 ],
			Player(playerid, player_position)[ 1 ],
			Player(playerid, player_position)[ 2 ],
			Player(playerid, player_vw),
			Item(playerid, itemid, item_uid)
		);
		mysql_query(string);
	}
	else
	{
 		new carid = Player(playerid, player_veh);

        if(IsARower(carid))
            return ShowInfo(playerid, red"Nie możesz odłożyć przedmiotu na rowerze!");

		format(string, sizeof string,
			"UPDATE `surv_items` SET `ownerType`="#item_place_vehicle", `owner`='%d' WHERE `uid`='%d'",
			Vehicle(carid, vehicle_uid),
			Item(playerid, itemid, item_uid)
		);
		mysql_query(string);
	}
	new sound;
	switch(Item(playerid, itemid, item_type))
	{
		case item_ammo:
		{
		    new table[] = {itm_sound_ammo_down};
			sound = table[random(sizeof table)];
		}
		case item_cloth:
		{
		    new table[] = {itm_sound_cloth_down};
			sound = table[random(sizeof table)];
		}
		case item_weapon:
		{
			switch(Item(playerid, itemid, item_value)[ 0 ])
			{
			    case 2..9, 15: // Male
			    {
			        sound = itm_sound_male_down;
			    }
			    case 30..31, 33..34, 25..27: // Assault | Shotguns | Rifle
			    {
			        sound = itm_sound_big_down;
			    }
			    case 22..24, 32, 28, 29: // Handguns | Machine-pistols
			    {
			        sound = itm_sound_gunssmall_down;
			    }
			    case 16..18, 39, 40: // throw | granat
			    {
			        sound = itm_grenade_down;
			    }
			    default:
				{
				    new table[] = {itm_sound_gen_down};
					sound = table[random(sizeof table)];
				}
			}
		}
		default:
		{
		    new table[] = {itm_sound_gen_down};
			sound = table[random(sizeof table)];
		}
	}
	if(sound && Audio_IsClientConnected(playerid))
		Audio_Play(playerid, sound);
    if(IsPlayerVisibleItems(playerid))
    {
		for(new i = 1; i != MAX_ITEMS; i++)
		{
		    if(Item(playerid, i, item_uid) == Item(playerid, itemid, item_uid)) continue;
		    if(Item(playerid, i, item_uid))
			{
		    	ShowPlayerItems(playerid, Player(playerid, player_item_site));
				break;
			}
	        HideItemsTextDraw(playerid);
			return 1;
		}
	}
	return 1;
}

FuncPub::OnItemDestroy(playerid, itemid)
{
	new string[ 126 ];
	format(string, sizeof string,
	    "DELETE FROM `surv_items` WHERE `uid` = '%d'",
	    Item(playerid, itemid, item_uid)
	);
	mysql_query(string);

    ClearItem(playerid, itemid);

	if(IsPlayerVisibleItems(playerid))
	    ShowPlayerItems(playerid, Player(playerid, player_item_site));
	    
	return 1;
}

FuncPub::OnPlayerPickUpItem(playerid, itemuid)
{
	new weight,
		owner[ 2 ],
		buffer[ 140 ];
		
	format(buffer, sizeof buffer,
		"SELECT `weight`, `ownerType`, `owner`, `type`, `v1`, `v2`, `name` FROM `surv_items` WHERE `uid` = '%d'",
		itemuid
	);
	mysql_query(buffer);
	mysql_store_result();
	mysql_fetch_row_format(buffer);
	
	sscanf(buffer, "p<|>da<d>[2]da<d>[2]s[24]",
	    weight,
		owner,
        Item(playerid, 0, item_type),
        Item(playerid, 0, item_value),
        Item(playerid, 0, item_name)
	);
	
	mysql_free_result();
	Item(playerid, 0, item_uid) = itemuid;
	
	if(owner[ 0 ] == item_place_player && owner[ 1 ])
		return ShowInfo(playerid, red"Ktoś Cię uprzedził i podniósł przedmiot przed Tobą!");

/*	if(weight)
	{
	    new masa;
		format(buffer, sizeof buffer,
			"SELECT `weight` FROM `surv_items` WHERE `ownerType`="#item_place_player" AND `owner` = '%d'",
			Player(playerid, player_uid)
		);
		mysql_query(buffer);
		mysql_store_result();
		while(mysql_fetch_row(buffer))
			masa += strval(buffer);
		mysql_free_result();

		if((masa + weight) <= Player(playerid, player_stamina)*50)
		    return ShowInfo(playerid, red"Nie masz wystarczająco siły, by podnieść ten przedmiot!");
	}*/
	
	new sound;
	switch(Item(playerid, 0, item_type))
	{
		case item_ammo:
		{
		    new table[] = {itm_sound_ammo_up};
		    sound = table[random(sizeof table)];
		}
		case item_cloth:
		{
		    new table[] = {itm_sound_cloth_up};
		    sound = table[random(sizeof table)];
		}
		case item_weapon:
		{
			switch(Item(playerid, 0, item_value)[ 0 ])
			{
			    case 2..9, 15: // Male
			    {
			        sound = itm_sound_male_up;
			    }
			    case 30..31, 33..34, 25..27: // Assault | Shotguns | Rifle
			    {
			        sound = itm_sound_big_up;
			    }
			    case 22..24, 32, 28, 29: // Handguns | Machine-pistols
			    {
			        sound = itm_sound_gunssmall_up;
			    }
			    case 16..18, 39, 40: // throw | granat
			    {
			        sound = itm_grenade_up;
			    }
			    default:
				{
				    new table[] = {itm_sound_gen_down};
					sound = table[random(sizeof table)];
				}
			}
		}
		default:
		{
		    new table[] = {itm_sound_gen_up};
		    sound = table[random(sizeof table)];
		}
	}
	if(sound && Audio_IsClientConnected(playerid))
		Audio_Play(playerid, sound);

	#if STREAMER
		for(new count; count < MAX_OBJECTS; count++)
		{
		    if(Object(count, obj_objID) == INVALID_OBJECT_ID) continue;
		    if(!Streamer_IsInArrayData(STREAMER_TYPE_OBJECT, Object(count, obj_objID), E_STREAMER_WORLD_ID, Player(playerid, player_vw))) continue;
			if(Object(count, obj_owner)[ 0 ] != object_owner_item) continue;
			if(Object(count, obj_owner)[ 1 ] != Item(playerid, 0, item_uid)) continue;

	    	format(buffer, sizeof buffer,
	    	    "DELETE FROM `surv_objects` WHERE `uid` = '%d'",
	    	    Streamer_GetIntData(STREAMER_TYPE_OBJECT, Object(count, obj_objID), E_STREAMER_EXTRA_ID)
			);
			mysql_query(buffer);
			
			DestroyDynamicObject(Object(count, obj_objID));

            for(new eObjects:i; i < eObjects; i++)
				Object(count, i) = 0;
			Object(count, obj_objID) = INVALID_OBJECT_ID;
			break;
		}
	#else
		foreach(Player, i)
		{
			if(Player(playerid, player_vw) != Player(i, player_vw)) continue;
		    for(new objectid = 1; objectid != MAX_OBJECTS; objectid++)
		    {
		        if(Object(i, objectid, obj_objID) == INVALID_OBJECT_ID) continue;
		        if(Object(i, objectid, obj_owner)[ 0 ] != object_owner_item) continue;
		        if(Object(i, objectid, obj_owner)[ 1 ] != Item(playerid, 0, item_uid)) continue;

		        DestroyPlayerObject(i, Object(i, objectid, obj_objID));
				for(new eObjects:d; d < eObjects; d++)
					Object(i, objectid, d)		= 0;
				Object(i, objectid, obj_objID) = INVALID_OBJECT_ID;
		    }
		}
	#endif

   	format(buffer, sizeof buffer,
		"UPDATE `surv_items` SET `ownerType`="#item_place_player", `owner`='%d', `X`=0.0, `Y`=0.0, `Z`=0.0, `favorite`='0', `vw`='0' WHERE `uid`='%d'",
		Player(playerid, player_uid),
		Item(playerid, 0, item_uid)
	);
    mysql_query(buffer);
    
	ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.1, 0, 0, 0, 0, 0);
	
    if(Player(playerid, player_option) & option_me)
	{
		format(buffer, sizeof buffer, "* %s podnosi \"%s\".", NickName(playerid), Item(playerid, 0, item_name));
		serwerme(playerid, buffer);
	}

	if(IsPlayerVisibleItems(playerid))
	    ShowPlayerItems(playerid, Player(playerid, player_item_site));

	ClearItem(playerid, 0);
	return 1;
}

FuncPub::Items_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case 2:
		{
		    if(!response) return 1;
		    new itemuid = strval(inputtext);
		    OnPlayerPickUpItem(playerid, itemuid);
		}
		case 15:
		{
		    if(!response) return 1;
		    new itemuid = strval(inputtext);
		    new act_item = GetPVarInt(playerid, "item-uid");
		    new string[ 126 ];
		    new ammo;
		    
			format(string, sizeof string, "SELECT `v2` FROM `surv_items` WHERE `uid` = '%d'", act_item);
			mysql_query(string);
			mysql_store_result();
			ammo = mysql_fetch_int();
			mysql_free_result();

			format(string, sizeof string, "UPDATE `surv_items` SET `v2` = `v2` + '%d' WHERE `uid` = '%d'", ammo, itemuid);
			mysql_query(string);

		    format(string, sizeof string, "DELETE FROM `surv_items` WHERE `uid` = '%d'", act_item);
			mysql_query(string);
			
			if(IsPlayerVisibleItems(playerid))
			    ShowPlayerItems(playerid, Player(playerid, player_item_site));
		}
		case 17:
		{
		    if(!response) return 1;
		    new index = GetPVarInt(playerid, "attach-item-slot");
			switch(listitem)
			{
			    case 0:
			    {
			        SetPVarInt(playerid, "attach-edit", 1);
			        EditAttachedObject(playerid, index);
			    }
			    case 1:
			    {
			        new string[ 80 ];

			        RemovePlayerAttachedObject(playerid, index);

					format(string, sizeof string,
					    "DELETE FROM `surv_attach` WHERE `playeruid` = '%d' AND `itemuid` = '%d'",
					    Player(playerid, player_uid),
					    Attach(playerid, index, attach_itemuid)
					);
					mysql_query(string);

					format(string, sizeof string,
						"UPDATE `surv_items` SET `used` = 0 WHERE `uid` = '%d'",
						Attach(playerid, index, attach_itemuid)
					);
					mysql_query(string);

					for(new eAttachObject:d; d < eAttachObject; d++)
				    	Attach(playerid, index, d) = 0;

					DeletePVar(playerid, "attach-slot");
				}
			}
		}
		case 36:
		{
		    if(!response) return 1;
			new craftuid = strval(inputtext);
			new bool:is_object;
			new string[ 200 ];
			
			format(string, sizeof string, "SELECT * FROM `surv_craft` WHERE `uid` = '%d'", craftuid);
            mysql_query(string);
            mysql_store_result();
            mysql_fetch_row(string);
            new type,
				value[ 2 ],
				Float:value3,
				name[ MAX_ITEM_NAME ],
				weight,
				objectmodel;
            sscanf(string, "p<|>{dd}da<d>[2]fs["#MAX_ITEM_NAME"]dd",
				type,
				value,
				value3,
				name,
				weight,
				objectmodel
			);
            mysql_free_result();
            if(objectmodel)
            {
                #if STREAMER
		    		// TODO
				#else
					for(new objectid; objectid != MAX_OBJECTS; objectid++)
					{
					    if(!Object(playerid, objectid, obj_uid))
							continue;
						if(!IsPlayerInRangeOfPoint(playerid, 10.0, Object(playerid, objectid, obj_position)[ 0 ], Object(playerid, objectid, obj_position)[ 1 ], Object(playerid, objectid, obj_position)[ 2 ]))
							continue;
						if(Object(playerid, objectid, obj_model) != objectmodel)
						    continue;
						is_object = true;
						break;
					}
				#endif
				if(!is_object) return ShowInfo(playerid, red"Nie jesteś przy odpowiednim obiekcie!");
			}
			ShowInfo(playerid, green"Przedmiot stworzony pomyślnie!");
            Createitem(playerid, type, value[ 0 ], value[ 1 ], value3, name, weight);

			format(string, sizeof string, "DELETE FROM `surv_items` WHERE `used` = 2 AND `ownerType` = "#item_place_player" AND `owner` = '%d' AND `type` = "#item_craft"", Player(playerid, player_uid));
            mysql_query(string);

			if(IsPlayerVisibleItems(playerid))
			    ShowPlayerItems(playerid, Player(playerid, player_item_site));
		}
		case 47:
		{
		    if(!response) return 1;
		    new string[ 126 ],
				itemuid = GetPVarInt(playerid, "cd-uid"),
				cduid;
				
		    mysql_real_escape_string(inputtext, inputtext);
		    format(string, sizeof string, "INSERT INTO `surv_cd` VALUES (NULL, '%s')", inputtext);
		    mysql_query(string);
		    
		    cduid = mysql_insert_id();
		    format(string, sizeof string, "UPDATE `surv_items` SET `v1` = '%d' WHERE `uid` = '%d'", cduid, itemuid);
		    mysql_query(string);
		    
		    ShowInfo(playerid, green"Adres płyty zapisany pomyślnie!");
		    
		    DeletePVar(playerid, "cd-uid");
		}
		case 58:
		{
		    if(!response) return 1;
			if(strfind(inputtext, "muzykę", true) != -1)
			{
  				new itemuid = GetPVarInt(playerid, "sound-uid");
			    if(Player(playerid, player_cdplayer))
			    {
			        Audio_Stop(playerid, Player(playerid, player_cdplayer_sound));
			        Player(playerid, player_cdplayer_sound) = 0;
			        Player(playerid, player_cdplayer) = 0;
			        
			        GameTextForPlayer(playerid, "~b~~h~Muzyka wylaczona!", 3000, 1);

					new string[ 60 ];
					format(string, sizeof string,
						"UPDATE `surv_items` SET `used` = '0' WHERE `uid` = '%d'",
						itemuid
					);
					mysql_query(string);
				}
			    else
			    {
			    	new value1 = GetPVarInt(playerid, "sound-v1");
			    	if(value1)
			    	{
			    	    new string[ 64 ];
						format(string, sizeof string,
							"SELECT `url` FROM `surv_cd` WHERE `uid` = '%d'",
							value1
						);
						mysql_query(string);
						mysql_store_result();
						mysql_fetch_row(string);
						mysql_free_result();

						Player(playerid, player_cdplayer_sound) = Audio_PlayStreamed(playerid, string);
			        	Player(playerid, player_cdplayer) = itemuid;
			        	
			        	GameTextForPlayer(playerid, "~b~~h~Muzyka wlaczona!", 3000, 1);
			        	
						format(string, sizeof string,
							"UPDATE `surv_items` SET `used` = '1' WHERE `uid` = '%d'",
							itemuid
						);
						mysql_query(string);
			    	}
			    	else
			    	{
			    	    ShowPlayerCD(playerid, 59);
			    	}
			    }
			}
			else if(DIN(inputtext, "Zmień utwór"))
			{
			    ShowPlayerCD(playerid, 59);
				SetPVarInt(playerid, "sound-change", 1);
			}
		}
		case 59:
		{
		    if(!response) return 1;
		    new itemuid = GetPVarInt(playerid, "sound-uid"),
		        cduid = strval(inputtext),
				string[ 126 ];
			format(string, sizeof string,
				"SELECT surv_cd.* FROM `surv_cd` JOIN `surv_items` ON surv_items.v1 = surv_cd.uid WHERE surv_items.uid = '%d'",
				cduid
			);
			mysql_query(string);
			mysql_store_result();
			mysql_fetch_row(string);
			mysql_free_result();
			new uid,
				url[ 64 ];
			sscanf(string, "p<|>ds[64]", uid, url);
			
			if(isnull(url))
			    return ShowInfo(playerid, red"Płyta jest pusta!");

			Player(playerid, player_cdplayer_sound) = Audio_PlayStreamed(playerid, url);
            Player(playerid, player_cdplayer) = itemuid;

			format(string, sizeof string,
				"UPDATE `surv_items` SET `v1` = '%d', `used` = '1' WHERE `uid` = '%d'",
				uid,
				itemuid
			);
			mysql_query(string);

        	if(GetPVarInt(playerid, "sound-change"))
        		GameTextForPlayer(playerid, "~b~~h~Utwor zmieniony!", 3000, 1);
			else
        		GameTextForPlayer(playerid, "~b~~h~Muzyka wlaczona!", 3000, 1);
		}
		case 78:
		{
		    if(!response) return 1;
			new itemuid = strval(inputtext),
			    string[ 126 ];
			    
			format(string, sizeof string,
				"UPDATE `surv_items` SET `ownerType` = '"#item_place_player"', `owner` = '%d' WHERE `uid` = '%d'",
			    Player(playerid, player_uid),
			    itemuid
			);
			mysql_query(string);
			
			if(IsPlayerVisibleItems(playerid))
			    ShowPlayerItems(playerid, Player(playerid, player_item_site));
		}
		case 83:
		{
		    if(!response) return 1;
		    new string[ 256 ];
		    mysql_real_escape_string(inputtext, inputtext);
		    format(string, sizeof string,
		        "INSERT INTO `surv_karteczki` VALUES (NULL, '%s', '"#kart_type_item"', '%d', UNIX_TIMESTAMP())",
				inputtext,
				GetPVarInt(playerid, "notes-uid")
			);
			mysql_query(string);
			ShowInfo(playerid, green"Wpis dodany!");
			
			DeletePVar(playerid, "notes-uid");
		}
		case 84:
		{
		    if(!response) return 1;
		    if(strfind(inputtext, "Dodaj nowy wpis", true) != -1)
		    {
		        Dialog::Output(playerid, 83, DIALOG_STYLE_INPUT, IN_HEAD" "white"» "grey"Notes", white"Wpisz niżej tekst, aby stworzyć notatkę!", "Zapisz", "Zamknij");
		    }
		    else
		    {
		        new uid = strval(inputtext),
			        string[ 600 ],
			        query[ 160 ],
					owner[ 2 ],
					timeAgo[ 32 ],
					unix_time;
				format(query, sizeof query,
				    "SELECT * FROM `surv_karteczki` WHERE `uid` = '%d'",
				    uid
				);
				mysql_query(query);
				mysql_store_result();
				mysql_fetch_row(string);
				mysql_free_result();

				sscanf(string, "p<|>{d}s[512]a<d>[2]d",
				    string,
				    owner,
				    unix_time
				);
			    decodepl(string);
				char_replace(string, "|", "\n");
				ReturnTimeAgo(unix_time, timeAgo);

				format(string, sizeof string,
				    "%s\n\n\t\t\t\tNapisano: %s",
					string,
					timeAgo
				);
				
				SetPVarInt(playerid, "karteczka-uid", uid);
				Dialog::Output(playerid, 85, DIALOG_STYLE_MSGBOX, IN_HEAD" "white"» "grey"Notes", string, "Wróć", "Wyrwij");
		    }
		}
		case 85:
		{
		    if(!response)
		    {
		        new uid = GetPVarInt(playerid, "karteczka-uid"),
					string[ 126 ];
		        // wyrywanie
		        format(string, sizeof string,
					"UPDATE `surv_karteczki` SET `authorType` = '"#kart_type_player"', `author` = '%d' WHERE `uid` = '%d'",
					Player(playerid, player_uid),
					uid
				);
				mysql_query(string);
				
				Createitem(playerid, item_kartka, uid, 0, 0.0, "Karteczka", 0);
				
				if(Player(playerid, player_option) & option_me)
				{
				    format(string, sizeof string, "* %s wyrywa karteczke z notesu.", NickName(playerid));
					serwerme(playerid, string);
				}
				
		        DeletePVar(playerid, "notes-uid");
		        DeletePVar(playerid, "karteczka-uid");
		    }
		    else
		    {
		        new notes_uid = GetPVarInt(playerid, "notes-uid"),
					query[ 600 ],
					string[ 512 ],
					count;

				format(query, sizeof query,
				    "SELECT `uid`, `text` FROM `surv_karteczki` WHERE `authorType` = '"#kart_type_item"' AND `author` = '%d'",
				    notes_uid
				);
				mysql_query(query);
				mysql_store_result();
			    while(mysql_fetch_row(query))
			    {
					static uid,
						text[ 512 ],
						len;

					sscanf(query, "p<|>ds[512]",
						uid,
						text
					);
					len = strlen(text);
					if(len >= max_c)
					{
					    strdel(text, max_c, len);
					    strcat(text, "...");
					}
					format(string, sizeof string, "%s%d\t%s\n", string, uid, text);
					count++;
			    }
				mysql_free_result();
				strcat(string, grey"------------------------\n");
				strcat(string, "Dodaj nowy wpis");
				SetPVarInt(playerid, "notes-uid", notes_uid);

			    if(!count) Dialog::Output(playerid, 83, DIALOG_STYLE_INPUT, IN_HEAD" "white"» "grey"Notes", white"Notes jest pusty.\nWpisz niżej tekst, aby stworzyć pierwszą notatkę!", "Zapisz", "Zamknij");
			    else Dialog::Output(playerid, 84, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Notes", string, "Wybierz", "Zamknij");

		        DeletePVar(playerid, "karteczka-uid");
		    }
		}
		case 127:
		{
		    if(!response) return 1;
		    if(!listitem) return ShowPlayerItems(playerid, 0);
		    new itemuid = strval(inputtext);
		    Item(playerid, 0, item_uid) = itemuid;
		    
		    new string[ 64 ], query[ 126 ];
		    format(query, sizeof query,
		        "SELECT `name`, `used`, `favorite`, `type`, `v1`, `v2`, `v3` FROM `surv_items` WHERE `uid` = '%d'",
		        itemuid
			);
		    mysql_query(query);
		    mysql_store_result();
		    mysql_fetch_row(string);
		    mysql_free_result();
			sscanf(string, "p<|>s[" #MAX_ITEM_NAME "]iiia<i>[2]f",
				Item(playerid, 0, item_name),
				Item(playerid, 0, item_used),
				Item(playerid, 0, item_favorite),
				Item(playerid, 0, item_type),
				Item(playerid, 0, item_value),
				Item(playerid, 0, item_value3)
			);
			
			new buffer[ 126 ];
			strcat(buffer, "1. Użyj\n");
			strcat(buffer, "2. Informacje\n");
			strcat(buffer, "3. Odłóż\n");
			strcat(buffer, "4. Oferuj\n");
			strcat(buffer, "5. Daj\n");
			strcat(buffer, "6. Włóż\n");
			strcat(buffer, "7. Nazwa\n");
			strcat(buffer, "8. Ulubiony\n");
            if(Item(playerid, 0, item_used) == 2)
				strcat(buffer, "9. Odznacz\n");
			else
                strcat(buffer, "9. Zaznacz\n");
			//strcat(buffer, "10. Zniszcz\n");
			
			Dialog::Output(playerid, 128, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Przedmiot", buffer, "Wybierz", "Wróć");
		}
		case 128:
		{
		    if(!response)
		    {
		        ClearItem(playerid, 0);
		        ShowPlayerItems(playerid, 0);
		        return 1;
		    }
			switch(strval(inputtext))
		    {
		        case 1:
		        {
					// Use
					switch(Item(playerid, 0, item_type))
					{
					    case item_weapon:
					    {
					        if(Player(playerid, player_option) & option_me)
					        	Dialog::Output(playerid, 129, DIALOG_STYLE_INPUT, IN_HEAD" "white"» "grey"Przedmiot", white"Podaj miejsce z którego broń ma być wyciągnięta/schowana.", "Dalej", "Zamknij");
							else
							    OnPlayerUseItem(playerid, 0, "");
						}
						case item_megafon:
					        Dialog::Output(playerid, 129, DIALOG_STYLE_INPUT, IN_HEAD" "white"» "grey"Przedmiot", white"Podaj treść.\n\nSyntax: /megafon [Treść]", "Dalej", "Zamknij");
						case item_document, item_leki, item_component, item_element, item_vehitem, item_worek, item_knebel:
						{
						    new buffer[ 512 ];
						    format(buffer, sizeof buffer, grey"%d\t%s\n", playerid, NickName(playerid));
						    foreach(Player, i)
						    {
						        if(Player(i, player_vw) != Player(playerid, player_vw)) continue;
						        if(!OdlegloscMiedzyGraczami(5.0, playerid, i)) continue;
						        if(i == playerid) continue;
						        
						        format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, i, NickName(i));
						    }
						    Dialog::Output(playerid, 131, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Przedmiot", buffer, "Dalej", "Zamknij");
						}
						default:
							OnPlayerUseItem(playerid, 0, "");
					}
		        }
		        case 2:
		        {
		            // Info
		            ShowItemInfo(playerid, 0);
		        }
		        case 3:
		        {
		            // Wyrzuć
		            OnPlayerRemoveItem(playerid, 0);
		        }
		        case 4:
		        {
					if(Item(playerid, 0, item_used) == 1)
					    return ShowInfo(playerid, red"Nie możesz oferować używanego przedmiotu!");
				    new buffer[ 512 ];
				    foreach(Player, i)
				    {
				        if(Player(i, player_vw) != Player(playerid, player_vw)) continue;
				        if(!OdlegloscMiedzyGraczami(10.0, playerid, i)) continue;
				        if(i == playerid) continue;

				        format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, i, NickName(i));
				    }
				    if(isnull(buffer)) ShowInfo(playerid, red"Nikogo nie ma w pobliżu!");
				    else Dialog::Output(playerid, 150, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Przedmiot", buffer, "Dalej", "Zamknij");
		            // Oferuj
		        }
		        case 5:
		        {
					if(Item(playerid, 0, item_used) == 1)
					    return ShowInfo(playerid, red"Nie możesz oferować używanego przedmiotu!");
				    new buffer[ 512 ];
				    foreach(Player, i)
				    {
				        if(Player(i, player_vw) != Player(playerid, player_vw)) continue;
				        if(!OdlegloscMiedzyGraczami(10.0, playerid, i)) continue;
				        if(i == playerid) continue;

				        format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, i, NickName(i));
				    }
				    if(isnull(buffer)) ShowInfo(playerid, red"Nikogo nie ma w pobliżu!");
				    else Dialog::Output(playerid, 149, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Przedmiot", buffer, "Dalej", "Zamknij");
		            // Daj
		        }
		        case 6:
		        {
		            if(!Player(playerid, player_item_selected))
		    			return ShowInfo(playerid, red"Nie zaznaczyłeś żadnego przedmiotu!");

					new query[ 126 ],
						buffer[ 256 ];
					format(query, sizeof query,
						"SELECT `uid`, `name` FROM `surv_items` WHERE `ownerType` = '"#item_place_player"' AND `owner` = '%d' AND `type` = '"#item_pack"'",
						Player(playerid, player_uid)
					);
					mysql_query(query);
					mysql_store_result();
					while(mysql_fetch_row(query))
					{
					    static uid,
							name[ MAX_ITEM_NAME ];
							
					    sscanf(query, "p<|>ds["#MAX_ITEM_NAME"]",
							uid,
							name
						);
						format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, uid, name);
					}
					if(isnull(buffer)) ShowInfo(playerid, red"Nie masz żadnego przedmiotu do trzymania innych!");
					else Dialog::Output(playerid, 133, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Przedmiot", buffer, "Wybierz", "Zamknij");
		        }
		        case 7:
		        {
		            // Nazwa
		            Dialog::Output(playerid, 130, DIALOG_STYLE_INPUT, IN_HEAD" "white"» "grey"Przedmiot", white"Podaj nową nazwę przedmiotu", "Dalej", "Zamknij");
		        }
		        case 8:
		        {
		            // Ulubiony
		            OnPlayerAddItemToFavorite(playerid, 0);
		            ShowPlayerItems(playerid, 0);
		        }
		        case 9:
		        {
		            // Wybierz
		            OnPlayerSelectItem(playerid, 0);
		            ShowPlayerItems(playerid, 0);
		        }
		        case 10:
		        {
		            // Zniszcz
		            OnItemDestroy(playerid, 0);
		        }
		    }
		}
		case 129:
		{
		    if(!response)
		    {
		        ClearItem(playerid, 0);
		        ShowPlayerItems(playerid, 0);
		        return 1;
		    }
		    OnPlayerUseItem(playerid, 0, inputtext);
		}
		case 130:
		{
		    if(!response)
		    {
		        ClearItem(playerid, 0);
		        ShowPlayerItems(playerid, 0);
		        return 1;
		    }
	        if(!(3 <= strlen(inputtext)))
				return Dialog::Output(playerid, 130, DIALOG_STYLE_INPUT, IN_HEAD" "white"» "grey"Przedmiot", white"Podaj nową nazwę przedmiotu", "Dalej", "Zamknij");
	        if(!(strlen(inputtext) <= MAX_ITEM_NAME))
				return Dialog::Output(playerid, 130, DIALOG_STYLE_INPUT, IN_HEAD" "white"» "grey"Przedmiot", white"Podaj nową nazwę przedmiotu", "Dalej", "Zamknij");
            OnItemNameChange(playerid, 0, inputtext);
		}
		case 131:
		{
		    if(!response)
		    {
		        ClearItem(playerid, 0);
		        ShowPlayerItems(playerid, 0);
		        return 1;
		    }
		    switch(Item(playerid, 0, item_type))
		    {
		        case item_component, item_element, item_vehitem:
		        {
		            SetPVarInt(playerid, "item-victimid", strval(inputtext));
		            Dialog::Output(playerid, 132, DIALOG_STYLE_INPUT, IN_HEAD" "white"» "grey"Przedmiot", white"Podaj cenę", "Dalej", "Zamknij");
				}
				case item_document:
				{
				    if(strval(inputtext) == playerid) OnPlayerUseItem(playerid, 0, "");
				    else OnPlayerUseItem(playerid, 0, inputtext);
				}
				default:
					OnPlayerUseItem(playerid, 0, inputtext);
			}
		}
		case 132:
		{
		    if(!response)
		    {
		        ClearItem(playerid, 0);
		        ShowPlayerItems(playerid, 0);
		        return 1;
		    }
		    new victimid = GetPVarInt(playerid, "item-victimid");
		    new out[ 64 ];
		    format(out, sizeof out, "%d %s", victimid, inputtext);
		    OnPlayerUseItem(playerid, 0, out);
		    DeletePVar(playerid, "item-victimid");
		}
		case 133:
		{
		    if(!response)
		    {
		        ClearItem(playerid, 0);
		        ShowPlayerItems(playerid, 0);
		        return 1;
		    }
		    new itemuid = strval(inputtext);
		    OnPlayerPutInItem(playerid, itemuid);
		}
		case 149:
		{
		    if(!response)
		    {
		        ClearOffer(playerid);
		        ClearItem(playerid, 0);
		        ShowPlayerItems(playerid, 0);
		        return 1;
		    }
		    new string[ 80 ];
		    format(string, sizeof string,
		        "UPDATE `surv_items` SET `used` = '2' WHERE `uid` = '%d'",
		        Item(playerid, 0, item_uid)
			);
			mysql_query(string);
			new victimid = strval(inputtext);
			if(playerid == victimid)
		    	return ShowInfo(playerid, red"Nie możesz sprzedać czegoś sobie!");

			Offer(playerid, offer_type) 		= offer_type_item;
			Offer(playerid, offer_player) 		= victimid;
			Offer(playerid, offer_active)       = true;

			Offer(victimid, offer_type) 		= offer_type_item;
			Offer(victimid, offer_player) 		= playerid;
			Offer(victimid, offer_active)       = true;

	        ShowPlayerOffer(playerid, victimid);
		}
		case 150:
		{
		    if(!response)
		    {
		        ClearOffer(playerid);
		        ClearItem(playerid, 0);
		        ShowPlayerItems(playerid, 0);
		        return 1;
		    }
		    new victimid = strval(inputtext);
			if(playerid == victimid)
		    	return ShowInfo(playerid, red"Nie możesz sprzedać czegoś sobie!");
			Offer(playerid, offer_type) 		= offer_type_item;
			Offer(playerid, offer_player) 		= victimid;

			Offer(victimid, offer_type) 		= offer_type_item;
			Offer(victimid, offer_player) 		= playerid;
			
			Dialog::Output(playerid, 151, DIALOG_STYLE_INPUT, IN_HEAD" "white"» "grey"Przedmiot", "Podaj cene za którą chcesz sprzedać przedmiot:", "Dalej", "Zamknij");
		}
		case 151:
		{
		    if(!response)
		    {
		        ClearOffer(playerid);
		        ClearItem(playerid, 0);
		        ShowPlayerItems(playerid, 0);
		        return 1;
		    }
		    new Float:money = floatstr(inputtext);
			if(money <= 0)
			    return Dialog::Output(playerid, 151, DIALOG_STYLE_INPUT, IN_HEAD" "white"» "grey"Przedmiot", "Podaj cene za którą chcesz sprzedać przedmiot:", "Dalej", "Zamknij");

		    new string[ 80 ];
		    format(string, sizeof string,
		        "UPDATE `surv_items` SET `used` = '2' WHERE `uid` = '%d'",
		        Item(playerid, 0, item_uid)
			);
			mysql_query(string);
			
		    new victimid = Offer(playerid, offer_player);
			Offer(playerid, offer_cash) 		= money;
			Offer(playerid, offer_active)       = true;

            Offer(victimid, offer_cash) 		= Offer(playerid, offer_cash);
			Offer(victimid, offer_active)       = true;

	        ShowPlayerOffer(playerid, victimid);
		}
		case 159:
		{
		    new numer = GetPVarInt(playerid, "sim-numer"),
		        itm_uid = GetPVarInt(playerid, "sim-uid");
			DeletePVar(playerid, "sim-numer");
			DeletePVar(playerid, "sim-uid");
			if(!response) return 1;
			
			new phone = strval(inputtext);
			new string[ 126 ];
			format(string, sizeof string,
			    "UPDATE `surv_items` SET `v1` = '%d' WHERE `uid` = '%d'",
			    numer,
			    phone
			);
			mysql_query(string);
			
			format(string, sizeof string,
			    "UPDATE `surv_items` SET `ownerType` = '"#item_place_item"', `owner` = '%d' WHERE `uid` = '%d'",
			    phone,
			    itm_uid
			);
			mysql_query(string);
			
			ShowCMD(playerid, "Karta została umieszczona poprawnie!");
			if(IsPlayerVisibleItems(playerid))
			    ShowPlayerItems(playerid, Player(playerid, player_item_site));
		}
	}
	
	return 1;
}

FuncPub::ClearItem(playerid, itemid)
{
	for(new eItems:d; d < eItems; d++)
    	Item(playerid, itemid, d) = 0;
	return 1;
}

FuncPub::Items_OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(Player(playerid, player_rolki) && !IsPlayerInAnyVehicle(playerid))
	{
		if(HOLDING(KEY_SPRINT))
		{
			ApplyAnimation(playerid, "SKATE", "skate_run", 5.1, 1, 1, 1, 1, 1);
		}
		if(RELEASED(KEY_SPRINT))
		{
			ApplyAnimation(playerid, "SKATE", "skate_idle", 1, 1, 1, 1, 1, 1);
		}
	}
	if(IsPlayerVisibleItems(playerid))
	{
		if(!Player(playerid, player_premium) && !Player(playerid, player_adminlvl)) return 1;
	    if(PRESSED(KEY_ANALOG_LEFT))
	    {
		    ShowPlayerItems(playerid, Player(playerid, player_item_site)-(MAX_ITEMS-1));
	    }
	    else if(PRESSED(KEY_ANALOG_RIGHT))
	    {
		    ShowPlayerItems(playerid, Player(playerid, player_item_site)+(MAX_ITEMS-1));
	    }
    }
    if(Player(playerid, player_drug) && !IsPlayerInAnyVehicle(playerid))
    {
        if(Player(playerid, player_drug) == nark_type_marycha || Player(playerid, player_drug) == nark_type_crack)
        {
	        if(PRESSED(KEY_FIRE) && GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_SMOKE_CIGGY)
	        {
	            if(!GetPVarInt(playerid, "nark-timer"))
	            	SetPVarInt(playerid, "nark-timer", SetTimerEx("Buch", 2500, false, "d", playerid));
	        }
	        else if(PRESSED(KEY_SECONDARY_ATTACK) || GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_SMOKE_CIGGY)
	        {
	            SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	            Player(playerid, player_drug) = nark_type_none;
	            ClearNark(playerid);
	        }
        }
    }
	return 1;
}

FuncPub::Buch(playerid)
{
	DeletePVar(playerid, "nark-timer");
	Player(playerid, player_druglvl) += Nark(playerid, nark_druglvl);
	Nark(playerid, nark_buch)++;
	switch(Nark(playerid, nark_buch))
	{
	    case 3: Chat::Output(playerid, COLOR_DO, "* Czujesz się zrelaksowany *");
	    case 5:
	    {
			if(!Player(playerid, player_drug_timer))
			    Player(playerid, player_drug_timer) = SetTimerEx("NarkoDzialanie", 60*1000, false, "dd", playerid, 0);
	    }
	    case 10:
	    {
		    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
		    Player(playerid, player_drug) = nark_type_none;
		    ClearNark(playerid);
	    }
	}
	return 1;
}

FuncPub::NarkoDzialanie(playerid, count)
{
    count++;
    SetPlayerHealth(playerid, Player(playerid, player_hp) += 2.0);
    if(random(3) == 1)
	{
	    new str[ 64 ];
	    format(str, sizeof str, "* %s uśmiecha się, patrząc przed siebie.", NickName(playerid));
	    serwerme(playerid, str);
	}
	else if(random(3) == 1)
	{
	    OnPlayerText(playerid, ":D");
	}
	else if(random(3) == 1)
	{
	    OnPlayerText(playerid, "xd");
	}
    if(count == 10)
    {
        KillTimer(Player(playerid, player_drug_timer));
        Player(playerid, player_drug_timer) = 0;
        return 1;
    }
	SetTimerEx("NarkoDzialanie", 2*60*1000, false, "dd", playerid, count);
	return 1;
}

FuncPub::ClearNark(playerid)
{
	for(new eNark:d; d < eNark; d++)
    	Nark(playerid, d) = 0;
	return 1;
}

FuncPub::Items_OnPlayerUpdate(playerid)
{
	for(new x; x != MAX_WEAPON; x++)
	{
		if(Weapon(playerid, x, weapon_model))
		{
			if(Weapon(playerid, x, weapon_model) == GetPlayerWeapon(playerid))
			{
				RemovePlayerAttachedObject(playerid, x);
				Player(playerid, player_used_weapon) = x;
			}
			else
			{
				for(new c; c != sizeof BodyWeapon; c++)
				{
					if(BodyWeapon[ c ][ weapon_id ] != Weapon(playerid, x, weapon_model)) continue;

					SetPlayerAttachedObject(playerid, x, ObjectModel[ BodyWeapon[ c ][ weapon_id] ], BodyWeapon[ c ][ weapon_body ], BodyWeapon[ c ][ weapon_posX ], BodyWeapon[ c ][ weapon_posY ], BodyWeapon[ c ][ weapon_posZ ], BodyWeapon[ c ][ weapon_posrX ], BodyWeapon[ c ][ weapon_posrY ], BodyWeapon[ c ][ weapon_posrZ ]);
					break;
				}
			}
		}
	}
/*	if(Player(playerid, player_weapon)[ 0 ] && Player(playerid, player_weapon)[ 1 ] && GetPlayerWeaponState(playerid) == WEAPONSTATE_NO_BULLETS)
	{
	    new string[ 100 ];
		if(Player(playerid, player_weapon2)[ 0 ] && Player(playerid, player_weapon2)[ 1 ])
		{
	        format(string, sizeof string,
				"UPDATE `surv_items` SET `used` = 0, `v2` = '0' WHERE `uid` = '%d'",
				Player(playerid, player_weapon2)[ 1 ]
			);
			mysql_query(string);
	        Player(playerid, player_weapon2)[ 0 ] = 0;
	        Player(playerid, player_weapon2)[ 1 ] = 0;
		}
        format(string, sizeof string,
			"UPDATE `surv_items` SET `used` = 0, `v2` = '0' WHERE `uid` = '%d'",
			Player(playerid, player_weapon)[ 1 ]
		);
		mysql_query(string);
        Player(playerid, player_weapon)[ 0 ] = 0;
        Player(playerid, player_weapon)[ 1 ] = 0;
	}*/
	
	if(!Player(playerid, player_reload) && Weapon(playerid, Player(playerid, player_used_weapon), weapon_model) && GetPlayerWeaponState(playerid) == WEAPONSTATE_RELOADING && Player(playerid, player_option) & option_me)
	{
		static string[ 64 ];
	    format(string, sizeof string, "* %s zmienia magazynek %s.", NickName(playerid), Weapon(playerid, Player(playerid, player_used_weapon), weapon_name));
	    serwerme(playerid, string);

		SetTimerEx("Weapon_EndReload", 2100, 0, "d", playerid);
	    Player(playerid, player_reload) = true;
	    
	    new soundid;
	    switch(Weapon(playerid, Player(playerid, player_used_weapon), weapon_model))
	    {
	        case 22: // 9mm
	        {
				new table[] = {pistol_reload_sound};
		    	soundid = table[random(sizeof table)];
	        }
	        case 28: // Uzi
	        {
				new table[] = {uzi_reload_sound};
		    	soundid = table[random(sizeof table)];
	        }
	        case 30..31: // AK, M4
	        {
				new table[] = {ak_reload_sound};
		    	soundid = table[random(sizeof table)];
	        }
	        case 33..34: // Rifle
	        {
				new table[] = {rifle_reload_sound};
		    	soundid = table[random(sizeof table)];
	        }
	    }
	    if(!soundid) return 1;
		GetPlayerPos(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]);
	    foreach(Player, id)
	    {
	        if(!Audio_IsClientConnected(id)) continue;
	        static handle;
	        handle = Audio_Play(id, soundid);
	        Audio_Set3DPosition(id, handle, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ], 5.0);
	    }
	    Audio_Play(playerid, soundid);
	}
	return 1;
}

FuncPub::Weapon_EndReload(playerid)
{
    Player(playerid, player_reload) = false;
	return 1;
}

FuncPub::ShowPlayerItems(playerid, page)
{
    if(page < 0)
    {
        GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~<~~r~ Nie ma takiej strony", 3000, 5);
		page = 0;
    }
	new buffer[ 2058 ], // Nazwa
	    numbers[ 40 ], // Numery
	    count,
		string[ 64 ],
		itemid = 1;
		
	if(Player(playerid, player_option) & option_textdraw)
	{
		format(buffer, sizeof buffer,
			"SELECT `uid`, `name`, `used`, `favorite`, `type`, `v1`, `v2`, `v3`, `weight` FROM `surv_items` WHERE `ownerType`="#item_place_player" AND `owner`='%d' ORDER BY `favorite` DESC, `created` DESC LIMIT %d, %d",
			Player(playerid, player_uid),
			page,
			(MAX_ITEMS-1)
		);
		mysql_query(buffer);
		mysql_store_result();
		if(!mysql_num_rows() && page)
		{
		    GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~r~Nie ma takiej strony ~>~", 3000, 5);
			mysql_free_result();
			return 1;
		}
		buffer[ 0 ] = EOS;
		while(mysql_fetch_row_format(string))
		{
			if(itemid == MAX_ITEMS) break;

			ClearItem(playerid, itemid);

		    static used[ 4 ], weg;
			sscanf(string, "p<|>is[" #MAX_ITEM_NAME "]iiia<i>[2]fd",
				Item(playerid, itemid, item_uid),
				Item(playerid, itemid, item_name),
				Item(playerid, itemid, item_used),
				Item(playerid, itemid, item_favorite),
				Item(playerid, itemid, item_type),
				Item(playerid, itemid, item_value),
				Item(playerid, itemid, item_value3),
				weg
			);
			format(numbers, sizeof numbers, "%s%d~n~", numbers, itemid);

			if(Item(playerid, itemid, item_used) == 1) used = "~g~";
			else if(Item(playerid, itemid, item_used) == 2) used = "~r~";
			else if(Item(playerid, itemid, item_favorite)) used = "~y~";
			else used = "~w~";
			
			if(Item(playerid, itemid, item_type) == item_weapon || Item(playerid, itemid, item_type) == item_ammo)
			{
			    if(IsPlayerWeapon(Item(playerid, itemid, item_value)[ 0 ]))
					format(buffer, sizeof buffer, "%s%s%s(%d ammo)~n~", buffer, used, Item(playerid, itemid, item_name), Item(playerid, itemid, item_value)[ 1 ]);
				else
					format(buffer, sizeof buffer, "%s%s%s~n~", buffer, used, Item(playerid, itemid, item_name));
			}
			else if(Item(playerid, itemid, item_type) == item_drugs)
				format(buffer, sizeof buffer, "%s%s%s(%dg)~n~", buffer, used, Item(playerid, itemid, item_name), weg);
			else if(Item(playerid, itemid, item_type) == item_phone)
			{
			    if(Item(playerid, itemid, item_value3))
					format(buffer, sizeof buffer, "%s%s%s ~r~(%d)~n~", buffer, used, Item(playerid, itemid, item_name), floatval(Item(playerid, itemid, item_value3)));
				else
					format(buffer, sizeof buffer, "%s%s%s~n~", buffer, used, Item(playerid, itemid, item_name));
			}
			else
				format(buffer, sizeof buffer, "%s%s%s~n~", buffer, used, Item(playerid, itemid, item_name));

			itemid++;
		}
		mysql_free_result();

		Player(playerid, player_item_site) = page;

		if(isnull(buffer)) return ShowInfo(playerid, red"Nie posiadasz żadnego przedmiotu w ekwipunku.");

		PlayerTextDrawSetString(playerid, Player(playerid, player_item_td)[ 0 ], numbers);
		PlayerTextDrawSetString(playerid, Player(playerid, player_item_td)[ 1 ], buffer);

		format(buffer, sizeof buffer, "SELECT COUNT(*) FROM `surv_items` WHERE `ownerType`="#item_place_player" AND `owner`='%d'", Player(playerid, player_uid));
		mysql_query(buffer);
		mysql_store_result();

		count = mysql_fetch_int();
		count = floatval((count-1)/(MAX_ITEMS-1))+1;

		mysql_free_result();

		format(numbers, sizeof numbers, "~<~ Strona %d/%d ~>~", floatval(Player(playerid, player_item_site)/(MAX_ITEMS-1))+1, count);

		PlayerTextDrawSetString(playerid, Player(playerid, player_item_td)[ 2 ], numbers);

		TextDrawShowForPlayer(playerid, Setting(setting_td_item)[ 0 ]);
		TextDrawShowForPlayer(playerid, Setting(setting_td_item)[ 1 ]);
		TextDrawShowForPlayer(playerid, Setting(setting_td_item)[ 2 ]);
		TextDrawShowForPlayer(playerid, Setting(setting_td_item)[ 3 ]);
		TextDrawShowForPlayer(playerid, Setting(setting_td_item)[ 4 ]);
		TextDrawShowForPlayer(playerid, Setting(setting_td_item)[ 5 ]);
		TextDrawShowForPlayer(playerid, Setting(setting_td_item)[ 6 ]);

		PlayerTextDrawShow(playerid, Player(playerid, player_item_td)[ 0 ]); // Numer
		PlayerTextDrawShow(playerid, Player(playerid, player_item_td)[ 1 ]); // Nazwa
		PlayerTextDrawShow(playerid, Player(playerid, player_item_td)[ 2 ]); // Strona
	}
	else
	{
		format(buffer, sizeof buffer,
			"SELECT `uid`, `name`, `used`, `favorite`, `type`, `v1`, `v2`, `v3`, `weight` FROM `surv_items` WHERE `ownerType`="#item_place_player" AND `owner`='%d' ORDER BY `favorite` DESC, `created` DESC",
			Player(playerid, player_uid)
		);
		mysql_query(buffer);
		mysql_store_result();
		buffer[ 0 ] = EOS;
		while(mysql_fetch_row_format(string))
		{
		    static uid,
				name[ MAX_ITEM_NAME ],
				use,
				favorite,
				type,
				weg,
				value[ 2 ],
				Float:value3;
				
			new used[ 16 ];
			sscanf(string, "p<|>ds["#MAX_ITEM_NAME"]ddda<i>[2]fd",
				uid,
				name,
				use,
				favorite,
				type,
				value,
				value3,
				weg
			);
			
			if(use == 1) used = C_GREEN;
			else if(use == 2) used = red;
			else if(favorite) used = C_YELLOW;
			else used = "";
			

			if(type == item_weapon || type == item_ammo)
			{
			    if(IsPlayerWeapon(value[ 0 ]))
					format(buffer, sizeof buffer, "%s%s%d\t%s (%d ammo)\n", buffer, used, uid, name, value[ 1 ]);
				else
					format(buffer, sizeof buffer, "%s%s%d\t%s\n", buffer, used, uid, name);
			}
			else if(type == item_drugs)
				format(buffer, sizeof buffer, "%s%s%d\t%s (%dg)\n", buffer, used, uid, name, weg);
			else if(type == item_phone)
			{
			    if(value3)
					format(buffer, sizeof buffer, "%s%s%d\t%s (%d)\n", buffer, used, uid, name, floatval(value3));
				else
					format(buffer, sizeof buffer, "%s%s%d\t%s\n", buffer, used, uid, name);
			}
			else
				format(buffer, sizeof buffer, "%s%s%d\t%s\n", buffer, used, uid, name);
		}
		mysql_free_result();
		if(isnull(buffer)) ShowInfo(playerid, red"Nie posiadasz żadnego przedmiotu!");
		else
		{
		    format(buffer, sizeof buffer, grey"UID:\tNazwa:\n%s", buffer);
			Dialog::Output(playerid, 127, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Twoje przedmioty", buffer, "Wybierz", "Zamknij");
		}
	}
	return 1;
}

FuncPub::HideItemsTextDraw(playerid)
{
	TextDrawHideForPlayer(playerid, Setting(setting_td_item)[ 0 ]);
	TextDrawHideForPlayer(playerid, Setting(setting_td_item)[ 1 ]);
	TextDrawHideForPlayer(playerid, Setting(setting_td_item)[ 2 ]);
	TextDrawHideForPlayer(playerid, Setting(setting_td_item)[ 3 ]);
	TextDrawHideForPlayer(playerid, Setting(setting_td_item)[ 4 ]);
	TextDrawHideForPlayer(playerid, Setting(setting_td_item)[ 5 ]);
	TextDrawHideForPlayer(playerid, Setting(setting_td_item)[ 6 ]);
	
	PlayerTextDrawHide(playerid, Player(playerid, player_item_td)[ 0 ]);
	PlayerTextDrawHide(playerid, Player(playerid, player_item_td)[ 1 ]);
	PlayerTextDrawHide(playerid, Player(playerid, player_item_td)[ 2 ]);
	
	for(new i; i != MAX_ITEMS; i++)
		ClearItem(playerid, i);

	new string[ 126 ];
    format(string, sizeof string, "UPDATE `surv_items` SET `used` = '0' WHERE `ownerType` = "#item_place_player" AND `owner` = '%d' AND `used` = '2'", Player(playerid, player_uid));
	mysql_query(string);
	
	Player(playerid, player_item_selected) = 0;
	return 1;
}

FuncPub::DeleteItem(itemuid)
{
	new string[ 50 ];
	format(string, sizeof string,
		"DELETE FROM `surv_items` WHERE `uid` = '%d'",
		itemuid
	);
	mysql_query(string);
	
	foreach(Player, playerid)
	{
	    if(IsPlayerVisibleItems(playerid))
	    {
			for(new i = 1; i != MAX_ITEMS; i++)
			{
			    if(Item(playerid, i, item_uid) == itemuid) continue;
			    if(Item(playerid, i, item_uid))
				{
			    	ShowPlayerItems(playerid, Player(playerid, player_item_site));
					break;
				}
		        HideItemsTextDraw(playerid);
				return 1;
			}
		}
		#if STREAMER
		    // TODO
		#else
		    for(new objectid; objectid != MAX_OBJECTS; objectid++)
		    {
		        if(!Object(playerid, objectid, obj_objID)) continue;
		        if(Object(playerid, objectid, obj_owner)[ 0 ] != object_owner_item) continue;
		        if(Object(playerid, objectid, obj_owner)[ 1 ] != itemuid) continue;

		        DestroyPlayerObject(playerid, Object(playerid, objectid, obj_objID));
				for(new eObjects:d; d < eObjects; d++)
					Object(playerid, objectid, d)		= 0;
		    }
	    #endif
	}
	return 1;
}

FuncPub::Createitem(playerid, typ, v1, v2, Float:v3, name[ ], weight)
{
	new string[ 300 ];
	mysql_real_escape_string(name, name);
	EscapePL(name);
	format(string, sizeof string,
		"INSERT INTO `surv_items` (`ownerType`, `owner`, `type`, `v1`, `v2`, `v3`, `name`, `weight`) VALUES ("#item_place_player", '%d', '%d', '%d', '%d', '%f', '%s', '%d')",
		Player(playerid, player_uid),
		typ,
		v1, v2, v3,
		name,
		weight
	);
	mysql_query(string);
	if(IsPlayerVisibleItems(playerid))
	    ShowPlayerItems(playerid, Player(playerid, player_item_site));
	return mysql_insert_id();
}

FuncPub::HavePlayerItem(playerid, typ)
{
	new num,
		uid,
		string[ 120 ];
	format(string, sizeof string,
		"SELECT `uid` FROM `surv_items` WHERE `ownerType` = "#item_place_player" AND `owner` = '%d' AND `type` = '%d'",
		Player(playerid, player_uid),
		typ
	);
	mysql_query(string);
	mysql_store_result();
	num = mysql_num_rows();
	uid = mysql_fetch_int();
	mysql_free_result();
	if(num)
	    return uid;
	return 0;
}

FuncPub::HavePlayerItemUID(playerid, uid)
{
	new num,
		string[ 120 ];
	format(string, sizeof string,
		"SELECT 1 FROM `surv_items` WHERE `ownerType` = "#item_place_player" AND `owner` = '%d' AND `uid` = '%d'",
		Player(playerid, player_uid),
		uid
	);
	mysql_query(string);
	mysql_store_result();
	num = mysql_num_rows();
	mysql_free_result();
	if(num)
	    return true;
	return false;
}

stock GetWeaponAmmo(playerid, weaponid)
{
	new weap,
		ammo,
		slot;
	switch(weaponid)
	{
		case 0,1:                       slot=0;
		case 2,3,4,5,6,7,8,9:   		slot=1;
		case 22,23,24:                  slot=2;
		case 25,26,27:                  slot=3;
		case 28,29,32:                  slot=4;
		case 30,31:                     slot=5;
		case 33,34:                     slot=6;
		case 35,36,37,38:               slot=7;
		case 16,17,18,39:               slot=8;
		case 41,42,43:                  slot=9;
		case 10,11,12,13,14,15: 		slot=10;
		case 44,45,46:                  slot=11;
		case 40:                        slot=12;
	}
	GetPlayerWeaponData(playerid, slot, weap, ammo);
	return ammo;
}

#if STREAMER
FuncPub::ObjectItem(type, v1)
#else
FuncPub::ObjectItem(playerid, type, v1, v2, Float:x, Float:y, Float:z)
#endif
{
	/*
	1486 	- Wino /
	1487 	- Wino 2 /
	1509 	- Wino 3 /
	1484    - Piwo /
	1546 	- Sprunk /
	19163 	- Maska /
	19138 	- Okulary
	18949   - Czapka
	2967 	- Telefon /
	18634 	- Łom
	18635 	- Młotek
	18641 	- Latarka
	18644 	- Śrubokręt
	1650    - Kanister
	1575    - Paczka
	2663    - Jedzenie /
	3044    - Papieros /
	1851    - Kostka /
	2059    - Śmieci /
	19142   - Kamizelka kulo-odporna
	*/
	new model = 1575;
	#if !STREAMER
	new objid;
	#endif
	switch(type)
	{
	    case item_weapon:
		{
			model = ObjectModel[ v1 ];
		}
		case item_mask: model = 19163;
		case item_kostka: model = 1851;
	    case item_phone:
		{
			model = 2967;
		}
		case item_food:
		{
			model = 2663;
		}
		case item_ciggy:
		{
			model = 3044;
		}
		case item_trash:
		{
			model = 2059;
		}
		case item_attach:
		{
		    model = v1;
		}
		case item_drink:
		{
		    if(v1 == SPECIAL_ACTION_DRINK_WINE) model = 1486;
		    else if(v1 == SPECIAL_ACTION_DRINK_BEER) model = 1484;
		    else/* if(v1 == SPECIAL_ACTION_DRINK_SPRUNK)*/ model = 1546;
		}
		case item_wedka:
		{
		    model = 18632;
		}
	}
	#if STREAMER
		return model;
	#else
	    if(type == item_weapon)
			objid = CreatePlayerObject(playerid, model, x, y, z, 85.0, -809.0, random(360), 200.0);
		else
			objid = CreatePlayerObject(playerid, model, x, y, z, 0, 0, random(360), 200.0);
		return objid;
	#endif
}

Cmd::Input->przedmiot(playerid, params[])
{
	if(!Player(playerid, player_logged) || !Player(playerid, player_spawned))
		return 1;

	new str1[ 64 ],
		str2[ 64 ];
	if(sscanf(params, "s[64]S()[64]", str1, str2))
	{
		if(IsPlayerVisibleItems(playerid)) HideItemsTextDraw(playerid);
		else ShowPlayerItems(playerid, 0);
		return 1;
	}
	if(!strcmp(str1, "podnies", true) || !strcmp(str1, "podnieś", true) || !strcmp(str1, "szukaj", true))
	{
	    new buffer[ 2058 ];
		if(!IsPlayerInAnyVehicle(playerid))
		{
			GetPlayerPos(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]);
			Player(playerid, player_vw) = GetPlayerVirtualWorld(playerid);
		    new string[ 300 ];
		    format(string, sizeof string,
				"SELECT `uid`, `name`, SQRT(((x - %f)  * (x - %f)) + ((y - %f) * (y - %f))) AS dist FROM `surv_items` WHERE `ownerType`="#item_place_none" AND `vw` = '%d' ORDER BY dist",
				Player(playerid, player_position)[ 0 ],
				Player(playerid, player_position)[ 0 ],
				Player(playerid, player_position)[ 1 ],
				Player(playerid, player_position)[ 1 ],
				Player(playerid, player_vw)
			);
			mysql_query(string);
			mysql_store_result();
	        while(mysql_fetch_row(string))
	        {
	        	static uid,
	            	name[ MAX_ITEM_NAME ],
					Float:dist;

				sscanf(string, "p<|>ds["#MAX_ITEM_NAME"]f",
				    uid,
				    name,
				    dist
				);

		  		if(dist < 5.0)
					format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, uid, name);
				else break;
			}
		    mysql_free_result();

			if(!isnull(buffer)) Dialog::Output(playerid, 2, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Przedmioty w okolicy", buffer, "Wybierz", "Zamknij");
			else ShowInfo(playerid, red"W pobliżu nie ma żadnych przedmiotów.");
		}
		else
		{
			new vehid = Player(playerid, player_veh);
		    if(!CanPlayerVehicleDrive(playerid, vehid))
		        return ShowInfo(playerid, red"Nie możesz przeszukać tego pojazdu!");
		        
		    new string[ 126 ];
			format(string, sizeof string,
				"SELECT `uid`, `name` FROM `surv_items` WHERE `ownerType`="#item_place_vehicle" AND `owner`='%d'",
				Vehicle(vehid, vehicle_uid)
			);
			mysql_query(string);
			mysql_store_result();
	        while(mysql_fetch_row(string))
	        {
	            static uid,
	                name[ MAX_ITEM_NAME ];

				sscanf(string, "p<|>ds[24]",
					uid,
					name
				);

				format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, uid, name);
			}
			mysql_free_result();

			if(!isnull(buffer)) Dialog::Output(playerid, 2, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Przedmioty w pojeździe", buffer, "Wybierz", "Zamknij");
			else ShowInfo(playerid, red"W pojeździe nie ma żadnych przedmiotów.");
		}
	}
	else if(!strcmp(str1, "lista", true))
	{
	    new buffer[ 2058 ], string[ 150 ];
	    
		new victimid = playerid;
		if(Player(playerid, player_adminlvl))
		{
			if(!isnull(params)) sscanf(str2, "u", victimid);
		}
		if(!IsPlayerConnected(victimid))
			return NoPlayer(playerid);
			
		format(string, sizeof string, "SELECT `uid`, `name`, `weight`, `used`, `favorite` FROM `surv_items` WHERE `ownerType`="#item_place_player" and `owner`=%d ORDER BY `favorite` DESC", Player(victimid, player_uid));
		mysql_query(string);
		mysql_store_result();
		while(mysql_fetch_row(string))
		{
		    static uid,
				name[ MAX_ITEM_NAME ],
				weight,
		   bool:use,
		   bool:favorite,
				used[ 10 ];
		    
			sscanf(string, "p<|>ds[24]ddd",
				uid,
				name,
				weight,
				use,
				favorite
			);

			if(use) used = C_GREEN;
			else if(favorite) used = C_YELLOW;
			else used = "";

			format(buffer, sizeof buffer, "%s%s%d\t%dg\t%s\n", buffer, used, uid, weight, name_add_tabs(name));
		}
		mysql_free_result();

		if(isnull(buffer))
			return ShowInfo(playerid, (playerid = victimid) ? (red"Nie posiadasz żadnego przedmiotu.") : (red"Gracz nie posiada żadnego przedmiotu"));
		ShowList(playerid, buffer);
	}
	else if(!strcmp(str1, "del", true))
	{
	    if(!Player(playerid, player_adminlvl))
			return 1;
	    new itemuid = strval(str2);
	    DeleteItem(itemuid);
	}
	else
	{
		new buffer[ 200 ];
		    
		ClearItem(playerid, 0);

		format(buffer, sizeof buffer,
			"SELECT `uid`, `name`, `used`, `type`, `v1`, `v2` FROM `surv_items` WHERE `ownerType`="#item_place_player" AND `owner`='%d' AND `name` LIKE '%%%s%%'",
			Player(playerid, player_uid),
			str1
		);
		mysql_query(buffer);
		mysql_store_result();
		if(!mysql_num_rows())
		{
		    ShowInfo(playerid, red"Nie znaleziono przedmiotu!");
		    mysql_free_result();
		    return 1;
		}
		mysql_fetch_row(buffer);
		
		sscanf(buffer, "p<|>ds["#MAX_ITEM_NAME"]iia<i>[2]f",
			Item(playerid, 0, item_uid),
			Item(playerid, 0, item_name),
			Item(playerid, 0, item_used),
			Item(playerid, 0, item_type),
			Item(playerid, 0, item_value),
			Item(playerid, 0, item_value3)
		);
		OnPlayerUseItem(playerid, 0, str2);

		mysql_free_result();
	}
	return 1;
}
Cmd::Input->p(playerid, params[]) return cmd_przedmiot(playerid, params);

Cmd::Input->time(playerid, cmdtext[])
{
	new zid = HavePlayerItem(playerid, item_watch);
	if(zid)
	{
		new victimid;
		if(sscanf(cmdtext, "u", victimid))
			victimid = playerid;
		if(!IsPlayerConnected(victimid))
			return NoPlayer(playerid);
		if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
			return ShowInfo(playerid, red"Gracz nie znajduje się w pobliżu.");

		new tm<tmTime>,
			string[ 128 ],
			zname[ MAX_ITEM_NAME ];
		gmtime(time(), tmTime);

		format(string, sizeof(string),
			"~w~%s~n~~p~%02d~w~:~p~%02d~w~:~p~%02d",
			days[tmTime[tm_wday]],
			(tmTime[tm_hour] + TIME_H) % 24,
			tmTime[tm_min],
			tmTime[tm_sec]
		);
		GameTextForPlayer(victimid, string, 5000, 1);
		
		format(string, sizeof string,
		    "SELECT `name` FROM `surv_items` WHERE `uid` = '%d'",
			zid
		);
		mysql_query(string);
		mysql_store_result();
		mysql_fetch_row(zname);
		mysql_free_result();

		if(Player(playerid, player_option) & option_me)
		{
			if(victimid == playerid)
				format(string, sizeof(string), "* %s spogląda na zegarek \"%s\".", NickName(playerid), zname);
			else
				format(string, sizeof(string), "* %s pokazuje godzine na zegarku \"%s\" %s.", NickName(playerid), zname, NickName(victimid));
			serwerme(playerid, string);
		}
		ApplyAnimation(playerid, "PLAYIDLES", "time", 4.1,0,1,1,1,1);
	}
	else ShowInfo(playerid, red"Nie masz zegarka.");
	return 1;
}
Cmd::Input->zegarek(playerid, cmdtext[]) return cmd_time(playerid, cmdtext);

Cmd::Input->wedkowanie(playerid, cmdtext[])
{
    if(!HavePlayerItem(playerid, item_wedka))
        return ShowInfo(playerid, red"Nie masz przy sobie wędki!");
        
	new string[ 160 ],
		bool:is = false,
		Float:closest_pos[ 3 ];
		
	new vehid = GetClosestCar(playerid, 10.0);
	if(vehid == INVALID_VEHICLE_ID)
	{
		GetPlayerPos(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]);
		format(string, sizeof string,
			"SELECT *, SQRT(((X - %f)  * (X - %f)) + ((Y - %f) * (Y - %f))) AS dist FROM `surv_fish` ORDER BY dist",
			Player(playerid, player_position)[ 0 ],
			Player(playerid, player_position)[ 0 ],
			Player(playerid, player_position)[ 1 ],
			Player(playerid, player_position)[ 1 ]
		);
		mysql_query(string);
		mysql_store_result();
		while(mysql_fetch_row(string))
		{
			static Float:pos[ 3 ];
		    sscanf(string, "p<|>{d}a<f>[3]{f}", pos);
			if(closest_pos[ 0 ] == 0.0 && closest_pos[ 1 ] == 0.0 && closest_pos[ 1 ] == 0.0)
			{
			    closest_pos[ 0 ] = pos[ 0 ];
			    closest_pos[ 1 ] = pos[ 1 ];
			    closest_pos[ 2 ] = pos[ 2 ];
			}
		    if(IsPlayerInRangeOfPoint(playerid, 2.0, pos[ 0 ], pos[ 1 ], pos[ 2 ]))
			{
				is = true;
				break;
			}
		}
		mysql_free_result();
	}
	else
	{
	    if(IsABoat(vehid))
	    	is = true;
	}
	
	if(is)
	{
	    SetPlayerAttachedObject(playerid, 3, 18632, 6, 0.079376, 0.037070, 0.007706, 181.482910, 0.0, 0.0, 1.0, 1.0, 1.0);
	    DisablePlayerCheckpoint(playerid);
	    
	    Player(playerid, player_fish) = 120;
	    Player(playerid, player_fish_timer) = SetTimerEx("Fish_Anim", 5000, true, "d", playerid);
	    FreezePlayer(playerid);
	    ApplyAnimation(playerid,"SWORD","sword_block",50.0,0,1,0,1,1);
	}
	else
	{
	    if(vehid == INVALID_VEHICLE_ID)
	    {
			SetPlayerCheckpoint(playerid, closest_pos[ 0 ], closest_pos[ 1 ], closest_pos[ 2 ], 2.0);
			ShowInfo(playerid, red"Nie jesteś w punkcie łowienia ryb!\n\nNajbliższy punkt został zaznaczony na mapie.");
		}
		else ShowInfo(playerid, red"Pojazd na którym się znajdujesz nie nadaje się do połowu ryb!");
	}
	return 1;
}

Cmd::Input->kostka(playerid, params[])
{
    if(!HavePlayerItem(playerid, item_kostka))
        return ShowInfo(playerid, red"Nie masz przy sobie kostki!");
        
    new string[ 40 + MAX_PLAYER_NAME ];
    format(string, sizeof string,
        "* %s wylosował %d na 6 oczek.",
        NickName(playerid),
        random(5)+1
	);
	serwerme(playerid, string);
	return 1;
}

public OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
    if(response)
    {
        new i = index;
        Attach(playerid, i, attach_model) 		= modelid;
        Attach(playerid, i, attach_bone) 		= boneid;
        Attach(playerid, i, attach_pos)[ 0 ] 	= fOffsetX;
        Attach(playerid, i, attach_pos)[ 1 ] 	= fOffsetY;
        Attach(playerid, i, attach_pos)[ 2 ] 	= fOffsetZ;
        Attach(playerid, i, attach_rpos)[ 0 ] 	= fRotX;
        Attach(playerid, i, attach_rpos)[ 1 ] 	= fRotY;
        Attach(playerid, i, attach_rpos)[ 2 ] 	= fRotZ;
        Attach(playerid, i, attach_apos)[ 0 ] 	= fScaleX;
        Attach(playerid, i, attach_apos)[ 1 ] 	= fScaleY;
        Attach(playerid, i, attach_apos)[ 2 ] 	= fScaleZ;
        
        new edit = GetPVarInt(playerid, "attach-edit"),
    		string[ 300 ];
		if(edit)
		{
        	Chat::Output(playerid, SZARY, "Obiekt wyedytowany!");
        	
		    format(string, sizeof string,
		        "UPDATE `surv_attach` SET `x`='%f', `y`='%f', `z`='%f', `rx`='%f', `ry`='%f', `rz`='%f', `ax`='%f', `ay`='%f', `az`='%f' WHERE `itemuid` = '%d' AND `playeruid` = '%d'",
				Attach(playerid, i, attach_pos)[ 0 ], Attach(playerid, i, attach_pos)[ 1 ], Attach(playerid, i, attach_pos)[ 2 ],
				Attach(playerid, i, attach_rpos)[ 0 ], Attach(playerid, i, attach_rpos)[ 1 ], Attach(playerid, i, attach_rpos)[ 2 ],
				Attach(playerid, i, attach_apos)[ 0 ], Attach(playerid, i, attach_apos)[ 1 ], Attach(playerid, i, attach_apos)[ 2 ],
				Attach(playerid, i, attach_itemuid),
				Player(playerid, player_uid)
			);
			mysql_query(string);
		}
		else
		{
		    Chat::Output(playerid, SZARY, "Obiekt stworzony!");
		    
			format(string, sizeof string, "UPDATE `surv_items` SET `used` = '1' WHERE `uid` = '%d'", Attach(playerid, i, attach_itemuid));
			mysql_query(string);

		    format(string, sizeof string,
				"INSERT INTO `surv_attach` VALUES (NULL, '%d', '%d', '%d', '%d', '%d', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f')",
				Player(playerid, player_uid),
				Attach(playerid, i, attach_itemuid),
				index,
				Attach(playerid, i, attach_model), Attach(playerid, i, attach_bone),
				Attach(playerid, i, attach_pos)[ 0 ], Attach(playerid, i, attach_pos)[ 1 ], Attach(playerid, i, attach_pos)[ 2 ],
				Attach(playerid, i, attach_rpos)[ 0 ], Attach(playerid, i, attach_rpos)[ 1 ], Attach(playerid, i, attach_rpos)[ 2 ],
				Attach(playerid, i, attach_apos)[ 0 ], Attach(playerid, i, attach_apos)[ 1 ], Attach(playerid, i, attach_apos)[ 2 ]
			);
			mysql_query(string);
		}
        SetPlayerAttachedObject(playerid, i, Attach(playerid, i, attach_model), Attach(playerid, i, attach_bone),
		Attach(playerid, i, attach_pos)[ 0 ], Attach(playerid, i, attach_pos)[ 1 ], Attach(playerid, i, attach_pos)[ 2 ],
		Attach(playerid, i, attach_rpos)[ 0 ], Attach(playerid, i, attach_rpos)[ 1 ], Attach(playerid, i, attach_rpos)[ 2 ],
		Attach(playerid, i, attach_apos)[ 0 ], Attach(playerid, i, attach_apos)[ 1 ], Attach(playerid, i, attach_apos)[ 2 ]);
		DeletePVar(playerid, "attach-edit");
		DeletePVar(playerid, "attach-slot");
	}
	else
	{
        new edit = GetPVarInt(playerid, "attach-edit");
        if(edit)
        {
		    Chat::Output(playerid, SZARY, "Edycja anulowana!");
		    new i = index;
	        SetPlayerAttachedObject(playerid, i, Attach(playerid, i, attach_model), Attach(playerid, i, attach_bone),
			Attach(playerid, i, attach_pos)[ 0 ], Attach(playerid, i, attach_pos)[ 1 ], Attach(playerid, i, attach_pos)[ 2 ],
			Attach(playerid, i, attach_rpos)[ 0 ], Attach(playerid, i, attach_rpos)[ 1 ], Attach(playerid, i, attach_rpos)[ 2 ],
			Attach(playerid, i, attach_apos)[ 0 ], Attach(playerid, i, attach_apos)[ 1 ], Attach(playerid, i, attach_apos)[ 2 ]);
		}
		else
		{
			RemovePlayerAttachedObject(playerid, index);
			Chat::Output(playerid, SZARY, "Przyczepianie anulowane!");
		}
		DeletePVar(playerid, "attach-edit");
		DeletePVar(playerid, "attach-slot");
	}
	return 1;
}

FuncPub::SetPlayerAttachedObjects(playerid, p_uid)
{
    for(new i=0; i<MAX_PLAYER_ATTACHED_OBJECTS; i++)
        if(IsPlayerAttachedObjectSlotUsed(playerid, i))
			RemovePlayerAttachedObject(playerid, i);
			
	new string[ 126 ];
	format(string, sizeof string, "SELECT * FROM `surv_attach` WHERE `playeruid` = '%d'", p_uid);
	mysql_query(string);
	mysql_store_result();
	while(mysql_fetch_row(string))
	{
	    static i;
	    sscanf(string, "p<|>{ddd}d", i);
	    
	    sscanf(string, "p<|>{dd}d{d}dda<f>[3]a<f>[3]a<f>[3]",
	    	Attach(playerid, i, attach_itemuid),
			Attach(playerid, i, attach_model),
			Attach(playerid, i, attach_bone),
			Attach(playerid, i, attach_pos),
			Attach(playerid, i, attach_rpos),
			Attach(playerid, i, attach_apos)
		);
        SetPlayerAttachedObject(playerid, i, Attach(playerid, i, attach_model), Attach(playerid, i, attach_bone),
		Attach(playerid, i, attach_pos)[ 0 ], Attach(playerid, i, attach_pos)[ 1 ], Attach(playerid, i, attach_pos)[ 2 ],
		Attach(playerid, i, attach_rpos)[ 0 ], Attach(playerid, i, attach_rpos)[ 1 ], Attach(playerid, i, attach_rpos)[ 2 ],
		Attach(playerid, i, attach_apos)[ 0 ], Attach(playerid, i, attach_apos)[ 1 ], Attach(playerid, i, attach_apos)[ 2 ]);
	}
	mysql_free_result();
	return 1;
}
