import Quickshell
import Quickshell.Wayland

import "modules/lockscreen"

ShellRoot {
    LockContext {
        id: lockContext

        onUnlocked: {
            lock.locked = false;

            Qt.quit();
        }
    }

    WlSessionLock {
        id: lock

        locked: true

        WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                context: lockContext
            }
        }
    }
}
