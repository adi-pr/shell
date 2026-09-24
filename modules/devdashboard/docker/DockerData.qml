import QtQuick

import Quickshell.Io

import "DockerUtils.js" as DockerUtils

/*
 * Polls docker for container metadata
 * and live resource statistics.
 */
Item {
    id: root

    property int interval: 3000

    property var containers: []
    property var statsByName: ({})

    function statFor(name) {
        if (!name)
            return null

        return root.statsByName[name] || null
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
