IssueBan(playerid, const adminname[], const reason[])
{
	new ip[18];
	GetPlayerIp(playerid, ip, 18);
	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO Bans (PlayerName, IP, C_ID, A_ID, Timestamp, BannedBy, Reason) VALUES('%e', '%e', %d, %d, %d, '%e', '%e')",
		GetName(playerid), ip, Account[playerid][SQLID], Account[playerid][SQLID], gettime(), adminname, reason));
	return 1;
}
Dialog:UNBAN(playerid, response, listitem, inputtext[])
{
	if(!response) return true;

	SendAdminsMessage(1, COLOR_LIGHTRED, sprintf("%s has unbanned user %s.", GetName(playerid), inputtext));
	mysql_pquery_s(SQL_CONNECTION, str_format("DELETE FROM `Bans` WHERE PlayerName = '%e'", inputtext));
	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp) VALUES('%e', '%e', '/unban', 'N/A', '%d')", GetName(playerid), inputtext, gettime()));
	return 1;
}
forward LocalCountDown(playerid);
public LocalCountDown(playerid)
{
	if(countdowntime[playerid] <= 0)
	{
		GameTextForPlayer(playerid, "~r~~h~UNFROZEN", 4000, 3);
		PlayerPlaySound(playerid, 3200, 0, 0, 0);
		TogglePlayerControllable(playerid, true);
		KillTimer(countdowntimer[playerid]);
	}
	else
	{
		GameTextForPlayer(playerid, sprintf("~r~~h~%d", countdowntime[playerid]), 1000, 3);
		PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
	}
	countdowntime[playerid]--;
	return 1;
}

AdminJailCheck(playerid)
{
	new ip[18];
	GetPlayerIp(playerid, ip, sizeof(ip));

	mysql_pquery_s(SQL_CONNECTION, str_format("SELECT * FROM Accounts WHERE LatestIP = '%e' AND Username != '%e'", ip, GetName(playerid)), "CheckJailsUnderIP", "is", playerid, ip);	

	if(Account[playerid][AJailTime] > 0)
	{
		SetPlayerSkin(playerid, 20051);
		SendClientMessage(playerid, -1, sprintf("{31AEAA}A-Jail: {FFFFFF}You still have {31AEAA}%d {FFFFFF}minute(s) left in admin-jail. You will now serve it.", Account[playerid][AJailTime]));
		ResetPlayerWeapons(playerid);
		SetTimerEx("SendToAJail", 5000, false, "d", playerid);
	}
	return 1;
}

forward CheckJailsUnderIP(playerid, const ip[]);
public CheckJailsUnderIP(playerid, const ip[])
{
	new jail, username[32], str[128], str1[128];
	for(new i = 0, r = cache_num_rows(); i < r; i++)
	{
		cache_get_value_name_int(i, "ajail_minutes", jail);
		cache_get_value_name(i, "Username", username);

		if(jail > 0)
		{
			format(str, sizeof(str), "%s has been caught a-jail evading under the alias %s which was jailed for %i minutes previously! The player was kicked and warned to serve the time.", GetName(playerid), username, jail);
			SendAdminsMessage(1, COLOR_LIGHTRED, str);

			format(str1, sizeof(str1), "%s has been caught a-jail evading! The player has been automatically kicked!", GetName(playerid));
			SendPunishmentMessage(str1);

			SendClientMessage(playerid, COLOR_LIGHTRED, sprintf("Notice: {FFFFFF}You must serve your %i admin jail minutes on your %s account before playing on this account!", jail, username));
			SendClientMessage(playerid, COLOR_LIGHTRED, sprintf("Notice: {FFFFFF}You must serve your %i admin jail minutes on your %s account before playing on this account!", jail, username));
			
			SetTimerEx("FixKick", 8000, false, "i", playerid);
			return 1;
		}
		else ShowHelpMessage(playerid);
	}
	return true;
}

MuteCheck(playerid)
{
	if(Account[playerid][Muted] > 0)
	{
		SendClientMessage(playerid, -1, sprintf("{31AEAA}Mute: {FFFFFF}You still have {31AEAA}%d {FFFFFF}minute(s) of a mute left. You will continue to serve it.", Account[playerid][Muted]));
	}
	return 1;
}

forward SendToAJail(playerid);
public SendToAJail(playerid)
{
	CreateLobby(playerid);
	SetPlayerPosEx(playerid, 2518.7590, 602.5683, 45.2066, 0, 0);
	SetPlayerSkin(playerid, 20051);
	return 1;
}

GetUserName(playerid) {
	new name[24];
	GetPlayerName(playerid, name, 24);
	return name;
}

SendAdminPM(from, to, msg[]) {
	new string[256];
	foreach (new i : Player) {
		if(AdminPMRead[i] == true && GetPlayerAdminLevel(i) > 1) {
			format(string, 256, "PM (%s->%s): %s", GetUserName(from), GetUserName(to), msg);
		}
	}
	return 1;
}