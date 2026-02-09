#ifndef HARMONY_TCP_STRUCTURES_H
#define HARMONY_TCP_STRUCTURES_H

#include <vector>
#include <string>
#include <cstring>
#include <cstdint>

// Define standard types for compatibility
typedef uint8_t quint8;
typedef int8_t qint8;
typedef uint16_t quint16;
typedef uint16_t ushort;
typedef uint32_t quint32;
typedef uint32_t ulong; // Assuming legacy was Windows (32-bit long), mapping to 32-bit
typedef uint32_t uint;
typedef int32_t qint32;

namespace ConstPreDefine
{
    static const int MAX_SUBSYS_NUM = 4;
    static const int MAX_CHANNEL_NUM = 12;
    static const int MAX_CAMERA_NUM = 9;
    static const int CHANNEL_NUM = 2;
    static const int MAX_COLOR_CAMERA_NUM = 3;
    static const int MAX_NIR_CAMERA_NUM = 6;
    static const int MAX_CAMERA_DIRECTION = 3;

    static const int MAX_QUALITY_GRADE_NUM = 16;
    static const int MAX_SIZE_GRADE_NUM = 16;
    static const int MAX_EXIT_NUM = 48; // Using 48 as default based on file path "48"
    static const int MAX_TEXT_LENGTH = 12;
    static const int MAX_FRUIT_NAME_LENGTH = 50;
    static const int MAX_CLIENTINFO_LENGTH = 20;
    static const int MAX_CLIENTINFO_LENGTH_OLD = 50;
    
    static const int MAX_COLOR_INTERVAL_NUM = 3;
    static const int MAX_COLOR_GRADE_NUM = 16;
    static const int MAX_SHAPE_GRADE_NUM = 6;
    static const int MAX_FlAWAREA_GRADE_NUM = 6;
    static const int MAX_BRUISE_GRADE_NUM = 6;
    static const int MAX_ROT_GRADE_NUM = 6;
    static const int MAX_DENSITY_GRADE_NUM = 6;
    static const int MAX_SUGAR_GRADE_NUM = 6;
    static const int MAX_ACIDITY_GRADE_NUM = 6;
    static const int MAX_HOLLOW_GRADE_NUM = 6;
    static const int MAX_SKIN_GRADE_NUM = 6;
    static const int MAX_BROWN_GRADE_NUM = 6;
    static const int MAX_TANGXIN_GRADE_NUM = 6;
    static const int MAX_RIGIDITY_GRADE_NUM = 6;
    static const int MAX_WATER_GRADE_NUM = 6;
    
    static const int MAX_FRUIT_TYPE_MAJOR_CLASS_NUM = 32;
    static const int MAX_FRUIT_TYPE_SUB_CLASS_NUM = 8;
    static const int MAX_FRUIT_TEXT_LENGTH = 20;
    
    static const int PARAS_TAGINFO_NUM = 6;
    static const int MAX_LABEL_NUM = 4;
    static const int MAX_NOTICE_LENGTH = 30;
    static const int MAX_IPM_NUM = 12;

    static const int MAX_SPLICE_IMAGE_WIDTH = 3200;
    static const int MAX_SPLICE_IMAGE_HEIGHT = 512;
    
    static const int MAX_EXIT_DISPALYNAME_LENGTH = 20;
    static const int MAX_EXIT_ADDITIONALNAME_LENGTH = 100;
    static const int BYTE_NUM_FSM_VERSION = 64;
}

enum FSM_HC_COMMAND_TYPE : int
{
    FSM_CMD_CONFIG = 0x1000,			    //配置信息	stGlobal (StSysConfig), FSM-->HC
    FSM_CMD_STATISTICS,					    //统计信息	stStatistics, FSM-->HC
    FSM_CMD_GRADEINFO,					    //水果实时分级信息	stFruitGradeInfo (StFruitParam?), FSM-->HC
    FSM_CMD_WEIGHTINFO,					    //重量统计信息	stWeightResult, FSM-->HC
    FSM_CMD_WAVEINFO,						//波形数据 stWaveInfo,FSM-->HC
    FSM_CMD_VERSIONERROR,				    //上位机版本与下位机版本不一致, fsmv,FSM-->HC
    FSM_CMD_BURN_FLASH_PROGRESS,            //烧写FSM进度显示 2015-4-7add(上传信息为一个int)
    FSM_CMD_BURN_DEBUG,						//FSM向上位机传输调试信息
    FSM_CMD_GETVERSION,                     //FSM向上位机传输版本信息
    FSM_CMD_BOOT_FLASH_PROGRESS,
};

enum IPM_HC_COMMAND_TYPE : int
{
    IPM_CMD_IMAGE = 0x3000,
    IPM_CMD_AUTOBALANCE_COEFFICIENT = 0x3001,
    IPM_CMD_IMAGE_SPLICE = 0x3002,
    IPM_CMD_IMAGE_SPOT = 0x3003,
    IPM_CMD_SHUTTER_ADJUST = 0x3004
};

enum ACS_HMI_COMMAND_TYPE : int
{
    ACS_HMI_EXIT_STOP = 0x8000
};

// ================== Pack 1 Section (Matches Legacy) ==================
#pragma pack(push, 1)

struct StSysConfig
{
    quint8 exitstate[ConstPreDefine::MAX_EXIT_NUM * 2 * 4];
    quint8 nChannelInfo[ConstPreDefine::MAX_SUBSYS_NUM];
    quint8 nImageUV[ConstPreDefine::MAX_SUBSYS_NUM];
    quint8 nDataRegistration[ConstPreDefine::MAX_SUBSYS_NUM];
    quint8 nImageSugar[ConstPreDefine::MAX_SUBSYS_NUM];
    quint8 nImageUltrasonic[ConstPreDefine::MAX_SUBSYS_NUM];
    int nCameraDelay[ConstPreDefine::MAX_CAMERA_NUM * 2];
    int width;
    int height;
    int packetSize;
    quint16 nSystemInfo;
    quint8 nSubsysNum;
    quint8 nExitNum;
    quint8 nClassificationInfo;
    quint8 multiFreq;
    quint8 nCameraType;
    quint8 CIRClassifyType;
    quint8 UVClassifyType;
    quint8 WeightClassifyTpye;
    quint8 InternalClassifyType;
    quint8 UltrasonicClassifyType;
    quint8 IfWIFIEnable;
    quint8 CheckExit;
    quint8 CheckNum;
    quint8 nIQSEnable;
    
    StSysConfig() {
        memset(this, 0, sizeof(StSysConfig));
    }
};

struct StColorIntervalItem
{
    quint8 nMinU;
    quint8 nMaxU;
    quint8 nMinV;
    quint8 nMaxV;
    
    StColorIntervalItem() { memset(this, 0, sizeof(StColorIntervalItem)); }
};

struct StPercentInfo
{
    quint8 nMax;
    quint8 nMin;
    StPercentInfo() { memset(this, 0, sizeof(StPercentInfo)); }
};

struct StBGR
{
    quint8 bB;
    quint8 bG;
    quint8 bR;
    StBGR() { memset(this, 0, sizeof(StBGR)); }
};

#pragma pack(pop)
// ================== End Pack 1 Section ==================

// ================== Pack 4 Section (Matches Legacy) ==================
#pragma pack(push, 4)

struct StGradeItemInfo
{
    ulong exit;
    float nMinSize;
    float nMaxSize;
    int nFruitNum;
    qint8 nColorGrade;
    qint8 sbShapeSize;
    qint8 sbDensity;
    qint8 sbFlawArea;
    qint8 sbBruise;
    qint8 sbRot;
    qint8 sbSugar;
    qint8 sbAcidity;
    qint8 sbHollow;
    qint8 sbSkin;
    qint8 sbBrown;
    qint8 sbTangxin;
    qint8 sbRigidity;
    qint8 sbWater;
    qint8 sbLabelbyGrade;
    
    StGradeItemInfo() { memset(this, 0, sizeof(StGradeItemInfo)); }
};

#pragma pack(pop)
// ================== End Pack 4 Section ==================

// ================== Default/Pack 4 Section (Legacy Default) ==================
// Using pack(4) to simulate 32-bit Windows alignment on ARM64
#pragma pack(push, 4)

struct StGradeInfo
{
    StColorIntervalItem intervals[ConstPreDefine::MAX_COLOR_INTERVAL_NUM];
    StPercentInfo percent[ConstPreDefine::MAX_COLOR_GRADE_NUM * ConstPreDefine::MAX_COLOR_INTERVAL_NUM];
    StGradeItemInfo grades[ConstPreDefine::MAX_QUALITY_GRADE_NUM * ConstPreDefine::MAX_SIZE_GRADE_NUM];
    int ExitEnabled[2];
    int ColorIntervals[2];
    int nExitSwitchNum[ConstPreDefine::MAX_EXIT_NUM];
    quint8 nTagInfo[ConstPreDefine::PARAS_TAGINFO_NUM];
    int nFruitType;
    quint8 strFruitName[ConstPreDefine::MAX_FRUIT_NAME_LENGTH];
    quint32 unFlawAreaFactor[ConstPreDefine::MAX_FlAWAREA_GRADE_NUM * 2];
    quint32 unBruiseFactor[ConstPreDefine::MAX_BRUISE_GRADE_NUM * 2];
    quint32 unRotFactor[ConstPreDefine::MAX_ROT_GRADE_NUM * 2];
    float fDensityFactor[ConstPreDefine::MAX_DENSITY_GRADE_NUM];
    float fSugarFactor[ConstPreDefine::MAX_SUGAR_GRADE_NUM];
    float fAcidityFactor[ConstPreDefine::MAX_ACIDITY_GRADE_NUM];
    float fHollowFactor[ConstPreDefine::MAX_HOLLOW_GRADE_NUM];
    float fSkinFactor[ConstPreDefine::MAX_SKIN_GRADE_NUM];
    float fBrownFactor[ConstPreDefine::MAX_BROWN_GRADE_NUM];
    float fTangxinFactor[ConstPreDefine::MAX_TANGXIN_GRADE_NUM];
    float fRigidityFactor[ConstPreDefine::MAX_RIGIDITY_GRADE_NUM];
    float fWaterFactor[ConstPreDefine::MAX_WATER_GRADE_NUM];
    float fShapeFactor[ConstPreDefine::MAX_SHAPE_GRADE_NUM];
    quint8 strSizeGradeName[ConstPreDefine::MAX_SIZE_GRADE_NUM * ConstPreDefine::MAX_TEXT_LENGTH];
    quint8 strQualityGradeName[ConstPreDefine::MAX_QUALITY_GRADE_NUM * ConstPreDefine::MAX_TEXT_LENGTH];
    quint8 stDensityGradeName[ConstPreDefine::MAX_DENSITY_GRADE_NUM * ConstPreDefine::MAX_TEXT_LENGTH];
    quint8 strColorGradeName[ConstPreDefine::MAX_COLOR_GRADE_NUM * ConstPreDefine::MAX_TEXT_LENGTH];
    quint8 strShapeGradeName[ConstPreDefine::MAX_SHAPE_GRADE_NUM * ConstPreDefine::MAX_TEXT_LENGTH];
    quint8 stFlawareaGradeName[ConstPreDefine::MAX_FlAWAREA_GRADE_NUM * ConstPreDefine::MAX_TEXT_LENGTH];
    quint8 stBruiseGradeName[ConstPreDefine::MAX_BRUISE_GRADE_NUM * ConstPreDefine::MAX_TEXT_LENGTH];
    quint8 stRotGradeName[ConstPreDefine::MAX_ROT_GRADE_NUM * ConstPreDefine::MAX_TEXT_LENGTH];
    quint8 stSugarGradeName[ConstPreDefine::MAX_SUGAR_GRADE_NUM * ConstPreDefine::MAX_TEXT_LENGTH];
    quint8 stAcidityGradeName[ConstPreDefine::MAX_ACIDITY_GRADE_NUM * ConstPreDefine::MAX_TEXT_LENGTH];
    quint8 stHollowGradeName[ConstPreDefine::MAX_HOLLOW_GRADE_NUM * ConstPreDefine::MAX_TEXT_LENGTH];
    quint8 stSkinGradeName[ConstPreDefine::MAX_SKIN_GRADE_NUM * ConstPreDefine::MAX_TEXT_LENGTH];
    quint8 stBrownGradeName[ConstPreDefine::MAX_BROWN_GRADE_NUM * ConstPreDefine::MAX_TEXT_LENGTH];
    quint8 stTangxinGradeName[ConstPreDefine::MAX_TANGXIN_GRADE_NUM * ConstPreDefine::MAX_TEXT_LENGTH];
    quint8 stRigidityGradeName[ConstPreDefine::MAX_FlAWAREA_GRADE_NUM * ConstPreDefine::MAX_TEXT_LENGTH];
    quint8 stWaterGradeName[ConstPreDefine::MAX_WATER_GRADE_NUM * ConstPreDefine::MAX_TEXT_LENGTH];
    quint8 ColorType;
    quint8 nLabelType;
    quint8 nLabelbyExit[ConstPreDefine::MAX_EXIT_NUM];
    quint8 nSwitchLabel[ConstPreDefine::MAX_EXIT_NUM];
    quint8 nSizeGradeNum;
    quint8 nQualityGradeNum;
    quint8 nClassifyType;
    short nCheckNum;
    short ForceChannel;
    
    StGradeInfo() { memset(this, 0, sizeof(StGradeInfo)); }
};

struct StStatistics
{
    ulong nGradeCount[ConstPreDefine::MAX_QUALITY_GRADE_NUM * ConstPreDefine::MAX_SIZE_GRADE_NUM];
    ulong nWeightGradeCount[ConstPreDefine::MAX_QUALITY_GRADE_NUM * ConstPreDefine::MAX_SIZE_GRADE_NUM];
    ulong nExitCount[ConstPreDefine::MAX_EXIT_NUM];
    ulong nExitWeightCount[ConstPreDefine::MAX_EXIT_NUM];
    ulong nChannelTotalCount[ConstPreDefine::MAX_CHANNEL_NUM];
    ulong nChannelWeightCount[ConstPreDefine::MAX_CHANNEL_NUM];
    int nSubsysId;
    int nBoxGradeCount[ConstPreDefine::MAX_QUALITY_GRADE_NUM * ConstPreDefine::MAX_SIZE_GRADE_NUM];
    int nBoxGradeWeight[ConstPreDefine::MAX_QUALITY_GRADE_NUM * ConstPreDefine::MAX_SIZE_GRADE_NUM];
    int nTotalCupNum;
    int nInterval;
    int nIntervalSumperminute;
    ushort nCupState;
    ushort nPulseInterval;
    ushort nUnpushFruitCount;
    quint8 nNetState;
    quint8 nWeightSetting;
    quint8 nSCMState;
    quint8 nIQSNetState;
    quint8 nLockState;
    quint16 ExitBoxNum[ConstPreDefine::MAX_EXIT_NUM];
    quint32 ExitWeight[ConstPreDefine::MAX_EXIT_NUM];
    quint8 Notice[ConstPreDefine::MAX_NOTICE_LENGTH];

    StStatistics() { memset(this, 0, sizeof(StStatistics)); }
};

struct StBroadcastStatistics
{
    StStatistics statistics;
    quint8 strStartTime[ConstPreDefine::MAX_TEXT_LENGTH];
    float fSeparationEfficiency;
    float fRealWeightCount;
    quint8 strProgramName[ConstPreDefine::MAX_TEXT_LENGTH];
    quint8 strLabelName[ConstPreDefine::MAX_LABEL_NUM * ConstPreDefine::MAX_TEXT_LENGTH];

    StBroadcastStatistics() { memset(this, 0, sizeof(StBroadcastStatistics)); }
};

struct StBroadcastSysConfig
{
    StSysConfig sysConfig;
    int nLanguage;
    long exitDisplayType; 
    quint8 strDisplayName[ConstPreDefine::MAX_EXIT_NUM * ConstPreDefine::MAX_EXIT_DISPALYNAME_LENGTH];
    
    StBroadcastSysConfig() { memset(this, 0, sizeof(StBroadcastSysConfig)); }
};

struct StTrackingData
{
    int nVehicleId;
    float fFruitWeight;
    float fVehicleWeight;
    ushort nADFruit;
    ushort nADVehicle;
    
    StTrackingData() { memset(this, 0, sizeof(StTrackingData)); }
};

struct StWeightStat
{
    float fCupAverageWeight;
    ushort nAD0;
    ushort nAD1;
    ushort nStandardAD0;
    ushort nStandardAD1;
    
    StWeightStat() { memset(this, 0, sizeof(StWeightStat)); }
};

struct StWeightResult
{
    StTrackingData data;
    StWeightStat paras;
    int nChannelId;
    float fVehicleWeight0;
    float fVehicleWeight1;
    quint8 state;
    
    StWeightResult() { memset(this, 0, sizeof(StWeightResult)); }
};

struct StFruitVisionParam
{
    uint unColorRate0;
    uint unColorRate1;
    uint unColorRate2;
    uint unArea;
    uint unFlawArea;
    uint unVolume;
    uint unFlawNum;
    float unMaxR;
    float unMinR;
    float unSelectBasis;
    float fDiameterRatio;
    float fMinDRatio;
    
    StFruitVisionParam() { memset(this, 0, sizeof(StFruitVisionParam)); }
};

struct StFruitUVParam
{
    uint unBruiseArea;
    uint unBruiseNum;
    uint unRotArea;
    uint unRotNum;
    uint unRigidity;
    uint unWater;
    quint32 unTimeTag;
    
    StFruitUVParam() { memset(this, 0, sizeof(StFruitUVParam)); }
};

struct StNIRParam
{
    float fSugar;
    float fAcidity;
    float fHollow;
    float fSkin;
    float fBrown;
    float fTangxin;
    quint32 unTimeTag;
    
    StNIRParam() { memset(this, 0, sizeof(StNIRParam)); }
};

struct StFruitParam
{
    StFruitVisionParam visionParam;
    StFruitUVParam uvParam;
    StNIRParam nirParam;
    float fWeight;
    float fDensity;
    uint unGrade;
    quint8 unWhichExit;
    
    StFruitParam() { memset(this, 0, sizeof(StFruitParam)); }
};

struct StFruitGradeInfo
{
    StFruitParam param[ConstPreDefine::CHANNEL_NUM];
    int nRouteId;
    
    StFruitGradeInfo() { memset(this, 0, sizeof(StFruitGradeInfo)); }
};

struct StWhiteBalanceMean
{
    int MeanR;
    int MeanG;
    int MeanB;
    StWhiteBalanceMean() { memset(this, 0, sizeof(StWhiteBalanceMean)); }
};

struct StWhiteBalanceCoefficient
{
    StBGR BGR;
    StWhiteBalanceMean MeanValue;
    StWhiteBalanceCoefficient() { memset(this, 0, sizeof(StWhiteBalanceCoefficient)); }
};

struct StShutterAdjust
{
    quint16 colorY[ConstPreDefine::MAX_COLOR_CAMERA_NUM];
    quint16 colorH[ConstPreDefine::MAX_COLOR_CAMERA_NUM];
    quint16 nir1Y[ConstPreDefine::MAX_COLOR_CAMERA_NUM];
    quint16 nir2Y[ConstPreDefine::MAX_COLOR_CAMERA_NUM];
    StShutterAdjust() { memset(this, 0, sizeof(StShutterAdjust)); }
};

struct StWaveInfo
{
    int nChannelId;
    ushort waveform0[256];
    ushort waveform1[256];
    float fruitweight;
    StWaveInfo() { memset(this, 0, sizeof(StWaveInfo)); }
};

#pragma pack(pop)
// ================== End Pack 4 Section ==================

#endif // HARMONY_TCP_STRUCTURES_H
