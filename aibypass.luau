local watermark="AI bypass plugin by AntiSkid (made in Poland)"
local debugWatermark="Fuck roblox AI marketplace moderation"

local folderName="AI bypass (fuck roblox AI marketplace moderation)"
local versionn="1.5fixteam"
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
local function closePlugin(reason)
	if reason then
		task.wait(2)
		print("bindtoclose reason:",reason)
		print(`Its safe to destroy everything now in order to prevent stupid close place crash - {debugWatermark}`)
	end

	pcall(destroy,loaded)
	pcall(destroy,mainmodule)

	for i,v in game:GetDescendants() do
		pcall(destroy,v)
	end

	print(`Everything has been safely destroyed (this means luau code successfully prevented crash on close place) - {debugWatermark}`)
end

pcall(game.BindToClose,game,closePlugin)
print(`Loading container - {debugWatermark}`)

success,loaded=pcall(function()
	return game:GetService("SerializationService"):DeserializeInstancesAsync(
		buffer.fromstring(
			game:GetService("HttpService"):RequestAsync({Url="https://github.com/loadstring1/roblox-ai-bypass-plugin/raw/refs/heads/main/container.rbxm",Method="GET"}).Body
		)
	)[1]
end)

if success==false then
	warn(`Failed to load container with SerializationService. - {debugWatermark}\nError Message:{typeof(loaded)=="string" and loaded or "error unknown because pcall didn't return string."}`)
	return
end

local aibypasses=loaded.AIBypasses
local toolbar = plugin:CreateToolbar(watermark)

local function attemptToCreate()
	if bypassFolder then return bypassFolder end

	bypassFolder=Instance.new("Folder")
	bypassFolder.Name=folderName
	bypassFolder.Parent=serverstorage

	return bypassFolder
end

for _,realBypass in aibypasses:GetChildren() do
	local button=toolbar:CreateButton(realBypass.Name,watermark,realBypass:GetAttribute("icon") or AIBad)
	
	realBypass.Name=""
	realBypass:SetAttribute("icon",nil)
	
	button.ClickableWhenViewportHidden=true
	button.Click:Connect(function()
		button.Enabled=false
		button:SetActive(false)
		button.Enabled=true

		local toSet={}

		for _,mod in selection:Get() do
			if mod.ClassName~="ModuleScript" then continue end

			local main=mainmodule:Clone()
			local clonedBypass=realBypass:Clone()
			local toparent=clonedBypass:QueryDescendants(".moduleParent")[1]

			if toparent==nil then 
				toparent=clonedBypass
			else
				toparent:RemoveTag("moduleParent")
			end

			clonedBypass.Parent=main
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
	closePlugin()
	print(`Unloaded successfully. - {debugWatermark} (version {versionn})`)
end)

print(`Loaded successfully - {debugWatermark} (version {versionn})`)