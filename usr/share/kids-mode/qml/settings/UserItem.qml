import QtQuick 2.0
import Sailfish.Silica 1.0

Item 
{
    id: shortcutItem
    property alias title: title.text
    property alias color: icon.color
    property int userId
    height: icon.height
     
    Rectangle 
    {
        id: icon
        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        height: character.contentHeight
        width:  character.contentHeight
        Label
        {
            id: character
            anchors.centerIn: parent
            text: title.text.charAt(0)
            font.pixelSize: Theme.fontSizeExtraLarge
            font.bold: true
            color: "black"
        } 
    }

    Label 
    {
        id: title
        anchors {
            left: icon.right
            leftMargin: Theme.paddingLarge 
            right: actionIcon.left
            rightMargin: Theme.paddingLarge
            verticalCenter: parent.verticalCenter 
        }
        width: parent.width - 2*icon.width
        color: shortcutItem.highlighted ? Theme.highlightColor : Theme.primaryColor
        font.pixelSize: Theme.fontSizeMedium
        truncationMode: TruncationMode.Fade
        MouseArea 
        {
            anchors.fill: parent
            onClicked:{
                page.userId = userId 
                pageStack.push(userSettingsPage)
            }
        }
    }

    Image
    {
        id: actionIcon
        anchors {
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        width: icon.width
        source: "image://theme/icon-m-clear"
        MouseArea 
        {
            height: parent.height
            width: parent.width
            onClicked: remorse.execute(shortcutItem, qsTrId("removing-user"), function() {
                userGroup.path =  "/desktop/lipstick-jolla-home/kidsMode/" + userId
                userGroup.clear()
                userGroup.firstUse = true
                kmSettings.nUsers =kmSettings.nUsers  -1 
                updateUsers()
            })
        }
    }
    
    RemorseItem
    {
        id: remorse
    }
}

