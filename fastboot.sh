#!/bin/bash

usage ()
{
	echo "Usage: sudo fastboot.sh <options>";
	echo "options:";
	echo "  --help Show this message and exit"
	echo "  --revg Flashes the dtb required for Rev-G J6 EVm which has 10inch panel";
	exit 1;
}

#no args case
if [ "$1" = "--help" ] ; then
	usage
fi

# Pre-packaged DB
export FASTBOOT=${FASTBOOT-"./fastboot"}
export PRODUCT_OUT=${PRODUCT_OUT-"./"}

echo "Fastboot: $FASTBOOT"
echo "Image location: $PRODUCT_OUT"


# =============================================================================
# pre-run
# =============================================================================

# Verify fastboot program is available
# Verify user permission to run fastboot
# Verify fastboot detects a device, otherwise exit
if [ -f ${FASTBOOT} ]; then
	fastboot_status=`${FASTBOOT} devices 2>&1`
	if [ `echo $fastboot_status | grep -wc "no permissions"` -gt 0 ]; then
		cat <<-EOF >&2
		-------------------------------------------
		 Fastboot requires administrator permissions
		 Please run the script as root or create a
		 fastboot udev rule, e.g:

		 % cat /etc/udev/rules.d/99_android.rules
		   SUBSYSTEM=="usb",
		   SYSFS{idVendor}=="0451"
		   OWNER="<username>"
		   GROUP="adm"
		-------------------------------------------
		EOF
		exit 1
	elif [ "X$fastboot_status" = "X" ]; then
		echo "No device detected. Please ensure that" \
			 "fastboot is running on the target device"
                exit -1;
	else
		device=`echo $fastboot_status | awk '{print$1}'`
		echo -e "\nFastboot - device detected: $device\n"
	fi
else
	echo "Error: fastboot is not available at ${FASTBOOT}"
        exit -1;
fi

## poll the board to find out its configuration
#product=`${FASTBOOT} getvar product 2>&1 | grep product | awk '{print$2}'`
cpu=`${FASTBOOT} getvar cpu 2>&1         | grep cpu     | awk '{print$2}'`
cputype=`${FASTBOOT} getvar secure 2>&1  | grep secure  | awk '{print$2}'`


# Make EMU = HS
if [ ${cputype} = "EMU" ] || [ ${cputype} = "HS" ]; then
        cputype="HS"
	xloader="${PRODUCT_OUT}${cputype}_QSPI_MLO"
fi

# If fastboot does not support getvar default to GP
if [ ${cputype} = "" ] || [ ${cputype} = "GP" ]; then
	cputype="GP"
	xloader="${PRODUCT_OUT}${cputype}_MLO"
fi

# Based on cpu, decide the dtb to flash, default fall back to J6
if [ ${cpu} = "J6ECO" ]; then
        environment="${PRODUCT_OUT}dra72-evm.dtb"
else
        environment="${PRODUCT_OUT}dra7-evm.dtb"
fi

# Special case to flash dtb for 10" panel board
if [ "$1" = "--revg" ] && [ ${cpu} = "J6"  ]; then
        environment="${PRODUCT_OUT}dra7-evm-g.dtb"
fi


# Create the filename
bootimg="${PRODUCT_OUT}boot.img"
uboot="${PRODUCT_OUT}u-boot.img"
systemimg="${PRODUCT_OUT}system.img"
userdataimg="${PRODUCT_OUT}userdata.img"
cacheimg="${PRODUCT_OUT}cache.img"
efsimg="${PRODUCT_OUT}efs.img"
recoveryimg="${PRODUCT_OUT}recovery.img"


# Verify that all the files required for the fastboot flash
# process are available

if [ ! -e "${bootimg}" ] ; then
  echo "Missing ${bootimg}"
  exit -1;
fi
if [ ! -e "$xloader" ] ; then
  echo "Missing ${xloader}"
  exit -1;
fi
if [ ! -e "${uboot}" ] ; then
  echo "Missing ${uboot}"
  exit -1;
fi
if [ ! -e "${environment}" ] ; then
  echo "Missing ${environment}"
  exit -1;
fi
if [ ! -e "${systemimg}" ] ; then
  echo "Missing ${systemimg}"
  exit -1;
fi
if [ ! -e "${userdataimg}" ] ; then
  echo "Missing ${userdataimg}"
  exit -1;
fi
if [ ! -e "${cacheimg}" ] ; then
  echo "Missing ${cacheimg}"
#  exit -1;
fi
if [ ! -e "${recoveryimg}" ] ; then
  echo "Missing ${recoveryimg}"
  exit -1;
fi

echo "Create GPT partition table"
${FASTBOOT} oem format

echo "Setting target for bootloader to SPI"
${FASTBOOT} oem spi

sleep 3

echo "Flashing bootloader....."
echo "   xloader: ${xloader}"
${FASTBOOT} flash xloader	${xloader}

sleep 3

${FASTBOOT} flash bootloader	${uboot}

#echo "Reboot: make sure new bootloader runs..."
${FASTBOOT} reboot-bootloader

sleep 5

echo "Re-creating GPT partition table with new bootloader"
${FASTBOOT} oem format

echo "Flash android partitions"
${FASTBOOT} flash boot		${bootimg}
echo "Flashing device tree ${environment}"
${FASTBOOT} flash environment	${environment}
${FASTBOOT} flash recovery	${recoveryimg}
${FASTBOOT} flash system	${systemimg}

userdataimg_orig="${userdataimg}.orig"
if [ ! -f $userdataimg_orig ]; then
	cp $userdataimg $userdataimg_orig
else
	cp $userdataimg_orig $userdataimg
fi

echo "Resizing userdata.img"
resizefail=0
userdatasize=`./fastboot getvar userdata_size 2>&1 | grep "userdata_size" | awk '{print$2}'`
if [ -n "$userdatasize" ]; then
	while [ 1 ];do
		echo Current userdata partition size=${userdatasize} KB
		if [ -d "./data" ]; then
			echo "Removing data"
			rm -rf ./data || resizefail=1
			if [ $resizefail -eq 1 ]; then
				echo "unable to remove data folder" && break
			fi
		fi
		mkdir ./data
		./simg2img userdata.img userdata.img.raw
		mount -o loop -o grpid -t ext4 ./userdata.img.raw ./data || resizefail=1
		if [ $resizefail -eq 1 ]; then
			echo "Mount failed" && break
		fi
		./make_ext4fs -s -l ${userdatasize}K -a data userdata.img data/
		sync
		umount data
		sync
		rm -rf ./data
		rm userdata.img.raw
		break
	done
else
	resizefail=1
fi

if [ $resizefail -eq 1 ]; then
	echo "userdata resize failed."
	echo "Eg: sudo ./fastboot.sh"
	echo "For now, we are defaulting to original userdata.img"
	cp $userdataimg_orig $userdataimg
fi
${FASTBOOT} flash userdata ${userdataimg}

if [ "$1" != "--noefs" ] ; then
	if [ ! -f ${efsimg} ] ; then
	  echo "Creating efs.img as 16M ext4 img..."
	  test -d ./efs/ || mkdir efs
	  ./make_ext4fs -s -l 16M -a efs efs.img efs/
	else
          echo "Using previously created efs.img..."
	fi

	${FASTBOOT} flash efs ${efsimg}
else
  echo "efs partition is untouched"
fi

#Create cache.img
if [ ! -f ${cacheimg} ]
then
	echo "Creating cache.img as empty ext4 img...."
	rm -rf /tmp/fastboot-cache
	mkdir /tmp/fastboot-cache
	./make_ext4fs -s -l 256M -a cache ${cacheimg} /tmp/fastboot-cache/
	rm -rf /tmp/fastboot-cache
fi

#flash cache.img
${FASTBOOT} flash cache		${cacheimg}

#reboot now
#${FASTBOOT} reboot

#if [ $resizefail -eq 1 ]; then
#	echo "--------------------------------------------------"
#	echo "Attempt was made to resize the userdata partition image"
#	echo "to the size available on your SOM. But it failed either"
#	echo "because it failed to remove existing ./data folder or because"
#	echo "you are not running this script with superuser privileges"
#	echo "Don't panic! The script just loaded the original userdata.img"
#	echo "so, things should just work as expected. Just that the size"
#	echo "of /data will be smaller on target."
#	echo ""
#	echo "If you really want to resize userdata.img, remove any existing"
#	echo "./data folder and run \"sudo ./fastboot.sh\""
#	echo "For now, we are defaulting to original userdata.img"
#	echo "--------------------------------------------------"
#fi

