import QtQuick 2.0
import Sailfish.Silica 1.0

Item 
{
    id: shortcutItem

    property alias title: title.text
    property alias color: icon.color
    property int userId

    height: col.height
    width: col.width
    Column
    {
        id: col
        height: icon.height + title.height
        width: icon.width
        Rectangle 
        {
            id: icon
            
            height: character.contentHeight
            width:  character.contentHeight
            Label
            {
                id: character
                anchors.centerIn: parent
                text: title.text.charAt(0)
                font.pixelSize: Theme.fontSizeExtraLarge*3
                font.bold: true
                color: "black"
            } 
        }

        Label 
        {
            id: title
            
           anchors.horizontalCenter: icon.horizontalCenter
        color:  Theme.primaryColor
        font.pixelSize: Theme.fontSizeExtraLarge
        truncationMode: TruncationMode.Fade
        }
    }
}

