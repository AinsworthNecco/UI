-- Script Tổng Tối Ưu Hóa Cực Đoan cho AFK (Cập nhật)

-- === CẤU HÌNH CHUNG ===
local DESTROY_MOST_WORKSPACE_PARTS = true -- !!! RẤT MẠNH TAY !!! Phá hủy hầu hết parts (trừ nhân vật).
local DESTROY_GUI_ELEMENTS = true       -- Phá hủy tất cả GUI.
local MINIMIZE_PLAYER_CHARACTER = true  -- Làm nhân vật gần như vô hình và bất động.
-- === KẾT THÚC CẤU HÌNH ===

-- Biến kiểm tra hàm đặc biệt (thường có trong môi trường exploit)
local sethiddenproperty = sethiddenproperty or set_hidden_property or set_hidden_prop
local settings_func = settings -- Đổi tên để tránh xung đột nếu _G.Settings tồn tại
local userSettings_func = UserSettings

-- Services
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

-- Local Player
local player = Players.LocalPlayer
local hasRunOptimizations = false

local function runExtremeOptimization()
    if hasRunOptimizations and not RunService:IsStudio() then
        return
    end
    hasRunOptimizations = true
    print("LOCAL SCRIPT: Attempting UPDATED EXTREME local optimization for AFK...")

    -- 1. Cài đặt Render Settings Cốt Lõi (NẾU `settings()` và `UserSettings()` hoạt động)
    if settings_func and userSettings_func then
        print("LOCAL SCRIPT: Applying core RenderSettings and UserGameSettings...")
        pcall(function()
            local RenderSettings = settings_func():GetService("RenderSettings")
            local UserGameSettings = userSettings_func():GetService("UserGameSettings")

            RenderSettings.EagerBulkExecution = false
            RenderSettings.QualityLevel = Enum.QualityLevel.Level01
            RenderSettings.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
            UserGameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
            workspace.InterpolationThrottling = Enum.InterpolationThrottlingMode.Enabled
        end)
    else
        print("LOCAL SCRIPT: `settings()` or `UserSettings()` not available. Skipping core RenderSettings.")
    end

    -- 2. Workspace - Cài đặt chung
    pcall(function()
        workspace.LevelOfDetail = Enum.ModelLevelOfDetail.Disabled -- MỚI: Giảm chi tiết model
        if sethiddenproperty then
            pcall(sethiddenproperty, workspace, "MeshPartHeads", Enum.MeshPartHeads.Disabled) -- MỚI: Tắt render đặc biệt cho đầu MeshPart
            print("LOCAL SCRIPT: Attempted to set MeshPartHeads via sethiddenproperty.")
        end
    end)

    -- 3. Lighting và Môi trường Siêu Tối Giản
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogColor = Color3.fromRGB(0, 0, 0)
        Lighting.FogStart = 0
        Lighting.FogEnd = 0.01 -- Giữ sương mù đen kịt để AFK
        Lighting.Brightness = 0
        Lighting.ClockTime = 0
        Lighting.GeographicLatitude = 0
        Lighting.ExposureCompensation = -10
        Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
        Lighting.ShadowSoftness = 0

        if sethiddenproperty then
            pcall(sethiddenproperty, Lighting, "Technology", Enum.Technology.Compatibility)
            print("LOCAL SCRIPT: Attempted to set Lighting.Technology via sethiddenproperty.")
        else
            Lighting.Technology = Enum.Technology.Compatibility
        end
        
        local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
        if atmosphere then Debris:AddItem(atmosphere, 0) end

        local sky = Lighting:FindFirstChildOfClass("Sky") -- Xử lý Sky ở vòng lặp dưới, nhưng nếu có sky trực tiếp trong Lighting thì xóa
        if sky and sky.Parent == Lighting then Debris:AddItem(sky, 0) end
    end)

    -- 4. Âm thanh Tắt Hoàn Toàn (Giữ nguyên từ script tổng trước)
    pcall(function()
        SoundService.AmbientReverb = Enum.ReverbType.NoReverb
        local soundsToProcess = {}
        for _, descendant in ipairs(Workspace:GetDescendants()) do if descendant:IsA("Sound") then table.insert(soundsToProcess, descendant) end end
        for _, descendant in ipairs(SoundService:GetDescendants()) do if descendant:IsA("Sound") then table.insert(soundsToProcess, descendant) end end
        if player and player.PlayerGui then for _, descendant in ipairs(player.PlayerGui:GetDescendants()) do if descendant:IsA("Sound") then table.insert(soundsToProcess, descendant) end end end
        for _, soundObject in ipairs(soundsToProcess) do if soundObject and soundObject.Parent then soundObject.Playing = false; soundObject.Volume = 0 end end
    end)

    -- 5. Giao diện Người dùng (GUI) Phá Hủy hoặc Vô Hiệu Hóa
    if DESTROY_GUI_ELEMENTS then
        pcall(function() if player and player.PlayerGui then for _, gui in ipairs(player.PlayerGui:GetChildren()) do Debris:AddItem(gui, 0) end end end)
    else
        pcall(function() if player and player.PlayerGui then for _, gui in ipairs(player.PlayerGui:GetChildren()) do if gui:IsA("ScreenGui") then gui.Enabled = false end end end end)
    end
    
    -- 6. Địa hình (Terrain) Tối Giản Hóa
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        pcall(function()
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0 -- MỚI
            terrain.WaterTransparency = 1 -- Giữ trong suốt để AFK
            
            if sethiddenproperty then
                pcall(sethiddenproperty, terrain, "Decoration", false)
                print("LOCAL SCRIPT: Attempted to set Terrain.Decoration via sethiddenproperty.")
            else
                terrain.Decoration = false
            end
            -- Cân nhắc phá hủy terrain hoặc làm nó hoàn toàn trong suốt nếu mục tiêu là tuyệt đối
            -- Debris:AddItem(terrain, 5) -- Xóa terrain sau 5s
            -- Hoặc: terrain.Transparency = 1
        end)
    end

    -- 7. Workspace: Cuộc Đại Thanh Trừng (hoặc Tối Giản Hóa)
    local playerCharacter = player.Character
    local itemsToProcess = Workspace:GetDescendants() -- Lấy danh sách một lần

    for _, descendant in ipairs(itemsToProcess) do
        if not descendant or not descendant.Parent then continue end -- Bỏ qua nếu đã bị xóa

        -- Xử lý Nhân vật Người chơi
        if descendant == playerCharacter or (playerCharacter and descendant:IsDescendantOf(playerCharacter)) then
            if MINIMIZE_PLAYER_CHARACTER and playerCharacter then
                pcall(function()
                    local humanoid = playerCharacter:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None; humanoid.HealthDisplayDistance = 0; humanoid.NameDisplayDistance = 0
                        humanoid.WalkSpeed = 0; humanoid.JumpPower = 0; humanoid.AutoRotate = false
                        if humanoid:GetState() ~= Enum.HumanoidStateType.Dead then humanoid:ChangeState(Enum.HumanoidStateType.Physics) end
                        local animator = humanoid:FindFirstChildOfClass("Animator")
                        if animator then for _, track in ipairs(animator:GetPlayingAnimationTracks()) do track:Stop(0.01); Debris:AddItem(track, 0.1) end end
                        for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do track:Stop(0.01); Debris:AddItem(track, 0.1) end
                    end
                    for _, charPart in ipairs(playerCharacter:GetDescendants()) do
                        if charPart:IsA("BasePart") then charPart.Transparency = 1; charPart.CanCollide = false; charPart.CastShadow = false; charPart.Anchored = true; charPart.Material = Enum.Material.Plastic end -- MỚI: đổi material nhân vật luôn
                        if charPart:IsA("Decal") or charPart:IsA("Texture") then charPart.Transparency = 1 end
                        if charPart:IsA("Accessory") then Debris:AddItem(charPart, 0) end
                    end
                end)
            end
        -- Xử lý các đối tượng khác
        elseif descendant ~= Workspace.CurrentCamera and not descendant:IsA("Terrain") and not descendant:IsA("Script") and not descendant:IsA("LocalScript") and not descendant:IsA("Configuration") then
            local processed = false
            -- Các loại đối tượng cần xử lý đặc biệt trước khi quyết định phá hủy chung
            if descendant:IsA("Sky") then
                pcall(function() descendant.StarCount = 0; descendant.CelestialBodiesShown = false; Debris:AddItem(descendant,0.1) end) -- Xóa sky luôn
                processed = true
            elseif descendant:IsA("Atmosphere") then -- Đã xử lý ở Lighting, nhưng nếu có thêm thì xóa
                pcall(function() Debris:AddItem(descendant, 0) end)
                processed = true
            elseif descendant:IsA("SurfaceAppearance") then -- MỚI: Xóa SurfaceAppearance
                pcall(function() Debris:AddItem(descendant, 0) end)
                processed = true
            elseif (descendant:IsA("ParticleEmitter") or descendant:IsA("Sparkles") or descendant:IsA("Smoke") or descendant:IsA("Trail") or descendant:IsA("Fire")) then
                pcall(function() descendant.Enabled = false; Debris:AddItem(descendant, 0.1) end)
                processed = true
            elseif (descendant:IsA("ColorCorrectionEffect") or descendant:IsA("DepthOfFieldEffect") or descendant:IsA("SunRaysEffect") or descendant:IsA("BloomEffect") or descendant:IsA("BlurEffect") or descendant:IsA("Light")) then
                pcall(function() descendant.Enabled = false; Debris:AddItem(descendant, 0.1) end)
                processed = true
            end

            if not processed then -- Nếu chưa được xử lý đặc biệt ở trên
                if DESTROY_MOST_WORKSPACE_PARTS then
                    Debris:AddItem(descendant, 0) -- Phá hủy
                else -- Nếu không phá hủy, thì làm vô hình/tĩnh/đơn giản
                    pcall(function()
                        if descendant:IsA("BasePart") then
                            descendant.Transparency = 1; descendant.CastShadow = false; descendant.CanCollide = false; descendant.Anchored = true
                            descendant.Material = Enum.Material.Plastic -- MỚI: Đổi material
                        elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
                            descendant.Transparency = 1
                        end
                    end)
                end
            end
        end
        if _ % 200 == 0 then task.wait() end -- Thêm task.wait để tránh quá tải nếu workspace quá lớn
    end

    -- 8. Camera Tối Giản
    local cam = Workspace.CurrentCamera
    if cam then
        pcall(function()
            cam.FieldOfView = 1; cam.CameraType = Enum.CameraType.Scriptable
            local hrp = playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart")
            cam.CameraSubject = if hrp and hrp.Parent then hrp else cam
            cam.CFrame = CFrame.new(0, -300000, 0)
        end)
    end
    
    print("LOCAL SCRIPT: UPDATED EXTREME local optimization attempt complete.")
end

-- Chạy tối ưu hóa
local function initializeOptimization()
    local startTime = tick()
    repeat task.wait() until (player and player.Character) or tick() - startTime > 7
    if not hasRunOptimizations then runExtremeOptimization() end
end

initializeOptimization()
player.CharacterAdded:Connect(function(char) -- Chạy lại nếu nhân vật hồi sinh (dù có thể không cần thiết cho AFK)
    task.wait(1) -- Chờ một chút
    if not hasRunOptimizations then runExtremeOptimization() end
end)
