import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Lipstick 1.0
import com.jolla.settings 1.0

Page 
{
    id: page
    property string currentPin
    signal pinChanged(string newPin)

    function sendPin(newPin) 
    {
        pinChanged(newPin)
        pageStack.pop()
    }

    SilicaFlickable
    {
        anchors.fill: parent
        contentHeight: content.height
        
        Column 
        {
            id: content
            width: parent.width
                
            PageHeader 
            {
                    //% "Set pin"
                    title: qsTrId("set-pin")
            }
            
            SectionHeader 
            {
                //% "Current pin"
                text: qsTrId("current-pin")
                visible: page.currentPin != "notset"
            }                                  
            
            TextField 
            {
                id: currentPinEntry
                width: parent.width
                placeholderText: label
                //% "Current pin"          
                label:qsTrId("current-pin") 
                inputMethodHints:Qt.ImhDigitsOnly
                echoMode: TextInput.Password
                validator: RegExpValidator { regExp: /^[0-9 ]{,4}$/ }
                opacity: enabled? 1.0 : 0.4
                property bool pinEntered: text.length == 4           
                onPinEnteredChanged:  if(pinEntered && text == page.currentPin) {
                        enabled = false
                        newPin.focus = true
                }
                //since entering the correct pin doesn't require pressing enter then wrong pin must have been used if enter is pressed.
                EnterKey.onClicked: {
                    pinError.visible = true
                    page.focus = true
                }
                onActiveFocusChanged:{ if (activeFocus)pinError.visible =false
                else if(text != page.currentPin)pinError.visible =true
                } 
                visible:   page.currentPin != "notset"
            }
            SectionHeader 
            {
                //% "New pin"
                text: qsTrId("new-pin")
                visible: page.currentPin != "notset"
            }                                        
            TextField 
            {
                id: newPin
                width: parent.width
                placeholderText: label
                //% "New pin"
                label:qsTrId("new-pin") 
                inputMethodHints:Qt.ImhDigitsOnly
                echoMode: TextInput.Password
                validator: RegExpValidator { regExp: /^[0-9 ]{,4}$/ }
                opacity: enabled? 1.0 : 0.4
                onActiveFocusChanged: if (text.length == 4) {
                    verify.enabled = true
                    verify.focus = true
                }
                    
                EnterKey.onClicked: {
                    verify.enabled = true
                    verify.focus = true
                }
                enabled: (page.currentPin == "notset" || !currentPinEntry.enabled) 
            }
            
            TextField 
            {
                id: verify
                width: parent.width
                placeholderText: label
                //% "Verify pin"
                label:qsTrId("verify-pin") 
                inputMethodHints:Qt.ImhDigitsOnly
                echoMode: TextInput.Password
                validator: RegExpValidator { regExp: /^[0-9 ]{,4}$/ }
                opacity: enabled? 1.0 : 0.4
                property bool pinEntered: text.length == 4           
                onPinEnteredChanged:  if(pinEntered && text == newPin.text)sendPin(text) 
                //since entering the correct pin doesn't require pressing enter then wrong pin must have been used if enter is pressed.
                EnterKey.onClicked: {
                    pinError.visible = true
                    page.focus = true
                }
                onActiveFocusChanged: activeFocus ? pinError.visible =false :  pinError.visible =true 
                enabled: false 
            }
            
            Label
            {
                id: pinError
                 //% "Incorrect pin entered"
                 text:qsTrId("pin-error")
                 visible: false
            }
        }
    }
}

