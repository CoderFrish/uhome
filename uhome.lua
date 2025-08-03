---
--- GitHub: https://github.com/CoderFrish
--- Created by Frish2021.
--- DateTime: 2025/8/3 21:10
---
local luajava = require("luajava")

local config = [[
# This is config file of uhome plugin
join:
    message: 欢迎玩家{name}加入服务器
    enable: false

quit:
    message: 玩家{name}离开了服务器
    enable: false

tpr:
    message:
        title: 三秒后随机传送
        subtitle: ...
    delayed: 60 # 20 = 1s
    error:
        player_not_found: §c玩家不存在
]]

local _api = function(player)
    return {
        name = player:getName()
    }
end

local format = function(text, player)
    local api = _api(player)

    for k, v in pairs(api) do
        local pattern = "{" .. k .. "}"
        if string.match(text, pattern) then
            return string.gsub(text, pattern, v)
        end
    end
end

local events = function(plugin)
    local config = plugin.config:getConfig("default")

    local join = function(event)
        local message = config:get("join.message")

        if config:get("join.enable") then
            event:setJoinMessage(format(message, event:getPlayer()))
        end
    end

    local quit = function(event)
        local message = config:get("quit.message")

        if config:get("quit.enable") then
            event:setQuitMessage(format(message, event:getPlayer()))
        end
    end

    plugin.event:listen("PlayerJoinEvent", join)
    plugin.event:listen("PlayerQuitEvent", quit)
end

local random = luajava.newInstance("java.util.Random")

local commands = function(plugin)
    local config = plugin.config:getConfig("default")
    local title = luajava.newInstance("com.destroystokyo.paper.Title", config:get("tpr.message.title"), config:get("tpr.message.subtitle"), 20, 50, 20)

    local tpr = function(sender, command, args)
        local target = sender:getLocation():set(
                random:nextInt(546576),
                100,
                random:nextInt(746874)
        )

        sender:sendTitle(title)

        pluginManager:entityScheduler(sender):runDelayed(
                plugin,
                function()
                    sender:teleportAsync(target)
                end,
                function()
                    sender:sendMessage(
                            config:get("tpr.error.player_not_found")
                    )
                end,
                config:get("tpr.delayed")
        )
    end

    plugin.command:register("tpr", tpr, {
        description = "This is uhome command, it can teleport random place in his world.",
        usage = "/tpr"
    })
end

-- Plugin Main
local uhome = function(plugin)
    plugin.load = function()
        plugin.config:register("default", config)
    end

    plugin.enable = function()
        events(plugin)
        commands(plugin)
    end

    plugin.disable = function()
    end
end

local meta = {
    name = "uhome",
    version = "1.0.0",
    description = "This is a useful plugin.",
    authors = {
        "Frish2021"
    },
    license = "MIT",
    website = "https://github.com/CoderFrish/uhome"
}

pluginManager:register(uhome, meta)
