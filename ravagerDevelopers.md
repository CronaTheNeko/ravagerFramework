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

Property path: `enemy.ravage.fallbackNarration`

Required?: No

Type: Array of strings

Default value: []

Notes:
- There's two common reasons the fallback narration will be used:
  1) All the slots the ravager can use (defined in [Targets](#targets)) are currently occupied by other ravagers
  2) The ravager has recently finished a session with the player and is in their [refractory period](#refractory-period)
- While this is optional, this narration is used so often that it should probably be considered required
  + [Issue #6](https://github.com/CronaTheNeko/ravagerFramework/issues/6) is a plan to add a default fallback narration for any ravagers that don't declare their own

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

To add a callback, define your function and add it via the [RavagerAddCallback helper](#ravageraddcallback-helper) function, and set the corresponding callback property in your ravager to the callback name you gave to `RavagerAddCallback`.

#### RavagerAddCallback helper
When adding callbacks, it is recommended to use the function `RavagerAddCallback`. This function is globally available, so you simply need to call it with the required parameters for your callback to be added in the way the framework expects it to be.

Parameters:
1) `callbackKey` - The name your callback will be referenced by. This needs to match the value of the corresponding callback property in your ravager.
2) `callbackFunction` - The function to be executed. Can either be defined as a separate function and have the function name given, or directly declared used the `(parameter1, parameter2) => { code }` syntax.

Returns: True if the callback was successfully added, false if adding was unsuccessful.

Recommended usage:
```
function myCallback(x, y, z) {
  ...
}
if (!RavagerAddCallback('exampleCallbackName', myCallback)) {
  // Print an error about your callback or do something to handle its absence
}
```

Note 1: It is recommended to ensure your callback keys are sufficiently unique, as to avoid overwriting another ravager's callback unintentionally.

Note 2: This helper function does some checks to ensure the keys can be stored correctly. If you encounter the framework throwing an error when you call this function, please report it in a bug report, as an error reading "Failed to initialize the ravager callbacks key" indicates something is going terribly wrong with the framework's callback functionality.

#### Manually adding a callback
While there's nothing stopping you from avoiding the helper function, it is not recommended, as the helper function is there to ensure your callbacks get placed where the framework expects them to be and that location is not set in stone.

Nevertheless, you may still want to do so. For example, if `RavagerAddCallback` returns false to indicate your callback was not added, you may want to attempt to add it yourself.

Here's the steps to add a callback manually:
1) Make sure the dictionary `KDEventMapEnemy['ravagerCallbacks']` exists. This should exist, unless something has gone quite wrong with the framework, as the framework adds multiple of its own debug/example callbacks during initialization.
2) Set the value of `KDEventMapEnemy['ravagerCallbacks'][yourCallbackKey]` to be your function, either by referencing the name of a function you've declared or using the `(x, y, z) => { code }` syntax.

If you are experiencing issues with this method, please try using `RavagerAddCallback` and check your parameters before filing a bug report.

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

When is this called: Whenever the ravager takes a ravaging action involving the ranges of progression. Different from `effectCallback`, as this callback does not get called during the strip and pin phases, only during the occupied phase.

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
