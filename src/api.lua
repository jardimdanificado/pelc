local api = require('src.util')

api.formatcmd = function(command)
    command = command:gsub("%s+", " ")
    command = command:gsub('; ', ';')
    command = command:gsub(' ;', ';')
    command = command:gsub(';\n', ';')
    command = command:gsub('\n;', ';')
    
    return api.string.split(command, ';')
end

api.getlink =  function(str)
    local pattern = "&(%w+)"
    local match = string.match(str, pattern)
    local result = string.gsub(str, pattern, "", 1)
    return ('&' .. match), result
end

api.stepin = function(session,step,cmd)
    if session.time % step.timer == 0 then
        local tmp = step.func(session,cmd,step)
        cmd = type(tmp) == "string" and tmp or cmd
        return cmd
    end
    return cmd
end

api.sadd = function(session,name,position,newid) 
    local step = session.data.step[name]
    if type(position) == "string" then
        newid = position
        position = step.position == 'pre' and #session.pre_step+1 or #session.post_step+1
    elseif not position then
        position = step.position == 'pre' and #session.pre_step+1 or #session.post_step+1
    end
    
    step.id = name or newid
    if step.position == 'post' then
        table.insert(session.post_step,position,step)
    else
        table.insert(session.pre_step,position,step)        
    end
    return step
end

api.loadcmds = function(session,templib)
    templib.step = templib.step or {}
    if templib.preload ~= nil then
        templib.preload(session)
    end
    for k, v in pairs(templib.cmd) do
        session.data.cmd[k] = v
        session.cmd[k] = session.data.cmd[k]
    end
    for k, step in pairs(templib.step) do
        if type(step) == 'function' then
            local _step = 
            {
                id = templib.step[k .. '_id'] or k,
                timer = templib.step[k .. '_timer'] or 1,
                position = templib.step[k .. '_position'] or 'pre',
                func = step
            }
            session.data.step[k] = _step
        elseif type(step) == 'table' then
            local _step = 
            {
                id = templib.step.id or k,
                timer = templib.step.timer or 1,
                position = templib.step.position or 'pre',
                func = step.func
            }
            session.data.step[k] = _step
        end
    end
    if templib.setup ~= nil then
        templib.setup(session)
    end
end

api.new = {
    step = function(func,timer,position,id)
        local step = {}
        step.func = func
        step.timer = timer or 1
        step.position = position or 'pre'
        step.id = id or api.id()
        return step
    end,
    session = function()
        local session = 
        {
            pre_step = {},
            post_step = {},
            temp = {},
            run = api.run,
            sadd = api.sadd,
            time = 0,
            api = api,
            cmd = {},
            data = 
            {
                cmd =
                {
                    run = function(session,args)
                        api.run(session,api.file.load.text(args[1]))
                    end,
                    require = function(session,args)
                        local templib
                        for k, v in pairs(args) do
                            if not api.string.includes(v,'lib.') and not api.string.includes(v,'/') and not api.string.includes(v,'\\') then
                                templib = require('lib.' .. v)
                            else
                                templib = require(
                                    api.string.replace(
                                        api.string.replace(
                                            api.string.replace(v,'.lua',''),'/','.'),'\\','.'))
                            end
                            api.loadcmds(session,templib)
                        end
                        
                    end,
                    import = function(session,args)
                        for k, v in pairs(args) do
                            if not api.file.exist(v) then
                                return
                            end
                            api.loadcmds(session,dofile(v))
                        end
                        
                    end,
                    ['--'] = function() end,
                    set = function(session,args, cmd)
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
                    end,
                    def = function(session,args,cmd)
                        session.cmd[args[1]] = (session.api.load("return function(session,args,cmd) " .. cmd:gsub('def '.. args[1] ,'',1) .. ' end'))()
                    end,
                    load = function(session,args)
                        if not session.data.cmd[args[1]] then
                            print(args[1] .. ' command does not exist.')
                        end
                        session.cmd[args[1]] = session.data.cmd[args[1]]
                    end,
                    autodef = function(session,args,cmd)
                        session.data.cmd[args[1]] = (session.api.load("return function(session,args,cmd) " .. cmd:gsub('autodef '.. args[1] ,'',1) .. ' end'))()
                        session.cmd[args[1]] = session.data.cmd[args[1]]
                    end,
                    [">"] = function(session,args, cmd)
                        local result = session.api.load('return ' .. cmd:gsub('> ','')) or function() end
                        result = result() or ''
                        return result
                    end,
                },
                step=
                {
                    ['='] = 
                    {
                        id = "=",
                        timer = 1,
                        position = "pre",
                        func = function(session, cmd)
                            local split = api.string.split(cmd," ")
                            if split[2] == '=' then
                                cmd = cmd:gsub("=",' = ')
                                cmd = cmd:gsub("%s+=%s+",' ')
                                cmd = "set " .. cmd
                            end
                            return cmd
                        end
                    },
                    ['=>'] = 
                    {
                        id = "=>",
                        timer = 1,
                        position = "pre",
                        func = function(session, cmd)
                            local split = api.string.split(cmd," ")
                            if split[2] == '=>' then
                                cmd = cmd:gsub("=>",'')
                                cmd = "def " .. cmd
                            end
                            return cmd
                        end
                    },
                    unref =
                    {
                        id = "unref",
                        timer = 1,
                        position = 'pre',
                        func = function(session, cmd)
                            if api.string.includes(cmd, '&') then
                                cmd = cmd:gsub("&%s+", "&")
                                local newc = cmd
                                local links = {}
                                while api.string.includes(newc,"&") == true do
                                    local link,result = api.getlink(newc)
                                    newc = result
                                    table.insert(links,link)
                                end
                                for i, link in ipairs(links) do
                                    if session.data[link:gsub('&','')] then
                                        cmd = cmd:gsub(link,api.stringify(session.data[link:gsub('&','')]))
                                    else
                                        print(link .. ' has no value.')
                                        session.temp.skip = true
                                    end
                                    
                                end
                            end
                            return cmd
                        end,
                    },
                    unwrapcmd = 
                    {
                        id = "unwrapcmd",
                        timer = 1,
                        position = 'pre',
                        func = function(session, cmd)
                            if api.string.includes(cmd, '!(') or api.string.includes(cmd, '!%b(') then
                                local startPos, endPos = cmd:find('!%((.-)%)!')
                                while startPos do
                                    local newstr = cmd:sub(startPos, endPos)
                                    local content = newstr:match('!%((.-)%)!')  -- Extract the content within parentheses
                                    local result = session:run(content) or ''
                                    cmd = cmd:sub(1, startPos - 1) .. result .. cmd:sub(endPos + 1)
                                    startPos, endPos = cmd:find('!%((.-)%)!')
                                end
                            end
                            return cmd
                        end,
                    },
                    spacendclean = 
                    {
                        id = "spacendclean",
                        timer = 1,
                        position = 'pre',
                        func = function(session,cmd)
                            return string.gsub(cmd, "^%s*(.-)%s*$", "%1")
                        end,
                    },
                    timepass = 
                    {
                        id = "timepass",
                        timer = 1,
                        position = 'pre',
                        func = function(session)
                            session.time = session.time + 1
                        end
                    },
                    segfault = 
                    {
                        id = "segfault",
                        timer = 1,
                        position = 'pre',
                        func = function(session,cmd)
                            session.temp.cmdname = session.temp.cmdname or api.string.split(cmd,'%s+')[1]
                            if not session.cmd[session.temp.cmdname] then
                                if session.data.step[session.temp.cmdname] then
                                    print(session.temp.cmdname .. ' command exist but is not loaded!')
                                else
                                    print(session.temp.cmdname .. ' command do not exist!')
                                end
                                session.temp.skip = true
                            end
                        end
                    },
                    ["@"] = 
                    {
                        id = "@",
                        timer = 1,
                        position = 'pre',
                        func = function(session,cmd)
                            return cmd:gsub("%@","%&")
                        end
                    }
                }
            }
        }
        session.cmd = api.array.clone(session.data.cmd)
        return session
    end
}

api.getline = function()
    io.write("> ")
    local str = io.read()
    return str
end

api.run = function(session, command)
    if not session.temp.keep then        
        session.temp = {}
    else
        session.temp.keep = false
    end

    command = command or api.getline()
    local result = ''
    for i, cmd in ipairs(api.formatcmd(command)) do
        for k, step in pairs(session.pre_step) do
            cmd = api.stepin(session,step,cmd)
            if session.temp.wskip or session.temp.skip then
                break
            end
        end
        session.temp.cmdname = api.string.split(cmd,"%s+")[1]
        if not session.temp.skip or not session.temp.cskip then
            split = api.string.split(cmd, " ")
            local args = {}
            for i = 2, #split, 1 do
                table.insert(args,split[i])
            end
            result = (session.cmd[split[1]] or session.cmd['--'])(session,args,cmd)
        end
        for k, step in pairs(session.post_step) do
            cmd = api.stepin(session,step,cmd)
            if session.temp.wskip or session.temp.skip then
                break
            end
        end
    end
    return result
end

api.start = function(session)
    session:sadd("=>","_=>")
    session:sadd("=","_=")
    session:sadd("@","_@")
    session:sadd("timepass","_time")
    session:sadd("unwrapcmd","_unwrap")
    session:sadd('unref',"_unref")
    session:sadd("spacendclean","_removeStartAndEndSpaces")
    session:sadd("segfault","_segFault")
    local laterscript = {}
    local skip = false
    for i, v in ipairs(arg) do
        if skip ~= false then
            session:run(skip .. v)
            skip = false
        elseif v == '-l' then
            skip = "import "
        elseif api.string.includes(v,'-l') then
            session:run("require lib." .. api.string.replace(v,'-l',''))
        elseif api.string.includes(v,'.plec') then
            table.insert(laterscript,v)
        end
    end
    for i, v in ipairs(laterscript) do
        session:run(api.file.load.text(v))
    end
    while not session.temp.exit do
        session:run()
    end
    session.temp.exit = nil
end

return api