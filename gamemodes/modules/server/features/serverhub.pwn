new kdmstaffskin;
new guccisnake;
new irishpolice;
new nillyskin;
new shotskin[MAX_PLAYERS];

new serverhubnpc = INVALID_ACTOR_ID;

ServerHubKeyText()
{
	Create3DTextLabel("{EE5133}Shoot me to go to{33C4EE}\nThe Server Hub", -1, 2518.4958 ,591.0577, 35.7459, 40.0, 0);
}
InitServerHub()
{
	kdmstaffskin = CreateActor(20067, 1721.8754, -1656.4478, 20.9688, 178.8593);
	guccisnake = CreateActor(20120, 1721.7507, -1654.7797, 20.9688, 0.4655);
	irishpolice = CreateActor(20121, 1722.6783, -1655.7043, 20.9741, 270.2162);
	nillyskin = CreateActor(20122, 1727.6315, -1668.0815, 22.6094, 41.4650);
	serverhubnpc = CreateActor(20067, 2518.4958 ,591.0577, 35.7459, 358.4071);

	SetActorInvulnerable(kdmstaffskin, false);
	SetActorHealth(kdmstaffskin, 1000);
	SetActorInvulnerable(guccisnake, false);
	SetActorHealth(guccisnake, 1000);
	SetActorInvulnerable(irishpolice, false);
	SetActorHealth(irishpolice, 1000);
	SetActorInvulnerable(nillyskin, false);
	SetActorHealth(nillyskin, 1000);
	SetActorInvulnerable(serverhubnpc, false);
	SetActorHealth(serverhubnpc, 1000);
	ApplyActorAnimation(nillyskin, "DANCING", "dnce_M_a", 4.1, 1, 1, 1, 1, 0); // Pay anim
	Create3DTextLabel("{EE5133}Welcome to the server hub!{33C4EE}\nShoot the actors to buy the skins!", -1, 1710.8682, -1667.3304, 20.2261, 25.0, 0);
	ServerHubKeyText();
	return true;
}
ReloadRareSkins()
{
	DestroyActor(kdmstaffskin);
	DestroyActor(guccisnake);
	DestroyActor(irishpolice);
	DestroyActor(nillyskin);

	kdmstaffskin = CreateActor(20067, 1721.8754, -1656.4478, 20.9688, 178.8593);
	guccisnake = CreateActor(20120, 1721.7507, -1654.7797, 20.9688, 0.4655);
	irishpolice = CreateActor(20121, 1722.6783, -1655.7043, 20.9741, 270.2162);
	nillyskin = CreateActor(20122, 1727.6315, -1668.0815, 22.6094, 41.4650);

	SetActorInvulnerable(kdmstaffskin, false);
	SetActorHealth(kdmstaffskin, 1000);
	SetActorInvulnerable(guccisnake, false);
	SetActorHealth(guccisnake, 1000);
	SetActorInvulnerable(irishpolice, false);
	SetActorHealth(irishpolice, 1000);
	SetActorInvulnerable(nillyskin, false);
	SetActorHealth(nillyskin, 1000);

	ApplyActorAnimation(kdmstaffskin, "DANCING", "dnce_M_a", 4.1, 1, 1, 1, 1, 0); // Pay anim
	ApplyActorAnimation(guccisnake, "DANCING", "dnce_M_a", 4.1, 1, 1, 1, 1, 0); // Pay anim
	ApplyActorAnimation(irishpolice, "DANCING", "dnce_M_a", 4.1, 1, 1, 1, 1, 0); // Pay anim
	ApplyActorAnimation(nillyskin, "DANCING", "dnce_M_a", 4.1, 1, 1, 1, 1, 0); // Pay anim
}
forward OnPlayerDamageServerHubActor(playerid, damaged_actorid, Float:amount, weaponid, bodypart);
public OnPlayerDamageServerHubActor(playerid, damaged_actorid, Float:amount, weaponid, bodypart)
{
	if(inServerHub[playerid] == 1)
	{	
		if(damaged_actorid == kdmstaffskin)
		{
			shotskin[playerid] = 1;
			SetActorPos(kdmstaffskin, 1721.8754, -1656.4478, 20.9688);
			Dialog_Show(playerid, BUYRARESKIN, DIALOG_STYLE_MSGBOX, "Purchase Rare Skin", "{FFFFFF}Skin: {ff8d00}KDM Staff Skin\n{FFFFFF}Price: {ff8d00}10 KDM Tokens\n{FFFFFF}Cash Value: ({ff8d00}$50,000,000 value!{FFFFFF})", "Purchase", "Cancel");
		}
		if(damaged_actorid == guccisnake)
		{
			shotskin[playerid] = 3;
			SetActorPos(guccisnake, 1721.7507, -1654.7797, 20.9688);
			Dialog_Show(playerid, BUYRARESKIN, DIALOG_STYLE_MSGBOX, "Purchase Rare Skin", "{FFFFFF}Skin: {ff8d00}Gucci Snake Skin\n{FFFFFF}Price: {ff8d00}5 KDM Tokens\n{FFFFFF}Cash Value: ({ff8d00}$25,000,000 value!{FFFFFF})", "Purchase", "Cancel");
		}
		if(damaged_actorid == irishpolice)
		{
			shotskin[playerid] = 4;
			SetActorPos(irishpolice, 1722.6783, -1655.7043, 20.9741);
			Dialog_Show(playerid, BUYRARESKIN, DIALOG_STYLE_MSGBOX, "Purchase Rare Skin", "{FFFFFF}kin: {ff8d00}Irish Police Skin\n{FFFFFF}Price: {ff8d00}2 KDM Tokens\n{FFFFFF}Cash Value: ({ff8d00}$10,000,000 value!{FFFFFF})", "Purchase", "Cancel");
		}
		if(damaged_actorid == nillyskin)
		{
			shotskin[playerid] = 5;
			SetActorPos(nillyskin,  1727.6315, -1668.0815, 22.6094);
			Dialog_Show(playerid, BUYRARESKIN, DIALOG_STYLE_MSGBOX, "Purchase Rare SKin", "{FFFFFF}Skin: {ff8d00}Nilly Skin\n{FFFFFF}Price: {ff8d00}1 KDM Tokens\n{FFFFFF}Cash Value: ({ff8d00}$5,000,000 value!{FFFFFF})", "Purchase", "Cancel");
		}
	}
	if(damaged_actorid == serverhubnpc)
	{
		cmd_serverhub(9999, playerid);
	}
	return false;
}
Dialog:BUYRARESKIN(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		if(shotskin[playerid] == 1)
		{
			if(Account[playerid][Tokens] >= 10)
			{
				Account[playerid][Tokens] = Account[playerid][Tokens] - 10;
				SendClientMessageToAll(COLOR_LIGHTRED, sprintf("Server Hub: {%06x}%s {FFFFFF}has just purchase the KDM Staff Skin for 10 KDM Tokens! ($50,000,000 Value!)", GetPlayerColor(playerid) >>> 8, GetName(playerid)));
				Account[playerid][hasKDMStaffSkin] = 1;
				Account[playerid][RareSkins]++;
			}
			else return SendClientMessage(playerid, -1, "{31AEAA}Server Hub: {FFFFFF}You don't have enough tokens to buy this item! Refer to /tokenhelp.");
		}
		if(shotskin[playerid] == 3)
		{
			if(Account[playerid][Tokens] >= 5)
			{
				Account[playerid][Tokens] = Account[playerid][Tokens] - 5;
				SendClientMessageToAll(COLOR_LIGHTRED, sprintf("Server Hub: {%06x}%s {FFFFFF}has just purchase the Gucci Snake Skin for 5 KDM Tokens! ($25,000,000 Value!)", GetPlayerColor(playerid) >>> 8, GetName(playerid)));
				Account[playerid][hasGucciSnakeSkin] = 1;
				Account[playerid][RareSkins]++;
			}
			else return SendClientMessage(playerid, -1, "{31AEAA}Server Hub: {FFFFFF}You don't have enough tokens to buy this item! Refer to /tokenhelp.");
		}
		if(shotskin[playerid] == 4)
		{
			if(Account[playerid][Tokens] >= 2)
			{
				Account[playerid][Tokens] = Account[playerid][Tokens] - 2;
				SendClientMessageToAll(COLOR_LIGHTRED, sprintf("Server Hub: {%06x}%s {FFFFFF}has just purchase the Irish Police Skin for 2 KDM Tokens! ($10,000,000 Value!)", GetPlayerColor(playerid) >>> 8, GetName(playerid)));
				Account[playerid][hasIrishPoliceSkin] = 1;
				Account[playerid][RareSkins]++;
			}
			else return SendClientMessage(playerid, -1, "{31AEAA}Server Hub: {FFFFFF}You don't have enough tokens to buy this item! Refer to /tokenhelp.");
		}
		if(shotskin[playerid] == 5)
		{
			if(Account[playerid][Tokens] >= 1)
			{
				Account[playerid][Tokens] = Account[playerid][Tokens] - 1;
				SendClientMessageToAll(COLOR_LIGHTRED, sprintf("Server Hub: {%06x}%s {FFFFFF}has just purchase the Nilly Skin for 1 KDM Tokens! ($5,000,000 Value!)", GetPlayerColor(playerid) >>> 8, GetName(playerid)));
				Account[playerid][hasNillySkin] = 1;
				Account[playerid][RareSkins]++;
			}
			else return SendClientMessage(playerid, -1, "{31AEAA}Server Hub: {FFFFFF}You don't have enough tokens to buy this item! Refer to /tokenhelp.");
		}
		return 1;
	}
	return 0;
}
CMD:rareitems(cmdid, playerid, params[])
{
	Dialog_Show(playerid, RAREDIALOG, DIALOG_STYLE_LIST, "Rare Items", sprintf("Rare Skins:\t%i\nRare Items:\t%i", Account[playerid][RareSkins], Account[playerid][RareItems]), "Select", "Cancel");
	return true;
}
Dialog:RAREDIALOG(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		if(listitem == 0)
		{
			Dialog_Show(playerid, RARESKINS, DIALOG_STYLE_LIST, "Rare Skins", "KDM Staff Skin\nArcher Skin\nGucci Snake Skin\nIrish Police Skins\nNilly Skin", "Select", "Cancel");
		}
		if(listitem == 1)
		{
			Dialog_Show(playerid, RAREITEMS, DIALOG_STYLE_LIST, "Rare Items", "NO\nRARE\nITEMS\nFOUND", "Okay", "Okay");
		}
		return 1;
	}
	return 0;
}
Dialog:RARESKINS(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		if(listitem == 0)
		{
			if(Account[playerid][hasKDMStaffSkin] == 1)
			{
				SetPlayerSkinEx(playerid, 20067);
			}
			else return SendClientMessage(playerid, -1, "{31AEAA}Rare Skins: You have not unlocked this skin yet. You can purchase it using /tokenhelp.");
		}
		if(listitem == 1)
		{
			if(Account[playerid][hasArcherSkin] == 1)
			{
				SetPlayerSkinEx(playerid, 20119);
			}
			else return SendClientMessage(playerid, -1, "{31AEAA}Rare Skins: You have not unlocked this skin yet. You can purchase it using /tokenhelp.");

		}
		if(listitem == 2)
		{
			if(Account[playerid][hasGucciSnakeSkin] == 1)
			{
				SetPlayerSkinEx(playerid, 20120);
			}
			else return SendClientMessage(playerid, -1, "{31AEAA}Rare Skins: You have not unlocked this skin yet. You can purchase it using /tokenhelp.");
		}
		if(listitem == 3)
		{
			if(Account[playerid][hasIrishPoliceSkin] == 1)
			{
				SetPlayerSkinEx(playerid, 20121);
			}
			else return SendClientMessage(playerid, -1, "{31AEAA}Rare Skins: You have not unlocked this skin yet. You can purchase it using /tokenhelp.");
		}
		if(listitem == 4)
		{
			if(Account[playerid][hasNillySkin] == 1)
			{
				SetPlayerSkinEx(playerid, 20122);
			}
			else return SendClientMessage(playerid, -1, "{31AEAA}Rare Skins: You have not unlocked this skin yet. You can purchase it using /tokenhelp.");
		}
		return 1;
	}
	return 0;
}
