require "view/tagMap/Tag_popup_new_pet"

NewPetPopup = class("NewPetPopup", function()
    return Popup:create()
end)

NewPetPopup.__index = NewPetPopup
local __instance = nil
local currentPet = nil

function NewPetPopup:create()
	print("create breakthrough popup")
	local ret = NewPetPopup.new()
	__instance = ret
	if (ItemManager.currentPet ~= nil) then
		currentPet = ItemManager.currentPet
		ItemManager.currentPet = nil
	end
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function NewPetPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function NewPetPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_new_pet.PANEL_POPUP_NEW_PET then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function NewPetPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_new_pet",PATH_POPUP_NEW_PET)
	local mid = WildDataProxy:getInstance():get("newPet_mid")
	local form = WildDataProxy:getInstance():get("newPet_form")
	NormalDataProxy:getInstance():set("isPopup",true)
	
	local layoutPet = self:getControl(Tag_popup_new_pet.PANEL_POPUP_NEW_PET,Tag_popup_new_pet.LAYOUT_PET_BAGIMG)
	layoutPet:setScale(0.01)
	local petFormConfig = ConfigManager.getPetFormConfig(mid, form)

	local pet = TextureManager.createImg(TextureManager.RES_PATH.PET_PORTRAIT,petFormConfig.model)
	Utils.addCellToParent(pet,layoutPet)
	local sequence = cc.Sequence:create(cc.DelayTime:create(0.5),cc.ScaleTo:create(0.3,1.3),cc.ScaleTo:create(0.1,1),nil)
	layoutPet:runAction(sequence)
	local layoutNewPet = self:getControl(Tag_popup_new_pet.PANEL_POPUP_NEW_PET,Tag_popup_new_pet.LAYOUT_NEWPET)
	local size = layoutNewPet:getContentSize()
	local json = TextureManager.RES_PATH.WILD_CIRCLE..".json"
	local atlas = TextureManager.RES_PATH.WILD_CIRCLE..".atlas"
	local spine = sp.SkeletonAnimation:create(json, atlas, 1)
	spine:setPosition(cc.p(size.width/2,size.height/2))
	spine:setAnimation(0, "part1", true)
	layoutNewPet:addChild(spine,5)

	local labNewPetName = self:getControl(Tag_popup_new_pet.PANEL_POPUP_NEW_PET,Tag_popup_new_pet.LAB_NEWPET_NAME)
	local name = TextManager.getPetName(mid,form)
	labNewPetName:setString(name)
	
	local imgCircle = self:getControl(Tag_popup_new_pet.PANEL_POPUP_NEW_PET,Tag_popup_new_pet.IMG_NEWPET_CIRCLE)
	local act1 = cc.RotateBy:create(5, 360)
	imgCircle:runAction(cc.RepeatForever:create(act1))

	local function event_popup_close()
		if GuideManager.guide_pet == 1 then
			local customEvent = cc.EventCustom:new("new_pet_1")
	    	cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
	    elseif GuideManager.guide_pet == 2 then
	    	local customEvent = cc.EventCustom:new("new_pet_2")
	    	cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
	    elseif GuideManager.guide_pet == 3 then
	    	local customEvent = cc.EventCustom:new("new_pet_3")
	    	cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
	    elseif GuideManager.guide_pet == 4 then
	    	local customEvent = cc.EventCustom:new("new_pet_4")
	    	cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
	    else
	    	if NormalDataProxy:getInstance().confirmHandler then
	 			NormalDataProxy:getInstance().confirmHandler()
	 		end
	 		NormalDataProxy:getInstance().confirmHandler = nil
	    end
		Utils.popUIScene(self)
	end
	local btnClose = self:getControl(Tag_popup_new_pet.PANEL_POPUP_NEW_PET, Tag_popup_new_pet.BTN_CLOSE_NEW_PET)
	btnClose:setOnClickScriptHandler(event_popup_close)
	
	Stagedataproxy:getInstance():set("isPopup",true)
	local function onNodeEvent( event )
		if "enter" == event then
			self:show()
		end
	    if "exit" == event then
	    	Stagedataproxy:getInstance():set("isPopup",false)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end
