//data
static SpectatingPlayer[MAX_PLAYERS] = {-1, ...};
static pSpecLimit[MAX_PLAYERS];

//hooks
#include <pp-hooks>
hook public OnPlayerDeathFinished(playerid)
{
	foreach(new i: Player)
	{
		if(SpectatingPlayer[i] == playerid)
		{
			if(IsPlayerInAnyVehicle(playerid)) PlayerSpectateVehicle(i, GetPlayerVehicleID(playerid));
			else PlayerSpectatePlayer(i, playerid);
		}
	}
}

hook public OnPlayerDisconnect(playerid, reason)
{
	SpectatingPlayer[playerid] = -1;
	pSpecLimit[playerid] = 0;

	foreach(new i: Player)
	{
		if(SpectatingPlayer[i] == playerid)
		{
			SendClientMessage(i, -1, sprintf("{31AEAA}Spectating: {FFFFFF}%s (%i) has disconnected, sending you to lobby.", GetName(playerid), playerid));
			StopSpectating(i);
		}
	}
}

hook public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_ONFOOT)
	{
		foreach(new i: Player)
		{
			if(SpectatingPlayer[i] == playerid)
			{
				PlayerSpectatePlayer(i, playerid);
			}
		}
	}
	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	{
		new v = GetPlayerVehicleSeat(playerid);
		foreach(new i: Player)
		{
			if(SpectatingPlayer[i] == playerid)
			{
				PlayerSpectateVehicle(playerid, v);
			}
		}
	}
}

hook public OnPlayerUpdate(playerid)
{
	//scroll spectate system, lets players press their arrow keys to switch between players
	new keys, updown, leftright;
	GetPlayerKeys(playerid, keys, updown, leftright);
	if(SpectatingPlayer[playerid] != -1 && Account[playerid][Admin] != 0)
	{
		if(keys & KEY_SPRINT)
		{
			PlayerSpectatePlayer(playerid, SpectatingPlayer[playerid]);
			if(ActivityState[SpectatingPlayer[playerid]] == ACTIVITY_TDM)
			{
				CreateTDMMapping(playerid);
			}
		}


		//SendClientMessageToAll(COLOR_RED, sprintf("updown: %d leftright: %d", updown, leftright));
		if(leftright != 0)
		{
			if(GetTickCount()-pSpecLimit[playerid] > 666 || GetTickCount()-pSpecLimit[playerid] < 0)
			{
				pSpecLimit[playerid] = GetTickCount();
				new i = SpectatingPlayer[playerid];
				if(leftright == KEY_RIGHT) // Next
				{
					i++;
					if(i == MAX_PLAYERS) i = 0;
					while(!IsPlayerConnected(i) || SpectatingPlayer[i] != -1)
					{
						i++;
						if(i == MAX_PLAYERS) i = 0;
					}
				}
				else if(leftright == KEY_LEFT) // Prev
				{
					i--;
					if(i == -1) i = MAX_PLAYERS-1;
					while(!IsPlayerConnected(i) || SpectatingPlayer[i] != -1)
					{
						i--;
						if(i == -1) i = MAX_PLAYERS-1;
					}
				}
				SendClientMessage(playerid, -1, sprintf("{31AEAA}Spectating: {FFFFFF}You are now spectating %s(%i). Player Mode: %s. Press SPRINT key to sync.", GetName(i), i, ReturnActivityDescription(i)));
				SpectatePlayer(playerid, i);

				if(ActivityState[i] == ACTIVITY_TDM)
				{
					CreateTDMMapping(playerid);
				}
			}
		}
		else pSpecLimit[playerid] = 0; // If not holding, reset limit to allow tapping
	}
}

//commands
CMD<AD1>:spec(cmdid, playerid, params[])
{
	new target;
	if(sscanf( params, "u", target)) return SendClientMessage( playerid, -1, "USAGE: /spec(tate) [ID]");
	if(target == playerid) return SendClientMessage( playerid, -1, "{31AEAA}Spectating: {FFFFFF}You cannot spectate yourself.");
	if(target == INVALID_PLAYER_ID) return SendClientMessage( playerid, -1, "{31AEAA}Spectating: {FFFFFF}Player not found.");
	if(GetPlayerState(target) == PLAYER_STATE_WASTED) return SendClientMessage( playerid, -1, "{31AEAA}Spectating: {FFFFFF}Player is respawning.");
	if(!IsPlayerInLobby(playerid)) return SendClientMessage( playerid, -1, "{31AEAA}Spectating: {FFFFFF}You must be in the lobby to use this command. This prevents wrong number of players in modes! Sorry baby.");

	if(ActivityState[target] == ACTIVITY_TDM)
	{
		CreateTDMMapping(playerid);
	}

	SpectatePlayer(playerid, target);
	SendClientMessage(playerid, -1, sprintf("{1E90FF}(Spectate):{dadada} You are now spectating %s(%i). Player Mode: %s. Press SPRINT key to sync.", GetName(target), target, ReturnActivityDescription(target)));
	return true;
}

CMD<AD1>:specoff(cmdid, playerid, params[])
{
	if(SpectatingPlayer[playerid] == -1) return SendClientMessage( playerid, -1, "{31AEAA}Spectating: {FFFFFF}You are not spectating anyone.");
	DestroyAllPlayerObjects(playerid);
	SendClientMessage(playerid, -1, sprintf("{31AEAA}Spectating: {FFFFFF}You are no longer spectating %s(%i).", GetName(SpectatingPlayer[playerid]), SpectatingPlayer[playerid]));
	StopSpectating(playerid);
	return true;
}

//functions
SpectatePlayer(playerid, target)
{
	SpectatingPlayer[playerid] = target;
	TogglePlayerSpectating(playerid, true);
	SetPlayerInterior(playerid, GetPlayerInterior(target));
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(target));
	if(ActivityState[target] == ACTIVITY_ARENADM)
	{
		new arena = ActivityStateID[target];
		if(arena <= MAX_ARENAS)
		{
			if(strlen(ArenaInfo[arena][ArenaMapCallback])) CallLocalFunction(ArenaInfo[arena][ArenaMapCallback], "i", playerid);
		}
	}

	SetTimerEx("DelayedSpectate", 200, false, "ii", playerid, target);
	return true;
}

StopSpectating(playerid)
{
	SpectatingPlayer[playerid] = -1;
	TogglePlayerSpectating(playerid, false);
	SendPlayerToLobby(playerid);
	return true;
}

forward DelayedSpectate(playerid, target);
public DelayedSpectate(playerid, target)
{
	if(IsPlayerInAnyVehicle(target)) PlayerSpectateVehicle(playerid, GetPlayerVehicleID(target));
	else PlayerSpectatePlayer(playerid, target);
}