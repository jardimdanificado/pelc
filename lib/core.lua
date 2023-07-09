local core = {}
core.cmd = {}
core.step = {}

core.cmd.exit = function(session,args)
    session.temp.exit = true
end
core.cmd.run = function(session,args)
    session.api.run(session,session.api.file.load.text(args[1]))
end
core.cmd['--'] = function() end
core.cmd.set = function(session,args, cmd)
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
core.cmd.unset = function(session,args)
    session.data[args[1]] = nil
    session.api.array.clear(session.data)
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

--------------------- STEPS
-- STEPS
--------------------- STEPS

core.step['='] = 
{
    id = "=",
    position = "pre",
    func = function(session, cmd)
        local split = session.api.string.split(cmd," ")
        if split[2] == '=' then
            cmd = cmd:gsub("=",' = ')
            cmd = cmd:gsub("%s+=%s+",' ')
            cmd = "set " .. cmd
        end
        return cmd
    end
}
core.step['=>'] = 
{
    id = "=>",
    position = "pre",
    func = function(session, cmd)
        local split = session.api.string.split(cmd," ")
        if split[2] == '=>' then
            cmd = cmd:gsub("=>",'')
            cmd = "autodef " .. cmd
        end
        return cmd
    end
}
core.step.unref =
{
    id = "unref",
    position = 'pre',
    func = function(session, cmd)
        if session.api.string.includes(cmd, '@') then
            cmd = cmd:gsub("@%s+", "@")
            local newc = cmd
            local links = {}
            while session.api.string.includes(newc,"@") == true do
                local link,result = session.api.getlink(newc,"@")
                newc = result
                table.insert(links,link)
            end
            for i, link in ipairs(links) do
                if session.data[link:gsub('@','')] then
                    cmd = cmd:gsub(link,session.api.stringify(session.data[link:gsub('@','')]))
                else
                    print(link .. ' has no value.')
                    session.temp.skip = true
                end
                
            end
        end
        return cmd
    end,
}

local function processCommand(session, cmd)
    local startPos, endPos = cmd:find('%(%b[]%)')
    while startPos do
        local content = cmd:sub(startPos + 2, endPos - 2) -- Extract the content within parentheses
        local result = processCommand(session, content) or ''
        local processedContent = session:run(result) or ''
        cmd = cmd:sub(1, startPos - 1) .. processedContent .. cmd:sub(endPos + 1)
        startPos, endPos = cmd:find('%(%b[]%)')
    end
    return cmd
end

core.step.unwrapcmd = 
{
    id = "unwrapcmd",
    position = 'pre',
    func = processCommand,
}
core.step.spacendclean = 
{
    id = "spacendclean",
    position = 'pre',
    func = function(session,cmd)
        return string.gsub(cmd, "^%s*(.-)%s*$", "%1")
    end,
}

core.step.segfault = 
{
    id = "segfault",
    position = 'pre',
    func = function(session,cmd)
        session.temp.cmdname = session.temp.cmdname or session.api.string.split(cmd,'%s+')[1]
        if not session.cmd[session.temp.cmdname] then
            if session.data.step[session.temp.cmdname] then
                print(session.temp.cmdname .. ' command exist but is not loaded!')
            else
                print(session.temp.cmdname .. ' command do not exist!')
            end
            session.temp.skip = true
        end
    end
}
core.step["@"] = 
{
    id = "@",

    position = 'pre',
    func = function(session,cmd)
        return cmd:gsub("%@","%@")
    end
}

return core