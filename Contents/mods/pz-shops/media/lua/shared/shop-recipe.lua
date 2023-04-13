require "shop-wallet"
require "shop-shared"

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


function shopsAndTradersRecipe.checkDeedValid()
    return true
end


local moneyValueForDeedRecipe
function shopsAndTradersRecipe.addMoneyTypesToRecipe(scriptItems)
    print(" -- recipe adding: ")
    for _,type in pairs(_internal.getMoneyTypes()) do
        print(" --- ?: "..type)
        addExistingItemType(scriptItems, type)
    end
end

function shopsAndTradersRecipe.onCanPerform() end

function shopsAndTradersRecipe.onCreate() end

function shopsAndTradersRecipe.onActivateDeed() end

--Creates Recipe for Shop Deeds
function shopsAndTradersRecipe.addDeedRecipe()
    local deedRecipe = SandboxVars.ShopsAndTraders.PlayerOwnedShopDeeds
    if not deedRecipe or deedRecipe=="" then return end

    local deedScript = {
        header="module ShopsAndTraders { imports { Base } recipe Create Shop Deed { ",
        footer="Result:ShopsAndTraders.ShopDeed, OnCreate:shopsAndTradersRecipe.onCreate, OnCanPerform:shopsAndTradersRecipe.onCanPerform, Time:30.0, Category:Shops,} }",
    }

    local rebuiltScript = ""
    for str in string.gmatch(deedRecipe, "([^|]+)") do

        local value, money = string.gsub(str, "%$", "")
        if money > 0 then
            moneyValueForDeedRecipe = value
            rebuiltScript = rebuiltScript.."keep [shopsAndTradersRecipe.addMoneyTypesToRecipe], "
            print("DEED SCRIPT: CURRENCY: ", value)
        else
            rebuiltScript = rebuiltScript..str..", "
            print("DEED SCRIPT:", str)
        end
    end

    local scriptManager = getScriptManager()
    scriptManager:ParseScript(deedScript.header..rebuiltScript..deedScript.footer)
end

Events.OnLoad.Add(shopsAndTradersRecipe.addDeedRecipe)
if isServer() then Events.OnGameBoot.Add(shopsAndTradersRecipe.addDeedRecipe) end