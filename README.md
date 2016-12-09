# boardManagerStub

It is usefull to directly use a git repository instead of a board package.
Mainly during dev/test of a board.

That's why, this repo is designed to stub Arduino IDE in order to be able to
use git repository instead of installing a board package.
It allows to install tools required to build or upload a sketch (ex: gcc, flasher,...)

For example to use the repo STM32F0:

1/ Launch Arduino IDE. Open the "preferences" dialog of Arduino IDE, then add the following
link to the "Additional Boards Managers URLs" field:
https://github.com/fpistm/boardManagerStub/raw/master/STM32/package_stub_stm_index.json

2/ Open the Arduino "Boards Manager" and select "Contributed" type. Then
install the "STM32 Stub Boards"

3/ Go to the local Arduino directory:
The location is displayed in the preferences dialog. It should be:

    /Users/<USERNAME>/Library/Arduino/ (Mac)
    c:\Documents and Settings\<USERNAME>\Application Data\Arduino\ (Windows XP)
    c:\Users\<USERNAME>\AppData\Roaming\Arduino\ (Windows Vista)
    c:\Users\<USERNAME>\AppData\Local\Arduino\ (Windows 7)
    ~/.arduino/ (Linux)

Then go to "packages/STM32/tools/STM32Tools/1.0/" directory and clone or
symlinks the STM32 tools git repository:
	git clone https://github.com/stm32duino/Arduino_Tools.git tools
or
	ln -s <path to the tools git repo> tools

4/ Clone the core git repository to the Arduino IDE install
directory:
Go to the Arduino install directory then go th the 'hardware' directory
	cd <Arduino path>/hardware/
then create a directory. ex: STM
	mkdir STM
then clone or symlinks the STM32 core git repository:
	git clone https://github.com/fpistm/STM32F0.git
or
	ln -s <path to the core git repo> STM32F0

5/ Finally, restart the Arduino IDE. The STM32 board should be displayed in the board
list.

