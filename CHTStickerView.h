//
//  CHTStickerView.h
//  Sample
//
//  Created by Nelson Tai on 2013/10/31.
//  Copyright (c) 2013年 Nelson Tai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CHTStickerViewHandler) {
  CHTStickerViewHandlerClose,
  CHTStickerViewHandlerRotate
};

typedef NS_ENUM(NSInteger, CHTStickerViewPosition) {
  CHTStickerViewPositionTopLeft,
  CHTStickerViewPositionTopRight,
  CHTStickerViewPositionBottomLeft,
  CHTStickerViewPositionBottomRight
};

@class CHTStickerView;

@protocol CHTStickerViewDelegate <NSObject>
@optional
- (void)stickerViewDidBeginMoving:(CHTStickerView *)stickerView;
- (void)stickerViewDidChangeMoving:(CHTStickerView *)stickerView;
- (void)stickerViewDidEndMoving:(CHTStickerView *)stickerView;
- (void)stickerViewDidBeginRotating:(CHTStickerView *)stickerView;
- (void)stickerViewDidChangeRotating:(CHTStickerView *)stickerView;
- (void)stickerViewDidEndRotating:(CHTStickerView *)stickerView;
- (void)stickerViewDidClose:(CHTStickerView *)stickerView;
- (void)stickerViewDidTap:(CHTStickerView *)stickerView;
@end

@interface CHTStickerView : UIView
@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, weak) id<CHTStickerViewDelegate> delegate;
@property (nonatomic, assign) BOOL enableClose;
@property (nonatomic, assign) BOOL enableRotate;
@property (nonatomic, assign) BOOL showEditingHandlers;
@property (nonatomic, assign) NSInteger minimumSize;
/// A convenient property for you to store extra information.
@property (nonatomic, strong) NSDictionary *userInfo;
- (id)initWithContentView:(UIView *)contentView;
- (void)setImage:(UIImage *)image forHandler:(CHTStickerViewHandler)handler;
- (void)setPosition:(CHTStickerViewPosition)position forHandler:(CHTStickerViewHandler)handler;
@end
