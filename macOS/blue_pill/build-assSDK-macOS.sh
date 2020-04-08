#!/usr/bin/env sh
# --- I'M FEELING LUCKY ---
HOME="PATH_TO_HOME_FOLDER"
PROJECT_DIR=${HOME}"PATH_TO_PROJECT_FOLDER"
CPU_CORES="N_CORES_AVAILABLE"
APL_CORE_BRANCH="THE_LIB_BRANCH"
DEBUG_LEVEL="SAMPLE_APP_DEBUG_LEVEL"

cd ${PROJECT_DIR}
git clone --single-branch --branch $APL_CORE_BRANCH git://github.com/alexa/apl-core-library.git || exit 1

git clone git://github.com/alexa/alexa-smart-screen-sdk.git || exit 1

cd ${PROJECT_DIR}/apl-core-library
mkdir build
cd build
cmake .. || exit 1

make $CPU_CORES || exit 1

brew install node

cd ${PROJECT_DIR}/third-party
wget https://github.com/zaphoyd/websocketpp/archive/0.8.1.tar.gz -O websocketpp-0.8.1.tar.gz || exit 1
tar -xvzf websocketpp-0.8.1.tar.gz

brew install asio

cd ${PROJECT_DIR}
mkdir ss-build
cd ss-build

opensslFolder=$(brew info openssl | grep /usr/local/Cellar | cut -d '(' -f1 | tr -d '[:space:]')
echo export PKG_CONFIG_PATH="/usr/local/opt/curl-openssl/lib/pkgconfig:$opensslFolder/lib/pkgconfig:$PKG_CONFIG_PATH" >> ~/.bash_profile
source $HOME/.bash_profile

time cmake -DCMAKE_PREFIX_PATH=${PROJECT_DIR}/sdk-install \
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
../alexa-smart-screen-sdk || exit 1

make $CPU_CORES  || exit 1

cd ${PROJECT_DIR}/ss-build
./modules/Alexa/SampleApp/src/SampleApp \
-C ${PROJECT_DIR}/sdk-build/Integration/AlexaClientSDKConfig.json \
-C ${PROJECT_DIR}/alexa-smart-screen-sdk/modules/GUI/config/guiConfigSamples/GuiConfigSample_SmartScreenLargeLandscape.json \
-L $DEBUG_LEVEL