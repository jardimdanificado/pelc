#!/usr/bin/luajit
print((jit.version or _VERSION) .. ", plec 0.4.5")
local api = require("src.api")
local session = api.new.session()

api.run(session,"require core") --lib containing the basics to set a working console, its also included in std

session:workeradd("cleartemp","_cleartemp")
session:workeradd("=>","_=>")
session:workeradd("=","_=")
session:workeradd("@","_@")
session:workeradd("unwrapcmd","_unwrap")
session:workeradd('unref',"_unref")
session:workeradd("spacendclean","_removeStartAndEndSpaces")
session:workeradd("segfault","_segFault")

api.arghandler(session,arg)

while not session.temp.exit do
    session:run()
end

session.temp.exit = nil