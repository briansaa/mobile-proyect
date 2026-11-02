import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double elevation;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
    this.height = 50,
    this.padding,
    this.borderRadius,
    this.elevation = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = backgroundColor ?? theme.primaryColor;
    final buttonTextColor = textColor ?? 
        (isOutlined ? primaryColor : Colors.white);

    return SizedBox(
      width: width,
      height: height,
      child: isOutlined ? _buildOutlinedButton(primaryColor, buttonTextColor) 
                        : _buildElevatedButton(primaryColor, buttonTextColor),
    );
  }

  Widget _buildElevatedButton(Color primaryColor, Color buttonTextColor) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: buttonTextColor,
        elevation: elevation,
        shadowColor: primaryColor.withValues(alpha: 0.3),
        padding: padding ?? EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
      child: _buildButtonContent(buttonTextColor),
    );
  }

  Widget _buildOutlinedButton(Color primaryColor, Color buttonTextColor) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: buttonTextColor,
        side: BorderSide(color: primaryColor, width: 1.5),
        padding: padding ?? EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
      child: _buildButtonContent(buttonTextColor),
    );
  }

  Widget _buildButtonContent(Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOutlined ? textColor : Colors.white,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }
}

// Botón personalizado con gradiente
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final List<Color> gradientColors;
  final IconData? icon;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.gradientColors = const [Colors.blue, Colors.blueAccent],
    this.icon,
    this.width,
    this.height = 50,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLoading || onPressed == null 
              ? [Colors.grey, Colors.grey[400]!]
              : gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          child: Container(
            padding: padding ?? EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Center(
              child: _buildButtonContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
}

// Botón de texto personalizado
class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;
  final FontWeight fontWeight;
  final double fontSize;
  final IconData? icon;
  final bool underline;

  const CustomTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.textColor,
    this.fontWeight = FontWeight.w500,
    this.fontSize = 14,
    this.icon,
    this.underline = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonTextColor = textColor ?? theme.primaryColor;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: buttonTextColor,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      child: icon != null ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 2),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              decoration: underline ? TextDecoration.underline : null,
            ),
          ),
        ],
      ) : Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          decoration: underline ? TextDecoration.underline : null,
        ),
      ),
    );
  }
}

// Botón de acción flotante personalizado
class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final String? tooltip;
  final bool mini;

  const CustomFloatingActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.size = 56,
    this.tooltip,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fabBackgroundColor = backgroundColor ?? theme.primaryColor;
    final fabIconColor = iconColor ?? Colors.white;

    return SizedBox(
      width: mini ? 40 : size,
      height: mini ? 40 : size,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: fabBackgroundColor,
        foregroundColor: fabIconColor,
        tooltip: tooltip,
        mini: mini,
        elevation: 6,
        child: Icon(icon, size: mini ? 20 : 24),
      ),
    );
  }
}