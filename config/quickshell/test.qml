import Quickshell
import Quickshell.Io
import QtQuick

FloatingWindow {
    id: bar
    color: "#272e33"
    mask: Region {
        item: globe
        shape: Region.Ellipse
    }

    Item {
        id: root
        property var size: Math.min(parent.width, parent.height)
        width: size; height: size
        anchors.verticalCenter: parent.verticalCenter; anchors.horizontalCenter: parent.horizontalCenter

    // ── Public properties ────────────────────────────────────────────────────────
        property string hovered:  ""
        property string selected: ""
        property real zoom: 1
        property real dragSensitivity: 1/180 /zoom
        readonly property string selectediso: (countries.find(c => c.name === selected) || {}).iso || ""
    // ── Private state  ───────────────────────────────────────────────────────────
        property var  countries: []
        property var  disabledCountries: ({}) // for example: ({"US": true, "CN": true})
        property int  hoverIdx:  -1
        property real lon: 0
        property real lat: 0
        property real lx:  0
        property real ly:  0
        readonly property real r:  Math.min(width, height) * 0.5
        readonly property real cx: width  /2
        readonly property real cy: height /2
    // ── Colors ───────────────────────────────────────────────────────────────────
        readonly property color fillOcean:   "#0d1f2d"
        readonly property color fillIsValid: "#1e3a2f"
        readonly property color fillHovered: "#295642"
        readonly property color fillClicked: "#3d9970"
        readonly property color fillInvalid: "#0b1b27"
        readonly property color border:      fillHovered
        readonly property color borderAlt:   "#1f3f54"
    // ── GeoJSON cache & network fallback ─────────────────────────────────────────
        FileView {
            path: Quickshell.shellDir + "/geojson_cache.json"
            onLoaded:         root._ingest(geoCache.data)
            onLoadFailed:     { writeAdapter(); root._fetch() }
            onAdapterUpdated: writeAdapter()
            JsonAdapter { id: geoCache; property var data: ({}) }
        }

        function _ingest(d) {
            if (!d?.features?.length) return _fetch()

            let cs = []
            for (let f of d.features) {
                let g = f.geometry, geom
                if      (g.type === "Polygon")      geom = { type: "Polygon",      coordinates: [g.coordinates] }
                else if (g.type === "MultiPolygon") geom = { type: "MultiPolygon", coordinates:  g.coordinates  }
                else if (g.type === "Point")        geom = { type: "Point",        coordinates:  g.coordinates  }
                else continue
                cs.push({
                    name: f.properties.name || f.properties.NAME_EN || f.properties.NAME || "?",
                    iso:  f.properties.ISO_A2 || f.properties.ISO_A2_EH || "",
                    geom
                })
            }
            countries = cs
            hoverIdx = -1
            hovered   = ""
            selected  = ""
            globe.requestPaint()
            pick.requestPaint()
        }

        function _fetch() {
            var results = [null, null]
            var done = 0
            ;[
                "https://raw.githubusercontent.com/nvkelso/natural-earth-vector/refs/heads/master/geojson/ne_110m_admin_0_countries.geojson",
                "https://raw.githubusercontent.com/nvkelso/natural-earth-vector/refs/heads/master/geojson/ne_50m_admin_0_tiny_countries.geojson",
            ].forEach((url, i) => {
                var xhr = new XMLHttpRequest
                xhr.open("GET", url)
                xhr.onreadystatechange = () => {
                    if (xhr.readyState !== XMLHttpRequest.DONE) return
                    if (xhr.status === 200) {
                        try {
                            results[i] = JSON.parse(xhr.responseText)
                            console.log("Fetched", url)
                        } catch (e) {
                            console.warn("fetch failed", url, e)
                            return  // prevent incrementing done
                        }
                    } else {
                        console.warn("fetch failed", url, xhr.status)
                        return
                    }
                    if (++done === 2) root._merge(results[0], results[1])
                }
                xhr.onerror = () => console.warn("fetch failed", url, "network error")
                xhr.send()
            })
        }

        function _merge(countries, tiny) {
            // Polygon countries take priority; points only fill the gap
            var seen = {}
            var features = []
            countries.features.forEach(f => {
                var iso = f.properties.ISO_A3
                if (iso && iso !== "-99") seen[iso] = true
                features.push(f)
            })
            tiny.features.forEach(f => {
                if (!seen[f.properties.ISO_A3]) features.push(f)
            })
            var merged = { type: "FeatureCollection", features: features}
            geoCache.data = merged
            root._ingest(merged)
        }
    // ── Projection & painting ────────────────────────────────────────────────────
        function _proj(lonDeg, latDeg) {
            let dLon = lonDeg * Math.PI /180 -lon
            let laR  = latDeg * Math.PI /180
            let cosC = Math.sin(lat) * Math.sin(laR) + Math.cos(lat) * Math.cos(laR) * Math.cos(dLon)
            if (cosC < 0) return null
            return [
                cx + r * zoom *  Math.cos(laR) * Math.sin(dLon),
                cy  -r * zoom * (Math.cos(lat) * Math.sin(laR) -Math.sin(lat) * Math.cos(laR) * Math.cos(dLon))
            ]
        }

        function _paint(ctx, isPick) {
            ctx.clearRect(0, 0, width, height)

            // Ocean
            ctx.beginPath()
            ctx.arc(cx, cy, r, 0, 2 * Math.PI)
            ctx.fillStyle = isPick ? "#000000" : fillOcean
            ctx.fill()

            // Clip to globe
            ctx.save()
            ctx.beginPath()
            ctx.arc(cx, cy, r, 0, 2 * Math.PI)
            ctx.clip()

            let occupied = []
            for (let i = 0; i < countries.length; i++) {
                const c = countries[i]
                const geom = c.geom

                const available = !disabledCountries[c.iso]
                let fill, stroke = null
                if (isPick) { const v = i + 1; fill = `rgb(${(v >> 16) & 255},${(v >> 8) & 255},${v & 255})` }
                else {
                    const isSelected = c.name === selected && available
                    const isHovered = i === hoverIdx && available
                    fill = isSelected ? fillClicked
                         : isHovered  ? fillHovered
                         : available  ? fillIsValid
                         : fillInvalid
                    stroke = available ? border : borderAlt
                }
                ctx.fillStyle = fill
                if (!isPick) ctx.strokeStyle = stroke

                if (geom.type === "Point") {
                    let p = _proj(geom.coordinates[0], geom.coordinates[1])
                    if (!p) continue
                    let pr = 3 * (1 + zoom /2)
                    if (!available) {
                        let skip = false
                        for (let o of occupied)
                            if ((p[0]-o[0])**2 + (p[1]-o[1])**2 < pr*pr*2) { skip = true; break }
                        if (skip) continue
                    }
                    occupied.push(p)
                    ctx.beginPath()
                    ctx.arc(p[0], p[1], pr, 0, 2 * Math.PI)
                    ctx.fill()
                    if (!isPick) ctx.stroke()
                } else {
                    ctx.beginPath()
                    for (let poly of geom.coordinates)
                        for (let ring of poly)
                            _drawRing(ctx, ring)
                    ctx.fill()
                    if (!isPick) ctx.stroke()
                }
            }
            ctx.restore()
        }
    // ── Ring drawing helpers ─────────────────────────────────────────────────────
        function _xing(pa, pb) {
            let t  = pa[2] /(pa[2] -pb[2])
            let ex = pa[0] + t * (pb[0] -pa[0]) -cx
            let ey = pa[1] + t * (pb[1] -pa[1]) -cy
            let s  = r * zoom /Math.hypot(ex, ey)
            return [cx + ex * s, cy + ey * s]
        }

        function _rimArc(ctx, a1, a2) {
            let cw = ((a2 -a1) + 2 * Math.PI) % (2 * Math.PI) > Math.PI
            ctx.arc(cx, cy, r * zoom, a1, a2, cw)
        }

        function _drawRing(ctx, ring) {
            let n      = ring.length
            let sinLat = Math.sin(lat), cosLat = Math.cos(lat)
            let rz     = r * zoom
            let pts    = [], anyVis = false

            for (let i = 0; i < n; i++) {
                let dLon  = ring[i][0] * Math.PI /180 -lon
                let laR   = ring[i][1] * Math.PI /180
                let cosLa = Math.cos(laR), sinLa = Math.sin(laR)
                let cosLo = Math.cos(dLon), sinLo = Math.sin(dLon)
                let c     = sinLat * sinLa + cosLat * cosLa * cosLo
                pts[i]    = [cx + rz * cosLa * sinLo, cy -rz * (cosLat * sinLa -sinLat * cosLa * cosLo), c]
                if (c >= 0) anyVis = true
            }
            if (!anyVis) return

            let exit = null, start = null, prevPx = null, started = false
            let pp = pts[n -1]

            for (let i = 0; i < n; i++) {
                let p = pts[i]

                if (pp[2] < 0 && p[2] < 0) {
                    // both behind — skip
                } else if (pp[2] < 0 && p[2] >= 0) {
                    let ep = _xing(pp, p)
                    let ea = Math.atan2(ep[1] -cy, ep[0] -cx)
                    if (!started) { ctx.moveTo(ep[0], ep[1]); start = ea; started = true }
                    else _rimArc(ctx, exit, ea)
                    exit = null
                    ctx.lineTo(p[0], p[1])
                    prevPx = p
                } else if (pp[2] >= 0 && p[2] < 0) {
                    let ep = _xing(pp, p)
                    ctx.lineTo(ep[0], ep[1])
                    exit   = Math.atan2(ep[1] -cy, ep[0] -cx)
                    prevPx = ep
                } else {
                    if      (!started)                       { ctx.moveTo(p[0], p[1]); started = true }
                    else if (Math.abs(p[0] -prevPx[0]) > rz)  ctx.moveTo(p[0], p[1])
                    else                                       ctx.lineTo(p[0], p[1])
                    prevPx = p
                }
                pp = p
            }
            if (exit !== null && start !== null) _rimArc(ctx, exit, start)
        }
    // ── Canvases ─────────────────────────────────────────────────────────────────
        Canvas {
            id: globe
            anchors.fill: parent
            onPaint: root._paint(getContext("2d"), false)
        }
        Canvas {
            id: pick
            anchors.fill: parent
            visible:      false
            antialiasing: false
            onPaint: root._paint(getContext("2d"), true)
        }
    // ── Input ────────────────────────────────────────────────────────────────────
        MouseArea {
            anchors.fill:    parent
            hoverEnabled:    true
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

            property bool _moved: false

            onPressed: e => { _moved = false; root.lx = e.x; root.ly = e.y }

            onPositionChanged: e => {
                if (pressed) {
                    _moved = true
                    root.lon   -= (e.x -root.lx) * root.dragSensitivity
                    root.lat    = Math.max(-1.48, Math.min(1.48, root.lat + (e.y -root.ly) * root.dragSensitivity))
                    root.lx = e.x; root.ly = e.y
                    globe.requestPaint()
                } else {
                    let d      = pick.getContext("2d").getImageData(e.x, e.y, 1, 1).data
                    let idx    = ((d[0] << 16) | (d[1] << 8) | d[2]) -1
                    let newIdx = (idx >= 0 && idx < root.countries.length) ? idx : -1
                    if (newIdx !== root.hoverIdx) {
                        root.hoverIdx = newIdx
                        root.hovered   = newIdx >= 0 ? root.countries[newIdx].name : ""
                        globe.requestPaint()
                    }
                }
            }
            onReleased: pick.requestPaint()

            onExited: { root.hoverIdx = -1; root.hovered = ""; globe.requestPaint() }

            onClicked: e => {
                if (_moved) return
                let d = pick.getContext("2d").getImageData(e.x, e.y, 1, 1).data
                if (!d) return
                let idx  = ((d[0] << 16) | (d[1] << 8) | d[2]) -1
                root.selected = (idx >= 0 && idx < root.countries.length && !root.disabledCountries[root.countries[idx].iso])
                    ? root.countries[idx].name
                    : ""
                globe.requestPaint()
            }
            onWheel: w => {
                let d = w.angleDelta.y /120
                root.zoom  = Math.max(1, Math.min(8, root.zoom * Math.pow(1.2, d)))
                globe.requestPaint()
                pick.requestPaint()
            }
        }
    // ── Labels (MD text) ───────────────────────────────────────────────────────────────────
        Text {
            anchors.bottom:       hoveredLabel.top
            x:                   (parent.width -width) /2
            horizontalAlignment: Text.AlignHCenter
            text:    `<i>selected:</i><br>${root.selected} (${root.selectediso})`
            color: "#ffffff"
            visible: root.selected !== ""
            Rectangle { width: parent.width; height: parent.height; color: "#80000000"; z: -1}
        }
        Text {
            id: hoveredLabel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            text: root.hovered
            color: "#ffffff"
            Rectangle { width: parent.width; height: parent.height; color: "#80000000"; z: -1}
        }
    }
}
