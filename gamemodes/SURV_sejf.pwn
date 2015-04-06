#define sejf_pin 		white"Podaj kod PIN, by móc otworzyæ sejf"
#define sejf_m_def  	"Wyp³aæ\nWp³aæ\nSprawdŸ stan konta"
#define sejf_u_def      "Zmieñ nazwê sejfu\nZmieñ PIN"
#define sejf_p_def      "Wyci¹gnij\nW³ó¿"
#define sejf_wplac      white"Podaj iloœæ gotówki, któr¹ chcesz wp³aciæ na konto."
#define sejf_wyplac		white"Podaj iloœæ gotówki, któr¹ chcesz wyp³aciæ z konta.\n\nStan konta: $%.2f"
#define sejf_wplata		white"W³o¿y³%sœ do sejfu "green"$%.2f\n\n"white"Obecna iloœæ gotówki: "green"$%.2f"
#define sejf_wyplata    white"Wyci¹gn¹³%sœ z sejfu "green"$%.2f\n\n"white"Obecna iloœæ gotówki: "green"$%.2f"
#define sejf_newpin     white"Podaj nowy PIN"
#define sejf_newname    white"Podaj now¹ nazwê dla sejfu"
#define sejf_wyc		green"Wyci¹gna³%sœ przedmiot %s z sejfu!"

FuncPub::ShowPlayerSejf(playerid)
{
	new doorid = GetPlayerDoor(playerid),
	    string[ 126 ],
	    buffer[ 2056 ];
	format(string, sizeof string,
	    "SELECT s.uid, s.name FROM `surv_sejf` s JOIN `surv_doors` d ON s.dooruid = d.uid WHERE d.uid = '%d'",
		Door(doorid, door_uid)
	);
	mysql_query(string);
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
	if(isnull(buffer)) ShowInfo(playerid, red"W tym pomieszczeniu nie ma sejfów/szafek.");
	else Dialog::Output(playerid, 107, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
	return 1;
}

FuncPub::Sejf_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case 107:
	    {
	        if(!response) return 1;
	        new sejfid = strval(inputtext);
	        if(!sejfid) return ShowPlayerSejf(playerid);
	        Bankomat(playerid, bank_number) = sejfid;
	        new doorid = GetPlayerDoor(playerid);
	        if(IsPlayerDoorOwner(playerid, doorid) != -1)
	        {
				new string[ 126 ];
				format(string, sizeof string,
				    "SELECT `name`, `cash` FROM `surv_sejf` WHERE `uid` = '%d'",
				    Bankomat(playerid, bank_number)
				);
				mysql_query(string);
				mysql_store_result();
				if(mysql_num_rows())
				{
				    mysql_fetch_row(string);

				    sscanf(string, "p<|>s[32]f",
						Bankomat(playerid, bank_name),
				    	Bankomat(playerid, bank_cash)
				    );
				}
				Sejf_Default(playerid);
	        }
	        else Dialog::Output(playerid, 108, DIALOG_STYLE_PASSWORD, IN_HEAD, sejf_pin, "Dalej", "Zamknij");
	    }
	    case 108:
	    {
	        if(!response) return 1;
	        
    	    if(isnull(inputtext) || strlen(inputtext) > 32)
				return Dialog::Output(playerid, 108, DIALOG_STYLE_PASSWORD, IN_HEAD, sejf_pin, "Dalej", "Zamknij");

			new string[ 126 ];
			mysql_real_escape_string(inputtext, inputtext);
			format(string, sizeof string,
			    "SELECT `name`, `cash` FROM `surv_sejf` WHERE `uid` = '%d' AND `pin` = '%s'",
			    Bankomat(playerid, bank_number),
			    inputtext
			);
			mysql_query(string);
			mysql_store_result();
			if(mysql_num_rows())
			{
			    mysql_fetch_row(string);
			    
			    sscanf(string, "p<|>s[32]f",
					Bankomat(playerid, bank_name),
			    	Bankomat(playerid, bank_cash)
			    );
			    
			    Sejf_Default(playerid);
			}
			else
			{
   	    		Dialog::Output(playerid, 108, DIALOG_STYLE_PASSWORD, IN_HEAD, sejf_pin, "Dalej", "Zamknij");
				GameTextForPlayer(playerid, "~n~~n~~n~~r~~h~Podales bledne haslo!", 5000, 5);
			}
			mysql_free_result();
	    }
	    case 109:
	    {
	        if(!response) return Bank_Clear(playerid);
	        switch(strval(inputtext))
	        {
	            case 1: Dialog::Output(playerid, 110, DIALOG_STYLE_LIST, IN_HEAD, sejf_m_def, "Wybierz", "Wróæ");
	            case 2: Dialog::Output(playerid, 117, DIALOG_STYLE_LIST, IN_HEAD, sejf_p_def, "Wybierz", "Wróæ");
	            case 3: Dialog::Output(playerid, 114, DIALOG_STYLE_LIST, IN_HEAD, sejf_u_def, "Wybierz", "Wróæ");
	        }
	    }
	    case 110:
	    {
	        if(!response) return Sejf_Default(playerid);
		    if(DIN(inputtext, "Wyp³aæ"))
		    {
		        new string[ 120 ];
		        format(string, sizeof string,
					sejf_wyplac,
					Bankomat(playerid, bank_cash)
				);
		        Dialog::Output(playerid, 112, DIALOG_STYLE_INPUT, IN_HEAD, string, "Wyp³aæ", "Wróæ");
		    }
		    else if(DIN(inputtext, "Wp³aæ"))
		    {
		        Dialog::Output(playerid, 113, DIALOG_STYLE_INPUT, IN_HEAD, sejf_wplac, "Wp³aæ", "Wróæ");
		    }
		    else if(DIN(inputtext, "SprawdŸ stan konta"))
		    {
		        new string[ 60 ];
		        format(string, sizeof string, white"Stan konta: "green"$%.2f", Bankomat(playerid, bank_cash));
		        Dialog::Output(playerid, 111, DIALOG_STYLE_MSGBOX, IN_HEAD, string, "OK", "");
		    }
	    }
	    case 111: Dialog::Output(playerid, 110, DIALOG_STYLE_LIST, IN_HEAD, sejf_m_def, "Wybierz", "Wróæ");
	    case 112:
	    {
		    if(!response) return Dialog::Output(playerid, 110, DIALOG_STYLE_LIST, IN_HEAD, sejf_m_def, "Wybierz", "Wróæ");
		    if(!Bankomat(playerid, bank_cash))
		        return Dialog::Output(playerid, 111, DIALOG_STYLE_LIST, IN_HEAD, red"W sejfie nie ma gotówki!", "Wybierz", "Wróæ");

			new Float:cash = floatstr(inputtext);
			if(cash <= 0)
				return Dialog::Output(playerid, 110, DIALOG_STYLE_LIST, IN_HEAD, sejf_m_def, "Wybierz", "Wróæ");
			if(Bankomat(playerid, bank_cash) < cash)
			{
			    new string[ 120 ];
		        format(string, sizeof string,
					sejf_wyplac,
					Bankomat(playerid, bank_cash)
				);
		        Dialog::Output(playerid, 112, DIALOG_STYLE_INPUT, IN_HEAD, string, "Wyp³aæ", "Wróæ");
				GameTextForPlayer(playerid, "~n~~n~~n~~r~~h~Nie masz tyle gotowki na koncie.", 5000, 5);
				return 1;
			}
		    GivePlayerMoneyEx(playerid, cash, true);
			Bankomat(playerid, bank_cash) -= cash;

		    new string[ 150 ];
		    format(string, sizeof string, "UPDATE `surv_sejf` SET `cash` = `cash` - '%.2f' WHERE `uid` = '%d'", cash, Bankomat(playerid, bank_number));
		    mysql_query(string);

			format(string, sizeof string, sejf_wyplata, (Player(playerid, player_sex) == sex_woman) ? ("a") : ("e"), cash, Bankomat(playerid, bank_cash));
			Dialog::Output(playerid, 111, DIALOG_STYLE_MSGBOX, IN_HEAD, string, "Wróæ", "");
	    }
	    case 113:
	    {
		    if(!response) return Dialog::Output(playerid, 110, DIALOG_STYLE_LIST, IN_HEAD, sejf_m_def, "Wybierz", "Wróæ");

			new Float:cash = floatstr(inputtext);
			if(cash <= 0)
				return Dialog::Output(playerid, 110, DIALOG_STYLE_LIST, IN_HEAD, sejf_m_def, "Wybierz", "Wróæ");

			if(Player(playerid, player_cash) < cash)
			{
		        Dialog::Output(playerid, 113, DIALOG_STYLE_INPUT, IN_HEAD, sejf_wplac, "Wp³aæ", "Wróæ");
				GameTextForPlayer(playerid, "~n~~n~~n~~r~~h~Nie masz tyle gotowki.", 5000, 5);
				return 1;
			}

		    GivePlayerMoneyEx(playerid, 0 - cash, true);
		    Bankomat(playerid, bank_cash) += cash;

		    new string[ 120 ];
		    format(string, sizeof string, "UPDATE `surv_sejf` SET `cash` = `cash` + '%.2f' WHERE `uid` = '%d'", cash, Bankomat(playerid, bank_number));
		    mysql_query(string);

			format(string, sizeof string, sejf_wplata, (Player(playerid, player_sex) == sex_woman) ? ("a") : ("e"), cash, Bankomat(playerid, bank_cash));
			Dialog::Output(playerid, 111, DIALOG_STYLE_MSGBOX, IN_HEAD, string, "Wróæ", "");
	    }
	    case 114:
	    {
	        if(!response) return Sejf_Default(playerid);
	        switch(listitem)
	        {
	            case 0: Dialog::Output(playerid, 116, DIALOG_STYLE_INPUT, IN_HEAD, sejf_newname, "Dalej", "Wróæ");
	            case 1:	Dialog::Output(playerid, 115, DIALOG_STYLE_PASSWORD, IN_HEAD, sejf_newpin, "Dalej", "Wróæ");
	        }
	    }
	    case 115:
	    {
	        if(!response) return Dialog::Output(playerid, 114, DIALOG_STYLE_LIST, IN_HEAD, sejf_u_def, "Wybierz", "Wróæ");
			if(!strval(inputtext)) return Dialog::Output(playerid, 115, DIALOG_STYLE_PASSWORD, IN_HEAD, sejf_newpin, "Dalej", "Wróæ");
			
			new string[ 126 ];
			mysql_real_escape_string(inputtext, inputtext);

			format(string, sizeof string, "UPDATE `surv_sejf` SET `pin`='%s' WHERE `uid`=%d", inputtext, Bankomat(playerid, bank_number));
            mysql_query(string);

            format(string, sizeof string, white"Kod PIN zosta³ zmieniony pomyœlnie.\n"red"Nowy pin:\t\t\t%s", inputtext);
			Dialog::Output(playerid, 120, DIALOG_STYLE_MSGBOX, IN_HEAD, string, "OK", "");
	    }
	    case 116:
	    {
	        if(!response) return Dialog::Output(playerid, 114, DIALOG_STYLE_LIST, IN_HEAD, sejf_u_def, "Wybierz", "Wróæ");

			if(isnull(inputtext) || strlen(inputtext) > 32)
				return Dialog::Output(playerid, 116, DIALOG_STYLE_INPUT, IN_HEAD, sejf_newname, "Dalej", "Wróæ");

			new string[ 128 ];
			mysql_real_escape_string(inputtext, inputtext);

			format(string, sizeof string, "UPDATE `surv_sejf` SET `name`='%s' WHERE `uid`=%d", inputtext, Bankomat(playerid, bank_number));
            mysql_query(string);

			format(Bankomat(playerid, bank_name), 32, inputtext);

            format(string, sizeof string, white"Nazwa sejfu zosta³a zmieniona pomyœlnie!\nNowa nazwa:\t\t%s", inputtext);
			Dialog::Output(playerid, 120, DIALOG_STYLE_MSGBOX, IN_HEAD, string, "OK", "");
	    }
	    case 117:
	    {
	        if(!response) return Sejf_Default(playerid);
			new string[ 126 ];
		    if(DIN(inputtext, "Wyci¹gnij"))
		    {
		        new buffer[ 512 ];
		        format(string, sizeof string,
					"SELECT `uid`, `name` FROM `surv_items` WHERE `ownerType` = '"#item_place_sejf"' AND `owner` = '%d'",
					Bankomat(playerid, bank_number)
				);
				mysql_query(string);
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
				if(isnull(buffer)) Dialog::Output(playerid, 119, DIALOG_STYLE_MSGBOX, IN_HEAD, red"Sejf jest pusty!", "OK", "");
				else Dialog::Output(playerid, 118, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Wróæ");
		    }
		    else if(DIN(inputtext, "W³ó¿"))
		    {
		        if(!Player(playerid, player_item_selected))
		            return Dialog::Output(playerid, 119, DIALOG_STYLE_MSGBOX, IN_HEAD, red"Nie masz ¿adnego zaznaczonego przedmiotu! Wpisz /p, a potem \"wybierz [slot]\"", "OK", "");

			    format(string, sizeof string,
					"UPDATE `surv_items` SET `ownerType`='"#item_place_sejf"', `owner` = '%d' WHERE `ownerType` = '"#item_place_player"' AND `owner` = '%d' AND `used` = '2'",
					Bankomat(playerid, bank_number),
					Player(playerid, player_uid)
				);
				mysql_query(string);

				Dialog::Output(playerid, 111, DIALOG_STYLE_MSGBOX, IN_HEAD, green"Wybrane przedmioty zosta³y w³o¿one do sejfu!", "OK", "");

				if(IsPlayerVisibleItems(playerid))
				    ShowPlayerItems(playerid, Player(playerid, player_item_site));
		    }
	    }
	    case 118:
	    {
	        if(!response) return Sejf_Default(playerid);
	        new itemid = strval(inputtext),
				string[ 126 ];
				
		    format(string, sizeof string,
				"UPDATE `surv_items` SET `ownerType`='"#item_place_player"', `owner` = '%d' WHERE `uid` = '%d'",
				Player(playerid, player_uid),
				itemid
			);
			mysql_query(string);
			
			new itemname[ MAX_ITEM_NAME ];
			format(string, sizeof string,
				"SELECT `name` FROM `surv_items` WHERE `uid` = '%d'",
				itemid
			);
			mysql_query(string);
			mysql_store_result();
			mysql_fetch_row(itemname);
			mysql_free_result();
			
			format(string, sizeof string,
				sejf_wyc,
				(Player(playerid, player_sex) == sex_woman) ? ("a") : ("e"),
				item_name
			);
			
			Dialog::Output(playerid, 119, DIALOG_STYLE_MSGBOX, IN_HEAD, string, "OK", "");
	    }
	    case 119: Dialog::Output(playerid, 117, DIALOG_STYLE_LIST, IN_HEAD, sejf_p_def, "Wybierz", "Wróæ");
	    case 120: Dialog::Output(playerid, 114, DIALOG_STYLE_LIST, IN_HEAD, sejf_u_def, "Wybierz", "Wróæ");
	}
	return 1;
}

FuncPub::Sejf_Default(playerid)
{
	new string[ 40 ];
	format(string, sizeof string,
		"Nazwa: %s",
		Bankomat(playerid, bank_name)
	);
    Dialog::Output(playerid, 109, DIALOG_STYLE_LIST, string, "1. Gotówka\n2. Przedmioty\n3. Ustawienia", "Dalej", "Zamknij");
	return 1;
}

Cmd::Input->szafka(playerid, params[]) return ShowPlayerSejf(playerid);
