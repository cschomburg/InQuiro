--[[
	InQuiro
]]

GetQuestDifficultyColor = GetQuestDifficultyColor or GetDifficultyColor

BINDING_HEADER_INQUIRO = "InQuiro";
BINDING_NAME_INQUIRO_TARGET = "Inspect Target"
BINDING_NAME_INQUIRO_MOUSEOVER = "Inspect Mouseover"

local Classification = {
	["worldboss"] = BOSS,
	["rareelite"] = ITEM_QUALITY3_DESC..ELITE,
	["elite"] = ELITE,
	["rare"] = ITEM_QUALITY3_DESC,
}

local InQuiro = InQuiro
InQuiro.Callbacks = {}

InQuiro:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

function InQuiro:Inspect(unit)
	ClearInspectPlayer()
	if(not unit or not UnitExists(unit)) then unit = "player" end
	
	if(unit == "mouseover" and UnitIsUnit(unit, "target")) then
		unit = "target"
	end
	
	local name, realm = UnitName(unit)
	local pvpName = UnitPVPName(unit)
	local level = UnitLevel(unit)
	local race, raceEng = UnitRace(unit)
	local class, classEng = UnitClass(unit)
	local guild, rank, rankIndex = GetGuildInfo(unit)
	local isPlayer = UnitIsPlayer(unit)
	local canCoop = UnitCanCooperate("player", unit)
	local classif = UnitClassification(unit)
	
	self:SetBackground(raceEng)
	
	realm = (realm == "") and nil
	race = race or UnitCreatureFamily(unit) or UnitCreatureType(unit)
	
	self.Title:SetText(pvpName or name)
	
	local diff = GetQuestDifficultyColor(level ~= -1 and level or 500)
	local levelText = ("|cff%.2x%.2x%.2x%s|r"):format(diff.r*255, diff.g*255, diff.b*255, (level ~= -1 and level or "??"))
	local additional
	
	if(isPlayer) then
		local color = RAID_CLASS_COLORS[classEng]
		additional = ("|cff%.2x%.2x%.2x%s|r"):format(color.r*255, color.g*255, color.b*255, class)
		if(realm) then additional = additional.." of "..realm end
	elseif(Classification[classif]) then
		additional = "("..Classification[classif]..")"
	else
		additional = ""
	end
	
	local guildText
	if(isPlayer and guild) then
		guildText = ("%s (%i) of <%s>"):format(rank, rankIndex, guild)
	end

	self.Title:SetText(pvpName or name)
	self.Details:SetText(levelText.." "..race.." "..additional)
	self.Guild:SetText(guildText)
	
	self.Model:ClearModel()
	self.Model:SetUnit(unit)
	SetPortraitTexture(self.Portrait, unit)
	
	self.unit, self.name = unit, name
	
	local iLevel, iRarity = 0, 0
	
	if(CanInspect(unit)) then
		self.TabFrame:Show()
		if(unit ~= "mouseover") then
			self.AchieveButton:Show()
		else
			self.AchieveButton:Hide()
		end
		if(not self.Dialog or self.Dialog.ShowEquip) then
			self.ItemButtons:Show()
		else
			self.ItemButtons:Hide()
		end

		NotifyInspect(unit)
		
		for i, button in ipairs(self.Slots) do
			button.link = GetInventoryItemLink(unit, button.id)
			if(button.slotName ~= "TabardSlot" and button.slotName ~= "ShirtSlot" and button.link) then
				local _, _, iRar, iLvl = GetItemInfo(button.link)
				if(slotName == "MainHandSlot" and not self.Slots[i+1].link) then iLvl = iLvl*2 iRar = iRar*2 end
				iLevel = iLevel + iLvl
				iRarity = iRarity + iRar
			end
			self:UpdateButton(button)
		end
		self.ItemLevel:SetText(iLevel)
		local r, g, b = GetItemQualityColor(ceil(iRarity/#self.Slots))
		self.ItemLevel:SetTextColor(r, g, b)

		for _, func in pairs(self.Callbacks) do func(self) end
	else
		if(self.Dialog) then self.HandleTabs(self.Dialog.Tab) end
		self.TabFrame:Hide()
		self.AchieveButton:Hide()
		self.ItemButtons:Hide()
	end
	
	ShowUIPanel(self)
end

function InQuiro:UpdateButton(button)
	if(button.link) then
		local _, _, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(button.link)
		button.texture:SetTexture(itemTexture or [[Interface\Icons\INV_Misc_QuestionMark]])
		local r,g,b = GetItemQualityColor(itemRarity and itemRarity > 0 and itemRarity or 0)
		button.border:SetVertexColor(r,g,b)
		button.border:Show()
		button:SetAlpha(1)
	else
		button:SetAlpha(.5)
		button.texture:SetTexture(button.bgTexture)
		button.border:Hide()
	end
end

function InQuiro:CheckLastUnit()
	if(self.unit and UnitExists(self.unit) and UnitName(self.unit) == self.name) then
		return true
	end
end

function InQuiro:UNIT_INVENTORY_CHANGED(event, unit)
	if(InQuiro:IsShown() and InQuiro:CheckLastUnit() and UnitIsUnit(self.unit, unit) and CheckInteractDistance(unit, 1)) then
		self:Inspect(self.unit)
	end
end

InQuiro:RegisterEvent("UNIT_INVENTORY_CHANGED")
InspectUnit = function(unit) InQuiro:Inspect(unit) end
