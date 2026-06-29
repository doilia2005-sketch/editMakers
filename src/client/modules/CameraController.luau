local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local CameraController = {}
CameraController.__index = CameraController

local FAR_DISTANCE = 18
local CLOSE_DISTANCE = 5
local DEFAULT_HEIGHT = 4
local LOW_HEIGHT = 1
local TELEPORT_OFFSET = 30
local QUICK_TWEEN = 0.25
local ROTATE_TWEEN = 1.5
local ACTIVATE_TWEEN = 1.5

function CameraController.new(player)
	local self = setmetatable({}, CameraController)

	self._player = player
	self._camera = Workspace.CurrentCamera
	self._originalCFrame = nil
	self._originalCameraType = nil
	self._isActive = false
	self._distance = FAR_DISTANCE
	self._orbitAngle = 0
	self._cameraHeight = DEFAULT_HEIGHT
	self._activeTween = nil
	self._shakeThread = nil

	return self
end

function CameraController:_getCharacterRoot()
	local character = self._player.Character
	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
		or character:FindFirstChild("Head")
		or character:FindFirstChildWhichIsA("BasePart")
end

function CameraController:_computeCameraCFrame(root)
	local rootPos = root.Position
	local lookAt = rootPos + Vector3.new(0, 1.5, 0)
	local offset = Vector3.new(
		math.sin(self._orbitAngle) * self._distance,
		self._cameraHeight,
		math.cos(self._orbitAngle) * self._distance
	)

	return CFrame.lookAt(rootPos + offset, lookAt)
end

function CameraController:_cancelTween()
	if self._activeTween then
		self._activeTween:Cancel()
		self._activeTween = nil
	end
end

function CameraController:_cancelShake()
	if self._shakeThread then
		local thread = self._shakeThread
		self._shakeThread = nil
		if thread ~= coroutine.running() then
			task.cancel(thread)
		end
	end
end

function CameraController:_tweenProperty(propertyName, targetValue, duration, easingStyle)
	local root = self:_getCharacterRoot()
	if not root then
		return
	end

	self:_cancelTween()

	local startValue = self[propertyName]
	local proxy = Instance.new("NumberValue")
	proxy.Value = startValue

	local tweenInfo = TweenInfo.new(duration, easingStyle or Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(proxy, tweenInfo, { Value = targetValue })

	local connection
	connection = proxy:GetPropertyChangedSignal("Value"):Connect(function()
		if not self._isActive then
			return
		end

		local currentRoot = self:_getCharacterRoot()
		if not currentRoot then
			return
		end

		self[propertyName] = proxy.Value
		self._camera.CFrame = self:_computeCameraCFrame(currentRoot)
	end)

	tween.Completed:Connect(function()
		connection:Disconnect()
		proxy:Destroy()
		if self._activeTween == tween then
			self._activeTween = nil
		end
	end)

	self._activeTween = tween
	tween:Play()
end

function CameraController:ActivateCamera()
	local root = self:_getCharacterRoot()
	if not root then
		warn("CameraController: Character not found")
		return
	end

	self._isActive = true
	self._orbitAngle = 0
	self._distance = CLOSE_DISTANCE
	self._cameraHeight = DEFAULT_HEIGHT

	self._originalCFrame = self._camera.CFrame
	self._originalCameraType = self._camera.CameraType
	self._camera.CameraType = Enum.CameraType.Scriptable
	self._camera.CFrame = self:_computeCameraCFrame(root)

	self:_tweenProperty("_distance", FAR_DISTANCE, ACTIVATE_TWEEN, Enum.EasingStyle.Quad)
end

function CameraController:ZoomIn()
	if not self._isActive then
		return
	end

	self:_tweenProperty("_distance", CLOSE_DISTANCE, QUICK_TWEEN, Enum.EasingStyle.Quad)
end

function CameraController:ZoomOut()
	if not self._isActive then
		return
	end

	self:_tweenProperty("_distance", FAR_DISTANCE, QUICK_TWEEN, Enum.EasingStyle.Quad)
end

function CameraController:Rotate360()
	if not self._isActive then
		return
	end

	self:_tweenProperty("_orbitAngle", self._orbitAngle + math.pi * 2, ROTATE_TWEEN, Enum.EasingStyle.Quad)
end

function CameraController:Shake()
	if not self._isActive then
		return
	end

	self:_cancelTween()
	self:_cancelShake()

	local baseAngle = self._orbitAngle
	self._shakeThread = task.spawn(function()
		for i = 1, 8 do
			if not self._isActive then
				return
			end

			self._orbitAngle = baseAngle + (if i % 2 == 0 then 0.12 else -0.12)
			local root = self:_getCharacterRoot()
			if root then
				self._camera.CFrame = self:_computeCameraCFrame(root)
			end
			task.wait(0.04)
		end

		self._orbitAngle = baseAngle
		local root = self:_getCharacterRoot()
		if root then
			self._camera.CFrame = self:_computeCameraCFrame(root)
		end

		self._shakeThread = nil
	end)
end

function CameraController:LowAngle()
	if not self._isActive then
		return
	end

	self:_tweenProperty("_cameraHeight", LOW_HEIGHT, QUICK_TWEEN, Enum.EasingStyle.Quad)
end

function CameraController:TeleportSideways()
	if not self._isActive then
		return
	end

	local root = self:_getCharacterRoot()
	if not root then
		return
	end

	self:_cancelTween()

	local delta = Vector3.new(TELEPORT_OFFSET, 0, 0)
	root.CFrame = root.CFrame + delta
	self._camera.CFrame = self._camera.CFrame + delta
end

function CameraController:ApplyDelta(delta)
	local root = self:_getCharacterRoot()
	if root then
		root.CFrame = root.CFrame + delta
	end

	self._camera.CFrame = self._camera.CFrame + delta
end

function CameraController:ResetCamera()
	self:_cancelTween()
	self:_cancelShake()

	if self._originalCFrame then
		self._camera.CameraType = self._originalCameraType or Enum.CameraType.Custom
		self._camera.CFrame = self._originalCFrame
	end

	self._isActive = false
	self._distance = FAR_DISTANCE
	self._orbitAngle = 0
	self._cameraHeight = DEFAULT_HEIGHT
end

function CameraController:IsActive()
	return self._isActive
end

return CameraController
