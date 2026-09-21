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

    property alias cfg_calcMethod: calcMethodCombo.currentValue
    property alias cfg_asrMethod: asrMethodCombo.currentIndex
    property alias cfg_highLatsMethod: highLatsCombo.currentValue
    property alias cfg_fajrAngle: fajrAngleSpin.value
    property alias cfg_ishaAngle: ishaAngleSpin.value
    property alias cfg_fajrOffset: fajrOffsetSpin.value
    property alias cfg_dhuhrOffset: dhuhrOffsetSpin.value
    property alias cfg_asrOffset: asrOffsetSpin.value
    property alias cfg_maghribOffset: maghribOffsetSpin.value
    property alias cfg_ishaOffset: ishaOffsetSpin.value

    Kirigami.FormLayout {
        width: root.availableWidth
        anchors.margins: Kirigami.Units.largeSpacing

        ComboBox {
            id: calcMethodCombo
            Kirigami.FormData.label: i18n("Calculation Method:")
            textRole: "text"
            valueRole: "value"
            model: [
                { text: i18n("🇴🇲 Oman (Official Calendar)"), value: "Oman" },
                { text: i18n("Muslim World League"), value: "MWL" },
                { text: i18n("ISNA (North America)"), value: "ISNA" },
                { text: i18n("Egyptian General Authority"), value: "Egypt" },
                { text: i18n("Umm Al-Qura (Makkah)"), value: "Makkah" },
                { text: i18n("University of Islamic Sciences, Karachi"), value: "Karachi" },
                { text: i18n("Institute of Geophysics, Tehran"), value: "Tehran" },
                { text: i18n("Shia Ithna-Ashari (Jafari)"), value: "Jafari" },
                { text: i18n("France"), value: "France" },
                { text: i18n("Russia"), value: "Russia" },
                { text: i18n("Malaysia (JAKIM)"), value: "Malaysia" },
                { text: i18n("Singapore"), value: "Singapore" },
                { text: i18n("Custom Angles"), value: "Custom" }
            ]
        }
        ComboBox {
            id: asrMethodCombo
            Kirigami.FormData.label: i18n("Asr Juristic Method:")
            model: [
                i18n("Standard (Shafi, Maliki, Hanbali)"),
                i18n("Hanafi")
            ]
        }
        ComboBox {
            id: highLatsCombo
            Kirigami.FormData.label: i18n("Higher Latitudes Method:")
            textRole: "text"
            valueRole: "value"
            model: [
                { text: i18n("Night Middle (Recommended)"), value: "NightMiddle" },
                { text: i18n("One-Seventh of Night"), value: "OneSeventh" },
                { text: i18n("Angle-Based"), value: "AngleBased" },
                { text: i18n("None (No Adjustment)"), value: "None" }
            ]
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Manual Time Adjustments (Offsets)")
        }
        SpinBox { id: fajrOffsetSpin; Kirigami.FormData.label: i18n("Fajr Offset (min):"); from: -60; to: 60 }
        SpinBox { id: dhuhrOffsetSpin; Kirigami.FormData.label: i18n("Dhuhr Offset (min):"); from: -60; to: 60 }
        SpinBox { id: asrOffsetSpin; Kirigami.FormData.label: i18n("Asr Offset (min):"); from: -60; to: 60 }
        SpinBox { id: maghribOffsetSpin; Kirigami.FormData.label: i18n("Maghrib Offset (min):"); from: -60; to: 60 }
        SpinBox { id: ishaOffsetSpin; Kirigami.FormData.label: i18n("Isha Offset (min):"); from: -60; to: 60 }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Custom Calculation Angles")
        }
        SpinBox { id: fajrAngleSpin; Kirigami.FormData.label: i18n("Fajr Angle (x10):"); from: 0; to: 300 }
        SpinBox { id: ishaAngleSpin; Kirigami.FormData.label: i18n("Isha Angle (x10):"); from: 0; to: 300 }
    }
}
