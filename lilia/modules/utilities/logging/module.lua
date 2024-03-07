﻿MODULE.categories = MODULE.categories or {}
MODULE.regex = MODULE.regex or {}
MODULE.name = "Utilities - Logger"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Adds a Module that implements a action logger"
MODULE.logsPerPage = 20
MODULE.maxPagesInBits = 16
MODULE.maxCategoriesInBits = 7
MODULE.Dependencies = {
    {
        File = MODULE.path .. "/main/client.lua",
    },
    {
        File = MODULE.path .. "/main/server.lua",
    },
    {
        File = MODULE.path .. "/definitions/hooks.lua",
        Realm = "server",
    },
    {
        File = MODULE.path .. "/definitions/logs.lua",
        Realm = "server",
    },
}