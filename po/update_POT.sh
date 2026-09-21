# Update POT
xgettext --from-code=UTF-8 -C --kde -k=i18n -k=i18nc:1c,2 -k=i18np:1,2 \
  ../contents/ui/*.qml ../contents/code/*.js ../metadata.json -o plasma_applet_org.kde.prayertimes.pot

  
# Update po files without creating backup files
find . -name "*.po" -exec msgmerge -U --backup=none {} ./plasma_applet_org.kde.prayertimes.pot \;
