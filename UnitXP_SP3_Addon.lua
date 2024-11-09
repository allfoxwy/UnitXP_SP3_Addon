--[[
    UnitXP Service Pack 3 Lua Addon

    By allfox
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

local registeredEvents = {"PLAYER_REGEN_DISABLED", "CHAT_MSG_WHISPER", "CHAT_MSG_RAID_WARNING", "TRADE_SHOW", 
    "PARTY_INVITE_REQUEST", "READY_CHECK", "GUILD_INVITE_REQUEST", "UPDATE_BATTLEFIELD_STATUS", "PARTY_MEMBERS_CHANGED"}
local specialEvents = {"LFT_Group_Ready", "LFT_Role_Check", "LFT_Leave_Queue"}

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

local function UnitXP_SP3_CreateDefaults(defaultValue)
    local data = {}
    local eventsData = {}
    data["Events"] = eventsData
    for _, e in ipairs(registeredEvents) do
        eventsData[e] = defaultValue
    end
    local specialEventsData = {}
    data["SpecialEvents"] = specialEventsData
    for _, e in ipairs(specialEvents) do
        specialEventsData[e] = defaultValue
    end
    return data
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

    for _, ev in ipairs(registeredEvents) do
        xpsp3Frame:UnregisterEvent(ev);
    end

    for ev, v in pairs(UnitXP_SP3_Addon["notify_flashTaskbarIcon"]["Events"]) do
        if (v == true) then
            xpsp3Frame:RegisterEvent(ev);
            xpsp3_checkButton_notify_flashTaskbarIcon:SetChecked(true);
        else
            xpsp3_checkButton_notify_flashTaskbarIcon:SetChecked(false);
        end
    end
    for ev, v in pairs(UnitXP_SP3_Addon["notify_playSystemDefaultSound"]["Events"]) do
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

    if (string.find(widget:GetName(), "_checkButton_")) then
        if (string.find(widget:GetName(), "_modernNameplate")) then
            if (widget:GetChecked()) then
                UnitXP_SP3_Addon["modernNameplateDistance"] = true;
            else
                UnitXP_SP3_Addon["modernNameplateDistance"] = false;
            end
        end

        local checked = widget:GetChecked() == 1

        if (string.find(widget:GetName(), "_notify_flashTaskbarIcon")) then
            UnitXP_SP3_Addon["notify_flashTaskbarIcon"] = UnitXP_SP3_CreateDefaults(checked)
        end

        if (string.find(widget:GetName(), "_notify_playSystemDefaultSound")) then
            UnitXP_SP3_Addon["notify_playSystemDefaultSound"] = UnitXP_SP3_CreateDefaults(checked)
        end
    end

    UnitXP_SP3_reloadConfig();
end

local function handleSpecialEvent(specialEvent)
    if UnitXP_SP3_Addon["notify_flashTaskbarIcon"]["SpecialEvents"][specialEvent] then
        UnitXP_SP3_flashTaskbarIcon()
    end
    if UnitXP_SP3_Addon["notify_playSystemDefaultSound"]["SpecialEvents"][specialEvent] then
        UnitXP_SP3_playSystemDefaultSound()
    end
end

local function hookSpecialEventFunction(funcName, eventName)
    local func = getglobal(funcName)
    if func then
        setglobal(funcName, function(...)
            func(unpack(arg)) -- idk where "arg" came from, but it does indeed contain the varargs
            handleSpecialEvent(eventName)
        end)
    end
end

-- Hooks the Turtle 1.17.2 LFT functions
local function hookLFT()
    hookSpecialEventFunction("LFT_GroupReadyShow", "LFT_Group_Ready")
    hookSpecialEventFunction("LFT_RoleCheckStart", "LFT_Role_Check")
    hookSpecialEventFunction("LFT_OnQueueLeave", "LFT_Leave_Queue")
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
        else
            actionFunction();
        end
    end
end

function UnitXP_SP3_OnEvent(event)
    if (event == "ADDON_LOADED" and arg1 == "UnitXP_SP3_Addon") then
        local dataVersion = 10;
        if (UnitXP_SP3_Addon == nil or UnitXP_SP3_Addon["dataVersion"] ~= dataVersion) then
            UnitXP_SP3_Addon = {};
            UnitXP_SP3_Addon["dataVersion"] = dataVersion;
            UnitXP_SP3_Addon["targetRangeConeFactor"] = 2.2;
            UnitXP_SP3_Addon["modernNameplateDistance"] = true;

            -- All events flash taskbar icon by default
            UnitXP_SP3_Addon["notify_flashTaskbarIcon"] = UnitXP_SP3_CreateDefaults(true)
            -- All events don't play sound by default
            UnitXP_SP3_Addon["notify_playSystemDefaultSound"] = UnitXP_SP3_CreateDefaults(false)
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

            hookLFT()

            UnitXP_SP3_Print("UnitXP Service Pack 3 is loaded. Press ESC to access it from Main Menu.");
        else
            UnitXP_SP3_Print("UnitXP Service Pack 3 didn't load properly.");
        end

        if UnitAffectingCombat("player") then
            if UnitXP_SP3_Addon["notify_flashTaskbarIcon"]["Events"]["PLAYER_REGEN_DISABLED"] then
                UnitXP_SP3_flashTaskbarIcon()
            end
            if UnitXP_SP3_Addon["notify_playSystemDefaultSound"]["Events"]["PLAYER_REGEN_DISABLED"] then
                UnitXP_SP3_playSystemDefaultSound()
            end
        end

        return;
    end

    if UnitXP_SP3_Addon then
        if UnitXP_SP3_Addon["notify_flashTaskbarIcon"] then
            checkEvent(UnitXP_SP3_Addon["notify_flashTaskbarIcon"]["Events"], UnitXP_SP3_flashTaskbarIcon)
        end

        if UnitXP_SP3_Addon["notify_playSystemDefaultSound"] then
            checkEvent(UnitXP_SP3_Addon["notify_playSystemDefaultSound"]["Events"], UnitXP_SP3_playSystemDefaultSound)
        end

        if event == "PARTY_MEMBERS_CHANGED" then
            lastRecordedPartyMembers = GetNumPartyMembers()
        end
    end
end
