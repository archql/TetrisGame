import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtMultimedia 5.8
import QtQml 2.0

Window {
    width: 1250
    height: 950
    visible: true
    title: "Tetris 0.0.1    pre "

    property int scale: 25
    property int panelwidth: 25
    property int panelheight: 25

    Text {
        x: 350
        id: txt
        text: "Tetris Game"
        font.family: "Helvetica"
        font.pointSize: 30
        font.bold: true
        color: "deeppink"
    }

    Field {
        y: 150
        id: field
    }

    //starter
    Timer {
        running: true
        interval: 50
        onTriggered: {
            scale = 25
            panelwidth = 18
            panelheight = 30
            field.drawField(scale, panelwidth, panelheight)
            //field.clearFrozens()
        }
    }
}
