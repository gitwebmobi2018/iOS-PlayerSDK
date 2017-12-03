//
//  ZixiAutocompleteCellTableViewCell.m
//  ZixiPlayerSDKDemo
//
//  Created by zixi on 8/24/17.
//  Copyright © 2017 zixi. All rights reserved.
//

#import "ZixiAutocompleteTableViewCell.h"
#import "TRAutocompleteItemsSource.h"

@implementation ZixiAutocompleteTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateWith:(id <TRSuggestionItem>)item
{
	self.textLabel.text = [item completionText];
}

@end
