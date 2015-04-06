/* TODO:
 - instalacja immobilisera, alarmu
*/

FuncPub::LoadVehicles()
{
	new carid = 1;
	for(; carid != MAX_VEHICLES; carid++)
	    if(!GetVehicleModel(carid))
	        break;

    mysql_query("UPDATE `surv_vehicles` SET `spawned` = '0'");
    new string[ 256 ];
	mysql_query("SELECT surv_vehicles.*, surv_cd.url FROM `surv_vehicles` LEFT JOIN `surv_cd` ON surv_vehicles.sound = surv_cd.uid WHERE surv_vehicles.ownerType != "#vehicle_owner_player"");
	mysql_store_result();
	while(mysql_fetch_row_format(string))
	{
	    if(carid == MAX_VEHICLES) break;
	    static damage[ 32 ], tires[ 32 ];
	    
	    sscanf(string, "p<|>dds[64]a<d>[2]a<f>[4]dda<d>[2]s[32]dfffs[32]d{d}da<d>[12]dddfs[64]s[32]{d}s[64]",
		    Vehicle(carid, vehicle_uid),
		    Vehicle(carid, vehicle_model),
		    Vehicle(carid, vehicle_name),
		    Vehicle(carid, vehicle_owner),
		    Vehicle(carid, vehicle_position),
		    Vehicle(carid, vehicle_vw),
		    Vehicle(carid, vehicle_int),
		    Vehicle(carid, vehicle_color),
		    damage,
		    Vehicle(carid, vehicle_fuel_type),
		    Vehicle(carid, vehicle_fuel),
		    Vehicle(carid, vehicle_hp),
		    Vehicle(carid, vehicle_distance),
		    Vehicle(carid, vehicle_plate),
		    Vehicle(carid, vehicle_option),
		    Vehicle(carid, vehicle_pj),
		    Vehicle(carid, vehicle_mod),
		    Vehicle(carid, vehicle_neon),
		    Vehicle(carid, vehicle_attached),
		    Vehicle(carid, vehicle_siren),
		    Vehicle(carid, vehicle_block),
		    Vehicle(carid, vehicle_block_reason),
		    tires,
		    Vehicle(carid, vehicle_url)
	    );
	    
	    sscanf(damage, "p<,>a<d>[4]",
			Vehicle(carid, vehicle_damage)
		);
		
		sscanf(tires, "p<,>a<f>[4]",
		    Vehicle(carid, vehicle_tire)
		);

	    Vehicle(carid, vehicle_vehID) = CreateVehicle(Vehicle(carid, vehicle_model), Vehicle(carid, vehicle_position)[ 0 ], Vehicle(carid, vehicle_position)[ 1 ], Vehicle(carid, vehicle_position)[ 2 ], Vehicle(carid, vehicle_position)[ 3 ], Vehicle(carid, vehicle_color)[ 0 ], Vehicle(carid, vehicle_color)[ 1 ], -1);
        
		Itter_Add(Server_Vehicles, Vehicle(carid, vehicle_vehID));
	    carid++;
	}
	mysql_free_result();
	foreach(Server_Vehicles, vid) OnVehicleSpawn(vid);
	printf("# Pojazdy zostały wczytane! | %d", Vehicle(carid-1, vehicle_vehID));
	mysql_query("UPDATE `surv_vehicles` SET `spawned` = '1' WHERE `ownerType` != "#vehicle_owner_player"");
	return 1;
}

FuncPub::LoadVehicleEx(vehicleuid)
{
	foreach(Server_Vehicles, vehid)
	    if(vehicleuid == Vehicle(vehid, vehicle_uid))
	        return 0;
	#if Debug
	    printf("LoadVehicleEx(%d)", vehicleuid);
	#endif
	new string[ 256 ];
	format(string, sizeof string,
		"SELECT surv_vehicles.*, surv_cd.url FROM `surv_vehicles` LEFT JOIN `surv_cd` ON surv_vehicles.sound = surv_cd.uid WHERE surv_vehicles.uid = '%d'",
		vehicleuid
	);
	mysql_query(string);
	mysql_store_result();
	mysql_fetch_row(string);
	mysql_free_result();
	
	new carid = 1;
	for(; carid != MAX_VEHICLES; carid++)
	    if(!GetVehicleModel(carid))
	        break;
	        
	if(carid == MAX_VEHICLES) return print("Skończył się limit pojazdów!");
	
	new damage[ 32 ], tires[ 32 ];
	sscanf(string, "p<|>dds[64]a<d>[2]a<f>[4]dda<d>[2]s[32]dfffs[32]d{d}da<d>[12]dddfs[64]s[32]{d}s[64]",
	    Vehicle(carid, vehicle_uid),
	    Vehicle(carid, vehicle_model),
	    Vehicle(carid, vehicle_name),
	    Vehicle(carid, vehicle_owner),
	    Vehicle(carid, vehicle_position),
	    Vehicle(carid, vehicle_vw),
	    Vehicle(carid, vehicle_int),
	    Vehicle(carid, vehicle_color),
	    damage,
	    Vehicle(carid, vehicle_fuel_type),
	    Vehicle(carid, vehicle_fuel),
	    Vehicle(carid, vehicle_hp),
	    Vehicle(carid, vehicle_distance),
	    Vehicle(carid, vehicle_plate),
	    Vehicle(carid, vehicle_option),
	    Vehicle(carid, vehicle_pj),
	    Vehicle(carid, vehicle_mod),
	    Vehicle(carid, vehicle_neon),
		Vehicle(carid, vehicle_attached),
	    Vehicle(carid, vehicle_siren),
	    Vehicle(carid, vehicle_block),
	    Vehicle(carid, vehicle_block_reason),
	    tires,
		Vehicle(carid, vehicle_url)
    );
    
    sscanf(damage, "p<,>a<d>[4]",
		Vehicle(carid, vehicle_damage)
	);
	
	sscanf(tires, "p<,>a<f>[4]",
	    Vehicle(carid, vehicle_tire)
	);

    Vehicle(carid, vehicle_vehID) = CreateVehicle(Vehicle(carid, vehicle_model), Vehicle(carid, vehicle_position)[ 0 ], Vehicle(carid, vehicle_position)[ 1 ], Vehicle(carid, vehicle_position)[ 2 ], Vehicle(carid, vehicle_position)[ 3 ], Vehicle(carid, vehicle_color)[ 0 ], Vehicle(carid, vehicle_color)[ 1 ], -1);
 	OnVehicleSpawn(carid);

	Itter_Add(Server_Vehicles, Vehicle(carid, vehicle_vehID));

	format(string, sizeof string, "UPDATE `surv_vehicles` SET `spawned` = '1' WHERE `uid` = '%d'", vehicleuid);
	mysql_query(string);
	return carid;
}

FuncPub::DeleteVeh(vehicleid)
{
	#if Debug
	    printf("DeleteVeh(%d)", vehicleid);
	#endif
	new string[ 50 ];
	format(string, sizeof string,
		"DELETE FROM `surv_vehicles` WHERE `uid` = '%d'",
		Vehicle(vehicleid, vehicle_uid)
	);
	mysql_query(string);
	
  	if(Vehicle(vehicleid, vehicle_siren_obj) != INVALID_OBJECT_ID)
  	    DestroyObject(Vehicle(vehicleid, vehicle_siren_obj));
	if(Vehicle(vehicleid, vehicle_lights_timer))
  	    KillTimer(Vehicle(vehicleid, vehicle_lights_timer));
	if(Vehicle(vehicleid, vehicle_empty_timer))
	    KillTimer(Vehicle(vehicleid, vehicle_empty_timer));
	if(Vehicle(vehicleid, vehicle_attach)[ 0 ])
		DestroyObject(Vehicle(vehicleid, vehicle_attach)[ 0 ]);
	if(Vehicle(vehicleid, vehicle_attach)[ 1 ])
		DestroyObject(Vehicle(vehicleid, vehicle_attach)[ 1 ]);
	if(Vehicle(vehicleid, vehicle_attach)[ 2 ])
		DestroyObject(Vehicle(vehicleid, vehicle_attach)[ 2 ]);
	if(Vehicle(vehicleid, vehicle_attach)[ 3 ])
		DestroyObject(Vehicle(vehicleid, vehicle_attach)[ 3 ]);
	if(Vehicle(vehicleid, vehicle_attach)[ 4 ])
		DestroyObject(Vehicle(vehicleid, vehicle_attach)[ 4 ]);
	if(Vehicle(vehicleid, vehicle_attach)[ 5 ])
		DestroyObject(Vehicle(vehicleid, vehicle_attach)[ 5 ]);
	if(Vehicle(vehicleid, vehicle_attach)[ 6 ])
		DestroyObject(Vehicle(vehicleid, vehicle_attach)[ 6 ]);
	if(Vehicle(vehicleid, vehicle_attach)[ 7 ])
		DestroyObject(Vehicle(vehicleid, vehicle_attach)[ 7 ]);
	if(Vehicle(vehicleid, vehicle_attach)[ 8 ])
		DestroyObject(Vehicle(vehicleid, vehicle_attach)[ 8 ]);
	if(Vehicle(vehicleid, vehicle_opis_id) != Text3D:INVALID_3DTEXT_ID)
	    Delete3DTextLabel(Vehicle(vehicleid, vehicle_opis_id));
	    
    if(Vehicle(vehicleid, vehicle_blink)[ 2 ])
		DestroyObject(Vehicle(vehicleid, vehicle_blink)[ 5 ]),DestroyObject(Vehicle(vehicleid, vehicle_blink)[ 2 ]), DestroyObject(Vehicle(vehicleid, vehicle_blink)[ 3 ]), Vehicle(vehicleid, vehicle_blink)[ 2 ] = 0;
	if(Vehicle(vehicleid, vehicle_blink)[ 0 ])
		DestroyObject(Vehicle(vehicleid, vehicle_blink)[ 4 ]),DestroyObject(Vehicle(vehicleid, vehicle_blink)[ 0 ]), DestroyObject(Vehicle(vehicleid, vehicle_blink)[ 1 ]), Vehicle(vehicleid, vehicle_blink)[ 0 ] = 0;

    for(new c; c != MAX_ATTACH_VEHICLE; c++)
    {
        if(Vehicle(vehicleid, vehicle_attach_ex)[ c ] == INVALID_OBJECT_ID) continue;
        DestroyObject(Vehicle(vehicleid, vehicle_attach_ex)[ c ]);
    }


	DestroyVehicle(Vehicle(vehicleid, vehicle_vehID));
  	Itter_Remove(Server_Vehicles, Vehicle(vehicleid, vehicle_vehID));
  	
	for(new eVehicles:i; i < eVehicles; i++)
    	Vehicle(vehicleid, i) = 0;
    Vehicle(vehicleid, vehicle_vehID) = INVALID_VEHICLE_ID;
	return 1;
}

FuncPub::UnSpawnVeh(vehicleid)
{
	#if Debug
	    printf("UnSpawnVeh(%d)", vehicleid);
	#endif
	new string[ 65 ];
	format(string, sizeof string,
		"UPDATE `surv_vehicles` SET `spawned` = '0' WHERE `uid` = '%d'",
		Vehicle(vehicleid, vehicle_uid)
	);
	mysql_query(string);

	SaveVeh(vehicleid);
	
	DestroyVehicle(Vehicle(vehicleid, vehicle_vehID));
  	Itter_Remove(Server_Vehicles, Vehicle(vehicleid, vehicle_vehID));
  	
  	if(Vehicle(vehicleid, vehicle_siren_obj) != INVALID_OBJECT_ID)
  	    DestroyObject(Vehicle(vehicleid, vehicle_siren_obj));
	if(Vehicle(vehicleid, vehicle_lights_timer))
  	    KillTimer(Vehicle(vehicleid, vehicle_lights_timer));
	if(Vehicle(vehicleid, vehicle_empty_timer))
	    KillTimer(Vehicle(vehicleid, vehicle_empty_timer));
	if(Vehicle(vehicleid, vehicle_attach)[ 0 ])
		DestroyObject(Vehicle(vehicleid, vehicle_attach)[ 0 ]);
	if(Vehicle(vehicleid, vehicle_attach)[ 1 ])
		DestroyObject(Vehicle(vehicleid, vehicle_attach)[ 1 ]);
	if(Vehicle(vehicleid, vehicle_attach)[ 2 ])
		DestroyObject(Vehicle(vehicleid, vehicle_attach)[ 2 ]);
	if(Vehicle(vehicleid, vehicle_attach)[ 3 ])
		DestroyObject(Vehicle(vehicleid, vehicle_attach)[ 3 ]);
	if(Vehicle(vehicleid, vehicle_attach)[ 4 ])
		DestroyObject(Vehicle(vehicleid, vehicle_attach)[ 4 ]);
	if(Vehicle(vehicleid, vehicle_attach)[ 5 ])
		DestroyObject(Vehicle(vehicleid, vehicle_attach)[ 5 ]);
	if(Vehicle(vehicleid, vehicle_attach)[ 6 ])
		DestroyObject(Vehicle(vehicleid, vehicle_attach)[ 6 ]);
	if(Vehicle(vehicleid, vehicle_attach)[ 7 ])
		DestroyObject(Vehicle(vehicleid, vehicle_attach)[ 7 ]);
	if(Vehicle(vehicleid, vehicle_attach)[ 8 ])
		DestroyObject(Vehicle(vehicleid, vehicle_attach)[ 8 ]);
	if(Vehicle(vehicleid, vehicle_opis_id) != Text3D:INVALID_3DTEXT_ID)
	    Delete3DTextLabel(Vehicle(vehicleid, vehicle_opis_id));

    if(Vehicle(vehicleid, vehicle_blink)[ 2 ])
		DestroyObject(Vehicle(vehicleid, vehicle_blink)[ 5 ]),DestroyObject(Vehicle(vehicleid, vehicle_blink)[ 2 ]), DestroyObject(Vehicle(vehicleid, vehicle_blink)[ 3 ]), Vehicle(vehicleid, vehicle_blink)[ 2 ] = 0;
	if(Vehicle(vehicleid, vehicle_blink)[ 0 ])
		DestroyObject(Vehicle(vehicleid, vehicle_blink)[ 4 ]),DestroyObject(Vehicle(vehicleid, vehicle_blink)[ 0 ]), DestroyObject(Vehicle(vehicleid, vehicle_blink)[ 1 ]), Vehicle(vehicleid, vehicle_blink)[ 0 ] = 0;

    for(new c; c != MAX_ATTACH_VEHICLE; c++)
    {
        if(Vehicle(vehicleid, vehicle_attach_ex)[ c ] == INVALID_OBJECT_ID) continue;
        DestroyObject(Vehicle(vehicleid, vehicle_attach_ex)[ c ]);
    }

	foreach(Player, i)
	{
		static index;
		index = 0;
		for(; index != MAX_ICONS; index++)
		    if(Player(i, player_veh_icon)[ index ] == Vehicle(vehicleid, vehicle_uid))
		        break;

		if(!index || index == MAX_ICONS)
		    continue;

		RemovePlayerMapIcon(i, index);
	}
	for(new eVehicles:i; i < eVehicles; i++)
    	Vehicle(vehicleid, i) = 0;
    Vehicle(vehicleid, vehicle_vehID) = INVALID_VEHICLE_ID;
	return 1;
}

FuncPub::SaveVeh(vehicleid)
{
	#if Debug
	    printf("SaveVeh(%d)", vehicleid);
	#endif
	if(!Vehicle(vehicleid, vehicle_uid)) return 1;
	
	GetVehicleHealth(Vehicle(vehicleid, vehicle_vehID), Vehicle(vehicleid, vehicle_hp));
	GetVehicleDamageStatus(Vehicle(vehicleid, vehicle_vehID), Vehicle(vehicleid, vehicle_damage)[ 0 ], Vehicle(vehicleid, vehicle_damage)[ 1 ], Vehicle(vehicleid, vehicle_damage)[ 2 ], Vehicle(vehicleid, vehicle_damage)[ 3 ]);

	new string[ 512 ];
	format(string, sizeof string,
		"UPDATE `surv_vehicles` SET \
		`dmg` = '%d,%d,%d,%d', \
		`fuel` = '%f', `hp` = '%f', `distance` = '%f', `option` = '%d', \
		`tires` = '%.1f,%.1f,%.1f,%.1f' \
		WHERE `uid` = '%d'",
		Vehicle(vehicleid, vehicle_damage)[ 0 ],
		Vehicle(vehicleid, vehicle_damage)[ 1 ],
		Vehicle(vehicleid, vehicle_damage)[ 2 ],
		Vehicle(vehicleid, vehicle_damage)[ 3 ],
		Vehicle(vehicleid, vehicle_fuel),
		Vehicle(vehicleid, vehicle_hp),
		Vehicle(vehicleid, vehicle_distance),
		Vehicle(vehicleid, vehicle_option),
		Vehicle(vehicleid, vehicle_tire)[ 0 ],
		Vehicle(vehicleid, vehicle_tire)[ 1 ],
		Vehicle(vehicleid, vehicle_tire)[ 2 ],
		Vehicle(vehicleid, vehicle_tire)[ 3 ],
		Vehicle(vehicleid, vehicle_uid)
	);
	mysql_query(string);
	return 1;
}

FuncPub::CreateVeh(playerid, model, ownerType, owner, c1, c2)
{
    if(Iter_Count(Server_Vehicles) == MAX_VEHICLES)
        return 0;
	#if Debug
	    printf("CreateVeh(%d, %d, %d, %d, %d, %d)", playerid, model, ownerType, owner, c1, c2);
	#endif
    GetPlayerPos(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]);
	GetPlayerFacingAngle(playerid, Player(playerid, player_position)[ 3 ]);
	GetXYInFrontOfPlayer(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], 0.5);
	Player(playerid, player_vw) = GetPlayerVirtualWorld(playerid);
	Player(playerid, player_int) = GetPlayerInterior(playerid);

	new string[ 512 ];
	format(string, sizeof string,
	    "INSERT INTO `surv_vehicles` (`model`, `ownerType`, `owner`, `x`, `y`, `z`, `a`, `vw`, `int`, `c1`, `c2`, `fuel`, `name`) VALUES \
		('%d', '%d', '%d', '%f', '%f', '%f', '%f', '%d', '%d', '%d', '%d', '%d', '%s')",
	    model,
		ownerType,
		owner,
		Player(playerid, player_position)[ 0 ],
		Player(playerid, player_position)[ 1 ],
		Player(playerid, player_position)[ 2 ],
		Player(playerid, player_position)[ 3 ],
		Player(playerid, player_vw),
		Player(playerid, player_int),
		c1,
		c2,
		GetVehicleMaxFuel(model),
		NazwyPojazdow[ model-400 ]
	);
	mysql_query(string);
	
	new carid,
		vehuid;
	vehuid = mysql_insert_id();
    carid = CreateVehicle(model, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ], Player(playerid, player_position)[ 3 ], c1, c2, -1);
    Vehicle(carid, vehicle_vehID) 		= carid;
    Vehicle(carid, vehicle_uid) 		= vehuid;
    Vehicle(carid, vehicle_hp) 			= 1000.0;
    Vehicle(carid, vehicle_model) 		= model;
    Vehicle(carid, vehicle_position)[ 0 ] 	= Player(playerid, player_position)[ 0 ];
    Vehicle(carid, vehicle_position)[ 1 ] 	= Player(playerid, player_position)[ 1 ];
    Vehicle(carid, vehicle_position)[ 2 ] 	= Player(playerid, player_position)[ 2 ];
    Vehicle(carid, vehicle_vw) 			= Player(playerid, player_vw);
    Vehicle(carid, vehicle_int) 		= Player(playerid, player_int);
    Vehicle(carid, vehicle_owner)[ 0 ] 	= ownerType;
    Vehicle(carid, vehicle_owner)[ 1 ] 	= owner;
    Vehicle(carid, vehicle_color)[ 0 ] 	= c1;
    Vehicle(carid, vehicle_color)[ 1 ] 	= c2;
    Vehicle(carid, vehicle_pj)          = 3;
    format(Vehicle(carid, vehicle_name), 64, NazwyPojazdow[ model-400 ]);
    Vehicle(carid, vehicle_fuel) 		= GetVehicleMaxFuel(Vehicle(carid, vehicle_model));
	Vehicle(carid, vehicle_tire)[ 0 ] 	= Vehicle(carid, vehicle_tire)[ 1 ] = Vehicle(carid, vehicle_tire)[ 2 ] = Vehicle(carid, vehicle_tire)[ 3 ] = 1000;

    OnVehicleSpawn(carid);
	Itter_Add(Server_Vehicles, Vehicle(carid, vehicle_vehID));
	return carid;
}

FuncPub::ShowPlayerCars(playerid)
{
	new string[ 150 ],
		buffer[ 1024 ];
	format(string, sizeof(string), "SELECT `uid`, `model`, `spawned`, `name`  FROM `surv_vehicles` WHERE `ownerType` = "#vehicle_owner_player" AND `owner` = '%d'", Player(playerid, player_uid));
    mysql_query(string);
    mysql_store_result();
	while(mysql_fetch_row(string))
	{
		static uid,
			model,
			name[ 64 ],
			spawn;
			
		sscanf(string, "p<|>ddds[64]",
			uid,
			model,
			spawn,
			name
		);
		if(!(400 <= model <= 611)) continue;
		if(spawn)
			format(buffer, sizeof buffer, "%s"gui_active"%d\t%s\n", buffer, uid, name);
		else
			format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, uid, name);
	}
	mysql_free_result();
	if(isnull(buffer)) ShowInfo(playerid, red"Nie posiadasz żadnego pojazdu!");
	else
	{
	    GivePlayerAchiv(playerid, achiv_veh);
	    format(buffer, sizeof buffer, grey"UID:\tNazwa:\n%s", buffer);
		Dialog::Output(playerid, 37, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Twoje pojazdy", buffer, "Wybierz", "Zamknij");
	}
	return 1;
}

stock GetClosestCar(playerid, Float:Prevdist = 5.0)
{
	new Prevcar = INVALID_VEHICLE_ID;
	foreach(Server_Vehicles, carid)
	{
		new Float:Dist = GetDistanceToCar(playerid, carid);
		if(Dist < Prevdist)
		{
			Prevdist = Dist;
			Prevcar = carid;
		}
	}
	return Prevcar;
}

stock GetDistanceToCar(playerid, carid)
{
	new Float:x1,
		Float:y1,
		Float:z1,
		Float:x2,
		Float:y2,
		Float:z2,
		Float:Dis;
	if(!IsPlayerConnected(playerid)) return -1;
	GetPlayerPos(playerid, x1, y1, z1);
	GetVehiclePos(carid, x2, y2, z2);
	Dis = floatsqroot(floatpower(floatabs(floatsub(x2,x1)),2)+floatpower(floatabs(floatsub(y2,y1)),2)+floatpower(floatabs(floatsub(z2,z1)),2));
	return floatround(Dis);
}

public OnUnoccupiedVehicleUpdate(vehicleid, playerid, passenger_seat, Float:new_x, Float:new_y, Float:new_z)
{
	if(passenger_seat) return 1;
	
	new Float:distance = GetVehicleDistanceFromPoint(vehicleid, Vehicle(vehicleid, vehicle_act_position)[ 0 ], Vehicle(vehicleid, vehicle_act_position)[ 1 ], Vehicle(vehicleid, vehicle_act_position)[ 2 ]),
		Float:Vpos[ 3 ];

	GetVehicleVelocity(vehicleid, Vpos[ 0 ], Vpos[ 1 ], Vpos[ 2 ]);
	
	if(Vpos[ 0 ] && Vpos[ 1 ] && Vpos[ 2 ])
		GetVehiclePos(vehicleid, Vehicle(vehicleid, vehicle_act_position)[ 0 ], Vehicle(vehicleid, vehicle_act_position)[ 1 ], Vehicle(vehicleid, vehicle_act_position)[ 2 ]);

	if(distance >= 10.0)
	{
	    // TODO :)
		if(Vehicle(vehicleid, vehicle_owner)[ 0 ] == vehicle_owner_player)
		{
		    if(Player(playerid, player_uid) == Vehicle(vehicleid, vehicle_owner)[ 1 ])
		    {
//		        print("Gracz pcha swój samochód!");
				GetVehiclePos(vehicleid, Vehicle(vehicleid, vehicle_act_position)[ 0 ], Vehicle(vehicleid, vehicle_act_position)[ 1 ], Vehicle(vehicleid, vehicle_act_position)[ 2 ]);
				return 1;
			}
		    foreach(Player, i)
		    {
		        if(Player(i, player_uid) == Vehicle(vehicleid, vehicle_owner)[ 1 ])
			    {
//			        print("Gracz pcha samochód gracza online!");
					GetVehiclePos(vehicleid, Vehicle(vehicleid, vehicle_act_position)[ 0 ], Vehicle(vehicleid, vehicle_act_position)[ 1 ], Vehicle(vehicleid, vehicle_act_position)[ 2 ]);
					return 1;
				}
		    }
		}
		if(!Player(playerid, player_adminlvl) && playerid != INVALID_PLAYER_ID)
			UnSpawnVeh(vehicleid);
	}
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	if(!strcmp(Vehicle(vehicleid, vehicle_plate), "Brak", false) || isnull(Vehicle(vehicleid, vehicle_plate)))
		SetVehicleNumberPlate(Vehicle(vehicleid, vehicle_vehID), "_");
	else
	{
	    new plate[ 32 ];
	    format(plate, sizeof plate, IN_CITY" %s", Vehicle(vehicleid, vehicle_plate));
		SetVehicleNumberPlate(Vehicle(vehicleid, vehicle_vehID), plate);
	}

	if(Vehicle(vehicleid, vehicle_owner)[ 0 ] == vehicle_owner_job)
	{
	    Vehicle(vehicleid, vehicle_engine) = false;
		Vehicle(vehicleid, vehicle_hp) = 1000.0;
		Vehicle(vehicleid, vehicle_fuel) = GetVehicleMaxFuel(Vehicle(vehicleid, vehicle_model));
        Vehicle(vehicleid, vehicle_damage)[ 0 ] = Vehicle(vehicleid, vehicle_damage)[ 1 ] = Vehicle(vehicleid, vehicle_damage)[ 2 ] = Vehicle(vehicleid, vehicle_damage)[ 3 ] = 0;
	}
	else
	{
		Vehicle(vehicleid, vehicle_lock) = true;
	}

    SetVehicleHealth(Vehicle(vehicleid, vehicle_vehID), Vehicle(vehicleid, vehicle_hp) < 300.0 ? (300.0) : Vehicle(vehicleid, vehicle_hp));
    UpdateVehicleDamageStatus(Vehicle(vehicleid, vehicle_vehID), Vehicle(vehicleid, vehicle_damage)[ 0 ], Vehicle(vehicleid, vehicle_damage)[ 1 ], Vehicle(vehicleid, vehicle_damage)[ 2 ], Vehicle(vehicleid, vehicle_damage)[ 3 ]);
 	SetVehiclePos(Vehicle(vehicleid, vehicle_vehID), Vehicle(vehicleid, vehicle_position)[ 0 ], Vehicle(vehicleid, vehicle_position)[ 1 ], Vehicle(vehicleid, vehicle_position)[ 2 ]);
   	SetVehicleVirtualWorld(Vehicle(vehicleid, vehicle_vehID), Vehicle(vehicleid, vehicle_vw));
    LinkVehicleToInterior(Vehicle(vehicleid, vehicle_vehID), Vehicle(vehicleid, vehicle_int));
	SetVehicleParamsEx(Vehicle(vehicleid, vehicle_vehID), _:Vehicle(vehicleid, vehicle_engine), 0, 0, _:Vehicle(vehicleid, vehicle_lock), 0, 0, 0);
	ChangeVehicleColor(Vehicle(vehicleid, vehicle_vehID), Vehicle(vehicleid, vehicle_color)[ 0 ], Vehicle(vehicleid, vehicle_color)[ 1 ]);

	for(new slot; slot != 12; slot++)
	{
	    if(!Vehicle(vehicleid, vehicle_mod)[ slot ]) continue;
	    for(new sim; sim != sizeof SimilarComponents; sim++)
	    {
	        if(SimilarComponents[ sim ][ 0 ] == Vehicle(vehicleid, vehicle_mod)[ slot ])
	        	AddVehicleComponent(Vehicle(vehicleid, vehicle_vehID), SimilarComponents[ sim ][ 1 ]);
	    }
	    AddVehicleComponent(Vehicle(vehicleid, vehicle_vehID), Vehicle(vehicleid, vehicle_mod)[ slot ]);
	}
    for(new c; c != MAX_ATTACH_VEHICLE; c++)
    {
        if(Vehicle(vehicleid, vehicle_attach_ex)[ c ] == INVALID_OBJECT_ID) continue;
        DestroyObject(Vehicle(vehicleid, vehicle_attach_ex)[ c ]);
        Vehicle(vehicleid, vehicle_attach_ex)[ c ] = INVALID_OBJECT_ID;
    }

	if(Vehicle(vehicleid, vehicle_pj) != 3)
	    ChangeVehiclePaintjob(Vehicle(vehicleid, vehicle_vehID), Vehicle(vehicleid, vehicle_pj));

	GetVehiclePos(Vehicle(vehicleid, vehicle_vehID), Vehicle(vehicleid, vehicle_act_position)[ 0 ], Vehicle(vehicleid, vehicle_act_position)[ 1 ], Vehicle(vehicleid, vehicle_act_position)[ 2 ]);

	if(Vehicle(vehicleid, vehicle_model) == 578 && Vehicle(vehicleid, vehicle_option) & option_plot)
	{
	    Vehicle(vehicleid, vehicle_attach)[ 0 ] = CreateObject(983, 0, 0, 0, 0, 0, 0);
		Vehicle(vehicleid, vehicle_attach)[ 1 ] = CreateObject(983, 0, 0, 0, 0, 0, 0);
		Vehicle(vehicleid, vehicle_attach)[ 2 ] = CreateObject(983, 0, 0, 0, 0, 0, 0);
		Vehicle(vehicleid, vehicle_attach)[ 3 ] = CreateObject(983, 0, 0, 0, 0, 0, 0);
		Vehicle(vehicleid, vehicle_attach)[ 4 ] = CreateObject(11474, 0, 0, 0, 0, 0, 0);
		AttachObjectToVehicle(Vehicle(vehicleid, vehicle_attach)[ 0 ], Vehicle(vehicleid, vehicle_vehID), 1.4550000429153, -0.85600000619888, 0.41100001335144, 0, 0, 0);
		AttachObjectToVehicle(Vehicle(vehicleid, vehicle_attach)[ 1 ], Vehicle(vehicleid, vehicle_vehID), 1.4490000009537, -2.4389998912811, 0.41100001335144, 0, 0, 0);
		AttachObjectToVehicle(Vehicle(vehicleid, vehicle_attach)[ 2 ], Vehicle(vehicleid, vehicle_vehID), -1.460000038147, -0.86400002241135, 0.41100001335144, 0, 0, 0);
		AttachObjectToVehicle(Vehicle(vehicleid, vehicle_attach)[ 3 ], Vehicle(vehicleid, vehicle_vehID), -1.4609999656677, -2.4519999027252, 0.41100001335144, 0, 0, 0);
		AttachObjectToVehicle(Vehicle(vehicleid, vehicle_attach)[ 4 ], Vehicle(vehicleid, vehicle_vehID), -0.068000003695488, -5.7540001869202, 0.38100001215935, 0, 2.5, 5.5);
   	    if(!(Vehicle(vehicleid, vehicle_option) & option_plot_open))
   	    {
			DestroyObject(Vehicle(vehicleid, vehicle_attach)[ 4 ]);
			Vehicle(vehicleid, vehicle_attach)[ 5 ] = CreateObject(11474, 0, 0, 0, 0, 0, 0);
			Vehicle(vehicleid, vehicle_attach)[ 6 ] = CreateObject(11474, 0, 0, 0, 0, 0, 0);
			AttachObjectToVehicle(Vehicle(vehicleid, vehicle_attach)[ 5 ], Vehicle(vehicleid, vehicle_vehID), -0.025000000372529, -6.1770000457764, -0.80699998140335, 58.193572998047, 194.33984375, 166.49182128906);
			AttachObjectToVehicle(Vehicle(vehicleid, vehicle_attach)[ 6 ], Vehicle(vehicleid, vehicle_vehID), 0.037999998778105, -7.3889999389648, -1.5329999923706, 58.189086914063, 194.33715820313, 166.48681640625);
   	        Vehicle(vehicleid, vehicle_option) += option_plot_open;
   	    }
   	    else
   	    {
		    DestroyObject(Vehicle(vehicleid, vehicle_attach)[ 5 ]);
		    DestroyObject(Vehicle(vehicleid, vehicle_attach)[ 6 ]);
		    Vehicle(vehicleid, vehicle_attach)[ 4 ] = CreateObject(11474, -0.068000003695488, -5.7540001869202, 0.38100001215935, 0, 2.5, 5.5); // elevator
		    AttachObjectToVehicle(Vehicle(vehicleid, vehicle_attach)[ 5 ], Vehicle(vehicleid, vehicle_vehID), -0.068000003695488, -5.7540001869202, 0.38100001215935, 0, 2.5, 5.5);
   	        Vehicle(vehicleid, vehicle_option) -= option_plot_open;
   	    }
	}
	Vehicle(vehicleid, vehicle_siren_obj) = INVALID_OBJECT_ID;
	InstallNeon(vehicleid);
	InstallSiren(vehicleid);
	InstallAttach(vehicleid);
	InstallOpis(vehicleid);
	return 1;
}

FuncPub::InstallOpis(vehicleid)
{
	if(Vehicle(vehicleid, vehicle_opis))
	{
		new buffer[ 128 ],
			string[ 128 ];
		format(buffer, sizeof buffer,
			"SELECT `opis` FROM `surv_opis` WHERE `uid` = '%d'",
		    Vehicle(vehicleid, vehicle_opis)
		);
		mysql_query(buffer);
		mysql_store_result();
		mysql_fetch_row(string);
		mysql_free_result();
		
		if(Vehicle(vehicleid, vehicle_opis_id) == Text3D:INVALID_3DTEXT_ID && !isnull(string))
		{
			wordwrap(string);
			Vehicle(vehicleid, vehicle_opis_id) = Create3DTextLabel(string, opis_color, 0.0, 0.0, 0.0, 5.0, 0, 1);
			Attach3DTextLabelToVehicle(Vehicle(vehicleid, vehicle_opis_id), vehicleid, 0.0, 0.0, -0.6);
		}
	}
	else Vehicle(vehicleid, vehicle_opis_id) = Text3D:INVALID_3DTEXT_ID;
	return 1;
}

FuncPub::InstallSiren(vehicleid)
{
	if(Vehicle(vehicleid, vehicle_option) & option_siren)
	{
		if(!Vehicle(vehicleid, vehicle_lights_timer))
			Vehicle(vehicleid, vehicle_lights_timer) = SetTimerEx("BlinkLights", 250, true, "d", vehicleid);
	}
	else
	{
		if(Vehicle(vehicleid, vehicle_lights_timer))
	    	KillTimer(Vehicle(vehicleid, vehicle_lights_timer));
	    Vehicle(vehicleid, vehicle_lights_timer) = 0;
	}
	if(!Vehicle(vehicleid, vehicle_siren)) return 1;
	if(Vehicle(vehicleid, vehicle_siren_obj) == INVALID_OBJECT_ID)
	{
		new Float:pos[ 3 ],
			Float:temp;
		GetVehicleModelInfo(Vehicle(vehicleid, vehicle_model), VEHICLE_MODEL_INFO_FRONTSEAT, pos[ 0 ], pos[ 1 ], temp);
		GetVehicleModelInfo(Vehicle(vehicleid, vehicle_model), VEHICLE_MODEL_INFO_SIZE, temp, temp, pos[ 2 ]);
	    switch(Vehicle(vehicleid, vehicle_siren))
	    {
	        case 18646:
	        {
				Vehicle(vehicleid, vehicle_siren_obj) = CreateObject(Vehicle(vehicleid, vehicle_siren), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 100.0);
				pos[ 0 ] = -pos[ 0 ];

				AttachObjectToVehicle(Vehicle(vehicleid, vehicle_siren_obj), Vehicle(vehicleid, vehicle_vehID), pos[ 0 ], pos[ 1 ], floatadd(floatdiv(pos[ 2 ], 2.0), 0.05), 0.0, 0.0, 0.0);
			}
			default:
			{
				Vehicle(vehicleid, vehicle_siren_obj) = CreateObject(18646, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 100.0);
				pos[ 0 ] = -pos[ 0 ];

				AttachObjectToVehicle(Vehicle(vehicleid, vehicle_siren_obj), Vehicle(vehicleid, vehicle_vehID), pos[ 0 ], pos[ 1 ], floatadd(floatdiv(pos[ 2 ], 2.0), 0.05), 0.0, 0.0, 0.0);
			}
		}
	}
	else
	{
	    DestroyObject(Vehicle(vehicleid, vehicle_siren_obj));
		Vehicle(vehicleid, vehicle_siren_obj) = INVALID_OBJECT_ID;
	}
	return 1;
}

FuncPub::BlinkLights(vehicleid)
{
    if(!(Vehicle(vehicleid, vehicle_option) & option_siren)) return 1;
    new t[ 2 ];
	GetVehicleParamsEx(Vehicle(vehicleid, vehicle_vehID), t[ 0 ], t[ 1 ], t[ 0 ], t[ 0 ], t[ 0 ], t[ 0 ], t[ 0 ]);
    if(!t[ 1 ]) return 1;
    if(Vehicle(vehicleid, vehicle_light) == 1) return 1;

	static bool:temp;
	if(temp) // Lewa strona
	{
	    if(getLight(vehicleid, LEFT_LIGHT) == FULL)
	    {
	        setLight(vehicleid, LEFT_LIGHT, DAMAGED);
	        setLight(vehicleid, RIGHT_LIGHT, FULL);
		}
	}
	else // Prawa strona
	{
	    if(getLight(vehicleid, RIGHT_LIGHT) == FULL)
	    {
	        setLight(vehicleid, RIGHT_LIGHT, DAMAGED);
	        setLight(vehicleid, LEFT_LIGHT, FULL);
		}
	}
	temp = !temp;
	return 1;
}

FuncPub::InstallNeon(vehicleid)
{
	if(!Vehicle(vehicleid, vehicle_neon)) return 1;
	if(Vehicle(vehicleid, vehicle_option) & option_neon)
	{
	    new Float:pos[ 3 ];
	    GetVehicleModelInfo(Vehicle(vehicleid, vehicle_model), VEHICLE_MODEL_INFO_SIZE, pos[ 0 ], pos[ 1 ], pos[ 2 ]);
		if(IsCar(Vehicle(vehicleid, vehicle_vehID)))// is a car
		{
	    	Vehicle(vehicleid, vehicle_attach)[ 7 ] = CreateObject(Vehicle(vehicleid, vehicle_neon), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 100.0);
	    	Vehicle(vehicleid, vehicle_attach)[ 8 ] = CreateObject(Vehicle(vehicleid, vehicle_neon), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 100.0);

			AttachObjectToVehicle(Vehicle(vehicleid, vehicle_attach)[ 7 ], Vehicle(vehicleid, vehicle_vehID), floatdiv(pos[ 0 ], 2.4), 0, floatdiv(pos[ 2 ], -3.5), 0.0, 0.0, 0.0);
			AttachObjectToVehicle(Vehicle(vehicleid, vehicle_attach)[ 8 ], Vehicle(vehicleid, vehicle_vehID), floatdiv(pos[ 0 ], -2.4), 0, floatdiv(pos[ 2 ], -3.5), 0.0, 0.0, 0.0);
		}
		else if(IsABike(Vehicle(vehicleid, vehicle_vehID)) || IsARower(Vehicle(vehicleid, vehicle_vehID)))
		{
	    	Vehicle(vehicleid, vehicle_attach)[ 7 ] = CreateObject(Vehicle(vehicleid, vehicle_neon), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 100.0);
			AttachObjectToVehicle(Vehicle(vehicleid, vehicle_attach)[ 7 ], Vehicle(vehicleid, vehicle_vehID), floatdiv(pos[ 0 ], 2.4), 0, floatdiv(pos[ 2 ], -3.5), 0.0, 0.0, 0.0);
		}
	}
	else
	{
		if(Vehicle(vehicleid, vehicle_attach)[ 7 ])
			DestroyObject(Vehicle(vehicleid, vehicle_attach)[ 7 ]);
		if(Vehicle(vehicleid, vehicle_attach)[ 8 ])
			DestroyObject(Vehicle(vehicleid, vehicle_attach)[ 8 ]);
	}
	return 1;
}

FuncPub::InstallAttach(vehid)
{
	new idx;
    for(new c; c != MAX_ATTACH_VEHICLE; c++)
    {
        if(Vehicle(vehid, vehicle_attach_ex)[ c ] == INVALID_OBJECT_ID) continue;
        DestroyObject(Vehicle(vehid, vehicle_attach_ex)[ c ]);
        Vehicle(vehid, vehicle_attach_ex)[ c ] = INVALID_OBJECT_ID;
    }
    if(!Vehicle(vehid, vehicle_attached)) return 1;
    new query[ 126 ];
    format(query, sizeof query,
        "SELECT * FROM `surv_v_attach_id` WHERE `type` = '%d'",
        Vehicle(vehid, vehicle_attached)
	);
    mysql_query(query);
	mysql_store_result();
    while(mysql_fetch_row(query))
    {
    	if(MAX_ATTACH_VEHICLE == idx) break;
    	static model, Float:pos[ 6 ], color, tsize, size, text[ 12 ], align, modelid, txdname[ 32 ], texturename[ 32 ];

    	//4|1|19280|-0.594727|2.67676|-0.4871|341.499|0.0|12.7496|0xAAFFFFFF|0|28|0||18646|matcolours|red
    	sscanf(query, "p<|>{dd}da<f>[6]xddds[12]ds[32]s[32]",
    	    model,
			pos,
			color,
			size,
			tsize,
			align,
			text,
			modelid,
			txdname,
			texturename
		);
    	Vehicle(vehid, vehicle_attach_ex)[ idx ] = CreateObject(model, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 300.0);
    	AttachObjectToVehicle(Vehicle(vehid, vehicle_attach_ex)[ idx ], vehid, pos[ 0 ], pos[ 1 ], pos[ 2 ], pos[ 3 ], pos[ 4 ], pos[ 5 ]);
		if(!(DIN(text, "NULL")))
		{
		    SetObjectMaterialText(Vehicle(vehid, vehicle_attach_ex)[ idx ], text, 0, size, "Arial", tsize, 0, color, 0, align);
		}
		if(!(DIN(txdname, "NULL")) || !(DIN(texturename, "NULL")) || modelid)
		{
		    SetObjectMaterial(Vehicle(vehid, vehicle_attach_ex)[ idx ], 1, modelid, txdname, texturename);
		}
    	idx++;
	}
	mysql_free_result();
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	#if Debug
	    printf("OnPlayerEnterVehicle(%d, %d, %d)", playerid, vehicleid, ispassenger);
	#endif
	
	new index;
	for(; index != MAX_ICONS; index++)
	    if(Player(playerid, player_veh_icon)[ index ] == Vehicle(vehicleid, vehicle_uid))
	        break;

	if(index && index != MAX_ICONS)
	{
		RemovePlayerMapIcon(playerid, index);
    	Player(playerid, player_veh_icon)[ index ] = 0;
	}
	
	GetPlayerPos(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]);
	GetPlayerFacingAngle(playerid, Player(playerid, player_position)[ 3 ]);

	if(Player(playerid, player_block) & block_noveh && !ispassenger)
	{
		SetPlayerPosEx(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]+0.1);
	    ShowInfo(playerid, TEXT_NOVEH);
	    return 1;
	}
	else if(Player(playerid, player_timehere) < 7200 && !ispassenger && !Player(playerid, player_adminlvl) && Vehicle(vehicleid, vehicle_owner)[ 0 ] != vehicle_owner_job)
	{
		SetPlayerPosEx(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]+0.1);
	    ShowInfo(playerid, red"Aby używać pojazdu musisz mieć przegrane minimum 2 godziny na serwerze");
	    return 1;
	}
	else if(Player(playerid, player_rolki) && !ispassenger)
	{
		SetPlayerPosEx(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]+0.1);
		ShowInfo(playerid, red"Nie możesz kierować w rolkach!");
		return 1;
	}
	else if(Vehicle(vehicleid, vehicle_hp) <= 301 && !ispassenger && !Player(playerid, player_adminlvl))
	{
		SetPlayerPosEx(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]+0.1);
	    SetVehicleHealth(vehicleid, Vehicle(vehicleid, vehicle_hp) = 300);
		return 1;
	}
	else if(Vehicle(vehicleid, vehicle_owner)[ 0 ] == vehicle_owner_group && !IsPlayerInUidGroup(playerid, Vehicle(vehicleid, vehicle_owner)[ 1 ]) && !ispassenger && !Player(playerid, player_adminlvl))
	{
		SetPlayerPosEx(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]+0.1);
		ShowInfo(playerid, red"Nie możesz prowadzić tego pojazdu.");
		return 1;
	}
	else if(Vehicle(vehicleid, vehicle_lock) && !Player(playerid, player_adminlvl))
	{
		SetPlayerPosEx(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]+0.1);
		return 1;
	}
	else if(Vehicle(vehicleid, vehicle_owner)[ 0 ] == vehicle_owner_job && Vehicle(vehicleid, vehicle_owner)[ 1 ] != Player(playerid, player_job) && !ispassenger && !Player(playerid, player_adminlvl))
	{
		SetPlayerPosEx(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]+0.1);
		ShowInfo(playerid, red"Nie jesteś zatrudniony w tej firmie.");
		return 1;
	}
	else if(Vehicle(vehicleid, vehicle_block) && !Player(playerid, player_adminlvl) && !ispassenger)
	{
		SetPlayerPosEx(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]+0.1);
		new string[ 126 ];
		format(string, sizeof string,
			red"Na koło jest nałożona blokada na kwotę "green"$"white"%.2f\n\n"red"Powód: "white"%s",
			Vehicle(vehicleid, vehicle_block),
			Vehicle(vehicleid, vehicle_block_reason)
		);
		ShowInfo(playerid, string);
		return 1;
	}
	SetVehicleHealth(vehicleid, Vehicle(vehicleid, vehicle_hp));
	Player(playerid, player_veh) = vehicleid;
	SetTimerEx("CheckDriver", 5000, false, "dd", playerid, vehicleid);
	return 1;
}

FuncPub::CheckDriver(playerid, vehicleid)
{
    if(Player(playerid, player_veh) == vehicleid && GetPlayerVehicleID(playerid) == vehicleid) return 1;
	//if(GetPlayerVehicleID(playerid) > 0 && Player(playerid, player_veh) != INVALID_VEHICLE_ID)
 	Player(playerid, player_veh) = INVALID_VEHICLE_ID;
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	#if Debug
	    printf("OnPlayerExitVehicle(%d, %d)", playerid, vehicleid);
	#endif
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(IsPlayerNPC(playerid)) return 1;
	#if Debug
	    printf("OnPlayerStateChange(%d, %d, %d)", playerid, newstate, oldstate);
	#endif

    new vehid = Player(playerid, player_veh);
	if((newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER) && oldstate == PLAYER_STATE_ONFOOT)
	{
/*	    if(Vehicle(GetPlayerVehicleID(playerid), vehicle_owner)[ 0 ] == vehicle_owner_npc)
	    {
	        vehid = GetPlayerVehicleID(playerid);
	    }*/
	    // Gracz wsiadł do pojazdu
	    if(vehid == INVALID_VEHICLE_ID && GetPlayerVehicleID(playerid) != 0 && !Player(playerid, player_disabled))
	    {
		    new reason[ 80 ], string[ 200 ];
	        format(reason, sizeof reason,
				"Teleport do pojazdu (Nazwa: %s, UID: %d)",
				Vehicle(GetPlayerVehicleID(playerid), vehicle_name),
				Vehicle(GetPlayerVehicleID(playerid), vehicle_uid)
			);
			format(string, sizeof string,
				"~>~ Kick ~<~ ~r~%s ~w~zostal wyrzucony przez ~r~System~w~. ~w~Powod: ~r~%s",
				NickName(playerid),
				reason
			);
			ShowKara(playerid, string);
			Logs(-1, playerid, reason, kara_kick, -1);
		    Kick(playerid);
			return 1;
	    }
		if(Vehicle(vehid, vehicle_lock) && !CanPlayerVehicleDrive(playerid, vehid) && !Player(playerid, player_disabled))
		{
		    new reason[ 80 ], string[ 200 ];
	        format(reason, sizeof reason,
				"Wejscie do zamknietego pojazdu (Nazwa: %s, UID: %d)",
				Vehicle(vehid, vehicle_name),
				Vehicle(vehid, vehicle_uid)
			);
			format(string, sizeof string,
				"~>~ Kick ~<~ ~r~%s ~w~zostal wyrzucony przez ~r~System~w~. ~w~Powod: ~r~%s",
				NickName(playerid),
				reason
			);
			ShowKara(playerid, string);
			Logs(-1, playerid, reason, kara_kick, -1);
		    Kick(playerid);
		    return 1;
		}
		if(newstate == PLAYER_STATE_DRIVER)
		{
			if(IsARower(vehid))
				Vehicle(vehid, vehicle_engine) = true;

		    new s[ 7 ];
	     	GetVehicleParamsEx(Vehicle(vehid, vehicle_vehID), s[ 0 ], s[ 1 ], s[ 2 ], s[ 3 ], s[ 4 ], s[ 5 ], s[ 6 ]);
	      	SetVehicleParamsEx(Vehicle(vehid, vehicle_vehID), _:Vehicle(vehid, vehicle_engine), s[ 1 ], s[ 2 ], _:Vehicle(vehid, vehicle_lock), s[ 4 ], s[ 5 ], s[ 6 ]);

	        if(!Vehicle(vehid, vehicle_engine) && Vehicle(vehid, vehicle_owner)[ 0 ] != vehicle_owner_npc)
				TextDrawShowForPlayer(playerid, Setting(setting_silnik));
			else if(!IsARower(vehid))
			    PlayerTextDrawShow(playerid, Player(playerid, player_veh_td));
			    
			Player(playerid, player_veh_hp) = Vehicle(vehid, vehicle_hp);
			    
			if(Vehicle(vehid, vehicle_owner)[ 0 ] == vehicle_owner_job && !Player(playerid, player_race))
			{
				new r = RandomRace(check_type_job, Player(playerid, player_job));
				if(r > 0)
				{
					LoadPlayerRace(playerid, r);
					ShowCMD(playerid, "Udaj się do pierwszego markera!");
					
					SetPlayerRaceCheckpoint(playerid, 0,
						Race(playerid, Player(playerid, player_race), race_pos)[ 0 ],
						Race(playerid, Player(playerid, player_race), race_pos)[ 1 ],
						Race(playerid, Player(playerid, player_race), race_pos)[ 2 ],
						Race(playerid, Player(playerid, player_race)+1, race_pos)[ 0 ],
						Race(playerid, Player(playerid, player_race)+1, race_pos)[ 1 ],
						Race(playerid, Player(playerid, player_race)+1, race_pos)[ 2 ],
					10);
				}
				//else ShowCMD(playerid, "Brak przemieszczania się pomiędzy markerami!");
			}
		}

		new string[ 126 ];
		format(string, sizeof string,
			"INSERT INTO `surv_odciski` VALUES (NULL, '%d', UNIX_TIMESTAMP(), '"#odcisk_type_vehicle"', '%d', '%d')",
			Player(playerid, player_uid),
			Vehicle(vehid, vehicle_uid),
			_:Player(playerid, player_rekawiczki)
		);
		mysql_query(string);
		
		KillTimer(Vehicle(vehid, vehicle_empty_timer));
		Vehicle(vehid, vehicle_empty_timer) = 0;
		
		Audio_SetRadioStation(playerid, 0);
		Audio_StopRadio(playerid);
	    if(Vehicle(vehid, vehicle_option) & option_audio && Vehicle(vehid, vehicle_sound))
	    {
	        if(Audio_IsClientConnected(playerid))
	        	Player(playerid, player_veh_sound) = Audio_PlayStreamed(playerid, Vehicle(vehid, vehicle_url));
			else
			    PlayAudioStreamForPlayer(playerid, Vehicle(vehid, vehicle_url));
	    }
	}
	else if(newstate == PLAYER_STATE_ONFOOT && (oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER))
	{
		// Gracz wysiadł z pojazdu
		if(Player(playerid, player_pasy))
		{
	 		FreezePlayer(playerid);
	   		SetTimerEx("UnFreezePlayer", 5000, 0, "d", playerid);
			ShowInfo(playerid, red"Miałeś zapięte pasy, zostałeś zamrożony na 5 sec.");
		   	Player(playerid, player_pasy) = false;
		}
		if(oldstate == PLAYER_STATE_DRIVER)
		{
		    PlayerTextDrawHide(playerid, Player(playerid, player_veh_td));
		    TextDrawHideForPlayer(playerid, Setting(setting_silnik));

		    new s[ 7 ];
	     	GetVehicleParamsEx(vehid, s[ 0 ], s[ 1 ], s[ 2 ], s[ 3 ], s[ 4 ], s[ 5 ], s[ 6 ]);
	      	SetVehicleParamsEx(vehid, _:Vehicle(vehid, vehicle_engine), s[ 1 ], s[ 2 ], _:Vehicle(vehid, vehicle_lock), s[ 4 ], s[ 5 ], s[ 6 ]);

			/*if(Vehicle(vehid, vehicle_lock))
			{
		 		FreezePlayer(playerid);
		   		SetTimerEx("UnFreezePlayer", 5000, 0, "d", playerid);
				ShowInfo(playerid, red"Samochód był zamknięty, zostałeś zamrożony na 5 sec.");
		  	}*/
		  	if(!Vehicle(vehid, vehicle_empty_timer))
		  	{
			  	if(Vehicle(vehid, vehicle_owner)[ 0 ] == vehicle_owner_job)
			  	{
			  	    if(Vehicle(vehid, vehicle_owner)[ 1 ] == job_smieciarz)
				  		Vehicle(vehid, vehicle_empty_timer) = SetTimerEx("RespawnVeh", 5*60*1000, false, "dd", vehid, playerid);
			  	    else
				  		Vehicle(vehid, vehicle_empty_timer) = SetTimerEx("RespawnVeh", 15000, false, "dd", vehid, playerid);
				}
				else
				    Vehicle(vehid, vehicle_empty_timer) = SetTimerEx("EngineOff", 5*60*1000, false, "d", vehid);
			}
			
			new Float:v = Vehicle(vehid, vehicle_hp) - Player(playerid, player_veh_hp);
			if(v != 0)
			{
				new string[ 126 ];
				format(string, sizeof string,
				    "INSERT INTO `surv_vehicles_log` VALUES (NULL, '%d', '%d', '%f', UNIX_TIMESTAMP())",
				    Player(playerid, player_uid),
				    Vehicle(vehid, vehicle_uid),
				    v
				);
				mysql_query(string);
			}
			
		  	SaveVeh(vehid);

	        foreach(Player, id)
	        {
	        	if(!Audio_IsClientConnected(id)) continue;
	            Audio_Stop(id, Player(playerid, player_engine_sound)[ id ]);
	            Player(playerid, player_engine_sound)[ id ] = 0;
	        }
	  		KillTimer(Player(playerid, player_veh_timer));
			Player(playerid, player_veh_timer) = 0;
			Player(playerid, player_veh_hp) = 0;
		}

		if(Taxi(playerid, taxi_player) != INVALID_PLAYER_ID)
		{
		    if(Taxi(playerid, taxi_dist))
		    {
			    new Float:cash = floatmul(Taxi(playerid, taxi_price), Taxi(playerid, taxi_dist));
			    if(cash > Player(playerid, player_cash))
			        cash = Player(playerid, player_cash);

			    new driver = Taxi(playerid, taxi_player);
			    GivePlayerMoneyEx(playerid, 0 - cash, true);

				if(IsPlayerConnected(driver))
				{
				    GivePlayerMoneyEx(driver, cash/2, true);
					ShowCMD(driver, "Przejazd zakończony! Pasażer wysiadł.");
				}

			    new string[ 126 ];
			    format(string, sizeof string,
			        "UPDATE `surv_groups` SET `cash` = `cash` + '%.2f' WHERE `uid` = '%d'",
			        IsPlayerConnected(driver) ? cash/2 : cash,
			    	Taxi(playerid, taxi_group)
				);
				mysql_query(string);

				format(string, sizeof string,
					"INSERT INTO `surv_groups_log` VALUES (NULL, '%d', '%d', '%d', UNIX_TIMESTAMP(), '%.2f', 'Kurs %.2fkm za $%.2f')",
					Taxi(playerid, taxi_group),
					Player(driver, player_uid),
					Player(playerid, player_uid),
					IsPlayerConnected(driver) ? cash/2 : cash,
					Taxi(playerid, taxi_dist),
					Taxi(playerid, taxi_price)
				);
				mysql_query(string);
			}
			ShowCMD(playerid, "Przejazd zakończony!");
			Taxi(playerid, taxi_player) = INVALID_PLAYER_ID;
			Taxi(playerid, taxi_dist) = 0.0;
			Taxi(playerid, taxi_price) = 0.0;
			Taxi(playerid, taxi_group) = 0;
		}
		
	    Player(playerid, player_veh) = INVALID_VEHICLE_ID;
	    
    	if(Audio_IsClientConnected(playerid))
		{
			Audio_Stop(playerid, Player(playerid, player_veh_sound));
			Player(playerid, player_veh_sound) = 0;
		}
		else StopAudioStreamForPlayer(playerid);
	}

	if(newstate == PLAYER_STATE_WASTED && Player(playerid, player_logged) && Player(playerid, player_spawned))
	{
	    if(oldstate == PLAYER_STATE_DRIVER)
	    {
		    PlayerTextDrawHide(playerid, Player(playerid, player_veh_td));
		    TextDrawHideForPlayer(playerid, Setting(setting_silnik));
	    }
	    if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)
	    {
	        Player(playerid, player_pasy) = false;
	        //print("Smierć w pojeździe!");
	    }
		GetPlayerPos(playerid, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], Player(playerid, player_position)[ 2 ]);
		GetPlayerFacingAngle(playerid, Player(playerid, player_position)[ 3 ]);
		Player(playerid, player_vw) = GetPlayerVirtualWorld(playerid);
		Player(playerid, player_int) = GetPlayerInterior(playerid);
		
	    new duty = Player(playerid, player_duty);
	    new Float:posZ, string[ 256 ];
	    posZ = Player(playerid, player_position)[ 2 ];
		#if mapandreas
	        if(Player(playerid, player_door))
			    posZ -= player_down;
			else
				MapAndreas_FindZ_For2DCoord(Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], posZ);
		#else
		    posZ -= player_down;
		#endif

		if(Weapon(playerid, 0, weapon_model) == Weapon(playerid, 1, weapon_model) && Weapon(playerid, 1, weapon_uid) && Weapon(playerid, 0, weapon_uid))
		{
		    new ammo = GetWeaponAmmo(playerid, Weapon(playerid, 0, weapon_model));

			new tammo = ammo;
			ammo = ammo/2 + ammo % 2;

	        if(duty && Group(playerid, duty, group_type) == group_type_pd)
	        {
				format(string, sizeof string,
					"UPDATE `surv_items` SET `used` = 0, `v2` = '%d', `ownerType`='"#item_place_none"', `owner`='0' WHERE `uid` = '%d'",
					tammo-ammo,
					Player(playerid, player_vw),
					Weapon(playerid, 1, weapon_uid)
				);
				mysql_query(string);
				ClearWeapon(playerid, 1);
				if(IsPlayerAttachedObjectSlotUsed(playerid, 1))
					RemovePlayerAttachedObject(playerid, 1);

		        format(string, sizeof string,
					"UPDATE `surv_items` SET `used` = 0, `v2` = '%d', `ownerType`='"#item_place_none"', `owner`='0' WHERE `uid` = '%d'",
					tammo-ammo,
					Weapon(playerid, 0, weapon_uid)
				);
				mysql_query(string);
	        }
	        else
	        {
				format(string, sizeof string,
					"UPDATE `surv_items` SET `used` = 0, `v2` = '%d', `X`='%f', `Y`='%f', `Z`='%f', `vw`='%d', `ownerType`='"#item_place_none"', `owner`='0' WHERE `uid` = '%d'",
					tammo-ammo,
					Player(playerid, player_position)[ 0 ],
					Player(playerid, player_position)[ 1 ],
					posZ,
					Player(playerid, player_vw),
					Weapon(playerid, 1, weapon_uid)
				);
				mysql_query(string);
				ClearWeapon(playerid, 1);
				if(IsPlayerAttachedObjectSlotUsed(playerid, 1))
					RemovePlayerAttachedObject(playerid, 1);

		        format(string, sizeof string,
					"UPDATE `surv_items` SET `used` = 0, `v2` = '%d', `X`='%f', `Y`='%f', `Z`='%f', `vw`='%d', `ownerType`='"#item_place_none"', `owner`='0' WHERE `uid` = '%d'",
					tammo-ammo,
					Player(playerid, player_position)[ 0 ],
					Player(playerid, player_position)[ 1 ],
					posZ,
					Player(playerid, player_vw),
					Weapon(playerid, 0, weapon_uid)
				);
				mysql_query(string);
				
				#if STREAMER
				    new Float:r[ 3 ],
						model;
					model = ObjectItem(item_weapon, Weapon(playerid, 0, weapon_model));
					r[ 0 ] = 85.0;
					r[ 1 ] = -809.0;
					r[ 2 ] = random(360);
				    format(string, sizeof string,
						"INSERT INTO `surv_objects` (`model`, `x`, `y`, `z`, `rx`, `ry`, `rz`, `ownerType`, `owner`) VALUES ('%d', '%f', '%f', '%f', '%f', '%f', '%f', '"#object_owner_item"', '%d')",
						model,
						Player(playerid, player_position)[ 0 ],
						Player(playerid, player_position)[ 1 ],
						posZ,
						r[ 0 ], r[ 1 ], r[ 2 ],
						Weapon(playerid, 1, weapon_uid)
					);
					mysql_query(string);
					new objectuid = mysql_insert_id();
					new objectid = CreateDynamicObject(model, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], posZ, r[ 0 ], r[ 1 ], r[ 2 ], Door(Player(playerid, player_door), door_in_vw), -1, -1, 1000.0);
					Streamer_SetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_EXTRA_ID, objectuid);
					Streamer_Update(playerid);

					new c;
					for(; c < MAX_OBJECTS; c++)
					    if(Object(c, obj_objID) == objectid)
					        break;
					if(c == MAX_OBJECTS)
					{
					    for(c = 0; c < MAX_OBJECTS; c++)
					    	if(Object(c, obj_objID) == INVALID_OBJECT_ID)
					    	    break;
					}
		            if(c != MAX_OBJECTS)
		            {
						Object(c, obj_objID) = objectid;
						Object(c, obj_position)[ 0 ] = Player(playerid, player_position)[ 0 ];
						Object(c, obj_position)[ 1 ] = Player(playerid, player_position)[ 1 ];
						Object(c, obj_position)[ 2 ] = posZ;
						Object(c, obj_positionrot)[ 0 ] = r[ 0 ];
						Object(c, obj_positionrot)[ 1 ] = r[ 1 ];
						Object(c, obj_positionrot)[ 2 ] = r[ 2 ];
						Object(c, obj_owner)[ 0 ] = object_owner_item;
						Object(c, obj_owner)[ 1 ] = Weapon(playerid, 1, weapon_uid);
					}
				#else
					foreach(Player, i)
					{
					    if(Player(i, player_vw) != Player(playerid, player_vw)) continue;
		                for(new c; c != 2; c++)
		                {
							new objectid = 1;
							for(; objectid != MAX_OBJECTS; objectid++)
			        			if(!IsValidPlayerObject(playerid, Object(playerid, objectid, obj_objID)) && !IsValidObject(objectid) && Object(playerid, objectid, obj_objID) == INVALID_OBJECT_ID)
							        break;
							if(objectid == MAX_OBJECTS) continue;

					        Object(i, objectid, obj_objID) = ObjectItem(i, item_weapon, Weapon(playerid, 0, weapon_model), 0, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], posZ);
						    Object(i, objectid, obj_owner)[ 0 ] 	= object_owner_item;
						    Object(i, objectid, obj_owner)[ 1 ] 	= Weapon(playerid, 1, weapon_uid);
					    }
					}
				#endif
			}
			ClearWeapon(playerid, 0);
			if(IsPlayerAttachedObjectSlotUsed(playerid, 0))
				RemovePlayerAttachedObject(playerid, 0);
		}
		else
		{
		    for(new x; x != MAX_WEAPON; x++)
		    {
		        if(!Weapon(playerid, x, weapon_uid)) continue;
		        if(!Weapon(playerid, x, weapon_model)) continue;
		        new ammo = GetWeaponAmmo(playerid, Weapon(playerid, x, weapon_model));
                if(duty && Group(playerid, duty, group_type) == group_type_pd)
                {
			        format(string, sizeof string,
						"UPDATE `surv_items` SET `used` = 0, `v2` = '%d', `ownerType`='"#item_place_none"', `owner`='0' WHERE `uid` = '%d'",
						ammo,
						Weapon(playerid, x, weapon_uid)
					);
					mysql_query(string);
                }
                else
                {
			        format(string, sizeof string,
						"UPDATE `surv_items` SET `used` = 0, `v2` = '%d', `X`='%f', `Y`='%f', `Z`='%f', `vw`='%d', `ownerType`='"#item_place_none"', `owner`='0' WHERE `uid` = '%d'",
						ammo,
						Player(playerid, player_position)[ 0 ],
						Player(playerid, player_position)[ 1 ],
						posZ,
						Player(playerid, player_vw),
						Weapon(playerid, x, weapon_uid)
					);
					mysql_query(string);

					#if STREAMER
					    new Float:r[ 3 ],
							model;
						model = ObjectItem(item_weapon, Weapon(playerid, 0, weapon_model));
						r[ 0 ] = 85.0;
						r[ 1 ] = -809.0;
						r[ 2 ] = random(360);
					    format(string, sizeof string,
							"INSERT INTO `surv_objects` (`model`, `x`, `y`, `z`, `rx`, `ry`, `rz`, `ownerType`, `owner`) VALUES ('%d', '%f', '%f', '%f', '%f', '%f', '%f', '"#object_owner_item"', '%d')",
							model,
							Player(playerid, player_position)[ 0 ],
							Player(playerid, player_position)[ 1 ],
							posZ,
							r[ 0 ], r[ 1 ], r[ 2 ],
							Weapon(playerid, x, weapon_uid)
						);
						mysql_query(string);
						new objectuid = mysql_insert_id();
						new objectid = CreateDynamicObject(model, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], posZ, r[ 0 ], r[ 1 ], r[ 2 ], Door(Player(playerid, player_door), door_in_vw), -1, -1, 1000.0);
						Streamer_SetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_EXTRA_ID, objectuid);
						Streamer_Update(playerid);

						new c;
						for(; c < MAX_OBJECTS; c++)
						    if(Object(c, obj_objID) == objectid)
						        break;
						if(c == MAX_OBJECTS)
						{
						    for(c = 0; c < MAX_OBJECTS; c++)
						    	if(Object(c, obj_objID) == INVALID_OBJECT_ID)
						    	    break;
						}
			            if(c != MAX_OBJECTS)
			            {
							Object(c, obj_objID) = objectid;
							Object(c, obj_position)[ 0 ] = Player(playerid, player_position)[ 0 ];
							Object(c, obj_position)[ 1 ] = Player(playerid, player_position)[ 1 ];
							Object(c, obj_position)[ 2 ] = posZ;
							Object(c, obj_positionrot)[ 0 ] = r[ 0 ];
							Object(c, obj_positionrot)[ 1 ] = r[ 1 ];
							Object(c, obj_positionrot)[ 2 ] = r[ 2 ];
							Object(c, obj_owner)[ 0 ] = object_owner_item;
							Object(c, obj_owner)[ 1 ] = Weapon(playerid, x, weapon_uid);
						}
					#else
						foreach(Player, i)
						{
						    if(Player(i, player_vw) != Player(playerid, player_vw)) continue;

							new objectid = 1;
							for(; objectid != MAX_OBJECTS; objectid++)
			        			if(!IsValidPlayerObject(playerid, Object(playerid, objectid, obj_objID)) && !IsValidObject(objectid) && Object(playerid, objectid, obj_objID) == INVALID_OBJECT_ID)
							        break;
							if(objectid == MAX_OBJECTS) continue;

					        Object(i, objectid, obj_objID) = ObjectItem(i, item_weapon, Weapon(playerid, x, weapon_model), 0, Player(playerid, player_position)[ 0 ], Player(playerid, player_position)[ 1 ], posZ);
						    Object(i, objectid, obj_owner)[ 0 ] 	= object_owner_item;
						    Object(i, objectid, obj_owner)[ 1 ] 	= Weapon(playerid, x, weapon_uid);
						}
					#endif
				}
				ClearWeapon(playerid, x);

				if(IsPlayerAttachedObjectSlotUsed(playerid, x))
					RemovePlayerAttachedObject(playerid, x);
		    }
		}
		ResetPlayerWeapons(playerid);
	}
	if(Player(playerid, player_spectated))
	{
	    Player(playerid, player_spectated) = 0;
	    foreach(Player, i)
	    {
	        if(Player(i, player_spec) != playerid) continue;
	        if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
			{
				PlayerSpectateVehicle(i, GetPlayerVehicleID(playerid));
			}
			else
			{
				PlayerSpectatePlayer(i, playerid);
			}
			Player(playerid, player_spectated)++;
		}
	}
	return 1;
}

public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
	#if Debug
	    //printf("OnVehicleDamageStatusUpdate(%d, %d)", vehicleid, playerid);
	#endif
	new Float:hp;
	GetVehicleHealth(vehicleid, hp);
	if(hp >= 900.0)
	    UpdateVehicleDamageStatus(vehicleid, Vehicle(vehicleid, vehicle_damage)[ 0 ], Vehicle(vehicleid, vehicle_damage)[ 1 ], Vehicle(vehicleid, vehicle_damage)[ 2 ], Vehicle(vehicleid, vehicle_damage)[ 3 ]);

    Vehicle_Timer(playerid);
    AntyCheatVehicle();
	return 1;
}
/*
public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	#if Debug
	    printf("OnVehicleRespray(%d, %d, %d, %d)", playerid, vehicleid, color1, color2);
	#endif
	if(Vehicle(vehicleid, vehicle_color)[ 0 ] != color1 || Vehicle(vehicleid, vehicle_color)[ 1 ] != color2)
		ChangeVehicleColor(vehicleid, Vehicle(vehicleid, vehicle_color)[ 0 ], Vehicle(vehicleid, vehicle_color)[ 1 ]);
	return 1;
}
*/

FuncPub::RespawnVeh(vehid, playerid)
{
    ClearRace(playerid);
    DisablePlayerRaceCheckpoint(playerid);
    SetVehicleToRespawn(Vehicle(vehid, vehicle_vehID));
    Vehicle(vehid, vehicle_empty_timer) = 0;
    Player(playerid, player_race) = 0;
    Player(playerid, player_race_max) = 0;
	return 1;
}

FuncPub::EngineOff(carid)
{
	new s[ 7 ];
 	GetVehicleParamsEx(carid, s[ 0 ], s[ 1 ], s[ 2 ], s[ 3 ], s[ 4 ], s[ 5 ], s[ 6 ]);
 	SetVehicleParamsEx(carid, _:Vehicle(carid, vehicle_engine) = false, s[ 1 ], s[ 2 ], s[ 3 ], s[ 4 ], s[ 5 ], s[ 6 ]);
 	Vehicle(carid, vehicle_empty_timer) = 0;
	return 1;
}

public OnVehicleDeath(vehicleid)
{
	#if Debug
	    printf("OnVehicleDeath(%d)", vehicleid);
	#endif
	if(Vehicle(vehicleid, vehicle_owner)[ 0 ] != vehicle_owner_job)
	{
		GetVehiclePos(Vehicle(vehicleid, vehicle_vehID), Vehicle(vehicleid, vehicle_position)[ 0 ], Vehicle(vehicleid, vehicle_position)[ 1 ], Vehicle(vehicleid, vehicle_position)[ 2 ]);
		GetVehicleZAngle(Vehicle(vehicleid, vehicle_vehID), Vehicle(vehicleid, vehicle_position)[ 3 ]);
		new string[ 160 ];
		format(string, sizeof string,
			"UPDATE `surv_vehicles` SET `x` = '%f', `y` = '%f', `z` = '%f', `a` = '%f', `hp` = '300.5' WHERE `uid` = '%d'",
			Vehicle(vehicleid, vehicle_position)[ 0 ],
			Vehicle(vehicleid, vehicle_position)[ 1 ],
			Vehicle(vehicleid, vehicle_position)[ 2 ],
			Vehicle(vehicleid, vehicle_position)[ 3 ],
			Vehicle(vehicleid, vehicle_uid)
		);
		mysql_query(string);

	    Vehicle(vehicleid, vehicle_hp) = 300.5;
		SetVehicleHealth(Vehicle(vehicleid, vehicle_vehID), Vehicle(vehicleid, vehicle_hp));
	}
    SetTimerEx("Respawn_Vehicle", 250, 0, "i", vehicleid);
	return 1;
}

FuncPub::Respawn_Vehicle(carid)
{
	new v_uid = Vehicle(carid, vehicle_uid);
	UnSpawnVeh(carid);
	carid = LoadVehicleEx(v_uid);
	SetVehicleParamsEx(Vehicle(carid, vehicle_vehID), _:Vehicle(carid, vehicle_engine) = 0, 0, 0, _:Vehicle(carid, vehicle_lock) = false, 0, 0, 0);
	SetVehicleHealth(Vehicle(carid, vehicle_vehID), Vehicle(carid, vehicle_hp));
	return 1;
}

FuncPub::OnVehicleLoseHP(playerid, Float:amount)
{
	#if Debug
	    printf("OnVehicleLoseHP(%d, %f)", playerid, amount);
	#endif

	//if(Player(playerid, player_pasy)) amount /= 2;

	new amo = floatval(amount)/10;
	
	Player(playerid, player_hp) 		-= amount/10;

	if((Player(playerid, player_screen) + (amo/20)+1) < 15)
		Player(playerid, player_screen) += (amo/20)+1;
	else
	    Player(playerid, player_screen) = 15;

	if(Player(playerid, player_screen))
	    Player(playerid, player_color) 	= player_nick_red;

	if(amo)
	{
	    TextDrawShowForPlayer(playerid, Setting(setting_red));
	    //Player(playerid, player_dark) = dark_none;
		//FadeColorForPlayer(playerid, 255, 0, 0, floatround(amount)*10, 0, 0, 0, 0, floatround(amount), 0);
	}
	
	if((Player(playerid, player_pulse) 	+ (amo*2)+1) < 200)
    	Player(playerid, player_pulse) 	+= (amo*2)+1;
	else
	    Player(playerid, player_pulse) 	= 200;

	Energy(playerid);
	UpdatePlayerNick(playerid);
	return 1;
}

FuncPub::Vehicle_Timer(playerid)
{
	new carid = Player(playerid, player_veh);
	if(carid == INVALID_VEHICLE_ID) return 1;
	if(Vehicle(carid, vehicle_fuel) < 0.1 && Vehicle(carid, vehicle_engine) && !IsARower(carid))
 	{
 		if(IsPlayerInAnyVehicle(playerid))
		{
			TextDrawShowForPlayer(playerid, Setting(setting_silnik));
			PlayerTextDrawHide(playerid, Player(playerid, player_veh_td));

			serwerdo(playerid, "* Silnik zgasł. *");
	    	serwerdo(playerid, "* W pojeździe skończyło się paliwo. *");

			GetVehiclePos(Vehicle(carid, vehicle_vehID), Vehicle(carid, vehicle_position)[ 0 ], Vehicle(carid, vehicle_position)[ 1 ], Vehicle(carid, vehicle_position)[ 2 ]);
			GetVehicleZAngle(Vehicle(carid, vehicle_vehID), Vehicle(carid, vehicle_position)[ 3 ]);
			GetVehicleHealth(Vehicle(carid, vehicle_vehID), Vehicle(carid, vehicle_hp));
			GetVehicleDamageStatus(Vehicle(carid, vehicle_vehID), Vehicle(carid, vehicle_damage)[ 0 ], Vehicle(carid, vehicle_damage)[ 1 ], Vehicle(carid, vehicle_damage)[ 2 ], Vehicle(carid, vehicle_damage)[ 3 ]);

            Vehicle(carid, vehicle_fuel) = 0;

		    new s[ 7 ];
	     	GetVehicleParamsEx(Vehicle(carid, vehicle_vehID), s[ 0 ], s[ 1 ], s[ 2 ], s[ 3 ], s[ 4 ], s[ 5 ], s[ 6 ]);
	      	SetVehicleParamsEx(Vehicle(carid, vehicle_vehID), _:Vehicle(carid, vehicle_engine) = 0, s[ 1 ], s[ 2 ], _:Vehicle(carid, vehicle_lock), s[ 4 ], s[ 5 ], s[ 6 ]);
			return 1;
		}
	}
	new Float:przebieg,
		Float:pos[ 3 ],
		Float:reprzebieg;

	GetVehiclePos(Vehicle(carid, vehicle_vehID), pos[ 0 ], pos[ 1 ], pos[ 2 ]);
	przebieg = Distance3D(Vehicle(carid, vehicle_act_position)[ 0 ], Vehicle(carid, vehicle_act_position)[ 1 ], Vehicle(carid, vehicle_act_position)[ 2 ], pos[ 0 ], pos[ 1 ], pos[ 2 ]);
    reprzebieg = floatdiv(przebieg, przebieg_przelicznik);
    Vehicle(carid, vehicle_act_position)[ 0 ]	= pos[ 0 ];
    Vehicle(carid, vehicle_act_position)[ 1 ]	= pos[ 1 ];
    Vehicle(carid, vehicle_act_position)[ 2 ]	= pos[ 2 ];

	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		if(!Vehicle(carid, vehicle_engine))
			return 1;
			
		new string[ 150 ];
		format(string, sizeof string, "\
			~y~~h~Predkosc: %s%.2fkm/h~n~\
			~y~~h~Paliwo: %s%.2f~w~/%dL~n~\
			~y~~h~Przebieg: ~w~%.2fkm",
			(GetVehSpeed(Vehicle(carid, vehicle_vehID)) > ((Street(Player(playerid, player_streetid), street_limit) > 0) ? (Street(Player(playerid, player_streetid), street_limit)) : (999))) ? ("~r~") : ("~w~"),
			GetVehSpeed(Vehicle(carid, vehicle_vehID)),
			(Vehicle(carid, vehicle_fuel) <= ((GetVehicleMaxFuel(Vehicle(carid, vehicle_model))/100)*5)) ? ("~r~~h~"):("~w~"), // TODO
			Vehicle(carid, vehicle_fuel),
			GetVehicleMaxFuel(Vehicle(carid, vehicle_model)),
			Vehicle(carid, vehicle_distance)
		);
		PlayerTextDrawSetString(playerid, Player(playerid, player_veh_td), string);
		
        Vehicle(carid, vehicle_distance) 	+= reprzebieg;
		Player(playerid, player_veh_dist)   += reprzebieg;
		
		new bool:c;
		foreach(Player, i)
		{
		    if(Player(i, player_veh) == INVALID_VEHICLE_ID) continue;
		    if(Taxi(i, taxi_player) == INVALID_PLAYER_ID) continue;
		    if(Player(i, player_veh) != carid) continue;
		    if(Taxi(i, taxi_player) != playerid) continue;
		    if(GetPlayerState(i) != PLAYER_STATE_PASSENGER) continue;
		    
	        Taxi(i, taxi_dist) += reprzebieg;

	        format(string, sizeof string,
				"~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~b~Dystans: ~w~%.2fkm~n~~b~Cena: ~g~$~w~%.2f",
				Taxi(i, taxi_dist),
				floatmul(Taxi(i, taxi_price), Taxi(i, taxi_dist))
			);
			GameTextForPlayer(i, string, 1200, 3);
			if(!c)
			{
				GameTextForPlayer(playerid, string, 1200, 3);
				c = true;
			}
		}
        if(!IsARower(carid))
			Vehicle(carid, vehicle_fuel) 		-= floatdiv(przebieg, fuel_przelicznik);

/*		if(Vehicle(carid, vehicle_tire)[ 0 ] > 0 && getTire(Vehicle(carid, vehicle_vehID), LEFT_B_TIRE) == FULL)
			Vehicle(carid, vehicle_tire)[ 0 ]   -= reprzebieg;
		else
		{
		    if(getTire(Vehicle(carid, vehicle_vehID), LEFT_F_TIRE) == FULL)
		    {
			    Vehicle(carid, vehicle_tire)[ 0 ] = 0.0;
			    setTire(Vehicle(carid, vehicle_vehID), LEFT_F_TIRE, DAMAGED);
				serwerdo(playerid, "* Lewa przednia opona pękła. *");
			}
		}

		if(Vehicle(carid, vehicle_tire)[ 1 ] > 0 && getTire(Vehicle(carid, vehicle_vehID), LEFT_B_TIRE) == FULL)
			Vehicle(carid, vehicle_tire)[ 1 ]   -= reprzebieg;
		else
		{
		    if(getTire(Vehicle(carid, vehicle_vehID), LEFT_B_TIRE) == FULL)
		    {
			    Vehicle(carid, vehicle_tire)[ 1 ] = 0.0;
			    setTire(Vehicle(carid, vehicle_vehID), LEFT_B_TIRE, DAMAGED);
				serwerdo(playerid, "* Lewa tylnia opona pękła. *");
			}
		}

		if(Vehicle(carid, vehicle_tire)[ 2 ] > 0 && getTire(Vehicle(carid, vehicle_vehID), RIGHT_F_TIRE) == FULL)
			Vehicle(carid, vehicle_tire)[ 2 ]   -= reprzebieg;
		else
		{
		    if(getTire(Vehicle(carid, vehicle_vehID), RIGHT_F_TIRE) == FULL)
		    {
			    Vehicle(carid, vehicle_tire)[ 2 ] = 0.0;
			    setTire(Vehicle(carid, vehicle_vehID), RIGHT_F_TIRE, DAMAGED);
				serwerdo(playerid, "* Prawa przednia opona pękła. *");
			}
		}

		if(Vehicle(carid, vehicle_tire)[ 3 ] > 0 && getTire(Vehicle(carid, vehicle_vehID), RIGHT_B_TIRE) == FULL)
			Vehicle(carid, vehicle_tire)[ 3 ]   -= reprzebieg;
		else
		{
		    if(getTire(Vehicle(carid, vehicle_vehID), RIGHT_B_TIRE) == FULL)
		    {
			    Vehicle(carid, vehicle_tire)[ 3 ] = 0.0;
			    setTire(Vehicle(carid, vehicle_vehID), RIGHT_B_TIRE, DAMAGED);
				serwerdo(playerid, "* Prawa tylnia opona pękła. *");
			}
		}*/
	}
	return 1;
}

FuncPub::Vehicle_Repair(playerid)
{
	if(!Repair(playerid, repair_time)) return 1;
	if(Repair(playerid, repair_type) == repair_comp || Repair(playerid, repair_type) == repair_inveh || Repair(playerid, repair_type) == repair_repair)
	{
	    new victimid = Repair(playerid, repair_player),
			vehicleid = Repair(playerid, repair_value)[ 2 ];
			
	    if(GetDistanceToCar(playerid, vehicleid) > 10.0)
	    {
	        if(Repair(playerid, repair_type) == repair_repair)
	        	GivePlayerMoneyEx(victimid, Repair(victimid, repair_value2) + Repair(playerid, repair_cash), true);
			else
	        	GivePlayerMoneyEx(victimid, Repair(playerid, repair_cash), true);

			GameTextForPlayer(playerid, Repair(playerid, repair_type) == repair_comp ? ("~w~Tuning ~r~anulowany") : ("~w~Naprawa ~r~anulowana"), 1000, 3);
			GameTextForPlayer(victimid, Repair(playerid, repair_type) == repair_comp ? ("~w~Tuning ~r~anulowany") : ("~w~Naprawa ~r~anulowana"), 1000, 3);

	        End_Repair(playerid);
	        return 1;
	    }
  		else if(GetDistanceToCar(playerid, vehicleid) > 5.0)
		  	return GameTextForPlayer(playerid, "~r~Nie oddalaj sie od pojazdu!", 1000, 3);
		if(GetPlayerVehicleID(playerid) > 0 && GetPlayerVehicleID(playerid) != vehicleid)
		    return GameTextForPlayer(playerid, "~r~Nie oddalaj sie od pojazdu!", 1000, 3);

	    new string[ 125 ];
		ReturnTime(Repair(playerid, repair_time), string);
	    format(string, sizeof string, "~r~%s: ~w~%s", dli(Repair(playerid, repair_time), "pozostala", "pozostaly", "pozostalo"), string);
        GameTextForPlayer(playerid, string, 1000, 1);
	    Repair(playerid, repair_time)--;

	    if(!Repair(playerid, repair_time))
	    {
	        new comp = Repair(playerid, repair_value)[ 1 ],
	            item = Repair(playerid, repair_value)[ 0 ];
	        if(Repair(playerid, repair_type) == repair_inveh)
	        {
	         	GameTextForPlayer(playerid, "~b~Element dodany!", 3000, 3);
	         	
				if(comp == inveh_neon)
				{
				    Vehicle(vehicleid, vehicle_option) += option_neon;
                	Vehicle(vehicleid, vehicle_neon) = Repair(victimid, repair_value)[ 3 ];
                	InstallNeon(vehicleid);
				}
				else
				{
				    if(!(Vehicle(vehicleid, vehicle_option) & InVeh[ comp ][ in_bit ]))
						Vehicle(vehicleid, vehicle_option) += InVeh[ comp ][ in_bit ];
					else
					    return ShowInfo(playerid, red"Wystąpił błąd. Napisz do admina!");
				}
				SaveVeh(vehicleid);
				
				format(string, sizeof string,
					"UPDATE `surv_items` SET `ownerType` = '" #item_place_tuning "', `owner` = '%d' WHERE `uid` = '%d'",
					Vehicle(vehicleid, vehicle_uid),
					item
				);
				mysql_query(string);
				GivePlayerMoneyEx(playerid, Repair(playerid, repair_cash), true);
	        }
	        else if(Repair(playerid, repair_type) == repair_comp)
	        {
	         	GameTextForPlayer(playerid, "~b~Pojazd zostal stuningowany!", 3000, 3);

	 			AddVehicleComponent(vehicleid, comp);
				new slot = GetVehicleComponentType(comp);

				Vehicle(vehicleid, vehicle_mod)[ slot ] = comp;
			    for(new sim; sim != sizeof SimilarComponents; sim++)
			    {
			        if(SimilarComponents[ sim ][ 0 ] == Vehicle(vehicleid, vehicle_mod)[ slot ])
			        	AddVehicleComponent(Vehicle(vehicleid, vehicle_vehID), SimilarComponents[ sim ][ 1 ]);
			    }

				format(string, sizeof string,
					"UPDATE `surv_vehicles` SET `m%d` = '%d' WHERE `uid` = '%d'",
					slot,
					comp,
					Vehicle(vehicleid, vehicle_uid)
				);
				mysql_query(string);
				
				format(string, sizeof string,
					"UPDATE `surv_items` SET `ownerType` = '" #item_place_tuning "', `owner` = '%d' WHERE `uid` = '%d'",
					Vehicle(vehicleid, vehicle_uid),
					item
				);
				mysql_query(string);

				GivePlayerMoneyEx(playerid, Repair(playerid, repair_cash), true);
			}
			else if(Repair(playerid, repair_type) == repair_repair)
			{
			    GameTextForPlayer(playerid, "~b~Pojazd zostal naprawiony!", 3000, 3);

				format(string, sizeof string,
				    "INSERT INTO `surv_vehicles_log` VALUES (NULL, '%d', '%d', '%f', UNIX_TIMESTAMP())",
				    Player(victimid, player_uid),
				    Vehicle(vehicleid, vehicle_uid),
				    1000.0 - Vehicle(vehicleid, vehicle_hp)
				);
				mysql_query(string);

				Vehicle(vehicleid, vehicle_ac) = true;
				Vehicle(vehicleid, vehicle_hp) = 1000.0;
				SetVehicleHealth(Vehicle(vehicleid, vehicle_vehID), Vehicle(vehicleid, vehicle_hp));
		   	    RepairVehicle(Vehicle(vehicleid, vehicle_vehID));
				Vehicle(vehicleid, vehicle_damage)[ 0 ] = Vehicle(vehicleid, vehicle_damage)[ 1 ] = Vehicle(vehicleid, vehicle_damage)[ 2 ] = Vehicle(vehicleid, vehicle_damage)[ 3 ] = 0;
			    SetTimerEx("EnableAnty", 2000, false, "d", vehicleid);
			    SaveVeh(vehicleid);
			    

				if(comp)
				{
					format(string, sizeof string,
					    "UPDATE `surv_groups` SET `cash` = `cash` + '%.2f' WHERE `uid` = '%d'",
					    Repair(playerid, repair_cash)/2,
					    Group(playerid, comp, group_uid)
					);
					mysql_query(string);
					GivePlayerMoneyEx(playerid, Repair(playerid, repair_cash)/2, true);
				}
				else GivePlayerMoneyEx(playerid, Repair(playerid, repair_cash), true);
			}

			PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			PlayerPlaySound(victimid, 1133, 0.0, 0.0, 0.0);

            End_Repair(playerid);
	    }
	}
	return 1;
}

FuncPub::End_Repair(playerid)
{
    for(new eRepair:i; i < eRepair; i++)
    	Repair(playerid, i) = 0;
    	
	if(Player(playerid, player_spray) != Text3D:INVALID_3DTEXT_ID)
	{
		Delete3DTextLabel(Player(playerid, player_spray));
	    Player(playerid, player_spray) = Text3D:INVALID_3DTEXT_ID;
	}
	return 1;
}

FuncPub::CanPlayerVehicleDrive(playerid, carid)
{
	if(Player(playerid, player_adminlvl))
	    return true;
	    
	if(Vehicle(carid, vehicle_owner)[ 0 ] == vehicle_owner_group)
	{
	    new groupid = IsPlayerInUidGroup(playerid, Vehicle(carid, vehicle_owner)[ 1 ]);
	    if(groupid && Group(playerid, groupid, group_can) & member_can_vehicle)
			return true;
	}
	else if(Vehicle(carid, vehicle_owner)[ 0 ] == vehicle_owner_job)
	{
	    if(Vehicle(carid, vehicle_owner)[ 1 ] == Player(playerid, player_job))
	        return true;
	}
	else
	{
		new num, string[ 160 ];
		format(string, sizeof string,
			"SELECT 1 FROM `surv_items` WHERE `type` = "#item_key" AND `v1` = "#key_type_vehicle" AND `v2` = '%d' AND `ownerType`="#item_place_player" AND `owner`='%d'",
			Vehicle(carid, vehicle_uid),
			Player(playerid, player_uid)
		);
		mysql_query(string);
		mysql_store_result();
		num = mysql_num_rows();
		mysql_free_result();

		if(num)
		    return true;
		else if(Vehicle(carid, vehicle_owner)[ 0 ] == vehicle_owner_player)
		{
		    if(Player(playerid, player_uid) == Vehicle(carid, vehicle_owner)[ 1 ])
		        return true;
		}
	}
	return false;
}

FuncPub::Vehicle_OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	new vehid = Player(playerid, player_veh);

	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
 	{
		if(PRESSED(KEY_ACTION + KEY_FIRE)) // CTRL
		{
			cmd_silnik(playerid, "");
		}
		if(PRESSED(KEY_CROUCH))
		{
		    Vehicle_Hook(playerid);
		}
		if(PRESSED(KEY_FIRE) && !(newkeys & KEY_LOOK_LEFT) && !(newkeys & KEY_LOOK_RIGHT))
		{
		    Vehicle(vehid, vehicle_light)++;
		    if(Vehicle(vehid, vehicle_option) & option_siren)
		    {
		    	if(Vehicle(vehid, vehicle_light) >= 3) Vehicle(vehid, vehicle_light) = 0;
		    	if(Vehicle(vehid, vehicle_light) == 1)
		    	{
		    	    setLight(vehid, RIGHT_LIGHT, FULL);
        			setLight(vehid, LEFT_LIGHT, FULL);
				}
			}
			else
			{
		    	if(Vehicle(vehid, vehicle_light) >= 2) Vehicle(vehid, vehicle_light) = 0;
			}
		    
		    new s[ 7 ];
			GetVehicleParamsEx(vehid, s[ 0 ], s[ 1 ], s[ 2 ], s[ 3 ], s[ 4 ], s[ 5 ], s[ 6 ]);
			if(!Vehicle(vehid, vehicle_light)) s[ 1 ] = VEHICLE_PARAMS_OFF;
			else s[ 1 ] = VEHICLE_PARAMS_ON;
			SetVehicleParamsEx(vehid, s[ 0 ], s[ 1 ], s[ 2 ], s[ 3 ], s[ 4 ], s[ 5 ], s[ 6 ]);
		}
/*		if(!IsAPlane(Vehicle(vehid, vehicle_vehID)) && !IsABoat(Vehicle(vehid, vehicle_vehID)))
	 	{
			if(newkeys & ( KEY_LOOK_LEFT ) && newkeys & ( KEY_LOOK_RIGHT ))
            {
                if(Vehicle(vehid, vehicle_blink)[ 2 ])
					DestroyObject(Vehicle(vehid, vehicle_blink)[ 5 ]),DestroyObject(Vehicle(vehid, vehicle_blink)[ 2 ]), DestroyObject(Vehicle(vehid, vehicle_blink)[3]),Vehicle(vehid, vehicle_blink)[ 2 ] = 0;
        		else if(Vehicle(vehid, vehicle_blink)[ 0 ])
					DestroyObject(Vehicle(vehid, vehicle_blink)[ 4 ]),DestroyObject(Vehicle(vehid, vehicle_blink)[ 0 ]), DestroyObject(Vehicle(vehid, vehicle_blink)[ 1 ]),Vehicle(vehid, vehicle_blink)[ 0 ] = 0;
                else
                   	SetVehicleBlinker(vehid, 1, 1);
                return 1;
            }
            if(newkeys & KEY_LOOK_RIGHT)
            {
                if(Vehicle(vehid, vehicle_blink)[ 0 ])
					DestroyObject(Vehicle(vehid, vehicle_blink)[ 4 ]), DestroyObject(Vehicle(vehid, vehicle_blink)[ 0 ]), DestroyObject(Vehicle(vehid, vehicle_blink)[ 1 ]),Vehicle(vehid, vehicle_blink)[ 0 ] = 0;
				else if(Vehicle(vehid, vehicle_blink)[ 2 ])
					DestroyObject(Vehicle(vehid, vehicle_blink)[ 5 ]), DestroyObject(Vehicle(vehid, vehicle_blink)[ 2 ]), DestroyObject(Vehicle(vehid, vehicle_blink)[ 3 ]),Vehicle(vehid, vehicle_blink)[ 2 ] = 0;
                else
                	SetVehicleBlinker(vehid, 0, 1);
            }
            if(newkeys & KEY_LOOK_LEFT)
            {
                if(Vehicle(vehid, vehicle_blink)[ 2 ])
					DestroyObject(Vehicle(vehid, vehicle_blink)[ 5 ]),DestroyObject(Vehicle(vehid, vehicle_blink)[ 2 ]), DestroyObject(Vehicle(vehid, vehicle_blink)[ 3 ]), Vehicle(vehid, vehicle_blink)[ 2 ] = 0;
    			else if(Vehicle(vehid, vehicle_blink)[ 0 ])
					DestroyObject(Vehicle(vehid, vehicle_blink)[ 4 ]),DestroyObject(Vehicle(vehid, vehicle_blink)[ 0 ]), DestroyObject(Vehicle(vehid, vehicle_blink)[ 1 ]), Vehicle(vehid, vehicle_blink)[ 0 ] = 0;
                else
                	SetVehicleBlinker(vehid, 1, 0);
            }
	 	}*/
	}
	if(PRESSED(KEY_FIRE) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER && Vehicle(vehid, vehicle_option) & option_turbo)
	{
        if(!IsValidObject(Player(playerid, player_nitro)))
		{
        	Player(playerid, player_nitro) = CreateObject(18694, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 500.0);
        	AttachObjectToVehicle(Player(playerid, player_nitro), vehid, 0.0, -2.3, 1.2, 180.0, 0.0, 0.0);
        }
        AddVehicleComponent(vehid, 1010);
    }
    else if(RELEASED(KEY_FIRE))
    {
		if(Player(playerid, player_nitro))
		{
			DestroyObject(Player(playerid, player_nitro));
			Player(playerid, player_nitro) = INVALID_OBJECT_ID;
		}
        RemoveVehicleComponent(vehid, 1010);
    }
	return 1;
}

stock SetVehicleBlinker(vehicleid, leftblinker=0, rightblinker=0)
{
    if(!leftblinker & !rightblinker) return false;
    new Float:_vX[ 2 ],
		Float:_vY[ 2 ],
		Float:_vZ[ 2 ];
    if(rightblinker)
    {
		if(IsTrailerAttachedToVehicle(vehicleid))
		{
		    new omg = GetVehicleModel(GetVehicleTrailer(Vehicle(vehicleid, vehicle_vehID)));
		    GetVehicleModelInfo(omg, VEHICLE_MODEL_INFO_SIZE, _vX[ 0 ], _vY[ 0 ], _vZ[ 0 ]);

			Vehicle(vehicleid, vehicle_blink)[ 4 ] = CreateObject(19294, 0, 0, 0, 0, 0, 0);
		    AttachObjectToVehicle(Vehicle(vehicleid, vehicle_blink)[ 4 ], GetVehicleTrailer(Vehicle(vehicleid, vehicle_vehID)),  _vX[ 0 ]/2.4, -_vY[ 0 ]/3.35, -1.0 ,0,0,0);
		}
		GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_SIZE, _vX[ 0 ], _vY[ 0 ], _vZ[ 0 ]);

        Vehicle(vehicleid, vehicle_blink)[ 0 ] = CreateObject(19294, 0, 0, 0, 0, 0, 0);
        AttachObjectToVehicle(Vehicle(vehicleid, vehicle_blink)[ 0 ], Vehicle(vehicleid, vehicle_vehID),  _vX[ 0 ]/2.23, _vY[ 0 ]/2.23, 0.1 ,0,0,0);

        Vehicle(vehicleid, vehicle_blink)[ 1 ] = CreateObject(19294, 0, 0, 0, 0, 0, 0);
        AttachObjectToVehicle(Vehicle(vehicleid, vehicle_blink)[ 1 ], Vehicle(vehicleid, vehicle_vehID),  _vX[ 0 ]/2.23, -_vY[ 0 ]/2.23, 0.1 ,0,0,0);
    }
    if(leftblinker)
    {
        if(IsTrailerAttachedToVehicle(vehicleid))
        {
            new omg = GetVehicleModel(GetVehicleTrailer(Vehicle(vehicleid, vehicle_vehID)));
        	GetVehicleModelInfo(omg, VEHICLE_MODEL_INFO_SIZE, _vX[ 0 ], _vY[ 0 ], _vZ[ 0 ]);

            Vehicle(vehicleid, vehicle_blink)[ 5 ] = CreateObject(19294, 0, 0, 0, 0, 0, 0);
            AttachObjectToVehicle(Vehicle(vehicleid, vehicle_blink)[ 5 ], GetVehicleTrailer(Vehicle(vehicleid, vehicle_vehID)), -_vX[ 0 ]/2.4, -_vY[ 0 ]/3.35, -1.0 ,0,0,0);
    	}
    	GetVehicleModelInfo(Vehicle(vehicleid, vehicle_model), VEHICLE_MODEL_INFO_SIZE, _vX[ 0 ], _vY[ 0 ], _vZ[ 0 ]);

        Vehicle(vehicleid, vehicle_blink)[ 2 ] = CreateObject(19294, 0, 0, 0, 0, 0, 0);
        AttachObjectToVehicle(Vehicle(vehicleid, vehicle_blink)[ 2 ], Vehicle(vehicleid, vehicle_vehID),  -_vX[ 0 ]/2.23, _vY[ 0 ]/2.23, 0.1 ,0,0,0);

        Vehicle(vehicleid, vehicle_blink)[ 3 ] = CreateObject(19294, 0, 0, 0, 0, 0, 0);
       	AttachObjectToVehicle(Vehicle(vehicleid, vehicle_blink)[ 3 ], Vehicle(vehicleid, vehicle_vehID),  -_vX[ 0 ]/2.23, -_vY[ 0 ]/2.23, 0.1 ,0,0,0);
    }
    return 1;
}

FuncPub::Vehicle_Hook(playerid)
{
   	new poj = Player(playerid, player_veh);
    if(poj != INVALID_VEHICLE_ID && GetVehicleModel(poj) == 525)
    {
        if(IsTrailerAttachedToVehicle(poj)) return DetachTrailerFromVehicle(poj);

        foreach(Server_Vehicles, i)
      	{
      	    if(i == poj) continue;
      	    if(!IsVehicleStreamedIn(i, playerid)) continue;
        	new Float:katH;
			new Float:katP;
			GetVehicleZAngle(poj, katH); // holownik
			GetVehicleZAngle(i, katP); // pojazd holowany
			if(AngleDifference(katH, katP) > 20.0) // jeśli nie stoją do siebie prostopadle, lub chociaż mniej więcej prostopadle, czyli ta różnica 20 stopni
				continue;
			new Float:hpos[2], Float:ppos[2];
			GetVehiclePos(poj, hpos[0], hpos[1], katH); // holownik
			GetVehiclePos(i, ppos[0], ppos[1], katH); // pojazd holowany
			katH = floatsqroot(floatpower(hpos[1] - ppos[1], 2) + floatpower(hpos[0] - ppos[0], 2)); // obliczanie odległości miedzy pojazdami z Pitagorasa
			if(katH > 10.0) // jeśli są zbyt daleko od siebie
				continue;

			ppos[0] += (katH * floatsin(-katP, degrees));
			ppos[1] += (katH * floatcos(-katP, degrees));
			if(floatsqroot(floatpower(hpos[1] - ppos[1], 2) + floatpower(hpos[0] - ppos[0], 2)) > 3.0)
				continue;
				
			//holowanie
			AttachTrailerToVehicle(i, poj);
			break;
        }
    }
	return 1;
}

FuncPub::Vehicle_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case 37:
	    {
	        if(!response) return 1;
	        if(!listitem) return ShowPlayerCars(playerid);
	        new vehicleuid = strval(inputtext),
				buffer[ 256 ];
	        Player(playerid, player_vehicle_uid) = vehicleuid;
	        
		    new vehicleid = INVALID_VEHICLE_ID;
			foreach(Server_Vehicles, vehid)
			{
				if(Vehicle(vehid, vehicle_uid) == vehicleuid)
				{
					vehicleid = vehid;
					break;
				}
			}
			new bool:spawned,
				owner[ 2 ];
			if(vehicleid == INVALID_VEHICLE_ID)
			{
				new string[ 80 ];
				format(string, sizeof string,
					"SELECT `ownerType`, `owner` FROM `surv_vehicles` WHERE `uid` = '%d'",
					vehicleuid
				);
				mysql_query(string);
				mysql_store_result();
				mysql_fetch_row(string);
				mysql_free_result();

				sscanf(string, "p<|>a<d>[2]",
					owner
				);
				spawned = false;
			}
			else
			{
			    owner = Vehicle(vehicleid, vehicle_owner);
			    spawned = true;
			}
			new index;
			for(; index != MAX_ICONS; index++)
			    if(Player(playerid, player_veh_icon)[ index ] == vehicleuid)
			        break;
			
 			if(spawned) strcat(buffer, "# Unspawnuj\n");
 			else strcat(buffer, "# Spawnuj\n");
 			strcat(buffer, "# Informacje\n");
 			if(spawned && (!index || index == MAX_ICONS))
 			    strcat(buffer, "# Namierz\n");
 			else if(spawned && !(!index || index == MAX_ICONS))
 			    strcat(buffer, "# Zakończ namierzanie\n");
			if(owner[ 0 ] == vehicle_owner_player)
 			    strcat(buffer, "# Przypisz\n");
			if(Player(playerid, player_adminlvl))
			    strcat(buffer, red"Edytuj\n");
			Dialog::Output(playerid, 38, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Pojazd", buffer, "Wybierz", "Zamknij");
	    }
	    case 38:
	    {
	        if(!response) return 1;
	        new vehicleuid = Player(playerid, player_vehicle_uid);
	        if(strfind(inputtext, "Unspawnuj", true) != -1)
			{
			    new vehicleid;
				foreachex(Server_Vehicles, vehicleid)
					if(Vehicle(vehicleid, vehicle_uid) == vehicleuid)
						break;
				if(vehicleid == -1) return ShowInfo(playerid, red"Błąd!");
				
				if(Player(playerid, player_adminlvl))
				{
					foreach(Player, i)
					{
					    if(Player(i, player_veh) == INVALID_VEHICLE_ID) continue;
					    if(Player(i, player_veh) == vehicleid)
					        return ShowInfo(playerid, red"Ktoś jest w tym pojeździe!");
					}
				}
				
			    UnSpawnVeh(vehicleid);
				GameTextForPlayer(playerid, "~r~Pojazd ~w~odspawnowany.", 3000, 3);
			}
	        else if(strfind(inputtext, "Spawnuj", true) != -1)
	        {
				//SELECT surv_vehicles.uid FROM surv_vehicles JOIN surv_online ON surv_vehicles.ownerType = "#vehicle_owner_player" AND surv_vehicles.owner = surv_online.player WHERE surv_vehicles.spawned = 1
				if(Iter_Count(Server_Vehicles) == MAX_VEHICLES)
				{
		            new destroyid;
		            foreach(Server_Vehicles, vehicleid)
		            {
		                if(Vehicle(vehicleid, vehicle_owner)[ 0 ] == vehicle_owner_player)
		                {
		                    foreach(Player, i)
		                    {
			                    if(Vehicle(vehicleid, vehicle_owner)[ 1 ] != Player(i, player_uid))
			                    {
									destroyid = vehicleid;
									break;
			                    }
		                    }
		                    if(destroyid) break;
		                }
		            }
		            if(!destroyid)
						return ShowInfo(playerid, red"Nie możesz zespawnować auta, ponieważ skończył się limit pojazdów na serwerze.\n"white"Poczekaj chwilę i spróbuj ponownie!");
					else
					    UnSpawnVeh(destroyid);
				}
				GameTextForPlayer(playerid, "~r~Pojazd ~w~zespawnowany.", 3000, 3);
 				LoadVehicleEx(vehicleuid);
	        }
	        else if(strfind(inputtext, "Informacje", true) != -1)
	        {
	            new buffer[ 512 ],
					model,
					Float:hp,
					Float:fuel,
					name[ 64 ],
					color[ 2 ],
					plate[ 32 ],
					Float:distance;
					
			    new vehicleid = 1;
				foreachex(Server_Vehicles, vehicleid)
					if(Vehicle(vehicleid, vehicle_uid) == vehicleuid)
						break;

				if(vehicleid == -1)
				{
	            	format(buffer, sizeof buffer,
						"SELECT `name`, `model`, `hp`, `fuel`, `c1`, `c2`, `distance`, `plate` FROM `surv_vehicles` WHERE `uid` = '%d'",
						vehicleuid
					);
					mysql_query(buffer);
					mysql_store_result();
					mysql_fetch_row(buffer);
					mysql_free_result();
					
					sscanf(buffer, "p<|>s[64]dffa<d>[2]fs[32]",
						name,
					    model,
					    hp,
					    fuel,
					    color,
					    distance,
					    plate
					);
				}
				else
				{
				    format(name, sizeof name, Vehicle(vehicleid, vehicle_name));
				    model 		= Vehicle(vehicleid, vehicle_model);
				    hp 			= Vehicle(vehicleid, vehicle_hp);
				    fuel 		= Vehicle(vehicleid, vehicle_fuel);
				    color[ 0 ] 	= Vehicle(vehicleid, vehicle_color)[ 0 ];
				    color[ 1 ] 	= Vehicle(vehicleid, vehicle_color)[ 1 ];
				    distance 	= Vehicle(vehicleid, vehicle_distance);
				    if(isnull(Vehicle(vehicleid, vehicle_plate)))
				        plate = "Brak";
				    else
				    	format(plate, sizeof plate, Vehicle(vehicleid, vehicle_plate));
	            }
				format(buffer, sizeof buffer, "UID:\t\t%d\n", vehicleuid);
				format(buffer, sizeof buffer, "%sModel:\t\t%s (%s - %d)\n", buffer, name, NazwyPojazdow[model - 400], model);
				format(buffer, sizeof buffer, "%sHP wozu:\t%.2f\t%s\n", buffer, hp, (hp <= 300.5) ? (red"Zniszczony") : (""));
				format(buffer, sizeof buffer, "%sPaliwo:\t\t%.2fl/%dl\n", buffer, fuel, GetVehicleMaxFuel(model));
				format(buffer, sizeof buffer, "%sRejestracja:\t%s\n", buffer, plate);
				format(buffer, sizeof buffer, "%sKolory:\t\t%d:%d\n", buffer, color[ 0 ], color[ 1 ]);
				format(buffer, sizeof buffer, "%sPrzebieg:\t%.2fkm\n", buffer, distance);
				ShowList(playerid, buffer);
	        }
	        else if(strfind(inputtext, "Namierz", true) != -1)
	        {
			    new vehicleid = 1;
				foreachex(Server_Vehicles, vehicleid)
					if(Vehicle(vehicleid, vehicle_uid) == vehicleuid)
						break;

				if(vehicleid == -1)
				    return ShowInfo(playerid, red"Pojazd nie jest zespawnowany!");

				new index;
				for(index = 1; index != MAX_ICONS; index++)
				    if(Player(playerid, player_veh_icon)[ index ] == Vehicle(vehicleid, vehicle_uid))
				        break;
				if(!index || index == MAX_ICONS)
				{
					for(index = 1; index != MAX_ICONS; index++)
					    if(!Player(playerid, player_veh_icon)[ index ])
					        break;
				}
				if(!index || index == MAX_ICONS)
				    return ShowInfo(playerid, red"Nie masz już wolnych slotów pod namierzanie pojazdów!");

				SetPlayerMapIcon(playerid, index, Vehicle(vehicleid, vehicle_act_position)[ 0 ], Vehicle(vehicleid, vehicle_act_position)[ 1 ], Vehicle(vehicleid, vehicle_act_position)[ 2 ], 55, 0, MAPICON_GLOBAL);
                Player(playerid, player_veh_icon)[ index ] = Vehicle(vehicleid, vehicle_uid);
				ShowInfo(playerid, green"Pojazd został zaznaczony na minimapie.");
			}
	        else if(strfind(inputtext, "Zakończ namierzanie", true) != -1)
	        {
			    new vehicleid = 1;
				foreachex(Server_Vehicles, vehicleid)
					if(Vehicle(vehicleid, vehicle_uid) == vehicleuid)
						break;

				if(vehicleid == -1)
				    return ShowInfo(playerid, red"Pojazd nie jest zespawnowany!");

				new index;
				for(; index != MAX_ICONS; index++)
				    if(Player(playerid, player_veh_icon)[ index ] == Vehicle(vehicleid, vehicle_uid))
				        break;
				        
				if(!index || index == MAX_ICONS)
				    return ShowInfo(playerid, red"Ten pojazd nie jest namierzany!");

				RemovePlayerMapIcon(playerid, index);
                Player(playerid, player_veh_icon)[ index ] = 0;
				ShowInfo(playerid, green"Pojazd został skasowany z mapy.");
			}
			else if(strfind(inputtext, "Przypisz", true) != -1)
			{
				new buffer[ 256 ];
				for(new groupid; groupid != MAX_GROUPS; groupid++)
				{
				    if(!Group(playerid, groupid, group_uid)) continue;

					format(buffer, sizeof buffer, "%s%d\t{%06x}%s\n", buffer, Group(playerid, groupid, group_uid), Group(playerid, groupid, group_color) >>> 8, Group(playerid, groupid, group_name));
				}
				if(isnull(buffer)) ShowInfo(playerid, red"Nie należysz do żadnej grupy!");
				else
				{
				    format(buffer, sizeof buffer, grey"UID:\tNazwa:\n%s", buffer);
					Dialog::Output(playerid, 44, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Przypisz", buffer, "Przypisz", "Zamknij");
				}
			}
			else if(strfind(inputtext, "Edytuj", true) != -1)
			{
				Create(playerid, create_value)[ 0 ] = vehicleuid;
			    Admin_OnDialogResponse(playerid, 99, 2, 0, "");
			}
	    }
	    case 43:
	    {
	        if(!response) return 1;
			if(strfind(inputtext, "Pokaż pojazdy", true) != -1)
			    ShowPlayerCars(playerid);
			else if(strfind(inputtext, "Silnik", true) != -1)
				cmd_silnik(playerid, "");
			else if(strfind(inputtext, "Ustawienia audio", true) != -1)
			{
			    new buffer[ 126 ],
					carid = Player(playerid, player_veh);
				format(buffer, sizeof buffer, "%s muzykę\n", Vehicle(carid, vehicle_sound) ? ("Wyłącz") : ("Włącz"));
				if(Vehicle(carid, vehicle_sound))
				    strcat(buffer, "Zmień utwór\n");
				Dialog::Output(playerid, 49, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Ustawienia audio", buffer, "Wybierz", "Zamknij");
			}
			else if(strfind(inputtext, "neony", true) != -1)
			{
			    new carid = Player(playerid, player_veh);
			    
				if(Vehicle(carid, vehicle_option) & option_neon)
				    Vehicle(carid, vehicle_option) -= option_neon;
				else
				    Vehicle(carid, vehicle_option) += option_neon;
				    
				InstallNeon(carid);
			}
			else if(strfind(inputtext, "Informacje", true) != -1)
			{
			    Player(playerid, player_vehicle_uid) = Vehicle(Player(playerid, player_veh), vehicle_uid);
			    Vehicle_OnDialogResponse(playerid, 38, 2, 0, "Informacje");
			}
			else if(strfind(inputtext, "Okno", true) != -1)
			{
			    new carid = Player(playerid, player_veh);
			    if(Vehicle(carid, vehicle_option) & option_window)
			        Vehicle(carid, vehicle_option) -= option_window;
				else
				    Vehicle(carid, vehicle_option) += option_window;
			}
			else if(strfind(inputtext, "Przypisz", true) != -1)
			{
			    Player(playerid, player_vehicle_uid) = Vehicle(Player(playerid, player_veh), vehicle_uid);
			    Vehicle_OnDialogResponse(playerid, 38, 2, 0, "Przypisz");
			}
			else
			{
			    new s[ 7 ],
			    	carid = Player(playerid, player_veh);
				GetVehicleParamsEx(carid, s[ 0 ], s[ 1 ], s[ 2 ], s[ 3 ], s[ 4 ], s[ 5 ], s[ 6 ]);
				if(strfind(inputtext, "Światła", true) != -1)
					s[ 1 ] = !s[ 1 ] ? (VEHICLE_PARAMS_ON) : (VEHICLE_PARAMS_OFF);
				else if(strfind(inputtext, "Maska", true) != -1)
					s[ 4 ] = !s[ 4 ] ? (VEHICLE_PARAMS_ON) : (VEHICLE_PARAMS_OFF);
				else if(strfind(inputtext, "Bagażnik", true) != -1)
					s[ 5 ] = !s[ 5 ] ? (VEHICLE_PARAMS_ON) : (VEHICLE_PARAMS_OFF);

				SetVehicleParamsEx(carid, s[ 0 ], s[ 1 ], s[ 2 ], s[ 3 ], s[ 4 ], s[ 5 ], s[ 6 ]);
			}
	    }
	    case 44:
	    {
	        if(!response || !listitem) return 1;
			new vehicleuid = Player(playerid, player_vehicle_uid),
				groupuid = strval(inputtext),
			    string[ 126 ];
			
		    new vehicleid = 1;
			foreachex(Server_Vehicles, vehicleid)
				if(Vehicle(vehicleid, vehicle_uid) == vehicleuid)
					break;
			format(string, sizeof string,
				"UPDATE `surv_vehicles` SET `ownerType` = "#vehicle_owner_group", `owner` = '%d' WHERE `uid` = %d",
				groupuid,
				vehicleuid
			);
			mysql_query(string);
			if(vehicleid != -1)
			{
			    Vehicle(vehicleid, vehicle_owner)[ 0 ] = vehicle_owner_group;
			    Vehicle(vehicleid, vehicle_owner)[ 1 ] = groupuid;
			}
			ShowInfo(playerid, green"Przypisałeś swój pojazd do grupy!");
	    }
	    case 49:
	    {
	        if(!response) return 1;
	       	new carid = Player(playerid, player_veh);
	       	if(carid == INVALID_VEHICLE_ID) return 1;

			if(strfind(inputtext, "muzykę", true) != -1)
			{
			    Vehicle(carid, vehicle_sound) = !Vehicle(carid, vehicle_sound);
			    if(!Vehicle(carid, vehicle_sound))
			    {
			        GameTextForPlayer(playerid, "~b~~h~Muzyka wylaczona!", 3000, 1);
			        foreach(Player, i)
			        {
			            if(carid != Player(i, player_veh)) continue;
			            if(Audio_IsClientConnected(i))
			            {
			            	Audio_Stop(i, Player(i, player_veh_sound));
			            	Player(i, player_veh_sound) = 0;
			            }
			            else StopAudioStreamForPlayer(i);
			        }
			    }
			    else
			    {
			        if(isnull(Vehicle(carid, vehicle_url)))
			        {
					    ShowPlayerCD(playerid, 50);
						SetPVarInt(playerid, "veh-change", 0);
			        }
			        else
			        {
				        foreach(Player, i)
				        {
				            if(carid != Player(i, player_veh)) continue;
				            if(Audio_IsClientConnected(i))
					            Player(i, player_veh_sound) = Audio_PlayStreamed(i, Vehicle(carid, vehicle_url));
							else
							    PlayAudioStreamForPlayer(i, Vehicle(carid, vehicle_url));
							
				        }
			        	GameTextForPlayer(playerid, "~b~~h~Muzyka wlaczona!", 3000, 1);
			        }
			    }
			}
			else if(DIN(inputtext, "Zmień utwór"))
			{
			    ShowPlayerCD(playerid, 50);
				SetPVarInt(playerid, "veh-change", 1);
			}
	    }
	    case 50:
	    {
	        if(!response) return OnDialogResponseEx(playerid, 43, 1, 0, "Ustawienia audio");
	        
	        new carid = Player(playerid, player_veh),
				itemuid = strval(inputtext),
				string[ 256 ];
			if(carid == INVALID_VEHICLE_ID) return 1;

			format(string, sizeof string, "SELECT surv_cd.url, surv_items.v1 FROM `surv_cd` JOIN `surv_items` ON surv_items.v1 = surv_cd.uid WHERE surv_items.uid = '%d'", itemuid);
			mysql_query(string);
			mysql_store_result();
			if(mysql_num_rows())
				mysql_fetch_row(string);
			else
			{
			    mysql_free_result();
			    return ShowInfo(playerid, red"Płyta jest pusta!");
			}
			mysql_free_result();
			new url[ 64 ],
				v1;
			sscanf(string, "p<|>s[64]d",
				url,
				v1
			);

			if(isnull(url))
			    return ShowInfo(playerid, red"Płyta jest pusta!");

			format(string, sizeof string, "UPDATE `surv_vehicles` SET `sound` = '%d' WHERE `uid` = '%d'", v1, Vehicle(carid, vehicle_uid));
			mysql_query(string);

			format(Vehicle(carid, vehicle_url), sizeof url, url);
	        foreach(Player, i)
	        {
	            if(carid != Player(i, player_veh)) continue;
	            if(Audio_IsClientConnected(i))
	            {
		            Audio_Stop(i, Player(i, player_veh_sound));
		            Player(i, player_veh_sound) = Audio_PlayStreamed(i, Vehicle(carid, vehicle_url));
	            }
	            else PlayAudioStreamForPlayer(playerid, Vehicle(carid, vehicle_url));
	        }

        	if(GetPVarInt(playerid, "veh-change"))
        		GameTextForPlayer(playerid, "~b~~h~Utwor zmieniony!", 3000, 1);
			else
        		GameTextForPlayer(playerid, "~b~~h~Muzyka wlaczona!", 3000, 1);

			DeletePVar(playerid, "veh-change");
	    }
	    case 82:
	    {
	        if(!response) return 1;
	        
			new carid = Player(playerid, player_veh);
			if(carid == INVALID_VEHICLE_ID) return 1;
			
	        new uid = strval(inputtext),
				string[ 126 ];
				
	        format(string, sizeof string,
	            "SELECT `type`, `v1`, `v2` FROM `surv_items` WHERE `uid` = '%d'",
	            uid
			);
			mysql_query(string);
			mysql_store_result();
			mysql_fetch_row(string);
			mysql_free_result();
			
	        new type,
				value[ 2 ];
			sscanf(string, "p<|>da<d>[2]", type, value);
			
			switch(type)
			{
			    case item_siren:
			    {
			        format(string, sizeof string,
			            "UPDATE `surv_items` SET `ownerType` = '"#item_place_player"', `owner` = '%d' WHERE `uid` = '%d'",
			            Player(playerid, player_uid),
			            uid
					);
					mysql_query(string);
					
					if(Vehicle(carid, vehicle_option) & option_siren)
					{
				        KillTimer(Vehicle(carid, vehicle_lights_timer));
				        Vehicle(carid, vehicle_option) -= option_siren;
				        Vehicle(carid, vehicle_siren) = 0;
				        GetVehicleDamageStatus(Vehicle(carid, vehicle_vehID), Vehicle(carid, vehicle_damage)[ 0 ], Vehicle(carid, vehicle_damage)[ 1 ], Vehicle(carid, vehicle_damage)[ 2 ], Vehicle(carid, vehicle_damage)[ 3 ]);
				        Vehicle(carid, vehicle_damage)[ 2 ] = 0;
				        UpdateVehicleDamageStatus(Vehicle(carid, vehicle_vehID), Vehicle(carid, vehicle_damage)[ 0 ], Vehicle(carid, vehicle_damage)[ 1 ], Vehicle(carid, vehicle_damage)[ 2 ], Vehicle(carid, vehicle_damage)[ 3 ]);

						if(Vehicle(carid, vehicle_siren_obj) != INVALID_OBJECT_ID)
				        {
					        DestroyObject(Vehicle(carid, vehicle_siren_obj));
					        Vehicle(carid, vehicle_siren_obj) = INVALID_OBJECT_ID;
				        }
				        
				        format(string, sizeof string,
				            "UPDATE `surv_vehicles` SET `siren` = '%d' WHERE `uid` = '%d'",
				            Vehicle(carid, vehicle_siren),
                            Vehicle(carid, vehicle_uid)
						);
						mysql_query(string);

				        ShowInfo(playerid, green"Syrena zdemontowana pomyślnie.");
			        }
			    }
			    case item_component:
			    {
			        format(string, sizeof string,
			            "UPDATE `surv_items` SET `ownerType` = '"#item_place_player"', `owner` = '%d' WHERE `uid` = '%d'",
			            Player(playerid, player_uid),
			            uid
					);
					mysql_query(string);

					new slot = GetVehicleComponentType(value[ 0 ]);
					format(string, sizeof string,
						"UPDATE `surv_vehicles` SET `m%d` = '0' WHERE `uid` = '%d'",
						slot,
						Vehicle(carid, vehicle_uid)
					);
					mysql_query(string);

					Vehicle(carid, vehicle_mod)[ slot ] = 0;
					RemoveVehicleComponent(carid, value[ 0 ]);
			    }
			    default: return Chat::Output(playerid, CLR_RED, "Opcja niedostępna");
			}
	    }
	    case 136:
	    {
	        if(!response) return 1;
	        new atid = strval(inputtext),
				vehid = Player(playerid, player_veh);

			if(vehid == INVALID_VEHICLE_ID) return 1;

			Vehicle(vehid, vehicle_attached) = atid;
			InstallAttach(vehid);
			
			new string[ 126 ];
			format(string, sizeof string,
				"UPDATE `surv_vehicles` SET `attach` = '%d' WHERE `uid` = '%d'",
				Vehicle(vehid, vehicle_attached),
				Vehicle(vehid, vehicle_uid)
			);
			mysql_query(string);
	    }
	}
	return 1;
}

FuncPub::Silnik(playerid, carid)
{
	new rand;
	switch(floatval(Vehicle(carid, vehicle_hp)))
	{
	    case 0..304:    rand = 0; // 0%
	    case 305..400: 	rand = 3; // 30%
	    case 401..500: 	rand = 4; // 50%
	    case 501..600: 	rand = 7; // 70%
	    case 601..700: 	rand = 8; // 80%
	}
	if(rand >= random(10)+1 || !Vehicle(carid, vehicle_fuel))
	{
		TextDrawShowForPlayer(playerid, Setting(setting_silnik));
		PlayerTextDrawHide(playerid, Player(playerid, player_veh_td));

    	Vehicle(carid, vehicle_engine) = false;
		serwerdo(playerid, "* Silnik nie odpalił. *");
		if(!Vehicle(carid, vehicle_fuel))
		    serwerdo(playerid, "* Wskaźnik wskazuje na brak paliwa. *");
	}
	else
	{
		PlayerTextDrawShow(playerid, Player(playerid, player_veh_td));
		TextDrawHideForPlayer(playerid, Setting(setting_silnik));

    	Vehicle(carid, vehicle_engine) = true;
        if(Player(playerid, player_option) & option_me)
			serwerdo(playerid, "* Silnik odpalił. *");
		else
			GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~g~~h~Silnik wlaczony!", 3000, 5);
    }
	new s[ 7 ];
 	GetVehicleParamsEx(carid, s[ 0 ], s[ 1 ], s[ 2 ], s[ 3 ], s[ 4 ], s[ 5 ], s[ 6 ]);
 	SetVehicleParamsEx(carid, _:Vehicle(carid, vehicle_engine), s[ 1 ], s[ 2 ], s[ 3 ], s[ 4 ], s[ 5 ], s[ 6 ]);

	foreach(Player, id)
	{
	    if(!Audio_IsClientConnected(id)) continue;
		Audio_Stop(id, Player(playerid, player_engine_sound)[ id ]);
		Player(playerid, player_engine_sound)[ id ] = 0;

		if(!Vehicle(carid, vehicle_engine)) continue;
		if(!OdlegloscMiedzyGraczami(15.0, playerid, id)) continue;
		new handleid;
		handleid = Audio_Play(id, engine_sound_started);
		Audio_Set3DPosition(id, handleid, Vehicle(carid, vehicle_act_position)[ 0 ], Vehicle(carid, vehicle_act_position)[ 1 ], Vehicle(carid, vehicle_act_position)[ 2 ], 10.0);
  	}
  	Player(playerid, player_veh_timer) = 0;
	return 1;
}

FuncPub::VehLight(vehid)
{
	new s[ 7 ];
	GetVehicleParamsEx(vehid, s[ 0 ], s[ 1 ], s[ 2 ], s[ 3 ], s[ 4 ], s[ 5 ], s[ 6 ]);
	SetVehicleParamsEx(vehid, _:Vehicle(vehid, vehicle_engine), false,  s[ 2 ], _:Vehicle(vehid, vehicle_lock), s[ 4 ], s[ 5 ], s[ 6 ]);
	Vehicle(vehid, vehicle_light) = 0;
	return 1;
}
Cmd::Input->odpal(playerid, params[]) return cmd_silnik(playerid, params);

Cmd::Input->silnik(playerid, params[])
{
	new carid = Player(playerid, player_veh);
 	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER || carid == INVALID_VEHICLE_ID || IsARower(carid))
	 	return 1;
	if(!CanPlayerVehicleDrive(playerid, carid))
		return ShowInfo(playerid, red"Nie możesz prowadzić tego pojazdu.");
	if(Player(playerid, player_veh_timer))
	    return ShowInfo(playerid, red"Jesteś w trakcie odpalania silnika!");
	    
	if(!Vehicle(carid, vehicle_engine))
	{
	    new time_started;
        if(Player(playerid, player_option) & option_me)
        {
            new string[ 100 ];
			format(string, sizeof string,
				"* %s odpala silnik pojazdu %s%s.",
				NickName(playerid),
				Vehicle(carid, vehicle_name),
				(Vehicle(carid, vehicle_option) & option_immo) ? (" dezaktywując immobiliser") : ("")
			);
			serwerme(playerid, string);
		}

		switch(floatval(Vehicle(carid, vehicle_hp)))
		{
		    case 0..304:    time_started = 15000;
		    case 305..400: 	time_started = 8000;
		    case 401..500: 	time_started = 7000;
		    case 501..600: 	time_started = 6000;
		    case 601..800: 	time_started = 5000;
		    case 801..900: 	time_started = 4000;
		    default: 		time_started = 3000;
		}
		if(!Vehicle(carid, vehicle_fuel)) time_started = 8000;
		
		if(Vehicle(carid, vehicle_option) & option_bomb)
		{
		    CreateExplosion(Vehicle(carid, vehicle_act_position)[ 0 ], Vehicle(carid, vehicle_act_position)[ 1 ], Vehicle(carid, vehicle_act_position)[ 2 ], 6, 10.0);
		    SetVehicleHealth(carid, Vehicle(carid, vehicle_hp) = 300.5);
			foreach(Player, id)
			{
			    if(Player(id, player_veh) == INVALID_VEHICLE_ID) continue;
			    if(carid != Player(id, player_veh)) continue;
			    Chat::Output(id, RED, "Zostałeś zabity przez bombę w samochodzie.");
				Player(id, player_block) += block_ck;
            	SetTimerEx (!#kickPlayer, 249, false, !"i", id);
			}
			Vehicle(carid, vehicle_option) -= option_bomb;
            return 1;
		}
		
		foreach(Player, id)
		{
		    if(!Audio_IsClientConnected(id)) continue;
		    if(!OdlegloscMiedzyGraczami(15.0, playerid, id)) continue;
		    Player(playerid, player_engine_sound)[ id ] = Audio_Play(id, engine_sound_start, .loop=true);
		    Audio_Set3DPosition(id, Player(playerid, player_engine_sound)[ id ], Vehicle(carid, vehicle_act_position)[ 0 ], Vehicle(carid, vehicle_act_position)[ 1 ], Vehicle(carid, vehicle_act_position)[ 2 ], 10.0);
		}

		Player(playerid, player_veh_timer) = SetTimerEx("Silnik", time_started, 0, "dd", playerid, carid);
		GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~g~~h~Trwa odpalanie silnika...", time_started, 5);
	}
	else
	{
		new s[ 7 ];
	 	GetVehicleParamsEx(carid, s[ 0 ], s[ 1 ], s[ 2 ], s[ 3 ], s[ 4 ], s[ 5 ], s[ 6 ]);
	 	SetVehicleParamsEx(carid, _:Vehicle(carid, vehicle_engine) = false, s[ 1 ], s[ 2 ], s[ 3 ], s[ 4 ], s[ 5 ], s[ 6 ]);

		TextDrawShowForPlayer(playerid, Setting(setting_silnik));
		PlayerTextDrawHide(playerid, Player(playerid, player_veh_td));
	}
	return 1;
}

Cmd::Input->v(playerid, params[])
{
	new sub[ 20 ],
		rest[ 126 ];
   	if(sscanf(params, "s[20]S()[126]", sub, rest))
   	{
   	    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
   	    {
   	        new carid = Player(playerid, player_veh);
   	        new buffer[ 256 ] = "# Pokaż pojazdy\n";
   	        if(Vehicle(carid, vehicle_option) & option_audio)
   	            strcat(buffer, "# Ustawienia audio\n");
			if(CanPlayerVehicleDrive(playerid, carid))
			{
			    strcat(buffer, grey"------------------------\n");
			    new s[ 7 ];
				GetVehicleParamsEx(carid, s[ 0 ], s[ 1 ], s[ 2 ], s[ 3 ], s[ 4 ], s[ 5 ], s[ 6 ]);
				format(buffer, sizeof buffer, "%sSilnik:\t\t%s\n", buffer, Vehicle(carid, vehicle_engine) ? (green"Zapalony") : (red"Zgaszony"));
				format(buffer, sizeof buffer, "%sŚwiatła:\t\t%s\n", buffer, s[ 1 ] ? (green"Zapalone") : (red"Zgaszone"));
				format(buffer, sizeof buffer, "%sMaska:\t\t%s\n", buffer, s[ 4 ] ? (green"Otwarta") : (red"Zamknięta"));
				format(buffer, sizeof buffer, "%sBagażnik:\t%s\n", buffer, s[ 5 ] ? (green"Otwarty") : (red"Zamknięty"));
				format(buffer, sizeof buffer, "%sOkno:\t\t%s\n", buffer, !(Vehicle(carid, vehicle_option) & option_window) ? (green"Otwarte") : (red"Zamknięte"));
				if(Vehicle(carid, vehicle_neon))
					format(buffer, sizeof buffer, "%sNeon:\t%s\n", buffer, Vehicle(carid, vehicle_option) & option_neon ? (green"Włączony") : (red"Wyłączony"));
				strcat(buffer, grey"------------------------\n");
			    strcat(buffer, "# Informacje o pojeździe\n");
			    strcat(buffer, "# Przypisz\n");
			}
            Dialog::Output(playerid, 43, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Pojazd", buffer, "Wybierz", "Zamknij");
		}
   	    else
   			ShowPlayerCars(playerid);
		return 1;
	}
   	if(!strcmp(sub, "zamknij", true) || !strcmp(sub, "z", true))
   	{
    	new vehid = GetClosestCar(playerid, 5.0);
        if(vehid == INVALID_VEHICLE_ID)
        {
			vehid = GetClosestCar(playerid, 10.0);
			if(vehid != INVALID_VEHICLE_ID)
			{
				if(!(Vehicle(vehid, vehicle_option) & option_alarm))
			    	vehid = INVALID_VEHICLE_ID;
			}
		}
		if(vehid == INVALID_VEHICLE_ID)
			return GameTextForPlayer(playerid, "~r~Nie znajdujesz sie w poblizu zadnego pojazdu", 3000, 3);
		if(!CanPlayerVehicleDrive(playerid, vehid))
			return ShowInfo(playerid, red"Nie możesz prowadzić tego pojazdu.");

		if(Player(playerid, player_option) & option_me)
 		{
 		    new string[ 80 + MAX_PLAYER_NAME ];
			format(string, sizeof string,
				"* %s %s pojazd %s%s",
				NickName(playerid),
				(Vehicle(vehid, vehicle_lock)) ? ("otwiera") : ("zamyka"),
				Vehicle(vehid, vehicle_name),
				(Vehicle(vehid, vehicle_option) & option_alarm) ? (" pilotem.") : (".")
			);
			serwerme(playerid, string);
		}
		else GameTextForPlayer(playerid, (Vehicle(vehid, vehicle_lock)) ? ("~g~Pojazd otwarty") : ("~r~Pojazd zamkniety"), 3000, 3);

		if(Vehicle(vehid, vehicle_option) & option_alarm)
			ApplyAnimation(playerid, "CRIB", "CRIB_use_switch", 4, 0, 0, 0, 0, 0, 1);
		else
			ApplyAnimation(playerid, "BD_FIRE", "wash_up", 4.0, 0, 0, 0, 0, 0, 1);
		new s[ 7 ];
		GetVehicleParamsEx(vehid, s[ 0 ], s[ 1 ], s[ 2 ], s[ 3 ], s[ 4 ], s[ 5 ], s[ 6 ]);
		if(Vehicle(vehid, vehicle_option) & option_alarm)
        {
			foreach(Player, id)
			{
			    if(!Audio_IsClientConnected(id)) continue;
		    	if(!OdlegloscMiedzyGraczami(15.0, playerid, id)) continue;
			    new handle_id;
			    handle_id = Audio_Play(id, vehicle_sound_alarm);
			    Audio_Set3DPosition(id, handle_id, Vehicle(vehid, vehicle_act_position)[ 0 ], Vehicle(vehid, vehicle_act_position)[ 1 ], Vehicle(vehid, vehicle_act_position)[ 2 ], 10.0);
			}
			if(!s[ 1 ])
			{
				s[ 1 ] = true;
				Vehicle(vehid, vehicle_light) = 1;
				SetTimerEx("VehLight", 500, false, "d", vehid);
			}
        }
       	Vehicle(vehid, vehicle_lock) = !Vehicle(vehid, vehicle_lock);
	 	SetVehicleParamsEx(vehid, _:Vehicle(vehid, vehicle_engine), s[ 1 ], s[ 2 ], _:Vehicle(vehid, vehicle_lock), s[ 4 ], s[ 5 ], s[ 6 ]);
   	}
   	else if(!strcmp(sub, "opis", true))
   	{
	   	new vehid = Player(playerid, player_veh);

   	    if(vehid == INVALID_VEHICLE_ID)
		   	return ShowInfo(playerid, red"Nie jesteś w pojeździe.");
		if(!CanPlayerVehicleDrive(playerid, vehid))
			return ShowInfo(playerid, red"Nie możesz użyć tej komendy w tym pojeździe.");

   		if(!strcmp(rest, "usun", true) || !strcmp(rest, "usuń", true))
	    {
		    if(Vehicle(vehid, vehicle_opis_id) != Text3D:INVALID_3DTEXT_ID)
		    {
			    Delete3DTextLabel(Vehicle(vehid, vehicle_opis_id));
			    Vehicle(vehid, vehicle_opis_id) = Text3D:INVALID_3DTEXT_ID;
			    Vehicle(vehid, vehicle_opis) = 0;
				ShowCMD(playerid, "Opis na pojeździe skasowany!");
		    }
		    else ShowCMD(playerid, "Nie masz żadnego opisu!");
	    }
	    else
	    {
	    	/*
			format(string, sizeof string,
				"SELECT `uid`, `opis` FROM `surv_opis` WHERE `type` = '"#text_owner_vehicle"' AND `id` = '%d'",
			    Player(playerid, player_uid)
			);
			
			while()
			{

				if(Vehicle(vehid, vehicle_opis) == uid)
					format(buffer, sizeof buffer, "- Aktualnie używany: "gui_active"%s\n- Wyłącz\n \nOstatnio używane:\n%s", name, buffer);

				if(Vehicle(vehid, vehicle_opis) == uid)
					format(buffer, sizeof buffer, "%s%d\t"gui_active"%s\n", buffer, uid, name);
				else
					format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, uid, name);
			}
*/
			wordwrap(rest);
			Vehicle(vehid, vehicle_opis) = 0;
		    if(Vehicle(vehid, vehicle_opis_id) == Text3D:INVALID_3DTEXT_ID)
		    {
				Vehicle(vehid, vehicle_opis_id) = Create3DTextLabel(rest, opis_color, 0.0, 0.0, 0.0, 5.0, 0, 1);
				Attach3DTextLabelToVehicle(Vehicle(vehid, vehicle_opis_id), vehid, 0.0, 0.0, 0.5);
			}
			else Update3DTextLabelText(Vehicle(vehid, vehicle_opis_id), opis_color, rest);
			format(rest, sizeof rest, white"Opis na pojeździe do czasu unspawnu pojazdu:\n\n%s", rest);
			ShowInfo(playerid, rest);
	    }
   	}
   	else if(!strcmp(sub, "info", true) || !strcmp(sub, "informacje", true))
   	{
   	    new vehid = Player(playerid, player_veh);
   	    if(vehid == INVALID_VEHICLE_ID)
		   	return ShowInfo(playerid, red"Nie jesteś w pojeździe.");
		if(!CanPlayerVehicleDrive(playerid, vehid))
			return ShowInfo(playerid, red"Nie możesz użyć tej komendy w tym pojeździe.");

        Player(playerid, player_vehicle_uid) = Vehicle(vehid, vehicle_uid);
   	    Vehicle_OnDialogResponse(playerid, 38, 1, 2, "Informacje");
   	}
   	else if(!strcmp(sub, "odpal", true) || !strcmp(sub, "o", true))
   	{
   	    cmd_silnik(playerid, rest);
   	}
   	else if(!strcmp(sub, "szyba", true) || !strcmp(sub, "okno", true))
   	{
	    new carid = Player(playerid, player_veh);
   	    if(carid == INVALID_VEHICLE_ID)
		   	return ShowInfo(playerid, red"Nie jesteś w pojeździe.");
	    if(Vehicle(carid, vehicle_option) & option_window)
	        Vehicle(carid, vehicle_option) -= option_window;
		else
		    Vehicle(carid, vehicle_option) += option_window;
   	}
   	else if(!strcmp(sub, "kogut", true) || !strcmp(sub, "syrena", true))
   	{
		cmd_kogut(playerid, "");
   	}
   	else if(!strcmp(sub, "przypisz", true))
   	{
   	    new vehid = Player(playerid, player_veh);
   	    if(vehid == INVALID_VEHICLE_ID)
		   	return ShowInfo(playerid, red"Nie jesteś w pojeździe.");
		if(Vehicle(vehid, vehicle_owner)[ 0 ] != vehicle_owner_player)
			return ShowInfo(playerid, red"Ten pojazd jest już przypisany do jakiejś grupy!");
	    if(Player(playerid, player_uid) != Vehicle(vehid, vehicle_owner)[ 1 ])
			return ShowInfo(playerid, red"Nie jesteś właścicielem tego pojazdu!");
			
		new buffer[ 256 ];
        Player(playerid, player_vehicle_uid) = Vehicle(vehid, vehicle_uid);
		for(new groupid; groupid != MAX_GROUPS; groupid++)
		{
		    if(!Group(playerid, groupid, group_uid)) continue;

			format(buffer, sizeof buffer, "%s%d\t{%06x}%s\n", buffer, Group(playerid, groupid, group_uid), Group(playerid, groupid, group_color) >>> 8, Group(playerid, groupid, group_name));
		}
		if(isnull(buffer)) ShowInfo(playerid, red"Nie należysz do żadnej grupy!");
		else
		{
		    format(buffer, sizeof buffer, "UID:\tNazwa:\n%s", buffer);
			Dialog::Output(playerid, 44, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Przypisz", buffer, "Przypisz", "Zamknij");
		}
   	}
   	else if(!strcmp(sub, "parkuj", true) || !strcmp(sub, "zaparkuj", true))
   	{
   	    new vehid = Player(playerid, player_veh);
   	    if(vehid == INVALID_VEHICLE_ID)
		   	return ShowInfo(playerid, red"Nie jesteś w pojeździe.");
		if(!CanPlayerVehicleDrive(playerid, vehid))
			return ShowInfo(playerid, red"Nie możesz przeparkować tego pojazdu.");
			
		//
		new bool:can_park = true;
		new zone = GetPlayerZone(playerid);
		if(zone)
			if(!IsPlayerInUidGroup(playerid, Zone(zone, zone_group)) && Zone(zone, zone_flag) & zone_parking)
			    can_park = false;
		if(can_park)
		{
			new grunt = GetPlayerGrunt(playerid);
			if(grunt)
			{
			    if(Grunt(grunt, grunt_owner)[ 0 ] == zone_owner_player)
			    {
			        if(Grunt(grunt, grunt_owner)[ 1 ] != Player(playerid, player_uid) && Grunt(grunt, grunt_flag) & zone_parking)
			            can_park = false;
			    }
			    else if(Grunt(grunt, grunt_owner)[ 0 ] == zone_owner_group)
			    {
			        if(!IsPlayerInUidGroup(playerid, Grunt(grunt, grunt_owner)[ 1 ]) && Grunt(grunt, grunt_flag) & zone_parking)
			            can_park = false;
			    }
				else if(Grunt(grunt, grunt_flag) & zone_parking)
					can_park = false;
			}
			if(can_park)
			{
				new street = GetPlayerStreet(playerid);
				if(street)
				    if(Street(street, street_flag) & zone_parking)
				        can_park = false;
			}
		}
		if(!can_park && !Player(playerid, player_adminlvl))
			return ShowInfo(playerid, red"W tej strefie nie możesz parkować!");
		
		//
		new string[ 200 ];
		if(!Player(playerid, player_adminlvl))
		{
			format(string, sizeof string,
				"SELECT `x`, `y`, `z` FROM `surv_vehicles` WHERE `uid` != '%d'",
				Vehicle(vehid, vehicle_uid)
			);
			mysql_query(string);
			mysql_store_result();
			if(mysql_num_rows())
	  		{
	  			while(mysql_fetch_row(string))
	     		{
	     		    static Float:pos[ 3 ];
				    sscanf(string, "p<|>a<f>[3]",
						pos
					);
	  				if(IsPlayerInRangeOfPoint(playerid, 2.0, pos[ 0 ], pos[ 1 ], pos[ 2 ]))
						return ShowInfo(playerid, red"W tym miejscu jest zaparkowany inny pojazd!");
				}
	   		}
	   		mysql_free_result();
   		}
   		
		GetVehiclePos(Vehicle(vehid, vehicle_vehID), Vehicle(vehid, vehicle_position)[ 0 ], Vehicle(vehid, vehicle_position)[ 1 ], Vehicle(vehid, vehicle_position)[ 2 ]);
		GetVehicleZAngle(Vehicle(vehid, vehicle_vehID), Vehicle(vehid, vehicle_position)[ 3 ]);
		format(string, sizeof string,
			"UPDATE `surv_vehicles` SET `x` = '%f', `y` = '%f', `z` = '%f', `a` = '%f', `int` = '%d', `vw` = '%d' WHERE `uid` = '%d'",
			Vehicle(vehid, vehicle_position)[ 0 ],
			Vehicle(vehid, vehicle_position)[ 1 ],
			Vehicle(vehid, vehicle_position)[ 2 ],
			Vehicle(vehid, vehicle_position)[ 3 ],
			Vehicle(vehid, vehicle_int),
			Vehicle(vehid, vehicle_vw),
			Vehicle(vehid, vehicle_uid)
		);
		mysql_query(string);
		
		if(IsTrailerAttachedToVehicle(Vehicle(vehid, vehicle_vehID)))
		{
			vehid = GetVehicleTrailer(Vehicle(vehid, vehicle_vehID));
			GetVehiclePos(Vehicle(vehid, vehicle_vehID), Vehicle(vehid, vehicle_position)[ 0 ], Vehicle(vehid, vehicle_position)[ 1 ], Vehicle(vehid, vehicle_position)[ 2 ]);
			GetVehicleZAngle(Vehicle(vehid, vehicle_vehID), Vehicle(vehid, vehicle_position)[ 3 ]);
			format(string, sizeof string,
				"UPDATE `surv_vehicles` SET `x` = '%f', `y` = '%f', `z` = '%f', `a` = '%f', `int` = '%d', `vw` = '%d' WHERE `uid` = '%d'",
				Vehicle(vehid, vehicle_position)[ 0 ],
				Vehicle(vehid, vehicle_position)[ 1 ],
				Vehicle(vehid, vehicle_position)[ 2 ],
				Vehicle(vehid, vehicle_position)[ 3 ],
				Vehicle(vehid, vehicle_int),
				Vehicle(vehid, vehicle_vw),
				Vehicle(vehid, vehicle_uid)
			);
			mysql_query(string);
		}
		
		ShowInfo(playerid, green"Pojazd zaparkowany pomyślnie.\n\n"red"Aby zapisać zmiany, należy zrespawnować pojazd.");
   	}
   	else if(!strcmp(sub, "tuning", true) || !strcmp(sub, "tunning", true))
   	{
   	    new vehid = Player(playerid, player_veh);
   	    if(vehid == INVALID_VEHICLE_ID)
		   	return ShowInfo(playerid, red"Nie jesteś w pojeździe.");
		if(!CanPlayerVehicleDrive(playerid, vehid))
			return ShowInfo(playerid, red"Nie możesz użyć tej komendy w tym pojeździe.");

	   	new	string[ 110 ],
	   		buffer[ 512 ];
		format(string, sizeof string,
			"SELECT `uid`, `name` FROM `surv_items` WHERE `ownerType` = '"#item_place_tuning"' AND `owner` = '%d'",
		    Vehicle(vehid, vehicle_uid)
		);
		mysql_query(string);
		mysql_store_result();
		while(mysql_fetch_row(string))
		{
		    static uid,
				name[ MAX_ITEM_NAME ];
				
		    sscanf(string, "p<|>ds["#MAX_ITEM_NAME"]",
				uid,
				name
			);
			
			format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, uid, name);
		}
		mysql_free_result();
		
		if(isnull(buffer)) ShowInfo(playerid, red"W tym pojeździe nie jest zamontowany żaden komponent.");
		else Dialog::Output(playerid, 82, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Komponenty", buffer, "Wymontuj", "Anuluj");
   	}
  	else if(!strcmp(sub, "napraw", true))
   	{
		if(!IsPlayerGameAdmin(playerid, 1, admin_perm_edit)) return 1;
   	    new vehid = Player(playerid, player_veh);
   	    if(vehid == INVALID_VEHICLE_ID)
		   	return ShowInfo(playerid, red"Nie jesteś w pojeździe.");
		   	
		Vehicle(vehid, vehicle_ac) = true;
		Vehicle(vehid, vehicle_hp) = 1000.0;
		SetVehicleHealth(Vehicle(vehid, vehicle_vehID), Vehicle(vehid, vehicle_hp));
   	    RepairVehicle(Vehicle(vehid, vehicle_vehID));
		Vehicle(vehid, vehicle_damage)[ 0 ] = Vehicle(vehid, vehicle_damage)[ 1 ] = Vehicle(vehid, vehicle_damage)[ 2 ] = Vehicle(vehid, vehicle_damage)[ 3 ] = 0;

		SendClientMessage(playerid, SZARY, "Pojazd został naprawiony.");
		SetTimerEx("EnableAnty", 2000, false, "d", vehid);
   	}
   	else if(!strcmp(sub, "edytuj", true) || !strcmp(sub, "edit", true))
   	{
		if(!IsPlayerGameAdmin(playerid, 1, admin_perm_edit)) return 1;

   	    new vehid = Player(playerid, player_veh);
   	    if(vehid == INVALID_VEHICLE_ID)
		   	return ShowInfo(playerid, red"Nie jesteś w pojeździe.");
		   	
		Create(playerid, create_value)[ 0 ] = Vehicle(vehid, vehicle_uid);
	    Admin_OnDialogResponse(playerid, 99, 2, 0, "");
   	}
   	else if(!strcmp(sub, "brama", true))
   	{
   	    new vehid = Player(playerid, player_veh);
   	    if(vehid == INVALID_VEHICLE_ID)
		   	return ShowInfo(playerid, red"Nie jesteś w pojeździe.");
		if(!CanPlayerVehicleDrive(playerid, vehid))
			return ShowInfo(playerid, red"Nie możesz używać tego pojazdu.");
   	    if(!(Vehicle(vehid, vehicle_option) & option_plot))
   	        return 1;
   	    if(!(Vehicle(vehid, vehicle_option) & option_plot_open))
   	    {
			DestroyObject(Vehicle(vehid, vehicle_attach)[ 4 ]);
			Vehicle(vehid, vehicle_attach)[ 5 ] = CreateObject(11474, 0, 0, 0, 0, 0, 0);
			Vehicle(vehid, vehicle_attach)[ 6 ] = CreateObject(11474, 0, 0, 0, 0, 0, 0);
			AttachObjectToVehicle(Vehicle(vehid, vehicle_attach)[ 5 ], Vehicle(vehid, vehicle_vehID), -0.025000000372529, -6.1770000457764, -0.80699998140335, 58.193572998047, 194.33984375, 166.49182128906);
			AttachObjectToVehicle(Vehicle(vehid, vehicle_attach)[ 6 ], Vehicle(vehid, vehicle_vehID), 0.037999998778105, -7.3889999389648, -1.5329999923706, 58.189086914063, 194.33715820313, 166.48681640625);
   	        Vehicle(vehid, vehicle_option) += option_plot_open;
   	    }
   	    else
   	    {
		    DestroyObject(Vehicle(vehid, vehicle_attach)[ 5 ]);
		    DestroyObject(Vehicle(vehid, vehicle_attach)[ 6 ]);
		    Vehicle(vehid, vehicle_attach)[ 4 ] = CreateObject(11474, -0.068000003695488, -5.7540001869202, 0.38100001215935, 0, 2.5, 5.5); // elevator
		    AttachObjectToVehicle(Vehicle(vehid, vehicle_attach)[ 5 ], Vehicle(vehid, vehicle_vehID), -0.068000003695488, -5.7540001869202, 0.38100001215935, 0, 2.5, 5.5);
   	        Vehicle(vehid, vehicle_option) -= option_plot_open;
   	    }
   	}
   	else if(!strcmp(sub, "attach", true))
   	{
   	    new vehid = Player(playerid, player_veh);
   	    if(vehid == INVALID_VEHICLE_ID)
		   	return ShowInfo(playerid, red"Nie jesteś w pojeździe.");
		if(!CanPlayerVehicleDrive(playerid, vehid))
			return ShowInfo(playerid, red"Nie możesz używać tego pojazdu.");

   	    new buffer[ 512 ],
		   	query[ 126 ];
		// Pojazdy grupy
		for(new groupid; groupid != MAX_GROUPS; groupid++)
		{
		    if(!Group(playerid, groupid, group_uid)) continue;
		    if(!(Group(playerid, groupid, group_can) & member_can_vehicle) && !Player(playerid, player_adminlvl)) continue;

			format(query, sizeof query,
			    "SELECT `uid`, `name` FROM `surv_v_attach_cat` WHERE `ownerType` = '"#vehicle_owner_group"' AND `owner` = '%d' AND `model` = '%d'",
			    Group(playerid, groupid, group_uid),
			    Vehicle(vehid, vehicle_model)
			);
			mysql_query(query);
			mysql_store_result();
		    if(mysql_num_rows())
				format(buffer, sizeof buffer, "%s{%06x}------------[%s]------------\n", buffer, Group(playerid, groupid, group_color) >>> 8, Group(playerid, groupid, group_name));
			while(mysql_fetch_row(query))
			{
			    static uid,
					name[ 32 ];
					
			    sscanf(query, "p<|>ds[32]",
					uid,
					name
				);
				
			    format(buffer, sizeof buffer, "%s%d\t%s\n", buffer, uid, name);
			}
			mysql_free_result();
		}
		if(isnull(buffer)) ShowInfo(playerid, red"Nie znaleziono dodatkowych części pasujących do pojazdu!");
		else Dialog::Output(playerid, 136, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Części przyczepialne", buffer, "Wybierz", "Zamknij");
   	}
	return 1;
}

Cmd::Input->wyrzuc(playerid, params[])
{
    new vehid = Player(playerid, player_veh);
    if(vehid == INVALID_VEHICLE_ID)
	   	return ShowInfo(playerid, red"Nie jesteś w pojeździe.");
	new victimid;
	if(sscanf(params, "u", victimid))
		return ShowCMD(playerid, "Tip: /wyrzuc [ID/Nick]");
	if(!IsPlayerConnected(victimid))
		return NoPlayer(playerid);
	if(Player(playerid, player_veh) != Player(victimid, player_veh))
		return ShowCMD(playerid, "Gracz nie znajduje się w pojeździe.");

    RemovePlayerFromVehicle(victimid);
	return 1;
}
Cmd::Input->maska(playerid, params[])
{
    new vehid = Player(playerid, player_veh);
    if(vehid == INVALID_VEHICLE_ID)
    {
        vehid = GetClosestCar(playerid);
        if(vehid == INVALID_VEHICLE_ID)
	   		return ShowInfo(playerid, red"Nie jesteś w/przy pojeździe.");
	}
	if(!CanPlayerVehicleDrive(playerid, vehid))
		return ShowInfo(playerid, red"Nie możesz używać tego pojazdu.");

    new s[ 7 ];
	GetVehicleParamsEx(vehid, s[ 0 ], s[ 1 ], s[ 2 ], s[ 3 ], s[ 4 ], s[ 5 ], s[ 6 ]);
	s[ 4 ] = !s[ 4 ] ? (VEHICLE_PARAMS_ON) : (VEHICLE_PARAMS_OFF);
	SetVehicleParamsEx(vehid, s[ 0 ], s[ 1 ], s[ 2 ], s[ 3 ], s[ 4 ], s[ 5 ], s[ 6 ]);
	return 1;
}

Cmd::Input->bagaznik(playerid, params[])
{
    new vehid = Player(playerid, player_veh);
    if(vehid == INVALID_VEHICLE_ID)
    {
        vehid = GetClosestCar(playerid);
        if(vehid == INVALID_VEHICLE_ID)
	   		return ShowInfo(playerid, red"Nie jesteś w/przy pojeździe.");
	}
	if(!CanPlayerVehicleDrive(playerid, vehid))
		return ShowInfo(playerid, red"Nie możesz używać tego pojazdu.");

    new s[ 7 ];
	GetVehicleParamsEx(vehid, s[ 0 ], s[ 1 ], s[ 2 ], s[ 3 ], s[ 4 ], s[ 5 ], s[ 6 ]);
	s[ 5 ] = !s[ 5 ] ? (VEHICLE_PARAMS_ON) : (VEHICLE_PARAMS_OFF);
	SetVehicleParamsEx(vehid, s[ 0 ], s[ 1 ], s[ 2 ], s[ 3 ], s[ 4 ], s[ 5 ], s[ 6 ]);
	return 1;
}

Cmd::Input->pasy(playerid, params[])
{
    new vehid = Player(playerid, player_veh);
    if(vehid == INVALID_VEHICLE_ID)
        return ShowInfo(playerid, red"Nie jesteś w pojeździe!");
        
    Player(playerid, player_pasy) = !Player(playerid, player_pasy);
    if(Player(playerid, player_option) & option_me)
    {
	    new string[ 100 ];
		format(string, sizeof string,
			"* %s %s pasy.",
			NickName(playerid),
			Player(playerid, player_pasy) ? ("zapina") : ("odpina")
		);
		serwerme(playerid, string);
	}
	else GameTextForPlayer(playerid, Player(playerid, player_pasy) ? ("~n~~n~~n~~n~~n~~n~~r~~h~pasy zapiete") : ("~n~~n~~n~~n~~n~~n~~r~~h~pasy odpiete"), 5000, 5);

	return 1;
}

Cmd::Input->odczep(playerid, params[])
{
    new vehid = Player(playerid, player_veh);
    if(vehid == INVALID_VEHICLE_ID)
        return ShowInfo(playerid, red"Nie jesteś w pojeździe!");
    if(!IsTrailerAttachedToVehicle(vehid))
        return 1;
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        return ShowCMD(playerid, "Musisz być kierowcą, aby użyć tej komendy!");
    
    DetachTrailerFromVehicle(vehid);
    return 1;
}
Cmd::Input->syrena(playerid, params[]) return cmd_kogut(playerid, params);

Cmd::Input->kogut(playerid, params[])
{
    new vehid = Player(playerid, player_veh);
    if(vehid == INVALID_VEHICLE_ID)
        return ShowInfo(playerid, red"Nie jesteś w pojeździe!");
        
	if(!Vehicle(vehid, vehicle_siren) && Vehicle(vehid, vehicle_siren_obj) != INVALID_OBJECT_ID)
	{
	    DestroyObject(Vehicle(vehid, vehicle_siren_obj));
		Vehicle(vehid, vehicle_siren_obj) = INVALID_OBJECT_ID;
	}

	if(!Vehicle(vehid, vehicle_siren))
		return ShowCMD(playerid, "W tym pojeździe nie jest zamontowana syrena!");
		
	InstallSiren(vehid);
	
	if(Vehicle(vehid, vehicle_siren_obj) != INVALID_OBJECT_ID)
		ShowCMD(playerid, "Syrena zamontowana!");
	else
		ShowCMD(playerid, "Syrena zdemontowana!");
	return 1;
}

