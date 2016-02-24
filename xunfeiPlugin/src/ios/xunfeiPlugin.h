#import <Cordova/CDV.h>
#import "iflyMSC/IFlyContact.h"
#import "iflyMSC/IFlyDataUploader.h"
#import "iflyMSC/IFlyDebugLog.h"
#import "iflyMSC/IFlyISVDelegate.h"
#import "iflyMSC/IFlyISVRecognizer.h"
#import "iflyMSC/IFlyRecognizerView.h"
#import "iflyMSC/IFlyRecognizerViewDelegate.h"
#import "iflyMSC/IFlyResourceUtil.h"
#import "iflyMSC/IFlySetting.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechError.h"
#import "iflyMSC/IFlySpeechEvaluator.h"
#import "iflyMSC/IFlySpeechEvaluatorDelegate.h"
#import "iflyMSC/IFlySpeechEvent.h"
#import "iflyMSC/IFlySpeechRecognizer.h"
#import "iflyMSC/IFlySpeechRecognizerDelegate.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"
#import "iflyMSC/IFlySpeechUnderstander.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlyTextUnderstander.h"
#import "iflyMSC/IFlyUserWords.h"
#import "iflyMSC/IFlyPcmRecorder.h"

@interface xunfeiPlugin : CDVPlugin <IFlySpeechRecognizerDelegate>
{
  // Member variables go here.
  IFlySpeechRecognizer *iFlySpeechRecognizer;//不带界面的识别对象
}

@property (nonatomic, strong) NSString *pcmFilePath;//音频文件路径
@property (nonatomic, strong) NSString *currentCallbackId;

- (void)initAppid:(CDVInvokedUrlCommand*)command;    //初始化讯飞语音
- (void)initMyRecognizer:(CDVInvokedUrlCommand*)command;  //语音识别函数
- (void)stop:(CDVInvokedUrlCommand*)command;
@end