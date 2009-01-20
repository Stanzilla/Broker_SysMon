
--[[ Start config ]]

-- Max number of addons to show in the memory plugin tooltip
local NUM_ADDONS = 10

-- How often the various plugins should update their label/text display
-- (an update is always triggered when showing the tooltip)
local UPDATE_RATE_FPS = 1
local UPDATE_RATE_LATENCY = 1
local UPDATE_RATE_INCREASING_RATE = 1
local UPDATE_RATE_MEMORY = 30

--[[ End config ]]

local format = string.format
local broker = LibStub("LibDataBroker-1.1")
local L = LibStub("AceLocale-3.0"):GetLocale("Broker_SysMon")

local icon = "Interface\\AddOns\\Broker_SysMon\\icon"

local FPS = broker:NewDataObject(L["Broker_FPS"], {
	suffix = L["fps"],
	label = L["Framerate"],
	icon = icon,
	type = "data source",
	interval = UPDATE_RATE_FPS,
})

local Lag = broker:NewDataObject(L["Broker_Latency"], {
	suffix = L["ms"],
	label = L["Latency"],
	icon = icon,
	type = "data source",
	interval = UPDATE_RATE_LATENCY,
})

local rate = {}
local IncreasingRate = broker:NewDataObject(L["Broker_IncreasingRate"], {
	suffix = L["kbs"],
	label = L["Increasing Rate"],
	icon = icon,
	type = "data source",
	interval = UPDATE_RATE_INCREASING_RATE,
})

local addons = {}
local function memorySorter(a, b)
	local aM = GetAddOnMemoryUsage(a)
	local bM = GetAddOnMemoryUsage(b)
	return aM > bM
end
local function formatMemory(addon)
	local n = GetAddOnMemoryUsage(addon)
	if n > 1024 then return format("%.2f mb", n / 1024)
	else return format("%.2f kb", n) end
end
local ttFormat = "%d. %s"
local MemUse = broker:NewDataObject(L["Broker_MemUse"], {
	suffix = L["mb"],
	label = L["Memory Usage"],
	icon = icon,
	type = "data source",
	interval = UPDATE_RATE_MEMORY,
	OnClick = function() collectgarbage("collect") end,
	additionalTooltip = function(tt)
		UpdateAddOnMemoryUsage()
		table.sort(addons, memorySorter)
		for i = 1, (#addons < NUM_ADDONS and #addons or NUM_ADDONS) do
			tt:AddDoubleLine(ttFormat:format(i, addons[i]), formatMemory(addons[i]), 1, 1, 1, 0.2, 1, 0.2)
		end
		tt:AddLine(" ")
		tt:AddLine(L["List above shows the top %d addons with regards to memory usage."]:format(NUM_ADDONS), 0.2, 1, 0.2, 1)
	end,
})

local brokers = {
    [FPS] = function() return floor(GetFramerate() + 0.5) end,
    [Lag] = function() return select(3, GetNetStats()) end,
    [MemUse] = function() return format("%.1f", collectgarbage("count") / 1024) end,
    [IncreasingRate] = function()
    	if #rate < 1 then return "0" end
    	return format("%.1f",((rate[#rate] - rate[1]) / #rate))
    end,
}

for k, v in pairs(brokers) do
	k.OnTooltipShow = function(tt)
		tt:AddLine(k.label)
		tt:AddLine(format("%s %s", v(), k.suffix))
		if k.additionalTooltip then
			tt:AddLine(" ")
			k.additionalTooltip(tt)
		end
	end
end

local seconds = 0
local function everySecond()
	table.insert(rate, collectgarbage("count"))
	if #rate > 10 then table.remove(rate, 1) end
	for k, v in pairs(brokers) do
		if seconds % k.interval == 0 then
			local value = v()
			k.value = value
			k.text = format("%s %s", value, k.suffix)
		end
	end
	seconds = seconds + 1
	if seconds == 1000 then seconds = 0 end
end

local f = CreateFrame("Frame")
local total = 0
f:SetScript("OnUpdate", function(self, elapsed)
	total = total + elapsed
	if total < 1 then return end
	everySecond()
	total = 0
end)
f:SetScript("OnEvent", function(self, event, addon)
	if event == "PLAYER_LOGIN" then
		for i = 1, GetNumAddOns() do
			if IsAddOnLoaded(i) then
				table.insert(addons, (GetAddOnInfo(i)))
			end
		end
		self:RegisterEvent("ADDON_LOADED")
	else
		table.insert(addons, addon)
	end
end)
f:RegisterEvent("PLAYER_LOGIN")
f:Show()

collectgarbage("collect")

