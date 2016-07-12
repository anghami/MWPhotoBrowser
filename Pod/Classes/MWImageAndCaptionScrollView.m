//
//  ZoomingScrollView.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <DACircularProgress/DACircularProgressView.h>
#import "MWCommon.h"
#import "MWImageAndCaptionScrollView.h"
#import "MWPhotoBrowser.h"
#import "MWPhoto.h"
#import "MWPhotoBrowserPrivate.h"
#import "UIImage+MWPhotoBrowser.h"
#import "MiniPlayerViewController.h"

// Private methods and properties
@interface MWImageAndCaptionScrollView () {
    
    MWPhotoBrowser __weak *_photoBrowser;
	UIImageView *_photoImageView;
    UIImageView *_loadingError;
    
}

@end

@implementation MWImageAndCaptionScrollView

- (id)initWithPhotoBrowser:(MWPhotoBrowser *)browser {
    if ((self = [super init])) {
        
        // Setup
        _index = NSUIntegerMax;
        _photoBrowser = browser;
        
        // Image view
		_photoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		_photoImageView.contentMode = UIViewContentModeScaleAspectFill;
		_photoImageView.backgroundColor = [UIColor clearColor];
        _photoImageView.image = [ANGArtworkFactory defaultPhotoPlaceHolder];
        _photoImageView.clipsToBounds = YES;
		[self addSubview:_photoImageView];
        
		// Setup
		self.backgroundColor = [UIColor clearColor];
		self.delegate = self;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		self.decelerationRate = UIScrollViewDecelerationRateFast;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.scrollEnabled = YES;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareForReuse {
    [self hideImageFailure];
    self.photo = nil;
    [self.captionView removeFromSuperview];
    [self.artistOverlay removeFromSuperview];
    self.selectedButton = nil;
    self.playButton = nil;
    _photoImageView.hidden = NO;
    _photoImageView.image = [ANGArtworkFactory defaultPhotoPlaceHolder];
    _index = NSUIntegerMax;
}

- (BOOL)displayingVideo {
    return [_photo respondsToSelector:@selector(isVideo)] && _photo.isVideo;
}

- (void)setImageHidden:(BOOL)hidden {
    _photoImageView.hidden = hidden;
}

#pragma mark - Image

- (void)setPhoto:(id<MWPhoto>)photo {
    // Cancel any loading on old photo
    if (_photo && photo == nil) {
        if ([_photo respondsToSelector:@selector(cancelAnyLoading)]) {
            [_photo cancelAnyLoading];
        }
    }
    _photo = photo;
    UIImage *img = [_photoBrowser imageForPhoto:_photo];
    if (img) {
        [self displayImage];
    }
    // we can call it since, caption is set before image.
    // Note: all component in future (strong) should be set before image.
    [self performLayout];
}



// Get and display image
- (void)displayImage {
    
    if (_photo) {
				
		// Get image from browser as it handles ordering of fetching
		UIImage *img = [_photoBrowser imageForPhoto:_photo];
		if (img) {
			// Set image
			_photoImageView.image = img;
			_photoImageView.hidden = NO;
            
		} else  {
            // Show image failure
            [self displayImageFailure];
			
		}
		[self setNeedsLayout];
	}
}

// Image failed so just show black!
- (void)displayImageFailure {
    _photoImageView.image = nil;
    
    // Show if image is not empty
    if (![_photo respondsToSelector:@selector(emptyImage)] || !_photo.emptyImage) {
        if (!_loadingError) {
            _loadingError = [UIImageView new];
            _loadingError.image = [UIImage imageNamed:@"ImageError"];
            _loadingError.userInteractionEnabled = NO;
            _loadingError.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |
            UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
            [_loadingError sizeToFit];
            [self addSubview:_loadingError];
        }
        _loadingError.frame = CGRectMake(floorf((self.bounds.size.width - _loadingError.frame.size.width) / 2.),
                                         floorf((self.bounds.size.height - _loadingError.frame.size.height) / 2),
                                         _loadingError.frame.size.width,
                                         _loadingError.frame.size.height);
    }
}

- (void)hideImageFailure {
    if (_loadingError) {
        [_loadingError removeFromSuperview];
        _loadingError = nil;
    }
}


#pragma mark - Layout

- (void)layoutSubviews {
    
	if (_loadingError)
        _loadingError.frame = CGRectMake(floorf((self.bounds.size.width - _loadingError.frame.size.width) / 2.),
                                         floorf((self.bounds.size.height - _loadingError.frame.size.height) / 2),
                                         _loadingError.frame.size.width,
                                         _loadingError.frame.size.height);
    
    // Super
	[super layoutSubviews];
}

- (void) performLayout{
 
    // needed when page are recycled
    if(!self.captionView.superview)
    {
        [self addSubview:self.captionView];
    }
    if(!self.artistOverlay.superview)
    {
        [self addSubview:self.artistOverlay];
        [self.artistOverlay autolayoutWidthProportionalToParentWidth:1 constant:0];
        [self.artistOverlay autolayoutPinEdge:NSLayoutAttributeLeading toParentEdge:NSLayoutAttributeLeading constant:8];
        [self.artistOverlay autolayoutPinEdge:NSLayoutAttributeTop toParentEdge:NSLayoutAttributeTop constant:appDelegateS.topNavigationController.navigationBar.bottom];
        [self.artistOverlay autolayoutSetAttribute:NSLayoutAttributeHeight toConstant:64];
    }
    
    
    // initial content
    self.contentSize = self.bounds.size;
    
    // Setup photo initial frame
    _photoImageView.frame = CGRectMake(0,0,self.width, self.width);
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _photoImageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    if(DEVICE_IS_IPHONE_5)
        frameToCenter.origin.y += 10;
    else if(DEVICE_IS_IPHONE_4)
        frameToCenter.origin.y += 50;
    
    // Center
    if (!CGRectEqualToRect(_photoImageView.frame, frameToCenter))
        _photoImageView.frame = frameToCenter;
    self.captionView.x = _photoImageView.x;
    self.captionView.y = _photoImageView.bottom;
    
    // Adjust content
    CGFloat newHeight = (self.captionView.bottom + miniPlayerHeight);
    self.contentSize = CGSizeMake(self.contentSize.width, (newHeight - self.contentSize.height) > 0 ? newHeight : self.contentSize.height);
}

@end
