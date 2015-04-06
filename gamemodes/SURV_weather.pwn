#define IN_WEATHER "link.php"

FuncPub::LoadWeather()
{
	if(!HTTP(1, HTTP_GET, IN_WEATHER, "", "Pogoda"))
		return LoadStandartWeather();
	return 1;
}

FuncPub::LoadStandartWeather()
{
	Setting(setting_weather) = Weathers[random(sizeof(Weathers))];
	SetWeather(Setting(setting_weather));
	return 1;
}

FuncPub::Pogoda(index, response_code, data[])
{
	if(response_code != 200)
		return LoadStandartWeather();

	new
		wset;
	strdel(data, 0, 72);
	strdel(data, strfind(data, "alt", true) - 2, strfind(data, "<br", true) + 5);

	if(strfind(data, "burz", true) != -1)
	    wset = 8;
	else if(strfind(data, "deszcz", true) != -1)
	    wset = 16;
	else if(strfind(data, "mg³a", true) != -1 || strfind(data, "mgla", true) != -1 || strfind(data, "mglisto", true) != -1)
	    wset = 9;
	else if(strfind(data, "s³onecznie", true) != -1 || strfind(data, "slonce", true) != -1 || strfind(data, "s³oñce", true) != -1 || strfind(data, "bezchmurnie", true) != -1)
	    wset = 0;
	else
		wset = Weathers[random(sizeof(Weathers))];
 	Setting(setting_weather) = wset;
	SetWeather(Setting(setting_weather));
	return 1;
}
