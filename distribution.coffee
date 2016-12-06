# Improv distribution assessment
# Currently only for files
# Ignores tags!!! The assessment could be above real value.

CSON = require 'cson'
glob = require 'glob'

distribution = {}
template = (phrase) ->
  if phrase == undefined or phrase == ''
    return []
  [openBracket, closeBracket] = [phrase.indexOf('['), phrase.indexOf(']')]
  if openBracket == -1
    return phrase
  if closeBracket == -1
    throw new Error("Missing close bracket in phrase: #{phrase}")
  before = phrase.slice(0, openBracket)
  after = phrase.slice(closeBracket + 1)
  directive = phrase.substring(openBracket + 1, closeBracket)
  return [directive, after]

parseGroup = (group) ->
  groups = []
  occurence = {}
  for phrase in group.phrases
    nexttpl = null
    templates = []
    while nexttpl != undefined
      [nexttpl, after] = template (phrase)
      if nexttpl != undefined
        templates.push(nexttpl)
      phrase = after
    for tpl in templates
      directive = tpl.slice(0, 1)
      grp = tpl.substring(1, tpl.length)
      if groups.length > 0 and groups.indexOf(grp) == -1
        groups.push grp
      if directive == ':'
        occurence[grp] ?= 0
        occurence[grp] += 1
  for filename, value of occurence
    distribution[filename] ?= 1
    distribution[filename] *= value/group.phrases.length
  for filename in groups
    if spec[filename]?
      for groupdata in spec[filename].groups
        parseGroup(groupdata)

files = glob.sync('data/*.cson')
spec = {}
for file in files
  data = CSON.parseCSONFile(file)
  if not data.groups?
    data.groups = []
  if data.phrases?
    data.groups.push({
      tags: [],
      phrases: data.phrases
    })
    data.phrases = null
  key = file.substr(0, file.lastIndexOf('.')) || file
  key = key.replace('data/', '')
  spec[key] = data

for group in spec.main.groups
  parseGroup(group)

for filename, value of distribution
  distribution[filename] = Math.round(value * 1000) / 1000
console.log distribution
