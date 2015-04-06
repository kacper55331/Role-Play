#include <a_samp>
#include <all>

#include "SURV_makro.pwn"

// ----------------------------------------------------------------------------------------------------
// Constants
// ----------------------------------------------------------------------------------------------------

#undef  MAX_PLAYERS
#undef  MAX_PLAYER_NAME
#undef  MAX_OBJECTS
#undef  MAX_3DTEXT_PLAYER
#undef  MAX_PICKUPS
#undef  MAX_VEHICLES

#if OFFICIAL
	#define MAX_PLAYERS			110		//                                      
	#define MAX_DOORS			300		// Maks ilość drzwi
	#define MAX_OBJECTS			10000	// Maks ilość obiektów
	#define MAX_VEHICLES        1000	// Maks ilość pojazdów                  
#else
	#define MAX_PLAYERS			26		//                                      
	#define MAX_DOORS			150		// Maks ilość drzwi
	#define MAX_OBJECTS			500		// Maks ilość obiektów
	#define MAX_VEHICLES        200		// Maks ilość pojazdów                  
#endif

#define MAX_ITEMS			9+1		// Maks ilość itemów w TD na stronie | 1-9
#define MAX_SELECT          10+1    // Maks ilość postaci w TD na stronie
#define MAX_ANIMS			170     // Maks ilość animacji
#define MAX_GROUPS			5+1		// Maks ilość slotów grup na gracza
#define MAX_BUS				35		// Maks ilość przystanków
#define MAX_3DTEXT_PLAYER	100		// Maks ilość 3dtextów na vw 				1024
#define MAX_PICKUPS         MAX_DOORS + 10     // Maks ilość pickupów                      4096
#define MAX_STATION         10      // Maks ilość stacji paliw
#define MAX_ICONS           100		// Maks ilość ikon
#define MAX_STREET          20      // Maks ilość ulic
#define MAX_RADAR           5       // Maks ilość radarów
#define MAX_ZONES           66      // Maks ilość stref
#define MAX_GRUNT           100
#define MAX_KURIER          5+1     // Maks ilość przewożonych itemów
#define MAX_ATTACH_VEHICLE  32      // Maks ilość obiektów przyczepionych do pojazdu
#define MAX_SKINS           130     // Maks ilość skinów do kupienia
#define MAX_CHECK           50
#define MAX_WEAPON          2
#define MAX_BLOKADA         10
#define MAX_SMIECI          5

#define MAX_ITEM_NAME       24      // Maksymalna długość nazwy przedmiotu
#define MAX_PLAYER_NAME		24
#define MAX_GROUP_NAME      32

// ----------------------------------------------------------------------------------------------------
// Macros
// ----------------------------------------------------------------------------------------------------

#define IN_NAME 			"Serwer Role Play"	// Nazwa projektu
#define IN_BAZA       		"connect.txt"   // Plik konfiguracyjny
#define IN_CITY             "LS"    		// Prefix miasta
#define IN_PREF             "ipb_"

#define Player(%1,%2)		PlayerData[%1][%2]
#define Vehicle(%1,%2)		VehicleData[%1][%2]
#define Door(%1,%2)			DoorData[%1][%2]
#define Setting(%1)			SettingData[%1]
#if STREAMER
	#define Object(%1,%2)		ObjectData[%1][%2]
#else
	#define Object(%1,%2,%3)	ObjectData[%1][%2][%3]
#endif
#define Item(%1,%2,%3)		ItemData[%1][%2][%3]
#define Group(%1,%2,%3)		GroupData[%1][%2][%3]
#define Text(%1,%2,%3)      TextData[%1][%2][%3]
#define Bus(%1,%2)			BusData[%1][%2]
#define Attach(%1,%2,%3)    AttachData[%1][%2][%3]
#define Bankomat(%1,%2)		BankData[%1][%2]
#define Offer(%1,%2)        OfferData[%1][%2]
#define Station(%1,%2)      StationData[%1][%2]
#define Pickup(%1,%2)		PickupData[%1][%2]
#define Anim(%1,%2)			AnimData[%1][%2]
#define Pc(%1,%2)			PcData[%1][%2]
#define NPC(%1,%2)          NpcData[%1][%2]
#define Street(%1,%2)		StreetData[%1][%2]
#define Radar(%1,%2)		RadarData[%1][%2]
#define Select(%1,%2,%3)    SelectData[%1][%2][%3]
#define Create(%1,%2)       CreateData[%1][%2]
#define Zone(%1,%2)         ZoneData[%1][%2]
#define Repair(%1,%2)       RepairData[%1][%2]
#define Kurier(%1,%2,%3)    KurierData[%1][%2][%3]
#define Race(%1,%2,%3)		RaceData[%1][%2][%3]
#define Grunt(%1,%2)        GruntData[%1][%2]
#define Skin(%1,%2)         SkinData[%1][%2]
#define Nark(%1,%2)         NarkData[%1][%2]
#define Taxi(%1,%2)         TaxiData[%1][%2]
#define Weapon(%1,%2,%3)	WeaponData[%1][%2][%3]
#define Phone(%1,%2)        PhoneData[%1][%2]
#define Tren(%1,%2)         TrainingData[%1][%2]

#define formatex(%1,%2,%3,%4) new %1[%2];format(%1, %2, %3, %4)
#define value_zero 			2.5
#define time_repair         100
#define max_c 				50
#define opis_color 			0xC2A2DAFF
#define timer_time  		500
#define hotdog_model        1342

#define ShowInfo(%1,%2)		Dialog::Output(%1, 999, DIALOG_STYLE_MSGBOX, IN_HEAD" "white"» "grey"Informacja", %2, "OK", "")
#define ShowCMD(%1,%2) 		Chat::Output(%1, SZARY, %2)
#define ShowList(%1,%2)		Dialog::Output(%1, 999, DIALOG_STYLE_LIST, IN_HEAD" "white"» "grey"Informacja", %2, "OK", "")
#define serwerdo(%1,%2)		SendClientMessageEx(14.0, %1, %2, COLOR_DO, COLOR_DO2, COLOR_DO3, COLOR_DO4, COLOR_DO5)
#define serwerme(%1,%2)		SendClientMessageEx(14.0, %1, %2, COLOR_PURPLE, COLOR_PURPLE2, COLOR_PURPLE3, COLOR_PURPLE4, COLOR_PURPLE5)
#define DIN(%1,%2) 			strcmp(%1, %2, true) == 0
//strfind(%1, %2, true) != -1
#define DestroyDialog(%1) 	Dialog::Output(%1, -1, DIALOG_STYLE_LIST, IN_HEAD, "", "okey", "")

#if !defined TextDrawSetPreviewRot
    #error Version 0.3x or higher of SA:MP Server requiered
#endif

#define player_nick_def     0xFFFFFFAA
#define player_nick_prem    0xE6D265AA
#define player_nick_red     0xFF0000AA
#define player_nick_green   0x33AA33AA

#define block_none          0
#define block_norun         1
#define block_noveh         2
#define block_nogun         4
#define block_noooc         8
#define block_ban           16
#define block_block         32
#define block_ck            64

#define kara_none           0
#define kara_norun          1
#define kara_noveh          2
#define kara_nogun          3
#define kara_noooc          4
#define kara_ban            5
#define kara_block          6
#define kara_warn           7
#define kara_kick       	8
#define kara_jail           9

#define option_none         0
#define option_me           1
#define option_panor        2
#define option_news         4
#define option_pm           8
#define option_freeze       16
#define option_hand         32 // true - lewa, false - prawa
#define option_shooting     64
#define option_textdraw     128
#define option_connect      256 // Locked
#define option_vehicle      512 // Pojazd z /veh
#define option_anim_k       1024
#define option_anim_m       2048
#define option_fight        4096

#define job_none            0
#define job_road          	1
#define job_road2           2
#define job_mechanic        3
#define job_hotdog        	4
#define job_smieciarz    	5
#define job_fisher       	6
#define job_kurier          7
#define job_newspaper       8

#define dark_none           0
#define dark_camera         1
#define dark_spawn          2
#define dark_login          3
#define dark_login2         4
#define dark_door_out		5
#define dark_door_in        6
#define dark_hotel          7
#define dark_character      8
#define dark_kick           9
#define dark_door_in2       10
#define dark_door_out2      11

#define sex_none            0
#define sex_men             1
#define sex_woman           2

// Sounds
#define heart_sound         1
#define heart_sound_fast    2
#define doors_sound_lock    3, 4, 5, 6
#define itm_sound_ammo_down	7
#define itm_sound_ammo_up   8, 9, 10
#define itm_sound_cloth_down 11, 12, 13
#define itm_sound_cloth_up  14, 15, 16
#define itm_sound_gen_down  17
#define itm_sound_gen_up    18, 19, 20, 21
#define sound_info          22
#define itm_sound_male_down 25
#define itm_sound_male_up   26
#define itm_sound_big_down  29
#define itm_sound_big_up    30
#define itm_sound_gunssmall_down 27
#define itm_sound_gunssmall_up 28
#define itm_grenade_down 	23
#define itm_grenade_up 		24
#define call_sound          31
#define call_sound_end      32
#define call_sound_mute     33
#define call_sound_sms     	34
#define lsd_sound           35, 36, 37, 38, 39
#define pistol_reload_sound 40
#define ak_reload_sound     41, 42, 43, 44, 45, 46, 47
#define rifle_reload_sound  48
#define uzi_reload_sound    49, 50, 51, 52
#define engine_sound_start  53
#define engine_sound_started 54
#define vehicle_sound_alarm 55
#define gui_button1_sound   56
#define gui_button2_sound   57
#define doors_sound_open    58
#define veh_sound_alarm		59
#define achiv_sound			60

// ----------------------------------------------------------------------------------------------------
// Enumerations
// ----------------------------------------------------------------------------------------------------

enum ePlayers {
		   player_guid, player_gname[ 120 ],	// GUID
	       player_uid, player_name[ MAX_PLAYER_NAME ], // UID, name
	  bool:player_logged, bool:player_spawned, bool:player_freezed, // Zalogowany, zrespiony, zamrożony
	 Float:player_position[ 4 ], player_int, player_vw, // Pozycja gracza (x, y, z, a)
		   player_visits, player_timehere[ 2 ], // Wizyty na serwerze [ 0 ] - czas ogolnie, [ 1 ] - czas teraz
	       player_block,                        // Rodzaje blokad
		   player_bw, player_aj,                // Śmierć, Jail
	 Float:player_cash,                         // Gotówka
		   player_skin,                         // Skin
		   player_sex,                          // Płeć
		   player_height,                       // Wzrost
		   player_age,                          // Wiek
	 Float:player_hp, Float:player_armour,      // HP gracza
		   player_adminlvl,                     // Adminlvl
		   player_adminperm,                    // Permy dla admina
	       player_lang,							// Nauczone języki
	       player_option,                       // Dodatki (me, SN, Priv, Panor)
	       player_fight,                        // Styl walki
	       player_stamina,                      // Siła
		   player_achiv,						// Achivmenty
		   player_drunklvl,                     // Poziom upicia
		   player_druglvl,
		   player_pkt,
	  bool:player_premium,                      // Konto premium
	  bool:player_trusted,                      // Zaufany gracz
	  bool:player_disabled,                     // Wyłączenie antycheata
	  bool:player_reload_anims,                 // Przeładowanie animek
	  bool:player_pasy,
	  bool:player_rekawiczki,

	 	   player_shot_body[ 10 ],

		   player_aim,                          // Celowanie
		   player_aim_object,                   // Celowanie (obiekt)
	  bool:player_crouch,                       // Czy gracz aktualnie kuca
//	  bool:player_tlumik,
		   
	       player_anim_chat,                    // Animacja chatu
	  bool:player_anim,                         // Animacja podczas rozmowy

		   player_opis,                         // UID opisu
	Text3D:player_opis_id,                      // ID 3dtextu nicku

	 	   player_re,                          	// /w odpowiedź
	 	   player_drug,
	 	   player_drug_timer,
		   player_pulse,                        // Puls
		   player_blood, player_blooding, 		// Krew
		   player_hungry,                       // Głód
		   
		   player_jail,                         // Unix Time Jaila
		   player_jail_timer,                   // Timer Jaila
		   
		   player_ammo,
		   
		   player_job,                          // Praca gracza
//	 Float:player_pack_pos[ 3 ],                // Pozycja paczki

	       player_dialog,                       // ID dialogu
	       player_blockade[ MAX_BLOKADA ],

	       player_door,                         // ID drzwi
		   player_door_id,                      // ID wybranych drzwi
		   player_door_sound,                   // Muzyka wew drzwi
		   player_door_out_sound[ MAX_DOORS ],  // Muzyka na zew drzwi
		   player_hotel,                        // UID aktualnego hotelu
	  bool:player_hotel_close,
		   player_door_timer,                   // Timer TD drzwi
		   player_login_timer,
		   player_streetid,                     // ID ulicy
PlayerText:player_door_td[ 3 ],                 // TD z drzwiami
PlayerText:player_street,                       // TD z nazwą ulicy
PlayerText:player_radar[ 2 ],                   // TD z licznikiem prędkości

	Text3D:player_tag,                          // ID 3dtextu nicku
		   player_color,                        // Kolor 3d nicku
		   player_ip[ 18 ],                     // IP gracza

		   player_vehicle_uid,                  // UID wybranego auta
	       player_veh,                          // ID pojazdu
	       player_veh_icon[ MAX_ICONS ],        // Ikony pojazdów
		   player_engine_sound[ MAX_PLAYERS ],  // Dźwięk odpalania silnika
		   player_veh_sound,                    // Muzyka w pojeździe
		   player_veh_timer,                    // Timer do odpalania silnika
PlayerText:player_veh_td,                       // TD z info o pojeździe

		   player_heart_sound, player_heart_sound_fast, // Odgłos serca
		   player_connect_sound,                // Muzyka przy połączeniu
	  bool:player_audio,                        // Czy ma wczytane pliki audio plugina
		   
		   player_afktime[ 3 ],                 // Czas AFK [ 0 ] - czas teraz, [ 1 ] - czas ogólnie, [ 2 ] - czas podczas wizyty
		   player_screen,                       // Czas w sec zmiany koloru nicku
		   
		   player_busid,                        // Aktualny przystanek gracza
		   player_bus_timer,                    // Timer dot. busa
		   player_cash_timer,                   // Znikanie TD z pieniędzmi
		   
PlayerText:player_infos,                        // TD informacyjny
PlayerText:player_friend,                       // TD z przyjacielem
PlayerText:player_cash_td,                      // TD z groszami
PlayerText:player_cash_add,                     // TD z dodatkiem kasy

		   player_item_site,                    // Strona z przedmiotami
PlayerText:player_item_td[ 3 ],                 // TextDraw przedmiotów
		   player_used_weapon,
		   player_item_selected,                // Ilość wybranych przedmiotów
		   player_skuty,         				// Czy gracz jest skuty
	  bool:player_reload,                       // Przeładowanie broni
	  bool:player_rolki,                        // Używanie rolek
		   player_mask,                         // Maska (UID Przedmiotu)
	  bool:player_worek,                        // Worek
	  bool:player_knebel,                       // Knebel
		   player_cdplayer,                     // CD player włączony
		   player_cdplayer_sound,               // HandleID CD-Playera

		   player_cam_timer,                    // Timer z kamerami
		   player_cam,                          // Aktualna kamera
	       player_dark,                         // Ściemnienie
	       player_friends,
	       
	       player_mandat,                       // ID radaru z mandatem
		   
		   player_select_uid,                   // UID wybranego gracza
		   player_select_page,                  // Strona z graczami
		   
		   player_nitro,                        // Obiekt nitra
		   player_race,
		   player_race_max,
		   
		   player_achiv_timer,
		   player_npc,
		   
		   player_spec,
		   player_spectated,
		   
		   player_fish,
		   player_fish_timer,
		   
		   player_trash,
		   
		   player_duty,                         // Slot grupy z duty
		   player_admin_id,
	  bool:player_aduty,                        // Służba admina
		   
		   player_mobile_sound_call,            // Głos dzwonienia (bii.. bii..)
		   player_mobile_sound_called[ MAX_PLAYERS ], // Dźwięk dzwonka
		   player_mobile_timer,                 // Timer
//	 Float:player_mobile_cash,                  // Kasa w telefonie
	 
	 Float:player_veh_dist,                     // Ogólny przebieg pojazdami
	 Float:player_dist,                         // Ogólny przebieg na piechotę
	 
	 Float:player_obj_pos[ 6 ],
	 Float:player_obj_dist,
	 
	 Float:player_veh_hp,
	 
PlayerText:player_fuel_td[ 4 ],                 // Tankowanie
		   player_fuel_timer,                   // Timer tankowania
		   
		   player_ulotki,                       // Ilość ulotek
		   
PlayerText:player_kara[ 2 ],                    // TextDraw dot. kar
		   player_kara_timer,                   // Timer do kary
		   
PlayerText:player_achiv_text,
		   
		   player_cmds,                         // Ilość wpisanych komend
		   player_texts,                        // Ilość wypowiedzi
		   
		   player_cmd_timer,
		   player_text_timer,
		   
		   player_killed,                       // Ilość zabójstw
		   player_killed_time,                  // Czas pomiędzy zabójstwami
		   
		   player_selected_object,

	Text3D:player_spray,                        // ID 3dtextu malowania
};

enum eSettings {
	       setting_globtimer,                   // Timer co 1s
	       setting_opttimer,                    // Timer co 100ms
	       
	       setting_mysql,                       // Połączenie z MySQL
	       setting_query,                       // Ilość zapytań
	       setting_uptime,                      // Czas od włączenia

	       setting_weather,                     // Pogoda na serwerze
	       setting_raports,                     // Ilość nowych raportów
	       setting_packet,
	       
	 Float:setting_gym[ 2 ],
	       
	       // Socket
	Socket:setting_socket,
	       
	  bool:setting_audiotranfer,                // Czy trwa transfer plików audio
	  Text:setting_td_box[ 2 ],                 // Paronamiczny ekran
	  Text:setting_td_item[ 7 ],                // Przedmioty box
	  Text:setting_silnik,                      // TextDraw dot. odpalania silnika
	  Text:setting_sn[ 2 ],                     // TextDraw dot. radia
	  Text:setting_black,                       // Czarny ekran
	  Text:setting_red,                         // Czerwony ekran
	  
	  Text:setting_admin_head,                  // Nagłówek
	  Text:setting_admin_box[ 2 ],              // Boxy
	  Text:setting_admin_exit,                  // Klawisz "exit"
	  Text:setting_admin_report,                // Klawisz "raporty"
	  Text:setting_admin_duty[ 2 ],             // Klawisz służby
	  
	  Text:setting_fuel_td[ 8 ],                // Tankowanie
	  Text:setting_selected_bg,                 // BG tła wyboru postaci
	  Text:setting_selected[ 4 ],               // Menu wyboru postaci
	  
	  Text:setting_achiv[ 2 ],
	  
	  Text:setting_radar[ 3 ],                  // Limit prędkości
	  
	  Text:setting_group_background[ MAX_GROUPS ],
	  Text:setting_group_info[ MAX_GROUPS ],
	  Text:setting_group_veh[ MAX_GROUPS ],
	  Text:setting_group_duty[ MAX_GROUPS ],
	  Text:setting_group_duty_on[ MAX_GROUPS ],
	  Text:setting_group_online[ MAX_GROUPS ],
	  Text:setting_group_magazyn[ MAX_GROUPS ],
	  Text:setting_group_out[ 2 ],

	  	   // MySQL
	 Float:setting_bank,                        // Opłata za używanie bankomatu
	 Float:setting_aj[ 3 ],                     // Pozycja Jaila (x, y, z)
	 
	 Float:setting_r_pos[ 4 ],                  // Pozycja wybierałki (x, y, z, a)
	 Float:setting_r_cam[ 6 ],                  // Pozycja kamery wybierałki (x, y, z, x2, y2, z2)

	 Float:setting_veh_pos[ 4 ],
}

/*ALTER TABLE  `surv_vehicles` ADD  `block` VARCHAR( 16 ) NOT NULL AFTER  `siren` ,
ADD  `block_reason` VARCHAR( 64 ) NOT NULL DEFAULT  'NULL' AFTER  `block`

ALTER TABLE  `surv_players` ADD  `pkt` INT NOT NULL DEFAULT  '0' AFTER  `opis`*/
enum eVehicles {
	       vehicle_uid,                         // UID pojazdu
	       vehicle_model,                       // Model pojazdu
	       vehicle_owner[ 2 ],                  // Właściciel pojazdu
	       vehicle_name[ 64 ],
	 Float:vehicle_position[ 4 ], vehicle_vw, vehicle_int, // Pozycja zaparkowanego pojazdu (x, y, z, a)
	       vehicle_color[ 2 ],                  // Kolor pojazdu
	       vehicle_damage[ 4 ],                 // Uszkodzenia
	 Float:vehicle_fuel, vehicle_fuel_type,     // Paliwo
	 Float:vehicle_hp,                          // HP pojazdu
	 Float:vehicle_distance,                    // Przebieg
		   vehicle_plate[ 32 ],                 // Rejestracja
		   vehicle_option,                      // Opcje pojazdu
	 Float:vehicle_block,                       // Zablokowane koło
		   vehicle_block_reason[ 64 ],          // Powód zablokowanego koła
		   
		   vehicle_siren,                       // Syrena na dachu
		   vehicle_mod[ 13 ],                   // Tuning
		   vehicle_pj,                          // Paintjob
	 Float:vehicle_tire[ 4 ],                   // Opony pojazdu (Front-Left, Back-Left, Front-Right and Back-Right)

	 Float:vehicle_act_position[ 3 ],           // Aktualna pozycja pojazdu
		   vehicle_vehID,                       // SAMPID pojazdu
		   
		   vehicle_attach[ 9 ],                 // Obiekty przyczepiane do pojazdu
		   
	  bool:vehicle_engine,                      // Status silnika
	  bool:vehicle_lock,                        // Status drzwi
	  bool:vehicle_sound,                       // Muzyka w środku
		   vehicle_url[ 64 ],                	// Adres do piosenki
		   vehicle_light,
		   
		   vehicle_attach_ex[ MAX_ATTACH_VEHICLE ],
		   
		   vehicle_blink[ 6 ],                  // Światełka awaryjne
		   vehicle_neon,                        // ID neonu
		   vehicle_attached,                    // UID przyczepionych syfów
	  bool:vehicle_ac,
		   
		   vehicle_lights_timer,                // Timer do świecenia
		   vehicle_opis,
	Text3D:vehicle_opis_id,
		   vehicle_siren_obj,
		   
		   vehicle_empty_timer,
}

enum eDoors {
	       door_uid,							// UID drzwi
	       door_name[ MAX_ITEM_NAME ],          // Nazwa drzwi
	       door_number[ 5 ], door_street,       // Ulica i numer domu
	  bool:door_close,                          // Status drzwi
		   door_owner[ 2 ],                     // Właściciele - Typ, ID
	 Float:door_pay,                            // Opłata za wejście
	 Float:door_in_pos[ 4 ], door_in_vw, door_in_int, // Pozycja wew (x, y, z, a)
	 Float:door_out_pos[ 4 ], door_out_vw, door_out_int, // Pozycja zew (x, y, z, a)
		   door_pickup,                         // Model pickupu
		   door_to,
		   door_option,                         // Opcje drzwi
		   
	  bool:door_sound_out,                      // Muzyka na zew
		   door_sound_url[ 64 ],                // Adres do piosenki
		   door_pickupID,                       // SAMPID pickupu
}
#if STREAMER
	enum eObjects {
			   obj_objID,
		 Float:obj_position[ 3 ], Float:obj_positionrot[ 3 ], // Pozycja obiektu (x, y, z)
		 Float:obj_positiongate[ 3 ], Float:obj_positiongaterot[ 3 ], Float:obj_gaterange, bool:obj_gatestatus, // Pozycja bramy (x, y, z)
			   obj_owner[ 2 ],                      // Właściciele - Typ, ID
	}
#else
	enum eObjects {
			   obj_uid,                             // UID obiektu
			   obj_mapid,
			   obj_model,                           // Model obiektu
		 Float:obj_position[ 3 ], Float:obj_positionrot[ 3 ], // Pozycja obiektu (x, y, z)
		 Float:obj_positiongate[ 3 ], Float:obj_positiongaterot[ 3 ], Float:obj_gaterange, bool:obj_gatestatus, // Pozycja bramy (x, y, z)
			   obj_owner[ 2 ],                      // Właściciele - Typ, ID

			   obj_objID,                           // SAMPID obiektu
	}
#endif

enum eItems {
		   item_uid,                        	// UID itemu
		   item_name[ MAX_ITEM_NAME ],          // Nazwa itemu
		   item_type,                           // Typ itemu
		   item_value[ 2 ], Float:item_value3,  // Wartości przedmiotu
	  bool:item_favorite,                       // Ulubiony
	  	   item_used,                           // Używany (1 - używany, 2 - wybrany)
}

enum eGroups {
		   group_uid,                           // UID grupy
		   group_name[ MAX_GROUP_NAME ],        // Nazwa grupy
		   group_tag[ 5 ],                      // TAG grupy
		   group_type,                          // Typ grupy
		   group_color,                   		// Kolor grupy
		   group_rankname[ MAX_ITEM_NAME ],     // Nazwa rangi
		   group_can,                      		// Możliwość członka
		   group_option,                        // Opcje dla grupy
		   group_skin,
	  
	  	   group_duty,                          // Czas służby
PlayerText:group_text,                          // Textdraw dot. nazwy grupy
}

enum eBus {
		   bus_uid,                             // UID busa
		   bus_name[ 32 ],                      // Nazwa busa
		   bus_street,                          // ID ulicy
	 Float:bus_pos[ 3 ],                        // Pozycja
}

enum eText {
		   text_uid,                            // UID 3dtextu
		   text_owner[ 2 ],                     // Właściciele - Typ, ID
	 Float:text_pos[ 3 ],                       // Pozycja (x, y, z)
		   
PlayerText3D:text_textID,                       // SAMPID 3dtextu
}

enum eAttachObject {
		   attach_itemuid,                      // UID przedmiotu
		   attach_model,                        // Model
		   attach_bone,                         // Część ciała
	 Float:attach_pos[ 3 ],                     // Pozycja (x, y, z)
	 Float:attach_rpos[ 3 ],                    // Rotacja (x, y, z)
	 Float:attach_apos[ 3 ],                    // Powiększenie (x, y, z)
}

enum eBank {
		   bank_number,                         // Numer konta
		   bank_name[ 32 ],						// Nazwa konta
	 Float:bank_cash,                           // Kasa
		   bank_owner,                          // Właściciel bankomatu
	 Float:bank_value[ 2 ],                     // Ceny
	  bool:bank_bankomate,                      // Bankomat
}

enum eOffer {
		   offer_player,                        // ID gracza
		   offer_type,                          // Typ oferty
	 Float:offer_cash,                          // Cena oferty
		   offer_value[ 2 ], Float:offer_value3, offer_value4[ 64 ], // Wartości oferty
	  bool:offer_active,                        // Aktywna oferta
}

enum eStation {
		   station_uid,                         // UID stacji
	 Float:station_pos[ 3 ],                    // Pozycja (x, y, z)
	 Float:station_range,                       // Wielkość
		   station_owner[ 2 ],                  // Właściele
	 Float:station_fuel,                        // Ilość paliwa
	 Float:station_value,                  		// Przelicznik
}

enum ePickup {
		   pickup_uid,                          // UID pickupa
		   pickup_type,                         // Typ
		   pickup_model,                        // Model
	 Float:pickup_pos[ 3 ],                     // Pozycja (x, y, z)
		   pickup_vw,                           // VW
		   
		   pickup_owner[ 2 ],                   // Właściciel pickupa
		   
		   pickup_sampID,                       // sampID pickupa
}

enum eAnims {
	       anim_uid,                            // UID animacji
	       anim_name[ 45 ],                     // Nazwa
	       anim_animlib[ 45 ],                  // Biblioteka
	       anim_animname[ 45 ],                 // Nazwa w bibliotece
	 Float:anim_speed,                          // Prędkość
	       anim_opt[ 5 ],                       // Parametry
}

enum ePC {
	       pc_user, 							// UID zalogowanego konta
	       pc_perm,                             // Uprawnienia
	       pc_typ,                              // PD/MC
	       
	       pc_type,                             // Typ poszukiwań
	       //pc_player, 							// UID wybranego gracza
	       //pc_kart, 							// UID wybranego wpisu
	       
	       pc_value[ 2 ],
}

enum eStreet {
	       street_uid,                          // UID ulicy
	       street_name[ 32 ],                   // Nazwa ulicy
	       street_limit,
	       street_flag,
	 Float:street_pos[ 4 ],                     // Pozycja ulicy (minx, miny, maxx, maxy)
}

enum eRadar {
	       radar_uid,                           // UID radaru
	       radar_street,                        // UID ulicy
	 Float:radar_speed,                         // Prędkość
	 Float:radar_range,                         // range radaru
	 Float:radar_pos[ 3 ],                      // Pozycja (x, y, z)
}

enum eSelect {
	       select_uid,                          // UID postaci
	       select_name[ MAX_PLAYER_NAME ],      // Nick postaci
	 Float:select_cash,                         // Kasa
	       select_skin,                         // Skin
	       select_sex,                          // Płeć
	       select_block,                        // Blokady
PlayerText:select_td,                           // Textdraw
}

enum eZone {
	       zone_uid,                            // UID strefy
	       zone_name[ 27 ],                     // Nazwa strefy
	       zone_group,                          // UID właściciela
	 Float:zone_pos[ 4 ],                       // Pozycja
	       zone_color,                          // Kolor
	       zone_flag,
	       
	       zone_id,                             // Samp ID CreateGangZone
}

enum eAdminLvl {
	       admin_color,                    		// Kolor
	       admin_tag[ 4 ],                    	// TAG rangi
	       admin_name[ 32 ],                    // Nazwa rangi
}

enum eCreate {
	       create_sid[ 32 ],                    // session ID
	       create_cat,                          // Kategoria
	       create_type,                         // Typ
	       create_value[ 3 ],                   // Wartości
	 Float:create_value2,                       // Wartość Float
	       create_value3[ 32 ],                 // Wartość string
	       create_name[ 64 ],                   // Nazwa
	       
	 Float:create_pos[ 5 ],                     // x,y, x1,x2, z
}

enum eRepair {
	       repair_player,                       // ID gracza
	       repair_type,                         // Typ naprawy
	 Float:repair_cash,                         // Kasa za naprawę
	       repair_value[ 5 ],                   // Wartości
	       repair_time,                         // Czas do końca
	 Float:repair_value2,
}

enum eTune {
	       comp_id,                             // ID komponentu
	       comp_name[ 32 ],                     // Nazwa
	       comp_typid,                          // Rodzaj
}

enum eInVeh {
	       in_name[ 32 ],
	       in_bit,
}

enum eKurier {
	       pack_id,                         	// ID paczki
	       pack_doorid,                     	// ID drzwi
}

enum ePickModel {
	       model_id,
	       model_name[ 32 ],
}

enum eGrunt {
	       grunt_uid,
	       grunt_owner[ 2 ],
	       grunt_flag,
	 Float:grunt_pos[ 5 ],
}

enum eNPC {
	       npc_name[ MAX_PLAYER_NAME ],
	       npc_file[ 32 ],
	       npc_vehicle,
	       npc_skin,
	       
	       npc_function,
	       npc_opis[ 126 ],
	       
	       Float:npc_pos[ 4 ],
	       npc_door,

	       npc_playerid,
	       
	       npc_timer,
}

enum eNPC_message {
	       msg_function,
	       msg_text[ 126 ],
}

enum eLicense {
	       lic_name[ 32 ],
	       lic_group,
	 Float:lic_price,
	 Float:lic_price_before,
}

enum eWeapon {
	       weapon_id,
	 Float:weapon_posX,
	 Float:weapon_posY,
	 Float:weapon_posZ,
	 Float:weapon_posrX,
	 Float:weapon_posrY,
	 Float:weapon_posrZ,
	       weapon_body,
}

enum eSkins {
	       skin_uid,
	       skin_model,
	       skin_sex,
	 Float:skin_price,
}

enum eNark {
	       nark_buch,
	       nark_druglvl,
}

enum eTaxi {
	       taxi_player,
	       taxi_group,
	 Float:taxi_price,
	 Float:taxi_dist,
}

enum eJobs {
	       job_name[ 32 ],
//	 Float:job_price,
//	       job_group,
}

enum eRace {
	       race_uid,
	 Float:race_pos[ 3 ],
}

enum ePlayerWeapon {
	       weapon_uid,
	       weapon_name[ MAX_ITEM_NAME ],
	       weapon_model,
	       weapon_ammo,
	       weapon_flag,
}

enum eFish {
	       fish_name[ MAX_ITEM_NAME ],  // Nazwa
	       fish_weight[ 2 ],            // Waga (od do)
	 Float:fish_cost,                   // Cena za gram
	  bool:fish_boat,                   // Dozwolone na łodzi
}

enum eAchiv {
	       achiv_bit,
	       achiv_name[ MAX_ITEM_NAME ],
	       achiv_gp,
}

enum eQuest {
	       quest_pyt[ 64 ],
	       quest_a[ 64 ],
	       quest_b[ 64 ],
	       quest_c[ 64 ],
	       quest_good,
}

enum eFightStyle {
	       fight_id,
	       fight_name[ 16 ],
}

enum ePhone {
	       phone_uid,
	       phone_number,        // Numer telefonu
	 Float:phone_cash,          // Kasa na koncie
	       phone_to,            // Numer do którego dzwonimy
	       phone_to_name[ MAX_PLAYER_NAME ],
	       phone_time,          // Czas połączenia
	       phone_option,        // Opcje
	       
	       phone_incoming,      // Próbujący się połączyć
	       phone_call_uid,
}

enum eRing {
	       ring_id,             // Sound ID
	       ring_type,           // typ (0 - ring, 1 - sms)
	       ring_name[ 64 ],     // Sound name
}

enum eTrain {
	       train_item,
	       train_group,
	       train_time,
	       train_obj,
	       train_type,
	       train_count,
	       
	       train_timer,
	       
	       Float:train_obj_pos[ 3 ],
	       Float:train_obj_rpos[ 3 ],
}
// ----------------------------------------------------------------------------------------------------
// Variables
// ----------------------------------------------------------------------------------------------------

stock
			TrainingData[ MAX_PLAYERS ][ eTrain ],
			
			VehicleData[ MAX_VEHICLES ][ eVehicles ],
			StationData[ MAX_STATION ][ eStation ],
			SettingData[ eSettings ],

	       	AttachData[ MAX_PLAYERS ][ MAX_PLAYER_ATTACHED_OBJECTS ][ eAttachObject ],
			#if STREAMER
				ObjectData[ MAX_OBJECTS ][ eObjects ],
			#else
	       		ObjectData[ MAX_PLAYERS ][ MAX_OBJECTS ][ eObjects ],
			#endif
			WeaponData[ MAX_PLAYERS ][ MAX_WEAPON ][ ePlayerWeapon ],
			SelectData[ MAX_PLAYERS ][ MAX_SELECT ][ eSelect ],
			KurierData[ MAX_PLAYERS ][ MAX_KURIER ][ eKurier ],
			PlayerData[ MAX_PLAYERS ][ ePlayers ],
			PickupData[ MAX_PICKUPS ][ ePickup ],
			CreateData[ MAX_PLAYERS ][ eCreate ],
			RepairData[ MAX_PLAYERS ][ eRepair ],
			StreetData[ MAX_STREET ][ eStreet ],

			GroupData[ MAX_PLAYERS ][ MAX_GROUPS ][ eGroups ],
			OfferData[ MAX_PLAYERS ][ eOffer ],
			PhoneData[ MAX_PLAYERS ][ ePhone ],
			RadarData[ MAX_RADAR ][ eRadar ],
			GruntData[ MAX_GRUNT ][ eGrunt ],

			TextData[ MAX_PLAYERS ][ MAX_3DTEXT_PLAYER ][ eText ],
			ItemData[ MAX_PLAYERS ][ MAX_ITEMS ][ eItems ],
			RaceData[ MAX_PLAYERS ][ MAX_CHECK ][ eRace ],
			BankData[ MAX_PLAYERS ][ eBank ],
			NarkData[ MAX_PLAYERS ][ eNark ],
			TaxiData[ MAX_PLAYERS ][ eTaxi ],
			DoorData[ MAX_DOORS ][ eDoors ],
			AnimData[ MAX_ANIMS ][ eAnims ],
			ZoneData[ MAX_ZONES ][ eZone ],
			SkinData[ MAX_SKINS ][ eSkins ],

			BusData[ MAX_BUS ][ eBus ],

			PcData[ MAX_PLAYERS ][ ePC ],
	       
   Iterator:Server_Doors< MAX_DOORS >,
   Iterator:Server_Vehicles< MAX_VEHICLES >;
	       
stock const Weathers[ ] = {
	 1,   2,  3,  4,  5,  7,
	 8,   9, 10, 11, 12, 13,
	 14, 15, 17, 18
};

stock const StartingVehicle[ ] = {
	401, 404, 422, 463, 466, 478, 542, 543
};

stock const Blockades[ ] = {
	   0,  1424,  1238, 1428, 1459,
	1425,  1423,  1422, 1435, 1427
};

stock const NpcData[ ][ eNPC ] = {
	{"Train_Driver_LV", "train_lv", 538, 255, npc_func_drive},
	{"Train_Driver_SF", "train_sf", 538, 255, npc_func_drive},
	{"Train_Driver_LS", "train_ls", 538, 255, npc_func_drive},
	{"Pilot_LV", "at400_lv", 577, 61, npc_func_drive},
	{"Pilot_SF", "at400_sf", 577, 61, npc_func_drive},
	{"Pilot_LS", "at400_ls", 577, 61, npc_func_drive},
	{"Urzednik_John", "", 0, 171, npc_func_gov, "Tutaj możesz wyrobić sobie dowód osobisty. Aby wywołać interakcję, wpisz: \"Witam\".", {359.7128, 173.8098, 1008.3893, 270.0}, 248}
/*	{"Znajdzka_1", "", 0, 10, npc_func_achiv, "Aby wywołać interakcję, wpisz: \"Znalazłem Cię!\"."},
	{"Znajdzka_2", "", 0, 10, npc_func_achiv, "Aby wywołać interakcję, wpisz: \"Znalazłem Cię!\"."},
	{"Znajdzka_3", "", 0, 10, npc_func_achiv, "Aby wywołać interakcję, wpisz: \"Znalazłem Cię!\"."}*/
};

stock const NpcMessage[ ][ eNPC_message ] = {
	{npc_func_gov, "Witaj, u mnie wyrobisz dowód osobisty."}//,
	//{npc_func_achiv, "Jeżeli mnie złapiesz, dostaniesz troche kasy!"}
};

stock const BodyParts[ ][ ] = {
	"-", "-", "-",
	"tułów", "krocze",
	"lewe ramie", "prawie ramie",
	"lewą nogę", "prawą nogę",
	"głowę"
};

stock const RingTone[ ][ eRing ] = {
	{0, 0, "Brak"},
	{62, 0, "Avicii - Wake Me Up"},
	{63, 0, "Bastille - Pompeii"},
	{64, 0, "OneRepublic - Counting Stars"},
	{65, 0, "Pitbull - Timber ft. Ke$ha"},
	{66, 0, "Katy Perry - Dark Horse"},
	{67, 0, "Eminem - The Monster ft. Rihanna"},
	{68, 0, "Kanye West - Bound 2"},
	{69, 0, "Chris Brown ft Lil Wayne & French Montana - Loyal"},
	{70, 0, "Pharrell Williams - Happy"},
	{71, 0, "The Chainsmokers - #Selfie"},
	
	{0, 1, "Brak"},
	{34, 1, "Standard SMS"},
	{61, 1, "Apple SMS"},
	{72, 1, "Best SMS"}
};

stock const FishData[ ][ eFish ] = {
	{"Szprotka", {50, 400}, 0.04, false},
	{"Tuńczyk", {50, 1000}, 0.04, false},
	{"Tuńczyk", {1000, 1500}, 0.04, true},
	{"Dorsz", {40, 300}, 0.04, false},
	{"Karp", {200, 1000}, 0.01, false},
	{"Karp", {1000, 1600}, 0.01, true},
	{"Płoć", {50, 103}, 0.03, false}
};

stock const AchivData[ ][ eAchiv ] = {
	{achiv_login, "Pierwsze logowanie", 50}, //
	{achiv_veh, "Wreszcie pojazd!", 400}, //
	{achiv_join, "Pierwsze zatrudnienie", 200}, //
	{achiv_gun, "Pora postrzelać!", 800}, //
	{achiv_kara, "Ukarany", -500},
	{achiv_time, "Staly bywalec", 100}, //
	{achiv_jail, "Ale wpadles", 50}, //
	{achiv_job, "Legalna praca", 100}, //
	{achiv_lider, "Przywodca", 2000}, //
	{achiv_bw, "Poszkodowany", -25}, //
	{achiv_bank, "Male oszczednosci", 300}, //
	{achiv_npc, "Bog zaplac!", 250}
};

stock const FightData[ ][ eFightStyle ] = {
	{4, "Normal"},
	{5, "Boxing"},
	{6, "Kungfu"},
	{7, "Kneehead"},
	{15, "Grabkick"},
	{16, "Elbow"}
};

stock const AdminLvl[ ][ eAdminLvl ] = {
	{0, "", ""}, 						// 0
	{0x6495EDFF, "", "Support"}, 			// 1
	{0x008000FF, "GM", "GameMaster"}, 			// 2
	{0x4B0082FF, "GA", "Game Assistant"}, 			// 3
	{0xFF4D4DFF, "", "Administrator"}, 			// 4
	{0x8B1A1AFF, "", "Główny Administrator"}, 			// 5
	{0xFF0000FF, "", "Skrypter"} 		// 6
};

stock const LicName[ ][ eLicense ] = {
	{"", group_type_none, 0.0},                           	// 0
	{"Prawo jazdy kat. A", group_type_gov, 50.0, 110.0},             // 1
	{"Prawo jazdy kat. B", group_type_gov, 225.0},             // 2
	{"Prawo jazdy kat. C", group_type_gov, 275.0},             // 3
	{"Prawo jazdy kat. C+E", group_type_gov, 300.0},           // 4
	{"Prawo jazdy kat. D", group_type_gov, 340.0},           // 5
	{"Dowód osobisty", group_type_gov, 75.0},                 // 6
	{"Metryka zdrowia", group_type_mc, 0.0},                // 7
	{"Niekaralność", group_type_pd, 0.0},                   // 8
	{"Pozwolenie na broń krótką", group_type_pd, 0.0},      // 9
	{"Pozwolenie na broń automatyczną", group_type_pd, 0.0},// 10
	{"...", group_type_none, 0.0}                             // 11
};

stock const QuestName[ ][ eQuest ] = {
	{"Jaki jest numer alarmowy?", "991", "911", "919", 1},
	{"Maksymalna prędkość w terenie zabudowanym, to?", "60km/h", "50km/h", "55km/h", 1},
	{"Maksymalna prędkość podczas holowania pojazdu, w terenie zabudowanym, to?", "30km/h", "40km/h", "50km/h", 0},
	{"Jesteś świadkiem wypadku, co robisz?", "Odchodzę na bezpieczną odległość i obserwuję całe zdarzenie.", "Dzwonię pod numer alarmowy, zabezpieczam miejsce wypadku, następnie udzielam pierwszej pomocy.", "Nie podejmuję jakichkolwiek działań.", 1},
	{"Maksymalna prędkość na autostradzie, to?", "140km/h", "130km/h", "125km/h", 0}
};

stock const JobName[ ][ eJobs ] = {
	{"None"},
	{"Sprzątacz ulic South Central"},
	{"Sprzątacz ulic Downtown"},
	{"Mechanik"},
	{"Sprzedawca hotdogów"},
	{"Śmieciarz"},
	{"Rybak"}
};

stock const NarkName[ ][ ] = {
	{"None"},
	{"Amfetamina"},
	{"Crack"},
	{"Ecstasy"},
	{"Grzybki halucynogenne"},
	{"Heroina"},
	{"Kokaina"},
	{"LSD"},
	{"Marihuana"},
	{"Metaamfetamina"},
	{"Opium"}
};

stock const Mowa[ ][ eAnims ] = {
	{0, "", "", "", 0.0, {0, 0, 0, 0, 0}},
	{1, "chat", "PED", "IDLE_CHAT", 4.1, {0, 0, 0, 1, 1}}
};

stock const BodyWeapon[ ][ eWeapon ] =
{
	{30, -0.1, -0.17, 0.09, 0.0, 50.0, 0.0, 1}, 	// AK-47
	{31, -0.1, -0.17, 0.09, 0.0, 50.0, 0.0, 1}, 	// M4
	{29, -0.1, -0.17, 0.09, 0.0, 50.0, 0.0, 1}, 	// MP5
	{34, -0.1, -0.17, 0.09, 0.0, 50.0, 0.0, 1}, 	// Sniper
	{25, -0.1, -0.17, 0.09, 0.0, 50.0, 0.0, 1}, 	// Shotgun
	{5, -0.1, -0.11, 0.2, 0.0, 130.0, -50.0, 1}, 	// Basket Ball
	{22, 0.05, 0.0, 0.15, -90.0, 370.0, -0.0, 8}, 	// 9mm
	{23, 0.05, 0.0, 0.15, -90.0, 370.0, -0.0, 8}, 	// 9mm t3umik
	{4, 0.1, -0.10, -0.15, 0.0, 90.0, 90.0, 7}, 	// Nó?
	{3, 0.1, -0.10, -0.15, 10.0, 90.0, 90.0, 7}, 	// Pa3ka
	{24, 0.05, 0.0, 0.15, -90.0, 370.0, -0.0, 8},	// Deagle
	{8, 0.2, -0.15, -0.2, 0.0, -60.0, 0.0, 1}, 	// Katana
	{6, -0.1, -0.11, 0.2, 0.0, 130.0, -70.0, 1}, 	// Lopata
	{26, 0.25, -0.13, -0.19, 180.0, 150.0, 0.0, 1},	// Combat Shotgun
	{28, 0.05, -0.05, 0.13, -90.0, -40.0, 0.0, 8},	// Uzi
	{32, 0.05, -0.05, 0.13, -90.0, -40.0, 0.0, 8},	// Tec 9
	{43, 0.1, 0.13, -0.1, 90.0, 140.0, 0.0, 1},	// Aparat
	{46, 0.06, -0.17, -0.0, 0.0, 90.0, 0.0, 1}	// Parachute
};

stock const ItemName[ ][ ] = {
	{"None"},
	{"Broń"},
	{"Amunicja"},
	{"Ubranie"},
	{"Jedzenie"},
	{"Napój"},
	{"Zegarek"},
	{"Klucz"},
	{"Papieros"},
	{"Radio"},
	{"Telefon"},
	{"Kajdanki"},
	{"Megafon"},
	{"Karta"},
	{"Śmieć"},
	{"Nasiono"},
	{"Obiekt na ciało"},
	{"Narkotyk"},
	{"Książeczka czekowa"},
	{"Czek"},
	{"Rolki"},
	{"---"}, // Craft
	{"Płyta"},
	{"Boombox"},
	{"CD-Player"},
	{"Paczka"},
	{"Syrena"},
	{"Dokument"},
	{"Leki"},
	{"Notes"},
	{"Kartka"},
	{"Komponent"},
	{"Element"},
	{"Część w pojeździe"},
	{"Knebel"},
	{"Worek"},
	{"Maska"},
	{"Tłumik"},
	{"Optiwand"},
	{"Kluczyki"},
	{"Wędka"},
	{"Karta SIM"},
	{"Kostka"},
	{"Linka holownicza"},
	{"Karnet"}
};

stock const GroupName[ ][ ] = {
	{"Brak"},
	{"Police"},
	{"Medical Center"},
	{"Government"},
	{"Fire Department"},
	{"Radio"},
	{"Gastronomy"},
	{"Warsztat"},
	{"Binco"},
	{"Sklep"},
	{"Budownictwo"},
	{"Syndykat"},
	{"Bank"},
	{"Gym"},
	{"Stacja"},
	{"---"}, // Poczta
	{"Gang"},
	{"Mafia"},
	{"Taxi"},
	{"Kurier"},
	{"Pomoc drogowa"},
	{"Salon samochodowy"},
	{"Sklep meblowy"},
	{"Kartel"},
	{"Wojsko"},
	{"Elektronika"}
};

stock const InVeh[ ][ eInVeh ] = {
	{"Brak", option_none},
	{"Immobiliser", option_immo},
	{"Alarm", option_alarm},
	{"Audio", option_audio},
	{"Komputer", option_pc},
	{"Neony", option_neon}
};

stock const PickModel[ ][ ePickModel ] = {
	{ 0,	"Brak"    	 },	{ 1240, "Życie"           }, { 1242, "Kamizelka				"},
	{ 1239, "Info 'i'"   }, { 1272, "Niebieski Dom"   }, { 1273, "Zielony Dom			"},
	{ 1212, "Pieniądze"  },/* { 1241, "Adrenaline"      },*/ { 1247, "Gwiazdka				"},
	{ 1254, "Czaszka"    }, { 1274, "Dolar"           }, { 1275, "Niebieska koszulka	"},
	{ 1313, "2 czaszki"  }, { 1318, "Strzałka"        }, { 1279, "Paczka z narkotykami	"}
};

stock const TuneName[ ][ eTune ] =
{
	{1000, "Pro", 				CARMODTYPE_SPOILER},
	{1001, "Win", 				CARMODTYPE_SPOILER},
	{1002, "Drag", 				CARMODTYPE_SPOILER},
	{1003, "Alpha", 			CARMODTYPE_SPOILER},
	{1004, "Champ Scoop", 		CARMODTYPE_HOOD},
	{1005, "Fury Scoop", 		CARMODTYPE_HOOD},
	{1006, "Roof Scoop", 		CARMODTYPE_ROOF},
	{1007, "Right Sideskirt", 	CARMODTYPE_SIDESKIRT},
	{1008, "Nitro 5x", 			CARMODTYPE_NITRO},
	{1009, "Nitro 2x", 			CARMODTYPE_NITRO},
	{1010, "Nitro 10x", 		CARMODTYPE_NITRO},
	{1011, "Race Scoop",        CARMODTYPE_HOOD},
	{1012, "Worx Scoop", 		CARMODTYPE_HOOD},
	{1013, "Round Fog",         CARMODTYPE_LAMPS},
	{1014, "Champ",             CARMODTYPE_SPOILER},
	{1015, "Race",              CARMODTYPE_SPOILER},
	{1016, "Worx",              CARMODTYPE_SPOILER},
	{1017, "Left Sideskirt",    CARMODTYPE_SIDESKIRT},
	{1018, "Upswept",           CARMODTYPE_EXHAUST},
	{1019, "Twin",              CARMODTYPE_EXHAUST},
	{1020, "Large",             CARMODTYPE_EXHAUST},
	{1021, "Medium",            CARMODTYPE_EXHAUST},
	{1022, "Small",             CARMODTYPE_EXHAUST},
	{1023, "Fury",              CARMODTYPE_SPOILER},
	{1024, "Square Fog",        CARMODTYPE_LAMPS},
	{1025, "Offroad",           CARMODTYPE_WHEELS},
	{1026, "Right Alien Sideskirt", CARMODTYPE_SIDESKIRT},
	{1027, "Left Alien Sideskirt",  CARMODTYPE_SIDESKIRT},
	{1028, "Alien",             CARMODTYPE_EXHAUST},
	{1029, "X-Flow",            CARMODTYPE_EXHAUST},
	{1030, "Left X-Flow Sideskirt", CARMODTYPE_SIDESKIRT},
	{1031, "Right X-Flow Sideskirt", CARMODTYPE_SIDESKIRT},
	{1032, "Alien Roof Vent",  	CARMODTYPE_ROOF},
	{1033, "X-Flow Roof Vent",  CARMODTYPE_ROOF},
	{1034, "Alien",             CARMODTYPE_EXHAUST},
	{1035, "X-Flow Roof Vent",  CARMODTYPE_ROOF},
	{1036, "Right Alien Sideskirt", CARMODTYPE_SIDESKIRT},
	{1037, "X-Flow",            CARMODTYPE_EXHAUST},
	{1038, "Alien Roof Vent",   CARMODTYPE_ROOF},
	{1039, "Right X-Flow Sideskirt", CARMODTYPE_SIDESKIRT},
	{1040, "Left Alien Sideskirt",   CARMODTYPE_SIDESKIRT},
	{1041, "Right X-Flow Sideskirt", CARMODTYPE_SIDESKIRT},
	{1042, "Right Chrome Sideskirt", CARMODTYPE_SIDESKIRT},
	{1043, "Slamin",    		CARMODTYPE_EXHAUST},
	{1044, "Chrome",    		CARMODTYPE_EXHAUST},
	{1045, "X-Flow",    		CARMODTYPE_EXHAUST},
	{1046, "Alien",     		CARMODTYPE_EXHAUST},
	{1047, "Right Alien Sideskirt", CARMODTYPE_SIDESKIRT},
	{1048, "Right X-Flow Sideskirt",CARMODTYPE_SIDESKIRT},
	{1049, "Alien",     		CARMODTYPE_SPOILER},
	{1050, "X-Flow",    	 	CARMODTYPE_SPOILER},
	{1051, "Left Alien Sideskirt", CARMODTYPE_SIDESKIRT},
	{1052, "Left X-Flow Sideskirt", CARMODTYPE_SIDESKIRT},
	{1053, "X-Flow", 			CARMODTYPE_ROOF},
	{1054, "Alien", 			CARMODTYPE_ROOF},
	{1055, "Alien", 			CARMODTYPE_ROOF},
	{1056, "Right Alien Sideskirt", CARMODTYPE_SIDESKIRT},
	{1057, "Right X-Flow Sideskirt", CARMODTYPE_SIDESKIRT},
	{1058, "Alien", 			CARMODTYPE_SPOILER},
	{1059, "X-Flow", 			CARMODTYPE_EXHAUST},
	{1060, "X-Flow", 			CARMODTYPE_SPOILER},
	{1061, "X-Flow", 			CARMODTYPE_ROOF},
	{1062, "Left Alien Sideskirt", CARMODTYPE_SIDESKIRT},
	{1063, "Left X-Flow Sideskirt", CARMODTYPE_SIDESKIRT},
	{1064, "Alien", 			CARMODTYPE_EXHAUST},
	{1065, "Alien", 			CARMODTYPE_EXHAUST},
	{1066, "X-Flow", 			CARMODTYPE_EXHAUST},
	{1067, "Alien", 			CARMODTYPE_ROOF},
	{1068, "X-Flow", 			CARMODTYPE_ROOF},
	{1069, "Right Alien Sideskirt", CARMODTYPE_SIDESKIRT},
	{1070, "Right X-Flow Sideskirt", CARMODTYPE_SIDESKIRT},
	{1071, "Left Alien Sideskirt", CARMODTYPE_SIDESKIRT},
	{1072, "Left X-Flow Sideskirt", CARMODTYPE_SIDESKIRT},
	{1073, "Shadow", 			CARMODTYPE_WHEELS},
	{1074, "Mega", 				CARMODTYPE_WHEELS},
	{1075, "Rimshine", 			CARMODTYPE_WHEELS},
	{1076, "Wires", 			CARMODTYPE_WHEELS},
	{1077, "Classic", 			CARMODTYPE_WHEELS},
	{1078, "Twist", 			CARMODTYPE_WHEELS},
	{1079, "Cutter", 			CARMODTYPE_WHEELS},
	{1080, "Switch", 			CARMODTYPE_WHEELS},
	{1081, "Grove", 			CARMODTYPE_WHEELS},
	{1082, "Import", 			CARMODTYPE_WHEELS},
	{1083, "Dollar", 			CARMODTYPE_WHEELS},
	{1084, "Trance", 			CARMODTYPE_WHEELS},
	{1085, "Aromic", 			CARMODTYPE_WHEELS},
	{1086, "Stereo", 			CARMODTYPE_STEREO},
	{1087, "Hydraulics", 		CARMODTYPE_HYDRAULICS},
	{1088, "Alien", 			CARMODTYPE_ROOF},
	{1089, "X-Flow", 			CARMODTYPE_EXHAUST},
	{1090, "Right Alien Sideskirt", CARMODTYPE_SIDESKIRT},
	{1091, "X-Flow", 			CARMODTYPE_ROOF},
	{1092, "Alien", 			CARMODTYPE_EXHAUST},
	{1093, "Right X-Flow Sideskirt", CARMODTYPE_SIDESKIRT},
	{1094, "Left Alien Sideskirt", CARMODTYPE_SIDESKIRT},
	{1095, "Right X-Flow Sideskirt", CARMODTYPE_SIDESKIRT},
	{1096, "Ahab", 				CARMODTYPE_WHEELS},
	{1097, "Virtual", 			CARMODTYPE_WHEELS},
	{1098, "Access", 			CARMODTYPE_WHEELS},
	{1099, "Left Chrome Sideskirt", CARMODTYPE_SIDESKIRT},
	{1100, "Chrome Grill", 		CARMODTYPE_FRONT_BUMPER},
	{1101, "Left `Chrome Flames` Sideskirt", CARMODTYPE_SIDESKIRT},
	{1102, "Left `Chrome Strip` Sideskirt", CARMODTYPE_SIDESKIRT},
	{1103, "Covertible", 		CARMODTYPE_ROOF},
	{1104, "Chrome", 			CARMODTYPE_EXHAUST},
	{1105, "Slamin", 			CARMODTYPE_EXHAUST},
	{1106, "Right `Chrome Arches`", CARMODTYPE_SIDESKIRT},
	{1107, "Left `Chrome Strip` Sideskirt", CARMODTYPE_SIDESKIRT},
	{1108, "Right `Chrome Strip Sideskirt", CARMODTYPE_SIDESKIRT},
	{1109, "Chrome", 			CARMODTYPE_REAR_BUMPER},
	{1110, "Slamin", 			CARMODTYPE_REAR_BUMPER},
	{1111, "Little Sign", 		CARMODTYPE_FRONT_BUMPER},
	{1112, "Little Sing", 		CARMODTYPE_FRONT_BUMPER},
	{1113, "Chrome", 			CARMODTYPE_EXHAUST},
	{1114, "Slamin", 			CARMODTYPE_EXHAUST},
	{1115, "Chrome", 			CARMODTYPE_FRONT_BUMPER},
	{1116, "Slamin", 			CARMODTYPE_FRONT_BUMPER},
	{1117, "Chrome", 			CARMODTYPE_FRONT_BUMPER},
	{1118, "Right `Chrome Trim` Sideskirt", CARMODTYPE_SIDESKIRT},
	{1119, "Right `Wheelcovers` Sideskirt", CARMODTYPE_SIDESKIRT},
	{1120, "Left `Chrome Trim` Sideskirt", CARMODTYPE_SIDESKIRT},
	{1121, "Left `Wheelcovers` Sideskirt", CARMODTYPE_SIDESKIRT},
	{1122, "Right `Chrome Flames` Sideskirt", CARMODTYPE_SIDESKIRT},
	{1123, "Bullbar Chrome Bars", CARMODTYPE_FRONT_BUMPER},
	{1124, "Left `Chrome Arches` Sideskirt", CARMODTYPE_SIDESKIRT},
	{1125, "Bullbar Chrome Lights", CARMODTYPE_FRONT_BUMPER},
	{1126, "Chrome Exhaust", 	CARMODTYPE_EXHAUST},
	{1127, "Slamin Exhaust", 	CARMODTYPE_EXHAUST},
	{1128, "Vinyl Hardtop", 	CARMODTYPE_ROOF},
	{1129, "Chrome", 			CARMODTYPE_EXHAUST},
	{1130, "Hardtop", 			CARMODTYPE_ROOF},
	{1131, "Softtop", 			CARMODTYPE_ROOF},
	{1132, "Slamin", 			CARMODTYPE_EXHAUST},
	{1133, "Right `Chrome Strip` Sideskirt", CARMODTYPE_SIDESKIRT},
	{1134, "Right `Chrome Strip` Sideskirt", CARMODTYPE_SIDESKIRT},
	{1135, "Slamin", 			CARMODTYPE_EXHAUST},
	{1136, "Chrome", 			CARMODTYPE_EXHAUST},
	{1137, "Left `Chrome Strip` Sideskirt", CARMODTYPE_SIDESKIRT},
	{1138, "Alien", 			CARMODTYPE_SPOILER},
	{1139, "X-Flow", 			CARMODTYPE_SPOILER},
	{1140, "X-Flow", 			CARMODTYPE_REAR_BUMPER},
	{1141, "Alien", 			CARMODTYPE_REAR_BUMPER},
	{1142, "Left Oval Vents", 	CARMODTYPE_VENT_LEFT},
	{1143, "Right Oval Vents", 	CARMODTYPE_VENT_RIGHT},
	{1144, "Left Square Vents", CARMODTYPE_VENT_LEFT},
	{1145, "Right Squere Vents", CARMODTYPE_VENT_RIGHT},
	{1146, "X-Flow", 			CARMODTYPE_SPOILER},
	{1147, "Alien", 			CARMODTYPE_SPOILER},
	{1148, "X-Flow", 			CARMODTYPE_REAR_BUMPER},
	{1149, "Alien", 			CARMODTYPE_REAR_BUMPER},
	{1150, "Alien", 			CARMODTYPE_REAR_BUMPER},
	{1151, "X-Flow", 			CARMODTYPE_REAR_BUMPER},
	{1152, "X-Flow", 			CARMODTYPE_FRONT_BUMPER},
	{1153, "Alien", 			CARMODTYPE_FRONT_BUMPER},
	{1154, "Alien", 			CARMODTYPE_REAR_BUMPER},
	{1155, "Alien", 			CARMODTYPE_FRONT_BUMPER},
	{1156, "X-Flow", 			CARMODTYPE_REAR_BUMPER},
	{1157, "X-Flow", 			CARMODTYPE_FRONT_BUMPER},
	{1158, "X-Flow", 			CARMODTYPE_SPOILER},
	{1159, "Alien", 			CARMODTYPE_REAR_BUMPER},
	{1160, "Alien", 			CARMODTYPE_FRONT_BUMPER},
	{1161, "X-Flow", 			CARMODTYPE_REAR_BUMPER},
	{1162, "Alien", 			CARMODTYPE_SPOILER},
	{1163, "X-Flow", 			CARMODTYPE_SPOILER},
	{1164, "Alien", 			CARMODTYPE_SPOILER},
	{1165, "X-Flow", 			CARMODTYPE_FRONT_BUMPER},
	{1166, "Alien", 			CARMODTYPE_FRONT_BUMPER},
	{1167, "X-Flow", 			CARMODTYPE_REAR_BUMPER},
	{1168, "Alien", 			CARMODTYPE_REAR_BUMPER},
	{1169, "Alien", 			CARMODTYPE_FRONT_BUMPER},
	{1170, "X-Flow", 			CARMODTYPE_FRONT_BUMPER},
	{1171, "Alien", 			CARMODTYPE_FRONT_BUMPER},
	{1172, "X-Flow", 			CARMODTYPE_FRONT_BUMPER},
	{1173, "X-Flow", 			CARMODTYPE_FRONT_BUMPER},
	{1174, "Chrome", 			CARMODTYPE_FRONT_BUMPER},
	{1175, "Slamin", 			CARMODTYPE_REAR_BUMPER},
	{1176, "Chrome", 			CARMODTYPE_FRONT_BUMPER},
	{1177, "Slamin", 			CARMODTYPE_REAR_BUMPER},
	{1178, "Slamin", 			CARMODTYPE_REAR_BUMPER},
	{1179, "Chrome", 			CARMODTYPE_FRONT_BUMPER},
	{1180, "Chrome", 			CARMODTYPE_REAR_BUMPER},
	{1181, "Slamin", 			CARMODTYPE_FRONT_BUMPER},
	{1182, "Chrome", 			CARMODTYPE_FRONT_BUMPER},
	{1183, "Slamin", 			CARMODTYPE_REAR_BUMPER},
	{1184, "Chrome", 			CARMODTYPE_REAR_BUMPER},
	{1185, "Slamin", 			CARMODTYPE_FRONT_BUMPER},
	{1186, "Slamin", 			CARMODTYPE_REAR_BUMPER},
	{1187, "Chrome", 			CARMODTYPE_REAR_BUMPER},
	{1188, "Slamin", 			CARMODTYPE_FRONT_BUMPER},
	{1189, "Chrome", 			CARMODTYPE_FRONT_BUMPER},
	{1190, "Slamin", 			CARMODTYPE_FRONT_BUMPER},
	{1191, "Chrome", 			CARMODTYPE_FRONT_BUMPER},
	{1192, "Chrome", 			CARMODTYPE_REAR_BUMPER},
	{1193, "Slamin", 			CARMODTYPE_REAR_BUMPER}
};

stock const SimilarComponents[ ][ 2 ] =
{
	{1007, 1017},
	{1026, 1027},
	{1030, 1031},
	{1036, 1040},
	{1039, 1041},
	{1042, 1099},
	{1047, 1051},
	{1048, 1052},
	{1056, 1062},
	{1057, 1063},
	{1069, 1071},
	{1070, 1072},
	{1090, 1094},
	{1093, 1095},
	{1106, 1124},
	{1107, 1108},
	{1118, 1120},
	{1119, 1121},
	{1122, 1101},
	{1133, 1102},
	{1143, 1142},
	{1145, 1144}
};

stock const CarMods[ ][ 15 ] =
{
	{400, 1018, 1019, 1020, 1021, 1013, 1024, 0,    0,    0,    0,    0,    0,    0,    0},     //Landstalker
	{401, 1001, 1003, 1004, 1005, 1006, 1013, 1019, 1020, 1007, 1017, 1142, 1143, 1144, 1145},  //Bravura
	{404, 1019, 1020, 1021, 1013, 1007, 1017, 1000, 1002, 1016, 0,    0,    0,    0,    0},     //Perenial
	{405, 1018, 1019, 1020, 1021, 1000, 1001, 1014, 1023, 0,    0,    0,    0,    0,    0},     //Sentinel
	{410, 1019, 1020, 1021, 1013, 1024, 1001, 1003, 1023, 1007, 1017, 0,    0,    0,    0},     //Manana
	{415, 1018, 1019, 1001, 1003, 1023, 1007, 1017, 0,    0,    0,    0,    0,    0,    0},     //Cheetah
	{418, 1020, 1021, 1006, 1002, 1016, 0,    0,    0,    0,    0,    0,    0,    0,    0},     //Moonbeam
	{420, 1004, 1005, 1019, 1021, 1001, 1003, 0,    0,    0,    0,    0,    0,    0,    0},     //Taxi
	{421, 1018, 1019, 1020, 1021, 1000, 1014, 1016, 1023, 0,    0,    0,    0,    0,    0},     //Washington
	{422, 1013, 1019, 1020, 1021, 1007, 1017, 0,    0,    0,    0,    0,    0,    0,    0},     //Bobcat
	{426, 1004, 1005, 1019, 1021, 1001, 1003, 1006, 0,    0,    0,    0,    0,    0,    0},     //Premier
	{436, 1019, 1020, 1021, 1022, 1006, 1013, 1001, 1003, 1007, 1017, 0,    0,    0,    0},     //Previon
	{439, 1142, 1143, 1144, 1145, 1013, 1001, 1003, 1023, 1007, 1017, 0,    0,    0,    0},     //Stallion
	{477, 1018, 1019, 1020, 1021, 1006, 1007, 1017, 0,    0,    0,    0,    0,    0,    0},     //ZR-350
	{478, 1004, 1005, 1012, 1020, 1021, 1022, 1013, 1024, 0,    0,    0,    0,    0,    0},     //Walton
	{489, 1004, 1005, 1018, 1019, 1020, 1013, 1024, 1006, 1000, 1002, 1016, 0,    0,    0},     //Rancher
	{491, 1142, 1143, 1144, 1145, 1018, 1019, 1020, 1021, 1003, 1014, 1023, 1007, 1017, 0},     //Virgo
	{492, 1004, 1005, 1000, 1006, 1016, 0,    0,    0,    0,    0,    0,    0,    0,    0},     //Greenwood
	{496, 1001, 1002, 1003, 1006, 1011, 1019, 1020, 1023, 1007, 1017, 1142, 1143, 0,    0},     //Blista Compact
	{500, 1019, 1020, 1021, 1013, 1024, 0,    0,    0,    0,    0,    0,    0,    0,    0},     //Mesa
	{516, 1004, 1018, 1019, 1020, 1021, 1000, 1002, 1015, 1016, 1007, 1017, 0,    0,    0},     //Nebula
	{517, 1007, 1017, 1142, 1143, 1144, 1145, 1018, 1019, 1020, 1002, 1003, 1016, 1023, 0},     //Majestic
	{518, 1001, 1005, 1006, 1013, 1018, 1020, 1023, 1142, 1143, 1144, 1145, 0,    0,    0},     //Buccaneer
	{527, 1018, 1020, 1021, 1001, 1014, 1015, 1007, 1017, 0,    0,    0,    0,    0,    0},     //Cadrona
	{529, 1011, 1012, 1018, 1019, 1020, 1006, 1001, 1003, 1023, 1007, 1017, 0,    0,    0},     //Willard
	{534, 1100, 1101, 1106, 1122, 1123, 1124, 1125, 1126, 1127, 1178, 1179, 1180, 1185, 0},     //Remington
	{535, 1109, 1110, 1111, 1112, 1113, 1114, 1115, 1116, 1117, 1118, 1119, 1120, 1121, 0},     //Slamvan
	{536, 1103, 1104, 1105, 1107, 1108, 1128, 1181, 1182, 1183, 1184, 0,    0,    0,    0},     //Blade
	{540, 1004, 1142, 1143, 1144, 1145, 1018, 1019, 1020, 1006, 1024, 1001, 1023, 1007, 1017},  //Vincent
	{542, 1018, 1019, 1020, 1021, 1014, 1015, 1144, 1145, 0,    0,    0,    0,    0,    0},     //Clover
	{546, 1004, 1142, 1143, 1144, 1145, 1018, 1019, 1006, 1024, 1001, 1002, 1023, 1007, 1017},  //Intruder
	{547, 1142, 1143, 1018, 1019, 1020, 1021, 1000, 1003, 1016, 0,    0,    0,    0,    0},     //Primo
	{549, 1011, 1012, 1142, 1143, 1144, 1145, 1018, 1019, 1020, 1001, 1003, 1023, 1007, 1017},  //Tampa
	{550, 1004, 1005, 1142, 1143, 1144, 1145, 1018, 1019, 1020, 1001, 1003, 1023, 1007, 1017},  //Sunrise
	{551, 1005, 1006, 1018, 1019, 1020, 1021, 1002, 1003, 1016, 1023, 0,    0,    0,    0},     //Merit
	{558, 1088, 1089, 1090, 1091, 1092, 1093, 1094, 1095, 1163, 1164, 1165, 1168, 0,    0},     //Uranus
	{559, 1065, 1066, 1067, 1068, 1069, 1070, 1071, 1072, 1158, 1159, 1160, 1161, 1162, 1173},  //Jester
	{560, 1026, 1027, 1028, 1029, 1030, 1031, 1032, 1033, 1138, 1139, 1140, 1141, 1169, 1170},  //Sultan
	{561, 1055, 1056, 1057, 1058, 1059, 1060, 1061, 1062, 1063, 1064, 1154, 1155, 1156, 1157},  //Stratum
	{562, 1034, 1035, 1036, 1037, 1038, 1039, 1040, 1041, 1146, 1147, 1148, 1149, 1171, 1172},  //Elegy
	{565, 1045, 1046, 1047, 1048, 1049, 1050, 1051, 1052, 1053, 1054, 1150, 1151, 1152, 1153},  //Flash
	{567, 1102, 1129, 1130, 1131, 1132, 1133, 1186, 1187, 1188, 1189, 0,    0,    0,    0},     //Savanna
	{575, 1042, 1043, 1044, 1099, 1074, 1075, 1076, 1077, 0,    0,    0,    0,    0,    0},     //Broadway
	{576, 1134, 1135, 1136, 1137, 1190, 1191, 1192, 1193, 0,    0,    0,    0,    0,    0},     //Tornado
	{580, 1018, 1020, 1001, 1006, 1023, 1007, 1017, 0,    0,    0,    0,    0,    0,    0},     //Stafford
	{585, 1142, 1143, 1144, 1145, 1018, 1019, 1020, 1013, 1006, 1001, 1003, 1023, 1007, 1017},  //Emperor
	{589, 1004, 1005, 1144, 1145, 1018, 1020, 1013, 1024, 1006, 1000, 1016, 1007, 1017, 0},     //Club
	{600, 1004, 1005, 1018, 1020, 1022, 1006, 1013, 1007, 1017, 0,    0,    0,    0,    0},     //Picador
	{603, 1142, 1143, 1144, 1145, 1018, 1019, 1020, 1013, 1001, 1006, 1023, 1007, 1017, 0}      //Phoenix
};

// ----------------------------------------------------------------------------------------------------
// Includes
// ----------------------------------------------------------------------------------------------------

#include <a_mysql>
#include <a_http>
#include <a_audio>
#include <sscanf2>
#include <md5>
#include <DOF2>
#include <zcmd>
#include <jFader>
#if mapandreas
	#include <mapandreas>
#endif
#include <veh>
#include <rnpc>
#if STREAMER
	#include <streamer>
#endif

#include "SURV_init.pwn"
#include "SURV_mysql.pwn"
#include "SURV_cmd.pwn"
#include "SURV_groups.pwn"
#include "SURV_objects.pwn"
#include "SURV_items.pwn"
#include "SURV_doors.pwn"
#include "SURV_vehicles.pwn"
#include "SURV_friends.pwn"
#include "SURV_bus.pwn"
#include "SURV_text.pwn"
#include "SURV_bank.pwn"
#include "SURV_tel.pwn"
#include "SURV_zone.pwn"
#include "SURV_offer.pwn"
#include "SURV_admin.pwn"
#include "SURV_station.pwn"
#include "SURV_orders.pwn"
#include "SURV_pickups.pwn"
#include "SURV_anims.pwn"
#include "SURV_pc.pwn"
#include "SURV_sejf.pwn"
#include "SURV_audio.pwn"
#include "SURV_achiv.pwn"
#include "SURV_opis.pwn"
#include "SURV_weather.pwn"
#include "SURV_radar.pwn"
#include "SURV_login.pwn"
#include "SURV_npc.pwn"
#include "SURV_socket.pwn"
#include "SURV_skin.pwn"
#include "SURV_checkpoint.pwn"
#include "SURV_train.pwn"
