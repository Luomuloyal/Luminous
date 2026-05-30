import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/l10n/app_localizations.dart';

const double _authControlHeight = 56;

class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.badge,
    required this.title,
    required this.description,
    required this.form,
    this.aside,
    this.showCompactNarrative = true,
  });

  final String badge;
  final String title;
  final String description;
  final Widget form;
  final Widget? aside;
  final bool showCompactNarrative;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surface = theme.extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final layout = AppLayoutTokens.resolve(width);
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(scheme.onSurface)
        : AppTypographyTokens.desktop(scheme.onSurface);
    final isWide = width >= AppBreakpoints.desktop;

    return Scaffold(
      backgroundColor: surface.canvasSoft,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[AppColorTokens.canvas, surface.canvasSoft],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: layout.maxContentWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: layout.pageHorizontalPadding,
                  vertical: width < AppBreakpoints.mobile
                      ? AppSpacingTokens.lg
                      : AppSpacingTokens.xl,
                ),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _AuthNarrativePanel(
                              badge: badge,
                              title: title,
                              description: description,
                              typography: typography,
                              surface: surface,
                            ),
                          ),
                          const SizedBox(width: AppSpacingTokens.xl),
                          SizedBox(
                            width: 420,
                            child: _AuthFormPanel(form: form, surface: surface),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showCompactNarrative) ...[
                            _AuthNarrativePanel(
                              badge: badge,
                              title: title,
                              description: description,
                              typography: typography,
                              surface: surface,
                              compact: true,
                            ),
                            const SizedBox(height: AppSpacingTokens.lg),
                          ],
                          _AuthFormPanel(form: form, surface: surface),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthNarrativePanel extends StatelessWidget {
  const _AuthNarrativePanel({
    required this.badge,
    required this.title,
    required this.description,
    required this.typography,
    required this.surface,
    this.compact = false,
  });

  final String badge;
  final String title;
  final String description;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColorTokens.canvas,
            AppColorTokens.canvasSoft,
            AppColorTokens.linkSoft,
          ],
        ),
        border: Border.all(color: surface.hairline),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          compact ? AppSpacingTokens.lg : AppSpacingTokens.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacingTokens.sm,
                vertical: AppSpacingTokens.xs,
              ),
              decoration: BoxDecoration(
                color: surface.canvas,
                borderRadius: BorderRadius.circular(AppRadiusTokens.full),
                border: Border.all(color: surface.hairline),
              ),
              child: Text(
                badge,
                style: typography.captionMono.copyWith(color: surface.body),
              ),
            ),
            const SizedBox(height: AppSpacingTokens.lg),
            Text(title, style: typography.displayXl),
            const SizedBox(height: AppSpacingTokens.sm),
            Text(
              description,
              style: typography.bodyMd.copyWith(color: surface.body),
            ),
            if (!compact) ...[
              const SizedBox(height: AppSpacingTokens.xl),
              Text(
                l10n?.authInfraHint ??
                    'Secure session storage, Lucent-backed localized responses, and session restore are already wired beneath this form layer.',
                style: typography.bodySm.copyWith(color: surface.mute),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AuthFormPanel extends StatelessWidget {
  const _AuthFormPanel({required this.form, required this.surface});

  final Widget form;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
          decoration: BoxDecoration(
            color: surface.canvas,
            borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
            border: Border.all(color: surface.hairline),
            boxShadow: AppShadowTokens.level4,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.xl),
            child: form,
          ),
        )
        .animate()
        .fadeIn(duration: 180.ms, curve: Curves.easeOut)
        .slideY(
          begin: 0.03,
          end: 0,
          duration: 180.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final bool enabled;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
    final borderColor = _focusNode.hasFocus
        ? theme.colorScheme.primary
        : surface.hairline;
    final contentColor = widget.enabled
        ? theme.colorScheme.onSurface
        : surface.mute;

    return _AuthControlFrame(
      backgroundColor: widget.enabled ? surface.canvas : surface.canvasSoft,
      borderColor: borderColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.md),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                keyboardType: widget.keyboardType,
                obscureText: widget.obscureText,
                maxLines: 1,
                style: typography.bodyMd.copyWith(color: contentColor),
                cursorColor: theme.colorScheme.primary,
                decoration: InputDecoration.collapsed(
                  hintText: widget.label,
                  hintStyle: typography.bodySm.copyWith(color: surface.mute),
                ),
              ),
            ),
            if (widget.suffix != null) ...[
              const SizedBox(width: AppSpacingTokens.xs),
              widget.suffix!,
            ],
          ],
        ),
      ),
    );
  }
}

class _AuthControlFrame extends StatelessWidget {
  const _AuthControlFrame({
    required this.child,
    required this.backgroundColor,
    required this.borderColor,
  });

  final Widget child;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppRadiusTokens.sm);

    return SizedBox(
      height: _authControlHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          border: Border.all(color: borderColor),
        ),
        child: ClipRRect(borderRadius: borderRadius, child: child),
      ),
    );
  }
}

class AuthFormHeader extends StatelessWidget {
  const AuthFormHeader({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: typography.displayMd),
        const SizedBox(height: AppSpacingTokens.sm),
        Text(
          description,
          style: typography.bodySm.copyWith(color: surface.body),
        ),
      ],
    );
  }
}

class AuthStatusMessage extends StatelessWidget {
  const AuthStatusMessage({super.key, this.error, this.success});

  final String? error;
  final String? success;

  @override
  Widget build(BuildContext context) {
    final message = error?.isNotEmpty == true
        ? error
        : success?.isNotEmpty == true
        ? success
        : null;
    if (message == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
    final isError = error?.isNotEmpty == true;
    final color = isError ? theme.colorScheme.error : surface.success;

    return Text(message, style: typography.bodySm.copyWith(color: color));
  }
}

class AuthCodeFieldRow extends StatelessWidget {
  const AuthCodeFieldRow({
    super.key,
    required this.controller,
    required this.label,
    required this.buttonLabel,
    required this.onSendCode,
    this.isLoading = false,
    this.keyboardType = TextInputType.number,
  });

  final TextEditingController controller;
  final String label;
  final String buttonLabel;
  final VoidCallback? onSendCode;
  final bool isLoading;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
    final isEnabled = onSendCode != null && !isLoading;

    return SizedBox(
      height: _authControlHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: AuthTextField(
              key: const ValueKey('auth-code-field-input'),
              controller: controller,
              label: label,
              keyboardType: keyboardType,
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          SizedBox(
            key: const ValueKey('auth-code-field-button'),
            width: 132,
            child: _AuthControlFrame(
              backgroundColor: surface.canvas,
              borderColor: surface.hairline,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isEnabled ? onSendCode : null,
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            buttonLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typography.buttonLg.copyWith(
                              color: isEnabled ? surface.link : surface.mute,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthLoginActionRow extends StatelessWidget {
  const AuthLoginActionRow({
    super.key,
    required this.registerPrompt,
    required this.registerLabel,
    required this.onRegister,
    required this.forgotPasswordLabel,
    required this.onForgotPassword,
  });

  final String registerPrompt;
  final String registerLabel;
  final VoidCallback onRegister;
  final String forgotPasswordLabel;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
    final promptStyle = typography.bodySm.copyWith(color: surface.body);
    final linkStyle = typography.bodySm.copyWith(
      color: surface.link,
      fontWeight: FontWeight.w600,
    );

    return Row(
      children: [
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 0,
            children: [
              Text(registerPrompt, style: promptStyle),
              TextButton(
                onPressed: onRegister,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(registerLabel, style: linkStyle),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onForgotPassword,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(forgotPasswordLabel, style: linkStyle),
        ),
      ],
    );
  }
}

class AuthFooterAction extends StatelessWidget {
  const AuthFooterAction({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onPressed,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacingTokens.xs,
      children: [
        Text(prompt, style: typography.bodySm.copyWith(color: surface.body)),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.xs,
            ),
            minimumSize: const Size(0, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(actionLabel),
        ),
      ],
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final typography = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(Theme.of(context).colorScheme.onPrimary)
        : AppTypographyTokens.desktop(Theme.of(context).colorScheme.onPrimary);

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(_authControlHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label, style: typography.buttonLg),
      ),
    );
  }
}
