import 'package:flutter/material.dart';

@immutable
sealed class SeragState {}

final class SeragInitial extends SeragState {}

final class SeragLoading extends SeragState {}

final class SeragSuccess extends SeragState {
  final String response;
  SeragSuccess(this.response);
}

final class SeragFailure extends SeragState {
  final String errMessage;
  SeragFailure(this.errMessage);
}
