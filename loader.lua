local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/dsfgtyuajkvujk/xvxvxvxvxvxvx/refs/heads/main/games.lua"))()

for PlaceID, Execute in pairs(Games) do
    if PlaceID == game.PlaceId then
        loadstring(game:HttpGet(Execute))()
    end
end
