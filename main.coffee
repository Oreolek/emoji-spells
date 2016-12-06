ImprovEngine = require "improv"
ImprovModel = require "./model"
CSON = require 'cson'
glob = require 'glob'
Masto = require 'mastodon'

config = CSON.parseCSONFile('config.cson')
Mastodon = new Masto({
  access_token: config.access_token
  api_url: config.api_url
})

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
description = improv.gen('main', model).trim()
if config.post
  Mastodon.post('statuses', {
    status: description
  })
else
  console.log description
