// Function to get a mod setting value
// If settings are undefined, it'll return the default value given to KDModConfigs
// If there is not matching value given to KDModConfigs, it'll return undefined
window.RavagerGetSetting = function(refvar) {
  if (refvar == "ravagerDebug" && _RavagerFrameworkDebugEnabled)
    return true
  // Mod settings and default config objects
  const settings = KDModSettings.RavagerFramework
  var config = RavagerData.ModConfig[refvar]
  // Helper for getting default value
  function RFConfigDefault(refvar, config) {
    // Check for missing default values; signals either a data structure change or (dev) failure to declare default values
    if (config == undefined) {
      RFError('[Ravager Framework]: RavagerGetSetting couldn\'t find ModConfig values for ' + refvar + ' !')
      return undefined
    }
    return config.default
  }
  // Helper for checking localStorage, incase the user has set mod settings previously but we're currently in mod initialization, where mod settings aren't available
  function RFConfigCheckLocalStorage(refvar, config) {
    // Chain to get the previous setting for the refvar we're looking for
    if (localStorage.hasOwnProperty('KDModSettings')) {
      const savedSettings = JSON.parse(localStorage.KDModSettings)
      if (savedSettings.hasOwnProperty('RavagerFramework') && savedSettings.RavagerFramework[refvar] != undefined) {
        return savedSettings.RavagerFramework[refvar]
      }
    }
    // Default to returning the default value in ModConfig
    return RFConfigDefault(refvar, config)
  }
  // No settings, return default; probably should never happen, but I believe I've seen it in the past when there's no localData
  if (!settings) {
    if (!_RavagerFrameworkInInit)
      RFWarn('[Ravager Framework]: RavagerGetSetting couldn\'t get current settings for the framework!')
    return RFConfigCheckLocalStorage(refvar, config)
  }
  // Requested setting isn't set, return default
  if (settings[refvar] == undefined) {
    if (!_RavagerFrameworkInInit)
      RFWarn('[Ravager Framework]: RavagerGetSetting couldn\'t get the current setting for ' + refvar)
    return RFConfigCheckLocalStorage(refvar, config)
  }
  // Return setting
  return settings[refvar]
}

// Helper for pushing to debug log buffer
window.RavagerFrameworkPushToLogBuffer = function(msg, level = "INFO") {
  // Check if we actually want to add logs to a potential log file (assuming yes during initialization)
  if (RavagerData.Variables.IWantToHelpDebug || _RavagerFrameworkInInit) {
    // A structured log line, with extra info so we can know when it happened while reading a log after the events
    let logLine = {
      level: level,
      gameState: {
        currentTick: KinkyDungeonCurrentTick,
        state: KinkyDungeonState, // State tracks things like Menu, NewGame, Wardrobe, Game
        drawState: KinkyDungeonDrawState // DrawState tracks the state within Game
      },
      callStack: undefined,
      msg: structuredClone(msg)
    }
    // Build a string to track the call stack
    // - Start by getting call stack by creating an error
    let stack_str_base = new Error().stack.replace("Error\n", "").replaceAll("    at ", "")
    // - Will be our final call stack string
    let stack_str = ""
    // - Each function in the call stack is on its own line; trim each line to the function name and add to our final string
    stack_str_base.split("\n").forEach(v => {
      v = v.trim()
      // Only add the current function call to the call stack if it's not one of the console message wrappers and not this function
      if (!v.match(/window\.(RF(Error|Warn|Info|Debug|Trace)|RavagerFrameworkPushToLogBuffer)/))
        stack_str += v.split(" ")[0] + " <= "
    })
    // - Save our call stack, but remove the trailing " <= " from it
    logLine.callStack = stack_str.substr(0, stack_str.length - 4)
    // Push this log line to our buffer
    RavagerData.Variables.IWantToHelpDebugBuffer.push(logLine)
  }
}

// Hidden option to enable way too many console messages
window.RavagerFrameworkToggleDebug = function(enable = false) {
  if (!_RavagerFrameworkDebugEnabled || enable) {
    RFDebug('[Ravager Framework] Serious debug mode enabled. Hope you like lots of text and variables!')
    _RavagerFrameworkDebugEnabled = true
  } else {
    RFDebug('[Ravager Framework] Serious debug mode disabled.')
    _RavagerFrameworkDebugEnabled = false
  }
  localStorage.RavagerFrameworkTraceMessages = _RavagerFrameworkDebugEnabled
}

// Hopeful fallback incase function signatures change -- I have no idea how this would interact with other mods that wind up overriding our overrides. Do they end up calling the original function or our leftover (possibly non-functional) override function?
window.RavagerFrameworkRevertFunctions = function() {
  const functions = Object.keys(RavagerData.functions).filter(s => s.match(/(KinkyDungeo.*|.*KD.*)/))
  for (let f of functions) {
    RFDebug(`Reverting ${f} ...`)
    window[f] = RavagerData.functions[f]
  }
  // Hopefully good enough to work around the weirdness that these variables were created to handle, but can't do the full 'for sure' method used before, as at this point we've already removed our custom KinkyDungeonRun. These variables are then garbage, but the game would have to be reloaded before they're ever used again
  KinkyDungeonState = RavagerData.Variables.PrevState
  KinkyDungeonState = RavagerData.Variables.PrevState
  KinkyDungeonDrawState = RavagerData.Variables.PrevDrawState
  KinkyDungeonDrawState = RavagerData.Variables.PrevDrawState
}

// Enable heavy debugging from modconfig
window.RavagerFrameworkIWantToHelpDebug = function(reason) {
  if (RavagerGetSetting("ravagerHelpDebug")) {
    // Set my own variables to track debugging
    RavagerData.Variables.IWantToHelpDebug = true
    RavagerFrameworkToggleDebug(true)
    KDModSettings.RavagerFramework.ravagerDebug = true
    // Reset ravagerHelpDebug in localStorage, as we don't want this to be persistent
    let j = JSON.parse(localStorage.KDModSettings)
    j.RavagerFramework.ravagerHelpDebug = false
    localStorage.KDModSettings = JSON.stringify(j)
  } else if (RavagerData.Variables.IWantToHelpDebug) {
    // Disable help debugging mode in variable
    RFDebug("[Ravager Framework][RavagerFrameworkIWantToHelpDebug]: Disabling debug logging and saving the log")
    RavagerData.Variables.IWantToHelpDebug = false
    // Save version info log
    let logLine = {
      level: "VER",
      KD: TextGet("KDVersionStr"),
      RF: RavagerData.ModInfo.modbuild
    }
    RavagerData.Variables.IWantToHelpDebugBuffer = [ logLine, ...RavagerData.Variables.IWantToHelpDebugBuffer ]
    // Save the buffer to a file
    const element = document.createElement("a");
    const now = new Date()
    element.setAttribute("href", window.URL.createObjectURL(new Blob([LZString.compressToBase64(JSON.stringify(RavagerData.Variables.IWantToHelpDebugBuffer))], { type: "text/plain" })))
    element.setAttribute("download", `RavagerDebug_${now.getFullYear()}_${String(now.getMonth() + 1).padStart(2, "0")}_${String(now.getDate()).padStart(2, "0")}-${Intl.DateTimeFormat("en-US", { hour12: false, hour: "2-digit", minute: "2-digit", second: "2-digit" }).format(now)}.txt`); // Disgusting chain
    element.click()
  }
}

// Load or unload custom font
window.RavagerFrameworkRefreshFonts = function(reason) {
  for (let font_data in RavagerData.Definitions.Fonts) {
    let font = structuredClone(RavagerData.Definitions.Fonts[font_data])
    // If the font isn't already loaded, create a new FontFace object and store it globally, as we need to use the same object to unload a font we previously loaded
    if (!RavagerData.Definitions.FontFaces.hasOwnProperty(font.alias)) {
      font.src = KDModFiles[font.src]
      RavagerData.Definitions.FontFaces[font.alias] = new FontFace(font.alias, `url(${font.src})`)
    }
    let font_face = RavagerData.Definitions.FontFaces[font.alias]
    if (RavagerGetSetting("ravagerFancyFont")) {
      // Loads the font
      if (!document.fonts.has(font_face)) {
        document.fonts.add(font_face)
        font_face.load().then(() => { RFDebug(`[Ravager Framework] Loaded font "${font.alias}"`) })
      }
    } else {
      // Unloads the font
      if (document.fonts.has(font_face)) {
        document.fonts.delete(font_face)
        RFDebug(`[Ravager Framework] Removed font "${font.alias}"`)
      }
    }
  }
}

// Base settings function, simplifying reloading settings
window.RavagerFrameworkSettingsRefresh = function(reason) {
  RFInfo('[Ravager Framework] Running settings functions for reason: ' + reason)
  RavagerFrameworkRefreshEnemies(reason)
  RavagerFrameworkApplySomeSpice(reason)
  RavagerFrameworkApplySlimeRestrictChance(reason)
  RefreshRavagerDataVariables(reason)
  RavagerFrameworkRefreshFonts(reason)
  RavagerFrameworkIWantToHelpDebug(reason)
  RFInfo('[Ravager Framework] Finished running settings functions')
}

// Change slime girl's chance to add slime to the player
window.RavagerFrameworkApplySlimeRestrictChance = function(reason) {
  var settings = KDModSettings['RavagerFramework'];
  RFDebug('[Ravager Framework] RavagerFrameworkApplySlimeRestrictChance(' + reason + ')')
  RFDebug('[Ravager Framework] Setting Slime Girl\'s restrict chance to ' + settings.ravagerSlimeAddChance)
  var slimeIndex = KinkyDungeonEnemies.findIndex(val => { if (val.name == 'SlimeRavager' && val.addedByMod == 'RavagerFramework') return true });
  if (!settings.ravagerDisableSlimegirl && slimeIndex >= 0) {
    var slime = KinkyDungeonEnemies[slimeIndex]
    slime.ravage.addSlimeChance = settings.ravagerSlimeAddChance
    RFDebug('[Ravager Framework] Refreshing enemy cache')
    KinkyDungeonRefreshEnemiesCache()
  }
}

// Mod settings for changing spicy dialogue for applicable ravagers
// This NEEDS to be run AFTER RavagerFrameworkRefreshEnemies, as this relies on enemy enabled state being consistent with the relevant setting
// If I expand the mod settings into a dedicated page, I'll most likely make a way to enable spicy dialogue per enemy, so this will need to be reworked
window.RavagerFrameworkApplySomeSpice = function(reason) {
  // Relevant settings
  const spice = RavagerGetSetting('ravagerSpicyTendril')
  RFDebug('[Ravager Framework] RavagerFrameworkApplySomeSpice(' + reason + ')')
  RFDebug('[Ravager Framework] Spicy Dialogue set to ', spice)
  // Filter enemies to ravagers that have Spice options
  const spiceable = KinkyDungeonEnemies.filter(enemy =>
    // Added by me
    enemy.addedByMod == 'RavagerFramework' &&
    // Has ravage settings
    enemy.ravage &&
    // Has ranges
    enemy.ravage.ranges &&
    // Has ranges that can have spicy dialogue
    enemy.ravage.ranges.some(([_, data]) =>
      // Find at least one spiceable narration
      Object.keys(data.narration).some(n =>
        // Regex always looks odd
        n.match(/((Spicy)|(Tame)).*/g)
      )
    )
  )
  RFTrace('[Ravager Framework][DBG][RavagerFrameworkApplySomeSpice] Spiceable enemies: ', spiceable)
  // Loop each of the possibly spicy ravager
  spiceable.forEach(enemy => {
    RFDebug('[Ravager Framework][RavagerFrameworkApplySomeSpice] Enemy ranges before refresh: ', enemy.ravage.ranges)
    if (spice) {
      RFDebug('[Ravager Framework][RavagerFrameworkApplySomeSpice] Enabling spice for ' + enemy.name)
      // For each ravaging range and slot, apply spicy dialogue if it exists
      enemy.ravage.ranges.forEach(range => {
        enemy.ravage.targets.forEach(slot => {
          if (range[1].narration.hasOwnProperty('Spicy' + slot))
            range[1].narration[slot] = range[1].narration['Spicy' + slot]
        })
      })
    } else {
      RFDebug('[Ravager Framework][RavagerFrameworkApplySomeSpice] Disabling spice for ' + enemy.name)
      // For each ravaging range and slot, apply tame dialogue if it exists
      enemy.ravage.ranges.forEach(range => {
        enemy.ravage.targets.forEach(slot => {
          if (range[1].narration.hasOwnProperty('Tame' + slot))
            range[1].narration[slot] = range[1].narration['Tame' + slot]
        })
      })
    }
    RFDebug('[Ravager Framework][RavagerFrameworkApplySomeSpice] Enemy ranges after refresh: ', enemy.ravage.ranges)
  })
  // Refresh enemies cache
  KinkyDungeonRefreshEnemiesCache()
}

// Mod Settings for disabling ravagers
// Any enemy within RavagerData.Definitions.Enemies that has a value for enemy.RFDisableRefvar can be disabled with this function
window.RavagerFrameworkRefreshEnemies = function(reason) {
  RFDebug(`[Ravager Framework] RavagerFrameworkRefreshEnemies(${reason})`)
  for (let en in RavagerData.Definitions.Enemies) {
    let enemy = RavagerData.Definitions.Enemies[en]
    if (enemy.RFDisableRefvar) {
      let enemyIndex = KinkyDungeonEnemies.findIndex(e => e.name == enemy.name && e.addedByMod == "RavagerFramework")
      if (RavagerGetSetting(enemy.RFDisableRefvar)) {
        if (enemyIndex >= 0) {
          RFDebug(`[Ravager Framework][RavagerFrameworkRefreshEnemies]: Removing ${enemy.name}`)
          KinkyDungeonEnemies.splice(enemyIndex, 1)
        }
      } else {
        if (enemyIndex < 0 || enemyIndex == undefined) {
          RFDebug(`[Ravager Framework][RavagerFrameworkRefreshEnemies]: Adding ${enemy.name}`)
          KinkyDungeonEnemies.push(structuredClone(enemy))
        }
      }
    } else {
      RFDebug(`Enemy ${enemy.name} does not contain a value for RFDisableRefvar, and cannot be disabled by us.`)
    }
  }
  RFDebug("[Ravager Framework][RavagerFrameworkRefreshEnemies]: Refreshing enemy cache.")
  KinkyDungeonRefreshEnemiesCache()
}

window.RavagerFrameworkSetupSound = function() {
  // I'm using this as a flag that another mod can set to explicitly tell me they're a sound mod
  // If you're a developer, the Ravager Framework plays sounds on the player getting hit and orgasming. If those conflict with your mod's sounds and the below check is not enough to notice your mod as a sound mod, you can set `window.HasSoundMod = true` to solve that conflict without waiting for this framework to update.
  if (!window.HasSoundMod)
    // Check if we can find another sound mod active
    window.HasSoundMod = KDAllModFiles.filter((val) => { if (val.filename.toLowerCase().includes('girlsound.ks')) return true; }).length > 0
  // Debug message that'll be helpful incase there's another sound mod loaded that slipped the above check
  RFDebug("[Ravager Framework][RavagerFrameworkSetupSound] Enabling sound effects. " + (window.HasSoundMod ? "We found another sound mod, so our sound effects won't actually be used." : "No other sound mod detected. If this is incorrect, please post either your mod list or a debug log to the Ravager Framework."))
  RFTrace("[Ravager Framework][RavagerFrameworkSetupSound] Mod list: ", Object.keys(KDMods), "; Mod file list: ", KDAllModFiles.map(v => v.filename))
  // Setup sound functions
  window.RavagerSoundGotHit = false
  KDEventMapGeneric.beforeDamage.RavagerSoundHit = RavagerData.KDEventMapGeneric.beforeDamage.RavagerSoundHit
  KDEventMapGeneric.tick.RavagerSoundTick = RavagerData.KDEventMapGeneric.tick.RavagerSoundTick
  KDExpressions.RavagerSoundHit = RavagerData.KDExpressions.RavagerSoundHit
  KDExpressions.RavagerSoundOrgasm = RavagerData.KDExpressions.RavagerSoundOrgasm
}

window.RefreshRavagerDataVariables = function(reason) {
  RFDebug("[Ravager Framework][RefreshRavagerDataVariables]: Refreshing variables for reason: ", reason)
  if (RavagerGetSetting("ravagerEnableNudeOutfit")) {
    if (!RavagerData.Variables.MimicBurstPossibleDress.includes("Nude"))
      RavagerData.Variables.MimicBurstPossibleDress.push("Nude")
  } else {
    if (RavagerData.Variables.MimicBurstPossibleDress.includes("Nude"))
      RavagerData.Variables.MimicBurstPossibleDress.splice(RavagerData.Variables.MimicBurstPossibleDress.findIndex(v => v == "Nude"), 1)
  }
}

// Verbose? Perhaps. Accurate? Yes...
// TODO: This'll need to be changed if we're going to make ravaging able to happen to npcs
window.RavagerFreeAndClearAllDataIfNoRavagers = function(showMessage = true) {
  RFTrace('[Ravager Framework][RavagerFreeAndClearAllDataIfNoRavagers]: showMessage: ', showMessage)
  let nearby = KDNearbyEnemies(KinkyDungeonPlayerEntity.x, KinkyDungeonPlayerEntity.y, 2)
  RFTrace('[Ravager Framework][RavagerFreeAndClearAllDataIfNoRavagers]: nearby: ', nearby)
  let cleared = false
  nearby.forEach(enemy => {
    enemy.stun = 5
    if (enemy.ravage)
      cleared = true
  })
  if (cleared) {
    if (showMessage && KinkyDungeonPlayerEntity.ravage)
      KinkyDungeonSendTextMessage(30, "You break free of their grip, leaving an opening to escape!", "#ff0000", 4)
    RavagerFreeAndClearAllData()
    KDBreakTether(KinkyDungeonPlayerEntity)
  }
}

// Util to remove player and enemy ravager data
window.RavagerFreeAndClearAllData = function() {
  // Clear all enemies
  for (const enemy of KDMapData.Entities) { // TODO: This'll need to be changed if we're going to make ravaging able to happen to npcs
    if (enemy.ravage)
      delete enemy.ravage
    else {
      // Clear the witness property from any enemies that witnessed this session
      delete enemy.witnessedRavaging
      enemy.witnessedRavagingJustDeleted = true
    }
  }
  // Clear all "occupied" restraints
  for (const slot in ravageEquipmentSlotTargets) {
    KinkyDungeonRemoveRestraintsWithName(`${slot.replace("Item", "RavagerOccupied")}`)    
  }
  // Clear player data
  delete KinkyDungeonPlayerEntity.ravage
  KinkyDungeonRemoveRestraintsWithName("Pinned")
}
