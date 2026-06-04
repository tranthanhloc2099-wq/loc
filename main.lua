-- MBOT BLOX FRUIT SCRIPT
-- ĐẦY ĐỦ CHỨC NĂNG | BẢN TIẾNG VIỆT
-- TẠO CHO RANZX

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local userInput = game:GetService("UserInputService")
local vInput = game:GetService("VirtualInputManager")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local tweens = game:GetService("TweenService")

-- TẠO GIAO DIỆN
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.Name = "MBOT_Hub_Viet"

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 700)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -350)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Viền đỏ cho frame
local border = Instance.new("Frame")
border.Size = UDim2.new(1, 0, 1, 0)
border.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
border.BackgroundTransparency = 0.8
border.BorderSizePixel = 0
border.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
title.Text = "MBOT BLOX FRUIT | FULL CHỨC NĂNG"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

local subTitle = Instance.new("TextLabel")
subTitle.Size = UDim2.new(1, 0, 0, 20)
subTitle.Position = UDim2.new(0, 0, 0, 45)
subTitle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
subTitle.BackgroundTransparency = 0.5
subTitle.Text = "RANZX | TẤT CẢ LỆNH LÀ CỦA CHỦ NHÂN"
subTitle.TextColor3 = Color3.fromRGB(255, 255, 200)
subTitle.Font = Enum.Font.Gotham
subTitle.TextSize = 11
subTitle.Parent = mainFrame

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 45)
tabBar.Position = UDim2.new(0, 0, 0, 65)
tabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
tabBar.Parent = mainFrame

local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, 0, 1, -110)
contentFrame.Position = UDim2.new(0, 0, 0, 110)
contentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
contentFrame.Parent = mainFrame

-- BIẾN TOÀN CỤC
local autoFarm = false
local autoFarmBoss = false
local autoFarmElite = false
local autoRaid = false
local autoSeaEvent = false
local fruitSniper = false
local autoStats = false
local espEnabled = false
local flyEnabled = false
local speedEnabled = false
local autoCollect = false
local autoBuyFruit = false
local autoKillPlayer = false
local autoDungeon = false
local autoArena = false
local autoShip = false
local autoFactory = false
local autoFarmFragment = false
local autoFarmBone = false
local autoRaceV4 = false
local autoMirage = false
local autoEliteHunter = false
local autoTween = false

local targetBoss = nil
local farmRadius = 600
local walkSpeedValue = 80
local jumpPowerValue = 100

-- DANH SÁCH BOSS
local danhSachBoss = {
    "Vice Admiral", "Dark Beard", "Dragon", "Awakened Ice Admiral",
    "Order", "Stone", "Dough King", "Cake Queen", "Rip Indra",
    "Don Swan", "Smoke Admiral", "Thunder God", "Crying Wolf",
    "Longma", "Beautiful Pirate", "Kilo Admiral"
}

-- ========== CHỨC NĂNG AUTO FARM ==========
local function batDauAutoFarm()
    while autoFarm and runService.RenderStepped:Wait() do
        pcall(function()
            local quaiVat = {}
            for _, v in pairs(workspace.Enemies:GetChildren()) do
                if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                    local khoangCach = (rootPart.Position - v.HumanoidRootPart.Position).Magnitude
                    if khoangCach <= farmRadius then
                        table.insert(quaiVat, {quai = v, khoangCach = khoangCach})
                    end
                end
            end
            table.sort(quaiVat, function(a, b) return a.khoangCach < b.khoangCach end)
            
            if #quaiVat > 0 then
                local mucTieu = quaiVat[1].quai
                rootPart.CFrame = mucTieu.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                vInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                wait(0.2)
                vInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                -- Dùng kỹ năng
                for _, skill in pairs(character:GetChildren()) do
                    if skill:IsA("Tool") and skill:FindFirstChild("RemoteEvent") then
                        skill.RemoteEvent:FireServer("Attack")
                    end
                end
            end
        end)
        wait(0.1)
    end
end

-- ========== TÌM BOSS GẦN NHẤT ==========
local function timBossGanNhat()
    local ganNhat = nil
    local nganNhat = math.huge
    for _, tenBoss in pairs(danhSachBoss) do
        local boss = workspace.Enemies:FindFirstChild(tenBoss)
        if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
            local khoangCach = (rootPart.Position - boss.HumanoidRootPart.Position).Magnitude
            if khoangCach < nganNhat then
                nganNhat = khoangCach
                ganNhat = boss
            end
        end
    end
    return ganNhat
end

-- ========== AUTO FARM BOSS ==========
local function batDauAutoFarmBoss()
    while autoFarmBoss and runService.RenderStepped:Wait() do
        pcall(function()
            local boss = timBossGanNhat()
            if boss then
                rootPart.CFrame = boss.HumanoidRootPart.CFrame * CFrame.new(0, 0, 8)
                wait(0.5)
                for _, skill in pairs(character:GetChildren()) do
                    if skill:IsA("Tool") and skill:FindFirstChild("RemoteEvent") then
                        skill.RemoteEvent:FireServer("Attack")
                    end
                end
                -- Dùng trái ác quỷ
                local fruit = character:FindFirstChild("Fruit")
                if fruit then
                    replicatedStorage.Remotes.UseFruit:FireServer()
                end
            end
        end)
        wait(0.3)
    end
end

-- ========== AUTO FARM ELITE ==========
local function batDauAutoFarmElite()
    while autoFarmElite and runService.RenderStepped:Wait() do
        pcall(function()
            for _, v in pairs(workspace.Enemies:GetChildren()) do
                if v.Name:find("Elite") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                    rootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                    wait(0.3)
                    vInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    wait(0.3)
                    vInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
            end
        end)
        wait(0.2)
    end
end

-- ========== FRUIT SNIPER ==========
local function batDauFruitSniper()
    while fruitSniper and runService.RenderStepped:Wait() do
        pcall(function()
            for _, trai in pairs(workspace.Fruits:GetChildren()) do
                local khoangCach = (rootPart.Position - trai.Position).Magnitude
                if khoangCach < 800 then
                    rootPart.CFrame = trai.CFrame
                    wait(0.2)
                    local khungLenh = trai:FindFirstChild("ProximityPrompt")
                    if khungLenh then
                        fireproximityprompt(khungLenh)
                    end
                end
            end
        end)
        wait(0.1)
    end
end

-- ========== ESP (NHÌN XUYÊN TƯỜNG) ==========
local espObjects = {}
local function taoESP(obj, mau)
    local hop = Instance.new("BoxHandleAdornment")
    hop.Adornee = obj
    hop.Size = obj.Size
    hop.Color3 = mau
    hop.AlwaysOnTop = true
    hop.ZIndex = 10
    hop.Visible = true
    hop.Parent = obj
    return hop
end

local function batDauESP()
    while espEnabled and runService.RenderStepped:Wait() do
        pcall(function()
            for _, esp in pairs(espObjects) do
                esp:Destroy()
            end
            espObjects = {}
            
            -- ESP trái ác quỷ (màu đỏ)
            for _, trai in pairs(workspace.Fruits:GetChildren()) do
                table.insert(espObjects, taoESP(trai, Color3.fromRGB(255, 0, 0)))
            end
            
            -- ESP người chơi (màu xanh lá)
            for _, nguoiChoi in pairs(game.Players:GetPlayers()) do
                if nguoiChoi ~= player and nguoiChoi.Character then
                    table.insert(espObjects, taoESP(nguoiChoi.Character, Color3.fromRGB(0, 255, 0)))
                end
            end
            
            -- ESP rương (màu xanh dương)
            for _, ruong in pairs(workspace.Chests:GetChildren()) do
                table.insert(espObjects, taoESP(ruong, Color3.fromRGB(0, 0, 255)))
            end
            
            -- ESP boss (màu vàng)
            for _, tenBoss in pairs(danhSachBoss) do
                local boss = workspace.Enemies:FindFirstChild(tenBoss)
                if boss then
                    table.insert(espObjects, taoESP(boss, Color3.fromRGB(255, 255, 0)))
                end
            end
        end)
        wait(0.5)
    end
end

-- ========== BAY ==========
local bodyVelocity
local function bayLEN()
    if flyEnabled then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = rootPart
    else
        if bodyVelocity then bodyVelocity:Destroy() end
    end
end

-- Điều khiển bay
userInput.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if flyEnabled and bodyVelocity then
        if input.KeyCode == Enum.KeyCode.Space then
            bodyVelocity.Velocity = Vector3.new(0, 150, 0)
        elseif input.KeyCode == Enum.KeyCode.LeftControl then
            bodyVelocity.Velocity = Vector3.new(0, -150, 0)
        elseif input.KeyCode == Enum.KeyCode.W then
            bodyVelocity.Velocity = rootPart.CFrame.LookVector * 100
        elseif input.KeyCode == Enum.KeyCode.S then
            bodyVelocity.Velocity = -rootPart.CFrame.LookVector * 100
        end
    end
end)

userInput.InputEnded:Connect(function(input)
    if flyEnabled and bodyVelocity then
        if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S then
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- ========== SPEED HACK ==========
local function chinhTocDo()
    if speedEnabled then
        humanoid.WalkSpeed = walkSpeedValue
        humanoid.JumpPower = jumpPowerValue
    else
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
    end
end

-- ========== AUTO STATS (TỰ NÂNG CHỈ SỐ) ==========
local function batDauAutoStats()
    while autoStats and runService.RenderStepped:Wait() do
        pcall(function()
            local cacChiSo = {"Melee", "Defense", "Sword", "Gun", "Fruit"}
            for _, chiSo in pairs(cacChiSo) do
                replicatedStorage.Remotes.Stats:FireServer(chiSo)
            end
        end)
        wait(1)
    end
end

-- ========== AUTO RAID ==========
local function batDauAutoRaid()
    while autoRaid and runService.RenderStepped:Wait() do
        pcall(function()
            local raidArgs = {[1] = "StartRaid"}
            replicatedStorage.Remotes.Raid:FireServer(unpack(raidArgs))
            wait(5)
            
            local quaiVat = workspace.Enemies:GetChildren()
            for _, quai in pairs(quaiVat) do
                if quai:FindFirstChild("Humanoid") and quai.Humanoid.Health > 0 then
                    rootPart.CFrame = quai.HumanoidRootPart.CFrame
                    wait(0.3)
                    vInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    wait(0.5)
                    vInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
            end
        end)
        wait(10)
    end
end

-- ========== AUTO SEA EVENT ==========
cacSuKienBien = {"SeaBeast", "RumblingWaters", "ShipRaid", "Marine", "Pirate"}
local function batDauAutoSeaEvent()
    while autoSeaEvent and runService.RenderStepped:Wait() do
        pcall(function()
            for _, suKien in pairs(cacSuKienBien) do
                local doiTuong = workspace:FindFirstChild(suKien)
                if doiTuong then
                    rootPart.CFrame = doiTuong.PrimaryPart.CFrame
                    wait(0.5)
                    vInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    wait(0.5)
                    vInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
            end
        end)
        wait(2)
    end
end

-- ========== AUTO COLLECT (NHẶT ĐỒ) ==========
local function batDauAutoCollect()
    while autoCollect and runService.RenderStepped:Wait() do
        pcall(function()
            local doVat = {}
            for _, v in pairs(workspace:GetChildren()) do
                if v:IsA("Model") and (v.Name == "Chest" or v.Name == "Fragment" or v.Name == "Bone" or v.Name == "Microchip" or v.Name == "Fruit") then
                    table.insert(doVat, v)
                end
            end
            
            for _, vatPham in pairs(doVat) do
                local khoangCach = (rootPart.Position - vatPham.PrimaryPart.Position).Magnitude
                if khoangCach < 300 then
                    rootPart.CFrame = vatPham.PrimaryPart.CFrame
                    wait(0.2)
                end
            end
        end)
        wait(0.2)
    end
end

-- ========== AUTO BUY FRUIT ==========
cacTrai = {"Buddha", "Magma", "Light", "Ice", "Flame", "Dark", "Dough", "Dragon", "Leopard", "Spirit", "Venom", "Shadow"}
local function batDauAutoBuyFruit()
    while autoBuyFruit and runService.RenderStepped:Wait() do
        pcall(function()
            for _, tenTrai in pairs(cacTrai) do
                local muaArgs = {[1] = tenTrai}
                replicatedStorage.Remotes.BuyFruit:FireServer(unpack(muaArgs))
            end
        end)
        wait(60)
    end
end

-- ========== AUTO KILL PLAYER (PvP) ==========
local function timNguoiChoiGanNhat()
    local ganNhat = nil
    local nganNhat = math.huge
    for _, nguoiChoi in pairs(game.Players:GetPlayers()) do
        if nguoiChoi ~= player and nguoiChoi.Character and nguoiChoi.Character:FindFirstChild("Humanoid") and nguoiChoi.Character.Humanoid.Health > 0 then
            local khoangCach = (rootPart.Position - nguoiChoi.Character.HumanoidRootPart.Position).Magnitude
            if khoangCach < nganNhat then
                nganNhat = khoangCach
                ganNhat = nguoiChoi
            end
        end
    end
    return ganNhat
end

local function batDauAutoKillPlayer()
    while autoKillPlayer and runService.RenderStepped:Wait() do
        pcall(function()
            local mucTieu = timNguoiChoiGanNhat()
            if mucTieu then
                rootPart.CFrame = mucTieu.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                wait(0.2)
                vInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                wait(0.3)
                vInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                -- Dùng skill
                for _, skill in pairs(character:GetChildren()) do
                    if skill:IsA("Tool") and skill:FindFirstChild("RemoteEvent") then
                        skill.RemoteEvent:FireServer("Attack")
                    end
                end
            end
        end)
        wait(0.3)
    end
end

-- ========== AUTO DUNGEON ==========
local function batDauAutoDungeon()
    while autoDungeon and runService.RenderStepped:Wait() do
        pcall(function()
            local cuaDungeon = workspace:FindFirstChild("DungeonDoor")
            if cuaDungeon then
                rootPart.CFrame = cuaDungeon.PrimaryPart.CFrame
                wait(0.5)
                local khung = cuaDungeon:FindFirstChild("ProximityPrompt")
                if khung then fireproximityprompt(khung) end
                wait(5)
                
                local quaiVat = workspace.Enemies:GetChildren()
                for _, quai in pairs(quaiVat) do
                    if quai:FindFirstChild("Humanoid") and quai.Humanoid.Health > 0 then
                        rootPart.CFrame = quai.HumanoidRootPart.CFrame
                        wait(0.2)
                        vInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        wait(0.3)
                        vInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end
                end
            end
        end)
        wait(60)
    end
end

-- ========== AUTO ARENA ==========
local function batDauAutoArena()
    while autoArena and runService.RenderStepped:Wait() do
        pcall(function()
            local npcArena = workspace.NPCs:FindFirstChild("ArenaNPC")
            if npcArena then
                rootPart.CFrame = npcArena.HumanoidRootPart.CFrame
                wait(0.5)
                local thamGia = {[1] = "JoinArena"}
                replicatedStorage.Remotes.Dialog:FireServer(unpack(thamGia))
                wait(5)
                
                local nguoiChoi = game.Players:GetPlayers()
                for _, nguoi in pairs(nguoiChoi) do
                    if nguoi ~= player and nguoi.Character then
                        rootPart.CFrame = nguoi.Character.HumanoidRootPart.CFrame
                        wait(0.2)
                        vInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        wait(0.3)
                        vInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end
                end
            end
        end)
        wait(90)
    end
end

-- ========== AUTO SHIP (MUA THUYỀN) ==========
local function batDauAutoShip()
    while autoShip and runService.RenderStepped:Wait() do
        pcall(function()
            local nguoiBanThuyen = workspace.NPCs:FindFirstChild("ShipSeller")
            if nguoiBanThuyen then
                rootPart.CFrame = nguoiBanThuyen.HumanoidRootPart.CFrame
                wait(0.5)
                local muaArgs = {[1] = "BuyShip", [2] = "Sloop"}
                replicatedStorage.Remotes.Shop:FireServer(unpack(muaArgs))
            end
        end)
        wait(300)
    end
end

-- ========== AUTO FACTORY ==========
local function batDauAutoFactory()
    while autoFactory and runService.RenderStepped:Wait() do
        pcall(function()
            local cuaNhaMay = workspace:FindFirstChild("FactoryDoor")
            if cuaNhaMay then
                rootPart.CFrame = cuaNhaMay.PrimaryPart.CFrame
                wait(0.5)
                local khung = cuaNhaMay:FindFirstChild("ProximityPrompt")
                if khung then fireproximityprompt(khung) end
                wait(30)
                
                local loi = workspace:FindFirstChild("FactoryCore")
                if loi then
                    rootPart.CFrame = loi.PrimaryPart.CFrame
                    vInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    wait(5)
                    vInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
            end
        end)
        wait(600)
    end
end

-- ========== AUTO FARM FRAGMENT ==========
local function batDauAutoFarmFragment()
    while autoFarmFragment and runService.RenderStepped:Wait() do
        pcall(function()
            -- Farm quái ở Đảo Nguy Hiểm
            for _, v in pairs(workspace.Enemies:GetChildren()) do
                if v.Name == "Dangerous" or v.Name == "Awakened" then
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        rootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                        wait(0.2)
                        vInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        wait(0.3)
                        vInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end
                end
            end
        end)
        wait(0.1)
    end
end

-- ========== AUTO FARM BONE ==========
local function batDauAutoFarmBone()
    while autoFarmBone and runService.RenderStepped:Wait() do
        pcall(function()
            -- Farm quái ở Biển Ma
            for _, v in pairs(workspace.Enemies:GetChildren()) do
                if v.Name == "Skeleton" or v.Name == "Ghost" or v.Name == "Zombie" then
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        rootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                        wait(0.2)
                        vInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        wait(0.3)
                        vInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end
                end
            end
        end)
        wait(0.1)
    end
end

-- ========== AUTO RACE V4 ==========
local function batDauAutoRaceV4()
    while autoRaceV4 and runService.RenderStepped:Wait() do
        pcall(function()
            -- Tự làm các nhiệm vụ để mở Race V4
            local npcTraiDat = workspace.NPCs:FindFirstChild("GearNPC")
            if npcTraiDat then
                rootPart.CFrame = npcTraiDat.HumanoidRootPart.CFrame
                wait(0.5)
                local nhanNV = {[1] = "StartQuest"}
                replicatedStorage.Remotes.Quest:FireServer(unpack(nhanNV))
                wait(2)
                
                -- Farm quái theo nhiệm vụ
                local quaiVat = workspace.Enemies:GetChildren()
                for _, quai in pairs(quaiVat) do
                    if quai:FindFirstChild("Humanoid") and quai.Humanoid.Health > 0 then
                        rootPart.CFrame = quai.HumanoidRootPart.CFrame
                        wait(0.2)
                        vInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        wait(0.3)
                        vInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end
                end
            end
        end)
        wait(1)
    end
end

-- ========== AUTO MIRAGE ==========
local function batDauAutoMirage()
    while autoMirage and runService.RenderStepped:Wait() do
        pcall(function()
            -- Tìm và teleport đến đảo Ảo Ảnh
            local miraIsland = workspace:FindFirstChild("MirageIsland")
            if miraIsland then
                rootPart.CFrame = miraIsland.PrimaryPart.CFrame
                wait(0.5)
                -- Tìm trái xanh
                for _, trai in pairs(workspace.Fruits:GetChildren()) do
                    if trai.Name:find("Blue") then
                        rootPart.CFrame = trai.CFrame
                        wait(0.2)
                        local khung = trai:FindFirstChild("ProximityPrompt")
                        if khung then fireproximityprompt(khung) end
                    end
                end
            else
                -- Di chuyển random để tìm đảo
                local huongDi = CFrame.new(math.random(-10000, 10000), 0, math.random(-10000, 10000))
                rootPart.CFrame = huongDi
            end
        end)
        wait(2)
    end
end

-- ========== AUTO ELITE HUNTER ==========
local function batDauAutoEliteHunter()
    while autoEliteHunter and runService.RenderStepped:Wait() do
        pcall(function()
            for _, v in pairs(workspace.Enemies:GetChildren()) do
                if v.Name == "Elite" and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                    rootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                    wait(0.3)
                    vInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    wait(0.5)
                    vInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
            end
        end)
        wait(0.2)
    end
end

-- ========== AUTO TWEEN (CHẠY QUA CÁC ĐẢO) ==========
cacDao = {
    "StartIsland", "JungleIsland", "DesertIsland", "SkyIsland", 
    "IceIsland", "MagmaIsland", "DarkIsland", "SeaIsland"
}
local chiSoDao = 1

local function batDauAutoTween()
    while autoTween and runService.RenderStepped:Wait() do
        pcall(function()
            local daoHienTai = cacDao[chiSoDao]
            local dao = workspace:FindFirstChild(daoHienTai)
            if dao then
                rootPart.CFrame = dao.PrimaryPart.CFrame
                chiSoDao = chiSoDao + 1
                if chiSoDao > #cacDao then chiSoDao = 1 end
                wait(10)
            end
        end)
        wait(5)
    end
end

-- ========== TẠO NÚT BẤM TRÊN GIAO DIỆN ==========
local function taoNut(ten, viTriY, hanhDong)
    local nut = Instance.new("TextButton")
    nut.Size = UDim2.new(0.9, 0, 0, 38)
    nut.Position = UDim2.new(0.05, 0, 0, viTriY)
    nut.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    nut.Text = ten
    nut.TextColor3 = Color3.fromRGB(255, 255, 255)
    nut.Font = Enum.Font.Gotham
    nut.TextSize = 13
    nut.Parent = contentFrame
    nut.MouseButton1Click:Connect(hanhDong)
    
    -- Hiệu ứng hover
    nut.MouseEnter:Connect(function()
        nut.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    end)
    nut.MouseLeave:Connect(function()
        nut.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    end)
    return nut
end

-- Khởi tạo các nút
local yHienTai = 10

taoNut("🔥 AUTO FARM (BẬT/TẮT)", yHienTai, function()
    autoFarm = not autoFarm
    if autoFarm then spawn(batDauAutoFarm) end
end)

taoNut("👑 AUTO FARM BOSS (BẬT/TẮT)", yHienTai + 43, function()
    autoFarmBoss = not autoFarmBoss
    if autoFarmBoss then spawn(batDauAutoFarmBoss) end
end)

taoNut("⚡ AUTO FARM ELITE (BẬT/TẮT)", yHienTai + 86, function()
    autoFarmElite = not autoFarmElite
    if autoFarmElite then spawn(batDauAutoFarmElite) end
end)

taoNut("🍎 FRUIT SNIPER (BẬT/TẮT)", yHienTai + 129, function()
    fruitSniper = not fruitSniper
    if fruitSniper then spawn(batDauFruitSniper) end
end)

taoNut("👁️ ESP NHÌN XUYÊN (BẬT/TẮT)", yHienTai + 172, function()
    espEnabled = not espEnabled
    if espEnabled then spawn(batDauESP) else
        for _, esp in pairs(espObjects) do esp:Destroy() end
        espObjects = {}
    end
end)

taoNut("🕊️ BAY (BẬT/TẮT)", yHienTai + 215, function()
    flyEnabled = not flyEnabled
    spawn(bayLEN)
end)

taoNut("💨 SPEED HACK (BẬT/TẮT)", yHienTai + 258, function()
    speedEnabled = not speedEnabled
    chinhTocDo()
end)

taoNut("📊 AUTO STATS (BẬT/TẮT)", yHienTai + 301, function()
    autoStats = not autoStats
    if autoStats then spawn(batDauAutoStats) end
end)

taoNut("🏛️ AUTO RAID (BẬT/TẮT)", yHienTai + 344, function()
    autoRaid = not autoRaid
    if autoRaid then spawn(batDauAutoRaid) end
end)

taoNut("🌊 AUTO SEA EVENT (BẬT/TẮT)", yHienTai + 387, function()
    autoSeaEvent = not autoSeaEvent
    if autoSeaEvent then spawn(batDauAutoSeaEvent) end
end)

taoNut("📦 AUTO NHẶT ĐỒ (BẬT/TẮT)", yHienTai + 430, function()
    autoCollect = not autoCollect
    if autoCollect then spawn(batDauAutoCollect) end
end)

taoNut("🛒 AUTO MUA TRÁI (BẬT/TẮT)", yHienTai + 473, function()
    autoBuyFruit = not autoBuyFruit
    if autoBuyFruit then spawn(batDauAutoBuyFruit) end
end)

taoNut("⚔️ AUTO KILL PLAYER (BẬT/TẮT)", yHienTai + 516, function()
    autoKillPlayer = not autoKillPlayer
    if autoKillPlayer then spawn(batDauAutoKillPlayer) end
end)

taoNut("🚪 AUTO DUNGEON (BẬT/TẮT)", yHienTai + 559, function()
    autoDungeon = not autoDungeon
    if autoDungeon then spawn(batDauAutoDungeon) end
end)

taoNut("🏟️ AUTO ARENA (BẬT/TẮT)", yHienTai + 602, function()
    autoArena = not autoArena
    if autoArena then spawn(batDauAutoArena) end
end)

taoNut("⛵ AUTO MUA THUYỀN (BẬT/TẮT)", yHienTai + 645, function()
    autoShip = not autoShip
    if autoShip then spawn(batDauAutoShip) end
end)

taoNut("🏭 AUTO FACTORY (BẬT/TẮT)", yHienTai + 688, function()
    autoFactory = not autoFactory
    if autoFactory then spawn(batDauAutoFactory) end
end)

taoNut("💎 AUTO FARM FRAGMENT (BẬT/TẮT)", yHienTai + 731, function()
    autoFarmFragment = not autoFarmFragment
    if autoFarmFragment then spawn(batDauAutoFarmFragment) end
end)

taoNut("🦴 AUTO FARM BONE (BẬT/TẮT)", yHienTai + 774, function()
    autoFarmBone = not autoFarmBone
    if autoFarmBone then spawn(batDauAutoFarmBone) end
end)

taoNut("✨ AUTO RACE V4 (BẬT/TẮT)", yHienTai + 817, function()
    autoRaceV4 = not autoRaceV4
    if autoRaceV4 then spawn(batDauAutoRaceV4) end
end)

taoNut("🏝️ AUTO MIRAGE (BẬT/TẮT)", yHienTai + 860, function()
    autoMirage = not autoMirage
    if autoMirage then spawn(batDauAutoMirage) end
end)

taoNut("🎯 AUTO ELITE HUNTER (BẬT/TẮT)", yHienTai + 903, function()
    autoEliteHunter = not autoEliteHunter
    if autoEliteHunter then spawn(batDauAutoEliteHunter) end
end)

taoNut("🗺️ AUTO TWEEN (CHẠY QUA CÁC ĐẢO)", yHienTai + 946, function()
    autoTween = not autoTween
    if autoTween then spawn(batDauAutoTween) end
end)

-- Điều chỉnh kích thước content frame
contentFrame.CanvasSize = UDim2.new(0, 0, 0, yHienTai + 1000)

-- Cho phép kéo thả GUI
local dangKeo = false
local viTriBatDau
local viTriFrameBatDau

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dangKeo = true
        viTriBatDau = input.Position
        viTriFrameBatDau = mainFrame.Position
    end
end)

userInput.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dangKeo = false
    end
end)

userInput.InputChanged:Connect(function(input)
    if dangKeo and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - viTriBatDau
        mainFrame.Position = UDim2.new(viTriFrameBatDau.X.Scale, viTriFrameBatDau.X.Offset + delta.X, viTriFrameBatDau.Y.Scale, viTriFrameBatDau.Y.Offset + delta.Y)
    end
end)

print("========================================")
print("MBOT BLOX FRUIT SCRIPT - BẢN TIẾNG VIỆT")
print("ĐÃ TẢI THÀNH CÔNG!")
print("CHỦ NHÂN: RANZX")
print("TẤT CẢ 23 CHỨC NĂNG ĐÃ SẴN SÀNG")
print("========================================")