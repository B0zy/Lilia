local MODULE = MODULE
do
    hook.Add(
        "InitializedConfig",
        "liaChatOOC",
        function()
            lia.chat.register(
                "ooc",
                {
                    onCanSay = function(speaker, text)
                        local delay = CONFIG.OOCDelay
                        local oocmaxsize = CONFIG.OOCLimit
                        if GetGlobalBool("oocblocked", false) then
                            speaker:notify("The OOC is Globally Blocked!")

                            return false
                        end

                        if MODULE.oocBans[speaker:SteamID()] then
                            speaker:notify("You have been banned from using OOC!")

                            return false
                        end

                        if string.len(text) > oocmaxsize then
                            speaker:notify("Text too big!")

                            return false
                        end

                        if not speaker:IsAdmin() then
                            -- Only need to check the time if they have spoken in OOC chat before.
                            if delay > 0 and speaker.liaLastOOC then
                                local lastOOC = CurTime() - speaker.liaLastOOC
                                -- Use this method of checking time in case the oocDelay config changes.
                                if lastOOC <= delay then
                                    speaker:notifyLocalized("oocDelay", delay - math.ceil(lastOOC))

                                    return false
                                end
                            end
                        end

                        -- Save the last time they spoke in OOC.
                        speaker.liaLastOOC = CurTime()
                    end,
                    onChatAdd = function(speaker, text)
                        local icon = "icon16/user.png"
                        icon = Material(hook.Run("GetPlayerIcon", speaker) or icon)
                        chat.AddText(icon, Color(255, 50, 50), " [OOC] ", speaker, color_white, ": " .. text)
                    end,
                    prefix = {"//", "/ooc"},
                    noSpaceAfter = true,
                    filter = "ooc"
                }
            )
        end
    )
end
