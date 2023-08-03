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

api.process = function(session, cmd, pipeline)
    local result
    pipeline = pipeline or session.pipeline.main
    for i = 1, #pipeline do
        if session.temp["break"]then
            session.temp['break'] = nil
            break
        end
        if not session.temp.skip then
            result = pipeline[i].func(session,result or cmd) 
            if result then
                cmd = result
            end
        else
            session.temp.skip = nil
        end
    end
    return result
end

api.workeradd = function(session,name,position,newid,custompipeline) 
    local wlist = session.pipeline[custompipeline or 'main']

    local worker = 
    {
        id = '',
        func = session.data.worker[name or ''].func or ''
    }

    if type(name) == 'function' then
        worker.func = name
        name = session.api.id()
    end

    if type(position) == "string" then
        newid = position
        position = #wlist+1 
    elseif not position then
        position = #wlist+1 
    end
    
    worker.id = newid or name
    table.insert(wlist,position,worker)
    return worker
end

api.workerrm = function(session,index,custompipeline)
    local wlist = session.pipeline[custompipeline] or session.pipeline.main
    index = index or 1
    if type(index) == 'string' then
        for i, v in ipairs(wlist) do
            if v.id == index then
                index = i
            end
        end
    end
    wlist[index] = nil
    if custompipeline then
        session.pipeline[custompipeline] = session.api.array.clear(wlist)
    else
        session.pipeline.main = session.api.array.clear(wlist)
    end
end

api.workerreplace = function(session,position,workername,optnewid) 
    local reference
    if type(position) == 'string' then
        for k, v in pairs(session.pipeline.main) do
            if v.id == position then
                reference = v
            end
        end
        if not reference then
            return
        end
    end
    reference = reference or session.pipeline.main[position]
    reference.func = session.data.worker[workername]
    reference.id = optnewid or reference.id
    return reference
end

api.arghandler = function(session,args)
    local laterscript = {}
    local skip = false
    for i, v in ipairs(args or {}) do
        if skip ~= false then
            api.legacyrun(session, skip .. v)
            skip = false
        elseif v == '-l' then
            skip = "import "
        elseif api.string.includes(v,'-l') then
            api.legacyrun(session,"require lib." .. api.string.replace(v,'-l',''))
        elseif api.string.includes(v,'-gl') then
            api.gl = api.string.replace(v,'-gl','')
        elseif api.string.includes(v,'.plec') then
            table.insert(laterscript,v)
        end
    end
    for i, v in ipairs(laterscript) do
        api.run(session,api.file.load.text(v))
    end
end

api.loadcmds = function(session,templib)
    templib.worker = templib.worker or {}
    if session.data.preload and templib.preload ~= nil then
        templib.preload(session)
    end
    if templib.cmd then
        for k, v in pairs(templib.cmd) do
            session.data.cmd[k] = v
            session.cmd[k] = session.data.cmd[k]
        end
    end
    if templib.worker then
        for k, func in pairs(templib.worker) do
            session.data.worker[k] = api.new.worker(func,k)
        end
    end
    if session.data.setup and templib.setup ~= nil then
        templib.setup(session)
    end
end

api.new = {
    worker = function(func,id)
        return {
            func = func,
            id = id
        }
    end,
    session = function()
        local session = 
        {
            pipeline = {main={}},
            temp = {},
            run = api.run,
            process = api.process,
            workeradd = api.workeradd,
            workerrm = api.workerrm,
            api = api,
            cmd = {},
            data = 
            {
                preload = true,
                setup = true,
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
                worker = {}
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

api.legacyrun = function(session, command)
    command = command or api.getline()
    local result = ''
    for i, cmd in ipairs(api.formatcmd(command)) do
        local split = api.string.split(cmd, " ")
        local args = {}
        for i = 2, #split, 1 do
            table.insert(args,split[i])
        end
        result = (session.cmd[split[1]] or session.cmd['--'])(session,args,cmd) or cmd
    end
    return result
end

api.run = function(session, command, pipeline)
    command = command or api.getline()
    local result = ''
    for i, cmd in ipairs(api.formatcmd(command)) do
        
        result = session:process(cmd,pipeline or session.pipeline.sysprocessor) or '' -- pipeline can be nil ofc
        --print('cmd:' .. api.string.split(cmd,' ')[1] .. '\nreturn:' .. result)
    end
    return result
end

api.version = '0.5.5'

api.gl = '21'

return api