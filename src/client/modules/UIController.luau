local UIController = {}
UIController.__index = UIController

function UIController.new()
	local self = setmetatable({}, UIController)

	self._screenGui = nil
	self._playButton = nil
	self._editorMenu = nil
	self._zoomInButton = nil
	self._zoomOutButton = nil
	self._rotateButton = nil
	self._stopButton = nil
	self._zoomToggleButton = nil

	self._playCallbacks = {}
	self._zoomInCallbacks = {}
	self._zoomOutCallbacks = {}
	self._rotateCallbacks = {}
	self._stopCallbacks = {}
	self._zoomToggleCallbacks = {}

	self:_createUI()

	return self
end

function UIController:_createUI()
	local playerGui = Instance.new("ScreenGui")
	playerGui.Name = "EditBattleGui"
	playerGui.ResetOnSpawn = false
	playerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self._screenGui = playerGui

	-- Play Button (center screen)
	local playButton = Instance.new("TextButton")
	playButton.Name = "PlayButton"
	playButton.Size = UDim2.new(0, 200, 0, 60)
	playButton.Position = UDim2.new(0.5, -100, 0.5, -30)
	playButton.Text = "Play"
	playButton.Font = Enum.Font.GothamBold
	playButton.TextSize = 28
	playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	playButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	playButton.BorderColor3 = Color3.fromRGB(0, 120, 200)
	playButton.BorderSizePixel = 2
	playButton.AutoButtonColor = true
	self._playButton = playButton

	-- Editor Menu Frame (bottom of screen, initially hidden)
	local editorMenu = Instance.new("Frame")
	editorMenu.Name = "EditorMenu"
	editorMenu.Size = UDim2.new(1, 0, 0, 80)
	editorMenu.Position = UDim2.new(0, 0, 1, -80)
	editorMenu.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	editorMenu.BorderSizePixel = 0
	editorMenu.Visible = false
	self._editorMenu = editorMenu

	-- Layout to distribute buttons evenly
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 6)
	layout.Parent = editorMenu

	-- bgColor parameter defaults to the standard dark gray
	local function createMenuButton(name, text, order, bgColor)
		local btn = Instance.new("TextButton")
		btn.Name = name
		btn.Size = UDim2.new(0.17, 0, 0, 50)
		btn.LayoutOrder = order
		btn.Text = text
		btn.Font = Enum.Font.GothamMedium
		btn.TextSize = 18
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.BackgroundColor3 = bgColor or Color3.fromRGB(50, 55, 70)
		btn.BorderSizePixel = 0
		btn.AutoButtonColor = true
		btn.Parent = editorMenu
		return btn
	end

	self._zoomInButton = createMenuButton("ZoomInButton", "Priblizit", 1)
	self._zoomOutButton = createMenuButton("ZoomOutButton", "Otdalit", 2)
	self._rotateButton = createMenuButton("RotateButton", "Krutit (360)", 3)
	self._stopButton = createMenuButton("StopButton", "Stop", 4, Color3.fromRGB(200, 50, 50))
	self._zoomToggleButton = createMenuButton("ZoomToggleButton", "Zoom !", 5, Color3.fromRGB(220, 140, 30))

	-- Connect signals
	playButton.MouseButton1Click:Connect(function()
		for _, cb in self._playCallbacks do
			cb()
		end
	end)

	self._zoomInButton.MouseButton1Click:Connect(function()
		for _, cb in self._zoomInCallbacks do
			cb()
		end
	end)

	self._zoomOutButton.MouseButton1Click:Connect(function()
		for _, cb in self._zoomOutCallbacks do
			cb()
		end
	end)

	self._rotateButton.MouseButton1Click:Connect(function()
		for _, cb in self._rotateCallbacks do
			cb()
		end
	end)

	self._stopButton.MouseButton1Click:Connect(function()
		for _, cb in self._stopCallbacks do
			cb()
		end
	end)

	self._zoomToggleButton.MouseButton1Click:Connect(function()
		for _, cb in self._zoomToggleCallbacks do
			cb()
		end
	end)

	-- Parent everything
	playButton.Parent = playerGui
	editorMenu.Parent = playerGui
	playerGui.Parent = nil  -- will be parented when Player is available
end

function UIController:ShowEditor()
	self._playButton.Visible = false
	self._editorMenu.Visible = true
end

function UIController:OnPlayClicked(callback)
	table.insert(self._playCallbacks, callback)
end

function UIController:OnZoomIn(callback)
	table.insert(self._zoomInCallbacks, callback)
end

function UIController:OnZoomOut(callback)
	table.insert(self._zoomOutCallbacks, callback)
end

function UIController:OnRotate(callback)
	table.insert(self._rotateCallbacks, callback)
end

function UIController:OnStop(callback)
	table.insert(self._stopCallbacks, callback)
end

function UIController:OnZoomToggle(callback)
	table.insert(self._zoomToggleCallbacks, callback)
end

function UIController:ShowPlayButton()
	self._playButton.Visible = true
	self._editorMenu.Visible = false
end

function UIController:GetGui()
	return self._screenGui
end

return UIController
