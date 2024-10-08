// Working on immobile tentacle pit which summons tendrils to ravage the player

let pit = {
	name: 'TentaclePit',
	faction: 'Plant',
	clusterWith: 'nature',
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
	AI: 'hunt',
	summon: [{
		enemy: 'TentaclePitTendril',
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
	maxhp: 34,
	minLevel: 0,
	weight: 10,
	movePoints: 0,
	attackPoints: 3,
	attack: 'SpellMeleePull',
	attackWidth: 1.5,
	attackMinRange: 1.5,
	attackRange: 10,
	power: 4,
	pullDist: 10,
	pullTowardSelf: true,
	dmgType: 'grope',
	terrainTags: {
		'secondhalf': 16,
		'lastthird': 5,
		'open': 20,
		'passage': -60,
		'increaseWeight': 1
	},
	floors: KDMapInit(['jng', 'cry', 'tmp']),
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

KinkyDungeonEnemies.push(pit)
