function AddCallback(key, func) {
	if (! KDEventMapEnemy['ravagerCallbacks']) {
		throw new Error('Ravager Framework has not been loaded yet! Please ensure that the Framework has been added and is listed alphabetically before your custom Ravager mod. If this is happening without any additional ravager mods (aka only Ravager Framework is adding ravagers), please post as much info as you can to the framework\'s thread on Discord so it can be investigated')
	} else {
		// When creating a custom ravager mod, I'd suggest changing this log call to have your mod's name inside the [ ] to help make it more clear what is loading when
		console.log('[Ravager Framework] Adding callback function with key ', key)
		KDEventMapEnemy['ravagerCallbacks'][key] = func
	}
}
// Moved the All Range Callback so it'll actually work
AddCallback('wolfgirlRavagerAllRangeCallback', (entity, target) => {
	let collared = KinkyDungeonPlayerTags.get("Collars");
	let moduled = KinkyDungeonPlayerTags.get("Modules");
	let leashed = KinkyDungeonPlayerTags.get("Item_WolfLeash") || KinkyDungeonPlayerTags.get("Item_BasicLeash")
	if(collared && moduled && !leashed){
		KinkyDungeonAddRestraintIfWeaker(KinkyDungeonGetRestraintByName("WolfLeash"), 1, false, "Red", undefined, undefined, undefined, "Nevermere", true);
		KinkyDungeonSendTextMessage(5, "The Alpha clicks a leash onto your collar, pulling you close...", "#ff44ff", 3);
	} else if(collared && !moduled) {
		KinkyDungeonAddRestraintIfWeaker(KinkyDungeonGetRestraintByName("ShockModule"), 1, false, "Red", undefined, undefined, undefined, "Nevermere", true);
		KinkyDungeonSendTextMessage(5, "The Alpha activates your collar's training module...", "#ff44ff", 3);
	} else if(!collared) {
		KinkyDungeonAddRestraintIfWeaker(KinkyDungeonGetRestraintByName("WolfCollar"), 1, false, "Red", undefined, undefined, undefined, "Nevermere", true);
		KinkyDungeonSendTextMessage(5, "The Alpha fixes a collar around your neck...", "#ff44ff", 3);
	}
})
// Moved the Submit Chance Modifier so it'll actually work
AddCallback('wolfgirlSubmitChanceModifierCallback', (entity, target, baseSubmitChance) => {
	if(KinkyDungeonPlayerTags.get("Item_ShockModule")) {
		KinkyDungeonSendTextMessage(5, "Your shock module gently insists you submit... (+20% Submit Chance)", "#ff44ff", 3);
		return baseSubmitChance + 20
	}
	return baseSubmitChance
})
// Hopefully we can get her spell functional here without screwing up the ravaging
AddCallback('wolfgirlRavagerEffectCallback', (entity, target) => {
	// console.log('[Ravager Framework] [Wolfgirl Status Callback] ', entity, target)
	if (!entity.hasThrownDevice) {
		let res = KinkyDungeonCastSpell(target.x, target.y, KinkyDungeonSpellListEnemies.find((spell) => { if (spell.name == 'RestrainingDevice') return true}), entity)
		// console.log(res)
		entity.hasThrownDevice = true
		return true
	}
	return false
})

/**********************************************
 * Enemy definition: NEVERMERE ALPHA
	A wolfgirl clone, that...
	- Has a special attack that applies the ravage "effect"
		- Will equip a collar, then a leash, if none are equipped.
		- Has an aura that gradually increases a "Heat" level in the player, boosting submit chance.
*/
let wolfRavager = {
	// Key to signal we added this so we can make sure we don't remove an enemy with the same name added by someone else (such as someone else making a mod to modify the bandit ravager)
	// If you're making your own ravager, change this key or just remove it
	addedByMod: 'RavagerFramework',
	// id data
	name: "WolfgirlRavager", 
	faction: "Nevermere", 
	clusterWith: "nevermere", 
	playLine: "Wolfgirl", 
	bound: "Wolfgirl", 
	color: "#00EFAB",
	tags: KDMapInit([ 
		"opendoors", 
		"closedoors", 
		"nevermere",  
		"melee",
		"elite",
		"trainer",
		"imprisonable",
		"glueweakness", 
		"ticklesevereweakness", 
		"iceresist", 
		"electricresist", 
		"charmweakness", 
		"stunweakness",
		"jail",
		"jailer",
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
	minLevel: 0,
	weight: -2,
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
		fallbackNarration: ["The ravager roughly gropes you! (DamageTaken)"],
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
					ItemVulva: ["EnemyName lines her intimidating cock up with your pussy..."],
					ItemButt: ["EnemyName lines her intimidating cock up with your ass..."],
					ItemMouth: ["EnemyName presses her cockhead against your lips..."],
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
KinkyDungeonEnemies.push(wolfRavager)
KDEventMapEnemy['ravagerCallbacks']['definitionWolfgirlRavager'] = wolfRavager

//textkeys
// addTextKey("NameSlimeRavager", "Slimegirl")
addTextKey('NameWolfgirlRavager', 'Wolfgirl Alpha')
addTextKey('AttackWolfgirlRavager','The alpha charges and captures you in a powerful hug!')
addTextKey('AttackWolfgirlRavagerDash','The alpha yanks your body against her hard!')
addTextKey("KillWolfgirlRavager", "The alpha scrambles away, waiting for her next chance...")
// Still need , , 
