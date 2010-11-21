#########################################################################################
# Deodex GalaxyS' applications and framework (Only for FroYo)				#
# You must let this script know whether you're deodexing files from I9000 or Eclair	#
# USAGE = deodexer.sh [I or M]     (I = I9000, M = M110S)				#
#########################################################################################

if test "$1" = "" ; then
	echo "***** You must choose either I or M for the first argument *****"
	exit
fi

framework_path=$PWD/ROM/framework
apk_path=$PWD/ROM/app
tools=$PWD/tools
LINE_PRE=""
LINE_PRE1=""

if test ! -d $framework_path -o ! -d $apk_path ; then
	echo "***** ROM directory must exist *****"
	exit
fi

do_baksmali_apk() {
	# depends on I or M
	if test "$1" = "M" -o "$1" = "m" ; then
		$tools/baksmali -d $framework_path -c :com.sec.android.solunconverter.jar:com.samsung.device.jar:framework-tests.jar:seccamera.jar:sechardware.jar:twframework.jar:libSECDMF.jar:javax.obex.jar:com.google.android.maps.jar -x $2.odex
	elif test "$1" = "I" -o "$1" = "i" ; then
		$tools/baksmali -d $framework_path -c :com.samsung.device.jar:seccamera.jar:sechardware.jar:twframework.jar:javax.obex.jar:com.google.android.maps.jar -x $2.odex
	fi
}


# First, we are going to deodex the framework
# read all framework files line by line
cd $framework_path
ls -1 | sed 's/\(.*\)\..*/\1/' | while read LINE

# do while reading framework files
do
	if test "$LINE" != "$LINE_PRE" ; then
		# deodex jar files
		if [ -f $LINE.odex ]; then
			echo "### Deodexing of $LINE.odex File is In progress...(FRAMEWORK)"
			$tools/baksmali -d $framework_path -x $LINE.odex
			if test "$?" != "0" ; then
				echo "****** $? ERROR (during deodexing $LINE.odex) ******"
				mkdir error_fw
				break
			fi
			$tools/smali out -o classes.dex
			zip $LINE.jar classes.dex
			rm -r classes.dex $LINE.odex out
		# zipalign apk files
		elif [ -f $LINE.apk ]; then
			echo "### Zipaligning $LINE.apk File is In progress...(FRAMEWORK)"
			$tools/zipalign -f -v 4 $LINE.apk "$LINE"_temp.apk > ../zipalign.log
			mv -f "$LINE"_temp.apk $LINE.apk
		fi
	fi
	LINE_PRE=$LINE
done
if [ -d error_fw ] ; then
	rm -r error_fw
	exit
fi
echo "============================================"
echo "**** Deodexing Framework files is done! ****"
echo "============================================"

#################################################
# now we are doing that with applications	#
#################################################
# read all apk files line by line
cd $apk_path
ls -1 | sed 's/\(.*\)\..*/\1/' | while read LINE1
# do while reading fw files
do
	if test "$LINE1" != "$LINE1_PRE" ; then
		# deodex and/or zipalign apk files
		if [ -f $LINE1.odex ]; then
			echo "### Deodexing of $LINE1.odex File is In progress...(APK)"
			do_baksmali_apk $1 $LINE1
			if test "$?" != "0" ; then
				echo "****** $? =  ERROR (during deodexing $LINE1.odex) ******"
				mkdir error_app
				break
			fi
			$tools/smali out -o classes.dex
			zip $LINE1.apk classes.dex
			rm -r classes.dex $LINE1.odex out
			echo "### Zipaligning $LINE1.apk File is In progress...(APK)"
			$tools/zipalign -f -v 4 $LINE1.apk "$LINE1"_temp.apk > ../zipalign.log
			mv -f "$LINE1"_temp.apk $LINE1.apk
		elif [ -f $LINE1.apk ]; then
			echo "### Zipaligning $LINE1.apk File is In progress...(APK)"
			$tools/zipalign -f -v 4 $LINE1.apk "$LINE1"_temp.apk > ../zipalign.log
			mv -f "$LINE1"_temp.apk $LINE1.apk
		fi
	fi
	LINE1_PRE=$LINE1
done
if [ -d error_app ] ; then
	rm -r error_app
	exit
fi
echo "============================================"
echo "******* Deodexing Apk files is done! *******"
echo "============================================"
