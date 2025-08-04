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

const text = {
	ItemPickupNaughtyCookie: "You pick up a lumpy sugar cookie with red frosting!",
	KinkyDungeonInventoryItemNaughtyCookie: "Bad-Girl Cookie",
	KinkyDungeonInventoryItemNaughtyCookieUse: "You slowly eat the cookie, it's lumpy texture reminding you of when you disobeyed.",
	KinkyDungeonInventoryItemNaughtyCookieDesc: "You're not sure how to feel when looking at it...",
	KinkyDungeonInventoryItemNaughtyCookieDesc2: "Removes 5 submissiveness but decreases willpower by 15%. Takes a few turns to eat.",
	ItemPickupRavagedCookie: "You find an odd looking chocolate chip cookie...",
	KinkyDungeonInventoryItemRavagedCookie: "Suspicious Cookie",
	KinkyDungeonInventoryItemRavagedCookieUse: "You slowly eat the cookie, feeling a weird sensation throughout your body.",
	KinkyDungeonInventoryItemRavagedCookieDesc: "It looks like there might be something wrong with this one...",
	KinkyDungeonInventoryItemRavagedCookieDesc2: "What's this weird substance in the chocolate..?",
}
for (var key in text)
	addTextKey(key, text[key])
