import QtQuick 2.0
import QtMultimedia 5.8

Item {

    property int scale: 40
    property int fieldWidth: 40
    property int fieldHeight: 40
    property var frozedIcons: [[], []]

    property double maxScore: 0
    property double score: 0
    property int timePlayed: 0
    property int maxTimePlayed: 0

    property bool paused: false
    property bool game: true

    Repeater {
        id: repa
        model: fieldWidth * fieldHeight
        Rectangle {
            x: scale * 0
            y: scale * 0
            width: 40
            height: 40
            color: "transparent"
        }
    }
    Item {
        id: frC
        x: 20
        y: 20
        Repeater {
            id: frozed
            model: (fieldWidth - 2) * (fieldHeight - 2)
            Rectangle {
                x: scale * 0
                y: scale * 0
                width: 40
                height: 40
                color: "transparent"
            }
        }
    }
    /////////////////////////////////===========
    ////////////////////////////////============
    /////////////////////////////////========
    ////////////////////////////////////========


    /*functions
    ==========================================================
        drawField(scale, width, heifht)
        getCordInfo(y, x) (gets frozed array in x y point)
        clearFrozens() full clear Frozens
        addFrozen(figure, oX, oY, color) (adds figure to frozens array and draw it)
        checkOnFullStacks() (check frozens on full lines)
        restartGame() full game restart
    ===========================================================
    */
    Figure {
        id: fg
    }
    Figure {
        id: nextFg
        x: 500
        y: 50
    }
    //entertaiment
    Text {
        id: stats
        x: 100
        y: 200
        text: "Stats: "
        font.pointSize: 15
        color: "black"
    }
    Text {
        id: nf
        y: 0
        text: "Next figure: "
        font.pointSize: 25
        color: "black"
    }
    Text {
        id: status
        x: 100
        y: 750
        text: "Status: none (press R to start)"
        font.pointSize: 20
        color: "gray"
    }
    Timer {
        id: timeController
        repeat: true
        interval: 100
        triggeredOnStart: true
        onTriggered: {
            score += 0.01
            if (score >= maxScore)
                maxScore = score
            timePlayed++
            if (timePlayed >= maxTimePlayed)
                maxTimePlayed = timePlayed
            stats.text = "   Stats: \n score: " + Math.round(
                        score) + " / max: " + Math.round(maxScore)
                    + "\n time played: " + (timePlayed / 10).toFixed(1)
                    + "s" + "\n field filled: " + (countFilled()).toFixed(
                        1) + " %"
        }
    }

    Timer {
        id: gameTimer
        repeat: true
        triggeredOnStart: true
        interval: 1000 - score * 0.1
        onTriggered: {
            if (gameTimer.interval > 100)
                gameTimer.interval = 1000 - score / 2
            fg.moveDown()
            console.log("inter: ", gameTimer.interval)
        }
    }
    /////////////funcs
    function drawField(sc, fix, fiy) {
        fieldWidth = fix
        fieldHeight = fiy
        console.log("fieldWidth ", fieldWidth, ", fieldHeight ", fieldHeight)
        scale = sc
        frC.x = scale
        frC.y = scale
        for (var fy = 0; fy < fieldHeight; fy++) {
            for (var fx = 0; fx < fieldWidth; fx++) {
                repa.itemAt(fy * fieldWidth + fx).width = scale
                repa.itemAt(fy * fieldWidth + fx).height = scale
                repa.itemAt(fy * fieldWidth + fx).x = scale * fx
                repa.itemAt(fy * fieldWidth + fx).y = scale * fy
                if (fy < fieldHeight - 2 && fx < fieldWidth - 2) {
                    frozed.itemAt(fy * (fieldWidth - 2) + fx).width = scale
                    frozed.itemAt(fy * (fieldWidth - 2) + fx).height = scale
                    frozed.itemAt(fy * (fieldWidth - 2) + fx).x = scale * fx
                    frozed.itemAt(fy * (fieldWidth - 2) + fx).y = scale * fy
                    frozed.itemAt(fy * (fieldWidth - 2) + fx).radius = scale / 6
                }
                if (fx == 0 || fx == fieldWidth - 1 || fy == 0
                        || fy == fieldHeight - 1) {
                    repa.itemAt(fy * fieldWidth + fx).color = "goldenrod"
                } else if (fy == 5) {
                    repa.itemAt(fy * fieldWidth + fx).color = "indianred"
                } else if (fx / 2 == Math.round(fx / 2)) {
                    repa.itemAt(fy * fieldWidth + fx).color = "moccasin"
                } else if (fx / 2 != Math.round(fx / 2)) {
                    repa.itemAt(fy * fieldWidth + fx).color = "khaki"
                }
            }
        }
    }

    function getCordInfo(y, x) {
        return frozedIcons[y * (fieldWidth - 2) + x]
    }

    function countFilled() {
        var k = 0
        for (var iY = 0; iY < (fieldHeight - 2); iY++) {
            for (var iX = 0; iX < fieldWidth - 2; iX++) {
                if (frozedIcons[iY * (fieldWidth - 2) + iX] === "x")
                    k++
            }
        }
        return k * 100 / ((fieldWidth - 2) * (fieldHeight - 2 - 5))
    }

    function clearFrozens() {
        for (var iY = 0; iY < (fieldHeight - 2); iY++) {
            for (var iX = 0; iX < fieldWidth - 2; iX++) {
                frozedIcons[iY * (fieldWidth - 2) + iX] = "0"
                frozed.itemAt(iY * (fieldWidth - 2) + iX).color = "transparent"
            }
        }
        console.log(" cler")
    }

    function addFrozen(figure, oX, oY, clr) {
        if (game) {
            for (var iY = 0; iY < figure.length; iY++) {
                for (var iX = 0; iX < figure.length; iX++) {
                    if (figure[iY][iX] === "x") {
                        frozed.itemAt((iY + oY - 1) * (fieldWidth - 2)
                                      + (iX + oX - 1)).color = clr //-1
                        frozedIcons[(iY + oY - 1) * (fieldWidth - 2) + (iX + oX - 1)] = "x" //-1
                    }
                }
            }
            checkOnFullStacks()
            if (checkOnProblems(4)) {
                game = false
                fail()
            }
            fg.setFigure(nextFg.getFigure())
            nextFg.gen(-1)
        }
    }
    function checkOnFullStacks() {
        for (var k = 0; k < fieldHeight - 2; k++) {
            var s = ""
            var countOes = 0
            for (var j = 0; j < fieldWidth - 2; j++) {
                if (frozedIcons[k * (fieldWidth - 2) + j] !== "x") {
                    countOes++
                    break
                }
            }
            if (countOes == 0) {
                for (var e = fieldHeight - 2; e > 0; e--) {
                    if (e < k) {
                        for (var r = 0; r < fieldWidth - 2; r++) {
                            s = s + frozedIcons[e * (fieldWidth - 2) + r]
                            frozedIcons[(e + 1) * (fieldWidth - 2) + r]
                                    = frozedIcons[e * (fieldWidth - 2) + r]
                            frozed.itemAt(
                                        (e + 1) * (fieldWidth - 2) + r).color = frozed.itemAt(
                                        e * (fieldWidth - 2) + r).color
                        }
                    }
                }
                score += 100
                if (score >= maxScore)
                    maxScore = score
            }
        }
    }

    function checkOnProblems(y) {
        for (var j = 0; j < fieldWidth - 2; j++) {
            if (frozedIcons[y * (fieldWidth - 2) + j] === "x") {
                return true
            }
        }
        return false
    }

    function fail() {
        restartGame()
        game = true
        paused = false
        pause()
        status.color = "red"
        status.text = "Status: game losed (press P to continue)..."
    }

    function pause() {
        if (paused) {
            status.color = "green"
            status.text = "Status: playing..."
            paused = false
            foneMusic.play()
            gameTimer.start()
            timeController.start()
        } else {
            status.color = "deepskyblue"
            status.text = "Status: game paused (press P to continue)"
            paused = true
            foneMusic.pause()
            gameTimer.stop()
            timeController.stop()
        }
    }

    function restartGame() {
        fg.froze(scale, fieldWidth, fieldHeight)
        clearFrozens()
        stats.x = 75 + scale * fieldWidth
        nf.x = 55 + scale * fieldWidth
        status.x = 50 + scale * fieldWidth
        nextFg.x = 120 + scale * fieldWidth
        nextFg.gen(-1)
        if (score >= maxScore)
            maxScore = score
        if (timePlayed >= maxTimePlayed)
            maxTimePlayed = timePlayed
        score = 0
        gameTimer.interval = 1000
        timePlayed = 0
        gameTimer.start()
        foneMusic.play()
        timeController.restart()
        status.color = "green"
        status.text = "Status: playing..."
    }
    Audio {
        id: foneMusic
        source: "fone.mp3"
        loops: Audio.Infinite
    }
    //keys
    Item {
        focus: true
        Keys.onPressed: {
            if (gameTimer.running) {
                if (event.key === Qt.Key_Left || event.key === Qt.Key_A)
                    fg.moveLeft()
                if (event.key === Qt.Key_Right || event.key === Qt.Key_D)
                    fg.moveRight()
                if (event.key === Qt.Key_Up || event.key === Qt.Key_W)
                    fg.rotate(1)
                //if (event.key === Qt.Key_Down || event.key === Qt.Key_S)
                //    fg.forcedMoveDown()
                if (event.key === Qt.Key_Space)
                    fg.forcedMoveDown()
            }
            if (event.key === Qt.Key_R)
                restartGame()
            if (event.key === Qt.Key_P) {
                pause()
            }
        }
    }
}
