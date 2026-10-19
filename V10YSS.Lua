-- YSS HUB | STEAL AN EGG UPDATE 10 (ProxyLib UI)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local PICK = Vector3.new(599.43, 70.57, -327.18)
local HOME = Vector3.new(545.74, 70.57, -352.17)
local ZONES = {
    ["1. Cosmic"]         = Vector3.new(3394.70, 70.57, -324.96),
    ["2. Kitsune"]        = Vector3.new(4026.14, 70.57, -396.96),
    ["3. Gorila King"]    = Vector3.new(4798.19, 70.57, -328.09),
    ["4. Demon&Angel"]    = Vector3.new(5662.82, 70.57, -327.71),
    ["5. Lion Enchanted"] = Vector3.new(6697.20, 70.57, -349.84),
}
local NAMES = { "1. Cosmic", "2. Kitsune", "3. Gorila King", "4. Demon&Angel", "5. Lion Enchanted" }
local UP, STEP, DELAY, BUMP = 50, 75, 0.04, 10
local zone, grabMs, running = NAMES[1], 500, false

local function parts()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart"), c and c:FindFirstChildOfClass("Humanoid")
end

local function put(hrp, pos)
    hrp.CFrame = CFrame.new(pos)
    hrp.AssemblyLinearVelocity = Vector3.zero
end

-- block tak terlihat di bawah kaki + matikan semua animasi karakter
local plat, conn
local function startFx()
    if conn then return end
    plat = Instance.new("Part")
    plat.Size = Vector3.new(8, 1, 8)
    plat.Anchored = true
    plat.Transparency = 1
    plat.Parent = workspace
    conn = RunService.Heartbeat:Connect(function()
        local hrp, hum = parts()
        if not hrp then return end
        local feet = (hum and hum.RigType == Enum.HumanoidRigType.R6) and 3 or ((hum and hum.HipHeight or 2) + hrp.Size.Y / 2)
        plat.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - feet - 0.5, hrp.Position.Z)
        if hum then
            for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop(0) end
        end
        local a = LocalPlayer.Character:FindFirstChild("Animate")
        if a then a.Disabled = true end
    end)
end

local function stopFx()
    if conn then conn:Disconnect() conn = nil end
    if plat then plat:Destroy() plat = nil end
    local a = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Animate")
    if a then a.Disabled = false end
end

-- ambil egg: tembak sampai 2 ProximityPrompt dalam radius 100 studs
local function grab(sec)
    local hrp = parts()
    if not hrp then return end
    local list = {}
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            local p = d.Parent
            local part = p and (p:IsA("BasePart") and p or p:FindFirstChildWhichIsA("BasePart"))
            if part and (part.Position - hrp.Position).Magnitude <= 100 then
                table.insert(list, d)
            end
        end
    end
    local t = tick()
    repeat
        for i = 1, math.min(2, #list) do
            task.spawn(pcall, fireproximityprompt, list[i])
        end
        task.wait(0.05)
    until not running or tick() - t >= sec
end

local function walk(pos)
    while running do
        local hrp, hum = parts()
        if not hrp or not hum then return end
        if Vector3.new(pos.X - hrp.Position.X, 0, pos.Z - hrp.Position.Z).Magnitude < 4 then return end
        hum:MoveTo(Vector3.new(pos.X, hrp.Position.Y, pos.Z))
        task.wait(0.2)
    end
end

local function cycle()
    local hrp = parts()
    if not hrp then return end
    local target = ZONES[zone]
    startFx()

    walk(PICK)                                    -- jalan ke titik ambil
    grab(grabMs / 1000)                           -- ambil egg
    if running then task.wait(2) end              -- tunggu 2 detik
    hrp = parts()
    if running and hrp then put(hrp, hrp.Position + Vector3.new(0, UP, 0)) end  -- TP naik 50
    walk(target)                                  -- jalan ke zone di atas block
    hrp = parts()
    if running and hrp then put(hrp, target) end  -- turun ke zone
    grab(grabMs / 1000)                           -- ambil egg

    hrp = parts()
    if running and hrp then                       -- TP 35 studs tiap 40 ms ke Home, tiap TP naik 10
        local a = hrp.Position
        local d = Vector3.new(HOME.X - a.X, 0, HOME.Z - a.Z)
        local dir, total, moved = d.Unit, d.Magnitude, 0
        while running and moved < total do
            moved = math.min(moved + STEP, total)
            local h = parts()
            if not h then break end
            put(h, Vector3.new(a.X, a.Y + BUMP, a.Z) + dir * moved)
            task.wait(DELAY)
        end
        local h = parts()
        if running and h then put(h, HOME) end
    end
    stopFx()
end

-- ===== UI =====
local ProxyLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProxyHubDev/ProxyLib/refs/heads/main/Documents/ProxyLibrary"))()
local Lib = ProxyLib.new()

local KS = Lib:CreateKeySystem({
    Title = "Authentication",
    Theme = "Blue",
})

KS:CreateSocialButton({ Type = "Discord", Link = "https://discord.gg/fqwtc8byFY", Order = 1 })

KS:CreateButton({
    Description = "Verify",
    Callback    = function()
        if KS:GetText() == "UPDATE-10" then
            KS:Destroy()

            local Window = Lib:CreateWindow({
                Title    = "YSS Hub",
                Subtitle = "Steal An Egg Update 10",
                Theme    = "Blue",
                Size     = Vector2.new(560, 420),
                ConfigPanel = {
                    Enabled = true,
                    Theme   = true,
                    Fps     = true,
                    Ping    = true,
                    Profile = true,
                },
                TitleConfig = {
                    Gradient = true,
                    Words    = {
                        "YSS",
                        { Text = "Hub", Colors = { Color3.fromRGB(150,80,255), Color3.fromRGB(50,220,100) } },
                    },
                },
            })

            Window:CreateSeparator({ Text = "MENUS" })
            local Tab = Window:CreateTab({ Title = "Steal Egg 🥚", Icon = "rbxassetid://105255307277742" })

            Tab:CreateSection({ Text = "Steal Egg" })

            local okDrop = pcall(function()
                Tab:CreateDropdown({
                    Title    = "Zone",
                    Options  = NAMES,
                    Default  = NAMES[1],
                    Callback = function(v) zone = type(v) == "table" and v[1] or v end,
                })
            end)
            if not okDrop then
                -- cadangan: tombol ganti zone bergantian
                local idx = 1
                Tab:CreateButton({
                    Description = "Ganti Zone",
                    Callback = function()
                        idx = idx % #NAMES + 1
                        zone = NAMES[idx]
                        Window:Notify({ Title = "Zone", Description = zone, Duration = 2 })
                    end,
                })
            end

            Tab:CreateSlider({
                Title    = "Grab Time (ms)",
                Min      = 100,
                Max      = 1500,
                Default  = grabMs,
                Callback = function(v) grabMs = v end,
            })

            Tab:CreateToggle({
                Title    = "Auto Egg",
                Default  = false,
                Callback = function(v)
                    running = v
                    if v then
                        task.spawn(function()
                            while running do
                                pcall(cycle)
                                stopFx()
                                task.wait(0.5)
                            end
                        end)
                    else
                        stopFx()
                    end
                end,
            })

            Tab:CreateButton({
                Description = "TP Home",
                Callback    = function()
                    local hrp = parts()
                    if hrp then put(hrp, HOME) end
                end,
            })

            Window:Notify({
                Title       = "Welcome!",
                Description = "YSS Hub berhasil dimuat.",
                Duration    = 4,
            })
        else
            KS:Notify({ Title = "Invalid key!", Duration = 3 })
        end
    end,
})
