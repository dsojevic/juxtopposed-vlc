// SPDX-License-Identifier: GPL-2.0-or-later
import QtQuick
import QtQuick.Layouts

// Presentation shared by the VLC integration and the standalone QML checks.
FocusScope {
    id: root
    property real scaleFactor: 1
    property color accentColor: "#d37918"
    property bool lightTheme: false
    property bool presentationOnly: false
    property bool playing: false
    property bool started: false
    property bool hasVideo: false
    property bool seekable: false
    property bool pausable: true
    property bool hasPrevious: false
    property bool hasNext: false
    property bool muted: false
    property bool fullscreen: false
    property int autoHideMode: 1
    property int controlsHideTimeout: 1800
    property bool showFullscreenControls: true
    property bool showStatistics: false
    property bool showSubtitleTimeline: false
    property bool showSeekPreview: true
    property var subtitleTimelineCues: []
    property string subtitleTimelineState: "off"
    property real durationSeconds: 0
    property int subtitleDelayMS: 0
    signal subtitleDelayRequested(int milliseconds)
    property var statistics: ({})
    readonly property bool autoHideActive: started && hasVideo && (autoHideMode === 2 || (fullscreen && autoHideMode === 1))
    property bool maximized: false
    property bool minimalView: false
    onMinimalViewChanged: {
        if (minimalView) {
            libraryOpen = false
            queueOpen = false
            settingsPage = ""
            forceActiveFocus()
        }
    }
    property bool showWindowButtons: true
    property bool libraryOpen: false
    property bool libraryExpanded: false
    property bool miniPlayerVisible: true
    property string mediaFolderTitle: ""
    property bool canBrowseMedia: true
    onLibraryExpandedChanged: if (libraryExpanded) miniPlayerVisible = true
    property bool libraryInitialized: false
    onLibraryOpenChanged: if (!libraryOpen) libraryExpanded = false
    property bool queueOpen: false
    readonly property bool floatingQueue: queueOpen && miniPlayer.visible
    property string settingsPage: ""
    property real position: 0
    property real volume: 1
    property real maxVolume: 1.25
    property real buffering: 1
    property string mediaTitle: qsTr("VLC Media Player")
    property string locationTitle: qsTr("Videos")
    property string timeText: "00:00:00"
    property string lengthText: "00:00:00"
    property string artist: ""
    property url artwork
    property bool resumeAvailable: false
    property var timeForPosition: function(position) { return "" }
    property url seekPreviewImage
    property real seekPreviewImagePosition: -1
    signal seekPreviewRequested(real position)
    signal seekPreviewEnded()
    function refreshSeekPreview() { if (libraryExpanded) miniPlayer.refreshPreview(); else seek.refreshPreview() }
    property Component titleBarDragContent
    property Component videoContent
    property Component libraryContent
    property Component queueContent
    property Component settingsContent
    property QtObject trackPopup
    readonly property alias videoItem: videoLoader.item
    readonly property alias libraryItem: libraryLoader.item
    readonly property alias settingsItem: settingsLoader.item
    readonly property real positionSliderY: libraryExpanded ? miniPlayer.y + miniPlayer.seekY : bottomEdge.y + toolbar.y + seek.y
    readonly property bool controlsLocked: queueOpen || libraryOpen || settingsPage.length > 0 || resumeAvailable || !!trackPopup && trackPopup.visible
    readonly property bool topVisible: !minimalView && (!fullscreen || headerHover.hovered || header.activeFocus || revealTimer.running || controlsLocked)
    readonly property bool bottomVisible: !minimalView && !libraryExpanded && (!fullscreen || showFullscreenControls) && (!autoHideActive || bottomHover.hovered || toolbar.activeFocus || revealTimer.running || controlsLocked)
    readonly property RedesignTheme theme: RedesignTheme { scaleFactor: root.scaleFactor; lightTheme: root.lightTheme; accentColor: root.accentColor }

    signal togglePlayback()
    signal previous()
    signal next()
    signal seekRequested(real value)
    signal seekDragStarted()
    signal seekDragFinished(real value, bool commit)
    signal volumeRequested(real value)
    signal muteRequested()
    signal fullscreenRequested()
    signal minimizeRequested()
    signal maximizeRequested()
    signal closeRequested()
    signal audioTracksRequested(Item anchor)
    signal subtitleTracksRequested(Item anchor)
    signal menuRequested(Item anchor)
    signal openRequested()
    signal preferencesRequested()
    signal fullLibraryRequested()
    signal mediaFolderRequested()
    signal artistRequested()
    signal resumeRequested(bool resume)
    signal keyPressed(var event)

    Component.onDestruction: if (seek.dragActive) root.seekDragFinished(seek.dragPosition, false)

    component ChromeButton: RedesignButton {
        focusPolicy: root.presentationOnly ? Qt.NoFocus : Qt.StrongFocus
    }

    // Preview the chrome without making its controls dim or focusable.
    MouseArea {
        anchors.fill: parent; z: 100
        enabled: root.presentationOnly; visible: enabled
        acceptedButtons: Qt.AllButtons
        onWheel: wheel => wheel.accepted = true
    }

    function revealControls() { revealTimer.restart() }
    function toggleSettings(page: string) {
        if (trackPopup) trackPopup.close()
        queueOpen = false
        settingsPage = settingsPage === page ? "" : page
    }
    function toggleTracks(anchor, page) {
        if (!trackPopup) return
        if (settingsPage === page) {
            settingsPage = ""
            trackPopup.close()
            return
        }
        settingsPage = ""
        queueOpen = false
        trackPopup.toggleFrom(anchor, page)
    }
    function dismissPanels() {
        settingsPage = ""
        queueOpen = false
        libraryOpen = false
    }

    Keys.onEscapePressed: event => {
        if (queueOpen || libraryOpen || settingsPage.length > 0)
            dismissPanels()
        else if (fullscreen)
            fullscreenRequested()
        else
            event.accepted = false
    }
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab)
            revealControls()
        keyPressed(event)
    }
    Timer { id: revealTimer; interval: root.controlsHideTimeout; running: root.fullscreen }
    onFullscreenChanged: revealControls()
    Rectangle { anchors.fill: parent; color: theme.background }

    // Side panels cover the picture. Their state must not change the video
    // surface geometry or trigger a new video size/aspect ratio.
    Item {
        id: viewport
        parent: root.libraryExpanded ? miniPlayer.videoArea : root
        objectName: "redesignViewport"
        visible: !root.libraryExpanded || (root.started && miniPlayer.visible)
        z: 0
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            topMargin: root.minimalView || root.libraryExpanded || root.fullscreen ? 0 : theme.dp(40)
            bottomMargin: root.minimalView || root.libraryExpanded || root.fullscreen ? 0 : theme.dp(54)
            leftMargin: root.minimalView || root.libraryExpanded || root.fullscreen ? 0 : theme.dp(10)
            rightMargin: root.minimalView || root.libraryExpanded || root.fullscreen ? 0 : theme.dp(10)
        }
        Rectangle { anchors.fill: parent; color: "black"; radius: theme.dp(10) }
        Loader { id: videoLoader; anchors.fill: parent; sourceComponent: root.videoContent }
        Rectangle {
            // The outer border leaves a rounded opening over the native video layer.
            anchors.fill: parent
            anchors.margins: -theme.dp(root.libraryExpanded ? 5 : 10)
            color: "transparent"
            radius: theme.dp(root.libraryExpanded ? 10 : 20)
            border.width: theme.dp(root.libraryExpanded ? 5 : 10)
            border.color: theme.background
            visible: root.libraryExpanded || (!root.fullscreen && !root.minimalView)
        }


        // An honest empty state; the supplied cat is reference footage only.
        Column {
            anchors.centerIn: parent
            width: Math.min(parent.width - theme.dp(40), theme.dp(420))
            spacing: theme.dp(18)
            visible: !root.started && !root.hasVideo
            RedesignIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                width: theme.dp(48); height: width
                name: "cone"; color: theme.accent
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Drop a file to start playing")
                color: "#cccccc"
                font.pixelSize: theme.dp(18)
            }
            ChromeButton {
                objectName: "openFileButton"
                anchors.horizontalCenter: parent.horizontalCenter
                scaleFactor: root.scaleFactor; lightTheme: root.lightTheme; accentColor: root.accentColor
                iconName: "folder"; text: qsTr("Open file"); caption: text
                accent: true
                onClicked: root.openRequested()
            }
        }
        Column {
            anchors.centerIn: parent
            spacing: theme.dp(14)
            visible: root.started && !root.hasVideo
            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: root.artwork
                width: Math.min(viewport.width * 0.45, theme.dp(320))
                height: width
                fillMode: Image.PreserveAspectFit
                visible: status === Image.Ready
            }
            RedesignIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                width: theme.dp(96); height: width
                name: "music"; color: theme.accent
                visible: !root.artwork.toString()
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.max(0, viewport.width - theme.dp(40))
                text: root.mediaTitle
                visible: !root.libraryExpanded
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                color: "#e5e5e5"
                font.pixelSize: theme.dp(22)
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.artist; color: "#8f8f8f"; font.pixelSize: theme.dp(14)
                visible: !root.libraryExpanded
            }
        }
        Text {
            anchors.centerIn: parent
            visible: root.started && root.buffering < 1
            text: qsTr("Buffering %1%").arg(Math.round(root.buffering * 100))
            color: "white"
            style: Text.Outline; styleColor: "black"
            font.pixelSize: theme.dp(16)
        }
        RedesignStatistics {
            objectName: "playbackStatisticsOverlay"
            anchors.top: parent.top; anchors.left: parent.left
            anchors.margins: theme.dp(12)
            width: Math.max(0, Math.min(implicitWidth, parent.width - theme.dp(24)))
            height: Math.max(0, Math.min(implicitHeight, parent.height - theme.dp(24)))
            scaleFactor: root.scaleFactor; lightTheme: root.lightTheme; accentColor: root.accentColor
            statistics: root.statistics
            visible: root.showStatistics && root.started && !root.minimalView
        }
        Rectangle {
            objectName: "resumePlaybackPrompt"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: theme.dp(24)
            width: Math.max(0, Math.min(parent.width - theme.dp(24), theme.dp(540)))
            height: theme.dp(width < theme.dp(420) ? 80 : 64)
            visible: root.resumeAvailable && !root.minimalView
            color: theme.panel; radius: theme.dp(8); border.color: theme.border
            RowLayout {
                id: resumeRow
                anchors.fill: parent; anchors.margins: theme.dp(12)
                Text {
                    Layout.fillWidth: true
                    text: qsTr("Continue where you left off?")
                    color: theme.bright; font.pixelSize: theme.dp(14)
                    wrapMode: Text.WordWrap
                }
                ChromeButton {
                    scaleFactor: root.scaleFactor; lightTheme: root.lightTheme; accentColor: root.accentColor
                    caption: qsTr("Continue"); text: caption; accent: true
                    onClicked: root.resumeRequested(true)
                }
                ChromeButton {
                    scaleFactor: root.scaleFactor; lightTheme: root.lightTheme; accentColor: root.accentColor
                    iconName: "close"; text: qsTr("Start from the beginning")
                    onClicked: root.resumeRequested(false)
                }
            }
        }
    }

    Rectangle {
        id: library
        objectName: "redesignLibraryPanel"
        z: 1
        property real reveal: root.libraryOpen ? 1 : 0
        Behavior on reveal { NumberAnimation { duration: 150; easing.type: Easing.OutExpo } }
        visible: reveal > 0
        width: root.libraryExpanded ? root.width : Math.min(theme.dp(427), root.width * (root.width < theme.dp(900) ? 0.48 : 0.38))
        x: (reveal - 1) * width
        anchors.top: parent.top; anchors.bottom: parent.bottom
        anchors.topMargin: header.height; anchors.bottomMargin: root.libraryExpanded ? 0 : toolbar.height
        color: theme.panel
        clip: true
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; onWheel: wheel => wheel.accepted = true }
        Loader {
            id: libraryLoader
            anchors.fill: parent
            sourceComponent: root.libraryContent
            active: root.libraryOpen || root.libraryInitialized
            enabled: root.libraryOpen
            onLoaded: root.libraryInitialized = true
        }
    }
    RedesignMiniPlayer {
        id: miniPlayer
        objectName: "redesignMiniPlayer"
        z: 2
        visible: root.libraryExpanded && root.libraryOpen && root.started && root.miniPlayerVisible
        width: Math.max(theme.dp(160), Math.min(theme.dp(391), root.width - theme.dp(12), (root.height - theme.dp(182)) * 16 / 9 + theme.dp(20)))
        scaleFactor: root.scaleFactor; lightTheme: root.lightTheme; accentColor: root.accentColor
        playing: root.playing; started: root.started; seekable: root.seekable; pausable: root.pausable
        hasPrevious: root.hasPrevious; hasNext: root.hasNext; hasVideo: root.hasVideo
        position: root.position; mediaTitle: root.mediaTitle; folderTitle: root.mediaFolderTitle; artist: root.artist
        canBrowseMedia: root.canBrowseMedia
        minimumY: Math.min(root.height - height - theme.dp(6), theme.dp(46) + (root.floatingQueue ? theme.dp(356) : 0))
        previewEnabled: root.showSeekPreview && !root.presentationOnly
        previewImage: root.seekPreviewImage; previewImagePosition: root.seekPreviewImagePosition
        timeForPosition: root.timeForPosition
        onTogglePlayback: root.togglePlayback()
        onPrevious: root.previous()
        onNext: root.next()
        onSeekRequested: position => root.seekRequested(position)
        onSeekDragStarted: root.seekDragStarted()
        onSeekDragFinished: (position, commit) => root.seekDragFinished(position, commit)
        onPreviewRequested: position => root.seekPreviewRequested(position)
        onPreviewEnded: root.seekPreviewEnded()
        onOpenPlayerRequested: { root.libraryExpanded = false; root.libraryOpen = false }
        onCloseRequested: { root.queueOpen = false; root.miniPlayerVisible = false }
        onQueueRequested: { root.settingsPage = ""; root.queueOpen = !root.queueOpen }
        onFolderRequested: root.mediaFolderRequested()
        onArtistRequested: root.artistRequested()
    }
    Rectangle {
        id: floatingQueuePanel
        objectName: "redesignFloatingQueue"
        z: 1.5
        visible: root.floatingQueue
        x: miniPlayer.x
        y: Math.max(theme.dp(46), miniPlayer.y - height)
        width: miniPlayer.width
        height: Math.min(theme.dp(356), Math.max(0, miniPlayer.y - theme.dp(46)))
        radius: theme.dp(14)
        color: theme.background
        // Continue the card behind the mini player without moving its video.
        Rectangle { y: parent.height - theme.dp(14); width: parent.width; height: theme.dp(28); color: parent.color }
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; onWheel: wheel => wheel.accepted = true }
    }
    Rectangle {
        id: rightPanel
        objectName: "redesignRightPanel"
        z: 3
        visible: (root.queueOpen && !root.floatingQueue) || root.settingsPage.length > 0
        width: Math.min(theme.dp(400), root.width * 0.48)
        anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.right: parent.right
        anchors.topMargin: header.height + theme.dp(20); anchors.bottomMargin: toolbar.height + theme.dp(20)
        anchors.rightMargin: theme.dp(20)
        color: theme.floatingPanel
        radius: theme.dp(10)
        border.width: 0
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; onWheel: wheel => wheel.accepted = true }
        Loader {
            id: queueLoader
            parent: root.floatingQueue ? floatingQueuePanel : rightPanel
            anchors.fill: parent
            sourceComponent: root.queueContent
            active: root.queueOpen
            visible: active
            onLoaded: if (item && item.floating !== undefined) item.floating = Qt.binding(() => root.floatingQueue)
        }
        Loader {
            id: settingsLoader
            anchors.fill: parent
            sourceComponent: root.settingsContent
            active: root.settingsPage.length > 0
            visible: active
        }
    }

    // Fullscreen edges reveal independently; motion in the video stays unobtrusive.
    // Each detector contains the chrome it reveals. Hover on a child control
    // must not hide the toolbar and then expose the detector again.
    Item {
        id: headerEdge
        z: 4
        anchors.top: parent.top; width: parent.width; height: theme.dp(48)
        HoverHandler { id: headerHover; blocking: false }
    }
    Item {
        id: bottomEdge
        z: 4
        anchors.bottom: parent.bottom; width: parent.width; height: theme.dp(64)
        HoverHandler { id: bottomHover; blocking: false }
    }

    Rectangle {
        id: header
        parent: headerEdge
        objectName: "redesignHeader"
        anchors.top: parent.top; width: parent.width; height: theme.dp(40)
        color: theme.background
        visible: root.topVisible
        Loader { anchors.fill: parent; sourceComponent: root.titleBarDragContent }
        RowLayout {
            id: headerLeft
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0
            ChromeButton {
                scaleFactor: root.scaleFactor; lightTheme: root.lightTheme; accentColor: root.accentColor
                implicitWidth: theme.dp(50)
                iconName: "cone"; text: qsTr("Open file"); foreground: theme.accent
                onClicked: root.openRequested()
            }
            ChromeButton {
                implicitWidth: theme.dp(30)
                objectName: "mainMenuButton"
                visible: !root.presentationOnly
                scaleFactor: root.scaleFactor; lightTheme: root.lightTheme; accentColor: root.accentColor
                iconName: "more"; text: qsTr("Menu")
                onClicked: root.menuRequested(this)
            }
            ChromeButton {
                implicitWidth: theme.dp(46)
                objectName: "libraryToggleButton"
                visible: !root.presentationOnly && !root.libraryExpanded
                scaleFactor: root.scaleFactor; lightTheme: root.lightTheme; accentColor: root.accentColor
                iconName: "sidebar"; text: root.libraryOpen ? qsTr("Hide library") : qsTr("Show library")
                iconReveal: library.reveal
                Accessible.checkable: true; Accessible.checked: root.libraryOpen
                onClicked: root.libraryOpen = !root.libraryOpen
            }
            Rectangle { visible: !root.presentationOnly && !root.libraryExpanded; Layout.leftMargin: theme.dp(2); Layout.rightMargin: theme.dp(6); width: theme.dp(1); height: theme.dp(18); color: theme.border }
            ChromeButton {
                objectName: "mediaFolderButton"
                property bool hasMediaFolder: root.started && root.canBrowseMedia && root.mediaFolderTitle.length > 0
                visible: !root.presentationOnly && !root.libraryExpanded && root.width > theme.dp(700)
                scaleFactor: root.scaleFactor; lightTheme: root.lightTheme; accentColor: root.accentColor
                iconName: "folder"
                caption: hasMediaFolder ? root.mediaFolderTitle : root.locationTitle
                captionMaximumWidth: theme.dp(220)
                text: hasMediaFolder ? qsTr("Open media folder") : qsTr("Browse library")
                onClicked: {
                    if (hasMediaFolder) {
                        root.libraryOpen = true
                        root.mediaFolderRequested()
                    } else root.libraryOpen = !root.libraryOpen
                }
            }
        }
        Text {
            anchors.centerIn: parent
            width: Math.max(0, parent.width - Math.max(headerLeft.width, windowControls.width) * 2 - theme.dp(32))
            horizontalAlignment: Text.AlignHCenter
            text: root.mediaTitle
            font.pixelSize: theme.dp(14)
            elide: Text.ElideRight; color: theme.foreground
        }
        Row {
            id: windowControls
            anchors.right: parent.right; anchors.rightMargin: theme.dp(6)
            anchors.verticalCenter: parent.verticalCenter
            ChromeButton {
                visible: root.showWindowButtons
                scaleFactor: root.scaleFactor; lightTheme: root.lightTheme; accentColor: root.accentColor
                iconName: "minimize"; text: qsTr("Minimize")
                onClicked: root.minimizeRequested()
            }
            ChromeButton {
                visible: root.showWindowButtons
                scaleFactor: root.scaleFactor; lightTheme: root.lightTheme; accentColor: root.accentColor
                iconName: "maximize"; text: root.maximized ? qsTr("Restore window") : qsTr("Maximize")
                onClicked: root.maximizeRequested()
            }
            ChromeButton {
                objectName: "fullscreenButton"
                scaleFactor: root.scaleFactor; lightTheme: root.lightTheme; accentColor: root.accentColor
                iconName: "fullscreen"; text: root.fullscreen ? qsTr("Exit fullscreen") : qsTr("Fullscreen")
                onClicked: root.fullscreenRequested()
            }
            ChromeButton {
                visible: root.showWindowButtons
                scaleFactor: root.scaleFactor; lightTheme: root.lightTheme; accentColor: root.accentColor
                iconName: "close"; text: qsTr("Close")
                onClicked: root.closeRequested()
            }
        }
    }

    Rectangle {
        id: toolbar
        parent: bottomEdge
        objectName: "redesignToolbar"
        anchors.bottom: parent.bottom; width: parent.width; height: theme.dp(54)
        color: theme.background
        visible: root.bottomVisible
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: theme.dp(18); anchors.rightMargin: theme.dp(18)
            spacing: theme.dp(10)
            ChromeButton {
                objectName: "previousButton"
                scaleFactor: root.scaleFactor; lightTheme: root.lightTheme; accentColor: root.accentColor
                implicitWidth: theme.dp(30); implicitHeight: theme.dp(28)
                iconName: "previous"; text: qsTr("Previous"); enabled: root.hasPrevious
                onClicked: root.previous()
            }
            ChromeButton {
                objectName: "playButton"
                scaleFactor: root.scaleFactor; lightTheme: root.lightTheme; accentColor: root.accentColor
                implicitWidth: theme.dp(54); implicitHeight: theme.dp(28)
                iconName: root.playing ? "pause" : "play"
                text: root.playing ? qsTr("Pause") : qsTr("Play")
                accent: true; enabled: !root.started || root.pausable
                onClicked: root.togglePlayback()
            }
            ChromeButton {
                objectName: "nextButton"
                scaleFactor: root.scaleFactor; lightTheme: root.lightTheme; accentColor: root.accentColor
                implicitWidth: theme.dp(30); implicitHeight: theme.dp(28)
                iconName: "next"; text: qsTr("Next"); enabled: root.hasNext
                onClicked: root.next()
            }
            Text {
                visible: root.width > theme.dp(650)
                Layout.preferredWidth: theme.dp(88)
                horizontalAlignment: Text.AlignHCenter
                text: root.timeText
                color: theme.foreground; font.pixelSize: theme.dp(14)
            }
            RedesignPlayerSeekBar {
                focusPolicy: root.presentationOnly ? Qt.NoFocus : Qt.StrongFocus
                id: seek
                objectName: "seekBar"
                mediaStarted: root.started
                playerPosition: root.position
                onDragStarted: root.seekDragStarted()
                onDragFinished: (position, commit) => root.seekDragFinished(position, commit)
                onSeekRequested: position => root.seekRequested(position)
                Layout.fillWidth: true
                Layout.minimumWidth: theme.dp(40)
                scaleFactor: root.scaleFactor; lightTheme: root.lightTheme; accentColor: root.accentColor
                enabled: root.seekable
                timeForPosition: root.timeForPosition
                previewEnabled: root.showSeekPreview && root.started && root.hasVideo && !root.presentationOnly
                previewImage: root.seekPreviewImage
                previewImagePosition: root.seekPreviewImagePosition
                timelineEnabled: root.showSubtitleTimeline
                timelineCues: root.subtitleTimelineCues
                timelineState: root.subtitleTimelineState
                durationSeconds: root.durationSeconds
                subtitleDelayMS: root.subtitleDelayMS
                onSubtitleDelayRequested: milliseconds => root.subtitleDelayRequested(milliseconds)
                onPreviewRequested: position => root.seekPreviewRequested(position)
                onPreviewEnded: root.seekPreviewEnded()
            }
            Text {
                visible: root.width > theme.dp(800)
                Layout.preferredWidth: theme.dp(84)
                horizontalAlignment: Text.AlignHCenter
                text: root.lengthText
                color: theme.foreground; font.pixelSize: theme.dp(14)
            }
            ChromeButton {
                id: muteButton
                objectName: "muteButton"
                scaleFactor: root.scaleFactor; lightTheme: root.lightTheme; accentColor: root.accentColor
                implicitWidth: theme.dp(28)
                iconName: root.muted ? "muted" : "volume"
                text: root.muted ? qsTr("Unmute") : qsTr("Mute")
                onClicked: root.muteRequested()
                WheelHandler {
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
                        volumeSlider.stepBy(numSteps)
                        wheel.accepted = true
                    }
                }
            }
            RedesignVolume {
                focusPolicy: root.presentationOnly ? Qt.NoFocus : Qt.StrongFocus
                id: volumeSlider
                objectName: "volumeSlider"
                visible: root.width > theme.dp(750)
                scaleFactor: root.scaleFactor; lightTheme: root.lightTheme; accentColor: root.accentColor
                muted: root.muted; to: root.maxVolume
                Binding on value { when: !volumeSlider.pressed && !volumeSlider.wheelActive; value: root.volume; restoreMode: Binding.RestoreBindingOrValue }
                onMoved: root.volumeRequested(value)
            }
            ChromeButton {
                objectName: "audioButton"
                visible: root.width > theme.dp(900)
                scaleFactor: root.scaleFactor; lightTheme: root.lightTheme; accentColor: root.accentColor
                iconName: "audio"; text: qsTr("Audio tracks and output")
                selected: !!root.trackPopup && root.trackPopup.visible && root.trackPopup.page === "audio"
                onClicked: { root.toggleTracks(this, "audio"); root.audioTracksRequested(this) }
            }
            ChromeButton {
                objectName: "subtitleButton"
                scaleFactor: root.scaleFactor; lightTheme: root.lightTheme; accentColor: root.accentColor
                iconName: "subtitles"; text: qsTr("Subtitle tracks")
                selected: !!root.trackPopup && root.trackPopup.visible && root.trackPopup.page === "subtitles"
                onClicked: { root.toggleTracks(this, "subtitles"); root.subtitleTracksRequested(this) }
            }
            ChromeButton {
                objectName: "playbackSettingsButton"
                scaleFactor: root.scaleFactor; lightTheme: root.lightTheme; accentColor: root.accentColor
                iconName: "settings"; text: qsTr("Playback settings")
                selected: root.settingsPage.length > 0
                onClicked: root.toggleSettings("playback")
            }
            ChromeButton {
                objectName: "queueButton"
                scaleFactor: root.scaleFactor; lightTheme: root.lightTheme; accentColor: root.accentColor
                iconName: "queue"; text: qsTr("Play queue"); selected: root.queueOpen
                onClicked: { root.settingsPage = ""; root.queueOpen = !root.queueOpen }
            }
        }
    }
}
