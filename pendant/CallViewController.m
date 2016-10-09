//
//  CallViewController.m
//  pendant
//
//  Created by 陈双超 on 15/3/17.
//  Copyright (c) 2015年 陈双超. All rights reserved.
//

#import "CallViewController.h"

#define POWER2(x) (1<<(x))

@interface CallViewController (){
    NSUserDefaults *MyUserDefault;
    NSMutableArray *MySettingData;
    NSDictionary *MyLastDataDic;
}

@end

@implementation CallViewController
@synthesize SettingType;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"SettingType:%@",SettingType);
    UILabel *rightBarView=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    rightBarView.numberOfLines=0;
    rightBarView.textAlignment=NSTextAlignmentRight;
    rightBarView.textColor=[UIColor whiteColor];
    
    switch ([SettingType integerValue]) {
        case 0:
            rightBarView.text=NSLocalizedStringFromTable(@"List_TITLE1", @"Localizable", nil);
            break;
        case 1:
            rightBarView.text=NSLocalizedStringFromTable(@"List_TITLE2", @"Localizable", nil);
            break;
        case 2:
            rightBarView.text=NSLocalizedStringFromTable(@"List_TITLE3", @"Localizable", nil);
            break;
        default:
            break;
    }
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:rightBarView];
    
    
    UIImageView *leftBarView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 10)];
    leftBarView.image=[UIImage imageNamed:@"uny_title"];
    self.navigationItem.titleView=leftBarView;
    self.navigationItem.titleView.frame=CGRectMake(10, 20, 80, 10);
    
    NSLog(@"OK-----");
    
    MyUserDefault=[NSUserDefaults standardUserDefaults];
    NSLog(@"%@",[MyUserDefault objectForKey:@"SettingDataKey"]);
    MySettingData=[[NSMutableArray alloc]initWithArray:[MyUserDefault objectForKey:@"SettingDataKey"]];
    
    if ([MySettingData count]<3) {
        [MySettingData removeAllObjects];
        NSLog(@"没数据，初始化");
        for (int i=0; i<3; i++) {
            NSMutableDictionary *TempDic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"VibSwitch", [NSNumber numberWithInteger:2],@"VibFre",[NSNumber numberWithBool:YES],@"LEDSwitch",[NSNumber numberWithInteger:2],@"LEDFre",[NSNumber numberWithInteger:2],@"LEDColor",[NSNumber numberWithBool:YES],@"SoundSwitch",[NSNumber numberWithInteger:11],@"SoundVolume",nil];
            [MySettingData addObject:TempDic];
        }
    }else{
        NSLog(@"有数据");
        [self setViewAction];
    }
    NSLog(@"OK");
    MyLastDataDic=[NSDictionary dictionaryWithDictionary:[MySettingData objectAtIndex:[SettingType integerValue]]];
//    NSLog(@"源数据：%@",MyLastDataDic);
    
    
    
    
    _VibNotifyLabel.numberOfLines=0;
    _VibFreLabel.numberOfLines=0;
    _FlashNotifyLabel.numberOfLines=0;
    _FlashFreLabel.numberOfLines=0;
    _FlashColorLabel.numberOfLines=0;
    _SoundLabel.numberOfLines=0;
    _SoundVolumeLabel.numberOfLines=0;
}




-(void)setViewAction{
    NSMutableDictionary *TempDic=[[NSMutableDictionary alloc]initWithDictionary:[MySettingData objectAtIndex:[SettingType integerValue]]];
    _VibSwitch.on=[[TempDic objectForKey:@"VibSwitch"] boolValue];
    _VibSlider.value=[[TempDic objectForKey:@"VibFre"] integerValue];
    _LEDSwitch.on=[[TempDic objectForKey:@"LEDSwitch"] boolValue];
    _LEDFRESlider.value=[[TempDic objectForKey:@"LEDFre"] integerValue];
    _LEDColorSliser.value=[[TempDic objectForKey:@"LEDColor"] integerValue];
    switch ([[TempDic objectForKey:@"LEDColor"] integerValue]) {
        case 0:
            _LEDColorView.backgroundColor=[UIColor blueColor];
            break;
        case 1:
            _LEDColorView.backgroundColor=[UIColor redColor];
            break;
        case 2:
            _LEDColorView.backgroundColor=[UIColor greenColor];
            break;
        case 3:
            _LEDColorView.backgroundColor=[UIColor yellowColor];
            break;
        case 4:
            _LEDColorView.backgroundColor=[UIColor whiteColor];
            break;
        default:
            break;
    }
    _SoundSwitch.on=[[TempDic objectForKey:@"SoundSwitch"] boolValue];
    _SoundSlider.value=[[TempDic objectForKey:@"SoundVolume"] integerValue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)VibrSwitchAction:(UISwitch*)sender {
    NSLog(@"VibSwitch:%d",sender.on);
    NSMutableDictionary *TempDic=[[NSMutableDictionary alloc]initWithDictionary:[MySettingData objectAtIndex:[SettingType integerValue]]];
    [TempDic setObject:[NSNumber numberWithBool:sender.on] forKey:@"VibSwitch"];
    [MySettingData replaceObjectAtIndex:[SettingType integerValue] withObject:TempDic];
    [MyUserDefault setObject:MySettingData forKey:@"SettingDataKey"];
//    NSLog(@"MySettingData:%@",MySettingData);
    
    
//    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedStringFromTable(@"VIBSWITCHALERT", @"Localizable", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    char strcommand[9]={0,0,0,0,0,0,0,0,0};
    if([SettingType integerValue]==1){
        strcommand[0] =3|(1<<4);//是把信息改成社交软件提醒
    }else{
        strcommand[0] =[SettingType integerValue]|(1<<4);
    }
    
    strcommand[2] =1;
    if (sender.on) {
        strcommand[3] =1;
        NSInteger Number=[[TempDic objectForKey:@"VibFre"] integerValue]+1;
        strcommand[4] =20*Number;
        strcommand[5] =20*Number;
        strcommand[6] =2*Number;
        strcommand[7] =40*Number;
        strcommand[8] =1*Number;
//        alertView.message=NSLocalizedStringFromTable(@"VIBSWITCHALERTOPEN", @"Localizable", nil);
    }
    NSData *cmdData = [NSData dataWithBytes:strcommand length:9];
    NSLog(@"cmdData:%@",cmdData);
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLEDataNotification" object:nil userInfo:dic];
//    [alertView show];
}

- (IBAction)VibrSliderAction:(UISlider*)sender {
    NSLog(@"sender:%f",sender.value);
    NSMutableDictionary *TempDic=[[NSMutableDictionary alloc]initWithDictionary:[MySettingData objectAtIndex:[SettingType integerValue]]];
    [TempDic setObject:[NSNumber numberWithInteger:sender.value] forKey:@"VibFre"];
    [MySettingData replaceObjectAtIndex:[SettingType integerValue] withObject:TempDic];
    [MyUserDefault setObject:MySettingData forKey:@"SettingDataKey"];
    NSLog(@"MySettingData:%@",MySettingData);
    
    if ([[TempDic objectForKey:@"VibSwitch"] boolValue]) {
        char strcommand[9]={0,0,0,0,0,0,0,0,0};
        if([SettingType integerValue]==1){
            strcommand[0] =3|(1<<4);
        }else{
            strcommand[0] =[SettingType integerValue]|(1<<4);
        }
        strcommand[2] =1;
        
        strcommand[3] =1;
        NSInteger Number=[[TempDic objectForKey:@"VibFre"] integerValue]+1;
        strcommand[4] =20*Number;
        strcommand[5] =20*Number;
        strcommand[6] =2*Number;
        strcommand[7] =40*Number;
        strcommand[8] =1*Number;
        
        NSData *cmdData = [NSData dataWithBytes:strcommand length:9];
        NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BLEDataNotification" object:nil userInfo:dic];
    }
}

- (IBAction)LEDFSwitchAction:(UISwitch*)sender {
    NSMutableDictionary *TempDic=[[NSMutableDictionary alloc]initWithDictionary:[MySettingData objectAtIndex:[SettingType integerValue]]];
    [TempDic setObject:[NSNumber numberWithBool:sender.on] forKey:@"LEDSwitch"];
    [MySettingData replaceObjectAtIndex:[SettingType integerValue] withObject:TempDic];
    [MyUserDefault setObject:MySettingData forKey:@"SettingDataKey"];
    
//    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedStringFromTable(@"FLASHALERT", @"Localizable", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    char strcommand[9]={0,0,0,0,0,0,0,0,0};
    if([SettingType integerValue]==1){
        strcommand[0] =3|(1<<4);
    }else{
        strcommand[0] =[SettingType integerValue]|(1<<4);
    }
    strcommand[2] =0;
    if (sender.on) {
        NSInteger ColorNumber=[[TempDic objectForKey:@"LEDColor"] integerValue];
        strcommand[3] =POWER2(ColorNumber);
        NSInteger Number=[[TempDic objectForKey:@"LEDFre"] integerValue]+1;
        strcommand[4] =20*Number;
        strcommand[5] =20*Number;
        strcommand[6] =2*Number;
        strcommand[7] =40*Number;
        strcommand[8] =1*Number;
//        alertView.message=NSLocalizedStringFromTable(@"FLASHALERTOPEN", @"Localizable", nil);
    }
    NSData *cmdData = [NSData dataWithBytes:strcommand length:9];
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLEDataNotification" object:nil userInfo:dic];
//    [alertView show];
}

- (IBAction)LEDFSliderAction:(UISlider*)sender {
    NSMutableDictionary *TempDic=[[NSMutableDictionary alloc]initWithDictionary:[MySettingData objectAtIndex:[SettingType integerValue]]];
    [TempDic setObject:[NSNumber numberWithInteger:sender.value] forKey:@"LEDFre"];
    [MySettingData replaceObjectAtIndex:[SettingType integerValue] withObject:TempDic];
    [MyUserDefault setObject:MySettingData forKey:@"SettingDataKey"];
    NSLog(@"MySettingData:%@",MySettingData);
    
    if ([[TempDic objectForKey:@"LEDSwitch"] boolValue]) {
        char strcommand[9]={0,0,0,0,0,0,0,0,0};
        if([SettingType integerValue]==1){
            strcommand[0] =3|(1<<4);
        }else{
            strcommand[0] =[SettingType integerValue]|(1<<4);
        }
        strcommand[2] =0;
        NSInteger ColorNumber=[[TempDic objectForKey:@"LEDColor"] integerValue];
        strcommand[3] =POWER2(ColorNumber);
        NSInteger Number=[[TempDic objectForKey:@"LEDFre"] integerValue]+1;
        strcommand[4] =20*Number;
        strcommand[5] =20*Number;
        strcommand[6] =2*Number;
        strcommand[7] =40*Number;
        strcommand[8] =1*Number;
        NSData *cmdData = [NSData dataWithBytes:strcommand length:9];
        NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BLEDataNotification" object:nil userInfo:dic];
    }
    
}

- (IBAction)LEDFColorAction:(UISlider*)sender {
    NSMutableDictionary *TempDic=[[NSMutableDictionary alloc]initWithDictionary:[MySettingData objectAtIndex:[SettingType integerValue]]];
    [TempDic setObject:[NSNumber numberWithInteger:sender.value] forKey:@"LEDColor"];
    [MySettingData replaceObjectAtIndex:[SettingType integerValue] withObject:TempDic];
    [MyUserDefault setObject:MySettingData forKey:@"SettingDataKey"];
    
    switch ([[TempDic objectForKey:@"LEDColor"] integerValue]) {
        case 0:
            _LEDColorView.backgroundColor=[UIColor blueColor];
            break;
        case 1:
            _LEDColorView.backgroundColor=[UIColor redColor];
            break;
        case 2:
            _LEDColorView.backgroundColor=[UIColor greenColor];
            break;
        case 3:
            _LEDColorView.backgroundColor=[UIColor yellowColor];
            break;
        case 4:
            _LEDColorView.backgroundColor=[UIColor whiteColor];
            break;
        default:
            break;
    }
    
    if ([[TempDic objectForKey:@"LEDSwitch"] boolValue]) {
        char strcommand[9]={0,0,0,0,0,0,0,0,0};
        if([SettingType integerValue]==1){
            strcommand[0] =3|(1<<4);
        }else{
            strcommand[0] =[SettingType integerValue]|(1<<4);
        }
        strcommand[2] =0;
        NSInteger ColorNumber=[[TempDic objectForKey:@"LEDColor"] integerValue];
        strcommand[3] =POWER2(ColorNumber);
        NSInteger Number=[[TempDic objectForKey:@"LEDFre"] integerValue]+1;
        strcommand[4] =20*Number;
        strcommand[5] =20*Number;
        strcommand[6] =2*Number;
        strcommand[7] =40*Number;
        strcommand[8] =1*Number;
        NSData *cmdData = [NSData dataWithBytes:strcommand length:9];
        NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BLEDataNotification" object:nil userInfo:dic];
    }
}

- (IBAction)SoundSwitchAction:(UISwitch*)sender {
    NSMutableDictionary *TempDic=[[NSMutableDictionary alloc]initWithDictionary:[MySettingData objectAtIndex:[SettingType integerValue]]];
    [TempDic setObject:[NSNumber numberWithBool:sender.on] forKey:@"SoundSwitch"];
    [MySettingData replaceObjectAtIndex:[SettingType integerValue] withObject:TempDic];
    [MyUserDefault setObject:MySettingData forKey:@"SettingDataKey"];
    
//    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedStringFromTable(@"SOUNDALERTCLOSE", @"Localizable", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    char strcommand[4]={0,0,0,0};
    if([SettingType integerValue]==1){
        strcommand[0] =3|(1<<4);
    }else{
        strcommand[0] =[SettingType integerValue]|(1<<4);
    }
    strcommand[2] =2;
    if (sender.on) {
        strcommand[3] =[[TempDic objectForKey:@"SoundVolume"] integerValue]+1;
//        alertView.message=NSLocalizedStringFromTable(@"SOUNDALERTOPEN", @"Localizable", nil);
    }
    NSData *cmdData = [NSData dataWithBytes:strcommand length:4];
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLEDataNotification" object:nil userInfo:dic];
//    [alertView show];
}

- (IBAction)SoundSliderAction:(UISlider*)sender {
    NSMutableDictionary *TempDic=[[NSMutableDictionary alloc]initWithDictionary:[MySettingData objectAtIndex:[SettingType integerValue]]];
    [TempDic setObject:[NSNumber numberWithInteger:sender.value] forKey:@"SoundVolume"];
    [MySettingData replaceObjectAtIndex:[SettingType integerValue] withObject:TempDic];
    [MyUserDefault setObject:MySettingData forKey:@"SettingDataKey"];
    NSLog(@"MySettingData:%@",MySettingData);
    
    if ([[TempDic objectForKey:@"SoundSwitch"] boolValue]) {
        char strcommand[4]={0,0,0,0};
        if([SettingType integerValue]==1){
            strcommand[0] =3|(1<<4);
        }else{
            strcommand[0] =[SettingType integerValue]|(1<<4);
        }
        strcommand[2] =2;
        strcommand[3] =[[TempDic objectForKey:@"SoundVolume"] integerValue]+1;
        NSData *cmdData = [NSData dataWithBytes:strcommand length:4];
        NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BLEDataNotification" object:nil userInfo:dic];
    }
}



- (IBAction)CancelAction:(UIBarButtonItem *)sender {
    NSEnumerator *enumerator = [[MySettingData objectAtIndex:[SettingType integerValue]] keyEnumerator];
    id key;
    NSDictionary *tempDic=[MySettingData objectAtIndex:[SettingType integerValue]];
    while ((key = [enumerator nextObject])) {
        /* code that uses the returned key */
        if([[tempDic objectForKey:key] isEqualToNumber:[MyLastDataDic objectForKey:key]]){
            
        }else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"ALERTTITLE", @"Localizable", nil) message:NSLocalizedStringFromTable(@"ALERTMESSAGE", @"Localizable", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"ALERTCANCEL", @"Localizable", nil) otherButtonTitles:NSLocalizedStringFromTable(@"ALERTSAVE", @"Localizable", nil), nil];
            alert.delegate=self;
            [alert show];
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%ld",(long)buttonIndex);
    if (buttonIndex==1) {
        
    }else{
        NSEnumerator *enumerator = [[MySettingData objectAtIndex:[SettingType integerValue]] keyEnumerator];
        id key;
        NSDictionary *tempDic=[MySettingData objectAtIndex:[SettingType integerValue]];
        while ((key = [enumerator nextObject])) {
            if([[tempDic objectForKey:key] isEqualToNumber:[MyLastDataDic objectForKey:key]]){
                
            }else{
                [self dataDiffAction:key];
            }
        }
        
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dataDiffAction:(NSString*)myKey{
    if ([myKey isEqualToString:@"VibSwitch"]||[myKey isEqualToString:@"LEDSwitch"]||[myKey isEqualToString:@"SoundSwitch"]) {
        UISwitch *mySwitch=[[UISwitch alloc]init];
        mySwitch.on=[[MyLastDataDic objectForKey:myKey] boolValue];
        if ([myKey isEqualToString:@"VibSwitch"]) {
            [self VibrSwitchAction:mySwitch];
        }else if ([myKey isEqualToString:@"LEDSwitch"]){
            [self LEDFSwitchAction:mySwitch];
        }else if ([myKey isEqualToString:@"SoundSwitch"]){
            [self SoundSwitchAction:mySwitch];
        }
        
    }else if([myKey isEqualToString:@"VibFre"]||[myKey isEqualToString:@"LEDFre"]||[myKey isEqualToString:@"LEDColor"]||[myKey isEqualToString:@"SoundVolume"]){
        UISlider *myslide=[[UISlider alloc]init];
        myslide.value=[[MyLastDataDic objectForKey:myKey] integerValue];
        if ([myKey isEqualToString:@"VibFre"]) {
            [self VibrSliderAction:myslide];
        }else if ([myKey isEqualToString:@"LEDFre"]){
            [self LEDFSliderAction:myslide];
        }else if ([myKey isEqualToString:@"LEDColor"]){
            [self LEDFColorAction:myslide];
        }else if ([myKey isEqualToString:@"SoundVolume"]){
            [self SoundSliderAction:myslide];
        }
    }
}

@end
