import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground
{
    Label
    {
        id: label
        anchors.centerIn: parent
        //% "Kids mode"
        text: qsTrId("kids-mode")
        wrapMode: Text.WordWrap
        width:parent.width
    }
}
