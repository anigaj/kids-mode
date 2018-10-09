import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Ambience 1.0
import com.jolla.gallery.ambience 1.0
import org.nemomobile.dbus 2.0
import org.nemomobile.configuration 1.0

Page {
    id: page
    property string dconfKey
    ConfigurationValue 
    {
        id: ambiences

        key: dconfKey
        defaultValue: []
    }
    
    SilicaFlickable
    {
        
        anchors.fill: parent
        contentHeight: content.height 
        ListModel
        {
            id: allAmbiences
        }
        Column 
        {
            id: content
            width: parent.width
            PageHeader
            {
                //% "Ambiences"
                title: qsTrId("jolla-gallery-ambience-he-ambiences")
            }
        
            Repeater
            {         
                height: Screen.height 
                model: allAmbiences
                delegate: Component {
                    BackgroundItem
                    {
                        width: parent.width
                        height:Screen.height / 5
                        opacity:ambiences.value.indexOf(model.url) == -1 ? 0.2: 1.0
                        Image
                        {
                            id: image
                            anchors.fill: parent
                            source: model.imageUrl
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }
                        Label
                        {
                            id: label
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            text: model.name
                            font.pixelSize: Theme.fontSizeLarge
                        }
                        onClicked: updateList()
                        property bool isSelected: ambiences.value.indexOf(model.url) == -1  
            
                        function updateList()
                        {
                            var ambList = ambiences.value 
                            if(!isSelected)
                            {
                                var i = ambList.indexOf(model.url)
                                ambList.splice(i,1)
                            }
                            else 
                            {
                                ambList.push(model.url)
                            }
                            ambiences.value = ambList
                        } 
                    }
                }
            }
        }
    }
    Component.onCompleted: {
        python.call('helper.getAmbiences',[],function(ambiencesList) {
            var result_length = ambiencesList.length;
            allAmbiences.clear();    
            allAmbiences.append(ambiencesList)
            /*for (var i=0; i<result_length; ++i) {
                ambiencesList[i]["isFavorite"] = ambiences.value.indexOf(ambiencesList[i].url) == -1 ? false: true
                allAmbiences.append(ambiencesList[i]);
            }*/
        });
    }
}
