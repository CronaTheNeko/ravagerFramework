// This hairpin model was snagged from Arconox's Asset Pack: https://discord.com/channels/938203644023685181/1247315650238746655/1253067649970343946
AddModel({
	Name: "RavLargeHeartHairpin",
	Folder: "Hair",
	Parent: "HeartHairPins",
	Protected: true,
	Categories: ["Hairstyles", "Accessories"],
	Layers: ToLayerMap([
	{
		Name: "LargeHeartHairpin",
		Layer: "HairFront",
		Pri: 20
	}])
});

AddModel({
	Name: "WolfgirlAlpha",
	Folder: "WolfCatsuit",
	Parent: "WolfgirlAlpha",
	TopLevel: true,
	// Categories: ["Uniforms"],
	Layers: ToLayerMap([
		...GetModelLayers("WolfCollarSmallTag"),
		...GetModelLayers("WolfHeels"),
		...GetModelLayers("WolfTorsoUpper"),
		...GetModelLayers("WolfSocks"),
		...GetModelLayers("WolfGloveLeft"),
	])
})

AddModel({
	Name: "FluffyPonytailRav",
	Parent: "Ponytail",
	Folder: "Hair",
	TopLevel: true,
	Protected: true,
	Layers: ToLayerMap([
		...GetModelLayers("FluffyPonytail")
	])
})

AddModel({
	Name: "FluffyPonytailRav2",
	Parent: "Ponytail",
	Folder: "Hair",
	TopLevel: true,
	Protected: true,
	Layers: ToLayerMap([
		...GetModelLayers("FluffyPonytailRav")
	])
})

addTextKey('m_RavLargeHeartHairpin', 'Bandit Hairpin')
addTextKey('l_RavLargeHeartHairpin_LargeHeartHairpin', 'Hairpin')
