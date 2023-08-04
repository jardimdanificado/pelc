--[[ nix packages in order to make plec + raylib run in replit
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

api.pipeadd = function(session,name,position,newid,custompipeline) 
    local wlist = session.pipeline[custompipeline or 'main']
    local pipe = 
    {
        id = '',
        func = session.pipes[name or ''] or ''
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

api.run = function(session, command, pipeline)
    command = command or api.getline()
    local result = ''
    for i, cmd in ipairs(api.formatcmd(command)) do
        result = session:process(cmd,pipeline or session.pipeline.parser)
    end
    return result
end

api.log = function(session,content,color)
    for k, txt in pairs(session.console.logs) do
        if txt ~= session.console.barra and txt ~= session.console.buffer then
            txt.position.y = txt.position.y - session.defaults.text.size
        end
    end
    table.insert(session.console.logs,api.new.text(nil,content,session.defaults.text.size*2,(session.window.height - (session.defaults.text.size*3)), color or rl.BLACK))
end

api.new = 
{
    scene = function(session,_type)
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
        }
        if session then
            table.insert(session.scenes,scene)
        end
        return scene
    end,
    text = function(session,text,px,py,color,size)
        local text = {file=text,position={x=px or 0,y=py or 0},color = color or rl.BLACK, size = size or 10}
        if session then
            table.insert(session.scene.text,text)
        end
        return text
    end,
    cube = function(session,px,py,pz,sx,sy,sz,color,wired)
        local cube = {wired = wired or true,position={x=px or 0,y=py or 0,z=pz or 0},size={x=sx or 1,y=sy or 1,z=sz or 1},color = color or rl.BLACK}
        if session then
            table.insert(session.scene.cube,cube)
        end
        return cube
    end
}

api.set = 
{
    scene = function(session,index)
        session.scene = session.scenes[index]
    end
}

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

api.version = '0.6'

api.gl = '11'

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
        pipes = require 'src.pipes',
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

    -- render pipeline
    session:pipeadd('close','_close')
    session:pipeadd('startdraw','_startdraw')
    session:pipeadd('clearbg','_clearbg')
    session:pipeadd('start3d','_start3d')
    session:pipeadd('drawcube','_drawcube')
    session:pipeadd('end3d','_end3d')
    session:pipeadd('drawtxt','_drawtxt')
    session:pipeadd('fpscounter','_fpscounter')
    session:pipeadd('enddraw','_enddraw')
    session.pipeline.render = session.pipeline.main
    session.pipeline.main = {}

    -- parser pipeline
    session:pipeadd("cleartemp","_cleartemp") -- clears session.temp
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
    api.new.text(session,'f1 to open console',session.defaults.text.size,session.window.height - (session.defaults.text.size*3),rl.BLACK,session.defaults.text.size)
    rl.InitWindow(session.window.width, session.window.height, session.window.title)
    
    return session
end

api.startup()

return api