import QtQuick
import QtQuick.Layouts

import Quickshell.Io

import Caelestia.Config

import qs.components
import qs.services

Item {
    id: root

    implicitWidth: 840
    implicitHeight: 420

    property var containers: []
    property var statsByName: ({})

    function shortImage(image) {
        if (!image)
            return "Unknown image"

        let name = image

        const slash = name.lastIndexOf("/")

        if (slash !== -1)
            name = name.substring(slash + 1)

        return name
    }

    function formatPorts(ports) {
        if (!ports || ports.trim() === "")
            return "None"

        const entries = ports.split(",")
        const formatted = []

        for (let entry of entries) {
            entry = entry.trim()

            const arrowIndex = entry.indexOf("->")

            if (arrowIndex !== -1) {
                const hostPart =
                    entry.substring(0, arrowIndex)

                const containerPart =
                    entry.substring(arrowIndex + 2)

                const hostMatch =
                    hostPart.match(/:(\d+)$/)

                const containerMatch =
                    containerPart.match(/^(\d+)/)

                if (hostMatch && containerMatch) {
                    const mapping =
                        hostMatch[1]
                        + " → "
                        + containerMatch[1]

                    if (formatted.indexOf(mapping) === -1)
                        formatted.push(mapping)

                    continue
                }
            }

            const internalMatch =
                entry.match(/^(\d+)/)

            if (internalMatch) {
                const port =
                    internalMatch[1]

                if (formatted.indexOf(port) === -1)
                    formatted.push(port)
            }
        }

        return formatted.length > 0
            ? formatted.join(" • ")
            : "None"
    }

    function statFor(name) {
        if (!name)
            return null

        return root.statsByName[name] || null
    }

    function cleanMemory(memUsage) {
        if (!memUsage)
            return "--"

        /*
         * docker stats returns values like:
         *
         * 342.4MiB / 31.27GiB
         *
         * We only show the used value to keep
         * the card compact.
         */
        const parts = memUsage.split("/")

        if (parts.length > 0)
            return parts[0].trim()

        return memUsage
    }

    /*
     * Main refresh timer.
     *
     * Both docker ps and docker stats update
     * every 3 seconds.
     */
    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            if (!dockerProcess.running)
                dockerProcess.running = true

            if (!statsProcess.running)
                statsProcess.running = true
        }
    }

    /*
     * Container metadata.
     */
    Process {
        id: dockerProcess

        command: [
            "sh",
            "-c",
            "docker ps --format '{{json .}}' 2>/dev/null"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines =
                    text.trim().split("\n")

                const result = []

                for (const line of lines) {
                    if (!line.trim())
                        continue

                    try {
                        result.push(
                            JSON.parse(line)
                        )
                    } catch (e) {
                        console.log(
                            "Failed to parse Docker output:",
                            line
                        )
                    }
                }

                root.containers = result
            }
        }
    }

    /*
     * Live resource statistics.
     */
    Process {
        id: statsProcess

        command: [
            "sh",
            "-c",
            "docker stats --no-stream --format '{{json .}}' 2>/dev/null"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines =
                    text.trim().split("\n")

                const result = {}

                for (const line of lines) {
                    if (!line.trim())
                        continue

                    try {
                        const stat =
                            JSON.parse(line)

                        /*
                         * Docker stats normally exposes
                         * Name.
                         *
                         * Keep Container as a fallback
                         * just in case.
                         */
                        const name =
                            stat.Name
                            || stat.Container

                        if (name)
                            result[name] = stat

                    } catch (e) {
                        console.log(
                            "Failed to parse Docker stats:",
                            line
                        )
                    }
                }

                root.statsByName = result
            }
        }
    }

    /*
     * Main content.
     *
     * No header. No overview.
     * Just useful data.
     */
    Item {
        anchors.fill: parent

        ListView {
            id: containerList

            anchors.fill: parent

            model: root.containers

            spacing:
                Tokens.spacing.medium

            clip: true

            visible:
                root.containers.length > 0

            delegate: StyledRect {
                id: containerCard

                required property var modelData
                required property int index

                readonly property var stats:
                    root.statFor(
                        modelData.Names
                    )

                width:
                    containerList.width

                height: 150

                radius:
                    Tokens.rounding.extraLarge

                color:
                    Colours.tPalette.m3surfaceContainer

                RowLayout {
                    anchors.fill: parent

                    anchors.leftMargin:
                        Tokens.padding.large

                    anchors.rightMargin:
                        Tokens.padding.large

                    anchors.topMargin:
                        Tokens.padding.medium

                    anchors.bottomMargin:
                        Tokens.padding.medium

                    spacing:
                        Tokens.spacing.largeIncreased

                    /*
                     * Container identity.
                     */
                    ColumnLayout {
                        Layout.preferredWidth: 245
                        Layout.fillHeight: true

                        spacing:
                            Tokens.spacing.small

                        RowLayout {
                            Layout.fillWidth: true

                            spacing:
                                Tokens.spacing.medium

                            MaterialIcon {
                                Layout.alignment:
                                    Qt.AlignVCenter

                                text:
                                    "deployed_code"

                                fontStyle:
                                    Tokens.font.icon
                                        .builders
                                        .extraLarge
                                        .scale(1.15)
                                        .build()

                                color:
                                    Colours.palette.m3primary
                            }

                            ColumnLayout {
                                Layout.fillWidth: true

                                spacing: 0

                                StyledText {
                                    Layout.fillWidth: true

                                    text:
                                        containerCard
                                            .modelData
                                            .Names
                                        || "Unknown"

                                    font:
                                        Tokens.font.body
                                            .builders
                                            .large
                                            .weight(
                                                Font.DemiBold
                                            )
                                            .build()

                                    color:
                                        Colours.palette
                                            .m3onSurface

                                    elide:
                                        Text.ElideRight
                                }

                                StyledText {
                                    Layout.fillWidth: true

                                    text:
                                        root.shortImage(
                                            containerCard
                                                .modelData
                                                .Image
                                        )

                                    font:
                                        Tokens.font.body.small

                                    color:
                                        Colours.palette
                                            .m3onSurfaceVariant

                                    opacity: 0.75

                                    elide:
                                        Text.ElideRight
                                }
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                        }

                        /*
                         * State.
                         */
                        Row {
                            spacing:
                                Tokens.spacing.small

                            StyledRect {
                                anchors.verticalCenter:
                                    parent.verticalCenter

                                width: 8
                                height: 8

                                radius: 99

                                color:
                                    containerCard
                                        .modelData
                                        .State === "running"
                                    ? Colours.palette
                                        .m3primary
                                    : Colours.palette
                                        .m3outline
                            }

                            StyledText {
                                text:
                                    containerCard
                                        .modelData
                                        .State
                                    || "unknown"

                                font:
                                    Tokens.font.body
                                        .builders
                                        .small
                                        .weight(
                                            Font.DemiBold
                                        )
                                        .build()

                                color:
                                    containerCard
                                        .modelData
                                        .State === "running"
                                    ? Colours.palette
                                        .m3primary
                                    : Colours.palette
                                        .m3onSurfaceVariant
                            }
                        }
                    }

                    /*
                     * Divider.
                     */
                    Rectangle {
                        Layout.fillHeight: true

                        Layout.preferredWidth: 1

                        color:
                            Colours.palette
                                .m3outlineVariant

                        opacity: 0.45
                    }

                    /*
                     * Stats.
                     *
                     * 2 x 2 grid:
                     *
                     * CPU      Memory
                     * Uptime   Ports
                     */
                    GridLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        columns: 2

                        columnSpacing:
                            Tokens.spacing.largeIncreased

                        rowSpacing:
                            Tokens.spacing.large

                        RawStat {
                            Layout.fillWidth: true

                            icon:
                                "speed"

                            label:
                                "CPU"

                            value:
                                containerCard.stats
                                    && containerCard.stats.CPUPerc
                                ? containerCard.stats.CPUPerc
                                : "--"

                            colour:
                                Colours.palette.m3primary
                        }

                        RawStat {
                            Layout.fillWidth: true

                            icon:
                                "memory"

                            label:
                                "Memory"

                            value:
                                containerCard.stats
                                    && containerCard.stats.MemUsage
                                ? root.cleanMemory(
                                    containerCard.stats.MemUsage
                                )
                                : "--"

                            colour:
                                Colours.palette.m3secondary
                        }

                        RawStat {
                            Layout.fillWidth: true

                            icon:
                                "schedule"

                            label:
                                "Uptime"

                            value:
                                containerCard
                                    .modelData
                                    .RunningFor
                                || "--"

                            colour:
                                Colours.palette.m3tertiary
                        }

                        RawStat {
                            Layout.fillWidth: true

                            icon:
                                "lan"

                            label:
                                "Ports"

                            value:
                                root.formatPorts(
                                    containerCard
                                        .modelData
                                        .Ports
                                )

                            colour:
                                Colours.palette.m3primary
                        }
                    }
                }
            }
        }

        /*
         * Empty state.
         */
        Loader {
            anchors.centerIn: parent

            active:
                root.containers.length === 0

            asynchronous: true

            sourceComponent:
                ColumnLayout {
                    spacing:
                        Tokens.spacing.medium

                    MaterialIcon {
                        Layout.alignment:
                            Qt.AlignHCenter

                        text:
                            "deployed_code"

                        fontStyle:
                            Tokens.font.icon
                                .builders
                                .extraLarge
                                .scale(2)
                                .build()

                        color:
                            Colours.palette
                                .m3onSurfaceVariant
                    }

                    StyledText {
                        Layout.alignment:
                            Qt.AlignHCenter

                        text:
                            "No containers running"

                        font:
                            Tokens.font.title.large

                        color:
                            Colours.palette
                                .m3onSurface
                    }

                    StyledText {
                        Layout.alignment:
                            Qt.AlignHCenter

                        text:
                            "Running containers will appear automatically"

                        font:
                            Tokens.font.body.small

                        color:
                            Colours.palette
                                .m3onSurfaceVariant
                    }
                }
        }
    }

    /*
     * Lightweight metric.
     */
    component RawStat: Row {
        id: stat

        property string icon
        property string label
        property string value
        property color colour

        spacing:
            Tokens.spacing.medium

        MaterialIcon {
            anchors.verticalCenter:
                parent.verticalCenter

            text:
                stat.icon

            fontStyle:
                Tokens.font.icon.large

            color:
                stat.colour
        }

        Column {
            anchors.verticalCenter:
                parent.verticalCenter

            spacing: 0

            StyledText {
                text:
                    stat.label

                font:
                    Tokens.font.body.small

                color:
                    Colours.palette
                        .m3onSurfaceVariant
            }

            StyledText {
                width: 160

                text:
                    stat.value

                font:
                    Tokens.font.body
                        .builders
                        .small
                        .weight(
                            Font.DemiBold
                        )
                        .build()

                color:
                    Colours.palette
                        .m3onSurface

                elide:
                    Text.ElideRight
            }
        }
    }
}