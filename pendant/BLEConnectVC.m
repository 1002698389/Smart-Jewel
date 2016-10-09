//
//  BLEConnectVC.m
//  ADMBL
//
//  Created by 陈双超 on 14/12/7.
//  Copyright (c) 2014年 com.aidian. All rights reserved.
//

#import "BLEConnectVC.h"

@interface BLEConnectVC (){
    
    UIBarButtonItem *AllButton;
    BOOL canSendMes;//判断是否找到了发送信息的特性
    NSUserDefaults *MyUserDefault;
    
    BOOL isConnected;
}

@end

@implementation BLEConnectVC
@synthesize peripheralOpration;
@synthesize dataArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=NSLocalizedStringFromTable(@"BLE_TITLE", @"Localizable", nil);
    
    MyUserDefault=[NSUserDefaults standardUserDefaults];
    
    AllButton=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search"] style:UIBarButtonItemStylePlain target:self action:@selector(seachAction)];
    AllButton.tintColor=[UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = AllButton;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_Left.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(BackAction)];
    self.navigationItem.leftBarButtonItem.tintColor=[UIColor whiteColor];
    
    
    dataArray=[[NSMutableArray alloc] initWithCapacity:0];
    
    self.cbCentralMgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.cbCentralMgr.delegate=self;
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(sendBLEData:) name:@"BLEDataNotification" object:nil];
    
    
}

-(void)BackAction{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)seachAction{
//    NSLog(@"搜索");
    isConnected=NO;
    for (int i=0; i<[dataArray count]; i++) {
        CBPeripheral * peripheral=[dataArray objectAtIndex:i];
        if (peripheral.state!=2) {
            [self.cbCentralMgr cancelPeripheralConnection:peripheral];
            [dataArray removeObjectAtIndex:i];
        }else{
            isConnected=YES;
        }
    }
    NSLog(@"isConnected:%d",isConnected);
    [self.cbCentralMgr stopScan];
    
    [NSThread sleepForTimeInterval:0.1];
    
    
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    [self.cbCentralMgr scanForPeripheralsWithServices:nil options:dic];
    
}


-(void)sendBLEData:(NSNotification*) notification{
    
    if (peripheralOpration.state==2)
    {
        //保留找到的特性6,实现跟定时器相关
        if ([notification object]) {
            [self sendDatawithperipheral:self.peripheralOpration characteristic:TRANSFER_CHARACTERISTIC_UUID_AABBCCDDEEFF02 data:[[notification userInfo] objectForKey:@"tempData"] showAlert:YES];
        }else{
            [self sendDatawithperipheral:self.peripheralOpration characteristic:TRANSFER_CHARACTERISTIC_UUID_AABBCCDDEEFF01 data:[[notification userInfo] objectForKey:@"tempData"] showAlert:YES];
        }
        
    }
}
//根据蓝牙对象和特性发送数据
-(BOOL)sendDatawithperipheral:(CBPeripheral *)peripheral characteristic:(NSString*)characteristicStr data:(NSData*)data showAlert:(BOOL)isShow{
//    NSLog(@"data:%@",data);
    canSendMes=NO;
    for (CBCharacteristic *characteristic in [[peripheral.services objectAtIndex:0] characteristics])
    {
        //保留找到的特性6
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:characteristicStr]])
        {
//            NSLog(@"相等");
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            canSendMes=YES;
        }
    }
    return canSendMes;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return dataArray.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row>=dataArray.count) {
        return;
    }
    if (((CBPeripheral*)[dataArray objectAtIndex:indexPath.row]).state==2) {
       
    }else{
        for (int i=0; i<[dataArray count]; i++)
        {
            CBPeripheral * peripheral = [dataArray objectAtIndex:i];
            if (peripheral.state!=0)
            {
                [self.cbCentralMgr cancelPeripheralConnection:peripheral];
            }
            if (i==indexPath.row) {
                NSLog(@"------------------");
                peripheralOpration=(CBPeripheral*)[dataArray objectAtIndex:indexPath.row];
                [self.cbCentralMgr connectPeripheral:peripheralOpration options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
                [self.bleTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"cell";
    UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    NSString *State=nil;
    if (((CBPeripheral*)[dataArray objectAtIndex:indexPath.row]).state==0) {
        State=@"disconnected";
        cell.textLabel.textColor=[UIColor blackColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else if (((CBPeripheral*)[dataArray objectAtIndex:indexPath.row]).state==1){
        State=@"Connecting";
        cell.textLabel.textColor=[UIColor blackColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        State=@"Connected";
        cell.textLabel.textColor=[UIColor blueColor];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@  %@", ((CBPeripheral*)[dataArray objectAtIndex:indexPath.row]).name ,State];
    cell.detailTextLabel.text = [((CBPeripheral*)[dataArray objectAtIndex:indexPath.row]).identifier UUIDString];
    return cell;
}
#pragma mark - Navigation
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self addLog:@"------------centralManagerDidUpdateState---------------"];
    switch (central.state) {
        case CBCentralManagerStateUnknown:
        breakcenterMgrStateCentralManagerStateResetting:
            [self addLog:@"State Resetting"];
            break;
        case CBCentralManagerStateUnsupported:
            [self addLog:@"State Unsupported"];
            break;
        case CBCentralManagerStateUnauthorized:
            [self addLog:@"State Unauthorized"];
            break;
        case CBCentralManagerStatePoweredOff:
            [self addLog:@"State PoweredOff"];
            break;
        case CBCentralManagerStatePoweredOn:
            [self addLog:@"State PoweredOn"];
            [self seachAction];
            break;
        default:
            [self addLog:@"State  未知"];
            break;
    }
    
}

-(void)addLog:(NSString*)log{
    NSLog(@"%@",log);
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
//    [self addLog:@"------------didDiscoverPeripheral---------------"];
    
    
    NSString *dataStr=[NSString stringWithFormat:@"%@",[advertisementData objectForKey:@"kCBAdvDataManufacturerData"]];
    for (CBPeripheral *temPeripheral in dataArray) {
        if (temPeripheral==peripheral) {
            return;
        }
    }
    if (isConnected) {
        return;
    }
    if ([dataStr isEqualToString:@"<21>"]||[dataStr isEqualToString:@"<20>"]) {
        [self addLog:peripheral.name];
        NSLog(@"能发现设备:%@，%@",peripheral.name,peripheral);
        NSLog(@"收到的广播数据:%@",advertisementData );
    }
    if ([dataStr isEqualToString:@"<21>"]) {
        if ([[MyUserDefault objectForKey:@"xuliehao"] isEqualToString:peripheral.name]) {
            NSLog(@"自动连接");
            for (int i=0; i<[dataArray count]; i++) {
                CBPeripheral * peripheralTemp=[dataArray objectAtIndex:i];
                if (peripheral.state!=2) {
                    [self.cbCentralMgr cancelPeripheralConnection:peripheralTemp];
                    [dataArray removeObjectAtIndex:i];
                }
            }
            peripheralOpration=peripheral;
            [self.cbCentralMgr connectPeripheral:peripheralOpration options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
            isConnected=YES;
            NSLog(@"isConnected:%d",isConnected);
        }
        peripheral.delegate=self;
        [dataArray addObject:peripheral];
        [_bleTableView reloadData];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    
    [self addLog:@"-------------didConnectPeripheral-----------------"];
    [_bleTableView reloadData];
    if (![[MyUserDefault objectForKey:@"xuliehao"] isEqualToString:peripheral.name]) {
        NSMutableArray *TempDic=[[NSMutableArray alloc]initWithObjects:@"test", nil];
        [MyUserDefault setObject:TempDic forKey:@"SettingDataKey"];
    }
    [MyUserDefault setValue:peripheral.name forKey:@"xuliehao"];
    
    isConnected=YES;
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    [peripheral readRSSI];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    isConnected=NO;
    NSLog(@"isConnected:%d",isConnected);
//    [self addLog:@"-------------didDisconnectPeripheral-----------------"];
    [self.cbCentralMgr connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    
//    [dataArray removeObject:peripheral];
    [_bleTableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeBatteryNotification" object:[NSNumber numberWithInt:0]];
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
{
    [self addLog:@"-------------didDiscoverIncludedServicesForService-----------------"];
    [self addLog:peripheral.name];
    for (CBService * server in service.includedServices) {
        NSLog(@"server:%@",server);
    }
    
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    [self addLog:@"-------------didDiscoverCharacteristicsForService-----------------"];
    
    for (CBCharacteristic * characteristic in service.characteristics) {
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"==========didUpdateValueForCharacteristic");
//    [self addLog:peripheral.name];
//    NSLog(@"characteristic:%@",characteristic);
   
//    NSString *str=[[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//    NSLog(@"特性的值：%@",str);
    if ([[characteristic.UUID UUIDString] isEqualToString:TRANSFER_CHARACTERISTIC_UUID_AABBCCDDEEFF03]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TakePhotoNotification" object:[NSNumber numberWithInt:1]];
    }else if ([[characteristic.UUID UUIDString] isEqualToString:TRANSFER_CHARACTERISTIC_UUID_Battery]) {
        NSString *str1=[NSString stringWithFormat:@"%@",characteristic.value];
        NSString *tempStr=[str1 substringWithRange:NSMakeRange(1, str1.length-2)];
        NSLog(@"电量tempStr:%@",tempStr);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeBatteryNotification" object:[NSNumber numberWithInt:[self TotexHex1:tempStr]]];
    }else{
//        NSLog(@"[characteristic.UUID UUIDString]:%@",[characteristic.UUID UUIDString]);
    }
    
}
//十六进制数转十进制数
-(int)TotexHex1:(NSString*)tmpid
{
    int int_ch;  ///两位16进制数转化后的10进制数
    unichar hex_char1 = [tmpid characterAtIndex:0]; ////两位16进制数中的第一位(高位*16)
    int int_ch1;
    if(hex_char1 >= '0' && hex_char1 <='9')
        int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
    else if(hex_char1 >= 'A' && hex_char1 <='F')
        int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
    else
        int_ch1 = (hex_char1-87)*16; //// a 的Ascll - 97
    unichar hex_char2 = [tmpid characterAtIndex:1]; ///两位16进制数中的第二位(低位)
    int int_ch2;
    if(hex_char2 >= '0' && hex_char2 <='9')
        int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
    else if(hex_char2 >= 'A' && hex_char2 <='F')
        int_ch2 = (hex_char2-55); //// A 的Ascll - 65
    else
        int_ch2 = (hex_char2-87); //// a 的Ascll - 97
    int_ch = int_ch1+int_ch2;
    
    return int_ch;
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [self addLog:@"-------------didWriteValueForCharacteristic-----------------"];
//    [self addLog:peripheral.name];
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)
    {
//        [self addLog:[NSString stringWithFormat:@"%@ ",characteristic]];//ios7时，这里的value并不是写进去的值
    }else{
//        [self addLog:[NSString stringWithFormat:@"%@ value:%@",characteristic,characteristic.value]];
    }
    NSLog(@"写数据");
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [self addLog:@"-------didUpdateNotificationStateForCharacteristic------"];
//    [self addLog:peripheral.name];
//    [self addLog:[NSString stringWithFormat:@"%@",characteristic]];
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    [self addLog:@"-------------didDiscoverServices-----------------"];
//    [self addLog:peripheral.name];
    for (CBService* service in peripheral.services){
        [peripheral discoverCharacteristics:nil forService:service];
        [peripheral discoverIncludedServices:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error{
//    NSLog(@"RSSI:%@",RSSI);
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:RSSI,@"RSSI",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateRSSINotification" object:nil userInfo:dic];
}
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"%@",peripheral.RSSI);
}

-(void)readRSSI{
    
    for (int i=0; i<dataArray.count; i++) {
        CBPeripheral * peripheral=[dataArray objectAtIndex:i];
//        NSLog(@"readRSSI");
        [peripheral readRSSI];
    }
}
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral{
    NSLog(@"peripheralDidUpdateName");
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"didDiscoverDescriptorsForCharacteristic");
    NSLog(@"%@",characteristic);
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    NSLog(@"didUpdateValueForDescriptor");
    NSLog(@"%@",descriptor);
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    NSLog(@"didWriteValueForDescriptor");
    NSLog(@"%@",descriptor);
}
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices{
    NSLog(@"didModifyServices");
}
@end
