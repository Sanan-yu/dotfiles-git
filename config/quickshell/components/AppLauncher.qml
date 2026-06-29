import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Qt5Compat.GraphicalEffects
import Qt.labs.folderlistmodel

import M3Shapes
import qs.components.reusable
import qs.theming

import "root:/sys/fuzzysort.js" as Fuzzy

PanelWindow {
	id: appWin
	anchors {
		left: true
		bottom: true
		top: true
	}
	margins.left: 5
	margins.bottom: 5
	exclusionMode: ExclusionMode.Normal
	color: "transparent"
	mask: Region{item: appWin.isOpened ? container : null;}
	implicitWidth: 400 
	focusable: isOpened

	property string query: ""
	property int currentTab: 0
	property bool isOpened: false
	property var appFinder: null
	property string currentFilesPath: Quickshell.workingDirectory

	property var globalResultsCache: []
	property bool isGlobalSearchMode: false
	
	// Music Properties
	property var musicCache: []

	Process {
		id: openFile
		property string app
		command: ["sh", "-c", "xdg-open '" + app + "'"]
	}

	Process {
		id: globalFileSearch
		command: ["fd", "--type", "f", "--type", "d", "--hidden", "--exclude", ".git", appWin.query, Quickshell.env("HOME") || "/"]

		stdout: StdioCollector {
			onStreamFinished: {
				const data = this.text;
				if (!data) return;

				const lines = data.split("\n").filter(line => line.trim() !== "");

				var results = lines.map(line => {
					const parts = line.split("/");
					const name = parts[parts.length - 1];
					const isDir = line.endsWith("/"); 

					return {
						name: name,
						isDir: isDir,
						path: line
					};
				});

				appWin.globalResultsCache = results;
				filteredFiles.update();
			}
		}
	}

	// Search for music files on startup
	Process {
		id: musicSearchProcess
		// Searches for common audio extensions recursively from HOME
		command: ["fd", "-t", "f", "-e", "mp3", "-e", "flac", "-e", "wav", "-e", "ogg", "-e", "m4a", ".", Quickshell.env("HOME")]
		
		stdout: StdioCollector {
			onStreamFinished: {
				const data = this.text;
				if (!data) return;

				const lines = data.split("\n").filter(line => line.trim() !== "");
				appWin.musicCache = lines.map(line => {
					const parts = line.split("/");
					const name = parts[parts.length - 1];
					return {
						name: name,
						path: line
					};
				});
			}
		}
	}

	function launchSelected() {
		if (appWin.currentTab === 0 && appsGridView.currentItem && appsGridView.currentItem.modelData) {
			appsGridView.currentItem.modelData.execute();
			appWin.query = "";
			field.text = "";
			appWin.isOpened = false;
		} else if (appWin.currentTab === 1 && filesListView.currentItem && filesListView.currentItem.modelData) {
			var currentFile = filesListView.currentItem.modelData;
			if (currentFile.isDir) {
				appWin.isGlobalSearchMode = false;
				appWin.currentFilesPath = currentFile.path;
				field.text = "";
				appWin.query = "";
			} else {
				openFile.app = currentFile.path;
				openFile.running = true;
				appWin.isOpened = false; // Close after opening file
			}
		} else if (appWin.currentTab === 2 && musicListView.currentItem && musicListView.currentItem.modelData) {
			// Launch Music
			var currentTrack = musicListView.currentItem.modelData;
			openFile.app = currentTrack.path;
			openFile.running = true;
			// Optional: Don't close window if you want to queue songs, but typically launchers close.
			// appWin.isOpened = false; 
		}
	}

	Component.onCompleted: {
		appWin.appFinder = new Fuzzy.Finder([...DesktopEntries.applications.values], {
			casing: "smart-case",
			selector: (item) => item.name || ""
		});
		
		// Start scanning for music immediately
		musicSearchProcess.running = true;
	}

	Rectangle {
		id: container
		anchors.fill: parent
		color: Colors.surface
		radius: 20
		opacity: appWin.isOpened ? 1.0 : 0.0

		Behavior on opacity {
			NumberAnimation { duration: 250 }
		}

		Rectangle {
			id: searchBar
			height: 40
			width: 350
			y: 20
			anchors.horizontalCenter: parent.horizontalCenter
			color: Colors.surfaceContainer
			radius: 20

			Image {
				id: checkIcon
				x: 15
				anchors.verticalCenter: parent.verticalCenter
				height: 15
				width: 15
				sourceSize.height: 15 
				sourceSize.width: 15
				smooth: true
				source: Quickshell.shellPath("assets/search.svg") 
				layer{
					enabled: true
					effect: ColorOverlay{ color: appWin.isGlobalSearchMode ? Colors.error : Colors.primary }
				}
			}
			TextField {
				id: field
				placeholderText: appWin.isGlobalSearchMode ? "Global search..." : (appWin.currentTab === 0 ? "Search apps" : appWin.currentTab === 1 ? "Search files" : "Search music")
				anchors.verticalCenter: parent.verticalCenter
				width: 290
				placeholderTextColor: Colors.secondary
				x: 40
				echoMode: TextInput.Normal
				color: Colors.secondary
				focus: true
				background: Rectangle {
					implicitHeight: 40
					color: "transparent"
				}
				Keys.onEscapePressed: (event) => {
					event.accepted = true;
					field.text = "";
					appWin.query = "";
					appWin.isGlobalSearchMode = false;
					appWin.isOpened = false;
				}
				Keys.onPressed: event => {
					const ctrl = event.modifiers & Qt.ControlModifier;
					const alt = event.modifiers & Qt.AltModifier;

					if (event.key == Qt.Key_Tab && ctrl ) {
						event.accepted = true;
						appWin.currentTab = (appWin.currentTab + 1) % 3;
						return;
					}

					if (appWin.currentTab === 0) {
						if (event.key == Qt.Key_Up) {
							event.accepted = true;
							if (appsGridView.currentIndex - 2 > 0) appsGridView.currentIndex-=3;
						} else if(event.key == Qt.Key_Left || event.key == Qt.Key_P && ctrl){
							event.accepted = true;
							if (appsGridView.currentIndex > 0) appsGridView.currentIndex--;
						} else if (event.key == Qt.Key_Right || event.key == Qt.Key_N && ctrl) {
							event.accepted = true;
							if (appsGridView.currentIndex < appsGridView.count - 1) appsGridView.currentIndex++;
						} else if (event.key == Qt.Key_Down) {
							event.accepted = true;
							if (appsGridView.currentIndex < appsGridView.count - 3) appsGridView.currentIndex+=3;
						}
					}

					if (appWin.currentTab === 1) {
						if (event.key == Qt.Key_Up) {
							event.accepted = true;
							if (filesListView.currentIndex > 0) filesListView.currentIndex--;
						} else if (event.key == Qt.Key_Down) {
							event.accepted = true;
							if (filesListView.currentIndex < filesListView.count - 1) filesListView.currentIndex++;
						} else if (event.key == Qt.Key_Left && alt) { 
							event.accepted = true;

							const homePath = Quickshell.env("HOME") || "/";
							if (appWin.currentFilesPath !== "/" && appWin.currentFilesPath !== homePath) {
								appWin.isGlobalSearchMode = false;

								let pathParts = appWin.currentFilesPath.split("/");
								if (pathParts[pathParts.length - 1] === "") {
									pathParts.pop();
								}
								pathParts.pop();

								let parentPath = pathParts.join("/");
								appWin.currentFilesPath = parentPath === "" ? "/" : parentPath;

								field.text = "";
								appWin.query = "";
							}
						}
					}
					
					// Music Tab Navigation
					if (appWin.currentTab === 2) {
						if (event.key == Qt.Key_Up) {
							event.accepted = true;
							if (musicListView.currentIndex > 0) musicListView.currentIndex--;
						} else if (event.key == Qt.Key_Down) {
							event.accepted = true;
							if (musicListView.currentIndex < musicListView.count - 1) musicListView.currentIndex++;
						}
					}

					if ([Qt.Key_Return, Qt.Key_Enter].includes(event.key)) {
						event.accepted = true;

						if (appWin.currentTab === 1) {
							if (appWin.query.trim() !== "" && !appWin.isGlobalSearchMode) {
								appWin.isGlobalSearchMode = true;
								globalFileSearch.running = true;
							} else {
								appWin.launchSelected();
							}
						} else {
							appWin.launchSelected();
						}
					}
				}
				onTextChanged: {
					appWin.query = text;
					if (text.trim() === "") {
						appWin.isGlobalSearchMode = false;
					}

					if (appWin.currentTab === 0) {
						appsGridView.currentIndex = filteredApps.values.length > 0 ? 0 : -1
					} else if (appWin.currentTab === 1) {
						if (appWin.isGlobalSearchMode && text.trim() !== "") {
							globalFileSearch.running = true;
						}
						filesListView.currentIndex = filteredFiles.values.length > 0 ? 0 : -1
					} else if (appWin.currentTab === 2) {
						musicListView.currentIndex = filteredMusic.values.length > 0 ? 0 : -1
					}
				}
			}
		}

		StackLayout {
			id: contentStack
			currentIndex: appWin.currentTab
			anchors.top: searchBar.bottom
			anchors.topMargin: 15
			anchors.bottom: navBar.top
			anchors.left: parent.left
			anchors.right: parent.right

			Item {
				id: appsTab
				M3Spinner {
					anchors.centerIn: parent
					visible: DesktopEntries.applications.length === 0 && appWin.isOpened
					animated: visible 
				}

				GridView {
					id: appsGridView
					anchors.fill: parent
					anchors.leftMargin: 25
					anchors.rightMargin: 25
					model: filteredApps.values
					currentIndex: filteredApps.values.length > 0 ? 0 : -1
					interactive: true
					clip: true
					cellHeight: 110
					cellWidth: 110
					highlightMoveDuration: 80
					highlight: Rectangle {
						radius: 8; 
						color: Colors.primary;
						Behavior on x{
							NumberAnimation{
								easing.bezierCurve: Anims.easing.expressiveFastEffects
							}
						}
					}

					delegate: Item {
						id: appEntry
						required property var modelData
						required property int index
						width: 110
						height: 110
						Image {
							id: img
							width: 70
							height: 70
							sourceSize.height: 50
							sourceSize.width: 50
							anchors.top: parent.top
							anchors.horizontalCenter: parent.horizontalCenter
							smooth: true
							source: Quickshell.iconPath(modelData.icon)
						}
						Text {
							anchors.top: img.bottom
							anchors.horizontalCenter: parent.horizontalCenter
							text: modelData.name
							color: appsGridView.currentIndex == appEntry.index ? Colors.primaryText : Colors.surfaceText 
							font.pixelSize: 13
							width: 95 
							wrapMode: Text.Wrap
							maximumLineCount: 2
							elide: Text.ElideRight
							horizontalAlignment: Text.AlignHCenter
						}
						MouseArea {
							anchors.fill: parent
							onClicked: appsGridView.currentIndex = appEntry.index
							onDoubleClicked: appWin.launchSelected()
						}
					}
				}
			}

			Item {
				id: filesTab

				FolderListModel {
					id: folderModel
					folder: "file://" + appWin.currentFilesPath
					showDirs: true
					showFiles: true
					showDotAndDotDot: false
					sortField: FolderListModel.Type
				}

				ListView {
					id: filesListView
					anchors.fill: parent
					anchors.leftMargin: 25
					anchors.rightMargin: 25
					model: ListModel{ id: filesModel }
					interactive: true
					clip: true
					highlightMoveDuration: 80
					highlight: Rectangle {
						radius: 8; 
						color: Colors.primary;
						Behavior on x{
							NumberAnimation{
								easing.bezierCurve: Anims.easing.expressiveFastEffects
							}
						}
					}

					delegate: Item {
						id: fileItem
						height: 35
						width: parent.width

						property string name: modelData.name
						property bool isDir: modelData.isDir
						property string path: modelData.path

						Text {
							anchors.verticalCenter: parent.verticalCenter
							anchors.left: parent.left
							anchors.leftMargin: 10

							text: appWin.isGlobalSearchMode ? fileItem.path.replace(Quickshell.env("HOME") || "", "~") : fileItem.name
							color: filesListView.currentIndex == index ? Colors.primaryText : Colors.surfaceText
							font.bold: fileItem.isDir
							elide: Text.ElideLeft
							width: parent.width - 20
						}

						MouseArea {
							anchors.fill: parent
							onClicked: filesListView.currentIndex = index
							onDoubleClicked: {
								if (fileItem.isDir) {
									appWin.isGlobalSearchMode = false;
									appWin.currentFilesPath = fileItem.path;
									field.text = ""; 
									appWin.query = "";
								} else {
									openFile.app = fileItem.path
									openFile.running = true
								}
							}
						}
					}
				}
			}

			Item {
				id: musicTab

				ListView {
					id: musicListView
					anchors.fill: parent
					anchors.leftMargin: 25
					anchors.rightMargin: 25
					model: filteredMusic.values
					interactive: true
					clip: true
					highlightMoveDuration: 80
					currentIndex: filteredMusic.values.length > 0 ? 0 : -1
					
					highlight: Rectangle {
						radius: 8; 
						color: Colors.primary;
						Behavior on x{
							NumberAnimation{
								easing.bezierCurve: Anims.easing.expressiveFastEffects
							}
						}
					}

					delegate: Item {
						id: musicItem
						height: 35
						width: musicTab.width - 50

						property string name: modelData.name
						property string path: modelData.path

						Text {
							anchors.verticalCenter: parent.verticalCenter
							anchors.left: parent.left
							anchors.leftMargin: 10
							text: musicItem.name
							color: musicListView.currentIndex == index ? Colors.primaryText : Colors.surfaceText
							elide: Text.ElideRight
							width: parent.width - 50
						}
						
						Image {
							id: musicNoteIcon
							anchors.verticalCenter: parent.verticalCenter
							anchors.right: parent.right
							anchors.rightMargin: 10
							height: 16
							width: 16
							// source: Quickshell.iconPath("audio-x-generic") 
							source: Quickshell.shellPath("assets/music.svg")
							sourceSize.height: 16
							sourceSize.width: 16
							smooth: true
						 opacity: 0.7
						}

						MouseArea {
							anchors.fill: parent
							onClicked: musicListView.currentIndex = index
							onDoubleClicked: {
								openFile.app = musicItem.path
								openFile.running = true
							}
						}
					}
				}
			}
		}

		Rectangle {
			id: navBar
			anchors.bottom: parent.bottom
			anchors.left: parent.left
			anchors.right: parent.right
			height: 80
			color: Colors.surfaceContainer
			bottomLeftRadius: 20
			bottomRightRadius: 20

			Rectangle {
				width: parent.width
				height: 1
				color: Colors.outlineVariant
				anchors.top: parent.top
			}

			Rectangle{
				id: highlight
				width: 56
				height: 32
				radius: 16
				color: Colors.secondaryContainer
				x: rowBar.x + 4 + 104 * appWin.currentTab
				y: rowBar.y + 6
				Behavior on x {
					NumberAnimation { 
						duration: Anims.duration.expressiveFastSpatial
						easing.type: Easing.BezierSpline
						easing.bezierCurve: Anims.easing.expressiveFastSpatial
					}
				}
			}

			Row {
				id: rowBar
				anchors.centerIn: parent
				spacing: 40

				NavButton {
					id: apps
					iconSource: Quickshell.shellPath("assets/apps.svg")
					label: "Apps"
					active: appWin.currentTab === 0
					onClicked: appWin.currentTab = 0
				}

				NavButton {
					id: files
					iconSource: Quickshell.shellPath("assets/folder.svg")
					label: "Files"
					active: appWin.currentTab === 1
					onClicked: appWin.currentTab = 1
				}

				NavButton {
					id: music
					iconSource: Quickshell.shellPath("assets/music.svg")
					label: "Music"
					active: appWin.currentTab === 2
					onClicked: appWin.currentTab = 2
				}
			}
		}

		ScriptModel {
			id: filteredApps
			values: {
				if (!appWin.appFinder) {
					return [...DesktopEntries.applications.values]
					.filter(d => d.name)
					.sort((a, b) => a.name.localeCompare(b.name));
				}
				const q = appWin.query.trim();

				if (q === "") {
					return appWin.appFinder.items;
				}

				const searchResults = appWin.appFinder.find(q);
				return searchResults.map(result => result.item);
			}
		}

		ScriptModel {
			id: filteredFiles

			function update() {
				valuesChanged();
			}

			values: {
				if (appWin.currentTab !== 1) return [];

				const q = appWin.query.trim();

				if (appWin.isGlobalSearchMode) {
					if (q === "") return [];

					var globalFinder = new Fuzzy.Finder(appWin.globalResultsCache, {
						casing: "smart-case",
						selector: (item) => item.name || ""
					});

					const searchResults = globalFinder.find(q);
					return searchResults.map(result => result.item);
				}

				var rawFiles = [];
				for (var i = 0; i < folderModel.count; i++) {
					rawFiles.push({
						name: folderModel.get(i, "fileName"),
						isDir: folderModel.get(i, "fileIsDir"),
						path: folderModel.get(i, "filePath").replace("file://", "")
					});
				}

				if (q === "") return rawFiles;

				var transientFinder = new Fuzzy.Finder(rawFiles, {
					casing: "smart-case",
					selector: (item) => item.name || ""
				});

				const searchResults = transientFinder.find(q);
				return searchResults.map(result => result.item);
			}
		}
		
		ScriptModel {
			id: filteredMusic
			
			function update() {
				valuesChanged();
			}

			values: {
				if (appWin.currentTab !== 2) return [];
				
				const q = appWin.query.trim();
				
				if (q === "") return appWin.musicCache;
				
				var musicFinder = new Fuzzy.Finder(appWin.musicCache, {
					casing: "smart-case",
					selector: (item) => item.name || ""
				});
				
				const searchResults = musicFinder.find(q);
				return searchResults.map(result => result.item);
			}
		}
	}

	HyprlandFocusGrab {
		id: grab
		windows: [appWin]
		active: appWin.isOpened
		onCleared: appWin.isOpened = false
	}

	IpcHandler {
		target: "appWin"
		function toggleOpened() {
			appWin.isOpened = !appWin.isOpened
			if (!appWin.isOpened) {
				appWin.isGlobalSearchMode = false;
			}
			console.log("IPC: Toggle App Launcher ->", appWin.isOpened); 
		}
	}
}
