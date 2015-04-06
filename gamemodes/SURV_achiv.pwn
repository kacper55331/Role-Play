/*
Zakumplujmy siê! - (aktywowany po zyskaniu pierwszego przyjaciela) - 150 ipointów
Pierwsze zatrudnienie - (aktywowany po przyjêciu invite od lidera biznesu/frakcji) - 200 ipointów
Wreszcie pojazd! - (aktywowany po zakupie pierwszego pojazdu z silnikiem) - 400 ipointów
Ma³e oszczêdnoœci -  (aktywowany po uzbieraniu 2000 dolarów na koncie bankowym) - 600 ipointów
Sta³y gracz - (aktywowany po wbiciu 100 godzin na serwerze) - 1.200 ipointów
Poszkodowany - (aktywowany po otrzymaniu pierwszego BW od gracza) - -100 ipointów
W³asne cztery œciany - (aktywowany po kupnie domu lub wynajmu mieszkania) - 500 ipointów
Zwyciêzca - (aktywowany po wygraniu pierwszej bójki) - 300 ipointów
Zaczynamy pakowaæ - (aktywowany po pierwszym treningu na si³owni) - 400 ipointów
Przyjacielski - (aktywowany po zyskaniu 20 przyjació³) - 800 ipointów
Lider frakcji - (aktywowany po otrzymaniu lidera grupy publicznej) - 5000 ipointów
W³asny biznes - (aktywowany po otwarciu w³asnego biznesu) - 3000 ipointów
Przywi¹zany - (aktywowany po wbiciu 1000 godzin na jednej postaci) - 5000 ipointów
Mandacik! - (aktywowany po otrzymaniu mandatu od policjanta) - -300 ipointów
Pierwsza wyp³ata - (aktywowany po otrzymaniu pierwszego PD) - 200 ipointów
Wiêksze oszczêdnoœci - (aktywowany po uzbieraniu 10.000 dolarów na koncie bankowym) - 1.500 ipointów
Przedsiêbiorca - (aktywowany po uzbieraniu 50.000 dolarów na koncie bankowym) - 3000 ipointów
Pora postrzelaæ! - (aktywowany po zyskaniu pierwszej broni palnej) - 800 ipointów
Bogacz - (aktywowany po uzbieraniu 100.000 dolarów na koncie bankowym) - 5.000 ipointów
Nie ma lipy! - (aktywowany po wbiciu 3500j na si³owni) - 2000 ipointów
Ukarany - (aktywowany po otrzymaniu pierwszej kary od zarz¹du) - -500 ipointów
Krokami Rockefellera! - (aktywowany po uzbieraniu 500.000 dolarów na koncie) - 8000 ipointów
Milioner!! - (aktywowany po uzbieraniu 1.000.000 dolarów na koncie) - 15.000 ipointów

Sta³y bywalec:Pierwsze 10 godzin na serwerze. +100
Nowa praca, nowe wydatki.:Pierwsza wyp³ata. +120
Jesteœ rozchwytywany!:Zdoby³eœ dziesiêæ kontaktów na telefon. +150
Ale wpad³eœ!:Pierwsza noc w pudle +50
Zapach nowego samochodu: Kupi³eœ pierwszy samochód +200

Dusza towarzystwa: Zbierz 20 kontaktów w telefonie, 50ipoints.
Pierwszy pojazd: Dowolny pojazd na /v,  300ipoints
Oszczêdnoœci: ZgromadŸ 5 tysiêcy na koncie bankowym, 250ipoints
Wszêdzie dobrze ale w domu najlepiej: Posiadanie panelu domu, 400ipoints
Sta³y gracz: Przegraj 50 godzin postaci¹ na serwerze, 100ipoints
Bóg pla¿y: Zdob¹dŸ "muskularny", 1000ipoints
Motomaniak: Posiadaj piêæ pojazdów na /v, 2000ipoints
Król nieruchomoœci: Posiadaj piêæ paneli domów, 3500ipoints
Legalna praca: Zdob¹dŸ pierwsze zatrudnienie, 500ipoints
Biznesman: Posiadaj w³asny biznes, 1500ipoints
Przywódca: Posiadaj w³asn¹ organizacje, 1500ipoints
Lider: Posiadaj w³asn¹ frakcje, 2000ipoints
A.C.A.B: B¹dŸ aresztowany po raz pierwszy, 100ipoints
Karniak: B¹dŸ wys³any do AdminJail, -150ipoints
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
