local notif = loadstring(game:HttpGet("https://raw.githubusercontent.com/insanedude59/notiflib/main/main"))()

notif:Notification("fortune.lua","Aimbot/ESP V1 Loaded!","GothamSemibold","Gotham",5)

-- Control Settings
local Settings = {
    Highlight = {
        Enabled = true;
        Teamcheck = false;
        Transparency = .7;
        IgnoreDead = true;
        EnemyColor = Color3.fromRGB(0, 0, 0);  -- Black color
        EnemyColorRainbow = false;  -- Disable rainbow
        TeamColor = Color3.fromRGB(255, 255, 255);  -- White color
        TeamColorRainbow = false;  -- Disable rainbow
    };

    Aimbot = {
        Enabled = true;
        Radius = 200;
        TargetPart = 'Head';
        VisibleCheck = true;
        TimeToTarget = .3;
        Teamcheck = true;
        Color = Color3.fromRGB(0, 0, 0);  -- Black color
        Rainbow = false;  -- Disable rainbow
    }
}

repeat task.wait() until game:IsLoaded()

-- Unload script if loaded
if(getgenv().RivalsScript and getgenv().RivalsScript.Unload) then
    local unloaded = getgenv().RivalsScript.Unload()
    if(unloaded ~= true) then
        print('Attempt to unload script failed, errors may occur')
    end
end

-- Globals
getgenv().RivalsScript = {}

-- Services
local WorkspaceService = game:GetService("Workspace")
local PlayersService = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

-- Vars
local LocalPlayer = PlayersService.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local GuiInset = GuiService:GetGuiInset()
local Camera = WorkspaceService.CurrentCamera
local WorldToScreen = Camera.WorldToScreenPoint

-- Internal Vars
local Internals = {
    Connections = {};
    HiddenGui = gethui();
    Highlights = {};
    Drawings = {};

    Aimbot = {
        On = false;
        FovDrawing = nil;
        ElapsedTime = 0;
        Target = nil;
    }
}

-- Internal Functions
local function Unload()
    print('Unloading Script')

    -- Disconnect all connections
    for _, v in pairs(Internals.Connections) do
        v:Disconnect()
    end

    -- Destroy hidden ui children
    for _, v in pairs(Internals.HiddenGui:GetChildren()) do
        v:Destroy()
    end

    -- Destroy drawings
    for _, v in pairs(Internals.Drawings) do
        v:Remove()
    end

    -- Clear global space
    getgenv().RivalsScript = nil

    print('Unloaded Script')

    return true
end
getgenv().RivalsScript.Unload = Unload

-- Functions
function IsTeammate(player)
    if(player.Character and player.Character:FindFirstChild('HumanoidRootPart')) then
        return player.Character.HumanoidRootPart:FindFirstChild('TeammateLabel') ~= nil
    end

    return false
end

-- Highlight Functions
function AddPlayerHighlight(player)
    local hl = Instance.new('Highlight')
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = Internals.HiddenGui
    hl.FillTransparency = (IsTeammate(player) and Settings.Highlight.Teamcheck) and 1 or Settings.Highlight.Transparency
    hl.OutlineTransparency = (IsTeammate(player) and Settings.Highlight.Teamcheck) and 1 or 0
    hl.OutlineColor = (IsTeammate(player)) and Settings.Highlight.TeamColor or Settings.Highlight.EnemyColor
    hl.FillColor = (IsTeammate(player)) and Settings.Highlight.TeamColor or Settings.Highlight.EnemyColor
    Internals.Highlights[player.Name] = hl

    if(player.Character) then
        hl.Adornee = player.Character
    end

    local con = player.CharacterAdded:Connect(function(character)
        hl.Adornee = character
    end)
    table.insert(Internals.Connections, con)
end

function RemovePlayerHighlight(player)
    if(Internals.Highlights[player.Name]) then
        Internals.Highlights[player.Name]:Destroy()
        Internals.Highlights[player.Name] = nil
    end
end

function UpdatePlayerHighlight(player)
    local hl = Internals.Highlights[player.Name]
    local color = nil
    local isTeammate = IsTeammate(player)

    if(isTeammate and Settings.Highlight.TeamColorRainbow) then
        color = Settings.Highlight.TeamColor  -- Just set it to the solid TeamColor (no rainbow)
    elseif(not isTeammate and Settings.Highlight.EnemyColorRainbow) then
        color = Settings.Highlight.EnemyColor  -- Just set it to the solid EnemyColor (no rainbow)
    else
        color = (isTeammate) and Settings.Highlight.TeamColor or Settings.Highlight.EnemyColor
    end

    if(player.Character and player.Character:FindFirstChild('Humanoid') and player.Character:FindFirstChild('Humanoid').Health == 0) then
        if(Settings.Highlight.IgnoreDead) then
            hl.FillTransparency = 1
            hl.OutlineTransparency = 1
            return
        end
        color = Color3.fromRGB(0, 0, 0)  -- Dead player highlight
    end

    hl.FillTransparency = (isTeammate and Settings.Highlight.Teamcheck) and 1 or Settings.Highlight.Transparency
    hl.OutlineTransparency = (isTeammate and Settings.Highlight.Teamcheck) and 1 or 0
    hl.OutlineColor = color
    hl.FillColor = color
end

-- Aimbot Functions
function FindClosestPlayer()
    local closestPlayer = nil
    local closestDist = nil

    for _, v in pairs(PlayersService:GetPlayers()) do
        if((Settings.Aimbot.Teamcheck and IsTeammate(v)) or (v == LocalPlayer) or (v.Character == nil) or (v.Character:FindFirstChild(Settings.Aimbot.TargetPart) == nil)) then continue end
        if(not v.Character:FindFirstChild('Humanoid') or v.Character:FindFirstChild('Humanoid').Health == 0) then continue end

        local screenPoint, _ = WorldToScreen(Camera, v.Character:FindFirstChild(Settings.Aimbot.TargetPart).CFrame.Position)
        if(screenPoint.Z < 0) then continue end
        if(Settings.Aimbot.VisibleCheck and not IsVisible(v)) then continue end

        local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
        if(dist > Settings.Aimbot.Radius) then continue end

        if(closestPlayer == nil) then
            closestPlayer = v
            closestDist = dist
            continue
        end

        if(closestDist > dist) then
            closestDist = dist
            closestPlayer = v
        end
    end

    return closestPlayer
end

-- Main

-- Setup Highlight
if(Settings.Highlight.Enabled) then
    -- Setup existing players
    for _, v in pairs(PlayersService:GetPlayers()) do
        if(v == LocalPlayer) then continue end

        AddPlayerHighlight(v)
    end

    -- Setup new players
    local con = PlayersService.PlayerAdded:Connect(AddPlayerHighlight)
    table.insert(Internals.Connections, con)

    -- Cleanup on leave
    local con = PlayersService.PlayerRemoving:Connect(RemovePlayerHighlight)
    table.insert(Internals.Connections, con)
end

-- Setup Aimbot
if(Settings.Aimbot.Enabled) then
    local fovDrawing = Drawing.new('Circle')
    fovDrawing.Transparency = 1
    fovDrawing.Thickness = 2
    fovDrawing.NumSides = 100
    fovDrawing.Radius = Settings.Aimbot.Radius
    fovDrawing.Filled = false
    fovDrawing.Color = Color3.fromRGB(0, 0, 0)  -- Black color
    fovDrawing.Position = Vector2.new(100, 100)
    fovDrawing.Visible = true
    Internals.Aimbot.FovDrawing = fovDrawing
    table.insert(Internals.Drawings, fovDrawing)

    local con = Mouse.Button2Down:Connect(function()
        Internals.Aimbot.On = true
    end)
    table.insert(Internals.Connections, con)

    local con = Mouse.Button2Up:Connect(function()
        Internals.Aimbot.On = false
        Internals.Aimbot.ElapsedTime = 0
        Internals.Aimbot.Target = nil;
    end)
   
