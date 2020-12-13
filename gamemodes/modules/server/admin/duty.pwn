// admin duty
#include <pp-hooks>

new bool: adminDuty[MAX_PLAYERS];

hook public OnPlayerConnect(playerid)
{
	adminDuty[playerid] = false;
}

CMD<AD1>:aduty(cmdid, playerid, params[])
{
	adminDuty[playerid] = !adminDuty[playerid];

	SendAdminsMessage(1, COLOR_GRAY, sprintf("Admin %s is currently %s duty.", GetName(playerid), adminDuty[playerid] ? "ON" : "OFF"));
	SendClientMessage(playerid, -1, sprintf("{31AEAA}Notice: {FFFFFF}You are now %s duty.", adminDuty[playerid] ? "ON" : "OFF"));
	return 1;
}