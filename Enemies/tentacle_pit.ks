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
	attackPoints: 2,
	attack: 'SpellMeleeWill',
	attackWidth: 2.5,
	attackRange: 2,
	power: 0.1,
	dmgType: 'pain',
	attackLock: 'White',
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
// END Tentacle Pit

// BEGIN Ravaging Tendril
// Completion callback to kill tendril upon ravaging completion
function pitTendrilCompletion(enemy, target, passedOut) {
	RFDebug('[Ravager Framework][Ravager Tendril] Killing tendril')
	enemy.hp = 0;
}
if (!RFAddCallback('pitTendrilCompletion', pitTendrilCompletion)) {
	RFError('[Ravager Framework][Ravager Tendril] Failed to add pitTendrilCompletion!')
}
// Effect callback for groping before ravaging
function pitTendrilEffect(enemy, target) {
	if (enemy.ravage && enemy.ravage.progress == 1 && !enemy.ravage.finishedCarressing) {
		if (Math.random() < enemy.Enemy.ravage.caressChance) {
			RFDebug('[Ravager Framework][Ravager Tendril] Carressing player before ravaging')
			let msg = ''
			switch (enemy.ravage.slot) {
			case 'ItemVulva':
				msg = "TendrilEventVulva"
				break;
			case 'ItemButt':
				msg = "TendrilEventButt"
				break;
			case 'ItemMouth':
				msg = "TendrilEventMouth"
				break;
			default:
				msg = "TendrilEvent"
				break;
			}
			KinkyDungeonSendActionMessage(20, RFGetText(msg), '#ff00ff', 1)
			KinkyDungeonDealDamage({type: 'grope', damage: 0.4})
			return true
		} else {
			RFDebug('[Ravager Framework][RavagerTendril] Finished caressing')
			enemy.ravage.finishedCarressing = true
		}
	}
	return false
}
if (!RFAddCallback('pitTendrilEffectCallback', pitTendrilEffect)) {
	RFError('[Ravager Framework][Ravager Tendril] Failed to add pitTendrilEffectCallback!')
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
	shrines: [], // Tentacle Kraken minion used rope, but wanted to change to a shrine relating to dryads, so TODO: figure out what shrine that is and put here
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
		targets: [ 'ItemVulva', 'ItemButt', 'ItemMouth' ],
		refactory: 5, // Tendril is killed on completion, so this really doesn't matter
		needsEyes: false, // Could try to hypno player to 'addict' them by adding a debuff after a while of not being ravaged by plant; maybe a good use for the ravagerTendrilCum; maybe better done through an aphrodisiac for the plant
		onomatopoeia: "MimicOnomatopoeia",
		doneTaunts: "MimicDoneTaunts",
		fallbackNarration: "MimicFallbackNarration",
		completionCallback: 'pitTendrilCompletion', // Callback to despawn tendril after ravaging, maybe after ravaging twice
		effectCallback: 'pitTendrilEffectCallback', // Callback to allow the tendril to caress the player (fallback style) for a bit before using her
		ranges: [
			[1, {
				taunts: "MimicR1Taunts",
				narration: {
					ItemVulva: "MimicR1Vulva",
					ItemButt: "MimicR1Butt",
					ItemMouth: "MimicR1Mouth",
				}
			}],
			[5, {
				taunts: "MimicR5Taunts",
				narration: {
					// 'Wild' version
					SpicyItemVulva: "MimicR5VulvaSpicy",
					SpicyItemButt: "MimicR5ButtSpicy",
					SpicyItemMouth: "MimicR5MouthSpicy",
					// 'Tame' version
					TameItemVulva: "MimicR5VulvaTame",
					TameItemButt: "MimicR5ButtTame",
					TameItemMouth: "MimicR5MouthTame"
				},
				sp: -0.1,
				dp: 1,
				orgasmBonus: 0
			}],
			[12, {
				taunts: "MimicR12Taunts",
				narration: {
					// 'Wild' version
					SpicyItemButt: "MimicR12ButtSpicy",
					// 'Tame' version
					TameItemButt: "MimicR12ButtTame",
					// Active narration
					ItemVulva: "MimicR12Vulva",
					ItemMouth: "MimicR12Mouth",
				},
				sp: -0.15,
				dp: 1.5,
				orgasmBonus: 1
			}],
			[16, {
				taunts: "MimicR16Taunts",
				narration: {
					// 'Wild' version
					SpicyItemVulva: "MimicR16VulvaSpicy",
					SpicyItemButt: "MimicR16ButtSpicy",
					SpicyItemMouth: "MimicR16MouthSpicy",
					// 'Tame' version
					TameItemVulva: "MimicR16VulvaTame",
					TameItemButt: "MimicR16ButtTame",
					TameItemMouth: "MimicR16MouthTame"
				},
				sp: -0.2,
				dp: 2,
				orgasmBonus: 2
			}],
			[17, {
				taunts: "MimicR17Taunts",
				narration: {
					// 'Wild' version
					SpicyItemVulva: "MimicR17VulvaSpicy",
					SpicyItemButt: "MimicR17ButtSpicy",
					SpicyItemMouth: "MimicR17MouthSpicy",
					// 'Tame' version
					TameItemVulva: "MimicR17VulvaTame",
					TameItemButt: "MimicR17ButtTame",
					TameItemMouth: "MimicR17MouthTame"
				},
				sp: -0.2,
				dp: 5,
				orgasmBonus: 3
			}],
			[20, {
				taunts: "MimicR20Taunts",
				narration: {
					// 'Wild' version
					SpicyItemVulva: "MimicR20VulvaSpicy",
					SpicyItemButt: "MimicR20ButtSpicy",
					// 'Tame' version
					TameItemVulva: "MimicR20VulvaTame",
					TameItemButt: "MimicR20ButtTame",
					// Active narration
					ItemMouth: "MimicR20Mouth",
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
// END Ravaging Tendril
// Dedicated event to remove the RavagerTendrils that for some reason get spawned during map generation
KDEventMapGeneric.postMapgen.RFRemovePrespawnedTendrils = function(e, data) {
	let tendrils = KDNearbyEnemies(0, 0, 10000).filter(v => v.Enemy.name == "RavagerTendril")
	for (let t of tendrils) {
		RFDebug(`[Ravager Framework][RFRemovePrespawnedTendrils]: Removing pre-spawned tendril (ID: ${t.id})`)
		KDRemoveEntity(t)
	}
}
