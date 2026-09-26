#pragma once

#include <qbytearray.h>
#include <qdatetime.h>
#include <qlist.h>
#include <qstring.h>

namespace caelestia::dev {

// One project from `dev project status --json`
struct Project {
    QString name;
    QString path;
    bool git = false;
    QString branch;
    bool dirty = false;
    QDateTime lastCommit;
    QString error;

    bool operator==(const Project& other) const = default;
};

// Turns the output of `dev project status --json` into projects. On bad input, returns an
// empty list and, if `error` isn't null, stores a message for the UI in it.
[[nodiscard]] QList<Project> parseProjects(const QByteArray& json, QString* error = nullptr);

} // namespace caelestia::dev
