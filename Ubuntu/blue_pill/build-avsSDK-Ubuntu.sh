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
mkdir sdk-build third-party sdk-install db

sudo apt-get install -y git gcc \
cmake openssl clang-format libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad libgstreamer-plugins-bad1.0-dev \
gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-doc gstreamer1.0-tools libssl-dev pulseaudio doxygen libsqlite3-dev curl libcurl4-openssl-dev \
libasound2-dev || exit 1

cd ${PROJECT_DIR}/third-party
wget -c http://www.portaudio.com/archives/pa_stable_v190600_20161030.tgz || exit 1
tar xf pa_stable_v190600_20161030.tgz
cd portaudio
./configure -without-jack && make $CPU_CORES || exit 1

cd ${PROJECT_DIR}

git clone --single-branch --branch $BRANCH git://github.com/alexa/avs-device-sdk.git || exit 1

cd ${PROJECT_DIR}/third-party

git clone git://github.com/Sensory/alexa-rpi.git || exit 1

cd ${PROJECT_DIR}/sdk-build

if [ "$BRANCH" != "v1.18.0" ]; then
    cmake ../avs-device-sdk \
    -DGSTREAMER_MEDIA_PLAYER=ON \
    -DPORTAUDIO=ON \
    -DPORTAUDIO_LIB_PATH=${PROJECT_DIR}/third-party/portaudio/lib/.libs/libportaudio.a \
    -DPORTAUDIO_INCLUDE_DIR=${PROJECT_DIR}/third-party/portaudio/include \
    -DCMAKE_BUILD_TYPE=DEBUG \
    -DCMAKE_INSTALL_PREFIX=${PROJECT_DIR}/sdk-install || exit 1
else
    cmake ../avs-device-sdk \
    -DGSTREAMER_MEDIA_PLAYER=ON \
    -DPORTAUDIO=ON \
    -DPORTAUDIO_LIB_PATH=${PROJECT_DIR}/third-party/portaudio/lib/.libs/libportaudio.so \
    -DPORTAUDIO_INCLUDE_DIR=${PROJECT_DIR}/third-party/portaudio/include \
    -DCMAKE_BUILD_TYPE=DEBUG \
    -DCMAKE_INSTALL_PREFIX=${PROJECT_DIR}/sdk-install || exit 1
fi

make $CPU_CORES || exit 1

make $CPU_CORES install || exit 1

cd ${PROJECT_DIR}/avs-device-sdk/tools/Install
echo "{\"deviceInfo\": {\"CLIENT_ID\": \"$CLIENT_ID\",\"PRODUCT_ID\": \"$PRODUCT_ID\"}}" > config.json

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
    -DSDK_CONFIG_DEVICE_DESCRIPTION="ubuntu" || exit 1
fi

cd ${PROJECT_DIR}/sdk-build/SampleApp/src
./SampleApp ${PROJECT_DIR}/sdk-build/Integration/AlexaClientSDKConfig.json $DEBUG_LEVEL