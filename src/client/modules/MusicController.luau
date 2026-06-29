local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local MusicController = {}
MusicController.__index = MusicController

local LOAD_TIMEOUT = 2

function MusicController.new()
	local self = setmetatable({}, MusicController)

	self._currentSound = nil
	self._currentTrackName = nil
	self._musicFolder = ReplicatedStorage:FindFirstChild("Sounds")

	if not self._musicFolder then
		warn("MusicController: Sounds folder not found in ReplicatedStorage")
	end

	return self
end

function MusicController:_shuffleTracks(tracks)
	local shuffled = table.clone(tracks)
	for i = #shuffled, 2, -1 do
		local j = math.random(1, i)
		shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
	end
	return shuffled
end

function MusicController:_tryPlayTrack(track)
	local soundClone = track:Clone()
	soundClone.Parent = SoundService
	soundClone.Looped = false

	local playOk = pcall(function()
		soundClone:Play()
	end)

	if not playOk then
		soundClone:Destroy()
		return nil
	end

	if not soundClone.IsLoaded then
		local deadline = os.clock() + LOAD_TIMEOUT
		while not soundClone.IsLoaded and os.clock() < deadline do
			task.wait(0.1)
		end
	end

	if not soundClone.IsLoaded or soundClone.TimeLength <= 0 then
		soundClone:Destroy()
		return nil
	end

	if not soundClone.Playing then
		pcall(function()
			soundClone:Play()
		end)
	end

	return soundClone
end

function MusicController:PlayRandom()
	if not self._musicFolder then
		return
	end

	if self._currentSound and self._currentSound.Playing then
		return
	end

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

	for _, track in self:_shuffleTracks(tracks) do
		local soundClone = self:_tryPlayTrack(track)
		if soundClone then
			soundClone.Ended:Connect(function()
				soundClone:Destroy()
				if self._currentSound == soundClone then
					self._currentSound = nil
				end
			end)

			self._currentSound = soundClone
			self._currentTrackName = track.Name
			return
		end
	end

	warn("MusicController: No playable tracks found (check asset permissions)")
end

function MusicController:PlayTrack(trackName)
	if not self._musicFolder or not trackName then
		return false
	end

	local track = self._musicFolder:FindFirstChild(trackName)
	if not track or not track:IsA("Sound") then
		return false
	end

	self:Stop()

	local soundClone = self:_tryPlayTrack(track)
	if not soundClone then
		return false
	end

	soundClone.Ended:Connect(function()
		soundClone:Destroy()
		if self._currentSound == soundClone then
			self._currentSound = nil
			self._currentTrackName = nil
		end
	end)

	self._currentSound = soundClone
	self._currentTrackName = trackName
	return true
end

function MusicController:GetCurrentTrackName()
	return self._currentTrackName
end

function MusicController:GetCurrentSound()
	return self._currentSound
end

function MusicController:Stop()
	if self._currentSound then
		self._currentSound:Stop()
		self._currentSound:Destroy()
		self._currentSound = nil
		self._currentTrackName = nil
	end
end

function MusicController:IsPlaying()
	return self._currentSound ~= nil and self._currentSound.Playing
end

return MusicController
