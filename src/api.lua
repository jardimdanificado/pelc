--[[ nix packages in order to make plec run in replit
{ pkgs }: {
	deps = [
        pkgs.luajit
        pkgs.luajitPackages.luarocks
        pkgs.lua
        pkgs.sumneko-lua-language-server
		pkgs.clang_12
	    pkgs.ccls
	    pkgs.gcc
	    pkgs.glibc
	    pkgs.mesa
		pkgs.xorg.libX11
		pkgs.libGL
		pkgs.libGLU
		pkgs.glfw
		pkgs.xorg.libXcursor
		pkgs.xorg.libXrandr
		pkgs.xorg.libXinerama
		pkgs.xorg.libXi
		pkgs.xorg.libXext
	];
}
]]

local api = require('src.util')

api.version = '0.6'
api.gl = '11'

----------------------------------------------------------------------------
-- ETECETERA
----------------------------------------------------------------------------

api.move3d = function(position, rotation, speed)
    local valorZ, valorX
    local giro = math.floor(rotation / 90.0)
    local resto = rotation - (90.0 * giro)
    local restodoresto = 90.0 - resto
    valorZ = speed - (resto * (speed / 90.0))
    valorX = (speed - (restodoresto * (speed / 90)))

    if giro == 0 then
        position.z = position.z + valorZ
        position.x = position.x + valorX
    elseif giro == 1 then
        position.z = position.z - valorX
        position.x = position.x + valorZ
    elseif giro == 2 then
        position.z = position.z - valorZ
        position.x = position.x - valorX
    elseif giro == 3 then
        position.z = position.z + valorX
        position.x = position.x - valorZ
    end

    return position
end

api.lookat = function(camera, target)
    local direction = rl.Vector3Normalize(rl.Vector3Subtract(target, camera.position))

    -- Calculate the new up vector, making sure it's perpendicular to the direction
    local right = rl.Vector3Normalize(rl.Vector3CrossProduct(camera.up, direction))
    local newUp = rl.Vector3CrossProduct(direction, right)

    -- Calculate the new target position to avoid tilting
    local forward = rl.Vector3Normalize(rl.Vector3Subtract(target, camera.position))
    local newTarget = rl.Vector3Add(camera.position, forward)

    -- Set the new orientation for the camera
    camera.up = newUp
    camera.target = newTarget
end

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

api.pipeadd = function(session,name,position,newid,custompipeline) 
    local wlist = session.pipeline[custompipeline or 'main']
    local pipe = 
    {
        id = '',
        func = session.pipe[name or ''] or ''
    }

    if type(name) == 'function' then
        pipe.func = name
        name = session.api.id()
    end

    if type(position) == "string" then
        newid = position
        position = #wlist+1 
    elseif not position then
        position = #wlist+1 
    end
    
    pipe.id = newid or name
    table.insert(wlist,position,pipe)
    return pipe
end

api.getline = function()
    io.write("> ")
    local str = io.read()
    return str
end

api.set = 
{
    scene = function(session,index)
        session.scene = session.scenes[index]
    end
}

api.shouldPlay = function(framerate, objframerate, currentframe)
    local interval = math.floor(framerate / objframerate)
    return math.ceil(currentframe % interval) < 1
end

api.log = function(session,content,color)
    for k, txt in pairs(session.console.logs) do
        if txt ~= session.console.barra and txt ~= session.console.buffer then
            txt.position.y = txt.position.y - session.defaults.text.size
        end
    end
    table.insert(session.console.logs,api.new.text(nil,content,session.defaults.text.size*2,(session.window.height - (session.defaults.text.size*3)), color or rl.BLACK))
end

----------------------------------------------------------------------------
-- REQUIRES AND IMPORTS
----------------------------------------------------------------------------

api.checklibcache = function(session,path)
    if not session.cache.lib[path] then
        session.cache.lib[path] = require(path)
    else
        print(path .. ' is already cached.')
    end
end

api.requirecmd = function(session,path)
    api.checklibcache(session,path)
    for k, v in pairs(session.cache.lib[path]) do
        session.cmd[k] = v
    end
end

api.requirepipe = function(session,path)
    api.checklibcache(session,path)
    for k, v in pairs(session.cache.lib[path]) do
        session.pipe[k] = v
    end
end

api.importcmd = function(session,path)
    if session.cache.lib[path] then
        print(path .. ' recached.')
    end
    session.cache.lib[path] = dofile(path)
    for k, v in pairs(session.cache.lib[path]) do
        session.cmd[k] = v
    end
end

api.importpipe = function(session,path)
    if session.cache.lib[path] then
        print(path .. ' recached.')
    end
    session.cache.lib[path] = dofile(path)
    for k, v in pairs(session.cache.lib[path]) do
        session.pipe[k] = v
    end
end

api.require = function(session,path)
    api.checklibcache(session,path)
    local checkpipe,checkcmd = false,false
    checkcmd = session.cache.lib[path].cmd and true or false
    checkpipe = session.cache.lib[path].pipe and true or false
    if checkcmd then
        for k, v in pairs(session.cache.lib[path].cmd) do
            session.cmd[k] = v
        end
    end
    if checkpipe then
        for k, v in pairs(session.cache.lib[path].pipe) do
            session.pipe[k] = v
        end
    end
end

api.import = function(session,path)
    local pathfixed = session.api.string.replace(session.api.string.replace(session.api.string.replace(path,'.lua',''),'/','.'),'\\','.')
    if session.cache.lib[pathfixed] then
        print(path .. ' recached.')
    end
    session.cache.lib[pathfixed] = dofile(path)
    local checkpipe,checkcmd = false,false
    checkcmd = session.cache.lib[pathfixed].cmd and true or false
    checkpipe = session.cache.lib[pathfixed].pipe and true or false
    if checkcmd then
        for k, v in pairs(session.cache.lib[pathfixed].cmd) do
            session.cmd[k] = v
        end
    end
    if checkpipe then
        for k, v in pairs(session.cache.lib[pathfixed].pipe) do
            session.pipe[k] = v
        end
    end
end

----------------------------------------------------------------------------
-- RUN AND PROCESS
----------------------------------------------------------------------------

api.process = function(session, cmd, pipeline)
    local result
    pipeline = pipeline or session.pipeline.main
    for i = 1, #pipeline do
        if session.temp["break"]then
            session.temp['break'] = nil
            break
        end
        if not session.temp.skip or session.temp.skip <= 0 then
            result = pipeline[i].func(session,result or cmd) 
            if result then
                cmd = result
            end
        elseif session.temp.skip >= 1 then
            session.temp.skip = session.temp.skip - 1
        end
    end
    session.temp = {}
    return result
end

api.run = function(session, command, pipeline)
    command = command or api.getline()
    local result = ''
    for i, cmd in ipairs(api.formatcmd(command)) do
        result = session:process(cmd,pipeline or session.pipeline.parser)
    end
    return result
end


----------------------------------------------------------------------------
-- api.new
----------------------------------------------------------------------------

api.new = {}

api.new.scene = function(session,_type)
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

api.new.text = function(session,text,px,py,color,size)
    local text = {file=text,position={x=px or 0,y=py or 0},color = color or rl.BLACK, size = size or 10}
    return text
end

api.new.cube = function(session,px,py,pz,sx,sy,sz,color,wired)
    local cube = {wired = wired or true,position={x=px or 0,y=py or 0,z=pz or 0},size={x=sx or 1,y=sy or 1,z=sz or 1},color = color or rl.BLACK}
    return cube
end

api.new.model = function(session,objpath,px,py,pz,sx,sy,sz,color,wired)
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
        render = true,
        file = {},
        framerate = 24
    }
    if session.cache.model[objpath] then
        model.file = session.cache.model[objpath]
    else
        if api.string.includes(objpath,'.obj') then
            session.cache.model[objpath] = rl.LoadModel(objpath)
            model.playing = true
            model.file[1] = session.cache.model[objpath]
        else
            if objpath:sub(#objpath,#objpath) ~= '/' and objpath:sub(#objpath,#objpath) ~= '\\' then
                objpath = objpath .. api.unix('/','\\')
            end
            local keys = api.file.list(objpath)
            for k, v in pairs(keys) do
                local value = api.string.replace(api.string.replace(api.string.replace(api.string.replace(v,objpath,''),'/'),'\\'),'.obj')
                keys[k] = tonumber(value)
            end
            local keymin = math.min(api.array.unpack(keys))
            local keymax = math.max(api.array.unpack(keys))
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

api.new.session = function(width,height,title,flags)
    --[[
        FLAG_VSYNC_HINT, 
        FLAG_FULLSCREEN_MODE, 
        FLAG_WINDOW_RESIZABLE, 
        FLAG_WINDOW_UNDECORATED, 
        FLAG_WINDOW_HIDDEN, 
        FLAG_WINDOW_MINIMIZED, 
        FLAG_WINDOW_MAXIMIZED, 
        FLAG_WINDOW_UNFOCUSED, 
        FLAG_WINDOW_TOPMOST, 
        FLAG_WINDOW_ALWAYS_RUN, 
        FLAG_WINDOW_TRANSPARENT, 
        FLAG_WINDOW_HIGHDPI, 
        FLAG_WINDOW_MOUSE_PASSTHROUGH, 
        FLAG_BORDERLESS_WINDOWED_MODE, 
        FLAG_MSAA_4X_HINT, 
        FLAG_INTERLACED_HINT
    ]]
    flags = flags or {'FLAG_WINDOW_RESIZABLE'}
    
    local session =
    {
        pipe = require 'src.pipes',
        pipeadd= api.pipeadd,
        pipeline = 
        {
            main={}
        },
        process = api.process,
        run = api.run,
        log = api.log,
        api = api,
        console = require 'src.console',
        window = 
        {
            width = 320,
            height = 240,
            title = ('plecVM' .. api.version)
        },
        scenes = {},
        scene = {},
        data = {},
        cache = {lib = {},model={}},
        temp = {},
        cmd = require "src.commands",
        defaults = 
        {
            text = 
            {
                size = 10,
                color = rl.BLACK,
                position = {x=0,y=0}
            },
            backgroundcolor = rl.LIGHTGRAY,
            color = rl.RED
        }
    }

    -- faking for keypad buttons
    session.console.key[320] = "KEY_ZERO"
    session.console.key[321] = "KEY_ONE"
    session.console.key[322] = "KEY_TWO"
    session.console.key[323] = "KEY_THREE"
    session.console.key[324] = "KEY_FOUR"
    session.console.key[325] = "KEY_FIVE"
    session.console.key[326] = "KEY_SIX"
    session.console.key[327] = "KEY_SEVEN"
    session.console.key[328] = "KEY_EIGHT"
    session.console.key[329] = "KEY_NINE"
    session.console.key[335] = "KEY_KP_ENTER"
    session.console.key[336] = "KEY_KP_EQUAL"

    -- renderer pipeline
    session:pipeadd('close','_close')
    session:pipeadd('startdraw','_startdraw')
    session:pipeadd('frameit','_frameit')
    --session:pipeadd('updatecamera','_updatecamera')
    --session:pipeadd('starttexturemode','_starttexturemode')
    session:pipeadd('clearbg','_clearbg')
    session:pipeadd('start3d','_start3d')
    session:pipeadd('drawcube','_drawcube')
    session:pipeadd('drawmodel','_drawmodel')
    session:pipeadd('end3d','_end3d')
    session:pipeadd('drawtxt','_drawtxt')
    session:pipeadd('fpscounter','_fpscounter')
    --session:pipeadd('endtexturemode','_endtexturemode')
    --session:pipeadd('drawtexture','_drawtexture')
    session:pipeadd('enddraw','_enddraw')
    session.pipeline.render = session.pipeline.main
    session.pipeline.main = {}

    -- parser pipeline
    --session:pipeadd("cleartemp","_cleartemp") -- clears session.temp
    session:pipeadd("=>","_=>") -- autodef wrapper
    session:pipeadd("=","_=") -- set wrapper
    session:pipeadd("unwrapcmd","_unwrap") -- unwrap a command ([command])
    session:pipeadd('unref',"_unref") -- unref a variable @variable
    session:pipeadd("!","_!") -- multi-pipeline operator wl1!wl2!wl3!wl4
    session:pipeadd("spacendclean","_removeStartAndEndSpaces") -- name says everything
    session:pipeadd("cmdname","_cmdname") -- sets session.temp.cmdname
    session:pipeadd("segfault","_segFault") -- throw errors
    session:pipeadd("commander","_commander") -- split args then run the command
    session.pipeline.parser = session.pipeline.main
    session.pipeline.main = {}
    
    --new scene
    session.scene = api.new.scene(session,'3d')

    for i, v in ipairs(flags) do
        rl.SetConfigFlags(rl[v])
    end
    
    session.window.width = width or session.window.width
    session.window.height = height or session.window.height
    session.window.title = title or session.window.title
    api.new.text(session,'f1 or \' to open console',session.defaults.text.size,session.window.height - (session.defaults.text.size*3),rl.BLACK,session.defaults.text.size)
    
    --set autonews
    api.autonew = {}
    for k, v in pairs(api.new) do
        api.autonew[k] = function(session,...)
            table.insert(session.scene[k],api.new[k](session,...))
            return session.scene[k][#session.scene[k]]
        end
    end
    api.autonew.session = false
    
    rl.InitWindow(session.window.width, session.window.height, session.window.title)
    
    return session
end

----------------------------------------------------------------------------
-- api.startup
----------------------------------------------------------------------------

api.startup = function()
    for i, v in ipairs(arg or {}) do
        if api.string.includes(v,'-gl') then
            api.gl = api.string.replace(v,'-gl','')
        end
    end
    if not rl then 
        gl = api.gl
        rl = require "lib.raylib"
        gl = nil
    end
end

api.startup()

return api