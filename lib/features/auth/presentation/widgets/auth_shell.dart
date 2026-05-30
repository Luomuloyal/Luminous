import 'package:flutter/material.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.badge,
    required this.title,
    required this.description,
    required this.form,
    this.aside,
  });

  final String badge;
  final String title;
  final String description;
  final Widget form;
  final Widget? aside;

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
            colors: <Color>[
              AppColorTokens.canvas,
              surface.canvasSoft,
            ],
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
                            child: _AuthFormPanel(
                              form: form,
                              surface: surface,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _AuthNarrativePanel(
                            badge: badge,
                            title: title,
                            description: description,
                            typography: typography,
                            surface: surface,
                            compact: true,
                          ),
                          const SizedBox(height: AppSpacingTokens.lg),
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
    );
  }
}

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.helperText,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: typography.bodySm.copyWith(color: surface.mute),
        labelStyle: typography.bodySm.copyWith(color: surface.body),
        filled: true,
        fillColor: surface.canvas,
        suffixIcon: suffix,
        helperText: helperText,
        helperStyle: typography.caption.copyWith(color: surface.mute),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
          borderSide: BorderSide(color: surface.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
      ),
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
          minimumSize: const Size.fromHeight(48),
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
