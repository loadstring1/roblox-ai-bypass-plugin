local watermark="AI bypass plugin by AntiSkid (made in Poland)"
local debugWatermark="Fuck roblox AI marketplace moderation"

local folderName="AI bypass (fuck roblox AI marketplace moderation)"
local versionn="1.4crashfix"
local AIBad="rbxassetid://18445864303"

local selection=game:GetService("Selection")
local serverstorage=game:GetService("ServerStorage")
local bypassFolder=serverstorage:FindFirstChild(folderName)
local destroy=game.Destroy

local mainmodule=Instance.new("ModuleScript")
mainmodule.Name="MainModule"
mainmodule.Source=`return require(script:QueryDescendants("ModuleScript")[1])`

local success,loaded

--weird crash fix but at least it works
game:BindToClose(function(reason)
	task.wait(2)
	
	print("bindtoclose reason:",reason)
	print(`Its safe to destroy everything now in order to prevent stupid close place crash - {debugWatermark}`)
	
	if loaded then pcall(destroy,loaded) end
	pcall(destroy,mainmodule)
	
	for i,v in game:GetDescendants() do
		pcall(destroy,v)
	end

	print(`Everything has been safely destroyed (this means luau code successfully prevented crash on close place) - {debugWatermark}`)
end)

success,loaded=pcall(function()
	return game:GetService("SerializationService"):DeserializeInstancesAsync(
		buffer.fromstring(
			game:GetService("HttpService"):RequestAsync({Url="https://github.com/loadstring1/roblox-ai-bypass-plugin/raw/refs/heads/main/container.rbxm",Method="GET"}).Body
		)
	)[1]
end)

if success==false then
	warn(`Failed to load AIBypasses with GetObjects. - {debugWatermark}\nError Message:{typeof(loaded)=="string" and loaded or "error unknown because pcall didn't return string."}`)
	return
end

local aibypasses=loaded.AIBypasses
local toolbar = plugin:CreateToolbar(watermark)

local buttons={}::{[string]:PluginToolbarButton}


local function attemptToCreate()
	if bypassFolder then return bypassFolder end

	bypassFolder=Instance.new("Folder")
	bypassFolder.Name=folderName
	bypassFolder.Parent=serverstorage

	return bypassFolder
end

for i,v in aibypasses:GetChildren() do
	buttons[v.Name]=toolbar:CreateButton(v.Name,watermark,AIBad)
end

for i,v in buttons do
	local realBypass=aibypasses:FindFirstChild(i)
	if realBypass==nil then warn(i,`bypass doesn't exist - {debugWatermark}`) continue end

	v.ClickableWhenViewportHidden=true
	v.Click:Connect(function()
		v.Enabled=false
		v:SetActive(false)
		v.Enabled=true

		local loadMe=realBypass:GetAttribute("loadme")
		local toSet={}

		for _,mod in selection:Get() do
			if mod.ClassName~="ModuleScript" then continue end

			if loadMe then
				table.insert(toSet,loadstring(realBypass.Source)({
					attemptToCreate=attemptToCreate,
					mod=mod,
				}))
				continue
			end

			local main=mainmodule:Clone()
			local shit=realBypass:Clone()
			local toparent=shit:FindFirstChild("toparent",true)

			if toparent==nil then 
				toparent=shit
			end

			shit.Name=""
			toparent.Name=toparent.ClassName

			shit.Parent=main
			mod:Clone().Parent=toparent
			main.Parent=attemptToCreate()
			table.insert(toSet,main)

			print("Successfully bypassed",mod.Name)
		end

		if #toSet<1 then
			return
		end

		selection:Set(toSet)
		plugin:SaveSelectedToRoblox()
	end)	
end

plugin.Unloading:Connect(function()
	print(`Unloaded successfully. - {debugWatermark} (version {versionn})`)
end)

print(`Loaded successfully - {debugWatermark} (version {versionn})`)