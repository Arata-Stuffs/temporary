# Private Keys for Signing Roms Building
Use this keys for signing your roms build

### How to use
1. clone this repository on `vendor/private-keys/keys`
or use this command line
```
git clone https://github.com/HinohArata/keys -b full vendor/private-keys/keys
```

2. Put this on your device tree `device.mk`
```
-include vendor/private-keys/keys/keys.mk
```

3. And start your build
