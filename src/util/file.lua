local file = {}
file.save = {}
file.load = {}

file.load.text = function(path)
    local file = io.open(path, "r")
    local contents = file:read("*all")
    file:close()
    return contents
end

file.save.text = function(path, text)
    local file = io.open(path, "w")
    file:write(text)
    file:close()
end

file.save.intMap = function(filename, matrix)
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

file.save.charMap = function(filename, matrix)
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

file.load.charMap = function(filename)
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

file.load.map = function(filepath)
    local text = file.load.text(filepath)
    local spl = util.string.split(text, "\n")
    local result = {}
    for x, v in spl do
        v = util.string.split(v, " ")
        result[x] = {}
        for y, l in ipairs(v) do
            result[x][y] = l
        end
    end
    return result
end

file.exist = function(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    else
        return false
    end
end

file.isFile = function(path)
    local mode = lfs.attributes(path, "mode")
    return mode == "file"
end

file.check = function(path)
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

return file