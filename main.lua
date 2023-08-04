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

local function teclado(session)
    if(rl.IsKeyDown(rl.KEY_PAGE_UP)) then
        session.scene.camera.position.y = session.scene.camera.position.y + 0.000000001
        rl.UpdateCamera(session.scene.camera)
    elseif(rl.IsKeyDown(rl.KEY_PAGE_DOWN)) then
        session.scene.camera.position.y = session.scene.camera.position.y - 0.000000001
        rl.UpdateCamera(session.scene.camera)
    elseif(rl.IsKeyDown(rl.KEY_UP)) then
        session.scene.camera.target.y = session.scene.camera.target.y + 0.000000001
        rl.UpdateCamera(session.scene.camera)
    elseif(rl.IsKeyDown(rl.KEY_DOWN)) then
        session.scene.camera.target.y = session.scene.camera.target.y - 0.000000001
        rl.UpdateCamera(session.scene.camera)
    elseif(rl.IsKeyDown(rl.KEY_RIGHT)) then
        session.scene.camera.position = api.math.rotate(session.scene.camera.position,session.scene.camera.target,-0.000000001)
        rl.UpdateCamera(session.scene.camera)
    elseif(rl.IsKeyDown(rl.KEY_LEFT)) then
        session.scene.camera.position = api.math.rotate(session.scene.camera.position,session.scene.camera.target,0.000000001)
        rl.UpdateCamera(session.scene.camera)
    elseif(rl.IsKeyDown(rl.KEY_PERIOD)) then
        session.scene.camera.fovy = session.scene.camera.fovy - 1
        rl.UpdateCamera(session.scene.camera)
    elseif(rl.IsKeyDown(rl.KEY_COMMA)) then
        session.scene.camera.fovy = session.scene.camera.fovy + 1
        rl.UpdateCamera(session.scene.camera)
    elseif rl.IsKeyPressed(rl.KEY_F1) then
        session.console.active = true
    end
end

session:run('randomcubes')

while not rl.WindowShouldClose() and not session.temp.exit do
    teclado(session)
    if session.console.active then
        session.console.loop(session)
        session.console.active = false
    end
    session.api.process(session,'',session.pipeline.render)
end
rl.CloseWindow()
session.temp.exit = nil