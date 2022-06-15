import React from "react";

function ReaderTable(props) {
	//Render
	return (
		<div>
			<table className="table table-striped">
				<thead>
					<tr>
						<th>Name</th>
						<th>Donated Books Popularity</th>
						<th>Donated Books Count</th>
						<th>Lendings Count</th>
					</tr>
				</thead>
				<tbody>
					{props.data.map(data => (
						<tr key={data.ID}>
							<th>{data.ReaderName}</th>
							<th>{data.DonatedBooksPopularity}</th>
							<th>{data.DonatedBooksCount}</th>
							<th>{data.LendingsCount}</th>
						</tr>
					))}
				</tbody>
			</table>
		</div>
	);
}

export default ReaderTable;
