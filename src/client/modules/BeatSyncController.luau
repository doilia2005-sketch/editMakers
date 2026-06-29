local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local BeatMaps = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BeatMaps"))

local BeatSyncController = {}
BeatSyncController.__index = BeatSyncController

function BeatSyncController.new(music, ui)
	local self = setmetatable({}, BeatSyncController)

	self._music = music
	self._ui = ui
	self._active = false
	self._beatIndex = 1
	self._beats = {}
	self._connection = nil
	self._lightingResetThread = nil
	self._baseBrightness = Lighting.Brightness
	self._baseAmbient = Lighting.Ambient

	return self
end

function BeatSyncController:Start(trackName)
	self:Stop()

	self._beats = BeatMaps.getBeats(trackName or "")
	self._beatIndex = 1
	self._active = true

	self._connection = RunService.Heartbeat:Connect(function()
		if not self._active then
			return
		end

		local sound = self._music:GetCurrentSound()
		if not sound or not sound.Playing then
			return
		end

		local timePosition = sound.TimePosition
		while self._beatIndex <= #self._beats and timePosition >= self._beats[self._beatIndex] do
			self:_pulse()
			self._beatIndex += 1
		end
	end)
end

function BeatSyncController:Stop()
	self._active = false

	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end

	if self._lightingResetThread then
		local thread = self._lightingResetThread
		self._lightingResetThread = nil
		if thread ~= coroutine.running() then
			task.cancel(thread)
		end
	end

	Lighting.Brightness = self._baseBrightness
	Lighting.Ambient = self._baseAmbient
end

function BeatSyncController:_pulse()
	self._ui:BeatPulse()

	Lighting.Brightness = self._baseBrightness + 1.2
	Lighting.Ambient = Color3.fromRGB(80, 80, 120)

	if self._lightingResetThread then
		local thread = self._lightingResetThread
		self._lightingResetThread = nil
		if thread ~= coroutine.running() then
			task.cancel(thread)
		end
	end

	self._lightingResetThread = task.delay(0.1, function()
		self._lightingResetThread = nil
		if self._active then
			Lighting.Brightness = self._baseBrightness
			Lighting.Ambient = self._baseAmbient
		end
	end)
end

return BeatSyncController
