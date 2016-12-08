module("Constants", package.seeall)

UNIT_SIZE = cc.size(70, 70)
MATRIX_POS = cc.p(40, 11)
MATRIX_COL = 8
MATRIX_ROW = 5
ENEMY_POS = cc.p(40, 560)
ENEMY_COL = 7
ENEMY_ROW = 3
DEMON_ATTACK_INTERVAL = 2
DEMON_ATTACK_INTERVAL_VAR = 5
DEMON_CAST_DURATION = 1.0
PET_SPEED = 1000
TOUCH_SCOPE = 30
DESIGN_SIZE = cc.size(640, 960)
-- APP_ID = "A45D43396B02022544171092FBF11E2E" --demo
APP_ID = "E0827DA68CFF1770BAD974AA55FF1959" -- Pokemon

ITEM_TYPE = {
    ALL = 'all',
	PET = 1, --宠物
	MATERIAL = 2, 	-- 材料
	TREASURE_CHEST = 3,  -- 宝箱 
	EVOLUTION_STONE = 4, -- 进化石
	EXP_POTION = 5,   -- 经验药水 
	ENERGY_POTION = 6, -- 体力药水
	TRAIN_MATERIAL = 7 --训练材料
}

MATERIAL_TYPE = {
	NORMAL_BALL = 1,
	SUPER_BALL = 2,
	SWEEP_CARD = 3
}
--[[
1	生命
2	攻击
3	暴击
4	暴击伤害
5	闪避
6	速度
7	免伤比
8   暴击率
9   闪避率
--]]
PET_ATTRIBUTE = {
	HP = 1,
	COMMON_ATTACK = 2, 
	CRIT = 3,
	CRIT_DAMAGE = 4,
	DODGE = 5,
	SPEED = 6,
	DAMAGE_REDUCE = 7,
	CRIT_RATE = 8,
	DODGE_RATE = 9,
}

TEAM_TYPE = {
	RED = 1,
	BLUE = 2,
	GREEN = 3,
	YELLOW = 4
}

CHEST_TYPE = {
	DIAMOND = 1,
	GOLD = 2,
	PRESTIGE = 3,
	EXP_POTION = 4
}
DUNGEON_TYPE = {
	NORMAL = 1,
	ELITE = 2,
	ACTIVITY1 = 3,
	ACTIVITY3 = 4,
	ACTIVITY2 = 5,
	PVP1 = 6,
}

STAGE_TYPE = {
	NORMAL = 1,
	ELITE = 2
}

SKILL_TYPE = {
	NORMAL = 1,
	SPECIAL = 2
}

SKILL_ATTRIBUTE = {
	ACTIVE = 1,
	PASSIVE = 2
}

OFFSET = 
{
	BAG_OFFSETX = 12,
	BAG_OFFSETY = 12,
	POPUP_OFFSETX = 150
}

SHOP_TYPE = 
{
	NORMAL_SHOP = 1,  --普通
	ADVANCED_SHOP = 2,--高级
	DIAMOND_SHOP = 3, --钻石
	BADGE_SHOP = 4,   --徽章
	PRESTIGE_SHOP = 5,--声望
}

CURRENCY_TYPE = 
{
	DIAMOND = 1,
	GOLD = 2,
	ARENA = 3,
	PAVILION = 4
}
OPEN_TIMES  =
{
	ONCE = 1,
	TENTH = 10
}
GOLDHAND_TYPE = 
{
	ONCE = 1,
	CONTINUOUS = 2
}
COLOR = 
{
	-- 赭石
	OCHRE = cc.c3b(0x63,0x3b,0x28),
	-- 青蓝
	CYANINE = cc.c3b(0x00,0xff,0xcc),
   -- 柠檬
	LEMON = cc.c3b(0xff,0xf6,0x00),
   -- 深灰
	DARK_GRAY = cc.c3b(0x54,0x54,0x54),
   -- 钻石蓝
 	DIAMOND_BLUE = cc.c3b(0x00,0xfc,0xff)
}

APTITUDE_COLOR = 
{
 	--白色
 	cc.c3b(0xff,0xff,0xff),
 	--绿色
 	cc.c3b(0xa6,0xff,0x0b),
 	--蓝色
 	cc.c3b(0x0f,0xe0,0xff),
 	--紫色
 	cc.c3b(0xff,0x00,0xfc),
 	--橙色
 	cc.c3b(0xff,0xa8,0x00),
}

--for more infomation please refer to CocosWidget/WidgetProtocal.h
TOUCH_RET =
{
	NOHANDLE = 0,  --
	TRANSIENT = 1,  --触摸不吞噬
	SUSTAIN = 2  --触摸吞噬
}

GUIDE_TYPE = 
{
	MAIL = 1,
}

ACTIVITY1_TYPE = 
{
	CANDY_AREA = 1, --糖果区
	REGAL_AREA = 2  --土豪区
}
RANK_TYPE = 
{
	NORMAL = 1,
	PVP1 = 2,
	ACTIVITY = 3,
}
DEFAULT_FONT = "fonts/FZCuYuan/M03S.ttf"
