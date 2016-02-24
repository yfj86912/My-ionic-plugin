/********* xunfeiPlugin.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import "xunfeiPlugin.h"
#import "IATConfig.h"
#import "ISRDataHelper.h"

@implementation xunfeiPlugin


- (void)initAppid:(CDVInvokedUrlCommand*)command
{
        //设置sdk的log等级，log保存在下面设置的工作路径中
    [IFlySetting setLogFile:LVL_ALL];
    
    //打开输出在console的log开关
    [IFlySetting showLogcat:YES];

    //设置sdk的工作路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    _pcmFilePath = [[NSString alloc] initWithFormat:@"%@",[cachePath stringByAppendingPathComponent:@"asr.pcm"]];
    
    [IFlySetting setLogFilePath:cachePath];
    
    //创建语音配置,appid必须要传入，仅执行一次则可
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=564186cc"];
    
    //所有服务启动前，需要确保执行createUtility
    [IFlySpeechUtility createUtility:initString];
    
    NSLog(@"xunfei注册成功！");
}

- (void)initMyRecognizer:(CDVInvokedUrlCommand*)command
{
    NSLog(@"xunfei开始语音识别");
    
    if(iFlySpeechRecognizer == nil)
    {
        [self initRecognizer];
    }
        
    [iFlySpeechRecognizer cancel];
        
    //设置音频来源为麦克风
    [iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        
    //设置听写结果格式为json
    [iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        
    //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
    [iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        
    [iFlySpeechRecognizer setDelegate:self];
        
    BOOL ret = [iFlySpeechRecognizer startListening];
    if (ret) {
        NSLog(@"xunfei启动服务成功！");
    }else{
        NSLog(@"--xunfei启动服务失败！");//可能是上次请求未结束，暂不支持多路并发
    }
    self.currentCallbackId = command.callbackId;
}

- (void)stop:(CDVInvokedUrlCommand*)command
{
    NSLog(@"xunfei语音识别结束");
    [iFlySpeechRecognizer stopListening];
}

/**
 设置识别参数
 ****/
-(void)initRecognizer
{        
        //单例模式，无UI的实例
        if (iFlySpeechRecognizer == nil) {
            iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
            
            [iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
            
            //设置听写模式
            [iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        }
        iFlySpeechRecognizer.delegate = self;
    
        if (iFlySpeechRecognizer != nil) {
            IATConfig *instance = [IATConfig sharedInstance];
            
            //设置最长录音时间
            [iFlySpeechRecognizer setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
            //设置后端点
            [iFlySpeechRecognizer setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
            //设置前端点
            [iFlySpeechRecognizer setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
            //网络等待时间
            [iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
            
            //设置采样率，推荐使用16K
            [iFlySpeechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
            
            if ([instance.language isEqualToString:[IATConfig chinese]]) {
                //设置语言
                [iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
                //设置方言
                [iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
            }else if ([instance.language isEqualToString:[IATConfig english]]) {
                [iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            }
            //设置是否返回标点符号
            [iFlySpeechRecognizer setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
            
        }
}


#pragma mark - IFlySpeechRecognizerDelegate

/**
 音量回调函数
 volume 0－30
 ****/
- (void) onVolumeChanged: (int)volume
{   
    NSString * vol = [NSString stringWithFormat:@"音量：%d",volume];
    NSLog(@"xunfei语音识别--%@", vol);
}



/**
 开始识别回调
 ****/
- (void) onBeginOfSpeech
{
    NSLog(@"xunfei语音识别--正在录音");
}

/**
 停止录音回调
 ****/
- (void) onEndOfSpeech
{
    NSLog(@"xunfei语音识别--停止录音");
}


/**
 听写结束回调（注：无论听写是否正确都会回调）
 error.errorCode =
 0     听写正确
 other 听写出错
 ****/
- (void) onError:(IFlySpeechError *) error
{
    NSLog(@"%s",__func__);
    
    if ([IATConfig sharedInstance].haveView == NO ) {
        NSString *text ;
        
        if (error.errorCode == 0 ) {
                text = @"识别成功";
        }else {
            text = [NSString stringWithFormat:@"发生错误：%d %@", error.errorCode,error.errorDesc];
            
        }
        
        NSLog(@"xunfei语音识别--%@",text);

    }else {
        NSLog(@"xunfei语音识别--识别结束");
        NSLog(@"errorCode:%d",[error errorCode]);
    }
    
}

/**
 无界面，听写结果回调
 results：听写结果
 isLast：表示最后一次
 ****/
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    
    NSString * resultFromJson =  [ISRDataHelper stringFromJson:resultString];
    NSLog(@"xunfei语音识别结果--%@", resultFromJson);
    
    if (isLast){
        NSLog(@"听写结果(json)：%@测试",  resultFromJson);
    }
    
    if (!self.currentCallbackId) {
        return;
    }
    
    CDVPluginResult* result = nil;
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:resultFromJson];
    [self.commandDelegate sendPluginResult:result callbackId:self.currentCallbackId];
    self.currentCallbackId = nil;
    [iFlySpeechRecognizer stopListening];
    
}



/**
 听写取消回调
 ****/
- (void) onCancel
{
    NSLog(@"识别取消");
}




@end
