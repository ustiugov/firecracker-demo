
COUNT="${1:-4000}" # Default to 4000

RES=scripts

rm -rf output
mkdir output
chown -R $USER:$USER output

pushd $RES > /dev/null

source ./one-time-setup.sh
source ./setup-network-taps.sh 0 $COUNT 100

popd > /dev/null
