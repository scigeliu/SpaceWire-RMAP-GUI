//
//  RMAPTargetNodeController.m
//  GUISpaceWireRMAP
//
//  Created by 湯浅 孝行 on 11/12/05.
//  Copyright 2011年 ISAS. All rights reserved.
//

#import "RMAPTargetNodeController.h"

@implementation RMAPTargetNodeController

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
		isRegisteredRMAPTargetNodesWindowDisplayed=false;
    }
    
    return self;
}

- (void)updateSubwindow{
	using namespace std;
	stringstream ss;
	if(rmapTargetNodes.size()<2){
		ss << rmapTargetNodes.size() << " RMAP Target Node is available." << endl;
	}else{
		ss << rmapTargetNodes.size() << " RMAP Target Nodes are available." << endl;
	}
	ss << endl;
	std::map<std::string,RMAPTargetNode*>::iterator it=rmapTargetNodes.begin();
	int i=1;
	while(it!=rmapTargetNodes.end()){
		if(it->second!=NULL){
			ss << "============ No. " << dec << i << "============" << endl;
			ss << it->second->toString() << endl;
			i++;
		}
		it++;
	}

	[Utility setTextToNSTextView:[Utility toNSString:ss.str()] to:registeredRMAPTargetNodesTextView];
	[registeredRMAPTargetNodesTextView selecteRange:NSMakeRange(0,0)];
}

- (IBAction)loadConfigurationButtonClicked:(id)sender {
	using namespace std;
	NSArray *fileTypes = [NSArray arrayWithObject:@"xml"];
	NSOpenPanel *oPanel = [NSOpenPanel openPanel];
	NSString *startingDir = [[NSUserDefaults standardUserDefaults] objectForKey:@"StartingDirectory"];
	if (!startingDir){
		startingDir = NSHomeDirectory();
	}
	[oPanel setAllowsMultipleSelection:NO];
	[oPanel setAllowedFileTypes:fileTypes];
	NSInteger opRet = [oPanel runModal];//[oPanel runModalForDirectory:startingDir file:nil types:fileTypes];
	string filename;
	if (opRet == NSOKButton){
		NSURL * filePath = [oPanel URL];
		filename=[Utility toString:[[[oPanel filenames] objectAtIndex:0] copy]];
	}else{
		return;
	}
	
	stringstream ss1;
	ss1 << "XML file '" << filename << "' was selected.";
	[mainController addMessageString:ss1.str()];
	
	std::vector<RMAPTargetNode*> nodes;
	try{
		nodes=RMAPTargetNode::constructFromXMLFile(filename);
	} catch (XMLLoader::XMLLoaderException e) {
		[mainController addRedMessage:@"XML file is invalid."];
		return;
	} catch (RMAPTargetNodeException e) {
		stringstream ss;
		if(e.isErrorFilenameSet()){
			ss << "RMAP Target Node defined in the XML flie " << e.getErrorFilename() << " is invalid." << endl;
		}else{
			ss << "RMAP Target Node defined in the XML flie is invalid." << endl;
		}
		[mainController addRedMessageString:ss.str()];
		return;
	} catch (RMAPMemoryObjectException e) {
		stringstream ss;
		if(e.isErrorFilenameSet()){
			ss << "RMAP Target Node defined in the XML flie " << e.getErrorFilename() << " is invalid." << endl;
		}else{
			ss << "RMAP Target Node defined in the XML flie is invalid." << endl;
		}
		[mainController addRedMessageString:ss.str()];
		return;
	} catch (...) {
		[mainController addRedMessage:@"XML file is invalid."];
		return;
	}
	
	stringstream ss;
	for(size_t i=0;i<nodes.size();i++){
		[self addRMAPTargetNode:nodes[i]];
		ss << "RMAP Target Node '" << nodes[i]->getID() << "' was added.";
		if(i!=nodes.size()-1){
			ss << endl;
		}
	}
	
	[mainController addMessageString:ss.str()];
	[self updateSubwindow];
	[rmapViewController rmapTargetNodesUpdated:&rmapTargetNodes];
}

- (IBAction)clearNodesButtonClicked:(id)sender {
	std::map<std::string,RMAPTargetNode*>::iterator it=rmapTargetNodes.begin();
	while(it!=rmapTargetNodes.end()){
		delete it->second;
		it++;
	}
	if(rmapTargetNodes.size()>1){
		[mainController addMessage:@"All RMAP Target Nodes were cleared."];
	}else{
		[mainController addMessage:@"RMAP Target Node was cleared."];
	}
	rmapTargetNodes.clear();
	[rmapViewController rmapTargetNodesCleared];
}

- (void)addRMAPTargetNode:(RMAPTargetNode*)node{
	rmapTargetNodes[node->getID()]=node;
}

- (void)addRMAPTargetNodes:(std::vector<RMAPTargetNode*>)nodes{
	for(size_t i=0;i<nodes.size();i++){
		[self addRMAPTargetNode:nodes[i]];
	}
}

- (std::map<std::string,RMAPTargetNode*>*)getRMAPTargetNodes{
	return &rmapTargetNodes;
}

- (IBAction)showInfoButtonClicked:(id)sender {
	if(isRegisteredRMAPTargetNodesWindowDisplayed==false){
		[registeredRMAPTargetNodesWindow setFloatingPanel:NO];
		[registeredRMAPTargetNodesTextView setTextColor:[NSColor whiteColor]]; 
		[registeredRMAPTargetNodesTextView setFont:[NSFont fontWithName:@"Courier" size:12]]; 
		[registeredRMAPTargetNodesWindow orderFront:mainWindow];
		[showRegisteredRMAPTargetNodesButton setTitle:@"Hide registered RMAP Target Nodes"];
		isRegisteredRMAPTargetNodesWindowDisplayed=true;
	}else{
		[registeredRMAPTargetNodesWindow orderOut:nil];
		[showRegisteredRMAPTargetNodesButton setTitle:@"Show registered RMAP Target Nodes"];
		isRegisteredRMAPTargetNodesWindowDisplayed=false;
	}
}

- (IBAction)transparencySliderAction:(id)sender {
	NSSlider* slider=(NSSlider*)sender;
	[registeredRMAPTargetNodesWindow setAlphaValue:[slider floatValue]];	
}
@end
