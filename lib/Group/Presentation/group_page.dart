import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartsplitclient/Expense/Presentation/your_expenses_page.dart';
import 'package:smartsplitclient/Group/Model/group.dart';
import 'package:smartsplitclient/Group/Presentation/choose_group_members.dart';
import 'package:smartsplitclient/Group/State/group_state.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Groups',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'add') {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, _, _) => ChooseGroupMemberPage(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'add',
                    child: Text('Add Group'),
                  ),
                ],
          ),
        ],
      ),
      body: Consumer<GroupState>(
        builder: (context, groupState, child) {
          final groups = groupState.myGroups;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child:
                      groupState.isLoadingGroups && groups.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : RefreshIndicator(
                            onRefresh: () async {
                              await groupState.getMyGroups();
                            },
                            child:
                                groups.isEmpty
                                    ? ListView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      children: const [
                                        Padding(
                                          padding: EdgeInsets.only(top: 50),
                                          child: Center(
                                            child: Text(
                                              'You currently have no groups',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                    : ListView.builder(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      itemCount: groups.length,
                                      itemBuilder: (context, index) {
                                        final Group group = groups[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12.0,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor:
                                                      colorScheme
                                                          .secondaryContainer,
                                                  foregroundImage:
                                                      const AssetImage(
                                                        "assets/groups-icon.png",
                                                      ),
                                                ),
                                                const SizedBox(width: 16),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      group.name,
                                                      style: theme
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    const Text(
                                                      'You are owed RM20',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
