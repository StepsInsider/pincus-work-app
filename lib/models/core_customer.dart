class CoreCustomer {
  const CoreCustomer({required this.id, required this.companyId, required this.name, this.contactPerson, this.phone, this.email, this.address, this.notes});
  final String id, companyId, name;
  final String? contactPerson, phone, email, address, notes;
  factory CoreCustomer.fromMap(Map<String,dynamic> m) => CoreCustomer(id:m['id'].toString(), companyId:m['company_id'].toString(), name:(m['name'] ?? '').toString(), contactPerson:m['contact_person']?.toString(), phone:m['phone']?.toString(), email:m['email']?.toString(), address:m['address']?.toString(), notes:m['notes']?.toString());
  Map<String,dynamic> toMap()=>{'company_id':companyId,'name':name,if(contactPerson!=null)'contact_person':contactPerson,if(phone!=null)'phone':phone,if(email!=null)'email':email,if(address!=null)'address':address,if(notes!=null)'notes':notes};
}
