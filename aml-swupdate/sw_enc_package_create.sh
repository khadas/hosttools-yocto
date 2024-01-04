#!/bin/bash

CONTAINER_VER="1.0"
PRODUCT_NAME="aml-software"
SWUPDATE_AES_FILE="encryption_key"

if [ $# != 1 ] ; then
echo $#
echo "USAGE: $0"
exit 1;
fi

#
# The key must be generated as described in doc
# with
# openssl enc -aes-256-cbc -k <PASSPHRASE> -P -md sha1 -nosalt
# The file is in the format
# key=
# iv=
# parameters: $1 = input file, $2 = output file
swu_encrypt_file() {
	input=$1
	output=$2
	key=`cat ${SWUPDATE_AES_FILE} | grep ^key | cut -d '=' -f 2`
	#iv=`cat ${SWUPDATE_AES_FILE} | grep ^iv | cut -d '=' -f 2`
	iv=$3
	if [ -z ${key} ] || [ -z ${iv} ];then
		echo "SWUPDATE_AES_FILE=$SWUPDATE_AES_FILE does not contain valid keys"
	fi
	openssl enc -aes-256-cbc -in ${input} -out ${output} -K ${key} -iv ${iv} -nosalt
}

cd $1

source sw-package-filelist

#encrypt all image files
for i in $HASH_FILES;do
	if [ $i != "update.sh" ] && [ $i != "u-boot.bin.signed" ] && [ $i != "u-boot.bin" ] && [ $i != "dtb.img" ] ; then
		iv=$(openssl rand -hex 16);
		iv_value="ivt = \""$iv"\"";
		sed -i "s/filename = \"$i\"/filename = \"$i.enc\"/" sw-description;
		sed -i "/filename = \"$i.enc\";/a\\\t\t\tencrypted = true;" sw-description;
		sed -i "/filename = \"$i.enc\";/a\\\t\t\t$iv_value;" sw-description;
		swu_encrypt_file $i $i.enc $iv;
	fi
done

#add hash value for all files
for i in $HASH_FILES;do
	if [ $i == "update.sh" ] || [ $i == "u-boot.bin.signed" ] || [ $i == "u-boot.bin" ] || [ $i == "dtb.img" ] ; then
		value_tmp=$(sha256sum $i);
		value_sha256=${value_tmp:0:64};
		key_value="sha256 = \""$value_sha256"\"";
		sed -i "/filename = \"$i\";/a\\\t\t\t$key_value;" sw-description;
	else
		value_tmp=$(sha256sum $i.enc);
		value_sha256=${value_tmp:0:64};
		key_value="sha256 = \""$value_sha256"\"";
		sed -i "/filename = \"$i.enc\";/a\\\t\t\t$key_value;" sw-description;
	fi
done

#Generating signature
openssl dgst -sha256 -sign swupdate-priv.pem sw-description > sw-description.sig

#create software.swu
for i in $FILES;do
	if [ $i == "update.sh" ] || [ $i == "sw-description" ] || [ $i == "sw-description.sig" ] || [ $i == "u-boot.bin.signed" ] || [ $i == "u-boot.bin" ] || [ $i == "dtb.img" ] ; then
		echo $i;
	else
		echo $i.enc;
	fi
done | cpio -ov -H crc >  software.swu

echo software.swu  | cpio -ov -H crc >  ${PRODUCT_NAME}_${CONTAINER_VER}.swu
cd -
