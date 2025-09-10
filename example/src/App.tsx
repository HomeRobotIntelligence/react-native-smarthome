import React, { useEffect } from 'react';
import { StyleSheet, View, Button, NativeEventEmitter, NativeModules, Text, Alert } from 'react-native';
import HomeKit, { AccessoryStateChangeEvent } from 'react-native-smarthome';

export default function App() {
  const myModuleEvt = new NativeEventEmitter(NativeModules.Homekit)
  
  useEffect(() => {
    // 监听新设备发现事件
    const findNewAccessoryListener = myModuleEvt.addListener("findNewAccessory", (accessory) => {
      console.log('发现新设备:', accessory);
      Alert.alert('发现新设备', `设备名称: ${accessory.accessory.name}`);
    });

    // 监听设备移除事件
    const removeNewAccessoryListener = myModuleEvt.addListener("removeNewAccessory", (accessory) => {
      console.log('设备被移除:', accessory);
      Alert.alert('设备被移除', `设备名称: ${accessory.accessory.name}`);
    });

    // 监听设备状态变化事件
    const accessoryStateChangeListener = myModuleEvt.addListener("accessoryStateChanged", (event: AccessoryStateChangeEvent) => {
      console.log('设备状态变化:', event);
      
      if (event.changeType === 'characteristicValueUpdated' && event.characteristic) {
        Alert.alert('设备特性值变化', `设备: ${event.accessory.name}\n特性: ${event.characteristic.description}\n新值: ${event.characteristic.value}`);
      } else if (event.changeType) {
        Alert.alert('设备状态变化', `设备: ${event.accessory.name}\n变化类型: ${event.changeType}`);
      }
    });

    // 清理监听器
    return () => {
      findNewAccessoryListener.remove();
      removeNewAccessoryListener.remove();
      accessoryStateChangeListener.remove();
    };
  }, []);
  const addHome = () => {
    HomeKit.addHome("Nazir's Home").then((result) => {
      console.log(result)
    });
  }
  const startSearchingForNewAccessories = () => {
    HomeKit.startSearchingForNewAccessories()
  }
  
  const startMonitoringDevice = () => {
    // 这里需要替换为实际的设备名称和家庭名称
    HomeKit.startMonitoringAccessoryState("设备名称", "家庭名称").then((result) => {
      console.log('开始监控设备状态:', result);
      Alert.alert('成功', '已开始监控设备状态变化');
    }).catch((error) => {
      console.error('监控设备状态失败:', error);
      Alert.alert('错误', '监控设备状态失败: ' + error.message);
    });
  }
  const removeHome = () => {
    HomeKit.removeHome("Nazir's Home").then((result) => {
      console.log(result)
    });
  }
  const renameHome = () => {
    HomeKit.renameHome("Berkay's Home", "Nazir's Home").then((result) => {
      console.log(result)
    });
  }
  return (
    <View style={styles.container}>
      <Text style={styles.title}>HomeKit 智能家居控制</Text>
      
      <Button
        onPress={addHome}
        title="添加家庭"
        color="blue"
      />
      <Button
        onPress={removeHome}
        title="删除家庭"
        color="#841584"
      />
      <Button
        onPress={renameHome}
        title="重命名家庭"
        color="green"
      />
      <Button
        onPress={startSearchingForNewAccessories}
        title="搜索新设备"
        color="orange"
      />
      <Button
        onPress={startMonitoringDevice}
        title="开始监控设备状态"
        color="purple"
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 20,
    textAlign: 'center',
  },
});
