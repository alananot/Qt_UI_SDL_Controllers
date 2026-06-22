import QtQuick
import QtQuick.Controls
import SDL 1.0
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Window
import QtQml
Window {

    id: window
    width: 1280
    height: 800
    visible: true
    visibility: Window.FullScreen
    title: qsTr("Hello World")
    color: "#2A2A59"
    property int leftX:0
    property int leftY:0
    property int rightX:0
    property int rightY:0
    property int x1_movement:0
    property int y1_movement:0

    property int x2_movement:0
    property int y2_movement:0

    property string status: "Intro"

    Rectangle{
        id: fadeoutintro
        anchors.fill: parent
        color: "black"
        opacity: 1.0
    }

    Item{
        id: program
        height: parent.height
        anchors.fill: parent
        focus: true
        opacity: 0
        Flow{
            flow: Flow.TopToBottom
            spacing: 10
            anchors.leftMargin: 30
            anchors.topMargin: 40
            id: box
            anchors.fill: parent
            ListModel{
                id: order
                ListElement {label: "States"}
                ListElement {label: "Debug"}
                ListElement {label: "Turretview"}
                ListElement {label: "Vehicle overview"}
                ListElement {label: "Speed"}

            }

            property var bigsize: [600,700]
            property var smallsize: [300,350]

            Repeater{
                model: order

                Button{
                    id: btn
                    text: model.label


                    width: index === 2 ? box.bigsize[0] : box.smallsize[0]
                    height: index === 2 ? box.bigsize[1]: box.smallsize[1]

                    Behavior on width {NumberAnimation{duration: 200}}
                    Behavior on x {NumberAnimation{duration: 200}}

                    onClicked:{
                        if(index !== 2){
                            let temp = order.get(2).label
                            order.set(2,{label:model.label})
                            order.set(index, {label:temp})
                        }
                    }
                }
            }
        }

        Rectangle{
            id: mouse2
            width: 20
            height: 20
            x:800
            y: 200
            color: "red"
        }

        Rectangle{
            id: mouse
            width: 20
            height: 20
            x:300
            y: 200
            color: "black"




            }

        Rectangle{
            id:connection
            opacity: 0
            width: 17
            height: 17
            radius: 180
            color:"#C4C4C4"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            Rectangle{
                id: status_light
                width: 13
                height: 13
                radius: 180
                color:"white"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
            SdlHelper{
                id: sdl



                onButtonPressed:{

                    if(status === "Intro"){
                    fadeOutAnimation.start()
                    fadeOutAnimation2.start()



                    fadeInAnimation.start()
                    fadeInAnimation2.start()
                        status = "Connected"
}
                    else{
                    console.log("Button being pressed", button)
                    if(button === 17)
                    {
                        status_light.color = "Green"
                    }
                    if(button === 16){
                        status_light.color = "yellow"
                    }
                    if(button === 18){
                        status_light.color = "white"
                    }


}



                }

            onAxisMoved:{
                if(status != "Intro")
                {
                switch(axis){
                     case 0:
                        if(Math.abs(value) > 5000){
                         leftX = value
                         //console.log("Axis 2 2 2", 0, "value", leftX);
                         x1_movement = Math.pow(Math.abs(leftX), 1/5)
                         if(leftX <0)
                             x1_movement = -x1_movement
                        }
                        else
                            x1_movement = 0
                         break;
                     case 1:
                         if(Math.abs(value) > 5000){
                         leftY = value
                         //console.log("Axis", 1, "value", leftY)
                         y1_movement = Math.pow(Math.abs(leftY), 1/5)
                         if(leftY <0)
                             y1_movement = -y1_movement
                        }
                         else
                             y1_movement = 0
                         break;
                     case 2:
                         if(Math.abs(value) > 5000){
                         rightX = value
                         //console.log("Axis", 2, "value", rightX)
                        x2_movement = Math.pow(Math.abs(rightX), 1/5)
                             if(rightX <0){
                                 x2_movement = -x2_movement
                             }

                         }
                         else
                             x2_movement = 0
                         break;
                     case 3:
                         if(Math.abs(value) > 5000){
                         rightY = value
                        // console.log("Axis", 3, "value", rightY)
                             y2_movement = Math.pow(Math.abs(rightY), 1/5)
                             if(rightY < 0){
                                 y2_movement = -y2_movement
                             }

                         }
                         else
                         {
                             y2_movement = 0
                         }

                         break;
                    }
                }



                //console.log(rightY)
                mouse2.x += x2_movement
                mouse2.y += y2_movement
                mouse.x += x1_movement
                mouse.y += y1_movement


                }
            }

        }
        Component.onCompleted:{
        if (!sdl.initGamepad()){
            console.log("SDL error: ", sdl.getError())
        }
        else{
            console.log("SDL initialized")
        }
    }

}
    Button{
        id: quit
        text: "Quit"

        onClicked:{
            window.close()
        }
    }
















    Image{
        id: saab_intro
        width: 800
        height: 800
        opacity: 1.0
        source: "Saab.jpg"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter


    }
    SdlHelper{
        id: intro

    onButtonPressed:{
        console.log("Button being pressed", button)


            fadeOutAnimation.start()
            fadeOutAnimation2.start()



            fadeInAnimation.start()
            fadeInAnimation2.start()




    }
    }
    Component.onCompleted:{
    if (!intro.initGamepad()){
        console.log("SDL error: ", intro.getError())
    }
    else{
        console.log("SDL initialized")
    }


}
    PropertyAnimation {
        id: fadeOutAnimation
        target: fadeoutintro
        property: "opacity"
        to: 0.0
        duration: 1000
        easing.type: Easing.OutQuad
    }
    PropertyAnimation {
        id: fadeOutAnimation2
        target: saab_intro
        property: "opacity"
        to: 0.0
        duration: 1000
        easing.type: Easing.OutQuad
    }

    PropertyAnimation {
        id: fadeInAnimation
        target: connection


        property: "opacity"
        to: 1.0
        duration: 1000
        easing.type: Easing.OutQuad
    }
    PropertyAnimation {
        id: fadeInAnimation2
        target: program

        property: "opacity"
        to: 1.0
        duration: 1000
        easing.type: Easing.OutQuad
    }




}


