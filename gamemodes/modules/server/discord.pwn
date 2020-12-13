#include <a_samp>
#include <discord-connector>
#include <discord-commands>

#define ANTICHEAT "610721144567496704"
#define REPORTS "610780079521529856"


new AdminName[][] =
{
	"None",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6"
};

forward kicktimer(playerid);
public kicktimer(playerid)
{
	Kick(playerid);
	return 1;
}
DQCMD:kick(DCC_Channel:channel, DCC_User:user, params[])
{
    new admin[64], id, reason[128];
	if(sscanf(params, "us[128]", id, reason)) return DCC_SendChannelMessage(channel, "**USAGE:** !kick [player name/playerid] [reason]");
    if(!IsPlayerConnected(id)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected.");
	DCC_GetUserName(user, admin, sizeof(admin));
    DCC_SendChannelMessage(channel, sprintf("**PUNISHMENT:** %s was kicked from the server, reason: %s", GetName(id), reason));
	SendClientMessageToAll(COLOR_LIGHTRED, sprintf("PUNISHMENT: %s was kicked from the server by %s, reason: %s", GetName(id), admin, reason));
    SendAdminsMessage(1, COLOR_GRAY, sprintf("{31AEAA}Admin Notice: {FFFFFF}%s has been kicked via Discord.", GetName(id)));
	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp) VALUES('%e', '%e', '/kick', '%e', %d)", admin, GetName(ID), reason, gettime()));
	Account[id][Kicks]++;
	KickPlayer(id);
	
    return 1;
}
DQCMD:ban(DCC_Channel:channel, DCC_User:user, params[])
{
	new pID, reason[128], admin[64];
	if(sscanf(params, "us[128]", pID, reason)) return DCC_SendChannelMessage(channel, "**USAGE:** !ban [player name/playerid] [reason]");
    if(!IsPlayerConnected(pID)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected.");
	if(Account[pID][Admin] >= 1) return DCC_SendChannelMessage(channel, "**ERROR:** You can't ban an admin.");
	DCC_GetUserName(user, admin, sizeof(admin));
	SendClientMessageToAll(COLOR_LIGHTRED, sprintf("PUNISHMENT: %s was banned from the server by %s via Discord, reason: %s", GetName(pID), admin, reason));
	DCC_SendChannelMessage(channel, sprintf("**PUNISHMENT:** %s was banned from the server by %s, reason: %s", GetName(pID), admin, reason));
	IssueBan(pID, admin, reason);
	KickPlayer(pID);
	return 1;
}
DQCMD:unban(DCC_Channel:channel, DCC_User:user, params[])
{
	new name, admin[64], pID, reason[128];
	if(sscanf(params, "us[128]", pID, reason)) return DCC_SendChannelMessage(channel, "**USAGE:** !unban [name]");
    if(!IsPlayerConnected(pID)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected.");
	if(Account[pID][Admin] >= 1) return DCC_SendChannelMessage(channel, "**ERROR:** You can't ban an admin.");
	DCC_GetUserName(user, admin, sizeof(admin));
	DCC_SendChannelMessage(channel, sprintf("**PUNISHMENT:** %s was unbanned from the server by %s.", name, admin));
	mysql_pquery_s(SQL_CONNECTION, str_format("DELETE FROM `Bans` WHERE PlayerName = '%e'", name));
	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp) VALUES('%e', '%e', '/unban', 'N/A', '%d')", admin, name, gettime()));
	return 1;
}
	
DQCMD:asay(DCC_Channel:channel, DCC_User:user, params[])
{
    new message[512], nick[64];
    if (sscanf(params, "s[512]", message)) return DCC_SendChannelMessage(channel, "```USAGE: !asay [message]```");
	DCC_GetUserName(user, nick, sizeof(nick));
	DCC_SendChannelMessage(channel, sprintf("```[Discord Announcement] %s: %s```", nick, message));
	foreach(new i: Player)
	{
		if(Account[i][LoggedIn] == 1)
		{
			SendClientMessage(i, COLOR_VIOLET, sprintf("[Discord Announcement] %s: %s", nick, params));
		}
	}
    return 1;
}
DQCMD:cmds(DCC_Channel:channel, DCC_User:user, params[])
{
	DCC_SendChannelMessage(channel, "```cmds, ip, mute, kick, ajail (to-do), offlinejail (to-do), aunjail, ban, remoteban (to-do), unban, asay, freeze, unfreeze, fpscheck, flinchcheck, aimprofile, players, admins, whois (to-do)```");
	return 1;
}
DQCMD:freeze(DCC_Channel:channel, DCC_User:user, params[])
{
	new giveplayerid, giveplayer[MAX_PLAYER_NAME], admin[64];
	if (sscanf(params, "u", giveplayerid)) return DCC_SendChannelMessage(channel, "```USAGE: !freeze [player name/playerid]```");
	if (!IsPlayerConnected(giveplayerid)) return DCC_SendChannelMessage(channel, "**ERROR: Inactive player id!**");
	TogglePlayerControllable(giveplayerid, 0);
	DCC_GetUserName(user, admin, sizeof(admin));
	GetPlayerName(giveplayerid, giveplayer, MAX_PLAYER_NAME);
	SendAdminsMessage(1, COLOR_GRAY, sprintf("{31AEAA}Admin Notice: {FFFFFF}%s has been frozen via discord.", giveplayer));
	SendClientMessage(giveplayerid, COLOR_GRAY, sprintf("{31AEAA}Notice: {FFFFFF}You have been frozen by an admin.", giveplayer));
	DCC_SendChannelMessage(channel, sprintf("**PUNISHMENT:** %s was frozen by %s.", giveplayer, admin));
	return 1;
}

DQCMD:unfreeze(DCC_Channel:channel, DCC_User:user, params[])
{
    new giveplayerid, giveplayer[MAX_PLAYER_NAME], admin[64];
	if (sscanf(params, "u", giveplayerid)) return DCC_SendChannelMessage(channel, "USAGE: !unfreeze [player name/playerid]");
	if (!IsPlayerConnected(giveplayerid)) return DCC_SendChannelMessage(channel, "**ERROR:** inactive player id!");
    TogglePlayerControllable(giveplayerid, 1);
	DCC_GetUserName(user, admin, sizeof(admin));
    GetPlayerName(giveplayerid, giveplayer, MAX_PLAYER_NAME);
	SendAdminsMessage(1, COLOR_GRAY, sprintf("{31AEAA}Admin Notice: {FFFFFF}%s has been unfrozen via discord.", giveplayer));
	SendClientMessage(giveplayerid, COLOR_GRAY, sprintf("{31AEAA}Notice: {FFFFFF}You have been unfrozen by an admin.", giveplayer));
	DCC_SendChannelMessage(channel, sprintf("**PUNISHMENT:** %s was unfrozen by %s.", giveplayer, admin));
	return 1;
}
DQCMD:players(DCC_Channel:channel, DCC_User:user, params[])
{
    new count = 0;
	new name[24];
	DCC_SendChannelMessage(channel, "**PLAYERS ONLINE:**");

	for(new i=0; i < MAX_PLAYERS; i++) {
		if(!IsPlayerConnected(i)) continue;

		GetPlayerName(i, name, MAX_PLAYER_NAME);
		{
		DCC_SendChannelMessage(channel, sprintf("%s (%d)", name, i));
		count++; 
		}
	}
	if (count == 0) return DCC_SendChannelMessage(channel, "There are no players online.");
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
        DCC_SendChannelMessage(channel, sprintf("(Level %s Admin) %s (ID %i)", AdminName[admin[1]][0], GetName(admin[0]), admin[0]));
    }
    list_delete(adminlist);
    return true;
}

DQCMD:fpscheck(DCC_Channel:channel, DCC_User:user, params[])
{
    new pID;
	if(sscanf(params, "u", pID)) return DCC_SendChannelMessage(channel, "**USAGE:** !fpscheck [player name/playerid]");
	if(!IsPlayerConnected(pID)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected!");

	DCC_SendChannelMessage(channel, sprintf("**FPS CHECK:** User **%s** has **%d** FRAMES PER SECOND.", GetName(pID), pFPS[pID]));
	return 1;
}

DQCMD:aimprofile(DCC_Channel:channel, DCC_User:user, params[])
{
	new playa = -1, weapon[32];
	if(sscanf(params, "uS()[32]", playa, weapon)) return DCC_SendChannelMessage(channel, "**USAGE:** !aimprofile [playerid or name] [optional: weapon]");
	if(!IsPlayerConnected(playa)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected!");

	new allshots, hitshots, max_cont_shots, out_of_range_warns, random_aim_warns, proaim_tele_warns, wepname[32];
	if(isnull(weapon))
	{
		BustAim::GetPlayerProfile(playa, allshots, hitshots, max_cont_shots, out_of_range_warns, random_aim_warns, proaim_tele_warns);
		wepname = "All Weapons";
	}
	else
	{
		new WeaponID = GetWeaponIDFromName(weapon);
		BustAim::GetPlayerWeaponProfile(playa, WeaponID, allshots, hitshots, max_cont_shots, out_of_range_warns, random_aim_warns, proaim_tele_warns);
		format(wepname, 32, WeaponNameList[WeaponID]);
	}

	DCC_SendChannelMessage(channel, "\n");
	DCC_SendChannelMessage(channel, sprintf("Aim Profile of %s (%i) - %s", GetName(playa), playa, wepname));
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
	new pID;
	if(sscanf(params, "u", pID)) return DCC_SendChannelMessage(channel, "**USAGE:** !flinchcheck [player name/playerid]");
	if(!IsPlayerConnected(pID)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected!");
	if(TimesHit[pID] == 0) return DCC_SendChannelMessage(channel, "**ERROR:** This player has not been shot yet.");

	DCC_SendChannelMessage(channel, sprintf("%s (%i) flinch stats - Times Hit: %i Times Flinched: %i (%.2f%%)", GetName(pID), pID, TimesHit[pID], FlinchCount[pID], (FlinchCount[pID] / TimesHit[pID] * 100)));
	return true;
}
DQCMD:whois(DCC_Channel:channel, DCC_User:user, params[])
{
	new id, ip[16], country[64], isp[256];

	if(sscanf(params, "u", id)) return DCC_SendChannelMessage(channel, "**USAGE:** !whois [player name/playerid]");
	
	if(!IsPlayerConnected(id)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected!");
	
	GetPlayerIp(id, ip, sizeof(ip));
	GetPlayerCountry(id, country, sizeof(country));
	GetPlayerISP(id, isp, sizeof(isp));

	DCC_SendChannelMessage(channel, sprintf("**[WHOIS]** IP Address info for %s (ID %d) (current session):", GetName(id), id));
	DCC_SendChannelMessage(channel, sprintf("**[WHOIS]** IP Address: %s | Location: %s", ip, country));
	DCC_SendChannelMessage(channel, sprintf("**[WHOIS]** ISP: %s", isp));
	if(Account[id][pVPN] == 1)
		DCC_SendChannelMessage(channel, "**[WHOIS]** This player is using a VPN/proxy!");
	return 1;
}
DQCMD:ajail(DCC_Channel:channel, DCC_User:user, params[])
{
	new target, time, reason[64], admin[64];
	if(sscanf(params, "uis[64]", target, time, reason)) return DCC_SendChannelMessage(channel, "**USAGE:** /ajail [player name/playerid] [minutes] [reason]");
	if(!IsPlayerConnected(target)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected!");
	DCC_GetUserName(user, admin, sizeof(admin));
	cmd_ajail(9999, -1, params);
	return 1;
}
DQCMD:aunjail(DCC_Channel:channel, DCC_User:user, params[])
{
	new pID, admin[64], target;
	if(sscanf(params, "u", target)) return DCC_SendChannelMessage(channel, "**USAGE:** /unjail [player name/playerid]");
	if(!IsPlayerConnected(target)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected!");
	if(!Account[pID][AJailTime]) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not in ajail.");
	DCC_GetUserName(user, admin, sizeof(admin));
	DCC_SendChannelMessage(channel, sprintf("**PUNISHMENT:** %s was unjailed by %s.", GetName(pID), admin));
	SendClientMessageToAll(COLOR_LIGHTRED, sprintf("PUNISHMENT: %s was unjailed by %s via Discord.", GetName(pID), admin));
	SendClientMessage(pID, -1, sprintf("{31AEAA}Notice: {FFFFFF}You have been unjailed by %s via Discord.", admin));
	Account[pID][AJailTime] = 0;
	SendPlayerToLobby(pID);

	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE Accounts SET ajail_minutes = 0 WHERE SQLID = %i", Account[pID][SQLID]));
	return 1;
}

DQCMD:mute(DCC_Channel:channel, DCC_User:user, params[])
{
	new pID, reason[64], time, admin[64];
	if(sscanf(params, "uis[64]", pID, time, reason)) return DCC_SendChannelMessage(channel, "**USAGE:** /mute [player name/playerid] [minutes] [reason]");
	if(!IsPlayerConnected(pID)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected!");
	DCC_GetUserName(user, admin, sizeof(admin));
	Account[pID][Muted] = time;
	Account[pID][Mutes]++;

	DCC_SendChannelMessage(channel, sprintf("**PUNISHMENT:** %s was muted by %s, reason: %s", GetName(pID), admin, reason));
	SendClientMessageToAll(COLOR_LIGHTRED, sprintf("PUNISHMENT: %s was muted by %s via Discord, reason: %s", GetName(pID), admin, reason));
	SendAdminsMessage(1, COLOR_GRAY, sprintf("{31AEAA}Admin Notice: {FFFFFF}%s has muted %s via Discord for %i minutes! Reason: %s", admin, GetName(pID), time, reason));
	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp) VALUES('%e', '%e', '/mute', '%e', '%d')", admin, GetName(pID), reason, gettime()));
	return 1;
}
DQCMD:unmute(DCC_Channel:channel, DCC_User:user, params[])
{
	new pID, admin[64];
	if(sscanf(params, "u", pID)) return DCC_SendChannelMessage(channel, "**USAGE:** /unmute [player name/playerid]");
	if(!IsPlayerConnected(pID)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected!");
	DCC_GetUserName(user, admin, sizeof(admin));
	Account[pID][Muted] = 0;

	DCC_SendChannelMessage(channel, sprintf("**PUNISHMENT:** %s was unmuted by %s.", GetName(pID), admin));
	SendClientMessageToAll(COLOR_LIGHTRED, sprintf("PUNISHMENT: %s was unmuted by %s via Discord.", GetName(pID), admin));
	SendAdminsMessage(1, COLOR_GRAY, sprintf("{31AEAA}Admin Notice: {FFFFFF}%s has unmuted %s via Discord.", admin, GetName(pID)));
	SendClientMessage(pID, COLOR_GRAY, "{31AEAA}Notice: {FFFFFF}You have been unmuted by an admin.");
	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp) VALUES('%e', '%e', '/unmute', 'N/A', '%d')", admin, GetName(pID), gettime()));
	return 1;
}
DQCMD:ip(DCC_Channel:channel, DCC_User:user, params[])
{
	new pID;
	if(sscanf(params, "u", pID)) return DCC_SendChannelMessage(channel, "**USAGE:** /ip [player name/playerid]");
	if(!IsPlayerConnected(pID)) return DCC_SendChannelMessage(channel, "**ERROR:** This player is not connected!");

	new countryname[40], countryregion[40], playerisp[40], ipaddress[18];
	GetPlayerIp(pID, ipaddress, 18);
	GetPlayerCountry(pID, countryname);
	GetPlayerRegion(pID, countryregion);
	GetPlayerISP(pID, playerisp);
	DCC_SendChannelMessage(channel, sprintf("IP Address: %s, Country: %s, Area: %s", ipaddress, countryname, countryregion));
	DCC_SendChannelMessage(channel, sprintf("Server Latency: %ims, ISP: %s", GetPlayerPing(pID), playerisp));
	return 1;
}
