import hid
import sys
import os
from PyQt6.QtCore import QTimer
from PyQt6.QtWidgets import (QApplication
                             ,QSystemTrayIcon
                             ,QMenu
                             )
from PyQt6.QtGui import QAction,QIcon

path_to_main = os.path.dirname(os.path.realpath(__file__))

def get_path_to_remote_interface():
    devices = hid.enumerate(vid=0x3434, pid=0xd028)

    for device in devices:
        if device.get('interface_number')==4:
            return device.get('path')

class MainWindow(QSystemTrayIcon):
    def __init__(self,appin):
        super().__init__(appin)

        self.menu = QMenu()
        self.quit = QAction("Quit")
        self.quit.triggered.connect(appin.quit)
        self.menu.addAction(self.quit)

        self.setContextMenu(self.menu)

        self.icon0 = QIcon(path_to_main + '/battery0.png')
        self.icon1 = QIcon(path_to_main + '/battery1.png')
        self.icon2 = QIcon(path_to_main + '/battery2.png')
        self.icon3 = QIcon(path_to_main + '/battery3.png')
        self.icon4 = QIcon(path_to_main + '/battery4.png')
        self.icon5 = QIcon(path_to_main + '/battery5.png')
            
        self.update_status()
        self.setVisible(True)

        self.timer = QTimer()
        self.timer.setInterval(300000)
        self.timer.timeout.connect(self.update_status)
        self.timer.start()

    def set_battery_icon(self):
        if self.battery_level:
            if self.battery_level >= 90:
                self.setIcon(self.icon5)
            elif self.battery_level >= 80:
                self.setIcon(self.icon4)
            elif self.battery_level >= 60:
                self.setIcon(self.icon3)
            elif self.battery_level >= 40:
                self.setIcon(self.icon2)
            elif self.battery_level >= 20:
                self.setIcon(self.icon1)
            else:
                self.setIcon(self.icon0)
        else:
            self.setIcon(self.icon0)

    def get_keychron_battery_status(self):
        try:
            with hid.Device(vid=0x3434, pid=0xd028,path=get_path_to_remote_interface()) as device:   
                device.write(bytes.fromhex('b306' + '00' * 62))
                report = device.read(128, 1000)

                hex_data = report.hex()

                data_array = [hex_data[x:x+2] for x in range(0,len(hex_data),2) ]

                self.battery_level = int(data_array[20],16)
                self.setToolTip(f'Battery level:{self.battery_level}%')
        except hid.HIDException:
            if len(hid.enumerate(vid=0x3434, pid=0xd048))>0:
                self.setToolTip('Device dose not report battery level while wired')
            else:
                self.setToolTip('Device couldnt be detected')
            self.battery_level = None

    def update_status(self):
        try:
            self.get_keychron_battery_status()    
            self.set_battery_icon()
        except IndexError:
            print('unable to load data')
            


app = QApplication(sys.argv)

w = MainWindow(app)
w.show()

app.exec()