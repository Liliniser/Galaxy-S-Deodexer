rom_path=$PWD/ROM
sign_tools=$PWD/tools/signing

if test ! -d $rom_path ; then
	echo "***** ROM directory must exist *****"
	exit
fi

cd $rom_path

zip -r update_unsigned.zip ./*

java -jar $sign_tools/signapk.jar testkey.x509.pem testkey.pk8 $rom_path/update_unsigned.zip $rom_path/update_signed_$(date '+%Y:%m:%d +%H:%M:%S').zip \

&& rm $rom_path/update_unsigned.zip

