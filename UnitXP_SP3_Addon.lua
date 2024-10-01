--[[
    UnitXP Service Pack 3 Lua Addon

    By allfox
]] --
UnitXP_SP3_Addon = nil; -- It's a SavedVariable, not local

local function UnitXP_SP3_Print(msg)
    if (not DEFAULT_CHAT_FRAME) then
        return;
    end
    DEFAULT_CHAT_FRAME:AddMessage(tostring(msg));
end

function UnitXP_SP3_OnLoad()
    this:RegisterEvent("ADDON_LOADED");
end

local function UnitXP_SP3_NotifyOS()
    return pcall(UnitXP, "notify", "taskbarIcon");
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

    for ev, v in pairs(UnitXP_SP3_Addon["notifyOS"]) do
        if (v == true) then
            this:RegisterEvent(ev);
            xpsp3_checkButton_notify:SetChecked(true);
        else
            this:UnregisterEvent(ev);
            xpsp3_checkButton_notify:SetChecked(false);
        end
    end

end

function UnitXP_SP3_UI_OnClick(widget)
    if (widget == nil or string.find(widget:GetName(), "xpsp3") == nil) then
        return
    end
    
    if (string.find(widget:GetName(), "_checkButton_")) then
        if (string.find(widget:GetName(), "_modernNameplate")) then
            UnitXP_SP3_Addon["modernNameplateDistance"] = widget:GetChecked();
        end

        if (string.find(widget:GetName(), "_notify")) then
            for ev, v in pairs(UnitXP_SP3_Addon["notifyOS"]) do
                UnitXP_SP3_Addon["notifyOS"][ev] = widget:GetChecked();
            end 
        end
    end

    UnitXP_SP3_reloadConfig();
end

function UnitXP_SP3_OnEvent(event)
    if (event == "ADDON_LOADED" and arg1 == "UnitXP_SP3_Addon") then
        local dataVersion = 4;
        if (UnitXP_SP3_Addon == nil or UnitXP_SP3_Addon["dataVersion"] ~= dataVersion) then
            UnitXP_SP3_Addon = {};
            UnitXP_SP3_Addon["dataVersion"] = dataVersion;
            UnitXP_SP3_Addon["targetRangeConeFactor"] = 2.2;
            UnitXP_SP3_Addon["modernNameplateDistance"] = true;

            UnitXP_SP3_Addon["notifyOS"] = {};
            UnitXP_SP3_Addon["notifyOS"]["PLAYER_ENTER_COMBAT"] = true;
            UnitXP_SP3_Addon["notifyOS"]["CHAT_MSG_WHISPER"] = true;
            UnitXP_SP3_Addon["notifyOS"]["CHAT_MSG_RAID_WARNING"] = true;
            UnitXP_SP3_Addon["notifyOS"]["TRADE_SHOW"] = true;
            UnitXP_SP3_Addon["notifyOS"]["PARTY_INVITE_REQUEST"] = true;
            UnitXP_SP3_Addon["notifyOS"]["READY_CHECK"] = true;
            UnitXP_SP3_Addon["notifyOS"]["GUILD_INVITE_REQUEST"] = true;
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

    elseif (UnitXP_SP3_Addon ~= nil and UnitXP_SP3_Addon["notifyOS"] ~= nil) then
        for ev, v in pairs(UnitXP_SP3_Addon["notifyOS"]) do
            if (event == ev and v == true) then
                UnitXP_SP3_NotifyOS();
                break
            end
        end
    end
end
