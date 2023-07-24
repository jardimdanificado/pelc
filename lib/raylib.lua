local raylib = {cmd = {}}

raylib.setup = function(session)
    if rl ~= nil then
        session.api.raylib = rl -- raylua set a global rl variable so you dont really need this session one
        session.data.raylib = true
        for k, v in pairs(rl) do
            raylib.cmd["raylib" .. k] = function(session,args)
                for i, v in ipairs(args) do
                    args[i] = tonumber(v) or v
                end
                return v(session.api.array.unpack(args))
            end
        end
    else
        print("raylib is not avaliable.")        
    end
end



return raylib
