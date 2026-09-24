.pragma library

/*
 * Pure formatting helpers for Docker data.
 */

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
 * Parses newline-delimited JSON output
 * from `docker ... --format '{{json .}}'`.
 */
function parseJsonLines(text, label) {
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
                "Failed to parse " + label + ":",
                line
            )
        }
    }

    return result
}
