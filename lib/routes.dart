/// 頁面索引常數，對應 MainShell._pages 的順序
class PageIndex {
  static const int home = 0;
  static const int dharmaRealize = 1;
  static const int yingShiJuan = 2;
  static const int mieZuiJuan = 3;
  static const int jiYuanDaoZhi = 4;
  static const int shiZhai = 5;
  static const int videoTeachings = 6;
  static const int resourceLinks = 7;
  static const int buddhaIntro = 8;
  static const int liveStream = 9;
  static const int classroomVideoTeachings = 10;

  /// 文字開示的子頁面範圍
  static bool isTextTeachings(int index) => index >= 1 && index <= 6;
}

/// 路由路徑常數
class AppRoutes {
  static const String home = '/';
  static const String dharmaRealize = '/dharma_realize';
  static const String yingShiJuan = '/ying_shi_juan';
  static const String mieZuiJuan = '/mie_zui_juan';
  static const String jiYuanDaoZhi = '/ji_yuan_dao_zhi';
  static const String shiZhai = '/shi_zhai';
  static const String videoTeachings = '/video_teachings';
  static const String resourceLinks = '/resource_links';
  static const String buddhaIntro = '/buddha_intro';
  static const String liveStream = '/live_stream';
  static const String classroomVideoTeachings = '/classroom_video_teachings';

  /// 路由路徑 → PageIndex 對照表
  static int pageIndexOf(String path) {
    switch (path) {
      case home:
        return PageIndex.home;
      case dharmaRealize:
        return PageIndex.dharmaRealize;
      case yingShiJuan:
        return PageIndex.yingShiJuan;
      case mieZuiJuan:
        return PageIndex.mieZuiJuan;
      case jiYuanDaoZhi:
        return PageIndex.jiYuanDaoZhi;
      case shiZhai:
        return PageIndex.shiZhai;
      case videoTeachings:
        return PageIndex.videoTeachings;
      case resourceLinks:
        return PageIndex.resourceLinks;
      case buddhaIntro:
        return PageIndex.buddhaIntro;
      case liveStream:
        return PageIndex.liveStream;
      case classroomVideoTeachings:
        return PageIndex.classroomVideoTeachings;
      default:
        return PageIndex.home;
    }
  }

  /// PageIndex → 路由路徑對照表
  static String pathOf(int index) {
    switch (index) {
      case PageIndex.home:
        return home;
      case PageIndex.dharmaRealize:
        return dharmaRealize;
      case PageIndex.yingShiJuan:
        return yingShiJuan;
      case PageIndex.mieZuiJuan:
        return mieZuiJuan;
      case PageIndex.jiYuanDaoZhi:
        return jiYuanDaoZhi;
      case PageIndex.shiZhai:
        return shiZhai;
      case PageIndex.videoTeachings:
        return videoTeachings;
      case PageIndex.resourceLinks:
        return resourceLinks;
      case PageIndex.buddhaIntro:
        return buddhaIntro;
      case PageIndex.liveStream:
        return liveStream;
      case PageIndex.classroomVideoTeachings:
        return classroomVideoTeachings;
      default:
        return home;
    }
  }
}
