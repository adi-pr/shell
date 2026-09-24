import QtQuick

import Caelestia.Config

import qs.components
import qs.services

/*
 * Lightweight metric.
 */
Row {
    id: root

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
            root.icon

        fontStyle:
            Tokens.font.icon.large

        color:
            root.colour
    }

    Column {
        anchors.verticalCenter:
            parent.verticalCenter

        spacing: 0

        StyledText {
            text:
                root.label

            font:
                Tokens.font.body.small

            color:
                Colours.palette
                    .m3onSurfaceVariant
        }

        StyledText {
            width: 160

            text:
                root.value

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
