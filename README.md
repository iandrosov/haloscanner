haloscanner
===========

Native iOS Scanner Cordova 3.3.0 Plugin for hybrid applications. Supports Infinite Peripherals scanner devices. 
This plugin is created with Apache Cordova 3.3.0, assuming that all Cordova plugin and been set up will start with actual plugin creation. For Cordova setup refer to http://cordova.apache.org.

Get Started with Scanner plugin

1. Download Infinate Perifirals Unversal SDK v1.82, this will require registration for Developer Portal and sign the basic NDA to get to download page.
Download SDK file - DTDevices-iOS_2013-10-29_v1.82_Universal_XCode5

2. Add required Framework to project - ExternalAccessory.framework

3. Add scanner SDK DTDevices related files to project
  * Create InfineaSDK Group in project
  * Copy DTDevice.h and libdtdev.a files into new SDK group

   If you find that project has errors then it is effect of a bug.  
   XCode 5 has a bug for adding new files to project described here how to fix that:  
   https://devforums.apple.com/message/898557#898557  remove extra garbage / \ that xcode places in Library search paths.

4. Add Supported External Accessory Products items to project plist property file
Add 4 items

```
com.datecs.linea.pro.bar
com.datecs.linea.pro.msr
com.datecs.iserial.communication
com.datecs.pinpad
```

5. Create basic Plugin IPCardScanner class derive from CDVPlugin to manage delegate and device interface. When .m .h files are generated they have incorrect import <Cordova/Cordova.h> fix it by replacing that with import “CDV.h” for plugin development. 

6. Include DTDevice.h file.
Your header file will look like this now.

```objective-c
#import "CDV.h"
#import "DTDevices.h"

@interface IPCardScanner : CDVPlugin {
    DTDevices *dtdev;
}

@end
```

7. Create native Plugin interface methods for JScript to handle device notifications to HTML side

```
-(void) initScanner:(CDVInvokedUrlCommand*)command;
-(void) scanBarcode:(NSString*)num;
-(void) scanPaymentCard:(NSString*)num;
-(void) scannerConect:(NSString*)num;
-(void) scannerBattery:(NSString*)num;
```

   Now the plugin interface will look like this:

```
#import "CDV.h"
#import "DTDevices.h"

@interface IPCardScanner : CDVPlugin {
    DTDevices *dtdev;
}

// Cordova command method initialize Scanner device
-(void) initScanner:(CDVInvokedUrlCommand*)command;

-(void) scanBarcode:(NSString*)num;
-(void) scanPaymentCard:(NSString*)num;
-(void) scannerConect:(NSString*)num;
-(void) scannerBattery:(NSString*)num;

@end
```

8. Implement DTDevices interfaces for card scan and magnetic swipe in plugin PICardScanner. Now we write some Objective-c code to implement interface methods we defined. IN this plugin we used 2 Cordova methods to pass data events back nad force for native to web layer.

Command method - Java Script calling native method.
initScanner:(CDVInvokedUrlCommand*)command - this is more of a reply to method call. this method is invoked from JavaScript via Cordova interface and reply is sent back as a command.

cordova.exec(onSuccessScan, onErrorScan, "PICardScanner", "initScanner", []);

In this case onSuccessScan and onErrorScan is javascript asynchronous response handler methods. These methods will be called when initScanner native methods returns. This initialization method is called by our HTML page to start the scanner device.

Native Method Initiating a call to JavaScript function using WebView object

NSString *jsStatement = [NSString stringWithFormat:@"onSuccessScanBarcode('%@');", num];
[self.webView stringByEvaluatingJavaScriptFromString:jsStatement];
[self.viewController dismissViewControllerAnimated:YES completion:nil];

This is a way to call JavaScript from Native code. 
in our implementation for each native plugin method we will call a corresponding JavaScript function and perform some action on the UI

Scanner Device Notification Methods

Our mobile scanner device Universal SDK handles various attachments from Infinate Peripherals for this example we are using iPad scanner device attachment Infinea Tab 4 that has dual function to scan barcodes and magnetic strip on credit cards.
We need to implement following methods in our plugin

-(void)barcodeData:(NSString *)barcode type:(int)type
- (void)magneticCardData:(NSString *)track1 track2:(NSString *)track2 track3:(NSString *)track3
-(void)connectionState:(int)state


