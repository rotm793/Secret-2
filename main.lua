-- [[ TVL2: COMPLETE V69 (MODIFIED) ]] --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local _G = {
    MasterActive = true,
    AutoAttack = false,
    Range = 1000,
    Whitelist = {},
    Blacklist = {}
}

-- [[ OTOMATİK ARKADAŞ WHITELIST ]]
local function AddFriendsToWhitelist()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and LocalPlayer:IsFriendsWith(plr.UserId) then
            if not table.find(_G.Whitelist, plr.Name) then table.insert(_G.Whitelist, plr.Name) end
        end
    end
end
AddFriendsToWhitelist()
Players.PlayerAdded:Connect(function(plr) task.wait(1); if LocalPlayer:IsFriendsWith(plr.UserId) then table.insert(_G.Whitelist, plr.Name) end end)

local Window = Rayfield:CreateWindow({
   Name = "TVL2: COMPLETE V69",
   LoadingTitle = "V57 Ayarları & Otomatik Arkadaş WL",
   LoadingSubtitle = "Range Enabled | Friend Auto-WL",
   ConfigurationSaving = { Enabled = false }
})

-- [[ K-BUTTON ]]
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local KButton = Instance.new("TextButton", ScreenGui)
KButton.Size = UDim2.new(0, 60, 0, 60); KButton.Position = UDim2.new(0, 20, 0.5, 0)
KButton.BackgroundColor3 = Color3.fromRGB(0, 255, 120); KButton.Text = "K"; KButton.Draggable = true
Instance.new("UICorner", KButton).CornerRadius = UDim.new(1, 0)
KButton.MouseButton1Click:Connect(function()
    _G.MasterActive = not _G.MasterActive
    KButton.BackgroundColor3 = _G.MasterActive and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 0, 50)
    KButton.Text = _G.MasterActive and "K" or "OFF"
end)

-- [[ HEDEF BULUCU (GÖRÜNMEZLERİ ATLA) ]]
local function GetTarget()
    if not _G.MasterActive then return nil end
    local target, blacklistTarget = nil, nil
    local minDist, minBlacklistDist = _G.Range, _G.Range

    for _, plr in pairs(Players:GetPlayers()) do
        local char = plr.Character
        -- Görünmezlik kontrolü (Transparency < 0.5 ise hedef al)
        local isVisible = char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Transparency < 0.5 

        if plr ~= LocalPlayer and char and isVisible and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.Health > 0 then
            local dist = (char.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if dist <= _G.Range then
                if table.find(_G.Blacklist, plr.Name) then
                    if dist < minBlacklistDist then minBlacklistDist = dist; blacklistTarget = char end
                elseif not table.find(_G.Whitelist, plr.Name) then
                    if dist < minDist then minDist = dist; target = char end
                end
            end
        end
    end
    return blacklistTarget or target
end

-- [[ TABS & UI ]]
local MainTab = Window:CreateTab("Savaş", 4483362458)
local ListTab = Window:CreateTab("Oyuncular", 4483362458)

MainTab:CreateToggle({Name = "AUTO ATTACK", CurrentValue = false, Callback = function(v) _G.AutoAttack = v end})
MainTab:CreateSlider({Name = "Menzil (Studs)", Range = {10, 1000}, Increment = 10, CurrentValue = 1000, Callback = function(v) _G.Range = v end})

-- [[ VURUŞ VE KİLİT ]]
task.spawn(function()
    while true do task.wait(1 / 24.5)
        if _G.MasterActive and _G.AutoAttack then
            local t = GetTarget()
            if t then
                VirtualUser:CaptureController(); VirtualUser:ClickButton1(Vector2.new(0, 0))
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
                local r = ReplicatedStorage:FindFirstChild("Remotes") and (ReplicatedStorage.Remotes:FindFirstChild("Attack") or ReplicatedStorage.Remotes:FindFirstChild("Punch") or ReplicatedStorage.Remotes:FindFirstChild("Hit"))
                if r then r:FireServer(t) end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if _G.MasterActive and _G.AutoAttack then
        local t = GetTarget()
        if t and t:FindFirstChild("HumanoidRootPart") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.HumanoidRootPart.Position)
        end
    end
end)

-- [[ OYUNCU YÖNETİMİ ]]
local function BuildList()
    ListTab:CreateSection("--- OYUNCU YÖNETİMİ ---")
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local uName = player.Name
            ListTab:CreateSection(uName .. (table.find(_G.Whitelist, uName) and " [WL]" or ""))
            ListTab:CreateButton({Name = "💀 BLACKLIST", Callback = function() if not table.find(_G.Blacklist, uName) then table.insert(_G.Blacklist, uName) end end})
            ListTab:CreateButton({Name = "🟢 WHITELIST", Callback = function() if not table.find(_G.Whitelist, uName) then table.insert(_G.Whitelist, uName) end end})
            ListTab:CreateButton({Name = "🔴 SİL (RESET)", Callback = function() 
                for i, v in ipairs(_G.Blacklist) do if v == uName then table.remove(_G.Blacklist, i) end end
                for i, v in ipairs(_G.Whitelist) do if v == uName then table.remove(_G.Whitelist, i) end end
            end})
        end
    end
end
ListTab:CreateButton({Name = "🔄 LİSTEYİ YENİLE", Callback = function() BuildList() end})
BuildList()
