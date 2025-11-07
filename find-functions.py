#!/bin/env python
from os import listdir
from os.path import join, isdir, realpath, dirname
from re import match, search
from json import dump
from sys import argv

def getFiles(path):
  files = listdir(path)
  found_files = []
  for file in files:
    if isdir(join(path, file)):
      found_files.extend(getFiles(join(path, file)))
    elif file.endswith(".ks"):
      found_files.append(join(path, file))
  return found_files

def findFunctions(path):
  lines = []
  with open(path, 'r') as file:
    while True:
      line = file.readline()
      if line == "":
        break
      line = line.strip()
      reg = search("[A-Za-z0-9_.-]+\\(.*\\);?", line)
      if not reg:
        continue
      func_call = line[reg.start():reg.end()].strip()
      # Skipping stuff
      ## Comments, if statements, and for loops
      if match("^(//|((} )?else )?if|for) *", line):
        continue
      ## Function def inside objects
      if match("^[A-Za-z. ]+(:| =) (function)?\\([A-Za-z_,= ]*\\)( =>)? {", line):
        continue
      ## Bare / nested function declarations
      if match("^function [A-Za-z0-9]+\\([A-Za-z0-9_,.=\" -]*\\) {", line):
        continue
      ## Known functions
      known = []
      ### My own functions
      known.extend([ "RFTrace", "RFInfo", "RFDebug", "RFWarn", "RFError", "RFNFTrace", "inStringRandom", "RavagerGetSetting", "objToString", "RFConfigDefault", "RFConfigCheckLocalStorage", "RavagerFrameworkPushToLogBuffer", "RFDebugEnabled", "RavagerFrameworkToggleDebug", "ravagerFrameworkRefreshEnemies", "ravagerFrameworkApplySomeSpice", "ravagerFrameworkApplySlimeRestrictChance", "refreshRavagerDataVariables", "RavagerFrameworkRefreshFonts", "RavagerFrameworkIWantToHelpDebug", "ravagerSettingsRefresh", "ravagerFrameworkSetupSound", "bypassed", "experiencedTextDecideDefault", "experiencedTextDecideUser", "experiencedTextDecideRavager", "increasePlayerRavagedCount", "ravagerFreeAndClearAllData", "ravagerFreeAndClearAllDataIfNoRavagers", "RavagerAddCallback", "RFPushEnemiesWithStrongVariations", "DrawCheckboxRFEx" ])
      ### Built in JS object functions
      known.extend([ "replace", "substring", "split", "floor", "replaceAt", "slice", "push", "pop", "filter", "max", "eval", "createElement", "translate", "appendChild", "addEventListener", "parse", "find", "structuredClone", "Error", "substr", "log", "warn", "error", "trim", "toString", "Boolean", "get", "isArray", "hasOwnProperty", "has", "splice", "match", "stringify", "Date", "setAttribute", "click", "removeChild", "FontFace", "add", "load", "delete", "findIndex", "some", "keys", "includes", "random", "Number", "findLast", "setTimeout", "min", "assign" ])
      if func_call.split("(")[0].split(".")[-1] in known:
        continue
      ## Any functions inside RavagerData.functions
      if func_call.startswith("RavagerData.functions."):
        continue
      ## Assignments that look like function calls to this nightmare
      if match("^\\(.+ ? .+ : .+\\)", func_call):
        continue
      ## Specific instances that pop up
      hardskip = [ "(DamageTaken)" ]
      if func_call in hardskip:
        continue
      hardskipstart = [ "window.RFPushEnemiesWithStrongVariations" ]
      found_to_skip = False
      for h in hardskipstart:
        if line.startswith(h):
          found_to_skip = True
          break
      if found_to_skip:
        continue
      #
      func_name = func_call.split("(")[0]
      if func_name not in lines:
        lines.append(func_name.strip("."))
  return lines

def main(basepath):
  found_files = getFiles(basepath)
  functions = []
  for file in found_files:
    found = findFunctions(file)
    for func in found:
      if func not in functions:
        functions.append(func)
  functions.sort()
  with open(join(basepath, "functions.json"), "w") as output:
    dump(functions, output, indent="  ")
  print("Functions saved to \"functions.json\" next to this script.")
  return 0

if __name__ == "__main__":
  exit(main(dirname(realpath(argv[0]))))
