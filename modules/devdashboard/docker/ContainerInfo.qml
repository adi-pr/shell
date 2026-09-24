import QtQuick
import QtQuick.Layouts

import Caelestia.Config

import qs.components
import qs.services

import "DockerUtils.js" as DockerUtils

/*
 * Container identity: name, image and state.
 */
ColumnLayout {
    id: root

    required property var container

    readonly property bool running:
        container.State === "running"

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
                root.running
                ? Colours.palette
                    .m3primary
                : Colours.palette
                    .m3outline
        }

        StyledText {
            text:
                root.container.State
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
        }
    }
}
