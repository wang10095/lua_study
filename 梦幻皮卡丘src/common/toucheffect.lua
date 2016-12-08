module("TouchEffect",package.seeall)

function addTouchEffect(scene)
	-- local listener = cc.EventListenerTouchOneByOne:create()
	-- listener:setSwallowTouches(true)
	-- listener:registerScriptHandler(function( touch,event )
	-- 	local location = touch:getLocation()		
	--  	Spine.addTouchEffectSpine(scene,location)
	--  	MusicManager.playBtnClickEffect()
	-- 	return false
	-- end,cc.Handler.EVENT_TOUCH_BEGAN)

	-- listener:registerScriptHandler(function(touch, event)  
 --        local locationInNodeX = scene:convertToNodeSpace(touch:getLocation()).x  
 --        local location = touch:getLocation()	
 --    end, cc.Handler.EVENT_TOUCH_ENDED )  
  	
 --    local eventDispatcher = scene:getEventDispatcher()  
 --    -- 添加监听器  
 --    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, scene)

    -- eventDispatcher:addEventListenerWithFixedPriority(listener, -1)
    local glView = cc.Director:getInstance():getOpenGLView()
    local size = glView:getFrameSize()
 	local node = CLayout:create()
 	
 	node:setContentSize(size)
 	node:setPosition(cc.p(size.width/2,size.height/2))
 	scene:addChild(node)
 	Utils.floatToBottom(node)
 	local function setTouchBeganNormalHandler(touchBeganHandlerP)
		node.touchBeganHandler = touchBeganHandlerP
	end

	local function setTouchEndedNormalHandler(touchEndedHandlerP)
		node.touchEndedHandler = touchEndedHandlerP
	end

	local function setTouchBeganClosureHandler(touchBeganHandlerP)
		--the format of the handler must be a closure 
		node.touchBeganHandler = touchBeganHandlerP()
	end

	local function setTouchEndedClosureHandler(touchEndedHandlerP)
		node.touchEndedHandler = touchEndedHandlerP()
	end
    local function onTouchBegan( p_sender, touch )
    	local location = touch:getLocation()		
	 	Spine.addTouchEffectSpine(node,location)
	 	MusicManager.playBtnClickEffect()
	 	return Constants.TOUCH_RET.NOHANDLE
    end
    local function onTouchMoved( p_sender,touch )
		return Constants.TOUCH_RET.NOHANDLE
	end
	local function onTouchEnded(p_sender, touch, duration)
		return Constants.TOUCH_RET.NOHANDLE
	end
    node:setOnTouchBeganScriptHandler(onTouchBegan)
	node:setOnTouchMovedScriptHandler(onTouchMoved)
	node:setOnTouchEndedScriptHandler(onTouchEnded)
end
