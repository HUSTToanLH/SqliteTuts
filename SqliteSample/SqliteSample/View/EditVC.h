//
//  EditVC.h
//  SqliteSample
//
//  Created by TaiND on 11/9/15.
//  Copyright (c) 2015 ToanLH. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol edittingInfoFinished <NSObject>

-(void)edittingInfoWasFinished;

@end

@interface EditVC : UIViewController
@property (nonatomic, strong) id<edittingInfoFinished> delegate;
@property (nonatomic, assign) int recordIDToEdit;

@end
