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
    ListModel 
    {
        id: users
    }
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
                //% "Kids mode"
                title: qsTrId("kids-mode")
            }
            
            SectionHeader 
            {
                    //% "Pin"
                    text: qsTrId("pin")
            }               
            TextSwitch 
            {
                id: pinSwitch
                //% "Require pin to exit kids mode"
                text: qsTrId("require-pin")
                checked: kmSettings.pinActive
                onClicked: {
                    if(! kmSettings.pinActive) 
                    {
                        checked = false
                        pageStack.push(pinEntry)
                    }
                    
                    else 
                    {
                        kmSettings.pinActive = false
                        kmSettings.kmPin = "notset"
                    } 
                }
            }
            Button 
            {
                width: parent.width - 2* Theme.paddingLarge
               anchors.horizontalCenter: parent.horizontalCenter 
               //% "change pin"
               text: qsTrId("change-pin")
               onClicked: pageStack.push(pinEntry)
               visible: kmSettings.pinActive 
            }
            SectionHeader
            {
                //% "Users"
                text: qsTrId("user")
            }
            Button 
            {
                width: parent.width - 2* Theme.paddingLarge
               anchors.horizontalCenter: parent.horizontalCenter 
                //% "Add new user"
                text: qsTrId("add-new-user")
                onClicked: {
                    page.userId = getUserId()
                    kmSettings.nUsers =kmSettings.nUsers + 1 
                    pageStack.push(userSettingsPage)
                } 
            }
            Repeater 
            {
                id: usersList
                model: users
                delegate: UserItem {
                    id: user
                    width: content.width
                    title: model.userName
                    actionIconSource: "icon-m-clear"
                    userId: model.userId
                    color: model.iconColor
                }
            }
        }
    }
    ConfigurationGroup
    {
        id: kmSettings
        path: "/desktop/lipstick-jolla-home/kidsMode"
        property bool pinActive: false
        property string kmPin: "notset"
        property int nUsers: 0
        
    }
    ConfigurationGroup
    {
        id: userGroup
        path: "/desktop/lipstick-jolla-home/kidsMode/0"
        property string userName:''
        property string iconColor: "#e60003"
        property bool firstUse: true
    }
    
    Component 
    {
        id: pinEntry

        PinEntryPage 
        {
            currentPin: kmSettings.kmPin 
            onPinChanged: { 
                kmSettings.kmPin = newPin
                kmSettings.pinActive = true
                pinSwitch.checked = true
            }
        }
    }
   Component 
    {
        id: userSettingsPage
        UserSettingsPage 
        {
            id: usPage
            userId: page.userId
        }
    }
    
    onStatusChanged:  if(status === PageStatus.Active) updateUsers() 

    function getUserId()
    {
        for(var i = 0; i < kmSettings.nUsers; ++i)
        {
            userGroup.path =  "/desktop/lipstick-jolla-home/kidsMode/" + i
            if(userGroup.firstUse) return i
        } 
        return kmSettings.nUsers
    } 
            
    function updateUsers()
    {
         users.clear()
        var i = 0
        var j = 0
        
        while( j < kmSettings.nUsers)
        {
            userGroup.path =  "/desktop/lipstick-jolla-home/kidsMode/" + i
            userGroup.sync()
            if(!userGroup.firstUse)
            {
               users.append({userId:i, userName:userGroup.userName , iconColor: userGroup.iconColor})
                j = j + 1
            }
            i = i +1
        }
    }
}
