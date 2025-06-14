import { Table } from 'react-bootstrap';
import { formatDate } from '../../utils/formatDate';

export function CustomTable({ columns, data }) {
  return (
    <>
      <Table striped bordered hover variant="dark">
        <thead>
          <tr>
            {columns?.map((col, index) => (
              <th key={index}>{col.header}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data?.map((row, rowIndex) => (
            <tr key={rowIndex}>
              {columns.map((col, colIndex) => (
                <td key={colIndex}>
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