import 'package:openwrt_manager/OpenWRT/Model/CommandReplyBase.dart';
import 'package:openwrt_manager/OpenWRT/Model/HostHintReply.dart';
import 'package:openwrt_manager/OpenWRT/Model/NetworkDeviceReply.dart';
import 'package:openwrt_manager/OpenWRT/Model/NetworkInterfaceReply.dart';
import 'package:openwrt_manager/OpenWRT/Model/ReplyBase.dart';
import 'package:openwrt_manager/OpenWRT/Model/SystemBoardReply.dart';
import 'package:openwrt_manager/OpenWRT/Model/SystemInfoReply.dart';
import 'package:openwrt_manager/OpenWRT/Model/WifiAssociatedClientReply.dart';
import 'package:openwrt_manager/OpenWRT/Model/WirelessDeviceReply.dart';

enum OverviewItemType
{
  SystemInfo,
  NetworkStatus,
  NetworkTraffic,
  WifiStatus,
}

class OverviewItem
{
  OverviewItem(this.displayName, this.type, this.commands);

  final String displayName;  
  final OverviewItemType type;
  final List<CommandReplyBase> commands;
}
class OverviewItemManager
{
  static Map<String,OverviewItem>  items =
  {    
    // do not change guids , they are stored on app device configuration files    
    '1bad2951-ee53-4ee4-95b6-ced2ed816b32' : OverviewItem("System Info", OverviewItemType.SystemInfo , [SystemInfoReply(ReplyStatus.Ok), SystemBoardReply(ReplyStatus.Ok)]),
    '96630e65-4da2-4d1b-81d1-7f6716d0d0cf' : OverviewItem("Network Status", OverviewItemType.NetworkStatus , [NetworkInterfaceReply(ReplyStatus.Ok)]),
    'db7b2fe8-cf9b-4a01-bce4-c56e293d458a' : OverviewItem("Network Traffic", OverviewItemType.NetworkTraffic , [NetworkDeviceReply(ReplyStatus.Ok),NetworkInterfaceReply(ReplyStatus.Ok)]),
    '25bafd01-816f-4d76-a88c-ef49a6120fa2' : OverviewItem("WIFI Status", OverviewItemType.WifiStatus , [HostHintReply(ReplyStatus.Ok),WirelessDeviceReply(ReplyStatus.Ok),WifiAssociatedClientReply(ReplyStatus.Ok)]),    
  };
}