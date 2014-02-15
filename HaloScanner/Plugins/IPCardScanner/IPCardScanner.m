/*
 
 IPCardScanner.m
 HaloScanner
 
 Copyright (c) 2014 Igor Androsov
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "IPCardScanner.h"
#import <Cordova/CDV.h>

@implementation IPCardScanner


-(UIAlertView *)displayAlert:(NSString *)title message:(NSString *)message
{
    if(alert)
    {
        [alert dismissWithClickedButtonIndex:0 animated:FALSE];
        alert=nil;
    }
    
	alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
	[alert show];
    return alert;
}


#pragma mark - Plugin external methods

-(void) scanBarcode:(NSString*)num {
 
    NSString *jsStatement = [NSString stringWithFormat:@"onSuccessScanBarcode('%@');", num];
    [self.webView stringByEvaluatingJavaScriptFromString:jsStatement];
	[self.viewController dismissViewControllerAnimated:YES completion:nil];
}

-(void) scanPaymentCard:(NSString*)num {
    
    NSString *jsStatement = [NSString stringWithFormat:@"onSuccessScanPaymentCard('%@');", num];
    [self.webView stringByEvaluatingJavaScriptFromString:jsStatement];
	[self.viewController dismissViewControllerAnimated:YES completion:nil];
    
}

-(void) scannerConect:(NSString*)num {

    NSString *jsStatement = [NSString stringWithFormat:@"reportConnectionStatus('%@');", num];
    [self.webView stringByEvaluatingJavaScriptFromString:jsStatement];

}

-(void) scannerBattery:(NSString*)num {

    int percent;
    float voltage;
    
	if([dtdev getBatteryCapacity:&percent voltage:&voltage error:nil])
    {
        NSString *status = [NSString stringWithFormat:@"Bat: %.2fv, %d%%",voltage,percent];
        
        // send to web view
        NSString *jsStatement = [NSString stringWithFormat:@"reportBatteryStatus('%@');", status];
        [self.webView stringByEvaluatingJavaScriptFromString:jsStatement];
        
    }
    
}


#pragma mark - Scanner methods

-(void) initScanner:(CDVInvokedUrlCommand*)command {

    dtdev=[DTDevices sharedDevice];
    [dtdev addDelegate:self];
	[dtdev connect];
    
    //[self displayAlert:@"Device" message:@"Connected init!"];
}

-(void)barcodeData:(NSString *)barcode type:(int)type
{
    //NSString *msg = [NSString stringWithFormat:@"Type: %@ Barcode: %@",[dtdev barcodeType2Text:type],barcode];
    //[self displayAlert:@"Barcode" message:msg];
    
    // Notiy plugin
    [self scanBarcode:barcode];
    
}

-(void)connectionState:(int)state {
	switch (state) {
		case CONN_DISCONNECTED:
		case CONN_CONNECTING:
            
            //[self displayAlert:@"Connect message" message:@"NOT Connected yet!"];
            
            [self scannerConect:@"SCANNER_NOT_CONNECTED"];
            
			break;
		case CONN_CONNECTED:
		{
            //[self displayAlert:@"Connect message" message:@"Connected Device!"];
            
            [self scannerConect:@"SCANNER_CONNECTED"];
            
            [self scannerBattery:nil];
            
			break;
		}
	}
    
}

- (void)magneticCardData:(NSString *)track1 track2:(NSString *)track2 track3:(NSString *)track3
{
    NSDictionary *card=[dtdev msProcessFinancialCard:track1 track2:track2];
    NSString *acct = [card objectForKey:@"accountNumber"];
    
    NSString *nn = [self maskCardNumber:acct]; 
    NSString *res = [NSString stringWithFormat:@"Account: %@ Expiration yyyy: %@",
                     nn,
                     [card  objectForKey:@"expirationYear"]];
    
    //[card objectForKey:@"accountNumber"],
    //[card objectForKey:@"expirationMonth"]
    //[card objectForKey:@"expirationYear"]];
    
    // plugin class pass data back
	[self scanPaymentCard:res];
    
}

- (NSString*)maskCardNumber:(NSString*)acct {

    NSString *lastAcct = [acct substringWithRange:NSMakeRange(acct.length - 4, 4)];
    NSString *nn = [NSString stringWithFormat:@"XXXX XXXX XXXX %@", lastAcct];
    return nn;
    
}

@end
