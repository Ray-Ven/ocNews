import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import QtMobility.feedback 1.1

import "../JS/globals.js" as GLOBALS

import "../Common"
import "../Delegates"
import "../Sheets"

Page {
    id: itemListView
    tools: itemListViewTools
    orientationLock: PageOrientation.LockPortrait

    property string feedId
    property string feedName

    property int handleRead: dbus.getSetting("display/handleread", 0)
    property bool sortAsc: dbus.getSetting("display/sortasc", false) == "true"

    function openFile(file, properties) {
             var component = Qt.createComponent(file)
             if (component.status == Component.Ready)
                 pageStack.push(component, properties);
             else
                 console.log("Error loading component:", component.errorString());
         }

    Component.onCompleted: { itemsModelSql.refresh(feedId, handleRead, sortAsc); }
    Component.onDestruction: GLOBALS.previousContentY = 0;

    Connections {
        target: feeds
        onMarkedReadFeedSuccess: itemsModelSql.refresh(feedId, handleRead, sortAsc)
        onDeletedFeedSuccess: pageStack.pop()
    }
    Connections {
        target: items
        onUpdatedItemsSuccess: { itemsModelSql.refresh(feedId, handleRead, sortAsc); itemsList.contentY = GLOBALS.previousContentY; }
        onRequestedItemsSuccess: { itemsModelSql.refresh(feedId, handleRead, sortAsc); itemsList.contentY = GLOBALS.previousContentY; }
        onStarredItemsSuccess: { itemsModelSql.refresh(feedId, handleRead, sortAsc); itemsList.contentY = GLOBALS.previousContentY; }
        onMarkedItemsSuccess: { itemsModelSql.refresh(feedId, handleRead, sortAsc); itemsList.contentY = GLOBALS.previousContentY; }
    }

    onHandleReadChanged: itemsModelSql.refresh(feedId, handleRead, sortAsc)
    onSortAscChanged: itemsModelSql.refresh(feedId, handleRead, sortAsc)

// ------------- Header Start ----------------

    Header {
        id: itemListViewHeader
        text: itemListView.feedName
    }

// ------------- Header End ----------------


// ------------- Start Search Field ------------

    Rectangle {
        id: searchFieldBox
        anchors { top: parent.top; topMargin: 71 }
        width: parent.width; height: 0; z: 1
        color: theme.inverted ? "black" : "#E0E1E2"
        clip: true

        Behavior on height { NumberAnimation { duration: 200 } }

        Rectangle {
            id: srect
            anchors { fill: searchFieldBox; leftMargin: 10; rightMargin: 10; top: searchFieldBox.top }
            color: "transparent"
            opacity: searchFieldBox.height === 0 ? 0 : 1

            Behavior on opacity { NumberAnimation { duration: 400 } }


            TextField {
                id: searchTextField
                width: parent.width
                placeholderText: qsTr("Search...")
                anchors { left: srect.left; top: srect.top; topMargin: 9 }
                platformStyle: TextFieldStyle { paddingRight: clearButton.width }
                inputMethodHints: Qt.ImhNoPredictiveText

                onTextChanged: { searchFieldTimer.restart(); itemsModelSql.refresh(feedId, handleRead, sortAsc, text) }

                Image {
                    id: clearButton
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    source: searchTextField.text === "" ? "image://theme/icon-m-common-search" : "image://theme/icon-m-input-clear"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            searchTextField.text = ""
                            itemsModelSql.refresh(feedId, handleRead, sortAsc)
                        }
                    }
                }
            }
        }

        Timer {
            id: searchFieldTimer; running: false; interval: 7000; repeat: false
            onTriggered: { if (searchTextField.text === "") searchFieldBox.height = 0 }
        }
    }

// ------------- End Search Field ------------


// --------------- Start Content List --------------

    ListView {
        id: itemsList
        anchors { fill: parent; topMargin: searchFieldBox.height + 71; leftMargin: 0; rightMargin: 16 }
        model: itemsModelSql
        delegate: ItemListDelegate {
            onClicked: { GLOBALS.previousContentY = itemsList.contentY; openFile("SingleItemView.qml", {itemId: itemId}); }
            onPressAndHold: {
                     contextMenuEffect.play()
                     itemContextMenu.itemId = itemId
                     itemContextMenu.itemTitle = title
                     itemContextMenu.itemUrl = url
                     itemContextMenu.starred = starred
                     itemContextMenu.itemGuidHash = guidHash
                     itemContextMenu.unread = unread
                     itemContextMenu.pubDateInt = pubDateInt
                     itemContextMenu.open()
                 }
        }

        onContentYChanged: {
            if (contentY < -100) {
                searchFieldBox.height = 71;
                searchFieldTimer.running = true;
            }
        }
    }

    ScrollDecorator {
        flickableItem: itemsList
        anchors { right: parent.right; rightMargin: -itemsList.anchors.rightMargin }
    }

    ThemeEffect { id: contextMenuEffect; effect: "LongPress" }


// --------------- End Content List --------------



// ------------- ToolBar Start -------------
    ToolBarLayout {
        id: itemListViewTools
        visible: true
        ToolIcon {
            platformIconId: "toolbar-back"
            anchors.left: (parent === undefined) ? undefined : parent.left
            onClicked: { pageStack.pop(); }
        }
        ToolIcon {
            id: updaterIcon
            platformIconId: "toolbar-refresh"
            state: updater.isUpdateRunning() ? "RUNNING" : "NORMAL"
            states: [
                State {
                    name: "NORAML"
                    PropertyChanges { target: updaterIcon; visible: true; enabled: true; }
                },
                State {
                    name: "RUNNING"
                    PropertyChanges { target: updaterIcon; visible: false; enabled: false; }
                }
            ]
            onClicked: {
                GLOBALS.previousContentY = itemsList.contentY
                itemListViewHeader.indicatorState = "RUNNING"
                updaterIcon.state = "RUNNING"
                items.updateItems("0", "0", itemListView.feedId);
            }
            Connections {
                target: items
                onUpdatedItemsSuccess: updaterIcon.state = "NORMAL"
                onUpdatedItemsError: updaterIcon.state = "NORMAL"
            }
            Connections {
                target: updater
                onUpdateFinished: updaterIcon.state = "NORMAL"
                onUpdateError: updaterIcon.state = "NORMAL"
                onUpdateStarted: updaterIcon.state = "RUNNING";
            }
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            anchors.right: (parent === undefined) ? undefined : parent.right
            onClicked: { (feedMenu.status === DialogStatus.Closed) ? feedMenu.open() : feedMenu.close(); }
        }
    }

    Menu {
        id: feedMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem {
                text: qsTr("Mark feed as read")
                onClicked: {
                    GLOBALS.previousContentY = itemsList.contentY
                    itemListViewHeader.indicatorState = "RUNNING"
                    feeds.markFeedRead(feedId)
                }
            }
            MenuItem {
                text: qsTr("Delete feed")
                onClicked: itemListViewDeleteFeedQuery.open()
            }
            MenuItem {
                text: sortAsc ? qsTr("Show newest on top") : qsTr("Show oldest on top")
                onClicked: sortAsc = !sortAsc
            }
            MenuItem {
                SelectionItem {
                    id: handleReadSelect
                    anchors.fill: parent
                    anchors.leftMargin: 25
                    anchors.rightMargin: 25
                    title: qsTr("Read articles")
                    model: handleReadModel
                    initialValue: handleRead
                    onCurrentValueChanged: handleRead = currentValue
                }
            }
        }
    }

    ListModel {
        id: handleReadModel
        ListElement { name: ""; value: 0 }
        ListElement { name: ""; value: 1 }
        ListElement { name: ""; value: 2 }
        Component.onCompleted: {
            handleReadModel.get(0).name = qsTr("Show")
            handleReadModel.get(1).name = qsTr("Hide")
            handleReadModel.get(2).name = qsTr("Show after unread")
        }
    }


// ----------------- ToolBar End -------------



// ----------------- Context Menu Start --------------

    ContextMenu {
        id: itemContextMenu
        property string itemId
        property string itemTitle
        property string itemUrl
        property bool starred
        property string itemGuidHash
        property bool unread
        property int pubDateInt
        function starParams() {
            var feedId=itemListView.feedId;
            var params={};
            params[feedId]=itemContextMenu.itemGuidHash;
            return params;
        }
        function markParams() {
            var params = new Array();
            params[0]=itemContextMenu.itemId;
            return params;
        }
        MenuLayout {
            MenuItem {
                text: itemContextMenu.starred === false ? qsTr("Add to favourites") : qsTr("Remove from favourites")
                onClicked: {
                    GLOBALS.previousContentY = itemsList.contentY
                    itemContextMenu.starred === false ?
                                items.starItems("star", itemContextMenu.starParams() ) :
                               items.starItems("unstar", itemContextMenu.starParams() )
                    itemListViewHeader.indicatorState = "RUNNING"
                }

            }
            MenuItem {
                text: itemContextMenu.unread ? qsTr("Mark as read") : qsTr("Mark as unread")
                onClicked: {
                    GLOBALS.previousContentY = itemsList.contentY
                    itemContextMenu.unread ? items.markItems("read", itemContextMenu.markParams()) : items.markItems("unread", itemContextMenu.markParams())
                    itemListViewHeader.indicatorState = "RUNNING"
                }
            }
            MenuItem {
                text: qsTr("Mark as read up to this point")
                onClicked: {
                    GLOBALS.previousContentY = itemsList.contentY
                    items.markItemsTillThis("read", itemContextMenu.pubDateInt, itemListView.feedId)
                    itemListViewHeader.indicatorState = "RUNNING"
                }
            }
            MenuItem {
                text: qsTr("Mark as unread up to this point")
                onClicked: {
                    GLOBALS.previousContentY = itemsList.contentY
                    items.markItemsTillThis("unread", itemContextMenu.pubDateInt, itemListView.feedId)
                    itemListViewHeader.indicatorState = "RUNNING"
                }
            }
            MenuItem {
                text: qsTr("Share")
                onClicked: shareUi.share(itemContextMenu.itemUrl, itemContextMenu.itemTitle, feedName)
            }
        }
    }

// ----------------- Context Menu End --------------




// ----------------- Dialogs Start --------------------

    QueryDialog {
        id: itemListViewDeleteFeedQuery
        icon: "image://theme/icon-m-bootloader-warning"
        acceptButtonText: qsTr("Delete")
        rejectButtonText: qsTr("Cancel")
        titleText: qsTr("Delete feed %1?").arg(feedName)
        onAccepted: {
            itemListViewHeader.indicatorState = "RUNNING"
        }
    }

    // ----------------- Dialogs End --------------------


}