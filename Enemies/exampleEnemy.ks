/**********************************************
 * Adding an example callback
 * This will use the callback definition helper, as it makes this much simpler on your part
 * Check the comments at each callback option to know what parameters each one uses
 * Note: Please ensure your callback name is reasonably unique in order to avoid overwriting another ravager's callback function
*/
function exampleRavagerRange1(entity, target, itemGroup) {
	console.log('[Ravager Framework] This is a range 1 callback function for the ExampleRavager! Here\'s the values you have access to in this function: Ravaging entity: ', entity, '; Target: ', target, '; itemGroup: ', itemGroup)
}
if (!RavagerAddCallback('exampleRavagerRange1', exampleRavagerRange1)) {
	console.error('[Ravager Framework][Example Ravager] Failed to add exampleRavagerRange1!')
}


/**********************************************
 * Enemy definition
 * This is a good enemy example, since enemies that use ravage will definitely need it to be the main thing they do. 
	Bandit, that...
	- Has a DashStun special to close gaps. Stun makes them quite dangerous, since they can quickly strip and immobilize a target.
	- Has a special attack that applies the ravage "effect"

 * NOTE: this enemy isn't actually added by this mod file. it's just an example
	if you wanted to add this enemy to the spawn pool, you'd call this after defining:
	KinkyDungeonEnemies.push(exampleEnemy)
*/
let exampleEnemy = {
	// ID information
	name: "BanditRavager", // The internal name of your enemy
	faction: "Bandit", // The faction of enemies your enemy should fit into 
	clusterWith: "bandit", 
	playLine: "Bandit", 
	bound: "BanditGrappler", 
	color: "#ddcaaa",
	tags: KDMapInit([ // Enemy tags for your enemy to define what they can do
		// DO NOT add leashing or else they'll pull the player to jail and break everything
		// Otherwise, unless marked, the tags are up to your intention for the enemy
		"opendoors", 
		"closedoors", 
		"bandit", 
		"imprisonable", 
		"melee",
		"miniboss",
		"cacheguard", 
		"unflinching", // Makes enemy unable to be pulled/pushed. Maybe don't remove this
		"chainRestraints", 
		"nosub", // Prevents enemy from being submissive. Probably don't want to remove this one
		"handcuffer",
		"clothRestraints", 
		"chainweakness", 
		"glueweakness", 
		"jail", // Ravagers in jails makes for a good time
		"jailer", 
		"hunter"
	]),

	// AI
	ignorechance: 0, 
	followRange: 1, 
	AI: "hunt",

	// Core stats
	armor: 1.5, 
	maxhp: 12, 
	minLevel:0, // Notably this affects the earliest floor they can spawn on
	weight: -20, // Chance of spawning. Higher means a greater chance. Negative means rare.
	visionRadius: 7,
	movePoints: 3,
	 
	// Main attack
	// P.S. - this enemy uses "Effect" melee, but you could also create a spell that has the PlayerEffect of Ravage if it fits more.
	dmgType: "grope",
	attack: "MeleeEffectBlind", // "MeleeEffect" is the only necessary part, assuming you're using the normal melee effect for ravaging
	attackLock: "White",
	power: 20, //i don't think this actually does anything with this enemy's setup - on theory, affects how strong their hits are -- comment written by hogus bogus (OP), I'll have to testing if this will effect anything
	attackPoints: 2, // Defines how many turns the Ravager's melee attack is telegraphed for. Set to 0 for warning before attack lands, but this seems to get ravagers unable to progress through ravaging at some point. I recommend sticking to a minimum of 1. This applies to the ravager's strip, pin, and occupy attacks, but doesn't effect the dash. See below for the 'DashStun' special attack.
	attackWidth: 2, 
	attackRange: 2.5, 
	fullBoundBonus: 0,
	disarm: 0.2,
	hitsfx: "Grab",

	// Spawning rules
	terrainTags: {"secondhalf":10, "thirdhalf":1}, 
	shrines: ["Leather", "Metal"], 
	floors:KDMapInit(["jng", "cry", "tmp"]),
	// Drops -- Currently just drops Gold
	dropTable: [{name: "Gold", amountMin: 50, amountMax: 100, weight: 10}],

	// Dash to player move
	specialAttack: "DashStun", 
	stunTime: 4, // Duration of player stun
	specialCD: 5, // Cooldown for dash
	specialCDonAttack: true, 
	specialAttackPoints: 2, // Telegraph time, just like the standard attack's attackPoints
	specialRange: 4, // Max dash range
	specialMinRange: 1.5, // Min dash range
	specialsfx: "Miss",
	specialWidth: 2, 
	specialRemove: "Effect", // We don't want them also immediately pinning. That could be a bit unfair

	/*
		Ravage setup, also any other vanilla properties that are useful or required for ravagers
	*/
	ravage: { // Custom ravage settings
		targets: ["ItemVulva", "ItemMouth", "ItemButt"], // Enemy will only pick what's listed here. These three are the only valid slots currently
			// NOTE - Butt will only be chosen if "Rear Plugs" from aroused mode is active.
		refractory: 30, // Amount of turns to fall back to default attack behavior

		// Restraint/equipment considerations
		needsEyes: false, // This is assumed to be false by default, but if true, will remove blindfolds when going for mouth. (for hypno purposes obviously)
		bypassAll: false, // If true, the enemy will not need to strip anything, restraints or clothing
		bypassSpecial: [/* "Slime", "Liquid", "Rubber" */], // An array of strings of binding names your ravager can ignore (can be partial, i.e. "Slime" to bypass all slime)
		
		// Generic narration
		onomatopoeia: ["CLAP...", "PLAP..."], // Floats overhead when using the player (can be unspecified for none)
		doneTaunts: ["That was good...", "Give me a minute and we'll go again, okay~?", "Such a good girl~!"], // Floats overhead when finished with the player
		fallbackNarration: ["The ravager roughly gropes you! (DamageTaken)"], // Fallback incase any of the narration fails
		restrainChance: 0.2, // Chance, decimal between 0 and 1. Determines if the ravager will attempt to restrain the player instead of groping as a fallback action. Default: 0.2 (20%)

		/**********************************************
		 * Ravaging callbacks
		 * If callback values are not a string, they will not be used to find a callback.
		 * If you want to use a callback, set the relavant value to the string key of your function.
		 * See AddCallback function near the top of this file to add your callbacks.
		 * I will add a debugging/testing callback for every callback available for the sake of figuring out what values you'll have available to your callbacks. These will be the default values for this example enemy.
		*/

		// When: Any time a ravager takes a 'ravaging' action against the player
		// Why: Mainly to be able to set stuff up/do things before ravaging starts
		// Parameter types: enemy: Dicitonary, target: Dictionary
		// Return type: Boolean -- True to skip all normal ravaging actions, false to not skip things
		effectCallback: 'debugEffectCallback',

		// When: Anytime actions fail, often during the 'refactory' period after a ravager finishes with the player
		// Why: To override the default grope damage/restrain a ravager performs as a fallback
		// Parameter types: enemy: Object/Dictionary, target: Object/Dictionary
		// Note: Declaring this will completely override the normal fallback actions!
		// Note 2: Using this means you're doing your own stuff as a fallback and your ravager WILL NOT deal grope damage or restrain the player, unless your callback does it
		// Note 3: A current limitation of the current fallback, and a reason you may want to use this, is that the default fallback's restraint-adding section only uses Jail restraints (as gotten via KDGetJailRestraints() ), but I plan to remove this limitation in the future, either by using a faction association or a custom list of restraints in the ravager declaration
		fallbackCallback: 'debugFallbackCallback', 

		// When: After finishing with the player
		// Parameter types: enemy: Object/Dictionary, target: Object/Dictionary, passedOut: Boolean
		completionCallback: 'debugCompletionCallback',

		// When: Upon triggering an action within the ranges of ravaging.
		// Parameter types: enemy: Object/Dictionary, target: Object/Dictionary, itemGroup: String
		// Note: itemGroup is the slot the enemy is 'ravaging' through
		allRangeCallback: 'debugAllRangeCallback',

		// When: Before checking the chance of player submitting to the ravager for submission effects
		// Parameter types: enemy: Object/Dictionary, target: Object/Dictionary, baseSubmitChance: Number
		// Note: Should return a number between 0 and 100 to represent the percentage chance
		submitChanceModifierCallback: 'debugSubmitChanceModifierCallback',

		/**********************************************
		 * Progression data
		 * The first array item that has a number less than or equal to the ravager's current progress is the one used.
		 * You can use any ranges, greater than or equal to 1. Range 0 does technically exist, but these ranges are not checked until range 1.
		 * Range format: [ range, values ]
		 * 	- range: The progress number that is tested against the ravager's progress
		 * 	- values: A dictionary containing an array of taunts, a dictionary of narrations, and (optionally) a callback to add extra functionality
		 * 		- Narration dictionary: Key is an item group which the ravager is targetting (current options are ItemVulva, ItemButt, ItemMouth, and ItemHead), the value for each key is an array of narrations to display in the message log
		 * 		- Callback: A string to reference a callback function added via the AddCallback helper function near the top of this file
		 * Note: These ranges are NOT checked in numerical order. They are instead checked in the order they are defined. So, for example, if you define range 5, then define range 1, range 1 will NEVER be triggered, as the code will find range 5 before range 1 and just run with range 5 -- I might redo this to avoid this limitation after I'm done refactoring and understanding all this ~CTN
		*/
		ranges: [
			[1, { // Starting - no stat damage yet
				taunts: ["Relax, girlie...", "Hehe, ready~?"],
				narration: {
					ItemVulva: ["EnemyName lines her intimidating cock up with your pussy..."],
					ItemButt: ["EnemyName lines her intimidating cock up with your ass..."],
					ItemMouth: ["EnemyName presses her cockhead against your lips..."],
				},
				// When: When ravager takes an action that matches inside this range
				// Parameter types: enemy: Object/Dictionary, target: Object/Dictionary, itemGroup: String
				callback: 'debugRangeX'
			}],

			[5, { // Regular
				taunts: ["Mmh...", "That's it..."],
				narration: {
					ItemVulva: ["Wide hips meet yours as her cock stretches out your pussy..."],
					ItemButt: ["Wide hips meet your ass as her dick stretches you out..."],
					ItemMouth: ["Her strong hand guides your head up and down her thick cock..."],
				},
				sp: -0.1,
				dp: 1,
				orgasmBonus: 0,
				callback: 'debugRangeX'
			}],

			[12, { // Rougher
				taunts: ["Good girl...", "Take it...", "I'm gonna miss you when we find you a nice master..."],
				narration: {
					ItemVulva: ["Strong hands grip your waist as your pussy is pounded..."],
					ItemButt: ["Your hips are gripped tight as your ass is railed..."],
					ItemMouth: ["Your face meets her lap, throating her cock over and over..."],
				},
				sp: -0.15,
				dp: 1.5,
				orgasmBonus: 1,
				callback: 'debugRangeX'
			}],

			[16, { // Peak intensity
				taunts: ["Ooh, good girl~!", "Haah!"],
				narration: {
					ItemVulva: ["You cry out with each hilting thrust, smothered by soft curves!"],
					ItemButt: ["Her ferocious thrusts drive pathetic whimpers out of you!"],
					ItemMouth: ["You feel weak, her dick filling your throat again and again!"],
				},
				sp: -0.2,
				dp: 2,
				orgasmBonus: 2,
				callback: 'debugRangeX'
			}],

			[17, { // Preparing to finish
				taunts: ["Here it comes~~!", "Let's fill you up~~!"],
				narration: {
					ItemVulva: ["With a thunderous final thrust, her dick throbs, she's about to--!!"],
					ItemButt: ["Her hips clap against yours with finality, she's about to--!!"],
					ItemMouth: ["Your vision fades as her cock pulses in your throat, she's about to--!!"],
				},
				sp: -0.2,
				dp: 5,
				orgasmBonus: 3,
				callback: 'debugRangeX'
			}],

			[20, { // Finishing
				taunts: ["Aaaah~...", "Ooohh~...", "That's a good pet~..."],
				narration: {
					ItemVulva: ["You moan loudly as you feel your womb flooded with her hot cum..."],
					ItemButt: ["Your belly grows warm as she fills you up, pounded powerfully into her lap..."],
					ItemMouth: ["GLK... GLK... You helplessly swallow wave after wave of her seed..."],
				},
				dp: 10,
				wp: -1,
				orgasmBonus: 4,
				sub: 1,
				callback: 'debugRangeX'
			}],
		]
	},

	// On-hit effect definition - required for this to work
	effect: {
		effect: {
			name: "Ravage"
		}
	},

	// These events are required for ravager stuff to work properly
	events: [
		{trigger: "death", type: "ravagerRemove"},
		{trigger: "tickAfter", type: "ravagerRefractory"},
	],

	// Useful flags
	noDisplace: true, // theoretically stops enemies from shoving this one out of the way. didn't seem to work by its lonesome for me -- Written by hogus bogus, will have to test this out ~CTN
	guardChance: 0.4, // Chance to spawn as a "Guard" type AI when player is trapped
	focusPlayer: true, // Obviously
}

// After defining, this enemy can be added to the game by uncommenting the following line
// KinkyDungeonEnemies.push(exampleEnemy)

// Additionally, some example textkeys
// For each of these example text keys, wherever 'BanditRavager' appears in the first string, that will need to match whatever exampleEnemy.name is set to.
// For example, for an enemy where name is set to 'CustomRavager', you'll need the text keys 'NameCustomRavager', 'AttackCustomRavagerDash', 'AttackCustomRavagerBlind', 'KillCustomRavager'
/*
	addTextKey("NameBanditRavager", "Bandit Ravager")
	addTextKey('AttackBanditRavagerDash','The ravager charges and captures you in a powerful hug!')
	addTextKey('AttackBanditRavagerBlind','The ravager pins you against her soft body effortlessly!')
	addTextKey("KillBanditRavager", "The ravager scrambles away, waiting for her next chance...")
*/
