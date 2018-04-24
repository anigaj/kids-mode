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
    property bool initialList: true
    height: content.height
    property string shortcutList: {
        var values = []
        values = values.concat(enabledShortcuts.values, enabledListShortcuts.values, enabledPageShortcuts.values)
        return enabledShortcuts.joined(values)
    }

    onShortcutListChanged: eventsScreenShortcutsEnabled.value =  shortcutList.length > 0
    Column 
    {
        id: content

        width: parent.width
        spacing: Theme.paddingMedium

        TextSwitch 
        {
            //% "Setting shortcuts"
            text: qsTrId("settings_events-la-settings_shortcuts")
            //% "Pick your favorite settings to be shown in events view. Current selection: %1"
            description: qsTrId("settings_events-la-settings_shortcuts_description").arg(shortcutList)
            automaticCheck: false
            checked: eventsScreenShortcutsEnabled.value && shortcutList.length > 0
            enabled: shortcutList.length > 0
            onClicked:eventsScreenShortcutsEnabled.value  = !eventsScreenShortcutsEnabled.value 
        }

        Button 
        {
            anchors.horizontalCenter: parent.horizontalCenter
            //% "Select shortcuts"
            text: qsTrId("settings_events-la-select_shortcuts")
            onClicked: pageStack.push(shortcutsSelector)
        }

        TextSwitch 
        {
            //% "Quick actions"
            text: qsTrId("settings_events-la-quick_actions")
            //% "Pick your favorite actions to be shown in events view. Current selection: %1"
            description: qsTrId("settings_events-la-quick_actions_description").arg(quickActionsModel.getQuickActionsList())
            automaticCheck: false
            checked: eventsScreenActionsEnabled.value && quickActions.value.length > 0
            enabled: quickActions.value.length > 0
            onClicked: eventsScreenActionsEnabled.value  = !eventsScreenActionsEnabled.value  
        }

        Button 
        {
            anchors.horizontalCenter: parent.horizontalCenter
            //% "Select actions"
            text: qsTrId("settings_events-la-select_actions")
            onClicked: pageStack.push(quickActionsSelector)
        }

        Item 
        {
            width: 1
            height: Theme.paddingLarge
        }
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
        id: eventsScreenShortcutsEnabled

        key: "/desktop/lipstick-jolla-home/kidsMode/"+page.userId+"/events_screen_shortcuts_enabled"
        defaultValue: true
    }

    ConfigurationValue 
    {
        id: eventsScreenActionsEnabled

        key: "/desktop/lipstick-jolla-home/kidsMode/"+page.userId+"/events_screen_actions_enabled"
        defaultValue: true
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

    ConfigurationValue 
    {
        id: quickActions

        key: "/desktop/lipstick-jolla-home/kidsMode/"+page.userId+"/events_screen_actions"
        defaultValue: []
        onValueChanged: eventsScreenActionsEnabled.value = value.length > 0      
/*        function updateList(filePath)
        {
            var actionList = value
            var i = actionList.indexOf(filePath)
            if(i != -1)actionList.splice(i,1)
            else actionList.push(filePath)
            
            value = actionList
            console.log(eventsScreenActionsEnabled.value)
            eventsScreenActionsEnabled.value = value.length > 0      
                        console.log(eventsScreenActionsEnabled.value) 
        }*/ 
    }

    FavoritesModel 
    {
        id: shortcutsModel

        filter: "grid_favorites_simple"
        showPotential: true
        key: "/desktop/lipstick-jolla-home/kidsMode/"+page.userId+"/events_screen_shortcuts"
        userModifiedKey: "/desktop/lipstick-jolla-home/kids-mode/"+page.userId+"/events_screen_shortcuts_user"
    }

    FavoritesModel 
    {
        id: shortcutsListModel

        filter: "list_favorites"
        showPotential: true
        path: "system_settings"
        key: "/desktop/lipstick-jolla-home/kidsMode/"+page.userId+"/events_screen_shortcuts"
        userModifiedKey: "/desktop/lipstick-jolla-home/kidsMode/"+page.userId+"/events_screen_shortcuts_user"
    }

    FavoritesModel 
    {
        id: shortcutsPageModel

        filter: "grid_favorites_page"
        showPotential: true
        path: "system_settings"
        key: "/desktop/lipstick-jolla-home/kidsMode/"+page.userId+"/events_screen_shortcuts"
        userModifiedKey: "/desktop/lipstick-jolla-home/kidsMode/"+page.userId+"/events_screen_shortcuts_user"
    }

    TitlesView 
    {
        id: enabledShortcuts

        model: shortcutsModel

        matchRole: "favorite"
        match: true
        role: "object.title"
    }

    TitlesView 
    {
        id: enabledPageShortcuts

        model: shortcutsPageModel

        matchRole: "favorite"
        match: true
        role: "object.title"
    }

    TitlesView 
    {
        id: enabledListShortcuts

        model: shortcutsListModel

        matchRole: "favorite"
        match: true
        role: "object.title"
    }

    QuickActionsModel 
    {
        id: quickActionsModel
        showPotential: true
        function getQuickActionsList() 
        {
            var values = ""
            var useCount = 1
            for (var i = 0; i < count; ++i) 
            {
                var item = quickActionsModel.get(i)
                if(quickActions.value.indexOf(item.path) != -1) 
                {
                    values = values + item.title
                    if( (quickActions.value.length - useCount)> 1) values = values + ", "
                    else if((quickActions.value.length - useCount) == 1) values = values + " and "
                    useCount = useCount + 1 
                }
            }        
            return values
        }
    }

    TitlesView 
    {
        id: enabledQuickActions

        model: quickActionsModel

        matchRole: "available"
        match: true
        role: "title"
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

    ConfigurationValue 
    {
        id: sidebarConfig
        key: "/desktop/lipstick-jolla-home/kidsMode/"+page.userId+"/events_screen_sidebar_enabled"
    }

    Component 
    {
        id: shortcutsSelector
        ShortcutsSelectionPage 
        {
            model: shortcutsModel
            pageModel: shortcutsPageModel
            // We currently don't allow list-type control in the sidebar (because they don't fit)
            listModel: sidebarConfig.value ? null : shortcutsListModel
        }
    }

    Component 
    {
        id: quickActionsSelector
        QuickActionsSelectionPage 
        {
            userId: page.userId
            model: quickActionsModel
        }
    }
}
