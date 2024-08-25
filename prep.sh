A="kernel/xiaomi/surya"
mkdir -p vendor/xiaomi && cp -rf $A/cam/* vendor/xiaomi/

mkdir -p device/xiaomi && cp -rf $A/cam2/* device/xiaomi/

mkdir -p device/xiaomi/surya/parts && cp -rf $A/parts/* device/xiaomi/surya/parts/

mkdir -p vendor/private-keys && cp -rf $A/key/* vendor/private-keys/

rm -rf $A/parts $A/key $A/cam $A/cam2 $A/prep.sh