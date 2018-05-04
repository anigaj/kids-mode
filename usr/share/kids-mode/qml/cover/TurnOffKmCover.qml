import QtQuick 2.2
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0

Column 
{
    id: coverContent
    width: parent.width
    property int pinChar: 0
    
    Label
    {             
        id: labelText          
        //% "Kids mode"
        text: qsTrId("kids-mode")    
        wrapMode: Text.WordWrap
        width:parent.width
        height: contentHeight
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Theme.fontSizeLarge
    }
    
    Row 
    {
        height: icon.height 
        width: parent.width-Theme.paddingLarge
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Theme.paddingSmall
        
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
                font.pixelSize: Theme.fontSizeMedium*2
                font.bold: true
                color: "black"
            }
        }
        
        Label 
        {
            id: userNameEntry
            width: parent.width - icon.width
            text: userName.value        
            color:  Theme.primaryColor
            font.pixelSize: Theme.fontSizeMedium 
        }
    }

    Grid
    {
        visible: kmSettings.pinActive
        columns: 4
        width: parent.width
        spacing: -Theme.paddingMedium
        Repeater
        {
            id: pinEntry
            model: 4
            TextField 
           {
                echoMode: TextInput.Password
                property int pinValue: 0
                text: pinValue
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
  
    CoverActionList
    {
        enabled: kmSettings.pinActive
        CoverAction
        {
            iconSource:"image://theme/icon-m-page-down"
            onTriggered:{
                var pinEntryItem =  pinEntry.itemAt(pinChar)
                pinEntryItem. echoMode = TextInput.Normal
                pinEntryItem.pinValue + 1 > 9 ? pinEntryItem.pinValue = 0 : pinEntryItem.pinValue = pinEntryItem.pinValue + 1 
            }
        }
        CoverAction
        {
            iconSource:"image://theme/icon-cover-play"
            onTriggered:{
                 var pinEntryItem =  pinEntry.itemAt(pinChar)
                pinEntryItem. echoMode = TextInput.Password
                if(pinChar + 1  > 3){
                    if(pinEntry.itemAt(0).text +pinEntry.itemAt(1).text + pinEntry.itemAt(2).text +  pinEntry.itemAt(3).text == kmSettings.kmPin) {
                        app.activate()
                        exitKM()
                    }
                    else pinChar = 0
                } 
                else pinChar = pinChar + 1
            }
        }
    }
    
    CoverActionList
    {
        enabled: !kmSettings.pinActive
        CoverAction
        {
            iconSource:"image://theme/icon-cover-play"
            onTriggered:{
                app.activate()
                exitKM()
            }
        }
    }  
}

