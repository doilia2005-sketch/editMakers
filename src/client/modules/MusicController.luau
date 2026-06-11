local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MusicController = {}
MusicController.__index = MusicController

function MusicController.new()
	local self = setmetatable({}, MusicController)

	self._currentSound = nil
	self._musicFolder = ReplicatedStorage:FindFirstChild("Sounds")

	if not self._musicFolder then
		warn("MusicController: Sounds folder not found in ReplicatedStorage")
	end

	return self
end

function MusicController:PlayRandom()
	if not self._musicFolder then
		return
	end

	-- Don't restart if already playing
	if self._currentSound and self._currentSound.Playing then
		return
	end

	-- Collect all Sound objects
	local tracks = {}
	for _, child in self._musicFolder:GetChildren() do
		if child:IsA("Sound") then
			table.insert(tracks, child)
		end
	end

	if #tracks == 0 then
		warn("MusicController: No Sound objects found in Sounds folder")
		return
	end

	-- Pick a random track
	local chosen = tracks[math.random(1, #tracks)]

	-- Clone locally (Sound objects from ReplicatedStorage are replicated,
	-- but we clone so we can control playback locally without affecting others)
	local soundClone = chosen:Clone()
	soundClone.Parent = game:GetService("SoundService")
	soundClone.Looped = false

	soundClone.Ended:Connect(function()
		soundClone:Destroy()
		self._currentSound = nil
	end)

	soundClone:Play()

	self._currentSound = soundClone
end

function MusicController:Stop()
	if self._currentSound then
		self._currentSound:Stop()
		self._currentSound:Destroy()
		self._currentSound = nil
	end
end

function MusicController:IsPlaying()
	return self._currentSound ~= nil and self._currentSound.Playing
end

return MusicController
