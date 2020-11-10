Tenant = Struct.new(:id)
Account = Struct.new(:id, :trm_enabled, :tenants, keyword_init: true)
Property = Struct.new(:id, :primary_account, keyword_init: true)
User = Struct.new(:id, :account, keyword_init: true)

def can_see_trm?(property, user)
  property.primary_account.trm_enabled && user.account.trm_enabled
end

def tenants(property, user)
  if can_see_trm?(property, user)
    user.account.tenants
  else
    property.primary_account.tenants
  end
end

def test_1
  property_account = Account.new(trm_enabled: false)
  p1 = Property.new(primary_account: property_account)

  user_account = Account.new(trm_enabled: false)
  u1 = User.new(id: 1, account: user_account)

  raise unless can_see_trm?(p1, u1) == false
end

def test_2
  property_account = Account.new(trm_enabled: true)
  p1 = Property.new(primary_account: property_account)

  user_account = Account.new(trm_enabled: true)
  u1 = User.new(id: 1, account: user_account)

  raise unless can_see_trm?(p1, u1) == true
end

def associative_array(key, domain)
  [key].product(domain)
end

def attributes_hash(*values)
  return values.first.map { |v| [v].to_h } if values.count == 1

  values.first.product(*values.drop(1)).map(&:to_h)
end

def typed_values(struct_klass, attribute_domains)
  attribute_arrays = attribute_domains.to_a.map { |a| associative_array(*a) }
  struct_attributes = attributes_hash(*attribute_arrays)

  struct_attributes.map { |a| struct_klass.new(a) }
end

def test_exhausitve
  bool_domain = [true, false]

  tenant_id_domain = [1, 2, 3]
  account_id_domain = [1, 2, 3]
  property_id_domain = [1,2, 3]
  user_id_domain = [1, 2, 3]

  tenant_domain = typed_values(Tenant, { id: tenant_id_domain })
  account_domain = typed_values(Account, { id: account_id_domain, trm_enabled: bool_domain, tenants: tenant_domain })
  
  property_domain = typed_values(Property, { id: property_id_domain, primary_account: account_domain })
  user_domain = typed_values(User, { id: user_id_domain, account: account_domain })

  puts account_domain
  puts
  puts property_domain
  puts
  puts user_domain

  failure = false
  property_domain.product(user_domain).each_with_index do |(p, u), i|

    if can_see_trm?(p, u)
    puts "===== Frame(#{i}) ====="
    puts p
    puts u
    puts "can_see_trm?: #{can_see_trm?(p, u)}"
  end
end

def test_category_partition
end

test_1
test_exhaustive

puts "All tests passed."