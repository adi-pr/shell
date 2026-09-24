import QtQuick
import QtQuick.Layouts

import Caelestia.Config

import qs.components
import qs.services

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
