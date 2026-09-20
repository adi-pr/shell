import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    implicitWidth: 700
    implicitHeight: 500

    property bool port3000: false
    property bool port8000: false
    property var containers: []

    // Poll development services
    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            portProcess.running = true
            dockerProcess.running = true
        }
    }

    // Check development ports
    Process {
        id: portProcess

        command: [
            "sh",
            "-c",
            "ss -tulpn 2>/dev/null | grep -E ':3000 |:8000 '"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const output = text

                root.port3000 = output.includes(":3000")
                root.port8000 = output.includes(":8000")
            }
        }
    }

    // Get Docker containers
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

        // Header
        StyledRect {
            Layout.fillWidth: true
            implicitHeight: 80

            radius: Tokens.rounding.large
            color: Colours.palette.m3surfaceContainer

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Tokens.padding.large
                spacing: 4

                StyledText {
                    text: "Developer Dashboard"
                    font.pixelSize: 22
                    font.bold: true
                    color: Colours.palette.m3onSurface
                }

                StyledText {
                    text: "Development environment overview"
                    font.pixelSize: 13
                    color: Colours.palette.m3onSurfaceVariant
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.medium

            // Port 3000
            StyledRect {
                Layout.fillWidth: true
                implicitHeight: 100

                radius: Tokens.rounding.large
                color: root.port3000
                    ? Colours.palette.m3surfaceContainerHigh
                    : Colours.palette.m3surfaceContainer

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Tokens.padding.large
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true

                        StyledText {
                            text: "Port 3000"
                            font.bold: true
                            font.pixelSize: 15
                            color: Colours.palette.m3onSurface
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        StyledText {
                            text: root.port3000 ? "●" : "●"
                            color: root.port3000
                                ? Colours.palette.m3primary
                                : Colours.palette.m3error
                            font.pixelSize: 18
                        }
                    }

                    StyledText {
                        text: root.port3000 ? "Running" : "Offline"
                        color: Colours.palette.m3onSurfaceVariant
                        font.pixelSize: 12
                    }
                }
            }

            // Port 8000
            StyledRect {
                Layout.fillWidth: true
                implicitHeight: 100

                radius: Tokens.rounding.large
                color: root.port8000
                    ? Colours.palette.m3surfaceContainerHigh
                    : Colours.palette.m3surfaceContainer

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Tokens.padding.large
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true

                        StyledText {
                            text: "Port 8000"
                            font.bold: true
                            font.pixelSize: 15
                            color: Colours.palette.m3onSurface
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        StyledText {
                            text: "●"
                            color: root.port8000
                                ? Colours.palette.m3primary
                                : Colours.palette.m3error
                            font.pixelSize: 18
                        }
                    }

                    StyledText {
                        text: root.port8000 ? "Running" : "Offline"
                        color: Colours.palette.m3onSurfaceVariant
                        font.pixelSize: 12
                    }
                }
            }
        }

        // Docker
        StyledRect {
            Layout.fillWidth: true
            Layout.fillHeight: true

            radius: Tokens.rounding.large
            color: Colours.palette.m3surfaceContainer

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Tokens.padding.large
                spacing: Tokens.spacing.medium

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

                    StyledText {
                        text: `${root.containers.length} running`
                        color: Colours.palette.m3onSurfaceVariant
                        font.pixelSize: 12
                    }
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    model: root.containers

                    clip: true
                    spacing: 8

                    delegate: StyledRect {
                        required property var modelData

                        width: ListView.view.width
                        height: 56

                        radius: Tokens.rounding.medium
                        color: Colours.palette.m3surfaceContainerHigh

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
                                color: Colours.palette.m3primary
                            }
                        }
                    }
                }
            }
        }
    }
}