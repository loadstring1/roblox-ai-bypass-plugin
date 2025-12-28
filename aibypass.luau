local coregui=game:GetService("CoreGui")

if coregui:HasTag("AIBypassPluginLoaded") then
	warn("prevented multiple instances of AI bypass plugin from loading - please uninstall second instance of this plugin to prevent lag and crashes\nofficial version can be found here: https://github.com/loadstring1/roblox-ai-bypass-plugin")
	return
end

coregui:AddTag("AIBypassPluginLoaded")

local watermark="AI bypass plugin by AntiSkid (made in Poland)"
local debugWatermark="Fuck roblox AI marketplace moderation"

local bypassFolderName="AI bypass (fuck roblox AI marketplace moderation)"
local versionn="2.0"
local AIBad="rbxassetid://18445864303"

if string.sub(debug.info(1,"s"),1,7)~="[string" or string.sub(debug.info(2,"s"),1,5)=="cloud" then
	versionn=`{versionn}_unofficial`
	warn("AI bypass plugin detected that you probably installed it from roblox's marketplace please switch to official source of this plugin.")
	warn("you might be using unofficial/unsupported version of AI bypass plugin\nofficial version of AI bypass plugin can be found here: https://github.com/loadstring1/roblox-ai-bypass-plugin")
else
	versionn=`{versionn}_official`
end

local pluginSettings=plugin:GetSetting("settings_aipluginbypass")
local toolbar=plugin:CreateToolbar(watermark)
local selection=game:GetService("Selection")
local serverstorage=game:GetService("ServerStorage")
local destroy=game.Destroy

local mainmodule=Instance.new("ModuleScript")
mainmodule.Name="MainModule"
mainmodule.Source=`local modulescript=script:FindFirstChildWhichIsA("ModuleScript",true)\nmodulescript.Parent=nil\nscript:ClearAllChildren()\nmodulescript.Parent=script\nreturn require(modulescript)`

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

if typeof(pluginSettings)~="table" then
    plugin:SetSetting("settings_aipluginbypass",{
        data={},
        offlineMode=false,
		lastVersion=versionn,
    })
    pluginSettings=plugin:GetSetting("settings_aipluginbypass")
end

if pluginSettings.lastVersion~="first_run" and pluginSettings.lastVersion~=versionn then
	print(`Plugin updated from {pluginSettings.lastVersion} to {versionn} successfully! Container cache cleared.`)
	pluginSettings.data.bypassContainer=nil
end

if pluginSettings.lastVersion~=versionn then
	pluginSettings.lastVersion=versionn
	plugin:SetSetting("settings_aipluginbypass",pluginSettings)
end

success,loaded=pcall(function()
	local encodingservice=game:GetService("EncodingService")
	local fetched=pluginSettings.data.bypassContainer

	if typeof(fetched)~="table" or typeof(fetched)=="table" and pluginSettings.offlineMode~=true and typeof(fetched.lastFetch)=="number" and os.clock()-fetched.lastFetch>86400 then
		print("Bypass is loading from github repo - this might take some time if your internet connection is slow")
		fetched={
			bypass=buffer.fromstring(
				game:GetService("HttpService"):RequestAsync({Url="https://github.com/loadstring1/roblox-ai-bypass-plugin/raw/refs/heads/main/container.rbxm",Method="GET"}).Body
			)
		}
		local bypassToSet={lastFetch=os.clock(),bypass=buffer.tostring(encodingservice:Base64Encode(fetched.bypass))}
		pluginSettings.data.bypassContainer=bypassToSet
		plugin:SetSetting("settings_aipluginbypass",pluginSettings)
	end
	
	return game:GetService("SerializationService"):DeserializeInstancesAsync(
		typeof(fetched.bypass)=="string" and encodingservice:Base64Decode(buffer.fromstring(fetched.bypass)) or fetched.bypass
	)[1]
end)

if success==false then
	warn(`Failed to load container with SerializationService. - {debugWatermark}\nError Message:{typeof(loaded)=="string" and loaded or "error unknown because pcall didn't return string."}`)
	return
end

local aibypasses=loaded.AIBypasses
loaded.Parent=script --fixes team create studio sessions crashes

local function folderHandler(folderName,folderParent)
	local currentFolder=folderParent:FindFirstChild(folderName)

	local function shouldRefit()
		if currentFolder and currentFolder.Parent==folderParent and currentFolder.Name==folderName then return currentFolder end

		currentFolder=Instance.new("Folder")
		currentFolder.Name=folderName
		currentFolder.Parent=folderParent

		return currentFolder
	end

	return shouldRefit
end

local bypassFolderRefit=folderHandler(bypassFolderName, serverstorage)
local unwrappedFolderRefit=folderHandler("UnwrappedBypasses", serverstorage)

local function buttonHandler(button,func)
	button.ClickableWhenViewportHidden=true
	button.Click:Connect(function(...)
		button.Enabled=false
		button:SetActive(false)
		button.Enabled=true

		return func(...)
	end)
end

for _,realBypass in aibypasses:GetChildren() do
	local button=toolbar:CreateButton(realBypass.Name,watermark,realBypass:GetAttribute("icon") or AIBad)

	realBypass.Name=""
	realBypass:SetAttribute("icon",nil)

	buttonHandler(button,function()
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
			main.Parent=bypassFolderRefit()
			table.insert(toSet,main)

			print("Successfully bypassed",mod.Name)
		end

		if #toSet<1 then
			return
		end

		selection:Set(toSet)
		--plugin:SaveSelectedToRoblox()
	end)	
end

local unwrapButton=toolbar:CreateButton("Unwrap bypass", "Removes AI bypass from a module.", "rbxassetid://5911946043")
buttonHandler(unwrapButton,function()
	local toSet={}

	for _,bypass in selection:Get() do
		if bypass.ClassName~="ModuleScript" then continue end
		local finalModule=bypass:FindFirstChildWhichIsA("ModuleScript",true)

		if finalModule==nil then
			print("Failed to unwrap",bypass.Name,"looks like it is not a bypassed module!")
			continue
		end

		finalModule.Parent=unwrappedFolderRefit()
		table.insert(toSet,finalModule)
		print("Successfully unwrapped",bypass.Name,finalModule.Name)
	end

	if #toSet<1 then
		return
	end

	selection:Set(toSet)
end)

local isOffline=pluginSettings.offlineMode
local wifiIcons={
	[false]="rbxassetid://105127187178989", --wifi enabled (offlineMode false)
	[true]="rbxassetid://90593114212596" --wifi disabled (offlineMode true)
}

local clearCache=toolbar:CreateButton("Clear cache", "Clears cache for bypasses", "rbxassetid://77395188959040")
local offlineMode=toolbar:CreateButton("Offline mode", "Allows the plugin to run without wifi.", wifiIcons[isOffline])

buttonHandler(clearCache, function()
	table.clear(pluginSettings.data)
	offlineMode.Icon=wifiIcons[false]
	pluginSettings.offlineMode=false
	plugin:SetSetting("settings_aipluginbypass",pluginSettings)
	print("Cache cleared and offline mode disabled! You must reopen this place file/reopen this team create session again to apply full changes")
end)

buttonHandler(offlineMode, function()  
	local bypassScript=pluginSettings.data.bypassScript
	local bypassContainer=pluginSettings.data.bypassContainer

	isOffline=not isOffline
	if typeof(bypassScript)=="table" and typeof(bypassContainer)=="table" then
		pluginSettings.offlineMode=isOffline
		offlineMode.Icon=wifiIcons[isOffline]

		plugin:SetSetting("settings_aipluginbypass",pluginSettings)

		print(`{isOffline and "Enabled offline mode successfully! AI bypass plugin will work without wifi - WARNING: PLUGIN WONT AUTO UPDATE NOW" 
			or "Disabled offline mode successfully! AI bypass plugin now requires wifi to work - plugin will auto update now"}`)
	else
		print("Seems like cache was cleared please reopen this place file/reopen this team create session to restore full plugin functionality.")
	end
end)

plugin.Unloading:Connect(function()
	coregui:RemoveTag("AIBypassPluginLoaded")
	print(`Unloaded successfully. - {debugWatermark} (version {versionn})`)
end)

print(`Loaded successfully - {debugWatermark} (version {versionn})`)