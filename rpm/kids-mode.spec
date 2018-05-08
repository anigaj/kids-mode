Name:          kids-mode
Version:       0.1
Release:       1
Summary:   Application thats allows only selected applications to be made available to a user.
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
 
In the application multiple users can be created and which applications and events view settings are available to each user can be configured. When kids mode is entered all existing applications visible in switcher are closed. For a selected user only the configured applications can be seen in launcher and launched. In events view notifications are hidden and only the configured switches and actions are available in the pull down menu.

When the user exits kids modes then the normal user settings are restored. A pin can be set to exit kids mode. 

Notes:
The pin is stored as plain text in dconf and so not secure.
This may conflict with other  patches of launcher, switcher, notifications or eventsview.
If the launcher folders aren't restored try a home screen restart. If that doesn't work then copy files in /home/nemo/.config/kids-mode/masterBackUp to  /home/nemo/.config/lipstick and restart home screen.

%files
/usr/share/patchmanager/patches/*
/usr/share/applications/*
/usr/share/icons/hicolor/86x86/apps/*
/usr/share/kids-mode/*

%post
%preun
 
if [ -f /usr/sbin/patchmanager ]; then
/usr/sbin/patchmanager -u kids-mode || true
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

0.1
- First build
