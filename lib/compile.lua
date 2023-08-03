local compile = {cmd = {}}

compile.preload = function(session,args)
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
end

compile.cmd.cpreload = compile.preload

compile.cmd.compile = function(session, args)
    if args and args[1] then
        compile.cmd.cpreload(session,args)
    end
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
    session.data.compile = nil
end

compile.setup = function(session,args)
    compile.cmd.compile(session,args)
    os.exit()
end

compile.cmd.csetup = compile.setup

return compile