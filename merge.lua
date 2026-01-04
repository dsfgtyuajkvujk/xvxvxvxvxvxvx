-- Load Kavo UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xnkq/idk/refs/heads/main/source.lua"))()

-- Create Window
local Window = Library.CreateLib("fortune.lua | Merge Brainrot", "BlueEngine") -- Change theme as needed

-- Create Tab and Section
local MainTab = Window:NewTab("Main")
local MainSection = MainTab:NewSection("Main")

-- Infinite Cash Button
MainSection:NewButton("Infinite Cash", "Gives a ton of cash", function()
    print("Infinite Cash button pressed")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local GiveCashEvent = ReplicatedStorage.Remotes:FindFirstChild("GiveCashEvent")

    if GiveCashEvent then
        GiveCashEvent:FireServer(1e8)
    end
end)

-- Infinite Gems Button
MainSection:NewButton("Infinite Gems", "Gives a ton of gems", function()
    print("Infinite Gems button pressed")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local GemEvent = ReplicatedStorage.Remotes:FindFirstChild("GemEvent")

    if GemEvent then
        GemEvent:FireServer(1e8)
    end
end)

-- Free Spin Button
MainSection:NewButton("Free Spin", "Fires free spin event", function()
    print("Free Spin button pressed")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local FreeSpinEvent = ReplicatedStorage.Remotes:FindFirstChild("FreeSpinEvent")

    if FreeSpinEvent then
        FreeSpinEvent:FireServer(1e8)
    end
end)

local Tab = Window:NewTab("Settings")
local Section = Tab:NewSection("Settings")
Section:NewKeybind("KeybindText", "KeybindInfo", Enum.KeyCode.RightShift, function()
    Library:ToggleUI()
end)
