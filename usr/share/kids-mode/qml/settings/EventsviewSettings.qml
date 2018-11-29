import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.systemsettings 1.0
import org.nemomobile.configuration 1.0
import org.nemomobile.lipstick 0.1

Item 
{
    id: page
    property int userId
    height: content.height
        
    Column 
    {
        id: content

        width: parent.width
        spacing: Theme.paddingMedium
        
        Label 
        {
            x: Theme.horizontalPageMargin
            width: parent.width - 2*x
            //: List of Events widgets that can be installed from store. %1 is replaced with a localised concatenation of widget names e.g: "Weather and Calendar".
            //% "Install %1 from Store."
            text: qsTrId("settings_events-la-install_from_store").arg(unavailableWidgets.value)
            visible: unavailableWidgets.value.length > 0
            wrapMode: Text.Wrap
            color: Theme.highlightColor
        }

        Repeater 
        {
            id: widgetsRepeater

            model: eventsWidgetsModel
            TextSwitch 
            {
                text: model.title
                description: model.description
                automaticCheck: false
                checked: eventsWidgets.value.indexOf(model.path)!= -1 
                enabled:model.available  
                onClicked: eventsWidgets.updateList(model.path)
            }
        }
    }

    ConfigurationValue 
    {
        id: eventsWidgets

        key: "/desktop/lipstick-jolla-home/kidsMode/"+page.userId+"/events_screen_widgets"
        defaultValue: []
             
        function updateList(filePath)
         {
            var widgetList = value
            var i = widgetList.indexOf(filePath)
            if(i != -1) widgetList.splice(i,1)
            else widgetList.push(filePath)
            
            value = widgetList
        } 
    }

    EventsWidgetsModel 
    {
        id: eventsWidgetsModel
    }

    Connections 
    {
        target: Qt.application
        onActiveChanged: {
            if (Qt.application.active)
                eventsWidgetsModel.updateAvailable()
        }
    }

    TitlesView 
    {
        id: unavailableWidgets

        model: eventsWidgetsModel

        matchRole: "available"
        match: false
        role: "title"
    }
}
