module("TextureManager", package.seeall)

RES_PATH = {
	PET_AVATAR = "pet/%d.jpg",
	PET_LIST = "pet_list/%d.png" ,
	PET_PORTRAIT = "portrait/%d.png",
	ITEM_AVATAR = "item/item_%d_%d.jpg",
	ACHIEVEMENT_AVATAR = "achievement/achievement%d.jpg",
	BORDER = "cell_item/img_border_%d.png",
	SPINE_ATTACK_EFFECT = "spine/spine_skill_effect/skill_effect_%d",
	SPINE_SUPER_EFFECT = "spine/spine_skill_effect/super_skill_effect",
	SPINE_TARGET_EFFECT = "spine/spine_target_effect/target_effect_%d",
	SPINE_ACTION_EFFECT = "spine/spine_action_effect/action_effect_%d",
	SPINE_PET = "spine/spine_pet/pet%d",
	SPINE_BOSS = "spine/spine_pet/boss_%d",
	SPINE_UNIT = "spine/spine_battle/spine_unit_%d_%d",
	SPINE_SPECIAL_UNIT = "spine/spine_battle/spine_special_unit_%d",
	SPINE_UNIT_BLOCK = "spine/spine_battle/spine_battle_block_%d",
	SPINE_UNIT_ELIMINATE = "spine/spine_battle/spine_unit_eliminate",
	SPINE_ANIM_ELIMINATE = "spine/spine_battle/spine_anim_eliminate",
	SPINE_ELIMINATE_ARROW = "spine/spine_battle/spine_eliminate_arrow",
	SPINE_UNIT_BOMB_EFFECT = "spine/spine_battle/spine_unit_bomb_effect",
	SPINE_UNIT_SPARKLE = "spine/spine_battle/spine_unit_sparkle",
	SPINE_AVATAR_TRASITION = "spine/spine_battle/spine_avatar_transition",
	SPINE_SUPER_BOMB_CONNECT = "spine/spine_battle/spine_super_bomb_connect",
	SPINE_ATTACK_ATLAS = "spine/spine_attack/spine_attack_effect_%d.atlas",
	SPINE_ATTACK_JSON  = "spine/spine_attack/spine_attack_effect_%d.json",
	SPINE_SKILL_ATLAS = "spine/spine_attack/spine_skill_effect_%d.atlas",
	SPINE_SKILL_JSON = "spine/spine_attack/spine_skill_effect_%d.json",
	SPINE_PASSIVE_SKILL = "spine/spine_passive_skill/passive_skill_%d",
	SPINE_SPRITE_BALL = "spine/spine_battle/spine_sprite_ball",
	SPINE_POWER_BREAKTHROUGH = "spine/spine_battle/spine_eliminate_energy_breakthrough",
	SPINE_POWER_ARRIVE = "spine/spine_battle/spine_eliminate_energy_arrive",
	SPINE_BATTLE_MODE_SWITCH = "spine/spine_battle/spine_battle_mode_switch",
	SPINE_BATTLE_COMBO = "spine/spine_battle/spine_battle_combo",
	SPINE_BATTLE_SHUFFLE = "spine/spine_battle/spine_battle_shuffle",
	SPINE_BATTLE_HINT = "spine/spine_battle/spine_battle_hint",
	SPINE_BATTLE_DROP_GOLD = "spine/spine_battle/spine_battle_drop_gold",
	SPINE_PVP1_BOTTOM_ANIM = "spine/spine_pvp1/spine_pvp1_bottom_anim",
	SPINE_HIT = "spine/spine_battle/spine_hit",
	SPINE_DEBUFF = "spine/spine_debuff/spine_debuff_%d",
	SPINE_BUFF = "spine/spine_buff/spine_buff_%d",
	SPINE_MAIN_TIP = "spine/spine_main/spine_main_tip",
	SPINE_LOADING = "spine/spine_main/spine_loading",
	UNIT_SHADOW = "ui_battle/img_unit_shadow.png",
    SPINE_SKILL_NAME_EFFECT = "spine/spine_battle/spine_battle_skill_name",
    PARTICLE_POWER_STAR = "component_separate/particle_power_star.plist",
	PROG_PET_POWER = "ui_battle/prog_pet_power.png",
	PROG_PET_HP = "ui_battle/prog_pet_hp",
	PROG_BOSS_HP = "ui_battle/prog_boss_hp",
	PROG_PET_POWER_BACKGROUND = "ui_battle/prog_pet_power_background_%d.png",
	POWER_LEVEL_DIVIDER = "ui_battle/power_level_divider.png",
	IMG_MISS = "ui_battle/img_miss.png",
	IMG_INCREASE_ICON = "ui_battle/img_increase_icon.png",
	IMG_DECREASE_ICON = "ui_battle/img_decrease_icon.png",
	IMG_ATTRIB_ICON = "ui_battle/img_attrib_icon_%d.png",
	MATRIX_TILE = "ui_battle/img_matrix_tile.png",
	AVATAR_BORDER_BG = "cell_item/img_border_bg.png",
	AVATAR_BORDER = "cell_item/img_border_%d.png",
	BATTLE_BALL = "ui_battle/img_battle_ball_%s_%d.png",
	BATTLE_PET_CAST = "ui_battle/img_pet_cast_effect.png",
	BATTLE_BG = "battle_bg/img_battle_bg_%d_%d.jpg",
	IMG_STAR = "component_common/img_star.png",
	CURRENCY_ICON = "component_common/img_%s.png",
	PLAYER_HEAD = "player/%d.png",
	SKILL_IMG = "skill/%d.png",
	PET_APTITUDE = "ui_pet_list/img_aptitude%d.png",
	PET_CHARACTER = "ui_pet_list/img_character%d.png",
	SETTING_MAIN = "cell_function/img_setting.png",
	ATLAS_MAIN = "cell_function/img_atlas.png",
	RANKING_MAIN = "cell_function/img_ranking.png",
	BAG_MAIN = "cell_function/img_bag.png",
	DEMON_SPINE_ATLAS = "spine/spine_pet/pet%d_f.atlas",
	DEMON_SPINE_JSON = "spine/spine_pet/pet%d_f.json",
	ITEM_IMAGE = "item/item_%d_%d.jpg",
	SPINE_ACTIVITY1_BOY = "spine/spine_activity1/spine_activity1_boy",
	SPINE_ACTIVITY1_GIRL = "spine/spine_activity1/spine_activity1_girl",
	SPINE_ACTIVITY2_EXPLORE = "spine/spine_activity2/spine_activity2_explore",
	SPINE_ACTIVITY2_HAZE = "spine/spine_activity2/spine_activity2_haze",
	ACTIVITY2_MENGJING_PLIST = "spine/spine_activity2/mengjing.plist",
	ACTIVITY2_XIAXUE_PLIST = "spine/spine_activity2/xiaxue.plist",
	SPINE_ACTIVITY2_RAIN = "spine/spine_activity2/spine_activity2_rain",
	BREEDHOUSE_CORNER = "spine/spine_breedhouse/spine_breedhouse_corner",
	BREEDHOUSE_01 = "spine/spine_breedhouse/breedhouse01/rh01_%04d.png",
	BREEDHOUSE_02 = "spine/spine_breedhouse/breedhouse02/rh02_%04d.png",
	BREEDHOUSE_03 = "spine/spine_breedhouse/breedhouse03/rh03_%04d.png",
	MAIN_MAIL = "spine/spine_main/spine_main_mail",
	PET_UPGRADE = "spine/spine_pet_attribute/pet_upgrade/shengji_%04d.png",
	PET_UPSTAR_DOWN = "spine/spine_pet_attribute/pet_upstar/pet_upstar_down/shengxing_%04d.png",
	PET_UPSTAR_UP = "spine/spine_pet_attribute/pet_upstar/pet_upstar_up/shengxing_up_%04d.png",
	CAPTURE = "spine/spine_capture/spine_capture",
	WILD_CIRCLE = "spine/spine_capture/spine_wild_newpet_circle",
	SPINE_TOURNAMENT_SHOP = "spine/spine_tournament/spine_tournament_shop",
	SPINE_TOURNAMENT_PVP1 = "spine/spine_tournament/spine_tournament_pvp1",
	SPINE_TOURNAMENT_PVP2 = "spine/spine_tournament/spine_tournament_pvp2",
	SPINE_MAIN_LOGIN = "spine/spine_main/spine_main_login",
	SPINE_MAIN_LOGO = "spine/spine_main/spine_main_logo",
	PET_SELECT = "component_common/img_select.png",
	IMG_GUIDE  = "component_separate/img_guide.png",
	GUIDETIPS_SCALE9 = "component_separate/img9_guide_tips.png",
	HAND_NORMAL = "component_separate/img_hand_normal.png",
	HAND_SELECT = "component_separate/img_hand_select.png",
	SPINE_GUIDE_DRAG = "spine/spine_guide/spine_guide_drag",
	SPINE_GUIDE_POINT = "spine/spine_guide/spine_guide_point",
	SPINE_BOY = "spine/spine_playersex/spine_playersex_boy",
	SPINE_GIRL = "spine/spine_playersex/spine_playersex_girl",
	IMG_PVP1_BOTTOM_ANIM_BG = "component_separate/img_pvp1_bottom_anim_bg.jpg",
	IMG_ARROW = "component_separate/img_arrow.png",
	PASSIVE_SKILL_IMAGE = "skill/passive_%d.png",
	PRESTIGE = "component_common/img_prestige.png",
	IMG_TIP = "component_common/img_num_bg.png",
	IMG_TALK_BG = "component_separate/img_talk_bg.png",
	BTN_JUMP_NORML = "component_separate/btn_jump_normal.png",
	BTN_JUMP_SELECT = "component_separate/btn_jump_select.png",
}

ATLAS_FONTS = {
	DAMAGE = 1,
	CRIT_DAMAGE = 2,
	HEAL = 3
}

local fontFiles = {
	"fonts/font_damage.png",
	"fonts/font_crit_damage.png",
	"fonts/font_heal.png",
}

local fontParams = {
	{32, 26, 48},
	{50, 40, 48},
	{32, 26, 48},
}

function createImg(pattern, ...)
	local fileName = string.format(pattern, ...)
	local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(fileName)
	if spriteFrame then
		return CImageView:createWithSpriteFrame(spriteFrame)
	end
	return CImageView:create(fileName)
end

function createImg9(size,pattern, ...)
	local fileName = string.format(pattern, ...)
	local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(fileName)
	if spriteFrame then
		return CImageViewScale9:createWithSpriteFrame(spriteFrame)
	end
	return CImageViewScale9:create(size,fileName)
end

function getItemAvatar(item_type, mid)
	local ret = CLayout:create()
	local avatarImg = nil
	
	if (item_type == Constants.ITEM_TYPE.PET) then
	else
		print(TextureManager.RES_PATH.ITEM_AVATAR, item_type, mid)
		avatarImg = createImg(TextureManager.RES_PATH.ITEM_AVATAR, item_type, mid)
	end
	
	ret:setContentSize(avatarImg:getContentSize())

	local itemConfig = ConfigManager.getItemConfig(item_type, mid)
	local border = createImg(TextureManager.RES_PATH.AVATAR_BORDER, itemConfig.quality)
	local s = ret:getContentSize()
	local center = cc.p(s.width/2, s.height/2)

	avatarImg:setPosition(center)
	ret:addChild(avatarImg)

	border:setPosition(center)
	ret:addChild(border)

	return ret
end


function changeLabColor(k,tag,lab) --k 按钮  l 标签  tag  被点击的按钮tag
	if  tag == k then 
		lab:setColor(cc.c3b(0,0,0)) --设置字体颜色
	else
		lab:setColor(cc.c3b(255,255,0))
	end
end

function changeColor(lab,num)  	
	if num == nil then
		lab:setColor(cc.c3b(255,255,0))
	else
		lab:setColor(cc.c3b(0,0,0))
	end
end

function enhanceEffect(node,point,enhanceList) --node为父节点 point为坐标 enhanceList为属性增加值{1，2，3，4，5}
	local k = {
		"生命+" .. enhanceList[1],
		"普防+" .. enhanceList[2],
		"特防+" .. enhanceList[3],
		"普攻+" .. enhanceList[4],
		"特攻+" .. enhanceList[5]
	}
	for i=1,5 do
		local label  = CCLabelTTF:create(k[i],"fonts/FZCuYuan/M03S.ttf",30)
		label:setPosition(point.x,point.y)
		label:setColor(cc.c3b(0,255,0))
		node:addChild(label,10)
		label:setVisible(false)
		local sequence = cc.Sequence:create(cc.DelayTime:create(i*0.5),cc.CallFunc:create(function() label:setVisible(true) end),
			cc.MoveBy:create(0.5,cc.p(0,100)),cc.CallFunc:create(function() label:removeFromParent() end),nil)
		label:runAction(sequence)
	end
end

function getNumberLabelAtlas(fontType, num, interval)
	--todo 优化
	num = math.abs(num)
	local numStr = tostring(num)
	local len = string.len(numStr)
	local container = CLayout:create()
	if fontType == TextureManager.ATLAS_FONTS.CRIT_DAMAGE then
		container:setContentSize(cc.size(40 * len, 26))
	else
		container:setContentSize(cc.size(25 * len, 26))
	end
	for i=1,len do
		local params = fontParams[fontType]
		local lb = CLabelAtlas:create(string.sub(numStr, i, i), fontFiles[fontType], params[1], params[2], params[3])
		lb:setAnchorPoint(cc.p(0, 0))
		lb:setPositionX((i - 1) * interval)
		container:addChild(lb)
	end
	return container
end