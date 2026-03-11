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
          RFTrace('[Ravager Framework][RavagerSoundHit]: enableSound: ', RFGetSetting('ravagerEnableSound'), '\nvolume: ', RFGetSetting('ravagerSoundVolume') / 2, '\nonHitChance: ', RFGetSetting('onHitChance'))
          // Might play a sound
          if (KDToggles.Sound && RFGetSetting('ravagerEnableSound') && Math.random() < RFGetSetting('onHitChance')) {
            AudioPlayInstantSoundKD(KinkyDungeonRootDirectory + "Audio/" + (KinkyDungeonGagTotal() > 0 ? "Angry21 liliana.ogg" : "Ah1 liliana.ogg"), RFGetSetting('ravagerSoundVolume') / 2)
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
          if (KDToggles.Sound && RFGetSetting('ravagerEnableSound')) {
            AudioPlayInstantSoundKD(KinkyDungeonRootDirectory + "Audio" + (KinkyDungeonGagTotal > 0 ? "GagOrgasm.ogg" : "Ah1 liliana.ogg"), RFGetSetting('ravagerSoundVolume') / 2)
          }
          // Text log message
          KinkyDungeonSendTextMessage(8, RFGetText("OrgasmLine"), "#1fffc7", 1);
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
    // Compatibility reference to RFStringFormat
    NameFormat: (...args) => { return window.RFStringFormat(...args); },
    // Compatibility reference to RFGetRestraint
    GetRandomRestraint: (...args) => { return RFGetRestraint(...args); },
  },
  // Currently just used for the MimicRavager spoiler
  conditions: {
    // Checked to make the MimicRavager spoiler only show when the mimic has not ambushed the player
    mimicRavSpoiler: enemy => !enemy.ambushtrigger
  },
  // Default mod settings values
  ModConfig: {
    ravagerDebug: {
      type: 'boolean',
      refvar: 'ravagerDebug',
    },
    ravagerDisableBandit: {
      type: 'boolean',
      refvar: 'ravagerDisableBandit',
    },
    ravagerDisableWolfgirl: {
      type: 'boolean',
      refvar: 'ravagerDisableWolfgirl',
    },
    ravagerDisableSlimegirl: {
      type: 'boolean',
      refvar: 'ravagerDisableSlimegirl',
    },
    ravagerDisableTentaclePit: {
      type: 'boolean',
      refvar: 'ravagerDisableTentaclePit',
    },
    ravagerDisableMimic: {
      type: 'boolean',
      refvar: 'ravagerDisableMimic',
    },
    ravagerSpicyTendril: {
      type: 'boolean',
      refvar: 'ravagerSpicyTendril',
    },
    ravagerSlimeAddChance: {
      type: 'range',
      name: 'ravagerSlimeAddChance', // A workaround for the game's code requiring ranges to have a name property for all but the last range; should be temporary
      refvar: 'ravagerSlimeAddChance',
      default: 0.05,
      rangelow: 0,
      rangehigh: 1,
      stepcount: 0.01,
    },
    ravagerEnableSound: {
      type: 'boolean',
      refvar: 'ravagerEnableSound',
      default: true,
    },
    onHitChance: {
      type: 'range',
      name: 'onHitChance', // A workaround for the game's code requiring ranges to have a name property for all but the last range; should be temporary
      refvar: 'onHitChance',
      default: 0.3,
      rangelow: 0,
      rangehigh: 1,
      stepcount: 0.05,
    },
    ravagerSoundVolume: {
      type: 'range',
      name: 'ravagerSoundVolume', // A workaround for the game's code requiring ranges to have a name property for all but the last range; should be temporary
      refvar: 'ravagerSoundVolume',
      rangelow: 0,
      rangehigh: 2,
      stepcount: 0.05,
    },
    ravEnableUseCount: {
      type: 'boolean',
      refvar: 'ravEnableUseCount',
      default: true,
    },
    ravUseCountMode: {
      type: 'list',
      name: 'ravUseCountMode', // Needed for proper declaration of the left and right selection buttons
      refvar: 'ravUseCountMode',
      options: [ 'Any', 'Sometimes', 'Always' ],
      default: 'Any',
    },
    ravUseCountModeChance: {
      type: 'range',
      name: 'ravUseCountModeChance',
      refvar: 'ravUseCountModeChance',
      default: 0.75,
      rangelow: 0,
      rangehigh: 1,
      stepcount: 0.05,
    },
    ravUseCountOverride: {
      type: 'boolean',
      refvar: 'ravUseCountOverride',
    },
    ravagerCustomDrop: {
      type: "boolean",
      refvar: "ravagerCustomDrop",
      default: true,
    },
    ravagerEnableNudeOutfit: {
      type: "boolean",
      refvar: "ravagerEnableNudeOutfit",
    },
    ravagerFancyFont: {
      type: "boolean",
      refvar: "ravagerFancyFont",
    },
    ravagerHelpDebug: {
      type: "boolean",
      refvar: "ravagerHelpDebug",
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
    // Some might be missing, since creation of this list relies on a custom python script
    "addTextKey",
    "AudioPlayInstantSoundKD",
    "DrawButtonKDEx",
    "DrawCheckboxKDEx",
    "DrawTextFitKD",
    "FileReader",
    "GetModelLayers",
    "KDAdvanceSlime",
    "KDBreakTether",
    "KDCanAddRestraint",
    "KDCanSeeEnemy",
    "KDChangeDistraction",
    "KDChangeStamina",
    "KDChangeWill",
    "KDCurrIndex",
    "KDDraw",
    "KDGetDressList",
    "KDGetEffLevel",
    "KDGetFontMult",
    "KDGetJailRestraints",
    "KDGetRestraintsEligible",
    "KDInitTileEditor",
    "KDistChebyshev",
    "KDMapInit",
    "KDNearbyEnemies",
    "KDPlayerTitlesRefreshCategories",
    "KDRandom",
    "KDRemoveEntity",
    "KDRemoveThisItem",
    "KDRestraint",
    "KDStunTurns",
    "KDTE_CloseUI",
    "KDTE_ExportTile",
    "KDTextField",
    "KinkyDungeonAddRestraintIfWeaker",
    "KinkyDungeonApplyBuffToEntity",
    "KinkyDungeonCastSpell",
    "KinkyDungeonChangeRep",
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
    "KinkyDungeonStartNewGame",
    "KinkyDungeonVisionGet",
    "KinkyDungeonWordWrap",
    "LZString.compressToBase64",
    "MouseIn",
    "PIXI.Texture.fromURL",
    "string2hex",
    "TextGet",
    "TextGetKD",
    "textProvider.getTextFromGroupStrict",
    "ToLayerMap",
    "URL.revokeObjectURL"
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
      Debug: [
        {
          name: "HeavyDebug",
          type: "boolean",
          onclick: () => { RavagerFrameworkToggleDebug(); return true },
          checked: () => { return _RavagerFrameworkDebugEnabled },
        },
        {
          refvar: "NameFormatDebug",
          type: "boolean",
        },
        {
          refvar: "DebugVanillaTextOverrides",
          type: "boolean",
        },
        {
          refvar: "AnnounceRavagers",
          type: "boolean",
          postclick: (val) => { return RavagerFrameworkSetRavagerCounting(val); },
          block: () => RFGetSetting("ravagerDisableBandit") && RFGetSetting("ravagerDisableWolfgirl") && RFGetSetting("ravagerDisableSlimegirl") && RFGetSetting("ravagerDisableTentaclePit") && RFGetSetting("ravagerDisableMimic")
        },
        {
          type: "padding"
        },
        {
          name: "SaveFunctionOverrides",
          type: "button",
          click: () => { RavagerFrameworkSaveFunctionOverrides(); return true; }
        },
        {
          name: "CheckFunctionOverrides",
          type: "button",
          click: () => { RavagerFrameworkCheckFunctionOverrides(); return true; }
        },
        {
          type: "padding"
        },
        {
          name: "RevertFunctions",
          type: "button",
          click: () => { RavagerFrameworkRevertFunctions(); return true; },
        },
        {
          name: "EndDebugLog",
          type: "button",
          click: () => { KDModSettings.RavagerFramework.ravagerHelpDebug = false; RavagerFrameworkIWantToHelpDebug('Finish'); return true; },
          block: () => !KDModSettings?.RavagerFramework?.ravagerHelpDebug
        },
        {
          refvar: "UseOldRFControl",
          type: "boolean",
          label: "Use old RFControl layout",
          default: false
        },
        {
          type: "padding"
        },
        {
          type: "padding"
        },
        {
          type: "padding"
        },
        {
          type: "padding"
        },
        {
          // This just completely breaks when reloading data.ks; it would take a major rework to fix, since this file just fully replaces window.RavagerData, leading to stack overlows, since our function overrides get set to themselves
          // This is also very dangerous, as it literally just calls eval on any file chosen
          type: "button",
          name: "ImportJS",
          block: () => !(_RavagerFrameworkDebugEnabled && RavagerData.Variables.RFControl.NameFormatDebug && RavagerData.Variables.RFControl.DebugVanillaTextOverrides && RavagerData.Variables.RFControl.AnnounceRavagers),
          click: () => {
            let input = document.createElement("input")
            input.type = "file"
            input.accept = ".js,.ks"
            input.multiple = true
            input.onchange = async function(event) {
              let files = event.target.files
              for (let file of files) {
                if (file) {
                  try {
                    console.log("Loading file " + file.name + " ...")
                    const fileContent = await file.text()
                    console.log("Executing file " + file.name + " ...")
                    let evaluated = await eval(fileContent)
                    console.log(evaluated)
                  } catch (error) {
                    console.error("Error reading JS file: ", error)
                  }
                }
              }
              RavagerData.Variables.State = RavagerData.Variables.PrevState
              RavagerData.Variables.DrawState = RavagerData.Variables.PrevDrawState
            }
            input.click()
          }
        },
      ],
      Customize: [
        {
          type: "text",
          name: "Border"
        },
        {
          refvar: "Customization_BorderColor",
          type: "string"
        },
        {
          refvar: "Customization_Background",
          type: "list",
          default: "Dark",
          options: [ "Dark", "Bright" ],
          postclick: (val) => { RavagerData.Variables.RFControl.Background = "RFControl" + val }
        },
      ],
      Translate: [
        {
          type: "text",
          name: "UnravelKey"
        },
        {
          type: "string",
          refvar: "UnravelKey"
        },
        {
          type: "button",
          name: "UnravelKeySubmit",
          click: () => {
            // console.log(RavagerData.Variables.RFControl.UnravelKey, RFGetText(RavagerData.Variables.RFControl.UnravelKey, undefined, true))
            let text = (RFHasText(RavagerData.Variables.RFControl.UnravelKey) ? RavagerData.Variables.RFControl.UnravelKey + " = " : "") + JSON.stringify(RFUnravelText(RavagerData.Variables.RFControl.UnravelKey)).replace('["', '[ "').replace('"]', '" ]').replaceAll('","', '", "')
            RavagerFrameworkShowModal("unravel", "Text Unravelling", [ "Here's the expansion of all possibilities for your requested text.", "You can translate each of these variations individually, just be sure to keep the formatting the same as what is output below." ], text)
            return true
          }
        },
        {
          type: "button",
          name: "Import",
          click: () => {
            let input = document.createElement("input")
            input.type = "file"
            input.accept = ".txt"
            input.onchange = async function(event) {
              RFInfo("Loading translation ...", event)
              let file = event.target.files[0]
              if (file) {
                try {
                  RFInfo("Loading file " + file.name + " ...")
                  const fileContent = await file.text()
                  RavagerFrameworkLoadTranslation(fileContent, localStorage.BondageClubLanguage)
                } catch (error) {
                  RFError("Caught error while importing translation: ", error)
                }
              }
            }
            input.click()
            return true
          }
        },
      ],
      Band: [
        {
          name: "EnemyApply",
          type: "button",
          click: () => { RFInfo("[RFC] Refreshing enemy cache..."); KinkyDungeonRefreshEnemiesCache(); return true },
          block: () => RFGetSetting('ravagerDisableBandit')
        },
        {
          refvar: "Bandit_SpawnW8",
          type: "range",
          rangehigh: 20,
          rangelow: -20,
          stepcount: 0.1,
          getval: () => KinkyDungeonEnemies.find(v => v.name == "BanditRavager").weight,
          postclick: (val) => { KinkyDungeonEnemies.find(v => v.name == "BanditRavager").weight = val },
          block: () => RFGetSetting('ravagerDisableBandit')
        },
        {
          refvar: "ControlBanditsFirstLevel",
          type: "boolean",
          default: true,
          block: () => RFGetSetting("ravagerDisableBandit")
        },
        {
          refvar: "MaxStartingBandits",
          type: "range",
          rangehigh: 50,
          rangelow: 0,
          stepcount: 1,
          block: () => RFGetSetting('ravagerDisableBandit')
        },
      ],
      Wolf: [
        {
          name: "EnemyApply",
          type: "button",
          click: () => { RFInfo("[RFC] Refreshing enemy cache..."); KinkyDungeonRefreshEnemiesCache(); return true },
          block: () => RFGetSetting('ravagerDisableWolfgirl')
        },
        {
          refvar: "Wolf_SpawnW8",
          type: "range",
          rangehigh: 20,
          rangelow: -20,
          stepcount: 0.1,
          getval: () => KinkyDungeonEnemies.find(v => v.name == "WolfgirlRavager").weight,
          postclick: (val) => { KinkyDungeonEnemies.find(v => v.name == "WolfgirlRavager").weight = val },
          block: () => RFGetSetting('ravagerDisableWolfgirl')
        },
      ],
      Slime: [
        {
          name: "EnemyApply",
          type: "button",
          click: () => { RFInfo("[RFC] Refreshing enemy cache..."); KinkyDungeonRefreshEnemiesCache(); return true },
          block: () => RFGetSetting('ravagerDisableSlimegirl')
        },
        {
          refvar: "Slime_SpawnW8",
          type: "range",
          rangehigh: 20,
          rangelow: -20,
          stepcount: 0.1,
          getval: () => KinkyDungeonEnemies.find(v => v.name == "SlimeRavager").weight,
          postclick: (val) => { KinkyDungeonEnemies.find(v => v.name == "SlimeRavager").weight = val },
          block: () => RFGetSetting('ravagerDisableSlimegirl')
        },
      ],
      Tent: [
        {
          name: "EnemyApply",
          type: "button",
          click: () => { RFInfo("[RFC] Refreshing enemy cache..."); KinkyDungeonRefreshEnemiesCache(); return true },
          block: () => RFGetSetting('ravagerDisableWolfgirl')
        },
        {
          refvar: "Tentacle_SpawnW8",
          type: "range",
          rangehigh: 20,
          rangelow: -20,
          stepcount: 0.1,
          getval: () => KinkyDungeonEnemies.find(v => v.name == "TentaclePit").weight,
          postclick: (val) => { KinkyDungeonEnemies.find(v => v.name == "TentaclePit").weight = val },
          block: () => RFGetSetting('ravagerDisableTentaclePit')
        },
      ],
      Mimic: [
        {
          name: "EnemyApply",
          type: "button",
          click: () => { RFInfo("[RFC] Refreshing enemy cache..."); KinkyDungeonRefreshEnemiesCache(); return true },
          block: () => RFGetSetting('ravagerDisableWolfgirl')
        },
        {
          refvar: "Mimic_SpawnW8",
          type: "range",
          rangehigh: 20,
          rangelow: -20,
          stepcount: 0.1,
          getval: () => KinkyDungeonEnemies.find(v => v.name == "MimicRavager").weight,
          postclick: (val) => { KinkyDungeonEnemies.find(v => v.name == "MimicRavager").weight = val },
          block: () => RFGetSetting('ravagerDisableMimic')
        },
        {
          refvar: "ExposeMimics",
          type: "boolean",
          postclick: (val) => { return RavagerFrameworkSetMimicExposure(val); },
          block: () => RFGetSetting("ravagerDisableMimic")
        },
        {
          refvar: "PassiveMimics",
          type: "boolean",
          postclick: (val) => { return RavagerFrameworkSetMimicPassive(val); },
          block: () => RFGetSetting("ravagerDisableMimic")
        },
        {
          refvar: "TrackMimics",
          type: "boolean",
          postclick: (val) => { return RavagerFrameworkSetMimicTracking(val); },
          block: () => RFGetSetting("ravagerDisableMimic")
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
      HoverData: {
        BoxData: {},
        Desc: {
          FontSize: 34,
          Font: "Once Upon A Time Italic",
        },
        Box: {
          PadV: 25,
          PadH: 10,
          XOffset: 68,
        },
      },
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
  },
  Translations: {}
}

// Slots that need to be stripped to occupy a given slot; slots to clear are in order
// TODO: Move this to RavagerData, to allow external ravager mods to define another slot if they wish
window.ravageEquipmentSlotTargets = {
  ItemButt: ["ItemPelvis", "ItemButt"],
  ItemVulva: ["ItemPelvis", "ItemVulva"],
  ItemMouth: ["ItemHead", "ItemMouth"],
  ItemHead: ["ItemHead"]
}
