import { useState } from 'react';
import { Container, Navbar, Form, Button, Row, Col } from 'react-bootstrap';
import { CustomTable } from './components/CustomTable/CustomTable';

import './App.css'
import { NewPayment } from './components/NewPayment/NewPayment';

function App() {
  const [filter, setFilter] = useState('');
  const [showModal, setShowModal] = useState(false);

  const columns = [
    { header: '#', accessor: 'id' },
    { header: 'Produto', accessor: 'product' },
    { header: 'Valor', accessor: 'value' },
    { header: 'Status', accessor: 'status' },
    { header: 'Data', accessor: 'date' },
    { header: 'Id do cliente', accessor: 'client_id' },
    { header: 'Tipo de cobrança', accessor: 'type' },
  ];

  const data = [
    { id: 1, product: 'PMS', value: '99,90', status: 'pendente', date: '2023-01-01', client_id: 1, type: 'avulsa' },
    { id: 2, product: 'Motor', value: '89,90', status: 'confirmado', date: '2023-01-02', client_id: 2, type: 'avulsa' },
    { id: 3, product: 'Channel', value: '79,90', status: 'falhou', date: '2023-01-03', client_id: 3, type: 'recorrente' },
    { id: 4, product: 'PMS', value: '99,90', status: 'pendente', date: '2023-01-04', client_id: 4, type: 'recorrente' },
    { id: 5, product: 'Motor', value: '89,90', status: 'confirmado', date: '2023-01-05', client_id: 5, type: 'recorrente' },
  ];

  const filteredData = data.filter(item => {
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
        <CustomTable columns={columns} data={filteredData} />
      </Container>
      <NewPayment showModal={showModal} setShowModal={setShowModal} />
    </>
  )
}

export default App
