local api = require('src.util')

api.formatcmd = function(command)
    command = command:gsub("%s+", " ")
    command = command:gsub('; ', ';')
    command = command:gsub(' ;', ';')
    command = command:gsub(';\n', ';')
    command = command:gsub('\n;', ';')
    
    return api.string.split(command, ';')
end

api.getlink =  function(str,linksymbol)
    local pattern = linksymbol .. "(%w+)"
    local match = string.match(str, pattern)
    local result = string.gsub(str, pattern, "", 1)
    return (linksymbol .. match), result
end

api.stepin = function(session,step,cmd)
    local tmp = step.func(session,cmd,step)
    cmd = type(tmp) == "string" and tmp or cmd
    return cmd
end

api.stepadd = function(session,name,position,newid) 
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

api.steprm = function(session,position,index)
    if not index then
        index = position
        position = 'pre'
    end
    if type(index) == 'string' then
        for i, v in ipairs(session.step) do
            if v.id == index then
                index = i
            end
        end
    end
    session[position .. '_step'][index] = nil
    session[position .. '_step'] = session.api.array.clear(session[position .. '_step'])
end

api.arghandler = function(session,args)
    local laterscript = {}
    local skip = false
    for i, v in ipairs(args) do
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
                position = templib.step[k .. '_position'] or 'pre',
                func = step
            }
            session.data.step[k] = _step
        elseif type(step) == 'table' then
            local _step = 
            {
                id = templib.step.id or k,
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
    step = function(func,position,id)
        local step = {}
        step.func = func
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
            stepadd = api.stepadd,
            steprm = api.steprm,
            time = 0,
            api = api,
            cmd = {},
            data = 
            {
                cmd = 
                {
                    require = function(session,args)
                        local templib
                        for k, v in pairs(args) do
                            if not session.api.string.includes(v,'lib.') and not session.api.string.includes(v,'/') and not session.api.string.includes(v,'\\') then
                                templib = require('lib.' .. v)
                            else
                                templib = require(
                                    session.api.string.replace(
                                        session.api.string.replace(
                                            session.api.string.replace(v,'.lua',''),'/','.'),'\\','.'))
                            end
                            session.api.loadcmds(session,templib)
                        end
                        
                    end,
                    import = function(session,args)
                        for k, v in pairs(args) do
                            if not session.api.file.exist(v) then
                                return
                            end
                            session.api.loadcmds(session,dofile(v))
                        end
                    end
                },
                step = {}
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

return api