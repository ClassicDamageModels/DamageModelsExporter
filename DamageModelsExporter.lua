local base64 = LibStub('LibBase64-1.0')

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

function OnLoad()
	SlashCmdList["EXPORT"] = Export_Command;
	SLASH_EXPORT1 = "/EXPORT";
end

function Export_Command(arg1)
	local info = GetCharacterInfoData("player")
	local gear = GetCharacterItemsData("player")
	local talents = GetCharacterTalentsData("player")

	local text = '{ '..info..', "gear": { '..gear..' }, "talents": '..talents..' }'
	local encoded = base64:encode(text)

	StaticPopupDialogs["EXPORT_DIALOG"] = {
		text = "Copy and paste the text from below to damagemodels.com",
		button1 = "Close",
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		OnShow = function (self, data)
			self.editBox:SetText(encoded)
			self.editBox:HighlightText()
			self.editBox:SetScript("OnEscapePressed", function() self:Hide() end)
		end,
		hasEditBox = true,
		preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	  }

	  StaticPopup_Show ("EXPORT_DIALOG")
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

	return '"name":"'..UnitName(_Target)..'","level":'..UnitLevel(_Target)..',"sex":"'..sex..'","race":"'..string.lower(race)..'","class":"'..string.lower(class)..'","guild":'..guildname..',"realm":"'..GetRealmName()..'"'
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

			local itemId, enchantId, gem1, gem2, gem3, gem4, suffixId = string.match(item, "(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):(%d*)");

			-- print(item);
			-- print(suffixId);

			--local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4,
			--		Suffix, Unique, LinkLvl, Name = string.find(slotItem,
			-- 
			-- "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")

			--   10096::::::1963:1263271680:60:::1::::

			--10096:  itemId
			--: enchantId
			--: gem1
			--: gem2
			--: gem3
			--: gem4
			--1963: suffixid
			--1263271680: uniqid
			--60: clevel
			--: specid
			--: upgradeId
			--1: difficulty
			--: numbonusId
			--: num
			--:			
			local itemString = itemId ..':'.. enchantId ..':'.. gem1 ..':'.. gem2 ..':'.. gem3 ..':'.. suffixId;
			table.insert(items, '"'..InventoryRenames[slotName]..'": '..'"'..itemString..'"')
		end
	end

	return table.concat(items, ',')
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
