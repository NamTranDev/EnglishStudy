import 'package:english_study/constants.dart';
import 'package:flutter/material.dart';

class DownloadComponent extends StatelessWidget {
  final double? process;
  final Color? colorProcess;
  const DownloadComponent({super.key, this.process, this.colorProcess});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if ((process ?? 0) > 0)
          Align(
            alignment: Alignment.center,
            child: Text(
              process?.toInt().toString() ?? '',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colorProcess ?? maastricht_blue),
            ),
          ),
        Positioned.fill(
          child: CircularProgressIndicator(
            color: turquoise,
            backgroundColor: colorProcess ?? maastricht_blue,
            value: (process ?? 0) > 0
                ? (process ?? 0) / 100
                : null,
          ),
        )
      ],
    );
  }
}
