ardu: ardu.nim nim.cfg ardusprites.nim *.bmp sprites/*.bmp
	nim cpp -d:release -d:danger --opt:size --os:standalone ardu

ardu.hex: ardu
	avr-objcopy -O ihex -R .eeprom ardu ardu.hex

run: ardu.hex
	../ProjectABE/ProjectABE ../wrapped/ardu.hex

size: ardu
	avr-size -C --mcu=atmega32u4 ardu
	@echo "Maximum program space is 28672 bytes."
	@echo "Maximum data space is 2560 bytes (rest will be left for local variables)."

upload: ardu.hex
	avrdude -C /etc/avrdude.conf -c arduino -p atmega32u4 -b 57600 -P /dev/ttyACM0 -cavr109 -D -U ./ardu.hex
