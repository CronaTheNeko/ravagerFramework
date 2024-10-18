/**********************************************
 * Callback definition helper
 * This function is a simple helper the I would recommend using if you're going to add callbacks for your ravager.
 * Takes two parameters:
 * 	- The key which will be used to reference your callback. This is the value to use when setting a callback value inside your ravager's definition.
 * 	- The function to use as a callback. 
 * Note: If you decide to not use this function, there are two things you need to know:
 * 	- If RavagerFramework itself does not load before your enemy, KDEventMapEnemy['ravagerCallbacks'] will not exist yet. This will cause the game will show a crash if you try to add a callback entry into that map, and that will cause execution of your JS file to stop at that line, potentially causing your ravager to never be added to the game
 * 	- Your function should be the value of KDEventMapEnemy['ravagerCallbacks'][<callback name>]
*/
function AddCallback(key, func) {
	if (! KDEventMapEnemy['ravagerCallbacks']) {
		throw new Error('Ravager Framework has not been loaded yet! Please ensure that the Framework has been added and is listed alphabetically before your custom Ravager mod. If this is happening without any additional ravager mods (aka only Ravager Framework is adding ravagers), please post as much info as you can to the framework\'s thread on Discord so it can be investigated')
	} else {
		// When creating a custom ravager mod, I'd suggest changing this log call to have your mod's name inside the [ ] to help make it more clear what is loading when
		console.log('[Ravager Framework] Adding callback function with key ', key)
		KDEventMapEnemy['ravagerCallbacks'][key] = func
	}
}

// BEGIN Tentacle Pit
// Tentacle Pit definition
let pit = {
	addedByMod: 'RavagerFramework',
	name: 'TentaclePit',
	faction: 'Plant',
	clusterWith: 'plant',
	color: '#085c0e',
	tags: KDMapInit([
		'immobile',
		'poisonresist',
		'soulimmune',
		'melee',
		'elite',
		'unflinching',
		'fireweakness',
		'crushweakness',
		'chainweakness',
		'glueresist',
		'hunter'
	]),
	armor: 3.0,
	spellResist: 1.5,
	evasion: -2,
	maxblock: 2,
	blockAmount: 2.5,
	maxdodge: 0,
	nopickpocket: true,
	ignorechance: 0.5,
	followRange: 1,
	// AI: 'ambush',
	AI: 'hunt',
	summon: [{
		enemy: 'RavagerTendril',
		range: 2.5,
		count: 1,
		strict: true
	}],
	spells: [
		'SummonTentaclePitTendril'
	],
	spellCooldownMult: 1,
	spellCooldownMod: 0,
	events: [
		{
			trigger: 'spellCast',
			type: 'tentaclePitSummonTendril'
		},
		{
			trigger: 'afterDamageEnemy',
			type: 'bleedEffectTile',
			kind: 'FabricGreen',
			aoe: 1.5,
			power: 1,
			chance: 1.0,
			duration: 20
		}
	],
	visionRadius: 10,
	maxhp: 20,
	minLevel: 2,
	weight: 2,
	movePoints: 0,
	//
	attackPoints: 2,
	// attack: 'MeleeWill',
	attack: 'SpellMeleeWill',
	attackWidth: 2.5,
	// attackMinRange: 2.5,
	attackRange: 2,
	power: 0.8,
	dmgType: 'pain',
	attackLock: 'White',
	//
	specialAttack: 'PullStun',
	stunTime: 3,
	pullDist: 8,
	pullTowardSelf: true,
	specialWidth: 1,
	specialMinRange: 2,
	specialRange: 8,
	specialCD: 4,
	specialCDonAttack: true,
	specialsfx: 'Grab',
	specialAttackPoints: 2,
	//
	terrainTags: {
		'secondhalf': 16,
		'lastthird': 5,
		'open': 20,
		'passage': -60,
		'increaseWeight': 1
	},
	floors: KDMapInit(['jng']),
	shrines: [],
	dropTable: [
		{
			name: 'VinePlantArms',
			amountMin: 1,
			amountMax: 5,
			weight: 12
		},
		{
			name: 'VinePlantLegs',
			amountMin: 1,
			amountMax: 5,
			weight: 12
		},
		{
			name: 'VinePlantFeet',
			amountMin: 1,
			amountMax: 5,
			weight: 12
		},
		{
			name: 'VinePlantTorso',
			amountMin: 1,
			amountMax: 5,
			weight: 12
		},
		{ // --- Haven't implemented yet, but my idea is to make a consumable that can repel humanoid ravagers (some kind of dialog like 'an abomination already used you')
			name: 'ravagerTendrilCum',
			amountMin: 1,
			amountMax: 5,
			weight: 1
		}
	]
}
// Summon spell definition
let summonSpell = {
	enemySpell: true,
	name: 'SummonTentaclePitTendril',
	noSprite: false,
	sfx: 'Evil',
	castCondition: 'tentaclePitSummon',
	manacost: 2,
	specialCD: 30,
	components: ['Verbal'],
	level: 1,
	projectileTargeting: true,
	castRange: 2,
	type: 'inert',
	onhit: 'summon',
	summon: [{
		name: 'RavagerTendril',
		count: 1,
		bound: true
	}],
	power: 0,
	damage: 'inert',
	time: 34,
	delay: 1,
	range: 0.5,
	size: 3,
	aoe: 1.5,
	lifetime: 1,
	speed: 1,
	playerEffect: {}
}
// Cast condition for summon spell
let summonCondition = (enemy, target) => {
	// Condition copied and modified from SarcoKraken's summon minion condition
	let nearbyEnemies = KDNearbyEnemies(enemy.x, enemy.y, 10) // How many enemies are nearby
	// console.log(nearbyEnemies)
	let nearbyMinions = nearbyEnemies.filter(enemy => { return enemy.Enemy?.tags.pittendril }) // How many of the nearby enemies are minions
	// console.log(nearbyMinions)
	let maxByHP = Math.floor(enemy.hp / enemy.Enemy.maxhp / 0.2) // How many minions can it have depending on health
	// console.log(maxByHP)
	let minCount = Math.min(2, 1 + maxByHP) // How many minions can we summon, minimum of defined max (2 to get three minions out) or max based on health (+1 to ensure we always can summon at least one)
	// console.log(minCount)
	if (nearbyMinions.length > minCount)
		return false
	return true
}
// Add Tentacle Pit's definitions
KDCastConditions['tentaclePitSummon'] = summonCondition
KinkyDungeonSpellListEnemies.push(summonSpell)
KinkyDungeonEnemies.push(pit)
KDEventMapEnemy['ravagerCallbacks']['definitionTentaclePit'] = pit
// Text keys
addTextKey('NameTentaclePit', 'Tentacle Pit')
addTextKey('AttackTentaclePitStun', 'A strong tentacle wraps around your torso and pulls you towards the pit')
addTextKey('KillTentaclePit', 'The tentacles writhe in pain and retreat into the ground')
addTextKey('AttackTentaclePit', 'A tentacle swings and whips your body')
addTextKey('KinkyDungeonSummonSingleRavagerTendril', 'An eager tentacle bursts out of the ground nearby')
// END Tentacle Pit

// BEGIN Ravaging Tendril
// Effect callback for groping before ravaging
AddCallback('pitTendrilEffectCallback', (enemy, target) => {
	// console.log('tendirl test')
	// return false
	if (enemy.ravage && enemy.ravage.progress == 1 && !enemy.ravage.finishedCarressing) {
		// KinkyDungeonSendFloater(enemy, 'carress', '#ffffff', 2)
		// return true
		if (Math.random() < enemy.Enemy.ravage.carressChance) {
			console.log('[Ravager Framework][RavagerTendril] Carressing player before ravaging')
			KinkyDungeonSendFloater(enemy, 'carress', '#ffffff', 2)
			return true
		} else {
			console.log('[Ravager Framework][RavagerTendril] Finished carressing')
			enemy.ravage.finishedCarressing = true
		}
	}
	return false
})
// Tendril definition
let tendril = {
	addedByMod: 'RavagerFramework',
	name: 'RavagerTendril',
	faction: 'Plant',
	color: '#99ff99',
	tags: KDMapInit([
		'poisonresist',
		'soulimmune',
		'melee',
		'unflinching',
		'fireweakness',
		'crushweakness',
		'chainweakness',
		'glueresist',
		'hunter',
		'minor',
		'pittendril',
		'nosub',
		'immobile'
	]),
	ignorechance: 0,
	followRange: 2,
	AI: 'hunt',
	master: {
		type: 'TentaclePit',
		range: 10
	},
	dependent: true,
	visionRadius: 10,
	maxhp: 5,
	minLevel: 0,
	weight: -1000,
	movePoints: 1,
	attackPoints: 2,
	attack: 'MeleeEffect',
	attackWidth: 2,
	attackRange: 1.5,
	attackLock: 'White', // What colors are available to pick?
	disarm: 0.2,
	hitsfx: 'Grab',
	power: 20,
	dmgType: 'grope',
	noAlert: true,
	events: [
		{
			trigger: 'afterDamageEnemy',
			type: 'bleedEffectTile',
			kind: 'FabricGreen',
			aoe: 1.5,
			power: 1,
			chance: 1,
			duration: 20
		},
		{
			trigger: 'death',
			type: 'ravagerRemove'
		},
		{
			trigger: 'tickAfter',
			type: 'ravagerRefactory'
		}
	],
	nopickpocket: true,
	maxblock: 0,
	maxdodge: 0,
	terrainTags: {},
	allFloors: true,
	shrines: [], // Tentacle Kraken minion used rope, but wanted to change to a shrine relating to dryads, so figure out what shrine that is and put here
	ravage: {
		carressChance: 0.5,
		targets: ['ItemVulva', 'ItemButt', 'ItemMouth'],
		refactory: 5, // Planning to make the tendril despawn on completion, so this shouldn't matter
		needsEyes: false, // Could try to hypno player to 'addict' them by adding a debuff after a while of not being ravaged by plant; maybe a good use for the ravagerTendrilCum; maybe better done through an aphrodisiac for the plant
		onomatopoeia: ['*Excited wriggling*', 'CLAP...', 'PLAP...'],
		doneTaunts: ['*Happy carressing*'],
		fallbackNarration: ['The tendril carresses your curves (damage taken)'],
		completionCallback: 'pitTendrilCompletion', // Callback to despawn tendril after ravaging, maybe after ravaging twice
		effectCallback: 'pitTendrilEffectCallback', // Callback to allow the tendril to carress the player (fallback style) for a bit before using her
		ranges: [
			[1, {
				taunts: [ '*Preemtive dripping*', '*Wriggling and pulsing*' ],
				narration: {
					ItemVulva: [ 'The EnemyName rubs its\' wet tip against your pussy...' ],
					ItemButt: [ 'The EnemyName rubs its\' wet tip against your ass...' ],
					ItemMouth: [ 'The EnemyName presses its\' tip against your lips...' ]
				}
			}],
			[5, {
				taunts: [ '*Passionate squirming*', '*Wriggling and pulsing*' ],
				narration: {
					ItemVulva: [ 'Your pussy is forced to stretch as the thick tendril plunges inside of you...' ],
					ItemButt: [ 'Your ass is forced to stretch as the thick tendril plunges inside of you...' ],
					ItemMouth: [ 'You gag as your throat is filled by the tendril...' ]
				},
				sp: -0.1,
				dp: 1,
				orgasmBonus: 0
			}],
			[12, {
				taunts: [ '*Rough thrusting*', '*Slow pulsating*' ],
				narration: {
					ItemVulva: [ 'More tendrils emerge to grip your legs while your pussy is pounded...' ],
					ItemButt: [ 'More tendrils emerge to grip your waist while your ass is abused...' ],
					ItemMouth: [ 'Another tendril emerges to cradle your head and wrap around your throat...' ]
				},
				sp: -0.15,
				dp: 1.5,
				orgasmBonus: 1
			}],
			[16, {
				taunts: [ '*Rough thrusting*', '*Deep thrusting*' ],
				narration: {
					ItemVulva: [ 'You cry out with each deep thrust, smothered by tentacles!' ],
					ItemButt: [ 'The tendril\'s rough thrusts drive pathetic whimpers out of you!' ],
					ItemMouth: [ 'You choke and feel weak, the tendril filling your throat with every thrust!' ]
				},
				sp: -0.2,
				dp: 2,
				orgasmBonus: 2
			}],
			[17, {
				taunts: [ '*Massively pulsating*', '*Pumping cum*' ],
				narration: {
					ItemVulva: [ 'With deeply penatrating final thrusts, the tendril pulsates quickly, it\'s about to--!!' ],
					ItemButt: [ 'The tendril invades your ass to extreme depths, it\'s about to--!!' ],
					ItemMouth: [ 'You gag and resist as the tendril thrusts deep into your throat, it\'s about to--!!' ]
				},
				sp: -0.2,
				dp: 5,
				orgasmBonus: 3
			}],
			[20, {
				taunts: [ '*Satisfied pulsing*', '*Pumping cum*' ],
				narration: {
					ItemVulva: [ 'You moan loudly, your belly stretching as your womb is filled with the tendril\'s seed...!' ],
					ItemButt: [ 'Your belly grows as you\'re filled with tentacle seed, laying limp in her tentacles...' ],
					ItemMouth: [ 'You helplessly swallow wave after wave of the tendril\'s cum...' ]
				},
				dp: 10,
				wp: -1,
				orgasmBonus: 4,
				sub: 1
			}]
		]
	},
	effect: {
		effect: {
			name: 'Ravage'
		}
	},
	focusPlayer: true
}

KinkyDungeonEnemies.push(tendril)
KDEventMapEnemy['ravagerCallbacks']['definitionPitTendril'] = tendril
// Text keys
addTextKey('NameRavagerTendril', 'Dripping Tentacle')
addTextKey('KillRavagerTendril', 'The tentacle thrashes and vanishes below the ground')
addTextKey('AttackRavagerTendril', 'The tentacle roughly gropes you')
// END Ravaging Tendril
