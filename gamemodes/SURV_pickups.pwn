FuncPub::LoadPickups()
{
	new pickupid = 1,
		string[ 64 ];
	mysql_query("SELECT * FROM `surv_pickups`");
	mysql_store_result();
	while(mysql_fetch_row(string))
	{
	    if(pickupid == MAX_PICKUPS) break;
	    
	    sscanf(string, "p<|>ddda<f>[3]d",
			Pickup(pickupid, pickup_uid),
			Pickup(pickupid, pickup_type),
			Pickup(pickupid, pickup_model),
			Pickup(pickupid, pickup_pos),
			Pickup(pickupid, pickup_vw)
		);
		Pickup(pickupid, pickup_sampID) = CreatePickup(Pickup(pickupid, pickup_model), 2, Pickup(pickupid, pickup_pos)[ 0 ], Pickup(pickupid, pickup_pos)[ 1 ], Pickup(pickupid, pickup_pos)[ 2 ], Pickup(pickupid, pickup_vw));
        pickupid++;
	}
	mysql_free_result();
	printf("# Pickupy zostały wczytane! | %d", pickupid-1);
	return 1;
}

FuncPub::DeletePickup(pickupid)
{
	new string[ 60 ];
	format(string, sizeof string,
	    "DELETE FROM `surv_pickups` WHERE `uid` = '%d'",
	    Pickup(pickupid, pickup_uid)
	);
	mysql_query(string);
	
	DestroyPickup(Pickup(pickupid, pickup_sampID));
	
    for(new ePickup:i; i < ePickup; i++)
    	Pickup(pickupid, i) = 0;
	return 1;
}

FuncPub::MakePickup(model, type, Float:pos_x, Float:pos_y, Float:pos_z, vw)
{
	new pickupid = 1;
	for(; pickupid != MAX_PICKUPS; pickupid++)
	    if(!Pickup(pickupid, pickup_uid))
			break;
			
	if(pickupid == MAX_PICKUPS) return 0;
	
	new string[ 126 ];
	format(string, sizeof string,
		"INSERT INTO `surv_pickups` VALUES (NULL, '%d', '%d', '%f', '%f', '%f', '%d')",
		type, model,
		pos_x, pos_y, pos_z,
		vw
	);
	mysql_query(string);
	
	Pickup(pickupid, pickup_uid) = mysql_insert_id();
	Pickup(pickupid, pickup_sampID) = CreatePickup(model, 2, pos_x, pos_y, pos_z, vw);
	Pickup(pickupid, pickup_type) = type;
	Pickup(pickupid, pickup_model) = model;
	Pickup(pickupid, pickup_pos)[ 0 ] = pos_x;
	Pickup(pickupid, pickup_pos)[ 1 ] = pos_y;
	Pickup(pickupid, pickup_pos)[ 2 ] = pos_z;
	Pickup(pickupid, pickup_vw) = vw;
	#if Debug
	    printf("[CREATE] Pickup (ID: %d, UID: %d, SAMPID: %d, Type: %d, Model: %d)", pickupid, Pickup(pickupid, pickup_uid), Pickup(pickupid, pickup_sampID), Pickup(pickupid, pickup_type), Pickup(pickupid, pickup_model));
	#endif
	return pickupid;
}

FuncPub::Pickup_OnPlayerPickUpPickup(playerid, pickupid)
{
	new pickupidx;
	for(; pickupidx != MAX_PICKUPS; pickupidx++)
	    if(Pickup(pickupidx, pickup_sampID) == pickupid)
	        break;
	        
	if(pickupidx == MAX_PICKUPS) return 1;
	if(!Pickup(pickupidx, pickup_uid)) return 1;
	
	new string[ 256 ];
	switch(Pickup(pickupidx, pickup_type))
	{
	    case job_road, job_road2: string = white"Sprzątanie ulic - w tej pracy możesz zasiąć za kółkiem Sweepera,\nktórym świadczysz usługę dla urzędu miasta, czyszcząc ulice.\n\nBaza San Andreas Sanitary znajduje się obok Pershing Square, przy kanałach miejskich.";
	    case job_mechanic: string = white"Mechanik - jest to praca, którą możesz świadczyć na każdej stacji benzynowej.\nDo Twoich obowiązków należy tankowanie pojazdów klientów stacji bezynowej.\n\nPrzydatne komendy, to: /o tankuj ilosc";
	    case job_hotdog: string = white"Sprzedawca hot dogów - praca, która polega na sprzedaży hot dogów z urządzeń przenośnych w najczęściej odwiedzanych częściach miasta.\n\nPrzydatne komendy to: /o hotdog id cena";
	    case job_smieciarz: string = white"Śmieciarz - w tej pracy możesz zasiąć za kółkiem śmierciari, którą świadczysz usługę dla urzędu miasta, wywożąc śmieci na wysypisko.\nBaza San Andreas Sanitary znajduje się obok Pershing Square, przy kanałach miejskich.";
	    case job_fisher: string = white"Rybak - Praca, która polega na łowieniu ryb.\nMiejsce, gdzie można łowić ryby to molo z kołem.\nKażdą złowioną rybę można sprzedać w każdym sklepie 24/7.\n\nPrzydatne komendy, to: /sprzedajrybe";
	    default: return 1;
	}
	SetPVarInt(playerid, "job-id", Pickup(pickupidx, pickup_type));
	Dialog::Output(playerid, 90, DIALOG_STYLE_MSGBOX, IN_HEAD, string, "Akceptuje", "Odrzuć");
	return 1;
}

FuncPub::Pickup_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case 90:
	    {
	        if(!response) return 1;
	        new job = GetPVarInt(playerid, "job-id");
				
	        Player(playerid, player_job) = job;
	        DeletePVar(playerid, "job-id");
	        GivePlayerAchiv(playerid, achiv_job);

			new string[ 126 ];
			format(string, sizeof string, "Gratulacje, zatrudniłeś się jako: "white"%s", JobName[ Player(playerid, player_job) ]);
	        ShowInfo(playerid, string);
	    }
	}
	return 1;
}
