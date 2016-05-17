//
//  AWPasteHelper.m
//  AWPasteHelper
//
//  Created by Work on 16/5/17.
//  Copyright © 2016年 Aldaron. All rights reserved.
//

#import "AWPasteHelper.h"

static AWPasteHelper *sharedPlugin;

@implementation AWPasteHelper

#pragma mark - Initialization

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    NSArray *allowedLoaders = [plugin objectForInfoDictionaryKey:@"me.delisa.XcodePluginBase.AllowedLoaders"];
    if ([allowedLoaders containsObject:[[NSBundle mainBundle] bundleIdentifier]]) {
        sharedPlugin = [[self alloc] initWithBundle:plugin];
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)bundle
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        _bundle = bundle;
        // NSApp may be nil if the plugin is loaded from the xcodebuild command line tool
        if (NSApp && !NSApp.mainMenu) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationDidFinishLaunching:)
                                                         name:NSApplicationDidFinishLaunchingNotification
                                                       object:nil];
        } else {
            [self initializeAndLog];
        }
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    [self initializeAndLog];
}

- (void)initializeAndLog
{
    NSString *name = [self.bundle objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *version = [self.bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *status = [self initialize] ? @"loaded successfully" : @"failed to load";
    NSLog(@"🔌 Plugin %@ %@ %@", name, version, status);
}

#pragma mark - Implementation

- (BOOL)initialize
{
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (editMenuItem) {
        //在Edit目录下添加新的Paste Helper(AW)按钮，快捷键为 shift + command + v
        NSUInteger itemIndex = [self menuIndexForMenuItem:editMenuItem withTitle:@"Paste"];
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Paste Helper(AW)" action:@selector(pasteMethods) keyEquivalent:@""];
        menuItem.keyEquivalentModifierMask = NSShiftKeyMask | NSCommandKeyMask;
        menuItem.keyEquivalent = @"v";
        menuItem.target = self;
        
        if (itemIndex > 0) {
            [editMenuItem.submenu insertItem:menuItem atIndex:itemIndex];
        } else {
            [editMenuItem.submenu addItem:menuItem];
        }
        
        [[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Do Action" action:@selector(doMenuAction) keyEquivalent:@""];
        //[actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        [actionMenuItem setTarget:self];
        [[editMenuItem submenu] addItem:actionMenuItem];
        return YES;
    } else {
        return NO;
    }
}

// Sample Action, for menu item:
- (void)doMenuAction
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Hello, World"];
    [alert runModal];
}

#pragma mark - Menu

- (void)pasteMethods
{
    //获取剪切板内容
    NSArray *classes = @[[NSString class]];
    NSArray *strings = [[NSPasteboard generalPasteboard] readObjectsForClasses:classes options:0];
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:[strings firstObject]];
    [alert runModal];
}

- (NSUInteger)menuIndexForMenuItem:(NSMenuItem *)menuItem withTitle:(NSString *)title
{
    __block NSUInteger insertIndex = 0;
    
    [menuItem.submenu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
        if (item.title.length >= title.length && [[item.title substringToIndex:title.length] isEqualToString:title]) {
            insertIndex = idx + 1;
        } else if (insertIndex > 0) {
            *stop = YES;
        }
    }];
    
    return insertIndex;
}

@end
