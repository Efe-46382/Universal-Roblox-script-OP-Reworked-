--Universal Script Reworked
--Made by: RobloxPlayer31is

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Universal Hub", "Ocean")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local NoRagdoll = false
local connection


local SpeedValue = 16
local JumpValue = 50
local InfiniteJumpEnabled = false
local flying = false
local flySpeed = 50
local mover, att, heartbeatConnection
local espEnabled = false


local Tab = Window:NewTab("Local Player")
local Section = Tab:NewSection("Player")
local Tab2 = Window:NewTab("Main")
local Section2 = Tab2:NewSection("Main")
local ESPSection = Tab2:NewSection("Visuals")


task.spawn(function()
    while task.wait() do
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = SpeedValue
                LocalPlayer.Character.Humanoid.JumpPower = JumpValue
            end
        end)
    end
end)


Section:NewSlider("Speed changer", "Changes your speed", 500, 16, function(s)
    SpeedValue = s
end)

Section:NewSlider("Jump power", "Changes your jump power", 300, 50, function(j)
    JumpValue = j
end)

Section:NewButton("Reset walkspeed and jump power", "Resets your walkspeed and jump power to default", function()
    SpeedValue = 16
    JumpValue = 50
end)

Section:NewToggle("Infinite Jump", "Jump as many times as you want", function(state)
    InfiniteJumpEnabled = state
end)

UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local character = LocalPlayer.Character
        local hum = character and character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

Section2:NewButton("Toggle Fly", "Enables/Disables flight", function()
    local camera = workspace.CurrentCamera
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local root = char.HumanoidRootPart
    local hum = char:FindFirstChild("Humanoid")
    
    flying = not flying
    
    if flying then
        hum:ChangeState(Enum.HumanoidStateType.Physics)
        att = Instance.new("Attachment", root)
        mover = Instance.new("LinearVelocity", root)
        mover.Attachment0 = att
        mover.MaxForce = math.huge
        mover.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
        
        heartbeatConnection = RunService.Heartbeat:Connect(function()
            local dir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= camera.CFrame.RightVector end
            
            if mover and mover.Parent then
                mover.VectorVelocity = (dir.Magnitude > 0) and (dir.Unit * flySpeed) or Vector3.zero
            end
            local camLook = camera.CFrame.LookVector
            root.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(camLook.X, 0, camLook.Z))
        end)
    else
        if heartbeatConnection then heartbeatConnection:Disconnect() end
        if mover then mover:Destroy() end
        if att then att:Destroy() end
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end)

Section2:NewTextBox("Fly Speed", "Set speed (Default 50)", function(txt)
    flySpeed = tonumber(txt) or 50
end)

Section2:NewToggle("Noclip", "Makes your character Noclip", function(state)
                _G.noclip = state
    
    task.spawn(function()
        while _G.noclip do
            local char = LocalPlayer.Character
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
            task.wait()
        end
        
        if LocalPlayer.Character then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                game.Players.LocalPlayer.Character.Humanoid.JumpPower = 1
                game.Players.LocalPlayer.Character.Humanoid.Jump = true
                end
            end
        end
    end)
end)

Section2:NewButton("Reset your character", "Resets your character", function()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
        else
            character:BreakJoints()
        end
    end
end)

Section2:NewToggle("Anti ragdoll", "prevents you from being ragdolled", function(state)
    NoRagdoll = state

    local function disableRagdoll(character)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not NoRagdoll)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not NoRagdoll)
        end
    end

    if NoRagdoll then
        if LocalPlayer.Character then
            disableRagdoll(LocalPlayer.Character)
        end
        connection = LocalPlayer.CharacterAdded:Connect(disableRagdoll)
    else
        if connection then
            connection:Disconnect()
            connection = nil
        end
        if LocalPlayer.Character then
            disableRagdoll(LocalPlayer.Character)
        end
    end
end)


local function ApplyESP(plr)
    local function createHighlight(char)
        if not char:FindFirstChild("ESP_Highlight") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESP_Highlight"
            highlight.Adornee = char
            highlight.FillTransparency = 0.5
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.Parent = char
        end
    end

    plr.CharacterAdded:Connect(function(char)
        if espEnabled then
            task.wait(0.5)
            createHighlight(char)
        end
    end)
    
    if plr.Character and espEnabled then
        createHighlight(plr.Character)
    end
end

ESPSection:NewToggle("Player ESP", "Highlights all players", function(state)
    espEnabled = state
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if espEnabled then
                ApplyESP(plr)
            else
                local h = plr.Character:FindFirstChild("ESP_Highlight")
                if h then h:Destroy() end
            end
        end
    end
end)

Players.PlayerAdded:Connect(ApplyESP)

local Tab3 = Window:NewTab("Misc")
local Section3 = Tab3:NewSection("Misc")

Section3:NewButton("Spawn Brick", "Client Sided", function()
    local Part = Instance.new("Part", workspace)
    Part.Position = LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
end)

Section3:NewButton("Click teleport tool", "Gives you the click teleport tool", function()
    local player = game:GetService("Players").LocalPlayer
    
    local tpTool = Instance.new("Tool")
    tpTool.Name = "Click TP"
    tpTool.RequiresHandle = false
    tpTool.Parent = player.Backpack
    
    tpTool.Activated:Connect(function()
        local mouse = player:GetMouse()
        local pos = mouse.Hit.Position
        
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        end
    end)
end)

local Tab4 = Window:NewTab("Credits")
local CreditsSection = Tab4:NewSection("Credits Info")

CreditsSection:NewLabel("Script made by RobloxPlayer31is")
CreditsSection:NewLabel("Kavo UI made by xHeptc")
--More coming soon