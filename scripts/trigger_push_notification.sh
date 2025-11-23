
echo "Trigger a push notification"

# To test it change the device id and the json file path with you ios device simulator
# run: xcrun simctl list - to list all devices on your terminal
xcrun simctl push '00008130-000059882421401C' ao.riskplace.makanetu scripts/push_notification_test.json

