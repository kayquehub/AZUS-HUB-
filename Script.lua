local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local TabHolder = Instance.new("Frame")
local ContentHolder = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local MinimizeBtn = Instance.new("TextButton")
local ZIcon = Instance.new("TextButton") 

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "AzusHub_Final"

-- 1. ÍCONE "Z"
ZIcon.Name = "ZIcon"
ZIcon.Parent = ScreenGui
ZIcon.Position = UDim2.new(0.05, 0, 0.1, 0)
ZIcon.Size = UDim2.new(0, 60, 0, 60)
ZIcon.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ZIcon.Text = "Z"
ZIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
ZIcon.TextSize = 40
ZIcon.Font = Enum.Font.GothamBold
ZIcon.Draggable = true
Instance.new("UICorner", ZIcon).CornerRadius = UDim.new(0, 15)
local ZStroke = Instance.new("UIStroke", ZIcon)
ZStroke.Thickness = 3
ZStroke.Color = Color3.fromRGB(255, 255, 0)

-- 2. MENU PRINCIPAL
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainFrame.BackgroundTransparency = 0.2
MainFrame.Position = UDim2.new(0.2, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 650, 0, 350)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 5)
TopBar.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
Instance.new("UICorner", TopBar)

Title.Parent = MainFrame
Title.Text = "AZUS HUB"
Title.Position = UDim2.new(0, 20, 0, 15)
Title.Size = UDim2.new(0, 300, 0, 30)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

MinimizeBtn.Parent = MainFrame
MinimizeBtn.Text = "-"
MinimizeBtn.Position = UDim2.new(0.93, 0, 0.02, 0)
MinimizeBtn.Size = UDim2.new(0, 35, 0, 35)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 40

-- 3. ABAS
TabHolder = Instance.new("Frame", MainFrame)
TabHolder.Position = UDim2.new(0, 15, 0, 70)
TabHolder.Size = UDim2.new(0, 140, 1, -85)
TabHolder.BackgroundTransparency = 1
Instance.new("UIListLayout", TabHolder).Padding = UDim.new(0, 10)

ContentHolder = Instance.new("Frame", MainFrame)
ContentHolder.Position = UDim2.new(0, 165, 0, 70)
ContentHolder.Size = UDim2.new(1, -180, 1, -85)
ContentHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ContentHolder.BackgroundTransparency = 0.9
Instance.new("UICorner", ContentHolder)

local function NewTab(name)
    local btn = Instance.new("TextButton", TabHolder)
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamMedium
    Instance.new("UICorner", btn)
    local page = Instance.new("ScrollingFrame", ContentHolder)
    page.Size = UDim2.new(1, -10, 1, -10)
    page.Position = UDim2.new(0, 5, 0, 5)
    page.Visible = false
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 2
    local pageList = Instance.new("UIListLayout", page); pageList.Padding = UDim.new(0, 5)
    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(ContentHolder:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
        page.Visible = true
    end)
    return page
end

local AimTab = NewTab("AIM")
local ESPTab = NewTab("ESP")
local ColorTab = NewTab("COLOR")
AimTab.Visible = true

-- 4. VARIÁVEIS DE ESTADO E DESENHOS
local EspLineOn, EspCornerOn, EspHealthOn, EspNameOn, EspDistOn, EspRGBOn = false, false, false, false, false, false
local AimbotOn, ShowFOV = false, false
local FOVRadius = 150
local Smoothness = 0.15

local Lines, Corners, Healths, HealthOuts, Names, Dists = {}, {}, {}, {}, {}, {}
local fov_circle = Drawing.new("Circle")
fov_circle.Thickness = 1; fov_circle.NumSides = 100; fov_circle.Radius = FOVRadius; fov_circle.Visible = false; fov_circle.Filled = false

local function RemoveESP(n)
    if Lines[n] then Lines[n]:Remove(); Lines[n] = nil end
    if Names[n] then Names[n]:Remove(); Names[n] = nil end
    if Dists[n] then Dists[n]:Remove(); Dists[n] = nil end
    if Healths[n] then Healths[n]:Remove(); Healths[n] = nil end
    if HealthOuts[n] then HealthOuts[n]:Remove(); HealthOuts[n] = nil end
    if Corners[n] then for _, v in pairs(Corners[n]) do v:Remove() end; Corners[n] = nil end
end

-- 5. LOOP DE RENDERIZAÇÃO
game:GetService("RunService").RenderStepped:Connect(function()
    local rgb = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    local cam = workspace.CurrentCamera
    
    -- FOV
    if ShowFOV then
        fov_circle.Visible = true
        fov_circle.Position = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
        fov_circle.Radius = FOVRadius
        fov_circle.Color = (EspRGBOn and rgb or TopBar.BackgroundColor3)
    else fov_circle.Visible = false end

    -- AIMBOT SUAVE (SÓ NO FOV)
    if AimbotOn then
        local target, closest = nil, FOVRadius
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, vis = cam:WorldToViewportPoint(p.Character.Head.Position)
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                    if mag < closest then target = p; closest = mag end
                end
            end
        end
        if target then
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, target.Character.Head.Position), Smoothness)
        end
    end

    -- ESP
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart
            local pos, onScreen = cam:WorldToViewportPoint(root.Position)
            if onScreen then
                local head = cam:WorldToViewportPoint(p.Character.Head.Position + Vector3.new(0, 0.5, 0))
                local leg = cam:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                local h = math.abs(head.Y - leg.Y)
                local w = h / 2
                local l, r = pos.X - w, pos.X + w
                local finalColor = EspRGBOn and rgb or TopBar.BackgroundColor3

                if EspNameOn then
                    local n = Names[p.Name] or Drawing.new("Text"); Names[p.Name] = n
                    n.Visible = true; n.Text = p.DisplayName; n.Center = true; n.Outline = true; n.Size = 18; n.Position = Vector2.new(pos.X, head.Y - 20)
                elseif Names[p.Name] then Names[p.Name].Visible = false end

                if EspDistOn then
                    local d = Dists[p.Name] or Drawing.new("Text"); Dists[p.Name] = d
                    local distNum = math.floor((root.Position - cam.CFrame.Position).Magnitude)
                    d.Visible = true; d.Text = "["..distNum.." studs]"; d.Center = true; d.Outline = true; d.Position = Vector2.new(pos.X, leg.Y + 5)
                elseif Dists[p.Name] then Dists[p.Name].Visible = false end

                if EspHealthOn then
                    local bar = Healths[p.Name] or Drawing.new("Line"); local out = HealthOuts[p.Name] or Drawing.new("Line")
                    Healths[p.Name], HealthOuts[p.Name] = bar, out
                    local bw, bx = 40, l - 25; local hp = p.Character.Humanoid.Health / p.Character.Humanoid.MaxHealth
                    out.Visible = true; out.From = Vector2.new(bx, leg.Y); out.To = Vector2.new(bx, head.Y); out.Thickness = bw + 4; out.Transparency = 0.5; out.Color = Color3.new(0,0,0)
                    bar.Visible = true; bar.From = Vector2.new(bx, leg.Y); bar.To = Vector2.new(bx, leg.Y - (h * math.clamp(hp,0,1))); bar.Thickness = bw; bar.Color = Color3.new(1,0,0):Lerp(Color3.new(0,1,0), hp)
                elseif Healths[p.Name] then Healths[p.Name].Visible = false; HealthOuts[p.Name].Visible = false end

                if EspLineOn then
                    local ln = Lines[p.Name] or Drawing.new("Line"); Lines[p.Name] = ln
                    ln.Visible = true; ln.From = Vector2.new(cam.ViewportSize.X/2, 0); ln.To = Vector2.new(pos.X, pos.Y); ln.Color = finalColor; ln.Thickness = 2
                elseif Lines[p.Name] then Lines[p.Name].Visible = false end

                if EspCornerOn then
                    if not Corners[p.Name] then local lns = {}; for i=1,8 do lns[i] = Drawing.new("Line"); lns[i].Thickness = 2 end; Corners[p.Name] = lns end
                    local cs = w/3; local pts = {{Vector2.new(l,head.Y),Vector2.new(l+cs,head.Y)},{Vector2.new(l,head.Y),Vector2.new(l,head.Y+cs)},{Vector2.new(r,head.Y),Vector2.new(r-cs,head.Y)},{Vector2.new(r,head.Y),Vector2.new(r,head.Y+cs)},{Vector2.new(l,leg.Y),Vector2.new(l+cs,leg.Y)},{Vector2.new(l,leg.Y),Vector2.new(l,leg.Y-cs)},{Vector2.new(r,leg.Y),Vector2.new(r-cs,leg.Y)},{Vector2.new(r,leg.Y),Vector2.new(r,leg.Y-cs)}}
                    for i, v in pairs(Corners[p.Name]) do v.Visible = true; v.From = pts[i][1]; v.To = pts[i][2]; v.Color = finalColor end
                elseif Corners[p.Name] then for _,v in pairs(Corners[p.Name]) do v.Visible = false end end
            else RemoveESP(p.Name) end
        else RemoveESP(p.Name) end
    end
end)

-- 6. COMPONENTES
local function AddToggle(parent, text, callback)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1, -10, 0, 45); b.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    b.Text = text .. ": OFF"; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamMedium; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() local s = callback(); b.Text = text..(s and ": ON" or ": OFF"); b.BackgroundColor3 = s and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0) end)
end

local function AddSlider(parent, text, min, max, start, callback)
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(1, -10, 0, 50); frame.BackgroundTransparency = 1
    local lab = Instance.new("TextLabel", frame); lab.Text = text..": "..start; lab.Size = UDim2.new(1,0,0,20); lab.TextColor3 = Color3.new(1,1,1); lab.BackgroundTransparency = 1
    local bg = Instance.new("Frame", frame); bg.Size = UDim2.new(1,-20,0,8); bg.Position = UDim2.new(0,10,0,25); bg.BackgroundColor3 = Color3.fromRGB(50,50,50); Instance.new("UICorner", bg)
    local fill = Instance.new("Frame", bg); fill.Size = UDim2.new((start-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.new(1,1,0); Instance.new("UICorner", fill)
    local btn = Instance.new("TextButton", bg); btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""
    local sliding = false
    btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true end end)
    game:GetService("UserInputService").InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
    game:GetService("UserInputService").InputChanged:Connect(function(i)
        if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
            local p = math.clamp((i.Position.X - bg.AbsolutePosition.X)/bg.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(p,0,1,0); local v = math.floor(min+(p*(max-min))); lab.Text = text..": "..v; callback(v)
        end
    end)
end

-- Botões
AddToggle(AimTab, "SMOOTH AIM", function() AimbotOn = not AimbotOn return AimbotOn end)
AddToggle(AimTab, "SHOW FOV", function() ShowFOV = not ShowFOV return ShowFOV end)
AddSlider(AimTab, "FOV SIZE", 50, 600, 150, function(v) FOVRadius = v end)

AddToggle(ESPTab, "ESP LINHA", function() EspLineOn = not EspLineOn return EspLineOn end)
AddToggle(ESPTab, "ESP CAIXA", function() EspCornerOn = not EspCornerOn return EspCornerOn end)
AddToggle(ESPTab, "ESP VIDA", function() EspHealthOn = not EspHealthOn return EspHealthOn end)
AddToggle(ESPTab, "ESP NOME", function() EspNameOn = not EspNameOn return EspNameOn end)
AddToggle(ESPTab, "ESP DISTANCIA", function() EspDistOn = not EspDistOn return EspDistOn end)
AddToggle(ESPTab, "ESP RGB", function() EspRGBOn = not EspRGBOn return EspRGBOn end)

local grid = Instance.new("UIGridLayout", ColorTab); grid.CellSize = UDim2.new(0, 60, 0, 60)
local cores = {Color3.new(1,1,0), Color3.new(0,0.7,1), Color3.new(1,0,0), Color3.new(0,1,0)}
for _, c in pairs(cores) do
    local b = Instance.new("TextButton", ColorTab); b.BackgroundColor3 = c; Instance.new("UICorner", b); b.Text = ""
    b.MouseButton1Click:Connect(function() TopBar.BackgroundColor3 = c; ZStroke.Color = c end)
end

ZIcon.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)
