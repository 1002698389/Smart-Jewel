//
//  ViewController.h
//  pendant
//
//  Created by 陈双超 on 15/1/12.
//  Copyright (c) 2015年 陈双超. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *MyTableView;

@property (weak, nonatomic) IBOutlet UISwitch *StatusNotifySwitch;

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIImageView *BatteryImage;
@property (weak, nonatomic) IBOutlet UILabel *batteryLabel;
@property (weak, nonatomic) IBOutlet UILabel *RssiLabel;
@property (weak, nonatomic) IBOutlet UIImageView *WIFIStrengthImageView;
@property (weak, nonatomic) IBOutlet UIImageView *EStrengthImageView;
@property (weak, nonatomic) IBOutlet UIView *BottomView;


- (IBAction)ShowConnectionAction:(UIBarButtonItem *)sender;
- (IBAction)NotifySwitchAction:(UISwitch*)sender;
- (IBAction)TakePhotoAction:(id)sender;

@end

