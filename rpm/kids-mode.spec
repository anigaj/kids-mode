Name:          kids-mode
Version:       0.2
Release:       1
Summary:   Allows only selected applications to be made available to a user in launcher.
Group:         System/Patches
Vendor:        Anant Gajjar
Distribution:  SailfishOS
Packager: Anant Gajjar
License:       GPL
Requires: patchmanager
Requires: sailfish-version >= 2.1.4
Requires: pyotherside-qml-plugin-python3-qt5
Requires: libsailfishapp-launcher

BuildArch: noarch

%description
This is a patch and application that creates a kids mode. The patch modifies the launcher, eventsview, notifications and switcher code to allows the application to work.
 
When kids mode is activated for a user  only the configured applications can be seen in launcher and launched. Long press is disabled in launcher. In events view notifications are hidden and only the configured switches and actions are available in the pull down menu. Notification pop-upps are shown but can't be clicked.

When the user exits kids modes then the normal user settings are restored. A pin can be set to exit kids mode. 

Features:
- Multiple users can be created, each with own configuration for launcher and events view shortcuts.
- Can be activated and deactivated from the cover.
- Pin can be set to exit kids mode.

Notes:
Newly installed applications need to be unselected in settings otherwise they will show in kids mode.
The pin is stored as plain text in dconf and so not secure.
This may conflict with other  patches of launcher, switcher, notifications or eventsview.
If the launcher folders aren't restored then you can manually restore from the last backup in settings.

To-dos:
Don't show newly installed applications in kids mode as default behavioir. 
User configurable notification settings.
User changeable kids-mode ambiences.
%files
/usr/share/patchmanager/patches/*
/usr/share/applications/*
/usr/share/icons/hicolor/86x86/apps/*
/usr/share/kids-mode/*

%post
cd /usr/share/kids-mode/translations

currentlang1=$(grep LANG /var/lib/environment/nemo/locale.conf | cut -d= -f2 | cut -d. -f1)

currentlang2=$(grep LANG /var/lib/environment/nemo/locale.conf | cut -d= -f2 | cut -d_ -f1)

file1="kids-mode-${currentlang1}.qm"
file2="kids-mode-${currentlang2}.qm"

echo $file1
echo $file2

if [ ! -f $file1 ]  && [ ! -f $file2 ] 
then ln -s kids-mode.qm $file1
else echo "file exists" 
fi
 

%preun
 
if [ -f /usr/sbin/patchmanager ]; then
/usr/sbin/patchmanager -u kids-mode || true
/usr/sbin/patchmanager -u kids-mode-lc || true
fi
cd /usr/share/kids-mode/translations 

currentlang1=$(grep LANG /var/lib/environment/nemo/locale.conf | cut -d= -f2 | cut -d. -f1)

file1="kids-mode-${currentlang1}.qm"
if [ -L $file1 ]
then rm -f  $file1
fi

%postun
if [ $1 = 0 ]; then

rm -rf /usr/share/patchmanager/patches/kids-mode || true
su -l nemo -c  "dconf reset -f /desktop/lipstick-jolla-home/kidsMode/" || true
rm -rf /home/nemo/.config/kids-mode || true 

else
if [ $1 = 1 ]; then
 
echo "It's just upgrade"
fi
fi

%changelog
*Mon Mar 14 2015 Builder <builder@...>
0.2-1
- Added option to hide applications instead of closing them. Note: applications launched from a notification are still closed.
- Added option to manually back up and restore launcher layout from settings.
- Added option to stop android support on either entering or exiting kids mode.
- Added hungarian translation.
- Added a specific patch for users of launcher combined patch (works with patch from web catalog using patchmanager 3)
- bug fix to improve restoring of launcher when cancelled through remorse.
0.1-2
- bug fix: now shows english text if translation is not available instead of the translation id.
- Added translations for Dutch, Dutch(Belgium), French, Italian, Polish, Spanish and Swedish. 
0.1-1
- First build
