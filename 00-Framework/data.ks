// Flag to know when we finish initializing
window._RavagerFrameworkInInit = true;
// Check for heavy debugging during initialization
window._RavagerFrameworkDebugEnabled = false;
if (localStorage.hasOwnProperty('RavagerFrameworkTraceMessages')) {
  _RavagerFrameworkDebugEnabled = localStorage.RavagerFrameworkTraceMessages
}
window.RavagerData = {
  // To be (maybe) added at KDEventMapGeneric
  KDEventMapGeneric: {
    // Sets flag for playing a sound
    beforeDamage: {
      RavagerSoundHit: (e, item, data) => { if (!window.HasSoundMod) RavagerSoundGotHit = true }
    },
    // Sets flag for playing a sound
    tick: {
      RavagerSoundTick: (e, item, data) => { if (!window.HasSoundMod) RavagerSoundGotHit = false }
    }
  },
  // To be (maybe) added at KDExpressions
  KDExpressions: {
    // Plays sound on getting hit
    RavagerSoundHit: {
      stackable: true,
      priority: 108,
      criteria: (C) => {
        if (C == KinkyDungeonPlayer && (RavagerSoundGotHit || KDUniqueBulletHits.has('undefined[object Object]_player'))) {
          // Unset hit flag
          RavagerSoundGotHit = false
          // Don't remember why we need to interrupt sleep, but sounds like an alright idea, so sure
          KinkyDungeonInterruptSleep()
          // Debug message
          RFTrace('[Ravager Framework][RavagerSoundHit]: enableSound: ', RavagerGetSetting('ravagerEnableSound'), '\nvolume: ', RavagerGetSetting('ravagerSoundVolume') / 2, '\nonHitChance: ', RavagerGetSetting('onHitChance'))
          // Might play a sound
          if (KDToggles.Sound && RavagerGetSetting('ravagerEnableSound') && Math.random() < RavagerGetSetting('onHitChance')) {
            AudioPlayInstantSoundKD(KinkyDungeonRootDirectory + "Audio/" + (KinkyDungeonGagTotal() > 0 ? "Angry21 liliana.ogg" : "Ah1 liliana.ogg"), RavagerGetSetting('ravagerSoundVolume') / 2)
          }
          return true
        }
        return false
      },
      expression: (C) => {
        return {
          EyesPose: "EyesAngry",
          Eyes2Pose: "Eyes2Closed",
          BrowsPose: "BrowsAnnoyed",
          Brows2Pose: "Brows2Angry",
          BlushPose: "",
          MouthPose: "MouthSurprised"
        }
      }
    },
    // Plays sound on orgasming
    RavagerSoundOrgasm: {
      stackable: true,
      priority: 90,
      criteria: (C) => {
        if (C == KinkyDungeonPlayer && KinkyDungeonFlags.get("OrgSuccess") == 7) {
          // Might play a sound
          if (KDToggles.Sound && RavagerGetSetting('ravagerEnableSound')) {
            AudioPlayInstantSoundKD(KinkyDungeonRootDirectory + "Audio" + (KinkyDungeonGagTotal > 0 ? "GagOrgasm.ogg" : "Ah1 liliana.ogg"), RavagerGetSetting('ravagerSoundVolume') / 2)
          }
          // Text log message
          KinkyDungeonSendTextMessage(8, "You make a loud moaning noise", "#1fffc7", 1);
          // Make noise so enemies hear
          KinkyDungeonMakeNoise(9, KinkyDungeonPlayerEntity.x, KinkyDungeonPlayerEntity.y)
          return true
        }
        return false
      },
      expression: (C) => {
        return {
          EyesPose: "EyesClosed",
          Eyes2Pose: "Eyes2Closed",
          BrowsPose: "BrowsAnnoyed",
          Brows2Pose: "Brows2Annoyed",
          BlushPose: "",
          MouthPose: "MouthSurprised"
        }
      }
    }
  },
  functions: {
    // Vanilla game function backups
    DrawButtonKDEx: DrawButtonKDEx,
    KinkyDungeonDrawEnemiesHP: KinkyDungeonDrawEnemiesHP,
    KinkyDungeonDrawGame: KinkyDungeonDrawGame,
    KinkyDungeonRun: KinkyDungeonRun,
    KinkyDungeonHandleClick: KinkyDungeonHandleClick,
    KDDropItems: KDDropItems,
    DrawCheckboxKDEx: DrawCheckboxKDEx,
    KinkyDungeonSendTextMessage: KinkyDungeonSendTextMessage,
    // Format strings used throughout the framework. Handles enemy, restraint, and clothing names, damage strings, and runtime string variations
    // Runtime string variations could be made faster in the case of nested variations, as this code is depth first, and having nested variations will lead to all deeper levels being decided and later thrown away. It'd likely be faster if I trimmed the tree of choices as soon as I could, but that would be significantly more effort :) -- Possibly pretty easy to do by deciding on the top level variation and recursing back into inStringRandom with the chosen section of the input string.
    NameFormat: function(string, entity, restraint, clothing, damage, skipCapitalize) {
      function RFNFTrace(...args) {
        RavagerData.Variables.RFControl.NameFormatDebug && RFDebug(...args)
      }
      RFNFTrace('[Ravager Framework][DBG][NameFormat]: Initial string "' + string + '"; entity: ', entity, '; restraint: ', restraint, '; clothing: ', clothing, '; damage: ', damage, '; skipCapitalize: ', skipCapitalize)
      // Player name
      string = string.replace("PlayerName", KDGameData.PlayerName)
      RFNFTrace('[Ravager Framework][DBG][NameFormat]: Transformed to "' + string + '"')
      // Enemy name
      if (entity) {
        // Definition name
        string = string.replace("EnemyName", TextGet('Name' + entity.Enemy.name))
        // Possible custom entity name (no formatting)
        string = string.replace("EnemyCNameBare", KDEnemyName(entity))
        // Possible custom entity name (w/ formatting)
        string = string.replace("EnemyCName", entity.CustomName || KDGetName(entity.id) || "the " + TextGet("Name" + entity.Enemy.name))
        RFNFTrace('[Ravager Framework][DBG][NameFormat]: Transformed to "' + string + '"')
      }
      // Restraint name
      if (restraint) {
        string = string.replace("RestraintName", TextGet('Restraint' + restraint.name))
        RFNFTrace('[Ravager Framework][DBG][NameFormat]: Transformed to "' + string + '"')
      }
      // Clothing name
      if (clothing) {
        string = string.replace("ClothingName", TextGet("m_" + clothing.Item).includes("[NotFound]") ? clothing.Item : TextGet("m_" + clothing.Item))
        RFNFTrace('[Ravager Framework][DBG][NameFormat]: Transformed to "' + string + '"')
      }
      // Damage string
      if (damage) {
        string = string.replace("DamageTaken", damage.string)
        RFNFTrace('[Ravager Framework][DBG][NameFormat]: Transformed to "' + string + '"')
      }
      // In-string randomization
      function inStringRandom(input) {
        if (!input.includes("{") && !input.includes("}") && !input.includes("|")) {
          RFNFTrace("[Ravager Framework][DBG][InStringRandom]: Input string doesn't contain any selections. Skipping.")
          return input
        }
        function characterCount(input, char) {
          var count = 0
          for (var i = 0; i < input.length; i++)
            if (input[i] == char)
              count++
          RFNFTrace("[Ravager Framework][DBG][InStringRandom][characterCount]: Found a total of " + count + " of character \"" + char + "\" in input string \"" + input + "\"")
          return count
        }
        var currentLevel = 0
        var holding = ""
        var output = ""
        for (var i = 0; i < input.length; i++) {
          RFNFTrace("[Ravager Framework][DBG][InStringRandom]: (L) Level: " + currentLevel)
          if (input[i] == "{") {
            currentLevel++
            holding += "{"
            RFNFTrace("[Ravager Framework][DBG][InStringRandom]: (L+) Holding: " + holding)
          } else if (input[i] == "}") {
            currentLevel--
            holding += "}"
            RFNFTrace("[Ravager Framework][DBG][InStringRandom]: (L-) Holding: " + holding)
          } else if (currentLevel > 0) {
            holding += input[i]
            RFNFTrace("[Ravager Framework][DBG][InStringRandom]: (L0) Holding: " + holding)
          } else {
            output += input[i]
            RFNFTrace("[Ravager Framework][DBG][InStringRandom]: (L) Output: " + output)
          }
          if (currentLevel == 0 && holding.length > 0) {
            RFNFTrace("[Ravager Framework][DBG][InStringRandom]: (P) Holding: " + output)
            if (!holding.includes("|")) {
              output += holding
              RFNFTrace("[Ravager Framework][DBG][InStringRandom]: (P)(NC) Output: " + output)
            } else {
              var sub = holding.substring(1, holding.length - 1)
              RFNFTrace("[Ravager Framework][DBG][InStringRandom]: (P) Substring: " + sub)
              if (sub.includes("{") && sub.includes("}") && characterCount(sub, "|") > 1) {
                sub = inStringRandom(sub)
                RFNFTrace("[Ravager Framework][DBG][InStringRandom]: (P)(R) Substring: " + sub)
              }
              var options = sub.split("|")
              RFNFTrace("[Ravager Framework][DBG][InStringRandom]: (P) Options: ", options)
              var selection = Math.floor(Math.random() * options.length)
              RFNFTrace("[Ravager Framework][DBG][InStringRandom]: (P) Selection: " + options[selection])
              output += options[selection]
              RFNFTrace("[Ravager Framework][DBG][InStringRandom]: (P) Output: " + output)
            }
            holding = ""
          }
        }
        if (currentLevel > 0) {
          RFWarn("[Ravager Framework][NameFormat][InStringRandom]: Input string contains more opening brackets than closing brackets. We will return the input string with an error prefix. Please report this to the author! Offending string:\n" + input)
          return "[ERROR]" + input
        } else if (currentLevel < 0) {
          RFWarn("[Ravager Framework][NameFormat][InStringRandom]: Input string contains more closing brackets than opening brackets. We will return the input string with an error prefix. Please report this to the author! Offending string:\n" + input)
          return "[ERROR]" + input
        }
        RFNFTrace("[Ravager Framework][DBG][InStringRandom]: Final output: " + output)
        return output
      }
      string = inStringRandom(string)
      RFNFTrace('[Ravager Framework][DBG][NameFormat]: inStringRandom transformed to "' + string + '"')
      // Capitalize
      if (!skipCapitalize)
        string = string.replaceAt(0, string[0].toUpperCase())
      RFNFTrace('[Ravager Framework][DBG][NameFormat]: Final string: "' + string + '"')
      return string
    },
    // Draws the ravager control menu
    RFControlRun: function() {
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
            func: () => { RavagerData.functions.SaveFunctionOverrides(); },
            enabled: true,
            Left: 1100,
            Top: 200,
            Width: 300,
            Height: 64,
            Label: "Save Overridden Functions"
          },
          {
            name: "RFControlCheckFunctionOverrides",
            func: () => { RavagerData.functions.CheckFunctionOverrides(); },
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
              RavagerData.functions.MimicExposure(!RavagerData.Variables.RFControl.ExposeMimics)
            },
            Left: 550,
            Top: 348,
            Disabled: RavagerGetSetting("ravagerDisableMimic"),
            Text: "Expose Mimics",
            IsChecked: RavagerData.Variables.RFControl.ExposeMimics,
            enabled: !RavagerGetSetting("ravagerDisableMimic"),
            options: {
              // HoveringText: "Enable to force the mimic spoiler bubble to be constantly shown" // Apparently HoveringText is only shown within the bounds of the button. How can I make it do a popup?
            }
          },
          {
            name: "RFControlPassiveMimic",
            func: () => {
              RavagerData.functions.MimicPassive(!RavagerData.Variables.RFControl.PassiveMimics)
            },
            Left: 550,
            Top: 422,
            Disabled: RavagerGetSetting("ravagerDisableMimic"),
            Text: "Oblivious Mimics",
            IsChecked: RavagerData.Variables.RFControl.PassiveMimics,
            enabled: !RavagerGetSetting("ravagerDisableMimic"),
            options: {
              // HoveringText: "Enable to make mimic ravagers never notice the player" // Apparently HoveringText is only shown within the bounds of the button. How can I make it do a popup?
            }
          },
          {
            name: "RFControlTrackMimics",
            func: () => {
              RavagerData.functions.SetTrackMimics(!RavagerData.Variables.RFControl.TrackMimics)
            },
            Left: 550,
            Top: 570,
            Disabled: RavagerGetSetting("ravagerDisableMimic"),
            Text: "Track Mimics",
            IsChecked: RavagerData.Variables.RFControl.TrackMimics,
            enabled: !RavagerGetSetting("ravagerDisableMimic")
          },
          {
            name: "RFControlAnnounceRavagers",
            func: () => {
              RavagerData.functions.SetAnnounceRavagers(!RavagerData.Variables.RFControl.AnnounceRavagers)
            },
            Left: 550,
            Top: 644,
            Disabled: RavagerGetSetting("ravagerDisableBandit") && RavagerGetSetting("ravagerDisableWolfgirl") && RavagerGetSetting("ravagerDisableSlimegirl") && RavagerGetSetting("ravagerDisableTentaclePit") && RavagerGetSetting("ravagerDisableMimic"),
            Text: "Announce Ravagers",
            IsChecked: RavagerData.Variables.RFControl.AnnounceRavagers,
            enabled: !(RavagerGetSetting("ravagerDisableBandit") && RavagerGetSetting("ravagerDisableWolfgirl") && RavagerGetSetting("ravagerDisableSlimegirl") && RavagerGetSetting("ravagerDisableTentaclePit") && RavagerGetSetting("ravagerDisableMimic"))
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
            enabled: !RavagerGetSetting("ravagerDisableBandit")
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
        DrawTextFitKD("Ravager Controls", 1250, Ystart - 120, 1000, KDBaseWhite, undefined, 40)
        // Return button
        DrawButtonKDEx("RFCReturn", () => { RFDebug("[RFC] Leaving ravager control"); RavagerData.Variables.State = RavagerData.Variables.PrevState; RavagerData.Variables.DrawState = RavagerData.Variables.PrevDrawState; return true }, true, 975, 880, 550, 64, "Return", KDBaseWhite, undefined, undefined, false, false, undefined, undefined, undefined, { bordercolor: bordercolor })
        // Categories
        let confCategories = Object.keys(RavagerData.Definitions.FrameworkControls).splice(RavagerData.Variables.RFControl._CategoryPage * confRows, confRows) // Select just the page we are on
        // Draw category buttons
        confCategories.forEach((currentCategory) => {
          DrawButtonKDEx("RFCCat" + currentCategory, () => { console.log("[RFC] Pressed button for category " + currentCategory); RavagerData.Variables.RFControl._ConfPage = 0; RavagerData.Variables.RFControl._ConfCategory = currentCategory; return true }, true, Xstart, Y, 300, 64, currentCategory, KDBaseWhite, undefined, undefined, false, false, undefined, undefined, undefined, { bordercolor: bordercolor })
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
        if (RavagerData.Definitions.FrameworkControls.hasOwnProperty(RavagerData.Variables.RFControl._ConfCategory)) {
          let categoryConfs = RavagerData.Definitions.FrameworkControls[RavagerData.Variables.RFControl._ConfCategory]
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
              DrawCheckboxRFEx("RFCToggle_" + name, click, !blocking, Xstart + confXOffset + confSecondColumnOffset, Y, 64, 64, confEntry.label, checked, false, blocking ? "#888" : KDBaseWhite, undefined, { bordercolor: bordercolor })
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
              DrawTextFitKD(`${confEntry.label}: ${RavagerData.Variables.RFControl[confEntry.refvar]}`, Xstart + confXOffset + 64 + 190 + confSecondColumnOffset, Y + 32, 360, blocking ? "#888" : KDBaseWhite, undefined, 30)
              // Increment
              DrawButtonKDEx(`RFCRangeButtonR_${name}`, (bdata) => {
                if (RavagerData.Variables.RFControl[confEntry.refvar] < confEntry.rangehigh)
                  RavagerData.Variables.RFControl[confEntry.refvar] = parseFloat((RavagerData.Variables.RFControl[confEntry.refvar] + confEntry.stepcount).toFixed(significantDigits))
                if (typeof confEntry.postclick == "function")
                  confEntry.postclick(RavagerData.Variables.RFControl[confEntry.refvar])
                return true
              }, !blocking, Xstart + confXOffset + 64 + 360 + 20 + confSecondColumnOffset, Y, 64, 64, ">", blocking ? "#888" : KDBaseWhite, undefined, undefined, false, false, undefined, undefined, undefined, { bordercolor: bordercolor })
              Y += Ystep
            } else if (confEntry.type == "button") { // Custom button to run custom code when clicked
              let blocking = (typeof confEntry.block == "function") ? confEntry.block() : undefined
              DrawButtonKDEx(confEntry.name, confEntry.click, !blocking, Xstart + confXOffset + confSecondColumnOffset, Y, 370, 64, confEntry.label ? confEntry.label : confEntry.name, blocking ? "#888" : KDBaseWhite, confEntry.image, undefined, false, false, undefined, undefined, undefined, { bordercolor: bordercolor })
              Y += Ystep
            } else if (confEntry.type == "text") { // Just a label, no settings control
              let blocking = (typeof confEntry.block == "function") ? confEntry.block() : undefined
              DrawTextFitKD(confEntry.label, Xstart + confXOffset + 64 + 190 + confSecondColumnOffset, Y + 32, 480, blocking ? "#888" : KDBaseWhite, undefined, 30)
              Y += Ystep
            } else if (confEntry.type == "string") { // Text input
              // Custom get-value function; don't mind how wasteful this all is :)
              if (RavagerData.Variables.RFControl[confEntry.refvar] == undefined && typeof confEntry.getval == "function")
                RavagerData.Variables.RFControl[confEntry.refvar] = confEntry.getval()
              let elem = KDTextField(confEntry.refvar, Xstart + confXOffset + confSecondColumnOffset, Y, 480, 64, undefined, RavagerData.Variables.RFControl[confEntry.refvar], 100).Element
              elem.addEventListener("input", () => { RavagerData.Variables.RFControl[confEntry.refvar] = elem.value })
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
              DrawTextFitKD(`${confEntry.label ? confEntry.label : name}: ${RavagerData.Variables.RFControl[confEntry.refvar]}`, Xstart + confXOffset + 64 + 190 + confSecondColumnOffset, Y + 32, 360, blocking ? "#888" : KDBaseWhite, undefined, 30)
              // Increment
              DrawButtonKDEx(`RFCListButtonR_${name}`, (bdata) => {
                let newindex = (confEntry.options.indexOf(RavagerData.Variables.RFControl[confEntry.refvar]) + 1) == confEntry.options.length ? 0 : confEntry.options.indexOf(RavagerData.Variables.RFControl[confEntry.refvar]) + 1
                RavagerData.Variables.RFControl[confEntry.refvar] = confEntry.options[newindex]
                if (typeof confEntry.postclick == "function")
                  confEntry.postclick(RavagerData.Variables.RFControl[confEntry.refvar])
                return true
              }, !blocking, Xstart + confXOffset + 64 + 360 + 20 + confSecondColumnOffset, Y, 64, 64, ">", blocking ? "#888" : KDBaseWhite, undefined, undefined, false, false, undefined, undefined, undefined, { bordercolor: bordercolor })
              Y += Ystep
            }
            confCount++
            if (confCount == confRows) {
              confSecondColumnOffset = 550
              Y = Ystart
            }
          })
        }
      }
    },
    // Sets whether the mimic spoiler is guaranteed
    MimicExposure: function(exposed) {
      // Save the setting
      RavagerData.Variables.RFControl.ExposeMimics = exposed
      // Exit early if mimic is disabled
      if (RavagerGetSetting('ravagerDisableMimic')) {
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
    },
    MimicPassive: function(passive) {
      // Save the setting
      RavagerData.Variables.RFControl.PassiveMimics = passive
      // Early exit if mimic is disabled
      if (RavagerGetSetting("ravagerDisableMimic")) {
        RFDebug("[Ravager Framework][MimicPassive]: Mimic disabled. Nothing to do.")
        return
      }
      RFDebug("[Ravager Framework][MimicPassive]: Setting mimic passive to " + passive)
      // Find the mimic. If passive, set ambushRadius to 0.1, otherwise set to enemy's default
      KinkyDungeonEnemies.find(enemy =>
        enemy.addedByMod == "RavagerFramework" &&
        enemy.name == "MimicRavager"
      ).ambushRadius = (passive ? 0.1 : RavagerData.Definitions.Enemies.MimicRavager.ambushRadius)
    },
    TrackMimics: function(e, enemy, data) {
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
    },
    SetTrackMimics: function(tracked) {
      let enemy = KinkyDungeonEnemies.find(enemy =>
        enemy.addedByMod == "RavagerFramework" &&
        enemy.name == "MimicRavager"
      )
      if (tracked) {
        KDEventMapEnemy.tickAfter["RavagerFrameworkTrackMimics"] = RavagerData.functions.TrackMimics
        enemy.events.push({ trigger: "tickAfter", type: "RavagerFrameworkTrackMimics" })
      }
      else {
        delete KDEventMapEnemy.tickAfter.RavagerFrameworkTrackMimics
      }
      RavagerData.Variables.RFControl.TrackMimics = tracked
    },
    AnnounceRavagers: function(e, enemy, data) {
      RFDebug(`[Ravager Framework][AnnounceRavagers]: { ${KinkyDungeonCurrentTick} }  ${enemy.Enemy.name} (id ${enemy.id}) at (${enemy.x}, ${enemy.y})`)
      // Count ravagers for post-tick message
      if (!RavagerData.Variables.RavagerCount)
        RavagerData.Variables.RavagerCount = {}
      if (!RavagerData.Variables.RavagerCount[enemy.Enemy.name])
        RavagerData.Variables.RavagerCount[enemy.Enemy.name] = 1
      else
        RavagerData.Variables.RavagerCount[enemy.Enemy.name]++
    },
    SetAnnounceRavagers: function(enabled) {
      RFDebug(`[Ravager Framework][RFControl][SetAnnounceRavagers]: Setting ravager announcement to ${enabled} ...`)
      let enemies = KinkyDungeonEnemies.filter(enemy => enemy.addedByMod == "RavagerFramework")
      if (enabled) {
        KDEventMapGeneric.tick.RavagerFrameworkTrackPlayer = function(e, data) { RFDebug(`[Ravager Framework][TrackPlayer]: Player at (${KinkyDungeonPlayerEntity.x}, ${KinkyDungeonPlayerEntity.y})`); }
        KDEventMapGeneric.before
        KDEventMapEnemy.tickAfter["RavagerFrameworkAnnounceRavagers"] = RavagerData.functions.AnnounceRavagers
        for (let e of enemies)
          e.events.push({ trigger: "tickAfter", type: "RavagerFrameworkAnnounceRavagers" })
        // Enable post-tick announce message in text log
        RavagerData.functions.KinkyDungeonAdvanceTime = KinkyDungeonAdvanceTime
        window.KinkyDungeonAdvanceTime = RavagerData.functions.RavagerFrameworkAdvanceTime
      } else {
        delete KDEventMapGeneric.tick.RavagerFrameworkTrackPlayer
        delete KDEventMapEnemy.tickAfter.RavagerFrameworkAnnounceRavagers
        // Disable post-tick announce message in text log
        window.KinkyDungeonAdvanceTime = RavagerData.functions.KinkyDungeonAdvanceTime
      }
      RavagerData.Variables.RFControl.AnnounceRavagers = enabled
    },
    // Wrapper for KinkyDungeonAdvanceTime to add post-tick ravager count messages
    RavagerFrameworkAdvanceTime: function(...args) {
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
        var actionMsg = ""
        var consoleMsg = "[Ravager Count]: { "
        for (var e of Object.entries(count)) {
          var [k, v] = e
          actionMsg += `${k.substring(0, 4)}: ${v}, `
          consoleMsg += `${k}: ${v}, `
        }
        actionMsg = actionMsg.substring(0, actionMsg.length - 2)
        consoleMsg = consoleMsg.substring(0, consoleMsg.length - 2) + " }"
        KinkyDungeonSendActionMessage(100000, actionMsg, "#f6f", 1)
        RFDebug(consoleMsg)
      }
      // Clear ravager count
      RavagerData.Variables.RavagerCount = {}
    },
    // Custom version of KinkyDungeonGetRestraint so I can have name-based exclusions and per-item weight modifiers
    // All the same params as KinkyDungeonGetRestraint, but with the addition of:
    //   - `exclude` as an array of strings that are restraint names, which should not be chosen
    //   - `weightMods` as a dictionary with the keys being restraint names and the values being a number to multiply that restraint's weight by
    // Also want to add some weight modifiers
    GetRandomRestraint: function(enemy, Level, Index, exclude, weightMods, Bypass, Lock, RequireWill, LeashingOnly, NoStack, extraTags, agnostic, filter, securityEnemy, curse, useAugmented, augmentedInventory, options) {
      RFTrace("[Ravager Framework][DBG][RFGetRestraint]: Starting RFGetRestraint(enemy: ", enemy, "; Level: ", Level, "; Index: ", Index, "; exclude: ", exclude, "; weightMods: ", weightMods, "; Bypass: ", Bypass, "; Lock: ", Lock, "; RequireWill: ", RequireWill, "; LeashingOnly: ", LeashingOnly, "; NoStack: ", NoStack, "; extraTags: ", extraTags, "; agnostic: ", agnostic, "; filter: ", filter, "; securityEnemy: ", securityEnemy, "; curse: ", curse, "; useAugmented: ", useAugmented, "; augmentedInventory: ", augmentedInventory, "; options: ", options)
      // Starting weight stuff
      let restraintWeightTotal = 0;
      let restraintWeights = [];
      // Get restraints
      let Restraints = KDGetRestraintsEligible(enemy, Level, Index, Bypass, Lock, RequireWill, LeashingOnly, NoStack, extraTags, agnostic, filter, securityEnemy, curse, undefined, undefined, useAugmented, augmentedInventory, options);
      RFTrace("[Ravager Framework][DBG][RFGetRestraint]: Eligible restraints: ", Restraints)
      for (let rest of Restraints) {
        let restraint = rest.restraint;
        RFTrace(`[Ravager Framework][DBG][RFGetRestraint]: Processing restraint ${restraint.name}: `, rest)
        // Skip restraints in exclude
        if (exclude && exclude.includes(restraint.name)) {
          RFTrace("[Ravager Framework][DBG][RFGetRestraint]: Skipping excluded restraint")
          continue
        }
        // Base weight
        let weight = rest.weight;
        RFTrace("[Ravager Framework][DBG][RFGetRestraint]: Base weight: ", weight)
        // Modify weight if this restraint has a modifier in weightMods
        if (weightMods && Object.keys(weightMods).includes(restraint.name) && typeof weightMods[restraint.name] == "number") {
          weight = weight * weightMods[restraint.name]
          RFTrace(`[Ravager Framework][DBG][RFGetRestraint]: Modifying weight of ${restraint.name} (X${weightMods[restraint.name]}); New weight: ${weight}`)
        }
        // Push the weight and update weight total
        restraintWeights.push({restraint: restraint, weight: restraintWeightTotal, inventoryVariant: rest.inventoryVariant});
        restraintWeightTotal += Math.max(0, weight);
      }
      // Decide a random number within the range of weights
      let selection = KDRandom() * restraintWeightTotal;
      RFTrace(`[Ravager Framework][DBG][RFGetRestraint]: Restraint weight total: ${restraintWeightTotal}; Restraints: `, restraintWeights, `; Selection: ${selection}`)
      // Pick the first restraint whose weight is less then the number in `selection`
      for (let L = restraintWeights.length - 1; L >= 0; L--) {
        if (selection > restraintWeights[L].weight) {
          RFTrace(`[Ravager Framework][DBG][RFGetRestraint]: Decided restraint. L: ${L}; `, restraintWeights[L])
          return restraintWeights[L].restraint;
        }
      }
      RFTrace("[Ravager Framework][DBG][RFGetRestraint]: Looks like there's no restraints left to return. End of RFGetRestraint.")
    },
    // Check if we're missing any functions
    CheckAllFunctions: function() {
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
      backdrop.id = "ravager-framework-missing-functions-popup"
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
      heading.appendChild(document.createTextNode("Ravager Alert"))
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
      modal.appendChild(KinkyDungeonErrorPreamble([
        "It appears that your game is missing a few functions that the Ravager Framework uses to function.",
        "This is most likely caused by the game updating and renaming / removing some functions."
      ]))
      modal.appendChild(KinkyDungeonErrorPreamble([
        "These functions not being present may result in issues.",
        "The severity of these issues can't be known by this message, but can range anywhere between unexpected behavior and full game crashes."
      ]))

      modal.appendChild(KinkyDungeonErrorPreamble([
        "While it would be best to report these missing functions as an issue, it may be possible to resolve the issue by enabling Kinky Dungeon's \"Mod Compat Mode\" option."
      ]))
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
      pre.textContent = "Missing functions: " + missingFunctions
      modal.appendChild(pre)
      // Close button
      const closeButton = document.createElement("button")
      closeButton.textContent = "Close"
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
      return false
    },
    GetFunctionOverrides: function() {
      let funcs = {}
      for (let key of Object.keys(RavagerData.functions))
        if (key.match(/(KinkyDungeo.*|.*KD.*)/))
          funcs[key] = LZString.compressToBase64(RavagerData.functions[key].toString())
      return funcs
    },
    SaveFunctionOverrides: function() {
      let funcs = RavagerData.functions.GetFunctionOverrides()
      const element = document.createElement("a")
      element.setAttribute("href", `data:application/json;charset=utf-8,${encodeURIComponent(JSON.stringify(funcs, undefined, '  '))}`)
      element.setAttribute("download", `RavagerFramework_FunctionOverrides_KD${TextGetKD("KDVersionStr")}_RF${RavagerData.ModInfo.modbuild}.json`)
      element.click()
    },
    CheckFunctionOverrides: function() {
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
            const currData = RavagerData.functions.GetFunctionOverrides()
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
    },
  },
  // Currently just used for the MimicRavager spoiler
  conditions: {
    // Checked to make the MimicRavager spoiler only show when the mimic has not ambushed the player
    mimicRavSpoiler: enemy => !enemy.ambushtrigger
  },
  // Default strings
  defaults: {
    releaseMessage: "You feel weak as EnemyCName releases you...",
    passoutMessage: "Your body is broken and exhausted...",
    restraintTearMessage: "EnemyCName tears your RestraintName away!",
    clothingTearMessage: "EnemyCName tears your ClothingName away!",
    pinMessage: "EnemyCName gets a good grip on you...",
    addRestraintMessage: "EnemyCName forces you to wear a RestraintName",
    fallbackNarration: "EnemyCName roughly gropes you! (DamageTaken)",
  },
  // Default mod settings values
  ModConfig: {
    ravagerDebug: {
      type: 'boolean',
      refvar: 'ravagerDebug',
      hoverDesc: "Print verbose messages to the browser console",
      textKeyVal: "Enable Debug Messages"
    },
    ravagerDisableBandit: {
      type: 'boolean',
      refvar: 'ravagerDisableBandit',
      textKeyVal: "Disable Bandit Ravager"
    },
    ravagerDisableWolfgirl: {
      type: 'boolean',
      refvar: 'ravagerDisableWolfgirl',
      textKeyVal: "Disable Wolfgirl Ravager"
    },
    ravagerDisableSlimegirl: {
      type: 'boolean',
      refvar: 'ravagerDisableSlimegirl',
      textKeyVal: "Disable Silmegirl Ravager"
    },
    ravagerDisableTentaclePit: {
      type: 'boolean',
      refvar: 'ravagerDisableTentaclePit',
      textKeyVal: "Disable Tentacle Pit"
    },
    ravagerDisableMimic: {
      type: 'boolean',
      refvar: 'ravagerDisableMimic',
      textKeyVal: "Disable Mimic Ravager"
    },
    ravagerSpicyTendril: {
      type: 'boolean',
      refvar: 'ravagerSpicyTendril',
      hoverDesc: "Enables some more questionable dialogue for the ravagers that may not be for everyone",
      textKeyVal: "Spicy Ravager Dialogue"
    },
    ravagerSlimeAddChance: {
      type: 'range',
      name: 'ravagerSlimeAddChance', // A workaround for the game's code requiring ranges to have a name property for all but the last range; should be temporary
      refvar: 'ravagerSlimeAddChance',
      default: 0.05,
      rangelow: 0,
      rangehigh: 1,
      stepcount: 0.01,
      hoverDesc: "The chance of the slime girl to add slime to you. Setting this too high would cause significant difficulty, as this chance is rolled on every attack, including during ravaging.",
      textKeyVal: "Slimegirl Restrict Chance"
    },
    ravagerEnableSound: {
      type: 'boolean',
      refvar: 'ravagerEnableSound',
      default: true,
      hoverDesc: "Enable moans when getting hit and orgasming. Note: This will have no effect if the Girl Sound mod is loaded.",
      textKeyVal: "Enable Sounds"
    },
    onHitChance: {
      type: 'range',
      name: 'onHitChance', // A workaround for the game's code requiring ranges to have a name property for all but the last range; should be temporary
      refvar: 'onHitChance',
      default: 0.3,
      rangelow: 0,
      rangehigh: 1,
      stepcount: 0.05,
      hoverDesc: "The chance to moan when getting hit.",
      textKeyVal: "Moan Chance"
    },
    ravagerSoundVolume: {
      type: 'range',
      name: 'ravagerSoundVolume', // A workaround for the game's code requiring ranges to have a name property for all but the last range; should be temporary
      refvar: 'ravagerSoundVolume',
      rangelow: 0,
      rangehigh: 2,
      stepcount: 0.05,
      hoverDesc: "The volume of moans",
      textKeyVal: "Moan Volume"
    },
    ravEnableUseCount: {
      type: 'boolean',
      refvar: 'ravEnableUseCount',
      default: true,
      hoverDesc: "Enable special dialogue based on how many times you've been ravaged before.",
      textKeyVal: "Enable Experience Aware Mode"
    },
    ravUseCountMode: {
      type: 'list',
      name: 'ravUseCountMode', // Needed for proper declaration of the left and right selection buttons
      refvar: 'ravUseCountMode',
      options: [ 'Any', 'Sometimes', 'Always' ],
      default: 'Any',
      hoverDesc: "Should experience aware dialogue be used sometimes, always, or do you not have a preference? Can be overridden by a ravager wanting a specific mode.",
      textKeyVal: "Exp Aware Mode"
    },
    ravUseCountModeChance: {
      type: 'range',
      name: 'ravUseCountModeChance',
      refvar: 'ravUseCountModeChance',
      default: 0.75,
      rangelow: 0,
      rangehigh: 1,
      stepcount: 0.05,
      hoverDesc: "Chance to use experience aware dialogue.",
      textKeyVal: "Exp Aware Chance"
    },
    ravUseCountOverride: {
      type: 'boolean',
      refvar: 'ravUseCountOverride',
      hoverDesc: "Overrides ravagers wanting a specific experience aware mode. With this enabled, all ravagers will follow your Exp Aware Mode setting. Note: None of the framework's ravagers prefer one mode or the other, so this setting only matters if you're using an external ravager mod that has ravagers that do have a preference.",
      textKeyVal: "Override Exp Aware Mode"
    },
    ravagerCustomDrop: {
      type: "boolean",
      refvar: "ravagerCustomDrop",
      default: true,
      hoverDesc: "Allow ravagers to use custom item drop behaviors, which enables dropping random quantaties of multiple items. If enemies stop dropping items, try disabling this, as it may have broken due to a game update.",
      textKeyVal: "Enable Multi-item Drops"
    },
    ravagerEnableNudeOutfit: {
      type: "boolean",
      refvar: "ravagerEnableNudeOutfit",
      hoverDesc: 'Allow ravagers to fully strip you when passing out, instead of leaving you minimally clothed.',
      textKeyVal: "Enable Full Nude"
    },
    ravagerFancyFont: {
      type: "boolean",
      refvar: "ravagerFancyFont",
      hoverDesc: "Who doesn't like a fancy font in their help messages?",
      textKeyVal: "Custom font for help"
    },
    ravagerHelpDebug: {
      type: "boolean",
      refvar: "ravagerHelpDebug",
      hoverDesc: "Turn on heavy debugging mode so that you can provide a log file to help CTN with tracking down bugs. Turning this on will begin saving all of the framework's console messages to memory. To save the log to a file, return to this menu and disable this setting, or enter the Ravager Hacking menu and click End Debug Log.",
      textKeyVal: "I want to help debug"
    },
  },
  // Copy of mod info; default values incase reading reading mod.json fails
  ModInfo: {
    author: "UNKNOWN",
    fileorder: [],
    gamemajor: -1,
    gameminor: -1,
    gamepatch_max: -1,
    gamepatch_min: -1,
    modbuild: "UNKNOWN",
    moddesc: "UNKNOWN",
    modname: "UNKNOWN",
    priority: -1
  },
  // TODO: Try to keep this up to date over time
  // List of all the game functions the framework relies on
  FunctionsThatMightBeMissing: [
    "KDistChebyshev", // Used by RFPlayerCanSeeEnemy
    "AudioPlayInstantSoundKD", // This and below were found via find-functions.py. Some may be missing
    "GetModelLayers",
    "KDAdvanceSlime",
    "KDBreakTether",
    "KDCanAddRestraint",
    "KDCanSeeEnemy",
    "KDChangeDistraction",
    "KDCurrIndex",
    "KDDraw",
    "KDGetDressList",
    "KDGetEffLevel",
    "KDGetFontMult",
    "KDGetJailRestraints",
    "KDGetRestraintsEligible",
    "KDMapInit",
    "KDNearbyEnemies",
    "KDRandom",
    "KDRemoveEntity",
    "KDRestraint",
    "KDStunTurns",
    "KinkyDungeonAddRestraintIfWeaker",
    "KinkyDungeonAddRestraintText",
    "KinkyDungeonApplyBuffToEntity",
    "KinkyDungeonCastSpell",
    "KinkyDungeonDealDamage",
    "KinkyDungeonDoTryOrgasm",
    "KinkyDungeonDressPlayer",
    "KinkyDungeonGetRestraint",
    "KinkyDungeonGetRestraintByName",
    "KinkyDungeonGetRestraintItem",
    "KinkyDungeonInterruptSleep",
    "KinkyDungeonItemDrop",
    "KinkyDungeonMakeNoise",
    "KinkyDungeonPassOut",
    "KinkyDungeonRefreshEnemiesCache",
    "KinkyDungeonRemoveRestraint",
    "KinkyDungeonRemoveRestraintSpecific",
    "KinkyDungeonRemoveRestraintsWithName",
    "KinkyDungeonSendActionMessage",
    "KinkyDungeonSendDialogue",
    "KinkyDungeonSendFloater",
    "KinkyDungeonSendTextMessage",
    "KinkyDungeonSetDress",
    "KinkyDungeonSetFlag",
    "KinkyDungeonVisionGet",
    "KinkyDungeonWordWrap",
    "MouseIn",
    "PIXI.Texture.fromURL",
    "TextGet",
    "TextGetKD",
    "ToLayerMap",
    "addTextKey"
  ],
  // Stores enemy definitions
  Definitions: {
    Enemies: {},
    Spells: {},
    Fonts: {
      "Once Upon A Time Italic": {
        alias: "Once Upon A Time Italic",
        src: "Game/Fonts/once_upon_a_time/Once upon a time-Italic.otf",
        mono: false,
        width: 1
      }
    },
    FontFaces: {},
    FrameworkControls: {
      // Categories of controls shown during RFControl. Built similar to mod configs with tabs and scrolling
      Debugging: [
        {
          name: "HeavyDebug",
          type: "boolean",
          onclick: () => { RavagerFrameworkToggleDebug(); return true },
          block: undefined,
          checked: () => { return _RavagerFrameworkDebugEnabled },
          label: "Heavy Debugging"
        },
        {
          refvar: "NameFormatDebug",
          type: "boolean",
          label: "Debug NameFormat function"
        },
        {
          refvar: "ExposeMimics",
          type: "boolean",
          label: "Expose Mimics",
          postclick: (val) => { return RavagerData.functions.MimicExposure(val); },
          block: () => RavagerGetSetting("ravagerDisableMimic")
        },
        {
          refvar: "PassiveMimics",
          type: "boolean",
          label: "Oblivious Mimics",
          postclick: (val) => { return RavagerData.functions.MimicPassive(val); },
          block: () => RavagerGetSetting("ravagerDisableMimic")
        },
        {
          name: "RevertFunctions",
          type: "button",
          click: () => { RavagerFrameworkRevertFunctions(); return true; },
          label: "Revert Functions"
        },
        {
          refvar: "TrackMimics",
          type: "boolean",
          label: "Track Mimics",
          postclick: (val) => { return RavagerData.functions.SetTrackMimics(val); },
          block: () => RavagerGetSetting("ravagerDisableMimic")
        },
        {
          refvar: "AnnounceRavagers",
          type: "boolean",
          label: "Announce Ravagers",
          postclick: (val) => { return RavagerData.functions.SetAnnounceRavagers(val); },
          block: () => RavagerGetSetting("ravagerDisableBandit") && RavagerGetSetting("ravagerDisableWolfgirl") && RavagerGetSetting("ravagerDisableSlimegirl") && RavagerGetSetting("ravagerDisableTentaclePit") && RavagerGetSetting("ravagerDisableMimic")
        },
        {
          refvar: "DebugVanillaTextOverrides",
          type: "boolean",
          label: "Debug Text Replacements",
        },
        {
          name: "EndDebugLog",
          type: "button",
          label: "End Debug Log",
          click: () => { KDModSettings.RavagerFramework.ravagerHelpDebug = false; RavagerFrameworkIWantToHelpDebug('Finish'); return true; },
          block: () => !KDModSettings?.RavagerFramework?.ravagerHelpDebug
        },
        {
          name: "SaveFunctionOverrides",
          type: "button",
          label: "Save Overridden Functions",
          click: () => { RavagerData.functions.SaveFunctionOverrides(); return true; }
        },
        {
          name: "CheckFunctionOverrides",
          type: "button",
          label: "Check Overridden Functions",
          click: () => { RavagerData.functions.CheckFunctionOverrides(); return true; }
        },
        {
          refvar: "ControlBanditsFirstLevel",
          type: "boolean",
          label: "Control 1st lvl Bandit #s",
          default: true,
          block: () => RavagerGetSetting("ravagerDisableBandit")
        },
        {
          refvar: "UseOldRFControl",
          type: "boolean",
          label: "Use old RFControl layout",
          default: false
        },
      ],
      Customization: [
        {
          type: "text",
          label: "Border Color"
        },
        {
          refvar: "Customization_BorderColor",
          type: "string"
        },
        // Need background and possibly others
        {
          refvar: "Customization_Background",
          type: "list",
          label: "Background",
          default: "Dark",
          options: [ "Dark", "Bright" ],
          postclick: (val) => { RavagerData.Variables.RFControl.Background = "RFControl" + val }
        },
      ],
      Bandit: [
        {
          name: "EnemyApply",
          type: "button",
          label: "Apply Changes",
          click: () => { RFInfo("[RFC] Refreshing enemy cache..."); KinkyDungeonRefreshEnemiesCache(); return true },
          block: () => RavagerGetSetting('ravagerDisableBandit')
        },
        {
          refvar: "Bandit_SpawnW8",
          type: "range",
          label: "Spawn Weight",
          rangehigh: 20,
          rangelow: -20,
          stepcount: 0.1,
          getval: () => KinkyDungeonEnemies.find(v => v.name == "BanditRavager").weight,
          postclick: (val) => { KinkyDungeonEnemies.find(v => v.name == "BanditRavager").weight = val },
          block: () => RavagerGetSetting('ravagerDisableBandit')
        },
        {
          refvar: "MaxStartingBandits",
          type: "range",
          label: "Lvl 1 Max Count",
          rangehigh: 50,
          rangelow: 0,
          stepcount: 1,
          // getval: () => RavagerData.Variables.MaxStartingBandits,
          // postclick: (val)
          block: () => RavagerGetSetting('ravagerDisableBandit')
        },
      ],
      Wolfgirl: [
        {
          name: "EnemyApply",
          type: "button",
          label: "Apply Changes",
          click: () => { RFInfo("[RFC] Refreshing enemy cache..."); KinkyDungeonRefreshEnemiesCache(); return true },
          block: () => RavagerGetSetting('ravagerDisableWolfgirl')
        },
        {
          refvar: "Wolf_SpawnW8",
          type: "range",
          label: "Spawn Weight",
          rangehigh: 20,
          rangelow: -20,
          stepcount: 0.1,
          getval: () => KinkyDungeonEnemies.find(v => v.name == "WolfgirlRavager").weight,
          postclick: (val) => { KinkyDungeonEnemies.find(v => v.name == "WolfgirlRavager").weight = val },
          block: () => RavagerGetSetting('ravagerDisableWolfgirl')
        },
      ],
      Slimegirl: [
        {
          name: "EnemyApply",
          type: "button",
          label: "Apply Changes",
          click: () => { RFInfo("[RFC] Refreshing enemy cache..."); KinkyDungeonRefreshEnemiesCache(); return true },
          block: () => RavagerGetSetting('ravagerDisableSlimegirl')
        },
        {
          refvar: "Slime_SpawnW8",
          type: "range",
          label: "Spawn Weight",
          rangehigh: 20,
          rangelow: -20,
          stepcount: 0.1,
          getval: () => KinkyDungeonEnemies.find(v => v.name == "SlimeRavager").weight,
          postclick: (val) => { KinkyDungeonEnemies.find(v => v.name == "SlimeRavager").weight = val },
          block: () => RavagerGetSetting('ravagerDisableSlimegirl')
        },
      ],
      Tentacle: [
        {
          name: "EnemyApply",
          type: "button",
          label: "Apply Changes",
          click: () => { RFInfo("[RFC] Refreshing enemy cache..."); KinkyDungeonRefreshEnemiesCache(); return true },
          block: () => RavagerGetSetting('ravagerDisableWolfgirl')
        },
        {
          refvar: "Tentacle_SpawnW8",
          type: "range",
          label: "Spawn Weight",
          rangehigh: 20,
          rangelow: -20,
          stepcount: 0.1,
          getval: () => KinkyDungeonEnemies.find(v => v.name == "TentaclePit").weight,
          postclick: (val) => { KinkyDungeonEnemies.find(v => v.name == "TentaclePit").weight = val },
          block: () => RavagerGetSetting('ravagerDisableTentaclePit')
        },
      ],
      Mimic: [
        {
          name: "EnemyApply",
          type: "button",
          label: "Apply Changes",
          click: () => { RFInfo("[RFC] Refreshing enemy cache..."); KinkyDungeonRefreshEnemiesCache(); return true },
          block: () => RavagerGetSetting('ravagerDisableWolfgirl')
        },
        {
          refvar: "Mimic_SpawnW8",
          type: "range",
          label: "Spawn Weight",
          rangehigh: 20,
          rangelow: -20,
          stepcount: 0.1,
          getval: () => KinkyDungeonEnemies.find(v => v.name == "MimicRavager").weight,
          postclick: (val) => { KinkyDungeonEnemies.find(v => v.name == "MimicRavager").weight = val },
          block: () => RavagerGetSetting('ravagerDisableMimic')
        },
      ],
    },
  },
  // Variable, general purpose data
  Variables: {
    // Tracks the state of mimic exposure
    ExposeMimics: false,
    // Runtime user-modifiable values for controlling the placement of a custom button; only in use when developing new buttons
    TestButton: {
      Left: 550,
      Top: 274,
      Width: 300,
      Height: 64
    },
    // Same as TestButton, but for labels
    TestLabel: {
      Container: kdcanvas,
      Map: kdpixisprites,
      id: "RFTestingRect",
      Params: {
        Left: canvasOffsetX,
        Top: canvasOffsetY,
        Width: KinkyDungeonCanvas.width,
        Height: KinkyDungeonCanvas.height,
        Color: "#ff4444",
        LineWidth: 2,
        zIndex: 10
      }
    },
    ModConfig: {
      BoxData: {},
      Desc: {
        FontSize: 34,
        Font: "Once Upon A Time Italic"
      },
      Box: {
        PadV: 25,
        PadH: 10,
        XOffset: 68,
      }
    },
    // Relating to the ravager control menu
    RFControl: {
      Background: "RFControlDark",
      InGameEnabled: false,
      WasEnabledInGame: false,
      PassiveMimics: false,
      NameFormatDebug: false,
      TrackMimics: false,
      AnnounceRavagers: false,
      DebugVanillaTextOverrides: false,
      ControlBanditsFirstLevel: true,
      // Max number of bandit ravs on floor 1
      MaxStartingBandits: 2,
      _ConfCategory: "Main", // Hold the current RFControl tab we're in
      _CategoryPage: 0, // Operates as KDModListPage, for scrolling through category tabs in RFControl
      _ConfPage: 0, // The page of the current RFControl category we're on
      Customization_BorderColor: "#6100cf"
    },
    DebugWasTurnedOn: false,
    DebugWasTurnedOff: false,
    MimicBurstPossibleDress: [ "Leotard", "GreenLeotard", "Bikini", "Lingerie" ],
    IWantToHelpDebug: false,
    IWantToHelpDebugBuffer: []
  }
}

// Slots that need to be stripped to occupy a given slot; slots to clear are in order
// TODO: Move this to RavagerData, to allow external ravager mods to define another slot if they wish
window.ravageEquipmentSlotTargets = {
  ItemButt: ["ItemPelvis", "ItemButt"],
  ItemVulva: ["ItemPelvis", "ItemVulva"],
  ItemMouth: ["ItemHead", "ItemMouth"],
  ItemHead: ["ItemHead"]
}
