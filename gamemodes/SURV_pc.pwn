/*
uid 		- A_I
type 		- typ kary
typ 		- veh, player
typid 		- veh_uid, player_uid
typname[32]	- "XXX", "Matt Simons"
name[64] 	- "złe parkowanie", "mandat za śmiecenie"
v1
v2
gived 		- nadajacy
time 		- unix
*/
FuncPub::Pc_LoginOut(playerid)
{
	for(new ePC:d; d < ePC; d++)
	    Pc(playerid, d) = 0;
	return 1;
}

FuncPub::Pc_Default(playerid)
{
    Pc(playerid, pc_type) = select_none;
    
	if(Pc(playerid, pc_perm) == pc_perm_none)
		return ShowInfo(playerid, red"Permission denied!");

	new buffer[ 256 ];
  	if(Pc(playerid, pc_perm) >= pc_perm_user)
	{
	  	strcat(buffer, "Wyszukaj element\n");
		strcat(buffer, grey"------------------------\n");
	  	strcat(buffer, "Zmień hasło\n");
	}
  	if(Pc(playerid, pc_perm) >= pc_perm_admin)
	{
		strcat(buffer, grey"------------------------\n");
		strcat(buffer, "Dodaj użytkownika\n");
		strcat(buffer, "Usuń użytkownika\n");
		strcat(buffer, "Ustaw uprawnienia\n");
  	}
	Dialog::Output(playerid, 63, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Wyloguj");
	return 1;
}

FuncPub::Pc_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case 61:
	    {
	        if(!response) return 1;

    	    if(isnull(inputtext) || strlen(inputtext) > 32)
				return 	Dialog::Output(playerid, 61, DIALOG_STYLE_INPUT, IN_HEAD, pc_login, "Dalej", "Zamknij");

	    	mysql_real_escape_string(inputtext, inputtext);
	    	
	    	new buffer[ 80 ];
	    	format(buffer, sizeof buffer, "SELECT `uid` FROM `surv_pc_users` WHERE `login` = '%s'", inputtext);
	    	mysql_query(buffer);
	    	mysql_store_result();
		    if(mysql_num_rows())
		    {
				Pc(playerid, pc_user) = mysql_fetch_int();
				Dialog::Output(playerid, 62, DIALOG_STYLE_PASSWORD, IN_HEAD, pc_pass, "Zaloguj", "Zamknij");
			}
			else
			{
				GameTextForPlayer(playerid, "~n~~n~~n~~r~~h~Nie znaleziono konta!", 5000, 5);
				Dialog::Output(playerid, 61, DIALOG_STYLE_INPUT, IN_HEAD, pc_login, "Dalej", "Zamknij");
			}
			mysql_free_result();
	    }
	    case 62:
	    {
	        if(!response) return Pc_LoginOut(playerid);

    	    if(isnull(inputtext) || strlen(inputtext) > 32)
				return Dialog::Output(playerid, 62, DIALOG_STYLE_PASSWORD, IN_HEAD, pc_pass, "Zaloguj", "Zamknij");

	    	mysql_real_escape_string(inputtext, inputtext);

	    	new buffer[ 126 ];
	    	format(buffer, sizeof buffer,
				"SELECT `perm`, `typ` FROM `surv_pc_users` WHERE `uid` = '%d' AND `pass` = md5('%s')",
				Pc(playerid, pc_user),
				inputtext
			);
	    	mysql_query(buffer);
	    	mysql_store_result();
		    if(mysql_num_rows())
		    {
		    	mysql_fetch_row(buffer);
		    	
      			sscanf(buffer, "p<|>dd",
		            Pc(playerid, pc_perm),
		            Pc(playerid, pc_typ)
				);
				
	    		Pc_Default(playerid);
			}
			else
	    	{
				Dialog::Output(playerid, 62, DIALOG_STYLE_PASSWORD, IN_HEAD, pc_pass, "Zaloguj", "Zamknij");
				GameTextForPlayer(playerid, "~n~~n~~n~~r~~h~Bledne haslo!", 5000, 5);
	    	}
	    	mysql_free_result();
	    }
	    case 63:
	    {
	        if(!response) return Pc_LoginOut(playerid);
			if(DIN(inputtext, "Wyszukaj element"))
			{
			    new buffer[ 256 ];
			    if(Pc(playerid, pc_typ) == pc_user_pd) buffer = "Postać\nPojazd\nWpis";
			    else if(Pc(playerid, pc_typ) == pc_user_mc) buffer = "Postać";
			    
				Dialog::Output(playerid, 69, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Wróć");
			}
	    }
	    case 69:
	    {
	        if(!response) return Pc_Default(playerid);
			if(DIN(inputtext, "Postać"))
			{
			    Pc(playerid, pc_type) = select_char;
				Dialog::Output(playerid, 79, DIALOG_STYLE_INPUT, IN_HEAD, "Podaj ID lub część nicku:", "Wybierz", "Wróć");
			}
			else if(DIN(inputtext, "Pojazd"))
			{
			    Pc(playerid, pc_type) = select_veh;
				Dialog::Output(playerid, 79, DIALOG_STYLE_INPUT, IN_HEAD, "Podaj rejestrację pojazdu:", "Wybierz", "Wróć");
			}
			else if(DIN(inputtext, "Wpis"))
			{
			    Pc(playerid, pc_type) = select_wpis;
				Dialog::Output(playerid, 79, DIALOG_STYLE_INPUT, IN_HEAD, "Podaj część wpisu:", "Wybierz", "Wróć");
			}
	    }
	    case 79:
	    {
	        if(!response) return Pc_Default(playerid);
	        if(isnull(inputtext))
			{
				if(Pc(playerid, pc_type) == select_char)
					Dialog::Output(playerid, 79, DIALOG_STYLE_INPUT, IN_HEAD, "Podaj ID lub część nicku:", "Wybierz", "Wróć");
				if(Pc(playerid, pc_type) == select_veh)
					Dialog::Output(playerid, 79, DIALOG_STYLE_INPUT, IN_HEAD, "Podaj rejestrację pojazdu:", "Wybierz", "Wróć");
				if(Pc(playerid, pc_type) == select_wpis)
					Dialog::Output(playerid, 79, DIALOG_STYLE_INPUT, IN_HEAD, "Podaj część wpisu:", "Wybierz", "Wróć");
			}
			new query[ 256 ],
				buffer[ 512 ],
				num,
				znak = -1;
			mysql_real_escape_string(inputtext, inputtext);
			if(Pc(playerid, pc_type) == select_char)
			{
			    if('0' <= inputtext[ 0 ] <= '9')
			    {
					new victimid = strval(inputtext);
					if(!IsPlayerConnected(victimid)) return NoPlayer(playerid);
					
					format(query, sizeof query, "SELECT DISTINCT `typid`, `typname` FROM `surv_kartoteka` WHERE `typ` = '%d' AND `typid` = '%d' AND (`t` = '%d' OR `t` = '"#pc_user_none"') ORDER BY `uid` DESC", Pc(playerid, pc_type), Player(victimid, player_uid), Pc(playerid, pc_typ));
				}
				else format(query, sizeof query, "SELECT DISTINCT `typid`, `typname` FROM `surv_kartoteka` WHERE `typ` = '%d' AND (`t` = '%d' OR `t` = '"#pc_user_none"') AND `typname` LIKE '%%%s%%' ORDER BY `uid` DESC", Pc(playerid, pc_type), Pc(playerid, pc_typ), inputtext);
				mysql_query(query);
				mysql_store_result();
				if(mysql_num_rows())
				{
				    format(buffer, sizeof buffer, "Znalezione wyniki dla nazwy: "green"%s\n", inputtext);
					while(mysql_fetch_row(query))
					{
					    new typname[ 32 ], typid;
					    
					    sscanf(query,
							"p<|>ds[32]",
							typid,
							typname
						);
						
					    znak = strfind(typname, inputtext, true);
						if(znak != -1)
						{
						    strins(typname, green, znak);
						    strins(typname, white, znak+strlen(inputtext)+strlen(green));
						    format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, typid, typname);
						    num++;
						}
						if(num > 9)
						{
							strcat(buffer, grey"------------------------\n");
						 	strcat(buffer, "Lista ucięta, zbyt wiele wyników!");
						 	break;
						}
					}
					Dialog::Output(playerid, 156, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
				}
				else ShowInfo(playerid, red"Gracz nie został znaleziona w bazie danych!");
				mysql_free_result();
			}
			else if(Pc(playerid, pc_type) == select_veh)
			{
			    format(query, sizeof query, "SELECT DISTINCT `typid`, `typname` FROM `surv_kartoteka` WHERE (`t` = '%d' OR `t` = '"#pc_user_none"') AND `typ` = '%d' AND `typname` LIKE '%%%s%%' ORDER BY `uid` DESC", Pc(playerid, pc_typ), Pc(playerid, pc_type), inputtext);
				mysql_query(query);
				mysql_store_result();
				if(mysql_num_rows())
				{
				    format(buffer, sizeof buffer, "Znalezione wyniki dla nazwy: "green"%s\n", inputtext);
					while(mysql_fetch_row(query))
					{
					    new typname[ 32 ],
					        typid;
							
					    sscanf(query,
							"p<|>ds[32]",
							typid,
							typname
						);

					    znak = strfind(typname, inputtext, true);
						if(znak != -1)
						{
						    strins(typname, green, znak);
						    strins(typname, white, znak+strlen(inputtext)+strlen(green));
						    format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, typid, typname);
						    num++;
						}
						if(num > 9)
						{
							strcat(buffer, grey"------------------------\n");
						 	strcat(buffer, "Lista ucięta, zbyt wiele wyników!");
						 	break;
						}
					}
					Dialog::Output(playerid, 156, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
				}
				else ShowInfo(playerid, red"Rejestracja nie została znaleziona w bazie danych!");
				mysql_free_result();
			}
			else if(Pc(playerid, pc_type) == select_wpis)
			{
			    format(query, sizeof query, "SELECT DISTINCT `uid`, `name` FROM `surv_kartoteka` WHERE `name` LIKE '%%%s%%' AND (`t` = '%d' OR `t` = '"#pc_user_none"') ORDER BY `uid` DESC", inputtext, Pc(playerid, pc_typ));
				mysql_query(query);
				mysql_store_result();
				if(mysql_num_rows())
				{
				    format(buffer, sizeof buffer, "Znalezione wyniki dla wpisu: "green"%s\n", inputtext);
					while(mysql_fetch_row(query))
					{
					    new uid,
							name[ 64 ];

					    sscanf(query,
							"p<|>ds[64]",
							uid,
							name
						);

					    znak = strfind(name, inputtext, true);
						if(znak != -1)
						{
						    strins(name, green, znak);
						    strins(name, white, znak+strlen(inputtext)+strlen(green));
						    format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, uid, name);
						    num++;
						}
						if(num > 9)
						{
							strcat(buffer, grey"------------------------\n");
						 	strcat(buffer, "Lista ucięta, zbyt wiele wyników!");
						 	break;
						}
					}
					Dialog::Output(playerid, 156, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
				}
				else ShowInfo(playerid, red"Wpis nie został znaleziona w bazie danych!");
				mysql_free_result();
			}
	    }
	    case 156:
	    {
	        if(!response) return Pc_Default(playerid);
	        Pc(playerid, pc_value)[ 0 ] = strval(inputtext);
	        if(Pc(playerid, pc_type) == select_char)
	        {
		        new playername[ MAX_PLAYER_NAME ],
					age, sex,
					string[ 126 ],
					year;

				format(string, sizeof string,
					"SELECT `name`, `age`, `sex` FROM `surv_players` WHERE `uid` = '%d'",
					Pc(playerid, pc_value)[ 0 ]
				);
				mysql_query(string);
				mysql_store_result();
				mysql_fetch_row(string);

				sscanf(string, "p<|>s["#MAX_PLAYER_NAME"]dd",
				    playername,
				    age,
				    sex
				);
				mysql_free_result();

				UnderscoreToSpace(playername);
		        getdate(year);
		        
			    new odc[ 10 ];
				format(odc, sizeof odc, MD5_Hash(Pc(playerid, pc_value)[ 0 ]));
				strdel(odc, 4, strlen(odc));
				for(new d; d != strlen(odc); d++) odc[ d ] = toupper(odc[ d ]);

	            format(string, sizeof string, "Imię i nazwisko:\t\t%s\n", playername);
	            format(string, sizeof string, "%sWiek:\t\t\t%d\n", string, year - age);
	            format(string, sizeof string, "%sPłeć:\t\t\t%s\n", string, (sex == sex_men) ? ("Mężczyzna") : ("Kobieta"));
	            format(string, sizeof string, "%sOdciski:\t\t%s\n", string, odc);
	    		strcat(string, grey"------------------------\n");
	    		strcat(string, "Sprawdź kartoteke\n");
				ShowList(playerid, string);
	        }
	        else if(Pc(playerid, pc_type) == select_veh)
	        {
		        new vehicleid = INVALID_VEHICLE_ID;
				foreachex(Server_Vehicles, vehicleid)
					if(Vehicle(vehicleid, vehicle_uid) == Pc(playerid, pc_value)[ 0 ])
						break;
						
				new buffer[ 256 ],
					model,
					color[ 2 ],
					plate[ 32 ],
					veh_name[ 64 ],
					owner[ 2 ],
					ownerName[ MAX_GROUP_NAME ];
				if(vehicleid == -1)
				{
					format(buffer, sizeof buffer,
						"SELECT `name`, `model`, `c1`, `c2`, `plate`, `ownerType`, `owner` FROM `surv_vehicles` WHERE `uid` = '%d'",
						Pc(playerid, pc_value)[ 0 ]
					);
					mysql_query(buffer);
					mysql_store_result();
			        if(!mysql_num_rows())
			        {
			            ShowInfo(playerid, red"Ten pojazd nie istnieje!");
			            mysql_free_result();
			            return 1;
			        }
					else mysql_fetch_row(buffer);
					mysql_free_result();

					sscanf(buffer, "p<|>s[64]da<d>[2]s[32]a<d>[2]",
					    veh_name,
					    model,
					    color,
					    plate,
					    owner
					);

				    Pc(playerid, pc_value)[ 1 ] = INVALID_VEHICLE_ID;
				}
				else
				{
			    	model 		= Vehicle(vehicleid, vehicle_model);
				    color[ 0 ] 	= Vehicle(vehicleid, vehicle_color)[ 0 ];
				    color[ 1 ] 	= Vehicle(vehicleid, vehicle_color)[ 1 ];
				    owner[ 0 ]	= Vehicle(vehicleid, vehicle_owner)[ 0 ];
				    owner[ 1 ]	= Vehicle(vehicleid, vehicle_owner)[ 1 ];
				    format(veh_name, sizeof veh_name, Vehicle(vehicleid, vehicle_name));
			    	if(isnull(Vehicle(vehicleid, vehicle_plate)))
				        plate = "Niezarejestrowany";
				    else
				    	format(plate, sizeof plate, Vehicle(vehicleid, vehicle_plate));
				    Pc(playerid, pc_value)[ 1 ] = vehicleid;
				}
				if(owner[ 0 ] == vehicle_owner_job)
					format(ownerName, sizeof ownerName, JobName[ owner[ 1 ] ]);
				else
				{
					new table[ 3 ][ ] = {"", "`surv_groups`", "`surv_players`"};
					format(buffer, sizeof buffer,
						"SELECT `name` FROM %s WHERE `uid` = '%d'",
						table[ owner[ 0 ] ],
						owner[ 1 ]
					);
					mysql_query(buffer);
					mysql_store_result();
					if(!mysql_num_rows()) ownerName = "n\a";
					else mysql_fetch_row(ownerName);
					mysql_free_result();

					if(owner[ 0 ] == vehicle_owner_player)
					    UnderscoreToSpace(ownerName);
				}

				format(buffer, sizeof buffer, "Informacje o pojeździe:\n");
				format(buffer, sizeof buffer, "%sUID:\t\t%d\n", buffer, Pc(playerid, pc_value)[ 0 ]);
				format(buffer, sizeof buffer, "%sModel:\t\t%s (%s - %d)\n", buffer, veh_name, model == 0 ? ("n/a") : NazwyPojazdow[ model - 400 ], model);
				format(buffer, sizeof buffer, "%sKolory:\t\t%d:%d\n", buffer, color[ 0 ], color[ 1 ]);
				format(buffer, sizeof buffer, "%sRejestracja:\t%s\n", buffer, plate);
				format(buffer, sizeof buffer, "%sWłaściciel:\t%d:%d (%s)\n", buffer, owner[ 0 ], owner[ 1 ], ownerName);
				ShowList(playerid, buffer);
	        }
	        else if(Pc(playerid, pc_type) == select_wpis)
	        {
	        
	        }
	    }
	}
	return 1;
}

FuncPub::AddToKartoteka(playerid, t, typ, type, typeid, typname[], reason[], v1, Float:v2)
{
	new string[ 256 ];
	mysql_real_escape_string(typname, typname);
	mysql_real_escape_string(reason, reason);
	EscapePL(reason);
	reason[ 0 ] = toupper(reason[ 0 ]);
	
	format(string, sizeof string,
		"INSERT INTO `surv_kartoteka` VALUES (NULL, '%d', '%d', '%d', '%d', '%s', '%s', '%d', '%.2f', '%d', UNIX_TIMESTAMP());",
		t,
		typ,
		type, typeid,
		typname,
		reason,
		v1, v2,
		Player(playerid, player_uid)
	);
	mysql_query(string);
	return mysql_insert_id();
}

Cmd::Input->komputer(playerid, params[])
{
	new vehid = Player(playerid, player_veh);
	if(vehid == INVALID_VEHICLE_ID)
	    return ShowInfo(playerid, red"Nie jesteś w pojeździe!");
	if(!(Vehicle(vehid, vehicle_option) & option_pc))
		return ShowInfo(playerid, red"Ten pojazd nie ma zamontowanego komputera pokładowego.");

	Dialog::Output(playerid, 61, DIALOG_STYLE_INPUT, IN_HEAD, pc_login, "Dalej", "Zamknij");
	return 1;
}
Cmd::Input->pc(playerid, params[]) return cmd_komputer(playerid, params);
