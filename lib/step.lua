local lib = {cmd = {},step = {}}

lib.cmd['step.add'] = function(session,args)
    if not session.data.step[args[1]] then
        print(args[1] .. ' command do not exist.')
    else
        session:sadd(args[1], args[2], args[3])
    end
end

lib.cmd["step.help"] = function(session,args)
    print("\27[32mPre_steps:\27[0m")
    for k, v in pairs(session.pre_step) do
        print('[' .. k .. '] : ' .. v.id .. ',')
    end
    print()
    print("\27[32mPost_steps:\27[0m")
    for k, v in pairs(session.post_step) do
        print(v.id)
    end
    print('--end')
end

lib.cmd["step.lhelp"] = function(session,args)
    print("\27[32mLoaded steps:\27[0m")
    for k, v in pairs(session.data.step) do
        print('[' .. k .. '] : ' .. session.api.stringify(v):gsub('\n','') .. ',')
    end
    print('--end')
end

lib.cmd["step.rm"] = function(session,args)
    if not args[2] then
        args[2] = args[1]
        args[1] = 'pre'
    end
    session[args[1] .. '_step'][tonumber(args[2])] = nil
    session[args[1] .. '_step'] = session.api.array.clear(session[args[1] .. '_step'])
end

return lib 