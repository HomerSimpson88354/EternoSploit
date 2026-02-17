
_G.noclip = not _G.noclip
print(_G.noclip)

if not game:GetService('Players').LocalPlayer.Character:FindFirstChild("LowerTorso") then
	while _G.noclip do
		game:GetService("RunService").Stepped:wait()
		game.Players.LocalPlayer.Character.Head.CanCollide = false
		game.Players.LocalPlayer.Character.Torso.CanCollide = false
	end
else
	if _G.InitNC ~= true then     
		_G.NCFunc = function(part)      
			local pos = game:GetService('Players').LocalPlayer.Character.LowerTorso.Position.Y  
			if _G.noclip then             
				if part.Position.Y > pos then                 
					part.CanCollide = false             
				end        
			end    
		end      
		_G.InitNC = true 
	end 
	 
	game:GetService('Players').LocalPlayer.Character.Humanoid.Touched:connect(_G.NCFunc) 
end
