-------------------------------------------------
-- ValorWorgen
-- Global: ValorAddons[] ValorWorgenForm
-------------------------------------------------
local _G = _G
local addonName, _ = ...
if not select(2, _G.UnitRace("player")) == "Worgen" then return end
if not _G.ValorAddons then _G.ValorAddons = {} end
_G.ValorAddons[addonName] = true
_G.ValorWorgenForm = false

-- Local Variables
-------------------------------------------------
local playerModel = _G.CreateFrame("PlayerModel")
local macroCond = "[nocombat,nomounted,novehicleui,noform]"
local macroText = "/cast "..macroCond.." ".._G.GetSpellInfo(68996).."\n/run ClearOverrideBindings(ValorWorgenButton)"
local modelId = { [307454] = "w", [307453] = "w", }		-- Male/Female Worgen
local GetBindingKey, ClearOverrideBindings, SetOverrideBindingClick, InCombatLockdown, SecureCmdOptionParse
	= _G.GetBindingKey, _G.ClearOverrideBindings, _G.SetOverrideBindingClick, _G.InCombatLockdown, _G.SecureCmdOptionParse

-- setupKeyBinding( frame )
-------------------------------------------------
local function setupKeyBinding(f)
	ClearOverrideBindings(f)
	local k1, k2 = GetBindingKey("TOGGLESHEATH")
	if k1 then SetOverrideBindingClick(f, false, k1, f:GetName()) end
	if k2 then SetOverrideBindingClick(f, false, k2, f:GetName()) end
end

-- Where the magic happens...
-------------------------------------------------
local vwButton = _G.CreateFrame("Button", "ValorWorgenButton", nil, "SecureActionButtonTemplate")
vwButton:SetAttribute("type", "macro")
vwButton:RegisterEvent("UNIT_MODEL_CHANGED")
vwButton:RegisterEvent("UNIT_AURA")
vwButton:RegisterEvent("PLAYER_REGEN_ENABLED")
vwButton:RegisterEvent("PLAYER_ENTERING_WORLD")
vwButton:RegisterForClicks("AnyDown")
vwButton:SetScript("OnEvent",
	function(self, event, ...)
		-- Model Trigger: Determine Current Form
		if event == "UNIT_MODEL_CHANGED" and ... == "player" then
			playerModel:SetUnit("player")
			local m = playerModel:GetModelFileID()
			if m then
				_G.ValorWorgenForm = modelId[m] and true or false
				if not InCombatLockdown() then
					if _G.ValorWorgenForm and SecureCmdOptionParse(macroCond) then
						setupKeyBinding(self)			-- Is Worgen, Can Transform; Set KeyBind
						self:SetAttribute("macrotext", macroText)
					else
						ClearOverrideBindings(self)		-- Not Worgen or Can't Transform; Unset
						self:SetAttribute("macrotext", "")
					end
				end
			end
		elseif not InCombatLockdown() and _G.ValorWorgenForm and SecureCmdOptionParse(macroCond) then
			setupKeyBinding(self)			-- Event Trigger: Is Worgen, Can Transform; Set KeyBind
			self:SetAttribute("macrotext", macroText)
		elseif not InCombatLockdown() then
			ClearOverrideBindings(self)		-- Event Trigger: Not Worgen or Can't Transform; Unset
			self:SetAttribute("macrotext", "")
		end
	end
)