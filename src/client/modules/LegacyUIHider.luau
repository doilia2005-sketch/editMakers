local LegacyUIHider = {}

local OUR_GUI_NAME = "EditBattleGui"
local OUR_SCRIPTS_FOLDER = "Client"

local LEGACY_GUI_NAMES = {
	"RecGui",
	"Rec",
	"RecordGui",
	"EditorGui",
	"BattleEditorGui",
	"MainGui",
}

local function disableGui(screenGui)
	screenGui.Enabled = false

	for _, descendant in screenGui:GetDescendants() do
		if descendant:IsA("LocalScript") then
			descendant.Enabled = false
		end
	end
end

local function shouldHide(screenGui)
	if not screenGui:IsA("ScreenGui") then
		return false
	end

	if screenGui.Name == OUR_GUI_NAME then
		return false
	end

	return true
end

local function shouldDisableScript(localScript, playerScripts)
	if not localScript:IsA("LocalScript") then
		return false
	end

	local ourFolder = playerScripts:FindFirstChild(OUR_SCRIPTS_FOLDER)
	if ourFolder and localScript:IsDescendantOf(ourFolder) then
		return false
	end

	return true
end

function LegacyUIHider.hide(playerGui)
	for _, name in LEGACY_GUI_NAMES do
		local gui = playerGui:FindFirstChild(name)
		if gui and gui:IsA("ScreenGui") then
			disableGui(gui)
		end
	end

	for _, child in playerGui:GetChildren() do
		if shouldHide(child) then
			disableGui(child)
		end
	end
end

function LegacyUIHider.watch(playerGui)
	playerGui.ChildAdded:Connect(function(child)
		if shouldHide(child) then
			disableGui(child)
		end
	end)
end

function LegacyUIHider.disableLegacyScripts(player)
	local playerScripts = player:WaitForChild("PlayerScripts")

	local function disableScript(localScript)
		if shouldDisableScript(localScript, playerScripts) then
			localScript.Enabled = false
		end
	end

	for _, child in playerScripts:GetChildren() do
		if child:IsA("LocalScript") then
			disableScript(child)
		end
	end

	playerScripts.ChildAdded:Connect(function(child)
		if child:IsA("LocalScript") then
			disableScript(child)
		end
	end)
end

return LegacyUIHider
