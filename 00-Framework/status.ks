window.KDRavaging = { // To keep enemy in one spot while they're busy
  id: "Ravaging", 
  aura: "#aa8888", 
  type: "MoveSpeed", 
  power: -1000.0, 
  player: false, 
  enemies: true, 
  duration: 3,
  noKeep: true,
  alwaysKeep: false,
};
window.KDRavaged = { // To focus the player in on what's happening
  id: "Ravaged", 
  type: "Blindness", 
  duration: 3, 
  power: 7.0, 
  player: true, 
  tags: ["passout"],
  noKeep: true,
  alwaysKeep: false,
}
