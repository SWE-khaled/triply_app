import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

const pageNetworkErrorMessage =
    'Unable to load data. Please check your internet connection and try again.';
const pageGenericErrorMessage = 'Unable to load data. Please try again.';

String pageLoadErrorMessage(Object error) {
  final description = error.toString().toLowerCase();
  if (error is SocketException || error is TimeoutException) {
    return pageNetworkErrorMessage;
  }
  if (error is DioException &&
      (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError)) {
    return pageNetworkErrorMessage;
  }
  if (error is FirebaseException &&
      const {
        'unavailable',
        'deadline-exceeded',
        'network-request-failed',
      }.contains(error.code)) {
    return pageNetworkErrorMessage;
  }
  if (description.contains('unavailable') ||
      description.contains('network') ||
      description.contains('connection') ||
      description.contains('timed out') ||
      description.contains('deadline-exceeded')) {
    return pageNetworkErrorMessage;
  }
  return pageGenericErrorMessage;
}

/// The message shown by My Trips: network failures keep the friendly
/// connection hint, every other failure keeps the original exception so the
/// generic text cannot hide the real cause.
String pageLoadErrorDetail(Object error) {
  final message = pageLoadErrorMessage(error);
  return message == pageGenericErrorMessage ? error.toString() : message;
}
