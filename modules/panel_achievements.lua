local IQ = InQuiro
local oth = IQ:CreateTabDialog(ACHIEVEMENTS)

local professions = { 1527, 1532, 1535, 1544, 1538, 1539, 1540, 1536, 1537, 1541, 1542 }
local statistics = {
	['Cook'] = 1524,
	['Aid'] = 281,
	['Fish'] = 1519,
	['Mounts'] = 339,
	['Pets'] = 338,
}

local achieveCats, achieve = {
	['Small'] =					{ 46, 1516, 1563, 2143, 2144, 2188, 730, 1250, 942, 953, 1681 },
	[LFG_TYPE_DUNGEON] =		{ 1288, 1289, 2136, 2137, 2138 },
	[LFG_TYPE_BATTLEGROUND] =	{ 1167, 1169, 1171, 1172, 2194 },
--	[ARENA] =					{ 2090, 2093, 2092, 2091, 1174 },
	["Fishing"] =				{ 1836, 1837, 726, 2096, 878 }
}, {}

local OnEnter = function(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:AddLine(self.name)
	GameTooltip:AddLine(self.desc, 1,1,1)
	GameTooltip:Show()
end

local function CreateAchievementButton(id, hasText)
	local frame = CreateFrame("Frame", nil, oth)
	frame:SetWidth(36)
	frame:SetHeight(36)
	frame.id = id
	frame:EnableMouse(true)
	frame:SetScript("OnEnter", OnEnter)
	frame:SetScript("OnLeave", IQ.GTTHide)
	
	local name, desc, icon
	if(id) then
		_, name, _, _, _, _, _, desc, _, icon = GetAchievementInfo(frame.id)
		frame.name, frame.desc = name, desc
	end
	
	local art = frame:CreateTexture(nil, "ARTWORK")
	art:SetTexture(icon or [[Interface\Icons\Spell_Misc_HellifrePVPHonorHoldFavor]])
	art:SetPoint("CENTER", 0, 3)
	art:SetWidth(25)
	art:SetHeight(25)
	
	local border = frame:CreateTexture(nil, "OVERLAY")
	border:SetTexture([[Interface\AchievementFrame\UI-Achievement-IconFrame]])
	border:SetPoint("CENTER", -1, 2)
	border:SetWidth(36)
	border:SetHeight(36)
	border:SetTexCoord(0, 0.5625, 0, 0.5625)
	
	if(hasText) then
		local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		text:SetPoint("LEFT", frame, "RIGHT", 5, 0)
		if(name) then text:SetText(name) end
		frame.value = text
	end
	
	frame.border = border
	frame.texture = art
	
	return frame
end

local nr, prev = 0
for name, subAch in pairs(achieveCats) do
	if(name == "Small") then
		for i=1, #subAch do
			local button = CreateAchievementButton(subAch[i])
			button:SetPoint("TOPRIGHT", -5, -(i-1)*35-10)
			button:SetScale(.8)
			tinsert(achieve, button)
		end
	else
		local cat = oth:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		cat:SetText(name)
		if(prev) then
			cat:SetPoint("LEFT", prev, "RIGHT", 30, 0)
		else
			cat:SetPoint("TOPLEFT", 20, -20)
		end
		prev = cat
		for i=1, #subAch do
			local button = CreateAchievementButton(subAch[i])
			button:SetPoint("TOP", cat, "BOTTOM", 0, (i-1)*-40-5)
			tinsert(achieve, button)
		end
	end
end
achieveCats, CreateAchievementButton, nr, prev = nil

for i=1, 2 do
	local bar = CreateFrame("StatusBar", nil, oth)
	bar:SetStatusBarTexture([[Interface\PaperDollInfoFrame\UI-Character-Skills-Bar]])
	bar:SetStatusBarColor(.7, .8, 1)
	bar:SetWidth(101)
	bar:SetHeight(13)
	bar:SetMinMaxValues(0, 450)
	bar:SetPoint("BOTTOM", -10, i*30+35)
	
	local left = bar:CreateTexture(nil, "OVERLAY")
	left:SetWidth(77)
	left:SetHeight(13)
	left:SetPoint("LEFT", -15, 0)
	left:SetTexture([[Interface\PaperDollInfoFrame\UI-Character-ReputationBar]])
	left:SetTexCoord(0.691, 1, 0.047, 0.281)
	
	local right = bar:CreateTexture(nil, "OVERLAY")
	right:SetWidth(42)
	right:SetHeight(13)
	right:SetPoint("LEFT", left, "RIGHT")
	right:SetTexture([[Interface\PaperDollInfoFrame\UI-Character-ReputationBar]])
	right:SetTexCoord(0, 0.164, 0.3906, 0.625)
	
	local name = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	name:SetPoint("RIGHT", bar, "LEFT", -5, 0)
	bar.name = name
	
	local value = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	value:SetPoint("LEFT", bar, "RIGHT", 5, 0)
	bar.value = value

	achieve['skill'..i] = bar
end

local prev
for name, id in pairs(statistics) do
	local cat = oth:CreateFontString(nil, "OVERLAY", "SystemFont_Tiny")
	cat:SetText(name)
	if(prev) then
		cat:SetPoint("LEFT", prev, "RIGHT", 30, 0)
	else
		cat:SetPoint("BOTTOMLEFT", 10, 30)
	end
	prev = cat

	local value = oth:CreateFontString(nil, "OVERLAY", "SystemFont_Tiny")
	value:SetPoint("TOP", cat, "BOTTOM", 0, -5)
	value.id = id
	statistics[name] = value
end

local awaiting
oth:RegisterEvent("INSPECT_ACHIEVEMENT_READY", function(self)
	if(AchievementFrameComparison) then AchievementFrameComparison:RegisterEvent"INSPECT_ACHIEVEMENT_READY" end

	for _, frame in ipairs(achieve) do
		if(GetAchievementComparisonInfo(frame.id)) then
			frame:SetAlpha(1)
			frame.texture:SetVertexColor(1, 1, 1, 1)
			frame.border:SetVertexColor(1, 1, 1, 1)
			if(frame.value) then frame.value:SetTextColor(1, 1, 1) end
		else
			frame:SetAlpha(.8)
			frame.texture:SetVertexColor(.55, .55, .55, 1)
			frame.border:SetVertexColor(.5, .5, .5, 1)
			if(frame.value) then frame.value:SetTextColor(.5, .5, .5) end
		end
	end
	
	local i=0
	for _, id in pairs(professions) do
		local skill = GetComparisonStatistic(id)
		if(skill and skill ~= "--") then
			i = i + 1
			local entry = achieve['skill'..i]
			if(entry) then
				local name = select(2, GetAchievementInfo(id))
				entry.name:SetText(name:match("%a*%s(%a*)%s%a") or name)
				entry.value:SetText(skill)
				skill = tonumber(skill:match("(%d+) / %d+"))
				if(skill) then entry:SetValue(skill) end
				entry:Show()
			else
				break
			end
		end
	end
	if(i<1 or i>2) then
		achieve.skill1:Hide()
		achieve.skill2:Hide()
	end
	
	for _, frame in pairs(statistics) do
		local value = GetComparisonStatistic(frame.id)
		value = tonumber(value) or value:match("(%d+) / %d+") or value
		frame:SetText(value)
	end

	ClearAchievementComparisonUnit()
end)

function oth:OnInspect()
	ClearAchievementComparisonUnit()
	SetAchievementComparisonUnit(IQ.unit)
	if(AchievementFrameComparison) then AchievementFrameComparison:UnregisterEvent"INSPECT_ACHIEVEMENT_READY" end
end