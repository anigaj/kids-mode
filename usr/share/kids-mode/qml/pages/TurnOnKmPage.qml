import QtQuick 2.2
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.4
import org.nemomobile.configuration 1.0
import "../settings"

Page 
{
    id: page

    Timer
     {
        id: noUserTimer
        repeat: false
        interval: 500
                
        onTriggered:   pageStack.push(kmSettingsPage)
    }
    
    User
    {
        id: selectedUser
        anchors.centerIn: parent
        visible: kmSettings.kmOn
        title: userName.value 
        color:  iconColor.value
        onVisibleChanged:{
            if(visible) growIcon.start()
            else {
                growIcon.stop()
                textSize = Theme.fontSizeSmall
            }
        }
        textSize: Theme.fontSizeSmall
        NumberAnimation
        {
            id: growIcon
            target: selectedUser
            property: "textSize"
            to: Theme.fontSizeExtraLarge*2
            duration: 5000
        }
    }
    
    SilicaFlickable
    {
        anchors.fill: parent
        contentHeight: content.height
        
        PullDownMenu
        {         
            MenuItem
            {
                id: settings
                //% "Settings" 
                text: qsTrId("Settings")
                onClicked: pageStack.push(kmSettingsPage)
            }
        }
        
        Column
        {
            visible: !kmSettings.kmOn
            id: content
            width: parent.width
            spacing: Theme.paddingMedium
            
            PageHeader
            {
                //% "Kids mode"
                title: qsTrId("kids-mode")
            }
            
            Label
            {
                id: noUsersText
                anchors 
                {
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                }
                font.pixelSize: Theme.fontSizeLarge
                 //% "Please add a user"
                 text:qsTrId("km-add-user")
                 visible: kmSettings.nUsers == 0 
                 color: Theme.highlightColor
                opacity: 1.0
                
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
                //% "Click on user to enter kids mode or use pulley menu to change settings."
                text: qsTrId("user-select-para")
            }

            Grid
            {
                columns: kmSettings.nUsers < 3 ?kmSettings.nUsers:3
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingMedium
                Repeater
                {
                    model: users 
                    delegate: User {
                        id: user
                        title: model.userName
                        userId: model.userId
                        color: model.iconColor
                        textSize: Theme.fontSizeExtraLarge
                        MouseArea
                        {
                            anchors.fill: parent
                            onClicked:{
                                buttonPress.start()
                                enterKm(userId)
                            }
                        }
                        SequentialAnimation
                        {
                            id: buttonPress
                            running: false
                            NumberAnimation
                            {
                                target: user
                                property: "opacity"
                                to: 0.0
                                duration: 100
                            }
                            NumberAnimation
                            {
                                target: user
                                property: "opacity"
                                to: 1.0
                                duration: 100
                            }    
                        }
                    }                  
                }
            }
        }
    }

    ConfigurationValue 
    {
        id: userName
        key: "/desktop/lipstick-jolla-home/kidsMode/"+kmSettings.currentUser+"/userName"
            defaultValue: ''
    }
    
    ConfigurationValue 
    {
        id: iconColor
        key: "/desktop/lipstick-jolla-home/kidsMode/"+kmSettings.currentUser+"/iconColor"
            defaultValue: "red"
    }
    
    Component 
    {
        id: kmSettingsPage
        MainSettingsPage { } 
    }
    
    onStatusChanged:  if(status === PageStatus.Active && kmSettings.nUsers == 0) python.call('helper.backupInitial',[],function() { noUserTimer.start()})
}
