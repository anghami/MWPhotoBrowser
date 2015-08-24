//
//  MWCaptionView.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 30/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoProtocol.h"

@interface MWCaptionView : UITextView

// Init
- (id)initWithPhoto:(id<MWPhoto>)photo;

// Custom Anghami init
- (id)initWithCaption:(NSString *)caption;

// To create your own custom caption view, subclass this view
// and override the following two methods (as well as any other
// UIView methods that you see fit):

// Override -setupCaption so setup your subviews and customise the appearance
// of your custom caption
// You can access the photo's data by accessing the _photo ivar
// If you need more data per photo then simply subclass MWPhoto and return your
// subclass to the photo browsers -photoBrowser:photoAtIndex: delegate method
- (void)setupCaption;

@end
