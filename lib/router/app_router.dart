import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/components/custom_bottom_nav_page.dart';
import 'package:pbl_app_joglo66/router/protected_route.dart';
import 'package:pbl_app_joglo66/screens/admin/attribute_booking/add_attribute_booking_admin_screen.dart';
import 'package:pbl_app_joglo66/screens/admin/attribute_booking/confirmation_attribute_booking_admin_screen.dart';
import 'package:pbl_app_joglo66/screens/admin/attribute_booking/history_attribute_booking_admin_screen.dart';
import 'package:pbl_app_joglo66/screens/admin/attribute_field/add_attribute_admin_screen.dart';
import 'package:pbl_app_joglo66/screens/admin/attribute_field/list_attribute_admin_screen.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_field/booking_details_admin_screen.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_field/change_booking_admin_screen.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_field/check_slot_availability_admin_screen.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_field/form_input_booking_admin_screen.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_field/list_booking_admin_screen.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_field/list_closed_booking_admin_screen.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_field/payment_details_admin_screen.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_field/successful_payment_admin_screen.dart';
import 'package:pbl_app_joglo66/screens/admin/dashboard_admin_screen.dart';
import 'package:pbl_app_joglo66/screens/admin/expense_field/add_expense_admin_screen.dart';
import 'package:pbl_app_joglo66/screens/admin/expense_field/detail_expense_admin_screen.dart';
import 'package:pbl_app_joglo66/screens/admin/expense_field/list_expense_admin_screen.dart';
import 'package:pbl_app_joglo66/screens/admin/field/field_details_admin_screen.dart';
import 'package:pbl_app_joglo66/screens/admin/field/form_close_field_admin_screen.dart';
import 'package:pbl_app_joglo66/screens/admin/field/form_edit_field_admin_screen.dart';
import 'package:pbl_app_joglo66/screens/admin/field/list_field_admin_screen.dart';
import 'package:pbl_app_joglo66/screens/admin/profile_admin_screen.dart';
import 'package:pbl_app_joglo66/screens/auth/login_auth_screen.dart';
import 'package:pbl_app_joglo66/screens/monthly_report_screen.dart';
import 'package:pbl_app_joglo66/screens/owner/dashboard_owner_screen.dart';
import 'package:pbl_app_joglo66/screens/owner/employee/employee_list_owner_screen.dart';
import 'package:pbl_app_joglo66/screens/treasurer/dashboard_treasurer_screen.dart';
import 'package:pbl_app_joglo66/screens/treasurer/salary/salary_form_treasurer_screen.dart';
import 'package:pbl_app_joglo66/services/auth_service.dart';

final authService = AuthService();

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

const List<String> _adminWorkerRoles = ['worker'];
const List<String> _allManagementRoles = ['owner', 'treasurer', 'worker'];

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  refreshListenable: authService,
  redirect: (context, state) {
    final bool loggedIn = authService.isLoggedIn;
    final String currentRole = authService.role;
    final String location = state.uri.toString();
    final bool isGoingToAuth = location == '/login';

    if (!loggedIn) {
      return isGoingToAuth ? null : '/login';
    }

    if (loggedIn && isGoingToAuth) {
      if (currentRole == 'owner') return '/owner/dashboard';
      if (currentRole == 'treasurer') return '/treasurer/dashboard';
      return '/admin/dashboard';
    }

    final bool isGoingToAdmin = location.startsWith('/admin');
    final bool isGoingToOwner = location.startsWith('/owner');
    final bool isGoingToTreasurer = location.startsWith('/treasurer');
    final bool isGlobalRoute = location.startsWith('/laporan-bulanan');

    if (isGlobalRoute) {
      return null;
    }

    if (currentRole == 'treasurer' && !isGoingToTreasurer) {
      return '/treasurer/dashboard';
    }

    if (currentRole == 'owner' && !isGoingToOwner) {
      return '/owner/dashboard';
    }

    if ((currentRole == 'admin' || currentRole == 'worker') && !isGoingToAdmin) {
      return '/admin/dashboard';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoginAuthScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return CustomBottomNavPage(currentRole: authService.role, child: child);
      },
      routes: [
        GoRoute(
          path: '/admin/dashboard',
          builder: (context, state) => ProtectedRoute(
            allowedRoles: _adminWorkerRoles,
            currentRole: authService.role,
            child: const DashboardAdminScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/list-field',
          builder: (context, state) => ProtectedRoute(
            allowedRoles: _adminWorkerRoles,
            currentRole: authService.role,
            child: const ListFieldAdminScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/list-booking',
          builder: (context, state) => ProtectedRoute(
            allowedRoles: _adminWorkerRoles, // FIXED ROLE
            currentRole: authService.role,
            child: const ListBookingAdminScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/profile',
          builder: (context, state) => ProtectedRoute(
            allowedRoles: _allManagementRoles,
            currentRole: authService.role,
            child: const ProfileAdminScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/list-attribute',
          builder: (context, state) => ProtectedRoute(
            allowedRoles: _adminWorkerRoles,
            currentRole: authService.role,
            child: const ListAttributeAdminScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/add-attribute',
          builder: (context, state) => ProtectedRoute(
            allowedRoles: _adminWorkerRoles, // FIXED ROLE
            currentRole: authService.role,
            child: const AddAttributeAdminScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/rent-attribute',
          builder: (context, state) => ProtectedRoute(
            allowedRoles: _adminWorkerRoles, // FIXED ROLE
            currentRole: authService.role,
            child: const AddAttributeBookingAdminScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/confirmation-rent-attribute',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return ProtectedRoute(
              allowedRoles: _adminWorkerRoles, // FIXED ROLE
              currentRole: authService.role,
              child: ConfirmationAttributeBookingAdminScreen(
                fkBookingId: extra['fkBookingId'] as int? ?? 0,
                items: (extra['items'] as List<dynamic>?)
                        ?.map((e) => e as Map<String, dynamic>)
                        .toList() ?? [],
                customerName: extra['customerName'] as String? ?? '',
                customerPhone: extra['customerPhone'] as String? ?? '',
                durationHours: extra['durationHours'] as int? ?? 1,
                transactionDate: extra['transactionDate'] as String? ?? '',
                totalPrice: extra['totalPrice'] as int? ?? 0,
              ),
            );
          },
        ),
        GoRoute(
          path: '/admin/history-rent-attribute',
          builder: (context, state) => ProtectedRoute(
            allowedRoles: _adminWorkerRoles,
            currentRole: authService.role,
            child: const HistoryAttributeBookingAdminScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/list-expense-field',
          builder: (context, state) => ProtectedRoute(
            allowedRoles: _adminWorkerRoles, // FIXED ROLE
            currentRole: authService.role,
            child: const ListExpenseAdminScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/add-expense-field',
          builder: (context, state) => ProtectedRoute(
            allowedRoles: _adminWorkerRoles, // FIXED ROLE
            currentRole: authService.role,
            child: const AddExpenseAdminScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/detail-expense-field',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return ProtectedRoute(
              allowedRoles: _adminWorkerRoles, // FIXED ROLE
              currentRole: authService.role,
              child: DetailExpenseAdminScreen(expenseData: extra),
            );
          },
        ),
        GoRoute(
          path: '/owner/dashboard',
          builder: (context, state) => ProtectedRoute(
            allowedRoles: const ['owner'],
            currentRole: authService.role,
            child: const DashboardOwnerScreen(),
          ),
        ),
        GoRoute(
          path: '/owner/karyawan',
          builder: (context, state) => ProtectedRoute(
            allowedRoles: const ['owner'],
            currentRole: authService.role,
            child: const EmployeeListOwnerScreen(),
          ),
        ),
        GoRoute(
          path: '/treasurer/dashboard',
          builder: (context, state) => ProtectedRoute(
            allowedRoles: const ['treasurer'],
            currentRole: authService.role,
            child: const DashboardTreasurerScreen(),
          ),
        ),
        GoRoute(
          path: '/treasurer/gaji',
          builder: (context, state) => ProtectedRoute(
            allowedRoles: const ['treasurer'],
            currentRole: authService.role,
            child: const SalaryFormTreasurerScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/laporan-bulanan',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => ProtectedRoute(
        allowedRoles: _allManagementRoles, // FIXED ROLE: Menjamin Admin & Worker juga bisa melihat laporan bulanan
        currentRole: authService.role,
        child: const MonthlyReportScreen(),
      ),
    ),
    GoRoute(
      path: '/admin/check-availability',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => ProtectedRoute(
        allowedRoles: _adminWorkerRoles, // FIXED ROLE
        currentRole: authService.role,
        child: const CheckSlotAvailabilityAdminScreen(),
      ),
    ),
    GoRoute(
      path: '/admin/field-details/:field_id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final String currentFieldId = state.pathParameters['field_id']!;
        return ProtectedRoute(
          allowedRoles: _adminWorkerRoles, // FIXED ROLE
          currentRole: authService.role,
          child: FieldDetailsAdminScreen(fieldId: currentFieldId),
        );
      },
    ),
    GoRoute(
      path: '/admin/edit-field-details/:field_id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final String currentFieldId = state.pathParameters['field_id']!;
        return ProtectedRoute(
          allowedRoles: _adminWorkerRoles, // FIXED ROLE
          currentRole: authService.role,
          child: FormEditFieldAdminScreen(fieldId: currentFieldId),
        );
      },
    ),
    GoRoute(
      path: '/admin/close-field/:field_id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final String currentFieldId = state.pathParameters['field_id']!;
        return ProtectedRoute(
          allowedRoles: _adminWorkerRoles, // FIXED ROLE
          currentRole: authService.role,
          child: FormCloseFieldAdminScreen(fieldId: currentFieldId),
        );
      },
    ),
    GoRoute(
      path: '/admin/list-closed-booking',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => ProtectedRoute(
        allowedRoles: _adminWorkerRoles, // FIXED ROLE
        currentRole: authService.role,
        child: const ListClosedBookingAdminScreen(),
      ),
    ),
    GoRoute(
      path: '/admin/form-input-booking',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return ProtectedRoute(
          allowedRoles: _adminWorkerRoles, // FIXED ROLE
          currentRole: authService.role,
          child: FormInputBookingAdminScreen(
            nameField: data['nameField'] as String? ?? '-',
            fieldId: data['fieldId'] as int? ?? 0,
            selectedDate: data['selectedDate'],
            hours: data['hours'] as String? ?? '',
            duration: data['duration'] as int? ?? 1,
            fieldPrice: data['fieldPrice'] as int? ?? 0,
          ),
        );
      },
    ),
    GoRoute(
      path: '/admin/payment-details',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        final bookingId = data['bookingId'] as int?;
        final paymentAmount = data['paymentAmount'] as int?;

        if (bookingId == null || paymentAmount == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Data Eror'), backgroundColor: Colors.white),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 54, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Struktur payload data booking tidak valid/lengkap.'),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Kembali')),
                ],
              ),
            ),
          );
        }

        return ProtectedRoute(
          allowedRoles: _adminWorkerRoles, // FIXED ROLE
          currentRole: authService.role,
          child: PaymentDetailsAdminScreen(
            nameField: data['nameField'] as String? ?? '-',
            nameTenant: data['nameTenant'] as String? ?? '-',
            selectedDate: data['selectedDate'],
            hours: data['hours'] ?? '',
            duration: data['duration'] as int? ?? 1,
            totalPrice: data['totalPrice'] as int? ?? 0,
            downPaymentPrice: data['downPaymentPrice'] as int? ?? 0,
            statusEarly: data['statusEarly'] ?? 'pending',
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
        return ProtectedRoute(
          allowedRoles: _adminWorkerRoles,
          currentRole: authService.role,
          child: SuccessfulPaymentAdminScreen(
            isSuccess: extra['isSuccess'] as bool? ?? true,
            message: extra['message'] as String? ?? 'Pembayaran berhasil dikonfirmasi.',
          ),
        );
      },
    ),
    GoRoute(
      path: '/admin/booking-detail/:booking_id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final String currentBookingId = state.pathParameters['booking_id']!;
        return ProtectedRoute(
          allowedRoles: _adminWorkerRoles, // FIXED ROLE
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
          allowedRoles: _adminWorkerRoles, // FIXED ROLE
          currentRole: authService.role,
          child: ChangeBookingAdminScreen(bookingId: currentBookingId),
        );
      },
    ),
  ],
);
