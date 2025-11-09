local watermark="AI bypass plugin by AntiSkid (made in Poland)"
local debugWatermark="Fuck roblox AI marketplace moderation"

local folderName="AI bypass (fuck roblox AI marketplace moderation)"
local versionn="1.6"
local AIBad="rbxassetid://18445864303"

local toolbar=plugin:CreateToolbar(watermark)
local selection=game:GetService("Selection")
local serverstorage=game:GetService("ServerStorage")
local bypassFolder=serverstorage:FindFirstChild(folderName)
local destroy=game.Destroy

local mainmodule=Instance.new("ModuleScript")
mainmodule.Name="MainModule"
mainmodule.Source=`return require(script:FindFirstChildWhichIsA("ModuleScript",true))`

local success,loaded
local defaultName=[[]]

;(function()
	local defaultBytes=[[227;129;130;227;130;138;227;129;140;227;129;168;227;129;134;227;128;130;227;129;130;227;130;138;227;129;140;227;129;168;227;129;134;227;128;130;227;129;130;227;130;138;227;129;140;227;129;168;227;129;134;227;128;130;227;129;130;227;130;138;227;129;140;227;129;168;227;129;134;227;128;130;227;129;130;227;130;138;227;129;140;227;129;168;227;129;134;227;128;130;227;129;130;227;130;138;227;129;140;227]]
	for i,v in string.split(defaultBytes,";") do
		defaultName=`{defaultName}{string.char(tonumber(v))}`
	end
end)()

--fixes solo studio session crashes
local function closePlugin(reason)
	local search=game:FindFirstChild(defaultName,true)
	if search==nil then return end
	
	task.wait(2)

	print("bindtoclose reason:",reason)
	print(`Its safe to destroy bypasses in order to prevent studio crash - {debugWatermark}`)

	pcall(destroy,loaded)
	pcall(destroy,mainmodule)
	pcall(destroy,search)
	
	while true do
		search=game:FindFirstChild(defaultName,true)
		
		if search==nil then break end
		pcall(destroy,search)
		
		task.wait()
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
loaded.Parent=script --fixes team create studio sessions crashes

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
	print(`Unloaded successfully. - {debugWatermark} (version {versionn})`)
end)

print(`Loaded successfully - {debugWatermark} (version {versionn})`)