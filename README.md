# kids-mode
Kids mode for sailfish OS

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
If the launcher folders aren't restored try a home screen restart. If that doesn't work then copy files in /home/nemo/.config/kids-mode/masterBackUp to  /home/nemo/.config/lipstick and restart home screen.

To-dos (time and ability permitting):
Don't show newly installed applications in kids mode as default behavioir.
User configurable notification settings. 
Look into whether running applications can be hidden instead of closed.
User changeable kids-mode ambiences.

How it works:
I have used the blacklisted applications list within launcher. For each user the applications that can't be shown are stored in dconf. Launcher has been patched to read the key and update the blacklisted applications when the kmon dconf key is set to true. Long press is also deactivated. The application.menu and folders are backed up. Folders are removed from application.menu xml and a patch of launchers allows this to be reloaded after km is turned on. Finally the swirther patch allows the application to trigger close all. 
For eventsview shortcuts the user settings are stored for the user in dconf and copied to the main events view dconf when kmon is set true.
When kmon is set to false everything is reverted.
File operations are done using python.

This may not be ghe most efficient or elegant solution but it works and meets my needs in only allowing selected applications to be used by the kids. Hopefully others will find it useful. Constructive feedback is welcome.