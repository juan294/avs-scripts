#!/usr/bin/env sh
# --- I'M FEELING LUCKY ---
HOME="/home/ubuntu"
PROJECT_DIR=${HOME}"/Prototypes/ass-sdk"
APL_CORE_BRANCH="v1.2"
DEBUG_LEVEL="INFO"

cd ${PROJECT_DIR}
git clone --single-branch --branch $APL_CORE_BRANCH git://github.com/alexa/apl-core-library.git
git clone git://github.com/alexa/alexa-smart-screen-sdk.git

cd ${PROJECT_DIR}/apl-core-library
mkdir build
cd build
cmake ..
make -j4

curl -sL https://deb.nodesource.com/setup_13.x | sudo -E bash -
sudo apt-get install -y nodejs

cd ${PROJECT_DIR}/third-party
wget https://github.com/zaphoyd/websocketpp/archive/0.8.1.tar.gz -O websocketpp-0.8.1.tar.gz
tar -xvzf websocketpp-0.8.1.tar.gz

sudo apt-get -y install libasio-dev

cd ${PROJECT_DIR}
mkdir ss-build
cd ss-build

cmake -DCMAKE_PREFIX_PATH=${PROJECT_DIR}/sdk-install \
-DWEBSOCKETPP_INCLUDE_DIR=${PROJECT_DIR}/third-party/websocketpp-0.8.1 \
-DDISABLE_WEBSOCKET_SSL=ON \
-DGSTREAMER_MEDIA_PLAYER=ON \
-DCMAKE_BUILD_TYPE=DEBUG \
-DPORTAUDIO=ON -DPORTAUDIO_LIB_PATH=${PROJECT_DIR}/third-party/portaudio/lib/.libs/libportaudio.a \
-DPORTAUDIO_INCLUDE_DIR=${PROJECT_DIR}/third-party/portaudio/include/ \
-DAPL_CORE=ON \
-DAPLCORE_INCLUDE_DIR=${PROJECT_DIR}/apl-core-library/aplcore/include \
-DAPLCORE_LIB_DIR=${PROJECT_DIR}/apl-core-library/build/aplcore \
-DYOGA_INCLUDE_DIR=${PROJECT_DIR}/apl-core-library/build/yoga-prefix/src/yoga \
-DYOGA_LIB_DIR=${PROJECT_DIR}/apl-core-library/build/lib \
../alexa-smart-screen-sdk

make -j4

cd ${PROJECT_DIR}/ss-build
./modules/Alexa/SampleApp/src/SampleApp -C ${PROJECT_DIR}/sdk-build/Integration/AlexaClientSDKConfig.json -C ${PROJECT_DIR}/alexa-smart-screen-sdk/modules/GUI/config/guiConfigSamples/GuiConfigSample_SmartScreenLargeLandscape.json -L $DEBUG_LEVEL