class Client < ApplicationRecord
  has_many :payments

  enum :client_type, {
    individual: 'individual',
    company: 'company'
  }

  enum :document_type, {
    CPF: 'CPF',
    CNPJ: 'CNPJ',
    PASSPORT: 'PASSPORT'
  }

  enum :gender, {
    male: 'male',
    female: 'female'
  }

  validates :name, presence: { message: "Nome é obrigatório" }
  validates :email, presence: { message: "Email é obrigatório" }
  validates :email, format: { 
    with: URI::MailTo::EMAIL_REGEXP, 
    message: "Email deve ter um formato válido"
  }
  validates :email, uniqueness: { 
    case_sensitive: false, 
    message: "Este email já está sendo usado" 
  }

  scope :individuals, -> { where(client_type: 'individual') }
  scope :companies, -> { where(client_type: 'company') }
  scope :by_document_type, ->(type) { where(document_type: type) }

  validates :client_type, presence: true, if: :document_present?
  validates :document_type, presence: true, if: :document_present?
  validates :document, presence: true, uniqueness: true, if: :document_present?

  validates :document, length: { maximum: 16 }, if: :cpf_or_cnpj?
  validates :document, length: { maximum: 50 }, if: :passport?

  validate :validate_document_format, if: :document_present?
  validate :validate_client_type_document_compatibility, if: -> { client_type.present? && document_type.present? }

  before_validation :normalize_document
  before_validation :normalize_address
  before_validation :normalize_phones
  before_save :normalize_email
  before_save :normalize_name

  def individual?
    client_type == 'individual'
  end

  def company?
    client_type == 'company'
  end

  def formatted_document
    return nil unless document.present?
    
    case document_type
    when 'CPF'
      format_cpf(document)
    when 'CNPJ'
      format_cnpj(document)
    else
      document
    end
  end

  def full_address
    return nil unless address.present?
    
    addr = address.with_indifferent_access
    parts = []
    parts << addr[:line_1] if addr[:line_1].present?
    parts << addr[:line_2] if addr[:line_2].present?
    parts << addr[:city] if addr[:city].present?
    parts << addr[:state] if addr[:state].present?
    parts << addr[:zip_code] if addr[:zip_code].present?
    parts << addr[:country] if addr[:country].present?
    
    parts.join(', ')
  end

  def formatted_zip_code
    return nil unless address&.dig('zip_code').present?
    
    zip = address['zip_code']
    zip.length == 8 ? "#{zip[0..4]}-#{zip[5..7]}" : zip
  end

  def formatted_mobile_phone
    return nil unless phones&.dig('mobile_phone').present?
    
    mobile = phones['mobile_phone'].with_indifferent_access
    return nil unless mobile[:number].present?
    
    country = mobile[:country_code] || '55'
    area = mobile[:area_code] || ''
    number = mobile[:number]
    
    "+#{country} (#{area}) #{format_phone_number(number)}"
  end

  def age
    return nil unless birthdate.present?
    
    ((Date.current - birthdate) / 365.25).floor
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
  
  def normalize_name
    self.name = name.strip.titleize if name.present?
  end

  def document_present?
    document.present?
  end

  def cpf_or_cnpj?
    document_present? && %w[CPF CNPJ].include?(document_type)
  end
  
  def passport?
    document_present? && document_type == 'PASSPORT'
  end

  def normalize_document
    return unless document.present?
    
    self.document = document.gsub(/\D/, '') if cpf_or_cnpj?
  end

  def normalize_address
    return unless address.present?
    
    if address['zip_code'].present?
      address['zip_code'] = address['zip_code'].gsub(/\D/, '')
    end
    
    if address['country'].present?
      address['country'] = address['country'].upcase
    end
  end

  def normalize_phones
    return unless phones.present? && phones['mobile_phone'].present?
    
    mobile = phones['mobile_phone']
    
    %w[country_code area_code number].each do |field|
      if mobile[field].present?
        mobile[field] = mobile[field].to_s.gsub(/\D/, '')
      end
    end
  end

  def validate_document_format
    return unless document.present? && document_type.present?
    
    case document_type
    when 'CPF'
      errors.add(:document, 'CPF inválido') unless valid_cpf?(document)
    when 'CNPJ'
      errors.add(:document, 'CNPJ inválido') unless valid_cnpj?(document)
    end
  end
  
  def validate_client_type_document_compatibility
    if individual? && document_type == 'CNPJ'
      errors.add(:document_type, 'Pessoa física não pode ter CNPJ')
    elsif company? && %w[CPF PASSPORT].include?(document_type)
      errors.add(:document_type, 'Pessoa jurídica deve ter CNPJ')
    end
  end
  
  def valid_cpf?(cpf)
    return false unless cpf.present?
    
    cpf = cpf.gsub(/\D/, '')
    return false unless cpf.length == 11
    return false if cpf.match?(/\A(\d)\1{10}\z/)
    
    true
  end
  
  def valid_cnpj?(cnpj)
    return false unless cnpj.present?
    
    cnpj = cnpj.gsub(/\D/, '')
    return false unless cnpj.length == 14
    return false if cnpj.match?(/\A(\d)\1{13}\z/)
    
    true
  end
  
  def format_cpf(cpf)
    return cpf unless cpf.present? && cpf.length == 11
    "#{cpf[0..2]}.#{cpf[3..5]}.#{cpf[6..8]}-#{cpf[9..10]}"
  end
  
  def format_cnpj(cnpj)
    return cnpj unless cnpj.present? && cnpj.length == 14
    "#{cnpj[0..1]}.#{cnpj[2..4]}.#{cnpj[5..7]}/#{cnpj[8..11]}-#{cnpj[12..13]}"
  end
  
  def format_phone_number(number)
    return number unless number.present?
    
    case number.length
    when 8
      "#{number[0..3]}-#{number[4..7]}"
    when 9
      "#{number[0..4]}-#{number[5..8]}"
    else
      number
    end
  end

  def em_migracao_para_pagarme?
    migrando_para_pagarme == true
  end
end