import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Hyprland
import Qt5Compat.GraphicalEffects
import QtQuick
import qs.theming

Rectangle {
    id: windowRect
    
    // Core states driven entirely by native properties, avoiding external shell executions
    property bool hasWindow: Hyprland.activeToplevel !== null
    property string activeAppId: {
        if (!hasWindow) return "hyprland";
        
        // Securely fall back through wayland or xwayland identifiers depending on the client window type
        if (Hyprland.activeToplevel.wayland && Hyprland.activeToplevel.wayland.appId) {
            return Hyprland.activeToplevel.wayland.appId;
        } else if (Hyprland.activeToplevel.xwayland && Hyprland.activeToplevel.xwayland.className) {
			return Hyprland.activeToplevel.xwayland.className;
		} else if (!Hyprland.activeToplevel) return "preferences-desktop-wallpaper";
		return "hyprland";
	}

	function getIcon(cls) {
		var c = (cls || "").toLowerCase();

		// Browsers
		if (c.includes("firefox")) return "firefox";
		if (c.includes("zen")) return "zen-browser";
		if (c.includes("librewolf")) return "librewolf";
		if (c.includes("chromium") || c.includes("chrome") || c.includes("thorium")) return "google-chrome";
		if (c.includes("brave")) return "brave-browser";
		if (c.includes("qutebrowser")) return "qutebrowser";

		// Terminals
		if (c.includes("kitty")) return "kitty";
		if (c.includes("alacritty") || c.includes("foot") || c.includes("terminal") || c.includes("ghostty") || c.includes("wezterm")) return "utilities-terminal";

		// Coding
		if (c.includes("code") || c.includes("codium")) return "vscode";
		if (c.includes("sublime")) return "sublime-text";
		if (c.includes("neovide") || c.includes("nvim")) return "nvim";
		if (c.includes("idea") || c.includes("jetbrains")) return "intellij-idea";
		if (c.includes("pycharm")) return "pycharm";
		if (c.includes("webstorm")) return "webstorm";
		if (c.includes("clion")) return "clion";
		if (c.includes("android")) return "android-studio";

		// Files
		if (c.includes("kate") || c.includes("texteditor")) return "accessories-text-editor";
		if (c.includes("nautilus") || c.includes("org.gnome.nautilus") || c.includes("files")) return "system-file-manager";
		if (c.includes("thunar") || c.includes("dolphin") || c.includes("nemo")) return "folder";

		// Chatting
		if (c.includes("discord") || c.includes("vesktop")) return "discord";
		if (c.includes("slack")) return "slack";
		if (c.includes("telegram")) return "telegram";
		if (c.includes("signal")) return "signal-desktop";
		if (c.includes("whatsapp")) return "whatsapp";

		// Media
		if (c.includes("spotify")) return "spotify";
		if (c.includes("vlc")) return "vlc";
		if (c.includes("mpv") || c.includes("haruna")) return "mpv";
		if (c.includes("gimp")) return "gimp";
		if (c.includes("inkscape")) return "inkscape";
		if (c.includes("krita")) return "krita";
		if (c.includes("blender")) return "blender";
		if (c.includes("obs")) return "obs";

		// Games
		if (c.includes("steam")) return "steam";
		if (c.includes("lutris")) return "lutris";
		if (c.includes("heroic")) return "heroic-launcher";

		// System
		if (c.includes("kvantum")) return "kvantum";
		if (c.includes("settings") || c.includes("missioncenter")) return "preferences-system";
		if (c.includes("systemmonitor")) return "utilities-system-monitor";
		if (c.includes("pavucontrol")) return "multimedia-volume-control";
		if (c.includes("calculator")) return "accessories-calculator";
		if (c.includes("weather")) return "weather-few-clouds";

		// Images
		if (c.includes("photos") || c.includes("loupe") || c.includes("imv") || c.includes("feh") || c.includes("viewnior")) return "image-viewer";

		// Default
		return c;
	}

	height: Dimensions.barHeight
	width: height
	radius: height / 2
	color: Colors.surface

	IconImage {
		id: icon
		anchors.fill: parent
		anchors.margins: 6

		// Binding to optimized activeAppId
		source: Quickshell.iconPath(windowRect.getIcon(windowRect.activeAppId))
		opacity: windowRect.hasWindow ? 1 : 0

		smooth: true
		antialiasing: true
		// layer{
		// 	enabled: true
		// 	effect: ColorOverlay{
		// 		color: Colors.primary
		// 	}
		// }

		Behavior on opacity {
			NumberAnimation { duration: 150 }
		}
	}
}
