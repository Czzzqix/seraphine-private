--// seraphine.camlock (Basic Version)
-- Save this as "camlock.luau"

local camlock = {}

-- Settings
camlock.settings = {
    Enabled = true,
    Keybind = Enum.UserInputType.MouseButton2, -- Hold RMB
    FOV = 100,
    Smoothness = 0.15,
    Prediction = 0.12,
    TargetPart = "Head",
    FOVColor = Color3.fromRGB(255, 0, 0)
}

-- Internal Services
local Players = cloneref(game:GetService("Players"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Vars
local LockedTarget = nil
local Holding = false

-- FOV Drawing
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 50
FOVCircle.Radius = camlock.settings.FOV
FOVCircle.Filled = false
FOVCircle.Color = camlock.settings.FOVColor
FOVCircle.Visible = true

-- Get closest player in FOV
local function GetClosestPlayer()
    local closest, distance = nil, camlock.settings.FOV
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(camlock.settings.TargetPart) then
            local pos, onScreen = Camera:WorldToViewportPoint(plr.Character[camlock.settings.TargetPart].Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mag < distance then
                    distance = mag
                    closest = plr
                end
            end
        end
    end
    return closest
end

-- Input Events
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == camlock.settings.Keybind then
        Holding = true
        LockedTarget = GetClosestPlayer()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == camlock.settings.Keybind then
        Holding = false
        LockedTarget = nil
    end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    -- Update FOV circle
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    FOVCircle.Radius = camlock.settings.FOV
    FOVCircle.Color = camlock.settings.FOVColor

    if camlock.settings.Enabled and Holding and LockedTarget and LockedTarget.Character and LockedTarget.Character:FindFirstChild(camlock.settings.TargetPart) then
        local targetPos = LockedTarget.Character[camlock.settings.TargetPart].Position +
            (LockedTarget.Character[camlock.settings.TargetPart].Velocity * camlock.settings.Prediction)

        local newCF = CFrame.new(Camera.CFrame.Position, targetPos)
        Camera.CFrame = Camera.CFrame:Lerp(newCF, camlock.settings.Smoothness)
    end
end)

return camlock
