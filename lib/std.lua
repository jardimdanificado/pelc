local std = {}

std['$'] = function(session,api,args,cmd)
    os.execute(cmd:gsub("%$"))
end

std['>>'] = function(_session,_api,args,cmd)
    session = _session
    api = _api
    assert(_api.load(cmd:gsub( "%>%>", '')))()
    session = nil
    api = nil
end

std['>'] = function(_session,_api,args,cmd)
    return assert(_api.load(cmd:gsub( "%>", '')))()
end

std['expose'] = function(_session,_api,args,cmd)
    if args[1] == "session" then
        session = _session
    elseif args[1] == "api" then
        api = _api
    else
        session = _session
        api = _api
    end
end

std['hide'] = function(_session,_api,args,cmd)
    if args[1] == "session" then
        session = nil
    elseif args[1] == "api" then
        api = nil
    else
        session = nil
        api = nil
    end
end

std.clear = function(s,a)
    os.execute(s.api.unix("clear","clr"))
end

std.pause = function(session,api,args)
    api.run(session)
end

std.exit = function(session,api,args)
    session.exit = true
end

std.terminate = function(session,api,args)
    os.exit()
end

std.echo = function(session,api,args)
    for i, v in ipairs(args) do
        io.write(v .. ' ')
    end
    io.write('\n')
end

std.solve = function(session,api,args, cmd)
    print('return ' .. cmd:gsub('solve ',''))
    local result = (api.load('return ' .. cmd:gsub('solve ','')))()
    
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

std.fn = function(session,api,args,cmd)
    session.cmd[args[1]] = (api.load("return function(session,api,args,cmd) " .. cmd:gsub('fn',''):gsub(args[1],'') .. ' end'))()
end

std.help = function(session,api,args)
    io.write("\27[32mAvaliable commands:\27[0m ")
    for k, v in pairs(session.cmd) do
        io.write(k .. ', ') 
    end
    io.write('\n')
end

return std
