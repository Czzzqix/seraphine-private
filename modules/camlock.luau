--// seraphine.camlock
local camlock = {}

-- Default Settings (everything OFF)
camlock.settings = {
    Enabled = false, -- master switch
    Keybind = Enum.UserInputType.MouseButton2, -- default hold RMB
    Mode = "Hold", -- "Hold" or "Toggle"
    FOV = 100,
    Smoothness = 0.15,
    Prediction = 0.12,
    TargetPart = "Head",
    ShowFOV = false, -- FOV circle visibility
    FOVColor = Color3.fromRGB(255, 0, 0)
}

-- Internal
local Players = cloneref(game:GetService("Players"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local LockedTarget = nil
local Holding = false
local ToggleState = false

-- FOV Drawing
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 50
FOVCircle.Filled = false
FOVCircle.Visible = false -- start hidden

-- Get Closest Player
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

-- Input Handling
UserInputService.InputBegan:Connect(function(input)
    if not camlock.settings.Enabled then return end
    if input.UserInputType == camlock.settings.Keybind then
        if camlock.settings.Mode == "Hold" then
            Holding = true
            LockedTarget = GetClosestPlayer()
        elseif camlock.settings.Mode == "Toggle" then
            ToggleState = not ToggleState
            LockedTarget = ToggleState and GetClosestPlayer() or nil
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if not camlock.settings.Enabled then return end
    if camlock.settings.Mode == "Hold" and input.UserInputType == camlock.settings.Keybind then
        Holding = false
        LockedTarget = nil
    end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    -- Update FOV circle
    FOVCircle.Visible = camlock.settings.ShowFOV
    FOVCircle.Position = Vector2.new(math.floor(Mouse.X), math.floor(Mouse.Y))
    FOVCircle.Radius = camlock.settings.FOV
    FOVCircle.Color = camlock.settings.FOVColor

    if not camlock.settings.Enabled then return end

    local active = (camlock.settings.Mode == "Hold" and Holding) or (camlock.settings.Mode == "Toggle" and ToggleState)
    if active and LockedTarget and LockedTarget.Character and LockedTarget.Character:FindFirstChild(camlock.settings.TargetPart) then
        local part = LockedTarget.Character[camlock.settings.TargetPart]
        local predicted = part.Position + (part.Velocity * camlock.settings.Prediction)
        local newCF = CFrame.new(Camera.CFrame.Position, predicted)
        Camera.CFrame = Camera.CFrame:Lerp(newCF, camlock.settings.Smoothness)
    end
end)

return camlock
