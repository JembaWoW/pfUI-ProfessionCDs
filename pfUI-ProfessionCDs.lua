local playerName = UnitName("player")
ProfessionCDs = {}
ProfessionCDs[playerName] = {}
pfUI:UpdateConfig("ProfessionCDs", nil, "mooncloth", "1")
pfUI:UpdateConfig("ProfessionCDs", nil, "transmute", "1")
pfUI:UpdateConfig("ProfessionCDs", nil, "salt", "1")

pfUI:RegisterModule("ProfessionCDs", "vanilla", function ()

	local font = C.panel.use_unitfonts == "1" and pfUI.font_unit or pfUI.font_default
	local font_size = C.panel.use_unitfonts == "1" and C.global.font_unit_size or C.global.font_size
	local rawborder, default_border = GetBorderSize("panels")

	pfUI.gui.dropdowns.ProfessionCDs_currentChar = {
		"enabled:" .. T["Enabled"],
		"disabled:" .. T["Disabled"]
	}
	pfUI.gui.dropdowns.ProfessionCDs_upcoming = {
		"1:" .. T["1"],
		"2:" .. T["2"],
		"3:" .. T["3"],
		"4:" .. T["4"],
		"5:" .. T["5"],
		"6:" .. T["6"],
		"7:" .. T["7"],
		"8:" .. T["8"],
		"9:" .. T["9"],
		"10:" .. T["10"],
		"disabled:" .. T["Disabled"]
	}

	local CreateConfig = pfUI.gui.CreateConfig

	if pfUI.gui.CreateGUIEntry then -- new pfUI
			pfUI.gui.CreateGUIEntry(T["Thirdparty"], T["Profession CDs"], function()
			CreateConfig(nil, T["Profession Cooldowns |cffffffffby |cfff5a9b8Jemba"], nil, nil, "header")
			CreateConfig(nil, nil, nil, nil, "header")
			CreateConfig(nil, T["Display Current Character"], C.ProfessionCDs, "currentChar", "dropdown", pfUI.gui.dropdowns.ProfessionCDs_currentChar)
			CreateConfig(nil, T["Display X Upcoming CDs"], C.ProfessionCDs, "upcoming", "dropdown", pfUI.gui.dropdowns.ProfessionCDs_upcoming)
			CreateConfig(nil, nil, nil, nil, "header")
			CreateConfig(nil, T["Display Mooncloth CDs"], C.ProfessionCDs, "mooncloth", "checkbox")
			CreateConfig(nil, T["Display Transmute CDs"], C.ProfessionCDs, "transmute", "checkbox")
			CreateConfig(nil, T["Display Refined Salt CDs"], C.ProfessionCDs, "salt", "checkbox")
			CreateConfig(nil, nil, nil, nil, "header")
			CreateConfig(nil, T["Website"], nil, nil, "button", function()
				pfUI.chat.urlcopy.CopyText("https://github.com/JembaWoW/pfUI-ProfessionCDs")
			end)

			panels = {
				{ pfUI.panel.left.left,    C.panel.left.left },
				{ pfUI.panel.left.center,  C.panel.left.center },
				{ pfUI.panel.left.right,   C.panel.left.right },
				{ pfUI.panel.right.left,   C.panel.right.left },
				{ pfUI.panel.right.center, C.panel.right.center },
				{ pfUI.panel.right.right,  C.panel.right.right },
				{ pfUI.panel.minimap,      C.panel.other.minimap },
			}
			local enabled = false
			for i, p in pairs(panels) do
				local frame, config = p[1], p[2]
				if frame.initialized == "professions" then enabled = true end
			end

			if not enabled then
				CreateConfig(nil, T["To use: Panel > add 'Profession CDs' to any panel."], nil, nil, "warning")
			end
		end)
	end

	pfUI:UpdateConfig("ProfessionCDs",       nil,         "currentChar",   "enabled")
	pfUI:UpdateConfig("ProfessionCDs",       nil,            "upcoming",   "3")

	do
		local widget = CreateFrame("Frame", "pfPanelProfessionCDs",UIParent)
		local _,_,_,green = GetColorGradient(1)
		local _,_,_,red = GetColorGradient(0)

		widget.Tooltip = function()
			GameTooltip_SetDefaultAnchor(GameTooltip, this)
			GameTooltip:ClearLines()

			GameTooltip:AddLine("Profession Cooldowns |cffffffffby |cfff5a9b8Jemba")
			GameTooltip:AddLine(" ")

			if C.ProfessionCDs.currentChar == "enabled" then
				for name, tbl in pairs(ProfessionCDs) do
					if name == playerName then
						if tbl["Tailoring"] or tbl["Alchemy"] or tbl["Leatherworking"] then
							GameTooltip:AddLine("|cfff5a9b8"..name)
							if tbl["Tailoring"] and C.ProfessionCDs.mooncloth == "1" then
								local mooncloth = green.."Ready!"
								if not tbl["MoonclothCD"] then mooncloth = red.."Unknown" end
								if tbl["MoonclothCD"] and time() < tbl["MoonclothCD"] then mooncloth = red..SecondsToTime(tbl["MoonclothCD"] - time()) end
								GameTooltip:AddDoubleLine("Mooncloth", mooncloth)
							end
							if tbl["Alchemy"] and C.ProfessionCDs.transmute == "1" then
								local arcanite = green.."Ready!"
								if not tbl["AlchCD"] then arcanite = red.."Unknown" end
								if tbl["AlchCD"] and time() < tbl["AlchCD"] then arcanite = red..SecondsToTime(tbl["AlchCD"] - time()) end
								GameTooltip:AddDoubleLine("Transmute", arcanite)
							end
							if tbl["Leatherworking"] and C.ProfessionCDs.salt == "1" then
								local salt = green.."Ready!"
								if not tbl["SaltCD"] then salt = red.."Unknown" end
								if tbl["SaltCD"] and time() < tbl["SaltCD"] then salt = red..SecondsToTime(tbl["SaltCD"] - time()) end
								GameTooltip:AddDoubleLine("Refined Salt", salt)
							end
						else
							GameTooltip:AddLine("No cooldown data found.")
							GameTooltip:AddLine("Please open up your professions.")
						end
					end
				end
				GameTooltip:AddLine(" ")
			end

			if C.ProfessionCDs.upcoming ~= "disabled" then
				local displayAmount = tonumber(C.ProfessionCDs.upcoming)
				local ShortCD = ProfessionCDsShortestCD()
				local len = table.getn(ShortCD)
				if table.getn(ShortCD) > displayAmount then len = displayAmount end

				GameTooltip:AddLine("Upcoming Cooldowns")
				GameTooltip:AddLine(" ")

				--for i=1,len do
				local i=len
				while i>0 do

					local data = ShortCD[i]
					local alt,key = strsplit(",",data)
					local cooldown = "Mooncloth"

					--CD name
					if key == "AlchCD" then
						cooldown = "Transmute"
					end
					if key == "SaltCD" then
						cooldown = "Refined Salt"
					end

					--CD duation formatting
					local CDduration = ProfessionCDs[alt][key] - time()
					if CDduration <= 0 then
						CDduration = green.."Ready!"
					else
						CDduration = SecondsToTime(CDduration)
					end

					--Name colouring
					if playerName == alt then
						alt = "|cfff5a9b8"..alt
					else
						alt = "|cff5bcefa"..alt
					end

					GameTooltip:AddDoubleLine("|cfff5a9b8"..alt.."|r - "..cooldown, red..CDduration)
					i=i-1
				end
			end

			GameTooltip:Show()
		end

		widget:SetScript("OnUpdate",function()
			if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + 1 end

			local output = red.."No CD Data!"

			local anyCDs = false
			local anyData = false

			for player, tbl in pairs(ProfessionCDs) do
				if tbl["Tailoring"] or tbl["Alchemy"] or tbl["Leatherworking"] then anyData = true end
				if tbl["Tailoring"] and tbl["MoonclothCD"] and time() > tbl["MoonclothCD"] then anyCDs = true end
				if tbl["Alchemy"] and tbl["AlchCD"] and time() > tbl["AlchCD"] then anyCDs = true end
				if tbl["Leatherworking"] and tbl["SaltCD"] and time() > tbl["SaltCD"] then anyCDs = true end
			end

			if anyCDs then
				output = green.."CDs Ready!"
			elseif anyData then
				local ShortCD = ProfessionCDsShortestCD()
				local data = ShortCD[1]
				local alt,key = strsplit(",",data)
				local cooldown = "Mooncloth"
				if key == "AlchCD" then cooldown = "Transmute" end
				if key == "SaltCD" then cooldown = "Refined Salt" end
				local CDduration = SecondsToTime(ProfessionCDs[alt][key] - time())
				output = red..CDduration
			end
			pfUI.panel:OutputPanel("professions", output, widget.Tooltip)
		end)
	end
	table.insert(pfUI.gui.dropdowns["panel_values"],"professions:Profession CDs")
end)


local ProfessionCDsFrame=CreateFrame("Frame")
ProfessionCDsFrame:RegisterEvent("TRADE_SKILL_SHOW")
ProfessionCDsFrame:RegisterEvent("BAG_UPDATE")

ProfessionCDsFrame:SetScript("OnEvent", function()
	if not ProfessionCDs then ProfessionCDs = {} end
	if not ProfessionCDs[playerName] then ProfessionCDs[playerName] = {} end
	if TradeSkillFrame then
		local skill = GetTradeSkillLine()
		if skill == "Alchemy" then ProfessionCDs[playerName]["Alchemy"] = true end
		if skill == "Tailoring" then ProfessionCDs[playerName]["Tailoring"] = true end
		if skill == "Leatherworking" then ProfessionCDs[playerName]["Leatherworking"] = true end
		for i=1,GetNumTradeSkills() do
			if GetTradeSkillInfo(i) == "Transmute: Arcanite" then
				local cd = GetTradeSkillCooldown(i) or 0
				ProfessionCDs[playerName]["AlchCD"] = time()+cd
			end
			if GetTradeSkillInfo(i) == "Mooncloth" then
				local cd = GetTradeSkillCooldown(i) or 0
				ProfessionCDs[playerName]["MoonclothCD"] = time()+cd
			end
		end
	end
	if event == "BAG_UPDATE" then
		for bag = 0, 4, 1 do
			for slot = 1, GetContainerNumSlots(bag), 1 do
				local itemLink = GetContainerItemLink(bag, slot)
				if itemLink then
					local _, _, itemID, itemName = string.find(itemLink, "item:(%d+):%d+:%d+:%d+.*%[(.*)%]")
					if itemID == "15846" then
						startTime, duration = GetContainerItemCooldown(bag,slot)
						ProfessionCDs[playerName]["Leatherworking"] = true
						if startTime then
							ProfessionCDs[playerName]["SaltCD"] = (duration - (GetTime() - startTime)) + time()
						else
							ProfessionCDs[playerName]["SaltCD"] = 0
						end

						if startTime < GetTime() then
							ProfessionCDs[playerName]["SaltCD"] = (duration - (GetTime() - startTime)) + time()
						else
							local time = time()
							local startupTime = time - GetTime()
							local cdTime = (2 ^ 32) / 1000 - startTime
							local cdStartTime = startupTime - cdTime
							local cdEndTime = cdStartTime + duration
							ProfessionCDs[playerName]["SaltCD"] = cdEndTime
						end
					end
				end
			end
		end
    end
end)

function ProfessionCDsShortestCD()
	local tempTBL = {}
	for player, tbl in pairs(ProfessionCDs) do
		if tbl["Tailoring"] and tbl["MoonclothCD"] and pfUI_config.ProfessionCDs.mooncloth == "1" then
			tempTBL[player..",MoonclothCD"] = tbl["MoonclothCD"]
		end
		if tbl["Alchemy"] and tbl["AlchCD"] and pfUI_config.ProfessionCDs.transmute == "1" then
			tempTBL[player..",AlchCD"] = tbl["AlchCD"]
		end
		if tbl["Leatherworking"] and tbl["SaltCD"] and pfUI_config.ProfessionCDs.salt == "1" then
			tempTBL[player..",SaltCD"] = tbl["SaltCD"]
		end
	end

	local sortedKeys = ProfessionCDsgetKeysSortedByValue(tempTBL, function(a, b) return a < b end)

	return sortedKeys

end

function ProfessionCDsgetKeysSortedByValue(tbl, sortFunction)
  local keys = {}
  for key in pairs(tbl) do
    table.insert(keys, key)
  end

  table.sort(keys, function(a, b)
    return sortFunction(tbl[a], tbl[b])
  end)

  return keys
end
