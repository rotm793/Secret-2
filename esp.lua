cat > /mnt/user-data/outputs/SW_ESP_LITE.lua << 'EOF'
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local FRIEND_COLOR  = Color3.fromRGB(100, 149, 237)
local DEFAULT_COLOR = Color3.new(1, 1, 1)

local friendSet = {}
pcall(function()
    local pages = Players:GetFriendsAsync(LocalPlayer.UserId)
    while true do
        for _, info in pairs(pages:GetCurrentPage()) do
            friendSet[info.Username] = true
        end
        if pages.IsFinished then break end
        pages:AdvanceToNextPageAsync()
    end
end)

local function createESP(plr)
    if plr == LocalPlayer then return end
    local char = plr.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if root:FindFirstChild("SW_ESP_LITE") then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "SW_ESP_LITE"
    bb.Size = UDim2.new(0, 120, 0, 18)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = root

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = friendSet[plr.Name] and FRIEND_COLOR or DEFAULT_COLOR
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.Text = plr.Name
    lbl.Parent = bb
end

for _, plr in pairs(Players:GetPlayers()) do
    if plr.Character then createESP(plr) end
    plr.CharacterAdded:Connect(function() task.wait(0.1) createESP(plr) end)
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function() task.wait(0.1) createESP(plr) end)
end)

Players.PlayerRemoving:Connect(function(plr)
    if plr.Character then
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local bb = root:FindFirstChild("SW_ESP_LITE")
            if bb then bb:Destroy() end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if root and not root:FindFirstChild("SW_ESP_LITE") then
                createESP(plr)
            end
        end
    end
end)
EOF
