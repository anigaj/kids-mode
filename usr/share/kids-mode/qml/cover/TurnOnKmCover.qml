import QtQuick 2.2
import Sailfish.Silica 1.0
 Item
{
    Label
    {             
        id: labelText
            
        //% "Kids mode"
        text: qsTrId("kids-mode")    
        wrapMode: Text.WordWrap
        width:parent.width
        height: contentHeight
        anchors.top: parent.top
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Theme.fontSizeLarge
    }

    ListView 
    {
        id: usersListCover
        anchors.top: labelText.bottom
        anchors.topMargin:  Theme.paddingMedium
        height: parent.height - labelText.height 
        spacing : Theme.paddingMedium
        model: users
        highlight: Rectangle { color: Theme.highlightColor}
        highlightFollowsCurrentItem: true
        delegate: CoverUserItem {
            id: userItem
            width: content.width
            title: model.userName
            userId: model.userId
            color: model.iconColor
        }
    }
    
    CoverActionList
    {
        CoverAction
        {
            iconSource:"image://theme/icon-m-page-down"
            onTriggered: usersListCover.currentIndex == (users.count - 1)? usersListCover.currentIndex = 0 : usersListCover.currentIndex = usersListCover.currentIndex  + 1 
        }
        CoverAction
        {
            iconSource:"image://theme/icon-cover-play"
            onTriggered: {
                app.activate()
                enterKm(usersListCover.currentItem.userId)
            }
        }
    }
}
