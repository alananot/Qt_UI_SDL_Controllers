import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import QtQuick.Window
import QtQml
import SDL 1.0
import Networking 1.0

Window {
    id: window
    width: 1280
    height: 800
    visible: true
    visibility: Window.FullScreen
    title: "Saab System UI"
    color: "#0B0E14"

    property bool lockedOn: false
    property var canisters: []
    property bool canister1: false
    property bool canister2: false
    property bool canister3: false
    property int targetX: 0
    property int targetY: 0
    property int speed: 0
    property real socketValue: 0.0
    property real socketValue2: 0.0
    property string status: "Intro"
    property bool isidle: false
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
    property int left_trig: 0
    property int smooth_cx: 0
    property int smooth_cy: 0


    Timer {
        interval: 80
        running: true
        repeat: true
        onTriggered: {
            var xhr = new XMLHttpRequest()
            xhr.open("GET", "http://192.168.4.200:8080/status")
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                    var data = JSON.parse(xhr.responseText)
                    window.lockedOn = data.locked
                    window.targetX = data.cx
                    window.targetY = data.cy
                }
            }
            xhr.send()
        }
    }

    TcpClient {
        id: tcpGraph
        property string network: ""
        onConnected: console.log("Connected to server")
        onMessageRecieved: {//socketValue = parseFloat(msg)
            network += msg
            if(network.indexOf("\n") !== -1){
                let cleanValue = network.replace("\r","").replace("\n","")
                socketValue = parseFloat(cleanValue)

                network = ""
            }


            console.log("message" +msg)
        console.log(socketValue)
        }

    }

    TcpClient {
        id: tcpButtons;
        onConnected: console.log("Buttons connected")
        onMessageRecieved: {
            canisters = msg
            canister1 = canisters[0]
            canister2 = canisters[1]
            canister3 = canisters[2]
            console.log(canisters)
        }



    }
    TcpClient { id: tcpJoystick; onConnected: console.log("Joysticks connected") }

    Timer {
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
        property double dataValue: 0

        Rectangle {
            anchors.fill: parent
            color: "#0B0E14"
            border.color: "#3A4A66"
            border.width: 2
            radius: 4
        }

        Canvas {
            anchors.fill: parent
            opacity: 0.3
            onPaint: {
                var ctx = getContext("2d")
                ctx.strokeStyle = graphRoot.gridColor
                ctx.lineWidth = 1
                for (var x = 0; x < width; x += 30) { ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, height); ctx.stroke() }
                for (var y = 0; y < height; y += 30) { ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(width, y); ctx.stroke() }
            }
        }

        property var points: [Qt.point(0, height/2)]

        Timer {
            interval: graphRoot.updateInterval
            running: true
            repeat: true
            onTriggered: {
                var p = graphRoot.points.slice()
                var newY = height/2 - (graphRoot.dataValue * (height * 0.4) - height * 0.2)
                //console.log("Graph value: " + graphRoot.dataValue)
                newY = Math.max(10, Math.min(height - 10, newY))

                p.push(Qt.point(p.length * 3, newY))
                while (p.length > 0 && p[p.length-1].x > width + 10) {
                    for (var i = 0; i < p.length; i++) p[i].x -= 3
                }
                if (p.length > (width / 3) + 5) p.shift()
                graphRoot.points = p
            }
        }

        Shape {
            anchors.fill: parent
            antialiasing: true
            clip: true
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
                for (var x = 0; x < width; x += 60) { ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, height); ctx.stroke() }
                for (var y = 0; y < height; y += 60) { ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(width, y); ctx.stroke() }
            }
        }

        Image {
            id: saabLogo
            source: "Saab.jpg"
            width: 1920
            height: 1920
            anchors.centerIn: parent
            opacity: 0.9
            fillMode: Image.PreserveAspectFit
        }

        // Connection lampa på intro - blinkar gult i connect state (req 2211)
        Rectangle {
            id: intro_lamp
            width: 24; height: 24; radius: 12
            color: "yellow"
            anchors.bottom: intro_text.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 15

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: intro_lamp.color === "yellow"
                NumberAnimation { from: 0.4; to: 1.0; duration: 600 }
                NumberAnimation { from: 1.0; to: 0.4; duration: 600 }
            }
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

        TcpClient {
            id: client
            onConnected: {
                console.log("Connected")
                intro_lamp.color = "green"
                fadeOutAnimation.start()
                fadeOutAnimation2.start()
                fadeOutHUD.start()
                fadeInAnimation2.start()
                status = "Operative"
                // Operative state: solid Green (req 2221)
                status_light.color = "green"
                client.sendMessage(status)
                is_idle_time.start()



                moved_timer.start()
            }
            onErrorOccurred: {
                if(status != "Intro"){
                status = "error"}
                intro_lamp.color = "red"
                intro_text.text = "Error: " + err
                status_light.color = "red"
            }
        }


    }

    /* ---------------- MAIN UI ---------------- */
    Rectangle { anchors.fill: parent; color: "#0B0E14" }

    Canvas {
        anchors.fill: parent
        opacity: 0.18
        onPaint: {
            var ctx = getContext("2d")
            ctx.strokeStyle = "#1A2333"
            ctx.lineWidth = 1
            for (var x = 0; x < width; x += 80) { ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, height); ctx.stroke() }
            for (var y = 0; y < height; y += 80) { ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(width, y); ctx.stroke() }
        }
    }

    // Graferna längst ner
    Row {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        anchors.bottomMargin: 10
        spacing: 10
        height: 150

        Graph {
            width: parent.width / 2 - 5
            height: parent.height
            lineColor: "#AFC7FF"
            dataValue: window.socketValue
        }

        Graph {
            width: parent.width / 2 - 5
            height: parent.height
            lineColor: "#FF5555"
            dataValue: window.socketValue2
        }
    }

    // Vänster kolumn - States
    Rectangle {
        id: statesPanel
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: graphRow.top
        anchors.leftMargin: 10
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        width: 300
        color: "#1A2333"
        border.color: "#3A4A66"
        border.width: 2
        radius: 4

        // States + LED centrerade i panelen
        Column {
            anchors.centerIn: parent
            spacing: 10

            // RGB Status Indicator LED (req 2211/2221/2231)
            // - Connect state:   flashing Yellow
            // - Operative state: solid Green
            // - Idle state:      solid White
            Rectangle {
                id: status_light
                width: 22; height: 22; radius: 11
                color: "yellow"
                anchors.horizontalCenter: parent.horizontalCenter

                // Glow-effekt
                layer.enabled: true
                layer.effect: null

                // Flashing Yellow animation - only active in Connect state (req 2211)
                SequentialAnimation on opacity {
                    id: connectBlink
                    loops: Animation.Infinite
                    running: status_light.color === "#ffff00" || status_light.color === "yellow"
                    NumberAnimation { from: 0.4; to: 1.0; duration: 600 }
                    NumberAnimation { from: 1.0; to: 0.4; duration: 600 }
                }
            }

            // CONNECT STATE
            Rectangle {
                width: 240; height: 50; radius: 4
                anchors.horizontalCenter: parent.horizontalCenter
                color: status === "Operative" ? "#0D2B1F" : "transparent"
                border.color: status === "Operative" ? "#00FF88" : "#2A3A55"
                border.width: 2
                Text {
                    text: "CONNECT STATE"
                    color: status === "Operative" ? "#00FF88" : "#6A7A99"
                    font.pixelSize: 17
                    font.bold: true
                    font.family: "Eurostile"
                    anchors.centerIn: parent
                }
            }

            // IDLE STATE
            Rectangle {
                width: 240; height: 50; radius: 4
                anchors.horizontalCenter: parent.horizontalCenter
                color: window.isidle ? "#2B2200" : "transparent"
                border.color: window.isidle ? "#FFCC00" : "#2A3A55"
                border.width: 2
                Text {
                    text: "IDLE STATE"
                    color: window.isidle ? "#FFCC00" : "#6A7A99"
                    font.pixelSize: 17
                    font.bold: true
                    font.family: "Eurostile"
                    anchors.centerIn: parent
                }
            }

            // OPERATIVE STATE
            Rectangle {
                width: 240; height: 50; radius: 4
                anchors.horizontalCenter: parent.horizontalCenter
                color: (status === "Operative" || status === "Operative") && !window.isidle ? "#131B2E" : "transparent"
                border.color: (status === "Operative" || status === "Operative") && !window.isidle ? "#AFC7FF" : "#2A3A55"
                border.width: 2
                Text {
                    text: "OPERATIVE STATE"
                    color: (status === "Operative" || status === "Operative") && !window.isidle ? "#AFC7FF" : "#6A7A99"
                    font.pixelSize: 17
                    font.bold: true
                    font.family: "Eurostile"
                    anchors.centerIn: parent
                }
            }
        }
    }

    // Höger kolumn - Speed
    Rectangle {
        id: speedPanel
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: graphRow.top
        anchors.rightMargin: 10
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        width: 300
        color: "#1A2333"
        border.color: "#3A4A66"
        border.width: 2
        radius: 4

        Column {
            anchors.centerIn: parent
            spacing: 20

            // Titel
            Text {
                text: "SPEED"
                font.pixelSize: 13
                font.bold: true
                font.family: "Eurostile"
                color: "#AFC7FF"
                opacity: 0.6
                anchors.horizontalCenter: parent.horizontalCenter
                font.letterSpacing: 3
            }

            // Stor siffra
            Text {
                text: window.speed
                font.pixelSize: 80
                font.bold: true
                font.family: "Eurostile"
                color: "#D6E1FF"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Enhet
            Text {
                text: "km/h"
                font.pixelSize: 16
                font.bold: true
                font.family: "Eurostile"
                color: "#AFC7FF"
                opacity: 0.5
                anchors.horizontalCenter: parent.horizontalCenter
                font.letterSpacing: 2
            }

            // Progressbar
            Rectangle {
                width: 220; height: 6; radius: 3
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#0B0E14"
                border.color: "#2A3A55"
                border.width: 1

                Rectangle {
                    height: parent.height
                    width: Math.min(parent.width, window.speed / 120 * parent.width)
                    radius: 3
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#AFC7FF" }
                        GradientStop { position: 1.0; color: "#00CFFF" }
                    }
                }
            }
        }
    }

    // Mitten - Turretview
    Item {
        id: turretItem
        anchors.left: statesPanel.right
        anchors.right: speedPanel.left
        anchors.top: parent.top
        anchors.bottom: graphRow.top
        anchors.margins: 10
        property bool showFirst: true

        Rectangle {
            anchors.fill: parent
            color: "#1A2333"
            border.color: window.lockedOn ? "#FF5555" : "#3A4A66"
            border.width: window.lockedOn ? 3 : 2
            radius: 4
        }

        Image {
            id: feed1
            anchors.fill: parent
            fillMode: Image.Stretch
            cache: false
            visible: turretItem.showFirst
            onStatusChanged: {
                if (status === Image.Ready) turretItem.showFirst = true
            }
        }

        Image {
            id: feed2
            anchors.fill: parent
            fillMode: Image.Stretch
            cache: false
            visible: !turretItem.showFirst
            onStatusChanged: {
                if (status === Image.Ready) turretItem.showFirst = false
            }
        }

        Timer {
            interval: 150
            running: true
            repeat: true
            onTriggered: {
                var url = "http://192.168.4.200:8080/video_frame?t=" + Date.now()
                if (turretItem.showFirst) {
                    feed2.source = url
                } else {
                    feed1.source = url
                }
            }
        }

        Rectangle {
            visible: window.lockedOn
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 15
            width: 130; height: 35
            color: "#8A1F1F"
            border.color: "#FF5555"
            border.width: 2
            radius: 4
            Text {
                anchors.centerIn: parent
                text: "LOCKED ON"
                color: "#FF5555"
                font.pixelSize: 16
                font.bold: true
                font.family: "Eurostile"
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { from: 0.3; to: 1.0; duration: 400 }
                    NumberAnimation { from: 1.0; to: 0.3; duration: 400 }
                }
            }
        }

        Canvas {
            anchors.fill: parent
            visible: window.targetX > 0
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                var sx = window.targetX / 640 * width
                var sy = window.targetY / 480 * height
                ctx.strokeStyle = window.lockedOn ? "#FF5555" : "#00FFFF"
                ctx.lineWidth = 2
                ctx.beginPath(); ctx.moveTo(sx - 20, sy); ctx.lineTo(sx + 20, sy); ctx.stroke()
                ctx.beginPath(); ctx.moveTo(sx, sy - 20); ctx.lineTo(sx, sy + 20); ctx.stroke()
                ctx.beginPath()
                ctx.arc(sx, sy, 15, 0, Math.PI * 2)
                ctx.stroke()
            }
            Connections {
                target: window
                function onTargetXChanged() { parent.requestPaint() }
                function onTargetYChanged() { parent.requestPaint() }
                function onLockedOnChanged() { parent.requestPaint() }
            }
        }
    }

    SdlHelper {
        id: sdl
        property bool locked: false
        onButtonPressed: {
            reset_idle()

            if (status == "Intro") {
                if (locked) return
                locked = true
                // Connect state: flashing Yellow (req 2211)
                intro_lamp.color = "yellow"
                intro_text.text = "Trying to Connect"
                client.connectToHost("192.168.4.1", 2222)
                tcpGraph.connectToHost("192.168.4.1", 2223)
                tcpButtons.connectToHost("192.168.4.1", 2224)
                tcpJoystick.connectToHost("192.168.4.1", 2225)
                status = "Operative"
                client.sendMessage(status)
                lockTimer.start()

                if(status != "error")
                {
                    status = "Operative"
                    client.sendMessage(status)
                }
            }
            else if(status !== "Intro") {
                switch(button) {
                case 0: a = 1; break
                case 1: b = 1; break
                case 2: x = 1; break
                case 3: y = 1; break
                case 9: shoulder_l = 1; break
                case 10: shoulder_r = 1; break
                }

                tcpButtons.sendMessage(a + "," + b + "," + x + "," + y + "," + shoulder_l + "," + shoulder_r)
            }
        }
        onButtonReleased: {
            if (status !== "Intro") {
                switch(button) {
                case 0: a = 0; break
                case 1: b = 0; break
                case 2: x = 0; break
                case 3: y = 0; break
                case 9: shoulder_l = 0; break
                case 10: shoulder_r = 0; break
                }
                tcpButtons.sendMessage(a + "," + b + "," + x + "," + y + "," + shoulder_l + "," + shoulder_r)
            }
        }

        onAxisMoved: {
            //moved_timer.restart()
            if (status !== "Intro") {
                status = "Operative"
                switch (axis) {
                case 0: x1_movement = Math.abs(value) > 15000 ? value : 0; break
                case 1: y1_movement = Math.abs(value) > 15000 ? value : 0; break
                case 2: x2_movement = Math.abs(value) > 15000 ? value : 0; break
                case 3: y2_movement = Math.abs(value) > 15000 ? value : 0; break
                }
                if (Math.abs(value) > 2000) reset_idle()
                console.log(x1_movement+ x2_movement)
                //console.log("axis moved")

                tcpJoystick.sendMessage(x1_movement + "," + y1_movement + "," + x2_movement + "," + y2_movement + "," + right_trig + "," + left_trig)
                //moved_timer.start()
            }
        }
    }

    Component.onCompleted: sdl.initGamepad()

    Item {
        id: graphRow
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 170
    }

    Button {
        z: 12
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
        onClicked: {
            client.sendMessage("connect")
            window.close()
                    }
    }
    Button{
        id: tutorialButton
        z: 12
        text: "Tutorial"
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20
        font.pixelSize: 18
        font.bold: true
        font.family: "Eurostile"
        background: Rectangle {
            radius: 4
            color: "#0B0E14"
            border.color: "#0B0E14"
            border.width: 2}
        onClicked: {
            if(tutorial.visible === false)
            tutorial.visible = true
            else
                tutorial.visible = false
        }

    }

    Rectangle{
        id: tutorial
        anchors.fill: parent
        visible: false
        color: "#1A2333"
        z: 11
        Text{
            text: "Controls"
            color: "white"
            font.pixelSize: 60
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text{
            color: "white"
            font.bold:true
            text: "Left Joystick  =  Movement/Steering "
            font.pixelSize: 30
            x: 50
            y: 80

        }
        Text{
            color: "white"
            font.bold:true
            text: "Right joystick  =  Turret Control/Movement"
            font.pixelSize: 30
            x: 50
            y: 120

        }
        Text{
            color: "white"
            font.bold:true
            text: "R1  =  Shoot "
            font.pixelSize: 30
            x: 50
            y: 160

        }
    }

    Timer {
        id: lockTimer
        interval: 1500
        repeat: false
        onTriggered: sdl.locked = false
    }

    // Idle timer: 5 minuter = 300 000 ms (req 2231)
    Timer {
        id: is_idle_time
        interval: 3000
        repeat: false
        onTriggered: {
            if (status != "Intro" && status != "error") {
                status = "idle"
                window.isidle = true

                //client.sendMessage(status)
                // Idle state: solid White (req 2231)
                status_light.color = "white"
                idle.start()
            }
        }
    }
    Timer{
        id: idle
        interval: 100
        repeat:true
        onTriggered: {
            client.sendMessage("idle")
        }

    }


    Timer{
        id: moved_timer
        interval: 1
        repeat:true
        onTriggered: {
            /*x1_movement = 0
            y1_movement = 0
            x2_movement = 0
            y2_movement = 0
            right_trig = 0
            left_trig = 0*/
            console.log("Joystick unmoved")
            tcpJoystick.sendMessage(x1_movement + "," + y1_movement + "," + x2_movement + "," + y2_movement + "," + right_trig + "," + left_trig)
        }
    }

    function reset_idle() {
        window.isidle = false
        if (status != "Intro" && status != "error") {
            // Operative state: solid Green (req 2221)
            status_light.color = "green"
        } else if (status == "error") {
            status_light.color = "red"
        } else {
            // Connect state: flashing Yellow (req 2211) - animation driven by color binding
            status_light.color = "yellow"
        }

        client.sendMessage(status)
        idle.stop()
        is_idle_time.restart()
    }

    PropertyAnimation { id: fadeOutAnimation;  target: fadeoutintro; property: "opacity"; to: 0.0; duration: 1000 }
    PropertyAnimation { id: fadeOutAnimation2; target: saabLogo;     property: "opacity"; to: 0.0; duration: 1000 }
    PropertyAnimation { id: fadeOutHUD;        target: hudIntro;     property: "opacity"; to: 0.0; duration: 1200 }
    PropertyAnimation { id: fadeInAnimation2;  target: turretItem;   property: "opacity"; to: 1.0; duration: 1000 }
}
