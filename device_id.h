#ifndef DEVICE_ID_H_INCLUDED
#define DEVICE_ID_H_INCLUDED

typedef enum SensorDeviceId_tag {
	ID_ADXL345       = 0x00,
	ID_LPS331AP      = 0x01,
	ID_LPS331AP_TEMP = 0x02,
	ID_L3GD20        = 0x03,
	ID_HMC5883L      = 0x04,
	DEVICE_COUNT     = 0x05,
} SensorDeviceId;

#endif
