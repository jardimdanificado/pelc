local compile = {cmd = {}}

compile.cmd.compile = function(session, args)
    local luajitpath = args and args[1] or 'luajit'
    local ccompiler = args and args[2] or 'gcc'
    if session.data.ccompiler then
        ccompiler = session.data.ccompiler
    end
    os.execute('rm -r build')
    
    local places = {'build' ,'build/src', 'build/src/util', 'build/lib'}
    for k, v in pairs(places) do
        os.execute("mkdir " .. v)
    end
    os.execute(luajitpath .. ' -b main.lua build/main.h') 
    os.execute("cp src/wrapper.c build/main.c")
    os.execute(ccompiler .. " -o " .. (session.api.string.includes(ccompiler,'mingw') and "build/plec.exe" or "build/plec") .. " build/main.c "..(session.compile.include or "-I/usr/include/luajit-2.1") ..(session.compile.lib or "").. " -lluajit-5.1")
    local files = session.api.file.list()
    for k, file in pairs(files) do
        if not session.api.string.includes(file, 'compile.lua') and not session.api.string.includes(file, 'main.lua') and session.api.string.includes(file, '.lua') then
            local newfile = session.api.string.replace(session.api.string.replace(file,'//','/build/'),'.lua','.raw')
            os.execute(luajitpath .. ' -b ' .. file .. ' ' .. newfile)
        end
    end
    os.execute('rm build/main.c build/main.h')
    if session.data.vitrine then
        os.execute("cp example build/example")
    end
    session.data.vitrine = nil
    session.data.ccompiler = nil
    os.exit()
end

compile.setup = function(session,args)
    compile.cmd.compile(session,args)
end

return compile