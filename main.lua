#!/usr/bin/luajit
local api = require("src.api")
local session = api.new.session()
api.start(session)