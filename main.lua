-- [[ TVL2: COMPLETE V57 V69 ]] --
-- HIZ: 24.5 CPS | MENZİL: AYARLANABİLİR | LİSTE: DROPDOWN METHOD (CALLBACK ERROR FIX)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "TVL2: COMPLETE V69",
   LoadingTitle = "Hata Düzeltmeleri Uygulanıyor...",
   LoadingSubtitle = "Whitelist & Range: ENABLED",
   ConfigurationSaving = { Enabled = false }
 })

-- [[ AYARLAR ]] --
local _G = {
    MasterActive = true,
    AutoAttack = false,
    Range = 1000,
    Whitelist = {},
    Blacklist = {}
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

-- [[ K-BUTTON (V57 STYLE) ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "V69K_Gui"
ScreenGui.Parent = game:GetService("CoreGui")

local KButton = Instance.new("TextButton")
KButton.Parent = ScreenGui
KButton.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
KButton.Size = UDim2.new(0, 60, 0, 60)
KButton.Position = UDim2.new(0, 20, 0.5, 0)
KButton.Text = "K"
KButton.TextColor3 = Color3.fromRGB(255, 255, 255)
KButton.TextSize = 30
KButton.Font = Enum.Font.SourceSansBold
KButton.Draggable = true
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(1, 0)
Corner.Parent = KButton

KButton.MouseButton1Click:Connect(function()
    _G.MasterActive = not _G.MasterActive
    KButton.BackgroundColor3 = _G.MasterActive and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 0, 50)
    KButton.Text = _G.MasterActive and "K" or "OFF"
end)

-- [[ GÖRÜNMEZLİK KONTROL FONKSİYONU ]] --
local function IsPlayerInvisible(character)
    local head = character:FindFirstChild("Head")
    if head and head.Transparency >= 0.5 then
        return true
    end
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            if part.Transparency >= 0.5 then
                return true
            end
        end
    end
    return false
end

-- [[ HEDEF BULUCU ]] --
local function GetTarget()
    if not _G.MasterActive then return nil end
    local target, blacklistTarget = nil, nil
    local minDist, minBlacklistDist = _G.Range, _G.Range

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            
            if not IsPlayerInvisible(plr.Character) then
                local dist = (plr.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if dist <= _G.Range then
                    if table.find(_G.Blacklist, plr.Name) then
                        if dist < minBlacklistDist then minBlacklistDist = dist; blacklistTarget = plr.Character end
                    elseif not table.find(_G.Whitelist, plr.Name) then
                        if dist < minDist then minDist = dist; target = plr.Character end
                    end
                end
            end
            
        end
    end
    return blacklistTarget or target
end

-- [[ TABS ]] --
local MainTab = Window:CreateTab("Savaş", 4483362458)
local ListTab = Window:CreateTab("Oyuncular", 4483362458)

MainTab:CreateToggle({
   Name = "AUTO ATTACK (24.5 CPS)",
   CurrentValue = false,
   Callback = function(v) _G.AutoAttack = v end,
})

MainTab:CreateSlider({
   Name = "Menzil (Studs)",
   Range = {10, 1000},
   Increment = 10,
   CurrentValue = 1000,
   Callback = function(v) _G.Range = v end,
})

-- [[ V57 VURUŞ MOTORU ]] --
task.spawn(function()
    while true do
        task.wait(1 / 24.5)
        if _G.MasterActive and _G.AutoAttack then
            local t = GetTarget()
            if t then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(0, 0))
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
                
                local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
                local r = remotes:FindFirstChild("Attack") or remotes:FindFirstChild("Punch") or remotes:FindFirstChild("Hit")
                if r then r:FireServer(t) end
            end
        end
    end
end)

-- [[ HARD LOCK ]] --
RunService.RenderStepped:Connect(function()
    if _G.MasterActive and _G.AutoAttack then
        local t = GetTarget()
        if t and t:FindFirstChild("HumanoidRootPart") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.HumanoidRootPart.Position)
        end
    end
end)

-- [[ GÜVENLİ LİSTELEME MOTORU ]] --
local SelectedPlayer = ""

-- Aktif oyuncu isimlerini dizi olarak çeken yardımcı fonksiyon
local function GetPlayerNames()
    local names = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    return names
end

ListTab:CreateSection("--- OYUNCU SEÇİMİ ---")

-- Çakışmaları önlemek için tek bir Dropdown elemanı üzerinden seçim yapıyoruz
local PlayerDropdown = ListTab:CreateDropdown({
   Name = "İşlem Yapılacak Oyuncu",
   Options = GetPlayerNames(),
   CurrentOption = "",
   MultipleOptions = false,
   Callback = function(Option)
        SelectedPlayer = Option[1] or Option
   end,
})

ListTab:CreateSection("--- LİSTE İŞLEMLERİ ---")

ListTab:CreateButton({
    Name = "💀 SEÇİLİ OYUNCUYU BLACKLIST'E EKLE",
    Callback = function()
        if SelectedPlayer ~= "" and not table.find(_G.Blacklist, SelectedPlayer) then
            table.insert(_G.Blacklist, SelectedPlayer)
            Rayfield:Notify({Title = "Blacklist", Content = SelectedPlayer .. " kara listeye eklendi.", Duration = 1.5})
        end
    end
})

ListTab:CreateButton({
    Name = "🟢 SEÇİLİ OYUNCUYU WHITELIST'E EKLE",
    Callback = function()
        if SelectedPlayer ~= "" and not table.find(_G.Whitelist, SelectedPlayer) then
            table.insert(_G.Whitelist, SelectedPlayer)
            Rayfield:Notify({Title = "Whitelist", Content = SelectedPlayer .. " beyaz listeye eklendi.", Duration = 1.5})
        end
    end
})

ListTab:CreateButton({
    Name = "🔴 SEÇİLİ OYUNCUYU SIFIRLA (RESET)",
    Callback = function()
        if SelectedPlayer ~= "" then
            for i, v in ipairs(_G.Blacklist) do if v == SelectedPlayer then table.remove(_G.Blacklist, i) end end
            for i, v in ipairs(_G.Whitelist) do if v == SelectedPlayer then table.remove(_G.Whitelist, i) end end
            Rayfield:Notify({Title = "Sıfırlandı", Content = SelectedPlayer .. " normal duruma çekildi.", Duration = 1.5})
        end
    end
})

ListTab:CreateButton({
    Name = "🔄 OYUNCU LİSTESİNİ YENİLE (RELOAD)",
    Callback = function()
        -- Yenileme esnasında arayüzü çökertmeden dropdown seçeneklerini günceller
        PlayerDropdown:Refresh(GetPlayerNames(), true)
        Rayfield:Notify({Title = "Yenilendi", Content = "Oyuncu listesi güncellendi.", Duration = 1})
    end
})

-- OTOMATİK ARKADAŞ KONTROLÜ (Arka planda çalışır, UI elemanlarını etkilemez)
local function AutoCheckFriends()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            task.spawn(function()
                local isFriend = false
                pcall(function()
                    isFriend = LocalPlayer:IsFriendsWith(player.UserId)
                end)
                if isFriend and not table.find(_G.Whitelist, player.Name) then
                    table.insert(_G.Whitelist, player.Name)
                end
            end)
        end
    end
end

-- İlk açılışta arkadaşları otomatik listeye ekle
AutoCheckFriends()
Players.PlayerAdded:Connect(function(player)
    PlayerDropdown:Refresh(GetPlayerNames(), true)
    AutoCheckFriends()
end)
Players.PlayerRemoving:Connect(function(player)
    PlayerDropdown:Refresh(GetPlayerNames(), true)
end)
