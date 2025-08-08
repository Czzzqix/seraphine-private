--// seraphine.camlock
local camlock = {}

-- Default Settings (everything OFF)
camlock.settings = {
    Enabled = false,      -- Master switch
    Keybind = Enum.UserInputType.MouseButton2, -- Default hold RMB
    Mode = "Hold",        -- "Hold" or "Toggle"
    FOV = 100,            -- Radius of the FOV circle in pixels
    Smoothness = 0.15,    -- Camera interpolation speed (lower is smoother)
    Prediction = 0.12,    -- How far to predict target movement
    TargetPart = "Head",  -- Part to aim at (e.g., "Head", "HumanoidRootPart")
    ShowFOV = false,      -- FOV circle visibility
    FOVColor = Color3.fromRGB(255, 0, 0) -- Color of the FOV circle
}

-- Roblox Services & Core Variables
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Internal State
local LockedTarget = nil
local Holding = false
local ToggleState = false

-- FOV Drawing (Circle centered on the screen)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64 -- Increased for a smoother circle
FOVCircle.Filled = false
FOVCircle.Visible = false -- Start hidden

-- Function to find the closest player within the screen-centered FOV
local function GetClosestPlayer()
    local closestPlayer, minDistance = nil, camlock.settings.FOV
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(camlock.settings.TargetPart) then
            local targetPart = player.Character[camlock.settings.TargetPart]
            local position, onScreen = Camera:WorldToViewportPoint(targetPart.Position)

            if onScreen then
                -- Calculate distance from the center of the screen, not the mouse
                local distance = (Vector2.new(position.X, position.Y) - screenCenter).Magnitude
                if distance < minDistance then
                    minDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

-- Input Handling for activating the camlock
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent or not camlock.settings.Enabled then return end

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

-- Main loop executed every frame
RunService.RenderStepped:Connect(function()
    -- Update FOV circle properties
    if camlock.settings.ShowFOV then
        FOVCircle.Visible = true
        -- NEW: Center the circle on the screen viewport
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius = camlock.settings.FOV
        FOVCircle.Color = camlock.settings.FOVColor
    else
        FOVCircle.Visible = false
    end

    if not camlock.settings.Enabled then return end

    -- Determine if the camlock should be active
    local isActive = (camlock.settings.Mode == "Hold" and Holding) or (camlock.settings.Mode == "Toggle" and ToggleState)

    -- If active, update the camera to track the target
    if isActive and LockedTarget and LockedTarget.Character and LockedTarget.Character:FindFirstChild(camlock.settings.TargetPart) then
        local targetPart = LockedTarget.Character[camlock.settings.TargetPart]
        
        -- Check if target is still valid (e.g., not dead or out of range)
        local _, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then
            LockedTarget = nil -- Lose target if they go off-screen
            return
        end

        -- Predict target's next position based on velocity
        local predictedPosition = targetPart.Position + (targetPart.Velocity * camlock.settings.Prediction)
        
        -- Smoothly interpolate the camera's CFrame to look at the predicted position
        local newCFrame = CFrame.new(Camera.CFrame.Position, predictedPosition)
        Camera.CFrame = Camera.CFrame:Lerp(newCFrame, camlock.settings.Smoothness)
    else
        -- If we are in toggle mode and lose the target, turn toggle off
        if camlock.settings.Mode == "Toggle" and ToggleState then
            ToggleState = false
        end
        LockedTarget = nil
    end
end)

return camlock
