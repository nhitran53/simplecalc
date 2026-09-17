import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  // What the screen shows right now.
  String _display = '0';

  // The left-hand number and the operator waiting on a second number.
  double? _pending;
  String? _operator;

  // True right after an operator or equals, so the next digit starts fresh.
  bool _startNewNumber = true;

  void _onDigit(String digit) {
    setState(() {
      if (_startNewNumber) {
        _display = digit;
        _startNewNumber = false;
      } else if (_display == '0') {
        _display = digit;
      } else {
        _display += digit;
      }
    });
  }

  void _onDecimal() {
    setState(() {
      if (_startNewNumber) {
        _display = '0.';
        _startNewNumber = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _onOperator(String operator) {
    setState(() {
      final current = double.parse(_display);
      if (_pending != null && _operator != null && !_startNewNumber) {
        _pending = _compute(_pending!, current, _operator!);
        _display = _format(_pending!);
      } else {
        _pending = current;
      }
      _operator = operator;
      _startNewNumber = true;
    });
  }

  void _onEquals() {
    setState(() {
      if (_pending == null || _operator == null) return;
      final result = _compute(_pending!, double.parse(_display), _operator!);
      _display = _format(result);
      _pending = null;
      _operator = null;
      _startNewNumber = true;
    });
  }

  void _onClear() {
    setState(() {
      _display = '0';
      _pending = null;
      _operator = null;
      _startNewNumber = true;
    });
  }

  void _onSign() {
    setState(() {
      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else if (_display != '0') {
        _display = '-$_display';
      }
    });
  }

  void _onPercent() {
    setState(() {
      _display = _format(double.parse(_display) / 100);
      _startNewNumber = true;
    });
  }

  double _compute(double left, double right, String operator) {
    switch (operator) {
      case '+':
        return left + right;
      case '-':
        return left - right;
      case '×':
        return left * right;
      case '÷':
        return right == 0 ? double.nan : left / right;
      default:
        return right;
    }
  }

  // Drop the trailing ".0" so whole numbers read as "12", not "12.0".
  String _format(double value) {
    if (value.isNaN || value.isInfinite) return 'Error';
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.inversePrimary,
        title: const Text('Simple Calculator'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(24),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomRight,
                  child: Text(
                    _display,
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buttonRow([
                    _Key('C', onTap: _onClear, kind: _KeyKind.function),
                    _Key('+/-', onTap: _onSign, kind: _KeyKind.function),
                    _Key('%', onTap: _onPercent, kind: _KeyKind.function),
                    _Key('÷',
                        onTap: () => _onOperator('÷'),
                        kind: _KeyKind.operator),
                  ]),
                  _buttonRow([
                    _Key('7', onTap: () => _onDigit('7')),
                    _Key('8', onTap: () => _onDigit('8')),
                    _Key('9', onTap: () => _onDigit('9')),
                    _Key('×',
                        onTap: () => _onOperator('×'),
                        kind: _KeyKind.operator),
                  ]),
                  _buttonRow([
                    _Key('4', onTap: () => _onDigit('4')),
                    _Key('5', onTap: () => _onDigit('5')),
                    _Key('6', onTap: () => _onDigit('6')),
                    _Key('-',
                        onTap: () => _onOperator('-'),
                        kind: _KeyKind.operator),
                  ]),
                  _buttonRow([
                    _Key('1', onTap: () => _onDigit('1')),
                    _Key('2', onTap: () => _onDigit('2')),
                    _Key('3', onTap: () => _onDigit('3')),
                    _Key('+',
                        onTap: () => _onOperator('+'),
                        kind: _KeyKind.operator),
                  ]),
                  _buttonRow([
                    _Key('0', onTap: () => _onDigit('0'), flex: 2),
                    _Key('.', onTap: _onDecimal),
                    _Key('=', onTap: _onEquals, kind: _KeyKind.operator),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttonRow(List<_Key> keys) {
    return Row(
      children: [
        for (final key in keys)
          Expanded(
            flex: key.flex,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: _CalcButton(config: key),
            ),
          ),
      ],
    );
  }
}

enum _KeyKind { digit, operator, function }

class _Key {
  const _Key(this.label,
      {required this.onTap, this.kind = _KeyKind.digit, this.flex = 1});

  final String label;
  final VoidCallback onTap;
  final _KeyKind kind;
  final int flex;
}

class _CalcButton extends StatelessWidget {
  const _CalcButton({required this.config});

  final _Key config;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (background, foreground) = switch (config.kind) {
      _KeyKind.operator => (scheme.primary, scheme.onPrimary),
      _KeyKind.function => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      _KeyKind.digit => (scheme.surfaceContainerHighest, scheme.onSurface),
    };

    return SizedBox(
      height: 72,
      child: FilledButton(
        onPressed: config.onTap,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          config.label,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
