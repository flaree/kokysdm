/*                                                           __
											/\ \/\ \        /\ \
											\ \ \/'/'    ___\ \ \/'\   __  __
											 \ \ , <    / __`\ \ , <  /\ \/\ \
											  \ \ \\`\ /\ \_\ \ \ \\`\\ \ \_\ \
											   \ \_\ \_\ \____/\ \_\ \_\/`____ \
												\/_/\/_/\/___/  \/_/\/_/`/___/> \
																		   /\___/
																		   \/__/
														*Developed by Koky*

==============================================================================================================
Update K:DM 0.43
Memorial Developers -> Koky ~ TommyB ~ J0sh ES ~ Graber
Developers -> SimoSbara ~ Davis ~ rivera ~ Bauer ~ josef 
Losers -> BanksDM - LSDM - CarnageTDM!

*/
#include <a_samp>
#include "/modules/server/defines.pwn"
#include <fixes>
#include <SKY>
#include <BustAim>

#define WC_CUSTOM_VENDING_MACHINES false
#include <weapon-config>

#include <lookup>
#include <gmenu>
#include <a_mysql>
#include <sscanf2>
#include <easyDialog>
#include <strlib>
#include <zmessage>
#include <zvehcomp>
#include <desync-checker>
#include <bcrypt>
#include <smartcmd>
#include <foreach>
#include <float>
#include <mselect>

//pawnplus stuff
#define PP_SYNTAX
#include <PawnPlus>

#include <async-dialogs>

#define MYSQL_ASYNC_DEFAULT_PARALLEL true
#include <pp-mysql>

//#include <mSelection>

new formatString[256];

#define SendFormatMessage(%0,%1,%2,%3) format(formatString, sizeof(formatString),%2,%3) && SendClientMessage(%0, %1, formatString)

new countdowntime[MAX_PLAYERS];
new countdowntimer[MAX_PLAYERS];
new dmessage[MAX_PLAYERS];
new inServerHub[MAX_PLAYERS];
new PauseTick[MAX_PLAYERS];
new pDrunkLevelLast[MAX_PLAYERS];
new pFPS[MAX_PLAYERS];
new TimesHit[MAX_PLAYERS];
new List:DialogOptions[MAX_PLAYERS];
new HitmarkerTimer[MAX_PLAYERS];
new PlayerSecondTimer[MAX_PLAYERS];

//antispam stuff
new MessageAmount[MAX_PLAYERS]; //how many chat messages a player has sent, decrements by 2 every second
new LastMessage[MAX_PLAYERS][180 char]; //the last chat message a player sent

new PlayerColors[200] = {
	0xFF8C13FF, 0xC715FFFF, 0x20B2AAFF, 0xDC143CFF, 0x6495EDFF, 0xf0e68cFF, 0x778899FF, 0xFF1493FF, 0xF4A460FF, 
	0xEE82EEFF, 0xFFD720FF, 0x8b4513FF, 0x4949A0FF, 0x148b8bFF, 0x14ff7fFF, 0x556b2fFF, 0x0FD9FAFF, 0x10DC29FF, 
	0x534081FF, 0x0495CDFF, 0xEF6CE8FF, 0xBD34DAFF, 0x247C1BFF, 0x0C8E5DFF, 0x635B03FF, 0xCB7ED3FF, 0x65ADEBFF, 
	0x5C1ACCFF, 0xF2F853FF, 0x11F891FF, 0x7B39AAFF, 0x53EB10FF, 0x54137DFF, 0x275222FF, 0xF09F5BFF, 0x3D0A4FFF, 
	0x22F767FF, 0xD63034FF, 0x9A6980FF, 0xDFB935FF, 0x3793FAFF, 0x90239DFF, 0xE9AB2FFF, 0xAF2FF3FF, 0x057F94FF, 
	0xB98519FF, 0x388EEAFF, 0x028151FF, 0xA55043FF, 0x0DE018FF, 0x93AB1CFF, 0x95BAF0FF, 0x369976FF, 0x18F71FFF, 
	0x4B8987FF, 0x491B9EFF, 0x829DC7FF, 0xBCE635FF, 0xCEA6DFFF, 0x20D4ADFF, 0x2D74FDFF, 0x3C1C0DFF, 0x12D6D4FF, 
	0x48C000FF, 0x2A51E2FF, 0xE3AC12FF, 0xFC42A8FF, 0x2FC827FF, 0x1A30BFFF, 0xB740C2FF, 0x42ACF5FF, 0x2FD9DEFF, 
	0xFAFB71FF, 0x05D1CDFF, 0xC471BDFF, 0x94436EFF, 0xC1F7ECFF, 0xCE79EEFF, 0xBD1EF2FF, 0x93B7E4FF, 0x3214AAFF, 
	0x184D3BFF, 0xAE4B99FF, 0x7E49D7FF, 0x4C436EFF, 0xFA24CCFF, 0xCE76BEFF, 0xA04E0AFF, 0x9F945CFF, 0xDCDE3DFF, 
	0x10C9C5FF, 0x70524DFF, 0x0BE472FF, 0x8A2CD7FF, 0x6152C2FF, 0xCF72A9FF, 0xE59338FF, 0xEEDC2DFF, 0xD8C762FF, 
	0xD8C762FF, 0xFF8C13FF, 0xC715FFFF, 0x20B2AAFF, 0xDC143CFF, 0x6495EDFF, 0xf0e68cFF, 0x778899FF, 0xFF1493FF, 
	0xF4A460FF, 0xEE82EEFF, 0xFFD720FF, 0x8b4513FF, 0x4949A0FF, 0x148b8bFF, 0x14ff7fFF, 0x556b2fFF, 0x0FD9FAFF, 
	0x10DC29FF, 0x534081FF, 0x0495CDFF, 0xEF6CE8FF, 0xBD34DAFF, 0x247C1BFF, 0x0C8E5DFF, 0x635B03FF, 0xCB7ED3FF, 
	0x65ADEBFF, 0x5C1ACCFF, 0xF2F853FF, 0x11F891FF, 0x7B39AAFF, 0x53EB10FF, 0x54137DFF, 0x275222FF, 0xF09F5BFF, 
	0x3D0A4FFF, 0x22F767FF, 0xD63034FF, 0x9A6980FF, 0xDFB935FF, 0x3793FAFF, 0x90239DFF, 0xE9AB2FFF, 0xAF2FF3FF, 
	0x057F94FF, 0xB98519FF, 0x388EEAFF, 0x028151FF, 0xA55043FF, 0x0DE018FF, 0x93AB1CFF, 0x95BAF0FF, 0x369976FF, 
	0x18F71FFF, 0x4B8987FF, 0x491B9EFF, 0x829DC7FF, 0xBCE635FF, 0xCEA6DFFF, 0x20D4ADFF, 0x2D74FDFF, 0x3C1C0DFF, 
	0x12D6D4FF, 0x48C000FF, 0x2A51E2FF, 0xE3AC12FF, 0xFC42A8FF, 0x2FC827FF, 0x1A30BFFF, 0xB740C2FF, 0x42ACF5FF, 
	0x2FD9DEFF, 0xFAFB71FF, 0x05D1CDFF, 0xC471BDFF, 0x94436EFF, 0xC1F7ECFF, 0xCE79EEFF, 0xBD1EF2FF, 0x93B7E4FF, 
	0x3214AAFF, 0x184D3BFF, 0xAE4B99FF, 0x7E49D7FF, 0x4C436EFF, 0xFA24CCFF, 0xCE76BEFF, 0xA04E0AFF, 0x9F945CFF, 
	0xDCDE3DFF, 0x10C9C5FF, 0x70524DFF, 0x0BE472FF, 0x8A2CD7FF, 0x6152C2FF, 0xCF72A9FF, 0xE59338FF, 0xEEDC2DFF, 
	0xD8C762FF, 0xD8C762FF
};

//hitmarker
new Text:HitMark_centre = Text:INVALID_TEXT_DRAW;
new Text:logintd; 

new bool:ChatLocked = false;

new PlayerText3D:KeyCrates;
new Text3D:playerinfo;
new Text:ChangeColor[66];

new ColorsAvailable[66] = {
	1, 0, 2, 3, 4, 6, 8, 12, 13, 16, 17, 20, 24, 28, 44, 43, 46, 51, 52, 55, 57, 79, 93, 86, 87, 65, 97, 112, 117, 118, 126, 111, 103, 102, 128, 145, 136, 139, 143, 158, 175, 170, 171, 154, 176, 179, 182, 191, 194, 195, 196, 198, 215, 224, 225, 237, 241, 244, 245, 248, 251, 252, 253, 254
};
new AllCarColors[256] = {
	0x000000FF,0xFFFFFFFF,0x55aaa7FF,0xce575bFF,0x58685dFF,0xb06c77FF,0xf8ad38FF,0x7a96acFF,0xdfdec9FF,0x81897aFF,
	0x677776FF,0x93948eFF,0x7e9689FF,0x807c70FF,0xe8eac3FF,0xbab9a5FF,0x73996aFF,0xa54549FF,0xc55063FF,0xd8d5b2FF,
	0x86979eFF,0xa66b67FF,0x8e4556FF,0xcfc3a9FF,0x6c6d65FF,0x5b5a55FF,0xafb295FF,0x77705eFF,0x5a6466FF,0xa89f82FF,
	0x64433aFF,0x73423dFF,0xb5bcb4FF,0xa1a58aFF,0x96947fFF,0x918a6cFF,0x5a5b53FF,0x5b6656FF,0xa8b186FF,0x8d9389FF,
	0x3f3c35FF,0x80765dFF,0x873b3bFF,0x7d3334FF,0x3b5741FF,0x71413dFF,0xaaa176FF,0x89815dFF,0xc2b894FF,0xd6d0b0FF,
	0xa9a98fFF,0x647d67FF,0x849283FF,0x495261FF,0x565b61FF,0x9d846eFF,0xb0af90FF,0xa19273FF,0x7a3138FF,0x5c6c69FF,
	0x9e9c83FF,0x887554FF,0x803c3dFF,0x928f7cFF,0xcfcda7FF,0xd4d27fFF,0x6f534fFF,0xa7ada1FF,0xe1dd9eFF,0xd9b79bFF,
	0xa84645FF,0x96a097FF,0x6f725dFF,0xb6bd93FF,0x764040FF,0x434842FF,0xb0ac89FF,0xb5a778FF,0x8a473fFF,0x375369FF,
	0x9a555aFF,0xaa9c75FF,0xac5359FF,0x56665bFF,0x786151FF,0x995061FF,0x60843cFF,0x72858bFF,0x7c454aFF,0xa7a373FF,
	0xb8b29aFF,0x585e5cFF,0x827f6eFF,0x388a85FF,0x4b6566FF,0x4c5858FF,0xc3c0a1FF,0x97a79aFF,0x80a999FF,0xe1c99dFF,
	0x6e8c8aFF,0x57585cFF,0xd6b98dFF,0x426d80FF,0xa29368FF,0x818274FF,0x3d717fFF,0xb6ab7eFF,0x587482FF,0x696a62FF,
	0x8f7d59FF,0xa3a091FF,0x80948bFF,0x786954FF,0x72866aFF,0xaa4553FF,0x53616aFF,0x8f4f4fFF,0xbfc1b6FF,0x938369FF,
	0xb5a180FF,0x763b41FF,0x747567FF,0x846c50FF,0x914b4dFF,0x38526bFF,0xef87a2FF,0x3c3d38FF,0x6cb85dFF,0x725a4eFF,
	0x78acaaFF,0x987e59FF,0x9b675aFF,0x545d4cFF,0x706c83FF,0x7dc6bdFF,0xcb90c6FF,0x7fca6fFF,0xf7ebc3FF,0x9697abFF,
	0xc3bda3FF,0xbdaf88FF,0xcdbf67FF,0xab8e90FF,0xa28796FF,0xd2ee99FF,0xbd8a93FF,0xaa6a85FF,0x72715cFF,0x665b45FF,
	0x656952FF,0x7e926fFF,0x7398b5FF,0x7da477FF,0x6bcf79FF,0x65c8a9FF,0xe0d59dFF,0xc8c5b4FF,0xde7c5fFF,0x77694cFF,
	0x5d6d49FF,0xd17f74FF,0x6f93b3FF,0x62b79aFF,0x667264FF,0x6aa998FF,0x6daaa5FF,0xaa7faaFF,0x875e4aFF,0xbfb1b0FF,
	0xb4a8acFF,0x987f9dFF,0x686947FF,0x80604bFF,0x8e6c50FF,0xd8685aFF,0xd294a9FF,0xbf9899FF,0xbb839cFF,0x826168FF,
	0xbd825aFF,0xba6254FF,0xd28865FF,0xcf7958FF,0xc88c84FF,0xbba899FF,0x4f5847FF,0x516b48FF,0x6c825bFF,0x677c5bFF,
	0xaa757dFF,0x8dca85FF,0xd4c7a4FF,0xc0bfaaFF,0xdfd249FF,0xbac775FF,0xbdc2a2FF,0xbabb5eFF,0x717caaFF,0x7d7b4aFF,
	0xc1aa74FF,0x536370FF,0x79936cFF,0x606f6cFF,0x798f8dFF,0x515459FF,0x4d585aFF,0x677a76FF,0x7d99a7FF,0x5d7b7dFF,
	0x6f8b8cFF,0x72668aFF,0xac6c53FF,0xd3caadFF,0x98a053FF,0x545945FF,0xcc996eFF,0xa3caafFF,0xd29779FF,0xcc9054FF,
	0xdd888fFF,0xd6c377FF,0xd07151FF,0x596271FF,0x936556FF,0x89864fFF,0x9cd665FF,0x5a765dFF,0xd0b858FF,0x66b758FF,
	0x83605aFF,0xb79153FF,0xc37d9fFF,0xbf6791FF,0x5b7f51FF,0x71894fFF,0x5d7166FF,0xc3919dFF,0xcca470FF,0xaf6c52FF,
	0x77c4a4FF,0x99c556FF,0x9b616fFF,0x63bd63FF,0x7c5d49FF,0x57694fFF,0x809ea8FF,0x748080FF,0x935d5bFF,0x90575eFF,
	0xaaa184FF,0x7d7e70FF,0x716d62FF,0xc9c3a3FF,0x9b907aFF,0x838786FF
};

#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

#define HOLDING(%0) \
	((newkeys & (%0)) == (%0))
#define COLOR_LIGHTRED 0xFF6347AA
// PRESSING(keyVariable, keys)
#define PRESSING(%0,%1) \
	(%0 & (%1))

#define RELEASED(%0) \
	(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))

#define MPH_KMH 1.609344



//==============================================================================
//          -- > Enums
//==============================================================================

enum acc
{
	SQLID,
	Name[32],
	Admin,
	ClanManagement,
	Donator,
	Skin,
	Kills,
	Deaths,
	PlayerKeys,
	PlayerEvents,
	Cash,
	GsignPack,
	WeatherAccess,
	TimeAccess,
	WheelChair,
	InWheelChair,
	OpenedCrates,
	ForumID,
	ForumCode,
	Verified,
	NameChanges,
	PlayerGroup,
	Color,
	CBUG,
	GunGameWeapon,
	GunGameIndex,
	Headshots,
	KillStreak,
	HighestSpree,
	EventsStarted,
	Hitmark,
	LoggedIn,
	PreventDamage,
	EventsWon,
	FreeroamVW,
	ForcedRules1,
	TDMTeam,
	LobbyPermission,
	Muted,
	Kicks,
	Mutes,
	ForcedRules,
	SkinPackUnlock,
	BronzePackages,
	SilverPackages,
	GoldPackages,
	DiamondPackages,
	NameChangePackages,
	PremiumKeyPackages,
	UpgradeDialogStage,
	DonatorActive,
	DonatorExpired,
	LobbyWeapon,
	Criminal,
	Police,
	CCVehicleID,
	OfficialClan,
	ShotsHit,
	ShotsFired,
	ShotsMissed,
	Beacon,
	AJailTime,
	CustomSkin,
	Seconds,
	Minutes,
	Hours,
	AdminPin,
	LastLoggedIn,
	CheckingFPS,
	MonthKills,
	LastMonthKills,
	AdminHours,
	AdminActions,
	ClanID,
	ClanName[64],
	ClanRank,
	Tokens,
	TokenPackages,
	RareSkins,
	RareItems,
	hasKDMStaffSkin,
	hasArcherSkin,
	hasGucciSnakeSkin,
	hasIrishPoliceSkin,
	hasNillySkin,
	pLanguage,
	Float:DonationAmount,
	pCopchase,
	pCopchaseVisible,
	pAFKTime,
	CopChaseDead,
	Float:pVPN,
	PlayerText:TextDraw[6],
	pAdminHide
};

enum sCustomSkinData
{
	sSkinID,
	sSkinModel,
	sSkinName[32],
	sSkinMonth[32],
};

enum pCustomSkinData
{
	cSkinID,
	cSkinName[32],
	bool:cSkinUnlocked
};

//==========================================================================
//	Server/Player Variables												  //
//==========================================================================

new Account[MAX_PLAYERS][acc];
new PlayerCustomSkins[MAX_PLAYERS][MAX_CUSTOM_SKINS][pCustomSkinData];

//structure is skin id - model - name
new ServerSkinData[][sCustomSkinData] =
{
	//==[DECEMBER 2017]==//
	{0, 20001, "VLA3", "December 2017"},
	{1, 20002, "Denim Jacket", "December 2017"},
	{2, 20003, "Thrasher 1", "December 2017"},
	{3, 20006, "McDonalds", "December 2017"},
	{4, 20008, "Bape Shorts", "December 2017"},
	{5, 20009, "Gucci Clout", "December 2017"},
	{6, 20010, "OG Papa", "December 2017"},
	{7, 20011, "KFC", "December 2017"},
	{8, 20012, "Chicken Head", "December 2017"},
	{9, 20013, "Gucci Pants", "December 2017"},
	{10, 20014, "Hello Kitty", "December 2017"},

	//==[JANUARY 2018]==//
	{11, 20019, "Supreme Asian", "January 2018"},
	{12, 20018, "One Arm", "January 2018"},
	{13, 20026, "Burger King", "January 2018"},
	{14, 20027, "Fam 1", "January 2018"},
	{15, 20028, "Gucci Boys 1", "January 2018"},
	{16, 20029, "Gucci Boys 2", "January 2018"},
	{17, 20030, "Menace", "January 2018"},
	{18, 20031, "Nun", "January 2018"},
	{19, 20032, "Old Balla", "January 2018"},
	{20, 20033, "Thrasher Girl", "January 2018"},
	{21, 20034, "Yellow Afro", "January 2018"},
	{22, 20035, "Fat Popo", "January 2018"},

	//==[FEBRUARY 2018]==//
	{23, 20036, "Paper Bag", "February 2018"},
	{24, 20037, "Cone Head", "February 2018"},
	{25, 20039, "Gucci Hat", "February 2018"},
	{26, 20040, "Champion Hoodie", "February 2018"},
	{27, 20041, "Green Pants", "February 2018"},
	{28, 20042, "Gucci Flip Flops", "February 2018"},
	{29, 20044, "Small Biker", "February 2018"},
	{30, 20045, "Old Biker", "February 2018"},
	{31, 20046, "Thrasher Girl", "February 2018"},
	{32, 20047, "Fam 2 Hoodie", "February 2018"},
	{33, 20048, "Big Head Ballas 1", "February 2018"},
	{34, 20049, "Big Head Ballas 2", "February 2018"},

	//==[MARCH 2018]==//
	{35, 20055, "Cheetah", "March 2018"},
	{36, 20056, "Guayabera", "March 2018"},
	{37, 20057, "Heavy Crip", "March 2018"},
	{38, 20058, "Gook", "March 2018"},
	{39, 20059, "Trump", "March 2018"},
	{40, 20060, "RalphSkin", "March 2018"},
	{41, 20061, "Papa Tracksuit 1", "March 2018"},
	{42, 20062, "Papa Tracksuit 2", "March 2018"},
	{43, 20063, "Boxer 1", "March 2018"},
	{44, 20064, "Boxer 2", "March 2018"},
	{45, 20065, "Butcher", "March 2018"},
	{46, 20066, "Sharp Boy", "March 2018"},

	//==[April 2018]==//
	{47, 20070, "6ix9ine", "April 2018"},
	{48, 20071, "666", "April 2018"},
	{49, 20072, "Amy Pepe", "April 2018"},
	{50, 20073, "Rockstar Fam", "April 2018"},
	{51, 20074, "Short Sleeve", "April 2018"},
	{52, 20075, "ChickenSoldier", "April 2018"},
	{53, 20076, "Off-White", "April 2018"},
	{54, 20077, "FTP", "April 2018"},
	{55, 20078, "LilXan", "April 2018"},
	{56, 20079, "Mogang", "April 2018"},
	{57, 20080, "Pimp", "April 2018"},
	{58, 20081, "Posh Boy", "April 2018"},

	//==[May 2018]==//
	{59, 20082, "Cosgs Dad", "May 2018"},
	{60, 20083, "Denim Guy", "May 2018"},
	{61, 20084, "Fuego Brother 1", "May 2018"},
	{62, 20085, "Fuego Brother 2", "May 2018"},
	{63, 20087, "Kappa", "May 2018"},
	{64, 20088, "Lakers", "May 2018"},
	{65, 20089, "LocDog", "May 2018"},
	{66, 20090, "Narco", "May 2018"},
	{67, 20091, "Orange12", "May 2018"},
	{68, 20092, "Rickets", "May 2018"},
	{69, 20093, "Slav", "May 2018"},
	{70, 20094, "Triad", "May 2018"},

	//==[June 2018]==//
	{71, 20095, "NY Baller", "June 2018"},
	{72, 20096, "Flag of Shorts", "June 2018"},
	{73, 20097, "Baller v2", "June 2018"},
	{74, 20098, "Freshie", "June 2018"},
	{75, 20099, "Gangcerlona", "June 2018"},
	{76, 20100, "Pink Champ", "June 2018"},
	{77, 20101, "Thrasher Girl v2", "June 2018"},
	{78, 20102, "Addict", "June 2018"},
	{79, 20103, "Lanky", "June 2018"},
	{80, 20104, "Furry", "June 2018"},
	{81, 20105, "Baller v3", "June 2018"},
	{82, 20106, "Howdy", "June 2018"},

	//==[July 2018]==//
	{83, 20107, "Bape Zip 1", "July 2018"},
	{84, 20108, "Bape Zip 2", "July 2018"},
	{85, 20109, "Detective James", "July 2018"},
	{86, 20110, "Fesitval SZN", "July 2018"},
	{87, 20111, "Grove Girl", "July 2018"},
	{88, 20112, "LAPD", "July 2018"},
	{89, 20113, "Palm Angels", "July 2018"},
	{90, 20114, "Persh", "July 2018"},
	{91, 20115, "Polio", "July 2018"},
	{92, 20116, "R.I.P XXX", "July 2018"},
	{93, 20117, "Rockstar Fam", "July 2018"},
	{94, 20118, "Anti Social Nanny", "July 2018"},

	//==[FEBRUARY 2019]==//
	{95, 20123, "Adidass", "February 2019"},
	{96, 20124, "Che", "February 2019"},
	{97, 20125, "Geykume", "February 2019"},
	{98, 20126, "Merci", "February 2019"},
	{99, 20127, "Ned", "February 2019"},
	{100, 20128, "Nikeone", "February 2019"},
	{101, 20129, "Paul", "February 2019"},
	{102, 20130, "Shawty", "February 2019"},
	{103, 20131, "Summr", "February 2019"},
	{104, 20132, "T-Bone", "February 2019"},
	{105, 20133, "Warning", "February 2019"},
	{106, 20134, "Yung Trapper", "February 2019"},

	//==[March 2019]==//
	{107, 20135, "All My Guys", "March 2019"},
	{108, 20136, "Bidness", "March 2019"},
	{109, 20137, "Big D", "March 2019"},
	{110, 20138, "Cyreus", "March 2019"},
	{111, 20139, "Flexx", "March 2019"},
	{112, 20140, "Green Bottles", "March 2019"},
	{113, 20141, "Lacotse", "March 2019"},
	{114, 20142, "Mo-chang", "March 2019"},
	{115, 20143, "Momma", "March 2019"},
	{116, 20144, "Omokung", "March 2019"},
	{117, 20145, "Slim Jesus", "March 2019"},
	{118, 20146, "Trash", "March 2019"},

	//==[April 2019]==//
	{119, 20148, "Adibuer", "April 2019"},
	{120, 20149, "Business Girl", "April 2019"},
	{121, 20150, "Fine Buer", "April 2019"},
	{122, 20151, "G-Bone", "April 2019"},
	{123, 20152, "Head-ass", "April 2019"},
	{124, 20153, "Injured", "April 2019"},
	{125, 20154, "Mac-Shorts", "April 2019"},
	{126, 20155, "Mall Cop", "April 2019"},
	{127, 20156, "Maxxer", "April 2019"},
	{128, 20157, "Rockstar Girl", "April 2019"},
	{129, 20158, "The Eagle", "April 2019"},
	{130, 20159, "Who Wants It", "April 2019"}
};

enum PLAYER_COLORS
{
	pEmbedColor[10],
	pColorName[24],
	pColor,
}
new pColorData[][PLAYER_COLORS] =
{
	{"{FFFFFF}", "WHITE", pCOLOR_WHITE},
	{"{FFFFFF}", "Transparent", pCOLOR_INVISIBLE},
	{EMBED_GREEN, "green", pCOLOR_GREEN},
	{EMBED_RED, "red", pCOLOR_RED},
	{EMBED_BLUE, "bluwe", pCOLOR_BLUE},
	{EMBED_PINK, "pink", pCOLOR_PINK},
	{EMBED_PURPLE, "purple", pCOLOR_PURPLE},
	{EMBED_YELLOW, "yellow", pCOLOR_YELLOW},
	{EMBED_BROWN, "brown", pCOLOR_BROWN},
	{EMBED_GREY, "grey", pCOLOR_GREY},
	{EMBED_GREY, "black", pCOLOR_BLACK},
	{EMBED_LPINK, "lpink", pCOLOR_LPINK},
	{EMBED_ORANGE, "orange", pCOLOR_ORANGE},
	{EMBED_PINKRED, "pinkred", pCOLOR_PINKRED},
	{EMBED_DARKRED, "darkred", pCOLOR_DARKRED},
	{EMBED_DARKERRED, "darkerred", pCOLOR_DARKERRED},
	{EMBED_ORANGERED, "orangered", pCOLOR_ORANGERED},
	{EMBED_TOMATO, "tomato", pCOLOR_TOMATO},
	{EMBED_LIGHTBLUE, "lightblue", pCOLOR_LIGHTBLUE},
	{EMBED_LIGHTNAVY, "lightnavy", pCOLOR_LIGHTNAVY},
	{EMBED_NAVYBLUE, "navyblue", pCOLOR_NAVYBLUE},
	{EMBED_LBLUE, "lblue", pCOLOR_LBLUE},
	{EMBED_LLBLUE, "llblue", pCOLOR_LLBLUE},
	{EMBED_FLBLUE, "flblue", pCOLOR_FLBLUE},
	{EMBED_BLUEVIOLET, "blueviolet", pCOLOR_BLUEVIOLET},
	{EMBED_BISQUE, "bisque", pCOLOR_BISQUE},
	{EMBED_LIME, "lime", pCOLOR_LIME},
	{EMBED_LAWNGREEN, "lawngreen", pCOLOR_LAWNGREEN},
	{EMBED_SEAGREEN, "seagreen", pCOLOR_SEAGREEN},
	{EMBED_LIMEGREEN, "limegreen", pCOLOR_LIMEGREEN},
	{EMBED_SPRINGGREEN, "springgreen", pCOLOR_SPRINGGREEN},
	{EMBED_YELLOWGREEN, "yellowgreen", pCOLOR_YELLOWGREEN},
	{EMBED_GREENYELLOW, "greenyellow", pCOLOR_GREENYELLOW},
	{EMBED_OLIVE, "olive", pCOLOR_OLIVE},
	{EMBED_AQUA, "aqua", pCOLOR_AQUA},
	{EMBED_MEDIUMAQUA, "mediumaque", pCOLOR_MEDIUMAQUA},
	{EMBED_MAGENTA, "magenta", pCOLOR_MAGENTA},
	{EMBED_MEDIUMMAGENTA, "mediummagenta", pCOLOR_MEDIUMMAGENTA},
	{EMBED_CHARTREUSE, "chartreuse", pCOLOR_CHARTREUSE},
	{EMBED_CORAL, "coral", pCOLOR_CORAL},
	{EMBED_GOLD, "gold", pCOLOR_GOLD},
	{EMBED_INDIGO, "indigo", pCOLOR_INDIGO},
	{EMBED_IVORY, "ivory", pCOLOR_IVORY}
};

//=========================================================================

new PlayerText:InfoBox[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...};
new PlayerText:InfoBoxOS[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...};
//==========================================================================

//==========================================================================
//	Optimisations														  //
//==========================================================================
new bool:PickedUpPickup[MAX_PLAYERS];
new LastCommandTime[MAX_PLAYERS];
//==========================================================================

//==========================================================================
//	PM System  														      //
//==========================================================================
new PMReply[MAX_PLAYERS];
//==========================================================================

new WeaponNameList[][] =
{
	"Unarmed" "Fist", "BrassKnuckles" "KnuckleDuster", "GolfClub", "NightStick", "Knife", "BaseballBat",
	"Shovel", "PoolCue", "Katana", "Chainsaw", "PurpleDildo", "BigWhiteVibrator",
	"MedWhiteVibrator", "SmlWhiteVibrator", "Flowers", "Cane", "Grenade", "Teargas",
	"Molotov", "None1", "None2", "None3",  "Colt45" "9mm", "SDPistol" "Silenced9mm",
	"Deagle", "Shotgun", "SawnoffShotgun", "Spas12", "Mac10" "UZI",
	"MP5", "AK47", "M4", "Tec9", "CountryRifle", "Sniper", "RPG",
	"HeatRPG", "Flamethrower", "Minigun", "Satchel", "Detonator",
	"SprayCan", "Extinguisher", "Camera", "NVGoggles", "IRGoggles",
	"Parachute"
};

//==============================================================================
//          -- > Gamemode Includes
//==============================================================================

//player activity tracking
#include "modules/server/activity.pwn"

//anticheat
#include "modules/server/anticheat/anticheat.pwn"

//server maps
#include "modules/server/maps/lobby.pwn"
#include "modules/server/maps/sewers.pwn"
#include "modules/server/maps/western.pwn"
#include "modules/server/maps/farm.pwn"
#include "modules/server/maps/dust2.pwn"
#include "modules/server/maps/tdm.pwn"

//other
#include "modules/server/hooks.pwn"
#include "modules/server/mysql.pwn"
#include "modules/server/load_settings.pwn"
#include "modules/server/discord.pwn"

//registering/logging in
#include "modules/player/accounts.pwn"

//features
#include "modules/server/features/arenas.pwn"
#include "modules/server/features/duel.pwn"
#include "modules/server/features/reports.pwn"
#include "modules/server/features/teamdeathmatch.pwn"
#include "modules/server/features/skinroll.pwn"
#include "modules/server/features/spectating.pwn"
#include "modules/server/features/upgrade.pwn"
#include "modules/server/features/copchase.pwn"
#include "modules/server/features/freeroam.pwn"
#include "modules/server/features/leaderboards.pwn"
#include "modules/server/features/events.pwn"
#include "modules/server/features/customskins.pwn"
#include "modules/server/lobby.pwn"
#include "modules/server/features/monthlydeathmatcher.pwn"
#include "modules/server/features/latestdonator.pwn"
#include "modules/server/features/clans.pwn"
#include "modules/server/features/serverhub.pwn"
//#include "modules/server/mselecti.pwn"
//#include "modules/server/features/headshotarenas.pwn"

//player
#include "modules/player/sessiontds.pwn"
#include "modules/player/networktds.pwn"
#include "modules/player/settings.pwn"

//admin
#include "modules/server/admin/admincmds.pwn"
#include "modules/server/admin/adminfunctions.pwn"
//#include "modules/server/admin/adminnotes.pwn"

//clanmanagement
#include "modules/server/admin/clanmanagement/officialclans.pwn"


//==========================================================================
//==========================================================================

new AdminNames[][] =
{
	"None",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6"
};

//nnow
enum E_SAZONE
{
    zName[28],
    Float:zArea[6]
};

new ZonesList[][E_SAZONE] =
{
    {"The Big Ear", {-410.00,1403.30,-3.00,-137.90,1681.20,200.00}},
    {"Aldea Malvada",{-1372.10,2498.50,0.00,-1277.50,2615.30,200.00}},
    {"Angel Pine",{-2324.90,-2584.20,-6.10,-1964.20,-2212.10,200.00}},
    {"Arco del Oeste",{-901.10,2221.80,0.00,-592.00,2571.90,200.00}},
    {"Avispa Country Club",{-2646.40,-355.40,0.00,-2270.00,-222.50,200.00}},
    {"Avispa Country Club",{-2831.80,-430.20,-6.10,-2646.40,-222.50,200.00}},
    {"Avispa Country Club",{-2361.50,-417.10,0.00,-2270.00,-355.40,200.00}},
    {"Avispa Country Club",{-2667.80,-302.10,-28.80,-2646.40,-262.30,71.10}},
    {"Avispa Country Club",{-2470.00,-355.40,0.00,-2270.00,-318.40,46.10}},
    {"Avispa Country Club",{-2550.00,-355.40,0.00,-2470.00,-318.40,39.70}},
    {"Back o Beyond",{-1166.90,-2641.10,0.00,-321.70,-1856.00,200.00}},
    {"Battery Point",{-2741.00,1268.40,-4.50,-2533.00,1490.40,200.00}},
    {"Bayside",{-2741.00,2175.10,0.00,-2353.10,2722.70,200.00}},
    {"Bayside Marina",{-2353.10,2275.70,0.00,-2153.10,2475.70,200.00}},
    {"Beacon Hill",{-399.60,-1075.50,-1.40,-319.00,-977.50,198.50}},
    {"Blackfield",{964.30,1203.20,-89.00,1197.30,1403.20,110.90}},
    {"Blackfield",{964.30,1403.20,-89.00,1197.30,1726.20,110.90}},
    {"Blackfield Chapel",{1375.60,596.30,-89.00,1558.00,823.20,110.90}},
    {"Blackfield Chapel",{1325.60,596.30,-89.00,1375.60,795.00,110.90}},
    {"Blackfield Intersection",{1197.30,1044.60,-89.00,1277.00,1163.30,110.90}},
    {"Blackfield Intersection",{1166.50,795.00,-89.00,1375.60,1044.60,110.90}},
    {"Blackfield Intersection",{1277.00,1044.60,-89.00,1315.30,1087.60,110.90}},
    {"Blackfield Intersection",{1375.60,823.20,-89.00,1457.30,919.40,110.90}},
    {"Blueberry", {104.50,-220.10,2.30,349.60,152.20,200.00}},
    {"Blueberry", {19.60,-404.10,3.80,349.60,-220.10,200.00}},
    {"Blueberry Acres",{-319.60,-220.10,0.00,104.50,293.30,200.00}},
    {"Caligula's Palace",{2087.30,1543.20,-89.00,2437.30,1703.20,110.90}},
    {"Caligula's Palace",{2137.40,1703.20,-89.00,2437.30,1783.20,110.90}},
    {"Calton Heights",{-2274.10,744.10,-6.10,-1982.30,1358.90,200.00}},
    {"Chinatown", {-2274.10,578.30,-7.60,-2078.60,744.10,200.00}},
    {"City Hall", {-2867.80,277.40,-9.10,-2593.40,458.40,200.00}},
    {"Come-A-Lot",{2087.30,943.20,-89.00,2623.10,1203.20,110.90}},
    {"Commerce",{1323.90,-1842.20,-89.00,1701.90,-1722.20,110.90}},
    {"Commerce",{1323.90,-1722.20,-89.00,1440.90,-1577.50,110.90}},
    {"Commerce",{1370.80,-1577.50,-89.00,1463.90,-1384.90,110.90}},
    {"Commerce",{1463.90,-1577.50,-89.00,1667.90,-1430.80,110.90}},
    {"Commerce",{1583.50,-1722.20,-89.00,1758.90,-1577.50,110.90}},
    {"Commerce",{1667.90,-1577.50,-89.00,1812.60,-1430.80,110.90}},
    {"Conference Center",{1046.10,-1804.20,-89.00,1323.90,-1722.20,110.90}},
    {"Conference Center",{1073.20,-1842.20,-89.00,1323.90,-1804.20,110.90}},
    {"Cranberry Station",{-2007.80,56.30,0.00,-1922.00,224.70,100.00}},
    {"Creek", {2749.90,1937.20,-89.00,2921.60,2669.70,110.90}},
    {"Dillimore", {580.70,-674.80,-9.50,861.00,-404.70,200.00}},
    {"Doherty",{-2270.00,-324.10,-0.00,-1794.90,-222.50,200.00}},
    {"Doherty",{-2173.00,-222.50,-0.00,-1794.90,265.20,200.00}},
    {"Downtown",{-1982.30,744.10,-6.10,-1871.70,1274.20,200.00}},
    {"Downtown",{-1871.70,1176.40,-4.50,-1620.30,1274.20,200.00}},
    {"Downtown",{-1700.00,744.20,-6.10,-1580.00,1176.50,200.00}},
    {"Downtown",{-1580.00,744.20,-6.10,-1499.80,1025.90,200.00}},
    {"Downtown",{-2078.60,578.30,-7.60,-1499.80,744.20,200.00}},
    {"Downtown",{-1993.20,265.20,-9.10,-1794.90,578.30,200.00}},
    {"Downtown Los Santos",{1463.90,-1430.80,-89.00,1724.70,-1290.80,110.90}},
    {"Downtown Los Santos",{1724.70,-1430.80,-89.00,1812.60,-1250.90,110.90}},
    {"Downtown Los Santos",{1463.90,-1290.80,-89.00,1724.70,-1150.80,110.90}},
    {"Downtown Los Santos",{1370.80,-1384.90,-89.00,1463.90,-1170.80,110.90}},
    {"Downtown Los Santos",{1724.70,-1250.90,-89.00,1812.60,-1150.80,110.90}},
    {"Downtown Los Santos",{1370.80,-1170.80,-89.00,1463.90,-1130.80,110.90}},
    {"Downtown Los Santos",{1378.30,-1130.80,-89.00,1463.90,-1026.30,110.90}},
    {"Downtown Los Santos",{1391.00,-1026.30,-89.00,1463.90,-926.90,110.90}},
    {"Downtown Los Santos",{1507.50,-1385.20,110.90,1582.50,-1325.30,335.90}},
    {"East Beach",{2632.80,-1852.80,-89.00,2959.30,-1668.10,110.90}},
    {"East Beach",{2632.80,-1668.10,-89.00,2747.70,-1393.40,110.90}},
    {"East Beach",{2747.70,-1668.10,-89.00,2959.30,-1498.60,110.90}},
    {"East Beach",{2747.70,-1498.60,-89.00,2959.30,-1120.00,110.90}},
    {"East Los Santos",{2421.00,-1628.50,-89.00,2632.80,-1454.30,110.90}},
    {"East Los Santos",{2222.50,-1628.50,-89.00,2421.00,-1494.00,110.90}},
    {"East Los Santos",{2266.20,-1494.00,-89.00,2381.60,-1372.00,110.90}},
    {"East Los Santos",{2381.60,-1494.00,-89.00,2421.00,-1454.30,110.90}},
    {"East Los Santos",{2281.40,-1372.00,-89.00,2381.60,-1135.00,110.90}},
    {"East Los Santos",{2381.60,-1454.30,-89.00,2462.10,-1135.00,110.90}},
    {"East Los Santos",{2462.10,-1454.30,-89.00,2581.70,-1135.00,110.90}},
    {"Easter Basin",{-1794.90,249.90,-9.10,-1242.90,578.30,200.00}},
    {"Easter Basin",{-1794.90,-50.00,-0.00,-1499.80,249.90,200.00}},
    {"Easter Bay Airport",{-1499.80,-50.00,-0.00,-1242.90,249.90,200.00}},
    {"Easter Bay Airport",{-1794.90,-730.10,-3.00,-1213.90,-50.00,200.00}},
    {"Easter Bay Airport",{-1213.90,-730.10,0.00,-1132.80,-50.00,200.00}},
    {"Easter Bay Airport",{-1242.90,-50.00,0.00,-1213.90,578.30,200.00}},
    {"Easter Bay Airport",{-1213.90,-50.00,-4.50,-947.90,578.30,200.00}},
    {"Easter Bay Airport",{-1315.40,-405.30,15.40,-1264.40,-209.50,25.40}},
    {"Easter Bay Airport",{-1354.30,-287.30,15.40,-1315.40,-209.50,25.40}},
    {"Easter Bay Airport",{-1490.30,-209.50,15.40,-1264.40,-148.30,25.40}},
    {"Easter Bay Chemicals", {-1132.80,-768.00,0.00,-956.40,-578.10,200.00}},
    {"Easter Bay Chemicals", {-1132.80,-787.30,0.00,-956.40,-768.00,200.00}},
    {"El Castillo del Diablo",{-464.50,2217.60,0.00,-208.50,2580.30,200.00}},
    {"El Castillo del Diablo",{-208.50,2123.00,-7.60,114.00,2337.10,200.00}},
    {"El Castillo del Diablo",{-208.50,2337.10,0.00,8.40,2487.10,200.00}},
    {"El Corona", {1812.60,-2179.20,-89.00,1970.60,-1852.80,110.90}},
    {"El Corona", {1692.60,-2179.20,-89.00,1812.60,-1842.20,110.90}},
    {"El Quebrados",{-1645.20,2498.50,0.00,-1372.10,2777.80,200.00}},
    {"Esplanade East",{-1620.30,1176.50,-4.50,-1580.00,1274.20,200.00}},
    {"Esplanade East",{-1580.00,1025.90,-6.10,-1499.80,1274.20,200.00}},
    {"Esplanade East",{-1499.80,578.30,-79.60,-1339.80,1274.20,20.30}},
    {"Esplanade North",{-2533.00,1358.90,-4.50,-1996.60,1501.20,200.00}},
    {"Esplanade North",{-1996.60,1358.90,-4.50,-1524.20,1592.50,200.00}},
    {"Esplanade North",{-1982.30,1274.20,-4.50,-1524.20,1358.90,200.00}},
    {"Fallen Tree",{-792.20,-698.50,-5.30,-452.40,-380.00,200.00}},
    {"Fallow Bridge",{434.30,366.50,0.00,603.00,555.60,200.00}},
    {"Fern Ridge",{508.10,-139.20,0.00,1306.60,119.50,200.00}},
    {"Financial", {-1871.70,744.10,-6.10,-1701.30,1176.40,300.00}},
    {"Fisher's Lagoon",{1916.90,-233.30,-100.00,2131.70,13.80,200.00}},
    {"Flint Intersection",{-187.70,-1596.70,-89.00,17.00,-1276.60,110.90}},
    {"Flint Range",{-594.10,-1648.50,0.00,-187.70,-1276.60,200.00}},
    {"Fort Carson",{-376.20,826.30,-3.00,123.70,1220.40,200.00}},
    {"Foster Valley",{-2270.00,-430.20,-0.00,-2178.60,-324.10,200.00}},
    {"Foster Valley",{-2178.60,-599.80,-0.00,-1794.90,-324.10,200.00}},
    {"Foster Valley",{-2178.60,-1115.50,0.00,-1794.90,-599.80,200.00}},
    {"Foster Valley",{-2178.60,-1250.90,0.00,-1794.90,-1115.50,200.00}},
    {"Frederick Bridge", {2759.20,296.50,0.00,2774.20,594.70,200.00}},
    {"Gant Bridge",{-2741.40,1659.60,-6.10,-2616.40,2175.10,200.00}},
    {"Gant Bridge",{-2741.00,1490.40,-6.10,-2616.40,1659.60,200.00}},
    {"Ganton",{2222.50,-1852.80,-89.00,2632.80,-1722.30,110.90}},
    {"Ganton",{2222.50,-1722.30,-89.00,2632.80,-1628.50,110.90}},
    {"Garcia",{-2411.20,-222.50,-0.00,-2173.00,265.20,200.00}},
    {"Garcia",{-2395.10,-222.50,-5.30,-2354.00,-204.70,200.00}},
    {"Garver Bridge",{-1339.80,828.10,-89.00,-1213.90,1057.00,110.90}},
    {"Garver Bridge",{-1213.90,950.00,-89.00,-1087.90,1178.90,110.90}},
    {"Garver Bridge",{-1499.80,696.40,-179.60,-1339.80,925.30,20.30}},
    {"Glen Park", {1812.60,-1449.60,-89.00,1996.90,-1350.70,110.90}},
    {"Glen Park", {1812.60,-1100.80,-89.00,1994.30,-973.30,110.90}},
    {"Glen Park", {1812.60,-1350.70,-89.00,2056.80,-1100.80,110.90}},
    {"Green Palms",{176.50,1305.40,-3.00,338.60,1520.70,200.00}},
    {"Greenglass College",{964.30,1044.60,-89.00,1197.30,1203.20,110.90}},
    {"Greenglass College",{964.30,930.80,-89.00,1166.50,1044.60,110.90}},
    {"Hampton Barns",{603.00,264.30,0.00,761.90,366.50,200.00}},
    {"Hankypanky Point", {2576.90,62.10,0.00,2759.20,385.50,200.00}},
    {"Harry Gold Parkway",{1777.30,863.20,-89.00,1817.30,2342.80,110.90}},
    {"Hashbury",{-2593.40,-222.50,-0.00,-2411.20,54.70,200.00}},
    {"Hilltop Farm",{967.30,-450.30,-3.00,1176.70,-217.90,200.00}},
    {"Hunter Quarry",{337.20,710.80,-115.20,860.50,1031.70,203.70}},
    {"Idlewood",{1812.60,-1852.80,-89.00,1971.60,-1742.30,110.90}},
    {"Idlewood",{1812.60,-1742.30,-89.00,1951.60,-1602.30,110.90}},
    {"Idlewood",{1951.60,-1742.30,-89.00,2124.60,-1602.30,110.90}},
    {"Idlewood",{1812.60,-1602.30,-89.00,2124.60,-1449.60,110.90}},
    {"Idlewood",{2124.60,-1742.30,-89.00,2222.50,-1494.00,110.90}},
    {"Idlewood",{1971.60,-1852.80,-89.00,2222.50,-1742.30,110.90}},
    {"Jefferson", {1996.90,-1449.60,-89.00,2056.80,-1350.70,110.90}},
    {"Jefferson", {2124.60,-1494.00,-89.00,2266.20,-1449.60,110.90}},
    {"Jefferson", {2056.80,-1372.00,-89.00,2281.40,-1210.70,110.90}},
    {"Jefferson", {2056.80,-1210.70,-89.00,2185.30,-1126.30,110.90}},
    {"Jefferson", {2185.30,-1210.70,-89.00,2281.40,-1154.50,110.90}},
    {"Jefferson", {2056.80,-1449.60,-89.00,2266.20,-1372.00,110.90}},
    {"Julius Thruway East",{2623.10,943.20,-89.00,2749.90,1055.90,110.90}},
    {"Julius Thruway East",{2685.10,1055.90,-89.00,2749.90,2626.50,110.90}},
    {"Julius Thruway East",{2536.40,2442.50,-89.00,2685.10,2542.50,110.90}},
    {"Julius Thruway East",{2625.10,2202.70,-89.00,2685.10,2442.50,110.90}},
    {"Julius Thruway North", {2498.20,2542.50,-89.00,2685.10,2626.50,110.90}},
    {"Julius Thruway North", {2237.40,2542.50,-89.00,2498.20,2663.10,110.90}},
    {"Julius Thruway North", {2121.40,2508.20,-89.00,2237.40,2663.10,110.90}},
    {"Julius Thruway North", {1938.80,2508.20,-89.00,2121.40,2624.20,110.90}},
    {"Julius Thruway North", {1534.50,2433.20,-89.00,1848.40,2583.20,110.90}},
    {"Julius Thruway North", {1848.40,2478.40,-89.00,1938.80,2553.40,110.90}},
    {"Julius Thruway North", {1704.50,2342.80,-89.00,1848.40,2433.20,110.90}},
    {"Julius Thruway North", {1377.30,2433.20,-89.00,1534.50,2507.20,110.90}},
    {"Julius Thruway South", {1457.30,823.20,-89.00,2377.30,863.20,110.90}},
    {"Julius Thruway South", {2377.30,788.80,-89.00,2537.30,897.90,110.90}},
    {"Julius Thruway West",{1197.30,1163.30,-89.00,1236.60,2243.20,110.90}},
    {"Julius Thruway West",{1236.60,2142.80,-89.00,1297.40,2243.20,110.90}},
    {"Juniper Hill",{-2533.00,578.30,-7.60,-2274.10,968.30,200.00}},
    {"Juniper Hollow",{-2533.00,968.30,-6.10,-2274.10,1358.90,200.00}},
    {"K.A.C.C. Military Fuels",{2498.20,2626.50,-89.00,2749.90,2861.50,110.90}},
    {"Kincaid Bridge",{-1339.80,599.20,-89.00,-1213.90,828.10,110.90}},
    {"Kincaid Bridge",{-1213.90,721.10,-89.00,-1087.90,950.00,110.90}},
    {"Kincaid Bridge",{-1087.90,855.30,-89.00,-961.90,986.20,110.90}},
    {"King's",{-2329.30,458.40,-7.60,-1993.20,578.30,200.00}},
    {"King's",{-2411.20,265.20,-9.10,-1993.20,373.50,200.00}},
    {"King's",{-2253.50,373.50,-9.10,-1993.20,458.40,200.00}},
    {"LVA Freight Depot",{1457.30,863.20,-89.00,1777.40,1143.20,110.90}},
    {"LVA Freight Depot",{1375.60,919.40,-89.00,1457.30,1203.20,110.90}},
    {"LVA Freight Depot",{1277.00,1087.60,-89.00,1375.60,1203.20,110.90}},
    {"LVA Freight Depot",{1315.30,1044.60,-89.00,1375.60,1087.60,110.90}},
    {"LVA Freight Depot",{1236.60,1163.40,-89.00,1277.00,1203.20,110.90}},
    {"Las Barrancas",{-926.10,1398.70,-3.00,-719.20,1634.60,200.00}},
    {"Las Brujas",{-365.10,2123.00,-3.00,-208.50,2217.60,200.00}},
    {"Las Colinas",{1994.30,-1100.80,-89.00,2056.80,-920.80,110.90}},
    {"Las Colinas",{2056.80,-1126.30,-89.00,2126.80,-920.80,110.90}},
    {"Las Colinas",{2185.30,-1154.50,-89.00,2281.40,-934.40,110.90}},
    {"Las Colinas",{2126.80,-1126.30,-89.00,2185.30,-934.40,110.90}},
    {"Las Colinas",{2747.70,-1120.00,-89.00,2959.30,-945.00,110.90}},
    {"Las Colinas",{2632.70,-1135.00,-89.00,2747.70,-945.00,110.90}},
    {"Las Colinas",{2281.40,-1135.00,-89.00,2632.70,-945.00,110.90}},
    {"Las Payasadas",{-354.30,2580.30,2.00,-133.60,2816.80,200.00}},
    {"Las Venturas Airport", {1236.60,1203.20,-89.00,1457.30,1883.10,110.90}},
    {"Las Venturas Airport", {1457.30,1203.20,-89.00,1777.30,1883.10,110.90}},
    {"Las Venturas Airport", {1457.30,1143.20,-89.00,1777.40,1203.20,110.90}},
    {"Las Venturas Airport", {1515.80,1586.40,-12.50,1729.90,1714.50,87.50}},
    {"Last Dime Motel",{1823.00,596.30,-89.00,1997.20,823.20,110.90}},
    {"Leafy Hollow",{-1166.90,-1856.00,0.00,-815.60,-1602.00,200.00}},
    {"Liberty City",{-1000.00,400.00,1300.00,-700.00,600.00,1400.00}},
    {"Lil' Probe Inn",{-90.20,1286.80,-3.00,153.80,1554.10,200.00}},
    {"Linden Side",{2749.90,943.20,-89.00,2923.30,1198.90,110.90}},
    {"Linden Station",{2749.90,1198.90,-89.00,2923.30,1548.90,110.90}},
    {"Linden Station",{2811.20,1229.50,-39.50,2861.20,1407.50,60.40}},
    {"Little Mexico",{1701.90,-1842.20,-89.00,1812.60,-1722.20,110.90}},
    {"Little Mexico",{1758.90,-1722.20,-89.00,1812.60,-1577.50,110.90}},
    {"Los Flores",{2581.70,-1454.30,-89.00,2632.80,-1393.40,110.90}},
    {"Los Flores",{2581.70,-1393.40,-89.00,2747.70,-1135.00,110.90}},
    {"Los Santos International",{1249.60,-2394.30,-89.00,1852.00,-2179.20,110.90}},
    {"Los Santos International",{1852.00,-2394.30,-89.00,2089.00,-2179.20,110.90}},
    {"Los Santos International",{1382.70,-2730.80,-89.00,2201.80,-2394.30,110.90}},
    {"Los Santos International",{1974.60,-2394.30,-39.00,2089.00,-2256.50,60.90}},
    {"Los Santos International",{1400.90,-2669.20,-39.00,2189.80,-2597.20,60.90}},
    {"Los Santos International",{2051.60,-2597.20,-39.00,2152.40,-2394.30,60.90}},
    {"Marina",{647.70,-1804.20,-89.00,851.40,-1577.50,110.90}},
    {"Marina",{647.70,-1577.50,-89.00,807.90,-1416.20,110.90}},
    {"Marina",{807.90,-1577.50,-89.00,926.90,-1416.20,110.90}},
    {"Market",{787.40,-1416.20,-89.00,1072.60,-1310.20,110.90}},
    {"Market",{952.60,-1310.20,-89.00,1072.60,-1130.80,110.90}},
    {"Market",{1072.60,-1416.20,-89.00,1370.80,-1130.80,110.90}},
    {"Market",{926.90,-1577.50,-89.00,1370.80,-1416.20,110.90}},
    {"Market Station",{787.40,-1410.90,-34.10,866.00,-1310.20,65.80}},
    {"Martin Bridge",{-222.10,293.30,0.00,-122.10,476.40,200.00}},
    {"Missionary Hill",{-2994.40,-811.20,0.00,-2178.60,-430.20,200.00}},
    {"Montgomery",{1119.50,119.50,-3.00,1451.40,493.30,200.00}},
    {"Montgomery",{1451.40,347.40,-6.10,1582.40,420.80,200.00}},
    {"Montgomery Intersection",{1546.60,208.10,0.00,1745.80,347.40,200.00}},
    {"Montgomery Intersection",{1582.40,347.40,0.00,1664.60,401.70,200.00}},
    {"Mulholland",{1414.00,-768.00,-89.00,1667.60,-452.40,110.90}},
    {"Mulholland",{1281.10,-452.40,-89.00,1641.10,-290.90,110.90}},
    {"Mulholland",{1269.10,-768.00,-89.00,1414.00,-452.40,110.90}},
    {"Mulholland",{1357.00,-926.90,-89.00,1463.90,-768.00,110.90}},
    {"Mulholland",{1318.10,-910.10,-89.00,1357.00,-768.00,110.90}},
    {"Mulholland",{1169.10,-910.10,-89.00,1318.10,-768.00,110.90}},
    {"Mulholland",{768.60,-954.60,-89.00,952.60,-860.60,110.90}},
    {"Mulholland",{687.80,-860.60,-89.00,911.80,-768.00,110.90}},
    {"Mulholland",{737.50,-768.00,-89.00,1142.20,-674.80,110.90}},
    {"Mulholland",{1096.40,-910.10,-89.00,1169.10,-768.00,110.90}},
    {"Mulholland",{952.60,-937.10,-89.00,1096.40,-860.60,110.90}},
    {"Mulholland",{911.80,-860.60,-89.00,1096.40,-768.00,110.90}},
    {"Mulholland",{861.00,-674.80,-89.00,1156.50,-600.80,110.90}},
    {"Mulholland Intersection",{1463.90,-1150.80,-89.00,1812.60,-768.00,110.90}},
    {"North Rock",{2285.30,-768.00,0.00,2770.50,-269.70,200.00}},
    {"Ocean Docks",{2373.70,-2697.00,-89.00,2809.20,-2330.40,110.90}},
    {"Ocean Docks",{2201.80,-2418.30,-89.00,2324.00,-2095.00,110.90}},
    {"Ocean Docks",{2324.00,-2302.30,-89.00,2703.50,-2145.10,110.90}},
    {"Ocean Docks",{2089.00,-2394.30,-89.00,2201.80,-2235.80,110.90}},
    {"Ocean Docks",{2201.80,-2730.80,-89.00,2324.00,-2418.30,110.90}},
    {"Ocean Docks",{2703.50,-2302.30,-89.00,2959.30,-2126.90,110.90}},
    {"Ocean Docks",{2324.00,-2145.10,-89.00,2703.50,-2059.20,110.90}},
    {"Ocean Flats",{-2994.40,277.40,-9.10,-2867.80,458.40,200.00}},
    {"Ocean Flats",{-2994.40,-222.50,-0.00,-2593.40,277.40,200.00}},
    {"Ocean Flats",{-2994.40,-430.20,-0.00,-2831.80,-222.50,200.00}},
    {"Octane Springs",{338.60,1228.50,0.00,664.30,1655.00,200.00}},
    {"Old Venturas Strip",{2162.30,2012.10,-89.00,2685.10,2202.70,110.90}},
    {"Palisades", {-2994.40,458.40,-6.10,-2741.00,1339.60,200.00}},
    {"Palomino Creek",{2160.20,-149.00,0.00,2576.90,228.30,200.00}},
    {"Paradiso",{-2741.00,793.40,-6.10,-2533.00,1268.40,200.00}},
    {"Pershing Square",{1440.90,-1722.20,-89.00,1583.50,-1577.50,110.90}},
    {"Pilgrim",{2437.30,1383.20,-89.00,2624.40,1783.20,110.90}},
    {"Pilgrim",{2624.40,1383.20,-89.00,2685.10,1783.20,110.90}},
    {"Pilson Intersection",{1098.30,2243.20,-89.00,1377.30,2507.20,110.90}},
    {"Pirates in Men's Pants",{1817.30,1469.20,-89.00,2027.40,1703.20,110.90}},
    {"Playa del Seville",{2703.50,-2126.90,-89.00,2959.30,-1852.80,110.90}},
    {"Prickle Pine",{1534.50,2583.20,-89.00,1848.40,2863.20,110.90}},
    {"Prickle Pine",{1117.40,2507.20,-89.00,1534.50,2723.20,110.90}},
    {"Prickle Pine",{1848.40,2553.40,-89.00,1938.80,2863.20,110.90}},
    {"Prickle Pine",{1938.80,2624.20,-89.00,2121.40,2861.50,110.90}},
    {"Queens",{-2533.00,458.40,0.00,-2329.30,578.30,200.00}},
    {"Queens",{-2593.40,54.70,0.00,-2411.20,458.40,200.00}},
    {"Queens",{-2411.20,373.50,0.00,-2253.50,458.40,200.00}},
    {"Randolph Industrial Estate",{1558.00,596.30,-89.00,1823.00,823.20,110.90}},
    {"Redsands East",{1817.30,2011.80,-89.00,2106.70,2202.70,110.90}},
    {"Redsands East",{1817.30,2202.70,-89.00,2011.90,2342.80,110.90}},
    {"Redsands East",{1848.40,2342.80,-89.00,2011.90,2478.40,110.90}},
    {"Redsands West",{1236.60,1883.10,-89.00,1777.30,2142.80,110.90}},
    {"Redsands West",{1297.40,2142.80,-89.00,1777.30,2243.20,110.90}},
    {"Redsands West",{1377.30,2243.20,-89.00,1704.50,2433.20,110.90}},
    {"Redsands West",{1704.50,2243.20,-89.00,1777.30,2342.80,110.90}},
    {"Regular Tom",{-405.70,1712.80,-3.00,-276.70,1892.70,200.00}},
    {"Richman",{647.50,-1118.20,-89.00,787.40,-954.60,110.90}},
    {"Richman",{647.50,-954.60,-89.00,768.60,-860.60,110.90}},
    {"Richman",{225.10,-1369.60,-89.00,334.50,-1292.00,110.90}},
    {"Richman",{225.10,-1292.00,-89.00,466.20,-1235.00,110.90}},
    {"Richman",{72.60,-1404.90,-89.00,225.10,-1235.00,110.90}},
    {"Richman",{72.60,-1235.00,-89.00,321.30,-1008.10,110.90}},
    {"Richman",{321.30,-1235.00,-89.00,647.50,-1044.00,110.90}},
    {"Richman",{321.30,-1044.00,-89.00,647.50,-860.60,110.90}},
    {"Richman",{321.30,-860.60,-89.00,687.80,-768.00,110.90}},
    {"Richman",{321.30,-768.00,-89.00,700.70,-674.80,110.90}},
    {"Robada Intersection",{-1119.00,1178.90,-89.00,-862.00,1351.40,110.90}},
    {"Roca Escalante",{2237.40,2202.70,-89.00,2536.40,2542.50,110.90}},
    {"Roca Escalante",{2536.40,2202.70,-89.00,2625.10,2442.50,110.90}},
    {"Rockshore East",{2537.30,676.50,-89.00,2902.30,943.20,110.90}},
    {"Rockshore West",{1997.20,596.30,-89.00,2377.30,823.20,110.90}},
    {"Rockshore West",{2377.30,596.30,-89.00,2537.30,788.80,110.90}},
    {"Rodeo", {72.60,-1684.60,-89.00,225.10,-1544.10,110.90}},
    {"Rodeo", {72.60,-1544.10,-89.00,225.10,-1404.90,110.90}},
    {"Rodeo", {225.10,-1684.60,-89.00,312.80,-1501.90,110.90}},
    {"Rodeo", {225.10,-1501.90,-89.00,334.50,-1369.60,110.90}},
    {"Rodeo", {334.50,-1501.90,-89.00,422.60,-1406.00,110.90}},
    {"Rodeo", {312.80,-1684.60,-89.00,422.60,-1501.90,110.90}},
    {"Rodeo", {422.60,-1684.60,-89.00,558.00,-1570.20,110.90}},
    {"Rodeo", {558.00,-1684.60,-89.00,647.50,-1384.90,110.90}},
    {"Rodeo", {466.20,-1570.20,-89.00,558.00,-1385.00,110.90}},
    {"Rodeo", {422.60,-1570.20,-89.00,466.20,-1406.00,110.90}},
    {"Rodeo", {466.20,-1385.00,-89.00,647.50,-1235.00,110.90}},
    {"Rodeo", {334.50,-1406.00,-89.00,466.20,-1292.00,110.90}},
    {"Royal Casino",{2087.30,1383.20,-89.00,2437.30,1543.20,110.90}},
    {"San Andreas Sound",{2450.30,385.50,-100.00,2759.20,562.30,200.00}},
    {"Santa Flora",{-2741.00,458.40,-7.60,-2533.00,793.40,200.00}},
    {"Santa Maria Beach",{342.60,-2173.20,-89.00,647.70,-1684.60,110.90}},
    {"Santa Maria Beach",{72.60,-2173.20,-89.00,342.60,-1684.60,110.90}},
    {"Shady Cabin",{-1632.80,-2263.40,-3.00,-1601.30,-2231.70,200.00}},
    {"Shady Creeks",{-1820.60,-2643.60,-8.00,-1226.70,-1771.60,200.00}},
    {"Shady Creeks",{-2030.10,-2174.80,-6.10,-1820.60,-1771.60,200.00}},
    {"Sobell Rail Yards",{2749.90,1548.90,-89.00,2923.30,1937.20,110.90}},
    {"Spinybed",{2121.40,2663.10,-89.00,2498.20,2861.50,110.90}},
    {"Starfish Casino",{2437.30,1783.20,-89.00,2685.10,2012.10,110.90}},
    {"Starfish Casino",{2437.30,1858.10,-39.00,2495.00,1970.80,60.90}},
    {"Starfish Casino",{2162.30,1883.20,-89.00,2437.30,2012.10,110.90}},
    {"Temple",{1252.30,-1130.80,-89.00,1378.30,-1026.30,110.90}},
    {"Temple",{1252.30,-1026.30,-89.00,1391.00,-926.90,110.90}},
    {"Temple",{1252.30,-926.90,-89.00,1357.00,-910.10,110.90}},
    {"Temple",{952.60,-1130.80,-89.00,1096.40,-937.10,110.90}},
    {"Temple",{1096.40,-1130.80,-89.00,1252.30,-1026.30,110.90}},
    {"Temple",{1096.40,-1026.30,-89.00,1252.30,-910.10,110.90}},
    {"The Camel's Toe",{2087.30,1203.20,-89.00,2640.40,1383.20,110.90}},
    {"The Clown's Pocket",{2162.30,1783.20,-89.00,2437.30,1883.20,110.90}},
    {"The Emerald Isle", {2011.90,2202.70,-89.00,2237.40,2508.20,110.90}},
    {"The Farm",{-1209.60,-1317.10,114.90,-908.10,-787.30,251.90}},
    {"The Four Dragons Casino",{1817.30,863.20,-89.00,2027.30,1083.20,110.90}},
    {"The High Roller",{1817.30,1283.20,-89.00,2027.30,1469.20,110.90}},
    {"The Mako Span",{1664.60,401.70,0.00,1785.10,567.20,200.00}},
    {"The Panopticon",{-947.90,-304.30,-1.10,-319.60,327.00,200.00}},
    {"The Pink Swan",{1817.30,1083.20,-89.00,2027.30,1283.20,110.90}},
    {"The Sherman Dam",{-968.70,1929.40,-3.00,-481.10,2155.20,200.00}},
    {"The Strip", {2027.40,863.20,-89.00,2087.30,1703.20,110.90}},
    {"The Strip", {2106.70,1863.20,-89.00,2162.30,2202.70,110.90}},
    {"The Strip", {2027.40,1783.20,-89.00,2162.30,1863.20,110.90}},
    {"The Strip", {2027.40,1703.20,-89.00,2137.40,1783.20,110.90}},
    {"The Visage",{1817.30,1863.20,-89.00,2106.70,2011.80,110.90}},
    {"The Visage",{1817.30,1703.20,-89.00,2027.40,1863.20,110.90}},
    {"Unity Station",{1692.60,-1971.80,-20.40,1812.60,-1932.80,79.50}},
    {"Valle Ocultado",{-936.60,2611.40,2.00,-715.90,2847.90,200.00}},
    {"Verdant Bluffs",{930.20,-2488.40,-89.00,1249.60,-2006.70,110.90}},
    {"Verdant Bluffs",{1073.20,-2006.70,-89.00,1249.60,-1842.20,110.90}},
    {"Verdant Bluffs",{1249.60,-2179.20,-89.00,1692.60,-1842.20,110.90}},
    {"Verdant Meadows",{37.00,2337.10,-3.00,435.90,2677.90,200.00}},
    {"Verona Beach",{647.70,-2173.20,-89.00,930.20,-1804.20,110.90}},
    {"Verona Beach",{930.20,-2006.70,-89.00,1073.20,-1804.20,110.90}},
    {"Verona Beach",{851.40,-1804.20,-89.00,1046.10,-1577.50,110.90}},
    {"Verona Beach",{1161.50,-1722.20,-89.00,1323.90,-1577.50,110.90}},
    {"Verona Beach",{1046.10,-1722.20,-89.00,1161.50,-1577.50,110.90}},
    {"Vinewood",{787.40,-1310.20,-89.00,952.60,-1130.80,110.90}},
    {"Vinewood",{787.40,-1130.80,-89.00,952.60,-954.60,110.90}},
    {"Vinewood",{647.50,-1227.20,-89.00,787.40,-1118.20,110.90}},
    {"Vinewood",{647.70,-1416.20,-89.00,787.40,-1227.20,110.90}},
    {"Whitewood Estates",{883.30,1726.20,-89.00,1098.30,2507.20,110.90}},
    {"Whitewood Estates",{1098.30,1726.20,-89.00,1197.30,2243.20,110.90}},
    {"Willowfield",{1970.60,-2179.20,-89.00,2089.00,-1852.80,110.90}},
    {"Willowfield",{2089.00,-2235.80,-89.00,2201.80,-1989.90,110.90}},
    {"Willowfield",{2089.00,-1989.90,-89.00,2324.00,-1852.80,110.90}},
    {"Willowfield",{2201.80,-2095.00,-89.00,2324.00,-1989.90,110.90}},
    {"Willowfield",{2541.70,-1941.40,-89.00,2703.50,-1852.80,110.90}},
    {"Willowfield",{2324.00,-2059.20,-89.00,2541.70,-1852.80,110.90}},
    {"Willowfield",{2541.70,-2059.20,-89.00,2703.50,-1941.40,110.90}},
    {"Yellow Bell Station",{1377.40,2600.40,-21.90,1492.40,2687.30,78.00}},
    {"Los Santos",{44.60,-2892.90,-242.90,2997.00,-768.00,900.00}},
    {"Las Venturas",{869.40,596.30,-242.90,2997.00,2993.80,900.00}},
    {"Bone County",{-480.50,596.30,-242.90,869.40,2993.80,900.00}},
    {"Tierra Robada",{-2997.40,1659.60,-242.90,-480.50,2993.80,900.00}},
    {"Tierra Robada",{-1213.90,596.30,-242.90,-480.50,1659.60,900.00}},
    {"San Fierro",{-2997.40,-1115.50,-242.90,-1213.90,1659.60,900.00}},
    {"Red County",{-1213.90,-768.00,-242.90,2997.00,596.30,900.00}},
    {"Flint County",{-1213.90,-2892.90,-242.90,44.60,-768.00,900.00}},
    {"Whetstone", {-2997.40,-2892.90,-242.90,-1213.90,-1115.50,900.00}}
};


new VehicleNames[][] =
{
	"Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel",
	"Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
	"Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
	"Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BF Injection",
	"Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus",
	"Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie",
	"Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral",
	"Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder",
	"Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", "Berkley's RC Van",
	"Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale",
	"Oceanic","Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy",
	"Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX",
	"Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper",
	"Rancher", "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking",
	"Blista Compact", "Police Maverick", "Boxville", "Benson", "Mesa", "RC Goblin",
	"Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher", "Super GT",
	"Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stunt",
	"Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra",
	"FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck", "Fortune",
	"Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer",
	"Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex", "Vincent",
	"Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo",
	"Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite",
	"Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratium",
	"Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito",
	"Freight Flat", "Streak Carriage", "Kart", "Mower", "Dune", "Sweeper",
	"Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400",
	"News Van", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
	"Freight Box", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "LSPD Cruiser",
	"SFPD Cruiser", "LVPD Cruiser", "Police Ranger", "Picador", "S.W.A.T", "Alpha",
	"Phoenix", "Glendale", "Sadler", "Luggage", "Luggage", "Stairs", "Boxville",
	"Tiller", "Utility Trailer"
};

#define		DIALOG_DAMAGE		1927
#define 	FILTERSCRIPT
#define		MAX_DAMAGES			1000
#define     DIALOG_WEAPONS      5193
#define     DIALOG_DRUGS        5194
#define     DIALOG_SONGS	    5199
#define     DIALOG_MAPS      	5200
#define     DIALOG_MAPS2      	5201

#define LANGUAGE_ENGLISH 0
#define LANGUAGE_TURKISH 1
#define LANGUAGE_FRENCH 2
#define LANGUAGE_PORTUGUESE 3
#define LANGUAGE_ESPANOL 4
#define LANGUAGE_OTHER 4

#define		FORMAT:%0(%1)		format(%0, sizeof(%0), %1)

#define 	BODY_PART_GROIN 	4
#define 	BODY_PART_RIGHT_ARM 5
#define 	BODY_PART_LEFT_ARM 	6
#define	 	BODY_PART_RIGHT_LEG 7
#define 	BODY_PART_LEFT_LEG 	8

#define     GAMBLEPOSITION  4800.2798,1250.3073,2.0049,271.5638


#define     BAPESHORTS 20008
#define     GUCCICLOUT 20009
#define     OGPAPA     20010
#define     KFC        20011

//==Events==//
//==================Stock(s)===============
IsNumeric(const string[])
{
	for (new i = 0, j = strlen(string); i < j; i++)
	{
		if (string[i] > '9' || string[i] < '0') return 0;
	}
	return 1;
}
AntiDeAMX()
{
	new a[][] =
	{
		"Unarmed (Fist)",
		"Brass K"
	};
	#pragma unused a
}

SendUsageMessage(playerid, const message[])
{
	new mess[256];
	format(mess, sizeof(mess), "Usage: {FFFFFF}%s", message);
	return SendClientMessage(playerid, COLOR_GREY, mess);
}

GetCoords2DZone(Float:x, Float:y, const zone[], len)
{
    for(new i = 0; i != sizeof(ZonesList); i++)
    {
        if(x >= ZonesList[i][zArea][0] && x <= ZonesList[i][zArea][3] && y >= ZonesList[i][zArea][1] && y <= ZonesList[i][zArea][4])
            return format(zone, len, ZonesList[i][zName], 0);
	}
    return 0;
}

OnDeathCash(playerid, killerid)
{
	switch(Account[killerid][Donator])
	{
		case 0: GivePlayerMoneyEx(killerid, 100);
		case 1: GivePlayerMoneyEx(killerid, 150);
		case 2: GivePlayerMoneyEx(killerid, 250);
		case 3: GivePlayerMoneyEx(killerid, 350);
	}
	GivePlayerMoneyEx(playerid, -50);
}
randomchar()
	return ( random(1000) %2 ==0 ) ? (65 + random(26)) : (97 + random(26));

SetPlayerForwardVelocity(playerid, Float:Velocity, Float:Z)
{
	if(!IsPlayerConnected(playerid)) return 0;

	new Float:Angle;
	new Float:SpeedX, Float:SpeedY;
	GetPlayerFacingAngle(playerid, Angle);
	SpeedX = floatsin(-Angle, degrees);
	SpeedY = floatcos(-Angle, degrees);
	SetPlayerVelocity(playerid, floatmul(Velocity, SpeedX), floatmul(Velocity, SpeedY), Z);

	return 1;
}
VerificationCode(playerid)
{
	new randomnumber;
	randomnumber = Account[playerid][ForumCode] + 200000+random(199991);
	Account[playerid][ForumCode] = randomnumber;

	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE `Accounts` SET `ForumCode` = %d WHERE `SQLID` = %d", randomnumber, Account[playerid][SQLID]));
}

ShowHitMarker(playerid)
{
	if(HitmarkerTimer[playerid] != 0) KillTimer(HitmarkerTimer[playerid]);

	TextDrawShowForPlayer(playerid, HitMark_centre);
	HitmarkerTimer[playerid] = SetTimerEx("HideHitMarker", 250, false, "i", playerid);
}
forward HideHitMarker(playerid);
public HideHitMarker(playerid)
{
	HitmarkerTimer[playerid] = 0;
	TextDrawHideForPlayer(playerid, HitMark_centre);
}

CreateSpacer(playerid, lines)
{
	for(new i = 0; i < lines; i++)
	{
		SendClientMessage(playerid, COLOR_WHITE, "");
	}
	return 1;
}
KeyText(playerid)
{
	new str[128];
	format(str, sizeof(str), "{EE5133}User %s's Keys:{33C4EE} %d", GetName(playerid), Account[playerid][PlayerKeys]);
	KeyCrates = CreatePlayer3DTextLabel(playerid, str, -1,  4773.4414, 1270.6072, 2.2533, 25.0);

}
GiveKey(playerid)
{
	new str[128];
	Account[playerid][PlayerKeys]++;
	format(str, sizeof(str), "{EE5133}User %s's Keys:{33C4EE} %d", GetName(playerid), Account[playerid][PlayerKeys]);
	UpdatePlayer3DTextLabelText(playerid, KeyCrates, -1, str);
	format(str, sizeof(str), "{31AEAA}Reward: {FFFFFF}You have recieved a Premium Key, you now have {31AEAA}%d.", Account[playerid][PlayerKeys]);
	SendClientMessage(playerid, -1, str);
}

forward UpdatePlayerInformation();
public UpdatePlayerInformation()
{
	new str[256];
	format(str, sizeof(str), "{EE5133}Arena Players: {33C4EE}%i\n{EE5133}TDM Players: {33C4EE}%i\n{EE5133}Copchase Players: {33C4EE}%i\n{EE5133}Freeroam Players: {33C4EE}%i\n",
		GetActivityCount(ACTIVITY_ARENADM), GetActivityCount(ACTIVITY_TDM), GetActivityCount(ACTIVITY_COPCHASE), GetActivityCount(ACTIVITY_FREEROAM));
	Update3DTextLabelText(playerinfo, -1, str);
}

forward UpdateKeyText(playerid);
public UpdateKeyText(playerid)
{
	new str[128];
	format(str, sizeof(str), "{EE5133}User %s's Keys:{33C4EE} %d", GetName(playerid), Account[playerid][PlayerKeys]);
	UpdatePlayer3DTextLabelText(playerid, KeyCrates, -1, str);
	return 1;
}
Log(playerid, const string[])
{
	new File:logfile, logentry[255], time[3], date[3], datestr[11], filepath[48];
	gettime(time[0], time[1], time[2]);
	getdate(date[0], date[1], date[2]);
	format(logentry, sizeof logentry, "[%02d:%02d:%02d] %s(%d): %s\r\n", time[0], time[1], time[2], GetName(playerid), playerid, string);
	format(datestr, sizeof datestr, "%02d-%02d-%d", date[2], date[1], date[0]);
	format(filepath, sizeof filepath, LOG_PATH, datestr);
	logfile = fopen(filepath, io_append);

	if(logfile)
	{
		fwrite(logfile, logentry);
		fclose(logfile);
	}
	return 1;
}
forward SendPlayerToFreeroam(playerid);
public SendPlayerToFreeroam(playerid)
{
	SetPlayerPosEx(playerid, 1129.0389, -1488.5541, 22.7690, 0, Account[playerid][FreeroamVW]);
	SetPlayerHealth(playerid, 100);
	ActivityState[playerid] = ACTIVITY_FREEROAM;
	Account[playerid][FreeroamVW] = 1;
	Account[playerid][PreventDamage] = 0;
	return true;
}
Comma(numbers)
{
	new temp[24],counter = -1;
	valstr(temp,numbers);
	for(new i = strlen(temp);i > 0; i--)
	{
		counter++;
		if(counter == 3)
		{
			strins(temp,",",i);
			counter = 0;
		}
	}
	return temp;
}
ShowStatsForPlayer(playerid, clickedplayerid)
{
	new Kill, Death, Float:KD;
	Kill = Account[clickedplayerid][Kills];
	Death = Account[clickedplayerid][Deaths];
	KD = floatdiv(Account[clickedplayerid][Kills], Account[clickedplayerid][Deaths]);

	StatsLine(playerid);
	SendClientMessage(playerid, COLOR_GRAY, sprintf("{808080}Showing statistics for registered user: %s (UserID: %d)", GetName(clickedplayerid), Account[clickedplayerid][SQLID]));
	SendClientMessage(playerid, COLOR_GRAY, sprintf("{808080}Donator Rank: {FFFFFF}%s{808080} | Name Changes: {FFFFFF}%d{808080} | Cash: {FFFFFF}$%s{808080}", DonatorRank(clickedplayerid), Account[clickedplayerid][NameChanges], Comma(Account[clickedplayerid][Cash]), Account[clickedplayerid][Skin]));
	SendClientMessage(playerid, COLOR_GRAY, sprintf("{808080}Kills: {FFFFFF}%d{808080} | Deaths: {FFFFFF}%d{808080} | Headshots: {FFFFFF}%d{808080} | K/D Ratio: {FFFFFF}%.2f", Kill, Death, Account[clickedplayerid][Headshots], KD));
	SendClientMessage(playerid, COLOR_GRAY, sprintf("{808080}Premium Keys: {FFFFFF}%d{808080} | Events: {FFFFFF}%d{808080} | Crates Opened: {FFFFFF}%d{808080} | Events Started: {FFFFFF}%d{808080}", Account[clickedplayerid][PlayerKeys], Account[clickedplayerid][PlayerEvents], Account[clickedplayerid][OpenedCrates], Account[clickedplayerid][EventsStarted]));
	SendClientMessage(playerid, COLOR_GRAY, sprintf("{808080}Events Won: {FFFFFF}%d{808080} | Verified User: {FFFFFF}%s{808080}", Account[clickedplayerid][EventsWon], VerifiedCheck(clickedplayerid)));
	SendClientMessage(playerid, COLOR_GRAY, sprintf("{808080}Hours: {FFFFFF}%d{808080} | Minutes: {FFFFFF}%d{808080} | Seconds: {FFFFFF}%d{808080}", Account[clickedplayerid][Hours], Account[clickedplayerid][Minutes], Account[clickedplayerid][Seconds]));	
	SendClientMessage(playerid, COLOR_GRAY, sprintf("{808080}Mutes: {FFFFFF}%d{808080} | Kicks: {FFFFFF}%d{808080} | Forced Rules: {FFFFFF}%d{808080}", Account[clickedplayerid][Mutes], Account[clickedplayerid][Kicks], Account[clickedplayerid][ForcedRules]));
	SendClientMessage(playerid, COLOR_GRAY, sprintf("{808080}KDM Tokens: {FFFFFF}%d{808080} | Rare Skins: {FFFFFF}%d{808080} | Rare Items: {FFFFFF}%d{808080}", Account[clickedplayerid][Tokens], Account[clickedplayerid][RareSkins], Account[clickedplayerid][RareItems]));
	if(GetPlayerAdminLevel(playerid) > 0) SendClientMessage(playerid, COLOR_GRAY, sprintf("{808080}Admin Hours: {FFFFFF}%d{808080} | Admin Actions: {FFFFFF}%d{808080}", Account[clickedplayerid][AdminHours], Account[clickedplayerid][AdminActions]));
	StatsLine(playerid);
	InfoBoxForPlayer(playerid, "~g~Loaded user statistics!");
}

PreloadAnimLib(playerid, const animlib[])
{
	ApplyAnimation(playerid,animlib,"null",0.0,0,0,0,0,0,1);
}

GiveAllKey()
{
	foreach(new i: Player)
	{
		GiveKey(i);
	}
	return 1;
}

forward SendRandomMessage();
public SendRandomMessage()
{
	static const randomMessages[][] =  //here, we're creating the array with the name "randomMessages"
	{
		"[Koky's Deathmatch]{FFFFFF}: Did you know? There is a 1 in 100 chance of receiving a Premium Key upon killing another player!", //this is the text of your second message
		"[Koky's Deathmatch]{FFFFFF}: Want a custom skin? Use /skinroll in the lobby!",
		"[Koky's Deathmatch]{FFFFFF}: Got an idea in mind? Suggest it on our forums. (www.kokysdm.com)",
		"[Koky's Deathmatch]{FFFFFF}: Use /top to view the top kills, headshots and deaths!",
		"[Koky's Deathmatch]{FFFFFF}: You can duel your friend and foes, use /duel!",
		"[Koky's Deathmatch]{FFFFFF}: Not having fun? Start your own event! (/startevent)",
		"[Koky's Deathmatch]{FFFFFF}: Double click on a players name to view their stats in the tablist!",
		"[Koky's Deathmatch]{FFFFFF}: Did you know? You can donate to the server and receive perks! (/donate)",
		"[Koky's Deathmatch]{FFFFFF}: Join our official Discord! discord.gg/TCVdvdV",
		"[Koky's Deathmatch]{FFFFFF}: Did you know? You can start your own clan and make it official! /createclan!"
	};

	SendClientMessageToAll(COLOR_LIGHTBLUE, randomMessages[ random(sizeof(randomMessages)) ]);
}

main()
{
	print("------------------------------------------------------------------------------");
	print("|                       Koky's Deathmatch Loaded								|");
	print("------------------------------------------------------------------------------");
}

public OnGameModeExit()
{
	mysql_close(SQL_CONNECTION);
	mysql_close(SQL_FORUM);
	return 1;
}
public OnGameModeInit()
{
	SetCbugAllowed(false);

	MySQLConnect();
	RegisterCallbackHooks();

	CreateSessionBox();

	//set gamemode text
	SetGameModeText("NOT CONNECTED");

	//enable arena
	EnableArenas = 1;

	CreateLobbyActors();

	LoadSkins();
	MonthlyKeyText();
	LatestDonatorText();
	CheckMonthlyDeathmatcher();
	EnableStuntBonusForAll(0);
	DisableInteriorEnterExits();
	SetNameTagDrawDistance(50.0);
	CreateServerTextDraws();
	EnableVehicleFriendlyFire();

	//"hooks"
	InitDuelArenas();
	InitTDM();
	SpawnAllClanVehicles();
	SkinRollInit();
	InitServerHub();
	ArenaInit();

	//timers
	SetTimer("UpdatePlayerInformation", 1000, true);
	SetTimer("SendRandomMessage", 60000, true);
	SetTimer("SecondCheck", 1000, true);

	mysql_tquery(SQL_CONNECTION, "SELECT * FROM `serversettings` LIMIT 1", "LoadSettings");

	new ClockHours;
	gettime(ClockHours);
	SetWorldTime(ClockHours);

	AddPlayerClass(1, -318.6522, 1049.3909, 20.3403, 358.4333, 0, 0, 0, 0, 0, 0);
	return 1;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(!IsPlayerInLobby(playerid))
	{
		Account[playerid][ShotsFired]++;
		if(hittype != BULLET_HIT_TYPE_PLAYER)
		{
			Account[playerid][ShotsMissed]++;
		}
		else Account[playerid][ShotsHit]++;
	}
	return 1;
}
public OnPlayerRequestDownload(playerid, type, crc)
{
	new filename[128], filefound;

	if(type == DOWNLOAD_REQUEST_TEXTURE_FILE) filefound = FindTextureFileNameFromCRC(crc, filename, 128);
	else if(type == DOWNLOAD_REQUEST_MODEL_FILE) filefound = FindModelFileNameFromCRC(crc, filename, 128);

	if(filefound)
	{
		strreplace(filename, " ", "%20");
		RedirectDownload(playerid, sprintf("https://kokysdm.net/samp/%s", filename));
	}
	return false;
}

forward HttpResponse(playerid, responseCode, data[]);

new dmessage2[MAX_PLAYERS];
public OnPlayerConnect(playerid)
{
	CreateSpacer(playerid, 128);
	CreateSessionStats(playerid);
	CreateNetworkTDs(playerid);
	SetPlayerVirtualWorld(playerid, 1);
	SetPlayerVirtualWorld(playerid, 0);

	ClearPlayerData(playerid);
	ResetPlayerVariables(playerid);

	AllowPMS{playerid} = true;

	Account[playerid][CheckingFPS] = -1;

	Account_Reset(playerid);
	SetPlayerColor(playerid, PlayerColors[playerid % sizeof PlayerColors]);
	SendClientMessageToAll(COLOR_GRAY, sprintf("{31AEAA}Connection: {%06x}%s {ffffff}has joined the server.", GetPlayerColor(playerid) >>> 8, GetName(playerid)));
	TogglePlayerSpectating(playerid, 1);
	SetPlayerColor(playerid, PlayerColors[playerid % sizeof PlayerColors]);
	dmessage2[playerid] = SetTimerEx("CheckDonations", 30000, true, "i", playerid);
	KeyText(playerid);
	Account[playerid][Color] = GetPlayerColor(playerid);
	DialogOptions[playerid] = list_new();

	PreloadAnimLib(playerid,"AIRPORT");
	PreloadAnimLib(playerid,"AIRPORT");
	PreloadAnimLib(playerid,"Attractors");
	PreloadAnimLib(playerid,"BAR");
	PreloadAnimLib(playerid,"BASEBALL");
	PreloadAnimLib(playerid,"BD_FIRE");
	PreloadAnimLib(playerid,"benchpress");
	PreloadAnimLib(playerid,"BF_injection");
	PreloadAnimLib(playerid,"BIKED");
	PreloadAnimLib(playerid,"BIKEH");
	PreloadAnimLib(playerid,"BIKELEAP");
	PreloadAnimLib(playerid,"BIKES");
	PreloadAnimLib(playerid,"BIKEV");
	PreloadAnimLib(playerid,"BIKE_DBZ");
	PreloadAnimLib(playerid,"BMX");
	PreloadAnimLib(playerid,"BOX");
	PreloadAnimLib(playerid,"BSKTBALL");
	PreloadAnimLib(playerid,"BUDDY");
	PreloadAnimLib(playerid,"BUS");
	PreloadAnimLib(playerid,"CAMERA");
	PreloadAnimLib(playerid,"CAR");
	PreloadAnimLib(playerid,"CAR_CHAT");
	PreloadAnimLib(playerid,"CASINO");
	PreloadAnimLib(playerid,"CHAINSAW");
	PreloadAnimLib(playerid,"CHOPPA");
	PreloadAnimLib(playerid,"CLOTHES");
	PreloadAnimLib(playerid,"COACH");
	PreloadAnimLib(playerid,"COLT45");
	PreloadAnimLib(playerid,"COP_DVBYZ");
	PreloadAnimLib(playerid,"CRIB");
	PreloadAnimLib(playerid,"DAM_JUMP");
	PreloadAnimLib(playerid,"DANCING");
	PreloadAnimLib(playerid,"DILDO");
	PreloadAnimLib(playerid,"DODGE");
	PreloadAnimLib(playerid,"DOZER");
	PreloadAnimLib(playerid,"DRIVEBYS");
	PreloadAnimLib(playerid,"FAT");
	PreloadAnimLib(playerid,"FIGHT_B");
	PreloadAnimLib(playerid,"FIGHT_C");
	PreloadAnimLib(playerid,"FIGHT_D");
	PreloadAnimLib(playerid,"FIGHT_E");
	PreloadAnimLib(playerid,"FINALE");
	PreloadAnimLib(playerid,"FINALE2");
	PreloadAnimLib(playerid,"Flowers");
	PreloadAnimLib(playerid,"FOOD");
	PreloadAnimLib(playerid,"Freeweights");
	PreloadAnimLib(playerid,"GANGS");
	PreloadAnimLib(playerid,"GHANDS");
	PreloadAnimLib(playerid,"GHETTO_DB");
	PreloadAnimLib(playerid,"goggles");
	PreloadAnimLib(playerid,"GRAFFITI");
	PreloadAnimLib(playerid,"GRAVEYARD");
	PreloadAnimLib(playerid,"GRENADE");
	PreloadAnimLib(playerid,"GYMNASIUM");
	PreloadAnimLib(playerid,"HAIRCUTS");
	PreloadAnimLib(playerid,"HEIST9");
	PreloadAnimLib(playerid,"INT_HOUSE");
	PreloadAnimLib(playerid,"INT_OFFICE");
	PreloadAnimLib(playerid,"INT_SHOP");
	PreloadAnimLib(playerid,"JST_BUISNESS");
	PreloadAnimLib(playerid,"KART");
	PreloadAnimLib(playerid,"KISSING");
	PreloadAnimLib(playerid,"KNIFE");
	PreloadAnimLib(playerid,"LAPDAN1");
	PreloadAnimLib(playerid,"LAPDAN2");
	PreloadAnimLib(playerid,"LAPDAN3");
	PreloadAnimLib(playerid,"LOWRIDER");
	PreloadAnimLib(playerid,"MD_CHASE");
	PreloadAnimLib(playerid,"MEDIC");
	PreloadAnimLib(playerid,"MD_END");
	PreloadAnimLib(playerid,"MISC");
	PreloadAnimLib(playerid,"MTB");
	PreloadAnimLib(playerid,"MUSCULAR");
	PreloadAnimLib(playerid,"NEVADA");
	PreloadAnimLib(playerid,"ON_LOOKERS");
	PreloadAnimLib(playerid,"OTB");
	PreloadAnimLib(playerid,"PARACHUTE");
	PreloadAnimLib(playerid,"PARK");
	PreloadAnimLib(playerid,"PAULNMAC");
	PreloadAnimLib(playerid,"PED");
	PreloadAnimLib(playerid,"PLAYER_DVBYS");
	PreloadAnimLib(playerid,"PLAYIDLES");
	PreloadAnimLib(playerid,"POLICE");
	PreloadAnimLib(playerid,"POOL");
	PreloadAnimLib(playerid,"POOR");
	PreloadAnimLib(playerid,"PYTHON");
	PreloadAnimLib(playerid,"QUAD");
	PreloadAnimLib(playerid,"QUAD_DBZ");
	PreloadAnimLib(playerid,"RIFLE");
	PreloadAnimLib(playerid,"RIOT");
	PreloadAnimLib(playerid,"ROB_BANK");
	PreloadAnimLib(playerid,"ROCKET");
	PreloadAnimLib(playerid,"RUSTLER");
	PreloadAnimLib(playerid,"RYDER");
	PreloadAnimLib(playerid,"SCRATCHING");
	PreloadAnimLib(playerid,"SHAMAL");
	PreloadAnimLib(playerid,"SHOTGUN");
	PreloadAnimLib(playerid,"SILENCED");
	PreloadAnimLib(playerid,"SKATE");
	PreloadAnimLib(playerid,"SPRAYCAN");
	PreloadAnimLib(playerid,"STRIP");
	PreloadAnimLib(playerid,"SUNBATHE");
	PreloadAnimLib(playerid,"SWAT");
	PreloadAnimLib(playerid,"SWEET");
	PreloadAnimLib(playerid,"SWIM");
	PreloadAnimLib(playerid,"SWORD");
	PreloadAnimLib(playerid,"TANK");
	PreloadAnimLib(playerid,"TATTOOS");
	PreloadAnimLib(playerid,"TEC");
	PreloadAnimLib(playerid,"TRAIN");
	PreloadAnimLib(playerid,"TRUCK");
	PreloadAnimLib(playerid,"UZI");
	PreloadAnimLib(playerid,"VAN");
	PreloadAnimLib(playerid,"VENDING");
	PreloadAnimLib(playerid,"VORTEX");
	PreloadAnimLib(playerid,"WAYFARER");
	PreloadAnimLib(playerid,"WEAPONS");
	PreloadAnimLib(playerid,"WUZI");
	PreloadAnimLib(playerid,"SNM");
	PreloadAnimLib(playerid,"BLOWJOBZ");
	PreloadAnimLib(playerid,"SEX");
	PreloadAnimLib(playerid,"BOMBER");
	PreloadAnimLib(playerid,"RAPPING");
	PreloadAnimLib(playerid,"SHOP");
	PreloadAnimLib(playerid,"BEACH");
	PreloadAnimLib(playerid,"SMOKING");
	PreloadAnimLib(playerid,"FOOD");
	PreloadAnimLib(playerid,"ON_LOOKERS");
	PreloadAnimLib(playerid,"DEALER");
	PreloadAnimLib(playerid,"CRACK");
	PreloadAnimLib(playerid,"CARRY");
	PreloadAnimLib(playerid,"COP_AMBIENT");
	PreloadAnimLib(playerid,"PARK");
	PreloadAnimLib(playerid,"INT_HOUSE");
	PreloadAnimLib(playerid,"FOOD");

	//farm arena building removals
	RemoveBuildingForPlayer(playerid, 11618, -688.117, 939.179, 11.125, 0.250);
	RemoveBuildingForPlayer(playerid, 11654, -681.875, 965.890, 11.125, 0.250);
	RemoveBuildingForPlayer(playerid, 11491, -688.109, 928.132, 12.625, 0.250);
	RemoveBuildingForPlayer(playerid, 11490, -688.117, 939.179, 11.125, 0.250);
	RemoveBuildingForPlayer(playerid, 11631, -691.593, 942.718, 13.875, 0.250);
	RemoveBuildingForPlayer(playerid, 11663, -688.117, 939.179, 11.125, 0.250);
	RemoveBuildingForPlayer(playerid, 11666, -688.140, 934.820, 14.390, 0.250);
	RemoveBuildingForPlayer(playerid, 11664, -685.093, 941.914, 13.140, 0.250);
	RemoveBuildingForPlayer(playerid, 11665, -685.171, 935.695, 13.320, 0.250);
	RemoveBuildingForPlayer(playerid, 11492, -681.875, 965.890, 11.125, 0.250);
	RemoveBuildingForPlayer(playerid, 691, -701.742, 1006.130, 11.585, 0.250);
	RemoveBuildingForPlayer(playerid, 691, -665.890, 1004.179, 11.585, 0.250);
	RemoveBuildingForPlayer(playerid, 691, -652.554, 999.906, 11.585, 0.250);
	RemoveBuildingForPlayer(playerid, 691, -619.968, 1019.429, 8.570, 0.250);
	RemoveBuildingForPlayer(playerid, 705, -621.859, 985.890, 8.078, 0.250);
	RemoveBuildingForPlayer(playerid, 691, -773.992, 813.593, 11.375, 0.250);
	RemoveBuildingForPlayer(playerid, 705, -756.351, 871.156, 10.929, 0.250);

	PlayerSecondTimer[playerid] = SetTimerEx("PlayerSecond", 1000, true, "i", playerid);
	CreatePlayerTextDraws(playerid);

	new ip[16];
	GetPlayerIp(playerid, ip, sizeof(ip));

	if(MultiConnection(ip, playerid))
	{
		SendClientMessage(playerid, COLOR_WHITE, "There are more than 2 connection with your same IP.");
		Dialog_Show(playerid, NONE, DIALOG_STYLE_MSGBOX, "Information", "There are more than 2 connection with your same IP.", "Close", "");
		Account[playerid][LoggedIn] = 0;
		KickPlayer(playerid);
	}
    //GetPlayerIp(playerid, ip, sizeof(ip));

	//SendClientMessageToAll(COLOR_RED, sprintf("IP: %s", ip));
	
    //format(url, sizeof(url), "check.getipintel.net/check.php?ip=%s&contact=cataplasia@protonmail.ch", ip);
	//SendClientMessageToAll(COLOR_RED, url);
    //HTTP(playerid, HTTP_GET, url, "", "HttpResponse");
	return 1;
}
forward MultiConnection(ip[], id);
public MultiConnection(ip[], id)
{
	new add[16], count = 0;
	foreach(new p : Player)
	{
		if(p == id) continue;

		GetPlayerIp(p, add, sizeof(add));

		if(!strcmp(add, ip, false)) count++;

		if(count >= 2) return 1;
	}
	return 0;
}

public HttpResponse(playerid, responseCode, data[])
{
	if(responseCode == 200)
	{
		SendClientMessageToAll(COLOR_RED, data);

		new Float:value = floatstr(data);
		if(value >= 0.99) {
        	new ip[16];
        	GetPlayerIp(playerid, ip, sizeof(ip));
        	//SendAdminsMessage(1, COLOR_LIGHTRED, sprintf("WARNING: %s (ID %d) has connected with a proxy/VPN! (%s)", GetName(playerid), playerid, ip));
        	Account[playerid][pVPN] = 1;
    	}
		new Float:proxyPercentage;
    	proxyPercentage = value;
    	Account[playerid][pVPN] = proxyPercentage;
	}
	else {
		SendClientMessageToAll(COLOR_RED, sprintf("connect failed %d", responseCode));
		SendClientMessageToAll(COLOR_RED, data);
	}
	return 1; 
}

Unban_Dialog(playerid)
{
	new str[128];
	format(str, sizeof(str), "{FFFFFF}Hello Admin %s!\n\nYou are about to unban a user.\n{D69929}Make sure you have locked and move the thread.", GetName(playerid));
	Dialog_Show(playerid, UNBAN, DIALOG_STYLE_INPUT, "Administrator | Unban", str, "Unban", "Cancel");
	return 1;
}

Forum_Dialog(playerid)
{
	new str[400];
	format(str, sizeof(str), "{FFFFFF}Hello, %s!\n\nIt is important for you to add your forum account to your in-game account, this cannot be changed so please be correct.\nThis will allow you to receive purchases made on the forums such as Account Upgrades instant.\nIf you also win a giveaway, you will instantly get your item(s).", GetName(playerid));
	Dialog_Show(playerid, FORUM, DIALOG_STYLE_INPUT, "Koky's Deathmatch | wwww.kokysdm.com/forum", str, "Input", "Cancel");
}
UserGroup_Dialog(playerid)
{
	new str[400];
	format(str, sizeof(str), "{FFFFFF}Hello, %s, please input a forum username to receive their usergroup ID's.", GetName(playerid));
	Dialog_Show(playerid, USERGROUP, DIALOG_STYLE_INPUT, "Usergroup ID Finder", str, "Find", "Cancel");
}

forward ShowVerificationDialog(playerid);
public ShowVerificationDialog(playerid)
{
	new str[400];
	format(str, sizeof(str), "{FFFFFF}Hello, %s!\n\nThank you for inputting your Forum name!\nWe have sent a verification code to your Forum account.\nClick the Verify My Account on top of the forums.", GetName(playerid));
	mysql_pquery_s(SQL_FORUM, str_format("INSERT INTO xf_user_field_value (user_id, field_id, field_value) VALUES(%d, 'security', %i)", Account[playerid][ForumID], Account[playerid][ForumCode]));
	Dialog_Show(playerid, VERIFICATION, DIALOG_STYLE_INPUT, "Koky's Deathmatch | Verification", str, "Input", "Cancel");
}

Dialog:RULES(playerid, response, listitem, inputtext[])
{
	if(!response){ Dialog_Show(playerid, RULES, DIALOG_STYLE_MSGBOX, "Forced Rules", "1. {FFFFFF}No third party modifications\n2. {FFFFFF}No bug abuse(c-roll, c-bug, c-shoot-c)\n3. {FFFFFF}No racism\n4. {FFFFFF}English only\n5. {FFFFFF}Abuse of commands (/lobby to avoid death)", "Okay", "Close");}
	if(response)
	{
		if(Account[playerid][ForcedRules1] == 1)
		{
			Dialog_Show(playerid, RULES, DIALOG_STYLE_MSGBOX, "Forced Rules", "1. {FFFFFF}No third party modifications\n2. {FFFFFF}No bug abuse(c-roll, c-bug, c-shoot-c)\n3. {FFFFFF}No racism\n4. {FFFFFF}English only\n5. {FFFFFF}Abuse of commands (/lobby to avoid death)", "Okay", "Close");
		}
		if(Account[playerid][ForcedRules1] == 0)
		{
			return 0;
		}
	}
	return 1;
}
Dialog:UPGRADE(playerid, response, listitem, inputtext[])
{
	if(!response) return 0;
	if(response)
	{
		return 1;
	}
	return 1;
}
Dialog:FORUM(playerid, response, listitem, inputtext[])
{
	if(!response) return true;

	await mysql_aquery_s(SQL_FORUM, str_format("SELECT user_id FROM xf_user WHERE username = '%e'", inputtext));
	if(!cache_num_rows()) return SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Notice: {FFFFFF}This forum name does not exist in our database.");

	cache_get_value_name_int(0, "user_id", Account[playerid][ForumID]);
	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE `Accounts` SET `ForumID` = %d WHERE SQLID = %d LIMIT 1", Account[playerid][ForumID], Account[playerid][SQLID]));
	VerificationCode(playerid);
	SetTimerEx("ShowVerificationDialog", 500, false, "d", playerid);
	return 1;
}
ResetForumVerification(playerid)
{
	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE `Accounts` SET `Verified` = 0, `ForumID` = 0, `ForumCode` = 0 WHERE SQLID = %d LIMIT 1", Account[playerid][SQLID]));
	mysql_pquery_s(SQL_FORUM, str_format("DELETE FROM `xf_user_field_value` WHERE field_id = 'security' and user_id = %d", Account[playerid][ForumID]));
	SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Notice: {FFFFFF}The code you have entered is incorrect, try again and make sure the information given is correct.");
	Account[playerid][ForumID] = 0;
	Account[playerid][Verified] = 0;
	Account[playerid][ForumCode] = 0;
	return 1;
}
Dialog:VERIFICATION(playerid, response, listitem, inputtext[])
{
	if(!response) return ResetForumVerification(playerid);
	if(strval(inputtext) != Account[playerid][ForumCode]) return ResetForumVerification(playerid);

	Account[playerid][Verified] = Account[playerid][ForumCode];
	SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Notice: {FFFFFF}Your account is now verified, thank you for taking your time to verify your account. You have been given $10000 and 1 Premium Key.");
	Account[playerid][PlayerKeys] = Account[playerid][PlayerKeys] +1;
	SendAdminsMessage(1, COLOR_GRAY, sprintf("{E13030}[ ADMINOTICE ] %s has just verified his forum account. (Forum ID: %d)", GetName(playerid), Account[playerid][ForumID]));
	GivePlayerMoneyEx(playerid, 10000);
	UpdateKeyText(playerid);
	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE `Accounts` SET `Verified` = %i WHERE SQLID = %d LIMIT 1", Account[playerid][ForumCode], Account[playerid][SQLID]));
	return 1;
}
forward CheckDonations(playerid);
public CheckDonations(playerid)
{
	await mysql_aquery_s(SQL_CONNECTION, str_format("SELECT * FROM `donations` WHERE `username` = '%e' AND `received` = '0'", GetName(playerid)));
	if(!cache_num_rows()) return true;

	new Float:euro, donationid;
	cache_get_value_name_float(0, "amount", euro);
	cache_get_value_name_int(0, "donation_id", donationid);

	Account[playerid][DonationAmount] = floatadd(Account[playerid][DonationAmount], euro);
	SendClientMessageToAll(COLOR_LIGHTRED, sprintf("Donation: {%06x}%s {FFFFFF}has just donated {F6546A}%.2f Euro {FFFFFF}to the server! They may now purchase items via /usedonations!", GetPlayerColor(playerid) >>> 8, GetName(playerid), euro));
	SendClientMessage(playerid, COLOR_LIGHTRED, sprintf("Notice: {FFFFFF}Thank you for donating, you now have %.2f Euro to spend in /usedonations!", Account[playerid][DonationAmount]));
	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE `donations` SET `received` = '1' WHERE `donation_id` = %i", donationid));
	UpdateLatestDonator(playerid);
	return 1;
}

forward SecondCheck();
public SecondCheck()
{
	if(EventJoinable == true)
	{
		foreach(new p : EventPlayers) if(EventTimers >= 0)
		{
			new string[128];
			format(string, sizeof(string),  "%d_seconds", EventTimers - 1);
			PlayerTextDrawSetString(p, Account[p][TextDraw][1], string);
			PlayerTextDrawShow(p, Account[p][TextDraw][1]);
			PlayerTextDrawShow(p, Account[p][TextDraw][0]);
		}
		EventTimers--;
	}

	if(EventType == EVENT_HEADSHOTSONLY && EventTime >= 0)
	{
		new string[128];
		foreach(new p : EventPlayers)
		{
			if(EventTime > 60)
				format(string, sizeof(string), "%d_minutes_%d_seconds", EventTime / 60, EventTime % 60);
			else
				format(string, sizeof(string), "%d_seconds", EventTime);

			PlayerTextDrawSetString(p, Account[p][TextDraw][3], string);
			PlayerTextDrawShow(p, Account[p][TextDraw][3]);
		}

		EventTime--;
	}

	if(!copchaseStatus && GetCopchaseTotalPlayers() < 2 && copchaseTimer != COPCHASE_START_TIMER) copchaseTimer = COPCHASE_START_TIMER;
	else if(!copchaseStatus && GetCopchaseTotalPlayers() > 1)
	{
		foreach(new p : Player) if(Account[p][pCopchase] == 1)
		{
			new string[128];
			format(string, sizeof(string),  "%d_seconds", copchaseTimer - 1);
			PlayerTextDrawSetString(p, Account[p][TextDraw][1], string);
			PlayerTextDrawShow(p, Account[p][TextDraw][1]);
			PlayerTextDrawShow(p, Account[p][TextDraw][0]);
		}

		copchaseTimer--;

		/*if(copchaseTimer <= 5)
		{
			new timerMsg[128];
			format(timerMsg, sizeof(timerMsg), "%d seconds left until game starts.", copchaseTimer);
			SendCopchaseMessage(timerMsg);
		}*/
		
		if(copchaseTimer <= 0)
		{
			StartCopchase();
		}
	}

	if(copchaseStatus == 1) // PLAYERS ARE IN THE CARS
	{
		foreach(new p : Player) if(Account[p][pCopchase] == 2 || Account[p][pCopchase] == 3)
		{
			new string[128];
			format(string, sizeof(string),  "%d_seconds", copchaseTimer - 1);
			PlayerTextDrawSetString(p, Account[p][TextDraw][1], string);
			PlayerTextDrawShow(p, Account[p][TextDraw][1]);
			PlayerTextDrawShow(p, Account[p][TextDraw][0]);
		}

		copchaseTimer--;
		if(copchaseTimer <= 0)
		{
			StartCopchase();
		}
	}

	if(copchaseStatus == 2) // GAME IS RUNNING
	{
		StartCopchase(); // checking if game is over
		copchaseTimer--;
		if(copchaseTimer <= 0)
		{
			StartCopchase(true); // ending it.
			return 1;
		}

		if(copchaseTimer % 60 == 0 && copchaseTimer < 600)
		{
			new criminal = GetCopchaseCriminal();

			if(criminal != -1)
			{
				new location[MAX_ZONE_NAME], Float:x, Float:y, Float:z;

				GetPlayerPos(criminal, x, y, z);
				GetCoords2DZone(x, y, location, MAX_ZONE_NAME);

				foreach(new p : Player) if(Account[p][pCopchase] == 2)
				{
					SetPlayerMarkerForPlayer(p, criminal, 0xFF0000FF);
					SetTimerEx("CopchaseHideCriminal", 5000, false, "d", p);
					SendClientMessage(p, COLOR_ORANGE, sprintf("[POLICE RADIO] Dispatch: The criminal has been seen around %s!", location));
				}
			}
		}

		new string[64];
		if(copchaseTimer > 60)
			format(string, sizeof(string), "%d_minutes_%d_seconds", copchaseTimer / 60, copchaseTimer % 60);
		else
			format(string, sizeof(string), "%d_seconds", copchaseTimer);

		foreach(new p : Player)
		{
			if(Account[p][pCopchase] == 2 || Account[p][pCopchase] == 3){
				PlayerTextDrawSetString(p, Account[p][TextDraw][3], string);
				PlayerTextDrawShow(p, Account[p][TextDraw][3]);
				if(Ytimer[p] > 0)
					Ytimer[p]--;
			}
		}
	}
	return 1;
}

forward CopchaseHideCriminal(playerid); public CopchaseHideCriminal(playerid)
{
	new criminal = GetCopchaseCriminal();

	SetPlayerMarkerForPlayer(playerid, criminal, GetPlayerColor(criminal) & 0xFFFFFF00);

	return 1;
}

forward PlayerSecond(playerid);
public PlayerSecond(playerid)
{
	if(Account[playerid][pAFKTime] > 5 && Account[playerid][pCopchase] == 1)
	{
		cmd_copchase(9999, playerid);
		SendErrorMessage(playerid, "You were kicked from the Copchase queue because you were AFK.");
	}

	if(Account[playerid][LoggedIn] == 0) return;

	MessageAmount[playerid] -= 1;

	Account[playerid][Seconds]++;
	if(Account[playerid][Seconds] >= 60)
	{
		Account[playerid][Seconds] = 0;
		Account[playerid][Minutes]++;

		if(Account[playerid][Muted] != 0)
		{
			Account[playerid][Muted] --;
			if(Account[playerid][Muted] == 0)
			{
				SendClientMessage(playerid, -1, "{31AEAA}Notice: {FFFFFF}Your mute timer has expired. You may now use the chat feature.");
			}
		}
		if(Account[playerid][AJailTime] != 0)
		{
			Account[playerid][AJailTime] --;
			if(Account[playerid][AJailTime] == 0)
			{
				SendClientMessage(playerid, -1, "{31AEAA}Notice: {FFFFFF}You have served your time in admin-jail.");
				Account[playerid][AJailTime] = 0;
				SendPlayerToLobby(playerid);

				mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE Accounts SET ajail_minutes = 0 WHERE SQLID = %i", Account[playerid][SQLID]));
			}
			else SendClientMessage(playerid, -1, sprintf("{31AEAA}A-Jail: {FFFFFF}You have {31AEAA}%d {FFFFFF}minute(s) left in admin-jail.", Account[playerid][AJailTime]));
		}

		if(Account[playerid][Minutes] >= 60)
		{
			Account[playerid][Minutes] = 0;
			Account[playerid][Hours]++;
			if(GetPlayerAdminLevel(playerid) > 0)
			{
				Account[playerid][AdminHours]++;
			}
		}
	}

	if(IsPlayerInAnyVehicle(playerid))
	{
		new v = GetPlayerVehicleID(playerid), Float:health;
		GetVehicleHealth(v, health);

		if(health <= 250.0)
		{
			SetVehicleHealth(v, 1000);
			SetVehicleParamsEx(v, 0, 0, 0, 1, 1, 0, 1);
			UpdateVehicleDamageStatus(v, 15, 000111111111, 68, 15);
			SetTimerEx("RespawnBrokenVeh", 10000, false, "d", v);

			RemovePlayerFromVehicle(playerid);
			SendClientMessage(playerid, COLOR_LIGHTRED, "The car broke down! It will respawn in 10 seconds.");
		}
	}
	UpdateNetworkdTDs(playerid);
	CheckPlayerWeapons(playerid);
	if(ActivityState[playerid] == ACTIVITY_TDM) DrivebyCheck(playerid);

	Account[playerid][pAFKTime]++;
}

public OnPlayerDisconnect(playerid, reason)
{
	Character_Save(playerid);
	ClearPlayerData(playerid);
	ResetPlayerVariables(playerid);
	return 1;
}

ClearPlayerData(playerid)
{
	if(dmessage[playerid] != 0) KillTimer(dmessage[playerid]);
	if(dmessage2[playerid] != 0) KillTimer(dmessage2[playerid]);
	if(PlayerSecondTimer[playerid] != 0) KillTimer(PlayerSecondTimer[playerid]);
	if(SpawnProtTimer[playerid] != 0) KillTimer(SpawnProtTimer[playerid]);
	if(list_valid(DialogOptions[playerid])) list_delete(DialogOptions[playerid]);

	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE Accounts SET LoggedIn = 0 WHERE SQLID = %d", Account[playerid][SQLID]));
	return 1;
}

ResetPlayerVariables(playerid)
{
	if(ACTimer[playerid] != 0) KillTimer(ACTimer[playerid]);

	new data[acc];
	Account[playerid] = data;
	Account[playerid][Cash] = 1337;
	Account[playerid][CheckingFPS] = -1;
	Account[playerid][Hitmark] = 1;
	Account[playerid][LobbyWeapon] = 24;
	Account[playerid][LoggedIn] = 1;
	Account[playerid][Skin] = 36;

	ACTimeout{playerid} = false;
	ACTimer[playerid] = 0;
	dmessage[playerid] = 0;
	FlinchCount[playerid] = 0;
	inAmmunation[playerid] = 0;
	LastAnimation[playerid] = 0;
	LastHit[playerid] = INVALID_PLAYER_ID;
	LastMessage[playerid]{0} = EOS;
	MessageAmount[playerid] = 0;
	PauseTick[playerid] = 0;
	pendinginvite[playerid] = -1;
	PlayerSecondTimer[playerid] = 0;
	PMReply[playerid] = -1;
	TimesHit[playerid] = 0;
	WeaponACTriggers[playerid] = 0;

	ActivityState[playerid] = 0;
	ActivityStateID[playerid] = -1;

	InfoBox[playerid] = PlayerText:INVALID_TEXT_DRAW;
	InfoBoxOS[playerid] = PlayerText:INVALID_TEXT_DRAW;

	foreach(new i: Player)
	{
		if(PMReply[i] == playerid) PMReply[i] = -1;
	}

	CurrentSessionDeaths[playerid] = 0;
	CurrentSessionKills[playerid] = 0;
}
/*public OnPlayerModelSelectionEx(playerid, response, extraid, modelid)
{
	if(!response) return true;

	if(extraid == MODEL_SELECTION_VTUNE && IsPlayerInAnyVehicle(playerid))
	{
		new componentname[ZVEH_MAX_COMPONENT_NAME];
		AddVehicleComponent(GetPlayerVehicleID(playerid), modelid);
		GetVehicleComponentName(modelid, componentname);
		SendClientMessage(playerid, -1, sprintf("(Freeroam):{dadada} You have installed the '%s' component to your vehicle.", componentname));
		return true;
	}
	if(extraid == MODEL_SELECTION_DONORSKIN)
	{
		SetPlayerSkinEx(playerid, modelid);
		return true;
	}
	if(extraid == MODEL_SELECTION_SKINLIST)
	{
		SetPlayerSkin(playerid, modelid);
		Account[playerid][Skin] = modelid;
		return true;
	}
	if(extraid == MODEL_SELECTION_CUSTOMSKIN)
	{
		SetPlayerSkin(playerid, modelid);
		Account[playerid][Skin] = modelid;
		return true;
	}
	return 1;
}*/
public OnDialogResponse(playerid, dialogid, response, listitem, const inputtext[])
{
	if(dialogid == DIALOG_COLOUR)
	{
		if(!response) return true;
		new colorlist[] =
		{
			pCOLOR_WHITE, pCOLOR_INVISIBLE, pCOLOR_GREEN, pCOLOR_RED, pCOLOR_BLUE, pCOLOR_PINK, pCOLOR_PURPLE, pCOLOR_YELLOW, pCOLOR_BROWN, pCOLOR_GREY, pCOLOR_BLACK,
			pCOLOR_LPINK, pCOLOR_ORANGE, pCOLOR_PINKRED, pCOLOR_DARKRED, pCOLOR_DARKERRED, pCOLOR_ORANGERED, pCOLOR_TOMATO, pCOLOR_LIGHTBLUE, pCOLOR_LIGHTNAVY, pCOLOR_NAVYBLUE,
			pCOLOR_LBLUE, pCOLOR_LLBLUE, pCOLOR_FLBLUE, pCOLOR_BLUEVIOLET, pCOLOR_BISQUE, pCOLOR_LIME, pCOLOR_LAWNGREEN, pCOLOR_SEAGREEN, pCOLOR_LIMEGREEN, pCOLOR_SPRINGGREEN,
			pCOLOR_YELLOWGREEN, pCOLOR_GREENYELLOW, pCOLOR_OLIVE, pCOLOR_AQUA, pCOLOR_MEDIUMAQUA, pCOLOR_MAGENTA, pCOLOR_MEDIUMMAGENTA, pCOLOR_CHARTREUSE, pCOLOR_CORAL,
			pCOLOR_GOLD, pCOLOR_INDIGO, pCOLOR_IVORY
		};

		if(listitem == 0) SetPlayerColor(playerid, PlayerColors[random(sizeof(PlayerColors))]);
		else SetPlayerColor(playerid, colorlist[listitem - 1]);
		return 1;
	}
	if(dialogid == DIALOG_VIPCOLOUR)
	{
		if(!response) return true;
		new colorlist[] =
		{
			pCOLOR_WHITE, pCOLOR_GREEN, pCOLOR_RED, pCOLOR_BLUE, pCOLOR_PINK, pCOLOR_PURPLE, pCOLOR_YELLOW, pCOLOR_BROWN, pCOLOR_GREY, pCOLOR_BLACK,
			pCOLOR_LPINK, pCOLOR_ORANGE, pCOLOR_PINKRED, pCOLOR_DARKRED, pCOLOR_DARKERRED, pCOLOR_ORANGERED, pCOLOR_TOMATO, pCOLOR_LIGHTBLUE, pCOLOR_LIGHTNAVY, pCOLOR_NAVYBLUE,
			pCOLOR_LBLUE, pCOLOR_LLBLUE, pCOLOR_FLBLUE, pCOLOR_BLUEVIOLET, pCOLOR_BISQUE, pCOLOR_LIME, pCOLOR_LAWNGREEN, pCOLOR_SEAGREEN, pCOLOR_LIMEGREEN, pCOLOR_SPRINGGREEN,
			pCOLOR_YELLOWGREEN, pCOLOR_GREENYELLOW, pCOLOR_OLIVE, pCOLOR_AQUA, pCOLOR_MEDIUMAQUA, pCOLOR_MAGENTA, pCOLOR_MEDIUMMAGENTA, pCOLOR_CHARTREUSE, pCOLOR_CORAL,
			pCOLOR_GOLD, pCOLOR_INDIGO, pCOLOR_IVORY
		};
		SetPlayerColor(playerid, colorlist[listitem - 1]);
		return 1;
	}
	return 1;
}

forward CloseInfo(playerid);
public CloseInfo(playerid)
{
	PlayerTextDrawHide(playerid, InfoBox[playerid]);
	return 1;
}

forward CloseInfoOffSet(playerid);
public CloseInfoOffSet(playerid)
{
	PlayerTextDrawHide(playerid, InfoBoxOS[playerid]);
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_PASSENGER)
	{
		if(GetPlayerWeapon(playerid) == 24)
		{
			SetPlayerArmedWeapon(playerid, 0);
		}
	}
	return 1;
}
public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	new id = GetNearestVehicle(playerid, 15.0);
	if (clickedid == ChangeColor[1] )
	{
		CancelSelectTextDraw(playerid);
		for(new i; i < sizeof(ChangeColor); i++)
		{
			TextDrawHideForPlayer(playerid,ChangeColor[i]);
		}
	}
	for(new i=2; i < sizeof(ChangeColor); i++)
	{
		if(clickedid == ChangeColor[i])
		{
			CancelSelectTextDraw(playerid);
			ChangeVehicleColor(id,ColorsAvailable[i-2],ColorsAvailable[i-2]);
			for(new j; j < sizeof(ChangeColor); j++)
			{
				TextDrawHideForPlayer(playerid,ChangeColor[j]);
			}
		}
	}
	return 1 ;
}
Account_Reset(playerid)
{
	for(new i; acc:i < acc; i++)
	{
		Account[playerid][acc:i] = 0;
	}
	return 1;
}
/*
ClearChatbox(playerid)
{
	for(new i = 0; i < 50; i++)
	{
		SendClientMessage(playerid, COLOR_WHITE, "");
	}
	return 1;
}
*/
//------------------------------------------------
KickPlayer(playerid)
{
	yield 1;
	wait_ticks(5);
	Kick(playerid);
	return true;
}

GetName(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	return name;
}
public OnPlayerUpdate(playerid)
{
	new drunknew;
	drunknew = GetPlayerDrunkLevel(playerid);
	if(drunknew < 100)
	{
		SetPlayerDrunkLevel(playerid, 2000); // go back up, keep cycling.
	}
	else
	{
		if (pDrunkLevelLast[playerid] != drunknew)
		{
			new wfps = pDrunkLevelLast[playerid] - drunknew;

			if((wfps > 0) && (wfps < 200)) pFPS[playerid] = wfps;
			pDrunkLevelLast[playerid] = drunknew;
		}
	}
	if(Account[playerid][InWheelChair] == 1)
	{
		new Float:a, Keys, ud, lr;
		GetPlayerKeys(playerid,Keys,ud,lr);
		if(ud < 0)
		{

			SetPlayerForwardVelocity(playerid, 0.16, -0.03);

		}
		if(ud > 0)
		{

			SetPlayerForwardVelocity(playerid, -0.16, -0.03);

		}
		if(lr > 0)
		{

			GetPlayerFacingAngle(playerid, a);
			SetPlayerFacingAngle(playerid, a-10);

		}
		if(lr < 0)
		{

			GetPlayerFacingAngle(playerid, a);
			SetPlayerFacingAngle(playerid, a+10);
		}
	}

	Account[playerid][pAFKTime] = 0;
	return 1;
}

InfoBoxForPlayer(playerid, const text[])
{
	//CloseInfo(playerid);
	PlayerTextDrawSetString(playerid, InfoBox[playerid], text);
	PlayerTextDrawShow(playerid, InfoBox[playerid]);
	SetTimerEx("CloseInfo", SECONDS(5), false, "d", playerid);
	return 1;
}

GetWeaponIDFromName(const str[])
{
	for(new i = 0; i < 48; i++)
	{
		if (i == 19 || i == 20 || i == 21) continue;
		if (strfind(WeaponNameList[i], str, true) != -1)
		{
			return i;
		}
	}
	return -1;
}

Restricted_Weapon(WeaponID)
{
	if(WeaponID == 35 || WeaponID >= 36 || WeaponID >= 38)
	{
		return 0;
	}
	return 1;
}

GetInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance)
{
	// Created by Y_Less

	new Float:a;

	GetPlayerPos(playerid, x, y, a);
	GetPlayerFacingAngle(playerid, a);

	if (GetPlayerVehicleID(playerid))
	{
		GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	}

	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
}

public OnPlayerRequestClass(playerid,classid)
{
	TogglePlayerSpectating(playerid, 0);
	SetTimerEx("SpawnPlayer1", 250, false, "d", playerid);
	SetPlayerSkin(playerid, Account[playerid][Skin]);
	return 1;
}
forward SpawnPlayer1(playerid);
public SpawnPlayer1(playerid)
{
	SpawnPlayer(playerid);
	return 1;
}

SetPlayerMoneyEx(playerid, amount)
{
	Account[playerid][Cash] = amount;

	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE Accounts SET Cash = %i WHERE SQLID = %i", Account[playerid][Cash], Account[playerid][SQLID]));

	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, Account[playerid][Cash]);
	return 1;
}

GivePlayerMoneyEx(playerid, amount)
{
	Account[playerid][Cash] += amount;

	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE Accounts SET Cash = %i WHERE SQLID = %i", Account[playerid][Cash], Account[playerid][SQLID]));

	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, Account[playerid][Cash]);
	return 1;
}
GivePlayerKillEx(playerid, amount)
{
	Account[playerid][Kills] += amount;
	Account[playerid][MonthKills]+= amount;

	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE Accounts SET Kills = %i, MonthKills = %i WHERE SQLID = %i", Account[playerid][Kills], Account[playerid][MonthKills], Account[playerid][SQLID]));

	SetPlayerScore(playerid, Account[playerid][Kills]);
	return 1;
}

GetNearestVehicle(playerid, Float:dis)
{
	new Float:X, Float:Y, Float:Z;
	if(GetPlayerPos(playerid, X, Y, Z))
	{
		new vehicleid = INVALID_VEHICLE_ID, Float:temp, Float:VX, Float:VY, Float:VZ;
		foreach(new v: Vehicle)
		{
			if(GetVehiclePos(v, VX, VY, VZ))
			{
				VX -= X, VY -= Y, VZ -= Z;
				temp = VX * VX + VY * VY + VZ * VZ;
				if(temp < dis) dis = temp, vehicleid = v;
			}
		}
		dis = floatpower(dis, 1.0);
		return vehicleid;
	}
	return INVALID_VEHICLE_ID;
}

FindVehicleByNameID(const vname[])
{
	if('4' <= vname[0] <= '6') return INVALID_VEHICLE_ID;

	for(new i,LEN = strlen(vname); i != sizeof(VehicleNames); i++)
		if(!strcmp(VehicleNames[i],vname,true,LEN))
			return i + 400;

	return INVALID_VEHICLE_ID;
}

Restricted_Skins(skinID)
{
	if(skinID == 0 || skinID == 92 || skinID == 99 || skinID == 74)
	{
		return 1;
	}
	return 0;
}
SendSpree(playerid)
{
	if(Account[playerid][KillStreak] == 2)
	{
		GameTextForPlayer(playerid, "~R~Double Kill!", 1000, 6);
	}
	if(Account[playerid][KillStreak] == 3)
	{
		new Float:armour;
		GetPlayerArmour(playerid, armour);
		SetPlayerArmour(playerid, armour + 25);

		SendDMMessage(ActivityStateID[playerid], COLOR_GRAY, sprintf("{31AEAA}Spree:{%06x} %s{FFFFFF} is on a %d killing spree!", GetPlayerColor(playerid) >>> 8, GetName(playerid), Account[playerid][KillStreak]));
		SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Reward: {FFFFFF}You have been given +25 armour for your spree!");
		GameTextForPlayer(playerid, "~R~Triple Kill!", 1000, 6);
	}
	if(Account[playerid][KillStreak] == 5)
	{
		new Float:armour;
		GetPlayerArmour(playerid, armour);
		SetPlayerArmour(playerid, armour + 50);

		SendDMMessage(ActivityStateID[playerid], COLOR_GRAY, sprintf("{31AEAA}Spree:{%06x} %s{FFFFFF} is on a %d killing spree!", GetPlayerColor(playerid) >>> 8, GetName(playerid), Account[playerid][KillStreak]));
		SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Reward: {FFFFFF}You have been given +50 armour for your spree!");
		GameTextForPlayer(playerid, "~R~Multi-Kill!", 1000, 6);
	}
	if(Account[playerid][KillStreak] == 10)
	{
		SendDMMessage(ActivityStateID[playerid], COLOR_GRAY, sprintf("{31AEAA}Spree:{%06x} %s{FFFFFF} is on a %d killing spree!", GetPlayerColor(playerid) >>> 8, GetName(playerid), Account[playerid][KillStreak]));
		SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Reward: {FFFFFF}You have been given $3500 for your spree!");
		GivePlayerMoneyEx(playerid, 3500);
		GameTextForPlayer(playerid, "~R~INSANE SPREE", 1000, 6);
	}
	if(Account[playerid][KillStreak] == 15)
	{
		SendDMMessage(ActivityStateID[playerid], COLOR_GRAY, sprintf("{31AEAA}Spree:{%06x} %s{FFFFFF} is on a %d killing spree!", GetPlayerColor(playerid) >>> 8, GetName(playerid), Account[playerid][KillStreak]));
		SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Reward: {FFFFFF}You have been given +10 kills for your spree!");
		GivePlayerKillEx(playerid, 10);
		GameTextForPlayer(playerid, "~R~MADNESS SPREE", 1000, 6);
	}
	if(Account[playerid][KillStreak] == 25)
	{
		SendDMMessage(ActivityStateID[playerid], COLOR_GRAY, sprintf("{31AEAA}Spree:{%06x} %s{FFFFFF} is on a %d killing spree!", GetPlayerColor(playerid) >>> 8, GetName(playerid), Account[playerid][KillStreak]));
		SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Reward: {FFFFFF}You have been given +25 kills for your spree!");
		GivePlayerKillEx(playerid, 25);
		GameTextForPlayer(playerid, "~R~NUKE SPREE!", 1000, 6);
	}
	else
	{
		if(Account[playerid][KillStreak]  < 3)
		{
			return 0;
		}
	}
	return 1;
}
SendTDMSpree(playerid)
{
	if(Account[playerid][KillStreak] == 2)
	{
		GameTextForPlayer(playerid, "~R~Double Kill!", 1000, 6);
	}
	if(Account[playerid][KillStreak] == 3)
	{
		new Float:armour;
		GetPlayerArmour(playerid, armour);
		SetPlayerArmour(playerid, armour + 25);

		SendTDMMessage(-1, sprintf("{31AEAA}Spree:{%06x} %s{FFFFFF} is on a %d killing spree!", GetPlayerColor(playerid) >>> 8, GetName(playerid), Account[playerid][KillStreak]));
		SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Reward: {FFFFFF}You have been given +25 armour for your spree!");
		GameTextForPlayer(playerid, "~R~Triple Kill!", 1000, 6);
	}
	if(Account[playerid][KillStreak] == 5)
	{
		new Float:armour;
		GetPlayerArmour(playerid, armour);
		SetPlayerArmour(playerid, armour + 50);

		SendTDMMessage(-1, sprintf("{31AEAA}Spree:{%06x} %s{FFFFFF} is on a %d killing spree!", GetPlayerColor(playerid) >>> 8, GetName(playerid), Account[playerid][KillStreak]));
		SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Reward: {FFFFFF}You have been given +50 armour for your spree!");
		GameTextForPlayer(playerid, "~R~Multi-Kill!", 1000, 6);
	}
	if(Account[playerid][KillStreak] == 10)
	{
		SendTDMMessage(-1, sprintf("{31AEAA}Spree:{%06x} %s{FFFFFF} is on a %d killing spree!", GetPlayerColor(playerid) >>> 8, GetName(playerid), Account[playerid][KillStreak]));
		SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Reward: {FFFFFF}You have been given $3500 for your spree!");
		GivePlayerMoneyEx(playerid, 3500);
		GameTextForPlayer(playerid, "~R~INSANE SPREE", 1000, 6);
	}
	if(Account[playerid][KillStreak] == 15)
	{
		SendTDMMessage(-1, sprintf("{31AEAA}Spree:{%06x} %s{FFFFFF} is on a %d killing spree!", GetPlayerColor(playerid) >>> 8, GetName(playerid), Account[playerid][KillStreak]));
		SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Reward: {FFFFFF}You have been given +10 kills for your spree!");
		GivePlayerKillEx(playerid, 10);
		GameTextForPlayer(playerid, "~R~MADNESS SPREE", 1000, 6);
	}
	if(Account[playerid][KillStreak] == 25)
	{
		SendTDMMessage(-1, sprintf("{31AEAA}Spree:{%06x} %s{FFFFFF} is on a %d killing spree!", GetPlayerColor(playerid) >>> 8, GetName(playerid), Account[playerid][KillStreak]));
		SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Reward: {FFFFFF}You have been given +25 kills for your spree!");
		GivePlayerKillEx(playerid, 25);
		GameTextForPlayer(playerid, "~R~NUKE SPREE!", 1000, 6);
	}
	else
	{
		if(Account[playerid][KillStreak]  < 3)
		{
			return 0;
		}
	}
	return 1;
}
public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	ShowStatsForPlayer(playerid, clickedplayerid);
	return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	if(GetPlayerAdminLevel(playerid) > 2)
	{
		SetPlayerPosFindZ(playerid, fX, fY, fZ);
	}
	return 1;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(PRESSED(KEY_SECONDARY_ATTACK))
	{
		if(IsPlayerInRangeOfPoint(playerid, 3.0, 2529.7070, 603.0845, 35.7459))
		{
			cmd_skinroll(9999, playerid);
		}
	}
	return 1;
}
public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}
public OnPlayerEnterCheckpoint(playerid)
{
	if(IsPlayerInLobby(playerid))
	{
		SendClientMessage(playerid, COLOR_LIGHTBLUE, "Press 'F' to use the Skin Roll system! Price: {31AEAA}$10,000 per roll!");
		SendClientMessage(playerid, COLOR_LIGHTBLUE, "Diamond V.I.P Donators are refunded if they get a skin they already have.");
	}
	return true;
}
public OnPlayerExitVehicle(playerid, vehicleid)
{
	if(ActivityState[playerid] == ACTIVITY_TDM)
	{
		if(GetVehicleSpeed(vehicleid) > 50)
		{
			ClearAnimations(playerid, 0);
		}
	}
	return 1;
}
public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{

	return 1;
}
forward RespawnBrokenVeh(vehicleid);
public RespawnBrokenVeh(vehicleid)
{
	SetVehicleToRespawn(vehicleid);
	SetVehicleParamsEx(vehicleid, 1, 1, 0, 0, 0, 0, 0);

	return true;
}
public OnPlayerDeath(playerid, killerid, reason)
{
	Account[playerid][KillStreak] = 0;
	if(ActivityState[playerid] == ACTIVITY_TDM) //player died in TDM
	{
		ResetPlayerWeaponsEx(playerid);
		SetPlayerHealth(playerid, 1);

		if(IsPlayerConnected(killerid))
		{
			GivePlayerKillEx(killerid, 1);
			OnDeathCash(playerid, killerid);
			Account[playerid][Deaths]++;
			Account[killerid][KillStreak]++;
			SendTDMSpree(killerid);
			UpdateKDs(playerid, killerid);
			PlayerPlaySound(killerid, 17802, 0.0, 0.0, 0.0);
			if(capturingturf[playerid] == 1)
			{
				capturingturf[playerid] = 0;
				SendTDMMessage(COLOR_LIGHTRED, sprintf("TURF: {%06x}%s was killed by {%06x}%s while capturing the turf. The turf is now available for capture!", GetPlayerColor(playerid) >>> 8, GetName(playerid), GetPlayerColor(killerid) >>> 8, GetName(killerid)));
				KillTimer(capturingtimer[playerid]);
				GangZoneStopFlashForAll(igsturf);
				beingcaptured = -1;
			}

			if(random(10000) == 5000)
			{	
				Account[killerid][Tokens]++;
				SendClientMessageToAll(pCOLOR_PINK, sprintf("ANNOUNCEMENT: PLAYER %s HAS JUST RECEIVED A KDM TOKEN FROM KILLING %S! (1/10000 CHANCE)", GetName(killerid), GetName(playerid)));
			}

			foreach(new i: Player)
			{
				if(ActivityState[i] == ACTIVITY_TDM)
				{
					SendDeathMessageToPlayer(i, killerid, playerid, reason);
				}
			}
		}
		return true;
	}
	else if(ActivityState[playerid] == ACTIVITY_DUEL)
	{
		if(killerid == INVALID_PLAYER_ID)
		{
			SendClientMessageToAll(-1, sprintf("{31AEAA}Duel: {%06x}%s {FFFFFF}died in mysterious circumstances. Duel ended.", GetPlayerColor(playerid) >>> 8, GetName(playerid)));
			EndDuel(playerid, true);
			return true;
		}

		new Float:duel_health, host_id;
		GetPlayerHealth(killerid, duel_health);
		host_id = ActivityStateID[playerid];

		if(DuelTeam[host_id][playerid] == HOST_TEAM) AlliesCount[host_id]--;
		else EnemyCount[host_id]--;

		new team_count = DuelTeam[host_id][playerid] == HOST_TEAM ? AlliesCount[host_id] : EnemyCount[host_id];
		if(team_count == 0)
		{
			SendClientMessageToAll(-1, sprintf("{31AEAA}Duel: {%06x}%s {FFFFFF}has won the duel for their team by finishing off {%06x}%s!", GetPlayerColor(killerid) >>> 8, GetName(killerid), GetPlayerColor(playerid) >>> 8, GetName(playerid)));
			EndDuel(playerid, false);
		}
		else
		{
			ActivityState[playerid] = ACTIVITY_LOBBY;
			ActivityStateID[playerid] = -1;
		}
		return true;
	}
	else if(ActivityState[playerid] == ACTIVITY_COPCHASE)
	{
		if(Account[playerid][pCopchase])
		{
			// The dead player was the criminal
			if(Account[playerid][pCopchase] == 3)
			{
				if(killerid != INVALID_PLAYER_ID){
					new msg[128];
					format(msg, sizeof(msg), "{%06x}%s{FFFFFF} has been killed by {%06x}%s{FFFFFF}. [%d players remaining]", GetPlayerColor(playerid) >>> 8, GetName(playerid), GetPlayerColor(killerid) >>> 8, GetName(killerid), GetCopchaseTotalPlayers() - 1);
					SendCopchaseMessage(msg);
				}else{
					new msg[128];
					format(msg, sizeof(msg), "{%06x}%s{FFFFFF} died of natural causes. [%d players remaining]", GetPlayerColor(playerid) >>> 8, GetName(playerid), GetCopchaseTotalPlayers() - 1);
					SendCopchaseMessage(msg);
				}
				Account[playerid][pCopchase] = 0;
				PlayerTextDrawHide(playerid, Account[playerid][TextDraw][1]);
				PlayerTextDrawHide(playerid, Account[playerid][TextDraw][0]);
				PlayerTextDrawHide(playerid, Account[playerid][TextDraw][2]);
				PlayerTextDrawHide(playerid, Account[playerid][TextDraw][3]);
				HandleLobbyTransition(playerid);
				StartCopchase(); // actually i'm terminating it in here.
			}
			
			// The dead player was a cop
			if(Account[playerid][pCopchase] == 2)
			{
				if(killerid != INVALID_PLAYER_ID){
					new msg[128];
					format(msg, sizeof(msg), "{%06x}%s{FFFFFF} has been killed by {%06x}%s{FFFFFF}. [%d players remaining]", GetPlayerColor(playerid) >>> 8, GetName(playerid), GetPlayerColor(killerid) >>> 8, GetName(killerid), GetCopchaseTotalPlayers() - 1);
					SendCopchaseMessage(msg);
				}else{
					new msg[128];
					format(msg, sizeof(msg), "{%06x}%s{FFFFFF} died of natural causes. [%d players remaining]", GetPlayerColor(playerid) >>> 8, GetName(playerid), GetCopchaseTotalPlayers() - 1);
					SendCopchaseMessage(msg);
				}
				Account[playerid][pCopchase] = 0;
				StartCopchase(); // checking if game is over
				HandleLobbyTransition(playerid);
				SetPlayerSkin(playerid, Account[playerid][Skin]);
				PlayerTextDrawHide(playerid, Account[playerid][TextDraw][1]);
				PlayerTextDrawHide(playerid, Account[playerid][TextDraw][0]);
				PlayerTextDrawHide(playerid, Account[playerid][TextDraw][2]);
				PlayerTextDrawHide(playerid, Account[playerid][TextDraw][3]);
			}
			ActivityState[playerid] = 0;
		}
	}
	if(ActivityState[playerid] == ACTIVITY_ARENADM)
	{
		new arenaid = ActivityStateID[playerid];
		Account[playerid][LobbyPermission] = 0;
		if(Account[playerid][KillStreak] >= 3) SendDMMessage(arenaid, COLOR_GRAY, sprintf("{31AEAA}Spree: {%06x}%s {FFFFFF}has just ended {%06x}%s{FFFFFF}'s killstreak of {31AEAA}%d", GetPlayerColor(killerid) >>> 8, GetName(killerid), GetPlayerColor(playerid) >>> 8, GetName(playerid), Account[playerid][KillStreak]));
		Account[killerid][KillStreak]++;
		Account[playerid][KillStreak] = 0;

		foreach(new i: ArenaOccupants[arenaid])
		{
			SendDeathMessageToPlayer(i, killerid, playerid, reason);
		}

		UpdateKDs(playerid, killerid);

		GivePlayerKillEx(killerid, 1);
		Account[playerid][Deaths]++;
		SetPlayerScore(killerid, GetPlayerScore(killerid) +1);
		SendSpree(killerid);
		OnDeathCash(playerid, killerid);
		if(random(100) == 49)
		{
			GiveKey(killerid);
		}
		if(random(10000) == 5000)
		{
			Account[playerid][Tokens]++;
			SendClientMessage(playerid, pCOLOR_PINK, sprintf("ANNOUNCEMENT: PLAYER %s HAS JUST RECEIVED A KDM TOKEN FROM KILLING %S! (1/10000 CHANCE)", GetName(killerid), GetName(playerid)));
		}
	}
	if(ActivityState[playerid] == ACTIVITY_FREEROAM)
	{
		ResetPlayerWeaponsEx(playerid);
	}
	if(ActivityState[playerid] == ACTIVITY_EVENT)
	{
		UpdateKDs(playerid, killerid);
		HandleEventDeath(playerid, killerid, reason);
		ResetPlayerWeaponsEx(playerid);
		SetPlayerHealth(playerid, 1);
		EventDeath[playerid] = 1;
		RespawnEventPlayer(playerid);
	}
	return 1;
}
StatsLine(playerid)
{
	SendClientMessage(playerid, COLOR_DGREEN, "_________________________________________________");
	return 1;
}
forward SetPlayerPosEx(playerid, Float:X, Float:Y, Float:Z, Int, vWorld);
public SetPlayerPosEx(playerid, Float:X, Float:Y, Float:Z, Int, vWorld)
{
	TogglePlayerControllable(playerid, false);
	SetPlayerPos(playerid, X, Y, Z);
	SetPlayerInterior(playerid, Int);
	SetPlayerVirtualWorld(playerid, vWorld);
	PickedUpPickup[playerid] = false;
	TogglePlayerControllable(playerid, true);
	return 1;
}
DonatorRank(playerid)
{
	new drank[34];
	switch(Account[playerid][Donator])
	{
		case 0:
		{
			drank = "None";
		}
		case 1:
		{
			drank = "{cd7f32}Bronze";
		}
		case 2:
		{
			drank = "{c0c0c0}Silver";
		}
		case 3:
		{
			drank = "{ffcc00}Gold";
		}
		case 4:
		{
			drank = "{08D6E3}Diamond";
		}
	}
	return drank;
}
VerifiedCheck(playerid)
{
	new string[34];
	if(Account[playerid][Verified] == 0)
	{
		string ="No";
	}
	if(Account[playerid][Verified] > 0)
	{
		string ="Yes";
	}
	return string;
}
//==============================================================================
//          -- > Player Functions
//==============================================================================
GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance)
{
    new Float:a;
    GetPlayerPos(playerid, x, y, a);
    GetPlayerFacingAngle(playerid, a);

    if (GetPlayerVehicleID(playerid))
    {
      GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
   }

    x += (distance * floatsin(-a, degrees));
    y += (distance * floatcos(-a, degrees));

    return 1;
}


//==============================================================================
//          -- > Chat Functions
//==============================================================================
stock GetPlayerAdminLevel(playerid)
{
	return Account[playerid][Admin];
}

stock GetPlayerAdminHidden(playerid)
{
	return Account[playerid][pAdminHide];
}

stock ToggleAdminHidden(playerid)
{
	if(GetPlayerAdminHidden(playerid)) {
		Account[playerid][pAdminHide] = 0;
	}
	else {
		Account[playerid][pAdminHide] = 1;
	}
	SendAdminsMessage(1, COLOR_INDIANRED, sprintf("WARNING: %s is %s visible in /admins.", GetName(playerid), (Account[playerid][pAdminHide] == 0 ? "now" : "no longer")));
	return 1;
}

SendPunishmentMessage(str[])
{
	foreach(new i: Player)
	{
	   if(Account[i][LoggedIn] > 0)
	   {
		   SendClientMessage(i, COLOR_LIGHTRED, sprintf("PUNISHMENT: %s", str));
	   }
	}
	return 1;
}

SendErrorMessage(playerid, const str[])
{
	new astr[128];
	format(astr, sizeof(astr), "[SERVER] %s", str);
	SendClientMessage(playerid, COLOR_GRAY, astr);
	return 1;
}

SendAdminsMessage(level, color, str[])
{
	foreach(new i: Player)
	{
		new astr[128];
		if(Account[i][Admin] >= level)
		{
			format(astr, sizeof(astr), "(AdmChat) %s", str);
			SendClientMessage(i, color, astr);
		}
	}
}
SendDonatorsMessage(level, color, str[])
{
	foreach(new i: Player)
	{
		new astr[128];
		if(Account[i][Donator] >= level)
		{
			format(astr, sizeof(astr), "(Donator-Chat) %s", str);
			SendClientMessage(i, color, astr);
		}
	}
}


//==============================================================================
//          -- > Chat Commands
//==============================================================================
forward ReadRules(playerid);
public ReadRules(playerid)
{
	InfoBoxForPlayer(playerid, "~g~Please be aware of our server rules.");
	Account[playerid][ForcedRules1] = 0;
	return 1;
}
forward OnPremiumCrateStep(playerid, step);
public OnPremiumCrateStep(playerid, step)
{
	switch(step)
	{
		case 0:
		{
			GameTextForPlayer(playerid, "~g~OPENING....", 1000, 4);
			SetTimerEx("OnPremiumCrateStep", 1000, false, "ii", playerid, 1);
			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			return true;
		}
		case 1:
		{
			GameTextForPlayer(playerid, "~r~THE....", 1000, 4);
			SetTimerEx("OnPremiumCrateStep", 1000, false, "ii", playerid, 2);
			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
			return true;
		}
		case 2:
		{
			GameTextForPlayer(playerid, "~b~CRATE.....", 1000, 4);
			PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
			SetTimerEx("OnPremiumCrateStep", 1000, false, "ii", playerid, 3);
			return true;
		}
		case 3:
		{
			new reward = random(10), str[400];
			GameTextForPlayer(playerid, "~b~Completed!", 1000, 4);
			PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
			if(reward == 0)
			{
				GivePlayerMoneyEx(playerid, 5000);
				format(str, sizeof(str), "{31AEAA}Crates: {%06x}%s {FFFFFF}has just won $5000!", GetPlayerColor(playerid) >>> 8, GetName(playerid));
				SendClientMessageToAll(-1, str);
			}
			if(reward == 1)
			{
				format(str, sizeof(str), "{31AEAA}Crates: {%06x}%s {FFFFFF}has just won $10000!", GetPlayerColor(playerid) >>> 8, GetName(playerid));
				SendClientMessageToAll(-1, str);
				GivePlayerMoneyEx(playerid, 10000);
			}
			if(reward == 2)
			{
				format(str, sizeof(str), "{31AEAA}Crates: {%06x}%s {FFFFFF}has just won an Event!", GetPlayerColor(playerid) >>> 8, GetName(playerid));
				SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Reward: {FFFFFF}Congratulations, you've won an Event. (/startevent)");
				SendClientMessageToAll(-1, str);
				Account[playerid][PlayerEvents]++;
			}
			if(reward == 3)
			{
				if(Account[playerid][Donator] <= 0 || Account[playerid][Donator] > 0 && Account[playerid][GsignPack] <= 0)
				{
					format(str, sizeof(str), "{31AEAA}Crates: {%06x}%s {FFFFFF}has just won access to /gsign!", GetPlayerColor(playerid) >>> 8, GetName(playerid));
					SendClientMessageToAll(-1, str);
					Account[playerid][GsignPack] = 1;
				}
				if(Account[playerid][Donator] > 0 && Account[playerid][GsignPack] > 0)
				{
					format(str, sizeof(str), "~y~It seems you already have ~r~/gsign~y~ have been ~g~refunded~y~ as you are a Donator!", GetPlayerColor(playerid) >>> 8, GetName(playerid));
					InfoBoxForPlayer(playerid, str);
					Account[playerid][PlayerKeys]++;
					UpdateKeyText(playerid);
				}
				if(Account[playerid][GsignPack] > 0 && Account[playerid][Donator] <= 0)
				{
					format(str, sizeof(str), "~y~It seems you already have ~r~/gsign~y~ and will not be refunded as you are not a ~g~Donator!", GetPlayerColor(playerid) >>> 8, GetName(playerid));
					InfoBoxForPlayer(playerid, str);
				}
			}
			if(reward == 4)
			{
				format(str, sizeof(str), "{31AEAA}Crates: {%06x}%s {FFFFFF}has just won $25000!", GetPlayerColor(playerid) >>> 8, GetName(playerid));
				SendClientMessageToAll(-1, str);
				GivePlayerMoneyEx(playerid, 25000);
				UpdateKeyText(playerid);
			}
			if(reward == 5)
			{
				if(Account[playerid][WeatherAccess] <= 0 || Account[playerid][Donator] > 0 && Account[playerid][WeatherAccess] <= 0)
				{
					format(str, sizeof(str), "{31AEAA}Crates: {%06x}%s {FFFFFF}has just won access to /setweather!", GetPlayerColor(playerid) >>> 8, GetName(playerid));
					SendClientMessageToAll(-1, str);
					Account[playerid][WeatherAccess] = 1;
				}
				if(Account[playerid][Donator] > 0 && Account[playerid][WeatherAccess] > 0)
				{
					format(str, sizeof(str), "~y~It seems you already have ~r~/setweather~y~ and have been ~g~refunded~y~ as you are a Donator!", GetPlayerColor(playerid) >>> 8, GetName(playerid));
					InfoBoxForPlayer(playerid, str);
					Account[playerid][PlayerKeys]++;
					UpdateKeyText(playerid);
				}
				if(Account[playerid][WeatherAccess] > 0 && Account[playerid][Donator] <= 0)
				{
					format(str, sizeof(str), "~y~It seems you already have ~r~/setweather~y~ and will not be refunded as you are not a ~g~Donator!", GetPlayerColor(playerid) >>> 8, GetName(playerid));
					InfoBoxForPlayer(playerid, str);
					Account[playerid][WeatherAccess] = 1;
				}
			}
			if(reward == 6)
			{
				if(Account[playerid][WheelChair] <= 0 || Account[playerid][Donator] > 0 && Account[playerid][WheelChair] <= 0)
				{
					format(str, sizeof(str), "{31AEAA}Crates: {%06x}%s {FFFFFF}has just won access to /wheelchair!", GetPlayerColor(playerid) >>> 8,  GetName(playerid));
					SendClientMessageToAll(-1, str);
					Account[playerid][WheelChair] = 1;
				}
				if(Account[playerid][Donator] > 0 && Account[playerid][WheelChair] > 0)
				{
					format(str, sizeof(str), "~y~It seems you already have a ~r~/wheelchair~y~ and have been ~g~refunded~y~ as you are a Donator!", GetPlayerColor(playerid) >>> 8, GetName(playerid));
					InfoBoxForPlayer(playerid, str);
					Account[playerid][PlayerKeys]++;
					UpdateKeyText(playerid);
				}
				if(Account[playerid][WheelChair] > 0 && Account[playerid][Donator] <= 0)
				{
					format(str, sizeof(str), "~y~It seems you already have a ~r~/wheelchair~y~ and will not be refunded as you are not a ~g~Donator!", GetPlayerColor(playerid) >>> 8, GetName(playerid));
					InfoBoxForPlayer(playerid, str);
					Account[playerid][WheelChair] = 1;
				}
			}
			if(reward == 7)
			{
				if(Account[playerid][TimeAccess] <= 0 || Account[playerid][Donator] > 0 && Account[playerid][TimeAccess] <= 0)
				{
					format(str, sizeof(str), "{31AEAA}Crates: {%06x}%s {FFFFFF}has just won access to /settime!", GetPlayerColor(playerid) >>> 8, GetName(playerid));
					SendClientMessageToAll(-1, str);
					Account[playerid][TimeAccess] = 1;
				}
				if(Account[playerid][Donator] > 0 && Account[playerid][TimeAccess] > 0)
				{
					format(str, sizeof(str), "~y~It seems you already have ~r~/settime~y~ and have been ~g~refunded~y~ as you are a Donator!", GetPlayerColor(playerid) >>> 8, GetName(playerid));
					InfoBoxForPlayer(playerid, str);
					Account[playerid][PlayerKeys]++;
					UpdateKeyText(playerid);
				}
				if(Account[playerid][TimeAccess] > 0 && Account[playerid][Donator] <= 0)
				{
					format(str, sizeof(str), "~y~It seems you already have ~r~/settime~y~ and will not be refunded as you are not a ~g~Donator!", GetPlayerColor(playerid) >>> 8, GetName(playerid));
					InfoBoxForPlayer(playerid, str);
					Account[playerid][TimeAccess] = 1;
				}
			}
			if(reward == 8)
			{
				format(str, sizeof(str), "{31AEAA}Crates: {%06x}%s {FFFFFF}has just won $50000!", GetPlayerColor(playerid) >>> 8, GetName(playerid));
				SendClientMessageToAll(-1, str);
				GivePlayerMoneyEx(playerid, 50000);
				UpdateKeyText(playerid);
			}
			if(reward == 9)
			{
				format(str, sizeof(str), "{31AEAA}Crates: {%06x}%s {FFFFFF}has just won 2 events!", GetPlayerColor(playerid) >>> 8, GetName(playerid));
				SendClientMessageToAll(-1, str);
				Account[playerid][PlayerEvents] = Account[playerid][PlayerEvents] + 2;
				UpdateKeyText(playerid);
			}
			return true;
		}
	}
	return true;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}
public OnPlayerGiveDamageActor(playerid, damaged_actorid, Float:amount, weaponid, bodypart)
{
	return 1;
}
GetVehicleSpeed( vehicleid )
{
	// Function: GetVehicleSpeed( vehicleid )
	
	new
	    Float:x,
	    Float:y,
	    Float:z,
		vel;

	GetVehicleVelocity( vehicleid, x, y, z );

	vel = floatround( floatsqroot( x*x + y*y + z*z ) * 180 );			// KM/H
//	vel = floatround( floatsqroot( x*x + y*y + z*z ) * 180 / MPH_KMH ); // MPH

	return vel;
}
GetLanguage(language)
{
	new lang[64];
	switch(language)
	{
		case 0:
		{
			lang = "~";
		}
		case 1:
		{
			lang = "TURK";
		}
		case 2:
		{
			lang = "FRE";
		}
		case 3:
		{
			lang = "PORT";
		}
		case 4:
		{
			lang = "ESP";
		}
		case 5:
		{
			lang = "Other";
		}
	}
	return lang;
}
public OnPlayerText(playerid, const text[])
{
	if(!Account[playerid][LoggedIn]) return 0;

	new passport[100], language[64], tempstr[180];
	strunpack(tempstr, LastMessage[playerid]);
	if(!strcmp(tempstr, text, true) && !GetPlayerAdminLevel(playerid))
	{
		SendErrorMessage(playerid, "You cannot repeat the same message twice.");
	}
	if(MessageAmount[playerid] >= 5)
	{
		SendErrorMessage(playerid, "Stop spamming.");
	}

	format(language, sizeof(language), "[%s]{FFFFFF}", GetLanguage(Account[playerid][pLanguage]));
	if (Account[playerid][Muted] >= 1)
	{
		SendClientMessage(playerid, -1, "{31AEAA}Notice: {FFFFFF}You are currently muted.");
		return 0;
	}

	if(!GetPlayerAdminLevel(playerid) && ChatLocked) {
		SendClientMessage(playerid, -1, "{31AEAA}Notice: {FFFFFF}The chat is currently locked by an administrator.");
		return 0;
	}
	switch(GetPlayerAdminLevel(playerid))
	{
		case 1: passport = "({00AF33}A{FFFFFF})";
		case 2: passport = "({00AF33}A{FFFFFF})";
		case 3: passport = "({00AF33}A{FFFFFF})";
		case 4: passport = "({00AF33}A{FFFFFF})";
		case 5: passport = "({1D7CF2}LA{FFFFFF})";
		case 6: passport = "({CD2626}SM{FFFFFF})";
		default: passport = language;
	}

	new str[145];

	if(Account[playerid][pLanguage] > 0 || GetPlayerAdminLevel(playerid) > 0 && !GetPlayerAdminHidden(playerid))
	{
		format(str, sizeof( str), "%s {%06x}%s(%i):{FFFFFF} %s", passport, GetPlayerColor(playerid) >>> 8, GetName(playerid), playerid, text);
	}
	else
	{
		format(str, sizeof( str), "~{FFFFFF} {%06x}%s(%i):{FFFFFF} %s", GetPlayerColor(playerid) >>> 8, GetName(playerid), playerid, text);	
	}

	ChatSend(Account[playerid][pLanguage], str);

	MessageAmount[playerid] ++;
	strpack(LastMessage[playerid], text);
	return 0;
}

ChatSend(language, const str[])
{
	foreach(new i: Player) if(Account[i][pLanguage] == language)
	{
		SendClientMessage(i, -1, str);
	}
	
	return 1;
}
public OnPlayerDamage(&playerid, &Float:amount, &issuerid, &weapon, &bodypart)
{
	if(IsPlayerConnected(issuerid) && IsPlayerConnected(playerid))
	{
		//don't do damage if the player isn't supposed to have the weapon
		if(!WeaponData[issuerid][GetWeaponSlot(weapon)][ACWeaponPossession]) return 0;

		if(ActivityState[issuerid] == ACTIVITY_DUEL && DuelTeam[ActivityStateID[issuerid]][issuerid] == DuelTeam[ActivityStateID[issuerid]][playerid]) return 0;
		if(Account[playerid][TDMTeam] == Account[issuerid][TDMTeam] && Account[playerid][TDMTeam] != 0) return 0;
		if(inAmmunation[playerid] == 1) return 0;
		if(ActivityState[playerid] == ACTIVITY_LOBBY) return 0;
		if(EventDeath[playerid] && ActivityState[playerid] == ACTIVITY_EVENT) return 0;
		if(ActivityState[playerid] == ACTIVITY_EVENT && ActivityStateID[playerid] == EVENT_HEADSHOTSONLY && bodypart != 9) return 0;
		if(ActivityState[playerid] == ACTIVITY_COPCHASE && Account[playerid][pCopchase] == 1) return 0;

		if(Account[playerid][PreventDamage] == 1)
		{
			GameTextForPlayer(issuerid, "~r~Player has disable damaged!", 1000, 3);
			return 0;
		}

		Account[playerid][LobbyPermission] = gettime() + 6;
		TimesHit[playerid] ++;
		LastHit[issuerid] = playerid;
		if(bodypart == 9) Account[issuerid][Headshots]++;
		if(Account[issuerid][Hitmark] == 1) ShowHitMarker(issuerid);

		if(ActivityState[playerid] == ACTIVITY_EVENT && ActivityStateID[playerid] == EVENT_HEADSHOTSONLY && bodypart == 9)
		{
			GameTextForPlayer(issuerid, "~R~Headshot!", 1000, 6);
		}
	}
	return 1;
}

public OnPlayerCommandReceived(cmdid, playerid, const cmdtext[])
{
	if(GetCommandFlags(cmdid) == AD1 && GetPlayerAdminLevel(playerid) < 1)
	{
		SendErrorMessage(playerid, ERROR_ADMIN);
		return false;
	}
	if(GetCommandFlags(cmdid) == AD2 && GetPlayerAdminLevel(playerid) < 2)
	{
		SendErrorMessage(playerid, ERROR_ADMIN);
		return false;
	}
	if(GetCommandFlags(cmdid) == AD3 && GetPlayerAdminLevel(playerid) < 3)
	{
		SendErrorMessage(playerid, ERROR_ADMIN);
		return false;
	}
	if(GetCommandFlags(cmdid) == AD4 && GetPlayerAdminLevel(playerid) < 4)
	{
		SendErrorMessage(playerid, ERROR_ADMIN);
		return false;
	}
	if(GetCommandFlags(cmdid) == AD5 && GetPlayerAdminLevel(playerid) < 5)
	{
		SendErrorMessage(playerid, ERROR_ADMIN);
		return false;
	}
	if(GetCommandFlags(cmdid) == AD6 && GetPlayerAdminLevel(playerid) < 6)
	{
		SendErrorMessage(playerid, ERROR_ADMIN);
		return false;
	}
	if(GetCommandFlags(cmdid) == CM && Account[playerid][ClanManagement] < 1)
	{
		SendErrorMessage(playerid, ERROR_ADMIN);
		return false;
	}
	if(GetCommandFlags(cmdid) == FRM && ActivityState[playerid] != ACTIVITY_FREEROAM)
	{
		SendErrorMessage(playerid, "You must be in freeroam to use this command.");
		return false;
	}
	LastCommandTime[playerid] = gettime();

	if(Account[playerid][LoggedIn] == 0)
	{
		SendErrorMessage(playerid, ERROR_LOGGEDIN);
		return 0;
	}
	if(Account[playerid][AJailTime] > 0)
	{
		SendClientMessage(playerid, -1, "{31AEAA}Notice: {FFFFFF}You are currently in admin-jail.");
		return 0;
	}
	return 1;
}

public OnPlayerCommandPerformed(cmdid, playerid, const cmdtext[], success)
{
	if(!success) SendClientMessage(playerid, COLOR_LIGHTRED, "CmdError: {FFFFFF}Command not recognized, please check the command and try again. For more help please refer to /help.");
	else
	{
		Log(playerid, cmdtext);
	}

	return 1;
}

SetPlayerSkinEx(playerid, skinid)
{
	SetPlayerSkin(playerid, skinid);
	Account[playerid][Skin] = skinid;
	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE `Accounts` SET Skin = %d WHERE SQLID = %d", skinid, Account[playerid][SQLID]));
	return 1;
}

public OnPlayerSpawn(playerid)
{
	AntiDeAMX();
	ApplyAnimation(playerid, "AIRPORT", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "Attractors", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "BAR", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "BASEBALL", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "BD_FIRE", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "BEACH", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "benchpress", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "BF_injection", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "BIKED", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "BIKEH", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "BIKELEAP", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "BIKES", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "BIKEV", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "BIKE_DBZ", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "BMX", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "BOMBER", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "BOX", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "BSKTBALL", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "BUDDY", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "BUS", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "CAMERA", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "CAR", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "CARRY", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "CAR_CHAT", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "CASINO", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "CHAINSAW", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "CHOPPA", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "CLOTHES", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "COACH", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "COLT45", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "COP_AMBIENT", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "COP_DVBYZ", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "CRACK", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "CRIB", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "DAM_JUMP", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "DANCING", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "DEALER", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "DILDO", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "DODGE", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "DOZER", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "DRIVEBYS", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "FAT", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "FIGHT_B", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "FIGHT_C", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "FIGHT_D", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "FIGHT_E", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "FINALE", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "FINALE2", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "FLAME", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "Flowers", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "FOOD", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "Freeweights", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "GANGS", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "GHANDS", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "GHETTO_DB", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "goggles", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "GRAFFITI", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "GRAVEYARD", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "GRENADE", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "GYMNASIUM", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "HAIRCUTS", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "HEIST9", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "INT_HOUSE", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "INT_OFFICE", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "INT_SHOP", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "JST_BUISNESS", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "KART", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "KISSING", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "KNIFE", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "LAPDAN1", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "LAPDAN2", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "LAPDAN3", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "LOWRIDER", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "MD_CHASE", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "MD_END", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "MEDIC", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "MISC", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "MTB", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "MUSCULAR", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "NEVADA", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "ON_LOOKERS", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "OTB", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "PARACHUTE", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "PARK", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "PAULNMAC", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "ped", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "PLAYER_DVBYS", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "PLAYIDLES", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "POLICE", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "POOL", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "POOR", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "PYTHON", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "QUAD", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "QUAD_DBZ", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "RAPPING", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "RIFLE", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "RIOT", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "ROB_BANK", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "RUSTLER", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "RYDER", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "SCRATCHING", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "SHAMAL", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "SHOP", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "SHOTGUN", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "SILENCED", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "SKATE", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "SMOKING", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "SNIPER", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "SPRAYCAN", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "STRIP", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "SUNBATHE", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "SWAT", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "SWEET", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "SWIM", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "SWORD", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "TANK", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "TATTOOS", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "TEC", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "TRAIN", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "TRUCK", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "UZI", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "VAN", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "VENDING", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "VORTEX", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "WAYFARER", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "WEAPONS", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "WUZI", "null", 0.0, 0, 0, 0, 0, 0);
	SetPlayerSkillLevel(playerid, 0, 1);
	SetPlayerSkillLevel(playerid, 1, 999);
	SetPlayerSkillLevel(playerid, 2, 999);
	SetPlayerSkillLevel(playerid, 3, 999);
	SetPlayerSkillLevel(playerid, 4, 1);
	SetPlayerSkillLevel(playerid, 5, 999);
	SetPlayerSkillLevel(playerid, 6, 1);
	SetPlayerSkillLevel(playerid, 7, 999);
	SetPlayerSkillLevel(playerid, 8, 999);
	SetPlayerSkillLevel(playerid, 9, 999);
	SetPlayerSkillLevel(playerid, 10, 999);
	Account[playerid][CBUG] = 0;
	CheckUpgrade(playerid);
	MuteCheck(playerid);
	RemoveRestrictedArenaSkin(playerid);
	SetPlayerColor(playerid, PlayerColors[playerid % sizeof PlayerColors]);

	switch(ActivityState[playerid])
	{
		case ACTIVITY_LOBBY: SendPlayerToLobby(playerid);
		case ACTIVITY_ARENADM: RespawnPlayerInArena(playerid, ActivityStateID[playerid]);
		case ACTIVITY_FREEROAM: SendPlayerToFreeroam(playerid);
		case ACTIVITY_EVENT: HandleEventSpawn(playerid);
		case ACTIVITY_TDM: HandleTDMSpawn(playerid);
		default: SendPlayerToLobby(playerid);
	}
	return 1;
}
CMD:strip(cmdid, playerid, params[])
{
	new type;
	if(sscanf(params,"d",type)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /strip [1-18]");
	switch(type)
	{
		case 1: ApplyAnimation(playerid,"STRIP","PLY_CASH",4.1,1,0,0,1,0);
		case 2: ApplyAnimation(playerid,"STRIP","PUN_CASH",4.1,1,0,0,1,0);
		case 3: ApplyAnimation(playerid,"STRIP","strip_A",4.1,1,0,0,1,0);
		case 4: ApplyAnimation(playerid,"STRIP","strip_B",4.1,1,0,0,1,0);
		case 5: ApplyAnimation(playerid,"STRIP","strip_C",4.1,1,0,0,1,0);
		case 6: ApplyAnimation(playerid,"STRIP","strip_D",4.1,1,0,0,1,0);
		case 7: ApplyAnimation(playerid,"STRIP","strip_E",4.1,1,0,0,1,0);
		case 8: ApplyAnimation(playerid,"STRIP","strip_F",4.1,1,0,0,1,0);
		case 9: ApplyAnimation(playerid,"STRIP","strip_G",4.1,1,0,0,1,0);
		case 10: ApplyAnimation(playerid,"STRIP","STR_A2B",4.1,1,0,0,1,0);
		case 11: ApplyAnimation(playerid,"STRIP","STR_B2A",4.1,1,0,0,1,0);
		case 12: ApplyAnimation(playerid,"STRIP","STR_B2C",4.1,1,0,0,1,0);
		case 13: ApplyAnimation(playerid,"STRIP","STR_C1",4.1,1,0,0,1,0);
		case 14: ApplyAnimation(playerid,"STRIP","STR_C2",4.1,1,0,0,1,0);
		case 15: ApplyAnimation(playerid,"STRIP","STR_C2B",4.1,1,0,0,1,0);
		case 16: ApplyAnimation(playerid,"STRIP","STR_Loop_A",4.1,1,0,0,1,0);
		case 17: ApplyAnimation(playerid,"STRIP","STR_Loop_B",4.1,1,0,0,1,0);
		case 18: ApplyAnimation(playerid,"STRIP","STR_Loop_C",4.1,1,0,0,1,0);
		default: SendClientMessage(playerid, COLOR_GRAY, "USAGE: /strip [1-18]");
	}
	return 1;
}
CMD:buytoken(cmdid, playerid, params[])
{
	if(Account[playerid][Cash] < 5000000) return SendClientMessage(playerid, -1, "{31AEAA}KDM Tokens: You need at least $5,000,000 to purchase a token!");

	GivePlayerMoneyEx(playerid, -5000000);
	Account[playerid][Tokens]++;

	return true;
}
CMD:selltoken(cmdid, playerid, params[])
{
	if(Account[playerid][Tokens] <= 0) return SendClientMessage(playerid, -1, "{31AEAA}KDM Tokens: You don't have any tokens to sell!");

	Account[playerid][Tokens]--;
	GivePlayerMoneyEx(playerid, 5000000);

	return true;
}
CMD:lay(cmdid, playerid, params[])
{
	new type;
	if(sscanf(params,"d",type)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /lay [1-9]");
	switch(type)
	{
		case 1: ApplyAnimation(playerid,"BEACH", "bather", 4.0, 1, 0, 0, 0, 0);
		case 2: ApplyAnimation(playerid,"BEACH", "parksit_w_loop", 4.0, 1, 0, 0, 0, 0);
		case 3: ApplyAnimation(playerid,"BEACH","parksit_m_loop", 4.0, 1, 0, 0, 0, 0);
		case 4: ApplyAnimation(playerid,"BEACH","lay_bac_loop", 4.0, 1, 0, 0, 0, 0);
		case 5: ApplyAnimation(playerid,"BEACH","sitnwait_loop_w", 4.0, 1, 0, 0, 0, 0);
		case 6: ApplyAnimation(playerid,"SUNBATHE","Lay_Bac_in",3.0, 1, 0, 0, 0, 0);
		case 7: ApplyAnimation(playerid,"SUNBATHE","batherdown",3.0, 1, 0, 0, 0, 0);
		case 8: ApplyAnimation(playerid,"SUNBATHE","parksit_m_in",3.0, 1, 0, 0, 0, 0);
		case 9: ApplyAnimation(playerid,"CAR", "Fixn_Car_Loop", 4.0, 1, 0, 0, 0, 0);
		default: SendClientMessage(playerid, COLOR_GRAY, "USAGE: /lay [1-9]");
	}
	return 1;
}
CMD:laugh(cmdid, playerid, params[])
{
	ApplyAnimation(playerid, "RAPPING", "Laugh_01", 4.0, 0, 0, 0, 0, 0);
	return 1;
}

CMD:cry(cmdid, playerid, params[])
{
	ApplyAnimation(playerid,"GRAVEYARD","mrnf_loop",4.0,1,0,0,0,0);
	return 1;
}
CMD:stopanim(cmdid, playerid, params[])
{
	ClearAnimations(playerid);
	return 1;
}
ALT:sa = CMD:stopanim;

CMD:gsign(cmdid, playerid, params[])
{
	new type;
	if(Account[playerid][GsignPack] > 0)
	{
		if(sscanf(params,"d",type)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /gsign [1-6]");
		switch(type)
		{
			case 1: ApplyAnimation(playerid,"GHANDS","gsign1",4.1, 0, 0, 0, 0, 0);
			case 2: ApplyAnimation(playerid,"GHANDS","gsign1LH",4.1, 0, 0, 0, 0, 0);
			case 3: ApplyAnimation(playerid,"GHANDS","gsign2LH", 4.1, 0, 0, 0, 0, 0);
			case 4: ApplyAnimation(playerid,"GHANDS","gsign4",4.1, 0, 0, 0, 0, 0);
			case 5: ApplyAnimation(playerid,"GHANDS","gsign4LH", 4.1, 0, 0, 0, 0, 0);
			case 6: ApplyAnimation(playerid,"GHANDS","gsign5",4.1, 0, 0, 0, 0, 0);
			default: SendClientMessage(playerid, COLOR_GRAY, "USAGE: /gsign [1-6]");
		}
	}
	else
	{
		SendClientMessage(playerid, COLOR_GRAY, "{E13030}[ ! ] {FFFFFF}You don't have the Gsign Pack, you can win this feature in the Premium Crates!");
	}
	return 1;
}
CMD:namechange(cmdid, playerid,params[])
{
	if(Account[playerid][NameChanges] == 0) return SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Notice: {FFFFFF}You don't have any name changes available.");
	if(isnull(params)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /namechange [New Name]");

	yield 1;
	await mysql_aquery_s(SQL_CONNECTION, str_format("SELECT * FROM Accounts WHERE Username = '%e' LIMIT 1", params));
	if(cache_num_rows()) return SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Notice: {FFFFFF}This name already exists in our database.");

	Account[playerid][NameChanges]--;
	SetPlayerName(playerid, params);
	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE Accounts SET Username = '%e' WHERE sqlid = %i", params, Account[playerid][SQLID]));
	SendClientMessage(playerid, COLOR_LGREEN, "{31AEAA}Notice: {FFFFFF}You have successfully changed your username.");
	return 1;
}
CMD:myskin(cmdid, playerid, params[])
{
	if(Account[playerid][CustomSkin] > 0)
	{
		SetPlayerSkinEx(playerid, Account[playerid][CustomSkin]);
	}
	else SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Notice: {FFFFFF}You do not have your own private Custom Skin, you may purchase one on the forums! (/donate)");
	return 1;
}
ALT:gw = CMD:giveweapon;
ALT:w2 = CMD:giveweapon;
CMD:stats(cmdid, playerid, params[])
{
	InfoBoxForPlayer(playerid, "~g~Gathering players information, please wait...");
	ShowStatsForPlayer(playerid, playerid);
	return 1;
}
CMD:help(cmdid, playerid, params[])
{
	StatsLine(playerid);
	SendClientMessage(playerid, COLOR_GRAY, "General Commands");
	SendCommandList(playerid, COLOR_GRAY, 0);
	StatsLine(playerid);
	return 1;
}
CMD:freeroamhelp(cmdid, playerid, params[])
{
	StatsLine(playerid);
	SendClientMessage(playerid, COLOR_GRAY, "Freeroam Commands");
	SendCommandList(playerid, COLOR_GRAY, FRM);
	StatsLine(playerid);
	return 1;
}
CMD<CM>:clanmanagementhelp(cmdid, playerid, params[])
{
	StatsLine(playerid);
	SendClientMessage(playerid, COLOR_GRAY, "Clan Management Commands");
	SendCommandList(playerid, COLOR_GRAY, CM);
	StatsLine(playerid);
	return 1;
}
CMD:clanhelp(cmdid, playerid, params[])
{
	StatsLine(playerid);
	SendClientMessage(playerid, COLOR_GRAY, "Clan Commands");
	SendCommandList(playerid, COLOR_GRAY, CLN);
	StatsLine(playerid);
	return 1;
}
CMD:d(cmdid, playerid, params[])
{
	new str[200];
	if(Account[playerid][Donator] > 0)
	{
		if(sscanf(params, "s[200]", str)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /d [text]");
		format(str, sizeof(str), "{FFFFFF}%s: {dadada}%s", GetName(playerid), str);
		SendDonatorsMessage(1, COLOR_LIGHTRED, str);
	}
	return 1;
}
CMD:pm(cmdid, playerid, params[])
{
	new pID, pmmsg[200];
	if(sscanf(params, "us[200]", pID, pmmsg)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /pm [playerid] [message]");
	if(!IsPlayerConnected(pID)) return SendErrorMessage(playerid, ERROR_OPTION);
	if(!AllowPMS{pID} && GetPlayerAdminLevel(playerid) == 0) return SendClientMessage(playerid, -1, "{31AEAA}Notice: {FFFFFF}This player has disabled his private messages!");
	if(!GetPlayerAdminLevel(playerid) && ChatLocked) return SendClientMessage(playerid, -1, "{31AEAA}Notice: {FFFFFF}The chat is currently locked by an administrator.");
	SendClientMessage(pID, COLOR_WHITE, sprintf("{FF8C00}Private Message from %s(%d):{FFFFFF} %s",GetName(playerid), playerid, pmmsg));
	PlayerPlaySound(pID, 1085, 0.0, 0.0, 0.0);
	SendClientMessage(playerid, COLOR_WHITE, sprintf("{FF8C00}Private Message sent to %s(%d):{FFFFFF} %s",GetName(pID), pID, pmmsg));
	PMReply[pID] = playerid;
	return 1;
}
CMD:r(cmdid, playerid, params[])
{
	if(PMReply[playerid] == -1) return SendClientMessage(playerid, COLOR_WHITE, "{31AEAA}Notice: {FFFFFF}You do not have any PMs to reply to.");
	if(isnull(params)) return SendClientMessage(playerid, COLOR_GREY, "USAGE: /r [message]");

	new playa = PMReply[playerid], str[200];
	format(str, sizeof(str), "%i %s", playa, params);

	cmd_pm(cid_pm, playerid, str);
	return true;
}
ALT:getid = CMD:id;
CMD:id(cmdid, playerid, params[])
{
	if(isnull(params)) return SendClientMessage(playerid, COLOR_GREY, "USAGE: /id [part of name/full name]");

	foreach(new i: Player)
	{
		if(strfind(GetName(i), params, true) != -1)
		{
			SendClientMessage(playerid, COLOR_GREY, sprintf("ID %i:{dadada} %s", i, GetName(i)));
		}
	}
	return true;
}
ALT:announce = CMD:announcement;

CMD:pay(cmdid, playerid, params[])
{
	new player, amount;
	if(sscanf(params, "ui", player, amount)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /pay [playerid] [amount]");
	if(!IsPlayerConnected(player)) return SendErrorMessage(playerid, ERROR_OPTION);
	if(amount > Account[playerid][Cash] || amount > 250000 || amount <= 0 || Account[playerid][Cash] <= 0 || playerid == player) return SendErrorMessage(playerid, ERROR_VALUE);

	SendClientMessage(playerid, COLOR_GRAY, sprintf("{E13030}[ $ ]{FFFFFF} You have sent $%d to {%06x}%s.", amount, GetPlayerColor(player) >>> 8, GetName(player)));
	SendClientMessage(player, COLOR_GRAY, sprintf("{E13030}[ $ ]{FFFFFF} {%06x}%s {FFFFFF}has sent you $%d.", GetPlayerColor(playerid) >>> 8, GetName(playerid), amount));

	GivePlayerMoneyEx(playerid, -amount);
	GivePlayerMoneyEx(player, amount);

	SendAdminsMessage(1, COLOR_LIGHTRED, sprintf("{31AEAA}Admin Notice: {FFFFFF}%s has just paid %s $%s.", GetName(playerid), GetName(player), Comma(amount)));
	return 1;
}
CMD:admins(cmdid, playerid, params[])
{
    new List:adminlist = list_new(), admin[2];
    foreach(new i: Player)
    {    
        if(Account[i][pAdminHide] && GetPlayerAdminLevel(playerid) == 0) continue;
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
        SendClientMessage(playerid, COLOR_GRAY, "There are currently no admins online.");
        return true;
    }
    else {
        SendClientMessage(playerid, COLOR_GREY, "Admins online:");
    }
    list_sort(adminlist, 1, -1, true);
    for_list(i: adminlist)
    {
        iter_get_arr(i, admin);
        SendClientMessage(playerid, COLOR_WHITE, sprintf("(Level %s Admin) %s (ID %i) {FF6347}%s", AdminNames[admin[1]][0], GetName(admin[0]), admin[0], Account[admin[0]][pAdminHide] == 1 ? "(HIDDEN)" : ""));
    }
	if(!GetPlayerAdminLevel(playerid)) SendAdminsMessage(1, COLOR_LIGHTRED, sprintf("{31AEAA}Admin Notice: {FFFFFF}%s has just typed /admins.", GetName(playerid)));
    list_delete(adminlist);
    return true;
}
ALT:staff = CMD:admins;
ALT:mods = CMD:admins;
ALT:moderators = CMD:admins;

CMD:muted(cmdid, playerid, params[])
{
	foreach(new i: Player) if(Account[i][Muted] > 0)
	{
		SendClientMessage(playerid, COLOR_GRAY, sprintf("%s", GetName(i)));
	}
	return 1;
}

CMD:opencrate(cmdid, playerid, params[])
{
	if(!IsPlayerInLobby(playerid)) return SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Crates: {FFFFFF}You must be in the lobby to use this command.");
	if(Account[playerid][PlayerKeys] <= 0) return SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Crates: {FFFFFF}You do not have enough keys to use this feature.");

	OnPremiumCrateStep(playerid, 0);
	Account[playerid][PlayerKeys]--;
	UpdateKeyText(playerid);
	Account[playerid][OpenedCrates]++;
	return 1;
}
CMD:wheelchair(cmdid, playerid, params[])
{
	if(!IsPlayerInLobby(playerid) || Account[playerid][WheelChair] == 0) return true;

	if(Account[playerid][InWheelChair] == 0)
	{
		ApplyAnimation(playerid, "PED", "SEAT_IDLE", 4.1, 0, 0, 0, 1, 0, 1);
		SetPlayerAttachedObject(playerid,0,1369,1,-0.276000,0.089999,-0.011999,178.699661,92.599975,3.100000,0.876001,0.734000,0.779000);
		Account[playerid][InWheelChair] = 1;
	}
	else
	{
		ApplyAnimation(playerid, "PED", "SEAT_UP", 4.0, 0, 0, 0, 0, 0, 1);
		RemovePlayerAttachedObject(playerid , 0);
		Account[playerid][InWheelChair] = 0;
	}
	return 1;
}
CMD:skin(cmdid, playerid, params[])
{
	if(ActivityState[playerid] != ACTIVITY_LOBBY && ActivityState[playerid] != ACTIVITY_FREEROAM) return true;

	if(isnull(params))
	{
		MSelect_Show(playerid, MSelect:skins);
		/*new skins[310];
		new skincount = 0;
		for(new i = 0; i < 311; i++)
		{
			if(i == 74) continue;

			skins[skincount] = i+1;
			skincount++;
		}*/
		//ShowModelSelectionMenuEx(playerid, skins, skincount, "Select a Skin", MODEL_SELECTION_SKINLIST);
		//ShowModelSelectionMenuEx(playerid, items_array[], item_amount, header_text[], extraid, Float:Xrot = 0.0, Float:Yrot = 0.0, Float:Zrot = 0.0, Float:mZoom = 1.0, dialogBGcolor = 0x4A5A6BBB, previewBGcolor = 0x88888899 , tdSelectionColor = 0xFFFF00AA)
	}
	else
	{
		new id = strval(params);
		if(id < 0 || id > 311) return SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Skin Change: {FFFFFF}Skin ID must be between 0 - 299");
		if(Restricted_Skins(id)) return SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Skin Change: {FFFFFF}This skin is restricted and cannot be used!");
		if(!IsNumeric(params)) return SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Skin Change: {FFFFFF}}Skin must be a number!");
		SetPlayerSkinEx(playerid, id);
	}
	return 1;
}

MSelectCreate:skins(playerid)
{
	new skin[310], count = 0;

	for (new i = 1; i < 312; i++) 
	{
		if (i == 74) continue;

		skin[count] = i;
		count++;
	}
	MSelect_Open(playerid, MSelect:skins, skin, sizeof(skin), .header = "Skin list");
}

MSelectResponse:skins(playerid, MSelectType:response, itemid, modelid)
{
	if(modelid != -1)
	{
		SetPlayerSkinEx(playerid, modelid);
		MSelect_Close(playerid);
	}
	return 1;
}

CMD:donatorskins(cmdid, playerid, params[])
{
	if(!Account[playerid][Donator]) return false;

	MSelect_Open(playerid, MSelect:skins, {20022, 20023, 20024, 20050, 20051, 20052, 20147}, 7, .header = "Donator skin list");

	//ShowModelSelectionMenuEx(playerid, {20022, 20023, 20024, 20050, 20051, 20052, 20147}, 7, "Select a Skin", MODEL_SELECTION_DONORSKIN);
	return 1;
}
CMD:donator(cmdid, playerid, params[])
{
	new string[24];
	format(string, sizeof(string), "donator rank: %d", Account[playerid][Donator]);
	SendClientMessage(playerid, -1, string);
	return 1;
}
CMD:forum(cmdid, playerid, params[])
{
	if(Account[playerid][ForumID] == 0 && Account[playerid][ForumCode] == 0 && Account[playerid][Verified] == 0)
	{
		Forum_Dialog(playerid);
	}
	else
	{
		SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Notice: {FFFFFF}You have already set your Forum name. If you chose the wrong one, or got a new Forum account, please use /report.");
	}
	return 1;
}
CMD:findusergroups(cmdid, playerid, params[])
{
	UserGroup_Dialog(playerid);
	return 1;
}
CMD:dmsg(cmdid, playerid, params[])
{
	yield 1;
	await mysql_aquery_s(SQL_CONNECTION, str_format("SELECT * FROM `messages` WHERE `Player` = '%d' AND `Sent` = '0'", Account[playerid][ForumID]));
	if(!cache_num_rows()) return true;

	new message[128];
	for(new i = 0, r = cache_num_rows(); i < r; i++)
	{
		cache_get_value_name(i, "Message", message);
		SendClientMessageToAll(-1, message);
	}

	mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE `messages` SET `Sent` = '1' WHERE `Player` = '%d'", Account[playerid][ForumID]));

	await mysql_aquery_s(SQL_CONNECTION, str_format("SELECT SkinPackUnlock, BronzePackages, SilverPackages, GoldPackages, DiamondPackages, NameChangePackages, PremiumKeyPackages, PurchasedPackage FROM `Accounts` WHERE `SQLID` = '%d'", Account[playerid][SQLID]));
	if(!cache_num_rows()) return true;

	new packageid;
	cache_get_value_name_int(0, "SkinPackUnlock", Account[playerid][SkinPackUnlock]);
	cache_get_value_name_int(0, "BronzePackages", Account[playerid][BronzePackages]);
	cache_get_value_name_int(0, "SilverPackages", Account[playerid][SilverPackages]);
	cache_get_value_name_int(0, "GoldPackages", Account[playerid][GoldPackages]);
	cache_get_value_name_int(0, "DiamondPackages", Account[playerid][DiamondPackages]);
	cache_get_value_name_int(0, "NameChangePackages", Account[playerid][NameChangePackages]);
	cache_get_value_name_int(0, "PremiumKeyPackages", Account[playerid][PremiumKeyPackages]);
	cache_get_value_name_int(0, "PurchasedPackage", packageid);

	SendClientMessage(playerid, -1, sprintf("{31AEAA}Account Upgrade: {FFFFFF}Thank you for your purchase, your items have been given to you as displayed before purchase."));
	SendClientMessage(playerid, COLOR_LIGHTRED, sprintf("NOTICE: USE /UGPRADES TO ACTIVATE YOUR PURCHASED UPGRADE."));

	mysql_tquery(SQL_FORUM, "DELETE FROM `xf_user_upgrade_active` WHERE `xf_user_upgrade_active`.`user_upgrade_id` > 0");

	UpdateLatestDonator(playerid);
	SendClientMessage(playerid, -1, sprintf("purchased package: %d", packageid));
	return 1;
}
CMD:random(cmdid, playerid, params[])
{
	new RandomString[16];
	for(new i = 0; i < sizeof(RandomString); i++)
	format( RandomString, sizeof( RandomString ), "%s%c", RandomString, randomchar());
	SendClientMessage(playerid, -1, RandomString);
	return 1;
}
CMD:debug(cmdid, playerid, params[])
{
	new str[128];
	format(str, sizeof(str), "user_id = %d, forumcode = %d", Account[playerid][ForumID], Account[playerid][ForumCode]);
	SendClientMessage(playerid, -1, str);
	return 1;
}

CMD:youtube(cmdid, playerid, params[])
{
	if(Account[playerid][Donator] > 0)
	{
		if(isnull(params)) return SendClientMessage(playerid, -1, "USAGE: /youtube [URL]");
		format(params, 145, "http://www.youtubeinmp3.com/fetch/?video=%s", params);
		PlayAudioStreamForPlayer(playerid, params);
	}
	else
	{
		SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Notice: {FFFFFF}This is a premium feature, you do not have access to this command.");
	}
	return 1;
}
CMD:donate(cmdid, playerid, params[])
{
	Dialog_Show(playerid, UPGRADE, DIALOG_STYLE_MSGBOX, "Want to donate?", "Donate via www.kokysdm.com/donate\nDonate any amount and you can spend it in-game via /usedonations.\nYou can then activate them via /upgrades.", "Okay", "Close");
	return 1;
}

CMD:freeroam(cmdid, playerid)
{
	if(!IsPlayerInLobby(playerid)) return SendClientMessage(playerid, COLOR_GRAY, "{31AEAA}Notice: {FFFFFF}You must be in the lobby to use this command.");
	
	SendPlayerToFreeroam(playerid);
	InfoBoxForPlayer(playerid, "Welcome to freeroam, use /freeroamhelp for more information.");
	return 1;
}

CMD:rules(cmdid, playerid, params[])
{
	Dialog_Show(playerid, RULES, DIALOG_STYLE_MSGBOX, "Rules", "1. {FFFFFF}No third party modifications\n2. {FFFFFF}No bug abuse(c-roll, c-bug, c-shoot-c)\n3. {FFFFFF}No racism\n4. {FFFFFF}English only\n5. {FFFFFF}Abuse of commands (/lobby to avoid death)", "Okay", "Close");
	return 1;
}

CMD:me(cmdid, playerid, params[])
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	if(Account[playerid][Muted] == 0 && !ChatLocked)
	{
		new str[200];
		if(sscanf(params, "s[200]", str)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /me [message]");

		format(str, sizeof(str), "{d0b6e3}* %s %s", GetName(playerid), str);
		foreach(new i: Player)
		{
			if(IsPlayerInRangeOfPoint(i, 10, x, y, z))
			{
				SendClientMessage(i, -1, str);
			}	
		}
	}
	return 1;
}

CMD:ame(cmdid, playerid, params[])
{
	if(Account[playerid][Muted] == 0 && !ChatLocked)
	{
		new msg[200];
		if(isnull(params)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /ame [action]");
		format(msg, sizeof(msg), "> %s %s", GetName(playerid), params);
		SetPlayerChatBubble(playerid, msg, COLOR_RP, 20.0, 10000);
		if(strlen(params) > MAXLEN)
		{
			new pos = MAXLEN;
			if(pos < MAXLEN-1) pos = MAXLEN;
			format(msg, sizeof(msg), "> %s %.*s ...", GetName(playerid), pos, params);
			SendClientMessage(playerid, COLOR_RP, msg);
			format(msg, sizeof(msg), "> %s ... %s", GetName(playerid), params[pos]);
			SendClientMessage(playerid, COLOR_RP, msg);
		}
		else
		{
			format(msg, sizeof(msg), "> %s %s", GetName(playerid), params);
			SendClientMessage(playerid, COLOR_RP, msg);
		}
	}
	return 1;
}

CMD:do(cmdid, playerid, params[])
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	if(Account[playerid][Muted] == 0 && !ChatLocked)
	{
		new str[200];
		if(sscanf(params, "s[200]", str)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /do [text]");
		format(str, sizeof(str), "{d0b6e3}* %s (( %s ))", str, GetName(playerid));
		foreach(new i: Player)
		{
			if(IsPlayerInRangeOfPoint(i, 10, x, y, z))
			{
				SendClientMessage(i, -1, str);
			}	
		}
	}	
	return 1;
}

CMD:walk(cmdid, playerid, params[])
{
	new walkstyle;
	if(sscanf(params, "d", walkstyle)) return SendClientMessage(playerid, COLOR_GRAY, "USAGE: /walk [0-13]");
	switch(walkstyle)
	{
		case 0: ApplyAnimation(playerid, "PED", "WALK_civi", 4.1, 1, 1, 1, 1, 1, 1);
		case 1: ApplyAnimation(playerid, "PED", "WALK_civi", 4.1, 1, 1, 1, 1, 1, 1);
		case 2: ApplyAnimation(playerid, "PED", "WALK_fatold", 4.1, 1, 1, 1, 1, 1, 1);
		case 3: ApplyAnimation(playerid, "FAT", "FatWalk", 4.1, 1, 1, 1, 1, 1, 1);
		case 4: ApplyAnimation(playerid, "MUSCULAR", "MuscleWalk", 4.1, 1, 1, 1, 1, 1, 1);
		case 5: ApplyAnimation(playerid, "PED", "WALK_gang1", 4.1, 1, 1, 1, 1, 1, 1);
		case 6: ApplyAnimation(playerid, "PED", "WALK_gang2", 4.1, 1, 1, 1, 1, 1, 1);
		case 7: ApplyAnimation(playerid, "PED", "WALK_player", 4.1, 1, 1, 1, 1, 1, 1);
		case 8: ApplyAnimation(playerid, "PED", "WALK_old", 4.1, 1, 1, 1, 1, 1, 1);
		case 9: ApplyAnimation(playerid, "PED", "WALK_wuzi", 4.1, 1, 1, 1, 1, 1, 1);
		case 10: ApplyAnimation(playerid, "PED", "WOMAN_walkbusy", 4.1, 1, 1, 1, 1, 1, 1);
		case 11: ApplyAnimation(playerid, "PED", "WOMAN_walkfatold", 4.1, 1, 1, 1, 1, 1, 1);
		case 12: ApplyAnimation(playerid, "PED", "WOMAN_walknorm", 4.1, 1, 1, 1, 1, 1, 1);
		case 13: ApplyAnimation(playerid, "PED", "WOMAN_walksexy", 4.1, 1, 1, 1, 1, 1, 1);
	}
	return 1;
}
ALT:colour = CMD:color;
SendCommandList(playerid, color, cmdflag)
{
	new cmdname[32], alts[15], altcount, string[200];
	for(new i = 0, j = GetTotalCommandCount(); i < j; i++)
	{
		if(GetCommandFlags(i) == cmdflag && !IsCommandAlternate(i))
		{
			GetCommandName(i, cmdname);
			altcount = GetAlternateCommands(i, alts);
			strcat(string, sprintf("/%s ", cmdname));
			if(altcount != 0)
			{
				strcat(string, "(");
				for(new c = 0; c < altcount; c++)
				{
					GetCommandName(alts[c], cmdname);
					strcat(string, sprintf("/%s", cmdname));
					if(altcount > 1) strcat(string, " ");
				}
				strcat(string, ") ");
			}
			if(strlen(string) > 120)
			{
				SendClientMessage(playerid, color, string);
				string[0] = EOS;
			}
		}
	}
	if(strlen(string)) SendClientMessage(playerid, color, string);
	return true;
}
IP_Lookup(playerid)
{
	new ip[18];
	GetPlayerIp(playerid, ip, sizeof(ip));
	mysql_pquery_s(SQL_CONNECTION, str_format("SELECT NULL FROM `Bans` WHERE IP = '%e' LIMIT 1", ip), "Lookup_Result", "d", playerid);
	return 1;
}

Account_Lookup(playerid)
{
	mysql_pquery_s(SQL_CONNECTION, str_format("SELECT NULL FROM `Bans` WHERE A_ID = %d OR PlayerName = '%e' LIMIT 1", Account[playerid][SQLID], GetName(playerid)), "Lookup_Result", "d", playerid);
	return 1;
}

forward Lookup_Result(playerid);
public Lookup_Result(playerid)
{
	if(cache_num_rows())
	{
		SendClientMessage(playerid, COLOR_WHITE, "You are banned from the server.");
		Dialog_Show(playerid, NONE, DIALOG_STYLE_MSGBOX, "Information", "You are banned from the server.", "Close", "");
		Account[playerid][LoggedIn] = 0;
		KickPlayer(playerid);
		return 0;
	}
	else
	{
		mysql_pquery_s(SQL_CONNECTION, str_format("UPDATE `Accounts` SET Banned = 0 WHERE SQLID = %d LIMIT 1", Account[playerid][SQLID]));
	}
	return 1;
}

SendDMMessage(dmid, color, const message[])
{
	foreach(new i: ArenaOccupants[dmid])
	{
		SendClientMessage(i, color, message);
	}
	return true;
}
ShowSyntax(playerid, const message[])
{
	SendClientMessage(playerid, COLOR_GRAY, sprintf("USAGE: %s", message));
	return true;
}

FreezePlayer(playerid, interval)
{
	TogglePlayerControllable(playerid, false);
	SetTimerEx("UnfreezePlayer", interval, false, "i", playerid);
	return true;
}

forward UnfreezePlayer(playerid);
public UnfreezePlayer(playerid)
{
	TogglePlayerControllable(playerid, true);
}

DestroyAllPlayerObjects(playerid)
{
	for(new i = 0; i < MAX_OBJECTS; i++)
	{
		if(IsValidPlayerObject(playerid, i))
		{
			DestroyPlayerObject(playerid, i);
		}
	}
	return true;
}
IsPlayerPaused(playerid)
{
	if((gettime() - PauseTick[playerid]) > 5) return true;
	return false;
}
CMD:unlockapril(cmdid, playerid, params[])
{
	for(new i = 0; i < sizeof(ServerSkinData); i++)
	{
		if(!strcmp(ServerSkinData[i][sSkinMonth], "April 2018", false))
		{
			UnlockSkinForPlayer(playerid, i);
		}
	}
	SendClientMessage(playerid, -1, "{31AEAA}Reward: {FFFFFF}You have unlocked all of the April 2018 skins. Thank you for your patience on the delayed update. (/customskins > April 2018)");
	return 1;
}
CMD:unlockmay(cmdid, playerid, params[])
{
	for(new i = 0; i < sizeof(ServerSkinData); i++)
	{
		if(!strcmp(ServerSkinData[i][sSkinMonth], "May 2018", false))
		{
			UnlockSkinForPlayer(playerid, i);
		}
	}
	SendClientMessage(playerid, -1, "{31AEAA}Reward: {FFFFFF}You have unlocked all of the May 2018 skins. Thank you for your patience on the delayed update. (/customskins > May 2018)");
	return 1;
}

CMD:tokenhelp(cmdid, playerid, params[])
{
	SendClientMessage(playerid, COLOR_LIGHTRED, "[ KDM TOKENS ]");
	SendClientMessage(playerid, COLOR_LIGHTRED, "1. {FFFFFF}Tokens can be used to purchase rare skins or items. These items are not easy to aquire.");
	SendClientMessage(playerid, COLOR_LIGHTRED, "2. {FFFFFF}There is a 1/10000 chance you can get a token every time you kill a player.");
	SendClientMessage(playerid, COLOR_LIGHTRED, "3. {FFFFFF}You can buy tokens via /buytoken. Tokens are valued at $5,000,000 per token.");
	SendClientMessage(playerid, COLOR_LIGHTRED, "4. {FFFFFF}You can sell tokens via /selltoken. Tokens are valued at $5,000,000 per token.");
	SendClientMessage(playerid, COLOR_LIGHTRED, "5. {FFFFFF}You can also get tokens by purchasing them for real money via the forums. (/donate)");
	SendClientMessage(playerid, COLOR_LIGHTRED, "6. {FFFFFF}Tokens can be spent in the server hub. (/serverhub)");

	return true;
}
CMD:skinrollhelp(cmdid, playerid, params[])
{
	SendClientMessage(playerid, COLOR_LIGHTRED, "[ SKIN ROLL ]");
	SendClientMessage(playerid, COLOR_LIGHTRED, "1. {FFFFFF}The /skinroll feature can be used to aquire server sided skins.");
	SendClientMessage(playerid, COLOR_LIGHTRED, "2. {FFFFFF}There are 12 new skins each month.");
	SendClientMessage(playerid, COLOR_LIGHTRED, "3. {FFFFFF}Each skin roll is valued at $10,000. You can use the /skinroll command in the lobby. (/lobby)");
	SendClientMessage(playerid, COLOR_LIGHTRED, "4. {FFFFFF}You can access these custom skins via /customskins.");
	SendClientMessage(playerid, COLOR_LIGHTRED, "5. {FFFFFF}Like a skin from a month that's already gone? You can purchase a Skin Pack Unlocker via the forums! (/donate)");
	SendClientMessage(playerid, COLOR_LIGHTRED, "6. {FFFFFF}Diamond V.I.P players are refunded via /skinroll if they get a skin they have already unlocked.");
	return true;
}
CMD:crateshelp(cmdid, playerid, params[])
{
	SendClientMessage(playerid, COLOR_LIGHTRED, "[ CRATES ]");
	SendClientMessage(playerid, COLOR_LIGHTRED, "1. {FFFFFF}Crates can be used to win items such as money, access to donator commands and more!");
	SendClientMessage(playerid, COLOR_LIGHTRED, "2. {FFFFFF}There is a 1/100 chance you can get a Premium Key everytime you kill a player.");
	SendClientMessage(playerid, COLOR_LIGHTRED, "3. {FFFFFF}You can buy Premium Keys via /buykey. Tokens are valued at $100,000 per token.");
	SendClientMessage(playerid, COLOR_LIGHTRED, "4. {FFFFFF}You can use your keys via /opencrate command at the lobby. (/lobby)");
	SendClientMessage(playerid, COLOR_LIGHTRED, "5. {FFFFFF}You can also get Premium Keys by purchasing them for real money via the forums. (/donate)");
	SendClientMessage(playerid, COLOR_LIGHTRED, "6. {FFFFFF}Donators are refunded via /skinroll if they get a skin they have already unlocked.");
	return true;
}
CMD:serverhub(cmdid, playerid)
{
	if(!IsPlayerInLobby(playerid)) return SendClientMessage(playerid, -1, "{31AEAA}Notice: {FFFFFF}You must be in the lobby to use this command.");

	inServerHub[playerid] = 1;

	SetPlayerPosEx(playerid, 1710.433715, -1669.379272, 20.225049, 18, 0);
	SendClientMessage(playerid, COLOR_LIGHTRED, "Server Hub: {FFFFFF}Welcome to the Server Hub, here you can purchase rare skins and items.");

	ReloadRareSkins();

	return true;
}
CMD:setlanguage(cmdid, playerid, params[])
{
	Dialog_Show(playerid, SELECTLANGUAGE, DIALOG_STYLE_LIST, "Language Selection", "English\nTurkish\nFrench\nPortuguese\nEspanol\nOther", "Select", "Cancel");

	return true;
}
Dialog:SELECTLANGUAGE(playerid, response, listitem, inputtext[])
{
	if(!response) return Dialog_Show(playerid, SELECTLANGUAGE, DIALOG_STYLE_LIST, "Language Selection", "English\nTurkish\nFrench\nPortuguese\nESpanol", "Select", "Cancel");

	if(response)
	{
		switch(listitem)
		{
			case 0:
			{
				SendClientMessage(playerid, COLOR_LIGHTRED, "Language Selection: {FFFFFF}You have selected English as your language. You will now only speak with English players in the public chat.");
				Account[playerid][pLanguage] = LANGUAGE_ENGLISH;
			}
			case 1:
			{
				SendClientMessage(playerid, COLOR_LIGHTRED, "Language Selection: {FFFFFF}You have selected Turkish as your language. You will now only speak with Turkish players in the public chat.");
				Account[playerid][pLanguage] = LANGUAGE_TURKISH;				
			}
			case 2:
			{
				SendClientMessage(playerid, COLOR_LIGHTRED, "Language Selection: {FFFFFF}You have selected French as your language. You will now only speak with French players in the public chat.");
				Account[playerid][pLanguage] = LANGUAGE_FRENCH;				
			}
			case 3:
			{
				SendClientMessage(playerid, COLOR_LIGHTRED, "Language Selection: {FFFFFF}You have selected Portuguese as your language. You will now only speak with Portuguese players in the public chat.");
				Account[playerid][pLanguage] = LANGUAGE_PORTUGUESE;				
			}
			case 4:
			{
				SendClientMessage(playerid, COLOR_LIGHTRED, "Language Selection: {FFFFFF}You have selected Espanol as your language. You will now only speak with Espanol players in the public chat.");
				Account[playerid][pLanguage] = LANGUAGE_ESPANOL;				
			}
			case 5:
			{
				SendClientMessage(playerid, COLOR_LIGHTRED, "Language Selection: {FFFFFF}You have selected other as your language. You will now only speak with other players in the public chat.");
				Account[playerid][pLanguage] = LANGUAGE_OTHER;				
			}
		}
		return 0;
	}
	return true;
}
CreatePlayerTextDraws(playerid)
{
	InfoBox[playerid] = CreatePlayerTextDraw(playerid, 323.000030, 363.377899, "Testing");
	PlayerTextDrawLetterSize(playerid, InfoBox[playerid], 0.309000, 1.417481);
	PlayerTextDrawTextSize(playerid, InfoBox[playerid], -114.333312, 300.325866);
	PlayerTextDrawAlignment(playerid, InfoBox[playerid], 2);
	PlayerTextDrawColor(playerid, InfoBox[playerid], -1);
	PlayerTextDrawUseBox(playerid, InfoBox[playerid], true);
	PlayerTextDrawBoxColor(playerid, InfoBox[playerid], 51);
	PlayerTextDrawSetShadow(playerid, InfoBox[playerid], 0);
	PlayerTextDrawSetOutline(playerid, InfoBox[playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, InfoBox[playerid], 255);
	PlayerTextDrawFont(playerid, InfoBox[playerid], 1);
	PlayerTextDrawSetProportional(playerid, InfoBox[playerid], 1);

	InfoBoxOS[playerid] = CreatePlayerTextDraw(playerid, 323.000030, 410.377899, "Testing");
	PlayerTextDrawLetterSize(playerid, InfoBoxOS[playerid], 0.309000, 1.417481);
	PlayerTextDrawTextSize(playerid, InfoBoxOS[playerid], -114.333312, 300.325866);
	PlayerTextDrawAlignment(playerid, InfoBoxOS[playerid], 2);
	PlayerTextDrawColor(playerid, InfoBoxOS[playerid], -1);
	PlayerTextDrawUseBox(playerid, InfoBoxOS[playerid], true);
	PlayerTextDrawBoxColor(playerid, InfoBoxOS[playerid], 51);
	PlayerTextDrawSetShadow(playerid, InfoBoxOS[playerid], 0);
	PlayerTextDrawSetOutline(playerid, InfoBoxOS[playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, InfoBoxOS[playerid], 255);
	PlayerTextDrawFont(playerid, InfoBoxOS[playerid], 1);
	PlayerTextDrawSetProportional(playerid, InfoBoxOS[playerid], 1);

	Account[playerid][TextDraw][0] = CreatePlayerTextDraw(playerid, 290.000122, 31.540763, "Starts_in:");
	PlayerTextDrawLetterSize(playerid, Account[playerid][TextDraw][0], 0.370999, 1.906962);
	PlayerTextDrawAlignment(playerid, Account[playerid][TextDraw][0], 1);
	PlayerTextDrawColor(playerid, Account[playerid][TextDraw][0], 13500671);
	PlayerTextDrawSetShadow(playerid, Account[playerid][TextDraw][0], 0);
	PlayerTextDrawBackgroundColor(playerid, Account[playerid][TextDraw][0], 255);
	PlayerTextDrawFont(playerid, Account[playerid][TextDraw][0], 1);
	PlayerTextDrawSetProportional(playerid, Account[playerid][TextDraw][0], 1);

	Account[playerid][TextDraw][1] = CreatePlayerTextDraw(playerid, 318.999908, 48.962959, "30_seconds");
	PlayerTextDrawLetterSize(playerid, Account[playerid][TextDraw][1], 0.379999, 2.027256);
	PlayerTextDrawTextSize(playerid, Account[playerid][TextDraw][1], 0.000000, 16.000000);
	PlayerTextDrawAlignment(playerid, Account[playerid][TextDraw][1], 2);
	PlayerTextDrawColor(playerid, Account[playerid][TextDraw][1], -1);
	PlayerTextDrawSetShadow(playerid, Account[playerid][TextDraw][1], 0);
	PlayerTextDrawBackgroundColor(playerid, Account[playerid][TextDraw][1], 255);
	PlayerTextDrawFont(playerid, Account[playerid][TextDraw][1], 1);
	PlayerTextDrawSetProportional(playerid, Account[playerid][TextDraw][1], 1);

	Account[playerid][TextDraw][2] = CreatePlayerTextDraw(playerid, 293.666717, 1.674252, "Time_left:");
	PlayerTextDrawLetterSize(playerid, Account[playerid][TextDraw][2], 0.302666, 1.616592);
	PlayerTextDrawAlignment(playerid, Account[playerid][TextDraw][2], 1);
	PlayerTextDrawColor(playerid, Account[playerid][TextDraw][2], 10281471);
	PlayerTextDrawSetShadow(playerid, Account[playerid][TextDraw][2], 0);
	PlayerTextDrawBackgroundColor(playerid, Account[playerid][TextDraw][2], 255);
	PlayerTextDrawFont(playerid, Account[playerid][TextDraw][2], 1);
	PlayerTextDrawSetProportional(playerid, Account[playerid][TextDraw][2], 1);

	Account[playerid][TextDraw][3] = CreatePlayerTextDraw(playerid, 317.333496, 14.948158, "10_minutes");
	PlayerTextDrawLetterSize(playerid, Account[playerid][TextDraw][3], 0.375667, 1.960889);
	PlayerTextDrawAlignment(playerid, Account[playerid][TextDraw][3], 2);
	PlayerTextDrawColor(playerid, Account[playerid][TextDraw][3], -1);
	PlayerTextDrawSetShadow(playerid, Account[playerid][TextDraw][3], 0);
	PlayerTextDrawBackgroundColor(playerid, Account[playerid][TextDraw][3], 255);
	PlayerTextDrawFont(playerid, Account[playerid][TextDraw][3], 1);
	PlayerTextDrawSetProportional(playerid, Account[playerid][TextDraw][3], 1);

	Account[playerid][TextDraw][4] = CreatePlayerTextDraw(playerid, 544.000000, 300, "Headshots:");
	PlayerTextDrawLetterSize(playerid, Account[playerid][TextDraw][4], 0.337999, 1.886222);
	PlayerTextDrawAlignment(playerid, Account[playerid][TextDraw][4], 1);
	PlayerTextDrawColor(playerid, Account[playerid][TextDraw][4], 0xDC143CFF);
	PlayerTextDrawSetShadow(playerid, Account[playerid][TextDraw][4], 0);
	PlayerTextDrawBackgroundColor(playerid, Account[playerid][TextDraw][4], 255);
	PlayerTextDrawFont(playerid, Account[playerid][TextDraw][4], 1);
	PlayerTextDrawSetProportional(playerid, Account[playerid][TextDraw][4], 1);

	Account[playerid][TextDraw][5] = CreatePlayerTextDraw(playerid, 607.250000, 300, "0"); //63.25 difference
	PlayerTextDrawLetterSize(playerid, Account[playerid][TextDraw][5], 0.337999, 1.886222);
	PlayerTextDrawAlignment(playerid, Account[playerid][TextDraw][5], 1);
	PlayerTextDrawColor(playerid, Account[playerid][TextDraw][5], -1);
	PlayerTextDrawSetShadow(playerid, Account[playerid][TextDraw][5], 0);
	PlayerTextDrawBackgroundColor(playerid, Account[playerid][TextDraw][5], 255);
	PlayerTextDrawFont(playerid, Account[playerid][TextDraw][5], 1);
	PlayerTextDrawSetProportional(playerid, Account[playerid][TextDraw][5], 1);
}
CreateServerTextDraws()
{
	ChangeColor[0] = TextDrawCreate(17.0, 138.0, "box");
	TextDrawLetterSize(ChangeColor[0], 0.0, 17.0);
	TextDrawTextSize(ChangeColor[0], 171.0, 0.0);
	TextDrawAlignment(ChangeColor[0], 1);
	TextDrawColor(ChangeColor[0], -1);
	TextDrawUseBox(ChangeColor[0], 1);
	TextDrawBoxColor(ChangeColor[0], 102);
	TextDrawSetOutline(ChangeColor[0], 0);
	TextDrawBackgroundColor(ChangeColor[0], 255);
	TextDrawFont(ChangeColor[0], 1);
	TextDrawSetProportional(ChangeColor[0], 1);
	TextDrawSetShadow(ChangeColor[0], 0);

	//mapping
	ChangeColor[1] = TextDrawCreate(138.667617, 298.116699, "Close");
	TextDrawLetterSize(ChangeColor[1], 0.400000, 1.600000);
	TextDrawTextSize(ChangeColor[1], 17.0, 62.327926);
	TextDrawAlignment(ChangeColor[1], 2);
	TextDrawColor(ChangeColor[1], -1);
	TextDrawUseBox(ChangeColor[1], 1);
	TextDrawBoxColor(ChangeColor[1], 102);
	TextDrawSetOutline(ChangeColor[1], 0);
	TextDrawBackgroundColor(ChangeColor[1], 255);
	TextDrawFont(ChangeColor[1], 2);
	TextDrawSetProportional(ChangeColor[1], 1);
	TextDrawSetShadow(ChangeColor[1], 0);
	TextDrawSetSelectable(ChangeColor[1], 1);

	//hitmarker
	HitMark_centre = TextDrawCreate(334.500000, 173.600000, "X");
	TextDrawBackgroundColor(HitMark_centre, 225);
	TextDrawFont(HitMark_centre, 2);
	TextDrawLetterSize(HitMark_centre, 0.500000, 1.000000);
	TextDrawColor(HitMark_centre, -1);
	TextDrawSetProportional(HitMark_centre, 1);
	TextDrawSetOutline(HitMark_centre, 1);
	TextDrawSetShadow(HitMark_centre, 0);

	//login 
	logintd = TextDrawCreate(183.5000, -41.0000, "mdl-1087:Koky_DM");
	TextDrawFont(logintd, 4);
	TextDrawLetterSize(logintd, 0.6399, 2.4999);
	TextDrawAlignment(logintd, 2);
	TextDrawColor(logintd, -1);
	TextDrawSetShadow(logintd, 0);
	TextDrawSetOutline(logintd, 0);
	TextDrawBackgroundColor(logintd, 255);
	TextDrawSetProportional(logintd, 1);
	TextDrawUseBox(logintd, 1);
	TextDrawBoxColor(logintd, 255);
	TextDrawTextSize(logintd, 290.0000, 322.5000);

	new Float:X=19.0,Float:Y=139.0,count = 1;
	for(new i=2; i < sizeof(ChangeColor); i++)
	{
		ChangeColor[i] = TextDrawCreate(X, Y, "box");
		TextDrawBackgroundColor(ChangeColor[i], AllCarColors[ColorsAvailable[i-2]]);
		TextDrawLetterSize(ChangeColor[i], 0.0, 18.0);
		TextDrawTextSize(ChangeColor[i], 18.0, 18.0);
		TextDrawAlignment(ChangeColor[i], 1);
		TextDrawColor(ChangeColor[i], -1);
		TextDrawUseBox(ChangeColor[i], 1);
		TextDrawBoxColor(ChangeColor[i], 0);
		TextDrawSetOutline(ChangeColor[i], 0);
		TextDrawFont(ChangeColor[i], 5);
		TextDrawSetProportional(ChangeColor[i], 1);
		TextDrawSetShadow(ChangeColor[i], 1);
		TextDrawSetPreviewModel(ChangeColor[i], 19349);
		TextDrawSetPreviewRot(ChangeColor[i], -16.0, 0.0, -180.0, 0.7);
		TextDrawSetSelectable(ChangeColor[i], 1);

		X+=19.0;
		count++;
		if(count == 9)
		{
			Y+=19.0;
			X = 19.0;
			count = 1;
		}
	}
}
CreateVehicleEx(model, Float:x, Float:y, Float:z, Float:a, col1, col2, r_delay, const numberplate[] = "", siren = 0)
{
	new id = CreateVehicle(model, x, y, z, a, col1, col2, r_delay, siren);

	if(strlen(numberplate) == 0) format(numberplate, 32, "KDM %i", id);
	SetVehicleNumberPlate(id, numberplate);
	return id;
}