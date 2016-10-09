//
//  CallViewController.h
//  pendant
//
//  Created by 陈双超 on 15/3/17.
//  Copyright (c) 2015年 陈双超. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallViewController : UIViewController<UIAlertViewDelegate,UIAlertViewDelegate>

@property (nonatomic,strong)NSNumber *SettingType;//电话提醒=0,信息提醒=1,邮件提醒=2,社交软件提醒=3,异常提醒=4,


@property (weak, nonatomic) IBOutlet UISwitch *VibSwitch;
@property (weak, nonatomic) IBOutlet UISlider *VibSlider;
@property (weak, nonatomic) IBOutlet UISwitch *LEDSwitch;
@property (weak, nonatomic) IBOutlet UISlider *LEDFRESlider;
@property (weak, nonatomic) IBOutlet UISlider *LEDColorSliser;
@property (weak, nonatomic) IBOutlet UIButton *LEDColorView;
@property (weak, nonatomic) IBOutlet UISwitch *SoundSwitch;
@property (weak, nonatomic) IBOutlet UISlider *SoundSlider;

@property (weak, nonatomic) IBOutlet UILabel *VibNotifyLabel;
@property (weak, nonatomic) IBOutlet UILabel *VibFreLabel;
@property (weak, nonatomic) IBOutlet UILabel *FlashNotifyLabel;
@property (weak, nonatomic) IBOutlet UILabel *FlashFreLabel;
@property (weak, nonatomic) IBOutlet UILabel *FlashColorLabel;
@property (weak, nonatomic) IBOutlet UILabel *SoundLabel;
@property (weak, nonatomic) IBOutlet UILabel *SoundVolumeLabel;



- (IBAction)VibrSwitchAction:(UISwitch*)sender;
- (IBAction)VibrSliderAction:(UISlider*)sender;
- (IBAction)LEDFSwitchAction:(UISwitch*)sender;
- (IBAction)LEDFSliderAction:(UISlider*)sender;
- (IBAction)LEDFColorAction:(UISlider*)sender;
- (IBAction)SoundSwitchAction:(UISwitch*)sender;
- (IBAction)SoundSliderAction:(UISlider*)sender;

- (IBAction)CancelAction:(UIBarButtonItem *)sender;


@end
