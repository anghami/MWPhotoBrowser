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
    UILabel *_label;
    NSString* _anghamiCaption;
}
@end

@implementation MWCaptionView

- (id)initWithPhoto:(id<MWPhoto>)photo {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 44)]; // Random initial frame
    if (self) {
        self.userInteractionEnabled = NO;
        _photo = photo;
        self.backgroundColor = [UIColor clearColor];
        [self setupCaption];
    }
    return self;
}

- (id)initWithCaption:(NSString *)caption {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 44)]; // Random initial frame
    if (self) {
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        _anghamiCaption = caption;
        [self setupCaption];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    
    CGSize textSize = [_label.text boundingRectWithSize:CGSizeMake(size.width - labelPadding*2, self.maxHeight)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName:_label.font}
                                                context:nil].size;
    return CGSizeMake(size.width, textSize.height + labelPadding * 2);
}

- (void)setupCaption {
    _label = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(labelPadding, 0,
                                                       self.bounds.size.width-labelPadding*2,
                                                      self.bounds.size.height))];
    _label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _label.opaque = NO;
    _label.backgroundColor = [UIColor clearColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.adjustsFontSizeToFitWidth = YES;
    _label.minimumFontSize = 10;
    _label.numberOfLines = 0;
    _label.textColor =  [UIColor whiteColor];
    _label.font = IS_IPAD() ? [UIFont systemFontOfSize:17] :[UIFont systemFontOfSize:14];
    if(_anghamiCaption)
        _label.text = _anghamiCaption;
    
    else if ([_photo respondsToSelector:@selector(caption)]) {
        _label.text = [_photo caption] ? [_photo caption] : @" ";
    }
    [self addSubview:_label];
}


@end
