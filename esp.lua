local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function createNameTag(player, character)
	local head = character:WaitForChild("Head")

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "CustomNameTag"
	billboard.Size = UDim2.new(0, 140, 0, 28)
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = head

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 16
	label.TextStrokeTransparency = 0.4
	label.Text = player.Name

	if LocalPlayer:IsFriendsWith(player.UserId) then
		label.TextColor3 = Color3.fromRGB(0, 170, 255) -- Arkadaşlar mavi
	else
		label.TextColor3 = Color3.fromRGB(255, 255, 255) -- Diğerleri beyaz
	end

	label.Parent = billboard
end

local function onCharacterAdded(player, character)
	local oldTag = character:FindFirstChild("CustomNameTag", true)
	if oldTag then
		oldTag:Destroy()
	end

	createNameTag(player, character)
end

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		if player.Character then
			onCharacterAdded(player, player.Character)
		end

		player.CharacterAdded:Connect(function(character)
			onCharacterAdded(player, character)
		end)
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
end)
