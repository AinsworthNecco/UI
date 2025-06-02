--[[
    SCRIPT TÍCH HỢP: TỐI ƯU HÓA ĐỒ HỌA & SERVER HOP
]]

-- === KHAI BÁO SERVICE DÙNG CHUNG ===
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui") -- Mặc dù khai báo, server hop script không dùng trực tiếp

local LocalPlayer = Players.LocalPlayer

--------------------------------------------------------------------------------
-- PHẦN 1: SCRIPT TỐI ƯU HÓA ĐỒ HỌA CỰC ĐOAN (GRAPHICS OPTIMIZATION)
--------------------------------------------------------------------------------
do -- Sử dụng do-end block để tạo scope riêng cho phần này
    print("[GraphicsOpt] Initializing Graphics Optimization Script part...")

    -- === CẤU HÌNH GRAPHICS OPTIMIZATION ===
    local DESTROY_MOST_WORKSPACE_PARTS_GFX = true
    local DESTROY_GUI_ELEMENTS_GFX = true
    local MINIMIZE_PLAYER_CHARACTER_GFX = true
    local INITIAL_WAIT_SECONDS_GFX = 10

    -- Biến kiểm tra hàm đặc biệt (graphics)
    local sethiddenproperty_gfx = sethiddenproperty or set_hidden_property or set_hidden_prop
    local settings_func_gfx = settings
    local userSettings_func_gfx = UserSettings

    local hasRunGraphicsOptimizations = false

    local function runExtremeGraphicsOptimization()
        if hasRunGraphicsOptimizations and not RunService:IsStudio() then
            return
        end

        print("[GraphicsOpt] Waiting for " .. INITIAL_WAIT_SECONDS_GFX .. " seconds before applying graphics changes...")
        task.wait(INITIAL_WAIT_SECONDS_GFX)

        if hasRunGraphicsOptimizations and not RunService:IsStudio() then
            print("[GraphicsOpt] Graphics optimization already ran during the delay. Aborting duplicate run.")
            return
        end

        hasRunGraphicsOptimizations = true
        print("[GraphicsOpt] " .. INITIAL_WAIT_SECONDS_GFX .. "s wait complete. Applying EXTREME graphics optimizations...")

        -- 1. Core RenderSettings (NẾU CÓ)
        if settings_func_gfx and userSettings_func_gfx then
            print("[GraphicsOpt] Applying core RenderSettings and UserGameSettings...")
            pcall(function()
                local RenderSettings = settings_func_gfx():GetService("RenderSettings")
                local UserGameSettings = userSettings_func_gfx():GetService("UserGameSettings")
                RenderSettings.EagerBulkExecution = false
                RenderSettings.QualityLevel = Enum.QualityLevel.Level01
                RenderSettings.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
                UserGameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
                Workspace.InterpolationThrottling = Enum.InterpolationThrottlingMode.Enabled
            end)
        else
            print("[GraphicsOpt] `settings()` or `UserSettings()` not available for graphics. Skipping core RenderSettings.")
        end

        -- 2. Workspace - Cài đặt chung (graphics)
        pcall(function()
            Workspace.LevelOfDetail = Enum.ModelLevelOfDetail.Disabled
            if sethiddenproperty_gfx then
                pcall(sethiddenproperty_gfx, Workspace, "MeshPartHeads", Enum.MeshPartHeads.Disabled)
            end
        end)

        -- 3. Lighting và Môi trường (graphics)
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogColor = Color3.fromRGB(0, 0, 0)
            Lighting.FogStart = 0; Lighting.FogEnd = 0.01
            Lighting.Brightness = 0; Lighting.ClockTime = 0; Lighting.GeographicLatitude = 0
            Lighting.ExposureCompensation = -10
            Lighting.Ambient = Color3.fromRGB(0, 0, 0)
            Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
            Lighting.ShadowSoftness = 0
            if sethiddenproperty_gfx then pcall(sethiddenproperty_gfx, Lighting, "Technology", Enum.Technology.Compatibility)
            else Lighting.Technology = Enum.Technology.Compatibility end
            local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
            if atmosphere then Debris:AddItem(atmosphere, 0) end
            local skyInLighting = Lighting:FindFirstChildOfClass("Sky")
            if skyInLighting then Debris:AddItem(skyInLighting, 0) end
        end)

        -- 4. Âm thanh (graphics)
        pcall(function()
            SoundService.AmbientReverb = Enum.ReverbType.NoReverb
            local soundsToProcess = {}
            for _, d in ipairs(Workspace:GetDescendants()) do if d:IsA("Sound") then table.insert(soundsToProcess, d) end end
            for _, d in ipairs(SoundService:GetDescendants()) do if d:IsA("Sound") then table.insert(soundsToProcess, d) end end
            if LocalPlayer and LocalPlayer.PlayerGui then for _, d in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do if d:IsA("Sound") then table.insert(soundsToProcess, d) end end end
            for _, s in ipairs(soundsToProcess) do if s and s.Parent then s.Playing = false; s.Volume = 0 end end
        end)

        -- 5. GUI (graphics - KHÔNG XÓA GUI CỦA SERVER HOP)
        local playerGuiForGfx = LocalPlayer:WaitForChild("PlayerGui")
        if DESTROY_GUI_ELEMENTS_GFX then
            pcall(function()
                if playerGuiForGfx then
                    for _, gui in ipairs(playerGuiForGfx:GetChildren()) do
                        if gui.Name ~= "ServerHopStatusGUI" then Debris:AddItem(gui, 0)
                        else print("[GraphicsOpt] Preserving ServerHopStatusGUI.") end
                    end
                end
            end)
        else
            pcall(function()
                if playerGuiForGfx then
                    for _, gui in ipairs(playerGuiForGfx:GetChildren()) do
                        if gui:IsA("ScreenGui") and gui.Name ~= "ServerHopStatusGUI" then gui.Enabled = false
                        elseif gui.Name == "ServerHopStatusGUI" then print("[GraphicsOpt] Preserving ServerHopStatusGUI (visibility unchanged).") end
                    end
                end
            end)
        end
        
        -- 6. Địa hình (graphics)
        local terrain_gfx = Workspace:FindFirstChildOfClass("Terrain")
        if terrain_gfx then
            pcall(function()
                terrain_gfx.WaterWaveSize = 0; terrain_gfx.WaterWaveSpeed = 0; terrain_gfx.WaterReflectance = 0; terrain_gfx.WaterTransparency = 1
                if sethiddenproperty_gfx then pcall(sethiddenproperty_gfx, terrain_gfx, "Decoration", false)
                else terrain_gfx.Decoration = false end
            end)
        end

        -- 7. Workspace Objects (graphics)
        local playerCharacter_gfx = LocalPlayer.Character
        local itemsToProcess_gfx = Workspace:GetDescendants()
        for i, descendant_gfx in ipairs(itemsToProcess_gfx) do
            if not descendant_gfx or not descendant_gfx.Parent then continue end
            if descendant_gfx == playerCharacter_gfx or (playerCharacter_gfx and descendant_gfx:IsDescendantOf(playerCharacter_gfx)) then
                if MINIMIZE_PLAYER_CHARACTER_GFX and playerCharacter_gfx then
                    -- (Logic tối giản nhân vật giữ nguyên như script gốc của bạn)
                     pcall(function()
                        local humanoid = playerCharacter_gfx:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None; humanoid.HealthDisplayDistance = 0; humanoid.NameDisplayDistance = 0
                            humanoid.WalkSpeed = 0; humanoid.JumpPower = 0; humanoid.AutoRotate = false
                            if humanoid:GetState() ~= Enum.HumanoidStateType.Dead then humanoid:ChangeState(Enum.HumanoidStateType.Physics) end
                            local animator = humanoid:FindFirstChildOfClass("Animator")
                            if animator then for _, track in ipairs(animator:GetPlayingAnimationTracks()) do track:Stop(0.01); Debris:AddItem(track, 0.1) end end
                            for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do track:Stop(0.01); Debris:AddItem(track, 0.1) end
                        end
                        for _, charPart in ipairs(playerCharacter_gfx:GetDescendants()) do
                            if charPart:IsA("BasePart") then charPart.Transparency = 1; charPart.CanCollide = false; charPart.CastShadow = false; charPart.Anchored = true; charPart.Material = Enum.Material.Plastic end
                            if charPart:IsA("Decal") or charPart:IsA("Texture") then charPart.Transparency = 1 end
                            if charPart:IsA("Accessory") then Debris:AddItem(charPart, 0) end
                        end
                    end)
                end
            elseif descendant_gfx ~= Workspace.CurrentCamera and not descendant_gfx:IsA("Terrain") and not descendant_gfx:IsA("Script") and not descendant_gfx:IsA("LocalScript") and not descendant_gfx:IsA("Configuration") then
                local processed_gfx = false
                if descendant_gfx:IsA("Sky") then pcall(function() descendant_gfx.StarCount = 0; descendant_gfx.CelestialBodiesShown = false; Debris:AddItem(descendant_gfx,0.1) end); processed_gfx = true
                elseif descendant_gfx:IsA("Atmosphere") then pcall(function() Debris:AddItem(descendant_gfx, 0) end); processed_gfx = true
                elseif descendant_gfx:IsA("SurfaceAppearance") then pcall(function() Debris:AddItem(descendant_gfx, 0) end); processed_gfx = true
                elseif (descendant_gfx:IsA("ParticleEmitter") or descendant_gfx:IsA("Sparkles") or descendant_gfx:IsA("Smoke") or descendant_gfx:IsA("Trail") or descendant_gfx:IsA("Fire")) then pcall(function() descendant_gfx.Enabled = false; Debris:AddItem(descendant_gfx, 0.1) end); processed_gfx = true
                elseif (descendant_gfx:IsA("ColorCorrectionEffect") or descendant_gfx:IsA("DepthOfFieldEffect") or descendant_gfx:IsA("SunRaysEffect") or descendant_gfx:IsA("BloomEffect") or descendant_gfx:IsA("BlurEffect") or descendant_gfx:IsA("Light")) then pcall(function() descendant_gfx.Enabled = false; Debris:AddItem(descendant_gfx, 0.1) end); processed_gfx = true
                end
                if not processed_gfx then
                    if DESTROY_MOST_WORKSPACE_PARTS_GFX then Debris:AddItem(descendant_gfx, 0)
                    else
                        pcall(function()
                            if descendant_gfx:IsA("BasePart") then descendant_gfx.Transparency = 1; descendant_gfx.CastShadow = false; descendant_gfx.CanCollide = false; descendant_gfx.Anchored = true; descendant_gfx.Material = Enum.Material.Plastic
                            elseif descendant_gfx:IsA("Decal") or descendant_gfx:IsA("Texture") then descendant_gfx.Transparency = 1 end
                        end)
                    end
                end
            end
            if i % 200 == 0 then task.wait() end
        end

        -- 8. Camera (graphics)
        local cam_gfx = Workspace.CurrentCamera
        if cam_gfx then
            pcall(function()
                cam_gfx.FieldOfView = 1; cam_gfx.CameraType = Enum.CameraType.Scriptable
                local hrp_gfx = playerCharacter_gfx and playerCharacter_gfx:FindFirstChild("HumanoidRootPart")
                cam_gfx.CameraSubject = if hrp_gfx and hrp_gfx.Parent then hrp_gfx else cam_gfx
                cam_gfx.CFrame = CFrame.new(0, -300000, 0)
            end)
        end
        print("[GraphicsOpt] Graphics optimization applied.")

        -- GỌI SCRIPT SERVER HOP SAU KHI TỐI ƯU HÓA XONG
        if _G.StartServerHopLogic then
            print("[Integration] Calling Server Hop logic...")
            _G.StartServerHopLogic()
        else
            warn("[Integration] _G.StartServerHopLogic function not found! Server Hop script may not run.")
        end
    end

    local function initializeGraphicsOptimization()
        local startTime_gfx = tick()
        repeat task.wait() until (LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")) or tick() - startTime_gfx > 7
        runExtremeGraphicsOptimization()
    end

    -- Khởi chạy tối ưu hóa đồ họa ban đầu
    initializeGraphicsOptimization()

    -- Kết nối CharacterAdded cho tối ưu hóa đồ họa (chỉ chạy nếu chưa chạy trước đó)
    LocalPlayer.CharacterAdded:Connect(function(char_gfx)
        task.wait(1.5)
        if not hasRunGraphicsOptimizations then -- Quan trọng: chỉ chạy nếu tối ưu hóa đồ họa chưa bao giờ hoàn thành
            runExtremeGraphicsOptimization()
        end
    end)
    print("[GraphicsOpt] Graphics Optimization Script part loaded.")
end -- Kết thúc scope của Graphics Optimization

--------------------------------------------------------------------------------
-- PHẦN 2: SCRIPT SERVER HOP
--------------------------------------------------------------------------------
_G.StartServerHopLogic = function()
    print("[ServerHop] Initializing Server Hop Script part...")

    -- --- Cấu hình Script Server Hop ---
    local placeId_sh = game.PlaceId
    local currentJobId_sh = game.JobId

    local DEFAULT_WAIT_MINUTES_SH = 10
    local minPlayerPercentage_sh = 0.50
    local maxPlayerPercentageLimit_sh = 0.90
    local waitTimeBetweenFullScans_sh = 7
    local waitTimeBetweenPageFetches_sh = 0.75
    local baseRetryDelay_sh = 1
    local maxRetryDelay_sh = 16
    local SERVER_HISTORY_FILENAME_SH = "server_hop_history.txt"
    local FIXED_TEXT_SIZE_SH = 50

    -- --- Kiểm tra file access (Server Hop) ---
    local canAccessFiles_sh = false
    local writefile_func_sh, readfile_func_sh
    if writefile and readfile then
        canAccessFiles_sh = true
        writefile_func_sh = writefile
        readfile_func_sh = readfile
        print("[ServerHop] File access (writefile/readfile) detected. Server history enabled.")
    else
        print("[ServerHop] File access not detected. Will only avoid current server.")
    end

    -- --- UI Chính (Server Hop) ---
    local playerGui_sh = LocalPlayer:WaitForChild("PlayerGui")
    local statusScreenGui_sh = playerGui_sh:FindFirstChild("ServerHopStatusGUI")
    if statusScreenGui_sh then statusScreenGui_sh:Destroy() end

    statusScreenGui_sh = Instance.new("ScreenGui")
    statusScreenGui_sh.Name = "ServerHopStatusGUI"
    statusScreenGui_sh.ResetOnSpawn = false
    statusScreenGui_sh.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    statusScreenGui_sh.IgnoreGuiInset = true
    statusScreenGui_sh.Parent = playerGui_sh

    local statusTextLabel_sh = Instance.new("TextLabel")
    statusTextLabel_sh.Name = "StatusLabel"
    statusTextLabel_sh.Size = UDim2.new(0.9, 0, 0, FIXED_TEXT_SIZE_SH + 20)
    statusTextLabel_sh.Position = UDim2.new(0.5, 0, 0.5, 0)
    statusTextLabel_sh.AnchorPoint = Vector2.new(0.5, 0.5)
    statusTextLabel_sh.BackgroundTransparency = 1
    statusTextLabel_sh.TextColor3 = Color3.fromRGB(255, 87, 51)
    statusTextLabel_sh.Font = Enum.Font.SourceSansSemibold
    statusTextLabel_sh.TextScaled = false
    statusTextLabel_sh.TextSize = FIXED_TEXT_SIZE_SH
    statusTextLabel_sh.TextXAlignment = Enum.TextXAlignment.Center
    statusTextLabel_sh.TextYAlignment = Enum.TextYAlignment.Center
    statusTextLabel_sh.TextWrapped = false
    statusTextLabel_sh.Parent = statusScreenGui_sh
    statusTextLabel_sh.Text = "SH Init..."

    local function updateStatus_sh(message)
        print("[ServerHop] " .. message)
        if statusTextLabel_sh and statusTextLabel_sh.Parent then
            statusTextLabel_sh.Text = message
        end
    end

    -- --- Hàm xử lý file (Server Hop) ---
    local serverHistoryCache_sh = {}
    local function loadServerHistory_sh()
        local historySet = {}
        if canAccessFiles_sh then
            local success, content = pcall(readfile_func_sh, SERVER_HISTORY_FILENAME_SH)
            if success and content then
                local count = 0
                for line in string.gmatch(content, "[^" .. "\r\n" .. "]+") do
                    local trimmedLine = line:match("^%s*(.-)%s*$")
                    if trimmedLine and #trimmedLine > 0 then historySet[trimmedLine] = true; count = count + 1 end
                end
                if count > 0 then print("[ServerHop] Loaded history for " .. count .. " servers.")
                else print("[ServerHop] History file empty or no valid IDs.") end
            else
                if not success then print("[ServerHop] Error reading " .. SERVER_HISTORY_FILENAME_SH .. ": " .. tostring(content))
                else print("[ServerHop] History file " .. SERVER_HISTORY_FILENAME_SH .. " not found/empty.") end
            end
        end
        serverHistoryCache_sh = historySet
        return historySet
    end

    local function addJobIdToHistoryAndSave_sh(jobIdToAdd)
        if not jobIdToAdd or not canAccessFiles_sh then return end
        serverHistoryCache_sh[jobIdToAdd] = true
        local historyLines = {}
        for id in pairs(serverHistoryCache_sh) do table.insert(historyLines, id) end
        local contentToWrite = table.concat(historyLines, "\n")
        local success, err = pcall(writefile_func_sh, SERVER_HISTORY_FILENAME_SH, contentToWrite)
        if success then print("[ServerHop] Updated server history, added ID: " .. jobIdToAdd)
        else print("[ServerHop] Error saving history: " .. tostring(err)) end
    end

    -- --- Logic Tìm Server (Server Hop) ---
    local chosenServer_sh = nil
    local serversUrlBase_sh = "https://games.roblox.com/v1/games/" .. placeId_sh .. "/servers/Public?sortOrder=Asc&limit=100"
    local serverHistoryToAvoid_sh = loadServerHistory_sh()

    local function listServers_sh(cursor)
        local requestUrl = serversUrlBase_sh
        if cursor then requestUrl = requestUrl .. "&cursor=" .. cursor end
        local successCall, result = pcall(function() return game:HttpGet(requestUrl, true) end)
        if not successCall then return false, "HttpGet failed: " .. tostring(result) end
        local successDecode, decodedResult = pcall(function() return HttpService:JSONDecode(result) end)
        if not successDecode then return false, "JSONDecode failed: " .. tostring(decodedResult) end
        return true, decodedResult
    end

    local searchForServer_sh -- Khai báo trước để có thể gọi đệ quy
    searchForServer_sh = function()
        local historyCount = 0; for _ in pairs(serverHistoryToAvoid_sh) do historyCount = historyCount + 1 end
        updateStatus_sh(string.format("Tìm (%.0f%%-%.0f%%). Tránh %d srv.", minPlayerPercentage_sh * 100, maxPlayerPercentageLimit_sh * 100, historyCount + 1))
        local searchLoopActive = true; chosenServer_sh = nil
        while searchLoopActive and not chosenServer_sh do
            local currentNextCursorForFullScan = nil
            updateStatus_sh("Quét server...")
            local allPagesScannedForThisRound = false
            while not allPagesScannedForThisRound and not chosenServer_sh do
                local pageScanAttempts = 0; local maxPageScanAttempts = 4
                local pageSuccessfullyFetched = false; local currentRetryDelayPage = baseRetryDelay_sh
                while not pageSuccessfullyFetched and pageScanAttempts < maxPageScanAttempts do
                    pageScanAttempts = pageScanAttempts + 1
                    if pageScanAttempts > 1 then
                        updateStatus_sh(string.format("Thử lại trang (%d/%d). Chờ %.1fs...", pageScanAttempts, maxPageScanAttempts, currentRetryDelayPage))
                        task.wait(currentRetryDelayPage)
                        currentRetryDelayPage = math.min(currentRetryDelayPage * 2, maxRetryDelay_sh)
                    else updateStatus_sh("Lấy trang server...") end
                    local success, dataOrError = listServers_sh(currentNextCursorForFullScan)
                    if success then
                        pageSuccessfullyFetched = true; currentRetryDelayPage = baseRetryDelay_sh
                        local serverListData = dataOrError
                        if serverListData and serverListData.data then
                            local pageSuitableServers = {}
                            if #serverListData.data > 0 then
                                for _, serverInfo in ipairs(serverListData.data) do
                                    local serverId = serverInfo.id
                                    if not (serverId == currentJobId_sh) and not (serverHistoryToAvoid_sh[serverId] == true) then
                                        if serverInfo.playing and serverInfo.maxPlayers and serverInfo.maxPlayers > 0 then
                                            local playerRatio = serverInfo.playing / serverInfo.maxPlayers
                                            if playerRatio >= minPlayerPercentage_sh and playerRatio < maxPlayerPercentageLimit_sh and serverInfo.playing < serverInfo.maxPlayers then
                                                table.insert(pageSuitableServers, serverInfo)
                                            end
                                        end
                                    end
                                end
                                if #pageSuitableServers > 0 then
                                    updateStatus_sh("Thấy " .. #pageSuitableServers .. " server tốt!")
                                    chosenServer_sh = pageSuitableServers[math.random(1, #pageSuitableServers)]
                                    allPagesScannedForThisRound = true; break
                                end
                            end
                            if not chosenServer_sh then
                                currentNextCursorForFullScan = serverListData.nextPageCursor
                                if not currentNextCursorForFullScan then allPagesScannedForThisRound = true; updateStatus_sh("Hết server để quét.") end
                            end
                        else
                            updateStatus_sh("Dữ liệu server không hợp lệ.")
                            currentNextCursorForFullScan = serverListData and serverListData.nextPageCursor
                            if not currentNextCursorForFullScan then allPagesScannedForThisRound = true end
                        end
                    else
                        local errorMessage = dataOrError
                        updateStatus_sh("Lỗi API: " .. string.sub(tostring(errorMessage), 1, 30)) -- Rút gọn
                        if pageScanAttempts >= maxPageScanAttempts then updateStatus_sh("Lỗi lấy trang. Bỏ qua."); allPagesScannedForThisRound = true end
                    end
                end
                if chosenServer_sh or allPagesScannedForThisRound then break end
                if pageSuccessfullyFetched and not allPagesScannedForThisRound and not chosenServer_sh then task.wait(waitTimeBetweenPageFetches_sh) end
            end
            if chosenServer_sh then
                updateStatus_sh(string.format("CHỌN SRV! ID: %s (%d/%d)", string.sub(tostring(chosenServer_sh.id), 1, 8), chosenServer_sh.playing, chosenServer_sh.maxPlayers))
                searchLoopActive = false
            elseif allPagesScannedForThisRound then
                updateStatus_sh(string.format("Không tìm thấy. Chờ %ds quét lại...", waitTimeBetweenFullScans_sh))
                task.wait(waitTimeBetweenFullScans_sh)
            end
            if not searchLoopActive then break end
        end
        if chosenServer_sh then
            updateStatus_sh("Dịch chuyển...")
            addJobIdToHistoryAndSave_sh(currentJobId_sh) -- Thêm server HIỆN TẠI vào lịch sử trước khi rời đi
            task.wait(2)
            local success_tp, err_tp = pcall(function()
                TeleportService:TeleportToPlaceInstance(placeId_sh, chosenServer_sh.id, LocalPlayer)
            end)
            if not success_tp then
                updateStatus_sh("Dịch chuyển lỗi: " .. string.sub(tostring(err_tp), 1, 30))
                chosenServer_sh = nil; task.wait(5); searchForServer_sh() -- Gọi lại chính nó
            end
        else updateStatus_sh("Không tìm thấy server. Dừng.") end
    end

    local countdownShouldReset_sh = false
    local currentCountdownThread_sh = nil
    local performCountdownThenSearch_sh -- Khai báo trước
    performCountdownThenSearch_sh = function(minutesToWait)
        if not minutesToWait or minutesToWait <= 0 then
            updateStatus_sh("Thời gian chờ lỗi. Tìm ngay..."); searchForServer_sh(); return
        end
        local totalWaitSeconds = minutesToWait * 60
        print(string.format("[ServerHop] Bắt đầu tìm server sau: %d phút %d giây...", math.floor(totalWaitSeconds / 60), totalWaitSeconds % 60))
        for i = totalWaitSeconds, 0, -1 do
            if countdownShouldReset_sh then
                countdownShouldReset_sh = false; updateStatus_sh("Donate! Reset đếm ngược.")
                performCountdownThenSearch_sh(DEFAULT_WAIT_MINUTES_SH); return
            end
            if statusTextLabel_sh and statusTextLabel_sh.Parent then
                statusTextLabel_sh.Text = string.format("%02d:%02d", math.floor(i / 60), i % 60)
            end
            task.wait(1)
        end
        updateStatus_sh("Hết giờ! Tìm server..."); searchForServer_sh()
    end

    local function startInitialCountdown_sh()
        if currentCountdownThread_sh and coroutine.status(currentCountdownThread_sh) ~= "dead" then
            coroutine.close(currentCountdownThread_sh)
        end
        currentCountdownThread_sh = coroutine.create(function() performCountdownThenSearch_sh(DEFAULT_WAIT_MINUTES_SH) end)
        coroutine.resume(currentCountdownThread_sh)
    end

    -- --- Xử lý sự kiện Donate (Server Hop) ---
    local leaderstats = LocalPlayer:WaitForChild("leaderstats", 60) -- Chờ leaderstats tối đa 60s
    if leaderstats then
        local raisedValueObject = leaderstats:WaitForChild("Raised", 60) -- Chờ Raised tối đa 60s
        if raisedValueObject then
            local lastRaisedValue_sh = raisedValueObject.Value
            raisedValueObject.Changed:Connect(function(newRaisedAmount)
                if newRaisedAmount > lastRaisedValue_sh then
                    updateStatus_sh(string.format("Donate! Raised: %s -> %s", tostring(lastRaisedValue_sh), tostring(newRaisedAmount)))
                    lastRaisedValue_sh = newRaisedAmount
                    countdownShouldReset_sh = true
                end
            end)
        else
            warn("[ServerHop] Không tìm thấy 'Raised' trong leaderstats sau 60 giây.")
        end
    else
        warn("[ServerHop] Không tìm thấy 'leaderstats' của người chơi sau 60 giây.")
    end

    -- --- Khởi chạy Script Server Hop ---
    updateStatus_sh("SH Đang chạy...")
    task.wait(1)
    print("[ServerHop] Thời gian chờ mặc định (SH): " .. DEFAULT_WAIT_MINUTES_SH .. " phút.")
    startInitialCountdown_sh()
    print("[ServerHop] Server Hop Script part loaded and running.")
end -- Kết thúc _G.StartServerHopLogic

print("[Integration] Main script body finished. Graphics optimization will run, then trigger server hop.")
