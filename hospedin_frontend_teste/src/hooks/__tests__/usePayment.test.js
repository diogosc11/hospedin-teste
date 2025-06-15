/* eslint-disable no-undef */
import { renderHook, act, waitFor } from '@testing-library/react';
import { usePayments } from '../usePayments.jsx';

describe('usePayments', () => {
  beforeEach(() => {
    fetch.mockClear();
  });

  describe('fetchPayments', () => {
    it('deve buscar pagamentos com sucesso', async () => {
      const mockPayments = {
        data: [
          {
            id: 1,
            product_name: 'Teste Product',
            amount: 'R$ 100,00',
            status_label: 'Confirmado',
            paid_at: '2025-01-01',
            client_name: 'João Silva',
            migrating_to_pagarme: false,
            payment_type: 'Pagamento Único'
          }
        ]
      };

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => mockPayments
      });

      const { result } = renderHook(() => usePayments());

      expect(result.current.loading).toBe(true);

      await act(async () => {
        await result.current.fetchPayments();
      });

      await waitFor(() => {
        expect(result.current.loading).toBe(false);
      });

      expect(result.current.payments).toHaveLength(1);
      expect(result.current.payments[0]).toEqual({
        id: 1,
        product: 'Teste Product',
        amount: 'R$ 100,00',
        status: 'Confirmado',
        date: '2025-01-01',
        client_id: 'João Silva',
        migrando: 'Não',
        type: 'Pagamento Único'
      });

      expect(fetch).toHaveBeenCalledWith('http://localhost:3000/api/v1/payments?');
    });

    it('deve buscar pagamentos com filtros', async () => {
      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ data: [] })
      });

      const { result } = renderHook(() => usePayments());

      await act(async () => {
        await result.current.fetchPayments({
          name: 'produto teste',
          status: 'confirmed',
          payment_type: 'one_time'
        });
      });

      expect(fetch).toHaveBeenCalledWith(
        'http://localhost:3000/api/v1/payments?name=produto+teste&status=confirmed&payment_type=one_time'
      );
    });

    it('deve lidar com erro na busca', async () => {
      const consoleSpy = jest.spyOn(console, 'error').mockImplementation(() => {});
      
      fetch.mockRejectedValueOnce(new Error('Network error'));

      const { result } = renderHook(() => usePayments());

      await act(async () => {
        await result.current.fetchPayments();
      });

      await waitFor(() => {
        expect(result.current.loading).toBe(false);
      });

      expect(consoleSpy).toHaveBeenCalledWith('Erro ao buscar pagamentos:', expect.any(Error));
      
      consoleSpy.mockRestore();
    });
  });

  describe('createPayment', () => {
    it('deve criar pagamento com sucesso', async () => {
      const mockResponse = {
        success: true,
        data: [{ payment_id: 123 }]
      };

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse
      });

      const { result } = renderHook(() => usePayments());

      const paymentData = {
        client_id: 1,
        product_ids: [1, 2],
        payment_type: 'one_time'
      };

      let response;
      await act(async () => {
        response = await result.current.createPayment(paymentData);
      });

      expect(response).toEqual(mockResponse);
      expect(fetch).toHaveBeenCalledWith('http://localhost:3000/api/v1/payments', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          client_id: 1,
          product_ids: [1, 2],
          payment_type: 'one_time',
        }),
      });
    });

    it('deve lançar erro quando response não é ok', async () => {
      fetch.mockResolvedValueOnce({
        ok: false,
        text: async () => 'Erro do servidor'
      });

      const { result } = renderHook(() => usePayments());

      const paymentData = {
        client_id: 1,
        product_ids: [1],
        payment_type: 'one_time'
      };

      await expect(
        act(async () => {
          await result.current.createPayment(paymentData);
        })
      ).rejects.toThrow('Erro ao criar pagamento: Erro do servidor');
    });
  });
});