let guardRavager = {
	addedByMod: 'RavagerFramework',
	name: 'GuardRavager',
	AI: "guard",
	allFloors: true,
	attack: "MeleeBindLockWillEffect",
	attackLock: "White",
	attackPoints: 3,
	attackRange: 1,
	attackWidth: 1,
	dmgType: "grope",
	dropTable: [{name: "RedKey", weight: 1}],
	focusPlayer: true,
	followRange: 1,
	maxhp: 12,
	minLevel: -1,
	movePoints: 1,
	power: 2,
	RemoteControl: {punishRemote: 3, punishRemoteChance: 0.15},
	stamina: 2,
	tags: KDMapInit([
		"leashing",
		"opendoors",
		"closedoors",
		"antiMagic",
		"miniboss",
		"jail",
		"jailer",
		"melee",
		"shackleRestraints",
		"jailRestraints",
		"guardCall",
		//
		"unflinching",
		"nosub"
	]),
	terrainTags: {"Guard": 1010},
	visionRadius: 6,
	weight: 1,
	// Ravaging
	ravage: {
		targets: [ "ItemVulva", "ItemButt", "ItemButt" ],
		refactory: 50,
		needsEyes: false,
		onomatopoeia: [ "ono 1", "ono 2" ],
		doneTaunts: [ "done 1", "done 2" ],
		fallbackNarration: [ "fallback narr" ],
		restrainChance: 0.2,
		ranges: [
			[
				1,
				{
					taunts: [ "taunt r1" ],
					narration: {
						ItemVulva: [ "vulva r1" ],
						ItemButt: [ "butt r1" ],
						ItemMouth: [ "mouth r1" ]
					},
					sp: -0.1,
					dp: 1,
					orgasmBonus: 0
				}
			],
			[
				5,
				{
					taunts: [ "taunt r5" ],
					narration: {
						ItemVulva: [ "vulva r5" ],
						ItemButt: [ "butt r5" ],
						ItemMouth: [ "mouth r5" ]
					},
					sp: -0.1,
					dp: 1,
					orgasmBonus: 0
				}
			],
			[
				12,
				{
					taunts: [ "taunt r12" ],
					narration: {
						ItemVulva: [ "vulva r12" ],
						ItemButt: [ "butt r12" ],
						ItemMouth: [ "mouth r12" ]
					},
					sp: -0.15,
					dp: 1.5,
					orgasmBonus: 1
				}
			],
			[
				16,
				{
					taunts: [ "taunt r16" ],
					narration: {
						ItemVulva: [ "vulva r16" ],
						ItemButt: [ "butt r16" ],
						ItemMouth: [ "mouth r16" ]
					},
					sp: -0.2,
					dp: 2,
					orgasmBonus: 2
				}
			],
			[
				17,
				{
					taunts: [ "taunt r17" ],
					narration: {
						ItemVulva: [ "vulva r17" ],
						ItemButt: [ "butt r17" ],
						ItemMouth: [ "mouth r17" ]
					},
					sp: -0.2,
					dp: 5,
					orgasmBonus: 3
				}
			],
			[
				20,
				{
					taunts: [ "taunt r20" ],
					narration: {
						ItemVulva: [ "vulva r20" ],
						ItemButt: [ "butt r20" ],
						ItemMouth: [ "mouth r20" ]
					},
					dp: 10,
					wp: -1,
					orgasmBonus: 4,
					sub: 1
				}
			],
		]
	},
	effect: {
		effect: {
			name: "Ravage"
		}
	},
	events: [
		{ trigger: "death", type: "ravagerRemove" },
		{ trigger: "tickAfter", type: "ravagerRefractory" }
	]
}

// let guardRavager = {
// 	addedByMod: "RavagerFramework",
// 	//
//   name: "GuardRavager",
//   // outfit: "Jailer",
//   // style: "Ice",
//   // bound: "Guard",
//   tags: KDMapInit([
//     "leashing",
//     "opendoors",
//     "closedoors",
//     "antiMagic",
//     "miniboss",
//     "jail",
//     "jailer",
//     "melee",
//     "shackleRestraints",
//     "jailRestraints",
//     "guardCall",
//     //
//     "nosub",
//     "unflinching",
//     "handcuffer",
//   ]),
//   // noDisplace: false,
//   // keys: true,
//   followRange: 1,
//   AI: "guard",
//   visionRadius: 6,
//   // disarm: 0.5,
//   maxhp: 12,
//   minLevel: -1,
//   weight:1,
//   movePoints: 1,
//   attackPoints: 3,
//   attack: "MeleeBindLockWill",
//   attackWidth: 1,
//   attackRange: 1,
//   power: 2,
//   dmgType: "grope",
//   // fullBoundBonus: 2,
//   // evasion: -0.5,
//   focusPlayer: true,
//   attackLock: "White",
//   stamina: 2,
//   // maxblock: 1,
//   // maxdodge: 0,
//   RemoteControl: {
//     punishRemote: 3,
//     punishRemoteChance: 0.15,
//   },
//   // events: [
//     // {
//       // trigger: "defeat",
//       // type: "delete",
//       // chance: 1.0
//     // },
//   // ],
//   terrainTags: {
//     "Guard": 1010
//   },
//   allFloors: true,
//   dropTable: [
//     {
//       name: "RedKey",
//       weight: 1
//     }
//   ]
// }

KinkyDungeonEnemies.push(guardRavager)
