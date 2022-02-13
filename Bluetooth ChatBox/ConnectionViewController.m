//
//  ConnectionViewController.m
//  Bluetooth ChatBox
//
//  Created by David 🤴 on 2022/2/8.
//

#import "ConnectionViewController.h"

@interface ConnectionViewController ()

-(void)sendMessage:(NSNotification*)notification;

@end

@implementation ConnectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _peerID = nil;
    _session = nil;
    _advertiser = nil;
    _browser = nil;
    _name.delegate = self;
    _tblConnectedDevices.delegate = self;
    _tblConnectedDevices.dataSource = self;
    [_visibilitySwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
    [_disconnectSession setEnabled:NO];
    _arrConnectedDevices = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMessage:) name:@"SendMessage" object:nil];
    // Do any additional setup after loading the view.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if (textField.text != nil) {
        _peerID = [[MCPeerID alloc] initWithDisplayName:textField.text];
        _session = [[MCSession alloc] initWithPeer:_peerID];
        _session.delegate = self;
        if (_visibilitySwitch.isOn) {
            _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_peerID discoveryInfo:nil serviceType:@"btcb-again-chat"];
            _advertiser.delegate = self;
            [_advertiser startAdvertisingPeer];
        }
    }
    return YES;
}

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    NSDictionary *dict = @{
        @"data":data,
        @"name":peerID.displayName
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceiveMessage" object:nil userInfo:dict];
}

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
}

-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
}

-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    
}

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    switch (state) {
        case MCSessionStateNotConnected:{
            if ([_arrConnectedDevices count] > 0) {
                NSInteger indexOfPeer = [_arrConnectedDevices indexOfObject:peerID.displayName];
                [_arrConnectedDevices removeObjectAtIndex:indexOfPeer];
            }
            NSLog(@"Oh no.");
            break;
        }
        case MCSessionStateConnecting:{
            break;
        }
        case MCSessionStateConnected:{
            [_arrConnectedDevices addObject:peerID.displayName];
            NSLog(@"That's good.");
            //2022-02-12 22:28:29
        }
    }
    BOOL peerExist = ([session connectedPeers].count != 0);
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tblConnectedDevices reloadData];
        [_disconnectSession setEnabled:peerExist];
        [_name setEnabled:!peerExist];
        [_browseDevices setEnabled:!peerExist];
    });
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(IBAction)disconnect:(id)sender{
    [_session disconnect];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_arrConnectedDevices count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"default"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
    }
    cell.textLabel.text = [_arrConnectedDevices objectAtIndex:indexPath.row];
    return cell;
}

-(void)switchChange:(UISwitch*)sw{
    if (sw.on) {
        [_name setEnabled:YES];
        [_browseDevices setEnabled:YES];
        [_disconnectSession setEnabled:YES];
    } else {
        [_name setEnabled:NO];
        [_browseDevices setEnabled:NO];
        [_disconnectSession setEnabled:NO];
        [_advertiser stopAdvertisingPeer];
    }
}

-(IBAction)browseForDevices:(id)sender{
    if (_peerID != nil) {
        _browser = [[MCBrowserViewController alloc] initWithServiceType:@"btcb-again-chat" session:_session];
        _browser.delegate = self;
        [self presentViewController:_browser animated:YES completion:nil];
    }
}

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nullable))invitationHandler{
    NSString *title = [[NSString alloc] initWithFormat:@"%@ wants to connect.", peerID.displayName];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invitation received" message:title preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *accept = [UIAlertAction actionWithTitle:@"Accept" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        invitationHandler(YES, _session);
    }];
    UIAlertAction *deny = [UIAlertAction actionWithTitle:@"Deny" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        invitationHandler(NO, _session);
    }];
    [alert addAction:accept];
    [alert addAction:deny];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler{
    certificateHandler(YES);
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Connected peers";
}

-(void)sendMessage:(NSNotification *)notification{
    NSError *error;
    NSData *messageData = [NSJSONSerialization dataWithJSONObject:[notification userInfo] options:NSJSONWritingPrettyPrinted error:nil];
    [_session sendData:messageData toPeers:_session.connectedPeers withMode:MCSessionSendDataReliable error:&error];
    if (error) {
        NSLog(@"Error: %@\nReason: %@\nSuggestion: %@", error.localizedDescription, error.localizedFailureReason, error.localizedRecoverySuggestion);
    }
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
