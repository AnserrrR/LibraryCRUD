import React from "react";

function StaffTable(props) {
	//Render
	return (
		<div>
			<table className="table table-striped">
				<thead>
					<tr>
						<th>Name</th>
						<th>Lendings Count</th>
					</tr>
				</thead>
				<tbody>
					{props.data.map(data => (
						<tr key={data.ID}>
							<th>{data.StaffName}</th>
							<th>{data.LendingsCount}</th>
						</tr>
					))}
				</tbody>
			</table>
		</div>
	);
}

export default StaffTable;
