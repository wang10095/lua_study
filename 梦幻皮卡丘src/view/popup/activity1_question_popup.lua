require "view/tagMap/Tag_popup_activity1_questions"

ActivityQuestionPopup = class("ActivityQuestionPopup",function()
	return Popup:create()
end)

ActivityQuestionPopup.__index = ActivityQuestionPopup
local __instance = nil
local index = 1
local lab_expect_num

function ActivityQuestionPopup:create()
	local ret = ActivityQuestionPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function ActivityQuestionPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function ActivityQuestionPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_activity1_questions.PANEL_POPUP_ACTIVITY1_QUESTION then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function ActivityQuestionPopup:onLoadQuestionas()
	local token = Activity1StatusProxy:getInstance():get("token")
	local questionTexts = TextManager.getActivity1Question(qid["id"..index])
	local labQuestion = __instance:getControl(Tag_popup_activity1_questions.PANEL_POPUP_ACTIVITY1_QUESTION,Tag_popup_activity1_questions.LAB_QUESTION)
	labQuestion:setString(index .. "、 " .. questionTexts.question)
	labQuestion:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1.1),cc.ScaleTo:create(0.2,1.0),nil))
	local options = {'options1','options2','options3','options4'}
	for i=1,4 do
		local labOptions = __instance:getControl(Tag_popup_activity1_questions.PANEL_POPUP_ACTIVITY1_QUESTION,Tag_popup_activity1_questions["LAB_ANSWER"..i])
		labOptions:setString(questionTexts[tostring(options[i])])
	end
end

function ActivityQuestionPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_activity1_question",PATH_POPUP_ACTIVITY1_QUESTIONS)
	local answer = {}
	local activity1Type = Activity1StatusProxy:getInstance():get("activity1Type")

	local lab_expect_num = self:getControl(Tag_popup_activity1_questions.PANEL_POPUP_ACTIVITY1_QUESTION,Tag_popup_activity1_questions.LAB_EXPECT_NUM)
	lab_expect_num:setString(0)
    index = 1
    local player_option = nil
    qid = Activity1StatusProxy:getInstance():get("qid")

    token = Activity1StatusProxy:getInstance():get("token")
    local fanalAnswer = 0 --回答
	self.onLoadQuestionas()
	local labQestionCount = self:getControl(Tag_popup_activity1_questions.PANEL_POPUP_ACTIVITY1_QUESTION,Tag_popup_activity1_questions.LAB_QUESTION_COUNT)
	
	local function onLoadnextQuestion( p_sender )
		local result_img = nil
		local  correct_option = TextManager.getActivity1Question(qid["id"..index]).correct_option
		print(correct_option)
		print(player_option)
		local score_question = ConfigManager.getActivty1CommonConfig('event3_score') --正确得分
		if fanalAnswer == correct_option  then
			result_img = TextureManager.createImg("popup_activity1_questions/tgv_test_select1.png")
			-- Utils.addCellToParent(result_img,player_option)
			player_option:addChild(result_img,99)
			local size = player_option:getContentSize()
			result_img:setPosition(cc.p(35,size.height-45))
           	TipManager.showTip("回答正确")
           	lab_expect_num:setString(tonumber(lab_expect_num:getString())+score_question)
		else
			result_img = TextureManager.createImg("popup_activity1_questions/tgv_test_select2.png")
			-- Utils.addCellToParent(result_img,player_option)
			player_option:addChild(result_img,99)
			local size = player_option:getContentSize()
			result_img:setPosition(cc.p(35,size.height-50))
           	TipManager.showTip("回答错误,答案为" .. correct_option)
		end
		__instance:runAction(cc.Sequence:create(cc.DelayTime:create(1.6),cc.CallFunc:create(function() 
			result_img:removeFromParent()
			if index+1 < 3 then
				index = index +1
				self.onLoadQuestionas()
			elseif index+1 == 3 then
				index = index +1
				self.onLoadQuestionas()
			elseif index == 3 then
				local function answeractivity1question( result )
					Activity1StatusProxy:getInstance():set("token",result["token"])
					Activity1StatusProxy:getInstance():set("score",result["score"])
					local eventDispatcher = self:getEventDispatcher()
	   				local event = cc.EventCustom:new("game_custom_event2")
	       			eventDispatcher:dispatchEvent(event)
	       			Utils.popUIScene(__instance)
					TipManager.showTip("答题完成 当前得分" .. result["score"])
				end
				NetManager.sendCmd("answeractivity1question",answeractivity1question,activity1Type,token,qid["id1"].."_"..answer[1][2],qid["id2"].."_"..answer[2][2],qid["id3"].."_"..answer[3][2])
			end
		end),nil))

	end

	local tgvSelect1,tgvSelect2,tgvSelect3,tgvSelect4
	tgvSelect1 = self:getControl(Tag_popup_activity1_questions.PANEL_POPUP_ACTIVITY1_QUESTION,Tag_popup_activity1_questions.BTN_SELECT1)
	tgvSelect2 = self:getControl(Tag_popup_activity1_questions.PANEL_POPUP_ACTIVITY1_QUESTION,Tag_popup_activity1_questions.BTN_SELECT2)
	tgvSelect3 = self:getControl(Tag_popup_activity1_questions.PANEL_POPUP_ACTIVITY1_QUESTION,Tag_popup_activity1_questions.BTN_SELECT3)
	tgvSelect4 = self:getControl(Tag_popup_activity1_questions.PANEL_POPUP_ACTIVITY1_QUESTION,Tag_popup_activity1_questions.BTN_SELECT4)

	local function event_select_answer(p_sender)
		local tag = p_sender:getTag()
		local k = {
			Tag_popup_activity1_questions.BTN_SELECT1,
			Tag_popup_activity1_questions.BTN_SELECT2,
			Tag_popup_activity1_questions.BTN_SELECT3,
			Tag_popup_activity1_questions.BTN_SELECT4
		}
		local buttonTable = {tgvSelect1,tgvSelect2,tgvSelect3,tgvSelect4}
		local table_option = {'A','B','C','D'}
		for i=1,#k do
			if k[i] == tag then
				fanalAnswer = table_option[i]
				player_option = buttonTable[i]
				table.insert(answer,{index,fanalAnswer})
			end
		end
		labQestionCount:setString(index.."/3")
		onLoadnextQuestion()
	end
	tgvSelect1:setOnClickScriptHandler(event_select_answer)
	tgvSelect2:setOnClickScriptHandler(event_select_answer)
	tgvSelect3:setOnClickScriptHandler(event_select_answer)
	tgvSelect4:setOnClickScriptHandler(event_select_answer)

	TouchEffect.addTouchEffect(self)
end









