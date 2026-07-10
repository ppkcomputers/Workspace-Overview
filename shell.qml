import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

ShellRoot {
    id: root

    // Function using your exact working Lua dispatcher syntax to step-increment desktops
    function moveWindowViaLua(hexAddress, currentWorkspaceId) {
        if (!hexAddress || hexAddress.length === 0) {
            console.log("[ERROR] Cannot move window: Address context is null.")
            return
        }

        // Ensure the hex address has the required '0x' prefix for your Lua function
        let formattedAddress = hexAddress.trim()
        if (!formattedAddress.startsWith("0x")) {
            formattedAddress = "0x" + formattedAddress
        }

        // Dynamically compute the next logical workspace target (1 -> 2, 2 -> 3, etc.)
        let targetWs = (currentWorkspaceId + 1).toString()

        // Assemble your native terminal dispatcher command
        let dispatchStr = "hl.dsp.window.move({ address = \"" + formattedAddress + "\", workspace = \"" + targetWs + "\", follow = false })"
        let cmdArgs = ["hyprctl", "dispatch", dispatchStr]

        console.log("[DEBUG] Executing Sequential Lua Migration:")
        console.log("  -> " + cmdArgs.join(" "))

        Quickshell.execDetached(cmdArgs)
    }

    PanelWindow {
        id: window

        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true

        exclusiveZone: 0
        color: "transparent"

        // Fullscreen dark overlay mask
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.4)
        }

        // Pulsing glow border
        Rectangle {
            id: glowEffect
            anchors.fill: body
            anchors.margins: -6
            radius: body.radius + 2
            color: "transparent"
            border.width: 4
            border.color: "#feffed"
            opacity: 0.8

            SequentialAnimation on opacity {
                running: true
                loops: Animation.Infinite
                NumberAnimation { to: 0.2; duration: 800; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 0.8; duration: 800; easing.type: Easing.InOutQuad }
            }
        }

        // Main OSD Panel
        Rectangle {
            id: body
            x: (parent.width - width) / 2
            y: -height

            width: parent.width * 0.90
            height: parent.height * 0.50
            radius: 16

            Behavior on y {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutCubic
                }
            }

            color: Qt.rgba(0.05, 0.05, 0.07, 0.94)
            border.width: 2
            border.color: "#7f7e52"

            Column {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.topMargin: 12
                anchors.rightMargin: 12
                anchors.bottomMargin: 1
                spacing: 1

                Flickable {
                    id: workspaceList
                    width: parent.width
                    height: parent.height
                    contentWidth: workspaceRow.width
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Row {
                        id: workspaceRow
                        height: parent.height
                        spacing: 20

                        Repeater {
                            model: Hyprland.workspaces

                            delegate: Rectangle {
                                id: workspaceCard

                                property int workspaceId: modelData.id
                                property var workspaceData: modelData

                                visible: workspaceId > 0
                                width: visible ? 280 : 0
                                height: visible ? parent.height - 10 : 0
                                radius: 10

                                color: workspaceId === Hyprland.focusedWorkspace.id ? Qt.rgba(207/255, 214/255, 153/255, 0.18) : Qt.rgba(255, 255, 255, 0.02)
                                border.color: workspaceId === Hyprland.focusedWorkspace.id ? "#cfd699" : "#575742"
                                border.width: workspaceId === Hyprland.focusedWorkspace.id ? 2 : 1

                                // --- UNIVERSAL CARD MOUSEAREA ---
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    z: 1

                                    onClicked: {
                                        body.y = -body.height
                                        delayTrigger.targetWs = workspaceCard.workspaceData
                                        delayTrigger.start()
                                    }
                                }

                                Rectangle {
                                    id: badge
                                    width: 32; height: 32; radius: 6
                                    x: 12; y: 12
                                    color: workspaceId === Hyprland.focusedWorkspace.id ? "#cfd699" : "#313244"
                                    z: 2

                                    Text {
                                        anchors.centerIn: parent
                                        text: workspaceId
                                        color: workspaceId === Hyprland.focusedWorkspace.id ? "#11111b" : "#cdd6f4"
                                        font.bold: true
                                        font.pixelSize: 14
                                    }
                                }

                                Flickable {
                                    anchors.top: badge.bottom
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    anchors.margins: 12
                                    contentHeight: windowLayout.height
                                    clip: true
                                    z: 2

                                    Column {
                                        id: windowLayout
                                        width: parent.width
                                        spacing: 5

                                        Text {
                                            text: "Windows:"
                                            color: "#a6adc8"
                                            font.pixelSize: 11
                                            font.bold: true
                                        }

                                        Repeater {
                                            model: modelData.toplevels

                                            delegate: Rectangle {
                                                id: appItem
                                                property var toplevelData: modelData
                                                width: parent.width
                                                height: 110
                                                color: Qt.rgba(0, 0, 0, 0.3)
                                                radius: 6
                                                clip: true

                                                border.color: appHover.hovered ? "#cfd699" : Qt.rgba(255, 255, 255, 0.1)
                                                border.width: appHover.hovered ? 2 : 1

                                                HoverHandler {
                                                    id: appHover
                                                }

                                                ScreencopyView {
                                                    anchors.fill: parent
                                                    anchors.margins: 2
                                                    captureSource: modelData.wayland
                                                    live: true
                                                    opacity: appHover.hovered ? 1.0 : 0.85
                                                }

                                                Rectangle {
                                                    anchors.bottom: parent.bottom
                                                    width: parent.width
                                                    height: 24
                                                    color: Qt.rgba(0.05, 0.05, 0.07, 0.85)

                                                    Text {
                                                        anchors.fill: parent
                                                        anchors.leftMargin: 8
                                                        anchors.rightMargin: 8
                                                        verticalAlignment: Text.AlignVCenter
                                                        text: modelData.appId ? modelData.appId : (modelData.title ? modelData.title : "Unknown App")
                                                        color: appHover.hovered ? "#feffed" : "#cdd6f4"
                                                        font.pixelSize: 11
                                                        font.family: "monospace"
                                                        elide: Text.ElideRight
                                                    }
                                                }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                                    cursorShape: Qt.PointingHandCursor

                                                    onClicked: (mouse) => {
                                                        if (mouse.button === Qt.RightButton) {
                                                            root.moveWindowViaLua(appItem.toplevelData.address, workspaceCard.workspaceId)
                                                        } else if (mouse.button === Qt.LeftButton) {
                                                            body.y = -body.height
                                                            delayTrigger.targetWs = workspaceCard.workspaceData
                                                            delayTrigger.start()
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
                }
            }
        }

        // Delay trigger for workspace switch + close
        Timer {
            id: delayTrigger
            property var targetWs: null
            interval: 400
            repeat: false
            onTriggered: {
                if (targetWs) targetWs.activate()
                    Qt.quit()
            }
        }

        // External toggle monitor
        Timer {
            id: externalToggleMonitor
            interval: 200
            running: true
            repeat: true
            property string flagPath: "/tmp/overview_exit_flag"
            onTriggered: {
                if (Qt.fileExists ? Qt.fileExists(flagPath) : false) {
                    externalToggleMonitor.running = false
                    body.y = -body.height
                    deferredShutdown.start()
                }
            }
        }

        // Clean shutdown
        Timer {
            id: deferredShutdown
            interval: 400
            repeat: false
            onTriggered: Qt.quit()
        }

        // Initial slide-in animation
        Timer {
            interval: 50
            running: true
            repeat: false
            onTriggered: {
                body.y = (window.height - body.height) / 2
            }
        }
    }
}
