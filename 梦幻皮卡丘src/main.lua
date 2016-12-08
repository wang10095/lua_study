
--[[
    in MVC structure, controller is used to transform user's event to logic event. 
    In our case, we use layout to handle those user's events. So there would not be 
    actually any visible real controllers named with controller. As a controller, it 
    would contain relative views and models and it would register connections between
    those views and models like petcell, functioncell, etc.
    Model is used to manage data and notify it's subscribers to update.
    View is used to display UI and capture user's event.

    So in our application architecture, some views are both view and controller. we call 
    them cell in our application!
--]]
require "extern"
require "Cocos2d"
require "Cocos2dConstants"
require "common/require"

-- cclog
cclog = function(...)
    print(string.format(...))
end

_G._scaleResolutionX = TuiManager:getInstance():getScaleResolutionX()
_G._scaleResolutionY = TuiManager:getInstance():getScaleResolutionY()
-- Arp
Arp = function(p)
    p.x = p.x * _G._scaleResolutionX
    p.y = p.y * _G._scaleResolutionY
    return p
end

REGISTER_SCENE_FUNC = function(sceneName,constructFunc)
    CSceneManager:getInstance():registerSceneClassScriptFunc(sceneName,constructFunc)
end

LoadScene = function(sceneName)
    return CSceneManager:getInstance():loadScene(sceneName)
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
end

local function main()
    collectgarbage("collect")
    
    -- -- avoid memory leak
    collectgarbage("setpause",  100)
    collectgarbage("setstepmul",  5000)

    --load all needed files
    Require.requireAll()

    --注册场景
    -- {sceneName, createFunc} 
    local scenes = {
        {"TransScene", TransScene.create},
        {"MainUI", MainUI.create},
        {"PveUI", PveUI.create},
        {"DungeonUI", DungeonUI.create},
        {"BattleUI",  BattleUI.create},
        {"PvPBattleUI",  PvPBattleUI.create},
        {"BattleEndUI",  BattleEndUI.create},
        {"PetListUI",  PetListUI.create},
        {"ItemDropPopup",  ItemDropPopup.create},
        {"FoodInfoPopup",  FoodInfoPopup.create},
        {"SubInfoPopup",  SubInfoPopup.create},
        {"NormalPopup",  NormalPopup.create},
        {"PetAttributeUI",  PetAttributeUI.create},
        {"TipPopup",  TipPopup.create},
        {"BuyPopup", BuyPopup.create},
        {"ShopUI", ShopUI.create},
        {"WildUI", WildUI.create},
        {"TrialTreasurePopup", TrialTreasurePopup.create},
        {"TrialRankPopup", TrialRankPopup.create},
        {"TrialUI", TrialUI.create},
        {"RefurbishPopup", RefurbishPopup.create},
        {"MailPopup", MailPopup.create},
        {"MailcontentPopup", MailcontentPopup.create},
        {"GoldhandPopup", GoldhandPopup.create},
        {"GuidePopup", GuidePopup.create},
        {"RechargePopup", RechargePopup.create},
        {"PetInfoPopup", PetInfoPopup.create},
        {"RankUI", RankUI.create},
        {"RankContentPopup", RankContentPopup.create},
        {"RankPowerContentPopup", RankPowerContentPopup.create},
        {"SecondensurePopup", SecondensurePopup.create},
        {"PetchosePopup", PetchosePopup.create},
        {"WeekGiftUI", WeekGiftUI.create},
        {"IteminfoPopup", IteminfoPopup.create},
        {"LogInUI", LogInUI.create},
        {"LogInPopup", LogInPopup.create},
        {"RegisterPopup", RegisterPopup.create},
        {"UpStarPopup", UpStarPopup.create},
        {"BuySkillPopup", BuySkillPopup.create},
        {"SkillInfoPopup", SkillInfoPopup.create},
        {"SiftPetPopup", SiftPetPopup.create},
        {"SequencePetPopup", SequencePetPopup.create},
        {"BagPopup", BagPopup.create},
        {"SellItemPopup", SellItemPopup.create},
        {"UseItemPopup", UseItemPopup.create},
        {"AtlasUI", AtlasUI.create},
        {"DailyPopup", DailyPopup.create},
        {"ActivityUI",ActivityUI.create},
        {"PetRankPromotePopup",PetRankPromotePopup.create},
        {"PetBreedHouse",PetBreedHouse.create},
        {"BreedSelectPetPopup",BreedSelectPetPopup.create},
        {"BreedResultPopup",BreedResultPopup.create},
        {"ChangeModelPopup",ChangeModelPopup.create},
        {"PvePopup",PvePopup.create},
        {"SweepPopup",SweepPopup.create},
        {"SettingPopup",SettingPopup.create},
        {"CapturePetPopup",CapturePetPopup.create},
        {"RecoveryPopup",RecoveryPopup.create},
        {"BattleVictoryPopup",BattleVictoryPopup.create},
        {"BattleDefeatPopup",BattleDefeatPopup.create},
        {"AchievementPopup",AchievementPopup.create},
        {"AchievementContentPopup",AchievementContentPopup.create},
        {"BattlePausePopup", BattlePausePopup.create},
        {"CaptureInBattlePopup", CaptureInBattlePopup.create},
        {"ExploreUI",ExploreUI.create},
        {"BattlePalaceUI",BattlePalaceUI.create},
        {"PyramidUI",PyramidUI.create},
        {"PyramidRewardsPopup",PyramidRewardsPopup.create},
        {"LoadingMaskPopup",LoadingMaskPopup.create},
        {"ActivityDiscountPopup",ActivityDiscountPopup.create},
        {"ActivityTurnTablePopup",ActivityTurnTablePopup.create},
        {"ActivityEncounterPopup",ActivityEncounterPopup.create},
        {"ActivityQuestionPopup",ActivityQuestionPopup.create},
        {"DisplayRewardsPopup",DisplayRewardsPopup.create},
        {"RouletteUI",RouletteUI.create},
        {"WildItemsPopup",WildItemsPopup.create},
        {"ChestItemsPopup",ChestItemsPopup.create},
        {"PetIntroducePopup",PetIntroducePopup.create},
        {"NewPetPopup",NewPetPopup.create},
        {"ServicerPopup",ServicerPopup.create},
        {"SilverChampionshipUI",SilverChampionshipUI.create},
        {"ChallengePopup",ChallengePopup.create},
        {"DefenseTeamUI",DefenseTeamUI.create},
        {"RoleIconPopup",RoleIconPopup.create},
        {"ChangeIconPopup",ChangeIconPopup.create},
        {"ChangeNamePopup",ChangeNamePopup.create},
        {"ChoosePetPopup",ChoosePetPopup.create},
        {"PresetUI",PresetUI.create},
        {"StoryPopup",StoryPopup.create},
        {"PvpVictoryPopup",PvpVictoryPopup.create},
        {"PvpDefeatPopup",PvpDefeatPopup.create},
        {"SweepOncePopup",SweepOncePopup.create},
        {"ChestRewardPopup",ChestRewardPopup.create},
        {"ActivityEndPopup",ActivityEndPopup.create},
        {"SignPopup",SignPopup.create},
        {"RecoverEnergyPopup",RecoverEnergyPopup.create},
        {"AnnouncePopup",AnnouncePopup.create},
        {"PlayerLevelUpPopup",PlayerLevelUpPopup.create},
        {"TurntableRewardPopup",TurntableRewardPopup.create},
        {"NewPetPopup",NewPetPopup.create},
        {"PvpBuyPopup",PvpBuyPopup.create},
        {"BeginVideoUI",BeginVideoUI.create},
    }
    for i,v in ipairs(scenes) do
        REGISTER_SCENE_FUNC(v[1], v[2])
    end


    
    StoryManager.initStoryManager()
    GuideManager.initGuide()
    PromtManager.init()
    local account = cc.UserDefault:getInstance():getStringForKey("account")
    local password = cc.UserDefault:getInstance():getStringForKey("password")

    cc.SpriteFrameCache:getInstance():addSpriteFrames("component_common/component_common.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("cell_item/cell_item.plist")
    if string.len(account) == 0 and string.len(password) == 0 then
        Utils.runWithScene("BeginVideoUI")
        ServerDataProxy:getInstance():set("switchLogin",1)
    else
        Utils.runWithScene("LogInUI")
    end
    -- TalkingDataGA:setVerboseLogDisabled()
    TalkingDataGA:onStart(Constants.APP_ID,"TalkingData") 
    
end

xpcall(main, __G__TRACKBACK__)
