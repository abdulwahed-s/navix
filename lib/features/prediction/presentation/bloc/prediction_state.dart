part of 'prediction_bloc.dart';

abstract class PredictionState extends Equatable {
  const PredictionState();

  @override
  List<Object?> get props => [];
}

class PredictionInitial extends PredictionState {
  const PredictionInitial();
}

class PredictionLoading extends PredictionState {
  const PredictionLoading();
}

class PredictionLoaded extends PredictionState {
  final RiskPredictionEntity prediction;

  const PredictionLoaded(this.prediction);

  @override
  List<Object?> get props => [prediction];
}

class PredictionEmpty extends PredictionState {
  const PredictionEmpty();
}

class PredictionError extends PredictionState {
  final String message;

  const PredictionError(this.message);

  @override
  List<Object?> get props => [message];
}
