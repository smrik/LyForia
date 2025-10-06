import 'package:flutter/material.dart';
import 'package:lyforia/utils/app_constants.dart';

/// Centralized error handling utilities for consistent error management.
class ErrorHandler {
  /// Shows a standard error snackbar
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 4),
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
      ),
    );
  }

  /// Shows a standard success snackbar
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.onInverseSurface,
              size: AppSizes.iconSm,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
        duration: duration ?? const Duration(seconds: 3),
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
      ),
    );
  }

  /// Shows error dialog with consistent styling
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
          size: AppSizes.iconLg,
        ),
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        actions: [
          TextButton(
            onPressed: onPressed ?? () => Navigator.of(context).pop(),
            child: Text(buttonText ?? 'OK'),
          ),
        ],
      ),
    );
  }

  /// Standard error message formatter based on exception type
  static String formatErrorMessage(dynamic error) {
    if (error == null) return AppStrings.errorGeneric;

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return AppStrings.errorNetwork;
    }

    if (errorString.contains('permission') ||
        errorString.contains('unauthorized') ||
        errorString.contains('access denied')) {
      return 'You don\'t have permission to perform this action.';
    }

    if (errorString.contains('not found')) {
      return 'The requested item was not found.';
    }

    // Return the original error message if it's user-friendly
    if (error.toString().length < 100 &&
        !errorString.contains('exception') &&
        !errorString.contains('error')) {
      return error.toString();
    }

    return AppStrings.errorGeneric;
  }

  /// Handles async operations with consistent error handling
  static Future<T?> handleAsyncOperation<T>(
    BuildContext context, {
    required Future<T> Function() operation,
    String? successMessage,
    String? errorMessage,
    bool showLoading = false,
  }) async {
    try {
      final result = await operation();

      if (context.mounted && successMessage != null) {
        showSuccessSnackBar(context, successMessage);
      }

      return result;
    } catch (error) {
      if (context.mounted) {
        final message = errorMessage ?? formatErrorMessage(error);
        showErrorSnackBar(context, message);
      }
      return null;
    }
  }
}

/// Mixin for consistent error handling in stateful widgets
mixin ErrorHandlerMixin<T extends StatefulWidget> on State<T> {
  void showError(String message) {
    ErrorHandler.showErrorSnackBar(context, message);
  }

  void showSuccess(String message) {
    ErrorHandler.showSuccessSnackBar(context, message);
  }

  Future<R?> handleAsync<R>(
    Future<R> Function() operation, {
    String? successMessage,
    String? errorMessage,
  }) {
    return ErrorHandler.handleAsyncOperation(
      context,
      operation: operation,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }
}