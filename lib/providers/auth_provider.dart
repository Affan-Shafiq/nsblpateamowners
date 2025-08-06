import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  fb_auth.User? _currentUser;
  UserModel? _currentUserModel;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  // Getters
  fb_auth.User? get currentUser => _currentUser;
  UserModel? get currentUserModel => _currentUserModel;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get userId => _currentUser?.uid;
  String? get userName => _currentUser?.displayName;
  String? get userEmail => _currentUser?.email;

  AuthProvider() {
    _loadAuthState();
  }

  // Load authentication state
  Future<void> _loadAuthState() async {
    try {
      _isLoading = true;
      notifyListeners();

      final fb_auth.User? firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        _currentUser = firebaseUser;
        _isAuthenticated = true;
        
        // Load user model from Firestore
        try {
          final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
          if (userDoc.exists) {
            _currentUserModel = UserModel.fromMap(userDoc.data()!);
          }
        } catch (e) {
          print('Error loading user model: $e');
        }
      } else {
        _currentUser = null;
        _currentUserModel = null;
        _isAuthenticated = false;
      }
    } catch (e) {
      print('Error loading auth state: $e');
      _currentUser = null;
      _currentUserModel = null;
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign up with email and password
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String name,
    String role = 'Team Owner',
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Create user in Firebase Auth
      final fb_auth.UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final fb_auth.User? firebaseUser = result.user;
      if (firebaseUser == null) {
        throw Exception('Failed to create user');
      }

      // Update display name
      await firebaseUser.updateDisplayName(name);

      // Create user document in Firestore
      try {
        final userModel = UserModel(
          name: name,
          email: email,
          role: 'owner', // Default role for new signups
          teamsOwned: [], // Empty list for new users
        );

        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(userModel.toMap());
      } catch (firestoreError) {
        print('Error creating user document: $firestoreError');
        // Continue with signup even if Firestore fails
        // The user account is still created in Firebase Auth
      }

      // Update current user and sign out to redirect to login
      _currentUser = firebaseUser;
      _isAuthenticated = true;
      
      // Sign out to redirect to login page
      await _firebaseAuth.signOut();
      _currentUser = null;
      _isAuthenticated = false;

      _isLoading = false;
      notifyListeners();

      return {'success': true, 'message': 'Account created successfully! Please sign in with your new account.'};
    } on fb_auth.FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account with this email already exists.';
          break;
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'invalid-email':
          message = 'The email address is invalid.';
          break;
        default:
          message = 'An error occurred during signup: ${e.message}';
      }
      return {'success': false, 'message': message};
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Sign in with Firebase Auth
      final fb_auth.UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final fb_auth.User? firebaseUser = result.user;
      if (firebaseUser == null) {
        throw Exception('Failed to sign in');
      }

      // Load user model from Firestore
      try {
        final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (userDoc.exists) {
          _currentUserModel = UserModel.fromMap(userDoc.data()!);
        }
      } catch (e) {
        print('Error loading user model: $e');
      }

      _currentUser = firebaseUser;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();

      return {'success': true, 'message': 'Login successful!'};
    } on fb_auth.FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email address.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        case 'invalid-email':
          message = 'The email address is invalid.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Please try again later.';
          break;
        default:
          message = 'An error occurred during login: ${e.message}';
      }
      return {'success': false, 'message': message};
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }

  // Sign in with Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': 'Google sign-in was cancelled.'};
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final fb_auth.UserCredential result = await _firebaseAuth.signInWithCredential(credential);
      final fb_auth.User? firebaseUser = result.user;

      if (firebaseUser == null) {
        throw Exception('Failed to sign in with Google');
      }

      // Check if user document exists in Firestore, if not create it
      try {
        final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (!userDoc.exists) {
          final userModel = UserModel(
            name: firebaseUser.displayName ?? 'User',
            email: firebaseUser.email ?? '',
            role: 'owner', // Default role for new Google sign-ins
            teamsOwned: [], // Empty list for new users
          );
          await _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .set(userModel.toMap());
          _currentUserModel = userModel;
        } else {
          _currentUserModel = UserModel.fromMap(userDoc.data()!);
        }
      } catch (firestoreError) {
        print('Error checking/creating user document: $firestoreError');
        // Continue with sign-in even if Firestore fails
      }

      _currentUser = firebaseUser;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      
      return {'success': true, 'message': 'Google sign-in successful!'};
    } on fb_auth.FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      
      String message;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          message = 'An account already exists with the same email address but different sign-in credentials.';
          break;
        case 'invalid-credential':
          message = 'The credential is invalid or has expired.';
          break;
        case 'operation-not-allowed':
          message = 'Google sign-in is not enabled.';
          break;
        default:
          message = 'An error occurred during Google sign-in: ${e.message}';
      }
      return {'success': false, 'message': message};
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }

  // Sign out
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      
      _currentUser = null;
      _currentUserModel = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    if (_currentUser == null) return;

    try {
      await _currentUser!.updateDisplayName(displayName);
      if (photoURL != null) {
        await _currentUser!.updatePhotoURL(photoURL);
      }
      
      // Reload user to get updated data
      await _currentUser!.reload();
      _currentUser = _firebaseAuth.currentUser;
      notifyListeners();
    } catch (e) {
      print('Error updating profile: $e');
    }
  }
} 