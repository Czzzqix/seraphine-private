local seraphine = {}
seraphine.camlock = loadstring(game:HttpGet("https://raw.githubusercontent.com/Czzzqix/seraphine-private/refs/heads/main/modules/camlock.luau"))()

--===Basic Cam Settings=====================
seraphine.camlock.settings.Enabled = true -- enable camlock
seraphine.camlock.settings.Keybind = Enum.UserInputType.MouseButton2 -- camlock keybind
seraphine.camlock.settings.Mode = "Toggle" -- "Hold" or "Toggle"
seraphine.camlock.settings.Prediction = 0.14 -- velocity prediction
--===FOV Settings===========================
seraphine.camlock.settings.FOV = 150 -- FOV circle radius
seraphine.camlock.settings.ShowFOV = true -- master FOV toggle
seraphine.camlock.settings.FOVColor = Color3.fromRGB(0, 255, 0) -- FOV circle color
seraphine.camlock.settings.FOVFilled = true -- fill the fov circle
seraphine.camlock.settings.FOVOutline = true -- Fov Outline
seraphine.camlock.settings.FOVOpacity = 1.0 -- 80% opacity (outline = this, fill = this - 0.2)
--==========================================

for k,v in pairs(seraphine.camlock.settings) do
    print(k, v)
end
