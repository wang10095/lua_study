module ("ResMap", package.seeall)

RES_MAP = {
	common = "component_common/component_common.plist",
	LogInUI = {"ui_login","img_login_bg.jpg"},
	LogInPopup = {"popup_login"},
    MainUI = {"ui_main","img_main_bg.jpg", "cell_player"},
    PveUI = {"ui_pve","component_ui_pve_ui_shop"},
    DungeonUI = {"component_ui_dungeon_explore","ui_dungeon","img_chapter_bg.jpg"},
    BattleUI = {"ui_battle","ui_defense_team","ui_explore"},
    PvPBattleUI = {"ui_battle","ui_defense_team", "img_pvp1_bottom_anim_bg.jpg"},
    PetListUI = {"ui_pet_list","component_popup","component_ui_pet_breedhouse_ui_pet_list","component_ui_pet_list_ui_shop"},
    ItemDropPopup = {"popup_item_drop","component_popup","component_list"},
    NormalPopup = {"component_popup"},
    PetAttributeUI = {"ui_pet_attribute","component_ui_pet_attribute_ui_pet_breedhouse","component_popup","img_pet_bg.jpg","img_pet_info_bg.png","component_popup_change_icon_ui_pet_attribute"},
    BuyPopup = {"component_popup"},
    ShopUI = {"ui_shop","component_ui_pet_list_ui_shop","component_popup","component_ui_pve_ui_shop","component_ui_shop_ui_weekgift","img_shop_bg.jpg"},
    WildUI = {"ui_wild","img_pet_bg.jpg","img_pet_info_bg.png"},
    RefurbishPopup = {"component_popup"},
    MailPopup = {"component_popup","popup_mail","component_list"},
    MailcontentPopup = {"component_popup","component_popup_mail_content_popup_petinfo","popup_mail_read"},
    GoldhandPopup = {"component_popup","popup_goldhand"},
    RechargePopup = {"component_popup","popup_recharge"},
    PetInfoPopup = {"component_popup","component_popup_mail_content_popup_petinfo","popup_ui_atlas_popup_petinfo"},
    RankUI = {"ui_rank","component_list","component_ui_rank_popup_rank_arena_content","img_bg.png"},
    RankPowerContentPopup = {"component_popup","component_ui_rank_popup_rank_arena_content"},
    SecondensurePopup = {"component_popup"},
    WeekGiftUI = {"component_list","ui_weekgift","component_popup_daily_popup_sign_ui_weekgift","component_popup_sign_ui_weekgift","component_ui_shop_ui_weekgift","component_ui_weekgift_popup_sign","img_bg.png"},
    IteminfoPopup = {"component_popup"},
    RegisterPopup = {"popup_login"},
    UpStarPopup = {"component_popup_rank_promote_popup_upstar","component_popup","popup_upstar"},
    SkillInfoPopup = {"component_popup"},
    SequencePetPopup = {"component_popup"},
    BagPopup = {"component_popup","popup_bag","component_list"},
    SellItemPopup = {"component_popup","popup_bag","component_list"},
    UseItemPopup = {"component_popup","popup_bag","component_list"},
    AtlasUI = {"ui_atlas","popup_ui_atlas_popup_petinfo","component_list","img_bg.png"},
    DailyPopup = {"component_popup_daily_popup_sign_ui_weekgift","component_popup","popup_daily","component_list","component_popup_achievement_popup_daily"},
    ActivityUI = {"ui_activity","img_bg.png"},
    PetRankPromotePopup = {"component_popup_rank_promote_popup_upstar","component_popup","popup_rank_promote"},
    PetBreedHouse = {"ui_breedhouse","component_ui_pet_attribute_ui_pet_breedhouse","component_ui_pet_breedhouse_ui_pet_list","img_breed_bg.jpg"},
    BreedSelectPetPopup = {"component_popup","component_list","ui_pet_list"},
    BreedResultPopup = {"component_popup","ui_pet_list"},
    PvePopup = {"component_popup"},
    SweepPopup = {"component_popup","popup_sweep","component_list"},
    SettingPopup = {"component_poup_change_name_popup_setting","component_popup","popup_setting"},
    CapturePetPopup = {"popup_capturepet","component_popup","component_popup_capturepet_ui_new_pet"},
    BattleVictoryPopup = {"component_popup_battle_defeat_popup_battle_victory","component_popup","popup_battle_victory"},
    BattleDefeatPopup = {"component_popup","component_popup_battle_defeat_popup_battle_victory","component_popup_battle_defeat_popup_pvp_defeat"},
    AchievementPopup = {"component_popup","popup_achievement","component_list","component_popup_achievement_popup_daily"},
    AchievementContentPopup = {"component_popup_achievement_content_popup_treasure_chest","component_popup"},
    CaptureInBattlePopup = {"popup_capturepet","component_popup","component_popup_capturepet_ui_new_pet"},
    ExploreUI = {"component_ui_dungeon_explore","ui_explore","ui_main","img_explore_bg.jpg"},
    BattlePalaceUI = {"ui_battle_palace","img_bg_1.jpg","img_bg_2.jpg"},
    PyramidUI = {"ui_pyramid","component_ui_pvp1_ui_pyramid","img_pyramid_bg.jpg"},
    ActivityDiscountPopup = {"component_popup","popup_activity1_discount"},
    ActivityTurnTablePopup = {"popup_activity1_turntable"},
    ActivityEncounterPopup = {"component_popup","popup_activity1_encounter"},
    ActivityQuestionPopup = {"component_popup","popup_activity1_questions"},
    DisplayRewardsPopup = {"component_popup","popup_activity1_reward"},
    RouletteUI = {"ui_roulette","img_pet_info_bg.png","img_roulette_bg.jpg","ui_explore"},
    ChestItemsPopup = {"component_popup","component_popup_achievement_content_popup_treasure_chest"},
    NewPetPopup = {"popup_new_pet","component_popup_capturepet_ui_new_pet"},
    ServicerPopup = {"popup_login"},
    SilverChampionshipUI = {"ui_pvp1","component_ui_pvp1_ui_pyramid","img_pet_info_bg.png","img_pvp1_bg.jpg"},
    ChallengePopup = {"component_popup","popup_challenge","component_list"},
    DefenseTeamUI = {"ui_defense_team","ui_battle_palace"},
    RoleIconPopup = {"cell_player","component_popup","popup_role_icon"},
    ChangeIconPopup = {"component_popup","popup_change_icon","component_popup_change_icon_ui_pet_attribute"},
    ChangeNamePopup = {"component_poup_change_name_popup_setting","component_popup"},
    PresetUI = {"ui_preset","component_popup","img_present_bg.jpg"},
    StoryPopup = {"ui_story"},
    PvpVictoryPopup = {"component_popup"},
    PvpDefeatPopup = {"component_popup_battle_defeat_popup_pvp_defeat","component_popup"},
    SweepOncePopup = {"component_popup"},
    ChestRewardPopup = {"component_popup","popup_pve_chest"},
    ActivityEndPopup = {"component_popup"},
    SignPopup = {"component_list","component_popup","popup_sign","component_popup_daily_popup_sign_ui_weekgift","component_popup_sign_ui_weekgift","component_ui_weekgift_popup_sign"},
    RecoverEnergyPopup = {"popup_recover_energy","component_popup"},
    AnnouncePopup = {"component_popup","popup_announce"},
    PlayerLevelUpPopup = {"component_popup","popup_player_level_up"},
    TurntableRewardPopup = {"component_popup"},
    BattlePausePopup = {"component_popup","popup_battle_pause"},
    PvpBuyPopup = {"component_popup"},
    PyramidRewardsPopup = {"component_popup"},
    BeginVideoUI = {"btn_jump_normal.png","btn_jump_select.png"},
}

