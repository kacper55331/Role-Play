public Audio_OnClientConnect(playerid)
{
	#if Debug
	    printf("Audio_OnClientConnect(%d)", playerid);
	#endif

	Audio_TransferPack(playerid);
	if(!Player(playerid, player_logged))
	{
	    new url[ 64 ];

		mysql_query("SELECT `url` FROM `surv_cd` ORDER BY RAND() LIMIT 1");
		mysql_store_result();
		mysql_fetch_row(url);
		mysql_free_result();
		if(!Player(playerid, player_connect_sound))
			Player(playerid, player_connect_sound) = Audio_PlayStreamed(playerid, url);
	}
	return 1;
}

public Audio_OnTransferFile(playerid, file[], current, total, result)
{
	if(current == total)
	{
//	    LoadSounds(playerid);
	    GameTextForPlayer(playerid, "~g~Plugin audio zaladowany!", 3000, 3);
	}
	return 1;
}
