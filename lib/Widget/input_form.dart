import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class InputForm extends StatefulWidget {
  const InputForm({super.key});

  @override
  State<InputForm> createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  late TooltipBehavior _tooltipBehavior;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController curr_age = TextEditingController();
  final TextEditingController retire_age = TextEditingController();
  final TextEditingController curr_expense = TextEditingController();
  final TextEditingController inflation = TextEditingController();
  final TextEditingController life_excep = TextEditingController();
  final TextEditingController rateOfReturn = TextEditingController();
  final TextEditingController monthlySaving = TextEditingController();
  final List<BarData> _barData = [];

  final myFocusNode1 = FocusNode();
  final myFocusNode2 = FocusNode();
  final myFocusNode3 = FocusNode();
  final myFocusNode4 = FocusNode();
  final myFocusNode5 = FocusNode();
  final myFocusNode6 = FocusNode();
  final myFocusNode7 = FocusNode();

  //Values
  double expectedMonthlySaving = 0;
  double expectedYearlySaving = 0;
  double corpousSize = 0;
  double currentSavingMonthly = 0;
  double currentSavingYearly = 0;

  var _isdone = false;
  final sizedBox = const SizedBox(
    height: 20,
  );

  InputDecoration _decoration(String lable) {
    return InputDecoration(
      label: Text(
        lable,
        style: TextStyle(fontSize: 15),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  void dispose() {
    myFocusNode1.dispose();
    myFocusNode2.dispose();
    myFocusNode3.dispose();
    myFocusNode4.dispose();
    myFocusNode5.dispose();
    myFocusNode6.dispose();
    myFocusNode7.dispose();
    super.dispose();
  }

  void _calculate() {
    if (curr_age.text.isEmpty ||
        retire_age.text.isEmpty ||
        curr_expense.text.isEmpty ||
        monthlySaving.text.isEmpty ||
        inflation.text.isEmpty ||
        life_excep.text.isEmpty ||
        rateOfReturn.text.isEmpty) {
      return;
    }

    if (int.parse(curr_age.text) > int.parse(retire_age.text)) {
      return;
    }

    if (int.parse(retire_age.text) > int.parse(life_excep.text)) {
      return;
    }

    //current Age
    int currAge = int.parse(curr_age.text);
    //retirement Age
    int retireAge = int.parse(retire_age.text);
    //Current Expenses
    int currExp = int.parse(curr_expense.text);
    //monthly saving
    int monthlySave = int.parse(monthlySaving.text);
    //inflation
    double inf = double.parse(inflation.text) / 100;
    //life Expextation
    int lifExp = int.parse(life_excep.text);
    //Rate of return
    double ror = double.parse(rateOfReturn.text) / 100;

    // calculating the (monthly) future value

    //Future Value
    double FV = 0;
    //Present Value
    double PV = currExp.toDouble();
    //(retireAge - currAge)
    int n = retireAge - currAge;
    //inflation
    double r = inf;

    num temp = pow((1 + r), n);
    FV = PV * temp;

    //The annual income you require immediately after retirement
    double FVY = FV * 12;

    //retirement period
    int rp = lifExp - retireAge;

    //inflation adjusted RoR
    double iRor = ((1 + ror) / (1 + inf)) - 1;

    //monthly iRor
    iRor = iRor / 12;

    //Retirement period in months
    int Nper = rp * 12;

    //inflation agjusted montlhy income
    double PMT = FVY / 12;

    //Using PV Function from Excel if iRor is not Zero
    double result = 0;
    if (iRor != 0) {
      num temp2 = (pow((1 + iRor), Nper));

      double temp3 = (temp2 - 1) / iRor;

      result = (PMT * (1 + iRor) * temp3) / temp2;
    } else {
      result = (PMT * Nper);
    }

    // Caluculating expected monthly saving to get to the corpous goal

    num temp4 = pow((1 + ror), n);

    double expmonthly = ((result * ror) / (temp4 - 1)) / 12;
    expmonthly = expmonthly.roundToDouble();

    //Testing
    print(iRor);

    setState(() {
      expectedMonthlySaving = expmonthly;
      expectedYearlySaving = expmonthly * 12;
      currentSavingMonthly = monthlySave.toDouble();
      currentSavingYearly = monthlySave * 12 + (monthlySave * 12) * ror;
      corpousSize = result.roundToDouble();

      if (_barData.length == 0) {
        _barData.add(BarData(name: 'Expected', amount: expmonthly));
        _barData.add(BarData(name: 'Actual', amount: monthlySave.toDouble()));
      } else {
        _barData.insert(0, BarData(name: 'Expected', amount: expmonthly));
        _barData.insert(
            1, BarData(name: 'Actual', amount: monthlySave.toDouble()));
      }

      _isdone = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    int retage = 0;
    int curage = 0;
    int lfexp = 0;

    TextStyle textStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: 150,
                        child: TextFormField(
                            onChanged: (value) => _calculate(),
                            focusNode: myFocusNode1,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter current age';
                              }
                              curage = int.parse(value);
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            controller: curr_age,
                            decoration: _decoration('Current Age')),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        width: 150,
                        child: TextFormField(
                            onChanged: (value) => _calculate(),
                            focusNode: myFocusNode2,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter retirement age';
                              }
                              retage = int.parse(value);

                              if (curage > retage) {
                                return 'Enter valid retirement age';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            controller: retire_age,
                            decoration: _decoration('Planned Age to Retire')),
                      ),
                    ],
                  ),
                  sizedBox,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: 150,
                        child: TextFormField(
                          onChanged: (value) => _calculate(),
                          focusNode: myFocusNode3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter current expense';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          controller: curr_expense,
                          decoration: _decoration('Current Monthly Expense'),
                        ),
                      ),
                      Container(
                        width: 150,
                        child: TextFormField(
                          onChanged: (value) => _calculate(),
                          focusNode: myFocusNode7,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter monthly saving';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          controller: monthlySaving,
                          decoration: _decoration('Monthly Saving '),
                        ),
                      )
                    ],
                  ),
                  sizedBox,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 90,
                        child: TextFormField(
                          onChanged: (value) => _calculate(),
                          focusNode: myFocusNode5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter life expectancy';
                            }
                            lfexp = int.parse(value);

                            if (retage > lfexp) {
                              return 'Enter a valid life expectancy age';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          controller: life_excep,
                          decoration: _decoration('Life Expectancy'),
                        ),
                      ),
                      Container(
                        width: 90,
                        child: TextFormField(
                          onChanged: (value) => _calculate(),
                          focusNode: myFocusNode4,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter inflation rate';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          controller: inflation,
                          decoration: _decoration('Inflation %'),
                        ),
                      ),
                      Container(
                        width: 90,
                        child: TextFormField(
                          onChanged: (value) => _calculate(),
                          focusNode: myFocusNode6,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter rate of return';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          controller: rateOfReturn,
                          decoration: _decoration('Rate of Return %'),
                        ),
                      )
                    ],
                  ),
                  sizedBox,
                  sizedBox,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            myFocusNode1.unfocus();
                            myFocusNode2.unfocus();
                            myFocusNode3.unfocus();
                            myFocusNode4.unfocus();
                            myFocusNode5.unfocus();
                            myFocusNode6.unfocus();
                            myFocusNode7.unfocus();
                            _calculate();
                          }
                        },
                        child: Text('Calculate'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          if (_isdone)
            Container(
              margin: const EdgeInsets.all(16),
              child: ListView(
                shrinkWrap: true,
                children: [
                  sizedBox,
                  Divider(),
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Corpus Size:',
                          style: textStyle,
                        ),
                        Text(
                          corpousSize.toString(),
                          textAlign: TextAlign.center,
                          style: textStyle.copyWith(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'You should save (monthly):',
                          style: textStyle,
                        ),
                        Text(
                          expectedMonthlySaving.toString(),
                          textAlign: TextAlign.center,
                          style: expectedMonthlySaving > currentSavingMonthly
                              ? textStyle.copyWith(color: Colors.green)
                              : textStyle.copyWith(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'You should save (yearly):',
                          style: textStyle,
                        ),
                        Text(
                          expectedYearlySaving.toString(),
                          textAlign: TextAlign.center,
                          style: expectedYearlySaving > currentSavingYearly
                              ? textStyle.copyWith(color: Colors.green)
                              : textStyle.copyWith(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Currently you are saving (monthly):',
                          style: textStyle,
                        ),
                        Text(
                          currentSavingMonthly.toString(),
                          textAlign: TextAlign.center,
                          style: currentSavingMonthly > expectedMonthlySaving
                              ? textStyle.copyWith(color: Colors.green)
                              : textStyle.copyWith(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Currently you are saving (yearly):',
                          style: textStyle,
                        ),
                        Text(
                          currentSavingYearly.toString(),
                          textAlign: TextAlign.center,
                          style: currentSavingYearly > expectedYearlySaving
                              ? textStyle.copyWith(color: Colors.green)
                              : textStyle.copyWith(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  sizedBox,
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: SfCartesianChart(
                      tooltipBehavior: _tooltipBehavior,
                      series: <ChartSeries>[
                        BarSeries<BarData, String>(
                            dataSource: _barData,
                            xValueMapper: (BarData b, _) => b.name,
                            yValueMapper: (BarData b, _) => b.amount,
                            dataLabelSettings:
                                DataLabelSettings(isVisible: true),
                            enableTooltip: true),
                      ],
                      primaryXAxis: CategoryAxis(),
                      primaryYAxis: NumericAxis(
                          edgeLabelPlacement: EdgeLabelPlacement.shift,
                          numberFormat: NumberFormat.currency(
                              decimalDigits: 0,
                              name: 'INR',
                              locale: 'en_IN',
                              symbol: '₹ '),
                          title: AxisTitle(text: 'Saving')),
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class BarData {
  final String name;
  final double amount;
  BarData({
    required this.name,
    required this.amount,
  });
}
