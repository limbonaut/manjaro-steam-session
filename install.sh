#!/bin/bash

# Set the defaults. These can be overridden by specifying the value as an
# environment variable when running this script.
NON_INTERACTIVE="${NON_INTERACTIVE:-false}"
INCLUDE_STEAM_TWEAKS="${INCLUDE_STEAM_TWEAKS:-true}"
INCLUDE_STEAMOS_FG="${INCLUDE_STEAMOS_FG:-true}"
INCLUDE_OPENSSH="${INCLUDE_OPENSSH:-true}"
INCLUDE_SAKURA="${INCLUDE_SAKURA:-true}"
UPDATE_CONFIG="${UPDATE_CONFIG:-true}"
SET_1080P="${SET_1080P:-true}"
STEAM_USER="${STEAM_USER:-steam}"
USER_PASSWORD="${USER_PASSWORD:-steam}"
export STEAM_USER

# The default of this script is to reboot to desktop.
REBOOT_MODE=reboot-to-desktop-mode

HIGHLIGHT_COLOR='\033[1;36m' # Light Cyan
NC='\033[0m' # No Color

function highlight() {
	echo -e "${HIGHLIGHT_COLOR}$1${NC}"
}

# Interrupt execution and exit on Ctrl-C
trap exit SIGINT

# Ensure the script is being run as root
if [ "$EUID" -ne 0 ]; then
	highlight "This script must be run with sudo."
	exit
fi

# Confirm from the user that it's OK to continue
if [[ "${NON_INTERACTIVE}" != "true" ]]; then
	echo "Options:"
	echo "  Steam Tweaks:         ${INCLUDE_STEAM_TWEAKS}"
	echo "  Sakura terminal:      ${INCLUDE_SAKURA}"
	echo "  OpenSSH server:       ${INCLUDE_OPENSSH}"
	echo "  steamos-fg script:    ${INCLUDE_STEAMOS_FG}"
	echo "  Update config:        ${UPDATE_CONFIG}"
	echo "  Set 1080p:            ${SET_1080P}"
	echo
	echo "  Steam User:           ${STEAM_USER}"
	echo "  Password:             ${USER_PASSWORD}"
	echo ""
	echo "This script will configure a SteamOS-like experience on Manjaro."
	read -p "Do you want to continue? [Yy] " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		highlight "Starting installation..."
	else
		highlight "Aborting installation."
		exit
	fi
fi

# See if there is a 'steam' user account. If not, create it.
if ! grep "^${STEAM_USER}" /etc/passwd > /dev/null; then
	highlight "Steam user '${STEAM_USER}' not found. Creating it..."
	useradd -m "${STEAM_USER}"
	usermod -a -G wheel "${STEAM_USER}"
	echo "${STEAM_USER}:${USER_PASSWORD}" | chpasswd
	sudo -u "${STEAM_USER}" xdg-user-dirs-update
fi
STEAM_UID=$(grep "^${STEAM_USER}" /etc/passwd | cut -d':' -f3)
STEAM_GID=$(grep "^${STEAM_USER}" /etc/passwd | cut -d':' -f4)
highlight "Steam user '${STEAM_USER}' found with UID ${STEAM_UID} and GID ${STEAM_GID}"


if [ ! -e /usr/games/steam ]; then
	highlight "Installing Steam and game devices support..."
	set -e
	pamac install --no-confirm steam-manjaro game-devices-udev
	set +e
fi

highlight "Installing SteamOS Compositor Plus..."
set -e
pamac build --no-confirm steamos-compositor-plus
set +e

highlight "Installing 32-bit modeswitch inhibitor libraries..."
tar xvfJ ./lib/lib32_libmodeswitch_inhibitor.tar.xz --directory /usr/lib32/

if [[ "${INCLUDE_STEAM_TWEAKS}" == "true" ]]; then
	highlight "Installing Steam Tweaks..."
	pamac build --no-confirm steam-tweaks
fi

if [[ "${INCLUDE_STEAMOS_FG}" == "true" ]]; then
	highlight "Installing steamos-fg..."
	# Install "steamos-fg" script as a workaround for games like Deadcells with the Steam compositor.
	install -m 755 ./res/steamos-fg.sh /usr/local/sbin/steamos-fg
	# Install dependancies needed for steamos-fg
	pamac install --no-confirm xorg-xwininfo xorg-xprop
fi

if [[ "${UPDATE_CONFIG}" == "true" ]]; then
	highlight "(Re-)Installing System Configuration"
	
	# Enable automatic login. We use 'envsubst' to replace the user with ${STEAM_USER}.
	highlight "Enabling automatic login..."
	envsubst < ./res/custom.conf > /etc/gdm/custom.conf

	highlight "Setting Bluetooth to auto-enable on boot..."
	sed -i -E "s/#?AutoEnable=.*/AutoEnable=true/" /etc/bluetooth/main.conf
	
	highlight "Installing reboot to session scripts..."
	envsubst < ./res/reboot-to-desktop-mode.sh > /usr/local/sbin/reboot-to-desktop-mode
	envsubst < ./res/reboot-to-steamos-mode.sh > /usr/local/sbin/reboot-to-steamos-mode
	chmod +x /usr/local/sbin/reboot-to-desktop-mode
	chmod +x /usr/local/sbin/reboot-to-steamos-mode
	
	highlight "Installing reboot to session desktop entries.."
	install -m 644 ./res/steamos-mode.desktop ./res/desktop-mode.desktop /usr/share/applications/
	install -m 644 ./res/reboot-mode.png "/usr/share/icons/"
	# Create a sudoers rule to allow passwordless reboots between sessions.
	install -m 440 ./res/reboot-sudoers.conf /etc/sudoers.d/steamos-reboot
	# Create desktop icon
	install -o ${STEAM_USER} -g ${STEAM_USER} -m 711 ./res/steamos-mode.desktop "/home/${STEAM_USER}/Desktop/"
	# Allow launching desktop icon
	sudo -u "${STEAM_USER}" dbus-launch gio set "/home/${STEAM_USER}/Desktop/steamos-mode.desktop" metadata::trusted true
	# Enable "Desktop Icons" GNOME Shell extension (DING)
	sudo -u "${STEAM_USER}" dbus-launch gnome-extensions enable ding@rastersoft.com
	
	highlight "Configuring the default session..."
	cp ./res/steam-session.conf "/var/lib/AccountsService/users/${STEAM_USER}"
fi

if [[ "${SET_1080P}" == "true" ]]; then
	highlight "Configuring resolution and refresh rate..."
	install -m 644 -o ${STEAM_USER} -g ${STEAM_USER} -D ./res/steamos-compositor-plus  "/home/${STEAM_USER}/.config/steamos-compositor-plus"
fi

if [[ "${INCLUDE_SAKURA}" == "true" ]]; then
	highlight "Installing the Sakura terminal emulator..."
	pamac install  --no-confirm sakura
fi

if [[ "${INCLUDE_OPENSSH}" == "true" ]]; then
	highlight "Setting up OpenSSH server..."
	pamac install --no-confirm openssh
	systemctl enable sshd.service
fi

echo
highlight "Installation complete!"
echo
echo "Some tips!"
echo "1) In SteamOS mode, you can add a library shortcut for rebooting into desktop mode in Steam settings."
echo "2) You should pair your Atari controllers in desktop Settings. That way controllers will reconnect on reboot."
echo
echo "Press [ENTER] to reboot or [CTRL]+C to exit"
read -r
eval $REBOOT_MODE
