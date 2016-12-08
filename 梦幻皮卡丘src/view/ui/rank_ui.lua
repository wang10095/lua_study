require "view/tagMap/Tag_ui_rank"

RankUI = class("RankUI", function ()
	return TuiBase:create()
end)

RankUI.__index = RankUI
local __instance = nil
local items = nil
local listRank = nil
local layoutBottom

function RankUI:create()
    local ret = RankUI.new()
    __instance = ret 
    ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
    return ret
end

function RankUI:getControl(tagPanel, tagControl)
	local ret = nil
	ret  = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function RankUI:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_rank.PANEL_RANK then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_return(p_sender)
	local rank_type = RankDataProxy:getInstance():get("rank_type")
	if rank_type == Constants.RANK_TYPE.ACTIVITY then
		Utils.replaceScene("PyramidUI",__instance)
	elseif rank_type == Constants.RANK_TYPE.PVP1 then
		Utils.replaceScene("SilverChampionshipUI",__instance)
	elseif rank_type == Constants.RANK_TYPE.NORMAL then
		Utils.replaceScene("MainUI",__instance)
	end
end

function RankUI:event_pvp_rank()
	local layoutSelfRank = layoutBottom:getChildByTag(Tag_ui_rank.LAYOUT_SELFRANK)
	layoutSelfRank:setVisible(true)
	local lab_rank_self = layoutSelfRank:getChildByTag(Tag_ui_rank.LAB_RANK_SELF)
	local lab_challenge_num = layoutSelfRank:getChildByTag(Tag_ui_rank.LAB_CHALLENGE_NUM)
	lab_challenge_num:setVisible(false)
	local lab_challenge_tips = layoutSelfRank:getChildByTag(Tag_ui_rank.LAB_CHALLENGE_TIPS)
	lab_challenge_tips:setVisible(false)
	local function loadpvp1rank( result )
		if result["rank_self"] <=0 then
			lab_rank_self:setString("未上榜")
      	else
      		lab_rank_self:setString(result["rank_self"])
      	end
		listRank:removeAllNodes()
		local count = listRank:getNodeCount()
		local cellHeight
		while count < #result["rank"] do
			local pCell = CGridViewCell:new()
			TuiManager:getInstance():parseCell(pCell, "cell_pvp", PATH_UI_RANK)
			cellHeight = pCell:getContentSize().height
			listRank:insertNodeAtLast(pCell)
			count = listRank:getNodeCount()
		end
		listRank:reloadData()
		listRank:setContentOffset(cc.p(0,-1 * #result["rank"]*cellHeight+listRank:getContentSize().height))
		for k = 1,#result["rank"] do  
			local node = listRank:getNodeAtIndex(k-1)
			local playerName = node:getChildByTag(Tag_ui_rank.LAB_PVP_PLAYER_NAME)
			local labLevel = node:getChildByTag(Tag_ui_rank.LAB_PLAYER_LEVEL)
			local layoutHead = node:getChildByTag(Tag_ui_rank.LAYOUT_PVP_HEAD)
			local layout_pvp_rank = node:getChildByTag(Tag_ui_rank.LAYOUT_PVP_RANK)
			local imgGoldCup = node:getChildByTag(Tag_ui_rank.IMG_GOLDCUP_PVP)
			local imgSilverCup = node:getChildByTag(Tag_ui_rank.IMG_SILVERCUP_PVP)
			local imgCopperCup = node:getChildByTag(Tag_ui_rank.IMG_COPPERCUP_PVP)

			playerName:setString(result["rank"][k].name)
			labLevel:setString(result["rank"][k].level)
			if k==1 then
				imgGoldCup:setVisible(true)
				imgSilverCup:setVisible(false)
				imgCopperCup:setVisible(false)
				local playerHead = TextureManager.createImg(TextureManager.RES_PATH.PLAYER_HEAD,result["rank"][k]["role"])
				Utils.addCellToParent(playerHead,layoutHead)
			elseif k==2 then
				imgGoldCup:setVisible(false)
				imgSilverCup:setVisible(true)
				imgCopperCup:setVisible(false)
				local playerHead = TextureManager.createImg(TextureManager.RES_PATH.PLAYER_HEAD,result["rank"][k]["role"])
				Utils.addCellToParent(playerHead,layoutHead)
			elseif k==3 then
				imgGoldCup:setVisible(false)
				imgSilverCup:setVisible(false)
				imgCopperCup:setVisible(true)
				local playerHead = TextureManager.createImg(TextureManager.RES_PATH.PLAYER_HEAD,result["rank"][k]["role"])
				Utils.addCellToParent(playerHead,layoutHead)
			else   --其他玩家的排名
				for i=1,#tostring(result["rank"][k].ranking) do
					local num = string.sub(tostring(result["rank"][k].ranking),i,i)
					local img = TextureManager.createImg("ui_rank/%d.png",num)
					img:setPosition(cc.p((i-1)*35,0))
					layout_pvp_rank:addChild(img,10)
				end
				imgGoldCup:setVisible(false)
				imgSilverCup:setVisible(false)
				imgCopperCup:setVisible(false)
				local playerHead = TextureManager.createImg(TextureManager.RES_PATH.PLAYER_HEAD,result["rank"][k]["role"])
				Utils.addCellToParent(playerHead,layoutHead)	
			end

			local noMove = true
			local xx,yy = nil,nil
			local listener = cc.EventListenerTouchOneByOne:create()
			listener:registerScriptHandler(function(touch,event)
				local selfLocation = __instance:convertTouchToNodeSpace(touch)
				xx,yy = selfLocation.x,selfLocation.y
				local cellLocation = node:convertTouchToNodeSpace(touch)
				local size = node:getContentSize()
				local winSize = cc.Director:getInstance():getWinSize()
				local addYY = (1136 - winSize.height)/2
				if size and yy >addYY  and yy < 820 and cellLocation.x>0 and cellLocation.y>0 and cellLocation.x<size.width and cellLocation.y<size.height then
					return true
				end
			end,cc.Handler.EVENT_TOUCH_BEGAN )   
			listener:registerScriptHandler(function(touch,event)
				local selfLocation = __instance:convertTouchToNodeSpace(touch)
				local distanceX =   math.abs(math.floor(selfLocation.x - xx))
				local distanceY =   math.abs(math.floor(selfLocation.y - yy))
				if distanceX > 30 or distanceY >30 then
					noMove = false
				end
			end,cc.Handler.EVENT_TOUCH_MOVED)
			listener:registerScriptHandler(function(touch,event)
				local selfLocation = __instance:convertTouchToNodeSpace(touch)
				if noMove then
					RankDataProxy:getInstance():set("level",result["rank"][k]["level"])
					RankDataProxy:getInstance():set("name",result["rank"][k]["name"])
					RankDataProxy:getInstance():set("role",result["rank"][k]["role"])
					Utils.runUIScene("RankPowerContentPopup")
				end
				noMove = true
			end,cc.Handler.EVENT_TOUCH_ENDED )  
			local eventDispatcher = node:getEventDispatcher() -- 时间派发器 
			eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
		end
	end
	NetManager.sendCmd("loadpvp1rank",loadpvp1rank)
end

function RankUI:loadactivity3rank()
	local layoutSelfRank = layoutBottom:getChildByTag(Tag_ui_rank.LAYOUT_SELFRANK)
	layoutSelfRank:setVisible(true)
	local lab_rank_self = layoutSelfRank:getChildByTag(Tag_ui_rank.LAB_RANK_SELF)
	local lab_challenge_num = layoutSelfRank:getChildByTag(Tag_ui_rank.LAB_CHALLENGE_NUM)
	lab_challenge_num:setVisible(true)
	local lab_challenge_tips = layoutSelfRank:getChildByTag(Tag_ui_rank.LAB_CHALLENGE_TIPS)
	lab_challenge_tips:setVisible(true)
	local function loadactivityrank(result)
      	--   RankDataProxy.arenarank = result
      	if result["rank_self"] <=0 then
			lab_rank_self:setString("未上榜")
      	else
      		lab_rank_self:setString(result["rank_self"])
      	end
      	if result["tier"]<=0 then
      		lab_challenge_num:setString("1")
      	else
      		lab_challenge_num:setString(result["tier"])
      	end
     	local rank_= result
     	local labRankSelf = layoutSelfRank:getChildByTag(Tag_ui_rank.LAB_RANK_SELF)
		labRankSelf:setString(rank_.rank_self)
		local labChallengeNum = layoutSelfRank:getChildByTag(Tag_ui_rank.LAB_CHALLENGE_NUM)
		labChallengeNum:setString(rank_.tier)

		local rank = result["rank"]
		listRank:removeAllNodes()
		local count = listRank:getNodeCount()
		local cellHeight
		while count < #rank do
			local pCell = CGridViewCell:new()
			TuiManager:getInstance():parseCell(pCell, "cell_activity", PATH_UI_RANK)
			cellHeight = pCell:getContentSize().height
			listRank:insertNodeAtLast(pCell)
			count = listRank:getNodeCount()
		end
		listRank:reloadData()
		listRank:setContentOffset(cc.p(0,-1 * #rank*cellHeight+listRank:getContentSize().height))
		for k = 1,#rank do  
			local node = listRank:getNodeAtIndex(k-1)
			local imgGoldCup = node:getChildByTag(Tag_ui_rank.IMG_GOLDCUP)
			local imgSilverCup = node:getChildByTag(Tag_ui_rank.IMG_SILVERCUP)
			local imgCopperCup = node:getChildByTag(Tag_ui_rank.IMG_COPPERCUP)
			local layout_activity_rank = node:getChildByTag(Tag_ui_rank.LAYOUT_ACTIVITY_RANK)
			local layoutHead = node:getChildByTag(Tag_ui_rank.LAYOUT_ACTIVITY_PLAYER)
			local playerName = node:getChildByTag(Tag_ui_rank.LAB_PLAYER_NAME_ACTIVITY)
			playerName:setString(rank[k].name)
			local playerlevel = node:getChildByTag(Tag_ui_rank.LAB_LEVEL_ACTIVITY)
			playerlevel:setString(rank[k].level)
			local lab_tiernum_activity = node:getChildByTag(Tag_ui_rank.LAB_TIERNUM_ACTIVITY_NUM) 
			lab_tiernum_activity:setString(rank[k].tiernum)

			if k == 1 then
				imgSilverCup:setVisible(false)
				imgCopperCup:setVisible(false)
				local playerHead = TextureManager.createImg(TextureManager.RES_PATH.PLAYER_HEAD,result["rank"][k]["role"])
				Utils.addCellToParent(playerHead,layoutHead)
				lab_tiernum_activity:setString(result["rank"][k]["tiernum"])
			elseif k== 2 then
				imgGoldCup:setVisible(false)
				imgCopperCup:setVisible(false)
				local playerHead = TextureManager.createImg(TextureManager.RES_PATH.PLAYER_HEAD,result["rank"][k]["role"])
				Utils.addCellToParent(playerHead,layoutHead)
				lab_tiernum_activity:setString(result["rank"][k]["tiernum"])
			elseif k== 3 then
				imgSilverCup:setVisible(false)
				imgGoldCup:setVisible(false)
				local playerHead = TextureManager.createImg(TextureManager.RES_PATH.PLAYER_HEAD,result["rank"][k]["role"])
				Utils.addCellToParent(playerHead,layoutHead)
				lab_tiernum_activity:setString(result["rank"][k]["tiernum"])
			else
				for i=1,#tostring(rank[k].ranking) do
					local num = string.sub(tostring(rank[k].ranking),i,i)
					local img = TextureManager.createImg("ui_rank/%d.png",num)
					img:setPosition(cc.p((i-1)*35,0))
					layout_activity_rank:addChild(img,10)
				end
				imgSilverCup:setVisible(false)
				imgGoldCup:setVisible(false)
				imgCopperCup:setVisible(false)
				local playerHead = TextureManager.createImg(TextureManager.RES_PATH.PLAYER_HEAD,result["rank"][k]["role"])
				Utils.addCellToParent(playerHead,layoutHead)
				lab_tiernum_activity:setString(result["rank"][k]["tiernum"])
			end
		end
    end
    NetManager.sendCmd("loadactivity3rank",loadactivityrank)
end

function RankUI:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_rank",PATH_UI_RANK)
	layoutTop = self:getControl(Tag_ui_rank.PANEL_RANK,Tag_ui_rank.LAYOUT_TOP)
	Utils.floatToTop(layoutTop)

	layoutBottom = self:getControl(Tag_ui_rank.PANEL_RANK,Tag_ui_rank.LAYOUT_BOTTOM)
	Utils.floatToBottom(layoutBottom)

	local layoutTgv = layoutTop:getChildByTag(Tag_ui_rank.LAYOUT_TGV)
	listRank =layoutTop:getChildByTag(Tag_ui_rank.LIST_RANK)
	
	local rank_type = RankDataProxy:getInstance():get("rank_type")
	if rank_type == Constants.RANK_TYPE.ACTIVITY then
		self:loadactivity3rank()
	else
		self:event_pvp_rank()
	end
	local btnReturn = layoutBottom:getChildByTag(Tag_ui_rank.BTN_RETURN)
	btnReturn:setOnClickScriptHandler(event_return)

	local btnPvpRank = layoutTgv:getChildByTag(Tag_ui_rank.TGV_LEFT)
	local tgvActivity = layoutTgv:getChildByTag(Tag_ui_rank.TGV_PVP1)
	btnPvpRank:setOnClickScriptHandler(self.event_pvp_rank)
	tgvActivity:setOnClickScriptHandler(self.loadactivity3rank)
	btnPvpRank:setChecked(true)
	
	TouchEffect.addTouchEffect(self)
end
