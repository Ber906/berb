if tostring(game.PlaceId) ~= "107778070777162" then
	print("[SAE] Wrong PlaceId (" .. tostring(game.PlaceId) .. "). Aborting.")
	return
end

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Players = game:GetService("Players")

while not Players.LocalPlayer do
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
end

local chsaeReleaseVersion, chsaeBuildId, fn, HttpService, ReplicatedStorage, TeleportService, TweenService, RunService, CollectionService, Stats
local Players2, localPlayer, fn2, lua, v2

-- [UI/key system removed - headless mode]
do
	chsaeReleaseVersion = "v4.5"
	chsaeBuildId = "2026-10-01-v4.5-release-r160-key-r2"

	if type(_G.AutoStealCtl) == "table" and type(_G.AutoStealCtl.panic) == "function" then
		pcall(_G.AutoStealCtl.panic)
	elseif type(_G.AutoStealCtl) == "table" and type(_G.AutoStealCtl.stop) == "function" then
		pcall(_G.AutoStealCtl.stop)
	end

	_G.AutoSteal = false
	_G.AutoStealCtl = nil


	fn = function()
		return true
	end

	local tbl3_save = nil

	GetSaveModule = function()
		if tbl3_save then return tbl3_save end
		local Save = require(game:GetService("ReplicatedStorage").Shared.Save)
		if tbl3_save then return tbl3_save end
		assert(type(Save) == "table", "CloverHub: Save module did not return a table")
		local get = Save.Get
		if type(get) ~= "function" then
			assert(type(Save.Peek) == "function" and type(Save.Await) == "function", "CloverHub: unsupported Save read API")
			get = function(arg)
				local v3 = Save.Peek(arg)
				if v3 ~= nil then return v3 end
				return Save.Await(arg)
			end
		end
		local fieldSignal = Save.FieldSignal or Save.Watch
		assert(type(fieldSignal) == "function", "CloverHub: unsupported Save watch API")
		tbl3_save = { Get = get, FieldSignal = fieldSignal }
		return tbl3_save
	end

	tbl.IdleWorkerWake = Instance.new("BindableEvent")
	tbl.IdleWorkerWakeQueued = false

	tbl.WakeIdleWorkers = function(arg)
		if not fn() or tbl.IdleWorkerWakeQueued then return end
		tbl.IdleWorkerWakeQueued = true
		task.defer(function()
			tbl.IdleWorkerWakeQueued = false
			if fn() then pcall(function() tbl.IdleWorkerWake:Fire(arg or "setting") end) end
		end)
	end

	HttpService = game:GetService("HttpService")
	ReplicatedStorage = game:GetService("ReplicatedStorage")
	TeleportService = game:GetService("TeleportService")
	TweenService = game:GetService("TweenService")
	RunService = game:GetService("RunService")
	CollectionService = game:GetService("CollectionService")
	Stats = game:GetService("Stats")
	Players2 = game:GetService("Players")
	localPlayer = Players2.LocalPlayer

	local ok2c, chsaeControls = pcall(function()
		return require(localPlayer.PlayerScripts.PlayerModule):GetControls()
	end)
	if ok2c then getgenv().__CHSAE_Controls = chsaeControls end

	fn2 = function()
		local chsaeControls2 = getgenv().__CHSAE_Controls
		if not chsaeControls2 then return end
		pcall(function() chsaeControls2:Enable() end)
	end

	getgenv().__CHSAE_RuntimeConns = getgenv().__CHSAE_RuntimeConns or {}

	-- Stub UI helpers so all downstream calls are no-ops
	local function makeStubToggle(cfgTbl, cfgKey, defaultVal)
		local t = { Value = (cfgTbl and cfgKey and cfgTbl[cfgKey] ~= nil) and cfgTbl[cfgKey] or defaultVal, _callbacks = {} }
		function t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
		function t:SetValue(val)
			self.Value = val
			if cfgTbl and cfgKey then cfgTbl[cfgKey] = val end
			for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
		end
		return t
	end

	local function makeStubInput(defaultVal, cfgTbl, cfgKey)
		local t = { Value = defaultVal, _callbacks = {} }
		function t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
		function t:SetValue(val)
			self.Value = val
			if cfgTbl and cfgKey then cfgTbl[cfgKey] = val end
			for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
		end
		function t:GetValue() return self.Value end
		function t:SetDisabled() end
		return t
	end

	local function makeStubGroupbox()
		local gb = {}
		function gb:AddToggle(id, opts)
			local defaultVal = false
			if type(opts) == "table" then defaultVal = opts.Default end
			local tog = makeStubToggle(nil, nil, defaultVal)
			gb[id] = tog
			return tog
		end
		function gb:AddInput(id, opts)
			local defaultVal = type(opts) == "table" and opts.Default or ""
			local inp = makeStubInput(defaultVal, nil, nil)
			gb[id] = inp
			return inp
		end
		function gb:AddLabel(id, opts)
			local t = {}
			function t:SetText(v) end
			function t:SetVisible(v) end
			return t
		end
		function gb:AddDivider() return {} end
		function gb:AddButton(id, opts)
			local t = { _callbacks = {} }
			function t:OnClick(cb) self._callbacks[#self._callbacks+1] = cb end
			return t
		end
		function gb:AddSlider(id, opts)
			local defaultVal = type(opts) == "table" and opts.Default or 0
			local t = { Value = defaultVal, _callbacks = {} }
			function t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
			function t:SetValue(val)
				self.Value = val
				for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
			end
			return t
		end
		function gb:AddDropdown(id, opts)
			local defaultVal = type(opts) == "table" and opts.Default or nil
			local t = { Value = defaultVal, _callbacks = {} }
			function t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
			function t:SetValue(val)
				self.Value = val
				for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
			end
			return t
		end
		function gb:AddGroupbox(opts) return makeStubGroupbox() end
		function gb:Destroy() end
		function gb:Resize() end
		setmetatable(gb, {
			__index = function(_, k)
				return function(...) return makeStubGroupbox() end
			end,
			__newindex = function(t, k, val) rawset(t, k, val) end,
		})
		return gb
	end

	local function makeStubToggle(cfgTbl, cfgKey)
		local t = { Value = cfgTbl[cfgKey], _callbacks = {} }
		function t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
		function t:SetValue(val)
			self.Value = val
			cfgTbl[cfgKey] = val
			for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
		end
		return t
	end

	lua = {
		Notify = function(_, msg, _dur) print("[SAE] " .. tostring(msg)) end,
		Unload = function() end,
		ScreenGui = Instance.new("ScreenGui"),
		GetIcon = function() return nil end,
		SetIconModule = function() end,
		CreateWindow = function() return makeStubGroupbox() end,
		AddToRegistry = function() end,
		GetBetterColor = function(_, color, _) return color end,
		AddDraggableLabel = function(_, text)
			local lbl = Instance.new("TextLabel")
			lbl.Text = tostring(text or "")
			lbl.Size = UDim2.new(0, 200, 0, 20)
			return { Label = lbl }
		end,
		Scheme = { MainColor = Color3.fromRGB(255, 255, 255) },
	}

	v2 = {
		CHK = {
			Merge = function(_, box, cb) pcall(cb) end,
			CardifyBox = nil,
			DeferTabBuild = function() end,
			StyleGroupboxPanel = function() end,
		},
		Install = function(_, _lua, _opts) return {} end,
		MakeCollapsible = function() end,
		StyleGroupboxPanel = function() end,
		BindDropdownOverlay = function(box, id, label, items, opts)
			if opts and type(opts.set) == "function" and type(opts.get) == "function" then
				pcall(function() opts.set(opts.get()) end)
			end
		end,
		MakeButtonPanel = function() return makeStubGroupbox() end,
		PatchControls = function() end,
		StyleWindow = function() end,
		StyleTabs = function() end,
		StyleBoxes = function() end,
		Polish = function() end,
		CardifyBox = nil,
		addKGFilterControls = function() end,
		addValueFilterInput = function() end,
		makeStubGroupbox = makeStubGroupbox,
		makeStubToggle = makeStubToggle,
	}

	-- Expose stub factories to downstream code
	getgenv().__CHSAE_MakeStubGroupbox = makeStubGroupbox
	getgenv().__CHSAE_MakeStubToggle = makeStubToggle
end

local chk
chk = v2.CHK
local makeCollapsible
makeCollapsible = function() end
local styleGroupboxPanel
styleGroupboxPanel = function() end
local bindDropdownOverlay
bindDropdownOverlay = v2.BindDropdownOverlay
local makeButtonPanel
makeButtonPanel = v2.MakeButtonPanel
local fn3

fn3 = function(arg)
	local n = tonumber(arg) or 0
	local flag = n < 0
	local n2 = math.abs(n)

	for _, v3 in ipairs({ { 1e12, "T" }, { 1e9, "B" }, { 1000000, "M" }, { 1000, "K" } }) do
		if n2 >= v3[1] then
			local n3 = math.floor(n2 / v3[1] * 10) / 10
			local str = n3 % 1 == 0 and tostring(math.floor(n3)) or string.format("%.1f", n3)
			flag = flag and "-" or ""
			return flag .. str .. v3[2]
		end
	end

	return (flag and "-" or "") .. tostring(math.floor(n2))
end

local fn4

fn4 = function(arg)
	local n = math.floor(arg)
	return string.format("%02d:%02d:%02d", math.floor(n / 3600), math.floor(n % 3600 / 60), n % 60)
end

local fn5

fn5 = function(arg)
	local floor = math.floor
	local n = arg.B * 255 + 0.5
	return string.format("#%02X%02X%02X", math.floor(arg.R * 255 + 0.5), math.floor(arg.G * 255 + 0.5), floor(n))
end

local fn6

fn6 = function(arg, arg2)
	task.wait(arg + math.random() * ((arg2 or arg) - arg))
end

local fn7

fn7 = function()
	local tbl2 = {}

	pcall(function()
		local tbl3 = {}

		for _, rarity in pairs(require(ReplicatedStorage.Data.Rarity).Rarities) do
			if type(rarity) == "table" and rarity._id and not tbl3[rarity._id] then
				tbl3[rarity._id] = true

				tbl2[#tbl2 + 1] = {
					id = rarity._id,
					num = tonumber(rarity.RarityNumber or rarity.Rank) or 0,
					color = rarity.Color,
					odds = rarity.DefaultRarityValue,
				}
			end
		end

		table.sort(tbl2, function(arg, arg2)
			if arg.num ~= arg2.num then
				return arg.num > arg2.num
			end
			return arg.id < arg2.id
		end)
	end)

	return tbl2
end

-- Window/tab/groupbox stubs (no UI rendered)
local makeStubGroupbox = getgenv().__CHSAE_MakeStubGroupbox or function()
	local gb = {}
	setmetatable(gb, {
		__index = function(_, k) return function(...) return gb end end,
		__newindex = function(t, k, v) rawset(t, k, v) end,
	})
	return gb
end

local function makeTabStub()
	local tab = setmetatable({}, {
		__index = function(_, k) return function(...) return makeStubGroupbox() end end,
	})
	return tab
end

local v3 = setmetatable({}, {
	__index = function(_, k) return function(...) return makeStubGroupbox() end end,
	__newindex = function(t, k, v) rawset(t, k, v) end,
})

v3.__AccountTab = makeTabStub()
v3.__FuseTab = makeTabStub()
v3.__ServerTab = makeTabStub()
v3.__WebhookTab = makeTabStub()
v3.__ProtectionBox = makeStubGroupbox()
v3.__ESPBox = makeStubGroupbox()
v3.__MutateBox = makeStubGroupbox()
v3.__AdminAbuseBox = makeStubGroupbox()
v3.__PetIndexBox = makeStubGroupbox()
v3.__FuseBox = makeStubGroupbox()
v3.__ServerControlsBox = makeStubGroupbox()
v3.__ServerResultsBox = makeStubGroupbox()
v3.__EventShopBox = makeStubGroupbox()
v3.__ScrambleBossBox = makeStubGroupbox()
v3.__WebhookBox = makeStubGroupbox()
v3.__WebhookAlertsBox = makeStubGroupbox()
v3.__ConfigBox = makeStubGroupbox()
v3.__ApplyMobileScrollFix = function() end

local home = makeTabStub()
local eggs = makeTabStub()
local progression = makeTabStub()
local event = makeTabStub()
local sell = makeTabStub()
local settings_ = makeTabStub()

local v4 = nil
local v5 = makeStubGroupbox()
local tbl2

tbl2 = {
	ConfigRevision = 20,
	TargetRarities = {},
	TargetCategories = {},
	TargetAreas = {},
	TargetPriority = "Rarity",
	TargetKGMode = "Any",
	TargetKGThreshold = 0,
	TargetValueThreshold = 0,
	AutoSteal = false,
	StealServerHop = false,
	Stall = false,
	ManualWalkSpeed = 500,
	PersistentSteal = false,
	PreventTraps = false,
	GuardProtection = false,
	StealMovementType = "Relay",
	EnableDefaultSpeed = false,
	StealSpeed = 700,
	StealWallSpacing = "Wide Wall",
	EquipInterval = 30,
	AutoEquipBest = false,
	SellPets = {},
	SellRarities = {},
	SellMutations = {},
	SellPetKGMode = "Any",
	SellPetKGThreshold = 0,
	SellPetValueThreshold = 0,
	AutoSell = false,
	SellPetsWhenFull = false,
	SellEggRarities = {},
	SellEggNames = {},
	SellEggMutations = {},
	SellEggKGMode = "Any",
	SellEggKGThreshold = 0,
	SellEggValueThreshold = 0,
	AutoSellEggs = false,
	SellEggsWhenFull = false,
	AutoTreadmill = false,
	AdminTreadmill = false,
	AntiTreadmill = false,
	AutoUpgradePen = false,
	AutoUpgradeTreadmill = false,
	AutoCollectCash = false,
	AutoClaimIndex = false,
	AutoPetIndex = false,
	PetIndexAreas = {},
	TrailName = "GreyTrail",
	TrailNames = {},
	AutoBuyTrail = false,
	FuseCategories = {},
	FuseKGMode = "Any",
	FuseKGThreshold = 0,
	FuseMinimumValue = 0,
	FindServer = false,
	AutoFuse = false,
	AutoLab = false,
	LabRotations = { Biohazard = true, Experimental = true, UnstableDNA = true },
	ScrambleSwapBat = false,
	AutoScrambleShop = false,
	AutoScrambleBoss = false,
	AutoClaimBossMastery = false,
	ScrambleShopItems = {},
	PriorityEvent = false,
	LabMinimumValue = 0,
	PlaceCategories = {},
	PlaceRarities = {},
	PlaceMutations = {},
	PlaceOrder = "Back → Front",
	AutoMutate = false,
	MutateConsumable = "Rift",
	MutateCategories = {},
	MutateRarities = {},
	MutateMutations = {},
	MutateMinimumValue = 0,
	AutoPlace = false,
	PlaceInRangeOnly = false,
	AutoHatch = false,
	HatchFracturedOnly = false,
	WebhookURL = "",
	WebhookEveryone = false,
	WebhookSteals = false,
	WebhookMutations = false,
	WebhookHatches = false,
	WebhookDisconnects = false,
	WebhookInventoryFull = false,
	EggESP = false,
	EggESPAreas = {},
	PenESP = false,
	InventoryESP = false,
	ShowStatusOverlay = false,
	AntiAFK = false,
	HidePets = false,
	RemovePenEggs = false,
	RemoveAdminTreadmill = false,
	ExtremeFPS = false,
	BlackScreen = false,
	BoostTickRate = false,
	UnlockFPS = false,
}

local tbl3

tbl3 = {
	loaded = false,
	lastSave = 0,
	note = "never saved",
	migrated = false,
	legacyPath = "SAE/config(SAG)_" .. tostring(localPlayer.UserId) .. ".json",
}

local fn8, fn9, fn10

do
	local str = "SAE/universalToggle(SAG).json"
	local str2 = "SAE" .. "/config(SAG)_" .. tostring(localPlayer.UserId) .. ".json"

	local ok, result = pcall(function()
		local str3 = isfile and isfile(str) and str

		if not str3 then
			str3 = isfile and isfile("SAE/universalToggle(SAG).json") and "SAE/universalToggle(SAG).json"
		end

		if str3 then
			local data = HttpService:JSONDecode(readfile(str3))
			return type(data) == "table" and data.UseUniversalConfig == true
		end
		return false
	end)

	if ok and result then
		str2 = "SAE/universalConfig(SAG).json"
		tbl3.legacyPath = "SAE/universalConfig(SAG).json"
	end

	fn8 = nil

	fn8 = function(arg, arg2)
		local tbl4 = {}

		for k in pairs(arg) do
			tbl4[#tbl4 + 1] = k
		end

		table.sort(tbl4, function(arg3, arg4)
			return tostring(arg3) < tostring(arg4)
		end)

		local tbl5 = {}

		for _, v6 in ipairs(tbl4) do
			local v7 = arg[v6]

			if type(v7) == "table" then
				local n = #tbl5 + 1
				local str3 = tostring(v6)
				local flag2 = (arg2 or 0) < 3

				if flag2 then
					flag2 = fn8(v7, (arg2 or 0) + 1)
				end

				tbl5[n] = str3 .. "={" .. (flag2 or "…") .. "}"
			else
				tbl5[#tbl5 + 1] = tostring(v6) .. "=" .. tostring(v7)
			end
		end

		return table.concat(tbl5, ",")
	end

	tbl3.normalizeDeliverySpeeds = function(arg)
		arg = type(arg) == "table" and arg or {}
		local num = tonumber(arg.TPReturnSpeed or arg.StealSpeed or arg.HopSpeed or arg.TweenSpeed)

		if not num or num ~= num or num == math.huge or num == -math.huge then
			num = 700
		end

		tbl2.StealSpeed = math.clamp(math.floor(num + 0.5), 100, 1000)
		local v6 = tbl2
		local v7 = tbl2
		tbl2.TPReturnSpeed = nil
		v6.TweenReturnSpeed = nil
		v7.StealMovementBackend = nil
	end

	local tbl4 = {
		TargetValueThreshold = true,
		SellPetValueThreshold = true,
		SellEggValueThreshold = true,
		LabMinimumValue = true,
	}

	tbl3.apply = function(arg, arg2)
		local n = tonumber(arg.ConfigRevision) or 0

		local function fn11(arg3)
			return type(arg3) == "number" and arg3 == arg3 and arg3 >= 0 and arg3 < math.huge
		end

		for k, v6 in pairs(tbl2) do
			local v7 = arg[k]
			local flag2 = k ~= "Stall" and v7 ~= nil

			if flag2 then
				flag2 = not (arg2 and k == "WebhookURL")
			end

			if flag2 then
				if type(v6) == "table" and type(v7) == "table" then
					for k2 in pairs(v6) do
						v6[k2] = nil
					end

					for k2, v8 in pairs(v7) do
						if v8 == true then
							v6[k2] = true
						end
					end
				elseif type(v6) == type(v7) and (not tbl4[k] or fn11(v7)) then
					tbl2[k] = v7
				end
			end
		end

		if not (fn11(arg.FuseMinimumValue) and fn11(arg.FuseKGThreshold) and type(arg.FuseCategories) == "table" and (arg.FuseKGMode == "Any" or arg.FuseKGMode == "Above" or arg.FuseKGMode == "Below")) then
			tbl2.AutoFuse = false
			local v6 = tbl2
			local v7 = tbl2
			tbl2.FuseMinimumValue = 0
			v6.FuseKGThreshold = 0
			v7.FuseKGMode = "Any"
		end

		local flag2 = n < 11 or not fn11(arg.SellPetValueThreshold)
		local flag3 = n < 11 or not fn11(arg.SellEggValueThreshold)

		if flag2 then
			tbl2.SellPetValueThreshold = 0
		end

		if flag3 then
			tbl2.SellEggValueThreshold = 0
		end

		local v6 = tbl2
		tbl2.AutoSell = false
		v6.SellPetsWhenFull = false
		local v7 = tbl2
		tbl2.AutoSellEggs = false
		v7.SellEggsWhenFull = false

		if n < 15 or not fn11(arg.LabMinimumValue) then
			local v8 = tbl2
			local v9 = tbl2
			tbl2.AutoLab = false
			v8.PriorityEvent = false
			v9.LabMinimumValue = 0
		end

		if n < 16 then
			tbl2.AutoLab = false
		end

		if n < 1 then
			tbl2.TargetPriority = "Rarity"
		end

		if n < 3 then
			tbl2.ShowStatusOverlay = false
		end

		if arg.PlaceInRangeOnly == nil and type(arg.PlaceMoveToPen) == "boolean" then
			tbl2.PlaceInRangeOnly = not arg.PlaceMoveToPen
		end

		if arg.WebhookMutations == nil and arg.WebhookHatches == nil then
			tbl2.WebhookSteals = arg.WebhookEnabled == true and arg.WebhookSteals ~= false
		end

		tbl2.ConfigRevision = 20
		tbl2.StealWallSpacing = "Wide Wall"
		local stealMovementType = tbl2.StealMovementType
		tbl2.EnableDefaultSpeed = arg.EnableDefaultSpeed == true or arg.EnableDefaultSpeed == nil and stealMovementType == "Default Speed"
		tbl2.StealMovementType = (stealMovementType == "Fly" and n >= 18 or (stealMovementType == "Hop" or stealMovementType == "Hop Fly") and n >= 20) and stealMovementType or "Relay"
		local v8 = tbl2
		tbl2.StealRagdoll = nil
		v8.HoverRunSpeed = nil
		tbl3.normalizeDeliverySpeeds(arg)
		local flag4 = not arg2

		if flag4 then
			flag4 = n < 20 or flag2 or flag3
		end

		if flag4 then
			tbl3.migrated = true
		end

		return flag2, flag3
	end

	local function fn11()
		tbl2.Stall = false
		if not (isfile and readfile) then
			tbl3.note = "no file API"
			return false
		end
		local v6 = isfile(str2) and str2
		local legacyPath

		if v6 then
			legacyPath = v6
		else
			legacyPath = isfile(tbl3.legacyPath) and tbl3.legacyPath
		end

		local ok2, result2 = pcall(function()
			return legacyPath and readfile(legacyPath) or nil
		end)

		if not (ok2 and type(result2) == "string" and #result2 > 2) then
			tbl3.note = "no saved config"
			return false
		end

		local ok3, result3 = pcall(function()
			return HttpService:JSONDecode(result2)
		end)

		if not (ok3 and type(result3) == "table") then
			tbl3.note = "⚠️ corrupt file — using defaults"
			return false
		end
		tbl3.apply(result3, false)
		tbl3.loaded = true
		tbl3.note = legacyPath == tbl3.legacyPath and "loaded legacy profile" or "loaded"
		return true
	end

	fn9 = function(arg)
		local tbl5 = {}

		for k, v6 in pairs(tbl2) do
			if k ~= "Stall" then
				if arg == true or k ~= "WebhookURL" then
					if type(v6) == "table" then
						local tbl6 = {}

						for k2, v7 in pairs(v6) do
							tbl6[k2] = v7
						end

						tbl5[k] = tbl6
					else
						tbl5[k] = v6
					end
				end
			end
		end

		tbl5.AutoSell = false
		tbl5.SellPetsWhenFull = false
		tbl5.AutoSellEggs = false
		tbl5.SellEggsWhenFull = false
		return tbl5
	end

	tbl3.CreatePersistence = function(arg)
		local v6 = nil
		local flag2 = false
		local flag3 = false
		local tbl5 = { AutoSell = true, SellPetsWhenFull = true, AutoSellEggs = true, SellEggsWhenFull = true }

		local function fn12()
			if not v6 then
				return false
			end

			for k, setting in pairs(arg.settings) do
				if k == "Stall" then
					continue
				end

				if tbl5[k] then
					setting = false
				end

				local v7 = v6[k]

				if type(setting) == "table" then
					if type(v7) ~= "table" then
						return false
					end

					for k2, v8 in pairs(setting) do
						if v7[k2] ~= v8 then
							return false
						end
					end

					for k2, v8 in pairs(v7) do
						if setting[k2] ~= v8 then
							return false
						end
					end

					continue
				end

				if setting ~= v7 then
					return false
				end
			end

			for k in pairs(v6) do
				if not tbl5[k] and arg.settings[k] == nil then
					return false
				end
			end

			return true
		end

		return {
			IsUnchanged = function()
				return fn12()
			end,
			Prime = function()
				if flag2 or not arg.alive() then
					return false
				end
				v6 = arg.snapshot()
				return true
			end,
			Save = function(arg2, arg3)
				if not arg.alive() or arg.blocked() then
					return false
				end

				if flag2 then
					if arg3 then
						flag3 = true
					end

					return false
				end

				if not arg3 and not flag3 and fn12() then
					return false
				end
				flag2 = true
				flag3 = false

				local ok2, result2 = pcall(function()
					local v7 = arg.snapshot()
					local ok2, result2 = pcall(arg.encode, v7)
					if not ok2 then
						arg.meta.note = "⚠️ encode failed"
						return false
					end

					if not arg.alive() or arg.blocked() then
						return false
					end

					if not pcall(arg.write, result2) then
						arg.meta.note = "⚠️ write failed"
						return false
					end
					v6 = v7
					local meta = arg.meta
					arg.meta.lastSave = arg.time()
					meta.note = "saved"
					return true
				end)

				flag2 = false
				local flag4 = not ok2

				if flag4 then
					arg.meta.note = "⚠️ save failed"
				end

				if flag4 or not result2 then
					flag3 = true
				end

				return ok2 and result2 == true
			end,
		}
	end

	tbl3.persistence = tbl3.CreatePersistence({
		settings = tbl2,
		meta = tbl3,
		alive = fn,
		blocked = function()
			return false
		end,
		snapshot = function()
			return fn9(true)
		end,
		encode = function(arg)
			return HttpService:JSONEncode(arg)
		end,
		write = function(arg)
			pcall(function()
				if makefolder and isfolder and not isfolder("SAE") then
					makefolder("SAE")
				end
			end)

			if not fn() or false then
				error("config save cancelled", 0)
			end

			writefile(str2, arg)
		end,
		time = os.time,
	})

	fn10 = function(arg)
		if tbl.InventoryWake and (arg or not tbl3.persistence:IsUnchanged()) then
			tbl.InventoryWake("config")
		end

		if not writefile then
			tbl3.note = "no file API"
			return false
		end
		return tbl3.persistence:Save(arg)
	end

	fn11()
end

for _, v6 in ipairs({
	{ "TargetKGMode", "TargetKGThreshold" },
	{ "SellPetKGMode", "SellPetKGThreshold" },
	{ "SellEggKGMode", "SellEggKGThreshold" },
	{ "FuseKGMode", "FuseKGThreshold" },
}) do
	local v7 = v6[1]
	local v8 = v6[2]
	local v9 = tbl2[v7]

	if v9 ~= "Below" and v9 ~= "Above" and v9 ~= "Any" then
		tbl2[v7] = "Any"
		tbl3.migrated = true
	end

	local n = math.max(tonumber(tbl2[v8]) or 0, 0)

	if tbl2[v8] ~= n then
		tbl2[v8] = n
		tbl3.migrated = true
	end
end

for _, v6 in ipairs({
	"TargetValueThreshold",
	"SellPetValueThreshold",
	"SellEggValueThreshold",
	"LabMinimumValue",
	"FuseMinimumValue",
	"MutateMinimumValue",
}) do
	local num = tonumber(tbl2[v6])

	if not (type(num) == "number" and num == num and num >= 0 and num < math.huge) then
		if v6 == "SellPetValueThreshold" then
			tbl2.AutoSell = false
			tbl2.SellPetsWhenFull = false
			num = 0
		else
			num = 0

			if v6 == "SellEggValueThreshold" then
				tbl2.AutoSellEggs = false
				tbl2.SellEggsWhenFull = false
				num = 0
			end
		end
	end

	if tbl2[v6] ~= num then
		tbl2[v6] = num
		tbl3.migrated = true
	end
end

if tbl2.AutoLab ~= true then
	tbl2.AutoLab = false
end

if tbl2.PriorityEvent ~= true then
	tbl2.PriorityEvent = false
end

if tbl3.migrated then
	fn10(true)
else
	tbl3.persistence:Prime()
end

task.spawn(function()
	while fn() do
		task.wait(3)
		if fn() then
			pcall(fn10)
			continue
		end
		break
	end
end)

local handlers

handlers = {
	steal = "🔴 Steal: Off",
	target = "🎯 Target: none",
	carry = "📦 Carry: none",
	place = "🥚 Pen: idle",
	steals = 0,
	attempts = 0,
	carryRequests = 0,
	returnResumeCount = 0,
	lastReturnResumeAt = 0,
	lastReturnResumeReason = nil,
	lastReturnResumeUid = nil,
	stealTime = "⏱️ Time: idle",
	stealTimer = { active = false, startedAt = 0, last = nil, total = 0, completed = 0, average = nil },
	eventActive = false,
	sendWebhook = nil,
	pendingInventoryFullAlert = nil,
	inventoryFullGraceUntil = 0,
	inventoryFullGraceScheduled = false,
	incubatedPlaceQueue = {},
	greatBloomUnlock = { stage = "idle", reservedEggUid = nil, reservedPetUid = nil, locked = nil },
	greatBloomUnlockStealWanted = false,
	greatBloomUnlockProtectCranePets = false,
	greatBloomUnlockReturnPending = false,
	greatBloomBodyPending = false,
	greatBloomBodyRunning = false,
	adminEventPending = false,
	adminEventActive = false,
	adminEventName = nil,
	adminEventFlow = "🔴 Off",
	riftClaimHandoffUid = nil,
	riftClaimHandoffAt = 0,
	riftClaimHandoffGrace = 2.5,
	adminCaptureUid = nil,
	adminMonsterActive = false,
	greatBloomUnlockClaimedAt = 0,
	greatBloomUnlockClaimedEggUid = nil,
	greatBloomUnlockClaimGrace = 8,
	greatBloomUnlockHatchFinishedAt = 0,
	greatBloomUnlockHatchedEggUid = nil,
	greatBloomUnlockLastReturnReason = nil,
	greatBloomUnlockLastReturnAt = 0,
	hatchPetOutputPending = false,
	hatchPetOutputGuard = nil,
	hatchPetGuardUntil = 0,
	hatchProtectedPetUids = {},
	knownPetUids = nil,
	petUidBaselineReady = false,
	hatchPetResolveSeconds = 8,
	hatchPetProtectSeconds = 8,
	defaultMoveFallback = false,
	intentionalDisconnectUntil = 0,
	intentionalDisconnectReason = nil,
	captureEventUid = function()
		local attribute = workspace:GetAttribute("Event_CaptureTheEggUid")
		if type(attribute) == "string" and attribute ~= "" then
			handlers.adminCaptureUid = attribute
			return attribute
		end
		return handlers.adminCaptureUid
	end,
	isCaptureEventUid = function(arg)
		if arg == nil then
			return false
		end
		local v6 = handlers.captureEventUid()
		return v6 ~= nil and tostring(arg) == tostring(v6)
	end,
	clearRiftClaimHandoff = function(arg)
		if arg == nil or tostring(handlers.riftClaimHandoffUid) == tostring(arg) then
			handlers.riftClaimHandoffUid = nil
			handlers.riftClaimHandoffAt = 0
		end
	end,
	riftClaimHandoffPending = function()
		local riftClaimHandoffUid = handlers.riftClaimHandoffUid
		local n = tonumber(handlers.riftClaimHandoffAt) or 0
		local n2 = tonumber(handlers.riftClaimHandoffGrace) or 2.5
		if tbl2.AutoLab ~= true or riftClaimHandoffUid == nil or n <= 0 or os.clock() - n > n2 then
			handlers.clearRiftClaimHandoff(riftClaimHandoffUid)
			return false
		end
		return true
	end,
	normalStealPending = function()
		if tbl2.AutoSteal ~= true then
			return false
		end

		if type(handlers.normalStealTargetAvailable) == "function" then
			return handlers.normalStealTargetAvailable()
		end
		return true
	end,
	adminEventHasPriority = function()
		if tbl2.AutoSteal == true then
			return false
		end

		if type(getgenv().__CHSAE_RiftTransaction) == "table" then
			return true
		end
		local flag2 = tbl2.AutoLab == true

		if flag2 then
			flag2 = handlers.riftClaimHandoffPending() or handlers.riftWantsBody == true or handlers.riftPlacementWanted == true
		end

		return flag2
	end,
	RiftPlanner = {},
}

handlers.RiftPlanner.Signature = function(arg)
	if type(arg) ~= "table" or type(arg.Requirements) ~= "table" or #arg.Requirements ~= 3 then
		return nil
	end
	local tbl4 = {}
	local v6 = tostring
	local bannerId = arg.BannerId or ""

	do
		local values = table.pack(v6(bannerId))
		table.move(values, 1, values.n, 1, tbl4)
	end

	for i = 1, 3 do
		local v7 = arg.Requirements[i]
		if type(v7) ~= "string" or v7 == "" then
			return nil
		end
		tbl4[#tbl4 + 1] = v7
	end

	return table.concat(tbl4, "\31")
end

handlers.RiftPlanner.ValueAllowed = function(arg, arg2, arg3)
	if type(arg3) ~= "number" or arg3 ~= arg3 or arg3 < 0 or arg3 >= math.huge then
		return false
	end

	if arg2 ~= true or type(arg) ~= "number" or arg ~= arg or arg < 0 or arg >= math.huge then
		return false
	end
	return arg3 == 0 or arg < arg3
end

handlers.RiftPlanner.Action = function(arg, arg2, arg3, arg4, arg5, arg6)
	if not arg then
		return "off"
	end

	if arg2 then
		return "transaction"
	end

	if arg3 then
		return "normal"
	end

	if arg5 then
		return "claim"
	end

	if not arg6 then
		return "state"
	end

	if arg6.ready then
		return "trade"
	end

	for _, slot in ipairs(arg6.slots) do
		if slot.eggUid and not slot.placed then
			return "place"
		end
	end

	if next(arg6.missing) ~= nil then
		return "collect"
	end
	return "hatch"
end

handlers.riftReservedPets = {}
handlers.riftReservedEggs = {}
handlers.riftEggHandoffs = {}

handlers.riftPetReserved = function(arg)
	local chsaeRiftTransaction = getgenv().__CHSAE_RiftTransaction
	local flag2 = tbl2.AutoLab == true and handlers.riftReservedPets[tostring(arg)] == true

	if not flag2 then
		flag2 = type(chsaeRiftTransaction) == "table" and chsaeRiftTransaction.jobId == game.JobId and type(chsaeRiftTransaction.petSet) == "table" and chsaeRiftTransaction.petSet[tostring(arg)] == true
	end

	return flag2
end

handlers.riftEggReserved = function(arg)
	return tbl2.AutoLab == true and handlers.riftReservedEggs[tostring(arg)] == true
end

handlers.riftEggActive = function()
	return tbl2.AutoLab == true and next(handlers.riftReservedEggs) ~= nil
end

handlers.riftFieldEligible = function(arg)
	return tbl2.AutoLab == true and type(arg) == "table" and tostring(arg.Uid) == tostring(handlers.riftTargetUid) and handlers.riftTargetUid ~= nil
end

handlers.RiftPlanner.PlanEggs = function(arg, arg2)
	local v6 = handlers.RiftPlanner.Signature(arg)
	if not v6 then
		return nil
	end
	local tbl4 = { signature = v6, slots = {}, pets = {}, eggs = {}, missing = {}, ready = true }

	for i, requirement in ipairs(arg.Requirements) do
		local v7 = nil

		for _, v8 in ipairs(arg2) do
			if v8.category == requirement and not v8.placed and not tbl4.eggs[v8.uid] and (not v7 or v8.value < v7.value or v8.value == v7.value and v8.uid < v7.uid) then
				v7 = v8
			end
		end

		local tbl5 = { category = requirement }

		if v7 then
			local uid = v7.uid
			local uid2 = v7.uid
			tbl4.eggs[uid] = true
			tbl5.eggUid = uid2
		else
			tbl4.ready = false
			tbl4.missing[requirement] = (tbl4.missing[requirement] or 0) + 1
		end

		tbl4.slots[i] = tbl5
	end

	return tbl4
end

handlers.RiftPlanner.LabAction = function(arg, arg2, arg3, arg4)
	if arg then
		return "transaction"
	end

	if arg2 then
		return "normal"
	end

	if arg3 then
		return "claim"
	end

	if not arg4 then
		return "state"
	end

	if arg4.ready then
		return "trade"
	end

	if next(arg4.missing) ~= nil then
		return "collect"
	end
	return "wait"
end

handlers.labReservedEggs = {}
handlers.labNeededCategories = {}

handlers.labEggReserved = function(arg, arg2)
	if tbl2.AutoLab ~= true then
		return false
	end

	if handlers.labReservedEggs[tostring(arg)] == true then
		return true
	end
	return arg2 ~= nil and handlers.labNeededCategories[tostring(arg2)] == true
end

handlers.getSafetySummary = function()
	return "🛡️ Guard loading", 0
end

handlers.statusWake = Instance.new("BindableEvent")
local statusWake = handlers.statusWake
handlers.statusLabelCache = setmetatable({}, { __mode = "k" })
handlers.statusWakeBusy = false
handlers.statusWakePending = nil

handlers.presentationInterval = function()
	return (handlers.clientFPS or 60) < 35 and 0.25 or 0.1
end

handlers.wakeOverlay = function(statusWakePending)
	if not fn() then
		return
	end
	handlers.statusWakePending = statusWakePending or "status"
	if handlers.statusWakeBusy then
		return
	end
	handlers.statusWakeBusy = true

	task.defer(function()
		while fn() and handlers.statusWakePending ~= nil do
			local statusWakePending2 = handlers.statusWakePending
			handlers.statusWakePending = nil

			pcall(function()
				handlers.statusWake:Fire(statusWakePending2)
			end)

			task.wait(handlers.presentationInterval())
		end

		handlers.statusWakeBusy = false
	end)
end

handlers.setLabel = function(arg, arg2)
	local text = tostring(arg2)
	if not arg or handlers.statusLabelCache[arg] == text then
		return false
	end
	handlers.statusLabelCache[arg] = text
	local value = type(arg) == "table" and rawget(arg, "TextLabel") or nil
	local ok

	if typeof(value) == "Instance" then
		local flag2 = type(getthreadidentity) == "function" and getthreadidentity() or nil

		if type(setthreadidentity) == "function" then
			pcall(setthreadidentity, 8)
		end

		ok = pcall(function()
			value.Text = text
			rawset(arg, "Text", text)
		end)

		if flag2 ~= nil and type(setthreadidentity) == "function" then
			pcall(setthreadidentity, flag2)
		end
	else
		ok = pcall(function()
			arg:SetText(text)
		end)
	end

	if ok then
		handlers.wakeOverlay("label")
	end

	return ok
end

handlers.set = function(arg, arg2)
	local str = tostring(arg2)
	if handlers[arg] == str then
		return false
	end
	handlers[arg] = str
	handlers.wakeOverlay(arg)
	return true
end

handlers.kgFilterActive = function(arg, arg2)
	local flag2 = arg == "Below" or arg == "Above"

	if flag2 then
		flag2 = (tonumber(arg2) or 0) > 0
	end

	return flag2
end

handlers.kgFilterModes = { "Any", "Below", "Above" }

handlers.kgFilterDisplayMap = {
	Any = "<font color=\"#9AA0AA\"><b>Any</b></font> <font color=\"#737987\">disabled</font>",
	Below = "<font color=\"#60A5FA\"><b>Below</b></font> <font color=\"#9AA0AA\">at or below</font>",
	Above = "<font color=\"#49E685\"><b>Above</b></font> <font color=\"#9AA0AA\">at or above</font>",
}

handlers.addKGFilterControls = function(arg, arg2, arg3, arg4, arg5, arg6)
	local v6 = bindDropdownOverlay(arg, arg2 .. "KGMode", arg6 and "Prevent KG" or "KG Rule", handlers.kgFilterModes, {
		configKey = arg3,
		multi = false,
		text = arg6 and "Prevent KG" or "KG Rule",
		tooltip = "Any = no KG filter.",
		displayMap = handlers.kgFilterDisplayMap,
		get = function()
			return tbl2[arg3] or "Any"
		end,
		set = function(arg7)
			tbl2[arg3] = (arg7 == "Below" or arg7 == "Above") and arg7 or "Any"
		end,
		onChange = arg5,
	})

	local v7 = arg:AddInput(arg2 .. "KGThreshold", {
		Text = "KG Threshold",
		Default = tostring(math.max(tonumber(tbl2[arg4]) or 0, 0)),
		Numeric = true,
		Finished = true,
		Placeholder = "0",
		Tooltip = "Uses the KG shown in game.",
	})

	local function fn11()
		if type(handlers.setCommittedThresholdCaption) == "function" then
			handlers.setCommittedThresholdCaption(v7, "KG Threshold", tbl2[arg4])
		end
	end

	fn11()

	v7:OnChanged(function(arg7)
		tbl2[arg4] = math.max(tonumber(arg7) or 0, 0)
		fn11()

		if arg5 then
			pcall(arg5)
		end
	end)

	local chsaeConfigControllers = nil

	if type(chsaeConfigControllers) == "table" then
		chsaeConfigControllers[arg4] = {
			GetValue = function()
				return tbl2[arg4]
			end,
			SetValue = function(arg7, arg8)
				local n = math.max(tonumber(arg8) or 0, 0)
				tbl2[arg4] = n

				pcall(function()
					v7:SetValue(tostring(n))
				end)

				fn11()
			end,
		}
	end

	return v6, v7
end

do
	local tbl4 = { [""] = 1, k = 1000, m = 1000000, b = 1e9, t = 1e12 }
	local tbl5 = { { 1e12, "T" }, { 1e9, "B" }, { 1000000, "M" }, { 1000, "K" } }

	local function fn11(arg)
		return type(arg) == "number" and arg == arg and arg >= 0 and arg < math.huge
	end

	handlers.parseCompactValue = function(arg)
		if type(arg) == "number" then
			arg = fn11(arg) and arg or nil
			return arg
		end
		local str = tostring(arg or ""):lower():gsub("%s+", "")
		if str == "" then
			return 0
		end

		if str:sub(1, 1) == "$" then
			str = str:sub(2)
		end

		if str == "" then
			return nil
		end
		local match, v6 = str:match("^([%d,]*%.?%d+)(%a*)$")
		local v7 = tbl4[v6]
		if not match or not v7 then
			return nil
		end
		local match2 = match:match("^([^%.]*)") or ""

		if match2 == "" then
			match2 = "0"
		end

		if match2:find(",", 1, true) then
			local match3, v8 = match2:match("^(%d%d?%d?)(,.*)$")
			if not match3 or not v8 or v8:gsub(",%d%d%d", "") ~= "" then
				return nil
			end
		elseif not match2:match("^%d+$") then
			return nil
		end

		local v8 = tonumber
		local str2 = match:gsub(",", "")
		local n = v8(str2)
		n = n and n * v7 or nil
		return fn11(n) and n or nil
	end

	handlers.formatCompactValue = function(arg)
		local n = tonumber(arg) or 0
		if not fn11(n) or n == 0 then
			return "0"
		end
		local n2 = 1
		local str = ""

		for _, v6 in ipairs(tbl5) do
			if n >= v6[1] then
				n2 = v6[1]
				str = v6[2]
				break
			end
		end

		return ("%.6f"):format(n / n2):gsub("(%..-)0+$", "%1"):gsub("%.$", "") .. str
	end

	handlers.formatThresholdConfirmation = function(arg)
		local n = tonumber(arg) or 0
		if not fn11(n) or n == 0 then
			return "0"
		end
		local n2 = 1
		local str = ""
		local v6 = nil

		for i, v7 in ipairs(tbl5) do
			if n >= v7[1] then
				n2 = v7[1]
				str = v7[2]
				v6 = i
				break
			else
				v6 = nil
			end
		end

		local function fn12(arg2, arg3)
			local n3 = n / arg2
			return ("%%.%df"):format(n3 >= 100 and 0 or n3 >= 10 and 1 or n3 >= 1 and 2 or arg2 == 1 and 6 or 2):format(n3):gsub("(%..-)0+$", "%1"):gsub("%.$", ""), arg3
		end

		local v7, v8 = fn12(n2, str)

		if tonumber(v7) and tonumber(v7) >= 1000 and v6 and v6 > 1 then
			local v9 = tbl5[v6 - 1]
			v7, v8 = fn12(v9[1], v9[2])
		end

		return v7 .. v8
	end

	handlers.setCommittedThresholdCaption = function(arg, arg2, arg3)
		if type(arg) ~= "table" or type(arg.SetText) ~= "function" then
			return false
		end
		local v6 = handlers.formatThresholdConfirmation(arg3)
		local str = ("%s: <font color=\"#49E685\"><b>%s</b></font>"):format(tostring(arg2), v6)

		return pcall(function()
			arg:SetText(str)
		end)
	end

	handlers.valueFilterActive = function(arg)
		return (tonumber(arg) or 0) > 0
	end

	handlers.markValueFilterChanged = function()
		handlers.valueFilterReadyAt = os.clock() + 0.75
	end

	handlers.sellerValueFilterReady = function(arg)
		if handlers.valueFilterLoadInProgress == true then
			return false
		end

		if os.clock() < (tonumber(handlers.valueFilterReadyAt) or 0) then
			return false
		end

		local ok, result = pcall(function()
			return game:GetService("UserInputService"):GetFocusedTextBox()
		end)

		if not (ok and result == nil) then
			return false
		end
		local valueFilterInputs = arg and handlers.valueFilterInputs and handlers.valueFilterInputs[arg] or nil

		if valueFilterInputs and type(valueFilterInputs.ReadText) == "function" then
			local ok2, result2 = pcall(valueFilterInputs.ReadText)
			local v6 = ok2 and handlers.parseCompactValue(result2) or nil
			if v6 == nil or v6 ~= tonumber(tbl2[arg]) then
				return false
			end
		end

		return true
	end

	handlers.addValueFilterInput = function(arg, arg2, arg3, arg4, arg5, arg6)
		local flag2 = false
		local v6 = handlers.formatCompactValue(tbl2[arg3])
		local v7 = handlers.parseCompactValue(v6)

		if v7 ~= nil then
			tbl2[arg3] = v7
		end

		local v8 = arg:AddInput(arg2, {
			Text = arg4,
			Default = v6,
			Numeric = false,
			Finished = true,
			Placeholder = "750M / 1.25B / 2T",
			Tooltip = arg6 or "Uses $/s. K, M, B, T work; 0 disables.",
		})

		local function fn12()
			handlers.setCommittedThresholdCaption(v8, arg4, tbl2[arg3])
		end

		fn12()

		local function fn13(arg7)
			local v9 = handlers.formatCompactValue(arg7)
			flag2 = true

			pcall(function()
				v8:SetValue(v9)
			end)

			flag2 = false
		end

		local function fn14(arg7, arg8)
			if flag2 then
				return false
			end
			handlers.markValueFilterChanged()
			local v9 = handlers.parseCompactValue(arg7)

			if v9 == nil then
				fn13(tbl2[arg3])

				pcall(function()
					lua:Notify("Use a value like 750M, 1.25B, or 2T.", 4)
				end)

				if arg5 then
					pcall(arg5, "invalid")
				end

				return false
			end

			local v10 = handlers.formatCompactValue(v9)
			local v11 = handlers.parseCompactValue(v10)
			if v11 == nil then
				return false
			end
			local flag3 = tonumber(tbl2[arg3]) ~= v11
			tbl2[arg3] = v11
			fn13(v11)
			fn12()

			if flag3 and arg5 then
				pcall(arg5, arg8 or "user")
			end

			return true
		end

		v8:OnChanged(function(arg7)
			fn14(arg7, "user")
		end)

		local textBox = v8.Holder and v8.Holder:FindFirstChildWhichIsA("TextBox", true)

		if textBox then
			local connection = textBox.FocusLost:Connect(function()
				if flag2 then
					return
				end
				fn14(textBox.Text, "blur")
			end)

			if type(v8.Connections) == "table" then
				table.insert(v8.Connections, connection)
			else
				handlers.valueFilterInputConnections = handlers.valueFilterInputConnections or {}
				table.insert(handlers.valueFilterInputConnections, connection)
			end
		end

		handlers.valueFilterInputs = handlers.valueFilterInputs or {}

		handlers.valueFilterInputs[arg3] = {
			ReadText = function()
				return textBox and textBox.Text or v8.Value
			end,
			Commit = function()
				return fn14(textBox and textBox.Text or v8.Value, "blur")
			end,
		}

		local chsaeConfigControllers = nil

		if type(chsaeConfigControllers) == "table" then
			chsaeConfigControllers[arg3] = {
				GetValue = function()
					return tbl2[arg3]
				end,
				SetValue = function(arg7, arg8)
					handlers.markValueFilterChanged()
					local num = handlers.parseCompactValue(arg8)

					if num == nil then
						num = tonumber(tbl2[arg3])
						num = fn11(num) and num or 0
					end

					local v9 = handlers.formatCompactValue(num)
					local v10 = handlers.parseCompactValue(v9)
					tbl2[arg3] = v10 ~= nil and v10 or 0
					fn13(tbl2[arg3])
					fn12()

					if arg5 then
						pcall(arg5, "config")
					end
				end,
			}
		end

		return v8
	end
end

local sessionMetrics

do
	local metrics = chk.Metrics
	local tbl4 = {}
	local tbl5 = { key = "time", title = "SESSION", icon = "◷", color = Color3.fromRGB(167, 139, 250) }
	local tbl6 = { key = "safety", title = "SAFETY", icon = "◆", color = Color3.fromRGB(74, 222, 128) }
	local tbl7 = { key = "fps", title = "FPS", icon = "▥", color = Color3.fromRGB(45, 212, 191) }
	local tbl8 = { key = "ping", title = "PING", icon = "⌁", color = Color3.fromRGB(96, 165, 250) }
	local tbl9 = { key = "steals", title = "STEALS", icon = "◇", color = Color3.fromRGB(251, 191, 36) }
	local tbl10 = { key = "attempts", title = "ATTEMPTS", icon = "↻", color = Color3.fromRGB(251, 146, 60) }
	local tbl11 = { key = "stealTime", title = "STEAL TIME", icon = "◴", color = Color3.fromRGB(56, 189, 248) }
	local tbl12 = { key = "avgStealTime", title = "AVG STEAL", icon = "≈", color = Color3.fromRGB(129, 140, 248) }
	tbl4[1] = tbl5
	tbl4[2] = tbl6
	tbl4[3] = tbl7
	tbl4[4] = tbl8
	tbl4[5] = tbl9
	tbl4[6] = tbl10
	tbl4[7] = tbl11
	tbl4[8] = tbl12
	sessionMetrics = metrics(v5, "SessionMetrics", tbl4, 2)
end

sessionMetrics:Set("time", "00:00:00")
sessionMetrics:Set("safety", "Loading")
sessionMetrics:Set("fps", "--")
sessionMetrics:Set("ping", "--")
sessionMetrics:Set("steals", "0")
sessionMetrics:Set("attempts", "0")
sessionMetrics:Set("stealTime", "idle")
sessionMetrics:Set("avgStealTime", "--")

handlers.finishStealTimer = function(arg, arg2)
	local stealTimer = handlers.stealTimer
	local last = math.max(0, (tonumber(arg) or 0) + (tonumber(arg2) or 0))
	stealTimer.active = false
	stealTimer.last = last
	stealTimer.outTime = tonumber(arg) or 0
	stealTimer.backTime = tonumber(arg2) or 0
	stealTimer.completed = (tonumber(stealTimer.completed) or 0) + 1
	stealTimer.total = (tonumber(stealTimer.total) or 0) + last
	stealTimer.average = stealTimer.total / stealTimer.completed
	handlers.set("stealTime", ("⏱️ Time: %.2fs · %.2f out / %.2f back"):format(last, stealTimer.outTime, stealTimer.backTime))
	pcall(sessionMetrics.Set, sessionMetrics, "stealTime", ("%.2fs"):format(last))
	pcall(sessionMetrics.Set, sessionMetrics, "avgStealTime", ("%.2fs"):format(stealTimer.average))
end

handlers.pauseStealTimer = function()
	local stealTimer = handlers.stealTimer
	if not stealTimer.active then
		return false
	end
	stealTimer.active = false
	handlers.wakeOverlay("steal-timer-paused")
	return true
end

task.spawn(function()
	while fn() do
		local stealTimer = handlers.stealTimer

		if stealTimer.active then
			local n = math.max(0, os.clock() - (tonumber(stealTimer.startedAt) or os.clock()))
			handlers.set("stealTime", ("⏱️ Time: %.2fs"):format(n))
			pcall(sessionMetrics.Set, sessionMetrics, "stealTime", ("%.2fs"):format(n))
			task.wait(handlers.presentationInterval())
		else
			handlers.statusWake.Event:Wait()
		end
	end
end)

local v6
v6 = home:AddRightGroupbox("📊 Live Stats")
local liveMetrics

do
	local metrics = chk.Metrics
	local tbl4 = {}
	local tbl5 = { key = "money", title = "MONEY", icon = "$", color = Color3.fromRGB(251, 191, 36) }
	local tbl6 = { key = "income", title = "INCOME / SEC", icon = "+", color = Color3.fromRGB(74, 222, 128) }
	local tbl7 = { key = "speed", title = "SPEED", icon = "»", color = Color3.fromRGB(251, 146, 60) }
	local tbl8 = { key = "eggs", title = "EGG INVENTORY", icon = "🥚", color = Color3.fromRGB(244, 114, 182) }
	local tbl9 = { key = "pets", title = "PET INVENTORY", icon = "◆", color = Color3.fromRGB(96, 165, 250) }

	local tbl10 = {
		key = "petValue",
		title = "TOTAL PET VALUE",
		icon = "$",
		color = Color3.fromRGB(167, 139, 250),
	}

	tbl4[1] = tbl5
	tbl4[2] = tbl6
	tbl4[3] = tbl7
	tbl4[4] = tbl8
	tbl4[5] = tbl9
	tbl4[6] = tbl10
	liveMetrics = metrics(v6, "LiveMetrics", tbl4, 1)
end

liveMetrics:Set("money", "Loading...")
liveMetrics:Set("income", "Loading...")
liveMetrics:Set("speed", "Loading...")
liveMetrics:Set("eggs", "Loading...")
liveMetrics:Set("pets", "Loading...")
liveMetrics:Set("petValue", "Loading...")
local v7
v7 = home:AddLeftGroupbox("🌐 Server")
getgenv().__CHSAE_RuntimeConns = getgenv().__CHSAE_RuntimeConns or {}

handlers.failSameServerRejoin = function(arg, arg2)
	if not handlers.sameServerRejoinPending then
		return
	end

	if arg2 ~= nil and handlers.sameServerRejoinAttempt ~= arg2 then
		return
	end
	handlers.sameServerRejoinPending = false
	handlers.sameServerRejoinAttempt = nil
	handlers.intentionalDisconnectUntil = 0
	lua:Notify("⚠️ Same-server rejoin failed: " .. tostring(arg or "Teleport failed"), 5)
end

handlers.requestSameServerRejoin = function()
	if handlers.sameServerRejoinPending or handlers.serverHopPending then
		lua:Notify("⚠️ another teleport is already pending", 4)
		return false
	end
	local placeId = game.PlaceId
	local jobId = game.JobId
	if type(jobId) ~= "string" or jobId == "" then
		lua:Notify("⚠️ Same-server rejoin failed: job id unavailable", 5)
		return false
	end
	handlers.sameServerRejoinPending = true
	local sameServerRejoinAttempt = {}
	handlers.sameServerRejoinAttempt = sameServerRejoinAttempt
	handlers.intentionalDisconnectUntil = os.clock() + 45

	task.spawn(function()
		local ok, result = pcall(function()
			TeleportService:TeleportToPlaceInstance(placeId, jobId, localPlayer)
		end)

		if not ok then
			handlers.failSameServerRejoin(result, sameServerRejoinAttempt)
		end
	end)

	task.delay(45, function()
		if fn() and handlers.sameServerRejoinAttempt == sameServerRejoinAttempt then
			handlers.failSameServerRejoin("teleport timed out", sameServerRejoinAttempt)
		end
	end)

	return true
end

pcall(function()
	getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = TeleportService.TeleportInitFailed:Connect(function(arg, arg2, arg3)
		if arg ~= localPlayer then
			return
		end

		if os.clock() < (tonumber(handlers.intentionalDisconnectUntil) or 0) then
			handlers.failSameServerRejoin(arg3)
		end
	end)
end)

makeButtonPanel(v7, "BtnServerPanel", {
	{
		"🔄 Rejoin Server",
		function()
			handlers.requestSameServerRejoin("Same-server rejoin")
		end,
	},
	{
		"💬 Copy Discord",
		function()
			local genv = getgenv()
			local value = rawget(genv, "Clipboard")
			local set = rawget(genv, "setclipboard") or rawget(genv, "toclipboard") or type(value) == "table" and value.set
			if type(set) ~= "function" then
				lua:Notify("Discord: discord.gg/CloverOnTop", 5)
				return
			end
			lua:Notify(pcall(set, "discord.gg/CloverOnTop") and "✅ Discord copied." or "❌ Copy failed.", 3)
		end,
	},
})

local now
now = os.clock()
local clientFPS
clientFPS = 60

do
	local n = 0
	local n2 = 0

	local connection = RunService.RenderStepped:Connect(function(deltaTime)
		n2 += 1
		n += deltaTime
		handlers.clientFrameSeconds = math.clamp(deltaTime, 0.0041666666666666666, 0.25)

		if n >= 1 then
			clientFPS = math.floor(n2 / n + 0.5)
			n2 = 0
			n = 0
			handlers.clientFPS = clientFPS
		end
	end)

	local chsaeRuntimeConns = getgenv().__CHSAE_RuntimeConns

	if type(chsaeRuntimeConns) == "table" then
		chsaeRuntimeConns[#chsaeRuntimeConns + 1] = connection
	end
end

task.spawn(function()
	local v8 = nil
	local v9 = nil

	while fn() do
		pcall(function()
			local v10, v11 = handlers.getSafetySummary()
			local str = tostring(v10):gsub("^🛡️%s*", ""):gsub("^⚠️%s*", "")

			if str ~= v8 or v11 ~= v9 then
				v8 = str
				v9 = v11
				handlers.wakeOverlay("safety")
			end

			sessionMetrics:Set("time", fn4(os.clock() - now))
			sessionMetrics:Set("safety", str, (tonumber(v11) or 0) > 0 and Color3.fromRGB(252, 165, 165) or Color3.fromRGB(134, 239, 172))
			sessionMetrics:Set("steals", tostring(handlers.steals or 0))
			sessionMetrics:Set("attempts", tostring(handlers.attempts or 0))
			local average = handlers.stealTimer.average
			sessionMetrics:Set("avgStealTime", average and ("%.2fs"):format(average) or "--")
		end)

		task.wait(1)
	end
end)

task.spawn(function()
	local tbl4 = nil
	local tbl5 = nil
	local salePrice = nil
	local Eggs = nil

	local function fn11(arg)
		if typeof(arg) ~= "RBXScriptConnection" then
			return
		end
		local chsaeRuntimeConns = getgenv().__CHSAE_RuntimeConns

		if type(chsaeRuntimeConns) == "table" then
			chsaeRuntimeConns[#chsaeRuntimeConns + 1] = arg
		end
	end

	local function fn12(arg)
		local v8, v9, v10 = pairs(type(arg) == "table" and arg or {})
		local n = 0

		for k in v8, v9, v10 do
			n += 1
		end

		return n
	end

	local function fn13()
		local flag2 = false

		pcall(function()
			local v8 = tbl4 and tbl4.Get()

			if type(v8) == "table" then
				if v8.Money then
					liveMetrics:Set("money", "$" .. fn3(v8.Money))
				end

				if v8.SpeedPower then
					liveMetrics:Set("speed", fn3(v8.SpeedPower))
					flag2 = true
				end
			end
		end)

		pcall(function()
			local leaderstats = localPlayer:FindFirstChild("leaderstats")
			local moneyS = leaderstats and leaderstats:FindFirstChild("Money/s")

			if moneyS then
				liveMetrics:Set("income", "$" .. fn3(moneyS.Value) .. "/s")
			end

			leaderstats = leaderstats and leaderstats:FindFirstChild("Speed")

			if leaderstats and not flag2 then
				liveMetrics:Set("speed", fn3(leaderstats.Value))
			end
		end)
	end

	local flag2 = false
	local n = 0

	local function fn14(arg)
		local v8 = nil

		pcall(function()
			v8 = tbl4 and tbl4.Get()
		end)

		if type(v8) ~= "table" then
			return
		end
		local v9 = fn12(v8.EggInventory)
		local num = tonumber(Eggs and Eggs.MAX_INVENTORY)
		local tbl6 = type(v8.Inventory) == "table" and table.clone(v8.Inventory) or {}
		local v10 = fn12(tbl6)
		local now2 = os.clock()
		local flag3 = tbl5 and salePrice and type(v8.Inventory) == "table"
		local n2 = localPlayer:GetAttribute("VIP") and 2 or 1
		local n3 = 0

		if flag3 then
			local n4 = 0

			for _, v11 in pairs(tbl6) do
				if not fn() or arg ~= n then
					return
				end
				local ok, result = pcall(tbl5.Deserialize, v11)

				if ok and type(result) == "table" then
					local ok2, result2 = pcall(salePrice, result)

					if ok2 then
						n3 += (tonumber(result2) or 0) * n2
					end
				end

				n4 += 1

				if n4 % 16 == 0 or os.clock() - now2 >= 0.002 then
					handlers.inventoryStatsYields = (handlers.inventoryStatsYields or 0) + 1
					task.wait()
					now2 = os.clock()
				end
			end
		end

		if not fn() or arg ~= n then
			return
		end
		liveMetrics:Set("eggs", num and num > 0 and ("%d / %d"):format(v9, num) or tostring(v9))
		liveMetrics:Set("pets", tostring(v10))
		liveMetrics:Set("petValue", flag3 and "$" .. fn3(n3) or "--")
		handlers.inventoryStatsPasses = (handlers.inventoryStatsPasses or 0) + 1
	end

	local function fn15()
		n += 1

		if tbl.InventoryWake then
			tbl.InventoryWake("inventory")
		end

		if flag2 then
			return
		end
		flag2 = true

		task.defer(function()
			while fn() do
				task.wait(0.25)
				pcall(fn14, n)
				if n ~= n then
					continue
				end
				break
			end

			flag2 = false
		end)
	end

	task.spawn(function()
		local v8 = nil

		pcall(function()
			v8 = GetSaveModule()
		end)

		if not (fn() and type(v8) == "table") then
			return
		end

		tbl4 = { Get = function()
			return v8.Get()
		end }

		pcall(fn13)
		fn15()

		pcall(function()
			fn11(v8.FieldSignal("Money"):Connect(fn13))
		end)

		pcall(function()
			fn11(v8.FieldSignal("SpeedPower"):Connect(fn13))
		end)

		pcall(function()
			fn11(v8.FieldSignal("Inventory"):Connect(fn15))
		end)

		pcall(function()
			fn11(v8.FieldSignal("EggInventory"):Connect(fn15))
		end)
	end)

	pcall(fn13)
	fn15()

	task.spawn(function()
		task.wait(1)

		pcall(function()
			tbl5 = { Deserialize = require(ReplicatedStorage.Shared.Util.AssetItems).Decode }
		end)

		pcall(function()
			salePrice = require(ReplicatedStorage.Shared.Util.AssetItems).SalePrice
		end)

		pcall(function()
			Eggs = require(ReplicatedStorage.Shared.Types.Eggs)
		end)

		fn15()
	end)

	fn11(localPlayer:GetAttributeChangedSignal("VIP"):Connect(fn15))
	local n2 = os.clock() + 30

	while fn() do
		pcall(function()
			local str = "--"
			local value = nil

			pcall(function()
				value = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
				str = ("%dms"):format(math.floor(value))
			end)

			sessionMetrics:Set("fps", tostring(clientFPS))
			sessionMetrics:Set("ping", str)
		end)

		pcall(fn13)

		if n2 <= os.clock() then
			n2 = os.clock() + 30
			fn15()
		end

		task.wait(5)
	end
end)

local v8
v8 = eggs:AddLeftGroupbox("🎯 Steal Filter")
local tbl4, tbl5, tbl6, tbl7, tbl8

do
	local v9 = fn7()
	local tbl9 = {}
	local tbl10 = {}
	tbl4 = {}
	tbl5 = {}
	tbl6 = {}
	tbl7 = {}
	tbl8 = { Items = {}, Display = {} }

	for _, v10 in ipairs(v9) do
		tbl9[#tbl9 + 1] = v10.id
		tbl10[v10.id] = string.format("<font color=\"%s\"><b>%s</b></font>", typeof(v10.color) == "Color3" and fn5(v10.color) or "#FFFFFF", v10.id) .. (v10.odds and string.format(" <font color=\"%s\">%s</font>", "#9AA0AA", tostring(v10.odds)) or "")
	end

	if #tbl9 == 0 then
	end

	local tbl11 = {}
	local tbl12 = {}
	local directory = nil

	pcall(function()
		local Areas = require(ReplicatedStorage.Data.Areas)
		local Assets = require(ReplicatedStorage.Data.Assets)
		directory = Assets.Directory
		local v10 = pairs
		local directory2 = Areas.Directory or {}

		for _, v11 in v10(directory2) do
			local tbl13 = { v11 }
			local v12 = ipairs
			local subBiomes = v11.SubBiomes or {}

			for _, subBiome in v12(subBiomes) do
				tbl13[#tbl13 + 1] = subBiome
			end

			for _, v13 in ipairs(tbl13) do
				local v14 = pairs
				local dropTable = v13.DropTable or {}

				for k, v15 in v14(dropTable) do
					local flag2 = type(v15) == "table" and v15[1] or k
					local directory3 = Assets.Directory and Assets.Directory[flag2]

					if flag2 then
						tbl12[tostring(flag2)] = true
					end

					directory3 = directory3 and directory3.Rarity
					directory3 = type(directory3) == "table" and directory3._id or directory3

					if directory3 then
						tbl11[tostring(directory3)] = true
					end
				end
			end
		end
	end)

	if next(tbl11) == nil then
		for _, v10 in ipairs({
			"Common",
			"Uncommon",
			"Rare",
			"Epic",
			"Legendary",
			"Mythic",
			"Cosmic",
			"Divine",
			"Eternal",
			"Secret",
		}) do
			tbl11[v10] = true
		end
	end

	for _, v10 in ipairs(v9) do
		if tbl11[v10.id] then
			tbl4[#tbl4 + 1] = v10.id
			tbl5[v10.id] = tbl10[v10.id]
		end
	end

	if #tbl4 == 0 then
		for _, v10 in ipairs({
			"Secret",
			"Eternal",
			"Divine",
			"Cosmic",
			"Mythic",
			"Legendary",
			"Epic",
			"Rare",
			"Uncommon",
			"Common",
		}) do
			tbl4[#tbl4 + 1] = v10
			tbl5[v10] = tbl10[v10] or v10
		end
	end

	for k in pairs(tbl2.TargetRarities) do
		if not tbl11[k] then
			tbl2.TargetRarities[k] = nil
		end
	end

	for _, v10 in ipairs({ "PlaceRarities", "SellRarities", "SellEggRarities" }) do
		local v11 = tbl2[v10]

		if type(v11) == "table" then
			for k in pairs(v11) do
				if not tbl11[k] then
					v11[k] = nil
				end
			end
		end
	end

	local tbl13 = {}

	for k in pairs(tbl12) do
		local v10 = directory and directory[k]
		local rarity = v10 and v10.Rarity
		local n = #tbl13 + 1
		local tbl14 = { id = k, name = tostring(v10 and (v10.DisplayName or v10.Name) or k) }
		local flag2 = type(rarity) == "table"

		if flag2 then
			flag2 = tostring(rarity._id or rarity.DisplayName or "")
		end

		local rarity2

		if flag2 then
			rarity2 = flag2
		else
			rarity2 = tostring(rarity or "")
		end

		tbl14.rarity = rarity2
		tbl14.rate = tonumber(v10 and v10.EarningRate) or 0
		tbl14.color = type(rarity) == "table" and rarity.Color or nil
		tbl13[n] = tbl14
	end

	table.sort(tbl13, function(arg, arg2)
		if arg.rate ~= arg2.rate then
			return arg.rate > arg2.rate
		end
		return arg.name < arg2.name
	end)

	for _, v10 in ipairs(tbl13) do
		tbl8.Items[#tbl8.Items + 1] = v10.id
		local str = typeof(v10.color) == "Color3" and fn5(v10.color) or "#FFFFFF"
		local display = tbl8.Display
		local id = v10.id
		local format = ("<b>%s</b> <font color=\"%s\">%s</font> <font color=\"#9AA0AA\">$%s/s</font>").format
		local name = v10.name
		local rarity = v10.rarity
		local v11 = fn3(v10.rate)
		display[id] = format("<b>%s</b> <font color=\"%s\">%s</font> <font color=\"#9AA0AA\">$%s/s</font>", name, str, rarity, v11)
	end

	for k in pairs(tbl2.TargetCategories) do
		if not tbl12[k] then
			tbl2.TargetCategories[k] = nil
		end
	end

	for _, v10 in ipairs({ "PlaceCategories", "SellPets", "SellEggNames", "FuseCategories" }) do
		local v11 = tbl2[v10]

		if type(v11) == "table" then
			for k in pairs(v11) do
				if not tbl12[k] then
					v11[k] = nil
				end
			end
		end
	end
end

do
	local tbl9 = {
		"Light Dark",
		"Titan Temple",
		"Cherry Blossom",
		"Cosmic",
		"Prehistoric",
		"Abyss Ocean",
		"Volcano",
		"Snow",
		"Jungle",
		"Desert",
		"Lake",
		"Forest",
	}

	local tbl10 = {}

	pcall(function()
		local v9 = pairs
		local directory = require(ReplicatedStorage.Data.Areas).Directory or {}

		for k, v10 in v9(directory) do
			if type(v10) == "table" and type(v10.DropTable) == "table" and next(v10.DropTable) ~= nil then
				tbl10[tostring(v10._id or k)] = true
			end
		end
	end)

	if next(tbl10) == nil then
		for _, v9 in ipairs(tbl9) do
			tbl10[v9] = true
		end
	end

	for _, v9 in ipairs(tbl9) do
		if tbl10[v9] then
			tbl6[#tbl6 + 1] = v9
			tbl10[v9] = nil
		end
	end

	local tbl11 = {}

	for k in pairs(tbl10) do
		tbl11[#tbl11 + 1] = k
	end

	table.sort(tbl11)

	for _, v9 in ipairs(tbl11) do
		tbl6[#tbl6 + 1] = v9
	end
end

local tbl9 = {
	Forest = "#62D96B",
	Lake = "#51BCEC",
	Desert = "#E6B85C",
	Jungle = "#42C98A",
	Snow = "#B9DFFB",
	Volcano = "#FF6B5F",
	["Abyss Ocean"] = "#5E8CFF",
	Prehistoric = "#D49A65",
	Cosmic = "#B37BFF",
	["Cherry Blossom"] = "#FF8FB8",
	["Titan Temple"] = "#F0C86A",
	["Light Dark"] = "#D7B8FF",
}

for _, v9 in ipairs(tbl6) do
	tbl7[v9] = ("<font color=\"%s\"><b>%s</b></font>"):format(tbl9[v9] or "#FFFFFF", v9)
end

local tbl10 = {}

for _, v9 in ipairs(tbl6) do
	tbl10[v9] = true
end

for _, v9 in ipairs({ "TargetAreas", "EggESPAreas" }) do
	for k in pairs(tbl2[v9]) do
		if not tbl10[k] then
			tbl2[v9][k] = nil
		end
	end
end

local AutoStealToggle, fn11, fn12, fn13, fn14, fn15, v9

do
	local StealStatusLabel = nil
	AutoStealToggle = nil

	fn11 = function(arg)
		local inventoryFullStopped = handlers.inventoryFullStopped

		if inventoryFullStopped then
			inventoryFullStopped = not (AutoStealToggle and AutoStealToggle.Value)
		end

		if inventoryFullStopped then
			arg = "🟠 Inventory full · Auto-Steal off"
		end

		handlers.set("steal", "🥷 Steal: " .. tostring(arg):gsub("^[^%w%s]+%s*", ""))
		handlers.setLabel(StealStatusLabel, arg)

		if type(handlers.resizeStealStatus) == "function" then
			handlers.resizeStealStatus()
		end
	end

	fn12 = nil
	fn13 = nil
	fn14 = nil

	fn15 = function()
		if not (AutoStealToggle and AutoStealToggle.Value) then
			fn11("🔴 Off")
		end
	end

	bindDropdownOverlay(v8, "EggTargetRarities", "Rarities", tbl4, {
		configKey = "TargetRarities",
		multi = true,
		store = tbl2.TargetRarities,
		text = "Rarities",
		tooltip = "Choose rarities. Empty = all.",
		displayMap = tbl5,
		onChange = function()
			if fn13 then
				fn13()
			end

			fn15()

			if fn12 then
				fn12("filter")
			end
		end,
	})

	bindDropdownOverlay(v8, "EggTargetCategories", "Categories", tbl8.Items, {
		configKey = "TargetCategories",
		multi = true,
		store = tbl2.TargetCategories,
		text = "Categories",
		tooltip = "Choose categories. Empty = all.",
		displayMap = tbl8.Display,
		onChange = function()
			if fn13 then
				fn13()
			end

			fn15()

			if fn12 then
				fn12("category-filter")
			end
		end,
	})

	bindDropdownOverlay(v8, "EggTargetAreas", "Areas", tbl6, {
		configKey = "TargetAreas",
		multi = true,
		store = tbl2.TargetAreas,
		text = "Areas",
		tooltip = "Choose spawning areas. Empty = all.",
		displayMap = tbl7,
		onChange = function()
			if fn13 then
				fn13()
			end

			fn15()

			if fn12 then
				fn12("area-filter")
			end
		end,
	})

	local tbl11 = { "Rarest", "Nearest", "Highest Value", "Highest KG", "Has Mutation", "Farthest" }

	local tbl12 = {
		Nearest = nil,
		["Highest Value"] = "Value",
		["Highest KG"] = "Weight",
		Rarest = "Rarity",
		["Has Mutation"] = "Mutation",
		Farthest = "Farthest",
	}

	bindDropdownOverlay(v8, "EggTargetPriority", "Priority", tbl11, {
		configKey = "TargetPriority",
		multi = false,
		text = "Priority",
		tooltip = "Choose which egg comes first.",
		displayMap = {
			Nearest = "<b>Nearest</b> <font color=\"#9AA0AA\">closest</font>",
			["Highest Value"] = "<font color=\"#F5C83C\"><b>Highest Value</b></font> <font color=\"#9AA0AA\">best income</font>",
			["Highest KG"] = "<font color=\"#7DD3FC\"><b>Highest KG</b></font> <font color=\"#9AA0AA\">heaviest egg</font>",
			Rarest = "<font color=\"#AA50E6\"><b>Rarest</b></font> <font color=\"#9AA0AA\">highest tier</font>",
			["Has Mutation"] = "<font color=\"#49E685\"><b>Has Mutation</b></font> <font color=\"#9AA0AA\">mutated only</font>",
			Farthest = "<font color=\"#E6A849\"><b>Farthest</b></font> <font color=\"#9AA0AA\">longest route</font>",
		},
		configValueToItem = function(arg)
			if table.find(tbl11, arg) then
				return arg
			end

			for k, v10 in pairs(tbl12) do
				if v10 == arg then
					return k
				end
			end

			return "Rarest"
		end,
		get = function()
			if tbl2.TargetPriority == nil then
				return "Nearest"
			end

			for k, v10 in pairs(tbl12) do
				if v10 == tbl2.TargetPriority then
					return k
				end
			end

			return "Rarest"
		end,
		set = function(arg)
			tbl2.TargetPriority = tbl12[arg]
		end,
		onChange = function()
			if fn13 then
				fn13()
			end

			fn15()

			if fn12 then
				fn12("priority")
			end
		end,
	})

	handlers.addKGFilterControls(v8, "EggTarget", "TargetKGMode", "TargetKGThreshold", function()
		if fn13 then
			fn13()
		end

		fn15()

		if fn12 then
			fn12("kg-filter")
		end
	end)

	handlers.addValueFilterInput(v8, "EggTargetValueThreshold", "TargetValueThreshold", "Minimum Value", function()
		if fn13 then
			fn13()
		end

		fn15()

		if fn12 then
			fn12("value-filter")
		end
	end, "Steal only eggs at or above this native $/s value. K, M, B, T work; 0 disables.")

	v9 = eggs:AddRightGroupbox("🥚 Auto-Steal")

	chk.Merge(v9, function()
		StealStatusLabel = v9:AddLabel("StealStatusLabel", { Text = "🔴 Off", DoesWrap = true })

		task.defer(function()
			pcall(function()
				for _, v10 in ipairs(v9.Container:QueryDescendants("TextLabel")) do
					if v10.Parent and v10.Parent:IsA("Frame") then
						v10.TextWrapped = true
						v10.TextTruncate = Enum.TextTruncate.None
						v10.AutomaticSize = Enum.AutomaticSize.Y
						v10.Size = UDim2.new(1, 0, 0, 18)
						break
					end
				end

				handlers.resizeStealStatus = function()
					task.defer(function()
						if v9.Resize then
							v9:Resize()
						end
					end)
				end

				handlers.resizeStealStatus()
			end)
		end)
	end)
end

AutoStealToggle = (function()
	local _t = {Value = tbl2.AutoSteal, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.AutoSteal = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

v9:AddToggle("PersistentStealToggle", {
	Text = "Persistent Steal",
	Default = tbl2.PersistentSteal,
	Tooltip = "Retry the same egg until claimed.",
}):OnChanged(function(persistentSteal)
	tbl2.PersistentSteal = persistentSteal

	if fn12 then
		fn12(persistentSteal and "persistent-enabled" or "persistent-disabled")
	end
end)

local StealServerHopToggle = (function()
	local _t = {Value = tbl2.StealServerHop, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.StealServerHop = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

StealServerHopToggle:OnChanged(function(arg)
	tbl2.StealServerHop = arg == true

	if handlers.stealHop then
		handlers.stealHop.emptySince = nil
	end

	fn10(true)

	if fn12 then
		fn12("server-hop-toggle")
	end
end)
v3.__ProtectionBox = eggs:AddRightGroupbox("🛡️ Protection")

v3.__ProtectionBox:AddToggle("PreventTrapsToggle", {
	Text = "Prevent Traps",
	Default = tbl2.PreventTraps,
	Tooltip = "Block and avoid enemy traps while carrying.",
}):OnChanged(function(preventTraps)
	tbl2.PreventTraps = preventTraps

	if fn14 then
		fn14()
	end
end)

local GuardProtectionToggle = (function()
	local _t = {Value = tbl2.GuardProtection, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.GuardProtection = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

GuardProtectionToggle:OnChanged(function(arg)
	tbl2.GuardProtection = arg == true

	if not tbl2.GuardProtection then
		local chsaeGuardStopActive = getgenv().__CHSAE_GuardStopActive

		if type(chsaeGuardStopActive) == "function" then
			pcall(chsaeGuardStopActive)
		end
	end
end)

local tbl11
tbl11 = nil
local Assets
Assets = nil
local tbl12
tbl12 = nil

pcall(function()
	local EggState = require(ReplicatedStorage.Client.EggState)
	local EggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)
	local AreaEggCycle = require(ReplicatedStorage.Shared.Util.AreaEggCycle)

	tbl11 = {
		GetAreaEggSnapshot = EggState.ReadFieldEggs,
		GetAreaEggRecord = EggState.ReadFieldEgg,
		AreaEggSnapshotUpdated = EggState.FieldRefreshed,
		AreaEggRecordUpdated = EggState.FieldShifted,
		AreaEggRecordRemoved = EggState.FieldGone,
		AreaEggCarryStateChanged = EggState.CarryChanged,
		AreaEggClaimed = EggState.FieldClaimed,
		RequestCarryAreaEgg = EggState.CarryFieldEgg,
		DropAreaEgg = EggState.DropFieldEgg,
		GetRuntimeSnapshot = EggState.ReadOwnedEggs,
		RuntimeSnapshotUpdated = EggState.SnapshotRefreshed,
		RuntimeResetCountdown = EggState.ResetCountdown,
		RequestEquipTool = EggState.WearEggTool,
		RequestUnequipTool = EggState.DoffEggTool,
		RequestPlaceEgg = EggState.PlantEgg,
		IsLocalEggReady = EggState.IsReadyToHatch,
		RequestHatchEgg = EggState.BeginHatch,
		RequestCompleteHatchEgg = EggState.FinishHatch,
		EggRecords = EggRecords,
		SecondsUntilReady = function(arg)
			if type(arg) ~= "table" or type(arg.Placement) ~= "table" then
				return nil
			end
			local serverTimeNow = workspace:GetServerTimeNow()
			local n = math.max(0.01, tonumber(arg.GrowthSpeedMultiplier) or 1)
			local v10 = EggRecords.CurrentNightCredit(arg, serverTimeNow, n)
			if EggRecords.IsGrown(arg, serverTimeNow, n, v10, localPlayer) then
				return 0
			end
			local v11 = EggRecords.GrowthSecondsRemaining(arg, serverTimeNow, n, v10, localPlayer)
			local v12 = n

			pcall(function()
				v12 += math.max(0, EggRecords.ServerGrowthBoostMultiplier())
			end)

			pcall(function()
				if AreaEggCycle.IsNightPhase(serverTimeNow) then
					v12 += math.max(0, AreaEggCycle.NightGrowthRate())
				end
			end)

			local n2 = v11 / math.max(0.01, v12)

			pcall(function()
				local v13 = AreaEggCycle.SecondsUntilPhaseEnd(serverTimeNow)

				if v13 > 0 then
					n2 = math.min(n2, v13 + 0.05)
				end
			end)

			return math.max(0.05, n2)
		end,
	}
end)

if tbl11 then
	pcall(function()
		tbl11.AssetItems = require(ReplicatedStorage.Shared.Util.AssetItems)
	end)

	pcall(function()
		tbl11.AssetEarnings = require(ReplicatedStorage.Shared.Util.AssetEarnings)
	end)

	pcall(function()
		local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)

		if type(Simple) == "table" and type(Simple.FormatCompact) == "function" then
			tbl11.FormatCompact = Simple.FormatCompact
		end
	end)

	pcall(function()
		local Numbers = require(ReplicatedStorage.Shared.Utils.Numbers)

		if type(Numbers) == "table" and type(Numbers.AddCommas) == "function" then
			tbl11.AddCommas = Numbers.AddCommas
		end
	end)
end

local bindableEvent, fn16, now2, fn17, fn18, n, fn19, fn20, fn21

do
	local tbl13 = nil

	pcall(function()
		local AreaEggSlotIdentity = require(ReplicatedStorage.Shared.Util.AreaEggSlotIdentity)
		tbl13 = { IsFirstAreaUid = AreaEggSlotIdentity.LooksLikeFirstAreaUid, BuildSlotKey = AreaEggSlotIdentity.SlotKey }
	end)

	local AreaEggResetWall = nil

	pcall(function()
		AreaEggResetWall = require(ReplicatedStorage.Client.AreaEggResetWall)
	end)

	bindableEvent = Instance.new("BindableEvent")
	getgenv().__CHSAE_ScanWake = bindableEvent
	getgenv().__CHSAE_ScanConns = {}

	fn12 = function(arg)
		if fn() then
			pcall(function()
				bindableEvent:Fire(arg or "change")
			end)
		end
	end

	local function fn22()
		return { closed = function(arg, arg2, arg3)
			local ok, result = pcall(function()
				if not arg or type(arg.IsSealed) ~= "function" or type(arg.ResolveWallPart) ~= "function" or not arg2 or type(arg2.IsNightPhase) ~= "function" then
					return true
				end
				local v10 = arg.IsSealed()
				local v11 = arg2.IsNightPhase(arg3)
				if v10 ~= false or v11 ~= false then
					return true
				end
				local v12 = arg.ResolveWallPart()
				if not v12 or not v12.Parent or not v12:IsA("BasePart") then
					return true
				end
				local y = v12.Size.Y
				return type(y) ~= "number" or y ~= y or y > 0.01 or y < 0
			end)

			return not ok or result ~= false
		end }
	end

	local v10 = fn22()
	local AreaEggCycle = nil

	pcall(function()
		AreaEggCycle = require(ReplicatedStorage.Shared.Util.AreaEggCycle)
	end)

	fn16 = function()
		return v10.closed(AreaEggResetWall, AreaEggCycle, workspace:GetServerTimeNow())
	end

	now2 = fn16() and 0 or os.clock()

	fn17 = function(arg, arg2)
		if not arg then
			return
		end

		local ok, result = pcall(function()
			return arg:Connect(arg2)
		end)

		if ok and result then
			table.insert(getgenv().__CHSAE_ScanConns, result)
		end
	end

	local v11 = fn16()

	local function fn23()
		local v12 = fn16()
		if v12 == v11 then
			return
		end
		v11 = v12

		if v12 then
			now2 = 0
		else
			now2 = os.clock()
		end

		fn12(v12 and "wall-closed" or "wall-open")
	end

	if AreaEggResetWall then
		fn17(AreaEggResetWall.Changed, fn23)

		local ok, result = pcall(function()
			return AreaEggResetWall.ResolveWallPart()
		end)

		if ok and result and result:IsA("BasePart") then
			fn17(result:GetPropertyChangedSignal("Size"), fn23)
		end
	end

	if tbl11 then
		fn17(tbl11.AreaEggSnapshotUpdated, function(arg)
			if type(handlers.queueCandidateIndexRebuild) == "function" then
				handlers.queueCandidateIndexRebuild(arg)
			end

			if type(handlers.refreshEggESP) == "function" then
				handlers.refreshEggESP()
			end

			if type(handlers.reconcileCarryLossSnapshot) == "function" then
				task.defer(handlers.reconcileCarryLossSnapshot, arg)
			end

			fn12("snapshot")
		end)
	end

	fn18 = function(arg, arg2)
		local bindableEvent2 = Instance.new("BindableEvent")
		local flag2 = true

		local connection = bindableEvent.Event:Connect(function(arg3)
			if flag2 then
				bindableEvent2:Fire(arg3)
			end
		end)

		task.delay(arg or 8, function()
			if flag2 then
				bindableEvent2:Fire("fallback")
			end
		end)

		if arg2 then
			local ok, result = pcall(arg2)

			if ok and result then
				flag2 = false
				connection:Disconnect()
				bindableEvent2:Destroy()
				return "already-ready"
			end
		end

		local result = bindableEvent2.Event:Wait()
		flag2 = false
		connection:Disconnect()
		bindableEvent2:Destroy()
		return result
	end

	n = 0

	fn19 = function()
		return fn16() or os.clock() < n
	end

	local function fn24(arg, arg2)
		if not (arg and arg:IsA("BasePart") and arg2) then
			return false
		end
		local v12 = arg.CFrame:PointToObjectSpace(arg2)
		local n2 = arg.Size * 0.5
		local x = n2.X
		local flag2 = math.abs(v12.X) <= x

		if flag2 then
			local z = n2.Z
			flag2 = math.abs(v12.Z) <= z
		end

		return flag2
	end

	fn20 = function(arg)
		local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
		world = world and world:FindFirstChild("Areas")
		world = world and world:FindFirstChild("GuardAreas")
		if not (world and arg) then
			return nil
		end

		for _, child in ipairs(world:GetChildren()) do
			local bounds = child:FindFirstChild("Bounds")

			if bounds and bounds:IsA("BasePart") then
				local ok, result = pcall(fn24, bounds, arg)
				if ok and result then
					return child.Name
				end
			end
		end

		return nil
	end

	local function fn25(arg)
		local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
		local areas = world and world:FindFirstChild("Areas")
		areas = areas and areas:FindFirstChild("GuardAreas")
		if not (areas and arg) then
			return "none", math.huge
		end
		local huge = math.huge
		local str = "none"

		for _, child in ipairs(areas:GetChildren()) do
			local guard = child:FindFirstChild("Guard") or child:FindFirstChild("ForestGuardAuthored")
			local primaryPart = guard and (guard.PrimaryPart or guard:FindFirstChild("HumanoidRootPart", true))

			if primaryPart then
				local magnitude = ((primaryPart.Position - arg) * Vector3.new(1, 0, 1)).Magnitude

				if magnitude < huge then
					str = child.Name
					huge = magnitude
				end
			end
		end

		return str, huge
	end

	handlers.deathWatchedHumanoids = setmetatable({}, { __mode = "k" })

	local function watchStealHumanoid(character)
		task.spawn(function()
			local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)
			if not (humanoid and humanoidRootPart) then
				return
			end

			if handlers.deathWatchedHumanoids[humanoid] then
				return
			end
			handlers.deathWatchedHumanoids[humanoid] = true
			local health = humanoid.Health
			local flag2 = false

			local connection = humanoid.HealthChanged:Connect(function(health2)
				if not fn() then
					return
				end

				if health2 <= 0 or health2 < health - 90 then
					local v12 = fn20(humanoidRootPart.Position)
					local value = rawget(getgenv(), "__CHSAE_IntegrityState")
					local value2 = type(value) == "table" and rawget(value, "Evidence") or nil
					local value3 = type(value) == "table" and rawget(value, "ImpulseContext") or nil
					local value4 = type(value) == "table" and (rawget(value, "LastObservedSample") or rawget(value, "LastSample")) or nil
					local flag3 = type(value3) == "table" and type(value4) == "table"

					if flag3 then
						flag3 = (tonumber(rawget(value3, "ExpiresAt")) or 0) - (tonumber(rawget(value4, "Timestamp")) or 0)
					end

					flag3 = flag3 or -1
					local v13, v14 = fn25(humanoidRootPart.Position)
					local value5 = rawget(getgenv(), "__CHSAE_CarryRequest")
					warn(("[CloverHub-SAE][death] hp=%.1f->%.1f area=%s pos=%.1f,%.1f,%.1f ws=%.1f killIgnore=%s threat=%s S%s/T%s/F%s ctx=%.2f correction=%s guard=%s@%.1f carryFlight=%s"):format(tonumber(health) or -1, tonumber(health2) or -1, tostring(v12 or "Start/Unknown"), humanoidRootPart.Position.X, humanoidRootPart.Position.Y, humanoidRootPart.Position.Z, tonumber(humanoid.WalkSpeed) or -1, tostring(humanoidRootPart:GetAttribute("KillPartIgnore")), tostring(type(value) == "table" and rawget(value, "ThreatLevel") or "--"), tostring(type(value2) == "table" and rawget(value2, "Speed") or 0), tostring(type(value2) == "table" and rawget(value2, "Teleport") or 0), tostring(type(value2) == "table" and rawget(value2, "Flight") or 0), flag3, tostring(type(value) == "table" and rawget(value, "CorrectionContext") ~= nil), tostring(v13), tonumber(v14) or -1, tostring(type(value5) == "table" and value5.inFlight == true)))

					if health2 <= 0 and not flag2 then
						flag2 = true
						local onAutoStealDeath = handlers.onAutoStealDeath

						if type(onAutoStealDeath) == "function" then
							task.defer(onAutoStealDeath, character)
						end
					end
				end

				health = health2
			end)

			local chsaeRuntimeConns = getgenv().__CHSAE_RuntimeConns

			if type(chsaeRuntimeConns) == "table" then
				chsaeRuntimeConns[#chsaeRuntimeConns + 1] = connection
			end
		end)
	end

	if localPlayer.Character then
		watchStealHumanoid(localPlayer.Character)
	end

	handlers.watchStealHumanoid = watchStealHumanoid
	getgenv().__CHSAE_RuntimeConns = getgenv().__CHSAE_RuntimeConns or {}
	getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = localPlayer.CharacterAdded:Connect(watchStealHumanoid)

	fn21 = function(arg)
		if not (tbl13 and arg and arg.Uid) then
			return nil
		end
		local v12 = nil

		pcall(function()
			if tbl13.IsFirstAreaUid(arg.Uid) then
				v12 = tbl13.BuildSlotKey(arg.AreaId, arg.NestId)
			end
		end)

		return v12
	end
end

pcall(function()
	Assets = require(ReplicatedStorage.Data.Assets)
end)

pcall(function()
	local Mutations = require(ReplicatedStorage.Shared.Modules.Mutations)

	tbl12 = {
		MutationNames = Mutations.Ids(),
		GetTotalMutationsEarningMulti = Mutations.EarningsFor,
		GetDisplayName = Mutations.LabelOf,
		GetMutation = function(arg)
			local v10 = Mutations.Get(arg)
			if type(v10) ~= "table" then
				return nil
			end
			return { Color = v10.Tint, ValueMulti = v10.EarningsScalar, DisplayName = v10.Label, _id = v10.Id }
		end,
	}
end)

local fn22

fn22 = function(arg)
	local tbl13 = {}

	if type(arg.Mutations) == "table" then
		for _, mutation in pairs(arg.Mutations) do
			if type(mutation) == "string" and mutation ~= "None" then
				tbl13[#tbl13 + 1] = mutation
			end
		end
	end

	return tbl13
end

local riftValueScore

riftValueScore = function(arg)
	local v10

	pcall(function()
		if type(arg) ~= "table" then
			return
		end
		local itemData = type(arg.ItemData) == "table" and arg.ItemData or arg

		if not (type(itemData.Category) == "string" and type(itemData.Scale) == "number" and type(itemData.Mutations) == "table") then
			local eggRecords = tbl11 and tbl11.EggRecords

			if eggRecords and type(eggRecords.ToAssetItemData) == "function" then
				local ok, result = pcall(eggRecords.ToAssetItemData, arg)

				if ok and type(result) == "table" then
					itemData = result
				end
			end
		end

		local assetEarnings = tbl11 and tbl11.AssetEarnings

		if type(itemData) == "table" and assetEarnings and type(assetEarnings.MutationOnlyRatePerSecond) == "function" then
			local ok, result = pcall(assetEarnings.MutationOnlyRatePerSecond, itemData)

			if ok and type(result) == "number" then
				v10 = result
			end
		end
	end)

	if type(v10) == "number" and v10 == v10 and v10 > -math.huge and v10 < math.huge then
		return math.max(v10, 0), true
	end
	local n2 = nil

	pcall(function()
		if type(arg) ~= "table" then
			return
		end
		local itemData = type(arg.ItemData) == "table" and arg.ItemData or arg
		local assetCategory = itemData.AssetCategory or itemData.Category or arg.AssetCategory or arg.Category
		local assetScale = itemData.AssetScale or itemData.Scale or arg.AssetScale or arg.Scale
		local v11 = Assets.Directory[assetCategory]
		local num = tonumber(v11 and v11.EarningRate)
		if not num or tonumber(assetScale) == nil then
			return
		end
		local v12 = fn22(arg)
		local flag2 = #v12 > 0 and tbl12
		local n3 = 1

		if flag2 then
			local ok, result = pcall(tbl12.GetTotalMutationsEarningMulti, v12)

			if ok and tonumber(result) then
				n3 = tonumber(result)
			end
		end

		n2 = num * n3 * tonumber(assetScale)
	end)

	if type(n2) ~= "number" or n2 ~= n2 or n2 <= -math.huge or n2 >= math.huge then
		n2 = 0
	end

	return math.max(n2, 0), false
end

handlers.riftValueScore = riftValueScore

handlers.valueFilterMatches = function(arg, arg2, arg3, arg4)
	if not handlers.valueFilterActive(arg2) then
		return true
	end
	local num = tonumber(arg2)
	if not num or num <= 0 then
		return false
	end
	local v10

	if type(arg) ~= "number" then
		v10, arg4 = riftValueScore(arg)
	elseif arg4 == nil then
		arg4 = true
		v10 = arg
	else
		v10 = arg
	end

	if arg4 ~= true or type(v10) ~= "number" or v10 ~= v10 or v10 <= -math.huge or v10 >= math.huge then
		return false
	end

	if arg3 == "atLeast" then
		return v10 >= num
	end

	if arg3 == "below" then
		return v10 > 0 and v10 < num
	end
	return false
end

local fn23

fn23 = function(arg)
	local n2 = nil

	pcall(function()
		if type(arg) ~= "table" then
			return
		end
		local itemData = type(arg.ItemData) == "table" and arg.ItemData or arg
		local assetCategory = itemData.AssetCategory or itemData.Category or arg.AssetCategory or arg.Category
		local assetScale = itemData.AssetScale or itemData.Scale or arg.AssetScale or arg.Scale
		local directory = assetCategory and Assets and Assets.Directory and Assets.Directory[assetCategory]
		local num = tonumber(directory and directory.ModelWeight)
		local num2 = tonumber(assetScale)
		if num == nil or num2 == nil then
			return
		end
		n2 = num * math.max(num2, 0) ^ 3
	end)

	return n2
end

handlers.kgFilterMatches = function(arg, arg2, arg3, arg4)
	if not handlers.kgFilterActive(arg2, arg3) then
		return true
	end
	local num = tonumber(arg3)
	if num == nil or num < 0 then
		return false
	end

	if type(arg) ~= "number" then
		arg = fn23(arg)
		arg4 = arg ~= nil
	elseif arg4 == nil then
		arg4 = true
	end

	if not arg4 or type(arg) ~= "number" then
		return false
	end
	local v10 = math.round(math.max(arg, 0))
	if arg2 == "Below" then
		return v10 <= num
	end
	return v10 >= num
end

local critical
critical = false
local tbl13

tbl13 = {
	claimSequence = 0,
	lastClaim = nil,
	webhookTarget = nil,
	persistentUid = nil,
	lockedUid = nil,
	requestFailureUid = nil,
	requestFailureAt = 0,
	lastRequestError = "",
	lastRequestKind = "",
	carriedUid = nil,
	lastPositiveCarryUid = nil,
	lastPositiveCarryAt = 0,
	lastDroppedUid = nil,
	disabledRecoveryHold = 25,
	featureGraceAt = 0,
	featureGrace = 12,
	dropDetectedAt = 0,
	dropCount = 0,
	deathRecoveryUid = nil,
	deathRecoveryAt = 0,
	deathRecoveryMissingAt = 0,
	deathRecoveryMissingReason = "",
	dropRecoveryRecord = nil,
	dropRecoveryRecordUid = nil,
	dropRecoveryRecordAt = 0,
	attemptUid = nil,
	lastPickupSettle = 0,
	lastPickupRequiredSettle = 0,
	lastPickupDistance = math.huge,
	lastPickupFromTreadmill = false,
	respawnGeneration = 0,
	characterToken = localPlayer.Character,
	deathCarryEvidenceTtl = 12,
	deathRecoveryMissingGrace = 15,
	rememberPositiveCarry = function(lastPositiveCarryUid)
		if lastPositiveCarryUid == nil then
			return
		end
		tbl13.lastPositiveCarryUid = lastPositiveCarryUid
		tbl13.lastPositiveCarryAt = os.clock()
	end,
	recentPositiveCarryUid = function()
		local lastPositiveCarryUid = tbl13.lastPositiveCarryUid
		local n2 = os.clock() - (tonumber(tbl13.lastPositiveCarryAt) or 0)
		if lastPositiveCarryUid ~= nil and n2 >= 0 and n2 <= tbl13.deathCarryEvidenceTtl then
			return lastPositiveCarryUid
		end
		return nil
	end,
	clearSyncFailure = function()
		local str = tostring(tbl13.lastRequestKind or "")
		if str ~= "carry-loss-sync" and str ~= "death-drop-sync" and str ~= "carry-drop" then
			return
		end
		local v10 = tbl13
		tbl13.requestFailureUid = nil
		v10.requestFailureAt = 0
		local v11 = tbl13
		tbl13.lastRequestKind = ""
		v11.lastRequestError = ""
	end,
	clearPositiveCarryEvidence = function(arg)
		if arg == nil or tostring(tbl13.lastPositiveCarryUid) == tostring(arg) then
			tbl13.lastPositiveCarryUid = nil
			tbl13.lastPositiveCarryAt = 0
		end
	end,
}

fn13 = function()
	tbl13.persistentUid = nil
	tbl13.lockedUid = nil
	tbl13.attemptUid = nil
	tbl13.lastDroppedUid = nil
	tbl13.dropDetectedAt = 0
	tbl13.deathRecoveryUid = nil
	tbl13.deathRecoveryAt = 0
	tbl13.deathRecoveryMissingAt = 0
	tbl13.deathRecoveryMissingReason = ""
	tbl13.dropRecoveryRecord = nil
	tbl13.dropRecoveryRecordUid = nil
	tbl13.dropRecoveryRecordAt = 0
	handlers.pendingDroppedUid = nil
	tbl13.clearPositiveCarryEvidence()
	tbl13.clearSyncFailure()
end

if type(getgenv().__CHSAE_CarryRequest) ~= "table" then
	getgenv().__CHSAE_CarryRequest = nil
end

handlers.rejectedDeliveries = {}

handlers.deliveryRejected = function(arg)
	local flag2 = arg ~= nil

	if flag2 then
		flag2 = (handlers.rejectedDeliveries[tostring(arg)] or 0) > os.clock()
	end

	return flag2
end

handlers.noteDeliveryFailure = function(arg)
	if arg == "Delivery failed! The egg was returned to its nest." then
		local carriedUid = tbl13.carriedUid or handlers.lastDeliveryRejectedUid

		if carriedUid ~= nil then
			handlers.rejectedDeliveries[tostring(carriedUid)] = os.clock() + 300

			if tostring(tbl13.lockedUid) == tostring(carriedUid) or tostring(tbl13.persistentUid) == tostring(carriedUid) then
				fn13()
			end
		end
	end

	if not fn() or arg ~= "Delivery failed! The egg was returned to its nest." then
		return false
	end
	local chsaeCarryRequest = getgenv().__CHSAE_CarryRequest
	if type(chsaeCarryRequest) ~= "table" or chsaeCarryRequest.owner ~= "Steal" or chsaeCarryRequest.accepted ~= true or chsaeCarryRequest.carrySeen ~= true or chsaeCarryRequest.claimSeen == true or chsaeCarryRequest.deliveryRejected == true or chsaeCarryRequest.session ~= tbl.Marker or chsaeCarryRequest.character ~= localPlayer.Character or chsaeCarryRequest.generation ~= tbl13.respawnGeneration or chsaeCarryRequest.uid == nil or tbl13.lockedUid == nil or tostring(chsaeCarryRequest.uid) ~= tostring(tbl13.lockedUid) then
		return false
	end
	chsaeCarryRequest.deliveryRejected = true
	handlers.deliveryRejections = (handlers.deliveryRejections or 0) + 1
	handlers.lastDeliveryRejectedUid = chsaeCarryRequest.uid

	if fn12 then
		fn12("delivery-retry")
	end

	return true
end

local packages = ReplicatedStorage:FindFirstChild("Packages")
packages = packages and packages:FindFirstChild("Networking")
packages = packages and packages:FindFirstChild("RE/Alerts/Raise")

if packages and packages:IsA("RemoteEvent") then
	fn17(packages.OnClientEvent, function(arg, arg2, arg3)
		arg3 = type(arg3) == "table" and arg3 or arg

		if type(arg3) == "table" then
			handlers.noteDeliveryFailure(arg3.Message or arg3.Text)
		end
	end)
end

if tbl11 then
	pcall(function()
		fn17(tbl11.AreaEggCarryStateChanged, function(arg)
			if not fn() then
				return
			end

			if handlers.StealClaim then
				handlers.StealClaim:observeCarry(arg)
			end

			local uid = type(arg) == "table" and arg.Uid or nil
			local flag2 = critical
			local carriedUid = tbl13.carriedUid
			critical = type(arg) == "table" and arg.IsCarrying == true or type(arg) ~= "table" and arg == true

			if critical then
				flag2 = uid == nil and flag2 and carriedUid ~= nil

				if not flag2 then
					carriedUid = uid
				end

				tbl13.carriedUid = carriedUid
				tbl13.rememberPositiveCarry(tbl13.carriedUid)
				local chsaeCarryRequest = getgenv().__CHSAE_CarryRequest

				if type(chsaeCarryRequest) == "table" and tostring(chsaeCarryRequest.uid) == tostring(tbl13.carriedUid) then
					chsaeCarryRequest.carrySeen = true
					chsaeCarryRequest.carryActive = true
					chsaeCarryRequest.carryEndedSeen = false
					chsaeCarryRequest.droppedSeen = false
				end

				if tostring(handlers.pendingDroppedUid) == tostring(tbl13.carriedUid) then
					handlers.pendingDroppedUid = nil
				end

				if tostring(tbl13.deathRecoveryUid) == tostring(tbl13.carriedUid) then
					tbl13.deathRecoveryUid = nil
					tbl13.deathRecoveryAt = 0
					tbl13.deathRecoveryMissingAt = 0
					tbl13.deathRecoveryMissingReason = ""
				end

				if tostring(tbl13.dropRecoveryRecordUid) == tostring(tbl13.carriedUid) then
					tbl13.dropRecoveryRecord = nil
					tbl13.dropRecoveryRecordUid = nil
					tbl13.dropRecoveryRecordAt = 0
				end

				if type(arg) == "table" and arg.AreaId ~= nil then
					handlers.activeGuardAreaId = tostring(arg.AreaId)
				end
			else
				local uid2 = type(arg) == "table" and arg.Uid or carriedUid or tbl13.lockedUid or tbl13.attemptUid
				local chsaeCarryRequest = getgenv().__CHSAE_CarryRequest

				if type(chsaeCarryRequest) == "table" and tostring(chsaeCarryRequest.uid) == tostring(uid2) then
					chsaeCarryRequest.carryActive = false
					chsaeCarryRequest.carryEndedSeen = true
				end

				local flag3 = type(chsaeCarryRequest) == "table" and tostring(chsaeCarryRequest.uid) == tostring(uid2) and chsaeCarryRequest.carrySeen == true
				local flag4 = tostring(tbl13.deathRecoveryUid) == tostring(uid2)

				if uid2 ~= nil and (flag2 or flag3 or flag4) then
					if handlers.isCaptureEventUid(uid2) then
						tbl13.rememberPositiveCarry(uid2)

						if tostring(tbl13.lockedUid) == tostring(uid2) then
							tbl13.lockedUid = nil
						end

						if tostring(tbl13.persistentUid) == tostring(uid2) then
							tbl13.persistentUid = nil
						end

						local chsaeAdminEventWake = getgenv().__CHSAE_AdminEventWake

						if chsaeAdminEventWake then
							pcall(function()
								chsaeAdminEventWake:Fire("capture-dropped")
							end)
						end
					else
						tbl13.rememberPositiveCarry(uid2)
						tbl13.lastDroppedUid = uid2
						tbl13.dropDetectedAt = os.clock()
						tbl13.lockedUid = uid2
						tbl13.requestFailureUid = uid2
						tbl13.requestFailureAt = tbl13.dropDetectedAt
						tbl13.lastRequestKind = flag4 and "death-drop-sync" or "carry-loss-sync"
						tbl13.lastRequestError = "carry ended; checking delivery or drop"
						handlers.pendingDroppedUid = uid2

						if type(chsaeCarryRequest) == "table" and tostring(chsaeCarryRequest.uid) == tostring(uid2) then
							chsaeCarryRequest.carrySeen = true
						end

						if type(handlers.armDroppedEggReacquire) == "function" then
							task.defer(handlers.armDroppedEggReacquire, uid2, "carry state reported a drop")
						end

						if fn12 then
							fn12("carry-dropped")
						end
					end
				end

				tbl13.carriedUid = nil
				handlers.activeGuardAreaId = nil
			end

			if critical and tbl13.carriedUid == nil then
				critical = false
				handlers.activeGuardAreaId = nil
			end

			handlers.carry = critical and "📦 Carry: locally verified" or "📦 Carry: none"
			handlers.wakeOverlay("carry-state")
		end)

		if tbl11.AreaEggRecordUpdated then
			fn17(tbl11.AreaEggRecordUpdated, function(dropRecoveryRecordUid, arg)
				if not fn() then
					return
				end
				local dropRecoveryRecord = type(dropRecoveryRecordUid) == "table" and dropRecoveryRecordUid or type(arg) == "table" and arg or nil
				local uid = dropRecoveryRecord and (dropRecoveryRecord.Uid or dropRecoveryRecord.UID or dropRecoveryRecord.EggUid)

				if uid then
					dropRecoveryRecordUid = uid
				else
					dropRecoveryRecordUid = type(dropRecoveryRecordUid) ~= "table" and dropRecoveryRecordUid
				end

				dropRecoveryRecordUid = dropRecoveryRecordUid or type(arg) ~= "table" and arg
				if dropRecoveryRecordUid == nil or type(dropRecoveryRecord) ~= "table" then
					return
				end
				local userId = localPlayer.UserId

				if tonumber(dropRecoveryRecord.CarrierUserId) == userId then
					tbl13.rememberPositiveCarry(dropRecoveryRecordUid)
				end

				if type(handlers.queueCandidateIndexRebuild) == "function" then
					handlers.queueCandidateIndexRebuild("field-shifted")
				end

				local flag2 = tostring(dropRecoveryRecordUid) == tostring(tbl13.lockedUid) or tostring(dropRecoveryRecordUid) == tostring(tbl13.attemptUid) or tostring(dropRecoveryRecordUid) == tostring(tbl13.carriedUid) or tostring(dropRecoveryRecordUid) == tostring(tbl13.lastDroppedUid) or tostring(dropRecoveryRecordUid) == tostring(tbl13.deathRecoveryUid)
				local flag3 = critical or tostring(dropRecoveryRecordUid) == tostring(tbl13.carriedUid) or tostring(dropRecoveryRecordUid) == tostring(tbl13.lastDroppedUid) or tostring(dropRecoveryRecordUid) == tostring(tbl13.deathRecoveryUid)
				local chsaeCarryRequest = getgenv().__CHSAE_CarryRequest

				if type(chsaeCarryRequest) == "table" and tostring(chsaeCarryRequest.uid) == tostring(dropRecoveryRecordUid) and chsaeCarryRequest.carrySeen == true then
					flag3 = true
				end

				local num = tonumber(dropRecoveryRecord.CarrierUserId)
				local str = tostring(dropRecoveryRecord.State)
				local flag4 = (str == "Slot" or str == "Dropped") and dropRecoveryRecord.BottomCFrame ~= nil or num == localPlayer.UserId

				if tostring(tbl13.deathRecoveryUid) == tostring(dropRecoveryRecordUid) then
					if flag4 then
						tbl13.deathRecoveryMissingAt = 0
						tbl13.deathRecoveryMissingReason = ""
					else
						local flag5 = str ~= "Claimed"

						if flag5 then
							flag5 = not (num ~= nil and num > 0 and num ~= localPlayer.UserId)
						end

						if flag5 then
							flag5 = (tonumber(tbl13.deathRecoveryMissingAt) or 0) <= 0
						end

						if flag5 then
							tbl13.deathRecoveryMissingAt = os.clock()
							tbl13.deathRecoveryMissingReason = "record-transitioning"
						end
					end
				end

				if flag2 and flag3 and tostring(dropRecoveryRecord.State) == "Dropped" and dropRecoveryRecord.BottomCFrame then
					tbl13.dropRecoveryRecord = dropRecoveryRecord
					tbl13.dropRecoveryRecordUid = dropRecoveryRecordUid
					tbl13.dropRecoveryRecordAt = os.clock()
					local flag5 = tostring(tbl13.lastDroppedUid) ~= tostring(dropRecoveryRecordUid)

					if not flag5 then
						flag5 = (tonumber(tbl13.dropDetectedAt) or 0) <= 0
					end

					if flag5 then
						tbl13.dropDetectedAt = os.clock()
					end

					tbl13.lastDroppedUid = dropRecoveryRecordUid
					tbl13.lockedUid = dropRecoveryRecordUid
					tbl13.requestFailureUid = dropRecoveryRecordUid
					tbl13.requestFailureAt = tbl13.dropDetectedAt
					tbl13.lastRequestKind = tostring(tbl13.deathRecoveryUid) == tostring(dropRecoveryRecordUid) and "death-drop-sync" or "carry-loss-sync"
					tbl13.lastRequestError = "field egg shifted to dropped"
					handlers.pendingDroppedUid = dropRecoveryRecordUid
					critical = false
					tbl13.carriedUid = nil
					handlers.activeGuardAreaId = nil

					if type(chsaeCarryRequest) == "table" and tostring(chsaeCarryRequest.uid) == tostring(dropRecoveryRecordUid) then
						chsaeCarryRequest.carrySeen = true
						chsaeCarryRequest.carryActive = false
						chsaeCarryRequest.carryEndedSeen = true
						chsaeCarryRequest.droppedSeen = true
					end

					if type(handlers.armDroppedEggReacquire) == "function" then
						task.defer(handlers.armDroppedEggReacquire, dropRecoveryRecordUid, "field egg shifted to dropped", dropRecoveryRecord)
					end

					if fn12 then
						fn12("field-egg-dropped")
					end

					handlers.wakeOverlay("field-egg-dropped")
				elseif flag2 and tostring(tbl13.dropRecoveryRecordUid) == tostring(dropRecoveryRecordUid) then
					tbl13.dropRecoveryRecord = nil
					tbl13.dropRecoveryRecordUid = nil
					tbl13.dropRecoveryRecordAt = 0
				end
			end)
		end

		if tbl11.AreaEggRecordRemoved then
			fn17(tbl11.AreaEggRecordRemoved, function(arg)
				if not fn() then
					return
				end
				local uid

				if type(arg) == "table" then
					uid = arg.Uid or arg.UID or arg.EggUid
				else
					uid = arg
				end

				if uid == nil then
					return
				end

				if type(handlers.queueCandidateIndexRebuild) == "function" then
					handlers.queueCandidateIndexRebuild("field-gone")
				end

				if tostring(uid) == tostring(tbl13.lastDroppedUid) or tostring(uid) == tostring(tbl13.deathRecoveryUid) then
					local v10 = tbl13.recentPositiveCarryUid()

					if tostring(tbl13.deathRecoveryUid) == tostring(uid) or tostring(v10) == tostring(uid) then
						tbl13.lockedUid = uid

						if (tonumber(tbl13.deathRecoveryMissingAt) or 0) <= 0 then
							tbl13.deathRecoveryMissingAt = os.clock()
						end

						tbl13.deathRecoveryMissingReason = "field-gone"
						handlers.pendingDroppedUid = uid
					else
						if type(handlers.clearCarryLossRecovery) == "function" then
							handlers.clearCarryLossRecovery(uid)
						end

						if tostring(tbl13.lockedUid) == tostring(uid) then
							tbl13.lockedUid = nil
						end

						if tostring(tbl13.persistentUid) == tostring(uid) then
							tbl13.persistentUid = nil
						end
					end
				end

				if fn12 then
					fn12("field-egg-gone")
				end
			end)
		end

		fn17(tbl11.AreaEggClaimed, function(arg)
			if not fn() then
				return
			end

			if handlers.StealClaim then
				local v10, v11 = handlers.StealClaim:observeClaim(arg)
				if v10 == false then
					return
				end

				if v10 then
					arg = table.clone(arg)
					arg.Uid = v11
				end
			end

			local carriedUid = critical and tbl13.carriedUid or nil
			local chsaeCarryRequest = getgenv().__CHSAE_CarryRequest
			local uid = type(chsaeCarryRequest) == "table" and chsaeCarryRequest.carrySeen == true and chsaeCarryRequest.uid or nil
			critical = false
			tbl13.carriedUid = nil
			handlers.activeGuardAreaId = nil
			tbl13.attemptUid = nil
			tbl13.claimSequence = tbl13.claimSequence + 1
			handlers.steals = (handlers.steals or 0) + 1
			local assetCategory = type(arg) == "table" and arg.AssetCategory or nil
			local riftClaimHandoffUid = type(arg) == "table"

			if riftClaimHandoffUid then
				riftClaimHandoffUid = arg.Uid or arg.UID or arg.EggUid
			end

			riftClaimHandoffUid = riftClaimHandoffUid or nil or carriedUid or uid

			if type(chsaeCarryRequest) == "table" and riftClaimHandoffUid ~= nil and tostring(chsaeCarryRequest.uid) == tostring(riftClaimHandoffUid) then
				chsaeCarryRequest.carryActive = false
				chsaeCarryRequest.claimSeen = true
			end

			local deathRecoveryUid = tbl13.deathRecoveryUid or tbl13.lastDroppedUid
			local flag2 = riftClaimHandoffUid == nil and deathRecoveryUid == nil

			if flag2 or tostring(tbl13.lastPositiveCarryUid) == tostring(riftClaimHandoffUid) then
				tbl13.clearPositiveCarryEvidence(riftClaimHandoffUid)
			end

			if flag2 or tostring(handlers.pendingDroppedUid) == tostring(riftClaimHandoffUid) then
				handlers.pendingDroppedUid = nil
			end

			local webhookTarget = tbl13.webhookTarget
			local category = assetCategory or type(webhookTarget) == "table" and webhookTarget.category
			local uid2

			if riftClaimHandoffUid then
				uid2 = riftClaimHandoffUid
			else
				uid2 = type(webhookTarget) == "table" and webhookTarget.uid
			end

			uid2 = uid2 or tbl13.lockedUid

			if type(webhookTarget) == "table" and webhookTarget.source == "rift" and riftClaimHandoffUid ~= nil and webhookTarget.uid ~= nil and tostring(riftClaimHandoffUid) == tostring(webhookTarget.uid) then
				handlers.riftClaimHandoffUid = riftClaimHandoffUid
				handlers.riftClaimHandoffAt = os.clock()
				handlers.labReservedEggs[tostring(riftClaimHandoffUid)] = true
				handlers.riftEggHandoffs[tostring(riftClaimHandoffUid)] = { category = webhookTarget.category, at = os.clock() }
				local chsaeRiftWake = getgenv().__CHSAE_RiftWake

				if chsaeRiftWake then
					task.defer(function()
						if fn() then
							pcall(function()
								chsaeRiftWake:Fire("field-claim-handoff")
							end)
						end
					end)
				end
			end

			if type(webhookTarget) == "table" and webhookTarget.source == "pet-index" and riftClaimHandoffUid ~= nil and tostring(riftClaimHandoffUid) == tostring(webhookTarget.uid) and handlers.PetIndex then
				local petIndex = handlers.PetIndex
				petIndex.eggs[tostring(riftClaimHandoffUid)] = true
				petIndex.handoffs[tostring(riftClaimHandoffUid)] = { category = webhookTarget.category, at = os.clock() }
				petIndex.target = nil
				petIndex.nextAt = 0

				if handlers.wakeRiftPen then
					handlers.wakeRiftPen("index-claim")
				end
			end

			local flag3 = tbl2.AutoUnlockGreatBloom == true and handlers.greatBloomUnlockStealWanted == true

			if flag3 then
				flag3 = tostring(category or "") == "Crane"
			end

			if flag3 then
				handlers.greatBloomUnlockStealWanted = false
				handlers.greatBloomUnlockClaimedAt = os.clock()
				handlers.greatBloomUnlockClaimedEggUid = uid2
				handlers.greatBloomUnlock.reservedEggUid = uid2

				if fn12 then
					fn12("crane-claim-sync")
				end

				if type(handlers.wakeGreatBloomUnlock) == "function" then
					task.defer(handlers.wakeGreatBloomUnlock, "crane-claimed")
				end
			end

			if flag2 or tostring(tbl13.lastDroppedUid) == tostring(riftClaimHandoffUid) then
				tbl13.lastDroppedUid = nil
				tbl13.dropDetectedAt = 0
				tbl13.clearSyncFailure()
			end

			if flag2 or tostring(tbl13.deathRecoveryUid) == tostring(riftClaimHandoffUid) then
				tbl13.deathRecoveryUid = nil
				tbl13.deathRecoveryAt = 0
				tbl13.deathRecoveryMissingAt = 0
				tbl13.deathRecoveryMissingReason = ""
			end

			if flag2 or tostring(tbl13.dropRecoveryRecordUid) == tostring(riftClaimHandoffUid) then
				tbl13.dropRecoveryRecord = nil
				tbl13.dropRecoveryRecordUid = nil
				tbl13.dropRecoveryRecordAt = 0
			end

			tbl13.lastClaim = {
				Sequence = tbl13.claimSequence,
				AssetCategory = assetCategory,
				Uid = riftClaimHandoffUid,
				Scoped = not (riftClaimHandoffUid == nil and deathRecoveryUid ~= nil),
				At = os.clock(),
			}

			if riftClaimHandoffUid ~= nil then
				if tostring(tbl13.lockedUid) == tostring(riftClaimHandoffUid) then
					tbl13.lockedUid = nil
				end

				if tostring(tbl13.persistentUid) == tostring(riftClaimHandoffUid) then
					tbl13.persistentUid = nil
				end

				local candidateIndex = handlers.candidateIndex

				if candidateIndex and type(candidateIndex.Invalidate) == "function" then
					candidateIndex:Invalidate(riftClaimHandoffUid, "local claim verified")
				end
			end

			handlers.carry = "📦 Carry: delivery verified"

			if type(handlers.sendWebhook) == "function" then
				local webhookTarget2 = tbl13.webhookTarget

				if webhookTarget2 and riftClaimHandoffUid and webhookTarget2.uid and tostring(webhookTarget2.uid) ~= tostring(riftClaimHandoffUid) then
					webhookTarget2 = nil
				end

				if webhookTarget2 and assetCategory and webhookTarget2.category and tostring(webhookTarget2.category) ~= tostring(assetCategory) then
					webhookTarget2 = nil
				end

				local flag4 = webhookTarget2 and webhookTarget2.source == "steal-filter"
				tbl13.webhookTarget = nil

				if flag4 then
					task.spawn(handlers.sendWebhook, "steal", "Egg Claimed", webhookTarget2, 4843141, false)
				end
			end
		end)
	end)
end

local fn24

fn24 = function()
	local v10 = nil

	pcall(function()
		v10 = tbl11 and tbl11.GetAreaEggSnapshot()
	end)

	local records = v10 and (v10.Records or v10)
	if type(records) == "table" then
		return records
	end
	local candidateIndex = handlers.candidateIndex
	return candidateIndex and type(candidateIndex.records) == "table" and candidateIndex.records or {}
end

local fn25

fn25 = function(arg)
	if arg == nil then
		return nil
	end

	if tbl11 and type(tbl11.GetAreaEggRecord) == "function" then
		local ok, result = pcall(tbl11.GetAreaEggRecord, tostring(arg))
		if ok then
			return result
		end
		return nil, tostring(result):sub(1, 180)
	end

	for _, v10 in pairs(fn24()) do
		if tostring(v10.Uid or v10.UID or v10.EggUid) == tostring(arg) then
			return v10
		end
	end

	return nil
end

handlers.carryLossAwaitingProof = function(arg)
	if arg == nil or tostring(handlers.pendingDroppedUid) ~= tostring(arg) then
		return false
	end
	local chsaeCarryRequest = getgenv().__CHSAE_CarryRequest
	local flag2 = type(chsaeCarryRequest) ~= "table" or tostring(chsaeCarryRequest.uid) ~= tostring(arg) or chsaeCarryRequest.carryEndedSeen == true
	local flag3

	if flag2 then
		flag3 = flag2
	else
		flag3 = (tonumber(chsaeCarryRequest.started) or 0) <= (tonumber(tbl13.dropDetectedAt) or 0)
	end

	return flag3
end

local fn26

fn26 = function()
	for _, v10 in pairs(fn24()) do
		local str = tostring(v10.State or "")
		local flag2 = str ~= "Dropped" and str ~= "GuardCarried" and str ~= "Claimed"

		if flag2 then
			local userId = localPlayer.UserId
			flag2 = tonumber(v10.CarrierUserId) == userId
		end

		if flag2 and not handlers.carryLossAwaitingProof(v10.Uid) then
			return v10
		end
	end

	return nil
end

local fn27

fn27 = function(lastDroppedUid)
	local chsaeCarryRequest = getgenv().__CHSAE_CarryRequest
	local flag2 = type(chsaeCarryRequest) == "table" and tostring(chsaeCarryRequest.uid) == tostring(lastDroppedUid)
	local v10 = fn25(lastDroppedUid)

	if v10 ~= nil then
		local str = tostring(v10.State or "")
		local num = tonumber(v10.CarrierUserId)

		if str == "Dropped" or str == "GuardCarried" or str == "Claimed" then
			if str ~= "Claimed" and (tostring(tbl13.carriedUid) == tostring(lastDroppedUid) or flag2 and chsaeCarryRequest.carrySeen == true) and tostring(handlers.pendingDroppedUid) ~= tostring(lastDroppedUid) then
				tbl13.lastDroppedUid = lastDroppedUid
				tbl13.dropDetectedAt = os.clock()
				tbl13.lockedUid = lastDroppedUid
				tbl13.lastRequestKind = "carry-loss-sync"
				tbl13.lastRequestError = "guard carry loss; waiting to reclaim egg"
				handlers.pendingDroppedUid = lastDroppedUid
			end

			if tostring(tbl13.carriedUid) == tostring(lastDroppedUid) then
				critical = false
			end

			if flag2 then
				chsaeCarryRequest.carryActive = false

				if str == "Dropped" or str == "GuardCarried" then
					chsaeCarryRequest.carryEndedSeen = true
					chsaeCarryRequest.droppedSeen = true
				end
			end

			return false
		end

		if num == localPlayer.UserId then
			if handlers.carryLossAwaitingProof(lastDroppedUid) then
				return false
			end
			critical = true
			tbl13.carriedUid = lastDroppedUid
		elseif num ~= nil then
			if num > 0 and tostring(tbl13.carriedUid) == tostring(lastDroppedUid) then
				critical = false
			end

			if flag2 then
				chsaeCarryRequest.carryActive = false
			end

			return false
		end
	end

	if critical and tbl13.carriedUid ~= nil and tostring(tbl13.carriedUid) == tostring(lastDroppedUid) and not handlers.carryLossAwaitingProof(lastDroppedUid) then
		tbl13.rememberPositiveCarry(lastDroppedUid)

		if flag2 then
			chsaeCarryRequest.carrySeen = true
			chsaeCarryRequest.carryActive = true
			chsaeCarryRequest.carryEndedSeen = false
			chsaeCarryRequest.droppedSeen = false
		end

		return true
	end

	if flag2 then
		chsaeCarryRequest.carryActive = false
	end

	return false
end

local fn28

fn28 = function(arg)
	local v10 = arg and fn25(arg)
	return v10 ~= nil and tostring(v10.State) == "Dropped"
end

handlers.getDroppedRecoveryRecord = function(arg)
	local lastDroppedUid = arg or tbl13.lastDroppedUid or tbl13.deathRecoveryUid
	local lockedUid

	if lastDroppedUid then
		lockedUid = lastDroppedUid
	else
		lockedUid = tostring(tbl13.lastRequestKind) == "carry-drop" and tbl13.lockedUid or nil
	end

	if lockedUid == nil then
		return nil
	end

	if not (tostring(tbl13.lastDroppedUid) == tostring(lockedUid) or tostring(tbl13.deathRecoveryUid) == tostring(lockedUid) or tostring(tbl13.lastRequestKind) == "carry-drop" and tostring(tbl13.lockedUid) == tostring(lockedUid)) then
		return nil
	end
	local v10 = fn25(lockedUid)

	if v10 and tostring(v10.State) == "Dropped" and v10.BottomCFrame then
		tbl13.dropRecoveryRecord = v10
		tbl13.dropRecoveryRecordUid = lockedUid
		tbl13.dropRecoveryRecordAt = os.clock()
		return v10
	end

	local dropRecoveryRecord = tbl13.dropRecoveryRecord
	local n2 = os.clock() - (tonumber(tbl13.dropRecoveryRecordAt) or 0)
	if type(dropRecoveryRecord) == "table" and dropRecoveryRecord.Uid ~= nil and tostring(tbl13.dropRecoveryRecordUid) == tostring(lockedUid) and tostring(dropRecoveryRecord.State) == "Dropped" and dropRecoveryRecord.BottomCFrame and n2 <= 2.5 then
		return dropRecoveryRecord
	end
	return nil
end

handlers.clearCarryLossRecovery = function(arg, arg2)
	if arg == nil then
		return
	end
	local flag2 = tostring(tbl13.lastDroppedUid) == tostring(arg)
	local flag3 = tostring(tbl13.deathRecoveryUid) == tostring(arg)

	if flag2 then
		tbl13.lastDroppedUid = nil
		tbl13.dropDetectedAt = 0
	end

	if flag3 then
		tbl13.deathRecoveryUid = nil
		tbl13.deathRecoveryAt = 0
	end

	if flag2 or flag3 then
		tbl13.deathRecoveryMissingAt = 0
		tbl13.deathRecoveryMissingReason = ""
	end

	if tostring(tbl13.dropRecoveryRecordUid) == tostring(arg) then
		tbl13.dropRecoveryRecord = nil
		tbl13.dropRecoveryRecordUid = nil
		tbl13.dropRecoveryRecordAt = 0
	end

	if tostring(handlers.pendingDroppedUid) == tostring(arg) then
		handlers.pendingDroppedUid = nil
	end

	if arg2 ~= true then
		tbl13.clearPositiveCarryEvidence(arg)
	end

	if flag2 or flag3 then
		tbl13.clearSyncFailure()
	end
end

local fn29

fn29 = function(arg, arg2, arg3)
	local lastClaim = tbl13.lastClaim
	local flag2

	if lastClaim then
		flag2 = lastClaim.Sequence > (arg3 or -1)
	else
		flag2 = lastClaim
	end

	if flag2 and lastClaim.Scoped ~= false and lastClaim.Uid ~= nil and arg ~= nil and tostring(lastClaim.Uid) == tostring(arg) and (arg2 == nil or lastClaim.AssetCategory == nil or lastClaim.AssetCategory == arg2) then
		return true
	end
	return false
end

local tbl14

tbl14 = {
	owner = nil,
	prio = 0,
	heartbeat = 0,
	yieldTo = nil,
	stealWants = false,
	stealBeat = 0,
	critical = false,
	sellWake = Instance.new("BindableEvent"),
	petsBusy = false,
	sellerActive = false,
	placeBusy = false,
	remoteActivity = nil,
	treadmillTraining = false,
	hatchBusy = false,
	PRIO = {
		Steal = 140,
		ScrambleBoss = 120,
		AdminEvent = 110,
		Event = 100,
		Place = 50,
		Mutate = 40,
		Treadmill = 20,
	},
	STALE = 60,
	WANTS_STALE = 30,
}

local sellWake = tbl14.sellWake
getgenv().__CHSAE_SellWake = sellWake
tbl14.sellerGeneration = 0
tbl14.sellerPending = false

tbl14.cancelSellerTimer = function()
	tbl14.sellerGeneration = tbl14.sellerGeneration + 1
	local sellerTimer = tbl14.sellerTimer
	tbl14.sellerTimer = nil

	if sellerTimer then
		pcall(task.cancel, sellerTimer)
	end
end

tbl14.wakeSeller = function()
	if not fn() then
		return
	end
	tbl14.sellerPending = true
	if tbl14.sellerWakeQueued then
		return
	end
	tbl14.sellerWakeQueued = true

	task.defer(function()
		tbl14.sellerWakeQueued = false

		if fn() then
			tbl14.sellWake:Fire()
		end
	end)
end

tbl14.waitSeller = function(arg)
	tbl14.cancelSellerTimer()

	if tbl14.sellerPending then
		tbl14.sellerPending = false
		task.wait(0.1)
		return
	end

	local sellerGeneration = tbl14.sellerGeneration

	tbl14.sellerTimer = task.delay(arg, function()
		if sellerGeneration ~= tbl14.sellerGeneration or not fn() then
			return
		end
		tbl14.sellerTimer = nil
		tbl14.wakeSeller()
	end)

	tbl14.sellWake.Event:Wait()
	tbl14.cancelSellerTimer()
	tbl14.sellerPending = false
end

tbl.InventoryWake = function()
	if tbl14.inventoryWakeQueued or not fn() then
		return
	end
	tbl14.inventoryWakeQueued = true

	task.defer(function()
		tbl14.inventoryWakeQueued = false
		if not fn() then
			return
		end
		tbl14.wakeSeller()

		if handlers.wakeRiftPen then
			handlers.wakeRiftPen("inventory/config")
		end

		local chsaeRiftWake = getgenv().__CHSAE_RiftWake

		if chsaeRiftWake then
			chsaeRiftWake:Fire("inventory/config")
		end
	end)
end

local cancelSellerTimer = tbl14.cancelSellerTimer
getgenv().__CHSAE_SellCancel = cancelSellerTimer

tbl14.free = function()
	local owner = tbl14.owner

	if owner then
		local heartbeat = tbl14.heartbeat
		owner = os.clock() - heartbeat > tbl14.STALE
	end

	if owner then
		local v10 = tbl14
		local v11 = tbl14
		tbl14.owner = nil
		v10.prio = 0
		v11.yieldTo = nil
	end

	return tbl14.owner == nil
end

tbl14.stealBusy = function()
	if not tbl14.stealWants then
		return false
	end

	if tbl14.WANTS_STALE < os.clock() - (tbl14.stealBeat or 0) then
		tbl14.stealWants = false
		return false
	end
	return true
end

tbl14.protectedStealTransaction = function(arg)
	if arg ~= "AdminEvent" then
		return false
	end

	if type(handlers.carryLossRecoveryPending) == "function" and handlers.carryLossRecoveryPending() then
		return true
	end

	if tbl14.owner ~= "Steal" then
		return false
	end
	local chsaeCarryRequest = getgenv().__CHSAE_CarryRequest
	return tbl14.critical or tbl13.lockedUid ~= nil or critical or fn26() ~= nil or type(chsaeCarryRequest) == "table" and (chsaeCarryRequest.inFlight == true or chsaeCarryRequest.carrySeen == true)
end

tbl14.prioOf = function(arg)
	return tbl14.PRIO[arg] or 0
end

tbl14.canTake = function(arg)
	if arg == "Treadmill" and handlers.mutateBatchPending and handlers.mutateBatchPending() then
		return false
	end

	if arg == "Treadmill" and (tbl14.placeBusy or handlers.placeBatchPending and handlers.placeBatchPending()) then
		return false
	end
	local v10 = tbl14.prioOf(arg)
	if tbl14.protectedStealTransaction(arg) then
		return false
	end

	if v10 < tbl14.PRIO.Steal and tbl14.stealBusy() then
		return false
	end

	if tbl14.owner == arg and tbl14.yieldTo ~= nil and tbl14.prioOf(tbl14.yieldTo) > v10 then
		return false
	end
	return tbl14.free() or tbl14.owner == arg
end

tbl14.acquire = function(yieldTo)
	local v10 = tbl14.protectedStealTransaction(yieldTo)

	if not tbl14.canTake(yieldTo) then
		if not v10 and tbl14.owner and tbl14.owner ~= yieldTo and tbl14.prioOf(yieldTo) > tbl14.prioOf(tbl14.owner) then
			tbl14.yieldTo = yieldTo
		end

		return false
	end

	if handlers.prepareMovementOwner and not handlers.prepareMovementOwner(yieldTo) then
		return false
	end
	local flag2 = tbl14.owner ~= yieldTo
	local v11 = tbl14
	local v12 = tbl14
	local v13 = tbl14
	local v14 = tbl14.prioOf(yieldTo)
	local now3 = os.clock()
	v11.owner = yieldTo
	v12.prio = v14
	v13.heartbeat = now3
	tbl14.yieldTo = nil

	if flag2 then
		handlers.wakeOverlay("arbiter")
	end

	return true
end

tbl14.acquireWait = function(arg, arg2)
	local n2 = os.clock() + (arg2 or 3)

	while fn() do
		if tbl14.acquire(arg) then
			return true
		end

		if n2 <= os.clock() then
			return false
		end
		task.wait(0.1)
	end

	return false
end

tbl14.hold = function(arg)
	if tbl14.owner ~= arg then
		return false
	end
	tbl14.heartbeat = os.clock()
	return tbl14.yieldTo == nil
end

tbl14.release = function(arg)
	if tbl14.owner == arg then
		local v10 = tbl14
		local v11 = tbl14
		tbl14.owner = nil
		v10.prio = 0
		v11.yieldTo = nil
		handlers.wakeOverlay("arbiter")
		local chsaeRiftWake = getgenv().__CHSAE_RiftWake

		if arg ~= "AdminEvent" and chsaeRiftWake then
			chsaeRiftWake:Fire("body-released")
		end
	end
end

tbl14.quietOk = function()
	if tbl14.owner == "ScrambleBoss" then
		return false
	end

	if tbl14.critical or critical or tbl14.stealBusy() then
		return false
	end

	if handlers.greatBloomUnlockReturnPending == true then
		return false
	end

	if tbl14.owner == "Place" or tbl14.owner == "Event" or tbl14.owner == "AdminEvent" or tbl14.placeBusy then
		return false
	end
	return true
end

tbl14.backgroundOk = function()
	if tbl14.critical or critical then
		return false
	end

	if tbl14.owner == "Place" or tbl14.placeBusy then
		return false
	end
	return true
end

tbl14.hatchOk = function()
	if tbl14.hatchBusy or tbl14.placeBusy or tbl14.petsBusy or tbl14.owner == "Place" then
		return false
	end

	if type(handlers.reconcileNewPetUids) == "function" then
		pcall(handlers.reconcileNewPetUids)
	end

	return not tbl14.hatchBusy and not tbl14.placeBusy and not tbl14.petsBusy and handlers.hatchPetOutputPending ~= true and handlers.petUidBaselineReady == true and tbl14.owner ~= "Place"
end

tbl14.sellOk = function()
	if os.clock() < (handlers.sellerResumeAt or 0) then
		return false
	end

	if tbl14.critical or critical or tbl14.placeBusy or tbl14.hatchBusy then
		return false
	end

	if type(handlers.hatchPetSaleGuardActive) == "function" and handlers.hatchPetSaleGuardActive() then
		return false
	end

	if handlers.greatBloomUnlockReturnPending == true then
		return false
	end

	if tbl14.owner == "Treadmill" then
		return false
	end

	if tbl14.owner == "Steal" or tbl14.stealBusy() then
		return false
	end

	if handlers.riftCollecting == true or handlers.riftWantsBody == true or handlers.riftPlacementWanted == true then
		return false
	end

	if handlers.normalStealPending() then
		return false
	end

	if tbl14.owner == "Event" or tbl14.owner == "AdminEvent" or tbl14.owner == "Place" or tbl14.owner == "ScrambleBoss" then
		return false
	end
	return true
end

tbl14.petsSerial = function(arg, remoteActivity)
	if tbl14.petsBusy or tbl14.hatchBusy or handlers.hatchPetOutputPending == true or not tbl14.quietOk() then
		return false
	end
	tbl14.petsBusy = true
	tbl14.remoteActivity = remoteActivity or "Managing inventory"
	tbl14.remoteOnlyActive = true
	local ok, result = pcall(arg)
	local v10 = tbl14
	tbl14.petsBusy = false
	v10.remoteOnlyActive = false
	tbl14.remoteActivity = nil

	if not ok then
		warn("[CloverHub] pets task error: " .. tostring(result))
	end

	return true
end

tbl14.sellSerial = function(arg, remoteActivity)
	if tbl14.petsBusy or not tbl14.sellOk() then
		return false
	end
	tbl14.petsBusy = true
	tbl14.remoteActivity = remoteActivity or "Selling inventory"
	tbl14.sellerActive = true
	handlers.sellerUsedTool = false
	local v10 = table.pack(pcall(arg))

	if type(handlers.stopHoldingSellerTool) == "function" then
		pcall(handlers.stopHoldingSellerTool)
	end

	local v11 = tbl14
	tbl14.petsBusy = false
	v11.sellerActive = false
	tbl14.remoteActivity = nil

	if handlers.sellerUsedTool and tbl2.AutoTreadmill and not tbl14.treadmillTraining then
		handlers.sellerResumeAt = os.clock() + 0.75
	end

	handlers.sellerUsedTool = nil
	if not v10[1] then
		warn("[CloverHub] sell task error: " .. tostring(v10[2]))
		return true
	end
	return true, table.unpack(v10, 2, v10.n)
end

tbl14.inventoryBlocksSteal = function()
	if handlers.sellerEggUid ~= nil or handlers.sellerPetUid ~= nil or handlers.sellerHeldTool ~= nil then
		return true
	end
	return tbl14.petsBusy and not tbl14.sellerActive and not tbl14.remoteOnlyActive and type(getgenv().__CHSAE_RiftTransaction) ~= "table"
end

tbl14.waitPets = function(arg, arg2)
	local n2 = os.clock() + (arg2 or 4)

	if tbl14.inventoryBlocksSteal() then
		fn11("⏳ Finishing inventory handoff")
	end

	while tbl14.inventoryBlocksSteal() and fn() and arg() do
		if not tbl14.hold("Steal") or os.clock() >= n2 then
			return false
		end
		RunService.Heartbeat:Wait()
	end

	return fn() and arg() and tbl14.hold("Steal") and not tbl14.inventoryBlocksSteal()
end

tbl14.status = function()
	if tbl14.owner == "Steal" then
		if tbl14.petsBusy and string.find(tostring(tbl14.remoteActivity), "Selling", 1, true) then
			return "🥷 Stealing · 💰 " .. tostring(tbl14.remoteActivity)
		end
		return critical and "🥷 Stealing (carrying)" or "🥷 Stealing"
	end

	if tbl14.owner == "AdminEvent" then
		return "🧪 Lab trade"
	end

	if tbl14.owner == "ScrambleBoss" then
		return "⚔️ " .. tostring(handlers.ScrambleBoss and handlers.ScrambleBoss.status or "Scramble Boss")
	end

	if tbl14.owner == "Event" then
		return handlers.greatBloomUnlockReturnPending == true and "🔓 Returning Crane" or "🌸 Farming Great Bloom"
	end

	if tbl14.owner == "Place" then
		return "🥚 Placing eggs"
	end

	if tbl14.owner == "Mutate" then
		return "🧬 Mutating eggs"
	end

	if tbl14.owner == "Treadmill" then
		return "🏃 Entering treadmill"
	end

	if tbl14.stealBusy() then
		return "🥷 Steal armed"
	end

	if tbl14.treadmillTraining and tbl14.hatchBusy then
		return "🏃 Training · 🥚 Hatching"
	end

	if tbl14.hatchBusy then
		return "🥚 Hatching eggs"
	end

	if tbl14.treadmillTraining and tbl14.petsBusy then
		return "🏃 Training · 📦 " .. tostring(tbl14.remoteActivity or "Managing inventory")
	end

	if tbl14.petsBusy then
		return "📦 " .. tostring(tbl14.remoteActivity or "Managing inventory")
	end

	if handlers.riftActive and tbl2.AutoLab then
		return "🧪 Lab active"
	end

	if tbl14.treadmillTraining then
		return "🏃 Training on treadmill"
	end

	if AutoStealToggle and AutoStealToggle.Value == true or tbl2.AutoSteal then
		return "🎯 Waiting for target"
	end
	local autoPlace = tbl2.AutoPlace

	if not autoPlace then
		autoPlace = tbl2.PlaceAfterIncubation and type(handlers.getIncubatedPlaceCount) == "function" and handlers.getIncubatedPlaceCount() > 0
	end

	if autoPlace then
		return tbl2.PlaceInRangeOnly and "🥚 Waiting for pen range" or "🥚 Auto-Place standby"
	end

	if tbl2.AutoTreadmill then
		return "🏃 Treadmill standby"
	end
	return "💤 Idle"
end

local fn30

fn30 = function(arg)
	local ok, result = pcall(function()
		local itemData = type(arg.ItemData) == "table" and arg.ItemData or arg
		return Assets.Directory[itemData.AssetCategory or itemData.Category or arg.AssetCategory or arg.Category].Rarity
	end)

	if ok and type(result) == "table" then
		return result
	end
	return nil
end

do
	local candidateIndex = {
		version = 0,
		signature = nil,
		records = {},
		entries = {},
		byUid = {},
		sorted = {},
		rejected = {},
		lastRebuildAt = 0,
	}

	local flag2 = false
	local flag3 = nil

	handlers.queueCandidateIndexRebuild = function(arg)
		flag3 = type(arg) == "table" and arg or nil
		if flag2 then
			return
		end
		flag2 = true

		task.delay(0.1, function()
			flag2 = false
			local v10 = flag3
			flag3 = nil
			if not fn() then
				return
			end
			local now3 = os.clock()
			local ok, result = pcall(candidateIndex.Rebuild, candidateIndex, v10)
			handlers.candidateRebuildMs = (os.clock() - now3) * 1000
			handlers.candidateRebuildMaxMs = math.max(handlers.candidateRebuildMaxMs or 0, handlers.candidateRebuildMs)

			if not ok then
				warn("[CloverHub-SAE] Candidate rebuild failed: " .. tostring(result))
			elseif result then
				fn12("candidate-rebuilt")
			end
		end)
	end

	local function fn31(arg)
		local v10 = table.create(#arg)

		for i, v11 in ipairs(arg) do
			v10[i] = v11
		end

		return v10
	end

	local function fn32(arg)
		return tostring(arg.uid or "")
	end

	candidateIndex.Rebuild = function(arg, arg2)
		local flag4 = type(arg2) ~= "table"
		local flag5

		if flag4 then
			flag5 = flag4
		else
			flag5 = type(arg2.Records or arg2) ~= "table"
		end

		if flag5 then
			local ok
			ok, arg2 = pcall(tbl11.GetAreaEggSnapshot)
			if not ok or type(arg2) ~= "table" then
				return false
			end
		end

		local records = arg2.Records or arg2
		local tbl15 = {}
		local records2 = {}

		for _, record in pairs(records) do
			if type(record) == "table" then
				local str = tostring(record.Uid or "")
				local v10 = arg.rejected[str]

				if v10 and tostring(record.State) ~= "Slot" then
					arg.rejected[str] = nil
					v10 = nil
				end

				if not v10 then
					records2[#records2 + 1] = record
				end

				local position = record.BottomCFrame and record.BottomCFrame.Position
				local v11 = fn22(record)
				table.sort(v11)
				local n2 = #tbl15 + 1
				local concat = table.concat
				local tbl16 = {}
				local str2 = tostring(record.Uid or "")
				local str3 = tostring(record.State or "")
				local str4 = tostring(record.CarrierUserId or "")
				local str5 = tostring(record.AssetCategory or "")
				local str6 = tostring(record.AreaId or "")
				local str7 = tostring(record.AssetScale or "")
				local str8 = tostring(record.BaseMutation or "")
				position = position and ("%.2f,%.2f,%.2f"):format(position.X, position.Y, position.Z) or ""
				local v12 = table.pack(table.concat(v11, ","))
				tbl16[1] = str2
				tbl16[2] = str3
				tbl16[3] = str4
				tbl16[4] = str5
				tbl16[5] = str6
				tbl16[6] = str7
				tbl16[7] = str8
				tbl16[8] = position

				do
					local values = table.pack(table.unpack(v12, 1, v12.n))
					table.move(values, 1, values.n, 9, tbl16)
				end

				tbl15[n2] = concat(tbl16, "\0")
			end
		end

		table.sort(tbl15)
		local signature = table.concat(tbl15, "\1")
		if signature == arg.signature then
			return false
		end
		local entries = {}
		local byUid = {}

		for _, v10 in ipairs(records2) do
			local rarityNumber = fn30(v10)
			local v11 = fn22(v10)
			local position = v10.BottomCFrame and v10.BottomCFrame.Position or nil
			local v12 = fn23(v10)
			local v13, v14 = riftValueScore(v10)

			local tbl16 = {
				rec = v10,
				uid = tostring(v10.Uid or ""),
				state = tostring(v10.State or ""),
				rarity = rarityNumber,
				rarityId = rarityNumber and tostring(rarityNumber._id) or "Unknown",
			}

			if rarityNumber then
				rarityNumber = tonumber(rarityNumber.RarityNumber or rarityNumber.Rank) or 0
			end

			tbl16.rarityNumber = rarityNumber or 0
			tbl16.mutations = v11
			tbl16.mutationCount = #v11
			tbl16.value = v13
			tbl16.valueKnown = v14
			tbl16.weight = v12 or 0
			tbl16.weightKnown = v12 ~= nil
			tbl16.position = position
			tbl16.area = tostring(v10.AreaId or "")
			tbl16.category = tostring(v10.AssetCategory or "")
			entries[#entries + 1] = tbl16

			if tbl16.uid ~= "" then
				byUid[tbl16.uid] = tbl16
			end
		end

		arg.signature = signature
		arg.records = records2
		arg.entries = entries
		arg.byUid = byUid
		arg.sorted = {}
		arg.version = arg.version + 1
		arg.lastRebuildAt = os.clock()

		if type(handlers.refreshEggESP) == "function" then
			handlers.refreshEggESP()
		end

		return true
	end

	local tbl15 = {
		Value = function(arg, arg2)
			if arg.value ~= arg2.value then
				return arg.value > arg2.value
			end

			if arg.rarityNumber ~= arg2.rarityNumber then
				return arg.rarityNumber > arg2.rarityNumber
			end
			return fn32(arg) < fn32(arg2)
		end,
		Rarity = function(arg, arg2)
			if arg.rarityNumber ~= arg2.rarityNumber then
				return arg.rarityNumber > arg2.rarityNumber
			end

			if arg.value ~= arg2.value then
				return arg.value > arg2.value
			end
			return fn32(arg) < fn32(arg2)
		end,
		Mutation = function(arg, arg2)
			if arg.mutationCount ~= arg2.mutationCount then
				return arg.mutationCount > arg2.mutationCount
			end

			if arg.value ~= arg2.value then
				return arg.value > arg2.value
			end

			if arg.rarityNumber ~= arg2.rarityNumber then
				return arg.rarityNumber > arg2.rarityNumber
			end
			return fn32(arg) < fn32(arg2)
		end,
		Weight = function(arg, arg2)
			if arg.weight ~= arg2.weight then
				return arg.weight > arg2.weight
			end

			if arg.rarityNumber ~= arg2.rarityNumber then
				return arg.rarityNumber > arg2.rarityNumber
			end

			if arg.value ~= arg2.value then
				return arg.value > arg2.value
			end
			return fn32(arg) < fn32(arg2)
		end,
	}

	candidateIndex.GetEntries = function(arg, arg2)
		if tbl15[arg2] and not arg.sorted[arg2] then
			local v10 = fn31(arg.entries)
			table.sort(v10, tbl15[arg2])
			arg.sorted[arg2] = v10
		end

		return arg.sorted[arg2] or arg.entries
	end

	candidateIndex.Invalidate = function(arg, arg2, arg3)
		local str = tostring(arg2 or "")
		if str == "" or not arg.byUid[str] then
			return false
		end

		local function fn33(arg4, arg5)
			local tbl16 = {}
			local v10 = ipairs
			arg4 = arg4 or {}

			for _, v11 in v10(arg4) do
				local str2

				if arg5 then
					str2 = tostring(v11.Uid or "")
				else
					str2 = arg5
				end

				if not str2 then
					str2 = tostring(v11.uid or "")
				end

				if str2 ~= str then
					tbl16[#tbl16 + 1] = v11
				end
			end

			return tbl16
		end

		arg.records = fn33(arg.records, true)
		arg.entries = fn33(arg.entries, false)

		for k, v10 in pairs(arg.sorted) do
			arg.sorted[k] = fn33(v10, false)
		end

		arg.byUid[str] = nil
		arg.rejected[str] = { reason = tostring(arg3 or "unavailable"), at = os.clock() }
		arg.version = arg.version + 1
		arg.lastInvalidation = { uid = str, reason = tostring(arg3 or "unavailable"), at = os.clock() }

		if type(handlers.refreshEggESP) == "function" then
			handlers.refreshEggESP()
		end

		fn12("candidate-invalidated")
		return true
	end

	handlers.candidateIndex = candidateIndex
end

handlers.queueCandidateIndexRebuild()

local function fn31()
	local tbl15 = {
		areaEnabled = false,
		penEnabled = false,
		queued = false,
		folder = nil,
		anchor = nil,
		markers = {},
		count = 0,
		PlotCmds = nil,
		trackConnection = function(arg)
			if typeof(arg) ~= "RBXScriptConnection" then
				return
			end
			local chsaeRuntimeConns = getgenv().__CHSAE_RuntimeConns

			if type(chsaeRuntimeConns) == "table" then
				chsaeRuntimeConns[#chsaeRuntimeConns + 1] = arg
			else
				pcall(function()
					arg:Disconnect()
				end)
			end
		end,
	}

	pcall(function()
		local PlotState = require(ReplicatedStorage.Client.PlotState)
		tbl15.PlotCmds = { GetPlotData = PlotState.ResolvePlot, OnAnyPlotUpdated = PlotState.PlotChanged }
	end)

	local function fn32(arg)
		return tostring(arg or ""):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("\"", "&quot;")
	end

	local function fn33()
		local folder = tbl15.folder
		local v10 = tbl15
		local v11 = tbl15
		local v12 = tbl15
		tbl15.folder = nil
		v10.anchor = nil
		v11.markers = {}
		v12.count = 0

		if folder then
			pcall(function()
				folder:Destroy()
			end)
		end

		if getgenv().__CHSAE_EggESPFolder == folder then
			getgenv().__CHSAE_EggESPFolder = nil
		end
	end

	local function createPart()
		if tbl15.anchor and tbl15.anchor.Parent then
			return tbl15.anchor
		end
		fn33()
		local chsaeEggESP = workspace:FindFirstChild("__CHSAE_EggESP")

		if chsaeEggESP then
			pcall(function()
				chsaeEggESP:Destroy()
			end)
		end

		local folder = Instance.new("Folder")
		folder.Name = "__CHSAE_EggESP"
		local part = Instance.new("Part")
		part.Name = "Anchor"
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.CastShadow = false
		part.Transparency = 1
		part.Size = Vector3.new(0.05, 0.05, 0.05)
		part.CFrame = CFrame.new()
		part.Parent = folder
		folder.Parent = workspace
		local v10 = tbl15
		tbl15.folder = folder
		v10.anchor = part
		getgenv().__CHSAE_EggESPFolder = folder
		return part
	end

	local function fn34()
		return tbl15.areaEnabled or tbl15.penEnabled
	end

	local function fn35(arg)
		local tbl16 = {}
		local tbl17 = {}

		local function fn36(arg2)
			local str = tostring(arg2 or "")
			if str == "" or str == "None" or tbl17[str] or #tbl16 >= 2 then
				return
			end
			tbl17[str] = true
			local v10 = str

			if tbl12 and type(tbl12.GetDisplayName) == "function" then
				pcall(function()
					v10 = tbl12.GetDisplayName(str) or str
				end)
			end

			tbl16[#tbl16 + 1] = fn32(v10)
		end

		fn36(arg and arg.BaseMutation)
		local v10 = ipairs
		local mutations = arg and arg.Mutations or {}

		for _, mutation in v10(mutations) do
			fn36(mutation)
		end

		return #tbl16 > 0 and " · " .. table.concat(tbl16, "+") or ""
	end

	local function fn36(arg)
		if type(arg) ~= "table" then
			return nil
		end
		local itemData = type(arg.ItemData) == "table" and arg.ItemData or arg
		if type(itemData.Category) == "string" and type(itemData.Scale) == "number" and type(itemData.Mutations) == "table" then
			return itemData
		end
		local eggRecords = tbl11 and tbl11.EggRecords

		if eggRecords and type(eggRecords.ToAssetItemData) == "function" then
			local ok, result = pcall(eggRecords.ToAssetItemData, arg)
			if ok and type(result) == "table" then
				return result
			end
		end

		return nil
	end

	local function fn37(arg)
		local v10 = fn36(arg)
		local assetItems = tbl11 and tbl11.AssetItems

		if v10 and assetItems and type(assetItems.WeightKg) == "function" then
			local ok, result = pcall(assetItems.WeightKg, v10)
			if ok and type(result) == "number" then
				return result
			end
		end

		return fn23(arg)
	end

	local function fn38(arg)
		local v10 = fn36(arg)
		local assetEarnings = tbl11 and tbl11.AssetEarnings
		if not (v10 and assetEarnings and type(assetEarnings.MutationOnlyRatePerSecond) == "function") then
			return nil
		end
		local ok, result = pcall(assetEarnings.MutationOnlyRatePerSecond, v10)
		if ok and type(result) == "number" then
			return result
		end
		return nil
	end

	local function fn39(arg)
		local formatCompact = tbl11 and tbl11.FormatCompact

		if type(formatCompact) == "function" then
			local ok, result = pcall(formatCompact, arg, ".#")
			if ok and type(result) == "string" then
				return result
			end
		end

		return fn3(arg)
	end

	local function fn40(arg)
		local addCommas = tbl11 and tbl11.AddCommas

		if type(addCommas) == "function" then
			local ok, result = pcall(addCommas, arg)
			if ok and type(result) == "string" then
				return result
			end
		end

		return tostring(math.round(arg))
	end

	local function fn41(arg)
		local rec = arg.rec or {}
		local directory = Assets and Assets.Directory and Assets.Directory[arg.category]

		if directory then
			directory = directory.DisplayName or directory.Name
		end

		directory = directory or arg.category
		local rarityId = arg.rarityId ~= "" and arg.rarityId or "Unknown"
		local color = arg.rarity and arg.rarity.Color
		local str = typeof(color) == "Color3" and fn5(color) or "#FFFFFF"
		local weight = arg.weightKnown and arg.weight or fn37(rec)
		local v10 = fn38(rec)
		local str2 = type(weight) == "number" and fn40(math.max(weight, 0)) .. " KG" or "-- KG"
		local str3 = type(v10) == "number" and "$" .. fn39(math.max(v10, 0)) .. "/s" or "$--/s"
		return ("<b><font color=\"#F4F4F5\">%s</font></b> <font color=\"%s\">[%s]</font><font color=\"#C4B5FD\">%s</font>\n<font color=\"#E5E7EB\">%s</font> <font color=\"#71717A\">·</font> <font color=\"#58E083\"><b>%s</b></font>"):format(fn32(directory), str, fn32(rarityId), fn35(rec), str2, str3)
	end

	local function fn42(arg, arg2)
		return (arg == "pen" and "Pen_" or "Area_") .. tostring(arg2):gsub("[^%w_%-]", "_")
	end

	local function fn43(arg, source, arg2)
		arg.source = source
		arg.attachment.Name = fn42(source, arg2)
		arg.billboard.Name = source == "pen" and "PenESP" or "EggESP"
	end

	local function fn44(arg, arg2)
		local attachment = Instance.new("Attachment")
		attachment.Parent = createPart()
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Adornee = attachment
		billboardGui.AlwaysOnTop = true
		billboardGui.LightInfluence = 0
		billboardGui.MaxDistance = 6000
		billboardGui.Size = UDim2.fromOffset(210, 52)
		billboardGui.Parent = attachment
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Info"
		textLabel.BackgroundTransparency = 1
		textLabel.BorderSizePixel = 0
		textLabel.Size = UDim2.fromScale(1, 1)
		textLabel.Font = Enum.Font.GothamMedium
		textLabel.RichText = true
		textLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
		textLabel.TextSize = 14
		textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
		textLabel.TextStrokeTransparency = 0.45
		textLabel.TextWrapped = true
		textLabel.Parent = billboardGui
		local tbl16 = { attachment = attachment, billboard = billboardGui, label = textLabel }
		fn43(tbl16, arg2, arg)
		tbl15.markers[arg] = tbl16
		return tbl16
	end

	local function fn45()
		local v10 = pairs
		local eggESPAreas = tbl2.EggESPAreas or {}

		for _, eggESPArea in v10(eggESPAreas) do
			if eggESPArea == true then
				return true
			end
		end

		return false
	end

	local function fn46()
		local tbl16 = {}
		if not tbl15.areaEnabled then
			return tbl16
		end

		if not (tbl11 and type(tbl11.GetAreaEggSnapshot) == "function") then
			return tbl16
		end
		local ok, result = pcall(tbl11.GetAreaEggSnapshot)
		if not ok or type(result) ~= "table" then
			return tbl16
		end
		local records = result.Records or result
		if type(records) ~= "table" then
			return tbl16
		end
		local v10 = fn45()

		for _, record in pairs(records) do
			local flag2 = type(record) == "table"

			if flag2 then
				flag2 = tostring(record.Uid or "")
			end

			flag2 = flag2 or ""
			local flag3 = type(record) == "table"

			if flag3 then
				flag3 = tostring(record.State or "")
			end

			flag3 = flag3 or ""
			local position = type(record) == "table" and typeof(record.BottomCFrame) == "CFrame" and record.BottomCFrame.Position or nil
			local flag4 = type(record) == "table"
			local str

			if flag4 then
				str = tostring(record.AssetCategory or "")
			else
				str = flag4
			end

			str = str or ""
			local flag5 = type(record) == "table"

			if flag5 then
				flag5 = tostring(record.AreaId or "")
			end

			flag5 = flag5 or ""
			local flag6 = flag2 ~= "" and position and (flag3 == "Slot" or flag3 == "Dropped")
			local flag7

			if flag6 then
				flag7 = not v10 or tbl2.EggESPAreas[flag5] == true
			else
				flag7 = flag6
			end

			if flag7 then
				local v11 = fn30(record)
				local v12 = fn37(record)

				tbl16[flag2] = {
					source = "area",
					entry = {
						rec = record,
						uid = flag2,
						state = flag3,
						rarity = v11,
						rarityId = v11 and tostring(v11._id) or "Unknown",
						weight = v12 or 0,
						weightKnown = v12 ~= nil,
						position = position,
						area = flag5,
						category = str,
					},
					offset = math.clamp((tonumber(record.BoundsSize and record.BoundsSize.Y) or 2) * 0.5 + 2, 2.5, 10),
				}
			end
		end

		return tbl16
	end

	local function fn47(arg)
		if not tbl15.PlotCmds then
			return nil
		end
		local playerByUserId = Players2:GetPlayerByUserId(tonumber(arg) or 0)
		if not playerByUserId then
			return nil
		end
		local v10 = nil

		pcall(function()
			v10 = tbl15.PlotCmds.GetPlotData(playerByUserId)
		end)

		if type(v10) ~= "table" then
			return nil
		end
		local centerPoint = v10.CenterPoint
		if typeof(centerPoint) == "CFrame" then
			return centerPoint
		end

		if typeof(centerPoint) == "Instance" and centerPoint:IsA("BasePart") then
			return centerPoint.CFrame
		end
		local petArea = v10.PetArea
		if typeof(petArea) == "Instance" and petArea:IsA("BasePart") then
			return petArea.CFrame
		end
		return nil
	end

	local function fn48()
		local tbl16 = {}
		if not tbl15.penEnabled then
			return tbl16
		end

		if not (tbl11 and type(tbl11.GetRuntimeSnapshot) == "function") then
			return tbl16
		end
		local ok, result = pcall(tbl11.GetRuntimeSnapshot)
		if not ok or type(result) ~= "table" then
			return tbl16
		end
		local userId = localPlayer.UserId
		local str = tostring(userId)
		local v10 = fn47(userId)
		if not v10 then
			return tbl16
		end

		for _, v11 in pairs(result) do
			if type(v11) == "table" and type(v11.Records) == "table" and tostring(v11.OwnerUserId) == str then
				for k, record in pairs(v11.Records) do
					local placement = type(record) == "table" and record.Placement
					local localCFrame = type(placement) == "table" and placement.LocalCFrame

					if typeof(localCFrame) == "CFrame" then
						local itemData = type(record.ItemData) == "table" and record.ItemData or record
						local str2 = tostring(itemData.Uid or record.Uid or k or "")
						local str3 = tostring(itemData.AssetCategory or itemData.Category or "")
						local v12 = fn30(itemData)
						local v13 = fn37(itemData)
						local n2 = tonumber(itemData.AssetScale or itemData.Scale or record.AssetScale or record.Scale) or 1

						if str2 ~= "" and str3 ~= "" then
							tbl16[str2] = {
								source = "pen",
								entry = {
									rec = itemData,
									uid = str2,
									state = "Placed",
									rarity = v12,
									rarityId = v12 and tostring(v12._id) or "Unknown",
									weight = v13 or 0,
									weightKnown = v13 ~= nil,
									position = (v10 * localCFrame).Position,
									area = "",
									category = str3,
									ownerUserId = userId,
								},
								offset = math.clamp(2.5 + math.max(n2, 0) * 2, 3, 10),
							}
						end
					end
				end

				return tbl16
			end
		end

		return tbl16
	end

	tbl15.reconcile = function(arg)
		if not fn34() or not fn() then
			return
		end
		local v10 = fn46()

		for k, v11 in pairs(fn48()) do
			v10[k] = v11
		end

		local n2 = 0
		local n3 = 0

		for k, v11 in pairs(v10) do
			local v12 = arg.markers[k] or fn44(k, v11.source)

			if v12.source ~= v11.source then
				fn43(v12, v11.source, k)
			end

			local entry = v11.entry
			v12.attachment.Position = entry.position + Vector3.new(0, v11.offset, 0)
			local v13 = fn41(entry)

			if v12.label.Text ~= v13 then
				v12.label.Text = v13
			end

			if v11.source == "pen" then
				n2 += 1
			else
				n3 += 1
			end
		end

		for k, marker in pairs(arg.markers) do
			if not v10[k] then
				arg.markers[k] = nil

				pcall(function()
					marker.attachment:Destroy()
				end)
			end
		end

		local count = 0

		for k in pairs(arg.markers) do
			count += 1
		end

		arg.count = count
	end

	local function fn49()
		if not fn34() or tbl15.queued then
			return
		end
		tbl15.queued = true

		task.defer(function()
			tbl15.queued = false

			if fn34() and fn() then
				tbl15:reconcile()
			end
		end)
	end

	handlers.refreshEggESP = function()
		if tbl15.areaEnabled then
			fn49()
		end
	end

	handlers.refreshPenESP = function()
		if tbl15.penEnabled then
			fn49()
		end
	end

	handlers.setEggESP = function(arg)
		tbl15.areaEnabled = arg == true

		if fn34() then
			fn49()
		else
			fn33()
		end
	end

	handlers.setPenESP = function(arg)
		tbl15.penEnabled = arg == true

		if fn34() then
			fn49()
		else
			fn33()
		end
	end

	local chsaeEggESP = workspace:FindFirstChild("__CHSAE_EggESP")

	if chsaeEggESP then
		pcall(function()
			chsaeEggESP:Destroy()
		end)
	end

	pcall(function()
		tbl15.trackConnection(tbl11.RuntimeSnapshotUpdated:Connect(function()
			handlers.refreshPenESP()
		end))
	end)

	pcall(function()
		tbl15.trackConnection(tbl11.AreaEggRecordUpdated:Connect(function()
			handlers.refreshEggESP()
		end))
	end)

	pcall(function()
		tbl15.trackConnection(tbl11.AreaEggRecordRemoved:Connect(function()
			handlers.refreshEggESP()
		end))
	end)

	pcall(function()
		tbl15.trackConnection(tbl15.PlotCmds.OnAnyPlotUpdated:Connect(function()
			handlers.refreshPenESP()
		end))
	end)

	getgenv().__CHSAE_EggESPRestore = function()
		tbl15.areaEnabled = false
		tbl15.penEnabled = false
		tbl15.queued = false
		fn33()
	end
end

fn31()

local function fn32()
	local tbl15 = {
		enabled = false,
		ready = false,
		loading = false,
		queued = false,
		queuedAt = 0,
		queueToken = 0,
		generation = 0,
		worker = 0,
		retryDelay = 0.08,
		coreConnections = {},
		guiConnections = {},
		cardConnections = {},
		inventory = nil,
		scroll = nil,
		eggRecords = nil,
		backpackController = nil,
		categoryLabel = nil,
		valueScope = "pets",
		nextExactResolveAt = 0,
	}

	local fn33 = nil

	local function fn34(arg)
		if arg then
			pcall(function()
				arg:Disconnect()
			end)
		end
	end

	local function fn35(arg)
		local v10 = ipairs
		local tbl16 = arg or {}

		for _, v11 in v10(tbl16) do
			fn34(v11)
		end

		table.clear(arg)
	end

	local function fn36(arg, arg2, arg3)
		if not arg2 then
			return nil
		end

		local ok, result = pcall(function()
			return arg2:Connect(arg3)
		end)

		if ok and result then
			table.insert(arg, result)
			return result
		end
		return nil
	end

	local function fn37(arg)
		if not arg then
			return
		end
		local chsaeInventoryValue = arg:FindFirstChild("__CHSAE_InventoryValue")

		if chsaeInventoryValue then
			pcall(function()
				chsaeInventoryValue:Destroy()
			end)
		end
	end

	local function fn38()
		for k, cardConnection in pairs(tbl15.cardConnections) do
			fn35(cardConnection)
			tbl15.cardConnections[k] = nil
		end
	end

	local function fn39(arg, arg2)
		arg = arg or tbl15.inventory
		arg2 = arg2 or tbl15.scroll

		if arg then
			local chsaeInventoryTotal = arg:FindFirstChild("__CHSAE_InventoryTotal")

			if chsaeInventoryTotal then
				pcall(function()
					chsaeInventoryTotal:Destroy()
				end)
			end
		end

		if arg2 then
			for _, child in ipairs(arg2:GetChildren()) do
				fn37(child)
			end
		end
	end

	local function fn40()
		local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
		playerGui = playerGui and playerGui:FindFirstChild("BackpackGui")
		playerGui = playerGui and playerGui:FindFirstChild("Backpack")
		playerGui = playerGui and playerGui:FindFirstChild("Main")
		playerGui = playerGui and playerGui:FindFirstChild("Inventory")
		local scrollingFrame = playerGui and playerGui:FindFirstChild("ScrollingFrame")
		if playerGui and playerGui:IsA("GuiObject") and scrollingFrame and scrollingFrame:IsA("ScrollingFrame") then
			return playerGui, scrollingFrame
		end
		return nil, nil
	end

	local function fn41(parent, name, arg)
		local textLabel = parent:FindFirstChild(name)

		if textLabel and not textLabel:IsA("TextLabel") then
			pcall(function()
				textLabel:Destroy()
			end)

			textLabel = nil
		end

		if not textLabel then
			textLabel = Instance.new("TextLabel")
			textLabel.Name = name
			textLabel.Parent = parent
		end

		textLabel.AnchorPoint = Vector2.new(0.5, 0)
		textLabel.BorderSizePixel = 0
		textLabel.Font = Enum.Font.SourceSansBold
		textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		textLabel.TextStrokeTransparency = 0.05
		textLabel.TextScaled = false
		textLabel.TextWrapped = false
		textLabel.TextXAlignment = Enum.TextXAlignment.Center
		textLabel.TextYAlignment = Enum.TextYAlignment.Center
		textLabel.Active = false
		textLabel.Selectable = false

		for k, v10 in pairs(arg) do
			textLabel[k] = v10
		end

		return textLabel
	end

	local function fn42(arg)
		local v10 = fn41(arg, "__CHSAE_InventoryTotal", {
			Position = UDim2.new(0.42, 0, 0.005, 0),
			Size = UDim2.new(0.56, 0, 0.13, 0),
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(188, 255, 126),
			TextSize = 28,
			ZIndex = 50,
		})

		for _, child in ipairs(v10:GetChildren()) do
			if child:IsA("UICorner") or child:IsA("UIStroke") or child:IsA("UITextSizeConstraint") then
				pcall(function()
					child:Destroy()
				end)
			end
		end

		return v10
	end

	local function fn43(arg)
		local v10 = fn41(arg, "__CHSAE_InventoryValue", {
			Position = UDim2.new(0.5, 0, 0.035, 0),
			Size = UDim2.new(0.92, 0, 0.22, 0),
			BackgroundColor3 = Color3.fromRGB(7, 12, 8),
			BackgroundTransparency = 0.16,
			TextColor3 = Color3.fromRGB(220, 255, 196),
			TextSize = 15,
			ZIndex = 60,
		})

		local uiCorner = nil

		for _, child in ipairs(v10:GetChildren()) do
			if child:IsA("UICorner") and not uiCorner then
				uiCorner = child
			elseif child:IsA("UICorner") or child:IsA("UIStroke") or child:IsA("UITextSizeConstraint") then
				pcall(function()
					child:Destroy()
				end)
			end
		end

		if not uiCorner then
			uiCorner = Instance.new("UICorner")
			uiCorner.Parent = v10
		end

		uiCorner.CornerRadius = UDim.new(0.3, 0)
		return v10
	end

	local function fn44(arg, arg2)
		local numberFormatter = tbl15.numberFormatter

		if numberFormatter and type(numberFormatter.FormatCompact) == "function" then
			local ok, result = pcall(numberFormatter.FormatCompact, arg, arg2 or ".##")
			if ok and type(result) == "string" and result ~= "" then
				return result
			end
		end

		return fn3(arg)
	end

	local function fn45(arg)
		local character = localPlayer.Character

		for _, v10 in ipairs({ localPlayer:FindFirstChildOfClass("Backpack"), character }) do
			if v10 then
				for _, child in ipairs(v10:GetChildren()) do
					if child:IsA("Tool") and child:GetAttribute("UID") == arg then
						return true
					end
				end
			end
		end

		return false
	end

	local function fn46(arg)
		local category = type(arg) == "table" and arg.Category or nil
		local baseAssetConfig = category and tbl15.assetDirectory[category] or tbl15.baseAssetConfig
		local flag2 = type(category) == "string" and tbl15.assetDirectory[category]
		local result = nil

		if flag2 then
			local ok
			ok, result = pcall(tbl15.itemDisplay.GetNameFromItemData, arg)
			ok = ok and type(result) == "string"
			local v10 = nil

			if not ok then
				result = v10
			end
		end

		local displayName

		if result then
			displayName = result
		else
			displayName = type(arg) == "table" and arg.DisplayName
		end

		displayName = displayName or baseAssetConfig and baseAssetConfig.DisplayName or category or "Asset"
		local ok, result2 = pcall(tbl15.assetItems.WeightLabel, arg)
		ok = ok and type(result2) == "string"
		local str = "?Kg"

		if not ok then
			result2 = str
		end

		return tostring(displayName) .. " (" .. tostring(result2) .. ")"
	end

	local function fn47(arg)
		local baseAssetConfig = tbl15.assetDirectory[arg.Category] or tbl15.baseAssetConfig
		baseAssetConfig = baseAssetConfig and baseAssetConfig.Rarity
		local flag2 = type(baseAssetConfig) == "table"

		if flag2 then
			flag2 = type(baseAssetConfig.RarityNumber or baseAssetConfig.Rank) == "number"
		end

		if flag2 then
			return baseAssetConfig.RarityNumber or baseAssetConfig.Rank
		end
		local v10 = baseAssetConfig and tbl15.rarityDirectory[baseAssetConfig]
		local flag3 = type(v10) == "table"

		if flag3 then
			flag3 = type(v10.RarityNumber or v10.Rank) == "number"
		end

		if flag3 then
			return v10.RarityNumber or v10.Rank
		end
		return math.huge
	end

	local function fn48(arg)
		local ok, result = pcall(tbl15.assetEarnings.MutationOnlyRatePerSecond, arg)
		return ok and type(result) == "number" and result or nil
	end

	local function fn49()
		local eggRecords = tbl15.eggRecords
		if type(eggRecords) == "table" and type(eggRecords.ToAssetItemData) == "function" and type(eggRecords.DisplayNameWithWeight) == "function" then
			return eggRecords
		end

		local ok, eggRecords2 = pcall(function()
			return require(ReplicatedStorage.Shared.Util.EggRecords)
		end)

		if ok and type(eggRecords2) == "table" then
			tbl15.eggRecords = eggRecords2
			return eggRecords2
		end
		return nil
	end

	local function fn50()
		local backpackController = tbl15.backpackController
		if type(backpackController) == "table" and type(backpackController.GetEggSlotFrame) == "function" then
			return backpackController
		end
		local controllers = ReplicatedStorage:FindFirstChild("Controllers") or localPlayer:FindFirstChild("PlayerScripts")
		controllers = controllers and controllers:FindFirstChild("GUI")
		controllers = controllers and controllers:FindFirstChild("BackpackController")
		controllers = controllers and controllers:FindFirstChild("Main")
		if not controllers then
			return nil
		end
		local ok, backpackController2 = pcall(require, controllers)
		if ok and type(backpackController2) == "table" then
			tbl15.backpackController = backpackController2
			return backpackController2
		end
		return nil
	end

	local function fn51()
		local v10 = fn49()
		if not v10 then
			return {}, nil
		end
		local ok, result = pcall(tbl15.save.Get)
		if not ok or type(result) ~= "table" then
			return nil, "save-not-ready"
		end
		local v11 = fn50()
		local tbl16 = {}
		local v12 = pairs
		local eggInventory = result.EggInventory or {}

		for k, v13 in v12(eggInventory) do
			if type(k) == "string" and type(v13) == "table" and v13.Placement == nil then
				local ok2, result2 = pcall(v10.ToAssetItemData, v13)
				local flag2 = ok2 and type(result2) == "table" and fn48(result2) or nil
				local ok3, result3 = pcall(v10.DisplayNameWithWeight, v13)

				if type(flag2) == "number" and ok3 and type(result3) == "string" then
					local result4 = nil

					if v11 then
						local ok4
						ok4, result4 = pcall(v11.GetEggSlotFrame, v11, k)
						ok4 = ok4 and typeof(result4) == "Instance"
						local v14 = nil

						if not ok4 then
							result4 = v14
						end
					end

					table.insert(tbl16, {
						uid = k,
						item = result2,
						income = flag2,
						display = result3,
						frame = result4,
						source = result4 and "egg-slot-api" or "egg-record",
					})
				end
			end
		end

		table.sort(tbl16, function(arg, arg2)
			return arg.uid < arg2.uid
		end)

		return tbl16, nil
	end

	local function fn52(arg, arg2)
		if type(arg2) ~= "number" or arg2 <= 0 then
			return 0
		end
		local ok, result = pcall(tbl15.mutations.RarityFactorFor, arg.Mutations, arg.BaseMutation)
		return ok and type(result) == "number" and result / arg2 or 0
	end

	local function fn53(arg, arg2)
		if arg.favorite ~= arg2.favorite then
			return arg.favorite
		end

		if arg.rarity ~= arg2.rarity then
			return arg.rarity > arg2.rarity
		end

		if arg.earning ~= arg2.earning then
			return arg.earning > arg2.earning
		end

		if arg.odds ~= arg2.odds then
			return arg.odds > arg2.odds
		end

		if arg.dropWeight ~= arg2.dropWeight then
			return arg.dropWeight < arg2.dropWeight
		end
		return arg.uid < arg2.uid
	end

	local function fn54()
		local ok, result = pcall(tbl15.save.Get)
		if not ok or type(result) ~= "table" or type(result.Inventory) ~= "table" then
			return nil, "save-not-ready"
		end
		local ok2, result2 = pcall(tbl15.assetRoster.ReadOwnerPen, localPlayer.UserId)
		if not ok2 or type(result2) ~= "table" then
			return nil, "pen-roster-not-ready"
		end
		local tbl16 = {}
		local v10 = ipairs
		local equippedAssets = result.EquippedAssets or {}

		for _, equippedAsset in v10(equippedAssets) do
			if type(equippedAsset) == "string" then
				tbl16[equippedAsset] = true
			end
		end

		local tbl17 = {}

		for k, v11 in pairs(result.Inventory) do
			if type(k) == "string" and type(v11) == "table" then
				local ok3, result3 = pcall(tbl15.assetItems.Decode, v11)

				if ok3 and type(result3) == "table" and result3.InFuse ~= true and (not tbl16[k] or fn45(k)) and result2[k] == nil then
					local v12 = fn48(result3)

					if type(v12) == "number" then
						local baseAssetConfig = tbl15.assetDirectory[result3.Category] or tbl15.baseAssetConfig
						baseAssetConfig = baseAssetConfig and baseAssetConfig.DropWeight

						if type(baseAssetConfig) ~= "number" then
							baseAssetConfig = math.huge
						end

						table.insert(tbl17, {
							uid = k,
							item = result3,
							income = v12,
							display = fn46(result3),
							favorite = result3.IsFavorite == true,
							rarity = fn47(result3),
							earning = v12,
							odds = fn52(result3, baseAssetConfig),
							dropWeight = baseAssetConfig,
						})
					end
				end
			end
		end

		table.sort(tbl17, fn53)
		return tbl17, nil
	end

	local function fn55(arg, arg2)
		local tbl16 = {}

		for _, child in ipairs(arg:GetChildren()) do
			if child:IsA("TextButton") and child:GetAttribute("IsInventorySlot") == true and child:GetAttribute(arg2) == true then
				local toolName = child:FindFirstChild("ToolName")

				if toolName and toolName:IsA("TextLabel") then
					table.insert(tbl16, child)
				end
			end
		end

		table.sort(tbl16, function(arg3, arg4)
			if arg3.LayoutOrder ~= arg4.LayoutOrder then
				return arg3.LayoutOrder < arg4.LayoutOrder
			end
			return (tonumber(arg3.Name) or math.huge) < (tonumber(arg4.Name) or math.huge)
		end)

		return tbl16
	end

	local function fn56(arg)
		local categoryLabel = arg and arg:FindFirstChild("CategoryLabel")

		if categoryLabel and categoryLabel:IsA("TextLabel") then
			local match = string.lower(tostring(categoryLabel.Text or "")):match("^%s*(.-)%s*$")

			if match == "eggs" then
				tbl15.valueScope = "eggs"
			elseif match == "pets" then
				tbl15.valueScope = "pets"
			end
		end

		return tbl15.valueScope
	end

	local function fn57(arg, arg2)
		local tbl16 = {}

		if #arg == #arg2 then
			local flag2 = true

			for i, v10 in ipairs(arg2) do
				local toolName = v10:FindFirstChild("ToolName")
				if not toolName or toolName.Text ~= arg[i].display then
					flag2 = false
					break
				end
			end

			if flag2 then
				for i, v10 in ipairs(arg2) do
					tbl16[v10] = arg[i]
				end

				return tbl16, true
			end
		end

		local tbl17 = {}

		for _, v10 in ipairs(arg) do
			local tbl18 = tbl17[v10.display]

			if not tbl18 then
				tbl18 = {}
				tbl17[v10.display] = tbl18
			end

			table.insert(tbl18, v10)
		end

		local tbl18 = {}

		for _, v10 in ipairs(arg2) do
			local text = v10.ToolName.Text
			local tbl19 = tbl18[text]

			if not tbl19 then
				tbl19 = {}
				tbl18[text] = tbl19
			end

			table.insert(tbl19, v10)
		end

		local n2 = 0

		for k, v10 in pairs(tbl18) do
			local v11 = tbl17[k]

			if v11 and #v11 == #v10 then
				for i, v12 in ipairs(v10) do
					tbl16[v12] = v11[i]
					n2 += 1
				end
			elseif v11 and #v11 > #v10 then
				local income = v11[1].income
				local flag2 = true

				for i = 2, #v11 do
					if v11[i].income ~= income then
						flag2 = false
						break
					end
				end

				if flag2 then
					for _, v12 in ipairs(v10) do
						tbl16[v12] = { uid = nil, income = income, display = k }
						n2 += 1
					end
				end
			end
		end

		return tbl16, n2 == #arg2
	end

	local function fn58(arg, arg2, arg3)
		local nextExactResolveAt = tbl15.nextExactResolveAt
		if os.clock() < nextExactResolveAt then
			return nil, false
		end
		tbl15.nextExactResolveAt = os.clock() + 5
		local genv = getgenv()

		if genv then
			genv = genv.filtergc or genv.filter_gc
		end

		if type(genv) ~= "function" then
			return nil, false
		end
		local ok, result = pcall(genv, "table", { Keys = { "Tool", "Index", "Frame" } }, false)
		if not ok or type(result) ~= "table" then
			return nil, false
		end
		local tbl16

		if rawget(result, "Tool") ~= nil and rawget(result, "Frame") ~= nil then
			tbl16 = { result }
		else
			tbl16 = result
		end

		local tbl17 = {}
		local tbl18 = {}

		for _, v10 in ipairs(arg2) do
			tbl17[v10] = true
		end

		for _, v10 in ipairs(arg) do
			tbl18[v10.uid] = v10
		end

		local tbl19 = {}

		for _, v10 in pairs(tbl16) do
			if type(v10) == "table" then
				local value = rawget(v10, "Frame")
				local value2 = rawget(v10, "Tool")

				if tbl17[value] and value.Parent == arg3 then
					local attribute = nil

					pcall(function()
						if type(value2) == "table" then
							attribute = rawget(value2, "UID") or type(value2.GetAttribute) == "function" and value2:GetAttribute("UID")
						elseif typeof(value2) == "Instance" then
							attribute = value2:GetAttribute("UID")
						end
					end)

					local flag2 = type(attribute) == "string" and tbl18[attribute] or nil
					local toolName = value:FindFirstChild("ToolName")

					if flag2 and toolName and toolName.Text == flag2.display then
						local v11 = tbl19[value]

						if v11 == nil then
							tbl19[value] = flag2
						elseif v11 ~= flag2 then
							tbl19[value] = false
						end
					end
				end
			end
		end

		local tbl20 = {}
		local v10, v11, v12 = ipairs(arg2)
		local n2 = 0

		for _, v13 in v10, v11, v12 do
			local v14 = tbl19[v13]

			if type(v14) == "table" then
				tbl20[v13] = { uid = v14.uid, income = v14.income, display = v14.display, source = "native-slot" }
				n2 += 1
			end
		end

		return tbl20, n2 == #arg2
	end

	local function fn59(arg, arg2)
		local v10 = tbl15.cardConnections[arg]

		if v10 then
			fn35(v10)
			tbl15.cardConnections[arg] = nil
		end

		if arg2 then
			fn37(arg)
		end
	end

	local function fn60(arg)
		if not arg or not arg:IsA("TextButton") or tbl15.cardConnections[arg] then
			return
		end
		local tbl16 = {}
		tbl15.cardConnections[arg] = tbl16

		fn36(tbl16, arg:GetPropertyChangedSignal("LayoutOrder"), function()
			fn33(0.04)
		end)

		fn36(tbl16, arg:GetAttributeChangedSignal("HasAssetOverlay"), function()
			fn33(0.04)
		end)

		fn36(tbl16, arg:GetAttributeChangedSignal("HasEggOverlay"), function()
			fn33(0.04)
		end)

		fn36(tbl16, arg:GetAttributeChangedSignal("IsInventorySlot"), function()
			fn33(0.04)
		end)

		fn36(tbl16, arg.ChildAdded, function(arg2)
			if arg2.Name == "ToolName" then
				if arg2:IsA("TextLabel") then
					fn36(tbl16, arg2:GetPropertyChangedSignal("Text"), function()
						fn33(0.06)
					end)
				end

				fn33(0.04)
			end
		end)

		fn36(tbl16, arg.AncestryChanged, function(arg2, arg3)
			if not arg3 then
				fn59(arg, false)
			end

			fn33(0.04)
		end)

		local toolName = arg:FindFirstChild("ToolName")

		if toolName and toolName:IsA("TextLabel") then
			fn36(tbl16, toolName:GetPropertyChangedSignal("Text"), function()
				fn33(0.06)
			end)
		end
	end

	local function fn61(inventory, scroll)
		if tbl15.inventory == inventory and tbl15.scroll == scroll then
			return
		end
		fn39(tbl15.inventory, tbl15.scroll)
		fn35(tbl15.guiConnections)
		fn38()
		tbl15.inventory = inventory
		tbl15.scroll = scroll
		tbl15.categoryLabel = nil
		tbl15.valueScope = "pets"

		local function fn62(categoryLabel)
			if not categoryLabel or not categoryLabel:IsA("TextLabel") or tbl15.categoryLabel == categoryLabel then
				return
			end
			tbl15.categoryLabel = categoryLabel

			fn36(tbl15.guiConnections, categoryLabel:GetPropertyChangedSignal("Text"), function()
				fn56(inventory)
				fn33(0)
			end)

			fn36(tbl15.guiConnections, categoryLabel.AncestryChanged, function(arg, arg2)
				if not arg2 and tbl15.categoryLabel == categoryLabel then
					tbl15.categoryLabel = nil
				end

				fn33(0)
			end)
		end

		fn62(inventory:FindFirstChild("CategoryLabel"))
		fn56(inventory)

		fn36(tbl15.guiConnections, scroll.ChildAdded, function(arg)
			task.defer(function()
				if tbl15.enabled and arg.Parent == scroll then
					fn60(arg)
				end

				fn33(0.05)
			end)
		end)

		fn36(tbl15.guiConnections, scroll.ChildRemoved, function(arg)
			fn59(arg, false)
			fn33(0.05)
		end)

		fn36(tbl15.guiConnections, inventory.AncestryChanged, function(arg, arg2)
			if not arg2 then
				fn33(0.08)
			end
		end)

		fn36(tbl15.guiConnections, inventory.ChildAdded, function(arg)
			if arg.Name == "CategoryLabel" then
				fn62(arg)
				fn56(inventory)
				fn33(0)
			end
		end)

		for _, child in ipairs(scroll:GetChildren()) do
			fn60(child)
		end
	end

	local function fn62()
		if not tbl15.enabled or not tbl15.ready or not fn() then
			return
		end
		local v10, v11 = fn40()

		if not v10 then
			fn39(tbl15.inventory, tbl15.scroll)
			local v12 = tbl15
			tbl15.inventory = nil
			v12.scroll = nil
			tbl15.retryDelay = math.min(2, tbl15.retryDelay * 2)
			fn33(tbl15.retryDelay)
			return
		end

		fn61(v10, v11)
		local v12 = fn42(v10)
		local v13 = fn54()
		local v14 = fn51()
		local hasAssetOverlay = fn55(v11, "HasAssetOverlay")
		local hasEggOverlay = fn55(v11, "HasEggOverlay")

		for k in pairs(tbl15.cardConnections) do
			if k.Parent ~= v11 then
				fn59(k, true)
			end
		end

		for _, v15 in ipairs(hasAssetOverlay) do
			fn60(v15)
		end

		if not v13 or not v14 then
			v12.Text = "Total Value: loading..."
			v12:SetAttribute("ExactValue", nil)
			v12:SetAttribute("ExactIncomePerSecond", nil)
			v12:SetAttribute("ExactPetIncomePerSecond", nil)
			v12:SetAttribute("ExactEggIncomePerSecond", nil)
			tbl15.retryDelay = math.min(2, tbl15.retryDelay * 2)
			fn33(tbl15.retryDelay)
			return
		end

		local n2 = 0

		for _, v15 in ipairs(v13) do
			n2 += v15.income
		end

		local n3 = 0

		for _, v15 in ipairs(v14) do
			n3 += v15.income
		end

		local v15 = fn56(v10)
		local flag2 = v15 == "eggs" and n3 or n2
		local str = v15 == "eggs" and "Egg" or "Pet"
		v12.Text = "Total " .. str .. " Value: $" .. fn44(flag2, ".###") .. "/s"
		v12:SetAttribute("ExactValue", flag2)
		v12:SetAttribute("ExactIncomePerSecond", flag2)
		v12:SetAttribute("ExactPetIncomePerSecond", n2)
		v12:SetAttribute("ExactEggIncomePerSecond", n3)
		v12:SetAttribute("InventoryCategory", str .. "s")
		v12:SetAttribute("Scope", v15 == "eggs" and "native-unplaced-egg-income" or "native-eligible-pet-income")
		local v16, flag3 = fn57(v13, hasAssetOverlay)
		local tbl16 = {}

		for _, v17 in ipairs(hasEggOverlay) do
			tbl16[v17] = true
		end

		local n4 = 0

		for _, v17 in ipairs(v14) do
			local frame = v17.frame
			local toolName = frame and frame:FindFirstChild("ToolName")

			if frame and tbl16[frame] and not v16[frame] and toolName and toolName:IsA("TextLabel") and toolName.Text == v17.display then
				v16[frame] = v17
				n4 += 1
			end
		end

		flag3 = flag3 and n4 == #hasEggOverlay

		if not flag3 then
			local tbl17 = {}
			local tbl18 = {}

			for _, v17 in ipairs(v13) do
				table.insert(tbl17, v17)
			end

			for _, v17 in ipairs(v14) do
				table.insert(tbl17, v17)
			end

			for _, v17 in ipairs(hasAssetOverlay) do
				table.insert(tbl18, v17)
			end

			for _, v17 in ipairs(hasEggOverlay) do
				table.insert(tbl18, v17)
			end

			local v17, v18 = fn58(tbl17, tbl18, v11)

			if v17 then
				for k, v19 in pairs(v17) do
					v16[k] = v19
				end

				if not v18 then
					local n5 = 0

					for _, v19 in ipairs(tbl18) do
						if v16[v19] then
							n5 += 1
						end
					end

					flag3 = n5 == #tbl18
				else
					flag3 = v18
				end
			end
		end

		local n5 = 0

		for _, child in ipairs(v11:GetChildren()) do
			local v17 = v16[child]

			if v17 then
				local v18 = fn43(child)
				v18.Text = "$" .. fn44(v17.income, ".#") .. "/s"
				v18:SetAttribute("ExactValue", v17.income)
				v18:SetAttribute("ExactIncomePerSecond", v17.income)
				v18:SetAttribute("UID", v17.uid)
				local v19 = v18
				local setAttribute = v19.SetAttribute
				local source = v17.source
				local str2

				if source then
					str2 = source
				else
					str2 = v17.uid and "native-order" or "equal-income-signature"
				end

				setAttribute(v19, "Source", str2)
				n5 += 1
			else
				fn37(child)
			end
		end

		v12:SetAttribute("ResolvedCards", n5)
		v12:SetAttribute("TotalCards", #hasAssetOverlay + #hasEggOverlay)

		if flag3 then
			tbl15.retryDelay = 0.08
		else
			tbl15.retryDelay = math.min(2, tbl15.retryDelay * 2)
			fn33(tbl15.retryDelay)
		end
	end

	fn33 = function(arg)
		if not tbl15.enabled then
			return
		end
		local n2 = math.max(0, tonumber(arg) or 0.04)
		local queuedAt = os.clock() + n2
		local queued = tbl15.queued

		if queued then
			queued = queuedAt >= (tbl15.queuedAt or 0) - 0.001
		end

		if queued then
			return
		end
		tbl15.queued = true
		tbl15.queuedAt = queuedAt
		tbl15.queueToken = tbl15.queueToken + 1
		local queueToken = tbl15.queueToken
		local generation = tbl15.generation

		task.delay(n2, function()
			if tbl15.queueToken ~= queueToken then
				return
			end
			tbl15.queued = false
			tbl15.queuedAt = 0

			if tbl15.enabled and tbl15.generation == generation and fn() then
				if not pcall(fn62) then
					tbl15.retryDelay = math.min(2, tbl15.retryDelay * 2)
					fn33(tbl15.retryDelay)
				end
			end
		end)
	end

	local function fn63()
		fn35(tbl15.coreConnections)

		local function fn64()
			fn33(0.1)
		end

		for _, v10 in ipairs({ "Inventory", "EquippedAssets", "EggInventory" }) do
			pcall(function()
				fn36(tbl15.coreConnections, tbl15.save.FieldSignal(v10), fn64)
			end)
		end

		local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

		if playerGui then
			fn36(tbl15.coreConnections, playerGui.ChildAdded, fn64)
		end

		fn36(tbl15.coreConnections, localPlayer.CharacterAdded, fn64)

		fn36(tbl15.coreConnections, tbl15.assetRoster.OwnerRefreshed, function(arg)
			if arg == localPlayer.UserId then
				fn64()
			end
		end)

		fn36(tbl15.coreConnections, tbl15.assetRoster.OwnerCleared, function(arg)
			if arg == localPlayer.UserId then
				fn64()
			end
		end)
	end

	local function fn64()
		tbl15.worker = tbl15.worker + 1
		local worker = tbl15.worker

		task.spawn(function()
			while tbl15.enabled and tbl15.worker == worker and fn() do
				task.wait(12)

				if tbl15.enabled and tbl15.worker == worker then
					fn33(0.04)
				end
			end
		end)
	end

	local fn65 = nil

	fn65 = function(arg)
		if tbl15.ready or tbl15.loading then
			return
		end
		tbl15.loading = true

		task.spawn(function()
			local ok, save, assetItems, itemDisplay, result, result2, assetEarnings, mutations, assetRoster, numberFormatter = pcall(function()
				local v10 = require
				local simple = ReplicatedStorage.Packages.FormatNumber.Simple
				return GetSaveModule(), require(ReplicatedStorage.Shared.Util.AssetItems), require(ReplicatedStorage.Shared.Modules.ItemDisplay), require(ReplicatedStorage.Data.Assets), require(ReplicatedStorage.Data.Rarity), require(ReplicatedStorage.Shared.Util.AssetEarnings), require(ReplicatedStorage.Shared.Modules.Mutations), require(ReplicatedStorage.Client.AssetRoster), v10(simple)
			end)

			tbl15.loading = false

			if not ok or not tbl15.enabled or tbl15.generation ~= arg or not fn() then
				if tbl15.enabled and fn() then
					task.delay(1, function()
						if tbl15.enabled and not tbl15.ready and fn() then
							fn65(tbl15.generation)
						end
					end)
				end

				return
			end

			tbl15.save = save
			tbl15.assetItems = assetItems
			tbl15.itemDisplay = itemDisplay
			tbl15.assetDirectory = result.Directory
			tbl15.baseAssetConfig = result.BaseConfig
			tbl15.rarityDirectory = result2.Rarities
			tbl15.assetEarnings = assetEarnings
			tbl15.mutations = mutations
			tbl15.assetRoster = assetRoster
			tbl15.numberFormatter = numberFormatter
			tbl15.ready = type(tbl15.assetDirectory) == "table" and type(tbl15.rarityDirectory) == "table"

			if tbl15.ready then
				fn63()
				fn33(0.08)
			else
				task.delay(1, function()
					if tbl15.enabled and not tbl15.ready and fn() then
						fn65(tbl15.generation)
					end
				end)
			end
		end)
	end

	local function chsaeInventoryESPRestore()
		tbl15.enabled = false
		tbl15.generation = tbl15.generation + 1
		tbl15.worker = tbl15.worker + 1
		tbl15.queued = false
		tbl15.queuedAt = 0
		tbl15.queueToken = tbl15.queueToken + 1
		fn35(tbl15.coreConnections)
		fn35(tbl15.guiConnections)
		fn38()
		fn39(tbl15.inventory, tbl15.scroll)
		local v10, v11 = fn40()
		fn39(v10, v11)
		local v12 = tbl15
		local v13 = tbl15
		tbl15.inventory = nil
		v12.scroll = nil
		v13.categoryLabel = nil
		tbl15.valueScope = "pets"
	end

	if getgenv().__CHSAE_InventoryESPRestore then
		pcall(getgenv().__CHSAE_InventoryESPRestore)
	end

	getgenv().__CHSAE_InventoryESPRestore = chsaeInventoryESPRestore

	handlers.setInventoryESP = function(arg)
		local flag2 = arg == true

		if tbl15.enabled == flag2 then
			if flag2 then
				fn33(0.04)
			else
				fn39()
			end

			return
		end

		if not flag2 then
			chsaeInventoryESPRestore()
			return
		end
		tbl15.enabled = true
		tbl15.generation = tbl15.generation + 1
		tbl15.retryDelay = 0.08
		local generation = tbl15.generation

		if tbl15.ready then
			fn63()
			fn33(0.08)
		else
			fn65(generation)
		end

		fn64()
	end
end

fn32()
local fn33

fn33 = function()
	local character = localPlayer.Character
	if not character then
		return nil, nil
	end
	local findFirstChildOfClass = character.FindFirstChildOfClass
	return character:FindFirstChild("HumanoidRootPart"), findFirstChildOfClass(character, "Humanoid")
end

local fn34

fn34 = function()
	local n2 = 0.08

	pcall(function()
		n2 = math.max(0, Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) / 1000
	end)

	return n2
end

local fn35, fn36

local function fn37()
	local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
	world = world and world:FindFirstChild("Areas")
	return world and world:FindFirstChild("SeparationLine")
end

fn35 = function(arg)
	local v10 = fn37()
	if not (v10 and arg) then
		return nil
	end
	return v10.CFrame.LookVector:Dot(arg - v10.Position)
end

fn36 = function(arg)
	local v10 = fn37()
	local v11 = fn33()
	if not (v10 and v11) then
		return nil
	end
	return v11.Position - v10.CFrame.LookVector.Unit * ((fn35(v11.Position) or 0) + 1 + (arg or 0))
end

local fn38

fn38 = function()
	local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
	world = world and world:FindFirstChild("Areas")
	return world and world:FindFirstChild("StartArea")
end

handlers.getTrackStart = function()
	local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
	world = world and world:FindFirstChild("Build")
	local mainMap = world and world:FindFirstChild("MainMap")
	local trackStart = mainMap and mainMap:FindFirstChild("TrackStart")
	if trackStart and trackStart:IsA("BasePart") then
		return trackStart
	end
	return nil
end

local state
state = nil

handlers.getSafetySummary = function()
	local v10 = state
	if type(v10) ~= "table" then
		return handlers.defaultMoveFallback and "🚶 Safe fallback" or "🛡️ Guard unavailable", 0
	end
	local value = rawget(v10, "Evidence")
	local n2 = type(value) == "table" and tonumber(rawget(value, "Speed")) or 0
	local n3 = type(value) == "table" and tonumber(rawget(value, "Teleport")) or 0
	local n4 = type(value) == "table" and tonumber(rawget(value, "Flight")) or 0
	local n5 = 0 + math.max(0, n2) + math.max(0, n3) + math.max(0, n4) + math.max(0, tonumber(rawget(v10, "TamperScore")) or 0) + math.max(0, tonumber(rawget(v10, "InvalidHeartbeatCount")) or 0)

	if rawget(v10, "KickQueued") == true then
		n5 += 4
	end

	local str = tostring(rawget(v10, "ThreatLevel") or "Unknown")
	if n5 == 0 then
		return "🛡️ " .. (str == "Unknown" and "Trusted" or str), 0
	end
	return "⚠️ " .. str, n5
end

local fn39, fn40, fn41, fn42

do
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.RespectCanCollide = true

	local function fn43()
		local character = localPlayer.Character

		if character then
			raycastParams.FilterDescendantsInstances = { character }
		end
	end

	fn43()

	fn39 = function(arg, arg2, arg3)
		local v10, v11 = fn33()
		local character = localPlayer.Character
		if not (v11 and character) then
			return nil
		end
		raycastParams.FilterDescendantsInstances = { character }
		local hit = workspace:Raycast(Vector3.new(arg, arg3 + 30, arg2), Vector3.new(0, -400, 0), raycastParams)
		if not hit then
			return nil
		end
		local v12 = state
		local num = state

		if v12 then
			num = tonumber(rawget(v12, "ExpectedHipHeight"))
		end

		local n2 = hit.Position.Y + (num or v11.HipHeight or 2) + (v12 and tonumber(rawget(v12, "ExpectedRootHalfHeight")) or 1)
		if n2 > arg3 + 4 or n2 < arg3 - 8 then
			return arg3
		end
		return n2
	end

	handlers.getStealStart = function()
		local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
		world = world and world:FindFirstChild("Build")
		world = world and world:FindFirstChild("MainMap")
		world = world and world:FindFirstChild("Limit")
		if world and world:IsA("BasePart") then
			return world
		end
		return handlers.getTrackStart()
	end

	handlers.stealStartPosition = function(arg, arg2)
		local position = arg.Position
		local n2 = position.Y + arg2.HipHeight
		if arg.Name ~= "Limit" then
			return Vector3.new(position.X, n2, position.Z)
		end
		return Vector3.new(position.X, fn39(position.X, position.Z, n2) or n2, position.Z)
	end

	local tbl15 = { map = nil, at = 0, save = nil }

	local function fn44(arg)
		local match, v10 = tostring(arg):match("([%d%.]+)%s*([KMBTkmbt]?)")
		local num = tonumber(match)
		if not num then
			return nil
		end
		return num * (({ K = 1000, M = 1000000, B = 1e9, T = 1e12 })[(v10 or ""):upper()] or 1)
	end

	fn40 = function()
		local map = tbl15.map

		if map then
			local at = tbl15.at
			map = os.clock() - at < 30
		end

		if map then
			return tbl15.map
		end
		local map2 = {}

		pcall(function()
			local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
			world = world and world:FindFirstChild("Areas")
			world = world and world:FindFirstChild("GuardAreas")
			if not world then
				return
			end

			for _, child in ipairs(world:GetChildren()) do
				local bounds = child:FindFirstChild("Bounds")
				local v10 = nil

				for _, descendant in ipairs(child:GetDescendants()) do
					if descendant:IsA("TextLabel") then
						v10 = fn44(descendant.Text)
						if not v10 then
							v10 = nil
							continue
						end
					else
						v10 = nil
						continue
					end

					break
				end

				if bounds and bounds:IsA("BasePart") then
					map2[child.Name] = {
						req = v10,
						minX = bounds.Position.X - bounds.Size.X / 2,
						maxX = bounds.Position.X + bounds.Size.X / 2,
						minZ = bounds.Position.Z - bounds.Size.Z / 2,
						maxZ = bounds.Position.Z + bounds.Size.Z / 2,
					}
				end
			end
		end)

		local v10 = tbl15
		local v11 = tbl15
		local now3 = os.clock()
		v10.map = map2
		v11.at = now3
		return map2
	end

	local function fn45()
		local num

		pcall(function()
			if not tbl15.save then
				local v10 = GetSaveModule()

				tbl15.save = { Get = function()
					return v10.Get()
				end }
			end

			num = tonumber(tbl15.save.Get().SpeedPower)
		end)

		return num or 0
	end

	fn41 = function(arg)
		local v10 = fn40()[tostring(arg)]
		if not (v10 and v10.req) then
			return true
		end
		local req = v10.req
		return fn45() >= req
	end

	fn42 = function()
		local v10 = fn33()

		if v10 and v10:GetAttribute("KillPartIgnore") ~= true then
			pcall(function()
				v10:SetAttribute("KillPartIgnore", true)
			end)
		end
	end

	local connection = nil

	local function fn46(character)
		if connection then
			pcall(function()
				connection:Disconnect()
			end)
		end

		connection = nil

		task.spawn(function()
			local v10 = character
			local humanoidRootPart

			if character then
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)
			else
				humanoidRootPart = v10
			end

			if not (fn() and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
				return
			end
			fn43()
			fn42()

			connection = humanoidRootPart:GetAttributeChangedSignal("KillPartIgnore"):Connect(function()
				if fn() and humanoidRootPart:GetAttribute("KillPartIgnore") ~= true then
					fn42()
				end
			end)

			getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = connection
		end)
	end

	if localPlayer.Character then
		fn46(localPlayer.Character)
	end

	getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = localPlayer.CharacterAdded:Connect(fn46)
end

local v10
v10 = nil
local fn43
fn43 = nil
local fn44

do
	local n2 = 0
	local v11 = nil
	local flag2 = false

	local function fn45(arg)
		local tbl15 = {}
		local flag3 = false

		local function fn46(arg2, ...)
			if type(arg2) ~= "function" then
				return false, nil
			end
			return pcall(arg2, ...)
		end

		return {
			upvalues = function(arg2)
				for _, upvalueReader in ipairs(arg.upvalueReaders) do
					local v12, v13 = fn46(upvalueReader, arg2)
					if v12 and type(v13) == "table" then
						return v13
					end
				end

				return nil, "movement API unavailable: getupvalues"
			end,
			constants = function(arg2)
				for _, constantReader in ipairs(arg.constantReaders) do
					local v12, v13 = fn46(constantReader, arg2)
					if v12 and type(v13) == "table" then
						return v13
					end
				end

				return nil
			end,
			name = function(arg2)
				local v12, v13 = fn46(arg.info, arg2, "n")
				if v12 and type(v13) == "string" and v13 ~= "" then
					return v13
				end
				local v14, v15 = fn46(arg.getinfo, arg2)
				if v14 and type(v15) == "table" then
					return rawget(v15, "name")
				end
				return nil
			end,
			frozen = function(arg2)
				local v12, v13 = fn46(arg.isfrozen, arg2)
				return v12 and v13 == true
			end,
			ready = function()
				if #arg.upvalueReaders == 0 then
					return false, "movement API unavailable: getupvalues"
				end

				if type(arg.info) ~= "function" and type(arg.getinfo) ~= "function" then
					return false, "movement API unavailable: function names"
				end

				if type(arg.isfrozen) ~= "function" then
					return false, "movement API unavailable: table.isfrozen"
				end
				return true
			end,
			filter = function(arg2, arg3)
				local keys = arg2 == "table" and arg3.Keys or arg3.Constants
				if type(keys) ~= "table" then
					return nil, "unsupported discovery predicate"
				end
				local str = arg2 .. ":" .. table.concat(keys, "\0")
				local v12 = tbl15[str]
				local flag4

				if v12 then
					local untilAt = v12.untilAt
					flag4 = arg.now() < untilAt
				else
					flag4 = v12
				end

				if flag4 then
					return v12.values, v12.reason
				end

				if flag3 then
					return nil, "movement discovery in progress"
				end
				flag3 = true

				local ok, result, result2 = pcall(function()
					for _, filter in ipairs(arg.filters) do
						local v13, v14 = fn46(filter, arg2, arg3, false)
						if v13 and type(v14) == "table" then
							return v14
						end
					end

					if type(arg.getgc) ~= "function" then
						return nil, "movement API unavailable: filtergc or getgc"
					end

					if arg2 == "function" and #arg.constantReaders == 0 then
						return nil, "movement API unavailable: getconstants"
					end
					local v13, v14 = fn46(arg.getgc, true)
					if not v13 or type(v14) ~= "table" then
						return nil, "movement discovery failed: getgc"
					end
					local tbl16 = {}
					local v15 = arg.now()
					local n3 = 0

					for _, v16 in pairs(v14) do
						n3 += 1
						if n3 > 250000 then
							return nil, "movement discovery limit reached"
						end

						if n3 % 128 == 0 and arg.now() - v15 >= 0.004 then
							arg.pause()
							if not arg.alive() then
								return nil, "movement discovery cancelled"
							end
							v15 = arg.now()
						end

						if type(v16) == arg2 then
							local v17 = nil

							if arg2 == "function" then
								v17 = nil

								for _, constantReader in ipairs(arg.constantReaders) do
									local v18
									v18, v17 = fn46(constantReader, v16)
									if not (v18 and type(v17) == "table") then
										v17 = nil
										continue
									end
									break
								end
							end

							local flag5 = arg2 == "table" or v17 ~= nil

							if flag5 then
								for _, key in ipairs(keys) do
									local flag6

									if arg2 == "table" then
										flag6 = rawget(v16, key) ~= nil
									else
										flag6 = false

										for _, v18 in pairs(v17) do
											if v18 == key then
												flag6 = true
												break
											end
										end
									end

									if not flag6 then
										flag5 = false
										break
									end
								end
							end

							if flag5 then
								tbl16[#tbl16 + 1] = v16
								if #tbl16 > 64 then
									return nil, "movement discovery ambiguous"
								end
							end
						end
					end

					return tbl16
				end)

				flag3 = false

				if not ok then
					result = nil
					result2 = "movement discovery failed"
				end

				tbl15[str] = { values = result, reason = result2, untilAt = arg.now() + 2 }
				return result, result2
			end,
		}
	end

	local genv = getgenv()

	local function fn46(...)
		local tbl15 = {}
		local v12 = table.pack(...)

		for i = 1, v12.n do
			local v13 = v12[i]

			if type(v13) == "function" and not table.find(tbl15, v13) then
				tbl15[#tbl15 + 1] = v13
			end
		end

		return tbl15
	end

	handlers.MovementCompat = fn45({
		filters = fn46(filtergc, genv.filtergc, genv.filter_gc),
		getgc = getgc or genv.getgc,
		upvalueReaders = fn46(getupvalues, genv.getupvalues, debug and debug.getupvalues),
		constantReaders = fn46(getconstants, genv.getconstants, debug and debug.getconstants),
		info = debug and debug.info,
		getinfo = debug and debug.getinfo,
		isfrozen = table.isfrozen,
		now = os.clock,
		pause = function()
			task.wait()
		end,
		alive = fn,
	})

	handlers.findMovementDispatcher = function(arg, arg2)
		local movementCompat = handlers.MovementCompat

		local function fn47(movementCompatibility)
			handlers.movementCompatibility = movementCompatibility
			return nil, movementCompatibility
		end

		if not (arg and arg2 and arg2.Health > 0) then
			local v12, v13 = fn47("waiting for live character")
			return v12, v13
		end
		local v12, v13 = movementCompat.ready()
		if not v12 then
			local v14, v15 = fn47(v13)
			return v14, v15
		end
		local v14, v15 = movementCompat.filter("function", { Constants = { "Relocate action requires twelve CFrame components" } })
		if type(v14) ~= "table" then
			local v16, v17 = fn47(v15)
			return v16, v17
		end

		local function fn48(arg3, arg4)
			if type(arg3) ~= "function" then
				return false
			end
			local v16 = movementCompat.constants(arg3)
			if type(v16) ~= "table" then
				return false
			end

			for _, v17 in pairs(v16) do
				if v17 == arg4 then
					return true
				end
			end

			return false
		end

		local function fn49(arg3)
			if type(arg3) ~= "table" then
				return nil
			end
			local value = rawget(arg3, 1)
			local value2 = rawget(arg3, 3)
			if type(value) ~= "table" or value2 == nil then
				return nil
			end
			return rawget(value, value2)
		end

		local function fn50(arg3, arg4, arg5)
			if arg5 ~= 1 or arg3[5] ~= arg4.state or arg3[8] ~= arg4.token then
				return nil
			end
			local v16 = fn49(arg3[14])
			if not (handlers.hookedRagdollTargets and handlers.hookedRagdollTargets[v16] or fn48(v16, "armedUntil") or fn48(v16, "Ragdoll duration must be non-negative")) then
				return nil
			end

			if not fn48(fn49(arg3[15]), "GettingUp") then
				return nil
			end

			if not fn48(arg3[17], "xpcall") then
				return nil
			end

			for _, v17 in ipairs({ 13, 19, 20, 21 }) do
				if type(arg3[v17]) ~= "function" then
					return nil
				end
			end

			return arg3[19], arg3[20], arg3[21], arg3[13]
		end

		for _, v16 in ipairs(v14) do
			local v17, v18 = movementCompat.upvalues(v16)

			if not v17 and v18 then
				v13 = v18
			end

			if type(v17) ~= "table" then
				continue
			end
			local tbl15 = {}
			local n3 = 0

			for _, v19 in pairs(v17) do
				if type(v19) == "function" then
					local v20 = movementCompat.name(v19)

					if v20 then
						if v20 == "ResetMovementState" then
							tbl15.reset = v19
						elseif v20 == "MakeSample" then
							tbl15.sample = v19
						elseif v20 == "AdoptTeleportBaseline" then
							tbl15.adopt = v19
						elseif v20 == "BeginImpulse" then
							tbl15.beginImpulse = v19
						end
					end
				elseif type(v19) == "table" then
					local flag3 = rawget(v19, "RootPart") == arg and rawget(v19, "Humanoid") == arg2

					if flag3 then
						local character = localPlayer.Character
						flag3 = rawget(v19, "Character") == character
					end

					if flag3 then
						tbl15.state = v19
					elseif next(v19) == nil and movementCompat.frozen(v19) then
						n3 += 1
						tbl15.token = v19
					end
				end
			end

			local flag3 = tbl15.state and n3 == 1

			if flag3 then
				flag3 = not (tbl15.reset and tbl15.sample and tbl15.adopt and tbl15.beginImpulse)
			end

			if flag3 then
				local v19, v20, v21, v22 = fn50(v17, tbl15, n3)

				if v19 then
					tbl15.reset = v19
					tbl15.sample = v20
					tbl15.adopt = v21
					tbl15.beginImpulse = v22
					tbl15.layout = "slots-569"
				end
			end

			if tbl15.state and tbl15.reset and tbl15.sample and tbl15.adopt and tbl15.beginImpulse and n3 == 1 then
				tbl15.capabilityPath = "live-movement-dispatcher"
				handlers.movementCompatibility = "ready"
				return tbl15
			end
		end

		local v16, v17 = fn47(v13 or "waiting for live movement dispatcher")
		return v16, v17
	end

	local function fn47()
		local v12, v13 = fn33()
		return handlers.findMovementDispatcher(v12, v13)
	end

	handlers.integrityCoverage = function(arg, arg2, arg3, arg4, arg5, arg6, arg7)
		if type(arg5) ~= "table" then
			return false
		end
		local value = rawget(arg5, "OriginPosition")
		if typeof(value) ~= "Vector3" then
			return false
		end

		if (tonumber(rawget(arg5, "ExpiresAt")) or 0) - arg6 <= math.max(0.35, arg4 / arg3 + 0.1) then
			return false
		end
		local n3 = arg2.Unit * arg3

		if typeof(arg7) == "Vector3" then
			n3 = arg.AssemblyLinearVelocity + arg7 / arg.AssemblyMass
		end

		local magnitude = Vector3.new(n3.X, 0, n3.Z).Magnitude
		local n4 = tonumber(rawget(arg5, "MaxHorizontalSpeed")) or 0
		local n5 = tonumber(rawget(arg5, "MaxVerticalSpeed")) or 0
		if magnitude + 5 > n4 or math.abs(n3.Y) + 5 > n5 then
			return false
		end
		local n6 = arg.Position - value
		local n7 = arg2.Unit * arg4
		local flag3 = Vector3.new(n6.X, 0, n6.Z).Magnitude + Vector3.new(n7.X, 0, n7.Z).Magnitude + 24 < (tonumber(rawget(arg5, "MaxHorizontalDistance")) or 0)

		if flag3 then
			flag3 = n6.Y + math.max(0, n7.Y) + 6 < (tonumber(rawget(arg5, "MaxUpwardDistance")) or 0)
		end

		return flag3
	end

	fn44 = function(arg, arg2, arg3, arg4, arg5, arg6, arg7)
		if not (arg and typeof(arg2) == "Vector3" and arg2.Magnitude > 0) then
			return false
		end
		local num = tonumber(arg3)
		if not num or num ~= num or num <= 0 or num == math.huge then
			return false
		end

		if flag2 then
			return false
		end

		if not v10 and not fn43 then
			return false
		end

		if not v10 and not fn43(true) then
			return false
		end
		local v12 = v10
		local state2 = v10

		if v12 then
			state2 = v12.state
		end

		local value = state2 and rawget(state2, "Humanoid")
		if not (state2 and value and v12.beginImpulse and v12.token) then
			return false
		end

		if not localPlayer.Character or value ~= localPlayer.Character:FindFirstChildOfClass("Humanoid") then
			return false, false, "controller changed"
		end
		local flag3 = rawget(state2, "RootPart") ~= arg or rawget(state2, "Humanoid") ~= value
		local flag4

		if flag3 then
			flag4 = flag3
		else
			local parent = arg.Parent
			flag4 = rawget(state2, "Character") ~= parent
		end

		if flag4 then
			return false, false, "integrity rig mismatch"
		end
		local assemblyMass = arg.AssemblyMass
		if assemblyMass ~= assemblyMass or assemblyMass <= 0 or assemblyMass == math.huge then
			return false
		end
		local flag5 = typeof(arg5) == "Vector3"
		local flag6

		if flag5 then
			flag6 = arg5.X ~= arg5.X or arg5.Y ~= arg5.Y or arg5.Z ~= arg5.Z or math.abs(arg5.X) == math.huge or math.abs(arg5.Y) == math.huge or math.abs(arg5.Z) == math.huge
		else
			flag6 = flag5
		end

		if flag6 then
			return false, false, "invalid impulse"
		end

		if rawget(state2, "CorrectionContext") ~= nil then
			return false, false, "correcting"
		end
		local n3 = math.max(0, tonumber(arg7) or tonumber(arg4) or 0)
		if not arg6 and handlers.integrityCoverage(arg, arg2, num, n3, rawget(state2, "ImpulseContext"), os.clock(), arg5) then
			return true, true, nil
		end

		if os.clock() - n2 < 0.08 then
			return false, false, "renewing"
		end
		local ok, result = pcall(v12.beginImpulse, v12.token, state2, value.WalkSpeed, math.clamp(math.max(0, tonumber(arg4) or 0) / num + 0.75, 0.05, 5), flag5 and arg5 or arg2.Unit * num * assemblyMass, arg)
		ok = ok and result ~= nil

		if ok then
			n2 = os.clock()
		else
			flag2 = true
			v10 = nil
			state = nil
			handlers.defaultMoveFallback = true
			getgenv().__CHSAE_IntegrityState = nil
			warn("[CloverHub-SAE][integrity] registration rejected; quarantined until respawn/reload")
		end

		if ok then
			if handlers.integrityCoverage(arg, arg2, num, n3, rawget(state2, "ImpulseContext"), os.clock(), arg5) then
				return true, false, nil
			end
			return false, false, "coverage unavailable"
		end

		return false, false, "rejected"
	end

	fn43 = function(arg)
		local devChickenTween = handlers.DevChickenTween
		if arg and devChickenTween and devChickenTween.persistentAlive and devChickenTween.persistentAlive() then
			return true
		end

		if devChickenTween and devChickenTween.lease then
			if arg then
				return devChickenTween.alive(devChickenTween.lease)
			end
			devChickenTween.restore("movement guard disabled")
		end

		local genv2 = getgenv()

		if not arg then
			local chsaeIntegrityConn = genv2.__CHSAE_IntegrityConn

			if chsaeIntegrityConn then
				pcall(function()
					chsaeIntegrityConn:Disconnect()
				end)
			end

			genv2.__CHSAE_IntegrityConn = nil
			genv2.__CHSAE_IntegrityState = nil
			state = nil
			v10 = nil
			return true
		end

		if flag2 then
			handlers.defaultMoveFallback = true
			return false
		end
		local chsaeIntegrityConn = genv2.__CHSAE_IntegrityConn

		if chsaeIntegrityConn then
			pcall(function()
				chsaeIntegrityConn:Disconnect()
			end)
		end

		genv2.__CHSAE_IntegrityConn = nil

		if v10 and v10.state then
			local v12, v13 = fn33()
			local state2 = v10.state
			local flag3 = v12 and v13 and rawget(state2, "RootPart") == v12 and rawget(state2, "Humanoid") == v13

			if flag3 then
				local character = localPlayer.Character
				flag3 = rawget(state2, "Character") == character
			end

			if flag3 then
				handlers.defaultMoveFallback = false
				return true
			end
			v10 = nil
			state = nil
		end

		v10 = fn47()
		state = v10 and v10.state or nil
		handlers.defaultMoveFallback = v10 == nil
		genv2.__CHSAE_IntegrityState = state
		local str = v10

		if v10 then
			str = "ready via " .. tostring(v10.capabilityPath or "legacy-dispatcher")
		end

		str = str or "unavailable"

		if str ~= v11 then
			v11 = str

			if v10 then
				print("[CloverHub-SAE][integrity] " .. str)
			else
				warn("[CloverHub-SAE][integrity] unavailable — no live guard was invoked")
			end
		end

		return v10 ~= nil
	end

	handlers.movementInitializing = function(arg)
		local flag3 = os.clock() - (handlers.characterAddedAt or -math.huge) < 1

		if not flag3 then
			flag3 = state ~= nil and arg ~= nil and rawget(state, "Humanoid") == arg

			if flag3 then
				flag3 = (tonumber(rawget(state, "InitializingUntil")) or 0) > os.clock()
			end
		end

		return flag3
	end

	getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = localPlayer.CharacterAdded:Connect(function()
		handlers.characterAddedAt = os.clock()
		flag2 = true
		n2 = 0
		fn43(false)
		handlers.defaultMoveFallback = true
		task.wait(0.5)

		if fn() then
			flag2 = false
			local chsaeCarryRequest = getgenv().__CHSAE_CarryRequest

			if type(chsaeCarryRequest) == "table" and chsaeCarryRequest.inFlight ~= true then
				getgenv().__CHSAE_CarryRequest = nil
			end

			fn43(true)
		end
	end)
end

handlers.defaultMoveFallback = true

task.spawn(function()
	if fn() then
		fn43(true)
	end
end)

do
	local tbl15 = { tag = "PlacedTrap", hitboxes = {}, characterTouch = {} }

	pcall(function()
		tbl15.tag = require(ReplicatedStorage.Shared.Globals.Constants).TAGS_MAP.Traps.PLACED_TRAP or tbl15.tag
	end)

	local function fn45(arg)
		local parent = arg and arg.Parent

		if parent then
			local name = localPlayer.Name
			parent = arg:GetAttribute("Owner") ~= name
		end

		return parent and arg:GetAttribute("TrapActive") ~= true
	end

	local function fn46(arg, arg2)
		local hitbox = arg and arg.hitbox
		if not (hitbox and hitbox.Parent) then
			return
		end

		if arg2 then
			if not arg.suppressed then
				arg.originalCanTouch = hitbox.CanTouch
				arg.suppressed = true
			end

			hitbox.CanTouch = false
		elseif arg.suppressed then
			hitbox.CanTouch = arg.originalCanTouch ~= false
			arg.suppressed = false
		end
	end

	local function fn47(arg)
		local character = localPlayer.Character
		local flag2 = not arg

		if flag2 or tbl15.touchCharacter ~= character then
			if tbl15.touchConnection then
				tbl15.touchConnection:Disconnect()
				tbl15.touchConnection = nil
			end

			tbl15.touchCharacter = nil

			for k, v11 in pairs(tbl15.characterTouch) do
				if k and k.Parent then
					k.CanTouch = v11
				end

				tbl15.characterTouch[k] = nil
			end
		end

		if flag2 or not character or tbl15.touchCharacter == character then
			return
		end
		tbl15.touchCharacter = character

		local function fn48(descendant)
			if tbl15.touchCharacter ~= character or not fn() then
				return
			end

			if descendant:IsA("BasePart") and tbl15.characterTouch[descendant] == nil then
				tbl15.characterTouch[descendant] = descendant.CanTouch
				descendant.CanTouch = false
			end
		end

		tbl15.touchConnection = character.DescendantAdded:Connect(fn48)

		for _, descendant in ipairs(character:GetDescendants()) do
			fn48(descendant)
		end
	end

	local function fn48(arg)
		if not arg then
			return
		end
		local hitbox = arg:FindFirstChild("Hitbox")

		if not (hitbox and hitbox:IsA("BasePart")) and arg:IsA("BasePart") then
			hitbox = arg
		end

		if hitbox and hitbox:IsA("BasePart") then
			local tbl16 = { hitbox = hitbox, originalCanTouch = hitbox.CanTouch, suppressed = false }
			tbl15.hitboxes[arg] = tbl16
			fn46(tbl16, tbl2.PreventTraps and fn45(arg))
		end
	end

	for _, v11 in ipairs(CollectionService:GetTagged(tbl15.tag)) do
		fn48(v11)
	end

	getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = CollectionService:GetInstanceAddedSignal(tbl15.tag):Connect(fn48)

	getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = CollectionService:GetInstanceRemovedSignal(tbl15.tag):Connect(function(arg)
		fn46(tbl15.hitboxes[arg], false)
		tbl15.hitboxes[arg] = nil
	end)

	fn14 = function()
		for k, hitboxe in pairs(tbl15.hitboxes) do
			if not (k and k.Parent and hitboxe.hitbox and hitboxe.hitbox.Parent) then
				fn46(hitboxe, false)
				tbl15.hitboxes[k] = nil
			else
				fn46(hitboxe, tbl2.PreventTraps and fn45(k))
			end
		end

		if not tbl2.PreventTraps then
			fn47(false)
		end
	end

	getgenv().__CHSAE_TrapRestore = function()
		for _, hitboxe in pairs(tbl15.hitboxes) do
			fn46(hitboxe, false)
		end

		fn47(false)
	end

	fn14()

	getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = RunService.PreSimulation:Connect(function()
		local character = localPlayer.Character
		character = character and character:FindFirstChild("HumanoidRootPart")
		local preventTraps = tbl2.PreventTraps and critical and character
		local flag2 = false

		if preventTraps then
			for k, hitboxe in pairs(tbl15.hitboxes) do
				local hitbox = hitboxe.hitbox

				if fn45(k) and hitbox and hitbox.Parent then
					fn46(hitboxe, true)
					if ((character.Position - hitbox.Position) * Vector3.new(1, 0, 1)).Magnitude <= math.max(hitbox.Size.X, hitbox.Size.Z) * 0.5 + 24 and math.abs(character.Position.Y - hitbox.Position.Y) <= 18 then
						flag2 = true
						break
					end
				end
			end
		end

		fn47(flag2)
	end)
end

if not fn() then
	return
end

do
	local tbl15 = {
		armedUntil = 0,
		character = nil,
		ragdollSignalUntil = 0,
		ragdollSignalCharacter = nil,
		recoveryUntil = 0,
		attackTarget = nil,
		ragdollTargets = {},
		velocityCancelGeneration = 0,
		velocityCancelUntil = 0,
		velocityCancelCharacter = nil,
		baselineLinear = Vector3.zero,
		baselineAngular = Vector3.zero,
		jointReleaseGeneration = 0,
		jointReleaseQueued = false,
		velocityConnections = {},
	}

	local chsaeGuardDiagnostics = {
		ForestArms = 0,
		RagdollSignalArms = 0,
		RagdollsSeen = 0,
		Suppressed = 0,
		Passed = 0,
		LastReason = "idle",
		LastImpulseMagnitude = 0,
		LastSignalRemaining = 0,
		RagdollTarget = "unavailable",
		VelocityCancels = 0,
		MaxCancelledVelocity = 0,
		PhysicsSeen = 0,
		StateRecoveries = 0,
		LastRecoveredState = "none",
		JointReleases = 0,
	}

	getgenv().__CHSAE_GuardDiagnostics = chsaeGuardDiagnostics

	pcall(function()
		tbl15.ragdollJoints = require(ReplicatedStorage.Shared.Modules.RagdollJoints)
	end)

	handlers.guardProtectionActive = function()
		return false
	end

	local function fn45()
		tbl15.armedUntil = 0
		tbl15.character = nil
		tbl15.ragdollSignalUntil = 0
		tbl15.ragdollSignalCharacter = nil
	end

	local function fn46()
		tbl15.velocityCancelGeneration = tbl15.velocityCancelGeneration + 1
		tbl15.recoveryUntil = 0
		tbl15.velocityCancelUntil = 0
		tbl15.velocityCancelCharacter = nil
		tbl15.jointReleaseQueued = false

		for _, velocityConnection in ipairs(tbl15.velocityConnections) do
			pcall(function()
				velocityConnection:Disconnect()
			end)
		end

		table.clear(tbl15.velocityConnections)
	end

	tbl15.stopActive = function()
		fn45()
		fn46()
	end

	local stopActive = tbl15.stopActive
	getgenv().__CHSAE_GuardStopActive = stopActive

	local function fn47(velocityCancelCharacter, arg)
		local function fn48()
			return tbl2.GuardProtection
		end

		if not (fn() and velocityCancelCharacter and fn48()) then
			return
		end
		local humanoidRootPart = velocityCancelCharacter:FindFirstChild("HumanoidRootPart")
		local humanoid = velocityCancelCharacter:FindFirstChildOfClass("Humanoid")
		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoid) then
			return
		end
		local n2 = math.clamp(tonumber(arg) or 0.85, 0.25, 3.5)
		fn46()
		tbl15.velocityCancelGeneration = tbl15.velocityCancelGeneration + 1
		local velocityCancelGeneration = tbl15.velocityCancelGeneration
		tbl15.jointReleaseQueued = false
		tbl15.recoveryUntil = os.clock() + n2
		tbl15.velocityCancelUntil = os.clock() + math.min(n2, 0.22)
		tbl15.velocityCancelCharacter = velocityCancelCharacter
		tbl15.baselineLinear = humanoidRootPart.AssemblyLinearVelocity
		tbl15.baselineAngular = humanoidRootPart.AssemblyAngularVelocity
		local tbl16 = {}

		for _, descendant in ipairs(velocityCancelCharacter:GetDescendants()) do
			tbl16[descendant] = true
		end

		local flag2 = false

		local function fn49()
			if flag2 or velocityCancelGeneration ~= tbl15.velocityCancelGeneration then
				return
			end
			local flag3 = fn() and fn48()

			if flag3 then
				local recoveryUntil = tbl15.recoveryUntil
				flag3 = os.clock() <= recoveryUntil
			end

			if not (flag3 and localPlayer.Character == velocityCancelCharacter and humanoidRootPart.Parent == velocityCancelCharacter) then
				return
			end
			flag2 = true

			pcall(function()
				humanoid.PlatformStand = false

				if tbl15.jointReleaseGeneration ~= velocityCancelGeneration then
					local flag4 = false

					for k in pairs(tbl16) do
						if k:GetAttribute("RagdollConstraint") ~= nil or k:IsA("Motor6D") and not k.Enabled then
							flag4 = true
							break
						end
					end

					if flag4 and type(tbl15.ragdollJoints) == "table" and type(tbl15.ragdollJoints.Release) == "function" then
						if pcall(tbl15.ragdollJoints.Release, velocityCancelCharacter) then
							tbl15.jointReleaseGeneration = velocityCancelGeneration
							chsaeGuardDiagnostics.JointReleases = chsaeGuardDiagnostics.JointReleases + 1
						end
					end
				end

				local state2 = humanoid:GetState()

				if state2 == Enum.HumanoidStateType.Physics or state2 == Enum.HumanoidStateType.Ragdoll or state2 == Enum.HumanoidStateType.FallingDown or state2 == Enum.HumanoidStateType.PlatformStanding then
					chsaeGuardDiagnostics.StateRecoveries = chsaeGuardDiagnostics.StateRecoveries + 1
					chsaeGuardDiagnostics.LastRecoveredState = state2.Name
					pcall(humanoid.ChangeState, humanoid, Enum.HumanoidStateType.Running)
				end

				local velocityCancelUntil = tbl15.velocityCancelUntil

				if os.clock() <= velocityCancelUntil then
					local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity

					if (assemblyLinearVelocity - tbl15.baselineLinear).Magnitude > 0.05 or (humanoidRootPart.AssemblyAngularVelocity - tbl15.baselineAngular).Magnitude > 0.05 then
						chsaeGuardDiagnostics.VelocityCancels = chsaeGuardDiagnostics.VelocityCancels + 1
						chsaeGuardDiagnostics.MaxCancelledVelocity = math.max(chsaeGuardDiagnostics.MaxCancelledVelocity, assemblyLinearVelocity.Magnitude)
						humanoidRootPart.AssemblyLinearVelocity = tbl15.baselineLinear
						humanoidRootPart.AssemblyAngularVelocity = tbl15.baselineAngular
					end
				end
			end)

			flag2 = false
		end

		tbl15.velocityConnections[#tbl15.velocityConnections + 1] = humanoid.StateChanged:Connect(function(old, new)
			if new == Enum.HumanoidStateType.Physics or new == Enum.HumanoidStateType.Ragdoll or new == Enum.HumanoidStateType.FallingDown or new == Enum.HumanoidStateType.PlatformStanding then
				chsaeGuardDiagnostics.PhysicsSeen = chsaeGuardDiagnostics.PhysicsSeen + 1
				fn49()
			end
		end)

		tbl15.velocityConnections[#tbl15.velocityConnections + 1] = velocityCancelCharacter.DescendantAdded:Connect(function(descendant)
			tbl16[descendant] = true
			if descendant:GetAttribute("RagdollConstraint") == nil or tbl15.jointReleaseQueued then
				return
			end
			tbl15.jointReleaseQueued = true

			task.defer(function()
				if velocityCancelGeneration ~= tbl15.velocityCancelGeneration then
					return
				end
				tbl15.jointReleaseQueued = false
				tbl15.jointReleaseGeneration = 0
				fn49()
			end)
		end)

		tbl15.velocityConnections[#tbl15.velocityConnections + 1] = velocityCancelCharacter.DescendantRemoving:Connect(function(descendant)
			tbl16[descendant] = nil
		end)

		tbl15.velocityConnections[#tbl15.velocityConnections + 1] = humanoidRootPart:GetPropertyChangedSignal("AssemblyLinearVelocity"):Connect(fn49)
		tbl15.velocityConnections[#tbl15.velocityConnections + 1] = RunService.PreSimulation:Connect(fn49)
		tbl15.velocityConnections[#tbl15.velocityConnections + 1] = RunService.PostSimulation:Connect(fn49)
		fn49()

		task.delay(n2 + 0.05, function()
			if velocityCancelGeneration == tbl15.velocityCancelGeneration then
				fn46()
			end
		end)
	end

	local function fn48()
		if not (fn() and tbl2.GuardProtection) then
			return
		end
		local serverTimeNow = workspace:GetServerTimeNow()
		local n2 = tonumber(localPlayer:GetAttribute("RagdollEndTime")) or 0
		local now3 = os.clock()
		if n2 <= serverTimeNow then
			return
		end
		local lastSignalRemaining = n2 - serverTimeNow
		local n3 = math.clamp(lastSignalRemaining + 0.35, 0.45, 3.5)
		tbl15.ragdollSignalCharacter = localPlayer.Character
		tbl15.ragdollSignalUntil = now3 + n3
		fn47(localPlayer.Character, n3)
		chsaeGuardDiagnostics.RagdollSignalArms = chsaeGuardDiagnostics.RagdollSignalArms + 1
		chsaeGuardDiagnostics.LastReason = "ragdoll-signal-armed"
		chsaeGuardDiagnostics.LastSignalRemaining = lastSignalRemaining
	end

	local connection = localPlayer:GetAttributeChangedSignal("RagdollEndTime"):Connect(fn48)
	local chsaeRuntimeConns = getgenv().__CHSAE_RuntimeConns

	if type(chsaeRuntimeConns) == "table" then
		chsaeRuntimeConns[#chsaeRuntimeConns + 1] = connection
	end

	local n2 = tonumber(localPlayer:GetAttribute("RagdollEndTime")) or 0

	if workspace:GetServerTimeNow() < n2 then
		fn48()
	end

	tbl15.attackBindings = {}
	tbl15.attackDisplaced = setmetatable({}, { __mode = "k" })
	tbl15.attackBindingStopped = false

	tbl15.liveForestGuard = function()
		local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
		world = world and world:FindFirstChild("Areas")
		local guardAreas = world and world:FindFirstChild("GuardAreas")
		guardAreas = guardAreas and guardAreas:FindFirstChild("Forest")
		guardAreas = guardAreas and guardAreas:FindFirstChild("Guard")
		return guardAreas and guardAreas:IsA("Model") and guardAreas or nil
	end

	tbl15.isLiveAttackComponent = function(arg, arg2)
		if type(arg) ~= "table" or not arg2 or rawget(arg, "_areaId") ~= "Forest" or rawget(arg, "_guardModel") ~= arg2 then
			return false
		end
		local value = rawget(arg, "_root")
		return typeof(value) == "Instance" and value:IsA("BasePart") and value:IsDescendantOf(arg2) and arg2:IsDescendantOf(workspace)
	end

	tbl15.restoreAttackBindings = function()
		tbl15.attackBindingStopped = true

		if tbl15.attackBindingConnection then
			tbl15.attackBindingConnection:Disconnect()
			tbl15.attackBindingConnection = nil
		end

		for k, attackBinding in pairs(tbl15.attackBindings) do
			local wrapper = attackBinding.wrapper

			if rawget(k, "_attackHandler") == wrapper then
				rawset(k, "_attackHandler", attackBinding.original)
			end

			tbl15.attackBindings[k] = nil
		end

		chsaeGuardDiagnostics.ForestAttackBinding = "stopped"
	end

	tbl15.reconcileAttackBindings = function()
		if tbl15.attackBindingStopped or not fn() then
			return false
		end
		local v11 = tbl15.liveForestGuard()
		local flag2 = false

		for k, attackBinding in pairs(tbl15.attackBindings) do
			local value = rawget(k, "_attackHandler")

			if tbl15.isLiveAttackComponent(k, v11) and value == attackBinding.wrapper then
				flag2 = true
			else
				if value == attackBinding.wrapper then
					rawset(k, "_attackHandler", attackBinding.original)
				else
					tbl15.attackDisplaced[k] = true
				end

				tbl15.attackBindings[k] = nil
			end
		end

		if flag2 then
			chsaeGuardDiagnostics.ForestAttackBinding = "live component"
			return true
		end
		chsaeGuardDiagnostics.ForestAttackBinding = "waiting for live Forest component"
		if not v11 then
			return false
		end
		local table_, v12 = handlers.MovementCompat.filter("table", { Keys = { "_attackHandler", "_areaId", "_guardModel", "_root" } })

		if not table_ and v12 then
			chsaeGuardDiagnostics.ForestAttackBinding = v12
		end

		if type(table_) ~= "table" or not fn() or tbl15.attackBindingStopped then
			return false
		end
		local tbl16

		for _, v13 in ipairs(table_) do
			if tbl15.isLiveAttackComponent(v13, v11) and not tbl15.attackDisplaced[v13] then
				local value = rawget(v13, "_attackHandler")
				if type(value) ~= "function" then
					continue
				end

				tbl16 = {
					original = value,
					wrapper = function(arg, ...)
						local flag3 = not tbl15.attackBindingStopped and fn() and tbl2.GuardProtection and type(arg) == "table" and arg.Player == localPlayer and arg.EggUid ~= nil

						if flag3 then
							local wrapper = tbl16.wrapper
							flag3 = rawget(v13, "_attackHandler") == wrapper
						end

						if flag3 and tbl15.isLiveAttackComponent(v13, tbl15.liveForestGuard()) then
							pcall(function()
								tbl15.character = localPlayer.Character
								tbl15.armedUntil = os.clock() + 2
								fn47(localPlayer.Character, 2.35)
								chsaeGuardDiagnostics.ForestArms = chsaeGuardDiagnostics.ForestArms + 1
								chsaeGuardDiagnostics.LastReason = "forest-armed"
							end)
						end

						local pack = table.pack
						local v14 = table.pack(...)
						local v15 = value
						v14.n = 2 + v14.n - 1
						table.move(v14, 1, v14.n, 2, v14)
						v14[1] = arg
						local v16 = pack(v15(table.unpack(v14, 1, v14.n)))
						return table.unpack(v16, 1, v16.n)
					end,
				}

				if fn() and not tbl15.attackBindingStopped and tbl15.liveForestGuard() == v11 and rawget(v13, "_attackHandler") == value then
					rawset(v13, "_attackHandler", tbl16.wrapper)
					tbl15.attackBindings[v13] = tbl16
					chsaeGuardDiagnostics.ForestAttackBinding = "live component"
					return true
				end
			end
		end

		return false
	end

	local function chsaeGuardRestore()
		tbl15.stopActive()
		tbl15.restoreAttackBindings()

		if type(restorefunction) == "function" then
			if type(tbl15.attackTarget) == "function" then
				pcall(restorefunction, tbl15.attackTarget)
			end

			for _, ragdollTarget in ipairs(tbl15.ragdollTargets) do
				if type(ragdollTarget) == "function" then
					pcall(restorefunction, ragdollTarget)
				end
			end
		end

		tbl15.attackTarget = nil
		table.clear(tbl15.ragdollTargets)

		if getgenv().__CHSAE_GuardDiagnostics == chsaeGuardDiagnostics then
			getgenv().__CHSAE_GuardDiagnostics = nil
		end

		local stopActive2 = tbl15.stopActive

		if getgenv().__CHSAE_GuardStopActive == stopActive2 then
			getgenv().__CHSAE_GuardStopActive = nil
		end
	end

	if not fn() then
		return
	end

	if getgenv().__CHSAE_GuardRestore then
		pcall(getgenv().__CHSAE_GuardRestore)
	end

	getgenv().__CHSAE_GuardRestore = chsaeGuardRestore
	local flag2 = false
	local flag3 = false

	local function fn49()
		if flag2 or flag3 or not fn() then
			return
		end
		flag2 = true

		task.defer(function()
			for i = 1, 4 do
				if not (flag3 or not fn()) then
					if not (tbl15.reconcileAttackBindings() or not tbl15.liveForestGuard()) then
						if i < 4 then
							task.wait(0.25)
						end

						continue
					end
				end

				break
			end

			flag2 = false
		end)
	end

	local function fn50(descendant)
		if descendant.Name == "Guard" and descendant:IsA("Model") and descendant.Parent and descendant.Parent.Name == "Forest" then
			fn49()
		end
	end

	local connection2 = workspace.DescendantAdded:Connect(fn50)
	local connection3 = workspace.DescendantRemoving:Connect(fn50)

	tbl15.attackBindingConnection = { Disconnect = function()
		flag3 = true
		connection2:Disconnect()
		connection3:Disconnect()
	end }

	fn49()
	local chsaeRuntimeConns2 = getgenv().__CHSAE_RuntimeConns

	if type(chsaeRuntimeConns2) == "table" then
		chsaeRuntimeConns2[#chsaeRuntimeConns2 + 1] = tbl15.attackBindingConnection
	end

	local ok, result = pcall(function()
		if type(filtergc) ~= "function" then
			return nil
		end
		return filtergc("function", { Constants = { "Ragdoll duration must be non-negative" } }, false)
	end)

	local tbl16

	if ok and type(result) == "function" then
		tbl16 = { result }
	else
		tbl16 = result
	end

	if ok and type(tbl16) == "table" and type(hookfunction) == "function" then
		local tbl17 = {}

		for _, v11 in ipairs(tbl16) do
			local v12 = v11

			if type(v12) == "function" and not tbl17[v12] then
				tbl17[v12] = true
				local v13 = nil

				if pcall(function()
					v13 = hookfunction(v12, function(arg, arg2, arg3)
						local now3 = os.clock()
						local character = localPlayer.Character
						local flag4 = character ~= nil
						local flag5 = flag4 and character == tbl15.character and now3 <= tbl15.armedUntil
						local flag6 = flag4 and character == tbl15.ragdollSignalCharacter and now3 <= tbl15.ragdollSignalUntil

						if flag4 and not flag6 then
							flag6 = (tonumber(localPlayer:GetAttribute("RagdollEndTime")) or 0) > workspace:GetServerTimeNow()
						end

						local flag7 = fn() and tbl2.GuardProtection and flag4 and handlers.adminMonsterActive ~= true and (flag5 or flag6)

						if flag4 then
							chsaeGuardDiagnostics.RagdollsSeen = chsaeGuardDiagnostics.RagdollsSeen + 1
							chsaeGuardDiagnostics.LastImpulseMagnitude = typeof(arg3) == "Vector3" and arg3.Magnitude or 0
						end

						if flag7 then
							local n3 = math.clamp(tonumber(arg2) or 0.85, 0.45, 3.5)
							local n4

							if flag6 then
								n4 = math.max(n3, tbl15.ragdollSignalUntil - now3)
							else
								n4 = n3
							end

							fn47(character, n4)

							if flag5 then
								tbl15.armedUntil = 0
								tbl15.character = nil
							end

							chsaeGuardDiagnostics.Suppressed = chsaeGuardDiagnostics.Suppressed + 1
							chsaeGuardDiagnostics.LastReason = flag5 and "forest-suppressed" or "ragdoll-signal-suppressed"
							local humanoid = character:FindFirstChildOfClass("Humanoid")

							if humanoid then
								humanoid.PlatformStand = false
								local physics = Enum.HumanoidStateType.Physics

								if humanoid:GetState() == physics then
									pcall(humanoid.ChangeState, humanoid, Enum.HumanoidStateType.Running)
								end
							end

							chsaeGuardDiagnostics.NativeRecoveryActions = (chsaeGuardDiagnostics.NativeRecoveryActions or 0) + 1
							return v13(arg, arg2, Vector3.zero)
						end

						if flag4 then
							chsaeGuardDiagnostics.Passed = chsaeGuardDiagnostics.Passed + 1
							chsaeGuardDiagnostics.LastReason = "ragdoll-passed"
						end

						return v13(arg, arg2, arg3)
					end)
				end) then
					tbl15.ragdollTargets[#tbl15.ragdollTargets + 1] = v12
					handlers.hookedRagdollTargets = handlers.hookedRagdollTargets or {}
					handlers.hookedRagdollTargets[v12] = true
				end
			end
		end

		if #tbl15.ragdollTargets > 0 then
			chsaeGuardDiagnostics.RagdollTarget = ("RigDriver x%d"):format(#tbl15.ragdollTargets)
		end
	end

	if #tbl15.ragdollTargets == 0 then
		warn("[CloverHub-SAE] Guard Protection controller hooks unavailable")
	end
end

handlers.guardRouteRandom = Random.new()

handlers.wallSpacingInsets = function()
	return 28, 36
end

handlers.guardRoutePoints = function(arg, arg2, arg3, arg4)
	local flag2 = not (arg and arg2)
	local flag3

	if flag2 then
		flag3 = flag2
	else
		flag3 = math.abs(arg2.X - arg.X) < (arg4 and 1 or 80)
	end

	if flag3 then
		return {}
	end
	local guardRouteRandom = handlers.guardRouteRandom
	local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
	world = world and world:FindFirstChild("Areas")
	world = world and world:FindFirstChild("GuardAreas")
	if not world then
		return {}
	end
	local huge = math.huge
	local n2 = -math.huge
	local v11 = ipairs
	local children = arg4 and { arg4.Parent } or world:GetChildren()

	for _, child in v11(children) do
		local bounds = child:FindFirstChild("Bounds")

		if bounds and bounds:IsA("BasePart") then
			huge = math.min(huge, bounds.Position.Z - bounds.Size.Z * 0.5)
			n2 = math.max(n2, bounds.Position.Z + bounds.Size.Z * 0.5)
		end
	end

	if huge == math.huge then
		return {}
	end
	local n3 = arg2.X >= arg.X and 1 or -1
	local v12, v13 = handlers.wallSpacingInsets()
	local n4 = (huge + n2) * 0.5
	local activeGuardAreaId = handlers.movementPhase == "return" and (arg3 ~= nil and tostring(arg3) or handlers.activeGuardAreaId) or nil
	local v14 = activeGuardAreaId and world:FindFirstChild(tostring(activeGuardAreaId))
	local flag4 = not arg4
	local guard = flag4 and v14 and v14:FindFirstChild("Guard")
	local primaryPart = guard and (guard.PrimaryPart or guard:FindFirstChild("HumanoidRootPart", true))

	if flag4 and handlers.movementPhase == "return" and not primaryPart then
		handlers.guardRoutePlanSequence = (handlers.guardRoutePlanSequence or 0) + 1

		handlers.lastGuardRoutePlan = {
			Sequence = handlers.guardRoutePlanSequence,
			Phase = "return",
			ActiveAreaId = activeGuardAreaId,
			MissingTargetGuard = true,
			PointCount = 0,
			SideSignature = "",
		}

		return {}
	end

	local flag5

	if primaryPart then
		flag5 = primaryPart.Position.Z < n4
	else
		flag5 = guardRouteRandom:NextNumber() < 0.5
	end

	local function fn45(arg5)
		return arg5 and n2 - guardRouteRandom:NextNumber(v12, v13) or huge + guardRouteRandom:NextNumber(v12, v13)
	end

	local n5 = math.abs(arg2.X - arg.X)
	local n6 = math.max(0, n5 - math.min(n5 * 0.22, guardRouteRandom:NextNumber(70, 125)))
	local n7 = math.min(n6, guardRouteRandom:NextNumber(65, 110))
	local n8 = math.min(n6, math.max(n7, math.min(650, n6 * 0.75)))
	local tbl15 = {}
	local x = arg.X

	local function fn46(arg5, arg6)
		local max = math.max
		local x2 = arg.X
		local x3 = arg2.X
		local n9 = math.clamp(arg5, math.min(arg.X, arg2.X), max(x2, x3))
		if n3 > 0 and n9 <= x + 1 or n3 < 0 and n9 >= x - 1 then
			return
		end
		tbl15[#tbl15 + 1] = Vector3.new(n9, arg.Y, arg6)
		x = n9
	end

	if n7 > 5 then
		local n9 = arg.X + n3 * n7
		local v15 = fn45(flag5)
		fn46(n9, v15)
	end

	local n9 = math.max(0, n6 - n7)
	local n10 = n9 >= 80 and math.clamp(math.floor(n9 / guardRouteRandom:NextNumber(360, 620)), 1, 5) or 0

	for i = 1, n10 do
		local n11 = n7 + n9 * math.clamp(i / (n10 + 1) + guardRouteRandom:NextNumber(-0.22, 0.22) / (n10 + 1), 0.05, 0.95)

		if n11 >= n8 and guardRouteRandom:NextNumber() < 0.62 then
			flag5 = not flag5
		end

		local n12 = arg.X + n3 * n11
		local v15 = fn45(flag5)
		fn46(n12, v15)
	end

	if n9 > 30 then
		if n6 >= n8 and guardRouteRandom:NextNumber() < 0.35 then
			flag5 = not flag5
		end

		local n11 = arg.X + n3 * n6
		local v15 = fn45(flag5)
		fn46(n11, v15)
	end

	local tbl16 = {}

	for _, v15 in ipairs(tbl15) do
		tbl16[#tbl16 + 1] = v15.Z >= n4 and "T" or "B"
	end

	handlers.guardRoutePlanSequence = (handlers.guardRoutePlanSequence or 0) + 1

	handlers.lastGuardRoutePlan = {
		Sequence = handlers.guardRoutePlanSequence,
		Phase = handlers.movementPhase,
		ActiveAreaId = activeGuardAreaId,
		ActiveGuardState = guard and guard:GetAttribute("GuardState") or nil,
		SwitchClearance = n8,
		PointCount = #tbl15,
		SideSignature = table.concat(tbl16),
	}

	return tbl15
end

handlers.centeredStealReturnTo = function(arg, arg2, arg3, arg4)
	local devChickenTween = handlers.DevChickenTween
	if not devChickenTween then
		return false, "shared delivery controller unavailable"
	end
	local v11, v12 = devChickenTween.begin(true)
	if not v11 then
		return false, v12
	end
	return devChickenTween.returnHome(arg2, arg3, arg4)
end

handlers.settleClaimAtTrackStart = function(arg, arg2)
	arg = type(arg) == "function" and arg or fn
	local v11 = arg2 or handlers.getTrackStart()
	if not (v11 and v11:IsA("BasePart")) then
		return false
	end
	local n2 = v11.Position + Vector3.new(0, 3, 0)
	local n3 = 0.08

	pcall(function()
		n3 = math.max(0, Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) / 1000
	end)

	local n4 = math.clamp(n3 * 1.5 + 0.04, 0.12, 0.3)
	local n5 = os.clock() + math.clamp(n4 + 0.35, 0.55, 0.8)
	local v12 = nil

	while fn() and arg() and os.clock() < n5 do
		local v13, v14 = fn33()
		if not v13 or v14 and v14.Health <= 0 then
			return false
		end

		if ((v13.Position - n2) * Vector3.new(1, 0, 1)).Magnitude > 1.5 then
			if tbl14.owner ~= "Steal" then
				local progressionTweenTo = handlers.progressionTweenTo
				if not progressionTweenTo then
					return false, "Tween controller starting"
				end
				local v15, v16 = progressionTweenTo(tbl14.owner, n2, 1.5, arg)
				v12 = nil
				if not v15 then
					return false, v16
				end
				continue
			end

			local devChickenTween = handlers.DevChickenTween
			local lease = devChickenTween and devChickenTween.lease
			if not (devChickenTween and devChickenTween.begin(true)) then
				return false
			end
			local v15 = devChickenTween.groundMove(n2, 1.5, arg, nil, nil, handlers.getDeliverySpeed())
			local flag2 = lease ~= nil or devChickenTween.restore("claim settled")
			flag2 = v15 and flag2
			v12 = nil
			if not flag2 then
				return false
			end
			continue
		end

		local now3 = v12 or os.clock()
		if n4 <= os.clock() - now3 then
			return true
		end
		RunService.Heartbeat:Wait()
		v12 = now3
	end

	local v13 = fn33()
	return fn() and arg() and v13 ~= nil and ((v13.Position - n2) * Vector3.new(1, 0, 1)).Magnitude <= 3
end

local tbl15

tbl15 = {
	treadmillSuppressed = false,
	placePending = false,
	eventPending = false,
	treadmillBlockedUntil = 0,
	treadmillIdleSince = 0,
	placeBeat = 0,
	PLACE_STALE = 8,
	refreshEventPending = function(arg)
		if arg ~= nil then
			handlers.greatBloomBodyPending = arg == true
		end

		tbl15.eventPending = handlers.greatBloomBodyPending == true or handlers.greatBloomUnlockReturnPending == true or handlers.adminEventPending == true or handlers.scrambleBossPending == true
		return tbl15.eventPending
	end,
	blockTreadmill = function(arg)
		tbl15.treadmillBlockedUntil = math.max(tonumber(tbl15.treadmillBlockedUntil) or 0, os.clock() + math.max(0, tonumber(arg) or 0))
		tbl15.treadmillIdleSince = 0
	end,
}

local v11
v11 = progression:AddLeftGroupbox("🏡 Pen")

do
	local PenProgressStatusLabel = nil

	chk.Merge(v11, function()
		PenProgressStatusLabel = v11:AddLabel("PenProgressStatusLabel", { Text = "💤 Progression standby", DoesWrap = true })
	end)

	local function fn45(arg)
		handlers.setLabel(PenProgressStatusLabel, arg)
	end

	local tbl16 = nil
	local tbl17 = nil
	local tbl18 = nil
	local tbl19 = nil
	local tbl20 = nil
	local tbl21 = nil

	pcall(function()
		local v12 = GetSaveModule()
		local BaseUpgrade = require(ReplicatedStorage.Client.BaseUpgrade)
		local Remotes = require(ReplicatedStorage.Shared.Remotes)
		local PlotState = require(ReplicatedStorage.Client.PlotState)

		tbl16 = { Get = function()
			return v12.Get()
		end }

		tbl17 = {
			GetNextConfig = BaseUpgrade.ResolveNextTier,
			CanAffordNext = BaseUpgrade.IsNextTierAffordable,
			RequestCashUpgrade = BaseUpgrade.PurchaseNextTier,
		}

		tbl18 = { Invoke = function(arg, ...)
			return arg:InvokeServer(...)
		end }

		tbl19 = { GetMySlot = PlotState.ResolveLocalSlot }
		tbl20 = { REQUEST_REDEEM = Remotes.AwayEarnings.AskCollect }
		tbl21 = { REQUEST_CLAIM_ALL = Remotes.Codex.AskRedeemAll }
	end)

	v11:AddToggle("AutoUpgradePenToggle", {
		Text = "Upgrade Pen",
		Default = tbl2.AutoUpgradePen,
		Tooltip = "Buy affordable pen upgrades.",
	}):OnChanged(function(autoUpgradePen)
		tbl2.AutoUpgradePen = autoUpgradePen
		fn45(autoUpgradePen and "🟡 Watching pen upgrades" or "💤 Progression standby")
		tbl.WakeIdleWorkers("pen-toggle")
	end)

	v11:AddToggle("AutoCollectCashToggle", {
		Text = "Collect Cash",
		Default = tbl2.AutoCollectCash,
		Tooltip = "Collect cash from your pen.",
	}):OnChanged(function(autoCollectCash)
		tbl2.AutoCollectCash = autoCollectCash

		if autoCollectCash then
			fn45("🟡 Watching pen cash")
		end

		tbl.WakeIdleWorkers("cash-toggle")
	end)

	v11:AddToggle("AutoClaimIndexToggle", {
		Text = "Claim Index",
		Default = tbl2.AutoClaimIndex,
		Tooltip = "Claim completed Index rewards.",
	}):OnChanged(function(autoClaimIndex)
		tbl2.AutoClaimIndex = autoClaimIndex

		if autoClaimIndex then
			fn45("🟡 Watching Index rewards")
		end

		tbl.WakeIdleWorkers("index-toggle")
	end)

	local function fn46()
		if not tbl19 then
			return false
		end
		local v12 = tbl19.GetMySlot()
		local plots = workspace:FindFirstChild("Plots")
		local v13 = v12 and plots and plots:FindFirstChild(tostring(v12))
		return v13 and v13:FindFirstChild("LocalOfflineMoneyClaim") ~= nil
	end

	task.spawn(function()
		while fn() do
			local ok, result = pcall(function()
				local n2 = 0
				local n3 = 0
				local n4 = 0

				while fn() do
					if not (tbl2.AutoUpgradePen or tbl2.AutoCollectCash or tbl2.AutoClaimIndex) then
						tbl.IdleWorkerWake.Event:Wait()
					else
						local now3 = os.clock()

						if tbl2.AutoUpgradePen and now3 >= n2 then
							n2 = now3 + 4

							if not (tbl16 and tbl17) then
								fn45("⚠️ Pen upgrade unavailable")
							elseif tbl14.backgroundOk() then
								local ok, result = pcall(tbl16.Get)
								local v12 = nil
								local v13 = nil

								if ok and type(result) == "table" then
									pcall(function()
										local v14, v15 = tbl17.GetNextConfig(result)
										v12 = v14
										v13 = v15
									end)
								end

								if not v12 or not v13 then
									fn45("✅ Pen is max level")
								else
									local flag2 = false

									pcall(function()
										flag2 = tbl17.CanAffordNext(result) == true
									end)

									if flag2 then
										local ok2, result2 = pcall(tbl17.RequestCashUpgrade)
										fn45(ok2 and result2 and "🟢 Pen upgrade purchased" or "🟡 Pen upgrade retrying")
									else
										fn45("🟡 Saving for pen level " .. tostring(v12))
									end
								end
							end
						end

						if tbl2.AutoCollectCash and now3 >= n3 then
							n3 = now3 + 6

							if fn46() and tbl18 and tbl20 and tbl20.REQUEST_REDEEM and tbl14.backgroundOk() then
								local ok, result, result2, result3 = pcall(tbl18.Invoke, tbl20.REQUEST_REDEEM, { Kind = "Claim" })

								if ok and result == true then
									local num = type(result3) == "table" and tonumber(result3.AwardedAmount) or nil
									fn45(num and num > 0 and "💰 Collected $" .. fn3(num) or "💰 Pen cash collected")
								end
							end
						end

						if tbl2.AutoClaimIndex and now3 >= n4 then
							n4 = now3 + 15

							if tbl18 and tbl21 and tbl21.REQUEST_CLAIM_ALL and tbl14.backgroundOk() then
								local ok, result, result2, result3 = pcall(tbl18.Invoke, tbl21.REQUEST_CLAIM_ALL)

								if ok and result == true and type(result3) == "table" and next(result3) ~= nil then
									fn45("🎁 Index rewards claimed")
								end
							end
						end

						task.wait(0.5)
					end
				end
			end)

			if not (ok or not fn()) then
				warn("[CloverHub-SAE][pen] worker recovered: " .. tostring(result))
				task.wait(1)
				continue
			end

			break
		end
	end)
end

local v12
v12 = progression:AddRightGroupbox("🏃 Treadmill")

do
	local TreadmillStatusLabel = nil
	local TreadmillUpgradeStatusLabel = nil

	chk.Merge(v12, function()
		TreadmillStatusLabel = v12:AddLabel("TreadmillStatusLabel", { Text = "🔴 Off", DoesWrap = true })
		TreadmillUpgradeStatusLabel = v12:AddLabel("TreadmillUpgradeStatusLabel", { Text = "💤 Upgrade standby", DoesWrap = true })
	end)

	local function fn45(arg)
		handlers.setLabel(TreadmillStatusLabel, arg)
	end

	local function fn46(arg)
		handlers.setLabel(TreadmillUpgradeStatusLabel, arg)
	end

	local tbl16 = nil
	local tbl17 = nil
	local Treadmills = nil
	local tbl18 = nil
	local tbl19 = nil

	pcall(function()
		local Remotes = require(ReplicatedStorage.Shared.Remotes)
		local v13 = GetSaveModule()
		local PlotState = require(ReplicatedStorage.Client.PlotState)

		tbl16 = {
			Invoke = function(arg, ...)
				return arg:InvokeServer(...)
			end,
			Fired = function(arg)
				return arg.OnClientEvent
			end,
		}

		tbl17 = {
			REQUEST_UNEQUIP = Remotes.Treadmill.AskDoff,
			REQUEST_UPGRADE = Remotes.Treadmill.AskTierRaise,
			ACTIVE_TREADMILL_EVENT = Remotes.Treadmill.RenderStateShifted,
		}

		Treadmills = require(ReplicatedStorage.Data.Treadmills)

		tbl18 = { Get = function()
			return v13.Get()
		end }

		tbl19 = { GetMySlot = PlotState.ResolveLocalSlot }
	end)

	local chsaeTreadmillActiveId = rawget(getgenv(), "__CHSAE_TreadmillActiveId")
	local str = "__physical_treadmill__"
	local n2 = 0
	local n3 = 0

	handlers.adminTreadmillPart = function()
		local adminTreadmill = workspace:FindFirstChild("AdminTreadmill")
		if not adminTreadmill then
			return nil
		end
		local belt001 = adminTreadmill:FindFirstChild("Belt.001", true) or adminTreadmill:FindFirstChild("BoundingBoxPart") or adminTreadmill:FindFirstChild("Root")
		return belt001 and belt001:IsA("BasePart") and belt001 or nil
	end

	handlers.adminTreadmillTarget = function()
		local adminTreadmill = workspace:FindFirstChild("AdminTreadmill")
		local boundingBoxPart = adminTreadmill and adminTreadmill:FindFirstChild("BoundingBoxPart")

		if boundingBoxPart and boundingBoxPart:IsA("BasePart") then
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { adminTreadmill }
			raycastParams.RespectCanCollide = true
			local hit = workspace:Raycast(boundingBoxPart.Position + Vector3.new(0, boundingBoxPart.Size.Y / 2 + 10, 0), Vector3.new(0, -(boundingBoxPart.Size.Y + 20), 0), raycastParams)
			if hit then
				return hit.Position + Vector3.new(0, 3, 0)
			end
		end

		local v13 = handlers.adminTreadmillPart()
		return v13 and v13.Position + Vector3.new(0, 3, 0) or nil
	end

	handlers.onAdminTreadmill = function(arg)
		local adminTreadmill = workspace:FindFirstChild("AdminTreadmill")
		adminTreadmill = adminTreadmill and adminTreadmill:FindFirstChild("BoundingBoxPart")
		if not (arg and adminTreadmill and adminTreadmill:IsA("BasePart")) then
			return false
		end
		local v13 = adminTreadmill.CFrame:PointToObjectSpace(arg.Position)
		local n4 = adminTreadmill.Size / 2 + Vector3.new(4, 8, 4)
		local x = n4.X
		local flag2 = math.abs(v13.X) <= x

		if flag2 then
			local y = n4.Y
			flag2 = math.abs(v13.Y) <= y
		end

		if flag2 then
			local z = n4.Z
			flag2 = math.abs(v13.Z) <= z
		end

		return flag2
	end

	local function fn47()
		local v13 = fn33()
		if not v13 or not v13.Anchored or v13.AssemblyMass ~= math.huge then
			return false
		end

		if handlers.onAdminTreadmill(v13) then
			return true
		end
		local plots = workspace:FindFirstChild("Plots")

		if plots then
			for _, child in ipairs(plots:GetChildren()) do
				local treadmillBottom = child:FindFirstChild("TreadmillBottom")
				if treadmillBottom and treadmillBottom:IsA("BasePart") and (treadmillBottom.Position - v13.Position).Magnitude <= 12 then
					return true
				end
			end
		end

		local clientTreadmillRenders = workspace:FindFirstChild("__ClientTreadmillRenders")
		if not clientTreadmillRenders then
			return false
		end

		for _, child in ipairs(clientTreadmillRenders:GetChildren()) do
			for _, descendant in ipairs(child:GetDescendants()) do
				if descendant:IsA("BasePart") and (descendant.Name == "Root" or descendant.Name == "BoundingBoxPart") and (descendant.Position - v13.Position).Magnitude <= 10 then
					return true
				end
			end
		end

		return false
	end

	tbl15.characterReadyToMove = function()
		local v13, v14 = fn33()
		return v13 ~= nil and v14 ~= nil and v14.Health > 0 and not v13.Anchored and v13.AssemblyMass ~= math.huge
	end

	if chsaeTreadmillActiveId ~= nil and not fn47() then
		chsaeTreadmillActiveId = nil
		getgenv().__CHSAE_TreadmillActiveId = nil
	elseif chsaeTreadmillActiveId == nil and fn47() then
		chsaeTreadmillActiveId = "__physical_treadmill__"
		getgenv().__CHSAE_TreadmillActiveId = chsaeTreadmillActiveId
	end

	tbl14.treadmillTraining = chsaeTreadmillActiveId ~= nil

	local function fn48()
		if tbl2.AntiTreadmill then
			return true, "Anti Treadmill enabled"
		end

		if tbl15.placePending and not tbl14.placeBusy then
			local n4 = tonumber(tbl15.placeBeat) or 0
			local flag2 = n4 <= 0
			local flag3

			if flag2 then
				flag3 = flag2
			else
				local placeStale = tbl15.PLACE_STALE
				flag3 = os.clock() - n4 > placeStale
			end

			if flag3 then
				tbl15.placePending = false

				if tbl14.owner == "Place" then
					tbl14.release("Place")
				end
			end
		end

		local eventPending = handlers.greatBloomUnlockReturnPending == true or tbl15.eventPending
		if tbl15.placePending or tbl14.placeBusy then
			return true, "Placing eggs"
		end

		if handlers.mutateBatchPending and handlers.mutateBatchPending() then
			return true, "Mutating eggs"
		end

		if eventPending then
			return true, handlers.adminEventPending and "Lab trade has priority" or "Event movement has priority"
		end

		if tbl15.treadmillSuppressed then
			return true, "Steal movement pending"
		end

		if os.clock() < (tonumber(tbl15.treadmillBlockedUntil) or 0) then
			return true, "Finishing pen handoff"
		end
		return false
	end

	local function detectActiveTreadmill()
		local v13 = fn47()

		if chsaeTreadmillActiveId ~= nil and not v13 and os.clock() - n2 > 1 then
			chsaeTreadmillActiveId = nil
			getgenv().__CHSAE_TreadmillActiveId = nil
			tbl14.treadmillTraining = false
		elseif chsaeTreadmillActiveId == nil and v13 then
			chsaeTreadmillActiveId = str
			getgenv().__CHSAE_TreadmillActiveId = chsaeTreadmillActiveId
			tbl14.treadmillTraining = true
		end

		return chsaeTreadmillActiveId
	end

	if tbl16 and tbl17 then
		pcall(function()
			getgenv().__CHSAE_TreadmillConn = tbl16.Fired(tbl17.ACTIVE_TREADMILL_EVENT):Connect(function(arg, arg2, arg3)
				if arg ~= localPlayer then
					return
				end
				n2 = os.clock()

				if arg2 == true then
					chsaeTreadmillActiveId = "__render_treadmill_" .. tostring(arg3 or n2)
				else
					chsaeTreadmillActiveId = nil
					n3 = n2
				end

				getgenv().__CHSAE_TreadmillActiveId = chsaeTreadmillActiveId
				tbl14.treadmillTraining = chsaeTreadmillActiveId ~= nil

				if chsaeTreadmillActiveId ~= nil then
					fn45(fn48() and "🟡 Leaving treadmill…" or "🟢 Training")
				elseif tbl2.AutoTreadmill and not fn48() then
					fn45("🟡 Returning to treadmill…")
				else
					fn45(tbl2.AutoTreadmill and "🟡 Standby" or "🔴 Off")
				end

				if fn12 then
					fn12("treadmill-state")
				end
			end)
		end)
	end

	tbl15.treadmillExitRequest = { inFlight = false, startedAt = 0, accepted = nil, error = nil }

	local function fn49()
		local treadmillExitRequest = tbl15.treadmillExitRequest
		local inFlight = treadmillExitRequest.inFlight

		if not inFlight then
			inFlight = not (tbl16 and tbl17)
		end

		if inFlight then
			return treadmillExitRequest.inFlight
		end
		treadmillExitRequest.inFlight = true
		treadmillExitRequest.startedAt = os.clock()
		treadmillExitRequest.accepted = nil
		treadmillExitRequest.error = nil
		task.spawn(function()
			local ok, result = pcall(tbl16.Invoke, tbl17.REQUEST_UNEQUIP)
			treadmillExitRequest.inFlight = false
			treadmillExitRequest.accepted = ok and result == true

			if not ok then
				treadmillExitRequest.error = tostring(result)
			elseif result ~= true then
				treadmillExitRequest.error = "Server rejected treadmill exit"
			end
		end)

		return true
	end

	local function requestTreadmillExit()
		if not detectActiveTreadmill() and tbl15.characterReadyToMove() then
			return true
		end

		if not (tbl16 and tbl17) then
			return false
		end
		fn45("🟡 Leaving treadmill…")
		fn49()
		local n4 = os.clock() + 3.5
		local n5 = math.clamp(fn34() * 1.5 + 0.08, 0.16, 0.35)
		local v13 = nil

		while true do
			if fn() and os.clock() < n4 then
				local flag2 = detectActiveTreadmill() == nil
				local v14 = tbl15.characterReadyToMove()
				local treadmillExitRequest = tbl15.treadmillExitRequest
				local flag3 = n3 >= (tonumber(treadmillExitRequest.startedAt) or math.huge) or not treadmillExitRequest.inFlight and treadmillExitRequest.accepted == true

				if flag2 and v14 and flag3 then
					local now3 = v13 or os.clock()

					if n5 <= os.clock() - now3 then
						break
					else
						v13 = now3
						RunService.Heartbeat:Wait()
						continue
					end
				else
					v13 = nil
					RunService.Heartbeat:Wait()
					continue
				end
			end

			break
		end

		local flag2 = detectActiveTreadmill() == nil
		local v14 = tbl15.characterReadyToMove()
		local treadmillExitRequest = tbl15.treadmillExitRequest
		local flag3 = n3 >= (tonumber(treadmillExitRequest.startedAt) or math.huge) or not treadmillExitRequest.inFlight and treadmillExitRequest.accepted == true
		local flag4 = fn()

		if flag4 then
			flag4 = not (flag2 and v14 and flag3)
		end

		if flag4 and tbl15.treadmillExitRequest.inFlight then
			tbl15.treadmillExitRequest.error = "Treadmill server response pending"
			fn45("🟡 Treadmill server pending")
		end

		if flag2 and v14 and flag3 then
			fn45(tbl2.AutoTreadmill and "🟡 Standby" or "🔴 Off")
		end

		return flag2 and v14 and flag3
	end

	tbl15.waitForToolFree = function(arg)
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not (character and humanoid and humanoid.Health > 0) then
			return false
		end
		local n4 = math.clamp(fn34() * 1.5 + 0.06, 0.12, 0.3)
		if not character:FindFirstChildWhichIsA("Tool") and not tbl15.toolRetiredAt then
			return true
		end
		local n5 = os.clock() + math.max(0.5, tonumber(arg) or 1.5)
		local now3 = nil

		while fn() and os.clock() < n5 do
			local character2 = localPlayer.Character
			local humanoid2 = character2 and character2:FindFirstChildOfClass("Humanoid")
			if not (character2 and humanoid2 and humanoid2.Health > 0) then
				return false
			end

			if character2:FindFirstChildWhichIsA("Tool") then
				tbl15.toolRetiredAt = os.clock()

				pcall(function()
					humanoid2:UnequipTools()
				end)

				now3 = nil
			else
				now3 = now3 or os.clock()
				if n4 <= os.clock() - now3 then
					tbl15.toolRetiredAt = nil
					return true
				end
			end

			RunService.Heartbeat:Wait()
		end

		return false
	end

	local function fn50()
		if tbl2.AdminTreadmill then
			local v13 = handlers.adminTreadmillTarget()
			if v13 then
				return v13
			end
		end

		if not tbl19 then
			return nil
		end
		local v13 = tbl19.GetMySlot()
		if not v13 then
			return nil
		end
		local plots = workspace:FindFirstChild("Plots")
		plots = plots and plots:FindFirstChild(tostring(v13))
		plots = plots and plots:FindFirstChild("TreadmillBottom")
		if plots and plots:IsA("BasePart") then
			return Vector3.new(plots.Position.X, plots.Position.Y + 4, plots.Position.Z)
		end
		local chsaeTreadmillRender = rawget(getgenv(), "__CHSAE_TreadmillRender")

		if typeof(chsaeTreadmillRender) ~= "Instance" or chsaeTreadmillRender.Parent == nil then
			chsaeTreadmillRender = workspace:FindFirstChild("__ClientTreadmillRenders")
			chsaeTreadmillRender = chsaeTreadmillRender and chsaeTreadmillRender:FindFirstChild("TreadmillRender_" .. tostring(v13)) or nil
			getgenv().__CHSAE_TreadmillRender = chsaeTreadmillRender
		end

		if not chsaeTreadmillRender then
			return nil
		end
		local belt001 = chsaeTreadmillRender:FindFirstChild("Belt.001", true) or chsaeTreadmillRender:FindFirstChild("BoundingBoxPart", true) or chsaeTreadmillRender:FindFirstChild("Root", true)
		local position = belt001 and belt001:IsA("BasePart") and belt001.Position or chsaeTreadmillRender:GetPivot().Position
		return Vector3.new(position.X, position.Y + 3, position.Z)
	end

	local function fn51(arg)
		local v13, v14 = fn33()
		local character = localPlayer.Character
		if not (v13 and v14) or v14.Health <= 0 then
			return false, "character unavailable"
		end

		local function fn52()
			return fn() and tbl2.AutoTreadmill and not fn48() and not critical and not tbl14.stealBusy() and not tbl14.petsBusy and tbl14.hold("Treadmill") and localPlayer.Character == character and v13.Parent == character and v14.Health > 0
		end

		if not fn52() then
			return false, "cancelled"
		end

		if detectActiveTreadmill() then
			return true, "mounted"
		end

		if v13.Anchored or v13.AssemblyMass == math.huge then
			return false, "character anchored"
		end
		local devChickenTween = handlers.DevChickenTween
		if devChickenTween and devChickenTween.lease then
			return false, "movement restoration pending"
		end
		local treadmillEntry = { phase = "approach", startedAt = os.clock() }
		tbl15.treadmillEntry = treadmillEntry

		local function fn53(arg2, reason)
			local v15 = treadmillEntry
			local v16 = treadmillEntry
			v15.phase = arg2 and "mounted" or "waiting"
			v16.reason = reason
			return arg2, reason
		end

		local z = arg.Z
		local vector = Vector3.new(arg.X, fn39(arg.X, arg.Z, arg.Y), z)
		v14.Sit = false
		if not handlers.progressionTweenTo then
			local tweenControllerStarting, v15 = fn53(false, "Tween controller starting")
			return tweenControllerStarting, v15
		end
		local Treadmill, v15 = handlers.progressionTweenTo("Treadmill", vector, 1.5, fn52)
		if not fn52() then
			local v16, v17 = fn53(false, "cancelled")
			return v16, v17
		end

		if detectActiveTreadmill() then
			local v16, v17 = fn53(true, "mounted")
			return v16, v17
		end

		if not Treadmill then
			local v16, v17 = fn53(false, v15 or "treadmill approach interrupted")
			return v16, v17
		end
		treadmillEntry.phase = "mount wait"
		fn45("🟡 Waiting for treadmill mount…")
		local n4 = math.clamp(tonumber(fn34()) or 0, 0, 1.5)
		local n5 = math.clamp(tonumber(handlers.clientFrameSeconds) or 0.016666666666666666, 0.0041666666666666666, 0.25)
		local n6 = os.clock() + math.max(3.5, n4 * 2 + 1.5 + n5 * 3)

		while fn52() and os.clock() < n6 do
			if detectActiveTreadmill() then
				local v16, v17 = fn53(true, "mounted")
				return v16, v17
			end

			if v13.Anchored or v13.AssemblyMass == math.huge then
				local v16, v17 = fn53(false, "character anchored")
				return v16, v17
			end

			if ((v13.Position - vector) * Vector3.new(1, 0, 1)).Magnitude > 4 then
				local v16, v17 = fn53(false, "moved away from treadmill")
				return v16, v17
			end
			RunService.Heartbeat:Wait()
		end

		if not fn52() then
			local v16, v17 = fn53(false, "cancelled")
			return v16, v17
		end

		if detectActiveTreadmill() then
			local v16, v17 = fn53(true, "mounted")
			return v16, v17
		end
		local v16, v17 = fn53(false, "native mount pending")
		return v16, v17
	end

	local function fn52()
		local tbl20 = {}
		local tbl21 = {}
		local n4 = 0

		local function fn53(arg)
			if not arg:IsA("BasePart") then
				return false
			end

			if arg.Name == "TreadmillBottom" and arg.Parent and arg.Parent.Parent == workspace:FindFirstChild("Plots") then
				return true
			end
			local parent = arg.Parent

			while parent and parent ~= workspace do
				local flag2 = parent.Parent == workspace
				local flag3

				if flag2 then
					flag3 = parent.Name == "AdminTreadmill" or parent.Name == "__ClientTreadmillRenders"
				else
					flag3 = flag2
				end

				if flag3 then
					return true
				end
				parent = parent.Parent
			end

			return false
		end

		local function fn54(descendant)
			if not fn() or not tbl2.AntiTreadmill or not fn53(descendant) or tbl20[descendant] then
				return
			end
			tbl20[descendant] = { descendant.CanCollide, descendant.CanTouch, descendant.CanQuery }
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
		end

		local function chsaeAntiTreadmillRestore()
			for _, v13 in ipairs(tbl21) do
				v13:Disconnect()
			end

			table.clear(tbl21)

			for k, v13 in pairs(tbl20) do
				pcall(function()
					local v14 = k
					local v15 = k
					local v16 = v13[2]
					local v17 = v13[1]
					k.CanQuery = v13[3]
					v14.CanTouch = v16
					v15.CanCollide = v17
				end)
			end

			table.clear(tbl20)
		end

		local function fn55()
			chsaeAntiTreadmillRestore()
			if not fn() or not tbl2.AntiTreadmill then
				return
			end
			n4 = 0
			tbl21[#tbl21 + 1] = workspace.DescendantAdded:Connect(fn54)

			tbl21[#tbl21 + 1] = workspace.DescendantRemoving:Connect(function(descendant)
				local v13 = tbl20[descendant]

				if v13 then
					tbl20[descendant] = nil

					pcall(function()
						local v14 = descendant
						local v15 = descendant
						local v16 = v13[2]
						local v17 = v13[1]
						descendant.CanQuery = v13[3]
						v14.CanTouch = v16
						v15.CanCollide = v17
					end)
				end
			end)

			for _, v13 in ipairs({ "AdminTreadmill", "__ClientTreadmillRenders" }) do
				local v14 = workspace:FindFirstChild(v13)

				if v14 then
					for _, v15 in ipairs(v14:QueryDescendants("BasePart")) do
						fn54(v15)
					end
				end
			end

			local plots = workspace:FindFirstChild("Plots")

			if plots then
				for _, child in ipairs(plots:GetChildren()) do
					local treadmillBottom = child:FindFirstChild("TreadmillBottom")

					if treadmillBottom then
						fn54(treadmillBottom)
					end
				end
			end
		end

		handlers.antiTreadmillStep = function(arg, arg2)
			if fn() and tbl2.AntiTreadmill and arg and arg2 >= n4 then
				n4 = arg2 + 1
				fn49()
			end
		end

		getgenv().__CHSAE_AntiTreadmillRestore = chsaeAntiTreadmillRestore

		local AntiTreadmillToggle = (function()
	local _t = {Value = tbl2.AntiTreadmill, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.AntiTreadmill = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

		AntiTreadmillToggle:OnChanged(function(arg)
			tbl2.AntiTreadmill = arg == true
			fn55()

			if arg then
				local clock = os.clock
				handlers.antiTreadmillStep(detectActiveTreadmill(), clock())
			end

			fn10(true)
		end)
		fn55()
	end

	fn52()

	v12:AddToggle("AutoUpgradeTreadmillToggle", {
		Text = "Upgrade Treadmill",
		Default = tbl2.AutoUpgradeTreadmill,
		Tooltip = "Buy affordable treadmill upgrades.",
	}):OnChanged(function(autoUpgradeTreadmill)
		tbl2.AutoUpgradeTreadmill = autoUpgradeTreadmill
		fn46(autoUpgradeTreadmill and "🟡 Watching upgrades" or "💤 Upgrade standby")
	end)

	v12:AddToggle("AutoTreadmillToggle", {
		Text = "Auto Treadmill",
		Default = tbl2.AutoTreadmill,
		Tooltip = "Use the treadmill when idle.",
	}):OnChanged(function(autoTreadmill)
		tbl2.AutoTreadmill = autoTreadmill

		if not autoTreadmill then
			tbl15.treadmillSuppressed = false

			task.spawn(function()
				requestTreadmillExit()
				fn45("🔴 Off")
			end)
		else
			fn45(detectActiveTreadmill() and "🟢 Training" or "🟡 Standby")
		end
	end)

	local AdminTreadmillToggle = (function()
	local _t = {Value = tbl2.AdminTreadmill, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.AdminTreadmill = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

	AdminTreadmillToggle:OnChanged(function(arg)
		tbl2.AdminTreadmill = arg == true
		handlers.adminTreadmillSwitchAt = 0
		fn10(true)
	end)

	task.spawn(function()
		local n4 = 0
		local n5 = 0
		local n6 = 0.75

		while fn() do
			local ok, result = xpcall(function()
				local now3 = os.clock()
				local v13 = detectActiveTreadmill()
				handlers.antiTreadmillStep(v13, now3)
				local v14, treadmillBlockReason = fn48()

				if critical then
					treadmillBlockReason = "Carrying egg"
				elseif tbl14.stealBusy() then
					treadmillBlockReason = "Steal has priority"
				end

				tbl15.treadmillBlockReason = treadmillBlockReason

				if v14 or treadmillBlockReason then
					tbl15.treadmillIdleSince = 0

					if tbl2.AutoTreadmill and not v13 then
						fn45("⏸️ " .. tostring(treadmillBlockReason))
					end
				elseif tbl15.treadmillIdleSince == 0 then
					tbl15.treadmillIdleSince = now3
				end

				local flag2 = tbl15.treadmillIdleSince > 0 and now3 - tbl15.treadmillIdleSince >= n6
				local flag3 = tbl2.AutoUpgradeTreadmill and now3 >= n5
				local flag4 = false

				if flag3 then
					n5 = now3 + 4

					if not (tbl18 and Treadmills and tbl16 and tbl17) then
						fn46("⚠️ Upgrade unavailable")
					elseif tbl14.quietOk() and not tbl14.stealBusy() then
						local ok, result = pcall(tbl18.Get)
						local n7 = ok and type(result) == "table" and tonumber(result.BaseUpgradeLevel) or 0
						local n8 = ok and type(result) == "table" and tonumber(result.TreadmillUpgradeLevel) or 0
						local v15 = nil

						pcall(function()
							v15 = Treadmills.GetByUpgradeLevel(n8 + 1)
						end)

						if n7 <= 0 then
							fn46("🔒 Upgrade the pen first")
						elseif not v15 then
							fn46("✅ Treadmill is max level")
						else
							local huge = tonumber(v15.Price) or math.huge

							if (tonumber(result.Money) or 0) < huge then
								fn46("🟡 Saving $" .. fn3(huge))
							else
								if v13 then
									requestTreadmillExit()
									v13 = detectActiveTreadmill()
								end

								if not v13 and tbl17.REQUEST_UPGRADE then
									local ok2, result2 = pcall(tbl16.Invoke, tbl17.REQUEST_UPGRADE, v15._id)
									n4 = now3 + 4
									fn46(ok2 and result2 == true and "🟢 Treadmill upgraded" or "🟡 Upgrade retrying")
									flag4 = true
								end
							end
						end
					end
				end

				if not flag4 and tbl2.AutoTreadmill and not fn48() and not critical and not tbl14.stealBusy() and not tbl14.petsBusy and (v13 or flag2) then
					if v13 then
						local flag5 = tbl2.AdminTreadmill and handlers.adminTreadmillPart() ~= nil
						local onAdminTreadmill = handlers.onAdminTreadmill
						local v15 = fn33()
						local flag6 = flag5 ~= onAdminTreadmill(v15)

						if flag6 then
							flag6 = now3 >= (handlers.adminTreadmillSwitchAt or 0)
						end

						if flag6 then
							handlers.adminTreadmillSwitchAt = now3 + 30
							fn45(flag5 and "↗️ Switching to Admin Treadmill…" or "↩️ Returning to your treadmill…")
							fn49()
						else
							fn45("🟢 Training")
						end
					elseif now3 < n4 then
						fn45("🟡 Entry cooling down")
					elseif tbl14.acquire("Treadmill") then
						local function fn53()
							return fn() and tbl2.AutoTreadmill and not fn48() and not critical and not tbl14.stealBusy() and not tbl14.petsBusy and tbl14.hold("Treadmill")
						end

						local v15 = handlers.getTrackStart()
						local v16 = fn33()
						local v17 = v16 and fn35(v16.Position)
						local flag5 = v17 ~= nil and v17 <= 0
						local v18 = fn50()
						local flag6 = not flag5 and not (v16 and v18 and ((v16.Position - v18) * Vector3.new(1, 0, 1)).Magnitude <= 2) and v15 and v16
						local flag7

						if flag6 then
							flag7 = ((v16.Position - v15.Position) * Vector3.new(1, 0, 1)).Magnitude > 3
						else
							flag7 = flag6
						end

						local flag8 = true

						if flag7 then
							fn45("↩️ Returning to TrackStart…")
							flag8 = handlers.settleClaimAtTrackStart(fn53)
						end

						local v19 = flag8 and fn53() and fn50() or nil

						if v19 then
							fn45("↗️ Tweening to treadmill…")
							local v20, v21 = fn51(v19)

							if not v20 then
								local flag9 = v21 == "character movement initializing" or v21 == "character unavailable"
								n4 = os.clock() + (flag9 and 1 or 8)
							end

							if detectActiveTreadmill() then
								fn45("🟢 Training")
							elseif v21 == "movement trust pending" or v21 == "renewing" then
								fn45("🟡 Tween movement pending")
							elseif handlers.defaultMoveFallback then
								fn45("🟡 Compatibility entry retrying")
							else
								fn45("🟡 " .. tostring(v21 or "Native mount pending"))
							end
						elseif not flag8 and fn53() then
							fn45("🟡 TrackStart return interrupted · retrying")
							n4 = os.clock() + 2
						elseif flag8 and fn53() then
							fn45("🟡 Treadmill unavailable")
							n4 = os.clock() + 8
						end

						tbl14.release("Treadmill")
					else
						tbl15.treadmillBlockReason = "Waiting for " .. tostring(tbl14.owner or "movement handoff")
						fn45("⏸️ " .. tbl15.treadmillBlockReason)
					end
				elseif tbl2.AutoTreadmill and not v13 and tbl14.petsBusy then
					tbl15.treadmillBlockReason = "Finishing inventory action"
					fn45("⏸️ " .. tbl15.treadmillBlockReason)
				elseif tbl2.AutoTreadmill and not v13 and not fn48() and not critical and not tbl14.stealBusy() and not flag2 then
					fn45("🟡 Waiting for useful idle window")
				elseif v13 and fn48() then
					requestTreadmillExit()
				elseif not tbl2.AutoTreadmill then
					fn45("🔴 Off")
				end
			end, debug.traceback)

			if not ok then
				getgenv().__CHSAE_TreadmillWorkerError = tostring(result)
				local devChickenTween = handlers.DevChickenTween

				if devChickenTween and devChickenTween.lease and devChickenTween.lease.owner == "Treadmill" then
					devChickenTween.restore("treadmill worker recovery")
				end

				tbl14.release("Treadmill")
				tbl15.treadmillIdleSince = 0
				tbl15.treadmillBlockReason = "Retrying treadmill after error"
				fn45("🟡 " .. tbl15.treadmillBlockReason)
				n4 = os.clock() + 2
			end

			task.wait(0.5)
		end

		tbl14.release("Treadmill")
	end)

	tbl15.detectActiveTreadmill = detectActiveTreadmill
	tbl15.requestTreadmillExit = requestTreadmillExit
end

handlers.CreateTrailController = function(arg)
	local settings_2 = arg.settings
	local str = "💤 Purchase standby"
	local n2 = 0
	local v13 = nil
	local v14 = nil
	local tbl16 = {}
	local tbl17 = {}
	local flag2 = false
	local flag3 = false
	local n3 = 0
	local v15 = nil

	local function fn45()
		return not flag2 and arg.alive()
	end

	local function fn46(arg2)
		if type(arg2) ~= "thread" or arg2 == coroutine.running() then
			return false
		end
		return pcall(task.cancel, arg2)
	end

	local function fn47(arg2)
		arg2.active = false
		tbl16[arg2] = nil
		fn46(arg2.thread)
		arg2.thread = nil
		arg2.callback = nil
	end

	local fn48 = nil

	fn48 = function(arg2)
		if not fn45() or not arg2.active or arg2.queued or arg2.delivered == str then
			return
		end
		arg2.queued = true

		arg2.thread = task.defer(function()
			if not arg2.active or not fn45() then
				arg2.queued = false
				return
			end
			local v16 = str
			local ok, result = pcall(arg2.callback, v16)
			local v17 = arg2
			arg2.queued = false
			v17.thread = nil

			if ok and result ~= false then
				arg2.delivered = v16
			end

			if str ~= v16 then
				fn48(arg2)
			end
		end)
	end

	local function fn49(arg2)
		if not fn45() then
			return
		end
		str = tostring(arg2)

		for k in pairs(tbl16) do
			fn48(k)
		end
	end

	local function fn50()
		local v16 = n3

		local function fn51()
			return fn45() and settings_2.AutoBuyTrail and n3 == v16
		end

		local v17

		pcall(function()
			v17 = arg.getSave()
		end)

		if not fn51() then
			return
		end

		if not arg.ready() or type(v17) ~= "table" then
			fn49("⚠️ Trail shop unavailable")
			return
		end
		local trailInventory = type(v17.TrailInventory) == "table" and v17.TrailInventory or {}

		if v13 then
			if v17.EquippedTrail == v13 then
				fn49("✅ Equipped " .. tostring(v14 or v13))
				v13 = nil
				v14 = nil
				n2 = arg.clock() + 1
			elseif not trailInventory[v13] then
				fn49("🟡 Purchase syncing…")
			elseif n2 <= arg.clock() then
				n2 = arg.clock() + 2
				fn49("🟡 Equipping " .. tostring(v14 or v13) .. "…")
				local ok, result, result2 = pcall(arg.equip, v13)
				if not fn45() then
					return
				end

				if ok and result == true then
					if fn51() then
						fn49("✅ Equipped " .. tostring(v14 or v13))
					end

					v13 = nil
					v14 = nil
				elseif fn51() then
					fn49("🟡 Equip retry · " .. tostring(result2 or result or "waiting"))
				end
			end
		else
			local n4 = 0
			local n5 = 0
			local v18 = nil

			for _, item in ipairs(arg.items) do
				if settings_2.TrailNames[item] then
					n4 += 1

					if trailInventory[arg.byLabel[item]] then
						n5 += 1
					else
						v18 = v18 or item
					end
				end
			end

			if n4 == 0 then
				fn49("🟡 Pick trails")
			elseif not v18 then
				fn49(("✅ Selected trails owned · %d/%d"):format(n5, n4))
				n2 = arg.clock() + 5
			elseif n2 <= arg.clock() then
				n2 = arg.clock() + 6
				local v19 = arg.byLabel[v18]
				settings_2.TrailName = v19
				fn49("🟡 Buying " .. v18 .. "…")
				local ok, result, result2 = pcall(arg.purchase, v19)
				if not fn45() then
					return
				end

				if ok and result == true then
					v13 = v19
					v14 = v18
					n2 = arg.clock() + 0.15
					if not fn51() then
						return
					end
					local ok2, result3 = pcall(arg.equip, v19)
					if not fn45() then
						return
					end

					if ok2 and result3 == true then
						if fn51() then
							fn49("✅ Purchased + equipped " .. v18)
						end

						v13 = nil
						v14 = nil
					elseif fn51() then
						fn49("✅ Purchased " .. v18 .. " · equipping")
					end
				elseif fn51() then
					fn49(tostring(result2 or result):lower():find("afford", 1, true) and "🟡 Waiting for cash" or "🟡 Purchase waiting")
				end
			else
				fn49(("🟡 %d/%d owned"):format(n5, n4))
			end
		end
	end

	local tbl18 = {
		GetStatus = function()
			return str
		end,
		ObserveStatus = function(arg2, arg3)
			local tbl18 = { callback = arg3, active = true, queued = false }

			local tbl19 = { Disconnect = function()
				fn47(tbl18)
			end }

			if not fn45() then
				tbl18.active = false
				tbl18.callback = nil
				return tbl19
			end

			tbl16[tbl18] = true
			fn48(tbl18)
			return tbl19
		end,
		SetEnabled = function(arg2, arg3)
			if not fn45() then
				return
			end

			if settings_2.AutoBuyTrail ~= arg3 == true then
				n3 += 1
			end

			settings_2.AutoBuyTrail = arg3 == true
			fn49(settings_2.AutoBuyTrail and "🟡 Watching trails" or "💤 Purchase standby")
			arg.wake("trail-toggle")
		end,
		Stop = function(arg2)
			arg2:SetEnabled(false)
		end,
		SelectionChanged = function()
			if not fn45() then
				return
			end
			local n4 = 0

			for _, trailName in pairs(settings_2.TrailNames) do
				if trailName then
					n4 += 1
				end
			end

			fn49(n4 > 0 and ("🟡 %d selected"):format(n4) or "🟡 Pick trails")
			arg.wake("trail-selection")
		end,
		Step = function()
			if not fn45() or not settings_2.AutoBuyTrail or flag3 then
				return false
			end
			local v16 = n3
			flag3 = true
			local ok = pcall(fn50)
			flag3 = false

			if not ok and fn45() and settings_2.AutoBuyTrail and n3 == v16 then
				fn49("⚠️ Trail shop retrying")
			end

			return ok
		end,
		Own = function(arg2, arg3)
			if flag2 then
				pcall(function()
					arg3:Disconnect()
				end)
			else
				tbl17[#tbl17 + 1] = arg3
			end

			return arg3
		end,
		Destroy = function()
			if flag2 then
				return
			end
			local n4 = n3 + 1
			flag2 = true
			n3 = n4

			if v15 and v15.phase ~= "stepping" and fn46(v15.thread) then
				v15 = nil
			end

			for k in pairs(tbl16) do
				fn47(k)
			end

			for _, v16 in ipairs(tbl17) do
				pcall(function()
					v16:Disconnect()
				end)
			end

			table.clear(tbl17)
			v13 = nil
			v14 = nil
			n2 = 0
		end,
	}

	tbl18.Disconnect = tbl18.Destroy

	tbl18.Start = function(arg2)
		if not fn45() then
			return false
		end

		if v15 then
			return true
		end
		local tbl19 = { phase = "queued" }
		v15 = tbl19

		tbl19.thread = task.defer(function()
			local ok = pcall(function()
				while fn45() do
					if not settings_2.AutoBuyTrail then
						tbl19.phase = "idle"
						arg.waitIdle()
						continue
					else
						tbl19.phase = "stepping"
						arg2:Step()

						if fn45() then
							tbl19.phase = "sleeping"
							task.wait(1)
							continue
						end
					end

					break
				end
			end)

			if v15 == tbl19 then
				v15 = nil
			end

			if not arg.alive() then
				arg2:Destroy()
			elseif not ok then
				fn49("⚠️ Trail worker stopped")
			end
		end)

		return true
	end

	tbl18.GetLifecycle = function()
		local n4 = 0

		for k in pairs(tbl16) do
			n4 += 1
		end

		return {
			destroyed = flag2,
			worker = v15 and v15.phase or "none",
			busy = flag3,
			observers = n4,
			connections = #tbl17,
		}
	end

	return tbl18
end

local v13

do
	local Trails = nil
	local tbl16 = nil
	local tbl17 = nil
	local askPurchase = nil
	local askChoose = nil
	local tbl18 = {}
	local tbl19 = {}
	local tbl20 = {}

	pcall(function()
		local Remotes = require(ReplicatedStorage.Shared.Remotes)
		local v14 = GetSaveModule()
		Trails = require(ReplicatedStorage.Data.Trails)

		tbl16 = { Invoke = function(arg, ...)
			return arg:InvokeServer(...)
		end }

		tbl17 = { Get = function()
			return v14.Get()
		end }

		askPurchase = Remotes.Trailwear.AskPurchase
		askChoose = Remotes.Trailwear.AskChoose
		local tbl21 = {}
		local v15 = pairs
		local directory = Trails.Directory or {}

		for k, v16 in v15(directory) do
			if type(v16) == "table" and v16.DisplayInShop then
				tbl21[#tbl21 + 1] = { id = tostring(k), data = v16 }
			end
		end

		table.sort(tbl21, function(arg, arg2)
			return (tonumber(arg.data.Price) or 0) < (tonumber(arg2.data.Price) or 0)
		end)

		for _, v16 in ipairs(tbl21) do
			local data = v16.data
			local str = tostring(data.DisplayName or v16.id)
			local rarity = data.Rarity
			local str2 = type(rarity) == "table" and typeof(rarity.Color) == "Color3" and fn5(rarity.Color) or "#FFFFFF"
			tbl18[#tbl18 + 1] = str
			tbl19[str] = v16.id
			tbl20[str] = ("<b>%s</b> <font color=\"%s\">%s</font> <font color=\"#9AA0AA\">$%s · ×%s</font>"):format(str, str2, tostring(type(rarity) == "table" and (rarity._id or rarity.DisplayName) or ""), fn3(tonumber(data.Price) or 0), tostring(data.SpeedMultiplier or 1))
		end
	end)

	if next(tbl2.TrailNames) == nil then
		for k, v14 in pairs(tbl19) do
			if v14 == tbl2.TrailName then
				tbl2.TrailNames[k] = true
				break
			end
		end
	end

	for k in pairs(tbl2.TrailNames) do
		if not tbl19[k] then
			tbl2.TrailNames[k] = nil
		end
	end

	local v14 = handlers.CreateTrailController({
		settings = tbl2,
		items = tbl18,
		byLabel = tbl19,
		alive = fn,
		clock = os.clock,
		wake = tbl.WakeIdleWorkers,
		waitIdle = function()
			tbl.IdleWorkerWake.Event:Wait()
		end,
		getSave = function()
			return tbl17 and tbl17.Get()
		end,
		ready = function()
			return tbl16 and askPurchase and askChoose
		end,
		purchase = function(arg)
			return tbl16.Invoke(askPurchase, arg)
		end,
		equip = function(arg)
			return tbl16.Invoke(askChoose, arg)
		end,
	})

	getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = v14
	v14:Start()
	v13 = progression:AddRightGroupbox("✨ Trail Shop")
	local TrailShopStatusLabel = nil

	chk.Merge(v13, function()
		TrailShopStatusLabel = v13:AddLabel("TrailShopStatusLabel", { Text = v14:GetStatus(), DoesWrap = true })
	end)

	bindDropdownOverlay(v13, "TrailShopDropdown", "Trails", tbl18, {
		configKey = "TrailNames",
		multi = true,
		store = tbl2.TrailNames,
		text = "Trails",
		tooltip = "Choose trails to buy.",
		displayMap = tbl20,
		onChange = function()
			v14:SelectionChanged()
		end,
	})

	v13:AddToggle("AutoBuyTrailToggle", {
		Text = "Auto Buy Trail",
		Default = tbl2.AutoBuyTrail,
		Tooltip = "Buy the selected trail when affordable.",
	}):OnChanged(function(arg)
		v14:SetEnabled(arg)
	end)

	local v15 = v14:ObserveStatus(function(arg)
		local v15 = handlers.setLabel(TrailShopStatusLabel, arg)

		if not v15 then
			handlers.statusLabelCache[TrailShopStatusLabel] = nil
		end

		return v15
	end)

	v14:Own(v13.Container.Destroying:Connect(function()
		v15:Disconnect()
	end))
end

do
	local tbl16 = nil
	local Eggs = nil

	pcall(function()
		local v14 = GetSaveModule()

		tbl16 = {
			Get = function()
				return v14.Get()
			end,
			ConnectForDataChanged = function(arg, arg2)
				return v14.FieldSignal(arg):Connect(arg2)
			end,
		}

		Eggs = require(ReplicatedStorage.Shared.Types.Eggs)
	end)

	handlers.eggInventoryCapacityState = function()
		local v14 = nil

		pcall(function()
			v14 = tbl16 and tbl16.Get()
		end)

		local eggInventory = type(v14) == "table" and v14.EggInventory or nil
		local num = tonumber(Eggs and Eggs.MAX_INVENTORY)
		if type(eggInventory) ~= "table" or not num or num <= 0 then
			return false, 0, num
		end
		local n2 = 0

		for k in pairs(eggInventory) do
			n2 += 1
		end

		return n2 >= num, n2, num
	end

	handlers.petInventoryCapacityState = function()
		local v14 = nil

		pcall(function()
			v14 = tbl16 and tbl16.Get()
		end)

		local inventory = type(v14) == "table" and v14.Inventory or nil
		local flag2 = type(v14) == "table"

		if flag2 then
			flag2 = tonumber(v14.PetInventoryCapacity or v14.InventoryCapacity or v14.MaxInventory)
		end

		flag2 = flag2 or nil

		if not flag2 then
			local num = tonumber(localPlayer:GetAttribute("PetInventoryCapacity")) or tonumber(localPlayer:GetAttribute("InventoryCapacity"))

			if num then
				flag2 = num
			else
				flag2 = tonumber(Eggs and Eggs.MAX_INVENTORY)
			end

			flag2 = flag2 or 115
		end

		if type(inventory) ~= "table" or flag2 <= 0 then
			return false, 0, flag2
		end
		local n2 = 0

		for k in pairs(inventory) do
			n2 += 1
		end

		return n2 >= flag2, n2, flag2
	end

	local flag2 = false

	handlers.stopAutoStealForFullInventory = function(arg, arg2, arg3)
		local chsaeCarryRequest = getgenv().__CHSAE_CarryRequest
		local flag3 = handlers.stealTimer.active == true and type(chsaeCarryRequest) == "table"

		if flag3 and fn29(chsaeCarryRequest.uid, chsaeCarryRequest.category, chsaeCarryRequest.claimSequenceAtStart) then
			handlers.inventoryFullGraceUntil = 0
			fn11("🟠 Inventory full · finalizing steal")
			return false
		end

		if flag3 and chsaeCarryRequest.carrySeen == true then
			local now3 = os.clock()
			local inventoryFullGraceUntil = tonumber(handlers.inventoryFullGraceUntil) or 0

			if inventoryFullGraceUntil <= 0 then
				inventoryFullGraceUntil = now3 + 0.25
				handlers.inventoryFullGraceUntil = inventoryFullGraceUntil
			end

			if now3 < inventoryFullGraceUntil then
				if not handlers.inventoryFullGraceScheduled then
					handlers.inventoryFullGraceScheduled = true

					task.delay(math.max(0.01, inventoryFullGraceUntil - now3), function()
						handlers.inventoryFullGraceScheduled = false

						if fn() and AutoStealToggle and AutoStealToggle.Value == true then
							local v14, v15, v16 = handlers.eggInventoryCapacityState()

							if v14 then
								handlers.stopAutoStealForFullInventory(v15, v16, arg3)
							else
								handlers.inventoryFullGraceUntil = 0
							end
						end
					end)
				end

				return false
			end
		end

		handlers.inventoryFullGraceUntil = 0

		if tbl2.SellEggsWhenFull then
			if type(chsaeCarryRequest) == "table" and chsaeCarryRequest.inFlight ~= true then
				getgenv().__CHSAE_CarryRequest = nil
			end

			critical = false
			tbl15.treadmillSuppressed = false
			local v14 = tbl14
			tbl14.stealWants = false
			v14.critical = false
			tbl14.release("Steal")
			handlers.pauseStealTimer()
			handlers.carry = "📦 Carry: none"
			handlers.set("target", "🎯 Target: none")
			fn11(("🟠 Eggs full %d/%d · selling matches"):format(tonumber(arg) or 0, tonumber(arg2) or 0))
			return false
		end

		local flag4 = AutoStealToggle and AutoStealToggle.Value == true
		tbl2.AutoSteal = false

		local function fn45()
			if not (fn() and AutoStealToggle) then
				return
			end

			if AutoStealToggle.Value then
				handlers.automaticStealStop = true
			end

			pcall(AutoStealToggle.SetValue, AutoStealToggle, false)
			tbl2.AutoSteal = false
		end

		fn45()
		task.defer(fn45)
		handlers.inventoryFullStopped = true
		tbl15.treadmillSuppressed = false
		fn13()

		if type(chsaeCarryRequest) == "table" and chsaeCarryRequest.inFlight ~= true then
			getgenv().__CHSAE_CarryRequest = nil
		end

		local v14 = tbl14
		tbl14.stealWants = false
		v14.critical = false
		tbl14.release("Steal")
		handlers.carry = "📦 Carry: none"
		handlers.pauseStealTimer()
		handlers.set("target", "🎯 Target: none")
		fn11("🟠 Inventory full · Auto-Steal off")
		local flag5 = not flag2

		if flag5 then
			flag5 = os.clock() - (handlers.inventoryFullAlertAt or -math.huge) >= 600
		end

		if flag5 then
			flag2 = true
			handlers.inventoryFullAlertAt = os.clock()

			local pendingInventoryFullAlert = {
				count = tonumber(arg) or 0,
				capacity = tonumber(arg2) or 0,
				reason = tostring(arg3 or "Egg inventory is full"),
			}

			if type(handlers.sendWebhook) == "function" then
				task.spawn(handlers.sendWebhook, "inventory-full", "Egg Inventory Full", ("Auto-Steal was turned off. Egg inventory: **%d / %d**."):format(pendingInventoryFullAlert.count, pendingInventoryFullAlert.capacity), 16096779, false)
			else
				handlers.pendingInventoryFullAlert = pendingInventoryFullAlert
			end

			lua:Notify(("🥚 Inventory full (%d/%d) · Auto-Steal turned off."):format(pendingInventoryFullAlert.count, pendingInventoryFullAlert.capacity), 6)
		end

		return flag4
	end

	pcall(function()
		local EggInventory = tbl16.ConnectForDataChanged("EggInventory", function()
			local v14, v15, v16 = handlers.eggInventoryCapacityState()

			if not v14 then
				local flag3 = handlers.inventoryFullStopped == true and not tbl2.Stall
				flag2 = false
				handlers.inventoryFullStopped = false
				handlers.inventoryFullGraceUntil = 0

				if flag3 and AutoStealToggle and not AutoStealToggle.Value then
					task.defer(function()
						if fn() and not AutoStealToggle.Value then
							pcall(AutoStealToggle.SetValue, AutoStealToggle, true)
						end
					end)
				elseif AutoStealToggle and not AutoStealToggle.Value then
					fn11("🔴 Off")
				end

				if fn12 then
					fn12("inventory-space")
				end
			elseif AutoStealToggle and AutoStealToggle.Value then
				task.defer(handlers.stopAutoStealForFullInventory, v15, v16, "Your egg inventory is full!")
			end
		end)

		if typeof(EggInventory) == "RBXScriptConnection" then
			local chsaeRuntimeConns = getgenv().__CHSAE_RuntimeConns

			if type(chsaeRuntimeConns) == "table" then
				chsaeRuntimeConns[#chsaeRuntimeConns + 1] = EggInventory
			end
		end
	end)
end

handlers.greatBloomUnlockNeedsCrane = function()
	return tbl2.AutoUnlockGreatBloom == true and handlers.greatBloomUnlockStealWanted == true
end

handlers.greatBloomUnlockHasCraneReservation = function()
	if tbl2.AutoUnlockGreatBloom ~= true or handlers.greatBloomUnlock.locked == false then
		return false
	end
	local n2 = tonumber(handlers.greatBloomUnlockClaimedAt) or 0
	local n3 = tonumber(handlers.greatBloomUnlockClaimGrace) or 8
	local flag2 = n2 > 0 and os.clock() - n2 <= n3
	local greatBloomUnlock = handlers.greatBloomUnlock
	return flag2 or greatBloomUnlock.reservedEggUid ~= nil or greatBloomUnlock.reservedPetUid ~= nil or handlers.greatBloomUnlockReturnPending == true
end

handlers.greatBloomUnlockReturnHasPriority = function()
	return tbl2.AutoUnlockGreatBloom == true and handlers.greatBloomUnlockReturnPending == true and not handlers.normalStealPending()
end

handlers.carryRequestInFlight = function()
	local chsaeCarryRequest = getgenv().__CHSAE_CarryRequest
	return type(chsaeCarryRequest) == "table" and chsaeCarryRequest.inFlight == true
end

handlers.retainUnverifiedPickup = function(arg)
	if not fn() or type(arg) ~= "table" then
		return false
	end

	if arg.owner ~= "Steal" or arg.done ~= true or arg.inFlight ~= false or arg.accepted ~= true or arg.carrySeen or arg.carryEndedSeen or arg.droppedSeen or arg.claimSeen or arg.cancelledByDeath or arg.supersededByDrop or arg.supersededByRecovery or arg.character ~= localPlayer.Character or arg.generation ~= tbl13.respawnGeneration or getgenv().__CHSAE_CarryRequest ~= arg or tostring(tbl13.lockedUid) ~= tostring(arg.uid) or fn16() or not tbl14.hold("Steal") then
		return false
	end
	local now3 = os.clock()
	if now3 < (tonumber(arg.proofDeadline) or math.huge) then
		return false
	end

	if fn27(arg.uid) or fn29(arg.uid, arg.category, arg.claimSequenceAtStart) then
		return false
	end
	local v14, v15 = fn33()
	local v16 = fn25(arg.uid)
	local str = v16 and tostring(v16.State)
	local num = v16 and tonumber(v16.CarrierUserId)
	local flag2 = not v14 or not v15 or v15.Health <= 0

	if not flag2 then
		flag2 = (fn35(v14.Position) or -1) <= 0
	end

	if flag2 or not v16 or not v16.BottomCFrame or str ~= "Slot" and str ~= "Dropped" or num ~= nil and num > 0 and num ~= localPlayer.UserId then
		return false
	end
	tbl13.requestFailureUid = arg.uid
	tbl13.requestFailureAt = now3
	tbl13.lastRequestKind = "position-sync"
	tbl13.lastRequestError = "carry accepted but ownership not replicated"
	tbl15.treadmillSuppressed = true
	local v17 = tbl14
	tbl14.stealWants = true
	v17.critical = true
	tbl14.stealBeat = now3
	handlers.pickupProofRetries = (handlers.pickupProofRetries or 0) + 1
	return true
end

handlers.PetIndex = { eggs = {}, nextAt = 0, handoffs = {} }

handlers.petIndexReserved = function(arg)
	return tbl2.AutoPetIndex == true and handlers.PetIndex.eggs[tostring(arg)] == true
end

handlers.petIndexActive = function()
	return tbl2.AutoPetIndex == true and next(handlers.PetIndex.eggs) ~= nil and not handlers.petIndexBlocked()
end

handlers.petIndexBlocked = function()
	local scramble = handlers.Scramble
	return handlers.normalStealPending() or tbl15.eventPending or handlers.riftCollecting or handlers.riftWantsBody or handlers.riftPlacementWanted or handlers.riftClaimHandoffPending() or handlers.greatBloomUnlockNeedsCrane() or handlers.greatBloomUnlockReturnPending or tbl14.owner == "Event" or tbl14.owner == "AdminEvent" or scramble and scramble.busy
end

handlers.refreshPetIndex = function()
	local petIndex = handlers.PetIndex
	local nextAt = petIndex.nextAt
	if os.clock() < nextAt then
		return
	end
	petIndex.nextAt = os.clock() + 2

	local function fn45(status)
		petIndex.status = status

		if petIndex.label then
			handlers.setLabel(petIndex.label, status)
		end
	end

	if not tbl2.AutoPetIndex then
		petIndex.eggs = {}
		petIndex.target = nil
		petIndex.penReady = false
		fn45("🔴 Off")
		return
	end

	if critical or tbl14.critical or tbl13.lockedUid or handlers.carryRequestInFlight() then
		petIndex.penReady = false
		return
	end
	petIndex.target = nil
	local v14 = nil

	if not pcall(function()
		v14 = GetSaveModule().Get()
	end) or type(v14) ~= "table" or type(v14.Index) ~= "table" or type(v14.EggInventory) ~= "table" then
		fn45("🟡 Waiting for index data")
		return
	end

	if not petIndex.areaCategories then
		local ok, areaCategories = pcall(function()
			local tbl16 = {}
			local directory = require(ReplicatedStorage.Data.Areas).Directory
			local directory2 = require(ReplicatedStorage.Data.Assets).Directory

			for k, v15 in pairs(directory) do
				local tbl17 = {}
				tbl16[tostring(v15._id or k)] = tbl17
				local tbl18 = { v15 }
				local v16 = ipairs
				local subBiomes = v15.SubBiomes or {}

				for _, subBiome in v16(subBiomes) do
					tbl18[#tbl18 + 1] = subBiome
				end

				for _, v17 in ipairs(tbl18) do
					local v18 = pairs
					local dropTable = v17.DropTable or {}

					for k2, v19 in v18(dropTable) do
						local flag2 = type(v19) == "table" and v19[1] or k2
						local flag3 = type(v19) == "table" and v19[2] or v19
						local flag4 = directory2[flag2]
						flag4 = flag4 and flag4.DontRoll ~= true
						local flag5

						if flag4 then
							flag5 = (tonumber(flag3) or 0) > 0
						else
							flag5 = flag4
						end

						if flag5 then
							tbl17[tostring(flag2)] = true
						end
					end
				end
			end

			return tbl16
		end)

		if not ok then
			fn45("🟡 Waiting for area index data")
			return
		end
		petIndex.areaCategories = areaCategories
	end

	local petIndexAreas = type(tbl2.PetIndexAreas) == "table" and tbl2.PetIndexAreas or {}
	local flag2 = false

	for _, petIndexArea in pairs(petIndexAreas) do
		if petIndexArea then
			flag2 = true
			break
		end
	end

	local tbl16 = {}

	for k, areaCategory in pairs(petIndex.areaCategories) do
		if not flag2 or petIndexAreas[k] == true then
			for k2 in pairs(areaCategory) do
				tbl16[k2] = true
			end
		end
	end

	local function fn46(arg)
		return type(arg) == "string" and v14.Index[arg] ~= true and tbl16[arg] == true
	end

	local eggs2 = {}
	local tbl17 = {}
	local flag3 = false

	for k, handoff in pairs(petIndex.handoffs) do
		local flag4 = not fn46(handoff.category)

		if not flag4 then
			local at = handoff.at
			flag4 = os.clock() - at >= 15
		end

		if flag4 then
			petIndex.handoffs[k] = nil
		else
			local category = handoff.category
			eggs2[k] = true
			tbl17[category] = true
			flag3 = true
		end
	end

	local function fn47(arg, arg2)
		if type(arg2) ~= "table" then
			return
		end
		local assetCategory = arg2.AssetCategory or arg2.Category

		if fn46(assetCategory) and not tbl17[assetCategory] then
			local v15 = tbl17
			eggs2[tostring(arg)] = true
			v15[assetCategory] = true
		end
	end

	local v15 = pairs
	local tbl18 = tbl11.GetRuntimeSnapshot() or {}

	for _, v16 in v15(tbl18) do
		if tostring(v16.OwnerUserId) == tostring(localPlayer.UserId) then
			local v17 = pairs
			local records = v16.Records or {}

			for k, record in v17(records) do
				fn47(k, record)
			end
		end
	end

	for k, v16 in pairs(v14.EggInventory) do
		fn47(k, v16)
	end

	local flag4 = false

	for k in pairs(eggs2) do
		if not petIndex.eggs[k] then
			flag4 = true
			break
		end
	end

	if not flag4 then
		for k in pairs(petIndex.eggs) do
			if not eggs2[k] then
				flag4 = true
				break
			end
		end
	end

	local penReady = petIndex.penReady
	petIndex.eggs = eggs2
	local v16 = handlers.petIndexBlocked()
	petIndex.penReady = next(eggs2) ~= nil and not v16
	if v16 then
		fn45("⏸️ Waiting for steals / events")
		return
	end

	if next(eggs2) then
		fn45(flag3 and "📖 Waiting for index / egg sync" or "🥚 Placing / hatching missing pets")

		if (flag4 or not penReady) and handlers.wakeRiftPen then
			handlers.wakeRiftPen("pet-index")
		end

		return
	end

	local candidateIndex = handlers.candidateIndex
	local v17 = ipairs
	candidateIndex = candidateIndex and candidateIndex.entries or {}

	for _, v18 in v17(candidateIndex) do
		local rec = v18.rec

		if rec and fn46(rec.AssetCategory) and tostring(rec.State) == "Slot" and rec.BottomCFrame and not handlers.isCaptureEventUid(rec.Uid) and fn41(rec.AreaId) and not handlers.riftTargetBlocked(rec.Uid) then
			petIndex.target = tostring(rec.Uid)
			fn45("📖 Collecting " .. rec.AssetCategory)
			return
		end
	end

	fn45("🟡 Waiting for missing index eggs")
end

handlers.stealFeatureEnabled = function()
	local flag2 = fn() and tbl11

	if flag2 then
		flag2 = AutoStealToggle and AutoStealToggle.Value == true or handlers.riftCollecting == true or tbl2.AutoPetIndex == true and handlers.PetIndex.target ~= nil and (tbl13.lockedUid ~= nil or not handlers.petIndexBlocked()) or handlers.greatBloomUnlockNeedsCrane()
	end

	return flag2
end

do
	local function carryLossRecoveryPending()
		local deathRecoveryUid = tbl13.deathRecoveryUid or tbl13.lastDroppedUid
		local str = tostring(tbl13.lastRequestKind or "")
		return deathRecoveryUid ~= nil and tostring(tbl13.lockedUid) == tostring(deathRecoveryUid) and (str == "carry-loss-sync" or str == "death-drop-sync" or str == "carry-drop")
	end

	handlers.carryLossRecoveryPending = carryLossRecoveryPending

	handlers.carryLostInField = function(arg)
		if arg == nil or fn27(arg) then
			return false
		end

		if handlers.carryLossAwaitingProof(arg) then
			return true
		end
		local v14 = fn33()
		local v15 = v14 and fn35(v14.Position)
		return type(v15) == "number" and v15 > 60
	end

	handlers.stealWorkerAlive = function()
		if handlers.stealFeatureEnabled() then
			tbl13.featureGraceAt = 0
			return true
		end

		if not (critical and tbl13.lockedUid ~= nil and tostring(tbl13.lockedUid) == tostring(tbl13.carriedUid) or carryLossRecoveryPending()) then
			tbl13.featureGraceAt = 0
			return false
		end
		local now3 = os.clock()

		if (tonumber(tbl13.featureGraceAt) or 0) <= 0 then
			tbl13.featureGraceAt = now3
		end

		return now3 - tbl13.featureGraceAt <= tbl13.featureGrace
	end

	local function fn45()
		if tbl2.Stall then
			return false
		end

		if not handlers.stealWorkerAlive() then
			return false
		end
		local v14 = carryLossRecoveryPending()
		local flag2 = tbl14.owner == "Steal" and tbl13.lockedUid ~= nil
		if handlers.greatBloomUnlockReturnHasPriority() and not v14 and not critical and not tbl14.critical and not handlers.carryRequestInFlight() then
			return false
		end

		if handlers.adminEventHasPriority() and not v14 and not flag2 and (tbl14.owner == "AdminEvent" or not critical and not tbl14.critical and not handlers.carryRequestInFlight()) then
			return false
		end
		local v15, v16 = fn33()
		if not (v15 and v16 and v16.Health > 0) then
			return false
		end
		local Steal = tbl14.hold("Steal")
		tbl14.stealBeat = os.clock()
		return Steal
	end

	handlers.preserveCarriedReturn = function(carriedUid, arg)
		if carriedUid == nil or not handlers.stealFeatureEnabled() then
			return false
		end
		local v14, v15 = fn33()
		if not (v14 and v15 and v15.Health > 0) then
			return false
		end
		local clamp = math.clamp
		local n2 = os.clock() + clamp(fn34() * 2 + 0.05, 0.12, 0.35)
		local flag2

		while true do
			if fn28(carriedUid) then
				return false
			else
				if fn27(carriedUid) then
					flag2 = true
					break
				end
				local flag3 = false
				if os.clock() >= n2 then
					flag2 = flag3
					break
				end
				RunService.Heartbeat:Wait()
				flag2 = false
				if not fn() then
					break
				end
			end
		end

		if not flag2 or not fn() or not handlers.stealFeatureEnabled() then
			return false
		end
		local v16 = fn25(carriedUid)
		critical = true
		tbl13.carriedUid = carriedUid
		tbl13.lockedUid = carriedUid
		tbl13.rememberPositiveCarry(carriedUid)

		if v16 and v16.AreaId ~= nil then
			handlers.activeGuardAreaId = tostring(v16.AreaId)
		end

		local chsaeCarryRequest = getgenv().__CHSAE_CarryRequest

		if type(chsaeCarryRequest) == "table" and tostring(chsaeCarryRequest.uid) == tostring(carriedUid) then
			chsaeCarryRequest.carrySeen = true
			chsaeCarryRequest.carryActive = true
			chsaeCarryRequest.carryEndedSeen = false
			chsaeCarryRequest.droppedSeen = false
		end

		tbl15.treadmillSuppressed = true
		local v17 = tbl14
		tbl14.stealWants = true
		v17.critical = true
		tbl14.stealBeat = os.clock()

		if tbl14.owner and tbl14.owner ~= "Steal" then
			tbl14.release(tbl14.owner)
		end

		if not tbl14.acquire("Steal") then
			return false
		end
		handlers.returnResumeCount = (handlers.returnResumeCount or 0) + 1
		handlers.lastReturnResumeAt = os.clock()
		handlers.lastReturnResumeReason = tostring(arg or "cancelled")
		handlers.lastReturnResumeUid = carriedUid
		handlers.carry = "📦 Carry: verified · resuming home"
		return true
	end

	local function armDroppedEggReacquire(dropRecoveryRecordUid, arg, dropRecoveryRecord)
		if not dropRecoveryRecordUid then
			dropRecoveryRecordUid = os.clock() - (tonumber(tbl13.dropDetectedAt) or 0) <= 3 and (tbl13.lastDroppedUid or tbl13.deathRecoveryUid) or nil
		end

		local flag2 = type(dropRecoveryRecord) == "table" and tostring(dropRecoveryRecord.State) == "Dropped" and dropRecoveryRecord.BottomCFrame ~= nil and (dropRecoveryRecord.Uid == nil or tostring(dropRecoveryRecord.Uid) == tostring(dropRecoveryRecordUid))
		if dropRecoveryRecordUid == nil or not flag2 and not fn28(dropRecoveryRecordUid) then
			return false
		end

		if flag2 then
			tbl13.dropRecoveryRecord = dropRecoveryRecord
			tbl13.dropRecoveryRecordUid = dropRecoveryRecordUid
			tbl13.dropRecoveryRecordAt = os.clock()
		end

		local flag3 = tostring(tbl13.lastRequestKind) ~= "carry-drop" or tostring(tbl13.lastDroppedUid) ~= tostring(dropRecoveryRecordUid)
		tbl13.lastDroppedUid = dropRecoveryRecordUid

		if (tonumber(tbl13.dropDetectedAt) or 0) <= 0 then
			tbl13.dropDetectedAt = os.clock()
		end

		if flag3 then
			tbl13.dropCount = (tonumber(tbl13.dropCount) or 0) + 1
		end

		local chsaeCarryRequest = getgenv().__CHSAE_CarryRequest

		if type(chsaeCarryRequest) == "table" and tostring(chsaeCarryRequest.uid) == tostring(dropRecoveryRecordUid) and chsaeCarryRequest.carrySeen == true then
			if chsaeCarryRequest.inFlight then
				chsaeCarryRequest.supersededByDrop = true
			end

			if getgenv().__CHSAE_CarryRequest == chsaeCarryRequest then
				getgenv().__CHSAE_CarryRequest = nil
			end
		end

		tbl13.lockedUid = dropRecoveryRecordUid
		tbl13.requestFailureUid = dropRecoveryRecordUid
		tbl13.requestFailureAt = tbl13.dropDetectedAt
		tbl13.lastRequestKind = "carry-drop"
		tbl13.lastRequestError = tostring(arg or "egg dropped during return")
		handlers.pendingDroppedUid = dropRecoveryRecordUid
		handlers.dropReacquireArmedAt = os.clock()

		if tbl2.PersistentSteal then
			tbl13.persistentUid = dropRecoveryRecordUid
		end

		critical = false
		handlers.carry = "📦 Carry: dropped · reclaiming"
		tbl15.treadmillSuppressed = true
		local v14 = tbl14
		tbl14.stealWants = true
		v14.critical = true
		tbl14.stealBeat = os.clock()

		if tbl14.owner ~= "Steal" then
			tbl14.acquireWait("Steal", 0.25)
		end

		if fn12 then
			fn12("reacquire-dropped-egg")
		end

		return true
	end

	handlers.armDroppedEggReacquire = armDroppedEggReacquire

	handlers.activeDroppedRecoveryRecord = function(arg)
		local str = tostring(tbl13.lastRequestKind or "")
		if not (arg ~= nil and tostring(tbl13.lockedUid) == tostring(arg) and (tostring(tbl13.lastDroppedUid) == tostring(arg) or tostring(tbl13.deathRecoveryUid) == tostring(arg))) or str ~= "carry-drop" and str ~= "death-drop-sync" and str ~= "carry-loss-sync" then
			return nil
		end
		local v14 = handlers.getDroppedRecoveryRecord(arg)
		if v14 then
			return v14
		end
		local v15 = fn25(arg)
		if (str == "carry-drop" or str == "death-drop-sync") and v15 and tostring(v15.State) == "Slot" and v15.BottomCFrame then
			return v15
		end
		return nil
	end

	handlers.reconcileCarryLossSnapshot = function(arg)
		local lastDroppedUid = tbl13.lastDroppedUid or tbl13.deathRecoveryUid
		if lastDroppedUid == nil then
			return
		end
		local records
		records = type(arg) == "table" and (arg.Records or arg) or records
		if type(records) ~= "table" then
			return
		end

		for _, record in pairs(records) do
			local flag2 = type(record) == "table"

			if flag2 then
				flag2 = record.Uid or record.UID or record.EggUid
			end

			flag2 = flag2 or nil

			if flag2 ~= nil and tostring(flag2) == tostring(lastDroppedUid) then
				local num = tonumber(record.CarrierUserId)
				local str = tostring(record.State)
				local flag3 = (str == "Slot" or str == "Dropped") and record.BottomCFrame ~= nil or num == localPlayer.UserId

				if tostring(tbl13.deathRecoveryUid) == tostring(lastDroppedUid) then
					if flag3 then
						tbl13.deathRecoveryMissingAt = 0
						tbl13.deathRecoveryMissingReason = ""
					else
						local flag4 = str ~= "Claimed"

						if flag4 then
							flag4 = not (num ~= nil and num > 0 and num ~= localPlayer.UserId)
						end

						if flag4 then
							flag4 = (tonumber(tbl13.deathRecoveryMissingAt) or 0) <= 0
						end

						if flag4 then
							tbl13.deathRecoveryMissingAt = os.clock()
							tbl13.deathRecoveryMissingReason = "snapshot-transitioning"
						end
					end
				end

				if tostring(record.State) == "Dropped" and record.BottomCFrame then
					armDroppedEggReacquire(lastDroppedUid, "full snapshot confirmed dropped egg", record)
				elseif tostring(tbl13.deathRecoveryUid) == tostring(lastDroppedUid) and tostring(record.State) == "Slot" and record.BottomCFrame then
					tbl13.lockedUid = lastDroppedUid

					if fn12 then
						fn12("death-recovery-slot")
					end
				end

				return
			end
		end

		if tostring(tbl13.deathRecoveryUid) == tostring(lastDroppedUid) then
			if (tonumber(tbl13.deathRecoveryMissingAt) or 0) <= 0 then
				tbl13.deathRecoveryMissingAt = os.clock()
			end

			tbl13.deathRecoveryMissingReason = "snapshot-missing"
		end
	end

	handlers.carrySpeedCap = function()
		local num
		num, num = fn33()
		num = num and tonumber(num.WalkSpeed)
		if not num or num ~= num or num <= 0 or num == math.huge then
			return nil
		end
		return math.max(16, math.floor(num * (tonumber(handlers.carrySpeedMultiplier) or 1.8)))
	end

	handlers.getDeliverySpeed = function()
		local num = tonumber(tbl2.StealSpeed)

		if not num or num ~= num or num == math.huge or num == -math.huge then
			num = 700
		end

		return math.clamp(math.floor(num + 0.5), 100, 1000)
	end

	handlers.setDeliverySpeed = function(arg)
		local stealSpeed = tonumber(arg)

		if stealSpeed and stealSpeed == stealSpeed and stealSpeed ~= math.huge and stealSpeed ~= -math.huge then
			tbl2.StealSpeed = stealSpeed
		end

		tbl2.StealSpeed = handlers.getDeliverySpeed()
		return tbl2.StealSpeed
	end

	local function fn46()
		local index = {}
		index.__index = index

		local function fn47(arg, arg2)
			return arg ~= nil and arg2 ~= nil and tostring(arg) == tostring(arg2)
		end

		index.new = function(arg)
			return setmetatable({ a = arg }, index)
		end

		index.begin = function(arg, arg2, arg3)
			if arg.current and arg.current.request == arg2 then
				return arg.current
			end

			if arg.current then
				arg.last = arg.current
			end

			local current = {
				request = arg2,
				uid = arg2.uid,
				category = arg2.category,
				phase = "PICKUP",
				carrySeen = arg3 == true or arg2.carrySeen == true,
				startedAt = arg.a.now(),
			}

			if current.carrySeen then
				current.carryProofAt = arg.a.now()
			end

			arg.current = current
			return current
		end

		index.observeCarry = function(arg, arg2)
			local current = arg.current
			if not current or current.proven or not arg.a.alive(current.request) or type(arg2) ~= "table" then
				return
			end

			if arg2.IsCarrying == true and fn47(arg2.Uid, current.uid) then
				current.carrySeen = true
				current.carryProofAt = current.carryProofAt or arg.a.now()
			end
		end

		index.returning = function(arg)
			local current = arg.current

			if current and current.request.carrySeen then
				current.carryProofAt = current.carryProofAt or arg.a.now()
			end

			if current and current.phase == "PICKUP" then
				current.phase = "RETURN"
			end
		end

		index.movementStarted = function(arg, returnSpeed)
			local current = arg.current

			if current and current.phase == "RETURN" then
				current.returnTweenAt = current.returnTweenAt or arg.a.now()
				current.returnSpeed = returnSpeed
			end
		end

		index.arrived = function(arg)
			local current = arg.current

			if current and current.phase == "RETURN" and arg.a.homeDistance() <= 12 then
				current.homeAt = arg.a.now()
				local deadline = arg.a.now() + 8
				current.phase = "CLAIM"
				current.deadline = deadline
			end
		end

		index.resumeHeldReturn = function(arg)
			local current = arg.current
			if not current or current.proven or current.phase ~= "CLAIM" and current.phase ~= "FAILED" or current.request.deliveryRejected or not arg.a.alive(current.request) or not arg.a.held or not arg.a.held(current.uid) or arg.a.homeDistance() <= 12 then
				return false
			end
			current.phase = "RETURN"
			current.deadline = nil
			current.returnResumes = (current.returnResumes or 0) + 1
			return true
		end

		index.observeClaim = function(arg, arg2)
			local current = arg.current
			if not current or not arg.a.alive(current.request) then
				return nil
			end

			if type(arg2) ~= "table" then
				return false
			end

			if current.phase == "FAILED" then
				return nil
			end
			local flag2 = current.phase == "READY"
			local flag3

			if flag2 then
				flag3 = not fn47(arg2.Uid or arg2.EggUid or arg2.UID, current.uid)
			else
				flag3 = flag2
			end

			if flag3 then
				return nil
			end
			local proven = current.proven

			if not proven then
				proven = not (current.carrySeen or current.request.carrySeen)
			end

			if proven then
				return false
			end

			if arg2.AssetCategory and current.category and arg2.AssetCategory ~= current.category then
				return false
			end
			local uid = arg2.Uid or arg2.EggUid or arg2.UID

			if uid ~= nil then
				if not fn47(uid, current.uid) then
					return false
				end
			elseif current.phase ~= "RETURN" and current.phase ~= "CLAIM" or arg.a.homeDistance() > 12 or current.request.droppedSeen then
				return false
			end

			local v14 = arg.a.now()
			current.proven = true
			current.finishedAt = v14
			current.phase = "DRAIN"
			current.deadline = current.finishedAt + 8
			local request_ = current.request
			current.request.claimSeen = true
			request_.standaloneClaimVerified = true
			current.request.claimFinishedAt = current.finishedAt
			arg.a.halt()
			return true, current.uid
		end

		index.verified = function(arg, arg2)
			local current = arg.current
			local flag2 = current ~= nil and current.proven == true
			local flag3

			if flag2 then
				flag3 = arg2 == nil or fn47(arg2, current.uid)
			else
				flag3 = flag2
			end

			return flag3 and arg.a.alive(current.request)
		end

		index.poll = function(arg)
			local current = arg.current
			if not current then
				return "IDLE"
			end

			if not arg.a.alive(current.request) then
				return "STALE"
			end
			arg:resumeHeldReturn()

			if current.proven then
				if not current.request.inFlight then
					current.phase = "READY"
				else
					local deadline = current.deadline

					if arg.a.now() >= deadline and current.phase ~= "BLOCKED" then
						current.phase = "BLOCKED"
						arg.a.releaseRig("pickup reply still pending after claim")
					end
				end
			else
				local flag2 = current.phase == "CLAIM"

				if flag2 then
					local deadline = current.deadline
					flag2 = arg.a.now() >= deadline
				end

				if flag2 or (current.phase == "RETURN" or current.phase == "CLAIM") and current.request.deliveryRejected then
					current.phase = "FAILED"
					current.failedAt = arg.a.now()
					arg.a.halt()
					arg.a.releaseRig(current.request.deliveryRejected and "server rejected delivery" or "home reached without claim feedback")
				end
			end

			return current.phase
		end

		return index
	end

	local tbl16 = {
		now = os.clock,
		alive = function(arg)
			local v14, v15 = fn33()
			return fn() and arg.character == localPlayer.Character and arg.generation == tbl13.respawnGeneration and v14 ~= nil and v15 ~= nil and v15.Health > 0
		end,
		homeDistance = function()
			local v14, v15 = fn33()
			local v16 = handlers.getTrackStart()
			if not v14 or not v15 or not v16 then
				return math.huge
			end
			local magnitude = (v14.Position - v16.Position + Vector3.new(0, v15.HipHeight, 0)).Magnitude
			local v17 = handlers.getStealStart()
			local n2

			if v17 and v17 ~= v16 then
				n2 = math.min(magnitude, (v14.Position - v17.Position + Vector3.new(0, v15.HipHeight, 0)).Magnitude)
			else
				n2 = magnitude
			end

			return n2
		end,
		held = function(arg)
			local v14 = fn25(arg)
			local flag2 = v14 ~= nil and v14.State == "Carried"

			if flag2 then
				local userId = localPlayer.UserId
				flag2 = tonumber(v14.CarrierUserId) == userId
			end

			return flag2
		end,
		halt = function()
			local devChickenTween = handlers.DevChickenTween
			local lease = devChickenTween and devChickenTween.lease

			if lease and tbl14.owner == lease.owner and localPlayer.Character == lease.character then
				devChickenTween.stopTween(lease, false)
				lease.temporary:Move(Vector3.zero, false)
				lease.root.AssemblyLinearVelocity = Vector3.new(0, lease.root.AssemblyLinearVelocity.Y, 0)
				lease.lastUse = os.clock()
			end
		end,
		releaseRig = function(arg)
			local devChickenTween = handlers.DevChickenTween

			if devChickenTween and devChickenTween.lease and devChickenTween.lease.owner == "Steal" then
				devChickenTween.restore(arg)
			end
		end,
	}

	local v14 = fn46().new(tbl16)
	handlers.StealClaim = v14

	handlers.beginStealClaim = function(arg, arg2)
		return v14:begin(arg, arg2)
	end

	handlers.waitStealClaim = function(arg, arg2)
		local current = v14.current
		if not current or tostring(current.uid) ~= tostring(arg) then
			return false
		end
		v14:arrived()

		while fn() and arg2() do
			if v14:verified(arg) then
				return true
			end
			local v15 = v14:poll()
			if v15 == "FAILED" or v15 == "STALE" or v15 ~= "CLAIM" then
				return false
			end

			if current.request.droppedSeen or fn28(arg) or tostring(tbl13.deathRecoveryUid) == tostring(arg) then
				current.phase = "PICKUP"
				return false
			end
			RunService.Heartbeat:Wait()
		end

		return false
	end

	handlers.serviceStealClaimDrain = function()
		local current = v14.current
		if not current then
			return false
		end
		local v15 = v14:poll()
		if v15 == "STALE" then
			v14.current = nil
			return false
		end

		if v15 == "FAILED" then
			local v16 = fn25(current.uid)

			if not current.request.inFlight and v16 and (v16.State == "Slot" or v16.State == "Dropped") then
				local request_ = current.request

				if getgenv().__CHSAE_CarryRequest == request_ then
					getgenv().__CHSAE_CarryRequest = nil
				end

				v14.last = current
				v14.current = nil
				fn11("🔁 Delivery failed · retrying steal")
				return false
			end

			local flag2

			if v16 then
				flag2 = v16.State == "Claimed"

				if not flag2 then
					flag2 = v16.State == "Carried"

					if flag2 then
						flag2 = (tonumber(v16.CarrierUserId) or 0) > 0
					end

					if flag2 then
						local userId = localPlayer.UserId
						flag2 = tonumber(v16.CarrierUserId) ~= userId
					end
				end
			else
				flag2 = v16
			end

			if not current.request.inFlight and (flag2 or not v16 and current.request.carryEndedSeen == true) then
				local request_ = current.request

				if getgenv().__CHSAE_CarryRequest == request_ then
					getgenv().__CHSAE_CarryRequest = nil
				end

				v14.last = current
				v14.current = nil
				fn11("🔁 Delivery ended · selecting next egg")
				return false
			end

			fn11(current.request.inFlight and "⏳ Delivery failed · waiting for pickup reply" or "⏳ Delivery unverified · waiting for egg state")
			return true
		end

		if not current.proven then
			return false
		end

		if v15 == "READY" then
			local request_ = current.request

			if getgenv().__CHSAE_CarryRequest == request_ then
				getgenv().__CHSAE_CarryRequest = nil
			end

			return false
		end

		handlers.carry = v15 == "BLOCKED" and "📦 Claimed · pickup reply stalled" or "📦 Claimed · finishing pickup reply"
		return true
	end

	local function fn47()
		local index = {}
		index.__index = index

		index.new = function(arg)
			return setmetatable({ character = arg, generation = 0, endedGeneration = 0, running = false }, index)
		end

		index.observe = function(arg, arg2, arg3)
			if arg2 ~= arg.character or type(arg3) ~= "table" then
				return false
			end
			local arguments = arg3.Arguments

			if arguments == nil then
				arguments = {}
			elseif type(arguments) ~= "table" then
				return false
			end

			if arg3.Action == "BeginRagdoll" then
				local v15 = arguments[1]
				if #arguments ~= 1 and #arguments ~= 4 or type(v15) ~= "number" or v15 ~= v15 or v15 < 0 or v15 == math.huge then
					return false
				end
				arg.generation = arg.generation + 1
				arg.expiresAt = os.clock() + v15
				arg.running = true
				return true
			end

			if arg3.Action == "EndRagdoll" and #arguments == 0 and arg.running then
				arg.running = false
				arg.endedGeneration = arg.generation
				return true
			end

			return false
		end

		index.ready = function(arg, arg2, arg3)
			local recovery = arg.recovery
			if not recovery or recovery.character ~= arg.character or arg.recoveryGeneration == nil then
				return false, "recovery observer unavailable"
			end

			if arg.targetLandedAt == nil or not arg.reactionSeen or not arg.request or not arg.request.carryEndedSeen then
				return false, "waiting for bait release and target landing"
			end

			if recovery.running or recovery.endedGeneration <= arg.recoveryGeneration then
				return false, "waiting for server EndRagdoll"
			end

			if arg3 < (tonumber(arg2) or 0) then
				return false, "waiting for replicated recovery deadline"
			end
			return true
		end

		return index
	end

	local v15 = fn47()

	local function fn48()
		return { heading = function(arg, arg2, arg3, arg4)
			local v16 = math.sqrt(arg * arg + arg2 * arg2)
			if v16 < 0.001 then
				return arg3 or 0, arg4 or -1
			end
			return arg / v16, arg2 / v16
		end }
	end

	local v16 = fn48()

	local function fn49()
		local index = {}
		index.__index = index

		index.new = function(arg, arg2, arg3, arg4)
			return setmetatable({ root = arg, humanoid = arg2, bridge = arg3, service = arg4 }, index)
		end

		index.stop = function(arg)
			arg.ragdollHold = nil
			arg.interpolation = nil
			arg.registrationPending = nil
			arg.registrationWaitAt = nil
			arg.correctionObserved = nil
			arg.correctionWaitAt = nil
			arg.correctionLastAt = nil
			arg.pauseSpent = 0
			arg.pauseCredit = 0
			arg.frameWaitSpent = 0
			arg.goal = nil
			arg.holdCFrame = nil
			arg.completedAt = nil
			arg.lastStep = nil

			if arg.tween then
				arg.tween:Cancel()
				arg.tween:Destroy()
				arg.tween = nil
			end
		end

		index.correctionGate = function(arg, correctionLastAt, arg2)
			if arg.correctionActive and arg.correctionActive() then
				if arg.tween then
					arg.tween:Pause()
				end

				if not arg.correctionWaitAt then
					arg.correctionCount = (arg.correctionCount or 0) + 1
				end

				arg.correctionWaitAt = arg.correctionWaitAt or correctionLastAt
				local n2 = math.max(0, correctionLastAt - (arg.correctionLastAt or correctionLastAt))
				arg.correctionSeconds = (arg.correctionSeconds or 0) + n2
				arg.correctionLastAt = correctionLastAt
				local n3 = math.min(n2, math.max(0, 3 - (arg.pauseSpent or 0)))
				arg.pauseSpent = (arg.pauseSpent or 0) + n3
				arg.pauseCredit = (arg.pauseCredit or 0) + n3

				if arg.deadline then
					arg.deadline = arg.deadline + n3
				end

				arg.registrationPending = true
				if correctionLastAt - arg.correctionWaitAt >= 3 then
					return true, "movement registration wait expired: correcting"
				end
				return true
			end

			if arg.correctionWaitAt then
				if not arg2 then
					return true
				end
				arg.correctionWaitAt = nil
				arg.correctionLastAt = nil
				arg.registrationPending = false
				arg.registrationWaitAt = nil
				arg.observed = arg.root.Position
				arg.observedAt = correctionLastAt
				arg.lastStep = correctionLastAt

				if arg.interpolation then
					arg.interpolation = arg.root.Position
				elseif arg.tween then
					local deadline = arg.deadline
					local pauseSpent = arg.pauseSpent
					local pauseCredit = arg.pauseCredit
					arg:setGoal(arg.goal, arg.speed)
					arg.deadline = deadline
					arg.pauseSpent = pauseSpent
					arg.pauseCredit = pauseCredit
				elseif arg.goal and (arg.goal - arg.root.Position).Magnitude > 0.35 then
					local n2 = arg.root.Position - arg.goal

					if arg.ragdollHold and Vector3.new(n2.X, 0, n2.Z).Magnitude <= 0.6 and math.abs(n2.Y) <= 3 then
						arg.goal = arg.root.Position
						arg.holdCFrame = arg:uprightAt(arg.goal)
						return false
					end

					return true, "character relocated"
				end
			end

			return false
		end

		index.setGoal = function(arg, arg2, arg3)
			arg:stop()
			arg.endpointRecovery = false
			arg:faceGoal(arg2)
			arg:startLeg(arg2, arg3)
		end

		index.faceGoal = function(arg, arg2)
			if arg.correctionActive and arg.correctionActive() then
				return
			end
			local position = arg.root.Position
			local n2 = arg2 - position
			local lookVector = arg.root.CFrame.LookVector
			local v17, v18 = v16.heading(lookVector.X, lookVector.Z, arg.headingX, arg.headingZ)
			local v19, v20 = v16.heading(n2.X, n2.Z, v17, v18)
			arg.headingX = v19
			arg.headingZ = v20
			arg.root.CFrame = CFrame.lookAt(position, position + Vector3.new(arg.headingX, 0, arg.headingZ), Vector3.new(0, 1, 0))
		end

		index.startLeg = function(arg, goal, speed)
			if arg.tween then
				arg.tween:Cancel()
				arg.tween:Destroy()
				arg.tween = nil
			end

			arg.goal = goal
			arg.speed = speed
			arg.completedAt = nil
			arg.holdCFrame = nil
			arg.target = arg:uprightAt(goal)
			local n2 = (goal - arg.root.Position).Magnitude / speed
			arg.deadline = os.clock() + n2 + 4
			if (goal - arg.root.Position).Magnitude <= 0.35 then
				arg.holdCFrame = arg.target
				return
			end
			arg.tween = arg.service:Create(arg.root, TweenInfo.new(n2, Enum.EasingStyle.Linear), { CFrame = arg.target })

			if not (arg.correctionActive and arg.correctionActive()) then
				arg.tween:Play()
			end
		end

		index.uprightAt = function(arg, arg2)
			local lookVector = arg.root.CFrame.LookVector
			local v17, v18 = v16.heading(lookVector.X, lookVector.Z, arg.headingX, arg.headingZ)
			arg.headingX = v17
			arg.headingZ = v18
			return CFrame.lookAt(arg2, arg2 + Vector3.new(arg.headingX, 0, arg.headingZ), Vector3.new(0, 1, 0))
		end

		index.step = function(arg, lastStep)
			if not arg.goal then
				return true
			end
			local v17, v18 = arg:correctionGate(lastStep, true)
			if v17 then
				return v18 == nil, v18
			end
			local n2 = arg.lastStep and math.max(0, lastStep - arg.lastStep) or 0.016666666666666666
			arg.lastStep = lastStep

			if arg.interpolation then
				local magnitude = (arg.goal - arg.root.Position).Magnitude

				if arg.bridge and magnitude > 0.35 then
					local v19, v20, str = arg.bridge(arg.root, (arg.goal - arg.root.Position).Unit, arg.speed, magnitude, nil, nil, math.min(magnitude, arg.speed))

					if not v19 then
						if str ~= "renewing" and str ~= "correcting" then
							local v21 = tostring
							str = str or "unavailable"
							return false, "movement registration failed: " .. v21(str)
						end

						arg.registrationPending = true
						arg.registrationWaitAt = arg.registrationWaitAt or lastStep

						if str == "correcting" then
							arg.correctionObserved = true
						end

						local n3 = math.min(n2, math.max(0, 3 - (arg.pauseSpent or 0)))
						arg.pauseSpent = (arg.pauseSpent or 0) + n3
						arg.pauseCredit = (arg.pauseCredit or 0) + n3
						arg.deadline = arg.deadline + n3
						if lastStep - arg.registrationWaitAt >= 1.5 or arg.pauseSpent >= 3 then
							return false, "movement registration wait expired: " .. str
						end
						return true
					end

					if arg.correctionObserved then
						arg.interpolation = arg.root.Position
					end

					arg.correctionObserved = nil
					arg.registrationPending = false
					arg.registrationWaitAt = nil
				end

				if (arg.root.Position - arg.interpolation).Magnitude > 80 then
					return false, "character relocated"
				end
				local n3 = math.min(math.max(0, n2 - 0.1), math.max(0, 8 - (arg.frameWaitSpent or 0)))
				arg.frameWaitSpent = (arg.frameWaitSpent or 0) + n3
				arg.pauseCredit = (arg.pauseCredit or 0) + n3
				arg.deadline = arg.deadline + n3
				if magnitude > 0.35 and lastStep >= arg.deadline then
					return false, "movement timeout"
				end
				local n4 = magnitude > 0.35 and math.min(arg.speed * math.min(n2, 0.1) / magnitude, 1) or 1
				arg.root.CFrame = arg.root.CFrame:Lerp(arg.target, n4)
				arg.interpolation = arg.root.Position

				if n4 >= 1 then
					local target = arg.target
					arg.interpolation = nil
					arg.holdCFrame = target
				end
			end

			if arg.tween then
				local playbackState = arg.tween.PlaybackState
				if playbackState == Enum.PlaybackState.Cancelled then
					return false, "engine tween cancelled"
				end
				local magnitude = (arg.goal - arg.root.Position).Magnitude

				if magnitude <= 0.35 then
					arg.tween:Cancel()
					arg.tween:Destroy()
					arg.tween = nil
					arg.holdCFrame = arg.target
				elseif playbackState == Enum.PlaybackState.Completed then
					arg.completedAt = arg.completedAt or lastStep

					if math.clamp(n2 * 4 + (arg.pingSeconds or 0) * 1.5 + 0.08, 0.16, 0.9) <= lastStep - arg.completedAt then
						if not (not arg.endpointRecovery and magnitude <= 20) then
							return false, arg.endpointRecovery and "tween final approach failed" or "tween ended away from goal"
						end
						arg.endpointRecovery = true
						arg:startLeg(arg.goal, math.clamp(math.min(arg.speed, 500), 100, 500))
					end
				elseif arg.deadline <= lastStep then
					return false, "movement timeout"
				end
			end

			if not arg.tween and arg.holdCFrame then
				local n3 = arg.root.Position - arg.holdCFrame.Position
				local n4 = math.clamp(n2, 0, 0.25)
				local n5 = math.max(3, workspace.Gravity * n4 * n4 + 2)
				if not arg.ragdollHold and (math.sqrt(n3.X * n3.X + n3.Z * n3.Z) > 6 or math.abs(n3.Y) > n5) then
					return false, "character relocated during hold"
				end
				arg.root.CFrame = arg.holdCFrame
			end

			local root = arg.root
			arg.root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			arg.humanoid:Move(Vector3.zero, false)
			return true
		end

		index.relocate = function(arg, arg2)
			arg:stop()
			if arg.correctionActive and arg.correctionActive() then
				return false
			end
			arg:faceGoal(arg2)
			arg.root.CFrame = arg:uprightAt(arg2)
			local root = arg.root
			arg.root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			return true
		end

		index.holdAt = function(arg, goal, arg2)
			if not arg:relocate(goal) then
				return false
			end
			arg.ragdollHold = arg2 == true
			local v17 = arg:uprightAt(goal)
			arg.goal = goal
			arg.holdCFrame = v17
			return true
		end

		index.interpolateTo = function(arg, goal, speed)
			assert(type(speed) == "number" and speed > 0 and speed < math.huge, "invalid interpolation speed")
			arg:stop()
			arg:faceGoal(goal)
			local v17 = arg:uprightAt(goal)
			arg.goal = goal
			arg.speed = speed
			arg.target = v17
			local position = arg.root.Position
			arg.lastStep = os.clock()
			arg.interpolation = position
			arg.deadline = arg.lastStep + (goal - arg.root.Position).Magnitude / speed + 4
		end

		index.returnHome = function(arg, arg2, arg3)
			arg:interpolateTo(arg2, arg3)
		end

		index.destroy = function(arg)
			arg:stop()
		end

		return index
	end

	local v17 = fn49()

	local function fn50()
		local index = {}
		index.__index = index

		index.new = function(arg, arg2, arg3, arg4)
			return setmetatable({ player = arg, character = arg2, original = arg3, camera = arg4, subject = arg4 and arg4.CameraSubject }, index)
		end

		index.rebindAnimations = function(arg, arg2)
			local animate = arg.character:FindFirstChild("Animate")
			if arg.player.Character ~= arg.character or not animate or not animate:IsA("LocalScript") or not animate.Enabled then
				return
			end
			animate.Enabled = false
			arg2 = arg2 and arg2:FindFirstChildOfClass("Animator")

			if arg2 then
				for _, v18 in ipairs(arg2:GetPlayingAnimationTracks()) do
					v18:Stop(0)
				end
			end

			animate.Enabled = true
		end

		index.attach = function(arg, arg2)
			assert(arg.player.Character == arg.character and arg.original.Parent == arg.character, "character changed before Humanoid replacement")

			if arg2 then
				arg.nativeBody = true
				local breakJointsOnDeath = arg.original.BreakJointsOnDeath
				arg.autoRotate = arg.original.AutoRotate
				arg.breakJointsOnDeath = breakJointsOnDeath
				arg.attached = true
				return arg.original
			end

			local archivable = arg.original.Archivable
			arg.original.Archivable = true

			local ok, replacement = pcall(function()
				return arg.original:Clone()
			end)

			arg.original.Archivable = archivable

			if not ok then
				error(replacement)
			end

			assert(replacement, "Humanoid clone unavailable")
			arg.replacement = replacement
			replacement.Name = arg.original.Name
			arg.original.Parent = nil
			replacement.Parent = arg.character
			arg:rebindAnimations(arg.original)

			if arg.camera and arg.camera.CameraSubject == arg.original then
				arg.camera.CameraSubject = replacement
			end

			arg.attached = true
			return replacement
		end

		index.restore = function(arg)
			if arg.restored then
				return
			end

			if arg.nativeBody then
				if arg.player.Character == arg.character and arg.original.Parent == arg.character then
					if arg.original.AutoRotate == false then
						arg.original.AutoRotate = arg.autoRotate
					end

					if arg.original.BreakJointsOnDeath == false then
						arg.original.BreakJointsOnDeath = arg.breakJointsOnDeath
					end
				end

				arg.restored = true
				return
			end

			local replacement = arg.replacement
			local humanoid = arg.character:FindFirstChildOfClass("Humanoid")
			local flag2 = arg.player.Character == arg.character

			if flag2 and (humanoid == replacement or humanoid == nil or humanoid == arg.original) then
				if replacement and replacement.Parent == arg.character then
					replacement.Parent = nil
				end

				if arg.original.Parent == nil then
					arg.original.Parent = arg.character
				end

				if humanoid ~= arg.original then
					arg:rebindAnimations(replacement)
				end
			end

			if arg.camera and replacement and arg.camera.CameraSubject == replacement then
				if flag2 and arg.original.Parent == arg.character then
					arg.camera.CameraSubject = arg.subject
				elseif arg.player.Character then
					local humanoid2 = arg.player.Character:FindFirstChildOfClass("Humanoid")

					if humanoid2 then
						arg.camera.CameraSubject = humanoid2
					end
				end
			end

			if replacement then
				replacement:Destroy()
			end

			if not flag2 and arg.original.Parent == nil then
				arg.original:Destroy()
			end

			arg.restored = true
		end

		return index
	end

	local v18 = fn50()

	local function fn51()
		local index = {}
		index.__index = index
		setmetatable(index, { __index = v17 })

		index.new = function(arg, arg2, arg3, arg4)
			arg2.AutoRotate = false
			return setmetatable(v17.new(arg, arg2, arg3, arg4), index)
		end

		index.setGoal = function(arg, goal, speed)
			assert(type(speed) == "number" and speed > 0 and speed < math.huge, "invalid movement speed")
			arg:stop()
			arg.goal = goal
			arg.speed = speed
			arg.target = arg:uprightAt(goal)
			local position = arg.root.Position
			arg.lastStep = os.clock()
			arg.observed = position
			arg.deadline = arg.lastStep + (goal - arg.observed).Magnitude / speed + 8
		end

		index.interpolateTo = function(arg, arg2, arg3)
			arg:setGoal(arg2, arg3)
		end

		index.returnHome = function(arg, arg2, arg3)
			arg:setGoal(arg2, arg3)
		end

		index.waitForMovement = function(arg, lastStep, arg2, arg3)
			arg.registrationPending = true
			arg.registrationWaitAt = arg.registrationWaitAt or lastStep
			arg.observed = arg.root.Position
			arg.lastStep = lastStep
			local n2 = math.min(arg2, math.max(0, 8 - (arg.pauseSpent or 0)))
			arg.pauseSpent = (arg.pauseSpent or 0) + n2
			arg.pauseCredit = (arg.pauseCredit or 0) + n2
			arg.deadline = arg.deadline + n2

			if arg3 == "correcting" then
				if not arg.correctionObserved then
					arg.correctionCount = (arg.correctionCount or 0) + 1
				end

				arg.correctionObserved = true
				arg.correctionSeconds = (arg.correctionSeconds or 0) + arg2
			end

			if lastStep - arg.registrationWaitAt >= 8 then
				return false, "movement registration wait expired: " .. arg3
			end
			return true
		end

		index.step = function(arg, lastStep)
			if not arg.goal then
				return true
			end
			local n2 = math.max(0, lastStep - arg.lastStep)
			arg.lastStep = lastStep
			if arg.correctionActive and arg.correctionActive() then
				return arg:waitForMovement(lastStep, n2, "correcting")
			end

			if arg.correctionObserved then
				arg.correctionObserved = nil
				arg.observed = arg.root.Position
				arg.target = arg:uprightAt(arg.goal)
			end

			local n3 = arg.root.Position - arg.observed
			local flag2 = arg.holdCFrame ~= nil
			local magnitude = Vector3.new(n3.X, 0, n3.Z).Magnitude
			local n4 = math.max(3, workspace.Gravity * math.min(n2, 0.25) ^ 2 + 2)
			if magnitude > (flag2 and 6 or 80) or flag2 and math.abs(n3.Y) > n4 or not flag2 and n3.Magnitude > 80 then
				return false, flag2 and "character relocated during hold" or "character relocated"
			end
			local n5 = arg.goal - arg.root.Position
			local magnitude2 = n5.Magnitude
			local n6 = math.min(magnitude2, arg.speed * math.min(n2, 0.1), 60)

			if magnitude2 > 0.01 and arg.bridge then
				local v19, v20, str = arg.bridge(arg.root, n5.Unit, arg.speed, magnitude2, nil, nil, math.min(magnitude2, math.max(n6, arg.speed * 0.2)))

				if not v19 then
					if str ~= "renewing" and str ~= "correcting" then
						local v21 = tostring
						str = str or "unavailable"
						return false, "movement registration failed: " .. v21(str)
					end

					return arg:waitForMovement(lastStep, n2, str)
				end
			end

			arg.registrationPending = false
			arg.registrationWaitAt = nil
			local n7 = math.min(math.max(0, n2 - math.min(n2, 0.1, 60 / arg.speed)), math.max(0, 8 - (arg.frameWaitSpent or 0)))
			arg.frameWaitSpent = (arg.frameWaitSpent or 0) + n7
			arg.pauseCredit = (arg.pauseCredit or 0) + n7
			arg.deadline = arg.deadline + n7
			if magnitude2 > 0.35 and lastStep >= arg.deadline then
				return false, "movement timeout"
			end

			if magnitude2 > 0.01 then
				arg.root.CFrame = arg.root.CFrame:Lerp(arg.target, math.min(1, n6 / magnitude2))
			end

			arg.observed = arg.root.Position
			arg.holdCFrame = (arg.goal - arg.observed).Magnitude <= 0.35 and arg.target or nil
			local root = arg.root
			arg.root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			arg.humanoid:Move(Vector3.zero, false)
			return true
		end

		index.relocate = function(arg, arg2, arg3)
			arg:stop()
			if arg.correctionActive and arg.correctionActive() then
				return false, "correcting"
			end
			local n2 = arg2 - arg.root.Position
			local magnitude = n2.Magnitude
			arg3 = arg3 or 500
			if magnitude > math.min(6, arg3 / 60) then
				return false, "target requires tween"
			end

			if magnitude > 0.01 then
				if not arg.bridge then
					return false, "movement registration unavailable"
				end
				local v19, v20, v21 = arg.bridge(arg.root, n2.Unit, arg3, magnitude, nil, nil, magnitude)
				if not v19 then
					return false, v21
				end
				arg.root.CFrame = arg:uprightAt(arg2)
			end

			local root = arg.root
			arg.root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			arg.observed = arg.root.Position
			return true
		end

		index.teleportTo = function(arg, arg2, arg3, arg4)
			arg:stop()
			local state2 = arg4 and arg4.state
			if not state2 or not arg4.token or type(arg4.sample) ~= "function" or type(arg4.adopt) ~= "function" or not arg.root.Parent or state2.Character ~= arg.root.Parent or arg.humanoid.Parent ~= arg.root.Parent or state2.RootPart ~= arg.root or state2.Humanoid ~= arg.humanoid then
				return false, "native teleport baseline unavailable"
			end

			if state2.CorrectionContext or arg.correctionActive and arg.correctionActive() then
				return false, "correcting"
			end

			local ok, result = pcall(function()
				arg.root.CFrame = arg:uprightAt(arg2)
				local root = arg.root
				arg.root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
				local walkSpeed = arg.humanoid.WalkSpeed
				local v19 = arg4.sample(state2, os.clock(), walkSpeed)
				assert(type(v19) == "table" and typeof(v19.Position) == "Vector3" and (v19.Position - arg.root.Position).Magnitude <= 0.01, "native teleport sample unavailable")
				arg4.adopt(arg4.token, state2, v19)
				assert(state2.LastSample == v19 and not state2.ValidationLocked, "native teleport baseline rejected")
			end)

			arg.observed = arg.root.Position
			if not ok then
				return false, tostring(result)
			end
			arg:setGoal(arg2, arg3)
			arg.holdCFrame = arg.target
			return true
		end

		index.holdAt = function(arg, arg2, arg3, arg4)
			local v19, v20 = arg:relocate(arg2, arg4)
			if not v19 then
				return false, v20
			end
			arg:setGoal(arg2, arg4 or 500)
			return true
		end

		index.syncBaseline = function(arg, arg2)
			if type(arg2) ~= "table" or arg2.Character ~= arg.root.Parent or not arg.root.Parent or arg2.RootPart ~= arg.root or arg2.Humanoid ~= arg.humanoid or arg.humanoid.Parent ~= arg.root.Parent or arg.humanoid.Health <= 0 then
				return false, "baseline rig unavailable"
			end

			if arg2.CorrectionContext then
				return true, "correcting"
			end
			local historyCapacity = arg2.HistoryCapacity
			local safeGroundCheckpointCapacity = arg2.SafeGroundCheckpointCapacity
			if type(historyCapacity) ~= "number" or historyCapacity % 1 ~= 0 or historyCapacity < 1 or historyCapacity > 128 or type(safeGroundCheckpointCapacity) ~= "number" or safeGroundCheckpointCapacity % 1 ~= 0 or safeGroundCheckpointCapacity < 1 or safeGroundCheckpointCapacity > 32 or type(arg2.SampleHistory) ~= "table" or type(arg2.SafeGroundCheckpoints) ~= "table" or type(arg2.LastSample) ~= "table" then
				return false, "baseline schema unavailable"
			end
			local root = arg.root
			local position = root.Position
			local cFrame = root.CFrame
			local assemblyLinearVelocity = root.AssemblyLinearVelocity
			local assemblyAngularVelocity = root.AssemblyAngularVelocity
			local n2 = math.max(arg.humanoid.WalkSpeed, (arg.speed or 500) * 1.35)

			local function fn52(arg3)
				if type(arg3) ~= "table" or typeof(arg3.Position) ~= "Vector3" then
					return
				end
				local v19 = cFrame
				arg3.Position = position
				arg3.CFrame = v19
				local v20 = assemblyAngularVelocity
				local v21 = n2
				arg3.LinearVelocity = assemblyLinearVelocity
				arg3.AngularVelocity = v20
				arg3.WalkSpeed = v21
			end

			fn52(arg2.LastObservedSample)
			fn52(arg2.LastGameplayTrustedSample)
			fn52(arg2.LastValidatedSample)
			fn52(arg2.LastSample)
			fn52(arg2.LastGoodSample)
			fn52(arg2.LastValidatedGroundedSample)
			fn52(arg2.LastConfirmedGroundSample)
			fn52(arg2.CandidateGroundedSample)

			for i = 1, historyCapacity do
				fn52(arg2.SampleHistory[i])
			end

			for i = 1, safeGroundCheckpointCapacity do
				fn52(arg2.SafeGroundCheckpoints[i])
			end

			local impulseContext = arg2.ImpulseContext

			if type(impulseContext) == "table" then
				if typeof(impulseContext.OriginPosition) == "Vector3" then
					impulseContext.OriginPosition = position
				end

				fn52(impulseContext.PreMovementSafeSample)
			end

			arg.baselineUpdates = (arg.baselineUpdates or 0) + 1
			return true
		end

		return index
	end

	local v19 = fn51()

	local devChickenTween = {
		enabled = true,
		lease = nil,
		phase = "idle",
		reason = "ready",
		launches = 0,
		engine = "r84 continuous baseline",
	}

	handlers.DevChickenTween = devChickenTween

	devChickenTween.persistentAlive = function()
		local persistent = devChickenTween.persistent
		return persistent ~= nil and fn() and localPlayer.Character == persistent.character and persistent.root.Parent == persistent.character and persistent.original.Parent == nil and persistent.temporary.Parent == persistent.character and persistent.original.Health > 0 and persistent.temporary.Health > 0
	end

	devChickenTween.restorePersistent = function(reason)
		local persistent = devChickenTween.persistent
		if not persistent then
			return true
		end

		local ok, result = pcall(function()
			persistent.rig:restore()
			devChickenTween.syncHandoff(persistent)
		end)

		if not ok then
			devChickenTween.reason = "persistent restore failed: " .. tostring(result)
			return false
		end
		devChickenTween.persistent = nil
		devChickenTween.reason = reason or "persistent rig restored"
		return true
	end

	devChickenTween.alive = function(arg)
		local flag2 = devChickenTween.lease == arg and not arg.cancelled and fn() and localPlayer.Character == arg.character and arg.root.Parent == arg.character and arg.original.Health > 0 and arg.temporary.Health > 0 and (arg.nativeBody and arg.temporary == arg.original and arg.original.Parent == arg.character or not arg.nativeBody and arg.original.Parent == nil and arg.temporary.Parent == arg.character) and not arg.root.Anchored and not arg.temporary.Sit

		if flag2 then
			local lastUse = arg.lastUse
			flag2 = os.clock() - lastUse < 45
		end

		flag2 = flag2 and (tbl14.owner == arg.owner or arg.owner == "Steal" and devChickenTween.enabled and tbl14.owner == nil)

		if flag2 then
			flag2 = arg.progression and arg.keepGoing()

			if not flag2 then
				flag2 = not arg.progression

				if flag2 then
					flag2 = tbl2.Stall or handlers.stealFeatureEnabled() or arg.rift and tbl2.AutoLab and handlers.stealWorkerAlive()
				end
			end
		end

		return flag2
	end

	devChickenTween.stopTween = function(arg, arg2)
		if arg2 then
			arg.mover:holdAt(arg.root.Position)
		else
			arg.mover:stop()
		end

		local holdCFrame = arg.mover.holdCFrame
		arg.tween = arg.mover.tween
		arg.holdCFrame = holdCFrame
	end

	devChickenTween.syncHandoff = function(arg)
		if arg.nativeBody then
			return true
		end

		if arg.handoffSynced then
			return true
		end
		local handoffBridge = arg.handoffBridge
		local state2 = handoffBridge and handoffBridge.state
		if not state2 or localPlayer.Character ~= arg.character or arg.original.Parent ~= arg.character or state2.Character ~= arg.character or state2.RootPart ~= arg.root or state2.Humanoid ~= arg.original then
			return true
		end
		local walkSpeed = arg.original.WalkSpeed
		local v20 = handoffBridge.sample(state2, os.clock(), walkSpeed)
		assert(type(v20) == "table" and typeof(v20.Position) == "Vector3" and (v20.Position - arg.root.Position).Magnitude <= 0.01, "native handoff sample unavailable")
		handoffBridge.adopt(handoffBridge.token, state2, v20)
		arg.handoffSynced = true
		return true
	end

	devChickenTween.restore = function(arg)
		local lease = devChickenTween.lease
		local v20 = devChickenTween
		local v21 = devChickenTween
		local reason = arg or "restored"
		local phase = devChickenTween.enabled and "idle" or "off"
		v20.reason = reason
		v21.phase = phase
		if not lease then
			return true
		end
		local stopReason = arg or "restored"
		lease.cancelled = true
		lease.stopReason = stopReason

		if lease.connection then
			lease.connection:Disconnect()
			lease.connection = nil
		end

		if lease.postConnection then
			lease.postConnection:Disconnect()
			lease.postConnection = nil
		end

		if lease.referenceHeartbeat then
			lease.referenceHeartbeat:Disconnect()
			lease.referenceHeartbeat = nil
		end

		local ok, result = pcall(function()
			if lease.mover then
				lease.mover:destroy()
			end

			if lease.temporary and lease.temporary.Parent == lease.character and lease.autoRotate ~= nil then
				lease.temporary.AutoRotate = lease.autoRotate
			end

			if not (devChickenTween.persistent and devChickenTween.persistent.rig == lease.rig and devChickenTween.persistentAlive()) then
				lease.rig:restore()

				if localPlayer.Character == lease.character and lease.original.Parent == lease.character then
					devChickenTween.syncHandoff(lease)
				end

				if devChickenTween.persistent and devChickenTween.persistent.rig == lease.rig then
					devChickenTween.persistent = nil
				end
			end
		end)

		if lease.restoreControls and lease.controls then
			if pcall(function()
				lease.controls:Enable()
			end) then
				lease.restoreControls = false
			end
		end

		if not ok then
			devChickenTween.reason = "restore failed: " .. tostring(result)
			return false
		end
		devChickenTween.lease = nil
		return true
	end

	devChickenTween.syncStealBaseline = function(arg)
		arg.baselineActive = false
		if arg.owner ~= "Steal" or not arg.nativeBody or not arg.mover.goal or not arg.mover.syncBaseline then
			return
		end
		local v20, v21 = arg.mover:syncBaseline(state)
		arg.baselineActive = v20 and v21 == nil
	end

	devChickenTween.begin = function(arg, arg2, arg3)
		arg2 = arg2 or "Steal"
		local flag2 = arg2 == "Place" or arg2 == "Mutate" or arg2 == "Treadmill"
		if arg2 ~= "Steal" and not flag2 then
			return false, "invalid movement owner"
		end

		if flag2 and (type(arg3) ~= "function" or not arg3()) then
			return false, "cancelled"
		end

		if not devChickenTween.enabled and arg ~= true then
			return false, "Tween disabled"
		end

		if devChickenTween.lease and devChickenTween.lease.owner ~= arg2 then
			return false, "another movement owns the rig"
		end

		if devChickenTween.lease and devChickenTween.alive(devChickenTween.lease) then
			devChickenTween.lease.lastUse = os.clock()
			return true
		end

		if not devChickenTween.restore("starting") then
			return false, devChickenTween.reason
		end
		local flag3 = false

		if devChickenTween.persistent and (not flag3 or not devChickenTween.persistentAlive()) then
			if not devChickenTween.restorePersistent("movement setup") then
				return false, devChickenTween.reason
			end
		end

		local v20 = nil
		local v21, original = fn33()

		if v20 then
			original = v20.original
		end

		local character = localPlayer.Character
		if not v21 or not original or original.Health <= 0 or v21.Anchored or original.Sit or tbl14.owner ~= arg2 then
			return false, "character activity unavailable"
		end

		if state and state.RootPart == v21 and state.Humanoid ~= original then
			return false, "another movement controller owns the Humanoid"
		end

		if handlers.movementInitializing(original) then
			return false, "character movement initializing"
		end

		local lease = {
			character = character,
			root = v21,
			original = original,
			owner = arg2,
			progression = flag2,
			keepGoing = arg3,
			handoffBridge = v20 and v20.handoffBridge or v10,
			nativeBody = true,
			delivery = arg == true,
		}

		lease.rift = type(tbl13.webhookTarget) == "table" and tbl13.webhookTarget.source == "rift"
		lease.lastUse = os.clock()
		lease.speed = 500
		lease.recovery = v15.new(character)
		lease.rig = v20 and v20.rig or v18.new(localPlayer, character, original, workspace.CurrentCamera)
		devChickenTween.lease = lease

		local ok, result = pcall(function()
			lease.referenceMovement = arg2 == "Steal"
			lease.controls = require(localPlayer.PlayerScripts.PlayerModule):GetControls()
			lease.restoreControls = lease.controls.controlsEnabled == true
			lease.controls:Disable()
			lease.temporary = v20 and v20.temporary or lease.rig:attach(lease.nativeBody)
			lease.autoRotate = lease.temporary.AutoRotate

			if flag3 then
				lease.temporary.BreakJointsOnDeath = false

				if not v20 then
					devChickenTween.persistent = lease
					handlers.watchStealHumanoid(character)
				end
			end

			lease.registration = {
				checks = 0,
				renewed = 0,
				reused = 0,
				renewing = 0,
				correcting = 0,
				failed = 0,
				baseline = 0,
				workMs = 0,
				maxWorkMs = 0,
			}

			local function fn52(arg4, arg5, ...)
				local flag4 = typeof(arg5) == "Vector3" and arg5.Magnitude > 0 and math.abs(arg5.Unit.Y) > 0.1 or state ~= nil and rawget(state, "IsSupportedNow") == false

				if lease.baselineActive and not flag4 then
					local registration = lease.registration
					registration.baseline = registration.baseline + 1
					return true, true, nil
				end

				local now3 = os.clock()
				local v22 = fn44
				local v23 = table.pack(...)
				v23.n = 3 + v23.n - 1
				table.move(v23, 1, v23.n, 3, v23)
				v23[1] = arg4
				v23[2] = arg5
				local v24, v25, v26 = v22(table.unpack(v23, 1, v23.n))
				local registration = lease.registration
				local n2 = (os.clock() - now3) * 1000
				registration.checks = registration.checks + 1
				registration.workMs = registration.workMs + n2
				registration.maxWorkMs = math.max(registration.maxWorkMs, n2)
				registration.lastReason = v26 or v24 and (v25 and "reused" or "renewed") or "unavailable"
				registration.lastAt = os.clock()

				if v24 then
					if v25 then
						registration.reused = registration.reused + 1
					else
						registration.renewed = registration.renewed + 1
					end
				elseif v26 == "renewing" then
					registration.renewing = registration.renewing + 1
				elseif v26 == "correcting" then
					registration.correcting = registration.correcting + 1
				else
					registration.failed = registration.failed + 1
				end

				return v24, v25, v26
			end

			local v22 = lease
			local new = (lease.referenceMovement and v19 or v17).new
			local temporary = lease.temporary
			local nativeBody = lease.nativeBody

			if nativeBody then
				nativeBody = arg2 == "Steal" and fn52 or fn44
			end

			v22.mover = new(v21, temporary, nativeBody or nil, TweenService)

			lease.mover.correctionActive = function()
				return lease.nativeBody and state and rawget(state, "CorrectionContext") ~= nil
			end

			lease.mover.pingSeconds = math.clamp(fn34(), 0, 1)

			lease.connection = RunService.PreSimulation:Connect(function()
				if not devChickenTween.alive(lease) then
					devChickenTween.restore("movement released")
					return
				end

				if tbl14.owner ~= lease.owner then
					return
				end

				local ok, result, result2 = pcall(function()
					devChickenTween.syncStealBaseline(lease)
					local v23, v24 = lease.mover:step(os.clock())

					if v23 then
						devChickenTween.syncStealBaseline(lease)
					end

					return v23, v24
				end)

				if not ok or not result then
					devChickenTween.restore(not ok and tostring(result) or result2)
					return
				end
				local v23 = lease
				local holdCFrame = lease.mover.holdCFrame
				lease.tween = lease.mover.tween
				v23.holdCFrame = holdCFrame
			end)
		end)

		if not ok then
			devChickenTween.restore("setup failed: " .. tostring(result))
			return false, tostring(result)
		end
		local v22 = devChickenTween
		local v23 = devChickenTween
		local reason = lease.nativeBody and "real body active" or "r17 replacement active"
		v22.phase = "staging"
		v23.reason = reason
		return true
	end

	devChickenTween.move = function(goal, arg, arg2, arg3, arg4, speed, arg5)
		local lease = devChickenTween.lease
		if not lease or not devChickenTween.alive(lease) or tbl14.owner ~= lease.owner then
			return false, "Tween rig unavailable"
		end
		local ticket = {}
		speed = speed or handlers.getDeliverySpeed()
		lease.ticket = ticket
		lease.goal = goal
		lease.speed = speed
		local flag2 = false

		local ok, result, result2 = pcall(function()
			if not arg2() or arg4 and arg4() then
				return false, "cancelled"
			end

			if arg3 and arg3() then
				flag2 = true
				return true
			end

			if arg5 and lease.owner == "Steal" then
				lease.mover:returnHome(goal, lease.speed)
			else
				lease.mover:setGoal(goal, lease.speed)
			end

			local stealClaim = handlers.StealClaim

			if lease.owner == "Steal" and stealClaim and stealClaim.movementStarted then
				stealClaim:movementStarted(lease.speed)
			end

			local n2 = (goal - lease.root.Position).Magnitude / lease.speed
			local n3 = os.clock() + n2 + 8

			while devChickenTween.alive(lease) and lease.ticket == ticket do
				lease.lastUse = os.clock()
				if tbl14.owner ~= lease.owner or not arg2() or arg4 and arg4() then
					return false, "cancelled"
				end

				if arg3 and arg3() then
					flag2 = true
					return true
				end

				if (lease.root.Position - goal).Magnitude <= (arg or 0.35) then
					return true
				end

				if n3 <= os.clock() then
					return false, "movement timeout"
				end
				RunService.Heartbeat:Wait()
			end

			return false, lease.stopReason or "Tween interrupted"
		end)

		if devChickenTween.lease == lease and lease.ticket == ticket and not lease.cancelled then
			devChickenTween.stopTween(lease, ok and result == true and not flag2)
		end

		if not ok then
			devChickenTween.restore("Tween error")
			return false, tostring(result)
		end
		return result, result2
	end

	devChickenTween.groundMove = function(arg, arg2, arg3, arg4, arg5, arg6, arg7)
		if not devChickenTween.lease then
			return false, "Tween rig unavailable"
		end
		return devChickenTween.move(Vector3.new(arg.X, fn39(arg.X, arg.Z, arg.Y) or arg.Y, arg.Z), arg2, arg3, arg4, arg5, arg6, arg7)
	end

	devChickenTween.returnHome = function(arg, arg2)
		local lease = devChickenTween.lease
		local v20 = handlers.getStealStart()
		if not lease or not v20 then
			return false, "home unavailable"
		end
		local stealClaim = handlers.StealClaim

		if stealClaim then
			stealClaim:returning()
		end

		local function fn52()
			return stealClaim and stealClaim:verified()
		end

		local n2 = math.min(handlers.getDeliverySpeed(), handlers.carrySpeedCap() or math.huge)
		local v21, v22 = devChickenTween.move(handlers.stealStartPosition(v20, lease.temporary), 0.35, arg, fn52, arg2, n2, true)
		if not v21 then
			return false, v22
		end

		if stealClaim and not fn52() then
			stealClaim:arrived()
		end

		devChickenTween.phase = fn52() and "claim verified" or "claim wait"
		return true
	end

	handlers.prepareMovementOwner = function(arg)
		local lease = devChickenTween.lease
		if lease and lease.owner ~= arg and not devChickenTween.restore("handoff to " .. tostring(arg)) then
			return false
		end

		if devChickenTween.persistent and arg ~= "Steal" then
			return devChickenTween.restorePersistent("handoff to " .. tostring(arg))
		end
		return true
	end

	handlers.progressionTweenTo = function(arg, arg2, arg3, arg4)
		if arg ~= "Place" and arg ~= "Mutate" and arg ~= "Treadmill" then
			return false, "invalid progression owner"
		end

		if devChickenTween.lease and not devChickenTween.restore("progression handoff") then
			return false, devChickenTween.reason
		end
		local v20, v21 = devChickenTween.begin(true, arg, arg4)
		if not v20 then
			return false, v21
		end
		local ok, result, result2 = pcall(devChickenTween.groundMove, arg2, arg3, arg4, nil, nil, 500)
		if not devChickenTween.restore("progression arrival") then
			return false, devChickenTween.reason
		end

		if not ok then
			return false, tostring(result)
		end
		return result, result2
	end

	getgenv().__CHSAE_TPRestore = function(arg)
		if not devChickenTween.restore(arg or "unload") then
			return false
		end
		return devChickenTween.restorePersistent(arg or "unload")
	end

	devChickenTween.prime = function()
		if not fn() or devChickenTween.lease or devChickenTween.persistentAlive() or tbl14.owner ~= nil or tbl14.treadmillTraining then
			return
		end
		local v20, v21 = fn33()
		if not v20 or not v21 or v20.Anchored or v21.Sit or v21.Health <= 0 then
			return
		end

		if not tbl14.acquire("Steal") then
			return
		end
		local ok, result, result2 = pcall(devChickenTween.begin, true)
		devChickenTween.restore("startup Steal rig prepared")
		tbl14.release("Steal")

		if not ok or not result then
			devChickenTween.reason = tostring(ok and result2 or result)
		end
	end

	getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = localPlayer.CharacterAdded:Connect(function(character)
		task.delay(0.75, function()
			if fn() and localPlayer.Character == character then
				devChickenTween.prime()
			end
		end)
	end)

	getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = RunService.Heartbeat:Connect(function()
		local lease = devChickenTween.lease

		if lease then
			lease = lease.cancelled or not devChickenTween.alive(lease)
		end

		if lease then
			devChickenTween.restore("movement cancelled")
		end

		if not devChickenTween.lease and devChickenTween.persistent and not devChickenTween.persistentAlive() then
			devChickenTween.restorePersistent("character changed")
		end
	end)

	local HttpService2 = game:GetService("HttpService")
	local packages2 = ReplicatedStorage:FindFirstChild("Packages")
	packages2 = packages2 and packages2:FindFirstChild("Networking")
	packages2 = packages2 and packages2:FindFirstChild("RE/RigSync/Refresh")
	devChickenTween.recoveryEventReady = packages2 ~= nil and packages2:IsA("RemoteEvent")

	if devChickenTween.recoveryEventReady then
		getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = packages2.OnClientEvent:Connect(function(arg)
			local lease = devChickenTween.lease
			if not fn() or not lease or not lease.recovery or lease.cancelled or localPlayer.Character ~= lease.character or type(arg) ~= "string" or #arg > 16384 then
				return
			end
			local ok, result = pcall(HttpService2.JSONDecode, HttpService2, arg)

			if ok then
				lease.recovery:observe(localPlayer.Character, result)
			end
		end)
	end

	handlers.leaveScrambleArena = function(arg)
		local scrambleArena = workspace:FindFirstChild("ScrambleArena")
		scrambleArena = scrambleArena and scrambleArena:FindFirstChild("LeaveTeleport")
		scrambleArena = scrambleArena and scrambleArena:FindFirstChild("Hitbox", true)
		if not (scrambleArena and scrambleArena:IsA("BasePart")) then
			return false
		end

		handlers.walkTo(scrambleArena.Position, function()
			return arg() and localPlayer:GetAttribute("InScrambleArena") == true
		end, 1)

		local n2 = os.clock() + 5

		while os.clock() < n2 and localPlayer:GetAttribute("InScrambleArena") == true do
			task.wait(0.1)
		end

		return localPlayer:GetAttribute("InScrambleArena") ~= true
	end

	handlers.portalDetour = function(arg, arg2)
		local scrambleArenaPortal = workspace:FindFirstChild("ScrambleArenaPortal")
		if not (scrambleArenaPortal and scrambleArenaPortal:IsA("Model")) or localPlayer:GetAttribute("InScrambleArena") == true then
			return nil
		end
		local boundingBox, v20 = scrambleArenaPortal:GetBoundingBox()
		local n2 = math.max(v20.X, v20.Z) / 2 + 12
		local n3 = arg * Vector3.new(1, 0, 1)
		local n4 = boundingBox.Position * Vector3.new(1, 0, 1)
		local n5 = arg2 * Vector3.new(1, 0, 1) - n3
		local n6 = n5.Magnitude > 1 and math.clamp((n4 - n3):Dot(n5) / n5:Dot(n5), 0, 1) or 0
		local n7 = n3 + n5 * n6 - n4
		if n6 <= 0 or n6 >= 1 or n7.Magnitude >= n2 then
			return nil
		end
		local unit = n7.Magnitude > 1 and n7.Unit or Vector3.new(0, 0, 1)
		return Vector3.new(n4.X, arg2.Y, n4.Z) + unit * (n2 + 15)
	end

	handlers.walkTo = function(arg, arg2, arg3)
		local flag2 = localPlayer:GetAttribute("InScrambleArena") == true
		local v20 = fn33()
		v20 = v20 and handlers.portalDetour(v20.Position, arg)

		if v20 then
			handlers.walkTo(v20, arg2, 4)
		end

		local chsaeControls = getgenv().__CHSAE_Controls

		pcall(function()
			chsaeControls:Disable()
		end)

		local now3 = os.clock()
		local flag3 = fn26() ~= nil
		local huge = math.huge
		local exitTo2 = nil
		local exitTo, str, flag4, v21, n2, magnitude

		while true do
			local v22 = fn()
			local v23 = v22 and arg2()
			exitTo = nil

			while true do
				str = "cancelled"
				flag4 = false

				if v23 then
					local v24
					v24, v21 = fn33()

					if not (v24 and v21) or v21.Health <= 0 then
						exitTo = 1
						break
					elseif not flag2 and localPlayer:GetAttribute("InScrambleArena") == true then
						exitTo = 2
						break
					else
						n2 = (arg - v24.Position) * Vector3.new(1, 0, 1)
						magnitude = n2.Magnitude

						if handlers.guardProtectionActive(v24) then
							v21:Move(Vector3.zero)
							now3 = os.clock()

							if magnitude < huge - 0.5 then
								now3 = os.clock()
								huge = magnitude
								RunService.Heartbeat:Wait()
								v22 = fn()
								v23 = v22 and arg2()
							elseif not (os.clock() - now3 > 3) then
								RunService.Heartbeat:Wait()
								v22 = fn()
								v23 = v22 and arg2()
							else
								exitTo = 6
								break
							end
						elseif magnitude <= arg3 then
							v21:Move(Vector3.zero)

							if (v24.AssemblyLinearVelocity * Vector3.new(1, 0, 1)).Magnitude < 3 then
								exitTo = 4
								break
							elseif magnitude < huge - 0.5 then
								now3 = os.clock()
								huge = magnitude
								RunService.Heartbeat:Wait()
								v22 = fn()
								v23 = v22 and arg2()
							elseif not (os.clock() - now3 > 3) then
								RunService.Heartbeat:Wait()
								v22 = fn()
								v23 = v22 and arg2()
							else
								exitTo = 5
								break
							end
						else
							exitTo = 3
							break
						end
					end
				else
					break
				end
			end

			if exitTo == 1 then
				exitTo2 = 1
				break
			elseif exitTo == 2 then
				exitTo2 = 2
				break
			elseif exitTo == 3 then
				fn42()
				local n3 = math.max(12, math.sqrt(1200 * math.max(0, magnitude - arg3 * 0.5)))
				local n4

				if flag3 then
					n4 = math.min(n3, v21.WalkSpeed * 0.8)
				else
					n4 = n3
				end

				v21:Move(n2.Unit * math.clamp(n4 / math.max(1, v21.WalkSpeed), 0.05, 1))

				if magnitude < huge - 0.5 then
					now3 = os.clock()
					huge = magnitude
					RunService.Heartbeat:Wait()
					continue
				elseif not (os.clock() - now3 > 3) then
					RunService.Heartbeat:Wait()
					continue
				else
					exitTo2 = 3
					break
				end
			end

			break
		end

		if exitTo2 == 1 then
			str = "character unavailable"
		elseif exitTo2 == 2 then
			str = "entered Scramble arena"
		elseif exitTo2 == 3 then
			str = "blocked"
		elseif exitTo == 4 then
			str = nil
			flag4 = true
		elseif exitTo == 5 then
			str = "blocked"
		elseif exitTo == 6 then
			str = "blocked"
		end

		local v22, v23 = fn33()

		if v23 then
			pcall(v23.Move, v23, Vector3.zero)
		end

		pcall(function()
			chsaeControls:Enable()
		end)

		return flag4, str
	end

	handlers.runDefaultSpeedSteal = function(carriedUid, arg)
		local tbl17 = { cycleAt = os.clock() }
		carriedUid = carriedUid and carriedUid.Uid
		local v20, v21 = fn33()
		if not (carriedUid ~= nil and v20 and v21 and v21.Health > 0) then
			return false, "character unavailable", tbl17
		end
		local character = localPlayer.Character
		local v22 = handlers.stealTransaction(carriedUid, v21, arg, tbl17)
		local alive = v22.alive
		local record = v22.record
		local held = v22.held
		local finish = v22.finish
		if not record() then
			return finish(false, "target unavailable")
		end
		local v23 = handlers.getStealStart()
		local v24 = v23 and handlers.stealStartPosition(v23, v21)
		if not v24 then
			return finish(false, "home unavailable")
		end
		handlers.movementPhase = "outbound"
		local v25, v26 = v22.walkToStart(v24)
		if not v25 then
			return finish(false, v26)
		end
		local v27 = record()
		if not v27 then
			return finish(false, "target unavailable")
		end
		fn11("🚶 Walking to egg")

		local v28, v29 = handlers.walkTo(v27.BottomCFrame.Position, function()
			return alive() and record() ~= nil
		end, 1.2)

		local v30 = record()
		if not v28 or not v30 then
			return finish(false, v29 or "egg taken before pickup")
		end

		local chsaeCarryRequest = {
			uid = carriedUid,
			category = v30.AssetCategory,
			owner = "Steal",
			session = tbl.Marker,
			character = character,
			generation = tbl13.respawnGeneration,
			started = os.clock(),
			inFlight = true,
			done = false,
			purpose = "default-speed",
		}

		getgenv().__CHSAE_CarryRequest = chsaeCarryRequest
		local ok, result, result2 = pcall(tbl11.RequestCarryAreaEgg, carriedUid, fn21(v30))
		chsaeCarryRequest.inFlight = false
		chsaeCarryRequest.done = true
		chsaeCarryRequest.accepted = ok and result == true
		local n2 = os.clock() + 2

		while chsaeCarryRequest.accepted and os.clock() < n2 and alive() and not held() do
			task.wait(0.05)
		end

		if getgenv().__CHSAE_CarryRequest == chsaeCarryRequest then
			getgenv().__CHSAE_CarryRequest = nil
		end

		if not held() then
			local str = chsaeCarryRequest.accepted and "carry not confirmed"

			if not str then
				str = tostring(ok and (result2 or "carry rejected") or result)
			end

			return finish(false, str)
		end

		local v31 = tbl13
		local now3 = os.clock()
		critical = true
		v31.carriedUid = carriedUid
		tbl17.returnAt = now3
		return v22.returnHome(v24)
	end

	handlers.playerGap = function(arg)
		local huge = math.huge

		for _, player in ipairs(Players2:GetPlayers()) do
			local humanoidRootPart = player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				huge = math.min(huge, ((humanoidRootPart.Position - arg) * Vector3.new(1, 0, 1)).Magnitude)
			end
		end

		return huge
	end

	handlers.stealTransaction = function(arg, arg2, arg3, arg4)
		local character = localPlayer.Character
		local devChickenTween2 = handlers.DevChickenTween
		local tbl17

		tbl17 = {
			record = function()
				local v20 = fn25(arg)
				return v20 and v20.BottomCFrame and (v20.State == "Slot" or v20.State == "Dropped") and v20 or nil
			end,
			held = function()
				local v20 = fn26()
				return v20 ~= nil and tostring(v20.Uid) == tostring(arg)
			end,
			claimed = function()
				local v20 = fn25(arg)
				return v20 == nil or tostring(v20.State) == "Claimed"
			end,
			alive = function()
				return fn() and arg3() and localPlayer.Character == character and arg2.Health > 0 and not fn16()
			end,
			finish = function(arg5, arg6)
				handlers.movementPhase = nil

				if devChickenTween2.lease then
					devChickenTween2.restore(arg5 and "steal complete" or "steal ended")
				end

				critical = tbl17.held()

				if arg5 then
					tbl13.carriedUid = nil
				end

				return arg5, arg6, arg4
			end,
			grab = function()
				for i = 1, 30 do
					local v20 = tbl17.record()
					if not (v20 and tbl17.alive()) then
						return false
					end
					local ok, result = pcall(tbl11.RequestCarryAreaEgg, arg, fn21(v20))
					if ok and result == true then
						return true
					end
					task.wait(0.18)
				end

				return false
			end,
			needsStart = function(arg5)
				local v20 = fn33()
				local flag2 = v20 ~= nil

				if flag2 then
					flag2 = (fn35(v20.Position) or -1) <= 0
				end

				return flag2 and ((v20.Position - arg5) * Vector3.new(1, 0, 1)).Magnitude > 2
			end,
			walkToStart = function(arg5)
				if not tbl17.needsStart(arg5) then
					return true
				end
				fn11("Going to start")

				local v20, v21 = handlers.walkTo(arg5, function()
					return tbl17.alive() and tbl17.record() ~= nil
				end, 1.5)

				if not v20 then
					task.wait(0.5)
				end

				return v20, v21 or "could not reach start"
			end,
			returnHome = function(arg5, arg6)
				handlers.movementPhase = "return"
				fn11(arg6 and "↩️ Tweening egg to start" or "🚶 Walking egg home")

				local function fn52()
					return tbl17.alive() and tbl17.held()
				end

				if arg6 then
					local v20 = fn33()
					v20 = v20 and handlers.portalDetour(v20.Position, arg5)
					local v21 = handlers.getDeliverySpeed()
					local flag2

					if v20 then
						local claimed = tbl17.claimed
						flag2 = not devChickenTween2.move(Vector3.new(v20.X, arg5.Y, v20.Z), 4, fn52, claimed, nil, v21, true)
					else
						flag2 = v20
					end

					if flag2 then
						return tbl17.finish(false, "could not return to start")
					end

					if not devChickenTween2.move(arg5, 0.6, fn52, tbl17.claimed, nil, v21, true) and not tbl17.claimed() then
						return tbl17.finish(false, "could not return to start")
					end
					devChickenTween2.restore("relay claim wait")
				else
					handlers.walkTo(arg5, fn52, 2)
				end

				local n2 = os.clock() + 4

				while os.clock() < n2 and fn() and tbl17.held() and not tbl17.claimed() do
					task.wait(0.1)
				end

				if tbl17.claimed() then
					return tbl17.finish(true)
				end
				return tbl17.finish(false, tbl17.held() and "claim not confirmed" or "egg dropped on the way home")
			end,
		}

		return tbl17
	end

	local vector = Vector3.new(1, 0, 1)

	local function fn52(arg)
		local tbl17 = {
			root = nil,
			support = nil,
			height = nil,
			reason = "idle",
			Stop = function(arg2)
				if arg2.support then
					arg.destroy(arg2.support)
				end

				arg2.root = nil
				arg2.support = nil
				arg2.height = nil
			end,
			Step = function(arg2, root, arg3, height)
				if not arg3 or not root or type(height) ~= "number" or height ~= height or math.abs(height) == math.huge then
					arg2.reason = "flight prerequisites"
					arg2:Stop()
					return false
				end

				if arg2.root ~= root then
					arg2:Stop()
				end

				local v20, v21, v22 = arg.sample(root)
				local flag2 = v22 <= 0 or v22 == math.huge or v22 ~= v22

				if not flag2 then
					flag2 = v21.Magnitude > math.max(500, arg.speed or 0) * 1.2
				end

				if flag2 then
					arg2.reason = "rig physics settling"
					arg2:Stop()
					return false
				end

				local n2 = arg.goal(root, height) - v20
				local flag3 = n2.Magnitude > 0.15

				if flag3 then
					flag3 = n2.Unit * math.min(arg.speed or 500, n2.Magnitude * (arg.gain or 8))
				end

				local vector2 = flag3 or Vector3.zero
				local v23, v24, v25 = arg.register(root, vector2, v22 * (vector2 - v21))

				if not v23 then
					arg2.reason = v25 or "movement registration unavailable"

					if v25 == "renewing" and arg2.support then
						if arg.pause then
							arg.pause(arg2.support)
						end

						return true
					end

					arg2:Stop()
					return false
				end

				arg2.reason = nil
				arg2.root = root
				arg2.height = height

				if not arg2.support then
					arg2.support = arg.create(root)
				end

				arg.update(arg2.support, vector2, v22)
				return true
			end,
		}

		tbl17.Destroy = tbl17.Stop
		tbl17.Disconnect = tbl17.Stop
		return tbl17
	end

	local tbl17 = {
		sample = function(arg)
			return arg.Position, arg.AssemblyLinearVelocity, arg.Anchored and math.huge or arg.AssemblyMass
		end,
		register = function(arg, arg2, arg3)
			if arg2.Magnitude <= 0 then
				return fn44(arg, Vector3.new(0, 1, 0), 1, 0.5, arg3, false)
			end
			local unit = arg2.Unit
			local value = v10 and v10.state and rawget(v10.state, "ImpulseContext")
			local originPosition = type(value) == "table" and value.OriginPosition
			local num = type(value) == "table" and tonumber(value.MaxVerticalSpeed)
			local num2 = type(value) == "table" and tonumber(value.MaxUpwardDistance)
			local flag2 = typeof(originPosition) == "Vector3" and num and num2 and math.abs(arg2.Y) + 5 <= num and arg.Position.Y - originPosition.Y + math.max(0, arg2.Y) * 0.05 + 2 < num2
			return fn44(arg, unit, math.max(1, arg2.Magnitude), 24, arg3, not flag2)
		end,
		pause = function(arg)
			if arg.active then
				arg.velocity.Velocity = Vector3.zero
			end
		end,
		create = function(parent)
			local parent2 = parent.Parent
			local humanoid = parent2 and parent2:FindFirstChildOfClass("Humanoid")
			assert(humanoid, "flight Humanoid unavailable")
			local tbl17 = { root = parent, humanoid = humanoid, platformStand = humanoid.PlatformStand, active = true, collisions = {} }

			local ok, result = pcall(function()
				tbl17.velocity = Instance.new("BodyVelocity")
				tbl17.velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				tbl17.velocity.Velocity = Vector3.zero
				tbl17.gyro = Instance.new("BodyGyro")
				tbl17.gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
				tbl17.gyro.D = 100
				tbl17.gyro.P = 10000
				tbl17.gyro.CFrame = parent.CFrame

				local function fn53(descendant)
					if tbl17.active and descendant:IsA("BasePart") and descendant:IsDescendantOf(parent2) and tbl17.collisions[descendant] == nil then
						tbl17.collisions[descendant] = descendant.CanCollide
					end
				end

				tbl17.partAdded = parent2.DescendantAdded:Connect(fn53)

				tbl17.partRemoving = parent2.DescendantRemoving:Connect(function(descendant)
					if not tbl17.active then
						return
					end
					local v20 = tbl17.collisions[descendant]

					if v20 ~= nil then
						tbl17.collisions[descendant] = nil

						pcall(function()
							descendant.CanCollide = v20
						end)
					end
				end)

				for _, v20 in ipairs(parent2:QueryDescendants("BasePart")) do
					fn53(v20)
				end

				tbl17.velocity.Parent = parent
				tbl17.gyro.Parent = parent
				humanoid.PlatformStand = true
			end)

			if not ok then
				tbl17.active = false

				if tbl17.partAdded then
					tbl17.partAdded:Disconnect()
				end

				if tbl17.partRemoving then
					tbl17.partRemoving:Disconnect()
				end

				table.clear(tbl17.collisions)

				if tbl17.velocity then
					tbl17.velocity:Destroy()
				end

				if tbl17.gyro then
					tbl17.gyro:Destroy()
				end

				humanoid.PlatformStand = tbl17.platformStand
				error(result)
			end

			return tbl17
		end,
		update = function(arg, velocity)
			if not arg.active then
				return
			end

			for k in pairs(arg.collisions) do
				if k.CanCollide then
					k.CanCollide = false
				end
			end

			arg.velocity.Velocity = velocity
			local n2 = velocity * vector

			if n2.Magnitude > 0.15 then
				arg.gyro.CFrame = CFrame.lookAt(arg.root.Position, arg.root.Position + n2)
			end
		end,
		destroy = function(arg)
			if not arg.active then
				return
			end
			arg.active = false
			arg.partAdded:Disconnect()
			arg.partRemoving:Disconnect()

			for k, collision in pairs(arg.collisions) do
				pcall(function()
					k.CanCollide = collision
				end)
			end

			table.clear(arg.collisions)
			arg.velocity:Destroy()
			arg.gyro:Destroy()
			arg.humanoid.PlatformStand = arg.platformStand
		end,
	}

	handlers.newFlight = function(goal, gain, speed)
		local v20 = table.clone(tbl17)
		v20.goal = goal
		v20.gain = gain
		v20.speed = speed
		return fn52(v20)
	end

	handlers.flyPath = function(arg, arg2, arg3, arg4)
		local n2 = (arg2 - arg) * Vector3.new(1, 0, 1)
		local n3 = math.max(1, math.ceil(n2.Magnitude / arg3))
		local tbl18 = {}

		for i = 1, n3 - 1 do
			local n4 = arg + n2 * i / n3
			tbl18[i] = Vector3.new(n4.X, arg4, n4.Z)
		end

		tbl18[n3] = arg2
		return tbl18
	end

	handlers.flyDropPoint = function(arg, arg2)
		local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
		world = world and world:FindFirstChild("Areas")
		local guardAreas = world and world:FindFirstChild("GuardAreas")

		if guardAreas then
			guardAreas = guardAreas:FindFirstChild(arg2 or "Forest")
		end

		guardAreas = guardAreas and guardAreas:FindFirstChild("Nests")
		if not (guardAreas and guardAreas:IsA("Model")) then
			return nil
		end
		local position = guardAreas:GetBoundingBox().Position
		local v20 = nil
		local v21 = position

		for _, child in ipairs(guardAreas:GetChildren()) do
			if child:IsA("PVInstance") then
				local position2 = child:GetPivot().Position
				local magnitude = ((position2 - position) * Vector3.new(1, 0, 1)).Magnitude

				if not v20 or magnitude < v20 then
					v20 = magnitude
					v21 = position2
				end
			end
		end

		local v22 = nil
		local v23 = nil

		for i = 1, 12 do
			local n2 = math.random() * 3.1415926535897931 * 2
			local n3 = math.sqrt(math.random()) * 6
			local y = arg.Y
			local z = v21.Z
			local vector2 = Vector3.new(v21.X + math.cos(n2) * n3, y, z + math.sin(n2) * n3)
			local v24 = handlers.playerGap(vector2)

			if not v22 or v24 > v22 then
				v22 = v24
				v23 = vector2
			end
		end

		return v23
	end

	handlers.relayDropPoint = function(arg)
		local world = workspace:FindFirstChild("World")
		world = world and world:FindFirstChild("Build")
		world = world and world:FindFirstChild("Props")
		world = world and world:FindFirstChild("Zone3Props")
		if not world then
			return nil
		end

		for _, child in ipairs(world:GetChildren()) do
			if child.Name == "untitled" and child:IsA("BasePart") and ((child.Position - Vector3.new(962.9, 0, -412.2)) * Vector3.new(1, 0, 1)).Magnitude < 50 then
				return Vector3.new(child.Position.X, arg.Y, child.Position.Z)
			end
		end

		return nil
	end

	handlers.flyTo = function(arg, arg2, arg3)
		local v20, v21 = fn33()
		if not (v20 and v21) then
			return false
		end
		arg3 = arg3 or v21.WalkSpeed

		local v22 = handlers.newFlight(function()
			return arg
		end, 8, arg3)

		local magnitude = (arg - v20.Position).Magnitude
		local n2 = os.clock() + magnitude / math.max(16, arg3) + 8
		local flag2

		while true do
			local flag3 = arg2() and v21.Health > 0 and os.clock() < n2
			flag2 = false

			if flag3 then
				if (arg - v20.Position).Magnitude <= 3 then
					flag2 = true
					break
				else
					v22:Step(v20, true, arg.Y)
					RunService.PreSimulation:Wait()
					continue
				end
			end

			break
		end

		v22:Stop()
		return flag2
	end

	handlers.relayReturn = function(arg, arg2, arg3, arg4)
		local devChickenTween2 = handlers.DevChickenTween
		local v20, v21 = fn33()
		if not (v20 and v21) then
			return arg.finish(false, "character unavailable")
		end
		local n2 = v21.HipHeight + v20.Size.Y / 2
		local n3 = arg3 + Vector3.new(0, 46 - n2, 0)

		local function fn53()
			return arg.alive() and devChickenTween2.lease ~= nil and devChickenTween2.alive(devChickenTween2.lease)
		end

		local function fn54()
			local v22 = arg.record()
			return fn53() and v22 ~= nil and v22.State == "Dropped"
		end

		for i = 1, 10 do
			if not fn53() then
				return arg.finish(false, "cancelled")
			end
			fn11(arg4 and ("⚡ Hop Fly %d · dropping at the drop spot"):format(i) or ("🔁 Relay %d · dropping in Desert"):format(i))
			local lease = devChickenTween2.lease
			local position = v20.Position
			local v22, v23 = lease.mover:teleportTo(n3, 2000, v10)
			devChickenTween2.stopTween(lease, false)
			if not v22 then
				return arg.finish(false, "relay teleport: " .. tostring(v23))
			end
			task.wait(0.12)
			if not fn53() then
				return arg.finish(false, "cancelled")
			end
			local ok = pcall(tbl11.DropAreaEgg, "PlayerRequest")
			local v24, v25 = lease.mover:teleportTo(position, 2000, v10)
			devChickenTween2.stopTween(lease, false)
			if not v24 then
				return arg.finish(false, "relay return: " .. tostring(v25))
			end

			if not ok then
				return arg.finish(false, "drop request failed")
			end
			local n4 = os.clock() + 2
			local v26 = arg.record()

			while os.clock() < n4 and fn53() and (arg.held() or not v26 or v26.State ~= "Dropped") do
				task.wait(0.03)
				v26 = arg.record()
			end

			if not fn53() then
				return arg.finish(false, "cancelled")
			end

			if arg.held() then
				return arg.finish(false, "drop rejected")
			end

			if not v26 then
				return arg.finish(false, "dropped egg unavailable")
			end

			if v26.State ~= "Dropped" then
				return arg.finish(false, "egg returned to its nest")
			end
			critical = false
			task.wait(0.2)
			local v27 = arg.record()
			if not (v27 and v27.State == "Dropped") then
				return arg.finish(false, "egg returned to its nest")
			end
			local n5 = v27.BottomCFrame.Position + Vector3.new(0, n2, 0)

			if arg4 then
				fn11("⚡ Hopping to the dropped egg")

				for _, v28 in ipairs(handlers.flyPath(v20.Position, n5, 370, n5.Y + 42)) do
					if not fn54() then
						return arg.finish(false, "could not reach dropped egg")
					end
					local v29, v30 = arg4(v28)
					if not v29 then
						return arg.finish(false, "hop: " .. tostring(v30))
					end
					task.wait(0.1)
				end
			else
				fn11("🔁 Relay · tweening to dropped egg")
				local v28 = handlers.portalDetour(v20.Position, n5)
				if v28 and not devChickenTween2.move(v28, 4, fn54, nil, nil, 2000, true) then
					return arg.finish(false, "could not reach dropped egg")
				end

				if not devChickenTween2.move(n5, 0.6, fn54, nil, nil, 2000, true) then
					return arg.finish(false, "could not reach dropped egg")
				end
			end

			if not arg.grab() then
				return arg.finish(false, "re-pickup rejected")
			end
			local n6 = os.clock() + 2

			while os.clock() < n6 and fn53() and not arg.held() do
				task.wait(0.03)
			end

			if not fn53() then
				return arg.finish(false, "cancelled")
			end

			if not arg.held() then
				return arg.finish(false, "carry not confirmed")
			end
			critical = true
			if arg4 and ((n5 - arg2) * Vector3.new(1, 0, 1)).Magnitude <= 150 then
				devChickenTween2.restore("walk in")
				return arg.returnHome(arg2)
			end

			if not arg4 and fn20(n5) == "Desert" then
				return arg.returnHome(arg2, true)
			end
		end

		return arg.finish(false, "relay limit reached")
	end

	handlers.runFlySteal = function(carriedUid, arg, arg2, arg3, arg4)
		local tbl18 = { cycleAt = os.clock() }
		carriedUid = carriedUid and carriedUid.Uid
		local v20, v21 = fn33()
		if not (carriedUid ~= nil and v20 and v21 and v21.Health > 0) then
			return false, "character unavailable", tbl18
		end
		local v22 = handlers.getStealStart()
		local v23 = v22 and handlers.stealStartPosition(v22, v21)
		if not v23 then
			return false, "home unavailable", tbl18
		end
		local v24 = nil

		if arg3 then
			if not fn41("Desert") then
				return false, "Desert is locked", tbl18
			end
			v24 = handlers.relayDropPoint(v23) or handlers.flyDropPoint(v23, "Desert")
			if not v24 then
				return false, "Desert drop point unavailable", tbl18
			end
		end

		local devChickenTween2 = handlers.DevChickenTween
		local v25 = handlers.stealTransaction(carriedUid, v21, arg, tbl18)
		if not fn43(true) then
			return false, "movement controller unavailable", tbl18
		end
		local v26 = v25.record()
		if not v26 then
			return v25.finish(false, "target unavailable")
		end

		local function fn53(arg5)
			local v27, v28 = devChickenTween2.begin(true, "Steal", arg)
			if not v27 then
				return false, v28
			end
			return devChickenTween2.lease.mover:teleportTo(arg5, 2000, v10)
		end

		local n2 = v26.BottomCFrame.Position + Vector3.new(0, v21.HipHeight + v20.Size.Y / 2, 0)
		handlers.movementPhase = "outbound"

		local function fn54()
			return v25.alive() and v25.record() ~= nil
		end

		if v25.needsStart(v23) then
			fn11("☁️ Flying to start")
			local v27 = handlers.portalDetour(v20.Position, v23)

			if v27 then
				handlers.flyTo(Vector3.new(v27.X, v23.Y, v27.Z), fn54)
			end

			if not handlers.flyTo(v23, fn54) then
				return v25.finish(false, "could not reach start")
			end
		end

		if fn16() then
			fn11("⏳ Wall closed — waiting at the start")

			while fn16() do
				if not (fn() and arg() and v21.Health > 0) then
					return v25.finish(false, "cancelled")
				end
				task.wait(0.05)
			end

			v26 = v25.record()
			if not v26 then
				return v25.finish(false, "target unavailable")
			end
			n2 = v26.BottomCFrame.Position + Vector3.new(0, v21.HipHeight + v20.Size.Y / 2, 0)
		end

		local n3 = math.max(v23.Y, n2.Y) + 50
		fn11("☁️ Flying to egg")

		if math.abs(v20.Position.Y - n3) > 5 then
			local v27, v28 = fn53(Vector3.new(v20.Position.X, n3, v20.Position.Z))
			if not v27 then
				return v25.finish(false, "could not lift off: " .. tostring(v28))
			end
		end

		devChickenTween2.restore("flight out")
		local v27 = handlers.portalDetour(v20.Position, n2)

		if v27 then
			handlers.flyTo(Vector3.new(v27.X, n3, v27.Z), fn54)
		end

		if not handlers.flyTo(Vector3.new(n2.X, n3, n2.Z), fn54) or not fn53(n2) then
			return v25.finish(false, "could not reach egg")
		end
		task.wait(0.35)
		if not v25.grab() then
			return v25.finish(false, "pickup rejected")
		end
		local v28 = tbl13
		local now3 = os.clock()
		critical = true
		v28.carriedUid = carriedUid
		tbl18.returnAt = now3
		handlers.movementPhase = "return"
		if arg3 then
			return handlers.relayReturn(v25, v23, v24)
		end

		if tostring(v26.AreaId) == "Forest" then
			devChickenTween2.restore("walk in")
			return v25.returnHome(v23)
		end

		if arg2 then
			fn11("☁️ Flying egg home")
			local n4 = math.max(v23.Y, n2.Y) + 70
			local v29, v30 = fn53(Vector3.new(v20.Position.X, n4, v20.Position.Z))
			if not v29 then
				return v25.finish(false, "could not lift off: " .. tostring(v30))
			end
			devChickenTween2.restore("flight home")
			local now4 = nil

			local function fn55()
				if v25.held() then
					now4 = nil
				else
					now4 = now4 or os.clock()
				end

				return v25.alive() and (now4 == nil or os.clock() - now4 < 0.3)
			end

			local ok, result = pcall(function()
				return require(ReplicatedStorage.Data.Guards).Directory[tostring(v26.AreaId)]
			end)

			local n5 = math.max(v21.WalkSpeed, (ok and type(result) == "table" and tonumber(result.WalkSpeed) or 0) * 1.05)
			local n6 = (n4 - v23.Y) * n5 / 110

			handlers.flyTo(Vector3.new(v23.X, n4, v23.Z), function()
				return fn55() and ((v20.Position - v23) * Vector3.new(1, 0, 1)).Magnitude > n6
			end, n5)

			if v25.held() then
				fn11("☁️ Gliding egg into the start")
				handlers.flyTo(v23, fn55, n5)
			end

			if v25.claimed() then
				return v25.finish(true)
			end

			if not v25.held() then
				return v25.finish(false, "egg dropped on the way home")
			end
			return v25.returnHome(v23)
		end

		local n4 = (n2 - v23) * Vector3.new(1, 0, 1)
		local n5 = handlers.flyDropPoint(v23)

		if not n5 then
			n5 = v23 + (n4.Magnitude > 1 and n4.Unit or Vector3.new(1, 0, 0)) * math.min(70, n4.Magnitude / 2)
		end

		if arg4 then
			return handlers.relayReturn(v25, v23, n5, fn53)
		end
		fn11("☁️ Hopping egg home")

		for _, v29 in ipairs(handlers.flyPath(v20.Position, n5, 370, n2.Y + 42)) do
			if not v25.alive() then
				return v25.finish(false, "cancelled")
			end
			local v30, v31 = fn53(v29)
			if not v30 then
				return v25.finish(false, "hop: " .. tostring(v31))
			end
			task.wait(0.1)
		end

		devChickenTween2.restore("walk in")
		task.wait(0.2)
		if not v25.alive() then
			return v25.finish(false, "cancelled")
		end
		pcall(tbl11.DropAreaEgg, "PlayerRequest")
		local n6 = os.clock() + 1.5

		while os.clock() < n6 and v25.alive() and v25.held() do
			task.wait(0.03)
		end

		if v25.held() then
			return v25.finish(false, "drop rejected")
		end
		local v29 = v25.record()
		local n7 = os.clock() + 2

		while os.clock() < n7 and v25.alive() and v29 and v29.State ~= "Dropped" and v29.State ~= "Slot" do
			task.wait(0.03)
			v29 = v25.record()
		end

		if not (v29 and v29.State == "Dropped") then
			return v25.finish(false, "egg returned to its nest after the drop")
		end

		if not v25.grab() then
			return v25.finish(false, "re-pickup rejected")
		end
		local n8 = os.clock() + 2

		while os.clock() < n8 and v25.alive() and not v25.held() do
			task.wait(0.05)
		end

		if not v25.held() then
			return v25.finish(false, "egg dropped on the way home")
		end
		return v25.returnHome(v23)
	end

	handlers.onAutoStealDeath = function()
		if not handlers.stealFeatureEnabled() then
			return
		end
		local now3 = os.clock()
		local chsaeCarryRequest = getgenv().__CHSAE_CarryRequest
		local v20 = fn26()
		local str = tostring(tbl13.lastRequestKind or "")
		local flag2 = type(chsaeCarryRequest) == "table" and chsaeCarryRequest.carrySeen == true
		local flag3 = (str == "carry-drop" or str == "carry-loss-sync" or str == "death-drop-sync") and (tbl13.lastDroppedUid ~= nil or tbl13.deathRecoveryUid ~= nil)
		local uid

		if v20 and v20.Uid ~= nil then
			uid = v20.Uid
		elseif critical or tbl13.carriedUid ~= nil then
			uid = tbl13.carriedUid or type(chsaeCarryRequest) == "table" and chsaeCarryRequest.uid or nil or tbl13.lockedUid or tbl13.attemptUid
		elseif flag2 then
			uid = chsaeCarryRequest.uid or tbl13.lockedUid or tbl13.attemptUid
		elseif flag3 then
			uid = tbl13.lastDroppedUid or tbl13.deathRecoveryUid or tbl13.lockedUid
		else
			uid = tbl13.recentPositiveCarryUid()
		end

		if uid ~= nil and handlers.isCaptureEventUid(uid) then
			uid = nil
		end

		tbl13.respawnGeneration = tbl13.respawnGeneration + 1

		if uid ~= nil then
			if tostring(tbl13.persistentUid) ~= tostring(uid) then
				tbl13.persistentUid = nil
			end

			if tostring(tbl13.dropRecoveryRecordUid) ~= tostring(uid) then
				tbl13.dropRecoveryRecord = nil
				tbl13.dropRecoveryRecordUid = nil
				tbl13.dropRecoveryRecordAt = 0
			end

			tbl13.lockedUid = uid
			tbl13.attemptUid = uid
			tbl13.lastDroppedUid = uid

			if (tonumber(tbl13.dropDetectedAt) or 0) <= 0 then
				tbl13.dropDetectedAt = now3
			end

			tbl13.deathRecoveryUid = uid

			if (tonumber(tbl13.deathRecoveryAt) or 0) <= 0 then
				tbl13.deathRecoveryAt = now3
			end

			local v21 = fn25(uid)
			local str2 = v21 and tostring(v21.State) or nil
			local num = v21 and tonumber(v21.CarrierUserId) or nil

			if v21 ~= nil and ((str2 == "Slot" or str2 == "Dropped") and v21.BottomCFrame ~= nil or num == localPlayer.UserId) then
				tbl13.deathRecoveryMissingAt = 0
				tbl13.deathRecoveryMissingReason = ""
			else
				tbl13.deathRecoveryMissingAt = now3
				tbl13.deathRecoveryMissingReason = v21 and "death-record-transitioning" or "death-snapshot-missing"
			end

			tbl13.requestFailureUid = uid
			tbl13.requestFailureAt = now3

			if str ~= "carry-drop" then
				tbl13.lastRequestKind = "death-drop-sync"
			end

			tbl13.lastRequestError = "character died while carrying; awaiting exact egg"
			handlers.pendingDroppedUid = uid

			if type(tbl13.webhookTarget) == "table" and tostring(tbl13.webhookTarget.uid) ~= tostring(uid) then
				tbl13.webhookTarget = nil
			end
		else
			fn13()
			tbl13.requestFailureUid = nil
			tbl13.requestFailureAt = 0
			tbl13.lastRequestKind = ""
			tbl13.lastRequestError = ""
			tbl13.webhookTarget = nil
		end

		critical = false
		tbl13.carriedUid = nil
		handlers.activeGuardAreaId = nil

		if type(chsaeCarryRequest) == "table" then
			if uid ~= nil and tostring(chsaeCarryRequest.uid) == tostring(uid) then
				chsaeCarryRequest.carrySeen = true
			end

			if chsaeCarryRequest.inFlight then
				chsaeCarryRequest.cancelledByDeath = true
			else
				getgenv().__CHSAE_CarryRequest = nil
			end
		end

		tbl15.treadmillSuppressed = uid ~= nil
		local owner = tbl14.owner

		if uid ~= nil and owner and owner ~= "Steal" then
			tbl14.release(owner)
		end

		tbl14.stealWants = uid ~= nil
		tbl14.critical = false
		tbl14.stealBeat = os.clock()
		tbl14.release("Steal")
		handlers.pauseStealTimer()
		handlers.carry = uid ~= nil and "📦 Carry: lost on death · reclaiming" or "📦 Carry: none"

		if uid == nil then
			handlers.set("target", "🎯 Target: none")
		end

		fn11(uid ~= nil and "🔁 Respawning — reclaiming dropped egg" or "🟡 Respawning — rescanning")

		if fn12 then
			fn12("character-death")
		end
	end

	local stall = {}
	handlers.Stall = stall

	stall.points = function(arg, arg2)
		local v20 = arg.CFrame:PointToObjectSpace(arg2)
		local n2 = arg.Size * 0.5
		local x = n2.X
		local flag2 = math.abs(v20.X) > x

		if not flag2 then
			local z = n2.Z
			flag2 = math.abs(v20.Z) > z
		end

		if flag2 or n2.X <= 8 or n2.Z <= 8 then
			return nil
		end
		local v21 = arg.CFrame:PointToWorldSpace(Vector3.new(-n2.X + 8, v20.Y, 0))
		local v22 = arg.CFrame:PointToWorldSpace(Vector3.new(n2.X - 8, v20.Y, 0))
		return { v21, v22 }, v20.X <= 0 and 2 or 1
	end

	stall.route = function(arg, arg2, arg3)
		local movementPhase = handlers.movementPhase
		handlers.movementPhase = "return"
		local ok, result = pcall(handlers.guardRoutePoints, arg2, arg3, arg.Parent.Name, arg)
		handlers.movementPhase = movementPhase

		if not ok then
			error(result)
		end

		local n2 = arg.Size * 0.5
		local y = arg.CFrame:PointToObjectSpace(arg2).Y

		for i, v20 in ipairs(result) do
			local v21 = arg.CFrame:PointToObjectSpace(v20)
			local clamp = math.clamp
			local z = v21.Z
			local n3 = -n2.Z + 8
			local n4 = n2.Z - 8
			result[i] = arg.CFrame:PointToWorldSpace(Vector3.new(math.clamp(v21.X, -n2.X + 8, n2.X - 8), y, clamp(z, n3, n4)))
		end

		result[#result + 1] = arg3
		return result
	end

	stall.itinerary = function(arg)
		local tbl18 = {}
		local tbl19 = {}

		for _, child in ipairs(arg:GetChildren()) do
			local bounds = child:FindFirstChild("Bounds")

			if bounds and bounds:IsA("BasePart") then
				tbl18[#tbl18 + 1] = bounds
			end
		end

		table.sort(tbl18, function(arg2, arg3)
			return arg2.Position.X < arg3.Position.X
		end)

		local v20 = fn40()
		local n2 = -math.huge
		local huge = math.huge

		for _, v21 in ipairs(tbl18) do
			local v22 = v20[v21.Parent.Name]

			if not (not v22 or v22.req == nil and v21.Parent.Name ~= "Forest" or not fn41(v21.Parent.Name)) then
				local n3 = math.max(n2, v21.Position.Z - v21.Size.Z / 2 + 8)
				local n4 = math.min(huge, v21.Position.Z + v21.Size.Z / 2 - 8)

				if not (n4 < n3) then
					tbl19[#tbl19 + 1] = v21
					n2 = n3
					huge = n4
					continue
				end
			end

			break
		end

		return tbl19, #tbl19 > 0 and (n2 + huge) / 2 or nil
	end

	stall.pickup = function()
		local captureEventUid = handlers.captureEventUid and handlers.captureEventUid()
		local v20 = captureEventUid and fn25(captureEventUid)
		if not captureEventUid then
			return false, "Stall · manually pick up an egg"
		end
		local bottomCFrame = v20 and v20.BottomCFrame
		local flag2

		if bottomCFrame then
			flag2 = v20.State == "Slot" or v20.State == "Dropped"
		else
			flag2 = bottomCFrame
		end

		if not flag2 then
			return false, "Stall · waiting for the event egg"
		end
		local v21, v22 = fn33()
		if not v21 or not v22 or v22.Health <= 0 or fn16() then
			return false, "Stall · waiting for the event egg"
		end
		local v23 = tbl14
		tbl14.stealWants = true
		v23.critical = true

		if not tbl14.acquireWait("Steal", 1) then
			local v24 = tbl14
			tbl14.stealWants = false
			v24.critical = false
			return false, "Stall · waiting for movement"
		end

		local character = localPlayer.Character

		local ok, result = pcall(function()
			if not fn43(true) then
				error("movement controller unavailable")
			end

			fn2(true)

			local function fn53()
				local v24 = fn25(captureEventUid)
				return fn() and tbl2.Stall and localPlayer.Character == character and v22.Health > 0 and tbl14.hold("Steal") and not fn16() and v24 ~= nil and v24.BottomCFrame ~= nil and (v24.State == "Slot" or v24.State == "Dropped")
			end

			local function fn54()
				return fn25(captureEventUid).BottomCFrame.Position + Vector3.new(0, v22.HipHeight + v21.Size.Y / 2, 0)
			end

			fn11("Stall · flying to the event egg")
			local v24 = handlers.getDeliverySpeed()
			local n2 = math.max(v21.Position.Y, fn54().Y) + 40
			local v25 = ipairs
			local tbl18 = {}
			local vector2 = Vector3.new(v21.Position.X, n2, v21.Position.Z)
			local vector3 = Vector3.new
			local x = fn54().X
			local z = fn54().Z
			tbl18[1] = vector2

			do
				local values = table.pack(vector3(x, n2, z))
				table.move(values, 1, values.n, 2, tbl18)
			end

			for _, v26 in v25(tbl18) do
				if not fn53() or not handlers.flyTo(v26, fn53, v24) then
					return false
				end
			end

			if not fn53() or not handlers.flyTo(fn54(), fn53, v24) then
				return false
			end
			local ok, result = pcall(tbl11.RequestCarryAreaEgg, captureEventUid, fn21(fn25(captureEventUid)))
			if not ok or result ~= true then
				return false
			end
			local n3 = os.clock() + 3

			while os.clock() < n3 and fn() do
				local v26 = fn26()
				if v26 and tostring(v26.Uid) == tostring(captureEventUid) then
					return true
				end
				task.wait(0.1)
			end

			return false
		end)

		fn2(false)
		fn43(false)
		local v24 = tbl14
		tbl14.stealWants = false
		v24.critical = false
		tbl14.release("Steal")
		if not ok then
			return false, "Stall paused · " .. tostring(result)
		end
		return result == true, result and nil or "Stall · retrying the event egg"
	end

	stall.run = function()
		local v20 = fn26()

		if not v20 then
			local v21, v22 = stall.pickup()
			if v21 then
				return
			end
			fn11(v22 or "Stall · manually pick up an egg")
			task.wait(0.2)
			return
		end

		local v21, v22 = fn33()
		if not v21 or not v22 or v22.Health <= 0 then
			task.wait(0.2)
			return
		end
		local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
		world = world and world:FindFirstChild("Areas")
		world = world and world:FindFirstChild("GuardAreas")
		local v23 = nil
		local v24 = nil
		local n2 = nil
		local v25 = ipairs
		local children = world and world:GetChildren() or {}

		for _, child in v25(children) do
			local bounds = child:FindFirstChild("Bounds")

			if bounds and bounds:IsA("BasePart") then
				v24, n2 = stall.points(bounds, v21.Position)
				if v24 then
					v23 = bounds
					break
				end
			end
		end

		if not v23 then
			fn11("Stall · enter an egg area first")
			task.wait(0.2)
			return
		end

		local v26, v27 = stall.itinerary(world)
		local v28 = table.find(v26, v23)

		if not v28 then
			fn11("Stall · waiting for unlocked area data")
			task.wait(0.2)
			return
		end

		local n3 = v28 == #v26 and -1 or 1
		local character = localPlayer.Character
		local uid = v20.Uid

		local function fn53()
			local v29 = fn26()
			return fn() and tbl2.Stall and localPlayer.Character == character and v29 ~= nil and tostring(v29.Uid) == tostring(uid) and v23.Parent ~= nil and not fn16()
		end

		local v29 = tbl14
		tbl14.stealWants = true
		v29.critical = true

		if not tbl14.acquireWait("Steal", 1) then
			local v30 = tbl14
			tbl14.stealWants = false
			v30.critical = false
			task.wait(0.2)
			return
		end

		local ok, result = pcall(function()
			if not fn53() then
				return
			end

			if not fn43(true) then
				error("movement controller unavailable")
			end

			fn2(true)
			tbl15.treadmillSuppressed = true

			local function fn54()
				return fn53() and v22.Health > 0 and tbl14.hold("Steal")
			end

			local v30 = handlers.getDeliverySpeed()
			local n4 = v21.Position.Y + 40

			local function fn55(arg)
				return Vector3.new(arg.X, n4, arg.Z)
			end

			if fn54() then
				if not handlers.flyTo(fn55(v21.Position), fn54, v30) and fn53() then
					error("movement interrupted")
				end
			end

			while fn54() do
				local tbl18

				if #v26 > 1 then
					local n5 = v28 + n3

					if n5 < 1 or n5 > #v26 then
						n3 = -n3
						n5 = v28 + n3
					end

					local v31 = v26[n5]

					if not (not v31.Parent or not fn41(v31.Parent.Name)) then
						fn11("Stall · " .. v31.Parent.Name)
						local vector2 = Vector3.new
						local x = v31.Position.X
						tbl18 = { fn55(Vector3.new(v21.Position.X, 0, v27)), fn55(vector2(x, 0, v27)) }
						v28 = n5

						for _, v32 in ipairs(tbl18) do
							if fn54() then
								if not handlers.flyTo(v32, fn54, v30) then
									if fn53() then
										error("movement interrupted")
									end

									break
								else
									continue
								end
							end

							break
						end

						n2 = 3 - n2
						RunService.Heartbeat:Wait()
						continue
					end
				else
					fn11("Stall · " .. v23.Parent.Name)
					tbl18 = stall.route(v23, v21.Position, v24[n2])

					for i, v31 in ipairs(tbl18) do
						tbl18[i] = fn55(v31)
					end

					for _, v31 in ipairs(tbl18) do
						if fn54() then
							if not handlers.flyTo(v31, fn54, v30) then
								if fn53() then
									error("movement interrupted")
								end

								break
							else
								continue
							end
						end

						break
					end

					n2 = 3 - n2
					RunService.Heartbeat:Wait()
					continue
				end

				break
			end
		end)

		fn2(false)
		fn43(false)
		tbl15.treadmillSuppressed = false
		local v30 = tbl14
		tbl14.stealWants = false
		v30.critical = false
		tbl14.release("Steal")

		if not ok then
			fn11("Stall paused · " .. tostring(result))
		end

		task.wait(0.2)
	end

	task.spawn(function()
		while fn() do
			local ok, result = xpcall(function()
				local tbl18 = {}

				handlers.riftTargetBlocked = function(arg)
					local flag2 = tbl18[arg] ~= nil

					if flag2 then
						local v20 = tbl18[arg]
						flag2 = os.clock() <= v20
					end

					return flag2
				end

				local respawnGeneration = tbl13.respawnGeneration
				local v20, v21, v22, uid, chsaeCarryRequest, n2, stealHopFallback, flag2, flag3, flag4, flag5, targetPriority, fn53, entries, rec, str, n3, n4

				while fn() do
					local exitTo = nil
					local v23, n5, v24, v25, magnitude, v26, lastRequestKind, v27, lower, v28, lastRequestError, v29, flag6, flag7, flag8, flag9, flag10, flag11, v30, flag12, flag13, now3, num, n6, n7, v31, retryResumeMode, v32, str2, magnitude2, v33, tbl19, tbl20, weight, v34, rarityNumber, rank, rarNum, v35, v36, v37, v38, n8, n9, rec2, flag14, flag15, flag16, v39, rarity, mutations, tbl21, magnitude3, dist, flag17, flag18, flag19, n10, n11, rec3, rarity2, mutations2, flag20, flag21, v40, flag22, v41, str3, format, str4, str5, v42, str6, format2, str7, checkStealHop, v43, n12, rar, v44, str8, str9, str10, set, str11, format3, str12, str13, num2, n13, directory, webhookTarget, str14, flag23, v45, webhookTarget2, v46, assetCategory, str15, v47, id, v48, areaId, mutations3, scale, income, distance, icon, flag24, rec4, v49, v50, str16, v51, riftTargetUid, flag25, flag26, v52, v53, flag27, str17, flag28, persistentSteal, v54, str18, v55, stealMovementType, v56, v57, v58, v59, v60, finishStealTimer, returnAt, n14, now4, returnAt2, v61, v62, v63, lastRequestError2, flag29, flag30, flag31, v64, v65, v66, min, consecutiveFailures, n15, n16, n17, flag32, v67, v68, str19

					while true do
						RunService.Heartbeat:Wait()

						if not fn() then
							break
						else
							if tbl2.Stall then
								exitTo = 1
								break
							else
								local autoSteal = AutoStealToggle and AutoStealToggle.Value == true

								if tbl2.AutoSteal ~= autoSteal then
									tbl2.AutoSteal = autoSteal
								end

								handlers.refreshPetIndex()

								if not handlers.stealWorkerAlive() then
									local stealClaim = handlers.StealClaim

									if stealClaim.current then
										stealClaim.last = stealClaim.current
									end

									stealClaim.current = nil
								end

								if handlers.stealWorkerAlive() and handlers.serviceStealClaimDrain() then
									exitTo = 2
									break
								elseif not handlers.stealWorkerAlive() then
									exitTo = 3
									break
								else
									do
										local character = localPlayer.Character

										if character ~= tbl13.characterToken then
											tbl13.characterToken = character

											if tbl13.lockedUid or tbl13.persistentUid or critical or tbl14.owner == "Steal" or tbl13.recentPositiveCarryUid() ~= nil then
												handlers.onAutoStealDeath(character)
											end
										end
									end

									if respawnGeneration ~= tbl13.respawnGeneration then
										respawnGeneration = tbl13.respawnGeneration
										tbl18 = {}
									end

									do
										local flag33, v69 = fn33()
										flag33 = flag33 and v69 and v69.Health > 0

										if not flag33 then
											exitTo = 4
											break
										else
											local v70 = carryLossRecoveryPending()

											if handlers.greatBloomUnlockReturnHasPriority() and not v70 and not critical and not tbl14.critical and not handlers.carryRequestInFlight() then
												exitTo = 5
												break
											else
												local v71

												if handlers.adminEventHasPriority() and not v70 then
													local chsaeCarryRequest2 = getgenv().__CHSAE_CarryRequest
													local flag34 = type(chsaeCarryRequest2) == "table" and chsaeCarryRequest2.owner == "AdminEvent"
													flag34 = tbl14.owner == "AdminEvent" or flag34 or not critical and not tbl14.critical and not handlers.carryRequestInFlight()

													if flag34 then
														exitTo = 7
														break
													else
														v71, v20, v21 = handlers.eggInventoryCapacityState()

														if v71 then
															exitTo = 6
															break
														else
															do
																local defaultMoveFallback = not fn43(true)
																handlers.defaultMoveFallback = defaultMoveFallback

																if defaultMoveFallback then
																	fn11("⏸️ Waiting to move")
																end
															end

															fn2(true)

															if not tbl2.PersistentSteal then
																tbl13.persistentUid = nil
															end

															tbl14.critical = critical or handlers.activeDroppedRecoveryRecord(tbl13.lockedUid) ~= nil
															tbl14.stealBeat = os.clock()
															v22 = fn26()
															uid = v22 and v22.Uid or tbl13.carriedUid or tbl13.lastDroppedUid or tbl13.lockedUid or tbl13.attemptUid

															if uid ~= nil and fn27(uid) and not handlers.StealClaim:verified(uid) then
																exitTo = 8
																break
															else
																chsaeCarryRequest = getgenv().__CHSAE_CarryRequest

																do
																	local n18

																	if type(chsaeCarryRequest) == "table" then
																		local n19, n20, flag35, n21, flag36, v72, flag37, uid2, max, n22, flag38

																		if chsaeCarryRequest.cancelledByDeath then
																			do
																				local deathRecoveryUid = tbl13.deathRecoveryUid or tbl13.lastDroppedUid

																				if chsaeCarryRequest.inFlight and deathRecoveryUid ~= nil and tostring(chsaeCarryRequest.uid) ~= tostring(deathRecoveryUid) then
																					chsaeCarryRequest.supersededByRecovery = true

																					if getgenv().__CHSAE_CarryRequest == chsaeCarryRequest then
																						getgenv().__CHSAE_CarryRequest = nil
																					end

																					tbl15.treadmillSuppressed = true

																					do
																						local v73 = tbl14
																						tbl14.stealWants = true
																						v73.critical = true
																					end

																					tbl14.stealBeat = os.clock()
																					fn11("🔁 Recovering dropped egg")
																					chsaeCarryRequest = nil
																				end
																			end

																			if chsaeCarryRequest and chsaeCarryRequest.inFlight then
																				local flag39, flag40, flag41

																				do
																					flag39 = chsaeCarryRequest.carrySeen == true and fn25(chsaeCarryRequest.uid) or nil
																					flag40 = chsaeCarryRequest.carrySeen == true and handlers.activeDroppedRecoveryRecord(chsaeCarryRequest.uid) or nil

																					do
																						local num3 = flag39 and tonumber(flag39.CarrierUserId) or nil
																						local str20 = flag39 and tostring(flag39.State) or nil
																						flag41 = flag39 ~= nil and (str20 == "Claimed" or num3 ~= nil and num3 > 0 and num3 ~= localPlayer.UserId)
																					end
																				end

																				local deathRecoveryMissingAt = tonumber(tbl13.deathRecoveryMissingAt) or 0

																				if carryLossRecoveryPending() and not flag40 and not flag41 and deathRecoveryMissingAt <= 0 then
																					deathRecoveryMissingAt = os.clock()
																					tbl13.deathRecoveryMissingAt = deathRecoveryMissingAt
																					tbl13.deathRecoveryMissingReason = flag39 and "pending-transitioning" or "pending-missing"
																				end

																				local flag42 = carryLossRecoveryPending()

																				if flag42 then
																					flag42 = fn16()

																					if not flag42 then
																						flag42 = deathRecoveryMissingAt > 0

																						if flag42 then
																							local deathRecoveryMissingGrace = tbl13.deathRecoveryMissingGrace
																							flag42 = os.clock() - deathRecoveryMissingAt >= deathRecoveryMissingGrace
																						end
																					end
																				end

																				if flag40 then
																					chsaeCarryRequest.supersededByRecovery = true

																					if getgenv().__CHSAE_CarryRequest == chsaeCarryRequest then
																						getgenv().__CHSAE_CarryRequest = nil
																					end

																					tbl15.treadmillSuppressed = true

																					do
																						local v73 = tbl14
																						tbl14.stealWants = true
																						v73.critical = true
																					end

																					tbl14.stealBeat = os.clock()
																					fn11("🔁 Retrieving dropped egg")
																					chsaeCarryRequest = nil

																					if chsaeCarryRequest == nil then
																						n19 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and tonumber(chsaeCarryRequest.retryAt) or 0
																						n20 = n19 - os.clock()
																						flag35 = chsaeCarryRequest and not chsaeCarryRequest.inFlight
																						n21 = flag35 and tonumber(chsaeCarryRequest.proofDeadline) or 0
																						n2 = n21 - os.clock()
																						flag36 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and chsaeCarryRequest.accepted and n2 > 0

																						if flag36 then
																							tbl15.treadmillSuppressed = true
																							v23 = tbl14
																							tbl14.stealWants = true
																							v23.critical = true
																							handlers.carry = "📦 Carry: waiting for server sync"
																							fn11("⏳ Confirming pickup")
																							task.wait(math.min(0.12, math.max(0.02, n2)))
																							if fn() then
																								continue
																							end
																						else
																							local n23, n24, v73, v74

																							do
																								v72 = chsaeCarryRequest and handlers.retainUnverifiedPickup(chsaeCarryRequest)

																								if v72 then
																									handlers.carry = "📦 Carry: unverified · retrying beside egg"
																									fn11("⏳ Retrying pickup")
																								end

																								flag37 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and not chsaeCarryRequest.accepted and n20 > 0

																								if flag37 then
																									if chsaeCarryRequest.uid then
																										uid2 = chsaeCarryRequest.uid
																										max = math.max
																										n22 = tonumber(tbl18[chsaeCarryRequest.uid]) or 0
																										tbl18[uid2] = max(n22, n19)
																									end
																								end

																								flag38 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and getgenv().__CHSAE_CarryRequest == chsaeCarryRequest

																								if flag38 then
																									getgenv().__CHSAE_CarryRequest = nil
																									n18 = 0
																								else
																									n18 = 0
																								end

																								for _, targetRarity in pairs(tbl2.TargetRarities) do
																									if targetRarity then
																										n18 += 1
																									end
																								end

																								n23 = 0

																								for _, targetCategory in pairs(tbl2.TargetCategories) do
																									if targetCategory then
																										n23 += 1
																									end
																								end

																								n24 = 0

																								for _, targetArea in pairs(tbl2.TargetAreas) do
																									if targetArea then
																										n24 += 1
																									end
																								end

																								stealHopFallback = handlers.stealHopFallback and handlers.stealHopFallback()

																								do
																									local flag43 = not stealHopFallback
																									v73 = flag43 and handlers.kgFilterActive(tbl2.TargetKGMode, tbl2.TargetKGThreshold)
																									v74 = flag43 and handlers.valueFilterActive(tbl2.TargetValueThreshold)
																								end
																							end

																							do
																								local v75 = handlers.normalStealPending()
																								flag2 = handlers.riftCollecting == true and not carryLossRecoveryPending() and not v75
																								flag3 = handlers.greatBloomUnlockNeedsCrane() and not v75 and not flag2
																								flag4 = tbl2.AutoPetIndex and handlers.PetIndex.target ~= nil and not v75 and not flag2 and not flag3 and not handlers.petIndexBlocked()
																							end

																							flag5 = not flag3 and handlers.greatBloomUnlockHasCraneReservation()
																							targetPriority = tbl2.TargetPriority

																							fn53 = function(arg, arg2, arg3, arg4)
																								local flag43 = tostring(arg.AssetCategory) == "Crane"
																								local flag44 = flag2 and handlers.riftFieldEligible(arg)

																								if not flag44 then
																									flag44 = flag4

																									if flag4 then
																										local target = handlers.PetIndex.target
																										flag44 = tostring(arg.Uid) == target
																									end
																								end

																								if not flag44 then
																									flag44 = not flag2 and not flag4 and (tbl2.AutoSteal or flag3)

																									if flag44 then
																										flag44 = not (flag5 and flag43)
																									end

																									if flag44 then
																										flag44 = flag3 and flag43

																										if not flag44 then
																											if arg2 then
																												arg2 = n18 == 0 or tbl2.TargetRarities[arg2._id]
																											end

																											flag44 = arg2 and (n23 == 0 or tbl2.TargetCategories[tostring(arg.AssetCategory)]) and (n24 == 0 or tbl2.TargetAreas[tostring(arg.AreaId)]) and (not v73 or handlers.kgFilterMatches(arg4.weight, tbl2.TargetKGMode, tbl2.TargetKGThreshold, arg4.weightKnown)) and (not v74 or handlers.valueFilterMatches(arg4.value, tbl2.TargetValueThreshold, "atLeast", arg4.valueKnown)) and (targetPriority ~= "Mutation" or #arg3 > 0)
																										end
																									end
																								end

																								return flag44
																							end

																							if flag3 or flag2 or flag4 then
																								targetPriority = nil
																							end

																							do
																								local flag43 = n18 == 0 and n23 == 0 and n24 == 0 and not v73 and not v74 and not targetPriority and not flag3 and not flag2 and not flag4 and not tbl13.lockedUid

																								if flag43 then
																									flag43 = not (tbl2.PersistentSteal and tbl13.persistentUid)
																								end

																								if flag43 then
																									exitTo = 12
																									break
																								else
																									do
																										local n25 = 0.15 - os.clock() - now2

																										if not fn16() and now2 > 0 and n25 > 0 then
																											task.wait(n25)
																										end
																									end

																									local candidateIndex = handlers.candidateIndex
																									local records = candidateIndex and candidateIndex.records
																									entries = candidateIndex and candidateIndex:GetEntries(targetPriority)

																									if type(records) ~= "table" or type(entries) ~= "table" then
																										exitTo = 13
																										break
																									else
																										local riftTargetUid2 = flag2 and handlers.riftTargetUid or flag4 and handlers.PetIndex.target or nil
																										local persistentUid = riftTargetUid2 or tbl2.PersistentSteal and tbl13.persistentUid or tbl13.lockedUid

																										if persistentUid and not riftTargetUid2 and handlers.deliveryRejected(persistentUid) then
																											fn13()
																											persistentUid = nil
																										end

																										rec = nil

																										if persistentUid then
																											local deathRecoveryMissingReason, flag44

																											do
																												local v75 = candidateIndex.byUid[tostring(persistentUid)]
																												deathRecoveryMissingReason = fn25(persistentUid)
																												str = tostring(tbl13.lastRequestKind or "")
																												flag44 = tostring(tbl13.deathRecoveryUid) == tostring(persistentUid) and (str == "death-drop-sync" or str == "carry-drop")

																												if deathRecoveryMissingReason then
																													rec = deathRecoveryMissingReason
																												else
																													rec = not flag44 and v75 and v75.rec
																												end
																											end

																											local str20 = deathRecoveryMissingReason and tostring(deathRecoveryMissingReason.State) or nil
																											local num3 = deathRecoveryMissingReason and tonumber(deathRecoveryMissingReason.CarrierUserId) or nil
																											local flag45 = deathRecoveryMissingReason ~= nil and ((str20 == "Slot" or str20 == "Dropped") and deathRecoveryMissingReason.BottomCFrame ~= nil or num3 == localPlayer.UserId)

																											if flag44 and flag45 then
																												tbl13.deathRecoveryMissingAt = 0
																												tbl13.deathRecoveryMissingReason = ""
																											end

																											if rec and handlers.isCaptureEventUid(rec.Uid) then
																												if tostring(tbl13.persistentUid) == tostring(persistentUid) then
																													tbl13.persistentUid = nil
																												end

																												if tostring(tbl13.lockedUid) == tostring(persistentUid) then
																													tbl13.lockedUid = nil
																												end

																												rec = nil
																											end

																											if rec and flag2 and not handlers.riftFieldEligible(rec) then
																												if tostring(handlers.riftTargetUid) == tostring(persistentUid) then
																													handlers.riftTargetUid = nil
																												end

																												tbl13.persistentUid = nil
																												tbl13.lockedUid = nil
																												rec = nil
																											end

																											local flag46, flag47, flag48, flag49, num4, flag50, flag51, flag52

																											if flag44 and not flag45 and not (deathRecoveryMissingReason ~= nil and (str20 == "Claimed" or num3 ~= nil and num3 > 0 and num3 ~= localPlayer.UserId)) then
																												do
																													local deathRecoveryMissingAt2 = tonumber(tbl13.deathRecoveryMissingAt) or 0

																													if deathRecoveryMissingAt2 <= 0 then
																														deathRecoveryMissingAt2 = os.clock()
																														tbl13.deathRecoveryMissingAt = deathRecoveryMissingAt2

																														do
																															local v75 = tbl13
																															deathRecoveryMissingReason = deathRecoveryMissingReason and "selection-transitioning" or "selection-missing"
																															v75.deathRecoveryMissingReason = deathRecoveryMissingReason
																														end
																													end

																													n3 = math.max(0, os.clock() - deathRecoveryMissingAt2)
																												end

																												if not fn16() and n3 < tbl13.deathRecoveryMissingGrace then
																													exitTo = 19
																													break
																												else
																													handlers.clearCarryLossRecovery(persistentUid)

																													if tostring(tbl13.lockedUid) == tostring(persistentUid) then
																														tbl13.lockedUid = nil
																													end

																													if tostring(tbl13.persistentUid) == tostring(persistentUid) then
																														tbl13.persistentUid = nil
																													end

																													tbl15.treadmillSuppressed = false

																													do
																														local v75 = tbl14
																														tbl14.stealWants = false
																														v75.critical = false
																													end

																													tbl14.release("Steal")
																													fn11("🟡 Finding another egg")
																													rec = nil
																													flag44 = false
																													flag46 = not rec or tostring(rec.State) == "Claimed"

																													if flag46 then
																														flag47 = not rec and not flag44 and tostring(tbl13.recentPositiveCarryUid()) == tostring(persistentUid) and (str == "carry-loss-sync" or str == "carry-drop")

																														if tostring(handlers.riftTargetUid) == tostring(persistentUid) then
																															handlers.riftTargetUid = nil
																														end

																														if tostring(tbl13.persistentUid) == tostring(persistentUid) then
																															tbl13.persistentUid = nil
																														end

																														if tostring(tbl13.lockedUid) == tostring(persistentUid) then
																															tbl13.lockedUid = nil
																														end

																														if type(handlers.clearCarryLossRecovery) == "function" then
																															handlers.clearCarryLossRecovery(persistentUid, flag47)
																														end

																														handlers.set("target", "🎯 Target: none")
																														rec = nil

																														if rec then
																															if handlers.getDroppedRecoveryRecord(rec.Uid) then
																																if armDroppedEggReacquire(rec.Uid, "confirmed dropped field record") then
																																	tbl18[rec.Uid] = nil
																																end
																															end

																															n4 = tonumber(tbl18[rec.Uid]) or 0

																															if os.clock() < n4 then
																																tbl15.treadmillSuppressed = true
																																tbl14.stealWants = true
																																tbl14.stealBeat = os.clock()
																																n5 = n4 - os.clock()
																																v24, v25 = fn33()
																																magnitude = v24 and rec.BottomCFrame and ((v24.Position - rec.BottomCFrame.Position) * Vector3.new(1, 0, 1)).Magnitude or math.huge
																																v26 = tostring
																																lastRequestKind = tbl13.lastRequestKind or ""
																																v27 = v26(lastRequestKind)
																																lower = string.lower
																																v28 = tostring
																																lastRequestError = tbl13.lastRequestError or ""
																																v29 = lower(v28(lastRequestError))
																																flag6 = v27 == "movement-trust"
																																flag7 = flag6 or v27 == "position-sync"
																																flag8 = flag7 or v27 == "activity-sync"
																																flag9 = flag8 or v27 == "movement-retry" or v27 == "server" or v27 == "retry" or v27 == "carry-loss-sync"
																																flag10 = flag9 or v27 == "death-drop-sync" or v27 == "carry-drop"
																																flag11 = handlers.activeDroppedRecoveryRecord(rec.Uid) ~= nil
																																v30 = v24 and v25
																																flag12 = v30 and v25.Health > 0 and tostring(tbl13.requestFailureUid) == tostring(rec.Uid)
																																flag13 = flag12 and tostring(tbl13.lockedUid) == tostring(rec.Uid)
																																flag10 = flag13 and flag10 and not v29:find("inventory is full", 1, true) and not v29:find("gameplay area", 1, true)

																																if flag10 then
																																	if flag11 then
																																		flag10 = flag11
																																	else
																																		now3 = os.clock()
																																		num = tonumber(tbl13.requestFailureAt)
																																		n6 = num or 0
																																		flag10 = now3 - n6 <= 6
																																	end
																																end

																																if flag10 then
																																	if flag11 then
																																		flag10 = flag11
																																	else
																																		n7 = fn35(v24.Position) or -1
																																		flag10 = n7 > 0
																																	end
																																end

																																if flag10 then
																																	tbl14.critical = true

																																	if tbl14.owner ~= "Steal" then
																																		tbl14.acquireWait("Steal", 0.1)
																																	end

																																	v31 = handlers
																																	retryResumeMode = magnitude <= 8 and "beside-egg" or "current-position"
																																	v31.retryResumeMode = retryResumeMode
																																	handlers.retryResumeDistance = magnitude
																																	handlers.retryResumeUid = rec.Uid
																																	v32 = fn11
																																	str2 = v27 == "movement-retry" and "⚡ Movement interrupted · resuming" or magnitude <= 8 and "🥚 Retrying carry…" or "🔁 Resuming carry target…"
																																	v32(str2)
																																else
																																	tbl14.critical = false
																																	tbl14.release("Steal")
																																	fn11("🟡 Target retry pending")
																																end

																																task.wait(math.min(0.2, math.max(0.03, n5)))
																																if fn() then
																																	continue
																																end
																															else
																																magnitude2 = fn33()

																																if rec then
																																	v33 = fn30(rec)

																																	tbl19 = v33 or {
																																		_id = "Target",
																																		RarityNumber = 0,
																																	}

																																	tbl20 = {
																																		rec = rec,
																																		rar = tbl19,
																																		muts = fn22(rec),
																																	}

																																	magnitude2 = magnitude2 and ((magnitude2.Position - rec.BottomCFrame.Position) * Vector3.new(1, 0, 1)).Magnitude or 0
																																	tbl20.dist = magnitude2
																																	tbl20.score = riftValueScore(rec)
																																	weight = fn23(rec) or 0
																																	tbl20.weight = weight
																																	v34 = tonumber
																																	rarityNumber = tbl19.RarityNumber
																																	rank = rarityNumber or tbl19.Rank
																																	rarNum = v34(rank) or 0
																																	tbl20.rarNum = rarNum
																																else
																																	v35, v36, v37 = ipairs(entries)
																																	v38 = v35
																																	n8 = 0
																																	n9 = 0
																																	tbl20 = nil

																																	for _, v75 in v38, v36, v37 do
																																		rec2 = v75.rec
																																		n8 += 1
																																		flag14 = tostring(rec2.State) == "Slot" and rec2.BottomCFrame and not handlers.isCaptureEventUid(rec2.Uid) and not handlers.deliveryRejected(rec2.Uid)

																																		if flag14 then
																																			flag15 = not tbl18[rec2.Uid]

																																			if flag15 then
																																				flag16 = flag15
																																			else
																																				v39 = tbl18[rec2.Uid]
																																				flag16 = os.clock() > v39
																																			end
																																		else
																																			flag16 = flag14
																																		end

																																		if flag16 then
																																			rarity = v75.rarity
																																			mutations = v75.mutations

																																			if fn53(rec2, rarity, mutations, v75) then
																																				n9 += 1

																																				tbl21 = {
																																					rec = rec2,
																																					rar = rarity,
																																					muts = mutations,
																																				}

																																				magnitude3 = magnitude2 and ((magnitude2.Position - rec2.BottomCFrame.Position) * Vector3.new(1, 0, 1)).Magnitude
																																				dist = magnitude3 or 0
																																				tbl21.dist = dist
																																				tbl21.score = v75.value
																																				tbl21.weight = v75.weight
																																				tbl21.rarNum = v75.rarityNumber

																																				if not tbl20 then
																																					flag17 = true
																																				elseif flag3 then
																																					flag18 = tbl21.score < tbl20.score

																																					if flag18 then
																																						flag17 = flag18
																																					else
																																						flag19 = tbl21.score == tbl20.score
																																						flag17 = flag19 and tbl21.weight < tbl20.weight
																																					end

																																					flag17 = flag17 or tbl21.score == tbl20.score and tbl21.weight == tbl20.weight and tbl21.dist < tbl20.dist
																																				elseif targetPriority == "Value" then
																																					flag17 = tbl21.score > tbl20.score or tbl21.score == tbl20.score and tbl21.dist < tbl20.dist
																																				elseif targetPriority == "Rarity" then
																																					flag17 = tbl21.rarNum > tbl20.rarNum or tbl21.rarNum == tbl20.rarNum and tbl21.score > tbl20.score or tbl21.rarNum == tbl20.rarNum and tbl21.score == tbl20.score and tbl21.dist < tbl20.dist
																																				elseif targetPriority == "Weight" then
																																					flag17 = tbl21.weight > tbl20.weight or tbl21.weight == tbl20.weight and tbl21.rarNum > tbl20.rarNum or tbl21.weight == tbl20.weight and tbl21.rarNum == tbl20.rarNum and tbl21.score > tbl20.score or tbl21.weight == tbl20.weight and tbl21.rarNum == tbl20.rarNum and tbl21.score == tbl20.score and tbl21.dist < tbl20.dist
																																				elseif targetPriority == "Farthest" then
																																					flag17 = tbl21.dist > tbl20.dist or tbl21.dist == tbl20.dist and tbl21.score > tbl20.score
																																				else
																																					flag17 = tbl21.dist < tbl20.dist or tbl21.dist == tbl20.dist and tbl21.score > tbl20.score
																																				end

																																				if flag17 then
																																					tbl20 = tbl21
																																				end
																																			end
																																		end
																																	end
																																end

																																if not tbl20 then
																																	n10 = 0
																																	n11 = 0

																																	for _, entry in ipairs(entries) do
																																		rec3 = entry.rec

																																		if rec3.BottomCFrame then
																																			rarity2 = entry.rarity
																																			mutations2 = entry.mutations
																																			flag20 = not handlers.isCaptureEventUid(rec3.Uid) and fn53(rec3, rarity2, mutations2, entry)
																																			flag21 = flag20 and tostring(rec3.State) == "Dropped"

																																			if flag21 then
																																				n10 += 1
																																			else
																																				flag20 = flag20 and tostring(rec3.State) == "Slot" and tbl18[rec3.Uid]

																																				if flag20 then
																																					v40 = tbl18[rec3.Uid]
																																					flag20 = os.clock() <= v40
																																				end

																																				if flag20 then
																																					n11 += 1
																																				end
																																			end
																																		end
																																	end

																																	tbl15.treadmillSuppressed = false
																																	tbl14.stealWants = false
																																	tbl14.release("Steal")
																																	handlers.set("target", "🎯 Target: none")
																																	handlers.carry = "📦 Carry: none"

																																	if flag2 then
																																		fn11("🌀 Waiting for a required Rift egg")
																																	elseif flag3 then
																																		fn11("🔓 Great Bloom · waiting for Crane egg")
																																	elseif flag5 then
																																		fn11("🔓 Crane reserved · continuing unlock")
																																	else
																																		flag22 = n10 > 0 and not tbl2.PersistentSteal

																																		if flag22 then
																																			v41 = fn11
																																			str3 = "🟡 %d selected egg%s dropped · enable Persistent"
																																			format = str3.format
																																			str4 = n10 == 1 and ""
																																			str5 = str4 or "s"
																																			v41(format(str3, n10, str5))
																																		elseif n11 > 0 then
																																			v42 = fn11
																																			str6 = "🟡 %d target%s cooling down"
																																			format2 = str6.format
																																			str7 = n11 == 1 and "" or "s"
																																			v42(format2(str6, n11, str7))
																																		else
																																			fn11("🟡 Waiting for target")
																																		end
																																	end

																																	checkStealHop = not flag2 and not flag3 and not flag5 and not flag4 and n10 == 0 and n11 == 0 and handlers.checkStealHop

																																	if checkStealHop then
																																		handlers.checkStealHop()
																																	end

																																	v43 = fn18
																																	n12 = tbl2.StealServerHop and 2 or 5
																																	v43(n12)
																																	if fn() then
																																		continue
																																	end
																																else
																																	if handlers.stealHop then
																																		handlers.stealHop.emptySince = nil
																																	end

																																	rar = tbl20.rar
																																	v44 = fn11
																																	str8 = flag2 and "🧪 Requested Lab egg locked"
																																	str9 = str8 or flag3 and "🔓 Crane egg locked" or stealHopFallback and "🟢 Best egg locked · no server matched"
																																	str10 = str9 or "🟢 Target locked"
																																	v44(str10)
																																	set = handlers.set
																																	str11 = "🎯 Target: %s %s · %.2f kg"
																																	format3 = str11.format
																																	str12 = tostring(rar._id)
																																	str13 = tostring(tbl20.rec.AssetCategory)
																																	num2 = tonumber(tbl20.weight)
																																	n13 = num2 or 0
																																	set("target", format3(str11, str12, str13, n13))
																																	directory = Assets and Assets.Directory and Assets.Directory[tostring(tbl20.rec.AssetCategory)]
																																	webhookTarget = tbl13.webhookTarget
																																	str14 = flag2 and "rift" or flag3 and "internal" or flag4 and "pet-index" or "steal-filter"
																																	flag23 = type(webhookTarget) == "table" and tostring(webhookTarget.uid) == tostring(tbl20.rec.Uid) and webhookTarget.source ~= nil

																																	if flag23 then
																																		str14 = webhookTarget.source
																																	end

																																	v45 = tbl13

																																	webhookTarget2 = {
																																		uid = tbl20.rec.Uid,
																																		source = str14,
																																	}

																																	v46 = tostring
																																	assetCategory = tbl20.rec.AssetCategory
																																	str15 = assetCategory or "Unknown"
																																	webhookTarget2.category = v46(str15)
																																	v47 = tostring
																																	id = rar._id or "Unknown"
																																	webhookTarget2.rarity = v47(id)
																																	v48 = tostring
																																	areaId = tbl20.rec.AreaId or "Unknown"
																																	webhookTarget2.area = v48(areaId)
																																	mutations3 = #tbl20.muts > 0 and table.concat(tbl20.muts, ", ") or "None"
																																	webhookTarget2.mutations = mutations3
																																	scale = tonumber(tbl20.rec.AssetScale) or 1
																																	webhookTarget2.scale = scale
																																	income = tonumber(tbl20.score) or 0
																																	webhookTarget2.income = income
																																	distance = tonumber(tbl20.dist) or 0
																																	webhookTarget2.distance = distance

																																	if directory then
																																		icon = directory.Egg and directory.Egg.Icon
																																		directory = icon or directory.Icon
																																	end

																																	webhookTarget2.icon = directory
																																	v45.webhookTarget = webhookTarget2
																																	tbl13.lockedUid = tbl20.rec.Uid
																																	flag24 = tbl2.PersistentSteal and not flag4

																																	if flag24 then
																																		tbl13.persistentUid = tbl20.rec.Uid
																																	end

																																	rec4 = tbl20.rec
																																	tbl15.treadmillSuppressed = true
																																	tbl14.stealWants = true

																																	if not tbl14.acquireWait("Steal", 4) then
																																		fn11("🟡 Waiting for pen…")
																																		task.wait(0.5)
																																		if fn() then
																																			continue
																																		end
																																	else
																																		tbl14.critical = true

																																		if not tbl14.waitPets(fn45, 4) then
																																			task.wait(0.1)
																																			if fn() then
																																				continue
																																			end
																																		elseif not tbl15.requestTreadmillExit() then
																																			v49 = tbl14
																																			tbl14.critical = false
																																			v49.stealWants = false
																																			tbl14.release("Steal")
																																			v50 = fn11
																																			str16 = tbl15.treadmillExitRequest.inFlight and "🟡 Treadmill server pending — retrying" or "🟡 Could not leave treadmill — retrying"
																																			v50(str16)
																																			task.wait(0.25)
																																			if fn() then
																																				continue
																																			end
																																		elseif not tbl15.waitForToolFree(1.5) then
																																			v51 = tbl14
																																			tbl14.critical = false
																																			v51.stealWants = true
																																			fn11("🟡 Finishing previous activity — retrying")
																																			task.wait(0.1)
																																			if fn() then
																																				continue
																																			end
																																		else
																																			riftTargetUid = not carryLossRecoveryPending() and handlers.riftCollecting == true and handlers.riftTargetUid or nil
																																			flag25 = riftTargetUid and tostring(rec4.Uid) ~= tostring(riftTargetUid)

																																			if flag25 then
																																				flag26 = flag25
																																			else
																																				v52 = flag4 and handlers.petIndexBlocked()
																																				flag26 = v52 and not carryLossRecoveryPending()
																																			end

																																			if flag26 then
																																				if tostring(tbl13.lockedUid) == tostring(rec4.Uid) then
																																					tbl13.lockedUid = nil
																																				end

																																				v53 = tbl14
																																				tbl14.critical = false
																																				v53.stealWants = false
																																				tbl14.release("Steal")
																																				fn11("🌀 Event target changed · selecting nearest")
																																				fn18(0.05)
																																				if fn() then
																																					continue
																																				end
																																			else
																																				flag27 = fn25(rec4.Uid)
																																				str17 = flag27 and tostring(flag27.State) or "Missing"
																																				flag28 = not flag27 or str17 ~= "Slot" and str17 ~= "Dropped"

																																				if flag28 then
																																					persistentSteal = tbl2.PersistentSteal
																																					flag27 = persistentSteal and flag27 and str17 ~= "Claimed"
																																					tbl14.critical = false
																																					tbl14.release("Steal")

																																					if flag27 then
																																						tbl15.treadmillSuppressed = true
																																						tbl14.stealWants = true
																																						tbl14.stealBeat = os.clock()
																																						fn11(("🔁 Persistent — target became %s"):format(str17))
																																						fn18(0.75)
																																					else
																																						if tostring(tbl13.persistentUid) == tostring(rec4.Uid) then
																																							tbl13.persistentUid = nil
																																						end

																																						if tostring(tbl13.lockedUid) == tostring(rec4.Uid) then
																																							tbl13.lockedUid = nil
																																						end

																																						tbl13.webhookTarget = nil
																																						tbl15.treadmillSuppressed = false
																																						tbl14.stealWants = false
																																						handlers.set("target", "🎯 Target: none")

																																						if handlers.candidateIndex then
																																							handlers.candidateIndex:Invalidate(rec4.Uid, "target changed while leaving treadmill")
																																						end

																																						fn11(("🟡 Target became %s — rescanning"):format(str17))
																																						fn18(0.08)
																																					end

																																					if fn() then
																																						continue
																																					end
																																				elseif localPlayer:GetAttribute("InScrambleArena") == true then
																																					fn11("Leaving Dr. Scramble's arena")
																																					handlers.leaveScrambleArena(fn45)
																																					if fn() then
																																						continue
																																					end
																																				else
																																					if tbl2.EnableDefaultSpeed then
																																						v54, str18, v55 = handlers.runDefaultSpeedSteal(flag27, fn45)
																																					else
																																						stealMovementType = tbl2.StealMovementType
																																						v54, str18, v55 = handlers.runFlySteal(flag27, fn45, stealMovementType == "Fly", stealMovementType == "Relay", stealMovementType == "Hop Fly")
																																					end

																																					if v54 then
																																						if handlers.candidateIndex then
																																							handlers.candidateIndex:Invalidate(flag27.Uid, "transaction verified")
																																						end

																																						handlers.clearCarryLossRecovery(flag27.Uid)
																																						v56 = tbl13
																																						v57 = tbl13
																																						tbl13.persistentUid = nil
																																						v56.lockedUid = nil
																																						v57.lastDroppedUid = nil
																																						v58 = tbl13
																																						tbl13.dropDetectedAt = 0
																																						v58.consecutiveFailures = 0
																																						critical = false
																																						handlers.activeGuardAreaId = nil
																																						v59 = tbl14
																																						tbl14.critical = false
																																						v59.stealWants = false
																																						tbl14.release("Steal")
																																						tbl14.wakeSeller()
																																						v60 = pcall
																																						finishStealTimer = handlers.finishStealTimer
																																						returnAt = v55.returnAt or os.clock()
																																						n14 = returnAt - v55.cycleAt
																																						now4 = os.clock()
																																						returnAt2 = v55.returnAt or os.clock()
																																						v60(finishStealTimer, n14, now4 - returnAt2)
																																						fn11("✅ Egg collected")
																																					else
																																						handlers.pauseStealTimer()
																																						v61 = tbl14
																																						tbl14.critical = false
																																						v61.stealWants = false
																																						tbl14.release("Steal")
																																						v62 = tbl13
																																						v63 = tbl13
																																						lastRequestError2 = tostring(str18)
																																						v62.lastRequestKind = "standalone"
																																						v63.lastRequestError = lastRequestError2

																																						if fn16() then
																																							fn11("⏳ Wall closed — waiting")

																																							while true do
																																								fn18(5, function()
																																									return not fn16() or not fn45()
																																								end)

																																								flag29 = not fn()
																																								flag30 = flag29 or not fn45()
																																								flag31 = flag30 or not fn16()
																																								if not flag31 then
																																									continue
																																								end
																																								break
																																							end

																																							task.wait(0.5)
																																						elseif fn45() then
																																							v64 = tostring
																																							str18 = str18 or "movement unavailable"
																																							v65 = v64(str18)
																																							v66 = tbl13
																																							min = math.min
																																							consecutiveFailures = tbl13.consecutiveFailures
																																							n15 = consecutiveFailures or 0
																																							v66.consecutiveFailures = min(n15 + 1, 6)
																																							tbl18[flag27.Uid] = os.clock() + 10
																																							n16 = math.min(2 ^ (tbl13.consecutiveFailures - 1), 30)
																																							fn11(("🔁 Retrying in %ds · %s"):format(n16, v65:sub(1, 100)))
																																							n17 = os.clock() + n16

																																							while true do
																																								flag32 = fn() and fn45() and os.clock() < n17
																																								if flag32 then
																																									task.wait(0.25)
																																									continue
																																								end
																																								break
																																							end
																																						end
																																					end

																																					if fn() then
																																						continue
																																					end
																																				end
																																			end
																																		end
																																	end
																																end
																															end
																														else
																															magnitude2 = fn33()

																															if rec then
																																v33 = fn30(rec)

																																tbl19 = v33 or {
																																	_id = "Target",
																																	RarityNumber = 0,
																																}

																																tbl20 = {
																																	rec = rec,
																																	rar = tbl19,
																																	muts = fn22(rec),
																																}

																																magnitude2 = magnitude2 and ((magnitude2.Position - rec.BottomCFrame.Position) * Vector3.new(1, 0, 1)).Magnitude or 0
																																tbl20.dist = magnitude2
																																tbl20.score = riftValueScore(rec)
																																weight = fn23(rec) or 0
																																tbl20.weight = weight
																																v34 = tonumber
																																rarityNumber = tbl19.RarityNumber
																																rank = rarityNumber or tbl19.Rank
																																rarNum = v34(rank) or 0
																																tbl20.rarNum = rarNum
																															else
																																v35, v36, v37 = ipairs(entries)
																																v38 = v35
																																n8 = 0
																																n9 = 0
																																tbl20 = nil

																																for _, v75 in v38, v36, v37 do
																																	rec2 = v75.rec
																																	n8 += 1
																																	flag14 = tostring(rec2.State) == "Slot" and rec2.BottomCFrame and not handlers.isCaptureEventUid(rec2.Uid) and not handlers.deliveryRejected(rec2.Uid)

																																	if flag14 then
																																		flag15 = not tbl18[rec2.Uid]

																																		if flag15 then
																																			flag16 = flag15
																																		else
																																			v39 = tbl18[rec2.Uid]
																																			flag16 = os.clock() > v39
																																		end
																																	else
																																		flag16 = flag14
																																	end

																																	if flag16 then
																																		rarity = v75.rarity
																																		mutations = v75.mutations

																																		if fn53(rec2, rarity, mutations, v75) then
																																			n9 += 1

																																			tbl21 = {
																																				rec = rec2,
																																				rar = rarity,
																																				muts = mutations,
																																			}

																																			magnitude3 = magnitude2 and ((magnitude2.Position - rec2.BottomCFrame.Position) * Vector3.new(1, 0, 1)).Magnitude
																																			dist = magnitude3 or 0
																																			tbl21.dist = dist
																																			tbl21.score = v75.value
																																			tbl21.weight = v75.weight
																																			tbl21.rarNum = v75.rarityNumber

																																			if not tbl20 then
																																				flag17 = true
																																			elseif flag3 then
																																				flag18 = tbl21.score < tbl20.score

																																				if flag18 then
																																					flag17 = flag18
																																				else
																																					flag19 = tbl21.score == tbl20.score
																																					flag17 = flag19 and tbl21.weight < tbl20.weight
																																				end

																																				flag17 = flag17 or tbl21.score == tbl20.score and tbl21.weight == tbl20.weight and tbl21.dist < tbl20.dist
																																			elseif targetPriority == "Value" then
																																				flag17 = tbl21.score > tbl20.score or tbl21.score == tbl20.score and tbl21.dist < tbl20.dist
																																			elseif targetPriority == "Rarity" then
																																				flag17 = tbl21.rarNum > tbl20.rarNum or tbl21.rarNum == tbl20.rarNum and tbl21.score > tbl20.score or tbl21.rarNum == tbl20.rarNum and tbl21.score == tbl20.score and tbl21.dist < tbl20.dist
																																			elseif targetPriority == "Weight" then
																																				flag17 = tbl21.weight > tbl20.weight or tbl21.weight == tbl20.weight and tbl21.rarNum > tbl20.rarNum or tbl21.weight == tbl20.weight and tbl21.rarNum == tbl20.rarNum and tbl21.score > tbl20.score or tbl21.weight == tbl20.weight and tbl21.rarNum == tbl20.rarNum and tbl21.score == tbl20.score and tbl21.dist < tbl20.dist
																																			elseif targetPriority == "Farthest" then
																																				flag17 = tbl21.dist > tbl20.dist or tbl21.dist == tbl20.dist and tbl21.score > tbl20.score
																																			else
																																				flag17 = tbl21.dist < tbl20.dist or tbl21.dist == tbl20.dist and tbl21.score > tbl20.score
																																			end

																																			if flag17 then
																																				tbl20 = tbl21
																																			end
																																		end
																																	end
																																end
																															end

																															if not tbl20 then
																																n10 = 0
																																n11 = 0

																																for _, entry in ipairs(entries) do
																																	rec3 = entry.rec

																																	if rec3.BottomCFrame then
																																		rarity2 = entry.rarity
																																		mutations2 = entry.mutations
																																		flag20 = not handlers.isCaptureEventUid(rec3.Uid) and fn53(rec3, rarity2, mutations2, entry)
																																		flag21 = flag20 and tostring(rec3.State) == "Dropped"

																																		if flag21 then
																																			n10 += 1
																																		else
																																			flag20 = flag20 and tostring(rec3.State) == "Slot" and tbl18[rec3.Uid]

																																			if flag20 then
																																				v40 = tbl18[rec3.Uid]
																																				flag20 = os.clock() <= v40
																																			end

																																			if flag20 then
																																				n11 += 1
																																			end
																																		end
																																	end
																																end

																																tbl15.treadmillSuppressed = false
																																tbl14.stealWants = false
																																tbl14.release("Steal")
																																handlers.set("target", "🎯 Target: none")
																																handlers.carry = "📦 Carry: none"

																																if flag2 then
																																	fn11("🌀 Waiting for a required Rift egg")
																																elseif flag3 then
																																	fn11("🔓 Great Bloom · waiting for Crane egg")
																																elseif flag5 then
																																	fn11("🔓 Crane reserved · continuing unlock")
																																else
																																	flag22 = n10 > 0 and not tbl2.PersistentSteal

																																	if flag22 then
																																		v41 = fn11
																																		str3 = "🟡 %d selected egg%s dropped · enable Persistent"
																																		format = str3.format
																																		str4 = n10 == 1 and ""
																																		str5 = str4 or "s"
																																		v41(format(str3, n10, str5))
																																	elseif n11 > 0 then
																																		v42 = fn11
																																		str6 = "🟡 %d target%s cooling down"
																																		format2 = str6.format
																																		str7 = n11 == 1 and "" or "s"
																																		v42(format2(str6, n11, str7))
																																	else
																																		fn11("🟡 Waiting for target")
																																	end
																																end

																																checkStealHop = not flag2 and not flag3 and not flag5 and not flag4 and n10 == 0 and n11 == 0 and handlers.checkStealHop

																																if checkStealHop then
																																	handlers.checkStealHop()
																																end

																																v43 = fn18
																																n12 = tbl2.StealServerHop and 2 or 5
																																v43(n12)
																																if fn() then
																																	continue
																																end
																															else
																																if handlers.stealHop then
																																	handlers.stealHop.emptySince = nil
																																end

																																rar = tbl20.rar
																																v44 = fn11
																																str8 = flag2 and "🧪 Requested Lab egg locked"
																																str9 = str8 or flag3 and "🔓 Crane egg locked" or stealHopFallback and "🟢 Best egg locked · no server matched"
																																str10 = str9 or "🟢 Target locked"
																																v44(str10)
																																set = handlers.set
																																str11 = "🎯 Target: %s %s · %.2f kg"
																																format3 = str11.format
																																str12 = tostring(rar._id)
																																str13 = tostring(tbl20.rec.AssetCategory)
																																num2 = tonumber(tbl20.weight)
																																n13 = num2 or 0
																																set("target", format3(str11, str12, str13, n13))
																																directory = Assets and Assets.Directory and Assets.Directory[tostring(tbl20.rec.AssetCategory)]
																																webhookTarget = tbl13.webhookTarget
																																str14 = flag2 and "rift" or flag3 and "internal" or flag4 and "pet-index" or "steal-filter"
																																flag23 = type(webhookTarget) == "table" and tostring(webhookTarget.uid) == tostring(tbl20.rec.Uid) and webhookTarget.source ~= nil

																																if flag23 then
																																	str14 = webhookTarget.source
																																end

																																v45 = tbl13

																																webhookTarget2 = {
																																	uid = tbl20.rec.Uid,
																																	source = str14,
																																}

																																v46 = tostring
																																assetCategory = tbl20.rec.AssetCategory
																																str15 = assetCategory or "Unknown"
																																webhookTarget2.category = v46(str15)
																																v47 = tostring
																																id = rar._id or "Unknown"
																																webhookTarget2.rarity = v47(id)
																																v48 = tostring
																																areaId = tbl20.rec.AreaId or "Unknown"
																																webhookTarget2.area = v48(areaId)
																																mutations3 = #tbl20.muts > 0 and table.concat(tbl20.muts, ", ") or "None"
																																webhookTarget2.mutations = mutations3
																																scale = tonumber(tbl20.rec.AssetScale) or 1
																																webhookTarget2.scale = scale
																																income = tonumber(tbl20.score) or 0
																																webhookTarget2.income = income
																																distance = tonumber(tbl20.dist) or 0
																																webhookTarget2.distance = distance

																																if directory then
																																	icon = directory.Egg and directory.Egg.Icon
																																	directory = icon or directory.Icon
																																end

																																webhookTarget2.icon = directory
																																v45.webhookTarget = webhookTarget2
																																tbl13.lockedUid = tbl20.rec.Uid
																																flag24 = tbl2.PersistentSteal and not flag4

																																if flag24 then
																																	tbl13.persistentUid = tbl20.rec.Uid
																																end

																																rec4 = tbl20.rec
																																tbl15.treadmillSuppressed = true
																																tbl14.stealWants = true

																																if not tbl14.acquireWait("Steal", 4) then
																																	fn11("🟡 Waiting for pen…")
																																	task.wait(0.5)
																																	if fn() then
																																		continue
																																	end
																																else
																																	tbl14.critical = true

																																	if not tbl14.waitPets(fn45, 4) then
																																		task.wait(0.1)
																																		if fn() then
																																			continue
																																		end
																																	elseif not tbl15.requestTreadmillExit() then
																																		v49 = tbl14
																																		tbl14.critical = false
																																		v49.stealWants = false
																																		tbl14.release("Steal")
																																		v50 = fn11
																																		str16 = tbl15.treadmillExitRequest.inFlight and "🟡 Treadmill server pending — retrying" or "🟡 Could not leave treadmill — retrying"
																																		v50(str16)
																																		task.wait(0.25)
																																		if fn() then
																																			continue
																																		end
																																	elseif not tbl15.waitForToolFree(1.5) then
																																		v51 = tbl14
																																		tbl14.critical = false
																																		v51.stealWants = true
																																		fn11("🟡 Finishing previous activity — retrying")
																																		task.wait(0.1)
																																		if fn() then
																																			continue
																																		end
																																	else
																																		riftTargetUid = not carryLossRecoveryPending() and handlers.riftCollecting == true and handlers.riftTargetUid or nil
																																		flag25 = riftTargetUid and tostring(rec4.Uid) ~= tostring(riftTargetUid)

																																		if flag25 then
																																			flag26 = flag25
																																		else
																																			v52 = flag4 and handlers.petIndexBlocked()
																																			flag26 = v52 and not carryLossRecoveryPending()
																																		end

																																		if flag26 then
																																			if tostring(tbl13.lockedUid) == tostring(rec4.Uid) then
																																				tbl13.lockedUid = nil
																																			end

																																			v53 = tbl14
																																			tbl14.critical = false
																																			v53.stealWants = false
																																			tbl14.release("Steal")
																																			fn11("🌀 Event target changed · selecting nearest")
																																			fn18(0.05)
																																			if fn() then
																																				continue
																																			end
																																		else
																																			flag27 = fn25(rec4.Uid)
																																			str17 = flag27 and tostring(flag27.State) or "Missing"
																																			flag28 = not flag27 or str17 ~= "Slot" and str17 ~= "Dropped"

																																			if flag28 then
																																				persistentSteal = tbl2.PersistentSteal
																																				flag27 = persistentSteal and flag27 and str17 ~= "Claimed"
																																				tbl14.critical = false
																																				tbl14.release("Steal")

																																				if flag27 then
																																					tbl15.treadmillSuppressed = true
																																					tbl14.stealWants = true
																																					tbl14.stealBeat = os.clock()
																																					fn11(("🔁 Persistent — target became %s"):format(str17))
																																					fn18(0.75)
																																				else
																																					if tostring(tbl13.persistentUid) == tostring(rec4.Uid) then
																																						tbl13.persistentUid = nil
																																					end

																																					if tostring(tbl13.lockedUid) == tostring(rec4.Uid) then
																																						tbl13.lockedUid = nil
																																					end

																																					tbl13.webhookTarget = nil
																																					tbl15.treadmillSuppressed = false
																																					tbl14.stealWants = false
																																					handlers.set("target", "🎯 Target: none")

																																					if handlers.candidateIndex then
																																						handlers.candidateIndex:Invalidate(rec4.Uid, "target changed while leaving treadmill")
																																					end

																																					fn11(("🟡 Target became %s — rescanning"):format(str17))
																																					fn18(0.08)
																																				end

																																				if fn() then
																																					continue
																																				end
																																			elseif localPlayer:GetAttribute("InScrambleArena") == true then
																																				fn11("Leaving Dr. Scramble's arena")
																																				handlers.leaveScrambleArena(fn45)
																																				if fn() then
																																					continue
																																				end
																																			else
																																				if tbl2.EnableDefaultSpeed then
																																					v54, str18, v55 = handlers.runDefaultSpeedSteal(flag27, fn45)
																																				else
																																					stealMovementType = tbl2.StealMovementType
																																					v54, str18, v55 = handlers.runFlySteal(flag27, fn45, stealMovementType == "Fly", stealMovementType == "Relay", stealMovementType == "Hop Fly")
																																				end

																																				if v54 then
																																					if handlers.candidateIndex then
																																						handlers.candidateIndex:Invalidate(flag27.Uid, "transaction verified")
																																					end

																																					handlers.clearCarryLossRecovery(flag27.Uid)
																																					v56 = tbl13
																																					v57 = tbl13
																																					tbl13.persistentUid = nil
																																					v56.lockedUid = nil
																																					v57.lastDroppedUid = nil
																																					v58 = tbl13
																																					tbl13.dropDetectedAt = 0
																																					v58.consecutiveFailures = 0
																																					critical = false
																																					handlers.activeGuardAreaId = nil
																																					v59 = tbl14
																																					tbl14.critical = false
																																					v59.stealWants = false
																																					tbl14.release("Steal")
																																					tbl14.wakeSeller()
																																					v60 = pcall
																																					finishStealTimer = handlers.finishStealTimer
																																					returnAt = v55.returnAt or os.clock()
																																					n14 = returnAt - v55.cycleAt
																																					now4 = os.clock()
																																					returnAt2 = v55.returnAt or os.clock()
																																					v60(finishStealTimer, n14, now4 - returnAt2)
																																					fn11("✅ Egg collected")
																																				else
																																					handlers.pauseStealTimer()
																																					v61 = tbl14
																																					tbl14.critical = false
																																					v61.stealWants = false
																																					tbl14.release("Steal")
																																					v62 = tbl13
																																					v63 = tbl13
																																					lastRequestError2 = tostring(str18)
																																					v62.lastRequestKind = "standalone"
																																					v63.lastRequestError = lastRequestError2

																																					if fn16() then
																																						fn11("⏳ Wall closed — waiting")

																																						while true do
																																							fn18(5, function()
																																								return not fn16() or not fn45()
																																							end)

																																							flag29 = not fn()
																																							flag30 = flag29 or not fn45()
																																							flag31 = flag30 or not fn16()
																																							if not flag31 then
																																								continue
																																							end
																																							break
																																						end

																																						task.wait(0.5)
																																					elseif fn45() then
																																						v64 = tostring
																																						str18 = str18 or "movement unavailable"
																																						v65 = v64(str18)
																																						v66 = tbl13
																																						min = math.min
																																						consecutiveFailures = tbl13.consecutiveFailures
																																						n15 = consecutiveFailures or 0
																																						v66.consecutiveFailures = min(n15 + 1, 6)
																																						tbl18[flag27.Uid] = os.clock() + 10
																																						n16 = math.min(2 ^ (tbl13.consecutiveFailures - 1), 30)
																																						fn11(("🔁 Retrying in %ds · %s"):format(n16, v65:sub(1, 100)))
																																						n17 = os.clock() + n16

																																						while true do
																																							flag32 = fn() and fn45() and os.clock() < n17
																																							if flag32 then
																																								task.wait(0.25)
																																								continue
																																							end
																																							break
																																						end
																																					end
																																				end

																																				if fn() then
																																					continue
																																				end
																																			end
																																		end
																																	end
																																end
																															end
																														end
																													else
																														flag48 = tostring(rec.State) ~= "Slot" and tostring(rec.State) ~= "Dropped"

																														if flag48 then
																															flag49 = tostring(tbl13.lastDroppedUid) == tostring(persistentUid) and (str == "carry-loss-sync" or str == "death-drop-sync" or str == "carry-drop")
																															num4 = tonumber(rec.CarrierUserId)
																															flag50 = num4 ~= nil and num4 > 0 and num4 ~= localPlayer.UserId
																															flag51 = flag49 and not flag50

																															if flag51 then
																																tbl15.treadmillSuppressed = true
																																v67 = tbl14
																																tbl14.stealWants = true
																																v67.critical = true
																																tbl14.stealBeat = os.clock()

																																if tbl14.owner ~= "Steal" then
																																	tbl14.acquireWait("Steal", 0.1)
																																end

																																v68 = fn11
																																str19 = str == "death-drop-sync" and "🔁 Respawned · waiting for dropped egg" or "🥚 Dropped egg syncing · holding recovery"
																																v68(str19)
																																fn18(0.08)
																																if fn() then
																																	continue
																																end
																															else
																																flag52 = tbl2.PersistentSteal and tostring(tbl13.persistentUid) == tostring(persistentUid)

																																if flag52 then
																																	tbl15.treadmillSuppressed = true
																																	tbl14.stealWants = true
																																	tbl14.stealBeat = os.clock()
																																	tbl14.release("Steal")
																																	fn11("🔁 Persistent — waiting for target to drop")
																																	fn18(0.75)
																																	if fn() then
																																		continue
																																	end
																																else
																																	tbl13.lockedUid = nil
																																	flag49 = flag49 and type(handlers.clearCarryLossRecovery) == "function"

																																	if flag49 then
																																		handlers.clearCarryLossRecovery(persistentUid)
																																	end

																																	rec = nil

																																	if rec then
																																		if handlers.getDroppedRecoveryRecord(rec.Uid) then
																																			if armDroppedEggReacquire(rec.Uid, "confirmed dropped field record") then
																																				tbl18[rec.Uid] = nil
																																			end
																																		end

																																		n4 = tonumber(tbl18[rec.Uid]) or 0

																																		if os.clock() < n4 then
																																			tbl15.treadmillSuppressed = true
																																			tbl14.stealWants = true
																																			tbl14.stealBeat = os.clock()
																																			n5 = n4 - os.clock()
																																			v24, v25 = fn33()
																																			magnitude = v24 and rec.BottomCFrame and ((v24.Position - rec.BottomCFrame.Position) * Vector3.new(1, 0, 1)).Magnitude or math.huge
																																			v26 = tostring
																																			lastRequestKind = tbl13.lastRequestKind or ""
																																			v27 = v26(lastRequestKind)
																																			lower = string.lower
																																			v28 = tostring
																																			lastRequestError = tbl13.lastRequestError or ""
																																			v29 = lower(v28(lastRequestError))
																																			flag6 = v27 == "movement-trust"
																																			flag7 = flag6 or v27 == "position-sync"
																																			flag8 = flag7 or v27 == "activity-sync"
																																			flag9 = flag8 or v27 == "movement-retry" or v27 == "server" or v27 == "retry" or v27 == "carry-loss-sync"
																																			flag10 = flag9 or v27 == "death-drop-sync" or v27 == "carry-drop"
																																			flag11 = handlers.activeDroppedRecoveryRecord(rec.Uid) ~= nil
																																			v30 = v24 and v25
																																			flag12 = v30 and v25.Health > 0 and tostring(tbl13.requestFailureUid) == tostring(rec.Uid)
																																			flag13 = flag12 and tostring(tbl13.lockedUid) == tostring(rec.Uid)
																																			flag10 = flag13 and flag10 and not v29:find("inventory is full", 1, true) and not v29:find("gameplay area", 1, true)

																																			if flag10 then
																																				if flag11 then
																																					flag10 = flag11
																																				else
																																					now3 = os.clock()
																																					num = tonumber(tbl13.requestFailureAt)
																																					n6 = num or 0
																																					flag10 = now3 - n6 <= 6
																																				end
																																			end

																																			if flag10 then
																																				if flag11 then
																																					flag10 = flag11
																																				else
																																					n7 = fn35(v24.Position) or -1
																																					flag10 = n7 > 0
																																				end
																																			end

																																			if flag10 then
																																				tbl14.critical = true

																																				if tbl14.owner ~= "Steal" then
																																					tbl14.acquireWait("Steal", 0.1)
																																				end

																																				v31 = handlers
																																				retryResumeMode = magnitude <= 8 and "beside-egg" or "current-position"
																																				v31.retryResumeMode = retryResumeMode
																																				handlers.retryResumeDistance = magnitude
																																				handlers.retryResumeUid = rec.Uid
																																				v32 = fn11
																																				str2 = v27 == "movement-retry" and "⚡ Movement interrupted · resuming" or magnitude <= 8 and "🥚 Retrying carry…" or "🔁 Resuming carry target…"
																																				v32(str2)
																																			else
																																				tbl14.critical = false
																																				tbl14.release("Steal")
																																				fn11("🟡 Target retry pending")
																																			end

																																			task.wait(math.min(0.2, math.max(0.03, n5)))
																																			if fn() then
																																				continue
																																			end
																																		else
																																			magnitude2 = fn33()

																																			if rec then
																																				v33 = fn30(rec)

																																				tbl19 = v33 or {
																																					_id = "Target",
																																					RarityNumber = 0,
																																				}

																																				tbl20 = {
																																					rec = rec,
																																					rar = tbl19,
																																					muts = fn22(rec),
																																				}

																																				magnitude2 = magnitude2 and ((magnitude2.Position - rec.BottomCFrame.Position) * Vector3.new(1, 0, 1)).Magnitude or 0
																																				tbl20.dist = magnitude2
																																				tbl20.score = riftValueScore(rec)
																																				weight = fn23(rec) or 0
																																				tbl20.weight = weight
																																				v34 = tonumber
																																				rarityNumber = tbl19.RarityNumber
																																				rank = rarityNumber or tbl19.Rank
																																				rarNum = v34(rank) or 0
																																				tbl20.rarNum = rarNum
																																			else
																																				v35, v36, v37 = ipairs(entries)
																																				v38 = v35
																																				n8 = 0
																																				n9 = 0
																																				tbl20 = nil

																																				for _, v75 in v38, v36, v37 do
																																					rec2 = v75.rec
																																					n8 += 1
																																					flag14 = tostring(rec2.State) == "Slot" and rec2.BottomCFrame and not handlers.isCaptureEventUid(rec2.Uid) and not handlers.deliveryRejected(rec2.Uid)

																																					if flag14 then
																																						flag15 = not tbl18[rec2.Uid]

																																						if flag15 then
																																							flag16 = flag15
																																						else
																																							v39 = tbl18[rec2.Uid]
																																							flag16 = os.clock() > v39
																																						end
																																					else
																																						flag16 = flag14
																																					end

																																					if flag16 then
																																						rarity = v75.rarity
																																						mutations = v75.mutations

																																						if fn53(rec2, rarity, mutations, v75) then
																																							n9 += 1

																																							tbl21 = {
																																								rec = rec2,
																																								rar = rarity,
																																								muts = mutations,
																																							}

																																							magnitude3 = magnitude2 and ((magnitude2.Position - rec2.BottomCFrame.Position) * Vector3.new(1, 0, 1)).Magnitude
																																							dist = magnitude3 or 0
																																							tbl21.dist = dist
																																							tbl21.score = v75.value
																																							tbl21.weight = v75.weight
																																							tbl21.rarNum = v75.rarityNumber

																																							if not tbl20 then
																																								flag17 = true
																																							elseif flag3 then
																																								flag18 = tbl21.score < tbl20.score

																																								if flag18 then
																																									flag17 = flag18
																																								else
																																									flag19 = tbl21.score == tbl20.score
																																									flag17 = flag19 and tbl21.weight < tbl20.weight
																																								end

																																								flag17 = flag17 or tbl21.score == tbl20.score and tbl21.weight == tbl20.weight and tbl21.dist < tbl20.dist
																																							elseif targetPriority == "Value" then
																																								flag17 = tbl21.score > tbl20.score or tbl21.score == tbl20.score and tbl21.dist < tbl20.dist
																																							elseif targetPriority == "Rarity" then
																																								flag17 = tbl21.rarNum > tbl20.rarNum or tbl21.rarNum == tbl20.rarNum and tbl21.score > tbl20.score or tbl21.rarNum == tbl20.rarNum and tbl21.score == tbl20.score and tbl21.dist < tbl20.dist
																																							elseif targetPriority == "Weight" then
																																								flag17 = tbl21.weight > tbl20.weight or tbl21.weight == tbl20.weight and tbl21.rarNum > tbl20.rarNum or tbl21.weight == tbl20.weight and tbl21.rarNum == tbl20.rarNum and tbl21.score > tbl20.score or tbl21.weight == tbl20.weight and tbl21.rarNum == tbl20.rarNum and tbl21.score == tbl20.score and tbl21.dist < tbl20.dist
																																							elseif targetPriority == "Farthest" then
																																								flag17 = tbl21.dist > tbl20.dist or tbl21.dist == tbl20.dist and tbl21.score > tbl20.score
																																							else
																																								flag17 = tbl21.dist < tbl20.dist or tbl21.dist == tbl20.dist and tbl21.score > tbl20.score
																																							end

																																							if flag17 then
																																								tbl20 = tbl21
																																							end
																																						end
																																					end
																																				end
																																			end

																																			if not tbl20 then
																																				n10 = 0
																																				n11 = 0

																																				for _, entry in ipairs(entries) do
																																					rec3 = entry.rec

																																					if rec3.BottomCFrame then
																																						rarity2 = entry.rarity
																																						mutations2 = entry.mutations
																																						flag20 = not handlers.isCaptureEventUid(rec3.Uid) and fn53(rec3, rarity2, mutations2, entry)
																																						flag21 = flag20 and tostring(rec3.State) == "Dropped"

																																						if flag21 then
																																							n10 += 1
																																						else
																																							flag20 = flag20 and tostring(rec3.State) == "Slot" and tbl18[rec3.Uid]

																																							if flag20 then
																																								v40 = tbl18[rec3.Uid]
																																								flag20 = os.clock() <= v40
																																							end

																																							if flag20 then
																																								n11 += 1
																																							end
																																						end
																																					end
																																				end

																																				tbl15.treadmillSuppressed = false
																																				tbl14.stealWants = false
																																				tbl14.release("Steal")
																																				handlers.set("target", "🎯 Target: none")
																																				handlers.carry = "📦 Carry: none"

																																				if flag2 then
																																					fn11("🌀 Waiting for a required Rift egg")
																																				elseif flag3 then
																																					fn11("🔓 Great Bloom · waiting for Crane egg")
																																				elseif flag5 then
																																					fn11("🔓 Crane reserved · continuing unlock")
																																				else
																																					flag22 = n10 > 0 and not tbl2.PersistentSteal

																																					if flag22 then
																																						v41 = fn11
																																						str3 = "🟡 %d selected egg%s dropped · enable Persistent"
																																						format = str3.format
																																						str4 = n10 == 1 and ""
																																						str5 = str4 or "s"
																																						v41(format(str3, n10, str5))
																																					elseif n11 > 0 then
																																						v42 = fn11
																																						str6 = "🟡 %d target%s cooling down"
																																						format2 = str6.format
																																						str7 = n11 == 1 and "" or "s"
																																						v42(format2(str6, n11, str7))
																																					else
																																						fn11("🟡 Waiting for target")
																																					end
																																				end

																																				checkStealHop = not flag2 and not flag3 and not flag5 and not flag4 and n10 == 0 and n11 == 0 and handlers.checkStealHop

																																				if checkStealHop then
																																					handlers.checkStealHop()
																																				end

																																				v43 = fn18
																																				n12 = tbl2.StealServerHop and 2 or 5
																																				v43(n12)
																																				if fn() then
																																					continue
																																				end
																																			else
																																				if handlers.stealHop then
																																					handlers.stealHop.emptySince = nil
																																				end

																																				rar = tbl20.rar
																																				v44 = fn11
																																				str8 = flag2 and "🧪 Requested Lab egg locked"
																																				str9 = str8 or flag3 and "🔓 Crane egg locked" or stealHopFallback and "🟢 Best egg locked · no server matched"
																																				str10 = str9 or "🟢 Target locked"
																																				v44(str10)
																																				set = handlers.set
																																				str11 = "🎯 Target: %s %s · %.2f kg"
																																				format3 = str11.format
																																				str12 = tostring(rar._id)
																																				str13 = tostring(tbl20.rec.AssetCategory)
																																				num2 = tonumber(tbl20.weight)
																																				n13 = num2 or 0
																																				set("target", format3(str11, str12, str13, n13))
																																				directory = Assets and Assets.Directory and Assets.Directory[tostring(tbl20.rec.AssetCategory)]
																																				webhookTarget = tbl13.webhookTarget
																																				str14 = flag2 and "rift" or flag3 and "internal" or flag4 and "pet-index" or "steal-filter"
																																				flag23 = type(webhookTarget) == "table" and tostring(webhookTarget.uid) == tostring(tbl20.rec.Uid) and webhookTarget.source ~= nil

																																				if flag23 then
																																					str14 = webhookTarget.source
																																				end

																																				v45 = tbl13

																																				webhookTarget2 = {
																																					uid = tbl20.rec.Uid,
																																					source = str14,
																																				}

																																				v46 = tostring
																																				assetCategory = tbl20.rec.AssetCategory
																																				str15 = assetCategory or "Unknown"
																																				webhookTarget2.category = v46(str15)
																																				v47 = tostring
																																				id = rar._id or "Unknown"
																																				webhookTarget2.rarity = v47(id)
																																				v48 = tostring
																																				areaId = tbl20.rec.AreaId or "Unknown"
																																				webhookTarget2.area = v48(areaId)
																																				mutations3 = #tbl20.muts > 0 and table.concat(tbl20.muts, ", ") or "None"
																																				webhookTarget2.mutations = mutations3
																																				scale = tonumber(tbl20.rec.AssetScale) or 1
																																				webhookTarget2.scale = scale
																																				income = tonumber(tbl20.score) or 0
																																				webhookTarget2.income = income
																																				distance = tonumber(tbl20.dist) or 0
																																				webhookTarget2.distance = distance

																																				if directory then
																																					icon = directory.Egg and directory.Egg.Icon
																																					directory = icon or directory.Icon
																																				end

																																				webhookTarget2.icon = directory
																																				v45.webhookTarget = webhookTarget2
																																				tbl13.lockedUid = tbl20.rec.Uid
																																				flag24 = tbl2.PersistentSteal and not flag4

																																				if flag24 then
																																					tbl13.persistentUid = tbl20.rec.Uid
																																				end

																																				rec4 = tbl20.rec
																																				tbl15.treadmillSuppressed = true
																																				tbl14.stealWants = true

																																				if not tbl14.acquireWait("Steal", 4) then
																																					fn11("🟡 Waiting for pen…")
																																					task.wait(0.5)
																																					if fn() then
																																						continue
																																					end
																																				else
																																					tbl14.critical = true

																																					if not tbl14.waitPets(fn45, 4) then
																																						task.wait(0.1)
																																						if fn() then
																																							continue
																																						end
																																					elseif not tbl15.requestTreadmillExit() then
																																						v49 = tbl14
																																						tbl14.critical = false
																																						v49.stealWants = false
																																						tbl14.release("Steal")
																																						v50 = fn11
																																						str16 = tbl15.treadmillExitRequest.inFlight and "🟡 Treadmill server pending — retrying" or "🟡 Could not leave treadmill — retrying"
																																						v50(str16)
																																						task.wait(0.25)
																																						if fn() then
																																							continue
																																						end
																																					elseif not tbl15.waitForToolFree(1.5) then
																																						v51 = tbl14
																																						tbl14.critical = false
																																						v51.stealWants = true
																																						fn11("🟡 Finishing previous activity — retrying")
																																						task.wait(0.1)
																																						if fn() then
																																							continue
																																						end
																																					else
																																						riftTargetUid = not carryLossRecoveryPending() and handlers.riftCollecting == true and handlers.riftTargetUid or nil
																																						flag25 = riftTargetUid and tostring(rec4.Uid) ~= tostring(riftTargetUid)

																																						if flag25 then
																																							flag26 = flag25
																																						else
																																							v52 = flag4 and handlers.petIndexBlocked()
																																							flag26 = v52 and not carryLossRecoveryPending()
																																						end

																																						if flag26 then
																																							if tostring(tbl13.lockedUid) == tostring(rec4.Uid) then
																																								tbl13.lockedUid = nil
																																							end

																																							v53 = tbl14
																																							tbl14.critical = false
																																							v53.stealWants = false
																																							tbl14.release("Steal")
																																							fn11("🌀 Event target changed · selecting nearest")
																																							fn18(0.05)
																																							if fn() then
																																								continue
																																							end
																																						else
																																							flag27 = fn25(rec4.Uid)
																																							str17 = flag27 and tostring(flag27.State) or "Missing"
																																							flag28 = not flag27 or str17 ~= "Slot" and str17 ~= "Dropped"

																																							if flag28 then
																																								persistentSteal = tbl2.PersistentSteal
																																								flag27 = persistentSteal and flag27 and str17 ~= "Claimed"
																																								tbl14.critical = false
																																								tbl14.release("Steal")

																																								if flag27 then
																																									tbl15.treadmillSuppressed = true
																																									tbl14.stealWants = true
																																									tbl14.stealBeat = os.clock()
																																									fn11(("🔁 Persistent — target became %s"):format(str17))
																																									fn18(0.75)
																																								else
																																									if tostring(tbl13.persistentUid) == tostring(rec4.Uid) then
																																										tbl13.persistentUid = nil
																																									end

																																									if tostring(tbl13.lockedUid) == tostring(rec4.Uid) then
																																										tbl13.lockedUid = nil
																																									end

																																									tbl13.webhookTarget = nil
																																									tbl15.treadmillSuppressed = false
																																									tbl14.stealWants = false
																																									handlers.set("target", "🎯 Target: none")

																																									if handlers.candidateIndex then
																																										handlers.candidateIndex:Invalidate(rec4.Uid, "target changed while leaving treadmill")
																																									end

																																									fn11(("🟡 Target became %s — rescanning"):format(str17))
																																									fn18(0.08)
																																								end

																																								if fn() then
																																									continue
																																								end
																																							elseif localPlayer:GetAttribute("InScrambleArena") == true then
																																								fn11("Leaving Dr. Scramble's arena")
																																								handlers.leaveScrambleArena(fn45)
																																								if fn() then
																																									continue
																																								end
																																							else
																																								if tbl2.EnableDefaultSpeed then
																																									v54, str18, v55 = handlers.runDefaultSpeedSteal(flag27, fn45)
																																								else
																																									stealMovementType = tbl2.StealMovementType
																																									v54, str18, v55 = handlers.runFlySteal(flag27, fn45, stealMovementType == "Fly", stealMovementType == "Relay", stealMovementType == "Hop Fly")
																																								end

																																								if v54 then
																																									if handlers.candidateIndex then
																																										handlers.candidateIndex:Invalidate(flag27.Uid, "transaction verified")
																																									end

																																									handlers.clearCarryLossRecovery(flag27.Uid)
																																									v56 = tbl13
																																									v57 = tbl13
																																									tbl13.persistentUid = nil
																																									v56.lockedUid = nil
																																									v57.lastDroppedUid = nil
																																									v58 = tbl13
																																									tbl13.dropDetectedAt = 0
																																									v58.consecutiveFailures = 0
																																									critical = false
																																									handlers.activeGuardAreaId = nil
																																									v59 = tbl14
																																									tbl14.critical = false
																																									v59.stealWants = false
																																									tbl14.release("Steal")
																																									tbl14.wakeSeller()
																																									v60 = pcall
																																									finishStealTimer = handlers.finishStealTimer
																																									returnAt = v55.returnAt or os.clock()
																																									n14 = returnAt - v55.cycleAt
																																									now4 = os.clock()
																																									returnAt2 = v55.returnAt or os.clock()
																																									v60(finishStealTimer, n14, now4 - returnAt2)
																																									fn11("✅ Egg collected")
																																								else
																																									handlers.pauseStealTimer()
																																									v61 = tbl14
																																									tbl14.critical = false
																																									v61.stealWants = false
																																									tbl14.release("Steal")
																																									v62 = tbl13
																																									v63 = tbl13
																																									lastRequestError2 = tostring(str18)
																																									v62.lastRequestKind = "standalone"
																																									v63.lastRequestError = lastRequestError2

																																									if fn16() then
																																										fn11("⏳ Wall closed — waiting")

																																										while true do
																																											fn18(5, function()
																																												return not fn16() or not fn45()
																																											end)

																																											flag29 = not fn()
																																											flag30 = flag29 or not fn45()
																																											flag31 = flag30 or not fn16()
																																											if not flag31 then
																																												continue
																																											end
																																											break
																																										end

																																										task.wait(0.5)
																																									elseif fn45() then
																																										v64 = tostring
																																										str18 = str18 or "movement unavailable"
																																										v65 = v64(str18)
																																										v66 = tbl13
																																										min = math.min
																																										consecutiveFailures = tbl13.consecutiveFailures
																																										n15 = consecutiveFailures or 0
																																										v66.consecutiveFailures = min(n15 + 1, 6)
																																										tbl18[flag27.Uid] = os.clock() + 10
																																										n16 = math.min(2 ^ (tbl13.consecutiveFailures - 1), 30)
																																										fn11(("🔁 Retrying in %ds · %s"):format(n16, v65:sub(1, 100)))
																																										n17 = os.clock() + n16

																																										while true do
																																											flag32 = fn() and fn45() and os.clock() < n17
																																											if flag32 then
																																												task.wait(0.25)
																																												continue
																																											end
																																											break
																																										end
																																									end
																																								end

																																								if fn() then
																																									continue
																																								end
																																							end
																																						end
																																					end
																																				end
																																			end
																																		end
																																	else
																																		error("devirt: unstructured jump to block_7908") -- goto block_7908
																																	end
																																end
																															end
																														elseif not rec.BottomCFrame then
																															fn11("🔁 Waiting for egg")
																															fn18(0.5)
																															if fn() then
																																continue
																															end
																														elseif rec then
																															if handlers.getDroppedRecoveryRecord(rec.Uid) then
																																if armDroppedEggReacquire(rec.Uid, "confirmed dropped field record") then
																																	tbl18[rec.Uid] = nil
																																end
																															end

																															n4 = tonumber(tbl18[rec.Uid]) or 0

																															if os.clock() < n4 then
																																tbl15.treadmillSuppressed = true
																																tbl14.stealWants = true
																																tbl14.stealBeat = os.clock()
																																n5 = n4 - os.clock()
																																v24, v25 = fn33()
																																magnitude = v24 and rec.BottomCFrame and ((v24.Position - rec.BottomCFrame.Position) * Vector3.new(1, 0, 1)).Magnitude or math.huge
																																v26 = tostring
																																lastRequestKind = tbl13.lastRequestKind or ""
																																v27 = v26(lastRequestKind)
																																lower = string.lower
																																v28 = tostring
																																lastRequestError = tbl13.lastRequestError or ""
																																v29 = lower(v28(lastRequestError))
																																flag6 = v27 == "movement-trust"
																																flag7 = flag6 or v27 == "position-sync"
																																flag8 = flag7 or v27 == "activity-sync"
																																flag9 = flag8 or v27 == "movement-retry" or v27 == "server" or v27 == "retry" or v27 == "carry-loss-sync"
																																flag10 = flag9 or v27 == "death-drop-sync" or v27 == "carry-drop"
																																flag11 = handlers.activeDroppedRecoveryRecord(rec.Uid) ~= nil
																																v30 = v24 and v25
																																flag12 = v30 and v25.Health > 0 and tostring(tbl13.requestFailureUid) == tostring(rec.Uid)
																																flag13 = flag12 and tostring(tbl13.lockedUid) == tostring(rec.Uid)
																																flag10 = flag13 and flag10 and not v29:find("inventory is full", 1, true) and not v29:find("gameplay area", 1, true)

																																if flag10 then
																																	if flag11 then
																																		flag10 = flag11
																																	else
																																		now3 = os.clock()
																																		num = tonumber(tbl13.requestFailureAt)
																																		n6 = num or 0
																																		flag10 = now3 - n6 <= 6
																																	end
																																end

																																if flag10 then
																																	if flag11 then
																																		flag10 = flag11
																																	else
																																		n7 = fn35(v24.Position) or -1
																																		flag10 = n7 > 0
																																	end
																																end

																																if flag10 then
																																	tbl14.critical = true

																																	if tbl14.owner ~= "Steal" then
																																		tbl14.acquireWait("Steal", 0.1)
																																	end

																																	v31 = handlers
																																	retryResumeMode = magnitude <= 8 and "beside-egg" or "current-position"
																																	v31.retryResumeMode = retryResumeMode
																																	handlers.retryResumeDistance = magnitude
																																	handlers.retryResumeUid = rec.Uid
																																	v32 = fn11
																																	str2 = v27 == "movement-retry" and "⚡ Movement interrupted · resuming" or magnitude <= 8 and "🥚 Retrying carry…" or "🔁 Resuming carry target…"
																																	v32(str2)
																																else
																																	tbl14.critical = false
																																	tbl14.release("Steal")
																																	fn11("🟡 Target retry pending")
																																end

																																task.wait(math.min(0.2, math.max(0.03, n5)))
																																if fn() then
																																	continue
																																end
																															else
																																magnitude2 = fn33()

																																if rec then
																																	v33 = fn30(rec)

																																	tbl19 = v33 or {
																																		_id = "Target",
																																		RarityNumber = 0,
																																	}

																																	tbl20 = {
																																		rec = rec,
																																		rar = tbl19,
																																		muts = fn22(rec),
																																	}

																																	magnitude2 = magnitude2 and ((magnitude2.Position - rec.BottomCFrame.Position) * Vector3.new(1, 0, 1)).Magnitude or 0
																																	tbl20.dist = magnitude2
																																	tbl20.score = riftValueScore(rec)
																																	weight = fn23(rec) or 0
																																	tbl20.weight = weight
																																	v34 = tonumber
																																	rarityNumber = tbl19.RarityNumber
																																	rank = rarityNumber or tbl19.Rank
																																	rarNum = v34(rank) or 0
																																	tbl20.rarNum = rarNum
																																else
																																	v35, v36, v37 = ipairs(entries)
																																	v38 = v35
																																	n8 = 0
																																	n9 = 0
																																	tbl20 = nil

																																	for _, v75 in v38, v36, v37 do
																																		rec2 = v75.rec
																																		n8 += 1
																																		flag14 = tostring(rec2.State) == "Slot" and rec2.BottomCFrame and not handlers.isCaptureEventUid(rec2.Uid) and not handlers.deliveryRejected(rec2.Uid)

																																		if flag14 then
																																			flag15 = not tbl18[rec2.Uid]

																																			if flag15 then
																																				flag16 = flag15
																																			else
																																				v39 = tbl18[rec2.Uid]
																																				flag16 = os.clock() > v39
																																			end
																																		else
																																			flag16 = flag14
																																		end

																																		if flag16 then
																																			rarity = v75.rarity
																																			mutations = v75.mutations

																																			if fn53(rec2, rarity, mutations, v75) then
																																				n9 += 1

																																				tbl21 = {
																																					rec = rec2,
																																					rar = rarity,
																																					muts = mutations,
																																				}

																																				magnitude3 = magnitude2 and ((magnitude2.Position - rec2.BottomCFrame.Position) * Vector3.new(1, 0, 1)).Magnitude
																																				dist = magnitude3 or 0
																																				tbl21.dist = dist
																																				tbl21.score = v75.value
																																				tbl21.weight = v75.weight
																																				tbl21.rarNum = v75.rarityNumber

																																				if not tbl20 then
																																					flag17 = true
																																				elseif flag3 then
																																					flag18 = tbl21.score < tbl20.score

																																					if flag18 then
																																						flag17 = flag18
																																					else
																																						flag19 = tbl21.score == tbl20.score
																																						flag17 = flag19 and tbl21.weight < tbl20.weight
																																					end

																																					flag17 = flag17 or tbl21.score == tbl20.score and tbl21.weight == tbl20.weight and tbl21.dist < tbl20.dist
																																				elseif targetPriority == "Value" then
																																					flag17 = tbl21.score > tbl20.score or tbl21.score == tbl20.score and tbl21.dist < tbl20.dist
																																				elseif targetPriority == "Rarity" then
																																					flag17 = tbl21.rarNum > tbl20.rarNum or tbl21.rarNum == tbl20.rarNum and tbl21.score > tbl20.score or tbl21.rarNum == tbl20.rarNum and tbl21.score == tbl20.score and tbl21.dist < tbl20.dist
																																				elseif targetPriority == "Weight" then
																																					flag17 = tbl21.weight > tbl20.weight or tbl21.weight == tbl20.weight and tbl21.rarNum > tbl20.rarNum or tbl21.weight == tbl20.weight and tbl21.rarNum == tbl20.rarNum and tbl21.score > tbl20.score or tbl21.weight == tbl20.weight and tbl21.rarNum == tbl20.rarNum and tbl21.score == tbl20.score and tbl21.dist < tbl20.dist
																																				elseif targetPriority == "Farthest" then
																																					flag17 = tbl21.dist > tbl20.dist or tbl21.dist == tbl20.dist and tbl21.score > tbl20.score
																																				else
																																					flag17 = tbl21.dist < tbl20.dist or tbl21.dist == tbl20.dist and tbl21.score > tbl20.score
																																				end

																																				if flag17 then
																																					tbl20 = tbl21
																																				end
																																			end
																																		end
																																	end
																																end

																																if not tbl20 then
																																	n10 = 0
																																	n11 = 0

																																	for _, entry in ipairs(entries) do
																																		rec3 = entry.rec

																																		if rec3.BottomCFrame then
																																			rarity2 = entry.rarity
																																			mutations2 = entry.mutations
																																			flag20 = not handlers.isCaptureEventUid(rec3.Uid) and fn53(rec3, rarity2, mutations2, entry)
																																			flag21 = flag20 and tostring(rec3.State) == "Dropped"

																																			if flag21 then
																																				n10 += 1
																																			else
																																				flag20 = flag20 and tostring(rec3.State) == "Slot" and tbl18[rec3.Uid]

																																				if flag20 then
																																					v40 = tbl18[rec3.Uid]
																																					flag20 = os.clock() <= v40
																																				end

																																				if flag20 then
																																					n11 += 1
																																				end
																																			end
																																		end
																																	end

																																	tbl15.treadmillSuppressed = false
																																	tbl14.stealWants = false
																																	tbl14.release("Steal")
																																	handlers.set("target", "🎯 Target: none")
																																	handlers.carry = "📦 Carry: none"

																																	if flag2 then
																																		fn11("🌀 Waiting for a required Rift egg")
																																	elseif flag3 then
																																		fn11("🔓 Great Bloom · waiting for Crane egg")
																																	elseif flag5 then
																																		fn11("🔓 Crane reserved · continuing unlock")
																																	else
																																		flag22 = n10 > 0 and not tbl2.PersistentSteal

																																		if flag22 then
																																			v41 = fn11
																																			str3 = "🟡 %d selected egg%s dropped · enable Persistent"
																																			format = str3.format
																																			str4 = n10 == 1 and ""
																																			str5 = str4 or "s"
																																			v41(format(str3, n10, str5))
																																		elseif n11 > 0 then
																																			v42 = fn11
																																			str6 = "🟡 %d target%s cooling down"
																																			format2 = str6.format
																																			str7 = n11 == 1 and "" or "s"
																																			v42(format2(str6, n11, str7))
																																		else
																																			fn11("🟡 Waiting for target")
																																		end
																																	end

																																	checkStealHop = not flag2 and not flag3 and not flag5 and not flag4 and n10 == 0 and n11 == 0 and handlers.checkStealHop

																																	if checkStealHop then
																																		handlers.checkStealHop()
																																	end

																																	v43 = fn18
																																	n12 = tbl2.StealServerHop and 2 or 5
																																	v43(n12)
																																	if fn() then
																																		continue
																																	end
																																else
																																	if handlers.stealHop then
																																		handlers.stealHop.emptySince = nil
																																	end

																																	rar = tbl20.rar
																																	v44 = fn11
																																	str8 = flag2 and "🧪 Requested Lab egg locked"
																																	str9 = str8 or flag3 and "🔓 Crane egg locked" or stealHopFallback and "🟢 Best egg locked · no server matched"
																																	str10 = str9 or "🟢 Target locked"
																																	v44(str10)
																																	set = handlers.set
																																	str11 = "🎯 Target: %s %s · %.2f kg"
																																	format3 = str11.format
																																	str12 = tostring(rar._id)
																																	str13 = tostring(tbl20.rec.AssetCategory)
																																	num2 = tonumber(tbl20.weight)
																																	n13 = num2 or 0
																																	set("target", format3(str11, str12, str13, n13))
																																	directory = Assets and Assets.Directory and Assets.Directory[tostring(tbl20.rec.AssetCategory)]
																																	webhookTarget = tbl13.webhookTarget
																																	str14 = flag2 and "rift" or flag3 and "internal" or flag4 and "pet-index" or "steal-filter"
																																	flag23 = type(webhookTarget) == "table" and tostring(webhookTarget.uid) == tostring(tbl20.rec.Uid) and webhookTarget.source ~= nil

																																	if flag23 then
																																		str14 = webhookTarget.source
																																	end

																																	v45 = tbl13

																																	webhookTarget2 = {
																																		uid = tbl20.rec.Uid,
																																		source = str14,
																																	}

																																	v46 = tostring
																																	assetCategory = tbl20.rec.AssetCategory
																																	str15 = assetCategory or "Unknown"
																																	webhookTarget2.category = v46(str15)
																																	v47 = tostring
																																	id = rar._id or "Unknown"
																																	webhookTarget2.rarity = v47(id)
																																	v48 = tostring
																																	areaId = tbl20.rec.AreaId or "Unknown"
																																	webhookTarget2.area = v48(areaId)
																																	mutations3 = #tbl20.muts > 0 and table.concat(tbl20.muts, ", ") or "None"
																																	webhookTarget2.mutations = mutations3
																																	scale = tonumber(tbl20.rec.AssetScale) or 1
																																	webhookTarget2.scale = scale
																																	income = tonumber(tbl20.score) or 0
																																	webhookTarget2.income = income
																																	distance = tonumber(tbl20.dist) or 0
																																	webhookTarget2.distance = distance

																																	if directory then
																																		icon = directory.Egg and directory.Egg.Icon
																																		directory = icon or directory.Icon
																																	end

																																	webhookTarget2.icon = directory
																																	v45.webhookTarget = webhookTarget2
																																	tbl13.lockedUid = tbl20.rec.Uid
																																	flag24 = tbl2.PersistentSteal and not flag4

																																	if flag24 then
																																		tbl13.persistentUid = tbl20.rec.Uid
																																	end

																																	rec4 = tbl20.rec
																																	tbl15.treadmillSuppressed = true
																																	tbl14.stealWants = true

																																	if not tbl14.acquireWait("Steal", 4) then
																																		fn11("🟡 Waiting for pen…")
																																		task.wait(0.5)
																																		if fn() then
																																			continue
																																		end
																																	else
																																		tbl14.critical = true

																																		if not tbl14.waitPets(fn45, 4) then
																																			task.wait(0.1)
																																			if fn() then
																																				continue
																																			end
																																		elseif not tbl15.requestTreadmillExit() then
																																			v49 = tbl14
																																			tbl14.critical = false
																																			v49.stealWants = false
																																			tbl14.release("Steal")
																																			v50 = fn11
																																			str16 = tbl15.treadmillExitRequest.inFlight and "🟡 Treadmill server pending — retrying" or "🟡 Could not leave treadmill — retrying"
																																			v50(str16)
																																			task.wait(0.25)
																																			if fn() then
																																				continue
																																			end
																																		elseif not tbl15.waitForToolFree(1.5) then
																																			v51 = tbl14
																																			tbl14.critical = false
																																			v51.stealWants = true
																																			fn11("🟡 Finishing previous activity — retrying")
																																			task.wait(0.1)
																																			if fn() then
																																				continue
																																			end
																																		else
																																			riftTargetUid = not carryLossRecoveryPending() and handlers.riftCollecting == true and handlers.riftTargetUid or nil
																																			flag25 = riftTargetUid and tostring(rec4.Uid) ~= tostring(riftTargetUid)

																																			if flag25 then
																																				flag26 = flag25
																																			else
																																				v52 = flag4 and handlers.petIndexBlocked()
																																				flag26 = v52 and not carryLossRecoveryPending()
																																			end

																																			if flag26 then
																																				if tostring(tbl13.lockedUid) == tostring(rec4.Uid) then
																																					tbl13.lockedUid = nil
																																				end

																																				v53 = tbl14
																																				tbl14.critical = false
																																				v53.stealWants = false
																																				tbl14.release("Steal")
																																				fn11("🌀 Event target changed · selecting nearest")
																																				fn18(0.05)
																																				if fn() then
																																					continue
																																				end
																																			else
																																				flag27 = fn25(rec4.Uid)
																																				str17 = flag27 and tostring(flag27.State) or "Missing"
																																				flag28 = not flag27 or str17 ~= "Slot" and str17 ~= "Dropped"

																																				if flag28 then
																																					persistentSteal = tbl2.PersistentSteal
																																					flag27 = persistentSteal and flag27 and str17 ~= "Claimed"
																																					tbl14.critical = false
																																					tbl14.release("Steal")

																																					if flag27 then
																																						tbl15.treadmillSuppressed = true
																																						tbl14.stealWants = true
																																						tbl14.stealBeat = os.clock()
																																						fn11(("🔁 Persistent — target became %s"):format(str17))
																																						fn18(0.75)
																																					else
																																						if tostring(tbl13.persistentUid) == tostring(rec4.Uid) then
																																							tbl13.persistentUid = nil
																																						end

																																						if tostring(tbl13.lockedUid) == tostring(rec4.Uid) then
																																							tbl13.lockedUid = nil
																																						end

																																						tbl13.webhookTarget = nil
																																						tbl15.treadmillSuppressed = false
																																						tbl14.stealWants = false
																																						handlers.set("target", "🎯 Target: none")

																																						if handlers.candidateIndex then
																																							handlers.candidateIndex:Invalidate(rec4.Uid, "target changed while leaving treadmill")
																																						end

																																						fn11(("🟡 Target became %s — rescanning"):format(str17))
																																						fn18(0.08)
																																					end

																																					if fn() then
																																						continue
																																					end
																																				elseif localPlayer:GetAttribute("InScrambleArena") == true then
																																					fn11("Leaving Dr. Scramble's arena")
																																					handlers.leaveScrambleArena(fn45)
																																					if fn() then
																																						continue
																																					end
																																				else
																																					if tbl2.EnableDefaultSpeed then
																																						v54, str18, v55 = handlers.runDefaultSpeedSteal(flag27, fn45)
																																					else
																																						stealMovementType = tbl2.StealMovementType
																																						v54, str18, v55 = handlers.runFlySteal(flag27, fn45, stealMovementType == "Fly", stealMovementType == "Relay", stealMovementType == "Hop Fly")
																																					end

																																					if v54 then
																																						if handlers.candidateIndex then
																																							handlers.candidateIndex:Invalidate(flag27.Uid, "transaction verified")
																																						end

																																						handlers.clearCarryLossRecovery(flag27.Uid)
																																						v56 = tbl13
																																						v57 = tbl13
																																						tbl13.persistentUid = nil
																																						v56.lockedUid = nil
																																						v57.lastDroppedUid = nil
																																						v58 = tbl13
																																						tbl13.dropDetectedAt = 0
																																						v58.consecutiveFailures = 0
																																						critical = false
																																						handlers.activeGuardAreaId = nil
																																						v59 = tbl14
																																						tbl14.critical = false
																																						v59.stealWants = false
																																						tbl14.release("Steal")
																																						tbl14.wakeSeller()
																																						v60 = pcall
																																						finishStealTimer = handlers.finishStealTimer
																																						returnAt = v55.returnAt or os.clock()
																																						n14 = returnAt - v55.cycleAt
																																						now4 = os.clock()
																																						returnAt2 = v55.returnAt or os.clock()
																																						v60(finishStealTimer, n14, now4 - returnAt2)
																																						fn11("✅ Egg collected")
																																					else
																																						handlers.pauseStealTimer()
																																						v61 = tbl14
																																						tbl14.critical = false
																																						v61.stealWants = false
																																						tbl14.release("Steal")
																																						v62 = tbl13
																																						v63 = tbl13
																																						lastRequestError2 = tostring(str18)
																																						v62.lastRequestKind = "standalone"
																																						v63.lastRequestError = lastRequestError2

																																						if fn16() then
																																							fn11("⏳ Wall closed — waiting")

																																							while true do
																																								fn18(5, function()
																																									return not fn16() or not fn45()
																																								end)

																																								flag29 = not fn()
																																								flag30 = flag29 or not fn45()
																																								flag31 = flag30 or not fn16()
																																								if not flag31 then
																																									continue
																																								end
																																								break
																																							end

																																							task.wait(0.5)
																																						elseif fn45() then
																																							v64 = tostring
																																							str18 = str18 or "movement unavailable"
																																							v65 = v64(str18)
																																							v66 = tbl13
																																							min = math.min
																																							consecutiveFailures = tbl13.consecutiveFailures
																																							n15 = consecutiveFailures or 0
																																							v66.consecutiveFailures = min(n15 + 1, 6)
																																							tbl18[flag27.Uid] = os.clock() + 10
																																							n16 = math.min(2 ^ (tbl13.consecutiveFailures - 1), 30)
																																							fn11(("🔁 Retrying in %ds · %s"):format(n16, v65:sub(1, 100)))
																																							n17 = os.clock() + n16

																																							while true do
																																								flag32 = fn() and fn45() and os.clock() < n17
																																								if flag32 then
																																									task.wait(0.25)
																																									continue
																																								end
																																								break
																																							end
																																						end
																																					end

																																					if fn() then
																																						continue
																																					end
																																				end
																																			end
																																		end
																																	end
																																end
																															end
																														else
																															error("devirt: unstructured jump to block_7908") -- goto block_7908
																														end
																													end
																												end
																											else
																												flag46 = not rec or tostring(rec.State) == "Claimed"

																												if flag46 then
																													flag47 = not rec and not flag44 and tostring(tbl13.recentPositiveCarryUid()) == tostring(persistentUid) and (str == "carry-loss-sync" or str == "carry-drop")

																													if tostring(handlers.riftTargetUid) == tostring(persistentUid) then
																														handlers.riftTargetUid = nil
																													end

																													if tostring(tbl13.persistentUid) == tostring(persistentUid) then
																														tbl13.persistentUid = nil
																													end

																													if tostring(tbl13.lockedUid) == tostring(persistentUid) then
																														tbl13.lockedUid = nil
																													end

																													if type(handlers.clearCarryLossRecovery) == "function" then
																														handlers.clearCarryLossRecovery(persistentUid, flag47)
																													end

																													handlers.set("target", "🎯 Target: none")
																													rec = nil
																													error("devirt: unstructured jump to block_8615") -- goto block_8615
																												else
																													flag48 = tostring(rec.State) ~= "Slot" and tostring(rec.State) ~= "Dropped"

																													if flag48 then
																														flag49 = tostring(tbl13.lastDroppedUid) == tostring(persistentUid) and (str == "carry-loss-sync" or str == "death-drop-sync" or str == "carry-drop")
																														num4 = tonumber(rec.CarrierUserId)
																														flag50 = num4 ~= nil and num4 > 0 and num4 ~= localPlayer.UserId
																														flag51 = flag49 and not flag50

																														if flag51 then
																															exitTo = 17
																															break
																														else
																															flag52 = tbl2.PersistentSteal and tostring(tbl13.persistentUid) == tostring(persistentUid)

																															if flag52 then
																																exitTo = 18
																																break
																															else
																																tbl13.lockedUid = nil
																																flag49 = flag49 and type(handlers.clearCarryLossRecovery) == "function"

																																if flag49 then
																																	handlers.clearCarryLossRecovery(persistentUid)
																																end

																																rec = nil
																																error("devirt: unstructured jump to block_8530") -- goto block_8530
																															end
																														end
																													elseif not rec.BottomCFrame then
																														exitTo = 15
																														break
																													elseif rec then
																														if handlers.getDroppedRecoveryRecord(rec.Uid) then
																															if armDroppedEggReacquire(rec.Uid, "confirmed dropped field record") then
																																tbl18[rec.Uid] = nil
																															end
																														end

																														n4 = tonumber(tbl18[rec.Uid]) or 0

																														if os.clock() < n4 then
																															exitTo = 16
																															break
																														else
																															magnitude2 = fn33()

																															if rec then
																																v33 = fn30(rec)

																																tbl19 = v33 or {
																																	_id = "Target",
																																	RarityNumber = 0,
																																}

																																tbl20 = {
																																	rec = rec,
																																	rar = tbl19,
																																	muts = fn22(rec),
																																}

																																magnitude2 = magnitude2 and ((magnitude2.Position - rec.BottomCFrame.Position) * Vector3.new(1, 0, 1)).Magnitude or 0
																																tbl20.dist = magnitude2
																																tbl20.score = riftValueScore(rec)
																																weight = fn23(rec) or 0
																																tbl20.weight = weight
																																v34 = tonumber
																																rarityNumber = tbl19.RarityNumber
																																rank = rarityNumber or tbl19.Rank
																																rarNum = v34(rank) or 0
																																tbl20.rarNum = rarNum
																															else
																																v35, v36, v37 = ipairs(entries)
																																v38 = v35
																																n8 = 0
																																n9 = 0
																																tbl20 = nil

																																for _, v75 in v38, v36, v37 do
																																	rec2 = v75.rec
																																	n8 += 1
																																	flag14 = tostring(rec2.State) == "Slot" and rec2.BottomCFrame and not handlers.isCaptureEventUid(rec2.Uid) and not handlers.deliveryRejected(rec2.Uid)

																																	if flag14 then
																																		flag15 = not tbl18[rec2.Uid]

																																		if flag15 then
																																			flag16 = flag15
																																		else
																																			v39 = tbl18[rec2.Uid]
																																			flag16 = os.clock() > v39
																																		end
																																	else
																																		flag16 = flag14
																																	end

																																	if flag16 then
																																		rarity = v75.rarity
																																		mutations = v75.mutations

																																		if fn53(rec2, rarity, mutations, v75) then
																																			n9 += 1

																																			tbl21 = {
																																				rec = rec2,
																																				rar = rarity,
																																				muts = mutations,
																																			}

																																			magnitude3 = magnitude2 and ((magnitude2.Position - rec2.BottomCFrame.Position) * Vector3.new(1, 0, 1)).Magnitude
																																			dist = magnitude3 or 0
																																			tbl21.dist = dist
																																			tbl21.score = v75.value
																																			tbl21.weight = v75.weight
																																			tbl21.rarNum = v75.rarityNumber

																																			if not tbl20 then
																																				flag17 = true
																																			elseif flag3 then
																																				flag18 = tbl21.score < tbl20.score

																																				if flag18 then
																																					flag17 = flag18
																																				else
																																					flag19 = tbl21.score == tbl20.score
																																					flag17 = flag19 and tbl21.weight < tbl20.weight
																																				end

																																				flag17 = flag17 or tbl21.score == tbl20.score and tbl21.weight == tbl20.weight and tbl21.dist < tbl20.dist
																																			elseif targetPriority == "Value" then
																																				flag17 = tbl21.score > tbl20.score or tbl21.score == tbl20.score and tbl21.dist < tbl20.dist
																																			elseif targetPriority == "Rarity" then
																																				flag17 = tbl21.rarNum > tbl20.rarNum or tbl21.rarNum == tbl20.rarNum and tbl21.score > tbl20.score or tbl21.rarNum == tbl20.rarNum and tbl21.score == tbl20.score and tbl21.dist < tbl20.dist
																																			elseif targetPriority == "Weight" then
																																				flag17 = tbl21.weight > tbl20.weight or tbl21.weight == tbl20.weight and tbl21.rarNum > tbl20.rarNum or tbl21.weight == tbl20.weight and tbl21.rarNum == tbl20.rarNum and tbl21.score > tbl20.score or tbl21.weight == tbl20.weight and tbl21.rarNum == tbl20.rarNum and tbl21.score == tbl20.score and tbl21.dist < tbl20.dist
																																			elseif targetPriority == "Farthest" then
																																				flag17 = tbl21.dist > tbl20.dist or tbl21.dist == tbl20.dist and tbl21.score > tbl20.score
																																			else
																																				flag17 = tbl21.dist < tbl20.dist or tbl21.dist == tbl20.dist and tbl21.score > tbl20.score
																																			end

																																			if flag17 then
																																				tbl20 = tbl21
																																			end
																																		end
																																	end
																																end
																															end

																															if not tbl20 then
																																n10 = 0
																																n11 = 0

																																for _, entry in ipairs(entries) do
																																	rec3 = entry.rec

																																	if rec3.BottomCFrame then
																																		rarity2 = entry.rarity
																																		mutations2 = entry.mutations
																																		flag20 = not handlers.isCaptureEventUid(rec3.Uid) and fn53(rec3, rarity2, mutations2, entry)
																																		flag21 = flag20 and tostring(rec3.State) == "Dropped"

																																		if flag21 then
																																			n10 += 1
																																		else
																																			flag20 = flag20 and tostring(rec3.State) == "Slot" and tbl18[rec3.Uid]

																																			if flag20 then
																																				v40 = tbl18[rec3.Uid]
																																				flag20 = os.clock() <= v40
																																			end

																																			if flag20 then
																																				n11 += 1
																																			end
																																		end
																																	end
																																end

																																tbl15.treadmillSuppressed = false
																																tbl14.stealWants = false
																																tbl14.release("Steal")
																																handlers.set("target", "🎯 Target: none")
																																handlers.carry = "📦 Carry: none"

																																if flag2 then
																																	fn11("🌀 Waiting for a required Rift egg")
																																elseif flag3 then
																																	fn11("🔓 Great Bloom · waiting for Crane egg")
																																elseif flag5 then
																																	fn11("🔓 Crane reserved · continuing unlock")
																																else
																																	flag22 = n10 > 0 and not tbl2.PersistentSteal

																																	if flag22 then
																																		v41 = fn11
																																		str3 = "🟡 %d selected egg%s dropped · enable Persistent"
																																		format = str3.format
																																		str4 = n10 == 1 and ""
																																		str5 = str4 or "s"
																																		v41(format(str3, n10, str5))
																																	elseif n11 > 0 then
																																		v42 = fn11
																																		str6 = "🟡 %d target%s cooling down"
																																		format2 = str6.format
																																		str7 = n11 == 1 and "" or "s"
																																		v42(format2(str6, n11, str7))
																																	else
																																		fn11("🟡 Waiting for target")
																																	end
																																end

																																checkStealHop = not flag2 and not flag3 and not flag5 and not flag4 and n10 == 0 and n11 == 0 and handlers.checkStealHop

																																if checkStealHop then
																																	handlers.checkStealHop()
																																end

																																v43 = fn18
																																n12 = tbl2.StealServerHop and 2 or 5
																																v43(n12)
																																if fn() then
																																	continue
																																end
																															else
																																if handlers.stealHop then
																																	handlers.stealHop.emptySince = nil
																																end

																																rar = tbl20.rar
																																v44 = fn11
																																str8 = flag2 and "🧪 Requested Lab egg locked"
																																str9 = str8 or flag3 and "🔓 Crane egg locked" or stealHopFallback and "🟢 Best egg locked · no server matched"
																																str10 = str9 or "🟢 Target locked"
																																v44(str10)
																																set = handlers.set
																																str11 = "🎯 Target: %s %s · %.2f kg"
																																format3 = str11.format
																																str12 = tostring(rar._id)
																																str13 = tostring(tbl20.rec.AssetCategory)
																																num2 = tonumber(tbl20.weight)
																																n13 = num2 or 0
																																set("target", format3(str11, str12, str13, n13))
																																directory = Assets and Assets.Directory and Assets.Directory[tostring(tbl20.rec.AssetCategory)]
																																webhookTarget = tbl13.webhookTarget
																																str14 = flag2 and "rift" or flag3 and "internal" or flag4 and "pet-index" or "steal-filter"
																																flag23 = type(webhookTarget) == "table" and tostring(webhookTarget.uid) == tostring(tbl20.rec.Uid) and webhookTarget.source ~= nil

																																if flag23 then
																																	str14 = webhookTarget.source
																																end

																																v45 = tbl13

																																webhookTarget2 = {
																																	uid = tbl20.rec.Uid,
																																	source = str14,
																																}

																																v46 = tostring
																																assetCategory = tbl20.rec.AssetCategory
																																str15 = assetCategory or "Unknown"
																																webhookTarget2.category = v46(str15)
																																v47 = tostring
																																id = rar._id or "Unknown"
																																webhookTarget2.rarity = v47(id)
																																v48 = tostring
																																areaId = tbl20.rec.AreaId or "Unknown"
																																webhookTarget2.area = v48(areaId)
																																mutations3 = #tbl20.muts > 0 and table.concat(tbl20.muts, ", ") or "None"
																																webhookTarget2.mutations = mutations3
																																scale = tonumber(tbl20.rec.AssetScale) or 1
																																webhookTarget2.scale = scale
																																income = tonumber(tbl20.score) or 0
																																webhookTarget2.income = income
																																distance = tonumber(tbl20.dist) or 0
																																webhookTarget2.distance = distance

																																if directory then
																																	icon = directory.Egg and directory.Egg.Icon
																																	directory = icon or directory.Icon
																																end

																																webhookTarget2.icon = directory
																																v45.webhookTarget = webhookTarget2
																																tbl13.lockedUid = tbl20.rec.Uid
																																flag24 = tbl2.PersistentSteal and not flag4

																																if flag24 then
																																	tbl13.persistentUid = tbl20.rec.Uid
																																end

																																rec4 = tbl20.rec
																																tbl15.treadmillSuppressed = true
																																tbl14.stealWants = true

																																if not tbl14.acquireWait("Steal", 4) then
																																	fn11("🟡 Waiting for pen…")
																																	task.wait(0.5)
																																	if fn() then
																																		continue
																																	end
																																else
																																	tbl14.critical = true

																																	if not tbl14.waitPets(fn45, 4) then
																																		task.wait(0.1)
																																		if fn() then
																																			continue
																																		end
																																	elseif not tbl15.requestTreadmillExit() then
																																		v49 = tbl14
																																		tbl14.critical = false
																																		v49.stealWants = false
																																		tbl14.release("Steal")
																																		v50 = fn11
																																		str16 = tbl15.treadmillExitRequest.inFlight and "🟡 Treadmill server pending — retrying" or "🟡 Could not leave treadmill — retrying"
																																		v50(str16)
																																		task.wait(0.25)
																																		if fn() then
																																			continue
																																		end
																																	elseif not tbl15.waitForToolFree(1.5) then
																																		v51 = tbl14
																																		tbl14.critical = false
																																		v51.stealWants = true
																																		fn11("🟡 Finishing previous activity — retrying")
																																		task.wait(0.1)
																																		if fn() then
																																			continue
																																		end
																																	else
																																		riftTargetUid = not carryLossRecoveryPending() and handlers.riftCollecting == true and handlers.riftTargetUid or nil
																																		flag25 = riftTargetUid and tostring(rec4.Uid) ~= tostring(riftTargetUid)

																																		if flag25 then
																																			flag26 = flag25
																																		else
																																			v52 = flag4 and handlers.petIndexBlocked()
																																			flag26 = v52 and not carryLossRecoveryPending()
																																		end

																																		if flag26 then
																																			if tostring(tbl13.lockedUid) == tostring(rec4.Uid) then
																																				tbl13.lockedUid = nil
																																			end

																																			v53 = tbl14
																																			tbl14.critical = false
																																			v53.stealWants = false
																																			tbl14.release("Steal")
																																			fn11("🌀 Event target changed · selecting nearest")
																																			fn18(0.05)
																																			if fn() then
																																				continue
																																			end
																																		else
																																			flag27 = fn25(rec4.Uid)
																																			str17 = flag27 and tostring(flag27.State) or "Missing"
																																			flag28 = not flag27 or str17 ~= "Slot" and str17 ~= "Dropped"

																																			if flag28 then
																																				persistentSteal = tbl2.PersistentSteal
																																				flag27 = persistentSteal and flag27 and str17 ~= "Claimed"
																																				tbl14.critical = false
																																				tbl14.release("Steal")

																																				if flag27 then
																																					tbl15.treadmillSuppressed = true
																																					tbl14.stealWants = true
																																					tbl14.stealBeat = os.clock()
																																					fn11(("🔁 Persistent — target became %s"):format(str17))
																																					fn18(0.75)
																																				else
																																					if tostring(tbl13.persistentUid) == tostring(rec4.Uid) then
																																						tbl13.persistentUid = nil
																																					end

																																					if tostring(tbl13.lockedUid) == tostring(rec4.Uid) then
																																						tbl13.lockedUid = nil
																																					end

																																					tbl13.webhookTarget = nil
																																					tbl15.treadmillSuppressed = false
																																					tbl14.stealWants = false
																																					handlers.set("target", "🎯 Target: none")

																																					if handlers.candidateIndex then
																																						handlers.candidateIndex:Invalidate(rec4.Uid, "target changed while leaving treadmill")
																																					end

																																					fn11(("🟡 Target became %s — rescanning"):format(str17))
																																					fn18(0.08)
																																				end

																																				if fn() then
																																					continue
																																				end
																																			elseif localPlayer:GetAttribute("InScrambleArena") == true then
																																				fn11("Leaving Dr. Scramble's arena")
																																				handlers.leaveScrambleArena(fn45)
																																				if fn() then
																																					continue
																																				end
																																			else
																																				if tbl2.EnableDefaultSpeed then
																																					v54, str18, v55 = handlers.runDefaultSpeedSteal(flag27, fn45)
																																				else
																																					stealMovementType = tbl2.StealMovementType
																																					v54, str18, v55 = handlers.runFlySteal(flag27, fn45, stealMovementType == "Fly", stealMovementType == "Relay", stealMovementType == "Hop Fly")
																																				end

																																				if v54 then
																																					if handlers.candidateIndex then
																																						handlers.candidateIndex:Invalidate(flag27.Uid, "transaction verified")
																																					end

																																					handlers.clearCarryLossRecovery(flag27.Uid)
																																					v56 = tbl13
																																					v57 = tbl13
																																					tbl13.persistentUid = nil
																																					v56.lockedUid = nil
																																					v57.lastDroppedUid = nil
																																					v58 = tbl13
																																					tbl13.dropDetectedAt = 0
																																					v58.consecutiveFailures = 0
																																					critical = false
																																					handlers.activeGuardAreaId = nil
																																					v59 = tbl14
																																					tbl14.critical = false
																																					v59.stealWants = false
																																					tbl14.release("Steal")
																																					tbl14.wakeSeller()
																																					v60 = pcall
																																					finishStealTimer = handlers.finishStealTimer
																																					returnAt = v55.returnAt or os.clock()
																																					n14 = returnAt - v55.cycleAt
																																					now4 = os.clock()
																																					returnAt2 = v55.returnAt or os.clock()
																																					v60(finishStealTimer, n14, now4 - returnAt2)
																																					fn11("✅ Egg collected")
																																				else
																																					handlers.pauseStealTimer()
																																					v61 = tbl14
																																					tbl14.critical = false
																																					v61.stealWants = false
																																					tbl14.release("Steal")
																																					v62 = tbl13
																																					v63 = tbl13
																																					lastRequestError2 = tostring(str18)
																																					v62.lastRequestKind = "standalone"
																																					v63.lastRequestError = lastRequestError2

																																					if fn16() then
																																						fn11("⏳ Wall closed — waiting")

																																						while true do
																																							fn18(5, function()
																																								return not fn16() or not fn45()
																																							end)

																																							flag29 = not fn()
																																							flag30 = flag29 or not fn45()
																																							flag31 = flag30 or not fn16()
																																							if not flag31 then
																																								continue
																																							end
																																							break
																																						end

																																						task.wait(0.5)
																																					elseif fn45() then
																																						v64 = tostring
																																						str18 = str18 or "movement unavailable"
																																						v65 = v64(str18)
																																						v66 = tbl13
																																						min = math.min
																																						consecutiveFailures = tbl13.consecutiveFailures
																																						n15 = consecutiveFailures or 0
																																						v66.consecutiveFailures = min(n15 + 1, 6)
																																						tbl18[flag27.Uid] = os.clock() + 10
																																						n16 = math.min(2 ^ (tbl13.consecutiveFailures - 1), 30)
																																						fn11(("🔁 Retrying in %ds · %s"):format(n16, v65:sub(1, 100)))
																																						n17 = os.clock() + n16

																																						while true do
																																							flag32 = fn() and fn45() and os.clock() < n17
																																							if flag32 then
																																								task.wait(0.25)
																																								continue
																																							end
																																							break
																																						end
																																					end
																																				end

																																				if fn() then
																																					continue
																																				end
																																			end
																																		end
																																	end
																																end
																															end
																														end
																													else
																														error("devirt: unstructured jump to block_7908") -- goto block_7908
																													end
																												end
																											end
																										else
																											exitTo = 14
																											break
																										end
																									end
																								end
																							end
																						end
																					else
																						getgenv().__CHSAE_CarryRequest = nil
																						chsaeCarryRequest = nil
																						n19 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and tonumber(chsaeCarryRequest.retryAt) or 0
																						n20 = n19 - os.clock()
																						flag35 = chsaeCarryRequest and not chsaeCarryRequest.inFlight
																						n21 = flag35 and tonumber(chsaeCarryRequest.proofDeadline) or 0
																						n2 = n21 - os.clock()
																						flag36 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and chsaeCarryRequest.accepted and n2 > 0

																						if flag36 then
																							tbl15.treadmillSuppressed = true
																							v23 = tbl14
																							tbl14.stealWants = true
																							v23.critical = true
																							handlers.carry = "📦 Carry: waiting for server sync"
																							fn11("⏳ Confirming pickup")
																							task.wait(math.min(0.12, math.max(0.02, n2)))
																							if fn() then
																								continue
																							end
																						else
																							v72 = chsaeCarryRequest and handlers.retainUnverifiedPickup(chsaeCarryRequest)

																							if v72 then
																								handlers.carry = "📦 Carry: unverified · retrying beside egg"
																								fn11("⏳ Retrying pickup")
																							end

																							flag37 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and not chsaeCarryRequest.accepted and n20 > 0

																							if flag37 then
																								if chsaeCarryRequest.uid then
																									uid2 = chsaeCarryRequest.uid
																									max = math.max
																									n22 = tonumber(tbl18[chsaeCarryRequest.uid]) or 0
																									tbl18[uid2] = max(n22, n19)
																								end
																							end

																							flag38 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and getgenv().__CHSAE_CarryRequest == chsaeCarryRequest

																							if flag38 then
																								getgenv().__CHSAE_CarryRequest = nil
																								n18 = 0
																							else
																								n18 = 0
																							end

																							for k in pairs(tbl2.TargetRarities) do
																								error("devirt: unstructured jump to block_2677") -- goto block_2677
																							end

																							error("devirt: unstructured jump to block_2698") -- goto block_2698
																						end
																					end
																				else
																					flag42 = flag41 or flag42

																					if flag42 then
																						chsaeCarryRequest.supersededByRecovery = true

																						if getgenv().__CHSAE_CarryRequest == chsaeCarryRequest then
																							getgenv().__CHSAE_CarryRequest = nil
																						end

																						handlers.clearCarryLossRecovery(chsaeCarryRequest.uid)

																						if tostring(tbl13.lockedUid) == tostring(chsaeCarryRequest.uid) then
																							tbl13.lockedUid = nil
																						end

																						if tostring(tbl13.persistentUid) == tostring(chsaeCarryRequest.uid) then
																							tbl13.persistentUid = nil
																						end

																						tbl15.treadmillSuppressed = false

																						do
																							local v73 = tbl14
																							tbl14.stealWants = false
																							v73.critical = false
																						end

																						tbl14.release("Steal")
																						fn11(flag41 and "🟡 Recovery egg taken — rescanning" or "🟡 Death recovery expired — rescanning")
																						chsaeCarryRequest = nil

																						if chsaeCarryRequest == nil then
																							n19 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and tonumber(chsaeCarryRequest.retryAt) or 0
																							n20 = n19 - os.clock()
																							flag35 = chsaeCarryRequest and not chsaeCarryRequest.inFlight
																							n21 = flag35 and tonumber(chsaeCarryRequest.proofDeadline) or 0
																							n2 = n21 - os.clock()
																							flag36 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and chsaeCarryRequest.accepted and n2 > 0

																							if flag36 then
																								tbl15.treadmillSuppressed = true
																								v23 = tbl14
																								tbl14.stealWants = true
																								v23.critical = true
																								handlers.carry = "📦 Carry: waiting for server sync"
																								fn11("⏳ Confirming pickup")
																								task.wait(math.min(0.12, math.max(0.02, n2)))
																								if fn() then
																									continue
																								end
																							else
																								v72 = chsaeCarryRequest and handlers.retainUnverifiedPickup(chsaeCarryRequest)

																								if v72 then
																									handlers.carry = "📦 Carry: unverified · retrying beside egg"
																									fn11("⏳ Retrying pickup")
																								end

																								flag37 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and not chsaeCarryRequest.accepted and n20 > 0

																								if flag37 then
																									if chsaeCarryRequest.uid then
																										uid2 = chsaeCarryRequest.uid
																										max = math.max
																										n22 = tonumber(tbl18[chsaeCarryRequest.uid]) or 0
																										tbl18[uid2] = max(n22, n19)
																									end
																								end

																								flag38 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and getgenv().__CHSAE_CarryRequest == chsaeCarryRequest

																								if flag38 then
																									getgenv().__CHSAE_CarryRequest = nil
																									n18 = 0
																								else
																									n18 = 0
																								end

																								for k in pairs(tbl2.TargetRarities) do
																									error("devirt: unstructured jump to block_2677") -- goto block_2677
																								end

																								error("devirt: unstructured jump to block_2698") -- goto block_2698
																							end
																						else
																							getgenv().__CHSAE_CarryRequest = nil
																							chsaeCarryRequest = nil
																							n19 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and tonumber(chsaeCarryRequest.retryAt) or 0
																							n20 = n19 - os.clock()
																							flag35 = chsaeCarryRequest and not chsaeCarryRequest.inFlight
																							n21 = flag35 and tonumber(chsaeCarryRequest.proofDeadline) or 0
																							n2 = n21 - os.clock()
																							flag36 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and chsaeCarryRequest.accepted and n2 > 0

																							if flag36 then
																								tbl15.treadmillSuppressed = true
																								v23 = tbl14
																								tbl14.stealWants = true
																								v23.critical = true
																								handlers.carry = "📦 Carry: waiting for server sync"
																								fn11("⏳ Confirming pickup")
																								task.wait(math.min(0.12, math.max(0.02, n2)))
																								if fn() then
																									continue
																								end
																							else
																								v72 = chsaeCarryRequest and handlers.retainUnverifiedPickup(chsaeCarryRequest)

																								if v72 then
																									handlers.carry = "📦 Carry: unverified · retrying beside egg"
																									fn11("⏳ Retrying pickup")
																								end

																								flag37 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and not chsaeCarryRequest.accepted and n20 > 0

																								if flag37 then
																									if chsaeCarryRequest.uid then
																										uid2 = chsaeCarryRequest.uid
																										max = math.max
																										n22 = tonumber(tbl18[chsaeCarryRequest.uid]) or 0
																										tbl18[uid2] = max(n22, n19)
																									end
																								end

																								flag38 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and getgenv().__CHSAE_CarryRequest == chsaeCarryRequest

																								if flag38 then
																									getgenv().__CHSAE_CarryRequest = nil
																									n18 = 0
																								else
																									n18 = 0
																								end

																								for k in pairs(tbl2.TargetRarities) do
																									error("devirt: unstructured jump to block_2677") -- goto block_2677
																								end

																								error("devirt: unstructured jump to block_2698") -- goto block_2698
																							end
																						end
																					else
																						exitTo = 11
																						break
																					end
																				end
																			elseif chsaeCarryRequest == nil then
																				n19 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and tonumber(chsaeCarryRequest.retryAt) or 0
																				n20 = n19 - os.clock()
																				flag35 = chsaeCarryRequest and not chsaeCarryRequest.inFlight
																				n21 = flag35 and tonumber(chsaeCarryRequest.proofDeadline) or 0
																				n2 = n21 - os.clock()
																				flag36 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and chsaeCarryRequest.accepted and n2 > 0

																				if flag36 then
																					tbl15.treadmillSuppressed = true
																					v23 = tbl14
																					tbl14.stealWants = true
																					v23.critical = true
																					handlers.carry = "📦 Carry: waiting for server sync"
																					fn11("⏳ Confirming pickup")
																					task.wait(math.min(0.12, math.max(0.02, n2)))
																					if fn() then
																						continue
																					end
																				else
																					v72 = chsaeCarryRequest and handlers.retainUnverifiedPickup(chsaeCarryRequest)

																					if v72 then
																						handlers.carry = "📦 Carry: unverified · retrying beside egg"
																						fn11("⏳ Retrying pickup")
																					end

																					flag37 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and not chsaeCarryRequest.accepted and n20 > 0

																					if flag37 then
																						if chsaeCarryRequest.uid then
																							uid2 = chsaeCarryRequest.uid
																							max = math.max
																							n22 = tonumber(tbl18[chsaeCarryRequest.uid]) or 0
																							tbl18[uid2] = max(n22, n19)
																						end
																					end

																					flag38 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and getgenv().__CHSAE_CarryRequest == chsaeCarryRequest

																					if flag38 then
																						getgenv().__CHSAE_CarryRequest = nil
																						n18 = 0
																					else
																						n18 = 0
																					end

																					for k in pairs(tbl2.TargetRarities) do
																						error("devirt: unstructured jump to block_2677") -- goto block_2677
																					end

																					error("devirt: unstructured jump to block_2698") -- goto block_2698
																				end
																			else
																				getgenv().__CHSAE_CarryRequest = nil
																				chsaeCarryRequest = nil
																				n19 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and tonumber(chsaeCarryRequest.retryAt) or 0
																				n20 = n19 - os.clock()
																				flag35 = chsaeCarryRequest and not chsaeCarryRequest.inFlight
																				n21 = flag35 and tonumber(chsaeCarryRequest.proofDeadline) or 0
																				n2 = n21 - os.clock()
																				flag36 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and chsaeCarryRequest.accepted and n2 > 0

																				if flag36 then
																					tbl15.treadmillSuppressed = true
																					v23 = tbl14
																					tbl14.stealWants = true
																					v23.critical = true
																					handlers.carry = "📦 Carry: waiting for server sync"
																					fn11("⏳ Confirming pickup")
																					task.wait(math.min(0.12, math.max(0.02, n2)))
																					if fn() then
																						continue
																					end
																				else
																					v72 = chsaeCarryRequest and handlers.retainUnverifiedPickup(chsaeCarryRequest)

																					if v72 then
																						handlers.carry = "📦 Carry: unverified · retrying beside egg"
																						fn11("⏳ Retrying pickup")
																					end

																					flag37 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and not chsaeCarryRequest.accepted and n20 > 0

																					if flag37 then
																						if chsaeCarryRequest.uid then
																							uid2 = chsaeCarryRequest.uid
																							max = math.max
																							n22 = tonumber(tbl18[chsaeCarryRequest.uid]) or 0
																							tbl18[uid2] = max(n22, n19)
																						end
																					end

																					flag38 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and getgenv().__CHSAE_CarryRequest == chsaeCarryRequest

																					if flag38 then
																						getgenv().__CHSAE_CarryRequest = nil
																						n18 = 0
																					else
																						n18 = 0
																					end

																					for k in pairs(tbl2.TargetRarities) do
																						error("devirt: unstructured jump to block_2677") -- goto block_2677
																					end

																					error("devirt: unstructured jump to block_2698") -- goto block_2698
																				end
																			end
																		elseif chsaeCarryRequest.inFlight then
																			local v73 = handlers.getDroppedRecoveryRecord(chsaeCarryRequest.uid)

																			if v73 then
																				armDroppedEggReacquire(v73.Uid, "egg dropped while carry request was still returning")
																				tbl15.treadmillSuppressed = true

																				do
																					local v74 = tbl14
																					tbl14.stealWants = true
																					v74.critical = true
																				end

																				tbl14.stealBeat = os.clock()

																				if tbl14.owner ~= "Steal" then
																					tbl14.acquireWait("Steal", 0.25)
																				end

																				handlers.carry = "📦 Carry: dropped · request retiring"
																				fn11("🔁 Retrieving dropped egg")
																				n19 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and tonumber(chsaeCarryRequest.retryAt) or 0
																				n20 = n19 - os.clock()
																				flag35 = chsaeCarryRequest and not chsaeCarryRequest.inFlight
																				n21 = flag35 and tonumber(chsaeCarryRequest.proofDeadline) or 0
																				n2 = n21 - os.clock()
																				flag36 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and chsaeCarryRequest.accepted and n2 > 0

																				if flag36 then
																					tbl15.treadmillSuppressed = true
																					v23 = tbl14
																					tbl14.stealWants = true
																					v23.critical = true
																					handlers.carry = "📦 Carry: waiting for server sync"
																					fn11("⏳ Confirming pickup")
																					task.wait(math.min(0.12, math.max(0.02, n2)))
																					if fn() then
																						continue
																					end
																				else
																					v72 = chsaeCarryRequest and handlers.retainUnverifiedPickup(chsaeCarryRequest)

																					if v72 then
																						handlers.carry = "📦 Carry: unverified · retrying beside egg"
																						fn11("⏳ Retrying pickup")
																					end

																					flag37 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and not chsaeCarryRequest.accepted and n20 > 0

																					if flag37 then
																						if chsaeCarryRequest.uid then
																							uid2 = chsaeCarryRequest.uid
																							max = math.max
																							n22 = tonumber(tbl18[chsaeCarryRequest.uid]) or 0
																							tbl18[uid2] = max(n22, n19)
																						end
																					end

																					flag38 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and getgenv().__CHSAE_CarryRequest == chsaeCarryRequest

																					if flag38 then
																						getgenv().__CHSAE_CarryRequest = nil
																						n18 = 0
																					else
																						n18 = 0
																					end

																					for k in pairs(tbl2.TargetRarities) do
																						error("devirt: unstructured jump to block_2677") -- goto block_2677
																					end

																					error("devirt: unstructured jump to block_2698") -- goto block_2698
																				end
																			else
																				exitTo = 10
																				break
																			end
																		else
																			n19 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and tonumber(chsaeCarryRequest.retryAt) or 0
																			n20 = n19 - os.clock()
																			flag35 = chsaeCarryRequest and not chsaeCarryRequest.inFlight
																			n21 = flag35 and tonumber(chsaeCarryRequest.proofDeadline) or 0
																			n2 = n21 - os.clock()
																			flag36 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and chsaeCarryRequest.accepted and n2 > 0

																			if flag36 then
																				exitTo = 9
																				break
																			else
																				v72 = chsaeCarryRequest and handlers.retainUnverifiedPickup(chsaeCarryRequest)

																				if v72 then
																					handlers.carry = "📦 Carry: unverified · retrying beside egg"
																					fn11("⏳ Retrying pickup")
																				end

																				flag37 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and not chsaeCarryRequest.accepted and n20 > 0

																				if flag37 then
																					if chsaeCarryRequest.uid then
																						uid2 = chsaeCarryRequest.uid
																						max = math.max
																						n22 = tonumber(tbl18[chsaeCarryRequest.uid]) or 0
																						tbl18[uid2] = max(n22, n19)
																					end
																				end

																				flag38 = chsaeCarryRequest and not chsaeCarryRequest.inFlight and getgenv().__CHSAE_CarryRequest == chsaeCarryRequest

																				if flag38 then
																					getgenv().__CHSAE_CarryRequest = nil
																					n18 = 0
																				else
																					n18 = 0
																				end

																				for k in pairs(tbl2.TargetRarities) do
																					error("devirt: unstructured jump to block_2677") -- goto block_2677
																				end

																				error("devirt: unstructured jump to block_2698") -- goto block_2698
																			end
																		end
																	else
																		n18 = 0

																		for k in pairs(tbl2.TargetRarities) do
																			error("devirt: unstructured jump to block_2677") -- goto block_2677
																		end

																		error("devirt: unstructured jump to block_2698") -- goto block_2698
																	end
																end
															end
														end
													end
												else
													v71, v20, v21 = handlers.eggInventoryCapacityState()

													if v71 then
														exitTo = 6
														break
													else
														error("devirt: unstructured jump to block_802") -- goto block_802
													end
												end
											end
										end
									end
								end
							end

							break
						end
					end

					if exitTo == 1 then
						handlers.Stall.run()
						continue
					elseif exitTo == 2 then
						local v69 = tbl14
						tbl14.critical = false
						v69.stealWants = false
						tbl14.release("Steal")
						RunService.Heartbeat:Wait()
						continue
					elseif exitTo == 3 then
						fn2(false)
						tbl15.treadmillSuppressed = false
						local flag33 = carryLossRecoveryPending()

						if flag33 then
							flag33 = os.clock() - (tonumber(tbl13.dropDetectedAt) or 0) <= tbl13.disabledRecoveryHold
						end

						if not flag33 then
							fn13()
						end

						local v69 = tbl14
						tbl14.stealWants = false
						v69.critical = false
						tbl14.release("Steal")
						handlers.pauseStealTimer()
						handlers.set("target", "🎯 Target: none")
						handlers.carry = "📦 Carry: none"
						fn11("🔴 Off")
						task.wait(0.5)
						continue
					elseif exitTo == 4 then
						local treadmillSuppressed = carryLossRecoveryPending()
						tbl15.treadmillSuppressed = treadmillSuppressed
						tbl14.stealWants = treadmillSuppressed
						tbl14.critical = false
						tbl14.stealBeat = os.clock()
						tbl14.release("Steal")
						local v69 = fn11
						treadmillSuppressed = treadmillSuppressed and "🔁 Respawning — exact egg recovery locked" or "🟡 Respawning — waiting for character"
						v69(treadmillSuppressed)
						task.wait(0.2)
						continue
					elseif exitTo == 5 then
						fn2(false)
						tbl15.treadmillSuppressed = false
						local v69 = tbl14
						tbl14.stealWants = false
						v69.critical = false
						tbl14.release("Steal")
						handlers.pauseStealTimer()
						handlers.set("target", "🎯 Target: Crane return")
						handlers.carry = "📦 Carry: none"
						fn11("🔓 Submitting hatched Crane")
						task.wait(0.1)
						continue
					elseif exitTo == 6 then
						if handlers.riftCollecting == true or tbl2.AutoLab == true and handlers.riftActive == true and handlers.riftEggActive() then
							handlers.riftCollecting = false
							tbl15.treadmillSuppressed = false
							local v69 = tbl14
							tbl14.stealWants = false
							v69.critical = false
							tbl14.release("Steal")
							fn11("🌀 Inventory full · place or hatch required eggs")
							local chsaeRiftWake = getgenv().__CHSAE_RiftWake

							if chsaeRiftWake then
								pcall(function()
									chsaeRiftWake:Fire("inventory-full")
								end)
							end

							task.wait(0.1)
						elseif tbl2.AutoPetIndex and not handlers.normalStealPending() and not handlers.greatBloomUnlockNeedsCrane() then
							tbl15.treadmillSuppressed = false
							local v69 = tbl14
							tbl14.stealWants = false
							v69.critical = false
							tbl14.release("Steal")
							fn11("📖 Index · make egg inventory space")
							task.wait(0.5)
						elseif handlers.greatBloomUnlockNeedsCrane() then
							tbl15.treadmillSuppressed = false
							local v69 = tbl14
							tbl14.stealWants = false
							v69.critical = false
							tbl14.release("Steal")
							fn11("🔓 Great Bloom · make egg inventory space")
							task.wait(0.5)
						else
							handlers.stopAutoStealForFullInventory(v20, v21, "Your egg inventory is full!")
							task.wait(0.05)
						end

						continue
					elseif exitTo == 7 then
						fn2(false)
						tbl15.treadmillSuppressed = true
						local v69 = tbl14
						tbl14.stealWants = false
						v69.critical = false
						tbl14.release("Steal")
						handlers.pauseStealTimer()
						handlers.set("target", "🎯 Target: Lab")
						handlers.carry = "📦 Carry: none"
						fn11("🧪 Lab has priority")
						task.wait(0.1)
						continue
					elseif exitTo == 8 then
						critical = true

						if v22 and v22.AreaId ~= nil then
							handlers.activeGuardAreaId = tostring(v22.AreaId)
						end

						tbl15.treadmillSuppressed = true
						local v69 = tbl14
						tbl14.stealWants = true
						v69.critical = true
						tbl14.acquireWait("Steal", 3)
						tbl15.requestTreadmillExit()

						if fn19() then
							tbl14.release("Steal")
							fn11("⏳ Wall closed — holding egg")

							fn18(fn16() and 10 or math.max(0.25, n - os.clock()), function()
								return not fn19()
							end)
						else
							fn11("🟢 Carrying → home")
							local n18 = fn38()
							n18 = n18 and n18.Position + Vector3.new(0, 3, 0) or fn36(30)

							if not n18 then
								fn11("🟡 No exit line")
								task.wait(0.5)
							else
								local v70, flag33

								do
									local assetCategory2 = v22 and v22.AssetCategory
									local activeGuardAreaId = v22 and v22.AreaId ~= nil and tostring(v22.AreaId) or handlers.activeGuardAreaId
									local claimSequence = tbl13.claimSequence
									local chsaeCarryRequest2 = getgenv().__CHSAE_CarryRequest

									if type(chsaeCarryRequest2) ~= "table" or tostring(chsaeCarryRequest2.uid) ~= tostring(uid) then
										chsaeCarryRequest2 = {
											uid = uid,
											category = assetCategory2,
											character = localPlayer.Character,
											generation = tbl13.respawnGeneration,
											carrySeen = true,
											inFlight = false,
										}
									end

									handlers.beginStealClaim(chsaeCarryRequest2, true)
									v70 = fn29(uid, assetCategory2, claimSequence)
									flag33 = false

									while true do
										if fn() and not v70 then
											local v71

											do
												local v72

												v72, v71 = handlers.centeredStealReturnTo(n18, fn45, function()
													local flag34 = fn16() or tbl15.detectActiveTreadmill() ~= nil
													local flag35

													if flag34 then
														flag35 = flag34
													else
														flag35 = uid and (fn28(uid) or handlers.carryLostInField(uid)) and not fn29(uid, assetCategory2, claimSequence)
													end

													return flag35 or uid and tostring(tbl13.deathRecoveryUid) == tostring(uid) and tostring(handlers.pendingDroppedUid) == tostring(uid) and not fn29(uid, assetCategory2, claimSequence)
												end, activeGuardAreaId)

												flag33 = v72
											end

											local v72 = v71
											v70 = fn29(uid, assetCategory2, claimSequence)

											if not (flag33 or v70) then
												if handlers.preserveCarriedReturn(uid, v72) then
													if tbl15.detectActiveTreadmill() then
														tbl15.requestTreadmillExit()
														fn11("🟡 Treadmill blocked — exiting")
														task.wait(0.1)
													elseif fn16() then
														fn11("⏳ Wall closed — holding carried egg")

														fn18(0.25, function()
															return not fn16()
														end)
													else
														fn11("↩️ Returning home")
														task.wait(0.03)
													end

													continue
												end
											end
										end

										break
									end
								end

								do
									local devChickenTween2 = handlers.DevChickenTween

									if devChickenTween2 and devChickenTween2.lease and devChickenTween2.lease.owner == "Steal" then
										devChickenTween2.restore("carried return ended")
									end
								end

								if tbl15.detectActiveTreadmill() then
									tbl15.requestTreadmillExit()
									fn11("🟡 Treadmill blocked — exiting")
								elseif fn16() then
									tbl14.release("Steal")
									fn11("⏳ Wall closed — holding egg")
								else
									v70 = v70 or flag33 and handlers.waitStealClaim(uid, fn45)

									do
										local v71 = fn26()
										critical = v71 ~= nil
										handlers.activeGuardAreaId = v71 and v71.AreaId ~= nil and tostring(v71.AreaId) or nil
									end

									tbl14.critical = critical

									if v70 then
										handlers.activeGuardAreaId = nil

										if uid and handlers.candidateIndex then
											handlers.candidateIndex:Invalidate(uid, "recovered delivery verified")
										end

										tbl15.treadmillSuppressed = true

										do
											local v71 = tbl14
											tbl14.stealWants = false
											v71.critical = false
										end

										tbl14.release("Steal")
										handlers.clearCarryLossRecovery(uid)
										tbl13.persistentUid = nil
										tbl13.lockedUid = nil
										tbl13.lastDroppedUid = nil
										tbl13.dropDetectedAt = 0
										fn11("✅ Egg collected")
										fn15()
									elseif not critical then
										local lastDroppedUid = uid or tbl13.lastDroppedUid

										if armDroppedEggReacquire(lastDroppedUid, "recovered carry was dropped") then
											fn11("🥚 Guard dropped egg · reclaiming now")
											task.wait(0.03)
										elseif lastDroppedUid and tostring(tbl13.lastDroppedUid) == tostring(lastDroppedUid) then
											tbl13.lockedUid = lastDroppedUid
											tbl15.treadmillSuppressed = true

											do
												local v71 = tbl14
												tbl14.stealWants = true
												v71.critical = true
											end

											tbl14.stealBeat = os.clock()

											if tbl14.owner ~= "Steal" then
												tbl14.acquireWait("Steal", 0.1)
											end

											fn11("🥚 Dropped egg syncing · reclaiming")
											fn18(0.08)
										else
											if tbl2.PersistentSteal and uid then
												tbl13.persistentUid = uid
												fn11("🔁 Carry lost — waiting for egg")
											else
												if uid then
													tbl18[uid] = os.clock() + 3
												end

												fn11("🟡 Egg dropped — rescanning")
											end

											tbl14.critical = false
										end
									else
										fn11("🟢 Carrying → home")
									end
								end
							end
						end

						continue
					elseif exitTo == 9 then
						tbl15.treadmillSuppressed = true
						v23 = tbl14
						tbl14.stealWants = true
						v23.critical = true
						handlers.carry = "📦 Carry: waiting for server sync"
						fn11("⏳ Confirming pickup")
						task.wait(math.min(0.12, math.max(0.02, n2)))
						continue
					elseif exitTo == 10 then
						tbl15.treadmillSuppressed = true
						local v69 = tbl14
						tbl14.stealWants = true
						v69.critical = true
						tbl14.stealBeat = os.clock()

						if tbl14.owner ~= "Steal" then
							tbl14.acquireWait("Steal", 0.25)
						end

						local n18 = math.max(0, os.clock() - (chsaeCarryRequest.started or os.clock()))
						handlers.carry = ("📦 Carry: server response stalled · %.1fs"):format(n18)
						fn11("⏳ Waiting for pickup")
						task.wait(0.2)
						continue
					elseif exitTo == 11 then
						if carryLossRecoveryPending() then
							tbl15.treadmillSuppressed = true
							local v69 = tbl14
							tbl14.stealWants = true
							v69.critical = true
							tbl14.stealBeat = os.clock()

							if tbl14.owner ~= "Steal" then
								tbl14.acquireWait("Steal", 0.1)
							end

							handlers.carry = "📦 Carry: death recovery syncing"
							fn11("🔁 Waiting for dropped egg")
							task.wait(0.1)
						else
							tbl15.treadmillSuppressed = false
							local v69 = tbl14
							tbl14.stealWants = false
							v69.critical = false
							tbl14.release("Steal")
							handlers.carry = "📦 Carry: retiring previous request"
							fn11("🟡 Finishing pickup")
							task.wait(0.2)
						end

						continue
					elseif exitTo == 12 then
						tbl15.treadmillSuppressed = false
						tbl14.stealWants = false
						tbl14.release("Steal")
						fn11("🟡 Pick a target")
						task.wait(2)
						continue
					elseif exitTo == 13 then
						tbl15.treadmillSuppressed = false
						tbl14.stealWants = false
						tbl14.release("Steal")
						fn11("🟡 Waiting for target")
						fn18(5)
						continue
					elseif exitTo == 14 then
						magnitude2 = fn33()

						if rec then
							v33 = fn30(rec)
							tbl19 = v33 or { _id = "Target", RarityNumber = 0 }
							tbl20 = { rec = rec, rar = tbl19, muts = fn22(rec) }
							magnitude2 = magnitude2 and ((magnitude2.Position - rec.BottomCFrame.Position) * Vector3.new(1, 0, 1)).Magnitude or 0
							tbl20.dist = magnitude2
							tbl20.score = riftValueScore(rec)
							weight = fn23(rec) or 0
							tbl20.weight = weight
							v34 = tonumber
							rarityNumber = tbl19.RarityNumber
							rank = rarityNumber or tbl19.Rank
							rarNum = v34(rank) or 0
							tbl20.rarNum = rarNum
						else
							v35, v36, v37 = ipairs(entries)
							v38 = v35
							n8 = 0
							n9 = 0
							tbl20 = nil

							for _, v69 in v38, v36, v37 do
								rec2 = v69.rec
								n8 += 1
								flag14 = tostring(rec2.State) == "Slot" and rec2.BottomCFrame and not handlers.isCaptureEventUid(rec2.Uid) and not handlers.deliveryRejected(rec2.Uid)

								if flag14 then
									flag15 = not tbl18[rec2.Uid]

									if flag15 then
										flag16 = flag15
									else
										v39 = tbl18[rec2.Uid]
										flag16 = os.clock() > v39
									end
								else
									flag16 = flag14
								end

								if flag16 then
									rarity = v69.rarity
									mutations = v69.mutations

									if fn53(rec2, rarity, mutations, v69) then
										n9 += 1
										tbl21 = { rec = rec2, rar = rarity, muts = mutations }
										magnitude3 = magnitude2 and ((magnitude2.Position - rec2.BottomCFrame.Position) * Vector3.new(1, 0, 1)).Magnitude
										dist = magnitude3 or 0
										tbl21.dist = dist
										tbl21.score = v69.value
										tbl21.weight = v69.weight
										tbl21.rarNum = v69.rarityNumber

										if not tbl20 then
											flag17 = true
										elseif flag3 then
											flag18 = tbl21.score < tbl20.score

											if flag18 then
												flag17 = flag18
											else
												flag19 = tbl21.score == tbl20.score
												flag17 = flag19 and tbl21.weight < tbl20.weight
											end

											flag17 = flag17 or tbl21.score == tbl20.score and tbl21.weight == tbl20.weight and tbl21.dist < tbl20.dist
										elseif targetPriority == "Value" then
											flag17 = tbl21.score > tbl20.score or tbl21.score == tbl20.score and tbl21.dist < tbl20.dist
										elseif targetPriority == "Rarity" then
											flag17 = tbl21.rarNum > tbl20.rarNum or tbl21.rarNum == tbl20.rarNum and tbl21.score > tbl20.score or tbl21.rarNum == tbl20.rarNum and tbl21.score == tbl20.score and tbl21.dist < tbl20.dist
										elseif targetPriority == "Weight" then
											flag17 = tbl21.weight > tbl20.weight or tbl21.weight == tbl20.weight and tbl21.rarNum > tbl20.rarNum or tbl21.weight == tbl20.weight and tbl21.rarNum == tbl20.rarNum and tbl21.score > tbl20.score or tbl21.weight == tbl20.weight and tbl21.rarNum == tbl20.rarNum and tbl21.score == tbl20.score and tbl21.dist < tbl20.dist
										elseif targetPriority == "Farthest" then
											flag17 = tbl21.dist > tbl20.dist or tbl21.dist == tbl20.dist and tbl21.score > tbl20.score
										else
											flag17 = tbl21.dist < tbl20.dist or tbl21.dist == tbl20.dist and tbl21.score > tbl20.score
										end

										if flag17 then
											tbl20 = tbl21
										end
									end
								end
							end
						end

						if not tbl20 then
							n10 = 0
							n11 = 0

							for _, entry in ipairs(entries) do
								rec3 = entry.rec

								if rec3.BottomCFrame then
									rarity2 = entry.rarity
									mutations2 = entry.mutations
									flag20 = not handlers.isCaptureEventUid(rec3.Uid) and fn53(rec3, rarity2, mutations2, entry)
									flag21 = flag20 and tostring(rec3.State) == "Dropped"

									if flag21 then
										n10 += 1
									else
										flag20 = flag20 and tostring(rec3.State) == "Slot" and tbl18[rec3.Uid]

										if flag20 then
											v40 = tbl18[rec3.Uid]
											flag20 = os.clock() <= v40
										end

										if flag20 then
											n11 += 1
										end
									end
								end
							end

							tbl15.treadmillSuppressed = false
							tbl14.stealWants = false
							tbl14.release("Steal")
							handlers.set("target", "🎯 Target: none")
							handlers.carry = "📦 Carry: none"

							if flag2 then
								fn11("🌀 Waiting for a required Rift egg")
							elseif flag3 then
								fn11("🔓 Great Bloom · waiting for Crane egg")
							elseif flag5 then
								fn11("🔓 Crane reserved · continuing unlock")
							else
								flag22 = n10 > 0 and not tbl2.PersistentSteal

								if flag22 then
									v41 = fn11
									str3 = "🟡 %d selected egg%s dropped · enable Persistent"
									format = str3.format
									str4 = n10 == 1 and ""
									str5 = str4 or "s"
									v41(format(str3, n10, str5))
								elseif n11 > 0 then
									v42 = fn11
									str6 = "🟡 %d target%s cooling down"
									format2 = str6.format
									str7 = n11 == 1 and "" or "s"
									v42(format2(str6, n11, str7))
								else
									fn11("🟡 Waiting for target")
								end
							end

							checkStealHop = not flag2 and not flag3 and not flag5 and not flag4 and n10 == 0 and n11 == 0 and handlers.checkStealHop

							if checkStealHop then
								handlers.checkStealHop()
							end

							v43 = fn18
							n12 = tbl2.StealServerHop and 2 or 5
							v43(n12)
						else
							if handlers.stealHop then
								handlers.stealHop.emptySince = nil
							end

							rar = tbl20.rar
							v44 = fn11
							str8 = flag2 and "🧪 Requested Lab egg locked"
							str9 = str8 or flag3 and "🔓 Crane egg locked" or stealHopFallback and "🟢 Best egg locked · no server matched"
							str10 = str9 or "🟢 Target locked"
							v44(str10)
							set = handlers.set
							str11 = "🎯 Target: %s %s · %.2f kg"
							format3 = str11.format
							str12 = tostring(rar._id)
							str13 = tostring(tbl20.rec.AssetCategory)
							num2 = tonumber(tbl20.weight)
							n13 = num2 or 0
							set("target", format3(str11, str12, str13, n13))
							directory = Assets and Assets.Directory and Assets.Directory[tostring(tbl20.rec.AssetCategory)]
							webhookTarget = tbl13.webhookTarget
							str14 = flag2 and "rift" or flag3 and "internal" or flag4 and "pet-index" or "steal-filter"
							flag23 = type(webhookTarget) == "table" and tostring(webhookTarget.uid) == tostring(tbl20.rec.Uid) and webhookTarget.source ~= nil

							if flag23 then
								str14 = webhookTarget.source
							end

							v45 = tbl13
							webhookTarget2 = { uid = tbl20.rec.Uid, source = str14 }
							v46 = tostring
							assetCategory = tbl20.rec.AssetCategory
							str15 = assetCategory or "Unknown"
							webhookTarget2.category = v46(str15)
							v47 = tostring
							id = rar._id or "Unknown"
							webhookTarget2.rarity = v47(id)
							v48 = tostring
							areaId = tbl20.rec.AreaId or "Unknown"
							webhookTarget2.area = v48(areaId)
							mutations3 = #tbl20.muts > 0 and table.concat(tbl20.muts, ", ") or "None"
							webhookTarget2.mutations = mutations3
							scale = tonumber(tbl20.rec.AssetScale) or 1
							webhookTarget2.scale = scale
							income = tonumber(tbl20.score) or 0
							webhookTarget2.income = income
							distance = tonumber(tbl20.dist) or 0
							webhookTarget2.distance = distance

							if directory then
								icon = directory.Egg and directory.Egg.Icon
								directory = icon or directory.Icon
							end

							webhookTarget2.icon = directory
							v45.webhookTarget = webhookTarget2
							tbl13.lockedUid = tbl20.rec.Uid
							flag24 = tbl2.PersistentSteal and not flag4

							if flag24 then
								tbl13.persistentUid = tbl20.rec.Uid
							end

							rec4 = tbl20.rec
							tbl15.treadmillSuppressed = true
							tbl14.stealWants = true

							if not tbl14.acquireWait("Steal", 4) then
								fn11("🟡 Waiting for pen…")
								task.wait(0.5)
							else
								tbl14.critical = true

								if not tbl14.waitPets(fn45, 4) then
									task.wait(0.1)
								elseif not tbl15.requestTreadmillExit() then
									v49 = tbl14
									tbl14.critical = false
									v49.stealWants = false
									tbl14.release("Steal")
									v50 = fn11
									str16 = tbl15.treadmillExitRequest.inFlight and "🟡 Treadmill server pending — retrying" or "🟡 Could not leave treadmill — retrying"
									v50(str16)
									task.wait(0.25)
								elseif not tbl15.waitForToolFree(1.5) then
									v51 = tbl14
									tbl14.critical = false
									v51.stealWants = true
									fn11("🟡 Finishing previous activity — retrying")
									task.wait(0.1)
								else
									riftTargetUid = not carryLossRecoveryPending() and handlers.riftCollecting == true and handlers.riftTargetUid or nil
									flag25 = riftTargetUid and tostring(rec4.Uid) ~= tostring(riftTargetUid)

									if flag25 then
										flag26 = flag25
									else
										v52 = flag4 and handlers.petIndexBlocked()
										flag26 = v52 and not carryLossRecoveryPending()
									end

									if flag26 then
										if tostring(tbl13.lockedUid) == tostring(rec4.Uid) then
											tbl13.lockedUid = nil
										end

										v53 = tbl14
										tbl14.critical = false
										v53.stealWants = false
										tbl14.release("Steal")
										fn11("🌀 Event target changed · selecting nearest")
										fn18(0.05)
									else
										flag27 = fn25(rec4.Uid)
										str17 = flag27 and tostring(flag27.State) or "Missing"
										flag28 = not flag27 or str17 ~= "Slot" and str17 ~= "Dropped"

										if flag28 then
											persistentSteal = tbl2.PersistentSteal
											flag27 = persistentSteal and flag27 and str17 ~= "Claimed"
											tbl14.critical = false
											tbl14.release("Steal")

											if flag27 then
												tbl15.treadmillSuppressed = true
												tbl14.stealWants = true
												tbl14.stealBeat = os.clock()
												fn11(("🔁 Persistent — target became %s"):format(str17))
												fn18(0.75)
											else
												if tostring(tbl13.persistentUid) == tostring(rec4.Uid) then
													tbl13.persistentUid = nil
												end

												if tostring(tbl13.lockedUid) == tostring(rec4.Uid) then
													tbl13.lockedUid = nil
												end

												tbl13.webhookTarget = nil
												tbl15.treadmillSuppressed = false
												tbl14.stealWants = false
												handlers.set("target", "🎯 Target: none")

												if handlers.candidateIndex then
													handlers.candidateIndex:Invalidate(rec4.Uid, "target changed while leaving treadmill")
												end

												fn11(("🟡 Target became %s — rescanning"):format(str17))
												fn18(0.08)
											end
										elseif localPlayer:GetAttribute("InScrambleArena") == true then
											fn11("Leaving Dr. Scramble's arena")
											handlers.leaveScrambleArena(fn45)
										else
											if tbl2.EnableDefaultSpeed then
												v54, str18, v55 = handlers.runDefaultSpeedSteal(flag27, fn45)
											else
												stealMovementType = tbl2.StealMovementType
												v54, str18, v55 = handlers.runFlySteal(flag27, fn45, stealMovementType == "Fly", stealMovementType == "Relay", stealMovementType == "Hop Fly")
											end

											if v54 then
												if handlers.candidateIndex then
													handlers.candidateIndex:Invalidate(flag27.Uid, "transaction verified")
												end

												handlers.clearCarryLossRecovery(flag27.Uid)
												v56 = tbl13
												v57 = tbl13
												tbl13.persistentUid = nil
												v56.lockedUid = nil
												v57.lastDroppedUid = nil
												v58 = tbl13
												tbl13.dropDetectedAt = 0
												v58.consecutiveFailures = 0
												critical = false
												handlers.activeGuardAreaId = nil
												v59 = tbl14
												tbl14.critical = false
												v59.stealWants = false
												tbl14.release("Steal")
												tbl14.wakeSeller()
												v60 = pcall
												finishStealTimer = handlers.finishStealTimer
												returnAt = v55.returnAt or os.clock()
												n14 = returnAt - v55.cycleAt
												now4 = os.clock()
												returnAt2 = v55.returnAt or os.clock()
												v60(finishStealTimer, n14, now4 - returnAt2)
												fn11("✅ Egg collected")
											else
												handlers.pauseStealTimer()
												v61 = tbl14
												tbl14.critical = false
												v61.stealWants = false
												tbl14.release("Steal")
												v62 = tbl13
												v63 = tbl13
												lastRequestError2 = tostring(str18)
												v62.lastRequestKind = "standalone"
												v63.lastRequestError = lastRequestError2

												if fn16() then
													fn11("⏳ Wall closed — waiting")

													while true do
														fn18(5, function()
															return not fn16() or not fn45()
														end)

														flag29 = not fn()
														flag30 = flag29 or not fn45()
														flag31 = flag30 or not fn16()
														if not flag31 then
															continue
														end
														break
													end

													task.wait(0.5)
												elseif fn45() then
													v64 = tostring
													str18 = str18 or "movement unavailable"
													v65 = v64(str18)
													v66 = tbl13
													min = math.min
													consecutiveFailures = tbl13.consecutiveFailures
													n15 = consecutiveFailures or 0
													v66.consecutiveFailures = min(n15 + 1, 6)
													tbl18[flag27.Uid] = os.clock() + 10
													n16 = math.min(2 ^ (tbl13.consecutiveFailures - 1), 30)
													fn11(("🔁 Retrying in %ds · %s"):format(n16, v65:sub(1, 100)))
													n17 = os.clock() + n16

													while true do
														flag32 = fn() and fn45() and os.clock() < n17
														if flag32 then
															task.wait(0.25)
															continue
														end
														break
													end
												end
											end
										end
									end
								end
							end
						end

						continue
					elseif exitTo == 15 then
						fn11("🔁 Waiting for egg")
						fn18(0.5)
						continue
					elseif exitTo == 16 then
						tbl15.treadmillSuppressed = true
						tbl14.stealWants = true
						tbl14.stealBeat = os.clock()
						n5 = n4 - os.clock()
						v24, v25 = fn33()
						magnitude = v24 and rec.BottomCFrame and ((v24.Position - rec.BottomCFrame.Position) * Vector3.new(1, 0, 1)).Magnitude or math.huge
						v26 = tostring
						lastRequestKind = tbl13.lastRequestKind or ""
						v27 = v26(lastRequestKind)
						lower = string.lower
						v28 = tostring
						lastRequestError = tbl13.lastRequestError or ""
						v29 = lower(v28(lastRequestError))
						flag6 = v27 == "movement-trust"
						flag7 = flag6 or v27 == "position-sync"
						flag8 = flag7 or v27 == "activity-sync"
						flag9 = flag8 or v27 == "movement-retry" or v27 == "server" or v27 == "retry" or v27 == "carry-loss-sync"
						flag10 = flag9 or v27 == "death-drop-sync" or v27 == "carry-drop"
						flag11 = handlers.activeDroppedRecoveryRecord(rec.Uid) ~= nil
						v30 = v24 and v25
						flag12 = v30 and v25.Health > 0 and tostring(tbl13.requestFailureUid) == tostring(rec.Uid)
						flag13 = flag12 and tostring(tbl13.lockedUid) == tostring(rec.Uid)
						flag10 = flag13 and flag10 and not v29:find("inventory is full", 1, true) and not v29:find("gameplay area", 1, true)

						if flag10 then
							if flag11 then
								flag10 = flag11
							else
								now3 = os.clock()
								num = tonumber(tbl13.requestFailureAt)
								n6 = num or 0
								flag10 = now3 - n6 <= 6
							end
						end

						if flag10 then
							if flag11 then
								flag10 = flag11
							else
								n7 = fn35(v24.Position) or -1
								flag10 = n7 > 0
							end
						end

						if flag10 then
							tbl14.critical = true

							if tbl14.owner ~= "Steal" then
								tbl14.acquireWait("Steal", 0.1)
							end

							v31 = handlers
							retryResumeMode = magnitude <= 8 and "beside-egg" or "current-position"
							v31.retryResumeMode = retryResumeMode
							handlers.retryResumeDistance = magnitude
							handlers.retryResumeUid = rec.Uid
							v32 = fn11
							str2 = v27 == "movement-retry" and "⚡ Movement interrupted · resuming" or magnitude <= 8 and "🥚 Retrying carry…" or "🔁 Resuming carry target…"
							v32(str2)
						else
							tbl14.critical = false
							tbl14.release("Steal")
							fn11("🟡 Target retry pending")
						end

						task.wait(math.min(0.2, math.max(0.03, n5)))
						continue
					elseif exitTo == 17 then
						tbl15.treadmillSuppressed = true
						v67 = tbl14
						tbl14.stealWants = true
						v67.critical = true
						tbl14.stealBeat = os.clock()

						if tbl14.owner ~= "Steal" then
							tbl14.acquireWait("Steal", 0.1)
						end

						v68 = fn11
						str19 = str == "death-drop-sync" and "🔁 Respawned · waiting for dropped egg" or "🥚 Dropped egg syncing · holding recovery"
						v68(str19)
						fn18(0.08)
						continue
					elseif exitTo == 18 then
						tbl15.treadmillSuppressed = true
						tbl14.stealWants = true
						tbl14.stealBeat = os.clock()
						tbl14.release("Steal")
						fn11("🔁 Persistent — waiting for target to drop")
						fn18(0.75)
						continue
					elseif exitTo == 19 then
						tbl15.treadmillSuppressed = true
						local v69 = tbl14
						tbl14.stealWants = true
						v69.critical = true
						tbl14.stealBeat = os.clock()

						if tbl14.owner ~= "Steal" then
							tbl14.acquireWait("Steal", 0.1)
						end

						fn11(("🔁 Respawned · egg syncing %.1fs"):format(n3))
						fn18(0.1)
						continue
					end

					break
				end

				fn43(false)
				fn2(false)
			end, function(arg)
				local ok, result = pcall(debug.traceback, tostring(arg), 2)
				return ok and result or tostring(arg)
			end)

			if fn() then
				if not ok then
					warn("[CloverHub-SAE][steal] worker recovered: " .. tostring(result))
					handlers.movementPhase = nil
					local chsaeCarryRequest = getgenv().__CHSAE_CarryRequest

					if type(chsaeCarryRequest) == "table" and not chsaeCarryRequest.inFlight then
						getgenv().__CHSAE_CarryRequest = nil
					end

					local v20 = fn26()
					critical = v20 ~= nil
					handlers.activeGuardAreaId = v20 and v20.AreaId ~= nil and tostring(v20.AreaId) or nil
					tbl14.critical = false
					tbl14.stealWants = critical
					tbl14.stealBeat = os.clock()
					tbl14.release("Steal")
					tbl15.treadmillSuppressed = critical

					if not critical then
						handlers.pauseStealTimer()
					end

					pcall(fn2, false)
					pcall(fn11, critical and "🟢 Recovering carried egg" or "🟡 Recovering steal worker")
				end

				task.wait(0.25)
				continue
			end

			break
		end
	end)
end

AutoStealToggle:OnChanged(function(autoSteal)
	local flag2 = handlers.automaticStealStop == true
	handlers.automaticStealStop = nil
	tbl2.AutoSteal = autoSteal

	if fn12 then
		fn12(autoSteal and "enabled" or "disabled")
	end

	if tbl2.Stall then
		return
	end

	if autoSteal then
		local v14, v15, v16 = handlers.eggInventoryCapacityState()

		if v14 then
			tbl2.AutoSteal = false
			task.defer(handlers.stopAutoStealForFullInventory, v15, v16, "Your egg inventory is full!")
			return
		end

		handlers.inventoryFullStopped = false
		fn2(true)
		fn11("🟡 Waiting for target")
	else
		if handlers.greatBloomUnlockNeedsCrane() then
			fn11("🔓 Great Bloom · finding Crane egg")

			if fn12 then
				fn12("great-bloom-unlock")
			end

			return
		end

		fn2(false)
		fn13()
		local chsaeCarryRequest = getgenv().__CHSAE_CarryRequest

		if type(chsaeCarryRequest) == "table" and chsaeCarryRequest.inFlight ~= true then
			getgenv().__CHSAE_CarryRequest = nil
		end

		local v14 = tbl14
		tbl14.stealWants = false
		v14.critical = false
		tbl14.release("Steal")
		handlers.pauseStealTimer()
		handlers.set("target", "🎯 Target: none")
		handlers.carry = "📦 Carry: none"
		handlers.activeGuardAreaId = nil
		fn15()
		if flag2 then
			return
		end

		task.spawn(function()
			task.wait()
			if not fn() or tbl2.Stall or tbl2.AutoSteal or critical then
				return
			end
			local v15 = handlers.getStealStart()
			local v16, v17 = fn33()
			if not (v15 and v16 and v17 and v17.Health > 0) then
				return
			end

			if ((v16.Position - v15.Position) * Vector3.new(1, 0, 1)).Magnitude <= 3 then
				return
			end
			tbl14.stealWants = true

			if tbl14.acquireWait("Steal", 1) then
				fn11("↩️ Returning to start")

				handlers.settleClaimAtTrackStart(function()
					return fn() and not tbl2.Stall and not tbl2.AutoSteal and not critical and tbl14.hold("Steal")
				end, v15)

				tbl14.release("Steal")
			end

			tbl14.stealWants = false
			fn15()
		end)
	end
end)

local chsaeDebug = {
	Settings = tbl2,
	GetDevelopmentChickenTween = function()
		local devChickenTween = handlers.DevChickenTween

		return {
			enabled = devChickenTween.enabled,
			phase = devChickenTween.phase,
			reason = devChickenTween.reason,
			persistentHumanoid = devChickenTween.persistentAlive(),
			persistentOriginalAttached = devChickenTween.persistent ~= nil and devChickenTween.persistent.original.Parent == devChickenTween.persistent.character,
			temporaryHumanoid = devChickenTween.lease ~= nil and not devChickenTween.lease.nativeBody,
			nativeBody = devChickenTween.lease ~= nil and devChickenTween.lease.nativeBody == true,
			launches = devChickenTween.launches,
			engine = devChickenTween.engine,
			endpointRecoveries = devChickenTween.endpointRecoveries or 0,
			landingReanchors = devChickenTween.landingReanchors or 0,
		}
	end,
	SetAutoSteal = function(arg)
		AutoStealToggle:SetValue(arg == true)
	end,
	GetEggInventoryCapacity = handlers.eggInventoryCapacityState,
	GetStealClaim = function()
		local stealClaim = handlers.StealClaim
		local current = stealClaim and (stealClaim.current or stealClaim.last)
		local tbl16

		if current then
			tbl16 = {
				uid = current.uid,
				phase = current.phase,
				active = stealClaim.current == current,
				verified = current.proven == true,
				homeDistance = stealClaim.a.homeDistance(),
				held = stealClaim.a.held(current.uid),
				returnResumes = current.returnResumes or 0,
				deadline = current.deadline,
				pickupToReturnSeconds = current.returnTweenAt and current.carryProofAt and math.max(0, current.returnTweenAt - current.carryProofAt),
			}

			local returnTweenAt = current.returnTweenAt
			local returnTravelSeconds

			if returnTweenAt then
				returnTravelSeconds = math.max(0, (current.homeAt or current.finishedAt or current.failedAt or os.clock()) - current.returnTweenAt)
			else
				returnTravelSeconds = returnTweenAt
			end

			tbl16.returnTravelSeconds = returnTravelSeconds
			tbl16.returnSpeed = current.returnSpeed
			tbl16.inFlight = current.request.inFlight
			tbl16.deliveryRejected = current.request.deliveryRejected
		else
			tbl16 = current
		end

		return tbl16 or { phase = "IDLE" }
	end,
	GetState = function()
		local v14, v15 = handlers.wallSpacingInsets()

		local tbl16 = {
			auto = AutoStealToggle.Value == true,
			settingsAuto = tbl2.AutoSteal == true,
			movementType = tbl2.EnableDefaultSpeed and "Default Speed" or tbl2.StealMovementType,
			selectedMovementType = tbl2.StealMovementType,
			enableDefaultSpeed = tbl2.EnableDefaultSpeed,
			wallSpacing = tbl2.StealWallSpacing,
			wallInsetMin = v14,
			wallInsetMax = v15,
			speed = tbl2.StealSpeed,
			effectiveSpeed = handlers.getDeliverySpeed(),
			deliveryWalkFallback = false,
			deliveryRejections = handlers.deliveryRejections or 0,
			lastDeliveryRejectedUid = handlers.lastDeliveryRejectedUid,
			guardFallback = handlers.defaultMoveFallback,
			movementCompatibility = handlers.movementCompatibility,
			wallClosed = fn16(),
			resetActive = fn19(),
			activity = handlers.steal,
			target = handlers.target,
			carry = handlers.carry,
			activeGuardAreaId = handlers.activeGuardAreaId,
			guardRouteSequence = handlers.lastGuardRoutePlan and handlers.lastGuardRoutePlan.Sequence or 0,
			guardRoutePhase = handlers.lastGuardRoutePlan and handlers.lastGuardRoutePlan.Phase or nil,
			guardRouteAreaId = handlers.lastGuardRoutePlan and handlers.lastGuardRoutePlan.ActiveAreaId or nil,
			guardRouteSides = handlers.lastGuardRoutePlan and handlers.lastGuardRoutePlan.SideSignature or nil,
			guardRoutePointCount = handlers.lastGuardRoutePlan and handlers.lastGuardRoutePlan.PointCount or 0,
			guardRouteMissingTarget = handlers.lastGuardRoutePlan and handlers.lastGuardRoutePlan.MissingTargetGuard == true or false,
			treadmill = tbl15.detectActiveTreadmill(),
			treadmillExitInFlight = tbl15.treadmillExitRequest.inFlight,
		}

		local inFlight = tbl15.treadmillExitRequest.inFlight

		if inFlight then
			local startedAt = tbl15.treadmillExitRequest.startedAt
			inFlight = math.max(0, os.clock() - startedAt)
		end

		tbl16.treadmillExitElapsed = inFlight or 0
		tbl16.treadmillExitAccepted = tbl15.treadmillExitRequest.accepted
		tbl16.treadmillExitError = tbl15.treadmillExitRequest.error
		tbl16.bodyOwner = tbl14.owner
		tbl16.bodyYieldTo = tbl14.yieldTo
		tbl16.returnResumeCount = handlers.returnResumeCount
		local lastReturnResumeAge = handlers.lastReturnResumeAt > 0

		if lastReturnResumeAge then
			local lastReturnResumeAt = handlers.lastReturnResumeAt
			lastReturnResumeAge = math.max(0, os.clock() - lastReturnResumeAt)
		end

		tbl16.lastReturnResumeAge = lastReturnResumeAge or 0
		tbl16.lastReturnResumeReason = handlers.lastReturnResumeReason
		tbl16.lastReturnResumeUid = handlers.lastReturnResumeUid
		tbl16.autoPlace = tbl2.AutoPlace == true
		tbl16.placePending = tbl15.placePending == true
		tbl16.placeBusy = tbl14.placeBusy == true
		local placeBeatAge = tbl15.placeBeat > 0

		if placeBeatAge then
			local placeBeat = tbl15.placeBeat
			placeBeatAge = math.max(0, os.clock() - placeBeat)
		end

		tbl16.placeBeatAge = placeBeatAge or 0
		tbl16.autoTreadmill = tbl2.AutoTreadmill == true
		tbl16.treadmillCompatibilityMode = handlers.defaultMoveFallback or v10 == nil
		tbl16.treadmillEntryPhase = tbl15.treadmillEntry and tbl15.treadmillEntry.phase
		tbl16.treadmillEntryReason = tbl15.treadmillEntry and tbl15.treadmillEntry.reason
		tbl16.treadmillBlockReason = tbl15.treadmillBlockReason
		tbl16.treadmillWorkerError = getgenv().__CHSAE_TreadmillWorkerError
		tbl16.treadmillSuppressed = tbl15.treadmillSuppressed == true
		tbl16.treadmillEventPending = tbl15.eventPending == true
		local treadmillIdleAge = tbl15.treadmillIdleSince > 0

		if treadmillIdleAge then
			local treadmillIdleSince = tbl15.treadmillIdleSince
			treadmillIdleAge = math.max(0, os.clock() - treadmillIdleSince)
		end

		tbl16.treadmillIdleAge = treadmillIdleAge or 0
		tbl16.eventActive = handlers.eventActive
		tbl16.autoRift = tbl2.AutoLab == true
		tbl16.priorityEvent = tbl2.PriorityEvent
		tbl16.riftMinimumValue = tbl2.LabMinimumValue
		tbl16.riftCollecting = handlers.riftCollecting == true
		tbl16.riftClaimHandoffUid = handlers.riftClaimHandoffUid
		local riftClaimHandoffAge = handlers.riftClaimHandoffAt > 0

		if riftClaimHandoffAge then
			local riftClaimHandoffAt = handlers.riftClaimHandoffAt
			riftClaimHandoffAge = math.max(0, os.clock() - riftClaimHandoffAt)
		end

		tbl16.riftClaimHandoffAge = riftClaimHandoffAge or nil
		tbl16.riftFieldCount = handlers.riftFieldCount
		tbl16.riftInventoryCount = handlers.riftInventoryCount
		tbl16.adminEventPending = handlers.adminEventPending == true
		tbl16.adminEventActive = handlers.adminEventActive == true
		tbl16.adminEventName = handlers.adminEventName
		tbl16.adminEventFlow = handlers.adminEventFlow
		tbl16.adminEventStatus = handlers.adminEventStatus
		tbl16.adminMonsterActive = handlers.adminMonsterActive == true
		tbl16.bloomFlow = handlers.bloomFlow
		tbl16.bloomEvent = handlers.bloomEvent
		tbl16.greatBloomUnlockEnabled = tbl2.AutoUnlockGreatBloom == true
		tbl16.greatBloomUnlockStage = handlers.greatBloomUnlock.stage
		tbl16.greatBloomUnlockEggUid = handlers.greatBloomUnlock.reservedEggUid
		tbl16.greatBloomUnlockPetUid = handlers.greatBloomUnlock.reservedPetUid
		tbl16.greatBloomUnlockClaimedEggUid = handlers.greatBloomUnlockClaimedEggUid
		local greatBloomUnlockClaimSyncAge = handlers.greatBloomUnlockClaimedAt > 0

		if greatBloomUnlockClaimSyncAge then
			local greatBloomUnlockClaimedAt = handlers.greatBloomUnlockClaimedAt
			greatBloomUnlockClaimSyncAge = math.max(0, os.clock() - greatBloomUnlockClaimedAt)
		end

		tbl16.greatBloomUnlockClaimSyncAge = greatBloomUnlockClaimSyncAge or nil
		tbl16.greatBloomUnlockReturnPending = handlers.greatBloomUnlockReturnPending == true
		tbl16.greatBloomBodyPending = handlers.greatBloomBodyPending == true
		tbl16.greatBloomBodyRunning = handlers.greatBloomBodyRunning == true
		tbl16.greatBloomUnlockLastReturnReason = handlers.greatBloomUnlockLastReturnReason
		tbl16.greatBloomUnlockLastReturnAt = handlers.greatBloomUnlockLastReturnAt
		tbl16.eggSellOverlap = handlers.eggSellOverlap
		tbl16.treadmillBlockedFor = math.max(0, (tonumber(tbl15.treadmillBlockedUntil) or 0) - os.clock())
		tbl16.candidateIndexVersion = handlers.candidateIndex and handlers.candidateIndex.version or 0
		tbl16.candidateCount = handlers.candidateIndex and #handlers.candidateIndex.entries or 0
		tbl16.candidateRebuildMs = handlers.candidateRebuildMs
		tbl16.candidateRebuildMaxMs = handlers.candidateRebuildMaxMs
		tbl16.stealTime = handlers.stealTime
		tbl16.lastStealTime = handlers.stealTimer.last
		tbl16.lastOutboundTime = handlers.stealTimer.outTime
		tbl16.lastReturnTime = handlers.stealTimer.backTime
		tbl16.averageStealTime = handlers.stealTimer.average
		tbl16.timedSteals = handlers.stealTimer.completed
		tbl16.totalStealTime = handlers.stealTimer.total
		tbl16.lockedUid = tbl13.lockedUid
		tbl16.persistentUid = tbl13.persistentUid
		tbl16.lastDroppedUid = tbl13.lastDroppedUid
		tbl16.pendingDroppedUid = handlers.pendingDroppedUid
		tbl16.deathRecoveryUid = tbl13.deathRecoveryUid
		local deathRecoveryAge = tbl13.deathRecoveryAt > 0

		if deathRecoveryAge then
			local deathRecoveryAt = tbl13.deathRecoveryAt
			deathRecoveryAge = math.max(0, os.clock() - deathRecoveryAt)
		end

		tbl16.deathRecoveryAge = deathRecoveryAge or 0
		local deathRecoveryMissingAge = tbl13.deathRecoveryMissingAt > 0

		if deathRecoveryMissingAge then
			local deathRecoveryMissingAt = tbl13.deathRecoveryMissingAt
			deathRecoveryMissingAge = math.max(0, os.clock() - deathRecoveryMissingAt)
		end

		tbl16.deathRecoveryMissingAge = deathRecoveryMissingAge or 0
		tbl16.deathRecoveryMissingReason = tbl13.deathRecoveryMissingReason
		tbl16.lastPositiveCarryUid = tbl13.lastPositiveCarryUid
		local lastPositiveCarryAge = tbl13.lastPositiveCarryAt > 0

		if lastPositiveCarryAge then
			local lastPositiveCarryAt = tbl13.lastPositiveCarryAt
			lastPositiveCarryAge = math.max(0, os.clock() - lastPositiveCarryAt)
		end

		tbl16.lastPositiveCarryAge = lastPositiveCarryAge or 0
		tbl16.cachedDropUid = tbl13.dropRecoveryRecordUid
		local cachedDropAge = tbl13.dropRecoveryRecordAt > 0

		if cachedDropAge then
			local dropRecoveryRecordAt = tbl13.dropRecoveryRecordAt
			cachedDropAge = math.max(0, os.clock() - dropRecoveryRecordAt)
		end

		tbl16.cachedDropAge = cachedDropAge or 0
		tbl16.dropCount = tbl13.dropCount
		local dropAge = tbl13.dropDetectedAt > 0

		if dropAge then
			local dropDetectedAt = tbl13.dropDetectedAt
			dropAge = math.max(0, os.clock() - dropDetectedAt)
		end

		tbl16.dropAge = dropAge or 0
		local flag2 = tbl13.dropDetectedAt > 0

		if flag2 then
			flag2 = (tonumber(handlers.dropReacquireArmedAt) or 0) > 0
		end

		tbl16.dropArmLatency = flag2 and math.max(0, handlers.dropReacquireArmedAt - tbl13.dropDetectedAt) or nil
		tbl16.respawnGeneration = tbl13.respawnGeneration
		tbl16.requestFailureUid = tbl13.requestFailureUid
		local requestFailureAge = tbl13.requestFailureAt > 0

		if requestFailureAge then
			local requestFailureAt = tbl13.requestFailureAt
			requestFailureAge = math.max(0, os.clock() - requestFailureAt)
		end

		tbl16.requestFailureAge = requestFailureAge or 0
		tbl16.retryResumeMode = handlers.retryResumeMode
		tbl16.retryResumeDistance = handlers.retryResumeDistance
		tbl16.retryResumeUid = handlers.retryResumeUid
		tbl16.lastRequestError = tbl13.lastRequestError
		tbl16.lastRequestKind = tbl13.lastRequestKind
		tbl16.releaseVersion = chsaeReleaseVersion
		tbl16.buildId = chsaeBuildId
		tbl16.sameServerRejoinPending = handlers.sameServerRejoinPending == true
		tbl16.lastPickupSettle = tbl13.lastPickupSettle
		tbl16.lastPickupRequiredSettle = tbl13.lastPickupRequiredSettle
		tbl16.lastPickupDistance = tbl13.lastPickupDistance
		tbl16.lastPickupFromTreadmill = tbl13.lastPickupFromTreadmill
		tbl16.attempts = handlers.attempts
		tbl16.carryRequests = handlers.carryRequests
		tbl16.pickupProofRetries = handlers.pickupProofRetries or 0
		tbl16.steals = handlers.steals
		return tbl16
	end,
}

getgenv().__CHSAE_Debug = chsaeDebug
fn15()
local tbl16
tbl16 = nil
local v14
v14 = eggs:AddLeftGroupbox("🥚 Auto-Place")

do
	local v15 = eggs:AddLeftGroupbox("👑 Admin abuse")
	v3.__AdminAbuseBox = v15
	local tbl17 = { speed = false, fly = false, jump = false, airJumpUntil = 0, lastJump = 0, flyRetryAt = 0 }
	local UserInputService = game:GetService("UserInputService")
	local n2 = 28
	local v16 = nil
	local connection = nil
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.RespectCanCollide = true

	local function fn45()
		local v17 = v16
		v16 = nil

		if v17 then
			v17:Stop()
		end
	end

	local function fn46()
		return tbl14.owner ~= nil or tbl2.Stall or not fn()
	end

	local function fn47(arg, arg2)
		local flag2 = not v16

		if flag2 then
			local flyRetryAt = tbl17.flyRetryAt
			flag2 = os.clock() < flyRetryAt
		end

		if flag2 then
			return
		end
		local cFrame = workspace.CurrentCamera and workspace.CurrentCamera.CFrame or arg.CFrame
		local chsaeControls = getgenv().__CHSAE_Controls

		local ok, result = pcall(function()
			return chsaeControls:GetMoveVector()
		end)

		result = ok and typeof(result) == "Vector3" and result or Vector3.zero
		local n3 = cFrame.LookVector * -result.Z + cFrame.RightVector * result.X

		if UserInputService:GetFocusedTextBox() == nil then
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) or arg2.Jump then
				n3 += Vector3.new(0, 1, 0)
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				n3 -= Vector3.new(0, 1, 0)
			end
		end

		local n4 = math.clamp(tonumber(tbl2.ManualWalkSpeed) or 500, 16, 500)
		local speed

		if fn26() then
			speed = math.min(n4, handlers.carrySpeedCap() or n4)
		else
			speed = n4
		end

		local unit = n3.Magnitude > 0.05 and n3.Unit or Vector3.zero
		raycastParams.FilterDescendantsInstances = { arg.Parent }

		if workspace:Raycast(arg.Position, Vector3.new(0, -(arg2.HipHeight + arg.Size.Y / 2 + 2), 0), raycastParams) and unit.Y < 0 then
			unit = Vector3.new(unit.X, 0, unit.Z)
		end

		if v16 and v16.speed ~= speed then
			fn45()
		end

		if not v16 then
			v16 = handlers.newFlight(function()
				return tbl17.flyGoal
			end, 8, speed)

			v16.speed = speed
		end

		tbl17.flyGoal = arg.Position + unit * speed

		if not v16:Step(arg, true, tbl17.flyGoal.Y) then
			local reason = v16.reason
			fn45()
			tbl17.flyRetryAt = os.clock() + (reason == "correcting" and 0.3 or 0.5)
		end
	end

	local function fn48()
		local v17, v18 = fn33()

		if not (v17 and v18 and v18.Health > 0) or fn46() then
			fn45()
			tbl17.airJumpUntil = 0
			return
		end

		if tbl17.fly then
			fn47(v17, v18)
			return
		end
		fn45()
		local assemblyLinearVelocity = v17.AssemblyLinearVelocity
		local vector

		if tbl17.speed then
			local moveDirection = v18.MoveDirection
			local vector2 = Vector3.new(moveDirection.X, 0, moveDirection.Z)

			if not (vector2.Magnitude > 0.05) then
				vector = assemblyLinearVelocity
			else
				local n3 = math.clamp(tonumber(tbl2.ManualWalkSpeed) or 500, 16, 1000)
				local n4

				if fn26() then
					n4 = math.min(n3, handlers.carrySpeedCap() or n3)
				else
					n4 = n3
				end

				local n5 = vector2.Unit * n4 * math.min(1, vector2.Magnitude)
				vector = Vector3.new(n5.X, assemblyLinearVelocity.Y, n5.Z)
			end
		else
			vector = assemblyLinearVelocity
		end

		local flag2 = false
		local flag3 = false
		local n3 = nil
		local v19

		if tbl17.jump then
			local flag4 = v18.FloorMaterial == Enum.Material.Air
			local flag5

			if flag4 then
				local airJumpUntil = tbl17.airJumpUntil
				flag5 = os.clock() < airJumpUntil
			else
				flag5 = flag4
			end

			if flag5 then
				local n4 = math.max(75, 1.5 * (v18.UseJumpPower and v18.JumpPower or math.sqrt(2 * workspace.Gravity * math.max(0, v18.JumpHeight))))
				vector = Vector3.new(vector.X, n4, vector.Z)
				n3 = n4 * n4 / 2 * math.max(1, workspace.Gravity) + 4
				flag2 = true
				flag3 = true
			else
				local flag6 = flag4 and vector.Y < -n2
				n3 = nil

				if flag6 then
					vector = Vector3.new(vector.X, -n2, vector.Z)
					n3 = nil
				end
			end

			if not flag4 then
				tbl17.airJumpUntil = 0
				v19 = vector
			else
				v19 = vector
			end
		else
			v19 = vector
		end

		if (v19 - assemblyLinearVelocity).Magnitude < 0.5 or v19.Magnitude < 1 then
			return
		end

		if fn44(v17, v19.Unit, v19.Magnitude, math.max(24, v19.Magnitude * 1.5), nil, flag2, n3) then
			v17.AssemblyLinearVelocity = v19

			if flag3 then
				tbl17.airJumpUntil = 0
			end
		end
	end

	local function fn49()
		local speed = tbl17.speed or tbl17.fly or tbl17.jump

		if speed and not connection then
			connection = RunService.PreSimulation:Connect(fn48)
			getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = connection
		elseif not speed and connection then
			connection:Disconnect()
			connection = nil
		end

		if not tbl17.fly then
			fn45()
		end
	end

	getgenv().__CHSAE_ManualMoveCleanup = function()
		local v17 = tbl17
		local v18 = tbl17
		tbl17.speed = false
		v17.fly = false
		v18.jump = false
		fn49()
	end

	getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = UserInputService.JumpRequest:Connect(function()
		local v17
		v17, v17 = fn33()
		local flag2 = tbl17.jump and not tbl17.fly and v17 and v17.FloorMaterial == Enum.Material.Air
		local flag3

		if flag2 then
			local lastJump = tbl17.lastJump
			flag3 = os.clock() - lastJump > 0.2
		else
			flag3 = flag2
		end

		if flag3 then
			local v18 = tbl17
			local v19 = tbl17
			local now3 = os.clock()
			local airJumpUntil = os.clock() + 0.3
			v18.lastJump = now3
			v19.airJumpUntil = airJumpUntil
		end
	end)

	local v17 = chk.Slider(v15, "ManualSpeedSlider", {
		Text = "Speed",
		Default = math.clamp(tonumber(tbl2.ManualWalkSpeed) or 500, 16, 1000),
		Min = 16,
		Max = 1000,
		Rounding = 0,
		Suffix = " studs/s",
		Tooltip = "Running speed while Speed is on. Fly uses it up to 500.",
	})

	v17:OnChanged(function(arg)
		tbl2.ManualWalkSpeed = math.clamp(math.floor((tonumber(arg) or 500) + 0.5), 16, 1000)
		fn10(true)
	end)

	for _, v18 in ipairs({
		{
			"ManualSpeedToggle",
			"Speed",
			"speed",
			"Run at the Speed slider value. Pauses while CloverHub moves you. Starts off each session.",
		},
		{
			"ManualFlyToggle",
			"Fly",
			"fly",
			"Fly where the camera faces; Space rises, Left Shift lowers. Passes through walls; lowering stops at the floor. Uses the Speed slider up to 500. Starts off each session.",
		},
		{
			"InfiniteJumpToggle",
			"Infinite Jump",
			"jump",
			"Keep jumping in mid-air to climb, with a slow fall between jumps. Starts off each session.",
		},
	}) do
		v15:AddToggle(v18[1], { Text = v18[2], Default = false, Tooltip = v18[4] }):OnChanged(function(arg)
			tbl17[v18[3]] = arg == true
			fn49()
		end)
	end

	v15:AddToggle("StallToggle", {
		Text = "Stall",
		Default = tbl2.Stall,
		Tooltip = "Picks up the event egg when it is free, then flies it 40 studs up across unlocked egg areas without returning to claim. A manually held egg works too. Starts off each session.",
	}):OnChanged(function(arg)
		tbl2.Stall = arg == true

		if fn12 then
			fn12("stall")
		end
	end)
end

local fn45
local PlaceStatusLabel = nil

chk.Merge(v14, function()
	PlaceStatusLabel = v14:AddLabel("PlaceStatusLabel", { Text = "🔴 Off", DoesWrap = true })
end)

fn45 = function(arg)
	handlers.set("place", "🥚 Pen: " .. tostring(arg):gsub("^[^%w%s]+%s*", ""))
	handlers.setLabel(PlaceStatusLabel, arg)
end

do
	local tbl17 = {}
	local tbl18 = {}

	pcall(function()
		local v15 = pairs
		local mutationNames = tbl12.MutationNames or {}

		for k in v15(mutationNames) do
			if type(k) == "string" and k ~= "None" then
				tbl17[#tbl17 + 1] = k
			end
		end

		table.sort(tbl17)

		for _, v16 in ipairs(tbl17) do
			local str = "#FFFFFF"

			pcall(function()
				local v17 = tbl12.GetMutation(v16)

				if v17 and typeof(v17.Color) == "Color3" then
					str = fn5(v17.Color)
				end
			end)

			tbl18[v16] = ("<font color=\"%s\"><b>%s</b></font>"):format(str, v16)
		end
	end)

	bindDropdownOverlay(v14, "PlaceCategories", "Categories", tbl8.Items, {
		configKey = "PlaceCategories",
		multi = true,
		store = tbl2.PlaceCategories,
		text = "Categories",
		tooltip = "Choose categories. Empty = any.",
		displayMap = tbl8.Display,
		onChange = function()
			if handlers.refreshEggOverlapStatus then
				handlers.refreshEggOverlapStatus()
			end
		end,
	})

	bindDropdownOverlay(v14, "PlaceRarities", "Rarities", tbl4, {
		configKey = "PlaceRarities",
		multi = true,
		store = tbl2.PlaceRarities,
		text = "Rarities",
		tooltip = "Choose rarities. Empty = any.",
		displayMap = tbl5,
		onChange = function()
			if handlers.refreshEggOverlapStatus then
				handlers.refreshEggOverlapStatus()
			end
		end,
	})

	bindDropdownOverlay(v14, "PlaceMutations", "Mutations", tbl17, {
		configKey = "PlaceMutations",
		multi = true,
		store = tbl2.PlaceMutations,
		text = "Mutations",
		tooltip = "Choose mutations. Empty = any.",
		displayMap = tbl18,
		onChange = function()
			if handlers.refreshEggOverlapStatus then
				handlers.refreshEggOverlapStatus()
			end
		end,
	})

	local v15 = progression:AddLeftGroupbox("📖 Auto Pet Index")
	v3.__PetIndexBox = v15

	chk.Merge(v15, function()
		handlers.PetIndex.label = v15:AddLabel("PetIndexStatusLabel", { Text = "🔴 Off", DoesWrap = true })
	end)

	local function fn46()
		handlers.PetIndex.nextAt = 0
		fn10(true)

		if fn12 then
			fn12("pet-index")
		end

		if handlers.wakeRiftPen then
			handlers.wakeRiftPen("pet-index")
		end
	end

	bindDropdownOverlay(v15, "PetIndexAreas", "Areas", tbl6, {
		configKey = "PetIndexAreas",
		multi = true,
		store = tbl2.PetIndexAreas,
		text = "Areas",
		displayMap = tbl7,
		tooltip = "Choose area indexes to complete. Empty = all areas. Reuses owned eggs, then collects missing pets after normal steals and events.",
		onChange = fn46,
	})

	local AutoPetIndexToggle = (function()
	local _t = {Value = tbl2.AutoPetIndex, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.AutoPetIndex = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

	AutoPetIndexToggle:OnChanged(function(arg)
		tbl2.AutoPetIndex = arg == true
		fn46()
	end)
	local v16 = eggs:AddRightGroupbox("🧬 Mutate")
	v3.__MutateBox = v16
	local MutateStatusLabel = nil

	chk.Merge(v16, function()
		MutateStatusLabel = v16:AddLabel("MutateStatusLabel", { Text = "🔴 Off", DoesWrap = true })
	end)

	handlers.setMutateStatus = function(arg)
		handlers.setLabel(MutateStatusLabel, arg)
	end

	local function fn47()
		if handlers.wakeRiftPen then
			handlers.wakeRiftPen("mutate-filter")
		end
	end

	bindDropdownOverlay(v16, "MutateConsumableDropdown", "Consumable", { "Rift", "Scramble" }, {
		configKey = "MutateConsumable",
		multi = false,
		text = "Consumable",
		displayMap = { Rift = "Rift · Fractured", Scramble = "Scramble · Scrambled" },
		get = function()
			return tbl2.MutateConsumable
		end,
		set = function(arg)
			tbl2.MutateConsumable = arg == "Scramble" and "Scramble" or "Rift"
		end,
		onChange = function()
			fn10(true)
			fn47()
		end,
		tooltip = "Use only the selected Mutation consumable. Mutated Only hatching accepts Fractured or Scrambled.",
	})

	bindDropdownOverlay(v16, "MutateCategories", "Categories", tbl8.Items, {
		configKey = "MutateCategories",
		multi = true,
		store = tbl2.MutateCategories,
		text = "Categories",
		displayMap = tbl8.Display,
		tooltip = "Match egg categories. Empty = any; select at least one filter.",
		onChange = fn47,
	})

	bindDropdownOverlay(v16, "MutateRarities", "Rarities", tbl4, {
		configKey = "MutateRarities",
		multi = true,
		store = tbl2.MutateRarities,
		text = "Rarities",
		displayMap = tbl5,
		tooltip = "Match egg rarities. Empty = any.",
		onChange = fn47,
	})

	bindDropdownOverlay(v16, "MutateMutations", "Mutations", tbl17, {
		configKey = "MutateMutations",
		multi = true,
		store = tbl2.MutateMutations,
		text = "Mutations",
		displayMap = tbl18,
		tooltip = "Match mutations already on the egg, not the desired result. Empty = any.",
		onChange = fn47,
	})

	handlers.addValueFilterInput(v16, "MutateMinimumValue", "MutateMinimumValue", "Minimum Value", function(arg)
		if arg ~= "invalid" then
			fn10(true)
		end

		fn47()
	end, "Only mutate placed eggs worth at least this income per second. K, M, B, T work; 0 disables.")

	local AutoMutateToggle = (function()
	local _t = {Value = tbl2.AutoMutate, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.AutoMutate = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

	AutoMutateToggle:OnChanged(function(arg)
		tbl2.AutoMutate = arg == true

		if handlers.resetMutate then
			handlers.resetMutate()
		end

		handlers.setMutateStatus(arg and "🟡 Waiting for pen window" or "🔴 Off")
		fn47()
	end)
end

bindDropdownOverlay(v14, "PlaceOrder", "Order", { "Back → Front", "Front → Back", "Edge → Inward", "Center → Out" }, {
	configKey = "PlaceOrder",
	multi = false,
	text = "Order",
	tooltip = "Choose the fill order.",
	displayMap = {
		["Back → Front"] = "⬆️ <b>Back → Front</b> <font color=\"#9AA0AA\">far first</font>",
		["Front → Back"] = "⬇️ <b>Front → Back</b> <font color=\"#9AA0AA\">near first</font>",
		["Edge → Inward"] = "⬛ <b>Edge → Inward</b> <font color=\"#9AA0AA\">edges first</font>",
		["Center → Out"] = "🎯 <b>Center → Out</b> <font color=\"#9AA0AA\">center first</font>",
	},
	get = function()
		return tbl2.PlaceOrder or "Back → Front"
	end,
	set = function(placeOrder)
		tbl2.PlaceOrder = placeOrder or "Back → Front"
	end,
})

do
	local AutoPlaceToggle = (function()
	local _t = {Value = tbl2.AutoPlace, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.AutoPlace = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

	v14:AddToggle("PlaceInRangeOnlyToggle", {
		Text = "Prevent Snap",
		Default = tbl2.PlaceInRangeOnly,
		Tooltip = "Wait until you are near the pen.",
	}):OnChanged(function(placeInRangeOnly)
		tbl2.PlaceInRangeOnly = placeInRangeOnly

		if tbl2.AutoPlace then
			fn45(placeInRangeOnly and "🟡 Waiting for pen range" or "🟢 Auto-move enabled")
		end
	end)

	local AutoHatchToggle = (function()
	local _t = {Value = tbl2.AutoHatch, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.AutoHatch = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

	local HatchFracturedOnlyToggle = (function()
	local _t = {Value = tbl2.HatchFracturedOnly, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.HatchFracturedOnly = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

	local tbl17 = {
		WakeEvent = Instance.new("BindableEvent"),
		Generation = 0,
		NextCheckAt = 0,
		TimerThread = nil,
		Pending = false,
	}

	local chsaeHatchWake = getgenv().__CHSAE_HatchWake

	if typeof(chsaeHatchWake) == "Instance" then
		pcall(function()
			chsaeHatchWake:Fire("reload")
		end)

		pcall(function()
			chsaeHatchWake:Destroy()
		end)
	end

	local wakeEvent = tbl17.WakeEvent
	getgenv().__CHSAE_HatchWake = wakeEvent

	tbl17.CancelTimer = function()
		local timerThread = tbl17.TimerThread
		tbl17.TimerThread = nil

		if timerThread then
			pcall(task.cancel, timerThread)
		end
	end

	local cancelTimer = tbl17.CancelTimer
	getgenv().__CHSAE_HatchCancel = cancelTimer

	tbl17.Wake = function(arg)
		tbl17.Pending = true
		tbl17.CancelTimer()
		tbl17.NextCheckAt = 0

		if fn() then
			pcall(function()
				local wakeEvent2 = tbl17.WakeEvent
				local fire = wakeEvent2.Fire
				local v15 = arg
				local str

				if arg then
					str = v15
				else
					str = "egg-state"
				end

				fire(wakeEvent2, str)
			end)
		end
	end

	handlers.wakeRiftPen = tbl17.Wake

	tbl17.Wait = function(arg)
		if tbl17.Pending then
			tbl17.Pending = false
			tbl17.NextCheckAt = 0
			task.wait(0.05)
			return
		end

		tbl17.Generation = tbl17.Generation + 1
		local generation = tbl17.Generation
		tbl17.CancelTimer()

		if type(arg) == "number" then
			tbl17.TimerThread = task.delay(math.max(0.05, arg), function()
				if generation == tbl17.Generation and fn() then
					tbl17.TimerThread = nil
					tbl17.Wake("deadline")
				end
			end)
		end

		tbl17.WakeEvent.Event:Wait()
		tbl17.Pending = false
		tbl17.Generation = tbl17.Generation + 1
		tbl17.CancelTimer()
	end

	if tbl11 and tbl11.RuntimeSnapshotUpdated then
		local connection = tbl11.RuntimeSnapshotUpdated:Connect(function()
			tbl17.Wake("snapshot")
		end)

		getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = connection
	end

	if tbl11 and tbl11.RuntimeResetCountdown then
		local connection = tbl11.RuntimeResetCountdown:Connect(function()
			tbl17.Wake("night-credit")
		end)

		getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = connection
	end

	local connection = workspace:GetAttributeChangedSignal("TemporaryGrowthBoosts"):Connect(function()
		tbl17.Wake("growth-boost")
	end)

	getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = connection
	local tbl18 = nil

	pcall(function()
		tbl18 = { GetPlotData = require(ReplicatedStorage.Client.PlotState).ResolvePlot }
	end)

	local function fn46()
		local v15 = nil

		pcall(function()
			v15 = tbl18 and tbl18.GetPlotData()
		end)

		if not v15 then
			return nil
		end
		local petArea = v15.PetArea
		if not (petArea and petArea:IsA("BasePart")) then
			return nil
		end
		local cFrame = petArea.CFrame
		local centerPoint = v15.CenterPoint

		if typeof(centerPoint) ~= "CFrame" then
			if typeof(centerPoint) == "Instance" and centerPoint:IsA("BasePart") then
				centerPoint = centerPoint.CFrame
			else
				centerPoint = cFrame
			end
		end

		return petArea, centerPoint
	end

	local function getIncubatedPlaceCount()
		local v15, v16, v17 = pairs(handlers.incubatedPlaceQueue or {})
		local n2 = 0

		for k in v15, v16, v17 do
			n2 += 1
		end

		return n2
	end

	local n2 = 8

	local function fn47()
		local greatBloomUnlock = handlers.greatBloomUnlock
		if tbl2.AutoUnlockGreatBloom == true and type(greatBloomUnlock) == "table" and greatBloomUnlock.locked == true then
			return greatBloomUnlock.reservedEggUid
		end
		return nil
	end

	local function fn48()
		return fn47() ~= nil
	end

	local function fn49()
		return tbl2.AutoPlace or tbl2.PlaceAfterIncubation and getIncubatedPlaceCount() > 0 or fn48() or handlers.riftEggActive() or handlers.petIndexActive()
	end

	handlers.getIncubatedPlaceCount = getIncubatedPlaceCount

	local function fn50()
		local v15 = fn46()
		local v16 = fn33()
		return v15 ~= nil and v16 ~= nil and (v16.Position - v15.CFrame.Position).Magnitude <= 70
	end

	handlers.placeHigherPriorityPending = function()
		return tbl14.stealBusy() or handlers.normalStealPending() or tbl15.eventPending or handlers.greatBloomUnlockReturnPending == true or tbl14.owner == "Event" or tbl14.owner == "AdminEvent" or tbl14.owner == "ScrambleBoss"
	end

	handlers.updatePlaceReservation = function(arg, arg2)
		local now3 = os.clock()
		local flag2 = not fn49() or handlers.placeHigherPriorityPending()
		local flag3

		if flag2 then
			flag3 = flag2
		else
			flag3 = tbl2.PlaceInRangeOnly and not fn48() and not handlers.riftEggActive() and not handlers.petIndexActive()
		end

		if flag3 or arg2 then
			local v15 = tbl15
			tbl15.placePending = false
			v15.placeClearSince = nil
		elseif arg then
			local v15 = tbl15
			tbl15.placePending = true
			v15.placeClearSince = nil
		elseif tbl15.placePending then
			tbl15.placeClearSince = tbl15.placeClearSince or now3

			if now3 - tbl15.placeClearSince >= 1 then
				tbl15.placePending = false
			end
		end

		tbl15.placeBeat = now3

		if not tbl15.placePending then
			tbl14.release("Place")
		end

		return tbl15.placePending
	end

	handlers.placeBatchPending = function()
		local placePending = tbl15.placePending
		local flag2

		if placePending then
			local placeBeat = tbl15.placeBeat
			flag2 = os.clock() - placeBeat <= tbl15.PLACE_STALE
		else
			flag2 = placePending
		end

		return flag2
	end

	local function fn51()
		if not (fn49() and fn()) then
			return false
		end
		local Place = not handlers.placeHigherPriorityPending() and tbl14.hold("Place")

		if Place then
			tbl15.placeBeat = os.clock()
		end

		return Place
	end

	local function fn52(arg)
		if not handlers.progressionTweenTo then
			return false
		end
		return handlers.progressionTweenTo("Place", arg, 0.35, fn51)
	end

	local function fn53()
		local tbl19 = {}

		pcall(function()
			local v15 = pairs
			local tbl20 = tbl11.GetRuntimeSnapshot() or {}

			for _, v16 in v15(tbl20) do
				if type(v16) == "table" and tostring(v16.OwnerUserId) == tostring(localPlayer.UserId) and v16.Records then
					for _, record in pairs(v16.Records) do
						local localCFrame = type(record.Placement) == "table" and record.Placement.LocalCFrame

						if typeof(localCFrame) == "CFrame" then
							tbl19[#tbl19 + 1] = { x = localCFrame.X, z = localCFrame.Z }
						end
					end
				end
			end
		end)

		return tbl19
	end

	local n3 = 3
	local n4 = 5.5

	local function fn54()
		local v15, v16 = fn46()
		if not (v15 and v16) then
			return nil
		end
		local size = v15.Size
		local huge = math.huge
		local n5 = -math.huge
		local huge2 = math.huge
		local n6 = -math.huge

		for _, v17 in ipairs({ -0.5, 0.5 }) do
			for _, v18 in ipairs({ -0.5, 0.5 }) do
				local v19 = v15.CFrame:PointToWorldSpace(Vector3.new(size.X * v17, 0, size.Z * v18))
				local v20 = v16:PointToObjectSpace(v19)
				huge = math.min(huge, v20.X)
				n5 = math.max(n5, v20.X)
				huge2 = math.min(huge2, v20.Z)
				n6 = math.max(n6, v20.Z)
			end
		end

		return { minx = huge + n3, maxx = n5 - n3, minz = huge2 + n3, maxz = n6 - n3 }, v16
	end

	local function fn55(arg, arg2, arg3)
		if arg2 == "Front → Back" then
			table.sort(arg, function(arg4, arg5)
				if arg4.z ~= arg5.z then
					return arg4.z < arg5.z
				end
				return arg4.x < arg5.x
			end)
		elseif arg2 == "Edge → Inward" then
			local function fn56(arg4)
				return math.min(arg4.x - arg3.minx, arg3.maxx - arg4.x, arg4.z - arg3.minz, arg3.maxz - arg4.z)
			end

			table.sort(arg, function(arg4, arg5)
				return fn56(arg4) < fn56(arg5)
			end)
		elseif arg2 == "Center → Out" then
			local n5 = (arg3.minx + arg3.maxx) / 2
			local n6 = (arg3.minz + arg3.maxz) / 2

			table.sort(arg, function(arg4, arg5)
				return (arg4.x - n5) ^ 2 + (arg4.z - n6) ^ 2 < (arg5.x - n5) ^ 2 + (arg5.z - n6) ^ 2
			end)
		else
			table.sort(arg, function(arg4, arg5)
				if arg4.z ~= arg5.z then
					return arg4.z > arg5.z
				end
				return arg4.x < arg5.x
			end)
		end

		return arg
	end

	local function fn56(arg)
		local v15, v16 = fn54()
		if not v15 then
			return {}, nil
		end
		local tbl19 = {}
		local minz = v15.minz

		while minz <= v15.maxz do
			local minx = v15.minx

			while minx <= v15.maxx do
				tbl19[#tbl19 + 1] = { x = minx, z = minz }
				minx += n4
			end

			minz += n4
		end

		fn55(tbl19, tbl2.PlaceOrder or "Back → Front", v15)
		local tbl20 = {}

		for _, v17 in ipairs(tbl19) do
			local flag2 = true

			for _, v18 in ipairs(arg) do
				if (v17.x - v18.x) ^ 2 + (v17.z - v18.z) ^ 2 < 20 then
					flag2 = false
					break
				end
			end

			if flag2 then
				tbl20[#tbl20 + 1] = v17
			end
		end

		return tbl20, v16
	end

	pcall(function()
		local v15 = GetSaveModule()

		tbl16 = { Get = function()
			return v15.Get()
		end }
	end)

	handlers.externallyHeldPetUid = function()
		local character = localPlayer.Character
		local v15 = ipairs
		character = character and character:GetChildren() or {}

		for _, v16 in v15(character) do
			if v16:IsA("Tool") and v16:GetAttribute("ItemType") == "Asset" and v16 ~= handlers.sellerHeldTool then
				local str = tostring(v16:GetAttribute("UID") or "")
				if str ~= "" then
					return str, v16
				end
			end
		end

		return nil, nil
	end

	handlers.reconcileNewPetUids = function(arg)
		local now3 = os.clock()
		local tbl19 = {}
		local tbl20 = {}
		local tbl21 = {}
		local v15 = arg

		if v15 == nil then
			pcall(function()
				v15 = tbl16 and tbl16.Get()
			end)
		end

		local flag2 = type(v15) == "table" and type(v15.Inventory) == "table"
		local flag3 = false

		if flag2 then
			for k in pairs(v15.Inventory) do
				local str = tostring(k)
				tbl19[str] = true
				tbl20[str] = true
			end

			flag3 = true
		end

		for _, v16 in pairs({ localPlayer.Character, localPlayer:FindFirstChildOfClass("Backpack") }) do
			local v17 = ipairs
			v16 = v16 and v16:GetChildren() or {}

			for _, v18 in v17(v16) do
				if v18:IsA("Tool") and v18:GetAttribute("ItemType") == "Asset" then
					local str = tostring(v18:GetAttribute("UID") or "")

					if str ~= "" then
						tbl19[str] = true
						tbl21[str] = true
					end
				end
			end
		end

		local knownPetUids = handlers.knownPetUids

		if type(knownPetUids) ~= "table" then
			knownPetUids = {}
			handlers.knownPetUids = knownPetUids
		end

		local flag4

		if handlers.petUidBaselineReady ~= true and flag3 and handlers.hatchPetOutputPending ~= true and type(handlers.hatchPetOutputGuard) ~= "table" then
			for k in pairs(tbl19) do
				knownPetUids[k] = {
					Baseline = true,
					SeenInventory = tbl20[k] == true,
					PresentInventory = tbl20[k] == true,
					PresentTool = tbl21[k] == true,
					ProtectedUntil = 0,
				}
			end

			handlers.petUidBaselineReady = true
			flag4 = true
		else
			local flag5 = handlers.petUidBaselineReady ~= true and flag3
			flag4 = false

			if flag5 then
				handlers.petUidBaselineReady = true
			end
		end

		local n5 = 0

		if not flag4 then
			local tbl22 = {}

			for k in pairs(knownPetUids) do
				tbl22[k] = true
			end

			for k in pairs(tbl19) do
				tbl22[k] = true
			end

			for k in pairs(tbl22) do
				local v16 = knownPetUids[k]
				local tbl23

				if type(v16) == "table" then
					tbl23 = v16
				else
					tbl23 = {
						Baseline = v16 == true,
						SeenInventory = false,
						PresentInventory = false,
						PresentTool = false,
						ProtectedUntil = 0,
					}

					knownPetUids[k] = tbl23
				end

				local presentInventory = tbl20[k] == true
				local presentTool = tbl21[k] == true
				local flag5 = tbl23.Baseline ~= true and tbl23.SeenInventory ~= true and tbl23.PresentTool ~= true and (presentInventory or presentTool)

				if flag5 or presentInventory and (tbl23.SeenInventory ~= true or tbl23.PresentInventory ~= true) or presentTool and tbl23.PresentTool ~= true then
					local n6 = now3 + (tonumber(handlers.hatchPetProtectSeconds) or 8)
					tbl23.ProtectedUntil = math.max(tonumber(tbl23.ProtectedUntil) or 0, n6)
					handlers.hatchProtectedPetUids[k] = tbl23.ProtectedUntil

					if flag5 then
						n5 += 1
					end
				end

				if presentInventory then
					tbl23.SeenInventory = true
					tbl23.LastInventoryAt = now3
				end

				if flag3 then
					tbl23.PresentInventory = presentInventory
				end

				tbl23.PresentTool = presentTool
			end
		end

		local hatchPetOutputGuard = handlers.hatchPetOutputGuard

		if type(hatchPetOutputGuard) == "table" then
			if (tonumber(hatchPetOutputGuard.ExpiresAt) or 0) <= now3 then
				handlers.hatchPetOutputPending = false
				handlers.hatchPetOutputGuard = nil
			end
		else
			local flag5 = handlers.hatchPetOutputPending == true

			if flag5 then
				flag5 = now3 >= (tonumber(handlers.hatchPetGuardUntil) or 0)
			end

			if flag5 then
				handlers.hatchPetOutputPending = false
			end
		end

		local v16 = handlers.externallyHeldPetUid()

		for k, hatchProtectedPetUid in pairs(handlers.hatchProtectedPetUids) do
			if now3 >= (tonumber(hatchProtectedPetUid) or 0) and k ~= v16 then
				handlers.hatchProtectedPetUids[k] = nil
			end
		end

		return n5, flag3
	end

	handlers.ensurePetUidBaseline = function()
		handlers.reconcileNewPetUids()
		return handlers.petUidBaselineReady == true
	end

	handlers.noteHatchPetOutputAttempt = function()
		handlers.reconcileNewPetUids()
		if handlers.petUidBaselineReady ~= true then
			return false
		end
		local now3 = os.clock()
		local hatchPetOutputGuard = handlers.hatchPetOutputGuard

		if type(hatchPetOutputGuard) ~= "table" then
			hatchPetOutputGuard = { ExpiresAt = 0 }
			handlers.hatchPetOutputGuard = hatchPetOutputGuard
		end

		hatchPetOutputGuard.ExpiresAt = now3 + (tonumber(handlers.hatchPetResolveSeconds) or 8)
		handlers.hatchPetOutputPending = true
		handlers.hatchPetGuardUntil = math.max(tonumber(handlers.hatchPetGuardUntil) or 0, hatchPetOutputGuard.ExpiresAt)
		return true
	end

	handlers.petSellUidProtected = function(arg, arg2, arg3)
		local str = tostring(arg or "")
		if str == "" then
			return true
		end

		if handlers.riftPetReserved(str) then
			return true
		end

		if arg3 ~= true then
			handlers.reconcileNewPetUids(arg2)
		end

		local n5 = tonumber(handlers.hatchProtectedPetUids[str]) or 0
		if os.clock() < n5 then
			return true
		end
		local v15 = handlers.externallyHeldPetUid()
		return v15 ~= nil and v15 == str
	end

	handlers.hatchPetSaleGuardActive = function()
		local flag2 = handlers.hatchPetOutputPending == true
		local flag3

		if flag2 then
			flag3 = flag2
		else
			flag3 = os.clock() < (tonumber(handlers.hatchPetGuardUntil) or 0)
		end

		return flag3 or handlers.externallyHeldPetUid() ~= nil
	end

	local function fn57()
		local n5 = #fn53()
		local baseUpgradeLevel = nil

		pcall(function()
			local v15 = tbl16 and tbl16.Get()

			if type(v15) == "table" then
				baseUpgradeLevel = v15.BaseUpgradeLevel
			end
		end)

		return n5, nil, baseUpgradeLevel
	end

	local n5 = nil
	local v15 = nil

	local function fn58()
		local v16, v17, v18 = fn57()
		n5 = v16
		v15 = v18
	end

	local function fn59()
		local v16, v17, v18 = fn57()

		if n5 and (v18 ~= v15 or v16 < n5) then
			n5 = nil
			v15 = nil
		end

		if n5 then
			n5 = math.max(n5, v16)
		end

		return v16, v17, v18, n5 ~= nil and v18 == v15 and v16 >= n5
	end

	local function fn60()
		local tbl19 = {}

		pcall(function()
			local v16 = pairs
			local tbl20 = tbl11.GetRuntimeSnapshot() or {}

			for _, v17 in v16(tbl20) do
				if type(v17) == "table" and tostring(v17.OwnerUserId) == tostring(localPlayer.UserId) and v17.Records then
					for k, record in pairs(v17.Records) do
						if type(record.Placement) == "table" and record.Placement.LocalCFrame ~= nil then
							tbl19[k] = true
						end
					end
				end
			end
		end)

		return tbl19
	end

	local function fn61(arg)
		local v16 = pairs
		arg = arg or {}

		for _, v17 in v16(arg) do
			if v17 == true then
				return true
			end
		end

		return false
	end

	local function fn62(arg, arg2, arg3, arg4, arg5, arg6)
		if type(arg) ~= "table" then
			return false, false
		end
		local v16 = fn61(arg2)
		local v17 = fn61(arg3)
		local v18 = fn61(arg4)
		local v19 = handlers.kgFilterActive(arg5, arg6)
		if not (v16 or v17 or v18 or v19) then
			return true, false
		end
		local str = tostring(arg.AssetCategory or arg.Category or "")
		local id = nil

		pcall(function()
			local rarity = Assets.Directory[str].Rarity
			id = type(rarity) == "table" and rarity._id or rarity
		end)

		local flag2 = not v18

		if v18 then
			local v20 = pairs
			local mutations = arg.Mutations or {}

			for _, mutation in v20(mutations) do
				if arg4[mutation] then
					flag2 = true
					break
				end
			end
		end

		return (not v16 or arg2[str] == true) and (not v17 or id and arg3[id] == true) and flag2 and (not v19 or handlers.kgFilterMatches(arg, arg5, arg6)), true
	end

	local tbl19 = { nextAt = 0, completed = {}, pending = false, beat = 0 }

	pcall(function()
		tbl19.remote = require(ReplicatedStorage.Shared.Remotes).BossMastery.AskUseMutationConsumable
	end)

	tbl19.selection = function()
		if tbl2.MutateConsumable == "Scramble" then
			return "Scrambled", "Scramble", "Scrambled"
		end
		return "Boss", "BossMastery", "Fractured"
	end

	tbl19.stock = function()
		local v16 = tbl19.selection()
		local n6 = 0

		for _, v17 in pairs({ localPlayer.Character, localPlayer:FindFirstChildOfClass("Backpack") }) do
			for _, child in ipairs(v17:GetChildren()) do
				local flag2 = child:IsA("Tool") and child:GetAttribute("ItemType") == "MutationConsumable"

				if flag2 then
					flag2 = (child:GetAttribute("MutationId") or "Boss") == v16
				end

				if flag2 then
					n6 = math.max(n6, tonumber(child:GetAttribute("Uses")) or 0)
				end
			end
		end

		return n6
	end

	tbl19.matches = function(arg, arg2)
		local v16 = tbl19.selection()
		local chsaeMutateRequest = getgenv().__CHSAE_MutateRequest
		local flag2 = chsaeMutateRequest and chsaeMutateRequest.uid == arg

		if flag2 then
			flag2 = chsaeMutateRequest.inFlight or chsaeMutateRequest.uncertain

			if not flag2 then
				flag2 = chsaeMutateRequest.mutated

				if flag2 then
					flag2 = (chsaeMutateRequest.mutation or "Boss") == v16
				end
			end
		end

		if flag2 then
			return false
		end

		if not tbl2.AutoMutate or not tbl19.remote or tbl19.fault or tbl19.completed[arg] == v16 or type(arg2) ~= "table" or arg2.IsHatching or type(arg2.Placement) ~= "table" or typeof(arg2.Placement.LocalCFrame) ~= "CFrame" or arg == fn47() or handlers.labEggReserved(arg) then
			return false
		end
		local v17 = pairs
		local mutations = arg2.Mutations or {}

		for _, mutation in v17(mutations) do
			if mutation == v16 then
				return false
			end
		end

		local v18, v19 = fn62(arg2, tbl2.MutateCategories, tbl2.MutateRarities, tbl2.MutateMutations)
		if not (v19 and v18) then
			return false
		end
		local n6 = tonumber(tbl2.MutateMinimumValue) or 0

		if n6 > 0 then
			local v20, v21 = riftValueScore(arg2)
			if not v21 or v20 < n6 then
				return false
			end
		end

		return true
	end

	tbl19.target = function()
		if tbl19.stock() <= 0 then
			return nil
		end
		local v16 = pairs
		local tbl20 = tbl11 and tbl11.GetRuntimeSnapshot() or {}

		for _, v17 in v16(tbl20) do
			if tostring(v17.OwnerUserId) ~= tostring(localPlayer.UserId) then
				continue
			end
			local v18 = pairs
			local records = v17.Records or {}

			for k, record in v18(records) do
				if tbl19.matches(k, record) then
					return k, record
				end
			end
		end
	end

	tbl19.blocked = function()
		return not fn() or not tbl2.AutoMutate or critical or fn26() ~= nil or tbl14.critical or handlers.placeHigherPriorityPending() or tbl14.placeBusy or handlers.placeBatchPending()
	end

	tbl19.cleanup = function()
		local tool = tbl19.tool
		local character = tbl19.character
		local v16 = tbl19
		tbl19.tool = nil
		v16.character = nil

		if tool and tool.Parent == character then
			local backpack = localPlayer:FindFirstChildOfClass("Backpack")

			if backpack then
				pcall(function()
					tool.Parent = backpack
				end)
			end
		end

		if tbl19.busy then
			local v17 = tbl14
			tbl14.petsBusy = false
			v17.remoteActivity = nil
			tbl19.busy = false
		end

		tbl19.pending = false
		tbl14.release("Mutate")
	end

	local cleanup = tbl19.cleanup
	getgenv().__CHSAE_MutateCleanup = cleanup

	handlers.resetMutate = function()
		local v16 = tbl19
		local v17 = tbl19
		tbl19.nextAt = 0
		v16.fault = nil
		v17.pending = false
		local chsaeMutateRequest = getgenv().__CHSAE_MutateRequest

		if chsaeMutateRequest and not chsaeMutateRequest.inFlight then
			chsaeMutateRequest.uncertain = false
		end
	end

	handlers.mutateBatchPending = function()
		local pending = tbl19.pending

		if pending then
			local beat = tbl19.beat
			pending = os.clock() - beat < 8
		end

		return pending and not tbl19.blocked()
	end

	handlers.mutateBeforeHatch = function(arg, arg2)
		local chsaeMutateRequest = getgenv().__CHSAE_MutateRequest
		if chsaeMutateRequest and chsaeMutateRequest.uid == arg and (chsaeMutateRequest.inFlight or chsaeMutateRequest.uncertain) then
			return true
		end
		local mutations = type(arg2.Mutations) == "table" and arg2.Mutations or {}

		if tbl2.HatchFracturedOnly then
			if table.find(mutations, "Boss") or table.find(mutations, "Scrambled") then
				return false
			end
			local v16, v17 = fn62(arg2, tbl2.MutateCategories, tbl2.MutateRarities, tbl2.MutateMutations)
			if v16 and v17 then
				return true
			end
		end

		return tbl2.AutoMutate and tbl19.stock() > 0 and tbl19.matches(arg, arg2)
	end

	tbl19.valid = function()
		return not tbl19.blocked() and not tbl19.fault and tbl14.hold("Mutate") and (not tbl19.busy or tbl19.activeMutation == tbl19.selection())
	end

	tbl19.attempt = function(arg)
		if not tbl19.valid() or not tbl15.requestTreadmillExit() or not tbl19.valid() then
			return
		end
		local v16, v17 = fn46()
		local v18 = pairs
		local tbl20 = tbl11.GetRuntimeSnapshot() or {}
		local v19 = nil

		for _, v20 in v18(tbl20) do
			if tostring(v20.OwnerUserId) == tostring(localPlayer.UserId) then
				v19 = (v20.Records or {})[arg]
				break
			else
				v19 = nil
			end
		end

		if not v17 or not tbl19.matches(arg, v19) then
			return
		end
		local v20, v21 = fn33()
		if not v20 or not v21 or v21.Health <= 0 then
			return
		end
		local v22 = fn35(v20.Position)

		if v22 and v22 > 0 then
			if not handlers.settleClaimAtTrackStart(tbl19.valid) then
				return
			end
		end

		local v23 = v17:PointToWorldSpace(v19.Placement.LocalCFrame.Position)
		handlers.setMutateStatus("🏡 Moving to matching egg")
		if not handlers.progressionTweenTo("Mutate", v23, 1, tbl19.valid) or not tbl19.valid() then
			return
		end
		local v24, v25 = fn33()
		if not v24 or not v25 or v25.Health <= 0 then
			return
		end
		local character = localPlayer.Character
		local backpack = localPlayer:FindFirstChildOfClass("Backpack")
		local v26 = nil

		for _, v27 in ipairs({ character, backpack }) do
			for _, child in ipairs(v27:GetChildren()) do
				local flag2 = child:IsA("Tool") and child:GetAttribute("ItemType") == "MutationConsumable"

				if flag2 then
					flag2 = (child:GetAttribute("MutationId") or "Boss") == tbl19.activeMutation
				end

				if flag2 then
					v26 = child
					break
				end
			end

			if not v26 then
				continue
			end
			break
		end

		if not v26 then
			handlers.setMutateStatus("🟡 Waiting for consumable tool")
			return
		end
		local v27 = tbl19
		tbl19.tool = v26
		v27.character = character
		v25:EquipTool(v26)
		task.wait(0.15)
		local flag2 = not tbl19.valid() or v26.Parent ~= character or tbl19.stock() <= 0

		if not flag2 then
			flag2 = (v26:GetAttribute("MutationId") or "Boss") ~= tbl19.activeMutation
		end

		if flag2 then
			return
		end
		local v28 = pairs
		local tbl21 = tbl11.GetRuntimeSnapshot() or {}
		local v29 = nil

		for _, v30 in v28(tbl21) do
			if tostring(v30.OwnerUserId) == tostring(localPlayer.UserId) then
				v29 = (v30.Records or {})[arg]
				break
			else
				v29 = nil
			end
		end

		if not tbl19.matches(arg, v29) then
			return
		end
		local v30, v31, v32 = tbl19.selection()
		handlers.setMutateStatus("🧬 Applying " .. v32)
		local chsaeMutateRequest = getgenv().__CHSAE_MutateRequest
		if chsaeMutateRequest and chsaeMutateRequest.inFlight then
			return
		end
		local chsaeMutateRequest2 = { uid = arg, mutation = tbl19.activeMutation, inFlight = true }
		getgenv().__CHSAE_MutateRequest = chsaeMutateRequest2

		local ok, result = pcall(function()
			return tbl19.remote:InvokeServer(arg)
		end)

		chsaeMutateRequest2.inFlight = false
		chsaeMutateRequest2.uncertain = not ok or type(result) ~= "table" or result.Success == true and type(result.Mutated) ~= "boolean" or type(result) == "table" and result.MutationId ~= nil and result.MutationId ~= chsaeMutateRequest2.mutation
		chsaeMutateRequest2.mutated = ok and type(result) == "table" and result.Mutated == true
		if not fn() then
			return
		end
		tbl19.nextAt = os.clock() + 3

		if chsaeMutateRequest2.uncertain then
			tbl19.fault = "Unconfirmed response; toggle Auto-Mutate to retry"
			handlers.setMutateStatus("⚠️ " .. tbl19.fault)
		elseif result.Success ~= true then
			tbl19.nextAt = os.clock() + 10
			handlers.setMutateStatus("🟡 " .. tostring(result.Message or "Consumable rejected"))
		elseif result.Mutated == true then
			tbl19.completed[arg] = chsaeMutateRequest2.mutation
			handlers.setMutateStatus("🟢 " .. v32 .. " applied")
		else
			handlers.setMutateStatus("🟡 Fizzled · retrying in 3s")
		end
	end

	tbl19.step = function()
		local v16 = tbl19
		local v17 = tbl19
		local now3 = os.clock()
		v16.pending = false
		v17.beat = now3
		if not tbl2.AutoMutate then
			return
		end
		local chsaeMutateRequest = getgenv().__CHSAE_MutateRequest

		if chsaeMutateRequest then
			chsaeMutateRequest = chsaeMutateRequest.inFlight or chsaeMutateRequest.uncertain
		end

		if chsaeMutateRequest then
			handlers.setMutateStatus("⚠️ Previous mutation unconfirmed; check egg before retrying")
			return
		end

		if tbl19.fault then
			handlers.setMutateStatus("⚠️ " .. tbl19.fault)
			return
		end

		if not tbl19.remote then
			handlers.setMutateStatus("⚠️ Mutation unavailable")
			return
		end

		if tbl19.blocked() then
			handlers.setMutateStatus("⏸️ Waiting for placement / higher priority")
			return
		end

		if tbl19.stock() <= 0 then
			handlers.setMutateStatus("🟡 No Mutation consumables")
			return
		end
		local v18 = tbl19.target()

		if not v18 then
			local v19, v20, v21 = tbl19.selection()
			local v22 = pairs
			local tbl20 = tbl11 and tbl11.GetRuntimeSnapshot() or {}
			local n6 = 0

			for _, v23 in v22(tbl20) do
				if tostring(v23.OwnerUserId) == tostring(localPlayer.UserId) then
					local v24 = pairs
					local records = v23.Records or {}

					for _, record in v24(records) do
						local flag2 = type(record.Placement) == "table"

						if flag2 then
							flag2 = table.find(record.Mutations or {}, v19)
						end

						if flag2 then
							local v25, v26 = fn62(record, tbl2.MutateCategories, tbl2.MutateRarities, tbl2.MutateMutations)

							if v25 and v26 then
								n6 += 1
							end
						end
					end
				end
			end

			handlers.setMutateStatus(n6 > 0 and "🟢 All matching placed eggs already " .. v21 or "🟡 No matching placed eggs · select filters")
			return
		end

		tbl19.pending = true
		local nextAt = tbl19.nextAt
		if os.clock() < nextAt or tbl14.petsBusy or tbl14.hatchBusy then
			return
		end

		if not tbl14.acquire("Mutate") then
			return
		end
		tbl19.activeMutation = tbl19.selection()
		local v19 = tbl14
		local v20 = tbl14
		tbl19.busy = true
		v19.petsBusy = true
		v20.remoteActivity = "Mutating eggs"
		tbl19.nextAt = os.clock() + 3
		local ok, result = pcall(tbl19.attempt, v18)
		tbl19.cleanup()
		if not fn() then
			return
		end

		if not ok then
			tbl19.fault = "Mutation error; toggle Auto-Mutate to retry"
			handlers.setMutateStatus("⚠️ " .. tbl19.fault)
			warn("[CloverHub] Mutate: " .. tostring(result))
		end

		tbl19.pending = not tbl19.fault and not tbl19.blocked() and tbl19.target() ~= nil
		tbl19.beat = os.clock()
	end

	if getgenv().__CHSAE_Debug then
		getgenv().__CHSAE_Debug.SetCarrySpeedMultiplier = function(arg)
			handlers.carrySpeedMultiplier = math.clamp(tonumber(arg) or 1, 0.5, 4)
			return handlers.carrySpeedMultiplier, handlers.carrySpeedCap()
		end

		getgenv().__CHSAE_Debug.GetMutate = function()
			return {
				enabled = tbl2.AutoMutate,
				target = tbl19.target(),
				stock = tbl19.stock(),
				pending = handlers.mutateBatchPending(),
				busy = tbl19.busy == true,
				fault = tbl19.fault,
				nextAt = tbl19.nextAt,
			}
		end
	end

	local function fn63()
		local tbl20 = {}
		local tbl21 = {}
		local v16 = fn60()
		local v17 = nil

		pcall(function()
			v17 = tbl16 and tbl16.Get()
		end)

		local eggInventory = type(v17) == "table" and type(v17.EggInventory) == "table" and v17.EggInventory or {}
		local v18 = fn47()

		if v18 ~= nil then
			if eggInventory[v18] ~= nil and not v16[v18] then
				return { v18 }
			end
			return tbl20
		end

		for k in pairs(handlers.riftReservedEggs) do
			if handlers.riftEggReserved(k) and eggInventory[k] and not v16[k] then
				tbl20[#tbl20 + 1] = k
				tbl21[k] = true
			end
		end

		if handlers.petIndexActive() then
			for k in pairs(handlers.PetIndex.eggs) do
				if eggInventory[k] and not v16[k] and not tbl21[k] then
					tbl20[#tbl20 + 1] = k
					tbl21[k] = true
				end
			end
		end

		table.sort(tbl20)
		local tbl22 = {}
		local flag2 = false

		if tbl2.PlaceAfterIncubation then
			local now3 = os.clock()

			for k, v19 in pairs(handlers.incubatedPlaceQueue) do
				local num = tonumber(v19) or now3

				if v16[k] then
					handlers.incubatedPlaceQueue[k] = nil
				elseif eggInventory[k] ~= nil then
					tbl22[#tbl22 + 1] = { uid = k, at = num }
				elseif n2 < now3 - num then
					handlers.incubatedPlaceQueue[k] = nil
				else
					flag2 = true
				end
			end

			table.sort(tbl22, function(arg, arg2)
				if arg.at ~= arg2.at then
					return arg.at < arg2.at
				end
				return tostring(arg.uid) < tostring(arg2.uid)
			end)

			for _, v19 in ipairs(tbl22) do
				tbl20[#tbl20 + 1] = v19.uid
				tbl21[v19.uid] = true
			end
		end

		if tbl2.AutoPlace and not flag2 then
			for k, v19 in pairs(eggInventory) do
				local flag3 = not v16[k] and not tbl21[k]

				if flag3 then
					local labEggReserved = handlers.labEggReserved
					local flag4 = type(v19) == "table"
					local assetCategory

					if flag4 then
						assetCategory = v19.AssetCategory or v19.Category
					else
						assetCategory = flag4
					end

					assetCategory = assetCategory or nil
					flag3 = not labEggReserved(k, assetCategory)
				end

				if flag3 then
					local v20, v21 = fn62(v19, tbl2.PlaceCategories, tbl2.PlaceRarities, tbl2.PlaceMutations)

					if not v21 or v20 then
						tbl20[#tbl20 + 1] = k
					end
				end
			end
		end

		return tbl20
	end

	handlers.getAutoPlaceEggPolicy = function()
		local tbl20 = {}
		if not fn49() then
			return tbl20, false, false
		end

		for _, v16 in ipairs(fn63()) do
			tbl20[tostring(v16)] = true
		end

		local flag2 = select(4, fn59()) == true
		return tbl20, not flag2, flag2
	end

	local function fn64()
		if not fn51() then
			return 0, 0, false, "interrupted"
		end
		local v16 = fn63()
		if #v16 == 0 then
			return 0, 0, false
		end
		local v17, v18, v19, v20 = fn59()
		if v20 then
			return 0, #v16, true, "full"
		end
		local v21, v22 = fn46()
		local v23 = fn33()

		if v21 and v23 and (v23.Position - v21.CFrame.Position).Magnitude > 70 then
			if tbl2.PlaceInRangeOnly and not fn48() and not handlers.riftEggActive() and not handlers.petIndexActive() then
				return 0, #v16, false, "range"
			end
			local v24 = fn35(v23.Position)

			if v24 ~= nil and v24 > 0 then
				fn45("↩️ Returning to TrackStart")
				if not handlers.settleClaimAtTrackStart(fn51) then
					return 0, #v16, false, "interrupted"
				end

				if not fn51() then
					return 0, #v16, false, "interrupted"
				end

				if not fn33() then
					return 0, #v16, false, "interrupted"
				end
			end

			fn45("🏡 Moving to pen")
			if not fn52(v21.CFrame.Position) then
				return 0, #v16, false, "interrupted"
			end
			task.wait(0.35)
		end

		local v24 = fn53()
		local v25 = fn56(v24)
		if #v25 == 0 then
			fn58()
			return 0, #v16, true, "full"
		end
		local n6 = 1
		local n7 = 1
		local n8 = 0
		local n9 = 0
		local flag2 = false
		local exitTo = nil

		while true do
			if n6 <= #v16 and n7 <= #v25 then
				if not fn51() then
					exitTo = 2
					break
				elseif n9 >= 40 then
					exitTo = 1
					break
				else
					local v26 = v16[n6]
					local v27 = nil

					pcall(function()
						v27 = tbl11.RequestEquipTool(v26)
					end)

					if not fn51() then
						exitTo = 3
						break
					else
						local n10

						if v27 ~= true then
							n6 += 1
							n10 = n9
							n9 = n10
							continue
						else
							task.wait(0.15)

							if not fn51() then
								exitTo = 4
								break
							else
								local v28 = v25[n7]
								local v29 = nil
								local v30 = nil

								pcall(function()
									local v31, v32 = tbl11.RequestPlaceEgg(v26, CFrame.new(v28.x, -0.5, v28.z))
									v29 = v31
									v30 = v32
								end)

								local n11, v31, str, v32, str2, pos, pos2

								if v29 ~= true and v22 and tostring(v30):find("closer") then
									if not tbl2.PlaceInRangeOnly then
										if not fn52(v22:PointToWorldSpace(Vector3.new(v28.x, -0.5, v28.z))) then
											exitTo = 5
											break
										else
											task.wait(0.2)

											if fn51() then
												pcall(function()
													local v33, v34 = tbl11.RequestPlaceEgg(v26, CFrame.new(v28.x, -0.5, v28.z))
													v29 = v33
													v30 = v34
												end)

												if v29 == true then
													n8 += 1
													handlers.incubatedPlaceQueue[v26] = nil
													v17 += 1
													n11 = #v24 + 1
													v24[n11] = { x = v28.x, z = v28.z }
													n6 += 1
													n7 += 1
													n10 = 0
												else
													v31 = tostring
													str = v30 or ""
													v32 = v31(str)
													str2 = v32:lower()
													pos = str2:find("full", 1, true) or str2:find("maximum", 1, true)
													pos2 = pos or str2:find("max egg", 1, true)

													if pos2 then
														n10 = 40
													else
														n7 += 1
														n10 = n9 + 1
													end
												end

												fn6(0.1, 0.18)
												n9 = n10
												continue
											end
										end
									else
										flag2 = true

										if v29 == true then
											n8 += 1
											handlers.incubatedPlaceQueue[v26] = nil
											v17 += 1
											n11 = #v24 + 1
											v24[n11] = { x = v28.x, z = v28.z }
											n6 += 1
											n7 += 1
											n10 = 0
										else
											v31 = tostring
											str = v30 or ""
											v32 = v31(str)
											str2 = v32:lower()
											pos = str2:find("full", 1, true) or str2:find("maximum", 1, true)
											pos2 = pos or str2:find("max egg", 1, true)

											if pos2 then
												n10 = 40
											else
												n7 += 1
												n10 = n9 + 1
											end
										end

										fn6(0.1, 0.18)
										n9 = n10
										continue
									end
								else
									if v29 == true then
										n8 += 1
										handlers.incubatedPlaceQueue[v26] = nil
										v17 += 1
										n11 = #v24 + 1
										v24[n11] = { x = v28.x, z = v28.z }
										n6 += 1
										n7 += 1
										n10 = 0
									else
										v31 = tostring
										str = v30 or ""
										v32 = v31(str)
										str2 = v32:lower()
										pos = str2:find("full", 1, true) or str2:find("maximum", 1, true)
										pos2 = pos or str2:find("max egg", 1, true)

										if pos2 then
											n10 = 40
										else
											n7 += 1
											n10 = n9 + 1
										end
									end

									fn6(0.1, 0.18)
									n9 = n10
									continue
								end
							end
						end
					end
				end
			else
				exitTo = 1
				break
			end

			break
		end

		if exitTo == 1 then
			local flag3 = (n9 >= 40 or n7 > #v25 and n8 > 0) and not flag2

			if flag3 then
				fn58()
			elseif n8 > 0 then
				n5 = nil
				v15 = nil
			end

			return n8, #v16, flag3, flag3 and "full" or flag2 and "range" or nil
		end

		if exitTo == 2 then
			return n8, #v16, false, "interrupted"
		end

		if exitTo == 3 then
			return n8, #v16, false, "interrupted"
		end

		if exitTo == 4 then
			return n8, #v16, false, "interrupted"
		end

		if exitTo == 5 then
			return n8, #v16, false, "interrupted"
		end
		return n8, #v16, false, "interrupted"
	end

	local function fn65()
		if tbl14.placeBusy then
			return 0, 0, false
		end
		tbl14.placeBusy = true
		local ok, result, result2, result3, result4 = pcall(fn64)
		tbl14.placeBusy = false

		if handlers.refreshEggOverlapStatus then
			task.defer(handlers.refreshEggOverlapStatus)
		end

		if not ok then
			warn("[CloverHub] place pass error: " .. tostring(result))
			return 0, 0, false, "error"
		end
		return result, result2, result3, result4
	end

	local function fn66()
		if not tbl14.hatchOk() then
			return 0, nil, "busy"
		end
		tbl14.hatchBusy = true
		local n6 = 0
		local n7 = nil

		local ok, result = pcall(function()
			local tbl20 = tbl11.GetRuntimeSnapshot()
			local v16 = pairs
			tbl20 = tbl20 or {}
			local v17 = nil

			for _, v18 in v16(tbl20) do
				if type(v18) == "table" and tostring(v18.OwnerUserId) == tostring(localPlayer.UserId) then
					v17 = v18
					break
				else
					v17 = nil
				end
			end

			local v18 = fn47()
			local v19 = handlers.petIndexActive()
			local autoHatch = tbl2.AutoHatch or v18 ~= nil or handlers.riftEggActive() or v19

			if v17 and v17.Records then
				for k, record in pairs(v17.Records) do
					if not (not (autoHatch and fn()) or tbl14.owner == "Place" or tbl14.placeBusy or tbl14.petsBusy or not handlers.ensurePetUidBaseline()) then
						if not (v18 ~= nil and tostring(k) ~= tostring(v18)) then
							if not tbl2.AutoHatch and v18 == nil and not handlers.riftEggReserved(k) then
								if v19 == nil then
									v19 = handlers.petIndexActive()
								end

								if not (v19 and handlers.petIndexReserved(k)) then
									continue
								end
							end

							if not handlers.mutateBeforeHatch(k, record) then
								local flag2 = false

								pcall(function()
									flag2 = tbl11.IsLocalEggReady(k)
								end)

								if flag2 then
									local ok, result = pcall(tbl11.RequestHatchEgg, k)
									ok = ok and result == true
									local flag3 = false
									local flag4 = false

									if ok then
										if handlers.riftEggReserved(k) then
											handlers.riftEggHandoffs[tostring(k)] = { category = record.AssetCategory or record.Category, at = os.clock() }
										end

										if handlers.petIndexReserved(k) then
											handlers.PetIndex.handoffs[tostring(k)] = { category = record.AssetCategory or record.Category, at = os.clock() }
										end

										if handlers.noteHatchPetOutputAttempt() then
											task.wait(0.15)
											flag3, flag4 = pcall(tbl11.RequestCompleteHatchEgg, k)
										end
									end

									if flag3 and flag4 == true then
										n6 += 1

										if v18 ~= nil and tostring(k) == tostring(v18) then
											handlers.greatBloomUnlockReturnPending = true
											handlers.greatBloomUnlockStealWanted = false
											tbl15.refreshEventPending()

											if fn12 then
												fn12("crane-return")
											end

											if type(handlers.wakeGreatBloomUnlock) == "function" then
												task.defer(handlers.wakeGreatBloomUnlock, "crane-hatched")
											end
										end

										if type(handlers.sendWebhook) == "function" then
											task.spawn(handlers.sendWebhook, "hatch", "Egg Hatched", tostring(type(record) == "table" and (record.AssetCategory or record.Category) or "Egg"), 6333946, false)
										end
									end

									fn6(0.2, 0.4)
									handlers.reconcileNewPetUids()
									v19 = nil
								elseif tbl11.SecondsUntilReady then
									local v20 = nil

									pcall(function()
										v20 = tbl11.SecondsUntilReady(record)
									end)

									if type(v20) == "number" and v20 > 0 then
										n7 = n7 and math.min(n7, v20) or v20
									end
								end
							end
						end

						continue
					end

					break
				end
			end
		end)

		handlers.reconcileNewPetUids()

		if handlers.hatchPetOutputPending == true then
			task.spawn(function()
				while fn() and handlers.hatchPetOutputPending == true do
					handlers.reconcileNewPetUids()
					task.wait(0.1)
				end
			end)
		end

		tbl14.hatchBusy = false

		if not ok then
			warn("[CloverHub] hatch pass error: " .. tostring(result))
		end

		if ok then
			return n6, n7, nil
		end
		return n6, n7, "error"
	end

	AutoPlaceToggle:OnChanged(function(autoPlace)
		tbl2.AutoPlace = autoPlace

		if not autoPlace and not fn49() then
			tbl15.placePending = false
		end

		if handlers.refreshEggOverlapStatus then
			task.defer(handlers.refreshEggOverlapStatus)
		end

		fn45((autoPlace or tbl2.AutoHatch or tbl2.PlaceAfterIncubation) and "🟢 Monitoring eggs" or "🔴 Off")
		tbl17.Wake("auto-place-toggle")
	end)

	AutoHatchToggle:OnChanged(function(autoHatch)
		tbl2.AutoHatch = autoHatch
		fn45((autoHatch or tbl2.AutoPlace or tbl2.PlaceAfterIncubation) and "🟢 Monitoring eggs" or "🔴 Off")
		tbl17.Wake("auto-hatch-toggle")
	end)

	HatchFracturedOnlyToggle:OnChanged(function(arg)
		tbl2.HatchFracturedOnly = arg == true
		tbl17.Wake("fractured-only-toggle")
	end)

	task.spawn(function()
		while fn() do
			local n6 = nil

			local ok, result = xpcall(function()
				handlers.refreshPetIndex()
				local v16 = fn48() or handlers.riftEggActive() or handlers.petIndexActive()
				local autoHatch = (tbl2.AutoHatch or v16) and tbl11
				local n7 = 0
				local n8 = nil

				if autoHatch then
					local now3 = os.clock()

					if tbl17.NextCheckAt <= now3 then
						local v17, v18
						n7, v17, v18 = fn66()
						n8 = v18 == "busy" and 0.5 or n7 > 0 and 0.75 or v17 and v17 + 0.05 or nil
						tbl17.NextCheckAt = n8 and now3 + n8 or math.huge
					else
						n8 = math.max(0.05, tbl17.NextCheckAt - now3)
					end
				end

				if fn49() and tbl11 and tbl16 then
					tbl15.placeBeat = os.clock()
					local flag2 = #fn63() > 0
					local v17, v18, v19, v20 = fn59()
					handlers.updatePlaceReservation(flag2, v20)

					if not flag2 then
						fn45(tbl2.PlaceAfterIncubation and getIncubatedPlaceCount() > 0 and "🟡 Waiting for mutated egg" or "🟢 Active · inventory clear")
					elseif handlers.placeHigherPriorityPending() then
						tbl15.placePending = false
						fn45(handlers.adminEventPending and "⏸️ Lab has priority" or "⏸️ Automation has priority")
					elseif critical then
						fn45("⏸️ Carrying egg")
					elseif v20 then
						tbl15.placePending = false
						fn45("🟡 Egg slots full · " .. (v18 and v17 >= v18 and ("%d/%d"):format(v17, v18) or ("%d placed"):format(v17)) .. " · waiting for hatch")
					elseif tbl2.PlaceInRangeOnly and not v16 and not fn50() then
						tbl15.placePending = false
						fn45("🟡 Waiting for pen range")
					elseif not tbl14.acquire("Place") then
						fn45("⏸️ Steal has priority")
					else
						tbl15.placePending = true
						tbl15.placeBeat = os.clock()
						local ok, result, result2, result3

						if tbl15.requestTreadmillExit() then
							local result4
							ok, result, result4, result2, result3 = pcall(fn65)
						else
							result = nil
							result3 = "treadmill"
							result2 = nil
							ok = false
						end

						local n9 = #fn63()
						local value = select(4, fn59())
						handlers.updatePlaceReservation(n9 > 0, result2 == true or value)

						if tbl15.placePending then
							n6 = 0.5
						end

						if not ok and result3 == "treadmill" then
							fn45("🟡 Could not leave treadmill")
						elseif not ok then
							fn45("🟡 Place error")
						elseif result and result > 0 then
							if not tbl15.placePending then
								tbl15.blockTreadmill(0.2)
								tbl15.treadmillIdleSince = os.clock() - 1
							end

							fn45(handlers.petIndexActive() and "📖 Index egg placed · growing" or v16 and "🔓 Crane egg placed · growing" or "🟢 Placed " .. result)
						elseif result2 then
							fn45("🟡 Pen full")
						elseif result3 == "range" then
							fn45("🟡 Waiting for pen range")
						elseif result3 == "interrupted" then
							fn45("⏸️ Yielding to steal")
						else
							fn45("🟢 Monitoring eggs")
						end
					end
				elseif tbl2.AutoHatch or v16 then
					tbl15.placePending = false
					fn45(n7 > 0 and "🟢 Hatched " .. n7 or tbl14.hatchOk() and "🟢 Watching hatch timers" or "⏸️ Egg transaction busy")
				elseif tbl2.PlaceAfterIncubation then
					tbl15.placePending = false
					fn45("🟢 Waiting for mutation")
				else
					tbl15.placePending = false
				end

				if not tbl15.placePending then
					tbl14.release("Place")
				end

				if fn49() then
					n6 = tbl15.placePending and 0.5 or 0.75
				elseif tbl2.AutoHatch or v16 then
					n6 = n8
				end

				tbl19.step()

				if tbl2.AutoMutate then
					n6 = math.min(n6 or 0.75, 0.75)
				end
			end, debug.traceback)

			if ok then
				getgenv().__CHSAE_AutoPlaceWorkerError = nil
			else
				getgenv().__CHSAE_AutoPlaceWorkerError = tostring(result)
				tbl15.placePending = false
				tbl14.placeBusy = false
				tbl14.release("Place")
				tbl19.cleanup()
				fn45("🟡 Retrying placement")
				warn("[CloverHub] Auto-Place worker recovered: " .. tostring(result))
				n6 = 1
			end

			tbl17.Wait(n6)
		end

		tbl19.cleanup()
	end)

	if getgenv().__CHSAE_Debug then
		getgenv().__CHSAE_Debug.PreviewPlaceEggs = function()
			return #fn63()
		end
	end
end

local v15, v16, v17

do
	local wearBest = nil

	pcall(function()
		wearBest = require(ReplicatedStorage.Shared.Remotes).Haul.WearBest
	end)

	if getgenv().__CHCapRestore then
		pcall(getgenv().__CHCapRestore)
	end

	getgenv().__CHCapRestore = nil
	v15 = progression:AddLeftGroupbox("🐾 Equip Best")

	local function fn46()
		if tbl2.AutoLab == true and next(handlers.riftReservedPets) ~= nil then
			return false, "Rift has reserved required pets"
		end

		if not (wearBest and wearBest:IsA("RemoteFunction")) then
			return false, "native Equip Best endpoint unavailable"
		end

		local ok, result, result2 = pcall(function()
			return wearBest:InvokeServer()
		end)

		if not ok then
			return false, tostring(result)
		end
		local flag2 = result == true
		local v18 = tostring
		local str

		if result2 then
			str = result2
		else
			str = result == true and "equipped" or "server rejected"
		end

		return flag2, v18(str)
	end

	local EquipInterval = v15:AddInput("EquipInterval", {
		Text = "Interval (seconds)",
		Default = tostring(tbl2.EquipInterval),
		Numeric = true,
		Placeholder = "30",
		Finished = true,
		Tooltip = "Seconds between runs. Minimum 5.",
	})

	v15:AddToggle("AutoEquipToggle", {
		Text = "Auto Equip Best",
		Default = tbl2.AutoEquipBest,
		Tooltip = "Equip your best pets automatically.",
	}):OnChanged(function(autoEquipBest)
		tbl2.AutoEquipBest = autoEquipBest
	end)

	makeButtonPanel(v15, "BtnEquipBest", {
		{
			"⚡ Equip Best",
			function()
				task.spawn(function()
					if handlers.greatBloomUnlockProtectCranePets == true then
						lua:Notify("🔓 Finish returning the Crane before equipping pets.", 4)
						return
					end
					local v18 = nil
					local v19 = nil

					if not tbl14.petsSerial(function()
						local v20, v21 = fn46()
						v18 = v20
						v19 = v21
					end, "Equipping best pets") then
						lua:Notify("🐾 An auto Equip-Best pass is already running — skipped.", 4)
						return
					end

					if not v18 then
						lua:Notify("🐾 Equip Best was not accepted: " .. tostring(v19), 5)
					end
				end)
			end,
		},
	})

	EquipInterval:OnChanged(function(arg)
		local equipInterval = tonumber(arg)

		if equipInterval and equipInterval >= 5 then
			tbl2.EquipInterval = equipInterval
		end
	end)

	v16 = sell:AddLeftGroupbox("💰 Sell Pets")

	local function fn47(arg)
		local v18 = pairs
		local tbl17 = arg or {}

		for _, v19 in v18(tbl17) do
			if v19 == true then
				return true
			end
		end

		return false
	end

	local SellStatusLabel = nil

	chk.Merge(v16, function()
		SellStatusLabel = v16:AddLabel("SellStatusLabel", { Text = "🔴 Off", DoesWrap = true })
	end)

	local function fn48(arg)
		handlers.setLabel(SellStatusLabel, arg)
	end

	local tbl17 = {}
	local tbl18 = {}

	pcall(function()
		local tbl19 = {}

		for k in pairs(tbl12.MutationNames) do
			if type(k) == "string" and k ~= "None" then
				tbl19[#tbl19 + 1] = k
			end
		end

		table.sort(tbl19)

		for _, v18 in ipairs(tbl19) do
			tbl17[#tbl17 + 1] = v18
			local str = "#FFFFFF"
			local valueMulti = nil

			pcall(function()
				local v19 = tbl12.GetMutation(v18)

				if v19 then
					if typeof(v19.Color) == "Color3" then
						str = fn5(v19.Color)
					elseif type(v19.Color) == "string" then
						str = "#" .. v19.Color:gsub("[^%x]", ""):sub(1, 6)
					end

					valueMulti = v19.ValueMulti
				end
			end)

			tbl18[v18] = ("<font color=\"%s\"><b>%s</b></font>"):format(str, v18) .. (valueMulti and (" <font color=\"#9AA0AA\">×%s</font>"):format(tostring(valueMulti)) or "")
		end
	end)

	bindDropdownOverlay(v16, "SellPets", "Categories", tbl8.Items, {
		configKey = "SellPets",
		multi = true,
		store = tbl2.SellPets,
		text = "Categories",
		tooltip = "Choose categories. Empty = any.",
		displayMap = tbl8.Display,
		onChange = function()
			if type(handlers.disarmPetSellerForFilterEdit) == "function" then
				handlers.disarmPetSellerForFilterEdit()
			end
		end,
	})

	bindDropdownOverlay(v16, "SellRarities", "Rarities", tbl4, {
		configKey = "SellRarities",
		multi = true,
		store = tbl2.SellRarities,
		text = "Rarities",
		tooltip = "Choose rarities. Empty = any.",
		displayMap = tbl5,
		onChange = function()
			if type(handlers.disarmPetSellerForFilterEdit) == "function" then
				handlers.disarmPetSellerForFilterEdit()
			end
		end,
	})

	bindDropdownOverlay(v16, "SellMutations", "Mutations", tbl17, {
		configKey = "SellMutations",
		multi = true,
		store = tbl2.SellMutations,
		text = "Mutations",
		tooltip = "Choose mutations. Empty = any.",
		displayMap = tbl18,
		onChange = function()
			if type(handlers.disarmPetSellerForFilterEdit) == "function" then
				handlers.disarmPetSellerForFilterEdit()
			end
		end,
	})

	handlers.addKGFilterControls(v16, "SellPet", "SellPetKGMode", "SellPetKGThreshold", function()
		if type(handlers.disarmPetSellerForFilterEdit) == "function" then
			handlers.disarmPetSellerForFilterEdit()
		end
	end)

	handlers.addValueFilterInput(v16, "SellPetValueThreshold", "SellPetValueThreshold", "Minimum Value", function(arg)
		if arg ~= "config" and type(handlers.disarmPetSellerForValueEdit) == "function" then
			handlers.disarmPetSellerForValueEdit()
		end

		if type(handlers.refreshSellPetStatus) == "function" then
			handlers.refreshSellPetStatus()
		end
	end, "Keep this value and above. Sells only pets below it; K, M, B, T work; 0 disables.")

	local tbl19 = nil
	local salePrice = nil
	local petSatchel = nil

	pcall(function()
		local AssetItems = require(ReplicatedStorage.Shared.Util.AssetItems)
		tbl19 = { Deserialize = AssetItems.Decode }
		salePrice = AssetItems.SalePrice
		petSatchel = require(ReplicatedStorage.Shared.Remotes).PetSatchel

		if not petSatchel.SellSelection and not petSatchel.SellPet then
			petSatchel = nil
		end
	end)

	local function fn49(arg)
		local ok, result = pcall(function()
			return Assets.Directory[arg.Category].Rarity
		end)

		return ok and type(result) == "table" and result or nil
	end

	local function fn50(arg)
		local tbl20 = {}

		if type(arg.Mutations) == "table" then
			for _, mutation in pairs(arg.Mutations) do
				if type(mutation) == "string" and mutation ~= "None" then
					tbl20[#tbl20 + 1] = mutation
				end
			end
		end

		return tbl20
	end

	local function fn51()
		local tbl20 = {}

		pcall(function()
			local v18 = tbl16 and tbl16.Get()
			if not (v18 and tbl19) then
				return
			end
			handlers.reconcileNewPetUids(v18)
			local tbl21 = {}
			local v19 = ipairs
			local equippedAssets = v18.EquippedAssets or {}

			for _, equippedAsset in v19(equippedAssets) do
				tbl21[tostring(equippedAsset)] = true
			end

			local n2 = localPlayer:GetAttribute("VIP") and 2 or 1
			local v20 = pairs
			local inventory = v18.Inventory or {}
			local n3 = 0

			for k, v21 in v20(inventory) do
				n3 += 1

				if n3 % 32 == 0 then
					task.wait()
					if not fn() then
						return
					end
				end

				if not tbl21[tostring(k)] and not handlers.petSellUidProtected(k, v18, true) then
					local ok, result = pcall(tbl19.Deserialize, v21)

					if ok and type(result) == "table" and result.IsFavorite ~= true and not result.InFuse then
						local n4 = 0

						if salePrice then
							pcall(function()
								n4 = (tonumber(salePrice(result)) or 0) * n2
							end)
						end

						local v22, v23 = riftValueScore(result)
						tbl20[#tbl20 + 1] = { uid = k, item = result, price = n4, income = v22, incomeKnown = v23 }
					end
				end
			end
		end)

		return tbl20
	end

	local function fn52()
		local valueFilterActive = handlers.valueFilterActive
		local sellPetValueThreshold = tbl2.SellPetValueThreshold
		return fn47(tbl2.SellPets), fn47(tbl2.SellRarities), fn47(tbl2.SellMutations), handlers.kgFilterActive(tbl2.SellPetKGMode, tbl2.SellPetKGThreshold), valueFilterActive(sellPetValueThreshold)
	end

	handlers.sellPetMatchesCurrentFilters = function(arg, arg2, arg3)
		local v18, v19, v20, v21, v22 = fn52()
		if not (v18 or v19 or v20 or v21 or v22) or type(arg) ~= "table" then
			return false
		end
		local category = arg.Category
		local v23 = fn49(arg)
		local flag2 = not v18 or category and tbl2.SellPets[category] == true
		local flag3 = not v19 or v23 and tbl2.SellRarities[v23._id] == true
		local flag4 = not v20

		if v20 then
			for _, v24 in ipairs(fn50(arg)) do
				if tbl2.SellMutations[v24] then
					flag4 = true
					break
				end
			end
		end

		local flag5 = not v21 or handlers.kgFilterMatches(arg, tbl2.SellPetKGMode, tbl2.SellPetKGThreshold)
		local flag6 = not v22 or handlers.valueFilterMatches(arg2, tbl2.SellPetValueThreshold, "below", arg3)
		local flag7 = handlers.greatBloomUnlockProtectCranePets == true and tostring(category) == "Crane"
		return flag2 and flag3 and flag4 and flag5 and flag6 and not flag7
	end

	local function fn53()
		local tbl20 = {}
		local v18, v19, v20, v21, v22 = fn52()
		if not (v18 or v19 or v20 or v21 or v22) then
			return tbl20, 0
		end
		local n2 = 0

		for _, v23 in ipairs(fn51()) do
			if handlers.sellPetMatchesCurrentFilters(v23.item, v23.income, v23.incomeKnown) then
				tbl20[#tbl20 + 1] = v23
				n2 += v23.price or 0
			end
		end

		table.sort(tbl20, function(arg, arg2)
			return tostring(arg.uid) < tostring(arg2.uid)
		end)

		return tbl20, n2
	end

	handlers.buildSalePreviewSnapshot = function(arg, arg2, arg3, arg4)
		arg = type(arg) == "table" and arg or {}
		local n2 = #arg
		local n3 = math.min(n2, tonumber(arg3) or n2)
		local tbl20 = {}
		local tbl21 = {}
		local n4 = 0

		for i = 1, n3 do
			local v18 = arg[i]
			tbl20[#tbl20 + 1] = v18
			local item = type(v18) == "table" and v18.item or nil
			local str = tostring(type(v18) == "table" and v18.uid or "")
			local str2 = tostring(type(item) == "table" and item.Category or "Unknown")
			local flag2 = type(item) == "table" and fn49(item) or nil
			local str3 = tostring(type(flag2) == "table" and flag2._id or "Unknown rarity")
			local tbl22 = type(item) == "table" and fn50(item) or {}
			table.sort(tbl22)
			local flag3 = type(item) == "table" and fn23(item) or nil
			local flag4 = type(flag3) == "number"
			local str4

			if flag4 then
				local v19 = tostring
				local v20 = table.pack(math.round(math.max(flag3, 0)))
				str4 = v19(table.unpack(v20, 1, v20.n))
			else
				str4 = flag4
			end

			str4 = str4 or "none"
			local n5 = type(v18) == "table" and tonumber(v18.price) or 0
			n4 += n5
			local n6 = #tbl21 + 1
			local concat = table.concat
			local tbl23 = {}
			local str5 = table.concat(tbl22, ",")
			local str6 = tostring(v18 and v18.incomeKnown == true)
			local str7 = tostring(v18 and v18.income)
			local v19 = table.pack(tostring(n5))
			tbl23[1] = str
			tbl23[2] = str2
			tbl23[3] = str3
			tbl23[4] = str5
			tbl23[5] = str4
			tbl23[6] = str6
			tbl23[7] = str7

			do
				local values = table.pack(table.unpack(v19, 1, v19.n))
				table.move(values, 1, values.n, 8, tbl23)
			end

			tbl21[n6] = concat(tbl23, ":")
		end

		local str = arg2 == "egg" and "egg" or "pet"
		local str2 = n3 == 0 and "0 " .. str .. "s selected"
		local str3

		if str2 then
			str3 = str2
		else
			str3 = ("%d %s%s selected · $%s sale value"):format(n3, str, n3 == 1 and "" or "s", fn3(n4))
		end

		return {
			Summary = str3,
			Fingerprint = tostring(arg4 or "") .. "|" .. tostring(n2) .. "|" .. table.concat(tbl21, "||"),
			Count = n3,
			TotalMatches = n2,
			Entries = tbl20,
		}
	end

	handlers.hideAndDismissSellerDialog = function(arg)
		if type(arg) ~= "table" or arg.Destroyed == true then
			return
		end

		pcall(function()
			local container = arg.Container
			local parent = typeof(container) == "Instance" and container.Parent and container.Parent.Parent or nil

			if parent and parent:IsA("GuiObject") then
				parent.Visible = false
			end
		end)

		pcall(function()
			arg:Dismiss()
		end)
	end

	handlers.holdSellerDialogEntrance = function()
		local v18 = nil

		local connection = v3.MainFrame.ChildAdded:Connect(function(child)
			if not v18 and child:IsA("TextButton") and child.ZIndex == 9000 then
				v18 = child
				child.Visible = false
			end
		end)

		return function(arg)
			connection:Disconnect()

			if v18 and v18.Parent then
				if arg then
					v18.Visible = true
				else
					v18:Destroy()
				end
			end
		end
	end

	handlers.prepareStationarySellerDialog = function(arg)
		local parent = arg.Container.Parent and arg.Container.Parent.Parent

		if not parent or not parent:IsA("GuiObject") then
			error("Seller dialog frame unavailable")
		end

		parent.Visible = false
		local uiScale = parent:FindFirstChildOfClass("UIScale")

		if uiScale then
			uiScale:Destroy()
		end

		parent.Position = UDim2.fromScale(0.5, 0.5)
		return parent
	end

	handlers.revealStationarySellerDialog = function(arg, arg2)
		task.spawn(function()
			local v18

			for i = 1, 4 do
				RunService.Heartbeat:Wait()
				if not fn() or arg.Destroyed == true or handlers.activeSellerDialog ~= arg or not arg2.Parent then
					return
				end
				local absoluteSize = arg2.AbsoluteSize
				if v18 == absoluteSize and absoluteSize.X > 0 and absoluteSize.Y > 0 then
					arg2.Visible = true
					return
				end
				v18 = absoluteSize
			end

			if handlers.activeSellerDialog == arg then
				handlers.activeSellerDialog = nil
				handlers.hideAndDismissSellerDialog(arg)
			end
		end)
	end

	handlers.openSellConfirmation = function(arg)
		local tbl20 = type(arg) == "table" and arg or {}
		if not fn() or type(tbl20.GetSnapshot) ~= "function" or type(tbl20.OnConfirm) ~= "function" then
			return false
		end
		local activeSellerDialog = handlers.activeSellerDialog
		if type(activeSellerDialog) == "table" and activeSellerDialog.Destroyed ~= true then
			lua:Notify("Review or cancel the open sell warning first.", 4)
			return false
		end
		handlers.activeSellerDialog = nil
		local ok, result = pcall(tbl20.GetSnapshot)
		if not ok or type(result) ~= "table" then
			return false
		end
		local v18 = nil
		local v19 = nil
		local v20 = nil
		local v21 = nil
		local flag2 = false

		local function fn54(arg2)
			if handlers.activeSellerDialog == v18 then
				handlers.activeSellerDialog = nil
			end

			handlers.hideAndDismissSellerDialog(arg2 or v18)
		end

		if not pcall(function()
			v21 = handlers.holdSellerDialogEntrance()

			v18 = v3:AddDialog(tostring(tbl20.Id or "SellerSafetyDialog"), {
				Title = tostring(tbl20.Title or "Confirm irreversible sale"),
				Description = "",
				TitleColor = Color3.fromRGB(248, 113, 113),
				AutoDismiss = false,
				OutsideClickDismiss = false,
				FooterButtons = {
					Cancel = {
						Title = "Cancel",
						Variant = "Ghost",
						Order = 1,
						Callback = function(arg2)
							fn54(arg2)
						end,
					},
					Confirm = {
						Title = tostring(tbl20.ConfirmText or "Confirm Sale"),
						Variant = "Destructive",
						Order = 2,
						Callback = function(arg2)
							local v22 = flag2
							local flag3

							if flag2 then
								flag3 = v22
							else
								flag3 = handlers.activeSellerDialog ~= v18
							end

							if flag3 then
								return
							end

							if not fn() then
								fn54(arg2)
								return
							end
							local ok2, result2 = pcall(tbl20.GetSnapshot)
							ok2 = ok2 and type(result2) == "table"
							local flag4 = ok2 and type(tbl20.Validate) == "function"
							local result3 = nil

							if flag4 then
								local ok3, result4
								ok3, result4, result3 = pcall(tbl20.Validate, result2)
								ok2 = ok3 and result4 == true
							end

							if not ok2 then
								v19.Body.Text = tostring(result3 or "The seller is no longer ready. Review the filters and Minimum Value.")
								v19.Title.Text = "<b>SALE BLOCKED</b>"
								return
							end

							if result2.Fingerprint ~= result.Fingerprint then
								result = result2
								v20:SetSnapshot(result2)
								v19.Title.Text = "<b>MATCHES CHANGED — REVIEW AGAIN</b>"
								v19.Body.Text = "Inventory or filters changed while this warning was open. The selected count and value are refreshed; press the destructive button again to confirm the new selection."
								v18:Resize()
								return
							end

							flag2 = true
							fn54(arg2)

							if not (fn() and pcall(tbl20.OnConfirm, result2)) then
								tbl2.AutoSell = false
								tbl2.SellPetsWhenFull = false
								tbl2.AutoSellEggs = false
								tbl2.SellEggsWhenFull = false

								for _, v23 in ipairs({ "AutoSell", "SellPetsWhenFull", "AutoSellEggs", "SellEggsWhenFull" }) do
									local flag5 = type(

									if type(flag5) == "table" and type(flag5.SetValue) == "function" then
										pcall(flag5.SetValue, flag5, false)
									end
								end

								lua:Notify("The confirmed action failed safely; all sellers remain off.", 5)
							end
						end,
					},
				},
			})

			local v22 = handlers.prepareStationarySellerDialog(v18)
			v21(true)
			v21 = nil
			handlers.activeSellerDialog = v18

			v19 = chk.Notice(v18, tostring(tbl20.Id or "Seller") .. "WarningCard", {
				title = "IRREVERSIBLE SALE",
				text = tostring(tbl20.Warning or "This sale cannot be undone."),
				accent = Color3.fromRGB(248, 113, 113),
				titleColor = Color3.fromRGB(252, 165, 165),
				textColor = Color3.fromRGB(243, 244, 246),
				titleSize = 15,
				textSize = 13,
				height = 92,
				zIndex = 9003,
			})

			v20 = chk.SalePreview(v18, tostring(tbl20.Id or "Seller") .. "Preview", { snapshot = result, accent = Color3.fromRGB(248, 113, 113), height = 46, zIndex = 9003 })
			v18:Resize()
			handlers.revealStationarySellerDialog(v18, v22)
		end) then
			if v21 then
				pcall(v21, false)
			end

			if handlers.activeSellerDialog == v18 then
				handlers.activeSellerDialog = nil
			end

			if type(v18) == "table" and v18.Destroyed ~= true then
				handlers.hideAndDismissSellerDialog(v18)
			end

			lua:Notify("The sell warning could not open; selling remains off.", 5)
			return false
		end

		return true
	end

	handlers.dismissSellConfirmation = function()
		local activeSellerDialog = handlers.activeSellerDialog
		handlers.activeSellerDialog = nil

		if type(activeSellerDialog) == "table" and activeSellerDialog.Destroyed ~= true then
			handlers.hideAndDismissSellerDialog(activeSellerDialog)
		end
	end

	handlers.petSalePreviewSnapshot = function(arg)
		local v18 = fn53()
		local concat = table.concat
		local tbl20 = {}
		local v19 = fn8(tbl2.SellPets)
		local v20 = fn8(tbl2.SellRarities)
		local v21 = fn8(tbl2.SellMutations)
		local str = tostring(tbl2.SellPetKGMode)
		local str2 = tostring(tbl2.SellPetKGThreshold)
		local v22 = tostring
		local sellPetValueThreshold = tbl2.SellPetValueThreshold
		tbl20[1] = v19
		tbl20[2] = v20
		tbl20[3] = v21
		tbl20[4] = str
		tbl20[5] = str2

		do
			local values = table.pack(v22(sellPetValueThreshold))
			table.move(values, 1, values.n, 6, tbl20)
		end

		local v23 = concat(tbl20, "|")
		return handlers.buildSalePreviewSnapshot(v18, "pet", arg, v23)
	end

	handlers.refreshSellPetStatus = function()
		if not (tbl2.AutoSell or tbl2.SellPetsWhenFull) then
			return
		end

		if not handlers.sellerValueFilterReady("SellPetValueThreshold") then
			fn48("⏸️ Finish editing value")
			return
		end
		local v18, v19, v20, v21, v22 = fn52()
		if not (v18 or v19 or v20 or v21 or v22) then
			fn48("🟡 Pick a filter")
			return
		end
		fn48(("🟢 Armed · %d match"):format(#fn53()))
	end

	handlers.stopHoldingSellerTool = function()
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		character = character and character:FindFirstChildWhichIsA("Tool")
		local sellerHeldTool = handlers.sellerHeldTool
		local sellerEggUid = handlers.sellerEggUid

		if sellerEggUid and not sellerHeldTool then
			pcall(tbl11.RequestUnequipTool, sellerEggUid)
		end

		handlers.sellerEggUid = nil
		handlers.sellerPetUid = nil
		handlers.sellerHeldTool = nil

		if humanoid and character and character == sellerHeldTool then
			pcall(function()
				humanoid:UnequipTools()
			end)
		end
	end

	local function fn54(arg, arg2, arg3)
		local function fn55(arg4, arg5, arg6)
			local tbl20 = {}
			local tbl21 = {}
			local tbl22 = {}
			if not handlers.sellerValueFilterReady("SellPetValueThreshold") then
				return 0, 0, 0, 0, "value-input-mismatch"
			end

			if not fn() or critical or not tbl14.sellOk() or arg6 and tbl2[arg6] ~= true then
				return 0, 0, 0, 0, "seller-busy"
			end
			local v18 = nil

			pcall(function()
				v18 = tbl16 and tbl16.Get()
			end)

			if not (type(v18) == "table" and type(v18.Inventory) == "table" and tbl19 and petSatchel and petSatchel.SellPet) then
				return 0, 0, 0, 0, "save-unavailable"
			end
			handlers.reconcileNewPetUids(v18)
			local tbl23 = {}
			local v19 = ipairs
			local equippedAssets = v18.EquippedAssets or {}

			for _, equippedAsset in v19(equippedAssets) do
				tbl23[tostring(equippedAsset)] = true
			end

			local n2 = localPlayer:GetAttribute("VIP") and 2 or 1

			for _, v20 in ipairs(arg4) do
				if not (arg5 and #tbl21 >= arg5) then
					local str = tostring(v20.uid or "")
					local v21 = v18.Inventory[str]

					if str ~= "" and not tbl22[str] and v21 ~= nil and not tbl23[str] and not handlers.petSellUidProtected(str, v18, true) then
						local ok, result = pcall(tbl19.Deserialize, v21)

						if ok and type(result) == "table" and result.IsFavorite ~= true and not result.InFuse then
							local v22, v23 = riftValueScore(result)

							if handlers.sellPetMatchesCurrentFilters(result, v22, v23) then
								local n3 = 0

								if salePrice then
									pcall(function()
										n3 = (tonumber(salePrice(result)) or 0) * n2
									end)
								end

								local tbl24 = { uid = str, item = result, price = n3, income = v22, incomeKnown = v23 }
								tbl22[str] = true
								tbl20[#tbl20 + 1] = tbl24
								tbl21[#tbl21 + 1] = str
							end
						end
					end

					continue
				end

				break
			end

			if #tbl21 == 0 then
				return 0, 0, 0, 0, "preflight-empty"
			end

			if not handlers.sellerValueFilterReady("SellPetValueThreshold") then
				return 0, 0, 0, 0, "value-input-mismatch"
			end

			if not fn() or critical or not tbl14.sellOk() or arg6 and tbl2[arg6] ~= true then
				return 0, 0, 0, 0, "seller-busy"
			end
			local tbl24 = {}
			local tbl25 = {}
			local tbl26 = {}

			for k in pairs(v18.Inventory) do
				tbl24[tostring(k)] = true
			end

			for i, v20 in ipairs(tbl21) do
				tbl26[i] = { UID = v20, Category = tostring(tbl20[i].item.Category or ""), Income = tbl20[i].income }
			end

			handlers.lastPetSellPreflight = {
				At = os.clock(),
				Threshold = tonumber(tbl2.SellPetValueThreshold) or 0,
				Count = #tbl21,
				Entries = tbl26,
			}

			if type(getgenv().__CHSAE_Debug) == "table" then
				local lastPetSellPreflight = handlers.lastPetSellPreflight
				getgenv().__CHSAE_Debug.LastPetSellPreflight = lastPetSellPreflight
			end

			if handlers.valueFilterActive(tbl2.SellPetValueThreshold) then
				fn48(("🟡 Verified %d · below $%s/s"):format(#tbl21, handlers.formatCompactValue(tbl2.SellPetValueThreshold)))
			else
				fn48(("🟡 Verified %d selected UID%s"):format(#tbl21, #tbl21 == 1 and "" or "s"))
			end

			local v20 = tbl21[1]
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if not humanoid then
				return 0, 0, #tbl20, 0, "character-unavailable"
			end
			local v21 = nil

			for _, v22 in ipairs({ character, localPlayer:FindFirstChildOfClass("Backpack") }) do
				for _, child in ipairs(v22:GetChildren()) do
					if child:IsA("Tool") and child:GetAttribute("ItemType") == "Asset" and child:GetAttribute("UID") == v20 then
						v21 = child
						break
					end
				end

				if not v21 then
					continue
				end
				break
			end

			if not v21 then
				return 0, 0, #tbl20, 0, "pet-tool-unavailable"
			end
			local v22 = handlers
			handlers.sellerPetUid = v20
			v22.sellerHeldTool = v21
			handlers.sellerUsedTool = true

			local ok = pcall(function()
				humanoid:EquipTool(v21)
			end)

			local n3 = os.clock() + 0.6

			while true do
				if ok and v21.Parent ~= character and os.clock() < n3 then
					if not (not fn() or localPlayer.Character ~= character or not tbl14.sellOk() or arg6 and tbl2[arg6] ~= true) then
						task.wait(0.05)
						continue
					end
				end

				break
			end

			if not ok or localPlayer.Character ~= character or v21.Parent ~= character then
				return 0, 0, #tbl20, 0, "pet-equip-failed"
			end
			local v23 = nil

			pcall(function()
				v23 = tbl16.Get()
			end)

			if type(v23) ~= "table" or type(v23.Inventory) ~= "table" then
				return 0, 0, #tbl20, 0, "save-unavailable"
			end
			handlers.reconcileNewPetUids(v23)
			local tbl27 = {}
			local tbl28 = {}
			local sentUIDs = {}
			local v24 = ipairs
			local equippedAssets2 = v23.EquippedAssets or {}

			for _, v25 in v24(equippedAssets2) do
				tbl27[tostring(v25)] = true
			end

			table.clear(tbl24)

			for k in pairs(v23.Inventory) do
				tbl24[tostring(k)] = true
			end

			for _, v25 in ipairs(tbl20) do
				local uid = v25.uid
				local v26 = v23.Inventory[v25.uid]

				if v26 ~= nil and not tbl27[uid] and not handlers.petSellUidProtected(uid, v23, true) then
					local ok2, item = pcall(tbl19.Deserialize, v26)

					if ok2 and type(item) == "table" and item.IsFavorite ~= true and not item.InFuse then
						local v27, v28 = riftValueScore(item)

						if handlers.sellPetMatchesCurrentFilters(item, v27, v28) then
							v25.item = item
							v25.income = v27
							v25.incomeKnown = v28

							if salePrice then
								pcall(function()
									v25.price = (tonumber(salePrice(item)) or 0) * n2
								end)
							end

							local n4 = #tbl28 + 1
							local n5 = #sentUIDs + 1
							tbl28[n4] = v25
							sentUIDs[n5] = uid
						end
					end
				end
			end

			if #sentUIDs == 0 then
				return 0, 0, 0, 0, "preflight-empty"
			end

			if not handlers.sellerValueFilterReady("SellPetValueThreshold") then
				return 0, 0, 0, 0, "value-input-mismatch"
			end

			if not fn() or critical or not tbl14.sellOk() or arg6 and tbl2[arg6] ~= true then
				return 0, 0, 0, 0, "seller-busy"
			end

			if localPlayer.Character ~= character or character:FindFirstChildWhichIsA("Tool") ~= v21 or v21:GetAttribute("ItemType") ~= "Asset" or v21:GetAttribute("UID") ~= v20 then
				return 0, 0, #tbl28, 0, "held-pet-changed"
			end

			if not pcall(function()
				petSatchel.SellPet:FireServer(sentUIDs)
			end) then
				return 0, 0, #tbl28, 0, "transport-error"
			end

			for _, sentUID in ipairs(sentUIDs) do
				tbl25[sentUID] = true
			end

			handlers.lastPetSellPreflight.SentUIDs = sentUIDs
			local n4 = os.clock() + 2.5
			local tbl29, flag2, flag3

			while true do
				task.wait(0.1)
				tbl29 = {}
				flag2 = false

				pcall(function()
					local v25 = tbl16.Get()

					if type(v25) == "table" and type(v25.Inventory) == "table" then
						tbl29 = v25.Inventory
						flag2 = true
					end
				end)

				if flag2 then
					local flag4 = false

					for _, v25 in ipairs(tbl28) do
						if tbl29[v25.uid] ~= nil then
							flag4 = true
							break
						end
					end

					if not flag4 then
						flag3 = true
						break
					else
						flag3 = false
						if not (n4 <= os.clock()) then
							continue
						end
					end

					break
				else
					flag3 = false
					if not (n4 <= os.clock()) then
						continue
					end
					break
				end
			end

			if not flag2 then
				tbl2.AutoSell = false
				tbl2.SellPetsWhenFull = false

				if type(handlers.forceDisarmPetSeller) == "function" then
					handlers.forceDisarmPetSeller("🔴 Seller stopped · confirmation unavailable", "Pet selling stopped because the inventory result could not be verified.", true)
				else
					fn48("🔴 Seller stopped · confirmation unavailable")

					pcall(function()
						lua:Notify("Pet selling stopped because the inventory result could not be verified.", 6)
					end)
				end

				return 0, 0, #tbl28, 0, "confirmation-unavailable"
			end

			if flag3 then
				task.wait(0.25)
				tbl29 = {}
				flag2 = false

				pcall(function()
					local v25 = tbl16.Get()

					if type(v25) == "table" and type(v25.Inventory) == "table" then
						tbl29 = v25.Inventory
						flag2 = true
					end
				end)
			end

			if not flag2 then
				handlers.forceDisarmPetSeller("🔴 Seller stopped · confirmation unavailable", "Pet selling stopped because the batch result could not be verified.", true)
				return 0, 0, #tbl28, 0, "confirmation-unavailable"
			end
			local tbl30 = {}

			for k in pairs(tbl29) do
				tbl30[tostring(k)] = true
			end

			local n5 = 0
			local n6 = 0
			local n7 = 0

			for _, v25 in ipairs(tbl28) do
				if not tbl30[tostring(v25.uid)] then
					n5 += 1
					n6 += v25.price or 0
				else
					n7 += 1
				end
			end

			local lastPetSellUnexpected = {}

			for k in pairs(tbl24) do
				if not tbl25[k] and not tbl30[k] then
					lastPetSellUnexpected[#lastPetSellUnexpected + 1] = k
				end
			end

			table.sort(lastPetSellUnexpected)

			if type(getgenv().__CHSAE_Debug) == "table" then
				getgenv().__CHSAE_Debug.LastPetSellUnexpected = lastPetSellUnexpected
			end

			if #lastPetSellUnexpected > 0 then
				tbl2.AutoSell = false
				tbl2.SellPetsWhenFull = false

				if type(handlers.forceDisarmPetSeller) == "function" then
					handlers.forceDisarmPetSeller("🔴 Seller stopped · unexpected inventory change", "Pet selling stopped because a UID outside the verified batch disappeared.", true)
				end
			end

			return n5, n6, n7, #lastPetSellUnexpected, #lastPetSellUnexpected > 0 and "unexpected-removal" or nil
		end

		if #arg <= 1 then
			local pack = table.pack
			local v18, v19, v20, v21, v22 = fn55(arg, arg2, arg3)
			local v23 = pack(v18, v19, v20, v21, v22)
			handlers.stopHoldingSellerTool()
			return table.unpack(v23, 1, v23.n)
		end

		local tbl20 = {}
		local n2 = 1
		local n3 = 0
		local n4 = 0
		local n5 = 0
		local n6 = 0
		local n7 = 0
		local v18

		while true do
			if not (n2 <= #arg) then
				return n4, n5, n6, n7
			else
				local n8 = arg2 and math.max(0, arg2 - n3) or 1
				if n8 <= 0 then
					return n4, n5, n6, n7
				end
				local tbl21 = {}

				while n2 <= #arg and #tbl21 < math.min(1, n8) do
					local v19 = arg[n2]
					n2 += 1
					local str = tostring(v19.uid or "")

					if str ~= "" and not tbl20[str] then
						tbl20[str] = true
						tbl21[#tbl21 + 1] = v19
					end
				end

				if #tbl21 > 0 then
					local v19, v20, v21, v22
					v19, v20, v21, v22, v18 = fn55(tbl21, n8, arg3)
					handlers.stopHoldingSellerTool()
					n4 += v19
					n5 += v20
					n6 += v21
					n3 += v19 + v21
					n7 += v22
					if v18 and v18 ~= "preflight-empty" then
						break
					end

					if v21 > 0 or tbl2.AutoTreadmill and not tbl14.treadmillTraining then
						return n4, n5, n6, n7
					end
				end

				if n2 <= #arg then
					task.wait()
				end
			end
		end

		return n4, n5, n6, n7, v18
	end

	local function fn55(arg)
		if not handlers.sellerValueFilterReady("SellPetValueThreshold") then
			fn48("⏸️ Finish editing value")
			return 0, false, 0
		end
		local v18, v19, v20, v21, v22 = fn52()
		if not (v18 or v19 or v20 or v21 or v22) then
			fn48("🟡 Pick a filter")
			return 0, false, 0
		end
		local v23 = fn53()
		if #v23 == 0 then
			fn48("🟢 Armed · 0 match")
			return 0, false, 0
		end
		local v24, v25, v26, v27, v28 = fn54(v23, nil, arg)
		if v28 == "preflight-empty" then
			fn48("🟢 Armed · 0 verified")
			return 0, false, 0
		end

		if v28 == "value-input-mismatch" then
			fn48("⏸️ Visible value does not match saved value")
			return 0, true, 0
		end

		if v28 == "seller-busy" then
			fn48(handlers.hatchPetSaleGuardActive() and "⏸️ Fresh/held hatch pet protected" or "⏸️ Busy · retrying")
			return 0, true, 0
		end

		if v28 == "save-unavailable" then
			fn48("⏸️ Inventory unavailable · retrying")
			return 0, true, 0
		end

		if v28 == "confirmation-unavailable" then
			fn48("🔴 Seller stopped · confirmation unavailable")
			return 0, false, v26
		end

		if v28 == "transport-error" then
			fn48("🔴 Sell request failed")
			return 0, true, v26
		end

		if (v27 or 0) > 0 then
			fn48("🔴 Seller stopped · unexpected inventory change")
		elseif not arg or tbl2[arg] then
			fn48(v26 > 0 and ("🟡 Sold %d · %d not sold"):format(v24, v26) or ("🟢 Sold %d · $%s"):format(v24, fn3(v25)))
		end

		return v24, true, v26
	end

	handlers.sellerToggle = function(arg, arg2, arg3)
		local addToggle = nil

		local function fn56(arg4)
			handlers[arg2.writeFlag] = true
			tbl2[arg3.key] = arg4

			local ok = pcall(function()
				addToggle:SetValue(arg4)
			end)

			handlers[arg2.writeFlag] = nil
			return ok
		end

		addToggle = arg.AddToggle
		addToggle = addToggle(arg, arg3.id, { Text = arg3.text, Default = tbl2[arg3.key], Risky = true, Tooltip = arg3.tooltip })

		addToggle:OnChanged(function(arg4)
			if handlers[arg2.writeFlag] == true then
				return
			end

			if not arg4 then
				tbl2[arg3.key] = false

				if arg2.refresh then
					arg2.refresh()
				end

				if arg3.full then
					arg2.setStatus(tbl2[arg2.autoKey] and arg2.armedText or "🔴 Off")
				elseif not tbl2[arg2.fullKey] then
					arg2.setStatus("🔴 Off")
				end

				return
			end

			fn56(false)
			if handlers.valueFilterLoadInProgress == true then
				return
			end

			if not handlers.sellerValueFilterReady(arg2.valueKey) then
				arg2.setStatus("⏸️ Finish editing value")
				lua:Notify("Finish editing Minimum Value, then enable " .. arg3.label .. " again.", 4)
				return
			end

			if not handlers.sellerHasFilter(arg2) then
				arg2.setStatus("🟡 Pick a filter")
				return
			end

			if not arg2.available() then
				arg2.setStatus("🔴 Sell unavailable")
				return
			end

			handlers.openSellConfirmation({
				Id = arg3.confirmId,
				Title = arg3.title,
				ConfirmText = arg3.confirmText,
				Warning = arg3.warning,
				GetSnapshot = function()
					return handlers[arg2.snapshot](nil)
				end,
				Validate = function()
					if not handlers.sellerValueFilterReady(arg2.valueKey) then
						return false, "Minimum Value is still being edited; " .. arg3.label .. " remains off."
					end

					if not handlers.sellerHasFilter(arg2) then
						return false, "Choose at least one " .. arg2.noun .. " filter; " .. arg3.label .. " remains off."
					end
					local str = arg2.Noun .. " selling is unavailable in this client."
					return arg2.available(), str
				end,
				OnConfirm = function(arg5)
					if not fn56(true) then
						tbl2[arg3.key] = false
						arg2.setStatus("🔴 " .. arg3.label .. " stayed off")
						return
					end

					handlers.markValueFilterChanged()

					if arg2.refresh then
						arg2.refresh()
					end

					if arg3.full then
						local v18, v19, v20 = handlers[arg2.capacity]()
						arg2.setStatus(("🟢 Watching · %d/%d"):format(v19, v20 or 0))
					else
						arg2.setStatus(("🟢 Armed · %d match"):format(arg5.TotalMatches or 0))
					end
				end,
			})
		end)

		return addToggle
	end

	handlers.sellerDisarm = function(arg, arg2)
		return function(arg3, arg4, arg5)
			local v18 = tbl2[arg.autoKey] or tbl2[arg.fullKey]
			handlers.dismissSellConfirmation()

			for _, v19 in ipairs(arg2) do
				pcall(function()
					v19:SetValue(false)
				end)
			end

			local v19 = tbl2
			local fullKey = arg.fullKey
			tbl2[arg.autoKey] = false
			v19[fullKey] = false

			if arg3 then
				arg.setStatus(arg3)
			end

			if arg4 and (v18 or arg5) then
				pcall(function()
					lua:Notify(arg4, 6)
				end)
			end

			return v18
		end
	end

	handlers.sellerHasFilter = function(arg)
		local v18, v19, v20, v21, v22 = arg.filterState()
		return v18 or v19 or v20 or v21 or v22
	end

	handlers.sellerOnceButton = function(arg, arg2, arg3)
		makeButtonPanel(arg, arg3.id, {
			{
				arg3.text,
				function()
					if not handlers.sellerValueFilterReady(arg2.valueKey) then
						arg2.setStatus("⏸️ Finish editing value")
						lua:Notify("Finish editing Minimum Value, then try again.", 4)
						return
					end

					if not handlers.sellerHasFilter(arg2) then
						arg2.setStatus("🟡 Pick a filter")
						return
					end

					if not arg2.available() then
						arg2.setStatus("🔴 Sell unavailable")
						lua:Notify(arg3.icon .. " " .. arg2.Noun .. " selling is unavailable in this client.", 4)
						return
					end

					if #arg3.matching() == 0 then
						arg2.setStatus("🟢 0 match")
						return
					end

					handlers.openSellConfirmation({
						Id = arg3.confirmId,
						Title = arg3.title,
						ConfirmText = arg3.confirmText,
						Warning = arg3.warning,
						GetSnapshot = function()
							return handlers[arg2.snapshot](nil)
						end,
						Validate = function(arg4)
							if not handlers.sellerValueFilterReady(arg2.valueKey) then
								return false, "Minimum Value is still being edited; nothing was sold."
							end

							if not handlers.sellerHasFilter(arg2) then
								return false, "Choose at least one " .. arg2.noun .. " filter; nothing was sold."
							end

							if not arg2.available() then
								return false, arg2.Noun .. " selling is unavailable in this client."
							end
							return (arg4.Count or 0) > 0, "No " .. arg2.noun .. "s currently match; nothing was sold."
						end,
						OnConfirm = function(arg4)
							arg2.setStatus(("🟡 Selling once · %d reviewed"):format(arg4.Count or 0))

							task.spawn(function()
								if not tbl14.sellSerial(function()
									arg3.sell(arg4)
								end, "Selling " .. arg2.noun .. "s") then
									arg2.setStatus("⏸️ Busy · try again")
								end
							end)
						end,
					})
				end,
			},
		})
	end

	handlers.petSeller = {
		noun = "pet",
		Noun = "Pet",
		writeFlag = "petSellerToggleWrite",
		valueKey = "SellPetValueThreshold",
		autoKey = "AutoSell",
		fullKey = "SellPetsWhenFull",
		armedText = "🟢 Auto-Sell armed",
		snapshot = "petSalePreviewSnapshot",
		capacity = "petInventoryCapacityState",
		setStatus = fn48,
		filterState = fn52,
		available = function()
			return petSatchel ~= nil
		end,
	}

	local v18 = handlers.sellerToggle(v16, handlers.petSeller, {
		id = "AutoSellToggle",
		key = "AutoSell",
		label = "Auto-Sell",
		text = "Auto-Sell",
		tooltip = "Warning: Sells matching pets. Favorites are safe.",
		confirmId = "ConfirmAutoSellPets",
		title = "Enable Pet Auto-Sell?",
		confirmText = "Enable Auto-Sell",
		warning = "Turning this on repeatedly sells every current and future pet matching these filters. Sales are permanent and cannot be restored. Favorite anything you want to keep.",
	})

	local v19 = handlers.sellerToggle(v16, handlers.petSeller, {
		id = "SellPetsWhenFullToggle",
		key = "SellPetsWhenFull",
		label = "Sell Full",
		full = true,
		text = "Sell Full",
		tooltip = "Only sell once pet inventory is full.",
		confirmId = "ConfirmSellPetsWhenFull",
		title = "Enable Pet Sell Full?",
		confirmText = "Enable Sell Full",
		warning = "When pet inventory becomes full, all matching pets are submitted one at a time with a pause between confirmed sales. Each sale is permanent. The current selected count is shown below.",
	})


	handlers.forceDisarmPetSeller = handlers.sellerDisarm(handlers.petSeller, { v18, v19 })

	handlers.disarmPetSellerForValueEdit = function()
		if tbl2.AutoSell or tbl2.SellPetsWhenFull then
			handlers.forceDisarmPetSeller("⏸️ Value changed · review and re-enable", "Pet selling paused. Review Minimum Value, then re-enable it.", false)
		end
	end

	handlers.disarmPetSellerForFilterEdit = function()
		if tbl2.AutoSell or tbl2.SellPetsWhenFull then
			handlers.forceDisarmPetSeller("⏸️ Filters changed · review and re-enable", "Pet selling paused because its filters changed. Review the new match list, then re-enable it.", false)
		end
	end

	handlers.sellerOnceButton(v16, handlers.petSeller, {
		id = "BtnSellPetsOnce",
		text = "💰 Sell Pets",
		icon = "💰",
		matching = fn53,
		confirmId = "ConfirmSellPetsOnce",
		title = "Sell These Pets?",
		confirmText = "Sell Selected Pets",
		warning = "All selected pets will be submitted one at a time with a pause between confirmed sales. This cannot be undone. Only pets selected at confirmation can be attempted.",
		sell = function(arg)
			local v20, v21, v22, v23, v24 = fn54(arg.Entries or {}, nil, nil)

			if v24 == "seller-busy" then
				fn48("⏸️ Busy · try again")
			elseif v24 == "save-unavailable" then
				fn48("⏸️ Inventory unavailable · nothing repeated")
			elseif v24 == "confirmation-unavailable" then
				fn48("🔴 Seller stopped · confirmation unavailable")
			elseif v24 == "transport-error" then
				fn48("🔴 Sell request failed")
			elseif (v23 or 0) > 0 then
				fn48("🔴 Seller stopped · unexpected inventory change")
			else
				fn48(v22 > 0 and ("🟡 Sold %d · %d not sold"):format(v20, v22) or ("🟢 Sold %d · $%s"):format(v20, fn3(v21)))
			end
		end,
	})

	v17 = sell:AddRightGroupbox("🥚 Sell Eggs")
	local EggSellOverlapLabel = nil
	local EggSellStatusLabel = nil

	chk.Merge(v17, function()
		EggSellOverlapLabel = v17:AddLabel("EggSellOverlapLabel", { Text = "✅ No Auto-Place overlap", DoesWrap = true })
		EggSellStatusLabel = v17:AddLabel("EggSellStatusLabel", { Text = "🔴 Off", DoesWrap = true })
	end)

	local function fn56(arg)
		handlers.setLabel(EggSellStatusLabel, arg)
	end

	local tbl20 = nil

	pcall(function()
		local EggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)

		tbl20 = {
			DeserializeSavedEgg = EggRecords.Decode,
			BuildAssetItemData = EggRecords.ToAssetItemData,
			GetSellPrice = EggRecords.SellPrice,
		}
	end)

	bindDropdownOverlay(v17, "SellEggNames", "Categories", tbl8.Items, {
		configKey = "SellEggNames",
		multi = true,
		store = tbl2.SellEggNames,
		text = "Categories",
		tooltip = "Choose categories. Empty = any.",
		displayMap = tbl8.Display,
		onChange = function()
			if type(handlers.disarmEggSellerForFilterEdit) == "function" then
				handlers.disarmEggSellerForFilterEdit()
			end

			if handlers.refreshEggOverlapStatus then
				handlers.refreshEggOverlapStatus()
			end
		end,
	})

	bindDropdownOverlay(v17, "SellEggRarities", "Rarities", tbl4, {
		configKey = "SellEggRarities",
		multi = true,
		store = tbl2.SellEggRarities,
		text = "Rarities",
		tooltip = "Choose rarities. Empty = any.",
		displayMap = tbl5,
		onChange = function()
			if type(handlers.disarmEggSellerForFilterEdit) == "function" then
				handlers.disarmEggSellerForFilterEdit()
			end

			if handlers.refreshEggOverlapStatus then
				handlers.refreshEggOverlapStatus()
			end
		end,
	})

	bindDropdownOverlay(v17, "SellEggMutations", "Mutations", tbl17, {
		configKey = "SellEggMutations",
		multi = true,
		store = tbl2.SellEggMutations,
		text = "Mutations",
		tooltip = "Choose mutations. Empty = any.",
		displayMap = tbl18,
		onChange = function()
			if type(handlers.disarmEggSellerForFilterEdit) == "function" then
				handlers.disarmEggSellerForFilterEdit()
			end

			if handlers.refreshEggOverlapStatus then
				handlers.refreshEggOverlapStatus()
			end
		end,
	})

	handlers.addKGFilterControls(v17, "SellEgg", "SellEggKGMode", "SellEggKGThreshold", function()
		if type(handlers.disarmEggSellerForFilterEdit) == "function" then
			handlers.disarmEggSellerForFilterEdit()
		end

		if handlers.refreshEggOverlapStatus then
			handlers.refreshEggOverlapStatus()
		end
	end)

	handlers.addValueFilterInput(v17, "SellEggValueThreshold", "SellEggValueThreshold", "Minimum Value", function(arg)
		if arg ~= "config" and type(handlers.disarmEggSellerForValueEdit) == "function" then
			handlers.disarmEggSellerForValueEdit()
		end

		if handlers.refreshEggOverlapStatus then
			handlers.refreshEggOverlapStatus()
		end
	end, "Keep this value and above. Sells only eggs below it; K, M, B, T work; 0 disables.")

	local function fn57()
		local valueFilterActive = handlers.valueFilterActive
		local sellEggValueThreshold = tbl2.SellEggValueThreshold
		return fn47(tbl2.SellEggNames), fn47(tbl2.SellEggRarities), fn47(tbl2.SellEggMutations), handlers.kgFilterActive(tbl2.SellEggKGMode, tbl2.SellEggKGThreshold), valueFilterActive(sellEggValueThreshold)
	end

	local function fn58(arg)
		local tbl21 = {}

		pcall(function()
			local v20 = tbl16 and tbl16.Get()
			if not (v20 and tbl20) then
				return
			end
			local eggInventory = v20.EggInventory or {}
			local v21 = pairs
			local v22 = arg or eggInventory
			local n2 = 0

			for k in v21(v22) do
				n2 += 1

				if not arg and n2 % 32 == 0 then
					task.wait()
					if not fn() then
						return
					end
				end

				local v23 = eggInventory[k]

				if type(v23) == "table" and v23.Placement == nil then
					local ok, result = pcall(tbl20.DeserializeSavedEgg, v23)

					if ok and result then
						local ok2, result2 = pcall(tbl20.BuildAssetItemData, result)
						local n3 = 0

						pcall(function()
							n3 = tonumber(tbl20.GetSellPrice(result)) or 0
						end)

						if ok2 and type(result2) == "table" and result2.Category then
							local v24, v25 = riftValueScore(result2)
							tbl21[#tbl21 + 1] = { uid = k, item = result2, raw = v23, price = n3, income = v24, incomeKnown = v25 }
						end
					end
				end
			end
		end)

		return tbl21
	end

	local function fn59(arg, arg2, arg3)
		local n2 = tonumber(arg) or 0
		local n3 = tonumber(arg2) or 0
		local eggSellOverlap

		if (tonumber(handlers.riftEggBlocked) or 0) > 0 then
			eggSellOverlap = "🔒 Requested egg reserved for the Lab"
		elseif n2 <= 0 then
			eggSellOverlap = "✅ No Auto-Place overlap"
		elseif n3 > 0 then
			eggSellOverlap = ("⚠️ Overlap: %d · Auto-Place first"):format(n3)
		else
			eggSellOverlap = (arg3 and "🟠 Overlap: %d · pen full, can sell" or "🟠 Overlap: %d · eligible to sell"):format(n2)
		end

		handlers.eggSellOverlap = eggSellOverlap
		handlers.setLabel(EggSellOverlapLabel, eggSellOverlap)
	end

	local function fn60(arg)
		local v20, v21, v22, v23, v24 = fn57()
		local tbl21 = {}

		if not (v21 or v20 or v22 or v23 or v24) then
			handlers.riftEggBlocked = 0
			fn59(0, 0, false)
			return tbl21, 0, 0, 0
		end

		local tbl22 = {}
		local flag2 = false
		local flag3 = false

		if type(handlers.getAutoPlaceEggPolicy) == "function" then
			pcall(function()
				local v25, v26, v27 = handlers.getAutoPlaceEggPolicy()
				tbl22 = v25
				flag2 = v26
				flag3 = v27
			end)
		end

		local n2 = 0
		local n3 = 0
		local riftEggBlocked = 0
		local n4 = 0

		for _, v25 in ipairs(fn58(arg)) do
			local category = v25.item.Category
			local v26 = fn49(v25.item)
			local flag4 = not v20 or tbl2.SellEggNames[category] == true
			local flag5 = not v21 or v26 and tbl2.SellEggRarities[v26._id] == true
			local flag6 = not v22
			local flag7 = not v23 or handlers.kgFilterMatches(v25.item, tbl2.SellEggKGMode, tbl2.SellEggKGThreshold)
			local flag8 = not v24 or handlers.valueFilterMatches(v25.income, tbl2.SellEggValueThreshold, "below", v25.incomeKnown)

			if v22 then
				for _, v27 in ipairs(fn50(v25.item)) do
					if tbl2.SellEggMutations[v27] then
						flag6 = true
						break
					end
				end
			end

			if flag4 and flag5 and flag6 and flag7 and flag8 then
				local flag9 = tbl22[tostring(v25.uid)] == true
				local v27 = handlers.labEggReserved(v25.uid, v25.category) or handlers.petIndexReserved(v25.uid)

				if flag9 or v27 then
					n2 += 1
				end

				if v27 then
					n3 += 1
					riftEggBlocked += 1
				elseif flag9 then
					tbl21[#tbl21 + 1] = v25
					n4 += v25.price or 0
				else
					tbl21[#tbl21 + 1] = v25
					n4 += v25.price or 0
				end
			end
		end

		if not arg then
			handlers.riftEggBlocked = riftEggBlocked
			fn59(n2, n3, flag3)
		end

		table.sort(tbl21, function(arg2, arg3)
			return tostring(arg2.uid) < tostring(arg3.uid)
		end)

		return tbl21, n4, n2, n3
	end

	handlers.refreshEggOverlapStatus = function()
		fn60()
	end

	task.defer(handlers.refreshEggOverlapStatus)

	handlers.eggSalePreviewSnapshot = function(arg)
		local v20 = fn60()
		local concat = table.concat
		local tbl21 = {}
		local v21 = fn8(tbl2.SellEggNames)
		local v22 = fn8(tbl2.SellEggRarities)
		local v23 = fn8(tbl2.SellEggMutations)
		local str = tostring(tbl2.SellEggKGMode)
		local str2 = tostring(tbl2.SellEggKGThreshold)
		local v24 = tostring
		local sellEggValueThreshold = tbl2.SellEggValueThreshold
		tbl21[1] = v21
		tbl21[2] = v22
		tbl21[3] = v23
		tbl21[4] = str
		tbl21[5] = str2

		do
			local values = table.pack(v24(sellEggValueThreshold))
			table.move(values, 1, values.n, 6, tbl21)
		end

		local v25 = concat(tbl21, "|")
		return handlers.buildSalePreviewSnapshot(v20, "egg", arg, v25)
	end

	local function fn61(arg, arg2, arg3)
		local function fn62(arg4, arg5, arg6)
			local function fn63()
				local SellEggValueThreshold = fn() and not critical and tbl14.sellOk() and handlers.sellerValueFilterReady("SellEggValueThreshold")
				local flag2

				if SellEggValueThreshold then
					flag2 = not arg6 or tbl2[arg6] == true
				else
					flag2 = SellEggValueThreshold
				end

				return flag2
			end

			if not fn63() then
				return 0, 0, 0
			end

			if not (petSatchel and petSatchel.SellPet and tbl11 and tbl11.RequestEquipTool) then
				return 0, 0, #arg4
			end
			local tbl21 = {}
			local tbl22 = {}
			local tbl23 = {}
			local tbl24 = {}

			for _, v20 in ipairs(arg4) do
				tbl21[tostring(v20.uid)] = true
			end

			for _, v20 in ipairs(fn60(tbl21)) do
				local str = tostring(v20.uid)

				if tbl21[str] and not tbl24[str] and not handlers.labEggReserved(str) and not handlers.petIndexReserved(str) then
					if not (arg5 and #tbl23 >= arg5) then
						local n2 = #tbl22 + 1
						local n3 = #tbl23 + 1
						tbl22[n2] = v20
						tbl23[n3] = str
						tbl24[str] = true
						continue
					end
				else
					continue
				end

				break
			end

			if #tbl23 == 0 or not fn63() then
				return 0, 0, 0
			end

			local ok, result = pcall(function()
				return tbl16.Get()
			end)

			if not ok or type(result) ~= "table" or type(result.EggInventory) ~= "table" then
				return 0, 0, #tbl22
			end
			local tbl25 = {}

			for k in pairs(result.EggInventory) do
				tbl25[tostring(k)] = true
			end

			local tbl26 = {}

			for _, v20 in ipairs(fn60(tbl21)) do
				tbl26[tostring(v20.uid)] = v20
			end

			local tbl27 = {}
			local tbl28 = {}
			table.clear(tbl24)

			for _, v20 in ipairs(tbl23) do
				if tbl25[v20] and tbl26[v20] and not handlers.labEggReserved(v20) and not handlers.petIndexReserved(v20) then
					local n2 = #tbl27 + 1
					local n3 = #tbl28 + 1
					tbl27[n2] = tbl26[v20]
					tbl28[n3] = v20
					tbl24[v20] = true
				end
			end

			if #tbl28 == 0 or not fn63() then
				return 0, 0, 0
			end
			local v20 = tbl28[1]
			local character = localPlayer.Character
			if not character then
				return 0, 0, #tbl27
			end
			handlers.sellerEggUid = v20
			handlers.sellerUsedTool = true
			local ok2, result2 = pcall(tbl11.RequestEquipTool, v20)
			if not ok2 or result2 ~= true then
				return 0, 0, #tbl27
			end
			local n2 = os.clock() + 1.5
			local tool

			while true do
				tool = nil

				if localPlayer.Character ~= character then
					break
				else
					tool = character:FindFirstChildWhichIsA("Tool")

					if tool and tool:GetAttribute("ItemType") == "AssetEgg" and tool:GetAttribute("UID") == v20 then
						handlers.sellerHeldTool = tool
						break
					else
						local flag2 = not fn63() or os.clock() >= n2
						tool = nil
						if not flag2 then
							task.wait(0.05)
							continue
						end
					end

					break
				end
			end

			if not tool then
				return 0, 0, #tbl27
			end
			local flag2 = false

			for _, v21 in ipairs(fn60({ [v20] = true })) do
				if tostring(v21.uid) == v20 and not handlers.labEggReserved(v20) and not handlers.petIndexReserved(v20) then
					flag2 = true
					break
				end
			end

			if not flag2 or not fn63() or localPlayer.Character ~= character or character:FindFirstChildWhichIsA("Tool") ~= tool or tool:GetAttribute("ItemType") ~= "AssetEgg" or tool:GetAttribute("UID") ~= v20 then
				return 0, 0, 0
			end

			if not pcall(function()
				petSatchel.SellPet:FireServer({ v20 })
			end) then
				return 0, 0, #tbl27
			end
			local n3 = os.clock() + 2.5
			local eggInventory

			while true do
				local ok3, result3 = pcall(function()
					return tbl16.Get()
				end)

				local flag3 = ok3 and type(result3) == "table" and type(result3.EggInventory) == "table"
				eggInventory = nil

				if flag3 then
					eggInventory = result3.EggInventory
					local flag4 = true

					for _, v21 in ipairs(tbl28) do
						if eggInventory[v21] ~= nil then
							flag4 = false
							break
						end
					end

					if not flag4 then
						if not (n3 <= os.clock()) then
							task.wait(0.1)
							continue
						end
					end
				elseif not (n3 <= os.clock()) then
					task.wait(0.1)
					continue
				end

				break
			end

			if eggInventory then
				task.wait(0.25)

				local ok3, result3 = pcall(function()
					return tbl16.Get()
				end)

				eggInventory = ok3 and type(result3) == "table" and type(result3.EggInventory) == "table" and result3.EggInventory or nil
			end

			if not eggInventory then
				handlers.forceDisarmEggSeller("🔴 Seller stopped · confirmation unavailable", "Egg selling stopped because the batch result could not be verified.", true)
				return 0, 0, #tbl27, "confirmation-unavailable"
			end
			local n4 = 0
			local n5 = 0

			for _, v21 in ipairs(tbl27) do
				if eggInventory[tostring(v21.uid)] == nil then
					n4 += 1
					n5 += v21.price or 0
				end
			end

			for k in pairs(tbl25) do
				if not tbl24[k] and eggInventory[k] == nil then
					handlers.forceDisarmEggSeller("🔴 Seller stopped · unexpected inventory change", "Egg selling stopped because an egg outside the filtered batch disappeared.", true)
					return n4, n5, #tbl27 - n4, "unexpected-removal"
				end
			end

			return n4, n5, #tbl27 - n4
		end

		if #arg <= 1 then
			local v20 = table.pack(fn62(arg, arg2, arg3))
			handlers.stopHoldingSellerTool()
			return table.unpack(v20, 1, v20.n)
		end

		local tbl21 = {}
		local n2 = 1
		local n3 = 0
		local n4 = 0
		local n5 = 0
		local n6 = 0
		local v20

		while true do
			if not (n2 <= #arg) then
				return n4, n5, n6
			else
				local n7 = arg2 and math.max(0, arg2 - n3) or 1
				if n7 <= 0 then
					return n4, n5, n6
				end
				local tbl22 = {}

				while n2 <= #arg and #tbl22 < math.min(1, n7) do
					local v21 = arg[n2]
					n2 += 1
					local str = tostring(v21.uid or "")

					if str ~= "" and not tbl21[str] then
						tbl21[str] = true
						tbl22[#tbl22 + 1] = v21
					end
				end

				if #tbl22 > 0 then
					local v21, v22, v23
					v21, v22, v23, v20 = fn62(tbl22, n7, arg3)
					handlers.stopHoldingSellerTool()
					n4 += v21
					n5 += v22
					n6 += v23
					n3 += v21 + v23
					if v20 then
						break
					end

					if v23 > 0 or tbl2.AutoTreadmill and not tbl14.treadmillTraining then
						return n4, n5, n6
					end
				end

				if n2 <= #arg then
					task.wait()
				end
			end
		end

		return n4, n5, n6, v20
	end

	local function fn62(arg)
		if not handlers.sellerValueFilterReady("SellEggValueThreshold") then
			fn56("⏸️ Finish editing value")
			return 0, false, 0
		end
		local v20, v21, v22, v23, v24 = fn57()
		if not (v20 or v21 or v22 or v23 or v24) then
			fn56("🟡 Pick a filter")
			return 0, false, 0
		end
		local v25 = fn60()
		if #v25 == 0 then
			fn56("🟢 Armed · 0 match")
			return 0, false, 0
		end
		local v26, v27, v28, v29 = fn61(v25, nil, arg)
		if v29 then
			return v26, false, v28
		end

		if not arg or tbl2[arg] then
			fn56(v28 > 0 and ("🟡 Sold %d · %d not sold"):format(v26, v28) or ("🟢 Sold %d · $%s"):format(v26, fn3(v27)))
		end

		return v26, true, v28
	end

	handlers.eggSeller = {
		noun = "egg",
		Noun = "Egg",
		writeFlag = "eggSellerToggleWrite",
		valueKey = "SellEggValueThreshold",
		autoKey = "AutoSellEggs",
		fullKey = "SellEggsWhenFull",
		armedText = "🟢 Auto-Sell eggs armed",
		snapshot = "eggSalePreviewSnapshot",
		capacity = "eggInventoryCapacityState",
		setStatus = fn56,
		filterState = fn57,
		available = function()
			return petSatchel ~= nil and petSatchel.SellPet ~= nil
		end,
		refresh = function()
			if handlers.refreshEggOverlapStatus then
				task.defer(handlers.refreshEggOverlapStatus)
			end
		end,
	}

	local v20 = handlers.sellerToggle(v17, handlers.eggSeller, {
		id = "AutoSellEggToggle",
		key = "AutoSellEggs",
		label = "Auto-Sell Eggs",
		text = "Auto-Sell Eggs",
		tooltip = "Warning: Sells matching eggs. Placed eggs are safe.",
		confirmId = "ConfirmAutoSellEggs",
		title = "Enable Egg Auto-Sell?",
		confirmText = "Enable Auto-Sell Eggs",
		warning = "Turning this on repeatedly sells every current and future egg matching these filters. Sales are permanent. Placed, Auto-Place-reserved, and Rift-reserved eggs stay excluded.",
	})

	local v21 = handlers.sellerToggle(v17, handlers.eggSeller, {
		id = "SellEggsWhenFullToggle",
		key = "SellEggsWhenFull",
		label = "Egg Sell Full",
		full = true,
		text = "Sell Full",
		tooltip = "Only sell once egg inventory is full.",
		confirmId = "ConfirmSellEggsWhenFull",
		title = "Enable Egg Sell Full?",
		confirmText = "Enable Egg Sell Full",
		warning = "When egg inventory becomes full, all matching eggs are submitted one at a time with a pause between confirmed sales. Each sale is permanent. Reserved and placed eggs remain excluded.",
	})


	handlers.forceDisarmEggSeller = handlers.sellerDisarm(handlers.eggSeller, { v20, v21 })

	handlers.disarmEggSellerForValueEdit = function()
		handlers.forceDisarmEggSeller((tbl2.AutoSellEggs or tbl2.SellEggsWhenFull) and "⏸️ Value changed · review and re-enable" or nil, "Egg selling paused. Review Minimum Value, then re-enable it.")
	end

	handlers.disarmEggSellerForFilterEdit = function()
		if tbl2.AutoSellEggs or tbl2.SellEggsWhenFull then
			handlers.forceDisarmEggSeller("⏸️ Filters changed · review and re-enable", "Egg selling paused because its filters changed. Review the new match list, then re-enable it.")
		end
	end

	handlers.sellerOnceButton(v17, handlers.eggSeller, {
		id = "BtnSellEggsOnce",
		text = "🥚 Sell Eggs",
		icon = "🥚",
		matching = fn60,
		confirmId = "ConfirmSellEggsOnce",
		title = "Sell These Eggs?",
		confirmText = "Sell Selected Eggs",
		warning = "All selected eggs will be submitted one at a time with a pause between confirmed sales. This cannot be undone. Only eggs selected at confirmation can be attempted.",
		sell = function(arg)
			local v22, v23, v24, v25 = fn61(arg.Entries or {}, nil, nil)
			if v25 then
				return
			end
			fn56(v24 > 0 and ("🟡 Sold %d · %d not sold"):format(v22, v24) or ("🟢 Sold %d · $%s"):format(v22, fn3(v23)))
		end,
	})

	task.spawn(function()
		while fn() do
			local ok, result = pcall(function()
				local autoSell = tbl2.AutoSell
				local autoSell2 = tbl2.AutoSell or tbl2.SellPetsWhenFull
				local autoSellEggs = tbl2.AutoSellEggs
				local flag2 = false
				local n2 = 0
				local flag3 = false
				local n3 = 0
				local n4 = 0
				autoSellEggs = autoSellEggs or tbl2.SellEggsWhenFull

				while fn() do
					local autoSell3 = tbl2.AutoSell or tbl2.SellPetsWhenFull
					local autoSellEggs2 = tbl2.AutoSellEggs or tbl2.SellEggsWhenFull

					if autoSell3 ~= autoSell2 then
						autoSell = tbl2.AutoSell

						if not tbl2.SellPetsWhenFull then
							flag2 = false
						end

						n2 = 0
						autoSell2 = autoSell3
					end

					if autoSellEggs2 ~= autoSellEggs then
						if not tbl2.SellEggsWhenFull then
							flag3 = false
						end

						n3 = 0
						autoSellEggs = autoSellEggs2
					end

					local flag4 = false
					local n5 = 0
					local v22 = nil

					if autoSell3 then
						flag4, n5, v22 = handlers.petInventoryCapacityState()
					end

					local flag5 = false
					local n6 = 0
					local v23 = nil

					if autoSellEggs2 then
						flag5, n6, v23 = handlers.eggInventoryCapacityState()
					end

					if tbl2.SellPetsWhenFull and flag4 then
						flag2 = true
					end

					if tbl2.SellEggsWhenFull and flag5 then
						flag3 = true
					end

					if not tbl2.SellPetsWhenFull then
						flag2 = false
					end

					if not tbl2.SellEggsWhenFull then
						flag3 = false
					end

					local str = tbl2.AutoSell and "AutoSell"
					local str2

					if str then
						str2 = str
					else
						str2 = flag2 and "SellPetsWhenFull" or nil
					end

					local str3 = tbl2.AutoSellEggs and "AutoSellEggs"
					local str4

					if str3 then
						str4 = str3
					else
						str4 = flag3 and "SellEggsWhenFull" or nil
					end

					if not str4 and (tbl2.AutoSellEggs or tbl2.SellEggsWhenFull) and type(handlers.refreshEggOverlapStatus) == "function" then
						pcall(handlers.refreshEggOverlapStatus)
					end

					local flag6 = false

					if tbl14.quietOk() then
						if str2 and petSatchel and os.clock() >= n2 then
							local v24, v25, v26, v27 = tbl14.sellSerial(function()
								return fn55(str2)
							end, "Selling pets")

							if v24 then
								autoSell = v26 == true

								if not v26 then
									flag2 = false
								end

								local n7 = tonumber(v25) or 0
								local n8 = tonumber(v27) or 0

								if v26 and n7 > 0 and n8 == 0 then
									flag6 = true
								elseif v26 then
									n2 = os.clock() + 3
								end
							end
						elseif tbl2.SellPetsWhenFull and not flag2 then
							fn48(("🟢 Watching · %d/%d"):format(n5, v22 or 0))
						end

						if str4 and petSatchel and petSatchel.SellPet and os.clock() >= n3 then
							local v24, v25, v26, v27 = tbl14.sellSerial(function()
								return fn62(str4)
							end, "Selling eggs")

							if v24 then
								if not v26 then
									flag3 = false
								end

								local n7 = tonumber(v25) or 0
								local n8 = tonumber(v27) or 0

								if v26 and n7 > 0 and n8 == 0 then
									flag6 = true
								elseif v26 then
									n3 = os.clock() + 3
								end
							end
						elseif tbl2.SellEggsWhenFull and not flag3 then
							fn56(("🟢 Watching · %d/%d"):format(n6, v23 or 0))
						end

						local flag7 = tbl2.AutoEquipBest and wearBest and handlers.greatBloomUnlockProtectCranePets ~= true

						if flag7 then
							flag7 = not (petSatchel and str2 and autoSell)
						end

						if flag7 then
							flag7 = os.clock() - n4 >= math.max(5, tbl2.EquipInterval or 30)
						end

						if flag7 then
							if tbl14.petsSerial(fn46, "Equipping best pets") then
								n4 = os.clock()
							end
						end
					end

					if flag6 and tbl14.quietOk() then
						task.wait()
					else
						tbl14.waitSeller((autoSell3 or autoSellEggs2 or tbl2.AutoEquipBest) and 1 or 5)
					end
				end
			end)

			if not (ok or not fn()) then
				warn("[CloverHub-SAE][sell] worker recovered: " .. tostring(result))
				task.wait(1)
				continue
			end

			break
		end
	end)
end

handlers.createFuseController = function(arg)
	local function fn46(arg2)
		return type(arg2) == "number" and arg2 == arg2 and arg2 >= 0 and arg2 < math.huge
	end

	local tbl17

	tbl17 = {
		owned = {},
		pending = nil,
		status = "Off",
		completed = 0,
		eligible = function(arg2, arg3, arg4, arg5)
			local settings_2 = arg.settings
			if type(arg3) ~= "table" or settings_2.FuseCategories[arg3.Category] ~= true then
				return false
			end
			local flag2 = not fn46(settings_2.FuseMinimumValue) or not fn46(settings_2.FuseKGThreshold)

			if not flag2 then
				flag2 = settings_2.FuseKGMode ~= "Any" and settings_2.FuseKGMode ~= "Above" and settings_2.FuseKGMode ~= "Below"
			end

			if flag2 then
				return false
			end

			if arg3.IsFavorite == true or arg3.InFuse == true ~= arg5 then
				return false
			end
			local v18 = pairs
			local equippedAssets = arg4.EquippedAssets or {}

			for _, equippedAsset in v18(equippedAssets) do
				if tostring(equippedAsset) == tostring(arg2) then
					return false
				end
			end

			if arg.protected(arg2, arg4) then
				return false
			end
			local ok, result = pcall(arg.mayEnter, arg2, arg3, nil, arg5)
			if not ok or result ~= true then
				return false
			end
			local ok2, result2 = pcall(arg.decode, arg3)
			if not ok2 or type(result2) ~= "table" then
				return false
			end

			if settings_2.FuseKGMode ~= "Any" and settings_2.FuseKGThreshold > 0 then
				local v19 = arg.weight(result2)
				if not fn46(v19) or arg.kgMatches(v19, settings_2.FuseKGMode, settings_2.FuseKGThreshold, true) then
					return false
				end
			end

			if settings_2.FuseMinimumValue > 0 then
				local v19, v20 = arg.value(result2)
				if not v20 or not fn46(v19) or v19 >= settings_2.FuseMinimumValue then
					return false
				end
			end

			return true, result2
		end,
		plan = function(arg2)
			if type(arg2) ~= "table" or type(arg2.Inventory) ~= "table" or type(arg2.FusionSlots) ~= "table" then
				return nil, "Waiting for fuse data"
			end
			local tbl18 = {}
			local tbl19 = {}
			local flag2 = nil

			for i = 1, 3 do
				local v18 = arg2.FusionSlots[i]

				if v18 then
					if tbl19[v18] or not tbl17.owned[v18] then
						return nil, "Machine has manually loaded pets"
					end
					tbl19[v18] = true
					local v19 = arg2.Inventory[v18]
					if not tbl17.eligible(v18, v19, arg2, true) then
						return nil, "Returning a protected pet", v18
					end
					flag2 = flag2 and v19.Category ~= flag2
					if flag2 then
						return nil, "Returning mismatched pet", v18
					end
					flag2 = v19.Category
					tbl18[#tbl18 + 1] = v18
				end
			end

			local tbl20 = {}

			if flag2 then
				tbl20[flag2] = table.clone(tbl18)
			end

			for k, v18 in pairs(arg2.Inventory) do
				if not tbl19[k] and (not flag2 or v18.Category == flag2) and tbl17.eligible(k, v18, arg2, false) then
					tbl20[v18.Category] = tbl20[v18.Category] or {}
					table.insert(tbl20[v18.Category], k)
				end
			end

			local tbl21 = {}

			for k, v18 in pairs(tbl20) do
				if #v18 >= 3 then
					tbl21[#tbl21 + 1] = k
				end
			end

			table.sort(tbl21)
			if #tbl21 == 0 then
				return nil, "Waiting for 3 eligible pets of one category"
			end
			local tbl22 = {}

			for _, v18 in ipairs(tbl20[tbl21[1]]) do
				if not tbl19[v18] then
					tbl22[#tbl22 + 1] = v18
				end
			end

			table.sort(tbl22, function(arg3, arg4)
				return tostring(arg3) < tostring(arg4)
			end)

			local v18 = table.clone(tbl18)

			for _, v19 in ipairs(tbl22) do
				if #v18 ~= 3 then
					v18[#v18 + 1] = v19
					continue
				end
				break
			end

			return { uids = v18, loaded = #tbl18, category = tbl21[1] }, "Ready"
		end,
		tick = function()
			if not arg.alive() then
				return
			end

			if not arg.idle() then
				tbl17.status = "Waiting for idle time"
				return
			end

			if not arg.ready() then
				tbl17.status = "Waiting for filter edits to finish"
				return
			end
			local v18 = arg.save()
			if type(v18) ~= "table" or type(v18.FusionSlots) ~= "table" then
				tbl17.status = "Waiting for fuse data"
				return
			end

			if tbl17.pending then
				local pending = tbl17.pending
				local flag2 = pending.action == "BeginFuse" and pending.uids ~= nil

				if flag2 then
					for _, uid in ipairs(pending.uids) do
						if v18.Inventory[uid] then
							flag2 = false
							break
						end
					end
				end

				local flag3 = pending.action == "LoadPet" and v18.Inventory[pending.uid] and v18.Inventory[pending.uid].InFuse == true
				local flag4

				if flag3 then
					flag4 = flag3
				else
					local flag5 = pending.action == "EjectPet"

					if flag5 then
						flag4 = not v18.Inventory[pending.uid] or not v18.Inventory[pending.uid].InFuse
					else
						flag4 = flag5
					end
				end

				local flag5 = not (flag4 or pending.action == "BeginFuse" and (v18.FusionLocked == true or type(v18.FusionEggReward) == "table" or flag2) or pending.action == "FinishReveal" and v18.FusionEggReward == false)
				local flag6

				if flag5 then
					local at = pending.at
					flag6 = arg.now() - at < 8
				else
					flag6 = flag5
				end

				if flag6 then
					tbl17.status = "Waiting for machine confirmation"
					return
				end

				if flag5 then
					arg.disable()
					tbl17.status = "Machine confirmation timed out; Auto Fuse stopped"
					tbl17.pending = nil
					return
				end

				tbl17.pending = nil
			end

			if v18.FusionEggReward ~= false and v18.FusionEggReward ~= nil then
				if not arg.settings.AutoFuse then
					tbl17.status = "Reward waiting in machine"
					return
				end

				if type(v18.FusionEndsAt) == "number" and v18.FusionEndsAt > arg.serverNow() then
					tbl17.status = "Fusing"
					return
				end
				tbl17.status = "Claiming fused egg"
				tbl17.pending = { action = "FinishReveal", at = arg.now() }
				local FinishReveal, v19 = arg.request("FinishReveal")

				if FinishReveal == false then
					tbl17.pending = nil
					tbl17.status = tostring(v19 or "Reward not ready")
				end

				return
			end

			if v18.FusionLocked == true then
				tbl17.status = "Fusing"
				return
			end
			local tbl18 = {}

			for _, fusionSlot in pairs(v18.FusionSlots) do
				if fusionSlot then
					tbl18[fusionSlot] = true
				end
			end

			for k in pairs(tbl17.owned) do
				if not tbl18[k] then
					tbl17.owned[k] = nil
				end
			end

			local v19, v20, v21 = tbl17.plan(v18)

			if not arg.settings.AutoFuse then
				local v22, v23, v24 = pairs(tbl17.owned)
				local v25 = table.pack(V_1())

				if v25[1] then
					v21 = v25[2]
				end

				if not v21 then
					tbl17.status = "Off"
					return
				end
			end

			if v21 then
				tbl17.status = "Returning protected/unused pet"
				tbl17.pending = { action = "EjectPet", uid = v21, at = arg.now() }
				local EjectPet, v22 = arg.request("EjectPet", v21)

				if EjectPet == false then
					tbl17.pending = nil
					tbl17.status = tostring(v22 or "Cannot return pet")
				end

				return
			end

			if not v19 then
				tbl17.status = v20
				return
			end
			local v22, v23, v24 = arg.capacity()
			if v22 or not v24 then
				tbl17.status = "Waiting for egg inventory space"
				return
			end
			local v25 = arg.price(v18, v19.uids)
			if not fn46(v25) or not fn46(v18.Money) or v18.Money < v25 then
				tbl17.status = "Waiting for fuse cost"
				return
			end

			if not arg.alive() or not arg.settings.AutoFuse or not arg.idle() or not arg.ready() then
				return
			end

			if v19.loaded < 3 then
				local v26 = v19.uids[v19.loaded + 1]
				local v27 = arg.save()
				local v28 = tbl17.plan(v27)
				if not v28 or v28.uids[v28.loaded + 1] ~= v26 or v28.loaded ~= v19.loaded then
					return
				end
				tbl17.owned[v26] = true
				tbl17.pending = { action = "LoadPet", uid = v26, at = arg.now() }
				tbl17.status = "Loading " .. v19.category .. " (" .. tostring(v19.loaded + 1) .. "/3)"
				local LoadPet, v29 = arg.request("LoadPet", v26)

				if LoadPet == false then
					tbl17.pending = nil
					tbl17.owned[v26] = nil
					tbl17.status = tostring(v29 or "Pet rejected")
				end
			else
				local v26 = arg.save()
				local v27 = tbl17.plan(v26)
				if not v27 or v27.loaded ~= 3 or v26.FusionLocked ~= false or v26.FusionEggReward ~= false then
					return
				end

				for i, uid in ipairs(v19.uids) do
					if v27.uids[i] ~= uid then
						return
					end
				end

				if not arg.settings.AutoFuse or not arg.idle() or not arg.ready() then
					return
				end
				tbl17.status = "Fusing " .. v19.category
				tbl17.pending = { action = "BeginFuse", at = arg.now(), uids = table.clone(v19.uids) }
				local BeginFuse, v28 = arg.request("BeginFuse")

				if BeginFuse == false then
					tbl17.pending = nil
					tbl17.status = tostring(v28 or "Fuse rejected")
				elseif BeginFuse == true then
					tbl17.completed = tbl17.completed + 1
				end
			end
		end,
	}

	return tbl17
end

local function fn46()
	local v18 = v3.__FuseTab:AddLeftGroupbox("Auto Fuse")
	v3.__FuseBox = v18
	local FuseStatus = nil

	chk.Merge(v18, function()
		FuseStatus = v18:AddLabel("FuseStatus", { Text = "Off", DoesWrap = true })
	end)

	local function fn47()
		fn10(true)
		handlers.markValueFilterChanged()
	end

	bindDropdownOverlay(v18, "FuseCategories", "Categories", tbl8.Items, {
		configKey = "FuseCategories",
		multi = true,
		store = tbl2.FuseCategories,
		text = "Categories",
		displayMap = tbl8.Display,
		tooltip = "Choose pets to fuse. Each fuse uses 3 matching pets.",
		onChange = fn47,
	})

	handlers.addKGFilterControls(v18, "Fuse", "FuseKGMode", "FuseKGThreshold", fn47, true)
	handlers.addValueFilterInput(v18, "FuseMinimumValue", "FuseMinimumValue", "Prevent Minimum Value", fn47, "Keep pets at this income per second and above. K, M, B, T work; 0 disables.")

	local AutoFuseToggle = (function()
	local _t = {Value = tbl2.AutoFuse, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.AutoFuse = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

	AutoFuseToggle:OnChanged(function(arg)
		tbl2.AutoFuse = arg == true
		fn10(true)
	end)
		GetValue = function()
			return tbl2.AutoFuse
		end,
		SetValue = function(arg, arg2)
			AutoFuseToggle:SetValue(arg2 == true)
		end,
	}

	local v19 = nil
	local AssetItems = nil
	local FuseKernel = nil
	local fusery = nil

	local function fn48()
		if v19 and AssetItems and FuseKernel and fusery then
			return true
		end

		return pcall(function()
			v19 = GetSaveModule()
			AssetItems = require(ReplicatedStorage.Shared.Util.AssetItems)
			FuseKernel = require(ReplicatedStorage.Shared.Util.FuseKernel)
			fusery = require(ReplicatedStorage.Shared.Remotes).Fusery
			assert(fusery.LoadPet and fusery.BeginFuse and fusery.FinishReveal and fusery.EjectPet)
		end)
	end

	local function fn49()
		return fn() and tbl14.free() and not tbl14.stealBusy() and not tbl14.critical and not critical and fn26() == nil and not handlers.carryLossRecoveryPending() and not tbl14.placeBusy and not tbl14.hatchBusy and not handlers.hatchPetOutputPending and not handlers.adminEventPending and not handlers.riftWantsBody and not handlers.greatBloomUnlockReturnPending
	end

	local v20 = handlers.createFuseController({
		settings = tbl2,
		now = os.clock,
		serverNow = function()
			return workspace:GetServerTimeNow()
		end,
		alive = fn,
		idle = fn49,
		ready = function()
			local flag2 = type(getthreadidentity) == "function" and getthreadidentity() or nil

			if type(setthreadidentity) == "function" then
				pcall(setthreadidentity, 8)
			end

			local ok, result = pcall(handlers.sellerValueFilterReady, "FuseMinimumValue")

			if flag2 and type(setthreadidentity) == "function" then
				pcall(setthreadidentity, flag2)
			end

			return ok and result == true
		end,
		save = function()
			local v20 = v19.Get()
			handlers.reconcileNewPetUids(v20)
			return v20
		end,
		decode = function(arg)
			return AssetItems.Decode(arg)
		end,
		mayEnter = function(...)
			return FuseKernel.MayEnterFuse(...)
		end,
		weight = fn23,
		kgMatches = handlers.kgFilterMatches,
		value = riftValueScore,
		protected = function(arg, arg2)
			return handlers.petSellUidProtected(arg, arg2, true) or handlers.greatBloomUnlockProtectCranePets == true and arg2.Inventory[arg].Category == "Crane"
		end,
		capacity = handlers.eggInventoryCapacityState,
		price = function(arg, arg2)
			local tbl17 = {}

			for _, v20 in ipairs(arg2) do
				tbl17[#tbl17 + 1] = AssetItems.Decode(arg.Inventory[v20])
			end

			return FuseKernel.PriceFor(tbl17)
		end,
		disable = function()
			tbl2.AutoFuse = false

			pcall(function()
				AutoFuseToggle:SetValue(false)
			end)

			fn10(true)
		end,
		request = function(arg, arg2)
			local ok, result, result2, result3 = pcall(function()
				if arg2 then
					return fusery[arg]:InvokeServer(arg2)
				end
				return fusery[arg]:InvokeServer()
			end)

			if not ok then
				return nil, tostring(result)
			end
			return result, result2, result3
		end,
	})

	if getgenv().__CHSAE_Debug then
		getgenv().__CHSAE_Debug.GetFuse = function()
			return {
				enabled = tbl2.AutoFuse,
				status = v20.status,
				completed = v20.completed,
				pending = v20.pending and v20.pending.action,
			}
		end

		getgenv().__CHSAE_Debug.PreviewFuse = function()
			if not fn48() then
				return { reason = "Fuse modules unavailable" }
			end
			local v21, v22 = v20.plan(v19.Get())
			return { category = v21 and v21.category, uids = v21 and v21.uids, reason = v22 }
		end
	end

	task.spawn(function()
		while fn() do
			local ok, result = pcall(function()
				if (tbl2.AutoFuse or v20.pending) and fn48() and not tbl14.petsBusy and fn49() then
					tbl14.petsSerial(function()
						v20.tick()
					end, "Auto Fuse")
				elseif tbl2.AutoFuse then
					v20.status = "Waiting for idle time"
				end
			end)

			if not ok then
				v20.status = "Fuse paused: " .. tostring(result)
			end

			if fn() then
				pcall(handlers.setLabel, FuseStatus, v20.status)
			end

			task.wait(1)
		end
	end)
end

fn46()

local function fn47()
	local v18 = nil
	local scrambleTradeIn = nil
	local AssetItems = nil
	local FuseKernel = nil
	local ScrambleTradeInEligibility = nil
	local EggRecords = nil
	local riftPlanner = handlers.RiftPlanner
	local v19 = nil
	local n2 = 0
	local tbl17 = nil
	local str = nil
	local n3 = 0
	local v20 = nil
	local n4 = 0

	local function fn48()
		if v18 and scrambleTradeIn and AssetItems and FuseKernel and ScrambleTradeInEligibility and EggRecords then
			return true
		end

		local ok, result = pcall(function()
			v18 = GetSaveModule()
			scrambleTradeIn = require(ReplicatedStorage.Shared.Remotes).ScrambleTradeIn
			AssetItems = require(ReplicatedStorage.Shared.Util.AssetItems)
			FuseKernel = require(ReplicatedStorage.Shared.Util.FuseKernel)
			ScrambleTradeInEligibility = require(ReplicatedStorage.Shared.Util.ScrambleTradeInEligibility)
			EggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)
		end)

		if not ok then
			str = tostring(result)
		end

		return ok and scrambleTradeIn ~= nil
	end

	handlers.eventText = function(arg, arg2)
		local str2 = tostring(arg):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
		return arg2 and "<font color=\"" .. arg2 .. "\">" .. str2 .. "</font>" or str2
	end

	v4 = event:AddLeftGroupbox("🧪 Dr. Scramble's Lab")
	local RiftEventLabel = nil
	local RiftFlowLabel = nil

	chk.Merge(v4, function()
		RiftEventLabel = v4:AddLabel("RiftEventLabel", { Text = "Checking the Lab", DoesWrap = true })
		RiftFlowLabel = v4:AddLabel("RiftFlowLabel", { Text = "🔴 Off", DoesWrap = true })
	end)

	if RiftEventLabel.TextLabel then
		RiftEventLabel.TextLabel.RichText = true
	end

	local bindableEvent2 = Instance.new("BindableEvent")
	getgenv().__CHSAE_RiftWake = bindableEvent2

	local function fn49(arg)
		if fn() then
			pcall(function()
				bindableEvent2:Fire(arg or "state")
			end)
		end
	end

	local function fn50(adminEventFlow)
		handlers.adminEventFlow = adminEventFlow
		handlers.setLabel(RiftFlowLabel, adminEventFlow)
		handlers.wakeOverlay("rift-flow")
	end

	local function fn51()
		local ok, result = pcall(v18.Get)
		if ok and type(result) == "table" and type(result.Inventory) == "table" and type(result.EggInventory) == "table" then
			return result
		end
		return nil
	end

	local function fn52()
		local flag2 = type(getthreadidentity) == "function" and getthreadidentity() or nil

		if type(setthreadidentity) == "function" then
			pcall(setthreadidentity, 8)
		end

		local ok, result = pcall(handlers.sellerValueFilterReady, "LabMinimumValue")

		if flag2 ~= nil and type(setthreadidentity) == "function" then
			pcall(setthreadidentity, flag2)
		end

		return ok and result == true
	end

	local function fn53()
		if tbl17 or os.clock() < n4 or not fn48() then
			return
		end
		tbl17 = { started = os.clock() }

		task.spawn(function()
			local ok, result = pcall(function()
				return scrambleTradeIn.AskState:InvokeServer()
			end)

			if not fn() then
				return
			end

			if ok and type(result) == "table" then
				local now3 = os.clock()
				v19 = result
				n2 = now3
				str = nil
			else
				str = tostring(result)
				n4 = os.clock() + 3
			end

			tbl17 = nil
			fn49("state")
		end)
	end

	local function fn54()
		if handlers.carryLossRecoveryPending() then
			return true
		end
		local chsaeCarryRequest = getgenv().__CHSAE_CarryRequest

		if type(chsaeCarryRequest) == "table" then
			if chsaeCarryRequest.inFlight then
				return true
			end
			local num = tonumber(chsaeCarryRequest.proofDeadline)

			if not num then
				num = (tonumber(chsaeCarryRequest.completedAt) or tonumber(chsaeCarryRequest.started) or 0) + 0.6
			end

			if chsaeCarryRequest.accepted and os.clock() <= num then
				return true
			end
		end

		return critical or fn26() ~= nil or tbl14.critical or tbl14.owner == "Steal" and tbl13.lockedUid ~= nil
	end

	local function normalStealTargetAvailable()
		if tbl2.AutoSteal ~= true then
			return false
		end
		local candidateIndex = handlers.candidateIndex
		if not (candidateIndex and type(candidateIndex.entries) == "table") then
			return false
		end

		local function fn55(arg)
			for _, v21 in pairs(arg) do
				if v21 then
					return true
				end
			end

			return false
		end

		local v21 = fn55(tbl2.TargetRarities)
		local v22 = fn55(tbl2.TargetCategories)
		local v23 = fn55(tbl2.TargetAreas)
		if not v21 and not v22 and not v23 and not tbl2.TargetPriority and not handlers.kgFilterActive(tbl2.TargetKGMode, tbl2.TargetKGThreshold) and not handlers.valueFilterActive(tbl2.TargetValueThreshold) then
			return false
		end

		for _, entry in ipairs(candidateIndex.entries) do
			local rec = entry.rec
			local rarity = entry.rarity
			local flag2 = rec and tostring(rec.State) == "Slot" and rec.BottomCFrame and rarity and not handlers.isCaptureEventUid(rec.Uid) and fn41(rec.AreaId) and not handlers.riftTargetBlocked(rec.Uid)
			local flag3

			if flag2 then
				flag3 = not v21 or tbl2.TargetRarities[tostring(rarity._id)] == true
			else
				flag3 = flag2
			end

			flag3 = flag3 and (not v22 or tbl2.TargetCategories[tostring(rec.AssetCategory)] == true)
			local flag4

			if flag3 then
				flag4 = not v23 or tbl2.TargetAreas[tostring(rec.AreaId)] == true
			else
				flag4 = flag3
			end

			flag4 = flag4 and handlers.kgFilterMatches(entry.weight, tbl2.TargetKGMode, tbl2.TargetKGThreshold, entry.weightKnown) and handlers.valueFilterMatches(entry.value, tbl2.TargetValueThreshold, "atLeast", entry.valueKnown) and (tbl2.TargetPriority ~= "Mutation" or #entry.mutations > 0)
			if flag4 then
				return true
			end
		end

		return false
	end

	handlers.normalStealTargetAvailable = normalStealTargetAvailable

	local function fn55()
		if tbl14.owner == "AdminEvent" then
			tbl14.critical = false
			tbl14.release("AdminEvent")
		end

		local v21 = handlers
		handlers.riftWantsBody = false
		v21.adminEventPending = false
		handlers.adminEventActive = false
		tbl15.refreshEventPending()
	end

	local function fn56()
		local v21 = handlers
		handlers.riftCollecting = false
		v21.riftTargetUid = nil
		handlers.riftPlacementWanted = false
		fn55()
	end

	local function fn57()
		local v21, v22, v23 = handlers.eggInventoryCapacityState()
		if not v21 then
			return true
		end
		fn56()
		n3 = math.max(n3, os.clock() + 3)
		fn50(("⏸️ Egg inventory full (%d/%d) · Lab trade paused"):format(tonumber(v22) or 0, tonumber(v23) or 0))
		return false
	end

	local function fn58(arg)
		local tbl18 = {}
		local tbl19 = {}

		for k, v21 in pairs(arg.EggInventory) do
			local ok, result = pcall(EggRecords.Decode, v21)
			local ok2, result2 = pcall(EggRecords.ToAssetItemData, ok and result or v21)
			local v22, v23 = handlers.riftValueScore(ok2 and result2 or v21)

			if v21.IsFavorite ~= true and v21.InFuse ~= true and riftPlanner.ValueAllowed(v22, v23, tbl2.LabMinimumValue) then
				local str2 = tostring(k)
				tbl19[str2] = true

				tbl18[#tbl18 + 1] = {
					uid = str2,
					category = ok2 and result2.Category or v21.AssetCategory or v21.Category,
					value = v22,
					placed = v21.Placement ~= nil,
				}
			end
		end

		return tbl18
	end

	local function fn59(arg)
		v20 = riftPlanner.PlanEggs(v19, fn58(arg))
		local v21 = handlers
		handlers.riftReservedPets = {}
		v21.riftReservedEggs = {}
		handlers.labReservedEggs = v20 and v20.eggs or {}
		local labNeededCategories = {}

		if v20 then
			for _, slot in ipairs(v20.slots) do
				labNeededCategories[slot.category] = true
			end
		end

		handlers.labNeededCategories = labNeededCategories
		handlers.riftInventoryCount = 0

		if v20 then
			local tbl18 = {
				"🧪 <b>" .. handlers.eventText(v19.BannerDisplayName or v19.BannerId or "Dr. Scramble's Lab") .. "</b>",
			}

			for _, slot in ipairs(v20.slots) do
				local flag2 = slot.eggUid ~= nil

				if flag2 then
					handlers.riftInventoryCount = handlers.riftInventoryCount + 1
				end

				tbl18[#tbl18 + 1] = handlers.eventText((flag2 and "✓ " or "○ ") .. slot.category, flag2 and "#58D6A5" or "#ED8796") .. "\n  " .. handlers.eventText(flag2 and "egg ready" or "missing egg", "#AAB1BC")
			end

			tbl18[#tbl18 + 1] = handlers.eventText(tostring(handlers.riftInventoryCount) .. "/" .. tostring(#v20.slots) .. " eggs ready to trade", "#AAB1BC")
			handlers.setLabel(RiftEventLabel, table.concat(tbl18, "\n"))
		end
	end

	local function fn60()
		local v21 = fn33()
		local riftFieldCount = 0
		local huge = math.huge
		local v22 = nil

		for _, v23 in pairs(fn24()) do
			if v23 and v20.missing[tostring(v23.AssetCategory)] and v23.BottomCFrame and (v23.State == "Slot" or v23.State == "Dropped") and not handlers.isCaptureEventUid(v23.Uid) and not handlers.riftTargetBlocked(v23.Uid) then
				local v24, v25 = handlers.riftValueScore(v23)

				if riftPlanner.ValueAllowed(v24, v25, tbl2.LabMinimumValue) then
					riftFieldCount += 1
					local magnitude = v21 and (v21.Position - v23.BottomCFrame.Position).Magnitude or 0

					if magnitude < huge then
						huge = magnitude
						v22 = v23
					end
				end
			end
		end

		handlers.riftFieldCount = riftFieldCount
		return v22
	end

	local function fn61()
		local chsaeRiftTransaction = getgenv().__CHSAE_RiftTransaction
		if type(chsaeRiftTransaction) == "table" and chsaeRiftTransaction.jobId ~= game.JobId then
			getgenv().__CHSAE_RiftTransaction = nil
			return nil
		end
		return type(chsaeRiftTransaction) == "table" and chsaeRiftTransaction or nil
	end

	local function fn62(arg)
		local v21 = fn61()
		if not v21 then
			return false
		end
		local v22 = tbl14
		local v23 = tbl14
		local remoteActivity = "Lab " .. tostring(v21.action)
		v22.petsBusy = true
		v23.remoteActivity = remoteActivity

		if next(v21.eggSet or {}) ~= nil then
			handlers.labReservedEggs = v21.eggSet
		end

		if tbl14.owner == "AdminEvent" and not tbl14.hold("AdminEvent") then
			fn55()
		end

		if v21.inFlight then
			fn50("⏳ Waiting for the Lab's reply")
			return true
		end
		local flag2 = v19

		if v19 then
			flag2 = n2 >= (v21.finishedAt or math.huge)
		end

		local v24 = pairs
		local eggSet = v21.eggSet or {}
		local flag3 = true

		for k in v24(eggSet) do
			if arg.EggInventory[k] then
				flag3 = false
			end
		end

		local flag4 = false

		for k in pairs(arg.EggInventory) do
			if not v21.eggsBefore[k] then
				flag4 = true
				break
			end
		end

		if flag2 then
			flag2 = v21.action == "trade" and flag3 and (v19.PendingReward or flag4) or v21.action == "claim" and not v19.PendingReward and flag4
		end

		local flag5 = v21.ok == false or v21.ok == true and v21.accepted == false

		if flag2 or flag5 then
			getgenv().__CHSAE_RiftTransaction = nil
			local v25 = tbl14
			tbl14.petsBusy = false
			v25.remoteActivity = nil
			fn55()
			n3 = os.clock() + (flag5 and 3 or 0.5)
			local v26 = fn50
			flag2 = flag2 and (v21.action == "claim" and "✅ Lab egg claimed" or "✅ Eggs traded in")

			if not flag2 then
				flag2 = "⏸️ Lab rejected: " .. tostring(v21.message or v21.accepted):sub(1, 110)
			end

			v26(flag2)
			return true
		end

		fn50("⏳ Verifying Lab " .. v21.action .. " · waiting for inventory and reward state")
		return true
	end

	local function fn63()
		if fn54() or tbl14.petsBusy or tbl14.hatchBusy or tbl14.placeBusy then
			return false
		end

		if tbl14.owner == "AdminEvent" and not tbl14.hold("AdminEvent") then
			fn55()
			return false
		end
		local v21 = handlers
		handlers.riftWantsBody = true
		v21.adminEventPending = true
		tbl15.refreshEventPending()
		tbl15.requestTreadmillExit()
		if tbl15.detectActiveTreadmill() ~= nil or not tbl14.acquire("AdminEvent") then
			return false
		end
		local v22 = handlers
		handlers.adminEventName = "Lab"
		v22.adminEventActive = true
		tbl14.hold("AdminEvent")
		return true
	end

	local function fn64(arg)
		if fn61() or os.clock() < n3 or not fn52() then
			return
		end

		if os.clock() - n2 > 1.5 or tbl17 then
			fn53()
			fn50("Refreshing Lab state before trading")
			return
		end

		if not fn57() then
			return
		end

		if not fn63() then
			return
		end
		local v21 = fn51()
		if not v21 or tbl2.AutoLab ~= true or not fn57() then
			fn55()
			return
		end

		local chsaeRiftTransaction = {
			jobId = game.JobId,
			action = arg,
			inFlight = true,
			started = os.clock(),
			eggSet = {},
			uids = {},
			eggsBefore = {},
		}

		for k in pairs(v21.EggInventory) do
			chsaeRiftTransaction.eggsBefore[k] = true
		end

		if arg == "trade" then
			local v22 = riftPlanner.PlanEggs(v19, fn58(v21))
			if not v22 or not v22.ready or v22.signature ~= v20.signature or v19.PendingReward then
				fn55()
				return
			end

			for i, slot in ipairs(v22.slots) do
				chsaeRiftTransaction.uids[i] = slot.eggUid
				chsaeRiftTransaction.eggSet[slot.eggUid] = true
			end

			handlers.labReservedEggs = chsaeRiftTransaction.eggSet
		elseif not v19.PendingReward then
			fn55()
			return
		end

		getgenv().__CHSAE_RiftTransaction = chsaeRiftTransaction
		local v22 = tbl14
		tbl14.petsBusy = true
		v22.remoteActivity = "Lab " .. arg
		fn50(arg == "trade" and "Trading in three requested eggs" or "Claiming Lab egg")

		task.spawn(function()
			local v23 = chsaeRiftTransaction
			local v24 = chsaeRiftTransaction
			local v25 = chsaeRiftTransaction

			local ok, accepted, message = pcall(function()
				if arg == "trade" then
					return scrambleTradeIn.AskTradeIn:InvokeServer(chsaeRiftTransaction.uids)
				end
				return scrambleTradeIn.AskFinishReveal:InvokeServer()
			end)

			v23.ok = ok
			v24.accepted = accepted
			v25.message = message
			local v26 = chsaeRiftTransaction
			chsaeRiftTransaction.finishedAt = os.clock()
			v26.inFlight = false

			if fn() then
				fn53()
				fn49("response")
			end
		end)
	end

	local function fn65()
		if not fn48() then
			fn50("Lab modules unavailable")
			return
		end

		if os.clock() - n2 > 3 then
			fn53()
		end

		local v21 = fn51()
		if not v21 then
			fn50("Waiting for inventory")
			return
		end

		if fn62(v21) then
			if tbl14.owner == "AdminEvent" then
				tbl14.hold("AdminEvent")
			end

			return
		end

		handlers.riftActive = type(v19) == "table" and v19.Unlocked == true
		handlers.adminEventStatus = handlers.riftActive and "Lab is live" or "Lab is unavailable"

		if tbl2.AutoLab ~= true then
			fn56()
			local v22 = handlers
			handlers.riftReservedPets = {}
			v22.riftReservedEggs = {}
			local v23 = handlers
			handlers.labReservedEggs = {}
			v23.labNeededCategories = {}

			if v19 and riftPlanner.Signature(v19) then
				local tbl18 = {}
				local str2 = "🧪 <b>" .. handlers.eventText(v19.BannerDisplayName or v19.BannerId) .. "</b>"
				local v24 = table.pack(handlers.eventText("Requested eggs", "#AAB1BC"))
				tbl18[1] = str2

				do
					local values = table.pack(table.unpack(v24, 1, v24.n))
					table.move(values, 1, values.n, 2, tbl18)
				end

				for _, requirement in ipairs(v19.Requirements) do
					tbl18[#tbl18 + 1] = handlers.eventText("○ " .. tostring(requirement), "#F5C76B")
				end

				handlers.setLabel(RiftEventLabel, table.concat(tbl18, "\n"))
			end

			fn50("🔴 Off")
			return
		end

		if not v19 or os.clock() - n2 > 10 then
			fn56()
			fn50(str and "Lab state unavailable" or "Checking Lab requests")
			return
		end

		if v19.Unlocked ~= true then
			fn56()
			fn50("Lab is locked for your speed")
			return
		end

		if not v19.PendingReward and not handlers.labRotationAllowed(v19.BannerId) then
			fn56()
			local v22 = handlers
			handlers.labReservedEggs = {}
			v22.labNeededCategories = {}
			fn50("⏸️ Skipping " .. tostring(v19.BannerDisplayName or v19.BannerId) .. " · not a selected rotation")
			return
		end

		fn59(v21)

		if not fn52() then
			if not fn54() then
				fn56()
			end

			fn50("Waiting for the protection value to finish editing")
			return
		end

		local pendingReward = v19.PendingReward
		local v22 = riftPlanner.LabAction(fn54(), normalStealTargetAvailable(), pendingReward, v20)
		if v22 == "transaction" then
			fn50("Finishing the current steal")
			return
		end
		fn56()

		if v22 == "normal" then
			fn50("Normal steal has priority")
		elseif v22 == "trade" or v22 == "claim" then
			fn64(v22, v21)
		elseif v22 == "collect" then
			local v23 = fn60()

			if v23 then
				local v24 = handlers
				local v25 = handlers
				local riftTargetUid = tostring(v23.Uid)
				v24.riftCollecting = true
				v25.riftTargetUid = riftTargetUid
				fn50("Collecting " .. tostring(v23.AssetCategory))

				if fn12 then
					fn12("rift-collect")
				end
			else
				fn50("Waiting for a requested egg to spawn")
			end
		else
			fn50("Waiting for the Lab's three requests")
		end
	end

	handlers.labRotationAllowed = function(arg)
		if next(tbl2.LabRotations) == nil then
			return true
		end
		return tbl2.LabRotations[tostring(arg)] == true
	end

	local tbl18 = { "Biohazard", "Experimental", "UnstableDNA" }
	local tbl19 = {}
	local tbl20 = { Biohazard = "Biohazard Pets", Experimental = "Experimental Pets", UnstableDNA = "Unstable DNA" }
	local tbl21 = { Biohazard = "#8BE36B", Experimental = "#7AB8FF", UnstableDNA = "#C78BFF" }
	local tbl22 = {}

	pcall(function()
		for _, banner in ipairs(require(ReplicatedStorage.Data.ScrambleTradeIn).Banners) do
			tbl22[banner.Id] = banner
		end
	end)

	for _, v21 in ipairs(tbl18) do
		local tbl23 = tbl22[v21] or {}
		local str2 = tbl23.From and tbl23.To and tostring(tbl23.From) .. " → " .. tostring(tbl23.To) or nil

		if tonumber(tbl23.Weight) then
			str2 = str2 and str2 .. " · "
			str2 = (str2 or "") .. tostring(tbl23.Weight) .. "%"
		end

		tbl19[v21] = string.format("<font color=\"%s\"><b>%s</b></font>", tbl21[v21], tbl23.DisplayName or tbl20[v21]) .. (str2 and string.format(" <font color=\"#9AA0AA\">%s</font>", str2) or "")
	end

	bindDropdownOverlay(v4, "LabRotations", "Rotations", tbl18, {
		configKey = "LabRotations",
		multi = true,
		store = tbl2.LabRotations,
		text = "Rotations",
		displayMap = tbl19,
		tooltip = "Only run the Lab during these egg rotations. Empty = every rotation.",
		onChange = function()
			fn10(true)
			fn49("rotation")
		end,
	})

	handlers.addValueFilterInput(v4, "LabMinimumValue", "LabMinimumValue", "Protect Minimum Value", function()
		fn49("protection")
	end, "Never trade in eggs worth at least this much per second. K, M, B, T work; 0 disables.")

	local AutoLabToggle = (function()
	local _t = {Value = tbl2.AutoLab, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.AutoLab = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

	AutoLabToggle:OnChanged(function(arg)
		tbl2.AutoLab = arg == true

		if not arg then
			handlers.riftCollecting = false
			handlers.riftPlacementWanted = false

			if not fn61() then
				fn56()
			end
		end

		fn10(true)
		fn49("toggle")

		if fn12 then
			fn12("rift-toggle")
		end
	end)

	tbl2.PriorityEvent = false

	if getgenv().__CHSAE_Debug then
		getgenv().__CHSAE_Debug.GetRift = function()
			return {
				State = v19,
				Plan = v20,
				Flow = handlers.adminEventFlow,
				MinimumValue = tbl2.LabMinimumValue,
				PriorityEvent = tbl2.PriorityEvent,
				Request = fn61(),
				Error = str,
			}
		end

		getgenv().__CHSAE_Debug.PreviewRift = function()
			local v21 = fn48() and fn51()
			return v21 and riftPlanner.PlanEggs(v19, fn58(v21)) or nil
		end
	end

	local flag2 = false

	fn17(bindableEvent2.Event, function()
		flag2 = true
	end)

	fn17(bindableEvent.Event, function(arg)
		if arg ~= "rift-collect" and (tbl2.AutoLab or fn61()) then
			fn49(arg)
		end
	end)

	for _, v21 in ipairs({
		"AreaEggRecordUpdated",
		"AreaEggRecordRemoved",
		"AreaEggCarryStateChanged",
		"RuntimeSnapshotUpdated",
	}) do
		fn17(tbl11[v21], function()
			if tbl2.AutoLab or fn61() then
				fn49("eggs")
			end
		end)
	end

	task.spawn(function()
		if fn48() and scrambleTradeIn.BannerRotated then
			fn17(scrambleTradeIn.BannerRotated.OnClientEvent, function()
				n2 = 0
				fn49("banner")
			end)
		end

		while fn() do
			flag2 = false
			local ok, result = pcall(fn65)

			if not ok then
				if not fn61() then
					fn56()
				end

				fn50("Lab paused: " .. tostring(result):sub(1, 140))
			end

			if fn() then
				if not flag2 then
					local now3 = os.clock()
					local n5 = (not v19 or tbl17) and now3 + 3 or math.max(n2 + 3, n4)
					local n6

					if not (now3 < n3) then
						n6 = n5
					else
						n6 = math.min(n5, n3)
					end

					if not ok then
						n6 = now3 + 3
					end

					local thread = task.delay(math.max(0.1, n6 - now3), function()
						fn49("deadline")
					end)

					bindableEvent2.Event:Wait()
					pcall(task.cancel, thread)
				end

				if fn() then
					task.wait(0.1)
				end

				continue
			end

			break
		end
	end)
end

fn47()
v3.__EventShopBox = event:AddLeftGroupbox("🛍️ Event Shop")

do
	local scramble = { revision = -1, fullRevision = -1, nextSnapshot = 0, stopped = false }
	handlers.Scramble = scramble
	local eventShopBox = v3.__EventShopBox
	local ScrambleShopStatus = nil

	chk.Merge(eventShopBox, function()
		ScrambleShopStatus = eventShopBox:AddLabel("ScrambleShopStatus", { Text = "Off", DoesWrap = true })
	end)

	local bindableEvent2 = Instance.new("BindableEvent")
	local thread = nil
	local flag2 = false

	local function wake()
		if scramble.stopped or not fn() then
			return
		end
		flag2 = true
		bindableEvent2:Fire()
	end

	local function fn48(status)
		if scramble.status == status then
			return
		end
		scramble.status = status
		handlers.setLabel(ScrambleShopStatus, status)
	end

	scramble.wake = wake

	scramble.masteryClaimId = function(arg)
		local ok, result = pcall(require, ReplicatedStorage.Data.ScrambleMastery)
		if not ok or type(arg) ~= "table" or type(arg.ClaimedMilestoneIds) ~= "table" then
			return nil
		end
		local n2 = tonumber(arg.Mastery) or 0

		for _, milestone in ipairs(result.Milestones) do
			if n2 >= milestone.Kills and not arg.ClaimedMilestoneIds[milestone.Id] then
				return milestone.Id
			end
		end

		if result.ClaimableInfiniteCount(arg) > 0 then
			return result.InfiniteMilestoneId
		end
		return nil
	end

	scramble.masteryText = function(arg)
		local ok, result = pcall(require, ReplicatedStorage.Data.ScrambleMastery)
		if not ok or type(arg) ~= "table" then
			return "Mastery: checking"
		end
		local n2 = tonumber(arg.Mastery) or 0
		if scramble.masteryClaimId(arg) then
			return "Mastery: " .. n2 .. " kills · reward ready"
		end

		for _, milestone in ipairs(result.Milestones) do
			if n2 < milestone.Kills then
				return "Mastery: " .. n2 .. " kills · next reward at " .. milestone.Kills
			end
		end

		return "Mastery: " .. n2 .. " kills"
	end

	local function fn49()
		return not scramble.stopped and fn() and (tbl2.AutoScrambleShop or tbl2.AutoClaimBossMastery)
	end

	local function fn50()
		local snapshot = scramble.snapshot
		local flag3 = fn49() and snapshot and snapshot.Ready == true and snapshot.Enabled == true and snapshot.WorldReady == true
		local flag4

		if flag3 then
			flag4 = workspace:GetServerTimeNow() < (tonumber(snapshot.EventEndsAt) or 0)
		else
			flag4 = flag3
		end

		return flag4
	end

	local function fn51(snapshot)
		if scramble.stopped or not fn() or type(snapshot) ~= "table" then
			return
		end
		local revision = snapshot.Revision
		if type(revision) ~= "number" then
			return
		end

		if scramble.revision < revision then
			scramble.revision = revision
			local v18 = scramble
			local ready = snapshot.Ready
			scramble.state = snapshot.State
			v18.ready = ready
		end

		if not snapshot.Patch and revision > scramble.fullRevision then
			scramble.fullRevision = revision
			scramble.snapshot = snapshot
		end

		if scramble.snapshot then
			local snapshot2 = scramble.snapshot
			local ready = scramble.ready
			scramble.snapshot.State = scramble.state
			snapshot2.Ready = ready
		end

		if scramble.masteryLabel and type(scramble.state) == "table" then
			handlers.setLabel(scramble.masteryLabel, scramble.masteryText(scramble.state))
		end

		wake()
	end

	scramble.Disconnect = function(arg)
		if arg.stopped then
			return
		end
		arg.stopped = true

		if thread then
			pcall(task.cancel, thread)
			thread = nil
		end

		bindableEvent2:Fire()
		bindableEvent2:Destroy()
	end

	getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = scramble

	local function fn52(arg, arg2, arg3)
		if scramble.busy or not scramble.remotes or scramble.stopped or not fn() or arg ~= "Snapshot" and not fn49() then
			return false
		end
		local busy = {}
		scramble.busy = busy

		task.spawn(function()
			local flag3 = arg == "Snapshot"

			if arg == "Shop" then
				flag3 = tbl2.AutoScrambleShop == true and tbl2.ScrambleShopItems[arg2] == true and fn50()
			elseif arg == "Milestone" then
				flag3 = tbl2.AutoClaimBossMastery == true and fn50()
			end

			if scramble.stopped or not fn() or not flag3 then
				if scramble.busy == busy then
					scramble.busy = nil
				end

				wake()
				return
			end

			local ok, result = pcall(function()
				return scramble.remotes.Request:InvokeServer(arg, arg2, arg3)
			end)

			if scramble.stopped or not fn() or scramble.busy ~= busy then
				return
			end
			scramble.busy = nil
			local flag4

			if ok and type(result) == "table" then
				fn51(arg == "Snapshot" and result or result.Snapshot)
				local flag5 = arg ~= "Snapshot" and result.Ok ~= true
				flag4 = false

				if flag5 then
					fn48("Request declined: " .. tostring(result.Reason or result.Error or arg))
					flag4 = true
				end
			else
				fn48("Event request failed")
				flag4 = true
			end

			if flag4 then
				if arg == "Shop" then
					scramble.nextShop = os.clock() + 5
				elseif arg == "Milestone" then
					scramble.nextMastery = os.clock() + 10
				end

				if arg ~= "Snapshot" then
					scramble.nextSnapshot = 0
				end
			end

			wake()
		end)

		return true
	end

	bindDropdownOverlay(eventShopBox, "ScrambleShopItemsDropdown", "Scramble items", {
		"MutationConsumable",
		"LimitedTimeExperimentPet",
		"Nibbles013",
		"CashBooster",
		"SpeedBoost",
		"TreadmillBooster",
	}, {
		configKey = "ScrambleShopItems",
		multi = true,
		store = tbl2.ScrambleShopItems,
		text = "Scramble items",
		displayMap = {
			MutationConsumable = "Scrambled mutation",
			LimitedTimeExperimentPet = "Experiment #001",
			Nibbles013 = "Nibbles #013",
			CashBooster = "2x Cash",
			SpeedBoost = "1.25x Speed",
			TreadmillBooster = "2x Treadmill",
		},
		onChange = function()
			fn10(true)
			wake()
		end,
	})

	local AutoScrambleShopToggle = (function()
	local _t = {Value = tbl2.AutoScrambleShop, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.AutoScrambleShop = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

	AutoScrambleShopToggle:OnChanged(function(arg)
		tbl2.AutoScrambleShop = arg == true
		scramble.nextSnapshot = 0
		fn10(true)
		wake()
	end)

	local function fn53()
		if not scramble.remotes then
			scramble.remotes = require(ReplicatedStorage.Shared.Remotes).Scramble
			if not scramble.remotes then
				fn48("Event unavailable")
				return
			end
			local connection = scramble.remotes.State.OnClientEvent:Connect(fn51)
			getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = connection
		end

		if scramble.busy then
			return
		end
		local nextSnapshot = scramble.nextSnapshot

		if os.clock() >= nextSnapshot then
			scramble.nextSnapshot = os.clock() + (fn49() and 10 or 30)
			fn52("Snapshot")
			return
		end

		if not fn49() then
			fn48("Off")
			return
		end

		if not fn50() then
			fn48("Waiting for event availability")
			return
		end
		local snapshot = scramble.snapshot
		local state2 = scramble.state
		if type(state2) ~= "table" then
			return
		end
		local flag3 = tbl2.AutoScrambleShop and not tbl2.Stall

		if flag3 then
			flag3 = os.clock() >= (scramble.nextShop or 0)
		end

		if flag3 then
			local v18 = ipairs
			local shop = snapshot.Shop or {}

			for _, v19 in v18(shop) do
				local v20 = (state2.ShopPurchases or {})[v19.Id]
				local flag4 = type(v20) == "table" and v20.Period == snapshot.ShopPeriod
				local n2

				if flag4 then
					n2 = tonumber(v20.Count) or 0
				else
					n2 = flag4
				end

				n2 = n2 or 0
				local flag5 = tbl2.ScrambleShopItems[v19.Id] and type(v19.Price) == "number" and v19.Price > 0

				if flag5 then
					flag5 = (state2.Samples or 0) >= v19.Price
				end

				flag5 = flag5 and type(v19.Quote) == "string"
				local flag6

				if flag5 then
					local flag7 = not v19.PurchaseLimit

					if flag7 then
						flag6 = flag7
					else
						flag6 = n2 + (v19.Quantity or 1) <= v19.PurchaseLimit
					end
				else
					flag6 = flag5
				end

				if flag6 then
					fn48("Buying " .. tostring(v19.Label))
					scramble.nextShop = os.clock() + 2
					fn52("Shop", v19.Id, { Quote = v19.Quote, Sequence = state2.ShopSequence })
					return
				end
			end
		end

		local autoClaimBossMastery = tbl2.AutoClaimBossMastery

		if autoClaimBossMastery then
			autoClaimBossMastery = os.clock() >= (scramble.nextMastery or 0)
		end

		if autoClaimBossMastery then
			local v18 = scramble.masteryClaimId(state2)

			if v18 then
				scramble.nextMastery = os.clock() + 2
				fn52("Milestone", v18)
				return
			end
		end

		local v18 = fn48
		local autoScrambleShop = tbl2.AutoScrambleShop

		if autoScrambleShop then
			autoScrambleShop = "🟢 Watching the shop · " .. tostring(state2.Samples or 0) .. " samples"
		end

		v18(autoScrambleShop or "Off")
	end

	task.spawn(function()
		while true do
			if fn() and not scramble.stopped then
				flag2 = false
				local ok, result = pcall(fn53)

				if not ok then
					fn48("Paused: " .. tostring(result))
				end

				if not (scramble.stopped or not fn()) then
					if fn49() then
						task.wait(0.25)
					elseif not flag2 then
						thread = task.delay(1, wake)
						bindableEvent2.Event:Wait()

						if thread then
							pcall(task.cancel, thread)
							thread = nil
						end
					end

					continue
				end
			end

			break
		end

		scramble:Disconnect()
	end)
end

do
	local scramble = handlers.Scramble
	local scrambleBoss = { stopped = false, status = "Off" }
	handlers.ScrambleBoss = scrambleBoss
	local v18 = event:AddRightGroupbox("⚔️ Scramble Boss")
	v3.__ScrambleBossBox = v18
	local ScrambleBossStatus = nil
	local ScrambleBossMasteryStatus = nil
	local ScrambleBossTimer = nil

	chk.Merge(v18, function()
		ScrambleBossTimer = v18:AddLabel("ScrambleBossTimer", { Text = "Next boss: checking", DoesWrap = true })
		ScrambleBossStatus = v18:AddLabel("ScrambleBossStatus", { Text = "Off", DoesWrap = true })
		ScrambleBossMasteryStatus = v18:AddLabel("ScrambleBossMasteryStatus", { Text = "Mastery: checking", DoesWrap = true })
	end)

	scramble.masteryLabel = ScrambleBossMasteryStatus

	if scramble.state then
		handlers.setLabel(ScrambleBossMasteryStatus, scramble.masteryText(scramble.state))
	end

	local scrambleBoss2 = require(ReplicatedStorage.Shared.Remotes).ScrambleBoss
	local clientCooldown = require(ReplicatedStorage.Shared.Flags.GameplayBalance).BatClient.CLIENT_COOLDOWN
	local ScrambleBossHazards = require(ReplicatedStorage.Shared.Util.ScrambleBossHazards)
	local tbl17 = {}
	local bindableEvent2 = Instance.new("BindableEvent")

	local function fn48()
		if not scrambleBoss.stopped then
			bindableEvent2:Fire()
		end
	end

	local function fn49(status)
		if scrambleBoss.status == status then
			return
		end
		scrambleBoss.status = status
		handlers.setLabel(ScrambleBossStatus, status)
	end

	local function fn50()
		local scrambleArena = workspace:FindFirstChild("ScrambleArena")
		return scrambleArena and scrambleArena:IsA("Model") and scrambleArena or nil
	end

	local function fn51()
		return localPlayer:GetAttribute("InScrambleArena") == true
	end

	if ScrambleBossTimer.TextLabel then
		ScrambleBossTimer.TextLabel.RichText = true
	end

	local value = select(2, pcall(require, ReplicatedStorage.Shared.Flags.ScrambleBossFlags))

	local function fn52()
		local v19 = fn50()
		local serverTimeNow = workspace:GetServerTimeNow()
		local timerText, str

		if v19 then
			local str2 = tostring(v19:GetAttribute("Phase") or "Waiting")

			if str2 == "Mech" then
				str2 = "Mech " .. math.floor(tonumber(v19:GetAttribute("Health")) or 0) .. "/" .. math.floor(tonumber(v19:GetAttribute("MaxHealth")) or 0) .. " HP"
			end

			timerText = "Boss fight live · " .. str2
			str = "#58D6A5"
		else
			local ok, result = pcall(function()
				return value.ContentEnabled:Get() and value.ScheduleEnabled:Get() and value.ScheduleIntervalSeconds:Get()
			end)

			ok = ok and type(result) == "number" and result > 0
			timerText = "Boss schedule unavailable"
			str = "#79C7F2"

			if ok then
				local v20 = math.ceil((math.floor(serverTimeNow / result) + 1) * result - serverTimeNow)
				timerText = string.format("Next boss in %02d:%02d", math.floor(v20 / 60), v20 % 60)
			end
		end

		if scrambleBoss.timerText == timerText then
			return
		end
		scrambleBoss.timerText = timerText
		handlers.setLabel(ScrambleBossTimer, "<b>" .. handlers.eventText(timerText, str) .. "</b>")
	end

	task.spawn(function()
		while fn() and not scrambleBoss.stopped do
			pcall(fn52)
			task.wait(1)
		end
	end)

	local function fn53(arg)
		if handlers.scrambleBossPending == arg == true then
			return
		end
		handlers.scrambleBossPending = arg == true
		tbl15.refreshEventPending()
	end

	local function fn54()
		if scrambleBoss.flight then
			scrambleBoss.flight:Stop()
			scrambleBoss.flight = nil
		end
	end

	local function fn55()
		local v19 = scrambleBoss
		local v20 = scrambleBoss
		scrambleBoss.goal = nil
		v19.readyAt = nil
		v20.follow = nil
		local v21 = scrambleBoss
		scrambleBoss.lastRoot = nil
		v21.lastInArena = nil
		table.clear(tbl17)
		fn54()

		if scrambleBoss.conn then
			scrambleBoss.conn:Disconnect()
			scrambleBoss.conn = nil
		end

		fn53(false)

		if tbl14.owner == "ScrambleBoss" then
			local character = localPlayer.Character
			local backpack = localPlayer:FindFirstChildOfClass("Backpack")

			if scrambleBoss.bat and scrambleBoss.bat.Parent == character and scrambleBoss.bat ~= scrambleBoss.previousTool and backpack then
				scrambleBoss.bat.Parent = backpack
			end

			tbl14.release("ScrambleBoss")
		end

		local v22 = scrambleBoss
		local v23 = scrambleBoss
		local v24 = scrambleBoss
		scrambleBoss.bat = nil
		v22.previousTool = nil
		v23.character = nil
		v24.exiting = false
	end

	local function fn56(arg, arg2)
		if typeof(arg) ~= "Instance" then
			return nil
		end

		if arg:IsA("BasePart") then
			local v19 = arg.CFrame:PointToObjectSpace(arg2)
			local n2 = arg.Size * 0.5
			local cFrame = arg.CFrame
			local pointToWorldSpace = cFrame.PointToWorldSpace
			local v20 = cFrame
			local clamp = math.clamp
			local z = v19.Z
			local n3 = -n2.Z
			local z2 = n2.Z
			return pointToWorldSpace(v20, Vector3.new(math.clamp(v19.X, -n2.X, n2.X), math.clamp(v19.Y, -n2.Y, n2.Y), clamp(z, n3, z2)))
		end

		if arg:IsA("Bone") or arg:IsA("Attachment") then
			return arg.WorldPosition
		end

		if arg:IsA("Model") then
			return arg:GetPivot().Position
		end
		return nil
	end

	local function fn57(arg)
		local scrambleHuman = arg:FindFirstChild("ScrambleHuman")
		local hitbox = scrambleHuman and (scrambleHuman:FindFirstChild("Hitbox", true) or scrambleHuman.PrimaryPart)
		return hitbox and hitbox:IsA("BasePart") and hitbox or nil, scrambleHuman
	end

	local function fn58(arg)
		local attribute = arg:GetAttribute("Phase")
		local userId = localPlayer.UserId

		if attribute == "Ball" and arg:GetAttribute("BallTarget") == userId and not arg:GetAttribute("BallStunned") then
			local coils = arg:FindFirstChild("Coils")

			if coils then
				coils = coils:FindFirstChild(tostring(arg:GetAttribute("BallCoil") or ""))
			end

			if coils then
				coils = coils:FindFirstChild("Zone") or coils:FindFirstChild("Top")
			end

			if coils then
				return "Leading the ball into the coil", coils, true
			end
		end

		local mech = arg:FindFirstChild("Mech")
		local n2 = attribute == "Mech" and tonumber(arg:GetAttribute("GrabVictim")) or 0
		local grabRescue = mech and mech:FindFirstChild("GrabRescue")
		if n2 ~= 0 and n2 ~= userId and grabRescue then
			return "Freeing a grabbed player", grabRescue
		end

		if attribute == "Mech" then
			if mech then
				mech = mech:FindFirstChild("Hitbox") or mech:FindFirstChild("Torso")
			end

			if mech then
				return "Hitting the mech", mech
			end
		elseif attribute == "Ball" and arg:GetAttribute("BallStunned") then
			local ball = arg:FindFirstChild("Ball")

			if ball then
				ball = ball:FindFirstChild("Hitbox", true) or ball.PrimaryPart
			end

			if ball then
				return "Hitting the core", ball
			end
		elseif attribute == "Human" or attribute == "Final" then
			local v19, v20 = fn57(arg)
			if v19 and v20:GetAttribute("Immune") ~= true then
				return "Hitting Dr. Scramble", v19
			end
		end

		return nil
	end

	local function fn59(followPart, arg)
		local now3 = os.clock()
		local position = followPart.Position

		if scrambleBoss.followPart ~= followPart then
			local v19 = scrambleBoss
			local v20 = scrambleBoss
			local v21 = scrambleBoss
			scrambleBoss.followPart = followPart
			v19.followVelocity = Vector3.zero
			v20.followLast = position
			v21.followAt = now3
		elseif arg and now3 - scrambleBoss.followAt >= 0.005 then
			local n2 = (position - scrambleBoss.followLast) * Vector3.new(1, 0, 1)
			scrambleBoss.followVelocity = n2.Magnitude > 40 and Vector3.zero or scrambleBoss.followVelocity:Lerp(n2 / (now3 - scrambleBoss.followAt), 0.3)
			local v19 = scrambleBoss
			scrambleBoss.followLast = position
			v19.followAt = now3
		end

		local n2 = scrambleBoss.followVelocity * (0.15 + 2 * localPlayer:GetNetworkPing())
		return position + n2 + Vector3.new(0, followPart.Size.Y / 2 + 3, 0), n2
	end

	local function fn60(arg)
		for _, v19 in ipairs({ arg, localPlayer:FindFirstChildOfClass("Backpack") }) do
			if v19 then
				for _, child in ipairs(v19:GetChildren()) do
					if child:IsA("Tool") and child:GetAttribute("IsBat") == true then
						return child
					end
				end
			end
		end

		return nil
	end

	handlers.swapBatSwing = function(arg, arg2, arg3)
		local character = localPlayer.Character
		local backpack = localPlayer:FindFirstChildOfClass("Backpack")
		if not character or not backpack then
			return nil
		end
		local serverTimeNow = workspace:GetServerTimeNow()
		arg.batReadyAt = arg.batReadyAt or setmetatable({}, { __mode = "k" })
		arg.batLastUsed = arg.batLastUsed or setmetatable({}, { __mode = "k" })

		if not arg.batClientCooldown then
			arg.batClientCooldown = require(ReplicatedStorage.Shared.Flags.GameplayBalance).BatClient.CLIENT_COOLDOWN
		end

		if serverTimeNow < (arg.nextBatAttack or 0) then
			return "wait"
		end
		local tool = character:FindFirstChildOfClass("Tool")
		local n2 = 0
		local v19 = nil

		for _, v20 in ipairs({ character, backpack }) do
			for _, child in ipairs(v20:GetChildren()) do
				if child:IsA("Tool") and (child:GetAttribute("IsBat") == true or child:GetAttribute("GearName") == "Flyswatter" or child:GetAttribute("GearName") == "The Scrambler") then
					n2 += 1
					local flag2 = child ~= arg.lastBat

					if flag2 then
						flag2 = serverTimeNow >= (arg.batReadyAt[child] or 0)
					end

					flag2 = flag2 and child.Enabled and child:GetAttribute("CooldownActive") ~= true

					if flag2 then
						flag2 = serverTimeNow >= (tonumber(child:GetAttribute("CooldownEndTime")) or 0)
					end

					if flag2 then
						local flag3 = not v19
						local flag4

						if flag3 then
							flag4 = flag3
						else
							flag4 = (arg.batLastUsed[child] or -math.huge) < (arg.batLastUsed[v19] or -math.huge)
						end

						if flag4 then
							v19 = child
						end
					end
				end
			end
		end

		if n2 < 2 then
			return "single"
		end

		if not v19 then
			return "cooldown"
		end

		if v19 ~= tool then
			arg2:EquipTool(v19)
			arg.bat = v19
			arg.nextBatAttack = serverTimeNow + 0.15
			return "equip"
		end

		arg.nextBatAttack = serverTimeNow + 0.15
		local flag2 = v19:GetAttribute("IsBat") ~= true and (v19:GetAttribute("GearName") == "Flyswatter" or v19:GetAttribute("GearName") == "The Scrambler")
		if not arg3(v19, flag2) then
			return "blocked"
		end
		local trigger = nil

		if flag2 then
			local ToolGameplayGuard = require(ReplicatedStorage.Client.ToolGameplayGuard)
			if v19.Parent ~= character or not ToolGameplayGuard.AllowsLocalUse(v19) then
				return "blocked"
			end
			trigger = require(ReplicatedStorage.Shared.Remotes).ToolTrigger.Trigger
		end

		arg.bat = v19

		if flag2 then
			trigger:FireServer(v19)
		else
			v19:Activate()
		end

		arg.lastBat = v19
		arg.batLastUsed[v19] = serverTimeNow
		arg.batReadyAt[v19] = serverTimeNow + (flag2 and 0 or arg.batClientCooldown)
		return "fired"
	end

	local function fn61(arg, arg2)
		local serverTimeNow = workspace:GetServerTimeNow()
		local flag2 = arg.Y - arg2 > 5

		for i = #tbl17, 1, -1 do
			local v19 = tbl17[i]
			local ok, result = pcall(ScrambleBossHazards.ActiveSeconds, v19)
			if not ok or serverTimeNow > v19.At + result + 0.2 then
				table.remove(tbl17, i)
				continue
			end

			if not (v19.At - serverTimeNow <= 1.2) then
				continue
			end
			local n2 = math.max(0, serverTimeNow - v19.At)

			repeat
				local ok2, result2 = pcall(ScrambleBossHazards.Contains, v19, n2, arg, flag2, 3)
				if ok2 and result2 then
					return true
				end
				n2 += math.max(result / 6, 0.05)
			until n2 > result
		end

		return false
	end

	local function fn62(arg, arg2, arg3, arg4, arg5)
		local v19 = nil
		local v20

		for i = 1, 3 do
			for i2 = 0, 11 do
				local n2 = i2 * 3.1415926535897931 / 6
				local sin = math.sin
				local n3 = arg + Vector3.new(math.cos(n2), 0, sin(n2)) * i * 18

				if (typeof(arg4) ~= "Vector3" or ((n3 - arg4) * Vector3.new(1, 0, 1)).Magnitude < arg5 - 10) and not fn61(n3, arg3) then
					local magnitude = (n3 - arg2).Magnitude

					if not v20 or magnitude < v20 then
						v20 = magnitude
						v19 = n3
					end
				end
			end

			if v19 then
				return v19
			end
		end

		return nil
	end

	local function fn63(arg, arg2, arg3)
		local serverTimeNow = workspace:GetServerTimeNow()
		local flag2 = (arg3 - arg.Position).Magnitude <= 12

		if tbl2.ScrambleSwapBat then
			if not flag2 then
				return nil
			end

			local v19 = handlers.swapBatSwing(scrambleBoss, arg2, function()
				return tbl14.hold("ScrambleBoss") and fn51()
			end)

			if v19 == "cooldown" then
				scrambleBoss.readyAt = serverTimeNow + 0.2
			end

			if v19 ~= "single" then
				return nil
			end
		end

		local character = localPlayer.Character
		local bat = scrambleBoss.bat

		if not bat or bat:GetAttribute("IsBat") ~= true or bat.Parent ~= character and bat.Parent ~= localPlayer:FindFirstChildOfClass("Backpack") then
			bat = fn60(character)
			scrambleBoss.bat = bat
		end

		if not bat then
			return "No bat found"
		end

		if bat.Parent ~= character then
			arg2:EquipTool(bat)
			return nil
		end

		if not flag2 then
			return nil
		end
		local flag3 = serverTimeNow < (scrambleBoss.nextSwing or 0) or not bat.Enabled or bat:GetAttribute("CooldownActive") == true
		local flag4

		if flag3 then
			flag4 = flag3
		else
			flag4 = serverTimeNow < (tonumber(bat:GetAttribute("CooldownEndTime")) or 0)
		end

		if flag4 then
			return nil
		end
		scrambleBoss.nextSwing = serverTimeNow + clientCooldown
		bat:Activate()
		scrambleBoss.readyAt = math.max(serverTimeNow + clientCooldown, tonumber(bat:GetAttribute("CooldownEndTime")) or 0) - 0.1
		return nil
	end

	local function fn64()
		if scrambleBoss.stopped or tbl14.owner ~= "ScrambleBoss" then
			fn54()
			return
		end
		local v19, v20 = fn33()

		if v19 then
			local v21 = fn51()
			local flag2 = scrambleBoss.lastRoot and (v19.Position - scrambleBoss.lastRoot).Magnitude > 200
			local flag3 = scrambleBoss.lastInArena ~= nil and scrambleBoss.lastInArena ~= v21
			local v22 = scrambleBoss
			scrambleBoss.lastRoot = v19.Position
			v22.lastInArena = v21

			if flag2 or flag3 then
				local v23 = scrambleBoss
				scrambleBoss.goal = nil
				v23.follow = nil
				fn54()
				v19.AssemblyLinearVelocity = Vector3.zero
				return
			end
		end

		if localPlayer:GetAttribute("ScrambleGrabbed") == true then
			fn54()

			if (scrambleBoss.nextMash or 0) <= os.clock() then
				scrambleBoss.nextMash = os.clock() + 0.08
				scrambleBoss2.HazardHit:FireServer(-2)
			end

			return
		end

		if not scrambleBoss.goal or not v19 or not v20 or v20.Health <= 0 or localPlayer:GetAttribute("ScrambleThrown") ~= nil then
			fn54()
			return
		end

		scrambleBoss.flight = scrambleBoss.flight or handlers.newFlight(function()
			return scrambleBoss.goal
		end, 25)

		if scrambleBoss.follow and scrambleBoss.follow.Parent then
			scrambleBoss.goal = fn59(scrambleBoss.follow, true)
		end

		scrambleBoss.flight:Step(v19, true, scrambleBoss.goal.Y)
	end

	local function fn65()
		return tbl14.critical or critical or fn26() ~= nil or tbl14.stealBusy() or handlers.normalStealPending() or tbl2.Stall or tbl14.placeBusy or tbl14.petsBusy or tbl14.hatchBusy
	end

	local function fn66()
		if tbl14.owner ~= "ScrambleBoss" and not fn51() and fn65() then
			return false
		end

		if not tbl14.acquire("ScrambleBoss") then
			return false
		end
		local character = localPlayer.Character

		if scrambleBoss.character ~= character then
			scrambleBoss.character = character
			scrambleBoss.previousTool = character and character:FindFirstChildOfClass("Tool")
		end

		if not scrambleBoss.conn then
			scrambleBoss.conn = RunService.PreSimulation:Connect(fn64)
		end

		if not fn51() and not tbl15.requestTreadmillExit() then
			fn49("Leaving treadmill")
			return false
		end

		if not fn43(true) then
			fn49("Waiting for movement controller")
			return false
		end

		if handlers.movementInitializing(select(2, fn33())) then
			fn49("Waiting for respawn")
			return false
		end
		return true
	end

	local function fn67(arg)
		arg = arg and arg:FindFirstChild("Hitbox", true)
		return arg and arg:IsA("BasePart") and arg or nil
	end

	local function fn68(arg, arg2, arg3)
		local size = arg2.Size
		local cFrame = arg2.CFrame
		local rightVector = size.X <= size.Y and size.X <= size.Z and cFrame.RightVector or size.Y <= size.Z and cFrame.UpVector or cFrame.LookVector
		local n2 = arg3 - arg2.Position
		local v19 = n2:Dot(rightVector)
		if (n2 - rightVector * v19).Magnitude <= 3 then
			return arg2.Position
		end
		return arg2.Position + rightVector * (v19 < 0 and -1 or 1) * ((arg:IsA("Model") and select(2, arg:GetBoundingBox()) or size).Magnitude / 2 + 4)
	end

	local function fn69()
		local str = fn50()
		local attribute = str and str:GetAttribute("Phase")
		local flag2 = tbl14.owner == "ScrambleBoss"

		if fn51() then
			local flag3 = not flag2
			if flag3 and not tbl2.AutoScrambleBoss then
				fn49("Off")
				return
			end

			if flag3 and not fn66() then
				fn49("Waiting for the body")
				return
			end
			local v19, v20 = fn33()
			if not v19 or not v20 then
				return
			end
			local attribute2 = str and str:GetAttribute("Center")
			local flag4 = typeof(attribute2) == "Vector3"

			if flag4 then
				flag4 = ((v19.Position - attribute2) * Vector3.new(1, 0, 1)).Magnitude > (tonumber(str:GetAttribute("Radius")) or 450) + 100
			end

			if flag4 then
				scrambleBoss.goal = nil
				fn49("Entering the arena")
				return
			end

			if not tbl2.AutoScrambleBoss or attribute == "Defeated" or not str or not tbl14.hold("ScrambleBoss") then
				scrambleBoss.exiting = true
				str = str and fn67(str:FindFirstChild("LeaveTeleport"))
				scrambleBoss.goal = str and str.Position or nil
				local v21 = fn49
				str = str and "Leaving through the exit portal" or "Waiting for the arena exit"
				v21(str)
				return
			end

			local y = tonumber(str:GetAttribute("FloorY")) or v19.Position.Y
			local str2, v21, v22 = fn58(str)
			local n2 = v21 and fn56(v21, v19.Position)
			local follow = (attribute == "Human" or attribute == "Final") and fn57(str)
			scrambleBoss.follow = follow or nil
			local vector

			if follow then
				local v23
				vector, v23 = fn59(follow, false)
				n2 = n2 and n2 + v23
				str2 = n2 and "Hitting Dr. Scramble from above" or "Following Dr. Scramble"
			elseif not n2 then
				vector = Vector3.new(v19.Position.X, y + 30, v19.Position.Z)
				str2 = attribute == "Waiting" and "Waiting for the fight to start" or "Waiting for an opening"
			elseif v22 then
				vector = Vector3.new(n2.X, y + 3, n2.Z)
			else
				local n3 = v19.Position - n2
				vector = n2 + (n3.Magnitude > 0.1 and n3.Unit or Vector3.new(0, 1, 0)) * (workspace:GetServerTimeNow() >= (scrambleBoss.readyAt or 0) and 5 or 22)
			end

			if fn61(vector, y) or fn61(v19.Position, y) then
				scrambleBoss.follow = nil
				vector = fn62(v19.Position, vector, y, str:GetAttribute("Center"), tonumber(str:GetAttribute("Radius")) or 450) or vector
				str2 = "Dodging an attack"
			elseif n2 and not v22 then
				str2 = fn63(v19, v20, n2) or str2
			end

			scrambleBoss.goal = vector
			fn49(str2)
			return
		end

		local exiting

		if flag2 then
			exiting = scrambleBoss.exiting or not tbl2.AutoScrambleBoss or not str or attribute == "Defeated"
		else
			exiting = flag2
		end

		if exiting then
			fn55()
		end

		if not tbl2.AutoScrambleBoss then
			fn53(false)
			fn49("Off")
			return
		end

		if not str or attribute == "Defeated" then
			fn55()
			fn49("Waiting for Dr. Scramble's portal")
			return
		end

		local attribute2 = str:GetAttribute("Center")
		local v19 = fn33()
		flag2 = flag2 and v19 and typeof(attribute2) == "Vector3"

		if flag2 then
			flag2 = ((v19.Position - attribute2) * Vector3.new(1, 0, 1)).Magnitude <= (tonumber(str:GetAttribute("Radius")) or 450) + 100
		end

		if flag2 then
			scrambleBoss.goal = nil
			fn49("Leaving the arena")
			return
		end

		if fn65() then
			fn55()
			fn49("Stealing has priority")
			return
		end

		local scrambleArenaPortal = workspace:FindFirstChild("ScrambleArenaPortal")
		local v20 = fn67(scrambleArenaPortal)

		if not v20 then
			fn55()
			fn49("Waiting for Dr. Scramble's portal")
			return
		end

		fn53(true)
		if not fn66() then
			return
		end
		local v21 = fn33()
		scrambleBoss.goal = v21 and fn68(scrambleArenaPortal, v20, v21.Position) or v20.Position
		fn49("Flying into the boss portal")
	end

	scrambleBoss.Disconnect = function(arg)
		if arg.stopped then
			return
		end
		arg.stopped = true
		fn55()
		bindableEvent2:Fire()
	end

	getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = scrambleBoss

	getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = scrambleBoss2.Hazard.OnClientEvent:Connect(function(arg)
		if type(arg) == "table" and typeof(arg.Origin) == "Vector3" and type(arg.At) == "number" and fn51() then
			tbl17[#tbl17 + 1] = arg
		end
	end)

	local AutoScrambleBossToggle = (function()
	local _t = {Value = tbl2.AutoScrambleBoss, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.AutoScrambleBoss = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

	AutoScrambleBossToggle:OnChanged(function(arg)
		tbl2.AutoScrambleBoss = arg == true
		fn10(true)
		fn48()
	end)

	local ScrambleSwapBatToggle = (function()
	local _t = {Value = tbl2.ScrambleSwapBat, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.ScrambleSwapBat = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

	ScrambleSwapBatToggle:OnChanged(function(arg)
		tbl2.ScrambleSwapBat = arg == true
		fn10(true)
	end)

	local AutoClaimBossMasteryToggle = (function()
	local _t = {Value = tbl2.AutoClaimBossMastery, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.AutoClaimBossMastery = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

	AutoClaimBossMasteryToggle:OnChanged(function(arg)
		tbl2.AutoClaimBossMastery = arg == true
		local v19 = scramble
		scramble.nextSnapshot = 0
		v19.nextMastery = 0
		fn10(true)

		if scramble.wake then
			scramble.wake()
		end
	end)

	local connection = workspace.ChildAdded:Connect(function(child)
		if child.Name == "ScrambleArena" then
			fn48()
		end
	end)

	getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = connection

	task.spawn(function()
		while true do
			if fn() and not scrambleBoss.stopped then
				local ok, result = pcall(fn69)

				if not ok then
					fn55()
					fn49("Paused: " .. tostring(result))
				end

				if not (scrambleBoss.stopped or not fn()) then
					if tbl2.AutoScrambleBoss and (fn50() or fn51()) then
						task.wait(0.1)
					else
						local thread = task.delay(2, fn48)
						bindableEvent2.Event:Wait()
						pcall(task.cancel, thread)
					end

					continue
				end
			end

			break
		end

		scrambleBoss:Disconnect()
	end)
end

handlers.createServerBrowser = function(arg)
	local function fn48(arg2)
		return type(arg2) == "number" and arg2 == arg2 and arg2 >= 0 and arg2 < math.huge
	end

	return {
		rows = {},
		selected = nil,
		busy = false,
		revision = 0,
		dead = {},
		status = "Enable Find Server or press Refresh",
		lastSuccess = nil,
		nextRefresh = 0,
		Drop = function(arg2, arg3)
			arg2.dead[arg3] = true

			for i, row in ipairs(arg2.rows) do
				if row.id == arg3 then
					table.remove(arg2.rows, i)
					break
				end
			end

			if arg2.selected == arg3 then
				arg2.selected = arg2.rows[1] and arg2.rows[1].id or nil
			end
		end,
		Cancel = function(arg2)
			arg2.revision = arg2.revision + 1
			arg2.busy = false
			arg2.status = "Find Server off"
			arg.render(arg2)
		end,
		Select = function(arg2, selected)
			for _, row in ipairs(arg2.rows) do
				if row.id == selected then
					arg2.selected = selected
					arg.render(arg2)
					return true
				end
			end

			return false
		end,
		Refresh = function(arg2)
			local busy = not arg.alive() or arg2.busy

			if not busy then
				local nextRefresh = arg2.nextRefresh
				busy = arg.now() < nextRefresh
			end

			if busy then
				return false
			end
			arg2.revision = arg2.revision + 1
			local revision = arg2.revision
			arg2.busy = true
			arg2.nextRefresh = arg.now() + 10
			arg2.status = "Finding servers..."
			arg.render(arg2)

			local function fn49()
				return arg.alive() and arg2.revision == revision
			end

			arg.delay(25, function()
				if fn49() and arg2.busy then
					arg2.revision = arg2.revision + 1
					arg2.busy = false
					arg2.lastSuccess = nil
					arg2.nextRefresh = arg.now() + 60
					arg2.status = "Request timed out. Try Refresh later."
					arg.render(arg2)
				end
			end)

			local ok, rows = pcall(function()
				local tbl17 = {}
				local tbl18 = {}
				local tbl19 = {}
				local nextPageCursor

				for i = 1, 3 do
					local v18 = arg.fetch(nextPageCursor)
					if not fn49() then
						return nil
					end
					assert(type(v18) == "table" and type(v18.data) == "table", "Invalid server response")

					for _, v19 in ipairs(v18.data) do
						if type(v19) == "table" and type(v19.id) == "string" and v19.id ~= "" and v19.id ~= arg.jobId and not tbl18[v19.id] and not arg2.dead[v19.id] and fn48(v19.playing) and fn48(v19.maxPlayers) and v19.playing % 1 == 0 and v19.maxPlayers % 1 == 0 and v19.playing < v19.maxPlayers then
							tbl18[v19.id] = true

							tbl17[#tbl17 + 1] = {
								id = v19.id,
								playing = v19.playing,
								maxPlayers = v19.maxPlayers,
								ping = fn48(v19.ping) and v19.ping or nil,
								fps = fn48(v19.fps) and v19.fps or nil,
							}
						end
					end

					nextPageCursor = v18.nextPageCursor
					if #tbl17 >= 20 or type(nextPageCursor) ~= "string" or nextPageCursor == "" or tbl19[nextPageCursor] then
						break
					end
					tbl19[nextPageCursor] = true
				end

				table.sort(tbl17, function(arg3, arg4)
					local flag2 = arg4.playing < 2
					if arg3.playing < 2 ~= flag2 then
						return flag2
					end

					if arg3.playing ~= arg4.playing then
						return arg3.playing < arg4.playing
					end

					if arg3.ping ~= arg4.ping then
						return (arg3.ping or math.huge) < (arg4.ping or math.huge)
					end
					return arg3.id < arg4.id
				end)

				while #tbl17 > 20 do
					table.remove(tbl17)
				end

				return tbl17
			end)

			if not fn49() then
				return false
			end
			arg2.busy = false
			arg2.nextRefresh = arg.now() + (ok and 10 or 60)

			if not ok then
				arg2.status = "Refresh failed: " .. tostring(rows):gsub("^.-:%d+: ", ""):sub(1, 150)
				arg.render(arg2)
				return false
			end

			local v18 = arg.now()
			arg2.rows = rows
			arg2.lastSuccess = v18
			local flag2 = false

			for _, row in ipairs(rows) do
				if row.id == arg2.selected then
					flag2 = true
					break
				end
			end

			if not flag2 then
				arg2.selected = rows[1] and rows[1].id or nil
			end

			arg2.status = #rows > 0 and tostring(#rows) .. " servers found" or "No available public servers. Try Refresh later."
			arg.render(arg2)
			return true
		end,
		Hop = function(arg2)
			if arg2.busy then
				return false, "Wait for the server refresh"
			end
			local flag2 = not arg2.lastSuccess

			if not flag2 then
				local lastSuccess = arg2.lastSuccess
				flag2 = arg.now() - lastSuccess > 90
			end

			if flag2 then
				return false, "Refresh the server list first"
			end
			local v18 = nil

			for _, row in ipairs(arg2.rows) do
				if row.id ~= arg.jobId and row.playing < row.maxPlayers then
					if row.id == arg2.selected then
						return arg.teleport(row.id)
					end
					v18 = v18 or row
				end
			end

			if v18 then
				arg2.selected = v18.id
				return arg.teleport(v18.id)
			end
			return false, "No available servers left. Refresh to load more."
		end,
	}
end

local function fn48()
	local v18 = v3.__ServerTab:AddLeftGroupbox("Server Controls")
	local v19 = v3.__ServerTab:AddRightGroupbox("Available Servers")
	local v20 = v3
	v3.__ServerControlsBox = v18
	v20.__ServerResultsBox = v19
	local ServerSearchStatus = nil

	chk.Merge(v18, function()
		ServerSearchStatus = v18:AddLabel("ServerSearchStatus", { Text = "Enable Find Server or press Refresh", DoesWrap = true })
	end)

	local FindServerToggle = (function()
	local _t = {Value = tbl2.FindServer, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.FindServer = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

	local v21 = nil

	makeButtonPanel(v18, "ServerBrowserButtons", {
		{
			"Refresh",
			function()
				task.spawn(function()
					if not v21:Refresh() and fn() then
						lua:Notify(v21.status, 4)
					end
				end)
			end,
		},
		{
			"Server Hop",
			function()
				task.spawn(function()
					local flag2 = not v21.lastSuccess
					local flag3

					if flag2 then
						flag3 = flag2
					else
						local lastSuccess = v21.lastSuccess
						flag3 = os.clock() - lastSuccess > 90
					end

					if flag3 then
						v21:Refresh()
					end

					local v22, v23 = v21:Hop()

					if not v22 and fn() then
						lua:Notify(v23 or "Unable to hop", 4)
					end
				end)
			end,
		},
	})

	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "CloverServerList"
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.Size = UDim2.new(1, 0, 0, 340)
	scrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
	scrollingFrame.ScrollBarThickness = 4
	scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	v19:AddUIPassthrough("ServerListPanel", { Instance = scrollingFrame, Height = 340 })
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "EmptyServerList"
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(1, -8, 0, 50)
	textLabel.Text = "No servers loaded"
	textLabel.TextColor3 = lua.Scheme.FontColor
	textLabel.TextTransparency = 0.4
	textLabel.Font = Enum.Font.GothamSemibold
	textLabel.TextSize = 12
	textLabel.Parent = scrollingFrame
	lua:AddToRegistry(textLabel, { TextColor3 = "FontColor" })
	local tbl17 = {}
	local tbl18 = {}

	for i = 1, 20 do
		local textButton = Instance.new("TextButton")
		textButton.Name = "ServerRow" .. i
		textButton.Size = UDim2.new(1, -10, 0, 50)
		textButton.Position = UDim2.fromOffset(1, 1 + (i - 1) * 54)
		textButton.BorderSizePixel = 0
		textButton.Font = Enum.Font.GothamSemibold
		textButton.TextSize = 12
		textButton.TextWrapped = true
		textButton.TextXAlignment = Enum.TextXAlignment.Left
		textButton.Visible = false
		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingLeft = UDim.new(0, 8)
		uiPadding.PaddingRight = UDim.new(0, 6)
		uiPadding.Parent = textButton
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 6)
		uiCorner.Parent = textButton
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Thickness = 1
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uiStroke.Parent = textButton

		local tbl19 = {
			BackgroundColor3 = function()
				return tbl18[i] and lua:GetBetterColor(lua.Scheme.MainColor, 4) or lua.Scheme.MainColor
			end,
			TextColor3 = function()
				return lua.Scheme.FontColor
			end,
		}

		local tbl20 = { Color = function()
			return tbl18[i] and lua.Scheme.AccentColor or lua.Scheme.OutlineColor
		end }

		lua:AddToRegistry(textButton, tbl19)
		lua:AddToRegistry(uiStroke, tbl20)
		local v22 = tbl19.BackgroundColor3()
		local v23 = tbl19.TextColor3()
		textButton.BackgroundColor3 = v22
		textButton.TextColor3 = v23
		uiStroke.Color = tbl20.Color()

		textButton.MouseButton1Click:Connect(function()
			local v24 = v21.rows[i]

			if v24 then
				v21:Select(v24.id)
			end
		end)

		textButton.Parent = scrollingFrame
		tbl17[i] = textButton
	end

	local function fn49(arg)
		local flag2 = type(getthreadidentity) == "function" and getthreadidentity() or nil

		if type(setthreadidentity) == "function" then
			pcall(setthreadidentity, 8)
		end

		local ok, result = pcall(arg)

		if flag2 and type(setthreadidentity) == "function" then
			pcall(setthreadidentity, flag2)
		end

		return ok, result
	end

	local function fn50(arg)
		if not fn() then
			return
		end

		fn49(function()
			ServerSearchStatus:SetText(arg.status)
			textLabel.Visible = #arg.rows == 0

			for i, v22 in ipairs(tbl17) do
				local v23 = arg.rows[i]
				v22.Visible = v23 ~= nil

				if v23 then
					local flag2 = v23.id == arg.selected
					tbl18[i] = flag2
					v22.BackgroundColor3 = flag2 and lua:GetBetterColor(lua.Scheme.MainColor, 4) or lua.Scheme.MainColor
					local uiStroke = v22:FindFirstChildOfClass("UIStroke")

					if uiStroke then
						uiStroke.Color = flag2 and lua.Scheme.AccentColor or lua.Scheme.OutlineColor
					end

					v22.Text = string.format("%s%d / %d players\n%s ms · %s FPS", flag2 and "✓ " or "", v23.playing, v23.maxPlayers, v23.ping and tostring(math.floor(v23.ping)) or "—", v23.fps and string.format("%.0f", v23.fps) or "—")
				end
			end

			scrollingFrame.CanvasSize = UDim2.fromOffset(0, #arg.rows * 54)
		end)
	end

	local function fn51(arg, arg2)
		if not handlers.serverHopPending or arg2 and handlers.serverHopPending ~= arg2 then
			return
		end
		handlers.serverHopPending = nil
		handlers.intentionalDisconnectUntil = 0

		if handlers.stealHop then
			handlers.stealHop.readyAt = math.min(handlers.stealHop.readyAt, os.clock() + 10)
		end

		v21.status = "Hop failed: " .. tostring(arg) .. ". Pick another server or press Server Hop."
		fn50(v21)
	end

	local function pickStealHopRow(arg)
		local tbl19 = {}

		for _, row in ipairs(v21.rows) do
			local flag2 = row.id ~= game.JobId and row.playing < row.maxPlayers

			if flag2 then
				flag2 = not (arg and arg[row.id])
			end

			if flag2 then
				tbl19[#tbl19 + 1] = row
			end
		end

		return #tbl19 > 0 and tbl19[math.random(1, #tbl19)] or nil
	end

	local function fn52(arg, serverId)
		local tried = arg.tried
		arg.serverId = serverId
		tried[serverId] = true

		task.spawn(function()
			local ok, result = pcall(TeleportService.TeleportToPlaceInstance, TeleportService, game.PlaceId, serverId, localPlayer)

			if not ok and fn() then
				fn51(result, arg)
			end
		end)
	end

	local function fn53(arg, arg2)
		if handlers.sameServerRejoinPending or handlers.serverHopPending then
			return false, "A teleport is already pending"
		end
		local serverHopPending = { directTries = 1, tried = {}, hopTry = arg2 }
		handlers.serverHopPending = serverHopPending
		handlers.intentionalDisconnectUntil = os.clock() + 45
		v21.status = "Joining selected server..."
		fn50(v21)
		fn52(serverHopPending, arg)

		task.delay(45, function()
			if fn() then
				fn51("Teleport timed out", serverHopPending)
			end
		end)

		return true
	end

	v21 = handlers.createServerBrowser({
		alive = fn,
		now = os.clock,
		delay = task.delay,
		jobId = game.JobId,
		render = fn50,
		fetch = function(arg)
			local request_ = syn and syn.request or http and http.request or http_request or request
			assert(type(request_) == "function", "HTTP request unavailable")
			local str = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&excludeFullGames=true&limit=100"

			if arg then
				str ..= "&cursor=" .. HttpService:UrlEncode(arg)
			end

			local v22 = request_({ Url = str, Method = "GET", Timeout = 20 })
			assert(type(v22) == "table", "Invalid HTTP response")
			local num = tonumber(v22.StatusCode or v22.status_code or v22.Status)

			if num == 429 then
				error("Roblox rate limit. Wait 60 seconds", 0)
			end

			assert(num and num >= 200 and num < 300, "HTTP " .. tostring(num or "failed"))
			return HttpService:JSONDecode(v22.Body or v22.body or "")
		end,
		teleport = function(arg)
			return fn53(arg)
		end,
	})

	local function fn54(arg, status)
		arg.matchmaking = true
		v21.status = status
		fn50(v21)

		task.delay(0.5, function()
			if not fn() or handlers.serverHopPending ~= arg then
				return
			end
			local ok, result = pcall(TeleportService.Teleport, TeleportService, game.PlaceId, localPlayer, { CloverHopFrom = game.JobId, CloverHopTry = arg.hopTry or 1 })

			if not ok and fn() then
				fn51(result, arg)
			end
		end)
	end

	getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = TeleportService.TeleportInitFailed:Connect(function(arg, arg2, arg3, arg4, arg5)
		if not fn() or arg ~= localPlayer or arg4 ~= game.PlaceId then
			return
		end
		local serverHopPending = handlers.serverHopPending
		if not serverHopPending then
			return
		end
		arg5 = arg5 and arg5.ServerInstanceId

		if arg5 and arg5 ~= "" then
			if serverHopPending.matchmaking and arg5 == serverHopPending.serverId then
				return
			end

			if not serverHopPending.matchmaking and arg5 ~= serverHopPending.serverId then
				return
			end
		end

		if not serverHopPending.matchmaking and arg2 ~= Enum.TeleportResult.Flooded and arg2 ~= Enum.TeleportResult.IsTeleporting then
			v21:Drop(serverHopPending.serverId)
			local flag2 = serverHopPending.directTries < 5 and pickStealHopRow(serverHopPending.tried) or nil

			if flag2 then
				serverHopPending.directTries = serverHopPending.directTries + 1
				v21.selected = flag2.id
				v21.status = "Server unavailable · trying another server..."
				fn50(v21)

				task.delay(0.5, function()
					if fn() and handlers.serverHopPending == serverHopPending then
						fn52(serverHopPending, flag2.id)
					end
				end)

				return
			end

			fn54(serverHopPending, "Servers unavailable · trying Roblox matchmaking...")
			return
		end

		fn51(tostring(arg2.Name) .. ": " .. tostring(arg3), serverHopPending)
	end)

	local ok, result = pcall(TeleportService.GetLocalPlayerTeleportData, TeleportService)
	ok = ok and type(result) == "table" and result.CloverHopFrom == game.JobId

	if ok then
		local jobId = game.JobId
		ok = getgenv().__CHSAE_HopArrivalHandled ~= jobId
	end

	local num = ok and tonumber(result.CloverHopTry)

	if num and num < 3 then
		local jobId = game.JobId
		getgenv().__CHSAE_HopArrivalHandled = jobId

		task.delay(3, function()
			if not fn() or handlers.serverHopPending or handlers.sameServerRejoinPending then
				return
			end
			v21:Refresh()
			if not fn() or handlers.serverHopPending or handlers.sameServerRejoinPending then
				return
			end
			local v22 = pickStealHopRow()

			if v22 then
				v21.selected = v22.id
				fn53(v22.id, num + 1)
				v21.status = "Returned to the same server · joining another server..."
				fn50(v21)
				return
			end

			local serverHopPending = { hopTry = num + 1, tried = {} }
			handlers.serverHopPending = serverHopPending
			handlers.intentionalDisconnectUntil = os.clock() + 45

			task.delay(45, function()
				if fn() then
					fn51("Teleport timed out", serverHopPending)
				end
			end)

			fn54(serverHopPending, "Returned to the same server · trying matchmaking again...")
		end)
	end

	handlers.pickStealHopRow = pickStealHopRow
	handlers.stealHop = { readyAt = os.clock() + 4, visited = {}, slots = {}, fallbackSeconds = 45 }

	handlers.stealHopAssessment = function(arg, arg2, arg3, arg4)
		if type(arg2) ~= "table" or type(arg2.Slots) ~= "table" or type(arg2.PeriodIndex) ~= "number" or arg2.PeriodIndex > arg3 then
			return false
		end
		local v22 = handlers.kgFilterActive(tbl2.TargetKGMode, tbl2.TargetKGThreshold)
		local flag2 = (tonumber(tbl2.TargetValueThreshold) or 0) > 0

		local function fn55(arg5, arg6)
			local flag3 = false

			for _, v23 in pairs(arg5) do
				if v23 then
					flag3 = true
					break
				end
			end

			return not flag3 or arg5[arg6] == true
		end

		local function fn56(arg5)
			return not (arg2.PeriodIndex == arg3 and arg2.Slots[arg5] == true)
		end

		local tbl19 = {}
		local flag3 = false

		for _, v23 in ipairs(arg) do
			local rec = v23.rec
			local rarity = rec.AreaId ~= "Forest" and not handlers.isCaptureEventUid(rec.Uid) and v23.rarity and fn55(tbl2.TargetRarities, v23.rarity._id) and fn55(tbl2.TargetCategories, tostring(rec.AssetCategory)) and fn55(tbl2.TargetAreas, tostring(rec.AreaId))

			if rarity then
				rarity = tbl2.TargetPriority ~= "Mutation"

				if not rarity then
					rarity = #(v23.mutations or {}) > 0
				end
			end

			if rarity then
				if type(rec.AreaId) ~= "string" or type(rec.NestId) ~= "string" then
					return false
				end
				local str = rec.AreaId .. ":" .. rec.NestId

				if arg4 then
					arg4[str] = true
				end

				if fn56(str) and rec.State == "Slot" and rec.BottomCFrame then
					tbl19[str] = true
					if v22 and not v23.weightKnown or flag2 and not v23.valueKnown then
						return false
					end

					if (not v22 or handlers.kgFilterMatches(v23.weight, tbl2.TargetKGMode, tbl2.TargetKGThreshold, v23.weightKnown)) and (not flag2 or handlers.valueFilterMatches(v23.value, tbl2.TargetValueThreshold, "atLeast", v23.valueKnown)) then
						return false
					end
					flag3 = true
				end
			end
		end

		local v23 = pairs
		arg4 = arg4 or {}

		for k in v23(arg4) do
			if not tbl19[k] and fn56(k) then
				flag3 = true
			end
		end

		return flag3
	end

	handlers.stealHopFallback = function()
		local stealHop = handlers.stealHop
		if not tbl2.AutoSteal or not tbl2.StealServerHop or not stealHop then
			return false
		end

		local ok2, result2 = pcall(function()
			local AreaEggCycle = require(ReplicatedStorage.Shared.Util.AreaEggCycle)
			local serverTimeNow = workspace:GetServerTimeNow()
			return stealHop.exhausted == AreaEggCycle.PeriodIndexAt(serverTimeNow) or not AreaEggCycle.IsNightPhase(serverTimeNow) and AreaEggCycle.SecondsUntilPhaseEnd(serverTimeNow) <= stealHop.fallbackSeconds
		end)

		return ok2 and result2 == true
	end

	handlers.checkStealHop = function()
		local stealHop = handlers.stealHop

		local function fn55()
			local character = localPlayer.Character
			character = character and character:FindFirstChildOfClass("Humanoid")
			local flag2 = fn() and tbl3.loaded and tbl2.AutoSteal and tbl2.StealServerHop and character and character.Health > 0 and not handlers.eggInventoryCapacityState() and not tbl2.Stall and not critical and not tbl14.owner and not tbl14.critical and not tbl14.treadmillTraining and not tbl14.placeBusy and not tbl14.hatchBusy and not tbl14.petsBusy and not handlers.riftWantsBody and not handlers.riftCollecting
			local flag3

			if flag2 then
				flag3 = not (tbl2.AutoPetIndex and (handlers.PetIndex.target ~= nil or next(handlers.PetIndex.eggs) ~= nil))
			else
				flag3 = flag2
			end

			return flag3 and not handlers.pendingDroppedUid and not tbl13.lockedUid and not getgenv().__CHSAE_CarryRequest and not fn16() and not handlers.serverHopPending and not handlers.sameServerRejoinPending
		end

		if not fn55() then
			stealHop.emptySince = nil
			return
		end
		local readyAt = stealHop.readyAt
		if os.clock() < readyAt then
			return
		end
		local autoExecute = tbl.AutoExecute

		if not autoExecute or not autoExecute.enabled or not autoExecute.queued then
			stealHop.emptySince = nil
			fn11("🟡 Server Hop · enable Auto Execute first")
			return
		end

		if handlers.stealHopFallback() then
			stealHop.emptySince = nil
			fn11("🟡 Server Hop · no match left · waiting for reset")
			return
		end

		local str = "CloverHub/StealAnEgg/hop-" .. localPlayer.UserId .. ".json"

		local function fn56()
			local candidateIndex = handlers.candidateIndex
			local v22 = GetSaveModule().Get()
			local v23 = workspace
			local getServerTimeNow = v23.GetServerTimeNow
			local v24 = require(ReplicatedStorage.Shared.Util.AreaEggCycle).PeriodIndexAt(getServerTimeNow(v23))

			if stealHop.period ~= v24 then
				local v25 = stealHop
				local v26 = stealHop
				local v27 = stealHop
				local v28 = stealHop
				stealHop.period = v24
				v25.emptySince = nil
				v26.visited = {}
				v27.slots = {}
				v28.exhausted = nil

				pcall(function()
					if not isfile(str) then
						return
					end
					local data = HttpService:JSONDecode(readfile(str))

					if type(data) == "table" and data.period == v24 then
						stealHop.visited = type(data.visited) == "table" and data.visited or {}
						stealHop.slots = type(data.slots) == "table" and data.slots or {}
					end
				end)
			end

			local entries = candidateIndex and candidateIndex:GetEntries(tbl2.TargetPriority)
			return type(entries) == "table" and v22 and handlers.stealHopAssessment(entries, v22.CurrentAreaEggClaims, v24, stealHop.slots), v24
		end

		local ok2, result2, exhausted = pcall(fn56)
		if not ok2 or not result2 then
			stealHop.emptySince = nil
			return
		end

		if not stealHop.emptySince then
			stealHop.emptySince = os.clock()
			return
		end
		local emptySince = stealHop.emptySince
		if os.clock() - emptySince < 2 then
			return
		end
		stealHop.readyAt = os.clock() + 60
		if type(readfile) ~= "function" or type(writefile) ~= "function" or type(isfile) ~= "function" then
			fn11("🟡 Server Hop · history unavailable")
			return
		end
		stealHop.visited[game.JobId] = true
		local flag2 = not v21:Refresh()

		if flag2 then
			local lastSuccess = v21.lastSuccess

			if lastSuccess then
				local lastSuccess2 = v21.lastSuccess
				lastSuccess = os.clock() - lastSuccess2 < 90
			end

			flag2 = not lastSuccess
		end

		if flag2 then
			fn11("🟡 Server Hop · retrying later")
			return
		end
		local ok3, result3, result4 = pcall(fn56)

		if not fn55() or not ok3 or not result3 or result4 ~= exhausted then
			stealHop.emptySince = nil
			stealHop.readyAt = os.clock()
			return
		end

		local v22 = handlers.pickStealHopRow(stealHop.visited)

		if v22 then
			if not fn10(true) then
				fn11("🟡 Server Hop · config save required")
				return
			end
			stealHop.visited[v22.id] = true
			if not pcall(function()
				writefile(str, HttpService:JSONEncode({ period = exhausted, visited = stealHop.visited, slots = stealHop.slots }))
			end) then
				return
			end

			if not fn55() then
				return
			end
			v21.selected = v22.id
			fn11("🌐 Finding qualifying eggs in another server")
			v21:Hop()
			stealHop.emptySince = nil
			return
		end

		stealHop.exhausted = exhausted
		stealHop.readyAt = os.clock()
		fn11("🟡 Server Hop · every server checked · stealing the best egg")
	end

	local n2 = 0

	FindServerToggle:OnChanged(function(arg)
		tbl2.FindServer = arg == true
		fn10(true)

		if not arg then
			v21:Cancel()
		else
			n2 = os.clock() + 60

			task.spawn(function()
				v21:Refresh()
			end)
		end
	end)
	local chsaeDebug2 = getgenv().__CHSAE_Debug

	if chsaeDebug2 then
		chsaeDebug2.GetServerBrowser = function()
			local tbl19 = {}

			for i, row in ipairs(v21.rows) do
				tbl19[i] = table.clone(row)
			end

			return {
				rows = tbl19,
				selected = v21.selected,
				status = v21.status,
				busy = v21.busy,
				enabled = tbl2.FindServer,
				lastSuccess = v21.lastSuccess,
			}
		end

		chsaeDebug2.RefreshServerBrowser = function()
			return v21:Refresh()
		end
	end

	task.spawn(function()
		while fn() do
			local flag2 = tbl2.FindServer and os.clock() >= n2

			if flag2 then
				local nextRefresh = v21.nextRefresh
				flag2 = os.clock() >= nextRefresh
			end

			if flag2 and not handlers.serverHopPending then
				v21:Refresh()
				n2 = os.clock() + 60
			elseif not tbl2.FindServer then
				n2 = 0
			end

			task.wait(1)
		end

		v21.revision = v21.revision + 1
	end)
end

fn48()

do
	local v18 = v3.__WebhookTab:AddLeftGroupbox("🔗 Webhook")
	v3.__WebhookBox = v18
	local v19 = v3.__WebhookTab:AddRightGroupbox("🔔 Alerts")
	v3.__WebhookAlertsBox = v19
	local WebhookStatusLabel = nil

	chk.Merge(v18, function()
		WebhookStatusLabel = v18:AddLabel("WebhookStatusLabel", { Text = "🔗 Paste a webhook URL", DoesWrap = true })
	end)

	local function fn49(arg)
		handlers.setLabel(WebhookStatusLabel, arg)
	end

	local function fn50(arg)
		return tostring(arg or ""):gsub("[%c%s]", ""):gsub("^<", ""):gsub(">$", "")
	end

	local function fn51(arg)
		return tostring(arg):match("^https://[%w%.%-]+/api/webhooks/%d+/%S+$") ~= nil
	end

	local WebhookURLInput = nil

	local function fn52()
		local webhookURL = tbl2.WebhookURL

		pcall(function()
			if WebhookURLInput and type(WebhookURLInput.GetValue) == "function" then
				webhookURL = WebhookURLInput:GetValue()
			elseif WebhookURLInput and type(WebhookURLInput.Value) == "string" then
				webhookURL = WebhookURLInput.Value
			end
		end)

		tbl2.WebhookURL = fn50(webhookURL)
		return tbl2.WebhookURL
	end

	WebhookURLInput = v18:AddInput("WebhookURLInput", {
		Text = "URL",
		Default = tbl2.WebhookURL,
		Placeholder = "https://discord.com/api/webhooks/...",
		Finished = false,
		Tooltip = "Paste your Discord webhook URL.",
	})

	WebhookURLInput:OnChanged(function(arg)
		tbl2.WebhookURL = fn50(arg)
		fn49(fn51(tbl2.WebhookURL) and "🟢 URL ready" or "🔗 Paste a webhook URL")
	end)

	v18:AddToggle("WebhookEveryoneToggle", {
		Text = "Mention @everyone",
		Default = tbl2.WebhookEveryone,
		Tooltip = "Mention @everyone in alerts and test messages.",
	}):OnChanged(function(arg)
		tbl2.WebhookEveryone = arg == true
	end)

	v19:AddToggle("WebhookStealsToggle", {
		Text = "Steal Alerts",
		Default = tbl2.WebhookSteals,
		Tooltip = "Alert for Steal Filter eggs only.",
	}):OnChanged(function(webhookSteals)
		tbl2.WebhookSteals = webhookSteals
	end)

	v19:AddToggle("WebhookMutationsToggle", {
		Text = "Mutation Alerts",
		Default = tbl2.WebhookMutations,
		Tooltip = "Send an alert after an egg mutation.",
	}):OnChanged(function(webhookMutations)
		tbl2.WebhookMutations = webhookMutations
	end)

	v19:AddToggle("WebhookHatchesToggle", {
		Text = "Hatch Alerts",
		Default = tbl2.WebhookHatches,
		Tooltip = "Send an alert after an egg hatches.",
	}):OnChanged(function(webhookHatches)
		tbl2.WebhookHatches = webhookHatches
	end)

	v19:AddToggle("WebhookDisconnectsToggle", {
		Text = "Disconnect Alerts",
		Default = tbl2.WebhookDisconnects,
		Tooltip = "Send an alert if this client disconnects.",
	}):OnChanged(function(webhookDisconnects)
		tbl2.WebhookDisconnects = webhookDisconnects
	end)

	v19:AddToggle("WebhookInventoryFullToggle", {
		Text = "Inventory Full Alerts",
		Default = tbl2.WebhookInventoryFull,
		Tooltip = "Alert when inventory stops Auto Steal.",
	}):OnChanged(function(webhookInventoryFull)
		tbl2.WebhookInventoryFull = webhookInventoryFull
	end)

	local function fn53(arg)
		if arg == "steal" then
			return tbl2.WebhookSteals
		end

		if arg == "mutation" then
			return tbl2.WebhookMutations
		end

		if arg == "hatch" then
			return tbl2.WebhookHatches
		end

		if arg == "disconnect" then
			return tbl2.WebhookDisconnects
		end

		if arg == "inventory-full" then
			return tbl2.WebhookInventoryFull
		end
		return false
	end

	local tbl17 = {}

	local function fn54(arg, arg2)
		local str = tostring(arg or "")
		if str:match("^https://[%w%-]+%.rbxcdn%.com/") then
			return str
		end
		local match = str:match("(%d+)")
		if not match or type(arg2) ~= "function" then
			return nil
		end

		if tbl17[match] then
			return tbl17[match]
		end
		local str2 = ("https://thumbnails.roblox.com/v1/assets?assetIds=%s&size=420x420&format=Png&isCircular=false"):format(match)

		for i = 1, 2 do
			local ok, result = pcall(arg2, { Url = str2, Method = "GET", Headers = { Accept = "application/json" } })
			local flag2 = ok and type(result) == "table"

			if flag2 then
				flag2 = tonumber(result.StatusCode or result.Status)
			end

			flag2 = flag2 or nil
			local body

			if ok then
				local flag3 = type(result) == "string" and result

				if flag3 then
					body = flag3
				else
					local flag4 = type(result) == "table"

					if flag4 then
						body = result.Body or result.body
					else
						body = flag4
					end
				end
			else
				body = ok
			end

			body = body or nil

			if flag2 then
				flag2 = flag2 < 200 or flag2 >= 300
			end

			if flag2 then
				return nil
			end

			if type(body) ~= "string" then
				return nil
			end
			local ok2, result2 = pcall(HttpService.JSONDecode, HttpService, body)
			local flag3 = ok2 and type(result2) == "table" and type(result2.data) == "table" and result2.data[1] or nil
			local imageUrl = flag3 and flag3.imageUrl
			if type(imageUrl) == "string" and imageUrl:find("e5bef3179d5ce82a42fdc8ddc83a2ba9", 1, true) then
				return nil
			end

			if type(imageUrl) == "string" and imageUrl:match("^https://[%w%-]+%.rbxcdn%.com/") then
				tbl17[match] = imageUrl
				return imageUrl
			end

			if not flag3 or flag3.state ~= "Pending" or i == 2 then
				return nil
			end
			task.wait(0.2)
		end

		return nil
	end

	handlers.sendWebhook = function(arg, arg2, arg3, arg4, arg5)
		if not arg5 and not fn53(arg) then
			return false
		end
		local v20 = fn52()
		if not fn51(v20) then
			fn49("🟡 Add a valid URL")
			return false
		end
		local request_ = syn and syn.request or http and http.request or http_request or request
		if type(request_) ~= "function" then
			fn49("🔴 Request unavailable")
			return false
		end
		fn49("🟡 Sending")
		local flag2 = type(arg3) == "table" and arg3 or nil
		local str = tostring(arg2 or "SAE")
		local str2 = tostring(arg3 or "")
		local tbl18 = {}
		local str3 = "||" .. localPlayer.Name .. "||"
		local thumbnail

		if flag2 then
			local rarity = flag2.rarity

			if type(rarity) == "table" then
				rarity = rarity._id or rarity.Id or rarity.Name
			end

			local str4 = tostring(flag2.category or "Unknown Egg")
			local n2 = tonumber(flag2.scale) or 1
			str = ("🥚 %s [%s] [%.2fx]"):format(str4, tostring(rarity or "Unknown"), n2)
			str2 = ("By User: **%s**"):format(str3)
			local tbl19 = {}
			local str5 = "✨ Rarity: " .. tostring(rarity or "Unknown")
			local str6 = "🗺️ Area: " .. tostring(flag2.area or "Unknown")
			local str7 = "🧬 Mutations: " .. tostring(flag2.mutations or "None")
			tbl19[1] = str5
			tbl19[2] = str6
			tbl19[3] = str7
			local tbl20 = {}
			local str8 = "💰 Income: $" .. fn3(flag2.income or 0) .. "/s"
			local str9 = "📏 Travel: " .. ("%.0f studs"):format(tonumber(flag2.distance) or 0)
			local str10 = "📦 Session steals: " .. tostring(handlers.steals or 0)
			tbl20[1] = str8
			tbl20[2] = str9
			tbl20[3] = str10
			tbl18[#tbl18 + 1] = { name = "📈 Egg info", value = "```\n" .. table.concat(tbl19, "\n") .. "\n```", inline = false }

			tbl18[#tbl18 + 1] = {
				name = "📦 Claim status",
				value = "```\n" .. table.concat(tbl20, "\n") .. "\n```",
				inline = false,
			}

			local v21 = fn54(flag2.icon, request_)
			thumbnail = nil

			if v21 then
				thumbnail = { url = v21 }
			end
		elseif arg == "disconnect" then
			tbl18 = {}
			local tbl19 = { name = "Place", value = tostring(game.PlaceId), inline = true }
			local tbl20 = { name = "Server", value = tostring(game.JobId), inline = false }
			tbl18[1] = { name = "Player", value = str3, inline = true }
			tbl18[2] = tbl19
			tbl18[3] = tbl20
			thumbnail = nil
		elseif arg == "inventory-full" then
			tbl18 = {
				{ name = "Player", value = str3, inline = true },
				{ name = "Action", value = "Auto-Steal disabled", inline = true },
			}

			thumbnail = nil
		else
			tbl18 = {}
			local tbl19 = { name = "Player", value = str3, inline = true }
			local tbl20 = { name = "Status", value = tostring(arg or "test"), inline = true }
			tbl18[1] = tbl19
			tbl18[2] = tbl20
			thumbnail = nil
		end

		local tbl19 = {
			title = str,
			description = str2,
			color = tonumber(arg4) or 4843141,
			fields = tbl18,
			footer = { text = "Steal an Egg · " .. chsaeReleaseVersion },
			timestamp = DateTime.now():ToIsoDate(),
		}

		if thumbnail then
			tbl19.thumbnail = thumbnail
		end

		local ok, result = pcall(request_, {
			Url = v20,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = HttpService:JSONEncode({
				username = "SAE",
				content = tbl2.WebhookEveryone == true and "@everyone" or "",
				allowed_mentions = { parse = tbl2.WebhookEveryone == true and { "everyone" } or {} },
				embeds = { tbl19 },
			}),
		})

		local flag3 = ok and type(result) == "table"

		if flag3 then
			flag3 = tonumber(result.StatusCode or result.Status)
		end

		flag3 = flag3 or nil
		ok = ok and flag3 and flag3 >= 200 and flag3 < 300
		fn49(ok and "🟢 Sent" or "🔴 Send failed")
		return ok == true
	end

	if handlers.pendingInventoryFullAlert then
		local pendingInventoryFullAlert = handlers.pendingInventoryFullAlert
		handlers.pendingInventoryFullAlert = nil

		task.defer(function()
			handlers.sendWebhook("inventory-full", "Egg Inventory Full", ("Auto-Steal was turned off. Egg inventory: **%d / %d**."):format(tonumber(pendingInventoryFullAlert.count) or 0, tonumber(pendingInventoryFullAlert.capacity) or 0), 16096779, false)
		end)
	end

	makeButtonPanel(v18, "WebhookButtons", {
		{
			"📨 Send Test",
			function()
				fn52()
				task.spawn(handlers.sendWebhook, "test", "Test Message", "Your CloverHub webhook is connected.", 4843141, true)
			end,
		},
	})

	fn49(fn51(tbl2.WebhookURL) and "🟢 URL ready" or "🔗 Paste a webhook URL")
end

do
	local flag2 = false

	local function fn49(arg)
		if flag2 or not fn() or not tbl2.WebhookDisconnects then
			return
		end

		if os.clock() < (tonumber(handlers.intentionalDisconnectUntil) or 0) then
			return
		end
		flag2 = true
		task.spawn(handlers.sendWebhook, "disconnect", "Client Disconnected", tostring(arg or "Connection closed"), 15680580, false)
	end

	pcall(function()
		local GuiService = game:GetService("GuiService")

		getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = GuiService.ErrorMessageChanged:Connect(function(arg)
			local str = tostring(arg or GuiService:GetErrorMessage() or "")

			if str ~= "" then
				fn49(str)
			end
		end)
	end)

	pcall(function()
		local NetworkClient = game:GetService("NetworkClient")

		getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = NetworkClient.ChildRemoved:Connect(function(child)
			if child:IsA("ClientReplicator") then
				local str = "Client connection closed"

				pcall(function()
					local errorMessage = game:GetService("GuiService"):GetErrorMessage()

					if type(errorMessage) == "string" and errorMessage ~= "" then
						str = errorMessage
					end
				end)

				fn49(str)
			end
		end)
	end)
end

local v18
v18 = settings_:AddLeftGroupbox("⚙️ Movement")

handlers.setStealMovementType = function(arg)
	tbl2.StealMovementType = (arg == "Fly" or arg == "Hop" or arg == "Hop Fly") and arg or "Relay"
	local devChickenTween = handlers.DevChickenTween

	if devChickenTween and not devChickenTween.lease then
		task.defer(devChickenTween.prime)
	end

	tbl2.StealSpeed = handlers.getDeliverySpeed()

	if handlers.syncSpeedSlider then
		handlers.syncSpeedSlider()
	end
end

bindDropdownOverlay(v18, "StealMovementTypeDropdown", "Movement", { "Relay", "Hop", "Fly", "Hop Fly" }, {
	configKey = "StealMovementType",
	multi = false,
	text = "Movement",
	tooltip = "Relay is the default: fly out, teleport and drop in Desert, return to the pickup spot, then tween to the dropped egg and back to start. Hop hops back; Fly flies the egg home without dropping it; Hop Fly flies out, drops the egg at the drop spot with Relay's teleport, hops to it, re-picks and walks in. Enable Default Speed overrides this choice with walking.",
	get = function()
		return tbl2.StealMovementType
	end,
	set = handlers.setStealMovementType,
	onChange = function()
		fn10(true)
	end,
})

local EnableDefaultSpeedToggle = (function()
	local _t = {Value = tbl2.EnableDefaultSpeed, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.EnableDefaultSpeed = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

EnableDefaultSpeedToggle:OnChanged(function(arg)
	tbl2.EnableDefaultSpeed = arg == true
	fn10(true)

	if fn12 then
		fn12("default-speed-toggle")
	end
end)

do
	local v19 = chk.Slider(v18, "StealSpeedSlider", {
		Text = "Fly Speed",
		Default = tbl2.StealSpeed,
		Min = 100,
		Max = 1000,
		Rounding = 0,
		Suffix = " studs/s",
		Tooltip = "Speed for Stall, trips to the pen, treadmill and mutate spots, and Relay's final tween to start. Outbound steal flights use your walk speed; Relay recovers dropped eggs at 2000 studs/s.",
	})

	local StealSpeedInput = v18:AddInput("StealSpeedInput", {
		Text = "Exact Tween Speed",
		Default = tostring(tbl2.StealSpeed),
		Numeric = true,
		Finished = true,
		Tooltip = "Enter an exact speed from 100 to 1000 studs/s.",
	})

	local flag2 = false

	local function fn49(arg)
		return math.clamp(math.floor((tonumber(arg) or tonumber(tbl2.StealSpeed) or 800) + 0.5), 100, 1000)
	end

	local function fn50(arg, arg2)
		local v20 = fn49(arg)

		if arg2 then
			v20 = handlers.setDeliverySpeed(v20)
			fn10(true)
		end

		flag2 = true
		v19:SetValue(v20, true)
		pcall(StealSpeedInput.SetValue, StealSpeedInput, tostring(v20))
		flag2 = false
		return v20
	end

	handlers.syncSpeedSlider = function()
		tbl2.StealSpeed = handlers.getDeliverySpeed()
		fn50(tbl2.StealSpeed, false)
	end

	handlers.syncSpeedSlider()

	v19:OnChanged(function(arg)
		if flag2 then
			return
		end
		fn50(arg, true)
	end)

	StealSpeedInput:OnChanged(function(arg)
		if flag2 or tonumber(arg) == nil then
			return
		end
		fn50(arg, true)
	end)
end

local v19
v19 = settings_:AddRightGroupbox("⚡ Performance")

do
	local obj = setmetatable({}, { __mode = "k" })
	local obj2 = setmetatable({}, { __mode = "kv" })
	local tbl17 = {}
	local n2 = 0
	local qualityLevel = nil
	local tbl18 = {}
	local n3 = 1
	local n4 = 0
	local obj3 = setmetatable({}, { __mode = "k" })
	local flag2 = false

	handlers.rememberingSetter = function(arg)
		return function(arg2, arg3, arg4)
			local tbl19 = arg[arg2]

			if not tbl19 then
				tbl19 = {}
				arg[arg2] = tbl19
			end

			if tbl19[arg3] == nil then
				local ok, result = pcall(function()
					return arg2[arg3]
				end)

				if not ok then
					return
				end
				tbl19[arg3] = result
			end

			pcall(function()
				arg2[arg3] = arg4
			end)
		end
	end

	local v20 = handlers.rememberingSetter(obj)

	local function fn49(arg)
		while arg and arg ~= workspace do
			if CollectionService:HasTag(arg, "SakuraBloomTree") then
				return true
			end
			arg = arg.Parent
		end

		return false
	end

	local function fn50(arg)
		local v21 = obj2[arg]

		if v21 then
			if arg.Parent == nil then
				pcall(function()
					arg.Parent = v21
				end)
			end

			obj2[arg] = nil
		end

		local v22 = obj[arg]

		if v22 then
			if arg.Parent then
				for k, v23 in pairs(v22) do
					pcall(function()
						arg[k] = v23
					end)
				end
			end

			obj[arg] = nil
		end

		obj3[arg] = nil
	end

	local function fn51(arg)
		if not (arg and arg:IsA("Model")) then
			return
		end
		fn50(arg)

		for _, descendant in ipairs(arg:GetDescendants()) do
			fn50(descendant)
		end

		for k, v21 in pairs(obj2) do
			local flag3 = false

			if v21 then
				local ok

				ok, flag3 = pcall(function()
					return v21 == arg or v21:IsDescendantOf(arg)
				end)

				flag3 = ok and flag3
			end

			if flag3 then
				fn50(k)
			end
		end
	end

	local function fn52(arg)
		if fn49(arg) then
			return
		end

		if arg:IsA("ParticleEmitter") or arg:IsA("Trail") or arg:IsA("Beam") or arg:IsA("Smoke") or arg:IsA("Fire") or arg:IsA("Sparkles") or arg:IsA("PostEffect") then
			v20(arg, "Enabled", false)
		elseif arg:IsA("Decal") or arg:IsA("Texture") then
			v20(arg, "Transparency", 1)
		elseif arg:IsA("SurfaceAppearance") or arg:IsA("Sky") then
			if arg.Parent and obj2[arg] == nil then
				obj2[arg] = arg.Parent
				arg.Parent = nil
			end
		elseif arg:IsA("BasePart") then
			v20(arg, "Material", Enum.Material.SmoothPlastic)
			v20(arg, "CastShadow", false)
			v20(arg, "Reflectance", 0)
		elseif arg:IsA("SpecialMesh") then
			v20(arg, "TextureId", "")
		elseif arg:IsA("Clouds") then
			v20(arg, "Enabled", false)
		end
	end

	local function fn53(arg, arg2)
		if not arg or obj3[arg] then
			return
		end
		obj3[arg] = true
		n4 += 1
		tbl18[n4] = { instance = arg, generation = arg2 }
		if flag2 then
			return
		end
		flag2 = true

		task.spawn(function()
			while fn() and n3 <= n4 do
				local n5 = math.min(n4, n3 + 199)

				while n3 <= n5 do
					local v21 = tbl18[n3]
					tbl18[n3] = nil
					n3 += 1
					local instance = v21 and v21.instance

					if instance then
						obj3[instance] = nil
					end

					if instance and v21.generation == n2 and tbl2.ExtremeFPS then
						fn52(instance)
					end
				end

				RunService.Heartbeat:Wait()
			end

			table.clear(tbl18)
			n3 = 1
			n4 = 0
			flag2 = false
		end)
	end

	local function chsaePerfRestore()
		n2 += 1
		table.clear(tbl18)
		table.clear(obj3)
		n3 = 1
		n4 = 0

		for _, v21 in ipairs(tbl17) do
			pcall(function()
				v21:Disconnect()
			end)
		end

		table.clear(tbl17)

		for k, v21 in pairs(obj2) do
			if k and k.Parent == nil and v21 then
				pcall(function()
					k.Parent = v21
				end)
			end

			obj2[k] = nil
		end

		for k, v21 in pairs(obj) do
			if k and k.Parent then
				for k2, v22 in pairs(v21) do
					pcall(function()
						k[k2] = v22
					end)
				end
			end

			obj[k] = nil
		end

		if qualityLevel then
			pcall(function()
				settings().Rendering.QualityLevel = qualityLevel
			end)

			qualityLevel = nil
		end
	end

	getgenv().__CHSAE_PerfRestore = chsaePerfRestore

	local function fn54()
		chsaePerfRestore()
		n2 += 1
		local v21 = n2
		local Lighting = game:GetService("Lighting")

		tbl17[#tbl17 + 1] = CollectionService:GetInstanceAddedSignal("SakuraBloomTree"):Connect(function(arg)
			if tbl2.ExtremeFPS and n2 == v21 then
				fn51(arg)
			end
		end)

		for _, v22 in ipairs(CollectionService:GetTagged("SakuraBloomTree")) do
			fn51(v22)
		end

		pcall(function()
			qualityLevel = settings().Rendering.QualityLevel
			local level01 = Enum.QualityLevel.Level01
			settings().Rendering.QualityLevel = level01
		end)

		tbl17[#tbl17 + 1] = workspace.DescendantAdded:Connect(function(descendant)
			if tbl2.ExtremeFPS then
				fn53(descendant, v21)
			end
		end)

		tbl17[#tbl17 + 1] = Lighting.ChildAdded:Connect(function(child)
			if tbl2.ExtremeFPS then
				fn53(child, v21)
			end
		end)

		task.spawn(function()
			for _, child in ipairs(Lighting:GetChildren()) do
				if not tbl2.ExtremeFPS or n2 ~= v21 then
					return
				end
				fn52(child)
			end

			local ok, result = pcall(function()
				return workspace:QueryDescendants("ParticleEmitter,Trail,Beam,Smoke,Fire,Sparkles,PostEffect,Decal,Texture,SurfaceAppearance,BasePart,SpecialMesh,Clouds")
			end)

			if not ok or type(result) ~= "table" then
				result = workspace:GetDescendants()
			end

			for i, v22 in ipairs(result) do
				if not fn() or not tbl2.ExtremeFPS or n2 ~= v21 then
					return
				end
				fn52(v22)

				if i % 200 == 0 then
					task.wait()
				end
			end
		end)
	end

	local module = nil

	pcall(function()
		local game_ = (ReplicatedStorage:FindFirstChild("Controllers") or localPlayer.PlayerScripts):FindFirstChild("Game")
		game_ = game_ and game_:FindFirstChild("Plots")
		game_ = game_ and game_:FindFirstChild("ActiveAssetsController")

		if game_ then
			module = require(game_)
		end
	end)

	local function fn55(arg)
		if module and type(module.SetAllPetsHidden) == "function" then
			local ok = pcall(module.SetAllPetsHidden, arg)
			arg = not ok and arg

			if arg then
				lua:Notify("⚠️ Pet visuals unavailable.", 3)
			end

			return ok
		end

		if arg then
			lua:Notify("⚠️ Pet visuals unavailable.", 3)
		end

		return false
	end

	getgenv().__CHSAE_PetsRestore = function()
		fn55(false)
	end

	local HidePetsToggle = (function()
	local _t = {Value = tbl2.HidePets, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.HidePets = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

	HidePetsToggle:OnChanged(function(hidePets)
		tbl2.HidePets = hidePets
		fn55(hidePets)
	end)

	if getgenv().__CHSAE_Debug then
		getgenv().__CHSAE_Debug.SetHidePets = function(arg)
			HidePetsToggle:SetValue(arg == true)
			return tbl2.HidePets
		end
	end

	getgenv().__CHSAE_InstallPenEggHider = function()
		local PlacedEggRenderer = nil
		local parent = nil
		local connection = nil
		local v21

		pcall(function()
			PlacedEggRenderer = require(ReplicatedStorage.Shared.Eggs.PlacedEggRenderer)
			v21 = PlacedEggRenderer.GetRenderFolder()
		end)

		local function fn56(arg)
			if not v21 then
				return false
			end

			if arg then
				if v21.Parent then
					parent = v21.Parent

					pcall(function()
						v21.Parent = nil
					end)
				end
			else
				if v21.Parent == nil and parent then
					pcall(function()
						v21.Parent = parent
					end)
				end

				parent = nil
			end

			return true
		end

		local function chsaePenEggsRestore()
			if connection then
				pcall(function()
					connection:Disconnect()
				end)
			end

			connection = nil
			fn56(false)
		end

		getgenv().__CHSAE_PenEggsRestore = chsaePenEggsRestore

		local function fn57()
			if not tbl2.RemovePenEggs then
				return
			end

			if not fn56(true) or connection then
				return
			end

			connection = workspace.ChildAdded:Connect(function(child)
				if tbl2.RemovePenEggs and child == v21 then
					task.defer(function()
						if tbl2.RemovePenEggs then
							fn56(true)
						end
					end)
				end
			end)
		end

		local RemovePenEggsToggle = (function()
	local _t = {Value = tbl2.RemovePenEggs, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.RemovePenEggs = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

		RemovePenEggsToggle:OnChanged(function(arg)
			tbl2.RemovePenEggs = arg == true

			if tbl2.RemovePenEggs then
				fn57()
			else
				chsaePenEggsRestore()
			end
		end)


		if getgenv().__CHSAE_Debug then
			getgenv().__CHSAE_Debug.SetRemovePenEggs = function(arg)
				RemovePenEggsToggle:SetValue(arg == true)
				return tbl2.RemovePenEggs
			end
		end

		if tbl2.RemovePenEggs then
			task.defer(fn57)
		end
	end

	getgenv().__CHSAE_InstallPenEggHider()
	getgenv().__CHSAE_InstallPenEggHider = nil
	local v21 = nil
	local connection = nil

	local function fn56(arg)
		if tbl2.RemoveAdminTreadmill and arg and arg.Name == "AdminTreadmill" and arg.Parent == workspace then
			v21 = arg

			pcall(function()
				arg.Parent = nil
			end)
		end
	end

	local function fn57()
		if tbl2.RemoveAdminTreadmill then
			fn56(workspace:FindFirstChild("AdminTreadmill"))

			if not connection then
				connection = workspace.ChildAdded:Connect(function(child)
					if child.Name == "AdminTreadmill" then
						task.defer(fn56, child)
					end
				end)

				getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = connection
			end
		else
			if connection then
				connection:Disconnect()
				connection = nil
			end

			if v21 and v21.Parent == nil and not workspace:FindFirstChild("AdminTreadmill") then
				pcall(function()
					v21.Parent = workspace
				end)
			end

			v21 = nil
		end
	end

	getgenv().__CHSAE_AdminTreadmillRestore = function()
		tbl2.RemoveAdminTreadmill = false
		fn57()
	end

	local RemoveAdminTreadmillToggle = (function()
	local _t = {Value = tbl2.RemoveAdminTreadmill, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.RemoveAdminTreadmill = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

	RemoveAdminTreadmillToggle:OnChanged(function(arg)
		tbl2.RemoveAdminTreadmill = arg == true
		fn57()
		fn10(true)
	end)

	if tbl2.RemoveAdminTreadmill then
		task.defer(fn57)
	end

	getgenv().__CHSAE_InstallExtremeFPS = function()
		local obj4 = setmetatable({}, { __mode = "k" })
		local tbl19 = {}
		local tbl20 = {}
		local tbl21 = {}
		local tbl22 = {}
		local n5 = 0
		local flag3 = false
		local PlotState = nil

		pcall(function()
			PlotState = require(ReplicatedStorage.Client.PlotState)
		end)

		local v22 = handlers.rememberingSetter(obj4)

		local function fn58(arg)
			if arg:IsA("BasePart") then
				v22(arg, "LocalTransparencyModifier", 1)
				v22(arg, "CastShadow", false)
			elseif arg:IsA("Decal") or arg:IsA("Texture") then
				v22(arg, "Transparency", 1)
			elseif arg:IsA("ParticleEmitter") or arg:IsA("Trail") or arg:IsA("Beam") or arg:IsA("Smoke") or arg:IsA("Fire") or arg:IsA("Sparkles") or arg:IsA("Highlight") or arg:IsA("BillboardGui") or arg:IsA("SurfaceGui") then
				v22(arg, "Enabled", false)
			elseif arg:IsA("PointLight") or arg:IsA("SpotLight") or arg:IsA("SurfaceLight") then
				v22(arg, "Enabled", false)
			end
		end

		local function fn59(arg, arg2)
			if not arg or arg2 ~= n5 or not tbl2.ExtremeFPS then
				return
			end

			for _, descendant in ipairs(arg:GetDescendants()) do
				fn58(descendant)
			end

			tbl22[#tbl22 + 1] = arg.DescendantAdded:Connect(function(descendant)
				if tbl2.ExtremeFPS and arg2 == n5 then
					fn58(descendant)
				end
			end)
		end

		local function fn60(arg)
			if arg and arg.Parent and tbl19[arg] == nil then
				tbl19[arg] = arg.Parent
				arg.Parent = nil
			end
		end

		local function fn61(arg)
			local v23 = tbl20[arg]
			if not v23 then
				return
			end

			if v23.destroyConn then
				pcall(function()
					v23.destroyConn:Disconnect()
				end)
			end

			if tbl21[v23.key] == arg then
				tbl21[v23.key] = nil
			end

			tbl20[arg] = nil
		end

		local function fn62(arg)
			local v23 = tbl20[arg]
			if not v23 then
				return
			end

			if v23.destroyConn then
				pcall(function()
					v23.destroyConn:Disconnect()
				end)
			end

			pcall(function()
				if arg.Parent == nil and v23.parent then
					arg.Parent = v23.parent
				end
			end)

			if tbl21[v23.key] == arg then
				tbl21[v23.key] = nil
			end

			tbl20[arg] = nil
		end

		local function fn63(arg, arg2, arg3)
			if not (arg and arg.Parent and type(arg2) == "string") then
				return
			end
			local v23 = tbl21[arg2]

			if v23 and v23 ~= arg then
				fn61(v23)
			end

			if not tbl20[arg] then
				local tbl23 = { parent = arg.Parent, key = arg2, slot = tostring(arg3) }
				tbl20[arg] = tbl23
				tbl21[arg2] = arg

				local ok, destroyConn = pcall(function()
					return arg.Destroying:Connect(function()
						local v24 = tbl20[arg]

						if v24 then
							if tbl21[v24.key] == arg then
								tbl21[v24.key] = nil
							end

							tbl20[arg] = nil
						end
					end)
				end)

				if ok then
					tbl23.destroyConn = destroyConn
				end
			end

			pcall(function()
				arg.Parent = nil
			end)
		end

		local function fn64()
			local key = next(tbl20)

			while key do
				fn62(key)
				key = next(tbl20)
			end

			table.clear(tbl21)
		end

		local function fn65(arg)
			local function fn66()
				if not (PlotState and type(PlotState.ResolveLocalSlot) == "function") then
					return nil
				end
				local ok, result = pcall(PlotState.ResolveLocalSlot)
				return ok and result ~= nil and tostring(result) or nil
			end

			local function fn67(arg2, arg3)
				if arg ~= n5 or not tbl2.ExtremeFPS or not arg2 or not tonumber(arg2.Name) or arg2.Name == arg3 then
					return
				end
				local toUpdate = arg2:FindFirstChild("ToUpdate")
				fn63(toUpdate and toUpdate:FindFirstChild("StarterPen"), "pen:" .. arg2.Name, arg2.Name)
			end

			local function fn68(arg2, arg3)
				if arg ~= n5 or not tbl2.ExtremeFPS or not arg2 then
					return
				end
				local match = arg2.Name:match("^TreadmillRender_(%d+)$")

				if match and match ~= arg3 then
					fn63(arg2, "treadmill:" .. match, match)
				end
			end

			local function fn69()
				if arg ~= n5 or not tbl2.ExtremeFPS then
					return
				end
				local v23 = fn66()
				if not v23 then
					return
				end
				local tbl23 = {}

				for k, v24 in pairs(tbl20) do
					if v24.slot == v23 then
						tbl23[#tbl23 + 1] = k
					end
				end

				for _, v24 in ipairs(tbl23) do
					fn62(v24)
				end

				local plots = workspace:FindFirstChild("Plots")

				if plots then
					for _, child in ipairs(plots:GetChildren()) do
						fn67(child, v23)
					end
				end

				local clientTreadmillRenders = workspace:FindFirstChild("__ClientTreadmillRenders")

				if clientTreadmillRenders then
					for _, child in ipairs(clientTreadmillRenders:GetChildren()) do
						fn68(child, v23)
					end
				end
			end

			task.defer(fn69)

			tbl22[#tbl22 + 1] = workspace.DescendantAdded:Connect(function(descendant)
				if arg ~= n5 or not tbl2.ExtremeFPS then
					return
				end

				if descendant.Name == "StarterPen" then
					local parent = descendant.Parent
					local parent2 = parent and parent.Name == "ToUpdate" and parent.Parent or nil

					if parent2 then
						task.defer(function()
							local v23 = fn66()

							if v23 then
								fn67(parent2, v23)
							end
						end)
					end
				elseif descendant.Name:match("^TreadmillRender_%d+$") then
					local parent = descendant.Parent

					if parent and parent.Name == "__ClientTreadmillRenders" then
						task.defer(function()
							local v23 = fn66()

							if v23 then
								fn68(descendant, v23)
							end
						end)
					end
				end
			end)

			if PlotState and PlotState.PlotChanged then
				local ok, result = pcall(function()
					return PlotState.PlotChanged:Connect(function()
						task.defer(fn69)
					end)
				end)

				if ok and result then
					tbl22[#tbl22 + 1] = result
				end
			end
		end

		local function chsaeExtremeRestore()
			n5 += 1

			for _, v23 in ipairs(tbl22) do
				pcall(function()
					v23:Disconnect()
				end)
			end

			table.clear(tbl22)
			fn64()

			for k, v23 in pairs(tbl19) do
				if k and k.Parent == nil and v23 then
					pcall(function()
						k.Parent = v23
					end)
				end

				tbl19[k] = nil
			end

			for k, v23 in pairs(obj4) do
				if k and k.Parent then
					for k2, v24 in pairs(v23) do
						pcall(function()
							k[k2] = v24
						end)
					end
				end

				obj4[k] = nil
			end
		end

		getgenv().__CHSAE_ExtremeRestore = chsaeExtremeRestore

		local function fn66()
			chsaeExtremeRestore()
			n5 += 1
			local v23 = n5
			fn54()
			flag3 = not HidePetsToggle.Value

			if flag3 then
				HidePetsToggle:SetValue(true)
			end

			local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
			local build = world and world:FindFirstChild("Build")
			fn60(build and build:FindFirstChild("Props"))

			if build then
				for _, child in ipairs(build:GetChildren()) do
					if child:IsA("Folder") or child:IsA("Model") then
						fn60(child:FindFirstChild("Props"))
					end
				end
			end

			fn60(world and world:FindFirstChild("Leaderboards"))
			fn60(world and world:FindFirstChild("ExclamationPoints"))
			fn60(world and world:FindFirstChild("Highlights"))
			fn60(world and world:FindFirstChild("GroupRewards") or build and build:FindFirstChild("GroupRewards"))
			fn65(v23)

			local function fn67(player)
				if player == localPlayer then
					return
				end

				if player.Character then
					fn59(player.Character, v23)
				end

				tbl22[#tbl22 + 1] = player.CharacterAdded:Connect(function(character)
					task.defer(fn59, character, v23)
				end)
			end

			for _, player in ipairs(Players2:GetPlayers()) do
				fn67(player)
			end

			tbl22[#tbl22 + 1] = Players2.PlayerAdded:Connect(fn67)
		end

		local function fn67()
			chsaeExtremeRestore()
			chsaePerfRestore()

			if flag3 and HidePetsToggle.Value then
				HidePetsToggle:SetValue(false)
			end

			flag3 = false
		end

		local ExtremeFPSToggle = (function()
	local _t = {Value = tbl2.ExtremeFPS, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.ExtremeFPS = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

		ExtremeFPSToggle:OnChanged(function(arg)
			tbl2.ExtremeFPS = arg == true

			if tbl2.ExtremeFPS then
				fn66()
			else
				fn67()
			end
		end)

		if getgenv().__CHSAE_Debug then
			getgenv().__CHSAE_Debug.SetExtremeFPS = function(arg)
				ExtremeFPSToggle:SetValue(arg == true)
			end
		end

		if tbl2.ExtremeFPS then
			task.defer(fn66)
		end
	end

	getgenv().__CHSAE_InstallExtremeFPS()
	getgenv().__CHSAE_InstallExtremeFPS = nil
	local frame = Instance.new("Frame")
	frame.Name = "CHSAE_BlackScreen"
	frame.Size = UDim2.new(1, 0, 1, 200)
	frame.Position = UDim2.new(0, 0, 0, -100)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 0
	frame.BorderSizePixel = 0
	frame.ZIndex = 0
	frame.Active = false
	frame.Visible = false
	frame.Parent = lua.ScreenGui

	local function fn58()
		local tbl19 = {
			panel = Color3.fromRGB(11, 15, 18),
			card = Color3.fromRGB(18, 24, 29),
			cardSoft = Color3.fromRGB(15, 20, 24),
			outline = Color3.fromRGB(39, 52, 61),
			text = Color3.fromRGB(235, 242, 245),
			muted = Color3.fromRGB(139, 153, 163),
			green = Color3.fromRGB(74, 222, 128),
			cyan = Color3.fromRGB(56, 189, 248),
			blue = Color3.fromRGB(96, 165, 250),
			gold = Color3.fromRGB(251, 191, 36),
			pink = Color3.fromRGB(244, 114, 182),
			orange = Color3.fromRGB(251, 146, 60),
			violet = Color3.fromRGB(167, 139, 250),
		}

		local font = lua.Scheme.Font

		pcall(function()
			font = Font.new(font.Family, Enum.FontWeight.SemiBold, font.Style)
		end)

		local frame2 = Instance.new("Frame")
		frame2.Name = "CHSAE_BlackScreenMonitor"
		frame2.AnchorPoint = Vector2.new(0.5, 0.5)
		frame2.Position = UDim2.fromScale(0.5, 0.5)
		frame2.Size = UDim2.new(0.92, 0, 0, 386)
		frame2.BackgroundTransparency = 1
		frame2.BorderSizePixel = 0
		frame2.ZIndex = 1
		frame2.Parent = frame
		local uiSizeConstraint = Instance.new("UISizeConstraint")
		uiSizeConstraint.MinSize = Vector2.new(300, 386)
		uiSizeConstraint.MaxSize = Vector2.new(620, 386)
		uiSizeConstraint.Parent = frame2
		local uiScale = Instance.new("UIScale")
		uiScale.Name = "ShortViewportScale"
		uiScale.Scale = 1
		uiScale.Parent = frame2

		local function fn59()
			local n5 = 600

			pcall(function()
				local currentCamera = workspace.CurrentCamera

				if currentCamera then
					n5 = currentCamera.ViewportSize.Y
				end
			end)

			uiScale.Scale = math.clamp((n5 - 16) / 386, 0.7, 1)
		end

		local function fn60(parent, arg)
			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(0, arg)
			uiCorner.Parent = parent
		end

		local function createTextLabel(parent, name, position, size, text, textSize, textColor3, textXAlignment, zIndex)
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = name
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0
			textLabel.Position = position
			textLabel.Size = size
			textLabel.FontFace = font
			textLabel.Text = text or ""
			textLabel.TextSize = textSize or 12
			textLabel.TextColor3 = textColor3 or tbl19.text
			textLabel.TextXAlignment = textXAlignment or Enum.TextXAlignment.Left
			textLabel.TextYAlignment = Enum.TextYAlignment.Center
			textLabel.TextTruncate = Enum.TextTruncate.AtEnd
			textLabel.ZIndex = zIndex or 3
			textLabel.Parent = parent
			return textLabel
		end

		local frame3 = Instance.new("Frame")
		frame3.Name = "Dashboard"
		frame3.Size = UDim2.new(1, 0, 0, 321)
		frame3.BackgroundColor3 = tbl19.panel
		frame3.BorderSizePixel = 0
		frame3.ZIndex = 1
		frame3.Parent = frame2
		fn60(frame3, 12)
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = tbl19.outline
		uiStroke.Thickness = 1
		uiStroke.Transparency = 0.1
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uiStroke.Parent = frame3
		local frame4 = Instance.new("Frame")
		frame4.Name = "CloverAccent"
		frame4.Size = UDim2.new(1, 0, 0, 3)
		frame4.BackgroundColor3 = tbl19.green
		frame4.BorderSizePixel = 0
		frame4.ZIndex = 2
		frame4.Parent = frame3
		fn60(frame4, 12)
		local uiGradient = Instance.new("UIGradient")
		local colorSequence = ColorSequence.new
		local tbl20 = {}
		local v22 = ColorSequenceKeypoint.new(0, tbl19.green)
		local v23 = ColorSequenceKeypoint.new(0.55, Color3.fromRGB(34, 197, 94))
		local new = ColorSequenceKeypoint.new
		local cyan = tbl19.cyan
		tbl20[1] = v22
		tbl20[2] = v23

		do
			local values = table.pack(new(1, cyan))
			table.move(values, 1, values.n, 3, tbl20)
		end

		uiGradient.Color = colorSequence(tbl20)
		uiGradient.Parent = frame4
		local frame5 = Instance.new("Frame")
		frame5.Name = "Mark"
		frame5.Position = UDim2.fromOffset(14, 12)
		frame5.Size = UDim2.fromOffset(38, 38)
		frame5.BackgroundColor3 = Color3.fromRGB(20, 54, 38)
		frame5.BorderSizePixel = 0
		frame5.ZIndex = 2
		frame5.Parent = frame3
		fn60(frame5, 9)
		local green = tbl19.green
		local center = Enum.TextXAlignment.Center
		createTextLabel(frame5, "Glyph", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), "C", 21, green, center, 3)
		local text = tbl19.text
		local left = Enum.TextXAlignment.Left
		local brand = createTextLabel(frame3, "Brand", UDim2.fromOffset(62, 9), UDim2.new(1, -174, 0, 27), "CLOVERHUB", 22, text, left, 3)
		brand.RichText = true
		brand.Text = "<b>CLOVER<font color=\"#4ADE80\">HUB</font></b>"
		local muted = tbl19.muted
		local left2 = Enum.TextXAlignment.Left
		createTextLabel(frame3, "User", UDim2.fromOffset(62, 35), UDim2.new(1, -180, 0, 17), "@" .. tostring(localPlayer.Name), 13, muted, left2, 3)
		local frame6 = Instance.new("Frame")
		frame6.Name = "LiveBadge"
		frame6.AnchorPoint = Vector2.new(1, 0)
		frame6.Position = UDim2.new(1, -14, 0, 16)
		frame6.Size = UDim2.fromOffset(94, 26)
		frame6.BackgroundColor3 = Color3.fromRGB(18, 52, 36)
		frame6.BorderSizePixel = 0
		frame6.ZIndex = 2
		frame6.Parent = frame3
		fn60(frame6, 13)
		local green2 = tbl19.green
		local center2 = Enum.TextXAlignment.Center
		local text2 = createTextLabel(frame6, "Text", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), "●  LIVE · 1P", 12, green2, center2, 3)
		local frame7 = Instance.new("Frame")
		frame7.Position = UDim2.new(0, 14, 0, 59)
		frame7.Size = UDim2.new(1, -28, 0, 1)
		frame7.BackgroundColor3 = tbl19.outline
		frame7.BackgroundTransparency = 0.35
		frame7.BorderSizePixel = 0
		frame7.ZIndex = 2
		frame7.Parent = frame3
		local frame8 = Instance.new("Frame")
		frame8.Name = "Activity"
		frame8.Position = UDim2.new(0, 14, 0, 67)
		frame8.Size = UDim2.new(1, -28, 0, 45)
		frame8.BackgroundColor3 = tbl19.cardSoft
		frame8.BorderSizePixel = 0
		frame8.ZIndex = 2
		frame8.Parent = frame3
		fn60(frame8, 7)
		local muted2 = tbl19.muted
		local left3 = Enum.TextXAlignment.Left
		createTextLabel(frame8, "Title", UDim2.fromOffset(11, 4), UDim2.new(1, -22, 0, 14), "CURRENT AUTOMATION", 12, muted2, left3, 3)
		local green3 = tbl19.green
		local left4 = Enum.TextXAlignment.Left
		local value = createTextLabel(frame8, "Value", UDim2.fromOffset(11, 18), UDim2.new(1, -22, 0, 23), "Starting CloverHub…", 19, green3, left4, 3)
		local frame9 = Instance.new("Frame")
		frame9.Name = "Metrics"
		frame9.Position = UDim2.new(0, 14, 0, 120)
		frame9.Size = UDim2.new(1, -28, 0, 168)
		frame9.BackgroundTransparency = 1
		frame9.BorderSizePixel = 0
		frame9.ZIndex = 2
		frame9.Parent = frame3
		local uiGridLayout = Instance.new("UIGridLayout")
		uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiGridLayout.CellPadding = UDim2.fromOffset(7, 7)
		uiGridLayout.CellSize = UDim2.new(0.33333333333333331, -5, 0, 51)
		uiGridLayout.Parent = frame9

		local function fn61(name, arg, backgroundColor3, layoutOrder)
			local frame10 = Instance.new("Frame")
			frame10.Name = name
			frame10.LayoutOrder = layoutOrder
			frame10.BackgroundColor3 = tbl19.card
			frame10.BorderSizePixel = 0
			frame10.ZIndex = 2
			frame10.Parent = frame9
			fn60(frame10, 7)
			local frame11 = Instance.new("Frame")
			frame11.Position = UDim2.fromOffset(0, 8)
			frame11.Size = UDim2.new(0, 4, 1, -16)
			frame11.BackgroundColor3 = backgroundColor3
			frame11.BorderSizePixel = 0
			frame11.ZIndex = 3
			frame11.Parent = frame10
			fn60(frame11, 2)
			local muted3 = tbl19.muted
			local left5 = Enum.TextXAlignment.Left
			createTextLabel(frame10, "Title", UDim2.fromOffset(11, 4), UDim2.new(1, -15, 0, 14), arg, 12, muted3, left5, 3)
			local left6 = Enum.TextXAlignment.Left
			local parent = createTextLabel(frame10, "Value", UDim2.fromOffset(11, 19), UDim2.new(1, -15, 0, 25), "--", 18, backgroundColor3, left6, 3)
			parent.TextScaled = true
			local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
			uiTextSizeConstraint.MinTextSize = 11
			uiTextSizeConstraint.MaxTextSize = 18
			uiTextSizeConstraint.Parent = parent
			return parent
		end

		local Balance = fn61("Balance", "BALANCE", tbl19.gold, 1)
		local Income = fn61("Income", "INCOME/SEC", tbl19.green, 2)
		local PetValue = fn61("PetValue", "PET VALUE", tbl19.violet, 3)
		local EggBag = fn61("EggBag", "EGG BAG", tbl19.pink, 4)
		local Steals = fn61("Steals", "STEALS", tbl19.cyan, 5)
		local Attempts = fn61("Attempts", "ATTEMPTS", tbl19.orange, 6)
		local fps = fn61("FPS", "FPS", tbl19.green, 7)
		local Ping = fn61("Ping", "PING", tbl19.blue, 8)
		local Session = fn61("Session", "SESSION", tbl19.violet, 9)
		local frame10 = Instance.new("Frame")
		frame10.Name = "EventDot"
		frame10.Position = UDim2.fromOffset(15, 303)
		frame10.Size = UDim2.fromOffset(8, 8)
		frame10.BackgroundColor3 = tbl19.pink
		frame10.BorderSizePixel = 0
		frame10.ZIndex = 3
		frame10.Parent = frame3
		fn60(frame10, 4)
		local left5 = Enum.TextXAlignment.Left
		local event2 = createTextLabel(frame3, "Event", UDim2.fromOffset(29, 294), UDim2.new(1, -44, 0, 25), "Event status loading…", 13, Color3.fromRGB(216, 180, 254), left5, 3)
		local muted3 = tbl19.muted
		local center3 = Enum.TextXAlignment.Center
		createTextLabel(frame2, "CommunityTitle", UDim2.new(0, 0, 0, 327), UDim2.new(1, 0, 0, 14), "JOIN THE CLOVERHUB COMMUNITY", 11, muted3, center3, 2)
		local cyan2 = tbl19.cyan
		local center4 = Enum.TextXAlignment.Center
		local discord = createTextLabel(frame2, "Discord", UDim2.new(0, 0, 0, 342), UDim2.new(1, 0, 0, 25), "discord.gg/CloverOnTop", 19, cyan2, center4, 2)
		discord.RichText = true
		discord.Text = "<b>discord.gg/<font color=\"#4ADE80\">CloverOnTop</font></b>"
		local str = "CloverHub " .. chsaeReleaseVersion .. "  •  3D RENDERING PAUSED"
		local center5 = Enum.TextXAlignment.Center
		createTextLabel(frame2, "Version", UDim2.new(0, 0, 0, 370), UDim2.new(1, 0, 0, 14), str, 10, Color3.fromRGB(91, 105, 113), center5, 2)

		local tbl21 = {
			Root = frame2,
			Refresh = function()
				fn59()
				local text3 = "Idle"

				pcall(function()
					text3 = tostring(tbl14.status())
				end)

				value.Text = text3
				Balance.Text = tostring(liveMetrics:Get("money"))
				Income.Text = tostring(liveMetrics:Get("income"))
				PetValue.Text = tostring(liveMetrics:Get("petValue"))
				EggBag.Text = tostring(liveMetrics:Get("eggs"))
				Steals.Text = tostring(tonumber(handlers.steals) or 0)
				Attempts.Text = tostring(tonumber(handlers.attempts) or 0)
				fps.Text = tostring(clientFPS)
				Ping.Text = tostring(sessionMetrics:Get("ping"))
				Session.Text = fn4(os.clock() - now)
				event2.Text = tostring(handlers.adminEventStatus or "Waiting for event data")
				frame10.BackgroundColor3 = handlers.riftActive and tbl19.pink or tbl19.cyan
				local n5 = 1

				pcall(function()
					n5 = #Players2:GetPlayers()
				end)

				text2.Text = ("●  LIVE · %dP"):format(n5)
			end,
			GetState = function()
				return {
					Visible = frame.Visible == true,
					Activity = value.Text,
					Money = Balance.Text,
					Income = Income.Text,
					PetValue = PetValue.Text,
					Eggs = EggBag.Text,
					Steals = Steals.Text,
					Attempts = Attempts.Text,
					FPS = fps.Text,
					Ping = Ping.Text,
					Session = Session.Text,
					Event = event2.Text,
					Discord = "discord.gg/CloverOnTop",
				}
			end,
		}

		task.spawn(function()
			while fn() do
				if not tbl2.BlackScreen then
					tbl.IdleWorkerWake.Event:Wait()
				else
					pcall(tbl21.Refresh)
					task.wait(1)
				end
			end
		end)

		tbl21.Refresh()
		return tbl21
	end

	local v22 = fn58()

	local function fn59(arg)
		local visible = arg == true
		frame.Visible = visible

		if visible then
			pcall(v22.Refresh)
		end

		pcall(function()
			RunService:Set3dRenderingEnabled(not visible)
		end)
	end

	getgenv().__CHSAE_RenderRestore = function()
		pcall(function()
			RunService:Set3dRenderingEnabled(true)
		end)
	end

	local n5 = nil

	local function fn60()
		if type(setfpscap) ~= "function" then
			return
		end
		local flag3 = tbl2.UnlockFPS == true
		local flag4

		if flag3 then
			flag4 = flag3
		else
			flag4 = tbl2.BoostTickRate == true and tbl2.BlackScreen == true
		end

		if flag4 then
			if n5 == nil then
				local ok, result = pcall(function()
					return type(getfpscap) == "function" and getfpscap() or nil
				end)

				n5 = ok and tonumber(result) or 60
			end

			pcall(setfpscap, tbl2.UnlockFPS == true and 999 or 240)
		elseif n5 ~= nil then
			pcall(setfpscap, n5)
			n5 = nil
		end
	end

	local chsaePerfRestore2 = getgenv().__CHSAE_PerfRestore

	getgenv().__CHSAE_PerfRestore = function()
		if n5 ~= nil and type(setfpscap) == "function" then
			pcall(setfpscap, n5)
			n5 = nil
		end

		if type(chsaePerfRestore2) == "function" then
			pcall(chsaePerfRestore2)
		end
	end

	local BlackScreenToggle = (function()
	local _t = {Value = tbl2.BlackScreen, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.BlackScreen = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

	BlackScreenToggle:OnChanged(function(blackScreen)
		tbl2.BlackScreen = blackScreen
		fn59(blackScreen)
		tbl.WakeIdleWorkers("black-screen-toggle")
		fn60()
		local chsaeStatusGui = getgenv().__CHSAE_StatusGui

		if chsaeStatusGui then
			local chsaeStatusRefresh = getgenv().__CHSAE_StatusRefresh

			if type(chsaeStatusRefresh) == "function" then
				pcall(chsaeStatusRefresh)
			else
				pcall(function()
					chsaeStatusGui:SetVisible(tbl2.ShowStatusOverlay and not blackScreen)
				end)
			end
		end
	end)

	fn59(tbl2.BlackScreen)

	local UnlockFPSToggle = (function()
	local _t = {Value = tbl2.UnlockFPS, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.UnlockFPS = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

	UnlockFPSToggle:OnChanged(function(arg)
		tbl2.UnlockFPS = arg == true
		fn60()
	end)


	local BoostTickRateToggle = (function()
	local _t = {Value = tbl2.BoostTickRate, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.BoostTickRate = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

	BoostTickRateToggle:OnChanged(function(arg)
		tbl2.BoostTickRate = arg == true
		fn60()
	end)


	fn60()

	if type(getgenv().__CHSAE_Debug) == "table" then
		getgenv().__CHSAE_Debug.SetBlackScreen = function(arg)
			BlackScreenToggle:SetValue(arg == true)
			return v22.GetState()
		end

		local getState = v22.GetState
		getgenv().__CHSAE_Debug.GetBlackScreenMonitorState = getState

		getgenv().__CHSAE_Debug.GetTickRateState = function()
			local flag3 = nil

			pcall(function()
				flag3 = type(getfpscap) == "function" and getfpscap() or nil
			end)

			return {
				BoostTickRate = tbl2.BoostTickRate == true,
				BlackScreen = tbl2.BlackScreen == true,
				Applied = n5 ~= nil,
				SavedCap = n5,
				CurrentCap = flag3,
			}
		end
	end

	if tbl2.HidePets then
		task.defer(fn55, true)
	end
end

v3.__ESPBox = settings_:AddRightGroupbox("👁 ESP")

do
	local EggESPToggle = (function()
	local _t = {Value = tbl2.EggESP, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.EggESP = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

	EggESPToggle:OnChanged(function(arg)
		tbl2.EggESP = arg == true
		handlers.setEggESP(tbl2.EggESP)
	end)

	local eggESPAreas = bindDropdownOverlay(v3.__ESPBox, "EggESPAreas", "Areas", tbl6, {
		configKey = "EggESPAreas",
		multi = true,
		store = tbl2.EggESPAreas,
		text = "Areas",
		tooltip = "Choose spawning areas. Empty = all.",
		displayMap = tbl7,
		onChange = function()
			handlers.refreshEggESP()
		end,
	})

	local setValue = eggESPAreas.SetValue

	eggESPAreas.SetValue = function(arg, arg2)
		setValue(arg, arg2)

		for k in pairs(tbl2.EggESPAreas) do
			if not table.find(tbl6, k) then
				tbl2.EggESPAreas[k] = nil
			end
		end

		handlers.refreshEggESP()
	end

	local PenESPToggle = (function()
	local _t = {Value = tbl2.PenESP, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.PenESP = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

	PenESPToggle:OnChanged(function(arg)
		tbl2.PenESP = arg == true
		handlers.setPenESP(tbl2.PenESP)
	end)

	local InventoryESPToggle = (function()
	local _t = {Value = tbl2.InventoryESP, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.InventoryESP = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

	InventoryESPToggle:OnChanged(function(arg)
		tbl2.InventoryESP = arg == true
		handlers.setInventoryESP(tbl2.InventoryESP)
	end)

end

handlers.setEggESP(tbl2.EggESP)
handlers.setPenESP(tbl2.PenESP)
handlers.setInventoryESP(tbl2.InventoryESP)

do
	local v20 = settings_:AddLeftGroupbox("📡 Status")
	local chsaeAutoExecute = getgenv().__CHSAE_AutoExecute
	tbl.AutoExecute = chsaeAutoExecute
	chsaeAutoExecute:restore()

	local AutoExecute = (function()
	local t = { Value = chsaeAutoExecute.enabled, _callbacks = {} }
	function t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function t:SetValue(val)
		self.Value = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	function t:SetDisabled() end
	return t
end)()
	AutoExecute:SetDisabled(not chsaeAutoExecute.files)
	local flag2 = false

	AutoExecute:OnChanged(function(arg)
		if not fn() or flag2 then
			return
		end

		if not chsaeAutoExecute:set(arg == true) and AutoExecute.Value ~= chsaeAutoExecute.enabled then
			flag2 = true
			AutoExecute:SetValue(chsaeAutoExecute.enabled)
			flag2 = false
		end

		if not chsaeAutoExecute.queue or not chsaeAutoExecute.files or chsaeAutoExecute.enabled ~= arg == true or chsaeAutoExecute.enabled and not chsaeAutoExecute.queued then
			lua:Notify(chsaeAutoExecute.note, 6)
		end
	end)

	local v21 = nil
	local flag3 = false

	local function fn49()
		local screenGui = lua.ScreenGui
		local y = screenGui and screenGui.AbsoluteSize.Y or 0

		if y <= 0 then
			y = workspace.CurrentCamera
			y = y and y.ViewportSize.Y or 1080
		end

		return UDim2.fromOffset(48, math.floor(y * 0.66 + 0.5))
	end

	local function chsaeStatusRefresh()
		if v21 then
			local flag4 = tbl2.ShowStatusOverlay and not tbl2.BlackScreen and not flag3
			v21:SetVisible(flag4)

			if flag4 then
				handlers.wakeOverlay("overlay-visible")
			end
		end
	end

	local chsaeStatusGui = getgenv().__CHSAE_StatusGui

	if chsaeStatusGui then
		pcall(function()
			chsaeStatusGui:Destroy()
		end)
	end

	v21 = lua:AddDraggableLabel("[Activity] Idle")
	local label = v21.Label
	label.Name = "CHSAE_StatusOverlay"
	label.Parent = lua.ScreenGui
	label.ZIndex = 0
	label.AnchorPoint = Vector2.new(0, 0.5)
	label.Position = fn49()

	task.defer(function()
		if fn() and label.Parent then
			label.Position = fn49()
		end
	end)

	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.TextWrapped = false
	label.RichText = true
	label.BackgroundTransparency = 1
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.TextStrokeTransparency = 0.35

	for _, child in ipairs(label:GetChildren()) do
		if child:IsA("UIStroke") then
			child.Transparency = 1
		end
	end

	getgenv().__CHSAE_StatusGui = v21
	getgenv().__CHSAE_StatusRefresh = chsaeStatusRefresh

	pcall(function()
		local GuiService = game:GetService("GuiService")

		getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = GuiService.MenuOpened:Connect(function()
			flag3 = true
			chsaeStatusRefresh()
		end)

		getgenv().__CHSAE_RuntimeConns[#getgenv().__CHSAE_RuntimeConns + 1] = GuiService.MenuClosed:Connect(function()
			flag3 = false
			chsaeStatusRefresh()
		end)
	end)

	v20:AddToggle("ShowStatusOverlayToggle", {
		Text = "Show Status",
		Default = tbl2.ShowStatusOverlay,
		Tooltip = "Show automation status on screen.",
	}):OnChanged(function(showStatusOverlay)
		tbl2.ShowStatusOverlay = showStatusOverlay
		chsaeStatusRefresh()
	end)

	chsaeStatusRefresh()

	local function fn50()
		local genv = getgenv()
		local chsaeAFKNativeState = genv.__CHSAE_AFKNativeState

		if type(chsaeAFKNativeState) ~= "table" or chsaeAFKNativeState.JobId ~= game.JobId then
			chsaeAFKNativeState = { JobId = game.JobId, Disabled = {}, Removed = 0 }
			genv.__CHSAE_AFKNativeState = chsaeAFKNativeState
		end

		chsaeAFKNativeState.Controllers = chsaeAFKNativeState.Controllers or {}

		local tbl17 = {
			Enabled = false,
			Connections = {},
			Error = nil,
			NativeDisabled = 0,
			LuaDisabled = 0,
			IdleReports = 0,
			Generation = 0,
			Events = {},
			Started = os.clock(),
		}

		local function fn51()
			if not tbl17.LogPath or not tbl17.LogDirty and not tbl17.LogError then
				return
			end

			local ok, result = pcall(function()
				assert(type(writefile) == "function", "writefile unavailable")

				writefile(tbl17.LogPath, "CloverHub AFK lifecycle test r1 | " .. chsaeBuildId .. "\nAccount=" .. localPlayer.Name .. " Job=" .. game.JobId .. [[

Suppression state is NOT proof of idle reset. No simulated input or keepalive remotes.
]] .. table.concat(tbl17.Events, "\n") .. "\n")
			end)

			local logError = nil

			if not ok then
				logError = tostring(result)
			end

			if logError and logError ~= tbl17.LogError then
				warn("[CloverHub-SAE] AFK log save failed: " .. logError)
			end

			tbl17.LogError = logError

			if ok then
				tbl17.LogDirty = false
			end
		end

		local function fn52(arg)
			local n2 = #tbl17.Events + 1
			local started = tbl17.Started
			tbl17.Events[n2] = string.format("[%.2f] %s", os.clock() - started, tostring(arg))

			if #tbl17.Events > 400 then
				table.remove(tbl17.Events, 1)
			end

			tbl17.LogDirty = true
		end

		local function fn53()
			return tbl17.Enabled and fn()
		end

		local function fn54(arg)
			tbl17.Error = tostring(arg)
			fn52("ERROR " .. tbl17.Error)
			fn51()
			genv.__CHSAE_AFKStartupError = { Message = tbl17.Error, Method = "Targeted game callback + native idle suppression" }
			warn("[CloverHub-SAE] Anti-AFK: " .. tbl17.Error)
		end

		local function fn55()
			for k in pairs(chsaeAFKNativeState.Disabled) do
				local ok, result = pcall(function()
					if k.Connected == false then
						return
					end
					k:Enable()

					if k.Enabled ~= true then
						error("Idle listener restoration not confirmed")
					end
				end)

				if ok then
					chsaeAFKNativeState.Disabled[k] = nil
				else
					fn52("WARN " .. tostring(result))
				end
			end

			for k, controller in pairs(chsaeAFKNativeState.Controllers) do
				local ok, result = pcall(function()
					if not k.Parent then
						return
					end
					k.Enabled = controller

					if k.Enabled ~= controller then
						error("AFK controller restoration not confirmed")
					end
				end)

				if ok then
					chsaeAFKNativeState.Controllers[k] = nil
				else
					fn52("WARN " .. tostring(result))
				end
			end

			return next(chsaeAFKNativeState.Disabled) == nil and next(chsaeAFKNativeState.Controllers) == nil
		end

		local function chsaeAFKGuardRestore()
			tbl17.Enabled = false
			tbl17.Generation = tbl17.Generation + 1
			local flag4 = true

			for i = #tbl17.Connections, 1, -1 do
				local ok, result = pcall(function()
					tbl17.Connections[i]:Disconnect()
				end)

				if ok then
					table.remove(tbl17.Connections, i)
				else
					fn54(result)
					flag4 = false
				end
			end

			flag4 = fn55() and flag4
			fn52("STOP restored=" .. tostring(flag4) .. " legacyControllersRemoved=" .. tostring(chsaeAFKNativeState.Removed))
			fn51()
			return flag4
		end

		local function fn56(arg)
			local function_ = arg.Function
			if type(function_) ~= "function" then
				return false
			end
			local v22 = debug.info(function_, "s")
			return v22 == "ReplicatedStorage.Controllers.Game.AntiAFKController" or v22 == "Players." .. localPlayer.Name .. ".PlayerScripts.Game.AntiAFK"
		end

		local function fn57()
			if tbl17.TimerGroup == nil then
				local ok, result = pcall(function()
					local AfkTreadmillTest = require(game:GetService("ReplicatedStorage").Shared.Modules.AfkTreadmillTest)
					return AfkTreadmillTest.GetGroupAsync(localPlayer) == AfkTreadmillTest.Groups.Variant
				end)

				if not ok then
					return
				end
				tbl17.TimerGroup = result and "Variant" or "Control"
				fn52("Game AFK test group " .. tbl17.TimerGroup)
			end

			if tbl17.TimerGroup ~= "Variant" then
				return
			end
			local flag4 = not tbl17.MarkActive
			local flag5

			if flag4 then
				flag5 = os.clock() >= (tbl17.TimerScanAt or 0)
			else
				flag5 = flag4
			end

			if flag5 and type(getgc) == "function" then
				tbl17.TimerScanAt = os.clock() + 60

				for _, v22 in ipairs(getgc()) do
					if type(v22) == "function" and debug.info(v22, "s") == "ReplicatedStorage.Controllers.Game.AntiAFKController" and debug.info(v22, "n") == "markActive" then
						tbl17.MarkActive = v22
						fn52("Game AFK rescue timer found")
						break
					end
				end
			end

			if tbl17.MarkActive then
				tbl17.MarkActive()
			end
		end

		local function fn58()
			local getSignalCons = getconnections or genv.get_signal_cons
			if type(getSignalCons) ~= "function" then
				fn54("Idle listener inspection unavailable")
				return
			end
			local ok, result = pcall(getSignalCons, localPlayer.Idled)
			if not ok or type(result) ~= "table" then
				fn54("Idle listener inspection failed")
				return
			end
			local v22 = tbl17
			tbl17.NativeDisabled = 0
			v22.LuaDisabled = 0

			for _, v23 in pairs(result) do
				local ok2, result2 = pcall(function()
					local luaConnection = v23.LuaConnection

					if type(luaConnection) ~= "boolean" then
						error("Idle listener classification unknown")
					end

					if luaConnection and not fn56(v23) then
						return
					end
					local str = luaConnection and "LuaDisabled" or "NativeDisabled"
					if v23.Enabled == false then
						tbl17[str] = tbl17[str] + 1
						return
					end

					if v23.Enabled ~= true or type(v23.Disable) ~= "function" or type(v23.Enable) ~= "function" then
						error("Idle listener has no verifiable, reversible Disable/Enable API")
					end

					chsaeAFKNativeState.Disabled[v23] = true
					v23:Disable()

					if v23.Enabled ~= false then
						error("Idle listener did not report disabled")
					end

					fn52((luaConnection and "Game" or "Native") .. " idle listener disabled/repaired")
					tbl17[str] = tbl17[str] + 1
				end)

				if not ok2 then
					fn52("WARN listener suppression will retry: " .. tostring(result2))
				end
			end

			local nativeMissing = tbl17.NativeDisabled == 0

			if nativeMissing ~= tbl17.NativeMissing then
				tbl17.NativeMissing = nativeMissing
				fn52(nativeMissing and "PARTIAL native idle listener unavailable; native protection unverified; continuing callback checks" or "Native idle listener suppression observed; idle reset still unverified")
			end
		end

		local function fn59()
			if not fn53() then
				return false
			end
			fn58()
			if tbl17.Error then
				chsaeAFKGuardRestore()
				return false, tbl17.Error
			end
			return true
		end

		local function fn60()
			if fn53() then
				return fn59()
			end
			chsaeAFKGuardRestore()
			local v22 = genv
			tbl17.Error = nil
			v22.__CHSAE_AFKStartupError = nil
			tbl17.LogPath = tbl17.LogPath or "CloverHub-AFK-Health-" .. localPlayer.Name .. ".log"
			fn52("START UTC=" .. os.date("!%Y-%m-%dT%H:%M:%SZ") .. " legacyControllersRemoved=" .. tostring(chsaeAFKNativeState.Removed))
			tbl17.Enabled = true
			fn58()
			if tbl17.Error then
				chsaeAFKGuardRestore()
				return false, tbl17.Error
			end

			tbl17.Connections[#tbl17.Connections + 1] = localPlayer.Idled:Connect(function(idleTime)
				if not fn53() then
					return
				end
				tbl17.IdleReports = tbl17.IdleReports + 1
				tbl17.LastIdleSeconds = idleTime
				fn52("IDLED seconds=" .. tostring(idleTime))
				fn51()
			end)

			local GuiService = game:GetService("GuiService")

			local function fn61()
				local ok, lastDisconnect = pcall(function()
					return GuiService:GetErrorMessage()
				end)

				if ok and type(lastDisconnect) == "string" and lastDisconnect ~= "" and tbl17.LastDisconnect ~= lastDisconnect then
					tbl17.LastDisconnect = lastDisconnect
					fn52("DISCONNECT " .. lastDisconnect:sub(1, 700))
					fn51()
				end
			end

			tbl17.Connections[#tbl17.Connections + 1] = GuiService.ErrorMessageChanged:Connect(fn61)

			tbl17.Connections[#tbl17.Connections + 1] = localPlayer.OnTeleport:Connect(function(arg)
				if not fn53() then
					return
				end
				fn52("TELEPORT " .. tostring(arg))
				fn51()
			end)

			tbl17.Connections[#tbl17.Connections + 1] = localPlayer.CharacterAdded:Connect(function()
				if not fn53() then
					return
				end
				fn52("RESPAWN; next health check within 5 seconds")
				fn51()
			end)

			local generation = tbl17.Generation

			task.spawn(function()
				local n2 = 0

				while true do
					if fn53() and generation == tbl17.Generation then
						local ok, result = pcall(fn59)

						if not ok then
							fn54("Health check failed: " .. tostring(result))
							chsaeAFKGuardRestore()
						end

						if not (not fn53() or generation ~= tbl17.Generation) then
							fn61()
							local ok2, result2 = pcall(fn57)

							if not ok2 then
								fn52("Game AFK timer refresh failed: " .. tostring(result2))
							end

							if n2 <= os.clock() then
								fn52("HEALTH nativeDisabled=" .. tbl17.NativeDisabled .. " idleReports=" .. tbl17.IdleReports .. " lastIdle=" .. tostring(tbl17.LastIdleSeconds) .. " idleResetVerified=false")
								n2 = os.clock() + 60
							end

							fn51()
							task.wait(5)
							continue
						end
					end

					break
				end
			end)

			fn51()
			return tbl17.Error == nil, tbl17.Error
		end

		local function fn61()
			local ok, result, result2 = pcall(fn60)
			if ok then
				return result, result2
			end
			fn54("Startup failed: " .. tostring(result))
			chsaeAFKGuardRestore()
			return false, tbl17.Error
		end

		genv.__CHSAE_AFKGuardRestore = chsaeAFKGuardRestore

		local AntiAFKToggle = (function()
	local _t = {Value = tbl2.AntiAFK, _callbacks = {}}
	function _t:OnChanged(cb) self._callbacks[#self._callbacks+1] = cb end
	function _t:SetValue(val)
		self.Value = val
		tbl2.AntiAFK = val
		for _, cb in ipairs(self._callbacks) do pcall(cb, val) end
	end
	return _t
end)()

		AntiAFKToggle:OnChanged(function(antiAFK)
			tbl2.AntiAFK = antiAFK

			if antiAFK then
				local v22, v23 = fn61()

				if not v22 then
					lua:Notify("Anti-AFK unavailable: " .. tostring(v23), 8)
				end
			else
				chsaeAFKGuardRestore()
			end
		end)

		local chsaeConfigControllers = genv.__CHSAE_ConfigControllers

		if type(chsaeConfigControllers) == "table" then
			chsaeConfigControllers.AntiAFK = AntiAFKToggle
			chsaeConfigControllers.AntiAFKMethod = nil
		end

		local chsaeDebug2 = genv.__CHSAE_Debug

		if chsaeDebug2 then
			chsaeDebug2.TestAntiAFK = nil
			chsaeDebug2.GetAntiAFKPulses = nil

			chsaeDebug2.RefreshAntiAFKGuard = function()
				if not tbl2.AntiAFK then
					return false, "Enable Anti-AFK first"
				end

				if not chsaeAFKGuardRestore() then
					return false, tbl17.Error
				end
				return fn61()
			end

			chsaeDebug2.GetAntiAFKStatus = function()
				local ownedReenabledCount = 0
				local restorePending = 0

				for k in pairs(chsaeAFKNativeState.Disabled) do
					restorePending += 1

					pcall(function()
						if k.Enabled == true then
							ownedReenabledCount += 1
						end
					end)
				end

				local tbl18 = { NativeOn = 0, NativeOff = 0, LuaOn = 0, LuaOff = 0, GameOn = 0, GameOff = 0, Unknown = 0 }
				local getSignalCons = getconnections or genv.get_signal_cons

				local ok, result = pcall(function()
					assert(type(getSignalCons) == "function", "Idle listener inspection unavailable")
					local v22 = getSignalCons(localPlayer.Idled)
					assert(type(v22) == "table", "Idle listener inspection failed")

					for _, v23 in pairs(v22) do
						if not pcall(function()
							local luaConnection = v23.LuaConnection
							local enabled = v23.Enabled

							if type(luaConnection) ~= "boolean" or type(enabled) ~= "boolean" then
								tbl18.Unknown = tbl18.Unknown + 1
							else
								local str = (luaConnection and "Lua" or "Native") .. (enabled and "On" or "Off")
								tbl18[str] = tbl18[str] + 1

								if luaConnection and fn56(v23) then
									local str2 = enabled and "GameOn" or "GameOff"
									tbl18[str2] = tbl18[str2] + 1
								end
							end
						end) then
							tbl18.Unknown = tbl18.Unknown + 1
						end
					end
				end)

				local flag4 = fn53() and not tbl17.Error and ok and ownedReenabledCount == 0 and tbl18.NativeOn == 0 and tbl18.GameOn == 0 and tbl18.Unknown == 0 and (tbl18.NativeOff > 0 or tbl18.GameOff > 0)
				local controllersDisabled = 0

				for k in pairs(chsaeAFKNativeState.Controllers) do
					controllersDisabled += 1
				end

				local tbl19 = {
					Method = "Targeted game callback + native idle suppression",
					Enabled = tbl17.Enabled,
					SettingEnabled = tbl2.AntiAFK,
					RuntimeActive = flag4,
				}

				local protectionState = tbl17.Error and "ERROR"

				if not protectionState then
					protectionState = not tbl17.Enabled and "DISABLED"

					if not protectionState then
						if flag4 then
							protectionState = tbl18.NativeOff > 0 and "SUPPRESSION_ACTIVE" or "GAME_ONLY_NATIVE_UNVERIFIED"
						else
							protectionState = flag4
						end

						protectionState = protectionState or "UNVERIFIED"
					end
				end

				tbl19.ProtectionState = protectionState
				tbl19.NativeListenerObserved = ok and tbl18.NativeOn + tbl18.NativeOff > 0
				tbl19.Error = tbl17.Error
				tbl19.InspectionError = not ok and tostring(result) or nil
				tbl19.NativeDisabledCount = ok and tbl18.NativeOff or nil
				tbl19.LuaDisabledCount = ok and tbl18.LuaOff or nil
				tbl19.NativeEnabledCount = ok and tbl18.NativeOn or nil
				tbl19.LuaEnabledCount = ok and tbl18.LuaOn or nil
				tbl19.UnknownListenerCount = ok and tbl18.Unknown or nil
				tbl19.OwnedReenabledCount = ownedReenabledCount
				tbl19.RestorePending = restorePending
				tbl19.GameIdleDisabledCount = ok and tbl18.GameOff or nil
				tbl19.GameIdleEnabledCount = ok and tbl18.GameOn or nil
				tbl19.ControllerTouched = chsaeAFKNativeState.Removed > 0 or controllersDisabled > 0
				tbl19.ControllersRemoved = chsaeAFKNativeState.Removed
				tbl19.ControllersDisabled = controllersDisabled
				tbl19.LogPath = tbl17.LogPath
				tbl19.LogError = tbl17.LogError
				tbl19.HealthIntervalSeconds = 5
				tbl19.RejoinRequired = chsaeAFKNativeState.Removed > 0 or restorePending > 0
				tbl19.LastIdleSeconds = tbl17.LastIdleSeconds
				tbl19.IdleReports = tbl17.IdleReports
				tbl19.GameTimerGroup = tbl17.TimerGroup
				tbl19.GameTimerFound = tbl17.MarkActive ~= nil
				tbl19.EnduranceVerified = false
				tbl19.NativeVerified = false
				tbl19.SimulatedInput = false
				tbl19.SyntheticInput = false
				tbl19.Pulses = 0
				tbl19.InputFailures = 0
				tbl19.JobId = game.JobId
				return tbl19
			end
		end

		if tbl2.AntiAFK then
			fn61()
		else
			chsaeAFKGuardRestore()
		end
	end

	fn50()

	task.spawn(function()
		local function fn51(arg)
			return tostring(arg):match(":%s*(.*)$") or tostring(arg)
		end

		local function fn52(arg, arg2, arg3)
			return ("<font color=\"#E4E4E7\"><b>[%s]</b></font> <font color=\"%s\">%s</font>"):format(arg, arg3 or "#D4D4D8", tostring(arg2))
		end

		local function fn53()
			local owner = tbl14.owner or tbl14.treadmillTraining and "Treadmill" or "Idle"
			local chsaeCarryRequest = getgenv().__CHSAE_CarryRequest
			local flag4 = type(handlers.getDroppedRecoveryRecord) == "function" and handlers.getDroppedRecoveryRecord() or nil

			if flag4 then
				local magnitude = fn33()
				magnitude = magnitude and ((magnitude.Position - flag4.BottomCFrame.Position) * Vector3.new(1, 0, 1)).Magnitude or nil
				local str = type(chsaeCarryRequest) == "table" and chsaeCarryRequest.inFlight and " · request pending" or ""
				return ("%s · drop %s · %s%s"):format(owner, tostring(flag4.Uid):sub(1, 6), magnitude and ("%.0f studs"):format(magnitude) or "position syncing", str), "#FDE68A"
			end

			if type(chsaeCarryRequest) == "table" and chsaeCarryRequest.inFlight then
				return ("%s · carry request pending %.1fs"):format(owner, math.max(0, os.clock() - (tonumber(chsaeCarryRequest.started) or os.clock()))), "#FDE68A"
			end

			if critical then
				return owner .. " · carry verified", "#86EFAC"
			end
			local n2 = math.max(0, os.clock() - (tonumber(tbl13.requestFailureAt) or os.clock()))
			local flag5 = tbl13.lockedUid and n2 <= 8
			local flag6

			if flag5 then
				flag6 = tostring(tbl13.lastRequestKind or "") ~= ""
			else
				flag6 = flag5
			end

			if flag6 then
				local str = tostring(tbl13.lastRequestKind)
				local flag7 = str == "movement-retry"

				if flag7 then
					flag7 = tostring(tbl13.lastRequestError or "") ~= ""
				end

				if flag7 then
					str = tostring(tbl13.lastRequestError):gsub("[<>&\r\n]", " "):sub(1, 100)
				end

				return ("%s · retry %s · %.1fs"):format(owner, str, n2), "#FDE68A"
			end

			local candidateIndex = handlers.candidateIndex
			return ("%s · targets %d · scan %d"):format(owner, candidateIndex and #candidateIndex.entries or 0, candidateIndex and candidateIndex.version or 0), "#A1A1AA"
		end

		local v22

		while fn() do
			local ok, result = pcall(function()
				while fn() do
					if not (tbl2.ShowStatusOverlay and not tbl2.BlackScreen and not flag3) then
						handlers.statusWake.Event:Wait()
					else
						local v23, v24 = handlers.getSafetySummary()
						local v25 = tbl14.status()
						local v26 = fn51(handlers.steal)
						local v27 = fn51(handlers.target)
						local v28 = fn51(handlers.place)
						local v29 = fn51(handlers.stealTime)
						local str = v25:find("Idle", 1, true) and "#A1A1AA"
						local str2

						if str then
							str2 = str
						else
							str2 = v25:find("Waiting", 1, true) and "#FDE68A"
						end

						str2 = str2 or "#86EFAC"
						local str3 = (v26 == "Off" or v26:find("Waiting for target", 1, true)) and "#A1A1AA" or "#FDE68A"
						local str4 = v27 == "none" and "#A1A1AA" or "#FDE68A"
						local str5 = v28:find("full", 1, true) and "#FDBA74" or v28:find("Placed", 1, true) and "#86EFAC" or "#D4D4D8"
						local str6 = (tonumber(v24) or 0) > 0 and "#FCA5A5" or "#86EFAC"
						local tbl17 = { fn52("Activity", v25, str2) }
						local str7 = tostring(handlers.adminEventStatus or "Lab status unavailable"):gsub("^🌀%s*", ""):gsub("^🕒%s*", ""):gsub("^👑%s*", ""):gsub("^👾%s*", "")
						tbl17[#tbl17 + 1] = fn52("Event", str7, (str7:find("Rift live", 1, true) or str7:find("is live", 1, true)) and "#F9A8D4" or "#7DD3FC")

						if (tbl14.owner == "Steal" or tbl14.stealBusy()) and v26 ~= "Off" and not v26:find("Waiting for target", 1, true) then
							tbl17[#tbl17 + 1] = fn52("Steal", v26, str3)
						end

						if v27 ~= "none" then
							tbl17[#tbl17 + 1] = fn52("Target", v27, str4)
						end

						if handlers.stealTimer.active then
							tbl17[#tbl17 + 1] = fn52("Time", v29, "#7DD3FC")
						end

						if tbl2.AutoPlace or tbl2.AutoHatch or tbl14.owner == "Place" or tbl2.PlaceAfterIncubation and type(handlers.getIncubatedPlaceCount) == "function" and handlers.getIncubatedPlaceCount() > 0 then
							tbl17[#tbl17 + 1] = fn52("Pen", v28, str5)
						end

						tbl17[#tbl17 + 1] = fn52("Safety", fn51(v23), str6)
						local v30, v31 = fn53()
						tbl17[#tbl17 + 1] = fn52("Debug", v30, v31)
						local str8 = table.concat(tbl17, "\n")

						if str8 ~= v22 then
							v22 = str8

							pcall(function()
								v21:SetText(str8)
							end)
						end

						handlers.statusWake.Event:Wait()
					end
				end
			end)

			if not (ok or not fn()) then
				warn("[CloverHub-SAE][overlay] worker recovered: " .. tostring(result))
				task.wait(1)
				continue
			end

			break
		end
	end)

	task.defer(function()
		local ok, result = pcall(function()
			return tbl.LoadUI("addons/ThemeManager.lua")
		end)

		if not fn() then
			return
		end
		local v22 = settings_:AddGroupbox({ Side = "Right", Name = "🎨 Themes" })
		v3.__ThemesBox = v22
		local ok2

		if ok and type(result) == "table" then
			local v23 = result

			ok2, result = pcall(function()
				v23:SetLibrary(lua)
				v23:SetFolder("SAE")
				local tbl17 = {}

				for k in pairs(v23.BuiltInThemes) do
					tbl17[#tbl17 + 1] = k
				end

				table.sort(tbl17, function(arg, arg2)
					return v23.BuiltInThemes[arg][1] < v23.BuiltInThemes[arg2][1]
				end)

				local defaultTheme = v23:GetDefaultTheme()
				local str = v23.BuiltInThemes[defaultTheme] and defaultTheme or "Default"

				bindDropdownOverlay(v22, "ThemeManager_ThemeList", "Theme list", tbl17, {
					text = "Theme list",
					multi = false,
					get = function()
						return str
					end,
					set = function(arg)
						local v24 = v23.BuiltInThemes[arg]
						if not v24 then
							return
						end
						str = arg
						v23:ApplyThemeData(v24[2])
					end,
					onChange = function()
						local ok3, result2, result3 = pcall(v23.SaveDefault, v23, str)

						if not ok3 or not result2 then
							warn("[CloverHub-SAE] Theme save failed: " .. tostring(ok3 and result3 or result2))
							lua:Notify("Theme applied, but could not be saved.")
						end
					end,
				}):SetValue(str)

				lua.__ThemeManager = v23
			end)
		else
			ok2 = false
		end

		if not ok2 then
			warn("[CloverHub-SAE] ThemeManager unavailable: " .. tostring(result))
			v22:AddLabel("ThemesUnavailableLabel", { Text = "Themes are unavailable. Re-execute to retry.", DoesWrap = true })
		end

		pcall(styleGroupboxPanel, v22)

		if chk.CardifyBox then
			pcall(chk.CardifyBox, v22)
		end

		task.spawn(makeCollapsible, v22, true)
	end)

	task.defer(function()
		local ok, saveManager = pcall(function()
			return tbl.LoadUI("addons/SaveManager.lua")
		end)

		if ok and type(saveManager) == "table" then
			lua.__SaveManager = saveManager
		end

		local saveManager2 = lua.__SaveManager

		if type(saveManager2) == "table" then
			local ok2, configBox = pcall(function()
				saveManager2:SetLibrary(lua)
				saveManager2:IgnoreThemeSettings()
				saveManager2:SetFolder("SAE")
				saveManager2:SetSubFolder("StealAnEgg")

				saveManager2:SetIgnoreIndexes({
					"StallToggle",
					"ManualSpeedSlider",
					"ManualSpeedToggle",
					"ManualFlyToggle",
					"InfiniteJumpToggle",
					"EggTargetRarities",
					"EggTargetCategories",
					"EggTargetAreas",
					"EggTargetPriority",
					"EggTargetKGMode",
					"EggTargetKGThreshold",
					"EggTargetValueThreshold",
					"TrailShopDropdown",
					"PlaceCategories",
					"PlaceRarities",
					"PlaceMutations",
					"PlaceOrder",
					"MutateCategories",
					"MutateRarities",
					"MutateMutations",
					"MutateMinimumValue",
					"AutoMutateToggle",
					"HatchFracturedOnlyToggle",
					"AutoPetIndexToggle",
					"PetIndexAreas",
					"SellPets",
					"SellRarities",
					"SellMutations",
					"SellPetKGMode",
					"SellPetKGThreshold",
					"SellPetValueThreshold",
					"SellEggNames",
					"SellEggRarities",
					"SellEggMutations",
					"SellEggKGMode",
					"SellEggKGThreshold",
					"SellEggValueThreshold",
					"FindServerToggle",
					"AutoExecute",
					"FuseCategories",
					"FuseKGMode",
					"FuseKGThreshold",
					"FuseMinimumValue",
					"AutoFuseToggle",
					"LabMinimumValue",
					"PriorityEventToggle",
					"AutoLabToggle",
					"StealMovementTypeDropdown",
					"EnableDefaultSpeedToggle",
					"StealRagdollToggle",
					"BurstTweenToggle",
					"StealSpeedSlider",
					"StealSpeedInput",
					"SidewaysGlideToggle",
					"GuardProtectionToggle",
					"AntiTreadmillToggle",
					"EggESPAreas",
					"CloverConfigName",
					"CloverConfigList",
					"CloverConfigJSON",
					"WebhookURLInput",
					"AutoSellToggle",
					"AutoSellEggToggle",
					"SellPetsWhenFullToggle",
					"SellEggsWhenFullToggle",
				})

				local saveJSON = saveManager2.SaveJSON
				local loadJSON = saveManager2.LoadJSON

				local function fn51(arg)
					if type(arg) ~= "table" then
						tbl2.AutoFuse = false
						local v22 = tbl2
						local v23 = tbl2
						tbl2.AutoLab = false
						v22.PriorityEvent = false
						v23.LabMinimumValue = 0
						tbl2.SellPetValueThreshold = 0
						tbl2.SellEggValueThreshold = 0
						tbl2.AutoSell = false
						tbl2.SellPetsWhenFull = false
						tbl2.AutoSellEggs = false
						tbl2.SellEggsWhenFull = false
						return true, true
					end

					local v22, v23 = tbl3.apply(arg, true)

					if v22 or v23 then
						pcall(function()
							lua:Notify("Invalid seller Minimum Value was rejected; selling stays off.", 5)
						end)
					end

					return v22, v23
				end

				local function fn52()
					local v22 = pairs
					local chsaeConfigControllers = nil

					for k, chsaeConfigController in v22(chsaeConfigControllers) do
						local v23 = tbl2[k]

						if v23 ~= nil and type(chsaeConfigController) == "table" and type(chsaeConfigController.SetValue) == "function" then
							if type(v23) == "table" then
								local tbl17 = {}

								for k2, v24 in pairs(v23) do
									if v24 then
										tbl17[k2] = true
									end
								end

								pcall(chsaeConfigController.SetValue, chsaeConfigController, tbl17)
							else
								pcall(chsaeConfigController.SetValue, chsaeConfigController, v23)
							end
						end
					end
				end

				saveManager2.SaveJSON = function(arg, arg2)
					local v22, v23, v24 = saveJSON(arg, arg2)
					if not v23 then
						return v22, v23, v24
					end
					local ok2, result = pcall(HttpService.JSONDecode, HttpService, v22)
					if not (ok2 and type(result) == "table") then
						return "", false, "Failed to attach CloverHub settings"
					end

					if type(result.objects) == "table" then
						local objects = {}

						for _, object in ipairs(result.objects) do
							if type(object) ~= "table" or object.idx ~= "WebhookURLInput" then
								objects[#objects + 1] = object
							end
						end

						result.objects = objects
					end

					local v25 = fn9(false)
					local cloverSettingsSchema = {}

					for k in pairs(v25) do
						cloverSettingsSchema[#cloverSettingsSchema + 1] = k
					end

					table.sort(cloverSettingsSchema)
					result.cloverSettings = v25
					result.cloverSettingsSchema = cloverSettingsSchema
					result.cloverSettingsRevision = tbl2.ConfigRevision
					local ok3, result2 = pcall(HttpService.JSONEncode, HttpService, result)
					if not ok3 then
						return "", false, "Failed to encode CloverHub settings"
					end
					return result2, true
				end

				saveManager2.LoadJSON = function(arg, arg2)
					handlers.valueFilterLoadInProgress = true
					handlers.markValueFilterChanged()
					local ok2, result = pcall(HttpService.JSONDecode, HttpService, arg2)
					ok2 = ok2 and type(result) == "table"
					local flag4 = false
					local flag5 = false

					if ok2 then
						flag5, flag4 = fn51(result.cloverSettings)

						if type(result.objects) == "table" then
							local objects = {}

							local tbl17 = {
								AntiAFKMethodDropdown = true,
								FastTPCycleToggle = true,
								AutoHungryMonsterToggle = true,
								HungryMonsterPriority = true,
								HungryMonsterProtectedCategories = true,
								HungryMonsterProtectedRarities = true,
								AutoOpenChestToggle = true,
								AutoSkipChestToggle = true,
								FindServerToggle = true,
								FuseCategories = true,
								FuseKGMode = true,
								FuseKGThreshold = true,
								FuseMinimumValue = true,
								AutoFuseToggle = true,
								AntiTreadmillToggle = true,
								AutoLabToggle = true,
								LabRotations = true,
								MutateCategories = true,
								MutateRarities = true,
								MutateMutations = true,
								AutoMutateToggle = true,
								HatchFracturedOnlyToggle = true,
								AutoPetIndexToggle = true,
								PetIndexAreas = true,
								PriorityEventToggle = true,
								LabMinimumValue = true,
								StealMovementBackendDropdown = true,
								StealMovementTypeDropdown = true,
								EnableDefaultSpeedToggle = true,
								StealRagdollToggle = true,
								BurstTweenToggle = true,
								StealSpeedSlider = true,
								StealSpeedInput = true,
								StealWallSpacingDropdown = true,
								DevChickenTweenToggle = true,
								InstantStealToggle = true,
								AutoSellToggle = true,
								AutoSellEggToggle = true,
								SellPetsWhenFullToggle = true,
								SellEggsWhenFullToggle = true,
							}

							for _, object in ipairs(result.objects) do
								if type(object) ~= "table" or object.idx ~= "WebhookURLInput" and tbl17[object.idx] ~= true then
									objects[#objects + 1] = object
								end
							end

							result.objects = objects
						end

						result.cloverSettings = fn9(false)
						result.cloverSettingsSchema = nil
						local ok3, result2 = pcall(HttpService.JSONEncode, HttpService, result)

						if ok3 then
							arg2 = result2
						end
					end

					local ok3, result2, result3 = pcall(loadJSON, arg, arg2)
					local flag6 = ok3 and result2 == true

					if flag5 then
						tbl2.AutoSell = false
						tbl2.SellPetsWhenFull = false
					end

					if flag4 then
						tbl2.AutoSellEggs = false
						tbl2.SellEggsWhenFull = false
					end

					if not flag6 then
						tbl2.AutoSell = false
						tbl2.SellPetsWhenFull = false
						tbl2.AutoSellEggs = false
						tbl2.SellEggsWhenFull = false
					end

					task.defer(function()
						task.wait()
						pcall(fn52)
						pcall(fn10, true)
						handlers.valueFilterLoadInProgress = false
						handlers.markValueFilterChanged()
					end)

					if not ok3 then
						return false, result2
					end
					return result2, result3
				end

				local v22 = settings_:AddGroupbox({ Side = "Left", Name = "💾 Config" })
				local CloverConfigName = v22:AddInput("CloverConfigName", { Text = "Name", Placeholder = "My config", Finished = false, Tooltip = "Name a new config." })
				local v23 = nil
				local cloverConfigList = nil
				local CloverConfigAutoload = nil

				local function fn53()
					local autoloadConfig = saveManager2:GetAutoloadConfig()

					pcall(function()
						CloverConfigAutoload:SetText("⭐ Autoload: " .. tostring(autoloadConfig or "none"))
					end)
				end

				local function fn54(arg)
					local v24 = saveManager2:RefreshConfigList()

					table.sort(v24, function(arg2, arg3)
						return string.lower(tostring(arg2)) < string.lower(tostring(arg3))
					end)

					if cloverConfigList then
						cloverConfigList:SetItems(v24, arg == true)
					end

					fn53()
					return v24
				end

				cloverConfigList = bindDropdownOverlay

				cloverConfigList = cloverConfigList(v22, "CloverConfigList", "Configs", saveManager2:RefreshConfigList(), {
					multi = false,
					text = "Configs",
					tooltip = "Choose a saved config.",
					get = function()
						return v23
					end,
					set = function(arg)
						v23 = arg
					end,
					onOpen = function()
						fn54(true)
					end,
				})

				local function fn55()
					if type(v23) ~= "string" or v23 == "" then
						lua:Notify("Choose a config first.", 3)
						return nil
					end
					return v23
				end

				local function fn56()
					local match = tostring(CloverConfigName.Value or ""):match("^%s*(.-)%s*$")
					if match == "" or string.lower(match) == "autoload" then
						lua:Notify("Enter a valid config name.", 3)
						return nil
					end
					return match
				end

				local function fn57(arg, arg2, arg3, arg4)
					if arg3 then
						lua:Notify(("✅ %s: %s"):format(arg, tostring(arg2 or "config")), 3)
					else
						lua:Notify(("❌ %s: %s"):format(arg, tostring(arg4 or "failed")), 4)
					end
				end

				local function fn58(arg, arg2, arg3, arg4, arg5, arg6)
					v3:AddDialog(arg, {
						Title = arg2,
						Description = arg3,
						AutoDismiss = false,
						FooterButtons = {
							Cancel = {
								Title = "Cancel",
								Variant = "Ghost",
								Order = 1,
								Callback = function(arg7)
									arg7:Dismiss()
								end,
							},
							Confirm = {
								Title = arg4,
								Variant = arg5 and "Destructive" or "Primary",
								Order = 2,
								Callback = function(arg7)
									arg7:Dismiss()
									arg6()
								end,
							},
						},
					})
				end

				local function fn59(arg, arg2)
					local v24, v25 = saveManager2:Save(arg)
					fn57(arg2 or "Saved", arg, v24, v25)

					if v24 then
						v23 = arg
						fn54(false)
						cloverConfigList:SetValue(arg)
					end
				end

				makeButtonPanel(v22, "CloverConfigCreateButtons", {
					{
						"+ Create Config",
						function()
							local v24 = fn56()
							if not v24 then
								return
							end

							if table.find(saveManager2:RefreshConfigList(), v24) ~= nil then
								fn58("CloverConfigCreateDialog", "Config exists", ("Overwrite %q with your current settings?"):format(v24), "Overwrite", true, function()
									fn59(v24, "Overwritten")
								end)
							else
								fn59(v24, "Created")
							end
						end,
					},
				})

				makeButtonPanel(v22, "CloverConfigManageButtons", {
					{
						"📂 Load Config",
						function()
							local v24 = fn55()
							if not v24 then
								return
							end

							fn58("CloverConfigLoadDialog", "Load config", ("Load %q and replace the current settings?"):format(v24), "Load", false, function()
								local v25, v26 = saveManager2:Load(v24)
								fn57("Loaded", v24, v25, v26)
							end)
						end,
					},
					{
						"💾 Overwrite Config",
						function()
							local v24 = fn55()
							if not v24 then
								return
							end

							fn58("CloverConfigOverwriteDialog", "Overwrite config", ("Replace %q with the current settings?"):format(v24), "Overwrite", true, function()
								fn59(v24, "Overwritten")
							end)
						end,
					},
					{
						"🗑 Delete Config",
						function()
							local v24 = fn55()
							if not v24 then
								return
							end

							fn58("CloverConfigDeleteDialog", "Delete config", ("Delete %q? This cannot be undone."):format(v24), "Delete", true, function()
								local v25, v26 = saveManager2:Delete(v24)
								fn57("Deleted", v24, v25, v26)

								if v25 then
									v23 = nil
									fn54(false)
								end
							end)
						end,
					},
					{
						"🔄 Refresh Configs",
						function()
							fn54(true)
						end,
					},
				})

				makeButtonPanel(v22, "CloverConfigAutoloadButtons", {
					{
						"⭐ Set Autoload",
						function()
							local v24 = fn55()
							if not v24 then
								return
							end
							local v25, v26 = saveManager2:SaveAutoloadConfig(v24)
							fn57("Autoload", v24, v25, v26)
							fn53()
						end,
					},
					{
						"🗑 Clear Autoload",
						function()
							fn58("CloverConfigClearAutoloadDialog", "Clear autoload", "Stop loading a named config on startup?", "Clear", true, function()
								local flag4, v24 = saveManager2:DeleteAutoLoadConfig()

								if not flag4 and tostring(v24):find("not set", 1, true) then
									flag4 = true
								end

								fn57("Autoload cleared", nil, flag4, v24)
								fn53()
							end)
						end,
					},
				})

				CloverConfigAutoload = v22:AddLabel("CloverConfigAutoload", { Text = "⭐ Autoload: none", DoesWrap = true })

				local CloverConfigJSON = v22:AddInput("CloverConfigJSON", {
					Text = "Config JSON",
					Placeholder = "Exported JSON appears here",
					Finished = false,
					Tooltip = "Paste JSON to import or export.",
				})

				makeButtonPanel(v22, "CloverConfigJSONButtons", {
					{
						"📥 Import JSON",
						function()
							local str = tostring(CloverConfigJSON.Value or "")
							if str:match("^%s*$") then
								lua:Notify("Paste config JSON first.", 3)
								return
							end

							fn58("CloverConfigImportDialog", "Import config", "Apply the JSON and replace the current settings?", "Import", false, function()
								local v24, v25 = saveManager2:LoadJSON(str)
								fn57("Imported", "JSON", v24, v25)
							end)
						end,
					},
					{
						"📤 Export JSON",
						function()
							local v24, v25, v26 = saveManager2:SaveJSON()
							if not v25 then
								fn57("Export", nil, false, v26)
								return
							end
							CloverConfigJSON:SetValue(v24)
							lua:Notify("✅ Config JSON is ready.", 3)
						end,
					},
					{
						"📋 Copy JSON",
						function()
							local str = tostring(CloverConfigJSON.Value or "")
							if str:match("^%s*$") then
								lua:Notify("Export JSON first.", 3)
								return
							end

							if type(setclipboard) ~= "function" then
								lua:Notify("Clipboard is unavailable.", 3)
								return
							end
							lua:Notify(pcall(setclipboard, str) and "✅ Config JSON copied." or "❌ Copy failed.", 3)
						end,
					},
				})

				fn54(false)

				task.defer(function()
					if fn() then
						saveManager2:LoadAutoloadConfig()
					end
				end)

				return v22
			end)

			if ok2 then
				v3.__ConfigBox = configBox
			end
		end

		if not v3.__ConfigBox then
			v3.__ConfigBox = settings_:AddGroupbox({ Side = "Left", Name = "💾 Config" })
			v3.__ConfigBox:AddLabel("ConfigUnavailableLabel", { Text = "Named configs are unavailable.\nSafe autosave is still active.", DoesWrap = true })
		end

		pcall(styleGroupboxPanel, v3.__ConfigBox)

		if chk.CardifyBox then
			pcall(chk.CardifyBox, v3.__ConfigBox)
		end

		task.spawn(makeCollapsible, v3.__ConfigBox, true)
	end)

	pcall(function()
		v2.StyleBoxes({
			v5,
			v6,
			v7,
			v8,
			v9,
			v3.__ProtectionBox,
			v14,
			v3.__MutateBox,
			v3.__AdminAbuseBox,
			v11,
			v15,
			v12,
			v13,
			v3.__PetIndexBox,
			v16,
			v17,
			v3.__FuseBox,
			v3.__ServerControlsBox,
			v3.__ServerResultsBox,
			v4,
			v3.__EventShopBox,
			v3.__ScrambleBossBox,
			v3.__WebhookBox,
			v3.__WebhookAlertsBox,
			v18,
			v19,
			v3.__ESPBox,
			v20,
			v3.__ConfigBox,
		})

		local cardifyBox = v2.CardifyBox
		v2.Polish()
	end)

	local function fn51(arg, arg2)
		if not arg then
			return
		end
		task.spawn(makeCollapsible, arg, arg2)
	end

	fn51(v5, false)
	fn51(v6, false)
	fn51(v7, false)
	fn51(v8, false)
	fn51(v9, false)
	fn51(v3.__ProtectionBox, false)
	fn51(v3.__AdminAbuseBox, false)
	fn51(v14, true)
	fn51(v3.__MutateBox, true)
	fn51(v11, true)
	fn51(v15, true)
	fn51(v12, true)
	fn51(v13, true)
	fn51(v3.__PetIndexBox, true)
	fn51(v16, true)
	fn51(v17, true)
	fn51(v4, true)
	fn51(v3.__EventShopBox, true)
	fn51(v3.__ScrambleBossBox, true)
	fn51(v3.__WebhookBox, true)
	fn51(v3.__WebhookAlertsBox, true)
	fn51(v18, true)
	fn51(v19, true)
	fn51(v3.__ESPBox, true)
	fn51(v20, true)
	fn51(v3.__ConfigBox, true)
end

getgenv().__CHSAE_AutoExecute.loading = false
task.defer(handlers.DevChickenTween.prime)
print("[SAE] Loaded for " .. localPlayer.Name)
