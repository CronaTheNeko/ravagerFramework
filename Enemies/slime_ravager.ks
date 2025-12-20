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
KDModelDresses['SlimegirlRavager'] = [{"Item":"FashionLatexMittens","Group":"Mittens","Filters":{"LatexLeft":{"gamma":1,"saturation":0,"contrast":1,"brightness":1,"red":1.6666666666666667,"green":0.3333333333333333,"blue":0.6274509803921569,"alpha":1},"Mitten":{"gamma":1,"saturation":0,"contrast":0.81,"brightness":1,"red":4.176470588235294,"green":0.9215686274509803,"blue":1.6470588235294117,"alpha":1}},"Properties":{"LatexLeft":{},"Zipper":{"Protected":"0","ExtraHidePoses":["Xray"],"XOffset":57.62,"YOffset":-153.68,"ExtraRequirePoses":["Xray"]},"Mitten":{}}}]
KDModelHair['SlimegirlRavager'] = [{"Item":"Curly","Group":"Hair","Filters":{"Curly":{"gamma":1,"saturation":0,"contrast":1,"brightness":1,"red":1.6666666666666667,"green":0.3333333333333333,"blue":0.6274509803921569,"alpha":1}},"Properties":{"Curly":{}}},{"Item":"Ponytail","Group":"Hair","Filters":{"Ponytail":{"gamma":1,"saturation":0,"contrast":1,"brightness":1,"red":1.6666666666666667,"green":0.3333333333333333,"blue":0.6274509803921569,"alpha":1}},"Properties":{"Ponytail":{"Protected":"","LayerBonus":"0","XOffset":1501.45,"YOffset":479.31,"XPivot":1390,"YPivot":245,"XScale":2,"YScale":2}}},{"Item":"RavLargeHeartHairpin","Group":"Hair","Filters":{"LargeHeartHairpin":{"gamma":1,"saturation":0,"contrast":1,"brightness":1,"red":0.6470588235294118,"green":0,"blue":2,"alpha":1}},"Properties":{"LargeHeartHairpin":{"XScale":1.8,"XOffset":-1000,"YScale":1.8,"YOffset":-330}}},{"Item":"FluffyPonytail","Group":"Hair","Filters":{"Ponytail2":{"gamma":1,"saturation":0,"contrast":1,"brightness":1,"red":1.392156862745098,"green":0.3137254901960784,"blue":0.49019607843137253,"alpha":1}},"Properties":{"Ponytail2":{"Rotation":-90,"YOffset":1750,"XOffset":950}}},{"Item":"FluffyPonytailRav","Group":"Hair","Filters":{"Ponytail2":{"gamma":1,"saturation":0,"contrast":1,"brightness":1,"red":1.7450980392156863,"green":0.35294117647058826,"blue":0.6274509803921569,"alpha":1}},"Properties":{"Ponytail2":{"Rotation":-90,"YOffset":1900,"XOffset":1090}}},{"Item":"FluffyPonytailRav2","Group":"Hair","Filters":{"Ponytail2":{"gamma":1,"saturation":0,"contrast":1,"brightness":1,"red":1.7450980392156863,"green":0.35294117647058826,"blue":0.6274509803921569,"alpha":1}},"Properties":{"Ponytail2":{"Rotation":-45,"YOffset":1400,"XOffset":60}}}]
KDModelBody['SlimegirlRavager'] = [{"Item":"Body","Group":"Body","Filters":{"Torso":{"gamma":1,"saturation":0,"contrast":1.3599999999999999,"brightness":1,"red":1,"green":0.23529411764705882,"blue":0.4117647058823529,"alpha":1},"Head":{"gamma":1,"saturation":0,"contrast":1.3599999999999999,"brightness":1,"red":1,"green":0.23529411764705882,"blue":0.4117647058823529,"alpha":1},"Nipples":{"gamma":1,"saturation":0,"contrast":0.03,"brightness":1,"red":1.8627450980392157,"green":0.39215686274509803,"blue":0.8235294117647058,"alpha":1}},"Properties":{"Head":{},"Torso":{}}}]
KDModelFace['SlimegirlRavager'] = [{"Item":"KoiBlush","Group":"FaceKoi"},{"Item":"KjusBrows","Group":"FaceKjus"},{"Item":"KjusMouth","Group":"FaceKjus","Filters":{"Mouth":{"gamma":1,"saturation":1,"contrast":1,"brightness":1,"red":1,"green":1,"blue":1,"alpha":1}}},{"Item":"KjusEyes3","Group":"EyesK3","Filters":{"Eyes":{"gamma":1,"saturation":0,"contrast":0.96,"brightness":1,"red":0.4117647058823529,"green":1.0980392156862746,"blue":1.7843137254901962,"alpha":1},"Eyes2":{"gamma":1,"saturation":0,"contrast":0.96,"brightness":1,"red":0.4117647058823529,"green":1.0980392156862746,"blue":1.7843137254901962,"alpha":1}}},{"Item":"Fear","Group":"Expressions"}]
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
		
		onomatopoeia: [ "CLAP...", "PLAP..." ],
		doneTaunts: [ "That was good...", "Give me a minute and we'll go again, okay~?", "Such a good girl~!" ],
		// A callback for the slime girl to add slime to the player
		allRangeCallback: 'slimegirlRavagerAllRangeCallback',
		ranges: [ 
			[1, {
				taunts: [ "Relax, girlie...", "Hehe, ready~?" ],
				narration: {
					ItemVulva: [ "EnemyCName lines her intimidating cock up with your pussy..." ],
					ItemButt: [ "EnemyCName lines her intimidating cock up with your ass..." ],
					ItemMouth: [ "EnemyCName presses her cockhead against your lips..." ],
				}
			}],
			[5, {
				taunts: ["Mmh...", "That's it..."],
				narration: {
					ItemVulva: [ "Wide hips meet yours as her cock stretches out your pussy..." ],
					ItemButt: [ "Wide hips meet your ass as her dick stretches you out..." ],
					ItemMouth: [ "Her strong hand guides your head up and down her thick cock..." ],
				},
				sp: -0.1,
				dp: 1,
				orgasmBonus: 0,
			}],
			[12, {
				taunts: [ "Good girl...", "Take it...", "I'm gonna miss you when we find you a nice master..." ],
				narration: {
					ItemVulva: [ "Strong hands grip your waist as your pussy is pounded..." ],
					ItemButt: [ "Your hips are gripped tight as your ass is railed..." ],
					ItemMouth: [ "Your face meets her lap, throating her cock over and over..." ],
				},
				sp: -0.15,
				dp: 1.5,
				orgasmBonus: 1,
			}],
			[16, {
				taunts: [ "Ooh, good girl~!", "Haah!" ],
				narration: {
					ItemVulva: [ "You cry out with each hilting thrust, smothered by soft curves!" ],
					ItemButt: [ "Her ferocious thrusts drive pathetic whimpers out of you!" ],
					ItemMouth: [ "You feel weak, her dick filling your throat again and again!" ],
				},
				sp: -0.2,
				dp: 2,
				orgasmBonus: 2,
			}],
			[17, {
				taunts: [ "Here it comes~~!", "Let's fill you up~~!" ],
				narration: {
					ItemVulva: [ "With a thunderous final thrust, her dick throbs, she's about to--!!" ],
					ItemButt: [ "Her hips clap against yours with finality, she's about to--!!" ],
					ItemMouth: [ "Your vision fades as her cock pulses in your throat, she's about to--!!" ],
				},
				sp: -0.2,
				dp: 5,
				orgasmBonus: 3,
			}],
			[20, {
				taunts: [ "Aaaah~...", "Ooohh~...", "That's a good pet~..." ],
				narration: {
					ItemVulva: [ "You moan loudly as you feel your womb flooded with her hot cum..." ],
					ItemButt: [ "Your belly grows warm as she fills you up, pounded powerfully into her lap..." ],
					ItemMouth: [ "GLK... GLK... You helplessly swallow wave after wave of her seed..." ],
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
let keys = {
	NameEnemyName: "Slimegirl",
	AttackEnemyName: "~~{RavagerFrameworkNoMessageDisplay}~~",
	KillEnemyName: "The slime girl scrambles away, waiting for her next chance...",
	KinkyDungeonRemindJailChaseSlimeAdvCommandAssault: "You shouldn\'t be out here on your own~",
	KinkyDungeonRemindJailSlimeAdvHitPlayer: "We\'ll take good care of you~",
	KinkyDungeonRemindJailPlaySlimeAdv2: "What\'s a pretty thing like you doing here?~",
	KinkyDungeonRemindJailChaseSlimeAdvDefendHonor2: "You won\'t get away this time~",
	KinkyDungeonRemindJailChaseSlimeAdvAttack0: "Why don\'t you make this easy?~",
	KinkyDungeonRemindJailChaseSlimeAdvAttack1: "Ooh, a feisty one!~",
	KinkyDungeonRemindJailChaseSlimeAdvAttack2: "You\'re gonna get yourself into trouble~",
	KinkyDungeonRemindJailChaseSlimeAdvAttack3: "Mmm let\'s train you to be good~",
	KinkyDungeonRemindJailChaseSlimeAdvDefend1: "Aww, give in and I\'ll take good care of you~", // Assuming this one will be needed, but hasn't been reported so far
	KinkyDungeonRemindJailChaseSlimeAdvDefend2: "That\'s enough trouble, miss",
	KinkyDungeonRemindJailChaseSlimeAdvDefend3: "You\'re in for it now, honey~",
	KinkyDungeonRemindJailSlimeAdvMissedMe: "Nuh uh uh, sweetie~",
	KinkyDungeonRemindJailSlimeAdvMiss: "Playing hard to get?~",
	KinkyDungeonRemindJailChaseSlimeAdvCommandBlock: "Get back here, sweetie~",
	KinkyDungeonRemindJailChaseSlimeAdvCommandDefend: "", // Based on vanilla text entries, 'CommandDefend' seems to be shown when showing up to assist another npc. Might just leave this empty (as Fuuka does)
	KinkyDungeonRemindJailChaseSlimeAdvAlert: "", // Left empty because I'm not sure what to write here
	KinkyDungeonRemindJailSlimeAdvBlockedMe: "I\'m too slippery for that~", // Only saw this when trying to debug bind her
}
RFPushEnemiesWithStrongVariations(slimeRavager, 5, keys, false)
