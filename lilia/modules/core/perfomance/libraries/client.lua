﻿function MODULE:InitPostEntity()
    hook.Remove("StartChat", "StartChatIndicator")
    hook.Remove("FinishChat", "EndChatIndicator")
    hook.Remove("PostPlayerDraw", "DarkRP_ChatIndicator")
    hook.Remove("CreateClientsideRagdoll", "DarkRP_ChatIndicator")
    hook.Remove("PostDrawEffects", "RenderWidgets")
    hook.Remove("PostDrawEffects", "RenderHalos")
    hook.Remove("OnEntityCreated", "WidgetInit")
    hook.Remove("GUIMousePressed", "SuperDOFMouseDown")
    hook.Remove("GUIMouseReleased", "SuperDOFMouseUp")
    hook.Remove("PreventScreenClicks", "SuperDOFPreventClicks")
    hook.Remove("Think", "DOFThink")
    hook.Remove("Think", "CheckSchedules")
    hook.Remove("NeedsDepthPass", "NeedsDepthPass_Bokeh")
    hook.Remove("RenderScene", "RenderSuperDoF")
    hook.Remove("RenderScene", "RenderStereoscopy")
    hook.Remove("PreRender", "PreRenderFrameBlend")
    hook.Remove("PostRender", "RenderFrameBlend")
    hook.Remove("RenderScreenspaceEffects", "RenderBokeh")
    timer.Remove("CheckHookTimes")
    timer.Remove("HostnameThink")
    RunConsoleCommand("gmod_mcore_test", "1")
    RunConsoleCommand("mem_max_heapsize", "131072")
    RunConsoleCommand("mem_max_heapsize_dedicated", "131072")
    RunConsoleCommand("mem_min_heapsize", "131072")
    RunConsoleCommand("threadpool_affinity", "64")
    RunConsoleCommand("mat_queue_mode", "2")
    RunConsoleCommand("mat_powersavingsmode", "0")
    RunConsoleCommand("r_queued_ropes", "1")
    RunConsoleCommand("r_threaded_renderables", "1")
    RunConsoleCommand("r_threaded_particles", "1")
    RunConsoleCommand("r_threaded_client_shadow_manager", "1")
    RunConsoleCommand("cl_threaded_client_leaf_system", "1")
    RunConsoleCommand("cl_threaded_bone_setup", "1")
    RunConsoleCommand("cl_forcepreload", "1")
    RunConsoleCommand("cl_lagcompensation", "1")
    RunConsoleCommand("cl_timeout", "3600")
    RunConsoleCommand("cl_smoothtime", "0.05")
    RunConsoleCommand("cl_localnetworkbackdoor", "1")
    RunConsoleCommand("cl_cmdrate", "66")
    RunConsoleCommand("cl_updaterate", "66")
    RunConsoleCommand("cl_interp_ratio", "2")
    RunConsoleCommand("studio_queue_mode", "1")
    RunConsoleCommand("ai_expression_optimization", "1")
    RunConsoleCommand("filesystem_max_stdio_read", "64")
    RunConsoleCommand("in_usekeyboardsampletime", "1")
    RunConsoleCommand("r_radiosity", "4")
    RunConsoleCommand("rate", "1048576")
    RunConsoleCommand("mat_frame_sync_enable", "0")
    RunConsoleCommand("mat_framebuffercopyoverlaysize", "0")
    RunConsoleCommand("mat_managedtextures", "0")
    RunConsoleCommand("fast_fogvolume", "1")
    RunConsoleCommand("lod_TransitionDist", "2000")
    RunConsoleCommand("filesystem_unbuffered_io", "0")
end

function MODULE:PostGamemodeLoaded()
    scripted_ents.GetStored("base_gmodentity").t.Think = nil
end

function MODULE:GrabEarAnimation()
    return nil
end

function MODULE:MouthMoveAnimation()
    return nil
end