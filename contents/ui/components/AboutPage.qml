/*
 * SPDX-FileCopyrightText: 2026 Zayed Al-Saidi <zayed.alsaidi@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ScrollView {
    id: root

    ColumnLayout {
        width: root.availableWidth
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Heading { level: 2; text: i18n("Prayer Times Plasmoid") }
        Label { text: i18n("Developer: Zayed Al-Saidi") }
        Label { text: i18n("License: GPL-3.0-or-later") }
        Label { text: i18n("Version: 1.0.0") }

        Kirigami.Separator { Layout.fillWidth: true }

        Label { text: i18n("Powered by PrayTime.js"); font.bold: true }
        Label {
            text: i18n("Note: PrayTime.js has been slightly modified to ensure full compatibility with the Qt/QML environment.")
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            opacity: 0.8
        }
        Button {
            text: i18n("Official Website")
            icon.name: "globe"
            onClicked: Qt.openUrlExternally("https://praytimes.org/")
        }
        Button {
            text: i18n("Calculation Documentation")
            icon.name: "document-properties"
            onClicked: Qt.openUrlExternally("https://praytimes.org/docs/calculation")
        }
        Button {
            text: i18n("Source Code (GitHub)")
            icon.name: "code-class"
            onClicked: Qt.openUrlExternally("https://github.com/zarrabi/praytime")
        }
        Label { text: i18n("PrayTime.js License: MIT License"); font.italic: true; opacity: 0.7 }
        Item { Layout.fillHeight: true }
    }
}
