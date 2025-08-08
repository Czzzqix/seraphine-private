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
seraphine.camlock.settings.FOVFilled = true -- show fill circle
seraphine.camlock.settings.FOVOutline = true -- hide outline (just filled)
seraphine.camlock.settings.FOVOpacity = 0.8 -- 80% opacity (outline = this, fill = this - 0.2)
--==========================================
