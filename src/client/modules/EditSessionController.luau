local RECORD_DURATION = 20

local EditSessionController = {}
EditSessionController.__index = EditSessionController

function EditSessionController.new(ui, camera, music, replay, player, actions, beatSync)
	local self = setmetatable({}, EditSessionController)

	self._ui = ui
	self._camera = camera
	self._music = music
	self._replay = replay
	self._player = player
	self._actions = actions
	self._beatSync = beatSync
	self._active = false
	self._timeLeft = 0
	self._countdownThread = nil
	self._sessionStartTime = 0
	self._recording = nil

	return self
end

function EditSessionController:Begin()
	if self._active or self._replay:IsPlaying() then
		return
	end

	local root = self._player and self._player.Character
		and self._player.Character:FindFirstChild("HumanoidRootPart")

	self._active = true
	self._sessionStartTime = os.clock()
	self._recording = {
		duration = RECORD_DURATION,
		startCFrame = root and root.CFrame or nil,
		musicTrack = nil,
		events = {},
	}

	self._actions:ResetForSession()

	self._music:Stop()
	self._music:PlayRandom()
	self._recording.musicTrack = self._music:GetCurrentTrackName()
	self._beatSync:Start(self._recording.musicTrack)

	self._camera:ActivateCamera()
	self._ui:ShowRecording(RECORD_DURATION)
	self:_startCountdown()
end

function EditSessionController:End()
	if not self._active then
		return
	end

	self._active = false

	local countdownThread = self._countdownThread
	self._countdownThread = nil

	if countdownThread and countdownThread ~= coroutine.running() then
		task.cancel(countdownThread)
	end

	local recording = self._recording
	if recording then
		recording.duration = os.clock() - self._sessionStartTime
	end

	self._camera:ResetCamera()
	self._beatSync:Stop()
	self._music:Stop()
	self._ui:HideRecording()

	if recording and recording.duration > 0 then
		self._replay:Play(recording, function()
			self._ui:ShowRecordButton()
		end)
	else
		self._ui:ShowRecordButton()
	end
end

function EditSessionController:RunAction(name)
	if not self._active then
		return
	end

	table.insert(self._recording.events, {
		time = os.clock() - self._sessionStartTime,
		action = name,
	})

	self._actions:Run(name)
end

function EditSessionController:IsActive()
	return self._active
end

function EditSessionController:_startCountdown()
	self._timeLeft = RECORD_DURATION
	self._ui:UpdateCountdown(self._timeLeft)

	self._countdownThread = task.spawn(function()
		while self._active and self._timeLeft > 0 do
			task.wait(1)
			if not self._active then
				return
			end
			self._timeLeft -= 1
			self._ui:UpdateCountdown(self._timeLeft)
		end

		if self._active then
			self:End()
		end
	end)
end

return EditSessionController
