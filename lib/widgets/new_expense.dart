import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/model/expense.dart';

final formatter = DateFormat.yMd();

class NewExpense extends StatefulWidget {
  const NewExpense({super.key, required this.onAddExpense});

  final void Function(Expense expense) onAddExpense;
  @override
  State<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category _selectedCategory = Category.leisure;

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _submitExpenseData() {
    final eneteredAmount = double.tryParse(_amountController.text);
    final amountIsInvalid = eneteredAmount == null || eneteredAmount <= 0;
    if (_titleController.text.trim().isEmpty ||
        amountIsInvalid ||
        _selectedDate == null) {
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Invalid Input'),
              content: Text(
                "Please make sure all things are filled properly...",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Okay"),
                ),
              ],
            ),
      );
      return;
    }
    widget.onAddExpense(
      Expense(
        title: _titleController.text,
        category: _selectedCategory,
        amount: eneteredAmount,
        date: _selectedDate!,
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 80, 16, 16),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            maxLength: 50,
            decoration: InputDecoration(label: Text("Title")),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,

                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixText: " ₹ ",
                    label: Text("Amount"),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                //using flexible instead of expanded
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      //wrapping the text with expanded to avoid over flow
                      child: Text(
                        _selectedDate == null
                            ? "No Date Selected"
                            : formatter.format(_selectedDate!),
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        textAlign:
                            TextAlign
                                .right, //might later add something to keep the thing to right
                      ),
                    ),
                    IconButton(
                      onPressed: _presentDatePicker,
                      icon: Icon(Icons.calendar_month),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              DropdownButton(
                value: _selectedCategory,
                items:
                    Category.values
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category.name.toUpperCase()),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: _submitExpenseData,
                child: Text("Save Expense"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
