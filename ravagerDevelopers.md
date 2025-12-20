# Making a ravager
Making a ravager is quite simple, there's only a few required parts:
- An attack type including "Effect"
- The `Ravage` effect
- Two events: `ravagerRemove` and `ravagerRefractory`
- A `ravage` section

The following sections will go through each of these and the optional additions available.

If you would like examples in the form of a ready-to-use ravager, take a look at [exampleEnemy.ks](Enemies/exampleEnemy.ks).

## Required parts
### Attack type
The attack type (declared in the `attack` key) can be whatever you like, as long as it includes "Effect". The Effect type is the first step to enable an enemy acting as a ravager.

As an example, the Bandit Ravager uses "MeleeEffectBlind", so she needs to be next to the player to ravage and her attacks apply a blinding effect.

### The Ravage effect
This is a simple requirement, as it declares what effect the "Effect" part of `attack` will use. In your enemy definition, you need `effect.effect.name = "Ravage"`.

In the form of the enemy declaration, it should look like this:
```
let enemy = {
  ...
  effect: {
    effect: {
      name: "Ravage"
    }
  },
  ...
}
```

### Ravager events
There are two events needed for a ravager to function properly. In the enemy declaration, they should look like this:
```
let enemy = {
  ...
  events: [
    {
      trigger: "death",
      type: "ravagerRemove"
    },
    {
      trigger: "tickAfter",
      type: "ravagerRefractory"
    }
  ],
  ...
}
```
#### ravagerRemove
This event is to ensure the player is released from the "Pinned!" and "Occupied!" restraints, as well as remove the player's ravaging state, when the last ravager using them is killed.

Without this, the player would likely remain pinned despite no ravagers being present.

#### ravagerRefractory
This event handles the refractory period of ravagers (how long they wait between finishing using the player and beginning again).

Without this, the ravager would use the player once and then never again. If this is your desired behavior, you should set your ravager's refractory period to -1. See [Refractory period](#refractory-period) for details.

### The ravage section
This section is the most involved, but for a simple ravager, is very straight forward. The ravage section consists of 3 required pieces:
- The `targets` array; an array of all targets a ravager can choose to occupy.
  + Current options are `ItemVulva`, `ItemMouth`, and `ItemButt`. `ItemButt` will only be usable if the "Rear Plugs" option is enabled for the save file.
  + There is a fourth slot, `ItemHead`, but this slot has not yet been tested and may have unknown bugs hiding within.
- The `refractory` time; a number of turns the ravager will wait between finishing a ravaging and starting again
- The `ranges` array; an array that defines the effects of ravaging across the range of progression values, as well as the range of progression.
  + Detailed explanation in [Ranges](#ranges)

Though these are the minimum requirements, there is a number of technically optional keys which will make your ravager feel much more fully functional. Available values are defined in [Ravaging](#ravaging)

## Ravaging
This section will better explain all available options within the `ravage` key of your ravager

### Targets
The list of slots a ravager can choose to target. When choosing a slot, the ravager will randomly pick an available slot from this list.

Property path: `enemy.ravage.targets`

Required?: Yes

Type: Array

Valid values: `ItemVulva`, `ItemMouth`, `ItemButt`, `ItemHead`

Notes:
- "Available" here essentially means another ravager is not already occupying that slot
- `ItemButt` will not be available to any ravager if the "Rear Plugs" option is disabled for the save file
- `ItemHead` is currently untested, but *should* work the same as the others. Bug reports welcome for any issues found

### Refractory period
The number of turns a ravager will wait to ravage again after finishing the previous session.

Property path: `enemy.ravage.refractory`

Required?: Yes

Type: Number

Valid values: Any number

Notes:
- Any positive number will be a number of turns to wait. This is likely the behavior you want
- Zero means there will be no refractory period. The turn after finishing, the ravaging can begin again
- A negative number will result in the ravager using the player once, and never again
  + If this is the behavior you want, it's recommended to set `refractory` to `-1`, as the corresponding value tracking the countdown will still be decremented every turn your ravager is alive.

### Need eyes
Controls whether or not the ravager will strip blindfolds and other eye coverings when targeting `ItemMouth`

Property path: `enemy.ravage.needsEyes`

Required?: No

Type: Boolean

Default value: False

Note: When combined with [Callback functions](#callback-functions), you could implement pretty unique behavior, such as hypnosis mechanics.

### Bypass items
There's two properties that control what a ravager can bypass during the "Strip" phase.

#### bypassAll
When true, causes the ravager to skip stripping any clothing or restraints during the strip phase.

Property path: `enemy.ravage.bypassAll`

Required?: No

Type: Boolean

Default value: False

#### bypassSpecial
Defines what clothing and restraint items will be skipped when stripping the player

Property path: `enemy.ravage.bypassSpecial`

Required?: No

Type: Array of strings

Default value: []

Valid values: Item/restraint names, or sub-strings of names

Notes:
- Sub-strings can be used to bypass whole classes of items.
  + Example: Adding "Slime" to the array will cause the ravager to skip stripping all Slime restraints

### Onomatopoeia
An array of strings to be displayed above a ravager's head while *using* the player.

Property path: `enemy.ravage.onomatopoeia`

Required?: No

Type: Array of strings

Default value: []

Notes:
- Strings given here will be randomly chosen from when showing the floating text
- While this is optional, this text is shown quite often while ravaging and may result in a ravager feeling half finished if missing

### Done taunts
An array of strings to be displayed above a ravager's head when finishing with the player.

Property path: `enemy.ravage.doneTaunts`

Required?: No

Type: Array of strings

Default value: []

Notes:
- Strings given here will be randomly chosen from when showing the floating text
- While this is optional, omitting this will result in your ravager being "silent" when finishing with the player

### Fallback narration
An array of strings to be shown in the text log when a ravager attacks with the Ravage effect, but cannot take a ravaging action.

Your narrations have a couple of options for dynamic strings. When displaying narration, the string "EnemyName" will be replaced with the attacking ravager's name and "DamageTaken" will be replaced with the amount of damage taken.

Property path: `enemy.ravage.fallbackNarration`

Required?: No

Type: Array of strings

Default value: []

Notes:
- There's two common reasons the fallback narration will be used:
  1) All the slots the ravager can use (defined in [Targets](#targets)) are currently occupied by other ravagers
  2) The ravager has recently finished a session with the player and is in their [refractory period](#refractory-period)
- With this being optional, if you do not declare your own narration, the framework's default narration will be used.
  + If your desired behvior is to not have fallback narration, see [No fallback narration](#no-fallback-narration).

### No fallback narration
Tell the framework not to use fallback narration. Useful if you don't want fallback narration, as the framework has a default narration

Property path: `enemy.ravage.noFallbackNarration`

Required?: No

Type: Boolean

Default value: False

Note: As of fixing [Issue #6](https://github.com/CronaTheNeko/ravagerFramework/issues/6), the framework provides default fallback narration. When `enemy.ravage.fallbackNarration` is empty or not defined and this property is not set to true, the default narration will be used. This property provides a way to not use fallback narration, if that is the desired behvior.

### Restrain chance
The chance that a ravager will add a restraint to the player when doing a fallback action. If this chance succeeds on a turn, a restraint will be added instead of dealing the normal grope damage.

Property path: `enemy.ravage.restrainChance`

Required?: No

Type: Number

Default value: `0.0`

Valid values: Decimals between `0.0` and `1.0`

Note: A limitation of the current implementation is that only restraints given by `KDGetJailRestraints()`. See [Fallback callback](#fallback-callback) if you'd like to add different restraints, but be sure that you read and understand that callback's `Note 1`

### Ranges
Probably the most involved portion of making a ravager, possibly only surpassed by [Callback functions](#callback-functions), this array defines the length of time your ravager will use the player, as well as the effects caused throughout the various stages of ravaging.

Property path: `enemy.ravage.ranges`

Required?: Yes

Type: Array of arrays, each of those being `[ progressionValue, rangeData ]`

Valid values: Each element in this array must be an array of two elements; the first element being the progression value to compare to the ravager's progression; the second element ([Range Data](#range-data)) is a dictionary containing all the data for that range

Notes:
- `progressionValue` is explained below in [Progression Value](#progression-value)
- `rangeData` is explained below in [Range Data](#range-data)

#### Progression Value
Range progression values can be any number 1 or higher. The framework will look across each of these values in the ranges array, and the first one it finds with a value greater than or equal to the ravager's current progression is the range that will be used.

**Note:** You should ensure that your ranges are declared in ascending order, as the framework currently does not check the numeric ordering of `ranges`. As an example, if your `ranges` array has range 5 in the first element and range 1 in the second element, range 1 will NEVER be used; the framework will find range 5, see that it is greater than or equal to the current progression, and not look any further into the ranges array until the progression reaches 6, at which point both range 5 and range 1 are "over".

#### Range Data
This dictionary defines:
- Taunts that float above the ravager
- Narration options for each slot
- Stat damage to apply
- Bonus chance for the player to orgasm
- [Callback functions](#callback-functions)

For the property paths of each of the following properties, the base of the path will be referred to as `rangeData`. See [Ranges](#ranges) for where the property path of `rangeData`.

##### Taunts
The strings to be shown above the ravager's head when starting a range.

Property path: `rangeData.taunts`

Required?: No

Type: Array of strings

Default value: []

Note: Strings given here will be randomly chosen from when showing the floating text

##### Narration
Defines the narration shown in the text log for each slot the ravager can target.

Property path: `rangeData.narration`

Required?: Yes

Type: Dictionary with a key-value pair for each slot in `targets` and its narration

Note: The key is the name of the slot, and the value is an array of strings to be chosen randomly and displayed at the top of screen.

Example:
```
narration: {
  ItemVulva: ["Sample narration vulva"],
  ItemMouth: ["Sample narration mouth"]
}
```

##### Stat Damages
Property path: `rangeData.sp`, `rangeData.dp`, `rangeData.wp`, `rangeData.sub`

Required?: No

Type: Number

Default value: None (Ignored if no value given)

Valid values: Positive or negative numbers, decimals included

Notes: 
- For each of these properties, a positive number will increase that stat and a negative number will decrease that stat
- For `sp` (Stamina) and `wp` (Willpower), you likely want to decrease them
- For `dp` (Distraction) and `sub` (Submissiveness), you likely want to increase them
- This is kept optional for the sake of starting off with no stat damage, then increasing damage over time

##### Orgasm Bonus
A bonus applied to the player's chance to orgasm.

Property path: `rangeData.orgasmBonus`

Required?: No

Type: Number

Default value: 0

Valid values: Positive or negative numbers

Notes:
- The orgasm chance is decided by KD's `KinkyDungeonDoTryOrgasm`. The modifiers given to it are the number of slots occupied plus `rangeData.orgasmBonus`
- Giving this bonus as a negative number would likely work, but is currently untested

#### Use Count Influence
Defines if/how the player's slot use counts will be changed during a range, for use by Experience Aware text. Doing so inside a range definition allows for plenty of flexibility as to when and how many times you want to count the player as having been used.

Property path: `rangeData.useCount`

Required?: No

Type: Number, or dictionary

Default value: 1

Valid values: Any number, or a dictionary with key/value pairs being the slot and the number to increment the player's use count by.

Notes:
- If you simply want to increment the player's use count by one at the end of a session, regardless of slot, this value is unnecessary since that is the framework's default behavior.
- If you'd like to increment the player's use count for some slots and not others, set this value to a dictionary which has the slots you want to increment, while omitting the slots you don't want to increment
- If you'd like to not increment the player's use count at all, set this value to 0
- To validate you ravager's EAM settings, use the browser console and call `RFVerifyEAM(ravagerName)` with your ravager's name

Examples:
- Incrementing use count by two for all slots: `useCount: 2`
- Not incrementing use count for any slots: `useCount: 0`
- Incrementing for ItemVulva and ItemButt, but not ItemMouth:
```
useCount: {
  ItemVulva: 1,
  ItemButt: 1
}
```

#### Experience Aware Taunts
Defines the text above the ravager's head for Experience Aware Mode. The structure of this data mimics [ranges](#ranges) and [rangeData](#range-data).

Property path: `rangeData.experiencedTaunts`

Required?: No

Type: Array of arrays, each of those being `[ slotUseCount, tauntDictionary ]`

Valid values: Each element in this array must be an array of two elements; the first element being the number of times a ravager has used a given slot; the second element is a dictionary containing the taunts for each slot. See below for an example.

Notes:
- Just like [Ranges](#ranges), the values defined here are not sorted. The last element in the array that has a `slotUseCount` less than or equal to the player's use count in the slot the ravager chooses will be used, even if there's a higher `slotUseCount` earlier in the array.
- Each slot is optional, and there shouldn't be any issue in omitting any slots from these taunt lists.
- Just like [Taunts](#taunts), the taunt that will be used is chosen randomly from the given array of taunts.
- Just like [Taunts](#taunts), the string "EnemyName" in your taunts will be replaced by the ravager's name.
- To validate you ravager's EAM settings, use the browser console and call `RFVerifyEAM(ravagerName)` with your ravager's name

Example:
```
experiencedTaunts: [
  [ 1, { // Defines taunts to be used after the player has been used once in the slot your ravager chooses
    ItemVulva: [ "Example EAM Vulva Taunt 1", "Example EAM Vulva Taunt 2" ],
    ItemButt: [ "Example EAM Butt Taunt 1", "Example EAM Butt Taunt 2" ],
    ItemMouth: [ "Example EAM Mouth Taunt 1", "Example EAM Mouth Taunt 2" ]
  }],
  [ 2, { // Defines taunts to be used after the player has been used two or more times in the slot your ravager chooses
    ItemVulva: [ "Example EAM Vulva Taunt 1", "Example EAM Vulva Taunt 2" ],
    ItemButt: [ "Example EAM Butt Taunt 1", "Example EAM Butt Taunt 2" ],
    ItemMouth: [ "Example EAM Mouth Taunt 1", "Example EAM Mouth Taunt 2" ]
  }]
]
```

#### Experience Aware Narration
Defines the narration to be used for Experience Aware Mode. The structure of this data mimics [ranges](#ranges) and [rangeData](#range-data).

Property path: `rangeData.experiencedNarration`

Required?: No

Type: Array of arrays, each of those being `[ slotUseCount, narrationDictionary ]`

Valid values: Each element in this array must be an array of two elements; the first element being the number of times a ravager has used a given slot; the second element is a dictionary containing the narration for each slot. See below for an example.

Notes:
- Just like [Ranges](#ranges), the values defined here are not sorted. The last element in the array that has a `slotUseCount` less than or equal to the player's use count in the slot the ravager chooses will be used, even if there's a higher `slotUseCount` earlier in the array.
- Each slot is optional, and there shouldn't be any issue in omitting any slots from these narration lists.
- Just like [Narration](#narration), the narration that will be used is chosen randomly from the given array of narrations.
- Just like [Narration](#narration), the string "EnemyName" in your narrations will be replaced by the ravager's name.
- To validate you ravager's EAM settings, use the browser console and call `RFVerifyEAM(ravagerName)` with your ravager's name

Example:
```
experiencedNarration: [
  [ 1, { // Defines narration to be used after the player has been used once in the slot your ravager chooses
    ItemVulva: [ "Example EAM Vulva Narration 1", "Example EAM Vulva Narration 2" ],
    ItemButt: [ "Example EAM Butt Narration 1", "Example EAM Butt Narration 2" ],
    ItemMouth: [ "Example EAM Mouth Narration 1", "Example EAM Mouth Narration 2" ]
  }],
  [ 2, { // Defines narration to be used after the player has been used two or more times in the slot your ravager chooses
    ItemVulva: [ "Example EAM Vulva Narration 1", "Example EAM Vulva Narration 2" ],
    ItemButt: [ "Example EAM Butt Narration 1", "Example EAM Butt Narration 2" ],
    ItemMouth: [ "Example EAM Mouth Narration 1", "Example EAM Mouth Narration 2" ]
  }]
]
```

#### Experience Aware Mode Chance
Defines the chance that a ravager will use Experience Aware Mode taunts and narration

Property path: `rangeData.experiencedChance`

Required?: No

Type: Number

Valid values: Decimals between `0.0` and `1.0`, representing a `0%` to `100%` chance

Notes:
- This value overrides the mod config preference for chance-based/guaranteed use of Experience Aware text, but can also be overridden by the mod config if the user desires.
- When neither this property nor `rangeData.experiencedAlways` are set, the use of Experience Aware text is left up to the relevant mod configs and controlled by the user. This means that Experience Aware text being used is determined by either the user-controlled chance or always, based on which the user prefers.
- To validate you ravager's EAM settings, use the browser console and call `RFVerifyEAM(ravagerName)` with your ravager's name

#### Experience Aware Mode Always
Makes a ravager prefer to always use Experience Aware Mode taunts and narration.

Property path: `rangeData.experiencedAlways`

Required?: No

Type: Boolean

Default value: false

Notes:
- This value overrides the mod config preference for chance-based/guaranteed use of Experience Aware text, but can also be overridden by the mod config if the user desires.
- When neither this property nor `rangeData.experiencedChance` are set, the use of Experience Aware text is left up to the relevant mod configs and controlled by the user. This means that Experience Aware text being used is determined by either the user-controlled chance or always, based on which the user prefers.
- To validate you ravager's EAM settings, use the browser console and call `RFVerifyEAM(ravagerName)` with your ravager's name

##### Callback
A reference to a callback function to be called during a specific range. Allows you to do extra stuff after all the normal ravaging actions for a specific range.

Property path: `rangeData.callback`

Required?: No

Type: String

Default value: None

Valid values: A string which matches the key of a callback added to the framework

Note: See [Callback functions](#callback-functions) for specifics on callbacks

### Callback functions
By far the most powerful, and most potentially complicated, feature of the framework is the callback functions that can be called at various stages throughout the ravaging process.

The following are the currently available callbacks that you can bind functions to:
- [effectCallback](#effect-callback)
- [allRangeCallback](#all-range-callback)
- [Range specific callbacks](#range-specific-callbacks)
- [submitChanceModifierCallback](#submit-chance-modifier-callback)
- [completionCallback](#completion-callback)
- [fallbackCallback](#fallback-callback)

For security, the callback functions cannot be declared directly in the enemy declaration. The callback keys in the ravager's declaration are strings which reference the name of your callback. 

To add a callback, define your function and add it via the [RFAddCallback helper](#rfaddcallback-helper) function, and set the corresponding callback property in your ravager to the callback name you gave to `RFAddCallback`.

Note: The parameters given to each callback are not set in stone. Incase of any changes to the parameter list, I will attempt to ensure the following:
1) Do not remove any parameters without notice in some form.
2) If a value provided as a parameter is no longer in use/available to the framework, provide an empty/default value of the same type, which will hopefully avoid breakages
3) Any new parameters added will be added to the end of the parameter list

#### RFAddCallback helper
When adding callbacks, it is recommended to use the function `RFAddCallback`. This function is globally available, so you simply need to call it with the required parameters for your callback to be added in the way the framework expects it to be.

Parameters:
1) `callbackKey` - The name your callback will be referenced by. This needs to match the value of the corresponding callback property in your ravager.
2) `callbackFunction` - The function to be executed. Can either be defined as a separate function and have the function name given, or directly declared used the `(parameter1, parameter2) => { code }` syntax.

Returns: True if the callback was successfully added, false if adding was unsuccessful.

Recommended usage:
```
function myCallback(x, y, z) {
  ...
}
if (!RFAddCallback('exampleCallbackName', myCallback)) {
  // Print an error about your callback or do something to handle its absence
}
```

Note 1: It is recommended to ensure your callback keys are sufficiently unique, as to avoid overwriting another ravager's callback unintentionally.

Note 2: This helper function does some checks to ensure the keys can be stored correctly. If you encounter the framework throwing an error when you call this function, please report it in a bug report, as an error reading "Failed to initialize the ravager callbacks key" indicates something is going terribly wrong with the framework's callback functionality.

#### Manually adding a callback
While there's nothing stopping you from avoiding the helper function, it is not recommended, as the helper function is there to ensure your callbacks get placed where the framework expects them to be and that location is not set in stone.

Nevertheless, you may still want to do so. For example, if `RFAddCallback` returns false to indicate your callback was not added, you may want to attempt to add it yourself.

Here's the steps to add a callback manually:
1) Make sure the dictionary `KDEventMapEnemy['ravagerCallbacks']` exists. This should exist, unless something has gone quite wrong with the framework, as the framework adds multiple of its own debug/example callbacks during initialization.
2) Set the value of `KDEventMapEnemy['ravagerCallbacks'][yourCallbackKey]` to be your function, either by referencing the name of a function you've declared or using the `(x, y, z) => { code }` syntax.

If you are experiencing issues with this method, please try using `RFAddCallback` and check your parameters before filing a bug report.

#### Effect callback
Property path: `enemy.ravage.effectCallback`

When is this called: Any time a ravager takes a 'ravaging' action against their target

Parameters:
- `enemy` - The enemy entity taking the action
- `target` - The target entity of the enemy

Expected return: True to skip all normal ravaging steps, false or no value to continue with normal ravaging steps

Note: This callback is effectively the first step in the ravaging function. If your function returns true, the framework will do NOTHING against the player for that turn and any actions to be taken will need to be done in your callback. This includes all narration, enemy floating text, damage, etc.

#### All range callback
Property path: `enemy.ravage.allRangeCallback`

When is this called: Whenever the ravager takes a ravaging action involving the ranges of progression. Different from `effectCallback`, as this callback does not get called during the strip, pin, or fallback phases, only during the occupied phase.

Parameters:
- `enemy` - The enemy entity taking the action
- `target` - The target entity of the enemy
- `slot` - The slot the ravager is targeting

Expected return: None

Note: Current possibilities for `slot` parameter are `ItemVulva`, `ItemMouth`, `ItemButt`, and `ItemHead`

#### Range-specific callbacks
Property path: `rangeData.callback`

When is this called: When taking a ravaging action inside a matching range.

Parameters:
- `enemy` - The enemy entity taking the action
- `target` - The target entity of the enemy
- `slot` - The slot the ravager is targeting

Expected return: None

Notes:
- Current possibilities for `slot` parameter are `ItemVulva`, `ItemMouth`, `ItemButt`, and `ItemHead`
- See [Range Data](#range-data) for what the property path `rangeData` means

#### Submit chance modifier callback
Property path: `enemy.ravage.submitChanceModifierCallback`

When is this called: Before checking the chance of a player submitting to the ravager for submission effects.

Parameters:
- `enemy` - The enemy entity taking the action
- `target` - The target entity of the enemy
- `baseSubmitChance` - The base chance for submission

Expected return: The modified chance for player submission, a number between 0 and 100 (representing 0% chance to 100% chance)

Note: If nothing is returned or the return type is not a Number (as decided by calling `typeof` on your return value), then the returned value will be ignored and `baseSubmitChance` will remain as the chance for submission.

#### Completion callback
Property path: `enemy.ravage.completionCallback`

When is this called: After the ravager finishes ravaging the player.

Parameters:
- `enemy` - The enemy entity taking the action
- `target` - The target entity of the enemy
- `passedOut` - Boolean for whether or not the player passes out from the ravaging

Expected return: None

Note: This callback is called after the player is (potentially) made to pass out. If you need to do something prior to passing out, you can make a [range callback](#range-specific-callback) for the last range in your `ranges` and check the value of `enemy.ravage.progress`.

#### Fallback callback
Property path: `enemy.ravage.fallbackCallback`

When is this called: Anytime a ravaging action fails (see [Fallback narration](#fallback-narration)).

Parameters:
- `enemy` - The enemy entity taking the action
- `target` - The target entity of the enemy

Expected return: None

Notes:
- Declaring this callback will completely override the normal fallback actions. Using this callback means you want to do your own fallback actions and the framework will do nothing as a fallback. [Issue 7](https://github.com/CronaTheNeko/ravagerFramework/issues/7) is a plan to change this behavior
- A current limitation of the framework's fallback actions, and thus a reason you may want to use this, is that the restraints added during the fallback actions are currently limited to jail restraints, but a change to this is planned.

## Ravager Bubbles
A new event has been added to allow custom bubbles for ravagers, with an image, duration, chance, and condition.

To get started, add the following to your enemy's events list:
```
{
  trigger: "tick",
  type: "ravagerBubble"
}
```
Those are the only values required to run the event, as those define what event to run. The following sub-sections will go over the optional settings for this event.

In the following sub-sections, the above example (the minimum required to add this event) will be referred to as `event`.

### Bubble chance
The chance on each game tick that the bubble will be shown. Value between `0.0` and `1.0` to represent 0% to 100% chance.

Property path: `event.chance`

Required?: No

Type: Number

Valid values: `0.0` through `1.0`

Default value: `0.3`

### Bubble duration
The number of game ticks that the bubble will be shown for after first being shown.

Property path: `event.duration`

Required?: No

Type: Number

Valid values: Any number greater than `0`

Default value: `3`

### Bubble image
The image to be shown as the ravager bubble. The default was designed for the mimic spoiler and is provided by the framework.

Property path: `event.image`

Required?: No

Type: String

Default value: `Hearts`

Note: To provide your own bubble image, the image you wish to use must be in `Conditions/RavBubble/` and be a `.png` image. This due to the framework getting the image using `KinkyDungeonRootDirectory + 'Conditions/RavBubble/${event.image}.png'`.

## Other enemy keys

### addedByMod
My attempt to suggest a standard for tracking custom enemies.

Entirely optional, but when the framework is modifying its enemies (such as disabling ravagers), the framework will often check this value to avoid modifying an enemy it didn't create.

The main times you'll likely want to use this are:

1) You agree with me and want the usage of this value to become standard
2) You're making a ravager that you wish to still be modified by the framework (set this to "RavagerFramework")
3) You're modifying a ravager added by the framework in such a way that is incompatible with how the framework modifies its ravagers (set this to something other than "RavagerFramework"); see notes for some info on modifying ravagers

Property path: `enemy.addedByMod`

Required?: No

Type: String

Notes:
- The currentl parts of the code where this value is checked to be "RavagerFramework" are:
  + Enabling/disabling enemies
  + Determining if the framework will use its custom item drop behvior (see [ravagerCustomDrop](#ravagercustomdrop) for enabling this behavior for your own ravagers)
  + Modifying the Slimegirl's "add slime restraint" chance
  + Modifying the "spiciness" of relevant enemy's narration (currently just the RavagerTendril and MimicRavager)
    - I do plan to change this behavior to allow spiciness of external ravagers to be handled by the framework. If you are seeing this and that behavior has not been changed and there is not an issue open for the plan to do so, please open an issue on GitHub. I am very forgetful.
- Modifying one of the framework's ravagers:
  + To allow your modifications to persist across the framework unloading and reloading its enemies, you should modify the root definitions of ravagers
  + As of writing, ravager definitions are across a two data structures:
    - The BanditRavager, WolfgirlRavager, SlimeRavager, TentaclePit, and RavagerTendril definitions are stored in `KDEventMapEnemy['ravagerCallbacks']['definition{EnemyName}']`
    - The MimicRavager definition is stored in `RavagerData.definitions.mimic`
    - This split in locations is from the in-progress change from using a data structure inherent to the game to my own data structure, which took me a while to figure out how to make it globally accessible.
    - If you are reading this, I have not yet moved all framework enemy definitions to `RavagerData.definitions`, and there is not an issue open for this on Github, please open an issue. My curse is forgetfulness.

### ravagerCustomDrop

Enables the framework's custom multi-item drop behavior. When enabled, this behavior allows enemies to drop multiple items on death without relying on however the base game handles such a thing.

Property path: `enemy.ravagerCustomDrop`

Required?: No

Type: Boolean

Notes:
- When enabled, `enemy.maxDrops` is also required. If `enemy.maxDrops` is missing, item drops will be handled by the game's original functionality
- Even when enabled for your enemy, multi-item drops will only be enabled when the `ravagerCustomDrop` ("Enable multi-item drops") mod setting is enabled by the user (this setting is enabled by default)
- This functionality prevents dropping the same item multiple times. Because of this, I recommend keeping your `enemy.maxDrops` low relative to the length of your dropTable, as too high a number of drops can cause your enemy's drops to be nearly or entirely constant (except for the amounts of any applicable items). If you'd like to see this behavior changed, feel free to open an issue on Github.

### maxDrops

Defines the maximum number of items that can be dropped when the enemy is using the framework's multi-item drop behavior.

Property path: `enemy.maxDrops`

Required?: No

Type: Number

Valid values: Any number greater than 0

Notes:
- If you enable the framework's multi-item drop behavior for your ravager, this value is required to enable multi-item drops
- If this is set to 0 or less, the framework's multi-item drop behavior will not be able to be used

### minDrops

Defines the minimum number of items that can be dropped when the enemy is using the framework's multi-item drop behavior.

Property path: `enemy.minDrops`

Required?: No

Type: Number

Valid values: Any number between 0 and `enemy.maxDrops`

Default value: `1`

## Text Replacements

Across many, if not all, places where the framework uses ravager-defined strings, it passes those strings through many text replacements.

This section will go through all the text replacements available.

Note: In the case of any of these values being at the beginning of the string, the first character will be capitalized so the strings don't turn out looking completely wrong.

Note: Some of these replacements may not have a use for you, as the strings they're made for are not currently controllable through ravager definitions. There are plans to change these strings to be controllable.

If you run into troubles with your strings and need debug info specific to the text replacements, check out [Developer Control Screen](#developer-control-screen) and [Debug NameFormat Function](#debug-nameformat-function)

### PlayerName

Any instance of "PlayerName" will be replaced with the player character's name in the current save file.

### EnemyName

When NameFormat is given an entity that is using this string, any instance of "EnemyName" will be replaced by the text key for the name of that entity

### EnemyCName

When NameFormat is given an entity that is using this string, any instance of "EnemyCName" will be replaced by either the entity's custom name (either by `entity.CustomName` or `KDGetName(entity.id)`), or by the text key for the name of that entity with the word "the" in front of the name.

Using this method allows cleanly using an enemy's custom name when available while avoiding a stray "the" in front of the name. For example, A bandit ravager with a custom name of Jennifer will have "EnemyCName" replaced with "Jennifer", while a bandit ravager with no custom name will have "EnemyCName" replaced with "the Bandit Ravager".

### EnemyCNameBare

When NameFormat is given an entity that is using this string, any instance of "EnemyCNameBare" will be replaced with the result of `KDEnemyName(entity)`. This is separate from EnemyCName as it will not add "the" before the name when there's not a custom name available for the entity.

### RestraintName

When an enemy is adding or removing a restraint from the player, NameFormat will be given that restraint and any instance of "RestraintName" will be replaced by the name of that restraint.

This is one of the options that is likely not currently useful to you, as the string used for with this is not currently controllable by a ravager definition.

### ClothingName

When an enemy is stripping the player, NameFormat will be given clothing item that was removed and any instance of "ClothingName" will be replaced by the name of that item.

This is one of the options that is likely not currently useful to you, as the string that uses this is not currently controllable by a ravager definition.

### DamageTaken

When an enemy is attacking the player, the amount of damage will be given to NameFormat and any instance of "DamageTaken" will be replaced by the corresponding damage string.

### Random String Choices

Random choice strings allow you to make strings with arbitrary variations that will change every time the string is used. The syntax is very basic, but still powerful. Options are wrapped in curly brackets and separated by a vertical bar. Example: "{option 1|option 2}".

These random selections can have any number of choices (such as "{option1|option2|option3|...|option50}"), can be nested inside each other to any depth (such as "{option1 {option1.1 {option1.1.1|option1.1.2}|option1.2}|option2}"), and can have empty options (such as "{modifier1|modifier2|}")

If you would like in-use examples of this functionality, you can check out the narration for the MimicRavager, as it makes heavy use of this feature and has multiple complex examples.

While any sections of curly brackets that don't contain a vertical bar will be passed unmodified into the output, you should consider curly brackets to be unsafe to use in your strings, as this functionality is sensitive to the number of opening and closing brackets and requires the numbers of each to match. If you have a use for mismatching curly brackets in your strings, feel free to tell me and I can modify this functionality to allow escaping brackets.

## Developer Control Screen

Version 6.2.0 adds a more powerful control screen aimed at developers, the "Ravager Hacking" menu.

To access this menu, you'll need to enable to button one of two ways:

1) On the main menu:
	- After mods finish loading, enable, disable, and re-enable the game's debug mode by clicking on the ball gag in the title three times
	- After doing so, the pink "Ravager Hacking" button will appear near the bottom left corner of the main menu

2) On the in-game pause menu:

	- With debug mode enabled on the main menu and the "Debug Mode" checkbox in the pause menu enabled, headpat your character twice
	- After doing so, the pink "Ravager Hacking" button will appear in the bottom right above the "See Perks" button

Currently, it doesn't have a way for external mods to add more settings, but that is a planned feature. If you're reading this, you want to use this menu for your own ravagers, and there isn't an issue open on GitHub, please open an issue. Can you believe how many things I can forget at once?

The current most useful options in this menu are the "Heavy Debugging" and "Debug NameFormat function" options.

### Heavy Debugging

Enabling this option will enable the framework's equivalent of `console.trace` messages. I've done it this way so I don't have to enable trace messages in the console, since the game spits out quite a lot of very large trace messages on its own.

These debugging messages happen A LOT. Their purpose is meant to allow me to follow through almost every line of code that the framework runs on every turn. If you enable this, I sure hope you really like scrolling.

### Debug NameFormat Function

This option is very similar to the Heavy Debugging option, but specifically for the `NameFormat` function that handles [Text Replacements](#text-replacements).

This was split to its own option after adding the randomized text options to the text replacements, as that addition makes NameFormat EASILY capable of printing hundreds of lines to the console every turn.

At the beginning of NameFormat, there will be a message telling you the string it's starting with.

After each of the basic text replacements (EnemyName, PlayerName, DamageTaken, etc.), there will be a message showing what the input text has been transformed into.

Upon reaching the randomized text replacements, you may need a guide to understand each line of output, as this portion prints a message for nearly every line of code.

Every message for the randomized text starts with "[Ravager Framework][DBG][InStringRandom]:" or "[Ravager Framework][DBG][InStringRandom][characterCount]:". As these are markers for stating what function the message comes from, I will be ignoring them for the upcoming explanations.

The random text function loops every character individually, so you'll likely see at least one of the following lines for every character in the string.

- The line "Input string doesn't contain any selections. Skipping." indicates that the input string is missing at least one of "{", "}", or "|" and will no be processed for random choices.
- A line starting with "Found a total of" is coming from the internal helper function for counting characters within a substring. This helper function is used to detect nested random choices. If you're using nested random choices, the relavant line for your nested choices should show a count of at least 2 for the character "|".
- A line starting with "(L) Level" is stating the current number of random choices the code is currently looking at. When at a part of the string that doesn't have a random choice, this line should state level 0. While parsing a choice, the level should be at least 1.
- A line starting with "(L+) Holding" means that the loop has found the opening bracket that signals the beginning of a random choice, the level has been incremented, and shows the text that is being held so that the random choice can actually be chosen when it finds the closing bracket.
- A line starting with "(L-) Holding" means that the loop has found the closing bracket that signals the end of a random choice, the level has been decremented, and shows the text that is about to be used to decide on the random choice
- A line starting with "(L0) Holding" means the loop is currently within a random choice section (level is above zero), and shows the text that is being held so that the random choice can actually be chosen when it finds the closing bracket.
- A line starting with "(L) Output" means the loop is not within a random choice section (level is less than one), and shows the current output string that will be returned at the end of the loop.
- A line starting with "(P) Holding" means the loop is now parsing the random choice and is going to make the decision shortly, and random selection string it's currently working with.
- A line starting with "(P)(NC) Output" means there's no "|" character in the currently held string and therefore has no choice to be made, the currently held string has been added to the output (preserving the surrounding brackets), and shows the current output string that will be returned at the end of the loop.
- A line starting with "(P) Substring" signals the beginning of actually parsing the random choice and shows the current random choice string without the surrounding brackets. Be aware that after this line, the function may recurse to handle nested random choices.
- A line starting with "(P)(R) Substring" means the function has just returned from a recursive call to itself in order to handle nested random choices, and shows the updated random choice string that no longer has any nested choices.
- A line starting with "(P) Options" shows all the random choices available by splitting the current random choice string by the "|" character.
- A line starting with "(P) Selection" shows the random choice from Options that has been selected.
- A line starting with "(P) Output" signals the end of the current random selection and shows the updated output string that will eventually be returned at the end of the loop.
- A line starting with "Final Output" signals the end of loop and shows what string is being returned now that all the random choices have been decided. Be aware that there may a number of these lines in the middle of the output if the function has to recurse for nested choices.

There are two possible errors for this section, in the case that the input string has a mismatch between the number of opening brackets and closing brackets. In the case of either of these errors, the string returned will be the input string with "[ERROR]" added onto the beginning.
