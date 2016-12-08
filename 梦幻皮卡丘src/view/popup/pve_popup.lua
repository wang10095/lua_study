--
-- Author: hapigames
-- Date: 2014-12-03 22:15:10
--
require "view/tagMap/Tag_popup_pve_stage"

PvePopup = class("PvePopup",function()
	return Popup:create()
end)

PvePopup.__index = PvePopup
local __instance = nil
local labSweepCardNum 
local labRemainSweepNum, lab_sweep
local lab_sweeptenth

function PvePopup:create()
	local ret = PvePopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function PvePopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function PvePopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_pve_stage.PANEL_POPUP_PVE then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function PvePopup:onLoadScene()
	local stageRecord     =  StageRecord:getInstance()
	local currentType     =  stageRecord:get("dungeonType")  --当前副本类型
	local currentChapter  =  stageRecord:get("chapter")      --当前章节
	local currentStage    =  stageRecord:get("stage")        --当前关卡
	local remainSweepTimes=  stageRecord:get("remainingtimes")  --剩余战斗次数
	local currentStarNum  =  stageRecord:get("starNum")      --当前星数
	canReset = false
	TuiManager:getInstance():parseScene(self,"panel_popup_pve",PATH_POPUP_PVE_STAGE)	
	local btnClose = self:getControl(Tag_popup_pve_stage.PANEL_POPUP_PVE,Tag_popup_pve_stage.BTN_CLOSE_PVE)
	btnClose:setOnClickScriptHandler(function() 
		if NormalDataProxy:getInstance().updateSweepNum  then
			NormalDataProxy:getInstance().updateSweepNum(remainSweepTimes)
		end
		Utils.popUIScene(self)
	end)
	for i=currentStarNum+1,3 do
		local img_star = self:getControl(Tag_popup_pve_stage.PANEL_POPUP_PVE,Tag_popup_pve_stage["IMG_STAR" .. i])
		img_star:setVisible(false)
	end

	local need_energy
	if currentType == Constants.DUNGEON_TYPE.NORMAL then
		need_energy = ConfigManager.getStageNormalConfig(currentChapter,currentStage).energy_usage
	elseif currentType == Constants.DUNGEON_TYPE.ELITE  then
		need_energy = ConfigManager.getStageEliteConfig(currentChapter,currentStage).energy_usage
	end
	local lab_energy = self:getControl(Tag_popup_pve_stage.PANEL_POPUP_PVE,Tag_popup_pve_stage.LAB_ENERGY)
	lab_energy:setString(need_energy)

	local stageConfig = TextManager.getStageText(currentChapter,currentStage) --关卡信息 

	local labStage = self:getControl(Tag_popup_pve_stage.PANEL_POPUP_PVE,Tag_popup_pve_stage.LAB_STAGE_NAME)
	local labDesc = self:getControl(Tag_popup_pve_stage.PANEL_POPUP_PVE,Tag_popup_pve_stage.LAB_STAGE_DESC)
	-- print("===stage==" .. currentChapter ,currentStage)
	labStage:setString(tostring(currentChapter.."-"..currentStage..": "..stageConfig.name))
	labDesc:setString(tostring(stageConfig.info))

	local elite_nums = ConfigManager.getStageCommonConfig('elite_nums')
	local stagerewardConfig 
	if currentType == Constants.DUNGEON_TYPE.NORMAL then
		stagerewardConfig = ConfigManager.getTable("stage_reward_normal","chapter",currentChapter,currentStage)
	elseif currentType == Constants.DUNGEON_TYPE.ELITE  then
		stagerewardConfig = ConfigManager.getTable("stage_reward_elite","chapter",currentChapter,currentStage)
	end

	local itemShowTable = {}
	for i,v in ipairs(stagerewardConfig) do
		for k,m in pairs(v) do
			if k == 'isShow' and m == 1 then
				table.insert(itemShowTable,v)
			end
		end
	end

	local layoutItem = self:getControl(Tag_popup_pve_stage.PANEL_POPUP_PVE,Tag_popup_pve_stage.LAYOUT_REWARD_ITEM)
	for i=1,#itemShowTable do
		local layout_item = layoutItem:getChildByTag(Tag_popup_pve_stage["LAYOUT_REWARDITEM_"..i])
		if itemShowTable[i]["item_type"] == 1 then  --宠物
	    	local pet = Pet:create()
	        pet:set("id", 1)
	        pet:set("mid", itemShowTable[i]["mid"])
	        pet:set("form", 1)
	        pet:set("aptitude", 5)
		    local pCell = PetCell:create(pet)
		    Utils.addCellToParent(pCell,layout_item,true)
		    pCell:setPositionY(pCell:getPositionY()-2)
			Utils.showPetInfoTips(layout_item, pet:get("mid"), pet:get("form"))
		else    --物品
			local item = ItemManager.createItem(itemShowTable[i]["item_type"], itemShowTable[i]["mid"])
			local cell = ItemCell:create(itemShowTable[i]["item_type"],item)
			Utils.addCellToParent(cell,layout_item,true)
			Utils.showItemInfoTips(layout_item, item)
		end
	end
	
	local function event_battle( p_sender ) --开始战斗
		if Player:getInstance():get("energy") < need_energy then
			Utils.buyEnergy()		
			return
		end
		if currentType == Constants.DUNGEON_TYPE.ELITE and remainSweepTimes<=0 then
			TipManager.showTip("挑战次数已用完 请重置!")
			return
		end
 		Utils.popUIScene(__instance,NormalDataProxy:getInstance().pveBattle)
 		NormalDataProxy:getInstance().pveBattle = nil
 	end

	local btnChange = self:getControl(Tag_popup_pve_stage.PANEL_POPUP_PVE,Tag_popup_pve_stage.BTN_CHANGE)
	btnChange:setOnClickScriptHandler(event_battle)
	local img9_pvepopup_bg1 = self:getControl(Tag_popup_pve_stage.PANEL_POPUP_PVE,Tag_popup_pve_stage.IMG9_PVEPOPUP_BG1)
	img9_pvepopup_bg1:setOpacity(190)
	---------------------扫荡
	local layoutElite = self:getControl(Tag_popup_pve_stage.PANEL_POPUP_PVE,Tag_popup_pve_stage.LAYOUT_ELITE)
	local layoutSweep = self:getControl(Tag_popup_pve_stage.PANEL_POPUP_PVE,Tag_popup_pve_stage.LAYOUT_SWEEP)
	local recordChapter = Player:getInstance():get("normalChapterId")
	local recordStage = Player:getInstance():get("normalStageId")
	local btnSweep = layoutSweep:getChildByTag(Tag_popup_pve_stage.BTN_SWEEP)
	local btnSweepTenth = layoutSweep:getChildByTag(Tag_popup_pve_stage.BTN_SWEEPNUM)
	lab_sweep = layoutSweep:getChildByTag(Tag_popup_pve_stage.LAB_SWEEP)
	local function event_sweep_stage(result)
		ItemManager.updateItem(Constants.ITEM_TYPE.MATERIAL,Constants.MATERIAL_TYPE.SWEEP_CARD,result["left_sweepcard_num"])
		labSweepCardNum:setString(result["left_sweepcard_num"])  --更新剩余扫荡卡数量
		if currentType == Constants.DUNGEON_TYPE.ELITE then  --精英副本 修改剩余扫荡次数
			remainSweepTimes = result["left_times"]
			if remainSweepTimes >0 then
				btnSweepTenth:setEnabled(true)
				lab_sweeptenth:setString("扫荡" .. remainSweepTimes .."次")
			else
				btnSweepTenth:setEnabled(false)
			end
			stageRecord:set("remainingtimes",remainSweepTimes)
			labRemainSweepNum:setString(remainSweepTimes .. '/' .. elite_nums) --剩余扫荡次数 
			if remainSweepTimes <= 0 and currentType == Constants.DUNGEON_TYPE.ELITE then
				lab_sweep:setString("重置")
			else
				lab_sweep:setString("扫荡")
			end  
		end 
		Stagedataproxy:getInstance().StageList = result   --在下一个扫荡结果弹窗 更新
		if stageRecord:get("sweeptimes")==1 then
			if #result["pets"]~=0 then
				local proxy = Stagedataproxy:getInstance()
				Stagedataproxy.StageList = result["pets"]
				proxy:set("CapturePetNum",1)
				Utils.runUIScene("CapturePetPopup")
			else
				Utils.runUIScene("SweepOncePopup")
			end
		else
			if #result["pets"]~=0 then
				local proxy = Stagedataproxy:getInstance()
				Stagedataproxy.StageList = result["pets"]
				proxy:set("CapturePetNum",1)
				Utils.runUIScene("CapturePetPopup")
			else
				Utils.runUIScene("SweepPopup")
			end
		end
	end

	if currentStarNum == 3 then    --满3星才可以扫荡 
		local function event_sweep( p_sender ) 
			if currentType == Constants.DUNGEON_TYPE.ELITE and remainSweepTimes<=0  then --判断是否需要重置  
				local proxy = NormalDataProxy:getInstance()
				proxy:set("title",'精英关重置')
				local elite_reset_limit = ConfigManager.getVipConfig(Player:getInstance():get("vip")).elite_reset_num --重置次数上限
				local resetCost = ConfigManager.getStageCommonConfig('reset_elite_diamond') --重置消耗{}
			
				local hadResetNum = elite_reset_limit - Player:getInstance():get("resetEliteNum")
				local cost = 0
				if hadResetNum >=#resetCost then
					cost = resetCost[#resetCost]
				else
					cost = resetCost[hadResetNum+1]
				end
				proxy:set("content",'是否花费' .. cost .. '钻石重置关卡\n今天已重置了' .. hadResetNum  .. '次')
				local function confirmHandler()
					if Player:getInstance():get("diamond")<cost then
						Utils.useRechargeDiamond()
					else
						if Player:getInstance():get("resetEliteNum") <=0 then
							if Player:getInstance():get("vip")>=15 then
								TipManager.showTip("今日重置次数已用完")
							else
								Utils.useRechargeDiamond("VIP等级不足","是否提升VIP等级以获得更多重置次数?")
							end
						else
							local function event_reset(result)
								Player:getInstance():set("diamond",result["diamond"])
								Player:getInstance():set("resetEliteNum",result["left_reset_times"])
								remainSweepTimes = result["times"]
								if remainSweepTimes >0 then
									btnSweepTenth:setEnabled(true)
									lab_sweeptenth:setString("扫荡" .. remainSweepTimes .."次")
								else
									btnSweepTenth:setEnabled(false)
								end
								labRemainSweepNum:setString(remainSweepTimes .. '/' .. elite_nums) --剩余扫荡次数 
								lab_sweep:setString("扫荡")
							end
							NetManager.sendCmd("resetstage",event_reset,currentType,currentChapter,currentStage)
						end	
					end
				end
				proxy.confirmHandler = confirmHandler
				Utils.runUIScene("NormalPopup")
				return
			end

			local sweepCardNum = ItemManager.getItemAmount(Constants.ITEM_TYPE.MATERIAL,Constants.MATERIAL_TYPE.SWEEP_CARD)
			if sweepCardNum <=0 then     --扫荡卡不足
				local diamondSweepNum = ConfigManager.getStageCommonConfig('sweep_diamond')
				local proxy = NormalDataProxy:getInstance()
				proxy:set("title",'扫荡卡不足')
				proxy:set("content",'是否花费' .. diamondSweepNum .. '钻石进行扫荡')
				local function confirmHandler()
					if Player:getInstance():get("diamond")<diamondSweepNum then
						Utils.useRechargeDiamond()
					else
						if Player:getInstance():get("energy") < need_energy then
							Utils.buyEnergy()
						else
							stageRecord:set("sweeptimes",1) --扫荡次数
							NetManager.sendCmd("sweepstage",event_sweep_stage,currentType,currentChapter,currentStage,1)
						end
					end
				end
				proxy.confirmHandler = confirmHandler
				Utils.runUIScene("NormalPopup")
				return
			end

			if Player:getInstance():get("energy") < need_energy then --体力不足
				Utils.buyEnergy()
				return
			end
			stageRecord:set("sweeptimes",1) --扫荡次数
			NetManager.sendCmd("sweepstage",event_sweep_stage,currentType,currentChapter,currentStage,1)
		end

		local function event_sweepFive( p_sender )
			local sweeplimitvip = ConfigManager.getRechargeCommonConfig('vip_level_sweep5')
			if Player:getInstance():get("vip")<sweeplimitvip then
				TipManager.showTip("VIP等级" .. sweeplimitvip .. "后开放")
				return
			end
			local sweepNum 
			if currentType == Constants.DUNGEON_TYPE.ELITE then
				sweepNum = remainSweepTimes
			else
				sweepNum = 5
			end
			local sweepCardNum = ItemManager.getItemAmount(Constants.ITEM_TYPE.MATERIAL,Constants.MATERIAL_TYPE.SWEEP_CARD)
			if sweepCardNum <sweepNum then --扫荡卡不足
				local diamondSweepNum = ConfigManager.getStageCommonConfig('sweep_diamond')
				local need_diamond = (sweepNum-sweepCardNum)*diamondSweepNum
				local proxy = NormalDataProxy:getInstance()
				proxy:set("title",'扫荡卡不足')
				proxy:set("content",'是否花费' .. need_diamond .. '钻石进行扫荡')
				local function confirmHandler()
					if Player:getInstance():get("diamond")<need_diamond then
						Utils.useRechargeDiamond()
					else
						if Player:getInstance():get("energy") < need_energy*sweepNum then --体力不足
							Utils.buyEnergy()
						else
							stageRecord:set("sweeptimes",sweepNum) --扫荡次数
							NetManager.sendCmd("sweepstage",event_sweep_stage,currentType,currentChapter,currentStage,sweepNum)
						end
					end
				end
				proxy.confirmHandler = confirmHandler
				Utils.runUIScene("NormalPopup")
				return
			end
			-- print("====energy=need=" ..need_energy, sweepNum,need_energy*sweepNum )
			if Player:getInstance():get("energy") < need_energy*sweepNum then --体力不足
				Utils.buyEnergy()
				return
			end
			stageRecord:set("sweeptimes",sweepNum) --扫荡次数
			NetManager.sendCmd("sweepstage",event_sweep_stage,currentType,currentChapter,currentStage,sweepNum)
		end
		
		btnSweep:setOnClickScriptHandler(event_sweep)
		btnSweepTenth:setOnClickScriptHandler(event_sweepFive)
		lab_sweeptenth = layoutSweep:getChildByTag(Tag_popup_pve_stage.LAB_SWEEPTENTH)
		if currentType == Constants.DUNGEON_TYPE.ELITE then  --精英关扫荡次数 不超过3次	
			if remainSweepTimes<=0 then
				lab_sweeptenth:setString("扫荡" .. 3 .. "次")
				btnSweepTenth:setEnabled(false)
			else
				lab_sweeptenth:setString("扫荡" .. remainSweepTimes  .. "次")
				btnSweepTenth:setEnabled(true)
			end
		end

		labSweepCardNum = layoutSweep:getChildByTag(Tag_popup_pve_stage.LAB_CARDNUM)
		local sweepCardNum = ItemManager.getItemAmount(Constants.ITEM_TYPE.MATERIAL,Constants.MATERIAL_TYPE.SWEEP_CARD)
		labSweepCardNum:setString(sweepCardNum)
	else
		layoutSweep:setVisible(false)
		layoutElite:setVisible(false)
	end

	if currentType == Constants.DUNGEON_TYPE.ELITE then  --只有精英副本才有扫荡次数限制  
		labRemainSweepNum = layoutElite:getChildByTag(Tag_popup_pve_stage.LAB_REMAINNUM)
		labRemainSweepNum:setString(remainSweepTimes .. "/" .. elite_nums)
		layoutElite:setVisible(true)
	else
		layoutElite:setVisible(false)
	end
	
	local function onNodeEvent(event)
		if "enter" == event then
			self:show()
			Stagedataproxy:getInstance():set("isPopup",true)
		end
		if "enterTransitionFinish"  == event then
			StageRecord:getInstance():set("old_level",Player:getInstance():get("level")) 
			if GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.PVE2  or GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.PVE3 then
				Utils.dispatchCustomEvent("event_enter_view",{view = "PveUI",phase = GuideManager.MAIN_GUIDE_PHASES.PVE3 ,scene = self})
				GuideManager.main_guide_phase_ = GuideManager.MAIN_GUIDE_PHASES.STAGE_2
			end
			if GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.PVE_STAGE3 or GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.PVE_POPUP then
				Utils.dispatchCustomEvent("event_enter_view",{view = "PveUI",phase = GuideManager.MAIN_GUIDE_PHASES.PVE_POPUP ,scene = self})
				GuideManager.main_guide_phase_ = GuideManager.MAIN_GUIDE_PHASES.STAGE_3
			end
			if StageRecord:getInstance():get("dungeonType") == 2 and StageRecord:getInstance():get("chapter") == 1 and StageRecord:getInstance():get("stage") ==1 then
				Utils.dispatchCustomEvent("event_elite_stage",{view = "PvePopup",phase =GuideManager.FUNC_GUIDE_PHASES.ELITE_STAGE1,scene = self})
			end
		end
		if "exit" == event then
	    	Stagedataproxy:getInstance():set("isPopup",false)
		end
	end
	self:registerScriptHandler(onNodeEvent)

	TouchEffect.addTouchEffect(self)

	if remainSweepTimes <= 0 and currentType == Constants.DUNGEON_TYPE.ELITE then
		lab_sweep:setString("重置")
	else
		lab_sweep:setString("扫荡")
	end

	--------
	-- Player:getInstance():set("energy",0)
	--------
end