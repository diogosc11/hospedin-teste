import { useState } from "react";
import { Modal, Form, Button, Row, Col, Spinner, Alert } from "react-bootstrap";

import { useClients } from "../../hooks/useClients";
import { useProducts } from "../../hooks/useProducts";

export function NewPayment({ showModal, setShowModal }) {
  const { clients, loading: clientsLoading, error: clientsError } = useClients();
  const { products, loading: productsLoading, error: productsError } = useProducts();

  const [formData, setFormData] = useState({
    product: '',
    value: '',
    status: '',
    date: '',
    client_id: '',
    payment_type: ''
  });
  const handleCloseModal = () => {
    setShowModal(false);

    setFormData({
      product: '',
      value: '',
      status: '',
      date: '',
      client_id: '',
      payment_type: ''
    });
  };

  const handleInputChange = (field, value) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));
  };

  const handleSavePayment = () => {
  };

  return (
    <>
      <Modal show={showModal} onHide={handleCloseModal} size="lg">
        <Modal.Header closeButton>
          <Modal.Title>Novo Pagamento</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <Form>
            {clientsError && (
              <Alert variant="danger" className="mb-3">
                Erro ao carregar clientes: {clientsError}
              </Alert>
            )}
            <Row>
              <Col md={12}>
                <Form.Group className="mb-3">
                  <Form.Label>Produto *</Form.Label>
                  <Form.Select
                    value={formData.product}
                    onChange={(e) => handleInputChange('product', e.target.value)}
                    disabled={productsLoading}
                  >
                    <option value="">
                      {productsLoading ? 'Carregando produtos...' : 'Selecione um produto'}
                    </option>
                    {products.map(product => (
                      <option key={product.id} value={product.id}>
                        {product.name}
                      </option>
                    ))}
                  </Form.Select>
                  {productsLoading && (
                    <div className="mt-1">
                      <Spinner animation="border" size="sm" />
                      <span className="ms-2 small text-muted">Carregando produtos...</span>
                    </div>
                  )}
                </Form.Group>
              </Col>
            </Row>
            
            <Row>
              <Col md={6}>
                <Form.Group className="mb-3">
                  <Form.Label>Cliente *</Form.Label>
                  <Form.Select
                    value={formData.client_id}
                    onChange={(e) => handleInputChange('client_id', e.target.value)}
                    disabled={clientsLoading}
                  >
                    <option value="">
                      {clientsLoading ? 'Carregando clientes...' : 'Selecione um cliente'}
                    </option>
                    {clients.map(client => (
                      <option key={client.id} value={client.id}>
                        {client.name} - {client.company || 'Sem empresa'}
                      </option>
                    ))}
                  </Form.Select>
                  {clientsLoading && (
                    <div className="mt-1">
                      <Spinner animation="border" size="sm" />
                      <span className="ms-2 small text-muted">Carregando clientes...</span>
                    </div>
                  )}
                </Form.Group>
              </Col>
              <Col md={6}>
                <Form.Group className="mb-3">
                  <Form.Label>Tipo de Cobrança</Form.Label>
                  <Form.Select>
                    <option value="">Selecione o tipo</option>
                    <option value="avulsa">Avulsa</option>
                    <option value="recorrente">Recorrente</option>
                  </Form.Select>
                </Form.Group>
              </Col>
            </Row>
          </Form>
        </Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={handleCloseModal}>
            Cancelar
          </Button>
          <Button variant="success" onClick={handleSavePayment}>
            Salvar Pagamento
          </Button>
        </Modal.Footer>
      </Modal>
    </>
  )
}