--put this in %localappdata%\Roblox\Plugins
local runserv=game:GetService("RunService")
if runserv:IsRunning() then return end
loadstring(game:GetService("HttpService"):GetAsync("https://raw.githubusercontent.com/loadstring1/roblox-ai-bypass-plugin/refs/heads/main/aibypass.luau"))()