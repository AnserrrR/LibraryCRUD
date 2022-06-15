import React, {useEffect, useState} from "react";
import {variables} from "./variables.js";

function Book(props) {
	const [Books, setBooks] = useState([]);
	const [Sections, setSections] = useState([]);
	const [PublishingHouses, setPublishingHouses] = useState([]);
	const [Authors, setAuthors] = useState([]);
	const [Genres, setGenres] = useState([]);

	const [modalFields, setModalFields] = useState({
		title: "",
		BookID: 0,
		BookName: "",
		BookOrigLang: "",
		BookPagesCount: 0,
		SectionID: 0,
		PublishingHouseID: 0,
		AuthorID: 0,
		BookPublishingYear: 0,
		GenresID: [],
	});

	useEffect(() => {
		refreshList();
	}, []);

	async function refreshList() {
		fetch(variables.API_URL + "Book")
			.then(response => response.json())
			.then(data => {
				setBooks(data);
			});

		fetch(variables.API_URL + "Book/Section")
			.then(response => response.json())
			.then(data => {
				setSections(data);
			});

		fetch(variables.API_URL + "Book/PublishingHouse")
			.then(response => response.json())
			.then(data => {
				setPublishingHouses(data);
			});

		fetch(variables.API_URL + "Book/Author")
			.then(response => response.json())
			.then(data => {
				setAuthors(data);
			});
		fetch(variables.API_URL + "Book/Genre")
			.then(response => response.json())
			.then(data => {
				setGenres(data);
			});
	}

	const changeBookFeilds = e => {
		setModalFields(prev => {
			switch (e.target.id) {
				case "name-input":
					return {
						...prev,
						BookName: e.target.value,
					};
				case "lang-input":
					return {
						...prev,
						BookOrigLang: e.target.value,
					};
				case "pages-input":
					return {
						...prev,
						BookPagesCount: e.target.value,
					};
				case "section-input":
					const sectionSelect = document.getElementById("section-input");
					return {
						...prev,
						SectionID: sectionSelect.options[sectionSelect.selectedIndex].value,
					};
				case "publishing-input":
					const phSelect = document.getElementById("publishing-input");
					return {
						...prev,
						PublishingHouseID: phSelect.options[phSelect.selectedIndex].value,
					};
				case "author-input":
					const authorSelect = document.getElementById("author-input");
					return {
						...prev,
						AuthorID: authorSelect.options[authorSelect.selectedIndex].value,
					};
				case "year-input":
					return {
						...prev,
						BookPublishingYear: e.target.value,
					};
				case "genres-input":
					const genreSelect = document.getElementById("genres-input");
					let newGenresID =
						prev.GenresID != null
							? [
									...prev.GenresID,
									genreSelect.options[genreSelect.selectedIndex].value,
							  ]
							: [genreSelect.options[genreSelect.selectedIndex].value];
					console.log(newGenresID.map(string => parseInt(string)));
					let genresText = document.getElementById("genres-text");
					genresText.value = newGenresID.map(id => {
						for (let genre in Genres) {
							if (Genres[genre].ID == parseInt(id)) {
								return " " + Genres[genre].Name;
							}
						}
					});
					return {
						...prev,
						GenresID: newGenresID.map(string => parseInt(string)),
					};
			}
		});
	};

	//Click handlers
	function addClick() {
		setModalFields({
			title: "Add book",
			BookID: 0,
			BookName: "",
			BookOrigLang: "",
			BookPagesCount: 0,
			SectionID: Sections[0].ID,
			PublishingHouseID: PublishingHouses[0].ID,
			AuthorID: Authors[0].ID,
			BookPublishingYear: 0,
			GenresID: [],
		});
	}

	function editClick(book) {
		let GenresIDs =
			book.GenresID != null
				? book.GenresID.split(", ").map(string => parseInt(string))
				: null;
		setModalFields({
			title: "Edit book",
			BookID: book.ID,
			BookName: book.Name,
			BookOrigLang: book.OriginalLanguage,
			BookPagesCount: book.PagesCount,
			SectionID: book.SectionID,
			PublishingHouseID: book.PublishingHouseID,
			AuthorID: book.AuthorID,
			BookPublishingYear: book.PublishingYear,
			GenresID: GenresIDs,
		});

		let genresText = document.getElementById("genres-text");
		genresText.value = GenresIDs.map(id => {
			for (let genre in Genres) {
				if (Genres[genre].ID == parseInt(id)) {
					return " " + Genres[genre].Name;
				}
			}
		});
	}

	function createClick() {
		fetch(variables.API_URL + "Book", {
			method: "POST",
			headers: {
				Accept: "application/json",
				"Content-Type": "application/json",
			},
			body: JSON.stringify({
				Name: modalFields.BookName,
				OriginalLanguage: modalFields.BookOrigLang,
				PagesCount: modalFields.BookPagesCount,
				SectionID: modalFields.SectionID,
				PublishingHouseID: modalFields.PublishingHouseID,
				AuthorID: modalFields.AuthorID,
				PublishingYear: modalFields.BookPublishingYear,
				GenresID: modalFields.GenresID,
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
		fetch(variables.API_URL + "Book", {
			method: "PUT",
			headers: {
				Accept: "application/json",
				"Content-Type": "application/json",
			},
			body: JSON.stringify({
				ID: modalFields.BookID,
				Name: modalFields.BookName,
				OriginalLanguage: modalFields.BookOrigLang,
				PagesCount: modalFields.BookPagesCount,
				SectionID: modalFields.SectionID,
				PublishingHouseID: modalFields.PublishingHouseID,
				AuthorID: modalFields.AuthorID,
				PublishingYear: modalFields.BookPublishingYear,
				GenresID: modalFields.GenresID,
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
			fetch(variables.API_URL + "Book/" + id, {
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
			<h3>Books:</h3>

			<button
				type="button"
				className="btn btn-dark m-2 float-end"
				data-bs-toggle="modal"
				data-bs-target="#exampleModal"
				onClick={() => addClick()}>
				Add Book
			</button>

			<table className="table table-striped">
				<thead>
					<tr>
						<th>Name</th>
						<th>OriginalLanguage</th>
						<th>PagesCount</th>
						<th>Section</th>
						<th>PublishingHouse</th>
						<th>Author</th>
						<th>PublishingYear</th>
						<th>Genres</th>
					</tr>
				</thead>
				<tbody>
					{Books.map(book => (
						<tr key={book.ID}>
							<td>{book.Name}</td>
							<td>{book.OriginalLanguage}</td>
							<td>{book.PagesCount}</td>
							<td>{book.SectionName}</td>
							<td>{book.PublishingHouseName}</td>
							<td>{book.AuthorName}</td>
							<td>{book.PublishingYear}</td>
							<td>{book.GenresNames}</td>
							<td>
								<button
									type="button"
									className="btn btn-dark mr-1"
									data-bs-toggle="modal"
									data-bs-target="#exampleModal"
									onClick={() => editClick(book)}>
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
									onClick={() => deleteClick(book.ID)}>
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
										<span className="input-group-text">BookName</span>
										<input
											id="name-input"
											type="text"
											className="form-control"
											value={modalFields.BookName}
											onChange={changeBookFeilds}
										/>
									</div>
									<div className="input-group mb-3">
										<span className="input-group-text">OriginalLanguage</span>
										<input
											id="lang-input"
											type="text"
											className="form-control"
											value={modalFields.BookOrigLang}
											onChange={changeBookFeilds}
										/>
									</div>
									<div className="input-group mb-3">
										<span className="input-group-text">PagesCount</span>
										<input
											id="pages-input"
											type="text"
											className="form-control"
											value={modalFields.BookPagesCount}
											onChange={changeBookFeilds}
										/>
									</div>
									<div className="input-group mb-3">
										<span className="input-group-text">Section</span>
										<select
											id="section-input"
											className="form-select"
											onChange={changeBookFeilds}
											value={modalFields.SectionID}>
											{Sections.map(sect => (
												<option value={sect.ID}>{sect.Name}</option>
											))}
										</select>
									</div>
									<div className="input-group mb-3">
										<span className="input-group-text">PublishingHouse</span>
										<select
											id="publishing-input"
											className="form-select"
											onChange={changeBookFeilds}
											value={modalFields.PublishingHouseID}>
											{PublishingHouses.map(ph => (
												<option value={ph.ID}>{ph.Name}</option>
											))}
										</select>
									</div>

									<div className="input-group mb-3">
										<span className="input-group-text">Author</span>
										<select
											id="author-input"
											className="form-select"
											onChange={changeBookFeilds}
											value={modalFields.AuthorID}>
											{Authors.map(author => (
												<option value={author.ID}>{author.FullName}</option>
											))}
										</select>
									</div>
									<div className="input-group mb-3">
										<span className="input-group-text">PublishingYear</span>
										<input
											id="year-input"
											type="text"
											className="form-control"
											value={modalFields.BookPublishingYear}
											onChange={changeBookFeilds}
										/>
									</div>
								</div>
								<div className="d-flex flex-column bd-highlight mb-3">
									<div className="input-group mb-3 p-2 bd-highlight">
										<span className="input-group-text">Genres</span>
										<select
											id="genres-input"
											className="form-select"
											onChange={changeBookFeilds}
											value={
												modalFields.GenresID != null
													? modalFields.GenresID.at(-1)
													: 0
											}>
											{Genres.map(genre => (
												<option value={genre.ID}>{genre.Name}</option>
											))}
										</select>
									</div>
									<div class="form-group mb-3 p-2 bd-highlight">
										<label for="genres-text" class="col-form-label">
											Genres:
										</label>
										<textarea class="form-control" id="genres-text"></textarea>
									</div>
									<div class="form-group mb-3 p-2 bd-highlight">
										<button
											type="button"
											className="btn btn-danger float-start"
											onClick={() => {
												document.getElementById("genres-text").value = "";
												setModalFields(prev => {
													return {
														...prev,
														GenresID: [],
													};
												});
											}}>
											Clear genres
										</button>
									</div>
								</div>
							</div>

							{modalFields.BookID == 0 ? (
								<button
									type="button"
									className="btn btn-secondary float-start"
									onClick={() => createClick()}>
									Create
								</button>
							) : null}

							{modalFields.BookID != 0 ? (
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

export default Book;
