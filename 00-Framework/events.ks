// Game tick side of ravager bubbles
KDEventMapEnemy['tick']['ravagerBubble'] = (e, entity, data) => {
  const enemy = entity.Enemy
  // Setup defaults
  if (!e.hasOwnProperty('chance'))
    e.chance = 0.3
  if (!e.hasOwnProperty('duration'))
    e.duration = 3
  if (!e.hasOwnProperty('image'))
    e.image = 'Hearts'
  // Debugging
  RFDebug('[Ravager Framework][ravagerBubble] Starting event with e:', e)
  // Does the enemy define a condition?
  const hasCond = enemy.ravage.hasOwnProperty('bubbleCondition')
  // Does said condition correspond to a function to call?
  const execCond = hasCond && typeof enemy.ravage.bubbleCondition == 'string' && typeof RavagerData.conditions[enemy.ravage.bubbleCondition] == 'function'
  // If there's no condition, don't bail
  if (hasCond)
    // If the condition is a function and that function returns false, bail
    if (execCond && !RavagerData.conditions[enemy.ravage.bubbleCondition](entity))
      return
    // If the condition isn't a function and the condition evaluates to false, bail
    else if (!execCond && !enemy.ravage.bubbleCondition)
      return
  // If we've gotten this far, we're supposed to be drawing the bubble; setup an empty object to avoid crashing
  if (!entity.ravBubble)
    entity.ravBubble = {}
  // Check that there's not a bubble already, then roll the dice
  if (!entity.ravBubble.name && Math.random() < e.chance) {
    // Setup bubble to be drawn
    entity.ravBubble = {
      name: e.image,
      duration: e.duration,
      index: KinkyDungeonCurrentTick
    }
    // Debugging
    RFDebug('[Ravager Framework][ravagerBubble] Set Rav Bubble properties for ' + entity.Enemy.name + '(' + entity.id + ')')
  }
}

if (KDEventMapGeneric['afterModSettingsLoad'] != undefined) {
  KDEventMapGeneric['afterModSettingsLoad']['RavagerFramework'] = (e, data) => {
    if (KDModSettings == null) {
      KDModSettings = {}
      RFDebug('[Ravager Framework] KDModSettings was null.')
    }
    if (KDModConfigs != undefined) {
      let settingsarr = []
      for (let conf in RavagerData.ModConfig) {
        settingsarr.push(Object.assign({}, RavagerData.ModConfig[conf]))
      }
      KDModConfigs['RavagerFramework'] = settingsarr
    }
    let settingsobject = (KDModSettings.hasOwnProperty('RavagerFramework') == false) ? {} : Object.assign({}, KDModSettings['RavagerFramework'])
    for (var i of KDModConfigs['RavagerFramework']) {
      if (settingsobject[i.refvar] == undefined) {
        RFDebug('Setting default value for ' + i.refvar + ' ...')
        settingsobject[i.refvar] = i.default
      }
      // Text keys
      if (i.textKeyVal)
        addTextKey(`KDModButton${i.refvar}`, i.textKeyVal)
    }
    KDModSettings['RavagerFramework'] = settingsobject
    RavagerFrameworkSettingsRefresh('load')
    RavagerFrameworkSetupSound()
    // Check for any missing functions
    if (!RavagerData.functions.CheckAllFunctions())
      RFError("Found missing functions!", RavagerData.Variables.MissingFunctions)
  }
}

if (KDEventMapGeneric['afterModConfig'] != undefined) {
  KDEventMapGeneric['afterModConfig']['RavagerFramework'] = (e, data) => {
    RavagerFrameworkSettingsRefresh('refresh')
    _RavagerFrameworkInInit = false
  }
}

// This whole nightmare references KinkyDungeonPlayerEntity all over the place, instead of just using target. Changing this would need testing to make sure nothing goes wrong, but could allow ravagers to go after other entities, or stay player targetted (with an early exit if target != KinkyDungeonPlayerEntity) while being easier to read
KDPlayerEffects["Ravage"] = (target, damage, playerEffect, spell, faction, bullet, entity) => {
  RFDebug('[Ravager Framework]: Effect: Ravage; Ravaging entity is', entity, 'target is', target)
  RFTrace('[Ravager Framework DBG]: Ravager PlayerEffect; target: ', target, '; damage: ', damage, '; playerEffect: ', playerEffect, '; spell: ', spell, '; faction: ', faction, '; bullet: ', bullet, '; entity: ', entity)
  let enemy = entity.Enemy
  if(!enemy.ravage)
    throw 'Ravaging enemies need to have ravage settings!'

  ////////////////////////////////////////////////////////////////////////
  /* STATUS DETERMINATION SECTION 
   * determine the strip/restraint state of the player - what to rip away before ravaging
   * for each option, each given slot must be unoccupied by restraints, and clothing, removed in that order
  */
  ////////////////////////////////////////////////////////////////////////

  // Status callback, I added this for the wolfgirl's spell work without screwing up the ravaging actions. If this callback function returns anything equal to true, the ravager will NOT take any ravaging actions
  // If you're going to use this, my current intent for it is to do some thing before the ravaging begins. It's probably best to do your actions, then set a flag in the ravager entity which will be used to quickly exit your callback.
  // Do NOT try to put this flag in `entity.ravage`, as that dictionary does not exist the first time your callback will be called
  // Currently, it is used to make the wolfgirl throw restraints at the player before closing in on her
  let skipEverything = false
  if (
    typeof enemy.ravage.effectCallback == 'string' &&
    KDEventMapEnemy['ravagerCallbacks'] &&
    typeof KDEventMapEnemy['ravagerCallbacks'][enemy.ravage.effectCallback] == 'function'
  ) {
    RFDebug('[Ravager Framework] Running effectCallback with enemy: ', entity, '; target: ', target)
    skipEverything = KDEventMapEnemy['ravagerCallbacks'][enemy.ravage.effectCallback](entity, target)
  }
  RFDebug('[Ravager Framework]: skipEverything: ', skipEverything)
  if (!skipEverything) {
    // Clothing targts
    let clothingTargetsPelvis = KDGetDressList()[KinkyDungeonCurrentDress].filter(article=> {
      // Working around a function override for PureWind'sTools outfits
      if (["InnocentDesireSuit", "NightCatSuit", "MikosSuitLV1", "MikosSuitLV2", "MikosSuitLV3", "Nake", "EtherMageSuit"].some(str => KinkyDungeonCurrentDress == str))
        return false
      // Seems to not be called before stripping; but it's working as it is now, so I'll come back to this later
      if (enemy.ravage.bypassAll)
        return false
      // Clothing with Lost = true are not visible on the player, aka already removed
      if(article.Lost)
        return false
      // Sorry, uniforms get torn off in their entirety
      if(article.Group == "Uniform")
        return true
      if(["Shorts", "Bikini", "Panties", "Leotard", "Swimsuit"].some(str => article.Item.includes(str)))
        return true
    })
    RFTrace('[Ravager Framework DBG]: PlayerEffect clothingTargetsPelvis: ', clothingTargetsPelvis)
    let clothingTargetsMouth = KDGetDressList()[KinkyDungeonCurrentDress].filter(article=> {
      // Working around a function override for PureWind'sTools outfits
      if (["InnocentDesireSuit", "NightCatSuit", "MikosSuitLV1", "MikosSuitLV2", "MikosSuitLV3", "Nake", "EtherMageSuit"].some(str => KinkyDungeonCurrentDress == str))
        return false
      // Seems to not be called before stripping; but it's working as it is now, so I'll come back to this later
      if (enemy.ravage.bypassAll)
        return false
      // Clothing with Lost = true are not visible on the player, aka already removed
      if(article.Lost)
        return false
      if(["Mask", "Visor", "Gag"].some(str => article.Item.includes(str)))
        return true
    })
    let clothingTargetsHead = KDGetDressList()[KinkyDungeonCurrentDress].filter(article=> {
      // Working around a function override for PureWind'sTools outfits
      if (["InnocentDesireSuit", "NightCatSuit", "MikosSuitLV1", "MikosSuitLV2", "MikosSuitLV3", "Nake", "EtherMageSuit"].some(str => KinkyDungeonCurrentDress == str))
        return false
      // Seems to not be called before stripping; but it's working as it is now, so I'll come back to this later
      if (enemy.ravage.bypassAll)
        return false
      // Clothing with Lost = true are not visible on the player, aka already removed
      if(article.Lost)
        return false
      if(["Hat"].some(str => article.Item.includes(str)))
        return true
    })
    RFDebug('[Ravager Framework]: Clothing targets: Pelvis: ', clothingTargetsPelvis, '; Mouth: ', clothingTargetsMouth, '; Head: ', clothingTargetsHead)

    // Equipment/clothing targets object
    // Has an array for each slot of specific stuff to remove
    let stripOptions = {
      equipment: {
        ItemButt: [],
        ItemVulva: [],
        ItemMouth: [],
        ItemHead: []
      },
      clothing: {
        ItemButt: clothingTargetsPelvis,
        ItemVulva: clothingTargetsPelvis,
        ItemMouth: clothingTargetsMouth,
        ItemHead: clothingTargetsHead
      }
    } 
    // Returns true on a given restraint unless it is bypassed
    function bypassed(restraint) {
      let restraintIsBypassed = false
      if(enemy.ravage.bypassSpecial)
        restraintIsBypassed = enemy.ravage.bypassSpecial.some(str => restraint?.name.includes(str))
      if( 
        ( // Leave blindfolds on unless specified
          (restraint.name.includes("Blindfold") && !enemy.ravage.needsEyes) 
        ) || 
        restraintIsBypassed ||
        ( // Possible to bypass completely if specified
          enemy.ravage.bypassAll
        )
      )
        return true
      else
        return false
    }

    // Collect an array of equipment that needs to be removed
    for (const slot in stripOptions.equipment) {
      ravageEquipmentSlotTargets[slot].forEach(groupName => {
        let restraintInSlot = KinkyDungeonGetRestraintItem(groupName)
        RFTrace('[Ravager Framework DBG]: PlayerEffect creating array of worn equipment; groupName: ', groupName, '; restraintInSlot: ', restraintInSlot)
        restraintInSlot && RFTrace('  ; if eval: restraintInSlot: ', Boolean(restraintInSlot), '; InSlot name: ', restraintInSlot.name, '; InSlot name != Stripped: ', restraintInSlot.name != "Stripped", '; InSlot name not includes RavagerOccupied: ', !restraintInSlot.name.includes("RavagerOccupied"), '; not bypassed: ', !bypassed(restraintInSlot), '; not bypassAll: ', !enemy.ravage.bypassAll, '; Total: ', restraintInSlot && restraintInSlot.name != "Stripped" && !restraintInSlot.name.includes("RavagerOccupied") && !bypassed(restraintInSlot) && !enemy.ravage.bypassAll)
        if(
          restraintInSlot && 
          restraintInSlot.name != "Stripped" && 
          !restraintInSlot.name.includes("RavagerOccupied") &&
          !bypassed(restraintInSlot) &&
          !enemy.ravage.bypassAll // Allows a ravager to not remove clothing
        )
          stripOptions.equipment[slot].push(groupName) // Since easiest removal is via group name
      })
      // Special check for mouth since collars can also affect this
      for (let inv of KinkyDungeonAllRestraint()) {
        if (
          KDRestraint(inv).gag && 
          !KDRestraint(inv).name.includes("RavagerOccupied") &&
          !bypassed(inv) &&
          !enemy.ravage.bypassAll // Allows a ravager to not remove clothing
        )
          stripOptions.equipment.ItemMouth.push(inv)
      }
    }
    // Easy eligibility detection; just make sure there's nothing else to remove in desired slot
    let uncovered = {
      ItemButt: stripOptions.equipment.ItemButt.length == 0 && stripOptions.clothing.ItemButt.length == 0,
      ItemVulva: stripOptions.equipment.ItemVulva.length == 0 && stripOptions.clothing.ItemVulva.length == 0,
      ItemMouth: stripOptions.equipment.ItemMouth.length == 0 && stripOptions.clothing.ItemMouth.length == 0
    }
    RFDebug('[Ravager Framework]: Slot state: stripOptions: ', stripOptions, '; uncovered: ', uncovered)

    ////////////////////////////////////////////////////////////////////////
    /* TARGETING SECTION  - an enemy should "claim" a slot for consistency
        - i.e. picks one slot, saved into active entity as a goal, strips that particular slot
        - other ravagers can have same goal and help strip, but only one gets it - they'll pick another eventually
        - if they can't, they default to fallback behavior
    */
    ////////////////////////////////////////////////////////////////////////
    // Define player/entity state if not already there
    if(!entity.ravage)
      entity.ravage = { progress: 0 }
    if(target == KinkyDungeonPlayerEntity && !KinkyDungeonPlayerEntity.ravage)
      KinkyDungeonPlayerEntity.ravage = {
        slots: {
          ItemVulva: false,
          ItemMouth: false,
          ItemButt: false
        },
        narrationBuffer: [], // We store narration to be done in here and do it after tick, so it's all together
        submissionLevel: 0,
        submissionReason: false,
        submitting: false,
        showedSubmissionMessage: false,
      }
    // Define entity state and determine slot of choice
    let validSlots = []
    let slotsOccupied = 0
    for (const slot in KinkyDungeonPlayerEntity.ravage.slots) {
      if(
        KinkyDungeonPlayerEntity.ravage.slots[slot] == false &&
        (slot != "ItemButt" || (slot == "ItemButt" && KinkyDungeonSexyPlug)) && // Only does butt stuff if opted in
        enemy.ravage.targets.includes(slot)
      ) {
        validSlots.push(slot)
      } else {
        slotsOccupied++
      }
    }
    // Determine a new slot if new usage, or it was taken before they got the chance
    // If all slots are taken, gotta fallback
    // TODO: Prioritize oral if target is belted
    let canRavage = true
    RFTrace('[Ravager Framework DBG]: PlayerEffect validSlots; needs to choose slot: ', !entity.ravage.slot, '; slot ocuppier type = object: ', typeof KinkyDungeonPlayerEntity.ravage.slots[entity.ravage.slot] == "object", '; entity not in desired slot: ', (typeof KinkyDungeonPlayerEntity.ravage.slots[entity.ravage.slot] == "object" && KinkyDungeonPlayerEntity.ravage.slots[entity.ravage.slot] != entity), '; Total: ', !entity.ravage.slot || (typeof KinkyDungeonPlayerEntity.ravage.slots[entity.ravage.slot] == "object" && KinkyDungeonPlayerEntity.ravage.slots[entity.ravage.slot] != entity))
    RFTrace('[Ravager Framework DBG]: PlayerEffect validSlots; validSlots.length: ', validSlots.length)
    if(
      !entity.ravage.slot ||
      (
        typeof KinkyDungeonPlayerEntity.ravage.slots[entity.ravage.slot] == "object" &&
        KinkyDungeonPlayerEntity.ravage.slots[entity.ravage.slot] != entity
      )
    ) {
      RFDebug('[Ravager Framework]: validSlots: ', validSlots, '; entity.ravage.slot: ', entity.ravage.slot, '; entity not in desired player slot: ', KinkyDungeonPlayerEntity.ravage.slots[entity.ravage.slot] != entity, '; desired player slot: ', KinkyDungeonPlayerEntity.ravage.slots[entity.ravage.slot])
      if (validSlots.length)
        entity.ravage.slot = RFArrayRand(validSlots)
      else
        canRavage = false
    }
    RFTrace('[Ravager Framework DBG]: PlayerEffect validSlots; entity slot: ', entity.ravage.slot, '; canRavage: ', canRavage)

    ////////////////////////////////////////////////////////////////////////
    /* RAVAGE SECTION - If target is player, lower body is nude, and is pinned */
    RFTrace('[Ravager Framework DBG]: playerEffect section determination; target is player: ', target == KinkyDungeonPlayerEntity, '; canRavage: ', canRavage, '; uncovered[' + entity.ravage.slot + ']: ', uncovered[entity.ravage.slot], '; Pinned tag: ', Boolean(KinkyDungeonPlayerTags.get("Item_Pinned")), '; refractory: ', Boolean(entity.ravageRefractory))
    if(
      target == KinkyDungeonPlayerEntity &&
      canRavage &&
      uncovered[entity.ravage.slot] &&
      KinkyDungeonPlayerTags.get("Item_Pinned") && // Granted by "Pinned"
      !entity.ravageRefractory
    ) {
      // Mark this spot as properly claimed
      let slotOfChoice = entity.ravage.slot
      let pRav = KinkyDungeonPlayerEntity.ravage // Shortcut for readability
      pRav.slots[entity.ravage.slot] = entity
      entity.ravage.isRavaging = true
      // Also, ensure entity doesn't stop "playing" until done, if they are playing
      if (entity.playWithPlayer)
        entity.playWithPlayer++
      // Transfer leash to this caster
      // TODO: Check if this is causing the issues between ravagers and leashes
      let leash = KinkyDungeonGetRestraintItem("ItemNeckRestraints");
      if (leash && KDRestraint(leash).tether) {
        leash.tetherEntity = entity.id;
        KDGameData.KinkyDungeonLeashingEnemy = entity.id;
        leash.tetherLength = 1;
      }
      KinkyDungeonSetFlag("overrideleashprotection", 2);
      // Add occupied binding
      KinkyDungeonAddRestraintIfWeaker(entity.ravage.slot.replace("Item", "RavagerOccupied"))
      // If player waited, SP and WP damage is halved - counts as "submitting"
      // They can also unwillingly submit
      pRav.submitting = KinkyDungeonLastTurnAction == "Wait"
      pRav.submissionReason = KinkyDungeonFlags.get("playerStun") ? "You're too stunned to resist..." : "You moan softly as you let it happen..."
      pRav.submissionLevel = 0
      // Get submit chance
      let submitRoll = Math.random() * 100
      let baseSubmitChance = KinkyDungeonGoddessRep["Ghost"] + 30 // Starts at -50, this gives it some offset
      RFTrace('[Ravager Framework] Enemy: ', enemy)
      RFDebug('[Ravager Framework]: Checking for submitChanceModifierCallback ...')
      if (
        typeof enemy.ravage.submitChanceModifierCallback == 'string' &&
        KDEventMapEnemy['ravagerCallbacks'] &&
        typeof KDEventMapEnemy['ravagerCallbacks'][enemy.ravage.submitChanceModifierCallback] == 'function'
      ) {
        RFDebug('[Ravager Framework] Calling submitChanceModifierCallback from ravager ', entity, ' ...')
        let tmp_baseSubmitChance = KDEventMapEnemy['ravagerCallbacks'][enemy.ravage.submitChanceModifierCallback](entity, target, baseSubmitChance)
        switch (typeof tmp_baseSubmitChance) {
        case 'undefined':
          RFWarn(`[Ravager Framework] WARNING: Ravager ${enemy.name} (${TextGet('name' + enemy.name)}) used a submitChanceModifierCallback which returned no value! This result will be ignored. Please report this issue to the author of this ravager!`)
          break
        case 'number':
          baseSubmitChance = tmp_baseSubmitChance
          RFDebug(`[Ravager Framework] Base submit chance changed to ${baseSubmitChance}`)
          break
        default:
          RFWarn(`[Ravager Framework] WARNING: Ravager ${enemy.name} (${TextGet('name' + enemy.name)}) used a submitChanceModifierCallback which returned a non-number value (${tmp_baseSubmitChance})! This result will be ignored. Please report this issue to the author of this ravager!`)
          break
        }
      }
      // "Stronger" kinds of submission; submitting because of your leash is less likely than normal submission; submitting because of a lack of willpower is less likely than leash submission
      let leashSubmitChance = baseSubmitChance + 10
      let wpSubmitChance = leashSubmitChance + 10
      // While the submit chance is being rolled once per enemy, we want to pick the strongest submission reason for the whole turn. Lack of willpower submission overrides leash submission, leash submission overrides base submission
      if (
        pRav.submissionLevel < 3 &&
        KinkyDungeonStatWill == 0 &&
        (
          submitRoll < wpSubmitChance &&
          submitRoll > leashSubmitChance
        )
      ) {
        pRav.submissionReason = "(STUN) You can't will yourself to resist..."
        pRav.submitting = "forced"
        pRav.submissionLevel = 3
      } else if (
        pRav.submissionLevel < 2 &&
        leash &&
        (
          submitRoll < leashSubmitChance &&
          submitRoll > baseSubmitChance
        )
      ) {
        pRav.submissionReason = "(STUN) With a tug of your leash, you're put in your place..."
        pRav.submitting = "forced"
        pRav.submissionLevel = 2
      } else if (
        pRav.submissionLevel < 1 &&
        submitRoll < baseSubmitChance
      ) {
        pRav.submissionReason = "(STUN) Your submissiveness gets the better of you..."
        pRav.submitting = "forced"
        pRav.submissionLevel = 1
      }
      /* Determine string and severity of ravaging 
        Every ravaging enemy should have a range that contains all damage, etc.
        The first range with a number higher than the enemy's ravaging progress is selected, and its effects used.
      */
      let range = enemy.ravage.ranges.find(range => range[0] > entity.ravage.progress)
      // Helper to get what the previous range was for the sake of increase player ravaged counts 
      function getPreviousRange(currRange, enemy) {
        // TODO: Possibly clean this up by replacing findIndex with a check against entity.progress (possibly `enemy.ravage.ranges.findLast(range => range[0] <= entity.progress)`)
        return currRange ? enemy.ravage.ranges[enemy.ravage.ranges.findIndex((v) => { if (v == currRange) return true; }) - 1] : enemy.ravage.ranges.at(-1)
      }
      // Helper to increase player ravaged counts
      function increasePlayerRavagedCount(range, slot, target, enemy, assumeIncrement) {
        RFDebug('[Ravager Framework][increasePlayerRavagedCount]: range: ', range, '; slot: ', slot, '; target: ', target, '; enemy: ', enemy, '; assumeIncrement: ', assumeIncrement)
        // Bail if use-count-aware mode is disabled
        if (!RavagerGetSetting('ravEnableUseCount')) {
          RFDebug('[Ravager Framework][increasePlayerRavagedCount]: EA mode disabled. Bailing.')
          return
        }
        // Check that player.ravagedCount exists
        if (target.ravagedCounts == undefined) {
          RFDebug('[Ravager Framework][increasePlayerRavagedCount]: Creating player\'s ravagedCounts')
          target.ravagedCounts = {}
        }
        // Check for last incremented, so we don't repeatedly increment the same slot
        if (target.ravagedCounts.lastIncremented == undefined) {
          RFDebug('[Ravager Framework][increasePlayerRavagedCount]: Creating player\'s ravagedCounts.lastIncremented')
          target.ravagedCounts.lastIncremented = {}
        }
        if (range == undefined) {
          RFDebug('[Ravager Framework][increasePlayerRavagedCount]: Invalid range')
          return false
        } else if (target.ravagedCounts.lastIncremented[slot] == range[0]) {
          RFDebug('[Ravager Framework][increasePlayerRavagedCount]: Matched range against previous incremented range')
          return false
        } else {
          RFDebug('[Ravager Framework][increasePlayerRavagedCount]: Last incremented range not matching; deleting')
          delete target.ravagedCounts.lastIncremented[slot]
        }
        // Check the range's increment setting for all/specified slot
        let incCount = range[1].useCount
        if (incCount == undefined && assumeIncrement) { // Failed to think through the fact that we want to increment slots by default at the end. So if rangeData.useCount is missing, we default to incrementing by one for all slots. This should still respect being able to not increment on specific slots via making an object without that slot, or setting the slot to false, and disabling entirely by setting rangeData.useCount to false
          RFDebug('[Ravager Framework][increasePlayerRavagedCount]: Assuming increment by default; we\'re hopefully at the end of a session')
          incCount = 1
        }
        RFDebug('[Ravager Framework][increasePlayerRavagedCount]: incCount: ', incCount)
        if (incCount) {
          // Normalize incCount
          if ((typeof incCount).toLowerCase() == "object") {
            if (!incCount[slot])
              return false
            incCount = Number(incCount[slot])
          } else if (Number.isNaN(Number(incCount))) {
            incCount = 0
          } else {
            // Cast to Number to handle Boolean meaning increment by one
            incCount = Number(incCount)
          }
          RFDebug('[Ravager Framework][increasePlayerRavagedCount]: Normalized incCount: ', incCount)
          // Check if specified slot's use count is undefined
          if (target.ravagedCounts[slot] == undefined || target.ravagedCounts[slot] < 0) {
            // Set use count to range's increment count
            target.ravagedCounts[slot] = incCount
            RFDebug('[Ravager Framework][increasePlayerRavagedCount]: Set slot\'s count to ', incCount)
          } else {
            // Increment use count by range's increment count
            target.ravagedCounts[slot] += incCount
            RFDebug('[Ravager Framework][increasePlayerRavagedCount]: Incremented slot\'s count by ', incCount)
          }
          // TODO: Make sure this plays well with multiple ravagers incrementing multiple times mid-ravage
          target.ravagedCounts.lastIncremented[slot] = range[0]
          RFDebug('[Ravager Framework][increasePlayerRavagedCount]: Set slot\'s last incremented to ', range[0])
          return true
        } else {
          RFDebug('[Ravager Framework][increasePlayerRavagedCount]: incCount invalid')
          return false
        }
      }
      // If rangeData is null, the encounter is over, and doneDialogue should be used.
      if(range) {
        let rangeData = range[1]
        // Handle stat changes
        if(rangeData.sp)
          KDChangeStamina(undefined, undefined, undefined, pRav.submitting ? rangeData.sp * 0.25 : rangeData.sp)
        if(rangeData.wp)
          KDChangeWill(undefined, undefined, undefined, rangeData.wp)
        if(rangeData.sub)
          KinkyDungeonChangeRep("Ghost", rangeData.sub); // "Ghost" is submissiveness for some reason
        else if (pRav.submitting)
          KinkyDungeonChangeRep("Ghost", 0.25)
        if(rangeData.dp) { // We only try orgasm if DP is affected
          KDChangeDistraction(undefined, undefined, undefined, rangeData.dp)
          KinkyDungeonDoTryOrgasm((rangeData.orgasmBonus || 0) + slotsOccupied, 1)
        }
        // Helpers for use count based text
        function checkPreviousUseCount(slot) {
          return target.ravagedCounts && typeof target.ravagedCounts[slotOfChoice] == "number" && target.ravagedCounts[slot] > 0
        }
        function decideToDoExperiencedText(obj, slot, rangeData) {
          // Check that use-count-aware mode is enabled before continuing
          if (!RavagerGetSetting('ravEnableUseCount')) {
            RFDebug('[Ravager Framework][decideToDoExperiencedText]: EA mode disabled. Bailing.')
            return false
          }
          // Initial value, just checks that there is narration
          let result = Boolean(obj[1] && obj[1][slot])
          // Helper functions
          function experiencedTextDecideDefault() {
            return Math.random() < RavagerGetSetting('ravUseCountModeChance')
          }
          function experiencedTextDecideUser() {
            const pref = RavagerGetSetting('ravUseCountMode').toLowerCase()
            if (pref == 'sometimes') {
              return experiencedTextDecideDefault()
            } else if (pref == 'always') {
              return true
            } else {
              RFError('[Ravager Framework][decideToDoExperiencedText][experiencedTextDecideUser]: Invalid preference: ', pref)
              return false
            }
          }
          function experiencedTextDecideRavager() {
            return rangeData.experiencedAlways || (rangeData.hasOwnProperty('experiencedChance') ? (Math.random() < rangeData.experiencedChance) : experiencedTextDecideDefault())
          }
          const tryUser = RavagerGetSetting('ravUseCountMode').toLowerCase() != 'any'
          const tryRav = rangeData.hasOwnProperty('experiencedChance') || rangeData.experiencedAlways
          if (RavagerGetSetting('ravUseCountOverride')) {
            if (tryUser) {
              result = result && experiencedTextDecideUser()
            } else if (tryRav) {
              result = result && experiencedTextDecideRavager()
            } else {
              result = result && experiencedTextDecideDefault()
            }
          } else {
            if (tryRav) {
              result = result && experiencedTextDecideRavager()
            } else if (tryUser) {
              result = result && experiencedTextDecideUser()
            } else {
              result = result && experiencedTextDecideDefault()
            }
          }
          // Return
          return result
        }
        // Next, handle dialogue/narration
        // Use count based narration
        let didExperiencedNarration = false
        if (checkPreviousUseCount(slotOfChoice) && rangeData.experiencedNarration) {
          let eNarr = rangeData.experiencedNarration.findLast((range) => { if (range[0] <= target.ravagedCounts[slotOfChoice]) return true; })
          if (decideToDoExperiencedText(eNarr, slotOfChoice, rangeData)) {
            pRav.narrationBuffer.push(RavagerData.functions.NameFormat(RFArrayRand(eNarr[1][slotOfChoice]), entity))
            didExperiencedNarration = true
          }
        }
        if (rangeData.narration && !didExperiencedNarration)
          pRav.narrationBuffer.push(RavagerData.functions.NameFormat(RFArrayRand(rangeData.narration[slotOfChoice]), entity))
        // Use count based taunts
        let didExperiencedTaunt = false
        if (checkPreviousUseCount(slotOfChoice) && rangeData.experiencedTaunts) {
          let eTaunt = rangeData.experiencedTaunts.findLast((range) => { if (range[0] <= target.ravagedCounts[slotOfChoice]) return true; })
          if (decideToDoExperiencedText(eTaunt, slotOfChoice, rangeData)) {
            KinkyDungeonSendDialogue(entity, RavagerData.functions.NameFormat(RFArrayRand(eTaunt[1][slotOfChoice]), entity), KDGetColor(entity), 6, 6)
            didExperiencedTaunt = true
          }
        }
        if (rangeData.taunts && !didExperiencedNarration)
          KinkyDungeonSendDialogue(entity, RavagerData.functions.NameFormat(RFArrayRand(rangeData.taunts), entity), KDGetColor(entity), 6, 6)
        if(rangeData.dp) { // Only do floaty sound effects if DP is being applied, since that means action is happening
          if(enemy.ravage.onomatopoeia)
            KinkyDungeonSendFloater(entity, RFArrayRand(enemy.ravage.onomatopoeia), "#ff00ff", 2);
        }
        // Status effect application/precautions
        KinkyDungeonApplyBuffToEntity(KinkyDungeonPlayerEntity, KDRavaged) // Blinds player
        KinkyDungeonApplyBuffToEntity(entity, KDRavaging) // Keeps enemy in one place
        if (!entity.Enemy.ravage.bypassAll)
          KinkyDungeonAddRestraintIfWeaker("Stripped") // Stay stripped

        if(pRav.submitting) { // When submitting, offset the "self-play" cost associated with doTryOrgasm
          if(KinkyDungeonStatStamina > 3)
            KDChangeStamina(undefined, undefined, undefined, KinkyDungeonEdgeCost * -1) // TODO: --- Haven't figured out yet, but this seems to be meant to reduce stamina loss when submitting, but it makes no difference and in fact results in not draining stamina
          KinkyDungeonSendActionMessage(20, pRav.submissionReason + ` (Reduced SP loss)`, "#dd00dd", 1, false, true);
        }
        if(pRav.submitting == "forced") {
          KDStunTurns(1)
          KinkyDungeonSendFloater(KinkyDungeonPlayerEntity, "SUBMIT!", "#ff00ff", 2);
        }
        entity.ravage.progress++
        RFDebug('[Ravager Framework] Checking for range callback at range ', range[1], ' ...')
        if (
          typeof rangeData.callback == 'string' &&
          KDEventMapEnemy['ravagerCallbacks'] &&
          typeof KDEventMapEnemy['ravagerCallbacks'][rangeData.callback] == 'function'
        ) {
          RFDebug('[Ravager Framework] Calling rangeData callback for range ', range[1], ' ...') // TODO: Expand parameters to include ravage progress and rangeData
          KDEventMapEnemy['ravagerCallbacks'][rangeData.callback](entity, target, entity.ravage.slot)
        }
        if (
          typeof enemy.ravage.allRangeCallback == 'string' &&
          KDEventMapEnemy['ravagerCallbacks'] &&
          typeof KDEventMapEnemy['ravagerCallbacks'][enemy.ravage.allRangeCallback] == 'function'
        ) {
          RFDebug('[Ravager Framework] Calling all range callback ', enemy.ravage.allRangeCallback, ' ...')
          KDEventMapEnemy['ravagerCallbacks'][enemy.ravage.allRangeCallback](entity, target, entity.ravage.slot)
        }
        RFDebug('[Ravager Framework]: Attempting to increment slot use count...')
        increasePlayerRavagedCount(getPreviousRange(range, enemy), slotOfChoice, target, enemy)
      } else {      
        // Done playing, if they were
        if(entity.playWithPlayer)
          entity.playWithPlayer = 0
        // If player doesn't pass out, just remove that enemy from slot and reset progress, give self a cooldown timer
        let passedOut = false
        if(KinkyDungeonStatWill != 0 || KinkyDungeonStatStamina > 1) {
          // Set 'refractory' on self and clear slot used
          KinkyDungeonRemoveRestraintsWithName(`${entity.ravage.slot.replace("Item", "RavagerOccupied")}`)
          pRav.slots[entity.ravage.slot] = false
          entity.ravageRefractory = enemy.ravage.refractory
          KDBreakTether(KinkyDungeonPlayerEntity) // Chances are, this enemy was holding the tether
          delete entity.ravage
          KinkyDungeonSendActionMessage(45, RavagerData.functions.NameFormat(RavagerData.defaults.releaseMessage, entity), "#e0e", 4) // Maybe make this controllable by a rav dev?
        } else { // Pass out!
          KinkyDungeonSendActionMessage(45, RavagerData.defaults.passoutMessage, "#ee00ee", 4);
          KinkyDungeonPassOut()
          passedOut = true
        }
        // Check for increasing ravaged count
        RFDebug('[Ravager Framework]: Attempting to increment slot use count at end of session...')
        increasePlayerRavagedCount(getPreviousRange(range, enemy), slotOfChoice, target, enemy, !(enemy.ravage.ranges.filter(v => v[1].useCount).length > 0))
        if (enemy.ravage.doneTaunts)
          KinkyDungeonSendDialogue(entity, RavagerData.functions.NameFormat(RFArrayRand(enemy.ravage.doneTaunts), entity), KDGetColor(entity), 6, 6)
        if (
          typeof enemy.ravage.completionCallback == 'string' &&
          KDEventMapEnemy['ravagerCallbacks'] &&
          typeof KDEventMapEnemy['ravagerCallbacks'][enemy.ravage.completionCallback] == 'function'
        ) {
          RFDebug('[Ravager Framework] Calling completion callback ', enemy.ravage.completionCallback, ' ...')
          KDEventMapEnemy['ravagerCallbacks'][enemy.ravage.completionCallback](entity, target, passedOut)
        }
        // Character gets exhausted by this interaction.
        KinkyDungeonSleepiness = 4
      }
    }
    ////////////////////////////////////////////////////////////////////////
    /* STRIP/PIN SECTION - If target is player, has belt/plugs, or has lower body clothing */
    else if (
      target == KinkyDungeonPlayerEntity &&
      canRavage &&
      (
        !uncovered[entity.ravage.slot] ||
        !KinkyDungeonPlayerTags.get("Item_Pinned")
      ) &&
      !entity.ravageRefractory
    ) {
      // Remove restraints first, THEN clothing, then pin once ready
      if (stripOptions.equipment[entity.ravage.slot].length) {
        // Since we want to go in order - remove mask before gag, etc
        let input = stripOptions.equipment[entity.ravage.slot][0]
        let targetRestraint
        let specific = false
        if (typeof input == "object") { // May pass specific restraints in the case of non-mouth-slot mouth coverings
          targetRestraint = input
          specific = true
        } else { // This is just the group string selection
          targetRestraint = KinkyDungeonGetRestraintItem(input)
        }
        // Determine removal progress here - TODO base on power, but first we need to make sure other enemies
        // Can't just add restraints mid-ravage
        let canBeRemoved = false
        let restraintRef = KinkyDungeonGetRestraintByName(targetRestraint)
        if (specific) {
          KinkyDungeonRemoveRestraintSpecific(targetRestraint, true, false, false, false, false, entity)
        } else {
          KinkyDungeonRemoveRestraint(input, true, false, false, false, false, entity)
        }
        KinkyDungeonSendTextMessage(10, RavagerData.functions.NameFormat(RavagerData.defaults.restraintTearMessage, entity, targetRestraint), "#f00", 4) // TODO: Maybe make this controllable for a rav dev?
      } else if (stripOptions.clothing[entity.ravage.slot].length) {
        RFTrace('[Ravager Framework DBG]: PlayerEffect stripping clothing; clothing strip options: ', stripOptions.clothing[entity.ravage.slot])
        let stripped = stripOptions.clothing[entity.ravage.slot][0]
        RFTrace('[Ravager Framework DBG]: PlayerEffect stripping clothing; stripped: ', stripped)
        RFTrace('[Ravager Framework DBG]: PlayerEffect stripping clothing; slot check; slot not = ItemMouth: ', entity.ravage.slot != "ItemMouth", '; !getRestraintItem ItemPelvis: ', !KinkyDungeonGetRestraintItem("ItemPelvis"), '; clothing includes shorts, bikini, or panties: ', ["Shorts", "Bikini", "Panties"].some(str => stripped.Item.includes(str)), '; Total: ', entity.ravage.slot != "ItemMouth" && !KinkyDungeonGetRestraintItem("ItemPelvis") && ["Shorts", "Bikini", "Panties"].some(str => stripped.Item.includes(str)))
        if (
          entity.ravage.slot != "ItemMouth" &&
          !KinkyDungeonGetRestraintItem("ItemPelvis") &&
          ["Shorts", "Bikini", "Panties"].some(str => stripped.Item.includes(str))
        ) {
          if (!entity.Enemy.ravage.bypassAll)
            KinkyDungeonAddRestraintIfWeaker("Stripped") // Since panties are sacred normally
        }
        KinkyDungeonSendTextMessage(10, RavagerData.functions.NameFormat(RavagerData.defaults.clothingTearMessage, entity, undefined, stripped), "#f00", 4) // TODO: Maybe make this controllable for a rav dev?
        RFTrace('[Ravager Framework DBG]: PlayerEffect stripping clothing; stripped.Lost = ', stripped.Lost)
        stripped.Lost = true
        RFTrace('[Ravager Framework DBG]: PlayerEffect stripping clothing; stripped.Lost = ', stripped.Lost)
      } else {
        KinkyDungeonAddRestraintIfWeaker("Pinned")
        KinkyDungeonSendTextMessage(10, RavagerData.functions.NameFormat(RavagerData.defaults.pinMessage, entity), "#f0f", 4)
      }
      KinkyDungeonDressPlayer()
      return { sfx: "Miss", effect: true };
    }
    ////////////////////////////////////////////////////////////////////////
    /* ATTACK SECTION - A basic distraction add if ineligible for other stuff */
    /* We're adding an ability to apply restraints instead of deal grope damage ~CTN */
    else {
      if (
        typeof enemy.ravage.fallbackCallback == 'string' &&
        KDEventMapEnemy['ravagerCallbacks'] &&
        typeof KDEventMapEnemy['ravagerCallbacks'][enemy.ravage.fallbackCallback] == 'function'
      ) { // Call the ravager's custom fallback if available
        RFDebug('[Ravager Framework] Calling fallback callback: ', enemy.ravage.fallbackCallback, ' ...')
        KDEventMapEnemy['ravagerCallbacks'][enemy.ravage.fallbackCallback](entity, target)
      } else { // Otherwise, we'll do the default fallback
        // Restraint adding
        let didRestrain = false
        if (typeof enemy.ravage.restrainChance == 'number' && Math.random() < enemy.ravage.restrainChance) {
          RFDebug('[Ravager Framework] We\'re trying to add a restraint to the player during fallback!')
          // Get jail restraints -- we're using these until I can figure out how to get a specific set of jail restraints or until I can be bothered to make a way of cleanly defining a list of restraints in the ravager declaration
          let possibleRestraints = KDGetJailRestraints()
          // Filter out restraints that can't be added
          possibleRestraints = possibleRestraints.filter(item => KDCanAddRestraint(KinkyDungeonGetRestraintByName(item.Name)))
          RFDebug('[Ravager Framework] Valid restraints for fallback: ', possibleRestraints)
          // Check that the possible restraints list is not empty
          if (possibleRestraints.length > 0) {
            // Pick a random restraint from possibilities
            let canidateRestraint = KinkyDungeonGetRestraintByName(possibleRestraints[Math.floor(Math.random() * possibleRestraints.length)].Name)
            // Check that canidate is not invalid
            if (canidateRestraint) {
              // Try to add that restraint to player
              try { // This might fail with a TypeError if the game cannot find canidate for some reason
                let ret = KinkyDungeonAddRestraintIfWeaker(canidateRestraint)
                // If we succeeded, print a message about that and set didRestrain to true
                if (ret) {
                  KinkyDungeonSendTextMessage(10, RavagerData.functions.NameFormat(RavagerData.defaults.addRestraintMessage, entity, canidateRestraint), "#f0f", 4)
                  didRestrain = true
                }
              } catch (e) {
                RFWarn('[Ravager Framework] Caught error while adding a restraint as a fallback: ', e)
              }
            } else { RFError('[Ravager Framework] CANIDATE RESTRAINT INVALID! ', canidateRestraint) }
          }
        }
        // Grope damage dealing
        if (!didRestrain) {
          RFDebug('[Ravager Framework] We DIDN\'T add a restraint, let\'s grope')
          let dmg = KinkyDungeonDealDamage({damage: 1, type: "grope"});
          if (!enemy.ravage.noFallbackNarration) {
            if (enemy.ravage.fallbackNarration) {
              KinkyDungeonSendTextMessage(10, RavagerData.functions.NameFormat(RFArrayRand(enemy.ravage.fallbackNarration), entity, undefined, undefined, dmg), "#f0f", 4)
            } else {
              KinkyDungeonSendTextMessage(10, RavagerData.functions.NameFormat(RavagerData.defaults.fallbackNarration, entity, undefined, undefined, dmg), "#f0f", 4)
            }
          } else {
            RFDebug('[Ravager Framework] ', enemy.name, ' requests no fallback narration.')
          }
        }
      }
    }
    return {sfx: "Struggle", effect: true};
  }
  return {sfx: "Struggle", effect: true};
}

// Handles preventing enemies from interfering with ravaging, with some narration included
KDEventMapInventory["tickAfter"]["ravagerSitDownAndShutUp"] = (e, item, data) => {
  RFDebug("[RavagerFramework] [ravagerSitDownAndShutUp]\ne: ", e, "\nitem: ", item, "\ndata: ", data)
  let nearby = KDNearbyEnemies(KinkyDungeonPlayerEntity.x, KinkyDungeonPlayerEntity.y, 5)
  let stunnedCount = 0
  let enemyName = ""
  nearby.forEach(enemy => {
    // Make sure we're only stunning non-ravagers
    if (!enemy.Enemy.ravage) {
      RFDebug("[RavagerFramework] [ravagerSitDownAndShutUp] Stunning ", enemy.Enemy.name)
      // Stun 2 will stun an enemy for only the next turn
      enemy.stun = 2
      // We'll count an enemy for the witness narration if they're not a beast and haven't already been in a narration
      if (!enemy.Enemy.tags.beast && !enemy.witnessedRavaging) {
        // Hacky work around for resetting witness state causing an extra narration on the last turn of ravaging
        if (enemy.witnessedRavagingJustDeleted) {
          delete enemy.witnessedRavagingJustDeleted
        } else {
          // Count how many new witnesses there are, save their name incase there's only one, and label them as witnesses
          stunnedCount++
          enemyName = enemy.Enemy.name
          enemy.witnessedRavaging = true
        }
      }
    }
  })
  // If there's new witnesses, send narration depending on how many new witnesses there are
  if (stunnedCount > 0) {
    let msg = ""
    if (stunnedCount === 1) {
      msg = "The nearby " + TextGet("Name" + enemyName) + " notices your predicament and stays to watch"
    } else {
      msg = "Your situation attracts some attention nearby"
    }
    KinkyDungeonSendTextMessage(5, msg, "#ff5be9", 4);
  }
}

// Each tick, check to see if the player is still pinned by anyone
KDEventMapInventory["tickAfter"]["ravagerPinCheck"] = (e, item, data) => {
  RFTrace('[Ravager Framework][ravagerPinCheck]: e: ', e, '; item: ', item, '; data: ', data)
  let nearby = KDNearbyEnemies(KinkyDungeonPlayerEntity.x, KinkyDungeonPlayerEntity.y, 4)
  let cleared = true
  RFTrace('[Ravager Framework][ravagerPinCheck]: nearby: ', nearby)
  nearby.forEach(enemy=>{
    RFTrace('[Ravager Framework][ravagerPinCheck]: enemy: ', enemy, '; ravage: ', enemy.ravage, '; stun: ', enemy.stun, '; ravageRefractory: ', enemy.ravageRefractory)
    if (enemy.ravage && !enemy.stun && !enemy.ravageRefractory) {
      RFTrace(`[Ravager Framework][ravagerPinCheck]: Found enemy playing with player! (${enemy.id})`)
      cleared = false
      enemy.playWithPlayer = 5 // Keep them playing until they're done
    }
  })
  if (cleared) {
    RFTrace('[Ravager Framework][ravagerPinCheck]: Player is free, clearing all data ...')
    RavagerFreeAndClearAllData();
  } else {
    RFTrace('[Ravager Framework][ravagerPinCheck]: Player is NOT free, applying block and evasion penalties ...')
    KinkyDungeonApplyBuffToEntity(KinkyDungeonPlayerEntity, {
      id: "RavagerNoDodge",
      duration: 1,
      type: "EvasionPenalty",
      power: 100,
    });
    KinkyDungeonApplyBuffToEntity(KinkyDungeonPlayerEntity, {
      id: "RavagerNoBlock",
      duration: 1,
      type: "BlockPenalty",
      power: 100,
    });
  }
}

// For occupied, make sure pinned is still there; if pinned is gone, occupied should be too
KDEventMapInventory["tickAfter"]["RavagerCheckForPinned"] = (e, item, data) => {
  let remove = false
  for (const inv of KinkyDungeonAllRestraint()) {
    if (inv.name == "Pinned")
      remove = true
  }
  if (remove)
    KDRemoveThisItem(item)
}

// We handle narration in an event since it's easier to get everything across multiple enemies grouped nicely this way
KDEventMapInventory["tickAfter"]["ravagerNarration"] = (e, item, data) => {
  let playerRavage = KinkyDungeonPlayerEntity.ravage
  RFDebug('[Ravager Framework][ravagerNarration] ', playerRavage)
  if (playerRavage) {
    playerRavage.narrationBuffer.forEach(narration => {
      KinkyDungeonSendActionMessage(20, narration, "#ff00ff", 1, false, true);
    })
    playerRavage.narrationBuffer = []
  }
}

// In case the player passes out for unrelated reasons
if (!KDEventMapInventory["passout"])
  KDEventMapInventory["passout"] = {}
KDEventMapInventory["passout"]["ravagerRemove"] = (e, item, data) => {
  RFTrace('[Ravager Framework][passout/ravagerRemove]: e: ', e, '; item: ', item, '; data: ', data, '; Calling RavagerFreeAndClearAllData')
  RavagerFreeAndClearAllData()
  // Keep panties gone as a souvenir
  setTimeout(() =>
    KDGetDressList()[KinkyDungeonCurrentDress].forEach(article => {
      if (["Panties"].some(str => article.Item.includes(str))) {
        article.Lost = true
      }
    }), 1)
}

// If pin is broken: resets ravage, clears leash, and stuns ravagers
KDEventMapInventory["remove"]["ravagerRemove"] = (e, item, data) => {
  RFTrace('[Ravager Framework][remove/ravagerRemove]: e: ', e, '; item: ', item, '; data: ', data)
  if (data.item.name == item.name) { // To make sure the item being removed is Pinned
    RFTrace(`[Ravager Framework][remove/ravagerRemove]: data.item.name (${data.item.name}) == item.name (${item.name}). Calling RavagerFreeAndClearAllDataIfNoRavagers`)
    RavagerFreeAndClearAllDataIfNoRavagers()
  }
}

// Remove pin if this enemy was the last one ravaging on death
KDEventMapEnemy["death"]["ravagerRemove"] = (e, enemy, data) => {
  RFTrace('[Ravager Framework][death/ravagerRemove]: e: ', e, '; enemy: ', enemy, '; data: ', data)
  if (enemy.hp > 0) {
    RFTrace('[Ravager Framework][death/ravagerRemove]: Enemy NOT dead! GTFO (' + enemy.Enemy.name + ')')
    return
  }
  if (enemy.ravage && KinkyDungeonPlayerEntity.ravage) {
    RFTrace('[Ravager Framework][death/ravagerRemove]: enemy.ravage && KinkyDungeonPlayerEntity.ravage passed, calling RavagerFreeAndClearAllDataIfNoRavagers')
    RavagerFreeAndClearAllDataIfNoRavagers()
  }
} 

// Remove refractory on ravagers each turn
if (!KDEventMapEnemy["tickAfter"])
  KDEventMapEnemy["tickAfter"] = {}
KDEventMapEnemy["tickAfter"]["ravagerRefractory"] = (e, enemy, data) => {
  if (enemy?.ravageRefractory > 0)
    enemy.ravageRefractory--
}
