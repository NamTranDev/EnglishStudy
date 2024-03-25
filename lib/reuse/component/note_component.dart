import 'package:english_study/constants.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class NoteComponent extends StatefulWidget {
  final String? text;
  final Function onNote;
  final String? note;
  final bool? isFirst;
  const NoteComponent({
    super.key,
    required this.text,
    required this.onNote,
    this.note,
    this.isFirst,
  });

  @override
  State<NoteComponent> createState() => _NoteComponentState();
}

class _NoteComponentState extends State<NoteComponent> {
  final tooltipController = JustTheController();
  final inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var iPref = getIt<Preference>();
    bool isGuideNote = false;
    if (widget.isFirst == true) {
      isGuideNote = iPref.isGuideNote();
    }
    if (isGuideNote) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        tooltipController.showTooltip();
      });
    }
    return JustTheTooltip(
      backgroundColor: maastricht_blue,
      controller: tooltipController,
      triggerMode: TooltipTriggerMode.manual,
      tailBaseWidth: 10.0,
      isModal: true,
      borderRadius: BorderRadius.circular(8.0),
      offset: 5,
      onDismiss: () {
        if (isGuideNote) {
          widget.onNote.call(null);
        }
      },
      content: Container(
        padding: EdgeInsets.all(10),
        child: RichText(
            text: TextSpan(children: [
          TextSpan(
            text: isGuideNote ? 'Noted' : (widget.note ?? ''),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
          if (!isGuideNote) TextSpan(text: '  '),
          if (!isGuideNote)
            WidgetSpan(
              child: GestureDetector(
                onTap: () {
                  tooltipController.hideTooltip();
                  showAlert(widget.text, widget.note);
                },
                child: widgetIcon('assets/icons/ic_note.svg',
                    size: 20, color: Colors.white.withOpacity(0.8)),
              ),
            )
        ])),
      ),
      child: GestureDetector(
        onTap: () {
          if (widget.note == null) {
            showAlert(widget.text, widget.note);
          } else {
            tooltipController.showTooltip();
          }
        },
        child: widgetIcon('assets/icons/ic_note.svg',
            size: 20, color: widget.note == null ? maastricht_blue : turquoise),
      ),
    );
  }

  void showAlert(String? text, String? note) {
    inputController.text = note ?? '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                controller: inputController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(labelText: 'Note'),
              )
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                if (note != null || inputController.text.isNotEmpty) {
                  widget.onNote.call(inputController.text);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
