//
//  ViewController.m
//  pendant
//
//  Created by 陈双超 on 15/1/12.
//  Copyright (c) 2015年 陈双超. All rights reserved.
//


#import "ViewController.h"
#import "TableViewCell.h"
#import "BLEConnectVC.h"
#import "PopupView.h"

#import <AVFoundation/AVFoundation.h>

#define IS_IOS_7 ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)?YES:NO
#define IS_IOS_8 ([[[UIDevice currentDevice] systemVersion] doubleValue]>=8.0)?YES:NO

#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define SCREENHIGHT [[UIScreen mainScreen] bounds].size.height
#define SCREENWIDTH [[UIScreen mainScreen] bounds].size.width

@interface ViewController (){
    NSMutableArray *list;
    NSMutableArray *imageList;
    BLEConnectVC *bleConnectViewContrller;
    
    __block int timeout;
    dispatch_queue_t queue;
    dispatch_source_t _timer;
    
    UIButton *buttonPhotoImage;
}
@end

@implementation ViewController
@synthesize BatteryImage,batteryLabel;



-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"SCREEN_MAX_LENGTH:%f",SCREEN_MAX_LENGTH);
//    if (IS_IPHONE_6||IS_IPHONE_5) {
//        _MyTableView.frame=CGRectMake(0, 126, SCREENWIDTH, 226);
//        _BottomView.frame=CGRectMake(0, 352, SCREENWIDTH, 196);
//    }else
    if (IS_IPHONE_4_OR_LESS){
        
        _MyTableView.frame=CGRectMake(0, 126, SCREENWIDTH, 156);
        
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];

//    if (IS_IPHONE_4_OR_LESS){
//        _MyTableView.autoresizesSubviews=NO;
//        _MyTableView.frame=CGRectMake(0, 126, SCREENWIDTH, 156);
//        _BottomView.frame=CGRectMake(0, 282, SCREENWIDTH, 196);
//    }
    UIImageView *leftBarView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 140, 10)];
    leftBarView.image=[UIImage imageNamed:@"uny_title"];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:leftBarView];
    
    
    
//    self.title=NSLocalizedStringFromTable(@"Home_TITLE", @"Localizable", nil);
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:5.0/255 green:37.0/255 blue:76.0/255 alpha:1];
    
    list = [[NSMutableArray alloc]init];
    [list addObject:NSLocalizedStringFromTable(@"List_TITLE1", @"Localizable", nil)];
    [list addObject:NSLocalizedStringFromTable(@"List_TITLE2", @"Localizable", nil)];
    [list addObject:NSLocalizedStringFromTable(@"List_TITLE3", @"Localizable", nil)];
    [list addObject:@"Applications"];
    imageList =[[NSMutableArray alloc] initWithObjects:@"ic_call",@"ic_text",@"ic_mail",@"ic_app",nil];
    
    bleConnectViewContrller=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]  instantiateViewControllerWithIdentifier:@"bleConnectVC"];
    
    queue= dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    timeout=3600; //倒计时时间
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(TakePhotoPushAction:) name:@"TakePhotoNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(updateBatteryAction:) name:@"ChangeBatteryNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(updateRSSINumber:) name:@"updateRSSINotification" object:nil];
    
    [self ShowRSSI];
}

-(void)viewWillAppear:(BOOL)animated{
    //    self.navigationController.navigationBar.hidden=YES;
    timeout=3600;
//    if (IS_IPHONE_4_OR_LESS){
//        _MyTableView.autoresizesSubviews=NO;
//        _MyTableView.frame=CGRectMake(0, 126, SCREENWIDTH, 156);
//        _BottomView.frame=CGRectMake(0, 282, SCREENWIDTH, 196);
//    }
}

-(void)ShowRSSI{
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                self.RssiLabel.text=@"over";
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (bleConnectViewContrller.peripheralOpration.state==2) {
                    if (IS_IOS_8) {
//                        NSLog(@"shuaxin");
                        [bleConnectViewContrller.peripheralOpration readRSSI];
                    }else{
                        self.RssiLabel.text=[NSString stringWithFormat:@"%@",[bleConnectViewContrller.peripheralOpration RSSI]];
                    }
                }else{
//                    NSLog(@"未连接");
                    self.RssiLabel.text=NSLocalizedStringFromTable(@"BLE_DIS", @"Localizable", nil);
                }
//                [bleConnectViewContrller readRSSI];  
            });
            timeout--;
            
        }
    });
    dispatch_resume(_timer);
}


-(void)updateBatteryAction:(NSNotification*) notification{
    
    self.batteryLabel.text=[NSString stringWithFormat:@"%@%%",[notification object] ];
    NSInteger ElecticNumber=[[notification object] integerValue];
    if (ElecticNumber>80) {
        [_EStrengthImageView setImage:[UIImage imageNamed:@"battery_lvl3"]];
    }else if (ElecticNumber>60){
        [_EStrengthImageView setImage:[UIImage imageNamed:@"battery_lvl2"]];
    }else if (ElecticNumber>40){
        [_EStrengthImageView setImage:[UIImage imageNamed:@"battery_lvl1"]];
    }else if (ElecticNumber>20){
        [_EStrengthImageView setImage:[UIImage imageNamed:@"battery_lvl0"]];
    }else{
        [_EStrengthImageView setImage:[UIImage imageNamed:@"battery_lvln"]];
    }
}

-(void)TakePhotoPushAction:(NSNotification*) notification{
//    NSLog(@"照相");
    [_imagePicker takePicture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateRSSINumber:(NSNotification*) notification{
    self.RssiLabel.text=[NSString stringWithFormat:@"%@",[[notification userInfo] objectForKey:@"RSSI"]];
    NSInteger rssiNumber=[[[notification userInfo] objectForKey:@"RSSI"] integerValue];
    if (rssiNumber>-50) {
        [_WIFIStrengthImageView setImage:[UIImage imageNamed:@"signal_open_lvl3"]];
    }else if (rssiNumber>-80){
        [_WIFIStrengthImageView setImage:[UIImage imageNamed:@"signal_open_lvl2"]];
    }else if (rssiNumber>-90){
        [_WIFIStrengthImageView setImage:[UIImage imageNamed:@"signal_open_lvl1"]];
    }else{
        [_WIFIStrengthImageView setImage:[UIImage imageNamed:@"signal_open_lvl0"]];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IS_IPHONE_4_OR_LESS) {
        return 52;
    }else if (IS_IPHONE_5){
        return 76;
    }else if (IS_IPHONE_6){
        return 86;
    }else{
        return 96;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CustomCellIdentifier =@"CellIdentifier";
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CustomCellIdentifier];
    if (cell ==nil) {
        cell = [[TableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CustomCellIdentifier];
    }
   
    cell.titleLabel.text = [list objectAtIndex:indexPath.row];
    cell.titleImage.image = [UIImage imageNamed:[imageList objectAtIndex:indexPath.row]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self performSegueWithIdentifier:@"CallView" sender:[NSNumber numberWithInteger:indexPath.row]];
}



- (IBAction)ShowConnectionAction:(UIBarButtonItem *)sender {
    [self.navigationController pushViewController:bleConnectViewContrller animated:YES];
}

- (IBAction)NotifySwitchAction:(UISwitch*)sender {
    char strcommand[2]={'0','0'};
    strcommand[0] =0;
    strcommand[1] =sender.on;
    
    NSData *cmdData = [NSData dataWithBytes:strcommand length:2];
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:cmdData,@"tempData",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLEDataNotification" object:dic userInfo:dic];
}

- (IBAction)TakePhotoAction:(id)sender {
    [self showImagePicker];
}
-(void)showImagePicker
{
    //调用系统照片库
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _imagePicker.allowsEditing =  YES;
        _imagePicker.cameraOverlayView = [self customOverlayView];
        _imagePicker.showsCameraControls = NO;
//        CGFloat camScaleup = 1;
//        _imagePicker.cameraViewTransform = CGAffineTransformScale(_imagePicker.cameraViewTransform, camScaleup, camScaleup);
        [self presentViewController:_imagePicker animated:YES completion:nil];
    } else {
        NSLog(@"照相机不可用。");
    }
}
-(void)DidCancelAction{
    [_imagePicker dismissViewControllerAnimated:YES completion:nil];
}
-(UIView *)customOverlayView
{
    UIView *mycustomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHIGHT)];
    
    UIButton *openLight=[UIButton buttonWithType:UIButtonTypeCustom];
    openLight.frame=CGRectMake(90, SCREENHIGHT-130, 100, 44);
    openLight.backgroundColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.5];
    [openLight setTitle:NSLocalizedStringFromTable(@"FLASHLIGHT", @"Localizable", nil) forState:UIControlStateNormal];
    openLight.titleLabel.numberOfLines=2;
    openLight.lineBreakMode = NSLineBreakByCharWrapping;
    [openLight setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [openLight addTarget:self action:@selector(Flashlight:) forControlEvents:UIControlEventTouchUpInside];
    [mycustomView addSubview:openLight];
    
    
    UIButton *ChangeButton = [[UIButton alloc] initWithFrame:CGRectMake(210, SCREENHIGHT-130, 100, 44)];
    ChangeButton.backgroundColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.5];
    [ChangeButton setTitle:NSLocalizedStringFromTable(@"SWITCHCAMERA", @"Localizable", nil) forState:UIControlStateNormal];
    [ChangeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    ChangeButton.titleLabel.numberOfLines=2;
    ChangeButton.lineBreakMode = NSLineBreakByCharWrapping;
    [ChangeButton addTarget:self action:@selector(swapFrontAndBackCameras) forControlEvents:UIControlEventTouchUpInside];
    [mycustomView addSubview:ChangeButton];
    
    
    UIButton *shootPictureButton = [[UIButton alloc] initWithFrame:CGRectMake(90, SCREENHIGHT-70, 100, 44)];
    shootPictureButton.backgroundColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.5];
    [shootPictureButton setTitle:NSLocalizedStringFromTable(@"PHOTO", @"Localizable", nil)  forState:UIControlStateNormal];
    shootPictureButton.titleLabel.numberOfLines=2;
    shootPictureButton.lineBreakMode = NSLineBreakByCharWrapping;
    [shootPictureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shootPictureButton addTarget:_imagePicker action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
    [mycustomView addSubview:shootPictureButton];
    
    
    UIButton *CancelButton = [[UIButton alloc] initWithFrame:CGRectMake(210, SCREENHIGHT-70, 100, 44)];
    CancelButton.backgroundColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.5];
    [CancelButton setTitle:NSLocalizedStringFromTable(@"CANCEL", @"Localizable", nil) forState:UIControlStateNormal];
    [CancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [CancelButton addTarget:self action:@selector(DidCancelAction) forControlEvents:UIControlEventTouchUpInside];
    CancelButton.titleLabel.numberOfLines=2;
    CancelButton.lineBreakMode = NSLineBreakByCharWrapping;
    [mycustomView addSubview:CancelButton];
    
    
    buttonPhotoImage=[UIButton buttonWithType:UIButtonTypeCustom];
    buttonPhotoImage.backgroundColor=[UIColor whiteColor];
    buttonPhotoImage.frame=CGRectMake(10, SCREENHIGHT-100, 60, 60);
    [buttonPhotoImage addTarget:self action:@selector(buttonImageAction) forControlEvents:UIControlEventTouchUpInside];
    [mycustomView addSubview:buttonPhotoImage];
    
    
    return mycustomView;
}
- (void)Flashlight:(id)sender {
    //配置一个device (查找前后摄像头)
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device.torchMode == AVCaptureTorchModeOff) {
        //Create an AV session
        AVCaptureSession *  AVSession = [[AVCaptureSession alloc]init];
        
        // Create device input and add to current session
        AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        [AVSession addInput:input];
        
        // Create video output and add to current session
        AVCaptureVideoDataOutput * output = [[AVCaptureVideoDataOutput alloc]init];
        [AVSession addOutput:output];
        
        // 重新设置session
        [AVSession beginConfiguration];// Start session configuration
        
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOn];// Set torch to on
        [device unlockForConfiguration];
        
        [AVSession commitConfiguration];//session configuration End
        
        
    }else{
        AVCaptureSession *  AVSession = [[AVCaptureSession alloc]init];
        
        AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        [AVSession addInput:input];
        
        // Create video output and add to current session
        AVCaptureVideoDataOutput * output = [[AVCaptureVideoDataOutput alloc]init];
        [AVSession addOutput:output];
        
        // 重新设置session
        [AVSession beginConfiguration];// Start session configuration
        
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOff];// Set torch to off
        [device unlockForConfiguration];
        
        [AVSession commitConfiguration];//session configuration End
        
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    NSNumber *SettingType = (NSNumber *)sender;
//    NSLog(@"SettingType:%@",SettingType );
    UIViewController *destination = segue.destinationViewController;
    [destination setValue:sender forKey:@"SettingType"];
    
}


#pragma - mark delegate methods
//选择完成之后
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    //改背景图为选择的图片
    [self dismissModalViewControllerAnimated:YES];
}


#pragma - mark delegate methods
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    if (_imagePicker.sourceType != UIImagePickerControllerSourceTypeCamera) {
        _imagePicker.sourceType =    UIImagePickerControllerSourceTypeCamera;
    }else{
        //取消选择图片，取消拍照
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info
{
    if (_imagePicker.sourceType != UIImagePickerControllerSourceTypeCamera) {
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:@"public.image"]){
            
            UIImage *originalImage = (UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage];//得到照片
            UIImageWriteToSavedPhotosAlbum(originalImage, nil, nil, nil);//图片存入相册
            [_imagePicker popViewControllerAnimated:YES];
            [buttonPhotoImage setBackgroundImage:originalImage forState:UIControlStateNormal];
        }
        
    }else{
//        NSLog(@"拍照完毕");
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:@"public.image"]){
//            NSLog(@"保存图片") ;
            UIImage *originalImage = (UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage];//得到照片
            UIImageWriteToSavedPhotosAlbum(originalImage, nil, nil, nil);//图片存入相册
            
            PopupView  *popUpView = [[PopupView alloc]initWithFrame:CGRectMake(100, 240, 0, 0)];
            popUpView.ParentView = self.imagePicker.cameraOverlayView;
            [popUpView setText:[NSString stringWithFormat:NSLocalizedStringFromTable(@"SaveMessage", @"Localizable", nil)]];
            [self.imagePicker.cameraOverlayView addSubview:popUpView];
            
            
            [buttonPhotoImage setBackgroundImage:originalImage forState:UIControlStateNormal];
        }
        
        if (_imagePicker == picker)  {//这里的条件随便你自己定义了
            //**主要就是下面这句话，会让你继续回到take camera的页面
            _imagePicker.sourceType =    UIImagePickerControllerSourceTypeCamera;
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
}
-(void)buttonImageAction{
//    NSLog(@"buttonImageAction");
    //打开相册选择照片
    _imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    _imagePicker.allowsEditing = YES;//是否可以编辑
}
- (void)swapFrontAndBackCameras {
    // Assume the session is already running
    if (_imagePicker.cameraDevice ==UIImagePickerControllerCameraDeviceRear ) {
        _imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }else {
        _imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
}

@end
