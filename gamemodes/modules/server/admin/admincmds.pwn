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
	SendClientMessage(pID, COLOR_GRAY, "{31AEAA}Notice: {FFFFFF}You have been unfrozen by an admin.");
	return 1;
}
CMD<AD1>:setvw(cmdid, playerid, params[])
{
	new pID, vw;
	if(sscanf(params, "ui", pID, vw)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /setvw [playerid] [virtualworld]");

	SendAdminsMessage(1, COLOR_GRAY, sprintf("Admin %s has set %s's virtual world to %i.", GetName(playerid), GetName(pID), vw));
	SendClientMessage(pID, -1, sprintf("{31AEAA}Notice: {FFFFFF}Your virtual world has been set to %i by Administrator %s.", vw, GetName(playerid)));
	SetPlayerVirtualWorld(pID, vw);
	return 1;
}
CMD<AD6>:givetokens(cmdid, playerid, params[])
{
	new pID, tokenamount;
	if(sscanf(params, "ui", pID, tokenamount)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /givetoken [id] [amount]");

	Account[pID][Tokens] += tokenamount;
	SendClientMessage(pID, COLOR_LIGHTRED, sprintf("Notice: You were given %i tokens by %s.", tokenamount, GetName(playerid)));
	SendClientMessage(playerid, -1, "You gave the player KDM Tokens.");
	return true;
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

 	SendClientMessage(playerid, -1, sprintf("{31AEAA}Notice: {FFFFFF}You have forced the language dialog upon %s.", GetName(pid)));
 	SendClientMessage(pid, -1, sprintf("{31AEAA}Notice: {FFFFFF}You have been forced to select a language by %s.", GetName(playerid)));

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
    if(!IsPlayerConnected(player)) return SendErrorMessage(playerid, ERROR_OPTION);
    SetPlayerSkinEx(player, 20067);
    return 1;
}
CMD<AD1>:ip(cmdid, playerid, params[])
{
	new pID;
	if(sscanf(params, "u", pID)) return SendClientMessage(playerid, COLOR_GREY, "USAGE: /ip [id]");
	if(!IsPlayerConnected(pID)) return SendErrorMessage(playerid, ERROR_OPTION);

	new countryname[40], countryregion[40], playerisp[40], ipaddress[18];
	GetPlayerIp(pID, ipaddress, 18);
	GetPlayerCountry(pID, countryname);
	GetPlayerRegion(pID, countryregion);
	GetPlayerISP(pID, playerisp);
	SendClientMessage(playerid, COLOR_WHITE, sprintf("IP Address: %s, Country: %s, Area: %s", ipaddress, countryname, countryregion));
	SendClientMessage(playerid, COLOR_WHITE, sprintf("Server Latency: %ims, ISP: %s", GetPlayerPing(pID), playerisp));
	return 1;
}
CMD<AD1>:whois(cmdid, playerid, params[])
{
	new id, ip[16], country[64], isp[256], url[128];


	if(sscanf(params, "u", id)) return
		SendUsageMessage(playerid, "/whois [ID/name]");

	if(!IsPlayerConnected(id)) return
		SendErrorMessage(playerid, "Invalid player specified.");

	if(Account[id][Admin] > 0 && Account[playerid][Admin] < 6) return // only allows level 6 admins to check other admins whois info
		SendErrorMessage(playerid, "You cannot check that player's whois info.");



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
	SendClientMessage(playerid, -1, sprintf("{31AEAA}Notice: {FFFFFF}You have set %s's custom skin ID to %d.", GetName(pID), skinID));
	SendClientMessage(pID, -1, sprintf("{31AEAA}Notice: {FFFFFF}Admin %s has set your personal custom skin! You may now use /myskin.", GetName(playerid)));
	return 1;
}
CMD<AD4>:alockchat(cmdid, playerid, params[])
{
	ChatLocked = !ChatLocked;
	SendClientMessageToAll(COLOR_GRAY, sprintf("{31AEAA}Notice: {FFFFFF}Admin %s has %s the chat.", GetName(playerid), ChatLocked == true ? "locked" : "unlocked"));
	return 1;
}
CMD<AD2>:aclearchat(cmdid, playerid, params[])
{
	for (new i=0; i<250; i++)
	{
		SendClientMessageToAll(0xFFFFFFFF, " ");
	}
	SendClientMessageToAll(COLOR_GRAY, sprintf("{31AEAA}Notice: {FFFFFF}Admin %s has cleared the chat.", GetName(playerid)));
	return 1;
}

CMD<AD5>:achangepassword(cmdid, playerid, params[])
{
	new name[32], password[64];
	if(sscanf(params, "s[32]s[32]", name, password)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /achangeapassword [Account Name] [New Password]");
	if(strlen(password) < 5) return SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Notice: {FFFFFF}Your password must have more than 5 characters.");

	bcrypt_hash(password, BCRYPT_COST, "OnOfflineAccountHashed", "s", name);
	SendClientMessage(playerid, COLOR_LGREEN, "{31AEAA}Notice: {FFFFFF}You have successfully changed the accounts password, keep it safe.");
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
	SendAdminsMessage(1, COLOR_GRAY, sprintf("{31AEAA}Admin Notice: {FFFFFF}Admin %s has given %s weapon: %s (Ammo:%d)", GetName(playerid), GetName(Player), WeaponNameList[WeaponID], gWeaponAmmo));
	SendClientMessage(Player, COLOR_GRAY, sprintf("{31AEAA}Notice: {FFFFFF}Admin %s has given %s weapon: %s (Ammo:%d)", GetName(playerid), GetName(Player), WeaponNameList[WeaponID], gWeaponAmmo));
	return 1;
}
CMD<AD1>:ah(cmdid, playerid, params[])
{
	StatsLine(playerid);
	if(Account[playerid][Admin] >= 1)
	{
		SendClientMessage(playerid, COLOR_GRAY, "{1E90FF}Level 1 admin commands");
		if(Account[playerid][Admin] >= 1) SendCommandList(playerid, COLOR_GRAY, AD1);
	}
	if(Account[playerid][Admin] >= 2)
	{
		SendClientMessage(playerid, COLOR_GRAY, "{1E90FF}Level 2 admin commands");
		if(Account[playerid][Admin] >= 2) SendCommandList(playerid, COLOR_GRAY, AD2);
	}
	if(Account[playerid][Admin] >= 3)
	{
		SendClientMessage(playerid, COLOR_GRAY, "{1E90FF}Level 3 admin commands");
		if(Account[playerid][Admin] >= 3) SendCommandList(playerid, COLOR_GRAY, AD3);
	}
	if(Account[playerid][Admin] >= 4)
	{
		SendClientMessage(playerid, COLOR_GRAY, "{1E90FF}Level 4 admin commands");
		if(Account[playerid][Admin] >= 4) SendCommandList(playerid, COLOR_GRAY, AD4);
	}
	if(Account[playerid][Admin] >= 5)
	{
		SendClientMessage(playerid, COLOR_GRAY, "{1E90FF}Level 5 admin commands");
		if(Account[playerid][Admin] >= 5) SendCommandList(playerid, COLOR_GRAY, AD5);
	}
	if(Account[playerid][Admin] >= 6)
	{
		SendClientMessage(playerid, COLOR_GRAY, "{1E90FF}Level 6 admin commands");
		if(Account[playerid][Admin] >= 6) SendCommandList(playerid, COLOR_GRAY, AD6);
	}
	StatsLine(playerid);
	return 1;
}
CMD<AD1>:a(cmdid, playerid, params[])
{
	if(isnull(params)) return SendUsageMessage(playerid, "/a [text]");

	SendAdminsMessage(1, COLOR_TURQUOISE, sprintf("%s: %s", GetName(playerid), params));
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
	if(!IsPlayerConnected(pID)) return SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Notice: {FFFFFF}This player is not connected!");

	SendClientMessage(playerid, -1, sprintf("{31AEAA}FPS CHECK: {FFFFFF}User {%06x}%s {FFFFFF}has {D69929}%d {FFFFFF}FRAMES PER SECOND.", GetPlayerColor(pID) >>> 8, GetName(pID), pFPS[pID]));
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
	if(Account[pID][Admin] >= 1 && Account[playerid][Admin] != 6) return SendErrorMessage(playerid, "You can't kick admins.");

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

	Account[pID][Muted] = time;
	Account[pID][Mutes]++;

	SendClientMessageToAll(COLOR_LIGHTRED, sprintf("PUNISHMENT: Admin %s has muted %s for %i minutes. Reason: %s", GetName(playerid), GetName(pID), time, reason));
	SendAdminsMessage(1, COLOR_GRAY, sprintf("{31AEAA}Admin Notice: {FFFFFF}%s has muted %s for %i minutes! Reason: %s", GetName(playerid), GetName(pID), time, reason));
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
	SetPlayerPosEx(target, 2518.7590, 602.5683, 45.2066, 0, 0);

	SendClientMessageToAll(COLOR_LIGHTRED, sprintf("PUNISHMENT: Admin %s has a-jailed %s for %d minutes! Reason: %s", GetName(playerid), GetName(target), time, reason));
	SendAdminsMessage(1, COLOR_GRAY, sprintf("{31AEAA}Admin Notice: {FFFFFF}%s a-jailed %s! Reason: %s", GetName(playerid), GetName(target), reason));

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

	SendClientMessage(pID, -1, sprintf("{31AEAA}Notice: {FFFFFF}You have been unjailed by %s.", GetName(playerid)));
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
	SendClientMessage(pID, COLOR_GRAY, sprintf("{31AEAA}Notice: {FFFFFF}Admin %s has unmuted you.", GetName(playerid)));
	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp) VALUES('%e', '%e', '/unmute', 'N/A', '%d')", GetName(playerid), GetName(pID), gettime()));
	return 1;
}
CMD<AD2>:freeze(cmdid, playerid, params[])
{
	new pID;
	if(sscanf(params, "u", pID)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /freeze [id]");
	if(!IsPlayerConnected(pID)) return SendErrorMessage(playerid, ERROR_OPTION);

	TogglePlayerControllable(pID, 0);
	SendAdminsMessage(1, COLOR_GRAY, sprintf("{31AEAA}Admin Notice: {FFFFFF}Admin %s has frozen %s.", GetName(playerid), GetName(pID)));
	SendClientMessage(pID, COLOR_GRAY, "{31AEAA}Notice: {FFFFFF}You have been frozen by an admin.");
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
			SendClientMessage(pID, COLOR_LIGHTRED, "PUNISHMENT: An admin %s has slapped you.");
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

	SendClientMessage(playerid, COLOR_INDIANRED, sprintf("{31AEAA}Notice: {FFFFFF}You have teleported to %s.", GetName(TargetPlayer)));
	SendClientMessage(TargetPlayer, COLOR_INDIANRED, sprintf("{31AEAA}Notice: {FFFFFF}Admin %s has teleported to your position.", GetName(playerid)));
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

		SendClientMessage(playerid, COLOR_GRAY, sprintf("{31AEAA}Notice: {FFFFFF}You have teleported %s to your position.", GetName(TargetPlayer)));
		SendClientMessage(TargetPlayer, COLOR_GRAY, sprintf("{31AEAA}Notice: {FFFFFF}Admin %s has teleported you to their position.", GetName(playerid)));
		return 1;
	}
	else
	{
		GetPlayerPos(playerid, X, Y, Z);
		SetPlayerPosEx(TargetPlayer, X, Y, Z+2, GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid));

		SendClientMessage(playerid, COLOR_GRAY, sprintf("{31AEAA}Notice: {FFFFFF}You have teleported %s to your position.", GetName(TargetPlayer)));
		SendClientMessage(TargetPlayer, COLOR_GRAY, sprintf("{31AEAA}Notice: {FFFFFF}Admin %s has teleported you to their position.", GetName(playerid)));
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

		SendClientMessage(playerid, COLOR_GRAY, sprintf("{31AEAA}Notice: {FFFFFF}You have teleported to vehicle %d.", TargetVehicle));
	}
	else
	{
		GetVehiclePos(TargetVehicle, X, Y, Z);
		SetPlayerPos(playerid, X, Y, Z+5);
	}

	SendClientMessage(playerid, COLOR_GRAY, sprintf("{31AEAA}Notice: {FFFFFF}You have been teleported to vehicle %d position.", TargetVehicle));
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
	SendClientMessage(playerid, COLOR_GRAY, sprintf("{31AEAA}Notice: {FFFFFF}Vehicle %d has been teleported.", TargetVehicle));
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
	SendClientMessage(playerid, COLOR_LIGHTRED, "{31AEAA}Notice: {FFFFFF}You have been given all possible upgrades.");
	return 1;
}
CMD<AD2>:delv(cmdid, playerid, params[])
{
	if(!IsPlayerInAnyVehicle(playerid)) return SendErrorMessage(playerid, ERROR_VEHICLE);

	new Vehicle = GetPlayerVehicleID(playerid);
	if(Vehicle > 0)
	{
		DestroyVehicle(Vehicle);
		SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Notice: {FFFFFF}The vehicle has been deleted!");
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
	if(Account[pID][Admin] >= 1 && Account[playerid][Admin] != 6) return SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Notice: {FFFFFF}You can't ban admins.");

	if (GetPlayerAdminHidden(playerid))
		SendClientMessageToAll(COLOR_LIGHTRED, sprintf("An admin has banned %s. Reason: %s", GetName(pID), reason));
	else
		SendClientMessageToAll(COLOR_LIGHTRED, sprintf("Admin %s has banned %s. Reason: %s", GetName(playerid), GetName(pID), reason));
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

	SendAdminsMessage(1, COLOR_GRAY, sprintf("{31AEAA}Admin Notice: {FFFFFF}%s has blocked IP '%s' on '%i' minutes", GetName(playerid), ip, minutes));

	BlockIpAddress(ip, 1000 * minutes);
	Account[playerid][AdminActions]++;
	return 1;
}
CMD<AD4>:unbanip(cmdid, playerid, params[])
{
	new ip[24];
	if(sscanf(params, "s[24]", ip))
		return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /unbanip [ip (wildcards supported)]");

	SendAdminsMessage(1, COLOR_GRAY, sprintf("{31AEAA}Admin Notice: {FFFFFF}%s un-blocked IP '%s'", GetName(playerid), ip));

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
	if(!cache_num_rows()) return SendClientMessage(playerid, -1, sprintf("{31AEAA}Notice: {FFFFFF}The user %s was not found, please check your input again.", account));

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
	SendClientMessageToAll(COLOR_LIGHTRED, sprintf("PUNISHMENT: Admin %s has offline jailed %s for %i minutes! (Reason: %s)", GetName(playerid), pID, time, reason));
	SendAdminsMessage(1, COLOR_GRAY, sprintf("{31AEAA}Admin Notice: {FFFFFF}%s a-jailed %s! Reason: %s", GetName(playerid), pID, reason));
	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp) VALUES('%e', '%e', '/ajail', '%e', '%d')", GetName(playerid), pID, reason, gettime()));
	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE `Accounts` SET ajail_minutes = %i WHERE `Username` = '%e'", time, pID));
	return 1;
}
CMD<AD5>:giveallkey(cmdid, playerid, params[])
{
	SendClientMessageToAll(-1, sprintf("{31AEAA}Notice: {FFFFFF}Admin {%06x}%s {ffffff}has given all online users 1 Premium Key.", GetPlayerColor(playerid) >>> 8, GetName(playerid)));
	GiveAllKey();
	return 1;
}
CMD<AD6>:giveevent(cmdid, playerid,params[])
{
	Account[playerid][PlayerEvents]++;
	SendClientMessage(playerid, -1, sprintf("{1E90FF}(Admin Notice):{dadada} You have given yourself an event and have now have %d events.", Account[playerid][PlayerEvents]));
	return 1;
}
CMD<AD5>:setlevel(cmdid, playerid, params[])
{
	new TargetPlayer, level;
	if(sscanf(params, "ui", TargetPlayer, level)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: setlevel [id] [level]");
	if(!IsPlayerConnected(TargetPlayer)) return SendErrorMessage(playerid, ERROR_OPTION);
	if(Account[TargetPlayer][Admin] > Account[playerid][Admin]) return SendClientMessage(playerid, COLOR_GRAY, "You cannot set an admin level to a person who is a higher rank than you.");
	if(level > Account[playerid][Admin]) return SendClientMessage(playerid, COLOR_GRAY, "You cannot set a person's admin level to a higher level than your own!");
	SendClientMessage(playerid, COLOR_INDIANRED, sprintf("{31AEAA}Notice: {FFFFFF}You have set %s's staff level to %d.", GetName(TargetPlayer), level));
	SendClientMessage(TargetPlayer, COLOR_INDIANRED, sprintf("{31AEAA}Notice: {FFFFFF}Admin %s has set you staff level to %d.", GetName(playerid), level));
	Account[TargetPlayer][Admin] = level;
	return 1;
}
CMD<AD5>:osetlevel(cmdid, playerid, params[])
{
	new PlayerName[MAX_PLAYER_NAME + 1], level;
	if(sscanf(params, "s[26]i", PlayerName, level)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /osetlevel [name] [level]");

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
CMD<AD6>:osetclanmanagement(cmdid, playerid, params[])
{
	new PlayerName[MAX_PLAYER_NAME + 1], level;
	if(sscanf(params, "s[26]i" , PlayerName, level)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /osetlevel [name] [level]");

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
		SendClientMessage(playerid, COLOR_LGREEN, "{31AEAA}Notice: {FFFFFF}The player's name has been restored.");
		SetPlayerName(player, Account[playerid][Name]);
		format(pName[player], MAX_PLAYER_NAME + 1, Account[playerid][Name]);
		return 1;
	}
	else if(sscanf(params, "us[24]", player, NewName)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /achangename [playerid] [New Name]");

	yield 1;
	await mysql_aquery_s(SQL_CONNECTION, str_format("SELECT * FROM Accounts WHERE Username = '%e' LIMIT 1", NewName));
	if(cache_num_rows()) return SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Notice: {FFFFFF}This name already exists in the database.");

	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE Accounts SET Username = '%e' WHERE sqlid = %i", NewName, Account[player][SQLID]));
	SetPlayerName(player, NewName);
	format(pName[player], MAX_PLAYER_NAME + 1, NewName);
	SendClientMessage(playerid, COLOR_LGREEN, "{31AEAA}Notice: {FFFFFF}You have successfully changed the player's name.");
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
	if(Account[pID][Admin] >= 1 && Account[playerid][Admin] != 6) return SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Notice: {FFFFFF}You can't ban admins.");


	SendAdminsMessage(1, COLOR_GRAY, sprintf("Admin %s has banned %s. Reason: %s.", GetName(playerid), GetName(pID), reason));

	IssueBan(pID, GetName(playerid), reason);
	KickPlayer(pID);
	Account[playerid][AdminActions]++;
	return 1;
}

CMD<AD4>:skick(cmdid, playerid, params[])
{
	new pID, reason[128];
	if(sscanf(params, "uS(Not specified)[128]", pID, reason)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /kick [ID/Name] [reason]");
	if(!IsPlayerConnected(pID)) return SendErrorMessage(playerid, ERROR_OPTION);
	if(Account[pID][Admin] >= 1 && Account[playerid][Admin] != 6) return SendErrorMessage(playerid, "You can't kick admins.");

	SendAdminsMessage(1, COLOR_GRAY, sprintf("Admin %s has kicked %s. Reason: %s.", GetName(playerid), GetName(pID), reason));

	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp) VALUES('%e', '%e', '/kick', '%e', %d)", GetName(playerid), GetName(pID), reason, gettime()));
	Account[pID][Kicks]++;
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

	SendAdminsMessage(1, COLOR_GRAY, sprintf("{31AEAA}Admin Notice: {FFFFFF}%s a-jailed %s! Reason: %s", GetName(playerid), GetName(target), reason));

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
		SendAdminsMessage(1, COLOR_GRAY, sprintf("{31AEAA}Admin Notice: {FFFFFF}%s slapped %s!", GetName(playerid), GetName(pID)));
	}
	return 1;
}
