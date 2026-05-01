// Moved the All Range Callback so it'll actually work
function slimegirlRavagerAllRange(entity, target) {
	RFTrace(entity)
	RFTrace(entity.Enemy.ravage.addSlimeChance)
	RFTrace(KDModSettings['RavagerFramework'].ravagerSlimeAddChance)
	let roll = Math.random() < entity.Enemy.ravage.addSlimeChance
	if(roll) {
		let restraintAdd = KinkyDungeonGetRestraint({tags: ["slimeRestraintsRandom"]}, MiniGameKinkyDungeonLevel + 1, KinkyDungeonMapIndex[MiniGameKinkyDungeonCheckpoint])
		if(!restraintAdd) {
			KDAdvanceSlime(false, "");
			KinkyDungeonSendTextMessage(5, TextGet("KinkyDungeonSlimeHarden"), "#ff44ff", 3);
		} else {
			KinkyDungeonAddRestraintIfWeaker(restraintAdd)
			KinkyDungeonSendTextMessage(5, TextGet("KinkyDungeonSlimeSpread"), "#ff44ff", 3);
		}
	}
}
if (!RFAddCallback('slimegirlRavagerAllRangeCallback', slimegirlRavagerAllRange)) {
	RFError('[Ravager Framework][Slimegirl Ravager] Failed to add slimegirlRavagerAllRangeCallback!')
}
// Outfits
KDModelDresses['SlimegirlRavager'] = [{"Item":"FashionLatexMittens","Group":"Mittens","Filters":{"LatexLeft":{"gamma":1,"saturation":0,"contrast":1,"brightness":1,"red":5/3,"green":1/3,"blue":32/51,"alpha":1},"Mitten":{"gamma":1,"saturation":0,"contrast":0.81,"brightness":1,"red":71/17,"green":47/51,"blue":28/17,"alpha":1}},"Properties":{"LatexLeft":{},"Zipper":{"Protected":"0","ExtraHidePoses":["Xray"],"XOffset":57.62,"YOffset":-153.68,"ExtraRequirePoses":["Xray"]},"Mitten":{}}}]
KDModelHair['SlimegirlRavager'] = [{"Item":"Curly","Group":"Hair","Filters":{"Curly":{"gamma":1,"saturation":0,"contrast":1,"brightness":1,"red":5/3,"green":1/3,"blue":32/51,"alpha":1}},"Properties":{"Curly":{}}},{"Item":"Ponytail","Group":"Hair","Filters":{"Ponytail":{"gamma":1,"saturation":0,"contrast":1,"brightness":1,"red":5/3,"green":1/3,"blue":32/51,"alpha":1}},"Properties":{"Ponytail":{"Protected":"","LayerBonus":-100,"XOffset":1501.45,"YOffset":479.31,"XPivot":1390,"YPivot":245,"XScale":2,"YScale":2}}},{"Item":"RavLargeHeartHairpin","Group":"Hair","Filters":{"LargeHeartHairpin":{"gamma":1,"saturation":0,"contrast":1,"brightness":1,"red":11/17,"green":0,"blue":2,"alpha":1}},"Properties":{"LargeHeartHairpin":{"XScale":1.8,"XOffset":-1000,"YScale":1.8,"YOffset":-330}}},{"Item":"FluffyPonytail","Group":"Hair","Filters":{"Ponytail2":{"gamma":1,"saturation":0,"contrast":1,"brightness":1,"red":71/51,"green":16/51,"blue":25/51,"alpha":1}},"Properties":{"Ponytail2":{"Rotation":-90,"YOffset":1750,"XOffset":950}}},{"Item":"FluffyPonytailRav","Group":"Hair","Filters":{"Ponytail2":{"gamma":1,"saturation":0,"contrast":1,"brightness":1,"red":89/51,"green":6/17,"blue":32/51,"alpha":1}},"Properties":{"Ponytail2":{"Rotation":-90,"YOffset":1900,"XOffset":1090}}},{"Item":"FluffyPonytailRav2","Group":"Hair","Filters":{"Ponytail2":{"gamma":1,"saturation":0,"contrast":1,"brightness":1,"red":89/51,"green":6/17,"blue":32/51,"alpha":1}},"Properties":{"Ponytail2":{"Rotation":-45,"YOffset":1400,"XOffset":60}}}]
KDModelBody['SlimegirlRavager'] = [{"Item":"Body","Group":"Body","Filters":{"Torso":{"gamma":1,"saturation":0,"contrast":34/25,"brightness":1,"red":1,"green":4/17,"blue":7/17,"alpha":1},"Head":{"gamma":1,"saturation":0,"contrast":34/25,"brightness":1,"red":1,"green":4/17,"blue":7/17,"alpha":1},"Nipples":{"gamma":1,"saturation":0,"contrast":0.03,"brightness":1,"red":95/51,"green":20/51,"blue":14/17,"alpha":1}},"Properties":{"Head":{},"Torso":{}}}]
KDModelFace['SlimegirlRavager'] = [{"Item":"KoiBlush","Group":"FaceKoi"},{"Item":"KjusBrows","Group":"FaceKjus"},{"Item":"KjusMouth","Group":"FaceKjus","Filters":{"Mouth":{"gamma":1,"saturation":1,"contrast":1,"brightness":1,"red":1,"green":1,"blue":1,"alpha":1}}},{"Item":"KjusEyes3","Group":"EyesK3","Filters":{"Eyes":{"gamma":1,"saturation":0,"contrast":0.96,"brightness":1,"red":7/17,"green":56/51,"blue":91/51,"alpha":1},"Eyes2":{"gamma":1,"saturation":0,"contrast":0.96,"brightness":1,"red":7/17,"green":56/51,"blue":91/51,"alpha":1}}},{"Item":"Fear","Group":"Expressions"}]
KDModelStyles['SlimegirlRavager'] = {
	Hairstyle: [ 'SlimegirlRavager' ],
	Bodystyle: [ 'SlimegirlRavager' ],
	Facestyle: [ 'SlimegirlRavager' ],
}
/**********************************************
 * Enemy definition: SLIMEGIRL
	A kinda weak slimegirl, that...
	- Has a special attack that applies the ravage "effect"
		- Has a callback that has a chance spread slime while 'busy'.
		- Can go through slime, rubber, and liquid metal!
*/
let slimeRavager = {
	style: 'SlimegirlRavager',
	outfit: 'SlimegirlRavager',
	// Key to signal we added this so we can make sure we don't remove an enemy with the same name added by someone else (such as someone else making a mod to modify the bandit ravager)
	// If you're making your own ravager, change this key or just remove it
	addedByMod: 'RavagerFramework',
	RFDisableRefvar: "ravagerDisableSlimegirl",
	// ID data
	name: "SlimeRavager",
	faction: "Slime",
	clusterWith: "slime",
	playLine: "SlimeAdv",
	bound: "SlimeAdv", // Not sure what this will end up requiring, we'll see eventually
	squeeze: true,
	color: "#FF00FF",
	tags: KDMapInit([ 
		"opendoors",
		"closedoors",
		"slime",  
		"melee",
		"meleeresist",
		"electricweakness",
		"acidresist",
		"chainimmune",
		"iceweakness",
		"unflinching", // Makes enemy unable to be pulled/pushed. Maybe don't remove this
		"nosub", // Probably don't want to remove this one
		"hunter"
	]),
	// AI
	ignorechance: 0,
	followRange: 1,
	AI: "hunt",
	Animations: ["squishy"],
	// Core stats
	armor: 1.5,
	maxhp: 10,
	minLevel: 2, // This affects the earliest floor they can spawn on
	weight: 6,
	visionRadius: 5,
	blindSight: 2.5,
	movePoints: 3,
	evasion: 0.3,
	sneakThreshold: 1,
	// Main attack
	dmgType: "grope",
	attack: "MeleeEffect",
	attackLock: "White",
	power: 1,
	attackPoints: 2,
	attackWidth: 1,
	attackRange: 1,
	fullBoundBonus: 0,
	disarm: 0.2,
	hitsfx: "Grab",
	// Spawning/drops
	terrainTags: {"increasingWeight":-1, "slime": 4, "slimeOptOut": -2, "slimePref": 2, "jungle": 20, "alchemist": 4},
	allFloors: true,
	shrines: ["Latex"],
	dropTable: [{name: "Nothing", weight: 10}, {name: "StaffGlue", weight: 3, ignoreInInventory: true}, {name: 'SlimeSword', weight: 3, ignoreInInventory: true}],
	/*
		Ravage setup
	*/
	ravage: {
		addSlimeChance: 0.05, // Chance to add slime restraint to player
		targets: [ "ItemVulva", "ItemMouth", "ItemButt" ],
		refractory: 50,
		needsEyes: false,
		bypassSpecial: [ "Slime", "Rubber", "LiquidMetal" ],
		
		onomatopoeia: "SlimeOnomatopoeia",
		doneTaunts: "SlimeDoneTaunts",
		// A callback for the slime girl to add slime to the player
		allRangeCallback: 'slimegirlRavagerAllRangeCallback',
		ranges: [ 
			[1, {
				taunts: "SlimeR1Taunts",
				narration: {
					ItemVulva: "SlimeR1Vulva",
					ItemButt: "SlimeR1Butt",
					ItemMouth: "SlimeR1Mouth",
				}
			}],
			[5, {
				taunts: "SlimeR5Taunts",
				narration: {
					ItemVulva: "SlimeR5Vulva",
					ItemButt: "SlimeR5Butt",
					ItemMouth: "SlimeR5Mouth",
				},
				sp: -0.1,
				dp: 1,
				orgasmBonus: 0,
			}],
			[12, {
				taunts: "SlimeR12Taunts",
				narration: {
					ItemVulva: "SlimeR12Vulva",
					ItemButt: "SlimeR12Butt",
					ItemMouth: "SlimeR12Mouth",
				},
				sp: -0.15,
				dp: 1.5,
				orgasmBonus: 1,
			}],
			[16, {
				taunts: "SlimeR16Taunts",
				narration: {
					ItemVulva: "SlimeR16Vulva",
					ItemButt: "SlimeR16Butt",
					ItemMouth: "SlimeR16Mouth",
				},
				sp: -0.2,
				dp: 2,
				orgasmBonus: 2,
			}],
			[17, {
				taunts: "SlimeR17Taunts",
				narration: {
					ItemVulva: "SlimeR17Vulva",
					ItemButt: "SlimeR17Butt",
					ItemMouth: "SlimeR17Mouth",
				},
				sp: -0.2,
				dp: 5,
				orgasmBonus: 3,
			}],
			[20, {
				taunts: "SlimeR20Taunts",
				narration: {
					ItemVulva: "SlimeR20Vulva",
					ItemButt: "SlimeR20Butt",
					ItemMouth: "SlimeR20Mouth",
				},
				dp: 10,
				wp: -1,
				orgasmBonus: 4,
				sub: 1
			}],
		]
	},
	effect: {
		effect: {
			name: "Ravage"
		}
	},
	events: [
		{ trigger: "death", type: "ravagerRemove" },
		{ trigger: "tickAfter", type: "ravagerRefractory" },
		{
			trigger: "afterDamageEnemy",
			type: "bleedEffectTile",
			kind: "Slime",
			aoe: 1.5,
			power: 3,
			chance: 1.0,
			duration: 20
		},
		{
			trigger: "afterEnemyTick",
			type: "createEffectTile",
			kind: "LatexThin",
			time: 25,
			power: 2,
			chance: 0.5,
			aoe: 0.5
		},
	],
	noDisplace: true,
	focusPlayer: true,
}
let textKeyInfo = [
	"SlimeRavager",
	[
		"NameSlimeRavager",
		"AttackSlimeRavager",
		"KillSlimeRavager",
		"KinkyDungeonRemindJailChaseSlimeAdvCommandAssault",
		"KinkyDungeonRemindJailSlimeAdvHitPlayer",
		"KinkyDungeonRemindJailPlaySlimeAdv2",
		"KinkyDungeonRemindJailChaseSlimeAdvDefendHonor2",
		"KinkyDungeonRemindJailChaseSlimeAdvAttack0",
		"KinkyDungeonRemindJailChaseSlimeAdvAttack1",
		"KinkyDungeonRemindJailChaseSlimeAdvAttack2",
		"KinkyDungeonRemindJailChaseSlimeAdvAttack3",
		"KinkyDungeonRemindJailChaseSlimeAdvDefend1",
		"KinkyDungeonRemindJailChaseSlimeAdvDefend2",
		"KinkyDungeonRemindJailChaseSlimeAdvDefend3",
		"KinkyDungeonRemindJailSlimeAdvMissedMe",
		"KinkyDungeonRemindJailSlimeAdvMiss",
		"KinkyDungeonRemindJailChaseSlimeAdvCommandBlock",
		"KinkyDungeonRemindJailChaseSlimeAdvCommandDefend",
		"KinkyDungeonRemindJailChaseSlimeAdvAlert",
		"KinkyDungeonRemindJailSlimeAdvBlockedMe",
		"KinkyDungeonRemindJailChaseSlimeAdvDefendHonor1",
		"KinkyDungeonRemindJailSlimeAdvIntro",
	]
]
RFPushEnemiesWithStrongVariations(slimeRavager, 5, textKeyInfo, false, undefined, undefined, { TranslationDictionaryEnemy: true })
