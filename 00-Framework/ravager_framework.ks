/* 
	RAVAGER FRAMEWORK 0.01
	No enemies are added by this file. It's just the framework.
	This mod adds a very dynamic playerEffect that lets enemies do the following in order of priority:

	SELECTION ++ The enemy selects a player slot to use based on specified preferences. Currently just butt/vulva/mouth itemgroups.

	STRIP/PIN ++ If target is player, has clothes in the way, or isn't pinned:
		- Pick a blocking restraint to remove. Presently just immediately removes it. End turn.
		- If no restraints in the way, pick an outfit/clothing item in the way, immediately removes it. End turn.

	RAVAGE ++ If target is player, is pinned, and the slot of choice is unoccupied (OR occupied by the entity attacking)
		- Marks the slot of choice as occupied by "this" enemy, so others pick different ones
		- Steals the leash if the player is leashed, so that they don't get dragged away mid-ravage.
		- If the enemy's ravage.progress value is within one of their specified ranges (this will make sense later), execute and end turn.
			- Progresses through tiers of effects, defined in the enemy object. Typically outlines increasing intensity up to orgasm.
			- Can damage SP, WP, Distraction, and also modify Submissiveness.
			- Has enemy-specified narration and 'taunts'.
			- ACTUALLY USES SUBMISSIVENESS - Player has up to an 70% chance to "Submit" (be stunned for a turn) based on a calculation of submissiveness, whether they're leashed, and whether their WP is 0.
			- You can also specify a custom function to call for each individual range if you want.
		
		- If the enemy's ravage.progress value is higher than all of their ranges, assumes that they're done and executes the 'done' state.
			- Player will pass out if SP and WP are low enough
			- Otherwise, they'll stay awake and the enemy will just enter a cooldown refractory period where they can't ravage (but can fallback attack)
			- Also, there's a callback for when an enemy's done, too. We love callbacks here. 

	FALLBACK ++ If target is NOT player, OR target is an NPC, OR all slots are already occupied (unlikely but possible), OR in refractory mode
		- Just deal some weak grope damage. End turn.
		- You can also specify a function to call instead if you want to do something special.

	An example enemy is defined below and appears prominently with other bandits, presently.
	They're a little overpowered, so they'll probably be removed from regular spawning eventually (or restricted)
	This way this mod can be more about providing the system to other modders.
*/

/* 
	top priority next updates:
		- GENERICIZE SLOTS
			- We should have it be possible for any enemy to want to occupy any slot at all. Head, legs, anything. Not sure how anyone would use all of them (like, hands? arms? what?), but the point is being able to have the option.
	
		- RAVAGE INTERRUPTIONS
			- maybe solved?

		- STRIP
			- Need to make stripping restraints in the way take a while. Maybe scale based on power.	
				- not resolved - just have them removing for now. gotta come up with a good idea for this
		
		- TARGETING
			- Prioritize 'easy' slots first. Should be done after stripping is handled.
				- i.e., rank slots based on the power of everything in the way. go after the lowest
	
	interesting other leads:
		see "PunishPlayer" event - possible event for struggling while pinned
*/


/**********************************************
 * BELOW THIS POINT ARE FUNCTIONS YOU DON'T REALLY NEED TO WORRY ABOUT
 * IF YOU'RE JUST MAKING SOME ENEMIES WHO USE RAVAGE, REFER TO Enemies/exampleEnemy.js !
 * 
 * PlayerEffect definition
 * Ravage is one big effect that encompasses all high-impact lewd activity
 * Ideally usable by any enemy, but it should be their "main thing" that they do, otherwise it gets weird/slow. You could play with ranges to make a mixed enemy work though.
 * Has three effects:
 	* ATTACK: If non-player or otherwise ineligible for the main course, the target just takes DP damage.
	* STRIP/PIN: If player and has clothing covering pelvis, or belted/vulva-plugged, remove. Lastly pins, preparing for the third phase.
	* RAVAGE: If player and has exposed + unoccupied pelvis/vulva item groups, enter a sex state with increasing intensity
*/
// Function to add callbacks
/**********************************************
 * Callback definition helper
 * This function is a simple helper the I would recommend using if you're going to add callbacks for your ravager.
 * Takes two parameters:
 * 	- The key which will be used to reference your callback. This is the value to use when setting a callback value inside your ravager's definition.
 * 	- The function to use as a callback. 
 * Note: If you decide to not use this function, there are two things you need to know:
 * 	- If RavagerFramework itself does not load before your enemy, KDEventMapEnemy['ravagerCallbacks'] will not exist yet. This will cause the game will show a crash if you try to add a callback entry into that map, and that will cause execution of your JS file to stop at that line, potentially causing your ravager to never be added to the game
 * 	- Your function should be the value of KDEventMapEnemy['ravagerCallbacks'][<callback name>]
*/
window.RavagerAddCallback = (key, func) => {
	if (!KDEventMapEnemy['ravagerCallbacks']) {
		KDEventMapEnemy['ravagerCallbacks'] = {}
		if (!KDEventMapEnemy['ravagerCallbacks']) {
			throw new Error('[Ravager Framework] Failed to initialize the ravager callbacks key! Something seems to have gone very wrong. Please report this to the Ravager Framework with as much info as you can provide.')
		}
	}
	console.log('[Ravager Framework] Adding callback function with key: ', key)
	KDEventMapEnemy['ravagerCallbacks'][key] = func
	return Boolean(KDEventMapEnemy['ravagerCallbacks'][key])
}

// Add our callbacks key
if (! KDEventMapEnemy['ravagerCallbacks']) {
	KDEventMapEnemy['ravagerCallbacks'] = {}
}
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
		console.error('[Ravager Framework] Failed to add debug callback: ', key)
}

// Hidden option to enable way too many console messages
window._RavagerFrameworkDebugEnabled = false;
window.RavagerFrameworkDebug = function() {
	if (_RavagerFrameworkDebugEnabled) {
		console.log('[Ravager Framework] Serious debug mode disabled.')
		_RavagerFrameworkDebugEnabled = false
	} else {
		console.log('[Ravager Framework] Serious debug mode enabled. Hope you like lots of text and variables!')
		_RavagerFrameworkDebugEnabled = true
	}
}
// Developer helper function to verify a ravager's EAM values
window.RavagerFrameworkVerifyEAM = function(ravagerName) {
	const ravager = KDEnemiesCache.get(ravagerName)
	// Check that enemy exists
	if (!ravager) {
		console.error('[RavagerFrameworkVerifyEAM] Could not find an enemy by the name of ', ravagerName)
		return false
	}
	// Check for ravager.ravage to make sure this is a ravager
	if (!ravager.ravage) {
		console.error('[RavagerFrameworkVerifyEAM] Enemy does not have a "ravage" property. Either you\'re checking the wrong enemy, or you\'ve defined your ravager wrong.')
		return false
	}
	// Check that ravager has ranges
	if (!ravager.ravage.ranges || ravager.ravage.ranges.length < 1) {
		console.error('[RavagerFrameworkVerifyEAM] Ravager has no ranges. This ravager will be unable to ravage the player.')
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
			console.error('[RavagerFrameworkVerifyEAM] Invalid range: ', range)
			// return false
			failedRanges.push(range)
			continue
		}
		const rangeData = range[1]
		// Log about use count
		if (rangeData.hasOwnProperty('useCount')) {
			let useCount = rangeData.useCount
			if (typeof useCount == undefined) {
				console.warn('[RavagerFrameworkVerifyEAM] Range ', range, ' has useCount defined, but it is set to undefined. Doing so is not well tested. If this is not your last range, the expected behavior is to block incrementing use count, but that is unnecessary, as that is the default bahvior. If this is in your last range, this will result in incrementing the use count by 1 regardless of slot. It is recommended you either remove this setting if it is not in your last range, or set useCount to 0 if this is in your last range and you wish to block incrementing use counts.')
			} else if (typeof useCount == 'number') {
				if (useCount == 0)
					console.log('[RavagerFrameworkVerifyEAM] Range ', range, ' has useCount set to zero. If this is the last range, this will prevent incrementing use counts. If this is not the last range, this setting is unnecessary.')
				else if (useCount < 0)
					console.log('[RavagerFrameworkVerifyEAM] Range ', range, ' has useCount set to a negative value. This will result in DECREMENTING use counts instead of incrementing them.')
				else if (useCount > 0)
					console.log('[RavagerFrameworkVerifyEAM] Range ', range, ' will increment use counts by ', useCount, ' for every slot')
				else
					console.error('[RavagerFrameworkVerifyEAM] wtf just happened? (useCount = number)')
			} else if (typeof useCount == 'object') {
				let hasSlots = false
				if (useCount.hasOwnProperty('ItemVulva')) {
					console.log('[RavagerFrameworkVerifyEAM] Range ', range, ' will increment use count for ItemVulva by ', useCount.ItemVulva)
					hasSlots = true
				}
				if (useCount.hasOwnProperty('ItemMouth')) {
					console.log('[RavagerFrameworkVerifyEAM] Range ', range, ' will increment use count for ItemMouth by ', useCount.ItemMouth)
					hasSlots = true
				}
				if (useCount.hasOwnProperty('ItemButt')) {
					console.log('[RavagerFrameworkVerifyEAM] Range ', range, ' will increment use count for ItemButt by ', useCount.ItemButt)
					hasSlots = true
				}
				if (useCount.hasOwnProperty('ItemHead')) {
					console.log('[RavagerFrameworkVerifyEAM] Range ', range, ' will increment use count for ItemHead by ', useCount.ItemHead)
					hasSlots = true
				}
				if (!hasSlots) {
					console.warn('[RavagerFrameworkVerifyEAM] Range ', range, ' defines useCount as a dictionary, but has no slots. This will result in never incrementing use counts.')
				}
			} else {
				console.error('[RavagerFrameworkVerifyEAM] Range ', range, ' has useCount set to an unknown type. This scenario is untested. If you beleive this is a mistake, please report the issue. Otherwise, it is recommended to fix your definition of useCount.')
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
					console.warn('[RavagerFrameworkVerifyEAM] This range has an invalid EAM taunt definition: ', count)
					if (!eamFailedRanges.includes(count))
						eamFailedRanges.push(count)
					continue
				}
				let countData = count[1]
				// Track if this taunt range has any slots
				let hasSlots = false
				// Check for each slot
				// const hasSlots = countData.hasOwnProperty('ItemVulva') || countData.hasOwnProperty('ItemButt') || countData.hasOwnProperty('ItemMouth') || countData.hasOwnProperty('ItemHead')
				for (var slot of [ 'ItemVulva', 'ItemMouth', 'ItemButt', 'ItemHead' ]) {
					// let slotValid = countData.hasOwnProperty(slot)
					// let slotWasValid = slotValid
					if (!countData.hasOwnProperty(slot))
						continue
					let stringsValid = Array.isArray(countData[slot])
					if (!stringsValid) {
						console.warn('[RavagerFrameworkVerifyEAM] Range ', count, ' contains a value which isn\'t an array for slot ', slot)
						continue
					}
					for (var string of countData[slot]) {
						stringsValid = stringsValid && typeof string == 'string'
					}
					if (!stringsValid) {
						console.warn('[RavagerFrameworkVerifyEAM] Range ', count, ' contains taunts which are not strings in slot "' + slot + '". This isn\'t necessarily fatal, but should still be fixed.')
					}
					// hasSlots = hasSlots || stringsValid
					hasSlots = true
				}
				// Warn if there's no slots
				if (!hasSlots)
					console.warn('[RavagerFrameworkVerifyEAM] Range ', count, ' doesn\'t appear to have any slots assigned. A use count range with no slots assigned is either defined wrong, or shouldn\'t be defined. Check for earlier errors or remove this range.')
				tauntsValid = tauntsValid && hasSlots
			}
			if (!tauntsValid)
				console.warn('[RavagerFrameworkVerifyEAM] experiencedTaunts is defined for range ' + range[0] + '. Either experiencedTaunts is invalid or shouldn\'t be defined. Please check for previous errors and warnings.')
			hasEAMProps = hasEAMProps || tauntsValid
		}
		// Check for narration
		if (rangeData.hasOwnProperty('experiencedNarration')) {
			let narrationValid = true
			for (var count of rangeData.experiencedTaunts) {
				if (count.length < 2 || !count[1]) {
					console.warn('[RavagerFrameworkVerifyEAM] This range has an invalid EAM narration definition: ', count)
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
						console.warn('[RavagerFrameworkVerifyEAM] Range ', count, ' contains a value which isn\'t an array for slot ', slot)
						continue
					}
					for (var string of countData[slot]) {
						stringsValid = stringsValid && typeof string == 'string'
					}
					if (!stringsValid) {
						console.warn('[RavagerFrameworkVerifyEAM] Range ', count, ' contains narrations which are not strings in slot "' + slot + '". This isn\'t necessarily fatal, but should still be fixed.')
					}
					hasSlots = true
				}
				if (!hasSlots)
					console.warn('[RavagerFrameworkVerifyEAM] Range ', count, ' doesn\'t appear to have any slots assigned. A use count range with no slots assigned is either defined wrong, or shouldn\'t be defined. Check for earlier errors or remove this range.')
				narrationValid = narrationValid && hasSlots
			}
			if (!narrationValid)
				console.warn('[RavagerFrameworkVerifyEAM] experiencedNarration is defined for range ' + range[0] + '. Either experiencedNarration is invalid or shouldn\'t be defined. Please check for previous errors and warnings.')
			hasEAMProps = hasEAMProps || narrationValid
		}
		//
		let hasChance = rangeData.hasOwnProperty('experiencedChance')
		let hasAlways = rangeData.hasOwnProperty('experiencedAlways')
		//
		if (!hasEAMProps && (hasChance || hasAlways)) {
			console.warn('[RavagerFrameworkVerifyEAM] Range ', range, 'defines EAM chance or always, but does not appear to have any valid taunts or narrations. Without taunts or narrations to use, EAM text will not be used, and the chance and always settings are pointless')
		}
		//
		hasEAMProps = hasEAMProps || hasChance || hasAlways
		//
		if (hasChance && hasAlways && rangeData.experiencedAlways) {
			console.warn('[RavagerFrameworkVerifyEAM] Range ', range, ' defines both experiencedChance and experiencedAlways. experiencedAlways overrides experiencedChance, so it\'s pointless to have them both declared at the same time.')
			continue
		}
		// Check for chance
		if (hasChance && rangeData.experiencedChance <= 0) {
			console.warn('[RavagerFrameworkVerifyEAM] Range ', range, ' has experiencedChance set to or below 0. This setting will result in EAM text never being used unless the user overrides your ravager\'s preference.')
		}
		// Check for always
		if (hasAlways && !rangeData.experiencedAlways) {
			console.warn('[RavagerFrameworkVerifyEAM] Range ', range, ' has experiencedAlways set to false. Doing so is entirely unneeded, as this setting only has any effect when true.')
		}
		hasEAMRanges = hasEAMRanges || hasEAMProps
	}
	// Bail on failed ranges
	if (failedRanges.length > 0) {
		console.error('[RavagerFrameworkVerifyEAM] The following ranges are invalid and may cause crashes: ', failedRanges)
		return false
	}
	// Bail of EAM failures in ranges
	if (eamFailedRanges.length > 0) {
		console.error('[RavagerFrameworkVerifyEAM] The following ranges have invalid EAM properties and may cause crashes: ', eamFailedRanges)
		return false
	}
	//
	if (!hasEAMRanges) {
		console.error('[RavagerFrameworkVerifyEAM] Ravager doesn\'t appear to have any ranges with valid EAM properties.')
		return false
	}
	return true
}
// Function to get a mod setting value. If settings are undefined, it'll return the default value given to KDModConfigs. If there is not matching value given to KDModConfigs, 
window.RavagerGetSetting = function(refvar) {
	const settings = KDModSettings.RavagerFramework
	var config = RavagerData.ModConfig.find((val) => { if (val.refvar == refvar) return true; })
	function RFConfigDefault(refvar, config) {
		if (config == undefined) {
			console.error('[Ravager Framework]: RavagerGetSetting couldn\'t find ModConfig values for ' + refvar + ' !')
			return undefined
		}
		return config.default
	}
	if (!settings) {
		console.warn('[Ravager Framework]: RavagerGetSetting couldn\'t get current settings for the framework!')
		return RFConfigDefault(refvar, config)
	}
	if (settings[refvar] == undefined) {
		console.warn('[Ravager Framework]: RavagerGetSetting couldn\'t get the current setting for ' + refvar)
		return RFConfigDefault(refvar, config)
	}
	return settings[refvar]
}
window.RavagerData = {
	KDEventMapGeneric: {
		beforeDamage: {
			RavagerSoundHit: (e, item, data) => { RavagerSoundGotHit = true }
		},
		tick: {
			RavagerSoundTick: (e, item, data) => { RavagerSoundGotHit = false }
		}
	},
	KDExpressions: {
		RavagerSoundHit: {
			stackable: true,
			priority: 108,
			criteria: (C) => {
				if (C == KinkyDungeonPlayer && (RavagerSoundGotHit || KDUniqueBulletHits.has('undefined[object Object]_player'))) {
					RavagerSoundGotHit = false
					KinkyDungeonInterruptSleep()
					console.log('enableSound: ', RavagerGetSetting('ravagerEnableSound'), '\nvolume: ', RavagerGetSetting('ravagerSoundVolume') / 2, '\nonHitChance: ', RavagerGetSetting('onHitChance'))
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
		RavagerSoundOrgasm: {
			stackable: true,
			priority: 90,
			criteria: (C) => {
				if (C == KinkyDungeonPlayer && KinkyDungeonFlags.get("OrgSuccess") == 7) {
					if (KDToggles.Sound && RavagerGetSetting('ravagerEnableSound')) {
						AudioPlayInstantSoundKD(KinkyDungeonRootDirectory + "Audio" + (KinkyDungeonGagTotal > 0 ? "GagOrgasm.ogg" : "Ah1 liliana.ogg"), RavagerGetSetting('ravagerSoundVolume') / 2)
					}
					KinkyDungeonSendTextMessage(8, "You make a loud moaning noise", "#1fffc7", 1);
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
		DrawButtonKDEx: DrawButtonKDEx,
		NameFormat: function(string, entity, restraint, clothing, damage, skipCapitalize) {
			_RavagerFrameworkDebugEnabled && console.log('[Ravager Framework][DBG][NameFormat]: Initial string "' + string + '"; entity: ', entity)
			// Player name
			string = string.replace("PlayerName", KDGameData.PlayerName)
			_RavagerFrameworkDebugEnabled && console.log('[Ravager Framework][DBG][NameFormat]: Transformed to "' + string + '"')
			// Enemy name
			if (entity) {
				// Definition name
				string = string.replace("EnemyName", TextGet('Name' + entity.Enemy.name))
				// Possible custom entity name (no formatting)
				string = string.replace("EnemyCNameBare", KDEnemyName(entity))
				// Possible custom entity name (w/ formatting)
				string = string.replace("EnemyCName", entity.CustomName || KDGetName(entity.id) || "the " + TextGet("Name" + entity.Enemy.name))
			_RavagerFrameworkDebugEnabled && console.log('[Ravager Framework][DBG][NameFormat]: Transformed to "' + string + '"')
			}
			// Restraint name
			if (restraint) {
				string = string.replace("RestraintName", TextGet('Restraint' + restraint.name))
			_RavagerFrameworkDebugEnabled && console.log('[Ravager Framework][DBG][NameFormat]: Transformed to "' + string + '"')
			}
			// Clothing name
			if (clothing) {
				string = string.replace("ClothingName", TextGet("m_" + clothing.Item).includes("[NotFound]") ? clothing.Item : TextGet("m_" + clothing.Item))
			_RavagerFrameworkDebugEnabled && console.log('[Ravager Framework][DBG][NameFormat]: Transformed to "' + string + '"')
			}
			// Damage string
			if (damage) {
				string = string.replace("DamageTaken", damage.string)
			_RavagerFrameworkDebugEnabled && console.log('[Ravager Framework][DBG][NameFormat]: Transformed to "' + string + '"')
			}
			// Capitalize
			if (!skipCapitalize)
				string = string.replaceAt(0, string[0].toUpperCase())
			return string
		},
	},
	defaults: {
		releaseMessage: "You feel weak as EnemyCName releases you...",
		passoutMessage: "Your body is broken and exhausted...",
		restraintTearMessage: "EnemyCName tears your RestraintName away!",
		clothingTearMessage: "EnemyCName tears your ClothingName away!",
		pinMessage: "EnemyCName gets a good grip on you...",
		addRestraintMessage: "EnemyCName forces you to wear a RestraintName",
		fallbackNarration: "EnemyCName roughly gropes you! (DamageTaken)",

	},
	ModConfig: [
		{
			type: 'boolean',
			refvar: 'ravagerDebug',
			default: false,
			block: undefined
		},
		{
			// name: 'Disable Bandit Ravager',
			type: 'boolean',
			refvar: 'ravagerDisableBandit',
			default: false,
			block: undefined
		},
		{
			// name: 'Disable Wolfgirl Ravager',
			type: 'boolean',
			refvar: 'ravagerDisableWolfgirl',
			default: false,
			block: undefined
		},
		{
			// name: 'Disable Slimegirl Ravager',
			type: 'boolean',
			refvar: 'ravagerDisableSlimegirl',
			default: false,
			block: undefined
		},
		{
			// name: 'Disable Tentacle Pit',
			type: 'boolean',
			refvar: 'ravagerDisableTentaclePit',
			default: false,
			block: undefined
		},
		{
			// name: 'Spicy Ravager Tendril Dialogue',
			type: 'boolean',
			refvar: 'ravagerSpicyTendril',
			default: false,
			block: undefined
		},
		{
			type: 'range',
			name: 'Slimegirl Restrict Chance', // A workaround for the game's code requiring ranges to have a name property for all but the last range; should be temporary
			refvar: 'ravagerSlimeAddChance',
			default: 0.05,
			rangelow: 0,
			rangehigh: 1,
			stepcount: 0.01,
			block: undefined
		},
		{
			type: 'boolean',
			refvar: 'ravagerEnableSound',
			default: true,
			block: undefined
		},
		{
			type: 'range',
			name: 'Hit Sound Chance', // A workaround for the game's code requiring ranges to have a name property for all but the last range; should be temporary
			refvar: 'onHitChance',
			default: 0.3,
			rangelow: 0,
			rangehigh: 1,
			stepcount: 0.05,
			block: undefined
		},
		{
			type: 'range',
			name: 'Sound Effect Volume', // A workaround for the game's code requiring ranges to have a name property for all but the last range; should be temporary
			refvar: 'ravagerSoundVolume',
			default: 1,
			rangelow: 0,
			rangehigh: 2,
			stepcount: 0.05,
			block: undefined
		},
		{
			type: 'boolean',
			refvar: 'ravEnableUseCount',
			default: true,
			block: undefined
		},
		{
			type: 'list',
			name: 'ravUseCountMode', // Needed for proper declaration of the left and right selection buttons
			refvar: 'ravUseCountMode',
			options: [ 'Any', 'Sometimes', 'Always' ],
			default: 'Any',
			block: undefined
		},
		{
			type: 'range',
			name: 'ravUseCountModeChance',
			refvar: 'ravUseCountModeChance',
			default: 0.75,
			rangelow: 0,
			rangehigh: 1,
			stepcount: 0.05,
			block: undefined
		},
		{
			type: 'boolean',
			refvar: 'ravUseCountOverride',
			default: false,
			block: undefined
		}
	]
}
DrawButtonKDEx = function(name, func, enabled, Left, Top, Width, Height, Label, Color, Image, HoveringText, Disabled, NoBorder, FillColor, FontSize, ShiftText, options) {
	if (name == "Ravager Framework") {
		Color = "#ff66ff"
		FillColor = "#330033"
		// NoBorder = true
	}
	return RavagerData.functions.DrawButtonKDEx(name, func, enabled, Left, Top, Width, Height, Label, Color, Image, HoveringText, Disabled, NoBorder, FillColor, FontSize, ShiftText, options)
}

// Base settings function, simplifying reloading settings
function ravagerSettingsRefresh(reason) {
	console.log('[Ravager Framework] Running settings functions for reason: ' + reason)
	ravagerFrameworkRefreshEnemies(reason)
	ravagerFrameworkApplySpicyTendril(reason)
	ravagerFrameworkApplySlimeRestrictChance(reason)
	ravagerFrameworkSetupSound(reason)
	console.log('[Ravager Framework] Finished running settings functions')
}
// Change slime girl's chance to add slime to the player
function ravagerFrameworkApplySlimeRestrictChance(reason) {
	console.log('[Ravager Framework] ravagerFrameworkApplySlimeRestrictChance(' + reason + ')')
	var settings = KDModSettings['RavagerFramework'];
	var dbg = settings && settings.ravagerDebug;
	dbg && console.log('[Ravager Framework] Setting Slime Girl\'s restrict chance to ' + settings.ravagerSlimeAddChance)
	var slimeIndex = KinkyDungeonEnemies.findIndex(val => { if (val.name == 'SlimeRavager' && val.addedByMod == 'RavagerFramework') return true });
	if (!settings.ravagerDisableSlimegirl && slimeIndex >= 0) {
		var slime = KinkyDungeonEnemies[slimeIndex]
		slime.ravage.addSlimeChance = settings.ravagerSlimeAddChance
		dbg && console.log('[Ravager Framework] Refreshing enemy cache')
		KinkyDungeonRefreshEnemiesCache()
	}
}
// Mod settings for changing spicy dialogue for tendril
// This NEEDS to be run AFTER ravagerFrameworkRefreshEnemies, as this relies on enemy enabled state being consistent with the relevant setting
function ravagerFrameworkApplySpicyTendril(reason) {
	console.log('[Ravager Framework] ravagerFrameworkApplySpicyTendril(' + reason + ')')
	// Shortcut for settings
	var settings = KDModSettings['RavagerFramework']
	var dbg = settings && settings.ravagerDebug;
	dbg && console.log('[Ravager Framework] Tentacle Pit Spicy Dialogue set to ', settings.ravagerSpicyTendril)
	// Check index for tendril
	var tendrilIndex = KinkyDungeonEnemies.findIndex(val => { if (val.name == 'RavagerTendril' && val.addedByMod == 'RavagerFramework') return true })
	// Only run if tendril is not disabled and is present
	if (!settings.ravagerDisableTentaclePit && tendrilIndex >= 0) {
		// Shortcut for tendril
		var tendril = KinkyDungeonEnemies[tendrilIndex]
		// Check whether spicy or not
		if (settings.ravagerSpicyTendril) {
			// Change to spicy
			for (var range of tendril.ravage.ranges) {
				range[1].narration.ItemVulva = range[1].narration.SpicyItemVulva
				range[1].narration.ItemButt = range[1].narration.SpicyItemButt
				range[1].narration.ItemMouth = range[1].narration.SpicyItemMouth
			}
		} else {
			// Change to tame
			for (var range of tendril.ravage.ranges) {
				range[1].narration.ItemVulva = range[1].narration.TameItemVulva
				range[1].narration.ItemButt = range[1].narration.TameItemButt
				range[1].narration.ItemMouth = range[1].narration.TameItemMouth
			}
		}
		dbg && console.log('[Ravager Framework] Tentacle Pit ranges before refresh: ', tendril.ravage.ranges)
		KinkyDungeonRefreshEnemiesCache()
		dbg && console.log('[Ravager Framework] Tentacle Pit ranges after refresh: ', tendril.ravage.ranges)
	}
}
// Mod Settings for disabling ravagers
function ravagerFrameworkRefreshEnemies(reason) {
	console.log('[Ravager Framework] ravagerFrameworkRefreshEnemies(' + reason + ')')
	// Shortcut for settings
	var settings = KDModSettings['RavagerFramework']
	let dbg = settings && settings.ravagerDebug;
	// Checking for bandit
	var banditFoundIndex = KinkyDungeonEnemies.findIndex((val) => { if (val.name == 'BanditRavager' && val.addedByMod == 'RavagerFramework') return true })
	// Check if we're supposed to be removing or adding the ravager
	if (settings.ravagerDisableBandit) {
		// Remove ravager
		// Check the returned index of the ravager. Will be >= 0 if it exists, but -1 if not
		if (banditFoundIndex >= 0) {
			// Log message
			dbg && console.log('[Ravager Framework] Removing Bandit Ravager')
			// Remove the ravager
			KinkyDungeonEnemies.splice(banditFoundIndex, 1)
		}
	} else {
		// Ensure ravager is present
		if (banditFoundIndex < 0 || banditFoundIndex == undefined) {
			// Log message
			dbg && console.log('[Ravager Framework] Adding Bandit Ravager')
			// Add ravager to enemy list. To simplify this ability, I've stored the ravager definition in the event map dictionary I'm already using for callbacks
			KinkyDungeonEnemies.push(KDEventMapEnemy['ravagerCallbacks']['definitionBanditRavager'])
		}
	}
	// Checking for slime
	var slimeFoundIndex = KinkyDungeonEnemies.findIndex((val) => { if (val.name == 'SlimeRavager' && val.addedByMod == 'RavagerFramework') return true })
	// Check if we're supposed to be removing or adding the ravager
	if (settings.ravagerDisableSlimegirl) {
		// Remove ravager
		// Check the returned index of the ravager. Will be >= 0 if it exists, but -1 if not
		if (slimeFoundIndex >= 0) {
			// Log message
			dbg && console.log('[Ravager Framework] Removing Slime Ravager')
			// Remove the ravager
			KinkyDungeonEnemies.splice(slimeFoundIndex, 1)
		}
	} else {
		// Ensure ravager is present
		if (slimeFoundIndex < 0 || slimeFoundIndex == undefined) {
			// Log message
			dbg && console.log('[Ravager Framework] Adding Slime Ravager')
			// Add ravager to enemy list. To simplify this ability, I've stored the ravager definition in the event map dictionary I'm already using for callbacks
			KinkyDungeonEnemies.push(KDEventMapEnemy['ravagerCallbacks']['definitionSlimegirlRavager'])
		}
	}
	// // Checking for wolf
	var wolfFoundIndex = KinkyDungeonEnemies.findIndex((val) => { if (val.name == 'WolfgirlRavager' && val.addedByMod == 'RavagerFramework') return true })
	// Check if we're supposed to be removing or adding the ravager
	if (settings.ravagerDisableWolfgirl) {
		// Remove ravager
		// Check the returned index of the ravager. Will be >= 0 if it exists, but -1 if not
		if (wolfFoundIndex >= 0) {
			// Log message
			dbg && console.log('[Ravager Framework] Removing Wolfgirl Ravager')
			// Attempt to remove the ravager
			KinkyDungeonEnemies.splice(wolfFoundIndex, 1)
		}
	} else {
		// Ensure ravager is present
		if (wolfFoundIndex < 0 || wolfFoundIndex == undefined) {
			// Log message
			dbg && console.log('[Ravager Framework] Adding Wolfgirl Ravager')
			// Add ravager to enemy list. To simplify this ability, I've stored the ravager definition in the event map dictionary I'm already using for callbacks
			KinkyDungeonEnemies.push(KDEventMapEnemy['ravagerCallbacks']['definitionWolfgirlRavager'])
		}
	}
	// Checking for Tentacle Pit
	var tentacleFoundIndex = KinkyDungeonEnemies.findIndex((val) => {if (val.name == 'TentaclePit' && val.addedByMod == 'RavagerFramework') return true })
	var tendrilFoundIndex = KinkyDungeonEnemies.findIndex((val) => {if (val.name == 'RavagerTendril' && val.addedByMod == 'RavagerFramework') return true })
	if (settings.ravagerDisableTentaclePit) {
		if (tentacleFoundIndex >= 0) {
			dbg && console.log('[Ravager Framework] Removing Tentacle Pit')
			KinkyDungeonEnemies.splice(tentacleFoundIndex, 1)
		}
		if (tendrilFoundIndex >= 0) {
			dbg && console.log('[Ravager Framework] Removing Pit Tendril')
			KinkyDungeonEnemies.splice(tendrilFoundIndex, 1)
		}
		tendrilFoundIndex = KinkyDungeonEnemies.findIndex((val) => {if (val.name == 'RavagerTendril' && val.addedByMod == 'RavagerFramework') return true })
		if (tendrilFoundIndex >= 0) {
			dbg && console.log('[Ravager Framework] Removing Pit Tendril')
			KinkyDungeonEnemies.splice(tendrilFoundIndex, 1)
		}
	} else {
		if (tentacleFoundIndex < 0 || tentacleFoundIndex == undefined) {
			dbg && console.log('[Ravager Framework] Adding Tentacle Pit')
			KinkyDungeonEnemies.push(KDEventMapEnemy['ravagerCallbacks']['definitionTentaclePit'])
		}
		if (tendrilFoundIndex < 0 || tendrilFoundIndex == undefined) {
			dbg && console.log('[Ravager Framework] Adding Pit Tendril')
			KinkyDungeonEnemies.push(KDEventMapEnemy['ravagerCallbacks']['definitionPitTendril'])
		}
	}
	// Refresh enemy cache
	dbg && console.log('[Ravager Framework] Refreshing enemy cache')
	KinkyDungeonRefreshEnemiesCache()
}

function ravagerFrameworkSetupSound(reason) {
	console.log('[Ravager Framework] ravagerFrameworkSetupSound(' + reason + ')')
	var settings = KDModSettings['RavagerFramework'];
	var dbg = settings.ravagerDebug;
	var otherSoundFound = KDAllModFiles.filter((val) => { if (val.filename.toLowerCase().includes('girlsound.ks')) return true; }).length > 0
	if (settings.ravagerEnableSound && !otherSoundFound) {
		dbg && console.log('[Ravager Framework] Enabling sound effects ...')
		window.RavagerSoundGotHit = false
		KDEventMapGeneric.beforeDamage.RavagerSoundHit = RavagerData.KDEventMapGeneric.beforeDamage.RavagerSoundHit
		KDEventMapGeneric.tick.RavagerSoundTick = RavagerData.KDEventMapGeneric.tick.RavagerSoundTick
		KDExpressions.RavagerSoundHit = RavagerData.KDExpressions.RavagerSoundHit
		KDExpressions.RavagerSoundOrgasm = RavagerData.KDExpressions.RavagerSoundOrgasm
	} else {
		dbg && console.log('[Ravager Framework] Disabling sound effects ...')
		delete window.RavagerSoundGotHit
		delete KDEventMapGeneric.beforeDamage.RavagerSoundHit
		delete KDEventMapGeneric.tick.RavagerSoundTick
		delete KDExpressions.RavagerSoundHit
		delete KDExpressions.RavagerSoundOrgasm
	}
}

addTextKey('KDModButtonRavagerFramework', 'Ravager Framework')
addTextKey('KDModButtonravagerDebug', 'Enable Debug Messages')
addTextKey('KDModButtonravagerDisableBandit', 'Disable Bandit Ravager')
addTextKey('KDModButtonravagerDisableWolfgirl', 'Disable Wolfgirl Ravager')
addTextKey('KDModButtonravagerDisableSlimegirl', 'Disable Slimegirl Ravager')
addTextKey('KDModButtonravagerDisableTentaclePit', 'Disable Tentacle Pit')
addTextKey('KDModButtonravagerSpicyTendril', 'Spicy Ravager Tendril Dialogue')
addTextKey('KDModButtonravagerSlimeAddChance', 'Slimegirl Restrict Chance')
addTextKey('KDModButtonravagerEnableSound', 'Enable Sounds')
addTextKey('KDModButtononHitChance', 'Moan Chance')
addTextKey('KDModButtonravagerSoundVolume', 'Moan Volume')
addTextKey('KDModButtonravEnableUseCount', 'Enable Experience Aware Mode')
addTextKey('KDModButtonravUseCountMode', 'Exp Aware Mode')
addTextKey('KDModButtonravUseCountModeChance', 'Exp Aware Chance')
addTextKey('KDModButtonravUseCountOverride', 'Override Exp Aware Mode')
if (KDEventMapGeneric['afterModSettingsLoad'] != undefined) {
	KDEventMapGeneric['afterModSettingsLoad']['RavagerFramework'] = (e, data) => {
		let dbg = KDModSettings['RavagerFramework'] && KDModSettings['RavagerFramework'].ravagerDebug;
		if (KDModSettings == null) {
			KDModSettings = {}
			dbg && console.log('[Ravager Framework] KDModSettings was null.')
		}
		if (KDModConfigs != undefined) {
			KDModConfigs['RavagerFramework'] = RavagerData.ModConfig
		}
		let settingsobject = (KDModSettings.hasOwnProperty('RavagerFramework') == false) ? {} : Object.assign({}, KDModSettings['RavagerFramework'])
		// console.log('ModSettings state: ', KDModSettings['RavagerFramework'], settingsobject)
		for (var i of KDModConfigs['RavagerFramework']) {
			if (settingsobject[i.refvar] == undefined) {
				dbg && console.log('Setting default value for ' + i.refvar + ' ...')
				settingsobject[i.refvar] = i.default
			}
		}
		KDModSettings['RavagerFramework'] = settingsobject
		// ravagerFrameworkRefreshEnemies('load')
		// ravagerFrameworkApplySpicyTendril('load')
		ravagerSettingsRefresh('load')
	}
}

if (KDEventMapGeneric['afterModConfig'] != undefined) {
	KDEventMapGeneric['afterModConfig']['RavagerFramework'] = (e, data) => {
		// ravagerFrameworkRefreshEnemies('config')
		// ravagerFrameworkApplySpicyTendril('config')
		ravagerSettingsRefresh('refresh')
	}
}
//


// Verbosity function, courtesy of CTN
// Need to figure out a way to deal with arbitrary number of arguments while keeping the nice way console.log will print an object
// Seems I prob can't make this work. Seems like JS is in strict mode, so I can't manually construct the arguments object given to console.log
// I'm giving up on this as of now.
// function RavagerFrameworkVMSG() {
// 	console.log('[RavagerFramework] :  ')//, msg)
// 	// console.log(arguments)
// 	console.log(arguments[Symbol.iterator]())
// }
// -- Method found for doing this, `KDModSettings['RavagerFramework'].ravagerDebug && console.log(...)`
// -- Or (as I've done around the file) define the setting to a variable and && against that for less typing

//things, in order, to remove for a given slot goal
let ravageEquipmentSlotTargets = {
	ItemButt: ["ItemPelvis", "ItemButt"],
	ItemVulva: ["ItemPelvis", "ItemVulva"],
	ItemMouth: ["ItemHead", "ItemMouth"],
	ItemHead: ["ItemHead"]
}

KDPlayerEffects["Ravage"] = (target, damage, playerEffect, spell, faction, bullet, entity) => {
	let dbg = KDModSettings['RavagerFramework'] && KDModSettings['RavagerFramework'].ravagerDebug;
	dbg && console.log('[Ravager Framework]: Effect: Ravage; Ravaging entity is', entity, 'target is', target)
	_RavagerFrameworkDebugEnabled && console.log('[Ravager Framework DBG]: Ravager PlayerEffect; target: ', target, '; damage: ', damage, '; playerEffect: ', playerEffect, '; spell: ', spell, '; faction: ', faction, '; bullet: ', bullet, '; entity: ', entity)
	let enemy = entity.Enemy
	if(!enemy.ravage) throw 'Ravaging enemies need to have ravage settings!'

	////////////////////////////////////////////////////////////////////////
	/* STATUS DETERMINATION SECTION 
	 * determine the strip/restraint state of the player - what to rip away before ravaging
	 * for each option, each given slot must be unoccupied by restraints, and clothing, removed in that order
	*/
	// Status callback, I added this the wolfgirl's spell work without screwing up the ravaging actions. If this callback function returns anything equal to true, the ravager will NOT take any ravaging actions
	// If you're going to use this, my current intent for it is to do some thing before the ravaging begins. It's probably best to do your actions, then set a flag in the ravager entity which will be used to quickly exit your callback.
	// Do NOT try to put this flag in `entity.ravage`, as that dictionary does not exist the first time your callback will be called
	// Currently, it is used to make the wolfgirl throw restraints at the player before closing in on her
	let skipEverything = false
	if (typeof enemy.ravage.effectCallback == 'string' &&
		KDEventMapEnemy['ravagerCallbacks'] &&
		typeof KDEventMapEnemy['ravagerCallbacks'][enemy.ravage.effectCallback] == 'function') {
		dbg && console.log('[Ravager Framework] Running effectCallback with enemy: ', entity, '; target: ', target)
		skipEverything = KDEventMapEnemy['ravagerCallbacks'][enemy.ravage.effectCallback](entity, target)
	}
	dbg && console.log('[Ravager Framework]: skipEverything: ', skipEverything)
	if (!skipEverything) {
		//clothing targts
		let clothingTargetsPelvis = KDGetDressList()[KinkyDungeonCurrentDress].filter(article=> {
				if (["InnocentDesireSuit", "NightCatSuit", "MikosSuitLV1", "MikosSuitLV2", "MikosSuitLV3", "Nake", "EtherMageSuit"].some(str => KinkyDungeonCurrentDress == str)) return false // Working around a function override for PureWind'sTools outfits
				if (enemy.ravage.bypassAll) return false // Seems to not be called before stripping; but it's working as it is now, so I'll come back to this later
				if(article.Lost) return false
				//if(article.Skirt) return true // Disabled because trying to remove the skirt would always fail, resulting in ravagers being unable to progress
				if(article.Group == "Uniform") return true // Sorry, uniforms get torn off in their entirety
				if(["Shorts", "Bikini", "Panties", "Leotard", "Swimsuit"].some(str => article.Item.includes(str))) {
					return true
			}
		})
		_RavagerFrameworkDebugEnabled && console.log('[Ravager Framework DBG]: PlayerEffect clothingTargetsPelvis: ', clothingTargetsPelvis)

		let clothingTargetsMouth = KDGetDressList()[KinkyDungeonCurrentDress].filter(article=> {
				if (["InnocentDesireSuit", "NightCatSuit", "MikosSuitLV1", "MikosSuitLV2", "MikosSuitLV3", "Nake", "EtherMageSuit"].some(str => KinkyDungeonCurrentDress == str)) return false // Working around a function override for PureWind'sTools outfits
				if (enemy.ravage.bypassAll) return false // Seems to not be called before stripping; but it's working as it is now, so I'll come back to this later
				if(article.Lost) return false
				if(["Mask", "Visor", "Gag"].some(str => article.Item.includes(str))) {
					return true
			}
		})

		let clothingTargetsHead = KDGetDressList()[KinkyDungeonCurrentDress].filter(article=> {
				if (["InnocentDesireSuit", "NightCatSuit", "MikosSuitLV1", "MikosSuitLV2", "MikosSuitLV3", "Nake", "EtherMageSuit"].some(str => KinkyDungeonCurrentDress == str)) return false // Working around a function override for PureWind'sTools outfits
				if (enemy.ravage.bypassAll) return false // Seems to not be called before stripping; but it's working as it is now, so I'll come back to this later
				if(article.Lost) return false
				if(["Hat"].some(str => article.Item.includes(str))) {
					return true
			}
		})

		dbg && console.log('[Ravager Framework]: Clothing targets: Pelvis: ', clothingTargetsPelvis, '; Mouth: ', clothingTargetsMouth, '; Head: ', clothingTargetsHead)

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
			if(enemy.ravage.bypassSpecial) restraintIsBypassed = enemy.ravage.bypassSpecial.some(str => restraint?.name.includes(str))
			if( 
				( // Leave blindfolds on unless specified
					(restraint.name.includes("Blindfold") && !enemy.ravage.needsEyes) 
				) || 
				restraintIsBypassed ||
				( // Possible to bypass completely if specified
					enemy.ravage.bypassAll
				)
			) return true
			else return false
		}

		// Collect an array of equipment that needs to be removed
		for (const slot in stripOptions.equipment) {
			ravageEquipmentSlotTargets[slot].forEach(groupName => {
				let restraintInSlot = KinkyDungeonGetRestraintItem(groupName)
				_RavagerFrameworkDebugEnabled && console.log('[Ravager Framework DBG]: PlayerEffect creating array of worn equipment; groupName: ', groupName, '; restraintInSlot: ', restraintInSlot)
				_RavagerFrameworkDebugEnabled && restraintInSlot && console.log('	; if eval: restraintInSlot: ', Boolean(restraintInSlot), '; InSlot name: ', restraintInSlot.name, '; InSlot name != Stripped: ', restraintInSlot.name != "Stripped", '; InSlot name not includes RavagerOccupied: ', !restraintInSlot.name.includes("RavagerOccupied"), '; not bypassed: ', !bypassed(restraintInSlot), '; not bypassAll: ', !enemy.ravage.bypassAll, '; Total: ', restraintInSlot && restraintInSlot.name != "Stripped" && !restraintInSlot.name.includes("RavagerOccupied") && !bypassed(restraintInSlot) && !enemy.ravage.bypassAll)
				if(
					restraintInSlot && 
					restraintInSlot.name != "Stripped" && 
					!restraintInSlot.name.includes("RavagerOccupied") &&
					!bypassed(restraintInSlot) &&
					!enemy.ravage.bypassAll // Allows a ravager to not remove clothing
				) stripOptions.equipment[slot].push(groupName) // Since easiest removal is via group name
			})

			// Special check for mouth since collars can also affect this
			for (let inv of KinkyDungeonAllRestraint()) {
				if (
					KDRestraint(inv).gag && 
					!KDRestraint(inv).name.includes("RavagerOccupied") &&
					!bypassed(inv) &&
					!enemy.ravage.bypassAll // Allows a ravager to not remove clothing
				) {
					stripOptions.equipment.ItemMouth.push(inv)
				}
			}
		}

		// Easy eligibility detection; just make sure there's nothing else to remove in desired slot
		let uncovered = {
			ItemButt: stripOptions.equipment.ItemButt.length == 0 && stripOptions.clothing.ItemButt.length == 0,
			ItemVulva: stripOptions.equipment.ItemVulva.length == 0 && stripOptions.clothing.ItemVulva.length == 0,
			ItemMouth: stripOptions.equipment.ItemMouth.length == 0 && stripOptions.clothing.ItemMouth.length == 0
		}

		dbg && console.log('[Ravager Framework]: Slot state: stripOptions: ', stripOptions, '; uncovered: ', uncovered)

		////////////////////////////////////////////////////////////////////////
		/* TARGETING SECTION  - an enemy should "claim" a slot for consistency
				- i.e. picks one slot, saved into active entity as a goal, strips that particular slot
				- other ravagers can have same goal and help strip, but only one gets it - they'll pick another eventually
				- if they can't, they default to fallback behavior
		*/

		// Define player/entity state if not already there
		if(!entity.ravage) entity.ravage = { progress: 0 }
		if(target == KinkyDungeonPlayerEntity && !KinkyDungeonPlayerEntity.ravage) KinkyDungeonPlayerEntity.ravage = {
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
		// TODO!!! prioritize oral if target is belted
		let canRavage = true
		_RavagerFrameworkDebugEnabled && console.log('[Ravager Framework DBG]: PlayerEffect validSlots; needs to choose slot: ', !entity.ravage.slot, 'slot ocuppier type = object: ', typeof KinkyDungeonPlayerEntity.ravage.slots[entity.ravage.slot] == "object", '; entity not in desired slot: ', (typeof KinkyDungeonPlayerEntity.ravage.slots[entity.ravage.slot] == "object" && KinkyDungeonPlayerEntity.ravage.slots[entity.ravage.slot] != entity), '; Total: ', !entity.ravage.slot || (typeof KinkyDungeonPlayerEntity.ravage.slots[entity.ravage.slot] == "object" && KinkyDungeonPlayerEntity.ravage.slots[entity.ravage.slot] != entity))
		_RavagerFrameworkDebugEnabled && console.log('[Ravager Framework DBG]: PlayerEffect validSlots; validSlots.length: ', validSlots.length)
		if(!entity.ravage.slot || (typeof KinkyDungeonPlayerEntity.ravage.slots[entity.ravage.slot] == "object" && KinkyDungeonPlayerEntity.ravage.slots[entity.ravage.slot] != entity)) {
			dbg && console.log('[Ravager Framework]: validSlots: ', validSlots, '; entity.ravage.slot: ', entity.ravage.slot, '; entity not in desired player slot: ', KinkyDungeonPlayerEntity.ravage.slots[entity.ravage.slot] != entity, '; desired player slot: ', KinkyDungeonPlayerEntity.ravage.slots[entity.ravage.slot])
			if(validSlots.length) entity.ravage.slot = ravRandom(validSlots)
			else canRavage = false
		}
		_RavagerFrameworkDebugEnabled && console.log('[Ravager Framework DBG]: PlayerEffect validSlots; entity slot: ', entity.ravage.slot, '; canRavage: ', canRavage)

		////////////////////////////////////////////////////////////////////////
		/* RAVAGE SECTION - If target is player, lower body is nude, and is pinned */
		_RavagerFrameworkDebugEnabled && console.log('[Ravager Framework DBG]: playerEffect section determination; target is player: ', target == KinkyDungeonPlayerEntity, '; canRavage: ', canRavage, '; uncovered[' + entity.ravage.slot + ']: ', uncovered[entity.ravage.slot], '; Pinned tag: ', Boolean(KinkyDungeonPlayerTags.get("Item_Pinned")), '; refractory: ', Boolean(entity.ravageRefractory))
		if(
			target == KinkyDungeonPlayerEntity &&
			canRavage &&
			uncovered[entity.ravage.slot] &&
			KinkyDungeonPlayerTags.get("Item_Pinned") && // Granted by "Pinned"
			!entity.ravageRefractory
		) {
			// Mark this spot as properly claimed
			let slotOfChoice = entity.ravage.slot
			let pRav = KinkyDungeonPlayerEntity.ravage //Shortcut for readability
			pRav.slots[entity.ravage.slot] = entity
			entity.ravage.isRavaging = true

			// Also, ensure entity doesn't stop "playing" until done, if they are playing
			if(entity.playWithPlayer) entity.playWithPlayer++

			// Transfer leash to this caster
			let leash = KinkyDungeonGetRestraintItem("ItemNeckRestraints");
			if (leash && KDRestraint(leash).tether) {
				leash.tetherEntity = entity.id;
				KDGameData.KinkyDungeonLeashingEnemy = entity.id;
				leash.tetherLength = 1;
			}
			KinkyDungeonSetFlag("overrideleashprotection", 2);

			// Add occupied binding
			KinkyDungeonAddRestraintIfWeaker(`${entity.ravage.slot.replace("Item", "RavagerOccupied")}`)

			// If player waited, SP and WP damage is halved - counts as "submitting"
			// They can also unwillingly submit
			pRav.submitting = KinkyDungeonLastTurnAction == "Wait"
			pRav.submissionReason = KinkyDungeonFlags.get("playerStun") ? "You're too stunned to resist..." : "You moan softly as you let it happen..."
			pRav.submissionLevel = 0

			let submitRoll = Math.random() * 100
			let baseSubmitChance = KinkyDungeonGoddessRep["Ghost"] + 30 // Starts at -50, this gives it some offset
			dbg && console.log('[Ravager Framework] Enemy: ', enemy)
			// if(enemy.ravage.submitChanceModifierCallback) baseSubmitChance = enemy.ravage.submitChanceModifierCallback(entity, target, baseSubmitChance)
			dbg && console.log('[Ravager Framework]: Checking for submitChanceModifierCallback ...')
			if (
				typeof enemy.ravage.submitChanceModifierCallback == 'string' &&
				KDEventMapEnemy['ravagerCallbacks'] &&
				typeof KDEventMapEnemy['ravagerCallbacks'][enemy.ravage.submitChanceModifierCallback] == 'function'
			) {
				dbg && console.log('[Ravager Framework] Calling submitChanceModifierCallback from ravager ', entity, ' ...')
				let tmp_baseSubmitChance = KDEventMapEnemy['ravagerCallbacks'][enemy.ravage.submitChanceModifierCallback](entity, target, baseSubmitChance)
				switch (typeof tmp_baseSubmitChance) {
				case 'undefined':
					console.warn('[Ravager Framework] WARNING: Ravager ', entity.Enemy.name, '(', TextGet('name' + entity.Enemy.name), ') used a submitChanceModifierCallback which returned no value! This result will be ignored. Please report this issue to the author of this ravager!')
					break
				case 'number':
					baseSubmitChance = tmp_baseSubmitChance
					dbg && console.log('[Ravager Framework] Base submit chance changed to ', baseSubmitChance)
					break
				default:
					console.warn('[Ravager Framework] WARNING: Ravager ', entity.Enemy.name, '(', TextGet('name' + entity.Enemy.name), ') used a submitChanceModifierCallback which returned a non-number value (', tmp_baseSubmitChance, ')! This result will be ignored. Please report this issue to the author of this ravager!')
					break
				}
			}
			let leashSubmitChance = baseSubmitChance + 10
			let wpSubmitChance = leashSubmitChance + 10

			// Since this is shown once per whole turn rather than each enemy, we pick the highest descriptive one
			if(pRav.submissionLevel < 3 && KinkyDungeonStatWill == 0 && (submitRoll < wpSubmitChance && submitRoll > leashSubmitChance)) {
				pRav.submissionReason = "(STUN) You can't will yourself to resist..."
				pRav.submitting = "forced"
				pRav.submissionLevel = 3
			} else if(pRav.submissionLevel < 2 && leash && (submitRoll < leashSubmitChance && submitRoll > baseSubmitChance)) {
				pRav.submissionReason = "(STUN) With a tug of your leash, you're put in your place..."
				pRav.submitting = "forced"
				pRav.submissionLevel = 2
			} else if(pRav.submissionLevel < 1 && submitRoll < baseSubmitChance) {
				pRav.submissionReason = "(STUN) Your submissiveness gets the better of you..."
				pRav.submitting = "forced"
				pRav.submissionLevel = 1
			}

			/* Determine string and severity of ravaging 
				Every ravaging enemy should have a range that contains all damage, etc.
				The first range with a number higher than the enemy's ravaging progress is selected, and its effects used.
			*/
			let range = enemy.ravage.ranges.find(range => {
				if(range[0] > entity.ravage.progress) return true
			})

			// Helper to get what the previous range was for the sake of increase player ravaged counts 
			function getPreviousRange(currRange, enemy) {
				return currRange ? enemy.ravage.ranges[enemy.ravage.ranges.findIndex((v) => { if (v == currRange) return true; }) - 1] : enemy.ravage.ranges.at(-1)
			}
			// Helper to increase player ravaged counts
			function increasePlayerRavagedCount(range, slot, target, enemy, assumeIncrement) {
				const dbg = RavagerGetSetting('ravagerDebug')
				dbg && console.log('[Ravager Framework][increasePlayerRavagedCount]: range: ', range, '; slot: ', slot, '; target: ', target, '; enemy: ', enemy, '; assumeIncrement: ', assumeIncrement)
				// Bail if use-count-aware mode is disabled
				if (!RavagerGetSetting('ravEnableUseCount')) {
					dbg && console.log('[Ravager Framework][increasePlayerRavagedCount]: EA mode disabled. Bailing.')
					return
				}
				// Check that player.ravagedCount exists
				if (target.ravagedCounts == undefined) {
					dbg && console.log('[Ravager Framework][increasePlayerRavagedCount]: Creating player\'s ravagedCounts')
					target.ravagedCounts = {}
				}
				// Check for last incremented, so we don't repeatedly increment the same slot
				if (target.ravagedCounts.lastIncremented == undefined) {
					dbg && console.log('[Ravager Framework][increasePlayerRavagedCount]: Creating player\'s ravagedCounts.lastIncremented')
					target.ravagedCounts.lastIncremented = {}
				}
				if (range == undefined) {
					dbg && console.log('[Ravager Framework][increasePlayerRavagedCount]: Invalid range')
					return false
				} else if (target.ravagedCounts.lastIncremented[slot] == range[0]) {
					dbg && console.log('[Ravager Framework][increasePlayerRavagedCount]: Matched range against previous incremented range')
					return false
				} else {
					dbg && console.log('[Ravager Framework][increasePlayerRavagedCount]: Last incremented range not matching; deleting')
					delete target.ravagedCounts.lastIncremented[slot]
				}
				// Check the range's increment setting for all/specified slot
				let incCount = range[1].useCount
				if (incCount == undefined && assumeIncrement) { // Failed to think through the fact that we want to increment slots by default at the end. So if rangeData.useCount is missing, we default to incrementing by one for all slots. This should still respect being able to not increment on specific slots via making an object without that slot, or setting the slot to false, and disabling entirely by setting rangeData.useCount to false
					dbg && console.log('[Ravager Framework][increasePlayerRavagedCount]: Assuming increment by default; we\'re hopefully at the end of a session')
					incCount = 1
				}
				dbg && console.log('[Ravager Framework][increasePlayerRavagedCount]: incCount: ', incCount)
				if (incCount) {
					// Normalize incCount
					if ((typeof incCount).toLowerCase() == "object") {
						if (!incCount[slot])
							return false
						incCount = Number(incCount[slot])
					} else if (Number.isNaN(Number(incCount))) {
						incCount = 0
					} else {
						incCount = Number(incCount)
					}
					dbg && console.log('[Ravager Framework][increasePlayerRavagedCount]: Normalized incCount: ', incCount)
					// Check if specified slot's use count is undefined
					if (target.ravagedCounts[slot] == undefined || target.ravagedCounts[slot] < 0) {
						// Set use count to range's increment count (Cast to Number to handle Boolean meaning increment by one)
						target.ravagedCounts[slot] = incCount
						dbg && console.log('[Ravager Framework][increasePlayerRavagedCount]: Set slot\'s count to ', incCount)
					} else {
						// Increment use count by range's increment count (cast to Number to handle Boolean meaning increment)
						target.ravagedCounts[slot] += incCount
						dbg && console.log('[Ravager Framework][increasePlayerRavagedCount]: Incremented slot\'s count by ', incCount)
					}
					target.ravagedCounts.lastIncremented[slot] = range[0]
					dbg && console.log('[Ravager Framework][increasePlayerRavagedCount]: Set slot\'s last incremented to ', range[0])
					return true
				} else {
					dbg && console.log('[Ravager Framework][increasePlayerRavagedCount]: incCount invalid')
					return false
				}
			}

			// If rangeData is null, the encounter is over, and doneDialogue should be used.
			if(range) {
				let rangeData = range[1]

				// Handle stat changes
				if(rangeData.sp) KDChangeStamina(pRav.submitting ? rangeData.sp * 0.25 : rangeData.sp)
				if(rangeData.wp) KDChangeWill(rangeData.wp)
				if(rangeData.sub) KinkyDungeonChangeRep("Ghost", rangeData.sub); // "Ghost" is submissiveness for some reason
					else if(pRav.submitting) KinkyDungeonChangeRep("Ghost", 0.25)
				if(rangeData.dp) { // We only try orgasm if DP is affected
					KDChangeDistraction(rangeData.dp)
					KinkyDungeonDoTryOrgasm((rangeData.orgasmBonus || 0) + slotsOccupied, 1)
				}

				// Helpers for use count based text
				function checkPreviousUseCount(slot) {
					return target.ravagedCounts && typeof target.ravagedCounts[slotOfChoice] == "number" && target.ravagedCounts[slot] > 0
				}
				function decideToDoExperiencedText(obj, slot, rangeData) {
					// Check that use-count-aware mode is enabled before continuing
					if (!RavagerGetSetting('ravEnableUseCount')) {
						dbg && console.log('[Ravager Framework][decideToDoExperiencedText]: EA mode disabled. Bailing.')
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
							console.error('[Ravager Framework][decideToDoExperiencedText][experiencedTextDecideUser]: Invalid preference: ', pref)
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
						// pRav.narrationBuffer.push(ravRandom(eNarr[1][slotOfChoice]).replace("EnemyName", TextGet("Name" + entity.Enemy.name)));
						pRav.narrationBuffer.push(RavagerData.functions.NameFormat(ravRandom(eNarr[1][slotOfChoice]), entity))
						didExperiencedNarration = true
					}
				}
				// if(rangeData.narration && !didExperiencedNarration) pRav.narrationBuffer.push(ravRandom(rangeData.narration[slotOfChoice]).replace("EnemyName", TextGet("Name" + entity.Enemy.name)));
				if (rangeData.narration && !didExperiencedNarration)
					pRav.narrationBuffer.push(RavagerData.functions.NameFormat(ravRandom(rangeData.narration[slotOfChoice]), entity))
				// Use count based taunts
				let didExperiencedTaunt = false
				if (checkPreviousUseCount(slotOfChoice) && rangeData.experiencedTaunts) {
					let eTaunt = rangeData.experiencedTaunts.findLast((range) => { if (range[0] <= target.ravagedCounts[slotOfChoice]) return true; })
					if (decideToDoExperiencedText(eTaunt, slotOfChoice, rangeData)) {
						// KinkyDungeonSendDialogue(entity, ravRandom(eTaunt[1][slotOfChoice]).replace("EnemyName", TextGet("Name" + entity.Enemy.name)), KDGetColor(entity), 6, 6)
						KinkyDungeonSendDialogue(entity, RavagerData.functions.NameFormat(ravRandom(eTaunt[1][slotOfChoice]), entity), KDGetColor(entity), 6, 6)
						didExperiencedTaunt = true
					}
				}
				// if(rangeData.taunts && !didExperiencedTaunt) KinkyDungeonSendDialogue(entity, ravRandom(rangeData.taunts).replace("EnemyName", TextGet("Name" + entity.Enemy.name)), KDGetColor(entity), 6, 6);
				if (rangeData.taunts && !didExperiencedNarration)
					KinkyDungeonSendDialogue(entity, RavagerData.functions.NameFormat(ravRandom(rangeData.taunts), entity), KDGetColor(entity), 6, 6)
				if(rangeData.dp) { // Only do floaty sound effects if DP is being applied, since that means action is happening
					if(enemy.ravage.onomatopoeia) KinkyDungeonSendFloater(entity, ravRandom(enemy.ravage.onomatopoeia), "#ff00ff", 2);
				}

				// Status effect application/precautions
				KinkyDungeonApplyBuffToEntity(KinkyDungeonPlayerEntity, KDRavaged) // Blinds player
				KinkyDungeonApplyBuffToEntity(entity, KDRavaging) // Keeps enemy in one place
				if (!entity.Enemy.ravage.bypassAll) KinkyDungeonAddRestraintIfWeaker("Stripped") // Stay stripped

				if(pRav.submitting) { // When submitting, offset the "self-play" cost associated with doTryOrgasm
					if(KinkyDungeonStatStamina > 3) KDChangeStamina(KinkyDungeonEdgeCost * -1)
					KinkyDungeonSendActionMessage(20, pRav.submissionReason + ` (Reduced SP loss)`, "#dd00dd", 1, false, true);
				}
				if(pRav.submitting == "forced") {
					KDStunTurns(1)
					KinkyDungeonSendFloater(KinkyDungeonPlayerEntity, "SUBMIT!", "#ff00ff", 2);
				}
				entity.ravage.progress++

				dbg && console.log('[Ravager Framework] Checking for range callback at range ', range[1], ' ...')
				if (
					typeof rangeData.callback == 'string' &&
					KDEventMapEnemy['ravagerCallbacks'] &&
					typeof KDEventMapEnemy['ravagerCallbacks'][rangeData.callback] == 'function'
				) {
					dbg && console.log('[Ravager Framework] Calling rangeData callback for range ', range[1], ' ...')
					KDEventMapEnemy['ravagerCallbacks'][rangeData.callback](entity, target, entity.ravage.slot)
				}
				if (
					typeof enemy.ravage.allRangeCallback == 'string' &&
					KDEventMapEnemy['ravagerCallbacks'] &&
					typeof KDEventMapEnemy['ravagerCallbacks'][enemy.ravage.allRangeCallback] == 'function'
				) {
					dbg && console.log('[Ravager Framework] Calling all range callback ', enemy.ravage.allRangeCallback, ' ...')
					KDEventMapEnemy['ravagerCallbacks'][enemy.ravage.allRangeCallback](entity, target, entity.ravage.slot)
				}
				dbg && console.log('[Ravager Framework]: Attempting to increment slot use count...')
				increasePlayerRavagedCount(getPreviousRange(range, enemy), slotOfChoice, target, enemy)
			} else {			
				// Done playing, if they were
				if(entity.playWithPlayer) entity.playWithPlayer = 0
				
				// If player doesn't pass out, just remove that enemy from slot and reset progress, give self a cooldown timer
				let passedOut = false
				if(KinkyDungeonStatWill != 0 || KinkyDungeonStatStamina > 1) {
					// Set 'refractory' on self and clear slot used
					KinkyDungeonRemoveRestraintsWithName(`${entity.ravage.slot.replace("Item", "RavagerOccupied")}`)
					pRav.slots[entity.ravage.slot] = false
					entity.ravageRefractory = enemy.ravage.refractory
					KDBreakTether(KinkyDungeonPlayerEntity) // Chances are, this enemy was holding the tether
					delete entity.ravage
					// KinkyDungeonSendActionMessage(45, "You feel weak as the EnemyName releases you...".replace("EnemyName", TextGet("Name" + entity.Enemy.name)), "#ee00ee", 4);
					KinkyDungeonSendActionMessage(45, RavagerData.functions.NameFormat(RavagerData.defaults.releaseMessage, entity), "#e0e", 4) // Maybe make this controllable by a rav dev?
				} else { // Pass out!
					KinkyDungeonSendActionMessage(45, RavagerData.defaults.passoutMessage, "#ee00ee", 4);
					KinkyDungeonPassOut()
					passedOut = true
				}

				// Check for increasing ravaged count
				dbg && console.log('[Ravager Framework]: Attempting to increment slot use count at end of session...')
				increasePlayerRavagedCount(getPreviousRange(range, enemy), slotOfChoice, target, enemy, !(enemy.ravage.ranges.filter(v => v[1].useCount).length > 0))

				// if(enemy.ravage.doneTaunts) KinkyDungeonSendDialogue(entity, ravRandom(enemy.ravage.doneTaunts).replace("EnemyName", TextGet("Name" + entity.Enemy.name)), KDGetColor(entity), 6, 6);
				if (enemy.ravage.doneTaunts)
					KinkyDungeonSendDialogue(entity, RavagerData.functions.NameFormat(ravRandom(enemy.ravage.doneTaunts), entity), KDGetColor(entity), 6, 6)
				if (
					typeof enemy.ravage.completionCallback == 'string' &&
					KDEventMapEnemy['ravagerCallbacks'] &&
					typeof KDEventMapEnemy['ravagerCallbacks'][enemy.ravage.completionCallback] == 'function'
				) {
					dbg && console.log('[Ravager Framework] Calling completion callback ', enemy.ravage.completionCallback, ' ...')
					KDEventMapEnemy['ravagerCallbacks'][enemy.ravage.completionCallback](entity, target, passedOut)
				}
				// Character gets exhausted by this interaction.
				KinkyDungeonSleepiness = 4
			}
		}
		////////////////////////////////////////////////////////////////////////
		/* STRIP/PIN SECTION - If target is player, has belt/plugs, or has lower body clothing */
		else if(
			target == KinkyDungeonPlayerEntity &&
			canRavage &&
			(!uncovered[entity.ravage.slot] || !KinkyDungeonPlayerTags.get("Item_Pinned")) && 
			!entity.ravageRefractory
		) {
			// Remove restraints first, THEN clothing, then pin once ready
			if(stripOptions.equipment[entity.ravage.slot].length) {
				// Since we want to go in order - remove mask before gag, etc
				let input = stripOptions.equipment[entity.ravage.slot][0]
				let targetRestraint
				let specific = false
				if(typeof input == "object") { // May pass specific restraints in the case of non-mouth-slot mouth coverings
					targetRestraint = input
					specific = true
				} else { // This is just the group string selection
					targetRestraint = KinkyDungeonGetRestraintItem(input)
				}
				// Determine removal progress here - TODO base on power, but first we need to make sure other enemies
				// Can't just add restraints mid-ravage
				let canBeRemoved = false
				let restraintRef = KinkyDungeonGetRestraintByName(targetRestraint)
				if(specific) {
					KinkyDungeonRemoveRestraintSpecific(targetRestraint, true, false, false, false, false, entity)
				} else {
					KinkyDungeonRemoveRestraint(input, true, false, false, false, false, entity)
				}
				// KinkyDungeonSendTextMessage(10, `EnemyName tears your ${TextGet("Restraint" + targetRestraint.name)} away!`.replace("EnemyName", TextGet("Name" + entity.Enemy.name)), "#ff0000", 4);	
				KinkyDungeonSendTextMessage(10, RavagerData.functions.NameFormat(RavagerData.defaults.restraintTearMessage, entity, targetRestraint), "#f00", 4) // Maybe make this controllable for a rav dev?
			} else if(stripOptions.clothing[entity.ravage.slot].length) {
				_RavagerFrameworkDebugEnabled && console.log('[Ravager Framework DBG]: PlayerEffect stripping clothing; clothing strip options: ', stripOptions.clothing[entity.ravage.slot])
				let stripped = stripOptions.clothing[entity.ravage.slot][0]
				_RavagerFrameworkDebugEnabled && console.log('[Ravager Framework DBG]: PlayerEffect stripping clothing; stripped: ', stripped)
				_RavagerFrameworkDebugEnabled && console.log('[Ravager Framework DBG]: PlayerEffect stripping clothing; slot check; slot not = ItemMouth: ', entity.ravage.slot != "ItemMouth", '; !getRestraintItem ItemPelvis: ', !KinkyDungeonGetRestraintItem("ItemPelvis"), '; clothing includes shorts, bikini, or panties: ', ["Shorts", "Bikini", "Panties"].some(str => stripped.Item.includes(str)), '; Total: ', entity.ravage.slot != "ItemMouth" && !KinkyDungeonGetRestraintItem("ItemPelvis") && ["Shorts", "Bikini", "Panties"].some(str => stripped.Item.includes(str)))
				if(entity.ravage.slot != "ItemMouth" && !KinkyDungeonGetRestraintItem("ItemPelvis") && ["Shorts", "Bikini", "Panties"].some(str => stripped.Item.includes(str))) {
					if (!entity.Enemy.ravage.bypassAll) KinkyDungeonAddRestraintIfWeaker("Stripped") // Since panties are sacred normally
				}
				// KinkyDungeonSendTextMessage(10, `EnemyName tears your ${stripped.Item} away!`.replace("EnemyName", TextGet("Name" + entity.Enemy.name)), "#ff0000", 4);
				KinkyDungeonSendTextMessage(10, RavagerData.functions.NameFormat(RavagerData.defaults.clothingTearMessage, entity, undefined, stripped), "#f00", 4) // Maybe make this controllable for a rav dev?
				_RavagerFrameworkDebugEnabled && console.log('[Ravager Framework DBG]: PlayerEffect stripping clothing; stripped.Lost = ', stripped.Lost)
				stripped.Lost = true
				_RavagerFrameworkDebugEnabled && console.log('[Ravager Framework DBG]: PlayerEffect stripping clothing; stripped.Lost = ', stripped.Lost)
			} else {
				KinkyDungeonAddRestraintIfWeaker("Pinned")
				// KinkyDungeonSendTextMessage(10, `EnemyName gets a good grip on you...`.replace("EnemyName", TextGet("Name" + entity.Enemy.name)), "#ff00ff	", 4);
				KinkyDungeonSendTextMessage(10, RavagerData.functions.NameFormat(RavagerData.defaults.pinMessage, entity), "#f0f", 4)
			}
			KinkyDungeonDressPlayer()
			return {sfx: "Miss", effect: true};
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
				dbg && console.log('[Ravager Framework] Calling fallback callback: ', enemy.ravage.fallbackCallback, ' ...')
				KDEventMapEnemy['ravagerCallbacks'][enemy.ravage.fallbackCallback](entity, target)
			} else { // Otherwise, we'll do the default fallback
				// Restraint adding
				let didRestrain = false
				if (typeof enemy.ravage.restrainChance == 'number' && Math.random() < enemy.ravage.restrainChance) {
					dbg && console.log('[Ravager Framework] We\'re trying to add a restraint to the player during fallback!')
					// Get jail restraints -- we're using these until I can figure out how to get a specific set of jail restraints or until I can be bothered to make a way of cleanly defining a list of restraints in the ravager declaration
					let possibleRestraints = KDGetJailRestraints()
					// Filter out restraints that can't be added
					possibleRestraints = possibleRestraints.filter((item) => {
						return KDCanAddRestraint(KinkyDungeonGetRestraintByName(item.Name))
					})
					dbg && console.log('[Ravager Framework] Valid restraints for fallback: ', possibleRestraints)
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
									// KinkyDungeonSendTextMessage(10, 'The EnemyName forces you to wear a RestraintName'.replace('EnemyName', TextGet('Name' + entity.Enemy.name)).replace('RestraintName', TextGet('Restraint' + canidateRestraint.name)), '#FF00FF', 4)
									KinkyDungeonSendTextMessage(10, RavagerData.functions.NameFormat(RavagerData.defaults.addRestraintMessage, entity, canidateRestraint), "#f0f", 4)
									didRestrain = true
								}
							} catch (e) {
								console.warn('[Ravager Framework] Caught error while adding a restraint as a fallback: ', e)
							}
						} else { console.error('[Ravager Framework] CANIDATE RESTRAINT INVALID! ', canidateRestraint) }
					}
				}
				//
				// Grope damage dealing
				if (!didRestrain) {
					dbg && console.log('[Ravager Framework] We DIDN\'T add a restraint, let\'s grope')
					let dmg = KinkyDungeonDealDamage({damage: 1, type: "grope"});
					if (!enemy.ravage.noFallbackNarration) {
						if(enemy.ravage.fallbackNarration) {
							// KinkyDungeonSendTextMessage( 10, ravRandom(enemy.ravage.fallbackNarration).replace("EnemyName", TextGet("Name" + enemy.name)).replace("DamageTaken", dmg.string), "#ff00ff", 4);
							KinkyDungeonSendTextMessage(10, RavagerData.functions.NameFormat(ravRandom(enemy.ravage.fallbackNarration), entity, undefined, undefined, dmg), "#f0f", 4)
						} else {
							// KinkyDungeonSendTextMessage( 10, "The EnemyName roughly gropes you! (DamageTaken)".replace("EnemyName", TextGet("Name" + enemy.name)).replace("DamageTaken", dmg.string), "#ff00ff", 4);
							KinkyDungeonSendTextMessage(10, RavagerData.functions.NameFormat(RavagerData.defaults.fallbackNarration, entity, undefined, undefined, dmg), "#f0f", 4)
						}
					} else {
						deb && console.log('[Ravager Framework] ', enemy.name, ' requests no fallback narration.')
					}
				}
				//
			}
		}

		return {sfx: "Struggle", effect: true};
	}
	return {sfx: "Struggle", effect: true};
}


/**********************************************
 * Misc definitions
 * Restraints are used to graphically remove panties, and also apply the pinned down "state".
 * Events are used to ensure that leashes can only be grabbed by the ravagers while being ravaged.
 * There are also a few buffs that are used to enhance the experience.
*/
// Restraint definitions
KinkyDungeonStruggleGroupsBase.push("ItemRavage")
KinkyDungeonRestraints.push(
	{
		name: "Pinned", 
		immobile: true, 
		Color: "#333333", 
		Group: "ItemRavage",
		bindarms: true,
		bindhands: true,
		blockfeet: true,
		power: 0.1,
		weight: 20, 
		alwaysStruggleable: true,
		alwaysEscapable: ["Struggle"],
		escapeChance: {"Struggle": -0.1, "Remove": 0.2, "Cut": 0.75},
		struggleMinSpeed: {"Struggle": 0.2},
		playerTags: {"ItemArmsFull":2},
		enemyTags: {},
		minLevel: 0, 
		allFloors: true, 
		removeOnLeash:false,
		removeOnPrison:true,
		shrine: [],
		events: [
			{trigger: "tick", type: "sneakBuff", power: -1},
			{trigger: "tick", type: "evasionBuff", power: -1000},
			{trigger: "tick", type: "blockBuff", power: -100},
			{trigger: "tickAfter", type: "ravagerNarration", power: -100},
			{trigger: "tickAfter", type: "ravagerPinCheck", power: -100},
			{trigger: "passout", type: "ravagerRemove", power: -100},
			{trigger: "remove", type: "ravagerRemove", power: -100},
			{ trigger: "tickAfter", type: "ravagerSitDownAndShutUp" }
		],
		failSuffix: {"Remove": "RavagerPinned", "Struggle": "RavagerPinned", "Cut": "RavagerPinned"},
		customEquip: 'RavagerPinned',
		customEscapeSucc: 'RavagerPinned'
	},

	// This is really just to remove panties
	{
		name: "Stripped", 
		Color: "#333333", 
		Group: "ItemPelvis", 
		specStruggleTypes: ["Remove"],
		power: 8, 
		weight: 2, 
		escapeChance: {"Remove": 2, 'Struggle': 2},
		playerTags: {"ItemArmsFull":6},
		addTag: ["stripped"],
		enemyTags: {},
		minLevel: 0, 
		allFloors: true, 
		removeOnLeash:false,
		removeOnPrison:false,
		shrine: [],
		events: [],
		failSuffix: {'Remove': 'RavagerStripped', 'Struggle': 'RavagerStripped'},
		customEquip: 'RavagerStripped',
		customEscapeSucc: 'RavagerStripped'
	},


	// Definitions for the "occupied" slots to stop other people from interrupting
	// These are removed by breaking Pinned, and they're just mechanical, so they can't be struggled out of.
	{
		name: "RavagerOccupiedMouth", 
		Color: "#333333", 
		Group: "ItemMouth",
		power: 99, 
		weight: 0, 
		specStruggleTypes: ["Struggle"], escapeChance: {"Struggle": -99, "Cut": -99, "Remove": -99},
		playerTags: {"ItemMouthFull": 6},
		enemyTags: {},
		shrine: [],
		minLevel: 0, 
		allFloors: true, 
		removeOnLeash:false,
		removeOnPrison:true,
		bypass: true,
		gag: 1,
		events: [
			{trigger: "tick", type: "ravagerCheckForPinned", power: -1},
		],
		failSuffix: {"Remove": "RavagerOccupied", "Struggle": "RavagerOccupied", "Cut": "RavagerOccupied"},
		customEquip: 'RavagerOccupied',
		Model: "GhostGag"
	},
	{
		name: "RavagerOccupiedHead", 
		Color: "#333333", 
		Group: "ItemHead",
		power: 99, 
		weight: 0, 
		specStruggleTypes: ["Struggle"], escapeChance: {"Struggle": -99, "Cut": -99, "Remove": -99},
		playerTags: {"ItemMouthFull": 6},
		enemyTags: {},
		shrine: [],
		minLevel: 0, 
		allFloors: true, 
		removeOnLeash:false,
		removeOnPrison:true,
		bypass: true,
		events: [
			{trigger: "tick", type: "ravagerCheckForPinned", power: -1},
		],
		failSuffix: {"Remove": "RavagerOccupied", "Struggle": "RavagerOccupied", "Cut": "RavagerOccupied"},
		customEquip: 'RavagerOccupied'
	},
	{
		name: "RavagerOccupiedVulva", 
		Color: "#333333", 
		Group: "ItemVulva",
		power: 99, 
		weight: 0, 
		specStruggleTypes: ["Struggle"], escapeChance: {"Struggle": -99, "Cut": -99, "Remove": -99},
		playerTags: {},
		enemyTags: {},
		shrine: [],
		minLevel: 0, 
		allFloors: true, 
		removeOnLeash:false,
		removeOnPrison:true,
		bypass: true,
		events: [
			{trigger: "tick", type: "ravagerCheckForPinned", power: -1},
		],
		failSuffix: {"Remove": "RavagerOccupied", "Struggle": "RavagerOccupied", "Cut": "RavagerOccupied"},
		customEquip: 'RavagerOccupied',
		Model: "RavLiftedSkirt"
	},
	{
		name: "RavagerOccupiedButt", 
		Color: "#333333", 
		Group: "ItemButt",
		power: 99, 
		weight: 0, 
		specStruggleTypes: ["Struggle"], escapeChance: {"Struggle": -99, "Cut": -99, "Remove": -99},
		playerTags: {},
		enemyTags: {},
		shrine: [],
		minLevel: 0, 
		allFloors: true, 
		removeOnLeash:false,
		removeOnPrison:true,
		bypass: true,
		events: [
			{trigger: "tick", type: "ravagerCheckForPinned", power: -1},
		],
		failSuffix: {"Remove": "RavagerOccupied", "Struggle": "RavagerOccupied", "Cut": "RavagerOccupied"},
		customEquip: 'RavagerOccupied',
		Model: "RavLiftedSkirt"
	},
)
////////////////
// Events

// Handles preventing enemies from interfering with ravaging, with some narration included
KDEventMapInventory["tickAfter"]["ravagerSitDownAndShutUp"] = (e, item, data) => {
	console.log("[RavagerFramework] [ravagerSitDownAndShutUp]\ne: ", e, "\nitem: ", item, "\ndata: ", data)
	let nearby = KDNearbyEnemies(KinkyDungeonPlayerEntity.x, KinkyDungeonPlayerEntity.y, 5)
	let stunnedCount = 0
	let enemyName = ""
	nearby.forEach(enemy => {
		// Make sure we're only stunning non-ravagers
		if (!enemy.Enemy.ravage) {
			console.log("[RavagerFramework] [ravagerSitDownAndShutUp] Stunning ", enemy.Enemy.name)
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
	let nearby = KDNearbyEnemies(KinkyDungeonPlayerEntity.x, KinkyDungeonPlayerEntity.y, 4)
	let cleared = true
	nearby.forEach(enemy=>{
		if(enemy.ravage && !enemy.stun && !enemy.ravageRefractory) {
			cleared = false
			enemy.playWithPlayer = 5 // Keep them playing until they're done
		}
	})
	if(cleared) ravagerFreeAndClearAllData(); else {
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

// For occupied, make sure pinned is still there - if gone, shouldn't be!!
KDEventMapInventory["tickAfter"]["RavagerCheckForPinned"] = (e, item, data) => {
	let remove = false
	for (const inv of KinkyDungeonAllRestraint()) {
		if(inv.name == "Pinned") remove = true
	}
	if(remove) KDRemoveThisItem(item)
}

// We handle narration in an event since it's easier to get everything across multiple enemies grouped nicely this way
KDEventMapInventory["tickAfter"]["ravagerNarration"] = (e, item, data) => {
	let playerRavage = KinkyDungeonPlayerEntity.ravage
	KDModSettings['RavagerFramework'] && KDModSettings['RavagerFramework'].ravagerDebug && console.log('[Ravager Framework][ravagerNarration] ', playerRavage)
	if(playerRavage) {
		playerRavage.narrationBuffer.forEach(narration=>{
			KinkyDungeonSendActionMessage(20, narration, "#ff00ff", 1, false, true);
		})
		playerRavage.narrationBuffer = []
	}
}

// In case the player passes out for unrelated reasons
if(!KDEventMapInventory["passout"]) KDEventMapInventory["passout"] = {}
KDEventMapInventory["passout"]["ravagerRemove"] = (e, item, data) => {
	ravagerFreeAndClearAllData()
	// Keep panties gone as a souvenir
	setTimeout(()=>
		KDGetDressList()[KinkyDungeonCurrentDress].forEach(article=> {
			if(["Panties"].some(str => article.Item.includes(str))) {
				article.Lost = true
			}
		})
	, 1)
}

// If pin is broken: resets ravage, clears leash, and stuns ravagers
KDEventMapInventory["remove"]["ravagerRemove"] = (e, item, data) => {
	if(data.item.name == item.name) { // To make sure the item being removed is Pinned
		ravagerFreeAndClearAllDataIfNoRavagers()
	}
}

// Remove pin if this enemy was the last one ravaging on death
KDEventMapEnemy["death"]["ravagerRemove"] = (e, enemy, data) => {
	if (enemy.ravage && KinkyDungeonPlayerEntity.ravage) {
		ravagerFreeAndClearAllDataIfNoRavagers()
	}
} 

// Remove refractory on ravagers each turn
if(!KDEventMapEnemy["tickAfter"]) KDEventMapEnemy["tickAfter"] = {}
KDEventMapEnemy["tickAfter"]["ravagerRefractory"] = (e, enemy, data) => {
	if (enemy?.ravageRefractory > 0) enemy.ravageRefractory--
} 

////////////////
// Buffs/statuses
let KDRavaging = { // To keep enemy in one spot while they're busy
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

let KDRavaged = { // To focus the player in on what's happening
	id: "Ravaged", 
	type: "Blindness", 
	duration: 3, 
	power: 7.0, 
	player: true, 
	tags: ["passout"],
	noKeep: true,
	alwaysKeep: false,
}

////////////////
// Utils

// Util to just randomly select an array (annoyed at writing long lines)
function ravRandom(array) {
	if (array.length === 0) {
	  return undefined; 
	}
	const randomIndex = Math.floor(Math.random() * array.length);
	return array[randomIndex];
}

// Verbose? Perhaps. Accurate? Yes...
function ravagerFreeAndClearAllDataIfNoRavagers(showMessage = true) {
	let nearby = KDNearbyEnemies(KinkyDungeonPlayerEntity.x, KinkyDungeonPlayerEntity.y, 2)
	let cleared = false
	nearby.forEach(enemy=>{
		enemy.stun = 5
		if(enemy.ravage) {
			cleared = true
		}
	})
	if(cleared) {
		if(showMessage && KinkyDungeonPlayerEntity.ravage) KinkyDungeonSendTextMessage(30, "You break free of their grip, leaving an opening to escape!", "#ff0000", 4)
		ravagerFreeAndClearAllData()
		KDBreakTether(KinkyDungeonPlayerEntity)
	}
}

// Util to remove player and enemy ravager data
function ravagerFreeAndClearAllData() {
	// Clear all enemies
	for (const enemy of KDMapData.Entities) {
		if(enemy.ravage)
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

/** Key definitions **/
// Global "restraints"
KinkyDungeonAddRestraintText(
	'Stripped', 'Stripped!', 'Your panties got torn away...', 'You can just put them back on, but maybe don\'t worry about that if you\'re currently pinned down...'
);
KinkyDungeonAddRestraintText(
	'Pinned', 'Pinned!', 'Something or someone is having their way with you.', 'You can\'t move unless you get them off you! Freeing yourself will stun nearby enemies.'
);
// These all use the same descriptor, suggesting you fight Pinned instead.
let slotsArr = ['Mouth', 'Vulva', 'Butt']
for (var i in slotsArr) {
	// KDModSettings['RavagerFramework'].ravagerDebug && console.log('RavagerOccupied' + slotsArr[i])
	KinkyDungeonAddRestraintText('RavagerOccupied' + slotsArr[i], 'Occupied!', 'Someone or something is having their way with you...', 'Don\'t worry about this restraint. Instead, try to escape "Pinned!"');
}
KinkyDungeonAddRestraintText(
	'RavagerOccupiedHead', 'Gripped!', 'Someone or something is having their way with you...', 'Don\'t worry about this restraint. Instead, try to escape "Pinned!"'
);
// Since it's supposed to be impossible to struggle out of "Occupied!", and you have to use debug mode to get one to equip to yourself, you should just use debug mode to give yourself a "Pinned!" and equip it
addTextKey('KinkyDungeonSelfBondageRavagerOccupied', 'You shouldn\'t have done that~ Equip "Pinned" to yourself to fix it~')

addTextKey('KinkyDungeonStruggleStruggleFailRavagerPinned', 'You try to break free...')
addTextKey('KinkyDungeonStruggleStruggleFailRavagerPinnedAroused', 'You try to break free, but you\'re quickly put back in your place...')
addTextKey('KinkyDungeonStruggleStruggleImpossibleRavagerPinned', 'You try to break free, but you can barely push back...')
addTextKey('KinkyDungeonStruggleStruggleImpossibleRavagerPinnedAroused', 'You try to break free, but you\'re quickly put back in your place...')
addTextKey('KinkyDungeonStruggleStruggleImpossibleBoundRavagerPinned', 'You squirm and try to fight back, but you can barely move... It\'s hopeless.')
addTextKey('KinkyDungeonStruggleStruggleImpossibleBoundRavagerPinnedAroused', 'It\'s hopeless... You can only give in...')

addTextKey('KinkyDungeonStruggleRemoveFailRavagerPinned', 'You try to push your attacker off you...')
addTextKey('KinkyDungeonStruggleRemoveFailRavagerPinnedAroused', 'You try to push your attacker away, but they pin you down rougher...')
addTextKey('KinkyDungeonStruggleRemoveImpossibleRavagerPinned', 'You try to push your attacker away, but you\'re getting weak...')
addTextKey('KinkyDungeonStruggleRemoveImpossibleRavagerPinnedAroused', 'You try to push your attacker away, but their tightening grip feels so good...')
addTextKey('KinkyDungeonStruggleRemoveImpossibleBoundRavagerPinned', 'You try to push your attacker away, but you can barely move...')
addTextKey('KinkyDungeonStruggleRemoveImpossibleBoundRavagerPinnedAroused', 'Fighting back is hopeless... You can only give in...')

addTextKey('KinkyDungeonStruggleCutFailRavagerPinned', 'You swing your weapon uselessly at your attacker...')
addTextKey('KinkyDungeonStruggleCutFailRavagerPinnedAroused', 'You swing your weapon at your attacker, but you\'re too distracted to land a hit...')
addTextKey('KinkyDungeonStruggleCutImpossibleRavagerPinned', 'You try your best to swing at your attacker, but you\'re getting weak...')
addTextKey('KinkyDungeonStruggleCutImpossibleRavagerPinnedAroused', 'You try your best to strike at your attacker, but the pleasure in your body makes you sloppy...')
addTextKey('KinkyDungeonStruggleCutImpossibleBoundRavagerPinned', 'You try to lift your weapon, but your body doesn\'t obey...')
addTextKey('KinkyDungeonStruggleCutImpossibleBoundRavagerPinnedAroused', 'Fighting is useless... You can only give in...')
// Custom equip text for pinned just because
// Self-equipping Pinned will have it immediately removed as well as any Occupied on the player, assuming there isn't a ravager on the player
addTextKey('KinkyDungeonSelfBondageRavagerPinned', 'How are you planning to pin yourself down?~')

// Stripped keys
// The 'Impossible' keys may not actually get used ever, but I've made them obvious incase someone finds a way to get them triggered
addTextKey('KinkyDungeonStruggleRemoveFailRavagerStripped', 'You try to pull your panties back on despite your restraints...')
addTextKey('KinkyDungeonStruggleRemoveFailRavagerStrippedAroused', 'You try to pull your panties back on, but your arousal makes you clumsy...')
addTextKey('KinkyDungeonStruggleStruggleFailRavagerStripped', 'You struggle to get your panties back in place despite your restraints...')
addTextKey('KinkyDungeonStruggleStruggleFailRavagerStrippedAroused', 'You struggle to get your panties back in place, but your arousal makes you clumsy...')

addTextKey('KinkyDungeonStruggleRemoveImpossibleRavagerStripped', 'POST SCREENSHOT OF THIS TO THE RAVAGER FRAMEWORK THREAD -StripRI') // 'TESTING KinkyDungeonStruggleRemoveImpossibleRavagerStripped')
addTextKey('KinkyDungeonStruggleRemoveImpossibleRavagerStrippedAroused', 'POST SCREENSHOT OF THIS TO THE RAVAGER FRAMEWORK THREAD -StripRIA') // 'TESTING KinkyDungeonStruggleRemoveImpossibleRavagerStrippedAroused')
addTextKey('KinkyDungeonStruggleRemoveImpossibleBoundRavagerStripped', 'POST SCREENSHOT OF THIS TO THE RAVAGER FRAMEWORK THREAD -StripRIB') // 'TESTING KinkyDungeonStruggleRemoveImpossibleBoundRavagerStripped')
addTextKey('KinkyDungeonStruggleRemoveImpossibleBoundRavagerStrippedAroused', 'POST SCREENSHOT OF THIS TO THE RAVAGER FRAMEWORK THREAD -StripRIBA') // 'TESTING KinkyDungeonStruggleRemoveImpossibleBoundRavagerStrippedAroused')

addTextKey('KinkyDungeonStruggleStruggleImpossibleRavagerStripped', 'POST SCREENSHOT OF THIS TO THE RAVAGER FRAMEWORK THREAD -StripSI') // 'TESTING KinkyDungeonStruggleStruggleImpossibleRavagerStripped')
addTextKey('KinkyDungeonStruggleStruggleImpossibleRavagerStrippedAroused', 'POST SCREENSHOT OF THIS TO THE RAVAGER FRAMEWORK THREAD -StripSIA') // 'TESTING KinkyDungeonStruggleStruggleImpossibleRavagerStrippedAroused')
addTextKey('KinkyDungeonStruggleStruggleImpossibleBoundRavagerStripped', 'POST SCREENSHOT OF THIS TO THE RAVAGER FRAMEWORK THREAD -StripSIB') // 'TESTING KinkyDungeonStruggleStruggleImpossibleBoundRavagerStripped')
addTextKey('KinkyDungeonStruggleStruggleImpossibleBoundRavagerStrippedAroused', 'POST SCREENSHOT OF THIS TO THE RAVAGER FRAMEWORK THREAD -StripSIBA') // 'TESTING KinkyDungeonStruggleStruggleImpossibleBoundRavagerStrippedAroused')
// Custom escape and equip keys just added in 5.4-nightly7b
addTextKey('KinkyDungeonStruggleStruggleSuccessRavagerStripped', 'You feel relaxed with your panties on again')
addTextKey('KinkyDungeonStruggleRemoveSuccessRavagerStripped', 'You feel relaxed with your panties on again')
addTextKey('KinkyDungeonSelfBondageRavagerStripped', 'You slowly slip off your panties')

// I can't seem to modify the Impossible2 and Impossible3 keys that are used *sometimes* when struggling against an impossible restraint repeatedly
// I'm adding all of these keys to act as an alert if they ever start working
addTextKey('KinkyDungeonStruggleStruggleImpossible2RavagerOccupied', 'POST SCREENSHOT OF THIS TO THE RAVAGER FRAMEWORK THREAD -Struggle1') // 'TESTING KinkyDungeonStruggleStruggleImpossible2RavagerOccupied')
addTextKey('KinkyDungeonStruggleStruggleImpossible3RavagerOccupied', 'POST SCREENSHOT OF THIS TO THE RAVAGER FRAMEWORK THREAD -Struggle2') // 'TESTING KinkyDungeonStruggleStruggleImpossible3RavagerOccupied')
addTextKey('KinkyDungeonStruggleStruggleImpossibleRavagerOccupied2', 'POST SCREENSHOT OF THIS TO THE RAVAGER FRAMEWORK THREAD -Struggle3') // 'TESTING KinkyDungeonStruggleStruggleImpossibleRavagerOccupied2')
addTextKey('KinkyDungeonStruggleStruggleImpossibleRavagerOccupied3', 'POST SCREENSHOT OF THIS TO THE RAVAGER FRAMEWORK THREAD -Struggle4') // 'TESTING KinkyDungeonStruggleStruggleImpossibleRavagerOccupied3')

addTextKey('KinkyDungeonStruggleCutImpossible2RavagerOccupied', 'POST SCREENSHOT OF THIS TO THE RAVAGER FRAMEWORK THREAD -Cut1') // 'TESTING KinkyDungeonStruggleCutImpossible2RavagerOccupied')
addTextKey('KinkyDungeonStruggleCutImpossible3RavagerOccupied', 'POST SCREENSHOT OF THIS TO THE RAVAGER FRAMEWORK THREAD -Cut2') // 'TESTING KinkyDungeonStruggleCutImpossible3RavagerOccupied')
addTextKey('KinkyDungeonStruggleCutImpossibleRavagerOccupied2', 'POST SCREENSHOT OF THIS TO THE RAVAGER FRAMEWORK THREAD -Cut3') // 'TESTING KinkyDungeonStruggleCutImpossibleRavagerOccupied2')
addTextKey('KinkyDungeonStruggleCutImpossibleRavagerOccupied3', 'POST SCREENSHOT OF THIS TO THE RAVAGER FRAMEWORK THREAD -Cut4') // 'TESTING KinkyDungeonStruggleCutImpossibleRavagerOccupied3')

addTextKey('KinkyDungeonStruggleRemoveImpossible2RavagerOccupied', 'POST SCREENSHOT OF THIS TO THE RAVAGER FRAMEWORK THREAD -Remove1') // 'TESTING KinkyDungeonStruggleRemoveImpossible2RavagerOccupied')
addTextKey('KinkyDungeonStruggleRemoveImpossible3RavagerOccupied', 'POST SCREENSHOT OF THIS TO THE RAVAGER FRAMEWORK THREAD -Remove2') // 'TESTING KinkyDungeonStruggleRemoveImpossible3RavagerOccupied')
addTextKey('KinkyDungeonStruggleRemoveImpossibleRavagerOccupied2', 'POST SCREENSHOT OF THIS TO THE RAVAGER FRAMEWORK THREAD -Remove3') // 'TESTING KinkyDungeonStruggleRemoveImpossibleRavagerOccupied2')
addTextKey('KinkyDungeonStruggleRemoveImpossibleRavagerOccupied3', 'POST SCREENSHOT OF THIS TO THE RAVAGER FRAMEWORK THREAD -Remove4') // 'TESTING KinkyDungeonStruggleRemoveImpossibleRavagerOccupied3')
//
slotsArr = ['FailRavagerOccupied', 'FailRavagerOccupiedAroused', 'ImpossibleRavagerOccupied', 'ImpossibleRavagerOccupiedAroused', 'ImpossibleBoundRavagerOccupied', 'ImpossibleBoundRavagerOccupiedAroused'] // Need to 'NeedEdgeWrongEdge' keys for Remove keys, as well as HookHigh, ScrapObjectUse
for (var i in slotsArr) {
	addTextKey('KinkyDungeonStruggleStruggle' + slotsArr[i], 'You need to get them off you first! (Struggle against "Pinned!")')
	addTextKey('KinkyDungeonStruggleCut' + slotsArr[i], 'You need to get them off you first! (Struggle against "Pinned!")')
	addTextKey('KinkyDungeonStruggleRemove' + slotsArr[i], 'You need to get them off you first! (Struggle against "Pinned!")') // This one doesn't seem to be working. Seems it has a different key -- Seems to be working now
}

addTextKey('KinkyDungeonStruggleRemoveNeedEdgeWrongEdgeRavagerOccupied', 'You need to get them off you first! (Struggle against "Pinned!")')
addTextKey('KinkyDungeonStruggleRemoveNeedEdgeWrongEdgeRavagerOccupiedAroused', 'You need to get them off you first! (Struggle against "Pinned!")')

// addTextKey("KinkyDungeonStruggleStruggleFailRavagerOccupied","You need to get them off you first! (Struggle against 'Pinned!')")
// addTextKey("KinkyDungeonStruggleStruggleFailRavagerOccupiedAroused","You need to get them off you first! (Struggle against 'Pinned!')")
// addTextKey("KinkyDungeonStruggleStruggleImpossibleRavagerOccupied","You need to get them off you first! (Struggle against 'Pinned!')")
// addTextKey("KinkyDungeonStruggleStruggleImpossibleRavagerOccupiedAroused","You need to get them off you first! (Struggle against 'Pinned!')")
// addTextKey("KinkyDungeonStruggleStruggleImpossibleBoundRavagerOccupied","You need to get them off you first! (Struggle against 'Pinned!')")
// addTextKey("KinkyDungeonStruggleStruggleImpossibleBoundRavagerOccupiedAroused","You need to get them off you first! (Struggle against 'Pinned!')")
