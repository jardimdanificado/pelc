local std = require("lib.core")

std.cmd['$'] = function(session,args,cmd)
    local lcmd = 'os.execute("' .. session.api.string.replace(cmd, "%$")  .. '")'
    assert(session.api.load(lcmd))()
end

std.cmd.clear = function(s,a)
    os.execute(s.api.unix("clear","clr"))
end

std.cmd.pause = function(session,args)
    session:run()
end

std.cmd.exposes = function(_session,args)
    session = _session
end

std.cmd.hides = function(_session,args)
    session = nil
end

std.cmd.terminate = function(session,args)
    os.exit()
end

std.cmd.echo = function(session,args)
    local txt = ''
    for i, v in ipairs(args) do
        txt = txt .. v .. ' '
    end
    print(txt)
    return txt
end

std.cmd.help = function(session,args)
    io.write("\27[32mAvaliable commands:\27[0m ")
    for k, v in pairs(session.cmd) do
        io.write(k .. ', ') 
    end
    print('\n--end')
end

std.cmd.lhelp = function(session,args)
    io.write("\27[32mLoaded commands:\27[0m ")
    for k, v in pairs(session.data.cmd) do
        io.write(k .. ', ') 
    end
    print('\n--end')
end

std.cmd["---"] = function(session,args)
    local txt = ''
    for i, v in ipairs(args) do
        txt = txt .. v .. ' '
    end
    return txt
end

return std
