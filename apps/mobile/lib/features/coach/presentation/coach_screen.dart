import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/widgets/empty_feature_card.dart';
import '../../../core/widgets/inline_error_card.dart';
import '../../../core/widgets/loading_card_skeleton.dart';
import '../../../core/widgets/memy_page_header.dart';
import '../../shell/presentation/memy_bottom_navigation.dart';
import '../../user/application/providers/user_providers.dart';
import '../application/providers/coach_providers.dart';
import '../application/services/coach_conversation_controller.dart';
import '../domain/entities/coach_suggestion.dart';

class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key});

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  final _composerController = TextEditingController();

  @override
  void dispose() {
    _composerController.dispose();
    super.dispose();
  }

  void _sendComposer() {
    final text = _composerController.text;
    if (text.trim().isEmpty) return;
    ref.read(coachConversationProvider.notifier).sendUserMessage(text);
    _composerController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final promptsAsync = ref.watch(coachPromptsProvider);
    final conversation = ref.watch(coachConversationProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final displayName = profileAsync.asData?.value.displayName ?? 'there';

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const MemyPageHeader(
            title: 'AI Coach',
            subtitle: AppStrings.liveAiNotConnected,
          ),
          Expanded(
            child: ListView(
              key: const PageStorageKey('coach_scroll'),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              children: [
                const SizedBox(height: AppSpacing.md),
                const Center(child: _CoachSpherePlaceholder()),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Hi, $displayName',
                  style: AppTextStyles.titleLarge(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'How can I help you today?',
                  style: AppTextStyles.bodyMedium(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                promptsAsync.when(
                  loading: () => const LoadingCardSkeleton(
                    key: Key('coach_prompts_loading'),
                    height: 72,
                    lines: 2,
                  ),
                  error: (error, _) => InlineErrorCard(
                    key: const Key('coach_prompts_error'),
                    message: userFacingErrorMessage(error),
                    onRetry: () => ref.invalidate(coachPromptsProvider),
                  ),
                  data: (prompts) {
                    if (prompts.isEmpty) {
                      return const EmptyFeatureCard(
                        key: Key('coach_prompts_empty'),
                        title: 'Suggested prompts',
                        message: AppStrings.sectionEmptyMessage,
                        icon: Icons.chat_bubble_outline_rounded,
                      );
                    }
                    return _PromptWrap(
                      prompts: prompts,
                      onSelected: (prompt) {
                        ref
                            .read(coachConversationProvider.notifier)
                            .sendPrompt(prompt);
                      },
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                if (conversation.messages.isNotEmpty)
                  _ConversationList(messages: conversation.messages),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.canvasDeep,
                    borderRadius: AppRadii.controlRadius,
                  ),
                  child: Text(
                    AppStrings.coachLocalDemoNote,
                    style: AppTextStyles.bodySmall(),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.page,
              0,
              AppSpacing.page,
              MemyBottomNavigation.contentBottomInset(context) + 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  key: const Key('coach_composer'),
                  controller: _composerController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendComposer(),
                  decoration: InputDecoration(
                    hintText: AppStrings.coachComposerHint,
                    filled: true,
                    fillColor: AppColors.surface,
                    suffixIcon: IconButton(
                      key: const Key('coach_send'),
                      onPressed: _sendComposer,
                      icon: const Icon(Icons.send_rounded),
                      tooltip: 'Send message',
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Composer creates a local ${AppStrings.demoResponseLabel.toLowerCase()} only.',
                  style: AppTextStyles.labelSmall(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptWrap extends StatelessWidget {
  const _PromptWrap({required this.prompts, required this.onSelected});

  final List<CoachSuggestion> prompts;
  final ValueChanged<CoachSuggestion> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: const Key('coach_prompts'),
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final prompt in prompts)
          ActionChip(
            key: Key('coach_prompt_${prompt.id}'),
            label: Text(prompt.prompt),
            onPressed: () => onSelected(prompt),
            backgroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.line),
            labelStyle: AppTextStyles.bodySmall(color: AppColors.primaryText),
          ),
      ],
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({required this.messages});

  final List<CoachMessage> messages;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('coach_conversation'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final message in messages) ...[
          Align(
            alignment: message.isUser
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              constraints: const BoxConstraints(maxWidth: 320),
              decoration: BoxDecoration(
                color: message.isUser ? AppColors.ember : AppColors.surface,
                borderRadius: AppRadii.controlRadius,
                border: message.isUser
                    ? null
                    : Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isDemoResponse)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        AppStrings.demoResponseLabel,
                        style: AppTextStyles.kicker(
                          color: message.isUser
                              ? Colors.white70
                              : AppColors.emberDark,
                        ),
                      ),
                    ),
                  Text(
                    message.text,
                    style: AppTextStyles.bodyMedium(
                      color: message.isUser
                          ? Colors.white
                          : AppColors.primaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CoachSpherePlaceholder extends StatelessWidget {
  const _CoachSpherePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      height: 168,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFFFB347), AppColors.ember, AppColors.depth],
          stops: [0.0, 0.45, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ember.withValues(alpha: 0.35),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.auto_awesome, color: Colors.white, size: 42),
      ),
    );
  }
}
