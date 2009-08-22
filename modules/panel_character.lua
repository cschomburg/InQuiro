local iQ = InQuiro
local char = iQ:CreateTabDialog(CHARACTER)
char.ShowEquip = true

local StatEntryOrder = {
	{ name = PLAYERSTAT_BASE_STATS, stats = {"STR", "AGI", "STA", "INT", "SPI", "ARMOR"} },
	{ name = HEALTH.." & "..MANA, stats = {"HP", "MP", "HP5", "MP5"} },
	{ name = MELEE.." & "..RANGED, stats = {"AP", "RAP", "APFERAL", "CRIT", "HIT", "HASTE", "WPNDMG", "RANGEDDMG", "ARMORPENETRATION", "EXPERTISE"} },
	{ name = PLAYERSTAT_SPELL_COMBAT, stats = {"HEAL", "SPELLDMG", "ARCANEDMG", "FIREDMG", "NATUREDMG", "FROSTDMG", "SHADOWDMG", "HOLYDMG", "SPELLCRIT", "SPELLHIT", "SPELLHASTE", "SPELLPENETRATION"} },
	{ name = PLAYERSTAT_DEFENSES, stats = {"DEFENSE", "DODGE", "PARRY", "BLOCK", "BLOCKVALUE", "RESILIENCE"} },
}


--[[ ##################
	Layout
#################### ]]
local prev
for i = 1, 5 do
	local resist = CreateFrame("Frame", nil, char)
	resist:SetWidth(32)
	resist:SetHeight(27)
	resist:SetScale(.8)

	resist.texture = resist:CreateTexture(nil,"BACKGROUND")
	resist.texture:SetTexture([[Interface\PaperDollInfoFrame\UI-Character-ResistanceIcons]])
	resist.texture:SetTexCoord(0,1,(i - 1) * 0.11328125 + 0.016,i * 0.11328125);
	resist.texture:SetAllPoints();

	resist.value = resist:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
	resist.value:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
	resist.value:SetPoint("BOTTOM", 1, 3)
	resist.value:SetTextColor( 1, 1, 0)

	if(not prev) then
		resist:SetPoint("BOTTOMLEFT", 124, 58)
	else
		resist:SetPoint("LEFT", prev ,"RIGHT")
	end
	prev = resist

	char["Resist"..i] = resist
end

iQ.NumLines = 20
for i = 1, iQ.NumLines do
	local t = CreateFrame("Frame", nil, char)
	t:SetWidth(200)
	t:SetHeight(12)
	t.id = i

	if (i == 1) then
		t:SetPoint("TOPLEFT", 60, -40)
	else
		t:SetPoint("TOP", char[i-1],"BOTTOM")
	end

	t.left = t:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
	t.left:SetPoint("LEFT")
	t.right = t:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
	t.right:SetPoint("RIGHT")

	t:SetScript("OnEnter",function(self) GameTooltip:SetOwner(self,"ANCHOR_RIGHT"); GameTooltip:SetText(self.tip) end)
	t:SetScript("OnLeave", iQ.GTTHide)

	char[i] = t
end
local scroll = CreateFrame("ScrollFrame", "iQCharScroll", char, "FauxScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", char[1])
scroll:SetPoint("BOTTOMRIGHT", char[iQ.NumLines], -3, -1)


--[[ ##################
	Core
#################### ]]

function iQ:BuildStatList()
	local stats, set, iLevel = {}, {}, 0
	ExScanner:ScanUnitItems(iQ.unit, stats, set)

	local lastHeader
	local value, tip
	if(not self.StatList) then
		self.StatListNames = {}
		self.StatListValues = {}
	end
	local names, values = self.StatListNames, self.StatListValues

	local line, Header = 0, nil
	for _, statCat in ipairs(StatEntryOrder) do
		for _, statToken in ipairs(statCat.stats) do
			if(stats[statToken]) then
				if(not Header) then
					line = (line > 0 and line+2) or 1
					names[line], values[line] = statCat.name
					Header = true
				end
				line = line+1
				names[line], values[line] = ExScanner.StatNames[statToken], stats[statToken] or 0
			end
		end
		Header = nil
	end

	for setName, setEntry in pairs(set) do
		if(not Header) then
			line = line+2
			names[line], values[line] = "Sets"
			Header = true
		end
		line = line+1
		names[line], values[line] = setName, setEntry.count.."/"..setEntry.max
	end
	
	if(self.StatLines and line < self.StatLines) then
		for i=line+1, self.StatLines do
			names[i], values[i] = nil, nil
		end
	end
	self.StatLines = line
	
	self.Resilience:SetText(stats["RESILIENCE"] or "")
	
	self:UpdateResistances(stats)
	self.UpdateStatsFrame()
end

local schools = { "FIRE", "NATURE", "ARCANE", "FROST", "SHADOW", "HOLY" }

function iQ:UpdateResistances(stats)
	for i = 1, 5 do
		local button = char["Resist"..i]
		local statToken = schools[i].."RESIST"
		if(stats[statToken]) then
			button.value:SetText(stats[statToken])
			button:SetAlpha(1)
		else
			button.value:SetText("")
			button:SetAlpha(.5)
		end
	end
end

function iQ.UpdateStatsFrame()
	FauxScrollFrame_Update(scroll, iQ.StatLines, iQ.NumLines, 12)
	local offset = FauxScrollFrame_GetOffset(scroll)
	local names, values = iQ.StatListNames, iQ.StatListValues
	for index = 1, iQ.NumLines do
		local i, entry = offset+index, char[index]
		if(names[i]) then
			if(values[i]) then
				entry.left:SetTextColor(1, .8, .0)
				entry.left:SetText("   "..names[i])
				entry.right:SetText(values[i])
			else
				entry.left:SetTextColor(1, 1, 1)
				entry.left:SetText(names[i])
				entry.right:SetText("")
			end
		else
			entry.left:SetText("");
			entry.right:SetText("");
		end
	end
end

iQ.Callbacks[char] = iQ.BuildStatList
scroll:SetScript("OnVerticalScroll", function(self,offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, 12, iQ.UpdateStatsFrame)
end)