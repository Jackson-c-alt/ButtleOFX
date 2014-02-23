import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.0
import QtQuick.Controls.Styles 1.0

import ButtleFileModel 1.0


Rectangle {
    id: winFile
    color: fileModel.exists ? "black" : "lightgrey"

    property string folder
    signal goToFolder(string newFolder)
    property string filterName
    signal changeFileFolder(string fileFolder)
    property string file
    signal changeFile(string file)
    signal changeFileType(string fileType)
    signal changeFileSize(real fileSize)
    property bool viewList: false
    signal changeSelectedList(variant selected)
    property int itemIndex: 0
    property string fileName

    function forceActiveFocusOnCreate() {
        fileModel.createFolder(fileModel.folder + "/New Directory")
    }

    function forceActiveFocusOnRename() {
        viewList ? listview.currentItem.forceActiveFocusInRow() : gridview.currentItem.forceActiveFocusInColumn()
    }

    function forceActiveFocusOnDelete() {
        fileModel.deleteItem(itemIndex)
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            forceActiveFocus()
            // TODO: unselect
        }
    }

    Menu {
        id: creation

        MenuItem {
            text: "Create a Directory"
            onTriggered: {
                fileModel.createFolder(fileModel.folder + "/New Directory")
            }
        }
    }


    QtObject {
        id: readerNode
        property variant nodeWrapper
    }

    FileModelBrowser {
        id: fileModel
        folder: winFile.folder
        nameFilter: winFile.filterName

        onFolderChanged: {
            fileModel.selectItem(0)
            winFile.changeFileFolder(fileModel.parentFolder)
        }
        onNameFilterChanged: {
            fileModel.selectItem(0)
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: {
            if (mouse.button == Qt.RightButton)
                creation.popup()
        }
    }

    ScrollView {
        anchors.fill: parent
        anchors.topMargin: 5
        anchors.bottomMargin: 5
        height: 120
        width: 110
        visible: viewList ? false : true

        style: ScrollViewStyle {
                        scrollBarBackground: Rectangle {
                            id: scrollBar
                            width:15
                            color: "#212121"
                            border.width: 1
                            border.color: "#333"
                        }
                        decrementControl : Rectangle {
                            id: scrollLower
                            width:15
                            height:15
                            color: styleData.pressed? "#212121" : "#343434"
                            border.width: 1
                            border.color: "#333"
                            radius: 3
                            Image {
                                id: arrow
                                source: "file:///" + _buttleData.buttlePath + "/gui/img/buttons/params/arrow2.png"
                                x:4
                                y:4
                            }
                        }
                        incrementControl : Rectangle {
                            id: scrollHigher
                            width:15
                            height:15
                            color: styleData.pressed? "#212121" : "#343434"
                            border.width: 1
                            border.color: "#333"
                            radius: 3
                            Image {
                                id: arrow
                                source: "file:///" + _buttleData.buttlePath + "/gui/img/buttons/params/arrow.png"
                                x:4
                                y:4
                            }
                        }
                    }

        GridView {
            id: gridview
            width: parent.width
            height: parent.height
            cellWidth: 120
            cellHeight: cellWidth
            property int gridMargin: 4
            visible: ! viewList
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick
            interactive: false
            currentIndex: -1
            cacheBuffer: 10 * cellHeight  // caches 10 lines below and above

            property int previousIndex: -1

            model: fileModel.fileItems
            delegate: Component {
                id: componentInColumn

                Rectangle {
                    id: rootFileItem
                    color: model.object.isSelected ? "#00b2a1" : "transparent"

                    width: gridview.cellWidth - gridview.gridMargin
                    height: gridview.cellHeight - gridview.gridMargin
                    radius: 5

                    objectName: index

                    property variant selectedFiles
                    property variant filePath: model.object.filepath

                    function forceActiveFocusInColumn() {
                        filename_textEdit.forceActiveFocus()
                    }

                    /*DropArea {
                        id: moveItemInColumn
                        anchors.fill: parent
                        objectName: model.object.filepath
                        keys: ["internFileDrag"]

                        onDropped: {
                            console.debug("file: " + Drag.source.objectName)
                            console.debug("Index: " + drop.source.objectName)
                            //fileModel.moveItem(drop.source.objectName, )
                        }
                    }*/

                    Drag.active: rootFileItem_mouseArea.drag.active
                    Drag.hotSpot.x: 20
                    Drag.hotSpot.y: 20
                    //Drag.dragType: Drag.Automatic
                    Drag.mimeData: {"urls": [rootFileItem.selectedFiles]}
                    //Drag.mimeData: {"text/plain": file.filePath, "text/uri-list": ""}
                    // Drag.keys: "text/uri-list"
                    Drag.keys: "internFileDrag"

                    StateGroup {
                        id: fileStateColumn
                        states: State {
                            name: "dragging"
                            when: rootFileItem_mouseArea.pressed
                            PropertyChanges { target: rootFileItem; x: rootFileItem.x; y: rootFileItem.y }
                        }
                    }

                    MouseArea {
                        id: rootFileItem_mouseArea
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onReleased: rootFileItem.Drag.drop()
                        drag.target: rootFileItem

                        onPressed: {
                            rootFileItem.forceActiveFocus()

                            winFile.changeFileSize(0)
                            if (mouse.button == Qt.RightButton)
                                options.popup()
                                winFile.fileName = filename_textEdit.text
                                winFile.itemIndex = index

                            //if shift:
                            if(mouse.modifiers & Qt.ShiftModifier)
                                fileModel.selectItemsByShift(gridview.previousIndex, index)

                            gridview.previousIndex = index
                            winFile.changeFile(model.object.filepath)
                            winFile.changeFileType(model.object.fileType)
                            //if ctrl:
                            if(mouse.modifiers & Qt.ControlModifier)
                                fileModel.selectItems(index)

                            else if(!(mouse.modifiers & Qt.ShiftModifier))
                                fileModel.selectItem(index)
                                winFile.changeFileSize(model.object.fileSize)

                            var sel = fileModel.getSelectedItems()
                            var selection = new Array()
                            for(var selIndex = 0; selIndex < sel.count; ++selIndex)
                            {
                                selection[selIndex] = sel.get(selIndex).filepath
                            }
                            rootFileItem.selectedFiles = selection
                            winFile.changeSelectedList(sel)
                        }

                        onDoubleClicked: {
                            // if it's an image, we assign it to the viewer
                             if (model.object.fileType != "Folder") {
                                 player.changeViewer(11) // we come to the temporary viewer
                                 // we save the last node wrapper of the last view
                                 player.lastNodeWrapper = _buttleData.getNodeWrapperByViewerIndex(player.lastView)

                                 readerNode.nodeWrapper = _buttleData.nodeReaderWrapperForBrowser(model.object.filepath)

                                 _buttleData.currentGraphIsGraphBrowser()
                                 _buttleData.currentGraphWrapper = _buttleData.graphBrowserWrapper

                                 _buttleData.currentViewerNodeWrapper = readerNode.nodeWrapper
                                 _buttleData.currentViewerFrame = 0
                                 // we assign the node to the viewer, at the frame 0
                                 _buttleData.assignNodeToViewerIndex(readerNode.nodeWrapper, 10)
                                 _buttleData.currentViewerIndex = 10 // we assign to the viewer the 10th view
                                 _buttleEvent.emitViewerChangedSignal()
                             } else {
                                 winFile.goToFolder(model.object.filepath)
                             }
                        }
                    }

                    Menu {
                        id: options

                        MenuItem {
                            text: "Rename"
                            onTriggered: {
                                //Open a TextEdit
                                filename_textEdit.forceActiveFocus()
                            }
                        }
                        MenuItem {
                            text: "Delete"
                            onTriggered: {
                                fileModel.deleteItem(itemIndex)
                                //deleteMessage.open()
                            }
                        }
                    }

                    ColumnLayout {
                        id: file
                        spacing: 0
                        anchors.fill: parent
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Item {
                                anchors.fill: parent
                                anchors.margins: 4
                                property int minSize: Math.min(width, height)

                                Image {
                                    property bool isFolder: model.object.fileType == "Folder"
                                    source: isFolder ? "../../img/buttons/browser/folder-icon.png" : "file:///" + model.object.filepath
                                    sourceSize.width: isFolder ? parent.minSize : -1
                                    sourceSize.height: isFolder ? parent.minSize : -1

                                    anchors.fill: parent
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true

                                    anchors.centerIn: parent
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            implicitHeight: hack_fontMetrics.height * 3 // 3 lines of text
                            Text {
                                id: hack_fontMetrics
                                text: "A"
                                visible: false
                            }
                            Rectangle {
                                id: filename_background
                                width: filename_textEdit.width
                                height: filename_textEdit.paintedHeight

                                color: "white"
                                radius: 2

                                visible: filename_textEdit.activeFocus
                            }
                            TextEdit {
                                id: filename_textEdit

                                horizontalAlignment: TextInput.AlignHCenter
                                anchors.fill: parent

                                text: model.object.fileName
                                property string origText: ""

                                color: model.object.isSelected ? "black" : "white"
                                font.bold: model.object.isSelected
                                textFormat: TextEdit.PlainText
                                wrapMode: TextEdit.Wrap

                                selectByMouse: activeFocus
                                selectionColor: "#5a5e6b"
                                clip: ! activeFocus
                                z: 9999  // TODO: need another solution to be truly on top.

                                onTextChanged: {
                                    // Hack to get the "Keys.onEnterPressed" event
                                    var hasEndline = (text.lastIndexOf("\n") != -1)
                                    if( hasEndline )
                                    {
                                        var newText = text.replace("\n", "")
                                        textAccepted(newText)
                                    }
                                }

                                onActiveFocusChanged: {
                                    if( filename_textEdit.activeFocus )
                                    {
                                        selectAll()
                                        origText = text
                                    }
                                    else
                                    {
                                        deselect()
                                        textAccepted(text)
                                    }
                                }
                                function textAccepted(newText) {
                                    if( origText != newText )
                                    {
                                        fileModel.changeFileName(newText, itemIndex)
                                    }
                                    origText = ""
                                }
                                MouseArea {
                                    id: filename_mouseArea
                                    width: filename_textEdit.width
                                    height: Math.max(filename_textEdit.width, filename_textEdit.paintedHeight)
                                    acceptedButtons: Qt.LeftButton
                                    enabled: ! filename_textEdit.activeFocus
                                    onPressed: {
                                        // forward to the rootFileItem
                                        rootFileItem_mouseArea.onPressed(mouse)
                                    }
                                    onDoubleClicked: {
                                        mouse.accepted = true
                                        filename_textEdit.forceActiveFocus()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    ScrollView {
        anchors.fill: parent
        anchors.topMargin: 5
        anchors.bottomMargin: 5
        height: 120
        width: 110
        visible: viewList

        style: ScrollViewStyle {
                        scrollBarBackground: Rectangle {
                            id: scrollBar
                            width:15
                            color: "#212121"
                            border.width: 1
                            border.color: "#333"
                        }
                        decrementControl : Rectangle {
                            id: scrollLower
                            width:15
                            height:15
                            color: styleData.pressed? "#212121" : "#343434"
                            border.width: 1
                            border.color: "#333"
                            radius: 3
                            Image{
                                id: arrow
                                source: "file:///" + _buttleData.buttlePath + "/gui/img/buttons/params/arrow2.png"
                                x:4
                                y:4
                            }
                        }
                        incrementControl : Rectangle {
                            id: scrollHigher
                            width:15
                            height:15
                            color: styleData.pressed? "#212121" : "#343434"
                            border.width: 1
                            border.color: "#333"
                            radius: 3
                            Image {
                                id: arrow
                                source: "file:///" + _buttleData.buttlePath + "/gui/img/buttons/params/arrow.png"
                                x:4
                                y:4
                            }
                        }
                    }

        ListView {
            id: listview
            height : parent.height
            width : parent.width
            visible: viewList
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick
            interactive: false
            currentIndex: -1

            property int previousIndex: -1

            model: fileModel.fileItems
            delegate: Component {

                Rectangle {
                    id: fileInRow
                    color: model.object.isSelected ? "#00b2a1" : "transparent"
                    radius: 5
                    height: 25
                    width: listview.width

                    function forceActiveFocusInRow() {
                        textInRow.forceActiveFocus()
                    }

                    property variant selectedFiles
                    property variant currentFile: model.object
                    property variant filePath: model.object.filepath

                    /*DropArea {
                        id: moveItemInRow
                        anchors.fill: parent
                        keys: ["internFileDrag"]

                        onDropped: {
                            console.debug("Drag: " + drag.source.filepath)
                            //fileModel.moveItem(itemIndex, drag.source.filepath)
                        }
                    }*/

                    Row {
                        width: parent.width
                        spacing: 10
                        Image {
                            x: 25
                            source: model.object.fileType == "Folder" ? "../../img/buttons/browser/folder-icon.png" : "file:///" + model.object.filepath
                            sourceSize.width: 20
                            sourceSize.height: 20
                        }

                        TextInput {
                            id: textInRow
                            x: 10

                            text: model.object.fileName
                            color: model.object.isSelected ? "black" : "white"
                            font.bold: model.object.isSelected
                            width: parent.width

                            selectByMouse: true
                            selectionColor: "#5a5e6b"

                            onFocusChanged:{
                                textInRow.focus ? selectAll() : deselect()
                            }

                            onAccepted: {
                                textInRow.selectAll()
                                fileModel.changeFileName(textInRow.getText(0, textInRow.cursorPosition + 1), itemIndex)
                                textInRow.forceActiveFocus()
                            }
                        }
                    }// endRow

                    Drag.active: dragMouseAreaRow.drag.active
                    Drag.hotSpot.x: 20
                    Drag.hotSpot.y: 20
                    //Drag.dragType: Drag.Automatic
                    Drag.mimeData: {"urls": [fileInRow.selectedFiles]}
                    //Drag.mimeData: {"text/plain": file.filePath, "text/uri-list": ""}
                    // Drag.keys: "text/uri-list"
                    Drag.keys: "internFileDrag"

                    StateGroup {
                      id: fileStateRow
                      states: State {
                          name: "dragging"
                          when: dragMouseAreaRow.pressed
                          PropertyChanges { target: fileInRow; x: fileInRow.x; y: fileInRow.y }
                      }
                    }

                    MouseArea {
                        id: dragMouseAreaRow
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onReleased: fileInRow.Drag.drop()
                        drag.target: fileInRow

                        onPressed: {
                            winFile.changeFileSize(0)
                            if (mouse.button == Qt.RightButton)
                                options.popup()
                                winFile.fileName = textInRow.text
                                winFile.itemIndex = index

                            //if shift:
                            if(mouse.modifiers & Qt.ShiftModifier)
                                fileModel.selectItemsByShift(listview.previousIndex, index)

                            listview.previousIndex = index
                            winFile.changeFile(model.object.filepath)
                            winFile.changeFileType(model.object.fileType)
                            //if ctrl:
                            if(mouse.modifiers & Qt.ControlModifier)
                                fileModel.selectItems(index)

                            else if(!(mouse.modifiers & Qt.ShiftModifier))
                                fileModel.selectItem(index)
                                winFile.changeFileSize(model.object.fileSize)

                            var sel = fileModel.getSelectedItems()
                            var selection = new Array()
                            for(var selIndex = 0; selIndex < sel.count; ++selIndex)
                            {
                                selection[selIndex] = sel.get(selIndex).filepath
                            }
                            fileInRow.selectedFiles = selection
                            winFile.changeSelectedList(sel)
                        }

                        onDoubleClicked: {
                            // if it's an image, we assign it to the viewer
                             if (model.object.fileType != "Folder"){
                                 player.changeViewer(11) // we come to the temporary viewer
                                 // we save the last node wrapper of the last view
                                 player.lastNodeWrapper = _buttleData.getNodeWrapperByViewerIndex(player.lastView)

                                 readerNode.nodeWrapper = _buttleData.nodeReaderWrapperForBrowser(model.object.filepath)

                                 _buttleData.currentGraphIsGraphBrowser()
                                 _buttleData.currentGraphWrapper = _buttleData.graphBrowserWrapper

                                 _buttleData.currentViewerNodeWrapper = readerNode.nodeWrapper
                                 _buttleData.currentViewerFrame = 0
                                 // we assign the node to the viewer, at the frame 0
                                 _buttleData.assignNodeToViewerIndex(readerNode.nodeWrapper, 10)
                                 _buttleData.currentViewerIndex = 10 // we assign to the viewer the 10th view
                                 _buttleEvent.emitViewerChangedSignal()
                             }
                             else{
                                 winFile.goToFolder(model.object.filepath)
                             }
                        }
                    }
                    Menu {
                        id: options

                        MenuItem {
                            text: "Rename"
                            onTriggered: {
                                //Open a TextEdit
                                textInRow.forceActiveFocus()
                            }
                        }
                        MenuItem {
                            text: "Delete"
                            onTriggered: {
                                fileModel.deleteItem(itemIndex)
                                //deleteMessage.open()
                            }
                        }
                    }
                }// end Rectangle
            }//endComponent
        }
    }

    /*MessageDialog {
        id: deleteMessage
        title: "Delete?"
        icon: StandardIcon.Warning
        text: "Do you really want to delete " + winFile.fileName + "?"
        standardButtons: StandardButton.No | StandardButton.Yes
        onYes: {
            //fileModel.deleteItem(itemIndex)
            console.log("deleted")
        }
        onNo: {
            console.log("didn't delete")
        }
    }*/
}
