local runserv=game:GetService("RunService")
if runserv:IsRunning() then return end

local watermark="AI bypasses by AntiSkid in Poland (Polska górą kurwa)"
local debugWatermark="Fuck roblox AI marketplace moderation"

local folderName="AI bypass (fuck roblox AI marketplace moderation)"
local versionn="1.0"
local AIBad="rbxassetid://18445864303"

local selection=game:GetService("Selection")
local serverstorage=game:GetService("ServerStorage")
local bypassFolder=serverstorage:FindFirstChild(folderName)

local mainmodule=Instance.new("ModuleScript")
mainmodule.Name="MainModule"
mainmodule.Source=`return require(script:FindFirstChildWhichIsA("ModuleScript",true))`

local success,loaded=pcall(function()
	return game:GetObjects("rbxassetid://103240522541803")[1]
end)

if success==false then
	warn(`Failed to load AIBypasses with GetObjects. - {debugWatermark}\nError Message:{typeof(loaded)=="string" and loaded or "error unknown because pcall didn't return string."}`)
	return
end

local aibypasses=loaded.AIBypasses
local toolbar = plugin:CreateToolbar(watermark)

local buttons={
	Bypass1=toolbar:CreateButton(
		"Bypass 1 (heavy)",
		watermark,
		AIBad),

	Bypass2=toolbar:CreateButton(
		"Bypass 2 (light)",
		watermark,
		AIBad),	
}::{[string]:PluginToolbarButton}


local function attemptToCreate()
	if bypassFolder then return bypassFolder end

	bypassFolder=Instance.new("Folder")
	bypassFolder.Name=folderName
	bypassFolder.Parent=serverstorage

	return bypassFolder
end

for i,v in buttons do
	local realBypass=aibypasses:FindFirstChild(i)
	if realBypass==nil then warn(i,`bypass doesn't exist - {debugWatermark}`) continue end

	v.ClickableWhenViewportHidden=true
	v.Click:Connect(function()
		v.Enabled=false
		v:SetActive(false)
		v.Enabled=true

		for _,mod in selection:Get() do
			if mod.ClassName~="ModuleScript" then continue end

			local main=mainmodule:Clone()
			local shit=realBypass:Clone()
			local toparent=shit:FindFirstChild("toparent",true)
			if toparent==nil then main:Destroy() shit:Destroy() warn(`unable to find toparent in {i} bypass - {debugWatermark}`) return end

			shit.Name=""
			toparent.Name=toparent.ClassName

			shit.Parent=main
			mod:Clone().Parent=toparent
			main.Parent=attemptToCreate()

			print("Successfully bypassed",mod.Name)
		end
	end)	
end

plugin.Unloading:Connect(function()
	aibypasses:Destroy()
	mainmodule:Destroy()
	loaded:Destroy()
	print(`Unloaded successfully. - {debugWatermark} (version {versionn})`)
end)

print(`Loaded successfully - {debugWatermark} (version {versionn})`)