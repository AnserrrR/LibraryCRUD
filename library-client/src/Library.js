import React, {useEffect, useState} from "react";
import {variables} from "./variables.js";

function Library(props) {
	const [Libraries, setLibraries] = useState([]);
	const [modalFields, setModalFields] = useState({
		title: "",
		LibID: 0,
		LibName: "",
		LibAddress: ""
	});

	useEffect(() => {
		refreshList();
	}, []);

	function refreshList() {
		//console.log("ok");
		fetch(variables.API_URL + "Library")
			.then(response => response.json())
			.then(data => {
				setLibraries(data);
			});
	}

	const changeLibFeilds = e => {
		// console.log(modalFields.LibID);
		// console.log(modalFields.LibName);
		// console.log(modalFields.LibAddress);

		switch (e.target.id) {
			case "name-input":
				setModalFields(prev => {
					return {
						...prev,
						LibName: e.target.value,
					};
				});
				break;

			case "address-input":
				setModalFields(prev => {
					return {
						...prev,
						LibAddress: e.target.value,
					};
				});
				break;
		}
	};

	//Click handlers
	function addClick() {
		setModalFields({
			title: "Add Library",
			LibID: 0,
			LibName: "",
			LibAddress: "",
		});
	}

	function editClick(lib) {
		setModalFields({
			title: "Edit library",
			LibID: lib.ID,
			LibName: lib.Name,
			LibAddress: lib.Address,
		});
	}

	function createClick() {
		fetch(variables.API_URL + "Library", {
			method: "POST",
			headers: {
				Accept: "application/json",
				"Content-Type": "application/json",
			},
			body: JSON.stringify({
				Name: modalFields.LibName,
				Address: modalFields.LibAddress,
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
		fetch(variables.API_URL + "Library", {
			method: "PUT",
			headers: {
				Accept: "application/json",
				"Content-Type": "application/json",
			},
			body: JSON.stringify({
				Id: modalFields.LibID,
				Name: modalFields.LibName,
				Address: modalFields.LibAddress,
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
			fetch(variables.API_URL + "Library/" + id, {
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
	//Render
	return (
		<div>
			<h3>Choose your library:</h3>

			<button
				type="button"
				className="btn btn-dark m-2 float-end"
				data-bs-toggle="modal"
				data-bs-target="#exampleModal"
				onClick={() => addClick()}>
				Add Library
			</button>

			<table className="table table-striped">
				<thead>
					<tr>
						<th>LibraryName</th>
						<th>LibraryAddress</th>
					</tr>
				</thead>
				<tbody>
					{Libraries.map(lib => (
						<tr key={lib.ID}>
							<td>{lib.Name}</td>
							<td>{lib.Address}</td>
							<td>
								<button
									type="button"
									className="btn btn-light mr-1"
									data-bs-toggle="modal"
									data-bs-target="#exampleModal"
									onClick={() => editClick(lib)}>
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
									onClick={() => deleteClick(lib.ID)}>
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
										<span className="input-group-text">LibraryName</span>
										<input
											id="name-input"
											type="text"
											className="form-control"
											value={modalFields.LibName}
											onChange={changeLibFeilds}
										/>
									</div>

									<div className="input-group mb-3">
										<span className="input-group-text">LibraryAddress</span>
										<input
											id="address-input"
											type="text"
											className="form-control"
											value={modalFields.LibAddress}
											onChange={changeLibFeilds}
										/>
									</div>
								</div>
							</div>

							{modalFields.LibID == 0 ? (
								<button
									type="button"
									className="btn btn-primary float-start"
									onClick={() => createClick()}>
									Create
								</button>
							) : null}

							{modalFields.LibID != 0 ? (
								<button
									type="button"
									className="btn btn-primary float-start"
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
export default Library;
