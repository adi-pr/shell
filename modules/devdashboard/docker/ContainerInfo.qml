import QtQuick
import QtQuick.Layouts

import Caelestia.Config

import qs.components
import qs.components.controls
import qs.services

import "DockerUtils.js" as DockerUtils

/*
 * Container identity: name, image, state
 * and actions.
 */
ColumnLayout {
    id: root

    required property var container
    property bool busy

    signal restartRequested
    signal logsRequested

    readonly property bool running:
        container.State === "running"
        && !busy

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
                    root.container.Names
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
                    DockerUtils.shortImage(
                        root.container.Image
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
     * State and actions.
     */
    RowLayout {
        Layout.fillWidth: true

        spacing:
            Tokens.spacing.small

        StyledRect {
            Layout.alignment:
                Qt.AlignVCenter

            implicitWidth: 8
            implicitHeight: 8

            radius: 99

            color:
                root.running
                ? Colours.palette
                    .m3primary
                : Colours.palette
                    .m3outline
        }

        StyledText {
            Layout.fillWidth: true

            text:
                root.busy
                ? "restarting…"
                : root.container.State
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
                root.running
                ? Colours.palette
                    .m3primary
                : Colours.palette
                    .m3onSurfaceVariant

            elide:
                Text.ElideRight
        }

        IconButton {
            type:
                IconButton.Text

            icon:
                "restart_alt"

            disabled:
                root.busy

            onClicked:
                root.restartRequested()
        }

        IconButton {
            type:
                IconButton.Text

            icon:
                "terminal"

            onClicked:
                root.logsRequested()
        }
    }
}
