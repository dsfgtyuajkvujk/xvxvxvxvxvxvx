local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/xinjuri/182736446271818923/refs/heads/main/8761262386363.lua"))()

for PlaceID, Execute in pairs(Games) do
    if PlaceID == game.PlaceId then
        loadstring(game:HttpGet(Execute))()
    end
end
