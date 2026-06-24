import QtQuick
import QtQuick.Controls
import SDL 1.0
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Window
import QtQml
import Networking 1.0
Window {
    id: window
    width: 1280
    height: 800
    visible: true
    visibility: Window.FullScreen
    title: "Saab System UI"
    color: "#0B0E14"

    MouseArea{
        anchors.fill: parent
        enabled: false
    }

    property int a: 0
    property int b: 0
    property int y: 0
    property int x: 0
    property int shoulder_r: 0
    property int shoulder_l: 0

    property int leftX: 0
    property int leftY: 0
    property int rightX: 0
    property int rightY: 0
    property real x1_movement: 0.0
    property real y1_movement: 0.0
    property real x2_movement: 0.0
    property real y2_movement: 0.0
    property int right_trig: 0
    property int  left_trig: 0
    property string status: "Intro"
    property int speed: 0
    property double socketValue: 0
    property bool isidle: false
    property var buttons: {
        "a" : 0,
        "b" : 0,
        "x" : 0,
        "y" : 0,
        "shoulder_l": 0,
        "shoulder_r": 0
    }

    /* ==================== GRAPH COMPONENT ==================== */
    TcpClient{
        id: tcpGraph
        onConnected : {
            console.log("Connected to server")
        }

        onMessageRecieved:{

            socketValue = parseInt(msg)

        }


    }
    TcpClient{
    id: tcpButtons
    onConnected:{
        console.log("Buttons connected")
    }
    }
    TcpClient{
    id: tcpJoystick
    onConnected:{
        console.log("Joysticks connected")
    }
    }

    Timer{
        interval: 50
        running: true
        repeat: true
        onTriggered: tcpGraph.sendMessage("READ\n")
    }

    component Graph: Item {
        id: graphRoot


        property color lineColor: "#AFC7FF"
        property color gridColor: "#1A2333"
        property real lineWidth: 2.5
        property int updateInterval: 40
        property real amplitude: 0.65
        property string title: "DEBUG SIGNAL"

        // Bakgrund
        Rectangle {
            anchors.fill: parent
            color: "#0B0E14"
            border.color: "#3A4A66"
            border.width: 2
            radius: 4
        }
        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d")
                ctx.strokeStyle = "#4A5A7A"
                ctx.lineWidth = 2

                // Y‑axel (vänster)
                ctx.beginPath()
                ctx.moveTo(40, 0)
                ctx.lineTo(40, height)
                ctx.stroke()

                // X‑axel (botten)
                ctx.beginPath()
                ctx.moveTo(0, height - 30)
                ctx.lineTo(width, height - 30)
                ctx.stroke()
            }
        }
        Text {
            text: "0"
            color: "white"
            x: 5
            y: graphRoot.height - 45
        }

        Text {
            text: "Max"
            color: "white"
            x: 5
            y: 10
        }

        Text {
            text: "Time →"
            color: "white"
            anchors.horizontalCenter: parent.horizontalCenter
            y: graphRoot.height - 25
        }



        // Grid
        Canvas {
            anchors.fill: parent
            opacity: 0.3
            onPaint: {
                var ctx = getContext("2d")
                ctx.strokeStyle = graphRoot.gridColor
                ctx.lineWidth = 1
                for (var x = 0; x < width; x += 30) {
                    ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, height); ctx.stroke();
                }
                for (var y = 0; y < height; y += 30) {
                    ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(width, y); ctx.stroke();
                }
            }
        }

        // Punkter för grafen
        property var points: [Qt.point(0, height/2)]

        Timer {
            interval: graphRoot.updateInterval
            running: true
            repeat: true
            onTriggered: {
                var p = graphRoot.points.slice()
                var newY = height/2 + (window.socketValue * (height * 0.4) - height * 0.2)

                // Begränsa Y-värdet så det inte går utanför
                newY = Math.max(10, Math.min(height - 10, newY))

                p.push(Qt.point(p.length * 3, newY))

                // Skifta punkter om de går utanför
                while (p.length > 0 && p[p.length-1].x > width + 10) {
                    for (var i = 0; i < p.length; i++) {
                        p[i].x -= 3
                    }
                }

                // Ta bort gamla punkter
                if (p.length > (width / 3) + 5) {
                    p.shift()
                }

                graphRoot.points = p
            }
        }

        // Grafen med clipping
        Shape {
            anchors.fill: parent
            antialiasing: true
            clip: true                    // <-- VIKTIGASTE FIXEN

            ShapePath {
                strokeColor: graphRoot.lineColor
                strokeWidth: graphRoot.lineWidth
                fillColor: "transparent"
                startX: 0
                startY: graphRoot.height / 2
                PathPolyline { path: graphRoot.points }
            }
        }

    }


    /* ---------------- INTRO ---------------- */
    Rectangle {
        id: fadeoutintro
        anchors.fill: parent
        color: "#0B0E14"
        opacity: 1.0
        z: 10
    }


    Rectangle {
        id: hudIntro
        anchors.fill: parent
        color: "#0B0E14"
        opacity: 1.0
        z: 11

        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d")
                ctx.strokeStyle = "#1A2333"
                ctx.lineWidth = 1
                for (var x = 0; x < width; x += 60) { ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, height); ctx.stroke(); }
                for (var y = 0; y < height; y += 60) { ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(width, y); ctx.stroke(); }
            }
        }

        Image {
            id: saabLogo
            source: "Saab.jpg"
            width: 420
            height: 420
            anchors.centerIn: parent
            opacity: 0.9
            fillMode: Image.PreserveAspectFit
        }

        Text {
            id: intro_text
            text: "PRESS ANY BUTTON TO START"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 120
            font.pixelSize: 32
            font.bold: true
            font.family: "Eurostile"
            color: "#AFC7FF"

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { from: 0.2; to: 1.0; duration: 900 }
                NumberAnimation { from: 1.0; to: 0.2; duration: 900 }
            }
        }


        TcpClient{
        id: client
        onConnected:
        {console.log("Connected")


            fadeOutAnimation.start()
            fadeOutAnimation2.start()
            fadeOutHUD.start()
            //fadeInAnimation.start()
            fadeInAnimation2.start()
            status = "operative"
            status_light.color = "green"
            client.sendMessage(status)



        }
        onErrorOccurred: {
            status = "error"
            intro_text.text = "Error: " + err
            status_light.color = "red"
        }

        }


        SdlHelper {
            id: intro
            property bool locked: false


            onButtonPressed: {
                if(status == "Intro"){
                if (locked) return

                locked = true
                intro_text.text = "Trying to Connect"

                client.connectToHost("192.168.1.146", 2222)      // HUD
                tcpGraph.connectToHost("192.168.1.146", 2223)    // GPIO
                tcpButtons.connectToHost("192.168.1.146", 2224)  // Knappar
                tcpJoystick.connectToHost("192.168.1.146", 2225) //Joystick
                lockTimer.start()
            }}

        }

        Component.onCompleted: intro.initGamepad()
    }

    /* ---------------- MAIN PROGRAM ---------------- */
    Item {
        id: program
        anchors.fill: parent
        opacity: 0

        Rectangle { anchors.fill: parent; color: "#0B0E14" }

        Canvas {
            anchors.fill: parent
            opacity: 0.18
            onPaint: {
                var ctx = getContext("2d")
                ctx.strokeStyle = "#1A2333"
                ctx.lineWidth = 1
                for (var x = 0; x < width; x += 80) { ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, height); ctx.stroke(); }
                for (var y = 0; y < height; y += 80) { ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(width, y); ctx.stroke(); }
            }
        }

        Flow {
            id: box
            anchors.fill: parent
            anchors.leftMargin: 40
            anchors.topMargin: 40
            spacing: 20
            flow: Flow.TopToBottom

            ListModel {
                id: order
                ListElement { label: "States" }
                ListElement { label: "Debug" }
                ListElement { label: "Turretview" }
                ListElement { label: "Vehicle overview" }
                ListElement { label: "Speed" }
            }

            property var bigsize: [600, 700]
            property var smallsize: [300, 350]

            Repeater {
                model: order
                Button {
                    id: btn
                    text: model.label
                    font.pixelSize: 20
                    font.bold: true
                    font.family: "Eurostile"
                    width: index === 2 ? box.bigsize[0] : box.smallsize[0]
                    height: index === 2 ? box.bigsize[1] : box.smallsize[1]

                    background: Rectangle {
                        radius: 4
                        color: "#1A2333"
                        border.color: "#3A4A66"
                        border.width: 2
                    }

                    contentItem: Text {
                        text: btn.text
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 10
                        color: "#D6E1FF"
                        font: btn.font
                    }

                    // Debug panel
                    Item {
                        anchors.fill: parent
                        visible: btn.text === "Debug"
                        Graph {
                            anchors.fill: parent
                            anchors.margins: 10
                        }
                    }

                    // Turretview panel
                    Item {
                        anchors.fill: parent
                        visible: btn.text === "Turretview"
                    }

                    // States panel
                    Item {
                        anchors.fill: parent
                        visible: btn.text === "States"
                        Column {
                            anchors.centerIn: parent
                            spacing: 12
                            Text { text: "CONNECT STATE"; color: "#D6E1FF"; font.pixelSize: 18; font.bold: true }
                            Text { text: "IDLE STATE"; color: "#D6E1FF"; font.pixelSize: 18; font.bold: true }
                            Text { text: "OPERATIVE STATE"; color: "#D6E1FF"; font.pixelSize: 18; font.bold: true }
                        }
                    }

                    // Speed panel
                    Item {
                        anchors.fill: parent
                        visible: btn.text === "Speed"
                        Column {
                            anchors.centerIn: parent
                            spacing: 15
                            Text { text: "SPEED"; font.pixelSize: 22; font.bold: true; color: "#D6E1FF" }
                            Rectangle {
                                width: parent.width * 0.8; height: 30; radius: 4; color: "#0B0E14"; border.color: "#3A4A66"; border.width: 2
                                Rectangle {
                                    height: parent.height
                                    width: Math.min(parent.width, window.speed * 2)
                                    color: "#D6E1FF"
                                }
                            }
                            Text { text: "Speed: " + window.speed + " km/h"; font.pixelSize: 18; color: "#D6E1FF" }
                        }
                    }

                    onClicked: {
                        if (index !== 2) {
                            let temp = order.get(2).label
                            order.set(2, { label: model.label })
                            order.set(index, { label: temp })
                        }
                    }
                }
            }
        }

        Rectangle { id: mouse; width: 20; height: 20; radius: 2; x: 300; y: 200; color: "#D6E1FF"; border.color: "#3A4A66"; border.width: 1 }
        Rectangle { id: mouse2; width: 20; height: 20; radius: 2; x: 800; y: 200; color: "#FF5555"; border.color: "#3A4A66"; border.width: 1 }


    }
    Rectangle {
        id: connection
        z : 12
        opacity: 1
        width: 22; height: 22; radius: 2; color: "#1A2333"
        border.color: "#3A4A66"; border.width: 2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20

        Rectangle {
            id: status_light
            width: 14; height: 14; radius: 2
            anchors.centerIn: parent
            color: "yellow"
        }


        SdlHelper {
            id: sdl
            onButtonPressed: {
                reset_idle()
                console.log("Button pressed!!!")

                if (status !== "Intro") {

                    // SKICKA KNAPPTRYCKNING TILL SERVERN
                    switch(button){
                    case 0: a = 1; break
                    case 1: b = 1; break
                    case 2: x = 1; break
                    case 3: y = 1; break
                    case 9: shoulder_l = 1; break
                    case 10: shoulder_r =1; break
                    }
                    console.log(button)

                    tcpButtons.sendMessage(a + "," + b + "," + x + "," + y + "," + shoulder_l + "," + shoulder_r)
                    console.log(a + "," + b + "," + x + "," + y + "," + shoulder_l + "," + shoulder_r)

                }
            }
            onButtonReleased: {

                console.log("Button released!!!")
                if (status !== "Intro") {

                    // SKICKA KNAPPTRYCKNING TILL SERVERN
                    switch(button){
                    case 0: a = 0; break
                    case 1: b = 0; break
                    case 2: x = 0; break
                    case 3: y = 0; break
                    case 9: shoulder_l = 0; break
                    case 10: shoulder_r =0; break
                    }
                    console.log(button)

                    tcpButtons.sendMessage(a + "," + b + "," + x + "," + y + "," + shoulder_l + "," + shoulder_r)
                    console.log(a + "," + b + "," + x + "," + y + "," + shoulder_l + "," + shoulder_r)

                }
            }


            onAxisMoved: {

                if (status !== "Intro") {
                    status = "Operative"


                    switch (axis) {
                    case 0: x1_movement = Math.abs(value) > 2000 ? value : 0; break
                    case 1: y1_movement = Math.abs(value) > 2000 ? value : 0; break
                    case 2: x2_movement = Math.abs(value) > 2000 ? value : 0; break
                    case 3: y2_movement = Math.abs(value) > 2000 ? value : 0; break
                    case 4: console.log(value); break
                    case 5: console.log(value); break

                    }

                    if(Math.abs(value) > 2000)
                    {
                        reset_idle()
                    }

                    /*switch (axis) {
                    case 0: x1_movement = Math.abs(value) > 5000 ? Math.sign(value) * Math.pow(Math.abs(value), 0.2) : 0; break
                    case 1: y1_movement = Math.abs(value) > 5000 ? Math.sign(value) * Math.pow(Math.abs(value), 0.2) : 0; break
                    case 2: x2_movement = Math.abs(value) > 5000 ? Math.sign(value) * Math.pow(Math.abs(value), 0.2) : 0; break
                    case 3: y2_movement = Math.abs(value) > 5000 ? Math.sign(value) * Math.pow(Math.abs(value), 0.2) : 0; break
                    }*/

                    mouse.x += x1_movement
                    mouse.y += y1_movement
                    mouse2.x += x2_movement
                    mouse2.y += y2_movement
                    tcpJoystick.sendMessage(x1_movement+"," +y1_movement + "," + x2_movement+ "," +  y2_movement+ "," + right_trig + "," + left_trig)
                }
            }
        }

    }

    Component.onCompleted: sdl.initGamepad()

    /* Quit button */
    Button {
        z:11
        id: quit
        text: "Quit"
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 20
        font.pixelSize: 18
        font.bold: true
        font.family: "Eurostile"

        background: Rectangle {
            radius: 4
            color: "#8A1F1F"
            border.color: "#C44A4A"
            border.width: 2
        }

        contentItem: Text {
            text: quit.text
            anchors.centerIn: parent
            color: "white"
            font: quit.font
        }

        onClicked: window.close()
    }

    Timer{
    id: lockTimer
    interval: 1500
    repeat: false
    onTriggered: intro.locked = false

    }
    Timer{
    id: is_idle_time
    interval: 6000
    repeat: false
    onTriggered:{
        if(status != "Intro" && status != "error")
        {
        window.isidle = true
        console.log("System is now idle")
        status_light.color = "white"
        }
    }
    }
    function reset_idle(){
        console.log("Nuvarande status: "+status)
        if(window.isidle){
            console.log("Exiting idle state")
        }
        window.isidle = false
        if(status != "intro" && status != "error"){
        status_light.color = "green"

        }
        else if(status == "error"){
            status_light.color = "red"
        }

        else{
            status_light.color = "yellow"
        }
        client.sendMessage(status)
        is_idle_time.restart()
    }



    /* Animations */
    PropertyAnimation { id: fadeOutAnimation; target: fadeoutintro; property: "opacity"; to: 0.0; duration: 1000 }
    PropertyAnimation { id: fadeOutAnimation2; target: saabLogo; property: "opacity"; to: 0.0; duration: 1000 }
    PropertyAnimation { id: fadeOutHUD; target: hudIntro; property: "opacity"; to: 0.0; duration: 1200 }
    //PropertyAnimation { id: fadeInAnimation; target: connection; property: "opacity"; to: 1.0; duration: 1000 }
    PropertyAnimation { id: fadeInAnimation2; target: program; property: "opacity"; to: 1.0; duration: 1000 }


}