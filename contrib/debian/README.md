
Debian
====================
This directory contains files used to package mutxd/mutx-qt
for Debian-based Linux systems. If you compile mutxd/mutx-qt yourself, there are some useful files here.

## mutx: URI support ##


mutx-qt.desktop  (Gnome / Open Desktop)
To install:

	sudo desktop-file-install mutx-qt.desktop
	sudo update-desktop-database

If you build yourself, you will either need to modify the paths in
the .desktop file or copy or symlink your mutxqt binary to `/usr/bin`
and the `../../share/pixmaps/mutx128.png` to `/usr/share/pixmaps`

mutx-qt.protocol (KDE)

