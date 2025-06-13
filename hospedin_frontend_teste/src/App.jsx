import { useState, useEffect } from 'react';
import { Container, Navbar, Form, Button, Row, Col } from 'react-bootstrap';
import { CustomTable } from './components/CustomTable/CustomTable';
import { NewPayment } from './components/NewPayment/NewPayment';

import './App.css';

function App() {
  const [showModal, setShowModal] = useState(false);
  const [payments, setPayments] = useState([]);
  const [loading, setLoading] = useState(true);

  const [productFilter, setProductFilter] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [typeFilter, setTypeFilter] = useState('');

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
    setLoading(true);
    try {
      const queryParams = new URLSearchParams();

      if (productFilter) queryParams.append('name', productFilter);
      if (statusFilter) queryParams.append('status_pagamento', statusFilter);
      if (typeFilter) queryParams.append('tipo_cobranca', typeFilter);

      const response = await fetch(`http://localhost:3000/api/v1/payments?${queryParams}`);
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

  return (
    <>
      <Navbar bg="dark" data-bs-theme="dark">
        <Container>
          <Navbar.Brand href="#home">Teste Hospedin</Navbar.Brand>
        </Container>
      </Navbar>
      <Container>
        <Row className="my-3 align-items-center">
          <Row className="my-3 align-items-center">
            <Col md={2}>
              <Form.Control
                type="text"
                placeholder="Filtrar por produto"
                value={productFilter}
                onChange={(e) => setProductFilter(e.target.value)}
              />
            </Col>
            <Col md={2}>
              <Form.Select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)}>
                <option value="">Todos os status</option>
                <option value="pendente">Pendente</option>
                <option value="confirmado">Confirmado</option>
                <option value="falhou">Falhou</option>
              </Form.Select>
            </Col>
            <Col md={2}>
              <Form.Select value={typeFilter} onChange={(e) => setTypeFilter(e.target.value)}>
                <option value="">Todos os tipos</option>
                <option value="avulsa">Pagamento Único</option>
                <option value="recorrente">Assinatura Mensal</option>
              </Form.Select>
            </Col>
            <Col md={2}>
              <Button 
                variant="primary"
                onClick={fetchPayments}
              >
                Buscar
              </Button>
              <Button 
                variant="success" 
                className="fw-bold"
                onClick={() => setShowModal(true)}
              >
                + Novo pagamento
              </Button>
            </Col>
          </Row>
        </Row>
        {loading ? (
          <p>Carregando pagamentos...</p>
        ) : (
          <CustomTable columns={columns} data={payments} />
        )}
      </Container>
      <NewPayment showModal={showModal} setShowModal={setShowModal} onPaymentCreated={fetchPayments} />
    </>
  );
}

export default App;
