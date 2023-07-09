#!/usr/bin/luajit
local api = require("src.api")
local session = api.new.session()

api.run(session,"require core") --lib containing the basics to set a working console, its also included in std

session:stepadd("=>","_=>")
session:stepadd("=","_=")
session:stepadd("@","_@")
session:stepadd("unwrapcmd","_unwrap")
session:stepadd('unref',"_unref")
session:stepadd("spacendclean","_removeStartAndEndSpaces")
session:stepadd("segfault","_segFault")

api.arghandler(session,arg)

while not session.temp.exit do
    session:run()
end

session.temp.exit = nil