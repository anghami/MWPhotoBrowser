//
//  ZoomingScrollView.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWPhotoProtocol.h"

@class MWPhotoBrowser, MWPhoto, MWCaptionView;

@interface MWImageAndCaptionScrollView : UIScrollView <UIScrollViewDelegate> {

}

@property () NSUInteger index;
@property (nonatomic) id <MWPhoto> photo;
@property (nonatomic, strong) MWCaptionView *captionView;
@property (nonatomic, weak) UIButton *selectedButton;
@property (nonatomic, weak) UIButton *playButton;

- (id)initWithPhotoBrowser:(MWPhotoBrowser *)browser;
- (void)displayImage;
- (void)displayImageFailure;
- (void)prepareForReuse;
- (BOOL)displayingVideo;
- (void)setImageHidden:(BOOL)hidden;
- (void) performLayout;

@end
