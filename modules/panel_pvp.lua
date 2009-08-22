local iQ = InQuiro
local pvp = iQ:CreateTabDialog(PVP)


--[[ ##################
	Layout
#################### ]]
pvp.HeaderText = pvp:CreateFontString(nil, "OVERLAY")
pvp.HeaderText:SetFont("Fonts\\FRIZQT__.TTF", 14, "THICKOUTLINE")
pvp.HeaderText:SetText("11")
pvp.HeaderText:SetPoint("TOPRIGHT", -10, -10)

pvp.HeaderIcon = pvp:CreateTexture(nil, "ARTWORK")
pvp.HeaderIcon:SetPoint("RIGHT", pvp.HeaderText, "LEFT", -5, 0)
pvp.HeaderIcon:SetWidth(18)
pvp.HeaderIcon:SetHeight(18)

pvp.Header = CreateFrame("Frame", nil, pvp)
pvp.Header:EnableMouse(true)
pvp.Header:SetPoint("TOPLEFT", pvp.HeaderIcon)
pvp.Header:SetPoint("BOTTOMRIGHT", pvp.HeaderText)
pvp.Header:SetScript("OnEnter", iQ.GTTShow)
pvp.Header:SetScript("OnLeave", iQ.GTTHide)

local kills = pvp:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
kills:SetText(KILLS_PVP)
kills:SetPoint("TOPLEFT", 20, -30)
local honor = pvp:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
honor:SetText(HONOR)
honor:SetPoint("TOPRIGHT", kills, "BOTTOMRIGHT", 0, -8)
local today = pvp:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
today:SetText(HONOR_TODAY)
today:SetPoint("BOTTOMLEFT", kills, "TOPRIGHT", 20, 8)
local yesterday = pvp:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
yesterday:SetText(HONOR_YESTERDAY)
yesterday:SetPoint("LEFT", today, "RIGHT", 20, 0)
local lifetime = pvp:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
lifetime:SetText(HONOR_LIFETIME)
lifetime:SetPoint("LEFT", yesterday, "RIGHT", 20, 0)

pvp.TodayKills = pvp:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
pvp.TodayKills:SetPoint("TOP", today, "BOTTOM", 0, -8)

pvp.TodayHonor = pvp:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
pvp.TodayHonor:SetPoint("TOP", pvp.TodayKills, "BOTTOM", 0, -8)

pvp.YesterdayKills = pvp:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
pvp.YesterdayKills:SetPoint("TOP", yesterday, "BOTTOM", 0, -8)

pvp.YesterdayHonor = pvp:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
pvp.YesterdayHonor:SetPoint("TOP", pvp.YesterdayKills, "BOTTOM", 0, -8)

pvp.LifetimeKills = pvp:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
pvp.LifetimeKills:SetPoint("TOP", lifetime, "BOTTOM", 0, -8)

local lthonor = pvp:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
lthonor:SetPoint("TOP", pvp.LifetimeKills, "BOTTOM", 0, -8)
lthonor:SetText("-")

-- Arena teams
local backdrop = {bgFile = [[Interface/Tooltips/UI-Tooltip-Background]],
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
}

for i=1, 3 do
	local frame = CreateFrame("Frame", nil, pvp)
	frame:SetBackdrop(backdrop)
	frame:SetBackdropColor(0, 0, 0, .5)
	frame:SetWidth(304)
	frame:SetHeight(82)
	
	local banner = frame:CreateTexture(nil, "BORDER")
	banner:SetPoint("TOPLEFT", 6, -4)
	banner:SetWidth(45)
	banner:SetHeight(90)
	
	local border = frame:CreateTexture(nil, "ARTWORK")
	border:SetPoint("TOPLEFT", banner)
	border:SetPoint("BOTTOMRIGHT", banner)
	
	local emblem = frame:CreateTexture(nil, "OVERLAY")
	emblem:SetPoint("CENTER", border, -5, 17)
	emblem:SetWidth(24)
	emblem:SetHeight(24)
	
	frame:SetPoint("TOPLEFT", honor, "BOTTOMLEFT", 0, -20-(i-1)*90)
	
	frame.Banner = banner
	frame.Border = border
	frame.Emblem = emblem
end

--[[ ##################
	Functions
#################### ]]

local awaiting
iQ.Callbacks[pvp] = function(self)
	awaiting = true
	if(UnitIsUnit("player", self.unit)) then
		iQ:INSPECT_HONOR_UPDATE()
	else
		RequestInspectHonorData()
	end
end

function iQ:INSPECT_HONOR_UPDATE()
	if(not self:CheckLastUnit() or not awaiting) then return end
	awaiting = nil
	
	local faction = UnitFactionGroup(self.unit)
	local todayKills, todayHonor, yesterdayKills, yesterdayHonor, lifeKills, rank
	if(UnitIsUnit("player", self.unit)) then
		todayKills, todayHonor = GetPVPSessionStats()
		yesterdayKills, yesterdayHonor = GetPVPYesterdayStats()
		lifeKills, rank = GetPVPLifetimeStats()
	else
		todayKills, todayHonor, yesterdayKills, yesterdayHonor, lifeKills, rank = GetInspectHonorData()
	end

	if(rank == 0 and faction) then
		pvp.HeaderIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..faction)
		pvp.HeaderIcon:SetTexCoord(0,0.59375,0,0.59375)
		pvp.HeaderText:SetText("-")
	elseif(rank ~= 0) then
		pvp.HeaderIcon:SetTexture("Interface\\PvPRankBadges\\PvPRank"..format("%.2d", rank-4))
		pvp.HeaderIcon:SetTexCoord(0,1,0,1)
		pvp.HeaderText:SetText(rank-4)
	else
		pvp.HeaderIcon:SetTexture()
		HeaderText("")
	end
	
	pvp.Header.tip = GetPVPRankInfo(rank, self.unit)
	pvp.TodayKills:SetText(todayKills)
	pvp.TodayHonor:SetText(todayHonor)
	pvp.YesterdayKills:SetText(yesterdayKills)
	pvp.YesterdayHonor:SetText(yesterdayHonor)
	pvp.LifetimeKills:SetText(lifeKills)
end
iQ:RegisterEvent"INSPECT_HONOR_UPDATE"