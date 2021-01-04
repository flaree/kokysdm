#include <a_samp>
#include <discord-connector>
#include <discord-commands>

#define DISCORD_GUILD "795532086605774859"
#define ANTICHEAT "795532204461391892"
#define REPORTS_G "795532280734679081"
#define ADMIN_CHANNEL "795532135812300811"
#define LEAD_CHANNEL "795532161842544670"
#define IG_CHANNEL "795532352759267359"
#define BOT_NAME "kdm test"

public DCC_OnMessageCreate(DCC_Message:message)
{
	new DCC_Channel:channel, DCC_User: author;
	new DCC_Guild:guildId = DCC_FindGuildById(DISCORD_GUILD);
	new content[1000],  username[33], channelid[DCC_ID_SIZE], bot_id[DCC_ID_SIZE];
	DCC_GetMessageChannel(message, channel);
	DCC_GetMessageContent(message, content, sizeof content);
	DCC_GetMessageAuthor(message, author);
	DCC_GetGuildMemberNickname(guildId, author, username, sizeof username);
	DCC_GetUserId(author, bot_id, sizeof bot_id);

	if(isequal(username, ""))
	{
		DCC_GetUserName(author, username, sizeof username);
	}

	if(isequal(bot_id, "794703578832437268")){
		return 1;
	}
	DCC_GetChannelId(channel, channelid, sizeof channelid);
	if(isequal(channelid, ADMIN_CHANNEL))
	{
		SendDiscordAdmMessage(1, COLOR_RED, sprintf("{FFFF80}%s: %s", username, content));
	} else if(isequal(channelid, LEAD_CHANNEL))
	{
		SendLeadsDiscordMessage(0x3FE629FF, sprintf("%s: %s", username, content));
	} else if(isequal(channelid, IG_CHANNEL))
	{
		new DCC_Role:leadAdminRole,
			DCC_Role:adminRole,
			DCC_Role:devRole,
			DCC_Role:managementRole,
			bool: hasRole = false;
		leadAdminRole = DCC_FindRoleByName(guildId, "Lead Admin");
		devRole = DCC_FindRoleByName(guildId, "Server Developer");
		adminRole = DCC_FindRoleByName(guildId, "Admin");
		managementRole = DCC_FindRoleByName(guildId, "Management");
		new color[16] = "FFFFFF";
		if(adminRole) {
			DCC_HasGuildMemberRole(guildId, author, adminRole, hasRole);
			print("admin");
			if(hasRole) color = "00af33";
		} 
		if(leadAdminRole) {
			DCC_HasGuildMemberRole(guildId, author, leadAdminRole, hasRole);

			if(hasRole) color = "1d7cf2";
		}
		if(devRole) {
			DCC_HasGuildMemberRole(guildId, author, devRole, hasRole);

			if(hasRole) color = "9b59b6";
		}
		if(managementRole) {
			DCC_HasGuildMemberRole(guildId, author, managementRole, hasRole);

			if(hasRole) color = "e7210d";
		}
		foreach(new i: Player)
		{
			if(!Account[i][pLanguage]) SendClientMessage(i, -1, sprintf("~{FF0000} [DISCORD] {%s}%s:{FFFFFF} %s", color, username, content));
		}
	}
	return 1;
}



stock IsUserDiscordAdmin(DCC_User: user)
{
	new DCC_Guild:guildId = DCC_FindGuildById(DISCORD_GUILD),
		DCC_Role:leadAdminRole,
		DCC_Role:adminRole,
		DCC_Role:devRole,
		DCC_Role:managementRole,
		bool: hasRole = false;
	leadAdminRole = DCC_FindRoleByName(guildId, "Lead Admin");
	devRole = DCC_FindRoleByName(guildId, "Server Developer");
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

DCMD:kick(user, channel, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	extract params -> new player:target, string:reason[128]; else return DCC_SendChannelMessage(channel, "**USAGE:** !kick [player name/playerid] [reason]");
	if(!IsPlayerConnected(target)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected.");
	if(Account[target][Admin] >= 1) return DCC_SendChannelMessage(channel, "**ERROR:** You cannot ban other admins.");
	new DCC_Guild:guildId = DCC_FindGuildById(DISCORD_GUILD);
	new admin[33];
	DCC_GetGuildMemberNickname(guildId, user, admin, sizeof admin);
	if(isequal(admin, ""))
	{
		DCC_GetUserName(user, admin, sizeof admin);
	}
	DCC_SendChannelMessage(channel, sprintf("**PUNISHMENT:** %s was kicked from the server, reason: %s", GetName(target), reason));

	SendPunishmentMessage(sprintf("Admin %s has kicked %s. Reason: %s", admin, GetName(target), reason));
	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp) VALUES('%e', '%e', '/kick', '%e', %d)", admin, GetName(target), reason, gettime()));
	Account[target][Kicks]++;
	KickPlayer(target);
	return 1;
}

DCMD:ban(user, channel, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	extract params -> new player:target, string:reason[128]; else return DCC_SendChannelMessage(channel, "**USAGE:** !ban [player name/playerid] [reason]");
	if(!IsPlayerConnected(target)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected.");
	if(Account[target][Admin] >= 1) return DCC_SendChannelMessage(channel, "**ERROR:** You cannot ban other admins.");

	new DCC_Guild:guildId = DCC_FindGuildById(DISCORD_GUILD);
	new admin[33];
	DCC_GetGuildMemberNickname(guildId, user, admin, sizeof admin);
	if(isequal(admin, ""))
	{
		DCC_GetUserName(user, admin, sizeof admin);
	}
	SendPunishmentMessage(sprintf("[DISCORD] Admin %s has banned %s. Reason: %s", admin, GetName(target), reason));
	DCC_SendChannelMessage(channel, sprintf("Admin %s has banned %s. Reason: %s", admin, GetName(target), reason));

	IssueBan(target, admin, reason);
	KickPlayer(target);
	return 1;
}

DCMD:unban(user, channel, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	yield 1;
	await mysql_aquery_s(SQL_CONNECTION, str_format("DELETE FROM `Bans` WHERE PlayerName = '%e'", params));

	if(cache_affected_rows()) //a row was found, player was unbanned
	{
		new DCC_Guild:guildId = DCC_FindGuildById(DISCORD_GUILD);
		new admin[33];
		DCC_GetGuildMemberNickname(guildId, user, admin, sizeof admin);
		if(isequal(admin, ""))
		{
			DCC_GetUserName(user, admin, sizeof admin);
		}
		DCC_SendChannelMessage(channel, sprintf("**PUNISHMENT:** %s was unbanned from the server by %s.", params, admin));
		SendAdminsMessage(1, 0xFF0000FF, sprintf("**PUNISHMENT:** %s was unbanned from the server by %s.", params, admin));
		mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp) VALUES('%e', '%e', '/unban', 'N/A', '%d')", admin, params, gettime()));
	}
	else DCC_SendChannelMessage(channel, sprintf("%s is not currently banned from the server.", params));
	return 1;
}

DCMD:cmds(user, channel, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	DCC_SendChannelMessage(channel, "```cmds, ip, mute, kick, ajail (to-do), offlinejail (to-do), aunjail, ban, remoteban (to-do), unban, asay, freeze, unfreeze, fpscheck, flinchcheck, aimprofile, players, admins, whois (to-do)```");
	return 1;
}

DCMD:players(user, channel, params[])
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

DCMD:admins(user, channel, params[])
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

DCMD:fpscheck(user, channel, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	extract params -> new player:target; else return DCC_SendChannelMessage(channel, "**USAGE:** !fpscheck [player name/playerid]");
	if(!IsPlayerConnected(target)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected!");

	DCC_SendChannelMessage(channel, sprintf("**FPS CHECK:** User **%s** has **%d** FRAMES PER SECOND.", GetName(target), pFPS[target]));
	return 1;
}

DCMD:aimprofile(user, channel, params[])
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
	new msg[1000];
	format(msg, sizeof msg, "Aim Profile of %s (%i) - %s\nBullets Fired: %i\nBullets Hit: %i\nHit Percentage: %.2f%%\nHighest Continuous Shots: %i\nOut of Range Shots: %i\nRandom Aim Warnings: %i\nProaim Teleport Warnings: %i", GetName(target), target, wepname, allshots, hitshots, hitshots*100.0 / allshots, max_cont_shots, out_of_range_warns, random_aim_warns, proaim_tele_warns);
	DCC_SendChannelMessage(channel, msg);
	return true;
}

DCMD:flinchcheck(user, channel, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	extract params -> new player:target; else return DCC_SendChannelMessage(channel, "**USAGE:** !flinchcheck [player name/playerid]");
	if(!IsPlayerConnected(target)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected!");
	if(TimesHit[target] == 0) return DCC_SendChannelMessage(channel, "**ERROR:** This player has not been shot yet.");

	DCC_SendChannelMessage(channel, sprintf("%s (%i) flinch stats - Times Hit: %i Times Flinched: %i (%.2f%%)", GetName(target), target, TimesHit[target], FlinchCount[target], (FlinchCount[target] / TimesHit[target] * 100)));
	return true;
}

DCMD:ajail(user, channel, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	extract params -> new player:target, time, string:reason[64]; else return DCC_SendChannelMessage(channel, "**USAGE:** /ajail [player name/playerid] [minutes] [reason]");
	if(!IsPlayerConnected(target)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected!");

	new DCC_Guild:guildId = DCC_FindGuildById(DISCORD_GUILD);
	new admin[33];
	DCC_GetGuildMemberNickname(guildId, user, admin, sizeof admin);
	if(isequal(admin, ""))
	{
		DCC_GetUserName(user, admin, sizeof admin);
	}

	Account[target][AJailTime] = time;
	if(ActivityState[target] == ACTIVITY_TDM)
	{
		if(GetPlayerTeam(target) < 100)
		{
			RemoveFromTDM(target, ActivityStateID[target]);
		}
		if(GetPlayerTeam(target) > 100 || ActivityState[target] == ACTIVITY_COPCHASE)
		{
			if(Account[target][pCopchase] == 2){
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
	SetPlayerPosEx(target, 2577.2522,2695.4265,22.9507, 0, 0);

	SendPunishmentMessage(sprintf("Admin %s has a-jailed %s for %d minutes! Reason: %s", admin, GetName(target), time, reason));
	DCC_SendChannelMessage(channel, sprintf("**PUNISHMENT:** %s has a-jailed %s for %d minutes! Reason: %s.", admin, GetName(target), time, reason));
	

	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp, ajailtime) VALUES('%e', '%e', '/ajail', '%e', '%d', '%i')", admin, GetName(target), reason, gettime(), time));
	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE Accounts SET ajail_minutes = %i WHERE SQLID = %i", time, Account[target][SQLID]));

	ResetPlayerWeapons(target);
	return 1;
}

DCMD:unjail(user, channel, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	extract params -> new player:target; else return DCC_SendChannelMessage(channel, "**USAGE:** /unjail [player name/playerid]");
	if(!IsPlayerConnected(target)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected!");
	if(!Account[target][AJailTime]) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not in ajail.");

	new DCC_Guild:guildId = DCC_FindGuildById(DISCORD_GUILD);
	new admin[33];
	DCC_GetGuildMemberNickname(guildId, user, admin, sizeof admin);
	if(isequal(admin, ""))
	{
		DCC_GetUserName(user, admin, sizeof admin);
	}

	Account[target][AJailTime] = 0;
	SendPlayerToLobby(target);

	DCC_SendChannelMessage(channel, sprintf("**PUNISHMENT:** %s was unjailed by %s.", GetName(target), admin));
	SendClientMessageToAll(COLOR_LIGHTRED, sprintf("PUNISHMENT: %s was unjailed by %s via Discord.", GetName(target), admin));
	SendClientMessage(target, -1, sprintf("{bf0000}Notice: {FFFFFF}You have been unjailed by %s via Discord.", admin));
	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE Accounts SET ajail_minutes = 0 WHERE SQLID = %i", Account[target][SQLID]));
	return 1;
}

DCMD:mute(user, channel, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	extract params -> new player:target, minutes, string:reason[64]; else return DCC_SendChannelMessage(channel, "**USAGE:** /mute [player name/playerid] [minutes] [reason]");
	if(!IsPlayerConnected(target)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected!");

	new DCC_Guild:guildId = DCC_FindGuildById(DISCORD_GUILD);
	new admin[33];
	DCC_GetGuildMemberNickname(guildId, user, admin, sizeof admin);
	if(isequal(admin, ""))
	{
		DCC_GetUserName(user, admin, sizeof admin);
	}

	Account[target][Muted] = gettime() + minutes*60;
	Account[target][Mutes]++;

	DCC_SendChannelMessage(channel, sprintf("**PUNISHMENT:** %s was muted by %s for %i minutes, reason: %s", GetName(target), admin, minutes, reason));
	SendClientMessageToAll(COLOR_LIGHTRED, sprintf("PUNISHMENT: %s was muted by %s via Discord %i minutes, reason: %s", GetName(target), admin, minutes, reason));
	SendAdminsMessage(1, COLOR_GRAY, sprintf("{bf0000}Admin Notice: {FFFFFF}%s has muted %s via Discord for %i minutes! Reason: %s", admin, GetName(target), minutes, reason));
	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp) VALUES('%e', '%e', '/mute', '%e', '%d')", admin, GetName(target), reason, gettime()));
	return 1;
}

DCMD:unmute(user, channel, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	extract params -> new player:target; else return DCC_SendChannelMessage(channel, "**USAGE:** /unmute [player name/playerid]");
	if(!IsPlayerConnected(target)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected!");

	new DCC_Guild:guildId = DCC_FindGuildById(DISCORD_GUILD);
	new admin[33];
	DCC_GetGuildMemberNickname(guildId, user, admin, sizeof admin);
	if(isequal(admin, ""))
	{
		DCC_GetUserName(user, admin, sizeof admin);
	}

	Account[target][Muted] = 0;

	DCC_SendChannelMessage(channel, sprintf("**PUNISHMENT:** %s was unmuted by %s.", GetName(target), admin));
	SendClientMessageToAll(COLOR_LIGHTRED, sprintf("PUNISHMENT: %s was unmuted by %s via Discord.", GetName(target), admin));
	SendAdminsMessage(1, COLOR_GRAY, sprintf("{bf0000}Admin Notice: {FFFFFF}%s has unmuted %s via Discord.", admin, GetName(target)));
	SendClientMessage(target, COLOR_GRAY, "{bf0000}Notice: {FFFFFF}You have been unmuted by an admin.");
	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp) VALUES('%e', '%e', '/unmute', 'N/A', '%d')", admin, GetName(target), gettime()));
	return 1;
}

DCMD:ip(user, channel, params[])
{
	if(!IsUserDiscordAdmin(user)) return 0;

	extract params -> new player:target; else return DCC_SendChannelMessage(channel, "**USAGE:** /ip [player name/playerid]");
	if(!IsPlayerConnected(target)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected!");

	new countryname[40], countryregion[40], playerisp[40], ipaddress[18];
	GetPlayerIp(target, ipaddress, 18);
	GetPlayerCountry(target, countryname);
	GetPlayerRegion(target, countryregion);
	GetPlayerISP(target, playerisp);

	DCC_SendChannelMessage(channel, sprintf("IP Address: %s, Country: %s, Area: %s\nServer Latency: %ims, ISP: %s", ipaddress, countryname, countryregion, GetPlayerPing(target), playerisp));
	return 1;
}
