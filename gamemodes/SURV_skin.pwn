/*enum eSkins {
	       skin_uid,
	       skin_model,
	       skin_sex,
	 Float:skin_price,
}

*/
FuncPub::LoadSkins()
{
	new skinid = 0,
		string[ 64 ];
	mysql_query("SELECT * FROM `sg_skins` WHERE `price` > 0");
	mysql_store_result();
	while(mysql_fetch_row(string))
	{
	    if(skinid == MAX_SKINS) break;
	    sscanf(string, "p<|>dddf",
	        Skin(skinid, skin_uid),
	        Skin(skinid, skin_model),
	        Skin(skinid, skin_sex),
			Skin(skinid, skin_price)
		);
		
	    skinid++;
	}
	mysql_free_result();
	printf("# Skiny zostały wczytane! | %d", skinid-1);
	return 1;
}

FuncPub::Skin_OnPlayerUpdate(playerid)
{
    if(GetPVarInt(playerid, "Ubranie"))
    {
		new Keys, ud, lr;
  		GetPlayerKeys(playerid, Keys, ud, lr);
        if(lr < 0 || lr > 0)
        {
            new action = lr < 0 ? 1 : -1,
				uid = GetPVarInt(playerid, "Ubranie_id"),
				str[ 20 ];
            do
            {
                uid = uid + action < 0 ? MAX_SKINS - 1: (uid + action >= MAX_SKINS ? 0: uid + action);
            } while(Player(playerid, player_sex) != Skin(uid, skin_sex));

            SetPVarInt(playerid, "Ubranie_id", uid);
            SetPlayerSkin(playerid, Skin(uid, skin_model));

		    if(Skin(uid, skin_price) <= Player(playerid, player_cash))
				format(str, sizeof str, "~g~$%.2f", Skin(uid, skin_price));
			else
				format(str, sizeof str, "~r~$%.2f", Skin(uid, skin_price));
            GameTextForPlayer(playerid, str, 2000, 6);
		}
        if(Keys & KEY_SECONDARY_ATTACK || Keys & KEY_JUMP)
        {
			// Enter
			new uid = GetPVarInt(playerid, "Ubranie_id");
            if(Player(playerid, player_cash) <= Skin(uid, skin_price))
                return ShowInfo(playerid, red"Nie stać Cię.");
            
            new string[ 126 ];
            SetPlayerSkin(playerid, Player(playerid, player_skin) = Skin(uid, skin_model));
			GivePlayerMoneyEx(playerid, 0 - Skin(uid, skin_price), true);

			SetCameraBehindPlayer(playerid);
   			TogglePlayerControllable(playerid, true);

 			DeletePVar(playerid, "Ubranie");
 			DeletePVar(playerid, "Ubranie_id");
 			
   			format(string, sizeof string, "Ubranie(%d)", Skin(uid, skin_model));
            Createitem(playerid, item_cloth, Skin(uid, skin_model), 0, 0.0, string, 200);

		    format(string, sizeof string,
				"UPDATE `surv_players` SET `skin` = '%d' WHERE `uid` = '%d'",
				Player(playerid, player_skin),
				Player(playerid, player_uid)
			);
			mysql_query(string);
			
			format(string, sizeof string, "Zakupiłeś ubranie model: %d, cena: $%.2f", Skin(uid, skin_model), Skin(uid, skin_price));
	    	ShowCMD(playerid, string);
        }
    }
	return 1;
}
