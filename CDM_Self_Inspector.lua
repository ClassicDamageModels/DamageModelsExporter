InventorySlots = {
	["Head"] = 1,
	["Neck"] = 2,
	["Shoulder"] = 3,
	["Shirt"] = 4,
	["Chest"] = 5,
	["Belt"] = 6,
	["Legs"] = 7,
	["Feet"] = 8,
	["Wrist"] = 9,
	["Gloves"] = 10,
	["Finger1"] = 11,
	["Finger2"] = 12,
	["Trinket1"] = 13,
	["Trinket2"] = 14,
	["Back"] = 15,
	["MainHand"] = 16,
	["OffHand"] = 17,
	["Ranged"] = 18,
	["Tabard"] = 19,
}

InventoryRenames = {
	["Head"] = "head",
	["Neck"] = "amulet",
	["Shoulder"] = "shoulders",
	["Shirt"] = "shirt",
	["Chest"] = "chest",
	["Belt"] = "belt",
	["Legs"] = "legs",
	["Feet"] = "boots",
	["Wrist"] = "bracers",
	["Gloves"] = "hands",
	["Finger1"] = "ring1",
	["Finger2"] = "ring2",
	["Trinket1"] = "trinket1",
	["Trinket2"] = "trinket2",
	["Back"] = "cloak",
	["MainHand"] = "weapon1",
	["OffHand"] = "weapon2",
	["Ranged"] = "ranged",
	["Tabard"] = "tabard",
}

function CDM_OnLoad()
	SlashCmdList["CDM"] = CDM_Command;
	SLASH_CDM1 = "/CDM";
end

function CDM_Command(arg1)
	local info = GetCharacterInfoData("player")
	local gear = GetCharacterItemsData("player")
	local talents = GetCharacterTalentsData("player")

	local text = '{ '..info..', "gear": { '..gear..' }, "talents": '..talents..' }'

	if not MyFrame then
		local f = CreateFrame("Frame","MyFrame",UIParent)
		f:SetFrameStrata("BACKGROUND")
		f:SetWidth(510) 
		f:SetHeight(350) 
		f:SetMovable(true)
		f:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight",
			edgeSize = 16,
			insets = { left = 8, right = 6, top = 8, bottom = 8 },
		})
		f:SetBackdropBorderColor(0, .44, .87, 0.5) 

		local button = CreateFrame("Button", "CloseButton", MyFrame, "GameMenuButtonTemplate")
		button:SetPoint("BOTTOM")
		button:SetWidth(120)
		button:SetHeight(30)
		button:SetText("Close")
		button:SetScript("OnClick", function() f:Hide() end)

		local sf = CreateFrame("ScrollFrame", "ScrollFrame", MyFrame, "UIPanelScrollFrameTemplate")
		sf:SetPoint("LEFT", 16, 0)
		sf:SetPoint("RIGHT", -32, 0)
		sf:SetPoint("TOP", 0, -16)
		sf:SetHeight(300)
		sf:SetWidth(500)

		eb = CreateFrame("EditBox", "EditBox", MyFrame)
		eb:SetHeight(300)
		eb:SetWidth(460)
		eb:SetMultiLine(true)
		eb:SetAutoFocus(true) 
		eb:SetFontObject("ChatFontNormal")	
		sf:SetScrollChild(eb)

		f:SetResizable(true)
		f:SetMinResize(150, 100)

		f:SetPoint("CENTER",0,0)
		eb:SetScript("OnEscapePressed", function() f:Hide() end)
	end

	EditBox:SetText(text)
	EditBox:HighlightText()
	MyFrame:Show()
end

function GetCharacterInfoData(_Target)
	local characterName = UnitName(_Target);
	local _, race = UnitRace(_Target);
	local _, class = UnitClass(_Target);
	local guildname, guildtitle, guildrank = GetGuildInfo(_Target);
	if(guildname == nil) then guildname = "null"; else guildname = '"'..guildname..'"' end
	if(guildtitle == nil) then guildtitle = ""; end
	if(guildrank == nil) then guildrank = 0; end
	if(UnitSex(_Target) == 2) then sex = 'male'; else sex = 'female'; end
	
	return '"name": "'..UnitName(_Target)..'", "level": '..UnitLevel(_Target)..', "sex": "'..sex..'", "race": "'..string.lower(race)..'", "class": "'..string.lower(class)..'", "guild": '..guildname..', "realm": "'..GetRealmName()..'"'
end

function GetCharacterItemsData(_Target)
	local characterName = UnitName(_Target);

	local items = {};
	local allItemsList = {};
	for slotName, slotID in pairs(InventorySlots) do
		local slotItem = GetInventoryItemLink(_Target, slotID);
		if(slotItem ~= nil) then
			local _, _, rubbish1, item, rubbish2 = string.find(slotItem, "(.*)|Hitem:(.*)|h%[(.*)");
			slotItem = item;

			table.insert(items, '"'..InventoryRenames[slotName]..'": '..'"'..item..'"')
		end
	end

	return table.concat(items, ', ')
end

function GetCharacterTalentsData(_Target)
	local characterName = UnitName(_Target);
	local talentData = "[";
	
	function _GetTalentPageData(_PageIndex, _IsPlayer)
		local talentData = "";
		local numTalents = GetNumTalents(_PageIndex, _IsPlayer ~= true);
		for i=1, numTalents do
			local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(_PageIndex, i, _IsPlayer ~= true);
			talentData = talentData..rank;
		end
		return talentData;
	end

	talentData = talentData..'"'.._GetTalentPageData(1, true)..'",';
	talentData = talentData..'"'.._GetTalentPageData(2, true)..'",';
	talentData = talentData..'"'.._GetTalentPageData(3, true)..'"]';

	return talentData
end
