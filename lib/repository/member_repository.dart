import 'package:badmatch_app/infrastructure/database.dart';
import 'package:badmatch_app/infrastructure/entity/members.dart';
import 'package:drift/drift.dart';

class MemberRepository {
  final MemberAccessor _memberAccessor;

  MemberRepository(this._memberAccessor);

  Future<void> insertMember({
    required String name,
    required SexEnum sex,
    required int level,
    required int communityId,
    int? age,
  }) {
    MembersCompanion membersCompanion = MembersCompanion.insert(
      name: name,
      sex: sex,
      age: age != null ? Value(age) : const Value(null),
      level: level,
      communityId: communityId,
    );
    return _memberAccessor.insertMember(membersCompanion: membersCompanion);
  }

  Future<List<Member>> getCommunityMembers(int communityId) =>
      _memberAccessor.getCommunityMembers(communityId);

  Stream<List<Member>> watchCommunityMembers(int communityId) =>
      _memberAccessor.watchCommunityMembers(communityId);

  Future<void> updateMember({
    required Member member,
    String? name,
    SexEnum? sex,
    int? level,
    int? age,
    bool? isParticipant,
  }) {
    MembersCompanion membersCompanion = MembersCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      sex: sex != null ? Value(sex) : const Value.absent(),
      age: age != null ? Value(age) : const Value.absent(),
      level: level != null ? Value(level) : const Value.absent(),
      isParticipant:
          isParticipant != null ? Value(isParticipant) : const Value.absent(),
    );
    return _memberAccessor.updateMember(
      member: member,
      membersCompanion: membersCompanion,
    );
  }

  Future<void> updateMembers(
      {required Map<Member, MembersCompanion> membersCompanionMap}) async {
    membersCompanionMap.forEach(
      (member, membersCompanion) async {
        await _memberAccessor.updateMember(
          member: member,
          membersCompanion: membersCompanion,
        );
      },
    );
  }

  Future<void> deleteMember({required Member member}) =>
      _memberAccessor.deleteMember(member);

  Future<void> deleteMembers({required List<Member> memberList}) async {
    for (Member member in memberList) {
      await _memberAccessor.deleteMember(member);
    }
  }

  Future<List<Member>> getParticipants(Community community) async {
    return await _memberAccessor.getParticipants(community.id);
  }

  Future<List<Member>> getCandidates(Community community) async {
    List<Member> participantList =
        await _memberAccessor.getParticipants(community.id);
    participantList.shuffle();
    participantList.sort(((a, b) => a.level.compareTo(b.level)));
    return participantList;
    // participantList.sort(((a, b) => a.level.compareTo(b.level)));
  }

  Future<List<List<Member>>> getPlayersList({
    required Community community,
    required int numCourt,
  }) async {
    List<List<Member>> playerList = [];
    List<Member> candidateList = await getCandidates(community);
    for (int i = 0; i < numCourt; i++) {
      playerList.add(candidateList.sublist(i * 4, i * 4 + 4));
    }
    return playerList;
  }
}
