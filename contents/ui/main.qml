/*
 * SPDX-FileCopyrightText: 2026 Zayed Al-Saidi <zayed.alsaidi@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtPositioning
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

import "../code/prayerEngine.js" as Engine

PlasmoidItem {
    id: root
    Component.onCompleted: {
        i18n.domain = "plasma_applet_org.kde.prayertimes"
        root.updateTimes()
    }
    property var prayerTimes: ({})
    property var nextPrayerInfo: ({ name: "fajr", time: "--:--", remainingSeconds: 0 })

    // دالة مساعدة لضمان قراءة الإحداثيات كأرقام صحيحة
    function getValidCoord(val, defaultVal) {
        if (val === undefined || val === null || val === "") return defaultVal;
        var parsed = parseFloat(val);
        return isNaN(parsed) ? defaultVal : parsed;
    }

    property double activeLat: getValidCoord(Plasmoid.configuration ? Plasmoid.configuration.latitude : null, 23.5880)
    property double activeLng: getValidCoord(Plasmoid.configuration ? Plasmoid.configuration.longitude : null, 58.3829)

    function getPrayerName(key) {
        switch (key) {
            case "fajr":    return "🌙  " + i18n("Fajr");
            case "sunrise": return "🌅  " + i18n("Sunrise");
            case "dhuhr":   return "☀️  " + i18n("Dhuhr");
            case "asr":     return "⛅  " + i18n("Asr");
            case "maghrib": return "🌇  " + i18n("Maghrib");
            case "isha":    return "🌙  " + i18n("Isha");
            default:        return key || "";
        }
    }

    function formatCountdown(seconds) {
        if (!seconds || seconds <= 0) return "00:00";
        var h = Math.floor(seconds / 3600);
        var m = Math.floor((seconds % 3600) / 60);
        return (h < 10 ? "0" + h : h) + ":" + 
               (m < 10 ? "0" + m : m);
    }

    function updateTimes() {
        var now = new Date();
        
        if (Plasmoid.configuration && Plasmoid.configuration.useAutoLocation && posSource.position.coordinate.isValid) {
            root.activeLat = posSource.position.coordinate.latitude;
            root.activeLng = posSource.position.coordinate.longitude;
        } else {
            root.activeLat = getValidCoord(Plasmoid.configuration ? Plasmoid.configuration.latitude : null, 23.5880);
            root.activeLng = getValidCoord(Plasmoid.configuration ? Plasmoid.configuration.longitude : null, 58.3829);
        }

        var timeZoneOffset = -now.getTimezoneOffset() / 60.0;

        var config = {
            calcMethod: (Plasmoid.configuration && Plasmoid.configuration.calcMethod) ? Plasmoid.configuration.calcMethod : "Makkah",
            asrMethod: (Plasmoid.configuration && Plasmoid.configuration.asrMethod !== undefined) ? parseInt(Plasmoid.configuration.asrMethod) : 0,
            fajrAngle: getValidCoord(Plasmoid.configuration ? Plasmoid.configuration.fajrAngle : null, 185) / 10.0,
            ishaAngle: getValidCoord(Plasmoid.configuration ? Plasmoid.configuration.ishaAngle : null, 180) / 10.0,
            fajrOffset: getValidCoord(Plasmoid.configuration ? Plasmoid.configuration.fajrOffset : null, 0),
            dhuhrOffset: getValidCoord(Plasmoid.configuration ? Plasmoid.configuration.dhuhrOffset : null, 2),
            asrOffset: getValidCoord(Plasmoid.configuration ? Plasmoid.configuration.asrOffset : null, 0),
            maghribOffset: getValidCoord(Plasmoid.configuration ? Plasmoid.configuration.maghribOffset : null, 2),
            ishaOffset: getValidCoord(Plasmoid.configuration ? Plasmoid.configuration.ishaOffset : null, 2),
            timeFormat: (Plasmoid.configuration && Plasmoid.configuration.timeFormat) ? Plasmoid.configuration.timeFormat : "12h", 
            timeZone: timeZoneOffset,
            timeZoneOffset: timeZoneOffset
        };

        console.log("حساب المواقيت للإحداثيات:", root.activeLat, root.activeLng, "المنطقة الزمنية:", timeZoneOffset);

        root.prayerTimes = Engine.calculateTimes(now, root.activeLat, root.activeLng, config);
        root.nextPrayerInfo = Engine.getNextPrayer(root.prayerTimes, now);
    }

    PositionSource {
        id: posSource
        active: Plasmoid.configuration ? Plasmoid.configuration.useAutoLocation : false
        updateInterval: 3600000

        onPositionChanged: {
            if (position.coordinate.isValid) {
                root.updateTimes();
            }
        }
    }

    // ✅ FIXED TIMER: Reassign the object to trigger QML property change notifications
    Timer {
        id: mainTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            if (root.nextPrayerInfo && root.nextPrayerInfo.remainingSeconds > 0) {
                // Reassigning the entire object forces QML to emit the `nextPrayerInfoChanged` signal
                root.nextPrayerInfo = {
                    name: root.nextPrayerInfo.name,
                    time: root.nextPrayerInfo.time,
                    remainingSeconds: root.nextPrayerInfo.remainingSeconds - 1
                };
            } else {
                root.updateTimes();
            }
        }
    }

    // الربط مع تغييرات الإعدادات
    Connections {
        target: Plasmoid.configuration
        ignoreUnknownSignals: true

        function onLatitudeChanged() { root.updateTimes(); }
        function onLongitudeChanged() { root.updateTimes(); }
        function onCalcMethodChanged() { root.updateTimes(); }
        function onAsrMethodChanged() { root.updateTimes(); }
        function onUseAutoLocationChanged() { root.updateTimes(); }
        function onFajrOffsetChanged() { root.updateTimes(); }
        function onDhuhrOffsetChanged() { root.updateTimes(); }
        function onAsrOffsetChanged() { root.updateTimes(); }
        function onMaghribOffsetChanged() { root.updateTimes(); }
        function onIshaOffsetChanged() { root.updateTimes(); }
        function onTimeFormatChanged() { root.updateTimes(); }
    }

    compactRepresentation: Item {
        id: compactRoot
        property bool isHovered: false

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: compactRoot.isHovered = true
            onExited: compactRoot.isHovered = false
            onClicked: Plasmoid.expanded = !Plasmoid.expanded
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: Kirigami.Units.smallSpacing

            Text {
                text: "🕌"
                font.pixelSize: Kirigami.Units.iconSizes.small
                verticalAlignment: Text.AlignVCenter
                Layout.alignment: Qt.AlignVCenter
            }

            PlasmaComponents.ToolTip {
                visible: compactRoot.isHovered
                text: root.getPrayerName(root.nextPrayerInfo.name) + " " + (root.nextPrayerInfo.time || "--:--") + "\n" + 
                      i18n("remaining") + ": " + root.formatCountdown(root.nextPrayerInfo.remainingSeconds)
            }
        }
    }

    fullRepresentation: Item {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 16
        Layout.minimumHeight: Kirigami.Units.gridUnit * 22
        Layout.preferredWidth: Kirigami.Units.gridUnit * 18
        Layout.preferredHeight: Kirigami.Units.gridUnit * 26

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.mediumSpacing

            Kirigami.AbstractCard {
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 7

                background: Rectangle {
                    radius: Kirigami.Units.largeSpacing
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Kirigami.Theme.highlightColor }
                        GradientStop { position: 1.0; color: Qt.darker(Kirigami.Theme.highlightColor, 1.3) }
                    }
                }

                contentItem: RowLayout {
                    width: parent.width
                    height: parent.height
                    anchors.margins: Kirigami.Units.largeSpacing
                    spacing: Kirigami.Units.largeSpacing

                    ColumnLayout {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width * 0.4
                        spacing: Kirigami.Units.smallSpacing

                        PlasmaComponents.Label {
                            text: root.getPrayerName(root.nextPrayerInfo.name)
                            font.pixelSize: Kirigami.Units.gridUnit * 1.4
                            font.bold: true
                            color: Kirigami.Theme.highlightedTextColor
                        }

                        PlasmaComponents.Label {
                            text: i18n("Next Prayer")
                            font.pixelSize: Kirigami.Units.gridUnit * 0.8
                            color: Kirigami.Theme.highlightedTextColor
                            opacity: 0.8
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 1
                        color: Kirigami.Theme.highlightedTextColor
                        opacity: 0.3
                    }

                    ColumnLayout {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        Item { Layout.fillHeight: true }

                        PlasmaComponents.Label {
                            text: root.formatCountdown(root.nextPrayerInfo.remainingSeconds)
                            font.pixelSize: Kirigami.Units.gridUnit * 1.8
                            font.bold: true
                            font.family: "monospace"
                            color: Kirigami.Theme.highlightedTextColor
                            Layout.alignment: Qt.AlignHCenter
                        }

                        PlasmaComponents.Label {
                            text: i18n("remaining")
                            font.pixelSize: Kirigami.Units.gridUnit * 0.8
                            color: Kirigami.Theme.highlightedTextColor
                            opacity: 0.8
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Item { Layout.fillHeight: true }
                    }
                }
            }

            Kirigami.Separator { Layout.fillWidth: true }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    width: parent.width
                    spacing: Kirigami.Units.smallSpacing
                    Repeater {
                        model: ["fajr", "sunrise", "dhuhr", "asr", "maghrib", "isha"]

                        delegate: Rectangle {
                            required property string modelData
                            
                            Layout.fillWidth: true
                            implicitHeight: Kirigami.Units.gridUnit * 2.5
                            radius: Kirigami.Units.smallSpacing
                            
                            color: modelData === root.nextPrayerInfo.name ? 
                                   Kirigami.Theme.highlightColor : "transparent"

                            RowLayout {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.leftMargin: Kirigami.Units.largeSpacing
                                anchors.rightMargin: Kirigami.Units.largeSpacing
                                spacing: Kirigami.Units.mediumSpacing

                                PlasmaComponents.Label {
                                    text: root.getPrayerName(modelData)
                                    font.bold: modelData === root.nextPrayerInfo.name
                                    color: modelData === root.nextPrayerInfo.name ? 
                                           Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                                    Layout.minimumWidth: Kirigami.Units.gridUnit * 8
                                    Layout.maximumWidth: Kirigami.Units.gridUnit * 8
                                    Layout.preferredWidth: Kirigami.Units.gridUnit * 8
                                    horizontalAlignment: Text.AlignLeft
                                    verticalAlignment: Text.AlignVCenter
                                }

                                Item { Layout.fillWidth: true }

                                PlasmaComponents.Label {
                                    text: (root.prayerTimes && root.prayerTimes[modelData]) ? root.prayerTimes[modelData] : "--:--"
                                    font.bold: modelData === root.nextPrayerInfo.name
                                    font.family: "monospace"
                                    color: modelData === root.nextPrayerInfo.name ? 
                                           Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                                    Layout.minimumWidth: Kirigami.Units.gridUnit * 6
                                    Layout.maximumWidth: Kirigami.Units.gridUnit * 6
                                    Layout.preferredWidth: Kirigami.Units.gridUnit * 6
                                    horizontalAlignment: Text.AlignRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                    }
                }
            }

            PlasmaComponents.Label {
                text: i18n("Location: ") + root.activeLat.toFixed(3) + ", " + root.activeLng.toFixed(3)
                font.pixelSize: Kirigami.Units.gridUnit * 0.65
                opacity: 0.6
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
