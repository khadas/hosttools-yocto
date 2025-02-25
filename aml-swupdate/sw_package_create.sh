#!/bin/bash

CONTAINER_VER="1.0"
PRODUCT_NAME="aml-software"

if [ $# != 1 ] ; then
echo $#
echo "USAGE: $0"
exit 1;
fi

cd $1

source sw-package-filelist

#add hash value for all files
for i in $HASH_FILES;do
	value_tmp=$(sha256sum $i);
	value_sha256=${value_tmp:0:64};
	key_value="sha256 = \""$value_sha256"\"";
	sed -i "/filename = \"$i\";/a\\\t\t\t$key_value" sw-description;
done

#Generating signature
openssl dgst -sha256 -sign swupdate-priv.pem sw-description > sw-description.sig

#create software.swu
for i in $FILES;do
	echo $i;done | cpio -ov -H crc >  software.swu
echo software.swu  | cpio -ov -H crc >  ${PRODUCT_NAME}_${CONTAINER_VER}.swu
cd -
