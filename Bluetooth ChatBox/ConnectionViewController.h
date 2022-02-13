//
//  ConnectionViewController.h
//  Bluetooth ChatBox
//
//  Created by David 🤴 on 2022/2/8.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConnectionViewController : UIViewController <UITextFieldDelegate, MCSessionDelegate, UITableViewDelegate, UITableViewDataSource, MCBrowserViewControllerDelegate, MCNearbyServiceAdvertiserDelegate>

@property (strong, nonatomic) MCPeerID *peerID;
@property (strong, nonatomic) MCSession *session;
@property (strong, nonatomic) MCNearbyServiceAdvertiser *advertiser;
@property (strong, nonatomic) MCBrowserViewController *browser;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UISwitch *visibilitySwitch;
@property (weak, nonatomic) IBOutlet UIButton *browseDevices;
@property (weak, nonatomic) IBOutlet UIButton *disconnectSession;
-(IBAction)disconnect:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tblConnectedDevices;
-(IBAction)browseForDevices:(id)sender;
@property (strong, nonatomic) NSMutableArray *arrConnectedDevices;

@end

NS_ASSUME_NONNULL_END
