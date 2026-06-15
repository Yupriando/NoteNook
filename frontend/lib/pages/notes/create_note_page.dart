import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/note_service.dart';
import 'package:image_picker/image_picker.dart';

class CreateNotePage extends StatefulWidget {
  final int? folderId;

  final Map? note;

  const CreateNotePage({super.key, this.folderId, this.note});

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  String visibility = "private";

  List<File> selectedFiles = [];

  bool loading = false;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final picker = ImagePicker();

  Future pickImage() async {
    final images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        selectedFiles.addAll(images.map((e) => File(e.path)));
      });
    }
  }

  Future pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        selectedFiles.addAll(result.files.map((e) => File(e.path!)));
      });
    }
  }

  Future saveNote() async {
    if (titleController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      loading = true;
    });

    final result = widget.note == null
        ? await NoteService.createNote(
            title: titleController.text,
            description: descriptionController.text,
            visibility: visibility,
            folderId: widget.folderId,
            files: selectedFiles,
          )
        : await NoteService.updateNote(
            id: widget.note!["id"],
            title: titleController.text,
            description: descriptionController.text,
            visibility: visibility,
            folderId: widget.folderId,
            files: selectedFiles,
          );

    setState(() {
      loading = false;
    });

    if (result["status"] == 201 || result["status"] == 200) {
      if (context.mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      titleController.text = widget.note!["title"];
      descriptionController.text = widget.note!["description"] ?? "";
      visibility = widget.note!["visibility"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 119, 255),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.note == null ? "Create Note" : "Edit Note",
          style: const TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              widget.note == null ? "Create Note" : "Edit Note",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              widget.note == null
                  ? "Organize your knowledge and share it with others"
                  : "Update your note and keep it organized",
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Title",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: titleController,

                    decoration: InputDecoration(
                      hintText: "Enter note title",
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),

                        borderSide: const BorderSide(
                          color: Color(0xFF0077FF),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: descriptionController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: "Write your note here...",
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),

                        borderSide: const BorderSide(
                          color: Color(0xFF0077FF),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Visibility",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField(
                    value: visibility,

                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),

                    items: const [
                      DropdownMenuItem(
                        value: "private",
                        child: Row(
                          children: [
                            Icon(Icons.lock_outline),
                            SizedBox(width: 8),
                            Text("Private"),
                          ],
                        ),
                      ),

                      DropdownMenuItem(
                        value: "public",
                        child: Row(
                          children: [
                            Icon(Icons.public),
                            SizedBox(width: 8),
                            Text("Public"),
                          ],
                        ),
                      ),
                    ],

                    onChanged: (value) {
                      setState(() {
                        visibility = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 25),

                  if (selectedFiles.isNotEmpty)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,

                      children: selectedFiles.map((file) {
                        return Container(
                          padding: const EdgeInsets.all(12),

                          decoration: BoxDecoration(
                            color: const Color(0xFFDCEBFF),
                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: Row(
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              const Icon(
                                Icons.attach_file,
                                color: Color(0xFF0077FF),
                              ),

                              const SizedBox(width: 8),

                              SizedBox(
                                width: 120,
                                child: Text(
                                  file.path.split("/").last,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    selectedFiles.remove(file);
                                  });
                                },

                                icon: const Icon(Icons.close, size: 18),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                  if (selectedFiles.isNotEmpty) const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDCEBFF),
                            foregroundColor: const Color(0xFF0077FF),
                            padding: const EdgeInsets.symmetric(vertical: 15),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text("Image"),
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0077FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),

                          onPressed: pickFile,
                          icon: const Icon(Icons.attach_file),
                          label: const Text("File"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
        color: Colors.white,
        child: SizedBox(
          height: 60,

          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 0, 119, 255),
              foregroundColor: Colors.white,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            onPressed: loading ? null : saveNote,

            child: loading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  )
                : Text(
                    widget.note == null ? "Create Note" : "Update Note",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
