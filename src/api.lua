local api = require('src.util')

api.console.formatcmd = function(command)
    command = command:gsub("%s+", " ")
    command = command:gsub('; ', ';')
    command = command:gsub(' ;', ';')
    command = command:gsub(';\n', ';')
    command = command:gsub('\n;', ';')
    
    return api.string.split(command, ';')
end

api.console.colors = 
{
    black = '\27[30m',
    reset = '\27[0m',
    red = '\27[31m',
    green = '\27[32m',
    yellow = '\27[33m',
    blue = '\27[34m',
    magenta = '\27[35m',
    cyan = '\27[36m',
    white = '\27[37m',
}

api.console.colorstring = function(str,color)
    return api.console.colors[color] .. str .. api.console.colors.reset
end

api.console.boldstring = function(str)
    return "\27[1m" .. str .. "\27[0m"
end

api.console.randomcolor = function()
    return api.console.colors[api.console.api.random(3,#api.console.colors)]--ignores black and reset
end

api.console.movecursor = function(x, y)
    return io.write("\27[" .. x .. ";" .. y .. "H")
end

api.getlink =  function(str)
    local pattern = "&(%w+)"
    local match = string.match(str, pattern)
    local result = string.gsub(str, pattern, "", 1)
    return ('&' .. match), result
end


api.run = function(session, command)
    command = command or io.read()
    local result = ''
    for i, cmd in ipairs(api.console.formatcmd(command)) do
        if api.string.includes(cmd, '&') then
            cmd = cmd:gsub("&%s+", "&")
            local newc = cmd
            local links = {}
            while api.string.includes(newc,"&") == true do
                local link,result = api.getlink(newc)
                newc = result
                table.insert(links,link)
            end
            for i, link in ipairs(links) do
                cmd = cmd:gsub(link,api.stringify(session.data[link:gsub('&','')]))
            end
        end
        if api.string.includes(cmd, '!(') or api.string.includes(cmd, '!%b(') then
            local startPos, endPos = cmd:find('!%((.-)%)!')
            while startPos do
                local newstr = cmd:sub(startPos, endPos)
                local content = newstr:match('!%((.-)%)!')  -- Extract the content within parentheses
                local result = session:run(content) or ''
                cmd = cmd:sub(1, startPos - 1) .. result .. cmd:sub(endPos + 1)
                startPos, endPos = cmd:find('!%((.-)%)!')
            end
        end        
        
        if cmd ~= '' then
            local split = api.string.split(cmd, " ")
            cmd = string.gsub(cmd, "^%s*(.-)%s*$", "%1")
            local args = {}
            for i = 2, #split, 1 do
                table.insert(args,split[i])
            end
            if session.cmd[split[1]] == nil then
                print(split[1] .. " isnt a command!")
            else
                result = session.cmd[split[1]](session,api,args,cmd)
            end
        end
    end
    return result
end
api.spawn = function(session,worker) 

end

api.new = {
    session = function()
        local session = 
        {
            data = {},
            worker={},
            run = api.run,
            exit = false,
            time = 0,
            cmd = 
            {
                run = function(session,api,args)
                    api.run(session,api.file.load.text(args[1]))
                end,
                require = function(session,api,args)
                    local templib
                    if not api.string.includes(args[1],'lib.') and not api.string.includes(args[1],'/') and not api.string.includes(args[1],'\\') then
                        templib = require('lib.' .. args[1])
                    else
                        templib = require(
                            api.string.replace(
                                api.string.replace(
                                    api.string.replace(args[1],'.lua',''),'/','.'),'\\','.'))
                    end
                    if templib._preload ~= nil then
                        templib._preload(session)
                    end
                    for k, v in pairs(templib) do
                        session.cmd[k] = v
                    end
                    if templib._setup ~= nil then
                        templib._setup(session)
                    end
                end,
                import = function(session,api,args)
                    if not api.file.exist(args[1]) then
                        return
                    end
                    local templib = dofile(args[1])
                    for k, v in pairs(templib) do
                        session.cmd[k] = v
                    end
                end,
                ['--'] = function() end
            }
        }
        return session
    end
}

api.start = function(session)
    local laterscript = {}
    local skip = false
    for i, v in ipairs(arg) do
        if skip ~= false then
            session:run(skip .. v)
            skip = false
        elseif v == '-l' then
            skip = "import "
        elseif api.string.includes(v,'-l') then
            session:run("require lib." .. api.string.replace(v,'-l',''))
        elseif api.string.includes(v,'.plec') then
            table.insert(laterscript,v)
        end
    end
    for i, v in ipairs(laterscript) do
        session:run(api.file.load.text(v))
    end
    while not session.exit do
        session:run()
    end
    session.exit = false
end

return api