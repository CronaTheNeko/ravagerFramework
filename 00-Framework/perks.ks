// Preferences
KDCategoriesStart = [
  ...KDCategoriesStart.slice(0, KDCategoriesStart.findIndex(v => v.name == "Multiclass")),
  { name: "RFPreferences" },
  ...KDCategoriesStart.slice(KDCategoriesStart.findIndex(v => v.name == "Multiclass"))
]
KinkyDungeonStatsPresets.RFEasyEscape = {
  category: "RFPreferences",
  id: "RFEasyEscape",
  cost: 0
}
KinkyDungeonStatsPresets.RFQuickRun = {
  category: "RFPreferences",
  id: "RFQuickRun",
  cost: 0
}
