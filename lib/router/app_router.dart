import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/components/foot_navigation.dart';
import 'package:pbl_app_joglo66/router/protected_route.dart';
import 'package:pbl_app_joglo66/screens/admin/attribute_booking/add_attribute_booking.dart';
import 'package:pbl_app_joglo66/screens/admin/attribute_booking/confirmation_attribute_booking.dart';
import 'package:pbl_app_joglo66/screens/admin/attribute_booking/history_attribute_booking.dart';
import 'package:pbl_app_joglo66/screens/admin/attribute_field/list_attribute.dart';
import 'package:pbl_app_joglo66/screens/admin/attribute_field/add_attribute.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_field/booking_details_admin_screens.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_field/change_booking_admin_screens.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_field/check_slot_availability_admin_screens.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_field/form_input_booking.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_field/list_booking_admin_screens.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_field/payment_details_page_admin_screens.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_field/successful_payment_admin_screens.dart';
import 'package:pbl_app_joglo66/screens/admin/expense_field/add_expense.dart';
import 'package:pbl_app_joglo66/screens/admin/expense_field/detail_expense.dart';
import 'package:pbl_app_joglo66/screens/admin/expense_field/list_expense.dart';
import 'package:pbl_app_joglo66/screens/admin/field/field_details_admin_screens.dart';
import 'package:pbl_app_joglo66/screens/admin/field/form_close_field_admin_screens.dart';
import 'package:pbl_app_joglo66/screens/admin/field/form_edit_field_admin_screens.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_field/list_closed_booking_admin_screens.dart';
import 'package:pbl_app_joglo66/screens/admin/field/list_field_admin_screens.dart';
import 'package:pbl_app_joglo66/screens/admin/profile_screen.dart';
import 'package:pbl_app_joglo66/screens/auth/login_screens.dart';
import 'package:pbl_app_joglo66/screens/auth/register_screens.dart';
import 'package:pbl_app_joglo66/services/auth_service.dart';
import 'package:pbl_app_joglo66/screens/admin/dashboard_admin_screens.dart';

final authService = AuthService();

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/admin/dashboard',
  refreshListenable: authService,

  redirect: (context, state) {
    final bool loggedIn = authService.isLoggedIn;
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
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoginScreens(),
    ),

    GoRoute(
      path: '/register',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const RegisterScreens(),
    ),

    // =========================================================================
    // SHELL ROUTE: SEMUA HALAMAN DI BAWAH INI AKAN MEMILIKI BOTTOM NAVIGATION
    // =========================================================================
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return CustomBottomNavPage(child: child);
      },
      routes: [
        GoRoute(
          path: '/admin/dashboard',
          builder: (context, state) {
            return const DashboardAdminScreens();
          },
        ),
        GoRoute(
          path: '/admin/list-field',
          builder: (context, state) {
            return ProtectedRoute(
              allowedRoles: ['worker'],
              currentRole: authService.role,
              child: const ListFieldAdminScreens(),
            );
          },
        ),
        GoRoute(
          path: '/admin/list-booking',
          builder: (context, state) {
            return ProtectedRoute(
              allowedRoles: ['worker'],
              currentRole: authService.role,
              child: const ListBookingAdminScreens(),
            );
          },
        ),
        GoRoute(
          path: '/admin/profile',
          builder: (context, state) {
            return const ProfileScreen();
          },
        ),
        GoRoute(
          path: '/admin/list-attribute',
          builder: (context, state) {
            return const ListAttributeScreens();
          },
        ),
        GoRoute(
          path: '/admin/add-attribute',
          builder: (context, state) {
            return const AddAttributeScreens();
          },
        ),
        GoRoute(
          path: '/admin/rent-attribute',
          builder: (context, state) {
            return const AddAttributeBookingScreens();
          },
        ),
        GoRoute(
          path: '/admin/confirmation-rent-attribute',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};

            return ConfirmationAttributeBookingScreens(
              fkBookingId: extra['fkBookingId'] as int? ?? 0,
              items:
                  (extra['items'] as List<dynamic>?)
                      ?.map((e) => e as Map<String, dynamic>)
                      .toList() ??
                  [],
              customerName: extra['customerName'] as String? ?? '',
              customerPhone: extra['customerPhone'] as String? ?? '',
              durationHours: extra['durationHours'] as int? ?? 1,
              transactionDate: extra['transactionDate'] as String? ?? '',
              totalPrice: extra['totalPrice'] as int? ?? 0,
            );
          },
        ),
        GoRoute(
          path: '/admin/history-rent-attribute',
          builder: (context, state) {
            return const HistoryAttributeBookingScreens();
          },
        ),
        GoRoute(
          path: '/admin/list-expense-field',
          builder: (context, state) => const ListExpensePage(),
        ),
        GoRoute(
          path: '/admin/add-expense-field',
          builder: (context, state) => const AddExpensePage(),
        ),
        GoRoute(
          path: '/admin/detail-expense-field',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return DetailExpensePage(expenseData: extra);
          },
        ),
      ],
    ),

    // =========================================================================
    // HALAMAN FULL SCREEN (TIDAK ADA BOTTOM NAVIGATION BAR)
    // =========================================================================
    GoRoute(
      path: '/admin/check-availability',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        return ProtectedRoute(
          allowedRoles: ['worker'],
          currentRole: authService.role,
          child: const CheckSlotAvailabilityAdminScreens(),
        );
      },
    ),

    GoRoute(
      path: '/admin/field-details/:field_id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final String currentFieldId = state.pathParameters['field_id']!;
        return ProtectedRoute(
          allowedRoles: ['worker'],
          currentRole: authService.role,
          child: FieldDetailsAdminScreens(fieldId: currentFieldId),
        );
      },
    ),

    GoRoute(
      path: '/admin/edit-field-details/:field_id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final String currentFieldId = state.pathParameters['field_id']!;
        return ProtectedRoute(
          allowedRoles: ['worker'],
          currentRole: authService.role,
          child: FormEditFieldAdminScreens(fieldId: currentFieldId),
        );
      },
    ),

    GoRoute(
      path: '/admin/close-field/:field_id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final String currentFieldId = state.pathParameters['field_id']!;
        return ProtectedRoute(
          allowedRoles: ['worker'],
          currentRole: authService.role,
          child: FormCloseFieldAdminScreens(fieldId: currentFieldId),
        );
      },
    ),

    GoRoute(
      path: '/admin/list-closed-booking',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        return ProtectedRoute(
          allowedRoles: ['worker'],
          currentRole: authService.role,
          child: ListClosedBookingAdminScreens(),
        );
      },
    ),

    GoRoute(
      path: '/admin/form-input-booking',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return ProtectedRoute(
          allowedRoles: ['worker'],
          currentRole: authService.role,
          child: FormInputBooking(
            nameField: data['nameField'] as String,
            fieldId: data['fieldId'] as int,
            selectedDate: data['selectedDate'],
            hours: data['hours'] as String,
            duration: data['duration'] as int,
            fieldPrice: data['fieldPrice'] as int,
          ),
        );
      },
    ),

    GoRoute(
      path: '/admin/payment-details',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        final bookingId = data['bookingId'] as int?;
        final paymentAmount = data['paymentAmount'] as int?;

        if (bookingId == null || paymentAmount == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
              backgroundColor: Colors.white,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Data booking tidak lengkap'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            ),
          );
        }

        return ProtectedRoute(
          allowedRoles: ['worker'],
          currentRole: authService.role,
          child: PaymentDetailsPageAdminScreens(
            nameField: data['nameField'] as String,
            nameTenant: data['nameTenant'] as String,
            selectedDate: data['selectedDate'],
            hours: data['hours'],
            duration: data['duration'] as int,
            totalPrice: data['totalPrice'] as int,
            downPaymentPrice: data['downPaymentPrice'] as int,
            statusEarly: data['statusEarly'],
            bookingId: bookingId,
            paymentAmount: paymentAmount,
          ),
        );
      },
    ),

    GoRoute(
      path: '/admin/payment-status',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return SuccessfulPaymentAdminScreen(
          isSuccess: extra['isSuccess'] ?? true,
          message: extra['message'] ?? 'Pembayaran berhasil dikonfirmasi.',
        );
      },
    ),

    GoRoute(
      path: '/admin/booking-detail/:booking_id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final String currentBookingId = state.pathParameters['booking_id']!;
        return ProtectedRoute(
          allowedRoles: ['worker'],
          currentRole: authService.role,
          child: BookingDetailsAdminScreen(bookingId: currentBookingId),
        );
      },
    ),

    GoRoute(
      path: '/admin/change-booking/:booking_id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final String currentBookingId = state.pathParameters['booking_id']!;
        return ProtectedRoute(
          allowedRoles: ['worker'],
          currentRole: authService.role,
          child: ChangeBookingAdminScreens(bookingId: currentBookingId),
        );
      },
    ),

    GoRoute(
      path: '/admin/close-field/:field_id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final String currentFieldId = state.pathParameters['field_id']!;
        return ProtectedRoute(
          allowedRoles: ['worker'],
          currentRole: authService.role,
          child: FormCloseFieldAdminScreens(fieldId: currentFieldId),
        );
      },
    ),
  ],
);
