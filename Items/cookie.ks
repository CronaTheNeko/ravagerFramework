const badgirlcookie = {
	name: "NaughtyCookie",
	rarity: 0,
	shop: true,
	type: "restore",
	wp_instant: -1.5,
	wp_gradual: 0,
	scaleWithMaxWP: true,
	needMouth: true,
	delay: 3,
	gagMax: 0.59,
	duration: 0,
	sfx: "Cookie",
	sideEffects: [ "subAdd" ],
	maxInventory: 30,
	data: {
		subAdd: -5,
		subPower: 0.3,
		subPowerVar: 0.5,
		subDuration: 100
	}
}
KDCookies['NaughtyCookie'] = badgirlcookie

const suscookie = {
	name: "RavagedCookie",
	rarity: 0,
	shop: false,
	type: "restore",
	wp_instant: 1.0,
	scaleWithMaxWP: true,
	ap_instant: 1.5,
	scaleWithMaxAP: true,
	needMouth: true,
	delay: 3,
	gagMax: 0.59,
	duration: 0,
	sfx: "Cookie",
}
KDCookies['RavagedCookie'] = suscookie

Object.assign(KinkyDungeonConsumables, KDCookies);
