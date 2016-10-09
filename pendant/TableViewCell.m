//
//  TableViewCell.m
//  ADMBL
//
//  Created by 陈双超 on 14/12/5.
//  Copyright (c) 2014年 com.aidian. All rights reserved.
//

#import "TableViewCell.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

@implementation TableViewCell


- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    
    self.titleImage =[[UIImageView alloc]init];
    if (IS_IPHONE_4_OR_LESS) {
        self.titleImage.frame = CGRectMake(10, 10, 32, 32);
    }else{
        self.titleImage.frame = CGRectMake(10, 12, 52, 52);
    }
    
    [self addSubview:self.titleImage];
    
    
    self.titleLabel  = [[UILabel alloc]init];
    if (IS_IPHONE_4_OR_LESS) {
        self.titleLabel.frame = CGRectMake(48, 0, 200, 52);
    }else{
        self.titleLabel.frame = CGRectMake(72, 0, 200, 76);
    }
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.numberOfLines=0;
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.textColor=[UIColor blackColor];
    self.titleLabel.font =[UIFont fontWithName:@"Helvetica" size:12];
    self.titleLabel.backgroundColor=[UIColor clearColor];
    [self addSubview:self.titleLabel];
    
    
    self.backgroundColor=[UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    
}

@end
