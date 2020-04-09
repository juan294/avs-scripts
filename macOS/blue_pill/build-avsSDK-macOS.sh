#!/usr/bin/env sh
# --- I'M FEELING LUCKY ---
CLIENT_ID="YOUR_CLIENT_ID"
PRODUCT_ID="YOUR_PRODUCT_ID"
DSN="DEVICE_SERIAL_NUMBER"
HOME="PATH_TO_HOME_FOLDER"
PROJECT_DIR=${HOME}"PATH_TO_PROJECT_FOLDER"
CPU_CORES="N_CORES_AVAILABLE"
BRANCH="THE_SDK_BRANCH"
DEBUG_LEVEL="SAMPLE_APP_DEBUG_LEVEL"

mkdir -p ${PROJECT_DIR}
cd ${PROJECT_DIR}
mkdir sdk-build third-party sdk-install db sdk-source application-necessities

cd application-necessities
mkdir sound-files

brew install curl-openssl
echo export PATH="/usr/local/opt/curl-openssl/bin:$PATH" >> ~/.bash_profile

brew install gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-libav sqlite3 repo cmake clang-format doxygen wget git

cd ${PROJECT_DIR}/third-party
wget -c http://www.portaudio.com/archives/pa_stable_v190600_20161030.tgz || exit 1
tar xf pa_stable_v190600_20161030.tgz
cd portaudio
./configure --disable-mac-universal && make $CPU_CORES || exit 1

opensslFolder=$(brew info openssl | grep /usr/local/Cellar | cut -d '(' -f1 | tr -d '[:space:]')
echo export PKG_CONFIG_PATH="/usr/local/opt/libffi/lib/pkgconfig:$opensslFolder/lib/pkgconfig:$PKG_CONFIG_PATH" >> ~/.bash_profile
source $HOME/.bash_profile

cd ${PROJECT_DIR}
git clone --single-branch --branch $BRANCH git://github.com/alexa/avs-device-sdk.git || exit 1

cd ${PROJECT_DIR}/sdk-build
cmake ../avs-device-sdk \
-DGSTREAMER_MEDIA_PLAYER=ON \
-DCURL_LIBRARY=/usr/local/opt/curl-openssl/lib/libcurl.dylib \
-DCURL_INCLUDE_DIR=/usr/local/opt/curl-openssl/include \
-DPORTAUDIO=ON \
-DPORTAUDIO_LIB_PATH=${PROJECT_DIR}/third-party/portaudio/lib/.libs/libportaudio.a \
-DPORTAUDIO_INCLUDE_DIR=${PROJECT_DIR}/third-party/portaudio/include \
-DCMAKE_BUILD_TYPE=DEBUG \
-DCMAKE_INSTALL_PREFIX=${PROJECT_DIR}/sdk-install || exit 1

make $CPU_CORES || exit 1

make $CPU_CORES install || exit 1

cd ${PROJECT_DIR}/avs-device-sdk/tools/Install
echo "{\"deviceInfo\": {\"clientId\": \"$CLIENT_ID\",\"productId\": \"$PRODUCT_ID\"}}" > config.json

if [ "$BRANCH" == "v1.15" ]; then
    bash genConfig.sh config.json \
    $DSN \
    ${PROJECT_DIR}/db \
    ${PROJECT_DIR}/avs-device-sdk \
    ${PROJECT_DIR}/sdk-build/Integration/AlexaClientSDKConfig.json || exit 1
else
    bash genConfig.sh config.json \
    $DSN \
    ${PROJECT_DIR}/db \
    ${PROJECT_DIR}/avs-device-sdk \
    ${PROJECT_DIR}/sdk-build/Integration/AlexaClientSDKConfig.json \
    -DSDK_CONFIG_MANUFACTURER_NAME="AE" \
    -DSDK_CONFIG_DEVICE_DESCRIPTION="macos" || exit 1
fi

cd ${PROJECT_DIR}/sdk-build/SampleApp/src
./SampleApp ${PROJECT_DIR}/sdk-build/Integration/AlexaClientSDKConfig.json $DEBUG_LEVEL
