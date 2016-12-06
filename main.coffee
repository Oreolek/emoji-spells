ImprovEngine = require "improv"
marked = require "marked"
fs = require 'fs'
CSON = require 'cson'
glob = require 'glob'

class ImprovModel
  constructor: () ->
    @tags = []

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

improv = new ImprovEngine(spec, {
  filters: [
    ImprovEngine.filters.mismatchFilter()
  ]
  reincorporate: true
})

model = new ImprovModel
console.log improv.gen('voice', model)
