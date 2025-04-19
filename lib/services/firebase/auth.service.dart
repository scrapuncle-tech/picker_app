import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/auth_process_state.model.dart';
import '../../models/picker.entity.dart';
import '../../utilities/firebase_constants.dart';

class AuthFunctions {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current authenticated user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Stream<AuthProcessState> signIn({
    required String email,
    required String password,
  }) async* {
    yield AuthProcessState.started();

    try {
      yield AuthProcessState.loading();

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final pickerData =
          await _firestore
              .collection(FirebaseConstants.pickerCollection)
              .doc(userCredential.user!.uid)
              .get();

      if (!pickerData.exists) {
        yield AuthProcessState.error('User data not found');
        return;
      }

      final picker = Picker.fromFirebase(pickerData.data()!);
      yield AuthProcessState.success(picker);
    } on FirebaseAuthException catch (e) {
      yield AuthProcessState.error('Sign up failed: ${e.message}');
    }
  }

  // Sign up with email, password, and additional details
  Stream<AuthProcessState> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async* {
    yield AuthProcessState.started();
    try {
      yield AuthProcessState.loading();

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Do to some additional user details specific to pickers
      Picker pickerData = Picker(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        phoneNo: phone,
        isAvailable: true,
        isPicker: true,
        licenseNo: '',
        assignedVehicleId: '',
        assignedVehicleName: '',
        isDriver: false,
        isHelper: false,
        isOnLeave: false,
        isWorking: false,
        routeName: '',
      );

      await _firestore
          .collection(FirebaseConstants.pickerCollection)
          .doc(userCredential.user!.uid)
          .set(pickerData.toFirebase());

      yield AuthProcessState.success(pickerData);
    } on FirebaseAuthException catch (e) {
      yield AuthProcessState.error('Sign up failed: ${e.message}');
    }
  }

  Stream<Picker> pickerDataChanges({required String userId}) {
    return _firestore
        .collection(FirebaseConstants.pickerCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) => Picker.fromFirebase(snapshot.data()!));
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }
}
