import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gemini_demo/check_auth.dart';
import 'package:gemini_demo/my_drawer.dart';
import 'package:gemini_demo/text_field.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

const apiKey = "AIzaSyB3Uv6W5nRdmwVozd_6XDvY0m7LOBc5ISU";

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final GenerativeModel model;
  ChatSession? chat;
  ScrollController scrollController = ScrollController();
  TextEditingController textController = TextEditingController();
  FocusNode textFieldFocus = FocusNode();

  List<({String? image, String? text, bool fromUser})> generatedContent =
      <({String? image, String? text, bool fromUser})>[];

  bool isNewChat = true;

  XFile pickedImg = XFile("");
  Uint8List pickedImgBytes = Uint8List(0);

  bool loading = false;

  List sampleMessages = [
    'Can you explain the concept of "nostalgia" to a kindergartener?',
    "Tell me a random fun fact about the Roman Empire.",
    "I have a photoshoot tomorrow. Can you recommend me some colors and outfit options that will look good on camera?",
    "Given an unsorted array of integers, find the length of the longest consecutive elements sequence. Your algorithm should run in O(n) time complexity."
  ];

  List<({String id, String title})> drawerNavList = [];
  String selectedChatId = "";

  @override
  void initState() {
    super.initState();

    getChatList();

    initModel();
  }

  void getChatList() {
    FirebaseAuth auth = FirebaseAuth.instance;

    String uid = auth.currentUser!.uid;

    // get chat history from firebase
    FirebaseFirestore db = FirebaseFirestore.instance;
    db
        .collection("chat")
        .doc(uid)
        .collection("chat_history")
        .orderBy("created_at", descending: true)
        .get()
        .then((value) {
      drawerNavList.clear();

      for (var element in value.docs) {
        drawerNavList.add((id: element.id, title: element.data()["title"]));
      }

      setState(() {});
    }).onError((error, stackTrace) {
      log("error: $error");
    });
  }

  void getChatHistory(chatId) {
    try {
      // get user id
      FirebaseAuth auth = FirebaseAuth.instance;

      String uid = auth.currentUser!.uid;

      // get chat history from firebase
      FirebaseFirestore db = FirebaseFirestore.instance;
      db
          .collection("chat")
          .doc(uid)
          .collection("chat_history")
          .doc(chatId)
          .get()
          .then((value) {
        if (value.exists) {
          Map<String, dynamic> data = value.data()!;
          List history = data["history"];

          List<Content>? historyContent = [];

          if (history.isNotEmpty) {
            isNewChat = false;
            for (var element in history) {
              generatedContent.add((
                image: element["image"],
                text: element['text'],
                fromUser: element['from_user']
              ));

              historyContent.add((element['from_user']
                  ? Content.text(element['text'])
                  : Content.model([TextPart(element['text'])])));
            }

            chat = model.startChat(history: historyContent);
            scrollDown();

            setState(() {});
          }
        }
      }).onError((error, stackTrace) {
        log("error: $error");
      });
    } catch (e) {
      log("catch error: $e");
    }
  }

  void initModel({List<Content>? historyContent}) {
    debugPrint("Init model");
    model = GenerativeModel(
      model: "gemini-1.5-flash",
      apiKey: apiKey,
      generationConfig: GenerationConfig(
          temperature: 1,
          topK: 64,
          topP: 0.95,
          maxOutputTokens: 8192,
          responseMimeType: 'text/plain'),
    );

    chat = model.startChat(history: historyContent);
  }

  void scrollDown() {
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeIn,
            ));
  }

  Future<void> clearChat() async {
    generatedContent.clear();
    chat!.sendMessage(Content.text("reset"));
    textFieldFocus.requestFocus();
    setState(() {});
  }

  void logout() {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signOut();
    checkUserAuth(context);
  }

  double xOffset = 0;
  double yOffset = 0;

  void onDestinationSelected(index) {
    if (index == -1) {
      isNewChat = true;
      selectedChatId = "";
      clearChat();
    } else {
      final id = drawerNavList.elementAt(index).id;

      if (selectedChatId != id) {
        selectedChatId = id;
        clearChat();
        getChatHistory(id);
      }
    }
    setState(() {
      // xOffset = 0;
      // yOffset = 0;
    });
  }

  void deleteChat(chatId) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    db
        .collection("chat")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("chat_history")
        .doc(chatId)
        .delete()
        .then(
      (value) {
        getChatList();
        clearChat();
        selectedChatId = "";
        isNewChat = true;
        generatedContent.clear();
        // setState(() {});
      },
    ).onError((error, stackTrace) {
      showError(error.toString());
    });
    Navigator.pop(context);
  }

  void deleteChatDialog(chatId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you sure you want to delete this chat?"),
        actions: [
          FilledButton(
              onPressed: () => deleteChat(chatId),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text("Yes")),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("No")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gen-AI Demo"),
        actions: const [
          // IconButton(onPressed: clearDialog, icon: const Icon(Icons.refresh)),
          // IconButton(onPressed: logout, icon: const Icon(Icons.logout_rounded)),
        ],
        leading: IconButton(
            onPressed: () {
              if (xOffset == 0) {
                setState(() {
                  xOffset = 300;
                  yOffset = 0;
                });
              } else {
                setState(() {
                  xOffset = 0;
                  yOffset = 0;
                });
              }
            },
            icon: const Icon(Icons.menu)),
      ),
      body: Stack(
        children: [
          MyDrawer(
            drawerNavList: drawerNavList,
            onDestinationSelected: onDestinationSelected,
            selectedChatId: selectedChatId,
            onDelete: deleteChatDialog,
          ),
          GestureDetector(
            onTap: () => {
              if (xOffset != 0)
                setState(() {
                  xOffset = 0;
                  yOffset = 0;
                }),
              textFieldFocus.requestFocus(),
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              transform: Matrix4.translationValues(xOffset, yOffset, 0),
              curve: Curves.easeInOut,
              child: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      Expanded(
                        child: CustomScrollView(
                          controller: scrollController,
                          shrinkWrap: true,
                          slivers: [
                            if (generatedContent.isEmpty && isNewChat)
                              SliverToBoxAdapter(
                                child: EmptyChatWidget(
                                  onTap: (index) {
                                    sendChatMessage(sampleMessages[index]);
                                  },
                                  sampleMessages: sampleMessages,
                                ),
                              ),
                            SliverPadding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              sliver: SliverList.builder(
                                itemCount: generatedContent.length,
                                itemBuilder: (context, index) {
                                  final content = generatedContent[index];

                                  if (loading &&
                                      index == generatedContent.length - 1) {
                                    return Row(
                                      mainAxisAlignment: content.fromUser
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Shimmer.fromColors(
                                            baseColor:
                                                Theme.of(context).focusColor,
                                            highlightColor: Theme.of(context)
                                                .highlightColor
                                                .withOpacity(0.5),
                                            child: Container(
                                              width: MediaQuery.sizeOf(context)
                                                  .width,
                                              height: 200,
                                              margin:
                                                  const EdgeInsets.all(16.0),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                color: content.fromUser
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primaryContainer
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .surfaceContainerHighest,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }

                                  return MessageWidget(
                                    isFromUser: content.fromUser,
                                    text: content.text,
                                    image: content.image,
                                  ).animate().fadeIn(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeIn);
                                },
                              ),
                            )
                          ],
                        ),
                      ),

                      // PromptField

                      PromptField(
                        loading: loading,
                        textFieldFocus: textFieldFocus,
                        textController: textController,
                        onSubmitted: (value) => pickedImg.path.isNotEmpty
                            ? sendImgPrompt(value)
                            : value.isNotEmpty
                                ? sendChatMessage(value)
                                : null,
                        webPickedImg: pickedImgBytes,
                        pickedImg: pickedImg,
                        removeImg: () {
                          setState(() {
                            pickedImg = XFile("");
                            pickedImgBytes = Uint8List(0);
                          });
                        },
                        suffix: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: loading
                                    ? null
                                    : () async {
                                        pickImage();
                                      },
                                style: IconButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    iconSize: 20,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.primary),
                                icon: const Icon(
                                    Icons.add_photo_alternate_rounded)),
                            if (!loading)
                              ValueListenableBuilder(
                                valueListenable: textController,
                                builder: (context, value, child) =>
                                    IconButton.filled(
                                        onPressed: value.text.isEmpty
                                            ? null
                                            : () {
                                                if (pickedImg.path.isNotEmpty) {
                                                  sendImgPrompt(value.text);
                                                  return;
                                                } else {
                                                  sendChatMessage(value.text);
                                                }
                                              },
                                        style: IconButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          iconSize: 20,
                                        ),
                                        icon: const Icon(Icons.send_rounded)),
                              )
                            else
                              const SizedBox.square(
                                  dimension: 24,
                                  child: CircularProgressIndicator(
                                      strokeCap: StrokeCap.round)),
                            const SizedBox.square(dimension: 15)
                          ],
                        ),
                      ),

                      Text(
                        "Gen-AI may display inaccurate info, including about people, so double-check its responses before using them.",
                        style: Theme.of(context).textTheme.labelSmall,
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      var imgBytes = await image.readAsBytes();

      image.readAsBytes().then((value) => imgBytes = value);
      setState(() {
        pickedImg = image;
        pickedImgBytes = imgBytes;
      });
    }
  }

  void saveNewChatData(data) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    String uid = auth.currentUser!.uid;

    final db = FirebaseFirestore.instance;

    log("saveNewChatData");

    db
        .collection("chat")
        .doc(uid)
        .collection("chat_history")
        .add(data)
        .then((value) {
      setState(() {
        selectedChatId = value.id;
      });
    }).catchError((e) {
      showError(e.toString());
    });
  }

  void updateChatData(data) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    String uid = auth.currentUser!.uid;
    final db = FirebaseFirestore.instance;
    log("updateChatData");

    db
        .collection("chat")
        .doc(uid)
        .collection("chat_history")
        .doc(selectedChatId)
        .update({"history": FieldValue.arrayUnion(data)});
  }

  Future<void> sendChatMessage(String message) async {
    textFieldFocus.unfocus();
    setState(() {
      loading = true;
    });
    try {
      generatedContent.add((image: null, text: message, fromUser: true));
      scrollDown();

      final response = await chat!.sendMessage(Content.text(message));

      final resText = response.text;

      generatedContent.add((image: null, text: resText, fromUser: false));

      // log("generatedContent: $generatedContent");

      var historyTemp = [];

      Map<String, dynamic> data = {
        "title": message,
        "created_at": DateTime.now(),
        "history": historyTemp,
      };

      if (resText == null) {
        showError("No response");
        return;
      } else {
        loading = false;

        scrollDown();

        if (isNewChat) {
          // new chat
          for (var element in generatedContent) {
            historyTemp.add({
              "text": element.text,
              "image": element.image,
              "from_user": element.fromUser
            });
          }
          isNewChat = false;
          saveNewChatData(data);
          getChatList();
        } else {
          // continue chat
          isNewChat = false;
          for (var i = generatedContent.length - 2;
              i < generatedContent.length;
              i++) {
            historyTemp.add({
              "text": generatedContent[i].text,
              "image": generatedContent[i].image,
              "from_user": generatedContent[i].fromUser
            });
          }

          updateChatData(historyTemp);
          setState(() {});
        }
      }
    } catch (e) {
      showError(e.toString());
      setState(() {
        loading = false;
      });
    } finally {
      textController.clear();
      textFieldFocus.requestFocus();

      setState(() {
        loading = false;
      });

      scrollDown();
    }
  }

  Future<void> sendImgPrompt(String message) async {
    textFieldFocus.unfocus();

    setState(() {
      loading = true;
    });

    try {
      final content = Content.multi([
        TextPart(message),
        DataPart(pickedImg.mimeType ?? "image/jpeg", pickedImgBytes),
      ]);

      generatedContent.add((
        image: kIsWeb ? jsonEncode(pickedImgBytes) : pickedImg.path,
        text: message,
        fromUser: true
      ));

      final response = await chat!.sendMessage(content);

      final resText = response.text;

      generatedContent.add((image: null, text: resText, fromUser: false));

      if (resText == null) {
        showError("No response");
        return;
      } else {
        setState(() {
          loading = false;
        });
        scrollDown();
      }
    } catch (e) {
      showError(e.toString());
      setState(() {
        loading = false;
      });
    } finally {
      textController.clear();
      textFieldFocus.requestFocus();

      setState(() {
        loading = false;
        pickedImg = XFile("");
      });

      scrollDown();
    }
  }

  void showError(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog.adaptive(
              title: const Text("Error"),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("OK")),
              ],
            ));
  }
}

class MessageWidget extends StatelessWidget {
  const MessageWidget(
      {super.key, this.text, this.image, required this.isFromUser});
  final String? text;
  final String? image;
  final bool isFromUser;

  @override
  Widget build(BuildContext context) {
    Uint8List getImageBinary(dynamicList) {
      List<int> intList =
          dynamicList.cast<int>().toList(); //This is the magical line.
      Uint8List data = Uint8List.fromList(intList);
      return data;
    }

    double width = MediaQuery.of(context).size.width;
    double widtht = width > 600 ? width * 0.7 : width * 0.6;

    return Row(
      mainAxisAlignment:
          isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: isFromUser ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Container(
                width: 45,
                height: 45,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isFromUser
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: isFromUser
                    ? const Icon(Icons.person_rounded)
                    : Transform.rotate(
                        angle: 3.14 / 4,
                        child: Image.asset(
                            "assets/images/google-gemini-icon.png")),
              ),
              const SizedBox.square(dimension: 10),
              Container(
                constraints: BoxConstraints(maxWidth: widtht),
                decoration: BoxDecoration(
                  color: isFromUser
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(18),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (text case final text?)
                      MarkdownBody(
                        data: text,
                        selectable: true,
                      ),
                    if (image case final image?)
                      Container(
                        height: 200,
                        width: 200,
                        clipBehavior: Clip.antiAlias,
                        margin: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: kIsWeb
                            ? Image.memory(getImageBinary(jsonDecode(image)),
                                fit: BoxFit.cover)
                            : Image.file(File(image), fit: BoxFit.cover),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EmptyChatWidget extends StatelessWidget {
  const EmptyChatWidget(
      {super.key, required this.onTap, required this.sampleMessages});

  final Function onTap;
  final List sampleMessages;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.rotate(
                  angle: 3.14 / 4,
                  child: Image.asset(
                    "assets/images/google-gemini-icon.png",
                    height: 100,
                    width: 100,
                  ),
                ),
                const SizedBox.square(dimension: 10),
                Text("How can i help you?",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
          ),
          const SizedBox.square(dimension: 20),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.8),
            child: Wrap(
                spacing: 15,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: List.generate(
                    sampleMessages.length,
                    (index) => ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 310,
                            minWidth: 310,
                            maxHeight: 80,
                            minHeight: 80,
                          ),
                          child: Material(
                            child: InkWell(
                              onTap: () => onTap(index),
                              borderRadius: BorderRadius.circular(10),
                              child: Ink(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    sampleMessages[index],
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ))),
          ),
        ],
      ),
    );
  }
}
