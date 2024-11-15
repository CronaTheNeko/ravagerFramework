/**********************************************
 * Enemy definition: BANDIT RAVAGER
	Bandit, that...
	- Has a DashStun special to close gaps. Stun makes them really dangerous, since they can quickly strip and immobilize a target.
	- Has a special attack that applies the ravage "effect"
*/

/**********************************************
 * Callback definition helper
 * This function is a simple helper the I would recommend using if you're going to add callbacks for your ravager.
 * Takes two parameters:
 * 	- The key which will be used to reference your callback. This is the value to use when setting a callback value inside your ravager's definition.
 * 	- The function to use as a callback. 
*/
// function AddCallback(key, func) {
// 	if (! KDEventMapEnemy['ravagerCallbacks']) {
// 		throw new Error('Ravager Framework has not been loaded yet! Please ensure that the Framework has been added and is listed alphabetically before your custom Ravager mod.')
// 	} else {
// 		console.log('[Ravager Framework] Adding callback function with key ', key)
// 		KDEventMapEnemy['ravagerCallbacks'][key] = func
// 	}
// }

let banditRavager = {
	// Key to signal we added this so we can make sure we don't remove an enemy with the same name added by someone else (such as someone else making a mod to modify the bandit ravager)
	// If you're making your own ravager, change this key or just remove it
	addedByMod: 'RavagerFramework',
	// id data
	name: "BanditRavagerWFloor", 
	faction: "Bandit", 
	clusterWith: "bandit", 
	playLine: "Bandit", 
	bound: "BanditGrappler", 
	color: "#ddcaaa",
	tags: KDMapInit([ 
		//DO NOT add leashing or else they'll pull the player to jail and break everything
		//otherwise, unless marked, the tags are up to your intention for the enemy
		"opendoors", 
		"closedoors", 
		"bandit", 
		"imprisonable", 
		"melee",
		"miniboss",
		"cacheguard", 
		"unflinching", // makes enemy unable to be pulled/pushed. maybe don't remove this
		"chainRestraints", 
		"nosub", //probably don't want to remove this one
		"handcuffer",
		"clothRestraints", 
		"chainweakness", 
		"glueweakness", 
		"jail", //ravagers in jails makes for a good time
		"jailer", 
		"hunter"
	]),

	// AI
	ignorechance: 0, 
	followRange: 1, 
	AI: "hunt",

	// core stats
	armor: 1.5, 
	maxhp: 12, 
	minLevel:0, //notably this affects the earliest floor they can spawn on
	weight: 8,
	visionRadius: 7, 
	movePoints: 3,
	 
	// main attack
	// P.S. - this enemy uses "Effect" melee, but you could also create a spell that has the PlayerEffect of Ravage if it fits more.
	dmgType: "grope",
	attack: "MeleeEffectBlind", // "MeleeEffect" is the only necessary part
	attackLock: "White",
	power: 20, //i don't think this actually does anything with this enemy's setup - on theory, affects how strong their hits are
	attackPoints: 2, //set this to 0 for it to happen instantly on contact, no telegraph
	attackWidth: 2, 
	attackRange: 2.5, 
	fullBoundBonus: 0,
	disarm: 0.2,
	hitsfx: "Grab",

	// spawning/drops, i made this enemy drop a bunch of cash as reward
	terrainTags: {"secondhalf":10, "thirdhalf":1}, 
	shrines: ["Leather", "Metal"], 
	floors:KDMapInit(["jng", "cry", "tmp"]),
	dropTable: [{name: "Gold", amountMin: 50, amountMax: 100, weight: 10}],

	// special dash move, nothing too special about this
	specialAttack: "DashStun", 
	stunTime: 4,
	specialCD: 5, 
	specialCDonAttack: true, 
	specialAttackPoints: 2, 
	specialRange: 4,
	specialMinRange: 1.5,
	specialsfx: "Miss",
	specialWidth: 2, 
	specialRemove: "Effect", // don't want them also immediately pinning - unfair!!

	/*
		Ravage setup, also any other vanilla properties that are useful or required for ravagers
	*/
	ravage: { // custom ravage settings
		targets: ["ItemVulva", "ItemMouth", "ItemButt"], // enemy will only pick what's listed here. these three are the only valid slots right now
			// NOTE - butt will only be chosen if "Rear Plugs" from aroused mode is active.
		refractory: 50, // amount of turns to fall back to default attack behavior
		needsEyes: false, // this is assumed to be false by default, but if true, will remove blindfolds when going for mouth. (for hypno purposes obviously)
		
		onomatopoeia: ["CLAP...", "PLAP..."], //floats overhead like stat changes (can be unspecified for none)
		doneTaunts: ["That was good...", "Give me a minute and we'll go again, okay~?", "Such a good girl~!"],

		fallbackNarration: ["The ravager roughly gropes you! (DamageTaken)"],
		restrainChance: 0.05, // Chance, decimal between 0 and 1

		// progression data - first group that's got a number your count is less than is the one used
		// you can use any numbers, any ranges, but keep in mind that there's a turn between hits unless you're doing something like AttackPoints 0
		ranges: [
			[1, { // starting - no stat damage yet
				taunts: ["Relax, girlie...", "Hehe, ready~?"],
				narration: {
					ItemVulva: ["EnemyName lines her intimidating cock up with your pussy..."],
					ItemButt: ["EnemyName lines her intimidating cock up with your ass..."],
					ItemMouth: ["EnemyName presses her cockhead against your lips..."],
					ItemHead: ["head range 1"] //
				}
			}],

			[5, { // regular
				taunts: ["Mmh...", "That's it..."],
				narration: {
					ItemVulva: ["Wide hips meet yours as her cock stretches out your pussy..."],
					ItemButt: ["Wide hips meet your ass as her dick stretches you out..."],
					ItemMouth: ["Her strong hand guides your head up and down her thick cock..."],
					ItemHead: ["head range 5~"] //
				},
				sp: -0.1,
				dp: 1,
				orgasmBonus: 0,
			}],

			[12, { // rougher
				taunts: ["Good girl...", "Take it...", "I'm gonna miss you when we find you a nice master..."],
				narration: {
					ItemVulva: ["Strong hands grip your waist as your pussy is pounded..."],
					ItemButt: ["Your hips are gripped tight as your ass is railed..."],
					ItemMouth: ["Your face meets her lap, throating her cock over and over..."],
					ItemHead: ["head range 12"] //
				},
				sp: -0.15,
				dp: 1.5,
				orgasmBonus: 1,
			}],

			[16, { // peak intensity
				taunts: ["Ooh, good girl~!", "Haah!"],
				narration: {
					ItemVulva: ["You cry out with each hilting thrust, smothered by soft curves!"],
					ItemButt: ["Her ferocious thrusts drive pathetic whimpers out of you!"],
					ItemMouth: ["You feel weak, her dick filling your throat again and again!"],
					ItemHead: ["head range 16"] //
				},
				sp: -0.2,
				dp: 2,
				orgasmBonus: 2,
			}],

			[17, { // preparing to finish
				taunts: ["Here it comes~~!", "Let's fill you up~~!"],
				narration: {
					ItemVulva: ["With a thunderous final thrust, her dick throbs, she's about to--!!"],
					ItemButt: ["Her hips clap against yours with finality, she's about to--!!"],
					ItemMouth: ["Your vision fades as her cock pulses in your throat, she's about to--!!"],
					ItemHead: ["head range 17"] //
				},
				sp: -0.2,
				dp: 5,
				orgasmBonus: 3,
			}],

			[20, { // finishing
				taunts: ["Aaaah~...", "Ooohh~...", "That's a good pet~..."],
				narration: {
					ItemVulva: ["You moan loudly as you feel your womb flooded with her hot cum..."],
					ItemButt: ["Your belly grows warm as she fills you up, pounded powerfully into her lap..."],
					ItemMouth: ["GLK... GLK... You helplessly swallow wave after wave of her seed..."],
					ItemHead: ["head range 20"] //
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
	guardChance: 0.4, // chance to spawn as a "Guard" type AI
	focusPlayer: true, // obvious
	specialdialogue: "RavTesting"
}

KinkyDungeonEnemies.push(banditRavager)
KDEventMapEnemy['ravagerCallbacks']['definitionBanditRavager'] = banditRavager

//textkeys
addTextKey("NameBanditRavager", "Bandit Transporter")
addTextKey('AttackBanditRavagerDash','The bandit charges and captures you in a powerful hug!')
addTextKey('AttackBanditRavagerBlind','The bandit pins you against her soft body effortlessly!')
addTextKey("KillBanditRavager", "The bandit scrambles away, waiting for her next chance...")



// Custom Dialog testing
var dialog = {
	tags: ['RavTesting'],
	response: 'Default',
	clickFunction: (_gagged, _player) => { return false; },
	options: {
		"Test1": {
			playertext: 'Default',
			response: 'Default',
			clickFunction: (_gagged, _player) => {
				console.log('[RAVAGER TESTING]: Clicked on Test1')
			},
			options: {
				"Test1.1": {
					playertext: "Continue",
					response: "RavTest2"
				}
			}
		}
	}
}
KDDialogue['RavTesting'] = dialog
