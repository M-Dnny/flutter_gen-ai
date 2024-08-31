import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class PromptField extends StatefulWidget {
  const PromptField({
    super.key,
    required this.textFieldFocus,
    required this.textController,
    required this.onSubmitted,
    required this.suffix,
    required this.webPickedImg,
    required this.pickedImg,
    required this.removeImg,
    required this.loading,
  });

  final FocusNode textFieldFocus;
  final TextEditingController textController;
  final Function(String) onSubmitted;
  final Widget suffix;
  final Uint8List webPickedImg;
  final XFile pickedImg;
  final Function() removeImg;
  final bool loading;

  @override
  State<PromptField> createState() => PromptFieldState();
}

class PromptFieldState extends State<PromptField> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    return Container(
      width: width > 600 ? width * 0.7 : width,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.pickedImg.path.isNotEmpty)
            Stack(
              children: [
                Container(
                  height: 80,
                  width: 80,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                  child: kIsWeb
                      ? Image.memory(widget.webPickedImg)
                      : Image.file(File(widget.pickedImg.path),
                          fit: BoxFit.cover),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: IconButton.filled(
                    onPressed: widget.removeImg,
                    icon: const Icon(Icons.remove_rounded),
                    style: IconButton.styleFrom(
                        minimumSize: const Size(20, 20),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.zero),
                  ),
                ),
              ],
            ),
          const SizedBox.square(dimension: 5),
          TextField(
            focusNode: widget.textFieldFocus,
            controller: widget.textController,
            onSubmitted: widget.onSubmitted,
            enabled: !widget.loading,
            autofocus: true,
            maxLines: 1000,
            minLines: 1,
            textInputAction: TextInputAction.send,
            decoration: InputDecoration(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.3),
              border: InputBorder.none,
              hintText: "Enter a prompt here",
              filled: true,
              contentPadding: width > 600 ? const EdgeInsets.all(20) : null,
              fillColor: Theme.of(context).highlightColor,
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              focusColor: Theme.of(context).primaryColorDark,
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(
                  Radius.circular(50),
                ),
              ),
              disabledBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(
                  Radius.circular(50),
                ),
              ),
              suffixIcon: widget.suffix,
              suffixIconColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
