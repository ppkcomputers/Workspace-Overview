# Hyprland Workspace Overview OSD - Hyproverview  

## Installation & Deployment  

## Run from terminal  

bash <(curl -sSL https://raw.githubusercontent.com/ppkcomputers/Workspace-Overview/main/install.sh)  

An interactive, fluid On-Screen Display (OSD) workspace overview dashboard built using the **Quickshell** framework, **QML**, and **Wayland Screencopy**. It interfaces directly with Hyprland data models and utilizes custom Lua dispatchers for seamless multi-workspace window migration.

![Preview Dashboard](https://github.com/ppkcomputers/Workspace-Overview/blob/main/2026-07-10-131925_hyprshot.png)

## Features

*   **Live Previews:** Displays high-performance, real-time window streams using native Wayland `ScreencopyView`.
*   **Intelligent Layout positioners:** Dynamically filters scratchpads, special, or background system workspaces seamlessly without layout distortion or padding anomalies.
*   **True Hybrid Navigation:** 
    *   **Left-Click:** Instantly transition focus to a target workspace.
    *   **Right-Click (On Window):** Migrate individual windows sequentially through desktop instances via an integrated Lua dispatcher mechanism.
*   **Fluid Animations:** Built-in slide-in panel easing transitions with a custom pulsing focus-ring aesthetic.
*   **External Signal Listener:** Monitors system flags (via `/tmp/overview_exit_flag`) for instant background toggle handling and clean service teardowns.



## Hyprland.lua keybinding  
-- Replace /path/to/script/ with the actual location of your file  

hl.bind("SUPER + O", hl.dsp.exec_cmd("bash /home/yourusername/.config/hypr/scripts/slide.sh"))

