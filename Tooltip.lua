local _G = getfenv(0)

local find = string.find
local gsub = string.gsub
local format = string.format

local classification = {
	worldboss = ' Boss|r',
	rareelite = '+|r Rare',
	rare = '|r Rare',
	elite = '+|r',
}

local function hex(c)
	return format('%02x%02x%02x', c.r * 255, c.g * 255, c.b * 255)
end

GameTooltip:HookScript('OnTooltipSetUnit', function(self)
	local _, unit = self:GetUnit()
	if(not unit or not UnitExists(unit)) then return end

	local localized, class = UnitClass(unit)
	local color = UnitIsPlayer(unit) and RAID_CLASS_COLORS[class] or FACTION_BAR_COLORS[UnitReaction(unit, 'player')]

	-- stupid shit, no api
	local title
	for index = 2, self:NumLines() do
		local text = _G['GameTooltipTextLeft'..index]:GetText()
		if(index == 2 and not text:find('^'..TOOLTIP_UNIT_LEVEL:gsub('%%s', '.+'))) then
			title = text
		end
	end

	self:ClearLines()
	self:AddLine(format('%s|cff%s%s|r', index and format('%s22|t', ICON_LIST[index]) or '', hex(color), GetUnitName(unit)))

	if(UnitIsPlayer(unit)) then
		local level = UnitLevel(unit)
		local index = GetRaidTargetIndex(unit)

		self:AddLine(format('|cff%s%s|r |cffffffff%s %s|r', hex(GetQuestDifficultyColor(UnitIsFriend(unit, 'player') and UnitLevel('player') or level > 0 and level or 99)), level > 0 and level or '??', UnitRace(unit), UnitIsAFK(unit) and CHAT_FLAG_AFK or UnitIsDND(unit) and CHAT_FLAG_DND or not UnitIsConnected(unit) and '<DC>' or ''))

		if(GetGuildInfo(unit)) then
			self:AddLine(GameTooltipTextLeft2:GetText())
			GameTooltipTextLeft2:SetFormattedText('|cff%s<%s>|r', IsInGuild() and UnitIsInMyGuild(unit) and '0090ff' or '00ff10', GetGuildInfo(unit))
		end
	else
		local level = UnitLevel(unit)
		local index = GetRaidTargetIndex(unit)

		self:AddLine(format('|cff%s%s%s|r |cffffffff%s|r', hex(GetQuestDifficultyColor(UnitIsFriend(unit, 'player') and UnitLevel('player') or level > 0 and level or 99)), level > 0 and level or '??', classification[UnitClassification(unit)] or '', UnitCreatureFamily(unit) or UnitCreatureType(unit) or ''))

		if(title) then
			self:AddLine(GameTooltipTextLeft2:GetText())
			GameTooltipTextLeft2:SetFormattedText('|cffffffff<%s>|r', title)
		end
	end

	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:SetPoint('BOTTOMLEFT', 8, 9)
	GameTooltipStatusBar:SetPoint('BOTTOMRIGHT', -8, 9)
	GameTooltipStatusBar:SetStatusBarColor(color.r, color.g, color.b)
	GameTooltipStatusBar:Show()

	self:AddLine(' ')
end)

GameTooltip:HookScript('OnTooltipCleared', function()
	GameTooltipStatusBar:Hide()
end)

GameTooltipStatusBar.text = GameTooltipStatusBar:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
GameTooltipStatusBar.text:SetPoint('CENTER')

GameTooltipStatusBar.bg = GameTooltipStatusBar:CreateTexture(nil, 'BACKGROUND')
GameTooltipStatusBar.bg:SetAllPoints(GameTooltipStatusBar)
GameTooltipStatusBar.bg:SetTexture(0.4, 0.4, 0.4)

GameTooltipStatusBar:SetHeight(7)
GameTooltipStatusBar:SetStatusBarTexture([=[Interface\AddOns\Inomena\media\minimalist]=])
GameTooltipStatusBar:HookScript('OnValueChanged', function(self, value)
	if(value) then
		local min, max = self:GetMinMaxValues()
		if(value == min) then
			self.text:SetText('Dead')
		else
			self.text:SetFormattedText('%d%%', value / max * 100)
		end
	end
end)

for k, v in next, {GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3} do
	v:SetBackdrop({bgFile = [=[Interface\Tooltips\UI-Tooltip-Background]=]})
	v:SetBackdropColor(0.1, 0.1, 0.1)
end
