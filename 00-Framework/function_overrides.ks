// Here so I can remove the messages from Attack{EnemyName}* during the ravage event (those messages are all the same and always end with "(no damage)", and they interupt my narration)
KinkyDungeonSendTextMessage = function(priority, text, color, time, noPush, noDupe, entity, filter) {
  if (text.match(/^~~\{RavagerFrameworkNoMessageDisplay\}~~/)) {
    RavagerData.Variables.RFControl.DebugVanillaTextOverrides && RFDebug('[Ravager Framework][KinkyDungeonSendTextMessage]: Found ravager string to skip.')
    return false
  }
  RavagerData.Variables.RFControl.DebugVanillaTextOverrides && RFDebug('[Ravager Framework][KinkyDungeonSendTextMessage]: priority: ', priority, '; text: ', text, '; color: ', color, '; time: ', time, '; noPush: ', noPush, '; noDupe: ', noDupe, '; entity: ', entity, '; filter: ', filter)
  return RavagerData.functions.KinkyDungeonSendTextMessage(priority, text, color, time, noPush, noDupe, entity, filter)
}

// Overriding item drops so I can have multiple drops from enemies
KDDropItems = function(enemy, mapData) {
  if (RavagerGetSetting("ravagerCustomDrop") && (enemy.Enemy.addedByMod == "RavagerFramework" || enemy.Enemy.ravagerCustomDrop) && enemy.Enemy.maxDrops) {
    RFTrace(`[Ravager Framework][DBG][KDDropItems]: Dropping items for enemy: ${enemy.Enemy.name}(${enemy.x}, ${enemy.y}): `, enemy)
    // Multiple drops for enemies that have a maxDrops value, are either added by me or want multiple drops via truthy ravagerCustomDrop, and when custom drop setting is enabled
    if (!enemy.noDrop && (enemy.playerdmg || !enemy.summoned) && !enemy.droppedItems) {
      // Set drop count to max
      let dropCount = enemy.Enemy.maxDrops
      RFTrace("[Ravager Framework][DBG][KDDropItems]: Drop count initialized to maxDrops: " + dropCount)
      // If there's a minDrops, pick a random number between min and max (inclusive)
      if (typeof enemy.Enemy.minDrops == "number") {
        dropCount = Math.floor(Math.random() * (dropCount - enemy.Enemy.minDrops + 1)) + enemy.Enemy.minDrops
      } else {
        dropCount = Math.floor(Math.random() * dropCount) + 1
      }
      RFTrace("[Ravager Framework][DBG][KDDropItems]: Drop count changed to " + dropCount)
      //
      let dropped = []
      let dropTable = structuredClone(enemy.Enemy.dropTable)
      // Loop the drop call until we reach drop count
      for (let i = 0; i < dropCount; i++) {
        if (dropTable.length == 0) {
          RFTrace(`[Ravager Framework][DBG][KDDropItems]: Ran out of items in drop table on loop count ${i} for enemy ${enemy.Enemy.name}(${enemy.x}, ${enemy.y})`)
          break
        }
        let item = KinkyDungeonItemDrop(enemy.x, enemy.y, dropTable, enemy.summoned)
        if (!item)
          RFTrace(`[Ravager Framework][DBG][KDDropItems]: KinkyDungeonItemDrop chose not to drop an item on loop count ${i} for enemy ${enemy.Enemy.name}(${enemy.x}, ${enemy.y})`)
        else {
          dropped.push(item)
          RFTrace(`[Ravager Framework][DBG][KDDropItems]: KinkyDungeonItemDrop dropped ${item.name} ` + (item.amount ? `(x${item.amount})` : "") + `(${item.x}, ${item.y}) for enemy ${enemy.Enemy.name}(${enemy.x}, ${enemy.y})`, item)
          let removed = dropTable.splice(dropTable.findIndex(v => v.name == item.name), 1)
          RFTrace(`[Ravager Framework][DBG][KDDropItems]: Removed ${removed[0].name} from drop table.`, removed)
        }
      }
      RFTrace(`[Ravager Framework][DBG][KDDropItems]: All items dropped for enemy ${enemy.Enemy.name}(${enemy.x}, ${enemy.y}): `, dropped)
      // The call we need to change in order to get multiple items
      enemy.droppedItems = enemy.droppedItems || Boolean(dropped.length)
      RFTrace(`[Ravager Framework][DBG][KDDropItems]: Has enemy ${enemy.Enemy.name}(${enemy.x}, ${enemy.y}) dropped items? ` + enemy.droppedItems)
    }
  }
  return RavagerData.functions.KDDropItems(enemy, mapData)
}

// Here so I can have a colored button in mod config and description popups for my mod configs
DrawButtonKDEx = function(name, func, enabled, Left, Top, Width, Height, Label, Color, Image, HoveringText, Disabled, NoBorder, FillColor, FontSize, ShiftText, options) {
  if (KinkyDungeonState == "ModConfig") {
    if (name == "Ravager Framework") {
      // Change the color of my mod config button
      Color = "#ff66ff"
      FillColor = "#330033"
    } else if (KDModToggleTab == "RavagerFramework") {
      // Setup description popups
      let possibleNewName = name.replace(/ModRangeButton[L|R]?/, "")
      if (RavagerData.ModConfig[possibleNewName] && RavagerData.ModConfig[possibleNewName].hoverDesc && !RavagerData.Variables.ModConfig.BoxData[possibleNewName]) {
        RavagerData.Variables.ModConfig.BoxData[possibleNewName] = {
          name: possibleNewName,
          Left: Left,
          Top: Top,
          Width: RavagerData.ModConfig[possibleNewName].type.match(/list|range/) ? 500 : Width,
          Height: Height,
          Text: TextGetKD(`KDModButton${possibleNewName}`),
          hoverDesc: RavagerData.ModConfig[possibleNewName].hoverDesc,
          modPage: KDModPage
        }
      }
    }
  }
  // Run and return the original DrawButtonKDEx
  return RavagerData.functions.DrawButtonKDEx(name, func, enabled, Left, Top, Width, Height, Label, Color, Image, HoveringText, Disabled, NoBorder, FillColor, FontSize, ShiftText, options)
}

// Just here so I can have custom checkbox images in mod config
DrawCheckboxKDEx = function(name, func, enabled, Left, Top, Width, Height, Text, IsChecked, Disabled, TextColor, _CheckImage, options) {
  if (KinkyDungeonState == "ModConfig" && KDModToggleTab == "RavagerFramework")
    _CheckImage = "UI/HeartChecked.png"
  return RavagerData.functions.DrawCheckboxKDEx(name, func, enabled, Left, Top, Width, Height, Text, IsChecked, Disabled, TextColor, _CheckImage, options)
}

// Override so I can draw a custom button on the in-game pause menu
KinkyDungeonDrawGame = function() {
  // Avoid weirdness with custom draw states -- Leaving RavagerControl (via `KinkyDungeonDrawState = "Restart"`) was putting the game in the Perks2 state -- Likely caused by the fact that pressing the Return button was also clicking on whatever button is in that spot on the screen you're returning to. This is also causing the main menu version to possibly end up in the credits and patrons screens, depending where you click, so this nonsense will be sticking around
  if (typeof RavagerData.Variables.DrawState == "string")
    if (RavagerData.Variables.DrawState == KinkyDungeonDrawState)
      delete RavagerData.Variables.DrawState
    else
      KinkyDungeonDrawState = RavagerData.Variables.DrawState
  // Call original function
  const ret = RavagerData.functions.KinkyDungeonDrawGame()
  // Draw my own button in the in-game pause screen
  if (
    KinkyDungeonState == "Game" && // In-game
    KinkyDungeonDrawState == 'Restart' && // Pause menu
    TestMode && // Debug enabled at title
    KDDebugMode && // Debug enabled in pause menu
    RavagerData.Variables.RFControl.InGameEnabled // Has double headpatted the character
  ) {
    DrawButtonKDEx(
      'ravagerControl',
      () => {
        RavagerData.Variables.PrevState = KinkyDungeonState
        RavagerData.Variables.PrevDrawState = KinkyDungeonDrawState
        KinkyDungeonState = "RavagerControl"
      },
      true,
      1650,
      830,
      300,
      64,
      'Ravager Hacking',
      '#f6f',
      "",
      undefined,
      false,
      false,
      '#303'
    )
  }
  // Return whatever the original function returned, just in case KinkyDungeonDrawGame ever returns anything
  return ret
}

// Override so I can draw a custom button on the title screen, as well as handling my custom menu
KinkyDungeonRun = function() {
  // Avoid same weirdness as custom KinkyDungeonDrawGame
  if (typeof RavagerData.Variables.State == "string")
    if (RavagerData.Variables.State == KinkyDungeonState)
      delete RavagerData.Variables.State
    else
      KinkyDungeonState = RavagerData.Variables.State
  // Run the original KinkyDungeonRun
  const ret = RavagerData.functions.KinkyDungeonRun()
  // Turn off the in-init flag when the player interacts with anything other than mod config
  // The reason not to unset it when opening mod config is because the "I want to help debug" config is not persistent and may be turned on by the user as the first thing they do, which means we still want to capture the log lines produced during the entirety of a settings refresh
  // KDEventMapGeneric['afterModConfig']['RavagerFramework'] (called after the user exits mod config) will unset the init flag AFTER calling RavagerFrameworkSettingsRefresh
  if (_RavagerFrameworkInInit && !(KinkyDungeonState == "Menu" || KinkyDungeonState == "ModConfig"))
    _RavagerFrameworkInInit = false
  // Draw ravager control button on title screen; only when debug mode has been enabled, disabled, enabled again, and is currently enabled
  if (
    KinkyDungeonState == "Menu" &&
    RavagerData.Variables.DebugWasTurnedOn &&
    RavagerData.Variables.DebugWasTurnedOff &&
    TestMode
  ) {
    DrawButtonKDEx(
      'ravagerControl',
      () => {
        RavagerData.Variables.PrevState = KinkyDungeonState
        RavagerData.Variables.PrevDrawState = KinkyDungeonDrawState
        KinkyDungeonState = "RavagerControl"
      },
      true,
      525,
      926,
      300,
      64,
      'Ravager Hacking',
      '#f6f',
      "",
      undefined,
      false,
      false,
      '#303'
    )
  } else if (KinkyDungeonState == "ModConfig" && KDModToggleTab == "RavagerFramework") {
    // Drawing the description popup when hovering an option that has one
    let modConfig = RavagerData.Variables.ModConfig
    for (let data in modConfig.BoxData) {
      let o = modConfig.BoxData[data]
      if (o.modPage != KDModPage)
        continue
      if (MouseIn(o.Left, o.Top, o.Width, o.Height)) {
        let mult = KDGetFontMult()
        let descSettings = modConfig.Desc
        let boxSettings = modConfig.Box
        let textSplit = KinkyDungeonWordWrap(o.hoverDesc, 20 * mult, 40 * mult).split("\n")
        let bPadV = boxSettings.PadV
        // Figure out the box size based on the number of description lines and all the padding needed
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
          'RFModConfigHover_' + o.name,
          {
            Left: bLeft,
            Top: bTop,
            Width: bWidth,
            Height: bHeight,
            Color: "#200020",
            zIndex: bZIndex,
            alpha: 0.85
          }
        );
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
        );
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
  // Detect enabling, disabling, then enabling debug mode for enabling ravager control button
  if (TestMode) {
    // Track first enable of debug mode
    if (!RavagerData.Variables.DebugWasTurnedOn)
      RavagerData.Variables.DebugWasTurnedOn = true
  } else {
    // Track first disable of debug mode
    if (RavagerData.Variables.DebugWasTurnedOn && !RavagerData.Variables.DebugWasTurnedOff)
      RavagerData.Variables.DebugWasTurnedOff = true
  }
  // Return the result of original KinkyDungeonRun incase it ever returns anything
  return ret
}

// Override so I can detect headpatting the character in the pause menu
// Seems this needs to be extended if I want to have click sounds for the ravager control menu, as this function's return value is the decider on whether to play the sound or not
// Either this function needs to check for clicks on all my custom buttons, or my custom buttons need to be able to set a flag that will get combined with the return value
// Although, the in-game pause menu seems to have click sounds regardless of if you click on a button or the background, so a catch for KinkyDungeonState == "RavagerControl" could do
KinkyDungeonHandleClick = function(event) {
  let ret = RavagerData.functions.KinkyDungeonHandleClick(event);
  // Catch headpatting the character preview while in the in-game pause menu to toggle ravager control
  if (
    KinkyDungeonState == "Game" && // In-game
    KinkyDungeonDrawState == "Restart" && // Pause menu
    TestMode && // Debug mode enabled at title screen
    KDDebugMode && // Debug mode enabled in pause menu
    MouseIn(144.422, 86.7996, 133.68, 41.775) // Headpat character
  ) {
    // Gotta headpat twice to enable ravager control
    if (RavagerData.Variables.RFControl.WasEnabledInGame)
      RavagerData.Variables.RFControl.InGameEnabled = !RavagerData.Variables.RFControl.InGameEnabled
    else
      RavagerData.Variables.RFControl.WasEnabledInGame = true
    // Set ret so it'll play a sound
    ret = true
  }
  // Enable sounds for my custom buttons
  if (!ret) {
    for (let b of Object.keys(KDButtonsCache).filter(v => v.startsWith("RFControl") || v.startsWith("ravager"))) {
      let btn = KDButtonsCache[b]
      if (
        btn &&
        btn.enabled &&
        MouseIn(btn.Left, btn.Top, btn.Width, btn.Height)
      ) {
        RFTrace(`[RF][KinkyDungeonHandleClick]: Clicked on button ${b}. Sound will be made.`)
        ret = true
        break
      }
    }
  }
  //
  return ret
}

// Currently just used for the mimic spoiler, but there's other ideas of how this can be used, so I've attempted to generalize it
KinkyDungeonDrawEnemiesHP = function(delta, canvasOffsetX, canvasOffsetY, CamX, CamY, _CamXoffset, _CamYoffset) {
  // Firstly, call the original function; we'll probably have some bailing happening later
  const ret = RavagerData.functions.KinkyDungeonDrawEnemiesHP(delta, canvasOffsetX, canvasOffsetY, CamX, CamY, _CamXoffset, _CamYoffset)
  // Get all enemies
  const nearby = KDNearbyEnemies(KinkyDungeonPlayerEntity.x, KinkyDungeonPlayerEntity.y, KDGameData.MaxVisionDist + 1, undefined, true)
  // Loop enemies
  for (var entity of nearby) {
    // Convinience reference to entity.Enemy
    const enemy = entity.Enemy
    // If there's one of our bubbles, check what to do about it
    if (entity.ravBubble) {
      // Expired
      if (KinkyDungeonCurrentTick > entity.ravBubble.index + entity.ravBubble.duration) {
        RFDebug('[Ravager Framework][KinkyDungeonDrawEnemiesHP]: Bubble expired for enemy' + entity.Enemy.name + '(' + entity.id + ')')
        delete entity.ravBubble
      } else {
        // If the player can't see the enemy, there's no need to draw a bubble; bail
        if (!RFPlayerCanSeeEnemy(entity))
          continue
        // Does the enemy define a condition?
        const hasCond = enemy.ravage.hasOwnProperty('bubbleCondition')
        // Does said condition correspond to a function to call?
        const execCond = hasCond && typeof enemy.ravage.bubbleCondition == 'string' && typeof RavagerData.conditions[enemy.ravage.bubbleCondition] == 'function'
        // If there's no condition, continue to drawing
        if (hasCond) {
          // If the condition is a function and that function returns false, bail
          if (execCond && !RavagerData.conditions[enemy.ravage.bubbleCondition](entity))
            continue
          // If the condition isn't a function and that value evaluates to false, bail
          else if (!execCond && !enemy.ravage.bubbleCondition)
            continue
        }
        // If we make it here, we should be drawing the bubble
        KDDraw(
          kdenemystatusboard,
          kdpixisprites,
          entity.id + "ravBubble",
          KinkyDungeonRootDirectory + `Conditions/RavBubble/${entity.ravBubble.name}.png`,
          canvasOffsetX + ((entity.visual_x ? entity.visual_x : entity.x) - CamX) * KinkyDungeonGridSizeDisplay,
          canvasOffsetY + ((entity.visual_y ? entity.visual_y : entity.y) - CamY) * KinkyDungeonGridSizeDisplay - KinkyDungeonGridSizeDisplay / 2,
          KinkyDungeonGridSizeDisplay,
          KinkyDungeonGridSizeDisplay,
          undefined,
          { zIndex: 25 }
        )
      }
    }
  }
  //
  return ret
}
