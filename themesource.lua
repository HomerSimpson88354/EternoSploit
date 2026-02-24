--[[
	Rayfield Interface Suite
	by Sirius

	shlex  | Designing + Programming
	iRay   | Programming
	Max    | Programming
	Damian | Programming
]]

-- [Previous initialization and utility functions remain unchanged for brevity]


local Theme = RayfieldLibrary:CreateTheme({
	NotificationActionsBackground = Color3.fromRGB(225, 230, 240),
	TabBackground = Color3.fromRGB(200, 210, 220),
	TabStroke = Color3.fromRGB(180, 190, 200),
	TabBackgroundSelected = Color3.fromRGB(175, 185, 200),
	TabTextColor = Color3.fromRGB(50, 55, 60),
	SelectedTabTextColor = Color3.fromRGB(30, 35, 40),
	ElementBackground = Color3.fromRGB(210, 220, 230),
	ElementBackgroundHover = Color3.fromRGB(220, 230, 240),
	SecondaryElementBackground = Color3.fromRGB(200, 210, 220),
	ElementStroke = Color3.fromRGB(190, 200, 210),
	SecondaryElementStroke = Color3.fromRGB(180, 190, 200),
	SliderBackground = Color3.fromRGB(200, 220, 235),
	SliderProgress = Color3.fromRGB(70, 130, 180),
	SliderStroke = Color3.fromRGB(150, 180, 220),
	ToggleBackground = Color3.fromRGB(210, 220, 230),
	ToggleEnabled = Color3.fromRGB(70, 160, 210),
	ToggleDisabled = Color3.fromRGB(180, 180, 180),
	ToggleEnabledStroke = Color3.fromRGB(60, 150, 200),
	ToggleDisabledStroke = Color3.fromRGB(140, 140, 140),
	ToggleEnabledOuterStroke = Color3.fromRGB(100, 120, 140),
	ToggleDisabledOuterStroke = Color3.fromRGB(120, 120, 130),
	DropdownSelected = Color3.fromRGB(220, 230, 240),
	DropdownUnselected = Color3.fromRGB(200, 210, 220),
	InputBackground = Color3.fromRGB(220, 230, 240),
	InputStroke = Color3.fromRGB(180, 190, 200),
	PlaceholderColor = Color3.fromRGB(150, 150, 150)
})

if CEnabled and Main:FindFirstChild('Notice') then
	Main.Notice.BackgroundColor3 = Theme.NotificationActionsBackground 
	Main.Notice.Title.TextColor3 = Theme.TabTextColor 
	Main.Notice.BackgroundTransparency = 1
	Main.Notice.Title.TextTransparency = 1
	Main.Notice.Size = UDim2.new(0, 0, 0, 0)
	Main.Notice.Position = UDim2.new(0.5, 0, 0, -100)
	Main.Notice.Visible = true

	TweenService:Create(Main.Notice, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 280, 0, 35), Position = UDim2.new(0.5, 0, 0, -50), BackgroundTransparency = 0.5}):Play()
	TweenService:Create(Main.Notice.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0.1}):Play()
end



task.delay(4, function()
	RayfieldLibrary.LoadConfiguration()
	if Main:FindFirstChild('Notice') and Main.Notice.Visible then
		TweenService:Create(Main.Notice, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 100, 0, 25), Position = UDim2.new(0.5, 0, 0, -100), BackgroundTransparency = 1}):Play()
		TweenService:Create(Main.Notice.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()

		task.wait(0.5)
		Main.Notice.Visible = false
	end
end)

return RayfieldLibrary
