local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

print("Main.client.luau started! script.Name =", script.Name, "script.Parent =", script.Parent and script.Parent.Name)
print("script.Parent contents:")
for _, child in (script.Parent and script.Parent:GetChildren() or {}) do
	print("  -", child.Name, "(", child.ClassName, ")")
end

local UIController = require(script.Parent:WaitForChild("modules"):WaitForChild("UIController"))
local CameraController = require(script.Parent:WaitForChild("modules"):WaitForChild("CameraController"))
local MusicController = require(script.Parent:WaitForChild("modules"):WaitForChild("MusicController"))

-- Wait for Player to be available
local player = Players.LocalPlayer
if not player then
	player = Players.PlayerAdded:Wait()
end

-- Wait for PlayerGui
local playerGui = player:WaitForChild("PlayerGui")

-- Initialize controllers
local ui = UIController.new()
local camera = CameraController.new()
local music = MusicController.new()

-- Parent the UI to PlayerGui
local gui = ui:GetGui()
gui.Parent = playerGui

-- Connect Play button
ui:OnPlayClicked(function()
	-- Hide play button, show editor menu
	ui:ShowEditor()

	-- Play random music (only if not already playing)
	music:PlayRandom()

	-- Activate camera (Scriptable, position at Camera_Point, look at Actor)
	camera:ActivateCamera()
end)

-- Connect zoom in
ui:OnZoomIn(function()
	camera:ZoomIn()
end)

-- Connect zoom out
ui:OnZoomOut(function()
	camera:ZoomOut()
end)

-- Connect rotate 360
ui:OnRotate(function()
	camera:Rotate360()
end)

-- Connect stop (returns camera to normal player view)
ui:OnStop(function()
	camera:ResetCamera()
	-- Stop music
	music:Stop()
	-- Show play button again so user can restart
	ui:ShowPlayButton()
end)

-- Connect zoom toggle (sharp zoom in/out)
ui:OnZoomToggle(function()
	camera:ToggleZoom()
end)

print("Edit Battle initialized!")
