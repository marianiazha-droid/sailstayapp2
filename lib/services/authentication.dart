import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import

class AuthService {
  // 1. Instances for Auth and Firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 2. Stream to listen to Auth state changes
  Stream<User?> get userStream => _auth.authStateChanges();

  // 3. SIGN UP with Firestore storage
  Future<String?> signUp({
    required String email,
    required String password,
    required String username, // Now accepts username
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save additional data to Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'username': username,
        'email': email,
        'uid': credential.user!.uid,
        'createdAt': DateTime.now(),
      });

      return "Success";
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return "An error occurred during sign up.";
    }
  }

  // 4. LOGIN using Username (Searches Firestore first)
  Future<String?> logInWithUsername({
    required String username,
    required String password,
  }) async {
    try {
      // Search Firestore for the email linked to this username
      var snapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (snapshot.docs.isEmpty) {
        return "Username not found.";
      }

      // Get the email and log in
      String email = snapshot.docs.first.get('email');
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      
      return "Success";
    } catch (e) {
      return "Login failed. Check your username and password.";
    }
  }

  // 5. GET USERNAME for the HomeScreen
  Future<String> getUsername() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = 
            await _firestore.collection('users').doc(user.uid).get();
        return doc.get('username') ?? "User";
      }
      return "Guest";
    } catch (e) {
      return "User";
    }
  }

  // 6. SIGN OUT
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 7. Error Handling Helper
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return "No account found with this email.";
      case 'wrong-password': return "Incorrect password.";
      case 'email-already-in-use': return "Email already registered.";
      case 'invalid-email': return "Invalid email format.";
      case 'weak-password': return "Password is too weak.";
      default: return e.message ?? "Authentication failed.";
    }
  }
}