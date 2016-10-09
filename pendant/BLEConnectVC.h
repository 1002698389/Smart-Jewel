//
//  BLEConnectVC.h
//  ADMBL
//
//  Created by 陈双超 on 14/12/7.
//  Copyright (c) 2014年 com.aidian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreBluetooth/CoreBluetooth.h"

#define TRANSFER_CHARACTERISTIC_UUID_Battery    @"2A19"
#define TRANSFER_CHARACTERISTIC_UUID_AABBCCDDEEFF01    @"33221101-5544-7766-9988-AABBCCDDEEFF"
#define TRANSFER_CHARACTERISTIC_UUID_AABBCCDDEEFF02    @"33221102-5544-7766-9988-AABBCCDDEEFF"
#define TRANSFER_CHARACTERISTIC_UUID_AABBCCDDEEFF03    @"33221103-5544-7766-9988-AABBCCDDEEFF"

@interface BLEConnectVC : UIViewController<CBCentralManagerDelegate,CBPeripheralDelegate>

//CBCentralManager对象负责管理外设的发现或连接，包括扫描、发现、连接正在广播的外设。
@property (strong,nonatomic) CBCentralManager *cbCentralMgr;
@property (strong,nonatomic) CBPeripheral *peripheralOpration;//一个灯时操作的蓝牙对象

@property (weak, nonatomic) IBOutlet UITableView *bleTableView;
@property (strong,nonatomic)NSMutableArray *dataArray;


-(void)readRSSI;
@end
