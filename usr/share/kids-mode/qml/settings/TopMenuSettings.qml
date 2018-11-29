import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.systemsettings 1.0
import org.nemomobile.configuration 1.0

Page {
    id: root
    property int userId
height: column.height
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        VerticalScrollDecorator {}

        Column {
            id: column
            width: parent.width

            PageHeader {
                //% "Top menu"
                title: qsTrId("settings_topmenu-he-topmenu")
            }

            SectionHeader {
                //: Ambience selector settings section header
                //% "Ambiences"
                text: qsTrId("settings_topmenu-he-ambiences")
            }

            IconTextSwitch {
                //: Label in icon text switch which allows the user to enable or disable the ambience selector in the top menu
                //% "Show ambiences in top menu"
                text: qsTrId("settings_topmenu-la-ambiences_switch")

                //: Label containing a description of what the ambience selector is
                //% "Quickly browse and switch between ambiences"
                description: qsTrId("settings_topmenu-la-ambiences_description")

                icon.source: "image://theme/icon-m-ambience"
                checked: topMenuAmbiencesEnabled.value
                automaticCheck: false
                onClicked: {
                    topMenuAmbiencesEnabled.value = !topMenuAmbiencesEnabled.value
                }
            }

            Item {
                height: favoriteAmbiencesButton.height + 2*Theme.paddingLarge
                width: parent.width
                Button {
                    id: favoriteAmbiencesButton
                    anchors.centerIn: parent
                    enabled: topMenuAmbiencesEnabled.value
                    //: Button which opens the favorite ambiences selector settings page
                    //% "Favorite ambiences"
                    text: qsTrId("settings_topmenu-bt-favorite_ambiences")
                    onClicked: pageStack.animatorPush("AmbienceSelectionPage.qml",{"dconfKey": "/desktop/lipstick-jolla-home/kidsMode/"+page.userId+"/kmAmbiences"}) 
                }
            }

            SectionHeader {
                //: Shortcuts which are simple switches
                //% "Switches"
                text: qsTrId("settings_topmenu-he-switches")
            }

            Item {
                width: parent.width
                height: listView.contentHeight
                ListView {
                    id: listView
                    width: parent.width
                    height: Screen.height * 1000
                    interactive: false
                    model: shortcutsToggleModel

                    delegate: IconTextSwitch {
                        id: item
                        width: parent.width
                        text: model.object.title
                        icon.source: model.object.icon
                        checked: model.favorite
                        automaticCheck: false
                        onClicked: {
                            var path = model.object.location().join('/')
                            if (model.favorite) {
                                shortcutsToggleModel.removeFavorite(path)
                            } else {
                                shortcutsToggleModel.addFavorite(path)
                            }
                        }
                    }
                }
            }

            SectionHeader {
                //% "Sliders"
                text: qsTrId("settings_topmenu-he-brightness_and_volume")
            }

            Item {
                width: parent.width
                height: listListView.contentHeight
                ListView {
                    id: listListView
                    width: parent.width
                    height: Screen.height * 1000
                    interactive: false
                    model: shortcutsSliderModel

                    delegate: IconTextSwitch {
                        width: parent.width
                        text: model.object.title
                        icon.source: model.object.icon
                        checked: model.favorite
                        automaticCheck: false
                        onClicked: {
                            var path = model.object.location().join('/')
                            if (model.favorite) {
                                shortcutsSliderModel.removeFavorite(path)
                            } else {
                                shortcutsSliderModel.addFavorite(path)
                            }
                        }
                    }
                }
            }

            SectionHeader {
                //: Shortcuts which are links to settings in the settings app
                //% "Shortcuts"
                text: qsTrId("settings_topmenu-he-shortcuts")
            }

            Column {
                width: parent.width
                Repeater {
                    model: FavoritesModel {
                        id: shortcutsActionsModel
                        filter: ["action"]
                        showPotential: true
                        path: "system_settings"
                        key: shortcutsToggleModel.key
                        userModifiedKey: shortcutsToggleModel.userModifiedKey
                    }

                    delegate: IconTextSwitch {
                        width: root.width
                        text: model.object.title
                        icon.source: model.object.icon
                        checked: model.favorite
                        automaticCheck: false

                        onClicked: {
                            var path = model.object.location().join('/')
                            if (model.favorite) {
                                shortcutsActionsModel.removeFavorite(path)
                            } else {
                                shortcutsActionsModel.addFavorite(path)
                            }
                        }
                    }
                }
            }

            Repeater {
                model: SettingsModel {
                    depth: 1
                    path: "system_settings"
                }

                delegate: Column {
                    id: shortcutGroup

                    readonly property var systemSettingsGroupList: model.object.location()

                    width: parent.width

                    SectionHeader {
                        text: model.object.title
                    }

                    ColumnView {
                        width: parent.width
                        itemHeight: Theme.itemSizeSmall

                        model: FavoritesModel {
                            id: shortcutsPageModel
                            filter: ["grid_favorites_page"]
                            showPotential: true
                            path: shortcutGroup.systemSettingsGroupList
                            key: shortcutsToggleModel.key
                            userModifiedKey: shortcutsToggleModel.userModifiedKey
                        }

                        delegate: IconTextSwitch {
                            width: root.width
                            text: model.object.title
                            icon.source: model.object.icon
                            checked: model.favorite
                            automaticCheck: false

                            onClicked: {
                                var path = model.object.location().join('/')
                                if (model.favorite) {
                                    shortcutsPageModel.removeFavorite(path)
                                } else {
                                    shortcutsPageModel.addFavorite(path)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    ConfigurationValue {
        id: topMenuAmbiencesEnabled

        //key: "/desktop/lipstick-jolla-home/topmenu_ambiences_enabled"
        key: "/desktop/lipstick-jolla-home/kidsMode/"+page.userId+"/topmenu_ambiences_enabled"
        defaultValue: true
    }

    FavoritesModel {
        id: shortcutsToggleModel

        filter: "grid_favorites_simple"
        showPotential: true
        //key: "/desktop/lipstick-jolla-home/topmenu_shortcuts"
       // userModifiedKey: "/desktop/lipstick-jolla-home/topmenu_shortcuts_user"
        key: "/desktop/lipstick-jolla-home/kidsMode/"+page.userId+"/topmenu_shortcuts"
        userModifiedKey: "/desktop/lipstick-jolla-home/kidsMode/"+page.userId+"/topmenu_shortcuts_user"
    }

    FavoritesModel {
        id: shortcutsSliderModel

        filter: "list_favorites"
        showPotential: true
        path: "system_settings"
        key: shortcutsToggleModel.key
        userModifiedKey: shortcutsToggleModel.userModifiedKey
    }
}
