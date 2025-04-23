let mimicRavager = {
  addedByMod: 'RavagerFramework',
  name: "MimicRavager",
  blockVisionWhileStationary: true,
  tags: KDMapInit([
    "removeDoorSpawn",
    "ignoreharmless",
    "ignoreharmless",
    "blindresist",
    "construct",
    "nosignal",
    "poisonresist",
    "soulresist",
    "minor",
    "melee",
    "trap",
    "shackleGag",
    "crushweakness",
    "meleeresist",
    "fireweakness",
    "electricresist",
    "chainweakness",
    //
    "nosub",
    "unflinching"
  ]),
  evasion: -0.5,
  ignorechance: 1.0,
  armor: 1,
  followRange: 1,
  AI: "ambush",
  bypass: true,
  difficulty: 0.15,
  guardChance: 0,
  nonDirectional: true,
  useLock: "White",
  GFX: {
    lighting: true,
    AmbushSprite: "Chest",
    // spriteHeight: 144,
    // spriteWidth: 144,
  },
  maxblock: 1,
  maxdodge: 0,
  Sound: {
    baseAmount: 0,
    alertAmount: 0,
    moveAmount: 10,
  },
  stamina: 10,
  visionRadius: 100,
  ambushRadius: 0.1, //1.9,
  blindSight: 100,
  maxhp: 20,
  minLevel:2,
  weight:-1,
  movePoints: 1.5,
  attackPoints: 2,
  attack: "MeleeEffectBlind",
  attackWidth: 1,
  attackRange: 1,
  power: 3,
  dmgType: "grope",
  fullBoundBonus: 1,
  terrainTags: {
    "rubble": 100,
    "adjChest": 15,
    "passage": 14,
    "illusionRage": 2,
    "illusionAnger": 2
  },
  allFloors: true,
  shrines: ["Illusion"],
  dropTable: [
    {
      name: "RedKey",
      weight: 1
    },
    {
      name: "Gold",
      amountMin: 10,
      amountMax: 40,
      weight: 6
    },
    {
      name: "ScrollArms",
      weight: 1
    },
    {
      name: "ScrollVerbal",
      weight: 1
    },
    {
      name: "ScrollLegs",
      weight: 1
    }
  ],
  events: [
    {
      trigger: "tick",
      type: "ravagerBubble",
      image: "Hearts",
      duration: 2,
      chance: 0.2
    },
    {
      trigger: "death",
      type: "ravagerRemove"
    },
    {
      trigger: "tickAfter",
      type: "ravagerRefractory"
    }
  ],
  effect: {
    effect: {
      name: "Ravage"
    }
  },
  noDisplace: true,
  focusPlayer: true,
  ravage: {
    bubbleCondition: 'mimicRavSpoiler', // Condition name that leads to window.RavagerData.conditions.mimicRavSpoiler. This condition is built into the framework, as I'd like to make more mimic ravagers
    targets: [ 'ItemVulva', 'ItemMouth', 'ItemButt', 'ItemHead' ],
    refractory: 20,
    onomatopoeia: [ 'ONO 1', 'ONO 2' ],
    doneTaunts: [ 'DONE 1', 'DONE 2' ],
    // fallbackNarration: [ 'FALLBACK NARRATION' ] // Test default fallback narration?
    restrainChance: 0.5,
    ranges: [
      [ 1, {
        taunts: [ 'TAUNT 1 1', 'TAUNT 1 2' ],
        narration: {
          ItemVulva: [ 'ItemVulva 1 1', 'ItemVulva 1 2' ],
          ItemMouth: [ 'ItemMouth 1 1', 'ItemMouth 1 2' ],
          ItemButt: [ 'ItemButt 1 1', 'ItemButt 1 2' ],
          ItemHead: [ 'ItemHead 1 1', 'ItemHead 1 2' ],
        }
      } ],
    ]
  },
}
KinkyDungeonEnemies.push(mimicRavager)
