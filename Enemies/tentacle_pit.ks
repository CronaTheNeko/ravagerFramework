// BEGIN Tentacle Pit
// Tentacle Pit definition
let pit = {
	addedByMod: 'RavagerFramework',
	RFDisableRefvar: "ravagerDisableTentaclePit",
	name: 'TentaclePit',
	faction: 'Plant',
	clusterWith: 'plant',
	color: '#085c0e',
	tags: KDMapInit([
		'nature',
		'plant',
		'immobile',
		'poisonresist',
		'soulimmune',
		'melee',
		// 'elite',
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
	power: 0.1,
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
		// { // --- Haven't implemented yet, but my idea is to make a consumable that can repel humanoid ravagers (some kind of dialog like 'an abomination already used you')
		// 	name: 'ravagerTendrilCum',
		// 	amountMin: 1,
		// 	amountMax: 5,
		// 	weight: 1
		// }
	],
	noDisplace: true,
	noswap: true,
	noFlip: true,
	nonHumanoid: true
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
	let nearbyMinions = nearbyEnemies.filter(enemy => { return enemy.Enemy?.tags.pittendril }) // How many of the nearby enemies are minions
	let maxByHP = Math.floor(enemy.hp / enemy.Enemy.maxhp / 0.2) // How many minions can it have depending on health
	let minCount = Math.min(2, 1 + maxByHP) // How many minions can we summon, minimum of defined max (2 to get three minions out) or max based on health (+1 to ensure we always can summon at least one)
	if (nearbyMinions.length > minCount)
		return false
	return true
}
// Add Tentacle Pit's definitions
KDCastConditions['tentaclePitSummon'] = summonCondition
KinkyDungeonSpellListEnemies.push(summonSpell)
KinkyDungeonEnemies.push(pit)
RavagerData.Definitions.Enemies.TentaclePit = structuredClone(pit)
// Text keys
addTextKey('NameTentaclePit', 'Tentacle Pit')
addTextKey('AttackTentaclePitStun', 'A strong tentacle wraps around your torso and pulls you towards the pit')
addTextKey('KillTentaclePit', 'The tentacles writhe in pain and retreat into the ground')
addTextKey('AttackTentaclePit', 'A tentacle swings and whips your body')
addTextKey('KinkyDungeonSummonSingleRavagerTendril', 'An eager tentacle bursts out of the ground nearby')
// END Tentacle Pit

// BEGIN Ravaging Tendril
// Completion callback to kill tendril upon ravaging completion
function pitTendrilCompletion(enemy, target, passedOut) {
	console.log('[Ravager Framework][Ravager Tendril] Killing tendril')
	enemy.hp = 0;
}
if (!RavagerAddCallback('pitTendrilCompletion', pitTendrilCompletion)) {
	console.error('[Ravager Framework][Ravager Tendril] Failed to add pitTendrilCompletion!')
}
// Effect callback for groping before ravaging
function pitTendrilEffect(enemy, target) {
	if (enemy.ravage && enemy.ravage.progress == 1 && !enemy.ravage.finishedCarressing) {
		if (Math.random() < enemy.Enemy.ravage.caressChance) {
			console.log('[Ravager Framework][Ravager Tendril] Carressing player before ravaging')
			let msg = ''
			switch (enemy.ravage.slot) {
			case 'ItemVulva':
				msg = 'The tendril rubs itself into your lower lips..'
				break;
			case 'ItemButt':
				msg = 'The tendril caresses your ass and hips..'
				break;
			case 'ItemMouth':
				msg = 'The tendril caresses your cheek and rubs under your chin..'
				break;
			default:
				msg = 'The tendril delicately caresses your curves..'
				break;
			}
			KinkyDungeonSendActionMessage(20, msg, '#ff00ff', 1)
			KinkyDungeonDealDamage({type: 'grope', damage: 0.4})
			return true
		} else {
			console.log('[Ravager Framework][RavagerTendril] Finished caressing')
			enemy.ravage.finishedCarressing = true
		}
	}
	return false
}
if (!RavagerAddCallback('pitTendrilEffectCallback', pitTendrilEffect)) {
	console.error('[Ravager Framework][Ravager Tendril] Failed to add pitTendrilEffectCallback!')
}
// Tendril definition
let tendril = {
	addedByMod: 'RavagerFramework',
	RFDisableRefvar: "ravagerDisableTentaclePit",
	name: 'RavagerTendril',
	faction: 'Plant',
	color: '#99ff99',
	tags: KDMapInit([
		'nature',
		'plant',
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
			type: 'ravagerRefractory'
		}
	],
	nopickpocket: true,
	maxblock: 0,
	maxdodge: 0,
	terrainTags: {},
	allFloors: true,
	shrines: [], // Tentacle Kraken minion used rope, but wanted to change to a shrine relating to dryads, so figure out what shrine that is and put here
	dropTable: [
		{
			name: 'VinePlantArms',
			amountMin: 1,
			amountMax: 1,
			weight: 1
		},
		{
			name: 'VinePlantLegs',
			amountMin: 1,
			amountMax: 1,
			weight: 1
		},
		{
			name: 'VinePlantFeet',
			amountMin: 1,
			amountMax: 1,
			weight: 1
		},
		{
			name: 'VinePlantTorso',
			amountMin: 1,
			amountMax: 1,
			weight: 1
		},
		// { // --- Haven't implemented yet, but my idea is to make a consumable that can repel humanoid ravagers (some kind of dialog like 'an abomination already used you')
		// 	name: 'ravagerTendrilCum',
		// 	amountMin: 1,
		// 	amountMax: 5,
		// 	weight: 1
		// }
	],
	ravage: {
		caressChance: 0.5,
		targets: ['ItemVulva', 'ItemButt', 'ItemMouth'],
		refactory: 5, // Tendril is killed on completion, so this really doesn't matter
		needsEyes: false, // Could try to hypno player to 'addict' them by adding a debuff after a while of not being ravaged by plant; maybe a good use for the ravagerTendrilCum; maybe better done through an aphrodisiac for the plant
		onomatopoeia: ['*Excited wriggling*', 'CLAP...', 'PLAP...'],
		doneTaunts: ['*Happy caressing*'],
		fallbackNarration: ['The tendril caresses your curves (DamageTaken)'],
		completionCallback: 'pitTendrilCompletion', // Callback to despawn tendril after ravaging, maybe after ravaging twice
		effectCallback: 'pitTendrilEffectCallback', // Callback to allow the tendril to caress the player (fallback style) for a bit before using her
		ranges: [
			[1, {
				taunts: [ '*Preemtive dripping*', '*Wriggling and pulsing*' ],
				narration: {
					// 'Wild' version
					SpicyItemVulva: [ 'EnemyCName rubs its\' wet tip against your pussy...' ],
					SpicyItemButt: [ 'EnemyCName rubs its\' wet tip against your ass...' ],
					SpicyItemMouth: [ 'EnemyCName presses its\' tip against your lips...' ],
					//
					// 'Tame' version
					TameItemVulva: [ 'EnemyCName rubs its\' wet tip against your pussy...' ],
					TameItemButt: [ 'EnemyCName rubs its\' wet tip against your ass...' ],
					TameItemMouth: [ 'EnemyCName presses its\' tip against your lips...' ],
					//
					// Active narration
					ItemVulva: [ 'EnemyCName rubs its\' wet tip against your pussy...' ],
					ItemButt: [ 'EnemyCName rubs its\' wet tip against your ass...' ],
					ItemMouth: [ 'EnemyCName presses its\' tip against your lips...' ],
					//
				}
			}],
			[5, {
				taunts: [ '*Passionate squirming*', '*Wriggling and pulsing*' ],
				narration: {
					// 'Wild' version
					SpicyItemVulva: [ 'Your pussy is forced to stretch as the thick tendril plunges inside of you...' ],
					SpicyItemButt: [ 'Your ass is forced to stretch as the thick tendril plunges inside of you...' ],
					SpicyItemMouth: [ 'You gag as your throat is filled by the tendril...' ],
					//
					// 'Tame' version
					TameItemVulva: [ 'Your pussy is stretched as the thick tendril plunges inside of you...' ],
					TameItemButt: [ 'Your ass is stretched as the thick tendril plunges inside of you...' ],
					TameItemMouth: [ 'You gag as your throat is filled by the tendril...' ],
					//
					// Active narration
					ItemVulva: [ 'Your pussy is stretched as the thick tendril plunges inside of you...' ],
					ItemButt: [ 'Your ass is stretched as the thick tendril plunges inside of you...' ],
					ItemMouth: [ 'You gag as your throat is filled by the tendril...' ],
					//
				},
				sp: -0.1,
				dp: 1,
				orgasmBonus: 0
			}],
			[12, {
				taunts: [ '*Rough thrusting*', '*Slow pulsating*' ],
				narration: {
					// 'Wild' version
					SpicyItemVulva: [ 'More tendrils emerge to grip your legs while your pussy is pounded...' ],
					SpicyItemButt: [ 'More tendrils emerge to grip your waist while your ass is abused...' ],
					SpicyItemMouth: [ 'Another tendril emerges to cradle your head and wrap around your throat...' ],
					//
					// 'Tame' version
					TameItemVulva: [ 'More tendrils emerge to grip your legs while your pussy is pounded...' ],
					TameItemButt: [ 'More tendrils emerge to grip your waist while your ass is pounded...' ],
					TameItemMouth: [ 'Another tendril emerges to cradle your head and wrap around your throat...' ],
					//
					// Active narration
					ItemVulva: [ 'More tendrils emerge to grip your legs while your pussy is pounded...' ],
					ItemButt: [ 'More tendrils emerge to grip your waist while your ass is pounded...' ],
					ItemMouth: [ 'Another tendril emerges to cradle your head and wrap around your throat...' ],
					//
				},
				sp: -0.15,
				dp: 1.5,
				orgasmBonus: 1
			}],
			[16, {
				taunts: [ '*Rough thrusting*', '*Deep thrusting*' ],
				narration: {
					// 'Wild' version
					SpicyItemVulva: [ 'You cry out with each thrust of the tendril invading your womb!' ],
					SpicyItemButt: [ 'The tendril\'s rough thrusts drive pathetic whimpers out of you!' ],
					SpicyItemMouth: [ 'You choke and feel weak, the tendril filling your throat with each thrust!' ],
					//
					// 'Tame' version
					TameItemVulva: [ 'You cry out with each thrust, smothered by tentacles!' ],
					TameItemButt: [ 'The tendril\'s rough thrusts drive pathetic whimpers out of you!' ],
					TameItemMouth: [ 'You feel weak, the tendril filling your throat with each thrust!' ],
					//
					// Active narration
					ItemVulva: [ 'You cry out with each thrust, smothered by tentacles!' ],
					ItemButt: [ 'The tendril\'s rough thrusts drive pathetic whimpers out of you!' ],
					ItemMouth: [ 'You feel weak, the tendril filling your throat with each thrust!' ],
					//
				},
				sp: -0.2,
				dp: 2,
				orgasmBonus: 2
			}],
			[17, {
				taunts: [ '*Massively pulsating*', '*Pumping cum*' ],
				narration: {
					// 'Wild' version
					SpicyItemVulva: [ 'With deeply penatrating final thrusts, the tendril pulsates quickly, it\'s about to--!!' ],
					SpicyItemButt: [ 'The tendril invades your ass to extreme depths, it\'s about to--!!' ],
					SpicyItemMouth: [ 'You gag and resist as the tendril thrusts deep into your throat, it\'s about to--!!' ],
					//
					// 'Tame' version
					TameItemVulva: [ 'With rough final thrusts, the tendril pulsates quickly, it\'s about to--!!' ],
					TameItemButt: [ 'The tendril thrusts hard into your ass, it\'s about to--!!' ],
					TameItemMouth: [ 'You gag as the tendril thrusts into your throat, it\'s about to--!!' ],
					//
					// Active narration
					ItemVulva: [ 'With rough final thrusts, the tendril pulsates quickly, it\'s about to--!!' ],
					ItemButt: [ 'The tendril thrusts hard into your ass, it\'s about to--!!' ],
					ItemMouth: [ 'You gag as the tendril thrusts into your throat, it\'s about to--!!' ],
					//
				},
				sp: -0.2,
				dp: 5,
				orgasmBonus: 3
			}],
			[20, {
				taunts: [ '*Satisfied pulsing*', '*Pumping cum*' ],
				narration: {
					// 'Wild' version
					// SpicyItemVulva: [ 'You moan loudly, your belly stretching as your womb is filled with the tendril\'s seed...!' ],
					SpicyItemVulva: [ 'You moan loudly, your womb stretching as you\'re filled with the tendril\'s seed...!' ],
					SpicyItemButt: [ 'Your belly grows round as you\'re filled with tentacle seed...' ],
					SpicyItemMouth: [ 'You helplessly swallow wave after wave of the tendril\'s cum...' ],
					//
					// 'Tame' version
					TameItemVulva: [ 'You moan loudly as your womb is flooded with the tendril\'s seed...!' ],
					TameItemButt: [ 'Your belly grows warm as you\'re filled with tentacle seed...' ],
					TameItemMouth: [ 'You helplessly swallow wave after wave of the tendril\'s cum...' ],
					//
					// Active narration
					ItemVulva: [ 'You moan loudly as your womb is flooded with the tendril\'s seed...!' ],
					ItemButt: [ 'Your belly grows warm as you\'re filled with tentacle seed...' ],
					ItemMouth: [ 'You helplessly swallow wave after wave of the tendril\'s cum...' ],
					//
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
	focusPlayer: true,
	noDisplace: true,
	noswap: true,
	noFlip: true,
	nonHumanoid: true
}

KinkyDungeonEnemies.push(tendril)
RavagerData.Definitions.Enemies.PitTendril = structuredClone(tendril)
// Text keys
addTextKey('NameRavagerTendril', 'Dripping Tentacle')
addTextKey('KillRavagerTendril', 'The tentacle thrashes and vanishes below the ground')
addTextKey('AttackRavagerTendril', '~~{RavagerFrameworkNoMessageDisplay}~~')
// END Ravaging Tendril

// Dedicated event to remove the RavagerTendrils that for some reason get spawned during map generation
KDEventMapGeneric.postMapgen.RFRemovePrespawnedTendrils = function(e, data) {
	// console.log('[Ravager Framework][RFTestTentacle]: e:', e, '; data: ', data, '; Enemies: ', KDNearbyEnemies(0, 0, 10000))
	let tendrils = KDNearbyEnemies(0, 0, 10000).filter(v => v.Enemy.name == "RavagerTendril")
	for (let t of tendrils) {
		RFDebug(`[Ravager Framework][RFRemovePrespawnedTendrils]: Removing pre-spawned tendril (ID: ${t.id})`)
		KDRemoveEntity(t)
	}
}
