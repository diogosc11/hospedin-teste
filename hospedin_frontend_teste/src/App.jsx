import { useState, useEffect } from 'react';
import { Container, Navbar, Form, Button, Row, Col } from 'react-bootstrap';
import { CustomTable } from './components/CustomTable/CustomTable';
import { NewPayment } from './components/NewPayment/NewPayment';

import { usePayments } from './hooks/usePayments';

import './App.css';

function App() {
  const [showModal, setShowModal] = useState(false);

  const [productFilter, setProductFilter] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [typeFilter, setTypeFilter] = useState('');

  const { payments, loading, fetchPayments } = usePayments();

  const columns = [
    { header: '#', accessor: 'id' },
    { header: 'Produto', accessor: 'product' },
    { header: 'Valor', accessor: 'amount' },
    { header: 'Status', accessor: 'status' },
    { header: 'Data', accessor: 'date' },
    { header: 'Id do cliente', accessor: 'client_id' },
    { header: 'Em Migração?', accessor: 'migrando' },
    { header: 'Tipo de cobrança', accessor: 'type' },
  ];

  const handleClearFilters = () => {
    setProductFilter('');
    setStatusFilter('');
    setTypeFilter('');
    fetchPayments();
  };

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
                <option value="pending">Pendente</option>
                <option value="confirmed">Confirmado</option>
                <option value="failed">Falhou</option>
              </Form.Select>
            </Col>
            <Col md={2}>
              <Form.Select value={typeFilter} onChange={(e) => setTypeFilter(e.target.value)}>
                <option value="">Todos os tipos</option>
                <option value="one_time">Pagamento Único</option>
                <option value="recurring">Assinatura Mensal</option>
              </Form.Select>
            </Col>
            <Col md={4}>
              <div className="d-flex gap-2">
                <Button 
                  variant="primary"
                  onClick={() =>
                    fetchPayments({
                      name: productFilter,
                      status: statusFilter,
                      payment_type: typeFilter
                    })
                  }
                >
                  Buscar
                </Button>
                <Button 
                  variant="danger"
                  onClick={handleClearFilters}
                >
                  Limpar
                </Button>
                <Button 
                  variant="success" 
                  className="fw-bold"
                  onClick={() => setShowModal(true)}
                >
                  + Novo pagamento
                </Button>
              </div>
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
