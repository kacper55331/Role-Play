/*
Zakumplujmy si�! - (aktywowany po zyskaniu pierwszego przyjaciela) - 150 ipoint�w
Pierwsze zatrudnienie - (aktywowany po przyj�ciu invite od lidera biznesu/frakcji) - 200 ipoint�w
Wreszcie pojazd! - (aktywowany po zakupie pierwszego pojazdu z silnikiem) - 400 ipoint�w
Ma�e oszcz�dno�ci -  (aktywowany po uzbieraniu 2000 dolar�w na koncie bankowym) - 600 ipoint�w
Sta�y gracz - (aktywowany po wbiciu 100 godzin na serwerze) - 1.200 ipoint�w
Poszkodowany - (aktywowany po otrzymaniu pierwszego BW od gracza) - -100 ipoint�w
W�asne cztery �ciany - (aktywowany po kupnie domu lub wynajmu mieszkania) - 500 ipoint�w
Zwyci�zca - (aktywowany po wygraniu pierwszej b�jki) - 300 ipoint�w
Zaczynamy pakowa� - (aktywowany po pierwszym treningu na si�owni) - 400 ipoint�w
Przyjacielski - (aktywowany po zyskaniu 20 przyjaci�) - 800 ipoint�w
Lider frakcji - (aktywowany po otrzymaniu lidera grupy publicznej) - 5000 ipoint�w
W�asny biznes - (aktywowany po otwarciu w�asnego biznesu) - 3000 ipoint�w
Przywi�zany - (aktywowany po wbiciu 1000 godzin na jednej postaci) - 5000 ipoint�w
Mandacik! - (aktywowany po otrzymaniu mandatu od policjanta) - -300 ipoint�w
Pierwsza wyp�ata - (aktywowany po otrzymaniu pierwszego PD) - 200 ipoint�w
Wi�ksze oszcz�dno�ci - (aktywowany po uzbieraniu 10.000 dolar�w na koncie bankowym) - 1.500 ipoint�w
Przedsi�biorca - (aktywowany po uzbieraniu 50.000 dolar�w na koncie bankowym) - 3000 ipoint�w
Pora postrzela�! - (aktywowany po zyskaniu pierwszej broni palnej) - 800 ipoint�w
Bogacz - (aktywowany po uzbieraniu 100.000 dolar�w na koncie bankowym) - 5.000 ipoint�w
Nie ma lipy! - (aktywowany po wbiciu 3500j na si�owni) - 2000 ipoint�w
Ukarany - (aktywowany po otrzymaniu pierwszej kary od zarz�du) - -500 ipoint�w
Krokami Rockefellera! - (aktywowany po uzbieraniu 500.000 dolar�w na koncie) - 8000 ipoint�w
Milioner!! - (aktywowany po uzbieraniu 1.000.000 dolar�w na koncie) - 15.000 ipoint�w

Sta�y bywalec:Pierwsze 10 godzin na serwerze. +100
Nowa praca, nowe wydatki.:Pierwsza wyp�ata. +120
Jeste� rozchwytywany!:Zdoby�e� dziesi�� kontakt�w na telefon. +150
Ale wpad�e�!:Pierwsza noc w pudle +50
Zapach nowego samochodu: Kupi�e� pierwszy samoch�d +200

Dusza towarzystwa: Zbierz 20 kontakt�w w telefonie, 50ipoints.
Pierwszy pojazd: Dowolny pojazd na /v,  300ipoints
Oszcz�dno�ci: Zgromad� 5 tysi�cy na koncie bankowym, 250ipoints
Wsz�dzie dobrze ale w domu najlepiej: Posiadanie panelu domu, 400ipoints
Sta�y gracz: Przegraj 50 godzin postaci� na serwerze, 100ipoints
B�g pla�y: Zdob�d� "muskularny", 1000ipoints
Motomaniak: Posiadaj pi�� pojazd�w na /v, 2000ipoints
Kr�l nieruchomo�ci: Posiadaj pi�� paneli dom�w, 3500ipoints
Legalna praca: Zdob�d� pierwsze zatrudnienie, 500ipoints
Biznesman: Posiadaj w�asny biznes, 1500ipoints
Przyw�dca: Posiadaj w�asn� organizacje, 1500ipoints
Lider: Posiadaj w�asn� frakcje, 2000ipoints
A.C.A.B: B�d� aresztowany po raz pierwszy, 100ipoints
Karniak: B�d� wys�any do AdminJail, -150ipoints
*/
stock bool:GetPlayerAchiv(playerid, achiv_type)
{
	if(Player(playerid, player_achiv) & achiv_type)
		return true;
	return false;
}

FuncPub::GivePlayerAchiv(playerid, achiv_type)
{
	if(GetPlayerAchiv(playerid, achiv_type))
		return 0;
	
	Player(playerid, player_achiv) += achiv_type;
	Audio_Play(playerid, achiv_sound);
	
	new string[ 100 ];
	format(string, sizeof string, 
		"INSERT INTO `all_achiv` VALUES (NULL, '%d', '%d', UNIX_TIMESTAMP(), '"#type_rp"')",
		Player(playerid, player_uid),
		achiv_type
	);
	mysql_query(string);
	

	new id;
	for(; id != sizeof AchivData; id++)
	    if(AchivData[ id ][ achiv_bit ] == achiv_type)
	        break;
	        
	if(id == sizeof AchivData) return 1;

	if(AchivData[ id ][ achiv_gp ])
	{
		format(string, sizeof string,
		    "UPDATE `"IN_PREF"members` SET `score` = `score` + '%d' WHERE `member_id` = '%d'",
		    AchivData[ id ][ achiv_gp ],
		    Player(playerid, player_guid)
		);
		mysql_query(string);
		
		SetPlayerScore(playerid, GetPlayerScore(playerid) + AchivData[ id ][ achiv_gp ]);
	}
	format(string, sizeof(string),
		"~w~ODBLOKOWANO OSIAGNIECIE~n~%s%dGS - %s",
		AchivData[ id ][ achiv_gp ] <= 0 ? ("~r~") : ("~g~"),
		AchivData[ id ][ achiv_gp ],
		AchivData[ id ][ achiv_name ]
	);
 	PlayerTextDrawSetString(playerid, Player(playerid, player_achiv_text), string);
 	PlayerTextDrawShow(playerid, Player(playerid, player_achiv_text));
 	TextDrawShowForPlayer(playerid, Setting(setting_achiv)[ 0 ]);
 	TextDrawShowForPlayer(playerid, Setting(setting_achiv)[ 1 ]);
 	
 	if(Player(playerid, player_achiv_timer))
 		KillTimer(Player(playerid, player_achiv_timer));
 	Player(playerid, player_achiv_timer) = SetTimerEx("HideAchiv", 5000, false, "d", playerid);
	return 1;
}

FuncPub::HideAchiv(playerid)
{
 	PlayerTextDrawHide(playerid, Player(playerid, player_achiv_text));
 	TextDrawHideForPlayer(playerid, Setting(setting_achiv)[ 0 ]);
 	TextDrawHideForPlayer(playerid, Setting(setting_achiv)[ 1 ]);
 	Player(playerid, player_achiv_timer) = 0;
	return 1;
}

FuncPub::DeletePlayerAchiv(playerid, achiv_type)
{
	if(!GetPlayerAchiv(playerid, achiv_type))
		return 0;

	Player(playerid, player_achiv) -= achiv_type;
	
	new string[ 100 ];
	format(string, sizeof string,
		"DELETE FROM `all_achiv` WHERE `player` = '%d' AND `type` = '%d' AND `server` = '"#type_rp"'",
		Player(playerid, player_uid),
		achiv_type
	);
	mysql_query(string);
	return 1;
}
