local pipe = {render={}}

pipe.close = function(session)
    if rl.WindowShouldClose() then
        rl.CloseWindow()
        session.temp.exit = true
    end
end

pipe.startdraw = function()
    rl.BeginDrawing()
end

pipe.start3d = function(session)
    rl.BeginMode3D(session.scene.camera)
end

pipe.clearbg = function(session)
    rl.ClearBackground(session.scene.backgroundcolor)
end

pipe.end3d = function()
    rl.EndMode3D()
end

pipe.drawtxt = function(session)
    for i, text in ipairs(session.scene.text) do
        rl.DrawText(text.file, text.position.x, text.position.y, text.size or session.defaults.text.size, text.color or session.scene.color.text)
    end
end

pipe.drawcube = function(session)
    for i, cube in ipairs(session.scene.cube) do
        if cube.render then
            rl.DrawCubeV(cube.position, cube.size, cube.color or rl.RED)
        end
        if cube.wired then
            rl.DrawCubeWiresV(cube.position, cube.size, session.defaults.color)
        end
    end
end

pipe.drawmodel = function(session)
    local fps = rl.GetFPS()
    for i, model in ipairs(session.scene.model) do
        if model.active then
            if model.playing then
                if session.api.shouldPlay(fps,model.framerate,session.scene.frame) then
                    if not model.file[2] then
                        model.currentframe = 1
                    elseif model.reverse then
                        model.currentframe = not (model.currentframe <= 1) and model.currentframe - 1 or #model.file
                    else
                        model.currentframe = not (model.currentframe >= #model.file) and model.currentframe + 1 or 1
                    end
                end
            end
            local m = type(model.file) == 'table' and model.file[model.currentframe] or model.file[1]
            rl.DrawModelEx(m, model.position, {x=0,y=1,z=0}, model.rotation.y, model.size, model.color or rl.RED)
        end
    end
end

pipe.fpscounter = function(session)
    rl.DrawFPS(1,1)
end

pipe.frameit = function(session)
    session.scene.frame = session.scene.frame + 1
end

pipe.starttexturemode = function(session)
    rl.BeginTextureMode(session.scene.rendertexture)
end

pipe.drawtexture = function(session)
    rl.DrawTextureEx(
        session.scene.rendertexture.texture,
        {x=1,y=1},
        1,
        1,
        rl.WHITE
    );
end

local emptyv3 = rl.new("Vector3",0,0,0)

pipe.updatecamera = function(session)
    rl.UpdateCameraPro(session.scene.camera,emptyv3,emptyv3,0)
end

pipe.endtexturemode = function()
    rl.EndTextureMode()
end

pipe.enddraw = function()
    rl.EndDrawing()
end

--------------------- parsers
-- parsers
--------------------- parsers

pipe['='] = function(session, cmd)
    local split = session.api.string.split(cmd,"=")
    if split[2] then
        cmd = cmd:gsub("=",' = ')
        cmd = cmd:gsub("%s+=%s+",' ')
        cmd = "set " .. cmd
    end
    return cmd
end
pipe['=>'] = function(session, cmd)
    local split = session.api.string.split(cmd," ")
    if split[2] == '=>' then
        cmd = cmd:gsub("=>",'')
        cmd = "def " .. cmd
    end
    return cmd
end

pipe.unref = function(session, cmd)
    if session.api.string.includes(cmd, '@') then
        cmd = cmd:gsub("@%s+", "@")
        local newc = cmd
        local links = {}
        while session.api.string.includes(newc,"@") == true do
            local link,result = session.api.getlink(newc,"@")
            newc = result
            table.insert(links,link)
        end
        for i, link in ipairs(links) do
            if session[link:gsub('@','')] then
                cmd = cmd:gsub(link,session.api.stringify(session[link:gsub('@','')]))
            else
                session:log(link .. ' has no value.',rl.MAROON)
                session.temp['break'] = true
            end
            
        end
    end
    return cmd
end

pipe.cleartemp = function(session,cmd)
    if not session.temp.keep then        
        session.temp = {}
    else
        session.temp.keep = false
    end
end

pipe.unwrapcmd = function (session, cmd)
    local startPos, endPos = cmd:find('%(%b[]%)')
    while startPos do
        local content = cmd:sub(startPos + 2, endPos - 2) -- Extract the content within parentheses
        local result = pipe.unwrapcmd(session, content) or ''
        local processedContent = session:run(result) or ''
        cmd = cmd:sub(1, startPos - 1) .. processedContent .. cmd:sub(endPos + 1)
        startPos, endPos = cmd:find('%(%b[]%)')
    end
    return cmd
end

pipe.spacendclean = function(session,cmd)
    return string.gsub(cmd, "^%s*(.-)%s*$", "%1")
end

pipe.segfault = function(session,cmd)
    session.temp.cmdname = session.temp.cmdname or session.api.string.split(cmd,'%s+')[1]
    if not session.cmd[session.temp.cmdname] then
        session:log(session.temp.cmdname .. ' command do not exist!',rl.MAROON)
        session.temp['break'] = true
    end
end

pipe["!"] = function(session,cmd)
    if type(cmd) == 'string' and session.api.string.includes(cmd,'!') then
        local splited = session.api.string.split(cmd,"%s+")
        if session.api.string.includes(splited[1],"!") then
            local cmdsplited = session.api.string.split(splited[1],"!")
            local newcmd = cmd
            for i, v in ipairs(cmdsplited) do
                if v == '' then
                    break
                end
                local wlname = session.api.string.replace(v,"!")
                if session.pipeline[wlname] then
                    newcmd = session:run(session.api.string.replace(newcmd,v),session.pipeline[wlname])
                else
                    session:log("pipeline " .. wlname .. " does not exist.", rl.MAROON)
                end
            end
            return session.api.string.replace(cmd,splited[1] .. "%s+")
        end
    end
end

pipe.cmdname = function(session,cmd)
    session.temp.cmdname = session.api.string.split(cmd,"%s+")[1]
    return cmd
end

pipe.commander = function(session,cmd)
    local result
    local split = session.api.string.split(cmd, " ")
    local args = {}
    for i = 2, #split, 1 do
        table.insert(args,split[i])
    end
    result = session.cmd[split[1]](session,args,cmd) or ''
    return result
end

return pipe