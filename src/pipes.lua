local pipes = {render={}}

pipes.close = function(session)
    if rl.WindowShouldClose() then
        rl.CloseWindow()
        session.temp.exit = true
    end
end

pipes.startdraw = function()
    rl.BeginDrawing()
end

pipes.start3d = function(session)
    rl.BeginMode3D(session.scene.camera)
end

pipes.clearbg = function(session)
    rl.ClearBackground(session.scene.backgroundcolor)
end

pipes.end3d = function()
    rl.EndMode3D()
end

pipes.drawtxt = function(session)
    for i, text in ipairs(session.scene.text) do

        rl.DrawText(text.file, text.position.x, text.position.y, text.size or session.defaults.text.size, text.color or session.scene.color.text)
    end
end

pipes.drawcube = function(session)
    for i, cube in ipairs(session.scene.cube) do
        if cube.render then
            rl.DrawCubeV(cube.position, cube.size, cube.color or rl.RED)
        end
        if cube.wired then
            rl.DrawCubeWiresV(cube.position, cube.size, session.defaults.color)
        end
    end
end

pipes.fpscounter = function(session)
    rl.DrawFPS(1,1)
end

pipes.enddraw = function()
    rl.EndDrawing()
end

--------------------- parsers
-- parsers
--------------------- parsers

pipes['='] = function(session, cmd)
    local split = session.api.string.split(cmd,"=")
    if split[2] then
        cmd = cmd:gsub("=",' = ')
        cmd = cmd:gsub("%s+=%s+",' ')
        cmd = "set " .. cmd
    end
    return cmd
end
pipes['=>'] = function(session, cmd)
    local split = session.api.string.split(cmd," ")
    if split[2] == '=>' then
        cmd = cmd:gsub("=>",'')
        cmd = "def " .. cmd
    end
    return cmd
end

pipes.unref = function(session, cmd)
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

pipes.cleartemp = function(session,cmd)
    if not session.temp.keep then        
        session.temp = {}
    else
        session.temp.keep = false
    end
end

pipes.unwrapcmd = function (session, cmd)
    local startPos, endPos = cmd:find('%(%b[]%)')
    while startPos do
        local content = cmd:sub(startPos + 2, endPos - 2) -- Extract the content within parentheses
        local result = pipes.unwrapcmd(session, content) or ''
        local processedContent = session:run(result) or ''
        cmd = cmd:sub(1, startPos - 1) .. processedContent .. cmd:sub(endPos + 1)
        startPos, endPos = cmd:find('%(%b[]%)')
    end
    return cmd
end

pipes.spacendclean = function(session,cmd)
    return string.gsub(cmd, "^%s*(.-)%s*$", "%1")
end

pipes.segfault = function(session,cmd)
    session.temp.cmdname = session.temp.cmdname or session.api.string.split(cmd,'%s+')[1]
    if not session.cmd[session.temp.cmdname] then
        session:log(session.temp.cmdname .. ' command do not exist!',rl.MAROON)
        session.temp['break'] = true
    end
end

pipes["!"] = function(session,cmd)
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

pipes.cmdname = function(session,cmd)
    session.temp.cmdname = session.api.string.split(cmd,"%s+")[1]
    return cmd
end

pipes.commander = function(session,cmd)
    local result
    local split = session.api.string.split(cmd, " ")
    local args = {}
    for i = 2, #split, 1 do
        table.insert(args,split[i])
    end
    result = session.cmd[split[1]](session,args,cmd) or ''
    return result
end

return pipes