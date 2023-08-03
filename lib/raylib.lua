local raylib = 
{
    cmd = {},
    worker = {}
}

raylib.preload = function(session)
    if not rl then 
        gl = session.api.gl
        rl = require "src.raylib" 
        gl = nil
    end
    session.api.raylib = rl -- raylib-lua set a global rl variable so you dont really need this session one
    session.data.raylib = true
    session.data.file = 
    {

    }
    session.scene = 
    {
        current = {}
    }
end

raylib.cmd['new.scene'] = function(session,args)
    local scene = 
    {
        type = args[1] or '3d',
        model = {},
        image = {},
        audio = {},
        music = {},
        text = {},
        cube = {},
        color = 
        {
            background = rl.LIGHTGRAY,
            text = rl.BLACK,
            wires = rl.BLACK
        },
        size = 
        {
            text = 20,
        },
        camera = rl.new("Camera", {
            position = rl.new("Vector3", 0, 10, 10),
            target = rl.new("Vector3", 0, 0, 0),
            up = rl.new("Vector3", 0, 1, 0),
            fovy = 45,
            type = rl.CAMERA_PERSPECTIVE
        }),
    }
    table.insert(session.scene,scene)
    return session.scene[#session.scene]
end

raylib.cmd['new.window'] = function(session,args)
    local title = 'plecVM ' .. session.api.version
    if tonumber(args[1]) then
        if tonumber(args[2]) then
            if args[3] then
                title = ''
                for i = 3, #args do
                    title = title .. ' ' .. args[i]
                end
            end
            rl.InitWindow(tonumber(args[1]), tonumber(args[2]), title)
            session.window = {size = {x = tonumber(args[1]), y = tonumber(args[2])}, title = title}
        else
            if args[2] then
                title = ''
                for i = 2, #args do
                    title = title .. ' ' .. args[i]
                end
            end
            rl.InitWindow(tonumber(args[1]), tonumber(args[1]), title)
            session.window = {size = {x = tonumber(args[1]), y = tonumber(args[1])}, title = title}
        end
    else
        rl.InitWindow(800, 600, title)
        session.window = {size = {x = 800, y = 600}, title = title}
    end
end

raylib.cmd['new.cube'] = function(session,args) -- px py pz sx sy sz color
    local scene = session.scene.current
    local cube = 
    {
        position = 
        {
            x = tonumber(args[1]),
            y = tonumber(args[2]),
            z = tonumber(args[3]),
        },
        size = 
        {
            x = tonumber(args[4]),
            y = tonumber(args[5]),
            z = tonumber(args[6]),
        },
        color = rl[string.upper(args[7]) or 'GREEN'],
        wired = args[8] == 'true' and true or false,
        render = true
    }
    table.insert(scene.cube,cube)
end

raylib.cmd['new.text'] = function(session,args)
    local scene = session.scene.current
    local start = 3
    local position = {x = tonumber(args[1]),y = tonumber(args[2])}
    local text = 
    {
        position = position,
        file = ''
    }
    if tonumber(args[3]) then
        start = 4
        text.size = tonumber(args[3])
    end
    text.file = text.file .. (args[start] or '')
    for i = start+1, #args do
        text.file = text.file .. ' ' .. args[i]
    end
    
    table.insert(scene.text, text)
    return text
end

raylib.cmd['color.background'] = function(session,args)
    if tonumber(args[1]) then
        session.scene.current.color.background = rl.new("Color",tonumber(args[1]),tonumber(args[2]),tonumber(args[3]),tonumber(args[4]) or 255)
    elseif args[1] then
        session.scene.current.color.background = rl[string.upper(args[1] or 'white')]
    end
end

raylib.cmd['color.text'] = function(session,args)
    if tonumber(args[1]) then
        session.scene.current.color.text = rl.new("Color",tonumber(args[1]),tonumber(args[2]),tonumber(args[3]),tonumber(args[4]) or 255)
    elseif args[1] then
        session.scene.current.color.text = rl[string.upper(args[1] or 'black')]
    end
end

raylib.cmd['set.flag'] = function(session, args)
    if rl[args[1]] then
        rl.SetConfigFlags(rl[args[1]])
    else
        print(args[1] .. ' flag does not exist.')
    end
end

raylib.cmd['set.scene'] = function(session,args)
    local scene = session.scene
    scene.current = scene[tonumber(args[1]) or args[1]]
    session.data.scene = scene.current
end

raylib.cmd['close'] = function()
    rl.CloseWindow()
end

raylib.cmd['fontsize'] = function(session,args)
    session.scene.current.size.text = tonumber(args[1])
end

raylib.cmd.consolemode = function(session)
    local quit = false
    session.cmd.back = function()
        quit = true
    end
    session.cmd.exit = function()
        session.temp.quit = true
        quit = true
    end
    session.scene.current._text = session.scene.current.text
    session.scene.current.text = session.scene.current.consoletext or {}
    local txtsize = session.scene.current.size.text
    local lastline = (session.window.size.y - txtsize)
    local juststarted = true
    local text = session:run('new.text ' .. txtsize/1.8 .. ' ' .. lastline)
    local logs = {session:run('new.text 0 ' .. (session.window.size.y - (txtsize)*2) .. ' console mode activated.')}
    logs[1].file = 'console mode activated.'
    local barra = session:run('new.text ' .. txtsize/7 .. ' ' .. lastline .. ' >')
    while not quit do
        if rl.IsKeyPressed(rl.KEY_ENTER) then
            session:run(text.file)
            for k, txt in ipairs(logs) do
                
                if txt.position.y - txtsize <= 0 then
                    txt.file = ''
                else
                    txt.position.y = txt.position.y - txtsize
                end

            end
            table.insert(logs,session:run('new.text 0 ' .. text.position.y - txtsize ..  ' a'))
            logs[#logs].file = text.file
            text.file = ''
            
        elseif rl.IsKeyPressed(rl.KEY_BACKSPACE) then 
            text.file = string.sub(text.file,1,#text.file-1)
        elseif rl.IsKeyPressed(rl.KEY_F1) then 
            if not juststarted then
                quit = true
            else
                juststarted = false
            end
            
        elseif rl.GetKeyPressed() > 0 and not rl.IsKeyPressed(rl.KEY_F1) then
            text.file = text.file .. string.char(rl.GetCharPressed())
        end
        session.api.run(session,'',session.pipeline.render)
    end
    for k, v in pairs(session.scene.current.text) do
        if v.file == '>' then
            session.scene.current.text[k] = nil
        end
    end
    session.scene.current.text = session.scene.current._text
    session.scene.current._text = nil
    session.cmd.exit = session.data.cmd.exit
end

raylib.cmd.rendermode = function(session)
    while not rl.WindowShouldClose() and not session.temp.quit do
        if rl.IsKeyPressed(rl.KEY_F1) then
            session:run('consolemode')
        end
        session.api.run(session,'',session.pipeline.render)
    end
end

raylib.worker.close = function(session)
    if rl.WindowShouldClose() then
        rl.CloseWindow()
        session:run('exit')
    end
end

raylib.worker.startdraw = function()
    rl.BeginDrawing()
end

raylib.worker.start3d = function(session)
    rl.BeginMode3D(session.scene.current.camera)
end

raylib.worker.clearbg = function(session)
    rl.ClearBackground(session.scene.current.color.background)
end

raylib.worker.end3d = function()
    rl.EndMode3D()
end

raylib.worker.drawtxt = function(session)
    for i, text in ipairs(session.scene.current.text) do
        rl.DrawText(text.file, text.position.x, text.position.y, text.size or session.scene.current.size.text, text.color or session.scene.current.color.text)
    end
end

raylib.worker.drawcube = function(session)
    for i, cube in ipairs(session.scene.current.cube) do
        if cube.render then
            rl.DrawCubeV(cube.position, cube.size, cube.color or session.scene.current.color.general)
        end
        if cube.wired then
            rl.DrawCubeWiresV(cube.position, cube.size, session.scene.current.color.wires)
        end
    end
end

raylib.worker.enddraw = function()
    rl.EndDrawing()
end

raylib.setup = function(session)
    session.pipeline._main = session.pipeline.main
    session.pipeline.main = {}
    session:workeradd('close','_close')
    session:workeradd('startdraw','_startdraw')
    session:workeradd('clearbg','_clearbg')
    session:workeradd('start3d','_start3d')
    session:workeradd('drawcube','_drawcube')
    session:workeradd('end3d','_end3d')
    session:workeradd('drawtxt','_drawtxt')
    session:workeradd('enddraw','_enddraw')

    session.pipeline.render = session.pipeline.main
    session.pipeline.main = session.pipeline._main
    session.pipeline._main = nil
    session:run('new.scene')
    session:run('set.scene 1')
end

return raylib
