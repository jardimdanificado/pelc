local std = {}

std['$'] = function(session,args,cmd)
    local lcmd = 'os.execute("' .. session.api.util.string.replace(cmd, "%$")  .. '")'
    assert(session.api.util.load(lcmd))()
    session:run()
end

std['>'] = function(_session,args,cmd)
    session = _session
    cmd = _session.api.util.string.replace(cmd, ">", '')
    assert(_session.api.util.load(cmd))()
    session = nil
end

std.clear = function(s,a)
    os.execute(s.api.util.unix("clear","clr"))
end

std.pause = function(session,args)
    session:run()
end

std.exit = function(session,args)
    session.exit = true
end

std.terminate = function(session,args)
    os.exit()
end

std.echo = function(session,args) --unblocked
    for i, v in ipairs(args) do
        io.write(v .. ' ')
    end
    io.write('\n')
end

std.sets = function(session,args)
    local finalargs = {}
    for i = 2,1 do 
        table.insert(finalargs,args[i])
    end
    session.data[args[1]] = session.api.util.array.unpack(finalargs)
end

std.seti = function(session,args)
    session.data[args[1]] = math.floor(tonumber(args[2]))
end

std.setn = function(session,args)
    session.data[args[1]] = tonumber(args[2])
end

std.def = function(session,args,cmd)
    local util = session.api.util
    local finalargs = {}
    for i = 2,1 do 
        table.insert(finalargs,args[i])
    end
    session.data[args[1]] = util.load("function(session,args,cmd) " .. util.array.tostring(finalargs) .. ' end')
end

std.defcmd = function(session,args,cmd)
    local util = session.api.util
    local finalargs = {}
    for i = 2,1 do 
        table.insert(finalargs,args[i])
    end
    session.cmd[args[1]] = util.load("function(session,args,cmd) " .. util.array.tostring(finalargs) .. ' end')
end

std.help = function(session,args)
    io.write("\27[32mAvaliable commands:\27[0m ")
    for k, v in pairs(session.cmd) do
        io.write(k .. ', ') 
    end
    io.write('\n')
end

return std
