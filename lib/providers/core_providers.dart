import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/core_baustelle.dart';
import '../models/core_customer.dart';
import '../models/core_employee.dart';
import '../models/core_order.dart';
import '../models/core_time_entry.dart';
import '../repositories/core_repositories.dart';

final coreSupabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final coreCustomerRepositoryProvider = Provider<CoreCustomerRepository>((ref) {
  return CoreCustomerRepository(ref.watch(coreSupabaseClientProvider));
});

final coreBaustelleRepositoryProvider = Provider<CoreBaustelleRepository>((ref) {
  return CoreBaustelleRepository(ref.watch(coreSupabaseClientProvider));
});

final coreEmployeeRepositoryProvider = Provider<CoreEmployeeRepository>((ref) {
  return CoreEmployeeRepository(ref.watch(coreSupabaseClientProvider));
});

final coreOrderRepositoryProvider = Provider<CoreOrderRepository>((ref) {
  return CoreOrderRepository(ref.watch(coreSupabaseClientProvider));
});

final coreTimeEntryRepositoryProvider = Provider<CoreTimeEntryRepository>((ref) {
  return CoreTimeEntryRepository(ref.watch(coreSupabaseClientProvider));
});

final coreCustomersProvider = FutureProvider<List<CoreCustomer>>((ref) {
  return ref.watch(coreCustomerRepositoryProvider).list();
});

final coreBaustellenProvider = FutureProvider<List<CoreBaustelle>>((ref) {
  return ref.watch(coreBaustelleRepositoryProvider).list();
});

final coreEmployeesProvider = FutureProvider<List<CoreEmployee>>((ref) {
  return ref.watch(coreEmployeeRepositoryProvider).list();
});

final coreOrdersProvider = FutureProvider<List<CoreOrder>>((ref) {
  return ref.watch(coreOrderRepositoryProvider).list();
});

final coreOrdersByCustomerProvider = FutureProvider.family<List<CoreOrder>, String>((ref, customerId) {
  return ref.watch(coreOrderRepositoryProvider).list(customerId: customerId);
});

final coreOrdersByBaustelleProvider = FutureProvider.family<List<CoreOrder>, String>((ref, siteId) {
  return ref.watch(coreOrderRepositoryProvider).list(siteId: siteId);
});

final coreTimeEntriesProvider = FutureProvider<List<CoreTimeEntry>>((ref) {
  return ref.watch(coreTimeEntryRepositoryProvider).list();
});

final coreTimeEntriesByEmployeeProvider = FutureProvider.family<List<CoreTimeEntry>, String>((ref, employeeId) {
  return ref.watch(coreTimeEntryRepositoryProvider).list(employeeId: employeeId);
});

final coreTimeEntriesByBaustelleProvider = FutureProvider.family<List<CoreTimeEntry>, String>((ref, siteId) {
  return ref.watch(coreTimeEntryRepositoryProvider).list(siteId: siteId);
});
