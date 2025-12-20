// Restraint definitions
KinkyDungeonStruggleGroupsBase.push("ItemRavage")
KinkyDungeonRestraints.push(
  {
    name: "Pinned", 
    immobile: true, 
    Color: "#333333", 
    Group: "ItemRavage",
    bindarms: true,
    bindhands: true,
    blockfeet: true,
    power: 0.1,
    weight: 20, 
    alwaysStruggleable: true,
    alwaysEscapable: ["Struggle"],
    escapeChance: {"Struggle": -0.1, "Remove": 0.2, "Cut": 0.75},
    struggleMinSpeed: {"Struggle": 0.2},
    playerTags: {"ItemArmsFull":2},
    enemyTags: {},
    minLevel: 0, 
    allFloors: true, 
    removeOnLeash:false,
    removeOnPrison:true,
    shrine: [],
    events: [
      {trigger: "tick", type: "sneakBuff", power: -1},
      {trigger: "tick", type: "evasionBuff", power: -1000},
      {trigger: "tick", type: "blockBuff", power: -100},
      {trigger: "tickAfter", type: "ravagerNarration", power: -100},
      {trigger: "tickAfter", type: "ravagerPinCheck", power: -100},
      {trigger: "passout", type: "ravagerRemove", power: -100},
      {trigger: "remove", type: "ravagerRemove", power: -100},
      { trigger: "tickAfter", type: "ravagerSitDownAndShutUp" }
    ],
    failSuffix: {"Remove": "RavagerPinned", "Struggle": "RavagerPinned", "Cut": "RavagerPinned"},
    customEquip: 'RavagerPinned',
    customEscapeSucc: 'RavagerPinned'
  },
  // This is really just to remove panties
  {
    name: "Stripped", 
    Color: "#333333", 
    Group: "ItemPelvis", 
    specStruggleTypes: ["Remove"],
    power: 8, 
    weight: 2, 
    escapeChance: {"Remove": 2, 'Struggle': 2},
    playerTags: {"ItemArmsFull":6},
    addTag: ["stripped"],
    enemyTags: {},
    minLevel: 0, 
    allFloors: true, 
    removeOnLeash:false,
    removeOnPrison:false,
    shrine: [],
    events: [],
    failSuffix: {'Remove': 'RavagerStripped', 'Struggle': 'RavagerStripped'},
    customEquip: 'RavagerStripped',
    customEscapeSucc: 'RavagerStripped'
  },
  // Definitions for the "occupied" slots to stop other ravagers from interrupting
  // These are removed by breaking Pinned, and they're just a mechanic, so they can't be struggled out of.
  {
    name: "RavagerOccupiedMouth", 
    Color: "#333333", 
    Group: "ItemMouth",
    power: 99, 
    weight: 0, 
    specStruggleTypes: ["Struggle"], escapeChance: {"Struggle": -99, "Cut": -99, "Remove": -99},
    playerTags: {"ItemMouthFull": 6},
    enemyTags: {},
    shrine: [],
    minLevel: 0, 
    allFloors: true, 
    removeOnLeash:false,
    removeOnPrison:true,
    bypass: true,
    gag: 1,
    events: [
      {trigger: "tick", type: "ravagerCheckForPinned", power: -1},
    ],
    failSuffix: {"Remove": "RavagerOccupied", "Struggle": "RavagerOccupied", "Cut": "RavagerOccupied"},
    customEquip: 'RavagerOccupied',
    Model: "GhostGag"
  },
  {
    name: "RavagerOccupiedHead", 
    Color: "#333333", 
    Group: "ItemHead",
    power: 99, 
    weight: 0, 
    specStruggleTypes: ["Struggle"], escapeChance: {"Struggle": -99, "Cut": -99, "Remove": -99},
    playerTags: {"ItemMouthFull": 6}, // TODO: Decide if this makes sense to use; may not make sense if head would be used for a form of hypnosis
    enemyTags: {},
    shrine: [],
    minLevel: 0, 
    allFloors: true, 
    removeOnLeash:false,
    removeOnPrison:true,
    bypass: true,
    events: [
      {trigger: "tick", type: "ravagerCheckForPinned", power: -1},
    ],
    failSuffix: {"Remove": "RavagerOccupied", "Struggle": "RavagerOccupied", "Cut": "RavagerOccupied"},
    customEquip: 'RavagerOccupied'
  },
  {
    name: "RavagerOccupiedVulva", 
    Color: "#333333", 
    Group: "ItemVulva",
    power: 99, 
    weight: 0, 
    specStruggleTypes: ["Struggle"], escapeChance: {"Struggle": -99, "Cut": -99, "Remove": -99},
    playerTags: {},
    enemyTags: {},
    shrine: [],
    minLevel: 0, 
    allFloors: true, 
    removeOnLeash:false,
    removeOnPrison:true,
    bypass: true,
    events: [
      {trigger: "tick", type: "ravagerCheckForPinned", power: -1},
    ],
    failSuffix: {"Remove": "RavagerOccupied", "Struggle": "RavagerOccupied", "Cut": "RavagerOccupied"},
    customEquip: 'RavagerOccupied',
    Model: "RavLiftedSkirt"
  },
  {
    name: "RavagerOccupiedButt", 
    Color: "#333333", 
    Group: "ItemButt",
    power: 99, 
    weight: 0, 
    specStruggleTypes: ["Struggle"], escapeChance: {"Struggle": -99, "Cut": -99, "Remove": -99},
    playerTags: {},
    enemyTags: {},
    shrine: [],
    minLevel: 0, 
    allFloors: true, 
    removeOnLeash:false,
    removeOnPrison:true,
    bypass: true,
    events: [
      {trigger: "tick", type: "ravagerCheckForPinned", power: -1},
    ],
    failSuffix: {"Remove": "RavagerOccupied", "Struggle": "RavagerOccupied", "Cut": "RavagerOccupied"},
    customEquip: 'RavagerOccupied',
    Model: "RavLiftedSkirt"
  },
)

// Global "restraints"
KinkyDungeonAddRestraintText('Stripped', 'Stripped!', 'Your panties got torn away...', 'You can just put them back on, but maybe don\'t worry about that if you\'re currently pinned down...');
KinkyDungeonAddRestraintText('Pinned', 'Pinned!', 'Something or someone is having their way with you.', 'You can\'t move unless you get them off you! Freeing yourself will stun nearby enemies.');

// These all use the same descriptor, suggesting you fight Pinned instead.
let slotsArr = ['Mouth', 'Vulva', 'Butt']
for (var i in slotsArr) {
  KinkyDungeonAddRestraintText('RavagerOccupied' + slotsArr[i], 'Occupied!', 'Someone or something is having their way with you...', 'Don\'t worry about this restraint. Instead, try to escape "Pinned!"');
}

KinkyDungeonAddRestraintText('RavagerOccupiedHead', 'Gripped!', 'Someone or something is having their way with you...', 'Don\'t worry about this restraint. Instead, try to escape "Pinned!"');
