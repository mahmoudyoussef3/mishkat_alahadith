import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/features/serag/data/models/serag_response_model.dart';

@immutable
sealed class SeragState {}

final class SeragInitial extends SeragState {}

final class SeragLoading extends SeragState {}

final class SeragSuccess extends SeragState {
  final SeragResponseModel messages;
  SeragSuccess(this.messages);
}




final class SeragFailure extends SeragState {
  final String errMessage;
  SeragFailure(this.errMessage);
}
