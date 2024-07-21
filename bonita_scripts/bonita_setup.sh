#!/bin/sh

set -euxo pipefail

BONITA_DIR="/opt/bonita"

# Use setup tool to configure Bonita Tomcat bundle

cd ${BONITA_DIR}/setup
./setup.sh pull

# configure logging
cp /opt/custom-init.d/log4j2-appenders.xml ${BONITA_DIR}/conf/logs/log4j2-appenders.xml

# configure cluster
if [[ "${CLUSTER_MODE}" == "true" ]]; then
sed -e 's/{{KUBERNETES_NAME}}/'"${KUBERNETES_NAME}"'/g' \
    -e 's/{{KUBERNETES_NAMESPACE}}/'"${KUBERNETES_NAMESPACE}"'/g' \
    /opt/custom-init.d/bonita-platform-sp-cluster-custom.properties \
    > ${BONITA_DIR}/setup/platform_conf/current/platform_engine/bonita-platform-sp-cluster-custom.properties
fi

cd ${BONITA_DIR}/setup
./setup.sh configure
./setup.sh push