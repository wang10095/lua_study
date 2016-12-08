module("NpcTalkManager", package.seeall)

SCENE = {
	Pokemon = 1,
	EnergyRecover = 2,
	Pvp = 3,
	NormalShop = 4,
	SuperShop = 5,
	NormalBreed = 6,
	SpecialBreed = 7,
	Inherit = 8
}

TALK_TYPE = {
	NORMAL = 1,
	TOUCH = 2,
	INTERCAL = 3
}

local isShow = false
local label_ = nil
local id_ = 0
local scene_ = nil
local node_ = nil


function initTalk( lab,ID )
	label_ = lab
	id_ = ID
	lab:stopAllActions()
	local initTalkText = string.format(TextManager.getNPCtext(id_,NpcTalkManager.TALK_TYPE.NORMAL,1),"潇梦缘")
	for i=1,#initTalkText do  --字一个个出现
		local sequence = cc.Sequence:create(cc.DelayTime:create(i*0.03),cc.CallFunc:create(function() 
			label_:setString(string.sub(initTalkText,1,i))
		end))
		label_:runAction(sequence)
	end
	lab:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()
		setNPCIntervalTotalk(label_,id_)
	end)))
end

function setNPCTouch( scene,node,lab,ID)
	label_ = lab
	id_ = ID
	scene_ = scene
	node_ = node

	print("npc 指引 "..id_ .."   "..TALK_TYPE.TOUCH)
	local y_ = {
		{-50,500},
		{400,540},
		{300,1200},
		{0,470},
		{0,470},
		{250,460},
		{250,460},
		{250,460},
	}
	
	local index = 1
	local talkContent 
	local amount = TextManager.getNPCtextAmount(id_,TALK_TYPE.TOUCH)
	print(" 个数 "..#amount)

	local layoutTouch = CLayout:create()
	local size = node_:getContentSize()
	local pos_ = cc.p(node_:getPosition())
	layoutTouch:setContentSize(size)
	-- layoutTouch:setBackgroundColor(cc.c4b(0,0,0,150))
	layoutTouch:setPosition(cc.p(pos_.x+y_[ID][1],pos_.y+y_[ID][2]))
	if id_ == SCENE.EnergyRecover then
		layoutTouch:setScale(0.4)
	end
	scene_:addChild(layoutTouch,1)
	
	layoutTouch:setOnTouchBeganScriptHandler(function ( )
		if not isShow then
			if index > #amount then
				index = 1
			end
			label_:stopAllActions()
			local talkContent = TextManager.getNPCtext(id_,TALK_TYPE.TOUCH,index,nil)
			for i=1,#talkContent do  --字一个个出现
				local sequence = cc.Sequence:create(cc.DelayTime:create(i*0.03),cc.CallFunc:create(function() 
					label_:setString(string.sub(talkContent,1,i))
					if i == #talkContent then
						isShow = false
					else
						isShow = true
					end
				end))
				label_:runAction(sequence)
			end
			index = index + 1
		else
			isShow = false
		end
		label_:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()
			setNPCIntervalTotalk(label_,id_)
		end)))
		return false
	end)
end

function setNPCIntervalTotalk(lab,ID)
	local index = 1
	lab:stopAllActions()
	if not isShow then
		local amount = TextManager.getNPCtextAmount(ID,TALK_TYPE.INTERCAL)
		local seq = cc.Sequence:create(cc.DelayTime:create(10),cc.CallFunc:create(function( )
			local talkContent = TextManager.getNPCtext(ID,TALK_TYPE.INTERCAL,index)
			index = index + 1 
			if index > #amount then
				index = 1 
			end
			for i=1,#talkContent do  --字一个个出现
				local sequence = cc.Sequence:create(cc.DelayTime:create(i*0.03),cc.CallFunc:create(function() 
					lab:setString(string.sub(talkContent,1,i))
					if i == #talkContent then
						isShow = false
					else
						isShow = true
					end
				end))
				lab:runAction(sequence)
			end
		end))
		lab:runAction(cc.RepeatForever:create(seq))
	end
end

function removeTip()
	imgTip:removeFromParent()
	imgTip = nil
end
