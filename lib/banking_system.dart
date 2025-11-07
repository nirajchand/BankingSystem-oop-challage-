
// Interface for interest-bearing accounts
abstract class InterestBearing {
  double calculateInterest();
}

// Abstract base class
abstract class BankAccount {
  int _accountNumber;
  String _holderName;
  double _balance;
  List<String> _transactions = [];

  BankAccount(this._accountNumber, this._holderName, this._balance);

  int get accountNumber => _accountNumber;
  String get holderName => _holderName;
  double get balance => _balance;
  List<String> get transactions => _transactions;

  set holderName(String name) => _holderName = name;
  set accountNumber(int acNo) => _accountNumber = acNo;
  set acBalance(double bal) => _balance = bal;


  void recordTransaction(String detail) {
    _transactions.add("${DateTime.now()}: $detail");
  }

  void displayInfo() {
    print(
      "Account No: $_accountNumber | Holder: $_holderName | Balance: \$${_balance.toStringAsFixed(2)}",
    );
  }

  void deposit(double amount);
  void withdraw(double amount);
}

// Savings Account
class SavingsAccount extends BankAccount implements InterestBearing {
  static const double minBalance = 500;
  static const double interestRate = 0.02;
  int withdrawalCount = 0;

  SavingsAccount(int num, String name, double bal) : super(num, name, bal);

  @override
  void deposit(double amount) {
    _balance += amount;
    recordTransaction("Deposited \$${amount.toStringAsFixed(2)}");
  }

  @override
  void withdraw(double amount) {
    if (withdrawalCount >= 3) {
      print("Withdrawal limit reached!");
      return;
    }
    if (_balance - amount < minBalance) {
      print("Cannot go below minimum balance!");
      return;
    }
    _balance -= amount;
    withdrawalCount++;
    recordTransaction("Withdrew \$${amount.toStringAsFixed(2)}");
  }

  @override
  double calculateInterest() => _balance * interestRate;
}

// Checking Account
class CheckingAccount extends BankAccount {
  static const double overdraftFee = 35;

  CheckingAccount(int num, String name, double bal) : super(num, name, bal);

  @override
  void deposit(double amount) {
    _balance += amount;
    recordTransaction("Deposited \$${amount.toStringAsFixed(2)}");
  }

  @override
  void withdraw(double amount) {
    _balance -= amount;
    if (_balance < 0) {
      _balance -= overdraftFee;
      recordTransaction("Overdraft fee applied: \$35");
    }
    recordTransaction("Withdrew \$${amount.toStringAsFixed(2)}");
  }
}

// Premium Account
class PremiumAccount extends BankAccount implements InterestBearing {
  static const double minBalance = 10000;
  static const double interestRate = 0.05;

  PremiumAccount(int num, String name, double bal) : super(num, name, bal);

  @override
  void deposit(double amount) {
    _balance += amount;
    recordTransaction("Deposited \$${amount.toStringAsFixed(2)}");
  }

  @override
  void withdraw(double amount) {
    if (_balance - amount < minBalance) {
      print("Cannot go below minimum balance!");
      return;
    }
    _balance -= amount;
    recordTransaction("Withdrew \$${amount.toStringAsFixed(2)}");
  }

  @override
  double calculateInterest() => _balance * interestRate;
}

// Student Account
class StudentAccount extends BankAccount {
  static const double maxBalance = 5000;

  StudentAccount(int num, String name, double bal) : super(num, name, bal);

  @override
  void deposit(double amount) {
    if (_balance + amount > maxBalance) {
      print("Cannot exceed max balance!");
      return;
    }
    _balance += amount;
    recordTransaction("Deposited \$${amount.toStringAsFixed(2)}");
  }

  @override
  void withdraw(double amount) {
    if (_balance < amount) {
      print("Insufficient funds!");
      return;
    }
    _balance -= amount;
    recordTransaction("Withdrew \$${amount.toStringAsFixed(2)}");
  }
}

// Bank class
class Bank {
  List<BankAccount> accounts = [];

  void addAccount(BankAccount account) => accounts.add(account);

  BankAccount? findAccount(int num) {
    try {
      return accounts.firstWhere((a) => a.accountNumber == num);
    } catch (e) {
      return null;
    }
  }

  void transfer(int from, int to, double amt) {
    var acc1 = findAccount(from);
    var acc2 = findAccount(to);
    if (acc1 == null || acc2 == null) {
      print("Account not found!");
      return;
    }
    acc1.withdraw(amt);
    acc2.deposit(amt);
    print("Transferred \$${amt.toStringAsFixed(2)} from $from to $to");
  }

  void applyMonthlyInterest() {
    for (var acc in accounts) {
      if (acc is InterestBearing) {
        double interest = (acc as InterestBearing).calculateInterest();
        acc.deposit(interest);
        acc.recordTransaction(
          "Interest added: \$${interest.toStringAsFixed(2)}",
        );
      }
    }
  }

  void report() {
    print("\n=== Bank Report ===");
    for (var acc in accounts) {
      acc.displayInfo();
      for (var t in acc.transactions) {
        print("  - $t");
      }
      print("");
    }
  }
}

// Main function
void main() {
  Bank bank = Bank();

  var acc1 = SavingsAccount(101, "Alice", 1000);
  var acc2 = CheckingAccount(102, "Bob", 200);
  var acc3 = PremiumAccount(103, "Charlie", 20000);
  var acc4 = StudentAccount(104, "David", 3000);

  bank.addAccount(acc1);
  bank.addAccount(acc2);
  bank.addAccount(acc3);
  bank.addAccount(acc4);

  acc1.withdraw(200);
  acc2.withdraw(300);
  acc3.deposit(1000);
  acc4.deposit(1500);

  bank.transfer(101, 102, 100);
  bank.applyMonthlyInterest();
  bank.report();
}
