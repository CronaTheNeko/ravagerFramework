Planned features may or may not adhere to a planned version. Ideas are not firm in their details and may not necessarily be implemented.

## Implemented
- Instead of only grope damage during fallback, sometimes add restraints to player -- Implimented, but only uses jail restraints; will try to add custom restraints soon™
- Implement the plant ravager and probably other ravagers, using Bogus' ideas as a base
	- See [MSG](https://discord.com/channels/938203644023685181/1183991709768622090/1184331756783030372)
	- Plant done in v006
- 'Occupied' restraints apply skirt lift (like crotch rope) / mouth open (like invis gag)
	- [Post](https://discord.com/channels/938203644023685181/1183991709768622090/1298403509338640450)
	- Implemented: v6.0.3
- Enemy portraits
	- [Post](https://discord.com/channels/938203644023685181/1183991709768622090/1297212342714499074)
	- Implemented: v6.0.3

## Planned features
- Jail guard ravager that takes the player to a torture dungeon? -- First implementation will likely just be the ravager as a guard to use the player; might integrate into the custom floor
	- Base off sprite for Guard/GuardHeavy?
	- In progress: enemy tuning, model work
- Figure out a good way to change what restraints are added to player during fallback (such as making the slime girl apply slime restraints)
- Option to strip all clothes, but not restraints; almost have this, just split `{enemy}.ravage.bypassAll` into two additional settings: `bypassRestraints` and `bypassClothes`
	- [Post](https://discord.com/channels/938203644023685181/1183991709768622090/1296897530277134387)
- 'Private Time' status to repel non-ravagers while being ravaged; planned, but haven't figured out how to do so yet
	- [Post](https://discord.com/channels/938203644023685181/1183991709768622090/1296897530277134387)
	- In progress: Ruling out methods that don't work
- Make sure 'Have fun with me' flirting option triggers ravaging correctly; unsure if this currently works
	- [Post](https://discord.com/channels/938203644023685181/1183991709768622090/1296897530277134387)
- Custom 'ravager-filled' floor to potentially be dragged to instead of passing out; maybe take the method of the SarcoKraken's engulf spell, which allows for some custom narration to happen along the lines of "Let's get you home to your new family~" and allowing the player to attempt an escape
	- [Post](https://discord.com/channels/938203644023685181/1183991709768622090/1295941022076899341)
	- Flirting option to be 'taken home' / jailed to a custom map (another suggestion) where only/mostly ravagers spawn
		- [Post](https://discord.com/channels/938203644023685181/1183991709768622090/1296897632354172968)
	- Trap rooms in the custom map that would trap the player in the room with a ravager
		- [Post](https://discord.com/channels/938203644023685181/1183991709768622090/1296898496229544111)
- Drag player to a bed / other furniture trap if available instead of passing out
	- [Post](https://discord.com/channels/938203644023685181/1183991709768622090/1296203259924578405)
- Ravager visits in jail; might be intended already for bandit, but haven't tested; make sure it works and add other non-immobile ravagers
	- [Post](https://discord.com/channels/938203644023685181/1183991709768622090/1295866151695548457)
- Add sound effects to ravaging - use `Object.values(KDAllModFiles).map((mod) => mod.filename).includes('GirlSound.ks')` to check if the current Sound Effect mod is loaded in order to avoid playing multiple sound effects (also check for 'girlsound.ks' to check for death_comsos' old sound effect mod)
	- [Post](https://discord.com/channels/938203644023685181/1183991709768622090/1329505099705487411)
- Tentacle Pit rare interaction to engulf the player, then continue spawning ravager tendrils to continuously ravage the player until either escape or pass out
	- Note: Like my unreleased tentacle ravager
	- Note: Either manually adding the item (instead of TentacleKraken's engulf spell) in order to keep spawning RavagerTendrils, or use the engulf spell and leave the player with a limited number of tendrils to deal with
	- Note: Might feel odd unless passout mechanic is reworked
	- Note: Highly reacted suggestion
	- [Post](https://discord.com/channels/938203644023685181/1183991709768622090/1295060266181984256)

- Check for cross-mod incompat; See known issues;
	- [Post](https://discord.com/channels/938203644023685181/1183991709768622090/1296759755611574303)
	- [Mod list](https://discord.com/channels/938203644023685181/1183991709768622090/1296803426390380564)
- Ravagers using player while keeping them in furniture restraint
	- [Post](https://discord.com/channels/938203644023685181/1183991709768622090/1343741161277489184)

## Ideas
- I like the ideas presented [here](https://discord.com/channels/938203644023685181/1183991709768622090/1187386814718279720)
	- Whenever the Ravager gets a hold on you, it's kinda difficult to free yourself or do anything. Maybe in future versions this can get tweaked accordingly so even with a full stamina bar and no restraints it's not impossible.
		+ Note: Should be easy to do, just need to do some testing
	- Other enemies are able to put restraints on you while you're getting ravaged which I'm not sure how to feel there. On one hand it'd make the ravager scarier to come across but at the same time once they grab you it's kinda over for you, so again it's a tad unfair.
		+ Note: Ties into the 'preventing non-ravagers intervening' plan
	- If you're able to give the ravagers more actions, I think it would be interesting as it'd make each one that much more unique outside of "occupying" the player and maybe applying restraints. I'm sure there might be actions/attacks that'd fit each potential ravager, and perhaps one or two of these attacks could be what leads to them "occupying" the player.~
	- Speaking of restraints, maybe once you get the enemies all sorted out you could try restraints exclusive to them? I'm thinking something that'd let them "occupy" the player easier like ring-gags, plug-gags (with the function that'd let them or yourself unplug your mouth), hoods, revealing catsuits/outfits for "easier access", etc.~
- Bast ravager that turns the player into a catgirl?
- Modifier perks; increase ravager stats, more common ravagers, guarantee restraint after use (maybe only one guaranteed)
	+ Additional thought: "Cruel Ravagers" perk -> ravagers reapply any restraints they had removed after they're done and (either guarantee or increase chance of) add an additional restraint
	- [Post](https://discord.com/channels/938203644023685181/1183991709768622090/1296897530277134387)
- Lower dodge while pinned - Just need to readjust variables that already exist (RavagerNoDodge) (Setting to 1000 penalty resulted in ~20% chance with ~-9900 evasion and ~-100000% penalty)
	+ Note: Just needs testing for a good value
	- [Post](https://discord.com/channels/938203644023685181/1183991709768622090/1296897530277134387)
- (Mouth?) occupation puts character in kneeling pose - None of the in-game poses work well for this idea - either one of the in-game poses will work, or this probably won't happen
	+ Note: There are kneeling poses that could work for this, but I'm hesitant as that'd lead to some odd rationale for how another ravager is using another slot while in that pose
	- [Post](https://discord.com/channels/938203644023685181/1183991709768622090/1297205431113875526)
- Modifier perk to increase restrain chance of ravagers; exclusive with guaranteed perk above?
	+ If doing separate perks, "Cruel Ravagers" should also be separate and exclusive; so one to increase the chance, one to guarantee a restraint, and one to return your previous restraints and (possibly) add another; under that, maybe "Cruel Ravagers" can be the guarantee add, and the harder one be something like "Heartless Ravagers"
	- [Post](https://discord.com/channels/938203644023685181/1183991709768622090/1295851910351552532)
- In-wall leashing 'cyber tentacles'/wall of tentacles ravager
	- [Post](https://discord.com/channels/938203644023685181/1183991709768622090/1308582085027561605)
- Above, but in furniture
	- [Post](https://discord.com/channels/938203644023685181/1183991709768622090/1308583283507859559)
- Void Patrol Ravager that summons tendrils/something to ravage your while hypnotizing you -- Edge of reality
	- Note: A lot of 'Observers' enemies in the edge of reality; we'll need the 'deter non-ravagers' and 'prevent leash pulling during ravage' plans to work out before properly implementing this one
	- Note to self: Ghost possession apparently can get the hypnosis effect done; see about manually triggering the related to code?
	- [Post](https://discord.com/channels/938203644023685181/1183991709768622090/1310026935258185759)
- 'Harem Demon' to summon lesser demons as ravagers to only grope you. Once weakened/'captured', 'harem lord' comes to take advantage
	+ Interesting: Setting an enemy's `ravage.rafractory` to -1 will lead to a single 'ravaging' and the nothing but fallback attacks from then on -- Framework never checks if `enemy.ravagerRefractory` is less than 0; only if it is falsy (falsy=0, means the ravager can ravage) or if it is greater than 0 (only used to decrement refractory each turn); a negative number is truthy but also less than 0, so refractory gets set after the first ravaging and will never change again
	- [Post](https://discord.com/channels/938203644023685181/1183991709768622090/1310026935258185759)
- Mimics that use the player for some amount of time/until a condition
	- [Post](https://discord.com/channels/938203644023685181/1183991709768622090/1310389721649909813)
- Ruined makeup after being ravaged would need a model as some sort of makeup that can't be hidden by blindfolds that cover a smaller area than the makeup
	- [Post](https://discord.com/channels/938203644023685181/1183991709768622090/1316222771453235221)
- "Borrow" some plans from "PLANS AND DETAILS.txt"
