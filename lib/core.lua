local core = {}
core.cmd = {}
core.worker = {}

core.cmd.exit = function(session,args)
    session.temp.exit = true
    session.temp['break'] = true
end

core.cmd.run = function(session,args)
    session.api.run(session,session.api.file.load.text(args[1]))
end
core.cmd['--'] = function() end
core.cmd.set = function(session, args, cmd)
    local function setNestedValue(table, keys, value)
        local currentTable = table
        for i = 1, #keys - 1 do
            local key = tonumber(keys[i]) or keys[i]
            if not currentTable[key] or type(currentTable[key]) ~= "table" then
                currentTable[key] = {}
            end
            currentTable = currentTable[key]
        end
        currentTable[keys[#keys]] = value
    end

    local finalargs = {}
    for i = 2, #args do -- Skip the first argument (args[1])
        table.insert(finalargs, args[i])
    end

    local keys = {}
    local nestedKey = args[1]
    for key in nestedKey:gmatch("([^%.]+)") do
        table.insert(keys, key)
    end

    if #keys > 1 then
        setNestedValue(session.data, keys, tonumber(finalargs[1]))
    else
        local newcmd = cmd:gsub(args[1] .. ' ', '')
        newcmd = newcmd:gsub("set ", '')
        if args[2] == 'true' or args[2] == 'false' then
            session.data[args[1]] = args[2] == 'true' and true or false
        elseif tonumber(newcmd) then
            session.data[args[1]] = tonumber(newcmd)
        else
            session.data[args[1]] = newcmd
        end
    end
end

core.cmd.get = function(session, args, cmd)
    local keys = {}
    local curr = session.data
    if session.api.string.includes(args[1],'.') then
        for key in args[1]:gmatch("([^%.]+)") do
            table.insert(keys, key)
        end
    end
    for i, v in ipairs(keys) do
        curr = curr[tonumber(v) or v]
    end
    return curr
end

core.cmd.unset = function(session, args)
    local function unsetNestedValue(table, keys)
        local currentTable = table
        for i = 1, #keys - 1 do
            local key = keys[i]
            if not currentTable[key] or type(currentTable[key]) ~= "table" then
                -- If any intermediate key doesn't exist or is not a table, we stop here.
                return
            end
            currentTable = currentTable[key]
        end
        currentTable[keys[#keys]] = nil
    end

    local keys = {}
    local nestedKey = args[1]
    for key in nestedKey:gmatch("([^%.]+)") do
        table.insert(keys, key)
    end

    unsetNestedValue(session.data, keys)
end

core.cmd.def = function(session,args,cmd)
    session.data.cmd[args[1]] = (session.api.load("return function(session,args,cmd) " .. cmd:gsub('def '.. args[1] ,'',1) .. ' end'))()
end

core.cmd.undef = function(session,args,cmd)
    if not session.data.cmd[args[1]] then
        print(args[1] .. ' command does not exist.')
    else
        session.data.cmd[args[1]] = nil
        session.api.array.clear(session.data.cmd)
    end

end
core.cmd.autodef = function(session,args,cmd)
    session.data.cmd[args[1]] = (session.api.load("return function(session,args,cmd) " .. cmd:gsub('autodef '.. args[1] ,'',1) .. ' end'))()
    session.cmd[args[1]] = session.data.cmd[args[1]]
end
core.cmd.load = function(session,args)
    if not session.data.cmd[args[1]] then
        print(args[1] .. ' command does not exist.')
    else
        session.cmd[args[1]] = session.data.cmd[args[1]]
    end
end
core.cmd.unload = function(session,args)
    if not session.cmd[args[1]] then
        print(args[1] .. ' command is not loaded. nothing has been unloaded.')
    else
        session.cmd[args[1]] = nil
        session.api.array.clear(session.cmd)
    end
end
core.cmd[">"] = function(session,args, cmd)
    local result = session.api.load('return ' .. cmd:gsub('> ','')) or function() end
    result = result() or ''
    return result
end

--------------------- workers
-- workers
--------------------- workers

core.worker['='] = function(session, cmd)
    local split = session.api.string.split(cmd," ")
    if split[2] == '=' then
        cmd = cmd:gsub("=",' = ')
        cmd = cmd:gsub("%s+=%s+",' ')
        cmd = "set " .. cmd
    end
    return cmd
end
core.worker['=>'] = function(session, cmd)
    local split = session.api.string.split(cmd," ")
    if split[2] == '=>' then
        cmd = cmd:gsub("=>",'')
        cmd = "autodef " .. cmd
    end
    return cmd
end

core.worker.unref = function(session, cmd)
    if session.api.string.includes(cmd, '@') then
        -- cmd = cmd:gsub("@%s+", "@")
        local newc = cmd
        local links = {}
        while session.api.string.includes(newc, "@") do
            local link, result = session.api.getlink(newc, "@")
            newc = result
            table.insert(links,link)
        end
        if #links == 1 then
            cmd = session.api.string.replace(cmd,links[1],session.api.stringify(session.data[links[1]:gsub('@','')]))
            --print(cmd)
        else
            local curr = session.data
            
            for i, link in ipairs(links) do
                local splited = session.api.string.split(link:gsub('@',''),"([^%.]+)")
                print(session.api.stringify(splited))
                for i, key in ipairs(splited) do
                    curr = curr[tonumber(key) or key]
                end
            end
            cmd = session.api.string.replace(cmd,args,session.api.stringify(session,{curr}))
        end
        
    end
    return cmd
end

core.worker.cleartemp = function(session,cmd)
    if not session.temp.keep then        
        session.temp = {}
    else
        session.temp.keep = false
    end
end

core.worker.unwrapcmd = function (session, cmd)
    local startPos, endPos = cmd:find('%(%b[]%)')
    while startPos do
        local content = cmd:sub(startPos + 2, endPos - 2) -- Extract the content within parentheses
        local result = core.worker.unwrapcmd(session, content) or ''
        local processedContent = session:run(result) or ''
        cmd = cmd:sub(1, startPos - 1) .. processedContent .. cmd:sub(endPos + 1)
        startPos, endPos = cmd:find('%(%b[]%)')
    end
    return cmd
end

core.worker.spacendclean = function(session,cmd)
    return string.gsub(cmd, "^%s*(.-)%s*$", "%1")
end

core.worker.segfault = function(session,cmd)
    session.temp.cmdname = session.temp.cmdname or session.api.string.split(cmd,'%s+')[1]
    if not session.cmd[session.temp.cmdname] then
        if session.data.worker[session.temp.cmdname] then
            print(session.temp.cmdname .. ' command exist but is not loaded!')
        else
            print(session.temp.cmdname .. ' command do not exist!')
        end
        session.temp['break'] = true
    end
end

core.worker["!"] = function(session,cmd)
    if type(cmd) == 'string' and session.api.string.includes(cmd,'!') then
        print(cmd)
        local splited = session.api.string.split(cmd,"%s+")
        if session.api.string.includes(splited[1],"!") then
            local cmdsplited = session.api.string.split(splited[1],"!")
            local newcmd = cmd
            for i, v in ipairs(cmdsplited) do
                if v == '' then
                    break
                end
                local wlname = session.api.string.replace(v,"!")
                if session.pipeline[wlname] then
                    newcmd = session:run(session.api.string.replace(newcmd,v),session.pipeline[wlname])
                else
                    print("pipeline " .. wlname .. " does not exist.")
                end
            end
            return session.api.string.replace(cmd,splited[1] .. "%s+")
        end
    end
end

core.worker.cmdname = function(session,cmd)
    session.temp.cmdname = session.api.string.split(cmd,"%s+")[1]
    return cmd
end

core.worker.commander = function(session,cmd)
    local result
    local split = session.api.string.split(cmd, " ")
    local args = {}
    for i = 2, #split, 1 do
        table.insert(args,split[i])
    end
    result = session.cmd[split[1]](session,args,cmd) or ''
    return result
end



return core