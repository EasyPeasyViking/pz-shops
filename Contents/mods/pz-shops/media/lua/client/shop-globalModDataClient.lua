---Credit to Konijima (Konijima#9279) for clearing up networking :thumbsup:
if isServer() then return end -- execute in SP or on Client

require "shop-commandsServerToClient"
require "shop-shared"

CLIENT_STORES = {}
CLIENT_WALLETS = {}

local function initGlobalModData(isNewGame)

    if isClient() then
        if ModData.exists("STORES") then ModData.remove("STORES") end
        if ModData.exists("WALLETS") then ModData.remove("WALLETS") end
    end

    CLIENT_STORES = ModData.getOrCreate("STORES")
    CLIENT_WALLETS = ModData.getOrCreate("WALLETS")

    --if isNewGame then print("- New Game Initialized!") else print("- Existing Game Initialized!") end
    triggerEvent("SHOPPING_ClientModDataReady", isNewGame)
end
Events.OnInitGlobalModData.Add(initGlobalModData)


---@param name string
---@param data table
local function receiveGlobalModData(name, data)
    print("- Received ModData " .. name)

    if name == "STORES" then
        _internal.copyAgainst(CLIENT_STORES,data)
    elseif name == "WALLETS" then
        _internal.copyAgainst(CLIENT_WALLETS,data)
    end
end
Events.OnReceiveGlobalModData.Add(receiveGlobalModData)