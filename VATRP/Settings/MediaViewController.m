//
//  MediaViewController.m
//  ACE
//
//  Created by Ruben Semerjyan on 9/28/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "MediaViewController.h"
#import "LinphoneManager.h"
#import "AppDelegate.h"
@import AVFoundation;
#define kPREFERED_VIDEO_RESOLUTION @"kPREFERED_VIDEO_RESOLUTION"

@interface MediaViewController () {
    BOOL isChanged;
}
@property (weak) IBOutlet NSComboBox *comboBoxMicrophone;
@property (weak) IBOutlet NSComboBox *comboBoxVideoSize;
@property (weak) IBOutlet NSComboBox *comboBoxCaptureDevices;
@property (weak) IBOutlet NSComboBox *comboBoxSpeaker;
@property (weak) IBOutlet NSComboBox *comboBoxMediaEncription;
@property (weak) IBOutlet NSView *cameraPreview;

@property (retain) AVAudioRecorder *recorder;
@property (retain) NSTimer *timerRecordingLevelsUpdate;
@property (weak) IBOutlet NSLevelIndicator *levelIndicatorMicrophone;

@end

@implementation MediaViewController

- (void) awakeFromNib {
    [super awakeFromNib];
    isChanged = NO;
}

char **camlist;
char **soundlist;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    NSString *video_resolution = [[NSUserDefaults standardUserDefaults] objectForKey:kPREFERED_VIDEO_RESOLUTION];
    
    if (video_resolution) {
        self.comboBoxVideoSize.stringValue = video_resolution;
    } else {
        MSVideoSize vsize = linphone_core_get_preferred_video_size([LinphoneManager getLc]);
        
        if ((vsize.width == MS_VIDEO_SIZE_1080P_W) && (vsize.height == MS_VIDEO_SIZE_1080P_H)) {
            self.comboBoxVideoSize.stringValue = @"1080p (1920x1080)";
        } else if ((vsize.width == MS_VIDEO_SIZE_720P_W) && (vsize.height == MS_VIDEO_SIZE_720P_H)) {
            self.comboBoxVideoSize.stringValue = @"720p (1280x720)";
        } else if ((vsize.width == MS_VIDEO_SIZE_SVGA_W) && (vsize.height == MS_VIDEO_SIZE_SVGA_H)) {
            self.comboBoxVideoSize.stringValue = @"svga (800x600)";
        } else if ((vsize.width == MS_VIDEO_SIZE_4CIF_W) && (vsize.height == MS_VIDEO_SIZE_4CIF_H)) {
            self.comboBoxVideoSize.stringValue = @"4cif (704x576)";
        } else if ((vsize.width == MS_VIDEO_SIZE_VGA_W) && (vsize.height == MS_VIDEO_SIZE_VGA_H)) {
            self.comboBoxVideoSize.stringValue = @"vga (640x480)";
        } else if ((vsize.width == MS_VIDEO_SIZE_CIF_W) && (vsize.height == MS_VIDEO_SIZE_CIF_H)) {
            self.comboBoxVideoSize.stringValue = @"cif (352x288)";
        } else if ((vsize.width == MS_VIDEO_SIZE_QCIF_W) && (vsize.height == MS_VIDEO_SIZE_QCIF_H)) {
            self.comboBoxVideoSize.stringValue = @"qcif (176x144)";
        }  else {
            self.comboBoxVideoSize.stringValue = @"None";
        }
    }
    
    LinphoneMediaEncryption menc = linphone_core_get_media_encryption([LinphoneManager getLc]);

    switch (menc) {
        case LinphoneMediaEncryptionSRTP:
            self.comboBoxMediaEncription.stringValue = @"Encrypted (SRTP)";
            break;
        case LinphoneMediaEncryptionZRTP:
            self.comboBoxMediaEncription.stringValue = @"Encrypted (ZRTP)";
            break;
        case LinphoneMediaEncryptionDTLS:
            self.comboBoxMediaEncription.stringValue = @"Encrypted (DTLS)";
            break;
        case LinphoneMediaEncryptionNone:
            self.comboBoxMediaEncription.stringValue = @"Unencrypted";
            break;
    }
    
    camlist = (char**)linphone_core_get_video_devices([LinphoneManager getLc]);
    for (char* cam = *camlist;*camlist!=NULL;cam=*++camlist) {
        [self.comboBoxCaptureDevices addItemWithObjectValue:[NSString stringWithCString:cam encoding:NSUTF8StringEncoding]];
    }
    
    const char * cam = linphone_core_get_video_device([LinphoneManager getLc]);
    [self.comboBoxCaptureDevices selectItemWithObjectValue:[NSString stringWithCString:cam encoding:NSUTF8StringEncoding]];

    soundlist = (char**)linphone_core_get_sound_devices([LinphoneManager getLc]);
    for (char* device = *soundlist;*soundlist!=NULL;device=*++soundlist) {
        if(linphone_core_sound_device_can_capture([LinphoneManager getLc], device)){
            [self.comboBoxMicrophone addItemWithObjectValue:[NSString stringWithCString:device encoding:NSUTF8StringEncoding]];
        }
        else if(linphone_core_sound_device_can_playback([LinphoneManager getLc], device)){
                [self.comboBoxSpeaker addItemWithObjectValue:[NSString stringWithCString:device encoding:NSUTF8StringEncoding]];
        }
    }
    
    const char * mic= linphone_core_get_capture_device([LinphoneManager getLc]);
    [self.comboBoxMicrophone selectItemWithObjectValue:[NSString stringWithCString:mic encoding:NSUTF8StringEncoding]];
    
    const char *speaker = linphone_core_get_playback_device([LinphoneManager getLc]);
    [self.comboBoxSpeaker selectItemWithObjectValue:[NSString stringWithCString:speaker encoding:NSUTF8StringEncoding]];
    
    [self initializeRecorder];
    [self initializeLevelTimer];
    
    [self displaySelectedVideoDevice];
}

- (IBAction)onComboboxPreferedVideoResolution:(id)sender {
    isChanged = YES;
}

- (void) save {
    if (!isChanged) {
        return;
    }
    
    MSVideoSize vsize;

    if ([self.comboBoxVideoSize.stringValue isEqualToString:@"1080p (1920x1080)"]) {
        MS_VIDEO_SIZE_ASSIGN(vsize, 1080P);
    } else     if ([self.comboBoxVideoSize.stringValue isEqualToString:@"720p (1280x720)"]) {
        MS_VIDEO_SIZE_ASSIGN(vsize, 720P);
    } else     if ([self.comboBoxVideoSize.stringValue isEqualToString:@"svga (800x600)"]) {
        MS_VIDEO_SIZE_ASSIGN(vsize, SVGA);
    } else     if ([self.comboBoxVideoSize.stringValue isEqualToString:@"4cif (704x576)"]) {
        MS_VIDEO_SIZE_ASSIGN(vsize, 4CIF);
    } else     if ([self.comboBoxVideoSize.stringValue isEqualToString:@"vga (640x480)"]) {
        MS_VIDEO_SIZE_ASSIGN(vsize, VGA);
    } else     if ([self.comboBoxVideoSize.stringValue isEqualToString:@"cif (352x288)"]) {
        MS_VIDEO_SIZE_ASSIGN(vsize, CIF);
    } else     if ([self.comboBoxVideoSize.stringValue isEqualToString:@"qcif (176x144)"]) {    
        MS_VIDEO_SIZE_ASSIGN(vsize, QCIF);
    }

    linphone_core_set_preferred_video_size([LinphoneManager getLc], vsize);
    [[NSUserDefaults standardUserDefaults] setObject:self.comboBoxVideoSize.stringValue forKey:kPREFERED_VIDEO_RESOLUTION];
    
    int retval = 0;
    
    if (self.comboBoxMediaEncription.stringValue && [self.comboBoxMediaEncription.stringValue compare:@"Encrypted (SRTP)"] == NSOrderedSame)
        retval = linphone_core_set_media_encryption([LinphoneManager getLc], LinphoneMediaEncryptionSRTP);
    else if (self.comboBoxMediaEncription.stringValue && [self.comboBoxMediaEncription.stringValue compare:@"Encrypted (ZRTP)"] == NSOrderedSame)
        retval = linphone_core_set_media_encryption([LinphoneManager getLc], LinphoneMediaEncryptionZRTP);
    else if (self.comboBoxMediaEncription.stringValue && [self.comboBoxMediaEncription.stringValue compare:@"Encrypted (DTLS)"] == NSOrderedSame)
        retval = linphone_core_set_media_encryption([LinphoneManager getLc], LinphoneMediaEncryptionDTLS);
    else
        retval = linphone_core_set_media_encryption([LinphoneManager getLc], LinphoneMediaEncryptionNone);

    [[NSUserDefaults standardUserDefaults] setObject:self.comboBoxCaptureDevices.stringValue forKey:@"SETTINGS_SELECTED_CAPTURE_DEVICE"];
    [[NSUserDefaults standardUserDefaults] setObject:self.comboBoxMicrophone.stringValue forKey:@"SETTINGS_SELECTED_MICROPHONE"];
    [[NSUserDefaults standardUserDefaults] setObject:self.comboBoxSpeaker.stringValue forKey:@"SETTINGS_SELECTED_SPEAKER"];
    // force the save rather than wait for auto sync.
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (IBAction)onComboBoxCaptureDevice:(id)sender {
    [self displaySelectedVideoDevice];
    isChanged = YES;
}

- (IBAction)onComboBoxMicrophone:(id)sender {
    const char *mic = [self.comboBoxMicrophone.stringValue cStringUsingEncoding:NSUTF8StringEncoding];
    linphone_core_set_capture_device([LinphoneManager getLc], mic);
    isChanged = YES;
}

- (IBAction)onComboBoxSpeaker:(id)sender {
    const char *speaker = [self.comboBoxSpeaker.stringValue cStringUsingEncoding:NSUTF8StringEncoding];
    linphone_core_set_playback_device([LinphoneManager getLc], speaker);
	
    const char* lPlay = [[LinphoneManager bundleFile:@"msg.wav"] cStringUsingEncoding:[NSString defaultCStringEncoding]];
    linphone_core_play_local([LinphoneManager getLc], lPlay);
    isChanged = YES;
}

- (IBAction)onComboboxMediaEncription:(id)sender {
    isChanged = YES;
}

-(void) displaySelectedVideoDevice {
    if([AppDelegate sharedInstance].viewController.videoMailWindowController.isShow == YES){
        [[AppDelegate sharedInstance].viewController.videoMailWindowController close];
    }
    
    const char *cam = [self.comboBoxCaptureDevices.stringValue cStringUsingEncoding:NSUTF8StringEncoding];
    LinphoneCore *lc = [LinphoneManager getLc];
    linphone_core_set_video_device(lc, cam);
    
    linphone_core_enable_video_preview([LinphoneManager getLc], TRUE);
    linphone_core_use_preview_window(lc, YES);
    linphone_core_set_native_preview_window_id(lc, (__bridge void *)(self.cameraPreview));
    linphone_core_enable_self_view([LinphoneManager getLc], TRUE);
}

- (void)initializeRecorder
{
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
    NSError *error;
    
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
    if (self.recorder) {
        [self.recorder prepareToRecord];
        [self.recorder setMeteringEnabled:YES];
        [self.recorder record];
    } else
        NSLog(@"Error in initializeRecorder: %@", [error description]);
}

- (void)initializeLevelTimer
{
    self.timerRecordingLevelsUpdate = [NSTimer scheduledTimerWithTimeInterval: 0.03 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
}

- (void)levelTimerCallback:(NSTimer *)timer
{
    [self.recorder updateMeters];
    [self.levelIndicatorMicrophone setDoubleValue:[self.recorder peakPowerForChannel:0]];
}

@end
