local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local CameraController = {}
CameraController.__index = CameraController

-- How far the camera "zooms in" toward the actor face (stude offset from head)
local ZOOM_IN_OFFSET = Vector3.new(0, 1.5, -3)
local TWEEN_TIME = 1.5

function CameraController.new()
	local self = setmetatable({}, CameraController)

	self._camera = Workspace.CurrentCamera
	self._originalCFrame = nil
	self._isActive = false
	self._currentAngle = 0
	self._zoomedIn = false

	-- Find Camera_Point and Actor
	self._cameraPoint = Workspace:FindFirstChild("Camera_Point")
	self._actor = Workspace:FindFirstChild("Actor")

	if not self._cameraPoint then
		warn("CameraController: Camera_Point not found in Workspace")
	end
	if not self._actor then
		warn("CameraController: Actor not found in Workspace")
	end

	return self
end

function CameraController:ActivateCamera()
	if not self._cameraPoint or not self._actor then
		return
	end

	local actorHead = self._actor:FindFirstChild("Head")
	if not actorHead then
		actorHead = self._actor:FindFirstChildWhichIsA("BasePart")
	end

	if not actorHead then
		warn("CameraController: Actor has no Head or BasePart")
		return
	end

	self._isActive = true
	self._currentAngle = 0

	-- Store original camera state
	self._originalCFrame = self._camera.CFrame
	self._originalCameraType = self._camera.CameraType

	-- Set camera to Scriptable and position it
	self._camera.CameraType = Enum.CameraType.Scriptable
	local targetCFrame = CFrame.lookAt(self._cameraPoint.Position, actorHead.Position)
	self._camera.CFrame = targetCFrame
end

function CameraController:ZoomIn()
	if not self._isActive or not self._actor then
		return
	end

	local actorHead = self._actor:FindFirstChild("Head")
	if not actorHead then
		actorHead = self._actor:FindFirstChildWhichIsA("BasePart")
	end
	if not actorHead then
		return
	end

	local targetPos = actorHead.Position + ZOOM_IN_OFFSET
	local targetCFrame = CFrame.lookAt(targetPos, actorHead.Position)

	local tweenInfo = TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(self._camera, tweenInfo, { CFrame = targetCFrame })
	tween:Play()
end

function CameraController:ZoomOut()
	if not self._isActive or not self._cameraPoint then
		return
	end

	if not self._actor then
		return
	end

	local actorHead = self._actor:FindFirstChild("Head")
	if not actorHead then
		actorHead = self._actor:FindFirstChildWhichIsA("BasePart")
	end
	if not actorHead then
		return
	end

	local targetCFrame = CFrame.lookAt(self._cameraPoint.Position, actorHead.Position)

	local tweenInfo = TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(self._camera, tweenInfo, { CFrame = targetCFrame })
	tween:Play()
end

function CameraController:Rotate360()
	if not self._isActive or not self._actor then
		return
	end

	local actorHead = self._actor:FindFirstChild("Head")
	if not actorHead then
		actorHead = self._actor:FindFirstChildWhichIsA("BasePart")
	end
	if not actorHead or not self._cameraPoint then
		return
	end

	-- Current camera position relative to actor
	local cameraPos = self._camera.CFrame.Position
	local toActor = (actorHead.Position - cameraPos).Unit
	local dist = (cameraPos - actorHead.Position).Magnitude

	-- We rotate 360 degrees around the Y axis relative to the camera point
	-- Use the camera point as the orbit center
	local basePos = self._cameraPoint.Position
	local relative = cameraPos - basePos
	local radius = relative.Magnitude
	local currentAngle = math.atan2(relative.X, relative.Z)

	local targetAngle = currentAngle + math.pi * 2  -- 360 degrees in radians
	local targetX = basePos.X + radius * math.sin(targetAngle)
	local targetZ = basePos.Z + radius * math.cos(targetAngle)
	local targetPos = Vector3.new(targetX, cameraPos.Y, targetZ)
	local targetCFrame = CFrame.lookAt(targetPos, actorHead.Position)

	local tweenInfo = TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local tween = TweenService:Create(self._camera, tweenInfo, { CFrame = targetCFrame })
	tween:Play()
end

function CameraController:ToggleZoom()
	if not self._isActive or not self._actor then
		return
	end

	local actorHead = self._actor:FindFirstChild("Head")
	if not actorHead then
		actorHead = self._actor:FindFirstChildWhichIsA("BasePart")
	end
	if not actorHead then
		return
	end

	-- If currently zoomed in, zoom out; otherwise zoom in
	if self._zoomedIn then
		self:ZoomOut()
		self._zoomedIn = false
	else
		self:ZoomIn()
		self._zoomedIn = true
	end
end

function CameraController:ResetCamera()
	if self._originalCFrame then
		self._camera.CameraType = self._originalCameraType or Enum.CameraType.Custom
		self._camera.CFrame = self._originalCFrame
	end
	self._isActive = false
	self._zoomedIn = false
end

function CameraController:IsActive()
	return self._isActive
end

return CameraController
