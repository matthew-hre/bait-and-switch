local save = {}

local SAVE_FILE = "savedata.lua"

function save.write(data)
    local serialized = "return " .. save.serializeTable(data)
    love.filesystem.write(SAVE_FILE, serialized)
end

function save.read()
    if not love.filesystem.getInfo(SAVE_FILE) then return nil end
    local chunk = love.filesystem.load(SAVE_FILE)
    if chunk then return chunk() end
    return nil
end

function save.serializeTable(t, indent)
    indent = indent or ""
    local nextIndent = indent .. "  "
    local parts = {"{"}
    for k, v in pairs(t) do
        local key = type(k) == "number" and ("[" .. k .. "]") or k
        local val
        if type(v) == "table" then
            val = save.serializeTable(v, nextIndent)
        elseif type(v) == "string" then
            val = string.format("%q", v)
        else
            val = tostring(v)
        end
        parts[#parts + 1] = nextIndent .. key .. " = " .. val .. ","
    end
    parts[#parts + 1] = indent .. "}"
    return table.concat(parts, "\n")
end

return save
