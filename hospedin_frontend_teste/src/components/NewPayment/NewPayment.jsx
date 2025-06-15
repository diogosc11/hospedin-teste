import { useState } from "react";
import { Modal, Form, Button, Row, Col, Spinner, Alert } from "react-bootstrap";

import { useClients } from "../../hooks/useClients";
import { useProducts } from "../../hooks/useProducts";
import { usePayments } from '../../hooks/usePayments';

export function NewPayment({ showModal, setShowModal, onPaymentCreated }) {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [hasAttemptedSubmit, setHasAttemptedSubmit] = useState(false);

  const { clients, loading: clientsLoading, error: clientsError } = useClients();
  const { products, loading: productsLoading, error: productsError } = useProducts();
  const { createPayment } = usePayments();

  const [formData, setFormData] = useState({
    products: [],
    client_id: '',
    payment_type: ''
  });

  const isProductsValid = formData.products.length > 0;
  const isClientValid = formData.client_id !== '';
  const isPaymentTypeValid = formData.payment_type !== '';
  const isFormValid = isProductsValid && isClientValid && isPaymentTypeValid;

  const handleCloseModal = () => {
    setShowModal(false);
    setHasAttemptedSubmit(false);

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
    setHasAttemptedSubmit(true);

    if (!isFormValid) {
      return;
    }

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

  const getValidationState = (isValid) => {
    if (!hasAttemptedSubmit) return {};
    return {
      isInvalid: !isValid,
      isValid: isValid
    };
  };

  return (
    <>
      <Modal show={showModal} onHide={handleCloseModal} size="lg">
        <Modal.Header closeButton>
          <Modal.Title>Novo Pagamento</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <Alert variant="info" className="mb-4">
            <small>
              <strong>Atenção:</strong> Todos os campos marcados com <span className="text-danger">*</span> são obrigatórios para criar o pagamento.
            </small>
          </Alert>

          {hasAttemptedSubmit && !isFormValid && (
            <Alert variant="danger" className="mb-3">
              <strong>Campos obrigatórios não preenchidos:</strong>
              <ul className="mb-0 mt-2">
                {!isProductsValid && <li>Selecione pelo menos um produto</li>}
                {!isClientValid && <li>Selecione um cliente</li>}
                {!isPaymentTypeValid && <li>Selecione o tipo de cobrança</li>}
              </ul>
            </Alert>
          )}

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
                  <Form.Label>
                    Produtos <span className="text-danger">*</span>
                  </Form.Label>
                  <Form.Select
                    multiple
                    size={4}
                    value={formData.products}
                    onChange={(e) => {
                      const selectedOptions = Array.from(e.target.selectedOptions, opt => opt.value);
                      handleInputChange('products', selectedOptions);
                    }}
                    disabled={productsLoading}
                    {...getValidationState(isProductsValid)}
                  >
                    {productsLoading ? (
                      <option>Carregando produtos...</option>
                    ) : (
                      products.map(product => (
                        <option key={product.id} value={product.id}>
                          {product.name} - {product.formatted_price || `R$ ${product.price}`}
                        </option>
                      ))
                    )}
                  </Form.Select>
                  <Form.Text className="text-muted">
                    Segure Ctrl para selecionar múltiplos produtos
                  </Form.Text>
                  {hasAttemptedSubmit && !isProductsValid && (
                    <Form.Control.Feedback type="invalid" style={{display: 'block'}}>
                      Selecione pelo menos um produto.
                    </Form.Control.Feedback>
                  )}
                </Form.Group>
              </Col>
            </Row>
            
            <Row>
              <Col md={6}>
                <Form.Group className="mb-3">
                  <Form.Label>
                    Cliente <span className="text-danger">*</span>
                  </Form.Label>
                  <Form.Select
                    value={formData.client_id}
                    onChange={(e) => handleInputChange('client_id', e.target.value)}
                    disabled={clientsLoading}
                    {...getValidationState(isClientValid)}
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
                  {hasAttemptedSubmit && !isClientValid && (
                    <Form.Control.Feedback type="invalid" style={{display: 'block'}}>
                      Selecione um cliente.
                    </Form.Control.Feedback>
                  )}
                </Form.Group>
              </Col>
              <Col md={6}>
                <Form.Group className="mb-3">
                  <Form.Label>
                    Tipo de Cobrança <span className="text-danger">*</span>
                  </Form.Label>
                  <Form.Select
                    value={formData.payment_type}
                    onChange={(e) => handleInputChange('payment_type', e.target.value)}
                    disabled={isSubmitting}
                    {...getValidationState(isPaymentTypeValid)}
                  >
                    <option value="">Selecione o tipo</option>
                    <option value="one_time">Avulsa (Pagamento Único)</option>
                    <option value="recurring">Recorrente (Assinatura Mensal)</option>
                  </Form.Select>
                  {hasAttemptedSubmit && !isPaymentTypeValid && (
                    <Form.Control.Feedback type="invalid" style={{display: 'block'}}>
                      Selecione o tipo de cobrança.
                    </Form.Control.Feedback>
                  )}
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
            disabled={isSubmitting}
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