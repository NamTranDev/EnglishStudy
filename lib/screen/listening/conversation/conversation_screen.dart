import 'package:english_study/reuse/component/back_screen_component.dart';
import 'package:english_study/screen/listening/conversation/conversation_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConversationScreen extends StatefulWidget {
  static String routeName = '/conversation';
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: ConversationViewModel(),
      child: Scaffold(body: SafeArea(child: BackScreenComponent(
        child: Consumer<ConversationViewModel>(
            builder: (context, viewModel, child) {
          return FutureBuilder(
            future: viewModel.conversationDetail(
                ModalRoute.of(context)?.settings.arguments as String?),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                      "Something wrong with message: ${snapshot.error.toString()}"),
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return Container(
                  child: Center(
                    child: Text(snapshot.data?.conversation_lession ?? ''),
                  ),
                );
              }
            },
          );
        }),
      ))),
    );
  }
}
