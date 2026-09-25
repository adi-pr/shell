import QtQuick
import QtQuick.Layouts

import Caelestia.Config

import qs.components
import qs.services

StyledRect {
    id: root

    required property var container
    property var stats: null
    property bool busy

    signal restartRequested
    signal logsRequested

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

        ContainerInfo {
            Layout.preferredWidth: 245
            Layout.fillHeight: true

            container:
                root.container

            busy:
                root.busy

            onRestartRequested:
                root.restartRequested()

            onLogsRequested:
                root.logsRequested()
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

        ContainerStats {
            Layout.fillWidth: true
            Layout.fillHeight: true

            container:
                root.container

            stats:
                root.stats
        }
    }
}
