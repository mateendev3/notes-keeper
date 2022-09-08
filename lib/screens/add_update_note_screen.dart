// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../databases/db_helper.dart';
import '../models/note.dart';
import 'components/action_button_widget.dart';
import 'components/action_icon_widget.dart';
import 'components/description_text_field_widget.dart';
import 'components/title_text_field_widget.dart';

class AddUpdateNoteScreen extends StatefulWidget {
  const AddUpdateNoteScreen({Key? key, this.note}) : super(key: key);

  final Note? note;

  @override
  State<AddUpdateNoteScreen> createState() => _AddUpdateNoteScreenState();
}

class _AddUpdateNoteScreenState extends State<AddUpdateNoteScreen> {
  late Size _size;
  late DBHelper _db;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late Note _note;

  @override
  void initState() {
    super.initState();

    _db = DBHelper();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _titleController.text = widget.note?.title ?? '';
    _descriptionController.text = widget.note?.description ?? '';
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: buildActionIcon(
        icon: Icons.arrow_back,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.pop(context);
        },
        rightMargin: 0.0,
        leftMargin: 15.0,
      ),
      actions: [
        buildActionButton(context, text: "Save", onTap: onTapSave),
      ],
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: EdgeInsets.only(
        left: _size.height * 0.015,
        right: _size.height * 0.015,
        bottom: _size.height * 0.015,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TitleTextField(
              size: _size,
              controller: _titleController,
            ),
            Expanded(
              child: DescriptionTextField(
                size: _size,
                controller: _descriptionController,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onTapSave() async {
    bool isValid = _formKey.currentState!.validate();

    if (isValid) {
      if (widget.note != null) {
        await updateNote();
        Navigator.pop(context, _note);
      } else {
        await insertNote();
        Navigator.pop(context);
      }
    }
  }

  Future<void> updateNote() async {
    _note = widget.note!.copyWith(
      title: _titleController.text,
      description: _descriptionController.text,
    );
    await _db.updateNote(_note);
  }

  Future<void> insertNote() async {
    await _db.insertNote(
      Note(
        title: _titleController.text,
        description: _descriptionController.text,
        time: DateTime.now(),
      ),
    );
  }
}
