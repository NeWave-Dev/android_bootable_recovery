#!/system/bin/sh
# By Hashcode
# Last Editted: 09/21/2013
PATH=/system/bin:/system/xbin
BLOCK_DIR=/dev/block

BLOCK_SYSTEM=mmcblk0p16
BLOCK_BOOT=mmcblk0p20

SYS_BLOCK_FSTYPE=ext4
INSTALLPATH=$1

CURRENTSYS=`$INSTALLPATH/busybox readlink $BLOCK_DIR/$BLOCK_SYSTEM`
echo "CURRENTSYS = $CURRENTSYS" >> $LOGFILE
if [ "$CURRENTSYS" = "$BLOCK_DIR/loop-system" ]; then
	DESTMOUNT=$INSTALLPATH/system
	if [ ! -d "$DESTMOUNT" ]; then
		$INSTALLPATH/busybox mkdir $DESTMOUNT
	fi
	$INSTALLPATH/busybox mount -t $SYS_BLOCK_FSTYPE $BLOCK_DIR/$BLOCK_SYSTEM-orig $DESTMOUNT
else
	DESTMOUNT=/system
	sync
	$INSTALLPATH/busybox mount -o remount,rw $DESTMOUNT
fi
echo "DESTMOUNT = $DESTMOUNT" >> $LOGFILE

# Make sure the hijack is going to run by linking this firmware file to a ramdisk based file which will disappear after each boot
$INSTALLPATH/busybox mount -o remount,rw /
$INSTALLPATH/busybox rm $DESTMOUNT/etc/firmware/q6.mdt
$INSTALLPATH/busybox cp /firmware/image/q6.mdt /q6.mdt
$INSTALLPATH/busybox ln -s /q6.mdt $DESTMOUNT/etc/firmware/q6.mdt
$INSTALLPATH/busybox mount -o remount,ro /

$INSTALLPATH/busybox echo 1 > /data/.recovery_mode
$INSTALLPATH/busybox sync

# determine our active system, and umount/remount accordingly
if [ "$CURRENTSYS" = "$BLOCK_DIR/loop-system" ]; then
	$INSTALLPATH/busybox umount $DESTMOUNT
	$INSTALLPATH/busybox rmdir $DESTMOUNT
else
	$INSTALLPATH/busybox mount -o ro,remount $DESTMOUNT
fi


