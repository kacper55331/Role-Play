stock SPD(playerid, dialogid, style, caption[], info[], button1[], button2[])
{
	Player(playerid, player_dialog) = (dialogid == -1) ? cellmin : dialogid;
	return Dialog::Output(playerid, dialogid, style, caption, info, button1, button2);
}
#define ShowPlayerDialog SPD

stock OnDialogResponseEx(playerid, dialogid, response, listitem, inputtext[])
{
	Player(playerid, player_dialog) = (dialogid == -1) ? cellmin : dialogid;
	return OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
}

FuncPub::kickPlayer(playerid)
{
	TextDrawHideForPlayer(playerid, Setting(setting_td_box)[ 0 ]);
	TextDrawHideForPlayer(playerid, Setting(setting_td_box)[ 1 ]);

    TextDrawHideForPlayer(playerid, Setting(setting_sn)[ 0 ]);
    TextDrawHideForPlayer(playerid, Setting(setting_sn)[ 1 ]);

	PlayerTextDrawHide(playerid, Player(playerid, player_cash_td));
	PlayerTextDrawDestroy(playerid, Player(playerid, player_cash_td));

	PlayerTextDrawHide(playerid, Player(playerid, player_infos));
	PlayerTextDrawDestroy(playerid, Player(playerid, player_infos));

	PlayerTextDrawHide(playerid, Player(playerid, player_veh_td));
	PlayerTextDrawDestroy(playerid, Player(playerid, player_veh_td));

	PlayerTextDrawHide(playerid, Player(playerid, player_street));
	PlayerTextDrawDestroy(playerid, Player(playerid, player_street));
	
	Player(playerid, player_disabled) = true;

	FadeColorForPlayer(playerid, 0, 0, 0, 0, 0, 0, 0, 255, 15, 0); // Ściemnienie
	Player(playerid, player_dark) = dark_kick;
	SetTimerEx("kickEx", 2000, false, "d", playerid);
	return 1;
}
FuncPub::kickEx(playerid)
{
	Kick(playerid);
	return 1;
}

FuncPub::LoadSetting()
{
    mysql_set_charset("utf8_unicode_ci");
    
	new str[ 256 ];
    mysql_query("SELECT * FROM `surv_setting` ORDER BY `uid` DESC");
    mysql_store_result();
 	mysql_fetch_row_format(str);
	sscanf(str, "p<|>{d}da<f>[3]a<f>[4]a<f>[6]{d}a<f>[4]",
		Setting(setting_bank),
		Setting(setting_aj),
		Setting(setting_r_pos),
		Setting(setting_r_cam),
		Setting(setting_veh_pos)
	);
    mysql_free_result();
    
    #if OFFICIAL == 1
    	mysql_query("DELETE FROM `all_online` WHERE `type` = '"#type_rp"'");
    #endif
    new h;
    gettime(h);
    SetWorldTime(h);
	LoadWeather();
	Setting(setting_packet) = 10050;
	Setting(setting_gym)[ 0 ] = 150.0;
	Setting(setting_gym)[ 1 ] = 750.0;
    Audio_DestroyTCPServer();
    Audio_CreateTCPServer(GetServerVarAsInt("port"));
    Audio_SetPack("surv");
	return 1;
}

FuncPub::LoadPlayerTextDraws(playerid)
{
	// Tabelka po prawej stronie.
	Player(playerid, player_infos) = CreatePlayerTextDraw(playerid, 500.000000, 300.000000, "Ladowanie danych!");
	PlayerTextDrawBackgroundColor(playerid, Player(playerid, player_infos), 255);
	PlayerTextDrawFont(playerid, Player(playerid, player_infos), 1);
	PlayerTextDrawLetterSize(playerid, Player(playerid, player_infos), 0.370000, 1.600000);
	PlayerTextDrawColor(playerid, Player(playerid, player_infos), -1);
	PlayerTextDrawSetOutline(playerid, Player(playerid, player_infos), 0);
	PlayerTextDrawSetProportional(playerid, Player(playerid, player_infos), 1);
	PlayerTextDrawUseBox(playerid, Player(playerid, player_infos), 1);
	PlayerTextDrawBoxColor(playerid, Player(playerid, player_infos), 150);
	PlayerTextDrawTextSize(playerid, Player(playerid, player_infos), 608.000000, 0.000000);
	
	// Przedmioty
	Player(playerid, player_item_td)[ 0 ] = CreatePlayerTextDraw(playerid, 489.000000, 145.000000, "_");
	PlayerTextDrawAlignment(playerid, Player(playerid, player_item_td)[ 0 ], 2);
	PlayerTextDrawBackgroundColor(playerid, Player(playerid, player_item_td)[ 0 ], 255);
	PlayerTextDrawFont(playerid, Player(playerid, player_item_td)[ 0 ], 1);
	PlayerTextDrawLetterSize(playerid, Player(playerid, player_item_td)[ 0 ], 0.310000, 1.299998);
	PlayerTextDrawColor(playerid, Player(playerid, player_item_td)[ 0 ], -2139062017);
	PlayerTextDrawSetOutline(playerid, Player(playerid, player_item_td)[ 0 ], 0);
	PlayerTextDrawSetProportional(playerid, Player(playerid, player_item_td)[ 0 ], 1);
	PlayerTextDrawSetShadow(playerid, Player(playerid, player_item_td)[ 0 ], 1);

	Player(playerid, player_item_td)[ 1 ] = CreatePlayerTextDraw(playerid, 523.000000, 145.000000, "_");
	PlayerTextDrawBackgroundColor(playerid, Player(playerid, player_item_td)[ 1 ], 255);
	PlayerTextDrawFont(playerid, Player(playerid, player_item_td)[ 1 ], 1);
	PlayerTextDrawLetterSize(playerid, Player(playerid, player_item_td)[ 1 ], 0.300000, 1.299999);
	PlayerTextDrawColor(playerid, Player(playerid, player_item_td)[ 1 ], -1);
	PlayerTextDrawSetOutline(playerid, Player(playerid, player_item_td)[ 1 ], 0);
	PlayerTextDrawSetProportional(playerid, Player(playerid, player_item_td)[ 1 ], 1);
	PlayerTextDrawSetShadow(playerid, Player(playerid, player_item_td)[ 1 ], 1);

	Player(playerid, player_item_td)[ 2 ] = CreatePlayerTextDraw(playerid, 550.000000, 265.000000, "~<~ Strona 1/1 ~>~");
	PlayerTextDrawAlignment(playerid, Player(playerid, player_item_td)[ 2 ], 2);
	PlayerTextDrawBackgroundColor(playerid, Player(playerid, player_item_td)[ 2 ], 255);
	PlayerTextDrawFont(playerid, Player(playerid, player_item_td)[ 2 ], 1);
	PlayerTextDrawLetterSize(playerid, Player(playerid, player_item_td)[ 2 ], 0.170000, 0.899999);
	PlayerTextDrawColor(playerid, Player(playerid, player_item_td)[ 2 ], -1);
	PlayerTextDrawSetOutline(playerid, Player(playerid, player_item_td)[ 2 ], 0);
	PlayerTextDrawSetProportional(playerid, Player(playerid, player_item_td)[ 2 ], 1);
	PlayerTextDrawSetShadow(playerid, Player(playerid, player_item_td)[ 2 ], 1);
	
	// Friends
	Player(playerid, player_friend) = CreatePlayerTextDraw(playerid, 548.000000, 29.000000, "~y~~h~Nick Name~n~~w~dolaczyl do gry!");
	PlayerTextDrawBackgroundColor(playerid, Player(playerid, player_friend), 255);
	PlayerTextDrawFont(playerid, Player(playerid, player_friend), 1);
	PlayerTextDrawLetterSize(playerid, Player(playerid, player_friend), 0.380000, 1.200000);
	PlayerTextDrawColor(playerid, Player(playerid, player_friend), -1);
	PlayerTextDrawSetOutline(playerid, Player(playerid, player_friend), 0);
	PlayerTextDrawSetProportional(playerid, Player(playerid, player_friend), 1);
	PlayerTextDrawSetShadow(playerid, Player(playerid, player_friend), 1);
	PlayerTextDrawUseBox(playerid, Player(playerid, player_friend), 1);
	PlayerTextDrawBoxColor(playerid, Player(playerid, player_friend), 150);
	PlayerTextDrawTextSize(playerid, Player(playerid, player_friend), 642.000000, 0.000000);
	
	// Pojazd
	Player(playerid, player_veh_td) = CreatePlayerTextDraw(playerid, 500.000000,392.000000, "Loading..");
	PlayerTextDrawUseBox(playerid, Player(playerid, player_veh_td), 1);
	PlayerTextDrawBoxColor(playerid, Player(playerid, player_veh_td), 25);
	PlayerTextDrawTextSize(playerid, Player(playerid, player_veh_td), 636.000000,4.000000);
	PlayerTextDrawAlignment(playerid, Player(playerid, player_veh_td), 0);
	PlayerTextDrawBackgroundColor(playerid, Player(playerid, player_veh_td), 0x000000ff);
	PlayerTextDrawFont(playerid, Player(playerid, player_veh_td), 1);
	PlayerTextDrawLetterSize(playerid, Player(playerid, player_veh_td), 0.299999,1.000000);
	PlayerTextDrawColor(playerid, Player(playerid, player_veh_td), 0xffffffff);
	PlayerTextDrawSetOutline(playerid, Player(playerid, player_veh_td), 1);
	PlayerTextDrawSetProportional(playerid, Player(playerid, player_veh_td), 1);
	PlayerTextDrawSetShadow(playerid, Player(playerid, player_veh_td), 1);

	// Tankowanie
	Player(playerid, player_fuel_td)[ 0 ] = CreatePlayerTextDraw(playerid, 384.000000, 305.000000, "Loading..");
	PlayerTextDrawBackgroundColor(playerid, Player(playerid, player_fuel_td)[ 0 ], 255);
	PlayerTextDrawFont(playerid, Player(playerid, player_fuel_td)[ 0 ], 1);
	PlayerTextDrawLetterSize(playerid, Player(playerid, player_fuel_td)[ 0 ], 0.330000, 1.200000);
	PlayerTextDrawColor(playerid, Player(playerid, player_fuel_td)[ 0 ], -1);
	PlayerTextDrawSetOutline(playerid, Player(playerid, player_fuel_td)[ 0 ], 0);
	PlayerTextDrawSetProportional(playerid, Player(playerid, player_fuel_td)[ 0 ], 1);
	PlayerTextDrawSetShadow(playerid, Player(playerid, player_fuel_td)[ 0 ], 1);
	PlayerTextDrawUseBox(playerid, Player(playerid, player_fuel_td)[ 0 ], 1);
	PlayerTextDrawBoxColor(playerid, Player(playerid, player_fuel_td)[ 0 ], 150);
	PlayerTextDrawTextSize(playerid, Player(playerid, player_fuel_td)[ 0 ], 690.000000, 0.000000);

	Player(playerid, player_fuel_td)[ 1 ] = CreatePlayerTextDraw(playerid, 590.000000, 318.000000, "Loading.."); // Ilość paliwa
	PlayerTextDrawAlignment(playerid, Player(playerid, player_fuel_td)[ 1 ], 3);
	PlayerTextDrawBackgroundColor(playerid, Player(playerid, player_fuel_td)[ 1 ], 255);
	PlayerTextDrawFont(playerid, Player(playerid, player_fuel_td)[ 1 ], 1);
	PlayerTextDrawLetterSize(playerid, Player(playerid, player_fuel_td)[ 1 ], 0.270000, 1.900000);
	PlayerTextDrawColor(playerid, Player(playerid, player_fuel_td)[ 1 ], -1);
	PlayerTextDrawSetOutline(playerid, Player(playerid, player_fuel_td)[ 1 ], 0);
	PlayerTextDrawSetProportional(playerid, Player(playerid, player_fuel_td)[ 1 ], 1);
	PlayerTextDrawSetShadow(playerid, Player(playerid, player_fuel_td)[ 1 ], 1);

	Player(playerid, player_fuel_td)[ 2 ] = CreatePlayerTextDraw(playerid, 590.000000, 338.000000, "Loading.."); // Cena
	PlayerTextDrawAlignment(playerid, Player(playerid, player_fuel_td)[ 2 ], 3);
	PlayerTextDrawBackgroundColor(playerid, Player(playerid, player_fuel_td)[ 2 ], 255);
	PlayerTextDrawFont(playerid, Player(playerid, player_fuel_td)[ 2 ], 1);
	PlayerTextDrawLetterSize(playerid, Player(playerid, player_fuel_td)[ 2 ], 0.270000, 1.900000);
	PlayerTextDrawColor(playerid, Player(playerid, player_fuel_td)[ 2 ], -1);
	PlayerTextDrawSetOutline(playerid, Player(playerid, player_fuel_td)[ 2 ], 0);
	PlayerTextDrawSetProportional(playerid, Player(playerid, player_fuel_td)[ 2 ], 1);
	PlayerTextDrawSetShadow(playerid, Player(playerid, player_fuel_td)[ 2 ], 1);

	Player(playerid, player_fuel_td)[ 3 ] = CreatePlayerTextDraw(playerid, 517.000000, 362.000000, "Loading.."); // Cena za litr
	PlayerTextDrawAlignment(playerid, Player(playerid, player_fuel_td)[ 3 ], 3);
	PlayerTextDrawBackgroundColor(playerid, Player(playerid, player_fuel_td)[ 3 ], 255);
	PlayerTextDrawFont(playerid, Player(playerid, player_fuel_td)[ 3 ], 1);
	PlayerTextDrawLetterSize(playerid, Player(playerid, player_fuel_td)[ 3 ], 0.270000, 1.900000);
	PlayerTextDrawColor(playerid, Player(playerid, player_fuel_td)[ 3 ], -1);
	PlayerTextDrawSetOutline(playerid, Player(playerid, player_fuel_td)[ 3 ], 0);
	PlayerTextDrawSetProportional(playerid, Player(playerid, player_fuel_td)[ 3 ], 1);
	PlayerTextDrawSetShadow(playerid, Player(playerid, player_fuel_td)[ 3 ], 1);
	
	// Kasa
	
	Player(playerid, player_cash_td) = CreatePlayerTextDraw(playerid, 608.000000, 77.500000, ".00");
	PlayerTextDrawBackgroundColor(playerid, Player(playerid, player_cash_td), 255);
	PlayerTextDrawFont(playerid, Player(playerid, player_cash_td), 3);
	PlayerTextDrawLetterSize(playerid, Player(playerid, player_cash_td), 0.609999, 2.299999);
	PlayerTextDrawColor(playerid, Player(playerid, player_cash_td), 0x315829FF);
	PlayerTextDrawSetOutline(playerid, Player(playerid, player_cash_td), 1);
	PlayerTextDrawSetProportional(playerid, Player(playerid, player_cash_td), 1);
	/*
	Player(playerid, player_cash_td) = CreatePlayerTextDraw(playerid, 590.000000, 94.500000, "00");
	PlayerTextDrawLetterSize(playerid, Player(playerid, player_cash_td), 0.382999, 1.455627);
	PlayerTextDrawAlignment(playerid, Player(playerid, player_cash_td), 1);
	PlayerTextDrawColor(playerid, Player(playerid, player_cash_td), 827927039);
	PlayerTextDrawSetShadow(playerid, Player(playerid, player_cash_td), 0);
	PlayerTextDrawSetOutline(playerid, Player(playerid, player_cash_td), 2);
	PlayerTextDrawBackgroundColor(playerid, Player(playerid, player_cash_td), 255);
	PlayerTextDrawFont(playerid, Player(playerid, player_cash_td), 3);
	PlayerTextDrawSetProportional(playerid, Player(playerid, player_cash_td), 1);
	*/
	// Dodatek kasy
	Player(playerid, player_cash_add) = CreatePlayerTextDraw(playerid, 531.000000, 95.500000, "+ $5.00");
	PlayerTextDrawBackgroundColor(playerid, Player(playerid, player_cash_add), 255);
	PlayerTextDrawFont(playerid, Player(playerid, player_cash_add), 3);
	PlayerTextDrawLetterSize(playerid, Player(playerid, player_cash_add), 0.589999, 2.299998);
	PlayerTextDrawColor(playerid, Player(playerid, player_cash_add), 0x315829FF);
	PlayerTextDrawSetOutline(playerid, Player(playerid, player_cash_add), 1);
	PlayerTextDrawSetProportional(playerid, Player(playerid, player_cash_add), 1);
	PlayerTextDrawSetSelectable(playerid, Player(playerid, player_cash_add), 0);

/*	// Drzwi
	Player(playerid, player_door_td) = CreatePlayerTextDraw(playerid,324.000000, 325.000000, "Motel Idlewood~n~~n~~y~~h~Aby wejsc, wcisnij jednoczesnie~n~~w~[~b~~h~LALT + SHIFT~w~]");
	PlayerTextDrawAlignment(playerid, Player(playerid, player_door_td), 2);
	PlayerTextDrawBackgroundColor(playerid, Player(playerid, player_door_td), 255);
	PlayerTextDrawFont(playerid, Player(playerid, player_door_td), 1);
	PlayerTextDrawLetterSize(playerid, Player(playerid, player_door_td), 0.370000, 1.600000);
	PlayerTextDrawColor(playerid, Player(playerid, player_door_td), -1);
	PlayerTextDrawSetOutline(playerid, Player(playerid, player_door_td), 1);
	PlayerTextDrawSetProportional(playerid, Player(playerid, player_door_td), 1);
	PlayerTextDrawUseBox(playerid, Player(playerid, player_door_td), 1);
	PlayerTextDrawBoxColor(playerid, Player(playerid, player_door_td), 50);
	PlayerTextDrawTextSize(playerid, Player(playerid, player_door_td), 0.000000, 224.000000);
*/
	// Nazwa ulicy
	Player(playerid, player_street) = CreatePlayerTextDraw(playerid, 88.000000, 325.000000, "Miami street");
	PlayerTextDrawAlignment(playerid, Player(playerid, player_street), 2);
	PlayerTextDrawBackgroundColor(playerid, Player(playerid, player_street), 255);
	PlayerTextDrawFont(playerid, Player(playerid, player_street), 1);
	PlayerTextDrawLetterSize(playerid, Player(playerid, player_street), 0.370000, 1.600000);
	PlayerTextDrawColor(playerid, Player(playerid, player_street), -1);
	PlayerTextDrawSetOutline(playerid, Player(playerid, player_street), 1);
	PlayerTextDrawSetProportional(playerid, Player(playerid, player_street), 1);
	
	// Kary
	Player(playerid, player_kara)[ 0 ] = CreatePlayerTextDraw(playerid, 320.000000, 425.000000, "~n~");
	PlayerTextDrawAlignment(playerid, Player(playerid, player_kara)[ 0 ], 2);
	PlayerTextDrawBackgroundColor(playerid, Player(playerid, player_kara)[ 0 ], 255);
	PlayerTextDrawFont(playerid, Player(playerid, player_kara)[ 0 ], 1);
	PlayerTextDrawLetterSize(playerid, Player(playerid, player_kara)[ 0 ], 0.500000, 1.000000);
	PlayerTextDrawColor(playerid, Player(playerid, player_kara)[ 0 ], -1);
	PlayerTextDrawSetOutline(playerid, Player(playerid, player_kara)[ 0 ], 0);
	PlayerTextDrawSetProportional(playerid, Player(playerid, player_kara)[ 0 ], 1);
	PlayerTextDrawSetShadow(playerid, Player(playerid, player_kara)[ 0 ], 1);
	PlayerTextDrawUseBox(playerid, Player(playerid, player_kara)[ 0 ], 1);
	PlayerTextDrawBoxColor(playerid, Player(playerid, player_kara)[ 0 ], 75);
	PlayerTextDrawTextSize(playerid, Player(playerid, player_kara)[ 0 ], 3.000000, -692.000000);

	Player(playerid, player_kara)[ 1 ] = CreatePlayerTextDraw(playerid, 10.000000, 423.000000, "Wczytywanie..");
	PlayerTextDrawBackgroundColor(playerid, Player(playerid, player_kara)[ 1 ], 255);
	PlayerTextDrawFont(playerid, Player(playerid, player_kara)[ 1 ], 1);
	PlayerTextDrawLetterSize(playerid, Player(playerid, player_kara)[ 1 ], 0.189999, 1.299999);
	PlayerTextDrawColor(playerid, Player(playerid, player_kara)[ 1 ], -1);
	PlayerTextDrawSetOutline(playerid, Player(playerid, player_kara)[ 1 ], 1);
	PlayerTextDrawSetProportional(playerid, Player(playerid, player_kara)[ 1 ], 1);
	
	// Znak drogowy
	Player(playerid, player_radar)[ 0 ] = CreatePlayerTextDraw(playerid, 448.444549, 39.822246, "90");
    PlayerTextDrawLetterSize(playerid, Player(playerid, player_radar)[ 0 ], 0.497555, 1.988267);
    PlayerTextDrawAlignment(playerid, Player(playerid, player_radar)[ 0 ], 1);
    PlayerTextDrawColor(playerid, Player(playerid, player_radar)[ 0 ], 255);
    PlayerTextDrawSetShadow(playerid, Player(playerid, player_radar)[ 0 ], 0);
    PlayerTextDrawSetOutline(playerid, Player(playerid, player_radar)[ 0 ], 0);
    PlayerTextDrawBackgroundColor(playerid, Player(playerid, player_radar)[ 0 ], 51);
    PlayerTextDrawFont(playerid, Player(playerid, player_radar)[ 0 ], 1);
    PlayerTextDrawSetProportional(playerid, Player(playerid, player_radar)[ 0 ], 1);

    Player(playerid, player_radar)[ 1 ] = CreatePlayerTextDraw(playerid, 445.888916, 40.822269, "140");
    PlayerTextDrawLetterSize(playerid, Player(playerid, player_radar)[ 1 ], 0.455333, 1.744356);
    PlayerTextDrawAlignment(playerid, Player(playerid, player_radar)[ 1 ], 1);
    PlayerTextDrawColor(playerid, Player(playerid, player_radar)[ 1 ], 255);
    PlayerTextDrawSetShadow(playerid, Player(playerid, player_radar)[ 1 ], 0);
    PlayerTextDrawSetOutline(playerid, Player(playerid, player_radar)[ 1 ], 0);
    PlayerTextDrawBackgroundColor(playerid, Player(playerid, player_radar)[ 1 ], 51);
    PlayerTextDrawFont(playerid, Player(playerid, player_radar)[ 1 ], 1);
    PlayerTextDrawSetProportional(playerid, Player(playerid, player_radar)[ 1 ], 1);
    
    // Drzwi
    Player(playerid, player_door_td)[ 0 ] = CreatePlayerTextDraw(playerid, 330.000000, 340.000000, "FBI (UID: 4)~n~~n~~y~[BRAK INFORMACJI]~n~Nacisnij ~w~[~k~~SNEAK_ABOUT~]oraz [~k~~PED_SPRINT~]");
	PlayerTextDrawAlignment(playerid, Player(playerid, player_door_td)[ 0 ], 2);
	PlayerTextDrawBackgroundColor(playerid, Player(playerid, player_door_td)[ 0 ], 255);
	PlayerTextDrawFont(playerid, Player(playerid, player_door_td)[ 0 ], 1);
	PlayerTextDrawLetterSize(playerid, Player(playerid, player_door_td)[ 0 ], 0.239999, 0.799998);
	PlayerTextDrawColor(playerid, Player(playerid, player_door_td)[ 0 ], -1);
	PlayerTextDrawSetOutline(playerid, Player(playerid, player_door_td)[ 0 ], 0);
	PlayerTextDrawSetProportional(playerid, Player(playerid, player_door_td)[ 0 ], 1);
	PlayerTextDrawSetShadow(playerid, Player(playerid, player_door_td)[ 0 ], 1);
	PlayerTextDrawUseBox(playerid, Player(playerid, player_door_td)[ 0 ], 1);
	PlayerTextDrawBoxColor(playerid, Player(playerid, player_door_td)[ 0 ], 90);
	PlayerTextDrawTextSize(playerid, Player(playerid, player_door_td)[ 0 ], 0.000000, 171.000000);

	Player(playerid, player_door_td)[ 1 ] = CreatePlayerTextDraw(playerid, 221.500000, 340.000000, "~n~~n~~n~~n~");
	PlayerTextDrawAlignment(playerid, Player(playerid, player_door_td)[ 1 ], 2);
	PlayerTextDrawBackgroundColor(playerid, Player(playerid, player_door_td)[ 1 ], 255);
	PlayerTextDrawFont(playerid, Player(playerid, player_door_td)[ 1 ], 1);
	PlayerTextDrawLetterSize(playerid, Player(playerid, player_door_td)[ 1 ], 0.239998, 0.799000);
	PlayerTextDrawColor(playerid, Player(playerid, player_door_td)[ 1 ], -1);
	PlayerTextDrawSetOutline(playerid, Player(playerid, player_door_td)[ 1 ], 0);
	PlayerTextDrawSetProportional(playerid, Player(playerid, player_door_td)[ 1 ], 1);
	PlayerTextDrawSetShadow(playerid, Player(playerid, player_door_td)[ 1 ], 1);
	PlayerTextDrawUseBox(playerid, Player(playerid, player_door_td)[ 1 ], 1);
	PlayerTextDrawBoxColor(playerid, Player(playerid, player_door_td)[ 1 ], 90);
	PlayerTextDrawTextSize(playerid, Player(playerid, player_door_td)[ 1 ], 0.000000, 38.000000);

	Player(playerid, player_door_td)[ 2 ] = CreatePlayerTextDraw(playerid, 423.500000, 340.000000, "~n~~n~~n~~n~");
	PlayerTextDrawAlignment(playerid, Player(playerid, player_door_td)[ 2 ], 2);
	PlayerTextDrawBackgroundColor(playerid, Player(playerid, player_door_td)[ 2 ], 255);
	PlayerTextDrawFont(playerid, Player(playerid, player_door_td)[ 2 ], 1);
	PlayerTextDrawLetterSize(playerid, Player(playerid, player_door_td)[ 2 ], 0.239998, 0.799898);
	PlayerTextDrawColor(playerid, Player(playerid, player_door_td)[ 2 ], -1);
	PlayerTextDrawSetOutline(playerid, Player(playerid, player_door_td)[ 2 ], 0);
	PlayerTextDrawSetProportional(playerid, Player(playerid, player_door_td)[ 2 ], 1);
	PlayerTextDrawSetShadow(playerid, Player(playerid, player_door_td)[ 2 ], 1);
	PlayerTextDrawUseBox(playerid, Player(playerid, player_door_td)[ 2 ], 1);
	PlayerTextDrawBoxColor(playerid, Player(playerid, player_door_td)[ 2 ], 13107290);
	PlayerTextDrawTextSize(playerid, Player(playerid, player_door_td)[ 2 ], 0.000000, 8.000000);

	// Achivmenty
	Player(playerid, player_achiv_text) = CreatePlayerTextDraw(playerid, 522.0, 0.833435, "_");
	PlayerTextDrawLetterSize(playerid, Player(playerid, player_achiv_text), 0.244319, 1.215000);
	PlayerTextDrawTextSize(playerid, Player(playerid, player_achiv_text), 791.801208, 47.250019);
	PlayerTextDrawAlignment(playerid, Player(playerid, player_achiv_text), 1);
	PlayerTextDrawColor(playerid, Player(playerid, player_achiv_text), -1);
	PlayerTextDrawUseBox(playerid, Player(playerid, player_achiv_text), false);
	PlayerTextDrawBoxColor(playerid, Player(playerid, player_achiv_text), 150);
	PlayerTextDrawSetShadow(playerid, Player(playerid, player_achiv_text), 0);
	PlayerTextDrawSetOutline(playerid, Player(playerid, player_achiv_text), 0);
	PlayerTextDrawBackgroundColor(playerid, Player(playerid, player_achiv_text), 51);
	PlayerTextDrawFont(playerid, Player(playerid, player_achiv_text), 1);
	PlayerTextDrawSetProportional(playerid, Player(playerid, player_achiv_text), 1);
	return 1;
}

FuncPub::LoadTextDraws()
{
	// Panoramika przy logowaniu (czarne boxy)
	Setting(setting_td_box)[ 0 ] = TextDrawCreate(320.000000, 337.000000, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~");
	TextDrawAlignment(Setting(setting_td_box)[ 0 ], 2);
	TextDrawBackgroundColor(Setting(setting_td_box)[ 0 ], 255);
	TextDrawFont(Setting(setting_td_box)[ 0 ], 0);
	TextDrawLetterSize(Setting(setting_td_box)[ 0 ], 1.000000, 3.300000);
	TextDrawColor(Setting(setting_td_box)[ 0 ], -1);
	TextDrawSetOutline(Setting(setting_td_box)[ 0 ], 0);
	TextDrawSetProportional(Setting(setting_td_box)[ 0 ], 1);
	TextDrawSetShadow(Setting(setting_td_box)[ 0 ], 1);
	TextDrawUseBox(Setting(setting_td_box)[ 0 ], 1);
	TextDrawBoxColor(Setting(setting_td_box)[ 0 ], 255);
	TextDrawTextSize(Setting(setting_td_box)[ 0 ], 0.000000, 640.000000);
	TextDrawSetSelectable(Setting(setting_td_box)[ 0 ], 0);

	Setting(setting_td_box)[ 1 ] = TextDrawCreate(650.000000, 0.000000, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~");
	TextDrawBackgroundColor(Setting(setting_td_box)[ 1 ], 255);
	TextDrawFont(Setting(setting_td_box)[ 1 ], 1);
	TextDrawLetterSize(Setting(setting_td_box)[ 1 ], 0.500000, 1.000000);
	TextDrawColor(Setting(setting_td_box)[ 1 ], -1);
	TextDrawSetOutline(Setting(setting_td_box)[ 1 ], 0);
	TextDrawSetProportional(Setting(setting_td_box)[ 1 ], 1);
	TextDrawSetShadow(Setting(setting_td_box)[ 1 ], 1);
	TextDrawUseBox(Setting(setting_td_box)[ 1 ], 1);
	TextDrawBoxColor(Setting(setting_td_box)[ 1 ], 255);
	TextDrawTextSize(Setting(setting_td_box)[ 1 ], -10.000000, 10.000000);
	TextDrawSetSelectable(Setting(setting_td_box)[ 1 ], 0);
	
	// Przedmioty
	Setting(setting_td_item)[ 0 ] = TextDrawCreate(639.500000, 123.000000, "_");
	TextDrawBackgroundColor(Setting(setting_td_item)[ 0 ], 255);
	TextDrawFont(Setting(setting_td_item)[ 0 ], 1);
	TextDrawLetterSize(Setting(setting_td_item)[ 0 ], 0.529999, 16.799999);
	TextDrawColor(Setting(setting_td_item)[ 0 ], -1);
	TextDrawSetOutline(Setting(setting_td_item)[ 0 ], 0);
	TextDrawSetProportional(Setting(setting_td_item)[ 0 ], 1);
	TextDrawSetShadow(Setting(setting_td_item)[ 0 ], 1);
	TextDrawUseBox(Setting(setting_td_item)[ 0 ], 1);
	TextDrawBoxColor(Setting(setting_td_item)[ 0 ], 96);
	TextDrawTextSize(Setting(setting_td_item)[ 0 ], 471.000000, 125.000000);

	Setting(setting_td_item)[ 1 ] = TextDrawCreate(508.000000, 123.000000, "_");
	TextDrawBackgroundColor(Setting(setting_td_item)[ 1 ], 255);
	TextDrawFont(Setting(setting_td_item)[ 1 ], 1);
	TextDrawLetterSize(Setting(setting_td_item)[ 1 ], 0.899999, 15.400001);
	TextDrawColor(Setting(setting_td_item)[ 1 ], -1);
	TextDrawSetOutline(Setting(setting_td_item)[ 1 ], 0);
	TextDrawSetProportional(Setting(setting_td_item)[ 1 ], 1);
	TextDrawSetShadow(Setting(setting_td_item)[ 1 ], 1);
	TextDrawUseBox(Setting(setting_td_item)[ 1 ], 1);
	TextDrawBoxColor(Setting(setting_td_item)[ 1 ], 255);
	TextDrawTextSize(Setting(setting_td_item)[ 1 ], 505.000000, 0.000000);

	Setting(setting_td_item)[ 2 ] = TextDrawCreate(478.000000, 124.000000, "Slot          Nazwa");
	TextDrawBackgroundColor(Setting(setting_td_item)[ 2 ], 255);
	TextDrawFont(Setting(setting_td_item)[ 2 ], 1);
	TextDrawLetterSize(Setting(setting_td_item)[ 2 ], 0.349999, 1.000000);
	TextDrawColor(Setting(setting_td_item)[ 2 ], -1061109505);
	TextDrawSetOutline(Setting(setting_td_item)[ 2 ], 0);
	TextDrawSetProportional(Setting(setting_td_item)[ 2 ], 1);
	TextDrawSetShadow(Setting(setting_td_item)[ 2 ], 1);

	Setting(setting_td_item)[ 3 ] = TextDrawCreate(639.500000, 107.000000, "_");
	TextDrawBackgroundColor(Setting(setting_td_item)[ 3 ], 255);
	TextDrawFont(Setting(setting_td_item)[ 3 ], 1);
	TextDrawLetterSize(Setting(setting_td_item)[ 3 ], 0.299998, 1.400002);
	TextDrawColor(Setting(setting_td_item)[ 3 ], -1);
	TextDrawSetOutline(Setting(setting_td_item)[ 3 ], 0);
	TextDrawSetProportional(Setting(setting_td_item)[ 3 ], 1);
	TextDrawSetShadow(Setting(setting_td_item)[ 3 ], 1);
	TextDrawUseBox(Setting(setting_td_item)[ 3 ], 1);
	TextDrawBoxColor(Setting(setting_td_item)[ 3 ], 149);
	TextDrawTextSize(Setting(setting_td_item)[ 3 ], 471.000000, 0.000000);

	Setting(setting_td_item)[ 4 ] = TextDrawCreate(640.000000, 265.000000, "_");
	TextDrawBackgroundColor(Setting(setting_td_item)[ 4 ], 255);
	TextDrawFont(Setting(setting_td_item)[ 4 ], 1);
	TextDrawLetterSize(Setting(setting_td_item)[ 4 ], 0.299998, 1.000002);
	TextDrawColor(Setting(setting_td_item)[ 4 ], -1);
	TextDrawSetOutline(Setting(setting_td_item)[ 4 ], 0);
	TextDrawSetProportional(Setting(setting_td_item)[ 4 ], 1);
	TextDrawSetShadow(Setting(setting_td_item)[ 4 ], 1);
	TextDrawUseBox(Setting(setting_td_item)[ 4 ], 1);
	TextDrawBoxColor(Setting(setting_td_item)[ 4 ], 64);
	TextDrawTextSize(Setting(setting_td_item)[ 4 ], 471.000000, 0.000000);

	Setting(setting_td_item)[ 5 ] = TextDrawCreate(514.000000, 108.000000, "~g~P~w~rzedmioty");
	TextDrawBackgroundColor(Setting(setting_td_item)[ 5 ], 255);
	TextDrawFont(Setting(setting_td_item)[ 5 ], 1);
	TextDrawLetterSize(Setting(setting_td_item)[ 5 ], 0.429998, 1.200000);
	TextDrawColor(Setting(setting_td_item)[ 5 ], -1);
	TextDrawSetOutline(Setting(setting_td_item)[ 5 ], 0);
	TextDrawSetProportional(Setting(setting_td_item)[ 5 ], 1);
	TextDrawSetShadow(Setting(setting_td_item)[ 5 ], 1);

	Setting(setting_td_item)[ 6 ] = TextDrawCreate(474.000000, 139.000000, "_");
	TextDrawBackgroundColor(Setting(setting_td_item)[ 6 ], 255);
	TextDrawFont(Setting(setting_td_item)[ 6 ], 1);
	TextDrawLetterSize(Setting(setting_td_item)[ 6 ], 0.899999, -0.400000);
	TextDrawColor(Setting(setting_td_item)[ 6 ], -1);
	TextDrawSetOutline(Setting(setting_td_item)[ 6 ], 0);
	TextDrawSetProportional(Setting(setting_td_item)[ 6 ], 1);
	TextDrawSetShadow(Setting(setting_td_item)[ 6 ], 1);
	TextDrawUseBox(Setting(setting_td_item)[ 6 ], 1);
	TextDrawBoxColor(Setting(setting_td_item)[ 6 ], 255);
	TextDrawTextSize(Setting(setting_td_item)[ 6 ], 637.000000, 0.000000);
	
	// Odpalanie silnika
 	Setting(setting_silnik) = TextDrawCreate(245.0, 50.0, "Aby odpalic silnik pojazdu nacisnij ~b~LCTRL~w~ + ~b~LALT ~w~lub wpisz ~b~/odpal~w~.");
    TextDrawUseBox(Setting(setting_silnik), 1);
    TextDrawBoxColor(Setting(setting_silnik), 0x00000055);
    TextDrawLetterSize(Setting(setting_silnik), 0.300000, 1.000000);
    TextDrawTextSize(Setting(setting_silnik), 400.0, 0);
    TextDrawFont(Setting(setting_silnik), 1);
    TextDrawSetShadow(Setting(setting_silnik), 0);
    TextDrawSetOutline(Setting(setting_silnik), 1);
    TextDrawBackgroundColor(Setting(setting_silnik), 0x00000055);
    TextDrawColor(Setting(setting_silnik), 0xFFFFFFff);
    TextDrawSetSelectable(Setting(setting_silnik), 0);
    
    // San News
	Setting(setting_sn)[ 0 ] = TextDrawCreate(318.000000, 437.000000, "~n~~n~");
	TextDrawAlignment(Setting(setting_sn)[ 0 ], 2);
	TextDrawBackgroundColor(Setting(setting_sn)[ 0 ], 255);
	TextDrawFont(Setting(setting_sn)[ 0 ], 1);
	TextDrawLetterSize(Setting(setting_sn)[ 0 ], 0.500000, 1.000000);
	TextDrawColor(Setting(setting_sn)[ 0 ], -1);
	TextDrawSetOutline(Setting(setting_sn)[ 0 ], 0);
	TextDrawSetProportional(Setting(setting_sn)[ 0 ], 1);
	TextDrawSetShadow(Setting(setting_sn)[ 0 ], 1);
	TextDrawUseBox(Setting(setting_sn)[ 0 ], 1);
	TextDrawBoxColor(Setting(setting_sn)[ 0 ], 75);
	TextDrawTextSize(Setting(setting_sn)[ 0 ], 80.000000, -710.000000);

	Setting(setting_sn)[ 1 ] = TextDrawCreate(10.000000, 435.000000, SAN_NEWS);
	TextDrawBackgroundColor(Setting(setting_sn)[ 1 ], 255);
	TextDrawFont(Setting(setting_sn)[ 1 ], 1);
	TextDrawLetterSize(Setting(setting_sn)[ 1 ], 0.189999, 1.299999);
	TextDrawColor(Setting(setting_sn)[ 1 ], -1);
	TextDrawSetOutline(Setting(setting_sn)[ 1 ], 1);
	TextDrawSetProportional(Setting(setting_sn)[ 1 ], 1);

	// Admin Panel
	Setting(setting_admin_head) = TextDrawCreate(318.000000, 150.000000, "Wczytywanie..");
	TextDrawAlignment(Setting(setting_admin_head), 2);
	TextDrawBackgroundColor(Setting(setting_admin_head), 255);
	TextDrawFont(Setting(setting_admin_head), 1);
	TextDrawLetterSize(Setting(setting_admin_head), 0.140000, 1.100000);
	TextDrawColor(Setting(setting_admin_head), -1);
	TextDrawSetOutline(Setting(setting_admin_head), 0);
	TextDrawSetProportional(Setting(setting_admin_head), 1);
	TextDrawSetShadow(Setting(setting_admin_head), 1);
	TextDrawUseBox(Setting(setting_admin_head), 1);
	TextDrawBoxColor(Setting(setting_admin_head), 255);
	TextDrawTextSize(Setting(setting_admin_head), 0.000000, 340.000000);

	Setting(setting_admin_box)[ 0 ] = TextDrawCreate(148.000000, 163.000000, "_");
	TextDrawBackgroundColor(Setting(setting_admin_box)[ 0 ], 255);
	TextDrawFont(Setting(setting_admin_box)[ 0 ], 1);
	TextDrawLetterSize(Setting(setting_admin_box)[ 0 ], 0.500000, 17.200000);
	TextDrawColor(Setting(setting_admin_box)[ 0 ], -1);
	TextDrawSetOutline(Setting(setting_admin_box)[ 0 ], 0);
	TextDrawSetProportional(Setting(setting_admin_box)[ 0 ], 1);
	TextDrawSetShadow(Setting(setting_admin_box)[ 0 ], 1);
	TextDrawUseBox(Setting(setting_admin_box)[ 0 ], 1);
	TextDrawBoxColor(Setting(setting_admin_box)[ 0 ], 150);
	TextDrawTextSize(Setting(setting_admin_box)[ 0 ], 255.000000, 20.000000);

	Setting(setting_admin_box)[ 1 ] = TextDrawCreate(490.750000, 163.000000, "_");
	TextDrawBackgroundColor(Setting(setting_admin_box)[ 1 ], 255);
	TextDrawFont(Setting(setting_admin_box)[ 1 ], 1);
	TextDrawLetterSize(Setting(setting_admin_box)[ 1 ], 0.500000, 17.200000);
	TextDrawColor(Setting(setting_admin_box)[ 1 ], -1);
	TextDrawSetOutline(Setting(setting_admin_box)[ 1 ], 0);
	TextDrawSetProportional(Setting(setting_admin_box)[ 1 ], 1);
	TextDrawSetShadow(Setting(setting_admin_box)[ 1 ], 1);
	TextDrawUseBox(Setting(setting_admin_box)[ 1 ], 1);
	TextDrawBoxColor(Setting(setting_admin_box)[ 1 ], 150);
	TextDrawTextSize(Setting(setting_admin_box)[ 1 ], 382.000000, 20.000000);

	Setting(setting_admin_exit) = TextDrawCreate(404.000000, 297.000000, "Zamknij");
	TextDrawBackgroundColor(Setting(setting_admin_exit), 255);
	TextDrawFont(Setting(setting_admin_exit), 3);
	TextDrawLetterSize(Setting(setting_admin_exit), 0.500000, 1.000000);
	TextDrawColor(Setting(setting_admin_exit), -1);
	TextDrawSetOutline(Setting(setting_admin_exit), 1);
	TextDrawSetProportional(Setting(setting_admin_exit), 1);
	TextDrawTextSize(Setting(setting_admin_exit), 471.000000, 10.000000);
	TextDrawSetSelectable(Setting(setting_admin_exit), 1);

	Setting(setting_admin_report) = TextDrawCreate(153.000000, 172.000000, "Nowe raporty: ~g~X");
	TextDrawBackgroundColor(Setting(setting_admin_report), 255);
	TextDrawFont(Setting(setting_admin_report), 1);
	TextDrawLetterSize(Setting(setting_admin_report), 0.290000, 1.000000);
	TextDrawColor(Setting(setting_admin_report), -1);
	TextDrawSetOutline(Setting(setting_admin_report), 0);
	TextDrawSetProportional(Setting(setting_admin_report), 1);
	TextDrawSetShadow(Setting(setting_admin_report), 1);
	TextDrawTextSize(Setting(setting_admin_report), 237.000000, 10.000000);
	TextDrawSetSelectable(Setting(setting_admin_report), 1);
	
	Setting(setting_admin_duty)[ 0 ] = TextDrawCreate(397.000000, 172.000000, "Wejdz na sluzbe");
	TextDrawBackgroundColor(Setting(setting_admin_duty)[ 0 ], 255);
	TextDrawFont(Setting(setting_admin_duty)[ 0 ], 1);
	TextDrawLetterSize(Setting(setting_admin_duty)[ 0 ], 0.299998, 1.000000);
	TextDrawColor(Setting(setting_admin_duty)[ 0 ], -1);
	TextDrawSetOutline(Setting(setting_admin_duty)[ 0 ], 0);
	TextDrawSetProportional(Setting(setting_admin_duty)[ 0 ], 1);
	TextDrawSetShadow(Setting(setting_admin_duty)[ 0 ], 1);
	TextDrawTextSize(Setting(setting_admin_duty)[ 0 ], 490.000000, 10.000000);
	TextDrawSetSelectable(Setting(setting_admin_duty)[ 0 ], 1);

	Setting(setting_admin_duty)[ 1 ] = TextDrawCreate(397.000000, 172.000000, "Wyjdz ze sluzby");
	TextDrawBackgroundColor(Setting(setting_admin_duty)[ 1 ], 255);
	TextDrawFont(Setting(setting_admin_duty)[ 1 ], 1);
	TextDrawLetterSize(Setting(setting_admin_duty)[ 1 ], 0.299998, 1.000000);
	TextDrawColor(Setting(setting_admin_duty)[ 1 ], -1);
	TextDrawSetOutline(Setting(setting_admin_duty)[ 1 ], 0);
	TextDrawSetProportional(Setting(setting_admin_duty)[ 1 ], 1);
	TextDrawSetShadow(Setting(setting_admin_duty)[ 1 ], 1);
	TextDrawTextSize(Setting(setting_admin_duty)[ 1 ], 490.000000, 10.000000);
	TextDrawSetSelectable(Setting(setting_admin_duty)[ 1 ], 1);
	
	// Tankowanie
	Setting(setting_fuel_td)[ 0 ] = TextDrawCreate(384.000000, 305.000000, "_");
	TextDrawBackgroundColor(Setting(setting_fuel_td)[ 0 ], 255);
	TextDrawFont(Setting(setting_fuel_td)[ 0 ], 1);
	TextDrawLetterSize(Setting(setting_fuel_td)[ 0 ], 0.509998, 9.700003);
	TextDrawColor(Setting(setting_fuel_td)[ 0 ], -1);
	TextDrawSetOutline(Setting(setting_fuel_td)[ 0 ], 0);
	TextDrawSetProportional(Setting(setting_fuel_td)[ 0 ], 1);
	TextDrawSetShadow(Setting(setting_fuel_td)[ 0 ], 1);
	TextDrawUseBox(Setting(setting_fuel_td)[ 0 ], 1);
	TextDrawBoxColor(Setting(setting_fuel_td)[ 0 ], 150);
	TextDrawTextSize(Setting(setting_fuel_td)[ 0 ], 682.000000, 4.000000);

	Setting(setting_fuel_td)[ 1 ] = TextDrawCreate(600.000000, 338.000000, "$");
	TextDrawAlignment(Setting(setting_fuel_td)[ 1 ], 3);
	TextDrawBackgroundColor(Setting(setting_fuel_td)[ 1 ], 255);
	TextDrawFont(Setting(setting_fuel_td)[ 1 ], 1);
	TextDrawLetterSize(Setting(setting_fuel_td)[ 1 ], 0.270000, 1.900000);
	TextDrawColor(Setting(setting_fuel_td)[ 1 ], -1);
	TextDrawSetOutline(Setting(setting_fuel_td)[ 1 ], 0);
	TextDrawSetProportional(Setting(setting_fuel_td)[ 1 ], 1);
	TextDrawSetShadow(Setting(setting_fuel_td)[ 1 ], 1);

	Setting(setting_fuel_td)[ 2 ] = TextDrawCreate(608.000000, 318.000000, "dm");
	TextDrawAlignment(Setting(setting_fuel_td)[ 2 ], 3);
	TextDrawBackgroundColor(Setting(setting_fuel_td)[ 2 ], 255);
	TextDrawFont(Setting(setting_fuel_td)[ 2 ], 1);
	TextDrawLetterSize(Setting(setting_fuel_td)[ 2 ], 0.270000, 1.900000);
	TextDrawColor(Setting(setting_fuel_td)[ 2 ], -1);
	TextDrawSetOutline(Setting(setting_fuel_td)[ 2 ], 0);
	TextDrawSetProportional(Setting(setting_fuel_td)[ 2 ], 1);
	TextDrawSetShadow(Setting(setting_fuel_td)[ 2 ], 1);

	Setting(setting_fuel_td)[ 3 ] = TextDrawCreate(613.000000, 318.000000, "3");
	TextDrawAlignment(Setting(setting_fuel_td)[ 3 ], 3);
	TextDrawBackgroundColor(Setting(setting_fuel_td)[ 3 ], 255);
	TextDrawFont(Setting(setting_fuel_td)[ 3 ], 1);
	TextDrawLetterSize(Setting(setting_fuel_td)[ 3 ], 0.240000, 1.000000);
	TextDrawColor(Setting(setting_fuel_td)[ 3 ], -1);
	TextDrawSetOutline(Setting(setting_fuel_td)[ 3 ], 0);
	TextDrawSetProportional(Setting(setting_fuel_td)[ 3 ], 1);
	TextDrawSetShadow(Setting(setting_fuel_td)[ 3 ], 1);

	Setting(setting_fuel_td)[ 4 ] = TextDrawCreate(558.000000, 362.000000, "$ za litr");
	TextDrawAlignment(Setting(setting_fuel_td)[ 4 ], 3);
	TextDrawBackgroundColor(Setting(setting_fuel_td)[ 4 ], 255);
	TextDrawFont(Setting(setting_fuel_td)[ 4 ], 1);
	TextDrawLetterSize(Setting(setting_fuel_td)[ 4 ], 0.270000, 1.900000);
	TextDrawColor(Setting(setting_fuel_td)[ 4 ], -1);
	TextDrawSetOutline(Setting(setting_fuel_td)[ 4 ], 0);
	TextDrawSetProportional(Setting(setting_fuel_td)[ 4 ], 1);
	TextDrawSetShadow(Setting(setting_fuel_td)[ 4 ], 1);

	Setting(setting_fuel_td)[ 5 ] = TextDrawCreate(400.000000, 322.000000, "_");
	TextDrawBackgroundColor(Setting(setting_fuel_td)[ 5 ], 255);
	TextDrawFont(Setting(setting_fuel_td)[ 5 ], 1);
	TextDrawLetterSize(Setting(setting_fuel_td)[ 5 ], 0.500000, 1.300000);
	TextDrawColor(Setting(setting_fuel_td)[ 5 ], -1);
	TextDrawSetOutline(Setting(setting_fuel_td)[ 5 ], 0);
	TextDrawSetProportional(Setting(setting_fuel_td)[ 5 ], 1);
	TextDrawSetShadow(Setting(setting_fuel_td)[ 5 ], 1);
	TextDrawUseBox(Setting(setting_fuel_td)[ 5 ], 1);
	TextDrawBoxColor(Setting(setting_fuel_td)[ 5 ], 150); // TODO | 51350
	TextDrawTextSize(Setting(setting_fuel_td)[ 5 ], 590.000000, 0.000000);

	Setting(setting_fuel_td)[ 6 ] = TextDrawCreate(400.000000, 341.000000, "_");
	TextDrawBackgroundColor(Setting(setting_fuel_td)[ 6 ], 255);
	TextDrawFont(Setting(setting_fuel_td)[ 6 ], 1);
	TextDrawLetterSize(Setting(setting_fuel_td)[ 6 ], 0.500000, 1.300000);
	TextDrawColor(Setting(setting_fuel_td)[ 6 ], -1);
	TextDrawSetOutline(Setting(setting_fuel_td)[ 6 ], 0);
	TextDrawSetProportional(Setting(setting_fuel_td)[ 6 ], 1);
	TextDrawSetShadow(Setting(setting_fuel_td)[ 6 ], 1);
	TextDrawUseBox(Setting(setting_fuel_td)[ 6 ], 1);
	TextDrawBoxColor(Setting(setting_fuel_td)[ 6 ], 150); // TODO | 51350
	TextDrawTextSize(Setting(setting_fuel_td)[ 6 ], 590.000000, 0.000000);

	Setting(setting_fuel_td)[ 7 ] = TextDrawCreate(465.000000, 366.000000, "_");
	TextDrawBackgroundColor(Setting(setting_fuel_td)[ 7 ], 255);
	TextDrawFont(Setting(setting_fuel_td)[ 7 ], 1);
	TextDrawLetterSize(Setting(setting_fuel_td)[ 7 ], 0.500000, 1.300000);
	TextDrawColor(Setting(setting_fuel_td)[ 7 ], -1);
	TextDrawSetOutline(Setting(setting_fuel_td)[ 7 ], 0);
	TextDrawSetProportional(Setting(setting_fuel_td)[ 7 ], 1);
	TextDrawSetShadow(Setting(setting_fuel_td)[ 7 ], 1);
	TextDrawUseBox(Setting(setting_fuel_td)[ 7 ], 1);
	TextDrawBoxColor(Setting(setting_fuel_td)[ 7 ], 150); // TODO | 51350
	TextDrawTextSize(Setting(setting_fuel_td)[ 7 ], 518.000000, 0.000000);
	
	Setting(setting_selected_bg) = TextDrawCreate(180.000000, 70.000000, "~n~_~n~_~n~_~n~_~n~_~n~_");
	TextDrawBackgroundColor(Setting(setting_selected_bg), 255);
	TextDrawFont(Setting(setting_selected_bg), 1);
	TextDrawLetterSize(Setting(setting_selected_bg), 0.500000, 5.699999);
	TextDrawColor(Setting(setting_selected_bg), -1);
	TextDrawSetOutline(Setting(setting_selected_bg), 0);
	TextDrawSetProportional(Setting(setting_selected_bg), 1);
	TextDrawSetShadow(Setting(setting_selected_bg), 1);
	TextDrawUseBox(Setting(setting_selected_bg), 1);
	TextDrawBoxColor(Setting(setting_selected_bg), 136);
	TextDrawTextSize(Setting(setting_selected_bg), -5.000000, 0.000000);
	
	Setting(setting_selected)[ 0 ] = TextDrawCreate(540.000000, 340.000000, "Graj");
	TextDrawBackgroundColor(Setting(setting_selected)[ 0 ], 51);
	TextDrawFont(Setting(setting_selected)[ 0 ], 1);
	TextDrawLetterSize(Setting(setting_selected)[ 0 ], 0.330000, 1.100000);
	TextDrawColor(Setting(setting_selected)[ 0 ], -1);
	TextDrawSetOutline(Setting(setting_selected)[ 0 ], 1);
	TextDrawSetProportional(Setting(setting_selected)[ 0 ], 1);
	TextDrawUseBox(Setting(setting_selected)[ 0 ], 1);
	TextDrawBoxColor(Setting(setting_selected)[ 0 ], 68);
	TextDrawTextSize(Setting(setting_selected)[ 0 ], 640.000000, 10.000000);
	TextDrawSetSelectable(Setting(setting_selected)[ 0 ], true);
	
	Setting(setting_selected)[ 1 ] = TextDrawCreate(540.000000, 354.000000, "Informacje");
	TextDrawBackgroundColor(Setting(setting_selected)[ 1 ], 51);
	TextDrawFont(Setting(setting_selected)[ 1 ], 1);
	TextDrawLetterSize(Setting(setting_selected)[ 1 ], 0.330000, 1.100000);
	TextDrawColor(Setting(setting_selected)[ 1 ], -1);
	TextDrawSetOutline(Setting(setting_selected)[ 1 ], 1);
	TextDrawSetProportional(Setting(setting_selected)[ 1 ], 1);
	TextDrawUseBox(Setting(setting_selected)[ 1 ], 1);
	TextDrawBoxColor(Setting(setting_selected)[ 1 ], 68);
	TextDrawTextSize(Setting(setting_selected)[ 1 ], 640.000000, 10.000000);
	TextDrawSetSelectable(Setting(setting_selected)[ 1 ], true);
	
	Setting(setting_selected)[ 2 ] = TextDrawCreate(540.000000, 368.000000, "Ustawienia");
	TextDrawBackgroundColor(Setting(setting_selected)[ 2 ], 51);
	TextDrawFont(Setting(setting_selected)[ 2 ], 1);
	TextDrawLetterSize(Setting(setting_selected)[ 2 ], 0.330000, 1.100000);
	TextDrawColor(Setting(setting_selected)[ 2 ], -1);
	TextDrawSetOutline(Setting(setting_selected)[ 2 ], 1);
	TextDrawSetProportional(Setting(setting_selected)[ 2 ], 1);
	TextDrawUseBox(Setting(setting_selected)[ 2 ], 1);
	TextDrawBoxColor(Setting(setting_selected)[ 2 ], 2122480213);
	TextDrawTextSize(Setting(setting_selected)[ 2 ], 640.000000, 10.000000);
	TextDrawSetSelectable(Setting(setting_selected)[ 2 ], true);
	
	Setting(setting_selected)[ 3 ] = TextDrawCreate(540.000000, 382.000000, "Wyjdz");
	TextDrawBackgroundColor(Setting(setting_selected)[ 3 ], 51);
	TextDrawFont(Setting(setting_selected)[ 3 ], 1);
	TextDrawLetterSize(Setting(setting_selected)[ 3 ], 0.330000, 1.100000);
	TextDrawColor(Setting(setting_selected)[ 3 ], -1);
	TextDrawSetOutline(Setting(setting_selected)[ 3 ], 1);
	TextDrawSetProportional(Setting(setting_selected)[ 3 ], 1);
	TextDrawUseBox(Setting(setting_selected)[ 3 ], 1);
	TextDrawBoxColor(Setting(setting_selected)[ 3 ], 68);
	TextDrawTextSize(Setting(setting_selected)[ 3 ], 640.000000, 10.000000);
	TextDrawSetSelectable(Setting(setting_selected)[ 3 ], true);
	
	// Znak drogowy
    Setting(setting_radar)[ 0 ] = TextDrawCreate(439.555297, 20.608011, "O");
    TextDrawLetterSize(Setting(setting_radar)[ 0 ], 1.461110, 6.010312);
    TextDrawAlignment(Setting(setting_radar)[ 0 ], 1);
    TextDrawColor(Setting(setting_radar)[ 0 ], -16776961);
    TextDrawSetShadow(Setting(setting_radar)[ 0 ], 0);
    TextDrawSetOutline(Setting(setting_radar)[ 0 ], -2);
    TextDrawBackgroundColor(Setting(setting_radar)[ 0 ], 51);
    TextDrawFont(Setting(setting_radar)[ 0 ], 1);
    TextDrawSetProportional(Setting(setting_radar)[ 0 ], 1);

    Setting(setting_radar)[ 1 ] = TextDrawCreate(445.888732, 29.074678, "O");
    TextDrawLetterSize(Setting(setting_radar)[ 1 ], 1.005554, 4.183466);
    TextDrawAlignment(Setting(setting_radar)[ 1 ], 1);
    TextDrawColor(Setting(setting_radar)[ 1 ], -1);
    TextDrawSetShadow(Setting(setting_radar)[ 1 ], 0);
    TextDrawSetOutline(Setting(setting_radar)[ 1 ], -1);
    TextDrawBackgroundColor(Setting(setting_radar)[ 1 ], -1);
    TextDrawFont(Setting(setting_radar)[ 1 ], 1);
    TextDrawSetProportional(Setting(setting_radar)[ 1 ], 1);

    Setting(setting_radar)[ 2 ] = TextDrawCreate(453.999816, 35.550243, "O");
    TextDrawLetterSize(Setting(setting_radar)[ 2 ], 0.606443, 2.794667);
    TextDrawAlignment(Setting(setting_radar)[ 2 ], 1);
    TextDrawColor(Setting(setting_radar)[ 2 ], -1);
    TextDrawSetShadow(Setting(setting_radar)[ 2 ], 0);
    TextDrawSetOutline(Setting(setting_radar)[ 2 ], -1);
    TextDrawBackgroundColor(Setting(setting_radar)[ 2 ], -1);
    TextDrawFont(Setting(setting_radar)[ 2 ], 3);
    TextDrawSetProportional(Setting(setting_radar)[ 2 ], 1);
    
    // Grupy
    for(new c; c != MAX_GROUPS; c++)
    {
	    Setting(setting_group_background)[ c ] = TextDrawCreate(320.000000, 130.000000 + (c*20.0), "~n~");
		TextDrawAlignment(Setting(setting_group_background)[ c ], 2);
		TextDrawBackgroundColor(Setting(setting_group_background)[ c ], 255);
		TextDrawFont(Setting(setting_group_background)[ c ], 1);
		TextDrawLetterSize(Setting(setting_group_background)[ c ], 0.500000, 1.600000);
		TextDrawColor(Setting(setting_group_background)[ c ], -1);
		TextDrawSetOutline(Setting(setting_group_background)[ c ], 0);
		TextDrawSetProportional(Setting(setting_group_background)[ c ], 1);
		TextDrawSetShadow(Setting(setting_group_background)[ c ], 1);
		TextDrawUseBox(Setting(setting_group_background)[ c ], 1);
		TextDrawBoxColor(Setting(setting_group_background)[ c ], 100);
		TextDrawTextSize(Setting(setting_group_background)[ c ], 0.000000, 450.000000);

		Setting(setting_group_info)[ c ] = TextDrawCreate(325.500000, 132.500000 + (c*20.0), "Info");
		TextDrawAlignment(Setting(setting_group_info)[ c ], 2);
		TextDrawBackgroundColor(Setting(setting_group_info)[ c ], 255);
		TextDrawFont(Setting(setting_group_info)[ c ], 1);
		TextDrawLetterSize(Setting(setting_group_info)[ c ], 0.239999, 1.100000);
		TextDrawColor(Setting(setting_group_info)[ c ], -1);
		TextDrawSetOutline(Setting(setting_group_info)[ c ], 1);
		TextDrawSetProportional(Setting(setting_group_info)[ c ], 1);
		TextDrawUseBox(Setting(setting_group_info)[ c ], 1);
		TextDrawBoxColor(Setting(setting_group_info)[ c ], 100);
		TextDrawTextSize(Setting(setting_group_info)[ c ], 10.000000, 44.000000);
		TextDrawSetSelectable(Setting(setting_group_info)[ c ], true);

		Setting(setting_group_magazyn)[ c ] = TextDrawCreate(472.500000, 132.500000 + (c*20.0), "Przebierz");
		TextDrawAlignment(Setting(setting_group_magazyn)[ c ], 2);
		TextDrawBackgroundColor(Setting(setting_group_magazyn)[ c ], 255);
		TextDrawFont(Setting(setting_group_magazyn)[ c ], 1);
		TextDrawLetterSize(Setting(setting_group_magazyn)[ c ], 0.239999, 1.100000);
		TextDrawColor(Setting(setting_group_magazyn)[ c ], -1);
		TextDrawSetOutline(Setting(setting_group_magazyn)[ c ], 1);
		TextDrawSetProportional(Setting(setting_group_magazyn)[ c ], 1);
		TextDrawUseBox(Setting(setting_group_magazyn)[ c ], 1);
		TextDrawBoxColor(Setting(setting_group_magazyn)[ c ], 100);
		TextDrawTextSize(Setting(setting_group_magazyn)[ c ], 10.000000, 44.000000);
		TextDrawSetSelectable(Setting(setting_group_magazyn)[ c ], true);

		Setting(setting_group_online)[ c ] = TextDrawCreate(521.500000, 132.500000 + (c*20.0), "On-line");
		TextDrawAlignment(Setting(setting_group_online)[ c ], 2);
		TextDrawBackgroundColor(Setting(setting_group_online)[ c ], 255);
		TextDrawFont(Setting(setting_group_online)[ c ], 1);
		TextDrawLetterSize(Setting(setting_group_online)[ c ], 0.239999, 1.100000);
		TextDrawColor(Setting(setting_group_online)[ c ], -1);
		TextDrawSetOutline(Setting(setting_group_online)[ c ], 1);
		TextDrawSetProportional(Setting(setting_group_online)[ c ], 1);
		TextDrawUseBox(Setting(setting_group_online)[ c ], 1);
		TextDrawBoxColor(Setting(setting_group_online)[ c ], 100);
		TextDrawTextSize(Setting(setting_group_online)[ c ], 10.000000, 44.000000);
		TextDrawSetSelectable(Setting(setting_group_online)[ c ], true);

		Setting(setting_group_duty)[ c ] = TextDrawCreate(423.500000, 132.500000 + (c*20.0), "Sluzba");
		TextDrawAlignment(Setting(setting_group_duty)[ c ], 2);
		TextDrawBackgroundColor(Setting(setting_group_duty)[ c ], 255);
		TextDrawFont(Setting(setting_group_duty)[ c ], 1);
		TextDrawLetterSize(Setting(setting_group_duty)[ c ], 0.239999, 1.100000);
		TextDrawColor(Setting(setting_group_duty)[ c ], -1);
		TextDrawSetOutline(Setting(setting_group_duty)[ c ], 1);
		TextDrawSetProportional(Setting(setting_group_duty)[ c ], 1);
		TextDrawUseBox(Setting(setting_group_duty)[ c ], 1);
		TextDrawBoxColor(Setting(setting_group_duty)[ c ], 100);
		TextDrawTextSize(Setting(setting_group_duty)[ c ], 10.000000, 44.000000);
		TextDrawSetSelectable(Setting(setting_group_duty)[ c ], true);

		Setting(setting_group_duty_on)[ c ] = TextDrawCreate(423.500000, 132.500000 + (c*20.0), "Sluzba");
		TextDrawAlignment(Setting(setting_group_duty_on)[ c ], 2);
		TextDrawBackgroundColor(Setting(setting_group_duty_on)[ c ], 255);
		TextDrawFont(Setting(setting_group_duty_on)[ c ], 1);
		TextDrawLetterSize(Setting(setting_group_duty_on)[ c ], 0.239999, 1.100000);
		TextDrawColor(Setting(setting_group_duty_on)[ c ], 0xFF0000AA);
		TextDrawSetOutline(Setting(setting_group_duty_on)[ c ], 1);
		TextDrawSetProportional(Setting(setting_group_duty_on)[ c ], 1);
		TextDrawUseBox(Setting(setting_group_duty_on)[ c ], 1);
		TextDrawBoxColor(Setting(setting_group_duty_on)[ c ], 100);
		TextDrawTextSize(Setting(setting_group_duty_on)[ c ], 10.000000, 44.000000);
		TextDrawSetSelectable(Setting(setting_group_duty_on)[ c ], true);

		Setting(setting_group_veh)[ c ] = TextDrawCreate(374.500000, 132.500000 + (c*20.0), "Pojazdy");
		TextDrawAlignment(Setting(setting_group_veh)[ c ], 2);
		TextDrawBackgroundColor(Setting(setting_group_veh)[ c ], 255);
		TextDrawFont(Setting(setting_group_veh)[ c ], 1);
		TextDrawLetterSize(Setting(setting_group_veh)[ c ], 0.239999, 1.100000);
		TextDrawColor(Setting(setting_group_veh)[ c ], -1);
		TextDrawSetOutline(Setting(setting_group_veh)[ c ], 1);
		TextDrawSetProportional(Setting(setting_group_veh)[ c ], 1);
		TextDrawUseBox(Setting(setting_group_veh)[ c ], 1);
		TextDrawBoxColor(Setting(setting_group_veh)[ c ], 100);
		TextDrawTextSize(Setting(setting_group_veh)[ c ], 10.000000, 44.000000);
		TextDrawSetSelectable(Setting(setting_group_veh)[ c ], true);
    }
    Setting(setting_group_out)[ 0 ] = TextDrawCreate(94.000000, 132.000000, "Slot_____Nazwa grupy");
	TextDrawBackgroundColor(Setting(setting_group_out)[ 0 ], 255);
	TextDrawFont(Setting(setting_group_out)[ 0 ], 1);
	TextDrawLetterSize(Setting(setting_group_out)[ 0 ], 0.200000, 1.200000);
	TextDrawColor(Setting(setting_group_out)[ 0 ], 177351935);
	TextDrawSetOutline(Setting(setting_group_out)[ 0 ], 1);
	TextDrawSetProportional(Setting(setting_group_out)[ 0 ], 1);

	Setting(setting_group_out)[ 1 ] = TextDrawCreate(301.000000, 132.000000, "Opcje dodatkowe");
	TextDrawBackgroundColor(Setting(setting_group_out)[ 1 ], 255);
	TextDrawFont(Setting(setting_group_out)[ 1 ], 1);
	TextDrawLetterSize(Setting(setting_group_out)[ 1 ], 0.200000, 1.200000);
	TextDrawColor(Setting(setting_group_out)[ 1 ], 177351935);
	TextDrawSetOutline(Setting(setting_group_out)[ 1 ], 1);
	TextDrawSetProportional(Setting(setting_group_out)[ 1 ], 1);
	
	// Achivmenty
	Setting(setting_achiv)[ 0 ] = TextDrawCreate(498.652343, 0.833435, "~n~~n~");
	TextDrawLetterSize(Setting(setting_achiv)[ 0 ], 0.244319, 1.215000);
	TextDrawTextSize(Setting(setting_achiv)[ 0 ], 791.801208, 47.250019);
	TextDrawAlignment(Setting(setting_achiv)[ 0 ], 1);
	TextDrawColor(Setting(setting_achiv)[ 0 ], -1);
	TextDrawUseBox(Setting(setting_achiv)[ 0 ], true);
	TextDrawBoxColor(Setting(setting_achiv)[ 0 ], 150);
	TextDrawSetShadow(Setting(setting_achiv)[ 0 ], 0);
	TextDrawSetOutline(Setting(setting_achiv)[ 0 ], 0);
	TextDrawBackgroundColor(Setting(setting_achiv)[ 0 ], 51);
	TextDrawFont(Setting(setting_achiv)[ 0 ], 1);
	TextDrawSetProportional(Setting(setting_achiv)[ 0 ], 1);

	Setting(setting_achiv)[ 1 ] = TextDrawCreate(494.652343, -2.0, "_");
	TextDrawFont(Setting(setting_achiv)[ 1 ], TEXT_DRAW_FONT_MODEL_PREVIEW);
	TextDrawBackgroundColor(Setting(setting_achiv)[ 1 ], 0);
	TextDrawTextSize(Setting(setting_achiv)[ 1 ], 30.0, 30.0);
	TextDrawSetPreviewRot(Setting(setting_achiv)[ 1 ], 0.0, 0.0, 00.0, 1.0);
	TextDrawSetPreviewModel(Setting(setting_achiv)[ 1 ], 1247);
	
	Setting(setting_red) = TextDrawCreate(0.0, 0.0, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~");
	TextDrawUseBox(Setting(setting_red), 1);
	TextDrawBoxColor(Setting(setting_red), 0xFF000066);
	TextDrawTextSize(Setting(setting_red), 640.0, 400.0);

	Setting(setting_black) = TextDrawCreate(0.0, 0.0, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~");
	TextDrawUseBox(Setting(setting_black), 1);
	TextDrawBoxColor(Setting(setting_black), 0x000000FF);
	TextDrawTextSize(Setting(setting_black), 640.0, 400.0);
	return 1;
}


stock NickSamp(playerid, bool:u = false)
{
	new playername[ MAX_PLAYER_NAME ];
	GetPlayerName(playerid, playername, sizeof(playername));
	if(u) UnderscoreToSpace(playername);
	return playername;
}

stock NickName(playerid)
{
	new playername[ MAX_PLAYER_NAME ];
	if(Player(playerid, player_aduty) && Player(playerid, player_adminlvl))
	    format(playername, sizeof playername, Player(playerid, player_gname));
	else if(Player(playerid, player_mask) == -1)
	{
	    GetPVarString(playerid, "mask-name", playername, sizeof playername);
	    UnderscoreToSpace(playername);
	}
	else if(Player(playerid, player_mask))
	{
	    new kod[ 10 ];
		format(kod, sizeof kod, MD5_Hash(Player(playerid, player_mask)));
		strdel(kod, 4, strlen(kod));
		for(new d; d != strlen(kod); d++) kod[ d ] = toupper(kod[ d ]);
	    format(playername, sizeof playername, "Nieznajomy %s", kod);
	}
	else
	{
	    format(playername, sizeof playername, Player(playerid, player_name));
		UnderscoreToSpace(playername);
	}
	return playername;
}

stock UnderscoreToSpace(name[])
{
	new pos = strfind(name, "_", true);
	while(pos != -1)
	{
		name[pos] = ' ';
        pos = strfind(name, "_", true);
	}
}

stock AntyUnderscoreToSpace(name[])
{
	new pos = strfind(name, " ", true);
	while(pos != -1)
	{
		name[pos] = '_';
        pos = strfind(name, " ", true);
	}
	return name;
}

stock SetPlayerPosEx(playerid, Float:X, Float:Y, Float:Z, Float:A = 0.0)
{
	SetPlayerPos(playerid, X, Y, Z);
	if(!A) GetPlayerFacingAngle(playerid, A);
	SetPlayerFacingAngle(playerid, A);
	
	Player(playerid, player_position)[ 0 ] = X;
	Player(playerid, player_position)[ 1 ] = Y;
	Player(playerid, player_position)[ 2 ] = Z;
	Player(playerid, player_position)[ 3 ] = A;
}

stock PutPlayerInVehicleEx(playerid, vehicleid, seatid)
{
	PutPlayerInVehicle(playerid, vehicleid, seatid);
}

stock RemovePlayerFromVehicleEx(playerid)
{
	RemovePlayerFromVehicle(playerid);
}

FuncPub::UnFreezePlayer(playerid)
{
	Player(playerid, player_freezed) = false;
    TogglePlayerControllable(playerid, true);
	return 1;
}

FuncPub::FreezePlayer(playerid)
{
	GetPlayerPos(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]);
	GetPlayerFacingAngle(playerid, Player(playerid, player_position)[ 3 ]);

	Player(playerid, player_vw) = GetPlayerVirtualWorld(playerid);
	Player(playerid, player_int) = GetPlayerInterior(playerid);
	FreezePlayerEx(playerid);
	return 1;
}

FuncPub::FreezePlayerEx(playerid)
{
	Player(playerid, player_freezed) = true;
    TogglePlayerControllable(playerid, false);
	return 1;
}

stock name_add_tabs(names[])
{
	new ret[ 128 ],
		len = strlen(names);
	if(len <= 4)		format(ret, sizeof ret, "%s\t\t\t", names);
	else if(len <= 8)	format(ret, sizeof ret, "%s\t\t", names);
	else if(len <= 12)	format(ret, sizeof ret, "%s\t", names);
	else				format(ret, sizeof ret, "%s\t\t", names);
	return ret;
}

stock GetPlayerSpeed(playerid)
{
	new Float:ST[ 4 ];
	GetPlayerVelocity(playerid, ST[ 0 ], ST[ 1 ], ST[ 2 ]);
	ST[ 3 ] = floatsqroot(floatpower(floatabs(ST[ 0 ]), 2.0) + floatpower(floatabs(ST[ 1 ]), 2.0) + floatpower(floatabs(ST[ 2 ]), 2.0)) * 169;
	return floatround(ST[ 3 ])/2;
}

stock Float:GetPlayerSpeedXY(playerid)
{
	new Float:SpeedX, Float:SpeedY, Float:SpeedZ;
	new Float:Speed;
	if(IsPlayerInAnyVehicle(playerid)) GetVehicleVelocity(GetPlayerVehicleID(playerid), SpeedX, SpeedY, SpeedZ);
	else GetPlayerVelocity(playerid, SpeedX, SpeedY, SpeedZ);
	Speed = floatsqroot(floatadd(floatpower(SpeedX, 2.0), floatpower(SpeedY, 2.0)));
	return floatmul(Speed, 200.0);
}

Float:GetVehSpeed(vehid)
{
	new
		Float:velX,
		Float:velY,
		Float:velZ,
		Float:speed;

	GetVehicleVelocity(vehid, velX, velY, velZ);
	speed = floatsqroot(velX * velX + velY * velY + velZ * velZ);
	return speed*150;
}

stock SendClientMessageEx(Float:range, playerid, message[], col1, col2, col3, col4, col5, bool:echo = false/*, bool:lang = false, text[] = ""*/)
{
	new Float:pos[ 3 ],
		virtual = GetPlayerVirtualWorld(playerid);
	GetPlayerPos(playerid, pos[ 0 ], pos[ 1 ], pos[ 2 ]);
	foreach(Player, i)
	{
		if(GetPlayerVirtualWorld(i) != virtual)
			continue;
		if(echo == true && i == playerid)
			continue;
			
		/*if(lang == true)
		{
		    if(!(Player(i, player_lang) & Player(playerid, player_lang)))
			{
			    if(isnull(text)) continue;
			    
			    for(new l, len = strlen(text); l != len; l++)
			    {
			        if(text[l] == ' ') continue;
			        text[l] = '?';
			    }
			    format(message, sizeof message, text);
			}
		}*/
//		if(echo == false && Player(i, player_bw))
//			continue;

		if(IsPlayerInRangeOfPoint(i, range/16, pos[ 0 ], pos[ 1 ], pos[ 2 ]))
			SendClientMessage(i, col1, message);
		else if(IsPlayerInRangeOfPoint(i, range/8, pos[ 0 ], pos[ 1 ], pos[ 2 ]))
			SendClientMessage(i, col2, message);
		else if(IsPlayerInRangeOfPoint(i, range/4, pos[ 0 ], pos[ 1 ], pos[ 2 ]))
			SendClientMessage(i, col3, message);
		else if(IsPlayerInRangeOfPoint(i, range/2, pos[ 0 ], pos[ 1 ], pos[ 2 ]))
			SendClientMessage(i, col4, message);
		else if(IsPlayerInRangeOfPoint(i, range, pos[ 0 ], pos[ 1 ], pos[ 2 ]))
			SendClientMessage(i, col5, message);
	}
	return 1;
}

stock GivePlayerMoneyEx(playerid, Float:cash, bool:show = false)
{
    Player(playerid, player_cash) += cash;
    SetPlayerMoney(playerid, Player(playerid, player_cash));
    
	if(show)
	{
	    new str[ 64 ];

	    if(cash < 0)
			format(str, sizeof str, "~r~- $%.2f", cash * -1);
	    else if(cash > 0)
			format(str, sizeof str, "+ $%.2f", cash);
		else return 1;
		PlayerTextDrawSetString(playerid, Player(playerid, player_cash_add), str);
		PlayerTextDrawShow(playerid, Player(playerid, player_cash_add));
		if(Player(playerid, player_cash_timer)) KillTimer(Player(playerid, player_cash_timer));
		Player(playerid, player_cash_timer) = SetTimerEx("CashOff", 3000, false, "d", playerid);
	}
	return 1;
}

FuncPub::CashOff(playerid)
{
	PlayerTextDrawHide(playerid, Player(playerid, player_cash_add));
    KillTimer(Player(playerid, player_cash_timer));
    Player(playerid, player_cash_timer) = 0;
	return 1;
}

stock SetPlayerMoney(playerid, Float:cash)
{
	Player(playerid, player_cash) = cash;
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, floatval(cash));

	new string[ 126 ],
        grosze;
	grosze = floatval((cash - floatval(cash)) * 100);

	if(0.00 <= grosze <= 0.09) format(string, sizeof string, ".0%d", grosze);
	else format(string, sizeof string, ".%02d", grosze);
	
	PlayerTextDrawSetString(playerid, Player(playerid, player_cash_td), string);

	format(string, sizeof string, "UPDATE `surv_players` SET `cash` = '%.2f' WHERE `uid` = '%d'",
	    cash,
	    Player(playerid, player_uid)
	);
	mysql_query(string);
	return 1;
}

stock GivePlayerHealthEx(playerid, Float:value, bool:Max100HP = true, Float:maxhp = 100.0)
{
	if(Max100HP == true)
	{
		if(Player(playerid, player_hp) + value > maxhp)
			Player(playerid, player_hp) = maxhp;
		else
			Player(playerid, player_hp) += value;
	}
	else
		Player(playerid, player_hp) += value;

	SetPlayerHealth(playerid, Player(playerid, player_hp));

	Player(playerid, player_color) = player_nick_green;
	if((Player(playerid, player_screen) + floatval(floatdiv(value, 10.0))+1) < 15)
		Player(playerid, player_screen) += floatval(floatdiv(value, 10.0))+1;
	else
	    Player(playerid, player_screen) = 15;
	UpdatePlayerNick(playerid);
	return 1;
}

stock GetVehicleMaxFuel(model)
{
	if(model == 400) return 70;
	else if(model == 401) return 52;
	else if(model == 402) return 60;
	else if(model == 403) return 400;
	else if(model == 404) return 50;
	else if(model == 405) return 52;
	else if(model == 406) return 150;
	else if(model == 407) return 250;
	else if(model == 408) return 150;
	else if(model == 409) return 110;
	else if(model == 410) return 66;
	else if(model == 411) return 66;
	else if(model == 412) return 52;
	else if(model == 413) return 80;
	else if(model == 414) return 120;
	else if(model == 415) return 76;
	else if(model == 416) return 120;
	else if(model == 417) return 408;
	else if(model == 418) return 80;
	else if(model == 419) return 72;
	else if(model == 420) return 80;
	else if(model == 421) return 82;
	else if(model == 422) return 80;
	else if(model == 423) return 90;
	else if(model == 424) return 30;
	else if(model == 425) return 500;
	else if(model == 426) return 70;
	else if(model == 427) return 120;
	else if(model == 428) return 120;
	else if(model == 429) return 68;
	else if(model == 430) return 220;
	else if(model == 431) return 315;
	else if(model == 432) return 1020;
	else if(model == 433) return 430;
	else if(model == 434) return 30;
	else if(model == 435) return 0;
	else if(model == 436) return 60;
	else if(model == 437) return 310;
	else if(model == 438) return 80;
	else if(model == 439) return 72;
	else if(model == 440) return 80;
	else if(model == 441) return 0;
	else if(model == 442) return 61;
	else if(model == 443) return 180;
	else if(model == 444) return 162;
	else if(model == 445) return 56;
	else if(model == 446) return 101;
	else if(model == 447) return 140;
	else if(model == 448) return 7;
	else if(model == 449) return 0;
	else if(model == 450) return 0;
	else if(model == 451) return 78;
	else if(model == 452) return 111;
	else if(model == 453) return 201;
	else if(model == 454) return 221;
	else if(model == 455) return 198;
	else if(model == 456) return 101;
	else if(model == 457) return 15;
	else if(model == 458) return 70;
	else if(model == 459) return 84;
	else if(model == 460) return 30;
	else if(model == 461) return 25;
	else if(model == 462) return 7;
	else if(model == 463) return 30;
	else if(model == 464) return 0;
	else if(model == 465) return 0;
	else if(model == 466) return 71;
	else if(model == 467) return 61;
	else if(model == 468) return 27;
	else if(model == 469) return 50;
	else if(model == 470) return 110;
	else if(model == 471) return 35;
	else if(model == 472) return 110;
	else if(model == 473) return 69;
	else if(model == 474) return 70;
	else if(model == 475) return 71;
	else if(model == 476) return 68;
	else if(model == 477) return 69;
	else if(model == 478) return 45;
	else if(model == 479) return 61;
	else if(model == 480) return 67;
	else if(model == 481) return 0;
	else if(model == 482) return 96;
	else if(model == 483) return 75;
	else if(model == 484) return 87;
	else if(model == 485) return 40;
	else if(model == 486) return 141;
	else if(model == 487) return 123;
	else if(model == 488) return 121;
	else if(model == 489) return 91;
	else if(model == 490) return 101;
	else if(model == 491) return 81;
	else if(model == 492) return 62;
	else if(model == 493) return 130;
	else if(model == 494) return 99;
	else if(model == 495) return 81;
	else if(model == 496) return 61;
	else if(model == 497) return 140;
	else if(model == 498) return 121;
	else if(model == 499) return 104;
	else if(model == 500) return 71;
	else if(model == 501) return 0;
	else if(model == 502) return 96;
	else if(model == 503) return 97;
	else if(model == 504) return 91;
	else if(model == 505) return 84;
	else if(model == 506) return 67;
	else if(model == 507) return 81;
	else if(model == 508) return 133;
	else if(model == 509) return 0;
	else if(model == 510) return 0;
	else if(model == 511) return 210;
	else if(model == 512) return 130;
	else if(model == 513) return 54;
	else if(model == 514) return 300;
	else if(model == 515) return 300;
	else if(model == 516) return 63;
	else if(model == 517) return 64;
	else if(model == 518) return 67;
	else if(model == 519) return 300;
	else if(model == 520) return 290;
	else if(model == 521) return 35;
	else if(model == 522) return 35;
	else if(model == 523) return 121;
	else if(model == 524) return 91;
	else if(model == 525) return 65;
	else if(model == 526) return 63;
	else if(model == 527) return 71;
	else if(model == 528) return 71;
	else if(model == 529) return 67;
	else if(model == 530) return 12;
	else if(model == 531) return 21;
	else if(model == 532) return 36;
	else if(model == 533) return 61;
	else if(model == 534) return 71;
	else if(model == 535) return 85;
	else if(model == 536) return 69;
	else if(model == 537) return 0;
	else if(model == 538) return 0;
	else if(model == 539) return 33;
	else if(model == 540) return 60;
	else if(model == 541) return 71;
	else if(model == 542) return 69;
	else if(model == 543) return 60;
	else if(model == 544) return 120;
	else if(model == 545) return 74;
	else if(model == 546) return 64;
	else if(model == 547) return 67;
	else if(model == 548) return 210;
	else if(model == 549) return 71;
	else if(model == 550) return 64;
	else if(model == 551) return 64;
	else if(model == 552) return 68;
	else if(model == 553) return 330;
	else if(model == 554) return 81;
	else if(model == 555) return 61;
	else if(model == 556) return 123;
	else if(model == 557) return 124;
	else if(model == 558) return 61;
	else if(model == 559) return 63;
	else if(model == 560) return 71;
	else if(model == 561) return 74;
	else if(model == 562) return 66;
	else if(model == 563) return 210;
	else if(model == 564) return 0;
	else if(model == 565) return 57;
	else if(model == 566) return 65;
	else if(model == 567) return 66;
	else if(model == 568) return 45;
	else if(model == 569) return 0;
	else if(model == 570) return 0;
	else if(model == 571) return 10;
	else if(model == 572) return 10;
	else if(model == 573) return 121;
	else if(model == 574) return 21;
	else if(model == 575) return 71;
	else if(model == 576) return 75;
	else if(model == 577) return 900;
	else if(model == 578) return 210;
	else if(model == 579) return 85;
	else if(model == 580) return 80;
	else if(model == 581) return 31;
	else if(model == 582) return 81;
	else if(model == 583) return 20;
	else if(model == 584) return 0;
	else if(model == 585) return 64;
	else if(model == 586) return 30;
	else if(model == 587) return 66;
	else if(model == 588) return 79;
	else if(model == 589) return 59;
	else if(model == 590) return 0;
	else if(model == 591) return 0;
	else if(model == 592) return 0;
	else if(model == 593) return 110;
	else if(model == 594) return 0;
	else if(model == 595) return 151;
	else if(model == 596) return 89;
	else if(model == 597) return 89;
	else if(model == 598) return 89;
	else if(model == 599) return 94;
	else if(model == 600) return 61;
	else if(model == 601) return 120;
	else if(model == 602) return 61;
	else if(model == 603) return 59;
	else if(model == 604) return 91;
	else if(model == 605) return 64;
	else if(model == 606) return 0;
	else if(model == 607) return 0;
	else if(model == 608) return 0;
	else if(model == 609) return 99;
	else if(model == 610) return 0;
	else if(model == 611) return 0;
	else return 50;
}

stock SendWrappedMessageToPlayerRange(playerid, col1, col2, col3, col4, col5, msg[], range = 20, maxlength=100, const prefix[]="...")
{
    new length = strlen(msg);
    if(length <= maxlength) {
        SendClientMessageEx(range, playerid, msg, col1, col2, col3, col4, col5);
        return;
    }
    new string[ 150 ], idx;
    for(new i, space, plen, bool:useprefix; i < length; i++) {
        if(i - idx + plen >= maxlength) {
            if(idx == space || i - space >= 25) {
                strmid(string, msg, idx, i);
                idx = i;
            } else {
                strmid(string, msg, idx, space);
                idx = space + 1;
            }
            if(useprefix) {
                strins(string, prefix, 0);
            } else {
                plen = strlen(prefix);
                useprefix = true;
            }
            format(string, sizeof(string), "%s...", string);
        	SendClientMessageEx(range, playerid, string, col1, col2, col3, col4, col5);
        } else if(msg[ i ] == ' ') {
            space = i;
        }
    }
    if(idx < length) {
        strmid(string, msg, idx, length);
        strins(string, prefix, 0);
        SendClientMessageEx(range, playerid, string, col1, col2, col3, col4, col5);
    }
    return;
}

stock SendWrappedMessageToPlayer(playerid, col, msg[], maxlength=100, const prefix[]="...")
{
    new length = strlen(msg);
    if(length <= maxlength) {
        SendClientMessage(playerid, col, msg);
        return;
    }
    new string[ 150 ], idx;
    for(new i, space, plen, bool:useprefix; i < length; i++) {
        if(i - idx + plen >= maxlength) {
            if(idx == space || i - space >= 25) {
                strmid(string, msg, idx, i);
                idx = i;
            } else {
                strmid(string, msg, idx, space);
                idx = space + 1;
            }
            if(useprefix) {
                strins(string, prefix, 0);
            } else {
                plen = strlen(prefix);
                useprefix = true;
            }
            format(string, sizeof(string), "%s...", string);
        	SendClientMessage(playerid, col, string);
        } else if(msg[ i ] == ' ') {
            space = i;
        }
    }
    if(idx < length) {
        strmid(string, msg, idx, length);
        strins(string, prefix, 0);
        SendClientMessage(playerid, col, string);
    }
    return;
}
