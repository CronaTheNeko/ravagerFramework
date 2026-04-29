window.RavagerFrameworkLoadTranslation = function(content, language) {
  // Split into lines
  let lines = content.split("\n")
  // Loop lines
  for (let line of lines) {
    // Skip empty lines and comments
    if (line.match(/^(\s*$|;)/))
      continue
    // Split line into text key and value. Key and value are separated by " = ", and the split regex ensures that " = " is still safe to use within values
    let [key, val] = line.split(/ = (.*)/s, 2)
    // Trim leading and trailing spaces
    key = key.trim()
    val = val.trim()
    // Add text key
    RFAddTextKey(key, val, language)
    // Save unmodified text keys for "unravel all" functionality in Ravager Controls, since RFPushEnemiesWithStrongVariations adds many additional text keys that will just get overridden
    if (language == "EN")
      RavagerData.Translations.raw[key] = val
  }
}
// Async function since blob operations are async
window.RavagerFrameworkLoadTranslations = async function() {
  // Get available translations
  let translations = Object.keys(KDModFiles).filter(v => v.match(/^Game\/Translations\/[A-Z]{2}\/[a-zA-Z0-9-_]+\.txt/s))
  // Loop available translations
  for (let tname of translations) {
    // Get language from file path
    let lang = tname.replace("Game/Translations/", "").split("/")[0]
    // Get response from blob url
    let response = await fetch(KDModFiles[tname])
    // Get blob
    let blob2 = await response.blob()
    // Read file text
    let text2 = await blob2.text()
    // Free memory used for translation (might as well?)
    URL.revokeObjectURL(KDModFiles[tname])
    delete KDModFiles[tname]
    RavagerFrameworkLoadTranslation(text2, lang)
  }
}
RavagerFrameworkLoadTranslations()
