--DO NOT USE THIS JUST DOWNLOAD loader.lua INSTEAD!!! NIGHTLY WILL HAVE FASTER UPDATES BUT THOSE UPDATES MIGHT BUG/GLITCH THE ENTIRE PLUGIN

--put this in %localappdata%\Roblox\Plugins
local runserv=game:GetService("RunService")
if runserv:IsRunning() then return end

local encoding=game:GetService("EncodingService")
local pluginSettings=plugin:GetSetting("settings_aipluginbypass")

if typeof(pluginSettings)~="table" then
    plugin:SetSetting("settings_aipluginbypass",{
        data={},
        offlineMode=false,
        lastVersion="first_run",
    })
    pluginSettings=plugin:GetSetting("settings_aipluginbypass")
end

local bypassScript=pluginSettings.data.bypassScript

if pluginSettings.offlineMode or typeof(bypassScript)=="table" and typeof(bypassScript.lastFetch)=="number" and os.clock()-bypassScript.lastFetch<600 then
    loadstring(buffer.tostring(encoding:Base64Decode(buffer.fromstring(bypassScript.source))))()
    return
end

local source=game:GetService("HttpService"):GetAsync("https://raw.githubusercontent.com/loadstring1/roblox-ai-bypass-plugin/refs/heads/nightly/aibypass.luau")

pluginSettings.data.bypassScript={
    lastFetch=os.clock(),
    source=buffer.tostring(encoding:Base64Encode(buffer.fromstring(source)))
}
plugin:SetSetting("settings_aipluginbypass",pluginSettings)

loadstring(source)()