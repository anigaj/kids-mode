import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.systemsettings 1.0
import org.nemomobile.configuration 1.0
import org.nemomobile.lipstick 0.1
import io.thp.pyotherside 1.4

Page 
{
    id: page
    property int userId
    
    SilicaFlickable 
    {
        anchors.fill: parent
        contentHeight: content.height + usersList.height + Theme.paddingLarge*2

        Column 
        {
            id: content

            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader 
            {
                //% "Kids mode"
                title: qsTrId("kids-mode")
            }
            
            SectionHeader 
            {
                    //% "Enter/Exit"
                    text: qsTrId("enter-exit")
            }               
            ComboBox
            {
                id: appCloseCombo
                //% "On entering kids mode"
                label: qsTrId("appClose-label")
                currentIndex: kmSettings.closeAllApps ?     0 : 1 
                menu: ContextMenu {
                    MenuItem 
                    {
                        property bool mode: true
                        //% "Close all applications"
                       text: qsTrId("close-all")
                    }
                    MenuItem 
                    {
                        property bool mode: false
                        //% "Hide applications"
                       text: qsTrId("hide-nonkm")
                    }   
                }
                onCurrentItemChanged: {
                       if (currentItem) {
                           kmSettings.closeAllApps = currentItem.mode
                       }
                   }
            }
            TextSwitch 
            {
                id: androidKmEnter
                //% "Stop android support on entering kids mode"
                text: qsTrId("android-onenter")
                checked: kmSettings.androidEnter
                onClicked: kmSettings.androidEnter = !kmSettings.androidEnter 
            }
            TextSwitch 
            {
                id: androidKmExit
                //% "Stop android support on exiting kids mode"
                text: qsTrId("android-onexit")
                checked: kmSettings.androidExit
                onClicked: kmSettings.androidExit = !kmSettings.androidExit 
            }
            TextSwitch 
            {
                id: pinSwitch
                //% "Require pin to exit kids mode"
                text: qsTrId("require-pin")
                checked: kmSettings.pinActive
                onClicked: {
                    if(! kmSettings.pinActive) 
                    {
                        checked = false
                        pageStack.push(pinEntry)
                    }
                    else 
                    {
                        kmSettings.pinActive = false
                        kmSettings.kmPin = "notset"
                    } 
                }
            }
            
            Button 
            {
                width: parent.width - 2* Theme.paddingLarge
               anchors.horizontalCenter: parent.horizontalCenter 
               //% "Change pin"
               text: qsTrId("change-pin")
               onClicked: pageStack.push(pinEntry)
               visible: kmSettings.pinActive 
            }
            SectionHeader
            {
                //% "Backups"
                text: qsTrId("backups")
            }
            Label 
            {
                anchors 
                {
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                }
                opacity: 0.6
                wrapMode: Text.Wrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                //% "The folder layout is backed up on first use. Click backup to backup current folder layout. If the launcher has not been restored as expected then click restore to restore layout from the last backup."
                text: qsTrId("backup-para")
            }
            Row
            {
                width: parent.width - 2* Theme.paddingLarge
                spacing: Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter 
                Button 
                {
                    width: parent.width/2 - Theme.paddingLarge/2 
                   //% "Backup"
                   text: qsTrId("backup")
                   onClicked: python.call('helper.backupInitial',[],function() {}) 
                }
                Button 
                {
                    width: parent.width/2 - Theme.paddingLarge/2 
                   //% "Restore"
                   text: qsTrId("restore")
                   onClicked: python.call('helper.restoreMainUser',['masterBackUp'],function(){
                        kmSettings.triggerLoad = !kmSettings.triggerLoad
                     /*   kmSettings.sync()
                        kmSettings.triggerLoad = false*/
                    }) 
                }
            }
            SectionHeader
            {
                //% "Users"
                text: qsTrId("users")
            }
            
            Button 
            {
                width: parent.width - 2* Theme.paddingLarge
               anchors.horizontalCenter: parent.horizontalCenter 
                //% "Add new user"
                text: qsTrId("add-new-user")
                onClicked: {
                    page.userId = getUserId()
                    kmSettings.nUsers =kmSettings.nUsers + 1 
                    pageStack.push(userSettingsPage)
                } 
            }
        }
        
        SilicaListView 
        {
            id: usersList
            model: users
            anchors.top: content.bottom
            anchors.topMargin: Theme.paddingMedium
            spacing: Theme.paddingSmall
            property real userHeight
            height: users.count*userHeight
            delegate: UserItem {
                id: user
                width: content.width
                title: model.userName
                userId: model.userId
                color: model.iconColor
                Component.onCompleted: usersList.userHeight = height
            }
        }
    }
    
    Component 
    {
        id: pinEntry

        PinEntryPage 
        {
            currentPin: kmSettings.kmPin 
            onPinChanged: { 
                kmSettings.kmPin = newPin
                kmSettings.pinActive = true
                pinSwitch.checked = true
            }
        }
    }
    
   Component 
    {
        id: userSettingsPage
        UserSettingsPage 
        {
            id: usPage
            userId: page.userId
        }
    }
    
    onStatusChanged:  if(status === PageStatus.Active) updateUsers() 

    function getUserId()
    {
        for(var i = 0; i < kmSettings.nUsers; ++i)
        {
            userGroup.path =  "/desktop/lipstick-jolla-home/kidsMode/" + i
            if(userGroup.firstUse) return i
        } 
        return kmSettings.nUsers
    } 
            
}
