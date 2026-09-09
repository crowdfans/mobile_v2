import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/register/register_fan_scaffold.dart';
import 'package:crowdfans/components/register/register_profile_bio_field.dart';
import 'package:crowdfans/components/register/register_profile_preview.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/state/fan_register_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Avatar e bio opcionais — o upload fica para depois do cadastro.
class RegisterFanProfileScreen extends ConsumerStatefulWidget {
  const RegisterFanProfileScreen({super.key});

  @override
  ConsumerState<RegisterFanProfileScreen> createState() =>
      _RegisterFanProfileScreenState();
}

class _RegisterFanProfileScreenState
    extends ConsumerState<RegisterFanProfileScreen> {
  Future<void> handlePickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file == null) {
      return;
    }
    ref
        .read(fanRegisterProvider.notifier)
        .setFields((current) => current.copyWith(avatarUri: file.path));
  }

  void handleFinish() {
    context.push(Pages.registerFanTerms);
  }

  void handleSkip() {
    context.push(Pages.registerFanTerms);
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(fanRegisterProvider);
    return RegisterFanScaffold(
      onBack: () => context.pop(),
      footer: Column(
        children: [
          AppButton(label: 'Concluir', onPressed: handleFinish),
          const SizedBox(height: 12),
          AppButton(
            label: 'Pular',
            onPressed: handleSkip,
            variant: AppButtonVariant.ghost,
          ),
        ],
      ),
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          const SizedBox(height: 24),
          RegisterProfilePreview(
            name: form.name,
            username: form.username,
            avatarPath: form.avatarUri,
            onPickAvatar: handlePickAvatar,
          ),
          const SizedBox(height: 24),
          RegisterProfileBioField(
            value: form.description,
            onChanged: (value) {
              ref
                  .read(fanRegisterProvider.notifier)
                  .setFields((current) => current.copyWith(description: value));
            },
          ),
        ],
      ),
    );
  }
}
