import { useState } from "react";
import { Modal, Form, Button, Row, Col, Spinner, Alert } from "react-bootstrap";

import { useClients } from "../../hooks/useClients";
import { useProducts } from "../../hooks/useProducts";
import { usePayments } from '../../hooks/usePayments';

export function NewPayment({ showModal, setShowModal, onPaymentCreated }) {
  const [isSubmitting, setIsSubmitting] = useState(false);

  const { clients, loading: clientsLoading, error: clientsError } = useClients();
  const { products, loading: productsLoading, error: productsError } = useProducts();
  const { createPayment } = usePayments();

  const [formData, setFormData] = useState({
    products: [],
    client_id: '',
    payment_type: ''
  });

  const handleCloseModal = () => {
    setShowModal(false);

    setFormData({
      products: [],
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
      await createPayment({
        client_id: formData.client_id,
        product_ids: formData.products,
        payment_type: formData.payment_type,
      });

      handleCloseModal();
      onPaymentCreated?.();
    } catch (error) {
      console.error('Erro na criação do pagamento:', error);
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
                  <Form.Label>Produtos *</Form.Label>
                  <Form.Select
                    multiple
                    value={formData.products}
                    onChange={(e) => {
                      const selectedOptions = Array.from(e.target.selectedOptions, opt => opt.value);
                      handleInputChange('products', selectedOptions);
                    }}
                    disabled={productsLoading}
                  >
                    {productsLoading ? (
                      <option>Carregando produtos...</option>
                    ) : (
                      products.map(product => (
                        <option key={product.id} value={product.id}>
                          {product.name}
                        </option>
                      ))
                    )}
                  </Form.Select>
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
                    value={formData.payment_type}
                    onChange={(e) => handleInputChange('payment_type', e.target.value)}
                    disabled={isSubmitting}
                  >
                    <option value="">Selecione o tipo</option>
                    <option value="one_time">Avulsa (Pagamento Único)</option>
                    <option value="recurring">Recorrente (Assinatura Mensal)</option>
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
            disabled={isSubmitting || !formData.client_id || formData.products.length === 0 || !formData.payment_type}
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