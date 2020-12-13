RegisterCallbackHooks()
{
	//cbug detection
	//pawn_register_callback("OnPlayerKeyStateChange", "ACOnPlayerKeyStateChange");
	//pawn_register_callback("OnPlayerUpdate", "ACOnPlayerUpdate");

	//csliding detection
	pawn_register_callback("OnPlayerConnect", "OnSlidePlayerConnect");
	pawn_register_callback("OnPlayerUpdate", "OnPlayerCSlide");

	//nostun detection
	pawn_register_callback("OnPlayerUpdate", "OnFlinchUpdate");

	//deathmatch arenas
	pawn_register_callback("OnPlayerDisconnect", "OnArenaPlayerDisconnect");

	//duel arenas
	pawn_register_callback("OnPlayerConnect", "OnDuelPlayerConnect");
	pawn_register_callback("OnPlayerDisconnect", "OnDuelPlayerDisconnect");
	pawn_register_callback("OnDialogResponse", "OnDuelDialogResponse");

	//TDM
	pawn_register_callback("OnPlayerDisconnect", "OnTDMPlayerDisconnect");
	pawn_register_callback("OnPlayerKeyStateChange", "OnTDMPlayerKeyStateChange");
	pawn_register_callback("OnPlayerEnterCheckpoint", "OnPlayerEnterTDMCheckpoint");
	pawn_register_callback("OnPlayerUpdate", "OnTDMPlayerUpdate");
	pawn_register_callback("OnPlayerEnterVehicle", "OnPlayerEnterTDMVehicle");

	//copchase
	pawn_register_callback("OnPlayerDisconnect", "OnCCPlayerDisconnect");
	pawn_register_callback("OnPlayerKeyStateChange", "OnCCPlayerKeyStateChange");
	//pawn_register_callback("SecondCheck", "CCSecondCheck");

	//freeroam
	pawn_register_callback("OnPlayerConnect", "OnFreeroamPlayerConnect");
	pawn_register_callback("OnPlayerDisconnect", "OnFreeroamPlayerDisconnect");
	pawn_register_callback("OnPlayerKeyStateChange", "OnFreeroamPlayerKeyStateChange");

	//events
	pawn_register_callback("OnPlayerDisconnect", "OnEventPlayerDisconnect");

	//server hub
	pawn_register_callback("OnPlayerGiveDamageActor", "OnPlayerDamageServerHubActor");

	//lobby
	pawn_register_callback("OnPlayerGiveDamageActor", "OnPlayerDamageLobbyActor");

	//reports
	pawn_register_callback("OnPlayerDisconnect", "OnReportedPlayerDisconnect");

	//spectating
	pawn_register_callback("OnPlayerDeathFinished", "OnSpectateDeathFinished");
	pawn_register_callback("OnPlayerDisconnect", "OnSpectatePlayerDisconnect");
	pawn_register_callback("OnPlayerStateChange", "OnSpectatePlayerStateChange");
	pawn_register_callback("OnPlayerUpdate", "OnSpectatePlayerUpdate");
}