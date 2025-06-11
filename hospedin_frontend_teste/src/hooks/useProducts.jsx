import { useState, useEffect } from 'react';

const API_BASE_URL = 'http://localhost:3000/api/v1';

export const useProducts = () => {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const fetchProducts = async (activeOnly = true) => {
    try {
      setLoading(true);
      setError(null);
      
      const url = activeOnly 
        ? `${API_BASE_URL}/products?active=true`
        : `${API_BASE_URL}/products`;
      
      
      const response = await fetch(url);
      
      if (!response.ok) {
        throw new Error(`Erro ${response.status}: ${response.statusText}`);
      }
      
      const data = await response.json();
      
      setProducts(data);
    } catch (err) {
      console.error('Erro ao buscar produtos:', err);
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const getProduct = async (id) => {
    try {
      const response = await fetch(`${API_BASE_URL}/products/${id}`);
      
      if (!response.ok) {
        throw new Error(`Erro ${response.status}: ${response.statusText}`);
      }
      
      return await response.json();
    } catch (err) {
      setError(err.message);
      throw err;
    }
  };

  useEffect(() => {
    fetchProducts(true);
  }, []);

  const refetch = (activeOnly = true) => {
    fetchProducts(activeOnly);
  };

  return {
    products,
    loading,
    error,    
    getProduct, 
    refetch,
  };
};