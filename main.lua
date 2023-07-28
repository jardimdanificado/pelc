print(((jit and jit.version) or _VERSION) .. ", plec 0.5")
local api = require("src.api")

local session = api.new.session() -- everything happen inside this

api.legacyrun(session,"require core") --lib containing the basics to set a working console, its also included in std



-- workers, these are used to modify commands and do turned actions
session:workeradd("cleartemp","_cleartemp") -- clears session.temp
session:workeradd("=>","_=>") -- autodef wrapper
session:workeradd("=","_=") -- set wrapper
session:workeradd("unwrapcmd","_unwrap") -- unwrap a command ([command])
session:workeradd('unref',"_unref") -- unref a variable @variable
session:workeradd("!","_!") -- multi-workerlist operator wl1!wl2!wl3!wl4
session:workeradd("spacendclean","_removeStartAndEndSpaces") -- name says everything
session:workeradd("cmdname","_cmdname") -- sets session.temp.cmdname
session:workeradd("segfault","_segFault") -- throw errors
session:workeradd("commander","_commander") -- split args then run the command

session.run = api.run -- disable the legacy runner

api.arghandler(session,arg) --name says everything, this handle the console arguments


-- print(api.run, session.run, api.legacyrun)
--session.api.visualtable(session) -- uncomment this to see how session hierarchy look like

--[[ uncomment this to test encryption
api.encode.save('abc.txt',api.encode.base64Encode(api.stringify(session,4)),0451)
api.file.save.text('changed.txt', api.encode.base64Decode(api.encode.load("abc.txt",0451)))
--]]

-- console loop
while not session.temp.exit do
    session:run()
end

session.temp.exit = nil