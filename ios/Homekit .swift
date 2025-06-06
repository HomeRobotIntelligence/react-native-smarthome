import  HomeKit

@objc(Homekit)
class Homekit: RCTEventEmitter , HMHomeManagerDelegate, HMAccessoryBrowserDelegate {
    var homeManager = HMHomeManager()
    let accessoryBrowser = HMAccessoryBrowser()
    var discoveredAccessories: [HMAccessory] = []
    override init() {
        self.homeManager = HMHomeManager()
        super.init()
        self.accessoryBrowser.delegate = self
        self.homeManager.delegate = self
    }
    
    @objc  override static func requiresMainQueueSetup() -> Bool {
        return true
    }
    override func supportedEvents() -> [String]! {
      return ["findNewAccessory","removeNewAccessory"]
    }
    @objc(addHome:withResolver:withRejecter:)
    func addHome(name: String, resolve: @escaping(RCTPromiseResolveBlock), reject: @escaping(RCTPromiseRejectBlock)) -> Void {
        homeManager.addHome(withName: name) { newHome, error in
            if error != nil {
                reject("error", error?.localizedDescription, error);
            } else {
                resolve(Homekit.transformHome(home: newHome!))
            }
        }
    }
    
    @objc(removeHome:withResolver:withRejecter:)
    func removeHome(name: String, resolve: @escaping(RCTPromiseResolveBlock), reject: @escaping(RCTPromiseRejectBlock)) -> Void {
        guard let home = self.findHome(name: name) else {
            reject("error","Home cannot found", nil);
            return
        }
        homeManager.removeHome(home) { error in
            if let error = error {
                reject("error", error.localizedDescription, error);
            } else {
                resolve(Homekit.transformHome(home: home))
            }
        }
    }
    @objc(renameHome:oldName:withResolver:withRejecter:)
    func renameHome(newName: String, oldName: String, resolve: @escaping(RCTPromiseResolveBlock), reject: @escaping(RCTPromiseRejectBlock)) -> Void {
        guard let home = self.findHome(name: oldName) else {
            reject("error","Home cannot found", nil);
            return
        }
        home.updateName(newName) { (error) in
            if let error = error {
                reject("error", error.localizedDescription, error);
            } else {
                resolve(Homekit.transformHome(home: home))
            }
        }
    }
    
    @objc(addZone:toHome:withResolver:withRejecter:)
    func addZone(name: String, toHome:String, resolve: @escaping(RCTPromiseResolveBlock), reject: @escaping(RCTPromiseRejectBlock)) -> Void {
        guard let home = self.findHome(name: toHome) else {
            reject("error","Home cannot found", nil);
            return
        }
        home.addZone(withName: name) { zone, error in
            if zone != nil {
                resolve(name)
            }
            if let error = error {
                reject("error",error.localizedDescription, nil);
            }
        }
    }
    @objc(removeZone:fromHome:withResolver:withRejecter:)
    func removeZone(name: String, fromHome:String, resolve: @escaping(RCTPromiseResolveBlock), reject: @escaping(RCTPromiseRejectBlock)) -> Void {
        guard let home = self.findHome(name: fromHome) else {
            reject("error","Home cannot found", nil);
            return
        }
        guard let zone = self.findZone(name: name, home: home) else {
            reject("error","Home cannot found", nil);
            return
        }
        home.removeZone(zone) { (error) in
            if let error = error {
                reject("error", error.localizedDescription, error);
            } else {
                resolve(name)
            }
        }
    }
    @objc(renameZone:oldName:inHome:withResolver:withRejecter:)
    func renameZone(name: String, oldName:String, inHome:String, resolve: @escaping(RCTPromiseResolveBlock), reject: @escaping(RCTPromiseRejectBlock)) -> Void {
        guard let home = self.findHome(name: oldName) else {
            reject("error","Home cannot found", nil);
            return
        }
        guard let zone = self.findZone(name: oldName, home: home) else {
            reject("error","Zone cannot found", nil);
            return
        }
        zone.updateName(name) { (error) in
            if let error = error {
                reject("error", error.localizedDescription, error);
            } else {
                resolve(name)
            }
        }
    }
    @objc(addAccessoryToHome:toHome:withResolver:withRejecter:)
    func addAccessoryToHome(accessoryName: String, toHome: String ,resolve: @escaping(RCTPromiseResolveBlock), reject: @escaping(RCTPromiseRejectBlock)) -> Void{
        guard let home = self.findHome(name: toHome) else {
            reject("error","Home cannot found", nil);
            return
        }
        guard let accessory = self.findAccessory(name: accessoryName) else {
            reject("error","Home cannot found", nil);
            return
        }
        home.addAccessory(accessory) { (error) in
            if let error = error {
                reject("error", error.localizedDescription, error);
            } else {
                resolve(accessory)
            }
        }
        
    }
    
    @objc(removeAccessoryFromHome:fromHome:withResolver:withRejecter:)
    func removeAccessoryFromHome(accessoryName: String, fromHome: String ,resolve: @escaping(RCTPromiseResolveBlock), reject: @escaping(RCTPromiseRejectBlock)) -> Void{
        guard let home = self.findHome(name: fromHome) else {
            reject("error","Home cannot found", nil);
            return
        }
        guard let accessory = self.findAccessoryInHome(name: accessoryName, inHome: home) else {
            reject("error","Home cannot found", nil);
            return
        }
        home.removeAccessory(accessory) { (error) in
            if let error = error {
                reject("error", error.localizedDescription, error);
            } else {
                resolve(accessory)
            }
        }
    }
    
    @objc(assignAccessoryToRoom:roomName:homeName:withResolver:withRejecter:)
    func assignAccessoryToRoom(accessoryName: String, roomName: String , homeName: String , resolve: @escaping(RCTPromiseResolveBlock), reject: @escaping(RCTPromiseRejectBlock)) -> Void{
        guard let home = self.findHome(name: homeName) else {
            reject("error","Home cannot found", nil);
            return
        }
        guard let accessory = self.findAccessoryInHome(name: accessoryName, inHome: home) else {
            reject("error","Home cannot found", nil);
            return
        }
        guard let room = self.findRoom(name: accessoryName, inHome: home) else {
            reject("error","Home cannot found", nil);
            return
        }
        home.assignAccessory(accessory , to: room) { (error) in
            if let error = error {
                reject("error", error.localizedDescription, error);
            } else {
                resolve(accessory)
            }
        }
    }
    
    @objc(renameAccessory:newName:withResolver:withRejecter:)
    func renameAccessory(oldName: String, newName: String ,resolve: @escaping(RCTPromiseResolveBlock), reject: @escaping(RCTPromiseRejectBlock)) -> Void{
        guard let accessory = self.findAccessory(name: oldName) else {
            reject("error","Home cannot found", nil);
            return
        }
        accessory.updateName(newName) { (error) in
            if let error = error {
                reject("error", error.localizedDescription, error);
            } else {
                resolve(accessory)
            }
        }
    }
    @objc(startSearchingForNewAccessories)
    func startSearchingForNewAccessories () -> Void {
        self.accessoryBrowser.startSearchingForNewAccessories()
    }
    @objc(stopSearchingForNewAccessories)
    func stopSearchingForNewAccessories () -> Void {
        self.accessoryBrowser.stopSearchingForNewAccessories()
    }
    @objc(getPrimaryHome:withRejecter:)
    func getPrimaryHome(resolve: @escaping(RCTPromiseResolveBlock), reject: @escaping(RCTPromiseRejectBlock)) -> Void {
        guard let primaryHome = self.findPrimaryHome() else {
            reject("error", "Primary home not found", nil);
            return
        }
        resolve(Homekit.transformHome(home: primaryHome))
    }
    
  @objc(updateAccessoryPowerState:inHome:isOn:withResolver:withRejecter:)
      func updateAccessoryPowerState(accessoryName: String, inHome: String, isOn: Bool, resolve: @escaping(RCTPromiseResolveBlock), reject: @escaping(RCTPromiseRejectBlock)) -> Void {
          guard let home = self.findHome(name: inHome) else {
              reject("error", "Home '\(inHome)' not found", nil);
              return
          }
          
          guard let accessory = self.findAccessoryInHome(name: accessoryName, inHome: home) else {
              reject("error", "Accessory  '\(accessoryName)' not found", nil);
              return
          }
          
          // 遍历所有服务查找电源特性
          var foundPowerService = false
          for service in accessory.services {
              if let powerCharacteristic = service.characteristics.first(where: { $0.characteristicType == HMCharacteristicTypePowerState }) {
                  foundPowerService = true
                  // 更新电源状态
                  powerCharacteristic.writeValue(isOn) { error in
                      if let error = error {
                          reject("error", error.localizedDescription, error);
                      } else {
                          resolve(Homekit.transformAccessory(acc: accessory))
                      }
                  }
                  return
              }
          }
          
          if !foundPowerService {
              reject("error", "Power characteristic not found in any service", nil);
          }
      }
    
    
    //Helper functions
    private func findHome(name: String) -> HMHome? {
        for home in homeManager.homes {
            if home.name == name {
                return home
            }
        }
        return nil
    }

    
    private func findPrimaryHome() -> HMHome? {
        for home in homeManager.homes {
            if home.isPrimary {
                return home
            }
        }
        return nil
    }

    private func findRoom(name: String, inHome: HMHome) -> HMRoom? {
        for room in inHome.rooms {
            if room.name == name {
                return room
            }
        }
        return nil
    }
    
    private func findAccessory(name: String) -> HMAccessory? {
        for accessory in accessoryBrowser.discoveredAccessories {
            if accessory.name == name {
                return accessory
            }
        }
        return nil
    }
    
    private func findAccessoryInHome(name: String, inHome: HMHome) ->  HMAccessory? {
        for accessory in inHome.accessories {
            if accessory.name == name {
                return accessory
            }
        }
        return nil
    }
    
    private func findZone(name: String, home:HMHome) -> HMZone? {
        for zone in home.zones {
            if zone.name == name {
                return zone
            }
        }
        return nil
    }
    private  static func transformHome(home: HMHome) -> [String : Any?] {
        return [
            "name" : home.name,
            "isPrimary": home.isPrimary,
            "rooms": Homekit.transformRooms(nrooms: home.rooms),
            "accessories": transformAccessories(naccessories: home.accessories),
            "zones": transformZones(nzones: home.zones),
        ];
    }
    
    private static func transformRooms(nrooms: [HMRoom]) -> [Any] {
        var rooms: [Any] = []
        for room in nrooms {
            rooms.append(transformRoom(room: room, skipAccessories:false))
        }
        return rooms;
    }
    
    
    private static func transformRoom(room: HMRoom, skipAccessories: Bool?) ->  [String : Any?] {
        return  [
            "name" : room.name,
            "accessories": skipAccessories! ? nil : transformAccessories(naccessories: room.accessories)
        ];
    }
    
    private static func transformAccessories(naccessories: [HMAccessory]) -> [Any] {
        var accessories: [Any] = []
        for accessory in naccessories {
            accessories.append(transformAccessory(acc: accessory))
        }
        return accessories;
    }
    
    private static func transformAccessory(acc: HMAccessory) ->  [String : Any?] {
        return [
            "name": acc.name,
            "bridged": acc.isBridged,
            "uniqueIdentifier": acc.uniqueIdentifier,
            "category": acc.category.localizedDescription,
            "services": transformServices(nservices: acc.services),
        ]
    }
    
    private static func transformZones(nzones: [HMZone]) -> [Any] {
        var zones: [Any] = []
        for zone in nzones {
            zones.append(transformZone(zone: zone))
        }
        return zones;
    }
    private static func transformZone(zone: HMZone) -> [String : Any] {
        return [
            "name": zone.name,
            "rooms": transformRooms(nrooms: zone.rooms),
        ]
    }
    
    private static func transformServices(nservices: [HMService]) -> [Any] {
        var services: [Any] = []
        for service in nservices {
            services.append(transformService(service: service))
        }
        return services;
    }
    private static func transformService(service: HMService) -> [String : Any] {
        return [
            "name": service.name,
            "serviceType":service.serviceType,
            "localizedDescription": service.localizedDescription,
            "isUserInteractive": service.isUserInteractive,
            "characteristics": transformCharacteristics(ncharacteristics: service.characteristics)
        ]
    }
    
    private static func transformCharacteristics(ncharacteristics: [HMCharacteristic]) -> [Any] {
        var characteristics: [Any] = []
        for characteristic in ncharacteristics {
            characteristics.append(transformCharacteristic(characteristic:characteristic))
        }
        return characteristics;
    }
    private static func transformCharacteristic(characteristic: HMCharacteristic) -> [String : Any] {
        return [
            "uniqueIdentifier": characteristic.uniqueIdentifier,
            "type": characteristic.characteristicType,
            "description": characteristic.localizedDescription,
            "isNotificationEnabled": characteristic.isNotificationEnabled,
            "value": characteristic.value as Any,
            "properties": characteristic.properties,
        ]
    }
    
    // Delegate
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
        self.sendEvent(withName: "findNewAccessory", body:["accessory": Homekit.transformAccessory(acc: accessory)])
    
    }
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didRemoveNewAccessory accessory: HMAccessory) {
         self.sendEvent(withName: "removeNewAccessory", body: ["accessory": Homekit.transformAccessory(acc: accessory)] )
    }
}
