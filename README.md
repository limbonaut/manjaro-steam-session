# Manjaro Steam Session for Atari VCS (and not only)

Manjaro Steam Session is a set of scripts to create a Manjaro-based Steam machine.

It will do the following:

* Create the `steam` user account, if it does not exist, otherwise use existing account.
* Install Steam, if it is not installed.
* Install the Steam Compositor Plus and mode switch inhibitor libraries including 32-bit version.
* Configure autologin for the `steam` user account.
* Configure the default session to the Steam Compositor Plus.
* Create `reboot-to-[steamos,desktop]-mode` scripts to switch between sessions and desktop entries for those.
* Create `steamos-fg` script for games that won't run in the foreground on the SteamOS Compositor.
* Install Steam Tweaks, a set of tools that unlock various quality of life improvements for Steam on Linux.
* For Steam Compositor Plus set allowed resolution to 1920x1080 and refresh rates to 60.0 and 59.9.
* Set bluetooth adapter to enable on boot.
* Install Sakura terminal emulator.
* Install and enable OpenSSH server for remote administration.

For best results, this should be run on a fresh installation of
Manjaro GNOME desktop.

Some of these steps are optional, see [Advanced Options](#advanced-options).

## Requirements
In order to install Manjaro Steam Session, you should have a fresh installation of Manjaro GNOME Desktop 
installed. For Atari VCS you need to disable Secure Boot in BIOS settings.
Other versions of Manjaro may work, but GDM is required as display manager for session management.

## Installation
Installation is very simple. Install Manjaro GNOME first, and follow these steps:

1. Clone or download this repository:  
`git clone https://github.com/narren96c/steamos-manjaro`  

2. Run the installation script:  
`cd steamos-manjaro`  
`sudo ./install.sh`  

## Additional Steps (optional)
1. After installation system will reboot and automatically login into steam user desktop session. You can do the following steps:
   1. Run Steam to update it and do initial setup.
   2. Pair your Atari controllers via Bluetooth in GNOME Settings (highly recommended).
   3. If you have surround speaker setup, choose appropriate profile in GNOME Settings.
   4. After you are done in desktop session, reboot to SteamOS Mode. There should be an icon on the desktop that reboots to SteamOS Mode.

2. In SteamOS Mode:
   1. Add shortcut for Desktop Mode in Settings (look for Add Library Shortcut menu item).
   2. Add shortcut for "Sakura" terminal emulator.
   
## Advanced Options
The installation script has several options that you can specify upon installation
in the form of environment variables. You can specify these options by prefixing
running the install script with the options you want.

For example, if you want to disable installing OpenSSH and run the script non-
interactively, you can run this command:

`INCLUDE_OPENSSH=false NON_INTERACTIVE=true sudo ./install.sh`

Here is the list of all the available installation options:

| Option Name            | Default | Description                                                 |
| ---------------------- | ------- | ----------------------------------------------------------- |
| `NON_INTERACTIVE`      | false   | Whether or not to prompt the user during install            |
| `INCLUDE_STEAM_TWEAKS` | true    | Whether or not Steam Tweaks should be installed             |
| `INCLUDE_STEAMOS_FG`   | true    | Whether or not steamos-fg script should be installed        |
| `INCLUDE_OPENSSH`      | true    | Whether or not OpenSSH server should be installed           |
| `INCLUDE_SAKURA`       | true    | Whether or not to install a terminal emulator               |
| `UPDATE_CONFIG`        | true    | Whether or not configuration files should be (re-)installed |
| `SET_1080P`            | true    | Resctrict resolution to 1080p                               |
| `STEAM_USER`           | steam   | The username of the account to autologin as                 |
| `USER_PASSWORD`        | steam   | User password to assign, if new user account is created     |



## FAQ

### How can I switch between desktop mode and SteamOS mode?

After installation, there will not be an easy way to switch between a regular
GNOME desktop session and Steam. In order to make it easier to switch between
the two, there are two commands that are installed that will let you switch 
between the two:

* `reboot-to-desktop-mode` - sets GNOME as the default session and reboots
* `reboot-to-steamos-mode` - sets SteamOS session as the default session and reboots

You can access the terminal from Steam Big Picuture by adding a local shortcut for `Sakura`.

Alternatively, desktop entries are added for these scripts, so you can add them in 
your Steam Big Picture mode as shortcuts and they are also present in GNOME Shell as applications.  
Additionally, a desktop icon is added for rebooting into SteamOS mode.

### Some games aren't launching correctly in SteamOS mode
When using the SteamOS compositor, some games start behind the big picture UI and
no graphics are displayed. The `steamos-fg` script forces such games to be shown 
in the foreground.

To fix this, add `steamos-fg %command%` to the launch options for each game you 
wish to use this script with.

### Why not GamerOS?
GamerOS does not provide a full desktop session and this project is aimed to satisfy that need.
Desktop session allows you to install any desktop application, including Lutris.  
This way you will also have more control over how your system is set up and updated.

## Attributions
* Alkazar for steamos-fg, compositor plus and steam tweaks
* ShadowApex for SteamOS Ubuntu - original installation scripts

