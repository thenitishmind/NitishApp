class GithubUser {
  final int id;
  final String login;
  final String? name;
  final String? bio;
  final String? company;
  final String? location;
  final String? email;
  final String? blog;
  final String avatarUrl;
  final String htmlUrl;
  final int publicRepos;
  final int followers;
  final int following;
  final DateTime createdAt;
  final DateTime updatedAt;

  GithubUser({
    required this.id,
    required this.login,
    this.name,
    this.bio,
    this.company,
    this.location,
    this.email,
    this.blog,
    required this.avatarUrl,
    required this.htmlUrl,
    required this.publicRepos,
    required this.followers,
    required this.following,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GithubUser.fromJson(Map<String, dynamic> json) {
    return GithubUser(
      id: json['id'],
      login: json['login'],
      name: json['name'],
      bio: json['bio'],
      company: json['company'],
      location: json['location'],
      email: json['email'],
      blog: json['blog'],
      avatarUrl: json['avatar_url'],
      htmlUrl: json['html_url'],
      publicRepos: json['public_repos'],
      followers: json['followers'],
      following: json['following'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'name': name,
      'bio': bio,
      'company': company,
      'location': location,
      'email': email,
      'blog': blog,
      'avatar_url': avatarUrl,
      'html_url': htmlUrl,
      'public_repos': publicRepos,
      'followers': followers,
      'following': following,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayName => name ?? login;
  
  String get joinedYear => createdAt.year.toString();
}