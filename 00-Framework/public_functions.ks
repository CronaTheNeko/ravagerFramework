// Shortcut to getting ravager debug
window.RFDebugEnabled = function() {
  return RFGetSetting('ravagerDebug')
}

// Verbosity function for normal level debugging
// This is just console.log wrapped in a function to see if we're debugging
window.RFDebug = (...args) => {
  RavagerFrameworkPushToLogBuffer(args)
  RFDebugEnabled() && console.log(...args)
}

// Verbosity function for extreme level debugging
// This is just console.log wrapped in a function to see if we're doing heavy debugging
window.RFTrace = (...args) => {
  RavagerFrameworkPushToLogBuffer(args, "TRACE")
  _RavagerFrameworkDebugEnabled && console.log(...args)
}

// Wrapper around console.warn
window.RFWarn = (...args) => {
  RavagerFrameworkPushToLogBuffer(args, "WARN")
  console.warn(...args)
}

// Wrapper around console.error
window.RFError = (...args) => {
  RavagerFrameworkPushToLogBuffer(args, "ERROR")
  console.error(...args)
}

// Wrapper around console.log, but this one will always print the message
window.RFInfo = (...args) => {
  RavagerFrameworkPushToLogBuffer(args, "INFO")
  console.log(...args)
}

// Function to get a mod setting value
// If KDModSettings.RavagerFramework is unavailable, we're likely in the middle of initialization, and this will attempt to return the matching value saved in localStorage
// If there's no setting in localStorage, user hasn't loaded this mod before (or has cleared data from the browser), and this will return the default value defined in RavagerData.ModConfig
// If there's no matching default value, it'll return undefined
window.RFGetSetting = function(refvar) {
  if (refvar == "ravagerDebug" && _RavagerFrameworkDebugEnabled)
    return true
  // Mod settings and default config objects
  const settings = KDModSettings.RavagerFramework
  var config = RavagerData.ModConfig[refvar]
  // Helper for getting default value
  function RFConfigDefault(refvar, config) {
    // Check for missing default values; signals either a data structure change or (dev) failure to declare default values
    if (config == undefined) {
      RFError('[Ravager Framework]: RFGetSetting couldn\'t find ModConfig values for ' + refvar + ' !')
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
      RFWarn('[Ravager Framework]: RFGetSetting couldn\'t get current settings for the framework!')
    return RFConfigCheckLocalStorage(refvar, config)
  }
  // Requested setting isn't set, return default
  if (settings[refvar] == undefined) {
    if (!_RavagerFrameworkInInit)
      RFWarn('[Ravager Framework]: RFGetSetting couldn\'t get the current setting for ' + refvar)
    return RFConfigCheckLocalStorage(refvar, config)
  }
  // Return setting
  return settings[refvar]
}

// Verbose, but acturate name. Easy way to create stronger versions of enemies.
/* Params:
    - enemy : The enemy definition to use
    - count : The number of variations to add, plus one for the original enemy. If you want your enemy and 3 additional variations, set this to 4
    - textKeys : The dictionary of text values, key/value pairs being textKey/textValue
    - higherLevelIncrease : Optional. Default true. Use faster enemy.minLevel increases. When false, minLevel is always increased by slowLevelIncreaseAmount
    - slowLevelIncreaseAmount : Optional. Default 1. The number to increment minLevel by when higherLevelIncrease is false
    - enemyDefinitionDictionary : Optional. Default RavagerData.Definitions.Enemies. Points to the dictionary where enemy definitions should be saved for your use (NOT for use by the game directly). This should be a dictionary where you can set a definition via `enemyDefinitionDictionary[enemy.name] = enemy`, as that's what this function does. If you do not use your enemy definitions after creation, or do not care where they get stored, you don't need to include this parameter
    - options.skipTextKeyWarning : Optional. Default false. Skips the warning message about textKeys parameter being empty. If you're intending to handle the text keys yourself, set this to true
    - options.skipEnemyDefinitionDictionaryWarning: Optional. Default false. If you don't want to set enemyDefinitionDictionary, but don't want the related warning message shown, set this to true.
*/
window.RFPushEnemiesWithStrongVariations = function(enemy, count, textKeys, higherLevelIncrease = true, slowLevelIncreaseAmount = 1, enemyDefinitionDictionary, options = { skipTextKeyWarning: false, skipEnemyDefinitionDictionaryWarning: false, TranslationDictionaryEnemy: false }) {
  RFDebug('[Ravager Framework][RFPushEnemiesWithStrongVariations]: enemy: ', enemy, '; count: ', count, '; textKeys: ', textKeys, '; higherLevelIncrease: ', higherLevelIncrease, '; slowLevelIncreaseAmount: ', slowLevelIncreaseAmount, '; options: { skipTextKeyWarning: ', options?.skipTextKeyWarning, ', skipEnemyDefinitionDictionaryWarning: ', options?.skipEnemyDefinitionDictionaryWarning, ' }')
  if (!enemy) {
    RFError("[Ravager Framework][RFPushEnemiesWithStrongVariations]: 'enemy' parameter is undefined! Cannot continue. Whatever enemy this is supposed to be will not be in the game. If you're using an external ravager mod, report this to that author, otherwise report this to the Ravager Framework")
    return false
  }
  if (count == undefined) {
    RFWarn(`[Ravager Framework][RFPushEnemiesWithStrongVariations]: 'count' parameter is undefined for enemy "${enemy.name}". Count will be defaulted to one, no stronger variations will be added. You should report this to the author of this ravager.`)
    count = 1
  }
  if (count < 1) {
    RFWarn(`[Ravager Framework][RFPushEnemiesWithStrongVariations]: 'count' parameter is less than one for enemy "${enemy.name}". This enemy will not be added. You should report this to the author of this ravager.`)
    return false
  }
  if (!textKeys && !options.skipTextKeyWarning) {
    RFWarn(`[Ravager Framework][RFPushEnemiesWithStrongVariations]: 'textKeys' parameter for enemy "${enemy.name}" has no text keys. This enemy will have no text keys added by this function.`)
  }
  if (enemyDefinitionDictionary == undefined) {
    if (!(options.skipEnemyDefinitionDictionaryWarning || enemy.addedByMod == "RavagerFramework"))
      RFWarn(`[Ravager Framework][RFPushEnemiesWithStrongVariations]: enemyDefinitionDictionary was undefined for enemy "${enemy.name}". Definitions dictionary will be defaulted to RavagerData.Definitions.Enemies. You should report this to the author of this ravager.`)
    enemyDefinitionDictionary = RavagerData.Definitions.Enemies
  }
  if (higherLevelIncrease == false && slowLevelIncreaseAmount == undefined) {
    RFDebug(`[Ravager Framework][RFPushEnemiesWithStrongVariations]: slowLevelIncreaseAmount is undefined for enemy "${enemy.name}" and this enemy will need to use this value to increase minLevel. This value will be defaulted to 1. You should report this to the author of this ravager.`)
    slowLevelIncreaseAmount = 1
  }
  let prevEnemy = undefined
  let currentEnemy = structuredClone(enemy)
  for (let i = 0; i < count; i++) {
    RFTrace(`[Ravager Framework][RFPushEnemiesWithStrongVariations]: Starting loop #${i} for enemy ${enemy.name}`)
    if (i > 0) {
      prevEnemy = structuredClone(currentEnemy)
      currentEnemy = structuredClone(enemy)
      currentEnemy.name = currentEnemy.name + i.toString()
      currentEnemy.maxhp = currentEnemy.maxhp * (1 + i)
      currentEnemy.minLevel = prevEnemy.minLevel + (higherLevelIncrease ? i : slowLevelIncreaseAmount)
      currentEnemy.armor = prevEnemy.armor + 0.5
      KDModFiles[`Game/Enemies/${currentEnemy.name}.png`] = KDModFiles[`Game/Enemies/${enemy.name}.png`]
    }
    RFTrace(`[Ravager Framework][RFPushEnemiesWithStrongVariations]: Pushing enemy ${currentEnemy.name}:`, currentEnemy)
    KinkyDungeonEnemies.push(currentEnemy)
    enemyDefinitionDictionary[currentEnemy.name] = structuredClone(currentEnemy)
    RFTrace(`[Ravager Framework][RFPushEnemiesWithStrongVariations]: Adding text keys for enemy ${currentEnemy.name}`)
    if (options.TranslationDictionaryEnemy) { // Translation update behavior
      let replacer = textKeys[0]
      for (let key of textKeys[1])
        RFAddTextKey(("- " + key).replace(replacer, currentEnemy.name), RFGetText(key))
    } else { // Normal behavior
      for (let key in textKeys)
        addTextKey(key.replace("EnemyName", currentEnemy.name), textKeys[key])
    }
  }
  return true
}

// Adds a callback function to the framework
/* Params:
    - key : The string you'll use in your enemy definition to reference the callback
    - func : The callback function to be used
  Returns : True if the callback was added successfully; false otherwise
*/
window.RFAddCallback = (key, func) => {
  if (!KDEventMapEnemy['ravagerCallbacks']) {
    KDEventMapEnemy['ravagerCallbacks'] = {}
    if (!KDEventMapEnemy['ravagerCallbacks']) {
      throw new Error('[Ravager Framework] Failed to initialize the ravager callbacks key! Something seems to have gone very wrong. Please report this to the Ravager Framework with as much info as you can provide.')
    }
  }
  RFDebug('[Ravager Framework] Adding callback function with key: ', key)
  KDEventMapEnemy['ravagerCallbacks'][key] = func
  return Boolean(KDEventMapEnemy['ravagerCallbacks'][key])
}

// Developer helper function to verify a ravager's EAM values - please don't have a bug ;-;
// The only parameter is the name of your ravager.
// Call this after adding your ravager, and it should tell you anything wrong with the Experience Aware Mode settings your ravager has and, at the end, will return true if no issues were found or false if there were issues found
// To see all messages, enable the debug option for the framework in mod config
window.RFVerifyEAM = function(ravagerName) {
  const ravager = KDEnemiesCache.get(ravagerName)
  // Check that enemy exists
  if (!ravager) {
    RFError('[RFVerifyEAM] Could not find an enemy by the name of ', ravagerName)
    return false
  }
  // Check for ravager.ravage to make sure this is a ravager
  if (!ravager.ravage) {
    RFError('[RFVerifyEAM] Enemy does not have a "ravage" property. Either you\'re checking the wrong enemy, or you\'ve defined your ravager wrong.')
    return false
  }
  // Check that ravager has ranges
  if (!ravager.ravage.ranges || ravager.ravage.ranges.length < 1) {
    RFError('[RFVerifyEAM] Ravager has no ranges. This ravager will be unable to ravage the player.')
    return false
  }
  // Track failed ranges
  let failedRanges = []
  // Track ranges with invalid EAM properties
  let eamFailedRanges = []
  //
  let hasEAMRanges = false
  // Loop each range
  for (var range of ravager.ravage.ranges) {
    // Check for rangeData
    if (range.length < 2 || !range[1]) {
      RFError('[RFVerifyEAM] Invalid range: ', range)
      failedRanges.push(range)
      continue
    }
    const rangeData = range[1]
    // Log about use count
    if (rangeData.hasOwnProperty('useCount')) {
      let useCount = rangeData.useCount
      if (typeof useCount == undefined) {
        RFWarn('[RFVerifyEAM] Range ', range, ' has useCount defined, but it is set to undefined. Doing so is not well tested. If this is not your last range, the expected behavior is to block incrementing use count, but that is unnecessary, as that is the default bahvior. If this is in your last range, this will result in incrementing the use count by 1 regardless of slot. It is recommended you either remove this setting if it is not in your last range, or set useCount to 0 if this is in your last range and you wish to block incrementing use counts.')
      } else if (typeof useCount == 'number') {
        if (useCount == 0)
          RFDebug('[RFVerifyEAM] Range ', range, ' has useCount set to zero. If this is the last range, this will prevent incrementing use counts. If this is not the last range, this setting is unnecessary.')
        else if (useCount < 0)
          RFDebug('[RFVerifyEAM] Range ', range, ' has useCount set to a negative value. This will result in DECREMENTING use counts instead of incrementing them.')
        else if (useCount > 0)
          RFDebug('[RFVerifyEAM] Range ', range, ' will increment use counts by ', useCount, ' for every slot')
        else
          RFError('[RFVerifyEAM] wtf just happened? (useCount = number)')
      } else if (typeof useCount == 'object') {
        let hasSlots = false
        if (useCount.hasOwnProperty('ItemVulva')) {
          RFDebug('[RFVerifyEAM] Range ', range, ' will increment use count for ItemVulva by ', useCount.ItemVulva)
          hasSlots = true
        }
        if (useCount.hasOwnProperty('ItemMouth')) {
          RFDebug('[RFVerifyEAM] Range ', range, ' will increment use count for ItemMouth by ', useCount.ItemMouth)
          hasSlots = true
        }
        if (useCount.hasOwnProperty('ItemButt')) {
          RFDebug('[RFVerifyEAM] Range ', range, ' will increment use count for ItemButt by ', useCount.ItemButt)
          hasSlots = true
        }
        if (useCount.hasOwnProperty('ItemHead')) {
          RFDebug('[RFVerifyEAM] Range ', range, ' will increment use count for ItemHead by ', useCount.ItemHead)
          hasSlots = true
        }
        if (!hasSlots) {
          RFWarn('[RFVerifyEAM] Range ', range, ' defines useCount as a dictionary, but has no slots. This will result in never incrementing use counts.')
        }
      } else {
        RFError('[RFVerifyEAM] Range ', range, ' has useCount set to an unknown type. This scenario is untested. If you beleive this is a mistake, please report the issue. Otherwise, it is recommended to fix your definition of useCount.')
      }
    }
    // Track if this range has any EAM settings
    let hasEAMProps = false
    // Check for taunts
    if (rangeData.hasOwnProperty('experiencedTaunts')) {
      let tauntsValid = true
      // Loop each taunt range
      for (var count of rangeData.experiencedTaunts) {
        // Check structure of taunt range
        if (count.length < 2 || !count[1]) {
          RFWarn('[RFVerifyEAM] This range has an invalid EAM taunt definition: ', count)
          if (!eamFailedRanges.includes(count))
            eamFailedRanges.push(count)
          continue
        }
        let countData = count[1]
        // Track if this taunt range has any slots
        let hasSlots = false
        // Check for each slot
        for (var slot of [ 'ItemVulva', 'ItemMouth', 'ItemButt', 'ItemHead' ]) {
          if (!countData.hasOwnProperty(slot))
            continue
          let stringsValid = Array.isArray(countData[slot])
          if (!stringsValid) {
            RFWarn('[RFVerifyEAM] Range ', count, ' contains a value which isn\'t an array for slot ', slot)
            continue
          }
          for (var string of countData[slot]) {
            stringsValid = stringsValid && typeof string == 'string'
          }
          if (!stringsValid) {
            RFWarn('[RFVerifyEAM] Range ', count, ' contains taunts which are not strings in slot "' + slot + '". This isn\'t necessarily fatal, but should still be fixed.')
          }
          hasSlots = true
        }
        // Warn if there's no slots
        if (!hasSlots)
          RFWarn('[RFVerifyEAM] Range ', count, ' doesn\'t appear to have any slots assigned. A use count range with no slots assigned is either defined wrong, or shouldn\'t be defined. Check for earlier errors or remove this range.')
        tauntsValid = tauntsValid && hasSlots
      }
      if (!tauntsValid)
        RFWarn('[RFVerifyEAM] experiencedTaunts is defined for range ' + range[0] + '. Either experiencedTaunts is invalid or shouldn\'t be defined. Please check for previous errors and warnings.')
      hasEAMProps = hasEAMProps || tauntsValid
    }
    // Check for narration
    if (rangeData.hasOwnProperty('experiencedNarration')) {
      let narrationValid = true
      for (var count of rangeData.experiencedTaunts) {
        if (count.length < 2 || !count[1]) {
          RFWarn('[RFVerifyEAM] This range has an invalid EAM narration definition: ', count)
          if (!eamFailedRanges.includes(count))
            eamFailedRanges.push(count)
          continue
        }
        let countData = count[1]
        let hasSlots = false
        for (var slot of [ 'ItemVulva', 'ItemMouth', 'ItemButt', 'ItemHead' ]) {
          if (!countData.hasOwnProperty(slot))
            continue
          let stringsValid = Array.isArray(countData[slot])
          if (!stringsValid) {
            RFWarn('[RFVerifyEAM] Range ', count, ' contains a value which isn\'t an array for slot ', slot)
            continue
          }
          for (var string of countData[slot]) {
            stringsValid = stringsValid && typeof string == 'string'
          }
          if (!stringsValid) {
            RFWarn('[RFVerifyEAM] Range ', count, ' contains narrations which are not strings in slot "' + slot + '". This isn\'t necessarily fatal, but should still be fixed.')
          }
          hasSlots = true
        }
        if (!hasSlots)
          RFWarn('[RFVerifyEAM] Range ', count, ' doesn\'t appear to have any slots assigned. A use count range with no slots assigned is either defined wrong, or shouldn\'t be defined. Check for earlier errors or remove this range.')
        narrationValid = narrationValid && hasSlots
      }
      if (!narrationValid)
        RFWarn('[RFVerifyEAM] experiencedNarration is defined for range ' + range[0] + '. Either experiencedNarration is invalid or shouldn\'t be defined. Please check for previous errors and warnings.')
      hasEAMProps = hasEAMProps || narrationValid
    }
    //
    let hasChance = rangeData.hasOwnProperty('experiencedChance')
    let hasAlways = rangeData.hasOwnProperty('experiencedAlways')
    //
    if (!hasEAMProps && (hasChance || hasAlways)) {
      RFWarn('[RFVerifyEAM] Range ', range, 'defines EAM chance or always, but does not appear to have any valid taunts or narrations. Without taunts or narrations to use, EAM text will not be used, and the chance and always settings are pointless')
    }
    //
    hasEAMProps = hasEAMProps || hasChance || hasAlways
    //
    if (hasChance && hasAlways && rangeData.experiencedAlways) {
      RFWarn('[RFVerifyEAM] Range ', range, ' defines both experiencedChance and experiencedAlways. experiencedAlways overrides experiencedChance, so it\'s pointless to have them both declared at the same time.')
      continue
    }
    // Check for chance
    if (hasChance && rangeData.experiencedChance <= 0) {
      RFWarn('[RFVerifyEAM] Range ', range, ' has experiencedChance set to or below 0. This setting will result in EAM text never being used unless the user overrides your ravager\'s preference.')
    }
    // Check for always
    if (hasAlways && !rangeData.experiencedAlways) {
      RFWarn('[RFVerifyEAM] Range ', range, ' has experiencedAlways set to false. Doing so is entirely unneeded, as this setting only has any effect when true.')
    }
    hasEAMRanges = hasEAMRanges || hasEAMProps
  }
  // Bail on failed ranges
  if (failedRanges.length > 0) {
    RFError('[RFVerifyEAM] The following ranges are invalid and may cause crashes: ', failedRanges)
    return false
  }
  // Bail of EAM failures in ranges
  if (eamFailedRanges.length > 0) {
    RFError('[RFVerifyEAM] The following ranges have invalid EAM properties and may cause crashes: ', eamFailedRanges)
    return false
  }
  //
  if (!hasEAMRanges) {
    RFError('[RFVerifyEAM] Ravager doesn\'t appear to have any ranges with valid EAM properties.')
    return false
  }
  return true
}

// Custom version of KinkyDungeonGetRestraint so I can have name-based exclusions and per-item weight modifiers
// All the same params as KinkyDungeonGetRestraint, but with the addition of:
//   - `exclude` as an array of strings that are restraint names, which should not be chosen
//   - `weightMods` as a dictionary with the keys being restraint names and the values being a number to multiply that restraint's weight by
// Also want to add some weight modifiers
window.RFGetRestraint = function(enemy, Level, Index, exclude, weightMods, Bypass, Lock, RequireWill, LeashingOnly, NoStack, extraTags, agnostic, filter, securityEnemy, curse, useAugmented, augmentedInventory, options) {
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
}

// Format strings used throughout the framework. Handles enemy, restraint, and clothing names, damage strings, and runtime string variations
// Runtime string variations could be made faster in the case of nested variations, as this code is depth first, and having nested variations will lead to all deeper levels being decided and (potentially) later thrown away. It'd likely be faster if I trimmed the tree of choices as soon as I could, but that would be significantly more effort :) -- Possibly pretty easy to do by deciding on the top level variation and recursing back into inStringRandom with the chosen section of the input string.
window.RFStringFormat = function(string, entity, restraint, clothing, damage, skipCapitalize) {
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
}

// A variation of DrawCheckboxKDEx so I can default to a custom check image
window.DrawCheckboxRFEx = function(name, func, enabled, Left, Top, Width = 64, Height = 64, Text, IsChecked, Disabled, TextColor, _CheckImage, options) {
  // Ensure valid checked image; default to mine
  if (!_CheckImage)
    _CheckImage = "UI/HeartChecked.png"
  return DrawCheckboxKDEx(name, func, enabled, Left, Top, Width, Height, Text, IsChecked, Disabled, (enabled ? (TextColor ? TextColor : KDBaseWhite) : "#757575"), _CheckImage, options)
}

// Checks if the player can see an enemy; just an overgrown shortcut for a call to KDCanSeeEnemy, which I anticipate being useful in the future
window.RFPlayerCanSeeEnemy = function(entity) {
  let canSee = undefined
  try {
    canSee = KDCanSeeEnemy(entity)
  } catch (error) {
    RFDebug('[Ravager Framework][RFPlayerCanSeeEnemy] Caught error while trying calling KDCanSeeEnemy. Trying again with player distance. Error: ', error)
    // KDistChebyshev(xDist, yDist) is basically just shorthand for Math.max(Math.abs(xDist), Math.abs(yDist))
    canSee = KDCanSeeEnemy(entity, KDistChebyshev(KinkyDungeonPlayerEntity.x - entity.x, KinkyDungeonPlayerEntity.y - entity.y), true)
  }
  const visiblilty = KinkyDungeonVisionGet(entity.x, entity.y)
  return canSee && (visiblilty > 0)
}

// Conditions helper
// TODO: Rename to RFAddCondition
window.RFAddCondition = function(key, func) {
  if (!RavagerData.conditions) {
    RavagerData.conditions = {}
    if (!RavagerData.conditions) {
      throw new Error('[Ravager Framework] Failed to initialize Ravager Conditions! Something seems to have gone very wrong. Please report this to the Ravager Framework with as much info as you can provide.')
    }
  }
  RFDebug('[Ravager Framework] Adding condition function with key:', key)
  RavagerData.conditions[key] = func
  return Boolean(RavagerData.conditions[key])
}

// Util to just randomly select an array element
// Returns undefined for an empty array or undefined, random element from the given array for arrays with item(s) to choose from
window.RFArrayRand = function (array) {
  return ((array && array.length) ? array[Math.floor(Math.random() * array.length)] : undefined);
}

// Just a shortcut to get me to 'testing' a tile in the tile editor, as a fast way of getting to a playable state
window.RFToTileTest = function() {
  TestMode = true
  KDDebugMode = true
  KDInitTileEditor();
  KDTE_CloseUI();
  KDTileToTest = KDTE_ExportTile();
  KinkyDungeonStartNewGame();
}

// Similar to KD's TextGet, returns text for a specific text key.
// This mimics KD's translation system, but doesn't directly use it, as I wrote it before figuring out how KD's translation system works.
// If there's not a translated version available for a specific text key, the english value will be used as a fallback.
// If there's not an english version available, this will default to returning "[Not Found]: {key}", but can be made to return just the key by setting the `fail` parameter to false
// This function also handles returning a random value from an array in multiple ways. If key is an array, that array will be passed to RFArrayRand and the result will be returned. If the value found for the text key is surrounded by square brackets ( [ "option1", "option2", ... ] ), this function will attempt to parse it to an array and return the result of RFArrayRand, but will return the unparsed string if parsing fails
window.RFGetText = function(key, fail = true, skipRandom = false) {
  let ret = undefined
  if (RavagerData.Translations[localStorage.BondageClubLanguage] && RavagerData.Translations[localStorage.BondageClubLanguage][key])
    ret = RavagerData.Translations[localStorage.BondageClubLanguage][key]
  else if (RavagerData.Translations[""][key])
    ret = RavagerData.Translations[""][key]
  else {
    let src = textProvider.getTextFromGroupStrict(textProvider.defaultGroupId, key)
    ret = src ? src : (fail ? "[Not Found]: " + key : key)
  }
  if (!skipRandom) {
    if (Array.isArray(key))
      ret = RFArrayRand(key)
    else if (ret.startsWith("[") && ret.endsWith("]")) {
      try {
        let t = JSON.parse(ret)
        ret = RFArrayRand(t)
      } catch (err) {
        RFWarn("[RF][RFGetText]: Caught error while attempting to parse array: ", err)
      }
    }
  }
  return ret
}

// Check if there is a text key available somewhere; first checks the current framework translation, then checks the english framework translation, then checks the game's text map
window.RFHasText = function(key) {
  if (RavagerData.Translations[localStorage.BondageClubLanguage] && RavagerData.Translations[localStorage.BondageClubLanguage][key])
    return true
  if (RavagerData.Translations[""][key])
    return true
  return Boolean(textProvider.getTextFromGroupStrict(textProvider.defaultGroupId, key))
}

// Similar to KD's addTextKey, adds a key-value pair for a line of text to the framework.
// If you're adding translated text, set the `lang` parameter to the two character language abbreviation that the game uses.
// The abbreviation *should* be the same as shown on the title screen's language button, but you can also set the game to your language and check `localStorage.BondageClubLanguage` to be certain
// If your text key should also be added to the game (via addTextKey()`), prepend your text key with a hyphen and a space "- "
window.RFAddTextKey = function(key, value, lang = "") {
  // Ensure lang is upper case
  lang = lang.toUpperCase()
  // Default game language of english will be changed to an empty string; makes referencing text keys easier
  if (lang == "EN")
    lang = ""
  // Ensure relevant translation dictionary exists
  if (!RavagerData.Translations)
    RavagerData.Translations = {}
  if (!RavagerData.Translations[lang])
    RavagerData.Translations[lang] = {}
  // Adding translated text keys to the game, so they can be returned by TextGet and TextGetKD
  if (key.startsWith("- ")) {
    key = key.substr(2)
    if (lang == "")
      textProvider.textGroupManager.sourceTextGroupMap.get("default").set(key, value)
    else if (textProvider.translationServiceGroup.get("default").localizationMap.get(lang))
      textProvider.translationServiceGroup.get("default").localizationMap.get(lang).tagTranslationMap.set(key, value)
  }
  // Add text key
  RavagerData.Translations[lang][key] = value
}

// Unravel my in-string-random strings; meant to help translators who may be struggling to understand those complex strings, and primarily meant to be used from RFControl
// `key` paramater can be either a text key or the string to be unravelled
window.RFUnravelText = function(key) {
  let text = RFGetText(key, false, true)
  if (text.startsWith("[") && text.endsWith("]")) {
    try {
      text = JSON.parse(text)
    } catch {}
  }
  function unravel(input, maxDepth = 50, depth = 0) {
    if (depth > maxDepth) {
      return input
    }
    if (Array.isArray(input)) {
      let ret = []
      for (let i of input) {
        let o = unravel(i, maxDepth, depth + 1)
        for (let j of o) {
          ret.push(j)
        }
      }
      return ret
    } else {
      if (!input.match(/.*\{.*\|.*\}.*/)) {
        return [ input ]
      }
      function characterCount(input, char) {
        let count = 0
        for (let i of input)
          if (i == char)
            count++
        return count
      }
      function custSplit(input) {
        let level = 0
        let items = [ "" ]
        while (input.length) {
          if (input[0] == "{") {
            level++
            items[items.length - 1] += input[0]
            input = input.slice(1)
          } else if (input[0] == "}") {
            level--
            items[items.length - 1] += input[0]
            input = input.slice(1)
          } else if (level == 0 && input[0] == "|") {
            items.push("")
            input = input.slice(1)
          } else /*if (currentLevel > 0)*/ {
            items[items.length - 1] += input[0]
            input = input.slice(1)
          }
        }
        return items
      }
      let currentLevel = 0
      let begin = ""
      let end = ""
      let choice = ""
      while (input.length) {
        if (input[0] == "{") {
          if (currentLevel > 0)
            choice += "{"
          currentLevel++
          input = input.slice(1)
        } else if (input[0] == "}") {
          if (currentLevel != 1)
            choice += "}"
          currentLevel--
          input = input.slice(1)
        } else if (currentLevel > 0) {
          choice += input[0]
          input = input.slice(1)
        } else if (choice.length == 0) {
          begin += input[0]
          input = input.slice(1)
        } else {
          end = input
          input = ""
        }
      }
      let options = custSplit(choice)
      let arr = []
      for (let i of options) {
        arr.push(begin + i + end)
      }
      if (arr.filter(v => v.match(/.*\{.*\|.*\}.*/)).length) {
        return unravel(arr, maxDepth, depth + 1)
      }
      return arr
    }
  }
  return unravel(text)
}
