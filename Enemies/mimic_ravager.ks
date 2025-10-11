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
      name: "PotionCollar", // might not fit in -- Idea to make a modified version of this collar that either 1) increases distraction when using potions, or 2) is tight enough that choking will increase miscast and accuracy
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
    onomatopoeia: [ "*Excited wriggling*", "CLAP...", "PLAP...", "*Heavy pulsating*" ],
    doneTaunts: [ "*Happy caressing*", "*Satisfied growling*" ],
    fallbackNarration: [ "The Mimic's {tendrils|tentacles} {grope|caress} you roughly! (DamageTaken)", "{Tendrils|Tentacles} {caress|grope} you as they wrap around your body (DamageTaken)" ],
    restrainChance: 0.5,
    ranges: [
      [ 1, {
        taunts: [ "*Preemtive dripping*", "*Wriggling and pulsing*" ],
        narration: {
          ItemVulva: [
            "The mimic rubs {a|its} {{slimy|wet} |}{tendril|tentacle} {into|against} your {slit|pussy}...",
            "A {{slimy|wet} |}{tendril|tentacle} rubs {itself into|against} your {slit|pussy}..."
          ],
          ItemButt: [
            "The mimic probes your butt with a {{slimy|wet} |}{tendril|tentacle}...",
            "The mimic rubs a {{slimy|wet} |}{tendril|tentacle} between your butt cheeks...",
            "{A|The mimic's} {{slimy|wet} |}{tendril|tentacle} {rubs itself between your butt cheeks|probes your butt}..."
          ],
          ItemMouth: [
            "The mimic {pushes|presses} a {{slimy|wet} |}{tendril|tentacle} against your lips...",
            "{A|The mimic's} {{slimy|wet} |}{tendril|tentacle} {{pushes|presses} against your lips|hovers above your face, dripping fluids}..."
          ],
          // ItemHead: [ 'ItemHead 1 1', 'ItemHead 1 2' ],
        }
      } ],
      [ 5, {
        taunts: [ "*Passionate squirming*", "*Wriggling and pulsing*" ],
        narration: {
          TameItemVulva: [
            "The {mimic's |}{tendril|tentacle} {quickly |}{pushes|thrusts} {deep |}into your {slit|pussy}..."
          ],
          TameItemButt: [
            "The mimic{'s {tendril|tentacle} {quickly|harshly|roughly|suddenly} {pushes|shoves|thrusts}| {{quickly|harshly|roughly|suddenly} |}{pushes|shoves|thrusts} its {tendril|tentacle}} into {and stretches |}your ass...",
            "You cry out as the {mimic's |}{thick |}{tendril|tentacle} {{harshly|roughly|suddenly|quickly} |}{shoves into|thrusts in{to|} and stretches} your ass..."
          ], // Expierence aware narration for getting used to anal? (comes to my attention that EAM doesn't have spice capability)
          TameItemMouth: [
            "The mimic {pushes|wiggles} its {tendril|tentacle} past your lips and {into|down} your throat...",
            "You gag as the {mimic's |}{tendril|tentacle} {wiggles between|pushes past} your lips and {into|down} your throat..."
          ],
          // ItemHead: [ 'ItemHead 5 1', 'ItemHead 5 2' ],
          SpicyItemVulva: [
            "The {mimic's |}{thick |}{tendril|tentacle} {shoves|pushes|thrusts} itself into you{r {tight |}pussy|}...",
            "Your pussy stretches around the {mimic's |}{thick |}{tendril|tentacle} {thrusting|pushing|plunging} into you{r {tight |}pussy}...",
            "Your pussy is stretched as the {mimic's |}{thick |}{tendril|tentacle} {thrusts|pushes|plunges} into you{r {tight |}pussy|}...",
            "You {cry out|gasp hard} as the {mimic's |}{thick |}{tendril|tentacle} {thrusts|pushes|plunges} into your {tight |}pussy..."
          ],
          SpicyItemButt: [
            "The {mimic's |}{thick |}{tendril|tentacle} {{quickly|forcefully|roughly|harshly|suddenly} |}{{shoves|pushes} itself|thrusts} deep into your {tight |}ass...",
            "Your ass stretches around the {mimic's |}{thick |}invading {tendril|tentacle}...",
            "You{r ass is forced to stretch| {cry out|gasp hard}} as the {mimic's |}{thick |}{tendril|tentacle} {{quickly|forcefully|roughly|harshly|suddenly} |}{pushes|thrusts|plunges|{forces|shoves} itself} into your {tight |}ass..."
          ],
          SpicyItemMouth: [
            "You gag as the {mimic's |}{tendril|tentacle} {wiggles|pushes} {between|past} your lips and down your throat...",
            "You gag as your throat is filled by the {mimic's |}{tendril|tentacle}...",
            "The mimic's {tendril|tentacle} {pushes|wiggles} past your lips and fills your throat...",
            "Your cries are {cut short|silenced} as the invading {tendril|tentacle} {thrusts|pushes} into {and fills |}your throat..."
          ]
        },
        sp: -0.1,
        dp: 1,
        orgasmBonus: 0
      } ],
      [ 12, {
        taunts: [ "*Rough thrusting*", "*Slow pulsating*" ],
        narration: {
          // ItemVulva: [ "The tendril begins thrusting deeper and harder into your pussy..." ], // Make this one spicy? // Spicy be multiple tendrils?
          ItemVulva: [
            "The mimic {grips|holds} your legs {firmly|tightly} with more {tendrils|tentacles}...",
            "The mimic uses its {tendrils|tentacles} to {grip|hold} your legs{ {firmly|tightly}|}...",
            "More {tendrils|tentacles} emerge {and wrap {tightly |}around|to {firmly |}grip} your legs {while|as} your pussy is pounded..."
          ],
          ItemButt: [
            "The mimic {firmly |}{grips|holds} your waist tightly with more {tendrils|tentacles}...",
            "The mimic uses its {tendrils|tentacles} to {grip|hold} your waist{ firmly|}...",
            "More {tendrils|tentacles} emerge to {firmly |}{hold|grip} your waist while your ass is pounded..."
          ],
          ItemMouth: [
            "The mimic {cradles|holds} your head with another {tendril|tentacle} {while|as} your throat is used...",
            "Another {tendril|tentacle} {{cradles|holds} your head {while|as} your throat is used|emerges to {cradle|hold} your head{ and wrap around your neck|}}..."
          ],
          // ItemHead: [ 'ItemHead 12 1', 'ItemHead 12 2' ],
        },
        sp: -0.15,
        dp: 1.5,
        orgasmBonus: 1
      } ],
      [ 16, {
        taunts: [ "*Rough thrusting*", "*Deep thrusting*" ],
        narration: {
          TameItemVulva: [
            "You {cry out|whimper} with {each|every} thrust, {smothered by {tendril|tentacle}s|{tendril|tentacle}s smothering you}!",
            "The {tendril|tentacle}s {caressing|groping} and invading your body drive out {cries|whimpers} from you!"
          ],
          TameItemButt: [
            "You {whimper pathetically|cry out} with {each|every} {rough|strong|hard|forceful} thrust!",
            "The {tendril|tentacle}'s {rough|strong|hard|forceful} thrusts drive pathetic {whimpers|cries} out of you!"
          ],
          TameItemMouth: [
            "You{r body grows| feel} weak{, choking| as you choke} on the {thick |}{tendril|tentacle} {filling|invading} your throat!"
          ],
          // ItemHead: [ 'ItemHead 16 1', 'ItemHead 16 2' ],
          SpicyItemVulva: [
            "You {cry out|whimper pathetically} {as the {mimic's |}{thick |}{tendril|tentacle} {invades|abuses} your womb with {every|each} thrust|with {each|every} thrust of the {mimic's |}{thick |}{tendril|tentacle} {invading|abusing} your womb}!"
          ],
          SpicyItemButt: [
            "You {cry out|whimper pathetically} with {each|every} thrust of the {thick |}{tendril|tentacle} {{pushing|penatrating} deep inside|invading|abusing} your ass!"
          ],
          SpicyItemMouth: [
            "You {choke and feel weak|try to cry out through your choking} as the {mimic's |}thick {tendril|tentacle} {pushes|thrusts} deeper {down|into} your throat!"
          ]
        },
        sp: -0.2,
        dp: 2,
        orgasmBonus: 2
      } ],
      [ 17, {
        taunts: [ "*Strong pulsating*", "*Pumping cum*" ],
        narration: {
          TameItemVulva: [
            "With {rough|strong} final thrusts, the {mimic's |}{tendril|tentacle} pulsates quickly, it's about to--!!"
          ],
          TameItemButt: [
            "The {mimic's |}{tendril|tentacle} thrusts {hard|forcefully} into your ass, it's about to--!!"
          ],
          TameItemMouth: [
            "You gag and choke as the {mimic's |}{tendril|tentacle} {pushes|thrusts} deep {into|down} your throat, it's about to--!!"
          ],
          // ItemHead: [ 'ItemHead 17 1', 'ItemHead 17 2' ],
          SpicyItemVulva: [
            "With {strong|deeply penatrating} final thrusts{ into your womb|}, the {tendril|tentacle} {begins |}pulsating{ quickly|}, it's about to--!!"
          ],
          SpicyItemButt: [
            "The {mimic's |}{tendril|tentacle} {thrusts very deep into your ass|invades your ass to extreme depths} and {begins pulsating|pulsates quickly}, it's about to--!!"
          ],
          SpicyItemMouth: [
            "You {choke|gag} and {struggle|resist} as the {{tendril|tentacle} thrusts|mimic thrusts its {tendril|tentacle}} {towards your stomach|deep into your throat}, it's about to--!!"
          ]
        },
        sp: -0.2,
        dp: 5,
        orgasmBonus: 3
      } ],
      [ 20, {
        taunts: [ "*Satisfied wriggling*", "*Pumping cum*" ],
        narration: {
          TameItemVulva: [
            "You moan loudly as your womb is {flooded|filled} with the {mimic|tendril|tentacle}'s {cum|seed}...!"
          ],
          TameItemButt: [
            "Your belly grows warm as you're {filled with|pumped full of} the {mimic|tendril|tentacle}'s {cum|seed}...!"
          ],
          TameItemMouth: [
            "You helplessly swallow {wave after wave|copious amounts} of the {mimic|tendril|tentacle}'s {cum|seed}...!"
          ],
          // ItemHead: [ 'ItemHead 20 1', 'ItemHead 20 2' ],
          SpicyItemVulva: [
            "You {moan loudly|cry out}, your womb {stretching|swelling} as you're {filled with|pumped full of} the {mimic|tendril|tentacle}'s {cum|seed}...!"
          ],
          SpicyItemButt: [
            "{You {moan loudly|cry out} and your|Your} belly {grows round|swells out} as you're {filled with|pumped full of} the {mimic|tendril|tentacle}'s {cum|seed}...!"
          ],
          SpicyItemMouth: [
            "You {whimper and gag|gag and choke} as the {mimic|tendril|tentacle} {pumps its {cum|seed} down your throat|{pumps|fills} your throat and stomach with its {cum|seed}}...!"
          ]
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
          "MasterworkBlindfold": 0.001,
          "MasterworkCorset": 0.001,
          "MasterworkHeels": 0.001,
          "MasterworkGloves": 0.001,
          "MasterworkCollar": 0.001
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
          spell?.faction, // Faction -- might not be useful, but we still want Deep, so might as well
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
// Text keys
const text = {
  NameMimicRavager: "Mimic Ravager",
  KillMimicRavager: "The Mimic Ravager spills its moist contents.",
  AttackMimicRavager: "~~{RavagerFrameworkNoMessageDisplay}~~",
  AttackMimicRavagerSlow: "The mimic's tentacles swarm your body and cover you in a thick liquid",
  RavagerFrameworkMimicRavBurst: "Restraints launched from the mimic's body latch themselves to your body!"
}
for (var key in text)
  addTextKey(key, text[key])
// AI fixing event
KDEventMapEnemy.tickAfter.ravagerForceMimicAI = function(e, enemy, data) {
  if (enemy.AI != "ambush") {
    RFDebug(`[Ravager Framework][ravagerForceMimicAI]: ${enemy.Enemy.name} (${enemy.id}) has the wrong AI (${enemy.AI})! Fixing.`)
    enemy.AI = "ambush"
  }
}
