import React from "react";

function BookTable(props) {
	//Render
	return (
		<div>
			<table className="table table-striped">
				<thead>
					<tr>
						<th>Name</th>
						<th>Popularity (lendings count)</th>
					</tr>
				</thead>
				<tbody>
					{props.data.map(data => (
						<tr key={data.ID}>
							<th>{data.BookName}</th>
							<th>{data.LendingsCount}</th>
						</tr>
					))}
				</tbody>
			</table>
		</div>
	);
}

export default BookTable;
