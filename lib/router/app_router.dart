import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/components/foot_navigation.dart';
import 'package:pbl_app_joglo66/router/protected_route.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_field/booking_details_admin_screens.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_field/change_booking_admin_screens.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_field/form_input_booking.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_field/list_booking_admin_screens.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_field/payment_details_page_admin_screens.dart';
import 'package:pbl_app_joglo66/screens/admin/field/field_details_admin_screens.dart';
import 'package:pbl_app_joglo66/screens/admin/field/form_close_field_admin_screens.dart';
import 'package:pbl_app_joglo66/screens/admin/field/form_edit_field_admin_screens.dart';
import 'package:pbl_app_joglo66/screens/admin/field/list_closed_booking_admin_screens.dart';
import 'package:pbl_app_joglo66/screens/admin/field/list_field_admin_screens.dart';
import 'package:pbl_app_joglo66/screens/auth/login_screens.dart';
import 'package:pbl_app_joglo66/screens/auth/register_screens.dart';
import 'package:pbl_app_joglo66/services/auth_service.dart';

final authService = AuthService(); // Buat instance global

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  refreshListenable: authService,

  redirect: (context, state) {
    final bool loggedIn = authService.isLoggedIn;
    // Cek tujuan URL saat ini
    final bool isGoingToLogin = state.uri.toString() == '/login';
    final bool isGoingToRegister = state.uri.toString() == '/register';

    
    if (!loggedIn && !isGoingToLogin && !isGoingToRegister) {
      return '/login'; 
    }

    if (loggedIn && (isGoingToLogin || isGoingToRegister)) {
      return '/admin/dashboard'; 
    }

    return null; 
  },

  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreens(), 
    ),

    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreens(), 
    ),

    GoRoute(
      path: '/',
      builder: (context, state) {
        return const CustomBottomNavPage();
      },
    ),

    GoRoute(
      path: '/admin/list-field',
      builder: (context, state) {
        return ProtectedRoute(
          allowedRoles: ['admin'],
          currentRole: authService.role,
          child: const ListFieldAdminScreens()
        );
      }
    ),

     GoRoute(
      path: '/admin/field-details/:field_id',
      builder: (context, state) {
        final String currentFieldId = state.pathParameters['field_id']!;

        return ProtectedRoute(
          allowedRoles: ['admin'], 
          currentRole: authService.role,
          child: FieldDetailsAdminScreens(fieldId: currentFieldId)
        );
      }
    ),

    GoRoute(
      path: '/admin/edit-field-details/:field_id',
      builder: (context, state) {
        final String currentFieldId = state.pathParameters['field_id']!;

        return ProtectedRoute(
          allowedRoles: ['admin'], 
          currentRole: authService.role,
          child: FormEditFieldAdminScreens(fieldId: currentFieldId)
        );
      }
    ),

     GoRoute(
      path: '/admin/close-field/:field_id',
      builder: (context, state) {
        final String currentFieldId = state.pathParameters['field_id']!;

        return ProtectedRoute(
          allowedRoles: ['admin'], 
          currentRole: authService.role,
          child: FormCloseFieldAdminScreens(fieldId: currentFieldId)
        );
      }
    ),

     GoRoute(
      path: '/admin/list-closed-booking',
      builder: (context, state) {
        return ProtectedRoute(
          allowedRoles: ['admin'], 
          currentRole: authService.role,
          child: ListClosedBookingAdminScreens()
        );
      }
    ),

    GoRoute(
      path: '/admin/form-input-booking',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        
        return FormInputBooking(
          nameField: data['nameField'] as String, 
          selectedDate: data['selectedDate'],     
          hours: data['hours'],
          duration: data['duration'] as int,
        );
      },
    ),

    // Tambahkan di dalam array routes: [...]
    GoRoute(
      path: '/admin/payment-details',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        
        return PaymentDetailsPageAdminScreens(
          nameField: data['nameField'] as String,
          nameTenant: data['nameTenant'] as String,
          selectedDate: data['selectedDate'],
          hours: data['hours'],             
          duration: data['duration'] as int,
          totalPrice: data['totalPrice'] as int,
          downPaymentPrice: data['downPaymentPrice'] as int,
          statusEarly: data['statusEarly'],  
        );
      },
    ),

    GoRoute(
      path: '/admin/list-booking',
      builder: (context, state) {
        return ProtectedRoute(
          allowedRoles: ['admin'], 
          currentRole: authService.role,
          child: const ListBookingAdminScreens()
        );
      }
    ),

    GoRoute(
      path: '/admin/booking-detail/:booking_id',
      builder: (context, state) {
        final String currentBookingId = state.pathParameters['booking_id']!;

        return ProtectedRoute(
          allowedRoles: ['admin'], 
          currentRole: authService.role,
          child: BookingDetailsAdminScreen(bookingId: currentBookingId)
        );
      }
    ),

    GoRoute(
      path: '/admin/change-booking/:booking_id',
      builder: (context, state) {
        final String currentBookingId = state.pathParameters['booking_id']!;

        return ProtectedRoute(
          allowedRoles: ['admin'], 
          currentRole: authService.role,
          child: ChangeBookingAdminScreens(bookingId: currentBookingId)
        );
      }
    ),

  ],
);