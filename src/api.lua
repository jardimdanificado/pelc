local api = require('src.util')

api.console.formatcmd = function(command)
    command = command:gsub("%s+", " ")
    command = command:gsub('; ', ';')
    command = command:gsub(' ;', ';')
    command = command:gsub(';\n', ';')
    command = command:gsub('\n;', ';')
    
    return api.string.split(command, ';')
end

api.console.colors = 
{
    black = '\27[30m',
    reset = '\27[0m',
    red = '\27[31m',
    green = '\27[32m',
    yellow = '\27[33m',
    blue = '\27[34m',
    magenta = '\27[35m',
    cyan = '\27[36m',
    white = '\27[37m',
}

api.console.colorstring = function(str,color)
    return api.console.colors[color] .. str .. api.console.colors.reset
end

api.console.boldstring = function(str)
    return "\27[1m" .. str .. "\27[0m"
end

api.console.randomcolor = function()
    return api.console.colors[api.console.api.random(3,#api.console.colors)]--ignores black and reset
end

api.console.movecursor = function(x, y)
    return io.write("\27[" .. x .. ";" .. y .. "H")
end

api.getlink =  function(str)
    local pattern = "&(%w+)"
    local match = string.match(str, pattern)
    local result = string.gsub(str, pattern, "", 1)
    return ('&' .. match), result
end

api.work = function(session,worker,cmd)
    if session.time % worker.timer == 0 then
        local tmp = worker.func(session,cmd,worker)
        cmd = type(tmp) == "string" and tmp or cmd
        return cmd
    end
    return cmd
end

api.run = function(session, command)
    if not session.temp.keep then        
        session.temp = {}
    else
        session.temp.keep = false
    end

    command = command or io.read()
    local result = ''
    for i, cmd in ipairs(api.console.formatcmd(command)) do
        for k, worker in pairs(session.pre_worker) do
            cmd = api.work(session,worker,cmd)
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
        for k, worker in pairs(session.post_worker) do
            cmd = api.work(session,worker,cmd)
            if session.temp.wskip or session.temp.skip then
                break
            end
        end
    end
    return result
end

api.spawn = function(session,name,position,newid) 
    local worker = session.data.worker[name]
    if type(position) == "string" then
        newid = position
        position = worker.position == 'pre' and #session.pre_worker+1 or #session.post_worker+1
    elseif not position then
        position = worker.position == 'pre' and #session.pre_worker+1 or #session.post_worker+1
    end
    
    worker.id = name or newid
    if worker.position == 'post' then
        table.insert(session.post_worker,position,worker)
    else
        table.insert(session.pre_worker,position,worker)        
    end
    return worker
end

api.loadcmds = function(session,templib)
    templib.worker = templib.worker or {}
    if templib.preload ~= nil then
        templib.preload(session)
    end
    for k, v in pairs(templib.cmd) do
        session.data.cmd[k] = v
        session.cmd[k] = session.data.cmd[k]
    end
    for k, worker in pairs(templib.worker) do
        if type(worker) == 'function' then
            local _worker = 
            {
                id = templib.worker[k .. '_id'] or k,
                timer = templib.worker[k .. '_timer'] or 1,
                position = templib.worker[k .. '_position'] or 'pre',
                func = worker
            }
            session.data.worker[k] = _worker
        elseif type(worker) == 'table' then
            local _worker = 
            {
                id = templib.worker.id or k,
                timer = templib.worker.timer or 1,
                position = templib.worker.position or 'pre',
                func = worker.func
            }
            session.data.worker[k] = _worker
        end
    end
    if templib.setup ~= nil then
        templib.setup(session)
    end
end

api.new = {
    worker = function(func,timer,position,id)
        local worker = {}
        worker.func = func
        worker.timer = timer or 1
        worker.position = position or 'pre'
        worker.id = id or api.id()
        return worker
    end,
    session = function()
        local session = 
        {
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
                            if not api.string.includes(args[k],'lib.') and not api.string.includes(args[k],'/') and not api.string.includes(args[k],'\\') then
                                templib = require('lib.' .. args[k])
                            else
                                templib = require(
                                    api.string.replace(
                                        api.string.replace(
                                            api.string.replace(args[k],'.lua',''),'/','.'),'\\','.'))
                            end
                        end
                        
                        api.loadcmds(session,templib)
                    end,
                    import = function(session,args)
                        if not api.file.exist(args[1]) then
                            return
                        end
                        api.loadcmds(session,dofile(args[1]))
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
                worker=
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
                                if session.data.worker[session.temp.cmdname] then
                                    print(session.temp.cmdname .. ' command exist but is not loaded!')
                                else
                                    print(session.temp.cmdname .. ' command do not exist!')
                                end
                                session.temp.skip = true
                            end
                        end
                    }
                }
            },
            pre_worker = {},
            post_worker = {},
            temp = {},
            run = api.run,
            spawn = api.spawn,
            time = 0,
            api = api,
            cmd = {}
        }
        session.cmd = api.array.clone(session.data.cmd)
        return session
    end
}

api.start = function(session)
    session:spawn("=>","_=>")
    session:spawn("=","_=")
    session:spawn("timepass","_time")
    session:spawn("unwrapcmd","_unwrap")
    session:spawn('unref',"_unref")
    session:spawn("spacendclean","_removeStartAndEndSpaces")
    session:spawn("segfault","_segFault")
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