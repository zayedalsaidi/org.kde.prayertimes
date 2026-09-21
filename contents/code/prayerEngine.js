/*
 * SPDX-FileCopyrightText: 2026 Zayed Al-Saidi <zayed.alsaidi@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

// contents/code/prayerEngine.js
// محرك حساب مواقيت الصلاة - متوافق مع KDE Plasma 6 ومكتبة PrayTime.js v3.2
.import "praytime.js" as PT

/**
تهيئة وتجهيز كائن الحسابات وفق إعدادات المستخدم
*/
function initEngine(config) {
    var engine = PT.prayTimes;
    var method = config.calcMethod || "Custom";

    // 1. ضبط المعيار المخصص أو اختيار المعايير العالمية (بما فيها Oman)
    if (method === "Custom") {
        engine.method("MWL");
        engine.adjust({
            fajr: config.fajrAngle || 18.5,
            isha: config.ishaAngle || 18.0
        });
    } else {
        engine.method(method);
    }

    // 2. ضبط المذهب الفقهي لصلاة العصر
    var asrJuristic = (config.asrMethod === 1) ? 'Hanafi' : 'Standard';
    engine.adjust({ asr: asrJuristic });

    // 3. ⭐ ضبط طريقة الحساب للمناطق ذات خطوط العرض العالية
    var highLatsMethod = config.highLatsMethod || "NightMiddle";
    engine.adjust({ highLats: highLatsMethod });

    // 4. تطبيق الضبط الميداني ودقائق الاحتياط الشرعي
    engine.tune({
        fajr: config.fajrOffset || 0,
        dhuhr: config.dhuhrOffset || 0,
        asr: config.asrOffset || 0,
        maghrib: config.maghribOffset || 0,
        isha: config.ishaOffset || 0
    });

    return engine;
}

/**
🌍 دالة مساعدة: اكتشاف المنطقة الزمنية المحلية تلقائياً
*/
function detectLocalTimezone() {
    var offsetMinutes = new Date().getTimezoneOffset();
    var offsetHours = -offsetMinutes / 60;
    return offsetHours;
}

/**
حساب مواقيت الصلاة اليومية بناءً على الإحداثيات والتاريخ
*/
function calculateTimes(date, lat, lng, config) {
    var engine = initEngine(config);

    // ✅ قراءة صيغة الوقت من الإعدادات
    var timeFormat = config.timeFormat || '24h';

    // 🌍 اكتشاف المنطقة الزمنية تلقائياً
    var localTimezone = detectLocalTimezone();

    // ضبط الموقع، المنطقة الزمنية، وصيغة الوقت
    engine.location([lat, lng]);
    engine.utcOffset(localTimezone);
    engine.format(timeFormat);

    // حساب الأوقات للتاريخ المحدد
    var rawTimes = engine.times(date);

    var finalTimes = {
        fajr: rawTimes.fajr,
        sunrise: rawTimes.sunrise,
        dhuhr: rawTimes.dhuhr,
        asr: rawTimes.asr,
        maghrib: rawTimes.maghrib,
        isha: rawTimes.isha
    };

    // =========================================================
    // 📊 سجلات التحقق اليدوي
    // =========================================================
    console.log("==================================================");
    console.log("🕌 تفاصيل حساب مواقيت الصلاة (Debug Info)");
    console.log("--------------------------------------------------");
    console.log("📅 التاريخ المستخدم: ", date.toDateString());
    console.log("📍 الإحداثيات: خط العرض (Lat) = ", lat, " | خط الطول (Lng) = ", lng);
    console.log("🌍 المنطقة الزمنية المكتشفة (UTC Offset): ", localTimezone, " ساعات");
    console.log("⚙️ طريقة الحساب (Method): ", config.calcMethod);
    console.log("⚖️ مذهب العصر (Asr): ", config.asrMethod === 1 ? "Hanafi" : "Standard");
    
    // ⭐ عرض طريقة الحساب للمناطق ذات خطوط العرض العالية
    console.log("🌐 طريقة خطوط العرض العالية (HighLats): ", config.highLatsMethod || "NightMiddle");

    // ✅ عرض الزوايا الفعلية
    console.log("📐 الزوايا الفعلية (Active): الفجر =", engine.settings.fajr, "| العشاء =", engine.settings.isha);

    // عرض زوايا الواجهة فقط إذا كانت الطريقة مخصصة
    if (config.calcMethod === "Custom") {
        console.log("🛠️ زوايا الواجهة (UI Settings): الفجر =", config.fajrAngle, "| العشاء =", config.ishaAngle);
    }

    console.log("⏱️ فروق التوقيت (Offsets):", JSON.stringify({
        fajr: config.fajrOffset || 0,
        dhuhr: config.dhuhrOffset || 0,
        asr: config.asrOffset || 0,
        maghrib: config.maghribOffset || 0,
        isha: config.ishaOffset || 0
    }, null, 2));

    console.log("🕒 صيغة الوقت المطلوبة (Format):", timeFormat);
    console.log("✅ الأوقات المحسوبة النهائية:", JSON.stringify(finalTimes, null, 2));
    console.log("==================================================");

    return finalTimes;
}

/**
تحديد الصلاة القادمة والوقت المتبقي لها بالثواني
*/
function getNextPrayer(timesMap, now) {
    var prayerNames = ["fajr", "sunrise", "dhuhr", "asr", "maghrib", "isha"];
    var currentMinutes = now.getHours() * 60 + now.getMinutes();
    var currentSeconds = now.getSeconds();

    for (var i = 0; i < prayerNames.length; i++) {
        var pName = prayerNames[i];
        var timeStr = timesMap[pName];
        if (!timeStr || typeof timeStr !== 'string') continue;

        var parts = timeStr.split(":");
        var hour = parseInt(parts[0], 10);
        var minStr = parts[1] || "0";
        var minute = parseInt(minStr, 10);

        // معالجة ذكية لصيغة 12 ساعة
        if (minStr.indexOf("PM") !== -1 || minStr.indexOf("pm") !== -1 || minStr.indexOf("م") !== -1) {
            if (hour < 12) hour += 12;
        } else if (minStr.indexOf("AM") !== -1 || minStr.indexOf("am") !== -1 || minStr.indexOf("ص") !== -1) {
            if (hour === 12) hour = 0;
        }

        var pMinutes = hour * 60 + minute;

        if (pMinutes > currentMinutes) {
            var diffSeconds = (pMinutes - currentMinutes) * 60 - currentSeconds;
            return {
                name: pName,
                time: timeStr,
                remainingSeconds: diffSeconds
            };
        }
    }

    // إذا انتهت صلوات اليوم، تكون الصلاة القادمة هي فجر اليوم التالي
    var fajrStr = timesMap["fajr"] || "05:00";
    var fajrParts = fajrStr.split(":");
    var fajrHour = parseInt(fajrParts[0], 10);
    var fajrMinStr = fajrParts[1] || "0";
    var fajrMinute = parseInt(fajrMinStr, 10);

    if (fajrMinStr.indexOf("AM") !== -1 || fajrMinStr.indexOf("am") !== -1 || fajrMinStr.indexOf("ص") !== -1) {
        if (fajrHour === 12) fajrHour = 0;
    }

    var fajrMinutesTomorrow = (24 * 60) + (fajrHour * 60 + fajrMinute);
    var diffSecsNextDay = (fajrMinutesTomorrow - currentMinutes) * 60 - currentSeconds;

    return {
        name: "fajr",
        time: fajrStr,
        remainingSeconds: diffSecsNextDay
    };
}
