import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

import qs.config

Rectangle {
	property int minimumAlwaysShown: 0
	property var workspaceSymbols: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
	property string inactiveWorkspaceSymbol: "●"
	property var namedWorkspaces: []
	property var appIconOverrides: {}

	Layout.fillWidth: true
	Layout.preferredHeight: cl.implicitHeight + cl.anchors.topMargin + cl.anchors.bottomMargin

	color: Global.colors.foreground
	radius: Global.borderRadius

	ColumnLayout {
		id: cl
		anchors {
			fill: parent
			margins: Global.spacing
		}
		spacing: Global.spacing

		/* Workspace Button */
		Repeater {
			model: namedWorkspaces.concat(Array.from({length: workspaceSymbols.length}, (_, i) => i + 1))

			Rectangle {
				required property var modelData

				readonly property var isNamedWorkspace: typeof modelData === "string"

				readonly property var workspace: Hyprland.workspaces.values.find(w =>
					isNamedWorkspace ? w.name === modelData : w.id === modelData
				)

				readonly property bool isActive: isNamedWorkspace
					? Hyprland.focusedWorkspace?.name === modelData
					: Hyprland.focusedWorkspace?.id === modelData

				readonly property var workspaceIndex: !isNamedWorkspace ? modelData - 1 : null

				readonly property var appIcon: isNamedWorkspace ? (appIconOverrides[modelData] ?? modelData) : null

				visible: isNamedWorkspace || !(workspace == null && workspaceIndex >= minimumAlwaysShown)

				Layout.fillWidth: true
				Layout.preferredHeight: isActive ? this.width * 13/7 : this.width
				color: isActive || (isNamedWorkspace && hoverHandler.hovered)
					? !isNamedWorkspace ? Global.colors.primary : Global.colors.textGray
					: Global.colors.foreground2
				radius: Global.borderRadius

				Behavior on Layout.preferredHeight {
					NumberAnimation {
						duration: Global.animationDurationMS
						easing.type: Easing.OutCubic
					}
				}
				Behavior on color {
					ColorAnimation {
						duration: Global.animationDurationMS
						easing.type: Easing.OutCubic
					}
				}

				HoverHandler { id: hoverHandler }

				MouseArea {
					anchors.fill: parent
					onClicked: {
						var workspaceString = isNamedWorkspace
							? `"name:${modelData}"`
							: `${workspaceIndex + 1}`
						Hyprland.dispatch(`hl.dsp.focus({ workspace = ${workspaceString} })`)
					}
				}

				Item {
					anchors.fill: parent 

					IconImage {
						visible: isNamedWorkspace

						implicitSize: 18
						anchors.verticalCenter: parent.verticalCenter
						anchors.horizontalCenter: parent.horizontalCenter

						source: Quickshell.iconPath(appIcon)
						opacity: workspace != null ? 1.0 : 0.5
					}

					Text {
						visible: !isNamedWorkspace

						anchors.centerIn: parent

						text: isNamedWorkspace
							? modelData[0].toUpperCase()
							: workspace != null ? workspaceSymbols[workspaceIndex] : inactiveWorkspaceSymbol

						font {
							family: Global.fonts.monospaceFamily
							pixelSize: workspace != null || isNamedWorkspace
								? parent.width * 0.7
								: parent.width * 0.35
							bold: true
						}

						color: {
							if (isActive) { 
								Global.colors.textDark
							} else if (hoverHandler.hovered) {
								Global.colors.primary
							} else if (workspace != null) {
								Global.colors.textLight
							} else {
								Global.colors.textGray
							}
						}

						Behavior on color {
							ColorAnimation {
								duration: Global.animationDurationMS
								easing.type: Easing.OutCubic
							}
						}
					}
				}
			}
		}
	}
}
