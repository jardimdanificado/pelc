local api = {}

api.char = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P','Q', 'R', 'S', 'T', 'U', 'W', 'V', 'X', 'Y', 'Z', 'ç', 'Ç', 'ã', 'â', 'Â', 'Ã', 'á', 'à', 'Á', 'À', 'ä', 'Ä', 'ê', 'Ê', 'é', 'É', 'è', 'È', 'ë', 'Ë', 'î', 'Î', 'ï', 'Ï', 'í', 'Í', 'ì', 'Ì', 'õ', 'Õ', 'ô', 'Ô', 'ó', 'Ó', 'ò', 'Ò', 'ö', 'Ö', 'ú', 'Ú', 'ù', 'Ù', 'û', 'Û', 'ü', 'Ü', 'ñ', 'Ñ'}
api.math = {}
api.string = {}
api.array = {}
api.table = {}
api.matrix = {}
api.file = {}
api.file.save = {}
api.file.load = {}
api.func = {}
api.console = {}
api.array.unpack = unpack or table.unpack

api.math.regrad3 = function(a, b, d)
    local c = (a * d) / b
    return c
end

api.math.scale = function(value, min, max)
    if (value > max) then
        while (value > max) do
            value = value - max - min
        end
    end
    if (value < min) then
        while (value < min) do
            value = value + (max - min)
        end
    end
    value = api.math.regrad3(max - min, 100, value - min)
    return value;
end

api.math.vec2 = function(x, y)
    return {
        x = x,
        y = y
    }
end

api.math.vec2add = function(vec0, vec1)
    return {
        x = vec0.x + vec1.x,
        y = vec0.y + vec1.y
    }
end

api.math.vec2sub = function(vec0, vec1)
    return {
        x = vec0.x - vec1.x,
        y = vec0.y - vec1.y
    }
end

api.math.vec2div = function(vec0, vec1)
    return {
        x = vec0.x / vec1.x,
        y = vec0.y / vec1.y
    }
end

api.math.vec2mod = function(vec0, vec1)
    return {
        x = vec0.x % vec1.x,
        y = vec0.y % vec1.y
    }
end

api.math.vec2mul = function(vec0, vec1)
    return {
        x = vec0.x * vec1.x,
        y = vec0.y * vec1.y
    }
end

api.math.vec3 = function(x, y, z)
    return {
        x = x,
        y = y,
        z = z
    }
end

api.math.vec3add = function(vec0, vec1)
    return {
        x = vec0.x + vec1.x,
        y = vec0.y + vec1.y,
        z = vec0.z + vec1.z
    }
end

api.math.vec3sub = function(vec0, vec1)
    return {
        x = vec0.x - vec1.x,
        y = vec0.y - vec1.y,
        z = vec0.z - vec1.z
    }
end

api.math.vec3mul = function(vec0, vec1)
    return {
        x = vec0.x * vec1.x,
        y = vec0.y * vec1.y,
        z = vec0.z * vec1.z
    }
end

api.math.vec3div = function(vec0, vec1)
    return {
        x = vec0.x / vec1.x,
        y = vec0.y / vec1.y,
        z = vec0.z / vec1.z
    }
end

api.math.vec3mod = function(vec0, vec1)
    return {
        x = vec0.x % vec1.x,
        y = vec0.y % vec1.y,
        z = vec0.z % vec1.z
    }
end

api.math.limit = function(value, min, max)
    local range = max - min
    if range <= 0 then
        return min
    end
    local offset = (value - min) % range
    return offset + min + (offset < 0 and range or 0)
end

api.math.rotate = function(position, pivot, angle)
    -- convert angle to radians
    angle = math.rad(angle)

    -- calculate sine and cosine of angle
    local s = math.sin(angle)
    local c = math.cos(angle)

    -- translate position so that pivot is at the origin
    local translated = api.math.vec3sub(position, pivot)

    -- apply rotation
    local rotated = {
        x = translated.x * c - translated.z * s,
        y = position.y,
        z = translated.x * s + translated.z * c
    }

    -- translate back to original position
    return api.math.vec3add(rotated, {
        x = pivot.x,
        y = 0,
        z = pivot.z
    })
end

api.string.split = function(str, separator)
    local parts = {}
    local start = 1
    separator = separator or ''
    if separator == '' then
        for i = 1, #str do
            parts[i] = string.sub(str, i, i)
        end
        return parts
    end
    local splitStart, splitEnd = string.find(str, separator, start)
    while splitStart do
        table.insert(parts, string.sub(str, start, splitStart - 1))
        start = splitEnd + 1
        splitStart, splitEnd = string.find(str, separator, start)
    end
    table.insert(parts, string.sub(str, start))
    return parts
end

api.string.replace = function(inputString, oldSubstring, newSubstring)
    newSubstring = newSubstring or ''
    return inputString:gsub(oldSubstring, newSubstring)
end

api.string.includes = function(str, substring)
    return string.find(str, substring, 1, true) ~= nil
end

api.string.trim = function(s)
    return s:gsub("^%s+", ""):gsub("%s+$", "")
end

api.table.assign = function(obj1, obj2)
    for k, v in pairs(obj2) do
        obj1[k] = obj2[k]
    end
end

api.table.len = function(obj)
    local count = 0
    for k, v in pairs(obj) do
        count = count + 1
    end
    return count
end

api.table.add = function(arr1, arr2)
    for k, v in pairs(arr2) do
        if api.array.includes(api.reserved, k) then
            arr1[k] = arr2[k] + arr2[k]
        end
    end
end

api.table.sub = function(arr1, arr2)
    for k, v in pairs(arr2) do
        if api.array.includes(api.reserved, k) then
            arr1[k] = arr2[k] - arr2[k]
        end
    end
end

api.table.mul = function(arr1, arr2)
    for k, v in pairs(arr2) do
        if api.array.includes(api.reserved, k) then
            arr1[k] = arr2[k] * arr2[k]
        end
    end
end

api.table.div = function(arr1, arr2)
    for k, v in pairs(arr2) do
        if api.array.includes(api.reserved, k) then
            arr1[k] = arr2[k] / arr2[k]
        end
    end
end

api.table.mod = function(arr1, arr2)
    for k, v in pairs(arr2) do
        if api.array.includes(api.reserved, k) then
            arr1[k] = arr2[k] % arr2[k]
        end
    end
end

api.table.sub = function(arr1, arr2)
    for k, v in pairs(arr2) do
        if api.array.includes(api.reserved, k) then
            arr1[k] = arr2[k] - arr2[k]
        end
    end
end

api.array.slice = function(arr, start, final)
    local sliced_array = {}
    for i = start, final do
        table.insert(sliced_array, arr[i])
    end
    return sliced_array
end

api.array.organize = function(arr, parts)
    local columns, rows = parts, parts
    local matrix = {}
    for i = 1, rows do
        matrix[i] = {}
        for j = 1, columns do
            local index = (i - 1) * columns + j
            matrix[i][j] = arr[index]
        end
    end

    return matrix
end

api.array.expand = function(matrix)
    local nSubMatrices = #matrix
    local subMatrixSize = #matrix[1]

    local result = {}

    for i = 1, nSubMatrices * subMatrixSize do
        result[i] = {}
        for j = 1, nSubMatrices * subMatrixSize do
            local subMatrixIndexI = math.ceil(i / subMatrixSize)
            local subMatrixIndexJ = math.ceil(j / subMatrixSize)
            local subMatrix = matrix[subMatrixIndexI][subMatrixIndexJ]
            local subMatrixRow = (i - 1) % subMatrixSize + 1
            local subMatrixCol = (j - 1) % subMatrixSize + 1
            result[i][j] = subMatrix[subMatrixRow][subMatrixCol]
        end
    end

    return result
end

api.array.new = function(size, value)
    local result = {}
    value = value or 0
    for i = 1, size do
        result[i] = value
    end
    return result
end

api.array.keys = function(arr)
    local result = {
        insert = table.insert
    }
    for key, value in pairs(arr) do
        result:insert(key)
    end
    return result
end

api.array.random = function(start, fim, size)
    local result = {}
    local range = fim - start + 1
    for i = 0, i < size do
        local randomInt = math.floor(api.random() * range) + start
        result.push(randomInt)
    end
    return result
end

api.array.minmax = function(arr)
    local min = arr[1]
    local max = arr[1]
    for y = 1, #arr do
        if (arr[y] > max) then
            max = arr[y]
        elseif (arr[y] < min) then
            min = arr[y]
        end
    end
    return {
        min = min,
        max = max
    }
end

api.array.sum = function(arr)
    local sum = 0
    for i = 1, #arr, 1 do
        sum = sum + arr[i]
    end
    return sum
end

api.array.map = function(arr, callback)
    local result = {}
    for i = 1, #arr do
        result[i] = callback(arr[i], i)
    end
    return result
end

api.array.filter = function(arr, callback)
    local result = {}
    local names = {}
    for k, v in pairs(arr) do
        if callback(v, k) then
            table.insert(result, v)
            table.insert(names, k)
        end
    end
    return result, names
end

api.array.reduce = function(arr, callback, initial)
    local accumulator = initial
    for i = 1, #arr do
        accumulator = callback(accumulator, arr[i])
    end
    return accumulator
end

api.array.includes = function(arr, value)
    for k, v in pairs(arr) do
        if (value == v) then
            return true
        end
    end
    return false
end

api.array.tostring = function(arr)
    local result = ''
    for i, v in ipairs(arr) do
        result = result .. ' ' .. v
    end
    return result
end

api.matrix.includes = function(matrix, value)
    for k, v in pairs(matrix) do
        for k, v in pairs(v) do
            if (value == v) then
                return true
            end
        end
    end
    return false
end

api.matrix.new = function(sizex, sizey, sizez, value)
    local result = {}
    for x = 1, sizex do
        result[x] = {}
        for y = 1, sizey do
            if (value ~= nil) then
                result[x][y] = {}
                for z = 1, sizez, 1 do
                    result[x][y][z] = value
                end
            else
                result[x][y] = sizez
            end
        end
    end
    return result
end

api.matrix.tostring = function(matrix)
    local str = ''
    for x = 1, #matrix, 1 do
        for y = 1, #matrix[x], 1 do
            str = str .. matrix[x][y]
        end
        str = str .. '\n'
    end
    return str
end

api.matrix.minmax = function(matrix)
    local min_val = matrix[1][1]
    local max_val = matrix[1][1]
    for i = 1, #matrix do
        for j = 1, #matrix[i] do
            if matrix[i][j] < min_val then
                min_val = matrix[i][j]
            end
            if matrix[i][j] > max_val then
                max_val = matrix[i][j]
            end
        end
    end
    return min_val, max_val
end

api.matrix.unique = function(matrix)
    function contains(table, val)
        for i = 1, #table do
            if table[i] == val then
                return true
            end
        end
        return false
    end
    local unique_vals = {}
    for i = 1, #matrix do
        for j = 1, #matrix[i] do
            if not contains(unique_vals, math.floor(matrix[i][j])) then
                table.insert(unique_vals, math.floor(matrix[i][j]))
            end
        end
    end
    -- print(unique_vals[4],unique_vals[8])
    return unique_vals
end

api.matrix.average = function(matrix)
    local sum, count = 0, 0
    for x = 1, #matrix do
        for y = 1, #matrix[x] do
            sum = sum + matrix[x][y]
            count = count + 1
        end
    end
    return (sum / count)
end

api.matrix.map = function(matrix, callback)
    for x = 1, #matrix do
        for y = 1, #matrix[x] do
            matrix[x][y] = callback(matrix[x][y])
        end
    end
    return matrix
end

api.matrix.reduce = function(matrix, callback, initialValue)
    local accumulator = initialValue
    for x = 1, #matrix do
        for y = 1, #matrix[x] do
            accumulator = callback(accumulator, matrix[x][y])
        end
    end
    return accumulator
end

api.matrix.filter = function(matrix, callback)
    local filtered = {}
    for x = 1, #matrix do
        filtered[x] = {}
        for y = 1, #matrix[x] do
            if callback(matrix[x][y]) then
                filtered[x][y] = matrix[x][y]
            end
        end
    end
    return filtered
end

api.func.time = function(func, ...)
    local name = 'noname'
    if type(func) == 'table' then
        func, name = func[1], func[2]
    end
    local tclock = os.clock()
    local result = func(api.array.unpack({...}))
    tclock = os.clock() - tclock
    print(name .. ": " .. tclock .. " seconds")
    return result, tclock
end

api.file.load.text = function(path)
    local file = io.open(path, "r")
    local contents = file:read("*all")
    file:close()
    return contents
end

api.file.save.text = function(path, text)
    local file = io.open(path, "w")
    file:write(text)
    file:close()
end

api.file.save.intMap = function(filename, matrix)
    local file = io.open(filename, "w")
    local max = 0
    for i = 1, #matrix do
        for j = 1, #matrix[i] do
            if matrix[i][j] > max then
                max = matrix[i][j]
            end
        end
    end
    local digits = #tostring(max)
    for i = 1, #matrix do
        for j = 1, #matrix[i] do
            local value = matrix[i][j]
            file:write(string.format("%0" .. digits .. "d", value))
            if j < #matrix[i] then
                file:write(" ")
            end
        end
        file:write("\n")
    end
    file:close()
end

api.file.save.charMap = function(filename, matrix)
    local file = io.open(filename, "w")
    for x = 1, #matrix, 1 do
        for y = 1, #matrix[x], 1 do
            if type(matrix[x][y]) == 'table' then
                file:write(matrix[x][y].id)
            else
                file:write(matrix[x][y])
            end

        end
        file:write("\n")
    end
    file:close()
end

api.file.load.charMap = function(filename)
    local file = io.open(filename, "r")
    local matrix = {}
    for line in file:lines() do
        local row = {}
        for i = 1, #line do
            row[i] = string.sub(line, i, i)
        end
        table.insert(matrix, row)
    end
    file:close()
    return matrix
end

api.file.load.map = function(filepath)
    local text = api.file.load.text(filepath)
    local spl = api.string.split(text, "\n")
    local result = {}
    for x, v in spl do
        v = api.string.split(v, " ")
        result[x] = {}
        for y, l in ipairs(v) do
            result[x][y] = l
        end
    end
    return result
end

api.file.exist = function(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    else
        return false
    end
end

api.file.isFile = function(path)
    local mode = lfs.attributes(path, "mode")
    return mode == "file"
end

api.file.check = function(path)
    local file = io.open(path, "r")
    if file then
        local info = file:read("*a")
        if info:sub(1, 4) == "RIFF" then
            return true, 'wav'
        else
            return true, 'folder'
        end
        file:close()
    else
        return false, 'none'
    end
end

randi = randi or 1

api.random = function(min, max)
    math.randomseed(os.time() + randi)
    randi = randi + math.random(1, 40)
    return math.random(min, max)
end

api.roleta = function(...)
    local odds = {...}
    local total = 0
    for i = 1, #odds do
        total = total + odds[i]
    end

    local random_num = api.random(1, total)
    local sum = 0
    for i = 1, #odds do
        sum = sum + odds[i]
        if random_num <= sum then
            return i
        end
    end
end

api.id = function(charTable)
    charTable = charTable or api.char
    local tablelen = #charTable
    local numbers  = api.string.replace(os.clock() .. os.time(), '%.', '')
    numbers = api.string.split(numbers, '')
    local result = ""
    for i = 1, #numbers do
        -- print 'a'
        result = result .. numbers[i]
        result = result .. charTable[api.random(1, tablelen)]
    end
    return result
end

api.turn = function(bool)
    if bool == false then
        return true
    else
        return false
    end
end

api.load = loadstring or load

api.unix = function(ifUnix, ifWindows) -- returts ifunix if unix, if windows return ifWindows, if no args return true if is unix
    ifUnix = ifUnix or true
    ifWindows = ifWindows or false
    if package.config:sub(1, 1) == '\\' then
        return ifWindows
    else
        return ifUnix
    end
end


api.stringify = function(obj, indent)
    if obj == nil then
        return ''
    end
    indent = indent or 0
    local str = ""
    local indentStr = string.rep(" ", indent)

    local function recursiveToString(tbl)
        local tableStr = ""
        for k, v in pairs(tbl) do
            if type(v) == "table" then
                tableStr = tableStr .. indentStr .. tostring(k) .. " = {\n"
                tableStr = tableStr .. recursiveToString(v, indent + 2)
                tableStr = tableStr .. indentStr .. "},\n"
            elseif type(v) == "function" then
                -- Handle functions as desired
                tableStr = tableStr .. indentStr .. tostring(k) .. " = <function>,\n"
            elseif type(v) == "boolean" then
                -- Handle booleans
                tableStr = tableStr .. indentStr .. tostring(k) .. " = " .. tostring(v) .. ",\n"
            else
                -- Handle other types
                tableStr = tableStr .. indentStr .. tostring(k) .. " = " .. tostring(v) .. ",\n"
            end
        end
        return tableStr
    end

    if type(obj) == "table" then
        str = str .. "{\n"
        str = str .. recursiveToString(obj, indent + 2)
        str = str .. indentStr .. "}"
    else
        -- Handle other types
        str = tostring(obj)
    end

    return str
end

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
            local newc = cmd .. ''
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
                local result = session:run(content)
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