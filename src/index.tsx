import { NativeModules } from 'react-native';


export interface Characteristic {
  uniqueIdentifier: string,
  type: string,
  description: string,
  isNotificationEnabled: boolean,
  value: any,
  properties: [string],
}

export interface Service {
  name: string;
  serviceType: string;
  localizedDescription: string;
  isUserInteractive: boolean;
  characteristics: Array<Characteristic>;
}

export interface Accessory {
  name: string;
  bridged: boolean;
  uniqueIdentifier: string;
  category: string;
  services: Array<Service>;
  isReady: boolean;
}

export interface Zone {
  name: string;
  rooms: Array<Room>;
}

export interface Room {
  name: string;
  accessories: Array<Accessory>;
}

export interface Home {
  name: string;
  isPrimary: boolean;
  rooms: Array<Room>;
  accessories: Array<Accessory>;
  zones: Array<Zone>;
}

export interface AccessoryStateChangeEvent {
  accessory: Accessory;
  service?: Service;
  characteristic?: Characteristic;
  changeType?: 'characteristicValueUpdated' | 'serviceNameUpdated' | 'serviceTypeUpdated' | 'reachabilityUpdated' | 'characteristicNameUpdated';
}
type HomekitType = {
  addHome(homeName: string): Promise<Home>;
  removeHome(homeName: string): Promise<Home>;
  renameHome(newName: string, oldName: string): Promise<Home>;

  addZone(zoneName: string, toHome: string): Promise<Zone>;
  removeZone(zoneName: string, fromHome: string): Promise<Zone>;
  renameZone(newName: string, oldName: string, inHome: string): Promise<Zone>;

  addRoomToHome(name: string, toHome: string): Promise<Room>;
  addRoomToZone(name: string, toZone: string, inHome: string): Promise<Zone>;
  removeRoomFromZone(name: string, fromZone: string, inHome: string): Promise<Zone>;
  removeRoomFromHome(name: string, fromHome: string): Promise<Room>;
  renameRoom(oldName: string, newName: string, inHome: string): Promise<Room>;

  addAccessoryToHome(accessoryName: string, toHome: string): Promise<Home>;
  removeAccessoryFromHome(accessoryName: string, fromHome: string): Promise<Home>;
  assignAccessoryToRoom(accessoryName: string, roomName: string, homeName: string): Promise<Array<Room>>;
  renameAccessory(oldName: string, newName: string): Promise<Accessory>;
  startSearchingForNewAccessories():void;
  stopSearchingForNewAccessories():void;
  getPrimaryHome(): Promise<Home>;
  updateAccessoryPowerState(accessoryName: string, inHome: string, isOn: boolean): Promise<Accessory>;
  startMonitoringAccessoryState(accessoryName: string, inHome: string): Promise<{message: string}>;
};

const { Homekit } = NativeModules;

export default Homekit as HomekitType;
