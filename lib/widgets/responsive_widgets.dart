import 'package:flutter/material.dart';
import '../utils/responsive_layout.dart';

class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPadding = EdgeInsets.all(
      ResponsiveLayout.isMobile(context)
          ? ResponsiveSpacing.md
          : ResponsiveSpacing.lg,
    );

    final defaultMargin = EdgeInsets.all(
      ResponsiveLayout.isMobile(context)
          ? ResponsiveSpacing.xs
          : ResponsiveSpacing.sm,
    );

    return Card(
      margin: margin ?? defaultMargin,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(padding: padding ?? defaultPadding, child: child),
      ),
    );
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth:
            maxWidth ??
            (ResponsiveLayout.isDesktop(context) ? 1200 : double.infinity),
      ),
      padding: padding ?? ResponsiveSpacing.getAllPadding(context),
      margin: margin,
      child: child,
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double? childAspectRatio;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.childAspectRatio,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
  });

  @override
  Widget build(BuildContext context) {
    int columns;
    if (ResponsiveLayout.isDesktop(context)) {
      columns = desktopColumns ?? 4;
    } else if (ResponsiveLayout.isTablet(context)) {
      columns = tabletColumns ?? 2;
    } else {
      columns = mobileColumns ?? 1;
    }

    return GridView.count(
      crossAxisCount: columns,
      childAspectRatio: childAspectRatio ?? 1.0,
      mainAxisSpacing: mainAxisSpacing ?? ResponsiveSpacing.md,
      crossAxisSpacing: crossAxisSpacing ?? ResponsiveSpacing.md,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool responsive;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.responsive = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!responsive) {
      return Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final scaledStyle = style?.copyWith(
      fontSize: _getResponsiveFontSize(context, style?.fontSize),
    );

    return Text(
      text,
      style: scaledStyle ?? _getDefaultTextStyle(context),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  double? _getResponsiveFontSize(BuildContext context, double? fontSize) {
    if (fontSize == null) return null;

    if (ResponsiveLayout.isMobile(context)) {
      return fontSize * 0.9;
    } else if (ResponsiveLayout.isTablet(context)) {
      return fontSize;
    } else {
      return fontSize * 1.1;
    }
  }

  TextStyle _getDefaultTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!;
  }
}

class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;

  const ResponsiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveLayout.isMobile(context)) {
      return AppBar(
        title: Text(title),
        actions: actions,
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        bottom: bottom,
      );
    }

    // Pour tablette et desktop, on n'affiche pas d'AppBar car la navigation
    // est gérée par le NavigationRail dans HomeScreen
    return const PreferredSize(
      preferredSize: Size.zero,
      child: SizedBox.shrink(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ResponsiveListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;

  const ResponsiveListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPadding = EdgeInsets.all(
      ResponsiveLayout.isMobile(context)
          ? ResponsiveSpacing.md
          : ResponsiveSpacing.lg,
    );

    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      contentPadding: contentPadding ?? defaultPadding,
    );
  }
}

class ResponsiveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool isElevated;
  final bool fullWidth;

  const ResponsiveButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.isElevated = true,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonPadding = EdgeInsets.symmetric(
      horizontal: ResponsiveLayout.isMobile(context) ? 16 : 24,
      vertical: ResponsiveLayout.isMobile(context) ? 12 : 16,
    );

    final buttonStyle = (style ??
            (isElevated
                ? ElevatedButton.styleFrom()
                : OutlinedButton.styleFrom()))
        .copyWith(padding: WidgetStateProperty.all(buttonPadding));

    Widget button =
        isElevated
            ? ElevatedButton(
              onPressed: onPressed,
              style: buttonStyle,
              child: child,
            )
            : OutlinedButton(
              onPressed: onPressed,
              style: buttonStyle,
              child: child,
            );

    if (fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}

class ResponsiveTextField extends StatelessWidget {
  final TextEditingController? controller;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final bool obscureText;
  final TextInputAction? textInputAction;

  const ResponsiveTextField({
    super.key,
    this.controller,
    this.decoration,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.obscureText = false,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final inputDecoration =
        decoration?.copyWith(
          contentPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveSpacing.md,
            vertical:
                ResponsiveLayout.isMobile(context)
                    ? ResponsiveSpacing.sm
                    : ResponsiveSpacing.md,
          ),
        ) ??
        InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveSpacing.md,
            vertical:
                ResponsiveLayout.isMobile(context)
                    ? ResponsiveSpacing.sm
                    : ResponsiveSpacing.md,
          ),
        );

    return TextFormField(
      controller: controller,
      decoration: inputDecoration,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      obscureText: obscureText,
      textInputAction: textInputAction,
    );
  }
}

class ResponsiveSection extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  const ResponsiveSection({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: ResponsiveLayout.isMobile(context) ? 20 : 24,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(width: ResponsiveSpacing.sm),
            ],
            Expanded(
              child: ResponsiveText(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveSpacing.md),
        Padding(padding: padding ?? EdgeInsets.zero, child: child),
      ],
    );
  }
}
