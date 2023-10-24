local _internal = require "shop-shared"

LuaEventManager.AddEvent("SHOPPING_ClientModDataReady")

local function onClientModDataReady(storeID)

    sendClientCommand(getPlayer(),"shop", "grabShop", {storeID=storeID})

    --[[
    if not isClient() then
        _internal.copyAgainst(GLOBAL_STORES, CLIENT_STORES)
        --_internal.copyAgainst(GLOBAL_WALLETS, CLIENT_WALLETS)
    else
        ModData.request("STORES")
        --ModData.request("WALLETS")
    end
    --]]
end
Events.SHOPPING_ClientModDataReady.Add(onClientModDataReady)


local function onServerCommand(_module, _command, _data)
    if _module ~= "shop" then return end
    _data = _data or {}

    if _command == "severModData_received" then
        --onClientModDataReady()
        --sendServerCommand("shop", "severModData_received", args) --storeID
        if _data.store and _data.store.storeID then
            if storeWindow.instance and storeWindow.instance:isVisible() and storeWindow.storeObj and storeWindow.storeObj.ID then
                if storeWindow.storeObj.ID == _data.store.storeID then
                    storeWindow.storeObj = _data.store
                end
            end
        end
    end

    if _command == "transmitItems" then for _,itemType in pairs(_data.items) do getPlayer():getInventory():AddItem(itemType) end end

    if _command == "updateWallet" then
        local wallet = _data
        if not wallet.playerUUID then return end
        CLIENT_WALLETS[wallet.playerUUID] = _data
    end

    if _command == "sendMoneyItem" then
        local moneyTypes = _internal.getMoneyTypes()
        local type = moneyTypes[ZombRand(#moneyTypes)+1]
        local money = InventoryItemFactory.CreateItem(type)
        generateMoneyValue(money, _data.value, true)
        getPlayer():getInventory():AddItem(money)
    end

    if _command == "updateTransferOffer" then
        if ISTradingUI.instance and ISTradingUI.instance:isVisible() then ISTradingUI.instance.setOfferedAmount = _data.amount end
    end
end
Events.OnServerCommand.Add(onServerCommand)
