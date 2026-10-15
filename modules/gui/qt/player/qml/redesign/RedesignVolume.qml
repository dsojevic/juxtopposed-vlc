// SPDX-License-Identifier: GPL-2.0-or-later
import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.Basic as C

T.Slider {
    id: root
    property real scaleFactor: 1
    property color accentColor: "#d37918"
    property bool lightTheme: false
    property bool muted: false
    property bool wheelActive: false
    readonly property RedesignTheme theme: RedesignTheme { scaleFactor: root.scaleFactor; lightTheme: root.lightTheme; accentColor: root.accentColor }
    implicitWidth: theme.dp(90)
    implicitHeight: theme.dp(28)
    from: 0
    to: 1.25
    stepSize: 0.05
    focusPolicy: Qt.StrongFocus
    hoverEnabled: true
    Accessible.name: qsTr("Volume")
    padding: 0
    handle: Item { width: 0; height: 0 }

    Timer {
        id: wheelSettleTimer
        interval: 300
        onTriggered: root.wheelActive = false
    }

    function stepBy(steps) {
        wheelActive = true
        wheelSettleTimer.restart()
        const stepDelta = steps * stepSize
        const target = Math.max(from, Math.min(to, Math.round((value + stepDelta) * 100) / 100))
        if (target !== value) {
            value = target
            moved()
        }
    }

    WheelHandler {
        id: wheelHandler
        orientation: Qt.Vertical | Qt.Horizontal
        acceptedDevices: PointerDevice.AllDevices
        onWheel: (wheel) => {
            let delta = 0
            if (Math.abs(wheel.angleDelta.y) >= Math.abs(wheel.angleDelta.x))
                delta = wheel.angleDelta.y
            else
                delta = wheel.angleDelta.x
            if (delta === 0) return

            const numSteps = Math.abs(delta) >= 120 ? Math.trunc(delta / 120) : (delta > 0 ? 1 : -1)
            root.stepBy(numSteps)
            wheel.accepted = true
        }
    }

    background: Item {
        RedesignSvg {
            id: cone
            anchors.fill: parent
            opacity: root.muted ? 0.3 : 1
            sourceSize: Qt.size(width * Screen.devicePixelRatio, height * Screen.devicePixelRatio)
            svg: {
                if (width <= 0 || height <= 0) return ""
                const path = "M2 " + (height * 0.35) + " L" + (width - 2) + " 1 Q" + width + " 1 " + width + " 4"
                    + " L" + width + " " + (height - 4) + " Q" + width + " " + (height - 1) + " " + (width - 2) + " " + (height - 1)
                    + " L2 " + (height * 0.65) + " Q0 " + (height * 0.65) + " 0 " + (height * 0.5) + " Z"
                function colorAt(fraction) {
                    const first = fraction <= 0.7 ? [109, 156, 0] : [212, 180, 0]
                    const last = fraction <= 0.7 ? [212, 180, 0] : [211, 121, 24]
                    const amount = fraction <= 0.7 ? fraction / 0.7 : (fraction - 0.7) / 0.3
                    return "#" + first.map((value, index) => Math.round(value + (last[index] - value) * amount).toString(16).padStart(2, "0")).join("")
                }
                const start = 2 / width
                const end = Math.min(1, (2 + root.position * (width - 4)) / width)
                const edge = 0.001 / width
                let stops = '<stop offset="0" stop-color="#090909"/>'
                if (root.position > 0) {
                    stops += '<stop offset="' + Math.max(0, start - edge) + '" stop-color="#090909"/>'
                        + '<stop offset="' + start + '" stop-color="' + colorAt(start) + '"/>'
                    if (start < 0.7 && end > 0.7)
                        stops += '<stop offset="0.7" stop-color="#d4b400"/>'
                    stops += '<stop offset="' + Math.max(start, end - edge) + '" stop-color="' + colorAt(end) + '"/>'
                        + '<stop offset="' + end + '" stop-color="#090909"/>'
                }
                stops += '<stop offset="1" stop-color="#090909"/>'
                return (
                    '<svg xmlns="http://www.w3.org/2000/svg" width="' + width + '" height="' + height + '" viewBox="0 0 ' + width + ' ' + height + '">'
                    + '<defs><linearGradient id="volume" gradientUnits="userSpaceOnUse" x1="0" y1="0" x2="' + width + '" y2="0">'
                    + stops + '</linearGradient></defs><path d="' + path + '" fill="url(#volume)"/></svg>')
            }
        }
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            radius: theme.dp(4)
            border.width: root.visualFocus ? theme.dp(1) : 0
            border.color: theme.accent
        }
    }
    RedesignToolTip { theme: root.theme; text: qsTr("%1%").arg(Math.round(root.value * 100)); visible: root.hovered || root.visualFocus || root.pressed || root.wheelActive; delay: 0 }
}
