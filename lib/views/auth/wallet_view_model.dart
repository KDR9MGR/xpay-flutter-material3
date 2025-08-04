import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../base_vm.dart';
import '../../data/request_money_model.dart';
import '../../data/transaction_model.dart';
import '../../data/user_model.dart';
import '../../utils/threading_utils.dart';
import '../../utils/crash_prevention.dart';
import '../../utils/app_logger.dart';
import 'package:flutter/foundation.dart';

class WalletViewModel extends BaseViewModel {
  List<TransactionModel> _transactions = [];
  bool _isDisposed = false;

  List<TransactionModel> get transactions => _transactions;

  List<RequestMoneyModel> _requests = [];

  List<RequestMoneyModel> get requests => _requests;

  // Memory safety check to prevent EXC_BAD_ACCESS
  bool get _isValid => !_isDisposed;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Future init() async {
    if (!_isValid) return;

    try {
      dataloadingState = DataloadingState.dataLoadComplete;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('WalletViewModel.init error: $e', tag: 'WalletViewModel');
      }
      dataloadingState = DataloadingState.error;
      notifyListeners();
    }
  }

  Future<void> addMoney(double amount, String currency) async {
    if (!_isValid) return;

    await CrashPrevention.safeExecute(() async {
      // Validate inputs to prevent crashes
      if (amount <= 0) {
        throw ArgumentError('Amount must be greater than zero');
      }
      if (currency.isEmpty) {
        throw ArgumentError('Currency cannot be empty');
      }

      // Use ThreadingUtils for Firebase operations to prevent main thread blocking
      await ThreadingUtils.runFirebaseOperation(() async {
        User? firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser == null) {
          if (kDebugMode) {
            AppLogger.warning('WalletViewModel.addMoney: No authenticated user found', tag: 'WalletViewModel');
          }
          return;
        }

        DocumentReference userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid);
        DocumentSnapshot userSnapshot = await userRef.get();

        if (userSnapshot.exists && userSnapshot.data() != null) {
          final data = userSnapshot.data() as Map<String, dynamic>?;
          if (data == null) {
            if (kDebugMode) {
              AppLogger.warning('WalletViewModel.addMoney: User data is null', tag: 'WalletViewModel');
            }
            return;
          }

          UserModel user = UserModel.fromMap(data);

          // Safe access to wallet balances with null check
          if (user.walletBalances.isEmpty) {
            user.walletBalances = <String, dynamic>{};
          }

          user.walletBalances[currency] =
              (user.walletBalances[currency] ?? 0) + amount;

          await userRef.update({'wallet_balances': user.walletBalances});

          TransactionModel transaction = TransactionModel(
            transactionId:
                FirebaseFirestore.instance.collection('transactions').doc().id,
            userId: user.userId,
            amount: amount,
            timestamp: DateTime.now(),
            type: 'add',
            currency: currency,
          );

          await FirebaseFirestore.instance
              .collection('transactions')
              .doc(transaction.transactionId)
              .set(transaction.toMap());
        }
      }, operationName: 'Add money to wallet');
    }, operationName: 'Add money operation');
  }

  Future<void> withdrawMoney(double amount, String currency) async {
    if (!_isValid) return;

    try {
      await ThreadingUtils.runFirebaseOperation(() async {
        User? firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser == null) {
          if (kDebugMode) {
            AppLogger.warning('WalletViewModel.withdrawMoney: No authenticated user found', tag: 'WalletViewModel');
          }
          return;
        }

        DocumentReference userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid);
        DocumentSnapshot userSnapshot = await userRef.get();

        if (userSnapshot.exists && userSnapshot.data() != null) {
          final data = userSnapshot.data() as Map<String, dynamic>?;
          if (data == null) {
            if (kDebugMode) {
              AppLogger.warning('WalletViewModel.withdrawMoney: User data is null', tag: 'WalletViewModel');
            }
            return;
          }

          UserModel user = UserModel.fromMap(data);

          // Safe access to wallet balances with null check
          if (user.walletBalances.isEmpty) {
            user.walletBalances = <String, dynamic>{};
          }

          double currentBalance = user.walletBalances[currency] ?? 0;

          if (currentBalance >= amount) {
            user.walletBalances[currency] = currentBalance - amount;

            await userRef.update({'wallet_balances': user.walletBalances});

            TransactionModel transaction = TransactionModel(
              transactionId:
                  FirebaseFirestore.instance
                      .collection('transactions')
                      .doc()
                      .id,
              userId: user.userId,
              amount: amount,
              timestamp: DateTime.now(),
              type: 'withdraw',
              currency: currency,
            );

            await FirebaseFirestore.instance
                .collection('transactions')
                .doc(transaction.transactionId)
                .set(transaction.toMap());
          } else {
            if (kDebugMode) {
              AppLogger.warning('WalletViewModel.withdrawMoney: Insufficient balance', tag: 'WalletViewModel');
            }
          }
        }
      }, operationName: 'Withdraw money from wallet');
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('WalletViewModel.withdrawMoney error: $e', tag: 'WalletViewModel');
      }
    }
  }

  Future<double> getCurrentWalletBalance(String currency) async {
    if (!_isValid) return 0.0;

    try {
      return await ThreadingUtils.runFirebaseOperation(() async {
        User? firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser == null) {
          if (kDebugMode) {
            AppLogger.warning(
              'WalletViewModel.getCurrentWalletBalance: No authenticated user found',
              tag: 'WalletViewModel',
            );
          }
          return 0.0;
        }

        DocumentSnapshot userSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(firebaseUser.uid)
                .get();

        if (userSnapshot.exists && userSnapshot.data() != null) {
          final data = userSnapshot.data() as Map<String, dynamic>?;
          if (data == null) {
            if (kDebugMode) {
              AppLogger.warning(
                'WalletViewModel.getCurrentWalletBalance: User data is null',
                tag: 'WalletViewModel',
              );
            }
            return 0.0;
          }

          UserModel user = UserModel.fromMap(data);

          return user.walletBalances[currency] ?? 0.0;
        }
        return 0.0;
      }, operationName: 'Get current wallet balance');
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('WalletViewModel.getCurrentWalletBalance error: $e', tag: 'WalletViewModel');
      }
    }
    return 0.0;
  }

  Future<void> sendMoneyToUser(
    String recipientEmail,
    double amount,
    String currency,
  ) async {
    if (!_isValid) return;

    if (kDebugMode) {
      AppLogger.info('WalletViewModel.sendMoneyToUser: recipientEmail: $recipientEmail', tag: 'WalletViewModel');
    }

    try {
      await ThreadingUtils.runFirebaseOperation(() async {
        User? senderUser = FirebaseAuth.instance.currentUser;
        if (senderUser == null) {
          if (kDebugMode) {
            print(
              'WalletViewModel.sendMoneyToUser: No authenticated user found',
            );
          }
          return;
        }

        // Fetch sender's details
        DocumentSnapshot senderSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(senderUser.uid)
                .get();
        if (!senderSnapshot.exists || senderSnapshot.data() == null) {
          if (kDebugMode) {
            AppLogger.warning('WalletViewModel.sendMoneyToUser: Sender data not found', tag: 'WalletViewModel');
          }
          return;
        }

        final senderData = senderSnapshot.data() as Map<String, dynamic>?;
        if (senderData == null) {
          if (kDebugMode) {
            AppLogger.warning('WalletViewModel.sendMoneyToUser: Sender data is null', tag: 'WalletViewModel');
          }
          return;
        }

        UserModel sender = UserModel.fromMap(senderData);

        // Fetch recipient's details by email
        QuerySnapshot recipientQuery =
            await FirebaseFirestore.instance
                .collection('users')
                .where('email_address', isEqualTo: recipientEmail)
                .get();
        if (recipientQuery.docs.isEmpty) {
          throw 'Recipient with email $recipientEmail not found';
        }

        final recipientData =
            recipientQuery.docs.first.data() as Map<String, dynamic>?;
        if (recipientData == null) {
          if (kDebugMode) {
            AppLogger.warning('WalletViewModel.sendMoneyToUser: Recipient data is null', tag: 'WalletViewModel');
          }
          return;
        }

        UserModel recipient = UserModel.fromMap(recipientData);

        // Safe access to wallet balances with null checks
        if (sender.walletBalances.isEmpty) {
          sender.walletBalances = <String, dynamic>{};
        }
        if (recipient.walletBalances.isEmpty) {
          recipient.walletBalances = <String, dynamic>{};
        }

        // Check if sender has enough balance
        double senderBalance = sender.walletBalances[currency] ?? 0;
        if (senderBalance < amount) {
          throw 'Insufficient balance to send money';
        }

        // Update sender's balance
        sender.walletBalances[currency] = senderBalance - amount;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(sender.userId)
            .update({'wallet_balances': sender.walletBalances});

        // Update recipient's balance
        recipient.walletBalances[currency] =
            (recipient.walletBalances[currency] ?? 0) + amount;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(recipient.userId)
            .update({'wallet_balances': recipient.walletBalances});

        // Record transaction for sender
        TransactionModel senderTransaction = TransactionModel(
          transactionId:
              FirebaseFirestore.instance.collection('transactions').doc().id,
          userId: sender.userId,
          amount: amount,
          timestamp: DateTime.now(),
          type: 'send',
          currency: currency,
        );
        await FirebaseFirestore.instance
            .collection('transactions')
            .doc(senderTransaction.transactionId)
            .set(senderTransaction.toMap());

        // Record transaction for recipient
        TransactionModel recipientTransaction = TransactionModel(
          transactionId:
              FirebaseFirestore.instance.collection('transactions').doc().id,
          userId: recipient.userId,
          amount: amount,
          timestamp: DateTime.now(),
          type: 'receive',
          currency: currency,
        );
        await FirebaseFirestore.instance
            .collection('transactions')
            .doc(recipientTransaction.transactionId)
            .set(recipientTransaction.toMap());
      }, operationName: 'Send money to user');

      // Notify listeners on main thread
      await ThreadingUtils.runUIOperation(() async {
        notifyListeners();
      });
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('WalletViewModel.sendMoneyToUser error: $e', tag: 'WalletViewModel');
      }
      rethrow; // Rethrow the error to handle it in the calling function
    }
  }

  Future<void> fetchTransactionHistory() async {
    if (!_isValid) return;

    try {
      await ThreadingUtils.runFirebaseOperation(() async {
        User? firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser == null) {
          if (kDebugMode) {
            AppLogger.warning(
              'WalletViewModel.fetchTransactionHistory: No authenticated user found',
              tag: 'WalletViewModel',
            );
          }
          return;
        }

        QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance
                .collection('transactions')
                .where('userId', isEqualTo: firebaseUser.uid)
                .orderBy('timestamp', descending: true)
                .get();

        _transactions =
            querySnapshot.docs
                .map((doc) {
                  final data = doc.data() as Map<String, dynamic>?;
                  if (data == null) {
                    if (kDebugMode) {
                      AppLogger.warning(
                        'WalletViewModel.fetchTransactionHistory: Transaction data is null',
                        tag: 'WalletViewModel',
                      );
                    }
                    return null;
                  }
                  return TransactionModel.fromMap(data);
                })
                .where((transaction) => transaction != null)
                .cast<TransactionModel>()
                .toList();
      }, operationName: 'Fetch transaction history');

      // Notify listeners on main thread
      await ThreadingUtils.runUIOperation(() async {
        notifyListeners();
      });
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('WalletViewModel.fetchTransactionHistory error: $e', tag: 'WalletViewModel');
      }
    }
  }

  Future<void> requestMoney(
    String recipientEmail,
    double amount,
    String currency,
    String notes,
  ) async {
    if (!_isValid) return;

    try {
      // Validate amount
      if (amount <= 0) {
        throw 'Amount should be greater than zero';
      }

      await ThreadingUtils.runFirebaseOperation(() async {
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Fetch recipient's details by email
        QuerySnapshot recipientQuery =
            await firestore
                .collection('users')
                .where('email_address', isEqualTo: recipientEmail)
                .get();
        if (recipientQuery.docs.isEmpty) {
          throw 'Recipient with email $recipientEmail not found';
        }

        // Create a new RequestMoneyModel for the request
        RequestMoneyModel requestMoney = RequestMoneyModel(
          requestId: firestore.collection('requests').doc().id,
          senderEmail: FirebaseAuth.instance.currentUser?.email,
          receiverEmail: recipientEmail,
          amount: amount,
          currency: currency,
          status: 'pending',
          requestedAt: DateTime.now(),
          notes: notes,
        );

        // Store the request in Firestore under a 'requests' collection
        await firestore
            .collection('requests')
            .doc(requestMoney.requestId)
            .set(requestMoney.toMap());
      }, operationName: 'Request money');

      if (kDebugMode) {
        AppLogger.info('WalletViewModel.requestMoney: Money request sent successfully', tag: 'WalletViewModel');
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('WalletViewModel.requestMoney error: $e', tag: 'WalletViewModel');
      }
      rethrow; // Rethrow the error to handle it in the calling function
    }
  }

  Future<void> fetchRequests() async {
    if (!_isValid) return;

    try {
      await ThreadingUtils.runFirebaseOperation(() async {
        String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;

        // Fetch requests where the current user is the sender
        QuerySnapshot senderRequestsSnapshot =
            await FirebaseFirestore.instance
                .collection('requests')
                .where('senderEmail', isEqualTo: currentUserEmail)
                .get();

        // Fetch requests where the current user is the receiver
        QuerySnapshot receiverRequestsSnapshot =
            await FirebaseFirestore.instance
                .collection('requests')
                .where('receiverEmail', isEqualTo: currentUserEmail)
                .get();

        // Combine the two lists of requests with null safety
        List<RequestMoneyModel> senderRequests =
            senderRequestsSnapshot.docs
                .map((doc) {
                  final data = doc.data() as Map<String, dynamic>?;
                  if (data == null) {
                    if (kDebugMode) {
                      AppLogger.warning(
                        'WalletViewModel.fetchRequests: Sender request data is null',
                        tag: 'WalletViewModel',
                      );
                    }
                    return null;
                  }
                  return RequestMoneyModel.fromMap(data);
                })
                .where((request) => request != null)
                .cast<RequestMoneyModel>()
                .toList();

        List<RequestMoneyModel> receiverRequests =
            receiverRequestsSnapshot.docs
                .map((doc) {
                  final data = doc.data() as Map<String, dynamic>?;
                  if (data == null) {
                    if (kDebugMode) {
                      AppLogger.warning(
                        'WalletViewModel.fetchRequests: Receiver request data is null',
                        tag: 'WalletViewModel',
                      );
                    }
                    return null;
                  }
                  return RequestMoneyModel.fromMap(data);
                })
                .where((request) => request != null)
                .cast<RequestMoneyModel>()
                .toList();

        // Merge the lists
        _requests = [...senderRequests, ...receiverRequests];
      }, operationName: 'Fetch requests');

      // Notify listeners on main thread
      await ThreadingUtils.runUIOperation(() async {
        notifyListeners();
      });
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('WalletViewModel.fetchRequests error: $e', tag: 'WalletViewModel');
      }
    }
  }

  Future<void> acceptRequest(RequestMoneyModel request) async {
    if (!_isValid) return;

    try {
      await ThreadingUtils.runFirebaseOperation(() async {
        request.status = 'accepted';
        await FirebaseFirestore.instance
            .collection('requests')
            .doc(request.requestId)
            .update(request.toMap());
      }, operationName: 'Accept request');

      await fetchRequests();
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('WalletViewModel.acceptRequest error: $e', tag: 'WalletViewModel');
      }
    }
  }

  Future<void> declineRequest(RequestMoneyModel request) async {
    if (!_isValid) return;

    try {
      await ThreadingUtils.runFirebaseOperation(() async {
        request.status = 'rejected';
        await FirebaseFirestore.instance
            .collection('requests')
            .doc(request.requestId)
            .update(request.toMap());
      }, operationName: 'Decline request');

      await fetchRequests();
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('WalletViewModel.declineRequest error: $e', tag: 'WalletViewModel');
      }
    }
  }

  Future<void> cancelRequest(RequestMoneyModel request) async {
    if (!_isValid) return;

    try {
      await ThreadingUtils.runFirebaseOperation(() async {
        request.status = 'canceled';
        await FirebaseFirestore.instance
            .collection('requests')
            .doc(request.requestId)
            .update(request.toMap());
      }, operationName: 'Cancel request');

      await fetchRequests();
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('WalletViewModel.cancelRequest error: $e', tag: 'WalletViewModel');
      }
    }
  }
}
