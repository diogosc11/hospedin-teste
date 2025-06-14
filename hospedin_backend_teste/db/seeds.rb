Payment.destroy_all
Client.destroy_all
Product.destroy_all

clients_data = [
  {
    name: "João Silva",
    email: "joao.silva@email.com",
    phone: "(11) 99999-1111",
    company: "Tech Solutions Ltda",
    client_type: "individual",
    document: "11144477735",
    document_type: "CPF",
    gender: "male",
    birthdate: "1985-03-15",
    address: {
      country: "BR",
      state: "SP",
      city: "São Paulo",
      zip_code: "01310100",
      line_1: "123, Avenida Paulista, Bela Vista",
      line_2: "Conjunto 45"
    },
    phones: {
      mobile_phone: {
        country_code: "55",
        area_code: "11",
        number: "999991111"
      }
    }
  },
  {
    name: "Maria Santos",
    email: "maria.santos@email.com",
    phone: "(11) 99999-2222",
    company: "Digital Marketing Co",
    client_type: "company",
    document: "11222333000181",
    document_type: "CNPJ",
    address: {
      country: "BR",
      state: "SP",
      city: "São Paulo",
      zip_code: "04038001",
      line_1: "456, Rua Augusta, Consolação",
      line_2: "Sala 1001"
    },
    phones: {
      mobile_phone: {
        country_code: "55",
        area_code: "11",
        number: "999992222"
      }
    }
  },
  {
    name: "Pedro Oliveira",
    email: "pedro.oliveira@email.com",
    phone: "(11) 99999-3333",
    company: "E-commerce Brasil",
    client_type: "individual",
    document: "22255588896",
    document_type: "CPF",
    gender: "male",
    birthdate: "1990-07-22",
    migrating_to_pagarme: true,
    address: {
      country: "BR",
      state: "RJ",
      city: "Rio de Janeiro",
      zip_code: "22071900",
      line_1: "789, Avenida Atlântica, Copacabana",
      line_2: "Apartamento 2101"
    },
    phones: {
      mobile_phone: {
        country_code: "55",
        area_code: "21",
        number: "999993333"
      }
    }
  }
]

products_data = [
  {
    name: "Sistema Hoteleiro - PMS",
    description: "Tenha total controle das suas reservas, acomodações e hóspedes com o Sistema Hoteleiro Hospedin",
    price: 99.90,
    active: true
  },
  {
    name: "Motor de Reservas",
    description: "Receba reservas direto do site da sua pousada ou hotel sem ter que pagar comissões extras para as OTAs",
    price: 89.90,
    active: true
  },
  {
    name: "Gestor de Canais",
    description: "Gerencie todas as reservas do Booking, Expedia, Decolar e vários outros canais no Hospedin",
    price: 79.90,
    active: true
  }
]

clients = clients_data.map do |data|
  Client.create!(data).tap { |c| puts "Cliente criado: #{c.name}" }
end

products = products_data.map do |data|
  Product.create!(data).tap { |p| puts "Produto criado: #{p.name}" }
end

payments_data = [
  {
    client: clients[0],
    product: products[0],
    payment_type: 'one_time',
    status: 'confirmed',
    paid_at: 2.days.ago
  },
  {
    client: clients[1],
    product: products[1],
    payment_type: 'recurring',
    status: 'confirmed',
    paid_at: 1.day.ago
  },
  {
    client: clients[0],
    product: products[2],
    payment_type: 'one_time',
    status: 'failed',
    paid_at: nil
  },
  {
    client: clients[2],
    product: products[1],
    payment_type: 'recurring',
    status: 'pending',
    paid_at: nil
  },
  {
    client: clients[1],
    product: products[2],
    payment_type: 'one_time',
    status: 'confirmed',
    paid_at: 3.hours.ago
  }
]

payments_data.each_with_index do |payment_data, index|
  begin
    payment = Payment.create!(
      client: payment_data[:client],
      product: payment_data[:product],
      amount: payment_data[:product].price,
      status: payment_data[:status],
      payment_type: payment_data[:payment_type],
      paid_at: payment_data[:paid_at],
      pagar_me_order_id: "or_#{SecureRandom.hex(8)}",
      processed_at: payment_data[:status] != 'pendente' ? Time.current : nil
    )
    puts "Pagamento criado: #{payment.client.name}"
  rescue => e
    puts "Erro ao criar pagamento #{index + 1}: #{e.message}"
  end
end
