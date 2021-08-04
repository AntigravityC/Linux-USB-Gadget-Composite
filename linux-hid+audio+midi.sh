modprobe gadgetfs
modprobe libcomposite

mount -t configfs none /sys/kernel/config

# create a gadget
mkdir /sys/kernel/config/usb_gadget/g1
# cd to its configfs node
cd /sys/kernel/config/usb_gadget/g1
# configure it (vid/pid can be anything if USB Class is used for driver compat)
echo 0x2b73 > idVendor
echo 0x0010 > idProduct

echo 0x0100 > bcdDevice 
echo 0x0200 > bcdUSB 
echo 0x00 > bDeviceClass
echo 0x00 > bDeviceSubClass
echo 0x00 > bDeviceProtocol
echo 0x40 > bMaxPacketSize0

# configure its serial/mfg/product
mkdir strings/0x409
echo "Pioneer DJ Corporation" > strings/0x409/manufacturer
echo "DDJ-WeGO4" > strings/0x409/product
echo "RFMP000209CN" > strings/0x409/serialnumber

# create a config
mkdir configs/c.1
# configure it with attributes if needed
echo 0x45 > configs/c.1/MaxPower

# create the function (name must match a usb_f_<name> module such as 'acm')
mkdir functions/uac1_legacy.0
mkdir functions/midi.0

mkdir -p functions/hid.usb0
echo 0x00 > functions/hid.usb0/protocol
echo 0x00 > functions/hid.usb0/subclass
echo 0x40 > functions/hid.usb0/report_length

echo -ne \\x06\\xa0\\xff\\x09\\x01\\xa1\\x01\\x09\\x02\\xa1\\x00\\x06\\xa1\\xff\\x09\\x03\\x09\\x04\\x15\\x80\\x25\\x7f\\x35\\x00\\x45\\xff\\x75\\x08\\x95\\x40\\x81\\x02\\x09\\x05\\x09\\x06\\x15\\x80\\x25\\x7f\\x35\\x00\\x45\\xff\\x75\\x08\\x95\\x40\\x91\\x02\\xc0\\xc0 > functions/hid.usb0/report_desc


# associate function with config
ln -s functions/uac1_legacy.0 configs/c.1
ln -s functions/midi.0 configs/c.1

ln -s functions/hid.usb0 configs/c.1/

# enable gadget by binding it to a UDC from /sys/class/udc
echo ci_hdrc.0 > UDC
# to unbind it: echo "" UDC; sleep 1; rm -rf /sys/kernel/config/usb_gadget/g1