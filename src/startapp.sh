#!/bin/sh
export HOME=/config

MEDIATHEKVIEW_DIR="/opt/MediathekView"
DOWNLOAD_DIR="/tmp"
UPDATES_XML_URL="https://download.mediathekview.de/stabil/updates-linux.xml"

# ENV auslesen, Standardwert ist latest
MEDIATHEK_VERSION="${MEDIATHEK_VERSION:-latest}"

# Funktion zum Abrufen der neuesten verfügbaren Version
get_latest_version() {
    wget -q "$UPDATES_XML_URL" -O "${DOWNLOAD_DIR}/updates-linux.xml"
    grep -oPm1 '(?<=newVersion=")[^"]+' "${DOWNLOAD_DIR}/updates-linux.xml"
}

# Version bestimmen
if [ "$MEDIATHEK_VERSION" = "latest" ]; then
    LATEST_VERSION=$(get_latest_version)
    echo "Neueste verfügbare Version ist: $LATEST_VERSION"
else
    LATEST_VERSION="$MEDIATHEK_VERSION"
    echo "Verwende explizit angegebene Version: $LATEST_VERSION"
fi

# Prüfen ob die Version bereits installiert ist
if [ -f "${MEDIATHEKVIEW_DIR}/current_version.txt" ] && [ "$(cat "${MEDIATHEKVIEW_DIR}/current_version.txt")" = "$LATEST_VERSION" ]; then
    echo "MediathekView Version ${LATEST_VERSION} bereits vorhanden. Kein Download nötig."
else
    echo "MediathekView Version ${LATEST_VERSION} wird heruntergeladen..."

    MEDIATHEKVIEW_URL="https://download.mediathekview.de/stabil/MediathekView-${LATEST_VERSION}-linux.tar.gz"

    # Altes Verzeichnis löschen und neu erstellen
    rm -rf "${MEDIATHEKVIEW_DIR:?}"/*
    mkdir -p "$MEDIATHEKVIEW_DIR"

    # Herunterladen und entpacken
    wget -q "${MEDIATHEKVIEW_URL}" -O "${DOWNLOAD_DIR}/MediathekView.tar.gz"
    tar xf "${DOWNLOAD_DIR}/MediathekView.tar.gz" -C "${MEDIATHEKVIEW_DIR}" --strip-components=1
    rm "${DOWNLOAD_DIR}/MediathekView.tar.gz"

    # Installierte Version speichern
    echo "$LATEST_VERSION" > "${MEDIATHEKVIEW_DIR}/current_version.txt"
fi

# MediathekView starten
/opt/MediathekView/MediathekView -m $HOME
