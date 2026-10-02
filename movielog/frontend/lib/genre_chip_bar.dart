import 'package:flutter/material.dart';

import './mock_movies.dart';

class GenreChipBar extends StatelessWidget {
  const GenreChipBar({
    super.key,
    required this.selectedGenre,
    required this.onSelected,
  });

  final String selectedGenre;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: genres.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final genre = genres[index];
          final selected = genre == selectedGenre;
          return ChoiceChip(
            label: Text(genre),
            selected: selected,
            showCheckmark: false,
            labelStyle: TextStyle(
              color: selected ? Colors.white : const Color(0xFF494551),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: const Color(0xFFE8E3EB),
            selectedColor: const Color(0xFF6750A4),
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: const StadiumBorder(),
            onSelected: (_) => onSelected(genre),
          );
        },
      ),
    );
  }
}

Future<Set<String>?> showGenreFilterSheet(
  BuildContext context, {
  required Set<String> selectedGenres,
}) {
  const filterGenres = [
    '드라마',
    'SF',
    '애니메이션',
    '스릴러',
    '로맨스',
    '코미디',
    '판타지',
    '다큐멘터리',
  ];
  final draft = Set<String>.of(selectedGenres);

  return showModalBottomSheet<Set<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.52,
      minChildSize: 0.48,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFAF9F5),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFC9C4CF),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 18, 24, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '장르 필터',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '여러 장르를 선택할 수 있어요',
                        style: TextStyle(
                          color: Color(0xFF79747E),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filterGenres.length,
                  itemBuilder: (context, index) {
                    final genre = filterGenres[index];
                    final checked = draft.contains(genre);
                    return SizedBox(
                      height: 48,
                      child: InkWell(
                        onTap: () => setSheetState(() {
                          if (checked) {
                            draft.remove(genre);
                          } else {
                            draft.add(genre);
                          }
                        }),
                        child: Row(
                          children: [
                            Checkbox(
                              value: checked,
                              activeColor: const Color(0xFF6750A4),
                              side: const BorderSide(
                                color: Color(0xFFA7A1AE),
                                width: 1.5,
                              ),
                              onChanged: (value) => setSheetState(() {
                                if (value ?? false) {
                                  draft.add(genre);
                                } else {
                                  draft.remove(genre);
                                }
                              }),
                            ),
                            const SizedBox(width: 4),
                            Text(genre, style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFEAE6ED))),
                  ),
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(draft),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6750A4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '확인',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
