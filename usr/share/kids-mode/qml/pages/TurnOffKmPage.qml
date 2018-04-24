import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.4
import org.nemomobile.configuration 1.0

Page 
{
    id: page
    Timer 
    {
        id: closeAllTimer

        interval: 5000
        repeat: false
        triggeredOnStart: false

        onTriggered: {
           python.call('helper.restoreMainUser',[],function(){kmSettings.trigger= true})
            }
    }
    SilicaFlickable
    {
        anchors.fill: parent
        contentHeight: content.height

        Column
        {
            id: content
            width: parent.width
            spacing: Theme.paddingMedium
            
            PageHeader
            {
                //% "Kids mode"
                title: qsTrId("exit-kids-mode")
            }
            Row 
            {
                height: icon.height 
                width: parent.width
                Rectangle 
                {
                    id: icon
                    anchors.verticalCenter: parent.verticalCenter
                    height: character.contentHeight
                    width:  character.contentHeight
                    color: iconColor.value
                    Label
                    {
                        id: character
                        anchors.centerIn: parent
                        text: userNameEntry.text.charAt(0)
                        font.pixelSize: Theme.fontSizeExtraLarge*3
                        font.bold: true
                        color: "black"
                    }
                    Component
                    {
                        id: colorPicker
                        ColorPickerPage 
                        {
                            onColorClicked: {
                                iconColor.value = color
                                pageStack.pop()
                            }
                        }
                    }
                    MouseArea 
                    {
                            
                            anchors { 
                            margins: -Theme.paddingLarge 
                            fill: parent 
                            }
                            onClicked: pageStack.push(colorPicker)
                    } 
                }
                TextField 
                {
                    id: userNameEntry
                    width: parent.width - icon.width
                    placeholderText: label
                    //% "Click to change user name"
                    label:qsTrId("change-user-name")
                    text: userName.value        
                    color:  Theme.primaryColor
                    font.pixelSize: Theme.fontSizeExtraLarge 
           
                    EnterKey.onClicked: {
                        userName.value = text
                        page.focus = true
                    }
                    onActiveFocusChanged: if (!activeFocus)userName.value = text
                }
            }
            SectionHeader 
            {
                    //% "Exit kids modes"
                    text: qsTrId("exit-kids-modes")
            }
            Button
             {
                 id: exitKm
                 visible: !kmSettings.pinActive                
                 //% "Exit kids mode"
                 text: qsTrId("exit-kids-mode")
                  onClicked: exitKM()
            }
            
            TextField
            {
                id: pinEntry
                width: parent.width
                //% "Enter pin to exit kids mode"
                placeholderText: label
                label:qsTrId("exit-pin-kids-mode") 
                inputMethodHints:Qt.ImhDigitsOnly
                echoMode: TextInput.Password
                validator: RegExpValidator { regExp: /^[0-9 ]{,4}$/ }
                property bool pinEntered: text.length == 4           
                onPinEnteredChanged:  if(pinEntry.pinEntered && pinEntry.text == kmSettings.kmPin) exitKM()
                //since entering the correct pin doesn't require pressing enter then wrong pin must have been used if enter is pressed.
                EnterKey.onClicked: {
                    pinError.visible = true
                    page.focus = true
                }
                onActiveFocusChanged: if (activeFocus)pinError.visible =false 
                visible:  kmSettings.pinActive
            }
            Label
            {
                id: pinError
                anchors 
                {
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                }
                font.pixelSize: Theme.fontSizeLarge
                 //% "Incorrect pin entered"
                 text:qsTrId("pin-error")
                 visible: false
                color: Theme.highlightColor
            }
            Label
            {
                id: pinOk
                anchors 
                {
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                }
                font.pixelSize: Theme.fontSizeLarge
                 //% "Exiting kids mode"
                 text:qsTrId("km-exit")
                 visible: false
                color: Theme.highlightColor
            }
        }
    }
     
    ConfigurationGroup
    {
        id: mainUserBackUp
        path: "/desktop/lipstick-jolla-home/kidsMode/mainUser"
        property bool events_screen_shortcuts_enabled: false
        property bool events_screen_actions_enabled: false 
    }
    
    ConfigurationGroup
    {
        id: mainUser
        path: "/desktop/lipstick-jolla-home"
        property bool events_screen_shortcuts_enabled: false
        property bool events_screen_actions_enabled: false  
        function restoreMainUser ()
        {
             events_screen_shortcuts_enabled = mainUserBackUp.events_screen_shortcuts_enabled
            events_screen_actions_enabled = mainUserBackUp.events_screen_actions_enabled
            mainUserActions.value =  mainUserBuActions.value 
            mainUserShortcuts.value =  mainUserBuShortcuts.value
            mainUserWidgets.value =  mainUserBuWidgets.value
        }
    }
    //keep getting error trying to copy the arrays so have to use configuration values as a work around
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
    onStatusChanged:  if(status === PageStatus.Active){
        kmSettings.trigger = false
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
    ConfigurationGroup
    {
        id: kmSettings
        path: "/desktop/lipstick-jolla-home/kidsMode"
        property bool pinActive: false
        property string kmPin: "notset"
        property bool kmOn: true
        property int currentUser: 0
        property bool trigger: false
    }
    function exitKM()
    {
        pinOk.visible = true
        kmSettings.kmOn = false
        mainUser.restoreMainUser()
        closeAllTimer.start()
    }
}
