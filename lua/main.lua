-- -- 注册一个mod
-- local mod = RegisterMod("M_mods", 1)
-- -- 使用Issac提供的接口函数,GetItemIdByName，获取道具id
-- -- Isaac是一个类，而不是对象
-- local tatakai = Isaac.GetItemIdByName("TATAKAI")
-- local tatakaiDamage = 1

-- function mod:EvaluateCache(player, cacheFlags)
--     -- 将cacheFlags和CacheFlag.CACHE_DAMAGE进行按位与操作，
--     if cacheFlags & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then
--         print("damage up~!")
--         local itemCount = player:GetCollectibleNum(tatakai)
--         local damage_to_add = tatakaiDamage * itemCount
--         player.Damage = player.Damage + damage_to_add   -- 重新赋值
--         player.TearColor = Color(0.0,1.0,1.0,1.0);
--     end
-- end


-- mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.EvaluateCache)

-- local YOXI = Isaac.GetItemIdByName("YOXI")

-- function mod:RioYOXI()
--     local RoomEntity = Isaac.GetRoomEntities()
--     for _, entity in ipairs(RoomEntity) do
--         if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() then
--             entity:Kill()
--         end
--     end
--     return {
--         Discharge = true,
--         Remove = false,
--         ShowAnim = true,
--     }
-- end

-- mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.RioYOXI, YOXI)




-- 注册 mod
local mod = RegisterMod("M_mods", 1)

-- 全局变量声明

local tatakai = Isaac.GetItemIdByName("TATAKAI")  -- 被动道具例子
local tatakaiDamage = 1
local yoxi = Isaac.GetItemIdByName("YOXI")  --主动道具例子


-- 定义基础命令类
local Command = {}
function Command:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    return obj
end

-- 定义TATAKAI道具的命令类
local TatakaiCommand = Command:new()
function TatakaiCommand:execute(player, cacheFlags)
    if cacheFlags & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then
        local itemCount = player:GetCollectibleNum(tatakai)
        local damage_to_add = tatakaiDamage * itemCount
        player.Damage = player.Damage + damage_to_add
    end
end

-- 定义YoxiCommand的命令类
local YoxiCommand = Command:new()
function YoxiCommand:execute()
    local roomEntities = Isaac.GetRoomEntities()
    for _, entity in ipairs(roomEntities) do
        -- 被击杀的对象，是entity呢
        if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() then
            entity:Kill()
        end
    end
end



-- 工厂方法来创建命令对象
local CommandFactory = {}
function CommandFactory:createCommand(itemId)
    if itemId == tatakai then
        return TatakaiCommand:new()     -- 延后new的执行
    elseif itemId == yoxi then
        return YoxiCommand:new()
    else
        return nil

    end
end

-- MC_EVALUATE_CACHE，检测堆栈后执行命令
function mod:onCACHE(player, cacheFlags)
    local command = CommandFactory:createCommand(tatakai)
    if command then
        -- Isaac.ConsoleOutput("In the onCACHE")
        command:execute(player, cacheFlags)
    end
end

-- MC_USE_ITEM，检测到使用主动道具（拍空格）后执行命令
function mod:onUseItem()
    local command = CommandFactory:createCommand(yoxi)
    if command then
        command:execute()
        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end
end


-- 添加到回调函数到 ModCallbacks.MC_EVALUATE_CACHE 事件
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.onCACHE)
mod:AddCallback(ModCallbacks.MC_USE_ITEM,mod.onUseItem,yoxi)