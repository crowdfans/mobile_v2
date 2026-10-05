import 'package:crowdfans/components/search/search_query_field.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Cabeçalho da busca de fã clube (CF-173): voltar + lupa; campo pílula abaixo.
class FanClubsSearchChrome extends StatelessWidget {
  const FanClubsSearchChrome({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onBack,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onBack;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 52,
          child: Row(
            children: [
              IconButton(
                key: const Key('fan-clubs-search-back'),
                onPressed: onBack,
                tooltip: 'Voltar',
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: colors.textPrimary,
                  size: 20,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Material(
                  color: colors.surfaceAlt,
                  shape: const CircleBorder(),
                  child: InkWell(
                    key: const Key('fan-clubs-search-lupa'),
                    customBorder: const CircleBorder(),
                    onTap: () => focusNode.requestFocus(),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: SvgPicture.asset(
                        'assets/icons/General/search-md.svg',
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          colors.textPrimary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: SearchQueryField(
            key: const Key('fan-clubs-search-field'),
            controller: controller,
            focusNode: focusNode,
            hint: 'Buscar fã clube',
            autofocus: true,
            pill: true,
            onChanged: onChanged,
          ),
        ),
        Divider(height: 1, thickness: 1, color: colors.border),
      ],
    );
  }
}
