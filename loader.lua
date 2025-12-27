--put this in %localappdata%\Roblox\Plugins
local runserv=game:GetService("RunService")
if runserv:IsRunning() then return end

local encoding=game:GetService("EncodingService")
local bypassScript=plugin:GetSetting("bypassScript")

if typeof(bypassScript)=="table" and bypassScript.offlineMode 
    or typeof(bypassScript)=="table" and typeof(bypassScript.lastFetch)=="number" and os.clock()-bypassScript.lastFetch<600 then
    loadstring(buffer.tostring(encoding:Base64Decode(buffer.fromstring(bypassScript.source))))()
    return
end

local source=game:GetService("HttpService"):GetAsync("https://raw.githubusercontent.com/loadstring1/roblox-ai-bypass-plugin/refs/heads/nightly/aibypass.luau")
plugin:SetSetting("bypassScript",{
    lastFetch=os.clock(),
    source=buffer.tostring(encoding:Base64Encode(buffer.fromstring(source)))
})

loadstring(source)()