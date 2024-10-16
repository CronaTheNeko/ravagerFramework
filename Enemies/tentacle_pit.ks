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
			amountMax: 10,
			weight: 12
		},
		{
			name: 'VinePlantLegs',
			amountMin: 1,
			amountMax: 10,
			weight: 12
		},
		{
			name: 'VinePlantFeet',
			amountMin: 1,
			amountMax: 10,
			weight: 12
		},
		{
			name: 'VinePlantTorso',
			amountMin: 1,
			amountMax: 10,
			weight: 12
		},
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
	specialCD: 15,
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
		targets: ['ItemVulva', 'ItemButt', 'ItemMouth'],
		refactory: 5,
		onomatopoeia: ['ono 1', 'ono 2'],
		doneTaunts: ['happy writhing'],
		fallbackNarration: ['fallback narration'],
		completionCallback: 'pitTendrilCompletion',
		ranges: [
			[1, {
				taunts: ['taunt 1 1', 'taunt 2 1'],
				narration: {
					ItemVulva: ['vulva 1'],
					ItemButt: ['butt 1'],
					ItemMouth: ['mouth 1']
				}
			}],
			[5, {
				taunts: ['taunt 5 1', 'taunt 5 2'],
				narration: {
					ItemVulva: ['vulva 5'],
					ItemButt: ['butt 5'],
					ItemMouth: ['mouth 5']
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
