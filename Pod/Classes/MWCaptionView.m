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
#import "NSString+Utils.h"
#import "PostPhotoLikeLoader.h"

#define labelPadding  10
#define likesAndDateViewHeight 52

@interface ResizableLabel : UILabel
@end

@implementation ResizableLabel

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0, labelPadding, 0, labelPadding};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
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
@end

// Private
@interface MWCaptionView () {
    id <MWPhoto> _photo;
    __strong Photo* _anghamiPhoto;
    
    ResizableLabel *_captionLabel;
    UIView *_likesAndDateView;
    UILabel *_dateLabel;
    UILabel *_likesLabel;
    EX2GlowButton *_likeButton;
}
@end

@implementation MWCaptionView

#pragma mark - init

- (id)initWithPhoto:(id<MWPhoto>)photo {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 44)]; // Random initial frame
    if (self) {
        _photo = photo;
        self.backgroundColor = [UIColor clearColor];
        [self setupCaption];
    }
    return self;
}

- (id)initWithAnghamiPhoto:(Photo *)photo{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 44)]; // Random initial frame
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _anghamiPhoto = photo;
        [self setupLikesAndDateView];
        [self setupCaption];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    // sizing the caption and likesAndDateView
    _captionLabel.size = [_captionLabel sizeThatFits:size];
    _likesAndDateView.width = _captionLabel.width;
    return CGSizeMake(_captionLabel.width, _captionLabel.height + likesAndDateViewHeight);
}
#pragma mark - initial Setup
- (void)setupCaption {
    // init caption & frame
    _captionLabel = [[ResizableLabel alloc] init];
    [self addSubview:_captionLabel];
    _captionLabel.y = _likesAndDateView.bottom;
    // Customize
    _captionLabel.font = IS_IPAD() ? [UIFont systemFontOfSize:17] :[UIFont systemFontOfSize:14];
    _captionLabel.numberOfLines = 0;
    _captionLabel.textColor = [UIColor whiteColor];
    if(_anghamiPhoto.caption)
        _captionLabel.text = n2blank(_anghamiPhoto.caption);
    else if ([_photo respondsToSelector:@selector(caption)]) {
        _captionLabel.text = [_photo caption] ? [_photo caption] : @" ";
    }
    _captionLabel.textAlignment = [_captionLabel.text isArabic] ? NSTextAlignmentRight : NSTextAlignmentLeft;
}

- (void) setupLikesAndDateView{
    _likesAndDateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, likesAndDateViewHeight)];
    [_likesAndDateView addBottomLine];
    [self addSubview:_likesAndDateView];
}

#pragma mark - fomatted strings

-(NSString *)formattedDate:(NSString *)date{
    if(date.length>0)
    {
        // format date
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSDate *captionDate= [dateFormatter dateFromString:date];
        dateFormatter.dateFormat = @"d MMM yyyy";
        return [dateFormatter stringFromDate:captionDate];
    }
    return @"";
}

-(NSString *)formattedLikes:(NSUInteger)likes{
    if(likes > 1)
        return [NSString stringWithFormat:NSLocalizedString(@"%@ likes", nil), [NSString abbreviatedCountForCount:likes]];
    else if(likes == 1)
        return NSLocalizedString(@"1 like", nil);
    return @"";
}

#pragma mark - layout
- (void) layoutDateLabel{
    if(!_dateLabel){
        _dateLabel= [[UILabel alloc] init];
        _dateLabel.text = [self formattedDate:_anghamiPhoto.date];
        _dateLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
        _dateLabel.font = IS_IPAD() ? [UIFont systemFontOfSize:17] :[UIFont systemFontOfSize:14];
        [_dateLabel sizeToFit];
        [_likesAndDateView addSubview:_dateLabel];
    }
    [_dateLabel centerVertically];
    if(IS_IOS9() && IsArabic)
        _dateLabel.left = _likesAndDateView.left + labelPadding;
    else
    _dateLabel.right = _likesAndDateView.right - labelPadding;
}

- (void) layoutLikeButton{
    if(!_likeButton){
        _likeButton = [[EX2GlowButton alloc] init];
        [_likeButton addTarget:self action:@selector(updateLikeState) forControlEvents:UIControlEventTouchUpInside];
        _likeButton.size = CGSizeMake(36, 32);
        [_likesAndDateView addSubview:_likeButton];
    }
    [_likeButton centerVertically];
    if(IS_IOS9() && IsArabic)
        _likeButton.right = _likesAndDateView.right - labelPadding;
    else
        _likeButton.left = _likesAndDateView.left + labelPadding;
    NSString * imageName = _anghamiPhoto.isLiked ? @"PhotoLiked" : @"PhotoLike";
    [_likeButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (void) layoutLikesLabel{
    if(!_likesLabel){
        _likesLabel = [[UILabel alloc] init];
        _likesLabel.textColor = [UIColor whiteColor];
        _likesLabel.font = IS_IPAD() ? [UIFont systemFontOfSize:17] :[UIFont systemFontOfSize:14];
        [_likesAndDateView addSubview:_likesLabel];
    }
    _likesLabel.text = [self formattedLikes:_anghamiPhoto.numberOflikes];
    [_likesLabel sizeToFit];
    [_likesLabel centerVertically];
    if(IS_IOS9() && IsArabic)
        _likesLabel.right = _likeButton.left - labelPadding;
    else
        _likesLabel.left = _likeButton.right + labelPadding;
}


- (void)layoutSubviews{
    [self layoutDateLabel];
    [self layoutLikeButton];
    [self layoutLikesLabel];
    [super layoutSubviews];
}

#pragma mark - actions
- (void)updateLikeState{
    // no Id can't like/unlike
    if(!_anghamiPhoto.iD){
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"Oops!", nil) message:NSLocalizedString(@"Something went wrong", nil) theme:BlockAlertViewTheme_Flat disableLinks:YES];
        [alert setCancelButtonWithTitle:OK_STRING block:nil];
        [alert showInQueue];
        return;
    }
    
    _anghamiPhoto.isLiked = !_anghamiPhoto.isLiked;
    _anghamiPhoto.numberOflikes = _anghamiPhoto.isLiked ?  _anghamiPhoto.numberOflikes+ 1 : _anghamiPhoto.numberOflikes -1;
    [self reportLikeState:_anghamiPhoto.isLiked];
    
    [self layoutIfNeeded];
    [self setNeedsLayout];
}

- (void) reportLikeState:(BOOL) isLiked{
    
    NSString * action = isLiked ? @"like" : @"unlike";
    PostPhotoLikeLoader * loader = [[PostPhotoLikeLoader alloc] initWithParams:@{
                                                                                 @"id": _anghamiPhoto.iD,
                                                                                 @"action": action
                                                                                 }];
    [loader startLoad];
}

@end
