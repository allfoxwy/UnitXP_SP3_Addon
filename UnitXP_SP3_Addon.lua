--[[
    UnitXP Service Pack 3 Lua Addon

    By allfox, and the thankful community
]] --
UnitXP_SP3_Addon = nil; -- It's a SavedVariable, not local
UnitXP_SP3_Icon = nil; -- It's a SavedVariable, not local

-- Commands
SLASH_UNITXP1 = "/unitxp";
SlashCmdList["UNITXP"] = function()
    if xpsp3Frame:IsShown() then
        PlaySound("igMainMenuContinue");
        xpsp3Frame:Hide();
    else
        PlaySound("igMainMenuOpen");
        xpsp3Frame:Show();
    end
end

-- Strings
BINDING_HEADER_UNITXPSP3TARGETING = "UnitXP SP3 Targeting Functions";
BINDING_NAME_UNITXPSP3NEARESTENEMY = "Nearest Enemy";
BINDING_NAME_UNITXPSP3WORLDBOSS = "World Boss";
BINDING_NAME_UNITXPSP3NEXTMARKER = "Next Target Marker";
BINDING_NAME_UNITXPSP3PREVIOUSMARKER = "Previous Target Marker";
BINDING_NAME_UNITXPSP3NEXTENEMY = "Next Enemy";
BINDING_NAME_UNITXPSP3PREVIOUSENEMY = "Previous Enemy";
BINDING_NAME_UNITXPSP3NEXTMELEE = "Next Enemy Prioritizing Melee";
BINDING_NAME_UNITXPSP3PREVIOUSMELEE = "Previous Enemy Prioritizing Melee";
BINDING_HEADER_UNITXPSP3UTILITIES = "UnitXP SP3 Utilities";
BINDING_NAME_UNITXPSP3RAISECAMERA = "Raise Camera";
BINDING_NAME_UNITXPSP3LOWERCAMERA = "Lower Camera";
BINDING_NAME_UNITXPSP3TOGGLEMODERNNAMEPLATEDISTANCE = "Toggle Proper Nameplates Behavior";
BINDING_NAME_UNITXPSP3TOGGLEPRIORITIZETARGETNAMEPLATE = "Toggle Prioritize Target Nameplate";
BINDING_NAME_UNITXPSP3TOGGLEPRIORITIZEMARKEDNAMEPLATE = "Toggle Prioritize Marked Nameplate";
local UNITXPSP3TOOLTIP = "UnitXP SP3 is running"

local libIcon = LibStub("LibDBIcon-1.0");
local libData = LibStub("LibDataBroker-1.1");

local function UnitXP_SP3_Print(msg)
    if (not DEFAULT_CHAT_FRAME) then
        return;
    end
    DEFAULT_CHAT_FRAME:AddMessage(tostring(msg));
end

function UnitXP_SP3_OnLoad()
    xpsp3Frame:RegisterEvent("ADDON_LOADED");
end

local function UnitXP_SP3_flashTaskbarIcon()
    return UnitXP("notify", "taskbarIcon");
end

local function UnitXP_SP3_FPScap(cap)
    UnitXP_SP3_Addon["FPScap"] = UnitXP("FPScap", cap);
    return UnitXP_SP3_Addon["FPScap"];
end

local function UnitXP_SP3_playSystemDefaultSound()
    return UnitXP("notify", "systemSound", "SystemDefault");
end

local function UnitXP_SP3_setTargetingRangeConeFactor(factor)
    UnitXP_SP3_Addon["targetingRangeConeFactor"] = UnitXP("target", "rangeCone", factor);
    return UnitXP_SP3_Addon["targetingRangeConeFactor"];
end

local function UnitXP_SP3_setModernNameplateDistance(enable)
    return UnitXP("modernNameplateDistance", enable);
end

local function UnitXP_SP3_setPrioritizeTargetNameplate(enable)
    return UnitXP("prioritizeTargetNameplate", enable);
end

local function UnitXP_SP3_setPrioritizeMarkedNameplate(enable)
    return UnitXP("prioritizeMarkedNameplate", enable);
end

local function UnitXP_SP3_setNameplateCombatFilter(enable)
    return UnitXP("nameplateCombatFilter", enable);
end

local function UnitXP_SP3_setShowInCombatNameplatesNearPlayer(enable)
    return UnitXP("showInCombatNameplatesNearPlayer", enable);
end

local function UnitXP_SP3_setCameraHeight(value)
    UnitXP_SP3_Addon["cameraHeight"] = UnitXP("cameraVerticalDisplacement", "set", value);

    return UnitXP_SP3_Addon["cameraHeight"];
end

local function UnitXP_SP3_setCameraHorizontalDisplacement(value)
    UnitXP_SP3_Addon["cameraHorizontalDisplacement"] = UnitXP("cameraHorizontalDisplacement", "set", value);

    return UnitXP_SP3_Addon["cameraHorizontalDisplacement"];
end

function UnitXP_SP3_resetCamera()
    UnitXP_SP3_setCameraHorizontalDisplacement(0);
    UnitXP_SP3_setCameraHeight(0);
    return 0;
end

function UnitXP_SP3_leftPlayer()
    return UnitXP_SP3_setCameraHorizontalDisplacement(UnitXP_SP3_Addon["cameraHorizontalDisplacement"] + 0.5);
end

function UnitXP_SP3_rightPlayer()
    return UnitXP_SP3_setCameraHorizontalDisplacement(UnitXP_SP3_Addon["cameraHorizontalDisplacement"] - 0.5);
end

function UnitXP_SP3_raiseCameraHeight()
    return UnitXP_SP3_setCameraHeight(UnitXP_SP3_Addon["cameraHeight"] + 0.2);
end

function UnitXP_SP3_lowerCameraHeight()
    return UnitXP_SP3_setCameraHeight(UnitXP_SP3_Addon["cameraHeight"] - 0.2);
end

local function UnitXP_SP3_reloadConfig()
    UnitXP_SP3_FPScap(UnitXP_SP3_Addon["FPScap"]);
    xpsp3_editBox_FPScap:SetNumber(UnitXP_SP3_Addon["FPScap"]);

    UnitXP_SP3_setTargetingRangeConeFactor(UnitXP_SP3_Addon["targetingRangeConeFactor"]);

    UnitXP_SP3_setCameraHeight(UnitXP_SP3_Addon["cameraHeight"]);
    UnitXP_SP3_setCameraHorizontalDisplacement(UnitXP_SP3_Addon["cameraHorizontalDisplacement"]);

    if UnitXP_SP3_Icon.hide then
        xpsp3_checkButton_minimapButton:SetChecked(false);
    else
        xpsp3_checkButton_minimapButton:SetChecked(true);
    end

    if (UnitXP_SP3_Addon["modernNameplateDistance"]) then
        UnitXP_SP3_setModernNameplateDistance("enable");
        xpsp3_checkButton_modernNameplate:SetChecked(true);
    else
        UnitXP_SP3_setModernNameplateDistance("disable");
        xpsp3_checkButton_modernNameplate:SetChecked(false);
    end

    if (UnitXP_SP3_Addon["prioritizeTargetNameplate"]) then
        UnitXP_SP3_setPrioritizeTargetNameplate("enable");
        xpsp3_checkButton_prioritizeTargetNameplate:SetChecked(true);
    else
        UnitXP_SP3_setPrioritizeTargetNameplate("disable");
        xpsp3_checkButton_prioritizeTargetNameplate:SetChecked(false);
    end

    if (UnitXP_SP3_Addon["prioritizeMarkedNameplate"]) then
        UnitXP_SP3_setPrioritizeMarkedNameplate("enable");
        xpsp3_checkButton_prioritizeMarkedNameplate:SetChecked(true);
    else
        UnitXP_SP3_setPrioritizeMarkedNameplate("disable");
        xpsp3_checkButton_prioritizeMarkedNameplate:SetChecked(false);
    end

    if (UnitXP_SP3_Addon["nameplateCombatFilter"]) then
        UnitXP_SP3_setNameplateCombatFilter("enable");
        xpsp3_checkButton_nameplateCombatFilter:SetChecked(true);
    else
        UnitXP_SP3_setNameplateCombatFilter("disable");
        xpsp3_checkButton_nameplateCombatFilter:SetChecked(false);
    end

    if (UnitXP_SP3_Addon["showInCombatNameplatesNearPlayer"]) then
        UnitXP_SP3_setShowInCombatNameplatesNearPlayer("enable");
        xpsp3_checkButton_showInCombatNameplatesNearPlayer:SetChecked(true);
    else
        UnitXP_SP3_setShowInCombatNameplatesNearPlayer("disable");
        xpsp3_checkButton_showInCombatNameplatesNearPlayer:SetChecked(false);
    end

    for ev, v in pairs(UnitXP_SP3_Addon["notify_flashTaskbarIcon"]) do
        xpsp3Frame:UnregisterEvent(ev);
    end
    for ev, v in pairs(UnitXP_SP3_Addon["notify_playSystemDefaultSound"]) do
        xpsp3Frame:UnregisterEvent(ev);
    end

    for ev, v in pairs(UnitXP_SP3_Addon["notify_flashTaskbarIcon"]) do
        if (v == true) then
            xpsp3Frame:RegisterEvent(ev);
            xpsp3_checkButton_notify_flashTaskbarIcon:SetChecked(true);
        else
            xpsp3_checkButton_notify_flashTaskbarIcon:SetChecked(false);
        end
    end
    for ev, v in pairs(UnitXP_SP3_Addon["notify_playSystemDefaultSound"]) do
        if (v == true) then
            xpsp3Frame:RegisterEvent(ev);
            xpsp3_checkButton_notify_playSystemDefaultSound:SetChecked(true);
        else
            xpsp3_checkButton_notify_playSystemDefaultSound:SetChecked(false);
        end
    end

end

function UnitXP_SP3_UI_OnClick(widget)
    if (widget == nil or string.find(widget:GetName(), "xpsp3") == nil) then
        return
    end

    xpsp3_editBox_FPScap:ClearFocus();

    if (string.find(widget:GetName(), "_editBox_")) then
        PlaySound("igMainMenuContinue");
        if (string.find(widget:GetName(), "_FPScap")) then
            UnitXP_SP3_FPScap(widget:GetNumber());
        end
    end

    if (string.find(widget:GetName(), "_button_")) then
        PlaySound("igMainMenuContinue");
        if (string.find(widget:GetName(), "_cameraHeight_raise")) then
            UnitXP_SP3_raiseCameraHeight();
        end
        if (string.find(widget:GetName(), "_cameraHeight_lower")) then
            UnitXP_SP3_lowerCameraHeight();
        end
        if (string.find(widget:GetName(), "_cameraHorizontalDisplacement_leftPlayer")) then
            UnitXP_SP3_leftPlayer();
        end
        if (string.find(widget:GetName(), "_cameraHorizontalDisplacement_rightPlayer")) then
            UnitXP_SP3_rightPlayer();
        end
    end

    if (string.find(widget:GetName(), "_buttonCancel_")) then
        PlaySound("gsTitleOptionExit");
        if (string.find(widget:GetName(), "_close")) then
            xpsp3Frame:Hide();
        end
        if (string.find(widget:GetName(), "_resetCamera")) then
            UnitXP_SP3_resetCamera();
        end
    end

    if (string.find(widget:GetName(), "_checkButton_")) then
        if (widget:GetChecked()) then
            PlaySound("igMainMenuOptionCheckBoxOn");
        else
            PlaySound("igMainMenuOptionCheckBoxOff");
        end

        if (string.find(widget:GetName(), "_minimapButton")) then
            UnitXP_SP3_Icon.hide = not widget:GetChecked();
            libIcon:Refresh("UnitXP SP3 icon", UnitXP_SP3_Icon);
        end

        if (string.find(widget:GetName(), "_modernNameplate")) then
            if (widget:GetChecked()) then
                UnitXP_SP3_Addon["modernNameplateDistance"] = true;
            else
                UnitXP_SP3_Addon["modernNameplateDistance"] = false;
            end
        end

        if (string.find(widget:GetName(), "_prioritizeTargetNameplate")) then
            if (widget:GetChecked()) then
                UnitXP_SP3_Addon["prioritizeTargetNameplate"] = true;
            else
                UnitXP_SP3_Addon["prioritizeTargetNameplate"] = false;
            end
        end

        if (string.find(widget:GetName(), "_prioritizeMarkedNameplate")) then
            if (widget:GetChecked()) then
                UnitXP_SP3_Addon["prioritizeMarkedNameplate"] = true;
            else
                UnitXP_SP3_Addon["prioritizeMarkedNameplate"] = false;
            end
        end

        if (string.find(widget:GetName(), "_nameplateCombatFilter")) then
            if (widget:GetChecked()) then
                UnitXP_SP3_Addon["nameplateCombatFilter"] = true;
            else
                UnitXP_SP3_Addon["nameplateCombatFilter"] = false;
            end
        end

        if (string.find(widget:GetName(), "_showInCombatNameplatesNearPlayer")) then
            if (widget:GetChecked()) then
                UnitXP_SP3_Addon["showInCombatNameplatesNearPlayer"] = true;
            else
                UnitXP_SP3_Addon["showInCombatNameplatesNearPlayer"] = false;
            end
        end

        if (string.find(widget:GetName(), "_notify_flashTaskbarIcon")) then
            for ev, v in pairs(UnitXP_SP3_Addon["notify_flashTaskbarIcon"]) do
                if (widget:GetChecked()) then
                    UnitXP_SP3_Addon["notify_flashTaskbarIcon"][ev] = true;
                else
                    UnitXP_SP3_Addon["notify_flashTaskbarIcon"][ev] = false;
                end
            end
        end

        if (string.find(widget:GetName(), "_notify_playSystemDefaultSound")) then
            for ev, v in pairs(UnitXP_SP3_Addon["notify_playSystemDefaultSound"]) do
                if (widget:GetChecked()) then
                    UnitXP_SP3_Addon["notify_playSystemDefaultSound"][ev] = true;
                else
                    UnitXP_SP3_Addon["notify_playSystemDefaultSound"][ev] = false;
                end
            end
        end
    end

    UnitXP_SP3_reloadConfig();
end

function UnitXP_SP3_toggleModernNameplateDistance()
    UnitXP_SP3_Addon["modernNameplateDistance"] = not UnitXP_SP3_Addon["modernNameplateDistance"];
    UnitXP_SP3_reloadConfig();
end

function UnitXP_SP3_togglePrioritizeTargetNameplate()
    UnitXP_SP3_Addon["prioritizeTargetNameplate"] = not UnitXP_SP3_Addon["prioritizeTargetNameplate"];
    UnitXP_SP3_reloadConfig();
end

function UnitXP_SP3_togglePrioritizeMarkedNameplate()
    UnitXP_SP3_Addon["prioritizeMarkedNameplate"] = not UnitXP_SP3_Addon["prioritizeMarkedNameplate"];
    UnitXP_SP3_reloadConfig();
end

-- Recording party members from previous PARTY_MEMBERS_CHANGED events so that we can verify if the party just became full
local lastRecordedPartyMembers = 0

local function checkEvent(listenedEvents, actionFunction)
    if listenedEvents[event] then
        if (event == "PARTY_MEMBERS_CHANGED") then
            -- Party full
            if (GetNumRaidMembers() == 0 and GetNumPartyMembers() == 4 and lastRecordedPartyMembers ~= 4) then
                actionFunction();
            end
        elseif (event == "UPDATE_BATTLEFIELD_STATUS") then
            for i = 1, MAX_BATTLEFIELD_QUEUES do
                local s = GetBattlefieldStatus(i);
                -- Battlefield is ready
                if (s == "confirm") then
                    actionFunction();
                    break
                end
            end
        elseif (event == "CHAT_MSG_ADDON") then
            if (LFT_ADDON_PREFIX ~= nil and arg1 == LFT_ADDON_PREFIX) then
                if (string.find(arg2, "S2C_OFFER_NEW") or string.find(arg2, "S2C_ROLECHECK_START") or
                    string.find(arg2, "S2C_QUEUE_LEFT")) then
                    -- LFT found group or role check start or somehow player left queue
                    actionFunction();
                end
            end
        else
            actionFunction();
        end
    end
end

function UnitXP_SP3_OnEvent(event)
    if (event == "ADDON_LOADED" and arg1 == "UnitXP_SP3_Addon") then
        local dataVersion = 22;
        if (UnitXP_SP3_Addon == nil or UnitXP_SP3_Addon["dataVersion"] ~= dataVersion) then
            UnitXP_SP3_Addon = {};
            UnitXP_SP3_Addon["dataVersion"] = dataVersion;
            UnitXP_SP3_Addon["targetRangeConeFactor"] = 2.2;
            UnitXP_SP3_Addon["cameraHeight"] = 0.0;
            UnitXP_SP3_Addon["cameraHorizontalDisplacement"] = 0.0;
            UnitXP_SP3_Addon["modernNameplateDistance"] = true;
            UnitXP_SP3_Addon["prioritizeTargetNameplate"] = false;
            UnitXP_SP3_Addon["prioritizeMarkedNameplate"] = false;
            UnitXP_SP3_Addon["nameplateCombatFilter"] = false;
            UnitXP_SP3_Addon["showInCombatNameplatesNearPlayer"] = false;
            UnitXP_SP3_Addon["FPScap"] = 0;

            UnitXP_SP3_Addon["notify_flashTaskbarIcon"] = {};
            UnitXP_SP3_Addon["notify_flashTaskbarIcon"]["PLAYER_REGEN_DISABLED"] = true;
            UnitXP_SP3_Addon["notify_flashTaskbarIcon"]["CHAT_MSG_WHISPER"] = true;
            UnitXP_SP3_Addon["notify_flashTaskbarIcon"]["CHAT_MSG_RAID_WARNING"] = true;
            UnitXP_SP3_Addon["notify_flashTaskbarIcon"]["TRADE_SHOW"] = true;
            UnitXP_SP3_Addon["notify_flashTaskbarIcon"]["PARTY_INVITE_REQUEST"] = true;
            UnitXP_SP3_Addon["notify_flashTaskbarIcon"]["READY_CHECK"] = true;
            UnitXP_SP3_Addon["notify_flashTaskbarIcon"]["GUILD_INVITE_REQUEST"] = true;
            UnitXP_SP3_Addon["notify_flashTaskbarIcon"]["UPDATE_BATTLEFIELD_STATUS"] = true;
            UnitXP_SP3_Addon["notify_flashTaskbarIcon"]["PARTY_MEMBERS_CHANGED"] = true;
            UnitXP_SP3_Addon["notify_flashTaskbarIcon"]["CHAT_MSG_ADDON"] = true; -- For LFT

            UnitXP_SP3_Addon["notify_playSystemDefaultSound"] = {};
            UnitXP_SP3_Addon["notify_playSystemDefaultSound"]["PLAYER_REGEN_DISABLED"] = false;
            UnitXP_SP3_Addon["notify_playSystemDefaultSound"]["CHAT_MSG_WHISPER"] = false;
            UnitXP_SP3_Addon["notify_playSystemDefaultSound"]["CHAT_MSG_RAID_WARNING"] = false;
            UnitXP_SP3_Addon["notify_playSystemDefaultSound"]["TRADE_SHOW"] = false;
            UnitXP_SP3_Addon["notify_playSystemDefaultSound"]["PARTY_INVITE_REQUEST"] = false;
            UnitXP_SP3_Addon["notify_playSystemDefaultSound"]["READY_CHECK"] = false;
            UnitXP_SP3_Addon["notify_playSystemDefaultSound"]["GUILD_INVITE_REQUEST"] = false;
            UnitXP_SP3_Addon["notify_playSystemDefaultSound"]["UPDATE_BATTLEFIELD_STATUS"] = false;
            UnitXP_SP3_Addon["notify_playSystemDefaultSound"]["PARTY_MEMBERS_CHANGED"] = false;
            UnitXP_SP3_Addon["notify_playSystemDefaultSound"]["CHAT_MSG_ADDON"] = false; -- For LFT

            UnitXP_SP3_Print("UnitXP Service Pack 3 configuration is reset due to AddOn update.")
        end
        if (UnitXP_SP3_Icon == nil) then
            UnitXP_SP3_Icon = {
                hide = false
            };
        end
        xpsp3Frame:UnregisterEvent("ADDON_LOADED");
        xpsp3Frame:RegisterEvent("PLAYER_LOGIN");
        return;
    elseif (event == "PLAYER_LOGIN") then
        local test = false;

        if (pcall(UnitXP, "nop", "nop") == true) then
            test = true;
        end

        if (test == true) then
            UnitXP_SP3_reloadConfig();
            xpsp3Frame:RegisterEvent("PLAYER_ENTERING_WORLD");
            xpsp3Frame:RegisterEvent("PLAYER_LEAVING_WORLD");

            local message = "UnitXP Service Pack 3 is loaded.";
            local hasCOFFtimestamp, coffTimestamp = pcall(UnitXP, "version", "coffTimeDateStamp");
            if hasCOFFtimestamp then
                message = message .. " It was built on " .. date("%d %b %Y", coffTimestamp) .. ".";
            end
            UnitXP_SP3_Print(message);
        else
            UnitXP_SP3_Print("UnitXP Service Pack 3 didn't load properly.");
            return;
        end

        if (UnitXP_SP3_Addon["notify_flashTaskbarIcon"] ~= nil and
            UnitXP_SP3_Addon["notify_flashTaskbarIcon"]["PLAYER_REGEN_DISABLED"] == true and
            UnitAffectingCombat("player")) then
            UnitXP_SP3_flashTaskbarIcon();
        end

        if (UnitXP_SP3_Addon["notify_playSystemDefaultSound"] ~= nil and
            UnitXP_SP3_Addon["notify_playSystemDefaultSound"]["PLAYER_REGEN_DISABLED"] == true and
            UnitAffectingCombat("player")) then
            UnitXP_SP3_playSystemDefaultSound();
        end

        local iconData = libData:NewDataObject("UnitXP SP3 icon data", {
            OnClick = function()

                if (xpsp3Frame:IsShown()) then
                    PlaySound("igMainMenuContinue");
                    xpsp3Frame:Hide();
                else
                    PlaySound("igMainMenuOpen");
                    xpsp3Frame:Show();
                end
            end,
            OnTooltipShow = function(tooltip)
                tooltip:SetText(UNITXPSP3TOOLTIP);
            end,
            icon = "Interface\\Icons\\INV_Misc_Gem_Pearl_05"
        });

        libIcon:Register("UnitXP SP3 icon", iconData, UnitXP_SP3_Icon);

        return;
    elseif event == "PLAYER_ENTERING_WORLD" then
        UnitXP("FPScap", UnitXP_SP3_Addon["FPScap"]);
        return;
    elseif event == "PLAYER_LEAVING_WORLD" then
        -- Some user report a faster loading time
        UnitXP("FPScap", 0);
        return;
    end

    if UnitXP_SP3_Addon then
        if UnitXP_SP3_Addon["notify_flashTaskbarIcon"] then
            checkEvent(UnitXP_SP3_Addon["notify_flashTaskbarIcon"], UnitXP_SP3_flashTaskbarIcon)
        end

        if UnitXP_SP3_Addon["notify_playSystemDefaultSound"] then
            checkEvent(UnitXP_SP3_Addon["notify_playSystemDefaultSound"], UnitXP_SP3_playSystemDefaultSound)
        end

        if event == "PARTY_MEMBERS_CHANGED" then
            lastRecordedPartyMembers = GetNumPartyMembers()
        end
    end
end
