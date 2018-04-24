import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0

Page 
{
    id: page
    property int userId
    property alias model: repeater.model
    
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
                //% "Select actions"
                title: qsTrId("settings_events-he-select_actions")
            }

            Flow 
            {
                width: parent.width

                Repeater 
                {
                    id: repeater

                    property real itemWidth: Screen.sizeCategory >= Screen.Large ? width/2 : width

                    width: parent.width
                    delegate: IconTextSwitch {
                        id: item
                        width: repeater.itemWidth
                        text: model.title
                        icon.source: {
                            if (model.icon && model.icon.indexOf("://") < 0) 
                            {
                                return "image://theme/" + model.icon
                            }
                            return model.icon
                        }
                        checked: quickActions.value.indexOf(model.path) != -1 
                        automaticCheck: false
                        onClicked: quickActions.updateList(model.path)
                    }
                }
            }
        }

        VerticalScrollDecorator {}
    }
    
    ConfigurationValue 
    {
        id: quickActions

        key: "/desktop/lipstick-jolla-home/kidsMode/"+page.userId+"/events_screen_actions"
        defaultValue: []
             
        function updateList(filePath)
        {
            var actionList = value
            var i = actionList.indexOf(filePath)
            if(i != -1)actionList.splice(i,1)
            else actionList.push(filePath)
            
            value = actionList
        } 
    }
}
