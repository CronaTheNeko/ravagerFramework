# Ravager Framework
Some of the dungeon's residents find you quite attractive, and they want a slice of the pie, *whether you're willing or not.*

## What's a ravager?
Simply put, an enemy that can strip, pin, and "use" the player.

Ravagers can have a wide variety of behaviors outside of that basic layout though. They can also do anything a normal enemy could do. Some of the current ravagers will add restraints, some can drag you to jail, and some can call on backup for *handling* you.

## Where do I find ravagers?
All throughout the game! Each is part of a faction, so they'll be found alongside their friends on the various floors of the dungeon.

## Features for players
- 5 unique ravagers currently implemented<details><summary>Spoilers</summary>
  + The Bandit Ravager, the most straightforward, she's just here for a good time
  + The Wolfgirl Alpha, uses her faction's tech to *convince* you to submit to her
  + The Slimegirl, might just cover you in slime by the time she's done
  + The Tentacle Pit, a *friend* of the Dryads, craving a new taste, pulls you into a squishy bed of tendrils ready to take their turn with you
  + The Mimic Ravager, a strage mass of tentacles making its home in the chests of the dungeon, awaiting their next prey
</details>

- Configuration allows disabling any ravager and customizing some of their details

## For developers
This mod acts as a framework (hence the name) for adding your own ravagers.

The minimum to turn an enemy into a ravager is that it uses the "Ravage" effect and has a `ravage` section in its declaration with the required structure.

Further details and examples can be found in [ravagerDevelopers.md](ravagerDevelopers.md) and [exampleEnemy.ks](Enemies/exampleEnemy.ks).

## Issues and suggestions
For any new bug reports and suggestions, feel free to create an issue on this repo.

If you have additional details to add to an bug report, or an opinion to express on a suggestion, all are welcome.


## Current plans and ideas
While I am working on moving the suggested features to the issue tracker, all suggestions that I have kept track of and come up with can be found in [CTN Ideas and Plans.md](CTN%20Ideas%20and%20Plans.md)
