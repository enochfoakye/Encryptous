import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'database.dart';

class NewCardPage extends StatefulWidget {
  static const routeName = '/Encryptous/addCard2';
  const NewCardPage({super.key});
  @override
  State<NewCardPage> createState() => _NewCardPageState();
}

class _NewCardPageState extends State<NewCardPage> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  OutlineInputBorder? border;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//This passage of code is
  void savedCardData(String cardNumber, String expiryDate,
      String cardHolderName, String cvvCode) async {
    final row = {
      'card_number': cardNumber,
      'expiry_date': expiryDate,
      'card_holder_name': cardHolderName,
      'cvv_code': cvvCode,
    };
    final id =
        await EncryptousHelper.instance.insertCard(row); //goes to database
    final allRows =
        await EncryptousHelper.instance.queryAllRows(); // prints to console
    print(allRows);

    print('Card saved with id: $id');
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Encryptous'),
      ),
      // All body code (e.g. widgets) go after body:

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CreditCardWidget(
            cardNumber: cardNumber,
            expiryDate: expiryDate,
            cardHolderName: cardHolderName,
            cvvCode: cvvCode,
            showBackView: isCvvFocused,
            onCreditCardWidgetChange:
                (CreditCardBrand) {}, //true when you want to show cvv(back) view
          ),
          CreditCardForm(
            formKey: formKey,
            obscureCvv: true,
            obscureNumber: true,
            cardNumber: cardNumber,
            cvvCode: cvvCode,
            isHolderNameVisible: true,
            isCardNumberVisible: true,
            isExpiryDateVisible: true,
            cardHolderName: cardHolderName,
            expiryDate: expiryDate,
            themeColor: Colors.blue,
            textColor: Color.fromARGB(255, 0, 0, 0),
            cardNumberDecoration: InputDecoration(
              labelText: 'Number',
              hintText: 'XXXX XXXX XXXX XXXX',
              hintStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              labelStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              focusedBorder: border,
              enabledBorder: border,
            ),
            expiryDateDecoration: InputDecoration(
              hintStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              labelStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              focusedBorder: border,
              enabledBorder: border,
              labelText: 'Expired Date',
              hintText: 'XX/XX',
            ),
            cvvCodeDecoration: InputDecoration(
              hintStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              labelStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              focusedBorder: border,
              enabledBorder: border,
              labelText: 'CVV',
              hintText: 'XXX',
            ),
            cardHolderDecoration: InputDecoration(
              hintStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              labelStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              focusedBorder: border,
              enabledBorder: border,
              labelText: 'Card Holder',
            ),
            onCreditCardModelChange: onCreditCardModelChange,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            print(
                'Card saved: $cardNumber, $expiryDate, $cardHolderName, $cvvCode');

            savedCardData(cardNumber, expiryDate, cardHolderName, cvvCode);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Card Details saved Succesfully')),
            );
          }
        },
        label: const Text('Save card'),
        icon: const Icon(Icons.save),
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      cardNumber = creditCardModel!.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
