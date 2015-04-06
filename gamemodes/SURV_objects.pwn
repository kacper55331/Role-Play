#if STREAMER
	FuncPub::LoadObjects()
	{
	    Streamer_MaxItems(STREAMER_TYPE_OBJECT, 50000);
	    
	    DestroyAllDynamicObjects();
	    
    	for(new c; c!= MAX_OBJECTS; c++)
	    {
	        for(new eObjects:i; i < eObjects; i++)
				Object(c, i) = 0;
	        Object(c, obj_objID) = INVALID_OBJECT_ID;
	    }
	    
		new objectid, string[ 380 ], count;
		mysql_query("SELECT o.*, IFNULL(d.in_pos_vw, 0) as 'vw' FROM `surv_objects` o LEFT JOIN `surv_doors` d ON o.door = d.uid WHERE o.accept = 1");
		mysql_store_result();
		while(mysql_fetch_row(string))
		{
		    new uid, model, Float:position[ 3 ], Float:positionrot[ 3 ],
				index_mat, index_text,
				color_text, color_mat, bgcolor,
				size, tsize, align, bold, text[ 64 ],
				modelid, txdname[ 32 ],
				texturename[ 32 ], font[ 32 ], vw;
				
			new Float:positiongate[ 3 ],
				Float:positiongaterot[ 3 ],
				bool:gatestatus,
				Float:gaterange,
				owner[ 2 ];

		    sscanf(string, "p<|>d{d}da<f>[3]a<f>[3]a<f>[3]a<f>[3]dfa<d>[2]ddxxxdddds[64]ds[32]s[32]s[32]{dd}d",
		        uid,
		        model,
				position,
				positionrot,
				positiongate, positiongaterot,
				gatestatus, gaterange, owner,
				index_text,
				index_mat,
				color_text,
				color_mat,
				bgcolor,
				size,
				tsize,
				align,
				bold,
				text,
				modelid,
				txdname,
				texturename,
				font,
				vw
			);

			if(gatestatus)
				objectid = CreateDynamicObject(model, positiongate[ 0 ], positiongate[ 1 ], positiongate[ 2 ], positiongaterot[ 0 ], positiongaterot[ 1 ], positiongaterot[ 2 ], vw, -1, -1, 1000.0);
			else
				objectid = CreateDynamicObject(model, position[ 0 ], position[ 1 ], position[ 2 ], positionrot[ 0 ], positionrot[ 1 ], positionrot[ 2 ], vw, -1, -1, 1000.0);
			Streamer_SetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_EXTRA_ID, uid);

			if(!(DIN(txdname, "NULL")) || !(DIN(texturename, "NULL")))
			    SetDynamicObjectMaterial(objectid, index_mat, modelid, txdname, texturename, color_mat);
			if(!(DIN(text, "NULL")))
			    SetDynamicObjectMaterialText(objectid, index_text, text, size, font, tsize, bold, color_text, bgcolor, align);

			if(owner[ 0 ] || owner[ 1 ] || positiongate[ 0 ] || positiongate[ 1 ] || positiongate[ 2 ])
			{
			    if(count == MAX_OBJECTS) continue;
	            Object(count, obj_objID) = objectid;
				Object(count, obj_position)[ 0 ] = position[ 0 ];
				Object(count, obj_position)[ 1 ] = position[ 1 ];
				Object(count, obj_position)[ 2 ] = position[ 2 ];
				Object(count, obj_positionrot)[ 0 ] = positionrot[ 0 ];
				Object(count, obj_positionrot)[ 1 ] = positionrot[ 1 ];
				Object(count, obj_positionrot)[ 2 ] = positionrot[ 2 ];
				Object(count, obj_positiongate)[ 0 ] = positiongate[ 0 ];
				Object(count, obj_positiongate)[ 1 ] = positiongate[ 1 ];
				Object(count, obj_positiongate)[ 2 ] = positiongate[ 2 ];
				Object(count, obj_positiongaterot)[ 0 ] = positiongaterot[ 0 ];
				Object(count, obj_positiongaterot)[ 1 ] = positiongaterot[ 1 ];
				Object(count, obj_positiongaterot)[ 2 ] = positiongaterot[ 2 ];
				Object(count, obj_gatestatus) = gatestatus;
				Object(count, obj_gaterange) = gaterange;
				Object(count, obj_owner)[ 0 ] = owner[ 0 ];
				Object(count, obj_owner)[ 1 ] = owner[ 1 ];
				count++;
			}
		}
		printf("# Obiekty zostały wczytane! | %d | %d", objectid-1, count-1);
		mysql_free_result();
		return 1;
	}
#else
	FuncPub::LoadPlayerObjects(playerid, virtualworld)
	{
		for(new t = 1; t != MAX_OBJECTS; t++)
		{
		    if(Object(playerid, t, obj_objID) == INVALID_OBJECT_ID)
		        continue;
			if(IsValidPlayerObject(playerid, Object(playerid, t, obj_objID)))
				DestroyPlayerObject(playerid, Object(playerid, t, obj_objID));

			for(new eObjects:i; i < eObjects; i++)
				Object(playerid, t, i)		= 0;
			Object(playerid, t, obj_objID) = INVALID_OBJECT_ID;
		}
		Player(playerid, player_obj_dist) = 0.0;
		Player(playerid, player_obj_pos)[ 0 ] = 0.0;
		Player(playerid, player_obj_pos)[ 1 ] = 0.0;
		Player(playerid, player_obj_pos)[ 2 ] = 0.0;

	    new string[ 380 ],
			Float:distiny;
		if(!virtualworld)
		    format(string, sizeof string,
				"SELECT o.*, SQRT(((o.X - %f)  * (o.X - %f)) + ((o.Y - %f) * (o.Y - %f))) AS dist FROM `surv_objects` o WHERE o.door = '%d' AND o.accept = 1 ORDER BY dist",
				Player(playerid, player_position)[ 0 ],
				Player(playerid, player_position)[ 0 ],
				Player(playerid, player_position)[ 1 ],
				Player(playerid, player_position)[ 1 ],
				virtualworld
			);
		else
		    format(string, sizeof string,
				"SELECT o.*, SQRT(((o.X - %f)  * (o.X - %f)) + ((o.Y - %f) * (o.Y - %f))) AS dist FROM `surv_objects` o JOIN `surv_doors` d ON o.door = d.uid WHERE d.in_pos_vw = '%d' AND o.accept = 1 ORDER BY dist",
				Player(playerid, player_position)[ 0 ],
				Player(playerid, player_position)[ 0 ],
				Player(playerid, player_position)[ 1 ],
				Player(playerid, player_position)[ 1 ],
				virtualworld
			);
		mysql_query(string);
	 	mysql_store_result();
		while(mysql_fetch_row(string))
		{
			new objectid = 1;
		    for(; objectid != floatval(MAX_OBJECTS*0.75); objectid++)
			    if(!IsValidPlayerObject(playerid, Object(playerid, objectid, obj_objID)) && !IsValidObject(objectid))
			        break;
		    if(objectid == floatval(MAX_OBJECTS*0.75))
			{
			    Player(playerid, player_obj_dist) = distiny;
				Player(playerid, player_obj_pos)[ 0 ] = Player(playerid, player_position)[ 0 ];
				Player(playerid, player_obj_pos)[ 1 ] = Player(playerid, player_position)[ 1 ];
				Player(playerid, player_obj_pos)[ 2 ] = Player(playerid, player_position)[ 2 ];
				break;
			}
		    static Float:dist;

		    new index_mat, index_text,
				color_text, color_mat, bgcolor,
				size, tsize, align, bold, text[ 64 ],
				modelid, txdname[ 32 ],
				texturename[ 32 ], font[ 32 ];

		    sscanf(string, "p<|>ddda<f>[3]a<f>[3]a<f>[3]a<f>[3]dfa<d>[2]ddxxxdddds[64]ds[32]s[32]s[32]{dd}f",
		        Object(playerid, objectid, obj_uid),
		        Object(playerid, objectid, obj_mapid),
		        Object(playerid, objectid, obj_model),
				Object(playerid, objectid, obj_position),
				Object(playerid, objectid, obj_positionrot),
				Object(playerid, objectid, obj_positiongate),
				Object(playerid, objectid, obj_positiongaterot),
				Object(playerid, objectid, obj_gatestatus),
				Object(playerid, objectid, obj_gaterange),
				Object(playerid, objectid, obj_owner),
				index_text,
				index_mat,
				color_text,
				color_mat,
				bgcolor,
				size,
				tsize,
				align,
				bold,
				text,
				modelid,
				txdname,
				texturename,
				font,
				dist
			);

			if(floatval(MAX_OBJECTS*0.6) == objectid)
			{
			    distiny = dist;
			}

			if(Object(playerid, objectid, obj_gatestatus))
				Object(playerid, objectid, obj_objID) = CreatePlayerObject(playerid, Object(playerid, objectid, obj_model), Object(playerid, objectid, obj_positiongate)[ 0 ], Object(playerid, objectid, obj_positiongate)[ 1 ], Object(playerid, objectid, obj_positiongate)[ 2 ], Object(playerid, objectid, obj_positiongaterot)[ 0 ], Object(playerid, objectid, obj_positiongaterot)[ 1 ], Object(playerid, objectid, obj_positiongaterot)[ 2 ], 150.0);
			else
				Object(playerid, objectid, obj_objID) = CreatePlayerObject(playerid, Object(playerid, objectid, obj_model), Object(playerid, objectid, obj_position)[ 0 ], Object(playerid, objectid, obj_position)[ 1 ], Object(playerid, objectid, obj_position)[ 2 ], Object(playerid, objectid, obj_positionrot)[ 0 ], Object(playerid, objectid, obj_positionrot)[ 1 ], Object(playerid, objectid, obj_positionrot)[ 2 ], 150.0);

			if(!(DIN(txdname, "NULL")) || !(DIN(texturename, "NULL")))
			{
			    SetPlayerObjectMaterial(playerid, Object(playerid, objectid, obj_objID), index_mat, modelid, txdname, texturename, color_mat);
			}
			if(!(DIN(text, "NULL")))
			{
			    SetPlayerObjectMaterialText(playerid, Object(playerid, objectid, obj_objID), text, index_text, size, font, tsize, 0, color_text, bgcolor, align);
			}
			objectid++;
		}
		mysql_free_result();

	    format(string, sizeof string,
			"SELECT `uid`, `type`, `x`, `y`, `z`, `v1`, `v2`, SQRT(((x - %f)  * (x - %f)) + ((y - %f) * (y - %f))) AS dist FROM `surv_items` WHERE `vw` = '%d' AND `ownerType` = "#item_place_none" ORDER BY dist",
			Player(playerid, player_position)[ 0 ],
			Player(playerid, player_position)[ 0 ],
			Player(playerid, player_position)[ 1 ],
			Player(playerid, player_position)[ 1 ],
			virtualworld
		);
		mysql_query(string);
	 	mysql_store_result();
	 	while(mysql_fetch_row(string))
		{
		    new objectid = 1;
		    for(; objectid != floatval(MAX_OBJECTS*0.75); objectid++)
			    if(!IsValidPlayerObject(playerid, Object(playerid, objectid, obj_objID)) && !IsValidObject(objectid))
			        break;
		    if(objectid == floatval(MAX_OBJECTS*0.75)) break;

		    static typ,
				value[ 2 ];

			sscanf(string, "p<|>dda<f>[3]a<d>[2]",
				Object(playerid, objectid, obj_owner)[ 1 ],
				typ,
				Object(playerid, objectid, obj_position),
				value
			);
		    Object(playerid, objectid, obj_owner)[ 0 ] = object_owner_item;
	        Object(playerid, objectid, obj_objID) = ObjectItem(playerid, typ, value[ 0 ], value[ 1 ], Object(playerid, objectid, obj_position)[ 0 ], Object(playerid, objectid, obj_position)[ 1 ], Object(playerid, objectid, obj_position)[ 2 ]);

			objectid++;
		}
		mysql_free_result();
		return 1;
	}
#endif

FuncPub::RemovePlayerBuilds(playerid)
{
	new string[ 64 ];
	mysql_query("SELECT * FROM `surv_removeobjects`");
 	mysql_store_result();
  	while(mysql_fetch_row(string))
	{
		static model,
			Float:pos[ 3 ],
			Float:range;

	    sscanf(string, "p<|>{d}da<f>[3]f",
			model,
			pos,
			range
		);

	    RemoveBuildingForPlayer(playerid, model, pos[ 0 ], pos[ 1 ], pos[ 2 ], range);
	}
	mysql_free_result();
	return 1;
}

Cmd::Input->brama(playerid, params[])
{
	#if STREAMER
		new objectidd = INVALID_OBJECT_ID,
			t = false;

		for(new count; count < MAX_OBJECTS; count++)
		{
		    if(Object(count, obj_objID) == INVALID_OBJECT_ID) continue;
		    if(!IsValidDynamicObject(Object(count, obj_objID))) continue;
		    if(!Streamer_IsInArrayData(STREAMER_TYPE_OBJECT, Object(count, obj_objID), E_STREAMER_WORLD_ID, Player(playerid, player_vw))) continue;

			if(Object(count, obj_positiongate)[ 0 ] == 0.0 && Object(count, obj_positiongate)[ 1 ] == 0.0 && Object(count, obj_positiongate)[ 2 ] == 0.0)
				continue;

			if(Object(count, obj_gatestatus))
			{
				if(!IsPlayerInRangeOfPoint(playerid, Object(count, obj_gaterange), Object(count, obj_positiongate)[ 0 ], Object(count, obj_positiongate)[ 1 ], Object(count, obj_positiongate)[ 2 ]))
					continue;
			}
			else
			{
				if(!IsPlayerInRangeOfPoint(playerid, Object(count, obj_gaterange), Object(count, obj_position)[ 0 ], Object(count, obj_position)[ 1 ], Object(count, obj_position)[ 2 ]))
					continue;
			}

			if(!(Player(playerid, player_adminlvl) && Player(playerid, player_aduty)))
			{
				if(Object(count, obj_owner)[ 0 ] == object_owner_group)
				{
					new groupid = IsPlayerInUidGroup(playerid, Object(count, obj_owner)[ 1 ]);
					if(!(groupid && Group(playerid, groupid, group_can) & member_can_door))
				    {
						t = true;
					    continue;
					}
				}
				else if(Object(count, obj_owner)[ 0 ] == object_owner_player)
				{
				    if(Object(count, obj_owner)[ 1 ] != Player(playerid, player_uid))
				    {
						t = true;
					    continue;
					}
				}
				else if(Object(count, obj_owner)[ 0 ] == object_owner_doors && Player(playerid, player_door))
				{
				    if(Object(count, obj_owner)[ 1 ] != Door(Player(playerid, player_door), door_uid))
				    {
						t = true;
					    continue;
					}
				}
				else
				{
					t = true;
				    continue;
				}
			}
			new string[ 100 ];
			format(string, sizeof string,
				"UPDATE `surv_objects` SET `gatestatus` = '%d' WHERE `uid` = '%d'",
			    _:Object(count, obj_gatestatus) ? (false) : (true),
			    Streamer_GetIntData(STREAMER_TYPE_OBJECT, Object(count, obj_objID), E_STREAMER_EXTRA_ID)
			);
			mysql_query(string);

			if(!Object(count, obj_gatestatus))
			    MoveDynamicObject(Object(count, obj_objID), Object(count, obj_positiongate)[ 0 ], Object(count, obj_positiongate)[ 1 ], Object(count, obj_positiongate)[ 2 ], 2.0, Object(count, obj_positiongaterot)[ 0 ], Object(count, obj_positiongaterot)[ 1 ], Object(count, obj_positiongaterot)[ 2 ]);
			else
			    MoveDynamicObject(Object(count, obj_objID), Object(count, obj_position)[ 0 ], Object(count, obj_position)[ 1 ], Object(count, obj_position)[ 2 ], 2.0, Object(count, obj_positionrot)[ 0 ], Object(count, obj_positionrot)[ 1 ], Object(count, obj_positionrot)[ 2 ]);
			if(objectidd == INVALID_OBJECT_ID)
			{
				if(!Object(count, obj_gatestatus))
				    GameTextForPlayer(playerid, "~g~~h~Brama otwarta", 3000, 3);
				else
				    GameTextForPlayer(playerid, "~r~~h~Brama zamknieta", 3000, 3);
			}
			Object(count, obj_gatestatus) = !Object(count, obj_gatestatus);
			objectidd = count;
		}
		if(objectidd == INVALID_OBJECT_ID)
		{
			if(t) GameTextForPlayer(playerid, "~r~Brak uprawnien", 3000, 3);
			else ShowCMD(playerid, "Nie jesteś przy żadnej bramie.");
		}
	#else
	
		new objectid = 1, bool:t;
		for(; objectid != MAX_OBJECTS; objectid++)
		{
		    if(Object(playerid, objectid, obj_objID) == INVALID_OBJECT_ID)
		        continue;
		    if(!IsValidPlayerObject(playerid, Object(playerid, objectid, obj_objID)))
		        continue;
		    if(!Object(playerid, objectid, obj_uid))
				continue;
		    if(Object(playerid, objectid, obj_positiongate)[ 0 ] == 0.0 && Object(playerid, objectid, obj_positiongate)[ 1 ] == 0.0 && Object(playerid, objectid, obj_positiongate)[ 2 ] == 0.0)
				continue;
			if(Object(playerid, objectid, obj_gatestatus))
			{
				if(!IsPlayerInRangeOfPoint(playerid, Object(playerid, objectid, obj_gaterange), Object(playerid, objectid, obj_positiongate)[ 0 ], Object(playerid, objectid, obj_positiongate)[ 1 ], Object(playerid, objectid, obj_positiongate)[ 2 ]))
					continue;
			}
			else
			{
				if(!IsPlayerInRangeOfPoint(playerid, Object(playerid, objectid, obj_gaterange), Object(playerid, objectid, obj_position)[ 0 ], Object(playerid, objectid, obj_position)[ 1 ], Object(playerid, objectid, obj_position)[ 2 ]))
					continue;
			}
			if(Player(playerid, player_adminlvl) && Player(playerid, player_aduty))
				break;
			if(Object(playerid, objectid, obj_owner)[ 0 ] == object_owner_group)
			{
			    new groupid;
				groupid = IsPlayerInUidGroup(playerid, Object(playerid, objectid, obj_owner)[ 1 ]);
				if(!groupid)
			    {
					t = true;
				    continue;
				}
			    if(Group(playerid, groupid, group_can) & member_can_door)
				    break;
				else
			    {
					t = true;
				    continue;
				}
			}
			else if(Object(playerid, objectid, obj_owner)[ 0 ] == object_owner_player)
			{
			    if(Object(playerid, objectid, obj_owner)[ 1 ] != Player(playerid, player_uid))
			    {
					t = true;
				    continue;
				}
				else break;
			}
			else if(Object(playerid, objectid, obj_owner)[ 0 ] == object_owner_doors && Player(playerid, player_door))
			{
			    if(Object(playerid, objectid, obj_owner)[ 1 ] != Door(Player(playerid, player_door), door_uid))
			    {
					t = true;
				    continue;
				}
				else break;
			}
			else
			{
				t = true;
			    continue;
			}
			break;
		}
		if(t)
		    return GameTextForPlayer(playerid, "~r~Brak uprawnien", 3000, 3);
		else if(objectid == MAX_OBJECTS)
		    return ShowCMD(playerid, "Nie jesteś przy żadnej bramie.");

	    new string[ 100 ];
		format(string, sizeof string,
			"UPDATE `surv_objects` SET `gatestatus` = '%d' WHERE `uid` = '%d'",
		    _:Object(playerid, objectid, obj_gatestatus) ? (false) : (true),
		    Object(playerid, objectid, obj_uid)
		);
		mysql_query(string);

		foreach(Player, id)
		{
			if(Player(playerid, player_vw) != Player(id, player_vw)) continue;
			new objectidx = 1;
			for(; objectidx != MAX_OBJECTS; objectidx++)
			{
			    if(Object(id, objectid, obj_objID) == INVALID_OBJECT_ID)
			        continue;
			    if(!IsValidPlayerObject(id, Object(id, objectid, obj_objID)))
			        continue;
			    if(!Object(id, objectid, obj_uid))
					continue;
	        	if(Object(id, objectidx, obj_uid) == Object(playerid, objectid, obj_uid))
	        	    break;
			}
			if(objectidx == MAX_OBJECTS) continue;

			if(!Object(id, objectidx, obj_gatestatus))
			    MovePlayerObject(id, Object(id, objectidx, obj_objID), Object(id, objectidx, obj_positiongate)[ 0 ], Object(id, objectidx, obj_positiongate)[ 1 ], Object(id, objectidx, obj_positiongate)[ 2 ], 2.0, Object(id, objectidx, obj_positiongaterot)[ 0 ], Object(id, objectidx, obj_positiongaterot)[ 1 ], Object(id, objectidx, obj_positiongaterot)[ 2 ]);
			else
			    MovePlayerObject(id, Object(id, objectidx, obj_objID), Object(id, objectidx, obj_position)[ 0 ], Object(id, objectidx, obj_position)[ 1 ], Object(id, objectidx, obj_position)[ 2 ], 2.0, Object(id, objectidx, obj_positionrot)[ 0 ], Object(id, objectidx, obj_positionrot)[ 1 ], Object(id, objectidx, obj_positionrot)[ 2 ]);

			Object(id, objectidx, obj_gatestatus) = !Object(id, objectidx, obj_gatestatus);
		}

		if(Object(playerid, objectid, obj_gatestatus))
		    GameTextForPlayer(playerid, "~g~~h~Brama otwarta", 3000, 3);
		else
		    GameTextForPlayer(playerid, "~r~~h~Brama zamknieta", 3000, 3);
	#endif
	return 1;
}

Cmd::Input->napoj(playerid, params[])
{
	#if STREAMER
	
	#else
		for(new objectid = 1; objectid != MAX_OBJECTS; objectid++)
		{
		    if(Object(playerid, objectid, obj_objID) == INVALID_OBJECT_ID)
		        continue;
		    if(!IsValidPlayerObject(playerid, Object(playerid, objectid, obj_objID)))
		        continue;
		    if(!Object(playerid, objectid, obj_uid))
				continue;
		    if(Object(playerid, objectid, obj_owner)[ 0 ] != object_owner_group)
		        continue;
			if(!IsPlayerInRangeOfPoint(playerid, Object(playerid, objectid, obj_gaterange), Object(playerid, objectid, obj_position)[ 0 ], Object(playerid, objectid, obj_position)[ 1 ], Object(playerid, objectid, obj_position)[ 2 ]))
				continue;
			if(Object(playerid, objectid, obj_model) != 955)
			    continue;

			new buffer[ 512 ], string[ 126 ];
			format(string, sizeof string,
			    "SELECT `uid`, `name`, `price` FROM `surv_products` WHERE `item_type` = '"#item_drink"' AND `owner` = '%d'",
				Object(playerid, objectid, obj_owner)[ 1 ]
			);
			mysql_query(string);
			mysql_store_result();
			while(mysql_fetch_row(string))
			{
			    static uid,
					name[ MAX_ITEM_NAME ],
					Float:price;

				sscanf(string, "p<|>ds["#MAX_ITEM_NAME"]f",
				    uid,
				    name,
				    price
				);
				format(buffer, sizeof buffer, "%s%d\t$%.2f\t\t%s\n", buffer, uid, price, name);
			}
			mysql_free_result();

			if(isnull(buffer)) ShowInfo(playerid, red"Automat jest pusty!");
			else Dialog::Output(playerid, 86, DIALOG_STYLE_LIST, IN_HEAD, buffer, "Kup", "Zamknij");
			return 1;
		}
		ShowInfo(playerid, red"Nie jesteś przy automacie z napojami!");
	#endif
	return 1;
}

Cmd::Input->mc(playerid, params[])
{
	new doorid = GetPlayerDoor(playerid, false);
	if(!doorid && !Player(playerid, player_adminlvl))
		return ShowInfo(playerid, red"Nie stoisz przy żadnych drzwiach!");

	new can_use = IsPlayerDoorOwner(playerid, doorid);
	if(!(can_use != -1))
	    return ShowInfo(playerid, red"Nie możesz stworzyć obiektu w tych drzwiach!");
	    
	if(isnull(params))
	    return ShowCMD(playerid, "Tip: /mc [modelid]");

    GetPlayerPos(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]);
	GetXYInFrontOfPlayer(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], 0.5);
    Player(playerid, player_position)[ 2 ] -= player_down;

	new modelid, objectuid, string[ 200 ];
	modelid = strval(params);

	if(!(0 <= modelid <= 100000))
	    return ShowCMD(playerid, "Error: Zbyt wysoki lub zbyt niski model obiektu!");

	if(CrashedObject(modelid))
	    return ShowCMD(playerid, "Error: Obiekt crasujący rozgrywkę!");
	    
	format(string, sizeof string,
		"INSERT INTO `surv_objects` (`model`, `X`, `Y`, `Z`, `door`, `accept`) VALUES ('%d', '%f', '%f', '%f', '%d', 1)",
		modelid,
		Player(playerid, player_position)[ 0 ],
		Player(playerid, player_position)[ 1 ],
		Player(playerid, player_position)[ 2 ],
		Door(doorid, door_uid)
	);
	mysql_query(string);
	objectuid = mysql_insert_id();
	
	Create(playerid, create_cat) = create_cat_obj;

	#if STREAMER
	    new objectid;
		objectid = CreateDynamicObject(modelid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ], 0, 0, 0, Player(playerid, player_vw), -1, -1, 1000.0);
	    Streamer_SetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_EXTRA_ID, objectuid);
		Streamer_Update(playerid);
		Player(playerid, player_selected_object) = objectid;
		EditDynamicObject(playerid, objectid);
	#else
		foreach(Player, i)
		{
			if(GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(i)) continue;

			new objectid = 1;
			for(; objectid != MAX_OBJECTS; objectid++)
			    if(!IsValidPlayerObject(playerid, Object(playerid, objectid, obj_objID)) && !IsValidObject(objectid))
			        break;

			if(objectid == MAX_OBJECTS)
	        {
	            //DestroyPlayerObject(playerid, objectid);
				ShowInfo(playerid, red"W tym pomieszczeniu skończył się limit obiektów!");
				return 1;
			}
			Object(i, objectid, obj_objID) = CreatePlayerObject(i, modelid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ], 0, 0, 0, 200.0);
			Object(i, objectid, obj_model) = modelid;
			Object(i, objectid, obj_uid) = objectuid;
			if(i == playerid)
			{
			    Player(playerid, player_selected_object) = objectid;
				EditPlayerObject(playerid, Object(playerid, objectid, obj_objID));
			}
		}
	#endif
	Create(playerid, create_value)[ 0 ] = objectuid;
	return 1;
}

Cmd::Input->msel(playerid, params[])
{
	new doorid = GetPlayerDoor(playerid);
	if(!doorid && !Player(playerid, player_adminlvl))
		return ShowInfo(playerid, red"Nie stoisz przy żadnych drzwiach!");

	new can_use = IsPlayerDoorOwner(playerid, doorid);
	if(!(can_use != -1))
	    return ShowInfo(playerid, red"Nie możesz edytować obiektu w tych drzwiach!");

	if(isnull(params))
	{
		if(Player(playerid, player_selected_object) == INVALID_OBJECT_ID)
		{
			SelectObject(playerid);
		    ShowCMD(playerid, "Wybierz obiekt do edycji.");
		    Player(playerid, player_selected_object) = -1;
		}
		else
		{
			ShowCMD(playerid, "Edycja obiektu zakończona!");
			PlayerTextDrawHide(playerid, Player(playerid, player_infos));
		    Player(playerid, player_selected_object) = INVALID_OBJECT_ID;
		    Create(playerid, create_cat) = create_cat_none;
		    CancelEdit(playerid);
		}
	}
	else
	{
		new model = strval(params);
		if(!model)
		    return ShowCMD(playerid, "Tip: /mselid [model]");

		new string[ 126 ];
		#if STREAMER
			new Float:Prevdist = 50.0;
			new objectid;
			
			new Float:ppos[ 3 ];
			GetPlayerPos(playerid, ppos[ 0 ], ppos[ 1 ], ppos[ 2 ]);
			for(new num; num < Streamer_GetUpperBound(STREAMER_TYPE_OBJECT); num++)
		    {
				if(!IsValidDynamicObject(num)) continue;
		    	if(!Streamer_IsInArrayData(STREAMER_TYPE_OBJECT, num, E_STREAMER_WORLD_ID, Player(playerid, player_vw))) continue;
		        if(Streamer_GetIntData(STREAMER_TYPE_OBJECT, num, E_STREAMER_MODEL_ID) != model) continue;

				new Float:pos[ 3 ];
			    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, num, E_STREAMER_X, pos[ 0 ]);
			    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, num, E_STREAMER_Y, pos[ 1 ]);
			    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, num, E_STREAMER_Z, pos[ 2 ]);

				new Float:Dist = Distance3D(ppos[ 0 ], ppos[ 1 ], ppos[ 2 ], pos[ 0 ], pos[ 1 ], pos[ 2 ]);
				if(Dist < Prevdist)
				{
					Prevdist = Dist;
					objectid = num;
				}
		    }
		    if(!objectid) return ShowInfo(playerid, red"Nie znaleziono!");
		    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_X, Player(playerid, player_obj_pos)[ 0 ]);
		    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_Y, Player(playerid, player_obj_pos)[ 1 ]);
		    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_Z, Player(playerid, player_obj_pos)[ 2 ]);
		    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_R_X, Player(playerid, player_obj_pos)[ 3 ]);
		    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_R_Y, Player(playerid, player_obj_pos)[ 4 ]);
		    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_R_Z, Player(playerid, player_obj_pos)[ 5 ]);
			EditDynamicObject(playerid, objectid);

			format(string, sizeof string, "Wybrałeś obiekt ID: %d, UID: %d", objectid, Streamer_GetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_EXTRA_ID));
			ShowCMD(playerid, string);
			
		    format(string, sizeof string, "x: %f~n~y: %f~n~z: %f~n~rx: %f~n~ry: %f~n~rz: %f", Player(playerid, player_obj_pos)[ 0 ], Player(playerid, player_obj_pos)[ 1 ], Player(playerid, player_obj_pos)[ 2 ], Player(playerid, player_obj_pos)[ 0 ], Player(playerid, player_obj_pos)[ 1 ], Player(playerid, player_obj_pos)[ 2 ]);
			PlayerTextDrawSetString(playerid, Player(playerid, player_infos), string);
		#else
			if(model != GetPVarInt(playerid, "obj-model"))
				SetPVarInt(playerid, "obj-search", 0);
				
			new objectid = GetPVarInt(playerid, "obj-search")+1;
			for(; objectid != MAX_OBJECTS; objectid++)
			{
			    if(Object(playerid, objectid, obj_objID) == INVALID_OBJECT_ID)
			        continue;
			    if(!IsValidPlayerObject(playerid, Object(playerid, objectid, obj_objID)))
			        continue;
			    if(!Object(playerid, objectid, obj_uid))
					continue;
				if(Object(playerid, objectid, obj_model) == model)
				    break;
			}
			if(objectid == MAX_OBJECTS) return ShowInfo(playerid, red"Nie znaleziono!");
			EditPlayerObject(playerid, Object(playerid, objectid, obj_objID));
			format(string, sizeof string, "Wybrałeś obiekt ID: %d, UID: %d", Object(playerid, objectid, obj_objID), Object(playerid, objectid, obj_uid));
			ShowCMD(playerid, string);
			SetPVarInt(playerid, "obj-search", objectid);
			SetPVarInt(playerid, "obj-model", model);
		#endif
		PlayerTextDrawShow(playerid, Player(playerid, player_infos));
		Create(playerid, create_cat) = create_cat_eobj;
	    Player(playerid, player_selected_object) = objectid;
	}
	return 1;
}

#if !STREAMER
	Cmd::Input->mselid(playerid, params[])
	{
		new doorid = GetPlayerDoor(playerid);
		if(!doorid && !Player(playerid, player_adminlvl))
			return ShowInfo(playerid, red"Nie stoisz przy żadnych drzwiach!");

		new can_use = IsPlayerDoorOwner(playerid, doorid);
		if(!(can_use != -1))
		    return ShowInfo(playerid, red"Nie możesz edytować obiektu w tych drzwiach!");

		new objectid = strval(params);
		if(!objectid)
		    return ShowCMD(playerid, "Tip: /mselid [SAMPID]");
		if(Player(playerid, player_selected_object) == objectid)
		    return ShowInfo(playerid, red"Edytujesz ten obiekt!");
		if(Object(playerid, objectid, obj_objID) == INVALID_OBJECT_ID)
		    return ShowCMD(playerid, "Taki obiekt nie istnieje!");
		if(objectid >= MAX_OBJECTS)
		    return ShowCMD(playerid, "Zbyt wysoka liczba!");
		new string[ 64 ];
		foreach(Player, i)
		{
		    if(Player(playerid, player_vw) != Player(i, player_vw)) continue;
		    if(Player(i, player_selected_object) == objectid)
		    {
			    Player(playerid, player_selected_object) = INVALID_OBJECT_ID;
			    Create(playerid, create_cat) = create_cat_none;
			    CancelEdit(playerid);
			    PlayerTextDrawHide(playerid, Player(playerid, player_infos));
		        format(string, sizeof string, "Gracz %s (ID: %d) edytuje ten obiekt!", NickName(i), i);
		        ShowCMD(playerid, string);
		        return 1;
		    }
		}
		format(string, sizeof string, "Wybrałeś obiekt ID: %d, UID: %d", Object(playerid, objectid, obj_objID), Object(playerid, objectid, obj_uid));
		ShowCMD(playerid, string);
		PlayerTextDrawShow(playerid, Player(playerid, player_infos));
		Create(playerid, create_cat) = create_cat_eobj;
	    Player(playerid, player_selected_object) = objectid;
		EditPlayerObject(playerid, Object(playerid, objectid, obj_objID));
		return 1;
	}
#endif

Cmd::Input->mmat(playerid, params[])
{
	new object = Player(playerid, player_selected_object);
	if(object == INVALID_OBJECT_ID)
	    return ShowCMD(playerid, "Nie wybrałeś żadnego obiektu do edycji!");
	#if !STREAMER
		if(Object(playerid, object, obj_objID) == INVALID_OBJECT_ID)
	    	return ShowCMD(playerid, "Nie wybrałeś żadnego obiektu do edycji!");
	#endif
	new index, typ, parametr[64];
	if(sscanf(params, "ddS()[64]", index, typ, parametr))
	    return ShowCMD(playerid, "Tip: /mmat [index] [typ] [parametr]");

	if(typ == 0)
	{
	    new color, model, txdname[ 32 ], texturename[ 32 ];
		if(sscanf(parametr, "xds[32]s[32]", color, model, txdname, texturename))
		    return ShowCMD(playerid, "Tip: /mmat [index] [typ] [color] [model] [txdname] [texturename]");
		if(!(0 <= model <= 100000))
		    return ShowCMD(playerid, "Error: Zbyt wysoki lub zbyt niski model obiektu!");

		mysql_real_escape_string(txdname, txdname);
		mysql_real_escape_string(texturename, texturename);
		new string[ 256 ];
		#if STREAMER
			format(string, sizeof string,
			    "UPDATE `surv_objects` SET `index_mat` = '%d', `txdname` = '%s', `texturename` = '%s', `color_mat` = '%x', `modelid` = '%d' WHERE `uid` = '%d'",
			    index,
			    txdname,
			    texturename,
			    color,
			    model,
				Streamer_GetIntData(STREAMER_TYPE_OBJECT, object, E_STREAMER_EXTRA_ID)
			);
		#else
			format(string, sizeof string,
			    "UPDATE `surv_objects` SET `index_mat` = '%d', `txdname` = '%s', `texturename` = '%s', `color_mat` = '%x', `modelid` = '%d' WHERE `uid` = '%d'",
			    index,
			    txdname,
			    texturename,
			    color,
			    model,
		    	Object(playerid, object, obj_uid)
			);
	    #endif
		mysql_query(string);
		
		#if STREAMER
		    SetDynamicObjectMaterial(object, index, model, txdname, texturename, color);
		#else
			foreach(Player, i)
			{
				if(!Player(i, player_spawned) || !Player(i, player_logged)) continue;
			    if(Player(playerid, player_vw) != Player(i, player_vw)) continue;
			    new objectid = 1;
				for(; objectid != MAX_OBJECTS; objectid++)
				{
				    if(Object(i, objectid, obj_objID) == INVALID_OBJECT_ID)
				        continue;
				    if(!IsValidPlayerObject(i, Object(i, objectid, obj_objID)))
				        continue;
				    if(!Object(i, objectid, obj_uid))
						continue;
					if(Object(i, objectid, obj_uid) == Object(playerid, object, obj_uid))
					    break;
				}
				if(objectid == MAX_OBJECTS) continue;
			    SetPlayerObjectMaterial(i, Object(i, objectid, obj_objID), index, model, txdname, texturename, color);
			}
		#endif
		ShowCMD(playerid, "Object Material zmieniony!");
	}
	else if(typ == 1)
	{
	    new matsize, fontsize, bold, align, color_text, bgcolor, font[ 32 ], text[ 64 ];
	    if(sscanf(parametr, "dddxxds[32]s[64]", matsize, fontsize, bold, color_text, bgcolor, align, font, text))
	    	return ShowCMD(playerid, "Tip: /mmat [index] [typ] [matsize] [fontsize] [bold] [fcolor] [bcolor] [align] [font] [text]");
		if(matsize % 10 || !(10 <= matsize <= 140))
		    return ShowCMD(playerid, "Error: Matsize musi być podzielne przez 10 i w zakresie 10-140.");
		if(!(24 <= fontsize <= 255))
		    return ShowCMD(playerid, "Error: Fontsize musi być w zakresie 24-255.");
        if(!(0 <= align <= 2))
            return ShowCMD(playerid, "Error: Align (0 lewo, 1 środek, 2 prawo).");
        if(!(0 <= bold <= 1))
            return ShowCMD(playerid, "Error: Bold (0 wyłączony, 1 włączony).");

		mysql_real_escape_string(text, text);
		mysql_real_escape_string(font, font);
		new string[ 256 ];
		#if STREAMER
			format(string, sizeof string,
			    "UPDATE `surv_objects` SET `index_text` = '%d', `text` = '%s', `font` = '%s', `align` = '%d', `size` = '%d', `tsize` = '%d', `color_text` = '%x', `bgcolor` = '%x', `bold` = '%d' WHERE `uid` = '%d'",
			    index,
			    text,
			    font,
			    align,
			    fontsize,
			    matsize,
			    color_text,
			    bgcolor,
			    bold,
				Streamer_GetIntData(STREAMER_TYPE_OBJECT, object, E_STREAMER_EXTRA_ID)
			);
		#else
			format(string, sizeof string,
			    "UPDATE `surv_objects` SET `index_text` = '%d', `text` = '%s', `font` = '%s', `align` = '%d', `size` = '%d', `tsize` = '%d', `color_text` = '%x', `bgcolor` = '%x', `bold` = '%d' WHERE `uid` = '%d'",
			    index,
			    text,
			    font,
			    align,
			    fontsize,
			    matsize,
			    color_text,
			    bgcolor,
			    bold,
		    	Object(playerid, object, obj_uid)
			);
	    #endif
		mysql_query(string);
		#if STREAMER
			SetDynamicObjectMaterialText(object, index, text, matsize, font, fontsize, bold, color_text, bgcolor, align);
		#else
			foreach(Player, i)
			{
				if(!Player(i, player_spawned) || !Player(i, player_logged)) continue;
			    if(Player(playerid, player_vw) != Player(i, player_vw)) continue;
			    new objectid = 1;
				for(; objectid != MAX_OBJECTS; objectid++)
				{
				    if(Object(i, objectid, obj_objID) == INVALID_OBJECT_ID)
				        continue;
				    if(!IsValidPlayerObject(i, Object(i, objectid, obj_objID)))
				        continue;
				    if(!Object(i, objectid, obj_uid))
						continue;
					if(Object(i, objectid, obj_uid) == Object(playerid, object, obj_uid))
					    break;
				}
				if(objectid == MAX_OBJECTS) continue;
			    SetPlayerObjectMaterialText(i, Object(i, objectid, obj_objID), text, index, matsize, font, fontsize, bold, color_text, bgcolor, align);
			}
		#endif
		ShowCMD(playerid, "Material Text zmieniony!");
	}
	else ShowCMD(playerid, "Za wysoki typ");
	return 1;
}

Cmd::Input->mgate(playerid, params[])
{
	new object = Player(playerid, player_selected_object);
	if(object == INVALID_OBJECT_ID)
	    return ShowCMD(playerid, "Nie wybrałeś żadnego obiektu do edycji!");
	#if !STREAMER
	if(Object(playerid, object, obj_objID) == INVALID_OBJECT_ID)
	    return ShowCMD(playerid, "Nie wybrałeś żadnego obiektu do edycji!");
	#endif
    if(Create(playerid, create_cat) == create_cat_obj)
        return ShowCMD(playerid, "Możesz użyć tej komendy dopiero po ponownym wybraniu obiektu!");

    Create(playerid, create_value)[ 1 ] = true;
    CancelEdit(playerid);
	return 1;
}

Cmd::Input->mdel(playerid, params[])
{
	new object = Player(playerid, player_selected_object);
	if(object == INVALID_OBJECT_ID)
	    return ShowCMD(playerid, "Nie wybrałeś żadnego obiektu do edycji!");
	#if !STREAMER
	if(Object(playerid, object, obj_objID) == INVALID_OBJECT_ID)
	    return ShowCMD(playerid, "Nie wybrałeś żadnego obiektu do edycji!");
	#endif
    if(Create(playerid, create_cat) == create_cat_obj)
        return ShowCMD(playerid, "Wciśnij ESC.");

	new string[ 128 ];
	#if STREAMER
		format(string, sizeof string,
			"UPDATE `surv_objects` SET `accept` = '0' WHERE `uid` = '%d'",
			Streamer_GetIntData(STREAMER_TYPE_OBJECT, object, E_STREAMER_EXTRA_ID)
		);
		mysql_query(string);

		format(string, sizeof string, "Skasowano obiekt, ID: %d, UID: %d", object, Streamer_GetIntData(STREAMER_TYPE_OBJECT, object, E_STREAMER_EXTRA_ID));
	    ShowCMD(playerid, string);
	    
		new c;
		for(; c < MAX_OBJECTS; c++)
		    if(Object(c, obj_objID) == object)
		        break;
        if(c != MAX_OBJECTS)
        {
            for(new eObjects:i; i < eObjects; i++)
				Object(c, i) = 0;
			Object(c, obj_objID) = INVALID_OBJECT_ID;
		}

		DestroyDynamicObject(object);
	#else
		format(string, sizeof string,
			"UPDATE `surv_objects` SET `accept` = '0' WHERE `uid` = '%d'",
			Object(playerid, object, obj_uid)
		);
		mysql_query(string);

		format(string, sizeof string, "Skasowano obiekt, ID: %d, UID: %d", Object(playerid, object, obj_objID), Object(playerid, object, obj_uid));
	    ShowCMD(playerid, string);
		new objectuid = Object(playerid, object, obj_uid);
		foreach(Player, i)
		{
			if(!Player(i, player_spawned) || !Player(i, player_logged)) continue;
		    if(Player(playerid, player_vw) != Player(i, player_vw)) continue;

			for(new objectid = 1; objectid != MAX_OBJECTS; objectid++)
			{
			    if(Object(i, objectid, obj_objID) == INVALID_OBJECT_ID)
			        continue;
			    if(!IsValidPlayerObject(i, Object(i, objectid, obj_objID)))
			        continue;
			    if(!Object(i, objectid, obj_uid))
					continue;
				if(Object(i, objectid, obj_uid) == objectuid)
				{
				    DestroyPlayerObject(i, Object(i, objectid, obj_objID));

					for(new eObjects:d; d < eObjects; d++)
						Object(i, objectid, d)		= 0;

				    Object(i, objectid, obj_objID) = INVALID_OBJECT_ID;
				    break;
				}
			}
		}
	#endif
	PlayerTextDrawHide(playerid, Player(playerid, player_infos));
    Player(playerid, player_selected_object) = INVALID_OBJECT_ID;
    Create(playerid, create_value)[ 1 ] = 0;
	CancelEdit(playerid);
	return 1;
}

Cmd::Input->rx(playerid, params[])
{
	new object = Player(playerid, player_selected_object);
	if(object == INVALID_OBJECT_ID)
	    return ShowCMD(playerid, "Nie wybrałeś żadnego obiektu do edycji!");
	#if !STREAMER
	if(Object(playerid, object, obj_objID) == INVALID_OBJECT_ID)
	    return ShowCMD(playerid, "Nie wybrałeś żadnego obiektu do edycji!");
	#endif
    if(Create(playerid, create_cat) == create_cat_obj)
        return ShowCMD(playerid, "Aby użyć tej komendy musisz ponownie wybrać obiekt przez /msel.");

	if(isnull(params))
	    return ShowCMD(playerid, "Tip: /rx [Wartość]");
	new Float:x = floatstr(params);
	#if STREAMER
		new Float:pos[ 3 ],
			Float:rpos[ 3 ];
		StopDynamicObject(object);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_X, pos[ 0 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_Y, pos[ 1 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_Z, pos[ 2 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_X, rpos[ 0 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_Y, rpos[ 1 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_Z, rpos[ 2 ]);
	    Create(playerid, create_value)[ 1 ] = 3;
	    SetDynamicObjectRot(object, rpos[ 0 ]+x, rpos[ 1 ], rpos[ 2 ]);
		OnPlayerEditDynamicObject(playerid, object, EDIT_RESPONSE_UPDATE, pos[ 0 ], pos[ 1 ], pos[ 2 ], rpos[ 0 ]+x, rpos[ 1 ], rpos[ 2 ]);
	#else
		Object(playerid, object, obj_positionrot)[ 0 ] += x;
		SetPlayerObjectRot(playerid, Object(playerid, object, obj_objID), Object(playerid, object, obj_positionrot)[ 0 ], Object(playerid, object, obj_positionrot)[ 1 ], Object(playerid, object, obj_positionrot)[ 2 ]);
	#endif
    //Create(playerid, create_value)[ 1 ] = 3;
	//CancelEdit(playerid);
	return 1;
}

Cmd::Input->ry(playerid, params[])
{
	new object = Player(playerid, player_selected_object);
	if(object == INVALID_OBJECT_ID)
	    return ShowCMD(playerid, "Nie wybrałeś żadnego obiektu do edycji!");
	#if !STREAMER
	if(Object(playerid, object, obj_objID) == INVALID_OBJECT_ID)
	    return ShowCMD(playerid, "Nie wybrałeś żadnego obiektu do edycji!");
	#endif
    if(Create(playerid, create_cat) == create_cat_obj)
        return ShowCMD(playerid, "Aby użyć tej komendy musisz ponownie wybrać obiekt przez /msel.");

	if(isnull(params))
	    return ShowCMD(playerid, "Tip: /ry [Wartość]");
	new Float:x = floatstr(params);
	#if STREAMER
		new Float:pos[ 3 ],
			Float:rpos[ 3 ];
		StopDynamicObject(object);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_X, pos[ 0 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_Y, pos[ 1 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_Z, pos[ 2 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_X, rpos[ 0 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_Y, rpos[ 1 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_Z, rpos[ 2 ]);
	    Create(playerid, create_value)[ 1 ] = 3;
	    SetDynamicObjectRot(object, rpos[ 0 ], rpos[ 1 ]+x, rpos[ 2 ]);
		OnPlayerEditDynamicObject(playerid, object, EDIT_RESPONSE_UPDATE, pos[ 0 ], pos[ 1 ], pos[ 2 ], rpos[ 0 ], rpos[ 1 ]+x, rpos[ 2 ]);
	#else
		Object(playerid, object, obj_positionrot)[ 1 ] += x;
		SetPlayerObjectRot(playerid, Object(playerid, object, obj_objID), Object(playerid, object, obj_positionrot)[ 0 ], Object(playerid, object, obj_positionrot)[ 1 ], Object(playerid, object, obj_positionrot)[ 2 ]);
	    Create(playerid, create_value)[ 1 ] = 3;
		CancelEdit(playerid);
	#endif
	return 1;
}

Cmd::Input->rz(playerid, params[])
{
	new object = Player(playerid, player_selected_object);
	if(object == INVALID_OBJECT_ID)
	    return ShowCMD(playerid, "Nie wybrałeś żadnego obiektu do edycji!");
	#if !STREAMER
	if(Object(playerid, object, obj_objID) == INVALID_OBJECT_ID)
	    return ShowCMD(playerid, "Nie wybrałeś żadnego obiektu do edycji!");
	#endif
    if(Create(playerid, create_cat) == create_cat_obj)
        return ShowCMD(playerid, "Aby użyć tej komendy musisz ponownie wybrać obiekt przez /msel.");

	if(isnull(params))
	    return ShowCMD(playerid, "Tip: /rz [Wartość]");
	new Float:x = floatstr(params);
	#if STREAMER
		new Float:pos[ 3 ],
			Float:rpos[ 3 ];
		StopDynamicObject(object);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_X, pos[ 0 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_Y, pos[ 1 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_Z, pos[ 2 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_X, rpos[ 0 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_Y, rpos[ 1 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_Z, rpos[ 2 ]);
	    Create(playerid, create_value)[ 1 ] = 3;
	    SetDynamicObjectRot(object, rpos[ 0 ], rpos[ 1 ], rpos[ 2 ]+x);
		OnPlayerEditDynamicObject(playerid, object, EDIT_RESPONSE_UPDATE, pos[ 0 ], pos[ 1 ], pos[ 2 ], rpos[ 0 ], rpos[ 1 ], rpos[ 2 ]+x);
	#else
		Object(playerid, object, obj_positionrot)[ 2 ] += x;
		SetPlayerObjectRot(playerid, Object(playerid, object, obj_objID), Object(playerid, object, obj_positionrot)[ 0 ], Object(playerid, object, obj_positionrot)[ 1 ], Object(playerid, object, obj_positionrot)[ 2 ]);
	    Create(playerid, create_value)[ 1 ] = 3;
		CancelEdit(playerid);
	#endif
	return 1;
}

Cmd::Input->mx(playerid, params[])
{
	new object = Player(playerid, player_selected_object);
	if(object == INVALID_OBJECT_ID)
	    return ShowCMD(playerid, "Nie wybrałeś żadnego obiektu do edycji!");
	#if !STREAMER
	if(Object(playerid, object, obj_objID) == INVALID_OBJECT_ID)
	    return ShowCMD(playerid, "Nie wybrałeś żadnego obiektu do edycji!");
	#endif
    if(Create(playerid, create_cat) == create_cat_obj)
        return ShowCMD(playerid, "Aby użyć tej komendy musisz ponownie wybrać obiekt przez /msel.");

	if(isnull(params))
	    return ShowCMD(playerid, "Tip: /mx [Wartość]");
	new Float:x = floatstr(params);
	#if STREAMER
		new Float:pos[ 3 ],
			Float:rpos[ 3 ];
		StopDynamicObject(object);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_X, pos[ 0 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_Y, pos[ 1 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_Z, pos[ 2 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_X, rpos[ 0 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_Y, rpos[ 1 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_Z, rpos[ 2 ]);
	    Create(playerid, create_value)[ 1 ] = 3;
	    SetDynamicObjectPos(object, pos[ 0 ]+x, pos[ 1 ], pos[ 2 ]);
		OnPlayerEditDynamicObject(playerid, object, EDIT_RESPONSE_UPDATE, pos[ 0 ]+x, pos[ 1 ], pos[ 2 ], rpos[ 0 ], rpos[ 1 ], rpos[ 2 ]);
	#else
		Object(playerid, object, obj_position)[ 0 ] += x;
		SetPlayerObjectPos(playerid, Object(playerid, object, obj_objID), Object(playerid, object, obj_position)[ 0 ], Object(playerid, object, obj_position)[ 1 ], Object(playerid, object, obj_position)[ 2 ]);
	    Create(playerid, create_value)[ 1 ] = 3;
		CancelEdit(playerid);
	#endif
	return 1;
}

Cmd::Input->my(playerid, params[])
{
	new object = Player(playerid, player_selected_object);
	if(object == INVALID_OBJECT_ID)
	    return ShowCMD(playerid, "Nie wybrałeś żadnego obiektu do edycji!");
	#if !STREAMER
	if(Object(playerid, object, obj_objID) == INVALID_OBJECT_ID)
	    return ShowCMD(playerid, "Nie wybrałeś żadnego obiektu do edycji!");
	#endif
    if(Create(playerid, create_cat) == create_cat_obj)
        return ShowCMD(playerid, "Aby użyć tej komendy musisz ponownie wybrać obiekt przez /msel.");

	if(isnull(params))
	    return ShowCMD(playerid, "Tip: /my [Wartość]");
	new Float:x = floatstr(params);
	#if STREAMER
		new Float:pos[ 3 ],
			Float:rpos[ 3 ];
		StopDynamicObject(object);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_X, pos[ 0 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_Y, pos[ 1 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_Z, pos[ 2 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_X, rpos[ 0 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_Y, rpos[ 1 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_Z, rpos[ 2 ]);
	    Create(playerid, create_value)[ 1 ] = 3;
	    SetDynamicObjectPos(object, pos[ 0 ], pos[ 1 ]+x, pos[ 2 ]);
		OnPlayerEditDynamicObject(playerid, object, EDIT_RESPONSE_UPDATE, pos[ 0 ], pos[ 1 ]+x, pos[ 2 ], rpos[ 0 ], rpos[ 1 ], rpos[ 2 ]);
	#else
		Object(playerid, object, obj_position)[ 1 ] += x;
		SetPlayerObjectPos(playerid, Object(playerid, object, obj_objID), Object(playerid, object, obj_position)[ 0 ], Object(playerid, object, obj_position)[ 1 ], Object(playerid, object, obj_position)[ 2 ]);
	    Create(playerid, create_value)[ 1 ] = 3;
		CancelEdit(playerid);
	#endif
	return 1;
}

Cmd::Input->mz(playerid, params[])
{
	new object = Player(playerid, player_selected_object);
	if(object == INVALID_OBJECT_ID)
	    return ShowCMD(playerid, "Nie wybrałeś żadnego obiektu do edycji!");
	#if !STREAMER
	if(Object(playerid, object, obj_objID) == INVALID_OBJECT_ID)
	    return ShowCMD(playerid, "Nie wybrałeś żadnego obiektu do edycji!");
	#endif
    if(Create(playerid, create_cat) == create_cat_obj)
        return ShowCMD(playerid, "Aby użyć tej komendy musisz ponownie wybrać obiekt przez /msel.");

	if(isnull(params))
	    return ShowCMD(playerid, "Tip: /mz [Wartość]");
	new Float:x = floatstr(params);
	#if STREAMER
		new Float:pos[ 3 ],
			Float:rpos[ 3 ];
		StopDynamicObject(object);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_X, pos[ 0 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_Y, pos[ 1 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_Z, pos[ 2 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_X, rpos[ 0 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_Y, rpos[ 1 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_Z, rpos[ 2 ]);
	    Create(playerid, create_value)[ 1 ] = 3;
	    SetDynamicObjectPos(object, pos[ 0 ], pos[ 1 ], pos[ 2 ]+x);
		OnPlayerEditDynamicObject(playerid, object, EDIT_RESPONSE_UPDATE, pos[ 0 ], pos[ 1 ], pos[ 2 ]+x, rpos[ 0 ], rpos[ 1 ], rpos[ 2 ]);
	#else
		Object(playerid, object, obj_position)[ 2 ] += x;
		SetPlayerObjectPos(playerid, Object(playerid, object, obj_objID), Object(playerid, object, obj_position)[ 0 ], Object(playerid, object, obj_position)[ 1 ], Object(playerid, object, obj_position)[ 2 ]);
	    Create(playerid, create_value)[ 1 ] = 3;
		CancelEdit(playerid);
	#endif
	return 1;
}

Cmd::Input->mkopia(playerid, params[])
{
	new object = Player(playerid, player_selected_object);
	if(object == INVALID_OBJECT_ID)
	    return ShowCMD(playerid, "Nie wybrałeś żadnego obiektu do edycji!");
	#if !STREAMER
	if(Object(playerid, object, obj_objID) == INVALID_OBJECT_ID)
	    return ShowCMD(playerid, "Nie wybrałeś żadnego obiektu do edycji!");
	#endif
    if(Create(playerid, create_cat) == create_cat_obj)
        return ShowCMD(playerid, "Aby użyć tej komendy musisz ponownie wybrać obiekt przez /msel.");

	new doorid = GetPlayerDoor(playerid, false);
	if(!doorid && !Player(playerid, player_adminlvl))
		return ShowInfo(playerid, red"Nie stoisz przy żadnych drzwiach!");

	new can_use = IsPlayerDoorOwner(playerid, doorid);
	if(!(can_use != -1))
	    return ShowInfo(playerid, red"Nie możesz stworzyć obiektu w tych drzwiach!");

    Create(playerid, create_value)[ 1 ] = 2;
	CancelEdit(playerid);
	return 1;
}

Cmd::Input->medytuj(playerid, params[])
{
	if(!Player(playerid, player_adminlvl))
	    return 1;
	new object = Player(playerid, player_selected_object);
	if(object == INVALID_OBJECT_ID)
	    return ShowCMD(playerid, "Nie wybrałeś żadnego obiektu do edycji!");
    if(Create(playerid, create_cat) == create_cat_obj)
        return ShowCMD(playerid, "Aby użyć tej komendy musisz ponownie wybrać obiekt przez /msel.");
        
    new Temp[ 512 ],
		uid, model, Float:range,
		owner[ 2 ], owner_name[ MAX_GROUP_NAME ],
		c;
		
   	new index_mat, index_text,
		color_text, color_mat, bgcolor,
		size, tsize, align, bold, text[ 64 ],
		modelid, txdname[ 32 ],
		texturename[ 32 ], font[ 32 ];

	#if STREAMER
		uid = Streamer_GetIntData(STREAMER_TYPE_OBJECT, object, E_STREAMER_EXTRA_ID);
	    model = Streamer_GetIntData(STREAMER_TYPE_OBJECT, object, E_STREAMER_MODEL_ID);
	    GetDynamicObjectMaterial(object, index_mat, modelid, txdname, texturename, color_mat);
	    GetDynamicObjectMaterialText(object, index_text, text, size, font, tsize, bold, color_text, bgcolor, align);

		for(; c < MAX_OBJECTS; c++)
		    if(Object(c, obj_objID) == object)
		        break;
		if(c != MAX_OBJECTS)
		{
		    owner[ 0 ] = Object(c, obj_owner)[ 0 ];
		    owner[ 1 ] = Object(c, obj_owner)[ 1 ];
		    if(!(Object(c, obj_positiongate)[ 0 ] == 0.0 && Object(c, obj_positiongate)[ 1 ] == 0.0 && Object(c, obj_positiongate)[ 2 ] == 0.0))
		    	range = Object(c, obj_gaterange);
		}
		else
		{
		    new string[ 126 ];
			format(string, sizeof string,
			    "SELECT `ownerType`, `owner`, `gateRange` FROM `surv_objects` WHERE `uid` = '%d'",
			    uid
			);
			mysql_query(string);
			mysql_store_result();
			mysql_fetch_row(string);
			sscanf(string, "p<|>a<d>[2]f", owner, range);
			mysql_free_result();
		}
	#else
		if(Object(playerid, object, obj_objID) == INVALID_OBJECT_ID)
		    return ShowCMD(playerid, "Nie wybrałeś żadnego obiektu do edycji!");

		owner[ 0 ] = Object(playerid, object, obj_owner)[ 0 ];
		owner[ 1 ] = Object(playerid, object, obj_owner)[ 1 ];
		model = Object(playerid, object, obj_model);
		range = Object(playerid, object, obj_gaterange);
	#endif
	
	if(owner[ 0 ] == object_owner_plant)
	    owner_name = "Plantacja";
	else if(owner[ 0 ] == object_owner_none)
	    owner_name = "n/a";
	else
	{
        new owner_list[ ][ ] = {"", "surv_groups", "surv_players", "surv_doors", "surv_items"};
    	format(Temp, sizeof Temp,
        	"SELECT `name` FROM `%s` WHERE `uid` = '%d'",
            owner_list[ owner[ 0 ] ],
            owner[ 1 ]
		);
		mysql_query(Temp);
		mysql_store_result();
		if(!mysql_num_rows()) owner_name = "n/a";
		else mysql_fetch_row(owner_name);
		mysql_free_result();
        if(owner[ 0 ] == object_owner_player)
            UnderscoreToSpace(owner_name);
	}
	format(Temp, sizeof Temp, "UID:\t\t\t%d\n", uid);
	format(Temp, sizeof Temp, "%sModel:\t\t\t%d\n", Temp, model);
	if(range) format(Temp, sizeof Temp, "%sRange:\t\t\t%.2fj\n", Temp, range);
	format(Temp, sizeof Temp, "%sWłaściciel:\t\t%d:%d (%s)\n", Temp, owner[ 0 ], owner[ 1 ], owner_name);
	#if STREAMER
	    GetDynamicObjectMaterial(object, index_mat, modelid, txdname, texturename, color_mat);
	    GetDynamicObjectMaterialText(object, index_text, text, size, font, tsize, bold, color_text, bgcolor, align);

		strcat(Temp, grey"------------------------\n");
        format(Temp, sizeof Temp, "%sIndex Mat:\t\t%d\n", Temp, index_mat);
        format(Temp, sizeof Temp, "%sModel:\t\t\t%d\n", Temp, modelid);
        format(Temp, sizeof Temp, "%sTxdname:\t\t%s\n", Temp, txdname);
        format(Temp, sizeof Temp, "%sTexturename:\t\t%s\n", Temp, texturename);
        format(Temp, sizeof Temp, "%sColor:\t\t\t#%x\n", Temp, color_mat);
		strcat(Temp, grey"------------------------\n");
        format(Temp, sizeof Temp, "%sIndex Mat:\t\t%d\n", Temp, index_text);
        format(Temp, sizeof Temp, "%sText:\t\t\t%s\n", Temp, text);
        format(Temp, sizeof Temp, "%sSize:\t\t\t%d\n", Temp, size);
        format(Temp, sizeof Temp, "%sFont:\t\t\t%s\n", Temp, font);
        format(Temp, sizeof Temp, "%sText size:\t\t%d\n", Temp, tsize);
        format(Temp, sizeof Temp, "%sBold:\t\t\t%s\n", Temp, YesOrNo(bool:bold));
        format(Temp, sizeof Temp, "%sColor Text:\t\t#%x\n", Temp, color_text);
        format(Temp, sizeof Temp, "%sBg Color:\t\t#%x\n", Temp, bgcolor);
        format(Temp, sizeof Temp, "%sAlign:\t\t\t%d\n", Temp, align);
	#endif
	strcat(Temp, grey"------------------------\n");
	strcat(Temp, "Zmień właściciela\n");
	if(c != MAX_OBJECTS) strcat(Temp, "Zmień range bramy\n");
	Dialog::Output(playerid, 152, DIALOG_STYLE_LIST, IN_HEAD, Temp, "Wybierz", "Zamknij");
	return 1;
}

#if STREAMER
	Cmd::Input->hotdog(playerid, params[])
	{
		new bool:is;
		for(new objectid; objectid < Streamer_GetUpperBound(STREAMER_TYPE_OBJECT); objectid++)
	    {
			if(!IsValidDynamicObject(objectid))
				continue;
	        if(Streamer_GetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_MODEL_ID) != hotdog_model)
	            continue;
		    if(!Streamer_IsInArrayData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_WORLD_ID, Player(playerid, player_vw)))
				continue;

			new Float:pos[ 3 ];
		    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_X, pos[ 0 ]);
		    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_Y, pos[ 1 ]);
		    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_Z, pos[ 2 ]);
			if(!IsPlayerInRangeOfPoint(playerid, 5.0, pos[ 0 ], pos[ 1 ], pos[ 2 ]))
				continue;

	        is = true;
	        break;
	    }
	    if(!is)
			return ShowInfo(playerid, red"Nie jesteś przy stoisku z Hot dogami.");

	    new victimid;
	    if(sscanf(params, "u", victimid))
			return ShowCMD(playerid, "Tip: /o(feruj) hotdog [ID/Nick]");
		if(victimid == playerid)
		    return ShowCMD(playerid, "Nie możesz zaoferować czegoś sobie!");
		if(!IsPlayerConnected(victimid))
			return NoPlayer(playerid);
		if(!OdlegloscMiedzyGraczami(5.0, playerid, victimid))
			return ShowCMD(playerid, "Gracz nie znajduje się w pobliżu.");
	    if(Offer(victimid, offer_active))
	        return ShowInfo(playerid, OFFER_FALSE);

		Offer(playerid, offer_type) 		= offer_type_hotdog;
		Offer(playerid, offer_player) 		= victimid;
		Offer(playerid, offer_cash)			= 10.0;
		Offer(playerid, offer_active)       = true;

		Offer(victimid, offer_type) 		= offer_type_hotdog;
		Offer(victimid, offer_player) 		= playerid;
		Offer(victimid, offer_cash)			= 10.0;
		Offer(victimid, offer_active)       = true;
		ShowPlayerOffer(playerid, victimid);
	    return 1;
	}
#endif

#if STREAMER
	public OnPlayerSelectDynamicObject(playerid, objectid, modelid, Float:x, Float:y, Float:z)
	{
		if(Player(playerid, player_selected_object) == objectid)
		    return ShowInfo(playerid, red"Edytujesz ten obiekt!");

		Create(playerid, create_cat) = create_cat_eobj;
		Player(playerid, player_selected_object) = objectid;

		EditDynamicObject(playerid, Player(playerid, player_selected_object));

		StopDynamicObject(objectid);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_X, Player(playerid, player_obj_pos)[ 0 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_Y, Player(playerid, player_obj_pos)[ 1 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_Z, Player(playerid, player_obj_pos)[ 2 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_R_X, Player(playerid, player_obj_pos)[ 3 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_R_Y, Player(playerid, player_obj_pos)[ 4 ]);
	    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_R_Z, Player(playerid, player_obj_pos)[ 5 ]);

		new string[ 126 ];
		format(string, sizeof string,
			"Wybrałeś obiekt ID: %d, UID: %d",
			Player(playerid, player_selected_object),
			Streamer_GetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_EXTRA_ID)
		);
		ShowCMD(playerid, string);
		ShowCMD(playerid, "Obiekt wybrany, wpisz: /mmat lub /mgate. Aby anulować wpisz /msel");

	    format(string, sizeof string, "x: %f~n~y: %f~n~z: %f~n~rx: %f~n~ry: %f~n~rz: %f", Player(playerid, player_obj_pos)[ 0 ], Player(playerid, player_obj_pos)[ 1 ], Player(playerid, player_obj_pos)[ 2 ], Player(playerid, player_obj_pos)[ 0 ], Player(playerid, player_obj_pos)[ 1 ], Player(playerid, player_obj_pos)[ 2 ]);
		PlayerTextDrawSetString(playerid, Player(playerid, player_infos), string);

		PlayerTextDrawShow(playerid, Player(playerid, player_infos));
		return 1;
	}

#else

	public OnPlayerSelectObject(playerid, type, objectid, modelid, Float:fX, Float:fY, Float:fZ)
	{
		#if Debug
			printf("OnPlayerSelectObject(%d, %d, %d, %d, %f, %f, %f)", playerid, type, objectid, modelid, fX, fY, fZ);
		#endif
		if(objectid > MAX_OBJECTS)
		    return ShowCMD(playerid, "Obiekt nie został wybrany z powodu braku limitu w tym pomieszczeniu!");
		new string[ 64 ];
		if(type == SELECT_OBJECT_PLAYER_OBJECT)
		{
		    new objidx = 1;
			for(; objidx != MAX_OBJECTS; objidx++)
			{
			    if(Object(playerid, objidx, obj_objID) == INVALID_OBJECT_ID)
			        continue;
			    if(!IsValidPlayerObject(playerid, Object(playerid, objidx, obj_objID)))
			        continue;
			    if(!Object(playerid, objidx, obj_uid))
					continue;
				if(Object(playerid, objidx, obj_objID) == objectid)
				    break;
			}
			if(objidx == MAX_OBJECTS) return 1;

			foreach(Player, i)
			{
			    if(Player(playerid, player_vw) != Player(i, player_vw)) continue;
			    if(Player(i, player_selected_object) == Object(playerid, objidx, obj_objID))
			    {
				    Player(playerid, player_selected_object) = INVALID_OBJECT_ID;
				    Create(playerid, create_cat) = create_cat_none;
				    CancelEdit(playerid);
			        format(string, sizeof string, "Gracz %s (ID: %d) edytuje ten obiekt!", NickName(i), i);
			        ShowCMD(playerid, string);
			        return 1;
			    }
			}
			Create(playerid, create_cat) = create_cat_eobj;
			Player(playerid, player_selected_object) = objidx;
			PlayerTextDrawShow(playerid, Player(playerid, player_infos));

			EditPlayerObject(playerid, Player(playerid, player_selected_object));

			format(string, sizeof string, "Wybrałeś obiekt ID: %d, UID: %d", Object(playerid, objidx, obj_objID), Object(playerid, objidx, obj_uid));
			ShowCMD(playerid, string);
			ShowCMD(playerid, "Obiekt wybrany, wpisz: /mmat lub /mgate. Aby anulować wpisz /msel");
		}
		return 1;
	}
#endif

#if STREAMER
	public OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
	{
		if(!IsValidDynamicObject(objectid)) return 1;
		MoveDynamicObject(objectid, x, y, z, 10.0, rx, ry, rz);
		if(Create(playerid, create_cat) == create_cat_obj)
		{
		    new objectuid = Create(playerid, create_value)[ 0 ];
		    if(response == EDIT_RESPONSE_CANCEL)
			{
			    new string[ 64 ];
				format(string, sizeof string,
					"DELETE FROM `surv_objects` WHERE `uid` = '%d'",
					objectuid
				);
				mysql_query(string);

				new c;
				for(; c < MAX_OBJECTS; c++)
				    if(Object(c, obj_objID) == Player(playerid, player_selected_object))
				        break;
                if(c != MAX_OBJECTS)
                {
                    for(new eObjects:i; i < eObjects; i++)
						Object(c, i) = 0;
					Object(c, obj_objID) = INVALID_OBJECT_ID;
				}
				DestroyDynamicObject(Player(playerid, player_selected_object));
	            
	            End_Create(playerid);
			    PlayerTextDrawHide(playerid, Player(playerid, player_infos));
	            Player(playerid, player_selected_object) = INVALID_OBJECT_ID;
	            
			    Chat::Output(playerid, SZARY, "Stawianie obiektu anulowane!");
			}
			else if(response == EDIT_RESPONSE_UPDATE)
			{
			    new string[ 126 ];
			    format(string, sizeof string, "x: %f~n~y: %f~n~z: %f~n~rx: %f~n~ry: %f~n~rz: %f", x, y, z, rx, ry, rz);
			    PlayerTextDrawSetString(playerid, Player(playerid, player_infos), string);
			}
			else if(response == EDIT_RESPONSE_FINAL)
			{
			    new object = Player(playerid, player_selected_object),
					string[ 200 ];

				format(string, sizeof string,
					"UPDATE `surv_objects` SET `X` = '%f', `Y` = '%f', `Z` = '%f', `rX` = '%f', `rY` = '%f', `rZ` = '%f' WHERE `uid` = '%d'",
					x, y, z,
					rx, ry, rz,
					objectuid
				);
				mysql_query(string);

                StopDynamicObject(object);
			    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_X, x);
			    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_Y, y);
			    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_Z, z);
			    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_X, rx);
			    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_Y, ry);
			    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_Z, rz);

                SetDynamicObjectRot(object, rx, ry, rz);
                SetDynamicObjectPos(object, x, y, z);

				format(string, sizeof string, "Obiekt stworzony! UID: %d, sampid: %d", objectuid, object);
	            Chat::Output(playerid, SZARY, string);
	            
				End_Create(playerid);
			    PlayerTextDrawHide(playerid, Player(playerid, player_infos));
				Player(playerid, player_selected_object) = INVALID_OBJECT_ID;
			}
		}
		else if(Create(playerid, create_cat) == create_cat_eobj)
		{
		    new object = Player(playerid, player_selected_object);
			if(Create(playerid, create_value)[ 1 ] == 1)
			{
			    new doorid = Player(playerid, player_door);
			    
				new string[ 360 ];
				format(string, sizeof string,
				    "UPDATE `surv_objects` SET `gateX` = '%f', `gateY` = '%f', `gateZ` = '%f', `gateRotX` = '%f', `gateRotY` = '%f', `gateRotZ` = '%f', `ownerType` = '%d', `owner` = '%d' WHERE `uid` = '%d'",
					x, y, z,
					rx, ry, rz,
					Door(doorid, door_owner)[ 0 ],
					Door(doorid, door_owner)[ 1 ],
				    Streamer_GetIntData(STREAMER_TYPE_OBJECT, object, E_STREAMER_EXTRA_ID)
				);
				mysql_query(string);
				
				new c;
				for(; c < MAX_OBJECTS; c++)
				    if(Object(c, obj_objID) == object)
				        break;
				if(c == MAX_OBJECTS)
				{
				    for(c = 0; c < MAX_OBJECTS; c++)
				    	if(Object(c, obj_objID) == INVALID_OBJECT_ID)
				    	    break;
				    if(c != MAX_OBJECTS)
				    {
						Object(c, obj_objID) = object;
						Object(c, obj_position)[ 0 ] = Player(playerid, player_obj_pos)[ 0 ];
						Object(c, obj_position)[ 1 ] = Player(playerid, player_obj_pos)[ 1 ];
						Object(c, obj_position)[ 2 ] = Player(playerid, player_obj_pos)[ 2 ];
						Object(c, obj_positionrot)[ 0 ] = Player(playerid, player_obj_pos)[ 3 ];
						Object(c, obj_positionrot)[ 1 ] = Player(playerid, player_obj_pos)[ 4 ];
						Object(c, obj_positionrot)[ 2 ] = Player(playerid, player_obj_pos)[ 5 ];
						Object(c, obj_positiongate)[ 0 ] = x;
						Object(c, obj_positiongate)[ 1 ] = y;
						Object(c, obj_positiongate)[ 2 ] = z;
						Object(c, obj_positiongaterot)[ 0 ] = rx;
						Object(c, obj_positiongaterot)[ 1 ] = ry;
						Object(c, obj_positiongaterot)[ 2 ] = rz;
						Object(c, obj_owner)[ 0 ] = Door(doorid, door_owner)[ 0 ];
						Object(c, obj_owner)[ 1 ] = Door(doorid, door_owner)[ 1 ];
						Object(c, obj_gaterange) = 2.0;
					}
				}
                else if(c != MAX_OBJECTS)
                {
					Object(c, obj_positiongate)[ 0 ] = x;
					Object(c, obj_positiongate)[ 1 ] = y;
					Object(c, obj_positiongate)[ 2 ] = z;
					Object(c, obj_positiongaterot)[ 0 ] = rx;
					Object(c, obj_positiongaterot)[ 1 ] = ry;
					Object(c, obj_positiongaterot)[ 2 ] = rz;
				}
                SetDynamicObjectPos(object, Player(playerid, player_obj_pos)[ 0 ], Player(playerid, player_obj_pos)[ 1 ], Player(playerid, player_obj_pos)[ 2 ]);
                SetDynamicObjectRot(object, Player(playerid, player_obj_pos)[ 3 ], Player(playerid, player_obj_pos)[ 4 ], Player(playerid, player_obj_pos)[ 5 ]);

	            Player(playerid, player_selected_object) = INVALID_OBJECT_ID;
			    PlayerTextDrawHide(playerid, Player(playerid, player_infos));
	            Create(playerid, create_value)[ 1 ] = 0;

				ShowCMD(playerid, "Pozycja bramy zapisana!");
			}
			else if(Create(playerid, create_value)[ 1 ] == 2)
			{
				new string[ 1024 ];

				new uid, model, Float:pos[ 3 ], Float:rot[ 3 ], owner[ 2 ];
			    new index_mat, index_text,
					color_text, color_mat, bgcolor,
					size, tsize, align, text[ 64 ],
					modelid, txdname[ 32 ], bold, vw,
					texturename[ 32 ], font[ 32 ];

				format(string, sizeof string, "INSERT INTO `surv_objects` (`model`, `X`, `Y`, `Z`, `rX`, `rY`, `rZ`, `gateX`, `gateY`, `gateZ`, `gatestatus`, `gateRange`, `ownerType`, `owner`, `index_text`, `index_mat`, `color_text`, `color_mat`, `bgcolor`, `tsize`, `size`, `align`, `bold`, `text`, `modelid`, `txdname`, `texturename`, `font`, `door`, `accept`)");
				format(string, sizeof string, "%s SELECT '%d', '%f', '%f', '%f', '%f', '%f', '%f', `gateX`, `gateY`, `gateZ`, `gatestatus`, `gateRange`, `ownerType`, `owner`, `index_text`, `index_mat`, `color_text`, `color_mat`, `bgcolor`, `tsize`, `size`, `align`, `bold`, `text`, `modelid`, `txdname`, `texturename`, `font`, `door`, '1' FROM `surv_objects` WHERE `uid` = '%d'",
					string,
					Streamer_GetIntData(STREAMER_TYPE_OBJECT, object, E_STREAMER_MODEL_ID),
					x,y,z,
					rx,ry,rz,
				    Streamer_GetIntData(STREAMER_TYPE_OBJECT, object, E_STREAMER_EXTRA_ID)
				);
				mysql_query(string);
				uid = mysql_insert_id();

				format(string, sizeof string,
				    "SELECT o.*, IFNULL(d.in_pos_vw, 0) as 'vw' FROM `surv_objects` o LEFT JOIN `surv_doors` d ON o.door = d.uid WHERE o.uid = '%d'",
				    uid
				);
				mysql_query(string);
				mysql_store_result();
				mysql_fetch_row(string);
				mysql_free_result();

				sscanf(string, "p<|>d{d}da<f>[3]a<f>[3]{a<f>[3]a<f>[3]df}a<d>[2]ddxxxdddds[64]ds[32]s[32]s[32]{dd}d",
			        uid, model, pos, rot, owner,
					index_text,
					index_mat,
					color_text,
					color_mat,
					bgcolor,
					size,
					tsize,
					align,
					bold,
					text,
					modelid,
					txdname,
					texturename,
					font,
					vw
				);
				
				object = CreateDynamicObject(model, pos[ 0 ], pos[ 1 ], pos[ 2 ], rot[ 0 ], rot[ 1 ], rot[ 2 ], vw, -1, -1, 1000.0);
				Streamer_SetIntData(STREAMER_TYPE_OBJECT, object, E_STREAMER_EXTRA_ID, uid);

                Player(playerid, player_obj_pos)[ 0 ] = pos[ 0 ];
                Player(playerid, player_obj_pos)[ 1 ] = pos[ 1 ];
                Player(playerid, player_obj_pos)[ 2 ] = pos[ 2 ];
                Player(playerid, player_obj_pos)[ 3 ] = rot[ 0 ];
                Player(playerid, player_obj_pos)[ 4 ] = rot[ 1 ];
                Player(playerid, player_obj_pos)[ 5 ] = rot[ 2 ];
                
				if(!(DIN(txdname, "NULL")) || !(DIN(texturename, "NULL")))
				    SetDynamicObjectMaterial(object, index_mat, modelid, txdname, texturename, color_mat);
				if(!(DIN(text, "NULL")))
				    SetDynamicObjectMaterialText(object, index_text, text, size, font, tsize, bold, color_text, bgcolor, align);

				Create(playerid, create_cat) = create_cat_eobj;
			    Player(playerid, player_selected_object) = object;
				EditDynamicObject(playerid, object);

				Create(playerid, create_value)[ 1 ] = 0;
				ShowCMD(playerid, "Obiekt skopiowany!");
			}
	        else if(Create(playerid, create_value)[ 1 ] == 3)
	        {
			    new string[ 256 ];
			    format(string, sizeof string, "x: %f~n~y: %f~n~z: %f~n~rx: %f~n~ry: %f~n~rz: %f", x, y, z, rx, ry, rz);
			    PlayerTextDrawSetString(playerid, Player(playerid, player_infos), string);
				EditDynamicObject(playerid, object);
				Create(playerid, create_value)[ 1 ] = 0;
	        }
			else if(response == EDIT_RESPONSE_UPDATE)
			{
			    new string[ 256 ];
			    format(string, sizeof string, "x: %f~n~y: %f~n~z: %f~n~rx: %f~n~ry: %f~n~rz: %f", x, y, z, rx, ry, rz);
			    PlayerTextDrawSetString(playerid, Player(playerid, player_infos), string);
			}
			else if(response == EDIT_RESPONSE_CANCEL)
			{
				StopDynamicObject(object);
			    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_X, Player(playerid, player_obj_pos)[ 0 ]);
			    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_Y, Player(playerid, player_obj_pos)[ 1 ]);
			    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_Z, Player(playerid, player_obj_pos)[ 2 ]);
			    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_X, Player(playerid, player_obj_pos)[ 3 ]);
			    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_Y, Player(playerid, player_obj_pos)[ 4 ]);
			    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_Z, Player(playerid, player_obj_pos)[ 5 ]);
                
			    Player(playerid, player_selected_object) = INVALID_OBJECT_ID;
			    Create(playerid, create_value)[ 1 ] = 0;
			    PlayerTextDrawHide(playerid, Player(playerid, player_infos));
			    
			    ShowCMD(playerid, "Edycja obiektu anulowana!");
			}
			else if(response == EDIT_RESPONSE_FINAL)
			{
			    new string[ 256 ];
				format(string, sizeof string,
					"UPDATE `surv_objects` SET `X` = '%f', `Y` = '%f', `Z` = '%f', `rX` = '%f', `rY` = '%f', `rZ` = '%f' WHERE `uid` = '%d'",
					x,y,z,
					rx,ry,rz,
					Streamer_GetIntData(STREAMER_TYPE_OBJECT, object, E_STREAMER_EXTRA_ID)
				);
				mysql_query(string);

                StopDynamicObject(object);
			    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_X, x);
			    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_Y, y);
			    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_Z, z);
			    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_X, rx);
			    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_Y, ry);
			    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, object, E_STREAMER_R_Z, rz);

                SetDynamicObjectRot(object, rx, ry, rz);
                SetDynamicObjectPos(object, x, y, z);
				new c;
				for(; c < MAX_OBJECTS; c++)
				    if(Object(c, obj_objID) == object)
				        break;
				if(c != MAX_OBJECTS)
				{
					Object(c, obj_position)[ 0 ] = x;
					Object(c, obj_position)[ 1 ] = y;
					Object(c, obj_position)[ 2 ] = z;
					Object(c, obj_positionrot)[ 0 ] = rx;
					Object(c, obj_positionrot)[ 1 ] = ry;
					Object(c, obj_positionrot)[ 2 ] = rx;
				}
			    Player(playerid, player_selected_object) = INVALID_OBJECT_ID;
			    PlayerTextDrawHide(playerid, Player(playerid, player_infos));
			    Create(playerid, create_value)[ 1 ] = 0;

				format(string, sizeof string, "Zapisałeś obiekt ID: %d, UID: %d", object, Streamer_GetIntData(STREAMER_TYPE_OBJECT, object, E_STREAMER_EXTRA_ID));
				ShowCMD(playerid, string);

				ShowCMD(playerid, "Pozycja obiektu zapisana!");
			}
		}
		else
		{
			if(response == EDIT_RESPONSE_CANCEL)
			{
			    new objectuid = GetPVarInt(playerid, "seed-object-uid");
			    new plantuid = GetPVarInt(playerid, "seed-plant-uid");
			    if(objectuid && plantuid)
			    {
					new c;
					for(; c < MAX_OBJECTS; c++)
					    if(Object(c, obj_objID) == objectid)
					        break;
	                if(c != MAX_OBJECTS)
	                {
	                    for(new eObjects:i; i < eObjects; i++)
    						Object(c, i) = 0;
						Object(c, obj_objID) = INVALID_OBJECT_ID;
					}
					DestroyDynamicObject(objectid);
				    
				    new string[ 128 ];
					format(string, sizeof string, "DELETE FROM `surv_plants` WHERE `uid` = '%d'", plantuid);
					mysql_query(string);

					format(string, sizeof string, "DELETE FROM `surv_objects` WHERE `uid` = '%d'", objectuid);
					mysql_query(string);

				    Chat::Output(playerid, SZARY, "Sadzenie rośliny anulowane!");
					DeletePVar(playerid, "seed-object-uid");
					DeletePVar(playerid, "seed-plant-uid");
					DeletePVar(playerid, "seed-item-value");
					DeletePVar(playerid, "seed-item-uid");
			    }
			}
			if(response == EDIT_RESPONSE_FINAL)
			{
			    new itemuid = GetPVarInt(playerid, "seed-item-uid");
			    new itemvalue = GetPVarInt(playerid, "seed-item-value");
			    new objectuid = GetPVarInt(playerid, "seed-object-uid");
			    new plantuid = GetPVarInt(playerid, "seed-plant-uid");

			    if(itemuid && objectuid && plantuid && itemvalue)
			    {
			        new string[ 250 ];
					format(string, sizeof string,
						"UPDATE `surv_objects` SET `X` = '%f', `Y` = '%f', `Z` = '%f', `rX` = '%f', `rY` = '%f', `rZ` = '%f', `ownerType` = "#object_owner_plant" AND `owner` = '%d' WHERE `uid` = '%d'",
						x, y, z,
						rx, ry, rz,
						plantuid,
						objectuid
					);
					mysql_query(string);

				    itemvalue--;
				    if(!itemvalue)
				    {
						format(string, sizeof string, "DELETE FROM `surv_items` WHERE `uid` = '%d'", itemuid);
						mysql_query(string);
				    }
				    else
				    {
						format(string, sizeof string, "UPDATE `surv_items` SET `v2`=`v2` - 1 WHERE `uid` = '%d'", itemuid);
						mysql_query(string);
					}

					DeletePVar(playerid, "seed-object-uid");
					DeletePVar(playerid, "seed-plant-uid");
					DeletePVar(playerid, "seed-item-value");
					DeletePVar(playerid, "seed-item-uid");
					
	                StopDynamicObject(objectid);
				    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_X, x);
				    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_Y, y);
				    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_Z, z);
				    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_R_X, rx);
				    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_R_Y, ry);
				    Streamer_SetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_R_Z, rz);

                	SetDynamicObjectRot(objectid, rx, ry, rz);
                	SetDynamicObjectPos(objectid, x, y, z);
                	
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
							Object(c, obj_position)[ 0 ] = x;
							Object(c, obj_position)[ 1 ] = y;
							Object(c, obj_position)[ 2 ] = z;
							Object(c, obj_positionrot)[ 0 ] = rx;
							Object(c, obj_positionrot)[ 1 ] = ry;
							Object(c, obj_positionrot)[ 2 ] = rz;
							Object(c, obj_owner)[ 0 ] = object_owner_plant;
							Object(c, obj_owner)[ 1 ] = plantuid;
						}
					}
	                else if(c != MAX_OBJECTS)
	                {
						Object(c, obj_owner)[ 0 ] = object_owner_plant;
						Object(c, obj_owner)[ 1 ] = plantuid;
					}

				    foreach(Player, i)
				    {
						if(!Player(i, player_spawned) || !Player(i, player_logged)) continue;
				        if(Player(playerid, player_vw) != Player(i, player_vw)) continue;

						new textid = 1;
						for(; textid != MAX_3DTEXT_PLAYER; textid++)
						    if(Text(i, textid, text_textID) == PlayerText3D:INVALID_3DTEXT_ID)
						        break;
						if(textid == MAX_3DTEXT_PLAYER) continue;
						Text(i, textid, text_textID) = CreatePlayer3DTextLabel(i, C_BLUE2"Ukończono: "white"0%", BIALY, x, y, z+1, 30, .testLOS=1);
		                Text(i, textid, text_pos)[ 0 ] = x;
		                Text(i, textid, text_pos)[ 1 ] = y;
		                Text(i, textid, text_pos)[ 2 ] = z;
		                Text(i, textid, text_owner)[ 0 ] = text_owner_plant;
		                Text(i, textid, text_owner)[ 1 ] = plantuid;
				    }
				    Chat::Output(playerid, SZARY, "Roślina posadzona!");
				}
			}
		}
	    return 1;
	}
	
	stock GetObjectID(objectuid)
	{
	    if(objectuid == INVALID_OBJECT_ID) return false;
		for(new objectid; objectid < Streamer_GetUpperBound(STREAMER_TYPE_OBJECT); objectid++)
	    {
			if(!IsValidDynamicObject(objectid)) continue;
	        if(Streamer_GetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_EXTRA_ID) == objectuid)
	            return objectid;
	    }
	    return INVALID_OBJECT_ID;
	}
#else
	public OnPlayerEditObject(playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
	{
		if(Create(playerid, create_cat) == create_cat_obj)
		{
		    new objectuid = Create(playerid, create_value)[ 0 ],
				string[ 200 ];
		    if(response == EDIT_RESPONSE_CANCEL)
			{
				format(string, sizeof string, "DELETE FROM `surv_objects` WHERE `uid` = '%d'", objectuid);
				mysql_query(string);

	            End_Create(playerid);
			    PlayerTextDrawHide(playerid, Player(playerid, player_infos));
	            Player(playerid, player_selected_object) = INVALID_OBJECT_ID;

			    foreach(Player, i)
			    {
			        if(!Player(i, player_spawned) || !Player(i, player_logged)) continue;
			        if(Player(playerid, player_vw) != Player(i, player_vw)) continue;
					new obj = 1;
					for(; obj != MAX_OBJECTS; obj++)
					{
					    if(Object(i, obj, obj_objID) == INVALID_OBJECT_ID)
							continue;
					    if(!Object(i, obj, obj_uid))
							continue;
					    if(Object(i, obj, obj_uid) == objectuid)
					        break;
					}
					if(obj == MAX_OBJECTS) continue;
					DestroyPlayerObject(i, Object(i, obj, obj_objID));
					for(new eObjects:d; d < eObjects; d++)
						Object(i, obj, d)		= 0;
					Object(i, obj, obj_objID) = INVALID_OBJECT_ID;
			    }
			    Chat::Output(playerid, SZARY, "Stawianie obiektu anulowane!");
			}
			else if(response == EDIT_RESPONSE_UPDATE)
			{
			    format(string, sizeof string, "x: %f~n~y: %f~n~z: %f~n~rx: %f~n~ry: %f~n~rz: %f", fX, fY, fZ, fRotX, fRotY, fRotZ);
			    PlayerTextDrawSetString(playerid, Player(playerid, player_infos), string);
			}
			else if(response == EDIT_RESPONSE_FINAL)
			{
			    new t;

				format(string, sizeof string,
					"UPDATE `surv_objects` SET `X` = '%f', `Y` = '%f', `Z` = '%f', `rX` = '%f', `rY` = '%f', `rZ` = '%f' WHERE `uid` = '%d'",
					fX, fY, fZ,
					fRotX, fRotY, fRotZ,
					objectuid
				);
				mysql_query(string);

				End_Create(playerid);
			    PlayerTextDrawHide(playerid, Player(playerid, player_infos));
				Player(playerid, player_selected_object) = INVALID_OBJECT_ID;

			    foreach(Player, i)
			    {
			        if(!Player(i, player_spawned) || !Player(i, player_logged)) continue;
			        if(Player(playerid, player_vw) != Player(i, player_vw)) continue;

			        new obj = 1;
					for(; obj != MAX_OBJECTS; obj++)
					{
					    if(Object(i, obj, obj_objID) == INVALID_OBJECT_ID)
							continue;
					    if(!Object(i, obj, obj_uid))
							continue;
						if(Object(i, obj, obj_uid) != objectuid)
							continue;
						break;
					}
					if(obj == MAX_OBJECTS) continue;
					Object(i, obj, obj_position)[ 0 ] = fX;
					Object(i, obj, obj_position)[ 1 ] = fY;
					Object(i, obj, obj_position)[ 2 ] = fZ;
					Object(i, obj, obj_positionrot)[ 0 ] = fRotX;
					Object(i, obj, obj_positionrot)[ 1 ] = fRotY;
					Object(i, obj, obj_positionrot)[ 2 ] = fRotZ;
				    SetPlayerObjectPos(i, Object(i, obj, obj_objID), Object(i, obj, obj_position)[ 0 ], Object(i, obj, obj_position)[ 1 ], Object(i, obj, obj_position)[ 2 ]);
					SetPlayerObjectRot(i, Object(i, obj, obj_objID), Object(i, obj, obj_positionrot)[ 0 ], Object(i, obj, obj_positionrot)[ 1 ], Object(i, obj, obj_positionrot)[ 2 ]);
					if(i == playerid) t = obj;
				}

				format(string, sizeof string, "Obiekt stworzony! UID: %d, sampid: %d", Object(playerid, t, obj_uid), Object(playerid, t, obj_objID));
	            Chat::Output(playerid, SZARY, string);
			}
		}
		else if(Create(playerid, create_cat) == create_cat_eobj)
		{
		    new object = Player(playerid, player_selected_object);
			if(Create(playerid, create_value)[ 1 ] == 1)
			{
				new string[ 256 ];
				format(string, sizeof string,
				    "UPDATE `surv_objects` SET `gateX` = '%f', `gateY` = '%f', `gateZ` = '%f', `gateRotX` = '%f', `gateRotY` = '%f', `gateRotZ` = '%f' WHERE `uid` = '%d'",
				    fX,
					fY,
					fZ,
					fRotX,
					fRotY,
					fRotZ,
				    Object(playerid, object, obj_uid)
				);
				mysql_query(string);

	            Player(playerid, player_selected_object) = INVALID_OBJECT_ID;
			    PlayerTextDrawHide(playerid, Player(playerid, player_infos));
	            Create(playerid, create_value)[ 1 ] = 0;

				foreach(Player, i)
				{
					if(!Player(i, player_spawned) || !Player(i, player_logged)) continue;
				    if(Player(playerid, player_vw) != Player(i, player_vw)) continue;
				    new objectidx = 1;
					for(; objectidx != MAX_OBJECTS; objectidx++)
					{
					    if(Object(i, objectidx, obj_objID) == INVALID_OBJECT_ID)
							continue;
					    if(!Object(i, objectidx, obj_uid))
							continue;
						if(Object(i, objectidx, obj_uid) == Object(playerid, object, obj_uid))
							break;
					}
					if(objectidx == MAX_OBJECTS) continue;
					Object(i, objectidx, obj_positiongate)[ 0 ] = fX;
					Object(i, objectidx, obj_positiongate)[ 1 ] = fY;
					Object(i, objectidx, obj_positiongate)[ 2 ] = fZ;
					Object(i, objectidx, obj_positiongaterot)[ 0 ] = fRotX;
					Object(i, objectidx, obj_positiongaterot)[ 1 ] = fRotY;
					Object(i, objectidx, obj_positiongaterot)[ 2 ] = fRotZ;
					Object(i, objectidx, obj_gaterange) = 2.0;
				    SetPlayerObjectPos(i, Object(i, objectidx, obj_objID), Object(i, objectidx, obj_position)[ 0 ], Object(i, objectidx, obj_position)[ 1 ], Object(i, objectidx, obj_position)[ 2 ]);
					SetPlayerObjectRot(i, Object(i, objectidx, obj_objID), Object(i, objectidx, obj_positionrot)[ 0 ], Object(i, objectidx, obj_positionrot)[ 1 ], Object(i, objectidx, obj_positionrot)[ 2 ]);
				}

				ShowCMD(playerid, "Pozycja bramy zapisana!");
			}
			else if(Create(playerid, create_value)[ 1 ] == 2)
			{
				new string[ 700 ];

				new uid, model, Float:pos[ 3 ], Float:rot[ 3 ], owner[ 2 ];
			    new index_mat, index_text,
					color_text, color_mat, bgcolor,
					size, tsize, align, text[ 64 ],
					modelid, txdname[ 32 ],
					texturename[ 32 ], font[ 32 ];

				format(string, sizeof string, "INSERT INTO `surv_objects` (`model`, `X`, `Y`, `Z`, `rX`, `rY`, `rZ`, `gateX`, `gateY`, `gateZ`, `gatestatus`, `gateRange`, `ownerType`, `owner`, `index_text`, `index_mat`, `color_text`, `color_mat`, `bgcolor`, `tsize`, `size`, `align`, `text`, `modelid`, `txdname`, `texturename`, `font`, `door`, `accept`)");
				format(string, sizeof string, "%s SELECT `model`, '%f', '%f', '%f', '%f', '%f', '%f', `gateX`, `gateY`, `gateZ`, `gatestatus`, `gateRange`, `ownerType`, `owner`, `index_text`, `index_mat`, `color_text`, `color_mat`, `bgcolor`, `tsize`, `size`, `align`, `text`, `modelid`, `txdname`, `texturename`, `font`, `door`, `accept` FROM `surv_objects` WHERE `uid` = '%d'",
					string,
					fX, fY, fZ,
					fRotX, fRotY, fRotZ,
				    Object(playerid, object, obj_uid)
				);
				mysql_query(string);
				uid = mysql_insert_id();

				format(string, sizeof string,
				    "SELECT * FROM `surv_objects` WHERE `uid` = '%d'",
				    uid
				);
				mysql_query(string);
				mysql_store_result();
				mysql_fetch_row(string);
				mysql_free_result();

				sscanf(string, "p<|>d{d}da<f>[3]a<f>[3]{a<f>[3]a<f>[3]df}a<d>[2]ddxxxddds[64]ds[32]s[32]s[32]{dd}f",
			        uid, model, pos, rot, owner,
					index_text,
					index_mat,
					color_text,
					color_mat,
					bgcolor,
					size,
					tsize,
					align,
					text,
					modelid,
					txdname,
					texturename,
					font
				);

				foreach(Player, i)
				{
					if(!Player(i, player_spawned) || !Player(i, player_logged)) continue;
	                if(Player(playerid, player_vw) != Player(i, player_vw)) continue;

					new objectidx = 1;
					for(; objectidx != MAX_OBJECTS; objectidx++)
					    if(!IsValidPlayerObject(i, Object(i, objectidx, obj_objID)) && !IsValidObject(objectidx) && Object(i, objectidx, obj_objID) == INVALID_OBJECT_ID)
					        break;
					if(objectidx == MAX_OBJECTS) continue;

					Object(i, objectidx, obj_objID) = CreatePlayerObject(i, model, pos[ 0 ], pos[ 1 ], pos[ 2 ], rot[ 0 ], rot[ 1 ], rot[ 2 ], 200.0);
					Object(i, objectidx, obj_model) = model;
					Object(i, objectidx, obj_uid) = uid;
					Object(i, objectidx, obj_owner)[ 0 ] = owner[ 0 ];
					Object(i, objectidx, obj_owner)[ 1 ] = owner[ 1 ];
					if(!(DIN(txdname, "NULL")) || !(DIN(texturename, "NULL")))
					{
					    SetPlayerObjectMaterial(i, Object(i, objectidx, obj_objID), index_mat, modelid, txdname, texturename, color_mat);
					}
					if(!(DIN(text, "NULL")))
					{
					    SetPlayerObjectMaterialText(i, Object(i, objectidx, obj_objID), text, index_text, size, font, tsize, 0, color_text, bgcolor, align);
					}
					if(i == playerid)
					{
						Create(i, create_cat) = create_cat_eobj;
					    Player(i, player_selected_object) = objectidx;
						EditPlayerObject(i, Object(i, objectidx, obj_objID));
					}
				}
				Create(playerid, create_value)[ 1 ] = 0;
				ShowCMD(playerid, "Obiekt skopiowany!");
			}
	        else if(Create(playerid, create_value)[ 1 ] == 3)
	        {
			    new string[ 256 ];
			    format(string, sizeof string, "x: %f~n~y: %f~n~z: %f~n~rx: %f~n~ry: %f~n~rz: %f", fX, fY, fZ, fRotX, fRotY, fRotZ);
			    PlayerTextDrawSetString(playerid, Player(playerid, player_infos), string);
				EditPlayerObject(playerid, Object(playerid, object, obj_objID));
				Create(playerid, create_value)[ 1 ] = 0;
	        }
			else if(response == EDIT_RESPONSE_UPDATE)
			{
			    new string[ 256 ];
			    format(string, sizeof string, "x: %f~n~y: %f~n~z: %f~n~rx: %f~n~ry: %f~n~rz: %f", fX, fY, fZ, fRotX, fRotY, fRotZ);
			    PlayerTextDrawSetString(playerid, Player(playerid, player_infos), string);
			}
			else if(response == EDIT_RESPONSE_CANCEL)
			{
			    SetPlayerObjectPos(playerid, Object(playerid, object, obj_objID), Object(playerid, object, obj_position)[ 0 ], Object(playerid, object, obj_position)[ 1 ], Object(playerid, object, obj_position)[ 2 ]);
				SetPlayerObjectRot(playerid, Object(playerid, object, obj_objID), Object(playerid, object, obj_positionrot)[ 0 ], Object(playerid, object, obj_positionrot)[ 1 ], Object(playerid, object, obj_positionrot)[ 2 ]);
			    Player(playerid, player_selected_object) = INVALID_OBJECT_ID;
			    Create(playerid, create_value)[ 1 ] = 0;
			    PlayerTextDrawHide(playerid, Player(playerid, player_infos));
			}
			else if(response == EDIT_RESPONSE_FINAL)
			{
			    new string[ 256 ];
				format(string, sizeof string,
					"UPDATE `surv_objects` SET `X` = '%f', `Y` = '%f', `Z` = '%f', `rX` = '%f', `rY` = '%f', `rZ` = '%f' WHERE `uid` = '%d'",
					fX, fY, fZ,
					fRotX, fRotY, fRotZ,
					Object(playerid, object, obj_uid)
				);
				mysql_query(string);

			    Player(playerid, player_selected_object) = INVALID_OBJECT_ID;
			    PlayerTextDrawHide(playerid, Player(playerid, player_infos));
			    Create(playerid, create_value)[ 1 ] = 0;

			    foreach(Player, i)
			    {
					if(!Player(i, player_spawned) || !Player(i, player_logged)) continue;
			        if(Player(playerid, player_vw) != Player(i, player_vw)) continue;

				    new objectidx = 1;
					for(; objectidx != MAX_OBJECTS; objectidx++)
					{
					    if(Object(i, objectidx, obj_objID) == INVALID_OBJECT_ID)
							continue;
					    if(!Object(i, objectidx, obj_uid))
							continue;

						if(Object(i, objectidx, obj_uid) == Object(playerid, object, obj_uid))
						    break;
					}
					Object(i, objectidx, obj_position)[ 0 ] = fX;
					Object(i, objectidx, obj_position)[ 1 ] = fY;
					Object(i, objectidx, obj_position)[ 2 ] = fZ;
					Object(i, objectidx, obj_positionrot)[ 0 ] = fRotX;
					Object(i, objectidx, obj_positionrot)[ 1 ] = fRotY;
					Object(i, objectidx, obj_positionrot)[ 2 ] = fRotZ;

				    SetPlayerObjectPos(i, Object(i, objectidx, obj_objID), Object(i, objectidx, obj_position)[ 0 ], Object(i, objectidx, obj_position)[ 1 ], Object(i, objectidx, obj_position)[ 2 ]);
					SetPlayerObjectRot(i, Object(i, objectidx, obj_objID), Object(i, objectidx, obj_positionrot)[ 0 ], Object(i, objectidx, obj_positionrot)[ 1 ], Object(i, objectidx, obj_positionrot)[ 2 ]);
				}


				format(string, sizeof string, "Zapisałeś obiekt ID: %d, UID: %d", Object(playerid, object, obj_objID), Object(playerid, object, obj_uid));
				ShowCMD(playerid, string);

				ShowCMD(playerid, "Pozycja obiektu zapisana!");
			}
		}
		else
		{
			if(response == EDIT_RESPONSE_CANCEL)
			{
			    new objectuid = GetPVarInt(playerid, "seed-object-uid");
			    new plantuid = GetPVarInt(playerid, "seed-plant-uid");
			    if(objectuid && plantuid)
			    {
				    foreach(Player, i)
				    {
						if(!Player(i, player_spawned) || !Player(i, player_logged)) continue;
				        if(Player(playerid, player_vw) != Player(i, player_vw)) continue;

						for(new obj = 1; obj != MAX_OBJECTS; obj++)
						{
						    if(Object(i, obj, obj_objID) == INVALID_OBJECT_ID) continue;
						    if(Object(i, obj, obj_uid) != objectuid) continue;

						    DestroyPlayerObject(i, Object(i, obj, obj_objID));
							for(new eObjects:d; d < eObjects; d++)
								Object(i, obj, d)		= 0;
							Object(i, obj, obj_objID) = INVALID_OBJECT_ID;
							break;
						}
				    }
				    new string[ 128 ];
					format(string, sizeof string, "DELETE FROM `surv_plants` WHERE `uid` = '%d'", plantuid);
					mysql_query(string);

					format(string, sizeof string, "DELETE FROM `surv_objects` WHERE `uid` = '%d'", objectuid);
					mysql_query(string);

				    Chat::Output(playerid, SZARY, "Sadzenie rośliny anulowane!");
					DeletePVar(playerid, "seed-object-uid");
					DeletePVar(playerid, "seed-plant-uid");
					DeletePVar(playerid, "seed-item-value");
					DeletePVar(playerid, "seed-item-uid");
			    }
			}
			if(response == EDIT_RESPONSE_FINAL)
			{
			    new itemuid = GetPVarInt(playerid, "seed-item-uid");
			    new itemvalue = GetPVarInt(playerid, "seed-item-value");
			    new objectuid = GetPVarInt(playerid, "seed-object-uid");
			    new plantuid = GetPVarInt(playerid, "seed-plant-uid");

			    if(itemuid && objectuid && plantuid && itemvalue)
			    {
			        new string[ 250 ];
					format(string, sizeof string,
						"UPDATE `surv_objects` SET `X` = '%f', `Y` = '%f', `Z` = '%f', `rX` = '%f', `rY` = '%f', `rZ` = '%f', `ownerType` = "#object_owner_plant" AND `owner` = '%d' WHERE `uid` = '%d'",
						fX, fY, fZ,
						fRotX, fRotY, fRotZ,
						plantuid,
						objectuid
					);
					mysql_query(string);

				    itemvalue--;
				    if(!itemvalue)
				    {
						format(string, sizeof string, "DELETE FROM `surv_items` WHERE `uid` = '%d'", itemuid);
						mysql_query(string);
				    }
				    else
				    {
						format(string, sizeof string, "UPDATE `surv_items` SET `v2`=`v2` - 1 WHERE `uid` = '%d'", itemuid);
						mysql_query(string);
					}

					DeletePVar(playerid, "seed-object-uid");
					DeletePVar(playerid, "seed-plant-uid");
					DeletePVar(playerid, "seed-item-value");
					DeletePVar(playerid, "seed-item-uid");
				    foreach(Player, i)
				    {
						if(!Player(i, player_spawned) || !Player(i, player_logged)) continue;
				        if(Player(playerid, player_vw) != Player(i, player_vw)) continue;

				        new obj = 1;
						for(; obj != MAX_OBJECTS; obj++)
						{
						    if(Object(i, obj, obj_objID) == INVALID_OBJECT_ID) continue;
						    if(!IsValidPlayerObject(i, Object(i, obj, obj_objID)))
						        continue;
						    if(!Object(i, obj, obj_uid))
								continue;
							if(Object(i, obj, obj_uid) == objectuid)
								break;
						}
						if(obj == MAX_OBJECTS) continue;
						Object(i, obj, obj_position)[ 0 ] = fX;
						Object(i, obj, obj_position)[ 1 ] = fY;
						Object(i, obj, obj_position)[ 2 ] = fZ;
						Object(i, obj, obj_positionrot)[ 0 ] = fRotX;
						Object(i, obj, obj_positionrot)[ 1 ] = fRotY;
						Object(i, obj, obj_positionrot)[ 2 ] = fRotZ;
						Object(i, obj, obj_owner)[ 0 ] = object_owner_plant;
						Object(i, obj, obj_owner)[ 1 ] = plantuid;
					    SetPlayerObjectPos(i, Object(i, obj, obj_objID), Object(i, obj, obj_position)[ 0 ], Object(i, obj, obj_position)[ 1 ], Object(i, obj, obj_position)[ 2 ]);
						SetPlayerObjectRot(i, Object(i, obj, obj_objID), Object(i, obj, obj_positionrot)[ 0 ], Object(i, obj, obj_positionrot)[ 1 ], Object(i, obj, obj_positionrot)[ 2 ]);

						new textid = 1;
						for(; textid != MAX_3DTEXT_PLAYER; textid++)
						    if(Text(i, textid, text_textID) == PlayerText3D:INVALID_3DTEXT_ID)
						        break;
						if(textid == MAX_3DTEXT_PLAYER) continue;
						Text(i, textid, text_textID) = CreatePlayer3DTextLabel(i, C_BLUE2"Ukończono: "white"0%", BIALY, fX, fY, fZ+1, 30, .testLOS=1);
		                Text(i, textid, text_pos)[ 0 ] = fX;
		                Text(i, textid, text_pos)[ 1 ] = fY;
		                Text(i, textid, text_pos)[ 2 ] = fZ;
		                Text(i, textid, text_owner)[ 0 ] = text_owner_plant;
		                Text(i, textid, text_owner)[ 1 ] = plantuid;
				    }
				    Chat::Output(playerid, SZARY, "Roślina posadzona!");
				}
			}
		}
		return 1;
	}
#endif

stock CrashedObject(model)
{
    switch(model)
    {
        case 384, 385, 386, 387, 388, 389, 390, 391, 392, 393, 1573:
        {
            return true;
        }
    }
    return false;
}
