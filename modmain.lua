local _G = GLOBAL
local scheduler = _G.scheduler
local subfmt = _G.subfmt

local language = GetModConfigData("language")
if language == "auto" then
    local langs = {
        zh = "chinese_s",
        chs = "chinese_s",
        pt = "portuguese_br",
        es = "spanish",
        en = "english",
    }
    language = langs[_G.LanguageTranslator.defaultlang] or "english"
end
local AW_STRINGS = require("aw_strings/"..language) -- or require("strings/english")

local function RGB(r, g, b)
    return { r / 255, g / 255, b / 255, 1 }
end

local COLORS = {
    WHITE   = RGB(255, 255, 255),
    BLACK   = RGB(0, 0, 0),
    RED     = RGB(207, 61, 61),
    PINK    = RGB(255, 192, 203),
    YELLOW  = RGB(255, 255, 0),
    BLUE    = RGB(0, 0, 255),
    GREEN   = RGB(59, 222, 99),
    PURPLE  = RGB(184, 87, 198),
}

local STRINGCOLOR
if GetModConfigData("P_C") == "preset" then
    STRINGCOLOR = COLORS[string.upper(GetModConfigData("string_color"))]
elseif GetModConfigData("P_C") == "customize" then
    STRINGCOLOR = RGB(GetModConfigData("R"), GetModConfigData("G"), GetModConfigData("B"))
end

local display_form = GetModConfigData("display_form")
if display_form == "eventannouncer" then
    local EventAnnouncer = require "widgets/eventannouncer"
    local PlayerHud = require("screens/playerhud")
    local CreateOverlays = PlayerHud.CreateOverlays
    function PlayerHud:CreateOverlays(owner, ...)
        CreateOverlays(self, owner, ...)
        if not self.eventannouncer:is_a(EventAnnouncer) then
            self.eventannouncer = self.eventannouncer:AddChild(EventAnnouncer(owner))
        end
    end

    -- Fix AnnouncementWidget mutating original color table
    local AnnouncementWidget = require("widgets/announcementwidget")
    local SetTextColour = AnnouncementWidget.SetTextColour
    function AnnouncementWidget:SetTextColour(r, g, b, a, ...)
        if type(r) == "table" then
            r = _G.shallowcopy(r)
        end
        return SetTextColour(self, r, g, b, a, ...)
    end
end

local function Say(message)
    local ThePlayer = _G.ThePlayer
    if not ThePlayer then return end
    if display_form == "announce" then
        _G.TheNet:Say("[Advanced Warning] "..message)
    elseif display_form == "head" then
        if not ThePlayer.components.talker then return end
        ThePlayer.components.talker:Say(message, nil, nil, nil, nil, STRINGCOLOR)
    elseif display_form == "chat" then
        _G.ChatHistory:AddToHistory(_G.ChatTypes.Message, nil, nil, "[Advanced Warning]", message, STRINGCOLOR, nil, nil, true)
        -- ThePlayer.HUD.controls.networkchatqueue:PushMessage("[Advanced Warning]", message , STRINGCOLOR)
    elseif display_form == "eventannouncer" then
        if not ThePlayer.HUD.eventannouncer then return end
        ThePlayer.HUD.eventannouncer:ShowNewAnnouncement(message, STRINGCOLOR, "death")
    end
end

local function add_record_table(main_table, name)
    if GetModConfigData(name.."_warning") then
        main_table[name] = {}
    end
end

local bosses_warning = {}
add_record_table(bosses_warning, "deerclops")
add_record_table(bosses_warning, "bearger")
add_record_table(bosses_warning, "twister")

local function DoBossWarning(boss, level, times)
    local time = level == 4 and times == 3 and 3
        or ((5 - level) * 30) - 15 * (times - 1)
    Say(subfmt(AW_STRINGS.BOSSES._format, {boss = AW_STRINGS.BOSSES[boss] or boss, time = time}))
end

local function reset_times(record_table, current_level)
    for k, v in pairs(record_table) do
        if type(v) == "number" and (current_level == nil or k ~= current_level) then
            record_table[k] = 0
        end
    end
end

for boss, record_table in pairs(bosses_warning) do
    for i = 2, 4 do -- Level one is useless I guess.. (longer than 90s)
        local level = tostring(i)
        AddPrefabPostInit(boss.."warning_lvl"..level, function()
            reset_times(record_table, level)
            if not record_table[level] then
                record_table[level] = 0
            end
            record_table[level] = record_table[level] + 1
            if record_table[level] > level - 1 then
                record_table[level] = 1
            end
            DoBossWarning(boss, i, record_table[level])

            -- Reset the times, if no warnings any more
            if record_table.task then
                record_table.task:Cancel()
            end
            record_table.task = scheduler:ExecuteInTime(60, function()
                reset_times(record_table)
                record_table.task = nil
            end)
        end)
    end
end

local hounded_warning = {}
add_record_table(hounded_warning, "hound")
add_record_table(hounded_warning, "worm")

local function DoHoundedWarning(attacker, time)
    Say(subfmt(AW_STRINGS.HOUNDED._format, {attacker = AW_STRINGS.HOUNDED[attacker] or attacker, time = time}))
end

local ANNOUNCEMENT_COOLDOWN = 3
local function start_hounded_task(attacker, record_table)

    if record_table.last_announce_time == nil
        or _G.GetTime() - record_table.last_announce_time > ANNOUNCEMENT_COOLDOWN then

        DoHoundedWarning(attacker, record_table.time)
    end
    record_table.last_announce_time = _G.GetTime()

    local next_warning_delay = 15
    if record_table.time == 15 then
        record_table.time = record_table.time - 12
        next_warning_delay = 12
    elseif record_table.time <= 3 then
        record_table.task = scheduler:ExecuteInTime(30, function() -- Cooldown
            record_table.task = nil
            record_table.last_level = nil
        end)
        return
    else
        record_table.time = record_table.time - 15
    end

    if record_table.task then
        record_table.task:Cancel()
    end
    record_table.task = scheduler:ExecuteInTime(next_warning_delay, function()
        start_hounded_task(attacker, record_table)
    end)

end

for attacker, record_table in pairs(hounded_warning) do
    for i = 2, 4 do
        local level = tostring(i)
        AddPrefabPostInit(attacker.."warning_lvl"..level, function()
            if record_table.task == nil
                or i > record_table.last_level then

                record_table.time = (5 - i) * 30
                start_hounded_task(attacker, record_table)
            end
            record_table.last_level = i
        end)
    end
end

local antlion_warning = {}
add_record_table(antlion_warning, "sinkhole")
add_record_table(antlion_warning, "cavein")

local antlion_warning_prefabs = {
    sinkhole = {"sinkhole_warn_fx_1", "sinkhole_warn_fx_2", "sinkhole_warn_fx_3"},
    cavein = {"cavein_debris"}
}

for trouble, record_table in pairs(antlion_warning) do
    for _, prefab in ipairs(antlion_warning_prefabs[trouble]) do
        AddPrefabPostInit(prefab, function()
            if record_table.task then return end
            Say(subfmt(AW_STRINGS.ANTLION._format, {trouble = AW_STRINGS.ANTLION[trouble] or trouble}))
            record_table.task = scheduler:ExecuteInTime(30, function()
                record_table.task = nil
            end)
        end)
    end
end

-- Apply color on "[Advanced Warning]"
-- AddClassPostConstruct("widgets/chatqueue", function(self)
--     local Old_RefreshWidgets = self.RefreshWidgets
--     self.RefreshWidgets = function(self, ...)
--         Old_RefreshWidgets(self, ...)

--         local current_time = _G.GetTime()

--         for i = 1, #self.chat_queue_data do

--             local row_data = self.chat_queue_data[i]

--             local alpha_fade = _G.calcChatAlpha(current_time, row_data.expire_time)

--             if alpha_fade > 0 then
--                 local c = { row_data.colour[1], row_data.colour[2], row_data.colour[3], alpha_fade }
--                 if row_data.username == "[Advanced Warning]" then
--                     self.widget_rows[i].message:SetColour(c)
--                 end
--             end
--         end
--     end
-- end)
