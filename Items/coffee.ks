// Coffee item
KinkyDungeonConsumables.RFCoffee = {
  name: "RFCoffee",
  rarity: 1,
  sfx: "PotionDrink",
  shop: false,
  sneakChance: 0.3,
  type: "restore",
  duration: 40,
  needMouth: true,
  sp_gradual: 25,
  sp_instant: 5,
  scaleWithMaxSP: true,
  wp_gradual: 25,
  wp_instant: 5,
  scalWithMaxWP: true,
  sideEffects: [ "RFUnlockCoffee" ],
}

// Perk entry
KinkyDungeonStatsPresets.RFCoffeeLover = {
  startPriority: 10,
  category: "Boss",
  id: "RFCoffeeLover",
  cost: 1,
  locked: true,
  tags: ["start"],
}

// Perk start function (Run at beginning of a run when perk is chosen)
KDPerkStart.RFCoffeeLover = () => {
  if (!RFAllowFeature("RFCoffeeLover")) {
    RFTrace("[RF][RFCoffeeLover Start] Coffee Lover perk feature not enabled.")
    return
  }
  RFInfo("[RF][RFCoffeeLover Start]: Setting up coffee lover")
  const mi = KinkyDungeonEnemies.findIndex(v => v.name == "MimicRavager")
  const ci = KinkyDungeonEnemies[mi].dropTable.findIndex(v => v.name == "RFCoffee")
  KinkyDungeonEnemies[mi].dropTable[ci].weight *= 2.5
  KinkyDungeonEnemies[mi].dropTable[ci].amountMin *= 2
  KinkyDungeonEnemies[mi].dropTable[ci].amountMax *= 2
}

// Unlock Coffee Lover when drinking coffee the first time
KDConsumableEffects.RFUnlockCoffee = () => {
  if (!RFAllowFeature("RFCoffeeLover")) {
    RFTrace("[RF][Coffee Drinking Event] Coffee Lover perk feature not enabled.")
    return
  }
  if (RavagerData.Variables.CoffeePerkUnlocked) {
    RFTrace("[RF][Coffee Drinking Event] RFCoffeeLover already unlocked.")
    return
  }
  if (RavagerData.Variables.RFControl.BlockCoffeePerkUnlock) {
    RFTrace("[RF][Coffee Drinking Event] RFCoffeeLover blocked.")
    return
  }
  if (RavagerData.Variables.DelayedActions.filter(v => v.id == "CoffeeUnlock").length) {
    RFTrace("[RF][Coffee Drinking Event] RFCoffeeLover unlock already queued.")
    return
  }
  RavagerData.Variables.DelayedActions.push({
    id: "CoffeeUnlock",
    timeout: 1,
    condition: () => KinkyDungeonState == "Game" && KinkyDungeonDrawState == "Game",
    action: () => {
      RFDebug("[RF][Coffee Drinking Unlock] Unlocking Coffee Lover")
      KDUnlockPerk("RFCoffeeLover")
      RavagerData.Variables.CoffeePerkUnlocked = KDUnlockedPerks.includes("RFCoffeeLover")
      if (RavagerData.Variables.CoffeePerkUnlocked)
        KDSendMusicToast(TextGet("KDPerkUnlockedToast") + TextGet("KinkyDungeonStatRFCoffeeLover"))
      else
        return true
    }
  })
}
