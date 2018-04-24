import QtQuick 2.0
import Sailfish.Silica 1.0

Item 
{
    id: shortcutItem

    property alias title: title.text
    property alias color: icon.color
    property string actionIconSource
    property int userId

    function imageSource(path) 
    {
        var imagePath = path
        if (path && path[0] != '/' && path.indexOf("://") < 0) {
            imagePath = "image://theme/" + path
        }
        if (imagePath.length > 0) 
        {
            imagePath = imagePath + '?' + (shortcutItem.highlighted ? Theme.highlightColor : Theme.primaryColor)
        }
        return imagePath
    }

    height: Theme.itemSizeSmall

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
            leftMargin: icon.visible ? Theme.paddingLarge : 0
            right: actionIcon.left
            rightMargin: actionIcon.visible ? Theme.paddingLarge : 0
            verticalCenter: parent.verticalCenter
        }
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
        source: imageSource(shortcutItem.actionIconSource)
        visible: source != ''
        MouseArea 
        {
            anchors.fill: parent
            onClicked:{
                userGroup.path =  "/desktop/lipstick-jolla-home/kidsMode/" + userId
                userGroup.clear()
                userGroup.firstUse = true
                kmSettings.nUsers =kmSettings.nUsers  -1 
                page.updateUsers()
            }
        }
    }
}

