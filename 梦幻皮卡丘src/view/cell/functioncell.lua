require "view/tagMap/Tag_cell_function"

FunctionCell= class("FunctionCell",function()
	return CLayout:create()
end)

FunctionCell.__index = FunctionCell
local __instance = nil

function FunctionCell:create()
	local ret = FunctionCell.new()
	__instance = ret
	TuiManager:getInstance():parseCell(__instance,"cell_function",PATH_CELL_FUNCTION)
	__instance:init()
	return ret
end

function FunctionCell:getControl(tagControl)
	local ret = nil
	ret = self:getChildByTag(tagControl)
	return ret
end

---------------logic----------------------------
local function event_setting(p_sender)
	Utils.runUIScene("SettingPopup")
	return false
end

local function event_atlas(p_sender)
	local function loadatlas( result )
		AtlasDataProxy.atlasList = result["pet"]
		Utils.replaceScene("AtlasUI")
	end
	NetManager.sendCmd("loadatlas",loadatlas)
	
	return false
end

local function event_ranking(p_sender)
	RankDataProxy:getInstance():set("rank_type",Constants.RANK_TYPE.NORMAL)
	Utils.replaceScene("RankUI")
	return false
end


local function event_bag(p_sender)
	
	Utils.runUIScene("BagPopup")
	return false
end


function FunctionCell:dtor()
	local stagerecord = StageRecord:getInstance()
 	stagerecord:resetUpdate()

 	local player = Player:getInstance()
 	player:resetUpdate()
end


function FunctionCell:init()
	local pikachu = self:getControl(Tag_cell_function.LAYOUT_PIKACHU)
	Spine.addSpine(pikachu,"main","pikachu","part1",true)
	local layout_setting = self:getControl(Tag_cell_function.LAYOUT_SETTING)
	
	local layout_atlas = self:getControl(Tag_cell_function.LAYOUT_ATLAS)

	local layout_ranking = self:getControl(Tag_cell_function.LAYOUT_RANKING)

	local layout_bag = self:getControl(Tag_cell_function.LAYOUT_BAG)
	local state = 1
	local function touchPikachuBegan( touch,p_sender )
		pikachu:removeAllChildren()
		if state == 1 then
			Spine.spineMix(pikachu,"main","pikachu","part2","part3",false,true)
			
			local settingImg = TextureManager.createImg(TextureManager.RES_PATH.SETTING_MAIN)
			Utils.addCellToParent(settingImg,layout_setting)
			layout_setting:setScale(0.001)
			layout_setting:runAction(cc.Sequence:create(cc.ScaleTo:create(0.4,0.1),cc.ScaleTo:create(0.2,1.2),cc.ScaleTo:create(0.2,0.8)))
			
			local atlasImg = TextureManager.createImg(TextureManager.RES_PATH.ATLAS_MAIN)
			Utils.addCellToParent(atlasImg,layout_atlas)
			layout_atlas:setScale(0.001)
			layout_atlas:runAction(cc.Sequence:create(cc.ScaleTo:create(0.4,0.1),cc.ScaleTo:create(0.2,1.2),cc.ScaleTo:create(0.2,0.8)))
			
			local rankingImg = TextureManager.createImg(TextureManager.RES_PATH.RANKING_MAIN)
			Utils.addCellToParent(rankingImg,layout_ranking)
			layout_ranking:setScale(0.001)
			layout_ranking:runAction(cc.Sequence:create(cc.ScaleTo:create(0.4,0.1),cc.ScaleTo:create(0.2,1.2),cc.ScaleTo:create(0.2,0.8)))

			local bagImg = TextureManager.createImg(TextureManager.RES_PATH.BAG_MAIN)
			Utils.addCellToParent(bagImg,layout_bag)
			layout_bag:setScale(0.001)
			layout_bag:runAction(cc.Sequence:create(cc.ScaleTo:create(0.4,0.1),cc.ScaleTo:create(0.2,1.2),cc.ScaleTo:create(0.2,0.8)))
			layout_setting:setOnTouchBeganScriptHandler(event_setting)

			layout_atlas:setOnTouchBeganScriptHandler(event_atlas)
	
			layout_ranking:setOnTouchBeganScriptHandler(event_ranking)
		
			layout_bag:setOnTouchBeganScriptHandler(event_bag)
			state = 2
		elseif state == 2 then
			
			Spine.spineMix(pikachu,"main","pikachu","part4","part1",false,true)
			pikachu:runAction(cc.Sequence:create(spine4,cc.DelayTime:create(1.0),spine1))
			layout_setting:removeAllChildren()
			layout_atlas:removeAllChildren()
			layout_ranking:removeAllChildren()
			layout_bag:removeAllChildren()
			state =1
		end
		return true
	end 
	
	local touchPikachu = self:getControl(Tag_cell_function.LAYOUT_TOUCH)
	touchPikachu:setOnTouchBeganScriptHandler(touchPikachuBegan)
	
	Utils.floatToBottom(self)
end