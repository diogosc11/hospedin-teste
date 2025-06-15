require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe 'Associações' do
    it { should belong_to(:client) }
    it { should belong_to(:product) }
  end

  describe 'Validações' do
    subject { build(:payment) }
    
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).is_greater_than(0) }
  end

  describe 'Factory' do
    it 'tem uma factory válida' do
      payment = build(:payment)
      expect(payment).to be_valid
    end

    it 'deve criar um payment' do
      payment = create(:payment)
      expect(payment).to be_persisted
    end
  end

  describe 'Instâncias' do
    describe '#formatted_amount' do
      it 'formatação de moeda válida' do
        payment = create(:payment, amount: 99.90)
        expect(payment.formatted_amount).to include('99,90')
      end
    end

    describe '#status_label' do
      it 'retorna a label correta para pending' do
        payment = create(:payment, status: 'pending')
        expect(payment.status_label).to eq('Pendente')
      end
    end

    describe '#processed?' do
      it 'retorna falso quando processed_at é nil' do
        payment = create(:payment, processed_at: nil)
        expect(payment.processed?).to be false
      end
    end
  end

  describe 'Lógica do negócio' do
    it 'aceita valores positivos' do
      payment = build(:payment, amount: 50.00)
      expect(payment).to be_valid
    end

    it 'rejeita valor zero' do
      payment = build(:payment, amount: 0)
      expect(payment).not_to be_valid
    end
  end
end