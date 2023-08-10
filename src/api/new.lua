local new = {}

new.scene = function(session,_type)
    _type = _type or '3d'
    local _3d = _type == '3d' and true or false
    local scene =  
    {
        type = _type,
        text = {},
        image = {},
        model = _3d and {} or nil,
        cube = _3d and {} or nil,
        backgroundcolor = rl.LIGHTGRAY,
        camera = rl.new("Camera", {
            position = rl.new("Vector3", 10, 10, 10),
            target = rl.new("Vector3", 0, 0, 0),
            up = rl.new("Vector3", 0, 1, 0),
            fovy = 45,
            type = rl.CAMERA_PERSPECTIVE
        }),
        framerate = 24,
        frame = 0,
        rendertexture = rl.new("RenderTexture"),
    }
    return scene
end

new.text = function(session,text,px,py,color,size)
    local text = {file=text,position={x=px or 0,y=py or 0},color = color or rl.BLACK, size = size or 10}
    return text
end

new.cube = function(session,px,py,pz,sx,sy,sz,color,wired)
    local cube = {wired = wired or true,position={x=px or 0,y=py or 0,z=pz or 0},size={x=sx or 1,y=sy or 1,z=sz or 1},color = color or rl.BLACK}
    return cube
end

new.model = function(session,objpath,px,py,pz,sx,sy,sz,color,wired)
    local model = 
    {
        wired = wired or true,
        position=
        {
            x=px or 0,
            y=py or 0,
            z=pz or 0
        },
        size=
        {
            x=sx or 1,
            y=sy or 1,
            z=sz or 1
        },
        rotationaxis = 
        {
            x = 0,
            y = 1,
            z = 0,
        },
        rotation = 
        {
            x = 0,
            y = 0,
            z = 0,
        },
        color = color or rl.WHITE,
        playing = false,
        currentframe = 1,
        active = true,
        file = {},
        framerate = 24
    }
    if session.cache.model[objpath] then
        model.file = session.cache.model[objpath]
    else
        if session.api.string.includes(objpath,'.obj') then
            session.cache.model[objpath] = rl.LoadModel(objpath)
            model.playing = true
            model.file[1] = session.cache.model[objpath]
        else
            if objpath:sub(#objpath,#objpath) ~= '/' and objpath:sub(#objpath,#objpath) ~= '\\' then
                objpath = objpath .. session.api.unix('/','\\')
            end
            local keys = session.api.file.list(objpath)
            for k, v in pairs(keys) do
                local value = session.api.string.replace(session.api.string.replace(session.api.string.replace(session.api.string.replace(v,objpath,''),'/'),'\\'),'.obj')
                keys[k] = tonumber(value)
            end
            local keymin = math.min(session.api.array.unpack(keys))
            local keymax = math.max(session.api.array.unpack(keys))
            model.playing = true
            model.file = {}
            for i = keymin, keymax, 1 do
                print(i)
                table.insert(model.file,rl.LoadModel(objpath .. i .. '.obj'))
            end
        end
    end
    return model
end

return new