local lib = {cmd = {},worker = {}}

lib.cmd['worker.spawn'] = function(session,args)
    if not session.data.worker[args[1]] then
        print(args[1] .. ' command do not exist.')
    else
        session:spawn(args[1], args[2], args[3])
    end
end

lib.cmd["worker.help"] = function(session,args)
    print("\27[32mPre_workers:\27[0m")
    for k, v in pairs(session.pre_worker) do
        print('[' .. k .. '] : ' .. v.id .. ',')
    end
    print()
    print("\27[32mPost_workers:\27[0m")
    for k, v in pairs(session.post_worker) do
        print(v.id)
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

lib.cmd["worker.despawn"] = function(session,args)
    if not args[2] then
        args[2] = args[1]
        args[1] = 'pre'
    end
    session[args[1] .. '_worker'][tonumber(args[2])] = nil
    session[args[1] .. '_worker'] = session.api.array.clear(session[args[1] .. '_worker'])
end

return lib 