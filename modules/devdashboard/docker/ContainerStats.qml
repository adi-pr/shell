import QtQuick
import QtQuick.Layouts

import Caelestia.Config

import qs.services

import "DockerUtils.js" as DockerUtils

/*
 * 2 x 2 grid:
 *
 * CPU      Memory
 * Uptime   Ports
 */
GridLayout {
    id: root

    required property var container
    property var stats: null

    columns: 2

    columnSpacing:
        Tokens.spacing.largeIncreased

    rowSpacing:
        Tokens.spacing.large

    StatItem {
        Layout.fillWidth: true

        icon:
            "speed"

        label:
            "CPU"

        value:
            root.stats
                && root.stats.CPUPerc
            ? root.stats.CPUPerc
            : "--"

        colour:
            Colours.palette.m3primary
    }

    StatItem {
        Layout.fillWidth: true

        icon:
            "memory"

        label:
            "Memory"

        value:
            root.stats
                && root.stats.MemUsage
            ? DockerUtils.cleanMemory(
                root.stats.MemUsage
            )
            : "--"

        colour:
            Colours.palette.m3secondary
    }

    StatItem {
        Layout.fillWidth: true

        icon:
            "schedule"

        label:
            "Uptime"

        value:
            root.container.RunningFor
            || "--"

        colour:
            Colours.palette.m3tertiary
    }

    StatItem {
        Layout.fillWidth: true

        icon:
            "lan"

        label:
            "Ports"

        value:
            DockerUtils.formatPorts(
                root.container.Ports
            )

        colour:
            Colours.palette.m3primary
    }
}
