local std = {}

std['$'] = function(session,api,args,cmd)
    local lcmd = 'os.execute("' .. api.string.replace(cmd, "%$")  .. '")'
    assert(api.load(lcmd))()
end

std.clear = function(s,a)
    os.execute(s.api.unix("clear","clr"))
end

std.pause = function(session,api,args)
    session:run()
end

std.exit = function(session,api,args)
    session.exit = true
end

std.terminate = function(session,api,args)
    os.exit()
end

std.echo = function(session,api,args) --unblocked
    local txt = ''
    for i, v in ipairs(args) do
        txt = txt .. v .. ' '
    end
    print(txt)
    return txt
end

std.solve = function(session,api,args, cmd)
    local result = api.load('return ' .. cmd:gsub('solve ','')) or function() end
    result = result() or ''
    return result
end

std.set = function(session,api,args, cmd)
    local finalargs = {}
    for i = 2, 1, -1 do
        table.insert(finalargs, args[i])
    end
    session.data[args[1]] = api.array.unpack(finalargs)
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

std.def = function(session,api,args,cmd)
    session.cmd[args[1]] = (api.load("return function(session,api,args,cmd) " .. cmd:gsub('def '.. args[1] ,'',1) .. ' end'))()
end

std.help = function(session,api,args)
    io.write("\27[32mAvaliable commands:\27[0m ")
    for k, v in pairs(session.cmd) do
        io.write(k .. ', ') 
    end
    io.write('\n')
end

std["---"] = function(session,api,args)
    local txt = ''
    for i, v in ipairs(args) do
        txt = txt .. v .. ' '
    end
    return txt
end

return std
