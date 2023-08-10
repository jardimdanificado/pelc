package.path = "./?.raw;" .. package.path

--print(api.luaversion() .. ", plec " .. api.version)

local api = require("src.api") -- everything happen inside this
local session = api.new.session(600,480)


-- print(api.run, session.run, api.legacyrun)
-- api.visualtable(session) -- uncomment this to see how session hierarchy look like

--[[ uncomment this to test encryption
api.encode.save('abc.txt',api.encode.base64Encode(api.stringify(session,4)),0451)
api.file.save.text('changed.txt', api.encode.base64Decode(api.encode.load("abc.txt",0451)))
--]]

local pposi = {x=0,y=0,z=0}
local playerwalk = api.new.model(session,'data/model/player/walk')
local playeridle = api.new.model(session,'data/model/player/idle.obj')
local playermodel = api.array.clone(playeridle)
playermodel.position = pposi
--session.scene.camera.target = {x=pposi.x,y=pposi.z,z=pposi.y}
playermodel.framerate = 16
table.insert(session.scene.model,playermodel)
local player = session.scene.model[1]

local function teclado(session)
    if(rl.IsKeyPressed(rl.KEY_PERIOD)) then
        session.scene.camera.fovy = session.scene.camera.fovy - 1
    elseif(rl.IsKeyPressed(rl.KEY_COMMA)) then
        session.scene.camera.fovy = session.scene.camera.fovy + 1
    elseif (rl.IsKeyPressed(rl.KEY_F1) or rl.IsKeyPressed(rl.KEY_APOSTROPHE)) then
        session.console.active = true
    end

    if rl.IsKeyPressed(rl.KEY_W) or rl.IsKeyPressed(rl.KEY_S) then
        playermodel.file = playerwalk.file
    end

    if rl.IsKeyDown(rl.KEY_W) then
        pposi = api.move3d(pposi,playermodel.rotation.y,0.01)
        if playermodel.reverse then
            playermodel.reverse = false
        end
    elseif rl.IsKeyDown(rl.KEY_S) then
        pposi = api.move3d(pposi,playermodel.rotation.y,-0.01)
        if not playermodel.reverse then
            playermodel.reverse = true
        end
    elseif rl.IsKeyReleased(rl.KEY_W) or rl.IsKeyReleased(rl.KEY_S) then
        playermodel.file = playeridle.file
    end

    if rl.IsKeyDown(rl.KEY_A) then
        playermodel.rotation.y = playermodel.rotation.y + 1
        if playermodel.rotation.y >= 360 then
            playermodel.rotation.y = playermodel.rotation.y - 360
        end
    elseif rl.IsKeyDown(rl.KEY_D) then
        playermodel.rotation.y = playermodel.rotation.y - 1
        if playermodel.rotation.y < 0 then
            playermodel.rotation.y = playermodel.rotation.y + 360
        end
    end
end


session:run('randomcubes')
session:run('randomcubes')

while not rl.WindowShouldClose() and not session.temp.exit do
    teclado(session)
    if session.console.active then
        session.console.loop(session)
        session.console.active = false
    end
    api.lookat(session.scene.camera,pposi)
    session.api.process(session,'',session.pipeline.render)
end

rl.CloseWindow()