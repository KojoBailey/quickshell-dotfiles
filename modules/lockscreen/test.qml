import QtQuick
import Quickshell

ShellRoot {
    LockContext {
        id: lockContext
        onUnlocked: Qt.quit();
    }

    FloatingWindow {
        LockSurface {
            anchors.fill: parent
            context: lockContext
        }
    }

    Connections {
        target: Quickshell

        function onLastWindowClosed() {
            Qt.quit();
        }
    }
}
