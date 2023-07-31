local raylib = {cmd = {},worker = {}}

raylib.preload = function(session)
    session.data.file = 
    {

    }
    session.scene = 
    {
        current = {}
    }
end

raylib.cmd = 
{
    ['rl.init'] = function(session,args)
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
    end,
    ['rl.close'] = function(session)
        rl.CloseWindow()
    end,
    ['rl.setflag'] = function(session, args)
        if rl[args[1]] then
            rl.SetConfigFlags(rl[args[1]])
        else
            print(args[1] .. ' flag does not exist.')
        end
    end,
    ['scene.new'] = function(session,args)
        local scene = 
        {
            type = args[1] or '3d',
            models = {},
            images = {},
            audios = {},
            musics = {},
            text = {},
            color = 
            {
                background = rl.LIGHTGRAY,
                text = rl.BLACK,
            },
            size = 
            {
                text = 20,
            }
        }
        table.insert(session.scene,scene)
        return session.scene[#session.scene]
    end,
    ['scene.bgcolor'] = function(session,args)
        if tonumber(args[1]) then
            session.scene.current.color.background = rl.new("Color",tonumber(args[1]),tonumber(args[2]),tonumber(args[3]),tonumber(args[4]) or 255)
        elseif args[1] then
            session.scene.current.color.background = rl[string.upper(args[1] or 'white')]
        end
    end,
    ['scene.txtcolor'] = function(session,args)
        if tonumber(args[1]) then
            session.scene.current.color.text = rl.new("Color",tonumber(args[1]),tonumber(args[2]),tonumber(args[3]),tonumber(args[4]) or 255)
        elseif args[1] then
            session.scene.current.color.text = rl[string.upper(args[1] or 'black')]
        end
    end,
    ['scene.newtxt'] = function(session,args)
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
        for i = start, #args do
            text.file = text.file .. ' ' .. args[i]
        end
        
        table.insert(scene.text, text)
        return text
    end,
    ['scene.setcurrent'] = function(session,args)
        local scene = session.scene
        scene.current = scene[tonumber(args[1]) or args[1]]
    end,
    ['consolemode'] = function(session)
        local quit = false
        session.cmd.exit = function()
            quit = true
        end
        local txtsize = session.scene.current.size.text
        local lastline = (session.window.size.y - txtsize)
        
        local text = session:run('scene.newtxt ' .. txtsize .. ' ' .. lastline .. ' a')
        local logs = {}
        session:run('scene.newtxt 0 ' .. lastline .. ' > ')
        text.file = ''
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
                table.insert(logs,session:run('scene.newtxt 0 ' .. text.position.y - txtsize ..  ' a'))
                logs[#logs].file = text.file
                text.file = ''
                
            elseif rl.IsKeyDown(259) then -- backspace
                text.file = string.sub(text.file,1,#text.file-1)
            elseif rl.GetKeyPressed() ~= 0 then
                text.file = text.file .. string.char(rl.GetCharPressed())
            end
            session.api.run(session,'',session.pipeline.render)
        end
        session.cmd.exit = session.data.cmd.exit
    end
}

raylib.worker.begindraw = function()
    rl.BeginDrawing()
end

raylib.worker.clearbg = function(session)
    rl.ClearBackground(session.scene.current.color.background)
end

raylib.worker.drawtxt = function(session)
    for i, text in ipairs(session.scene.current.text) do
        rl.DrawText(text.file, text.position.x, text.position.y, text.size or session.scene.current.size.text, text.color or session.scene.current.color.text)
    end
end

raylib.worker.enddraw = function()
    rl.EndDrawing()
end

raylib.setup = function(session)
    if rl ~= nil then
        session.api.raylib = rl -- raylib-lua set a global rl variable so you dont really need this session one
        session.data.raylib = true
        session.pipeline._main = session.pipeline.main
        session.pipeline.main = {}
        session:workeradd('begindraw','_begindraw')
        session:workeradd('clearbg','_clearbg')
        session:workeradd('drawtxt','_drawtxt')
        session:workeradd('enddraw','_enddraw')

        session.pipeline.render = session.pipeline.main
        session.pipeline.main = session.pipeline._main
        session.pipeline._main = nil
    else
        print("raylib is not avaliable.")
    end
    session:run('scene.new')
    session:run('scene.setcurrent 1')
end

return raylib
