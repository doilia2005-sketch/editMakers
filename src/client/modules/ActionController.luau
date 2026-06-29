local ActionController = {}
ActionController.__index = ActionController

function ActionController.new(player, camera, ui, location)
	local self = setmetatable({}, ActionController)

	self._player = player
	self._camera = camera
	self._ui = ui
	self._location = location

	self._handlers = {
		zoom_in = function()
			camera:ZoomIn()
		end,
		zoom_out = function()
			camera:ZoomOut()
		end,
		rotate = function()
			camera:Rotate360()
		end,
		teleport = function()
			camera:TeleportSideways()
		end,
		shake = function()
			camera:Shake()
		end,
		low_angle = function()
			camera:LowAngle()
		end,
		jump = function()
			self:_jump()
		end,
		next_spot = function()
			location:Next()
		end,
		flash = function()
			ui:Flash()
		end,
	}

	return self
end

function ActionController:ResetForSession()
	self._location:Reset()
end

function ActionController:Run(name)
	local handler = self._handlers[name]
	if handler then
		handler()
	end
end

function ActionController:_jump()
	local character = self._player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end

return ActionController
