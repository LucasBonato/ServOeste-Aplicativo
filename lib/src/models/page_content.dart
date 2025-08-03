class PageContent<T> {
  final List<T> content;
  final PageInfo page;

  PageContent({
    required this.content,
    required this.page,
  });

  factory PageContent.fromJson(Map<String, dynamic> json,
          T Function(Map<String, dynamic>) fromJsonT) =>
      PageContent(
          content: (json["content"] as List)
              .map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList(),
          page: PageInfo.fromJson(json["page"]));

  factory PageContent.empty() =>
      PageContent(content: [], page: PageInfo.empty());
}

class PageInfo {
  final int totalElements;
  final int totalPages;
  final int page;
  final int size;

  PageInfo({
    required this.totalElements,
    required this.totalPages,
    required this.page,
    required this.size,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) => PageInfo(
      totalElements: json["totalElements"],
      totalPages: json["totalPages"],
      page: json["page"],
      size: json["size"]);

  factory PageInfo.empty() =>
      PageInfo(totalElements: 0, totalPages: 1, page: 0, size: 10);
}
