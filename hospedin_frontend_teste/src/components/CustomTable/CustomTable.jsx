import { Table } from 'react-bootstrap';
import { formatDate } from '../../utils/formatDate';

export function CustomTable({ columns, data }) {
  return (
    <>
      <Table striped bordered hover variant="dark">
        <thead>
          <tr>
            {columns?.map((col) => (
              <th key={col.id}>{col.header}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data?.map((row) => (
            <tr key={row.id}>
              {columns.map((col) => (
                <td key={col.id}>
                  {col.accessor === 'date' 
                    ? formatDate(row[col.accessor]) 
                    : row[col.accessor]
                  }
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </Table>
    </>
  )
}