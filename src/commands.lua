local cmd = {}


cmd.exit = function(session,args)
    session.temp.exit = true
    session.temp['break'] = true
end

cmd.run = function(session,args)
    session.api.run(session,session.api.file.load.text(args[1]))
end
cmd['--'] = function() end
cmd.get = function(session, args, cmd)
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

cmd.def = function(session,args,cmd)
    session.cmd[args[1]] = (session.api.load("return function(session,args,cmd) " .. cmd:gsub('def '.. args[1] ,'',1) .. ' end'))()
end

cmd[">"] = function(session,args, cmd)
    local result = session.api.load('return ' .. cmd:gsub('> ','')) or function() end
    result = result() or ''
    return result
end

-- new commands
-- new commands
-- new commands

cmd.set = function(session,args)
    local found = false
    local camp = session
    for i = 1, #args-2, 1 do
        if camp[i] then
            camp = session.api.table.recurse(camp,tonumber(args[i]) or args[i])
        else
            camp[i] = {}
        end
        
    end
    local result = args[#args]
    if tonumber(args[#args]) then
        result = tonumber(args[#args])
    elseif args[#args] == 'true' or args[#args] == 'false' then
        result = args[#args] == 'true' and true or false
    end

    if result == 'nil' then
        camp[args[#args-1]] = nil
    else
        camp[args[#args-1]] = result
    end
end

cmd['$'] = function(session,args,cmd)
    local lcmd = 'os.execute("' .. session.api.string.replace(cmd, "%$")  .. '")'
    assert(session.api.load(lcmd))()
end

cmd.exposes = function(_session,args)
    session = _session
end

cmd.hides = function(_session,args)
    session = nil
end

cmd.terminate = function(session,args)
    os.exit()
end

cmd.echo = function(session,args)
    local txt = ''
    for i, v in ipairs(args) do
        txt = txt .. v .. ' '
    end
    session:log(txt,rl.DARKGREEN)
    return txt
end

cmd.help = function(session,args)
    session:log("Avaliable commands:")
    for k, v in pairs(session.cmd) do
        session:log('     ' .. k .. ', ',rl.DARKBROWN) 
    end
end

cmd["---"] = function(session,args)
    local txt = ''
    for i, v in ipairs(args) do
        txt = txt .. v .. ' '
    end
    return txt
end

cmd.pipe = function(session,args)
    local pipe = args[1] or 'parser'
    args[1] = nil
    args = session.api.array.clear(args)
    local cmd = table.concat(args,' ')
    session:run(cmd, session.pipeline[pipe])
end

cmd.shufflecubes = function(session)
    for i, cube in ipairs(session.scene.cube) do
        cube.position.x = session.api.random(-7,7)
        cube.position.y = session.api.random(-7,7)
        cube.position.z = session.api.random(-7,7)
        cube.size.x = session.api.random(0.1,7)
        cube.size.y = session.api.random(0.1,7)
        cube.size.z = session.api.random(0.1,7)
    end
end

cmd.randomcubes = function(session,args)
    for i = 1, session.api.random(args[1] or 3, args[2] or 21), 1 do
        session.api.autonew.cube(session,0,0,0,1,1,1)
    end
    cmd.shufflecubes(session)
end

cmd.cleancubes = function(session,args)
    session.scene.cube = {}
end

cmd.compile = function(session, args)
    if not session.api.unix() then
        session:log('windows compilation is not avaliable yet.',rl.MAROON)
        return
    end
    session:log('Compiling...',rl.DARKGREEN)
    local libcheck,lposition = session.api.array.includes(args,'-L')
    local includecheck,iposition = session.api.array.includes(args,'-I')
    local ccheck,cposition = session.api.array.includes(args,'-C')
    local jcheck,jposition = session.api.array.includes(args,'-J')
    session.data.compile = 
    {
        ccompiler = ccheck and session.api.string.replace(args[cposition],"-C",'') or 'gcc',
        vitrine = session.api.array.includes(args,'-V') and true or false,
        lib = libcheck and args[lposition] or '',
        include = includecheck and args[iposition] or "-I/usr/include/luajit-2.1",
        luajitpath = jcheck and session.api.string.replace(args[cposition],"-J",'') or "luajit"
    }
    local luajitpath = session.data.compile.luajitpath
    local ccompiler = session.data.compile.ccompiler
    
    os.execute('rm -r build')
    
    local places = {'build' ,'build/src', 'build/src/util', 'build/lib', 'build/lib/raylib'}
    for k, v in pairs(places) do
        os.execute("mkdir " .. v)
    end
    os.execute(luajitpath .. ' -b main.lua build/main.h') 
    os.execute("cp src/wrapper.c build/main.c")
    os.execute(ccompiler .. " -o " .. (session.api.string.includes(ccompiler,'mingw') and "build/plec.exe" or "build/plec") .. " build/main.c "..(session.data.compile.include or "-I/usr/include/luajit-2.1") ..(session.data.compile.lib or "").. " -lluajit-5.1")
    local files = session.api.file.list()
    for _, file in ipairs(files) do
        if not session.api.string.includes(file, 'compile.lua') and not session.api.string.includes(file, 'main.lua') and session.api.string.includes(file, '.lua') then
            local newfile = session.api.string.replace(session.api.string.replace(file, '//', '/build/'), '.lua', '.raw')
            os.execute(luajitpath .. ' -b ' .. file .. ' ' .. newfile)
        end
    end
    os.execute('cp -r lib/raylib build/lib/')
    os.execute('rm build/main.c build/main.h')
    if session.data.compile.vitrine then
        os.execute("cp -r example build/example")
    end
    session:log('comilation done, check ./build',rl.DARKGREEN)
    session.data.compile = nil
end

cmd.clear = function(session,args)
    if not args[1] or args[1] == 'console' or args[1] == 'terminal' then
        os.execute(session.api.unix("clear","clr"))
    elseif args[1] == 'logs'then
        
        if session.console.active then
            for k, v in pairs(session.scene.text) do
                if session.api.array.includes(session.console.logs,v) or v == session.console.buffer then
                    session.scene.text[k] = nil
                end
            end
            session.scene.text = session.api.array.clear(session.scene.text)
            session.api.autonew.text(session,'f1 to open console',session.defaults.text.size,session.window.height - (session.defaults.text.size*3),rl.BLACK,session.defaults.text.size)
        end
        session.console.logs = {}
        session.console.active = false
        session.console.virgin = true
        session.console.active = true
    elseif session.api.array.includes(session.api.array.keys(session.scene),args[1]) then
        session.scene[args[1]] = {}
    elseif session.api.array.includes(session.api.array.keys(session),args[1]) then
        session[args[1]] = {}
    elseif session.api.string.includes(args[1],'session.') then
        local splited = {}
        for word in args[1]:gmatch("[^.]+") do
            table.insert(splited, word)
        end
        local target = session
        for i = 1, #splited-1, 1 do
            target = session.api.table.recurse(target,splited[i]) or target
        end
        target[splited[#splited]] = {}
    end
end

return cmd