export const getHelloString: () => string;
export const addNumbers: (a: number, b: number) => number;
export const getVersion: () => string;

// SocketServer (PLC Control)
export const socketServerStart: (ip: string, port: number, callback: (clientIP: string, data: Uint8Array) => void) => boolean;
export const socketServerSendData: (data: Uint8Array) => boolean;
export const socketServerDestroy: () => void;

// TcpClient (Short Connection / Command)
export const tcpClientConnect: (ip: string, port: number, callback: (data: Uint8Array) => void) => boolean;
export const tcpClientSend: (data: Uint8Array) => boolean;
export const tcpClientDestroy: () => void;

// TcpServer (Business Data)
export interface CommandHead {
    cmdId: number;
    srcId: number;
    length: number;
    data: Uint8Array; // 原始数据
}

// 具体业务结构定义 (Legacy Protocol)

export interface StSysConfig {
    width: number;
    height: number;
    packetSize: number;
    nSystemInfo: number;
    nSubsysNum: number;
    nExitNum: number;
    // ... 其他关键字段，根据需要展开
}

export interface StStatistics {
    nGradeCount: Uint32Array;      // [16 * 16]
    nWeightGradeCount: Uint32Array; // [16 * 16]
    nExitCount: Uint32Array;       // [48]
    nExitWeightCount: Uint32Array; // [48]
    nChannelTotalCount: Uint32Array; // [12]
    nChannelWeightCount: Uint32Array; // [12]
    nSubsysId: number;
    nTotalCupNum: number;
    nIntervalSumperminute: number; // 分选速度
    nCupState: number;
    nNetState: number;
}

export interface StFruitParam {
    fWeight: number;
    fDensity: number;
    unGrade: number;
    unWhichExit: number;
    // ... 视觉/NIR参数可进一步展开
}

export interface StWeightResult {
    nChannelId: number;
    fVehicleWeight0: number;
    fVehicleWeight1: number;
    state: number;
    // data: StTrackingData;
    // paras: StWeightStat;
}

export const tcpServerStart: (ip: string, port: number, dstId: number, callback: (head: CommandHead) => void) => boolean;
export const tcpServerDestroy: () => void;
