import 'package:english_study/constants.dart';
import 'package:english_study/download/download_manager.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:flutter/material.dart';

class DownloadBannerComponent extends StatelessWidget {
  final String text;
  final double? process;
  final bool isHasCircleBorder;
  final Function onDownloadClick;
  const DownloadBannerComponent({
    super.key,
    required this.text,
    this.process,
    this.isHasCircleBorder = false,
    required this.onDownloadClick,
  });

  @override
  Widget build(BuildContext context) {
    print("DownloadBannerComponent ${process}");
    return Row(
      children: [
        Expanded(
          child: Container(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        Container(
          width: 50,
          height: 50,
          padding: EdgeInsets.all(5),
          decoration: process == null && isHasCircleBorder
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 2, color: maastricht_blue),
                )
              : null,
          alignment: Alignment.center,
          child: process == null
              ? GestureDetector(
                  onTap: () {
                    onDownloadClick.call();
                  },
                  child: widgetIcon(
                    'assets/icons/ic_download.svg',
                    size: 28,
                    color: maastricht_blue,
                  ),
                )
              : Stack(
                  children: [
                    if ((process ?? 0) > 0)
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          process?.toInt().toString() ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    Positioned.fill(
                      child: CircularProgressIndicator(
                        color: turquoise,
                        backgroundColor: maastricht_blue,
                        value: (process ?? 0) / 100,
                      ),
                    ),
                  ],
                ),
        )
      ],
    );
  }
}
