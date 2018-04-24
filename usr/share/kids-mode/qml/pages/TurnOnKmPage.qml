import QtQuick 2.2
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.4
import org.nemomobile.configuration 1.0
import "../settings"

Page 
{
    id: page

    ListModel 
    {
        id: users
    }
    Timer 
    {
        id: closeAllTimer

        interval: 5000
        repeat: false
        triggeredOnStart: false

        onTriggered: {
            python.call('helper.restoreAppMenu',[],function() { kmSettings.trigger = true })
            }
    }
    Timer
     {
        id: noUserTimer
        repeat: false
        interval: 500
                
        onTriggered:   pageStack.push(kmSettingsPage)
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
            id: content
            width: parent.width
            spacing: Theme.paddingMedium
            
            PageHeader
            {
                //% "Enter kids mode"
                title: qsTrId("enter-kids-mode")
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
                text: qsTrId("selections-para")
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
            Label
            {
                id: enterKmLabel
                anchors 
                {
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                }
                font.pixelSize: Theme.fontSizeLarge
                 //% "Entering kids mode"
                 text:qsTrId("km-enter")
                 visible: false
                color: Theme.highlightColor
            }
        }
    }

    ConfigurationGroup
    {
        id: kmSettings
        path: "/desktop/lipstick-jolla-home/kidsMode"
        property bool pinActive: false
        property string kmPin: "notset"
        property bool kmOn: false
        property int nUsers: 0
        property int currentUser: 0
        property bool trigger: false
    }
    ConfigurationGroup
    {
        id: userGroup
        path: "/desktop/lipstick-jolla-home/kidsMode/0"
        property string userName:''
        property string iconColor: "#e60003"
        property bool firstUse: true
        property bool events_screen_shortcuts_enabled: false
        property bool events_screen_actions_enabled: false  
    }
    
    ConfigurationGroup
    {
        id: mainUserBackUp
        path: "/desktop/lipstick-jolla-home/kidsMode/mainUser"
        property bool events_screen_shortcuts_enabled: false
        property bool events_screen_actions_enabled: false 
        function backUpMainUser ()
        {
            events_screen_shortcuts_enabled = mainUser.events_screen_shortcuts_enabled
            events_screen_actions_enabled = mainUser.events_screen_actions_enabled
            mainUserBuActions.value =  mainUserActions.value 
            mainUserBuShortcuts.value =  mainUserShortcuts.value
            mainUserBuWidgets.value =  mainUserWidgets.value
        }
        
    }
    
    ConfigurationGroup
    {
        id: mainUser
        path: "/desktop/lipstick-jolla-home"
        property bool events_screen_shortcuts_enabled: false
property bool events_screen_actions_enabled: false  
        function copyKmUser ()
        {
            events_screen_shortcuts_enabled = userGroup.events_screen_shortcuts_enabled
            events_screen_actions_enabled = userGroup.events_screen_actions_enabled
            mainUserActions.value =  userGroupActions.value 
            mainUserShortcuts.value =  userGroupShortcuts.value
            mainUserWidgets.value =  userGroupWidgets.value
        }
        
    }
    //keep getting error trying to copy the arrays so have to use configuration values as a work around
    ConfigurationValue
    {
        id: userGroupActions
        key: "/desktop/lipstick-jolla-home/kidsMode/"+kmSettings.currentUser+"/events_screen_actions"
        defaultValue: []
    }
    ConfigurationValue
    {
        id: userGroupShortcuts
        key: "/desktop/lipstick-jolla-home/kidsMode/"+kmSettings.currentUser+"/events_screen_shortcuts"
        defaultValue: []
    }
    ConfigurationValue
    {
        id: userGroupWidgets
        key: "/desktop/lipstick-jolla-home/kidsMode/"+kmSettings.currentUser+"/events_screen_widgets"
        defaultValue: []
    }
    ConfigurationValue
    {
        id: mainUserActions
        key: "/desktop/lipstick-jolla-home/events_screen_actions"
        defaultValue: []
    }
    ConfigurationValue
    {
        id: mainUserShortcuts
        key: "/desktop/lipstick-jolla-home/events_screen_shortcuts"
        defaultValue: []
    }
    ConfigurationValue
    {
        id: mainUserWidgets
        key: "/desktop/lipstick-jolla-home/events_screen_widgets"
        defaultValue: []
    }
    ConfigurationValue
    {
        id: mainUserBuActions
        key: "/desktop/lipstick-jolla-home/kidsMode/mainUser/events_screen_actions"
        defaultValue: []
    }
    ConfigurationValue
    {
        id: mainUserBuShortcuts
        key: "/desktop/lipstick-jolla-home/kidsMode/mainUser/events_screen_shortcuts"
        defaultValue: []
    }
    ConfigurationValue
    {
        id: mainUserBuWidgets
        key: "/desktop/lipstick-jolla-home/kidsMode/mainUser/events_screen_widgets"
        defaultValue: []
    }
    Component 
    {
        id: kmSettingsPage
        MainSettingsPage { } 
    }
    onStatusChanged:  if(status === PageStatus.Active){
        if(kmSettings.nUsers == 0) noUserTimer.start()
         updateUsers()
         kmSettings.trigger = false
    }
    function enterKm(userId)
    {
        enterKmLabel.visible = true
        mainUserBackUp.backUpMainUser()
        userGroup.path =  "/desktop/lipstick-jolla-home/kidsMode/" + userId
        kmSettings.currentUser = userId
        mainUser.copyKmUser() 
        python.call('helper.backupMainUser',[],function  () {
                kmSettings.kmOn = true
                closeAllTimer.start()
             }       
        )
    }
    function updateUsers()
    {
        users.clear()
        var i = 0
        var j = 0
        
        while( j < kmSettings.nUsers)
        {
            userGroup.path =  "/desktop/lipstick-jolla-home/kidsMode/" + i
            userGroup.sync()
            if(!userGroup.firstUse)
            {
               users.append({userId:i, userName:userGroup.userName , iconColor: userGroup.iconColor})
                j = j + 1
            }
            i = i +1
        }
    }
}
