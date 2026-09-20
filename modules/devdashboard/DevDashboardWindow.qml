import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    implicitWidth: 700
    implicitHeight: 400

    property var containers: []

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            dockerProcess.running = true
        }
    }

    Process {
        id: dockerProcess

        command: [
            "sh",
            "-c",
            "docker ps --format '{{json .}}' 2>/dev/null"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                const result = []

                for (const line of lines) {
                    if (!line.trim())
                        continue

                    try {
                        result.push(JSON.parse(line))
                    } catch (e) {
                        console.log("Failed to parse Docker output:", line)
                    }
                }

                root.containers = result
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Tokens.spacing.medium

        StyledRect {
            Layout.fillWidth: true
            Layout.fillHeight: true

            radius: Tokens.rounding.large
            color: Colours.palette.m3surfaceContainer

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Tokens.padding.large
                spacing: Tokens.spacing.medium

                // Header + Badge
                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "Docker Containers"
                        font.pixelSize: 16
                        font.bold: true
                        color: Colours.palette.m3onSurface
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    StyledRect {
                        implicitHeight: 24
                        implicitWidth: countText.implicitWidth + 16
                        radius: Tokens.rounding.full
                        color: Colours.palette.m3surfaceContainerHigh

                        StyledText {
                            id: countText
                            anchors.centerIn: parent
                            text: `${root.containers.length} active`
                            color: Colours.palette.m3primary
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }
                }

                // Container ListView or Empty State
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ListView {
                        id: containerList
                        anchors.fill: parent
                        model: root.containers
                        clip: true
                        spacing: 8
                        visible: root.containers.length > 0

                        delegate: StyledRect {
                            required property var modelData

                            width: containerList.width
                            height: 52

                            radius: Tokens.rounding.medium
                            color: containerMouse.containsMouse 
                                ? Colours.palette.m3surfaceContainerHighest 
                                : Colours.palette.m3surfaceContainerHigh

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }

                            MouseArea {
                                id: containerMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    // Optional: Handle click event (e.g., open logs or toggle)
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Tokens.padding.medium
                                spacing: Tokens.spacing.medium

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    StyledText {
                                        text: modelData.Names || "Unknown"
                                        font.bold: true
                                        font.pixelSize: 13
                                        color: Colours.palette.m3onSurface
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    StyledText {
                                        text: modelData.Image || ""
                                        font.pixelSize: 11
                                        color: Colours.palette.m3onSurfaceVariant
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }

                                StyledText {
                                    text: modelData.Status || "Running"
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: Colours.palette.m3primary
                                }
                            }
                        }
                    }

                    // Fallback when no containers are running
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        visible: root.containers.length === 0

                        StyledText {
                            text: "🐳"
                            font.pixelSize: 28
                            Layout.alignment: Qt.AlignHCenter
                        }

                        StyledText {
                            text: "No active containers found"
                            color: Colours.palette.m3onSurfaceVariant
                            font.pixelSize: 13
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }
    }
}