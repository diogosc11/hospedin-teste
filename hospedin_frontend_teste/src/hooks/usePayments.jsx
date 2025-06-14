// src/hooks/usePayments.js
import { useState, useCallback } from 'react';

export function usePayments() {
  const [payments, setPayments] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchPayments = useCallback(async (filters = {}) => {
    setLoading(true);

    try {
      const queryParams = new URLSearchParams();

      if (filters.name) queryParams.append('name', filters.name);
      if (filters.status_pagamento) queryParams.append('status_pagamento', filters.status_pagamento);
      if (filters.tipo_cobranca) queryParams.append('tipo_cobranca', filters.tipo_cobranca);

      const response = await fetch(`http://localhost:3000/api/v1/payments?${queryParams}`);
      const json = await response.json();

      const mapped = json.data.map((item) => ({
        id: item.id,
        product: item.product_name,
        value: item.valor,
        status: item.status_humanizado,
        date: item.data_pagamento,
        client_id: item.client_name,
        migrando: item.migrando_para_pagarme ? 'Sim' : 'Não',
        type: item.tipo_cobranca,
      }));

      setPayments(mapped);
    } catch (error) {
      console.error('Erro ao buscar pagamentos:', error);
    } finally {
      setLoading(false);
    }
  }, []);

  const createPayment = useCallback(async ({ client_id, product_ids, tipo_cobranca }) => {
    const response = await fetch('http://localhost:3000/api/v1/payments', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        client_id: parseInt(client_id),
        product_ids: product_ids.map(Number),
        tipo_cobranca,
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Erro ao criar pagamento: ${errorText}`);
    }

    return await response.json();
  }, []);

  return { payments, loading, fetchPayments, createPayment };
}
