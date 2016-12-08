module("Require",package.seeall)

function requireAll()
	print("requireAll")

	require "view/ui/trans_scene"

	require "common/constants"
	require "common/config"
	require "common/debug"
	require "common/spine"
	require "common/utils"
	require "common/toucheffect"
	require "common/res_map"
	--model--
	require "model/model"
	require "model/fragment"
	require "model/pet"
	require "model/player"
	require "model/stagerecord"
    require "model/item"

	--manager--  
	require "manager/netmanager"
	require "manager/configmanager"
	require "manager/texturemanager"
	require "manager/itemmanager"
	require "manager/textmanager"
	require "manager/guidemanager"
	require "manager/musicmanager"
	require "manager/passive_skill_manager"
	require "manager/story_manager"
	require "manager/tip_manager"
	require "manager/resource_manager.lua"
	require "manager/promtmanager"
	require "manager/npctalk_manager.lua"

	--cell--
	require "view/cell/functioncell"
	require "view/cell/petcell"
	require "view/cell/itemcell"
	require "view/cell/playercell"

	--proxy
	require "proxy/trialdataproxy"
	require "proxy/tipdataproxy"
	require "proxy/achievementdataproxy"
	require "proxy/normaldataproxy"
	require "proxy/shopdataproxy"
	require "proxy/hotpetdataproxy"
	require "proxy/petattributedataproxy"
	require "proxy/mysterytoydataproxy"
	require "proxy/maildataproxy"
	-- require "proxy/guidedataproxy"
	require "proxy/goldhanddataproxy"
	require "proxy/rankdataproxy"
	require "proxy/dailydataproxy"
	require "proxy/dailyattendancedataproxy"
	require "proxy/serverdataproxy"
	require "proxy/pet_breed_proxy"
	require "proxy/stage_proxy"
	require "proxy/pyramid_proxy"
	require "proxy/activity1_status_proxy"
	require "proxy/wild_data_proxy"
	require "proxy/atlas_proxy"
	require "proxy/pvp1_proxy"
	require "proxy/player_proxy"
	require "proxy/story_proxy"
	--popup--
	require "view/popup/popup"
	require "view/popup/guidepopup"
	require "view/popup/tippopup"
	require "view/popup/item_drop_popup"
	require "view/popup/foodinfopopup"
	require "view/popup/subinfopopup"
	require "view/popup/normalpopup"
	require "view/popup/buypopup"
	require "view/popup/trialrankpopup"
	require "view/popup/trialtreasurepopup"
	require "view/popup/refurbishpopup"
	require "view/popup/mail_popup"
	require "view/popup/mail_content_popup"
	require "view/popup/goldhand_popup"
	require "view/popup/rechargepopup"
	require "view/popup/rankcontentpopup"
	require "view/popup/rankpowercontentpopup"
	require "view/popup/secondensure_popup"
	require "view/popup/petchosepopup"
	require "view/popup/iteminfopopup"
	require "view/popup/loginpopup"
	require "view/popup/registerpopup"
	require "view/popup/upstarpopup"
	require "view/popup/buyskillpopup" 
	require "view/popup/skillinfopopup"
	require "view/popup/siftpetpopup"
	require "view/popup/sequencepetpopup"
	require "view/popup/bag_popup"
	require "view/popup/sellitem_popup"
	require "view/popup/useitem_popup"
	require "view/popup/petinfo_popup"
	require "view/popup/daily_popup"
	require "view/popup/pet_rank_promote_popup"
	require "view/popup/breed_select_pet_popup"
	require "view/popup/breed_result_popup"
	require "view/popup/change_model_popup"
	require "view/popup/pve_popup"
	require "view/popup/sweep_popup"
	require "view/popup/setting_popup"
	require "view/popup/capturepet_popup"
	require "view/popup/recovery_popup"
	require "view/popup/battle_victory_popup"
	require "view/popup/battle_defeat_popup"
	require "view/popup/achievement_popup"
	require "view/popup/achievement_content_popup"
	require "view/popup/battle_pause_popup"
	require "view/popup/loading_mask_popup"
	require "view/popup/capture_in_battle_popup"
	require "view/popup/pyramid_rewards_popup"
	require "view/popup/activity1_discount_popup"
	require "view/popup/activity1_question_popup"
	require "view/popup/activity1_encounter_popup"
	require "view/popup/activity1_turntable_popup"
	require "view/popup/display_rewards_popup"
	require "view/popup/wild_items_popup"
	require "view/popup/chest_items_popup"
	require "view/popup/pet_introduce_popup"
	require "view/popup/new_pet_popup"
	require "view/popup/servicer_popup"
	require "view/popup/challenge_popup"
	require "view/popup/role_icon_popup"
	require "view/popup/change_name_popup"
	require "view/popup/change_icon_popup"
	require "view/popup/choose_pet_popup"
	require "view/popup/story_popup"
	require "view/popup/pvp_victory_popup"
	require "view/popup/pvp_defeat_popup"
	require "view/popup/sweep_once_popup"
	require "view/popup/chest_reward_popup"
	require "view/popup/activity1_end_popup"
	require "view/popup/sign_popup"
	require "view/popup/recover_energy_popup"
	require "view/popup/announce_popup"
	require "view/popup/player_level_up_popup"
	require "view/popup/turntable_reward_popup"
	require "view/popup/new_pet_popup"
	require "view/popup/pvp_buy_popup"
	--ui--
	require "view/ui/battleui"
	require "view/ui/pvp_battle_ui"
	require "view/ui/battleendui"
	require "view/ui/mainui"
	require "view/ui/pveui"
	require "view/ui/dungeonui"
	require "view/ui/petlistui"
	require "view/ui/petattributeui"
	require "view/ui/shopui"
	require "view/ui/wild_ui"
	require "view/ui/trialui"
	require "view/ui/loginui"
	require "view/ui/pet_breedhouse"
	require "view/ui/explore_ui"
	require "view/ui/battle_palace_ui"
	require "view/ui/pyramid_ui"
	require "view/ui/roulette_ui"
	require "view/ui/atlas_ui"
	require "view/ui/rank_ui"
	require "view/ui/silver_championshop_ui"
	require "view/ui/defense_team_ui"
	require "view/ui/activity_ui"
	require "view/ui/weekgift_ui"
	require "view/ui/preset_ui"
	require "view/ui/begin_video_ui"
	-- battle --
	require "battle/passive_skill"
	require "battle/unit/pet_unit"
end
