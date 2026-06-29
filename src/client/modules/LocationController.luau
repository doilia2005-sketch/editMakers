local Workspace = game:GetService("Workspace")

local LocationController = {}
LocationController.__index = LocationController

function LocationController.new(player, camera)
	local self = setmetatable({}, LocationController)

	self._player = player
	self._camera = camera
	self._index = 0
	self._spotsFolder = Workspace:FindFirstChild("Locations")

	if not self._spotsFolder then
		warn("LocationController: Locations folder not found in Workspace")
	end

	return self
end

function LocationController:Reset()
	self._index = 0
end

function LocationController:_getCharacterRoot()
	local character = self._player.Character
	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
		or character:FindFirstChild("Head")
		or character:FindFirstChildWhichIsA("BasePart")
end

function LocationController:_getSpots()
	if not self._spotsFolder then
		return {}
	end

	local spots = {}
	for _, child in self._spotsFolder:GetChildren() do
		if child:IsA("BasePart") or child:IsA("Model") then
			table.insert(spots, child)
		end
	end

	table.sort(spots, function(a, b)
		return a.Name < b.Name
	end)

	return spots
end

function LocationController:_getSpotPosition(spot)
	if spot:IsA("BasePart") then
		return spot.Position + Vector3.new(0, 3, 0)
	end

	local primary = spot.PrimaryPart or spot:FindFirstChildWhichIsA("BasePart")
	if primary then
		return primary.Position + Vector3.new(0, 3, 0)
	end

	return nil
end

function LocationController:Next()
	local spots = self:_getSpots()
	local root = self:_getCharacterRoot()
	if not root then
		return
	end

	if #spots == 0 then
		self._camera:TeleportSideways()
		return
	end

	self._index = (self._index % #spots) + 1
	local position = self:_getSpotPosition(spots[self._index])
	if not position then
		return
	end

	local delta = position - root.Position
	root.CFrame = CFrame.new(position) * (root.CFrame - root.CFrame.Position)

	if self._camera:IsActive() then
		self._camera:ApplyDelta(delta)
	end
end

return LocationController
