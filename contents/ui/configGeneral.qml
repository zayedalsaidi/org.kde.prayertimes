/*
 * SPDX-FileCopyrightText: 2026 Zayed Al-Saidi <zayed.alsaidi@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCMUtils

KCMUtils.SimpleKCM {
    id: configPage

    // ✅ إصلاح المحاذاة للغات من اليمين لليسار (العربية)
    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    Component.onCompleted: {
        i18n.domain = "plasmoid_org.kde.prayertimes"
    }

    // 1. الخصائص الأساسية
    property alias cfg_useAutoLocation: autoLocCheck.checked
    property alias cfg_latitude: latitudeField.text
    property alias cfg_longitude: longitudeField.text
    property alias cfg_timeFormat: timeFormatCombo.currentValue
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

    // 2. القيم الافتراضية
    property bool cfg_useAutoLocationDefault: true
    property string cfg_latitudeDefault: "23.5880"
    property string cfg_longitudeDefault: "58.3829"
    property string cfg_timeFormatDefault: "12h"
    property string cfg_calcMethodDefault: "Oman"
    property int cfg_asrMethodDefault: 0
    property string cfg_highLatsMethodDefault: "NightMiddle"
    property int cfg_fajrAngleDefault: 180
    property int cfg_ishaAngleDefault: 180
    property int cfg_fajrOffsetDefault: 0
    property int cfg_dhuhrOffsetDefault: 0
    property int cfg_asrOffsetDefault: 0
    property int cfg_maghribOffsetDefault: 0
    property int cfg_ishaOffsetDefault: 0

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TabBar {
            id: tabBar
            Layout.fillWidth: true

            TabButton { text: i18n("Location") }
            TabButton { text: i18n("Appearance") }
            TabButton { text: i18n("Calculation") }
            TabButton { text: i18n("About") }
        }

        StackLayout {
            id: contentStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex

            // --- تبويب الموقع ---
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: availableWidth   // ✅ ملء العرض كاملاً
                clip: true

                Kirigami.FormLayout {
                    width: parent.width
                    anchors.margins: Kirigami.Units.largeSpacing
                    CheckBox { id: autoLocCheck; Kirigami.FormData.label: i18n("Location Source:"); text: i18n("Use system location services (Recommended)") }
                    TextField { id: latitudeField; Kirigami.FormData.label: i18n("Latitude:"); enabled: !autoLocCheck.checked; placeholderText: "23.5880" }
                    TextField { id: longitudeField; Kirigami.FormData.label: i18n("Longitude:"); enabled: !autoLocCheck.checked; placeholderText: "58.3829" }
                    Kirigami.InlineMessage { Layout.fillWidth: true; type: Kirigami.MessageType.Information; visible: !autoLocCheck.checked; text: i18n("💡 Tip: Open Google Maps, right-click on your location, and copy the numbers.") }
                }
            }

            // --- تبويب العرض ---
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: availableWidth   // ✅ ملء العرض كاملاً
                clip: true

                Kirigami.FormLayout {
                    width: parent.width
                    anchors.margins: Kirigami.Units.largeSpacing
                    ComboBox {
                        id: timeFormatCombo
                        Kirigami.FormData.label: i18n("Time Format:")
                        textRole: "text"; valueRole: "value"
                        model: [
                            { text: i18n("24-hour (e.g., 14:30)"), value: "24h" },
                            { text: i18n("12-hour with AM/PM (e.g., 02:30 PM)"), value: "12h" },
                            { text: i18n("12-hour without AM/PM (e.g., 02:30)"), value: "12H" }
                        ]
                    }
                }
            }

            // --- تبويب الحسابات ---
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: availableWidth   // ✅ ملء العرض كاملاً
                clip: true

                Kirigami.FormLayout {
                    width: parent.width
                    anchors.margins: Kirigami.Units.largeSpacing
                    ComboBox {
                        id: calcMethodCombo
                        Kirigami.FormData.label: i18n("Calculation Method:")
                        textRole: "text"; valueRole: "value"
                        model: [
                            { text: i18n("🇴 Oman (Official Calendar)"), value: "Oman" },
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
                        model: [ i18n("Standard (Shafi, Maliki, Hanbali)"), i18n("Hanafi") ]
                    }
                    ComboBox {
                        id: highLatsCombo
                        Kirigami.FormData.label: i18n("Higher Latitudes Method:")
                        textRole: "text"; valueRole: "value"
                        model: [
                            { text: i18n("Night Middle (Recommended)"), value: "NightMiddle" },
                            { text: i18n("One-Seventh of Night"), value: "OneSeventh" },
                            { text: i18n("Angle-Based"), value: "AngleBased" },
                            { text: i18n("None (No Adjustment)"), value: "None" }
                        ]
                    }
                    Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Manual Time Adjustments (Offsets)") }
                    SpinBox { id: fajrOffsetSpin; Kirigami.FormData.label: i18n("Fajr Offset (min):"); from: -60; to: 60 }
                    SpinBox { id: dhuhrOffsetSpin; Kirigami.FormData.label: i18n("Dhuhr Offset (min):"); from: -60; to: 60 }
                    SpinBox { id: asrOffsetSpin; Kirigami.FormData.label: i18n("Asr Offset (min):"); from: -60; to: 60 }
                    SpinBox { id: maghribOffsetSpin; Kirigami.FormData.label: i18n("Maghrib Offset (min):"); from: -60; to: 60 }
                    SpinBox { id: ishaOffsetSpin; Kirigami.FormData.label: i18n("Isha Offset (min):"); from: -60; to: 60 }
                    Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Custom Calculation Angles") }
                    SpinBox { id: fajrAngleSpin; Kirigami.FormData.label: i18n("Fajr Angle (x10):"); from: 0; to: 300 }
                    SpinBox { id: ishaAngleSpin; Kirigami.FormData.label: i18n("Isha Angle (x10):"); from: 0; to: 300 }
                }
            }

            // --- تبويب حول ---
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: availableWidth   // ✅ ملء العرض كاملاً
                clip: true

                ColumnLayout {
                    width: parent.width
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
                    Button { text: i18n("Official Website"); icon.name: "globe"; onClicked: Qt.openUrlExternally("https://praytimes.org/") }
                    Button { text: i18n("Calculation Documentation"); icon.name: "document-properties"; onClicked: Qt.openUrlExternally("https://praytimes.org/docs/calculation") }
                    Button { text: i18n("Source Code (GitHub)"); icon.name: "code-class"; onClicked: Qt.openUrlExternally("https://github.com/zarrabi/praytime") }
                    Label { text: i18n("PrayTime.js License: MIT License"); font.italic: true; opacity: 0.7 }
                    Item { Layout.fillHeight: true }
                }
            }
        }
    }
}
