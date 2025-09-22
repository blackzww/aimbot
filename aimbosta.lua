--[[
Aimbot GUI (Verde/Desligado, Vermelho/Ligado)
Trava a câmera só no humanoid MAIS PERTO do seu jogador, ignorando distantes.
Funciona PC/mobile.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AimbotLockGui"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 120, 0, 40)
btn.Position = UDim2.new(0, 20, 0, 100)
btn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
btn.Text = "Aimbot: OFF"
btn.Font = Enum.Font.SourceSansBold
btn.TextSize = 24
btn.TextColor3 = Color3.new(1,1,1)
btn.Parent = gui

local aimbotOn = false
local conn = nil

-- Config: só mira se estiver bem perto (ex: até 25 studs)
local DIST_LIMIT = 100

-- Função para pegar humanoid mais próximo dentro do limite
local function getClosest()
    local minDist = DIST_LIMIT
    local closestChar = nil
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local dist = (myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closestChar = p.Character
            end
        end
    end
    return closestChar
end

-- Função de travar câmera
local function lockCamera()
    local myChar = LocalPlayer.Character
    local myHead = myChar and myChar:FindFirstChild("Head")
    local closest = getClosest()
    if closest and myHead then
        local targetPos = closest.HumanoidRootPart.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
    end
end

-- Ativa/Desativa Aimbot
local function toggleAimbot(state)
    aimbotOn = state
    if aimbotOn then
        btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        btn.Text = "Aimbot: ON"
        conn = RunService.RenderStepped:Connect(lockCamera)
    else
        btn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        btn.Text = "Aimbot: OFF"
        if conn then conn:Disconnect() conn = nil end
    end
end

btn.MouseButton1Click:Connect(function()
    toggleAimbot(not aimbotOn)
end)

-- Mobile: arrastar botão opcional
local dragging, dragInput, dragStart, startPos
btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = btn.Position
    end
end)
btn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
btn.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        btn.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
    end
end)