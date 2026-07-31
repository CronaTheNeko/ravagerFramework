if (!window.hasOwnProperty("RavagerData")) {
  console.error("[RF] Framework Tainted! Manually loading fileorder files in hopes to avoid a crash!")
  console.log("[RF] Building file list ...")
  const names = [
    "00-Framework/data.ks",
    "00-Framework/core_functions.ks",
    "00-Framework/public_functions.ks",
    "Translations/EN/core.txt",
    "Translations/EN/consumables.txt",
    "Translations/EN/perks.txt",
    "Translations/EN/bandit_ravager.txt",
    "Translations/EN/mimic_ravager.txt",
    "Translations/EN/slime_ravager.txt",
    "Translations/EN/tentacle_pit.txt",
    "Translations/EN/wolfgirl_ravager.txt",
    "mod.json"
  ]
  let order = []
  for (let name of names) {
    order.push(KDAllModFiles.filter(file => file.filename.endsWith(name))[0])
  }
  const pathPrefix = order[0].filename.replace(names[0], "")
  console.log("[RF] Loading files ...")
  for (let file of order) {
    console.log(file)
    file.getData(new zip.TextWriter()).then(content => {
      if (file.filename.endsWith(".ks")) {
        console.log(`[RF] Executing file ${file.filename} ...`)
        // Spook
        eval(content)
      } else {
        console.log(`[RF] Importing asset ${file.filename} ...`)
        let newkey = file.filename.replace(pathPrefix, "")
        KDModFiles[(KinkyDungeonRootDirectory + newkey).replace("\\", "/")] = URL.createObjectURL(new Blob([content]));
        KDModFiles[(KinkyDungeonRootDirectory + "" + newkey).replace("\\", "/")] = KDModFiles[KinkyDungeonRootDirectory + newkey];
      }
    })
  }
  KDEventMapGeneric.afterModSettingsLoad.RavagerFrameworkTainted = () => {
    const body = [ "The directory structure of the Ravager Framework was detected as being broken. The likely causes for this are 1) you're using a repackage of the framework that was built incorrectly, or 2) you've downloaded the code for the mod as a ZIP file from GitHub.", "Regardless of how this happened, if you look inside the ZIP file you're loading, you'll likely see the mod within a subdirectory. Inside the ZIP file, the mod.json file and everything next to it must be at the root of the archive, but inside your ZIP file, mod.json is in a subdirectory (possibly something like ravagerFramework-main/mod.json).", "If you're on Linux, you can create a correct build of the mod by running the build.sh script included in the code. Otherwise, you can select all files and folders in the mod's directory (the directory containing mod.json) and compressing them so that all the files are in the root of the ZIP archive.", "While the framework has seemingly loaded all of its code, ALL assets (image and sound files) have failed to load properly. If you choose to play in this state, expect sounds made by the player to not play, enemy sprites being invisible at least temporarily, significant portions of the mod's text to be missing, and all text translations to be missing.", "Please do NOT report bugs found in this state unless they are reproducible when this warning is not shown." ]
    RavagerFrameworkShowModal("rf-tainted", "Ravager Framework Structure Broken", body)
    RavagerData.Tainted = true
  }
  console.error("TAINTED TESTER DONE")
}
