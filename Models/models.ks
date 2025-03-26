// Pre-load ravager hairpin
console.log('[Ravager Framework] Preloading assets...')
try {
  PIXI.Texture.fromURL(KDModFiles['Models/Hair/LargeHeartHairpin.png'])
} catch (error) {
  console.error('Caught error while loading LargeHeartHairpin: ', error.message)
}

// This hairpin model was snagged from Arconox's Asset Pack: https://discord.com/channels/938203644023685181/1247315650238746655/1253067649970343946
AddModel({
	Name: "RavLargeHeartHairpin",
	Folder: "Hair",
	TopLevel: true,
	Protected: true,
	Categories: ["Hairstyles", "Accessories"],
	Layers: ToLayerMap([
	{
		Name: "LargeHeartHairpin",
		Layer: "HairFront",
		Pri: 20
	}])
});
addTextKey('m_RavLargeHeartHairpin', 'Ravager Hairpin')
addTextKey('l_RavLargeHeartHairpin_LargeHeartHairpin', 'Hairpin')

AddModel({
	Name: "WolfgirlAlpha",
	Folder: "WolfCatsuit",
	Parent: "WolfgirlAlpha",
	TopLevel: true,
	Layers: ToLayerMap([
		...GetModelLayers("WolfCollarSmallTag"),
		...GetModelLayers("WolfHeels"),
		...GetModelLayers("WolfTorsoUpper"),
		...GetModelLayers("WolfSocks"),
		...GetModelLayers("WolfGloveLeft"),
	])
});

AddModel({
	Name: "FluffyPonytailRav",
	Folder: "Hair",
	TopLevel: true,
	Protected: true,
	Layers: ToLayerMap([
		...GetModelLayers("FluffyPonytail")
	])
});

AddModel({
	Name: "FluffyPonytailRav2",
	Folder: "Hair",
	TopLevel: true,
	Protected: true,
	Layers: ToLayerMap([
		...GetModelLayers("FluffyPonytailRav")
	])
});

AddModel({
	Name: "RavLiftedSkirt",
	Folder: "Rope",
	TopLevel: false,
	Restraint: true,
	AddPoseConditional: {
		OptionCrotchRope: [ "CrotchStrap" ]
	},
	Layers: ToLayerMap([])
});


// This didn't fix the delayed loading either
// KinkyDungeonRefreshEnemiesCache()
