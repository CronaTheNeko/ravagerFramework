let mimicRavager = {
  addedByMod: 'RavagerFramework',
  RFDisableRefvar: "ravagerDisableMimic",
  name: "MimicRavager",
  blockVisionWhileStationary: true,
  tags: KDMapInit([
    "removeDoorSpawn",
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
    "unflinching",
    "ropeRestraints",
    "ropeRestraints2",
    "nosignalothers",
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
    AmbushSprite: "Chest"
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
  ambushRadius: 1.5,
  blindSight: 100,
  maxhp: 20,
  minLevel:2,
  weight: 8,
  movePoints: 0.1,
  attackPoints: 2,
  attack: "MeleeEffectSlow",
  attackWidth: 1,
  attackRange: 1,
  power: 3,
  dmgType: "grope",
  fullBoundBonus: 1,
  hitsfx: "Grab",
  terrainTags: {
    "rubble": 100,
    "adjChest": 15,
    "passage": 14,
    "illusionRage": 2,
    "illusionAnger": 2
  },
  allFloors: true,
  shrines: ["Illusion"],
  maxDrops: 5, // Enables multiple item drops on enemy death; Note: when set to zero, vanilla item drop behvior will be used
  // minDrops: 1, // Set this to a number less than or equal to maxDrops to define the minimum item drops
  // ravagerCustomDrop: true, // Set to true to enable multi-item drops behavior for non-RavagerFramework enemies
  dropTable: [
    {
      name: "RedKey",
      amountMin: 1,
      amountMax: 5,
      weight: 1.7,
    },
    {
      name: "Gold",
      amountMin: 10,
      amountMax: 40,
      weight: 6,
    },
    {
      name: "ScrollArms",
      amountMin: 1,
      amountMax: 2,
      weight: 1.2,
    },
    {
      name: "ScrollVerbal",
      amountMin: 1,
      amountMax: 2,
      weight: 1.2,
    },
    {
      name: "ScrollLegs",
      amountMin: 1,
      amountMax: 2,
      weight: 1.2,
    },
    {
      name: "ManaOrb",
      amount: 1,
      weight: 1.1
    },
    {
      name: "WaterRune",
      amountMin: 1,
      amountMax: 2,
      weight: 1
    },
    {
      name: "ElfCrystal",
      amountMin: 1,
      amountMax: 3,
      weight: 1
    },
    {
      name: "AncientPowerSource",
      amountMin: 1,
      amountMax: 2,
      weight: 0.9
    },
    {
      name: "ScrollPurity",
      amountMin: 1,
      amountMax: 2,
      weight: 1.1
    },
    {
      name: "Pick",
      amountMin: 1,
      amountMax: 10,
      weight: 1.5
    },
    {
      name: "BlueKey",
      weight: 0.4 // For runic locks, need to make it rare
    },
    {
      name: "SackOfSacks",
      amountMin: 1,
      amountMax: 3,
      weight: 1.3
    },
    {
      name: "UniversalSolvent",
      weight: 1
    },
    {
      name: "NaughtyCookie",
      amountMin: 1,
      amountMax: 4,
      weight: 1
    },
    {
      name: "RavagedCookie",
      amountMin: 1,
      amountMax: 4,
      weight: 1
    },
    {
      name: "SlimeWalkers",
      weight: 0.7
    },
    {
      name: "PotionCollar", // Might not fit in -- Idea to make a modified version of this collar that either 1) increases distraction when using potions, or 2) is tight enough that choking will increase miscast and accuracy
      weight: 0.5
    },
    {
      name: "Swimsuit",
      weight: 0.9
    },
    {
      name: "SwimsuitMimic",
      weight: 1.1
    },
    {
      name: "Breastplate",
      weight: 0.9
    },
    {
      name: "BreastplateShibari",
      weight: 1.1
    },
    {
      name: "Bustier",
      weight: 0.9
    },
    {
      name: "BustierShibari",
      weight: 1.1
    },
    {
      name: "ChainTunic",
      weight: 0.9
    },
    {
      name: "ChainTunicShibari",
      weight: 1.1
    },
    {
      name: "ChainTunicSkimpy",
      weight: 1
    },
    {
      name: "ChainBikini",
      weight: 0.9
    },
    {
      name: "ChainBikiniShibari",
      weight: 1.1
    },
    {
      name: "Bracers",
      weight: 0.9
    },
    {
      name: "BracersShibari",
      weight: 1.1
    },
    {
      name: "LeatherGloves",
      weight: 0.9
    },
    {
      name: "LeatherGlovesMimic",
      weight: 1.1
    },
    {
      name: "Gauntlets",
      weight: 0.9
    },
    {
      name: "GauntletsMimic",
      weight: 1.1
    },
    {
      name: "SteelBoots",
      weight: 0.9
    },
    {
      name: "SteelBootsMimic",
      weight: 1.1
    },
    {
      name: "LeatherBoots",
      weight: 0.9
    },
    {
      name: "LeatherBootsMimic",
      weight: 1.1
    },
    {
      name: "SteelSkirt2",
      weight: 0.9
    },
    {
      name: "SteelSkirt2Skimpy",
      weight: 1.1
    },
    {
      name: "SteelArmor",
      weight: 0.9
    },
    {
      name: "SteelArmorShibari",
      weight: 1.1
    },
    {
      name: "SteelSkirt",
      weight: 0.9
    },
    {
      name: "SteelSkirtShibari",
      weight: 1.1
    },
    {
      name: "SteelSkirtSkimpy",
      weight: 1
    },
    {
      name: "MageArmor",
      weight: 0.9
    },
    {
      name: "MageArmorShibari",
      weight: 1.1
    },
    {
      name: "Cape",
      weight: 0.9
    },
    {
      name: "CapeShibari",
      weight: 1.1
    },
    {
      name: "MagicArmbands",
      weight: 0.9
    },
    {
      name: "MagicArmbandsMimic",
      weight: 1.1
    },
    {
      name: "SlimeSword",
      weight: 1
    },
    {
      name: "Dirk",
      weight: 1
    },
    {
      name: "BagOfGoodies",
      weight: 1
    },
    {
      name: "VibeRemote",
      weight: 1
    },
    {
      name: "DildoBatPlus", // Check where this normally drops from to see if it fits in
      weight: 0.65
    },
    {
      name: "StaffGlue",
      weight: 1
    },
  ],
  ondeath: [
    {
      type: "spellOnSelf",
      spell: "MimicRavBurst"
    }
  ],
  events: [
    {
      trigger: "tick",
      type: "ravagerBubble",
      image: "Hearts",
      duration: 2,
      chance: 0.02
    },
    {
      trigger: "tickAfter",
      type: "ravagerForceMimicAI"
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
  noswap: true,
  focusPlayer: true,
  ravage: {
    bubbleCondition: "mimicRavSpoiler", // Condition name that leads to window.RavagerData.conditions.mimicRavSpoiler. This condition is built into the framework, as I'd like to make more mimic ravagers
    targets: [ "ItemVulva", "ItemMouth", "ItemButt" ], // Disabled head until I figure out what to make of it //, "ItemHead" ], // Will need to test ItemHead, as I'd like to use it for either hypnosis or some form of tentacle engulfing the head
    refractory: 20,
    onomatopoeia: "MimicOnomatopoeia",
    doneTaunts: "MimicDoneTaunt",
    fallbackNarration: "MimicFallbackNarration",
    restrainChance: 0.5,
    ranges: [
      [ 1, {
        taunts: "MimicR1Taunts",
        narration: {
          ItemVulva: "MimicR1Vulva",
          ItemButt: "MimicR1Butt",
          ItemMouth: "MimicR1Mouth",
        }
      } ],
      [ 5, {
        taunts: "MimicR5Taunts",
        narration: {
          TameItemVulva: "MimicR5VulvaTame",
          TameItemButt: "MimicR5ButtTame", // Expierence aware narration for getting used to anal? (comes to my attention that EAM doesn't have spice capability)
          TameItemMouth: "MimicR5MouthTame",
          SpicyItemVulva: "MimicR5VulvaSpicy",
          SpicyItemButt: "MimicR5ButtSpicy",
          SpicyItemMouth: "MimicR5MouthSpicy"
        },
        sp: -0.1,
        dp: 1,
        orgasmBonus: 0
      } ],
      [ 12, {
        taunts: "MimicR12Taunts",
        narration: {
          ItemVulva: "MimicR12Vulva",
          ItemButt: "MimicR12Butt",
          ItemMouth: "MimicR12Mouth",
        },
        sp: -0.15,
        dp: 1.5,
        orgasmBonus: 1
      } ],
      [ 16, {
        taunts: "MimicR16Taunts",
        narration: {
          TameItemVulva: "MimicR16VulvaTame",
          TameItemButt: "MimicR16ButtTame",
          TameItemMouth: "MimicR16MouthTame",
          SpicyItemVulva: "MimicR16VulvaSpicy",
          SpicyItemButt: "MimicR16ButtSpicy",
          SpicyItemMouth: "MimicR16MouthSpicy"
        },
        sp: -0.2,
        dp: 2,
        orgasmBonus: 2
      } ],
      [ 17, {
        taunts: "MimicR17Taunts",
        narration: {
          TameItemVulva: "MimicR17VulvaTame",
          TameItemButt: "MimicR17ButtTame",
          TameItemMouth: "MimicR17MouthTame",
          SpicyItemVulva: "MimicR17VulvaSpicy",
          SpicyItemButt: "MimicR17ButtSpicy",
          SpicyItemMouth: "MimicR17MouthSpicy"
        },
        sp: -0.2,
        dp: 5,
        orgasmBonus: 3
      } ],
      [ 20, {
        taunts: "MimicR20Taunts",
        narration: {
          TameItemVulva: "MimicR20VulvaTame",
          TameItemButt: "MimicR20ButtTame",
          TameItemMouth: "MimicR20MouthTame",
          SpicyItemVulva: "MimicR20VulvaSpicy",
          SpicyItemButt: "MimicR20ButtSpicy",
          SpicyItemMouth: "MimicR20MouthSpicy"
        },
        dp: 10,
        wp: -1,
        orgasmBonus: 4,
        sub: 1
      } ],
    ]
  },
  noFlip: true,
  nonHumanoid: true,
  noLeash: true,
}
RavagerData.Definitions.Enemies.MimicRavager = structuredClone(mimicRavager)
KinkyDungeonEnemies.push(mimicRavager)
// On-death spell
const spell = {
  name: "MimicRavBurst",
  enemySpell: true,
  faction: "Trap",
  sfx: "Struggle",
  manacost: 4,
  components: [],
  level:1,
  type:"inert",
  onhit:"aoe",
  passthrough: true,
  noTerrainHit: true,
  time: 5,
  delay: 1,
  power: 2,
  range: 2,
  size: 3,
  aoe: 1.5,
  lifetime: 1,
  damage: "chain",
  playerEffect: {
    name: "MimicRavBindings",
    realBind: true,
    text: "RavagerFrameworkMimicRavBurst",
    tags: [
      "scarfRestraints",
      "ropeAuxiliary",
      "sensedep",
      "latexEncase",
      "jailRestraints",
      "latexStart",
      "latexgagSpell",
      "mittensSpell",
      "masterworkRestraints",
      "leatherRestraintsHeavy",
      "ballGagRestraints",
      "trap",
      "yokeSpell",
      "harnessSpell",
      // "machineChastity", // Will reintroduce when I get ravagers re-applying chastity after use
      // "genericChastity", // Will reintroduce when I get ravagers re-applying chastity after use
      "blacksteelRestraints",
      "steelRestraints",
      "obsidianRestraints",
      // "maidChastityBelt", // Might reintroduce with other chastity, but questionable if maid fits in
      "leatherGags",
      "handcuffer",
      "shackleRestraints",
      "shackleGag",
      "banditMagicRestraints",
      "ropeRestraints",
      "ropeRestraintsNonbind",
      "ropeRestraintsWrist",
      "ropeRestraintsHogtie",
      "chainRestraints"
    ],
    power: 6,
    count: 2
  }
}
RavagerData.Definitions.Spells.MimicRavBurst = structuredClone(spell)
KinkyDungeonSpellListEnemies.push(spell)

const playerEffect = (_target, damage, playerEffect, spell, faction, bullet, _entity, xtra1, xtra2) => {
  let effect = false;
  if (KDTestSpellHits(spell, 0.5, 0.5)) {
    let dmg = KinkyDungeonDealDamage({damage: playerEffect?.power || spell?.power || 1, type: playerEffect?.damage || spell?.damage || damage,}, bullet);
    if (!dmg.happened)
      return { sfx: "Shield", effect: false }; 
    let added = [];
    for (let i = 0; i < playerEffect.count; i++) {
      let restraintAdd = RFGetRestraint(
        { tags: playerEffect.tags },
        KDGetEffLevel() + spell.power,
        KDCurrIndex(),
        [
          "TrapBelt",
          "BlacksteelBelt",
          "SteelBelt",
          "TrapVibe",
          "TrapPlug",
          "TrapPlug2",
          "TrapPlug3",
          "TrapPlug4",
          "TrapPlug5"
        ],
        {
          "MasterworkBlindfold": 1e-4,
          "MasterworkCorset": 1e-4,
          "MasterworkHeels": 1e-4,
          "MasterworkGloves": 1e-4,
          "MasterworkCollar": 2e-6
        }
      ) // Don't really like the feel of insertions // Also excluding chastity until I figure out re-applying them after use // Also modifying the chances for the Masterwork set, as they're being chosen more often than I want
      if (restraintAdd) {
        let returned = KinkyDungeonAddRestraintIfWeaker(
          restraintAdd, // restraint
          spell?.power || 0, // Tightness
          KinkyDungeonStatsChoice.has("MagicHands") || spell, // Bypass
          restraintAdd.DefaultLock, // Lock
          undefined,
          undefined,
          undefined,
          spell?.faction, // Faction -- might not be useful
          KinkyDungeonStatsChoice.has("MagicHands") ? true : undefined, // Deep
          undefined,
          undefined,
          true // useAugmentedPower -- not sure what this is for
        )
        if (returned) {
          added.push(restraintAdd);
          effect = true;
        }
      }
    }
    if (added.length > 0) {
      KinkyDungeonSendTextMessage(6, TextGet(playerEffect.text).KDReplaceOrAddDmg( dmg.string), KDBaseRed, 2);
      effect = true;
    } else {
      let PossibleDresses = RavagerData.Variables.MimicBurstPossibleDress
      if (!PossibleDresses.includes(KinkyDungeonCurrentDress) && !KinkyDungeonStatsChoice.get("KeepOutfit")) {
        KinkyDungeonSetDress(PossibleDresses[Math.floor(Math.random() * PossibleDresses.length)], "");
        KinkyDungeonDressPlayer();
        KinkyDungeonSendTextMessage(3, TextGet("KinkyDungeonTrapBindingsDress").KDReplaceOrAddDmg( dmg.string), KDBaseRed, 3);
        effect = true;
      }
    }
    return { sfx: "", effect: effect };
  }
  return { sfx: "Miss", effect: effect };
}
KDPlayerEffects["MimicRavBindings"] = playerEffect
// AI fixing event
KDEventMapEnemy.tickAfter.ravagerForceMimicAI = function(e, enemy, data) {
  if (enemy.AI != "ambush") {
    RFDebug(`[Ravager Framework][ravagerForceMimicAI]: ${enemy.Enemy.name} (${enemy.id}) has the wrong AI (${enemy.AI})! Fixing.`)
    enemy.AI = "ambush"
  }
}
