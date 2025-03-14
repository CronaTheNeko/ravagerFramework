/**
	* An example of adding a callback
	* For consistency and simplicity, this example uses helper function `RavagerAddCallback(key, func)`
	* The `key` parameter is the name of your callback, and is what you will put in the relavant `*Callback` value of your ravager definition
	* The `func` parameter is the function that will be executed
	* Note: Please keep your callback name reasonably unique in order to avoid overwriting another ravager's callback function
  */
// Callback declaration. The parameters your callback is given depend on what section of the framework code is triggering your callback. Explanations in 'ravagerDevelopers.md'
function exampleRavagerRange1(entity, target, itemGroup) {
	console.log('[Ravager Framework] This is a range 1 callback function for the ExampleRavager! Here\'s the values you have access to in this function: Ravaging entity: ', entity, '; Target: ', target, '; itemGroup: ', itemGroup)
}
// Use the helper to add your callback to the game. The helper returns true if the callback was successfully added, and false if adding it failed
if (!RavagerAddCallback('exampleRavagerRange1', exampleRavagerRange1)) {
	console.error('[Ravager Framework][Example Ravager] Failed to add exampleRavagerRange1!')
}


/**
	* Example enemy definition
	* This example is based on the BanditRavager, as it's the simplest of the ravagers
	* The bandit has:
	* - "Effect" in its attack type, which enables it using the ravage effect
	* - A DashStun special to close gaps and stun the player
	* - `effect: { effect: { name: "Ravage" } }` to add the ravage effect as an option for this enemy
	* - And finally, a 'ravage' section, which is required for all ravagers
	*
	* Note: This enemy isn't actually added by this mod file, It's just an example.
	*       If you wanted to add this enemy to the spawn pool, you'd call this after defining:
	*       KinkyDungeonEnemies.push(exampleEnemy)
	* Note: Many of the comments in this declaration are related to generic enemy declartion and are
	*       included simply because I would like an easier reference for them.
	*       The values specific to ravagers are reiterated in 'ravagerDevelopers.md'
	*/
let exampleEnemy = {
	// ID information
	name: "BanditRavager", // The internal name of your enemy
	faction: "Bandit", // The faction of enemies your enemy should fit into 
	clusterWith: "bandit", // Defines what extra enemies this one can try to spawn with it
	playLine: "Bandit", // Defines the lines that will be used in places like jail. Seems to be defined as `KinkyDungeonRemindJailPlay<playLine>*`. Can be custom. Look for "KinkyDungeonRemindJailPlayBandit*" in Text_KinkyDungeon.csv for examples
	bound: "BanditGrappler", // The model in EnemiesBound/ that will be used when bound bar is max. Also sets the enemy as humanoid and bindable
	color: "#ddcaaa", // The color the enemy uses (name, floating text, warning tiles, etc.)
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
	ignorechance: 0, // Assuming chance for the enemy to ignore the player; assuming range is 0.0 to 1.0
	followRange: 1, // The range within which the enemy will try to follow the player
	AI: "hunt", // The type of AI to use. "hunt" is a good default as that will have the enemy roaming and looking for something to attack

	// Core stats
	armor: 1.5, // Damage reduction when the enemy is hit. Multiplied by 10 by the game, so this becomes 15 damage reduction
	maxhp: 12, // The max HP of the enemy. Multiplied by 10 by the game, so this becomes 120 health
	minLevel:0, // Minimum floor the enemy can appear on
	weight: -20, // Chance of spawning. Higher means a greater chance. Negative means rare.
	visionRadius: 7, // How well the enemy can see. 5 for nearsighted, 8 for observant, 9 and 10 are really damn observant and meant for bosses
	movePoints: 3, // How many turns until the enemy can move again. 3 means the enemy will wait 2 turns in between movements. 1 means they move every turn
	 
	// Main attack
	// P.S. - this enemy uses "Effect" melee, but you could also create a spell that has the PlayerEffect of Ravage if it fits more.
	dmgType: "grope", // Different types of damage have different effects on the player's various stats. Grope (I believe) decreases stamina and increases desire. Pain might also be fun to use
	attack: "MeleeEffectBlind", // "MeleeEffect" is the only necessary part, assuming you're using the normal melee effect for ravaging
	attackLock: "White", // ?
	power: 20, // The damage the enemy does, but I'm fairly sure the framework completely overrides the damage dealt to the player. This should still effect the damage this ravager does to other enemies though
	attackPoints: 2, // How many turns the enemy's attack takes. 2 gives 1 warning turn, 1 would be instant. This applies to the ravager's strip, pin, and occupy attacks, but doesn't effect the dash, as that is a special attack
	attackWidth: 2, // Width of the attack
	attackRange: 2.5, // Distance the attack can hit from. 2.5 seems to give the enemy consistent ability to hit diagonally
	fullBoundBonus: 0, // Adds onto the `power` if the player can't be bound further, increasing damage
	disarm: 0.2, // ? - Guessing this is the chance for the enemy to disarm the player?
	hitsfx: "Grab", // Sound to be played when an attack lands. Can (presumably) be omitted for no sound. Not sure where the sounds are defined/how to make a custom one

	// Spawning rules
	terrainTags: {"secondhalf":10, "thirdhalf":1}, // Modifiers to the spawn weight. "secondhalf" applies on floor numbers ending in 2, 3, 4, 5. Not sure what "thirdhalf" would effect. Docs half "lastthird" applying to floors 4 and 5 though
	shrines: ["Leather", "Metal"], // ?
	floors:KDMapInit(["jng", "cry", "tmp"]), // List of tilesets the enemy can spawn on. I think a list of available options can be found in KinkyDungeonParams.ts. You can always just copy the floors from an enemy in your ravager's faction
	dropTable: [{name: "Gold", amountMin: 50, amountMax: 100, weight: 10}], // What the enemy will drop. Multiple drops can be declared, the item is chosen randomly based on the weight, and the amount is random between Min and Max

	// A "dash to player" move
	specialAttack: "DashStun", 
	stunTime: 4, // Duration of player stun
	specialCD: 5, // Cooldown for dash
	specialCDonAttack: true, // Assuming set special on cooldown when doing a normal attack
	specialAttackPoints: 2, // Telegraph time, just like the standard attack's attackPoints
	specialRange: 4, // Max dash range
	specialMinRange: 1.5, // Min dash range
	specialsfx: "Miss", // Sound to play on special attack
	specialWidth: 2, // Attack width, just like the standard attack's
	specialRemove: "Effect", // We don't want them also immediately pinning. That could be a bit unfair

	/*
		Ravage setup, also any other vanilla properties that are useful or required for ravagers
	*/
	ravage: {
		targets: ["ItemVulva", "ItemMouth", "ItemButt"], // Enemy will only pick what's listed here. These three are the only valid slots currently
			// NOTE - Butt will only be chosen if "Rear Plugs" from aroused mode is active.
		refractory: 30, // Amount of turns to be a cooldown for ravaging the player

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
		 * See RavagerAddCallback function near the top of this file to add your callbacks.
		 * I will add a debugging/testing callback for every callback available for the sake of figuring out what values you'll have available to your callbacks. These will be the default values for this example enemy.
		*/

		// When: Any time a ravager takes a 'ravaging' action against the player
		// Why: Mainly to be able to set stuff up/do things before ravaging starts
		// Parameter types: enemy: Dicitonary, target: Dictionary
		// Return type: Boolean -- True to skip all normal ravaging actions, false to not skip things
		effectCallback: 'debugEffectCallback',

		// When: Anytime actions fail, often during the 'refractory' period after a ravager finishes with the player
		// Why: To override the default grope damage/restrain a ravager performs as a fallback
		// Parameter types: enemy: Object/Dictionary, target: Object/Dictionary
		// Note: Declaring this will completely override the normal fallback actions!
		//       Using this means you're doing your own stuff as a fallback and your ravager WILL NOT deal grope damage or restrain the player, unless your callback does so.
		//       A current limitation of the this fallback, and a reason you may want to use this, is that the default fallback's restraint-adding section only uses Jail restraints (as gotten via KDGetJailRestraints() ), but I plan to remove this limitation in the future, either by using a faction association or a custom list of restraints in the ravager declaration
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
		// Return type: Number -- The modified chance for the player to submit, between 0 and 100
		// Note: If nothing is returned or the return type is not a Number (as determined by calling `typeof` on the returned value), the returned value will be ignored
		submitChanceModifierCallback: 'debugSubmitChanceModifierCallback',

		/*
		 * Progression data
		 * The first array item that has a number greater than or equal to the ravager's current progress is the one used.
		 * You can use any ranges, greater than or equal to 1. Range 0 does technically exist, but these ranges are not checked until range 1.
		 * The ravaging will end after the ravager's progress equals the last/largest item in your ranges array. The Bandit, Wolf, Slime, and Tentacle ravagers all end at range 20, but you can make yours longer or shorter
		 * Range format: [ range, values ]
		 * 	- range: The progress number that is tested against the ravager's progress
		 * 	- values: A dictionary containing an array of taunts, a dictionary of narrations, and (optionally) a callback to add extra functionality
		 * 		- Narration dictionary: Key is an item group which the ravager is targetting (current options are ItemVulva, ItemButt, and ItemMouth), the value for each key is an array of narrations to display in the message log
		 * 		- Callback: A string to reference a callback function added via the AddCallback helper function near the top of this file
		 * Note: These ranges are NOT checked in numerical order. They are instead checked in the order they are defined.
		 *       So, for example, if you define range 5, then define range 1, range 1 will NEVER be triggered, as the code will find range 5 before range 1 and just run with range 5
		 *       I might redo this to avoid this limitation after I'm done refactoring and understanding all this ~CTN
		 */
		ranges: [
			[1, { // Starting - no stat damage yet
				taunts: ["Relax, girlie...", "Hehe, ready~?"], // Taunts are shown above the enemy
				narration: { // Narrations are shown in the text log at the top of the screen
					// Each of these correspond to a slot the ravager can target. If there are multiple options in these arrays, the line used will be randomly chosen from the array
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
				sp: -0.1, // Decrease stamina
				dp: 1, // Increase desire
				orgasmBonus: 0, // Bonus damage dealt due to player orgasming
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
				wp: -1, // Decrease willpower
				orgasmBonus: 4,
				sub: 1, // Increase submissiveness
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
// Note: There are often many text keys related to ravagers. Things like attack misses, taking damage, a bunch related to jails.
//       Depending on how your ravager is set up, she could wind up being a lovely goose chase of key after key.
//       As an example, take a look at slime_ravager.ks
/*
	addTextKey("NameBanditRavager", "Bandit Ravager")
	addTextKey('AttackBanditRavagerDash','The ravager charges and captures you in a powerful hug!')
	addTextKey('AttackBanditRavagerBlind','The ravager pins you against her soft body effortlessly!')
	addTextKey("KillBanditRavager", "The ravager scrambles away, waiting for her next chance...")
*/
