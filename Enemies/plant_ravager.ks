/**********************************************
 * Enemy definition: 
	A kinda weak slimegirl, that...
	- Has a special attack that applies the ravage "effect"
		- Has a callback that has a chance spread slime while 'busy'.
		- Can go through slime, rubber, and liquid metal!
*/

let y = {
	name: "SarcoKraken", 
	faction: "KinkyConstruct", 
	clusterWith: "construct", 
	color: "#3b7d4f", 
	tags: KDMapInit([
		"construct", 
		"nosignal", 
		"poisonresist", 
		"soulimmune", 
		"melee", 
		"boss", 
		"elite",
		"unflinching", 
		"fireresist", 
		"crushweakness", 
		"chainweakness", 
		"glueweakness", 
		"hunter"
	]),
	armor: 3.0, 
	spellResist: 1.5,
	evasion: -2.0,
	ignorechance: 0.75, 
	followRange: 1, 
	AI: "hunt", 
	Animations: ["squishy"],
	summon: [
		{
			enemy: "SarcoMinion", 
			range: 2.5, 
			count: 3, 
			strict: true
		}
	],
	spells: ["SarcoHex", "SummonSarcoTentacle"], 
	spellCooldownMult: 1, 
	spellCooldownMod: 0, 
	ignoreflag: ["kraken"],
	events: [
		{trigger: "spellCast", type: "sarcoKrakenSummonTentacle"}, // Drain HP when casting
		{trigger: "afterDamageEnemy", type: "bleedEffectTile", kind: "FabricGreen", aoe: 1.5, power: 1, chance: 1.0, duration: 20},
	],
	visionRadius: 10, 
	maxhp: 34, 
	minLevel: 0, 
	weight:-11, 
	movePoints: 4, 
	attackPoints: 3, 
	attack: "SpellMeleePull", 
	attackWidth: 1.5, 
	attackMinRange: 1.5, 
	attackRange: 6, 
	power: 4, 
	pullDist: 4, 
	pullTowardSelf: true, 
	dmgType: "charm",
	terrainTags: {"secondhalf":16, "lastthird":5, "boss": -80, "open": 20, "passage": -60, "increasingWeight":1}, 
	floors: KDMapInit(["tmb"]), 
	shrines: [],
	dropTable: [{name: "Gold", amountMin: 40, amountMax: 50, weight: 12}],
}

let x = {
	name: "SarcoMinion", 
	faction: "KinkyConstruct", 
	color: "#99ff99", 
	Animations: ["squishy"],
	tags: KDMapInit([
		"construct", 
		"nosignal", 
		"poisonresist", 
		"soulimmune", 
		"melee", 
		"fireweakness", 
		"minor", 
		"slashweakness", 
		"chainresist", 
		"sarcotentacle", 
		"mummyRestraints"
	]),
	ignorechance: 0.75,
	 followRange: 1, 
	 AI: "hunt",  
	 master: {
		type: "SarcoKraken", 
		range: 7
	}, 
	ignoreflag: ["kraken"], 
	dependent: true, 
	suicideOnAdd: true,
	visionRadius: 10, 
	maxhp: 5, 
	minLevel: 0, 
	weight:-1000, 
	movePoints: 1, 
	attackPoints: 2, 
	attack: "MeleeBindSuicide", 
	attackWidth: 1, 
	attackRange: 1, 
	power: 2, 
	fullBoundBonus: 2, 
	dmgType: "chain", 
	noAlert: true,
	events: [
		{trigger: "afterDamageEnemy", type: "bleedEffectTile", kind: "FabricGreen", aoe: 1.5, power: 1, chance: 1.0, duration: 20},
	],
	terrainTags: {}, 
	allFloors: true, 
	shrines: ["Rope"]
}



// KinkyDungeonEnemies.push({
// 	// id data
// 	name: "SlimeRavager", 
// 	faction: "Slime", 
// 	clusterWith: "slime", 
// 	playLine: "SlimeAdv", 
// 	bound: "SlimeAdv", 
// 	squeeze: true,
// 	color: "#FF00FF",
// 	tags: KDMapInit([ 
// 		"opendoors", 
// 		"closedoors", 
// 		"slime",  
// 		"melee",
// 		"elite",
// 		"meleeresist", 
// 		"electricweakness", 
// 		"acidresist", 
// 		"chainimmune",
// 		"iceweakness",
// 		"unflinching", // makes enemy unable to be pulled/pushed. maybe don't remove this
// 		"nosub", //probably don't want to remove this one
// 		"hunter"
// 	]),

// 	// AI
// 	ignorechance: 0, 
// 	followRange: 1, 
// 	AI: "hunt",
// 	Animations: ["squishy"],

// 	// core stats
// 	armor: 1.5, 
// 	maxhp: 10, 
// 	minLevel:0, //notably this affects the earliest floor they can spawn on
// 	weight: 2,
// 	visionRadius: 5, 
// 	blindSight: 2.5,
// 	movePoints: 3,
// 	evasion: 0.3,
// 	sneakThreshold: 1,
	 
// 	// main attack
// 	// P.S. - this enemy uses "Effect" melee, but you could also create a spell that has the PlayerEffect of Ravage if it fits more.
// 	dmgType: "grope",
// 	attack: "MeleeEffect", // "MeleeEffect" is the only necessary part
// 	attackLock: "White",
// 	power: 1, //i don't think this actually does anything with this enemy's setup - on theory, affects how strong their hits are
// 	attackPoints: 2, //set this to 0 for it to happen instantly on contact, no telegraph
// 	attackWidth: 1, 
// 	attackRange: 1, 
// 	fullBoundBonus: 0,
// 	disarm: 0.2,
// 	hitsfx: "Grab",

// 	// spawning/drops, i made this enemy drop a bunch of cash as reward
// 	terrainTags: {"increasingWeight":-1, "slime": 4, "slimeOptOut": -2, "slimePref": 2, "jungle": 20, "alchemist": 4}, 
// 	allFloors: true, 
// 	shrines: ["Latex"],
// 	dropTable: [{name: "Nothing", weight: 10}, {name: "StaffGlue", weight: 3, ignoreInInventory: true}],

// 	/*
// 		Ravage setup
// 	*/
// 	ravage: { // custom ravage settings
// 		targets: ["ItemVulva", "ItemMouth", "ItemButt"],
// 		refractory: 50, 
// 		needsEyes: false,
// 		bypassSpecial: ["Slime", "Rubber", "Liquid Metal"],
		
// 		onomatopoeia: ["CLAP...", "PLAP..."], //floats overhead like stat changes (can be unspecified for none)
// 		doneTaunts: ["That was good...", "Give me a minute and we'll go again, okay~?", "Such a good girl~!"],

// 		// this can be a function ( (enemy, target) => {whatever} ) if you don't want it to do generic grope damage. anything you specify is used instead
// 		// you only need to specify narration if no callback is defined - otherwise you bring your own narration
// 		fallbackCallback: false, 
// 		fallbackNarration: ["The ravager roughly gropes you! (DamageTaken)"],

// 		// another optional function callback - will be called when an enemy is done
// 		// structured like (enemy, target, passedOut) => {} (with passedOut being whether the player passed out as a result or not)
// 		completionCallback: false,

// 		allRangeCallback: (entity, target) => {
// 			let roll = Math.random() > 0.85
// 			if(roll) {
// 				let restraintAdd = KinkyDungeonGetRestraint({tags: ["slimeRestraintsRandom"]}, MiniGameKinkyDungeonLevel + 1, KinkyDungeonMapIndex[MiniGameKinkyDungeonCheckpoint])
// 				console.log('chose', restraintAdd)
// 				if(!restraintAdd) {
// 					KDAdvanceSlime(false, "");
// 					KinkyDungeonSendTextMessage(5, TextGet("KinkyDungeonSlimeHarden"), "#ff44ff", 3);
// 				} else {
// 					KinkyDungeonAddRestraintIfWeaker(restraintAdd)
// 					KinkyDungeonSendTextMessage(5, TextGet("KinkyDungeonSlimeSpread"), "#ff44ff", 3);
// 				}
// 			}
// 		},

// 		// progression data - first group that's got a number your count is less than is the one used
// 		// you can use any numbers, any ranges, but keep in mind that there's a turn between hits unless you're doing something like AttackPoints 0
// 		ranges: [ 
// 			[1, { // starting - no stat damage yet
// 				taunts: ["Relax, girlie...", "Hehe, ready~?"],
// 				narration: {
// 					ItemVulva: ["EnemyName lines her intimidating cock up with your pussy..."],
// 					ItemButt: ["EnemyName lines her intimidating cock up with your ass..."],
// 					ItemMouth: ["EnemyName presses her cockhead against your lips..."],
// 				},
// 				callback: (enemy, target)=>{
// 					console.log('callback test from', enemy, "on", target)
// 				}
// 			}],

// 			[5, { // regular
// 				taunts: ["Mmh...", "That's it..."],
// 				narration: {
// 					ItemVulva: ["Wide hips meet yours as her cock stretches out your pussy..."],
// 					ItemButt: ["Wide hips meet your ass as her dick stretches you out..."],
// 					ItemMouth: ["Her strong hand guides your head up and down her thick cock..."],
// 				},
// 				sp: -0.1,
// 				dp: 1,
// 				orgasmBonus: 0,
// 			}],

// 			[12, { // rougher
// 				taunts: ["Good girl...", "Take it...", "I'm gonna miss you when we find you a nice master..."],
// 				narration: {
// 					ItemVulva: ["Strong hands grip your waist as your pussy is pounded..."],
// 					ItemButt: ["Your hips are gripped tight as your ass is railed..."],
// 					ItemMouth: ["Your face meets her lap, throating her cock over and over..."],
// 				},
// 				sp: -0.15,
// 				dp: 1.5,
// 				orgasmBonus: 1,
// 			}],

// 			[16, { // peak intensity
// 				taunts: ["Ooh, good girl~!", "Haah!"],
// 				narration: {
// 					ItemVulva: ["You cry out with each hilting thrust, smothered by soft curves!"],
// 					ItemButt: ["Her ferocious thrusts drive pathetic whimpers out of you!"],
// 					ItemMouth: ["You feel weak, her dick filling your throat again and again!"],
// 				},
// 				sp: -0.2,
// 				dp: 2,
// 				orgasmBonus: 2,
// 			}],

// 			[17, { // preparing to finish
// 				taunts: ["Here it comes~~!", "Let's fill you up~~!"],
// 				narration: {
// 					ItemVulva: ["With a thunderous final thrust, her dick throbs, she's about to--!!"],
// 					ItemButt: ["Her hips clap against yours with finality, she's about to--!!"],
// 					ItemMouth: ["Your vision fades as her cock pulses in your throat, she's about to--!!"],
// 				},
// 				sp: -0.2,
// 				dp: 5,
// 				orgasmBonus: 3,
// 			}],

// 			[20, { // finishing
// 				taunts: ["Aaaah~...", "Ooohh~...", "That's a good pet~..."],
// 				narration: {
// 					ItemVulva: ["You moan loudly as you feel your womb flooded with her hot cum..."],
// 					ItemButt: ["Your belly grows warm as she fills you up, pounded powerfully into her lap..."],
// 					ItemMouth: ["GLK... GLK... You helplessly swallow wave after wave of her seed..."],
// 				},
// 				dp: 10,
// 				wp: -1,
// 				orgasmBonus: 4,
// 				sub: 1
// 			}],
// 		]
// 	},

// 	// on-hit effect definition - required for this to work
// 	effect: {
// 		effect: {
// 			name: "Ravage"
// 		}
// 	},

// 	//these events are required for ravager stuff to work properly
// 	events: [
// 		{trigger: "death", type: "ravagerRemove"},
// 		{trigger: "tickAfter", type: "ravagerRefractory"},
// 		{trigger: "afterDamageEnemy", type: "bleedEffectTile", kind: "Slime", aoe: 1.5, power: 3, chance: 1.0, duration: 20},
// 		{trigger: "afterEnemyTick", type: "createEffectTile", kind: "LatexThin", time: 25, power: 2, chance: 0.5, aoe: 0.5},
// 	],

// 	//useful flags
// 	noDisplace: true, // theoretically stops enemies from shoving this one out of the way. didn't seem to work by its lonesome for me
// 	focusPlayer: true, // obvious
// })

//textkeys
// addTextKey("NameSlimeRavager", "Slimegirl")
// addTextKey('AttackSlimeRavagerDash','The ravager charges and captures you in a powerful hug!')
// addTextKey('AttackSlimeRavagerBlind','The ravager pins you against her soft body effortlessly!')
// addTextKey("KillSlimeRavager", "The ravager scrambles away, waiting for her next chance...")