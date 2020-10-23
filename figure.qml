import QtQuick 2.0

Item {
    //cur props
    property int scale: 25
    property int oX: 0
    property int oY: 0
    property int rotX: 0
    property int rotY: 0
    property int randKick: 0
    property int fieldWight: 0
    property int fieldHeight: 0
    property int figureNumb: 0
    property int dir: 0
    property color col: "transparent"
    property var figure: [["0", "0", "0", "0"], ["0", "0", "0", "0"], ["0", "0", "0", "0"], ["0", "0", "0", "0"]]


    /*functions
    ==========================================================
        move...() - moves figure to ...
        checkOn....Collision() - checks figure do not flip with other in ... direction
        rotate(dirChange) - rotates figure to(-1 = -90 grad and 1 = 90 grad)
        froze(scale, fieldWdth, fieldHght) - creates froze field and froze cur figure
        gen() - refresh figure stats
        getRandomInt(max) -
        drawFigure() - redraw figure use new coords and color
    ===========================================================
    */

    //basics -- down
    Repeater {
        id: repa
        model: 16
        Rectangle {
            x: scale * 0
            y: scale * 0
            width: 50
            height: 50
            radius: 50 / 10
            color: col != "" ? col : "transparent"
        }
    }

    //public f
    function setFigure(figureNumb) {
        ///
        gen(figureNumb)
        drawFigure()
    }
    function getFigure() {
        return figureNumb
    }
    function getColor() {
        return col
    }
    function moveLeft() {
        if (checkOnLeftCollision() === 0) {
            oX--
            drawFigure()
        }
    }

    function moveRight() {
        if (checkOnRightCollision() === 0) {
            oX++
            drawFigure()
        }
    }

    function moveDown() {
        if (checkOnBottomCollision() === 0) {
            oY++
            drawFigure()
        }
    }

    function forcedMoveDown() {
        while (checkOnBottomCollision() === 0) {
            //console.log("oy ", oY + 3)
            oY++
            drawFigure()
        }
    }

    //////////////////////////////////////============
    /////////////////////////////////////////==============
    /////////////////////////////////////////==============
    ///////////////////////////////////////////==============
    function rotate(dirCh) {
        dir += dirCh
        if (dir >= 4)
            dir = 0
        if (dir <= -1)
            dir = 3
        //getCordInfo
        var allow = true
        for (var nY = 0; nY < figs[dir][figureNumb].length; nY++) {
            for (var nX = 0; nX < figs[dir][figureNumb].length; nX++) {
                if ((figs[dir][figureNumb][nX][nY] === "x" && getCordInfo(nY + oY - 1, nX + oX + randKick - 1) === "x") || (nY + oY >= fieldHeight - 1) || (nY + oY - 1 < 1) || (nX + oX + randKick < 1) || (nX + oX + randKick >= fieldWidth - 1)) {
                    allow = false
                    console.log("disallow ", nX + oX + randKick, nY + oY)
                    break
                }
            }
        }
        if (allow) {
            for (nY = 0; nY < figs[dir][figureNumb].length; nY++) {
                for (nX = 0; nX < figs[dir][figureNumb].length; nX++) {
                    figure[nX][nY] = figs[dir][figureNumb][nX][nY]
                }
            }
            drawFigure()
        }
    }

    function froze(sc, fieldWdth, fieldHght) {
        fieldWight = fieldWdth
        fieldHeight = fieldHght
        scale = sc
        addFrozen(figure, oX + randKick + rotX, oY + rotY, col)
        //gen()
    }

    function gen(k) {
        dir = 0
        var c = getRandomInt(8)
        if (k !== -1)
            c = k
        for (var nY = 0; nY < figs[dir][figureNumb].length; nY++) {
            for (var nX = 0; nX < figs[dir][figureNumb].length; nX++) {
                figure[nY][nX] = figs[dir][c][nY][nX]
            }
        }
        //timed
        figureNumb = c //c
        col = colors[c] //c
        randKick = getRandomInt(fieldWight - figure.length - 1)
        oX = 1
        oY = 1
        drawFigure()
    }

    //other
    function getRandomInt(max) {
        return Math.floor(Math.random() * Math.floor(max))
    }

    function drawFigure() {
        for (var i = 0; i < figure.length; i++) {
            for (var j = 0; j < figure.length; j++) {
                if (figure[i][j] === "x") {
                    repa.itemAt(i * figure.length + j).color = col
                    repa.itemAt(i * figure.length + j).x = scale * (j + oX + rotX + randKick)
                    repa.itemAt(i * figure.length + j).y = scale * (i + oY + rotY)
                    repa.itemAt(i * figure.length + j).width = scale
                    repa.itemAt(i * figure.length + j).height = scale
                    repa.itemAt(i * figure.length + j).radius = scale / 6
                } else {
                    repa.itemAt(i * figure.length + j).color = "transparent"
                }
            }
        }
    }

    function flipNumb(x) {
        if (x < 0)
            return abs(x)
        else
            return -x
    }

    function checkOnLeftCollision() {
        for (var iY = 0; iY < figure.length; iY++) {
            for (var iX = 0; iX < figure.length; iX++) {
                if (figure[iY][iX] === "x") {
                    if (iX + oX + rotX - 1 + randKick <= 0)
                        return 1
                    if (getCordInfo(iY + oY + rotY - 1,
                                    iX + oX + rotX + randKick - 2) === "x")
                        return 1
                }
            }
        }
        return 0
    }
    function checkOnRightCollision() {
        for (var iY = 0; iY < figure.length; iY++) {
            for (var iX = 0; iX < figure.length; iX++) {
                if (figure[iY][iX] === "x") {
                    if (iX + oX + rotX + randKick + 2 >= fieldWight)
                        return 1
                    if (getCordInfo(iY + oY + rotY - 1,
                                    iX + oX + rotX + randKick) === "x")
                        return 1
                }
            }
        }
        return 0
    }

    function checkOnBottomCollision() {
        for (var iY = 0; iY < figure.length; iY++) {
            for (var iX = 0; iX < figure.length; iX++) {
                if (figure[iY][iX] === "x") {
                    if (iY + oY + rotY + 2 >= fieldHeight) {
                        froze(scale, fieldWidth, fieldHeight)
                        return 1
                    }
                    if (getCordInfo(iY + rotY + oY,
                                    iX + oX + rotX + randKick - 1) === "x") {
                        froze(scale, fieldWidth, fieldHeight)
                        return 1
                    }
                }
            }
        }
        return 0
    }

    //basics
    property var colors: ["crimson", "forestgreen", "deepskyblue", "darkorchid", "darkturquoise", "greenyellow", "darkorange", "indigo", "grey"]
    //////
    property var ff: [["0", "0", "0", "0"], ["0", "0", "0", "0"], ["0", "0", "0", "0"], ["0", "0", "0", "0"]]
    // Empty
    property var f00: [["x", "x", "0", "0"], ["x", "x", "0", "0"], ["0", "0", "0", "0"], ["0", "0", "0", "0"]] // O

    property var f01: [["0", "x", "0", "0"], ["0", "x", "0", "0"], ["0", "x", "0", "0"], ["0", "x", "0", "0"]] // I
    property var f02: [["0", "x", "x", "0"], ["x", "x", "0", "0"], ["0", "0", "0", "0"], ["0", "0", "0", "0"]] // S
    property var f03: [["x", "x", "0", "0"], ["0", "x", "x", "0"], ["0", "0", "0", "0"], ["0", "0", "0", "0"]] // Z

    property var f11: [["0", "0", "0", "0"], ["x", "x", "x", "x"], ["0", "0", "0", "0"], ["0", "0", "0", "0"]] // I
    property var f12: [["x", "0", "0", "0"], ["x", "x", "0", "0"], ["0", "x", "0", "0"], ["0", "0", "0", "0"]] // S
    property var f13: [["0", "x", "0", "0"], ["x", "x", "0", "0"], ["x", "0", "0", "0"], ["0", "0", "0", "0"]] // Z

    property var f04: [["x", "0", "x", "0"], ["x", "x", "x", "0"], ["0", "0", "0", "0"], ["0", "0", "0", "0"]] // U
    property var f05: [["0", "0", "0", "0"], ["0", "x", "x", "x"], ["0", "x", "0", "0"], ["0", "0", "0", "0"]] // L
    property var f06: [["0", "0", "0", "0"], ["0", "x", "x", "x"], ["0", "0", "x", "0"], ["0", "0", "0", "0"]] // T
    property var f07: [["0", "0", "0", "0"], ["0", "x", "x", "x"], ["0", "0", "0", "x"], ["0", "0", "0", "0"]] // J

    property var f14: [["x", "x", "0", "0"], ["x", "0", "0", "0"], ["x", "x", "0", "0"], ["0", "0", "0", "0"]] // U
    property var f15: [["0", "0", "x", "0"], ["0", "0", "x", "0"], ["0", "0", "x", "x"], ["0", "0", "0", "0"]] // L
    property var f16: [["0", "0", "x", "0"], ["0", "0", "x", "x"], ["0", "0", "x", "0"], ["0", "0", "0", "0"]] // T
    property var f17: [["0", "0", "x", "x"], ["0", "0", "x", "0"], ["0", "0", "x", "0"], ["0", "0", "0", "0"]] // J

    property var f24: [["x", "x", "x", "0"], ["x", "0", "x", "0"], ["0", "0", "0", "0"], ["0", "0", "0", "0"]] // U
    property var f25: [["0", "0", "0", "x"], ["0", "x", "x", "x"], ["0", "0", "0", "0"], ["0", "0", "0", "0"]] // L
    property var f26: [["0", "0", "x", "0"], ["0", "x", "x", "x"], ["0", "0", "0", "0"], ["0", "0", "0", "0"]] // T
    property var f27: [["0", "x", "0", "0"], ["0", "x", "x", "x"], ["0", "0", "0", "0"], ["0", "0", "0", "0"]] // J

    property var f34: [["x", "x", "0", "0"], ["0", "x", "0", "0"], ["x", "x", "0", "0"], ["0", "0", "0", "0"]] // U
    property var f35: [["0", "x", "x", "0"], ["0", "0", "x", "0"], ["0", "0", "x", "0"], ["0", "0", "0", "0"]] // L
    property var f36: [["0", "0", "x", "0"], ["0", "x", "x", "0"], ["0", "0", "x", "0"], ["0", "0", "0", "0"]] // T
    property var f37: [["0", "0", "x", "0"], ["0", "0", "x", "0"], ["0", "x", "x", "0"], ["0", "0", "0", "0"]] // J
    ///
    property var figs0: [f00, f01, f02, f03, f04, f05, f06, f07]
    property var figs1: [f00, f11, f12, f13, f14, f15, f16, f17]
    property var figs2: [f00, f01, f02, f03, f24, f25, f26, f27]
    property var figs3: [f00, f11, f12, f13, f34, f35, f36, f37]
    property var figs: [figs0, figs1, figs2, figs3]
}
