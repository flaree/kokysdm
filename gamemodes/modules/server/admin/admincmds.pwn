CMD<AD6>:tickrate(cmdid, playerid, params[])
{
	SendClientMessage(playerid, -1, sprintf("Server Tickrate: %i", GetServerTickRate()));
	return true;
}
CMD<AD4>:gotopos(cmdid, playerid,params[])
{
	new Float:pos[3], int;
	if(sscanf(params, "fffi", pos[0], pos[1], pos[2], int)) return SendClientMessage(playerid, COLOR_GRAY, "/gotopos [x] [y] [z] [int]");
	{
		SetPlayerPosEx(playerid, pos[0], pos[1], pos[2], int, 0);
		SetPlayerInterior(playerid, int);
	}
	return 1;
}
CMD<AD1>:unfreeze(cmdid, playerid, params[])
{
	new pID;
	if(sscanf(params, "u", pID)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /unfreeze [id]");

	TogglePlayerControllable(pID, 1);
	SendAdminsMessage(1, COLOR_GRAY, sprintf("Admin %s has unfrozen %s.", GetName(playerid), GetName(pID)));
	SendClientMessage(pID, COLOR_GRAY, "{bf0000}NOTICE: {FFFFFF}You have been unfrozen by an admin.");
	return 1;
}
CMD<AD1>:setvw(cmdid, playerid, params[])
{
	new pID, vw;
	if(sscanf(params, "ui", pID, vw)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /setvw [playerid] [virtualworld]");

	SendAdminsMessage(1, COLOR_GRAY, sprintf("Admin %s has set %s's virtual world to %i.", GetName(playerid), GetName(pID), vw));
	SendClientMessage(pID, -1, sprintf("{bf0000}NOTICE: {FFFFFF}Your virtual world has been set to %i by Administrator %s.", vw, GetName(playerid)));
	SetPlayerVirtualWorld(pID, vw);
	return 1;
}
CMD<AD1>:wallhack(playerid, params[]) {
	if(SpectatingPlayer[playerid] == -1) SendErrorMessage(playerid, "You must be spectating to use this command");
	WallHack{playerid} = !WallHack{playerid};
	sendFormatMessage(playerid, 0xFFFF0000, "* You have %s wall hacks!", WallHack{playerid}?("enabled"):("disabled"));
	new szString[256];
	format(szString, 256, "%s is %s using /wallhack.", GetName(playerid), WallHack{playerid}?("now"):("no longer"));
	SendAdminsMessage(1, COLOR_YELLOW, szString);
	return 1;
	#pragma unused params
}
CMD<AD6>:givetokens(cmdid, playerid, params[])
{
	new pID, tokenamount;
	if(sscanf(params, "ui", pID, tokenamount)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /givetoken [id] [amount]");

	Account[pID][Tokens] += tokenamount;
	SendClientMessage(pID, COLOR_LIGHTRED, sprintf("NOTICE: You were given %i tokens by %s.", tokenamount, GetName(playerid)));
	SendClientMessage(playerid, -1, "You gave the player KDM Tokens.");
	return true;
}
CMD<AD1>:sv(cmdid, playerid, params[])
{
	new id = GetPlayerVehicleID(playerid);
	if(id != INVALID_VEHICLE_ID) {
		SetVehicleToRespawn(id);
	} else {
		if(sscanf(params, "i", id)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /sv [vehicle id]");
	}
    SetVehicleToRespawn(id);
	SendClientMessage(playerid, COLOR_RED, "[AdmCmd]: Vehicle respawned.");
	return 1;
}
CMD<AD6>:resetmonthdmer(cmid, playerid, params[])
{
	CheckDateForNPC();
	return 1;
}
CMD<AD1>:freezelocal(cmdid, playerid, params[])
{
	new range;
	if(sscanf(params, "d", range)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /freezelocal [meters]");

	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);

	foreach(new i: Player)
	{
		if(IsPlayerInRangeOfPoint(i, range, x, y, z))
		{
			TogglePlayerControllable(i, false);
			SendClientMessage(i, COLOR_LIGHTRED, sprintf("Local Freeze: Admin %s has frozen all local players within %i meters of their position.", GetName(playerid), range));
		}
	}
	return true;
}
CMD<AD1>:forcelanguage(cmdid, playerid, params[])
{
	new pid;
 	if(sscanf(params, "u", pid)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /forcelanguage [playerid/playername]");

 	SendClientMessage(playerid, -1, sprintf("{bf0000}NOTICE: {FFFFFF}You have forced the language dialog upon %s.", GetName(pid)));
 	SendClientMessage(pid, -1, sprintf("{bf0000}NOTICE: {FFFFFF}You have been forced to select a language by %s.", GetName(playerid)));

 	Dialog_Show(pid, SELECTLANGUAGE, DIALOG_STYLE_LIST, "Language Selection", "English\nTurkish\nFrench\nPortuguese\nEspanol\nOther", "Select", "Cancel");

 	if (GetPlayerAdminHidden(playerid))
 		SendPunishmentMessage(sprintf("An admin has forced language selection upon %s. Reason: English only in main chat!", GetName(pid)));
 	else
 		SendPunishmentMessage(sprintf("Admin %s has forced language selection upon %s. Reason: English only in main chat!", GetName(playerid), GetName(pid)));
 	return true;
}
ALT:fl = CMD:forcelanguage;

CMD<AD1>:unfreezelocal(cmdid, playerid, params[])
{
	new range, time;
	if(sscanf(params, "di", range, time)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /unfreezelocal [meters] [countdown in seconds]");

	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);

	foreach(new i: Player)
	{
		if(IsPlayerInRangeOfPoint(i, range, x, y, z))
		{
			countdowntime[i] = time;
			SetTimerEx("UnfreezePlayer", time * 1000 , false, "i", i);
			countdowntimer[i] = SetTimerEx("LocalCountDown", 1000, true, "i", i);
			SendClientMessage(i, COLOR_LIGHTRED, sprintf("Local Freeze: Admin %s has unfrozen all local players within %i meters of their position.", GetName(playerid), range));
		}
	}
	return true;
}
CMD<AD1>:sendlocalmessage(cmdid, playerid, params[])
{
	new range, message[64];
	if(sscanf(params, "ds[64]", range, message)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /sendlocalmessage [meters] [message]");

	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);

	new string[128];
	format(string, sizeof(string), "[LOCAL ADMIN NOTICE(%s)]: %s", GetName(playerid), message);
	foreach(new i: Player)
	{
		if(IsPlayerInRangeOfPoint(i, range, x, y, z))
		{
			SendClientMessage(i, COLOR_LIGHTRED, string);
		}
	}
	return true;
}
CMD<AD1>:localcount(cmdid, playerid, params[])
{
	new range;
	if(sscanf(params, "d", range)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /localcount [meters]");

	new Float:x, Float:y, Float:z, count;
	GetPlayerPos(playerid, x, y, z);

	foreach(new i: Player)
	{
		if(IsPlayerInRangeOfPoint(i, range, x, y, z))
		{
			count++;
		}
	}

	SendClientMessage(playerid, COLOR_LIGHTRED, sprintf("[LOCAL COUNT]: {FFFFFF}There is a local count of {31AEAA}%i {FFFFFF}players including you.", count));
	return true;
}
CMD<AD4>:setskin(cmdid, playerid, params[])
{
	new player, skinSel;
	if(sscanf(params, "ud", player, skinSel)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /setskin [player] [skin]");
	if(!IsPlayerConnected(player)) return SendErrorMessage(playerid, ERROR_OPTION);
	if(Restricted_Skins(skinSel)) return SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Skin Change: {FFFFFF}This skin is restricted and cannot be used!");

	SetPlayerSkinEx(player, skinSel);
	return 1;
}
CMD<AD1>:adminskin(cmdid, playerid, params[])
{
    if(!IsPlayerConnected(playerid)) return SendErrorMessage(playerid, ERROR_OPTION);
    SetPlayerSkinEx(playerid, 20067);
    return 1;
}

CMD<AD1>:whois(cmdid, playerid, params[])
{
	new id, ip[16], country[64], isp[256], url[128];


	if(sscanf(params, "u", id))
		return SendUsageMessage(playerid, "/whois [ID/name]");

	if(!IsPlayerConnected(id))
		return SendErrorMessage(playerid, "Invalid player specified.");

	if(Account[id][Admin] > 0 && Account[playerid][Admin] < 6)
		return SendErrorMessage(playerid, "You cannot check that player's whois info.");



	GetPlayerIp(id, ip, sizeof(ip));
	GetPlayerCountry(id, country, sizeof(country));
	GetPlayerISP(id, isp, sizeof(isp));

	format(url, sizeof(url), "check.getipintel.net/check.php?ip=%s&contact=cataplasia@protonmail.ch", ip);

	HTTP(id, HTTP_GET, url, "", "HttpResponse");

	SendClientMessage(playerid, COLOR_GREY, sprintf("[WHOIS] IP Address info for %s (ID %d) (current session)", GetName(id), id));
	SendClientMessage(playerid, COLOR_GREY, sprintf("[WHOIS] IP Address: {FFFFFF}%s {D3D3D3}| Location: {FFFFFF}%s", ip, country));
	SendClientMessage(playerid, COLOR_GREY, sprintf("[WHOIS] ISP: {FFFFFF}%s", isp));
	if(Account[id][pVPN] == 1)
	SendClientMessage(playerid, COLOR_LIGHTRED, "[WHOIS] This player is using a VPN/proxy!");
	if(Account[id][pVPN] != 1)
	SendClientMessage(playerid, COLOR_GREY, sprintf("[WHOIS] This player has a %d%s chance of using a VPN/proxy.", Account[id][pVPN]*100, "%%"));
	return 1;
}
CMD<AD1>:ipcheck(cmdid, playerid, params[])
{
	if(isnull(params)) return SendClientMessage(playerid, COLOR_GREY, "Usage: /ipcheck [IP Address] * Wildcards (*) supported *");

	new formatip[18];
	format(formatip, 18, params);
	strreplace(formatip, "*", "%%");

	yield 1;
	await mysql_aquery_s(SQL_CONNECTION, str_format("SELECT Username, Bans.ID AS Banned FROM Accounts LEFT JOIN Bans ON Accounts.SQLID = Bans.C_ID WHERE RegisterIP LIKE '%e' OR LatestIP LIKE '%e'", formatip, formatip));
	if(!cache_num_rows()) return SendErrorMessage(playerid, sprintf("No results found for '%s'.", params));

	new accountname[25], bool:banned;
	SendClientMessage(playerid, COLOR_GREY, sprintf("Accounts under the IP %s", params));
	for(new i = 0, r = cache_num_rows(); i < r; i++)
	{
		cache_get_value_name(i, "Username", accountname);
		cache_get_value_name_bool(i, "Banned", banned);

		SendClientMessage(playerid, COLOR_GREY, sprintf("%s (Banned: %s)", accountname, (banned ? "Yes" : "No")));
	}
	return true;
}

CMD<AD5>:setcustomskin(cmdid, playerid, params[])
{
	new pID, skinID;
	if(sscanf(params, "ud", pID, skinID)) return SendClientMessage(playerid, COLOR_GREY, "USAGE: /setcustomskin [id] [customskinid]");
	if(!IsPlayerConnected(pID)) return SendErrorMessage(playerid, ERROR_OPTION);

	Account[pID][CustomSkin] = skinID;
	SendClientMessage(playerid, -1, sprintf("{bf0000}NOTICE: {FFFFFF}You have set %s's custom skin ID to %d.", GetName(pID), skinID));
	SendClientMessage(pID, -1, sprintf("{bf0000}NOTICE: {FFFFFF}Admin %s has set your personal custom skin! You may now use /myskin.", GetName(playerid)));
	return 1;
}
CMD<AD4>:alockchat(cmdid, playerid, params[])
{
	ChatLocked = !ChatLocked;
	SendClientMessageToAll(COLOR_GRAY, sprintf("{bf0000}NOTICE: {FFFFFF}Admin %s has %s the chat.", GetName(playerid), ChatLocked == true ? "locked" : "unlocked"));
	return 1;
}
CMD<AD2>:aclearchat(cmdid, playerid, params[])
{
	for (new i=0; i<250; i++)
	{
		SendClientMessageToAll(0xFFFFFFFF, " ");
	}
	SendClientMessageToAll(COLOR_GRAY, sprintf("{bf0000}NOTICE: {FFFFFF}Admin %s has cleared the chat.", GetName(playerid)));
	return 1;
}

CMD<AD5>:achangepassword(cmdid, playerid, params[])
{
	new name[32], password[64];
	if(sscanf(params, "s[32]s[32]", name, password)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /achangeapassword [Account Name] [New Password]");
	if(strlen(password) < 5) return SendClientMessage(playerid, COLOR_GRAY, "{bf0000}NOTICE: {FFFFFF}Your password must have more than 5 characters.");

	bcrypt_hash(password, BCRYPT_COST, "OnOfflineAccountHashed", "s", name);
	SendClientMessage(playerid, COLOR_LGREEN, "{bf0000}NOTICE: {FFFFFF}You have successfully changed the accounts password, keep it safe.");
	Account[playerid][AdminActions]++;
	return 1;
}
CMD<AD2>:giveweapon(cmdid, playerid, params[])
{
	new WeaponName[50], gWeaponAmmo, Player;
	if(sscanf(params, "us[50]d", Player, WeaponName, gWeaponAmmo)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /giveweapon [playerid] [Name] [Ammo]");

	new WeaponID = GetWeaponIDFromName(WeaponName);
	if(Account[playerid][Admin] != 6 && !Restricted_Weapon(WeaponID)) return SendErrorMessage(playerid, ERROR_OPTION);
	if(gWeaponAmmo > 1000) return SendErrorMessage(playerid, ERROR_VALUE);

	GivePlayerWeapon(Player, WeaponID, gWeaponAmmo);
	SendAdminsMessage(1, COLOR_GRAY, sprintf("{bf0000}Admin Notice: {FFFFFF}Admin %s has given %s weapon: %s (Ammo:%d)", GetName(playerid), GetName(Player), WeaponNameList[WeaponID], gWeaponAmmo));
	SendClientMessage(Player, COLOR_GRAY, sprintf("{bf0000}NOTICE: {FFFFFF}Admin %s has given %s weapon: %s (Ammo:%d)", GetName(playerid), GetName(Player), WeaponNameList[WeaponID], gWeaponAmmo));
	return 1;
}
CMD<AD1>:ah(cmdid, playerid, params[])
{
	StatsLine(playerid);
	if(Account[playerid][Admin] >= 1)
	{
		SendClientMessage(playerid, COLOR_GRAY, "{bf0000}Level 1 admin commands");
		if(Account[playerid][Admin] >= 1) SendCommandList(playerid, COLOR_GRAY, AD1);
	}
	if(Account[playerid][Admin] >= 2)
	{
		SendClientMessage(playerid, COLOR_GRAY, "{bf0000}Level 2 admin commands");
		if(Account[playerid][Admin] >= 2) SendCommandList(playerid, COLOR_GRAY, AD2);
	}
	if(Account[playerid][Admin] >= 3)
	{
		SendClientMessage(playerid, COLOR_GRAY, "{bf0000}Level 3 admin commands");
		if(Account[playerid][Admin] >= 3) SendCommandList(playerid, COLOR_GRAY, AD3);
	}
	if(Account[playerid][Admin] >= 4)
	{
		SendClientMessage(playerid, COLOR_GRAY, "{5f0000}Level 4 admin commands");
		if(Account[playerid][Admin] >= 4) SendCommandList(playerid, COLOR_GRAY, AD4);
	}
	if(Account[playerid][Admin] >= 5)
	{
		SendClientMessage(playerid, COLOR_GRAY, "{5f0000}Level 5 admin commands");
		if(Account[playerid][Admin] >= 5) SendCommandList(playerid, COLOR_GRAY, AD5);
	}
	if(Account[playerid][Admin] >= 6)
	{
		SendClientMessage(playerid, COLOR_GRAY, "{5f0000}Level 6 admin commands");
		if(Account[playerid][Admin] >= 6) SendCommandList(playerid, COLOR_GRAY, AD6);
	}
	StatsLine(playerid);
	return 1;
}
CMD<AD1>:a(cmdid, playerid, params[])
{
	if(isnull(params)) return SendUsageMessage(playerid, "/a [text]");

	SendAdminsMessage(1, COLOR_TURQUOISE, sprintf("{FFFF80}%s: %s", GetName(playerid), params));
	return true;
}
CMD<AD3>:staffreward(cmdid, playerid, params[])
{
	if(Account[playerid][Donator] != 4)
	{
		SendAdminsMessage(1, COLOR_LIGHTRED, sprintf("%s has activated their staff reward!", GetName(playerid)));
		ActivateUpgrades(playerid, 3);
	}
	else SendClientMessage(playerid, COLOR_LIGHTRED, "You already have Diamond V.I.P active!");
	return true;
}
CMD<AD1>:fpscheck(cmdid, playerid, params[])
{
	new pID;
	if(sscanf(params, "u", pID)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /fpscheck [player name/playerid]");
	if(!IsPlayerConnected(pID)) return SendClientMessage(playerid, COLOR_GRAY, "{bf0000}NOTICE: {FFFFFF}This player is not connected!");

	SendClientMessage(playerid, -1, sprintf("{bf0000}FPS CHECK: {FFFFFF}User {%06x}%s {FFFFFF}has {990a1e}%d {FFFFFF}FRAMES PER SECOND.", GetPlayerColor(pID) >>> 8, GetName(pID), pFPS[pID]));
	return 1;
}
CMD<AD1>:forcerules(cmdid, playerid, params[])
{
	new pID, reason[64];
	if(sscanf(params, "us", pID, reason)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /forcerules [ID] [Reason]");
	if(!IsPlayerConnected(pID)) return SendErrorMessage(playerid, ERROR_OPTION);

	Dialog_Show(pID, RULES, DIALOG_STYLE_MSGBOX, "Forced Rules", "{1E90FF}1. {FFFFFF}No third party modifications\n{1E90FF}2. {FFFFFF}No bug abuse(c-roll, c-bug, c-shoot-c)\n{1E90FF}3. {FFFFFF}No racism\n{1E90FF}4. {FFFFFF}English only\n{1E90FF}5. {FFFFFF}Abuse of commands (/lobby to avoid death)", "Okay", "Close");
	Account[pID][ForcedRules1] = 1;
	Account[pID][ForcedRules]++;
	if (GetPlayerAdminHidden(playerid))
		SendPunishmentMessage(sprintf("An admin has forced rules upon %s! Reason: %s", GetName(pID), reason));
	else
		SendPunishmentMessage(sprintf("Admin %s has forced rules upon %s! Reason: %s", GetName(playerid), GetName(pID), reason));
	SetTimerEx("ReadRules", 5000, false, "d", pID);

	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp) VALUES('%e', '%e', '/forcerules', '%e', %d)", GetName(playerid), GetName(pID), reason, gettime()));
	Account[playerid][AdminActions]++;
	return 1;
}
ALT:fr = CMD:forcerules;

CMD<AD3>:announcement(cmdid, playerid, params[])
{
	if(isnull(params)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /announcement [message]");

	foreach(new i: Player)
	{
		if(Account[i][LoggedIn] == 1)
		{
			SendClientMessage(i, COLOR_VIOLET, sprintf("[Announcement] %s: %s", GetName(playerid), params));
		}
	}
	return 1;
}
ALT:ann = CMD:announcement;
ALT:announ = CMD:announcement;

CMD<AD1>:kick(cmdid, playerid, params[])
{
	new pID, reason[128];
	if(sscanf(params, "uS(Not specified)[128]", pID, reason)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /kick [ID/Name] [reason]");
	if(!IsPlayerConnected(pID)) return SendErrorMessage(playerid, ERROR_OPTION);
	if(Account[pID][Admin] >= 1 && Account[playerid][Admin] < 6) return SendErrorMessage(playerid, "You can't kick admins.");

	if (GetPlayerAdminHidden(playerid))
		SendPunishmentMessage(sprintf("An admin has kicked %s. Reason: %s", GetName(pID), reason));
	else
		SendPunishmentMessage(sprintf("Admin %s has kicked %s. Reason: %s", GetName(playerid), GetName(pID), reason));
	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp) VALUES('%e', '%e', '/kick', '%e', %d)", GetName(playerid), GetName(pID), reason, gettime()));
	Account[pID][Kicks]++;
	KickPlayer(pID);
	Account[playerid][AdminActions]++;
	return 1;
}
CMD<AD1>:mute(cmdid, playerid, params[])
{
	new pID, reason[64], time;
	if(sscanf(params, "uis[64]", pID, time, reason)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /mute [id] [minutes] [reason]");
	if(!IsPlayerConnected(pID)) return SendErrorMessage(playerid, ERROR_OPTION);

	Account[pID][Muted] = gettime() + time*60;
	Account[pID][Mutes]++;

	if (GetPlayerAdminHidden(playerid)) {
		SendPunishmentMessage(sprintf("An admin has muted %s for %i minutes. Reason: %s", GetName(pID), time, reason));
	}
	else {
		SendPunishmentMessage(sprintf("Admin %s has muted %s for %i minutes. Reason: %s", GetName(playerid), GetName(pID), time, reason));
	}
	SendAdminsMessage(1, COLOR_GRAY, sprintf("{bf0000}Admin Notice: {C0C0C0}%s has muted %s for %i minutes! Reason: %s", GetName(playerid), GetName(pID), time, reason));
	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp) VALUES('%e', '%e', '/mute', '%e', '%d')", GetName(playerid), GetName(pID), reason, gettime()));
	Account[playerid][AdminActions]++;
	return 1;
}
CMD<AD1>:ajail(cmdid, playerid, params[])
{
	new target, time, reason[64];
	if(sscanf(params, "uis[64]", target, time, reason)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /ajail [id] [minutes] [reason]");
	if(!IsPlayerConnected(target)) return SendErrorMessage(playerid, ERROR_OPTION);

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

	SendPunishmentMessage(sprintf("Admin %s has a-jailed %s for %d minutes! Reason: %s", GetName(playerid), GetName(target), time, reason));
	SendAdminsMessage(1, COLOR_GRAY, sprintf("{bf0000}Admin Notice: {FFFFFF}%s a-jailed %s! Reason: %s", GetName(playerid), GetName(target), reason));

	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp, ajailtime) VALUES('%e', '%e', '/ajail', '%e', '%d', '%i')", GetName(playerid), GetName(target), reason, gettime(), time));
	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE Accounts SET ajail_minutes = %i WHERE SQLID = %i", time, Account[target][SQLID]));

	Account[playerid][AdminActions]++;

	ResetPlayerWeapons(target);
	return 1;
}
CMD<AD1>:aunjail(cmdid, playerid, params[])
{
	new pID;
	if(sscanf(params, "u", pID)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /aunjail [id]");
	if(!IsPlayerConnected(pID)) return SendErrorMessage(playerid, ERROR_OPTION);
	if(!Account[pID][AJailTime]) return SendErrorMessage(playerid, "This player is not in ajail.");

	SendClientMessage(pID, -1, sprintf("{bf0000}NOTICE: {FFFFFF}You have been unjailed by %s.", GetName(playerid)));
	SendAdminsMessage(1, COLOR_GRAY, sprintf("{bf0000}Admin Notice: {FFFFFF}%s has unjailed %s!", GetName(playerid), GetName(pID)));
	Account[pID][AJailTime] = 0;
	SendPlayerToLobby(pID);

	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE Accounts SET ajail_minutes = 0 WHERE SQLID = %i", Account[pID][SQLID]));
	return 1;
}
CMD<AD1>:unmute(cmdid, playerid, params[])
{
	new pID;
	if(sscanf(params, "u", pID)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /unmute [id]");
	if(!IsPlayerConnected(pID)) return SendErrorMessage(playerid, ERROR_OPTION);

	Account[pID][Muted] = 0;

	SendAdminsMessage(1, COLOR_LIGHTRED, sprintf("PUNISHMENT: %s has unmuted %s!", GetName(playerid), GetName(pID)));
	SendClientMessage(pID, COLOR_GRAY, sprintf("{bf0000}NOTICE: {FFFFFF}Admin %s has unmuted you.", GetName(playerid)));
	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp) VALUES('%e', '%e', '/unmute', 'N/A', '%d')", GetName(playerid), GetName(pID), gettime()));
	return 1;
}
CMD<AD2>:freeze(cmdid, playerid, params[])
{
	new pID;
	if(sscanf(params, "u", pID)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /freeze [id]");
	if(!IsPlayerConnected(pID)) return SendErrorMessage(playerid, ERROR_OPTION);

	TogglePlayerControllable(pID, 0);
	SendAdminsMessage(1, COLOR_GRAY, sprintf("{bf0000}Admin Notice: {FFFFFF}Admin %s has frozen %s.", GetName(playerid), GetName(pID)));
	SendClientMessage(pID, COLOR_GRAY, "{bf0000}NOTICE: {FFFFFF}You have been frozen by an admin.");
	Account[playerid][AdminActions]++;
	return 1;
}
CMD<AD1>:slap(cmdid, playerid, params[])
{
	new pID;
	if(sscanf(params, "u", pID)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /slap [id]");
	PlayerPlaySound(playerid, 1190, 0.0, 0.0, 0.0);

	new Float:px, Float:py, Float:pz;
	if(!IsPlayerInAnyVehicle(pID))
	{
		GetPlayerPos(pID, px, py, pz);
		SetPlayerPos(pID, px, py, pz+4);
		PlayerPlaySound(pID, 1190, 0.0, 0.0, 0.0);
		if (GetPlayerAdminHidden(playerid))
			SendClientMessage(pID, COLOR_LIGHTRED, "PUNISHMENT: An admin has slapped you.");
		else
			SendClientMessage(pID, COLOR_LIGHTRED, sprintf("PUNISHMENT: Admin %s has slapped you.", GetName(playerid)));
	}
	return 1;
}
CMD<AD1>:downslap(cmdid, playerid, params[])
{
	new pID;
	if(sscanf(params, "u", pID)) return SendUsageMessage(playerid, "/downslap [id]");
	PlayerPlaySound(playerid, 1190, 0.0, 0.0, 0.0);

	new Float:px, Float:py, Float:pz;
	if(!IsPlayerInAnyVehicle(pID))
	{
		GetPlayerPos(pID, px, py, pz);
		SetPlayerPos(pID, px, py, pz-4);
		PlayerPlaySound(pID, 1190, 0.0, 0.0, 0.0);
		SendClientMessage(pID, COLOR_LIGHTRED, sprintf("PUNISHMENT: Admin %s has downslapped you.", GetName(playerid)));
	}
	return 1;
}
CMD<AD1>:forward(cmdid, playerid, params[])
{
	new Float:amount, Float:x, Float:y, Float:z, Float:a;
	if(sscanf(params, "f", amount)) return SendUsageMessage(playerid, "/forward [amount]");

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, a);
	GetXYInFrontOfPlayer(playerid, x, y, amount);

	SetPlayerPos(playerid, x, y, z);
	SetPlayerFacingAngle(playerid, a);

	return 1;
}
CMD<AD2>:agoto(cmdid, playerid, params[])
{
	new TargetPlayer;
	if(sscanf(params, "u", TargetPlayer)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /gotop [id]");
	if(!IsPlayerConnected(TargetPlayer)) return SendErrorMessage(playerid, ERROR_OPTION);

	new Float:X, Float:Y, Float:Z;
	SetPlayerInterior(playerid, GetPlayerInterior(TargetPlayer));
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(TargetPlayer));
	GetPlayerPos(TargetPlayer, X, Y, Z);
	SetPlayerPos(playerid, X, Y, Z);

	SendClientMessage(playerid, COLOR_INDIANRED, sprintf("{bf0000}NOTICE: {FFFFFF}You have teleported to %s.", GetName(TargetPlayer)));
	SendClientMessage(TargetPlayer, COLOR_INDIANRED, sprintf("{bf0000}NOTICE: {FFFFFF}Admin %s has teleported to your position.", GetName(playerid)));
	return 1;
}
CMD<AD2>:aget(cmdid, playerid, params[])
{
	new TargetPlayer;
	if(sscanf(params, "u", TargetPlayer)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /getp [playerid]");
	if(!IsPlayerConnected(TargetPlayer)) return SendErrorMessage(playerid, ERROR_OPTION);

	new Float:X, Float:Y, Float:Z;
	if(IsPlayerInAnyVehicle(TargetPlayer))
	{
		GetPlayerPos(playerid, X, Y, Z);
		SetVehiclePos(GetPlayerVehicleID(TargetPlayer), X, Y, Z+5);

		SetPlayerInterior(TargetPlayer, GetPlayerInterior(playerid));
		SetPlayerVirtualWorld(TargetPlayer, GetPlayerVirtualWorld(playerid));

		SendClientMessage(playerid, COLOR_GRAY, sprintf("{bf0000}NOTICE: {FFFFFF}You have teleported %s to your position.", GetName(TargetPlayer)));
		SendClientMessage(TargetPlayer, COLOR_GRAY, sprintf("{bf0000}NOTICE: {FFFFFF}Admin %s has teleported you to their position.", GetName(playerid)));
		return 1;
	}
	else
	{
		GetPlayerPos(playerid, X, Y, Z);
		SetPlayerPosEx(TargetPlayer, X, Y, Z+2, GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid));

		SendClientMessage(playerid, COLOR_GRAY, sprintf("{bf0000}NOTICE: {FFFFFF}You have teleported %s to your position.", GetName(TargetPlayer)));
		SendClientMessage(TargetPlayer, COLOR_GRAY, sprintf("{bf0000}NOTICE: {FFFFFF}Admin %s has teleported you to their position.", GetName(playerid)));
		return 1;
	}
}
CMD<AD1>:gotov(cmdid, playerid, params[])
{
	new TargetVehicle;
	if(sscanf(params, "d", TargetVehicle)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /gotov [VehicleID]");
	if(!GetVehicleModel(TargetVehicle)) return SendErrorMessage(playerid, "Invalid vehicle ID.");

	new Float:X, Float:Y, Float:Z;
	if(IsPlayerInAnyVehicle(playerid))
	{
		GetVehiclePos(TargetVehicle, X, Y, Z);
		SetVehiclePos(GetPlayerVehicleID(playerid), X, Y, Z+5);

		SendClientMessage(playerid, COLOR_GRAY, sprintf("{bf0000}NOTICE: {FFFFFF}You have teleported to vehicle %d.", TargetVehicle));
	}
	else
	{
		GetVehiclePos(TargetVehicle, X, Y, Z);
		SetPlayerPos(playerid, X, Y, Z+5);
	}

	SendClientMessage(playerid, COLOR_GRAY, sprintf("{bf0000}NOTICE: {FFFFFF}You have been teleported to vehicle %d position.", TargetVehicle));
	return 1;
}
CMD<AD4>:getv(cmdid, playerid, params[])
{
	new TargetVehicle;
	if(sscanf(params, "d", TargetVehicle)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /getv [VehicleID]");

	new Float:X, Float:Y, Float:Z;
	GetPlayerPos(playerid, X, Y, Z);
	GetInFrontOfPlayer(playerid, X, Y, 1);
	SetVehiclePos(TargetVehicle, X, Y, Z);
	SendClientMessage(playerid, COLOR_GRAY, sprintf("{bf0000}NOTICE: {FFFFFF}Vehicle %d has been teleported.", TargetVehicle));
	return 1;
}
CMD<AD6>:giveupgrades(cmdid, playerid, params[])
{
	Account[playerid][SkinPackUnlock]++;
	Account[playerid][BronzePackages]++;
	Account[playerid][SilverPackages]++;
	Account[playerid][DiamondPackages]++;
	Account[playerid][NameChangePackages]++;
	Account[playerid][PremiumKeyPackages]++;
	SendClientMessage(playerid, COLOR_LIGHTRED, "{bf0000}NOTICE: {FFFFFF}You have been given all possible upgrades.");
	return 1;
}
CMD<AD2>:delv(cmdid, playerid, params[])
{
	if(!IsPlayerInAnyVehicle(playerid)) return SendErrorMessage(playerid, ERROR_VEHICLE);

	new Vehicle = GetPlayerVehicleID(playerid);
	if(Vehicle > 0)
	{
		DestroyVehicle(Vehicle);
		SendClientMessage(playerid, COLOR_GRAY, "{bf0000}NOTICE: {FFFFFF}The vehicle has been deleted!");
	}
	return 1;
}
CMD<AD5>:customskin(cmdid, playerid, params[])
{
	new skin;
	if(sscanf(params, "i", skin)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /customskin [20001 - 20022]");
	SetPlayerSkinEx(playerid, skin);
	return 1;
}
CMD<AD1>:ban(cmdid, playerid, params[])
{
	new pID, reason[128];
	if(sscanf(params, "uS(Not specified)[128]", pID, reason)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /ban [id] [reason]");
	if(!IsPlayerConnected(pID)) return SendErrorMessage(playerid, ERROR_OPTION);
	if(Account[pID][Admin] >= 1 && Account[playerid][Admin] < 6) return SendClientMessage(playerid, COLOR_GRAY, "{bf0000}NOTICE: {FFFFFF}You can't ban admins.");

	if (GetPlayerAdminHidden(playerid))
		SendPunishmentMessage(sprintf("An admin has banned %s. Reason: %s", GetName(pID), reason));
	else
		SendPunishmentMessage(sprintf("Admin %s has banned %s. Reason: %s", GetName(playerid), GetName(pID), reason));

	IssueBan(pID, GetName(playerid), reason);
	KickPlayer(pID);
	Account[playerid][AdminActions]++;
	return 1;
}
CMD<AD4>:banip(cmdid, playerid, params[])
{
	new ip[24], minutes;
	if(sscanf(params, "s[24]i", ip, minutes))
		return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /banip [ip (wildcards supported)] [minutes]");

	SendAdminsMessage(1, COLOR_GRAY, sprintf("{bf0000}Admin Notice: {FFFFFF}%s has blocked IP '%s' on '%i' minutes", GetName(playerid), ip, minutes));

	BlockIpAddress(ip, 1000 * minutes);
	Account[playerid][AdminActions]++;
	return 1;
}
CMD<AD4>:unbanip(cmdid, playerid, params[])
{
	new ip[24];
	if(sscanf(params, "s[24]", ip))
		return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /unbanip [ip (wildcards supported)]");

	SendAdminsMessage(1, COLOR_GRAY, sprintf("{bf0000}Admin Notice: {FFFFFF}%s un-blocked IP '%s'", GetName(playerid), ip));

	UnBlockIpAddress(ip);
	Account[playerid][AdminActions]++;
	return 1;
}
CMD<AD1>:remoteban(cmdid, playerid, params[])
{
	new account[64], reason[128];
	if(sscanf(params, "s[25]S(Not specified)[128]", account, reason)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /remoteban [name] [reason]");

	yield 1;
	await mysql_aquery_s(SQL_CONNECTION, str_format("SELECT `SQLID`, `Username` `LatestIP` FROM `Accounts` WHERE `Username` = '%e'", account));
	if(!cache_num_rows()) return SendClientMessage(playerid, -1, sprintf("{bf0000}NOTICE: {FFFFFF}The user %s was not found, please check your input again.", account));

	new playersqlid, ip;
	cache_get_value_name_int(0, "SQLID", playersqlid);
	cache_get_value_name_int(0, "LatestIP", ip);

	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO Bans (PlayerName, IP, C_ID, A_ID, Timestamp, BannedBy, Reason) VALUES('%e', '%e', %d, %d, %d, '%e', '%e')", account, ip, playersqlid, playersqlid, gettime(), GetName(playerid), reason));

	Account[playerid][AdminActions]++;
	SendClientMessage(playerid, -1, sprintf("{1E90FF}(Admin Notice):{dadada} You have banned the user %s(userid: %d), reason: %s", account, playersqlid, reason));
	return 1;
}
CMD<AD1>:offlinejail(cmdid, playerid, params[])
{
	new pID[MAX_PLAYER_NAME], reason[64], time;
	if(sscanf(params, "sis[64]", pID, time, reason)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /ajail [playername] [minutes] [reason]");

	Account[playerid][AdminActions]++;
	SendPunishmentMessage(sprintf("PUNISHMENT: Admin %s has offline jailed %s for %i minutes! (Reason: %s)", GetName(playerid), pID, time, reason));
	SendAdminsMessage(1, COLOR_GRAY, sprintf("{bf0000}Admin Notice: {FFFFFF}%s a-jailed %s! Reason: %s", GetName(playerid), pID, reason));
	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp) VALUES('%e', '%e', '/ajail', '%e', '%d')", GetName(playerid), pID, reason, gettime()));
	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE `Accounts` SET ajail_minutes = %i WHERE `Username` = '%e'", time, pID));
	return 1;
}
CMD<AD5>:giveallkey(cmdid, playerid, params[])
{
	SendClientMessageToAll(-1, sprintf("{bf0000}NOTICE: {FFFFFF}Admin {%06x}%s {ffffff}has given all online users 1 Premium Key.", GetPlayerColor(playerid) >>> 8, GetName(playerid)));
	GiveAllKey();
	return 1;
}
CMD<AD6>:giveevent(cmdid, playerid,params[])
{
	Account[playerid][PlayerEvents]++;
	SendClientMessage(playerid, -1, sprintf("{1E90FF}(Admin Notice):{dadada} You have given yourself an event and have now have %d events.", Account[playerid][PlayerEvents]));
	return 1;
}
CMD<AD5>:setadmin(cmdid, playerid, params[])
{
	new TargetPlayer, level;
	if(sscanf(params, "ui", TargetPlayer, level)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: setadmin [id] [level]");
	if(!IsPlayerConnected(TargetPlayer)) return SendErrorMessage(playerid, ERROR_OPTION);
	if(Account[TargetPlayer][Admin] > Account[playerid][Admin]) return SendClientMessage(playerid, COLOR_GRAY, "You cannot set an admin level to a person who is a higher rank than you.");
	if(level > Account[playerid][Admin]) return SendClientMessage(playerid, COLOR_GRAY, "You cannot set a person's admin level to a higher level than your own!");
	SendClientMessage(playerid, COLOR_INDIANRED, sprintf("{bf0000}NOTICE: {FFFFFF}You have set %s's staff level to %d.", GetName(TargetPlayer), level));
	SendClientMessage(TargetPlayer, COLOR_INDIANRED, sprintf("{bf0000}NOTICE: {FFFFFF}Admin %s has set you staff level to %d.", GetName(playerid), level));
	Account[TargetPlayer][Admin] = level;
	return 1;
}
CMD<AD5>:osetadmin(cmdid, playerid, params[])
{
	new PlayerName[MAX_PLAYER_NAME + 1], level;
	if(sscanf(params, "s[26]i", PlayerName, level)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /osetadmin [name] [level]");

	yield 1;
	await mysql_aquery_s(SQL_CONNECTION, str_format("SELECT Admin FROM Accounts WHERE Username = '%e'", PlayerName));
	if(!cache_num_rows()) return SendClientMessage(playerid, COLOR_GRAY, sprintf("Nobody has been found with the name %s.", PlayerName));

	new OldLevel;
	cache_get_value_name_int(0, "Admin", OldLevel);
	if(OldLevel > Account[playerid][Admin]) return SendClientMessage(playerid, COLOR_GRAY, "You cannot set a person's admin level to a higher level than your own!");

	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE Accounts SET Admin = %d WHERE Username = '%e'", level, PlayerName));
	SendClientMessage(playerid, COLOR_GRAY, sprintf("You have successfully set %s's admin level to %d", PlayerName, level));
	return 1;
}
CMD<AD5>:osetclanmanagement(cmdid, playerid, params[])
{
	new PlayerName[MAX_PLAYER_NAME + 1], level;
	if(sscanf(params, "s[26]i" , PlayerName, level)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /osetclanmanagement [name] [level]");

	yield 1;
	await mysql_aquery_s(SQL_CONNECTION, str_format("SELECT ClanManagement FROM Accounts WHERE Username = '%e'", PlayerName));
	if(!cache_num_rows()) return SendClientMessage(playerid, COLOR_GRAY, sprintf("Nobody has been found with the name %s.", PlayerName));

	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE Accounts SET ClanManagement = %d WHERE Username = '%e'", level, PlayerName));
	SendClientMessage(playerid, COLOR_GRAY, sprintf("You have successfully set %s's clan management level to %d", PlayerName, level));
	return 1;
}
CMD<AD1>:lastajail(cmdid, playerid, params[])
{
	new TargetPlayer;
	if(sscanf(params, "u", TargetPlayer)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /lastajail [playername/id]");

	yield 1;
	await mysql_aquery_s(SQL_CONNECTION, str_format("SELECT * from logs WHERE PlayerName = '%e' AND Command = '/ajail' ORDER BY ID DESC LIMIT 1;", GetName(TargetPlayer)));
	if(!cache_num_rows()) return SendClientMessage(playerid, COLOR_GRAY, sprintf("%s has not been ajailed yet.", TargetPlayer));

	new admin[32], reason[64], time, when;
	cache_get_value_name(0, "AdminName", admin);
	cache_get_value_name(0, "Reason", reason);
	cache_get_value_int(0, "ajailtime", time);
	cache_get_value_int(0, "Timestamp", when);

	SendClientMessage(playerid, COLOR_LIGHTBLUE, sprintf("Player %s has been last ajailed %i minutes ago by %s for %s. Duration %i minutes.", GetName(TargetPlayer), time, admin, reason, time));
	return 1;
}
CMD<AD1>:unban(cmdid, playerid, params[])
{
	Unban_Dialog(playerid);
	return 1;
}
CMD<AD3>:flip(cmdid, playerid)
{
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: You must be in a vehicle.");

	new Float:angle, vID = GetPlayerVehicleID(playerid);
	GetVehicleZAngle(vID, angle);
	SetVehicleZAngle(vID, angle);
	SendAdminsMessage(6, COLOR_SLATEGRAY, sprintf("%s has flipped vehicle %d.", GetName(playerid), vID));
	return 1;
}
CMD<AD3>:achangename(cmdid, playerid, params[])
{
	new player, NewName[24];
	if(!sscanf(params, "u", player) && strcmp(GetName(playerid), Account[playerid][Name]))
	{
		SetPlayerName(player, Account[playerid][Name]);
		format(pName[player], MAX_PLAYER_NAME + 1, Account[playerid][Name]);
		return 1;
	}
	else if(sscanf(params, "us[24]", player, NewName)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /achangename [playerid] [New Name]");

	yield 1;
	await mysql_aquery_s(SQL_CONNECTION, str_format("SELECT * FROM Accounts WHERE Username = '%e' LIMIT 1", NewName));
	if(cache_num_rows()) return SendClientMessage(playerid, COLOR_GRAY, "{bf0000}NOTICE: {FFFFFF}This name already exists in the database.");

	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE Accounts SET Username = '%e' WHERE sqlid = %i", NewName, Account[player][SQLID]));
	SetPlayerName(player, NewName);
	format(pName[player], MAX_PLAYER_NAME + 1, NewName);
	SendClientMessage(playerid, COLOR_LGREEN, "{bf0000}NOTICE: {FFFFFF}You have successfully changed the player's name.");
	return 1;
}
CMD<AD3>:ahide(cmdid, playerid, params[])
{
	ToggleAdminHidden(playerid);
	return 1;
}

CMD<AD5>:activitycheck(cmdid, playerid, params[]) {
	yield 1;
    new Username[MAX_PLAYER_NAME + 1], days;

    if(sscanf(params, "s[24]d", Username, days)) return SendClientMessage(playerid, COLOR_GREY, "USAGE: /activitycheck [AdminName] [Time (in days)]");

    if(days <= 0) return SendClientMessage(playerid, 0x8B0000FF, "Days has to be atleast 1.");

    new daystoseconds = 86400 * days, timestamp = gettime() - daystoseconds;

	await mysql_aquery_s(SQL_CONNECTION, str_format("SELECT SQLID FROM `Accounts` WHERE `Username` = '%s'", Username));

	if(!cache_num_rows()) return SendErrorMessage(playerid, "That name was not found in our database!");

	await mysql_aquery_s(SQL_CONNECTION, str_format("SELECT (SELECT COUNT(*) FROM Bans WHERE BannedBy = '%s' AND TIMESTAMP >= %d) AS ban_count,\
	 	(SELECT COUNT(*) FROM `logs` WHERE `AdminName` = '%s' AND `Timestamp` >= %d AND `Command` = '/ajail') AS ajail_count,\
		(SELECT COUNT(*) FROM `logs` WHERE `AdminName` = '%s' AND `Timestamp` >= %d AND `Command` = '/forcelobby') AS lobby_count,\
		(SELECT COUNT(*) FROM `logs` WHERE `AdminName` = '%s' AND `Timestamp` >= %d AND `Command` = '/forcerules') AS rules_count,\
		(SELECT COUNT(*) FROM `logs` WHERE `AdminName` = '%s' AND `Timestamp` >= %d AND `Command` = '/mute') AS mute_count",\
		Username, timestamp, Username, timestamp, Username, timestamp, Username, timestamp, Username, timestamp));

	if(!cache_num_rows()) return SendErrorMessage(playerid, "Something went wrong. Couldn't find those stats.");

	new bans,
		ajails,
		lobbies,
		rules,
		mutes;

	cache_get_value_name_int(0, "ban_count", bans);
	cache_get_value_name_int(0, "ajail_count", ajails);
	cache_get_value_name_int(0, "lobby_count", lobbies);
	cache_get_value_name_int(0, "rules_count", rules);
	cache_get_value_name_int(0, "mute_count", mutes);

	SendClientMessage(playerid, COLOR_LIGHTRED, sprintf("Viewing Activity for %s in the past %d days:", Username, days));
	SendClientMessage(playerid, 0xADD8E6FF, sprintf("Bans: %d", bans));
	SendClientMessage(playerid, 0xADD8E6FF, sprintf("Ajails: %d", ajails));
	SendClientMessage(playerid, 0xADD8E6FF, sprintf("Force Lobbies: %d", lobbies));
	SendClientMessage(playerid, 0xADD8E6FF, sprintf("Force Rules: %d", rules));
	SendClientMessage(playerid, 0xADD8E6FF, sprintf("Mutes: %d", mutes));
    return 1;
}

// silent commands
CMD<AD4>:sban(cmdid, playerid, params[])
{
	new pID, reason[128];
	if(sscanf(params, "uS(Not specified)[128]", pID, reason)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /ban [id] [reason]");
	if(!IsPlayerConnected(pID)) return SendErrorMessage(playerid, ERROR_OPTION);
	if(Account[pID][Admin] >= 1 && Account[playerid][Admin] < 6) return SendClientMessage(playerid, COLOR_GRAY, "{bf0000}NOTICE: {FFFFFF}You can't ban admins.");


	SendAdminsMessage(1, COLOR_GRAY, sprintf("Admin %s has banned %s. Reason: %s.", GetName(playerid), GetName(pID), reason));

	IssueBan(pID, GetName(playerid), reason);
	KickPlayer(pID);
	Account[playerid][AdminActions]++;
	return 1;
}

CMD<AD4>:sajail(cmdid, playerid, params[])
{
	new target, time, reason[64];
	if(sscanf(params, "uis[64]", target, time, reason)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /ajail [id] [minutes] [reason]");
	if(!IsPlayerConnected(target)) return SendErrorMessage(playerid, ERROR_OPTION);

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
	SetPlayerPosEx(target, 2518.7590, 602.5683, 45.2066, 0, 0);

	SendAdminsMessage(1, COLOR_GRAY, sprintf("{bf0000}Admin Notice: {FFFFFF}%s a-jailed %s! Reason: %s", GetName(playerid), GetName(target), reason));

	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp, ajailtime) VALUES('%e', '%e', '/ajail', '%e', '%d', '%i')", GetName(playerid), GetName(target), reason, gettime(), time));
	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE Accounts SET ajail_minutes = %i WHERE SQLID = %i", time, Account[target][SQLID]));

	Account[playerid][AdminActions]++;

	ResetPlayerWeapons(target);
	return 1;
}

CMD<AD4>:sslap(cmdid, playerid, params[])
{
	new pID;
	if(sscanf(params, "u", pID)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /sslap [id]");
	PlayerPlaySound(playerid, 1190, 0.0, 0.0, 0.0);

	new Float:px, Float:py, Float:pz;
	if(!IsPlayerInAnyVehicle(pID))
	{
		GetPlayerPos(pID, px, py, pz);
		SetPlayerPos(pID, px, py, pz+4);
		PlayerPlaySound(pID, 1190, 0.0, 0.0, 0.0);
		SendAdminsMessage(1, COLOR_GRAY, sprintf("{bf0000}Admin Notice: {FFFFFF}%s slapped %s!", GetName(playerid), GetName(pID)));
	}
	return 1;
}

// - Server Administrator (Level 1)

CMD<AD1>:amove(cmdid, playerid, params[])
{
	new targetid, amount;
	if(sscanf(params, "uI(5)", targetid, amount)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /amove [player id] [amount(optional)]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, NOPLAYER);
	if(Account[targetid][LoggedIn] != 1) return SendClientMessage(playerid, COLOR_RED, NOTLOGGEDIN);
	if(amount > 100) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: Value cannot be greater than 100!");
	if(GetPlayerAdminLevel(playerid) < Account[targetid][Admin]) return SendClientMessage(playerid, COLOR_RED, NOLEVEL);
	new Float:pos[3];
	GetPlayerPos(targetid, pos[0], pos[1], pos[2]);
	GetXYInFrontOfPlayer(targetid, pos[0], pos[1], amount);
 	SetPlayerPos(targetid, pos[0], pos[1], pos[2]);
	new adminmsg[150];
	format(adminmsg, sizeof(adminmsg), "You have moved %s(%i).", GetName(targetid), targetid);
	SendClientMessage(playerid, COLOR_RED, adminmsg);
	return 1;
}
CMD<AD1>:forceteam(cmdid, playerid, params[])
{
	new targetid;
	if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /forceteam [player]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, NOPLAYER);
	if(Account[targetid][LoggedIn] != 1) return SendClientMessage(playerid, COLOR_RED, NOTLOGGEDIN);
    if(GetPlayerAdminLevel(playerid) < Account[targetid][Admin]) return SendClientMessage(playerid, COLOR_RED, NOLEVEL);
	ForceClassSelection(targetid);
	SetPlayerHealth(targetid, 0.0);
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	new buf[150];
	format(buf, sizeof(buf), "[AdmCmd]: Admin [%i] %s has forced you to class selection.", playerid, GetName(playerid));
	SendClientMessage(targetid, COLOR_RED, buf);
	format(buf, sizeof(buf), "You have forced [%i] %s to class selection.", GetName(targetid), targetid);
	SendClientMessage(playerid, COLOR_RED, buf);
	return 1;
}
CMD<AD1>:weaps(cmdid, playerid, params[])
{
	new targetid;
	if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /weaps [playerid]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, NOPLAYER);
	if(Account[targetid][LoggedIn] != 1) return SendClientMessage(playerid, COLOR_RED, NOTLOGGEDIN);
    new weapons[13][2], weaponname[35], string[40], count=0;
	format(string, sizeof(string), "[AdmCmd]: %s's Weapons:", GetName(targetid));
	SendClientMessage(playerid, COLOR_RED, string);
	for (new i = 0; i <= 12; i++)
	{
	    GetPlayerWeaponData(targetid, i, weapons[i][0], weapons[i][1]);
	    if(weapons[i][0] != 0)
	    {
	        count++;
    		GetWeaponName(weapons[i][0], weaponname, sizeof(weaponname));
		    format(string, sizeof(string), "Weapon: %s (%d ammo)", weaponname, weapons[i][1]);
		    SendClientMessage(playerid, COLOR_GRAY, string);
	    }
	}
	if(!count)
	{
	    SendClientMessage(playerid, COLOR_GRAY, "None.");
	}
	return 1;
}
CMD<AD1>:vcolor(cmdid, playerid, params[])
{
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You must be in a vehicle to use this command.");
	new color1, color2;
	if(sscanf(params, "iI(-1)", color1, color2)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /vcolor [color1] [*color2]");
	ChangeVehicleColor(GetPlayerVehicleID(playerid), color1, color2);
	PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
	new buf[128];
	format(buf, sizeof(buf), "You have changed your vehicle's color to %i & %i.", color1, color2);
	SendClientMessage(playerid, COLOR_RED, buf);
	return 1;
}
CMD<AD1>:muted(cmdid, playerid)
{
	new string[64], count = 0;
	SendClientMessage(playerid, COLOR_GRAY, "Muted players:");
	foreach (new i : Player)
	{
		if (Account[i][LoggedIn] && Account[i][Muted] > gettime())
		{
			format(string, sizeof(string), "[%d] %s (%d seconds remaining)", i, GetName(i), Account[i][Muted]-gettime());
			SendClientMessage(playerid, COLOR_RED, string);
			count++;
		}
	}
	if(!count) SendClientMessage(playerid,COLOR_RED,"There are currently no muted players.");
	return 1;
}

CMD<AD1>:nos(cmdid, playerid, params[])
{
	if (!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You must be in a vehicle to use this command.");
	if(adminDuty[playerid] != true) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You can't use this command off admin duty.");
	new vehicle = GetPlayerVehicleID(playerid);
	switch (GetVehicleModel(vehicle))
	{
		case 448,461,462,463,468,471,509,510,521,522,523,581,586,449:
		{
			return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You cannot add nitros to this vehicle.");
		}
	}
	AddVehicleComponent(vehicle, 1010);
    SendClientMessage(playerid, COLOR_RED, "[AdmCmd]: You have added nitros (10x) to your vehicle.");
	return 1;
}

CMD<AD1>:countdown(cmdid, playerid, params[])
{
    new amount;
	if(sscanf(params, "i", amount)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /countdown [seconds]");
	if(amount > 30) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: Value cannot be greater than 30!");
	new buf[45];
	format(buf, sizeof(buf), "You have started a %d second countdown", amount);
	SendClientMessage(playerid, COLOR_LIMEGREEN, buf);
	Countdown = amount+1;
	CountdownTimer = SetTimer("Count", 850, true);
	return 1;
}

CMD<AD1>:tempban(cmdid, playerid, params[])
{
	new targetid, hours, reason[45];
	if(sscanf(params, "uis[45]", targetid, hours, reason) || isnull(params)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /ban [player id] [hours] [reason]");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, NOPLAYER);
	if(Account[targetid][LoggedIn] != 1) return SendClientMessage(playerid, COLOR_RED, NOTLOGGEDIN);
	if(targetid == playerid) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You can't use this command on yourself.");
	if(Account[targetid][Admin] > 1) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You cannot ban an admin.");
	new string[100], query[300], Player_IP[16];
	GetPlayerIp(targetid, Player_IP, 16);
    mysql_format(SQL_CONNECTION, query, sizeof(query), "INSERT INTO `bandata` (`User`, `BannedBy`,`ExpiresOn`,`BannedOn`,`BanReason`,`IPAddress`) VALUES ('%e','%e', DATE_ADD(NOW(), INTERVAL '%d' HOUR), NOW(), '%e', '%e');", GetName(targetid), GetName(playerid), hours, reason, Player_IP);
	mysql_tquery(SQL_CONNECTION, query, "", "");
	format(string, sizeof(string), "[AdmCmd]: %s has banned %s for %d hours. Reason: %s", GetName(playerid), GetName(targetid), hours, reason);
	SendClientMessageToAll(COLOR_RED, string);
	KickPlayer(targetid);
	return 1;
}

CMD<AD1>:fakeban(cmdid, playerid, params[])
{
	new targetid, reason[45];
	if(sscanf(params, "us[40]", targetid, reason) || isnull(params)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /fakeban [player id] [reason]");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, NOPLAYER);
	if(Account[targetid][LoggedIn] != 1) return SendClientMessage(playerid, COLOR_RED, NOTLOGGEDIN);
	if(targetid == playerid) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You can't use this command on yourself.");
	if(Account[targetid][Admin] > 1) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You cannot ban an admin.");

	if (GetPlayerAdminHidden(playerid)) {
		SendClientMessageToAll(COLOR_LIGHTRED, sprintf("An admin has banned %s. Reason: %s", GetName(targetid), reason));
	} else {
		SendClientMessageToAll(COLOR_LIGHTRED, sprintf("Admin %s has banned %s. Reason: %s", GetName(playerid), GetName(targetid), reason));
	}

	return 1;
}

CMD<AD1>:get(cmdid, playerid, params[])
{
	new targetid;
	if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /get [player id]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, NOPLAYER);
	if(Account[targetid][LoggedIn] != 1) return SendClientMessage(playerid, COLOR_RED, NOTLOGGEDIN);
	if(GetPlayerState(targetid) == PLAYER_STATE_SPECTATING) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: The specified player is not spawned.");
	if(GetPlayerAdminLevel(playerid) < Account[targetid][Admin]) return SendClientMessage(playerid, COLOR_RED, NOLEVEL);
	if(targetid == playerid) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You can't get yourself.");
	SetPlayerInterior(targetid, GetPlayerInterior(playerid));
	SetPlayerVirtualWorld(targetid, GetPlayerVirtualWorld(playerid));
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	if (GetPlayerState(targetid) == PLAYER_STATE_DRIVER)
	{
	    new vehicleid = GetPlayerVehicleID(targetid);
		SetVehiclePos(vehicleid, x, y + 2.5, z+1);
		LinkVehicleToInterior(vehicleid, GetPlayerInterior(playerid));
		SetVehicleVirtualWorld(vehicleid, GetPlayerVirtualWorld(playerid));
	}
	else
	{
		SetPlayerPos(targetid, x, y + 2.0, z+1);
	}
	new buf[85];
	format(buf, sizeof(buf), "[AdmCmd]: Administrator %s has teleported you to his position.", GetName(playerid));
	SendClientMessage(targetid, COLOR_RED, buf);
	format(buf, sizeof(buf), "[AdmCmd]: You have teleported %s to your position.", GetName(targetid));
	SendClientMessage(playerid, COLOR_RED, buf);
	return 1;
}
CMD<AD1>:rw(cmdid, playerid, params[])
{
	new targetid;
	if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /rw [player]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, NOPLAYER);
	if(Account[targetid][LoggedIn] != 1) return SendClientMessage(playerid, COLOR_RED, NOTLOGGEDIN);
    if(GetPlayerAdminLevel(playerid) < Account[targetid][Admin]) return SendClientMessage(playerid, COLOR_RED, NOLEVEL);
	ResetPlayerWeapons(targetid);
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	new buf[150];
	format(buf, sizeof(buf), "Admin %s has disarmed you.", GetName(playerid), playerid);
	SendClientMessage(targetid, COLOR_RED, buf);
	format(buf, sizeof(buf), "You have disarmed %s.", GetName(targetid), targetid);
	SendClientMessage(playerid, COLOR_RED, buf);
	return 1;
}
CMD<AD1>:shp(cmdid, playerid, params[])
{
	new targetid, amount;
    if(sscanf(params, "ui", targetid, amount)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /shp [playerid] [amount]");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, NOPLAYER);
	if(Account[targetid][LoggedIn] != 1) return SendClientMessage(playerid, COLOR_RED, NOTLOGGEDIN);
	SetPlayerHealth(targetid, amount);
	new buf[150];
	format(buf, sizeof(buf), "You have set %s's health to %d.", GetName(targetid), amount);
	SendClientMessage(playerid, COLOR_RED, buf);
	return 1;
}
CMD<AD1>:sarm(cmdid, playerid, params[])
{
	new targetid, amount;
    if(sscanf(params, "ui", targetid, amount)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /sarm [playerid] [amount]");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, NOPLAYER);
	if(Account[targetid][LoggedIn] != 1) return SendClientMessage(playerid, COLOR_RED, NOTLOGGEDIN);
	SetPlayerArmour(targetid, amount);
	new buf[150];
	format(buf, sizeof(buf), "You have set %s's armour to %d.", GetName(targetid), amount);
	SendClientMessage(playerid, COLOR_RED, buf);
	return 1;
}
CMD<AD1>:explode(cmdid, playerid, params[])
{
	new targetid;
	if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /explode [player]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, NOPLAYER);
	if(Account[targetid][LoggedIn] != 1) return SendClientMessage(playerid, COLOR_RED, NOTLOGGEDIN);
    if(GetPlayerAdminLevel(playerid) < Account[targetid][Admin]) return SendClientMessage(playerid, COLOR_RED, NOLEVEL);
	new Float:x, Float:y, Float:z;
	GetPlayerPos(targetid, x, y, z);
	CreateExplosion(x, y, z, 7, 10.00);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	new buf[150];
	format(buf, sizeof(buf), "You have made an explosion on %s(%i)'s position.", GetName(targetid), targetid);
	SendClientMessage(playerid, COLOR_RED, buf);
	return 1;
}

CMD<AD1>:ip(cmdid, playerid, params[])
{
	new targetid;
	if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /ip [playerid]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, NOPLAYER);
	if(Account[targetid][LoggedIn] != 1) return SendClientMessage(playerid, COLOR_RED, NOTLOGGEDIN);
	if(GetPlayerAdminLevel(playerid) < Account[targetid][Admin]) return SendClientMessage(playerid, COLOR_RED, NOLEVEL);
	new country[30], region[30], city[30], isp[30], timezone[30];
	GetPlayerCountry(targetid, country);
	GetPlayerRegion(targetid, region);
	GetPlayerCity(targetid, city);
	GetPlayerISP(targetid, isp);
	GetPlayerTimezone(targetid, timezone);
	new Player_IP[16];	GetPlayerIp(targetid, Player_IP, 16);
	SendClientMessage(playerid, -1, sprintf("{FFCC66}Current internet lookup information on user: {FFFFFF}%s", GetName(targetid)));
	SendClientMessage(playerid, -1, sprintf("{FF5733}IP Address: {FFFFFF}%s", Player_IP));
	SendClientMessage(playerid, -1, sprintf("{FF5733}Country: {FFFFFF}%s", country));
	SendClientMessage(playerid, -1, sprintf("{FF5733}Region: {FFFFFF}%s", region));
	SendClientMessage(playerid, -1, sprintf("{FF5733}City: {FFFFFF}%s", city));
	SendClientMessage(playerid, -1, sprintf("{FF5733}Internet provider: {FFFFFF}%s", isp));
	SendClientMessage(playerid, -1, sprintf("{FF5733}Timezone: {FFFFFF}%s", timezone));
	//Dialog_Show(playerid, DIALOG_IP, DIALOG_STYLE_MSGBOX, "IP Address lookup", string, "OK", ""); // Show Help-dialog
	return 1;
}
CMD<AD1>:suicide(cmdid, playerid, params[])
{
	new targetid;
	if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /suicide [player id]");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, NOPLAYER);
	if(!Account[targetid][LoggedIn]) return SendClientMessage(playerid, COLOR_RED, NOTLOGGEDIN);
	if(GetPlayerAdminLevel(playerid) < Account[targetid][Admin]) return SendClientMessage(playerid, COLOR_RED, NOLEVEL);
	SetPlayerHealth(targetid, 0);
	return 1;
}

CMD<AD1>:schp(cmdid, playerid, params[])
{
	new targetid, health;
	if(sscanf(params, "ui", targetid, health)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /schp [playerid] [car health]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, NOPLAYER);
	if(Account[targetid][LoggedIn] != 1) return SendClientMessage(playerid, COLOR_RED, NOTLOGGEDIN);
	if(GetPlayerState(targetid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: That player is not in a vehicle.");
	new vehicleid = GetPlayerVehicleID(targetid), string[128];
	SetVehicleHealth(vehicleid, health);
	if(health >= 1000)
	    RepairVehicle(vehicleid);
	format(string, sizeof(string), "You have set %s's vehicle health to %d", GetName(targetid), health);
	SendClientMessage(playerid, COLOR_RED, string);
	return 1;
}

// Senior Administrator (Level 2)
CMD<AD2>:area(cmdid, playerid, params[])
{
    new subcommand[10], SendClientMessaged_params[28];
    if(sscanf(params, "s[15]S()[35]", subcommand, SendClientMessaged_params)) return SendClientMessage(playerid, COLOR_RED, "/area [heal/armour/weap/veh/freeze/unfreeze/skin/nos/disarm]");

    if(!strcmp(subcommand, "heal", true))
    {
        new range, string[128];
        if(sscanf(SendClientMessaged_params, "I(30)", range)) return SendClientMessage(playerid, COLOR_RED, "/area heal [range(optional)]");
  		foreach(new i : Player)
		{
		    if(Account[i][LoggedIn] && IsPlayerNearPlayer(i, playerid, range))
		    {
			    SetPlayerHealth(i, 100);
			    GameTextForPlayer(i, "~g~healed", 5000, 5);
		    }
		}
		format(string, sizeof(string), "You have healed players in range of %d.", range);
		SendClientMessage(playerid, COLOR_RED, string);
    }
    else if(!strcmp(subcommand, "armour", true))
    {
        new range, string[128];
        if(sscanf(SendClientMessaged_params, "I(30)", range)) return SendClientMessage(playerid, COLOR_RED, "/area armour [range(optional)]");
  		foreach(new i : Player)
		{
		    if(Account[i][LoggedIn] && IsPlayerNearPlayer(i, playerid, range))
		    {
			    SetPlayerArmour(i, 100);
			    GameTextForPlayer(i, "~g~armoured", 5000, 5);
		    }
		}
		format(string, sizeof(string), "You have armoured players in range of %d.", range);
		SendClientMessage(playerid, COLOR_RED, string);
    }
    else if(!strcmp(subcommand, "weap", true))
    {
        new range, weaponname[15], ammo, string[128];
        if(sscanf(SendClientMessaged_params, "s[15]iI(30)", weaponname, ammo, range)) return SendClientMessage(playerid, COLOR_RED, "/area weap [weapon name] [ammo] [range(optional)]");

		new GetID = GetWeaponIDFromName(weaponname);
		if (!(GetID > 0 && GetID < 19 || GetID > 21 && GetID < 47)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: Invalid weapon name.");
        GetWeaponName(GetID, weaponname, sizeof(weaponname));
        format(string, sizeof(string), "~g~weapon ~r~%s ~g~given", weaponname);
		foreach(new i : Player)
		{
		    if(Account[i][LoggedIn] && IsPlayerNearPlayer(i, playerid, range))
		    {
				GivePlayerWeapon(i, GetID, ammo);
			    GameTextForPlayer(i, string, 5000, 5);
		    }
		}
		format(string, sizeof(string), "You gave weapon %s with %d ammo players in range of %d.", weaponname, ammo, range);
		SendClientMessage(playerid, COLOR_RED, string);
    }
    else if(!strcmp(subcommand, "veh", true))
    {
        new range, carname[30], color1, color2, string[128];
        if(sscanf(SendClientMessaged_params, "s[30]I(-1)I(-1)I(30)", carname, color1, color2, range)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /area veh [Vehicle name/ID] [color1] [color2] (range)");
		new vID = FindVehicleByNameID(carname);
		if(vID == INVALID_VEHICLE_ID)
		{
			vID = strval(carname);
			if(!(399 < vID < 612)) return SendErrorMessage(playerid, "[ERROR]: Invalid vehicle model.");
		}

		format(string, sizeof(string), "~g~vehicle ~r~%s ~g~spawned", VehicleNames[vID - 400]);
		new Float:X, Float:Y, Float:Z;
		foreach(new i : Player)
		{
		    if(Account[i][LoggedIn] && IsPlayerNearPlayer(i, playerid, range))
		    {
		        if(IsPlayerInAnyVehicle(i))
		        	RemovePlayerFromVehicle(i);
                GetPlayerPos(i, X, Y, Z);
				CreateVehicle(vID, X, Y, Z, 0.0, color1, color2, 180000, 0);
				SetPlayerPos(i, X, Y, Z + 5);
			    GameTextForPlayer(i, string, 5000, 5);
		    }
		}
		format(string, sizeof(string), "You have spawned vehicle %s to players in range of %d.", VehicleNames[vID - 400],  range);
		SendClientMessage(playerid, COLOR_RED, string);
    }
    else if(!strcmp(subcommand, "freeze", true))
    {
        new range, string[128];
        if(sscanf(SendClientMessaged_params, "I(30)", range)) return SendClientMessage(playerid, COLOR_RED, "/area freeze [range(optional)]");
  		foreach(new i : Player)
		{
		    if(Account[i][LoggedIn] && IsPlayerNearPlayer(i, playerid, range))
		    {
			    TogglePlayerControllable(i, 0);
			    GameTextForPlayer(i, "~r~frozen", 5000, 5);
		    }
		}
		format(string, sizeof(string), "You have frozen players in range of %d.", range);
		SendClientMessage(playerid, COLOR_RED, string);
    }
    else if(!strcmp(subcommand, "unfreeze", true))
    {
        new range, string[128];
        if(sscanf(SendClientMessaged_params, "I(30)", range)) return SendClientMessage(playerid, COLOR_RED, "/area unfreeze [range(optional)]");
  		foreach(new i : Player)
		{
		    if(Account[i][LoggedIn] && IsPlayerNearPlayer(i, playerid, range))
		    {
			    TogglePlayerControllable(i, 1);
			    GameTextForPlayer(i, "~g~unfrozen", 5000, 5);
		    }
		}
		format(string, sizeof(string), "You have unfrozen players in range of %d.", range);
		SendClientMessage(playerid, COLOR_RED, string);
    }
    else if(!strcmp(subcommand, "skin", true))
    {
        new range, skin, string[128];
        if(sscanf(SendClientMessaged_params, "iI(30)", skin, range)) return SendClientMessage(playerid, COLOR_RED, "/area skin [skinid] [range(optional)]");
        if(skin < 0 || skin == 74 || skin > 311) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: Invalid skin ID, must be b/w 0 - 311 (except 74).");
  		foreach(new i : Player)
		{
		    if(Account[i][LoggedIn] && IsPlayerNearPlayer(i, playerid, range))
		    {
	    		SetPlayerSkin(i, skin);
				PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
			    GameTextForPlayer(i, "~p~skin changed", 5000, 5);
		    }
		}
		format(string, sizeof(string), "You have changed players skin in range of %d.", range);
		SendClientMessage(playerid, COLOR_RED, string);
    }
    else if(!strcmp(subcommand, "nos", true))
    {
        new range, string[128];
        if(sscanf(SendClientMessaged_params, "I(30)", range)) return SendClientMessage(playerid, COLOR_RED, "/area nos [range(optional)]");
  		foreach(new i : Player)
		{
		    if(Account[i][LoggedIn] && IsPlayerNearPlayer(i, playerid, range) && IsPlayerInAnyVehicle(i))
		    {
	    		AddVehicleComponent(GetPlayerVehicleID(i), 1010);
				PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
			    GameTextForPlayer(i, "~b~nos added", 5000, 5);
		    }
		}
		format(string, sizeof(string), "You have added nos to players in range of %d.", range);
		SendClientMessage(playerid, COLOR_RED, string);
    }
    else if(!strcmp(subcommand, "disarm", true))
    {
        new range, string[128];
        if(sscanf(SendClientMessaged_params, "I(30)", range)) return SendClientMessage(playerid, COLOR_RED, "/area disarm [range(optional)]");
  		foreach(new i : Player)
		{
		    if(Account[i][LoggedIn] && IsPlayerNearPlayer(i, playerid, range))
		    {
				PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
				ResetPlayerWeapons(i);
			    GameTextForPlayer(i, "~r~disarmed", 5000, 5);
		    }
		}
		format(string, sizeof(string), "You have disarmed players in range of %d.", range);
		SendClientMessage(playerid, COLOR_RED, string);
    }
    return 1;
}

CMD<AD2>:datasave(cmdid, playerid, params[])
{
	new string[70];
	format(string, sizeof(string), "Administrator %s has saved all online users accounts.", GetName(playerid));
	SendClientMessage(playerid, COLOR_WHITE, "Data is being auto saved. This command to be used only before shutting down the server (Not /restart)");
    SendClientMessage(playerid, COLOR_WHITE, "* Give the server about 30 seconds time before shutting down.");
	SendClientMessageToAll(COLOR_RED, string);
	foreach (new i : Player)
	{
        Character_Save(i);
	}
	return 1;
}
CMD<AD2>:ainject(cmdid, playerid, params[])
{
	new targetid, seatid, vehicle;
	if (sscanf(params, "ui", targetid, seatid)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /ainject [playerid] [seatid]");
	if (!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You must be in a vehicle to use this command.");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, NOPLAYER);
	if(Account[targetid][LoggedIn] != 1) return SendClientMessage(playerid, COLOR_RED, NOTLOGGEDIN);
	if(playerid == targetid) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You can't use this command on yourself.");
    vehicle = GetPlayerVehicleID(playerid);
	PutPlayerInVehicle(targetid, vehicle, seatid);

	new buf[65];
	format(buf, sizeof(buf), "[AdmCmd]: You have injected %s into your vehicle.", GetName(targetid));
	SendClientMessage(playerid, COLOR_RED, buf);
	return 1;
}
CMD<AD2>:setinterior(cmdid, playerid, params[])
{
	new targetid, interiorid;
	if(sscanf(params, "ui", targetid, interiorid)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /setinterior [playerid] [ID]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, NOPLAYER);
	if(Account[targetid][LoggedIn] != 1) return SendClientMessage(playerid, COLOR_RED, NOTLOGGEDIN);

	SetPlayerInterior(targetid, interiorid);

	new buf[150];
	format(buf, sizeof(buf), "Admin %s has set your interior to %d.", GetName(playerid), interiorid);
	SendClientMessage(targetid, COLOR_RED, buf);
	format(buf, sizeof(buf), "You have set %s's interior to %d.", GetName(targetid), interiorid);
	SendClientMessage(playerid, COLOR_RED, buf);
	return 1;
}

CMD<AD2>:giveallweapon(cmdid, playerid, params[])
{
	new weaponname[15], ammo;
	if (sscanf(params, "s[15]i", weaponname, ammo)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /giveallweapon [weapon name] [ammo]");

    new GetID = GetWeaponIDFromName(weaponname);
	if (!(GetID > 0 && GetID < 19 || GetID > 21 && GetID < 47)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: Invalid weapon name.");
	foreach (new i : Player)
	{
        GivePlayerWeapon(i, GetID, ammo);
	}
    GetWeaponName(GetID, weaponname, sizeof(weaponname));
	new string[128];
	format(string, sizeof(string), "Administrator %s gave all players weapon %s with %d ammo.", GetName(playerid), weaponname, ammo);
	SendClientMessageToAll(COLOR_ORANGE, string);
	return 1;
}
CMD<AD2>:vget(cmdid, playerid, params[])
{
	new targetid;
	if(sscanf(params, "i", targetid)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /vget [vehicle id]");
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	SetVehiclePos(targetid, x, y , z);
	SetPlayerPos(playerid, x, y, z+5);
	LinkVehicleToInterior(targetid, GetPlayerInterior(playerid));
	SetVehicleVirtualWorld(targetid, GetPlayerVirtualWorld(playerid));
	new buf[70];
	format(buf, sizeof(buf), "[AdmCmd]: You have teleported teleported vehicle ID %d to youself.", targetid);
	SendClientMessage(playerid, COLOR_RED, buf);
	return 1;
}

CMD<AD2>:copyweaps(cmdid, playerid, params[])
{
	new targetid, toid;
	if(sscanf(params, "uu", targetid, toid)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /copyweaps [from] [to]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, NOPLAYER);
	if(Account[targetid][LoggedIn] != 1) return SendClientMessage(playerid, COLOR_RED, NOTLOGGEDIN);
	if(!IsPlayerConnected(toid)) return SendClientMessage(playerid, COLOR_RED, NOPLAYER);
	if(Account[toid][LoggedIn] != 1) return SendClientMessage(playerid, COLOR_RED, NOTLOGGEDIN);
    new weapons[13][2], string[90];
    ResetPlayerWeapons(toid);
	for (new i = 0; i <= 12; i++)
	{
	    GetPlayerWeaponData(targetid, i, weapons[i][0], weapons[i][1]);
	    if(weapons[i][0] != 0)
	    {
		    GivePlayerWeapon(toid, weapons[i][0], weapons[i][1]);
	    }
	}
 	format(string, sizeof(string), "[AdmCmd]: Weapons have been copied from %s to %s.", GetName(targetid), GetName(toid));
  	SendClientMessage(playerid, COLOR_RED, string);
	return 1;
}
CMD<AD2>:clearchat(cmdid, playerid, params[])
{
	for (new i; i < 100; i++)
	{
		SendClientMessageToAll(-1, " ");
	}
	return 1;
}
CMD<AD2>:jetpack(cmdid, playerid, params[])
{
	if(adminDuty[playerid] == false) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You can't use this command while off admin duty!");
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
	SendClientMessage(playerid, COLOR_RED, "[AdmCmd]: You have spawned a jetpack.");
	return 1;
}
CMD<AD2>:unfreezeall(cmdid, playerid, params[])
{
	foreach(new i : Player)
	{
	    if(IsPlayerConnected(i) && Account[i][LoggedIn])
	        TogglePlayerControllable(i, true);
	}
	new string[128];
	format(string, sizeof(string), "Administrator %s has unfreezed all players.", GetName(playerid));
	SendClientMessageToAll(COLOR_RED, string);
	return 1;
}
CMD<AD2>:freezeall(cmdid, playerid, params[])
{
	foreach(new i : Player)
	{
	    if(IsPlayerConnected(i) && Account[i][LoggedIn])
	        TogglePlayerControllable(i, false);

	}
	new string[128];
	format(string, sizeof(string), "Administrator %s has freezed all players.", GetName(playerid));
	SendClientMessageToAll(COLOR_RED, string);
	return 1;
}
CMD<AD2>:sskin(cmdid, playerid, params[])
{
	new targetid, skin;
	if(sscanf(params, "ui", targetid, skin)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /sskin [player id] [skin id]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, NOPLAYER);
	if(Account[targetid][LoggedIn] != 1) return SendClientMessage(playerid, COLOR_RED, NOTLOGGEDIN);

	if(GetPlayerAdminLevel(playerid) < Account[targetid][Admin]) return SendClientMessage(playerid, COLOR_RED, "[ERROR] You cannot use this command on higher level admin.");
	if(skin < 0 || skin == 74 || skin > 311) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: Invalid skin ID, must be b/w 0 - 311 (except 74).");

	SetPlayerSkin(targetid, skin);
    TogglePlayerControllable(targetid, true);
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	new buf[150];
	format(buf, sizeof(buf), "Admin %s(%i) has set your skin id to %i.", GetName(playerid), playerid, skin);
	SendClientMessage(targetid, COLOR_RED, buf);
	format(buf, sizeof(buf), "You have set %s(%i)'s skin id to %i.", GetName(targetid), targetid, skin);
	SendClientMessage(playerid, COLOR_RED, buf);
	return 1;
}
CMD<AD2>:bringall(cmdid, playerid)
{
	new count = 0;
	foreach (new i : Player)
	{
		if(Account[i][LoggedIn])
		{
		    if(i == playerid) continue;
			new Float:x, Float:y, Float:z;
			GetPlayerPos(playerid, x, y, z);
			SetPlayerPos(i, x, y, z);
			count++;
		}
	}
	if (count == 0) return SendClientMessage(playerid,COLOR_RED,"[ERROR]: There are currently no players online.");
	new string[128];
	format(string, sizeof(string), "Administrator %s has teleported all players to his position.", GetName(playerid));
	SendClientMessageToAll(COLOR_LIGHTBLUE, string);
	return 1;
}

CMD<AD3>:watchpmall(cmdid, playerid, params[])
{
	if(AdminPMRead[playerid] == false)
	{
	    SendClientMessage(playerid, COLOR_LIGHTGREEN, "You will now see the player's messages.");
		AdminPMRead[playerid] = true;
	}
	else if(AdminPMRead[playerid])
	{
	    SendClientMessage(playerid, COLOR_RED, "You will no longer see player's messages.");
    	AdminPMRead[playerid] = false;
	}
	return 1;
}

CMD<AD2>:watchpm(cmdid, playerid, params[])
{
	new iTargetID;
	if(!sscanf(params, "u", iTargetID)) {
		WatchPM[playerid][iTargetID] = !WatchPM[playerid][iTargetID];
		new szString[144];
		format(szString, 144, "You are %s watching %s's PMs.", (WatchPM[playerid][iTargetID])?"now":"no longer", GetName(iTargetID));
		SendClientMessage(playerid, COLOR_LIGHTBLUE, szString);
	} else SendClientMessage(playerid, COLOR_RED, "/watchpm [ID]");
	return 1;
}

// Lead Administrator (Level 3)
CMD<AD3>:giveallmoney(cmdid, playerid, params[])
{
	new amount;
	if (sscanf(params, "i", amount)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /giveallmoney [amount]");
	if(amount > 50000) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You can't give more than 50.000$ per time!");
	foreach (new i : Player)
	{
		Account[i][Cash] += amount;
	}
	new buf[150];
	format(buf, sizeof(buf), "Admin %s(%i) has given all players $%i.", GetName(playerid), playerid, amount);
	SendClientMessageToAll(COLOR_RED, buf);
	return 1;
}
CMD<AD3>:healall(cmdid, playerid, params[])
{
	foreach (new i : Player)
	{
		SetPlayerHealth(i, 100.0);
		PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
	}

    new buf[150];
	format(buf, sizeof(buf), "Admin %s(%i) has healed all players.", GetName(playerid), playerid);
    SendClientMessageToAll(COLOR_RED, buf);
	return 1;
}
CMD<AD3>:armourall(cmdid, playerid, params[])
{
	foreach (new i : Player)
	{
		SetPlayerArmour(i, 100.0);
		PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
	}

	new buf[150];
	format(buf, sizeof(buf), "Admin %s(%i) has armoured all players.", GetName(playerid), playerid);
    SendClientMessageToAll(COLOR_RED, buf);
	return 1;
}
CMD<AD3>:astream(cmdid, playerid, params[])
{
    new link[150];
    if (sscanf(params, "s[150]", link)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /astream [mp3 link]");

   	new string[128];
	format(string, sizeof(string), "DJ %s has started an audio stream.", GetName(playerid));
	SendClientMessageToAll(COLOR_LIGHTBLUE, string);

	foreach (new i : Player)
    {
     	PlayAudioStreamForPlayer(i, link);
    }
    return 1;
}
CMD<AD3>:agivemoney(cmdid, playerid, params[])
{
	new targetid, amount;
	if(sscanf(params, "ui", targetid, amount)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /agivemoney [id] [amount]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, NOPLAYER);
    if(Account[targetid][LoggedIn] != 1) return SendClientMessage(playerid, COLOR_RED, NOTLOGGEDIN);
	if(amount > 1000000) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You can't give more than 1.000.000$ per time!");
	Account[targetid][Cash]+=amount;
	ResetPlayerMoney(targetid);
	GivePlayerMoney(targetid, Account[targetid][Cash]);
	new buf[150];
	format(buf, sizeof(buf), "Admininistrator %s gave you %d$ cash.", GetName(playerid), amount);
	SendClientMessage(targetid, COLOR_RED, buf);
	format(buf, sizeof(buf), "You gave %s %d$ cash.", GetName(targetid), amount);
	SendClientMessage(playerid, COLOR_RED, buf);
	return 1;
}

CMD<AD3>:setworld(cmdid, playerid, params[])
{
	new targetid, id;
	if(sscanf(params, "ui", targetid, id))	return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /setworld [player id] [world id]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, NOPLAYER);
	if(Account[targetid][LoggedIn] != 1) return SendClientMessage(playerid, COLOR_RED, NOTLOGGEDIN);
	if(GetPlayerAdminLevel(playerid) < Account[targetid][Admin]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You cannot use this command on higher level admin.");
	SetPlayerVirtualWorld(targetid, id);
	PlayerPlaySound(targetid, 1057, 0.0, 0.0, 0.0);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	new buf[150];
	format(buf, sizeof(buf), "Admin %s(%i) has set your virtual world id to %i.", GetName(playerid), playerid, id);
	SendClientMessage(targetid, COLOR_RED, buf);
	format(buf, sizeof(buf), "You have set %s(%i)'s virtual world id to %i.", GetName(targetid), targetid, id);
	SendClientMessage(playerid, COLOR_RED, buf);
	return 1;
}
CMD<AD3>:spawncars(cmdid, playerid)
{
	SendClientMessageToAll(COLOR_LIGHTGREEN, "SERVER: All unoccupied vehicles will be respawned in 20 seconds!");
	cmd_ann(cid_ann, playerid, "~y~vehicles respawning in ~r~ 20 ~y~secs.");
	SetTimer("RespawnCars", 20000, false); // (20 seconds)
	return 1;
}

// Manager (Level 4)
CMD<AD4>:fakecmd(cmdid, playerid, params[])
{
	new targetid, cmd[20], cmdparams[20], finalcmd[128];
	if(sscanf(params, "us[20]s[20]", targetid, cmd, cmdparams)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /fakecmd [playerid] [command] [params]");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, NOPLAYER);
	if(Account[targetid][LoggedIn] != 1) return SendClientMessage(playerid, COLOR_RED, NOTLOGGEDIN);
	if(targetid == playerid) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You can't use this command on yourself.");
	format(finalcmd, sizeof(finalcmd), "cmd_%s", cmd);
    CallLocalFunction(finalcmd, "us[20]", targetid, cmdparams);
    SendClientMessage(playerid, COLOR_RED, "Fake command sent.");
	return 1;
}
CMD<AD4>:fakechat(cmdid, playerid, params[])
{
	new targetid, text[128], string[128];
	if(sscanf(params, "us[128]", targetid, text)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /fakechat [playerid] [message]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, NOPLAYER);
	if(Account[targetid][LoggedIn] != 1) return SendClientMessage(playerid, COLOR_RED, NOTLOGGEDIN);
	if(targetid == playerid) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You can't use this command on yourself.");

	format(string, sizeof(string), "[%d] %s: {FFFFFF}%s", targetid, GetName(targetid), text);
	SendClientMessageToAll(GetPlayerColor(targetid), string);
	return 1;
}
CMD<AD4>:setmoney(cmdid, playerid, params[])
{
	new targetid, amount;
	if(sscanf(params, "ui", targetid, amount)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /setmoney [id] [amount]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, NOPLAYER);
	if(Account[targetid][LoggedIn] != 1) return SendClientMessage(playerid, COLOR_RED, NOTLOGGEDIN);
	Account[targetid][Cash] = amount;
	new buf[150];
	format(buf, sizeof(buf), "Admininistrator %s set your cash to %d$.", GetName(playerid), amount);
	SendClientMessage(targetid, COLOR_RED, buf);
	format(buf, sizeof(buf), "You have set %s's cash to %d$.", GetName(targetid), amount);
	SendClientMessage(playerid, COLOR_RED, buf);
	return 1;
}
CMD<AD4>:restart(cmdid, playerid, params[])
{
	SendRconCommand("gmx");
	return 1;
}

CMD<AD4>:lserv(cmdid, playerid, params[])
{
	new password[50], string[128];
	if(sscanf(params, "s[50]", password)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /lserv [password]");
	format(string, sizeof(string), "password %s", password);
	SendRconCommand(string);
	SendClientMessage(playerid, COLOR_RED, "Server password has been set.");
	return 1;
}
CMD<AD4>:ulserv(cmdid, playerid, params[])
{
	SendRconCommand("password 0");
	SendClientMessage(playerid, COLOR_GREEN, "Server password has been removed.");
	return 1;
}
// END OF SCRIPT
