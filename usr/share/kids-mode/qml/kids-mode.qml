import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.4
import org.nemomobile.configuration 1.0
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
    Component.onCompleted: {
        kmSettings.triggerLoad = false
        kmSettings.triggerClose = false 
        updateUsers()
    }
    
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
    }
        
    ConfigurationGroup
    {
        id: userGroup
        path: "/desktop/lipstick-jolla-home/kidsMode/0"
        property string userName:''
        property string iconColor: "#e60003"
        property bool firstUse: true
        property bool events_screen_shortcuts_enabled: false
        property bool events_screen_actions_enabled: false  
    }
    
    ConfigurationGroup
    {
        id: mainUserBackUp
        path: "/desktop/lipstick-jolla-home/kidsMode/mainUser"
        property bool events_screen_shortcuts_enabled: false
        property bool events_screen_actions_enabled: false 
        function backUpMainUser ()
        {
            events_screen_shortcuts_enabled = mainUser.events_screen_shortcuts_enabled
            events_screen_actions_enabled = mainUser.events_screen_actions_enabled
            mainUserBuActions.value =  mainUserActions.value 
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
        
        function copyKmUser ()
        {
            events_screen_shortcuts_enabled = userGroup.events_screen_shortcuts_enabled
            events_screen_actions_enabled = userGroup.events_screen_actions_enabled
            mainUserActions.value =  userGroupActions.value 
            mainUserShortcuts.value =  userGroupShortcuts.value
            mainUserWidgets.value =  userGroupWidgets.value
        }
        
        function restoreMainUser ()
        {
             events_screen_shortcuts_enabled = mainUserBackUp.events_screen_shortcuts_enabled
            events_screen_actions_enabled = mainUserBackUp.events_screen_actions_enabled
            mainUserActions.value =  mainUserBuActions.value 
            mainUserShortcuts.value =  mainUserBuShortcuts.value
            mainUserWidgets.value =  mainUserBuWidgets.value
        }
    }
    //keep getting error trying to copy the arrays so have to use configuration values as a work around
    ConfigurationValue
    {
        id: userGroupActions
        key: "/desktop/lipstick-jolla-home/kidsMode/"+kmSettings.currentUser+"/events_screen_actions"
        defaultValue: []
    }
    ConfigurationValue
    {
        id: userGroupShortcuts
        key: "/desktop/lipstick-jolla-home/kidsMode/"+kmSettings.currentUser+"/events_screen_shortcuts"
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
        id: mainUserActions
        key: "/desktop/lipstick-jolla-home/events_screen_actions"
        defaultValue: []
    }
    ConfigurationValue
    {
        id: mainUserShortcuts
        key: "/desktop/lipstick-jolla-home/events_screen_shortcuts"
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
        id: mainUserBuActions
        key: "/desktop/lipstick-jolla-home/kidsMode/mainUser/events_screen_actions"
        defaultValue: []
    }
    ConfigurationValue
    {
        id: mainUserBuShortcuts
        key: "/desktop/lipstick-jolla-home/kidsMode/mainUser/events_screen_shortcuts"
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
                kmSettings.triggerLoad = true
                kmSettings.triggerLoad = false
                }) 
          else  python.call('helper.restoreMainUser',[],function(){
                kmSettings.triggerLoad = true
                kmSettings.triggerLoad = false     
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
                kmSettings.triggerLoad = true
                kmSettings.triggerClose = true })
            else python.call('helper.restoreMainUser',[],function(){
                kmSettings.triggerLoad = true
                kmSettings.triggerClose= true}) 
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
            mainUser.copyKmUser() 
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

