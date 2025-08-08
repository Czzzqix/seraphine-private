--// seraphine.camlock
local camlock = {}
-- Default Settings (everything OFF)
camlock.settings = {
    Enabled = false, -- master switch
    Keybind = Enum.UserInputType.MouseButton2, -- camlock keybind
    Mode = "Hold", -- "Hold" or "Toggle"
    FOV = 100, -- FOV circle radius
    Smoothness = 0.15, -- camera smoothing
    Prediction = 0.12, -- velocity prediction
    TargetPart = "Head", -- body part to target
    ShowFOV = false, -- FOV circle visibility (master toggle)
    FOVFilled = true, -- show fill circle
    FOVOutline = true, -- show outline circle
    FOVOpacity = 1, -- base opacity (outline = this, fill = this - 0.2)
    FOVColor = Color3.fromRGB(255, 0, 0) -- FOV circle color
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
local FOVCircleFill = Drawing.new("Circle")
FOVCircleFill.Thickness = 1
FOVCircleFill.NumSides = 50
FOVCircleFill.Filled = true
FOVCircleFill.Visible = false

local FOVCircleOutline = Drawing.new("Circle")
FOVCircleOutline.Thickness = 2
FOVCircleOutline.NumSides = 50
FOVCircleOutline.Filled = false
FOVCircleOutline.Visible = false
-- Get Closest Player
local function GetClosestPlayer()
    local closest, distance = nil, camlock.settings.FOV
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(camlock.settings.TargetPart) then
            local pos, onScreen = Camera:WorldToViewportPoint(plr.Character[camlock.settings.TargetPart].Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
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
    -- Update FOV circles
    local mousePos = UserInputService:GetMouseLocation()
    local showFOV = camlock.settings.ShowFOV
    local outlineOpacity = camlock.settings.FOVOpacity
    local fillOpacity = math.max(0, outlineOpacity - 0.2)
    
    -- Outline circle (draw first, behind fill)
    FOVCircleOutline.Visible = showFOV and camlock.settings.FOVOutline
    FOVCircleOutline.Position = mousePos
    FOVCircleOutline.Radius = camlock.settings.FOV
    FOVCircleOutline.Color = camlock.settings.FOVColor
    FOVCircleOutline.Transparency = 1 - outlineOpacity
    
    -- Fill circle (draw second, on top)
    FOVCircleFill.Visible = showFOV and camlock.settings.FOVFilled
    FOVCircleFill.Position = mousePos
    FOVCircleFill.Radius = camlock.settings.FOV
    FOVCircleFill.Color = camlock.settings.FOVColor
    FOVCircleFill.Transparency = 1 - fillOpacity
    
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
