import 'package:flutter/material.dart';
import '../core/theme/brutalism_theme.dart';

/// Widget Card dengan tema Brutalism
/// Karakteristik: Border tebal, tanpa shadow, sudut tajam
class BrutalCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const BrutalCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBorderColor = isDark 
        ? BrutalismTheme.primaryWhite 
        : BrutalismTheme.primaryBlack;
    final defaultBgColor = isDark 
        ? BrutalismTheme.darkGrey 
        : BrutalismTheme.primaryWhite;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.all(BrutalismTheme.spacingS),
        padding: padding ?? const EdgeInsets.all(BrutalismTheme.spacingM),
        decoration: BoxDecoration(
          color: backgroundColor ?? defaultBgColor,
          border: Border.all(
            color: borderColor ?? defaultBorderColor,
            width: borderWidth ?? BrutalismTheme.borderWidth,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Widget Button dengan tema Brutalism
class BrutalButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final IconData? icon;
  final bool isOutlined;
  final bool isFullWidth;
  final bool isLoading;

  const BrutalButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.icon,
    this.isOutlined = false,
    this.isFullWidth = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isOutlined
        ? Colors.transparent
        : (backgroundColor ??
            (isDark
                ? BrutalismTheme.accentYellow
                : BrutalismTheme.primaryBlack));
    final fgColor = isOutlined
        ? (textColor ??
            (isDark
                ? BrutalismTheme.primaryWhite
                : BrutalismTheme.primaryBlack))
        : (textColor ??
            (isDark
                ? BrutalismTheme.primaryBlack
                : BrutalismTheme.primaryWhite));
    final border = borderColor ??
        (isDark ? BrutalismTheme.primaryWhite : BrutalismTheme.primaryBlack);

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: Material(
        color: bgColor,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: BrutalismTheme.spacingL,
              vertical: BrutalismTheme.spacingM,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: border,
                width: BrutalismTheme.borderWidth,
              ),
            ),
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize:
                        isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: fgColor, size: 24),
                        const SizedBox(width: BrutalismTheme.spacingS),
                      ],
                      Text(
                        text.toUpperCase(),
                        style: TextStyle(
                          color: fgColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Widget untuk menampilkan statistik dengan tema Brutalism
class BrutalStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? accentColor;
  final IconData? icon;

  const BrutalStatCard({
    super.key,
    required this.label,
    required this.value,
    this.accentColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? BrutalismTheme.accentYellow;

    return BrutalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                  color: isDark
                      ? BrutalismTheme.lightGrey
                      : BrutalismTheme.darkGrey,
                ),
                const SizedBox(width: BrutalismTheme.spacingS),
              ],
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: isDark
                        ? BrutalismTheme.lightGrey
                        : BrutalismTheme.darkGrey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: BrutalismTheme.spacingS),
          Row(
            children: [
              Container(
                width: 4,
                height: 28,
                color: accent,
              ),
              const SizedBox(width: BrutalismTheme.spacingS),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? BrutalismTheme.primaryWhite
                          : BrutalismTheme.primaryBlack,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget untuk status badge
class BrutalBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const BrutalBadge({
    super.key,
    required this.text,
    required this.backgroundColor,
    this.textColor = BrutalismTheme.primaryWhite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BrutalismTheme.spacingS,
        vertical: BrutalismTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: BrutalismTheme.primaryBlack,
          width: 2,
        ),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
