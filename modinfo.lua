name = "Advanced Warning"
description = "Feel free to listen to your own music :)"
author = "Tony"
version = "2.0.6"
icon_atlas = "modicon.xml"
icon = "modicon.tex"
dst_compatible = true
client_only_mod = true

api_version = 10

local valuelist = {}
for i = 0, 255 do
    valuelist[i] = {description = i, data = i}
end

local function AddTitle(title)
    return {
        label = title,
        name = "",
        hover = "",
        options = {{description = "", data = 0}},
        default = 0
    }
end

configuration_options =
{
    AddTitle("General"),
    {
        name = "language",
        hover = "Choose your language\n选择您使用的语言",
        label = "Language",
        options =
        {
            {description = "Auto", data = "auto", hover = "Auto detect, may not work"},
            {description = "English", data = "english", hover = "English"},
            {description = "Español", data = "spanish", hover = "Spanish"},
            {description = "Português", data = "portuguese_br", hover = "Portuguese BR"},
            {description = "简体中文", data = "chinese_s", hover = "Simplified Chinese"},
        },
        default = "auto",
    },
    {
        name = "display_form",
        hover = "Choose the place where to display warning string\n选择提示语句的显示位置",
        label = "Display Form",
        options =
        {
            {description = "Head message", data = "head", hover = "Warning string will appear on top of the player\n提示语句将会出现在人物头顶"},
            {description = "Chat message", data = "chat", hover = "Warning string will appear at the chat bar(Visible to yourself only)\n提示语句将会出现在聊天栏的位置(仅自己可见)"},
            {description = "Event Announcer", data = "eventannouncer", hover = "Warning string will appear at the system message bar\n提示语句将会显示到系统消息栏"},
            {description = "Announce to server", data = "announce", hover = "Warning string will announce to the server, and everyone can see it\n提示语句将会宣告到服务器，所有人可见"},
        },
        default = "head",
    },
    AddTitle("Warnings"),
    {
        name = "deerclops_warning",
        hover = "player will say \"Deerclops will come in ... seconds\"\n玩家会在巨鹿每次吼叫的同时说:\"巨鹿将在...秒后到来\"",
        label = "Deerclops",
        options =
        {
            {description = "Enable", data = true, hover = "启用"},
            {description = "Disable", data = false, hover = "禁用"},
        },
        default = true,
    },
    {
        name = "bearger_warning",
        hover = "player will say \"Bearger will come in ... seconds\"\n玩家会在熊獾每次吼叫的同时说:\"熊獾将在...秒后到来\"",
        label = "Bearger",
        options =
        {
            {description = "Enable", data = true, hover = "启用"},
            {description = "Disable", data = false, hover = "禁用"},
        },
        default = true,
    },
    {
        name = "twister_warning",
        hover = "player will say \"Sealnado will come in ... seconds\"\n玩家会在飓风海豹每次吼叫的同时说:\"海豹将在...秒后到来\"\n(For Island Adventure)",
        label = "Sealnado",
        options =
        {
            {description = "Enable", data = true, hover = "启用"},
            {description = "Disable", data = false, hover = "禁用"},
        },
        default = true,
    },
    {
        name = "hound_warning",
        hover = "player will say \"Hound attack will begin in ... seconds\"\n玩家会在猎犬袭击的警告声出现的时候说:\"猎犬袭击将在...秒后开始\"",
        label = "Hound Attack",
        options =
        {
            {description = "Enable", data = true, hover = "启用"},
            {description = "Disable", data = false, hover = "禁用"},
        },
        default = true,
    },
    {
        name = "worm_warning",
        hover = "player will say \"Worm attack will begin in ... seconds\"\n玩家会在蠕虫袭击的警告声出现的时候说:\"蠕虫袭击将在...秒后开始\"",
        label = "Depth Worm Attack",
        options =
        {
            {description = "Enable", data = true, hover = "启用"},
            {description = "Disable", data = false, hover = "禁用"},
        },
        default = true,
    },
    {
        name = "sinkhole_warning",
        hover = "player will say \"Sinkhole will spawn in ... seconds\"\n玩家会在蚁狮地震前的提示时说:\"蚁狮地陷将在...秒后生成\"",
        label = "Antlion Sinkhole",
        options =
        {
            {description = "Enable", data = true, hover = "启用"},
            {description = "Disable", data = false, hover = "禁用"},
        },
        default = true,
    },
    {
        name = "cavein_warning",
        hover = "player will say \"Cave-in will spawn in ... seconds\"\n玩家会在蚁狮落石前的提示时说:\"蚁狮落石将在...秒后生成\"",
        label = "Antlion Cave-in",
        options =
        {
            {description = "Enable", data = true, hover = "启用"},
            {description = "Disable", data = false, hover = "禁用"},
        },
        default = true,
    },
    AddTitle("Colors"),
    {
        name = "P_C",
        hover = "If you want a customize warning string color,you can choose the \"Customize\" and config Red,Green,Blue value to whatever you need\n如果你希望自定义提示语句的颜色，可以选择Customize，然后分别在Red、Green、Blue选项中选择需要的数值",
        label = "Warning String Color",
        options =
        {
            {description = "Preset", data = "preset", hover = "Will use preset color\n将会使用预设颜色"},
            {description = "Customize", data = "customize", hover = "Will use customize color\n将会使用自定义颜色"},
        },
        default = "preset",
    },
    {
        name = "string_color",
        hover = "Choose a warning string color :)\n选一个喜欢的提示语颜色吧 :)",
        label = "Warning String Color Preset",
        options =
        {
            {description = "White", data = "white", hover = "白色"},
            {description = "Black", data = "black", hover = "黑色"},
            {description = "Red", data = "red", hover = "红色"},
            {description = "Pink", data = "pink", hover = "粉色"},
            {description = "Purple", data = "purple", hover = "紫色"},
            {description = "Yellow", data = "yellow", hover = "黄色"},
            {description = "Blue", data = "blue", hover = "蓝色"},
            {description = "Green", data = "green", hover = "绿色"}
        },
        default = "white",
    },
    {
        name = "R",
        hover = "",
        label = "Red",
        options = valuelist,
		default = 0,
	},
    {
        name = "G",
        hover = "",
        label = "Green",
        options = valuelist,
		default = 0,
	},
    {
        name = "B",
        hover = "",
        label = "Blue",
        options = valuelist,
		default = 0,
	}
}
