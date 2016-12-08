module("DataManager",package.seeall)

AllDataTable = {
	DailyTaskTable = nil, --日常
	DailySignTable = nil, --每日签到
	SuperSignTable = nil ,--豪华签到
	PveNormalStageTable = nil, --pve普通副本
	PveEliteStageTable = nil, --pve精英副本
	BattlePalaceTable = nil, --战斗宫殿
	RouletteTable = nil, --神秘丛林
	PyramidTable = nil,--战斗金字塔
	OrdinaryShopTable =nil,
	SuperShopTable = nil,
	DiamondShopTable = nil,
	BadgeShopTable = nil,
	FameShopTable = nil,


}


function clearAllDataTable() --清空所有数据管理表 
	for k,v in pairs(AllDataTable) do
		v = nil
	end
end





