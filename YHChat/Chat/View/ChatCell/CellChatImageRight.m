//
//  CellChatImageRight.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/22.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellChatImageRight.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>
#import <HYBMasonryAutoCellHeight/UITableViewCell+HYBMasonryAutoCellHeight.h>
#import "YHChatModel.h"
#import "UIImage+Extension.h"
#import "YHPhotoBrowserView.h"
#import "YHChatImageView.h"

@interface CellChatImageRight()<YHPhotoBrowserViewDelegate>

@property (nonatomic,strong) YHChatImageView *imgvContent;
@end

@implementation CellChatImageRight

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    _imgvContent = [YHChatImageView new];
    _imgvContent.isReceiver = YES;
    UIImage *oriImg = [UIImage imageNamed:@"chat_img_defaultPhoto"];
    _imgvContent.userInteractionEnabled = YES;
    [_imgvContent addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureOnContent:)]];
    _imgvContent.image = [UIImage imageArrowWithSize:oriImg.size image:oriImg isSender:YES];
    [self.contentView addSubview:_imgvContent];
    
    WeakSelf
    _imgvContent.retweetImageBlock = ^(UIImage *image){
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(retweetImage:inRightCell:)]) {
            [weakSelf.delegate retweetImage:image inRightCell:weakSelf];
        }
    };
    
    _imgvContent.withDrawImageBlock = ^(UIImage *image){
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(withDrawImage:inRightCell:)]) {
            [weakSelf.delegate withDrawImage:image inRightCell:weakSelf];
        }
    };
    [self layoutUI];
}

- (void)layoutUI{
    WeakSelf
    [self layoutCommonUI];
    
    [self.lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.imgvAvatar.mas_left).offset(-10);
    }];
    
    [self.imgvAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.contentView).offset(-5);
    }];
    
    [_imgvContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.lbName.mas_bottom).offset(5);
        make.right.equalTo(weakSelf.imgvAvatar.mas_left).offset(-5);
        make.size.mas_equalTo(CGSizeMake(113, 113));
    }];
    
    [self.activityV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.imgvContent.mas_centerY);
        make.right.equalTo(weakSelf.imgvContent.mas_left).offset(-5);
        make.width.height.mas_equalTo(20);
    }];
    
    [self.imgvSendMsgFail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.imgvContent.mas_centerY);
        make.right.equalTo(weakSelf.imgvContent.mas_left).offset(-5);
        make.width.height.mas_equalTo(20);
    }];
    
    self.hyb_lastViewInCell = _imgvContent;
    self.hyb_bottomOffsetToCell = 5;
}

#pragma mark - Super

- (void)onAvatarGesture:(UIGestureRecognizer *)aRec{
    [super onAvatarGesture:aRec];
    //    if (aRec.state == UIGestureRecognizerStateEnded) {
    //        if (_delegate && [_delegate respondsToSelector:@selector(tapRightAvatar:)]) {
    //            [_delegate tapRightAvatar:nil];
    //        }
    //    }
}

- (void)onImgSendMsgFailGesture:(UIGestureRecognizer *)aRec{
    [super onImgSendMsgFailGesture:aRec];
    //    if (aRec.state == UIGestureRecognizerStateEnded) {
    //        if(_delegate && [_delegate respondsToSelector:@selector(tapSendMsgFailImg)]){
    //            [_delegate tapSendMsgFailImg];
    //        }
    //    }
}

- (void)setupModel:(YHChatModel *)model{
    [super setupModel:model];
    self.lbName.text    = self.model.speakerName;
    self.lbTime.text    = self.model.createTime;
    [self.imgvAvatar sd_setImageWithURL:self.model.speakerAvatar placeholderImage:[UIImage imageNamed:@"common_avatar_80px"]];
    
    //消息图片下载
    if (self.model.msgContent && self.model.msgType == 1) {
        NSURL *url = [self getImageUrl];
        [_imgvContent sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"chat_img_defaultPhoto"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            
//            [self updateImageCellHeightWith:image maxSize:CGSizeMake(200, 200)];
            
        }];
    }
}

//更新Cell高度
- (void)updateImageCellHeightWith:(UIImage *)image maxSize:(CGSize)maxSize{
     WeakSelf
    CGSize size = [UIImage handleImgSize:image.size maxSize:maxSize];
    image = [UIImage imageArrowWithSize:size image:image isSender:YES];
    weakSelf.imgvContent.image = image;
    
    [_imgvContent mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.lbName.mas_bottom).offset(5);
        make.right.equalTo(weakSelf.imgvAvatar.mas_left).offset(-10);
        make.size.mas_equalTo(image.size);
    }];
}

#pragma mark - Private
//获取消息内容图片
- (NSURL *)getImageUrl{
    NSString *picUrlStr = [self.model.msgContent stringByReplacingOccurrencesOfString:@"img[" withString:@""];
    picUrlStr = [picUrlStr stringByReplacingOccurrencesOfString:@"]" withString:@""];
    NSURL *url = [NSURL URLWithString:picUrlStr];
    return url;
}

#pragma mark - Gesture
- (void)gestureOnContent:(UIGestureRecognizer *)aGes{
    if (aGes.state == UIGestureRecognizerStateEnded) {
        
        YHPhotoBrowserView *browser = [[YHPhotoBrowserView alloc] init];
        browser.currentImageView = _imgvContent;
        browser.delegate = self;
        [browser show];
    }
}

#pragma mark - @protocol YHPhotoBrowserViewDelegate

- (NSURL *)photoBrowser:(YHPhotoBrowserView *)browser highQualityImageURLForIndex:(NSInteger)index
{
    return [self getImageUrl];
}

- (UIImage *)photoBrowser:(YHPhotoBrowserView *)browser placeholderImageForIndex:(NSInteger)index
{
    return _imgvContent.image;
}

#pragma mark - Life
- (void)dealloc{
    //DDLog(@"%s dealloc",__func__);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
