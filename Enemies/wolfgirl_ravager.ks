function AddCallback(key, func) {
	if (! KDEventMapEnemy['ravagerCallbacks']) {
		throw new Error('Ravager Framework has not been loaded yet! Please ensure that the Framework has been added and is listed alphabetically before your custom Ravager mod. If this is happening without any additional ravager mods (aka only Ravager Framework is adding ravagers), please post as much info as you can to the framework\'s thread on Discord so it can be investigated')
	} else {
		// When creating a custom ravager mod, I'd suggest changing this log call to have your mod's name inside the [ ] to help make it more clear what is loading when
		console.log('[Ravager Framework] Adding callback function with key ', key)
		KDEventMapEnemy['ravagerCallbacks'][key] = func
	}
}
// Moved the All Range Callback so it'll actually work
AddCallback('wolfgirlRavagerAllRangeCallback', (entity, target) => {
	let collared = KinkyDungeonPlayerTags.get("Collars");
	let moduled = KinkyDungeonPlayerTags.get("Modules");
	let leashed = KinkyDungeonPlayerTags.get("Item_WolfLeash") || KinkyDungeonPlayerTags.get("Item_BasicLeash")
	if(collared && moduled && !leashed){
		KinkyDungeonAddRestraintIfWeaker(KinkyDungeonGetRestraintByName("WolfLeash"), 1, false, "Red", undefined, undefined, undefined, "Nevermere", true);
		KinkyDungeonSendTextMessage(5, "The Alpha clicks a leash onto your collar, pulling you close...", "#ff44ff", 3);
	} else if(collared && !moduled) {
		KinkyDungeonAddRestraintIfWeaker(KinkyDungeonGetRestraintByName("ShockModule"), 1, false, "Red", undefined, undefined, undefined, "Nevermere", true);
		KinkyDungeonSendTextMessage(5, "The Alpha activates your collar's training module...", "#ff44ff", 3);
	} else if(!collared) {
		KinkyDungeonAddRestraintIfWeaker(KinkyDungeonGetRestraintByName("WolfCollar"), 1, false, "Red", undefined, undefined, undefined, "Nevermere", true);
		KinkyDungeonSendTextMessage(5, "The Alpha fixes a collar around your neck...", "#ff44ff", 3);
	}
})
// Moved the Submit Chance Modifier so it'll actually work
AddCallback('wolfgirlSubmitChanceModifierCallback', (entity, target, baseSubmitChance) => {
	if(KinkyDungeonPlayerTags.get("Item_ShockModule")) {
		KinkyDungeonSendTextMessage(5, "Your shock module gently insists you submit... (+20% Submit Chance)", "#ff44ff", 3);
		return baseSubmitChance + 20
	}
	return baseSubmitChance
})
// Hopefully we can get her spell functional here without screwing up the ravaging
AddCallback('wolfgirlRavagerEffectCallback', (entity, target) => {
	// console.log('[Ravager Framework] [Wolfgirl Status Callback] ', entity, target)
	if (!entity.hasThrownDevice) {
		let res = KinkyDungeonCastSpell(target.x, target.y, KinkyDungeonSpellListEnemies.find((spell) => { if (spell.name == 'RestrainingDevice') return true}), entity)
		// console.log(res)
		entity.hasThrownDevice = true
		return true
	}
	return false
})

// Outfit declaration
// KDModelDresses['WolfgirlRavDresses'] = [
// 	{
// 		"Lost": false,
//     "Item": "WolfCollarSmallTag",
//     "Group": "Wolf",
//     "Parent": "Wolf",
//     "TopLevel": true,
//     "Categories": [
//       "Accessories"
//       ],
//     "Layers": {
//       "FCollar": {
//         "Name": "FCollar",
//         "Layer": "Collar",
//         "Pri": 35,
//         "Invariant": true,
//         "InheritColor": "Lining"
//       },
//       "FCollarBand": {
//         "Name": "FCollarBand",
//         "Layer": "Collar",
//         "Pri": 35.1,
//         "Invariant": true,
//         "InheritColor": "Band",
//         "TieToLayer": "FCollar",
//         "NoOverride": true
//       },
//       "FCollarHardware": {
//         "Name": "FCollarHardware",
//         "Layer": "CollarAcc",
//         "Pri": -5.1,
//         "Invariant": true,
//         "InheritColor": "Hardware",
//         "TieToLayer": "FCollar",
//         "NoOverride": true,
//         "HidePoses": {
//           "HideModuleMiddle": true
//         }
//       },
//       "FCollarTag": {
//         "Name": "FCollarTag",
//         "Layer": "CollarAcc",
//         "Pri": -5,
//         "Invariant": true,
//         "InheritColor": "Tag",
//         "TieToLayer": "FCollar",
//         "NoOverride": true,
//         "HidePoses": {
//           "HideModuleMiddle": true
//         }
//       }
//     }
//   },
//   {
//   	"Lost": false,
//     "Item": "WolfHeels",
//     "Group": "WolfCatsuit",
//     "Parent": "Wolf",
//     "TopLevel": true,
//     "Categories": [
//       "Shoes"
//       ],
//     "Layers": {
//       "ShoeLeft": {
//         "Name": "ShoeLeft",
//         "Layer": "ShoeLeft",
//         "Pri": 9,
//         "Poses": {
//           "Spread": true,
//           "Closed": true,
//           "Kneel": true,
//           "KneelClosed": true
//         },
//         "HideWhenOverridden": true
//       },
//       "ShoeRight": {
//         "Name": "ShoeRight",
//         "Layer": "ShoeRight",
//         "Pri": 9,
//         "Poses": {
//           "Spread": true,
//           "Closed": true
//         },
//         "HideWhenOverridden": true
//       },
//       "ShoeRightKneel": {
//         "Name": "ShoeRightKneel",
//         "Layer": "ShoeRightKneel",
//         "Pri": 9,
//         "Poses": {
//           "Kneel": true
//         },
//         "Invariant": true,
//         "InheritColor": "ShoeRight",
//         "HideWhenOverridden": true
//       },
//       "ShoeLeftHogtie": {
//         "Name": "ShoeLeftHogtie",
//         "Layer": "ShoeLeftHogtie",
//         "Pri": 9,
//         "Poses": {
//           "Hogtie": true
//         },
//         "Invariant": true,
//         "InheritColor": "ShoeLeft",
//         "HideWhenOverridden": true
//       }
//     }
//   },
//   {
//   	"Lost": false,
//     "Item": "CyberPanties",
//     "Group": "Chastity",
//     "Parent": "CyberBelt",
//     "TopLevel": true,
//     "Categories": [
//       "Underwear",
//       "Panties",
//       "Metal",
//       "SciFi"
//       ],
//     "Layers": {
//       "CyberPanties": {
//         "Name": "CyberPanties",
//         "Layer": "Panties",
//         "Pri": -10,
//         "Invariant": true,
//         "InheritColor": "Metal",
//         "MorphPoses": {
//           "Closed": "Closed",
//           "Hogtie": "Closed"
//         }
//       },
//       "CyberPantiesLining": {
//         "Name": "CyberPantiesLining",
//         "Layer": "Panties",
//         "Pri": -10.1,
//         "Invariant": true,
//         "DisplacementInvariant": true,
//         "NoOverride": true,
//         "TieToLayer": "CyberPanties",
//         "InheritColor": "Lining",
//         "MorphPoses": {
//           "Closed": "Closed",
//           "Hogtie": "Closed"
//         }
//       }
//     },
//     "Filters": {
//       "Lining": {
//         "gamma": 1.0166666666666666,
//         "saturation": 0,
//         "contrast": 0.88,
//         "brightness": 1,
//         "red": 0.11764705882352941,
//         "green": 0.11764705882352941,
//         "blue": 0.11764705882352941,
//         "alpha": 0.9833333333333333
//       }
//     }
//   },
//   {
//   	"Lost": false,
//     "Item": "VBikini",
//     "Group": "Swimsuit",
//     "Parent": "StrappySwimsuit",
//     "TopLevel": true,
//     "Categories": [
//       "Underwear",
//       "Panties"
//       ],
//     "Layers": {
//       "VBikini": {
//         "Name": "VBikini",
//         "Layer": "Panties",
//         "Pri": 39,
//         "Invariant": true,
//         "MorphPoses": {
//           "Closed": "Closed",
//           "Hogtie": "Closed"
//         }
//       }
//     },
//     "Filters": {
//       "VBikini": {
//         "gamma": 1,
//         "saturation": 0,
//         "contrast": 1,
//         "brightness": 1,
//         "red": 0.29411764705882354,
//         "green": 0.29411764705882354,
//         "blue": 0.27450980392156865,
//         "alpha": 1
//       }
//     },
//     "Properties": {
//       "VBikini": {
//         "YScale": 0.6,
//         "YOffset": 700,
//         "XScale": 1.11,
//         "XOffset": -120,
//         "LayerBonus": -100
//       }
//     }
//   }, //Weird morphing?
//   {
//   	"Lost": false,
//     "Item": "ElfPanties",
//     "Group": "Elf",
//     "Parent": "Elf",
//     "TopLevel": true,
//     "Categories": [
//       "Underwear",
//       "Panties"
//       ],
//     "Layers": {
//       "Panties": {
//         "Name": "Panties",
//         "Layer": "Panties",
//         "Pri": -30,
//         "Invariant": true
//       }
//     },
//     "Properties": {
//       "Panties": {
//         "YOffset": 25,
//         "LayerBonus": -10000
//       }
//     }
//   },
//   {
//   	"Lost": false,
//     "Item": "LatexWhip",
//     "Group": "Weapon",
//     "TopLevel": true,
//     "Protected": false,
//     "Categories": [
//       "Weapon"
//       ],
//     "Layers": {
//       "LatexWhip": {
//         "Name": "LatexWhip",
//         "Layer": "Weapon",
//         "Pri": 0,
//         "NoOverride": true,
//         "Poses": {
//           "Free": true
//         }
//       }
//     },
//     "Filters": {
//       "LatexWhip": {
//         "gamma": 1,
//         "saturation": 0,
//         "contrast": 1.25,
//         "brightness": 1,
//         "red": 0,
//         "green": 0.7254901960784313,
//         "blue": 0.0392156862745098,
//         "alpha": 1
//       }
//     }
//   },
//   //
//   {
//   	// "Color": "Default",
//   	"Lost": false,
//     "Item": "WolfTorsoUpper",
//     "Group": "WolfCatsuit",
//     // "Parent": "Wolf",
//     // "TopLevel": true,
//     // "Categories": [
//     //   "Underwear",
//     //   "Panties",
//     //   "Tops"
//     //   ],
//     // "Layers": {
//     //   "Chest": {
//     //     "Name": "Chest",
//     //     "Layer": "SuitChest",
//     //     "Pri": 30,
//     //     "HidePrefixPose": [
//     //       "Encase"
//     //       ],
//     //     "HidePrefixPoseSuffix": [
//     //       "TorsoUpper"
//     //       ],
//     //     "Invariant": true,
//     //     "InheritColor": "Cloth",
//     //     "EraseAmount": 100,
//     //     "EraseSprite": "LaceChest",
//     //     "EraseLayers": {
//     //       "ShirtCutoffBra": true
//     //     }
//     //   },
//     //   "TorsoUpperCups": {
//     //     "Name": "TorsoUpperCups",
//     //     "Layer": "SuitChest",
//     //     "Pri": 30.1,
//     //     "Invariant": true,
//     //     "InheritColor": "Cups",
//     //     "TieToLayer": "Chest",
//     //     "NoOverride": true
//     //   },
//     //   "ChestRim": {
//     //     "Name": "ChestRim",
//     //     "Layer": "SuitChest",
//     //     "Pri": 30.1,
//     //     "Invariant": true,
//     //     "InheritColor": "Rim",
//     //     "TieToLayer": "Chest",
//     //     "NoOverride": true
//     //   },
//     //   "ChestBand": {
//     //     "Name": "ChestBand",
//     //     "Layer": "SuitChest",
//     //     "Pri": 30.2,
//     //     "Invariant": true,
//     //     "InheritColor": "Band",
//     //     "TieToLayer": "Chest",
//     //     "NoOverride": true
//     //   },
//     //   "TorsoUpper": {
//     //     "Name": "TorsoUpper",
//     //     "Layer": "Bodysuit",
//     //     "Pri": 30,
//     //     "HidePrefixPose": [
//     //       "Encase"
//     //       ],
//     //     "HidePrefixPoseSuffix": [
//     //       "TorsoUpper"
//     //       ],
//     //     "Invariant": true,
//     //     "InheritColor": "Cloth"
//     //   },
//     //   "TorsoUpperBand": {
//     //     "Name": "TorsoUpperBand",
//     //     "Layer": "Bodysuit",
//     //     "Pri": 30.2,
//     //     "Invariant": true,
//     //     "InheritColor": "Band",
//     //     "TieToLayer": "TorsoUpper",
//     //     "NoOverride": true
//     //   },
//     //   "TorsoUpperRim": {
//     //     "Name": "TorsoUpperRim",
//     //     "Layer": "Bodysuit",
//     //     "Pri": 30.1,
//     //     "Invariant": true,
//     //     "InheritColor": "Rim",
//     //     "TieToLayer": "TorsoUpper",
//     //     "NoOverride": true
//     //   }
//     // }
//   },
//   //
//   // {
//   // 	"Lost": false,
//   //   "Item": "WolfSocks",
//   //   "Group": "WolfCatsuit",
//   //   "Parent": "Wolf",
//   //   "TopLevel": true,
//   //   "Categories": [
//   //     "Socks"
//   //     ],
//   //   "Layers": {
//   //     "LegRight": {
//   //       "Name": "LegRight",
//   //       "Layer": "StockingRight",
//   //       "Pri": -1,
//   //       "Poses": {
//   //         "Spread": true,
//   //         "Closed": true,
//   //         "Kneel": true,
//   //         "KneelClosed": true,
//   //         "Hogtie": true
//   //       },
//   //       "GlobalDefaultOverride": {
//   //         "Hogtie": true,
//   //         "KneelClosed": true
//   //       },
//   //       "InheritColor": "Cloth"
//   //     },
//   //     "LegRimRight": {
//   //       "Name": "LegRimRight",
//   //       "Layer": "StockingRight",
//   //       "Pri": -0.9,
//   //       "Poses": {
//   //         "Spread": true,
//   //         "Closed": true,
//   //         "Kneel": true,
//   //         "KneelClosed": true,
//   //         "Hogtie": true
//   //       },
//   //       "GlobalDefaultOverride": {
//   //         "Hogtie": true,
//   //         "KneelClosed": true
//   //       },
//   //       "NoOverride": true,
//   //       "TieToLayer": "LegRight",
//   //       "InheritColor": "Rim"
//   //     },
//   //     "LegBandRight": {
//   //       "Name": "LegBandRight",
//   //       "Layer": "StockingRight",
//   //       "Pri": -0.8,
//   //       "Poses": {
//   //         "Spread": true,
//   //         "Closed": true,
//   //         "Kneel": true,
//   //         "KneelClosed": true,
//   //         "Hogtie": true
//   //       },
//   //       "GlobalDefaultOverride": {
//   //         "Hogtie": true,
//   //         "KneelClosed": true
//   //       },
//   //       "NoOverride": true,
//   //       "TieToLayer": "LegRight",
//   //       "InheritColor": "Band"
//   //     },
//   //     "LegPadsRight": {
//   //       "Name": "LegPadsRight",
//   //       "Layer": "StockingRight",
//   //       "Pri": -0.9,
//   //       "Poses": {
//   //         "Spread": true,
//   //         "Closed": true,
//   //         "Kneel": true,
//   //         "KneelClosed": true,
//   //         "Hogtie": true
//   //       },
//   //       "GlobalDefaultOverride": {
//   //         "Hogtie": true,
//   //         "KneelClosed": true
//   //       },
//   //       "NoOverride": true,
//   //       "TieToLayer": "LegRight",
//   //       "InheritColor": "Pads"
//   //     },
//   //     "LegLeft": {
//   //       "Name": "LegLeft",
//   //       "Layer": "StockingLeft",
//   //       "Pri": -1,
//   //       "Poses": {
//   //         "Spread": true,
//   //         "Closed": true,
//   //         "Kneel": true,
//   //         "KneelClosed": true,
//   //         "Hogtie": true
//   //       },
//   //       "GlobalDefaultOverride": {
//   //         "Hogtie": true,
//   //         "KneelClosed": true
//   //       },
//   //       "InheritColor": "Cloth"
//   //     },
//   //     "LegRimLeft": {
//   //       "Name": "LegRimLeft",
//   //       "Layer": "StockingLeft",
//   //       "Pri": -0.9,
//   //       "Poses": {
//   //         "Spread": true,
//   //         "Closed": true,
//   //         "Kneel": true,
//   //         "KneelClosed": true,
//   //         "Hogtie": true
//   //       },
//   //       "GlobalDefaultOverride": {
//   //         "Hogtie": true,
//   //         "KneelClosed": true
//   //       },
//   //       "NoOverride": true,
//   //       "TieToLayer": "LegLeft",
//   //       "InheritColor": "Rim"
//   //     },
//   //     "LegBandLeft": {
//   //       "Name": "LegBandLeft",
//   //       "Layer": "StockingLeft",
//   //       "Pri": -0.8,
//   //       "Poses": {
//   //         "Spread": true,
//   //         "Closed": true,
//   //         "Kneel": true,
//   //         "KneelClosed": true,
//   //         "Hogtie": true
//   //       },
//   //       "GlobalDefaultOverride": {
//   //         "Hogtie": true,
//   //         "KneelClosed": true
//   //       },
//   //       "NoOverride": true,
//   //       "TieToLayer": "LegLeft",
//   //       "InheritColor": "Band"
//   //     },
//   //     "LegPadsLeft": {
//   //       "Name": "LegPadsLeft",
//   //       "Layer": "StockingLeft",
//   //       "Pri": -0.9,
//   //       "Poses": {
//   //         "Spread": true,
//   //         "Closed": true,
//   //         "Kneel": true,
//   //         "KneelClosed": true,
//   //         "Hogtie": true
//   //       },
//   //       "GlobalDefaultOverride": {
//   //         "Hogtie": true,
//   //         "KneelClosed": true
//   //       },
//   //       "NoOverride": true,
//   //       "TieToLayer": "LegLeft",
//   //       "InheritColor": "Pads"
//   //     }
//   //   },
//   //   "Properties": {
//   //     "Cloth": {
//   //       "LayerBonus": 15000
//   //     }
//   //   }
//   // },
//   //
//   // {
//   // 	"Lost": false,
//   //   "Item": "WolfGloveLeft",
//   //   "Group": "WolfCatsuit",
//   //   "Parent": "Wolf",
//   //   "Categories": [
//   //     "Gloves"
//   //     ],
//   //   "Layers": {
//   //     "GloveLeft": {
//   //       "Name": "GloveLeft",
//   //       "Layer": "GloveLeft",
//   //       "Pri": -1,
//   //       "Poses": {
//   //         "Free": true,
//   //         "Boxtie": true,
//   //         "Wristtie": true,
//   //         "Yoked": true,
//   //         "Front": true,
//   //         "Up": true,
//   //         "Crossed": true
//   //       },
//   //       "GlobalDefaultOverride": {
//   //         "Front": true,
//   //         "Crossed": true
//   //       }
//   //     },
//   //     "ForeGloveLeft": {
//   //       "Name": "ForeGloveLeft",
//   //       "Layer": "ForeGloveLeft",
//   //       "Pri": -1,
//   //       "Poses": {
//   //         "Front": true,
//   //         "Crossed": true
//   //       },
//   //       "InheritColor": "GloveLeft",
//   //       "GlobalDefaultOverride": {
//   //         "Front": true,
//   //         "Crossed": true
//   //       },
//   //       "SwapLayerPose": {
//   //         "Crossed": "CrossGloveLeft"
//   //       }
//   //     },
//   //     "RimGloveLeft": {
//   //       "Name": "RimGloveLeft",
//   //       "Layer": "GloveLeft",
//   //       "Pri": -0.9,
//   //       "Poses": {
//   //         "Free": true,
//   //         "Boxtie": true,
//   //         "Wristtie": true,
//   //         "Yoked": true,
//   //         "Front": true,
//   //         "Up": true,
//   //         "Crossed": true
//   //       },
//   //       "InheritColor": "RimLeft",
//   //       "NoOverride": true,
//   //       "GlobalDefaultOverride": {
//   //         "Front": true,
//   //         "Crossed": true
//   //       }
//   //     },
//   //     "RimForeGloveLeft": {
//   //       "Name": "RimForeGloveLeft",
//   //       "Layer": "ForeGloveLeft",
//   //       "Pri": -0.9,
//   //       "Poses": {
//   //         "Front": true,
//   //         "Crossed": true
//   //       },
//   //       "InheritColor": "RimLeft",
//   //       "NoOverride": true,
//   //       "GlobalDefaultOverride": {
//   //         "Front": true,
//   //         "Crossed": true
//   //       },
//   //       "SwapLayerPose": {
//   //         "Crossed": "CrossGloveLeft"
//   //       }
//   //     },
//   //     "BandGloveLeft": {
//   //       "Name": "BandGloveLeft",
//   //       "Layer": "GloveLeft",
//   //       "Pri": -0.8,
//   //       "Poses": {
//   //         "Free": true,
//   //         "Boxtie": true,
//   //         "Wristtie": true,
//   //         "Yoked": true,
//   //         "Front": true,
//   //         "Up": true,
//   //         "Crossed": true
//   //       },
//   //       "InheritColor": "BandLeft",
//   //       "NoOverride": true,
//   //       "GlobalDefaultOverride": {
//   //         "Front": true,
//   //         "Crossed": true
//   //       }
//   //     },
//   //     "BandForeGloveLeft": {
//   //       "Name": "BandForeGloveLeft",
//   //       "Layer": "ForeGloveLeft",
//   //       "Pri": -0.8,
//   //       "Poses": {
//   //         "Front": true,
//   //         "Crossed": true
//   //       },
//   //       "InheritColor": "BandLeft",
//   //       "NoOverride": true,
//   //       "GlobalDefaultOverride": {
//   //         "Front": true,
//   //         "Crossed": true
//   //       },
//   //       "SwapLayerPose": {
//   //         "Crossed": "CrossGloveLeft"
//   //       }
//   //     }
//   //   }
//   // },
//   //
// ]

// KDModelCosplay['WolfgirlRavCosplay'] = [
//   {
// 		"Lost": false,
//     "Item": "WolfCollarSmallTag",
//     "Group": "Wolf",
//     "Parent": "Wolf",
//     "TopLevel": true,
//     "Categories": [
//       "Accessories"
//       ],
//     "Layers": {
//       "FCollar": {
//         "Name": "FCollar",
//         "Layer": "Collar",
//         "Pri": 35,
//         "Invariant": true,
//         "InheritColor": "Lining"
//       },
//       "FCollarBand": {
//         "Name": "FCollarBand",
//         "Layer": "Collar",
//         "Pri": 35.1,
//         "Invariant": true,
//         "InheritColor": "Band",
//         "TieToLayer": "FCollar",
//         "NoOverride": true
//       },
//       "FCollarHardware": {
//         "Name": "FCollarHardware",
//         "Layer": "CollarAcc",
//         "Pri": -5.1,
//         "Invariant": true,
//         "InheritColor": "Hardware",
//         "TieToLayer": "FCollar",
//         "NoOverride": true,
//         "HidePoses": {
//           "HideModuleMiddle": true
//         }
//       },
//       "FCollarTag": {
//         "Name": "FCollarTag",
//         "Layer": "CollarAcc",
//         "Pri": -5,
//         "Invariant": true,
//         "InheritColor": "Tag",
//         "TieToLayer": "FCollar",
//         "NoOverride": true,
//         "HidePoses": {
//           "HideModuleMiddle": true
//         }
//       }
//     }
//   },
//   {
//   	"Lost": false,
//     "Item": "WolfHeels",
//     "Group": "WolfCatsuit",
//     "Parent": "Wolf",
//     "TopLevel": true,
//     "Categories": [
//       "Shoes"
//       ],
//     "Layers": {
//       "ShoeLeft": {
//         "Name": "ShoeLeft",
//         "Layer": "ShoeLeft",
//         "Pri": 9,
//         "Poses": {
//           "Spread": true,
//           "Closed": true,
//           "Kneel": true,
//           "KneelClosed": true
//         },
//         "HideWhenOverridden": true
//       },
//       "ShoeRight": {
//         "Name": "ShoeRight",
//         "Layer": "ShoeRight",
//         "Pri": 9,
//         "Poses": {
//           "Spread": true,
//           "Closed": true
//         },
//         "HideWhenOverridden": true
//       },
//       "ShoeRightKneel": {
//         "Name": "ShoeRightKneel",
//         "Layer": "ShoeRightKneel",
//         "Pri": 9,
//         "Poses": {
//           "Kneel": true
//         },
//         "Invariant": true,
//         "InheritColor": "ShoeRight",
//         "HideWhenOverridden": true
//       },
//       "ShoeLeftHogtie": {
//         "Name": "ShoeLeftHogtie",
//         "Layer": "ShoeLeftHogtie",
//         "Pri": 9,
//         "Poses": {
//           "Hogtie": true
//         },
//         "Invariant": true,
//         "InheritColor": "ShoeLeft",
//         "HideWhenOverridden": true
//       }
//     }
//   },
//   {
//   	"Lost": false,
//     "Item": "CyberPanties",
//     "Group": "Chastity",
//     "Parent": "CyberBelt",
//     "TopLevel": true,
//     "Categories": [
//       "Underwear",
//       "Panties",
//       "Metal",
//       "SciFi"
//       ],
//     "Layers": {
//       "CyberPanties": {
//         "Name": "CyberPanties",
//         "Layer": "Panties",
//         "Pri": -10,
//         "Invariant": true,
//         "InheritColor": "Metal",
//         "MorphPoses": {
//           "Closed": "Closed",
//           "Hogtie": "Closed"
//         }
//       },
//       "CyberPantiesLining": {
//         "Name": "CyberPantiesLining",
//         "Layer": "Panties",
//         "Pri": -10.1,
//         "Invariant": true,
//         "DisplacementInvariant": true,
//         "NoOverride": true,
//         "TieToLayer": "CyberPanties",
//         "InheritColor": "Lining",
//         "MorphPoses": {
//           "Closed": "Closed",
//           "Hogtie": "Closed"
//         }
//       }
//     },
//     "Filters": {
//       "Lining": {
//         "gamma": 1.0166666666666666,
//         "saturation": 0,
//         "contrast": 0.88,
//         "brightness": 1,
//         "red": 0.11764705882352941,
//         "green": 0.11764705882352941,
//         "blue": 0.11764705882352941,
//         "alpha": 0.9833333333333333
//       }
//     }
//   },
//   {
//   	"Lost": false,
//     "Item": "VBikini",
//     "Group": "Swimsuit",
//     "Parent": "StrappySwimsuit",
//     "TopLevel": true,
//     "Categories": [
//       "Underwear",
//       "Panties"
//       ],
//     "Layers": {
//       "VBikini": {
//         "Name": "VBikini",
//         "Layer": "Panties",
//         "Pri": 39,
//         "Invariant": true,
//         "MorphPoses": {
//           "Closed": "Closed",
//           "Hogtie": "Closed"
//         }
//       }
//     },
//     "Filters": {
//       "VBikini": {
//         "gamma": 1,
//         "saturation": 0,
//         "contrast": 1,
//         "brightness": 1,
//         "red": 0.29411764705882354,
//         "green": 0.29411764705882354,
//         "blue": 0.27450980392156865,
//         "alpha": 1
//       }
//     },
//     "Properties": {
//       "VBikini": {
//         "YScale": 0.6,
//         "YOffset": 700,
//         "XScale": 1.11,
//         "XOffset": -120,
//         "LayerBonus": -100
//       }
//     }
//   }, //Weird morphing?
//   {
//   	"Lost": false,
//     "Item": "ElfPanties",
//     "Group": "Elf",
//     "Parent": "Elf",
//     "TopLevel": true,
//     "Categories": [
//       "Underwear",
//       "Panties"
//       ],
//     "Layers": {
//       "Panties": {
//         "Name": "Panties",
//         "Layer": "Panties",
//         "Pri": -30,
//         "Invariant": true
//       }
//     },
//     "Properties": {
//       "Panties": {
//         "YOffset": 25,
//         "LayerBonus": -10000
//       }
//     }
//   },
//   {
//   	"Lost": false,
//     "Item": "LatexWhip",
//     "Group": "Weapon",
//     "TopLevel": true,
//     "Protected": false,
//     "Categories": [
//       "Weapon"
//       ],
//     "Layers": {
//       "LatexWhip": {
//         "Name": "LatexWhip",
//         "Layer": "Weapon",
//         "Pri": 0,
//         "NoOverride": true,
//         "Poses": {
//           "Free": true
//         }
//       }
//     },
//     "Filters": {
//       "LatexWhip": {
//         "gamma": 1,
//         "saturation": 0,
//         "contrast": 1.25,
//         "brightness": 1,
//         "red": 0,
//         "green": 0.7254901960784313,
//         "blue": 0.0392156862745098,
//         "alpha": 1
//       }
//     }
//   },
//   //
//   {
//   	// "Color": "Default",
//   	"Lost": false,
//     "Item": "WolfTorsoUpper",
//     "Group": "WolfCatsuit",
//     // "Parent": "Wolf",
//     // "TopLevel": true,
//     // "Categories": [
//     //   "Underwear",
//     //   "Panties",
//     //   "Tops"
//     //   ],
//     // "Layers": {
//     //   "Chest": {
//     //     "Name": "Chest",
//     //     "Layer": "SuitChest",
//     //     "Pri": 30,
//     //     "HidePrefixPose": [
//     //       "Encase"
//     //       ],
//     //     "HidePrefixPoseSuffix": [
//     //       "TorsoUpper"
//     //       ],
//     //     "Invariant": true,
//     //     "InheritColor": "Cloth",
//     //     "EraseAmount": 100,
//     //     "EraseSprite": "LaceChest",
//     //     "EraseLayers": {
//     //       "ShirtCutoffBra": true
//     //     }
//     //   },
//     //   "TorsoUpperCups": {
//     //     "Name": "TorsoUpperCups",
//     //     "Layer": "SuitChest",
//     //     "Pri": 30.1,
//     //     "Invariant": true,
//     //     "InheritColor": "Cups",
//     //     "TieToLayer": "Chest",
//     //     "NoOverride": true
//     //   },
//     //   "ChestRim": {
//     //     "Name": "ChestRim",
//     //     "Layer": "SuitChest",
//     //     "Pri": 30.1,
//     //     "Invariant": true,
//     //     "InheritColor": "Rim",
//     //     "TieToLayer": "Chest",
//     //     "NoOverride": true
//     //   },
//     //   "ChestBand": {
//     //     "Name": "ChestBand",
//     //     "Layer": "SuitChest",
//     //     "Pri": 30.2,
//     //     "Invariant": true,
//     //     "InheritColor": "Band",
//     //     "TieToLayer": "Chest",
//     //     "NoOverride": true
//     //   },
//     //   "TorsoUpper": {
//     //     "Name": "TorsoUpper",
//     //     "Layer": "Bodysuit",
//     //     "Pri": 30,
//     //     "HidePrefixPose": [
//     //       "Encase"
//     //       ],
//     //     "HidePrefixPoseSuffix": [
//     //       "TorsoUpper"
//     //       ],
//     //     "Invariant": true,
//     //     "InheritColor": "Cloth"
//     //   },
//     //   "TorsoUpperBand": {
//     //     "Name": "TorsoUpperBand",
//     //     "Layer": "Bodysuit",
//     //     "Pri": 30.2,
//     //     "Invariant": true,
//     //     "InheritColor": "Band",
//     //     "TieToLayer": "TorsoUpper",
//     //     "NoOverride": true
//     //   },
//     //   "TorsoUpperRim": {
//     //     "Name": "TorsoUpperRim",
//     //     "Layer": "Bodysuit",
//     //     "Pri": 30.1,
//     //     "Invariant": true,
//     //     "InheritColor": "Rim",
//     //     "TieToLayer": "TorsoUpper",
//     //     "NoOverride": true
//     //   }
//     // }
//   },
//   //
//   // {
//   // 	"Lost": false,
//   //   "Item": "WolfSocks",
//   //   "Group": "WolfCatsuit",
//   //   "Parent": "Wolf",
//   //   "TopLevel": true,
//   //   "Categories": [
//   //     "Socks"
//   //     ],
//   //   "Layers": {
//   //     "LegRight": {
//   //       "Name": "LegRight",
//   //       "Layer": "StockingRight",
//   //       "Pri": -1,
//   //       "Poses": {
//   //         "Spread": true,
//   //         "Closed": true,
//   //         "Kneel": true,
//   //         "KneelClosed": true,
//   //         "Hogtie": true
//   //       },
//   //       "GlobalDefaultOverride": {
//   //         "Hogtie": true,
//   //         "KneelClosed": true
//   //       },
//   //       "InheritColor": "Cloth"
//   //     },
//   //     "LegRimRight": {
//   //       "Name": "LegRimRight",
//   //       "Layer": "StockingRight",
//   //       "Pri": -0.9,
//   //       "Poses": {
//   //         "Spread": true,
//   //         "Closed": true,
//   //         "Kneel": true,
//   //         "KneelClosed": true,
//   //         "Hogtie": true
//   //       },
//   //       "GlobalDefaultOverride": {
//   //         "Hogtie": true,
//   //         "KneelClosed": true
//   //       },
//   //       "NoOverride": true,
//   //       "TieToLayer": "LegRight",
//   //       "InheritColor": "Rim"
//   //     },
//   //     "LegBandRight": {
//   //       "Name": "LegBandRight",
//   //       "Layer": "StockingRight",
//   //       "Pri": -0.8,
//   //       "Poses": {
//   //         "Spread": true,
//   //         "Closed": true,
//   //         "Kneel": true,
//   //         "KneelClosed": true,
//   //         "Hogtie": true
//   //       },
//   //       "GlobalDefaultOverride": {
//   //         "Hogtie": true,
//   //         "KneelClosed": true
//   //       },
//   //       "NoOverride": true,
//   //       "TieToLayer": "LegRight",
//   //       "InheritColor": "Band"
//   //     },
//   //     "LegPadsRight": {
//   //       "Name": "LegPadsRight",
//   //       "Layer": "StockingRight",
//   //       "Pri": -0.9,
//   //       "Poses": {
//   //         "Spread": true,
//   //         "Closed": true,
//   //         "Kneel": true,
//   //         "KneelClosed": true,
//   //         "Hogtie": true
//   //       },
//   //       "GlobalDefaultOverride": {
//   //         "Hogtie": true,
//   //         "KneelClosed": true
//   //       },
//   //       "NoOverride": true,
//   //       "TieToLayer": "LegRight",
//   //       "InheritColor": "Pads"
//   //     },
//   //     "LegLeft": {
//   //       "Name": "LegLeft",
//   //       "Layer": "StockingLeft",
//   //       "Pri": -1,
//   //       "Poses": {
//   //         "Spread": true,
//   //         "Closed": true,
//   //         "Kneel": true,
//   //         "KneelClosed": true,
//   //         "Hogtie": true
//   //       },
//   //       "GlobalDefaultOverride": {
//   //         "Hogtie": true,
//   //         "KneelClosed": true
//   //       },
//   //       "InheritColor": "Cloth"
//   //     },
//   //     "LegRimLeft": {
//   //       "Name": "LegRimLeft",
//   //       "Layer": "StockingLeft",
//   //       "Pri": -0.9,
//   //       "Poses": {
//   //         "Spread": true,
//   //         "Closed": true,
//   //         "Kneel": true,
//   //         "KneelClosed": true,
//   //         "Hogtie": true
//   //       },
//   //       "GlobalDefaultOverride": {
//   //         "Hogtie": true,
//   //         "KneelClosed": true
//   //       },
//   //       "NoOverride": true,
//   //       "TieToLayer": "LegLeft",
//   //       "InheritColor": "Rim"
//   //     },
//   //     "LegBandLeft": {
//   //       "Name": "LegBandLeft",
//   //       "Layer": "StockingLeft",
//   //       "Pri": -0.8,
//   //       "Poses": {
//   //         "Spread": true,
//   //         "Closed": true,
//   //         "Kneel": true,
//   //         "KneelClosed": true,
//   //         "Hogtie": true
//   //       },
//   //       "GlobalDefaultOverride": {
//   //         "Hogtie": true,
//   //         "KneelClosed": true
//   //       },
//   //       "NoOverride": true,
//   //       "TieToLayer": "LegLeft",
//   //       "InheritColor": "Band"
//   //     },
//   //     "LegPadsLeft": {
//   //       "Name": "LegPadsLeft",
//   //       "Layer": "StockingLeft",
//   //       "Pri": -0.9,
//   //       "Poses": {
//   //         "Spread": true,
//   //         "Closed": true,
//   //         "Kneel": true,
//   //         "KneelClosed": true,
//   //         "Hogtie": true
//   //       },
//   //       "GlobalDefaultOverride": {
//   //         "Hogtie": true,
//   //         "KneelClosed": true
//   //       },
//   //       "NoOverride": true,
//   //       "TieToLayer": "LegLeft",
//   //       "InheritColor": "Pads"
//   //     }
//   //   },
//   //   "Properties": {
//   //     "Cloth": {
//   //       "LayerBonus": 15000
//   //     }
//   //   }
//   // },
//   //
//   // {
//   // 	"Lost": false,
//   //   "Item": "WolfGloveLeft",
//   //   "Group": "WolfCatsuit",
//   //   "Parent": "Wolf",
//   //   "Categories": [
//   //     "Gloves"
//   //     ],
//   //   "Layers": {
//   //     "GloveLeft": {
//   //       "Name": "GloveLeft",
//   //       "Layer": "GloveLeft",
//   //       "Pri": -1,
//   //       "Poses": {
//   //         "Free": true,
//   //         "Boxtie": true,
//   //         "Wristtie": true,
//   //         "Yoked": true,
//   //         "Front": true,
//   //         "Up": true,
//   //         "Crossed": true
//   //       },
//   //       "GlobalDefaultOverride": {
//   //         "Front": true,
//   //         "Crossed": true
//   //       }
//   //     },
//   //     "ForeGloveLeft": {
//   //       "Name": "ForeGloveLeft",
//   //       "Layer": "ForeGloveLeft",
//   //       "Pri": -1,
//   //       "Poses": {
//   //         "Front": true,
//   //         "Crossed": true
//   //       },
//   //       "InheritColor": "GloveLeft",
//   //       "GlobalDefaultOverride": {
//   //         "Front": true,
//   //         "Crossed": true
//   //       },
//   //       "SwapLayerPose": {
//   //         "Crossed": "CrossGloveLeft"
//   //       }
//   //     },
//   //     "RimGloveLeft": {
//   //       "Name": "RimGloveLeft",
//   //       "Layer": "GloveLeft",
//   //       "Pri": -0.9,
//   //       "Poses": {
//   //         "Free": true,
//   //         "Boxtie": true,
//   //         "Wristtie": true,
//   //         "Yoked": true,
//   //         "Front": true,
//   //         "Up": true,
//   //         "Crossed": true
//   //       },
//   //       "InheritColor": "RimLeft",
//   //       "NoOverride": true,
//   //       "GlobalDefaultOverride": {
//   //         "Front": true,
//   //         "Crossed": true
//   //       }
//   //     },
//   //     "RimForeGloveLeft": {
//   //       "Name": "RimForeGloveLeft",
//   //       "Layer": "ForeGloveLeft",
//   //       "Pri": -0.9,
//   //       "Poses": {
//   //         "Front": true,
//   //         "Crossed": true
//   //       },
//   //       "InheritColor": "RimLeft",
//   //       "NoOverride": true,
//   //       "GlobalDefaultOverride": {
//   //         "Front": true,
//   //         "Crossed": true
//   //       },
//   //       "SwapLayerPose": {
//   //         "Crossed": "CrossGloveLeft"
//   //       }
//   //     },
//   //     "BandGloveLeft": {
//   //       "Name": "BandGloveLeft",
//   //       "Layer": "GloveLeft",
//   //       "Pri": -0.8,
//   //       "Poses": {
//   //         "Free": true,
//   //         "Boxtie": true,
//   //         "Wristtie": true,
//   //         "Yoked": true,
//   //         "Front": true,
//   //         "Up": true,
//   //         "Crossed": true
//   //       },
//   //       "InheritColor": "BandLeft",
//   //       "NoOverride": true,
//   //       "GlobalDefaultOverride": {
//   //         "Front": true,
//   //         "Crossed": true
//   //       }
//   //     },
//   //     "BandForeGloveLeft": {
//   //       "Name": "BandForeGloveLeft",
//   //       "Layer": "ForeGloveLeft",
//   //       "Pri": -0.8,
//   //       "Poses": {
//   //         "Front": true,
//   //         "Crossed": true
//   //       },
//   //       "InheritColor": "BandLeft",
//   //       "NoOverride": true,
//   //       "GlobalDefaultOverride": {
//   //         "Front": true,
//   //         "Crossed": true
//   //       },
//   //       "SwapLayerPose": {
//   //         "Crossed": "CrossGloveLeft"
//   //       }
//   //     }
//   //   }
//   // },
//   //
// ]

// KDModelHair['WolfgirlRavHair'] = [
// 	{
//     "Item": "MessyBack",
//     "Group": "Hair",
//     "TopLevel": true,
//     "Protected": true,
//     "Categories": [
//       "Hairstyles",
//       "BackHair"
//       ],
//     "Layers": {
//       "Messy": {
//         "Name": "Messy",
//         "Layer": "HairBack",
//         "Pri": 0
//       }
//     },
//     "Filters": {
//       "Messy": {
//         "gamma": 1,
//         "saturation": 0,
//         "contrast": 0.98,
//         "brightness": 1,
//         "red": 0.9215686274509803,
//         "green": 1,
//         "blue": 1.3529411764705883,
//         "alpha": 1
//       }
//     }
//   },
//   // Might not belong here
//   {
//     "Item": "FoxEars",
//     "Group": "Ears",
//     "Parent": "Fox",
//     "TopLevel": true,
//     "Protected": true,
//     "Categories": [
//       "Ears",
//       "Fox",
//       "Face",
//       "Cosplay"
//       ],
//     "AddPose": [
//       "AnimalEars",
//       "Fox",
//       "Cosplay"
//       ],
//     "Layers": {
//       "Fox": {
//         "Name": "Fox",
//         "Layer": "AnimalEars",
//         "Pri": 10,
//         "Invariant": true,
//         "InheritColor": "Ears"
//       },
//       "FoxInner": {
//         "Name": "FoxInner",
//         "Layer": "AnimalEars",
//         "Pri": 10.1,
//         "Invariant": true,
//         "TieToLayer": "Fox",
//         "NoOverride": true,
//         "InheritColor": "InnerEars"
//       }
//     },
//     "Filters": {
//       "Ears": {
//         "gamma": 1,
//         "saturation": 0,
//         "contrast": 0.98,
//         "brightness": 1,
//         "red": 0.9607843137254902,
//         "green": 1.0588235294117647,
//         "blue": 1.4313725490196079,
//         "alpha": 1
//       }
//     },
//     "Properties": {
//       "Ears": {
//         "Rotation": 5,
//         "XOffset": 40,
//         "YOffset": -100
//       },
//       "InnerEars": {
//         "Rotation": 5,
//         "XOffset": 40,
//         "YOffset": -100
//       }
//     }
//   },
//   {
//     "Item": "Straight",
//     "Group": "Hair",
//     "TopLevel": true,
//     "Protected": true,
//     "Categories": [
//       "Hairstyles",
//       "FrontHair"
//       ],
//     "AddPose": [
//       "Hair"
//       ],
//     "Layers": {
//       "Straight": {
//         "Name": "Straight",
//         "Layer": "Hair",
//         "Pri": 0,
//         "SwapLayerPose": {
//           "HoodMask": "HairOver"
//         }
//       },
//       "Straight_Overstrap": {
//         "Name": "Straight_Overstrap",
//         "Layer": "HairFront",
//         "Pri": 0,
//         "InheritColor": "Straight"
//       }
//     },
//     "Filters": {
//       "Straight": {
//         "gamma": 1,
//         "saturation": 0,
//         "contrast": 0.98,
//         "brightness": 1,
//         "red": 0.9215686274509803,
//         "green": 1,
//         "blue": 1.3529411764705883,
//         "alpha": 1
//       }
//     }
//   },
// ]

// KDModelBody['WolfgirlRavBody'] = [
// 	{
//     "Item": "Body",
//     "Group": "Body",
//     "TopLevel": true,
//     "Protected": true,
//     "Categories": [
//       "Body"
//       ],
//     "Folder": "Body",
//     "AddPose": [
//       "Body"
//       ],
//     "Layers": {
//       "Head": {
//         "Name": "Head",
//         "Layer": "Head",
//         "Pri": 0,
//         "MorphPoses": {
//           "AnimalEars": "NoEar",
//           "HideEars": "NoEar"
//         },
//         "AppendPose": {
//           "FaceCoverGag": "",
//           "FaceBigGag": "BigGag",
//           "FaceGag": "Gag"
//         }
//       },
//       "ArmRight": {
//         "Name": "ArmRight",
//         "Layer": "ArmRight",
//         "Pri": 0,
//         "HideWhenOverridden": true,
//         "InheritColor": "Torso",
//         "Poses": {
//           "Free": true,
//           "Boxtie": true,
//           "Wristtie": true,
//           "Yoked": true,
//           "Front": true,
//           "Up": true,
//           "Crossed": true
//         },
//         "GlobalDefaultOverride": {
//           "Front": true,
//           "Crossed": true
//         }
//       },
//       "ArmLeft": {
//         "Name": "ArmLeft",
//         "Layer": "ArmLeft",
//         "Pri": 0,
//         "HideWhenOverridden": true,
//         "InheritColor": "Torso",
//         "Poses": {
//           "Free": true,
//           "Boxtie": true,
//           "Wristtie": true,
//           "Yoked": true,
//           "Front": true,
//           "Up": true,
//           "Crossed": true
//         },
//         "GlobalDefaultOverride": {
//           "Front": true,
//           "Crossed": true
//         },
//         "ErasePoses": [
//           "HideHands"
//           ],
//         "EraseLayers": {
//           "RightHand": true
//         },
//         "EraseSprite": "HideBoxtieHand",
//         "EraseInvariant": true
//       },
//       "ShoulderRight": {
//         "Name": "ShoulderRight",
//         "Layer": "ShoulderRight",
//         "Pri": 0,
//         "HideWhenOverridden": true,
//         "InheritColor": "Torso",
//         "Poses": {
//           "Up": true
//         }
//       },
//       "ShoulderLeft": {
//         "Name": "ShoulderLeft",
//         "Layer": "ShoulderLeft",
//         "Pri": 0,
//         "HideWhenOverridden": true,
//         "InheritColor": "Torso",
//         "Poses": {
//           "Up": true
//         }
//       },
//       "ForeArmRight": {
//         "Name": "ForeArmRight",
//         "Layer": "ForeArmRight",
//         "Pri": 0,
//         "HideWhenOverridden": true,
//         "InheritColor": "Torso",
//         "Poses": {
//           "Front": true,
//           "Crossed": true
//         },
//         "GlobalDefaultOverride": {
//           "Front": true,
//           "Crossed": true
//         },
//         "SwapLayerPose": {
//           "Crossed": "CrossArmRight"
//         }
//       },
//       "ForeArmLeft": {
//         "Name": "ForeArmLeft",
//         "Layer": "ForeArmLeft",
//         "Pri": 0,
//         "HideWhenOverridden": true,
//         "InheritColor": "Torso",
//         "Poses": {
//           "Front": true,
//           "Crossed": true
//         },
//         "GlobalDefaultOverride": {
//           "Front": true,
//           "Crossed": true
//         },
//         "SwapLayerPose": {
//           "Crossed": "CrossArmLeft"
//         }
//       },
//       "HandRight": {
//         "Name": "HandRight",
//         "Layer": "HandRight",
//         "Pri": 0,
//         "HideWhenOverridden": true,
//         "InheritColor": "Torso",
//         "Poses": {
//           "Free": true,
//           "Boxtie": true,
//           "Yoked": true
//         },
//         "GlobalDefaultOverride": {
//           "Front": true
//         },
//         "HidePoses": {
//           "HideHands": true,
//           "EncaseHandRight": true
//         }
//       },
//       "HandLeft": {
//         "Name": "HandLeft",
//         "Layer": "HandLeft",
//         "Pri": 0,
//         "HideWhenOverridden": true,
//         "InheritColor": "Torso",
//         "Poses": {
//           "Free": true,
//           "Yoked": true
//         },
//         "GlobalDefaultOverride": {
//           "Front": true
//         },
//         "HidePoses": {
//           "HideHands": true,
//           "EncaseHandLeft": true
//         }
//       },
//       "ForeHandRight": {
//         "Name": "ForeHandRight",
//         "Layer": "ForeHandRight",
//         "Pri": 0,
//         "HideWhenOverridden": true,
//         "Sprite": "HandRight",
//         "InheritColor": "Torso",
//         "Poses": {
//           "Front": true
//         },
//         "GlobalDefaultOverride": {
//           "Front": true
//         },
//         "HidePoses": {
//           "HideHands": true,
//           "EncaseHandRight": true
//         }
//       },
//       "ForeHandLeft": {
//         "Name": "ForeHandLeft",
//         "Layer": "ForeHandLeft",
//         "Pri": 0,
//         "HideWhenOverridden": true,
//         "Sprite": "HandLeft",
//         "InheritColor": "Torso",
//         "Poses": {
//           "Front": true
//         },
//         "GlobalDefaultOverride": {
//           "Front": true
//         },
//         "HidePoses": {
//           "HideHands": true,
//           "EncaseHandLeft": true
//         }
//       },
//       "LegLeft": {
//         "Name": "LegLeft",
//         "Layer": "LegLeft",
//         "Pri": 0,
//         "HideWhenOverridden": true,
//         "InheritColor": "Torso",
//         "Poses": {
//           "Spread": true,
//           "Closed": true,
//           "Kneel": true,
//           "KneelClosed": true,
//           "Hogtie": true
//         },
//         "GlobalDefaultOverride": {
//           "Hogtie": true,
//           "KneelClosed": true
//         }
//       },
//       "Torso": {
//         "Name": "Torso",
//         "Layer": "Torso",
//         "Pri": 0,
//         "InheritColor": "Torso",
//         "MorphPoses": {
//           "Closed": "Closed",
//           "Spread": "Spread",
//           "Hogtie": "Closed"
//         },
//         "EraseLayers": {
//           "BustierPoses": true
//         },
//         "EraseSprite": "EraseCorset",
//         "EraseInvariant": true,
//         "EraseZBonus": 1000
//       },
//       "Chest": {
//         "Name": "Chest",
//         "Layer": "Chest",
//         "Pri": 0,
//         "HideWhenOverridden": true,
//         "InheritColor": "Torso"
//       },
//       "FootRightKneel": {
//         "Name": "FootRightKneel",
//         "Sprite": "FootRight",
//         "Layer": "FootRightKneel",
//         "Pri": 0,
//         "HideWhenOverridden": true,
//         "InheritColor": "Torso",
//         "HidePoses": {
//           "FeetLinked": true,
//           "FeetCovered": true
//         },
//         "Poses": {
//           "Kneel": true
//         }
//       },
//       "FootLeftHogtie": {
//         "Name": "FootLeftHogtie",
//         "Layer": "FootLeftHogtie",
//         "Pri": 0,
//         "HideWhenOverridden": true,
//         "InheritColor": "Torso",
//         "Poses": {
//           "Hogtie": true
//         },
//         "MorphPoses": {
//           "Hogtie": ""
//         }
//       },
//       "LegRight": {
//         "Name": "LegRight",
//         "Layer": "LegRight",
//         "Pri": 0,
//         "HideWhenOverridden": true,
//         "InheritColor": "Torso",
//         "Poses": {
//           "Spread": true,
//           "Closed": true,
//           "Kneel": true,
//           "KneelClosed": true,
//           "Hogtie": true
//         },
//         "GlobalDefaultOverride": {
//           "Hogtie": true,
//           "KneelClosed": true
//         }
//       },
//       "Butt": {
//         "Name": "Butt",
//         "Layer": "Butt",
//         "Pri": 0,
//         "InheritColor": "Torso",
//         "Poses": {
//           "Kneel": true,
//           "KneelClosed": true
//         },
//         "EraseLayers": {
//           "BustierPoses2": true
//         },
//         "EraseSprite": "EraseCorsetKneel",
//         "EraseInvariant": true,
//         "EraseZBonus": 1000
//       },
//       "Butt2": {
//         "Name": "Butt2",
//         "Layer": "Butt",
//         "Pri": 0,
//         "InheritColor": "Torso",
//         "Poses": {
//           "Kneel": true,
//           "KneelClosed": true
//         },
//         "EraseLayers": {
//           "ButtSleeves": true
//         },
//         "EraseSprite": "ButtSleeves",
//         "EraseZBonus": 1000,
//         "EraseInvariant": true,
//         "Invariant": true
//       },
//       "Nipples": {
//         "Name": "Nipples",
//         "Layer": "Nipples",
//         "Pri": 0,
//         "HideWhenOverridden": true,
//         "InheritColor": "Nipples",
//         "Invariant": true,
//         "HidePoses": {
//           "HideNipples": true
//         }
//       }
//     },
//     "Filters": {
//       "Head": {
//         "gamma": 1,
//         "saturation": 0,
//         "contrast": 1.76,
//         "brightness": 1,
//         "red": 0.8627450980392157,
//         "green": 0.6470588235294118,
//         "blue": 0.5686274509803921,
//         "alpha": 1
//       },
//       "Torso": {
//         "gamma": 1,
//         "saturation": 0,
//         "contrast": 1.76,
//         "brightness": 1,
//         "red": 0.8627450980392157,
//         "green": 0.6470588235294118,
//         "blue": 0.5686274509803921,
//         "alpha": 1
//       },
//       "Nipples": {
//         "gamma": 1,
//         "saturation": 0,
//         "contrast": 1,
//         "brightness": 1,
//         "red": 0.23529411764705882,
//         "green": 0.23529411764705882,
//         "blue": 0.21568627450980393,
//         "alpha": 1
//       }
//     }
//   },
//   // Might not belong here
//   {
//     "Item": "WolfTail",
//     "Group": "Tails",
//     "Parent": "Wolf",
//     "TopLevel": true,
//     "Protected": true,
//     "Categories": [
//       "Tails",
//       "Wolf",
//       "Cosplay"
//       ],
//     "AddPose": [
//       "Tails",
//       "Wolf",
//       "Cosplay"
//       ],
//     "Layers": {
//       "Wolf": {
//         "Name": "Wolf",
//         "Layer": "Tail",
//         "Pri": 0,
//         "Invariant": true,
//         "InheritColor": "Tail"
//       }
//     }
//   },
// ]

// KDModelFace['WolfgirlRavFace'] = [
// 	{
//     "Item": "KjusBrows",
//     "Group": "FaceKjus",
//     "TopLevel": true,
//     "Protected": true,
//     "Categories": [
//       "Eyes",
//       "Face"
//       ],
//     "Layers": {
//       "Brows": {
//         "Name": "Brows",
//         "Layer": "Brows",
//         "Pri": 0,
//         "Sprite": "",
//         "Poses": {
//           "BrowsNeutral": true,
//           "BrowsAngry": true,
//           "BrowsAnnoyed": true,
//           "BrowsSad": true,
//           "BrowsSurprised": true
//         },
//         "HidePoses": {
//           "EncaseHead": true
//         }
//       },
//       "Brows2": {
//         "Name": "Brows2",
//         "Layer": "Brows",
//         "Pri": 0,
//         "Sprite": "",
//         "Poses": {
//           "Brows2Neutral": true,
//           "Brows2Angry": true,
//           "Brows2Annoyed": true,
//           "Brows2Sad": true,
//           "Brows2Surprised": true
//         },
//         "HidePoses": {
//           "EncaseHead": true
//         }
//       }
//     }
//   },
//   {
//     "Item": "KjusBlush",
//     "Group": "FaceKjus",
//     "TopLevel": true,
//     "Protected": true,
//     "Categories": [
//       "Face"
//       ],
//     "Layers": {
//       "Blush": {
//         "Name": "Blush",
//         "Layer": "Blush",
//         "Pri": 0,
//         "Sprite": "",
//         "Poses": {
//           "BlushLow": true,
//           "BlushMedium": true,
//           "BlushHigh": true,
//           "BlushExtreme": true
//         }
//       }
//     }
//   },
//   {
//     "Item": "KjusMouth",
//     "Group": "FaceKjus",
//     "TopLevel": true,
//     "Protected": true,
//     "Group": "Mouth",
//     "Categories": [
//       "Mouth",
//       "Face"
//       ],
//     "Layers": {
//       "Mouth": {
//         "Name": "Mouth",
//         "Layer": "Mouth",
//         "Pri": 0,
//         "Sprite": "",
//         "Poses": {
//           "MouthNeutral": true,
//           "MouthDazed": true,
//           "MouthDistracted": true,
//           "MouthEmbarrassed": true,
//           "MouthFrown": true,
//           "MouthSmile": true,
//           "MouthSurprised": true,
//           "MouthPout": true
//         },
//         "HidePoses": {
//           "HideMouth": true
//         }
//       }
//     }
//   },
//   {
//     "Item": "KjusEyes",
//     "Group": "FaceKjus",
//     "TopLevel": true,
//     "Protected": true,
//     "Categories": [
//       "Eyes",
//       "Face"
//       ],
//     "AddPose": [
//       "Eyes"
//       ],
//     "Layers": {
//       "Eyes": {
//         "Name": "Eyes",
//         "Layer": "Eyes",
//         "Pri": 0,
//         "Sprite": "",
//         "Poses": {
//           "EyesNeutral": true,
//           "EyesSurprised": true,
//           "EyesDazed": true,
//           "EyesClosed": true,
//           "EyesAngry": true,
//           "EyesSly": true,
//           "EyesHeart": true
//         }
//       },
//       "Eyes2": {
//         "Name": "Eyes2",
//         "Layer": "Eyes",
//         "Pri": 0,
//         "Sprite": "",
//         "Poses": {
//           "Eyes2Neutral": true,
//           "Eyes2Surprised": true,
//           "Eyes2Dazed": true,
//           "Eyes2Closed": true,
//           "Eyes2Angry": true,
//           "Eyes2Sly": true,
//           "Eyes2Heart": true
//         }
//       },
//       "Whites": {
//         "Name": "Whites",
//         "Layer": "Eyes",
//         "Pri": -1,
//         "NoColorize": true,
//         "Poses": {
//           "EyesNeutral": true,
//           "EyesSurprised": true,
//           "EyesDazed": true,
//           "EyesClosed": true,
//           "EyesAngry": true,
//           "EyesSly": true,
//           "EyesHeart": true
//         }
//       },
//       "Whites2": {
//         "Name": "Whites2",
//         "Layer": "Eyes",
//         "Pri": -1,
//         "Sprite": "Whites",
//         "NoColorize": true,
//         "Poses": {
//           "Eyes2Neutral": true,
//           "Eyes2Surprised": true,
//           "Eyes2Dazed": true,
//           "Eyes2Closed": true,
//           "Eyes2Angry": true,
//           "Eyes2Sly": true,
//           "Eyes2Heart": true
//         }
//       }
//     },
//     "Filters": {
//       "Eyes": {
//         "gamma": 0.8500000000000001,
//         "saturation": 0.43333333333333335,
//         "contrast": 1,
//         "brightness": 1,
//         "red": 2.6862745098039214,
//         "green": 2.843137254901961,
//         "blue": 4.607843137254902,
//         "alpha": 1
//       },
//       "Eyes2": {
//         "gamma": 0.8500000000000001,
//         "saturation": 0.43333333333333335,
//         "contrast": 1,
//         "brightness": 1,
//         "red": 2.6862745098039214,
//         "green": 2.843137254901961,
//         "blue": 4.607843137254902,
//         "alpha": 1
//       }
//     }
//   },
// ]


KDModelDresses['WolfgirlRavDresses'] = [
  // {
  //   "Item": "WolfCollarSmallTag",
  //   "Group": "Wolf",
  // },
  // {
  //   "Item": "WolfHeels",
  //   "Group": "WolfCatsuit",
  // },
  // {
  //   "Item": "WolfTorsoUpper",
  //   "Group": "WolfCatsuit",
  // },
  // {
  //   "Item": "WolfSocks",
  //   "Group": "WolfCatsuit",
  //   "Properties": {
  //     "Cloth": {
  //       "LayerBonus": 15000
  //     }
  //   }
  // },
  // {
  //   "Item": "WolfGloveLeft",
  //   "Group": "WolfCatsuit",
  // },
  {
    "Item": "CyberPanties",
    "Group": "Chastity",
    "Filters": {
      "Lining": {
        "gamma": 1.0166666666666666,
        "saturation": 0,
        "contrast": 0.88,
        "brightness": 1,
        "red": 0.11764705882352941,
        "green": 0.11764705882352941,
        "blue": 0.11764705882352941,
        "alpha": 0.9833333333333333
      }
    }
  },
  {
    "Item": "VBikini",
    "Group": "Swimsuit",
    "Filters": {
      "VBikini": {
        "gamma": 1,
        "saturation": 0,
        "contrast": 1,
        "brightness": 1,
        "red": 0.29411764705882354,
        "green": 0.29411764705882354,
        "blue": 0.27450980392156865,
        "alpha": 1
      }
    },
    "Properties": {
      "VBikini": {
        "YScale": 0.6,
        "YOffset": 700,
        "XScale": 1.11,
        "XOffset": -120,
        "LayerBonus": -100
      }
    }
  },
  {
    "Item": "ElfPanties",
    "Group": "Elf",
    "Properties": {
      "Panties": {
        "YOffset": 25,
        "LayerBonus": -8000
      }
    }
  },
  {
    "Item": "LatexWhip",
    "Group": "Weapon",
    "Filters": {
      "LatexWhip": {
        "gamma": 1,
        "saturation": 0,
        "contrast": 1.27,
        "brightness": 1,
        "red": 0,
        "green": 0.5098039215686274,
        "blue": 0.058823529411764705,
        "alpha": 1
      }
    }
  },
  {
    "Item": "WolfgirlAlpha",
    "Group": "WolfCatsuit",
  },
  //
  {
    "Item": "FoxEars",
    "Group": "Ears",
    "Filters": {
      "Ears": {
        "gamma": 1,
        "saturation": 0,
        "contrast": 2.24,
        "brightness": 1,
        "red": 0.29411764705882354,
        "green": 0.29411764705882354,
        "blue": 0.5686274509803921,
        "alpha": 1
      },
      "Fox": {
        "gamma": 1,
        "saturation": 0,
        "contrast": 2.24,
        "brightness": 1,
        "red": 0.29411764705882354,
        "green": 0.29411764705882354,
        "blue": 0.5686274509803921,
        "alpha": 1
      },
      "InnerEars": {
        "gamma": 1,
        "saturation": 0,
        "contrast": 2.24,
        "brightness": 1,
        "red": 0.058823529411764705,
        "green": 0.058823529411764705,
        "blue": 0.13725490196078433,
        "alpha": 1
      }
    },
    "Properties": {
      "Ears": {
        "Rotation": 5,
        "XOffset": 40,
        "YOffset": -100
      },
      "InnerEars": {
        "Rotation": 5,
        "XOffset": 40,
        "YOffset": -100
      }
    }
  },
  // {
  //   "Item": "RavLargeHeartHairpin",
  //   "Group": "Hair",
  //   "Filters": {
  //     "LargeHeartHairpin": {
  //       "gamma": 1,
  //       "saturation": 0,
  //       "contrast": 1,
  //       "brightness": 1,
  //       "red": 0.6470588235294118,
  //       "green": 0,
  //       "blue": 2,
  //       "alpha": 1
  //     }
  //   },
  //   "Properties": {
  //     "LargeHeartHairpin": {
  //       "XScale": 1.8,
  //       "XOffset": -950,
  //       "YScale": 1.8,
  //       "YOffset": -330
  //     }
  //   }
  // },
  // {
  //   "Item": "FoxEars",
  //   "Group": "Ears",
  //   "Filters": {
  //     "Ears": {
  //       "gamma": 1,
  //       "saturation": 0,
  //       "contrast": 2.24,
  //       "brightness": 1,
  //       "red": 0.29411764705882354,
  //       "green": 0.29411764705882354,
  //       "blue": 0.5686274509803921,
  //       "alpha": 1
  //     },
  //     "Fox": {
  //       "gamma": 1,
  //       "saturation": 0,
  //       "contrast": 2.24,
  //       "brightness": 1,
  //       "red": 0.29411764705882354,
  //       "green": 0.29411764705882354,
  //       "blue": 0.5686274509803921,
  //       "alpha": 1
  //     },
  //     "InnerEars": {
  //       "gamma": 1,
  //       "saturation": 0,
  //       "contrast": 2.24,
  //       "brightness": 1,
  //       "red": 0.058823529411764705,
  //       "green": 0.058823529411764705,
  //       "blue": 0.13725490196078433,
  //       "alpha": 1
  //     }
  //   },
  //   "Properties": {
  //     "Ears": {
  //       "Rotation": 5,
  //       "XOffset": 40,
  //       "YOffset": -100
  //     },
  //     "InnerEars": {
  //       "Rotation": 5,
  //       "XOffset": 40,
  //       "YOffset": -100
  //     }
  //   }
  // },
  {
    "Item": "WolfTail",
    "Group": "Tails",
    "Filters": {
      "Tail": {
        "gamma": 1,
        "saturation": 0,
        "contrast": 2.24,
        "brightness": 1,
        "red": 0.19607843137254902,
        "green": 0.19607843137254902,
        "blue": 0.43137254901960786,
        "alpha": 1
      }
    }
  },
]

KDModelCosplay['WolfgirlRavCosplay'] = [
  // {
  //   "Item": "WolfCollarSmallTag",
  //   "Group": "Wolf",
  // },
  // {
  //   "Item": "WolfHeels",
  //   "Group": "WolfCatsuit",
  // },
  // {
  //   "Item": "WolfTorsoUpper",
  //   "Group": "WolfCatsuit",
  // },
  // {
  //   "Item": "WolfSocks",
  //   "Group": "WolfCatsuit",
  //   "Properties": {
  //     "Cloth": {
  //       "LayerBonus": 15000
  //     }
  //   }
  // },
  // {
  //   "Item": "WolfGloveLeft",
  //   "Group": "WolfCatsuit",
  // },
  {
    "Item": "CyberPanties",
    "Group": "Chastity",
    "Filters": {
      "Lining": {
        "gamma": 1.0166666666666666,
        "saturation": 0,
        "contrast": 0.88,
        "brightness": 1,
        "red": 0.11764705882352941,
        "green": 0.11764705882352941,
        "blue": 0.11764705882352941,
        "alpha": 0.9833333333333333
      }
    }
  },
  {
    "Item": "VBikini",
    "Group": "Swimsuit",
    "Filters": {
      "VBikini": {
        "gamma": 1,
        "saturation": 0,
        "contrast": 1,
        "brightness": 1,
        "red": 0.29411764705882354,
        "green": 0.29411764705882354,
        "blue": 0.27450980392156865,
        "alpha": 1
      }
    },
    "Properties": {
      "VBikini": {
        "YScale": 0.6,
        "YOffset": 700,
        "XScale": 1.11,
        "XOffset": -120,
        "LayerBonus": -100
      }
    }
  },
  {
    "Item": "ElfPanties",
    "Group": "Elf",
    "Properties": {
      "Panties": {
        "YOffset": 25,
        "LayerBonus": -8000
      }
    }
  },
  {
    "Item": "LatexWhip",
    "Group": "Weapon",
    "Filters": {
      "LatexWhip": {
        "gamma": 1,
        "saturation": 0,
        "contrast": 1.27,
        "brightness": 1,
        "red": 0,
        "green": 0.5098039215686274,
        "blue": 0.058823529411764705,
        "alpha": 1
      }
    }
  },
  //
  {
    "Item": "WolfgirlAlpha",
    "Group": "WolfgirlAlpha",
  },
  //
  {
    "Item": "FoxEars",
    "Group": "Ears",
    "Filters": {
      "Ears": {
        "gamma": 1,
        "saturation": 0,
        "contrast": 2.24,
        "brightness": 1,
        "red": 0.29411764705882354,
        "green": 0.29411764705882354,
        "blue": 0.5686274509803921,
        "alpha": 1
      },
      "Fox": {
        "gamma": 1,
        "saturation": 0,
        "contrast": 2.24,
        "brightness": 1,
        "red": 0.29411764705882354,
        "green": 0.29411764705882354,
        "blue": 0.5686274509803921,
        "alpha": 1
      },
      "InnerEars": {
        "gamma": 1,
        "saturation": 0,
        "contrast": 2.24,
        "brightness": 1,
        "red": 0.058823529411764705,
        "green": 0.058823529411764705,
        "blue": 0.13725490196078433,
        "alpha": 1
      }
    },
    "Properties": {
      "Ears": {
        "Rotation": 5,
        "XOffset": 40,
        "YOffset": -100
      },
      "InnerEars": {
        "Rotation": 5,
        "XOffset": 40,
        "YOffset": -100
      }
    }
  },
  {
    "Item": "WolfTail",
    "Group": "Tails",
    "Filters": {
      "Tail": {
        "gamma": 1,
        "saturation": 0,
        "contrast": 2.24,
        "brightness": 1,
        "red": 0.19607843137254902,
        "green": 0.19607843137254902,
        "blue": 0.43137254901960786,
        "alpha": 1
      }
    }
  },
]
// KDModelCosplay['WolfgirlRavEars'] = [
//   {
//     "Item": "FoxEars",
//     "Group": "Ears",
//     "Filters": {
//       "Ears": {
//         "gamma": 1,
//         "saturation": 0,
//         "contrast": 2.24,
//         "brightness": 1,
//         "red": 0.29411764705882354,
//         "green": 0.29411764705882354,
//         "blue": 0.5686274509803921,
//         "alpha": 1
//       },
//       "Fox": {
//         "gamma": 1,
//         "saturation": 0,
//         "contrast": 2.24,
//         "brightness": 1,
//         "red": 0.29411764705882354,
//         "green": 0.29411764705882354,
//         "blue": 0.5686274509803921,
//         "alpha": 1
//       },
//       "InnerEars": {
//         "gamma": 1,
//         "saturation": 0,
//         "contrast": 2.24,
//         "brightness": 1,
//         "red": 0.058823529411764705,
//         "green": 0.058823529411764705,
//         "blue": 0.13725490196078433,
//         "alpha": 1
//       }
//     },
//     "Properties": {
//       "Ears": {
//         "Rotation": 5,
//         "XOffset": 40,
//         "YOffset": -100
//       },
//       "InnerEars": {
//         "Rotation": 5,
//         "XOffset": 40,
//         "YOffset": -100
//       }
//     }
//   },
// ]

KDModelHair['WolfgirlRavHair'] = [
  {
    "Item": "MessyBack",
    "Group": "Hair",
    "Filters": {
      "Messy": {
        "gamma": 1,
        "saturation": 0,
        "contrast": 2.24,
        "brightness": 1,
        "red": 0.29411764705882354,
        "green": 0.29411764705882354,
        "blue": 0.5686274509803921,
        "alpha": 1
      }
    }
  },
  {
    "Item": "Straight",
    "Group": "Hair",
    "Filters": {
      "Straight": {
        "gamma": 1,
        "saturation": 0,
        "contrast": 2.24,
        "brightness": 1,
        "red": 0.29411764705882354,
        "green": 0.29411764705882354,
        "blue": 0.5686274509803921,
        "alpha": 1
      }
    }
  },
  {
    "Item": "RavLargeHeartHairpin",
    "Group": "Hair",
    "Filters": {
      "LargeHeartHairpin": {
        "gamma": 1,
        "saturation": 0,
        "contrast": 1,
        "brightness": 1,
        "red": 0.6470588235294118,
        "green": 0,
        "blue": 2,
        "alpha": 1
      }
    },
    "Properties": {
      "LargeHeartHairpin": {
        "XScale": 1.8,
        "XOffset": -950,
        "YScale": 1.8,
        "YOffset": -330
      }
    }
  },
]

KDModelBody['WolfgirlRavBody'] = [
  {
    "Item": "Body",
    "Group": "Body",
    "Filters": {
      "Head": {
        "gamma": 1,
        "saturation": 0,
        "contrast": 1.76,
        "brightness": 1,
        "red": 0.8627450980392157,
        "green": 0.6470588235294118,
        "blue": 0.5686274509803921,
        "alpha": 1
      },
      "Torso": {
        "gamma": 1,
        "saturation": 0,
        "contrast": 1.76,
        "brightness": 1,
        "red": 0.8627450980392157,
        "green": 0.6470588235294118,
        "blue": 0.5686274509803921,
        "alpha": 1
      },
      "Nipples": {
        "gamma": 1,
        "saturation": 0,
        "contrast": 1,
        "brightness": 1,
        "red": 0.23529411764705882,
        "green": 0.23529411764705882,
        "blue": 0.21568627450980393,
        "alpha": 1
      }
    }
  },
]

KDModelFace['WolfgirlRavFace'] = [
  {
    "Item": "Fear",
    "Group": "Expressions",
  },
  {
    "Item": "KjusBrows",
    "Group": "FaceKjus",
  },
  {
    "Item": "KjusBlush",
    "Group": "FaceKjus",
  },
  {
    "Item": "KjusMouth",
    "Group": "FaceKjus",
  },
  {
    "Item": "KjusEyes",
    "Group": "FaceKjus",
    "Filters": {
      "Eyes2": {
        "gamma": 0.8500000000000001,
        "saturation": 0.43333333333333335,
        "contrast": 1,
        "brightness": 1,
        "red": 2.6862745098039214,
        "green": 2.843137254901961,
        "blue": 4.607843137254902,
        "alpha": 1
      },
      "Eyes": {
        "gamma": 0.8500000000000001,
        "saturation": 0.43333333333333335,
        "contrast": 1,
        "brightness": 1,
        "red": 2.6862745098039214,
        "green": 2.843137254901961,
        "blue": 4.607843137254902,
        "alpha": 1
      }
    }
  },
]


KDModelStyles['WolfgirlRavStyle'] = {
	Cosplay: [ 'WolfgirlRavCosplay' ],
	Hairstyle: [ 'WolfgirlRavHair' ],
	Bodystyle: [ 'WolfgirlRavBody' ],
	Facestyle: [ 'WolfgirlRavFace' ],
}

/**********************************************
 * Enemy definition: NEVERMERE ALPHA
	A wolfgirl clone, that...
	- Has a special attack that applies the ravage "effect"
		- Will equip a collar, then a leash, if none are equipped.
		- Has an aura that gradually increases a "Heat" level in the player, boosting submit chance.
*/
let wolfRavager = {
	style: 'WolfgirlRavStyle',
	outfit: 'WolfgirlRavDresses',
	// Key to signal we added this so we can make sure we don't remove an enemy with the same name added by someone else (such as someone else making a mod to modify the bandit ravager)
	// If you're making your own ravager, change this key or just remove it
	addedByMod: 'RavagerFramework',
	// id data
	name: "WolfgirlRavager", 
	faction: "Nevermere", 
	clusterWith: "nevermere", 
	playLine: "Wolfgirl", 
	bound: "Wolfgirl", 
	color: "#00EFAB",
	tags: KDMapInit([ 
		"opendoors", 
		"closedoors", 
		"nevermere",  
		"melee",
		"elite",
		"trainer",
		// "imprisonable",
		"glueweakness", 
		"ticklesevereweakness", 
		"iceresist", 
		"electricresist", 
		"charmweakness", 
		"stunweakness",
		"jail",
		"jailer",
		"unflinching", // makes enemy unable to be pulled/pushed. maybe don't remove this
		"nosub", //probably don't want to remove this one
		"hunter"
	]),

	// AI
	ignorechance: 0, 
	followRange: 1, 
	AI: "hunt",
	summon: [{enemy: "WolfgirlPet", range: 2, count: 2, chance: 0.7, strict: true},],

	// core stats
	armor: 1.5, 
	maxhp: 20, 
	minLevel: 0,
	weight: -2,
	visionRadius: 10, 
	movePoints: 3,
	disarm: 0.2,

	spells: ["RestrainingDevice"], 
	spellCooldownMult: 1, 
	spellCooldownMod: 1,
	minSpellRange: 2,

	RemoteControl: {
		punishRemote: 4,
		punishRemoteChance: 0.25,
	},
	 
	// main attack
	// HOW CAN I SEPARATE THIS FROM THE RAVAGING ABILITY
	// P.S. - this enemy uses "Effect" melee, but you could also create a spell that has the PlayerEffect of Ravage if it fits more.
	// dmgType: "grope",
	// attack: "MeleeEffectSpell", // "MeleeEffect" is the only necessary part
	// attackLock: "White",
	// power: 4, //i don't think this actually does anything with this enemy's setup - on theory, affects how strong their hits are
	// attackPoints: 2, //set this to 0 for it to happen instantly on contact, no telegraph
	// attackWidth: 1, 
	// attackRange: 2,
	// tilesMinRange: 1,
	// fullBoundBonus: 0,
	// stamina: 6,
	// hitsfx: "Grab",

	dmgType: "grope",
	attack: "MeleeEffect", // "MeleeEffect" is the only necessary part
	attackLock: "White",
	power: 4, //i don't think this actually does anything with this enemy's setup - on theory, affects how strong their hits are
	attackPoints: 2, //set this to 0 for it to happen instantly on contact, no telegraph
	attackWidth: 1, 
	attackRange: 1,
	tilesMinRange: 1,
	fullBoundBonus: 0,
	stamina: 6,
	hitsfx: "Grab",

	terrainTags: {"secondhalf":3, "lastthird":5, "metalAnger": 7, "metalRage": 2, "metalPleased": 9, "metalFriendly": 6, "nevermere": 7},
	allFloors: true, 
	shrines: ["Metal"],
	dropTable: [{name: "Gold", amountMin: 15, amountMax: 20, weight: 10}, {name: "EscortDrone", weight: 5.0, ignoreInInventory: true}],

	/*
		Ravage setup
	*/
	ravage: { // custom ravage settings
		targets: ["ItemVulva", "ItemMouth", "ItemButt"],
		refractory: 50, 
		needsEyes: false,
		
		onomatopoeia: ["CLAP...", "PLAP..."], //floats overhead like stat changes (can be unspecified for none)
		doneTaunts: ["That was good...", "Give me a minute and we'll go again, okay~?", "Such a good girl~!"],

		effectCallback: 'wolfgirlRavagerEffectCallback',

		// this can be a function ( (enemy, target) => {whatever} ) if you don't want it to do generic grope damage. anything you specify is used instead
		// you only need to specify narration if no callback is defined - otherwise you bring your own narration
		fallbackCallback: false, 
		fallbackNarration: ["The ravager roughly gropes you! (DamageTaken)"],
		restrainChance: 0.05, // Chance, decimal between 0 and 1

		// another optional function callback - will be called when an enemy is done
		// structured like (enemy, target, passedOut) => {} (with passedOut being whether the player passed out as a result or not)
		completionCallback: false,

		allRangeCallback: 'wolfgirlRavagerAllRangeCallback',

		submitChanceModifierCallback: 'wolfgirlSubmitChanceModifierCallback',

		// progression data - first group that's got a number your count is less than is the one used
		// you can use any numbers, any ranges, but keep in mind that there's a turn between hits unless you're doing something like AttackPoints 0
		ranges: [ 
			[1, { // starting - no stat damage yet
				taunts: ["Relax, girlie...", "Hehe, ready~?"],
				narration: {
					ItemVulva: ["EnemyName lines her intimidating cock up with your pussy..."],
					ItemButt: ["EnemyName lines her intimidating cock up with your ass..."],
					ItemMouth: ["EnemyName presses her cockhead against your lips..."],
				}
			}],

			[5, { // regular
				taunts: ["Mmh...", "That's it..."],
				narration: {
					ItemVulva: ["Wide hips meet yours as her cock stretches out your pussy..."],
					ItemButt: ["Wide hips meet your ass as her dick stretches you out..."],
					ItemMouth: ["Her strong hand guides your head up and down her thick cock..."],
				},
				sp: -0.3,
				dp: 1,
				orgasmBonus: 0,
			}],

			[12, { // rougher
				taunts: ["Good girl...", "Take it...", "I'm gonna miss you when we find you a nice master..."],
				narration: {
					ItemVulva: ["Strong hands grip your waist as your pussy is pounded..."],
					ItemButt: ["Your hips are gripped tight as your ass is railed..."],
					ItemMouth: ["Your face meets her lap, throating her cock over and over..."],
				},
				sp: -0.4,
				dp: 1.5,
				orgasmBonus: 1,
			}],

			[16, { // peak intensity
				taunts: ["Ooh, good girl~!", "Haah!"],
				narration: {
					ItemVulva: ["You cry out with each hilting thrust, smothered by soft curves!"],
					ItemButt: ["Her ferocious thrusts drive pathetic whimpers out of you!"],
					ItemMouth: ["You feel weak, her dick filling your throat again and again!"],
				},
				sp: -0.5,
				dp: 2,
				orgasmBonus: 2,
			}],

			[17, { // preparing to finish
				taunts: ["Here it comes~~!", "Let's fill you up~~!"],
				narration: {
					ItemVulva: ["With a thunderous final thrust, her dick throbs, she's about to--!!"],
					ItemButt: ["Her hips clap against yours with finality, she's about to--!!"],
					ItemMouth: ["Your vision fades as her cock pulses in your throat, she's about to--!!"],
				},
				sp: -0.5,
				dp: 5,
				orgasmBonus: 3,
			}],

			[20, { // finishing
				taunts: ["Aaaah~...", "Ooohh~...", "That's a good pet~..."],
				narration: {
					ItemVulva: ["You moan loudly as you feel your womb flooded with her hot cum..."],
					ItemButt: ["Your belly grows warm as she fills you up, pounded powerfully into her lap..."],
					ItemMouth: ["GLK... GLK... You helplessly swallow wave after wave of her seed..."],
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
	focusPlayer: true, // obvious
}
KinkyDungeonEnemies.push(wolfRavager)
KDEventMapEnemy['ravagerCallbacks']['definitionWolfgirlRavager'] = wolfRavager

//textkeys
// addTextKey("NameSlimeRavager", "Slimegirl")
addTextKey('NameWolfgirlRavager', 'Wolfgirl Alpha')
addTextKey('AttackWolfgirlRavager','The alpha charges and captures you in a powerful hug!')
addTextKey('AttackWolfgirlRavagerDash','The alpha yanks your body against her hard!')
addTextKey("KillWolfgirlRavager", "The alpha scrambles away, waiting for her next chance...")
// Still need , , 
