/**********************************************
 * Enemy definition: BANDIT RAVAGER
	Bandit, that...
	- Has a DashStun special to close gaps. Stun makes them really dangerous, since they can quickly strip and immobilize a target.
	- Has a special attack that applies the ravage "effect"
*/

KDModelDresses['BanditRavager'] = [{"Item":"FashionBlindfoldTape","Group":"Blindfold","TopLevel":true,"Restraint":false,"Categories":["Restraints","Blindfolds","FashionRestraints"],"AddPose":["Blindfolds"],"Layers":{"Tape":{"Name":"Tape","Layer":"Blindfold","Pri":-1,"OffsetX":942,"OffsetY":200,"Invariant":true,"HideWhenOverridden":true,"InheritColor":"Tape"}},"Parent":"Fashionundefined","Filters":{"Tape":{"gamma":1,"saturation":0,"contrast":1.0999999999999999,"brightness":1,"red":0.43137254901960786,"green":0.21568627450980393,"blue":0,"alpha":1}},"Properties":{"Tape":{"Rotation":42,"XOffset":870,"YOffset":-470,"YScale":0.9,"XScale":0.8}}},{"Item":"Bandit","Group":"Bandit","TopLevel":true,"Categories":["Uniforms"],"Layers":{"Shorts":{"Name":"Shorts","Layer":"Shorts","Pri":7,"Poses":{"Spread":true,"Closed":true,"Kneel":true,"KneelClosed":true,"Hogtie":true},"HidePrefixPose":["Encase"],"HidePrefixPoseSuffix":["TorsoLower"]},"ShortsLeft":{"Name":"ShortsLeft","Layer":"ShortsLeft","Pri":7,"Poses":{"Spread":true,"Closed":true,"Kneel":true,"KneelClosed":true,"Hogtie":true},"HidePrefixPose":["Encase"],"HidePrefixPoseSuffix":["TorsoLower"]},"Breastplate":{"Name":"Breastplate","Layer":"Chestplate","Pri":24,"Poses":{"Free":true,"Boxtie":true,"Wristtie":true,"Yoked":true,"Front":true,"Up":true,"Crossed":true,"Hogtie":true},"HideWhenOverridden":true,"MorphPoses":{"Hogtie":"Hogtie"},"Invariant":true},"WristLeft":{"Name":"WristLeft","Layer":"WristLeft","Pri":7,"Poses":{"Free":true,"Yoked":true,"Front":true}},"WristRight":{"Name":"WristRight","Layer":"WristRight","Pri":7,"Poses":{"Free":true,"Yoked":true,"Front":true,"Crossed":true}},"Pouch":{"Name":"Pouch","Layer":"PantsAccRight","Pri":14,"Poses":{"Spread":true,"Closed":true,"Kneel":true,"KneelClosed":true,"Hogtie":true}},"Knee":{"Name":"Knee","Layer":"KneeAccLeft","Pri":15,"Poses":{"Spread":true,"Closed":true,"Kneel":true,"KneelClosed":true,"Hogtie":true},"HideWhenOverridden":true},"Choker":{"Name":"Choker","Layer":"Collar","Pri":3,"Invariant":true,"HideWhenOverridden":true},"ShoeLeft":{"Name":"ShoeLeft","Layer":"ShoeLeft","Pri":1,"Poses":{"Spread":true,"Closed":true,"Kneel":true,"KneelClosed":true},"GlobalDefaultOverride":{"KneelClosed":true},"NoDisplace":true,"HideWhenOverridden":true,"DisplacementSprite":"BootsShort","DisplaceAmount":30,"DisplaceLayers":{"Boots":true},"DisplaceZBonus":100},"ShoeRight":{"Name":"ShoeRight","Layer":"ShoeRight","Pri":1,"Poses":{"Spread":true,"Closed":true},"NoDisplace":true,"HideWhenOverridden":true},"ShoeRightKneel":{"Name":"ShoeRightKneel","Layer":"ShoeRightKneel","Pri":1,"Poses":{"Kneel":true},"Invariant":true,"NoDisplace":true,"InheritColor":"ShoeRight","HideWhenOverridden":true},"ShoeLeftHogtie":{"Name":"ShoeLeftHogtie","Layer":"ShoeLeftHogtie","Pri":1,"Poses":{"Hogtie":true},"Invariant":true,"NoDisplace":true,"InheritColor":"ShoeLeft","HideWhenOverridden":true}}}]

KDModelHair['BanditRavager'] = [{"Item":"RavLargeHeartHairpin","Group":"Hair","Parent":"HeartHairPins","Protected":true,"Categories":["Hairstyles","Accessories"],"Layers":{"LargeHeartHairpin":{"Name":"LargeHeartHairpin","Layer":"HairFront","Pri":20}},"Filters":{"LargeHeartHairpin":{"gamma":1,"saturation":0,"contrast":1,"brightness":1,"red":0.9607843137254902,"green":0,"blue":2,"alpha":1}},"Properties":{"LargeHeartHairpin":{"XScale":1.8,"YScale":1.8,"YOffset":-300,"XOffset":-1000}}},	{"Item":"Curly","Group":"Hair","TopLevel":true,"Protected":true,"Categories":["Hairstyles","FrontHair"],"AddPose":["Hair"],"Layers":{"Curly":{"Name":"Curly","Layer":"Hair","Pri":0,"SwapLayerPose":{"HoodMask":"HairOver"}},"Curly_Overstrap":{"Name":"Curly_Overstrap","Layer":"HairFront","Pri":0,"InheritColor":"Curly"}},"Filters":{"Curly":{"gamma":1,"saturation":0,"contrast":1,"brightness":1,"red":1.1764705882352942,"green":0.3333333333333333,"blue":0,"alpha":1}}},{"Item":"ShortCurlyBack","Group":"Hair","Parent":"Curly","TopLevel":true,"Protected":true,"Categories":["Hairstyles","BackHair"],"Layers":{"BackShortCurly":{"Name":"BackShortCurly","Layer":"HairBack","Pri":0},"BackShortCurlyUnderlight":{"Name":"BackShortCurlyUnderlight","Layer":"HairBack","Pri":-0.1,"NoOverride":true,"TieToLayer":"BackShortCurly"}},"Filters":{"BackShortCurly":{"gamma":1,"saturation":0,"contrast":1,"brightness":1,"red":1.1764705882352942,"green":0.3333333333333333,"blue":0,"alpha":1},"BackShortCurlyUnderlight":{"gamma":1,"saturation":0,"contrast":1,"brightness":1,"red":1.1764705882352942,"green":0.3333333333333333,"blue":0,"alpha":1}}},{"Item":"FluffyPonytail","Group":"Hair","Parent":"Ponytail","TopLevel":true,"Protected":true,"Categories":["Hairstyles","BackHair"],"Layers":{"Ponytail2":{"Name":"Ponytail2","Layer":"HairBack","Pri":0}},"Filters":{"Ponytail2":{"gamma":1,"saturation":0,"contrast":1,"brightness":1,"red":0.7254901960784313,"green":0.19607843137254902,"blue":0,"alpha":1}},"Properties":{"Ponytail2":{"Rotation":-11,"YOffset":500,"XOffset":100,"LayerBonus":-1}}}]

KDModelBody['BanditRavager'] = [{"Item":"Body","Group":"Body","TopLevel":true,"Protected":true,"Categories":["Body"],"Folder":"Body","AddPose":["Body"],"Layers":{"Head":{"Name":"Head","Layer":"Head","Pri":0,"MorphPoses":{"AnimalEars":"NoEar","HideEars":"NoEar"},"AppendPose":{"FaceCoverGag":"","FaceBigGag":"BigGag","FaceGag":"Gag"}},"ArmRight":{"Name":"ArmRight","Layer":"ArmRight","Pri":0,"HideWhenOverridden":true,"InheritColor":"Torso","Poses":{"Free":true,"Boxtie":true,"Wristtie":true,"Yoked":true,"Front":true,"Up":true,"Crossed":true},"GlobalDefaultOverride":{"Front":true,"Crossed":true}},"ArmLeft":{"Name":"ArmLeft","Layer":"ArmLeft","Pri":0,"HideWhenOverridden":true,"InheritColor":"Torso","Poses":{"Free":true,"Boxtie":true,"Wristtie":true,"Yoked":true,"Front":true,"Up":true,"Crossed":true},"GlobalDefaultOverride":{"Front":true,"Crossed":true},"ErasePoses":["HideHands"],"EraseLayers":{"RightHand":true},"EraseSprite":"HideBoxtieHand","EraseInvariant":true},"ShoulderRight":{"Name":"ShoulderRight","Layer":"ShoulderRight","Pri":0,"HideWhenOverridden":true,"InheritColor":"Torso","Poses":{"Up":true}},"ShoulderLeft":{"Name":"ShoulderLeft","Layer":"ShoulderLeft","Pri":0,"HideWhenOverridden":true,"InheritColor":"Torso","Poses":{"Up":true}},"ForeArmRight":{"Name":"ForeArmRight","Layer":"ForeArmRight","Pri":0,"HideWhenOverridden":true,"InheritColor":"Torso","Poses":{"Front":true,"Crossed":true},"GlobalDefaultOverride":{"Front":true,"Crossed":true},"SwapLayerPose":{"Crossed":"CrossArmRight"}},"ForeArmLeft":{"Name":"ForeArmLeft","Layer":"ForeArmLeft","Pri":0,"HideWhenOverridden":true,"InheritColor":"Torso","Poses":{"Front":true,"Crossed":true},"GlobalDefaultOverride":{"Front":true,"Crossed":true},"SwapLayerPose":{"Crossed":"CrossArmLeft"}},"HandRight":{"Name":"HandRight","Layer":"HandRight","Pri":0,"HideWhenOverridden":true,"InheritColor":"Torso","Poses":{"Free":true,"Boxtie":true,"Yoked":true},"GlobalDefaultOverride":{"Front":true},"HidePoses":{"HideHands":true,"EncaseHandRight":true}},"HandLeft":{"Name":"HandLeft","Layer":"HandLeft","Pri":0,"HideWhenOverridden":true,"InheritColor":"Torso","Poses":{"Free":true,"Yoked":true},"GlobalDefaultOverride":{"Front":true},"HidePoses":{"HideHands":true,"EncaseHandLeft":true}},"ForeHandRight":{"Name":"ForeHandRight","Layer":"ForeHandRight","Pri":0,"HideWhenOverridden":true,"Sprite":"HandRight","InheritColor":"Torso","Poses":{"Front":true},"GlobalDefaultOverride":{"Front":true},"HidePoses":{"HideHands":true,"EncaseHandRight":true}},"ForeHandLeft":{"Name":"ForeHandLeft","Layer":"ForeHandLeft","Pri":0,"HideWhenOverridden":true,"Sprite":"HandLeft","InheritColor":"Torso","Poses":{"Front":true},"GlobalDefaultOverride":{"Front":true},"HidePoses":{"HideHands":true,"EncaseHandLeft":true}},"LegLeft":{"Name":"LegLeft","Layer":"LegLeft","Pri":0,"HideWhenOverridden":true,"InheritColor":"Torso","Poses":{"Spread":true,"Closed":true,"Kneel":true,"KneelClosed":true,"Hogtie":true},"GlobalDefaultOverride":{"Hogtie":true,"KneelClosed":true}},"Torso":{"Name":"Torso","Layer":"Torso","Pri":0,"InheritColor":"Torso","MorphPoses":{"Closed":"Closed","Spread":"Spread","Hogtie":"Closed"},"EraseLayers":{"BustierPoses":true},"EraseSprite":"EraseCorset","EraseInvariant":true,"EraseZBonus":1000},"Chest":{"Name":"Chest","Layer":"Chest","Pri":0,"HideWhenOverridden":true,"InheritColor":"Torso"},"FootRightKneel":{"Name":"FootRightKneel","Sprite":"FootRight","Layer":"FootRightKneel","Pri":0,"HideWhenOverridden":true,"InheritColor":"Torso","HidePoses":{"FeetLinked":true,"FeetCovered":true},"Poses":{"Kneel":true}},"FootLeftHogtie":{"Name":"FootLeftHogtie","Layer":"FootLeftHogtie","Pri":0,"HideWhenOverridden":true,"InheritColor":"Torso","Poses":{"Hogtie":true},"MorphPoses":{"Hogtie":""}},"LegRight":{"Name":"LegRight","Layer":"LegRight","Pri":0,"HideWhenOverridden":true,"InheritColor":"Torso","Poses":{"Spread":true,"Closed":true,"Kneel":true,"KneelClosed":true,"Hogtie":true},"GlobalDefaultOverride":{"Hogtie":true,"KneelClosed":true}},"Butt":{"Name":"Butt","Layer":"Butt","Pri":0,"InheritColor":"Torso","Poses":{"Kneel":true,"KneelClosed":true},"EraseLayers":{"BustierPoses2":true},"EraseSprite":"EraseCorsetKneel","EraseInvariant":true,"EraseZBonus":1000},"Butt2":{"Name":"Butt2","Layer":"Butt","Pri":0,"InheritColor":"Torso","Poses":{"Kneel":true,"KneelClosed":true},"EraseLayers":{"ButtSleeves":true},"EraseSprite":"ButtSleeves","EraseZBonus":1000,"EraseInvariant":true,"Invariant":true},"Nipples":{"Name":"Nipples","Layer":"Nipples","Pri":0,"HideWhenOverridden":true,"InheritColor":"Nipples","Invariant":true,"HidePoses":{"HideNipples":true}}},"Filters":{"HeadAnimalEars":{"gamma":1,"saturation":0,"contrast":1,"brightness":1,"red":0.4117647058823529,"green":1.588235294117647,"blue":1.3529411764705883,"alpha":1},"Head":{"gamma":1,"saturation":0,"contrast":1.76,"brightness":1,"red":0.7450980392156863,"green":0.5490196078431373,"blue":0.49019607843137253,"alpha":1},"Torso":{"gamma":1,"saturation":0,"contrast":1.76,"brightness":1,"red":0.7450980392156863,"green":0.5490196078431373,"blue":0.49019607843137253,"alpha":1}}}]

KDModelFace['BanditRavager'] = [{"Item":"HumanEyes","Group":"FaceKoi","TopLevel":true,"Protected":true,"Categories":["Eyes","Face"],"AddPose":["Eyes"],"Layers":{"Eyes":{"Name":"Eyes","Layer":"Eyes","Pri":0,"Sprite":"Human","OffsetX":942,"OffsetY":200,"Poses":{"EyesNeutral":true,"EyesSurprised":true,"EyesDazed":true,"EyesClosed":true,"EyesAngry":true,"EyesSly":true,"EyesHeart":true}},"Eyes2":{"Name":"Eyes2","Layer":"Eyes","Pri":0,"Sprite":"Human","OffsetX":942,"OffsetY":200,"Poses":{"Eyes2Neutral":true,"Eyes2Surprised":true,"Eyes2Dazed":true,"Eyes2Closed":true,"Eyes2Angry":true,"Eyes2Sly":true,"Eyes2Heart":true}},"Whites":{"Name":"Whites","Layer":"Eyes","Pri":-1,"OffsetX":942,"OffsetY":200,"NoColorize":true,"Poses":{"EyesNeutral":true,"EyesSurprised":true,"EyesDazed":true,"EyesClosed":true,"EyesAngry":true,"EyesSly":true,"EyesHeart":true}},"Whites2":{"Name":"Whites2","Layer":"Eyes","Pri":-1,"Sprite":"Whites","OffsetX":942,"OffsetY":200,"NoColorize":true,"Poses":{"Eyes2Neutral":true,"Eyes2Surprised":true,"Eyes2Dazed":true,"Eyes2Closed":true,"Eyes2Angry":true,"Eyes2Sly":true,"Eyes2Heart":true}}},"Filters":{"Eyes":{"gamma":0.5333333333333333,"saturation":0.016666666666666666,"contrast":1,"brightness":1.1166666666666667,"red":1.6166666666666665,"green":0.8333333333333333,"blue":0.7166666666666667,"alpha":1},"Eyes2":{"gamma":0.5333333333333333,"saturation":0.016666666666666666,"contrast":1,"brightness":1.1166666666666667,"red":1.6166666666666665,"green":0.8333333333333333,"blue":0.7166666666666667,"alpha":1}}},{"Item":"KoiBlush","Group":"FaceKoi","TopLevel":true,"Protected":true,"Categories":["Face"],"Layers":{"Blush":{"Name":"Blush","Layer":"Blush","Pri":0,"Sprite":"","OffsetX":942,"OffsetY":200,"Poses":{"BlushLow":true,"BlushMedium":true,"BlushHigh":true,"BlushExtreme":true}}}},{"Item":"KjusMouth","Group":"FaceKjus","TopLevel":true,"Protected":true,"Group":"Mouth","Categories":["Mouth","Face"],"Layers":{"Mouth":{"Name":"Mouth","Layer":"Mouth","Pri":0,"Sprite":"","Poses":{"MouthNeutral":true,"MouthDazed":true,"MouthDistracted":true,"MouthEmbarrassed":true,"MouthFrown":true,"MouthSmile":true,"MouthSurprised":true,"MouthPout":true},"HidePoses":{"HideMouth":true}}}},{"Item":"KoiBrows","Group":"FaceKoi","TopLevel":true,"Protected":true,"Categories":["Eyes","Face"],"Layers":{"Brows":{"Name":"Brows","Layer":"Brows","Pri":0,"Sprite":"","OffsetX":942,"OffsetY":200,"Poses":{"BrowsNeutral":true,"BrowsAngry":true,"BrowsAnnoyed":true,"BrowsSad":true,"BrowsSurprised":true},"HidePoses":{"EncaseHead":true}},"Brows2":{"Name":"Brows2","Layer":"Brows","Pri":0,"Sprite":"","OffsetX":942,"OffsetY":200,"Poses":{"Brows2Neutral":true,"Brows2Angry":true,"Brows2Annoyed":true,"Brows2Sad":true,"Brows2Surprised":true},"HidePoses":{"EncaseHead":true}}}}]

KDModelStyles['BanditRavager'] = {
	Hairstyle: [ 'BanditRavager' ],
	Bodystyle: [ 'BanditRavager' ],
	Facestyle: [ 'BanditRavager' ],
}

let banditRavager = {
	style: 'BanditRavager', // Body style
	outfit: 'BanditRavager', // Outfit style
	// Key to signal we added this so we can make sure we don't remove an enemy with the same name added by someone else (such as someone else making a mod to modify the bandit ravager)
	// If you're making your own ravager, change this key or just remove it
	addedByMod: 'RavagerFramework',
	// id data
	name: "BanditRavager", 
	faction: "Bandit", 
	clusterWith: "bandit", 
	playLine: "Bandit", 
	bound: "BanditRavager", 
	color: "#ddcaaa",
	tags: KDMapInit([ 
		//DO NOT add leashing or else they'll pull the player to jail and break everything
		//otherwise, unless marked, the tags are up to your intention for the enemy
		"opendoors", 
		"closedoors", 
		"bandit", 
		// "imprisonable", 
		"melee",
		// "miniboss",
		"cacheguard", 
		"unflinching", // makes enemy unable to be pulled/pushed. maybe don't remove this
		"chainRestraints", 
		"nosub", //probably don't want to remove this one
		"handcuffer",
		"clothRestraints", 
		"chainweakness", 
		"glueweakness", 
		// "jail", // Needed to remove in order for ravager to stop pulling the player mid-ravage
		// "jailer", // Needed to remove in order for ravager to stop pulling the player mid-ravage
		"hunter",
		// "human" // An attempt to fix the "Play with her" dialog, but still resulted in the ravager not acting after selecting the dialog
	]),

	// AI
	ignorechance: 0, 
	followRange: 1, 
	AI: "hunt",

	// core stats
	armor: 1.5, 
	maxhp: 12, 
	minLevel: 1, //notably this affects the earliest floor they can spawn on
	weight: 6,
	visionRadius: 7, 
	movePoints: 3,
	 
	// main attack
	// P.S. - this enemy uses "Effect" melee, but you could also create a spell that has the PlayerEffect of Ravage if it fits more.
	dmgType: "grope",
	attack: "MeleeEffectBlind", // "MeleeEffect" is the only necessary part
	attackLock: "White",
	power: 2, //i don't think this actually does anything with this enemy's setup - on theory, affects how strong their hits are -- This being 20, plus the imprisonable tag, allowed the bandit rav to be found in Fuuka's prison and recruited as a overly powerful ally
	attackPoints: 2, //set this to 0 for it to happen instantly on contact, no telegraph
	attackWidth: 2, 
	attackRange: 2.5, 
	fullBoundBonus: 0,
	disarm: 0.2,
	hitsfx: "Grab",

	// spawning/drops, i made this enemy drop a bunch of cash as reward
	terrainTags: {"secondhalf":10, "thirdhalf":1}, 
	shrines: ["Leather", "Metal"], 
	floors:KDMapInit(["jng", "cry", "tmp"]),
	dropTable: [{name: "Gold", amountMin: 50, amountMax: 100, weight: 10}],

	// special dash move, nothing too special about this
	specialAttack: "DashStun", 
	stunTime: 4,
	specialCD: 5, 
	specialCDonAttack: true, 
	specialAttackPoints: 2, 
	specialRange: 4,
	specialMinRange: 1.5,
	specialsfx: "Miss",
	specialWidth: 2, 
	specialRemove: "Effect", // don't want them also immediately pinning - unfair!!

	/*
		Ravage setup, also any other vanilla properties that are useful or required for ravagers
	*/
	ravage: { // custom ravage settings
		targets: ["ItemVulva", "ItemMouth", "ItemButt"], // enemy will only pick what's listed here. these three are the only valid slots right now
			// NOTE - butt will only be chosen if "Rear Plugs" from aroused mode is active.
		refractory: 50, // amount of turns to fall back to default attack behavior
		needsEyes: false, // this is assumed to be false by default, but if true, will remove blindfolds when going for mouth. (for hypno purposes obviously)
		
		onomatopoeia: ["CLAP...", "PLAP..."], //floats overhead like stat changes (can be unspecified for none)
		doneTaunts: ["That was good...", "Give me a minute and we'll go again, okay~?", "Such a good girl~!"],

		// fallbackNarration: ["The ravager roughly gropes you! (DamageTaken)"], // Going to rework this, but let it be default for now
		restrainChance: 0.05, // Chance, decimal between 0 and 1

		// progression data - first group that's got a number your count is less than is the one used
		// you can use any numbers, any ranges, but keep in mind that there's a turn between hits unless you're doing something like AttackPoints 0
		ranges: [
			[1, { // starting - no stat damage yet
				taunts: ["Relax, girlie...", "Hehe, ready~?"],
				narration: {
					ItemVulva: ["EnemyCName lines her intimidating cock up with your pussy..."],
					ItemButt: ["EnemyCName lines her intimidating cock up with your ass..."],
					ItemMouth: ["EnemyCName presses her cockhead against your lips..."],
					ItemHead: ["head range 1"] //
				}
			}],

			[5, { // regular
				taunts: ["Mmh...", "That's it..."],
				narration: {
					ItemVulva: ["Wide hips meet yours as her cock stretches out your pussy..."],
					ItemButt: ["Wide hips meet your ass as her dick stretches you out..."],
					ItemMouth: ["Her strong hand guides your head up and down her thick cock..."],
					ItemHead: ["head range 5~"] //
				},
				sp: -0.1,
				dp: 1,
				orgasmBonus: 0,
			}],

			[12, { // rougher
				taunts: ["Good girl...", "Take it...", "I'm gonna miss you when we find you a nice master..."],
				narration: {
					ItemVulva: ["Strong hands grip your waist as your pussy is pounded..."],
					ItemButt: ["Your hips are gripped tight as your ass is railed..."],
					ItemMouth: ["Your face meets her lap, throating her cock over and over..."],
					ItemHead: ["head range 12"] //
				},
				sp: -0.15,
				dp: 1.5,
				orgasmBonus: 1,
			}],

			[16, { // peak intensity
				taunts: ["Ooh, good girl~!", "Haah!"],
				narration: {
					ItemVulva: ["You cry out with each hilting thrust, smothered by soft curves!"],
					ItemButt: ["Her ferocious thrusts drive pathetic whimpers out of you!"],
					ItemMouth: ["You feel weak, her dick filling your throat again and again!"],
					ItemHead: ["head range 16"] //
				},
				sp: -0.2,
				dp: 2,
				orgasmBonus: 2,
			}],

			[17, { // preparing to finish
				taunts: ["Here it comes~~!", "Let's fill you up~~!"],
				narration: {
					ItemVulva: ["With a thunderous final thrust, her dick throbs, she's about to--!!"],
					ItemButt: ["Her hips clap against yours with finality, she's about to--!!"],
					ItemMouth: ["Your vision fades as her cock pulses in your throat, she's about to--!!"],
					ItemHead: ["head range 17"] //
				},
				sp: -0.2,
				dp: 5,
				orgasmBonus: 3,
			}],

			[20, { // finishing
				taunts: ["Aaaah~...", "Ooohh~...", "That's a good pet~..."],
				narration: {
					ItemVulva: ["You moan loudly as you feel your womb flooded with her hot cum..."],
					ItemButt: ["Your belly grows warm as she fills you up, pounded powerfully into her lap..."],
					ItemMouth: ["GLK... GLK... You helplessly swallow wave after wave of her seed..."],
					ItemHead: ["head range 20"] //
				},
				dp: 10,
				wp: -1,
				orgasmBonus: 4,
				sub: 1
			}],
		]
	},

	// on-hit effect definition - required for this to work
	effect: {
		effect: {
			name: "Ravage"
		}
	},

	//these events are required for ravager stuff to work properly
	events: [
		{trigger: "death", type: "ravagerRemove"},
		{trigger: "tickAfter", type: "ravagerRefractory"},
	],

	//useful flags
	noDisplace: true, // theoretically stops enemies from shoving this one out of the way. didn't seem to work by its lonesome for me
	guardChance: 0.4, // chance to spawn as a "Guard" type AI
	focusPlayer: true, // obvious
}

KinkyDungeonEnemies.push(banditRavager)
KDEventMapEnemy['ravagerCallbacks']['definitionBanditRavager'] = banditRavager

//textkeys
addTextKey("NameBanditRavager", "Bandit Ravager")
addTextKey('AttackBanditRavagerDash','The bandit charges and captures you in a powerful hug!')
addTextKey('AttackBanditRavagerBlind','The bandit pins you against her soft body effortlessly!')
addTextKey("KillBanditRavager", "The bandit scrambles away, waiting for her next chance...")
// Need 'AttackBanditRavager' (happens when jailed)
