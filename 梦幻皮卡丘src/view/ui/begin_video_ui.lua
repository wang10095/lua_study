require "view/tagMap/Tag_ui_begin_video"

BeginVideoUI = class("BeginVideoUI",function()
	return TuiBase:create()
end)

BeginVideoUI.__index = BeginVideoUI
local __instance = nil

function BeginVideoUI:create()
	local ret = BeginVideoUI.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function BeginVideoUI:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function BeginVideoUI:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_begin_video.PANEL_BEGIN_VIDEO then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function BeginVideoUI:onLoadScene( )
	TuiManager:getInstance():parseScene(self,"panel_begin_video",PATH_UI_BEGIN_VIDEO)
	local layoutVideo = self:getControl(Tag_ui_begin_video.PANEL_BEGIN_VIDEO,Tag_ui_begin_video.LAYOUT_VIDEO)
    print("    **********************************    ")
    
	local function onNodeEvent(event)
	 	if "enterTransitionFinish" == event then
	 		local winSize = cc.Director:getInstance():getVisibleSize()
		    local videoPlayer = ccexp.VideoPlayer:create()
		    videoPlayer:setAnchorPoint(cc.p(0, 0))

		    videoPlayer:setFileName("res/video/begin_video.mp4")
		    print(winSize.width,winSize.height)

		    local glView = cc.Director:getInstance():getOpenGLView()
			local screenSize = glView:getFrameSize()
			print("  andorid  "..screenSize.width,screenSize.height)
			if screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
				videoPlayer:setPosition(cc.p(-67,0))
				Utils.floatToBottom(videoPlayer)
				videoPlayer:setContentSize(cc.size(768,1024))
				videoPlayer:setFullScreenEnabled(false)
			elseif screenSize.width%640 == 0 and screenSize.height%960 == 0 then
				videoPlayer:setPosition(cc.p(0,winSize.height/2))
				videoPlayer:setContentSize(cc.size(640/2,960/2))
				videoPlayer:setFullScreenEnabled(false)
			elseif screenSize.width%640 == 0 and screenSize.height%1136 == 0 then
				-- videoPlayer:setPosition(cc.p(winSize.width/4,winSize.height/1.5+6))
				videoPlayer:setPosition(cc.p(0,winSize.height/2))
				Utils.floatToBottom(videoPlayer)
				videoPlayer:setContentSize(cc.size(640/2,1136/2))
				videoPlayer:setFullScreenEnabled(false)
			else
				print(" android video ")
				print()
				-- videoPlayer:setAnchorPoint(cc.p(0, 0.85))
				-- videoPlayer:setPosition(cc.p(0,0))
				-- -- Utils.floatToBottom(videoPlayer)
				-- videoPlayer:setContentSize(cc.size(winSize.width,winSize.height*4))
				-- videoPlayer:setFullScreenEnabled(true)
				videoPlayer:setAnchorPoint(cc.p(0.5, 0))
				videoPlayer:setPosition(cc.p(winSize.width/2,-winSize.height/3))
				-- Utils.floatToBottom(videoPlayer)
				videoPlayer:setFullScreenEnabled(true)
				videoPlayer:setContentSize(cc.size(winSize.width,winSize.height))
				-- videoPlayer:play()
			end
		    self:addChild(videoPlayer)
		    
		    self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function( )
		    	videoPlayer:play()
		    end)))
		    
			function VideoPlayerEvent(p_Sender, eventType )
		    	print(eventType)
		    	if eventType == 1 then
		    		videoPlayer:play()
		    	end
		    	if eventType == 3 then
		    		videoPlayer:stop()
			    	videoPlayer:removeFromParent()
		    		-- videoPlayer:setFullScreenEnabled(false)
					Utils.replaceScene("LogInUI",self)
		        end
		    end
		    videoPlayer:addEventListener(VideoPlayerEvent)
	 	end
	 	if "exit" == event then
	 		-- videoPlayer:release()
	 	end
	 end
	 self:registerScriptHandler(onNodeEvent)
end