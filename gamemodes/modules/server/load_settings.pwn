
enum sver
{
	ID,
	Name[64],
	Version[32],
	Locked,
	Password[32],
	Weather
};

new Server[sver];

forward LoadSettings(id);
public LoadSettings(id)
{
	if(cache_num_rows())
    {

    	cache_get_value_name_int(0, "ID", Server[ID] );
  		cache_get_value_name(0, "Name", Server[Name]);
  		cache_get_value_name(0, "Version", Server[Version]);
		cache_get_value_name_int(0, "Locked", Server[Locked]);
		cache_get_value_name(0, "Password", Server[Password]);
		cache_get_value_name_int(0, "Weather", Server[Weather]);

		new str[128];
		if(Server[Locked] == 1)
		{

			format(str, sizeof(str), "password %s", Server[Password]);
			SendRconCommand(str);
		}
		else if(Server[Locked] == 0)
		{
			SendRconCommand("password ");
		}
		format(str, sizeof(str), "hostname %s", Server[Name]);
		SendRconCommand(str);

		format(str, sizeof(str), "gamemodetext %s", Server[Version]);
		SendRconCommand(str);

		printf("[MYSQL]: Server Settings Loaded.", id);
	}
	else
	{
		print("ERROR: Loading Settings");
	}
	return 1;
}

