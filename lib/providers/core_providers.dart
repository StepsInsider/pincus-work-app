import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/core_baustelle.dart';
import '../models/core_customer.dart';
import '../models/core_employee.dart';
import '../models/core_location.dart';
import '../models/core_order.dart';
import '../models/core_time_entry.dart';
import '../repositories/core_repositories.dart';

final coreSupabaseClientProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

final coreCustomerRepositoryProvider = Provider<CoreCustomerRepository>((ref) => CoreCustomerRepository(ref.watch(coreSupabaseClientProvider)));
final coreLocationRepositoryProvider = Provider<CoreLocationRepository>((ref) => CoreLocationRepository(ref.watch(coreSupabaseClientProvider)));
final coreBaustelleRepositoryProvider = Provider<CoreBaustelleRepository>((ref) => CoreBaustelleRepository(ref.watch(coreSupabaseClientProvider)));
final coreEmployeeRepositoryProvider = Provider<CoreEmployeeRepository>((ref) => CoreEmployeeRepository(ref.watch(coreSupabaseClientProvider)));
final coreOrderRepositoryProvider = Provider<CoreOrderRepository>((ref) => CoreOrderRepository(ref.watch(coreSupabaseClientProvider)));
final coreTimeEntryRepositoryProvider = Provider<CoreTimeEntryRepository>((ref) => CoreTimeEntryRepository(ref.watch(coreSupabaseClientProvider)));

final coreCustomersProvider = FutureProvider<List<CoreCustomer>>((ref) => ref.watch(coreCustomerRepositoryProvider).list());
final coreLocationsProvider = FutureProvider<List<CoreLocation>>((ref) => ref.watch(coreLocationRepositoryProvider).list());
final coreLocationsByCustomerProvider = FutureProvider.family<List<CoreLocation>, String>((ref, customerId) => ref.watch(coreLocationRepositoryProvider).list(customerId: customerId));
final coreBaustellenProvider = FutureProvider<List<CoreBaustelle>>((ref) => ref.watch(coreBaustelleRepositoryProvider).list());
final coreEmployeesProvider = FutureProvider<List<CoreEmployee>>((ref) => ref.watch(coreEmployeeRepositoryProvider).list());
final coreOrdersProvider = FutureProvider<List<CoreOrder>>((ref) => ref.watch(coreOrderRepositoryProvider).list());
final coreOrdersByCustomerProvider = FutureProvider.family<List<CoreOrder>, String>((ref, customerId) => ref.watch(coreOrderRepositoryProvider).list(customerId: customerId));
final coreOrdersByBaustelleProvider = FutureProvider.family<List<CoreOrder>, String>((ref, siteId) => ref.watch(coreOrderRepositoryProvider).list(siteId: siteId));
final coreTimeEntriesProvider = FutureProvider<List<CoreTimeEntry>>((ref) => ref.watch(coreTimeEntryRepositoryProvider).list());
final coreTimeEntriesByEmployeeProvider = FutureProvider.family<List<CoreTimeEntry>, String>((ref, employeeId) => ref.watch(coreTimeEntryRepositoryProvider).list(employeeId: employeeId));
final coreTimeEntriesByBaustelleProvider = FutureProvider.family<List<CoreTimeEntry>, String>((ref, siteId) => ref.watch(coreTimeEntryRepositoryProvider).list(siteId: siteId));
