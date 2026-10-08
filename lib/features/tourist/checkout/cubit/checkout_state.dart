class CheckoutState {
  final String? cardNumberError;
  final String? expiryError;
  final String? cvvError;
  final String? cardholderError;
  final bool isPaying;
  final String? payError;
  final String? paymentToken;

  const CheckoutState({
    this.cardNumberError,
    this.expiryError,
    this.cvvError,
    this.cardholderError,
    this.isPaying = false,
    this.payError,
    this.paymentToken,
  });

  static const _keep = Object();

  CheckoutState copyWith({
    Object? cardNumberError = _keep,
    Object? expiryError = _keep,
    Object? cvvError = _keep,
    Object? cardholderError = _keep,
    bool? isPaying,
    Object? payError = _keep,
    Object? paymentToken = _keep,
  }) {
    return CheckoutState(
      cardNumberError: cardNumberError == _keep
          ? this.cardNumberError
          : cardNumberError as String?,
      expiryError:
          expiryError == _keep ? this.expiryError : expiryError as String?,
      cvvError:
          cvvError == _keep ? this.cvvError : cvvError as String?,
      cardholderError: cardholderError == _keep
          ? this.cardholderError
          : cardholderError as String?,
      isPaying: isPaying ?? this.isPaying,
      payError: payError == _keep ? this.payError : payError as String?,
      paymentToken: paymentToken == _keep
          ? this.paymentToken
          : paymentToken as String?,
    );
  }
}
