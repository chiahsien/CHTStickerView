//
//  CHTViewController.m
//  Sample
//
//  Created by Nelson Tai on 2013/10/31.
//  Copyright (c) 2013年 Nelson Tai. All rights reserved.
//

#import "CHTViewController.h"

@interface CHTViewController ()
@property (nonatomic, strong) CHTStickerView *selectedView;
@end

@implementation CHTViewController

- (void)setSelectedView:(CHTStickerView *)selectedView {
  if (_selectedView != selectedView) {
    if (_selectedView) {
      _selectedView.showEditingHandlers = NO;
    }
    _selectedView = selectedView;
    if (_selectedView) {
      _selectedView.showEditingHandlers = YES;
    }
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];

  UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 100)];
  testView.backgroundColor = [UIColor redColor];

  CHTStickerView *stickerView = [[CHTStickerView alloc] initWithContentView:testView];
  stickerView.center = self.view.center;
  stickerView.delegate = self;
  [stickerView setImage:[UIImage imageNamed:@"Close"] forHandler:CHTStickerViewHandlerClose];
  [stickerView setImage:[UIImage imageNamed:@"Rotate"] forHandler:CHTStickerViewHandlerRotate];
  [self.view addSubview:stickerView];

  UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
  testLabel.text = @"Test Label";
  testLabel.textAlignment = NSTextAlignmentCenter;

  CHTStickerView *stickerView2 = [[CHTStickerView alloc] initWithContentView:testLabel];
  stickerView2.center = CGPointMake(100, 100);
  stickerView2.delegate = self;
  [stickerView2 setImage:[UIImage imageNamed:@"Close"] forHandler:CHTStickerViewHandlerClose];
  [stickerView2 setImage:[UIImage imageNamed:@"Rotate"] forHandler:CHTStickerViewHandlerRotate];
  stickerView2.showEditingHandlers = NO;
  [self.view addSubview:stickerView2];

  self.selectedView = stickerView;
}

- (void)stickerViewDidBeginMoving:(CHTStickerView *)stickerView {
  self.selectedView = stickerView;
}

- (void)stickerViewDidTapped:(CHTStickerView *)stickerView {
  self.selectedView = stickerView;
}

@end
