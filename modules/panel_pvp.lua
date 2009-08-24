local IQ = InQuiro
local pvp = IQ:CreateTabDialog(PVP)

PLAYED_STRING = "played |cffffffff%d|r of |cffffffff%d|r    (|cffffffff%.0f%%|r)"
WINLOSS_STRING = "win |cff00ff00%d|r - |cffff0000%d|r loss    (|cffffffff%.0f%%|r)"

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
pvp.Header:SetScript("OnEnter", IQ.GTTShow)
pvp.Header:SetScript("OnLeave", IQ.GTTHide)

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

for i=1, MAX_ARENA_TEAMS do
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

	local name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	name:SetPoint("TOPLEFT", banner, "TOPRIGHT", 5, -5)

	local type = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
	type:SetPoint("TOPRIGHT", -8, -8)
	type:SetTextColor(1, 1, 1, 0.2)

	local played = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	played:SetTextColor(0.56, 0.56, 0.56)
	played:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 10, -10)

	local winloss = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	winloss:SetTextColor(0.56, 0.56, 0.56)
	winloss:SetPoint("TOPLEFT", played, "BOTTOMLEFT", 0, -10)

	local rating = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
	rating:SetPoint("BOTTOMRIGHT", -8, 8)

	local personal = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	personal:SetPoint("BOTTOMRIGHT", rating, "TOPRIGHT", 0, 8)
	personal:SetTextColor(0.6, 0.8, 0.6)

	frame:SetPoint("TOPLEFT", honor, "BOTTOMLEFT", 0, -20-(i-1)*90)
	
	frame.Banner = banner
	frame.Border = border
	frame.Emblem = emblem

	frame.Name = name
	frame.Type = type
	frame.Played = played
	frame.WinLoss = winloss
	frame.Rating = rating
	frame.Personal = personal

	pvp["Arena"..i] = frame
end

--[[ ##################
	Functions
#################### ]]

local awaiting
function pvp:OnInspect()
	awaiting = true
	if(UnitIsUnit("player", IQ.unit)) then
		pvp:UpdateDisplay()
	else
		RequestInspectHonorData()
	end
end

function pvp:UpdateDisplay()
	local faction = UnitFactionGroup(IQ.unit)
	local todayKills, todayHonor, yesterdayKills, yesterdayHonor, lifeKills, rank
	if(UnitIsUnit("player", IQ.unit)) then
		todayKills, todayHonor = GetPVPSessionStats()
		yesterdayKills, yesterdayHonor = GetPVPYesterdayStats()
		lifeKills, rank = GetPVPLifetimeStats()
	else
		todayKills, todayHonor, yesterdayKills, yesterdayHonor, lifeKills, rank = GetInspectHonorData()
	end

	for i=1, MAX_ARENA_TEAMS do
		local frame = self["Arena"..i]
		-- The longest API-query I've ever seen
		local name, size, rating, played, wins, playerPlayed, playerRating
		local bg_r, bg_g, bg_b, emb, emb_r, emb_g, emb_b, bor, bor_r, bor_g, bor_b
		if(UnitIsUnit("player", IQ.unit)) then
			name, size, rating, played, wins, _, _, playerPlayed, _, _, playerRating, g_r, bg_g, bg_b, emb, emb_r, emb_g, emb_b, bor, bor_r, bor_g, bor_b = GetArenaTeam(i)
		else
			name, size, rating, played, wins, playerPlayed, playerRating, bg_r, bg_g, bg_b, emb, emb_r, emb_g, emb_b, bor, bor_r, bor_g, bor_b = GetInspectArenaTeamData(i)
		end
		if(name) then
			frame:Show()

			frame.Name:SetText(name)
			frame.Type:SetText(size.."v"..size)
			frame.Played:SetFormattedText(PLAYED_STRING, playerPlayed, played, max(0, playerPlayed/played*100))
			frame.WinLoss:SetFormattedText(WINLOSS_STRING, wins, played-wins, max(0, wins/played*100))
			frame.Rating:SetText(rating)
			frame.Personal:SetText(playerRating.."p")

			frame.Banner:SetTexture("Interface\\PVPFrame\\PVP-Banner-"..size)
			frame.Banner:SetVertexColor(bg_r, bg_g, bg_b)
			frame.Emblem:SetTexture("Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-"..emb)
			frame.Emblem:SetVertexColor(emb_r, emb_g, emb_b)
			frame.Border:SetTexture("Interface\\PVPFrame\\PVP-Banner-"..size.."-Border-"..bor)
			frame.Border:SetVertexColor(bor_r, bor_g, bor_b)
		else
			frame:Hide()
		end
	end
	if(rank == 0 and faction) then
		self.HeaderIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..faction)
		self.HeaderIcon:SetTexCoord(0,0.59375,0,0.59375)
		self.HeaderText:SetText("-")
	elseif(rank ~= 0) then
		self.HeaderIcon:SetTexture("Interface\\PvPRankBadges\\PvPRank"..format("%.2d", rank-4))
		self.HeaderIcon:SetTexCoord(0,1,0,1)
		self.HeaderText:SetText(rank-4)
	else
		self.HeaderIcon:SetTexture()
		self.HeaderText:SetText("")
	end

	self.Header.tip = GetPVPRankInfo(rank, self.unit)
	self.TodayKills:SetText(todayKills)
	self.TodayHonor:SetText(todayHonor)
	self.YesterdayKills:SetText(yesterdayKills)
	self.YesterdayHonor:SetText(yesterdayHonor)
	self.LifetimeKills:SetText(lifeKills)
end
pvp:RegisterEvent("INSPECT_HONOR_UPDATE", pvp.UpdateDisplay)