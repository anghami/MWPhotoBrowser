//
//  MWCaptionView.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 30/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MWCommon.h"
#import "MWCaptionView.h"
#import "MWPhoto.h"

static const CGFloat labelPadding = 10;

// Private
@interface MWCaptionView () {
    id <MWPhoto> _photo;
    NSString* _anghamiCaption;
}
@end

@implementation MWCaptionView

- (id)initWithPhoto:(id<MWPhoto>)photo {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 44)]; // Random initial frame
    if (self) {
        _photo = photo;
        self.backgroundColor = [UIColor clearColor];
        [self setupCaption];
    }
    return self;
}

- (id)initWithCaption:(NSString *)caption {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 44)]; // Random initial frame
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _anghamiCaption = caption;
        [self setupCaption];
    }
    return self;
}


- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat maxHeight = 9999;
    if (self.numberOfLines > 0) maxHeight = self.font.leading*self.numberOfLines;
    CGSize textSize = [self.text boundingRectWithSize:CGSizeMake(size.width - labelPadding*2, maxHeight)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName:self.font}
                                                context:nil].size;
    return CGSizeMake(size.width, textSize.height + labelPadding * 2);
}

- (void)setupCaption {
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    self.textAlignment = NSTextAlignmentLeft;
    self.textColor =  [UIColor whiteColor];
    self.userInteractionEnabled = YES;
    self.font = IS_IPAD() ? [UIFont systemFontOfSize:17] :[UIFont systemFontOfSize:14];
    self.numberOfLines = 0;
    
    if(_anghamiCaption)
        self.text = _anghamiCaption;
    else if ([_photo respondsToSelector:@selector(caption)]) {
        self.text = [_photo caption] ? [_photo caption] : @" ";
    }
}

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0, 5, 0, 5};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}


@end
