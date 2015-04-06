FuncPub::LoadSocket()
{
	Setting(setting_socket) = socket_create(TCP);
	if(is_socket_valid(Setting(setting_socket)))
	{
		socket_set_max_connections(Setting(setting_socket), 10);
		socket_listen(Setting(setting_socket), 6614);
	}
	return 1;
}

public onSocketRemoteConnect(Socket:id, remote_client[], remote_clientid)
{
	printf("Incoming connection from [%d:%s]", remote_clientid, remote_client); // [id:ip]
//	socket_send(id, "Welcome :)");
	return 1;
}

public onSocketRemoteDisconnect(Socket:id, remote_clientid)
{
	printf("Remote client [%d] has disconnected.", remote_clientid); // [id:ip]
	return 1;
}

public onSocketReceiveData(Socket:id, remote_clientid, data[], data_len)
{
	printf("%d Dane od klienta [%d] odebrane: %s", gettime(), remote_clientid, data); // id & data
	return 1;
}
