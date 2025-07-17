import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartsplitclient/Authentication/State/auth_state.dart';
import 'package:smartsplitclient/Group/Model/group.dart';
import 'package:smartsplitclient/Group/Presentation/choose_group_members.dart';
import 'package:smartsplitclient/Group/Presentation/group_expenses_page.dart';
import 'package:smartsplitclient/Group/State/group_state.dart';
import 'package:smartsplitclient/Split/Model/registered_friend.dart';
import 'package:smartsplitclient/Split/State/split_state.dart';

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

                                        final splitState =
                                            context.watch<SplitState>();
                                        final user =
                                            context
                                                .read<AuthState>()
                                                .currentUser;

                                        double totalOwedByMe = 0;
                                        double totalOwedToMe = 0;

                                        for (final billList
                                            in splitState.myDebts.values) {
                                          for (final bill in billList) {
                                            if (bill.groupId ==
                                                group.id.toString()) {
                                              final totalYouOwed =
                                                  bill.members.fold<int>(0, (
                                                    sum,
                                                    member,
                                                  ) {
                                                    if ((member.friend
                                                                is RegisteredFriend &&
                                                            (member.friend
                                                                        as RegisteredFriend)
                                                                    .id ==
                                                                user!.id) &&
                                                        !member.hasPaid) {
                                                      return sum +
                                                          member.totalDebt;
                                                    }
                                                    return sum;
                                                  }) /
                                                  100;

                                              totalOwedByMe += totalYouOwed;
                                            }
                                          }
                                        }

                                        for (final billList
                                            in splitState.mySplitBills.values) {
                                          for (final bill in billList) {
                                            if (bill.groupId ==
                                                group.id.toString()) {
                                              final totalOwedToYou =
                                                  bill.members.fold<int>(0, (
                                                    sum,
                                                    member,
                                                  ) {
                                                    if ((member.friend
                                                                is RegisteredFriend &&
                                                            (member.friend
                                                                        as RegisteredFriend)
                                                                    .id !=
                                                                user!.id) &&
                                                        !member.hasPaid) {
                                                      return sum +
                                                          member.totalDebt;
                                                    }
                                                    return sum;
                                                  }) /
                                                  100;

                                              totalOwedToMe += totalOwedToYou;
                                            }
                                          }
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12.0,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                PageRouteBuilder(
                                                  pageBuilder:
                                                      (_, __, ___) =>
                                                          GroupExpensesPage(
                                                            groups[index],
                                                          ),
                                                  transitionDuration:
                                                      Duration.zero,
                                                  reverseTransitionDuration:
                                                      Duration.zero,
                                                ),
                                              );
                                            },
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        group.name,
                                                        style: theme
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          if (totalOwedToMe !=
                                                              0.0) ...[
                                                            Text(
                                                              'Owed to you: ',
                                                              style:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                  ),
                                                            ),
                                                            Text(
                                                              'RM${totalOwedToMe.toStringAsFixed(2)}',
                                                              style: const TextStyle(
                                                                fontSize: 10,
                                                                color:
                                                                    Colors.red,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                          if (totalOwedToMe !=
                                                                  0.0 &&
                                                              totalOwedByMe !=
                                                                  0.0)
                                                            const Text(
                                                              '  |  ',
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                              ),
                                                            ),
                                                          if (totalOwedByMe !=
                                                              0.0) ...[
                                                            Text(
                                                              'You owe: ',
                                                              style:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                  ),
                                                            ),
                                                            Text(
                                                              'RM${totalOwedByMe.toStringAsFixed(2)}',
                                                              style: const TextStyle(
                                                                fontSize: 10,
                                                                color:
                                                                    Colors.red,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
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
