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
  if (RFGetSetting("ravagerHelpDebug")) {
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
    if (RFGetSetting("ravagerFancyFont")) {
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
  const spice = RFGetSetting('ravagerSpicyTendril')
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
      if (RFGetSetting(enemy.RFDisableRefvar)) {
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
  if (RFGetSetting("ravagerEnableNudeOutfit")) {
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
      KinkyDungeonSendTextMessage(30, RFGetText("NarrationsPinBreakFree"), "#ff0000", 4)
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

// Draws the ravager control menu
window.RavagerFrameworkControlRun = function() {
  // Draw custom background
  KDDraw(kdcanvas, kdpixisprites, "bg", `${KinkyDungeonRootDirectory}Backgrounds/${RavagerData.Variables.RFControl.Background}.png`, 0, 0, CanvasWidth, CanvasHeight, undefined, { zIndex: -115 });
  if (RavagerData.Variables.RFControl.UseOldRFControl) {
    // All the buttons we'll draw
    const buttons = [
      {
        name: "RFControlBack",
        func: () => {
          RFDebug("[Ravager Framework][RFControlRun] Leaving ravager control")
          RavagerData.Variables.State = RavagerData.Variables.PrevState
          RavagerData.Variables.DrawState = RavagerData.Variables.PrevDrawState
        },
        enabled: true,
        Left: 1650,
        Top: 900,
        Width: 300,
        Height: 64,
        Label: "Return"
      },
      {
        name: "RFControlRevertFunctions",
        func: () => { RavagerFrameworkRevertFunctions() },
        enabled: true,
        Left: 550,
        Top: 496,
        Width: 300,
        Height: 64,
        Label: "Revert functions"
      },
      {
        name: "RFControlEndIWantToHelpDebugMode",
        func: () => { KDModSettings.RavagerFramework.ravagerHelpDebug = false; RavagerFrameworkIWantToHelpDebug('Finish') },
        enabled: KDModSettings?.RavagerFramework?.ravagerHelpDebug,
        Left: 550,
        Top: 792,
        Width: 300,
        Height: 64,
        Label: "End Debug Log"
      },
      {
        name: "RFControlSaveFunctionOverrides",
        func: () => { RavagerFrameworkSaveFunctionOverrides(); },
        enabled: true,
        Left: 1100,
        Top: 200,
        Width: 300,
        Height: 64,
        Label: "Save Overridden Functions"
      },
      {
        name: "RFControlCheckFunctionOverrides",
        func: () => { RavagerFrameworkCheckFunctionOverrides(); },
        enabled: true,
        Left: 1100,
        Top: 274,
        Width: 300,
        Height: 64,
        Label: "Check Overridden Functions"
      }
    ]
    // All the checkboxes we'll draw
    const checkboxes = [
      {
        name: "RFControlDebug",
        func: () => { RavagerFrameworkToggleDebug() },
        Left: 550,
        Top: 200,
        Disabled: false,
        Text: "Heavy Debugging",
        IsChecked: _RavagerFrameworkDebugEnabled,
        enabled: true
      },
      {
        name: "RFControlNameFormatDebug",
        func: (_bdata) => {
          RavagerData.Variables.RFControl.NameFormatDebug = !RavagerData.Variables.RFControl.NameFormatDebug
        },
        Left: 550,
        Top: 274,
        Disabled: false,
        Text: "Debug NameFormat function",
        IsChecked: RavagerData.Variables.RFControl.NameFormatDebug,
        enabled: true
      },
      {
        name: "RFControlExposeMimics",
        func: (_bdata) => {
          RavagerFrameworkSetMimicExposure(!RavagerData.Variables.RFControl.ExposeMimics)
        },
        Left: 550,
        Top: 348,
        Disabled: RFGetSetting("ravagerDisableMimic"),
        Text: "Expose Mimics",
        IsChecked: RavagerData.Variables.RFControl.ExposeMimics,
        enabled: !RFGetSetting("ravagerDisableMimic"),
        options: {
          // HoveringText: "Enable to force the mimic spoiler bubble to be constantly shown" // Apparently HoveringText is only shown within the bounds of the button. How can I make it do a popup?
        }
      },
      {
        name: "RFControlPassiveMimic",
        func: () => {
          RavagerFrameworkSetMimicPassive(!RavagerData.Variables.RFControl.PassiveMimics)
        },
        Left: 550,
        Top: 422,
        Disabled: RFGetSetting("ravagerDisableMimic"),
        Text: "Oblivious Mimics",
        IsChecked: RavagerData.Variables.RFControl.PassiveMimics,
        enabled: !RFGetSetting("ravagerDisableMimic"),
        options: {
          // HoveringText: "Enable to make mimic ravagers never notice the player" // Apparently HoveringText is only shown within the bounds of the button. How can I make it do a popup?
        }
      },
      {
        name: "RFControlTrackMimics",
        func: () => {
          RavagerFrameworkSetMimicTracking(!RavagerData.Variables.RFControl.TrackMimics)
        },
        Left: 550,
        Top: 570,
        Disabled: RFGetSetting("ravagerDisableMimic"),
        Text: "Track Mimics",
        IsChecked: RavagerData.Variables.RFControl.TrackMimics,
        enabled: !RFGetSetting("ravagerDisableMimic")
      },
      {
        name: "RFControlAnnounceRavagers",
        func: () => {
          RavagerFrameworkSetRavagerCounting(!RavagerData.Variables.RFControl.AnnounceRavagers)
        },
        Left: 550,
        Top: 644,
        Disabled: RFGetSetting("ravagerDisableBandit") && RFGetSetting("ravagerDisableWolfgirl") && RFGetSetting("ravagerDisableSlimegirl") && RFGetSetting("ravagerDisableTentaclePit") && RFGetSetting("ravagerDisableMimic"),
        Text: "Announce Ravagers",
        IsChecked: RavagerData.Variables.RFControl.AnnounceRavagers,
        enabled: !(RFGetSetting("ravagerDisableBandit") && RFGetSetting("ravagerDisableWolfgirl") && RFGetSetting("ravagerDisableSlimegirl") && RFGetSetting("ravagerDisableTentaclePit") && RFGetSetting("ravagerDisableMimic"))
      },
      {
        name: "RFControlDebugVanillaTextOverrides",
        func: () => {
          RavagerData.Variables.RFControl.DebugVanillaTextOverrides = !RavagerData.Variables.RFControl.DebugVanillaTextOverrides
        },
        Left: 550,
        Top: 718,
        Disabled: false,
        Text: "Debug Text Replacements",
        IsChecked: RavagerData.Variables.RFControl.DebugVanillaTextOverrides,
        enabled: true,
      },
      {
        name: "RFControlControlBanditsFirstLevel",
        func: () => {
          RavagerData.Variables.RFControl.ControlBanditsFirstLevel = !RavagerData.Variables.RFControl.ControlBanditsFirstLevel
        },
        Left: 1100,
        Top: 348,
        Disabled: false,
        Text: "Control 1st lvl Bandit #s",
        IsChecked: RavagerData.Variables.RFControl.ControlBanditsFirstLevel,
        enabled: !RFGetSetting("ravagerDisableBandit")
      },
      {
        name: "RFControlUseOldRFControlLayout",
        func: () => {
          RavagerData.Variables.RFControl.UseOldRFControl = !RavagerData.Variables.RFControl.UseOldRFControl
          return true
        },
        Left: 1100,
        Top: 422,
        Disabled: false,
        Text: "Use old RFControl layout",
        IsChecked: RavagerData.Variables.RFControl.UseOldRFControl,
        enabled: true
      },
    ]
    // All the labels we'll draw
    const labels = [
      {
        Text: "Ravager Controls",
        X: 1250,
        Y: 100,
        Width: 1000
      }
    ]
    // All the rectangles we'll draw
    const rects = [
      // { // Doesn't fit with new background, but still here bc I like the idea
      //  Container: kdcanvas,
      //  Map: kdpixisprites,
      //  id: "RFControlTitleHR",
      //  Params: {
      //    Left: 550,
      //    Top: 130,
      //    Width: 1400,
      //    Height: 1,
      //    Color: "#f3f"
      //  }
      // }
    ]
    // Draw each button
    for (var btn of buttons)
      DrawButtonKDEx(
        btn?.name,
        btn?.func,
        btn?.enabled,
        btn?.Left,
        btn?.Top,
        btn?.Width,
        btn?.Height,
        btn?.Label,
        (btn?.enabled ? (btn?.Color ? btn.Color : KDBaseWhite) : "#757575"),
        btn?.Image,
        btn?.HoveringText,
        !btn?.enabled,
        btn?.NoBorder,
        btn?.FillColor,
        btn?.FontSize,
        btn?.ShiftText,
        btn?.options
      )
    // Draw each checkbox
    for (var box of checkboxes)
      DrawCheckboxRFEx(
        box?.name,
        box?.func,
        box?.enabled,
        box?.Left,
        box?.Top,
        box?.Width,
        box?.Height,
        box?.Text,
        box?.IsChecked,
        box?.Disabled,
        box?.TextColor,
        box?._CheckImage,
        box?.options
      )
    // Draw each label
    for (var label of labels)
      DrawTextFitKD(
        label?.Text,
        label?.X,
        label?.Y,
        label?.Width,
        label?.Color ? label.Color : KDBaseWhite,
        label?.BackColor,
        label?.FontSize,
        label?.Align,
        label?.zIndex,
        label?.alpha,
        label?.border,
        label?.unique,
        label?.font
      )
    // Draw each rectangle
    for (var rect of rects)
      DrawRectKD(
        rect?.Container,
        rect?.Map,
        rect?.id,
        rect?.Params
      )
  } else {
    // Rework
    const Ystart = 190
    let Y = Ystart
    const Ystep = 80
    const Xstart = 550
    const confRows = 8 // Number of options
    const confXOffset = 350
    let bordercolor = "#000"
    try { bordercolor = string2hex(RavagerData.Variables.RFControl.Customization_BorderColor) } catch {}
    // Title
    DrawTextFitKD(RFGetText("RFCTitle"), 1250, Ystart - 120, 1000, KDBaseWhite, undefined, 40)
    // Return button
    DrawButtonKDEx("RFCReturn", () => { RFDebug("[RFC] Leaving ravager control"); RavagerData.Variables.State = RavagerData.Variables.PrevState; RavagerData.Variables.DrawState = RavagerData.Variables.PrevDrawState; return true }, true, 975, 880, 550, 64, RFGetText("RFCReturn"), KDBaseWhite, undefined, undefined, false, false, undefined, undefined, undefined, { bordercolor: bordercolor })
    // Categories
    let confCategories = Object.keys(RavagerData.Definitions.FrameworkControls).splice(RavagerData.Variables.RFControl._CategoryPage * confRows, confRows) // Select just the page we are on
    // Draw category buttons
    confCategories.forEach((currentCategory) => {
      DrawButtonKDEx("RFCCat" + currentCategory, () => { console.log("[RFC] Pressed button for category " + currentCategory); RavagerData.Variables.RFControl._ConfPage = 0; RavagerData.Variables.RFControl._ConfCategory = currentCategory; return true }, true, Xstart, Y, 300, 64, RFGetText("RFCCategory" + currentCategory), KDBaseWhite, undefined, undefined, false, false, undefined, undefined, undefined, { bordercolor: bordercolor })
      Y += Ystep
    })
    if (Object.keys(RavagerData.Definitions.FrameworkControls).length > confRows) {
      if (RavagerData.Variables.RFControl._CategoryPage != 0) {
        DrawButtonKDEx("RFCCatListUp", (b) => { RavagerData.Variables.RFControl._CategoryPage--; return true }, true, Xstart + 105, Ystart - 50, 90, 40, "", KDBaseWhite, KinkyDungeonRootDirectory + "UI/RavUp.png", undefined, false, false, undefined, undefined, undefined, { bordercolor: bordercolor })
      }
      if (RavagerData.Variables.RFControl._CategoryPage < (!(Object.keys(RavagerData.Definitions.FrameworkControls).length % confRows) ? Object.keys(RavagerData.Definitions.FrameworkControls).length / confRows - 1 : Math.floor(Object.keys(RavagerData.Definitions.FrameworkControls).length / confRows))) {
        DrawButtonKDEx("RFCCatListDown", (b) => { RavagerData.Variables.RFControl._CategoryPage++; return true }, true, Xstart + 105, Ystart + (Ystep * confRows), 90, 40, "", KDBaseWhite, KinkyDungeonRootDirectory + "UI/RavDown.png", undefined, false, false, undefined, undefined, undefined, { bordercolor: bordercolor })
      }
    }
    Y = Ystart
    let currentCategory = RavagerData.Variables.RFControl._ConfCategory
    if (RavagerData.Definitions.FrameworkControls.hasOwnProperty(currentCategory)) {
      let categoryConfs = RavagerData.Definitions.FrameworkControls[currentCategory]
      if (categoryConfs.length > confRows * 2) {
        if (RavagerData.Variables.RFControl._ConfPage != 0) {
          DrawButtonKDEx("RFCToggleListUp", (b) => { RavagerData.Variables.RFControl._ConfPage--; return true }, true, Xstart + 105 + confXOffset * 2, Ystart - 50, 90, 40, "", KDBaseWhite, KinkyDungeonRootDirectory + "UI/RavUp.png", undefined, false, false, undefined, undefined, undefined, { bordercolor: bordercolor })
        }
        if (RavagerData.Variables.RFControl._ConfPage < (categoryConfs.length % (confRows * 2) == 0 ? categoryConfs.length / (confRows * 2) - 1 : Math.floor(categoryConfs.length / (confRows * 2)))) {
          DrawButtonKDEx("RFCToggleListDown", (b) => { RavagerData.Variables.RFControl._ConfPage++; return true }, true, Xstart + 105 + confXOffset * 2, Ystart + ((Ystep) * confRows), 90, 40, "", KDBaseWhite, KinkyDungeonRootDirectory + "UI/RavDown.png", undefined, false, false, undefined, undefined, undefined, { bordercolor: bordercolor })
        }
      }
      let categoryConfsSlice = categoryConfs.slice(RavagerData.Variables.RFControl._ConfPage * (confRows * 2), RavagerData.Variables.RFControl._ConfPage * (confRows * 2) + (confRows * 2))
      let confSecondColumnOffset = 0
      let confCount = 0
      categoryConfsSlice.forEach((confEntry) => {
        // Variable is a toggle
        if (confEntry.type == "boolean") {
          // Custom get-value function; don't mind how wasteful this all is :)
          if (RavagerData.Variables.RFControl[confEntry.refvar] == undefined && typeof confEntry.getval == "function")
            RavagerData.Variables.RFControl[confEntry.refvar] = confEntry.getval()
          // Default value
          if (RavagerData.Variables.RFControl[confEntry.refvar] == undefined) {
            RavagerData.Variables.RFControl[confEntry.refvar] = (confEntry.default != undefined) ? confEntry.default : false
          }
          // Disable button?
          let blocking = (typeof confEntry.block == "function") ? confEntry.block() : undefined
          // Internal button name
          let name = confEntry.name ? confEntry.name : confEntry.refvar
          // Click function - If direct on-click function control is needed, define `onclick` as you function. If you just need to update some stuff with the new value, define `postclick` as a function that'll take the new refvar value as the only argument
          let click = confEntry.onclick ? confEntry.onclick : (bdata) => { if (confEntry.refvar) RavagerData.Variables.RFControl[confEntry.refvar] = !RavagerData.Variables.RFControl[confEntry.refvar]; if (confEntry.postclick) confEntry.postclick(RavagerData.Variables.RFControl[confEntry.refvar]); return true; }
          // When declaring your own on-click function, you'll may not be using a reference variable in the normal refvar location, so you can declare `checked` as a function that returns true or false for the checked value
          let checked = (confEntry.hasOwnProperty('checked') && typeof confEntry.checked == "function") ? confEntry.checked() : RavagerData.Variables.RFControl[confEntry.refvar]
          DrawCheckboxRFEx("RFCToggle_" + name, click, !blocking, Xstart + confXOffset + confSecondColumnOffset, Y, 64, 64, RFGetText("RFCBool" + currentCategory + name), checked, false, blocking ? "#888" : KDBaseWhite, undefined, { bordercolor: bordercolor })
          // Setup description popup
          if (RFHasText("RFCHover" + currentCategory + name) && !RavagerData.Variables.RFControl.HoverData.BoxData[name]) {
            RavagerData.Variables.RFControl.HoverData.BoxData[name] = {
              name: name,
              Left: Xstart + confXOffset + confSecondColumnOffset,
              Top: Y,
              Width: 64,
              Height: 64,
              Text: RFGetText("RFCBool" + currentCategory + name),
              hoverDesc: RFGetText("RFCHover" + currentCategory + name),
              category: currentCategory
            }
          }
          //
          Y += Ystep;
        } else if (confEntry.type == "range") { // Range selection
          // Custom get-value function; don't mind how wasteful this all is :)
          if (RavagerData.Variables.RFControl[confEntry.refvar] == undefined && typeof confEntry.getval == "function")
            RavagerData.Variables.RFControl[confEntry.refvar] = confEntry.getval()
          // Default value
          if (RavagerData.Variables.RFControl[confEntry.refvar] == undefined) {
            RavagerData.Variables.RFControl[confEntry.refvar] = confEntry.default != undefined ? confEntry.default : ((confEntry.rangehigh + confEntry.rangelow) / 2)
          }
          let blocking = typeof confEntry.block == "function" ? confEntry.block() : undefined
          // Determine significant digits in stepcount
          let significantDigits = confEntry.stepcount.toString().includes(".") ? confEntry.stepcount.toString().split(".")[1].length : 0
          let name = confEntry.name ? confEntry.name : confEntry.refvar
          // Decrement
          DrawButtonKDEx(`RFCRangeButtonL_${name}`, (bdata) => {
            if (RavagerData.Variables.RFControl[confEntry.refvar] > confEntry.rangelow)
              RavagerData.Variables.RFControl[confEntry.refvar] = parseFloat((RavagerData.Variables.RFControl[confEntry.refvar] - confEntry.stepcount).toFixed(significantDigits))
            if (typeof confEntry.postclick == "function")
              confEntry.postclick(RavagerData.Variables.RFControl[confEntry.refvar])
            return true
          }, !blocking, Xstart + confXOffset + confSecondColumnOffset, Y, 64, 64, "<", blocking ? "#888" : KDBaseWhite, undefined, undefined, false, false, undefined, undefined, undefined, { bordercolor: bordercolor })
          // Label
          DrawTextFitKD(`${RFGetText("RFCRange" + currentCategory + name)}: ${RavagerData.Variables.RFControl[confEntry.refvar]}`, Xstart + confXOffset + 64 + 190 + confSecondColumnOffset, Y + 32, 360, blocking ? "#888" : KDBaseWhite, undefined, 30)
          // Increment
          DrawButtonKDEx(`RFCRangeButtonR_${name}`, (bdata) => {
            if (RavagerData.Variables.RFControl[confEntry.refvar] < confEntry.rangehigh)
              RavagerData.Variables.RFControl[confEntry.refvar] = parseFloat((RavagerData.Variables.RFControl[confEntry.refvar] + confEntry.stepcount).toFixed(significantDigits))
            if (typeof confEntry.postclick == "function")
              confEntry.postclick(RavagerData.Variables.RFControl[confEntry.refvar])
            return true
          }, !blocking, Xstart + confXOffset + 64 + 360 + 20 + confSecondColumnOffset, Y, 64, 64, ">", blocking ? "#888" : KDBaseWhite, undefined, undefined, false, false, undefined, undefined, undefined, { bordercolor: bordercolor })
          // Setup description popup
          if (RFHasText("RFCHover" + currentCategory + name) && !RavagerData.Variables.RFControl.HoverData.BoxData[name]) {
            RavagerData.Variables.RFControl.HoverData.BoxData[name] = {
              name: name,
              Left: Xstart + confXOffset + confSecondColumnOffset,
              Top: Y,
              Width: 500,
              Height: 64,
              Text: RFGetText("RFCRange" + currentCategory + name),
              hoverDesc: RFGetText("RFCHover" + currentCategory + name),
              category: currentCategory
            }
          }
          //
          Y += Ystep
        } else if (confEntry.type == "button") { // Custom button to run custom code when clicked
          let blocking = (typeof confEntry.block == "function") ? confEntry.block() : undefined
          DrawButtonKDEx(confEntry.name, confEntry.click, !blocking, Xstart + confXOffset + confSecondColumnOffset, Y, 370, 64, RFGetText("RFCButton" + currentCategory + confEntry.name), blocking ? "#888" : KDBaseWhite, confEntry.image, undefined, false, false, undefined, undefined, undefined, { bordercolor: bordercolor })
          // Setup description popup
          if (RFHasText("RFCHover" + currentCategory + confEntry.name) && !RavagerData.Variables.RFControl.HoverData.BoxData[confEntry.name]) {
            RavagerData.Variables.RFControl.HoverData.BoxData[confEntry.name] = {
              name: confEntry.name,
              Left: Xstart + confXOffset + confSecondColumnOffset,
              Top: Y,
              Width: 370,
              Height: 64,
              Text: RFGetText("RFCButton" + currentCategory + confEntry.name),
              hoverDesc: RFGetText("RFCHover" + currentCategory + confEntry.name),
              category: currentCategory
            }
          }
          //
          Y += Ystep
        } else if (confEntry.type == "text") { // Just a label, no settings control
          let blocking = (typeof confEntry.block == "function") ? confEntry.block() : undefined
          DrawTextFitKD(RFGetText("RFCText" + currentCategory + confEntry.name), Xstart + confXOffset + 64 + 190 + confSecondColumnOffset, Y + 32, 480, blocking ? "#888" : KDBaseWhite, undefined, 30)
          // Setup description popup
          if (RFHasText("RFCHover" + currentCategory + confEntry.name) && !RavagerData.Variables.RFControl.HoverData.BoxData[confEntry.name]) {
            RavagerData.Variables.RFControl.HoverData.BoxData[confEntry.name] = {
              name: confEntry.name,
              Left: Xstart + confXOffset + confSecondColumnOffset,
              Top: Y,
              Width: 480,
              Height: 64,
              Text: RFGetText("RFCText" + currentCategory + confEntry.name),
              hoverDesc: RFGetText("RFCHover" + currentCategory + confEntry.name),
              category: currentCategory
            }
          }
          //
          Y += Ystep
        } else if (confEntry.type == "string") { // Text input
          // Custom get-value function; don't mind how wasteful this all is :)
          if (RavagerData.Variables.RFControl[confEntry.refvar] == undefined && typeof confEntry.getval == "function")
            RavagerData.Variables.RFControl[confEntry.refvar] = confEntry.getval()
          let elem = KDTextField(confEntry.refvar, Xstart + confXOffset + confSecondColumnOffset, Y, 480, 64, undefined, RavagerData.Variables.RFControl[confEntry.refvar], 100).Element
          elem.addEventListener("input", () => { RavagerData.Variables.RFControl[confEntry.refvar] = elem.value })
          // Setup description popup
          if (RFHasText("RFCHover" + currentCategory + confEntry.refvar) && !RavagerData.Variables.RFControl.HoverData.BoxData[confEntry.refvar]) {
            RavagerData.Variables.RFControl.HoverData.BoxData[confEntry.refvar] = {
              name: confEntry.refvar,
              Left: Xstart + confXOffset + confSecondColumnOffset,
              Top: Y,
              Width: 480,
              Height: 64,
              Text: RFGetText("RFCString" + currentCategory + confEntry.refvar),
              hoverDesc: RFGetText("RFCHover" + currentCategory + confEntry.refvar),
              category: currentCategory
            }
          }
          //
          Y += Ystep
        } else if (confEntry.type == "list") { // List of options; similar to range, but iterating over an array of options and allowing arbitrary types
          // Custom get-value function; don't mind how wasteful this all is :)
          if (RavagerData.Variables.RFControl[confEntry.refvar] == undefined && typeof confEntry.getval == "function")
            RavagerData.Variables.RFControl[confEntry.refvar] = confEntry.getval()
          // Default
          if (RavagerData.Variables.RFControl[confEntry.refvar] == undefined)
            RavagerData.Variables.RFControl[confEntry.refvar] = confEntry.default
          let blocking = (typeof confEntry.block == "function") ? confEntry.block() : undefined
          let name = confEntry.name ? confEntry.name : confEntry.refvar
          // Decrement
          DrawButtonKDEx(`RFCListButtonL_${name}`, (bdata) => {
            let newindex = (confEntry.options.indexOf(RavagerData.Variables.RFControl[confEntry.refvar]) - 1) == -1 ? confEntry.options.length - 1 : confEntry.options.indexOf(RavagerData.Variables.RFControl[confEntry.refvar]) - 1
            RavagerData.Variables.RFControl[confEntry.refvar] = confEntry.options[newindex]
            if (typeof confEntry.postclick == "function")
              confEntry.postclick(RavagerData.Variables.RFControl[confEntry.refvar])
            return true
          }, !blocking, Xstart + confXOffset + confSecondColumnOffset, Y, 64, 64, "<", blocking ? "#888" : KDBaseWhite, undefined, undefined, false, false, undefined, undefined, undefined, { bordercolor: bordercolor })
          // Label
          DrawTextFitKD(`${RFGetText("RFCList" + currentCategory + name)}: ${RavagerData.Variables.RFControl[confEntry.refvar]}`, Xstart + confXOffset + 64 + 190 + confSecondColumnOffset, Y + 32, 360, blocking ? "#888" : KDBaseWhite, undefined, 30)
          // Increment
          DrawButtonKDEx(`RFCListButtonR_${name}`, (bdata) => {
            let newindex = (confEntry.options.indexOf(RavagerData.Variables.RFControl[confEntry.refvar]) + 1) == confEntry.options.length ? 0 : confEntry.options.indexOf(RavagerData.Variables.RFControl[confEntry.refvar]) + 1
            RavagerData.Variables.RFControl[confEntry.refvar] = confEntry.options[newindex]
            if (typeof confEntry.postclick == "function")
              confEntry.postclick(RavagerData.Variables.RFControl[confEntry.refvar])
            return true
          }, !blocking, Xstart + confXOffset + 64 + 360 + 20 + confSecondColumnOffset, Y, 64, 64, ">", blocking ? "#888" : KDBaseWhite, undefined, undefined, false, false, undefined, undefined, undefined, { bordercolor: bordercolor })
          // Setup description popup
          if (RFHasText("RFCHover" + currentCategory + name) && !RavagerData.Variables.RFControl.HoverData.BoxData[name]) {
            RavagerData.Variables.RFControl.HoverData.BoxData[name] = {
              name: name,
              Left: Xstart + confXOffset + confSecondColumnOffset,
              Top: Y,
              Width: 500,
              Height: 64,
              Text: RFGetText("RFCList" + currentCategory + name),
              hoverDesc: RFGetText("RFCHover" + currentCategory + name),
              category: currentCategory
            }
          }
          //
          Y += Ystep
        } else if (confEntry.type == "padding") { // Padding in between entries; does nothing but increment the Y value to push the next config down a row and contribute to the config count
          Y += Ystep
        }
        confCount++
        if (confCount == confRows) {
          confSecondColumnOffset = 550
          Y = Ystart
        }
      })
    }
    // Draw description popups
    let hoverblocks = RavagerData.Variables.RFControl.HoverData
    for (let data in hoverblocks.BoxData) {
      let o = hoverblocks.BoxData[data]
      if (o.category != RavagerData.Variables.RFControl._ConfCategory)
        continue
      if (MouseIn(o.Left, o.Top, o.Width, o.Height)) {
        let mult = KDGetFontMult()
        let descSettings = hoverblocks.Desc
        let boxSettings = hoverblocks.Box
        let textSplit = []
        o.hoverDesc.split("\n").forEach(v => { KinkyDungeonWordWrap(v, 20 * mult, 40 * mult).split("\n").forEach(vv => { textSplit.push(vv) }) })
        let bPadV = boxSettings.PadV
        let bHeight = (bPadV * 4) + ((descSettings.FontSize + 5) * (textSplit.length - 1))
        let bWidth = 750
        let bLeft = (
          o.Left + boxSettings.XOffset + bWidth < CanvasWidth ?
          o.Left + boxSettings.XOffset :
          o.Left - boxSettings.PadH - bWidth
        )
        let bTop = (
          o.Top + bHeight < CanvasHeight - 50 ?
          o.Top :
          CanvasHeight - bHeight - 50
        )
        let bZIndex = 159
        let bPadH = boxSettings.PadH
        FillRectKD(
          kdcanvas,
          kdpixisprites,
          'RFCHover_' + o.name,
          {
            Left: bLeft,
            Top: bTop,
            Width: bWidth,
            Height: bHeight,
            Color: "#200020",
            zIndex: bZIndex,
            alpha: 0.85
          }
        )
        DrawTextFitKD(
          o.Text,
          bLeft + bPadH,
          bTop + bPadV,
          bWidth - bPadH * 2,
          "#efefef",
          "#000",
          38,
          "left",
          bZIndex + 1,
          undefined,
          undefined,
          undefined,
          descSettings.Font
        )
        for (let n = 0; n < textSplit.length; n++)
          DrawTextFitKD(
            textSplit[n],
            bLeft + bPadH,
            bTop + bPadV * 3 + n * (descSettings.FontSize + 5),
            bWidth - bPadH * 2,
            "#efefef",
            "#000",
            descSettings.FontSize,
            "left",
            bZIndex + 1,
            undefined,
            undefined,
            undefined,
            descSettings.Font
          )
      }
    }
  }
}

// Sets whether the mimic spoiler is guaranteed
window.RavagerFrameworkSetMimicExposure = function(exposed) {
  // Save the setting
  RavagerData.Variables.RFControl.ExposeMimics = exposed
  // Exit early if mimic is disabled
  if (RFGetSetting('ravagerDisableMimic')) {
    RFDebug("[Ravager Framework][MimicExposure]: Mimic disabled. Nothing to do.")
    return
  }
  RFDebug("[Ravager Framework][MimicExposure]: Setting mimic exposure: " + exposed)
  // Find the mimic and its bubble event. If exposed, set event chance to 1, otherwise set event chance to the enemy's default
  KinkyDungeonEnemies.find(enemy =>
    enemy.addedByMod == "RavagerFramework" &&
    enemy.name == "MimicRavager" &&
    enemy.events.some(event =>
      event.type == "ravagerBubble"
    )
  ).events.find(event =>
    event.type == "ravagerBubble"
  ).chance = (exposed ? 1 : RavagerData.Definitions.Enemies.MimicRavager.events.find(event => event.type == "ravagerBubble").chance)
}

// Sets whether mimics are passive or not
window.RavagerFrameworkSetMimicPassive = function(passive) {
  // Save the setting
  RavagerData.Variables.RFControl.PassiveMimics = passive
  // Early exit if mimic is disabled
  if (RFGetSetting("ravagerDisableMimic")) {
    RFDebug("[Ravager Framework][MimicPassive]: Mimic disabled. Nothing to do.")
    return
  }
  RFDebug("[Ravager Framework][MimicPassive]: Setting mimic passive to " + passive)
  // Find the mimic. If passive, set ambushRadius to 0.1, otherwise set to enemy's default
  KinkyDungeonEnemies.find(enemy =>
    enemy.addedByMod == "RavagerFramework" &&
    enemy.name == "MimicRavager"
  ).ambushRadius = (passive ? 0.1 : RavagerData.Definitions.Enemies.MimicRavager.ambushRadius)
}

// Sets whether mimics are tracked or not
window.RavagerFrameworkSetMimicTracking = function(tracked) {
  let enemy = KinkyDungeonEnemies.find(enemy =>
    enemy.addedByMod == "RavagerFramework" &&
    enemy.name == "MimicRavager"
  )
  if (tracked) {
    KDEventMapEnemy.tickAfter["RavagerFrameworkTrackMimics"] = RavagerFrameworkTrackMimics
    enemy.events.push({ trigger: "tickAfter", type: "RavagerFrameworkTrackMimics" })
  } else
    delete KDEventMapEnemy.tickAfter.RavagerFrameworkTrackMimics
  RavagerData.Variables.RFControl.TrackMimics = tracked
}

// Tracks mimics position and status with messages to the console
window.RavagerFrameworkTrackMimics = function(e, enemy, data) {
  function objToString(obj) {
    let ret = "{ "
    for (let k in obj) {
      ret += k + ": "
      if (typeof obj[k] == "string")
        ret += '"' + obj[k] + '", '
      else
        ret += obj[k] + ", "
    }
    return ret.slice(0, -2) + " }"
  }
  let string = `;
Name: ${enemy.Enemy.name}
ID: ${enemy.id}
X: ${enemy.x}
Y: ${enemy.y}
Visual X: ${enemy.visual_x}
Visual Y: ${enemy.visual_y}
FX: ${enemy.fx}
FY: ${enemy.fy}
GX: ${enemy.gx}
GY: ${enemy.gy}
GXX: ${enemy.gxx}
GYY: ${enemy.gyy}
Spawn X: ${enemy.spawnX}
Spawn Y: ${enemy.spawnY}
Home coord: ${objToString(enemy.homeCoord)}
HP: ${enemy.hp}
AI: ${enemy.AI}
Flags: ${objToString(enemy.flags)}
Idle: ${enemy.idle}
Move points: ${enemy.movePoints}
Has moved: ${enemy.moved}
Attack points: ${enemy.attackPoints}
Target: ${enemy.target}
TX: ${enemy.tx}
TY: ${enemy.ty}`
  RFDebug("[Ravager Framework][TrackMimics]: enemy: ", enemy, string)
}

// Sets ravager count messages enabled/disabled
window.RavagerFrameworkSetRavagerCounting = function(enabled) {
  RFDebug(`[Ravager Framework][RFControl][SetAnnounceRavagers]: Setting ravager announcement to ${enabled} ...`)
  let enemies = KinkyDungeonEnemies.filter(enemy => enemy.addedByMod == "RavagerFramework")
  if (enabled) {
    KDEventMapGeneric.tick.RavagerFrameworkTrackPlayer = function(e, data) { RFDebug(`[Ravager Framework][TrackPlayer]: Player at (${KinkyDungeonPlayerEntity.x}, ${KinkyDungeonPlayerEntity.y})`); }
    KDEventMapGeneric.before
    KDEventMapEnemy.tickAfter["RavagerFrameworkAnnounceRavagers"] = RavagerFrameworkCountRavager
    for (let e of enemies)
      e.events.push({ trigger: "tickAfter", type: "RavagerFrameworkAnnounceRavagers" })
    // Enable post-tick announce message in text log
    RavagerData.functions.KinkyDungeonAdvanceTime = KinkyDungeonAdvanceTime
    window.KinkyDungeonAdvanceTime = RavagerFrameworkAdvanceTime
  } else {
    delete KDEventMapGeneric.tick.RavagerFrameworkTrackPlayer
    delete KDEventMapEnemy.tickAfter.RavagerFrameworkAnnounceRavagers
    // Disable post-tick announce message in text log
    window.KinkyDungeonAdvanceTime = RavagerData.functions.KinkyDungeonAdvanceTime
  }
  RavagerData.Variables.RFControl.AnnounceRavagers = enabled
}

// Counts ravagers currently spawned
window.RavagerFrameworkCountRavager = function(e, enemy, data) {
  RFDebug(`[Ravager Framework][AnnounceRavagers]: { ${KinkyDungeonCurrentTick} }  ${enemy.Enemy.name} (id ${enemy.id}) at (${enemy.x}, ${enemy.y})`)
  // Count ravagers for post-tick message
  if (!RavagerData.Variables.RavagerCount)
    RavagerData.Variables.RavagerCount = {}
  if (!RavagerData.Variables.RavagerCount[enemy.Enemy.name])
    RavagerData.Variables.RavagerCount[enemy.Enemy.name] = 1
  else
    RavagerData.Variables.RavagerCount[enemy.Enemy.name]++
}

// Wrapper for KinkyDungeonAdvanceTime to add post-tick ravager count messages
window.RavagerFrameworkAdvanceTime = function(...args) {
  RavagerData.functions.KinkyDungeonAdvanceTime(...args)
  if (RavagerData.Variables.RavagerCount && Object.keys(RavagerData.Variables.RavagerCount).length) {
    var count = {}
    for (var e of Object.entries(RavagerData.Variables.RavagerCount)) {
      var [k, v] = e
      var name = k.replace(/Ravager[0-9]*/, "")
      if (!count[name])
        count[name] = v
      else
        count[name] += v
    }
    var totalEn = KDNearbyEnemies(0, 0, 10000).length
    var actionMsg = `Total: ${totalEn}, `
    var consoleMsg = `[Ravager Count]: { Total: ${totalEn}, `
    for (var e of Object.entries(count)) {
      var [k, v] = e
      actionMsg += `${k.substring(0, 4)}: ${v}(${Math.floor(v / totalEn * 100)}%), `
      consoleMsg += `${k}: ${v}, `
    }
    actionMsg = actionMsg.substring(0, actionMsg.length - 2)
    consoleMsg = consoleMsg.substring(0, consoleMsg.length - 2) + " }"
    KinkyDungeonSendActionMessage(100000, actionMsg, "#f6f", 1)
    RFDebug(consoleMsg)
  }
  // Clear ravager count
  RavagerData.Variables.RavagerCount = {}
}

// Check if we're missing any functions
window.RavagerFrameworkCheckAllFunctions = function() {
  var missingFunctions = ""
  // Loop the functions we use to find any that are missing
  for (var func of RavagerData.FunctionsThatMightBeMissing) {
    var type = eval('typeof ' + func);
    if (type != 'function' && type != 'object')
      missingFunctions += func + ", "
  }
  // Exit now if there's no functions missing
  if (missingFunctions.length == 0)
    return true
  // Trim the trailing comma
  missingFunctions = missingFunctions.slice(0, missingFunctions.length - 2)
  RavagerData.Variables.MissingFunctions = missingFunctions.split(", ")
  // Show the popup for missing functions
  RavagerFrameworkShowModal("missing-functions-popup", "MissingFuncTitle", [ [ "MissingFuncPreamble1", "MissingFuncPreamble2" ], [ "MissingFuncPreamble3", "MissingFuncPreamble4" ], [ "MissingFuncPreamble5" ] ], RFGetText("MissingFuncLabel") + ": " + missingFunctions)
  // If we've made it this far, there are missing functions, so return false
  return false
}

// Get all the game functions we've overriden
window.RavagerFrameworkGetFunctionOverrides = function() {
  let funcs = {}
  for (let key of Object.keys(RavagerData.functions))
    if (key.match(/(KinkyDungeo.*|.*KD.*)/))
      funcs[key] = LZString.compressToBase64(RavagerData.functions[key].toString())
  return funcs
}

// Save current function overrides
window.RavagerFrameworkSaveFunctionOverrides = function() {
  let funcs = RavagerFrameworkGetFunctionOverrides()
  const element = document.createElement("a")
  element.setAttribute("href", `data:application/json;charset=utf-8,${encodeURIComponent(JSON.stringify(funcs, undefined, '  '))}`)
  element.setAttribute("download", `RavagerFramework_FunctionOverrides_KD${TextGetKD("KDVersionStr")}_RF${RavagerData.ModInfo.modbuild}.json`)
  element.click()
}

// Check for missing or mismatched function overrides
window.RavagerFrameworkCheckFunctionOverrides = function() {
  // Setup a file open dialog to read in a file of saved function overrides
  let input = document.createElement("input")
  input.type = "file"
  input.accept = ".json"
  // onchange is called when the user selects a file
  input.onchange = async function(event) {
    const file = event.target.files[0]
    if (file) {
      try {
        const fileContent = await file.text()
        const savedData = JSON.parse(fileContent)
        const currData = RavagerFrameworkGetFunctionOverrides()
        // Parsing
        const skeys = Object.keys(savedData)
        const ckeys = Object.keys(currData)
        const keys = new Set([ ...skeys, ...ckeys ])
        let mismatches = {
          savedKeys: [], // In saved, not in current
          currentKeys: [], // In current, not in saved
          savedFuncs: {}, // Saved version of changed functions
          currentFuncs: {} // Current version of changed functions
        }
        // Loop each function
        for (let key of keys) {
          // Current function not in saved functions. Will trigger when adding new function override
          if (!skeys.includes(key)) {
            mismatches.currentKeys.push(key)
          }
          // Current function not in currently available functions. Will trigger when removing a function override
          if (!ckeys.includes(key)) {
            mismatches.savedKeys.push(key)
          }
          // Current function has changed since being saved. Might be entirely inconsequential, but I don't have a better way to check if function parameters have changed
          if (savedData[key] != currData[key]) {
            mismatches.savedFuncs[key] = savedData[key]
            mismatches.currentFuncs[key] = currData[key]
          }
        }
        // Found mismatches (either mismatching key lists, or mismatching function content); save a report file
        if (mismatches.savedKeys.length || mismatches.currentKeys.length || Object.keys(mismatches.savedFuncs).length || Object.keys(mismatches.currentFuncs).length) {
          const element = document.createElement("a")
          element.setAttribute("href", `data:application/json;charset=utf-8,${encodeURIComponent(JSON.stringify(mismatches, undefined, '  '))}`)
          element.setAttribute("download", `RavagerFramework_FunctionOverrides_Report_KD${TextGetKD("KDVersionStr")}_RF${RavagerData.ModInfo.modbuild}.json`)
          element.click()
        }
      } catch (error) {
        console.error("Error reading or parsing JSON file:", error)
      }
    }
  }
  // Trigger the file open dialog
  input.click()
}

// Show a popup
window.RavagerFrameworkShowModal = function(id, title = "Ravager Framework", preamble, content) {
  // Helper to make the header images
  function ErrorImage(src, path = "Enemies") {
    const img = document.createElement("img")
    img.src = KDModFiles[`Game/${path}/${src}.png`]
    Object.assign(img.style, {
      maxWidth: "10vw",
    })
    return img
  }
  // Creating the popup box
  // The whole popup box
  const backdrop = document.createElement("div")
  backdrop.id = "ravager-framework-" + id
  Object.assign(backdrop.style, {
    position: "fixed",
    inset: 0,
    backgroundColor: "#000000a0",
    fontFamily: "'Arial', sans-serif",
    fontSize: "1.8vmin",
    lineHeight: 1.6
  })
  // The main body
  const modal = document.createElement("div")
  Object.assign(modal.style, {
    position: "absolute",
    display: "flex",
    flexFlow: "column nowrap",
    width: "90vw",
    maxWidth: "1440px",
    maxHeight: "90vh",
    overflow: "hidden",
    backgroundColor: "#282828",
    color: "#fafafa",
    left: "50%",
    top: "50%",
    transform: "translate(-50%, -50%)",
    padding: "1rem",
    borderRadius: "2px",
    boxShadow: "1px 1px 40px -8px #ffffff80"
  })
  backdrop.appendChild(modal)
  // The heading with ravager images
  const heading = document.createElement("h1")
  Object.assign(heading.style, {
    display: "flex",
    flexFlow: "row nowrap",
    alignItems: "center",
    justifyContent: "space-around",
    textAlign: "center"
  })
  heading.appendChild(ErrorImage("BanditRavager"))
  heading.appendChild(ErrorImage("Hearts", "Conditions/RavBubble"))
  heading.appendChild(ErrorImage("WolfgirlRavager"))
  heading.appendChild(ErrorImage("Hearts", "Conditions/RavBubble"))
  heading.appendChild(ErrorImage("SlimeRavager"))
  heading.appendChild(document.createTextNode(RFGetText(title, false)))
  heading.appendChild(ErrorImage("SlimeRavager"))
  heading.appendChild(ErrorImage("Hearts", "Conditions/RavBubble"))
  heading.appendChild(ErrorImage("WolfgirlRavager"))
  heading.appendChild(ErrorImage("Hearts", "Conditions/RavBubble"))
  heading.appendChild(ErrorImage("BanditRavager"))
  modal.appendChild(heading)
  // Horizontal line
  const hr = document.createElement("hr")
  Object.assign(hr.style, {
    border: "1px solid #f6f",
    margin: "0 0 1.5em"
  })
  modal.appendChild(hr)
  // Plain text explaining the popup
  if (Array.isArray(preamble)) {
    for (let amble of preamble) {
      console.error(amble)
      let text = []
      if (Array.isArray(amble))
        for (let a of amble)
          text.push(RFGetText(a, false, true))
      else
        text = [ RFGetText(amble, false, true) ]
      modal.appendChild(KinkyDungeonErrorPreamble(text))
    }
  } else
    modal.appendChild(KinkyDungeonErrorPreamble([ preamble ]))
  // The code-style info box
  const pre = document.createElement("pre")
  Object.assign(pre.style, {
    flex: 1,
    backgroundColor: "#1a1a1a",
    border: "1px solid #ffffff40",
    fontSize: "1.1em",
    padding: "1em",
    userSelect: "all",
    overflowWrap: "anywhere",
    overflowX: "hidden",
    overflowY: "auto",
    color: "#fbf",
    whiteSpace: "pre-wrap"
  })
  // The list of missing functions
  pre.textContent = content
  modal.appendChild(pre)
  // Close button
  const closeButton = document.createElement("button")
  closeButton.textContent = RFGetText("ModalCloseButton")
  Object.assign(closeButton.style, {
    fontSize: "1.25em",
    padding: "0.5em 1em",
    backgroundColor: KDButtonColor,
    border: "2px solid #f6f",
    color: KDBaseWhite,
    cursor: "pointer"
  })
  closeButton.addEventListener("click", () => { backdrop.remove() })
  Object.assign(closeButton.style, {
    display: "flex",
    flexFlow: "row wrap",
    justifyContent: "space-around",
    gap: "1em"
  })
  modal.appendChild(closeButton)
  // Show the popup
  document.body.appendChild(backdrop)
}
