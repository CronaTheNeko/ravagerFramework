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

V6.0.2
- Updated function names for KD5.4.25

v6.0.3
- Added outfits for the Bandit, Wolfgirl, and Slimegirl Ravagers
- Modified 'RavagerOccupiedMouth' to use the Invisible Gag model (mouth open without gag)
- Modified 'RavagerOccupiedVulva' to use a blank model which lifts the skirt like crotch rope
- Added debug logging option
- Fixed RavagerTendril's crash from having no dialogue if the mod settings have never been loaded before

v6.0.4
- Added Mod Configuration option for the Slimegirl's chance to add a slime restraint to the player
- Added more text keys to the Slimegirl
- Fixed delayed appearance of Ravager's hairpin
- Fixed Slimegirl's ability to bypass Liquid Metal restraints
- Removed 'jail' and 'jailer' tags from Bandit Ravager and Wolfgirl Alpha to prevent them from dragging the player to jail mid-ravaging
	+ This is a dirty fix for that behavior and will hopefully be temporary
- Increased evasion penalty while pinned
- Fixed ravagers fallback narration never being used (the narration that is supposed to happen between ravaging sessions)
- Reduced the toughness of struggling from a pin
	+ For details, a struggle attempt requires about 30 usable stamina and struggling free should take about 5 struggle attempts
- Non-ravager enemies will now stop and watch you while ravagers have their way
- Added custom bound sprite for Bandit and Wolfgirl ravagers
- Added on-hit and orgasm sound effects with associated config options
- Yet Another Text Key For The SlimeRavager™
- Ravager development:
	+ Added `ravagerDevelopers.md` to document all framework-specific options available
	+ Added globally accessible helper function to add callbacks for custom ravager development
	+ Added default fallback narration for ravagers, as well as a property that can be set if no narration is the desired behavior
