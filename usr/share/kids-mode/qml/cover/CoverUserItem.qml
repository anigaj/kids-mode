import QtQuick 2.0
import Sailfish.Silica 1.0

Item 
{
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
            font.pixelSize: Theme.fontSizeLarge
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
            verticalCenter: parent.verticalCenter
        }
        color:  Theme.primaryColor
        font.pixelSize: Theme.fontSizeMedium
        truncationMode: TruncationMode.Fade
    }
}

