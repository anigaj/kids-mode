import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings 1.0

Page 
{
    id: page

    property alias model: listView.model
    property alias pageModel: pageListView.model
    property alias listModel: listListView.model

    SilicaFlickable 
    {
        anchors.fill: parent
        contentHeight: column.height

        VerticalScrollDecorator {}

        Column 
        {
            id: column
            width: parent.width

            PageHeader 
            {
                //% "Select shortcuts"
                title: qsTrId("settings_events-he-select_shortcuts")
            }

            SectionHeader 
            {
                //: Shortcuts which are simple switches
                //% "Switches"
                text: qsTrId("settings_events-he-switches")
            }

            Item 
            {
                width: parent.width
                height: listView.contentHeight
                ListView 
                {
                    id: listView
                    width: parent.width
                    height: Screen.height * 1000
                    interactive: false

                    delegate: IconTextSwitch {
                        id: item
                        width: parent.width
                        text: model.object.title
                        icon.source: model.object.icon
                        checked: model.favorite
                        automaticCheck: false
                        onClicked: {
                            var path = model.object.location().join('/')
                            if (model.favorite) page.model.removeFavorite(path)
                            else page.model.addFavorite(path)
                        }
                    }
                }
            }

            Item 
            {
                width: parent.width
                height: listListView.contentHeight
                ListView 
                {
                    id: listListView
                    width: parent.width
                    height: Screen.height * 1000
                    interactive: false

                    delegate: IconTextSwitch {
                        width: parent.width
                        text: model.object.title
                        icon.source: model.object.icon
                        checked: model.favorite
                        automaticCheck: false
                        onClicked: {
                            var path = model.object.location().join('/')
                            if (model.favorite) page.model.removeFavorite(path)
                            else page.model.addFavorite(path)
                        }
                    }
                }
            }

            SectionHeader 
            {
                //: Shortcuts which are links to settings in the settings app
                //% "Shortcuts"
                text: qsTrId("settings_events-he-shortcuts")
            }

            Item 
            {
                width: parent.width
                height: pageListView.contentHeight
                ListView 
                {
                    id: pageListView
                    width: parent.width
                    height: Screen.height * 1000
                    interactive: false

                    delegate: IconTextSwitch {
                        width: parent.width
                        text: model.object.title
                        icon.source: model.object.icon
                        checked: model.favorite
                        automaticCheck: false
                        onClicked: {
                            var path = model.object.location().join('/')
                            if (model.favorite) page.model.removeFavorite(path)
                            else page.model.addFavorite(path)
                        }
                    }
                }
            }
        }
    }
}
