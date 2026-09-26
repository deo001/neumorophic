import 'package:flutter/material.dart';


class NumericKeypad extends StatelessWidget {
  final ValueSetter<int> onInputNumber;
  final VoidCallback onClearLastInput;
  final VoidCallback onClearAll;
  const NumericKeypad({
    super.key,
    required this.onInputNumber,
    required this.onClearLastInput,
    required this.onClearAll,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for(int i =1; i<4; i++)
        Expanded(child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for(int j =1; j<4;j++)
            Expanded(child: Numeral(
              number: (i - 1) * 3 + j,
              onKeyPress: () => onInputNumber((i-1) *3 + j)
            ),),
            
          ],
        ),),
        Expanded(
          child: Row(
            crossAxisAlignment:CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Expanded(child: 
              Numeral(
                number: 0,
                onKeyPress: () => onInputNumber(0),
              )),
              Expanded(child: ClearButton(
                onClearLastInput:onClearLastInput,
                onClearAll:onClearAll,
              ))
            ],
          ),
        ),
      ]
    );
  }
}

class Numeral extends StatelessWidget { 
   const Numeral({
    super.key,
    required this.number,
    required this.onKeyPress,
  });

  final int number;
  final VoidCallback onKeyPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
 backgroundColor: const Color(0xFFF1F4FE),
          shape: const CircleBorder(),        ),
        onPressed: onKeyPress, child: Text('$number')),
    );
  }
}

class ClearButton extends StatelessWidget {
  const ClearButton({
    super.key,
    required this.onClearLastInput,
    required this.onClearAll,
  });

  final VoidCallback onClearLastInput;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onClearAll,
      child: IconButton(
        onPressed: onClearLastInput,
        icon: const Icon(
          Icons.backspace,
          color: Color(0xFFF1F4FE),
        ),
      ),
    );
  }
}
