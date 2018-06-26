import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.systemsettings 1.0
import org.nemomobile.configuration 1.0
import org.nemomobile.lipstick 0.1

Page 
{
    id: page
    property int userId
    
    SilicaFlickable 
    {
        anchors.fill: parent
        contentHeight: content.height

        Column 
        {
            id: content
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader 
            {
                //% "User settings"
                title: qsTrId("user-settings")
            }
            Row 
            {
                height: icon.height 
                width: parent.width
                Rectangle 
                {
                    id: icon
                    anchors.verticalCenter: parent.verticalCenter
                    height: character.contentHeight
                    width:  character.contentHeight
                    color: iconColor.value
                    Label
                    {
                        id: character
                        anchors.centerIn: parent
                        text: userNameEntry.text.charAt(0)
                        font.pixelSize: Theme.fontSizeExtraLarge
                        font.bold: true
                        color: "black"
                    }
                    Component
                    {
                        id: colorPicker
                        ColorPickerPage 
                        {
                            onColorClicked: {
                                iconColor.value = color
                                pageStack.pop()
                            }
                        }
                    }
                    MouseArea 
                    {
                            
                            anchors { 
                            margins: -Theme.paddingLarge 
                            fill: parent 
                            }
                            onClicked: pageStack.push(colorPicker)
                    } 
                }
                TextField 
                {
                    id: userNameEntry
                    width: parent.width - icon.width
                    placeholderText: label
                    //% "Enter user name"
                    label:qsTrId("enter-user-name")
                    text: userName.value            
                    EnterKey.onClicked: {
                        userName.value = text
                        page.focus = true
                    }
                    onActiveFocusChanged: if (!activeFocus)userName.value = text
                }
            }
            
            SectionHeader
            {
                    //% "Launcher"
                    text: qsTrId("launcher")
            } 
          
            Label 
            {
                anchors {
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                }
                opacity: 0.6
                wrapMode: Text.Wrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                //% "Select the applications that will be available in kids mode."
                text: qsTrId("selections-para")
            }

            Button 
            {
                width: parent.width - 2* Theme.paddingLarge
               anchors.horizontalCenter: parent.horizontalCenter 
                    //% "Select applications"
                    text: qsTrId("select-applications")
                    onClicked: pageStack.push(appSelector)
            }
            
            SectionHeader 
            {
                 //% "Events view"
                text: qsTrId("events-view")
            }
            
            Label 
            {               
                anchors {
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                }
                opacity: 0.6
                wrapMode: Text.Wrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                //% "Select the items that will be available in events view for  kids mode."
                text: qsTrId("events-para")
            }
            
            EventsviewSettings 
            {
                id: evSettings
                userId: page.userId
                width: parent.width
            }
        }
        
        VerticalScrollDecorator {}   
    }
    
    LauncherModel 
    {
        id: applicationModel

        function saveAppList ()
        {
            var appList = []
            var appNames = []
            for (var i = 0; i < itemCount; ++i) {
                var item = get(i)
                if(item.filePath != "/usr/share/applications/kids-mode.desktop"){
                     appList.push(item.filePath)
                    appNames.push(item.title)
                }
            }
            lockScreenShortcuts.value = appList
            appTitles.value = appNames
        }
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
   
     ConfigurationValue 
    {
        id: firstUse
        key: "/desktop/lipstick-jolla-home/kidsMode/"+page.userId+"/firstUse"
            defaultValue: true
    }
    
     ConfigurationValue 
    {
        id: userName
        key: "/desktop/lipstick-jolla-home/kidsMode/"+page.userId+"/userName"
            defaultValue: ''
    }
    
    ConfigurationValue 
    {
        id: iconColor
        key: "/desktop/lipstick-jolla-home/kidsMode/"+page.userId+"/iconColor"
            defaultValue: "red"
    }
    
    Component 
    {
        id: appSelector

        ApplicationSelectionPage 
        {
            userId: page.userId
        }
    }
    
    Component.onCompleted: if(firstUse.value) {
         applicationModel.saveAppList()
        firstUse.value = false
        iconColor.value = "red"
    }
}
