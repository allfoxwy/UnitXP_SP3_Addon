--[[
    UnitXP Service Pack 3 Lua Addon

    By allfox, and thankful community.
]] --
UnitXP_SP3_Addon = nil; -- It's a SavedVariable, not local

-- Key binding strings
BINDING_HEADER_UNITXPSP3TARGETING = "UnitXP SP3 Targeting Functions";
BINDING_NAME_UNITXPSP3NEARESTENEMY = "Nearest Enemy";
BINDING_NAME_UNITXPSP3WORLDBOSS = "World Boss";
BINDING_NAME_UNITXPSP3NEXTMARKER = "Next Target Marker";
BINDING_NAME_UNITXPSP3PREVIOUSMARKER = "Previous Target Marker";
BINDING_NAME_UNITXPSP3NEXTENEMY = "Next Enemy";
BINDING_NAME_UNITXPSP3PREVIOUSENEMY = "Previous Enemy";
BINDING_NAME_UNITXPSP3NEXTMELEE = "Next Enemy Prioritizing Melee";
BINDING_NAME_UNITXPSP3PREVIOUSMELEE = "Previous Enemy Prioritizing Melee";

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
    return pcall(UnitXP, "notify", "taskbarIcon");
end

local function UnitXP_SP3_playSystemDefaultSound()
    return pcall(UnitXP, "notify", "systemSound", "SystemDefault");
end

local function UnitXP_SP3_setTargetingRangeConeFactor(factor)
    return pcall(UnitXP, "target", "rangeCone", factor);
end

local function UnitXP_SP3_setModernNameplateDistance(enable)
    return pcall(UnitXP, "modernNameplateDistance", enable);
end

local function UnitXP_SP3_reloadConfig()
    UnitXP_SP3_setTargetingRangeConeFactor(UnitXP_SP3_Addon["targetingRangeConeFactor"]);

    if (UnitXP_SP3_Addon["modernNameplateDistance"]) then
        UnitXP_SP3_setModernNameplateDistance("enable");
        xpsp3_checkButton_modernNameplate:SetChecked(true);
    else
        UnitXP_SP3_setModernNameplateDistance("disable");
        xpsp3_checkButton_modernNameplate:SetChecked(false);
    end

    for ev, v in pairs(UnitXP_SP3_Addon["notify_flashTaskbarIcon"]) do
        if (type(v) == "boolean") then
            xpsp3Frame:UnregisterEvent(ev);
        end
    end
    for ev, v in pairs(UnitXP_SP3_Addon["notify_playSystemDefaultSound"]) do
        if (type(v) == "boolean") then
            xpsp3Frame:UnregisterEvent(ev);
        end
    end

    for ev, v in pairs(UnitXP_SP3_Addon["notify_flashTaskbarIcon"]) do
        if (type(v) == "boolean") then
            if (v == true) then
                xpsp3Frame:RegisterEvent(ev);
                xpsp3_checkButton_notify_flashTaskbarIcon:SetChecked(true);
            else
                xpsp3_checkButton_notify_flashTaskbarIcon:SetChecked(false);
            end
        end
    end
    for ev, v in pairs(UnitXP_SP3_Addon["notify_playSystemDefaultSound"]) do
        if (type(v) == "boolean") then
            if (v == true) then
                xpsp3Frame:RegisterEvent(ev);
                xpsp3_checkButton_notify_playSystemDefaultSound:SetChecked(true);
            else
                xpsp3_checkButton_notify_playSystemDefaultSound:SetChecked(false);
            end
        end
    end

end

function UnitXP_SP3_UI_OnClick(widget)
    if (widget == nil or string.find(widget:GetName(), "xpsp3") == nil) then
        return
    end

    if (string.find(widget:GetName(), "_checkButton_")) then
        if (string.find(widget:GetName(), "_modernNameplate")) then
            if (widget:GetChecked()) then
                UnitXP_SP3_Addon["modernNameplateDistance"] = true;
            else
                UnitXP_SP3_Addon["modernNameplateDistance"] = false;
            end
        end

        if (string.find(widget:GetName(), "_notify_flashTaskbarIcon")) then
            for ev, v in pairs(UnitXP_SP3_Addon["notify_flashTaskbarIcon"]) do
                if (type(v) == "boolean") then
                    if (widget:GetChecked()) then
                        UnitXP_SP3_Addon["notify_flashTaskbarIcon"][ev] = true;
                    else
                        UnitXP_SP3_Addon["notify_flashTaskbarIcon"][ev] = false;
                    end
                end
            end
        end

        if (string.find(widget:GetName(), "_notify_playSystemDefaultSound")) then
            for ev, v in pairs(UnitXP_SP3_Addon["notify_playSystemDefaultSound"]) do
                if (type(v) == "boolean") then
                    if (widget:GetChecked()) then
                        UnitXP_SP3_Addon["notify_playSystemDefaultSound"][ev] = true;
                    else
                        UnitXP_SP3_Addon["notify_playSystemDefaultSound"][ev] = false;
                    end
                end
            end
        end
    end

    UnitXP_SP3_reloadConfig();
end

-- Recording party members from previous PARTY_MEMBERS_CHANGED events so that we can verify if the party just became full
local lastRecordedPartyMembers = 0;

local function checkEvent(event, notifyMethod)
    if notifyMethod[event] then
        if (event == "PARTY_MEMBERS_CHANGED") then
            -- Party full
            if (GetNumRaidMembers() == 0 and GetNumPartyMembers() == 4 and lastRecordedPartyMembers ~= 4) then
                notifyMethod["actionFunction"]();
            end

        elseif (event == "UPDATE_BATTLEFIELD_STATUS") then
            for i = 1, MAX_BATTLEFIELD_QUEUES do
                local s = GetBattlefieldStatus(i);
                -- Battlefield is ready
                if (s == "confirm") then
                    notifyMethod["actionFunction"]();
                    break
                end
            end

        else
            -- Other events
            notifyMethod["actionFunction"]();
        end
    end
end

function UnitXP_SP3_OnEvent(event)
    if (event == "ADDON_LOADED" and arg1 == "UnitXP_SP3_Addon") then
        local dataVersion = 12;
        if (UnitXP_SP3_Addon == nil or UnitXP_SP3_Addon["dataVersion"] ~= dataVersion) then
            UnitXP_SP3_Addon = {};
            UnitXP_SP3_Addon["dataVersion"] = dataVersion;
            UnitXP_SP3_Addon["targetRangeConeFactor"] = 2.2;
            UnitXP_SP3_Addon["modernNameplateDistance"] = true;

            UnitXP_SP3_Addon["notify_flashTaskbarIcon"] = {};
            UnitXP_SP3_Addon["notify_flashTaskbarIcon"]["actionFunction"] = UnitXP_SP3_flashTaskbarIcon;
            UnitXP_SP3_Addon["notify_flashTaskbarIcon"]["PLAYER_REGEN_DISABLED"] = true;
            UnitXP_SP3_Addon["notify_flashTaskbarIcon"]["CHAT_MSG_WHISPER"] = true;
            UnitXP_SP3_Addon["notify_flashTaskbarIcon"]["CHAT_MSG_RAID_WARNING"] = true;
            UnitXP_SP3_Addon["notify_flashTaskbarIcon"]["TRADE_SHOW"] = true;
            UnitXP_SP3_Addon["notify_flashTaskbarIcon"]["PARTY_INVITE_REQUEST"] = true;
            UnitXP_SP3_Addon["notify_flashTaskbarIcon"]["READY_CHECK"] = true;
            UnitXP_SP3_Addon["notify_flashTaskbarIcon"]["GUILD_INVITE_REQUEST"] = true;
            UnitXP_SP3_Addon["notify_flashTaskbarIcon"]["UPDATE_BATTLEFIELD_STATUS"] = true;
            UnitXP_SP3_Addon["notify_flashTaskbarIcon"]["PARTY_MEMBERS_CHANGED"] = true;

            UnitXP_SP3_Addon["notify_playSystemDefaultSound"] = {};
            UnitXP_SP3_Addon["notify_playSystemDefaultSound"]["actionFunction"] = UnitXP_SP3_playSystemDefaultSound;
            UnitXP_SP3_Addon["notify_playSystemDefaultSound"]["PLAYER_REGEN_DISABLED"] = false;
            UnitXP_SP3_Addon["notify_playSystemDefaultSound"]["CHAT_MSG_WHISPER"] = false;
            UnitXP_SP3_Addon["notify_playSystemDefaultSound"]["CHAT_MSG_RAID_WARNING"] = false;
            UnitXP_SP3_Addon["notify_playSystemDefaultSound"]["TRADE_SHOW"] = false;
            UnitXP_SP3_Addon["notify_playSystemDefaultSound"]["PARTY_INVITE_REQUEST"] = false;
            UnitXP_SP3_Addon["notify_playSystemDefaultSound"]["READY_CHECK"] = false;
            UnitXP_SP3_Addon["notify_playSystemDefaultSound"]["GUILD_INVITE_REQUEST"] = false;
            UnitXP_SP3_Addon["notify_playSystemDefaultSound"]["UPDATE_BATTLEFIELD_STATUS"] = false;
            UnitXP_SP3_Addon["notify_playSystemDefaultSound"]["PARTY_MEMBERS_CHANGED"] = false;
        end

        local test = false;
        if (vanilla1121mod ~= nil and vanilla1121mod.UnitXP_SP3 ~= nil) then
            test = true;
        elseif (pcall(UnitXP, "notify", "taskbarIcon") == true) then
            test = true;
        end

        if (test == true) then
            GameMenuButtonXPSP3:SetPoint("BOTTOM", GameMenuFrame, "BOTTOM", 0, 14);
            GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + GameMenuButtonXPSP3:GetHeight());

            UnitXP_SP3_reloadConfig();

            UnitXP_SP3_Print("UnitXP Service Pack 3 is loaded. Press ESC to access it from Main Menu.");
        else
            UnitXP_SP3_Print("UnitXP Service Pack 3 didn't load properly.");
        end

        -- We might in combat when game start
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

        -- We might in party when game start
        lastRecordedPartyMembers = GetNumPartyMembers();

        return;
    end

    if UnitXP_SP3_Addon then
        if UnitXP_SP3_Addon["notify_flashTaskbarIcon"] then
            checkEvent(event, UnitXP_SP3_Addon["notify_flashTaskbarIcon"]);
        end

        if UnitXP_SP3_Addon["notify_playSystemDefaultSound"] then
            checkEvent(event, UnitXP_SP3_Addon["notify_playSystemDefaultSound"]);
        end

        -- lastRecordedPartyMembers maintenance could not be done in checkEvent(), because checkEvent() not always be called.
        if event == "PARTY_MEMBERS_CHANGED" then
            lastRecordedPartyMembers = GetNumPartyMembers();
        end
    end

end
