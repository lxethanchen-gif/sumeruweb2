import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart'; // 引入高效連結啟動器
import 'footer.dart';

class ResourceLinksPage extends StatelessWidget {
  const ResourceLinksPage({super.key});

  // ── APK 下載連結 ──
  // static const String _apkUrl = 'https://drive.google.com/file/d/1-CIfgUfsr2xkft1LRjbDQt1sXlY9REiZ/view?usp=sharing';

  // 靜態資料常數化（整合 9 種語言版本與對應的下載連結）── 第一區塊
  static const List<Map<String, String>> _resources1 = [
    {'title': '繁體中文', 'url': 'https://drive.google.com/file/d/1XPGA6mJumCgLtzrntlkqD4XuclyYpEbA/view?usp=sharing'},
    {'title': '簡體中文', 'url': 'https://drive.google.com/file/d/1wRMRXRqheVz5khQQwJoedI3kYoUGMxCQ/view?usp=sharing'},
    {'title': '英文', 'url': 'https://drive.google.com/file/d/1YAJC8utgU-EPM9QDIjGbSVG90XRQWAg6/view?usp=sharing'},
    {'title': '日文', 'url': 'https://drive.google.com/file/d/1KW2brE_giwkeX2yNxBWPYU3Xr7kNs7me/view?usp=sharing'},
  ];

  // 靜態資料常數化（整合 9 種語言版本與對應的下載連結）── 第二區塊
  static const List<Map<String, String>> _resources2 = [
    {'title': '繁體中文', 'url': 'https://drive.google.com/file/d/1pElReRzRx8ZVoe_IMATcGl6M3zfwqXxt/view?usp=drive_link'},
    {'title': '簡體中文', 'url': 'https://drive.google.com/file/d/18W2HS-zj6nswu1Oo14PAZoMELo31Ll-M/view?usp=drive_link'},
    // {'title': '英文', 'url': 'https://drive.google.com/file/d/1Tlmv2ivfAJkxUzr-MJLMNAlVzTUnuZNZ/view?usp=drive_link'},
    {'title': '日文', 'url': 'https://drive.google.com/file/d/1Ne3y4s2KSt0GPdvSwnkSRY2-BoYjRhPU/view?usp=drive_link'},
    {'title': '法文', 'url': 'https://drive.google.com/file/d/1QrXGKVekq8TK543V0aqM5GGbPf-4Fz87/view?usp=drive_link'},
    {'title': '德文', 'url': 'https://drive.google.com/file/d/1BPH2glM2HH-ILSKONklLZwPYEYRanQx_/view?usp=drive_link'},
    {'title': '西班牙文', 'url': 'https://drive.google.com/file/d/1cbRKjIKSCdUpXr12K8fp7jHs0ALfx8gw/view?usp=drive_link'},
    {'title': '葡萄牙文', 'url': 'https://drive.google.com/file/d/1P5qrzgRZR4mGE7dCuqVFkPcYBlxDXdKs/view?usp=drive_link'},
    {'title': '義大利文', 'url': 'https://drive.google.com/file/d/1P0QJ9739snEhOGjy922nydcbYrqOF_yC/view?usp=drive_link'},
    {'title': '泰文', 'url': 'https://drive.google.com/file/d/1mXjwaGgPrqGhsUVprtciP_QBFtV91ykD/view?usp=drive_link'},
    {'title': '印度文', 'url': 'https://drive.google.com/file/d/1NKFpBMNXTrACkQZgoFQSW9S0_R_nP8Vk/view?usp=drive_link'},
    {'title': '阿拉伯文', 'url': 'https://drive.google.com/file/d/1mW4MvAfqYyT9kZ419jr0G2ziaThT5DZo/view?usp=drive_link'},
    {'title': '韓文', 'url': 'https://drive.google.com/file/d/1orN66VwCI042wiR2YupUGkseWI69qXDQ/view?usp=drive_link'},
    {'title': '俄文', 'url': 'https://drive.google.com/file/d/1KGUXTIY64ha3Ea_XHH2tFUe_tWV533Ta/view?usp=drive_link'},
  ];

  // ── 第三區塊連結 ──
  static const List<Map<String, String>> _resources3 = [
    {'title': '繁體中文', 'url': 'https://drive.google.com/file/d/1RXWiutokfDbqkJ0fCfyvI_uAeq_EflvB/view?usp=drive_link'},
    {'title': '簡體中文', 'url': 'https://drive.google.com/file/d/1ltLkkWkUDqf11IMrpVOsKWAkMG6pZBV1/view?usp=drive_link'},
    // {'title': '英文', 'url': 'https://drive.google.com/file/d/1GHJ35sGZaH-2okrSMPhkxLz1JQUqdtF_/view?usp=drive_link'},
    {'title': '日文', 'url': 'https://drive.google.com/file/d/1TrH9kn3BhNINiyNPx5nB_Yn35KxlI39Y/view?usp=drive_link'},
    {'title': '韓文', 'url': 'https://drive.google.com/file/d/164JW7YuZjWXjQkKiaF93gejYTwNi9pf5/view?usp=drive_link'},
    {'title': '法文', 'url': 'https://drive.google.com/file/d/1vNGTnWaJg8YutKif6uBBfU5B8wAjNB3-/view?usp=drive_link'},
    {'title': '德文', 'url': 'https://drive.google.com/file/d/1a5jgBvko_kp5AXb20WGJihe3OCz5HAEj/view?usp=drive_link'},
    {'title': '西班牙文', 'url': 'https://drive.google.com/file/d/1hwZuIuxI4I7d4ueZvvsjtxhx_eduItyv/view?usp=drive_link'},
    {'title': '葡萄牙文', 'url': 'https://drive.google.com/file/d/1ScoXlhu3O_Ij7B3ZqEzsS_jhUyxEtKAi/view?usp=drive_link'},
    {'title': '義大利文', 'url': 'https://drive.google.com/file/d/1M-p923XPDTI58GTphqLaOT1GaYhv5eZq/view?usp=drive_link'},
    {'title': '拉丁文', 'url': 'https://drive.google.com/file/d/1yTVtPyHRUugpDTu-OFnMeI_w_SRj6Y-0/view?usp=drive_link'},
    {'title': '泰文', 'url': 'https://drive.google.com/file/d/1FwSKYN98G7Wc9nIN7OAYjtJ4msW-Rf53/view?usp=drive_link'},
    {'title': '尼泊爾文', 'url': 'https://drive.google.com/file/d/15vXT64HdYDKFp8QQYJSCCvLvfJ8mdZkk/view?usp=drive_link'},
    {'title': '印度文', 'url': 'https://drive.google.com/file/d/1xmNVR6UZdQMKoFzL7MUUUJ7uMGrSUo1n/view?usp=drive_linkf'},
    {'title': '孟加拉文', 'url': 'https://drive.google.com/file/d/1koYi9kQchY0oFn2zkaiwLEcQFx3fGeHk/view?usp=drive_link'},
    {'title': '阿拉伯文', 'url': 'https://drive.google.com/file/d/1hdo7DGzn-j6-UXpA-_7bnx5WyjuEBb-0/view?usp=drive_link'},
    {'title': '印尼文', 'url': 'https://drive.google.com/file/d/1jqdQRyVcNfn21CL29d6zpaEf1Uq0f9M5/view?usp=drive_link'},
    {'title': '越南文', 'url': 'https://drive.google.com/file/d/1wZ7Ed4eHNhexvIhys1b8MQVDdQNnyV4O/view?usp=drive_link'},
    {'title': '波斯文', 'url': 'https://drive.google.com/file/d/16Y_rMOKiMCI_v6iUm-Wy6RYyVoxFGWqy/view?usp=drive_link'},
  ];

  // 異步高效下載邏輯
  Future<void> _downloadFile(BuildContext context, String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('無法開啟下載連結'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  // 共用的 Wrap 卡片區塊
  Widget _buildResourceWrap(BuildContext context, double cardSize, List<Map<String, String>> resources) {
    return Wrap(
      alignment: WrapAlignment.center, // 修正：讓 Wrap 內部的子元件水平置中
      spacing: 8,
      runSpacing: 8,
      children: resources.map((item) => InkWell(
        onTap: () => _downloadFile(context, item['url']!),
        borderRadius: BorderRadius.circular(6),
        child: Ink(
          width: cardSize, height: cardSize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8, offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 2, offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 22),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item['title']!,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double cardSize = ((MediaQuery.of(context).size.width - 64) / 6).clamp(48.0, 100.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 32, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // 修正：垂直方向置中（若內容沒超出螢幕）
                  crossAxisAlignment: CrossAxisAlignment.center, // 修正：水平方向置中
                  children: [

                    // ── APK 下載按鈕 ──
                    // const Text(
                      // '須彌山佛國學習 APP APK Links(還未更新):',
                      // textAlign: TextAlign.center, // 修正：文字本身置中
                      // style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(221, 255, 179, 2)),
                    // ),
                    // const SizedBox(height: 12),
                    // ElevatedButton.icon(
                      // onPressed: () => _downloadFile(context, _apkUrl),
                      // icon: const Icon(Icons.android, color: Colors.white, size: 18),
                      // label: const Text('點擊下載 APK', style: TextStyle(fontSize: 14, color: Colors.white)),
                      // style: ElevatedButton.styleFrom(
                        // backgroundColor: const Color(0xFF4CAF50),
                        // padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      // ),
                    // ),

                    // const SizedBox(height: 40),

                    // ── 第一區塊 ──
                    const Text(
                      '須彌山佛國 戒律 4國語言翻譯', 
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(221, 255, 179, 2))
                    ),
                    const SizedBox(height: 20),
                    _buildResourceWrap(context, cardSize, _resources1),

                    const SizedBox(height: 40),

                    // ── 第二區塊 ──
                    const Text(
                      '了解佛法 14國語言翻譯', 
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(221, 255, 179, 2))
                    ),
                    const SizedBox(height: 20),
                    _buildResourceWrap(context, cardSize, _resources2),

                    const SizedBox(height: 40),

                    // ── 第三區塊 ──
                    const Text(
                      '文字開示 19國語言翻譯', 
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(221, 255, 179, 2))
                    ),
                    const SizedBox(height: 20),
                    _buildResourceWrap(context, cardSize, _resources3),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SumeruFooter(),
            ],
          ),
        ),
      ),
    );
  }
}