local runService = game:GetService("RunService")

local function createLag()
	while true do
		local part = Instance.new("Part")
		part.Size = Vector3.new(1, 1, 1)
		part.Position = Vector3.new(math.random(-500, 500), math.random(-500, 500), math.random(-500, 500))
		part.Anchored = true
		part.Parent = workspace

		task.wait(0.01)

		part:Destroy()
	end
end

runService.RenderStepped:Connect(createLag)
