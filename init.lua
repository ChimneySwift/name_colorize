local online_players = {}

local saturation = 0.6
local value = 1

-- From: https://github.com/red-001/colour_chat/blob/master/init.lua
local function rgb_to_hex(rgb)
    local hexadecimal = '#'

    for key, value in pairs(rgb) do
        local hex = ''

        while(value > 0)do
            local index = math.fmod(value, 16) + 1
            value = math.floor(value / 16)
            hex = string.sub('0123456789ABCDEF', index, index) .. hex
        end

        if(string.len(hex) == 0)then
            hex = '00'

        elseif(string.len(hex) == 1)then
            hex = '0' .. hex
        end

        hexadecimal = hexadecimal .. hex
    end

    return hexadecimal
end

-- From: https://gist.github.com/raingloom/3cb614b4e02e9ad52c383dcaa326a25a
local function hsv_to_rgb(h, s, v)
    h = h + math.pi/2

    local r, g, b = 1, 1, 1
    local h1, h2 = math.cos( h ), math.sin( h )

    local r1, r2 = 0, 1.0
    local g1, g2 = -math.sqrt( 3 )/2, -0.5
    local b1, b2 = math.sqrt( 3 )/2, -0.5

    --hue
    r = h1*r1 + h2*r2
    g = h1*g1 + h2*g2
    b = h1*b1 + h2*b2

    --saturation
    r = r + (1-r)*s
    g = g + (1-g)*s
    b = b + (1-b)*s

    r,g,b = r*v, g*v, b*v

    return {math.floor(r*255), math.floor(g*255), math.floor(b*255)}
end

local function to_hash(str)
    local hash = 0
    str:gsub(".", function(c)
        hash = c:byte() + hash
    end)

    return hash
end

local function get_color(str)
    local hash = tostring(to_hash(str))

    for i=4,1,-1 do
        hash = tostring(to_hash(hash))
    end

    hash = tonumber(hash)

    local hue = math.ceil(hash % 360)

    return rgb_to_hex(hsv_to_rgb(hue, saturation, value))
end

minetest.register_on_receiving_chat_messages(function(message)
    local message = minetest.strip_colors(message)

    local original = message

    -- Keep online player list updated
    if message:sub(1, 4) == "*** " then
        local parts = string.split(message, " ")

        if parts then
            if parts[3] == "joined" then
                table.insert(online_players, parts[2])
            elseif parts[3] == "left" then
                for i, name in pairs(online_players) do
                    if name == parts[2] then
                        table.remove(online_players, i)
                    end
                end
            end
        end
    end

    -- Initialize player list when server status message is sent
    if message:sub(1, 2) == "# " then
        local version, uptime, max_lag, clients = message:match("# Server: version=([^ ]+), uptime=([^ ]+), max_lag=([^ ]+), clients={(.+)}")

        if clients then
            online_players = string.split(clients, ", ")

            local colored_clients = {}
            for i, name in pairs(online_players) do
                table.insert(colored_clients, minetest.colorize(get_color(name), name))
            end

            minetest.display_chat_message("# Server: version="..version..", uptime="..uptime..", max_lag="..max_lag..", clients={"..table.concat(colored_clients, ", ").."}")
            return true
        end
    end

    local name, msg

    if message:sub(1, 1) == "<" then
        name, msg = message:match("<([^ ]+)> (.+)")
        if name then
            name = minetest.colorize(get_color(name), "<"..name.."> ")
            -- name = minetest.colorize(get_color(name), name..": ")
        end
    elseif message:sub(1, 2) == "* " or message:sub(1, 4) == "*** " then
        local parts = string.split(message, " ", false, 2)
        name = minetest.colorize(get_color(parts[2]), parts[1].." "..parts[2].." ")
        msg = parts[3]
    end

    if msg then
        for i, n in pairs(online_players) do
            colorname = minetest.colorize(get_color(n), n)
            msg = msg:gsub(n, colorname)
        end
    end

    if name and msg then
        minetest.display_chat_message(name..msg)
        return true
    end
end)
