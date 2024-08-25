#!/bin/bash
# Copyright cc 2024 HinohArata

cyan="\033[96m"
green="\033[92m"
red="\033[91m"
blue="\033[94m"
yellow="\033[93m"

# setup dir
WORK_DIR=$(pwd)
TC_DIR="${WORK_DIR}/clang-neutron"
AK3_DIR="${WORK_DIR}/AnyKernel3"
DEFCONFIG="surya_defconfig"
DEVICE="Poco X3 NFC (Surya)"
TELEGRAM_FOLDER="/workspace/work/telegram"
TELEGRAM="${TELEGRAM_FOLDER}/telegram"
IMAGE="out/arch/arm64/boot/Image.gz"
DTB="out/arch/arm64/boot/dtb.img"
DTBO="out/arch/arm64/boot/dtbo.img"
CHATID="-1002150767148"
TELEGRAM_TOKEN="6779607065:AAEzVWDTx1OFDE_gQu-FzhrS87rXd68LxSE"
CL=$(git log --oneline --pretty="-%m %s" -50)
DISTRO=$(source /etc/os-release && echo ${PRETTY_NAME})
DATE=$(TZ='Asia/Jakarta' date)
LINUX=$(make kernelversion)

function git_variable() {
if test -z "$(git rev-parse --show-cdup 2>/dev/null)" &&
   head=$(git rev-parse --verify HEAD 2>/dev/null); then
	ZIPNAME="${ZIPNAME::-4}-$(echo $head | cut -c1-8).zip"
fi
}

function setup_dep() {
    if ! [ -d "$TC_DIR" ]; then
        echo "Neutron Clang not found! Cloning to $TC_DIR..."
        if ! git clone --depth=1 https://github.com/Shiryu-Kernel/neutron-clang.git "$TC_DIR"; then
            echo "Cloning failed! Aborting..."
        fi
    fi
	
	if ! [ -d "${TELEGRAM_FOLDER}" ]; then
        git clone https://github.com/fabianonline/telegram.sh/ "${TELEGRAM_FOLDER}"
    fi
}

function clean() {
    echo -e "\n"
    echo -e "$red << cleaning up >> \033[0m"
    rm -rf out/arch/arm64/boot
    echo -e "${red}Removing out/arch/arm64/boot\033[0m"
    rm -rf $AK3_DIR/Image.gz $AK3_DIR/dtb*
    echo -e "${red}Removing AnyKernel3/Image.gz AnyKernel3/dtb.img AnyKernel/dtbo.img\033[0m"
    rm_zip
}

function build_kernel() {
    # Setup kernel type
    echo -ne "\n${blue}Enter kernel output name\033[0m(EX. Shiryu_Codename): "
    read -r kername
    KERNEL="${kername}"
    ZIPNAME="${KERNEL}-kernel-surya-$(date '+%Y%m%d-%H%M').zip"
    echo -e "[+] ${green}Applying kernel name for output...\033[0m"
    sleep 2

    # Setup kernel type
    echo -ne "\n${blue}Enter kernel output name\033[0m(EX: KSU or NonKSU): "
    read -r kerntype
    KERNELTYPE="${kerntype}"
    echo -e "[+] ${green}Applying kernel type for output...\033[0m"
    sleep 2

    SECONDS=0 # builtin bash timer
    export PATH="$TC_DIR/bin:$PATH"
    if [[ $1 = "-r" || $1 = "--regen" ]]; then
	    make O=out ARCH=arm64 $DEFCONFIG savedefconfig
    	cp out/defconfig arch/arm64/configs/$DEFCONFIG
    	echo -e "\nSuccessfully regenerated defconfig at $DEFCONFIG"
    else
        echo -e "\n${red}Failed to regenerate defconfig\033[0m"
    fi

    if [[ $1 = "-rf" || $1 = "--regen-full" ]]; then
	    make O=out ARCH=arm64 $DEFCONFIG
	    cp out/.config arch/arm64/configs/$DEFCONFIG
	    echo -e "\nSuccessfully regenerated full defconfig at $DEFCONFIG"
    else
        echo -e "\n${red}Failed to regenerate defconfig\033[0m"
    fi

    if [[ $1 = "-c" || $1 = "--clean" ]]; then
    	rm -rf out
    fi
    mkdir -p out
    make O=out ARCH=arm64 $DEFCONFIG
    echo -e "\nStarting compilation...\n"
    make -j$(nproc --all) O=out ARCH=arm64 CC=clang LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_COMPAT=arm-linux-gnueabi- LLVM=1 LLVM_IAS=1 Image.gz dtb.img dtbo.img 2> >(tee log.txt >&2)

    if [ -f "$IMAGE" ] && [ -f "$DTB" ] && [ -f "$DTBO" ]; then
    	echo -e "\n${green}Kernel compiled succesfully!\033[0m"
    else
        echo -e "\n${red}Compiling kernel failed!\033[0m"
    fi
}

function zipping() {
    if [ -d "$AK3_DIR" ]; then
        echo -e "\n${blue}AnyKernel3 found! Copying file and zipping...\033[0m" 
	elif ! git clone -q https://github.com/Shiryu-Kernel/AnyKernel3.git "$AK3_DIR"; then
		echo -e "\nAnyKernel3 repo not found locally and could not clone from GitHub! Aborting..."
	fi

    if [ -f "$IMAGE" ] && [ -f "$DTB" ] && [ -f "$DTBO" ]; then
    	cp $IMAGE $DTB $DTBO $AK3_DIR
    	cd $AK3_DIR
    	git checkout shiryu &> /dev/null
    	zip -r9 "../$ZIPNAME" * -x .git README.md *placeholder
        cd ..
    	echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
    	echo -e "Zip: ${green}$ZIPNAME \033[0m"
    else
    	echo -e "\n${red}Zipping failed!\033[0m"
    fi
	
}

function tg_cast() {
    curl -s -X POST https://api.telegram.org/bot"$TELEGRAM_TOKEN"/sendMessage -d disable_web_page_preview="true" -d chat_id="$CHATID" -d "parse_mode=MARKDOWN" -d text="$(
                for POST in "${@}"; do
                        echo "${POST}"
                done
        )" &> /dev/null
}
function tg_ship() {
    "${TELEGRAM}" -f "${ZIPNAME}" -t "${TELEGRAM_TOKEN}" -c "${CHATID}" -H \
    "$(
                for POST in "${@}"; do
                        echo "${POST}"
                done
    )"
}
function tg_msg() {
    "${TELEGRAM}" -t "${TELEGRAM_TOKEN}" -c "${CHATID}" -H \
    "$(
                for POST in "${@}"; do
                        echo "${POST}"
                done
    )"
}
function tg_fail() {
    "${TELEGRAM}" -f "${LOGS}" -t "${TELEGRAM_TOKEN}" -c "${CHATID}" -H \
    "$(
                for POST in "${@}"; do
                        echo "${POST}"
                done
    )"
}

function upload() {
    # Ship it to the CI channel
    NAMA=$(cat "arch/arm64/configs/$DEFCONFIG" | grep "CONFIG_LOCALVERSION=" | sed 's/CONFIG_LOCALVERSION="-*//g' | sed 's/"*//g')
    CSTRING=$("$TC_DIR"/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
        tg_ship "<b>-------- NEW UPDATES --------</b>" \
                "Compiling with <code>$(nproc --all)</code> CPUs" \
                "------------------------------------" \
                "<b>Host :</b><code> ${DISTRO}</code>" \
                "<b>Device :</b><code> ${DEVICE}</code>" \
                "<b>Version :</b><code> ${KERNELTYPE}</code>" \
                "<b>Linux :</b><code> ${LINUX}</code>" \
                "<b>Kernel :</b><code> ${NAMA}</code>" \
                "<b>Date :</b><code> ${DATE}</code>" \
                "<b>Compiler :</b><code> ${CSTRING}</code>" \
                "------------------------------------"

        tg_msg "<b>Changelogs:</b>" \
                "<code>${CL}</code>"
}

function rm_zip() {
    cd "$WORK_DIR"
    if [ -f "$ZIPNAME" ]; then
        echo -e "\nZip file found, removing now..."
        rm -rf "$ZIPNAME"
        sleep 2
        echo -e "\n${green}Succesfully deleted $ZIPNAME...\033[0m"
    else
        echo -e "\n${red}Zip file not found, nothing file removed...\033[0m"
        sleep 2
    fi
}

# execute
git_variable
setup_dep
