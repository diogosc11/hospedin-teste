import { useState, useEffect } from 'react';
import { Container, Navbar, Form, Button, Row, Col } from 'react-bootstrap';
import { CustomTable } from './components/CustomTable/CustomTable';
import { NewPayment } from './components/NewPayment/NewPayment';

import './App.css';

function App() {
  const [filter, setFilter] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [payments, setPayments] = useState([]);
  const [loading, setLoading] = useState(true);

  const columns = [
    { header: '#', accessor: 'id' },
    { header: 'Produto', accessor: 'product' },
    { header: 'Valor', accessor: 'value' },
    { header: 'Status', accessor: 'status' },
    { header: 'Data', accessor: 'date' },
    { header: 'Id do cliente', accessor: 'client_id' },
    { header: 'Tipo de cobrança', accessor: 'type' },
  ];

  async function fetchPayments() {
    try {
      const response = await fetch('http://localhost:3000/api/v1/payments');
      const json = await response.json();

      const mapped = json.data.map((item) => ({
        id: item.id,
        product: item.product_name,
        value: item.valor,
        status: item.status_humanizado,
        date: item.data_pagamento,
        client_id: item.client_name,
        type: item.tipo_cobranca,
      }));
      setPayments(mapped);
    } catch (error) {
      console.error('Erro ao buscar pagamentos:', error);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    fetchPayments();
  }, []);

  const filteredData = payments.filter(item => {
    const searchTerm = filter.toLowerCase();
    return (
      item.product.toLowerCase().includes(searchTerm) ||
      item.status.toLowerCase().includes(searchTerm) ||
      item.type.toLowerCase().includes(searchTerm)
    );
  });

  return (
    <>
      <Navbar bg="dark" data-bs-theme="dark">
        <Container>
          <Navbar.Brand href="#home">Teste Hospedin</Navbar.Brand>
        </Container>
      </Navbar>
      <Container>
        <Row className="my-3 align-items-center">
          <Col md={6}>
            <Form.Control
              type="text"
              placeholder="Filtrar produto, status ou tipo"
              value={filter}
              onChange={(e) => setFilter(e.target.value)}
              style={{ maxWidth: '400px' }}
            />
          </Col>
          <Col md={6} className="text-end">
            <Button 
              variant="success" 
              className="fw-bold"
              onClick={() => setShowModal(true)}
            >
              + Novo pagamento
            </Button>
          </Col>
        </Row>
        {loading ? (
          <p>Carregando pagamentos...</p>
        ) : (
          <CustomTable columns={columns} data={filteredData} />
        )}
      </Container>
      <NewPayment showModal={showModal} setShowModal={setShowModal} onPaymentCreated={fetchPayments} />
    </>
  );
}

export default App;
