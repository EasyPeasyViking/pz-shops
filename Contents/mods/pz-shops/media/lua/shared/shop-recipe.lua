require "shop-wallet"
local _internal = require "shop-shared"

shopsAndTradersRecipe = {}

---Authentic Z
--recipe Make a Stack of Money { Money, Result:Authentic_MoneyStack, Time:30.0, }
--recipe Convert into Item { Authentic_MoneyStack, Result:Money, Time:30.0, }

function shopsAndTradersRecipe.OnAuthZMoneyStack(items, result, player) return false end

local function recipeOverride()
    local allRecipes = getAllRecipes()
    for i=0, allRecipes:size()-1 do
        ---@type Recipe
        local recipe = allRecipes:get(i)
        if recipe then
            if recipe:getResult():getFullType()=="AuthenticZClothing.Authentic_MoneyStack" then
                recipe:setLuaTest("shopsAndTradersRecipe.OnAuthZMoneyStack")
                recipe:setIsHidden(true)
            end
        end
    end
end
Events.OnGameBoot.Add(recipeOverride)

---@param item InventoryItem
function shopsAndTradersRecipe.checkDeedValid(recipe, playerObj, item) --onCanPerform

    print("item:"..tostring(item))

    local cont = item:getContainer()
    if not cont then return false end

    local worldObj = cont and (not cont:isInCharacterInventory(playerObj)) and cont:getParent()
    if not worldObj then return false end
    if worldObj and worldObj:getModData().storeObjID then return false end

    return true
end

---@param items ArrayList
function shopsAndTradersRecipe.onActivateDeed(items, result, player) --onCreate
    local item = items:get(0)

    local cont = item:getContainer()
    if not cont then return false end

    local worldObj = cont and (not cont:isInCharacterInventory()) and cont:getParent()

    if worldObj and worldObj:getModData().storeObjID then
        return false
    end

    local x, y, z, worldObjName = self.worldObject:getX(), self.worldObject:getY(), self.worldObject:getZ(), _internal.getWorldObjectName(self.worldObject)
    sendClientCommand("shop", "assignStore", { x=x, y=y, z=z, worldObjName=worldObjName })
end


--[[
local moneyValueForDeedRecipe
function shopsAndTradersRecipe.addMoneyTypesToRecipe(scriptItems)
    print(" -- recipe adding: ")
    for _,type in pairs(_internal.getMoneyTypes()) do
        print(" --- ?: "..type)
        local scriptItem = getScriptManager():getItem(type)
        if not scriptItems:contains(scriptItem) then scriptItems:add(scriptItem) end
    end
end

function shopsAndTradersRecipe.onCanPerform(recipe, playerObj, item)
    return true
end

function shopsAndTradersRecipe.onCreate(items, result, player) end

--Creates Recipe for Shop Deeds
function shopsAndTradersRecipe.addDeedRecipe()
    local deedRecipe = SandboxVars.ShopsAndTraders.PlayerOwnedShopDeeds
    if not deedRecipe or deedRecipe=="" then return end

    local deedScript = {
        header="module ShopsAndTraders { imports { Base } recipe Create Shop Deed { ",
        footer="Result:ShopsAndTraders.ShopDeed, Time:30.0, Category:Shops,} }",
    }

    local rebuiltScript = ""
    for str in string.gmatch(deedRecipe, "([^|]+)") do

        local value, money = string.gsub(str, "%$", "")
        if money > 0 then
            moneyValueForDeedRecipe = value
            rebuiltScript = rebuiltScript.."keep Base.Money, "
            print("DEED SCRIPT: CURRENCY: ", value)
        else
            rebuiltScript = rebuiltScript..str..", "
            print("DEED SCRIPT:", str)
        end
    end

    print("SCRIPT:", rebuiltScript)

    local scriptManager = getScriptManager()
    scriptManager:ParseScript(deedScript.header..rebuiltScript..deedScript.footer)
end
--]]

--Events.OnResetLua.Add(shopsAndTradersRecipe.addDeedRecipe)
--Events.OnLoad.Add(shopsAndTradersRecipe.addDeedRecipe)
--if isServer() then Events.OnGameBoot.Add(shopsAndTradersRecipe.addDeedRecipe) end