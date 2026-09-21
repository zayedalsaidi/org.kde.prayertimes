
#!/bin/bash

APP_ID="org.kde.prayertimes"
VERSION="1.0.0"

echo "1. جاري البحث عن ملفات الترجمة وتجميعها لجميع اللغات..."

# البحث عن كل ملفات .po في مجلد po/ أو مجلداته الفرعية
find po/ -name "*.po" | while read -r po_file; do
    # استخراج اسم اللغة من اسم الملف أو من اسم المجلد الفرعي
    # مثال: po/ar/plasma_applet_org.kde.prayertimes.po -> ar
    # أو: po/ar.po -> ar
    lang=$(basename "$po_file" .po)
    lang=${lang#plasma_applet_${APP_ID}_} # في حال كان اسم الملف يحتوي على الملحقة
    lang=$(echo "$lang" | sed 's/.*po\///;s/\/.*//') # استخراج المجلد إذا كان النظام po/ar/file.po

    # إذا كان اسم اللغة يحتوي على اسم Applet كامل، استخرج كود اللغة فقط (مثل ar أو fr)
    if [[ "$lang" == *"plasma_applet"* ]]; then
        lang=$(basename $(dirname "$po_file"))
    fi

    echo "   - تجميع ترجمة اللغة: $lang ($po_file)"

    # إنشاء مجلد Target للغة الحالية
    target_dir="locale/${lang}/LC_MESSAGES"
    mkdir -p "$target_dir"

    # تحويل ملف .po إلى .mo
    msgfmt "$po_file" -o "${target_dir}/plasma_applet_${APP_ID}.mo"
done

echo "2. تحزيم البلازمويد..."
rm -f "${APP_ID}-v${VERSION}.plasmoid"

zip -r "${APP_ID}-v${VERSION}.plasmoid" \
    contents/ \
    locale/ \
    metadata.json \
    LICENSE \
    -x "*.git*" "po/*" "build.sh"

echo "تم تجميع كل اللغات وتحزيم البلازمويد بنجاح: ${APP_ID}-v${VERSION}.plasmoid"
