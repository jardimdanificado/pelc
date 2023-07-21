local lib = {cmd = {},worker = {}}

lib.cmd['worker.add'] = function(session,args)
    if not session.data.worker[args[1]] then
        print(args[1] .. ' command do not exist.')
    else
        session:workeradd(args[1], args[2], args[3])
    end
end

lib.cmd["worker.help"] = function(session,args)
    print("\27[32mworkers:\27[0m")
    for k, v in pairs(session.workerlist[args[1]] or session.workerlist.main) do
        print('[' .. k .. '] : ' .. v.id .. ',')
    end
    print('--end')
end

lib.cmd["worker.lhelp"] = function(session,args)
    print("\27[32mLoaded workers:\27[0m")
    for k, v in pairs(session.data.worker) do
        print('[' .. k .. '] : ' .. session.api.stringify(v):gsub('\n','') .. ',')
    end
    print('--end')
end

lib.cmd["worker.rm"] = function(session,args)
    session:workerrm(tonumber(args[1]) or args[1],tonumber(args[2]) or args[2])
end

return lib 