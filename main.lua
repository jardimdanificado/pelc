print(((jit and jit.version) or _VERSION) .. ", plec 0.4.7")
local api = require("src.api")

local session = api.new.session()

api.run(session,"require core") --lib containing the basics to set a working console, its also included in std

session:workeradd("cleartemp","_cleartemp")

session:workeradd("=>","_=>")
session:workeradd("=","_=")
session:workeradd("unwrapcmd","_unwrap")
session:workeradd('unref',"_unref")
session:workeradd("!","_!")
session:workeradd("spacendclean","_removeStartAndEndSpaces")
session:workeradd("segfault","_segFault")

api.arghandler(session,arg)

--[[ uncomment this to test encryption
api.encode.save('abc.txt',api.encode.base64Encode(api.stringify(session,4)),0451)
api.file.save.text('changed.txt', api.encode.base64Decode(api.encode.load("abc.txt",0451)))
--]]

while not session.temp.exit do
    session:run()
end

session.temp.exit = nil