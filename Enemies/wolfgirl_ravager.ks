// Add a leash, shock module, or leash to the player during use -- Might make this chance based
function wolfgirlRavagerAllRange(entity, target) {
	if (KDIsInParty(entity))
		return
	let collared = KinkyDungeonPlayerTags.get("Collars");
	let moduled = KinkyDungeonPlayerTags.get("Modules");
	let leashed = KinkyDungeonPlayerTags.get("Item_WolfLeash") || KinkyDungeonPlayerTags.get("Item_BasicLeash")
	if(collared && moduled && !leashed){
		KinkyDungeonAddRestraintIfWeaker(KinkyDungeonGetRestraintByName("WolfLeash"), 1, false, "Red", undefined, undefined, undefined, "Nevermere", true);
		KinkyDungeonSendTextMessage(5, RavagerData.functions.NameFormat("EnemyCName clicks a leash onto your collar, pulling you close...", entity), "#ff44ff", 3);
	} else if(collared && !moduled) {
		KinkyDungeonAddRestraintIfWeaker(KinkyDungeonGetRestraintByName("ShockModule"), 1, false, "Red", undefined, undefined, undefined, "Nevermere", true);
		KinkyDungeonSendTextMessage(5, RavagerData.functions.NameFormat("EnemyCName activates your collar's training module...", entity), "#ff44ff", 3);
	} else if(!collared) {
		KinkyDungeonAddRestraintIfWeaker(KinkyDungeonGetRestraintByName("WolfCollar"), 1, false, "Red", undefined, undefined, undefined, "Nevermere", true);
		KinkyDungeonSendTextMessage(5, RavagerData.functions.NameFormat("EnemyCName fixes a collar around your neck...", entity), "#ff44ff", 3);
	}
}
if (!RavagerAddCallback('wolfgirlRavagerAllRangeCallback', wolfgirlRavagerAllRange)) {
	RFError('[Ravager Framework][Wolfgirl Ravager] Failed to add wolfgirlRavagerAllRangeCallback!')
}
// Increase submission chance if wearing shock module
function wolfgirlSubmitChanceModifier(entity, target, baseSubmitChance) {
	if(KinkyDungeonPlayerTags.get("Item_ShockModule")) {
		KinkyDungeonSendTextMessage(5, "Your shock module gently insists you submit... (+20% Submit Chance)", "#ff44ff", 3);
		return baseSubmitChance + 20
	}
	return baseSubmitChance
}
if (!RavagerAddCallback('wolfgirlSubmitChanceModifierCallback', wolfgirlSubmitChanceModifier)) {
	RFError('[Ravager Framework][Wolfgirl Ravager] Failed to add wolfgirlSubmitChanceModifierCallback!')
}
// Workaround for not being able to get the spell working well with ravaging
function wolfgirlRavagerEffect(entity, target) {
	if (!entity.hasThrownDevice) {
		let res = KinkyDungeonCastSpell(target.x, target.y, KinkyDungeonSpellListEnemies.find((spell) => { if (spell.name == 'RestrainingDevice') return true}), entity)
		entity.hasThrownDevice = true
		return true
	}
	return false
}
if (!RavagerAddCallback('wolfgirlRavagerEffectCallback', wolfgirlRavagerEffect)) {
	RFError('[Ravager Framework][Wolfgirl Ravager] Failed to add wolfgirlRavagerEffectCallback!')
}

// Outfit declaration
KDModelDresses['WolfgirlRavager'] = [{"Item":"CyberPanties","Group":"Chastity","Filters":{"Lining":{"gamma":1.0166666666666666,"saturation":0,"contrast":0.88,"brightness":1,"red":0.11764705882352941,"green":0.11764705882352941,"blue":0.11764705882352941,"alpha":0.9833333333333333}}},{"Item":"VBikini","Group":"Swimsuit","Filters":{"VBikini":{"gamma":1,"saturation":0,"contrast":1,"brightness":1,"red":0.29411764705882354,"green":0.29411764705882354,"blue":0.27450980392156865,"alpha":1}},"Properties":{"VBikini":{"YScale":0.6,"YOffset":700,"XScale":1.11,"XOffset":-120,"LayerBonus":-100}}},{"Item":"ElfPanties","Group":"Elf","Properties":{"Panties":{"YOffset":25,"LayerBonus":-8000}}},{"Item":"LatexWhip","Group":"Weapon","Filters":{"LatexWhip":{"gamma":1,"saturation":0,"contrast":1.27,"brightness":1,"red":0,"green":0.5098039215686274,"blue":0.058823529411764705,"alpha":1}}},{"Item":"WolfgirlAlpha","Group":"WolfCatsuit",}]

KDModelCosplay['WolfgirlRavager'] = [{"Item":"FoxEars","Group":"Ears","Filters":{"Ears":{"gamma":1,"saturation":0,"contrast":2.24,"brightness":1,"red":0.29411764705882354,"green":0.29411764705882354,"blue":0.5686274509803921,"alpha":1},"Fox":{"gamma":1,"saturation":0,"contrast":2.24,"brightness":1,"red":0.29411764705882354,"green":0.29411764705882354,"blue":0.5686274509803921,"alpha":1},"InnerEars":{"gamma":1,"saturation":0,"contrast":2.24,"brightness":1,"red":0.058823529411764705,"green":0.058823529411764705,"blue":0.13725490196078433,"alpha":1}},"Properties":{"Ears":{"Rotation":5,"XOffset":40,"YOffset":-100},"InnerEars":{"Rotation":5,"XOffset":40,"YOffset":-100}}},{"Item":"WolfTail","Group":"Tails","Filters":{"Tail":{"gamma":1,"saturation":0,"contrast":2.24,"brightness":1,"red":0.19607843137254902,"green":0.19607843137254902,"blue":0.43137254901960786,"alpha":1}}}]

KDModelHair['WolfgirlRavager'] = [{"Item":"MessyBack","Group":"Hair","Filters":{"Messy":{"gamma":1,"saturation":0,"contrast":2.24,"brightness":1,"red":0.29411764705882354,"green":0.29411764705882354,"blue":0.5686274509803921,"alpha":1}}},{"Item":"Straight","Group":"Hair","Filters":{"Straight":{"gamma":1,"saturation":0,"contrast":2.24,"brightness":1,"red":0.29411764705882354,"green":0.29411764705882354,"blue":0.5686274509803921,"alpha":1}}},{"Item":"RavLargeHeartHairpin","Group":"Hair","Filters":{"LargeHeartHairpin":{"gamma":1,"saturation":0,"contrast":1,"brightness":1,"red":0.6470588235294118,"green":0,"blue":2,"alpha":1}},"Properties":{"LargeHeartHairpin":{"XScale":1.8,"XOffset":-950,"YScale":1.8,"YOffset":-330}}}]

KDModelBody['WolfgirlRavager'] = [{"Item":"Body","Group":"Body","Filters":{"Head":{"gamma":1,"saturation":0,"contrast":1.76,"brightness":1,"red":0.8627450980392157,"green":0.6470588235294118,"blue":0.5686274509803921,"alpha":1},"Torso":{"gamma":1,"saturation":0,"contrast":1.76,"brightness":1,"red":0.8627450980392157,"green":0.6470588235294118,"blue":0.5686274509803921,"alpha":1},"Nipples":{"gamma":1,"saturation":0,"contrast":1,"brightness":1,"red":0.23529411764705882,"green":0.23529411764705882,"blue":0.21568627450980393,"alpha":1}}}]

KDModelFace['WolfgirlRavager'] = [{"Item":"Fear","Group":"Expressions",},{"Item":"KjusBrows","Group":"FaceKjus",},{"Item":"KjusBlush","Group":"FaceKjus",},{"Item":"KjusMouth","Group":"FaceKjus",},{"Item":"KjusEyes","Group":"FaceKjus","Filters":{"Eyes2":{"gamma":0.8500000000000001,"saturation":0.43333333333333335,"contrast":1,"brightness":1,"red":2.6862745098039214,"green":2.843137254901961,"blue":4.607843137254902,"alpha":1},"Eyes":{"gamma":0.8500000000000001,"saturation":0.43333333333333335,"contrast":1,"brightness":1,"red":2.6862745098039214,"green":2.843137254901961,"blue":4.607843137254902,"alpha":1}}}]


KDModelStyles['WolfgirlRavager'] = {
	Cosplay: [ 'WolfgirlRavager' ],
	Hairstyle: [ 'WolfgirlRavager' ],
	Bodystyle: [ 'WolfgirlRavager' ],
	Facestyle: [ 'WolfgirlRavager' ],
}

/**********************************************
 * Enemy definition: NEVERMERE ALPHA
	A wolfgirl clone, that...
	- Has a special attack that applies the ravage "effect"
		- Will equip a collar, then a leash, if none are equipped.
		- Has an aura that gradually increases a "Heat" level in the player, boosting submit chance.
*/
let wolfRavager = {
	style: 'WolfgirlRavager',
	outfit: 'WolfgirlRavager',
	// Key to signal we added this so we can make sure we don't remove an enemy with the same name added by someone else (such as someone else making a mod to modify the bandit ravager)
	// If you're making your own ravager, change this key or just remove it
	addedByMod: 'RavagerFramework',
	RFDisableRefvar: "ravagerDisableWolfgirl",
	// id data
	name: "WolfgirlRavager", 
	nameList: "nevermere",
	faction: "Nevermere", 
	clusterWith: "nevermere", 
	playLine: "Wolfgirl", 
	bound: "WolfgirlRavager", 
	color: "#00EFAB",
	tags: KDMapInit([ 
		"opendoors", 
		"closedoors", 
		"nevermere",  
		"melee",
		// "elite",
		"trainer",
		// "imprisonable",
		"glueweakness", 
		"ticklesevereweakness", 
		"iceresist", 
		"electricresist", 
		"charmweakness", 
		"stunweakness",
		// "jail", // Needed to remove in order for ravager to stop pulling the player mid-ravage
		// "jailer", // Needed to remove in order for ravager to stop pulling the player mid-ravage
		"unflinching", // makes enemy unable to be pulled/pushed. maybe don't remove this
		"nosub", //probably don't want to remove this one
		"hunter"
	]),

	// AI
	ignorechance: 0, 
	followRange: 1, 
	AI: "hunt",
	summon: [{enemy: "WolfgirlPet", range: 2, count: 2, chance: 0.7, strict: true},],

	// core stats
	armor: 1.5, 
	maxhp: 20, 
	minLevel: 2,
	weight: 6,
	visionRadius: 10, 
	movePoints: 3,
	disarm: 0.2,

	spells: ["RestrainingDevice"], 
	spellCooldownMult: 1, 
	spellCooldownMod: 1,
	minSpellRange: 2,

	RemoteControl: {
		punishRemote: 4,
		punishRemoteChance: 0.25,
	},
	 
	// main attack
	// HOW CAN I SEPARATE THIS FROM THE RAVAGING ABILITY
	// P.S. - this enemy uses "Effect" melee, but you could also create a spell that has the PlayerEffect of Ravage if it fits more.
	// dmgType: "grope",
	// attack: "MeleeEffectSpell", // "MeleeEffect" is the only necessary part
	// attackLock: "White",
	// power: 4, //i don't think this actually does anything with this enemy's setup - on theory, affects how strong their hits are
	// attackPoints: 2, //set this to 0 for it to happen instantly on contact, no telegraph
	// attackWidth: 1, 
	// attackRange: 2,
	// tilesMinRange: 1,
	// fullBoundBonus: 0,
	// stamina: 6,
	// hitsfx: "Grab",

	dmgType: "grope",
	attack: "MeleeEffect", // "MeleeEffect" is the only necessary part
	attackLock: "White",
	power: 4, //i don't think this actually does anything with this enemy's setup - on theory, affects how strong their hits are
	attackPoints: 2, //set this to 0 for it to happen instantly on contact, no telegraph
	attackWidth: 1, 
	attackRange: 1,
	tilesMinRange: 1,
	fullBoundBonus: 0,
	stamina: 6,
	hitsfx: "Grab",

	terrainTags: {"secondhalf":3, "lastthird":5, "metalAnger": 7, "metalRage": 2, "metalPleased": 9, "metalFriendly": 6, "nevermere": 7},
	allFloors: true, 
	shrines: ["Metal"],
	dropTable: [{name: "Gold", amountMin: 15, amountMax: 20, weight: 10}, {name: "EscortDrone", weight: 5.0, ignoreInInventory: true}],

	/*
		Ravage setup
	*/
	ravage: { // custom ravage settings
		targets: ["ItemVulva", "ItemMouth", "ItemButt"],
		refractory: 50, 
		needsEyes: false,
		
		onomatopoeia: ["CLAP...", "PLAP..."], //floats overhead like stat changes (can be unspecified for none)
		doneTaunts: ["That was good...", "Give me a minute and we'll go again, okay~?", "Such a good girl~!"],

		effectCallback: 'wolfgirlRavagerEffectCallback',

		// this can be a function ( (enemy, target) => {whatever} ) if you don't want it to do generic grope damage. anything you specify is used instead
		// you only need to specify narration if no callback is defined - otherwise you bring your own narration
		fallbackCallback: false, 
		// fallbackNarration: ["The ravager roughly gropes you! (DamageTaken)"], // Going to rework, but leaving at default for now
		restrainChance: 0.05, // Chance, decimal between 0 and 1

		// another optional function callback - will be called when an enemy is done
		// structured like (enemy, target, passedOut) => {} (with passedOut being whether the player passed out as a result or not)
		completionCallback: false,

		allRangeCallback: 'wolfgirlRavagerAllRangeCallback',

		submitChanceModifierCallback: 'wolfgirlSubmitChanceModifierCallback',

		// progression data - first group that's got a number your count is less than is the one used
		// you can use any numbers, any ranges, but keep in mind that there's a turn between hits unless you're doing something like AttackPoints 0
		ranges: [ 
			[1, { // starting - no stat damage yet
				taunts: ["Relax, girlie...", "Hehe, ready~?"],
				narration: {
					ItemVulva: ["EnemyCName lines her intimidating cock up with your pussy..."],
					ItemButt: ["EnemyCName lines her intimidating cock up with your ass..."],
					ItemMouth: ["EnemyCName presses her cockhead against your lips..."],
				}
			}],

			[5, { // regular
				taunts: ["Mmh...", "That's it..."],
				narration: {
					ItemVulva: ["Wide hips meet yours as her cock stretches out your pussy..."],
					ItemButt: ["Wide hips meet your ass as her dick stretches you out..."],
					ItemMouth: ["Her strong hand guides your head up and down her thick cock..."],
				},
				sp: -0.3,
				dp: 1,
				orgasmBonus: 0,
			}],

			[12, { // rougher
				taunts: ["Good girl...", "Take it...", "I'm gonna miss you when we find you a nice master..."],
				narration: {
					ItemVulva: ["Strong hands grip your waist as your pussy is pounded..."],
					ItemButt: ["Your hips are gripped tight as your ass is railed..."],
					ItemMouth: ["Your face meets her lap, throating her cock over and over..."],
				},
				sp: -0.4,
				dp: 1.5,
				orgasmBonus: 1,
			}],

			[16, { // peak intensity
				taunts: ["Ooh, good girl~!", "Haah!"],
				narration: {
					ItemVulva: ["You cry out with each hilting thrust, smothered by soft curves!"],
					ItemButt: ["Her ferocious thrusts drive pathetic whimpers out of you!"],
					ItemMouth: ["You feel weak, her dick filling your throat again and again!"],
				},
				sp: -0.5,
				dp: 2,
				orgasmBonus: 2,
			}],

			[17, { // preparing to finish
				taunts: ["Here it comes~~!", "Let's fill you up~~!"],
				narration: {
					ItemVulva: ["With a thunderous final thrust, her dick throbs, she's about to--!!"],
					ItemButt: ["Her hips clap against yours with finality, she's about to--!!"],
					ItemMouth: ["Your vision fades as her cock pulses in your throat, she's about to--!!"],
				},
				sp: -0.5,
				dp: 5,
				orgasmBonus: 3,
			}],

			[20, { // finishing
				taunts: ["Aaaah~...", "Ooohh~...", "That's a good pet~..."],
				narration: {
					ItemVulva: ["You moan loudly as you feel your womb flooded with her hot cum..."],
					ItemButt: ["Your belly grows warm as she fills you up, pounded powerfully into her lap..."],
					ItemMouth: ["GLK... GLK... You helplessly swallow wave after wave of her seed..."],
				},
				dp: 10,
				wp: -1,
				orgasmBonus: 4,
				sub: 1
			}],
		]
	},

	// on-hit effect definition - required for this to work
	effect: {
		effect: {
			name: "Ravage"
		}
	},

	//these events are required for ravager stuff to work properly
	events: [
		{trigger: "death", type: "ravagerRemove"},
		{trigger: "tickAfter", type: "ravagerRefractory"},
	],

	//useful flags
	noDisplace: true, // theoretically stops enemies from shoving this one out of the way. didn't seem to work by its lonesome for me
	focusPlayer: true, // obvious
}
//textkeys
let keys = {
	NameEnemyName: "Wolfgirl Alpha",
	AttackEnemyName: "~{RavagerFrameworkNoMessageDisplay}~~",
	AttackEnemyNameDash: "The alpha yanks your body against her hard!",
	KillEnemyName: "The alpha scrambles away, waiting for her next chance...",
}
RFPushEnemiesWithStrongVariations(wolfRavager, 4, keys)
