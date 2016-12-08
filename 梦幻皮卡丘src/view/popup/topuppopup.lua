--
-- Author: hapigames
-- Date: 2014-12-10 20:02:04
--
require "view/tagMap/Tag_popup_topup"

TopupPopup = class("TopupPopup",function()
	return Popup:create()
end)

TopupPopup.__index = TopupPopup
local __instance = nil

function TopupPopup:create()
	local ret = TopupPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function TopupPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function TopupPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_topup.PANEL_POPUP_TOPUP then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function TopupPopup:updateUI()
	
end
TopupPopup.status = 0
function TopupPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_topup",PATH_POPUP_TOPUP)	
	local function event_privilege(p_sender)
	
		if TopupPopup.status == 0 then
			self.gpv_privilege:setVisible(true)
			self.gv_topup:setVisible(false)
			self.updateUI()
			self.btn_privilege:setText("充值")
			self.lab_topup:setString("特权")
			self.btn_rightarrow:setVisible(true)
			self.btn_leftarrow:setVisible(true)
			TopupPopup.status = 1
		else
			self.gpv_privilege:setVisible(false)
			self.gv_topup:setVisible(true)
			self.btn_rightarrow:setVisible(false)
			self.btn_leftarrow:setVisible(false)
			self.btn_privilege:setText("特权")
			self.lab_topup:setString("充值")
			TopupPopup.status = 0
		end
	end
	self.btn_privilege = self:getControl(Tag_popup_topup.PANEL_POPUP_TOPUP,Tag_popup_topup.BTN_PRIVILEGE)
	self.btn_privilege:setOnClickScriptHandler(event_privilege)
	

	
	local function event_arrow()
		
		
		print("page trun")
	end

 	self.lab_topup = self:getControl(Tag_popup_topup.PANEL_POPUP_TOPUP,Tag_popup_topup.LAB_TOPUP)
 	self.btn_rightarrow = self:getControl(Tag_popup_topup.PANEL_POPUP_TOPUP,Tag_popup_topup.BTN_RIGHTARROW)
 	self.btn_leftarrow = self:getControl(Tag_popup_topup.PANEL_POPUP_TOPUP,Tag_popup_topup.BTN_LEFTARROW)
 	self.btn_rightarrow:setOnClickScriptHandler(event_arrow)
 	self.btn_leftarrow:setOnClickScriptHandler(event_arrow)
 	self.btn_rightarrow:setVisible(false)
	self.btn_leftarrow:setVisible(false)
	
	for i=1,2 do
		self.layout_vip = self:getControl(Tag_popup_topup.PANEL_POPUP_TOPUP,Tag_popup_topup["LAYOUT_VIPLEVEL_".. i])
		local img = TextureManager.createImg("vip_word/".. i+4 ..".png")
		Utils.addCellToParent(img, self.layout_vip )
	end
	-- self.labAtlasNum:setScale(0.8)
	local function updateGV(p_convertview,idx)
		local pCell = p_convertview
		if pCell == nil then
			pCell = CGridViewCell:new()
			local index = idx+1
			TuiManager:getInstance():parseCell(pCell, "cell_privilege", PATH_POPUP_TOPUP)
			for i=1,3 do
				local layout_pet = pCell:getChildByTag(Tag_popup_topup["LAYOUT_PRIVILEGE_".. i])
				local img = TextureManager.createImg("pet/".. i ..".png")
				Utils.addCellToParent(img, layout_pet)
			end
			for i=1,2 do
				local layout_viplevel = pCell:getChildByTag(Tag_popup_topup["LAYOUT_CELL_VIPLEVEL".. i])
				local img = TextureManager.createImg("vip_word/".. i*index ..".png")
				Utils.addCellToParent(img, layout_viplevel )
			end
			
		end
		return pCell
	end
	self.gpv_privilege = self:getControl(Tag_popup_topup.PANEL_POPUP_TOPUP,Tag_popup_topup.GPV_PRIVILEGE)
	self.gpv_privilege:setDataSourceAdapterScriptHandler(updateGV)
	self.gpv_privilege:setCountOfCell(10)
	self.gpv_privilege:reloadData()
	self.gpv_privilege:setVisible(false)

	local function updateGV(p_convertview,idx)
		local pCell = p_convertview
		if pCell == nil then
			pCell = CGridViewCell:new()
			local index = idx+1
			TuiManager:getInstance():parseCell(pCell, "cell_topup", PATH_POPUP_TOPUP)
			local layout_pet_topup = pCell:getChildByTag(Tag_popup_topup.LAYOUT_PET_TOPUP)
			local img = TextureManager.createImg("pet/".. index ..".png")
			Utils.addCellToParent(img, layout_pet_topup)
		end
		return pCell
	end
	self.gv_topup = self:getControl(Tag_popup_topup.PANEL_POPUP_TOPUP,Tag_popup_topup.GV_TOPUP)
	self.gv_topup:setDataSourceAdapterScriptHandler(updateGV)
	self.gv_topup:setCountOfCell(10)
	self.gv_topup:reloadData()
	TouchEffect.addTouchEffect(self)
end