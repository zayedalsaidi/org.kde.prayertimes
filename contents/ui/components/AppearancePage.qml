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

    property alias cfg_timeFormat: timeFormatCombo.currentValue

    Kirigami.FormLayout {
        width: root.availableWidth
        anchors.margins: Kirigami.Units.largeSpacing

        ComboBox {
            id: timeFormatCombo
            Kirigami.FormData.label: i18n("Time Format:")
            textRole: "text"
            valueRole: "value"
            model: [
                { text: i18n("24-hour (e.g., 14:30)"), value: "24h" },
                { text: i18n("12-hour with AM/PM (e.g., 02:30 PM)"), value: "12h" },
                { text: i18n("12-hour without AM/PM (e.g., 02:30)"), value: "12H" }
            ]
        }
    }
}
