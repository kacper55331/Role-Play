#define TEXT_LOGIN  		white"Witamy na serwerze {228D22}"glob_name""white".\nZalogowaæ siê mo¿esz przy u¿yciu nazwy swojego konta globalnego, b¹dŸ postaci.\n\nWpisz has³o, aby do³¹czyæ do najbardziej zaawansowanego projektu Role Play na scenie."
#define TEXT_OOC    		white"Administrator {E31919}odebraæ Ci dostêp do kana³u OOC.\n\n"white"Odwo³anie od kary mo¿esz zamieœciæ {008000}na naszym forum"white"."
#define TEXT_NOVEH   		white"Administrator {E31919}odebraæ Ci mo¿liwoœæ korzystania z pojazdów.\n\n"white"Odwo³anie od kary mo¿esz zamieœciæ {008000}na naszym forum"white"."
#define TEXT_BRON  			white"Administrator {E31919}odebraæ Ci mo¿liwoœæ korzystania z broni.\n\n"white"Odwo³anie od kary mo¿esz zamieœciæ½ {008000}na naszym forum"white"."
#define TEXT_AJ     		"{E31919}W tym miejscu nie mo¿esz u¿ywaæ "white"komend{E31919}!"
#define SAN_NEWS    		"~>~ Los Santos News:~w~ Aktualnie nic nie jest nadawane."

#define gui_active          "{B9CBEC}"

// text.pwn

#define text_owner_none   	0
#define text_owner_group  	1
#define text_owner_player 	2
#define text_owner_doors  	3
#define text_owner_bus      4
#define text_owner_plant    5
#define text_owner_vehicle  6

// objects.pwn

#define object_owner_none   0
#define object_owner_group  1
#define object_owner_player 2
#define object_owner_doors  3
#define object_owner_item   4
#define object_owner_plant  5

// vehicles.pwn

#define vehicle_owner_none  	0
#define vehicle_owner_group 	1
#define vehicle_owner_player    2
#define vehicle_owner_job       3
#define vehicle_owner_npc       4

#define fuel_none               0
#define fuel_benzyna            1
#define fuel_ropa               2
#define fuel_gas                4

#define option_none             0
#define option_immo             1
#define option_alarm            2
#define option_audio            4
#define option_pc               8
#define option_plot             16
#define option_plot_open        32
#define option_bomb             64
#define option_neon             128
#define option_siren            256
#define option_turbo            512
#define option_nosell           1024
#define option_window           2048
#define option_dark             4096

#define przebieg_przelicznik    335
#define fuel_przelicznik        2700

// items.pwn

#define item_none   	0
#define item_weapon 	1
#define item_ammo   	2
#define item_cloth  	3
#define item_food   	4
#define item_drink  	5
#define item_watch  	6
#define item_key    	7
#define item_ciggy  	8
#define item_radio  	9
#define item_phone  	10
#define item_kajdanki   11
#define item_megafon    12
#define item_karta      13
#define item_trash      14
#define item_seed       15
#define item_attach     16
#define item_drugs      17
#define item_checkbox   18
#define item_check      19
#define item_rolki      20
#define item_craft      21
#define item_cd         22
#define item_bumbox     23
#define item_cdplayer   24
#define item_pack       25
#define item_siren      26
#define item_document   27
#define item_leki       28
#define item_notes		29
#define item_kartka		30
#define item_component  31
#define item_element    32
#define item_vehitem    33
#define item_knebel     34
#define item_worek      35
#define item_mask       36
#define item_tlumik     37
#define item_optiwand   38
#define item_kluczyki   39
#define item_wedka      40
#define item_sim        41
#define item_kostka     42
#define item_hol        43
#define item_karnet     44

#define item_place_none     0
#define item_place_player   1
#define item_place_vehicle  2
#define item_place_interior 3
#define item_place_tuning   4
#define item_place_sejf     5
#define item_place_item     6

#define key_type_none       0
#define key_type_vehicle    1
#define key_type_doors      2

#define kart_type_none      0
#define kart_type_group     1   // Grupy    	| owner = group_uid
#define kart_type_player    2   // Gracza   	| owner = player_uid
#define kart_type_item      3   // W notesie 	| owner = item_uid

#define drugs_none          0
#define drugs_lsd           1
#define drugs_mar           2

#define trash_none          0
#define trash_bottle        1
#define trash_food          2

#define doc_none    	0
#define doc_prawko_a	1
#define doc_prawko_b	2
#define doc_prawko_c	3
#define doc_prawko_c_e	4
#define doc_prawko_d    5
#define doc_dowod       6
#define doc_metryk  	7
#define doc_niekar		8
#define doc_bron_krotka	9
#define doc_bron_auto	10
//#define doc_bron_stal	11

#define lek_none        0
#define lek_bandaz      1
#define lek_morfina     2

#define inveh_none      0
#define inveh_immo      1
#define inveh_alarm     2
#define inveh_audio     3
#define inveh_pc        4
#define inveh_neon      5

#define IsPlayerVisibleItems(%1) Item(%1, 1, item_uid)

#define player_down         1.0

#define weapon_flag_none    0
#define weapon_flag_paral   1
#define weapon_flag_nodmg   2

#define odcisk_type_none    0
#define odcisk_type_door    1
#define odcisk_type_item    2
#define odcisk_type_vehicle 3

#define nark_type_none      0
#define nark_type_amfa      1
#define nark_type_crack     2
#define nark_type_ecstasy   3
#define nark_type_grzyby    4
#define nark_type_heroina   5
#define nark_type_kokaina   6
#define nark_type_lsd       7
#define nark_type_marycha   8
#define nark_type_meta      9
#define nark_type_opium     10

// groups.pwn

#define member_type_none    0
#define member_type_group   1
#define member_type_doors   2
#define member_type_hotel   3

#define group_type_none		0
#define group_type_pd       1
#define group_type_mc       2
#define group_type_gov      3
#define group_type_fd       4
#define group_type_radio    5
#define group_type_gastro   6
#define group_type_workshop 7
#define group_type_binco    8
#define group_type_shop     9
#define group_type_build    10
#define group_type_syndykat 11
#define group_type_bank     12
#define group_type_gym      13
#define group_type_station  14
#define group_type_post     15
#define group_type_gang     16
#define group_type_mafia    17
#define group_type_taxi     18
#define group_type_kurier   19
#define group_type_vehhelp  20
#define group_type_salon    21
#define group_type_mebel    22
#define group_type_kartel   23
#define group_type_wojsko   24
#define group_type_elektro  25

#define member_can_vehicle  1 	// U¿ywanie pojazdów
#define member_can_door		2 	// Zamykanie drzwi
#define member_can_sell		4 	// Sprzedawanie /podaj
#define member_can_added	8 	// Przyjmowanie pracowników
#define member_can_product  16 	// Zamawianie produktów
#define member_can_gate     32 	// Ruszanie obiektami
#define member_can_door_opt	64  // Ustawienia drzwi
#define member_can_ooc    	128 // Pisanie na czacie IC i OOC
#define member_can_panel  	256 // Dostêp do panelu
#define member_can_nodel    512 // Nie mo¿na skasowaæ rangi
#define member_can_duty     1024 // Ranga pod nickiem

#define group_option_ooc    1   // Czat OOC
#define group_option_color  2   // Zmiana koloru i TAG w nicku na s³u¿bie
#define group_option_depar  4   // Dostêp do /d
#define group_option_id     8   // /pokaz id
#define group_option_duty   16  // duty w œrodku drzwi
#define group_option_take   32  // Zabieranie przedmiotów
#define group_option_przet  64  // Przetrzymanie
#define group_option_payout 128 // Wyp³acanie gotówki

// doors.pwn

#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define HOLDING(%0) \
	((newkeys & (%0)) == (%0))
#define RELEASED(%0) \
	(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))

#define door_type_none      0
#define door_type_group     1
#define door_type_house     2
#define door_type_bingo     3
#define door_type_hotel     4

#define door_option_none    0
#define door_option_audio   1
#define door_option_audio_out 2
#define door_option_przejazd 4
#define door_option_buy     8
#define door_option_card	16
#define door_option_paypass	32
#define door_option_sound   64

#define audio_price         600.00
#define sejf_price          340.00

// cmd.pwn

#define kom     			"{999ccc}"
#define kom2     			"{9378ab}"

#define NoPlayer(%1)        ShowCMD(%1, "Nie znaleziono gracza o podanym ID!")

// bank.pwn

#define bank_pin 		white"Podaj kod PIN."
#define bank_bankomat   "Wyp³aæ\nSprawdŸ stan konta\nInformacje o bankomacie"
#define bank_bank       "Wyp³aæ\nWp³aæ\nInformacje o koncie\nHistoria\nZmieñ PIN\nZmieñ nazwê konta\nWyrób kartê\nZablokuj kartê\n"red"Zablokuj konto"
#define bank_info       "\n\n"white"Op³ata pobierana po ka¿dej wyp³acie z konta."
#define bank_newpin     white"Podaj nowe has³o PIN do konta."
#define bank_block      red"Czy na pewno chcesz skasowaæ konto?\n"white"Podaj kod PIN, by potwierdziæ."
#define bank_deactive   red"Konto zosta³o usuniête lub jest nieaktywne"
#define bank_wplac      white"Podaj iloœæ gotówki, któr¹ chcesz wp³aciæ na konto."
#define bank_wyplac		white"Podaj iloœæ gotówki, któr¹ chcesz wyp³aciæ z konta.\n\nStan konta: $%.2f\n\n"red"Je¿eli jesteœ przy bankomacie, naliczana jest dodatkowa op³ata."
#define bank_wplata		white"Wp³aci³%sœ na konto w banku "green"$%.2f\n\n"white"Obecny stan konta: "green"$%.2f"
#define bank_wyplata    white"Wyp³aci³%sœ z banku "green"$%.2f\n\n"white"Obecny stan konta: "green"$%.2f"
#define bank_karte      green"Karta zosta³a zablokowana pomyœlnie!"
#define bank_checkbox   white"Podaj kwotê, która ma widnieæ na czeku"
#define bank_check      white"Wypisa³%sœ czek na $%.2f"
#define bank_chname		white"Podaj now¹ nazwê konta."

#define bank_type_none      0
#define bank_type_player    1
#define bank_type_group     2

#define bankomat_model      2942

// friends.pwn

#define message_type_none   0
#define message_type_sms    1
#define message_type_priv   2
#define message_type_raport 3

// offer.pwn

#define SEND_OFFER  		kom"Oferta zosta³a pomyœlnie wys³ana"white", poczekaj teraz na reakcjê odbiorcy."
#define OFFER_FALSE         red"Ktoœ temu graczu w³aœnie coœ oferuje, poczekaj."

#define offer_type_none     0
#define offer_type_item     1
#define offer_type_vehicle  2
#define offer_type_group    3
#define offer_type_product  4
#define offer_type_plate    5
#define offer_type_document 6
#define offer_type_ulotka   7
#define offer_type_comp     8
#define offer_type_spray    9
#define offer_type_konto    10
#define offer_type_element  11
#define offer_type_inveh    12
#define offer_type_tatoo    13
#define offer_type_doc      14
#define offer_type_anim     15
#define offer_type_tank     16
#define offer_type_repair   17
#define offer_type_leczenie 18
#define offer_type_rp       19
#define offer_type_taxi     20
#define offer_type_silownia 21
#define offer_type_walka    22
#define offer_type_mandat   23
#define offer_type_vcard    24
#define offer_type_hol      25
#define offer_type_blokada  26
#define offer_type_hotdog   27

#define offer_pay_cash		0
#define offer_pay_card		1
#define offer_pay_paypass	2

#define repair_none         0
#define repair_comp         1
#define repair_repair       2
#define repair_spray        3
#define repair_inveh        4

// station.pwn

#define station_owner_none  	0
#define station_owner_group		1
#define station_owner_player	2

// pickups.pwn

#define pickup_type_door       	-1
#define pickup_type_none        0
/*#define pickup_type_road        1
#define pickup_type_road2       2
#define pickup_type_mechanic    3
#define pickup_type_hotdog      4
#define pickup_type_smieciarz   5
#define pickup_type_fisher      6
#define pickup_type_kurier      7
#define pickup_type_newspeper   8*/

// orders.pwn

#define pack_status_none	0
#define pack_status_road	1
#define pack_status_end		2

#define price_kurier        20.00

// achiv.pwn

#define achiv_none		0
#define achiv_login		1 // Pierwsze logowanie
#define achiv_veh		2 // Pierwszy pojazd
#define achiv_join		4 // Pierwsze zatrudnienie
#define achiv_gun		8 // Pora postrzelaæ
#define achiv_kara		16  // Ukarany
#define achiv_time      32  // 10h
#define achiv_jail      64  // Jail
#define achiv_job       128 // Legalna praca
#define achiv_lider     256 // Przywodca
#define achiv_bw        512 // Poszkodowany
#define achiv_bank      1024 // Male oszczednosci
#define achiv_npc       2048 // Bóg zap³aæ

// admin.pwn

#define create_cat_none 	0
#define create_cat_veh  	1
#define create_cat_item 	2
#define create_cat_door 	3
#define create_cat_obj  	4
#define create_cat_group   	5
#define create_cat_eveh 	6
#define create_cat_eobj 	7
#define create_cat_eitem 	8
#define create_cat_edoor 	9
#define create_cat_egroup   10
#define create_cat_estref	11
#define create_cat_pick     12
#define create_cat_strefa   13

#define create_edit_hp          1
#define create_edit_distance    2
#define create_edit_color       3
#define create_edit_model       4
#define create_edit_fuel        5
#define create_edit_delete      6
#define create_edit_owner       7
#define create_edit_owner2      8
#define create_edit_value1      9
#define create_edit_value2      10
#define create_edit_value3      11
#define create_edit_name      	12
#define create_edit_type        13
#define create_edit_person      14
#define create_edit_flags       15
#define create_edit_in_vw       16
#define create_edit_inside      17
#define create_edit_outside     18
#define create_edit_interior    19
#define create_edit_pickup      20
#define create_edit_out_vw      21
#define create_edit_interior2   22
#define create_edit_to          23
#define create_edit_range       24
#define create_edit_add         25
#define create_edit_plate       26

#define admin_perm_none         0
#define admin_perm_kick         1
#define admin_perm_ban          2
#define admin_perm_block        4
#define admin_perm_set          8
#define admin_perm_create       16
#define admin_perm_edit         32
#define admin_perm_slap         64
#define admin_perm_bw           128
#define admin_perm_tp           256
#define admin_perm_blockad      512
#define admin_perm_glob         1024
#define admin_perm_globdo       2048
#define admin_perm_aj           4096
#define admin_perm_spec         8192
#define admin_perm_server       16384

// zone.pwn

#define zone_none           0
#define zone_parking        1

#define zone_owner_none     0
#define zone_owner_group    1
#define zone_owner_player   2

// checkpoint.pwn

#define check_type_none     0
#define check_type_group    1
#define check_type_job      2

// npc.pwn

#define npc_func_none       0
#define npc_func_gov        1
#define npc_func_drive      2
#define npc_func_achiv      3

// pc.pwn

#define pc_login    white"Podaj login:"
#define pc_pass     white"Podaj has³o:"

#define pc_perm_none    0
#define pc_perm_user    1
#define pc_perm_admin   2

#define select_none     0
#define select_char     1
#define select_veh      2
#define select_wpis     3

#define pd_none			0 	// Brak funkcji
#define pd_mandat		1   // Mandat
	// v1: pkt
	// v2: kwota
#define pd_block		2   // Blokada ko³a
	// v2: kwota
#define pd_ostrz		3   // Notatka
#define pd_jail         4   // Odsiadka
	// v1: czas w sekundach

#define pc_user_none    0
#define pc_user_pd      1
#define pc_user_mc      2

// tel.pwn

#define phone_none  0
#define phone_off   1
#define phone_mute  2

// End
