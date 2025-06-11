import { useState } from "react";
import { Modal, Form, Button, Row, Col, Spinner, Alert } from "react-bootstrap";

import { useClients } from "../../hooks/useClients";
import { useProducts } from "../../hooks/useProducts";

export function NewPayment({ showModal, setShowModal, onPaymentCreated }) {
  const [isSubmitting, setIsSubmitting] = useState(false);

  const { clients, loading: clientsLoading, error: clientsError } = useClients();
  const { products, loading: productsLoading, error: productsError } = useProducts();

  const [formData, setFormData] = useState({
    product: '',
    client_id: '',
    payment_type: ''
  });

  const handleCloseModal = () => {
    setShowModal(false);

    setFormData({
      product: '',
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

  const handleSavePayment = async () => {
    setIsSubmitting(true);

    try {
      const response = await fetch('http://localhost:3000/api/v1/payments', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          client_id: parseInt(formData.client_id),
          product_id: parseInt(formData.product),
          tipo_cobranca: formData.tipo_cobranca
        })
      });

      if (!response.ok) {
        throw new Error('Erro ao criar pagamento');
      }

      handleCloseModal();
      onPaymentCreated?.();
    } catch (error) {
      console.error('Erro na requisição:', error);
    } finally {
      setIsSubmitting(false);
    }
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
            {productsError && (
              <Alert variant="danger" className="mb-3">
                Erro ao carregar produtos: {productsError}
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
                  <Form.Label>Tipo de Cobrança *</Form.Label>
                  <Form.Select
                    value={formData.tipo_cobranca}
                    onChange={(e) => handleInputChange('tipo_cobranca', e.target.value)}
                    disabled={isSubmitting}
                  >
                    <option value="">Selecione o tipo</option>
                    <option value="avulsa">Avulsa (Pagamento Único)</option>
                    <option value="recorrente">Recorrente (Assinatura Mensal)</option>
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
          <Button 
            variant="success" 
            onClick={handleSavePayment}
            disabled={isSubmitting || !formData.client_id || !formData.product || !formData.tipo_cobranca}
          >
            {isSubmitting ? (
              <>
                <Spinner animation="border" size="sm" className="me-2" />
                Processando...
              </>
            ) : (
              'Criar Pagamento'
            )}
          </Button>
        </Modal.Footer>
      </Modal>
    </>
  )
}