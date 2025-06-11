import { useState, useEffect } from 'react';

const API_BASE_URL = 'http://localhost:3000/api/v1';

export const useClients = () => {
  const [clients, setClients] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const fetchClients = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const response = await fetch(`${API_BASE_URL}/clients`);
      
      if (!response.ok) {
        throw new Error(`Erro ${response.status}: ${response.statusText}`);
      }
      
      const data = await response.json();
      setClients(data);
    } catch (err) {
      setError(err.message);
      console.error('Erro ao buscar clientes:', err);
    } finally {
      setLoading(false);
    }
  };

  const getClient = async (id) => {
    try {
      const response = await fetch(`${API_BASE_URL}/clients/${id}`);
      
      if (!response.ok) {
        throw new Error(`Erro ${response.status}: ${response.statusText}`);
      }
      
      return await response.json();
    } catch (err) {
      setError(err.message);
      throw err;
    }
  };

  const createClient = async (clientData) => {
    try {
      setError(null);
      
      const response = await fetch(`${API_BASE_URL}/clients`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ client: clientData }),
      });
      
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || 'Erro ao criar cliente');
      }
      
      const newClient = await response.json();
      setClients(prev => [...prev, newClient]);
      
      return newClient;
    } catch (err) {
      setError(err.message);
      throw err;
    }
  };

  const updateClient = async (id, clientData) => {
    try {
      setError(null);
      
      const response = await fetch(`${API_BASE_URL}/clients/${id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ client: clientData }),
      });
      
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || 'Erro ao atualizar cliente');
      }
      
      const updatedClient = await response.json();
      setClients(prev => 
        prev.map(client => client.id === id ? updatedClient : client)
      );
      
      return updatedClient;
    } catch (err) {
      setError(err.message);
      throw err;
    }
  };

  const deleteClient = async (id) => {
    try {
      setError(null);
      
      const response = await fetch(`${API_BASE_URL}/clients/${id}`, {
        method: 'DELETE',
      });
      
      if (!response.ok) {
        throw new Error(`Erro ${response.status}: ${response.statusText}`);
      }
      
      setClients(prev => prev.filter(client => client.id !== id));
      
      return true;
    } catch (err) {
      setError(err.message);
      throw err;
    }
  };

  useEffect(() => {
    fetchClients();
  }, []);

  const refetch = () => {
    fetchClients();
  };

  return {
    clients,
    loading,
    error,
    getClient,
    createClient,
    updateClient,
    deleteClient,
    refetch,
  };
};