local ReplayController = {}
ReplayController.__index = ReplayController

function ReplayController.new(player, camera, music, ui, actions, beatSync)
	local self = setmetatable({}, ReplayController)

	self._player = player
	self._camera = camera
	self._music = music
	self._ui = ui
	self._actions = actions
	self._beatSync = beatSync
	self._playing = false
	self._replayThread = nil

	return self
end

function ReplayController:IsPlaying()
	return self._playing
end

function ReplayController:Stop()
	self._playing = false

	if self._replayThread then
		local thread = self._replayThread
		self._replayThread = nil
		if thread ~= coroutine.running() then
			task.cancel(thread)
		end
	end

	self._beatSync:Stop()
	self._camera:ResetCamera()
	self._music:Stop()
end

function ReplayController:_getCharacterRoot()
	local character = self._player.Character
	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
		or character:FindFirstChild("Head")
		or character:FindFirstChildWhichIsA("BasePart")
end

function ReplayController:Play(recording, onComplete)
	if self._playing then
		return
	end

	self._playing = true
	self._ui:ShowReplay()

	local root = self:_getCharacterRoot()
	if root and recording.startCFrame then
		root.CFrame = recording.startCFrame
	end

	self._actions:ResetForSession()

	self._music:Stop()
	if recording.musicTrack then
		self._music:PlayTrack(recording.musicTrack)
	else
		self._music:PlayRandom()
	end

	self._beatSync:Start(recording.musicTrack or self._music:GetCurrentTrackName())
	self._camera:ActivateCamera()

	for _, event in recording.events do
		task.delay(event.time, function()
			if not self._playing then
				return
			end

			self._actions:Run(event.action)
		end)
	end

	self._replayThread = task.delay(recording.duration, function()
		self._replayThread = nil
		if not self._playing then
			return
		end

		self._playing = false
		self._beatSync:Stop()
		self._camera:ResetCamera()
		self._music:Stop()

		if onComplete then
			onComplete()
		end
	end)
end

return ReplayController
