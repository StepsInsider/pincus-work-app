import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/core_customer.dart';
import '../models/core_baustelle.dart';
import '../models/core_employee.dart';
import '../models/core_location.dart';
import '../models/core_order.dart';
import '../models/core_time_entry.dart';

class CoreCustomerRepository {
  CoreCustomerRepository(this.client);
  final SupabaseClient client;

  Future<List<CoreCustomer>> list() async {
    final rows = await client.from('kunden').select().order('name');
    return (rows as List)
        .map((r) => CoreCustomer.fromMap(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<String?> currentCompanyId() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return null;
    final row = await client
        .from('profiles')
        .select('company_id')
        .eq('id', userId)
        .maybeSingle();
    return row?['company_id']?.toString();
  }

  Future<CoreCustomer> get(String id) async => CoreCustomer.fromMap(
        Map<String, dynamic>.from(
          await client.from('kunden').select().eq('id', id).single(),
        ),
      );

  Future<CoreCustomer> create(CoreCustomer value) async => CoreCustomer.fromMap(
        Map<String, dynamic>.from(
          await client.from('kunden').insert(value.toMap()).select().single(),
        ),
      );

  Future<CoreCustomer> update(String id, Map<String, dynamic> changes) async =>
      CoreCustomer.fromMap(
        Map<String, dynamic>.from(
          await client.from('kunden').update(changes).eq('id', id).select().single(),
        ),
      );

  Future<void> delete(String id) async {
    await client.from('kunden').delete().eq('id', id);
  }
}

class CoreLocationRepository {
  CoreLocationRepository(this.client);
  final SupabaseClient client;

  Future<List<CoreLocation>> list({String? customerId}) async {
    var query = client.from('standorte').select().eq('aktiv', true);
    if (customerId != null) query = query.eq('kunden_id', customerId);
    final rows = await query.order('name');
    return (rows as List)
        .map((r) => CoreLocation.fromMap(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<CoreLocation> get(String id) async => CoreLocation.fromMap(
        Map<String, dynamic>.from(
          await client.from('standorte').select().eq('id', id).single(),
        ),
      );

  Future<CoreLocation> create(CoreLocation value) async => CoreLocation.fromMap(
        Map<String, dynamic>.from(
          await client.from('standorte').insert(value.toMap()).select().single(),
        ),
      );

  Future<CoreLocation> update(String id, Map<String, dynamic> changes) async =>
      CoreLocation.fromMap(
        Map<String, dynamic>.from(
          await client.from('standorte').update(changes).eq('id', id).select().single(),
        ),
      );

  Future<void> delete(String id) async {
    await client.from('standorte').delete().eq('id', id);
  }
}

class CoreBaustelleRepository {
  CoreBaustelleRepository(this.client);
  final SupabaseClient client;
  Future<List<CoreBaustelle>> list() async { final rows=await client.from('baustellen').select().order('created_at',ascending:false); return (rows as List).map((r)=>CoreBaustelle.fromMap(Map<String,dynamic>.from(r))).toList(); }
  Future<CoreBaustelle> get(String id) async=>CoreBaustelle.fromMap(Map<String,dynamic>.from(await client.from('baustellen').select().eq('id',id).single()));
  Future<CoreBaustelle> create(CoreBaustelle v) async=>CoreBaustelle.fromMap(Map<String,dynamic>.from(await client.from('baustellen').insert(v.toMap()).select().single()));
  Future<CoreBaustelle> update(String id,Map<String,dynamic> c) async=>CoreBaustelle.fromMap(Map<String,dynamic>.from(await client.from('baustellen').update(c).eq('id',id).select().single()));
  Future<void> delete(String id) async{await client.from('baustellen').delete().eq('id',id);}
}

class CoreEmployeeRepository {
  CoreEmployeeRepository(this.client);
  final SupabaseClient client;
  Future<List<CoreEmployee>> list() async { final rows=await client.from('profiles').select().order('last_name'); return (rows as List).map((r)=>CoreEmployee.fromMap(Map<String,dynamic>.from(r))).toList(); }
  Future<CoreEmployee> get(String id) async=>CoreEmployee.fromMap(Map<String,dynamic>.from(await client.from('profiles').select().eq('id',id).single()));
}

class CoreOrderRepository {
  CoreOrderRepository(this.client);
  final SupabaseClient client;
  Future<List<CoreOrder>> list({String? customerId,String? siteId}) async { var q=client.from('auftraege').select(); if(customerId!=null) q=q.eq('kunden_id',customerId); if(siteId!=null) q=q.eq('baustelle_id',siteId); final rows=await q.order('created_at',ascending:false); return (rows as List).map((r)=>CoreOrder.fromMap(Map<String,dynamic>.from(r))).toList(); }
  Future<CoreOrder> get(String id) async=>CoreOrder.fromMap(Map<String,dynamic>.from(await client.from('auftraege').select().eq('id',id).single()));
  Future<CoreOrder> create(CoreOrder v) async=>CoreOrder.fromMap(Map<String,dynamic>.from(await client.from('auftraege').insert(v.toMap()).select().single()));
  Future<CoreOrder> update(String id,Map<String,dynamic> c) async=>CoreOrder.fromMap(Map<String,dynamic>.from(await client.from('auftraege').update(c).eq('id',id).select().single()));
  Future<void> delete(String id) async{await client.from('auftraege').delete().eq('id',id);}
}

class CoreTimeEntryRepository {
  CoreTimeEntryRepository(this.client);
  final SupabaseClient client;
  Future<List<CoreTimeEntry>> list({String? employeeId,String? siteId}) async { var q=client.from('arbeitszeiten').select(); if(employeeId!=null) q=q.eq('mitarbeiter_id',employeeId); if(siteId!=null) q=q.eq('baustelle_id',siteId); final rows=await q.order('arbeitsbeginn',ascending:false); return (rows as List).map((r)=>CoreTimeEntry.fromMap(Map<String,dynamic>.from(r))).toList(); }
  Future<CoreTimeEntry> get(String id) async=>CoreTimeEntry.fromMap(Map<String,dynamic>.from(await client.from('arbeitszeiten').select().eq('id',id).single()));
  Future<CoreTimeEntry> create(CoreTimeEntry v) async=>CoreTimeEntry.fromMap(Map<String,dynamic>.from(await client.from('arbeitszeiten').insert(v.toMap()).select().single()));
  Future<CoreTimeEntry> update(String id,Map<String,dynamic> c) async=>CoreTimeEntry.fromMap(Map<String,dynamic>.from(await client.from('arbeitszeiten').update(c).eq('id',id).select().single()));
  Future<void> delete(String id) async{await client.from('arbeitszeiten').delete().eq('id',id);}
}
