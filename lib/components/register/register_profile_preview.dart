import 'package:crowdfans/components/register/register_profile_stat.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Preview do perfil no cadastro (avatar, nome, handle e stats de exemplo).
class RegisterProfilePreview extends StatelessWidget {
  const RegisterProfilePreview({
    super.key,
    required this.name,
    required this.username,
    required this.avatarPath,
    required this.onPickAvatar,
  });

  final String name;
  final String username;
  final String avatarPath;
  final VoidCallback onPickAvatar;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onPickAvatar,
          child: SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ColoredBox(
                    color: colors.surfaceAlt,
                    child: SizedBox(
                      width: 110,
                      height: 110,
                      child: avatarPath.isEmpty
                          ? Icon(
                              Icons.image_outlined,
                              size: 28,
                              color: colors.textTertiary,
                            )
                          : FutureBuilder(
                              future: XFile(avatarPath).readAsBytes(),
                              builder: (context, snapshot) {
                                final bytes = snapshot.data;
                                if (bytes == null) {
                                  return Icon(
                                    Icons.image_outlined,
                                    size: 28,
                                    color: colors.textTertiary,
                                  );
                                }
                                return Image.memory(bytes, fit: BoxFit.cover);
                              },
                            ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox(
                        width: 22,
                        height: 22,
                        child: Icon(
                          Icons.add,
                          size: 12,
                          color: AppPalette.platinum50,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  text: name.isEmpty ? 'User Name' : name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                  children: [
                    TextSpan(
                      text: ' fan/${username.isEmpty ? 'username' : username}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  RegisterProfileStat(value: '5.741', label: 'Posts'),
                  SizedBox(width: 20),
                  RegisterProfileStat(value: '681', label: 'Cartas'),
                  SizedBox(width: 20),
                  RegisterProfileStat(value: '1,2k', label: 'Artistas'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
