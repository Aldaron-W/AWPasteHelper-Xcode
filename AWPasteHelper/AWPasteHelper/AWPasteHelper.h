//
//  AWPasteHelper.h
//  AWPasteHelper
//
//  Created by Work on 16/5/17.
//  Copyright © 2016年 Aldaron. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface AWPasteHelper : NSObject

+ (instancetype)sharedPlugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end