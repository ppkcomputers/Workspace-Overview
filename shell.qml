import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

ShellRoot {
    id: root

    function moveWindowViaLua(hexAddress, currentWorkspaceId) {
        if (!hexAddress || hexAddress.length === 0) return;
        let formattedAddress = hexAddress.trim().startsWith("0x") ? hexAddress.trim() : "0x" + hexAddress.trim();
        let targetWs = (currentWorkspaceId + 1).toString();
        let dispatchStr = "hl.dsp.window.move({ address = \"" + formattedAddress + "\", workspace = \"" + targetWs + "\", follow = false })";
        Quickshell.execDetached(["hyprctl", "dispatch", dispatchStr]);
    }

    PanelWindow {
        id: window
        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        exclusiveZone: 0
        color: "transparent"

        Rectangle { anchors.fill: parent; color: Qt.rgba(0, 0, 0, 0.4) }

        Rectangle {
            id: body
            x: (parent.width - width) / 2
            y: -height
            width: parent.width * 0.90
            height: parent.height * 0.50
            radius: 16
            Behavior on y { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
            color: Qt.rgba(0.05, 0.05, 0.07, 0.94)
            border.width: 2
            border.color: "#7f7e52"

            Column {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 1

                Flickable {
                    id: scrollArea
                    width: parent.width
                    height: parent.height
                    contentWidth: workspaceRow.width
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Row {
                        id: workspaceRow
                        height: parent.height
                        spacing: 20

                        // Standard Workspaces
                        Repeater {
                            model: Hyprland.workspaces
                            delegate: Rectangle {
                                id: wsCard
                                property var wsModel: modelData // Capture model data
                                visible: wsModel.id > 0
                                width: visible ? 280 : 0
                                height: visible ? parent.height - 10 : 0
                                radius: 10
                                color: wsModel.id === Hyprland.focusedWorkspace.id ? Qt.rgba(207/255, 214/255, 153/255, 0.18) : Qt.rgba(255, 255, 255, 0.02)
                                border.color: wsModel.id === Hyprland.focusedWorkspace.id ? "#cfd699" : "#575742"
                                border.width: 1

                                MouseArea { anchors.fill: parent; onClicked: { body.y = -body.height; delayTrigger.targetWs = wsModel; delayTrigger.start() } }

                                Rectangle {
                                    id: badge
                                    width: 32; height: 32; radius: 6; x: 12; y: 12
                                    color: wsModel.id === Hyprland.focusedWorkspace.id ? "#cfd699" : "#313244"
                                    Text { anchors.centerIn: parent; text: wsModel.id; color: wsModel.id === Hyprland.focusedWorkspace.id ? "#11111b" : "#cdd6f4"; font.bold: true; font.pixelSize: 14 }
                                }

                                Column {
                                    anchors { top: badge.bottom; left: parent.left; right: parent.right; bottom: parent.bottom; margins: 12 }
                                    spacing: 5
                                    Repeater {
                                        model: wsModel.toplevels
                                        delegate: Rectangle {
                                            id: appItem
                                            width: parent.width; height: 110; color: Qt.rgba(0, 0, 0, 0.3); radius: 6; clip: true
                                            border.color: appHover.hovered ? "#cfd699" : Qt.rgba(255, 255, 255, 0.1)
                                            border.width: appHover.hovered ? 2 : 1
                                            HoverHandler { id: appHover }
                                            ScreencopyView { anchors.fill: parent; anchors.margins: 2; captureSource: modelData.wayland; live: true; opacity: appHover.hovered ? 1.0 : 0.85 }

                                            MouseArea {
                                                anchors.fill: parent
                                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                                onClicked: (mouse) => {
                                                    if (mouse.button === Qt.RightButton) {
                                                        root.moveWindowViaLua(modelData.address, wsModel.id)
                                                    } else {
                                                        body.y = -body.height
                                                        delayTrigger.targetWs = wsModel
                                                        delayTrigger.start()
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                anchors.bottom: parent.bottom; width: parent.width; height: 24; color: Qt.rgba(0.05, 0.05, 0.07, 0.85)
                                                Text { anchors.fill: parent; anchors.leftMargin: 8; verticalAlignment: Text.AlignVCenter; text: modelData.appId || modelData.title || "Unknown"; color: appHover.hovered ? "#feffed" : "#cdd6f4"; font.pixelSize: 11; font.family: "monospace"; elide: Text.ElideRight }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Special Workspaces
                        Repeater {
                            model: Hyprland.workspaces
                            delegate: Rectangle {
                                id: specialCard
                                property var wsModel: modelData // Capture model data
                                visible: wsModel.id < 0
                                width: visible ? 280 : 0
                                height: visible ? parent.height - 10 : 0
                                radius: 10
                                color: Qt.rgba(137/255, 180/255, 250/255, 0.08)
                                border.color: "#89b4fa"
                                border.width: 3
                                z: 10

                                MouseArea { anchors.fill: parent; onClicked: { body.y = -body.height; delayTrigger.targetWs = wsModel; delayTrigger.start() } }

                                Rectangle {
                                    id: sBadge
                                    width: 70; height: 32; radius: 6; x: 12; y: 12
                                    color: "#89b4fa"
                                    Text { anchors.centerIn: parent; text: "Special"; color: "#11111b"; font.bold: true; font.pixelSize: 12 }
                                }

                                Column {
                                    anchors { top: sBadge.bottom; left: parent.left; right: parent.right; bottom: parent.bottom; margins: 12 }
                                    spacing: 5
                                    Repeater {
                                        model: wsModel.toplevels
                                        delegate: Rectangle {
                                            id: sAppItem
                                            width: parent.width; height: 110; color: Qt.rgba(0, 0, 0, 0.3); radius: 6; clip: true
                                            border.color: sAppHover.hovered ? "#89b4fa" : Qt.rgba(255, 255, 255, 0.1)
                                            border.width: sAppHover.hovered ? 2 : 1
                                            HoverHandler { id: sAppHover }
                                            ScreencopyView { anchors.fill: parent; anchors.margins: 2; captureSource: modelData.wayland; live: true; opacity: sAppHover.hovered ? 1.0 : 0.85 }

                                            MouseArea {
                                                anchors.fill: parent
                                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                                onClicked: (mouse) => {
                                                    if (mouse.button === Qt.RightButton) {
                                                        root.moveWindowViaLua(modelData.address, wsModel.id)
                                                    } else {
                                                        body.y = -body.height
                                                        delayTrigger.targetWs = wsModel
                                                        delayTrigger.start()
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                anchors.bottom: parent.bottom; width: parent.width; height: 24; color: Qt.rgba(0.05, 0.05, 0.07, 0.85)
                                                Text { anchors.fill: parent; anchors.leftMargin: 8; verticalAlignment: Text.AlignVCenter; text: modelData.appId || modelData.title || "Unknown"; color: sAppHover.hovered ? "#feffed" : "#cdd6f4"; font.pixelSize: 11; font.family: "monospace"; elide: Text.ElideRight }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Timer { id: delayTrigger; property var targetWs: null; interval: 400; onTriggered: { if (targetWs) targetWs.activate(); Qt.quit() } }
        Timer { interval: 50; running: true; onTriggered: body.y = (window.height - body.height) / 2 }
    }
}
