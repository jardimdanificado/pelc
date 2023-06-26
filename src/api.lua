local util = require('src.util')
local api = {}
api.util = util

api.run = function(session, command)
    local fullcmd = command or io.read()
    for i, cmd in ipairs(util.console.formatcmd(fullcmd)) do
        if cmd ~= '' then
            local split = api.util.string.split(cmd, " ")
            cmd = string.gsub(cmd, "^%s*(.-)%s*$", "%1")
            local args = {}
            for i = 2, #split, 1 do
                table.insert(args,split[i])
            end
            if session.cmd[split[1]] == nil then
                print(split[1] .. " is not a command!")
            else
                session.cmd[split[1]](session,args,cmd)
            end
        end
    end
end

api.spawn = function(session,worker) 

end

api.new = {
    session = function()
        local session = 
        {
            data = {},
            worker={},
            run = api.run,
            api = api,
            exit = false,
            time = 0,
            cmd = 
            {
                require = function(session,args)
                    local templib
                    if not session.api.util.string.includes(args[1],'lib.') and not session.api.util.string.includes(args[1],'/') and not session.api.util.string.includes(args[1],'\\') then
                        templib = require('lib.' .. args[1])
                    else
                        templib = require(
                            session.api.util.string.replace(
                                session.api.util.string.replace(
                                    session.api.util.string.replace(args[1],'.lua',''),'/','.'),'\\','.'))
                    end
                    if templib._preload ~= nil then
                        templib._preload(session)
                    end
                    for k, v in pairs(templib) do
                        session.cmd[k] = v
                    end
                    if templib._setup ~= nil then
                        templib._setup(session)
                    end
                end,
                import = function(session,args)
                    if not session.api.util.file.exist(args[1]) then
                        return
                    end
                    local templib = dofile(args[1])
                    for k, v in pairs(templib) do
                        session.cmd[k] = v
                    end
                end,
            }
        }
        return session
    end
}

api.start = function(session)
    local laterscript = {}
    local skip = false
    for i, v in ipairs(arg) do
        if skip ~= false then
            session:run(skip .. v)
            skip = false
        elseif v == '-l' then
            skip = "import "
        elseif util.string.includes(v,'-l') then
            session:run("require lib." .. util.string.replace(v,'-l',''))
        elseif util.string.includes(v,'.lup') then
            table.insert(laterscript,v)
        end
    end
    for i, v in ipairs(laterscript) do
        session:run(util.file.load.text(v))
    end
    while not session.exit do
        session:run()
    end
    session.exit = false
end

return api