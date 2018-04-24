import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.4
import org.nemomobile.configuration 1.0
import "pages"
import "settings"

ApplicationWindow
{
    id: app
    initialPage: kmOn.value ? kmRunning : kmNotRunning 
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    
    ConfigurationValue 
    {
        id: kmOn
        key: "/desktop/lipstick-jolla-home/kidsMode/kmOn"
        defaultValue: false
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
}

