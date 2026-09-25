pragma ComponentBehavior: Bound

import "docker"
import QtQuick

import Caelestia.Config

Item {
    id: root

    implicitWidth: 840
    implicitHeight: 420

    DockerData {
        id: docker
    }

    ListView {
        id: containerList

        anchors.fill: parent

        model: docker.containers

        spacing:
            Tokens.spacing.medium

        clip: true

        visible:
            docker.containers.length > 0

        delegate: ContainerCard {
            required property var modelData

            width:
                containerList.width

            container:
                modelData

            stats:
                docker.statFor(
                    modelData.Names
                )

            busy:
                docker.isBusy(
                    modelData.ID
                )

            onRestartRequested:
                docker.restart(modelData)

            onLogsRequested:
                docker.openLogs(modelData)
        }
    }

    Loader {
        anchors.centerIn: parent

        active:
            docker.containers.length === 0

        asynchronous: true

        sourceComponent: EmptyState {}
    }
}
