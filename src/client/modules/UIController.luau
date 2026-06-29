local UIController = {}
UIController.__index = UIController

local EDITOR_ACTIONS = {
	{ name = "ZoomInButton", action = "zoom_in", text = "Zoom In", row = 1 },
	{ name = "ZoomOutButton", action = "zoom_out", text = "Zoom Out", row = 1 },
	{ name = "RotateButton", action = "rotate", text = "Rotate 360", row = 1 },
	{ name = "TeleportButton", action = "teleport", text = "Teleport", row = 1, color = Color3.fromRGB(80, 120, 200) },
	{ name = "ShakeButton", action = "shake", text = "Shake", row = 2 },
	{ name = "LowAngleButton", action = "low_angle", text = "Low Angle", row = 2 },
	{ name = "JumpButton", action = "jump", text = "Jump", row = 2, color = Color3.fromRGB(90, 170, 90) },
	{ name = "NextSpotButton", action = "next_spot", text = "Next Spot", row = 2, color = Color3.fromRGB(140, 90, 200) },
	{ name = "FlashButton", action = "flash", text = "Flash", row = 2, color = Color3.fromRGB(220, 200, 80) },
	{ name = "StopButton", action = "stop", text = "Stop", row = 2, color = Color3.fromRGB(200, 50, 50) },
}

function UIController.new()
	local self = setmetatable({}, UIController)

	self._screenGui = nil
	self._recordButton = nil
	self._countdownLabel = nil
	self._editorMenu = nil
	self._actionCallbacks = {}

	self:_createUI()

	return self
end

function UIController:_createUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "EditBattleGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self._screenGui = screenGui

	local recordButton = Instance.new("TextButton")
	recordButton.Name = "RecordButton"
	recordButton.Size = UDim2.new(0, 72, 0, 72)
	recordButton.Position = UDim2.new(0.5, -36, 1, -140)
	recordButton.AnchorPoint = Vector2.new(0.5, 0)
	recordButton.Text = "Rec"
	recordButton.Font = Enum.Font.GothamBold
	recordButton.TextSize = 20
	recordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	recordButton.BackgroundColor3 = Color3.fromRGB(255, 59, 48)
	recordButton.BorderSizePixel = 0
	recordButton.AutoButtonColor = true
	self._recordButton = recordButton

	local recordCorner = Instance.new("UICorner")
	recordCorner.CornerRadius = UDim.new(1, 0)
	recordCorner.Parent = recordButton

	local countdownLabel = Instance.new("TextLabel")
	countdownLabel.Name = "CountdownLabel"
	countdownLabel.Size = UDim2.new(0, 120, 0, 60)
	countdownLabel.Position = UDim2.new(0.5, -60, 0, 20)
	countdownLabel.BackgroundTransparency = 1
	countdownLabel.Text = ""
	countdownLabel.Font = Enum.Font.GothamBold
	countdownLabel.TextSize = 48
	countdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	countdownLabel.Visible = false
	self._countdownLabel = countdownLabel

	local editorMenu = Instance.new("Frame")
	editorMenu.Name = "EditorMenu"
	editorMenu.Size = UDim2.new(1, 0, 0, 120)
	editorMenu.Position = UDim2.new(0, 0, 1, -120)
	editorMenu.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	editorMenu.BorderSizePixel = 0
	editorMenu.Visible = false
	self._editorMenu = editorMenu

	local function createRow(name, yOffset)
		local row = Instance.new("Frame")
		row.Name = name
		row.Size = UDim2.new(1, 0, 0, 52)
		row.Position = UDim2.new(0, 0, 0, yOffset)
		row.BackgroundTransparency = 1
		row.Parent = editorMenu

		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.VerticalAlignment = Enum.VerticalAlignment.Center
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, 6)
		layout.Parent = row

		return row
	end

	local row1 = createRow("Row1", 4)
	local row2 = createRow("Row2", 60)

	local function createMenuButton(parent, config, order)
		local btn = Instance.new("TextButton")
		btn.Name = config.name
		btn.Size = if config.row == 2
			then UDim2.new(0.155, 0, 0, 44)
			else UDim2.new(0.22, 0, 0, 44)
		btn.LayoutOrder = order
		btn.Text = config.text
		btn.Font = Enum.Font.GothamMedium
		btn.TextSize = 16
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.BackgroundColor3 = config.color or Color3.fromRGB(50, 55, 70)
		btn.BorderSizePixel = 0
		btn.AutoButtonColor = true
		btn.Parent = parent
		return btn
	end

	local rowOrder = { [1] = 0, [2] = 0 }

	for _, config in EDITOR_ACTIONS do
		rowOrder[config.row] += 1
		local parent = if config.row == 1 then row1 else row2
		local btn = createMenuButton(parent, config, rowOrder[config.row])

		btn.MouseButton1Click:Connect(function()
			for _, cb in self._actionCallbacks[config.action] or {} do
				cb()
			end
		end)
	end

	recordButton.MouseButton1Click:Connect(function()
		for _, cb in self._actionCallbacks["record"] or {} do
			cb()
		end
	end)

	recordButton.Parent = screenGui
	countdownLabel.Parent = screenGui
	editorMenu.Parent = screenGui
end

function UIController:Flash()
	self:_spawnFlash(0.25, Color3.fromRGB(255, 255, 255), 0.12)
end

function UIController:BeatPulse()
	self:_spawnFlash(0.55, Color3.fromRGB(200, 220, 255), 0.08)
end

function UIController:_spawnFlash(transparency, color, duration)
	local flash = Instance.new("Frame")
	flash.Name = "FlashOverlay"
	flash.Size = UDim2.new(1, 0, 1, 0)
	flash.BackgroundColor3 = color
	flash.BackgroundTransparency = transparency
	flash.BorderSizePixel = 0
	flash.ZIndex = 50
	flash.Parent = self._screenGui

	task.delay(duration, function()
		flash:Destroy()
	end)
end

function UIController:ShowRecording(duration)
	self._recordButton.Visible = false
	self._editorMenu.Visible = true
	self._countdownLabel.Visible = true
	self._countdownLabel.Text = tostring(duration)
end

function UIController:UpdateCountdown(secondsLeft)
	self._countdownLabel.Text = tostring(secondsLeft)
end

function UIController:HideRecording()
	self._recordButton.Visible = false
	self._editorMenu.Visible = false
	self._countdownLabel.Visible = false
	self._countdownLabel.Text = ""
end

function UIController:ShowReplay()
	self._recordButton.Visible = false
	self._editorMenu.Visible = false
	self._countdownLabel.Visible = false
	self._countdownLabel.Text = ""
end

function UIController:ShowRecordButton()
	self._recordButton.Visible = true
	self._editorMenu.Visible = false
	self._countdownLabel.Visible = false
	self._countdownLabel.Text = ""
end

function UIController:OnAction(actionName, callback)
	if not self._actionCallbacks[actionName] then
		self._actionCallbacks[actionName] = {}
	end
	table.insert(self._actionCallbacks[actionName], callback)
end

function UIController:OnRecordClicked(callback)
	self:OnAction("record", callback)
end

function UIController:GetGui()
	return self._screenGui
end

return UIController
