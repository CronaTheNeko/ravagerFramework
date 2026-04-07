# Framework Translation
In this folder are the translations for the framework and its enemies. This document is intended to assist translators in translating the framework to a new language.

Contents:
1) [Folder Structure](#folder-structure)
2) [File Syntax](#file-syntax)
3) [Submitting a Translation](#submitting-a-translation)
4) [Making Your Translation](#making-your-translation)
	1) [What NOT to Translate](#what-not-to-translate)
	2) [Narration Randomization](#narration-randomization)
	3) [Complex Strings](#complex-strings)
		1) [Expanding Complex Strings](#expanding-complex-strings)
5) [Testing Your Translation](#testing-your-translation)
	1) [Entering Ravager Controls](#entering-ravager-controls)
	2) [Importing Your Translation](#importing-your-translation)
	3) [Testing Methods](#testing-methods)
6) [Further Questions](#further-questions)

If you have questions not answered by this document, need clarification, or need help with something, feel free to reach out with your questions.

## Folder Structure
Starting within this folder, each sub-folder is a language and should be named with the same abbreviation that Kinky Dungeon uses for that language. As of writing this, the game's current language options are English (EN), Chinese (CN), Korean (KR), Japanese (JP), Russian (RU), and Spanish (ES). If any additional languages are added, translations of this mod should work without any issues as long as the folder is named with the abbreviation the game uses for that language.

Within each of these folders, all text files (\*.txt) will be loaded by the framework and treated as text to be loaded into the game.

## File Syntax
The syntax of the files follows a simple "KEY = VALUE" style, with each key-value pair is on its own line.

Key points about syntax:
- Lines that start with a semi-colon ( ; ) are comments. You don't have to worry about translating comments, but they are helpful to read.
- For lines that are not comments, everything before the first " = " (space, equals, space) is treated as the key, and everything after that is treated as the value.
- Some text values are actually arrays of multiple options in the syntax of `KEY = [ "option 1", "option 2" ]`
  - These values are because the framework uses such arrays to have some variation throughout playtime
- Some other text values use my own syntax for varying strings, using `some text {option 1|option 2} some text`
  - See [Complex Strings](#complex-strings) for more clarification on translating these

Extra notes about syntax:
- Lines starting with a hyphen and a space ( "- " ) are text keys that get added to Kinky Dungeon's text system
  - The only thing you need to worry about for these keys is that you need to keep the hyphen and space before the key
- With this syntax, it *should* still be perfectly safe to use equals signs ( = ) within the text value, though there are currently no text keys in the English text that do so.

## Submitting a Translation
If you have a translation you'd like added into the framework, you've got a couple options to get them officially added into the next update.

You can either:
1) DM me the translation file(s)
2) Post it to the Ravager Framework thread in KD's Discord and ping me
3) Or open a pull request adding your translation on GitHub

Regardless of which method you use to submit your translation, please make it clear which language you are providing. 

If you're submitting your translation via Discord, please provide your translation files as an archive (zip, rar, or tar)

If you are editing a translation made by someone else, please attempt to get that person involved in the conversation. If that person submitted their translation via Discord or is known to be the translator in the Discord, ping them as well in your submission. If that person submitted their translation via GitHub and you're comfortable doing so, submit your edited translation on GitHub and ping the previous translator. As I don't speak the language you're translating into, I do not want to be in the middle of two translators fighting about whose translation is better. If there is future disagreements about whose translation is better, there may be the addition of an option for players to choose their preferred translation for any language that has multiple translations available

## Making Your Translation
For most of the text in the framework, translating is as simple as translating the text that comes after the first equals sign. The complexity comes from the two ways the framework uses to add variety to the ravaging narration and the variables that can be substituted into the narration when it's used.

Just make sure you don't change the text key. Everything before the first equals sign should be copied into your translation exactly as it is in the original English file.

### What NOT to Translate
There are a handful of things that either don't need to or shouldn't be translated.

1) Any line where the value is `~~{RavagerFrameworkNoMessageDisplay}~~`

  These lines are used to prevent the game from showing extra attack messages while the player is being ravaged and __need__ to remain unchanged. It's best to just not include these lines in your translation.

  Example: `AttackSlimeRavager = ~~{RavagerFrameworkNoMessageDisplay}~~` in EN/slime_ravager.txt

2) Any line that has an empty value

  These lines are intentionally left empty since the game tries to use them, but I haven't come up with some dialog to be used. It's best to just not include these lines in your translation.

  Example: `KinkyDungeonRemindJailChaseSlimeAdvAlert = ` in EN/slime_ravager.txt

3) At the end of EN/core.txt, most lines under the `; Ravager Control menu` comment

  The lines below that comment are used in the Ravager Control menu and are largely not meant to be seen by normal players. Because of this, most of these can be ignored, but please translate `RFCTitle`, `RFCReturn`, `RFCCategoryDebug`, and `RFCButtonDebugEndDebugLog`, as those are the ones that a player may be asked to interact with if they are attempting to provide a debug log to me.

4) Any of the variable replacement keys within the text

  These are used to substitute things like the enemy's name, the name of a restraint, or the amount of damage taken into the string that's shown to the player.

  The variable replacement keys are:
  - `PlayerName` - The player character's name
  - `EnemyName`, `EnemyCName`, `EnemyCNameBare` - The name of the enemy attacking the player, either the name of the entity (such as "Bandit Ravager") or as a name given to that specific enemy (such as "Anna")
  - `RestraintName` - The name of a restraint being added to or taken off the player
  - `ClothingName` - The name of a clothing item being added to or taken off the player
  - `DamageTaken` - The amount and kind of damage the player is taking from an attack

### Narration Randomization
The framework includes two ways of adding randomization to a line of narration: Arrays and custom formatted strings.

The first method of adding variations to the narration is through arrays of strings. The text key for these lines are just like the others, but the value is a JSON parsable array. As an example of how these lines will look:
```
SomeTextKey = [ "narration option 1", "narration option 2", "narration option 3" ]
```
For these, keep the array format the same, just translate each of the strings within the array.

The second method is a custom format string that allows for a single string to have as many variations as desired. I call these strings complex strings.

Complex strings contain curly brackets that surround one or more pipe symbols, which separates the possible options. As an example of what these strings will look:
```
SomeTextKey = narration start {option 1|option 2|option 3} narration end
```
For some of these in some languages, translating could be as easy as translating each word in a way that grammatically works in your language. Some complex strings do have options which cut words in half, and many of them will likely not work as-is for languages which have a different sentence structure than English does. If these are causing you troubles when translating, see [Complex Strings](#complex-strings) below.

If these methods of randomized narrations (specifically the complex strings) work for your language, then you're ready to work on your translation. Once you have a translation you'd like to test, continue to [Testing Your Translation](#testing-your-translation).

### Complex Strings
If complex strings are giving you trouble translating, either due to words being split apart or due to differing sentence structure in your language, they can be easily converted to a simple array of narrations to be translated. 

At their core, complex strings are a way to compress arrays of possible narrations (the first method of narration randomization) into a single string value. Many complex strings have options which add or exchange adjectives within a line of narration. Along with changing adjectives, many complex string options are there to interchange words, which ultimately have the same meaning. Without complex strings, these variations would be represented by an array containing many strings that are nearly identical.

If some complex strings can't be directly translated into your language, there are two options. You can either reformat them as you translate them, or convert them to an array of strings that can be directly translated. If you'd like to reformat them, continue reading below for an explanation of their syntax. If you'd prefer to just translate an array, skip to [Expanding Complex Strings](#expanding-complex-strings).

The syntax of complex strings is very simple, although nesting can make it difficult to read. A complex string contains at least one "option" section. An option section starts with a "{", ends with a "}", and contains at least one "|" (a vertical bar/pipe symbol) to separate each option that can be chosen. Each option can be as long as desired, or be empty, as well as contain nested option sections. Option sections can be nested to an arbitrary depth.

Below are some examples of complex strings and all possible outcomes they'd have.

Example 1: `start {option A|option B} end`

The most basic usage of complex strings.

Outcomes:
1) `start option A end`
2) `start option B end`

Example 2: `start {option 1 A|option 1 B|} middle {option 2 A|option 2 B|} end`

A more complex usage, showing two option sections as well as empty options within each section.

Take note that for each of the outcomes where an empty option is chosen (outcomes 3, 6, 7, 8, and 9), this example results in double spaces at those empty options. To avoid these double spaces, this example could be reformatted to `start {{option 1 A|option 1 B} |}middle {{option 2 A|option 2 B} |}end`. This reformatting incorporates one of the spaces into the non-empty options, and ultimately results in the same set of outcomes but without the double spaces. This structuring is used often within the framework, although many uses are along the lines of `start {adjective |}end`

Outcomes:
1) `start option 1 A middle option 2 A end`
2) `start option 1 A middle option 2 B end`
3) `start option 1 A middle  end`
4) `start option 1 B middle option 2 A end`
5) `start option 1 B middle option 2 B end`
6) `start option 1 B middle  end`
7) `start  middle option 2 A end`
8) `start  middle option 2 B end`
9) `start  middle  end`

Example 3: `start {option A|option B with {option 1|option 2}} end`

A usage of nested option sections, showing that each option can have further options within it.

Outcomes:
1) `start option A end`
2) `start option B with option 1 end`
3) `start option B with option 2 end`

Once you have a complex string you think will work, you can test it inside the "Ravager Controls" menu. See [Entering Ravager Controls](#entering-ravager-controls) for how to access the menu. Once you're in Ravager Controls, select the "Translations" category, paste your complex string into the "Unravel complex string" text box, and click "Unravel". After that, a popup dialog will show you all the possible outcomes of your complex string.

Be aware that the "Unravel complex string" text box does have a max length limit of 1000 characters. I don't expect this to cause any problems, but if your full string isn't pasting into the text box, save your complex string to a text key, see [Testing Your Translation](#testing-your-translation) for how to import your translation into the game, and paste the text key for your complex string into the "Unravel complex string" box instead.

#### Expanding Complex Strings
The framework contains a helper function for translators which returns all possible variations of a string. This will be very helpful if you'd like to avoid rewriting complex strings, as well as for testing your rewritten complex strings.

Start by following [Entering Ravager Controls](#entering-ravager-controls) and clicking the "Translations" category button. After that, paste the text key for the complex string you'd like to expand (or the complex string itself) into the "Unravel complex string" text box, and click Unravel. After that, a popup dialog will show you all possible outcomes of that text key/string.

If you entered the text key, the popup will include the text key in the output so that you can copy and paste the output directly into your translation file. If you entered the string itself, the popup will not include a text key, so the output will only be the value portion of the `textKey = value` format in your translation file.

The output of expanding a string will be in the darker box with pink text. Clicking on that box should highlight all text within it to allow you to easily copy it.

There is also the "Unravel All Keys" button which will expand all complex strings in the framework and let you save a file with all that text, ready to be translated. Please note that this button does not have a way to split the text keys into all the files they were originally part of and just dumps them all into a single file. Make sure to read the warning below if you're going to use this button.

Here's a bit of a warning though: Some complex strings result in very high numbers of possible variations. While there are only 4 text keys that expand to more than 100 possible variations, the largest text key in the framework, "MimicR5ButtSpicy", is an array of complex strings and expands to over 1700 total variations. For any text keys that have a lot of variations, you're welcome to trim them to a more manageable number of variations. You can pick out a handful of variations to translate or contact me (CTN) asking for a minimized set of variations to translate. If you want to ask for a minimized set of variations, you can ping me in the Ravager Framework thread in KD's Discord, DM me on Discord, or open an issue on the framework's GitHub. When I supply a minimized set of variations, it will likely be added as a comment in the English translation in case other translators would like to utilize it.

## Testing Your Translation
Once you have a translation (or part of one) ready to be tested, the sections below will guide you through testing your translation.

To start, make sure your game is set to the language you're translating into, then continue to [Entering Ravager Controls](#entering-ravager-controls).

### Entering Ravager Controls
All translation helper functions are made easily accessible within the "Translations" category of the Ravager Controls menu.

To access this menu after the mod is loaded, click three times on the ball gag in the Kinky Dungeon title. After that, whenever the "Tile Editor" button is visible on the title menu, there will be a pink "Ravager Controls" button in the bottom left of the title menu. Clicking that button will bring you to the Ravager Controls menu.

Now click on "Translations" on the left and continue to [Importing Your Translation](#importing-your-translation).

### Importing Your Translation
Clicking on the "Import Language File" button will open a file dialog for you to choose a text file that will be loaded as a translation for the language the game is currently set to.

The function loading the translation is very lenient and does almost no error checking. The only errors it is able to tell you about is if any arrays of strings are malformed, since those strings are passed into `JSON.parse()` and that does have error checking. Testing for formatting and complex string syntax errors will be done through manual testing below. The framework may get some proper error checking in translation loading in a future update though, and this line will be changed if/when it does.

Assuming the game doesn't crash and the browser console doesn't show an error from loading your translation, continue to [Testing Methods](#testing-methods).

### Testing Methods
There are three main ways to test your new translation:

1) Unraveling text keys and checking the result for mistakes
2) Calling the framework's GetText function and checking the results
3) Playing the game and seeing your translation in action

Unraveling text keys can be done either through the Ravager Controls menu or by calling `RFUnravelText("SomeTextKey")` in the browser console. Whichever method you choose, the result returned to you will be all possible variations of the provided text key in the language currently selected in the game.

You can also test the variations of text keys in the browser console by calling `RFGetText("SomeTextKey")`. This function is what the framework itself uses to get text and will return one possible variation of the provided text key in the language currently selected in the game.

Lastly, you can spend some time playing the game and seeing how your translation fits into the mod.

If you start testing and you're seeing English text instead of your translation, there are a few possibilities for why that is:

1) You simply didn't translate that text key
2) You mistyped that text key in your translation
3) You mistyped that text key in whatever method you're using to test

There are a handful of text keys that don't need to be translated since they're mostly not intended for players, notably many of the text keys that start with "RFC".

The way the framework finds the value for a text key is by first looking for the key in the game's currently selected language, then looking for it in the English text, and lastly, as a fallback, returning the text key with "[Not Found]: " at the beginning. 

If you mistyped the text key in your translation, you'll likely see the English text during testing. If you mistyped the text key during testing, you'll likely see the "[Not Found]" fallback during testing.

More thorough testing methods that check for syntax and consistency are in the works, but they're taking some time.

Once you've done your testing and you're ready to submit your translation, pick a method from [Submitting a Translation](#submitting-a-translation) and submit your translation.

## Further Questions
Got any questions not answered or not explained clear enough in this file? Feel free to contact me with your questions. I will further explain whatever you need and use it to improve this documentation. 
