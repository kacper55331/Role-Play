FuncPub::LoadAnims()
{
	new animid = 1,
		string[ 256 ];
	mysql_query("SELECT * FROM `surv_anims`");
	mysql_store_result();
	while(mysql_fetch_row(string))
	{
		if(animid == MAX_ANIMS) break;
		
	    sscanf(string, "p<|>is[45]s[45]s[45]fa<d>[5]",
	       	Anim(animid, anim_uid),
	       	Anim(animid, anim_name),
	       	Anim(animid, anim_animlib),
	       	Anim(animid, anim_animname),
			Anim(animid, anim_speed),
	       	Anim(animid, anim_opt)
		);
		animid++;
	}
	mysql_free_result();
	printf("# Animacje zosta³y wczytane. | %d", animid-1);
	return 1;
}

FuncPub::ShowPlayerAnimations(playerid)
{
	new buffer[ 1024 ];
	for(new animid; animid < MAX_ANIMS; animid++)
	    if(!isnull(Anim(animid, anim_name)))
	        format(buffer, sizeof buffer, "%s%s\n", buffer, Anim(animid, anim_name));
	        
	Dialog::Output(playerid, 51, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Wybierz", "Zamknij");
	return 1;
}

FuncPub::SetAnimationByName(playerid, animname[])
{
	if(isnull(animname)) return 1;
	
	if(!strcmp("stopani", animname, true))
	    return StopAnim(playerid);
	
	for(new animid; animid < MAX_ANIMS; animid++)
	{
	    if(strcmp(Anim(animid, anim_name), animname, true) == 0 && !isnull(Anim(animid, anim_name)))
	    {
	        SetAnimation(playerid, animid);
	        break;
	    }
    }
    return 1;
}

FuncPub::SetAnimationByUID(playerid, animuid)
{
	if(!animuid) return 1;
	for(new animid; animid < MAX_ANIMS; animid++)
	{
	    if(Anim(animid, anim_uid) == animuid)
	    {
	        SetAnimation(playerid, animid);
	        break;
	    }
	}
	return 1;
}

FuncPub::SetAnimation(playerid, animid)
{
	if(!animid) return 1;
   	ApplyAnimation(playerid, Anim(animid, anim_animlib), Anim(animid, anim_animname), Anim(animid, anim_speed), Anim(animid, anim_opt)[ 0 ], Anim(animid, anim_opt)[ 1 ], Anim(animid, anim_opt)[ 2 ], Anim(animid, anim_opt)[ 3 ], Anim(animid, anim_opt)[ 4 ]);
 	if(Anim(animid, anim_opt)[ 0 ] || Anim(animid, anim_opt)[ 4 ])
	 	Player(playerid, player_anim) = true;
	return 1;
}

FuncPub::SetAnimationByGame(playerid, animuid, len)
{
	if(!animuid) return 1;
	for(new animid; animid != sizeof Mowa; animid++)
	{
	    if(Mowa[ animid ][ anim_uid ] == animuid)
	    {
	        ApplyAnimation(playerid, Mowa[animid][anim_animlib], Mowa[animid][anim_animname], Mowa[animid][anim_speed], Mowa[animid][anim_opt][ 0 ], Mowa[animid][anim_opt][ 1 ], Mowa[animid][anim_opt][ 2 ], Mowa[animid][anim_opt][ 3 ], Mowa[animid][anim_opt][ 4 ]);
	        //len * 1000
	        SetTimerEx("StopAnim", len * 500, false, "d", playerid);
			break;
	    }
	}
	return 1;
}

FuncPub::StopAnim(playerid)
{
    ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);
    ClearAnimations(playerid, true);
    Player(playerid, player_anim) = false;
	return 1;
}

FuncPub::Anims_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case 51:
	    {
	        if(!response) return 1;
	        SetAnimationByName(playerid, inputtext);
	    }
	}
	return 1;
}

FuncPub::Anims_OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if((PRESSED(KEY_SPRINT) || PRESSED(KEY_SECONDARY_ATTACK)) && Player(playerid, player_anim))
	{
	    StopAnim(playerid);
	}
	return 1;
}

stock PreloadAnimLibraries(playerid)
{
    static AnimLibraries[][] =
    {
		"AIRPORT","Attractors","BAR","BASEBALL","BD_FIRE","BEACH","benchpress","BF_injection","BIKED","BIKEH",
		"BIKELEAP","BIKES","BIKEV","BIKE_DBZ","BLOWJOBZ","BMX","BOMBER","BOX","BSKTBALL","BUDDY","BUS","CAMERA",
		"CAR","CARRY","CAR_CHAT","CASINO","CHAINSAW","CHOPPA","CLOTHES","COACH","COLT45","COP_AMBIENT","COP_DVBYZ",
		"CRACK","CRIB","DAM_JUMP","DANCING","DEALER","DILDO","DODGE","DOZER","DRIVEBYS","FAT","FIGHT_B","FIGHT_C",
		"FIGHT_D","FIGHT_E","FINALE","FINALE2","FLAME","Flowers","FOOD","Freeweights","GANGS","GHANDS","GHETTO_DB",
		"goggles","GRAFFITI","GRAVEYARD","GRENADE","GYMNASIUM","HAIRCUTS","HEIST9","INT_HOUSE","INT_OFFICE",
		"INT_SHOP","JST_BUISNESS","KART","KISSING","KNIFE","LAPDAN1","LAPDAN2","LAPDAN3","LOWRIDER","MD_CHASE",
		"MD_END","MEDIC","MISC","MTB","MUSCULAR","NEVADA","ON_LOOKERS","OTB","PARACHUTE","PARK","PAULNMAC","ped",
		"PLAYER_DVBYS","PLAYIDLES","POLICE","POOL","POOR","PYTHON","QUAD","QUAD_DBZ","RAPPING","RIFLE","RIOT",
		"ROB_BANK","ROCKET","RUSTLER","RYDER","SCRATCHING","SHAMAL","SHOP","SHOTGUN","SILENCED","SKATE","SMOKING",
		"SNIPER","SPRAYCAN","STRIP","SUNBATHE","SWAT","SWEET","SWIM","SWORD","TANK","TATTOOS","TEC","TRAIN","TRUCK",
		"UZI","VAN","VENDING","VORTEX","WAYFARER","WEAPONS","WUZI"
    };

    for(new l; l < sizeof AnimLibraries; l++)
    	ApplyAnimation(playerid, AnimLibraries[ l ], "null", 0.0, 0, 0, 0, 0, 0);
    return 1;
}

Cmd::Input->anims(playerid, params[])
{
	if(isnull(params))
    	ShowPlayerAnimations(playerid);
	else
	    SetAnimationByName(playerid, params);
	return 1;
}
Cmd::Input->anim(playerid, params[]) return cmd_anims(playerid, params);
Cmd::Input->animacje(playerid, params[]) return cmd_anims(playerid, params);
