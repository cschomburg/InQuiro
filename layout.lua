--[[
	InQuiro
]]

local Backgrounds = {
	"DeathknightBlood", "DeathknightFrost", "DeathknightUnholy",
	"DruidBalance", "DruidFeralCombat", "DruidRestoration",
	"HunterBeastMastery", "HunterMarksmanship", "HunterSurvival",
	"HunterPetCunning", "HunterPetFeroiQty", "HunterPetTenaiQty",
	"MageArcane", "MageFire", "MageFrost",
	"PaladinCombat", "PaladinHoly", "PaladinProtection",
	"PriestDisiQpline", "PriestHoly", "PriestShadow",
	"RogueAssassination", "RogueCombat", "RogueSubtlety",
	"ShamanElementalCombat", "ShamanEnhancement", "ShamanRestoration",
	"WarlockCurses", "WarlockDestruction", "WarlockSummoning",
	"WarriorArms", "WarriorFury", "WarriorProtection",
}


local iQ = CreateFrame("Frame", "InQuiro", UIParent)
iQ:SetWidth(384)
iQ:SetHeight(440)
iQ:SetToplevel(1)
iQ:SetPoint"CENTER"
iQ:EnableMouse(true)
iQ:SetHitRectInsets(12, 35, 10, 2)
iQ:SetScript("OnDragStart", function() if(self:IsMovable()) then self:StartMoving() end end)
iQ:SetScript("OnDragStop", function() self:StopMovingOrSizing() end)
iQ:Hide()

UIPanelWindows["InQuiro"] = { area = "left", pushable = 1, whileDead = 1 }
tinsert(UISpecialFrames, "InQuiro")

iQ.Slots = {
		"HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "ShirtSlot", "TabardSlot", "WristSlot",
		"HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot",
		"MainHandSlot", "SecondaryHandSlot", "RangedSlot",
}


CreateFrame("Button", nil, iQ, "UIPanelCloseButton"):SetPoint("TOPRIGHT", -30, -8)
iQ.GTTHide = function() GameTooltip:Hide() end
iQ.GTTShow = function(self) if(self.tip) then
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:AddLine(self.tip)
	GameTooltip:Show()
end end

--[[ ##################
	Portrait
#################### ]]
local portrait = iQ:CreateTexture(nil, "BACKGROUND")
portrait:SetWidth(60)
portrait:SetHeight(60)
portrait:SetPoint("TOPLEFT", 7, -6)
iQ.Portrait = portrait

local ach = CreateFrame("Button", nil, iQ)
ach:SetWidth(24)
ach:SetHeight(48)
ach:SetNormalTexture([[Interface\Buttons\UI-MicroButton-Achievement-Up]])
ach:SetPushedTexture([[Interface\Buttons\UI-MicroButton-Achievement-Down]])
ach:SetHighlightTexture([[Interface\Buttons\UI-MicroButton-Hilight]])
ach:SetPoint("TOPRIGHT", -40, -20)
ach:SetScript("OnClick", function() if(iQ:CheckLastUnit()) then
		InspectAchievements(iQ.unit)
	end
end)
ach:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:AddLine(ACHIEVEMENTS, 1,1,1)
	GameTooltip:Show()
end)
ach:SetScript("OnLeave", iQ.GTTHide)
iQ.AchieveButton = ach

--[[ ##################
	Title, Details & Guild
#################### ]]
local title = iQ:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
title:SetPoint("TOP", 5, -17)
local details = iQ:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
details:SetPoint("TOP", 5, -44)
local guild = iQ:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
guild:SetPoint("TOP", details, "BOTTOM", 0, -2)
iQ.Title, iQ.Details, iQ.Guild = title, details, guild

--[[ ##################
	Frame Textures
#################### ]]
local t1 = iQ:CreateTexture(nil, "ARTWORK")
t1:SetTexture([[Interface\PaperDollInfoFrame\UI-Character-General-TopLeft]])
t1:SetPoint"TOPLEFT"
t1:SetWidth(256)
t1:SetHeight(256)
local t2 = iQ:CreateTexture(nil, "ARTWORK")
t2:SetTexture([[Interface\PaperDollInfoFrame\UI-Character-General-TopRight]])
t2:SetPoint"TOPRIGHT"
t2:SetWidth(128)
t2:SetHeight(256)
local t3 = iQ:CreateTexture(nil, "ARTWORK")
t3:SetTexture([[Interface\PaperDollInfoFrame\UI-Character-General-BottomLeft]])
t3:SetPoint("TOPLEFT", t1, "BOTTOMLEFT")
t3:SetWidth(256)
t3:SetHeight(256)
local t4 = iQ:CreateTexture(nil, "ARTWORK")
t4:SetTexture([[Interface\PaperDollInfoFrame\UI-Character-General-BottomRight]])
t4:SetPoint("TOPRIGHT", t2, "BOTTOMRIGHT")
t4:SetWidth(128)
t4:SetHeight(256)

--[[ ##################
	Background
#################### ]]

local bgTL = iQ:CreateTexture(nil, "OVERLAY")
bgTL:SetPoint("TOPLEFT", 22, -76)
local bgTR = iQ:CreateTexture(nil, "OVERLAY")
bgTR:SetPoint("LEFT", bgTL, "RIGHT")
local bgBL = iQ:CreateTexture(nil, "OVERLAY")
bgBL:SetPoint("TOP", bgTL, "BOTTOM")
local bgBR = iQ:CreateTexture(nil, "OVERLAY")
bgBR:SetPoint("LEFT", bgBL, "RIGHT")

function iQ:SetBackground(race)
	local texture, small
	if (not race) then
		texture = "Interface\\TalentFrame\\"..Backgrounds[random(1, #Backgrounds)].."-"
	else
		texture = "Interface\\DressUpFrame\\DressUpBackground-"..((race == "Gnome" and "Dwarf") or (race == "Troll" and "Orc") or race)
		small = true
	end

	bgTL:SetWidth(small and 256 or 267)
	bgTR:SetWidth(small and 64 or 74)
	bgBL:SetWidth(small and 256 or 267)
	bgBR:SetWidth(small and 64 or 74)

	bgTL:SetHeight(270)
	bgTR:SetHeight(270)
	bgBL:SetHeight(141)
	bgBR:SetHeight(141)

	bgTL:SetTexture(texture..(small and "1" or "TopLeft"))
	bgTR:SetTexture(texture..(small and "2" or "TopRight"))
	bgBL:SetTexture(texture..(small and "3" or "BottomLeft"))
	bgBR:SetTexture(texture..(small and "4" or "BottomRight"))
end

--[[ ##################
	Model
#################### ]]
local model = CreateFrame("PlayerModel", nil, iQ)
model:SetWidth(320)
model:SetHeight(354)
model:SetPoint("BOTTOM", -11, 10)
model:EnableMouse(true)
model:EnableMouseWheel(true)
model:SetScript("OnUpdate", function(self, elapsed)
	if (self.isRotating) then
		local endx, endy = GetCursorPosition()
		self.rotation = (endx - self.startx) / 34 + self:GetFacing()
		self:SetFacing(self.rotation)
		self.startx, self.starty = GetCursorPosition()
	elseif (self.isPanning) then
		local endx, endy = GetCursorPosition()
		local z, x, y = self:GetPosition(z,x,y)
		x = (endx - self.startx) / 45 + x
		y = (endy - self.starty) / 45 + y
		self:SetPosition(z,x,y)
		self.startx, self.starty = GetCursorPosition()
	end
end)
model:SetScript("OnMouseWheel", function(self)
	if(IsShiftKeyDown()) then
		local alpha = bgTL:GetAlpha()
		alpha = alpha + arg1*0.1
		alpha = alpha > 1 and 1 or alpha < 0 and 0 or alpha
		bgTL:SetAlpha(alpha)
		bgTR:SetAlpha(alpha)
		bgBL:SetAlpha(alpha)
		bgBR:SetAlpha(alpha)
	else
		local z, x, y = self:GetPosition()
		local scale = (IsControlKeyDown() and 2 or 0.7)
		z = (arg1 > 0 and z + scale or z - scale)
		self:SetPosition(z,x,y)
	end
end)
model:SetScript("OnMouseDown", function(self)
	self.startx, self.starty = GetCursorPosition()
	if (arg1 == "LeftButton") then
		self.isRotating = 1
	elseif (arg1 == "RightButton") then
		self.isPanning = 1
	end
end)
model:SetScript("OnMouseUp", function(self)
	if (arg1 == "LeftButton") then
		self.isRotating = nil
	elseif (arg1 == "RightButton") then
		self.isPanning = nil
	end
end)
iQ.Model = model


--[[ ##################
	Item Buttons
#################### ]]
local function ItemSlot_OnClick(self, button)
	if(self.link) then
		if(button == "RightButton") then
			local gemLink
			print("--- Gem Overview for "..select(2,GetItemInfo(self.link)).." |r---")
			for i = 1, 3 do
				gemLink = select(2,GetItemGem(self.link,i));
				if(gemLink) then
					print(("Gem %d: %s"):format(i,gemLink))
				end
			end
		elseif(button == "LeftButton") then
			if(IsModifiedClick("DRESSUP")) then
				DressUpItemLink(self.link)
			elseif(IsModifiedClick("CHATLINK") and ChatFrameEditBox:IsVisible()) then
				ChatFrameEditBox:Insert(select(2,GetItemInfo(self.link)))
			end
		end
	end
end

local function ItemSlot_OnEnter(self)
	GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
	if(iQ:CheckLastUnit() and CheckInteractDistance(iQ.unit, 1) and GameTooltip:SetInventoryItem(iQ.unit, self.id)) then
	elseif (self.link) then
		GameTooltip:SetHyperlink(self.link)
	end
	GameTooltip:Show()
end

iQ.ItemButtons = CreateFrame("Frame", nil, model)
iQ.ItemButtons:SetFrameLevel(model:GetFrameLevel()+2)
for i, slot in ipairs(iQ.Slots) do
	local button = CreateFrame("Button","InQuiroItemButton"..slot, model, "ItemButtonTemplate")
	button:SetWidth(37)
	button:SetHeight(37)
	button:RegisterForClicks("anyUp")
	button:RegisterForDrag("LeftButton");

	button:SetScript("OnClick",ItemSlot_OnClick)
	button:SetScript("OnEnter",ItemSlot_OnEnter)
	button:SetScript("OnLeave", iQ.GTTHide)

	button.id, button.bgTexture = GetInventorySlotInfo(slot)
	button.slotName = slot

	button.texture = _G['InQuiroItemButton'..slot..'IconTexture']

	button.border = button:CreateTexture(nil,"OVERLAY")
	button.border:SetTexture([[Interface\Buttons\UI-ActionButton-Border]])
	button.border:SetBlendMode"ADD"
	button.border:SetWidth(70)
	button.border:SetHeight(70)
	button.border:SetPoint("CENTER")
	button.border:SetAlpha(0.7)

	if(i == 1) then
		button:SetPoint("TOPLEFT", 4, -3)
	elseif(i == 9) then
		button:SetPoint("TOPRIGHT", -4, -3)
	elseif(i == 17) then
		button:SetPoint("BOTTOM", -40, 4)
	elseif(i <= 16) then
		button:SetPoint("TOP", iQ.Slots[i-1], "BOTTOM", 0, -4)
	else
		button:SetPoint("LEFT", iQ.Slots[i-1], "RIGHT", 5, 0)
	end

	button:SetParent(iQ.ItemButtons)
	iQ.Slots[i] = button
end

iQ.ItemLevel = iQ.ItemButtons:CreateFontString(nil, "OVERLAY")
iQ.ItemLevel:SetFont([[Fonts\FRIZQT__.TTF]], 14, "THINOUTLINE")
iQ.ItemLevel:SetPoint("BOTTOMLEFT", model, "BOTTOMLEFT", 4, 4)
iQ.ItemLevel:SetTextColor(1, .5, 0)

iQ.Resilience = iQ.ItemButtons:CreateFontString(nil, "OVERLAY")
iQ.Resilience:SetFont([[Fonts\FRIZQT__.TTF]], 14, "THINOUTLINE")
iQ.Resilience:SetPoint("BOTTOMRIGHT", model, "BOTTOMRIGHT", -4, 4)
iQ.Resilience:SetTextColor(1, .5, .5)

--[[ ##################
	Tabs
#################### ]]
local backdrop = {bgFile = [[Interface/Tooltips/UI-Tooltip-Background]],
	tile = true, tileSize = 16, edgeSize = 16,
}

function iQ.HandleTabs(self)
	if(iQ.Dialog) then iQ.Dialog:Hide() iQ.Dialog.Tab:UnlockHighlight() end
	if(iQ.Dialog == self.Dialog) then
		iQ.Dialog = nil
	else
		self.Dialog:Show()
		self.Dialog.Tab:LockHighlight()
		iQ.Dialog = self.Dialog
	end
	if(iQ.Dialog and iQ.Dialog.ShowEquip or not iQ.Dialog) then
		iQ.ItemButtons:Show()
	else
		iQ.ItemButtons:Hide()
	end
end

iQ.TabFrame = CreateFrame("Frame", nil, iQ)
local prev
function iQ:CreateTabDialog(name, frameName)
	local tab = CreateFrame("Button", nil, self.TabFrame, "UIPanelButtonGrayTemplate")
	tab:SetHeight(21)
	tab:SetFrameLevel(1)
	tab:RegisterForClicks("anyUp")
	tab:SetText(name)
	tab:SetWidth(tab:GetTextWidth()+10)
	tab:SetScript("OnClick", iQ.HandleTabs)
	tab:SetAlpha(.7)
	tab:SetNormalFontObject(GameFontHighlightSmall)
	tab:SetHighlightFontObject(GameFontHighlightSmall)
	tinsert(iQ.TabFrame, tab)

	if(prev) then
		tab:SetPoint("LEFT", prev, "RIGHT", 3, 0)
	else
		tab:SetPoint("BOTTOMLEFT", iQ, "BOTTOMLEFT", 30, -14)
	end
	prev = tab
	
	local dialog = CreateFrame("Frame", frameName and "InQuiro"..frameName, model)
	dialog:SetPoint("TOPLEFT", -1, 1)
	dialog:SetPoint("BOTTOMRIGHT")
	dialog:SetBackdrop(backdrop)
	dialog:SetBackdropColor(0, 0, 0, 1)
	dialog:Hide()
	
	dialog.Tab = tab
	tab.Dialog = dialog

	return dialog, tab, frameName and "InQuiro"..frameName
end

function iQ:UNIT_MODEL_CHANGED(event, unit)
	if(not self:CheckLastUnit() or not UnitIsUnit(unit, self.unit)) then return nil end
	self.Model:ClearModel()
	self.Model:SetUnit(self.unit)
	SetPortraitTexture(self.Portrait, self.unit)
end
iQ.UNIT_PORTRAIT_UPDATE = iQ.UNIT_MODEL_CHANGED
iQ:RegisterEvent"UNIT_MODEL_CHANGED"