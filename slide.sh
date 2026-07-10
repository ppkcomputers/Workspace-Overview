#!/usr/bin/env bash
QML_PATH="$HOME/.config/Quickshell/ActiveWorkspaces/shell.qml"

if pgrep -f "quickshell.*ActiveWorkspaces/shell.qml" >/dev/null; then
    pkill -USR1 -f "quickshell.*ActiveWorkspaces/shell.qml" 2>/dev/null || true
    exit 0
fi

QT_QUICK_BACKEND=software quickshell -p "$QML_PATH" &
