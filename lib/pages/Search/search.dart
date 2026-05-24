import 'package:luminous/features/search/presentation/search.dart';

export 'package:luminous/features/search/presentation/search.dart';

/// 兼容旧路径的搜索页入口。
@Deprecated(
  'Use SearchPage from package:luminous/features/search/presentation/search.dart',
)
class SearchView extends SearchPage {
  const SearchView({
    super.key,
    super.pickerMode,
    super.initialKeyword,
    super.autoSearchOnInit,
    super.searchExecutor,
    super.controller,
  });
}
