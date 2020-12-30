#include <a_samp>
#include <discord-connector>
#include <discord-commands>

#define ANTICHEAT "610721144567496704"
#define REPORTS "610780079521529856"
#define DISCORD_GUILD "658341890516844575"

stock IsUserDiscordAdmin(DCC_User: user)
{
	new DCC_Guild:guildId = DCC_FindGuildById(DISCORD_GUILD),
		DCC_Role:leadAdminRole,
		DCC_Role:adminRole,
		DCC_Role:devRole,
		DCC_Role:managementRole,
		bool: hasRole = false;
	
	leadAdminRole = DCC_FindRoleByName(guildId, "Lead Admin");
	adminRole = DCC_FindRoleByName(guildId, "Admin");
	devRole = DCC_FindRoleByName(guildId, "Server Developer");
	managementRole = DCC_FindRoleByName(guildId, "Management");

	if(leadAdminRole) {
		DCC_HasGuildMemberRole(guildId, user, leadAdminRole, hasRole);

		if(hasRole) return 1;
	}

	if(adminRole) {
		DCC_HasGuildMemberRole(guildId, user, adminRole, hasRole);

		if(hasRole) return 1;
	}

	if(devRole) {
		DCC_HasGuildMemberRole(guildId, user, devRole, hasRole);

		if(hasRole) return 1;
	}

	if(managementRole) {
		DCC_HasGuildMemberRole(guildId, user, managementRole, hasRole);

		if(hasRole) return 1;
	}
	return 0;
}

DQCMD:kick(DCC_Channel:channel, DCC_User:user, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	extract params -> new player:target, string:reason[128]; else return DCC_SendChannelMessage(channel, "**USAGE:** !kick [player name/playerid] [reason]");
	if(!IsPlayerConnected(target)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected.");

	new admin[64];
	DCC_GetUserName(user, admin, sizeof(admin));
	DCC_SendChannelMessage(channel, sprintf("**PUNISHMENT:** %s was kicked from the server, reason: %s", GetName(target), reason));
	SendClientMessageToAll(COLOR_LIGHTRED, sprintf("PUNISHMENT: %s was kicked from the server by %s, reason: %s", GetName(target), admin, reason));
	SendAdminsMessage(1, COLOR_GRAY, sprintf("{bf0000}Admin Notice: {FFFFFF}%s has been kicked via Discord.", GetName(target)));
	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp) VALUES('%e', '%e', '/kick', '%e', %d)", admin, GetName(target), reason, gettime()));
	Account[target][Kicks]++;
	KickPlayer(target);
	return 1;
}

DQCMD:ban(DCC_Channel:channel, DCC_User:user, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	extract params -> new player:target, string:reason[128]; else return DCC_SendChannelMessage(channel, "**USAGE:** !ban [player name/playerid] [reason]");
	if(!IsPlayerConnected(target)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected.");
	if(Account[target][Admin] >= 1) return DCC_SendChannelMessage(channel, "**ERROR:** You can't ban an admin.");

	new admin[64];
	DCC_GetUserName(user, admin, sizeof(admin));
	SendClientMessageToAll(COLOR_LIGHTRED, sprintf("PUNISHMENT: %s was banned from the server by %s via Discord, reason: %s", GetName(target), admin, reason));
	DCC_SendChannelMessage(channel, sprintf("**PUNISHMENT:** %s was banned from the server by %s, reason: %s", GetName(target), admin, reason));
	IssueBan(target, admin, reason);
	KickPlayer(target);
	return 1;
}

DQCMD:unban(DCC_Channel:channel, DCC_User:user, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	yield 1;
	await mysql_aquery_s(SQL_CONNECTION, str_format("DELETE FROM `Bans` WHERE PlayerName = '%e'", params));

	if(cache_affected_rows()) //a row was found, player was unbanned
	{
		new admin[64];
		DCC_GetUserName(user, admin, sizeof(admin));
		DCC_SendChannelMessage(channel, sprintf("**PUNISHMENT:** %s was unbanned from the server by %s.", params, admin));
		mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp) VALUES('%e', '%e', '/unban', 'N/A', '%d')", admin, params, gettime()));
	}
	else DCC_SendChannelMessage(channel, sprintf("%s is not currently banned from the server.", params));
	return 1;
}
	
DQCMD:asay(DCC_Channel:channel, DCC_User:user, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;
	if(isnull(params)) return DCC_SendChannelMessage(channel, "```USAGE: !asay [message]```");

	new admin[64];
	DCC_GetUserName(user, admin, sizeof(admin));

	new string[256];
	format(string, sizeof(string), "[Discord Announcement] %s: %s", admin, params);
	DCC_SendChannelMessage(channel, string);
	foreach(new i: Player)
	{
		if(Account[i][LoggedIn] == 1)
		{
			SendClientMessage(i, COLOR_VIOLET, string);
		}
	}
	return 1;
}

DQCMD:cmds(DCC_Channel:channel, DCC_User:user, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	DCC_SendChannelMessage(channel, "```cmds, ip, mute, kick, ajail (to-do), offlinejail (to-do), aunjail, ban, remoteban (to-do), unban, asay, freeze, unfreeze, fpscheck, flinchcheck, aimprofile, players, admins, whois (to-do)```");
	return 1;
}

DQCMD:freeze(DCC_Channel:channel, DCC_User:user, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	extract params -> new player:target; else return DCC_SendChannelMessage(channel, "```USAGE: !freeze [player name/playerid]```");
	if(!IsPlayerConnected(target)) return DCC_SendChannelMessage(channel, "**ERROR: Invalid player id!**");

	new admin[64];
	DCC_GetUserName(user, admin, sizeof(admin));

	TogglePlayerControllable(target, false);
	SendAdminsMessage(1, COLOR_GRAY, sprintf("{bf0000}Admin Notice: {FFFFFF}%s has been frozen via discord.", GetName(target)));
	SendClientMessage(target, COLOR_GRAY, sprintf("{bf0000}Notice: {FFFFFF}You have been frozen by an admin.", GetName(target)));
	DCC_SendChannelMessage(channel, sprintf("**PUNISHMENT:** %s was frozen by %s.", GetName(target), admin));
	return 1;
}

DQCMD:unfreeze(DCC_Channel:channel, DCC_User:user, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	extract params -> new player:target; else return DCC_SendChannelMessage(channel, "USAGE: !unfreeze [player name/playerid]");
	if(!IsPlayerConnected(target)) return DCC_SendChannelMessage(channel, "**ERROR:** Invalid player id!");

	new admin[64];
	DCC_GetUserName(user, admin, sizeof(admin));

	TogglePlayerControllable(target, true);
	SendAdminsMessage(1, COLOR_GRAY, sprintf("{bf0000}Admin Notice: {FFFFFF}%s has been unfrozen via discord.", GetName(target)));
	SendClientMessage(target, COLOR_GRAY, sprintf("{bf0000}Notice: {FFFFFF}You have been unfrozen by an admin.", GetName(target)));
	DCC_SendChannelMessage(channel, sprintf("**PUNISHMENT:** %s was unfrozen by %s.", GetName(target), admin));
	return 1;
}

DQCMD:players(DCC_Channel:channel, DCC_User:user, params[])
{
	if(!Iter_Count(Player)) return DCC_SendChannelMessage(channel, "There are no players online.");

	DCC_SendChannelMessage(channel, sprintf("**PLAYERS ONLINE: (%i)**", Iter_Count(Player)));

	new string[2056]; //probably overkill array size but whatever
	foreach(new i: Player)
	{
		strcat(string, sprintf("%s (ID %i)\n", GetName(i), i));
	}
	DCC_SendChannelMessage(channel, string);
	return 1;
}

DQCMD:admins(DCC_Channel:channel, DCC_User:user, params[])
{
	new List:adminlist = list_new(), admin[2];
	foreach(new i: Player)
	{    
		if(Account[i][Admin] != 0)
		{
			admin[0] = i;
			admin[1] = Account[i][Admin];
			list_add_arr(adminlist, admin);
		}
	}
	if(!list_size(adminlist))
	{
		list_delete(adminlist);
		DCC_SendChannelMessage(channel, "There are no admins online.");
		return true;
	}
	else {
		DCC_SendChannelMessage(channel, "**ADMINS ONLINE**:");
	}
	list_sort(adminlist, 1, -1, true);
	for_list(i: adminlist)
	{
		iter_get_arr(i, admin);
		DCC_SendChannelMessage(channel, sprintf("(Level %s Admin) %s (ID %i)", AdminNames(admin[1]), GetName(admin[0]), admin[0]));
	}
	list_delete(adminlist);
	return true;
}

DQCMD:fpscheck(DCC_Channel:channel, DCC_User:user, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	extract params -> new player:target; else return DCC_SendChannelMessage(channel, "**USAGE:** !fpscheck [player name/playerid]");
	if(!IsPlayerConnected(target)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected!");

	DCC_SendChannelMessage(channel, sprintf("**FPS CHECK:** User **%s** has **%d** FRAMES PER SECOND.", GetName(target), pFPS[target]));
	return 1;
}

DQCMD:aimprofile(DCC_Channel:channel, DCC_User:user, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	extract params -> new player:target, string:weapon[32] = ""; else return DCC_SendChannelMessage(channel, "**USAGE:** !aimprofile [playerid or name] [optional: weapon]");
	if(!IsPlayerConnected(target)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected!");

	new allshots, hitshots, max_cont_shots, out_of_range_warns, random_aim_warns, proaim_tele_warns, wepname[32];
	if(isnull(weapon))
	{
		BustAim::GetPlayerProfile(target, allshots, hitshots, max_cont_shots, out_of_range_warns, random_aim_warns, proaim_tele_warns);
		wepname = "All Weapons";
	}
	else
	{
		new WeaponID = GetWeaponIDFromName(weapon);
		BustAim::GetPlayerWeaponProfile(target, WeaponID, allshots, hitshots, max_cont_shots, out_of_range_warns, random_aim_warns, proaim_tele_warns);
		format(wepname, 32, WeaponNameList[WeaponID]);
	}

	DCC_SendChannelMessage(channel, "\n");
	DCC_SendChannelMessage(channel, sprintf("Aim Profile of %s (%i) - %s", GetName(target), target, wepname));
	DCC_SendChannelMessage(channel, sprintf("Bullets Fired: %i", allshots));
	DCC_SendChannelMessage(channel, sprintf("Bullets Hit: %i", hitshots));
	DCC_SendChannelMessage(channel, sprintf("Hit Percentage: %.2f%%", ((hitshots*100.0) / allshots)));
	DCC_SendChannelMessage(channel, sprintf("Highest Continuous Shots: %i", max_cont_shots));
	DCC_SendChannelMessage(channel, sprintf("Out of Range Shots: %i", out_of_range_warns));
	DCC_SendChannelMessage(channel, sprintf("Random Aim Warnings: %i", random_aim_warns));
	DCC_SendChannelMessage(channel, sprintf("Proaim Teleport Warnings: %i", proaim_tele_warns));
	DCC_SendChannelMessage(channel, "\n");
	return true;
}

DQCMD:flinchcheck(DCC_Channel:channel, DCC_User:user, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	extract params -> new player:target; else return DCC_SendChannelMessage(channel, "**USAGE:** !flinchcheck [player name/playerid]");
	if(!IsPlayerConnected(target)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected!");
	if(TimesHit[target] == 0) return DCC_SendChannelMessage(channel, "**ERROR:** This player has not been shot yet.");

	DCC_SendChannelMessage(channel, sprintf("%s (%i) flinch stats - Times Hit: %i Times Flinched: %i (%.2f%%)", GetName(target), target, TimesHit[target], FlinchCount[target], (FlinchCount[target] / TimesHit[target] * 100)));
	return true;
}

DQCMD:whois(DCC_Channel:channel, DCC_User:user, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	extract params -> new player:target; else return DCC_SendChannelMessage(channel, "**USAGE:** !whois [player name/playerid]");
	if(!IsPlayerConnected(target)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected!");

	new ip[16], country[64], isp[256];
	GetPlayerIp(target, ip, sizeof(ip));
	GetPlayerCountry(target, country, sizeof(country));
	GetPlayerISP(target, isp, sizeof(isp));

	DCC_SendChannelMessage(channel, sprintf("**[WHOIS]** IP Address info for %s (ID %d) (current session):", GetName(target), target));
	DCC_SendChannelMessage(channel, sprintf("**[WHOIS]** IP Address: %s | Location: %s", ip, country));
	DCC_SendChannelMessage(channel, sprintf("**[WHOIS]** ISP: %s", isp));
	if(Account[target][pVPN] == 1) DCC_SendChannelMessage(channel, "**[WHOIS]** This player is using a VPN/proxy!");
	return 1;
}

DQCMD:ajail(DCC_Channel:channel, DCC_User:user, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	extract params -> new player:target, minutes, string:reason[64]; else return DCC_SendChannelMessage(channel, "**USAGE:** /ajail [player name/playerid] [minutes] [reason]");
	if(!IsPlayerConnected(target)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected!");

	new admin[64];
	DCC_GetUserName(user, admin, sizeof(admin));

	Account[target][AJailTime] = minutes;
	if(ActivityState[target] == ACTIVITY_TDM)
	{
		if(GetPlayerTeam(target) < 100)
		{
			RemoveFromTDM(target, ActivityStateID[target]);
		}
		if(GetPlayerTeam(target) > 100 || ActivityState[target] == ACTIVITY_COPCHASE)
		{
			if(Account[target][pCopchase] == 2)
			{
				new msg[128];
				format(msg, sizeof(msg), "%s has left. [%d players remaining]", GetName(target), GetCopchaseTotalPlayers() - 1);
				SendCopchaseMessage(msg);
				Account[target][pCopchase] = 0;
				PlayerTextDrawHide(target, Account[target][TextDraw][1]);
				PlayerTextDrawHide(target, Account[target][TextDraw][0]);
				PlayerTextDrawHide(target, Account[target][TextDraw][2]);
				PlayerTextDrawHide(target, Account[target][TextDraw][3]);
				TogglePlayerControllable(target, 1);
				StartCopchase(); // checking if game is over
			}
			else if(Account[target][pCopchase] == 3)
			{
				Account[target][pCopchase] = 0;
				PlayerTextDrawHide(target, Account[target][TextDraw][1]);
				PlayerTextDrawHide(target, Account[target][TextDraw][0]);
				PlayerTextDrawHide(target, Account[target][TextDraw][2]);
				PlayerTextDrawHide(target, Account[target][TextDraw][3]);
				TogglePlayerControllable(target, 1);
				StartCopchase(); // terminating it
			}
			else if(Account[target][pCopchase] == 1){
				new msg[128];
				Account[target][pCopchase] = 0;
				format(msg, sizeof(msg), "{%06x}%s{FFFFFF} has left. [%d players in queue]", GetPlayerColor(target) >>> 8, GetName(target), GetCopchaseTotalPlayers() - 1);
				SendCopchaseMessage(msg);

				PlayerTextDrawHide(target, Account[target][TextDraw][1]);
				PlayerTextDrawHide(target, Account[target][TextDraw][0]);
				PlayerTextDrawHide(target, Account[target][TextDraw][2]);
				PlayerTextDrawHide(target, Account[target][TextDraw][3]);
			}

			foreach(new p : Player)
			{
				SetPlayerMarkerForPlayer(target, p, GetPlayerColor(p) | 0x000000FF);
			}
			DestroyAllPlayerObjects(target);

			SetPlayerTeam(target, NO_TEAM);
			GangZoneHideForPlayer(target, igsturf);
			DisablePlayerCheckpoint(target);
			cancapture[target] = 0;
			RemovePlayerMapIcon(target, 1);
			SendPlayerToLobby(target);
			Account[target][CopChaseDead] = 0;
			inAmmunation[target] = 0;
		}
	}
	ActivityState[target] = ACTIVITY_LOBBY;
	ActivityStateID[target] = -1;

	CreateLobby(target);
	SetPlayerSkin(target, 20051);
	SetPlayerPosEx(target, 2518.7590, 602.5683, 45.2066, 0, 0);

	SendClientMessageToAll(COLOR_LIGHTRED, sprintf("PUNISHMENT: Admin %s via discord has a-jailed %s for %d minutes! Reason: %s", admin, GetName(target), minutes, reason));
	SendAdminsMessage(1, COLOR_GRAY, sprintf("{bf0000}Admin Notice: {FFFFFF}%s via discord has a-jailed %s! Reason: %s", admin, GetName(target), reason));

	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp, ajailtime) VALUES('%e', '%e', '/ajail', '%e', '%d', '%i')", admin, GetName(target), reason, gettime(), minutes));
	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE Accounts SET ajail_minutes = %i WHERE SQLID = %i", minutes, Account[target][SQLID]));

	ResetPlayerWeapons(target);
	return 1;
}

DQCMD:aunjail(DCC_Channel:channel, DCC_User:user, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	extract params -> new player:target; else return DCC_SendChannelMessage(channel, "**USAGE:** /unjail [player name/playerid]");
	if(!IsPlayerConnected(target)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected!");
	if(!Account[target][AJailTime]) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not in ajail.");

	new admin[64];
	DCC_GetUserName(user, admin, sizeof(admin));

	Account[target][AJailTime] = 0;
	SendPlayerToLobby(target);

	DCC_SendChannelMessage(channel, sprintf("**PUNISHMENT:** %s was unjailed by %s.", GetName(target), admin));
	SendClientMessageToAll(COLOR_LIGHTRED, sprintf("PUNISHMENT: %s was unjailed by %s via Discord.", GetName(target), admin));
	SendClientMessage(target, -1, sprintf("{bf0000}Notice: {FFFFFF}You have been unjailed by %s via Discord.", admin));
	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE Accounts SET ajail_minutes = 0 WHERE SQLID = %i", Account[target][SQLID]));
	return 1;
}

DQCMD:mute(DCC_Channel:channel, DCC_User:user, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	extract params -> new player:target, minutes, string:reason[64]; else return DCC_SendChannelMessage(channel, "**USAGE:** /mute [player name/playerid] [minutes] [reason]");
	if(!IsPlayerConnected(target)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected!");

	new admin[64];
	DCC_GetUserName(user, admin, sizeof(admin));

	Account[target][Muted] = gettime() + minutes*60;
	Account[target][Mutes]++;

	DCC_SendChannelMessage(channel, sprintf("**PUNISHMENT:** %s was muted by %s, reason: %s", GetName(target), admin, reason));
	SendClientMessageToAll(COLOR_LIGHTRED, sprintf("PUNISHMENT: %s was muted by %s via Discord, reason: %s", GetName(target), admin, reason));
	SendAdminsMessage(1, COLOR_GRAY, sprintf("{bf0000}Admin Notice: {FFFFFF}%s has muted %s via Discord for %i minutes! Reason: %s", admin, GetName(target), minutes, reason));
	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp) VALUES('%e', '%e', '/mute', '%e', '%d')", admin, GetName(target), reason, gettime()));
	return 1;
}

DQCMD:unmute(DCC_Channel:channel, DCC_User:user, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	extract params -> new player:target; else return DCC_SendChannelMessage(channel, "**USAGE:** /unmute [player name/playerid]");
	if(!IsPlayerConnected(target)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected!");

	new admin[64];
	DCC_GetUserName(user, admin, sizeof(admin));

	Account[target][Muted] = 0;

	DCC_SendChannelMessage(channel, sprintf("**PUNISHMENT:** %s was unmuted by %s.", GetName(target), admin));
	SendClientMessageToAll(COLOR_LIGHTRED, sprintf("PUNISHMENT: %s was unmuted by %s via Discord.", GetName(target), admin));
	SendAdminsMessage(1, COLOR_GRAY, sprintf("{bf0000}Admin Notice: {FFFFFF}%s has unmuted %s via Discord.", admin, GetName(target)));
	SendClientMessage(target, COLOR_GRAY, "{bf0000}Notice: {FFFFFF}You have been unmuted by an admin.");
	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp) VALUES('%e', '%e', '/unmute', 'N/A', '%d')", admin, GetName(target), gettime()));
	return 1;
}

DQCMD:ip(DCC_Channel:channel, DCC_User:user, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	extract params -> new player:target; else return DCC_SendChannelMessage(channel, "**USAGE:** /ip [player name/playerid]");
	if(!IsPlayerConnected(target)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected!");

	new countryname[40], countryregion[40], playerisp[40], ipaddress[18];
	GetPlayerIp(target, ipaddress, 18);
	GetPlayerCountry(target, countryname);
	GetPlayerRegion(target, countryregion);
	GetPlayerISP(target, playerisp);

	DCC_SendChannelMessage(channel, sprintf("IP Address: %s, Country: %s, Area: %s", ipaddress, countryname, countryregion));
	DCC_SendChannelMessage(channel, sprintf("Server Latency: %ims, ISP: %s", GetPlayerPing(target), playerisp));
	return 1;
}
