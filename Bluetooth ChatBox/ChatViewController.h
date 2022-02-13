//
//  ChatViewController.h
//  Bluetooth ChatBox
//
//  Created by David 🤴 on 2022/2/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *message;
@property (weak, nonatomic) IBOutlet UITextView *chatView;
-(IBAction)exportMessage:(id)sender;
-(IBAction)sendMessage:(id)sender;

@end

NS_ASSUME_NONNULL_END
