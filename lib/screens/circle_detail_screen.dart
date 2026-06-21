import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/circle_model.dart';
import 'invite_members_screen.dart';
import 'circle_settings_screen.dart';

class CircleDetailScreen extends StatefulWidget {
  final Circle circle;

  const CircleDetailScreen({super.key, required this.circle});

  @override
  State<CircleDetailScreen> createState() => _CircleDetailScreenState();
}

class _CircleDetailScreenState extends State<CircleDetailScreen> {
  late String _circleName;

  @override
  void initState() {
    super.initState();
    _circleName = widget.circle.name;
  }

  Future<void> _leaveGroup() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gruppe verlassen'),
        content: Text('Möchtest du "$_circleName" wirklich verlassen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Verlassen'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('circles')
          .doc(widget.circle.id)
          .update({
        'members': FieldValue.arrayRemove([currentUid]),
        'memberCount': FieldValue.increment(-1),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Verlassen der Gruppe.')),
        );
      }
    }
  }

  void _openInviteScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InviteMembersScreen(
          circleId: widget.circle.id,
          circleName: _circleName,
          members: widget.circle.members,
        ),
      ),
    );
  }

  Future<void> _openSettingsScreen() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => CircleSettingsScreen(
          circle: widget.circle,
          initialName: _circleName,
        ),
      ),
    );
    if (result == null) return;
    if (result['deleted'] == true) {
      if (mounted) Navigator.pop(context, true);
    } else if (result['name'] != null) {
      setState(() => _circleName = result['name'] as String);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isCreator = currentUid == widget.circle.createdBy;

    return Scaffold(
      appBar: AppBar(
        title: Text(_circleName),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'invites':
                  _openInviteScreen();
                case 'settings':
                  _openSettingsScreen();
                case 'leave':
                  _leaveGroup();
              }
            },
            itemBuilder: (context) => isCreator
                ? [
                    const PopupMenuItem(
                      value: 'invites',
                      child: ListTile(
                        leading: Icon(Icons.person_add_outlined),
                        title: Text('Leute einladen'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'settings',
                      child: ListTile(
                        leading: Icon(Icons.settings_outlined),
                        title: Text('Einstellungen'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ]
                : [
                    const PopupMenuItem(
                      value: 'leave',
                      child: ListTile(
                        leading: Icon(Icons.exit_to_app, color: Colors.red),
                        title: Text(
                          'Gruppe verlassen',
                          style: TextStyle(color: Colors.red),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
          ),
        ],
      ),
      body: const SizedBox.expand(),
    );
  }
}
