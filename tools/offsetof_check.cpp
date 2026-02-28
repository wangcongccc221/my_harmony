#include <iostream>
#include <cstddef>
#include "E:/NEW/MY_HARMONY/entry/src/main/cpp/Tcp/structures.h"
int main(){
 std::cout << "StGradeInfo size=" << sizeof(StGradeInfo) << "\n";
 std::cout << "  nTagInfo=" << offsetof(StGradeInfo,nTagInfo) << "\n";
 std::cout << "  nFruitType=" << offsetof(StGradeInfo,nFruitType) << "\n";
 std::cout << "  strFruitName=" << offsetof(StGradeInfo,strFruitName) << "\n";
 std::cout << "  unFlawAreaFactor=" << offsetof(StGradeInfo,unFlawAreaFactor) << "\n";
 std::cout << "  ColorType=" << offsetof(StGradeInfo,ColorType) << "\n";
 std::cout << "  nCheckNum=" << offsetof(StGradeInfo,nCheckNum) << "\n";
 std::cout << "  ForceChannel=" << offsetof(StGradeInfo,ForceChannel) << "\n";
 std::cout << "StStatistics size=" << sizeof(StStatistics) << "\n";
 std::cout << "  nNetState=" << offsetof(StStatistics,nNetState) << "\n";
 std::cout << "  nSCMState=" << offsetof(StStatistics,nSCMState) << "\n";
 std::cout << "  nIQSNetState=" << offsetof(StStatistics,nIQSNetState) << "\n";
 std::cout << "  nLockState=" << offsetof(StStatistics,nLockState) << "\n";
 std::cout << "  ExitBoxNum=" << offsetof(StStatistics,ExitBoxNum) << "\n";
 std::cout << "  ExitWeight=" << offsetof(StStatistics,ExitWeight) << "\n";
 std::cout << "StGlobal size=" << sizeof(StGlobal) << "\n";
 std::cout << "  sys=" << offsetof(StGlobal,sys) << "\n";
 std::cout << "  grade=" << offsetof(StGlobal,grade) << "\n";
 std::cout << "  gexit=" << offsetof(StGlobal,gexit) << "\n";
 std::cout << "  analogdensity=" << offsetof(StGlobal,analogdensity) << "\n";
 std::cout << "  exit=" << offsetof(StGlobal,exit) << "\n";
 std::cout << "  paras=" << offsetof(StGlobal,paras) << "\n";
 std::cout << "  motor=" << offsetof(StGlobal,motor) << "\n";
 std::cout << "  cFSMInfo=" << offsetof(StGlobal,cFSMInfo) << "\n";
 std::cout << "  nSubsysId=" << offsetof(StGlobal,nSubsysId) << "\n";
 std::cout << "  nNetState=" << offsetof(StGlobal,nNetState) << "\n";
 return 0;
}
