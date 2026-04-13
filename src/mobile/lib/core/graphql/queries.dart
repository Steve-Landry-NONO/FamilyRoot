/// =====================
/// QUERIES GraphQL
/// =====================

const String queryMe = r'''
  query Me {
    me {
      id
      email
      firstName
      lastName
      avatarUrl
      hasFamily
      families {
        id
        role
        joinedAt
        family {
          id
          name
          code
          tier
        }
      }
    }
  }
''';

const String queryDashboard = r'''
  query Dashboard {
    dashboard {
      family {
        id
        name
        code
        tier
        memberCount
      }
      memberCount
      generationCount
      upcomingEvents {
        id
        title
        type
        date
        memberName
      }
      recentMembers {
        id
        firstName
        lastName
        photoUrl
        createdAt
      }
    }
  }
''';

const String queryFamilyTree = r'''
  query FamilyTree {
    familyTree {
      id
      name
      code
      members {
        id
        firstName
        lastName
        birthDate
        deathDate
        gender
        photoUrl
        isDeceased
        hasLinkedProfile
        relations {
          id
          type
          fromMember {
            id
            firstName
            lastName
          }
          toMember {
            id
            firstName
            lastName
          }
        }
      }
    }
  }
''';

const String queryMember = r'''
  query Member($id: String!) {
    member(id: $id) {
      id
      firstName
      lastName
      birthDate
      deathDate
      gender
      birthPlace
      bio
      photoUrl
      relations {
        id
        type
        toMember {
          id
          firstName
          lastName
        }
      }
    }
  }
''';

const String queryValidateInvitation = r'''
  query ValidateInvitationCode($code: String!) {
    validateInvitationCode(code: $code) {
      valid
      familyName
      error
    }
  }
''';

const String queryNotifications = r'''
  query Notifications($limit: Int, $unreadOnly: Boolean) {
    notifications(limit: $limit, unreadOnly: $unreadOnly) {
      id
      type
      title
      body
      isRead
      createdAt
    }
  }
''';

const String queryUnreadCount = r'''
  query UnreadCount {
    unreadNotificationCount
  }
''';

/// =====================
/// MUTATIONS GraphQL
/// =====================

const String mutationCreateFamily = r'''
  mutation CreateFamily($input: CreateFamilyInput!) {
    createFamily(input: $input) {
      id
      name
      code
      tier
    }
  }
''';

const String mutationJoinFamily = r'''
  mutation JoinFamily($code: String!, $firstName: String!, $lastName: String!) {
    joinFamily(code: $code, firstName: $firstName, lastName: $lastName)
  }
''';

const String mutationAddMember = r'''
  mutation AddMember($input: AddMemberInput!) {
    addMember(input: $input) {
      id
      firstName
      lastName
      birthDate
      gender
    }
  }
''';

const String mutationUpdateMember = r'''
  mutation UpdateMember($id: String!, $input: UpdateMemberInput!) {
    updateMember(id: $id, input: $input) {
      id
      firstName
      lastName
      birthDate
      deathDate
      gender
      birthPlace
      bio
      photoUrl
    }
  }
''';

const String mutationUpdateProfile = r'''
  mutation UpdateProfile($input: UpdateProfileInput!) {
    updateProfile(input: $input) {
      id
      firstName
      lastName
      avatarUrl
    }
  }
''';

const String mutationCreateInvitation = r'''
  mutation CreateInvitation($expiresInDays: Float) {
    createInvitation(expiresInDays: $expiresInDays) {
      id
      code
      expiresAt
    }
  }
''';

const String mutationMarkNotificationRead = r'''
  mutation MarkNotificationAsRead($id: String!) {
    markNotificationAsRead(id: $id) {
      id
      isRead
    }
  }
''';

const String mutationMarkAllNotificationsRead = r'''
  mutation MarkAllNotificationsAsRead {
    markAllNotificationsAsRead
  }
''';
