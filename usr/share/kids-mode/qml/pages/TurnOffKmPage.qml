import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.4
import org.nemomobile.configuration 1.0

Page 
{
    id: page
    User
    {
        id: selectedUser
        anchors.centerIn: parent
        visible: !kmSettings.kmOn
        title: userName.value 
        color:  iconColor.value
        onVisibleChanged:{
            if(visible) growIcon.start()
            else {
                growIcon.stop()
                textSize = Theme.fontSizeExtraLarge*2
            }
        }
        textSize: Theme.fontSizeExtraLarge*2
        NumberAnimation
        {
            id: growIcon
            target: selectedUser
            property: "textSize"
            to: Theme.fontSizeSmall
            duration: 5000
        }
    }
    
    SilicaFlickable
    {
        anchors.fill: parent
        contentHeight: content.height

        Column
        {
            visible: kmSettings.kmOn
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
                //% "Click text to change user name or icon to change icon colour."
                text: qsTrId("change-user-name")
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
                    //label:qsTrId("change-user-name")
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
                    //% "Exit kids mode"
                    text: qsTrId("exit-kids-mode")
            }
            
            Button
             {
                 id: exitKm
                 visible: !kmSettings.pinActive                
                 //% "Exit kids mode"
                 text: qsTrId("exit-kids-mode")
                width: parent.width - 2*Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                  onClicked: exitKM()
            }
            
            TextField
            {
                id: pinEntry
                width: parent.width
                placeholderText: label
                //% "Enter pin to exit kids mode"
                label:qsTrId("exit-pin-kids-mode") 
                inputMethodHints:Qt.ImhDigitsOnly
                echoMode: TextInput.Password
                validator: RegExpValidator { regExp: /^[0-9 ]{,4}$/ }
                property bool pinEntered: text.length == 4           
                onPinEnteredChanged:  if(pinEntry.pinEntered && pinEntry.text == kmSettings.kmPin){
                    EnterKey.enabled = false
                    pinEntry.text = ""
                    exitKM()
                }
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
}
