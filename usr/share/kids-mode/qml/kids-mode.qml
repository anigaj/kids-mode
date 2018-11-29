import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.4
import org.nemomobile.configuration 1.0
import org.nemomobile.lipstick 0.1
import org.nemomobile.dbus 2.0
import "pages"
import "settings"

ApplicationWindow
{
    id: app
    ListModel 
    {
        id: users
    }
    
    initialPage: kmSettings.kmOn ? kmRunning : kmNotRunning 
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    Component.onCompleted: updateUsers()
    
    Component 
    {
        id: kmRunning 
        TurnOffKmPage { } 
    }
    
    Component 
    {
        id: kmNotRunning 
        TurnOnKmPage { } 
    }
    
    Python
    {
        id: python
        Component.onCompleted: 
        {
            addImportPath(Qt.resolvedUrl('.'));
            importModule('helper', function () {});
        }
    }
    LauncherModel 
    {
        id: appModel

        function updateAppTitles ()
        {
            var appNames = []
            for (var i = 0; i < itemCount; ++i) {
                var item = get(i)
                if(appsList.value.indexOf(item.filePath) != -1) appNames.push(item.title)
            }
            appTitles.value = appNames
        }
    }

    DBusInterface 
    {
        id: apkInterface

        bus: DBus.SystemBus
        service: "com.jolla.apkd"
        path: "/com/jolla/apkd"
        iface: "com.jolla.apkd"
    }
    
    ConfigurationValue 
    {
        id: appsList

        key: "/desktop/lipstick-jolla-home/kidsMode/"+kmSettings.currentUser+"/appsList"
        defaultValue: []
    }
    
   ConfigurationValue 
    {
        id: appTitles

        key: "/desktop/lipstick-jolla-home/kidsMode/"+kmSettings.currentUser+"/appTitles"
        defaultValue: []
    }    
    
    ConfigurationValue 
    {
        id: mainAmbiences

        key: "/desktop/lipstick-jolla-home/kidsMode/mainAmbiences"
        defaultValue: []
    }    
    ConfigurationValue 
    {
        id: kmAmbiences

        key: "/desktop/lipstick-jolla-home/kidsMode/"+kmSettings.currentUser+"/kmAmbiences"
        defaultValue: []
    }
    ConfigurationValue 
    {
        id: currentAmbience

        key: "/desktop/jolla/theme/active_ambience"
        defaultValue: ""
    }
    ConfigurationValue 
    {
        id: mainAmbience

        key: "/desktop/lipstick-jolla-home/kidsMode/ambience"
        defaultValue: currentAmbience.value
    }
    ConfigurationValue 
    {
        id: userAmbience

        key: "/desktop/lipstick-jolla-home/kidsMode/"+kmSettings.currentUser+"/ambience"
        defaultValue: currentAmbience.value
    }
    ConfigurationGroup
    {
        id: kmSettings
        path: "/desktop/lipstick-jolla-home/kidsMode"
        property bool pinActive: false
        property string kmPin: "notset"
        property bool kmOn: false
        property int nUsers: 0
        property int currentUser: 0
        property bool triggerLoad: false   
        property bool triggerClose: false
        property bool closeAllApps: true
        property bool androidEnter: false
        property bool androidExit: false
    }
        
    ConfigurationGroup
    {
        id: userGroup
        path: "/desktop/lipstick-jolla-home/kidsMode/0"
        property string userName:''
        property string iconColor: "#e60003"
        property bool firstUse: true
        property bool topmenu_ambiences_enabled: true 
    }
    
    ConfigurationGroup
    {
        id: mainUserBackUp
        path: "/desktop/lipstick-jolla-home/kidsMode/mainUser"
        property bool topmenu_ambiences_enabled: true  
        function backUpMainUser ()
        {
            topmenu_ambiences_enabled = mainUser.topmenu_ambiences_enabled
            mainUserBuShortcuts.value =  mainUserShortcuts.value
            mainUserBuWidgets.value =  mainUserWidgets.value
        }      
    }
    
    ConfigurationGroup
    {
        id: mainUser
        path: "/desktop/lipstick-jolla-home"
        property bool events_screen_shortcuts_enabled: false
        property bool events_screen_actions_enabled: false  
        property bool topmenu_ambiences_enabled: true  
        function copyKmUser ()
        {
            topmenu_ambiences_enabled = userGroup.topmenu_ambiences_enabled
            mainUserShortcuts.value =  userGroupShortcuts.value
            mainUserWidgets.value =  userGroupWidgets.value
        }
        
        function restoreMainUser ()
        {
            topmenu_ambiences_enabled = mainUserBackUp.topmenu_ambiences_enabled
          mainUserShortcuts.value =  mainUserBuShortcuts.value
            mainUserWidgets.value =  mainUserBuWidgets.value
        }
    }
    //keep getting error trying to copy the arrays so have to use configuration values as a work around
    ConfigurationValue
    {
        id: userGroupShortcuts
        key: "/desktop/lipstick-jolla-home/kidsMode/"+kmSettings.currentUser+"/topmenu_shortcuts"
        defaultValue: []
    }
    ConfigurationValue
    {
        id: userGroupWidgets
        key: "/desktop/lipstick-jolla-home/kidsMode/"+kmSettings.currentUser+"/events_screen_widgets"
        defaultValue: []
    }
    ConfigurationValue
    {
        id: mainUserShortcuts
        key: "/desktop/lipstick-jolla-home/topmenu_shortcuts"
        defaultValue: []
    }
    ConfigurationValue
    {
        id: mainUserWidgets
        key: "/desktop/lipstick-jolla-home/events_screen_widgets"
        defaultValue: []
    }
    ConfigurationValue
    {
        id: mainUserBuShortcuts
        key: "/desktop/lipstick-jolla-home/kidsMode/mainUser/topmenu_shortcuts"
        defaultValue: []
    }
    ConfigurationValue
    {
        id: mainUserBuWidgets
        key: "/desktop/lipstick-jolla-home/kidsMode/mainUser/events_screen_widgets"
        defaultValue: []
    }
    
    Timer
     {
        //When cancelled the files have already been changed, wait a few seconds for the file changes to complete then copy correct files and reload
        id: loadTimer
        repeat: false
        interval: 2000
        property int userId: 0
        property bool turnOnKm: false
        property bool turnOffKm: false
        onTriggered:   {
            if(kmSettings.kmOn) python.call('helper.restoreAppMenu',[],function() { 
                kmSettings.triggerLoad = !kmSettings.triggerLoad
                }) 
          else  python.call('helper.restoreMainUser',['launcherBackUp'],function(){
                kmSettings.triggerLoad = !kmSettings.triggerLoad
                })
            if(turnOnKm){ 
                turnOnKm = false                
                enterKm(userId)
            }
            if(turnOffKm){
                turnOffKm = false                
                exitKm()
            }
        } 
    }
    RemorsePopup 
    {
        id: kmRemorse
//Most of the changes have already been made before the remorse. It is used to give the delay required to wait for the modifed corrupt application.menu file to appear. This then needs to be overridden with the correct file
        onTriggered: {
           if(kmSettings.kmOn) python.call('helper.restoreAppMenu',[],function() {
                kmSettings.triggerLoad = !kmSettings.triggerLoad
                kmSettings.triggerClose =  !kmSettings.triggerClose
                python.call('helper.setFavorites',[userAmbience.value, kmAmbiences.value],function(){})
                if(kmSettings.androidEnter) apkInterface.typedCall("controlService", [{ "type": "b", "value": false }])
                })
            else python.call('helper.restoreMainUser',['launcherBackUp'],function(){
                kmSettings.triggerLoad = !kmSettings.triggerLoad
                python.call('helper.setFavorites',[mainAmbience.value, mainAmbiences.value],function(){})
                kmSettings.triggerClose= !kmSettings.triggerClose
                 if(kmSettings.androidExit) apkInterface.typedCall("controlService", [{ "type": "b", "value": false }])
                }) 
            }
        onCanceled: {
         if(kmSettings.kmOn) {
                   kmSettings.kmOn = false
                   mainUser.restoreMainUser()
                   loadTimer.start()
            }
            else {
                userGroup.path =  "/desktop/lipstick-jolla-home/kidsMode/" + kmSettings.currentUser
                kmSettings.kmOn = true
                mainUser.copyKmUser()
                loadTimer.start()          
            }
        } 
    }
        
     function enterKm(userId)
    {
        if(loadTimer.running ) {
            loadTimer.turnOnKm=true
            loadTimer.userId=userId
        }
        else {            
            mainUserBackUp.backUpMainUser()
            userGroup.path =  "/desktop/lipstick-jolla-home/kidsMode/" + userId
            kmSettings.currentUser = userId
            if(appsList.value.length != appTitles.value.length) appModel.updateAppTitles()
            mainUser.copyKmUser()
            mainAmbience.value = currentAmbience.value
            python.call('helper.backupMainUser',[],function  () {
                    kmSettings.kmOn = true
                    //% "Entering kids mode"
                    kmRemorse.execute(qsTrId("enter-km"))
                 }       
            )
        }
    }
    
    function exitKM()
    {
        if(loadTimer.running ) {
            loadTimer.turnOffKm=true
        }
        else {
            kmSettings.kmOn = false
            mainUser.restoreMainUser()
            userAmbience.value = currentAmbience.value
            //% "Exiting kids mode"
            kmRemorse.execute(qsTrId("exit-km"))
        }
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

