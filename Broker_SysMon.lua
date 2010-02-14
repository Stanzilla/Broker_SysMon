
--[[ Start config ]]

-- Max number of addons to show in the memory plugin tooltip.
local NUM_ADDONS = 30

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
local Crayon = LibStub:GetLibrary("LibCrayon-3.0", true)

local icon = "Interface\\AddOns\\Broker_SysMon\\icon"

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
local rate = {}

local brokers = {
broker:NewDataObject(L["Broker_FPS"], {
	suffix = L["fps"],
	label = L["Framerate"],
	icon = icon,
	type = "data source",
	interval = UPDATE_RATE_FPS,
	func =
		Crayon and
			function()
				local framerate = floor(GetFramerate() + 0.5)
				return format("|cff%s%d|r", Crayon:GetThresholdHexColor(framerate / 60), framerate)
			end
		or
			function() return floor(GetFramerate() + 0.5) end
}),
broker:NewDataObject(L["Broker_Latency"], {
	suffix = L["ms"],
	label = L["Latency"],
	icon = icon,
	type = "data source",
	interval = UPDATE_RATE_LATENCY,
	func =
		Crayon and
			function()
				local latency = select(3, GetNetStats())
				return format("|cff%s%d|r", Crayon:GetThresholdHexColor(latency, 1000, 500, 250, 100, 0), latency)
			end
		or
			function() return select(3, GetNetStats()) end
}),
broker:NewDataObject(L["Broker_IncreasingRate"], {
	suffix = L["kbs"],
	label = L["Increasing Rate"],
	icon = icon,
	type = "data source",
	interval = UPDATE_RATE_INCREASING_RATE,
	func =
		Crayon and
			function()
				local currentRate = 0
				if #rate > 0 then
					currentRate = (rate[#rate] - rate[1]) / #rate
				end
				return format("|cff%s%.1f|r", Crayon:GetThresholdHexColor(currentRate, 30, 10, 3, 1, 0), currentRate)
			end
		or
			function()
				if #rate < 1 then return "0" end
				return format("%.1f",((rate[#rate] - rate[1]) / #rate))
			end
}),
broker:NewDataObject(L["Broker_MemUse"], {
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
	func =
		Crayon and
			function()
				local currentMemory = collectgarbage("count")
				return format("|cff%s%.1f|r", Crayon:GetThresholdHexColor(currentMemory, 51200, 40960, 30520, 20480, 10240), currentMemory / 1024)
			end
		or
			function() return format("%.1f", collectgarbage("count") / 1024) end
})
}

for i, broker in next, brokers do
	broker.OnTooltipShow = function(tt)
		tt:AddLine(broker.label)
		tt:AddLine(format("%s %s", broker.func(), broker.suffix))
		if broker.additionalTooltip then
			tt:AddLine(" ")
			broker.additionalTooltip(tt)
		end
	end
end

local seconds = 0
local function everySecond()
	rate[#rate + 1] = collectgarbage("count")
	if #rate > 10 then table.remove(rate, 1) end
	for i, broker in next, brokers do
		if seconds % broker.interval == 0 then
			local value = broker.func()
			broker.value = value
			broker.text = format("%s %s", value, broker.suffix)
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
				addons[#addons + 1] = GetAddOnInfo(i)
			end
		end
		self:RegisterEvent("ADDON_LOADED")
	else
		addons[#addons + 1] = addon
	end
end)
f:RegisterEvent("PLAYER_LOGIN")
f:Show()

collectgarbage("collect")

