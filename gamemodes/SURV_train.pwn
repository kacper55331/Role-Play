#define trening_none    0
#define trening_hantle	1

FuncPub::Train_OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(Tren(playerid, train_time) && Tren(playerid, train_item))
    {
        if(PRESSED(KEY_SECONDARY_ATTACK))
        {
            if(!Tren(playerid, train_type))
            {
				for(new objectid; objectid < Streamer_GetUpperBound(STREAMER_TYPE_OBJECT); objectid++)
				{
				    if(!IsValidDynamicObject(objectid)) continue;
				    if(!Streamer_IsInArrayData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_WORLD_ID, Player(playerid, player_vw))) continue;

					new Float:pos[ 3 ], Float:rot;
					Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_X, pos[ 0 ]);
		    		Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_Y, pos[ 1 ]);
		    		Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_Z, pos[ 2 ]);
		    		Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_R_Z, rot);
		    		if(!IsPlayerInRangeOfPoint(playerid, 2.0, pos[ 0 ], pos[ 1 ], pos[ 2 ])) continue;

		    		switch(Streamer_GetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_MODEL_ID))
		    		{
		    		    case 2915: // hantle
		    		    {
		    		        Tren(playerid, train_type) = trening_hantle;
		    		        Tren(playerid, train_obj) = objectid;
		    		        SetPlayerPos(playerid, pos[ 0 ] - 1.0, pos[ 1 ], pos[ 2 ] + 1.0);
							SetPlayerFacingAngle(playerid, rot);
		    		        FreezePlayer(playerid);
		    		        ApplyAnimation(playerid, "Freeweights", "gym_free_pickup", 1, 0, 0, 0, 1, 0, 1);

							SetPlayerCameraPos(playerid, pos[ 0 ] + 2.3, pos[ 1 ], pos[ 2 ] + 0.3);
							SetPlayerCameraLookAt(playerid, pos[ 0 ], pos[ 1 ], pos[ 2 ] + 0.5);

			    		    //SetTimerEx("podniet", 200, false, "d", playerid); // Animacja
	                    	SetTimerEx("podni", 2000, false, "d", playerid); // Przyczepienie obiektu
							Chat::Output(playerid, SZARY, "Rozpoczełeś trening!");
							break;
		    		    }
		    		}
				}
			}
            else
            {
                SetTimerEx("podnie", 200, false, "d", playerid); // Animacja
                SetTimerEx("podni", 1200, false, "d", playerid); // Przyczepienie obiektu
                SetTimerEx("c_clear", 1300, false, "d", playerid);

				Chat::Output(playerid, SZARY, "Zakończyłeś trening!");
			}
        }
        else if(PRESSED(KEY_SPRINT) && Tren(playerid, train_type) && !Tren(playerid, train_timer))
        {
        	switch(Tren(playerid, train_type))
            {
				case trening_hantle:
				{
					switch( random( 2 ) )
					{
						case 0: ApplyAnimation( playerid, "freeweights", "gym_free_A", 1, 0, 0, 0, 1, 0, 1 );
			  			case 1: ApplyAnimation( playerid, "freeweights", "gym_free_B", 1, 0, 0, 0, 1, 0, 1 );
					}
				}
//            	ApplyAnimation(playerid, "Freeweights", "gym_free_up_smooth", 3.9, 0, 1, 1, 1, 1, 1);
            }
			Tren(playerid, train_timer) = SetTimerEx("podnies", 2100, false, "d", playerid);
            // Góra
        }
        /*else if(RELEASED(KEY_SPRINT) && Tren(playerid, train_type))
        {
            if(Tren(playerid, train_timer))
            {
				switch(Tren(playerid, train_type))
				{
				    case trening_hantle:
						ApplyAnimation(playerid, "Freeweights", "gym_free_down", 1, 0, 0, 0, 1, 0, 1);
				}
				KillTimer(Tren(playerid, train_timer));
				Tren(playerid, train_timer) = 0;
			}
            // Dół
        }*/
    }
	return 1;
}

FuncPub::c_clear(playerid)
{
	Tren(playerid, train_type) = 0;
	Tren(playerid, train_count) = 0;
	return 1;
}

FuncPub::podni(playerid)
{
	if(Tren(playerid, train_type) == trening_hantle)
	{
	    if(Tren(playerid, train_obj) != INVALID_OBJECT_ID)
	    {
	        // Podnoszenie
			SetPlayerAttachedObject(playerid, 5, 2916, 5, 0.045000, 0.037000, 0.017999, 0.000000, 90.000000, 0.000000, 1.000000, 1.000000, 1.000000);
	    	SetPlayerAttachedObject(playerid, 6, 2916, 6, 0.045000, 0.037000, 0.017999, 0.000000, 90.000000, 0.000000, 1.000000, 1.000000, 1.000000);

			new objectid = Tren(playerid, train_obj);
			Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_X, Tren(playerid, train_obj_pos)[ 0 ]);
    		Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_Y, Tren(playerid, train_obj_pos)[ 1 ]);
    		Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_Z, Tren(playerid, train_obj_pos)[ 2 ]);
			Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_R_X, Tren(playerid, train_obj_rpos)[ 0 ]);
    		Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_R_Y, Tren(playerid, train_obj_rpos)[ 1 ]);
    		Streamer_GetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_R_Z, Tren(playerid, train_obj_rpos)[ 2 ]);
            DestroyDynamicObject(Tren(playerid, train_obj));
            Tren(playerid, train_obj) = INVALID_OBJECT_ID;
		}
	    else
	    {
	        // Odkładanie
			RemovePlayerAttachedObject(playerid, 5);
		    RemovePlayerAttachedObject(playerid, 6);
		    
			ClearAnimations(playerid, true);
			SetCameraBehindPlayer(playerid);
			UnFreezePlayer(playerid);

	    	CreateDynamicObject(2915, Tren(playerid, train_obj_pos)[ 0 ], Tren(playerid, train_obj_pos)[ 1 ], Tren(playerid, train_obj_pos)[ 2 ], Tren(playerid, train_obj_rpos)[ 0 ], Tren(playerid, train_obj_rpos)[ 1 ], Tren(playerid, train_obj_rpos)[ 2 ], Player(playerid, player_vw));
		}
	}
	return 1;
}

FuncPub::podnie(playerid) // Odkładanie
{
	if(Tren(playerid, train_type) == trening_hantle)
	{
		ApplyAnimation(playerid, "Freeweights", "gym_free_putdown", 4.1, 0, 1, 1, 1, 1, 1);
	}
	return 1;
}

FuncPub::podniet(playerid) // Podnoszenie
{
	if(Tren(playerid, train_type) == trening_hantle)
	{
		ApplyAnimation(playerid, "Freeweights", "gym_free_pickup", 4.1, 0, 1, 1, 1, 1, 1);
	}
	return 1;
}

FuncPub::podnies(playerid)
{
	Tren(playerid, train_count)++;
	if(Tren(playerid, train_type) == trening_hantle)
	{
		ApplyAnimation(playerid, "Freeweights", "gym_free_down", 1, 0, 0, 0, 1, 0, 1);
		//Player(playerid, kondycja) -= 5.0;
	}
	//TreningTimer[playerid] = 0;
	//Player(playerid, max_kondycja) += 0.5;
//	SetProgressBarMaxValue(Kondycja[playerid], Player(playerid, max_kondycja));

/*	Trening[playerid]--;
	if(!Trening[playerid])
	{
		GameTextForPlayer(playerid,"~r~Trening na dzis zakonczony!", 3000, 3);

	    SetTimerEx("podnie", 200, 0, "dd", playerid, GetPVarInt(playerid, "trening-type")); // Animacja
     	SetTimerEx("podni", 1200, 0, "ddd", playerid, GetPVarInt(playerid, "trening-obj"), GetPVarInt(playerid, "trening-type")); // Przyczepienie obiektu

		DeletePVar(playerid, "trening-type");
		//Player(playerid, sila) += 10;
	}*/
	return 1;
}

FuncPub::ClearTrening(playerid)
{
    for(new eTrain:i; i < eTrain; i++)
    	Tren(playerid, i) = 0;
    Tren(playerid, train_obj) 		= INVALID_OBJECT_ID;
    return 1;
}
