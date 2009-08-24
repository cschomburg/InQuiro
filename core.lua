--[[
	InQuiro
]]

local LIB = LibStub("LibItemBonus-2.0", true)
local LCE = LibStub("LibCargEvents-1.0", true)

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
local modules = {}

InQuiro:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

local function metahandler()
	return InQuiro:IsShown() and InQuiro.isInspecting and InQuiro:CheckLastUnit()
end

function InQuiro:RegisterModule(name, module)
	module = module or {}
	modules[name] = module
	LCE.Implement(module)
	module:SetMetaHandler(metahandler)
	return module
end

local dummyTable = {}
InQuiro.Equip = {}
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
	
	if(realm == "") then realm = nil end
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
	
	self.unit, self.guid = unit, UnitGUID(unit)
	
	local iLevel, iRarity = 0, 0
	self.IsInspecting = CanInspect(unit)
	
	if(self.IsInspecting) then
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
		local set_count = {}
		for i, button in ipairs(self.Slots) do
			button.link = GetInventoryItemLink(unit, button.id)
			self.Equip[button.slotName] = button.link

			if(button.slotName ~= "Tabard" and button.slotName ~= "Shirt" and button.link) then
				local _, _, iRar, iLvl = GetItemInfo(button.link)
				if(slotName == "MainHand" and not self.Slots[i+1].link) then iLvl = iLvl*2 iRar = iRar*2 end
				iLevel = iLevel + iLvl
				iRarity = iRarity + iRar
			end
			self:UpdateButton(button)
		end
		self.SetCount = set_count

		self.ItemLevel:SetText(iLevel)
		local r, g, b = GetItemQualityColor(ceil(iRarity/#self.Slots))
		self.ItemLevel:SetTextColor(r, g, b)

		if(LIB) then
			local details = LIB:BuildBonusSet(self.Equip)
			self.Bonuses = LIB:MergeDetails(details)
		else
			self.Equip = dummyTable
			self.Bonuses = dummyTable
		end
		self.Resilience:SetText(self.Bonuses.CR_RESILIENCE)

		for _, module in pairs(modules) do
			if(module.OnInspect) then
				module:OnInspect(self)
			end
		end
	else
		for _, module in pairs(modules) do
			if(module.OnClearInspect) then
				module:OnClearInspect(self)
			end
		end
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
	if(self.unit and (UnitGUID(self.unit) == self.guid or not UnitGUID(self.unit) or not UnitExists(self.unit))) then
		return true
	end
end

InspectUnit = function(unit) InQuiro:Inspect(unit) end
