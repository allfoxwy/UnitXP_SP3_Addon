--[[
    UnitXP Service Pack 3 Lua Addon

    By Konaka Masaru
]] --
UnitXP_SP3_Addon = nil; -- It's a SavedVariable, not local

local function UnitXP_SP3_Print(msg)
    if (not DEFAULT_CHAT_FRAME) then
        return;
    end
    DEFAULT_CHAT_FRAME:AddMessage(msg);
end

function UnitXP_SP3_OnLoad()
    this:RegisterEvent("ADDON_LOADED");
end

local function UnitXP_SP3_NotifyOS()
    return pcall(UnitXP, "flashNotifyOS");
end

local function UnitXP_SP3_setTargetingRangeConeFactor(factor)
    return pcall(UnitXP, "target", "rangeCone", factor);
end

local function UnitXP_SP3_setModernNameplateDistance(enable)
    return pcall(UnitXP, "modernNameplateDistance", enable);
end

local function UnitXP_SP3_reloadConfig()
    UnitXP_SP3_setTargetingRangeConeFactor(UnitXP_SP3_Addon["targetingRangeConeFactor"]);

    if (UnitXP_SP3_Addon["modernNameplateDistance"] == true) then
        UnitXP_SP3_setModernNameplateDistance("enable");
    else
        UnitXP_SP3_setModernNameplateDistance("disable");
    end

    for ev, v in pairs(UnitXP_SP3_Addon["notifyOS"]) do
        if (v == true) then
            this:RegisterEvent(ev);
        else
            this:UnregisterEvent(ev);
        end
    end
end

function UnitXP_SP3_OnEvent(event)
    if (event == "ADDON_LOADED" and arg1 == "UnitXP_SP3_Addon") then
        if (UnitXP_SP3_Addon == nil or UnitXP_SP3_Addon["dataVersion"] ~= 1) then
            UnitXP_SP3_Addon = {};
            UnitXP_SP3_Addon["dataVersion"] = 1;
            UnitXP_SP3_Addon["targetingRangeConeFactor"] = 2.2;
            UnitXP_SP3_Addon["modernNameplateDistance"] = true;

            UnitXP_SP3_Addon["notifyOS"] = {};
            UnitXP_SP3_Addon["notifyOS"]["PLAYER_ENTER_COMBAT"] = true;
            UnitXP_SP3_Addon["notifyOS"]["CHAT_MSG_WHISPER"] = true;
            UnitXP_SP3_Addon["notifyOS"]["CHAT_MSG_GUILD"] = false;
            UnitXP_SP3_Addon["notifyOS"]["CHAT_MSG_OFFICER"] = true;
            UnitXP_SP3_Addon["notifyOS"]["CHAT_MSG_PARTY"] = true;
            UnitXP_SP3_Addon["notifyOS"]["CHAT_MSG_PARTY_LEADER"] = true;
            UnitXP_SP3_Addon["notifyOS"]["CHAT_MSG_RAID"] = true;
            UnitXP_SP3_Addon["notifyOS"]["CHAT_MSG_RAID_LEADER"] = true;
            UnitXP_SP3_Addon["notifyOS"]["CHAT_MSG_RAID_WARNING"] = true;
            UnitXP_SP3_Addon["notifyOS"]["TRADE_SHOW"] = true;
            UnitXP_SP3_Addon["notifyOS"]["PARTY_INVITE_REQUEST"] = true;
            UnitXP_SP3_Addon["notifyOS"]["READY_CHECK"] = true;
            UnitXP_SP3_Addon["notifyOS"]["GUILD_INVITE_REQUEST"] = true;
        end

        UnitXP_SP3_reloadConfig();

        local test = false;
        if (vanilla1121mod ~= nil and vanilla1121mod.UnitXP_SP3 ~= nil) then
            test = true;
        elseif (pcall(UnitXP, "target", "rangeCone") == true) then
            test = true;
        end

        if(test == false) then
            UnitXP_SP3_Print(UNITXP_SP3_DIDNT_LOAD);
        end

    elseif (UnitXP_SP3_Addon ~= nil and UnitXP_SP3_Addon["notifyOS"] ~= nil) then
        for ev, v in pairs(UnitXP_SP3_Addon["notifyOS"]) do
            if (event == ev and v == true) then
                UnitXP_SP3_NotifyOS();
                break
            end
        end
    end
end
