pragma ComponentBehavior: Bound

import QtQuick

import Quickshell
import Quickshell.Io

import Caelestia.Config

import "DockerUtils.js" as DockerUtils

/*
 * Polls docker for container metadata
 * and live resource statistics, and runs
 * actions against containers.
 */
Item {
    id: root

    property int interval: 3000

    property var containers: []
    property var statsByName: ({})

    /*
     * IDs of containers with an action
     * currently in flight.
     */
    property var busyIds: ({})

    function statFor(name) {
        if (!name)
            return null

        return root.statsByName[name] || null
    }

    function isBusy(id) {
        return !!root.busyIds[id]
    }

    function setBusy(id, busy) {
        const next =
            Object.assign({}, root.busyIds)

        if (busy)
            next[id] = true
        else
            delete next[id]

        root.busyIds = next
    }

    function refresh() {
        if (!dockerProcess.running)
            dockerProcess.running = true

        if (!statsProcess.running)
            statsProcess.running = true
    }

    function restart(container) {
        const id = container.ID

        if (!id || root.isBusy(id))
            return

        root.setBusy(id, true)

        const proc =
            restartComponent.createObject(root, {
                containerId: id,
                containerName: container.Names || id
            })

        proc.running = true
    }

    /*
     * Follows the container's logs in the
     * user's configured terminal.
     */
    function openLogs(container) {
        if (!container.ID)
            return

        Quickshell.execDetached([
            ...GlobalConfig.general.apps.terminal,
            "docker",
            "logs",
            "--follow",
            "--tail",
            "200",
            container.ID
        ])
    }

    /*
     * Both docker ps and docker stats update
     * on the same interval.
     */
    Timer {
        interval: root.interval
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: root.refresh()
    }

    /*
     * One-shot restart process, created
     * per request so several containers
     * can restart at once.
     */
    Component {
        id: restartComponent

        Process {
            id: restartProcess

            property string containerId
            property string containerName

            command: [
                "docker",
                "restart",
                containerId
            ]

            stderr: StdioCollector {
                id: restartErrors
            }

            onExited: exitCode => {
                root.setBusy(
                    restartProcess.containerId,
                    false
                )

                if (exitCode !== 0) {
                    Quickshell.execDetached([
                        "notify-send",
                        "-a",
                        "caelestia-shell",
                        "-u",
                        "critical",
                        "Failed to restart "
                            + restartProcess.containerName,
                        restartErrors.text.trim()
                            || "docker exited with code "
                                + exitCode
                    ])
                }

                root.refresh()
                restartProcess.destroy()
            }
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
                root.containers =
                    DockerUtils.parseJsonLines(
                        text,
                        "Docker output"
                    )
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
                const stats =
                    DockerUtils.parseJsonLines(
                        text,
                        "Docker stats"
                    )

                const result = {}

                for (const stat of stats) {
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
                }

                root.statsByName = result
            }
        }
    }
}
