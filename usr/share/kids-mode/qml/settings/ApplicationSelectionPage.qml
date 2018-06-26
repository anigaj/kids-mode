import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Lipstick 1.0
import com.jolla.settings 1.0
import org.nemomobile.configuration 1.0

Page 
{
    id: page
    property int userId
    
    ApplicationsGridView 
    {
        id: gridView

        header: Column {
            width: page.width
            spacing: Theme.paddingMedium
            transform: Translate { x:(gridView.width - page.width) / 2 }
            PageHeader 
            {
                    //% "Select applications"
                    title: qsTrId("select-applications")
            }
        }

        delegate: LauncherGridItem {
            id: appItem

            width: gridView.cellWidth
            height: gridView.cellHeight
            icon: iconId
            text: name
            enabled: true
            opacity: lockScreenShortcuts.value.indexOf(filePath) == -1 ? 1.0: 0.2
            onClicked: updateList()
            property bool isSelected: lockScreenShortcuts.value.indexOf(filePath) == -1  
            visible: filePath != "/usr/share/applications/kids-mode.desktop"
            function updateList()
            {
                var appList = lockScreenShortcuts.value
                var appNames = appTitles.value 
                if(!isSelected)
                {
                    var i = appList.indexOf(filePath)
                    appList.splice(i,1)
                    i = appNames.indexOf(name)
                    appNames.splice(i,1)
                    opacity=1.0
                }
                else 
                {
                    appList.push(filePath)
                    appNames.push(name)
                    opacity = 0.2
                }
                lockScreenShortcuts.value = appList
                appTitles.value = appNames
            } 
        }
    } 
               
   ConfigurationValue 
    {
        id: firstUse
        key: "/desktop/lipstick-jolla-home/kidsMode/"+page.userId+"/firstUse"
        defaultValue: true
    }
        
    ConfigurationValue 
    {
        id: lockScreenShortcuts

        key: "/desktop/lipstick-jolla-home/kidsMode/"+page.userId+"/appsList"
        defaultValue: []
    }
    ConfigurationValue 
    {
        id: appTitles

        key: "/desktop/lipstick-jolla-home/kidsMode/"+page.userId+"/appTitles"
        defaultValue: []
    }
}

