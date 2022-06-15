import React, {useEffect, useState} from "react";
import {variables} from "./variables.js";

function Lending(props) {
	const [Lendings, setLendings] = useState([]);
	const [Readers, setReaders] = useState([]);
	const [ReadingRooms, setReadingRooms] = useState([]);
	const [Staff, setStaff] = useState([]);

	const [modalFields, setModalFields] = useState({
		title: "",
		LendingID: 0,
		LendingDate: "",
		ReturnDate: "",
		ReaderID: 0,
		ReadingRoomID: 0,
		StaffID: 0,
	});

	useEffect(() => {
		refreshList();
	}, []);

	async function refreshList() {
		fetch(variables.API_URL + "Lending")
			.then(response => response.json())
			.then(data => {
				setLendings(data);
			});

		fetch(variables.API_URL + "Lending/Reader")
			.then(response => response.json())
			.then(data => {
				setReaders(data);
			});

		fetch(variables.API_URL + "Lending/ReadingRoom")
			.then(response => response.json())
			.then(data => {
				setReadingRooms(data);
			});

		fetch(variables.API_URL + "Lending/Staff")
			.then(response => response.json())
			.then(data => {
				setStaff(data);
			});
	}

	const changeLendingFeilds = e => {
		setModalFields(prev => {
			switch (e.target.id) {
				case "lending-input":
					return {
						...prev,
						LendingDate: e.target.value,
					};
				case "return-input":
					return {
						...prev,
						ReturnDate: e.target.value,
					};
				case "reader-input":
					const readerSelect = document.getElementById("reader-input");
					return {
						...prev,
						ReaderID: readerSelect.options[readerSelect.selectedIndex].value,
					};
				case "room-input":
					const rrSelect = document.getElementById("room-input");
					return {
						...prev,
						ReadingRoomID: rrSelect.options[rrSelect.selectedIndex].value,
					};
				case "staff-input":
					const staffSelect = document.getElementById("staff-input");
					return {
						...prev,
						StaffID: staffSelect.options[staffSelect.selectedIndex].value,
					};
			}
		});
	};

	//Click handlers
	function addClick() {
        console.log(Date.now().toString());
		setModalFields({
			title: "Add lending",
			LendingID: 0,
			LendingDate: new Date().toLocaleDateString("en-CA"),
			ReturnDate: null,
			ReaderID: Readers[0].ID,
			ReadingRoomID: null,
			StaffID: Staff[0].ID,
		});
	}

	function editClick(lending) {
		setModalFields({
			title: "Add lending",
			LendingID: lending.ID,
			LendingDate: new Date(lending.LendingDate).toLocaleDateString("en-CA"),
			ReturnDate: new Date(lending.ReturnDate).toLocaleDateString("en-CA"),
			ReaderID: lending.ReaderID,
			ReadingRoomID: lending.ReadingRoomID,
			StaffID: lending.StaffID,
		});
	}

	function createClick() {
		fetch(variables.API_URL + "Lending", {
			method: "POST",
			headers: {
				Accept: "application/json",
				"Content-Type": "application/json",
			},
			body: JSON.stringify({
				LendingDate: modalFields.LendingDate,
				ReturnDate: modalFields.ReturnDate,
				ReaderID: modalFields.ReaderID,
				ReadingRoomID: modalFields.ReadingRoomID,
				StaffID: modalFields.StaffID,
			}),
		})
			.then(res => res.json())
			.then(
				result => {
					alert(result);
					refreshList();
				},
				error => {
					alert("Failed");
				}
			);
	}

	function updateClick() {
		fetch(variables.API_URL + "Lending", {
			method: "PUT",
			headers: {
				Accept: "application/json",
				"Content-Type": "application/json",
			},
			body: JSON.stringify({
				ID: modalFields.LendingID,
				LendingDate: modalFields.LendingDate,
				ReturnDate: modalFields.ReturnDate,
				ReaderID: modalFields.ReaderID,
				ReadingRoomID: modalFields.ReadingRoomID,
				StaffID: modalFields.StaffID,
			}),
		})
			.then(res => res.json())
			.then(
				result => {
					alert(result);
					refreshList();
				},
				error => {
					alert("Failed");
				}
			);
	}

	function deleteClick(id) {
		if (window.confirm("Are you sure?")) {
			fetch(variables.API_URL + "Lending/" + id, {
				method: "DELETE",
				headers: {
					Accept: "application/json",
					"Content-Type": "application/json",
				},
			})
				.then(res => res.json())
				.then(
					result => {
						alert(result);
						refreshList();
					},
					error => {
						alert("Failed");
					}
				);
		}
	}
	return (
		<div>
			<h3>Lendings:</h3>

			<button
				type="button"
				className="btn btn-dark m-2 float-end"
				data-bs-toggle="modal"
				data-bs-target="#exampleModal"
				onClick={() => addClick()}>
				Add Lending
			</button>

			<table className="table table-striped">
				<thead>
					<tr>
						<th>LendingDate</th>
						<th>ReturnDate</th>
						<th>Reader</th>
						<th>ReadingRoomLocation</th>
						<th>Staff</th>
                        <th>Books</th>
					</tr>
				</thead>
				<tbody>
					{Lendings.map(lending => (
						<tr key={lending.ID}>
							<td>
								{new Date(lending.LendingDate).toLocaleDateString("en-CA")}
							</td>
							<td>
								{lending.ReturnDate != null ? new Date(lending.ReturnDate).toLocaleDateString("en-CA")
                                : null}
							</td>
							<td>{lending.ReaderName}</td>
							<td>{lending.ReadingRoomLocation}</td>
							<td>{lending.StaffName}</td>
                            <td>{lending.BooksNames}</td>
							<td>
								<button
									type="button"
									className="btn btn-dark mr-1"
									data-bs-toggle="modal"
									data-bs-target="#exampleModal"
									onClick={() => editClick(lending)}>
									<svg
										xmlns="http://www.w3.org/2000/svg"
										width="16"
										height="16"
										fill="currentColor"
										className="bi bi-pencil-square"
										viewBox="0 0 16 16">
										<path d="M15.502 1.94a.5.5 0 0 1 0 .706L14.459 3.69l-2-2L13.502.646a.5.5 0 0 1 .707 0l1.293 1.293zm-1.75 2.456-2-2L4.939 9.21a.5.5 0 0 0-.121.196l-.805 2.414a.25.25 0 0 0 .316.316l2.414-.805a.5.5 0 0 0 .196-.12l6.813-6.814z" />
										<path
											fillRule="evenodd"
											d="M1 13.5A1.5 1.5 0 0 0 2.5 15h11a1.5 1.5 0 0 0 1.5-1.5v-6a.5.5 0 0 0-1 0v6a.5.5 0 0 1-.5.5h-11a.5.5 0 0 1-.5-.5v-11a.5.5 0 0 1 .5-.5H9a.5.5 0 0 0 0-1H2.5A1.5 1.5 0 0 0 1 2.5v11z"
										/>
									</svg>
								</button>
								<button
									type="button"
									className="btn btn-light mr-1"
									onClick={() => deleteClick(lending.ID)}>
									<svg
										xmlns="http://www.w3.org/2000/svg"
										width="16"
										height="16"
										fill="currentColor"
										className="bi bi-trash3-fill"
										viewBox="0 0 16 16">
										<path d="M11 1.5v1h3.5a.5.5 0 0 1 0 1h-.538l-.853 10.66A2 2 0 0 1 11.115 16h-6.23a2 2 0 0 1-1.994-1.84L2.038 3.5H1.5a.5.5 0 0 1 0-1H5v-1A1.5 1.5 0 0 1 6.5 0h3A1.5 1.5 0 0 1 11 1.5Zm-5 0v1h4v-1a.5.5 0 0 0-.5-.5h-3a.5.5 0 0 0-.5.5ZM4.5 5.029l.5 8.5a.5.5 0 1 0 .998-.06l-.5-8.5a.5.5 0 1 0-.998.06Zm6.53-.528a.5.5 0 0 0-.528.47l-.5 8.5a.5.5 0 0 0 .998.058l.5-8.5a.5.5 0 0 0-.47-.528ZM8 4.5a.5.5 0 0 0-.5.5v8.5a.5.5 0 0 0 1 0V5a.5.5 0 0 0-.5-.5Z" />
									</svg>
								</button>
							</td>
						</tr>
					))}
				</tbody>
			</table>

			<div
				className="modal fade"
				id="exampleModal"
				tabIndex="-1"
				aria-hidden="true">
				<div className="modal-dialog modal-lg modal-dialog-centered">
					<div className="modal-content">
						<div className="modal-header">
							<h5 className="modal-title">{modalFields.title}</h5>
							<button
								type="button"
								className="btn-close"
								data-bs-dismiss="modal"
								aria-label="Close"></button>
						</div>

						<div className="modal-body">
							<div className="d-flex flex-row bd-highlight mb-3">
								<div className="p-2 w-50 bd-highlight">
									<div className="input-group mb-3">
										<span className="input-group-text">LendingDate</span>
										<input
											id="lending-input"
											type="date"
											className="form-control"
											value={modalFields.LendingDate}
											onChange={changeLendingFeilds}
										/>
									</div>
									<div className="input-group mb-3">
										<span className="input-group-text">ReturnDate</span>
										<input
											id="return-input"
											type="date"
											className="form-control"
											value={modalFields.ReturnDate != null ? modalFields.ReturnDate : ""}
											onChange={changeLendingFeilds}
										/>
									</div>
									<div className="input-group mb-3">
										<span className="input-group-text">Reader</span>
										<select
											id="reader-input"
											className="form-select"
											onChange={changeLendingFeilds}
											value={modalFields.ReaderID}>
											{Readers.map(reader => (
												<option value={reader.ID}>{reader.Name}</option>
											))}
										</select>
									</div>
									<div className="input-group mb-3">
										<span className="input-group-text">
											ReadingRoomLocation
										</span>
										<select
											id="room-input"
											className="form-select"
											onChange={changeLendingFeilds}
											value={modalFields.ReadingRoomID != null ? modalFields.ReadingRoomID : ""}>
											{ReadingRooms.map(rr => {
												if (rr.Location != null)
													return <option value={rr.ID}>{rr.Location}</option>;
											})}
										</select>
									</div>

									<div className="input-group mb-3">
										<span className="input-group-text">Staff</span>
										<select
											id="staff-input"
											className="form-select"
											onChange={changeLendingFeilds}
											value={modalFields.StaffID}>
											{Staff.map(staff => (
												<option value={staff.ID}>{staff.Name}</option>
											))}
										</select>
									</div>
								</div>
							</div>

							{modalFields.LendingID == 0 ? (
								<button
									type="button"
									className="btn btn-secondary float-start"
									onClick={() => createClick()}>
									Create
								</button>
							) : null}

							{modalFields.LendingID != 0 ? (
								<button
									type="button"
									className="btn btn-secondary float-start"
									onClick={() => updateClick()}>
									Update
								</button>
							) : null}
						</div>
					</div>
				</div>
			</div>
		</div>
	);
}

export default Lending;
