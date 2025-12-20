// Keep track of our own mod.json
fetch(KDModFiles['Game/mod.json']).then(response => response.blob()).then(blob => {
  const reader = new FileReader();
  reader.onload = () => {
    window.RavagerData.ModInfo = JSON.parse(reader.result);
  };
  reader.readAsText(blob);
}).catch(error => {
  console.error("[Ravager Framework] Caught error while reading mod.json", error);
})

// Add our debug callbacks for the sake of the example ravager
let debugCallbacks = {
  'debugFallbackCallback': (enemy, target) => {
    console.log('[Ravager Framework] Debug fallback narration callback! Here\'s what you have available to you: enemy (Type: ', typeof enemy, '): ', enemy, '; target (Type: ', typeof target, '): ', target)
  },
  'debugCompletionCallback': (enemy, target, passedOut) => {
    console.log('[Ravager Framework] Debug completion callback! Here\'s what you have available to you: enemy (Type: ', typeof enemy, '): ', enemy, '; target (Type: ', typeof target, '): ', target, '; passedOut (Type: ', typeof passedOut, '): ', passedOut)
  },
  'debugAllRangeCallback': (enemy, target, itemGroup) => {
    console.log('[Ravager Framework] Debug all-range callback! Here\'s what you have available to you: enemy (Type: ', typeof enemy, '): ', enemy, '; target (Type: ', typeof target, '): ', target, '; itemGroup (Type: ', typeof itemGroup, '): ', itemGroup)
    console.log('[Ravager Framework] Please note: This callback currently doesn\'t tell you what progress value or ravage range is triggering this call. This is something I may add soon, as I can think up a handful of uses for that info :)')
    console.log('[Ravager Framework] Incase you need to know what range you\'re operating in, you can get the range data and the ravage progress via "enemy.Enemy.ravage.ranges" and "enemy.ravage.progress" respectively')
  },
  'debugSubmitChanceModifierCallback': (enemy, target, baseSubmitChance) => {
    console.log('[Ravager Framework] Debug submit chance modifier callback! Here\'s what you have available to you: enemy (Type: ', typeof enemy, '): ', enemy, '; target (Type: ', typeof target, '): ', target, '; baseSubmitChance (Type: ', typeof baseSubmitChance, '): ', baseSubmitChance)
    console.log('[Ravager Framework] Don\'t forget the submiteChanceModifierCallback needs to return a number between 0 and 100 for submission chance!')
    return baseSubmitChance
  },
  'debugRangeX': (enemy, target, itemGroup) => {
    console.log('[Ravager Framework] Debug range X callback! Here\'s what you have available: enemy (Type: ', typeof enemy, '): ', enemy, '; target (Type: ', typeof target, '): ', target, '; itemGroup (Type: ', typeof itemGroup, '): ', itemGroup)
  },
  'debugEffectCallback': (enemy, target) => {
    console.log('[Ravager Framework] Debug effect callback! Here\'s what you have available: enemy (Type: ', typeof enemy, '): ', enemy, '; target (Type: ', typeof target, '): ', target)
    return false
  }
}
for (var key in debugCallbacks) {
  if (!RavagerAddCallback(key, debugCallbacks[key]))
    RFError('[Ravager Framework] Failed to add debug callback: ', key)
}

// Add Ravager Control to the game's custom screen list
// The game will look in KDRender for a key matching the value of KinkyDungeonState, and run the function in that key as the draw function
KDRender.RavagerControl = RavagerData.functions.RFControlRun
