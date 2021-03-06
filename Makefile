# Linux(Ubuntu)用avr-gcc用ほぼmega88用Makefile
# 最後に出力される text + data がプログラムメモリーの使用量です．

# デバイスと周波数[Hz]
DEVICE = atmega88
F_CPU  = 8000000UL

# FUSES ( Div8解除 )
LFUSE  = 0xe2
HFUSE  = 0xdf
EFUSE  = 0xf9

# ソースコードと出力ファイル
CSOURCES = usart.c spi.c i2c.c sd.c main.c adxl345.c l3gd20.c lps331ap.c hmc5883l.c
SSOURCES = 
TARGET   = main

# オプション
CFLAGS  = -Os -fshort-enums -g -Wall -mmcu=$(DEVICE) -DF_CPU=$(F_CPU)
LDFLAGS = -g -mmcu=$(DEVICE)
LINK	= 
INCLUDE = 

# 環境依存定数
MAKE    = make -r
AVRCC   = avr-gcc
OBJDUMP = avr-objdump
OBJCOPY = avr-objcopy
SIZE    = avr-size
AVRDUDE = avrdude
SUDO    = sudo
SIM     = ../../usr/bin/simulavr

# 偽ルールとオブジェクトファイル保持
.PRECIOUS : $(CSOURCES:.c=.o)
.PRECIOUS : $(SSOURCES:.s=.o)
.PHONY    : $(TARGET) eeprom install fuse prompt rebuild sim clean

# ルール
all : $(TARGET)

$(TARGET) : $(TARGET).hex

%.o : %.s
	$(AVRCC) $(CFLAGS) $(INCLUDE) -c $<

%.o : %.c 
	$(AVRCC) $(CFLAGS) $(INCLUDE) -c $<

%.s : %.c
	$(AVRCC) $(CFLAGS) $(INCLUDE) -S $<

%.elf : $(CSOURCES:.c=.o) $(SSOURCES:.s=.o)
	$(AVRCC) $(LDFLAGS) -Wl,-Map,$(@:.elf=.map) $(LINK) -o $@ $+
	$(OBJDUMP) -h -S $@ > $(@:.elf=.lst)

%.hex : %.elf
	$(OBJCOPY) -j .text -j .data -O ihex $< $@
	$(SIZE) $<

eeprom : $(TARGET).elf
	$(OBJCOPY) -j .eeprom --change-section-lma .eeprom=0 -O ihex $(TARGET).elf $(TARGET)_eeprom.hex	

install : $(TARGET)
	$(SUDO) $(AVRDUDE) -P usb -c avrisp2 -p $(DEVICE) -U flash:w:$(TARGET).hex

fuse :
	$(SUDO) $(AVRDUDE) -P usb -c avrisp2 -p $(DEVICE) -u -U lfuse:w:$(LFUSE):m -U hfuse:w:$(HFUSE):m -U efuse:w:$(EFUSE):m

prompt :
	$(SUDO) $(AVRDUDE) -P usb -c avrisp2 -p $(DEVICE) -t

sim : $(TARGET).elf
	$(SIM) -d $(DEVICE) -f $+ -g

clean :
	-rm $(CSOURCES:.c=.o)
	-rm $(SSOURCES:.s=.o)
	-rm *.lst
	-rm *.map
	-rm *.elf
	-rm *.hex

rebuild :
	$(MAKE) -B

