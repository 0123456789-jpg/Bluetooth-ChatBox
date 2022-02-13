//
//  ChatViewController.m
//  Bluetooth ChatBox
//
//  Created by David 🤴 on 2022/2/8.
//

#import "ChatViewController.h"

@interface ChatViewController ()

-(void)receiveMessage:(NSNotification*)notification;
-(void)writeUserInfo:(NSNotification*)notification;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _message.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage:) name:@"ReceiveMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(writeUserInfo:) name:@"WriteUserInfo" object:nil];
    // Do any additional setup after loading the view.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self sendMessage];
    [textField setText:nil];
    return YES;
}

-(IBAction)exportMessage:(id)sender{
    UIActivityViewController *exportViewController = [[UIActivityViewController alloc] initWithActivityItems:@[@"Text Message",[_chatView.text dataUsingEncoding:NSUTF8StringEncoding]] applicationActivities:nil];
    [self presentViewController:exportViewController animated:YES completion:nil];
}

-(IBAction)sendMessage:(id)sender{
    [_message resignFirstResponder];
    [self sendMessage];
}

-(void)sendMessage{
    NSString *date = [self getCurrentDate];
    NSString *text = _message.text;
    [_chatView setText:[_chatView.text stringByAppendingFormat:@"%@\nThe despicable me wrote:\n%@\n\n", date, text]];
    NSDictionary *messageDict = @{
        @"message":text,
        @"date":date
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SendMessage" object:nil userInfo:messageDict];
    [_message setText:nil];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(void)receiveMessage:(NSNotification *)notification{
    NSString *name = [[notification userInfo] objectForKey:@"name"];
    NSDictionary *messageData = [NSJSONSerialization JSONObjectWithData:[[notification userInfo] objectForKey:@"data"] options:NSJSONReadingMutableContainers error:nil];
    NSString *date = [messageData objectForKey:@"date"];
    NSString *message = [messageData objectForKey:@"message"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_chatView setText:[_chatView.text stringByAppendingFormat:@"%@\nMy noble friend %@ wrote:\n%@\n\n", date, name, message]];
    });
}

-(NSString*)getCurrentDate{
    NSDateFormatter *date = [[NSDateFormatter alloc] init];
    [date setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *dateString = [date stringFromDate:[NSDate date]];
    return dateString;
}

-(void)writeUserInfo:(NSNotification *)notification{
    NSString *info = [[notification userInfo] objectForKey:@"info"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_chatView setText:[_chatView.text stringByAppendingString:info]];
    });
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
