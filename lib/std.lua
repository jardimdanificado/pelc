local std = {cmd = {},worker = {}}

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

std.cmd.exit = function(session,args)
    session.temp.exit = true
end

std.cmd.terminate = function(session,args)
    os.exit()
end

std.cmd.echo = function(session,args) --unblocked
    local txt = ''
    for i, v in ipairs(args) do
        txt = txt .. v .. ' '
    end
    print(txt)
    return txt
end

std.cmd.solve = function(session,args, cmd)
    local result = session.api.load('return ' .. cmd:gsub('solve ','')) or function() end
    result = result() or ''
    return result
end

std.cmd.set = function(session,args, cmd)
    local finalargs = {}
    for i = 2, 1, -1 do
        table.insert(finalargs, args[i])
    end
    session.data[args[1]] = session.api.array.unpack(finalargs)
    local newcmd = cmd:gsub(args[1] .. ' ', '')
    newcmd = newcmd:gsub("set ", '')
    if args[2] == 'true' or args[2] == 'false' then
        session.data[args[1]] = args[2] == true and true or false
    elseif tonumber(newcmd) then
        session.data[args[1]] = tonumber(newcmd)
    else
        session.data[args[1]] = newcmd
    end
end

std.cmd.def = function(session,args,cmd)
    session.cmd[args[1]] = (session.api.load("return function(session,args,cmd) " .. cmd:gsub('def '.. args[1] ,'',1) .. ' end'))()
end

std.cmd.help = function(session,args)
    io.write("\27[32mAvaliable commands:\27[0m ")
    for k, v in pairs(session.cmd) do
        io.write(k .. ', ') 
    end
    io.write('\n')
end

std.cmd["---"] = function(session,args)
    local txt = ''
    for i, v in ipairs(args) do
        txt = txt .. v .. ' '
    end
    return txt
end

return std
