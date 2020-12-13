new bool:ClanVehicles[MAX_VEHICLES] = {false, ...};

CMD<CM>:setofficial(cmdid, playerid, params[])
{
	new TargetClan[64], level;
	if(sscanf(params, "s[64]i", TargetClan, level)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /setofficial [clanname] [level] (1 = official, 0 = unofficial)");

	yield 1;
	await mysql_aquery_s(SQL_CONNECTION, str_format("SELECT * FROM clans WHERE name = '%e'", TargetClan));
	if(!cache_num_rows()) return SendClientMessage(playerid, COLOR_GRAY, sprintf("No clan exists with the name %s.", TargetClan));

	new OldLevel;
	cache_get_value_name_int(0, "official", OldLevel);
	if(OldLevel == level) return SendClientMessage(playerid, COLOR_GRAY, "This clan already has this level status!");

	new clanid, clanname[64];
	cache_get_value_name_int(0, "id", clanid);
	cache_get_value_name(0, "name", clanname);
	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE clans SET official = %i WHERE id = %d", level, clanid));
	SendClanMessage(clanid, clanname, sprintf("Your clan %s has been set to official by Clan Manager %s", clanname, GetName(playerid)));
	SendClientMessage(playerid, COLOR_LIGHTRED, sprintf("CLAN MANAGEMENT: You have set %s's official clan level to %i.", clanname, level));
	UpdateClanOfficialLevel(clanid, level);
	return 1;
}
CMD<CM>:respawnclanvehicles(cmdid, playerid, params[])
{
	DeleteAllClanVehicles();
	return true;
}
CMD<CM>:createclanvehicle(cmdid, playerid, params[])
{
	new vehicleid[20], State = GetPlayerState(playerid);
	if(GetPlayerVirtualWorld(playerid) != WORLD_TDM) return SendErrorMessage(playerid, "You must be in the Team Deathmatch mode to spawn a clan vehicle!");
	if(State == PLAYER_STATE_DRIVER) return SendErrorMessage(playerid, "You are currently driving a vehicle.");
	if(sscanf(params, "s[20]", vehicleid)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /veh [modelid/name]");
	new vID = FindVehicleByNameID(vehicleid);
	if(vID == INVALID_VEHICLE_ID)
	{
		vID = strval(vehicleid);
		if(!(399 < vID < 612)) return SendErrorMessage(playerid, ERROR_OPTION);
	}
	new Float: curX, Float: curY, Float: curZ, Float: curR;

	GetPlayerPos(playerid, curX, curY, curZ);
	GetPlayerFacingAngle(playerid, curR);
	FreeroamVehicle[playerid] = CreateVehicle(vID, curX+1, curY+1, curZ, curR, -1, -1, -1);
	LinkVehicleToInterior(FreeroamVehicle[playerid], GetPlayerInterior(playerid));
	SetVehicleVirtualWorld(FreeroamVehicle[playerid], GetPlayerVirtualWorld(playerid));

	PutPlayerInVehicle(playerid, FreeroamVehicle[playerid], 0);
	SetVehicleNumberPlate(FreeroamVehicle[playerid], "Koky's DM");
	SetVehicleParamsEx(FreeroamVehicle[playerid], 1, 1, 0, 0, 0, 0, 0);
	SendClientMessage(playerid, COLOR_GRAY, sprintf("{31AEAA}Clan Management:{FFFFFF} You have successfully spawned a %s. Use /saveclanvehicle [clanname] to save the position.", vehNames[vID-400]));
	return 1;
}
CMD<CM>:deletevehicle(cmdid, playerid, params[])
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		DestroyVehicle(GetPlayerVehicleID(playerid));
	}
	return true;
}
CMD<CM>:saveclanvehicle(cmdid, playerid, params[])
{
	if(isnull(params)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /saveclanvehicle [clanname]");
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendErrorMessage(playerid, "You must be in a clan vehicle. Refer to /createclanvehicle.");
	if(!ClanAlreadyExists(params)) return SendClientMessage(playerid, COLOR_GRAY, sprintf("No clan been found with the name %s.", params));

	new vehicleid, vehiclemodel, Float:x, Float:y, Float:z, Float:a;
	vehicleid = GetPlayerVehicleID(playerid);
	vehiclemodel = GetVehicleModel(vehicleid);
	GetVehiclePos(vehicleid, x, y, z);
	GetVehicleZAngle(vehicleid, a);

	new clanid = GetClanIDFromName(params);
	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO clan_vehicles (clan_id, vehicle_id, clan_name, x, y, z, a) VALUES(%i, %i, '%s', %f, %f, %f, %f)", clanid, vehiclemodel, params, x, y, z, a));
	DestroyVehicle(vehicleid);
	DeleteAllClanVehicles();
	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Clan Management: You have sucessfully set the clan vehicle in the database.");
	return true;
}
CMD<CM>:setspawn(cmdid, playerid, params[])
{
	if(isnull(params)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /setspawn [clanname]");
	if(!ClanAlreadyExists(params)) return SendClientMessage(playerid, COLOR_GRAY, sprintf("No clan been found with the name %s.", params));

	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE clans SET x = %f, y = %f, z = %f WHERE name =  '%e'", x, y, z, params));
	SendClientMessage(playerid, COLOR_LIGHTBLUE, "You have set the clans spawn point. Please take a screenshot of the map to prevent near-by spawn issues. Post it in the Discord!");
	return 1;
}

CMD<CM>:setclanskin(cmdid, playerid, params[])
{
	new TargetClan[64], skinid;
	if(sscanf(params, "s[64]i", TargetClan, skinid)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /setclanskin [clanname] [skinid]");

	yield 1;
	await mysql_aquery_s(SQL_CONNECTION, str_format("SELECT * FROM clans WHERE skin = %i", skinid));
	if(cache_num_rows()) return SendClientMessage(playerid, COLOR_LIGHTRED, "A clan is already using this skin!");

	SendClientMessage(playerid, COLOR_LIGHTBLUE, sprintf("You have set the clans skin to %i!", skinid));
	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE clans SET skin = %i WHERE name = '%e'", skinid, TargetClan));
	return 1;
}

SpawnAllClanVehicles()
{
	await mysql_aquery(SQL_CONNECTION, "SELECT * FROM clan_vehicles");
	if(!cache_num_rows()) return true;

	new carid, clanname[32], idclan, vehid, Float:x, Float:y, Float:z, Float:a;
	for(new i = 0, r = cache_num_rows(); i < r; i++)
	{
		cache_get_value_name_int(i, "clan_id", idclan);
		cache_get_value_name_int(i,	"vehicle_id", vehid);
		cache_get_value_name(i, "clan_name", clanname);
		cache_get_value_name_float(i, "x", x);
		cache_get_value_name_float(i, "y", y);
		cache_get_value_name_float(i, "z", z);
		cache_get_value_name_float(i, "a", a);

		carid = AddStaticVehicleEx(vehid, x, y, z, a, PlayerColors[idclan + 5], PlayerColors[idclan + 5], 60, 0);
		SetVehicleNumberPlate(carid, clanname);
		LinkVehicleToInterior(carid, 0);
		SetVehicleVirtualWorld(carid, WORLD_TDM);
		ClanVehicles[carid] = true;
	}	
	return true;
}
DeleteAllClanVehicles()
{
	foreach(new v: Vehicle)
	{
	    if(GetVehicleModel(v) != 0) // if vehicle id valid
	    {
	        DestroyVehicle(v);
	        ClanVehicles[v] = false;
	    }
	}
	return SpawnAllClanVehicles();
}
UpdateClanOfficialLevel(clanid, level)
{
	foreach(new i: Player)
	{
		if(Account[i][ClanID] == clanid)
		{
			Account[i][OfficialClan] = level;
			SendClientMessage(i, COLOR_LIGHTRED, sprintf("Clan status has been updated to %i", level));
		}
	}
	return true;
}