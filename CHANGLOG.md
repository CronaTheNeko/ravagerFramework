V001
	- Initial release by hogus bogus
V002
	- Added the ability for a ravager to "pass through" restraints
	- Attempted to add callback functions available to ravagers, but the way it was implimented was non-functional
V002 Unofficial Skirt Fix
	- Introduction of CTN
	- Removed skirts from ravager's clothes to attempt to remove, as it was causing ravagers to be unable to "occupy" anything but the player's head
V003
	- Sort of, kind of officially taken over by CTN
	- Expanded the pass-through-restraints ability to include passing through clothes
	- Temporarily removed the unfinished Plant Ravager from being added to the game, as it is currently just a copy and paste of the Slime Ravager, causing the game to have two entries for "SlimeRavager"
V004
	- Added a chance for a ravager to add restraints to the player as a fallback action instead of just dealing grope damage
		- Chance to do so for the three current ravagers is 5%. If you have feedback on if this percentage should adjusted, please bring it up in the mod's thread
		- Note: Currently the only restraints applied are default jail restraints. I am working on figuring out a good way to use a different list of restraints.
	- Fixed the callback functions added in V002. The original declaration method was a decent idea, but was incompatible with how the game handles enemies
		- See "Callback Functions Explanation.txt" for explanation on how to use them
	- Added a new callback that happens every time a ravager takes a 'ravaging' action on the player
		- See effectCallback in "Callback Functions Explanation.txt" for more info
	- Renamed the mod's ZIP file to ensure it gets loaded early in the mod order.
		- This is needed due to how the callback functions now work, and any extra ravager mods MUST be loaded AFTER the Framework
		- This can be ensured by naming the mod something like "10-someRavager.zip"
	- Better documented how to create a custom ravager in Enemies/exampleEnemy.js for anyone looking to create their own ravagers
	- Cleaned up the Framework's code and added/cleaned up comments anywhere I could understand what the code was doing. There will be further work here, but it is inconsequential to any normal users of the mod.
	- Added CHANGELOG.txt, README.txt, "Callback Functions Explanation.txt", and "CTN Future Plans.txt"
	- Began releasing 'core' version of mod as well, which only contains the framework, no ravagers included
	- Realized bogus tried to make the Slime Ravager add slime to the player while using them as a callback function. I'll have to fix the implimentation (same with Wolfgirl Ravager)
V005
	- Added mod settings for disabling any ravager you wish to not experience. This functionality is available as of 5.3.38
	- Added Mod Info file to provide game with mod info and ensure load priority. This functionality is available as of 5.3.38
	- Fixed issues causing mod to be detected as malware on some systems
V006
	- Added the new Tentacle Pit enemy and accompanying Ravager Tendrils
	- Small handful of fixes
V6.0.1
	- Fixed missing text keys for Slimegirl
	- Change to semantic versioning
