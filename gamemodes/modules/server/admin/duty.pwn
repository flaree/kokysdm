// admin duty
#include <pp-hooks>

hook public OnPlayerConnect(playerid)
{
	adminDuty[playerid] = false;
}

CMD<AD1>:aduty(cmdid, playerid, params[])
{
	adminDuty[playerid] = !adminDuty[playerid];
	if(Account[playerid][pAdminHide]) ToggleAdminHidden(playerid);

	new szString[144];
	format(szString, 144, "{FF0000}%s{FFFFFF} is %s on duty.", GetName(playerid), adminDuty[playerid] ? "now" : "no longer");
	SendClientMessageToAll(COLOR_RED, szString);

	if(adminDuty[playerid]) {
		TextDrawShowForPlayer(playerid, DutyTextDraw);
		SetPlayerColor(playerid, 0xFF000000);
	}
	else {
		TextDrawHideForPlayer(playerid, DutyTextDraw);
		SetPlayerColor(playerid, Account[playerid][Color]);
	}
	return 1;
}