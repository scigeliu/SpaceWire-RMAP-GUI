//
//  GSRMainController.m
//  GUISpaceWireRMAP
//
//  Created by 湯浅 孝行 on 11/10/26.
//  Copyright 2011年 ISAS. All rights reserved.
//

#import "GSRMainController.h"
#import "Utility.h"

#import "RMAPPacketUtilityViewController.h"
#import "RMAPCRCViewController.h"

@implementation GSRMainController


class CheckUpdateThread : public CxxUtilities::Thread {
private:
	GSRMainController* mainController;

public:
	static std::string DefaultDownloadURL;

public:
	bool versionFileIsValid;
	uint32_t latestVersion;
	std::string downloadURL;

public:
	CheckUpdateThread(GSRMainController* mainController){
		this->mainController=mainController;
	}
	
public:
	void run(){
		NSURL *theURL = [NSURL URLWithString:@"https://galaxy.astro.isas.jaxa.jp/~yuasa/SpaceWire/versions/SpaceWireRMAPGUI.version"];
		NSURLRequest *req=[NSURLRequest requestWithURL:theURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:1];
		NSURLResponse *resp;
		NSError *err;
		
		// 同期的な呼び出し。sendSynchronousRequestを使っているのが特徴です
		NSData *result = [NSURLConnection sendSynchronousRequest:req
											   returningResponse:&resp
														   error:&err];
		
		using namespace std;
		string str((const char*)[result bytes],[result length]);
		
		analyzeDonwloadedText(str);
		
		if(versionFileIsValid){
			if(isNewVersionAvailable()){
				if(downloadURL==""){
					downloadURL=DefaultDownloadURL;
				}
				cout << "New version is available." << endl;
				sleep(1000);
				[mainController showUpdateNotificationWindow];
			}else{
				cout << "No new version." << endl;
			}
		}else{
			cout << "Version file is invalid." << endl;
		}
	}
	
	void analyzeDonwloadedText(std::string str){
		using namespace std;
		using namespace CxxUtilities;
		vector<string> lines=String::splitIntoLines(str);
		versionFileIsValid=false;
		for(size_t i=0;i<lines.size();i++){
			if(String::contains(lines[i],"LatestVersion")){
				try{
					latestVersion=String::toUInt32(String::split(lines[i]," ")[1]);
					versionFileIsValid=true;
				}catch(...){
					versionFileIsValid=false;
				}
			}
			if(String::contains(lines[i],"DownloadURL")){
				try{
					downloadURL=String::split(lines[i]," ")[1];
				}catch(...){
					downloadURL="";
				}
			}
		}
	}
	
	bool isNewVersionAvailable(){
		if(SpaceWireRMAPGUIVersion::Version<latestVersion){
			return true;
		}else{
			return false;
		}
	}
};

std::string CheckUpdateThread::DefaultDownloadURL("https://galaxy.astro.isas.jaxa.jp/~yuasa/SpaceWire/");

bool isFirstMessage;

- (id)init
{
    self = [super init];
    if (self) {
        isSpaceWireIFSet_=false;
		previousTime=[[NSString alloc] init];
		ud = [NSUserDefaults standardUserDefaults];
		isFirstMessage=true;
		logWindowIsDisplayed=false;
    }
    return self;
}

- (NSUserDefaults*)getNSUserDefaults{
	return ud;
}

- (void)notifyCompletionOfLaunching{
	[rmapCRCViewController applicationFinishedLaunching];
	[rmapPacketUtilityViewController applicationFinishedLaunching];
	checkUpdateThread=new CheckUpdateThread(self);
	checkUpdateThread->start();
}

- (void)saveDefaults{
	using namespace std;
	[self addMessage:@"Saving default parameters."];
	[ud setInteger:SpaceWireRMAPGUIVersion::Version forKey:@"DefaultFileIsValid"];
	[ud setInteger:[mainTab indexOfTabViewItem:[mainTab selectedTabViewItem]] forKey:@"IndexOfSelectedTab"];
	[spaceWireIFViewController saveDefaults];
	[spaceWireViewController saveDefaults];
	[rmapViewController saveDefaults];
	[rmapPacketUtilityViewController saveDefaults];
	[rmapCRCViewController saveDefaults];
}

- (void)restoreDefaults{
	using namespace std;
	if([ud integerForKey:@"DefaultFileIsValid"]==SpaceWireRMAPGUIVersion::Version){
		[self addMessage:@"Restoring default parameters."];
		[mainTab selectTabViewItemAtIndex:[ud integerForKey:@"IndexOfSelectedTab"]];
		[spaceWireIFViewController restoreDefaults];
		[spaceWireViewController restoreDefaults];
		[rmapViewController restoreDefaults];
		[rmapPacketUtilityViewController restoreDefaults];
		[rmapCRCViewController restoreDefaults];
	}else{
		[self addMessage:@"Preference file is newly created for saving default parameters."];
	}
	[self notifyCompletionOfLaunching];
}

- (IBAction)clearLogButton:(id)sender {
	[messageCell selectAll:nil];
	[messageCell deleteBackward:nil];
}

- (IBAction)saveLogButton:(id)sender {
}

- (NSString*)getDateTimeString {
    // 今日の日付を取得
    NSDate* today = [NSDate date];
    // 現在のカレンダーを取得
    NSCalendar* calendar = [NSCalendar currentCalendar];
    // 年月日と曜日を組み立て
    NSCalendarUnit flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents* components = [calendar components:flags fromDate:today];
	
    NSInteger year    =    [components year    ];
    NSInteger month   =    [components month   ];
    NSInteger day     =    [components day     ];
    NSInteger hour    =    [components hour    ];
    NSInteger min     =    [components minute  ];
    NSInteger sec     =    [components second  ];
    NSInteger wday    =    [components weekday ];
	
    NSString* str = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d",
					 year, month, day, hour, min, sec];
	return str;
}

- (void)addMessage:(NSString*)text withColor:(NSColor*)color{
	NSRange	wholeRange;
	NSRange	endRange;
	NSRange newTextRange;
	
	[messageCell selectAll:nil];
	wholeRange = [messageCell selectedRange];
	endRange = NSMakeRange(wholeRange.length, 0);
	unsigned long previousLength=wholeRange.length;
	[messageCell setSelectedRange:endRange];
		
	if(isFirstMessage){
		[messageCell setFont:[NSFont fontWithName:@"Courier" size:12]]; 
	}
	
	//insert time?
	NSString* currentTime=[self getDateTimeString];
	if(![currentTime isEqualToString:previousTime]){
		if(!isFirstMessage){
			[messageCell insertText:@"\n"];
		}
		[messageCell insertText:currentTime];
		[messageCell insertText:@"\n"];
	}
	[messageCell insertText:text];
	[messageCell insertText:@"\n"];
	
	//set text color
	[messageCell selectAll:nil];
	wholeRange=[messageCell selectedRange];
	unsigned long length2=wholeRange.length-previousLength;
	newTextRange = NSMakeRange(endRange.location, length2);
	[messageCell setTextColor: color range: newTextRange]; 
	[messageCell setSelectedRange:NSMakeRange(wholeRange.length, 0)];

	previousTime=currentTime;
	if(isFirstMessage){
		isFirstMessage=false;
	}
}

- (void)addMessage:(NSString*)text{
	[self addMessage:text withColor:[NSColor whiteColor]];
}

- (void)addMessageString:(std::string)text{
	[self addMessage:[Utility toNSString:text]];
}

- (void)addRedMessage:(NSString*)text{
	[self addMessage:text withColor:[NSColor orangeColor]];
}

- (void)addRedMessageString:(std::string)text{
	[self addMessage:[Utility toNSString:text] withColor:[NSColor orangeColor]];
}


- (void)setSpaceWireIFInstance:(SpaceWireIF*)spwif_{
	spwif=spwif_;
	isSpaceWireIFSet_=true;
}

- (void)removeSpaceWireIFInstance{
	spwif=NULL;
	isSpaceWireIFSet_=false;
}

- (SpaceWireIF*)getSpaceWireIFInstance{
	return spwif;
}

- (bool)isSpaceWireIFSet{
	return isSpaceWireIFSet_;
}

- (void)tryingToDisconnectSpaceWireIF{
	isSpaceWireIFSet_=false;
}

- (double)getDefaultThreadWaitDuraion{
	return 300.0;
}

- (void)spaceWireIFDisconnected{
	[spaceWireIFViewController spaceWireIFDisconnected];
	[self removeSpaceWireIFInstance];
}

- (std::map<std::string,RMAPTargetNode*>*)getRMAPTargetNodes{
	return [rmapTargetNodeController getRMAPTargetNodes];
}

- (NSWindow*)getMainWindow{
	return mainWindow;
}

- (IBAction)aboutMenuSelected:(id)sender {
	/*
	[splashWindow center];
	[splashWindow makeKeyAndOrderFront:mainWindow];
	[splashWindow display];
	 */
	[self ackButtonClicked:nil];
}

- (IBAction)splashWindowClicked:(id)sender {
	[splashWindow orderOut:nil];
}

- (IBAction)ackWindowCloseButtonClicked:(id)sender {
	[ackWindow orderOut:nil];
}

- (IBAction)ackButtonClicked:(id)sender {
	[ackWindow center];
	using namespace std;
	stringstream ss;
	ss << "Version: " << SpaceWireRMAPGUIVersion::Version;
	[ackWindowVersionCell setStringValue:[Utility toNSString:ss.str()]];
	[ackWindow orderFront:splashWindow];
}

- (IBAction)showLogButtonClicked:(id)sender {
	if(logWindowIsDisplayed==false){
		[logWindow setFloatingPanel:NO];
		[logWindow orderFront:mainWindow];
		[showLogWindowButton setTitle:@"Hide log"];
		logWindowIsDisplayed=true;
	}else{
		[logWindow  orderOut:nil];
		[showLogWindowButton setTitle:@"Show log"];
		logWindowIsDisplayed=false;
	}
}

- (IBAction)logWindowTransparencyChanged:(id)sender {
	NSSlider* slider=(NSSlider*)sender;
	[logWindow setAlphaValue:[slider floatValue]];
}

- (void)showUpdateNotificationWindow{
	[currentVersionField setIntValue:SpaceWireRMAPGUIVersion::Version];
	[latestVersionField setIntValue:checkUpdateThread->latestVersion];
	[updateNotificationWindow center];
	[updateNotificationWindow makeKeyAndOrderFront:mainWindow];
	//[updateNotificationWindow orderWindow:NSWindowAbove relativeTo:0];
}

- (IBAction)updateWindowOKButtonClicked:(id)sender {
	[updateNotificationWindow orderOut:nil];
}

- (IBAction)openTheDownloadPageButtonClicked:(id)sender {
	[updateNotificationWindow orderOut:nil];
	
	using namespace std;
	stringstream ss;
	ss << "open " << checkUpdateThread->downloadURL;

	NSTask *task  = [[NSTask alloc] init];
	NSPipe *pipe  = [[NSPipe alloc] init];
	[task setLaunchPath: @"/bin/sh"];
	[task setArguments: [NSArray arrayWithObjects: @"-c", [Utility toNSString:ss.str()], nil]];
	
	[task setStandardOutput: pipe];
	[task launch];
}

@end


/*
 // NSUserDefaultsからデータを読み込む
 NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
 int i = [ud integerForKey:@"KEY_I"];  // KEY_Iの内容をint型として取得
 float f = [ud floatForKey:@"KEY_F"];  // KEY_Fの内容をfloat型として取得
 double d = [ud doubleForKey:@"KEY_D"];  // KEY_Dの内容をdouble型として取得
 BOOL b = [ud boolForKey:@"KEY_B"];  // KEY_Bの内容をBOOL型として取得
 NSString s = [ud stringForKey:@"KEY_S"];  // KEY_Sの内容をNSString型として取得

 // NSUserDefaultsに保存・更新する
 NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
 [ud setInteger:100 forKey:@"KEY_I"];  // int型の100をKEY_Iというキーで保存
 [ud setFloat:1.23 forKey:@"KEY_F"];  // float型の1.23をKEY_Fというキーで保存
 [ud setDouble:1.23 forKey:@"KEY_D"];  // double型の1.23をKEY_Dというキーで保存
 [ud setBool:YES forKey:@"KEY_B"];  // BOOL型のYESをKEY_Bというキーで保存
 [ud setObject:@"あいう" forKey:@"KEY_S"];  // "あいう"をKEY_Sというキーで保存
 [ud synchronize];  // NSUserDefaultsに即時反映させる（即時で無くてもよい場合は不要）
*/