//
//  GrowingTextViewExampleViewController.m
//
//  Created by Hans Pinckaers on 29-06-10.
//
//	MIT License
//
//	Copyright (c) 2011 Hans Pinckaers
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

//#define USE_TEXTVIEW_AS_LABEL

#import "GrowingTextViewExampleViewController.h"
#import <Aniways/AWTextViewLabel.h>
#import <Aniways/AWLabel.h>
#import <Aniways/AWIconOnDemandButton.h>
#import <Aniways/NSString+aniways.h>

@interface GrowingTextViewExampleViewController(){
    UIImage *_messageBubbleBlue;
    float _screenWidth;
    UIImageView* _messageBackgroundImageView;
#ifdef	USE_TEXTVIEW_AS_LABEL
    AWTextViewLabel* _messageLabel;
#else
    AWLabel* _messageLabel;
#endif
    
}
@end

@implementation GrowingTextViewExampleViewController


-(id)init
{
	self = [super init];
	if(self){
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillShow:)
													 name:UIKeyboardWillShowNotification
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillHide:)
													 name:UIKeyboardWillHideNotification
												   object:nil];
	}
	
	return self;
}



// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor colorWithRed:219.0f/255.0f green:226.0f/255.0f blue:237.0f/255.0f alpha:1];
	
    _messageBubbleBlue = [[UIImage imageNamed:@"MessageBubbleBlue"] resizableImageWithCapInsets: UIEdgeInsetsMake(15,20,15,20)];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    _screenWidth = screenRect.size.width;
    
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, 320, 40)];
    
	textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, 210, 40)];
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	textView.minNumberOfLines = 1;
	textView.maxNumberOfLines = 6;
	textView.returnKeyType = UIReturnKeyGo; //just as an example
	textView.font = [UIFont systemFontOfSize:15.0f];
	textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];
    textView.placeholder = @"Message";
    
    _messageBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _messageBackgroundImageView.userInteractionEnabled = YES;
    [self.view addSubview:_messageBackgroundImageView];
    
#ifdef USE_TEXTVIEW_AS_LABEL
    _messageLabel = [[AWTextViewLabel alloc] initWithFrame:CGRectZero];
    _messageLabel.editable = NO;
    _messageLabel.dataDetectorTypes = UIDataDetectorTypeAll;
    _messageLabel.scrollEnabled = NO;
    [_messageLabel setContentInset:UIEdgeInsetsMake(-8, 0, 0, 0)];
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.font = [UIFont systemFontOfSize:16];
    [_messageBackgroundImageView addSubview:_messageLabel];
#else
    _messageLabel = [[AWLabel alloc] initWithFrame:CGRectZero];
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.numberOfLines = 0;
    _messageLabel.lineBreakMode = UILineBreakModeWordWrap;
    _messageLabel.font = [UIFont systemFontOfSize:16];
    [_messageBackgroundImageView addSubview:_messageLabel];
#endif
    
    
    
    
    [self.view addSubview:containerView];
	
    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(5, 0, 218, 40);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [containerView addSubview:imageView];
    [containerView addSubview:textView];
    [containerView addSubview:entryImageView];
    
    UIImage *sendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    
	UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	doneBtn.frame = CGRectMake(containerView.frame.size.width - 99, 8, 63, 27);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	[doneBtn setTitle:@"Send" forState:UIControlStateNormal];
    
    [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[doneBtn addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
    [doneBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
	[containerView addSubview:doneBtn];
    
    AWIconOnDemandButton *iconBtn = [AWIconOnDemandButton buttonWithType:UIButtonTypeCustom];
    iconBtn.textview = (AWTextView*)textView.internalTextView;
    iconBtn.frame = CGRectMake(containerView.frame.size.width - 32, 8, 25, 27);
    iconBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [iconBtn setImage:[UIImage imageNamed:@"s_aniways_ebp_icons_button.png"] forState:UIControlStateNormal];
    [[iconBtn layer] setCornerRadius:8.0f];
    [[iconBtn layer] setMasksToBounds:YES];
    [[iconBtn layer] setBorderWidth:1.0f];
    [[iconBtn layer] setBorderColor:[UIColor grayColor].CGColor];
    [iconBtn addTarget:self action:@selector(iconButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    iconBtn.tag = 0;
    
	[containerView addSubview:iconBtn];
    
    
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

-(void)iconButtonClicked:(id)sender{
    AWIconOnDemandButton* button = (AWIconOnDemandButton*) sender;
    if(button.tag == 0){
        [button setImage:[UIImage imageNamed:@"s_aniways_ebp_keyboard_button.png"] forState:UIControlStateNormal];
        button.tag = 1;
    }
    else{
        [button setImage:[UIImage imageNamed:@"s_aniways_ebp_icons_button.png"] forState:UIControlStateNormal];
        button.tag = 0;
    }
}


-(void)sendMessage
{
    _messageLabel.text = textView.text;
    textView.text = nil;
#ifdef USE_TEXTVIEW_AS_LABEL
    float textViewMargin = 16.0;
    CGSize messageSize = [_messageLabel.text aniwaysSizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(180, CGFLOAT_MAX)];
    _messageBackgroundImageView.frame = CGRectMake(_screenWidth - messageSize.width - 35, 10, messageSize.width + 35, messageSize.height + 12);
    _messageBackgroundImageView.image = _messageBubbleBlue;
    
    _messageLabel.frame = CGRectMake(10, 5, messageSize.width + 16, messageSize.height + textViewMargin);
#else
    CGSize messageSize = [_messageLabel.text aniwaysSizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(180, CGFLOAT_MAX)];
    _messageBackgroundImageView.frame = CGRectMake(_screenWidth - messageSize.width - 35, 10, messageSize.width + 35, messageSize.height + 12);
    _messageBackgroundImageView.image = _messageBubbleBlue;
    
    _messageLabel.frame = CGRectMake(13, 5, messageSize.width, messageSize.height);
#endif
    
}

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	containerView.frame = containerFrame;
	
	// commit animations
	[UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	containerView.frame = containerFrame;
	
	// commit animations
	[UIView commitAnimations];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	containerView.frame = r;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



@end
