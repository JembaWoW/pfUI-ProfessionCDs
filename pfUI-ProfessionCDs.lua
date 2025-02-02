local playerName = UnitName("player")
ProfessionCDs = {}
ProfessionCDs[playerName] = {}

pfUI:RegisterModule("ProfessionCDs", "vanilla", function ()

	local font = C.panel.use_unitfonts == "1" and pfUI.font_unit or pfUI.font_default
	local font_size = C.panel.use_unitfonts == "1" and C.global.font_unit_size or C.global.font_size
	local rawborder, default_border = GetBorderSize("panels")

	do
		local widget = CreateFrame("Frame", "pfPanelProfessionCDs",UIParent)
		local _,_,_,green = GetColorGradient(1)
		local _,_,_,red = GetColorGradient(0)

		widget.Tooltip = function()
			GameTooltip_SetDefaultAnchor(GameTooltip, this)
			GameTooltip:ClearLines()

			local first = true
			for name, tbl in pairs(ProfessionCDs) do
				if tbl["Tailoring"] or tbl["Alchemy"] or tbl["Leatherworking"] then
					if not first then GameTooltip:AddLine(" ") end
					first = false
					GameTooltip:AddLine("|cfff5a9b8"..name)
					if tbl["Tailoring"] then
						local mooncloth = green.."Ready!"
						if not tbl["MoonclothCD"] then mooncloth = red.."Unknown" end
						if tbl["MoonclothCD"] and time() < tbl["MoonclothCD"] then mooncloth = red..SecondsToTime(tbl["MoonclothCD"] - time()) end
						GameTooltip:AddDoubleLine("Mooncloth", mooncloth)
					end
					if tbl["Alchemy"] then
						local arcanite = green.."Ready!"
						if not tbl["AlchCD"] then arcanite = red.."Unknown" end
						if tbl["AlchCD"] and time() < tbl["AlchCD"] then arcanite = red..SecondsToTime(tbl["AlchCD"] - time()) end
						GameTooltip:AddDoubleLine("Transmute", arcanite)
					end
					if tbl["Leatherworking"] then
						local salt = green.."Ready!"
						if not tbl["SaltCD"] then salt = red.."Unknown" end
						if tbl["SaltCD"] and time() < tbl["SaltCD"] then salt = red..SecondsToTime(tbl["SaltCD"] - time()) end
						GameTooltip:AddDoubleLine("Refind Salt", salt)
					end
				else
					GameTooltip:AddLine("No cooldown data found.")
					GameTooltip:AddLine("Please open up your professions.")
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
				output = red.."All on CD"
			end
			pfUI.panel:OutputPanel("professions", output, widget.Tooltip)
		end)
	end
	table.insert(pfUI.gui.dropdowns["panel_values"],"professions:Profession CDs")
end)


local ProfessionCDsFrame=CreateFrame("Frame")
ProfessionCDsFrame:RegisterEvent("TRADE_SKILL_SHOW")
ProfessionCDsFrame:RegisterEvent("BAG_UPDATE")
ProfessionCDsFrame:RegisterEvent("BANKFRAME_OPENED")
ProfessionCDsFrame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
ProfessionCDsFrame:RegisterEvent("BAG_UPDATE_COOLDOWN")

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
	if event == "BAG_UPDATE" or event == "BANKFRAME_OPENED" or event == "PLAYERBANKSLOTS_CHANGED" then
		for bag = 0, 10, 1 do
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
					end
				end
			end
		end
    end
end)
