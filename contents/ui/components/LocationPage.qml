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

    property alias cfg_useAutoLocation: autoLocCheck.checked
    property alias cfg_latitude: latitudeField.text
    property alias cfg_longitude: longitudeField.text

    Kirigami.FormLayout {
        width: root.availableWidth
        anchors.margins: Kirigami.Units.largeSpacing

        CheckBox {
            id: autoLocCheck
            Kirigami.FormData.label: i18n("Location Source:")
            text: i18n("Use system location services (Recommended)")
        }
        TextField {
            id: latitudeField
            Kirigami.FormData.label: i18n("Latitude:")
            enabled: !autoLocCheck.checked
            placeholderText: "23.5880"
        }
        TextField {
            id: longitudeField
            Kirigami.FormData.label: i18n("Longitude:")
            enabled: !autoLocCheck.checked
            placeholderText: "58.3829"
        }
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            type: Kirigami.MessageType.Information
            visible: !autoLocCheck.checked
            text: i18n("💡 Tip: Open Google Maps, right-click on your location, and copy the numbers. Use a dot (.) for decimals.")
        }
    }
}
