import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import QtQuick.Effects
import Quickshell.Wayland

import qs.config

Item {
    id: root
    required property LockContext context
    readonly property ColorGroup colors: Windows.active ? palette.active : palette.inactive

    Image {
        id: wallpaper

        anchors.fill: parent

        source: "file:///home/kojo/Pictures/Gyro.jpg"
        fillMode: Image.PreserveAspectCrop
        opacity: 0.7
    }

    Text {
        anchors.fill: parent
        topPadding: 20
        horizontalAlignment: Text.Center
        // Translation: "Currently locked"
        text: "ロック中"
        font {
            bold: true
            family: "JetBrains Mono"
            pixelSize: 25
        }
        color: "#555"
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20

        Button {
            id: failsafe
            visible: false

            Layout.alignment: Qt.AlignCenter

            text: "It's not working, let me out"
            onClicked: context.unlocked();
        }

        Label {
            id: clock
            property var date: new Date()

            Layout.alignment: Qt.AlignCenter

            renderType: Text.NativeRendering
            font {
                family: "JetBrains Mono NL"
                pointSize: 80
            }
            color: "white"
            style: Text.Outline
            styleColor: "black"

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "black"
                shadowBlur: 0.5
                shadowOpacity: 1.0
            }

            Timer {
                running: true
                repeat: true
                interval: 1000

                onTriggered: clock.date = new Date();
            }

            text: {
                const hours = this.date.getHours().toString().padStart(2, '0');
                const minutes = this.date.getMinutes().toString().padStart(2, '0');
                return `${hours}:${minutes}`;
            }
        }

        ColumnLayout {
            // Show password field only on active monitor.
            // visible: Window.active

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter

            TextField {
                id: passwordBox

                implicitWidth: 500
                padding: 10

                font {
                    family: "JetBrains Mono NL"
                    pointSize: 14
                    letterSpacing: 5
                }
                horizontalAlignment: TextInput.AlignHCenter

                // placeholderText is hidden when horizontally aligned (Qt bug).
                // Translation: "Please enter password..."
                placeholderText: "パスワードを入力してください..."
                // Have to override cursorVisible after creation as well.
                onActiveFocusChanged: cursorVisible = false
                Text {
                    visible: passwordBox.text.length == 0
                    anchors.centerIn: parent
                    font.family: "JetBrains Mono NL"
                    font.pointSize: 14
                    color: "#888"
                    text: passwordBox.placeholderText
                }

                background: Rectangle {
                    color: "white"
                    border.color: "black"
                    border.width: 2
                    radius: 10
                    opacity: 0.8
                }

                focus: true
                enabled: !root.context.unlockInProgress
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhSensitiveData

                onTextChanged: root.context.currentText = this.text;

                onAccepted: root.context.tryUnlock();

                Connections {
                    target: root.context

                    function onCurrentTextChanged() {
                        passwordBox.text = root.context.currentText;
                    }
                }
            }

            Label {
                visible: root.context.showFailure

                Layout.alignment: Qt.AlignCenter

                text: "Nope!"

                font {
                    family: "JetBrains Mono"
                    pixelSize: 20
                    bold: true
                }
                color: "#CC0000"
            }
        }
    }
}
