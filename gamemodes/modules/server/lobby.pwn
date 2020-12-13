//data
//positions
#define FREEROAM_NPC_POS 2515.4778, 599.6540, 35.7424
#define ARENA_NPC_POS 2521.9836, 606.1979, 35.7459
#define GANGWAR_NPC_POS 2515.2917, 606.0045, 35.7424
#define COPCHASE_NPC_POS 2521.6025, 599.5485, 35.7459
#define DONATOR_NPC_POS 2518.4753, 615.0641, 35.7424
#define MONTHDM_NPC_POS 2530.2698, 603.0973, 35.7459

//actors
new arena_actor;
new copchase_actor;
new freeroam_actor;
new gangwars_actor;
new latestdonator_actor;
new monthlydm_actor;

//labels
new Text3D:dmerlabel;
new Text3D:latestdonatorlabel;

//commands
CMD:lobby(cmdid, playerid)
{
	if(ActivityState[playerid] == ACTIVITY_LOBBY && inServerHub[playerid] == 0) return SendClientMessage(playerid, -1, "{31AEAA}Notice: {FFFFFF}You are already in the lobby."); 
	if(Account[playerid][LobbyPermission] > gettime()) return SendClientMessage(playerid, -1, "{31AEAA}Notice: {FFFFFF}You recently took damage, please wait for 6 seconds before using this command.");
	HandleLobbyTransition(playerid);
	return 1;
}
CMD<AD1>:forcelobby(cmdid, playerid, params[])
{
	new pID;
	if(sscanf(params, "u", pID)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /forcelobby [ID]");
	if(!IsPlayerConnected(pID)) return SendErrorMessage(playerid, ERROR_OPTION);

	HandleLobbyTransition(pID);
	SendPunishmentMessage(sprintf("Admin %s has forced %s to the lobby.", GetName(playerid), GetName(pID)));
	mysql_pquery_s(SQL_CONNECTION, str_format("INSERT INTO logs (AdminName, PlayerName, Command, Reason, Timestamp) VALUES('%e', '%e', '/forcelobby', '', %d)", GetName(playerid), GetName(pID), gettime()));
	Account[playerid][AdminActions]++;
	return 1;
}

//functions
CreateLobbyActors()
{
	Create3DTextLabel("{EE5133}Shoot me to go to{33C4EE}\nFreeroam", -1, FREEROAM_NPC_POS, 40.0, 0);
	freeroam_actor = CreateActor(99, FREEROAM_NPC_POS, 316.2483);
	SetActorVirtualWorld(freeroam_actor, 0);
	SetActorInvulnerable(freeroam_actor, false);
	SetActorHealth(freeroam_actor, 1000);

	Create3DTextLabel("{EE5133}Shoot me for the list of{33C4EE}\nArenas", -1, ARENA_NPC_POS, 40.0, 0);
	arena_actor = CreateActor(80, ARENA_NPC_POS, 121.1037);
	SetActorVirtualWorld(arena_actor, 0);
	SetActorInvulnerable(arena_actor, false);
	SetActorHealth(arena_actor, 1000);

	Create3DTextLabel("{EE5133}Shoot me to go to{33C4EE}\n{33C4EE}Team Deathmatch", -1, GANGWAR_NPC_POS, 40.0, 0);
	gangwars_actor = CreateActor(106, GANGWAR_NPC_POS, 226.3410);
	SetActorVirtualWorld(gangwars_actor, 0);
	SetActorInvulnerable(gangwars_actor, false);
	SetActorHealth(gangwars_actor, 1000);
	ApplyActorAnimation(gangwars_actor, "DANCING", "dnce_M_a", 4.1, 1, 1, 1, 1, 0); // Pay anim

	Create3DTextLabel("{EE5133}Shoot me to join the{33C4EE}\nCop Chase", -1, COPCHASE_NPC_POS, 40.0, 0);
	copchase_actor =  CreateActor(265, COPCHASE_NPC_POS, 44.1017);
	SetActorVirtualWorld(copchase_actor, 0);
	SetActorInvulnerable(copchase_actor, false);
	SetActorHealth(copchase_actor, 1000);

	latestdonator_actor = CreateActor(1, DONATOR_NPC_POS, 180.0);
	SetActorVirtualWorld(latestdonator_actor, 0);
	SetActorInvulnerable(latestdonator_actor, false);
	SetActorHealth(latestdonator_actor, 1000);

	monthlydm_actor = CreateActor(1, MONTHDM_NPC_POS, 90.0);
	SetActorInvulnerable(monthlydm_actor, false);
	SetActorHealth(monthlydm_actor, 1000);

	playerinfo = Create3DTextLabel("{EE5133}Arena Players: X{33C4EE}\n{EE5133}TDM Players: X{33C4EE}\n{EE5133}Cop Chase Players: X{33C4EE}\n{EE5133}Freeroam Players: X{33C4EE}\n", -1, 2518.6104, 603.0276, 35.8195, 40.0, 0);
}
ResetLobbyActorPositions()
{
	SetActorHealth(arena_actor, 1000);
	SetActorInvulnerable(arena_actor, false);
	SetActorPos(arena_actor, ARENA_NPC_POS);
	SetActorVirtualWorld(arena_actor, 0);

	SetActorHealth(copchase_actor, 1000);
	SetActorInvulnerable(copchase_actor, false);
	SetActorPos(copchase_actor, COPCHASE_NPC_POS);
	SetActorVirtualWorld(copchase_actor, 0);

	SetActorHealth(freeroam_actor, 1000);
	SetActorInvulnerable(freeroam_actor, false);
	SetActorPos(freeroam_actor, FREEROAM_NPC_POS);
	SetActorVirtualWorld(freeroam_actor, 0);

	SetActorHealth(gangwars_actor, 1000);
	SetActorInvulnerable(gangwars_actor, false);
	SetActorPos(gangwars_actor, GANGWAR_NPC_POS);
	SetActorVirtualWorld(gangwars_actor, 0);
	return true;
}
HandleLobbyTransition(playerid)
{
	switch(ActivityState[playerid])
	{
		case ACTIVITY_ARENADM: UpdateArena(playerid);
		case ACTIVITY_COPCHASE:
		{
			if(Account[playerid][pCopchase] == 2){
				new msg[128];
				format(msg, sizeof(msg), "%s has left. [%d players remaining]", GetName(playerid), GetCopchaseTotalPlayers() - 1);
				SendCopchaseMessage(msg);
				Account[playerid][pCopchase] = 0;
				PlayerTextDrawHide(playerid, Account[playerid][TextDraw][1]);
				PlayerTextDrawHide(playerid, Account[playerid][TextDraw][0]);
				PlayerTextDrawHide(playerid, Account[playerid][TextDraw][2]);
				PlayerTextDrawHide(playerid, Account[playerid][TextDraw][3]);
				TogglePlayerControllable(playerid, 1);
				StartCopchase(); // checking if game is over
			}
			else if(Account[playerid][pCopchase] == 3)
			{
				Account[playerid][pCopchase] = 0;
				PlayerTextDrawHide(playerid, Account[playerid][TextDraw][1]);
				PlayerTextDrawHide(playerid, Account[playerid][TextDraw][0]);
				PlayerTextDrawHide(playerid, Account[playerid][TextDraw][2]);
				PlayerTextDrawHide(playerid, Account[playerid][TextDraw][3]);
				TogglePlayerControllable(playerid, 1);
				StartCopchase(); // terminating it
			}
			else if(Account[playerid][pCopchase] == 1){
				new msg[128];
				Account[playerid][pCopchase] = 0;
				format(msg, sizeof(msg), "{%06x}%s{FFFFFF} has left. [%d players in queue]", GetPlayerColor(playerid) >>> 8, GetName(playerid), GetCopchaseTotalPlayers() - 1);
				SendCopchaseMessage(msg);

				PlayerTextDrawHide(playerid, Account[playerid][TextDraw][1]);
				PlayerTextDrawHide(playerid, Account[playerid][TextDraw][0]);
				PlayerTextDrawHide(playerid, Account[playerid][TextDraw][2]);
				PlayerTextDrawHide(playerid, Account[playerid][TextDraw][3]);
			}

			foreach(new p : Player)
			{
				SetPlayerMarkerForPlayer(playerid, p, GetPlayerColor(p) | 0x000000FF);
			}
		}
		case ACTIVITY_EVENT: ExitEvent(playerid);
		case ACTIVITY_DUEL:
		{
			if(DuelInvite[playerid] != -1) EmulateCommand(playerid, "/duel deny");
			else if(ActivityState[playerid] == ACTIVITY_DUEL) EndDuel(playerid, true);
		}
		case ACTIVITY_TDM:
		{
			if(GetPlayerTeam(playerid) < 100)
			{
				RemoveFromTDM(playerid, ActivityStateID[playerid]);
			}
			if(GetPlayerTeam(playerid) > 100)
			{
				SetPlayerTeam(playerid, NO_TEAM);
				GangZoneHideForPlayer(playerid, igsturf);
				DisablePlayerCheckpoint(playerid);
				cancapture[playerid] = 0;
				RemovePlayerMapIcon(playerid, 1);
				SendPlayerToLobby(playerid);
				Account[playerid][CopChaseDead] = 0;
				inAmmunation[playerid] = 0;
			}
		}
	}

	Account[playerid][KillStreak] = 0;
	Account[playerid][FreeroamVW] = 0;
	Account[playerid][TDMTeam] = 0;
	Account[playerid][PreventDamage] = 0;
	Account[playerid][FreeroamVW] = 0;
	Account[playerid][LobbyPermission] = 0;
	Account[playerid][CopChaseDead] = 0;
	Account[playerid][KillStreak] = 0;
	SetPlayerTeam(playerid, 255);
	DisablePlayerCheckpoint(playerid);
	InfoBoxForPlayer(playerid, "~w~Sending you to spawn, please wait.....");
	if(ActivityState[playerid] != ACTIVITY_LOBBY || inServerHub[playerid] == 1) SendPlayerToLobby(playerid);
	ResetPlayerWeaponsEx(playerid);
	GivePlayerWeapon(playerid, Account[playerid][LobbyWeapon], 9999);
	return true;
}
SendPlayerToLobby(playerid)
{
	if(Account[playerid][ForumID] == 0 || Account[playerid][ForumID] < 1)
	{
		SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Notice: {FFFFFF}You have not yet set your Forum account. Please use /forum and input the correct Forum name.");
	}
	DestroyAllPlayerObjects(playerid);
	CreateLobby(playerid);
	ShowSessionStats(playerid);
	ShowNetworkTDs(playerid);

	ActivityState[playerid] = ACTIVITY_LOBBY;
	ActivityStateID[playerid] = -1;
	Account[playerid][LoggedIn] = 1;
	inServerHub[playerid] = 0;

	SetPlayerColor(playerid,  PlayerColors[playerid % sizeof PlayerColors]);
	SetPlayerScore(playerid, Account[playerid][Kills]);
	SetPlayerMoneyEx(playerid, (Account[playerid][Cash]));
	SetPlayerSkinEx(playerid, Account[playerid][Skin]);

	TogglePlayerControllable(playerid, 1);
	SetPlayerPosEx(playerid, 2518.3625, 603.0128, 35.8195, 1, 0);

	ResetPlayerWeaponsEx(playerid);
	GivePlayerWeapon(playerid, Account[playerid][LobbyWeapon], 500);
	SetPlayerHealth(playerid, 9999);
	SetPlayerArmour(playerid, 0);

	AdminJailCheck(playerid);
	
	UpdateKeyText(playerid);
	DisablePlayerCheckpoint(playerid);
	return true;
}
IsPlayerInLobby(playerid)
{
	if(ActivityState[playerid] == ACTIVITY_LOBBY) return true;
	return false;
}

forward OnPlayerDamageLobbyActor(playerid, damaged_actorid, Float:amount, weaponid, bodypart);
public OnPlayerDamageLobbyActor(playerid, damaged_actorid, Float:amount, weaponid, bodypart)
{
	if(Account[playerid][AJailTime] <= 0)
	{
		if(damaged_actorid == freeroam_actor)
		{
			SetPlayerPosEx(playerid, 4787.6133, 1276.0731, 2.0049, 0, 1);
			InfoBoxForPlayer(playerid, "Welcome to freeroam, use /freeroamhelp for more information.");
			ResetLobbyActorPositions();
			cmd_freeroam(9999, playerid);
			ApplyActorAnimation(freeroam_actor, "DANCING", "dnce_M_a", 4.1, 1, 1, 1, 1, 0); // Pay anim
		}
		if(damaged_actorid == arena_actor)
		{
			ShowArenaDialog(playerid);
			ResetLobbyActorPositions();
		}

		if(damaged_actorid == copchase_actor)
		{
			cmd_copchase(9999, playerid);
			ResetLobbyActorPositions();
		}
		if(damaged_actorid == gangwars_actor)
		{
			ResetLobbyActorPositions();
			ShowTeamSelectionDialog(playerid);
		}
		if(damaged_actorid == monthlydm_actor)
		{
			SetActorPos(monthlydm_actor, MONTHDM_NPC_POS);
			SetActorVirtualWorld(monthlydm_actor, 0);
			SetActorInvulnerable(monthlydm_actor, false);
			SetActorHealth(monthlydm_actor, 1000);
			ApplyActorAnimation(monthlydm_actor, "GHANDS", "gsign3", 4.1, 1, 1, 1, 1, 0);
			SendClientMessage(playerid, -1, "{31AEAA}Notice: {FFFFFF}This is the Monthly Deathmatcher! It updates every 10 minutes, winner gets Diamond VIP!");
		}
		if(damaged_actorid == latestdonator_actor)
		{
			SetActorPos(latestdonator_actor, DONATOR_NPC_POS);
			SetActorVirtualWorld(latestdonator_actor, 0);
			SetActorInvulnerable(latestdonator_actor, false);
			SetActorHealth(latestdonator_actor, 1000);
			ApplyActorAnimation(latestdonator_actor, "GHANDS", "gsign3", 4.1, 1, 1, 1, 1, 0);
			SendClientMessage(playerid, -1, "{31AEAA}Notice: {FFFFFF}Donate to the server for rewards via www.kokysdm.com/donate!");
		}
	}
}