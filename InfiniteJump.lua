
_G.infinjump = not _G.infinjump

local plr = game:GetService'Players'.LocalPlayer
local m = plr:GetMouse()
m.KeyDown:connect(function(k)
	if _G.infinjump then
		if k:byte() == 32 then
		plrh = game:GetService'Players'.LocalPlayer.Character:FindFirstChildOfClass'Humanoid'
		plrh:ChangeState('Jumping')
		wait()
		plrh:ChangeState('Seated')
		end
	end
end)
