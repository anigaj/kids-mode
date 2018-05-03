import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground
{
    id: cover
    Loader
    {
        sourceComponent: kmSettings.kmOn ? turnOff: turnOn 
    }
    
    Component 
     {
         id: turnOn
        TurnOnKmCover 
        {
            height: cover.height
            width: cover.width 
        }
    }
    
    Component 
     {
         id: turnOff
        TurnOffKmCover 
        {
            height: cover.height
            width: cover.width 
        }
    }
}
