local Players = game:GetService("Players")

local UIController = require(script.Parent:WaitForChild("modules"):WaitForChild("UIController"))
local CameraController = require(script.Parent:WaitForChild("modules"):WaitForChild("CameraController"))
local MusicController = require(script.Parent:WaitForChild("modules"):WaitForChild("MusicController"))
local LocationController = require(script.Parent:WaitForChild("modules"):WaitForChild("LocationController"))
local ActionController = require(script.Parent:WaitForChild("modules"):WaitForChild("ActionController"))
local EditSessionController = require(script.Parent:WaitForChild("modules"):WaitForChild("EditSessionController"))
local ReplayController = require(script.Parent:WaitForChild("modules"):WaitForChild("ReplayController"))
local BeatSyncController = require(script.Parent:WaitForChild("modules"):WaitForChild("BeatSyncController"))
local LegacyUIHider = require(script.Parent:WaitForChild("modules"):WaitForChild("LegacyUIHider"))

local SESSION_ACTIONS = {
	"zoom_in",
	"zoom_out",
	"rotate",
	"teleport",
	"shake",
	"low_angle",
	"jump",
	"next_spot",
	"flash",
}

local player = Players.LocalPlayer
if not player then
	player = Players.PlayerAdded:Wait()
end

local playerGui = player:WaitForChild("PlayerGui")

LegacyUIHider.hide(playerGui)
LegacyUIHider.watch(playerGui)
LegacyUIHider.disableLegacyScripts(player)

local ui = UIController.new()
local camera = CameraController.new(player)
local music = MusicController.new()
local location = LocationController.new(player, camera)
local actions = ActionController.new(player, camera, ui, location)
local beatSync = BeatSyncController.new(music, ui)
local replay = ReplayController.new(player, camera, music, ui, actions, beatSync)
local session = EditSessionController.new(ui, camera, music, replay, player, actions, beatSync)

ui:GetGui().Parent = playerGui

task.defer(function()
	LegacyUIHider.hide(playerGui)
end)

ui:OnRecordClicked(function()
	session:Begin()
end)

ui:OnAction("stop", function()
	session:End()
end)

for _, actionName in SESSION_ACTIONS do
	ui:OnAction(actionName, function()
		session:RunAction(actionName)
	end)
end

print("Edit Battle initialized!")
