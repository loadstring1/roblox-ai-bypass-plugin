--DO NOT USE THIS JUST DOWNLOAD loader.lua INSTEAD!!! NIGHTLY WILL HAVE FASTER UPDATES BUT THOSE UPDATES MIGHT BUG/GLITCH THE ENTIRE PLUGIN

--put this in %localappdata%\Roblox\Plugins
local runserv=game:GetService("RunService")
if runserv:IsRunning() then return end

local encoding=game:GetService("EncodingService")
local bypassScript=plugin:GetSetting("bypassScript")

if typeof(bypassScript)=="table" and bypassScript.offlineMode 
    or typeof(bypassScript)=="table" and typeof(bypassScript.lastFetch)=="number" and os.clock()-bypassScript.lastFetch<600 then
    print("calling loadstring on cached script")
    loadstring(buffer.tostring(encoding:Base64Decode(buffer.fromstring(bypassScript.source))))()
    return
end

print("getting script from repo (sending http request)")

local source=game:GetService("HttpService"):GetAsync("https://raw.githubusercontent.com/loadstring1/roblox-ai-bypass-plugin/refs/heads/nightly/aibypass.luau")
plugin:SetSetting("bypassScript",{
    lastFetch=os.clock(),
    source=buffer.tostring(encoding:Base64Encode(buffer.fromstring(source)))
})

loadstring(source)()