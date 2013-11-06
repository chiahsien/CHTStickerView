//
//  CHTStickerView.m
//  Sample
//
//  Created by Nelson Tai on 2013/10/31.
//  Copyright (c) 2013年 Nelson Tai. All rights reserved.
//

#import "CHTStickerView.h"

CG_INLINE CGPoint CGRectGetCenter(CGRect rect) {
  return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

CG_INLINE CGRect CGRectScale(CGRect rect, CGFloat wScale, CGFloat hScale) {
  return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width * wScale, rect.size.height * hScale);
}

CG_INLINE CGFloat CGAffineTransformGetAngle(CGAffineTransform t) {
  return atan2(t.b, t.a);
}

CG_INLINE CGFloat CGPointGetDistance(CGPoint point1, CGPoint point2) {
  CGFloat fx = (point2.x - point1.x);
  CGFloat fy = (point2.y - point1.y);
  return sqrt((fx*fx + fy*fy));
}

@interface CHTStickerView () {
  CGPoint beginningPoint;
  CGPoint beginningCenter;

  CGRect initialBounds;
  CGFloat initialDistance;
  CGFloat deltaAngle;
}
@property (nonatomic, strong, readwrite) UIView *contentView;
@property (nonatomic, strong) UIPanGestureRecognizer *moveGesture;
@property (nonatomic, strong) UIImageView *rotateImageView;
@property (nonatomic, strong) UIPanGestureRecognizer *rotateGesture;
@property (nonatomic, strong) UIImageView *closeImageView;
@property (nonatomic, strong) UITapGestureRecognizer *closeGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@end

const NSInteger kGlobalInset = 12;
const NSInteger kMinimumSize = 5 * kGlobalInset;

@implementation CHTStickerView

#pragma mark - Properties

- (UIPanGestureRecognizer *)moveGesture {
  if (!_moveGesture) {
    _moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMoveGesture:)];
  }
  return _moveGesture;
}

- (UIPanGestureRecognizer *)rotateGesture {
  if (!_rotateGesture) {
    _rotateGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotateGesture:)];
  }
  return _rotateGesture;
}

- (UITapGestureRecognizer *)closeGesture {
  if (!_closeGesture) {
    _closeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCloseGesture:)];
  }
  return _closeGesture;
}

- (UIImageView *)closeImageView {
  if (!_closeImageView) {
    _closeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kGlobalInset*2, kGlobalInset*2)];
    _closeImageView.contentMode = UIViewContentModeScaleAspectFit;
    _closeImageView.backgroundColor = [UIColor clearColor];
    _closeImageView.userInteractionEnabled = YES;
    [_closeImageView addGestureRecognizer:self.closeGesture];
  }
  return _closeImageView;
}

- (UIImageView *)rotateImageView {
  if (!_rotateImageView) {
    _rotateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kGlobalInset*2, kGlobalInset*2)];
    _rotateImageView.contentMode = UIViewContentModeScaleAspectFit;
    _rotateImageView.backgroundColor = [UIColor clearColor];
    _rotateImageView.userInteractionEnabled = YES;
    [_rotateImageView addGestureRecognizer:self.rotateGesture];
  }
  return _rotateImageView;
}

- (UITapGestureRecognizer *)tapGesture {
  if (!_tapGesture) {
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
  }
  return _tapGesture;
}

- (void)setEnableClose:(BOOL)enableClose {
  _enableClose = enableClose;
  if (self.showEditingHandlers) {
    [self _setEnableClose:enableClose];
  }
}

- (void)setEnableRotate:(BOOL)enableRotate {
  _enableRotate = enableRotate;
  if (self.showEditingHandlers) {
    [self _setEnableRotate:enableRotate];
  }
}

- (void)setShowEditingHandlers:(BOOL)showEditingHandlers {
  _showEditingHandlers = showEditingHandlers;
  if (showEditingHandlers) {
    [self _setEnableClose:self.enableClose];
    [self _setEnableRotate:self.enableRotate];
    self.contentView.layer.borderWidth = 2;
  } else {
    [self _setEnableClose:NO];
    [self _setEnableRotate:NO];
    self.contentView.layer.borderWidth = 0;
  }
}

- (void)setMinimumSize:(NSInteger)minimumSize {
  _minimumSize = MAX(minimumSize, kMinimumSize);
}

#pragma mark - Private Methods

- (void)_setEnableClose:(BOOL)enableClose {
  self.closeImageView.hidden = !enableClose;
  self.closeImageView.userInteractionEnabled = enableClose;
}

- (void)_setEnableRotate:(BOOL)enableRotate {
  self.rotateImageView.hidden = !enableRotate;
  self.rotateImageView.userInteractionEnabled = enableRotate;
}

#pragma mark - UIView

- (id)initWithContentView:(UIView *)contentView {
  if (!contentView) {
    return nil;
  }

  CGRect frame = contentView.frame;
  frame = CGRectMake(0, 0, frame.size.width + kGlobalInset*2, frame.size.height + kGlobalInset*2);
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor clearColor];
    [self addGestureRecognizer:self.moveGesture];
    [self addGestureRecognizer:self.tapGesture];

    // Content View
    self.contentView = contentView;
    self.contentView.center = CGRectGetCenter(self.bounds);
    self.contentView.userInteractionEnabled = NO;
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.contentView.layer.borderColor = [UIColor brownColor].CGColor;
    self.contentView.layer.borderWidth = 2;
    [self addSubview:self.contentView];

    [self setPosition:CHTStickerViewPositionTopLeft forHandler:CHTStickerViewHandlerClose];
    [self addSubview:self.closeImageView];
    [self setPosition:CHTStickerViewPositionTopRight forHandler:CHTStickerViewHandlerRotate];
    [self addSubview:self.rotateImageView];

    self.showEditingHandlers = YES;
    self.enableClose = YES;
    self.enableRotate = YES;

    self.minimumSize = kMinimumSize;
  }
  return self;
}

#pragma mark - Gesture Handlers

- (void)handleMoveGesture:(UIPanGestureRecognizer *)recognizer {
  CGPoint touchLocation = [recognizer locationInView:self.superview];

  switch (recognizer.state) {
    case UIGestureRecognizerStateBegan:
      beginningPoint = touchLocation;
      beginningCenter = self.center;
      if ([self.delegate respondsToSelector:@selector(stickerViewDidBeginMoving:)]) {
        [self.delegate stickerViewDidBeginMoving:self];
      }
      break;

    case UIGestureRecognizerStateChanged:
      self.center = CGPointMake(beginningCenter.x + (touchLocation.x - beginningPoint.x),
                                beginningCenter.y + (touchLocation.y - beginningPoint.y));
      if ([self.delegate respondsToSelector:@selector(stickerViewDidChangeMoving:)]) {
        [self.delegate stickerViewDidChangeMoving:self];
      }
      break;

    case UIGestureRecognizerStateEnded:
      self.center = CGPointMake(beginningCenter.x + (touchLocation.x - beginningPoint.x),
                                beginningCenter.y + (touchLocation.y - beginningPoint.y));
      if ([self.delegate respondsToSelector:@selector(stickerViewDidEndMoving:)]) {
        [self.delegate stickerViewDidEndMoving:self];
      }
      break;

    default:
      break;
  }
}

- (void)handleRotateGesture:(UIPanGestureRecognizer *)recognizer {
  CGPoint touchLocation = [recognizer locationInView:self.superview];
  CGPoint center = self.center;

  switch (recognizer.state) {
    case UIGestureRecognizerStateBegan: {
      deltaAngle = atan2f(touchLocation.y - center.y, touchLocation.x - center.x) - CGAffineTransformGetAngle(self.transform);
      initialBounds = self.bounds;
      initialDistance = CGPointGetDistance(center, touchLocation);
      if ([self.delegate respondsToSelector:@selector(stickerViewDidBeginRotating:)]) {
        [self.delegate stickerViewDidBeginRotating:self];
      }
      break;
    }

    case UIGestureRecognizerStateChanged: {
      float angle = atan2f(touchLocation.y - center.y, touchLocation.x - center.x);
      float angleDiff = deltaAngle - angle;
      self.transform = CGAffineTransformMakeRotation(-angleDiff);

      CGFloat scale = CGPointGetDistance(center, touchLocation)/initialDistance;
      CGFloat minimumScale = self.minimumSize/MIN(initialBounds.size.width, initialBounds.size.height);
      scale = MAX(scale, minimumScale);
      CGRect scaledBounds = CGRectScale(initialBounds, scale, scale);
      self.bounds = scaledBounds;
      [self setNeedsDisplay];

      if ([self.delegate respondsToSelector:@selector(stickerViewDidChangeRotating:)]) {
        [self.delegate stickerViewDidChangeRotating:self];
      }
      break;
    }

    case UIGestureRecognizerStateEnded:
      if ([self.delegate respondsToSelector:@selector(stickerViewDidEndRotating:)]) {
        [self.delegate stickerViewDidEndRotating:self];
      }
      break;

    default:
      break;
  }
}

- (void)handleCloseGesture:(UITapGestureRecognizer *)recognizer {
  [self removeFromSuperview];
  if ([self.delegate respondsToSelector:@selector(stickerViewDidClose:)]) {
    [self.delegate stickerViewDidClose:self];
  }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer {
  if ([self.delegate respondsToSelector:@selector(stickerViewDidTap:)]) {
    [self.delegate stickerViewDidTap:self];
  }
}

#pragma mark - Public Methods

- (void)setImage:(UIImage *)image forHandler:(CHTStickerViewHandler)handler {
  switch (handler) {
    case CHTStickerViewHandlerClose:
      self.closeImageView.image = image;
      break;
    case CHTStickerViewHandlerRotate:
      self.rotateImageView.image = image;
      break;
  }
}

- (void)setPosition:(CHTStickerViewPosition)position forHandler:(CHTStickerViewHandler)handler {
  CGPoint origin = self.contentView.frame.origin;
  CGSize size = self.contentView.frame.size;
  UIImageView *handlerView = nil;
  
  switch (handler) {
    case CHTStickerViewHandlerClose:
      handlerView = self.closeImageView;
      break;
    case CHTStickerViewHandlerRotate:
      handlerView = self.rotateImageView;
      break;
  }
  
  switch (position) {
    case CHTStickerViewPositionTopLeft:
      handlerView.center = origin;
      handlerView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
      break;
    case CHTStickerViewPositionTopRight:
      handlerView.center = CGPointMake(origin.x + size.width, origin.y);
      handlerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
      break;
    case CHTStickerViewPositionBottomLeft:
      handlerView.center = CGPointMake(origin.x, origin.y + size.height);
      handlerView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
      break;
    case CHTStickerViewPositionBottomRight:
      handlerView.center = CGPointMake(origin.x + size.width, origin.y + size.height);
      handlerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
      break;
  }
}

@end
