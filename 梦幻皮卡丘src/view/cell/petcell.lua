require "view/tagMap/Tag_cell_pet"

PetCell= class("PetCell",function()
	return CGridViewCell:new()
end)

PetCell.__index = PetCell
--be careful to use local variable in class, 
--those local variables just refer to the last variable it assigned
local __instance = nil
local touchBegin = false
function PetCell:registerPet(pet)
	if (pet ~= nil) then
 	end
end

function PetCell:create(pet)
	local ret = PetCell.new()
	__instance = ret
	TuiManager:getInstance():parseCell(__instance,"cell_pet",PATH_CELL_PET)
	__instance:init()
	__instance:updateUI(pet)
	return ret
end

function PetCell:getControl(tagControl)
	local ret = nil
	ret = self:getChildByTag(tagControl)
	return ret
end

function PetCell:updateUI(petP)  
	local mid, aptitude, form = petP:get("mid"), petP:get("aptitude"), petP:get("form")
	print(petP:get("mid").."@"..petP:get("aptitude").."@"..petP:get("form"))
	local petFormConfig = ConfigManager.getPetFormConfig(mid, form)
	local maxStar = ConfigManager.getPetCommonConfig('star_limit')
	local star = petP:get("star")
	for i = 1, maxStar do
		if self.imgStars ~= nil and self.imgStars[i] ~= nil then
			self.imgStars[i]:setVisible(true)
			if i > star then 
				self.imgStars[i]:setVisible(false)
			end
		end
	end
	
	for i = maxStar+1, 6  do
		if self.imgStars ~= nil and self.imgStars[i] ~= nil then
			self.imgStars[i]:setVisible(false)
		end
	end
    
	if (mid == 0) then
		self:setVisible(false)
	else
		self:setVisible(true) 
	end
	
	if petFormConfig ~= nil and self.layoutPet ~= nil then
		local sid = petFormConfig.model
		local fileName = TextureManager.createImg(string.format(TextureManager.RES_PATH.PET_AVATAR, sid))
		-- self.layoutPet:setTexture(fileName)
		Utils.addCellToParent(fileName,self.layoutPet)
	end

	if self.layoutBorder ~= nil then
		local fileName = TextureManager.createImg(string.format(TextureManager.RES_PATH.BORDER, aptitude))
		-- self.layoutBorder:setSpriteFrame(fileName)
		Utils.addCellToParent(fileName,self.layoutBorder)
	end
	self.labLevel:setString(petP:get("level").."级")
	self.labRank:setString(petP:get("rank").."段")
end

function PetCell:removeTouchEvent()
	if (self.listener ~= nil) then
		local eventDispatcher = self:getEventDispatcher() -- 时间派发器 
    	-- 绑定触摸事件到层当中  
    	eventDispatcher:removeEventListener(self.listener)
	end
end

function PetCell:setTouchBeganNormalHandler(touchBeganHandlerP)

	self.touchBeganHandler = touchBeganHandlerP
end

function PetCell:setTouchEndedNormalHandler(touchEndedHandlerP)
	
	self.touchEndedHandler = touchEndedHandlerP
end

function PetCell:setTouchBeganClosureHandler(touchBeganHandlerP)
	--the format of the handler must be a closure 
	self.touchBeganHandler = touchBeganHandlerP()
end

function PetCell:setTouchEndedClosureHandler(touchEndedHandlerP)
	self.touchEndedHandler = touchEndedHandlerP()
end

function PetCell:addDefaultTouchEvent()
	--touch handler--
	local function onTouchBegan(p_sender, touch)
		if (self.touchBeganHandler ~= nil) then
			self.touchBeganHandler()
		end

		return Constants.TOUCH_RET.TRANSIENT
	end

	local function onTouchEnded(p_sender, touch, duration)
		if (self.touchEndedHandler ~= nil) then
			self.touchEndedHandler()
		end
		return Constants.TOUCH_RET.TRANSIENT
	end

	self:setOnTouchBeganScriptHandler(onTouchBegan)
	self:setOnTouchEndedScriptHandler(onTouchEnded)
end

function PetCell:init()
	self.layoutPet = self:getControl(Tag_cell_pet.LAYOUT_PET)
	self.layoutBorder = self:getControl(Tag_cell_pet.LAYOUT_BORDER)
	self.labLevel = self:getControl(Tag_cell_pet.LAB_LEVEL)
	self.labLevel:setString("1级")
	self.labRank = self:getControl(Tag_cell_pet.LAB_RANK)
	self.labRank:setString("1段")
	self.imgStars = {}
	for i = 1, 5 do
		self.imgStars[i] = self:getControl(Tag_cell_pet["IMG_STAR"..i])
	end
	self:addDefaultTouchEvent()

	self.layout_effect_up = self:getControl(Tag_cell_pet.LAYOUT_EFFECT_UP)
	self.layout_effect_down = self:getControl(Tag_cell_pet.LAYOUT_EFFECT_DOWN)
	
end

function PetCell:onEnter()
end
