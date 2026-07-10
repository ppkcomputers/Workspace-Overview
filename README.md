# Workspace-Overview  

# Hyprland Workspace Overview OSD

An interactive, fluid On-Screen Display (OSD) workspace overview dashboard built using the **Quickshell** framework, **QML**, and **Wayland Screencopy**. It interfaces directly with Hyprland data models and utilizes custom Lua dispatchers for seamless multi-workspace window migration.

![Preview Dashboard](https://github.com/ppkcomputers/Workspace-Overview/raw/main/preview.png)

## Features

*   **Live Previews:** Displays high-performance, real-time window streams using native Wayland `ScreencopyView`.
*   **Intelligent Layout positioners:** Dynamically filters scratchpads, special, or background system workspaces seamlessly without layout distortion or padding anomalies.
*   **True Hybrid Navigation:** 
    *   **Left-Click:** Instantly transition focus to a target workspace.
    *   **Right-Click (On Window):** Migrate individual windows sequentially through desktop instances via an integrated Lua dispatcher mechanism.
*   **Fluid Animations:** Built-in slide-in panel easing transitions with a custom pulsing focus-ring aesthetic.
*   **External Signal Listener:** Monitors system flags (via `/tmp/overview_exit_flag`) for instant background toggle handling and clean service teardowns.

## Installation & Deployment

You can deploy this dashboard automatically directly into your shell profile config directory using our standalone runner script.

```bash
bash <(curl -sSL [https://raw.githubusercontent.com/ppkcomputers/Workspace-Overview/main/install.sh](https://raw.githubusercontent.com/ppkcomputers/Workspace-Overview/main/install.sh))

